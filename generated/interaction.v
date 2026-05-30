(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Produced by: pipeline/clightgen.sh
   From source: vendor/sm64/src/game/interaction.c
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
  Definition source_file := "vendor/sm64/src/game/interaction.c".
  Definition normalized := true.
End Info.

Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _Area : ident := $"Area".
Definition _BullyCollisionData : ident := $"BullyCollisionData".
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
Definition _InteractionHandler : ident := $"InteractionHandler".
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
Definition _able_to_grab_object : ident := $"able_to_grab_object".
Definition _action : ident := $"action".
Definition _actionArg : ident := $"actionArg".
Definition _actionId : ident := $"actionId".
Definition _actionState : ident := $"actionState".
Definition _actionTimer : ident := $"actionTimer".
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _angle : ident := $"angle".
Definition _angleRange : ident := $"angleRange".
Definition _angleToMario : ident := $"angleToMario".
Definition _angleToObject : ident := $"angleToObject".
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
Definition _atan2s : ident := $"atan2s".
Definition _attackType : ident := $"attackType".
Definition _attack_object : ident := $"attack_object".
Definition _behavior : ident := $"behavior".
Definition _behaviorArg : ident := $"behaviorArg".
Definition _behaviorScript : ident := $"behaviorScript".
Definition _bhvBowser : ident := $"bhvBowser".
Definition _bhvCarrySomething3 : ident := $"bhvCarrySomething3".
Definition _bhvCarrySomething4 : ident := $"bhvCarrySomething4".
Definition _bhvCarrySomething5 : ident := $"bhvCarrySomething5".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvKoopaShellUnderwater : ident := $"bhvKoopaShellUnderwater".
Definition _bhvMetalCap : ident := $"bhvMetalCap".
Definition _bhvNormalCap : ident := $"bhvNormalCap".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _bhvStarKeyCollectionPuffSpawner : ident := $"bhvStarKeyCollectionPuffSpawner".
Definition _bhvVanishCap : ident := $"bhvVanishCap".
Definition _bhvWingCap : ident := $"bhvWingCap".
Definition _bhv_spawn_star_no_level_exit : ident := $"bhv_spawn_star_no_level_exit".
Definition _bonkAction : ident := $"bonkAction".
Definition _bounce_back_from_attack : ident := $"bounce_back_from_attack".
Definition _bounce_off_object : ident := $"bounce_off_object".
Definition _bufTarget : ident := $"bufTarget".
Definition _bully : ident := $"bully".
Definition _bullyDYaw : ident := $"bullyDYaw".
Definition _bullyData : ident := $"bullyData".
Definition _bullyToMarioRatio : ident := $"bullyToMarioRatio".
Definition _bully_knock_back_mario : ident := $"bully_knock_back_mario".
Definition _burningAction : ident := $"burningAction".
Definition _button : ident := $"button".
Definition _buttonDown : ident := $"buttonDown".
Definition _buttonPressed : ident := $"buttonPressed".
Definition _camera : ident := $"camera".
Definition _cameraEvent : ident := $"cameraEvent".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _capFlag : ident := $"capFlag".
Definition _capMusic : ident := $"capMusic".
Definition _capObject : ident := $"capObject".
Definition _capSpeed : ident := $"capSpeed".
Definition _capState : ident := $"capState".
Definition _capTime : ident := $"capTime".
Definition _capTimer : ident := $"capTimer".
Definition _ceil : ident := $"ceil".
Definition _ceilHeight : ident := $"ceilHeight".
Definition _check_death_barrier : ident := $"check_death_barrier".
Definition _check_kick_or_punch_wall : ident := $"check_kick_or_punch_wall".
Definition _check_lava_boost : ident := $"check_lava_boost".
Definition _check_npc_talk : ident := $"check_npc_talk".
Definition _check_object_grab_mario : ident := $"check_object_grab_mario".
Definition _check_read_sign : ident := $"check_read_sign".
Definition _children : ident := $"children".
Definition _coins : ident := $"coins".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _controller : ident := $"controller".
Definition _controllerData : ident := $"controllerData".
Definition _conversionRatio : ident := $"conversionRatio".
Definition _count : ident := $"count".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _currentAddr : ident := $"currentAddr".
Definition _cutscene : ident := $"cutscene".
Definition _dAngle : ident := $"dAngle".
Definition _dYaw : ident := $"dYaw".
Definition _dYawToObject : ident := $"dYawToObject".
Definition _damage : ident := $"damage".
Definition _defMode : ident := $"defMode".
Definition _destArea : ident := $"destArea".
Definition _destLevel : ident := $"destLevel".
Definition _destNode : ident := $"destNode".
Definition _detector : ident := $"detector".
Definition _determine_interaction : ident := $"determine_interaction".
Definition _determine_knockback_action : ident := $"determine_knockback_action".
Definition _dialog : ident := $"dialog".
Definition _displacement : ident := $"displacement".
Definition _distance : ident := $"distance".
Definition _dmaTable : ident := $"dmaTable".
Definition _does_mario_have_normal_cap_on_head : ident := $"does_mario_have_normal_cap_on_head".
Definition _door : ident := $"door".
Definition _doorAction : ident := $"doorAction".
Definition _doorSaveFileFlag : ident := $"doorSaveFileFlag".
Definition _doorStatus : ident := $"doorStatus".
Definition _doubleJumpTimer : ident := $"doubleJumpTimer".
Definition _drop_and_set_mario_action : ident := $"drop_and_set_mario_action".
Definition _drop_queued_background_music : ident := $"drop_queued_background_music".
Definition _dx : ident := $"dx".
Definition _dz : ident := $"dz".
Definition _enterDoorAction : ident := $"enterDoorAction".
Definition _errnum : ident := $"errnum".
Definition _eyeState : ident := $"eyeState".
Definition _f32_find_wall_collision : ident := $"f32_find_wall_collision".
Definition _faceAngle : ident := $"faceAngle".
Definition _facingDYaw : ident := $"facingDYaw".
Definition _facingDYaw__1 : ident := $"facingDYaw__1".
Definition _fadeWarpOpacity : ident := $"fadeWarpOpacity".
Definition _fadeout_level_music : ident := $"fadeout_level_music".
Definition _filler : ident := $"filler".
Definition _filler1 : ident := $"filler1".
Definition _filler2 : ident := $"filler2".
Definition _find_floor : ident := $"find_floor".
Definition _flags : ident := $"flags".
Definition _floor : ident := $"floor".
Definition _floorAngle : ident := $"floorAngle".
Definition _floorHeight : ident := $"floorHeight".
Definition _floorType : ident := $"floorType".
Definition _focus : ident := $"focus".
Definition _force : ident := $"force".
Definition _forwardVel : ident := $"forwardVel".
Definition _framesSinceA : ident := $"framesSinceA".
Definition _framesSinceB : ident := $"framesSinceB".
Definition _gCurrCourseNum : ident := $"gCurrCourseNum".
Definition _gCurrSaveFileNum : ident := $"gCurrSaveFileNum".
Definition _gGlobalTimer : ident := $"gGlobalTimer".
Definition _gHudDisplay : ident := $"gHudDisplay".
Definition _gMarioState : ident := $"gMarioState".
Definition _gSineTable : ident := $"gSineTable".
Definition _get_door_save_file_flag : ident := $"get_door_save_file_flag".
Definition _get_mario_cap_flag : ident := $"get_mario_cap_flag".
Definition _gettingBlownGravity : ident := $"gettingBlownGravity".
Definition _gfx : ident := $"gfx".
Definition _grabPos : ident := $"grabPos".
Definition _grandStar : ident := $"grandStar".
Definition _handState : ident := $"handState".
Definition _handler : ident := $"handler".
Definition _headAngle : ident := $"headAngle".
Definition _headRotation : ident := $"headRotation".
Definition _header : ident := $"header".
Definition _healCounter : ident := $"healCounter".
Definition _health : ident := $"health".
Definition _height : ident := $"height".
Definition _heldObj : ident := $"heldObj".
Definition _heldObjLastPosition : ident := $"heldObjLastPosition".
Definition _hit_object_from_below : ident := $"hit_object_from_below".
Definition _hitboxDownOffset : ident := $"hitboxDownOffset".
Definition _hitboxHeight : ident := $"hitboxHeight".
Definition _hitboxRadius : ident := $"hitboxRadius".
Definition _hurtCounter : ident := $"hurtCounter".
Definition _hurtboxHeight : ident := $"hurtboxHeight".
Definition _hurtboxRadius : ident := $"hurtboxRadius".
Definition _i : ident := $"i".
Definition _id : ident := $"id".
Definition _index : ident := $"index".
Definition _init_bully_collision_data : ident := $"init_bully_collision_data".
Definition _input : ident := $"input".
Definition _instantWarps : ident := $"instantWarps".
Definition _intendedMag : ident := $"intendedMag".
Definition _intendedYaw : ident := $"intendedYaw".
Definition _interact : ident := $"interact".
Definition _interactObj : ident := $"interactObj".
Definition _interactType : ident := $"interactType".
Definition _interact_bbh_entrance : ident := $"interact_bbh_entrance".
Definition _interact_bounce_top : ident := $"interact_bounce_top".
Definition _interact_breakable : ident := $"interact_breakable".
Definition _interact_bully : ident := $"interact_bully".
Definition _interact_cannon_base : ident := $"interact_cannon_base".
Definition _interact_cap : ident := $"interact_cap".
Definition _interact_clam_or_bubba : ident := $"interact_clam_or_bubba".
Definition _interact_coin : ident := $"interact_coin".
Definition _interact_damage : ident := $"interact_damage".
Definition _interact_door : ident := $"interact_door".
Definition _interact_flame : ident := $"interact_flame".
Definition _interact_grabbable : ident := $"interact_grabbable".
Definition _interact_hit_from_below : ident := $"interact_hit_from_below".
Definition _interact_hoot : ident := $"interact_hoot".
Definition _interact_igloo_barrier : ident := $"interact_igloo_barrier".
Definition _interact_koopa_shell : ident := $"interact_koopa_shell".
Definition _interact_mr_blizzard : ident := $"interact_mr_blizzard".
Definition _interact_pole : ident := $"interact_pole".
Definition _interact_shock : ident := $"interact_shock".
Definition _interact_snufit_bullet : ident := $"interact_snufit_bullet".
Definition _interact_star_or_key : ident := $"interact_star_or_key".
Definition _interact_strong_wind : ident := $"interact_strong_wind".
Definition _interact_text : ident := $"interact_text".
Definition _interact_tornado : ident := $"interact_tornado".
Definition _interact_unknown_08 : ident := $"interact_unknown_08".
Definition _interact_warp : ident := $"interact_warp".
Definition _interact_warp_door : ident := $"interact_warp_door".
Definition _interact_water_ring : ident := $"interact_water_ring".
Definition _interact_whirlpool : ident := $"interact_whirlpool".
Definition _interaction : ident := $"interaction".
Definition _invincTimer : ident := $"invincTimer".
Definition _isCCMDoor : ident := $"isCCMDoor".
Definition _isPSSDoor : ident := $"isPSSDoor".
Definition _keys : ident := $"keys".
Definition _length : ident := $"length".
Definition _level_control_timer : ident := $"level_control_timer".
Definition _level_trigger_warp : ident := $"level_trigger_warp".
Definition _lives : ident := $"lives".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowSpeed : ident := $"lowSpeed".
Definition _lowerY : ident := $"lowerY".
Definition _m : ident := $"m".
Definition _macroObjects : ident := $"macroObjects".
Definition _main : ident := $"main".
Definition _mario : ident := $"mario".
Definition _marioBodyState : ident := $"marioBodyState".
Definition _marioDYaw : ident := $"marioDYaw".
Definition _marioData : ident := $"marioData".
Definition _marioObj : ident := $"marioObj".
Definition _marioToBullyRatio : ident := $"marioToBullyRatio".
Definition _mario_blow_off_cap : ident := $"mario_blow_off_cap".
Definition _mario_can_talk : ident := $"mario_can_talk".
Definition _mario_check_object_grab : ident := $"mario_check_object_grab".
Definition _mario_drop_held_object : ident := $"mario_drop_held_object".
Definition _mario_get_collided_object : ident := $"mario_get_collided_object".
Definition _mario_grab_used_object : ident := $"mario_grab_used_object".
Definition _mario_handle_special_floors : ident := $"mario_handle_special_floors".
Definition _mario_lose_cap_to_enemy : ident := $"mario_lose_cap_to_enemy".
Definition _mario_obj_angle_to_object : ident := $"mario_obj_angle_to_object".
Definition _mario_process_interactions : ident := $"mario_process_interactions".
Definition _mario_retrieve_cap : ident := $"mario_retrieve_cap".
Definition _mario_set_forward_vel : ident := $"mario_set_forward_vel".
Definition _mario_stop_riding_and_holding : ident := $"mario_stop_riding_and_holding".
Definition _mario_stop_riding_object : ident := $"mario_stop_riding_object".
Definition _mario_throw_held_object : ident := $"mario_throw_held_object".
Definition _minDistance : ident := $"minDistance".
Definition _mode : ident := $"mode".
Definition _model : ident := $"model".
Definition _modelState : ident := $"modelState".
Definition _musicParam : ident := $"musicParam".
Definition _musicParam2 : ident := $"musicParam2".
Definition _newBullyYaw : ident := $"newBullyYaw".
Definition _newMarioX : ident := $"newMarioX".
Definition _newMarioYaw : ident := $"newMarioYaw".
Definition _newMarioZ : ident := $"newMarioZ".
Definition _next : ident := $"next".
Definition _nextYaw : ident := $"nextYaw".
Definition _noExit : ident := $"noExit".
Definition _node : ident := $"node".
Definition _normal : ident := $"normal".
Definition _numCoins : ident := $"numCoins".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _numKeys : ident := $"numKeys".
Definition _numLives : ident := $"numLives".
Definition _numStars : ident := $"numStars".
Definition _numViews : ident := $"numViews".
Definition _o : ident := $"o".
Definition _obj_set_held_state : ident := $"obj_set_held_state".
Definition _object : ident := $"object".
Definition _objectSpawnInfos : ident := $"objectSpawnInfos".
Definition _object_facing_mario : ident := $"object_facing_mario".
Definition _offset : ident := $"offset".
Definition _offsetX : ident := $"offsetX".
Definition _offsetZ : ident := $"offsetZ".
Definition _originOffset : ident := $"originOffset".
Definition _padding : ident := $"padding".
Definition _paintingWarpNodes : ident := $"paintingWarpNodes".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _particleFlags : ident := $"particleFlags".
Definition _peakHeight : ident := $"peakHeight".
Definition _pitch : ident := $"pitch".
Definition _platform : ident := $"platform".
Definition _play_cap_music : ident := $"play_cap_music".
Definition _play_shell_music : ident := $"play_shell_music".
Definition _play_sound : ident := $"play_sound".
Definition _pos : ident := $"pos".
Definition _posX : ident := $"posX".
Definition _posY : ident := $"posY".
Definition _posZ : ident := $"posZ".
Definition _prev : ident := $"prev".
Definition _prevAction : ident := $"prevAction".
Definition _prevNumStarsForDialog : ident := $"prevNumStarsForDialog".
Definition _prevObj : ident := $"prevObj".
Definition _pss_begin_slide : ident := $"pss_begin_slide".
Definition _pss_end_slide : ident := $"pss_end_slide".
Definition _punchState : ident := $"punchState".
Definition _pushAngle : ident := $"pushAngle".
Definition _push_mario_out_of_object : ident := $"push_mario_out_of_object".
Definition _quicksandDepth : ident := $"quicksandDepth".
Definition _radius : ident := $"radius".
Definition _rawData : ident := $"rawData".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _remainingHealth : ident := $"remainingHealth".
Definition _requiredNumStars : ident := $"requiredNumStars".
Definition _reset_mario_pitch : ident := $"reset_mario_pitch".
Definition _resolve_and_return_wall_collisions : ident := $"resolve_and_return_wall_collisions".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _result : ident := $"result".
Definition _riddenObj : ident := $"riddenObj".
Definition _roll : ident := $"roll".
Definition _room : ident := $"room".
Definition _sBackwardKnockbackActions : ident := $"sBackwardKnockbackActions".
Definition _sDelayInvincTimer : ident := $"sDelayInvincTimer".
Definition _sDisplayingDoorText : ident := $"sDisplayingDoorText".
Definition _sForwardKnockbackActions : ident := $"sForwardKnockbackActions".
Definition _sInteractionHandlers : ident := $"sInteractionHandlers".
Definition _sInvulnerable : ident := $"sInvulnerable".
Definition _sJustTeleported : ident := $"sJustTeleported".
Definition _sPSSSlideStarted : ident := $"sPSSSlideStarted".
Definition _saveFileFlag : ident := $"saveFileFlag".
Definition _saveFlags : ident := $"saveFlags".
Definition _save_file_clear_flags : ident := $"save_file_clear_flags".
Definition _save_file_collect_star_or_key : ident := $"save_file_collect_star_or_key".
Definition _save_file_get_flags : ident := $"save_file_get_flags".
Definition _save_file_get_total_star_count : ident := $"save_file_get_total_star_count".
Definition _save_file_set_cap_pos : ident := $"save_file_set_cap_pos".
Definition _save_file_set_flags : ident := $"save_file_set_flags".
Definition _scale : ident := $"scale".
Definition _script : ident := $"script".
Definition _segmented_to_virtual : ident := $"segmented_to_virtual".
Definition _set_camera_mode : ident := $"set_camera_mode".
Definition _set_camera_shake_from_hit : ident := $"set_camera_shake_from_hit".
Definition _set_mario_action : ident := $"set_mario_action".
Definition _shake : ident := $"shake".
Definition _sharedChild : ident := $"sharedChild".
Definition _should_push_or_pull_door : ident := $"should_push_or_pull_door".
Definition _size : ident := $"size".
Definition _slideTime : ident := $"slideTime".
Definition _slideVelX : ident := $"slideVelX".
Definition _slideVelZ : ident := $"slideVelZ".
Definition _slideYaw : ident := $"slideYaw".
Definition _spawnInfo : ident := $"spawnInfo".
Definition _spawn_default_star : ident := $"spawn_default_star".
Definition _spawn_object : ident := $"spawn_object".
Definition _sqrtf : ident := $"sqrtf".
Definition _squishTimer : ident := $"squishTimer".
Definition _srcAddr : ident := $"srcAddr".
Definition _starGrabAction : ident := $"starGrabAction".
Definition _starIndex : ident := $"starIndex".
Definition _stars : ident := $"stars".
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
Definition _stop_shell_music : ident := $"stop_shell_music".
Definition _strength : ident := $"strength".
Definition _strengthIndex : ident := $"strengthIndex".
Definition _surfaceRooms : ident := $"surfaceRooms".
Definition _take_damage_and_knock_back : ident := $"take_damage_and_knock_back".
Definition _take_damage_from_interact_object : ident := $"take_damage_from_interact_object".
Definition _targetX : ident := $"targetX".
Definition _targetZ : ident := $"targetZ".
Definition _terrainData : ident := $"terrainData".
Definition _terrainIndex : ident := $"terrainIndex".
Definition _terrainSoundAddend : ident := $"terrainSoundAddend".
Definition _terrainType : ident := $"terrainType".
Definition _text : ident := $"text".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _timer : ident := $"timer".
Definition _torsoAngle : ident := $"torsoAngle".
Definition _transfer_bully_speed : ident := $"transfer_bully_speed".
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
Definition _val6 : ident := $"val6".
Definition _values : ident := $"values".
Definition _vel : ident := $"vel".
Definition _velX : ident := $"velX".
Definition _velY : ident := $"velY".
Definition _velZ : ident := $"velZ".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _views : ident := $"views".
Definition _virtual_to_segmented : ident := $"virtual_to_segmented".
Definition _wall : ident := $"wall".
Definition _wallKickTimer : ident := $"wallKickTimer".
Definition _warpDoorId : ident := $"warpDoorId".
Definition _warpNodes : ident := $"warpNodes".
Definition _warp_pipe_seg3_collision_03009AC8 : ident := $"warp_pipe_seg3_collision_03009AC8".
Definition _wasWearingCap : ident := $"wasWearingCap".
Definition _waterLevel : ident := $"waterLevel".
Definition _wedges : ident := $"wedges".
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
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v_gCurrCourseNum := {|
  gvar_info := tshort;
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

Definition v_warp_pipe_seg3_collision_03009AC8 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvKoopaShellUnderwater := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBowser := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvCarrySomething3 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvCarrySomething4 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvCarrySomething5 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvStarKeyCollectionPuffSpawner := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvWingCap := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvMetalCap := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvNormalCap := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvVanishCap := {|
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

Definition v_sDelayInvincTimer := {|
  gvar_info := tuchar;
  gvar_init := (Init_space 1 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sInvulnerable := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sInteractionHandlers := {|
  gvar_info := (tarray (Tstruct _InteractionHandler noattr) 31);
  gvar_init := (Init_int32 (Int.repr 16) :: Init_space 4 ::
                Init_addrof _interact_coin (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 65536) :: Init_space 4 ::
                Init_addrof _interact_water_ring (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 4096) :: Init_space 4 ::
                Init_addrof _interact_star_or_key (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) :: Init_space 4 ::
                Init_addrof _interact_bbh_entrance (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 8192) :: Init_space 4 ::
                Init_addrof _interact_warp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 2048) :: Init_space 4 ::
                Init_addrof _interact_warp_door (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 4) :: Init_space 4 ::
                Init_addrof _interact_door (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 16384) :: Init_space 4 ::
                Init_addrof _interact_cannon_base (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 1073741824) :: Init_space 4 ::
                Init_addrof _interact_igloo_barrier (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 16777216) :: Init_space 4 ::
                Init_addrof _interact_tornado (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 33554432) :: Init_space 4 ::
                Init_addrof _interact_whirlpool (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 1024) :: Init_space 4 ::
                Init_addrof _interact_strong_wind (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 262144) :: Init_space 4 ::
                Init_addrof _interact_flame (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 268435456) :: Init_space 4 ::
                Init_addrof _interact_snufit_bullet (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 67108864) :: Init_space 4 ::
                Init_addrof _interact_clam_or_bubba (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 131072) :: Init_space 4 ::
                Init_addrof _interact_bully (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 536870912) :: Init_space 4 ::
                Init_addrof _interact_shock (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 1048576) :: Init_space 4 ::
                Init_addrof _interact_bounce_top (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 2097152) :: Init_space 4 ::
                Init_addrof _interact_mr_blizzard (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 4194304) :: Init_space 4 ::
                Init_addrof _interact_hit_from_below (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 32768) :: Init_space 4 ::
                Init_addrof _interact_bounce_top (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 8) :: Init_space 4 ::
                Init_addrof _interact_damage (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 64) :: Init_space 4 ::
                Init_addrof _interact_pole (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 1) :: Init_space 4 ::
                Init_addrof _interact_hoot (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 512) :: Init_space 4 ::
                Init_addrof _interact_breakable (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 128) :: Init_space 4 ::
                Init_addrof _interact_bounce_top (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 524288) :: Init_space 4 ::
                Init_addrof _interact_koopa_shell (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 256) :: Init_space 4 ::
                Init_addrof _interact_unknown_08 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 32) :: Init_space 4 ::
                Init_addrof _interact_cap (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 2) :: Init_space 4 ::
                Init_addrof _interact_grabbable (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 8388608) :: Init_space 4 ::
                Init_addrof _interact_text (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sForwardKnockbackActions := {|
  gvar_info := (tarray (tarray tuint 3) 3);
  gvar_init := (Init_int32 (Int.repr 132197) ::
                Init_int32 (Int.repr 132195) ::
                Init_int32 (Int.repr 132193) ::
                Init_int32 (Int.repr 16910513) ::
                Init_int32 (Int.repr 16910513) ::
                Init_int32 (Int.repr 16910514) ::
                Init_int32 (Int.repr 805446342) ::
                Init_int32 (Int.repr 805446342) ::
                Init_int32 (Int.repr 805446342) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sBackwardKnockbackActions := {|
  gvar_info := (tarray (tarray tuint 3) 3);
  gvar_init := (Init_int32 (Int.repr 132196) ::
                Init_int32 (Int.repr 132194) ::
                Init_int32 (Int.repr 132192) ::
                Init_int32 (Int.repr 16910512) ::
                Init_int32 (Int.repr 16910512) ::
                Init_int32 (Int.repr 16910515) ::
                Init_int32 (Int.repr 805446341) ::
                Init_int32 (Int.repr 805446341) ::
                Init_int32 (Int.repr 805446341) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDisplayingDoorText := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sJustTeleported := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sPSSSlideStarted := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_get_mario_cap_flag := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_capObject, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_script, (tptr tuint)) :: (_t'1, (tptr tvoid)) ::
               (_t'2, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Efield
          (Ederef (Etempvar _capObject (tptr (Tstruct _Object noattr)))
            (Tstruct _Object noattr)) _behavior (tptr tuint)))
      (Scall (Some _t'1)
        (Evar _virtual_to_segmented (Tfunction (tuint :: (tptr tvoid) :: nil)
                                      (tptr tvoid) cc_default))
        ((Econst_int (Int.repr 19) tint) :: (Etempvar _t'2 (tptr tuint)) ::
         nil)))
    (Sset _script (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Sifthenelse (Ebinop Oeq (Etempvar _script (tptr tuint))
                   (Evar _bhvNormalCap (tarray tuint 0)) tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      (Sifthenelse (Ebinop Oeq (Etempvar _script (tptr tuint))
                     (Evar _bhvMetalCap (tarray tuint 0)) tint)
        (Sreturn (Some (Econst_int (Int.repr 4) tint)))
        (Sifthenelse (Ebinop Oeq (Etempvar _script (tptr tuint))
                       (Evar _bhvWingCap (tarray tuint 0)) tint)
          (Sreturn (Some (Econst_int (Int.repr 8) tint)))
          (Sifthenelse (Ebinop Oeq (Etempvar _script (tptr tuint))
                         (Evar _bhvVanishCap (tarray tuint 0)) tint)
            (Sreturn (Some (Econst_int (Int.repr 2) tint)))
            Sskip))))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_object_facing_mario := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_o, (tptr (Tstruct _Object noattr))) ::
                (_angleRange, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_dx, tfloat) :: (_dz, tfloat) :: (_angleToMario, tshort) ::
               (_dAngle, tshort) :: (_t'2, tint) :: (_t'1, tshort) ::
               (_t'7, tfloat) :: (_t'6, tfloat) :: (_t'5, tfloat) ::
               (_t'4, tfloat) :: (_t'3, tint) :: nil);
  fn_body :=
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
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asF32 (tarray tfloat 80))
            (Ebinop Oadd (Econst_int (Int.repr 6) tint)
              (Econst_int (Int.repr 0) tint) tint) (tptr tfloat)) tfloat))
      (Sset _dx
        (Ebinop Osub (Etempvar _t'6 tfloat) (Etempvar _t'7 tfloat) tfloat))))
  (Ssequence
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
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asF32 (tarray tfloat 80))
              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                (Econst_int (Int.repr 2) tint) tint) (tptr tfloat)) tfloat))
        (Sset _dz
          (Ebinop Osub (Etempvar _t'4 tfloat) (Etempvar _t'5 tfloat) tfloat))))
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil) tshort
                          cc_default))
          ((Etempvar _dz tfloat) :: (Etempvar _dx tfloat) :: nil))
        (Sset _angleToMario (Ecast (Etempvar _t'1 tshort) tshort)))
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asS32 (tarray tint 80))
                (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                  (Econst_int (Int.repr 1) tint) tint) (tptr tint)) tint))
          (Sset _dAngle
            (Ecast
              (Ebinop Osub (Etempvar _angleToMario tshort)
                (Etempvar _t'3 tint) tint) tshort)))
        (Ssequence
          (Ssequence
            (Sifthenelse (Ebinop Ole
                           (Eunop Oneg (Etempvar _angleRange tshort) tint)
                           (Etempvar _dAngle tshort) tint)
              (Sset _t'2
                (Ecast
                  (Ebinop Ole (Etempvar _dAngle tshort)
                    (Etempvar _angleRange tshort) tint) tbool))
              (Sset _t'2 (Econst_int (Int.repr 0) tint)))
            (Sifthenelse (Etempvar _t'2 tint)
              (Sreturn (Some (Econst_int (Int.repr 1) tint)))
              Sskip))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_mario_obj_angle_to_object := {|
  fn_return := tshort;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_dx, tfloat) :: (_dz, tfloat) :: (_t'1, tshort) ::
               (_t'5, tfloat) :: (_t'4, tfloat) :: (_t'3, tfloat) ::
               (_t'2, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
            _asF32 (tarray tfloat 80))
          (Ebinop Oadd (Econst_int (Int.repr 6) tint)
            (Econst_int (Int.repr 0) tint) tint) (tptr tfloat)) tfloat))
    (Ssequence
      (Sset _t'5
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
            (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
      (Sset _dx
        (Ebinop Osub (Etempvar _t'4 tfloat) (Etempvar _t'5 tfloat) tfloat))))
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asF32 (tarray tfloat 80))
            (Ebinop Oadd (Econst_int (Int.repr 6) tint)
              (Econst_int (Int.repr 2) tint) tint) (tptr tfloat)) tfloat))
      (Ssequence
        (Sset _t'3
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
        (Sset _dz
          (Ebinop Osub (Etempvar _t'2 tfloat) (Etempvar _t'3 tfloat) tfloat))))
    (Ssequence
      (Scall (Some _t'1)
        (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil) tshort cc_default))
        ((Etempvar _dz tfloat) :: (Etempvar _dx tfloat) :: nil))
      (Sreturn (Some (Etempvar _t'1 tshort))))))
|}.

Definition f_determine_interaction := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_interaction, tuint) :: (_action, tuint) ::
               (_dYawToObject, tshort) :: (_t'12, tint) :: (_t'11, tint) ::
               (_t'10, tint) :: (_t'9, tint) :: (_t'8, tint) ::
               (_t'7, tint) :: (_t'6, tint) :: (_t'5, tint) ::
               (_t'4, tint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tshort) :: (_t'26, tshort) :: (_t'25, tuint) ::
               (_t'24, tuint) :: (_t'23, tuint) :: (_t'22, tfloat) ::
               (_t'21, tushort) :: (_t'20, tfloat) :: (_t'19, tfloat) ::
               (_t'18, tfloat) :: (_t'17, tfloat) :: (_t'16, tfloat) ::
               (_t'15, tfloat) :: (_t'14, tfloat) :: (_t'13, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _interaction (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sset _action
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _action tuint))
    (Ssequence
      (Sifthenelse (Ebinop Oand (Etempvar _action tuint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 23) tint) tint) tuint)
        (Ssequence
          (Ssequence
            (Sifthenelse (Ebinop Oeq (Etempvar _action tuint)
                           (Econst_int (Int.repr 8389504) tint) tint)
              (Sset _t'10 (Econst_int (Int.repr 1) tint))
              (Sset _t'10
                (Ecast
                  (Ebinop Oeq (Etempvar _action tuint)
                    (Econst_int (Int.repr 8389719) tint) tint) tbool)))
            (Sifthenelse (Etempvar _t'10 tint)
              (Sset _t'11 (Econst_int (Int.repr 1) tint))
              (Sset _t'11
                (Ecast
                  (Ebinop Oeq (Etempvar _action tuint)
                    (Econst_int (Int.repr 25168044) tint) tint) tbool))))
          (Sifthenelse (Etempvar _t'11 tint)
            (Ssequence
              (Ssequence
                (Scall (Some _t'1)
                  (Evar _mario_obj_angle_to_object (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      (tptr (Tstruct _Object noattr)) ::
                                                      nil) tshort cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Etempvar _o (tptr (Tstruct _Object noattr))) :: nil))
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
                  (Sset _dYawToObject
                    (Ecast
                      (Ebinop Osub (Etempvar _t'1 tshort)
                        (Etempvar _t'26 tshort) tint) tshort))))
              (Ssequence
                (Ssequence
                  (Sset _t'25
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _flags tuint))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'25 tuint)
                                 (Econst_int (Int.repr 1048576) tint) tuint)
                    (Ssequence
                      (Sifthenelse (Ebinop Ole
                                     (Eunop Oneg
                                       (Econst_int (Int.repr 10922) tint)
                                       tint) (Etempvar _dYawToObject tshort)
                                     tint)
                        (Sset _t'2
                          (Ecast
                            (Ebinop Ole (Etempvar _dYawToObject tshort)
                              (Econst_int (Int.repr 10922) tint) tint) tbool))
                        (Sset _t'2 (Econst_int (Int.repr 0) tint)))
                      (Sifthenelse (Etempvar _t'2 tint)
                        (Sset _interaction
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 1) tint) tint))
                        Sskip))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sset _t'24
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _flags tuint))
                    (Sifthenelse (Ebinop Oand (Etempvar _t'24 tuint)
                                   (Econst_int (Int.repr 2097152) tint)
                                   tuint)
                      (Ssequence
                        (Sifthenelse (Ebinop Ole
                                       (Eunop Oneg
                                         (Econst_int (Int.repr 10922) tint)
                                         tint)
                                       (Etempvar _dYawToObject tshort) tint)
                          (Sset _t'3
                            (Ecast
                              (Ebinop Ole (Etempvar _dYawToObject tshort)
                                (Econst_int (Int.repr 10922) tint) tint)
                              tbool))
                          (Sset _t'3 (Econst_int (Int.repr 0) tint)))
                        (Sifthenelse (Etempvar _t'3 tint)
                          (Sset _interaction
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 2) tint) tint))
                          Sskip))
                      Sskip))
                  (Ssequence
                    (Sset _t'23
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _flags tuint))
                    (Sifthenelse (Ebinop Oand (Etempvar _t'23 tuint)
                                   (Econst_int (Int.repr 4194304) tint)
                                   tuint)
                      (Ssequence
                        (Sifthenelse (Ebinop Ole
                                       (Eunop Oneg
                                         (Econst_int (Int.repr 16384) tint)
                                         tint)
                                       (Etempvar _dYawToObject tshort) tint)
                          (Sset _t'4
                            (Ecast
                              (Ebinop Ole (Etempvar _dYawToObject tshort)
                                (Econst_int (Int.repr 16384) tint) tint)
                              tbool))
                          (Sset _t'4 (Econst_int (Int.repr 0) tint)))
                        (Sifthenelse (Etempvar _t'4 tint)
                          (Sset _interaction
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 3) tint) tint))
                          Sskip))
                      Sskip)))))
            (Ssequence
              (Sifthenelse (Ebinop Oeq (Etempvar _action tuint)
                             (Econst_int (Int.repr 8390825) tint) tint)
                (Sset _t'9 (Econst_int (Int.repr 1) tint))
                (Sset _t'9
                  (Ecast
                    (Ebinop Oeq (Etempvar _action tuint)
                      (Econst_int (Int.repr 276826276) tint) tint) tbool)))
              (Sifthenelse (Etempvar _t'9 tint)
                (Ssequence
                  (Sset _t'22
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _vel
                          (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tfloat)) tfloat))
                  (Sifthenelse (Ebinop Olt (Etempvar _t'22 tfloat)
                                 (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                 tint)
                    (Sset _interaction
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 0) tint) tint))
                    Sskip))
                (Ssequence
                  (Sifthenelse (Ebinop Oeq (Etempvar _action tuint)
                                 (Econst_int (Int.repr 8389180) tint) tint)
                    (Sset _t'8 (Econst_int (Int.repr 1) tint))
                    (Sset _t'8
                      (Ecast
                        (Ebinop Oeq (Etempvar _action tuint)
                          (Econst_int (Int.repr 411042360) tint) tint) tbool)))
                  (Sifthenelse (Etempvar _t'8 tint)
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
                              (Econst_int (Int.repr 1) tint) (tptr tfloat))
                            tfloat))
                        (Sifthenelse (Ebinop Olt (Etempvar _t'20 tfloat)
                                       (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                       tint)
                          (Ssequence
                            (Sset _t'21
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _actionState
                                tushort))
                            (Sset _t'5
                              (Ecast
                                (Ebinop Oeq (Etempvar _t'21 tushort)
                                  (Econst_int (Int.repr 0) tint) tint) tbool)))
                          (Sset _t'5 (Econst_int (Int.repr 0) tint))))
                      (Sifthenelse (Etempvar _t'5 tint)
                        (Sset _interaction
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 0) tint) tint))
                        Sskip))
                    (Ssequence
                      (Sifthenelse (Ebinop Oeq (Etempvar _action tuint)
                                     (Econst_int (Int.repr 25168042) tint)
                                     tint)
                        (Sset _t'7 (Econst_int (Int.repr 1) tint))
                        (Sset _t'7
                          (Ecast
                            (Ebinop Oeq (Etempvar _action tuint)
                              (Econst_int (Int.repr 8389722) tint) tint)
                            tbool)))
                      (Sifthenelse (Etempvar _t'7 tint)
                        (Sset _interaction
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 4) tint) tint))
                        (Sifthenelse (Ebinop Oand (Etempvar _action tuint)
                                       (Ebinop Oshl
                                         (Econst_int (Int.repr 1) tint)
                                         (Econst_int (Int.repr 16) tint)
                                         tint) tuint)
                          (Sset _interaction
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 5) tint) tint))
                          (Ssequence
                            (Ssequence
                              (Sset _t'18
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _forwardVel
                                  tfloat))
                              (Sifthenelse (Ebinop Ole
                                             (Etempvar _t'18 tfloat)
                                             (Eunop Oneg
                                               (Econst_single (Float32.of_bits (Int.repr 1104150528)) tfloat)
                                               tfloat) tint)
                                (Sset _t'6 (Econst_int (Int.repr 1) tint))
                                (Ssequence
                                  (Sset _t'19
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _forwardVel tfloat))
                                  (Sset _t'6
                                    (Ecast
                                      (Ebinop Ole
                                        (Econst_single (Float32.of_bits (Int.repr 1104150528)) tfloat)
                                        (Etempvar _t'19 tfloat) tint) tbool)))))
                            (Sifthenelse (Etempvar _t'6 tint)
                              (Sset _interaction
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 5) tint) tint))
                              Sskip)))))))))))
        Sskip)
      (Ssequence
        (Ssequence
          (Sifthenelse (Ebinop Oeq (Etempvar _interaction tuint)
                         (Econst_int (Int.repr 0) tint) tint)
            (Sset _t'12
              (Ecast
                (Ebinop Oand (Etempvar _action tuint)
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 11) tint) tint) tuint) tbool))
            (Sset _t'12 (Econst_int (Int.repr 0) tint)))
          (Sifthenelse (Etempvar _t'12 tint)
            (Ssequence
              (Sset _t'13
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                    (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
              (Sifthenelse (Ebinop Olt (Etempvar _t'13 tfloat)
                             (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                             tint)
                (Ssequence
                  (Sset _t'16
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _pos
                          (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tfloat)) tfloat))
                  (Ssequence
                    (Sset _t'17
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _o (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __665 noattr)) _asF32
                            (tarray tfloat 80))
                          (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                            (Econst_int (Int.repr 1) tint) tint)
                          (tptr tfloat)) tfloat))
                    (Sifthenelse (Ebinop Ogt (Etempvar _t'16 tfloat)
                                   (Etempvar _t'17 tfloat) tint)
                      (Sset _interaction
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 6) tint) tint))
                      Sskip)))
                (Ssequence
                  (Sset _t'14
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _pos
                          (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tfloat)) tfloat))
                  (Ssequence
                    (Sset _t'15
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _o (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __665 noattr)) _asF32
                            (tarray tfloat 80))
                          (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                            (Econst_int (Int.repr 1) tint) tint)
                          (tptr tfloat)) tfloat))
                    (Sifthenelse (Ebinop Olt (Etempvar _t'14 tfloat)
                                   (Etempvar _t'15 tfloat) tint)
                      (Sset _interaction
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 7) tint) tint))
                      Sskip)))))
            Sskip))
        (Sreturn (Some (Etempvar _interaction tuint)))))))
|}.

Definition f_attack_object := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_o, (tptr (Tstruct _Object noattr))) ::
                (_interaction, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_attackType, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _attackType (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sswitch (Etempvar _interaction tint)
      (LScons (Some 1)
        (Ssequence (Sset _attackType (Econst_int (Int.repr 4) tint)) Sbreak)
        (LScons (Some 2)
          (Ssequence
            (Sset _attackType (Econst_int (Int.repr 1) tint))
            Sbreak)
          (LScons (Some 4)
            Sskip
            (LScons (Some 8)
              (Ssequence
                (Sset _attackType (Econst_int (Int.repr 2) tint))
                Sbreak)
              (LScons (Some 16)
                Sskip
                (LScons (Some 32)
                  (Ssequence
                    (Sset _attackType (Econst_int (Int.repr 5) tint))
                    Sbreak)
                  (LScons (Some 64)
                    (Ssequence
                      (Sset _attackType (Econst_int (Int.repr 3) tint))
                      Sbreak)
                    (LScons (Some 128)
                      (Ssequence
                        (Sset _attackType (Econst_int (Int.repr 6) tint))
                        Sbreak)
                      LSnil)))))))))
    (Ssequence
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
            (tptr tint)) tint)
        (Ebinop Oadd (Etempvar _attackType tuint)
          (Ebinop Oor
            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
              (Econst_int (Int.repr 15) tint) tint)
            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
              (Econst_int (Int.repr 14) tint) tint) tint) tuint))
      (Sreturn (Some (Etempvar _attackType tuint))))))
|}.

Definition f_mario_stop_riding_object := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _riddenObj
      (tptr (Tstruct _Object noattr))))
  (Sifthenelse (Ebinop One (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _riddenObj
            (tptr (Tstruct _Object noattr))))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
              (tptr tint)) tint)
          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
            (Econst_int (Int.repr 22) tint) tint)))
      (Ssequence
        (Scall None (Evar _stop_shell_music (Tfunction nil tvoid cc_default))
          nil)
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _riddenObj
            (tptr (Tstruct _Object noattr)))
          (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))))
    Sskip))
|}.

Definition f_mario_grab_used_object := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _heldObj
      (tptr (Tstruct _Object noattr))))
  (Sifthenelse (Ebinop Oeq (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _usedObj
            (tptr (Tstruct _Object noattr))))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _heldObj
            (tptr (Tstruct _Object noattr)))
          (Etempvar _t'3 (tptr (Tstruct _Object noattr)))))
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _heldObj
            (tptr (Tstruct _Object noattr))))
        (Scall None
          (Evar _obj_set_held_state (Tfunction
                                      ((tptr (Tstruct _Object noattr)) ::
                                       (tptr tuint) :: nil) tvoid cc_default))
          ((Etempvar _t'2 (tptr (Tstruct _Object noattr))) ::
           (Evar _bhvCarrySomething3 (tarray tuint 0)) :: nil))))
    Sskip))
|}.

Definition f_mario_drop_held_object := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: (_t'15, (tptr tuint)) ::
               (_t'14, (tptr (Tstruct _Object noattr))) ::
               (_t'13, (tptr (Tstruct _Object noattr))) :: (_t'12, tfloat) ::
               (_t'11, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tfloat) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tfloat) ::
               (_t'6, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: (_t'4, tshort) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'2
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _heldObj
      (tptr (Tstruct _Object noattr))))
  (Sifthenelse (Ebinop One (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                        (tptr tvoid) cc_default))
          ((Evar _bhvKoopaShellUnderwater (tarray tuint 0)) :: nil))
        (Ssequence
          (Sset _t'14
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _heldObj
              (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'15
              (Efield
                (Ederef (Etempvar _t'14 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _behavior (tptr tuint)))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'15 (tptr tuint))
                           (Etempvar _t'1 (tptr tvoid)) tint)
              (Scall None
                (Evar _stop_shell_music (Tfunction nil tvoid cc_default))
                nil)
              Sskip))))
      (Ssequence
        (Ssequence
          (Sset _t'13
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _heldObj
              (tptr (Tstruct _Object noattr))))
          (Scall None
            (Evar _obj_set_held_state (Tfunction
                                        ((tptr (Tstruct _Object noattr)) ::
                                         (tptr tuint) :: nil) tvoid
                                        cc_default))
            ((Etempvar _t'13 (tptr (Tstruct _Object noattr))) ::
             (Evar _bhvCarrySomething4 (tarray tuint 0)) :: nil)))
        (Ssequence
          (Ssequence
            (Sset _t'10
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _heldObj
                (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'11
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioBodyState
                  (tptr (Tstruct _MarioBodyState noattr))))
              (Ssequence
                (Sset _t'12
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _t'11 (tptr (Tstruct _MarioBodyState noattr)))
                          (Tstruct _MarioBodyState noattr))
                        _heldObjLastPosition (tarray tfloat 3))
                      (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                      (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                        (Econst_int (Int.repr 0) tint) tint) (tptr tfloat))
                    tfloat) (Etempvar _t'12 tfloat)))))
          (Ssequence
            (Ssequence
              (Sset _t'8
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _heldObj
                  (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'9
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
                        (Efield
                          (Ederef
                            (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                      (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                        (Econst_int (Int.repr 1) tint) tint) (tptr tfloat))
                    tfloat) (Etempvar _t'9 tfloat))))
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _heldObj
                    (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'6
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _marioBodyState
                      (tptr (Tstruct _MarioBodyState noattr))))
                  (Ssequence
                    (Sset _t'7
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _t'6 (tptr (Tstruct _MarioBodyState noattr)))
                              (Tstruct _MarioBodyState noattr))
                            _heldObjLastPosition (tarray tfloat 3))
                          (Econst_int (Int.repr 2) tint) (tptr tfloat))
                        tfloat))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __665 noattr)) _asF32
                            (tarray tfloat 80))
                          (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                            (Econst_int (Int.repr 2) tint) tint)
                          (tptr tfloat)) tfloat) (Etempvar _t'7 tfloat)))))
              (Ssequence
                (Ssequence
                  (Sset _t'3
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _heldObj
                      (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sset _t'4
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
                            (Efield
                              (Ederef
                                (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __665 noattr)) _asS32 (tarray tint 80))
                          (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                            (Econst_int (Int.repr 1) tint) tint) (tptr tint))
                        tint) (Etempvar _t'4 tshort))))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _heldObj
                    (tptr (Tstruct _Object noattr)))
                  (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))))))))
    Sskip))
|}.

Definition f_mario_throw_held_object := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: (_t'20, (tptr tuint)) ::
               (_t'19, (tptr (Tstruct _Object noattr))) ::
               (_t'18, (tptr (Tstruct _Object noattr))) :: (_t'17, tfloat) ::
               (_t'16, tshort) :: (_t'15, tfloat) ::
               (_t'14, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'13, (tptr (Tstruct _Object noattr))) :: (_t'12, tfloat) ::
               (_t'11, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tfloat) ::
               (_t'8, tshort) :: (_t'7, tfloat) ::
               (_t'6, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: (_t'4, tshort) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'2
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _heldObj
      (tptr (Tstruct _Object noattr))))
  (Sifthenelse (Ebinop One (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                        (tptr tvoid) cc_default))
          ((Evar _bhvKoopaShellUnderwater (tarray tuint 0)) :: nil))
        (Ssequence
          (Sset _t'19
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _heldObj
              (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'20
              (Efield
                (Ederef (Etempvar _t'19 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _behavior (tptr tuint)))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'20 (tptr tuint))
                           (Etempvar _t'1 (tptr tvoid)) tint)
              (Scall None
                (Evar _stop_shell_music (Tfunction nil tvoid cc_default))
                nil)
              Sskip))))
      (Ssequence
        (Ssequence
          (Sset _t'18
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _heldObj
              (tptr (Tstruct _Object noattr))))
          (Scall None
            (Evar _obj_set_held_state (Tfunction
                                        ((tptr (Tstruct _Object noattr)) ::
                                         (tptr tuint) :: nil) tvoid
                                        cc_default))
            ((Etempvar _t'18 (tptr (Tstruct _Object noattr))) ::
             (Evar _bhvCarrySomething5 (tarray tuint 0)) :: nil)))
        (Ssequence
          (Ssequence
            (Sset _t'13
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _heldObj
                (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'14
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioBodyState
                  (tptr (Tstruct _MarioBodyState noattr))))
              (Ssequence
                (Sset _t'15
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _t'14 (tptr (Tstruct _MarioBodyState noattr)))
                          (Tstruct _MarioBodyState noattr))
                        _heldObjLastPosition (tarray tfloat 3))
                      (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
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
                  (Ssequence
                    (Sset _t'17
                      (Ederef
                        (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                          (Ebinop Oshr
                            (Ecast (Etempvar _t'16 tshort) tushort)
                            (Econst_int (Int.repr 4) tint) tint)
                          (tptr tfloat)) tfloat))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'13 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __665 noattr)) _asF32
                            (tarray tfloat 80))
                          (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                            (Econst_int (Int.repr 0) tint) tint)
                          (tptr tfloat)) tfloat)
                      (Ebinop Oadd (Etempvar _t'15 tfloat)
                        (Ebinop Omul
                          (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                          (Etempvar _t'17 tfloat) tfloat) tfloat)))))))
          (Ssequence
            (Ssequence
              (Sset _t'10
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _heldObj
                  (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'11
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _marioBodyState
                    (tptr (Tstruct _MarioBodyState noattr))))
                (Ssequence
                  (Sset _t'12
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _t'11 (tptr (Tstruct _MarioBodyState noattr)))
                            (Tstruct _MarioBodyState noattr))
                          _heldObjLastPosition (tarray tfloat 3))
                        (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                        (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                          (Econst_int (Int.repr 1) tint) tint) (tptr tfloat))
                      tfloat) (Etempvar _t'12 tfloat)))))
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _heldObj
                    (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'6
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _marioBodyState
                      (tptr (Tstruct _MarioBodyState noattr))))
                  (Ssequence
                    (Sset _t'7
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _t'6 (tptr (Tstruct _MarioBodyState noattr)))
                              (Tstruct _MarioBodyState noattr))
                            _heldObjLastPosition (tarray tfloat 3))
                          (Econst_int (Int.repr 2) tint) (tptr tfloat))
                        tfloat))
                    (Ssequence
                      (Sset _t'8
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
                        (Sset _t'9
                          (Ederef
                            (Ebinop Oadd
                              (Ebinop Oadd
                                (Evar _gSineTable (tarray tfloat 0))
                                (Econst_int (Int.repr 1024) tint)
                                (tptr tfloat))
                              (Ebinop Oshr
                                (Ecast (Etempvar _t'8 tshort) tushort)
                                (Econst_int (Int.repr 4) tint) tint)
                              (tptr tfloat)) tfloat))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __665 noattr)) _asF32
                                (tarray tfloat 80))
                              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                                (Econst_int (Int.repr 2) tint) tint)
                              (tptr tfloat)) tfloat)
                          (Ebinop Oadd (Etempvar _t'7 tfloat)
                            (Ebinop Omul
                              (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                              (Etempvar _t'9 tfloat) tfloat) tfloat)))))))
              (Ssequence
                (Ssequence
                  (Sset _t'3
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _heldObj
                      (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sset _t'4
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
                            (Efield
                              (Ederef
                                (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __665 noattr)) _asS32 (tarray tint 80))
                          (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                            (Econst_int (Int.repr 1) tint) tint) (tptr tint))
                        tint) (Etempvar _t'4 tshort))))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _heldObj
                    (tptr (Tstruct _Object noattr)))
                  (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))))))))
    Sskip))
|}.

Definition f_mario_stop_riding_and_holding := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, (tptr (Tstruct _Object noattr))) :: (_t'3, tuint) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: (_t'1, tuint) ::
               nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _mario_drop_held_object (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
  (Ssequence
    (Scall None
      (Evar _mario_stop_riding_object (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Ssequence
      (Sset _t'1
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _action tuint))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tuint)
                     (Econst_int (Int.repr 1192) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _usedObj
                (tptr (Tstruct _Object noattr))))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __665 noattr)) _asS32 (tarray tint 80))
                  (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
              (Econst_int (Int.repr 0) tint)))
          (Ssequence
            (Sset _t'2
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _usedObj
                (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'3 (Evar _gGlobalTimer tuint))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __665 noattr)) _asS32 (tarray tint 80))
                    (Econst_int (Int.repr 34) tint) (tptr tint)) tint)
                (Etempvar _t'3 tuint)))))
        Sskip))))
|}.

Definition f_does_mario_have_normal_cap_on_head := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _flags tuint))
  (Sreturn (Some (Ebinop Oeq
                   (Ebinop Oand (Etempvar _t'1 tuint)
                     (Ebinop Oor
                       (Ebinop Oor (Econst_int (Int.repr 1) tint)
                         (Ebinop Oor
                           (Ebinop Oor (Econst_int (Int.repr 2) tint)
                             (Econst_int (Int.repr 4) tint) tint)
                           (Econst_int (Int.repr 8) tint) tint) tint)
                       (Econst_int (Int.repr 16) tint) tint) tuint)
                   (Ebinop Oor (Econst_int (Int.repr 1) tint)
                     (Econst_int (Int.repr 16) tint) tint) tint))))
|}.

Definition f_mario_blow_off_cap := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_capSpeed, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_capObject, (tptr (Tstruct _Object noattr))) ::
               (_t'3, tuint) :: (_t'2, tfloat) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: (_t'13, tfloat) ::
               (_t'12, tfloat) :: (_t'11, tfloat) :: (_t'10, tuint) ::
               (_t'9, (tptr (Tstruct _Object noattr))) :: (_t'8, tuint) ::
               (_t'7, tfloat) :: (_t'6, tshort) :: (_t'5, tint) ::
               (_t'4, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Scall (Some _t'3)
    (Evar _does_mario_have_normal_cap_on_head (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tuint cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
  (Sifthenelse (Etempvar _t'3 tuint)
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
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
          (Ssequence
            (Sset _t'13
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
            (Scall None
              (Evar _save_file_set_cap_pos (Tfunction
                                             (tshort :: tshort :: tshort ::
                                              nil) tvoid cc_default))
              ((Etempvar _t'11 tfloat) :: (Etempvar _t'12 tfloat) ::
               (Etempvar _t'13 tfloat) :: nil)))))
      (Ssequence
        (Ssequence
          (Sset _t'10
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _flags tuint))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _flags tuint)
            (Ebinop Oand (Etempvar _t'10 tuint)
              (Eunop Onotint
                (Ebinop Oor (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 16) tint) tint) tint) tuint)))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'9
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioObj
                  (tptr (Tstruct _Object noattr))))
              (Scall (Some _t'1)
                (Evar _spawn_object (Tfunction
                                      ((tptr (Tstruct _Object noattr)) ::
                                       tint :: (tptr tuint) :: nil)
                                      (tptr (Tstruct _Object noattr))
                                      cc_default))
                ((Etempvar _t'9 (tptr (Tstruct _Object noattr))) ::
                 (Econst_int (Int.repr 136) tint) ::
                 (Evar _bhvNormalCap (tarray tuint 0)) :: nil)))
            (Sset _capObject (Etempvar _t'1 (tptr (Tstruct _Object noattr)))))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'8
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _action tuint))
                (Sifthenelse (Ebinop Oand (Etempvar _t'8 tuint)
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 15) tint) tint) tuint)
                  (Sset _t'2
                    (Ecast
                      (Econst_single (Float32.of_bits (Int.repr 1123024896)) tfloat)
                      tfloat))
                  (Sset _t'2
                    (Ecast
                      (Econst_single (Float32.of_bits (Int.repr 1127481344)) tfloat)
                      tfloat))))
              (Ssequence
                (Sset _t'7
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _capObject (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                      (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                        (Econst_int (Int.repr 1) tint) tint) (tptr tfloat))
                    tfloat))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _capObject (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                      (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                        (Econst_int (Int.repr 1) tint) tint) (tptr tfloat))
                    tfloat)
                  (Ebinop Oadd (Etempvar _t'7 tfloat) (Etempvar _t'2 tfloat)
                    tfloat))))
            (Ssequence
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _capObject (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                    (Econst_int (Int.repr 12) tint) (tptr tfloat)) tfloat)
                (Etempvar _capSpeed tfloat))
              (Ssequence
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
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _capObject (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __665 noattr)) _asS32 (tarray tint 80))
                        (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                          (Econst_int (Int.repr 1) tint) tint) (tptr tint))
                      tint)
                    (Ecast
                      (Ebinop Oadd (Etempvar _t'6 tshort)
                        (Econst_int (Int.repr 1024) tint) tint) tshort)))
                (Ssequence
                  (Sset _t'4
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Sifthenelse (Ebinop Olt (Etempvar _t'4 tfloat)
                                 (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                 tint)
                    (Ssequence
                      (Sset _t'5
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _capObject (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _rawData
                                (Tunion __665 noattr)) _asS32
                              (tarray tint 80))
                            (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                              (Econst_int (Int.repr 1) tint) tint)
                            (tptr tint)) tint))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _capObject (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _rawData
                                (Tunion __665 noattr)) _asS32
                              (tarray tint 80))
                            (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                              (Econst_int (Int.repr 1) tint) tint)
                            (tptr tint)) tint)
                        (Ecast
                          (Ebinop Oadd (Etempvar _t'5 tint)
                            (Econst_int (Int.repr 32768) tint) tint) tshort)))
                    Sskip))))))))
    Sskip))
|}.

Definition f_mario_lose_cap_to_enemy := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_arg, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_wasWearingCap, tuint) :: (_t'2, tuint) :: (_t'1, tint) ::
               (_t'6, (tptr (Tstruct _MarioState noattr))) ::
               (_t'5, tuint) ::
               (_t'4, (tptr (Tstruct _MarioState noattr))) ::
               (_t'3, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _wasWearingCap (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'6 (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
        (Scall (Some _t'2)
          (Evar _does_mario_have_normal_cap_on_head (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       nil) tuint cc_default))
          ((Etempvar _t'6 (tptr (Tstruct _MarioState noattr))) :: nil)))
      (Sifthenelse (Etempvar _t'2 tuint)
        (Ssequence
          (Ssequence
            (Sifthenelse (Ebinop Oeq (Etempvar _arg tuint)
                           (Econst_int (Int.repr 1) tint) tint)
              (Sset _t'1
                (Ecast
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 17) tint) tint) tint))
              (Sset _t'1
                (Ecast
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 18) tint) tint) tint)))
            (Scall None
              (Evar _save_file_set_flags (Tfunction (tuint :: nil) tvoid
                                           cc_default))
              ((Etempvar _t'1 tint) :: nil)))
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
                        (Tstruct _MarioState noattr)) _flags tuint))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _t'3 (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _flags tuint)
                    (Ebinop Oand (Etempvar _t'5 tuint)
                      (Eunop Onotint
                        (Ebinop Oor (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 16) tint) tint) tint) tuint)))))
            (Sset _wasWearingCap (Econst_int (Int.repr 1) tint))))
        Sskip))
    (Sreturn (Some (Etempvar _wasWearingCap tuint)))))
|}.

Definition f_mario_retrieve_cap := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'7, (tptr (Tstruct _MarioState noattr))) ::
               (_t'6, tuint) ::
               (_t'5, (tptr (Tstruct _MarioState noattr))) ::
               (_t'4, (tptr (Tstruct _MarioState noattr))) ::
               (_t'3, tuint) ::
               (_t'2, (tptr (Tstruct _MarioState noattr))) ::
               (_t'1, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7 (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
    (Scall None
      (Evar _mario_drop_held_object (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       nil) tvoid cc_default))
      ((Etempvar _t'7 (tptr (Tstruct _MarioState noattr))) :: nil)))
  (Ssequence
    (Scall None
      (Evar _save_file_clear_flags (Tfunction (tuint :: nil) tvoid
                                     cc_default))
      ((Ebinop Oor
         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
           (Econst_int (Int.repr 17) tint) tint)
         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
           (Econst_int (Int.repr 18) tint) tint) tint) :: nil))
    (Ssequence
      (Ssequence
        (Sset _t'4 (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
        (Ssequence
          (Sset _t'5 (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
          (Ssequence
            (Sset _t'6
              (Efield
                (Ederef (Etempvar _t'5 (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _flags tuint))
            (Sassign
              (Efield
                (Ederef (Etempvar _t'4 (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _flags tuint)
              (Ebinop Oand (Etempvar _t'6 tuint)
                (Eunop Onotint (Econst_int (Int.repr 16) tint) tint) tuint)))))
      (Ssequence
        (Sset _t'1 (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
        (Ssequence
          (Sset _t'2 (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
          (Ssequence
            (Sset _t'3
              (Efield
                (Ederef (Etempvar _t'2 (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _flags tuint))
            (Sassign
              (Efield
                (Ederef (Etempvar _t'1 (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _flags tuint)
              (Ebinop Oor (Etempvar _t'3 tuint)
                (Ebinop Oor (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 32) tint) tint) tuint))))))))
|}.

Definition f_able_to_grab_object := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_action, tuint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'4, tuint) :: (_t'3, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _action
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _action tuint))
  (Ssequence
    (Ssequence
      (Sifthenelse (Ebinop Oeq (Etempvar _action tuint)
                     (Econst_int (Int.repr 8914006) tint) tint)
        (Sset _t'2 (Econst_int (Int.repr 1) tint))
        (Sset _t'2
          (Ecast
            (Ebinop Oeq (Etempvar _action tuint)
              (Econst_int (Int.repr 25692298) tint) tint) tbool)))
      (Sifthenelse (Etempvar _t'2 tint)
        (Ssequence
          (Sset _t'4
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asU32 (tarray tuint 80))
                (Econst_int (Int.repr 66) tint) (tptr tuint)) tuint))
          (Sifthenelse (Eunop Onotbool
                         (Ebinop Oand (Etempvar _t'4 tuint)
                           (Econst_int (Int.repr 4) tint) tuint) tint)
            (Sreturn (Some (Econst_int (Int.repr 1) tint)))
            Sskip))
        (Ssequence
          (Sifthenelse (Ebinop Oeq (Etempvar _action tuint)
                         (Econst_int (Int.repr 8389504) tint) tint)
            (Sset _t'1 (Econst_int (Int.repr 1) tint))
            (Sset _t'1
              (Ecast
                (Ebinop Oeq (Etempvar _action tuint)
                  (Econst_int (Int.repr 8389719) tint) tint) tbool)))
          (Sifthenelse (Etempvar _t'1 tint)
            (Ssequence
              (Sset _t'3
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionArg tuint))
              (Sifthenelse (Ebinop Olt (Etempvar _t'3 tuint)
                             (Econst_int (Int.repr 2) tint) tint)
                (Sreturn (Some (Econst_int (Int.repr 1) tint)))
                Sskip))
            Sskip))))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_mario_get_collided_object := {|
  fn_return := (tptr (Tstruct _Object noattr));
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_object, (tptr (Tstruct _Object noattr))) ::
               (_t'4, tshort) :: (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: (_t'1, tuint) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _i (Econst_int (Int.repr 0) tint))
    (Sloop
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
                (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _numCollidedObjs tshort))
            (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                           (Etempvar _t'4 tshort) tint)
              Sskip
              Sbreak)))
        (Ssequence
          (Ssequence
            (Sset _t'2
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _marioObj
                (tptr (Tstruct _Object noattr))))
            (Sset _object
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _collidedObjs
                    (tarray (tptr (Tstruct _Object noattr)) 4))
                  (Etempvar _i tint) (tptr (tptr (Tstruct _Object noattr))))
                (tptr (Tstruct _Object noattr)))))
          (Ssequence
            (Sset _t'1
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _object (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __665 noattr)) _asU32 (tarray tuint 80))
                  (Econst_int (Int.repr 42) tint) (tptr tuint)) tuint))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tuint)
                           (Etempvar _interactType tuint) tint)
              (Sreturn (Some (Etempvar _object (tptr (Tstruct _Object noattr)))))
              Sskip))))
      (Sset _i
        (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint) tint))))
  (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))))
|}.

Definition f_mario_check_object_grab := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_result, tuint) :: (_script, (tptr tuint)) ::
               (_facingDYaw, tshort) :: (_facingDYaw__1, tshort) ::
               (_t'6, tint) :: (_t'5, tint) :: (_t'4, tshort) ::
               (_t'3, tint) :: (_t'2, tuint) :: (_t'1, (tptr tvoid)) ::
               (_t'20, (tptr tuint)) ::
               (_t'19, (tptr (Tstruct _Object noattr))) :: (_t'18, tint) ::
               (_t'17, (tptr (Tstruct _Object noattr))) :: (_t'16, tshort) ::
               (_t'15, tint) :: (_t'14, (tptr (Tstruct _Object noattr))) ::
               (_t'13, (tptr (Tstruct _Object noattr))) ::
               (_t'12, (tptr (Tstruct _Object noattr))) :: (_t'11, tshort) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tuint) ::
               (_t'8, tuint) :: (_t'7, tushort) :: nil);
  fn_body :=
(Ssequence
  (Sset _result (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Sset _t'7
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'7 tushort)
                     (Econst_int (Int.repr 2048) tint) tint)
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'19
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _interactObj
                  (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'20
                  (Efield
                    (Ederef (Etempvar _t'19 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _behavior (tptr tuint)))
                (Scall (Some _t'1)
                  (Evar _virtual_to_segmented (Tfunction
                                                (tuint :: (tptr tvoid) ::
                                                 nil) (tptr tvoid)
                                                cc_default))
                  ((Econst_int (Int.repr 19) tint) ::
                   (Etempvar _t'20 (tptr tuint)) :: nil))))
            (Sset _script (Etempvar _t'1 (tptr tvoid))))
          (Sifthenelse (Ebinop Oeq (Etempvar _script (tptr tuint))
                         (Evar _bhvBowser (tarray tuint 0)) tint)
            (Ssequence
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
                (Ssequence
                  (Sset _t'17
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _interactObj
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
                          (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                            (Econst_int (Int.repr 1) tint) tint) (tptr tint))
                        tint))
                    (Sset _facingDYaw
                      (Ecast
                        (Ebinop Osub (Etempvar _t'16 tshort)
                          (Etempvar _t'18 tint) tint) tshort)))))
              (Ssequence
                (Sifthenelse (Ebinop Oge (Etempvar _facingDYaw tshort)
                               (Eunop Oneg (Econst_int (Int.repr 21845) tint)
                                 tint) tint)
                  (Sset _t'3
                    (Ecast
                      (Ebinop Ole (Etempvar _facingDYaw tshort)
                        (Econst_int (Int.repr 21845) tint) tint) tbool))
                  (Sset _t'3 (Econst_int (Int.repr 0) tint)))
                (Sifthenelse (Etempvar _t'3 tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'14
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _interactObj
                          (tptr (Tstruct _Object noattr))))
                      (Ssequence
                        (Sset _t'15
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'14 (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __665 noattr)) _asS32
                                (tarray tint 80))
                              (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                                (Econst_int (Int.repr 1) tint) tint)
                              (tptr tint)) tint))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _faceAngle
                                (tarray tshort 3))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))
                            tshort) (Etempvar _t'15 tint))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'13
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _interactObj
                            (tptr (Tstruct _Object noattr))))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _usedObj
                            (tptr (Tstruct _Object noattr)))
                          (Etempvar _t'13 (tptr (Tstruct _Object noattr)))))
                      (Ssequence
                        (Scall (Some _t'2)
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 912) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))
                        (Sset _result (Etempvar _t'2 tuint)))))
                  Sskip)))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'12
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _interactObj
                      (tptr (Tstruct _Object noattr))))
                  (Scall (Some _t'4)
                    (Evar _mario_obj_angle_to_object (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        (tptr (Tstruct _Object noattr)) ::
                                                        nil) tshort
                                                       cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Etempvar _t'12 (tptr (Tstruct _Object noattr))) :: nil)))
                (Ssequence
                  (Sset _t'11
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _faceAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tshort)) tshort))
                  (Sset _facingDYaw__1
                    (Ecast
                      (Ebinop Osub (Etempvar _t'4 tshort)
                        (Etempvar _t'11 tshort) tint) tshort))))
              (Ssequence
                (Sifthenelse (Ebinop Oge (Etempvar _facingDYaw__1 tshort)
                               (Eunop Oneg (Econst_int (Int.repr 10922) tint)
                                 tint) tint)
                  (Sset _t'6
                    (Ecast
                      (Ebinop Ole (Etempvar _facingDYaw__1 tshort)
                        (Econst_int (Int.repr 10922) tint) tint) tbool))
                  (Sset _t'6 (Econst_int (Int.repr 0) tint)))
                (Sifthenelse (Etempvar _t'6 tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'10
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _interactObj
                          (tptr (Tstruct _Object noattr))))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _usedObj
                          (tptr (Tstruct _Object noattr)))
                        (Etempvar _t'10 (tptr (Tstruct _Object noattr)))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'8
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _action tuint))
                        (Sifthenelse (Eunop Onotbool
                                       (Ebinop Oand (Etempvar _t'8 tuint)
                                         (Ebinop Oshl
                                           (Econst_int (Int.repr 1) tint)
                                           (Econst_int (Int.repr 11) tint)
                                           tint) tuint) tint)
                          (Ssequence
                            (Ssequence
                              (Sset _t'9
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _action
                                  tuint))
                              (Sifthenelse (Ebinop Oand (Etempvar _t'9 tuint)
                                             (Ebinop Oshl
                                               (Econst_int (Int.repr 1) tint)
                                               (Econst_int (Int.repr 19) tint)
                                               tint) tuint)
                                (Sset _t'5
                                  (Ecast (Econst_int (Int.repr 901) tint)
                                    tint))
                                (Sset _t'5
                                  (Ecast (Econst_int (Int.repr 899) tint)
                                    tint))))
                            (Scall None
                              (Evar _set_mario_action (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         tuint :: tuint ::
                                                         nil) tuint
                                                        cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Etempvar _t'5 tint) ::
                               (Econst_int (Int.repr 0) tint) :: nil)))
                          Sskip))
                      (Sset _result (Econst_int (Int.repr 1) tint))))
                  Sskip)))))
        Sskip))
    (Sreturn (Some (Etempvar _result tuint)))))
|}.

Definition f_bully_knock_back_mario := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_mario, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := ((_marioData, (Tstruct _BullyCollisionData noattr)) ::
              (_bullyData, (Tstruct _BullyCollisionData noattr)) :: nil);
  fn_temps := ((_newMarioYaw, tshort) :: (_newBullyYaw, tshort) ::
               (_marioDYaw, tshort) :: (_bullyDYaw, tshort) ::
               (_bonkAction, tuint) ::
               (_bully, (tptr (Tstruct _Object noattr))) ::
               (_bullyToMarioRatio, tfloat) ::
               (_marioToBullyRatio, tfloat) :: (_t'5, tint) ::
               (_t'4, tfloat) :: (_t'3, tfloat) :: (_t'2, tshort) ::
               (_t'1, tshort) :: (_t'39, tfloat) :: (_t'38, tfloat) ::
               (_t'37, tshort) :: (_t'36, tfloat) :: (_t'35, tfloat) ::
               (_t'34, tfloat) :: (_t'33, tfloat) :: (_t'32, tint) ::
               (_t'31, tfloat) :: (_t'30, tfloat) :: (_t'29, tfloat) ::
               (_t'28, tfloat) :: (_t'27, tfloat) :: (_t'26, tfloat) ::
               (_t'25, tfloat) :: (_t'24, tfloat) :: (_t'23, tshort) ::
               (_t'22, tint) :: (_t'21, tfloat) :: (_t'20, tfloat) ::
               (_t'19, tfloat) :: (_t'18, tfloat) :: (_t'17, tfloat) ::
               (_t'16, tfloat) :: (_t'15, tfloat) :: (_t'14, tfloat) ::
               (_t'13, tfloat) :: (_t'12, tfloat) :: (_t'11, tfloat) ::
               (_t'10, tfloat) :: (_t'9, tshort) :: (_t'8, tfloat) ::
               (_t'7, tuint) :: (_t'6, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _bonkAction (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sset _bully
      (Efield
        (Ederef (Etempvar _mario (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _interactObj
        (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Ssequence
        (Sset _t'39
          (Efield
            (Ederef (Etempvar _bully (tptr (Tstruct _Object noattr)))
              (Tstruct _Object noattr)) _hitboxRadius tfloat))
        (Sset _bullyToMarioRatio
          (Ebinop Odiv
            (Ebinop Omul (Etempvar _t'39 tfloat)
              (Econst_int (Int.repr 3) tint) tfloat)
            (Econst_int (Int.repr 53) tint) tfloat)))
      (Ssequence
        (Ssequence
          (Sset _t'38
            (Efield
              (Ederef (Etempvar _bully (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _hitboxRadius tfloat))
          (Sset _marioToBullyRatio
            (Ebinop Odiv
              (Econst_single (Float32.of_bits (Int.repr 1112801280)) tfloat)
              (Etempvar _t'38 tfloat) tfloat)))
        (Ssequence
          (Ssequence
            (Sset _t'34
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef
                      (Etempvar _mario (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
            (Ssequence
              (Sset _t'35
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _mario (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                    (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
              (Ssequence
                (Sset _t'36
                  (Efield
                    (Ederef
                      (Etempvar _mario (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
                (Ssequence
                  (Sset _t'37
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _mario (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _faceAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tshort)) tshort))
                  (Scall None
                    (Evar _init_bully_collision_data (Tfunction
                                                       ((tptr (Tstruct _BullyCollisionData noattr)) ::
                                                        tfloat :: tfloat ::
                                                        tfloat :: tshort ::
                                                        tfloat :: tfloat ::
                                                        nil) tvoid
                                                       cc_default))
                    ((Eaddrof
                       (Evar _marioData (Tstruct _BullyCollisionData noattr))
                       (tptr (Tstruct _BullyCollisionData noattr))) ::
                     (Etempvar _t'34 tfloat) :: (Etempvar _t'35 tfloat) ::
                     (Etempvar _t'36 tfloat) :: (Etempvar _t'37 tshort) ::
                     (Etempvar _bullyToMarioRatio tfloat) ::
                     (Econst_single (Float32.of_bits (Int.repr 1112539136)) tfloat) ::
                     nil))))))
          (Ssequence
            (Ssequence
              (Sset _t'29
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _bully (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                    (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                      (Econst_int (Int.repr 0) tint) tint) (tptr tfloat))
                  tfloat))
              (Ssequence
                (Sset _t'30
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _bully (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                      (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                        (Econst_int (Int.repr 2) tint) tint) (tptr tfloat))
                    tfloat))
                (Ssequence
                  (Sset _t'31
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _bully (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                        (Econst_int (Int.repr 12) tint) (tptr tfloat))
                      tfloat))
                  (Ssequence
                    (Sset _t'32
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _bully (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __665 noattr)) _asS32 (tarray tint 80))
                          (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                            (Econst_int (Int.repr 1) tint) tint) (tptr tint))
                        tint))
                    (Ssequence
                      (Sset _t'33
                        (Efield
                          (Ederef
                            (Etempvar _bully (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _hitboxRadius tfloat))
                      (Scall None
                        (Evar _init_bully_collision_data (Tfunction
                                                           ((tptr (Tstruct _BullyCollisionData noattr)) ::
                                                            tfloat ::
                                                            tfloat ::
                                                            tfloat ::
                                                            tshort ::
                                                            tfloat ::
                                                            tfloat :: nil)
                                                           tvoid cc_default))
                        ((Eaddrof
                           (Evar _bullyData (Tstruct _BullyCollisionData noattr))
                           (tptr (Tstruct _BullyCollisionData noattr))) ::
                         (Etempvar _t'29 tfloat) ::
                         (Etempvar _t'30 tfloat) ::
                         (Etempvar _t'31 tfloat) :: (Etempvar _t'32 tint) ::
                         (Etempvar _marioToBullyRatio tfloat) ::
                         (Ebinop Oadd (Etempvar _t'33 tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                           tfloat) :: nil)))))))
            (Ssequence
              (Ssequence
                (Sset _t'28
                  (Efield
                    (Ederef
                      (Etempvar _mario (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
                (Sifthenelse (Ebinop One (Etempvar _t'28 tfloat)
                               (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                               tint)
                  (Scall None
                    (Evar _transfer_bully_speed (Tfunction
                                                  ((tptr (Tstruct _BullyCollisionData noattr)) ::
                                                   (tptr (Tstruct _BullyCollisionData noattr)) ::
                                                   nil) tvoid cc_default))
                    ((Eaddrof
                       (Evar _marioData (Tstruct _BullyCollisionData noattr))
                       (tptr (Tstruct _BullyCollisionData noattr))) ::
                     (Eaddrof
                       (Evar _bullyData (Tstruct _BullyCollisionData noattr))
                       (tptr (Tstruct _BullyCollisionData noattr))) :: nil))
                  (Scall None
                    (Evar _transfer_bully_speed (Tfunction
                                                  ((tptr (Tstruct _BullyCollisionData noattr)) ::
                                                   (tptr (Tstruct _BullyCollisionData noattr)) ::
                                                   nil) tvoid cc_default))
                    ((Eaddrof
                       (Evar _bullyData (Tstruct _BullyCollisionData noattr))
                       (tptr (Tstruct _BullyCollisionData noattr))) ::
                     (Eaddrof
                       (Evar _marioData (Tstruct _BullyCollisionData noattr))
                       (tptr (Tstruct _BullyCollisionData noattr))) :: nil))))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'26
                      (Efield
                        (Evar _marioData (Tstruct _BullyCollisionData noattr))
                        _velZ tfloat))
                    (Ssequence
                      (Sset _t'27
                        (Efield
                          (Evar _marioData (Tstruct _BullyCollisionData noattr))
                          _velX tfloat))
                      (Scall (Some _t'1)
                        (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil)
                                        tshort cc_default))
                        ((Etempvar _t'26 tfloat) ::
                         (Etempvar _t'27 tfloat) :: nil))))
                  (Sset _newMarioYaw (Ecast (Etempvar _t'1 tshort) tshort)))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'24
                        (Efield
                          (Evar _bullyData (Tstruct _BullyCollisionData noattr))
                          _velZ tfloat))
                      (Ssequence
                        (Sset _t'25
                          (Efield
                            (Evar _bullyData (Tstruct _BullyCollisionData noattr))
                            _velX tfloat))
                        (Scall (Some _t'2)
                          (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil)
                                          tshort cc_default))
                          ((Etempvar _t'24 tfloat) ::
                           (Etempvar _t'25 tfloat) :: nil))))
                    (Sset _newBullyYaw (Ecast (Etempvar _t'2 tshort) tshort)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'23
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _mario (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _faceAngle
                              (tarray tshort 3))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))
                          tshort))
                      (Sset _marioDYaw
                        (Ecast
                          (Ebinop Osub (Etempvar _newMarioYaw tshort)
                            (Etempvar _t'23 tshort) tint) tshort)))
                    (Ssequence
                      (Ssequence
                        (Sset _t'22
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _bully (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __665 noattr)) _asS32
                                (tarray tint 80))
                              (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                                (Econst_int (Int.repr 1) tint) tint)
                              (tptr tint)) tint))
                        (Sset _bullyDYaw
                          (Ecast
                            (Ebinop Osub (Etempvar _newBullyYaw tshort)
                              (Etempvar _t'22 tint) tint) tshort)))
                      (Ssequence
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _mario (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _faceAngle
                                (tarray tshort 3))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))
                            tshort) (Etempvar _newMarioYaw tshort))
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Sset _t'18
                                (Efield
                                  (Evar _marioData (Tstruct _BullyCollisionData noattr))
                                  _velX tfloat))
                              (Ssequence
                                (Sset _t'19
                                  (Efield
                                    (Evar _marioData (Tstruct _BullyCollisionData noattr))
                                    _velX tfloat))
                                (Ssequence
                                  (Sset _t'20
                                    (Efield
                                      (Evar _marioData (Tstruct _BullyCollisionData noattr))
                                      _velZ tfloat))
                                  (Ssequence
                                    (Sset _t'21
                                      (Efield
                                        (Evar _marioData (Tstruct _BullyCollisionData noattr))
                                        _velZ tfloat))
                                    (Scall (Some _t'3)
                                      (Evar _sqrtf (Tfunction (tfloat :: nil)
                                                     tfloat cc_default))
                                      ((Ebinop Oadd
                                         (Ebinop Omul (Etempvar _t'18 tfloat)
                                           (Etempvar _t'19 tfloat) tfloat)
                                         (Ebinop Omul (Etempvar _t'20 tfloat)
                                           (Etempvar _t'21 tfloat) tfloat)
                                         tfloat) :: nil))))))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _mario (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _forwardVel
                                tfloat) (Etempvar _t'3 tfloat)))
                          (Ssequence
                            (Ssequence
                              (Sset _t'17
                                (Efield
                                  (Evar _marioData (Tstruct _BullyCollisionData noattr))
                                  _posX tfloat))
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Etempvar _mario (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr)) _pos
                                      (tarray tfloat 3))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr tfloat)) tfloat)
                                (Etempvar _t'17 tfloat)))
                            (Ssequence
                              (Ssequence
                                (Sset _t'16
                                  (Efield
                                    (Evar _marioData (Tstruct _BullyCollisionData noattr))
                                    _posZ tfloat))
                                (Sassign
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Ederef
                                          (Etempvar _mario (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr)) _pos
                                        (tarray tfloat 3))
                                      (Econst_int (Int.repr 2) tint)
                                      (tptr tfloat)) tfloat)
                                  (Etempvar _t'16 tfloat)))
                              (Ssequence
                                (Sassign
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _bully (tptr (Tstruct _Object noattr)))
                                            (Tstruct _Object noattr))
                                          _rawData (Tunion __665 noattr))
                                        _asS32 (tarray tint 80))
                                      (Ebinop Oadd
                                        (Econst_int (Int.repr 15) tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      (tptr tint)) tint)
                                  (Etempvar _newBullyYaw tshort))
                                (Ssequence
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'12
                                        (Efield
                                          (Evar _bullyData (Tstruct _BullyCollisionData noattr))
                                          _velX tfloat))
                                      (Ssequence
                                        (Sset _t'13
                                          (Efield
                                            (Evar _bullyData (Tstruct _BullyCollisionData noattr))
                                            _velX tfloat))
                                        (Ssequence
                                          (Sset _t'14
                                            (Efield
                                              (Evar _bullyData (Tstruct _BullyCollisionData noattr))
                                              _velZ tfloat))
                                          (Ssequence
                                            (Sset _t'15
                                              (Efield
                                                (Evar _bullyData (Tstruct _BullyCollisionData noattr))
                                                _velZ tfloat))
                                            (Scall (Some _t'4)
                                              (Evar _sqrtf (Tfunction
                                                             (tfloat :: nil)
                                                             tfloat
                                                             cc_default))
                                              ((Ebinop Oadd
                                                 (Ebinop Omul
                                                   (Etempvar _t'12 tfloat)
                                                   (Etempvar _t'13 tfloat)
                                                   tfloat)
                                                 (Ebinop Omul
                                                   (Etempvar _t'14 tfloat)
                                                   (Etempvar _t'15 tfloat)
                                                   tfloat) tfloat) :: nil))))))
                                    (Sassign
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _bully (tptr (Tstruct _Object noattr)))
                                                (Tstruct _Object noattr))
                                              _rawData (Tunion __665 noattr))
                                            _asF32 (tarray tfloat 80))
                                          (Econst_int (Int.repr 12) tint)
                                          (tptr tfloat)) tfloat)
                                      (Etempvar _t'4 tfloat)))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'11
                                        (Efield
                                          (Evar _bullyData (Tstruct _BullyCollisionData noattr))
                                          _posX tfloat))
                                      (Sassign
                                        (Ederef
                                          (Ebinop Oadd
                                            (Efield
                                              (Efield
                                                (Ederef
                                                  (Etempvar _bully (tptr (Tstruct _Object noattr)))
                                                  (Tstruct _Object noattr))
                                                _rawData
                                                (Tunion __665 noattr)) _asF32
                                              (tarray tfloat 80))
                                            (Ebinop Oadd
                                              (Econst_int (Int.repr 6) tint)
                                              (Econst_int (Int.repr 0) tint)
                                              tint) (tptr tfloat)) tfloat)
                                        (Etempvar _t'11 tfloat)))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'10
                                          (Efield
                                            (Evar _bullyData (Tstruct _BullyCollisionData noattr))
                                            _posZ tfloat))
                                        (Sassign
                                          (Ederef
                                            (Ebinop Oadd
                                              (Efield
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _bully (tptr (Tstruct _Object noattr)))
                                                    (Tstruct _Object noattr))
                                                  _rawData
                                                  (Tunion __665 noattr))
                                                _asF32 (tarray tfloat 80))
                                              (Ebinop Oadd
                                                (Econst_int (Int.repr 6) tint)
                                                (Econst_int (Int.repr 2) tint)
                                                tint) (tptr tfloat)) tfloat)
                                          (Etempvar _t'10 tfloat)))
                                      (Ssequence
                                        (Ssequence
                                          (Sifthenelse (Ebinop Olt
                                                         (Etempvar _marioDYaw tshort)
                                                         (Eunop Oneg
                                                           (Econst_int (Int.repr 16384) tint)
                                                           tint) tint)
                                            (Sset _t'5
                                              (Econst_int (Int.repr 1) tint))
                                            (Sset _t'5
                                              (Ecast
                                                (Ebinop Ogt
                                                  (Etempvar _marioDYaw tshort)
                                                  (Econst_int (Int.repr 16384) tint)
                                                  tint) tbool)))
                                          (Sifthenelse (Etempvar _t'5 tint)
                                            (Ssequence
                                              (Ssequence
                                                (Sset _t'9
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _mario (tptr (Tstruct _MarioState noattr)))
                                                          (Tstruct _MarioState noattr))
                                                        _faceAngle
                                                        (tarray tshort 3))
                                                      (Econst_int (Int.repr 1) tint)
                                                      (tptr tshort)) tshort))
                                                (Sassign
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _mario (tptr (Tstruct _MarioState noattr)))
                                                          (Tstruct _MarioState noattr))
                                                        _faceAngle
                                                        (tarray tshort 3))
                                                      (Econst_int (Int.repr 1) tint)
                                                      (tptr tshort)) tshort)
                                                  (Ebinop Oadd
                                                    (Etempvar _t'9 tshort)
                                                    (Econst_int (Int.repr 32768) tint)
                                                    tint)))
                                              (Ssequence
                                                (Ssequence
                                                  (Sset _t'8
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _mario (tptr (Tstruct _MarioState noattr)))
                                                        (Tstruct _MarioState noattr))
                                                      _forwardVel tfloat))
                                                  (Sassign
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _mario (tptr (Tstruct _MarioState noattr)))
                                                        (Tstruct _MarioState noattr))
                                                      _forwardVel tfloat)
                                                    (Ebinop Omul
                                                      (Etempvar _t'8 tfloat)
                                                      (Eunop Oneg
                                                        (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                                                        tfloat) tfloat)))
                                                (Ssequence
                                                  (Sset _t'7
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _mario (tptr (Tstruct _MarioState noattr)))
                                                        (Tstruct _MarioState noattr))
                                                      _action tuint))
                                                  (Sifthenelse (Ebinop Oand
                                                                 (Etempvar _t'7 tuint)
                                                                 (Ebinop Oshl
                                                                   (Econst_int (Int.repr 1) tint)
                                                                   (Econst_int (Int.repr 11) tint)
                                                                   tint)
                                                                 tuint)
                                                    (Sset _bonkAction
                                                      (Econst_int (Int.repr 16910512) tint))
                                                    (Sset _bonkAction
                                                      (Econst_int (Int.repr 132196) tint))))))
                                            (Ssequence
                                              (Sset _t'6
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _mario (tptr (Tstruct _MarioState noattr)))
                                                    (Tstruct _MarioState noattr))
                                                  _action tuint))
                                              (Sifthenelse (Ebinop Oand
                                                             (Etempvar _t'6 tuint)
                                                             (Ebinop Oshl
                                                               (Econst_int (Int.repr 1) tint)
                                                               (Econst_int (Int.repr 11) tint)
                                                               tint) tuint)
                                                (Sset _bonkAction
                                                  (Econst_int (Int.repr 16910513) tint))
                                                (Sset _bonkAction
                                                  (Econst_int (Int.repr 132197) tint))))))
                                        (Sreturn (Some (Etempvar _bonkAction tuint)))))))))))))))))))))))
|}.

Definition f_bounce_off_object := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_o, (tptr (Tstruct _Object noattr))) :: (_velY, tfloat) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tfloat) :: (_t'3, tfloat) :: (_t'2, tuint) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
            _asF32 (tarray tfloat 80))
          (Ebinop Oadd (Econst_int (Int.repr 6) tint)
            (Econst_int (Int.repr 1) tint) tint) (tptr tfloat)) tfloat))
    (Ssequence
      (Sset _t'4
        (Efield
          (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
            (Tstruct _Object noattr)) _hitboxHeight tfloat))
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
            (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
        (Ebinop Oadd (Etempvar _t'3 tfloat) (Etempvar _t'4 tfloat) tfloat))))
  (Ssequence
    (Sassign
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
          (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
      (Etempvar _velY tfloat))
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _flags tuint))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _flags tuint)
          (Ebinop Oand (Etempvar _t'2 tuint)
            (Eunop Onotint (Econst_int (Int.repr 256) tint) tint) tuint)))
      (Ssequence
        (Sset _t'1
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
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 89) tint) tuint)
                     (Econst_int (Int.repr 16) tint) tuint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 176) tint) tuint)
                   (Econst_int (Int.repr 8) tint) tuint) tuint)
               (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                 (Econst_int (Int.repr 128) tint) tint) tuint)
             (Econst_int (Int.repr 1) tint) tuint) ::
           (Efield
             (Efield
               (Efield
                 (Ederef (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
                   (Tstruct _Object noattr)) _header
                 (Tstruct _ObjectNode noattr)) _gfx
               (Tstruct _GraphNodeObject noattr)) _cameraToObject
             (tarray tfloat 3)) :: nil))))))
|}.

Definition f_hit_object_from_below := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := nil;
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
  (Scall None
    (Evar _set_camera_shake_from_hit (Tfunction (tshort :: nil) tvoid
                                       cc_default))
    ((Econst_int (Int.repr 8) tint) :: nil)))
|}.

Definition f_determine_knockback_action := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: (_arg, tint) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_bonkAction, tuint) :: (_terrainIndex, tshort) ::
               (_strengthIndex, tshort) :: (_angleToObject, tshort) ::
               (_facingDYaw, tshort) :: (_remainingHealth, tshort) ::
               (_t'2, tint) :: (_t'1, tshort) ::
               (_t'21, (tptr (Tstruct _Object noattr))) :: (_t'20, tshort) ::
               (_t'19, tuchar) :: (_t'18, tshort) :: (_t'17, tuint) ::
               (_t'16, tuint) :: (_t'15, tint) ::
               (_t'14, (tptr (Tstruct _Object noattr))) :: (_t'13, tint) ::
               (_t'12, (tptr (Tstruct _Object noattr))) :: (_t'11, tfloat) ::
               (_t'10, tfloat) :: (_t'9, tfloat) :: (_t'8, tfloat) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tfloat) ::
               (_t'5, tfloat) :: (_t'4, tfloat) :: (_t'3, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _terrainIndex (Ecast (Econst_int (Int.repr 0) tint) tshort))
  (Ssequence
    (Sset _strengthIndex (Ecast (Econst_int (Int.repr 0) tint) tshort))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'21
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _interactObj
              (tptr (Tstruct _Object noattr))))
          (Scall (Some _t'1)
            (Evar _mario_obj_angle_to_object (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                (tptr (Tstruct _Object noattr)) ::
                                                nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _t'21 (tptr (Tstruct _Object noattr))) :: nil)))
        (Sset _angleToObject (Ecast (Etempvar _t'1 tshort) tshort)))
      (Ssequence
        (Ssequence
          (Sset _t'20
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _faceAngle
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort))
          (Sset _facingDYaw
            (Ecast
              (Ebinop Osub (Etempvar _angleToObject tshort)
                (Etempvar _t'20 tshort) tint) tshort)))
        (Ssequence
          (Ssequence
            (Sset _t'18
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _health tshort))
            (Ssequence
              (Sset _t'19
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _hurtCounter tuchar))
              (Sset _remainingHealth
                (Ecast
                  (Ebinop Osub (Etempvar _t'18 tshort)
                    (Ebinop Omul (Econst_int (Int.repr 64) tint)
                      (Etempvar _t'19 tuchar) tint) tint) tshort))))
          (Ssequence
            (Ssequence
              (Sset _t'16
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _action tuint))
              (Sifthenelse (Ebinop Oand (Etempvar _t'16 tuint)
                             (Ebinop Oor
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 13) tint) tint)
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 14) tint) tint) tint)
                             tuint)
                (Sset _terrainIndex
                  (Ecast (Econst_int (Int.repr 2) tint) tshort))
                (Ssequence
                  (Sset _t'17
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _action tuint))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'17 tuint)
                                 (Ebinop Oor
                                   (Ebinop Oor
                                     (Ebinop Oshl
                                       (Econst_int (Int.repr 1) tint)
                                       (Econst_int (Int.repr 11) tint) tint)
                                     (Ebinop Oshl
                                       (Econst_int (Int.repr 1) tint)
                                       (Econst_int (Int.repr 20) tint) tint)
                                     tint)
                                   (Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 21) tint) tint)
                                   tint) tuint)
                    (Sset _terrainIndex
                      (Ecast (Econst_int (Int.repr 1) tint) tshort))
                    Sskip))))
            (Ssequence
              (Sifthenelse (Ebinop Olt (Etempvar _remainingHealth tshort)
                             (Econst_int (Int.repr 256) tint) tint)
                (Sset _strengthIndex
                  (Ecast (Econst_int (Int.repr 2) tint) tshort))
                (Ssequence
                  (Sset _t'12
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _interactObj
                      (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sset _t'13
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'12 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __665 noattr)) _asS32 (tarray tint 80))
                          (Econst_int (Int.repr 62) tint) (tptr tint)) tint))
                    (Sifthenelse (Ebinop Oge (Etempvar _t'13 tint)
                                   (Econst_int (Int.repr 4) tint) tint)
                      (Sset _strengthIndex
                        (Ecast (Econst_int (Int.repr 2) tint) tshort))
                      (Ssequence
                        (Sset _t'14
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _interactObj
                            (tptr (Tstruct _Object noattr))))
                        (Ssequence
                          (Sset _t'15
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'14 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __665 noattr)) _asS32
                                  (tarray tint 80))
                                (Econst_int (Int.repr 62) tint) (tptr tint))
                              tint))
                          (Sifthenelse (Ebinop Oge (Etempvar _t'15 tint)
                                         (Econst_int (Int.repr 2) tint) tint)
                            (Sset _strengthIndex
                              (Ecast (Econst_int (Int.repr 1) tint) tshort))
                            Sskip)))))))
              (Ssequence
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _faceAngle
                        (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tshort)) tshort)
                  (Etempvar _angleToObject tshort))
                (Ssequence
                  (Sifthenelse (Ebinop Oeq (Etempvar _terrainIndex tshort)
                                 (Econst_int (Int.repr 2) tint) tint)
                    (Ssequence
                      (Ssequence
                        (Sset _t'11
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _forwardVel
                            tfloat))
                        (Sifthenelse (Ebinop Olt (Etempvar _t'11 tfloat)
                                       (Econst_single (Float32.of_bits (Int.repr 1105199104)) tfloat)
                                       tint)
                          (Scall None
                            (Evar _mario_set_forward_vel (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            tfloat :: nil)
                                                           tvoid cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_single (Float32.of_bits (Int.repr 1105199104)) tfloat) ::
                             nil))
                          Sskip))
                      (Ssequence
                        (Sset _t'6
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
                          (Sset _t'7
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _interactObj
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
                                      (Tunion __665 noattr)) _asF32
                                    (tarray tfloat 80))
                                  (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  (tptr tfloat)) tfloat))
                            (Sifthenelse (Ebinop Oge (Etempvar _t'6 tfloat)
                                           (Etempvar _t'8 tfloat) tint)
                              (Ssequence
                                (Sset _t'10
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr)) _vel
                                        (tarray tfloat 3))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr tfloat)) tfloat))
                                (Sifthenelse (Ebinop Olt
                                               (Etempvar _t'10 tfloat)
                                               (Econst_single (Float32.of_bits (Int.repr 1101004800)) tfloat)
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
                                    (Econst_single (Float32.of_bits (Int.repr 1101004800)) tfloat))
                                  Sskip))
                              (Ssequence
                                (Sset _t'9
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr)) _vel
                                        (tarray tfloat 3))
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
                                  Sskip)))))))
                    (Ssequence
                      (Sset _t'5
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _forwardVel tfloat))
                      (Sifthenelse (Ebinop Olt (Etempvar _t'5 tfloat)
                                     (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                                     tint)
                        (Scall None
                          (Evar _mario_set_forward_vel (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          tfloat :: nil)
                                                         tvoid cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat) ::
                           nil))
                        Sskip)))
                  (Ssequence
                    (Ssequence
                      (Sifthenelse (Ebinop Ole
                                     (Eunop Oneg
                                       (Econst_int (Int.repr 16384) tint)
                                       tint) (Etempvar _facingDYaw tshort)
                                     tint)
                        (Sset _t'2
                          (Ecast
                            (Ebinop Ole (Etempvar _facingDYaw tshort)
                              (Econst_int (Int.repr 16384) tint) tint) tbool))
                        (Sset _t'2 (Econst_int (Int.repr 0) tint)))
                      (Sifthenelse (Etempvar _t'2 tint)
                        (Ssequence
                          (Ssequence
                            (Sset _t'4
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
                              (Ebinop Omul (Etempvar _t'4 tfloat)
                                (Eunop Oneg
                                  (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                                  tfloat) tfloat)))
                          (Sset _bonkAction
                            (Ederef
                              (Ebinop Oadd
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _sBackwardKnockbackActions (tarray (tarray tuint 3) 3))
                                    (Etempvar _terrainIndex tshort)
                                    (tptr (tarray tuint 3)))
                                  (tarray tuint 3))
                                (Etempvar _strengthIndex tshort)
                                (tptr tuint)) tuint)))
                        (Ssequence
                          (Ssequence
                            (Sset _t'3
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
                              (Ebinop Oadd (Etempvar _t'3 tshort)
                                (Econst_int (Int.repr 32768) tint) tint)))
                          (Sset _bonkAction
                            (Ederef
                              (Ebinop Oadd
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _sForwardKnockbackActions (tarray (tarray tuint 3) 3))
                                    (Etempvar _terrainIndex tshort)
                                    (tptr (tarray tuint 3)))
                                  (tarray tuint 3))
                                (Etempvar _strengthIndex tshort)
                                (tptr tuint)) tuint)))))
                    (Sreturn (Some (Etempvar _bonkAction tuint)))))))))))))
|}.

Definition f_push_mario_out_of_object := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_o, (tptr (Tstruct _Object noattr))) ::
                (_padding, tfloat) :: nil);
  fn_vars := ((_floor, (tptr (Tstruct _Surface noattr))) ::
              (_newMarioX, tfloat) :: (_newMarioZ, tfloat) :: nil);
  fn_temps := ((_minDistance, tfloat) :: (_offsetX, tfloat) ::
               (_offsetZ, tfloat) :: (_distance, tfloat) ::
               (_pushAngle, tshort) :: (_t'2, tshort) :: (_t'1, tfloat) ::
               (_t'20, tfloat) :: (_t'19, (tptr (Tstruct _Object noattr))) ::
               (_t'18, tfloat) :: (_t'17, tfloat) :: (_t'16, tfloat) ::
               (_t'15, tfloat) :: (_t'14, tfloat) :: (_t'13, tshort) ::
               (_t'12, tfloat) :: (_t'11, tfloat) :: (_t'10, tfloat) ::
               (_t'9, tfloat) :: (_t'8, tfloat) :: (_t'7, tfloat) ::
               (_t'6, tfloat) :: (_t'5, tfloat) :: (_t'4, tfloat) ::
               (_t'3, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'18
      (Efield
        (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
          (Tstruct _Object noattr)) _hitboxRadius tfloat))
    (Ssequence
      (Sset _t'19
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'20
          (Efield
            (Ederef (Etempvar _t'19 (tptr (Tstruct _Object noattr)))
              (Tstruct _Object noattr)) _hitboxRadius tfloat))
        (Sset _minDistance
          (Ebinop Oadd
            (Ebinop Oadd (Etempvar _t'18 tfloat) (Etempvar _t'20 tfloat)
              tfloat) (Etempvar _padding tfloat) tfloat)))))
  (Ssequence
    (Ssequence
      (Sset _t'16
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
            (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
      (Ssequence
        (Sset _t'17
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asF32 (tarray tfloat 80))
              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                (Econst_int (Int.repr 0) tint) tint) (tptr tfloat)) tfloat))
        (Sset _offsetX
          (Ebinop Osub (Etempvar _t'16 tfloat) (Etempvar _t'17 tfloat)
            tfloat))))
    (Ssequence
      (Ssequence
        (Sset _t'14
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
        (Ssequence
          (Sset _t'15
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                  (Econst_int (Int.repr 2) tint) tint) (tptr tfloat)) tfloat))
          (Sset _offsetZ
            (Ebinop Osub (Etempvar _t'14 tfloat) (Etempvar _t'15 tfloat)
              tfloat))))
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _sqrtf (Tfunction (tfloat :: nil) tfloat cc_default))
            ((Ebinop Oadd
               (Ebinop Omul (Etempvar _offsetX tfloat)
                 (Etempvar _offsetX tfloat) tfloat)
               (Ebinop Omul (Etempvar _offsetZ tfloat)
                 (Etempvar _offsetZ tfloat) tfloat) tfloat) :: nil))
          (Sset _distance (Etempvar _t'1 tfloat)))
        (Sifthenelse (Ebinop Olt (Etempvar _distance tfloat)
                       (Etempvar _minDistance tfloat) tint)
          (Ssequence
            (Sifthenelse (Ebinop Oeq (Etempvar _distance tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                           tint)
              (Ssequence
                (Sset _t'13
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _faceAngle
                        (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tshort)) tshort))
                (Sset _pushAngle (Ecast (Etempvar _t'13 tshort) tshort)))
              (Ssequence
                (Scall (Some _t'2)
                  (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil) tshort
                                  cc_default))
                  ((Etempvar _offsetZ tfloat) ::
                   (Etempvar _offsetX tfloat) :: nil))
                (Sset _pushAngle (Ecast (Etempvar _t'2 tshort) tshort))))
            (Ssequence
              (Ssequence
                (Sset _t'11
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _o (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                      (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                        (Econst_int (Int.repr 0) tint) tint) (tptr tfloat))
                    tfloat))
                (Ssequence
                  (Sset _t'12
                    (Ederef
                      (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                        (Ebinop Oshr
                          (Ecast (Etempvar _pushAngle tshort) tushort)
                          (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                      tfloat))
                  (Sassign (Evar _newMarioX tfloat)
                    (Ebinop Oadd (Etempvar _t'11 tfloat)
                      (Ebinop Omul (Etempvar _minDistance tfloat)
                        (Etempvar _t'12 tfloat) tfloat) tfloat))))
              (Ssequence
                (Ssequence
                  (Sset _t'9
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _o (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                        (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                          (Econst_int (Int.repr 2) tint) tint) (tptr tfloat))
                      tfloat))
                  (Ssequence
                    (Sset _t'10
                      (Ederef
                        (Ebinop Oadd
                          (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                            (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                          (Ebinop Oshr
                            (Ecast (Etempvar _pushAngle tshort) tushort)
                            (Econst_int (Int.repr 4) tint) tint)
                          (tptr tfloat)) tfloat))
                    (Sassign (Evar _newMarioZ tfloat)
                      (Ebinop Oadd (Etempvar _t'9 tfloat)
                        (Ebinop Omul (Etempvar _minDistance tfloat)
                          (Etempvar _t'10 tfloat) tfloat) tfloat))))
                (Ssequence
                  (Scall None
                    (Evar _f32_find_wall_collision (Tfunction
                                                     ((tptr tfloat) ::
                                                      (tptr tfloat) ::
                                                      (tptr tfloat) ::
                                                      tfloat :: tfloat ::
                                                      nil) tint cc_default))
                    ((Eaddrof (Evar _newMarioX tfloat) (tptr tfloat)) ::
                     (Ebinop Oadd
                       (Efield
                         (Ederef
                           (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                           (Tstruct _MarioState noattr)) _pos
                         (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                       (tptr tfloat)) ::
                     (Eaddrof (Evar _newMarioZ tfloat) (tptr tfloat)) ::
                     (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat) ::
                     (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat) ::
                     nil))
                  (Ssequence
                    (Ssequence
                      (Sset _t'6 (Evar _newMarioX tfloat))
                      (Ssequence
                        (Sset _t'7
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
                          (Sset _t'8 (Evar _newMarioZ tfloat))
                          (Scall None
                            (Evar _find_floor (Tfunction
                                                (tfloat :: tfloat ::
                                                 tfloat ::
                                                 (tptr (tptr (Tstruct _Surface noattr))) ::
                                                 nil) tfloat cc_default))
                            ((Etempvar _t'6 tfloat) ::
                             (Etempvar _t'7 tfloat) ::
                             (Etempvar _t'8 tfloat) ::
                             (Eaddrof
                               (Evar _floor (tptr (Tstruct _Surface noattr)))
                               (tptr (tptr (Tstruct _Surface noattr)))) ::
                             nil)))))
                    (Ssequence
                      (Sset _t'3
                        (Evar _floor (tptr (Tstruct _Surface noattr))))
                      (Sifthenelse (Ebinop One
                                     (Etempvar _t'3 (tptr (Tstruct _Surface noattr)))
                                     (Ecast (Econst_int (Int.repr 0) tint)
                                       (tptr tvoid)) tint)
                        (Ssequence
                          (Ssequence
                            (Sset _t'5 (Evar _newMarioX tfloat))
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
                              (Etempvar _t'5 tfloat)))
                          (Ssequence
                            (Sset _t'4 (Evar _newMarioZ tfloat))
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
                              (Etempvar _t'4 tfloat))))
                        Sskip)))))))
          Sskip)))))
|}.

Definition f_bounce_back_from_attack := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interaction, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tuint) :: (_t'3, tuint) :: (_t'2, tuint) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Oand (Etempvar _interaction tuint)
                 (Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 1) tint) tint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 2) tint) tint) tint)
                   (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                     (Econst_int (Int.repr 3) tint) tint) tint) tuint)
    (Ssequence
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _action tuint))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tuint)
                       (Econst_int (Int.repr 8389504) tint) tint)
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _action tuint)
            (Econst_int (Int.repr 8389719) tint))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _action tuint))
          (Sifthenelse (Ebinop Oand (Etempvar _t'3 tuint)
                         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 11) tint) tint) tuint)
            (Scall None
              (Evar _mario_set_forward_vel (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tfloat :: nil) tvoid
                                             cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Eunop Oneg
                 (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                 tfloat) :: nil))
            (Scall None
              (Evar _mario_set_forward_vel (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tfloat :: nil) tvoid
                                             cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Eunop Oneg
                 (Econst_single (Float32.of_bits (Int.repr 1111490560)) tfloat)
                 tfloat) :: nil))))
        (Ssequence
          (Scall None
            (Evar _set_camera_shake_from_hit (Tfunction (tshort :: nil) tvoid
                                               cc_default))
            ((Econst_int (Int.repr 1) tint) :: nil))
          (Ssequence
            (Sset _t'2
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _particleFlags tuint))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _particleFlags tuint)
              (Ebinop Oor (Etempvar _t'2 tuint)
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 18) tint) tint) tuint))))))
    Sskip)
  (Sifthenelse (Ebinop Oand (Etempvar _interaction tuint)
                 (Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 1) tint) tint)
                       (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 2) tint) tint) tint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 3) tint) tint) tint)
                   (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                     (Econst_int (Int.repr 5) tint) tint) tint) tuint)
    (Ssequence
      (Sset _t'1
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
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 68) tint) tuint)
                   (Econst_int (Int.repr 16) tint) tuint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 176) tint) tuint)
                 (Econst_int (Int.repr 8) tint) tuint) tuint)
             (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
               (Econst_int (Int.repr 128) tint) tint) tuint)
           (Econst_int (Int.repr 1) tint) tuint) ::
         (Efield
           (Efield
             (Efield
               (Ederef (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
                 (Tstruct _Object noattr)) _header
               (Tstruct _ObjectNode noattr)) _gfx
             (Tstruct _GraphNodeObject noattr)) _cameraToObject
           (tarray tfloat 3)) :: nil)))
    Sskip))
|}.

Definition f_should_push_or_pull_door := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_dx, tfloat) :: (_dz, tfloat) :: (_dYaw, tshort) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tshort) ::
               (_t'8, tfloat) :: (_t'7, tfloat) :: (_t'6, tfloat) ::
               (_t'5, tfloat) :: (_t'4, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
            _asF32 (tarray tfloat 80))
          (Ebinop Oadd (Econst_int (Int.repr 6) tint)
            (Econst_int (Int.repr 0) tint) tint) (tptr tfloat)) tfloat))
    (Ssequence
      (Sset _t'8
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
            (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
      (Sset _dx
        (Ebinop Osub (Etempvar _t'7 tfloat) (Etempvar _t'8 tfloat) tfloat))))
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asF32 (tarray tfloat 80))
            (Ebinop Oadd (Econst_int (Int.repr 6) tint)
              (Econst_int (Int.repr 2) tint) tint) (tptr tfloat)) tfloat))
      (Ssequence
        (Sset _t'6
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
        (Sset _dz
          (Ebinop Osub (Etempvar _t'5 tfloat) (Etempvar _t'6 tfloat) tfloat))))
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil) tshort
                          cc_default))
          ((Etempvar _dz tfloat) :: (Etempvar _dx tfloat) :: nil))
        (Ssequence
          (Sset _t'4
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asS32 (tarray tint 80))
                (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                  (Econst_int (Int.repr 1) tint) tint) (tptr tint)) tint))
          (Sset _dYaw
            (Ecast
              (Ebinop Osub (Etempvar _t'4 tint) (Etempvar _t'1 tshort) tint)
              tshort))))
      (Ssequence
        (Ssequence
          (Sifthenelse (Ebinop Oge (Etempvar _dYaw tshort)
                         (Eunop Oneg (Econst_int (Int.repr 16384) tint) tint)
                         tint)
            (Sset _t'2
              (Ecast
                (Ebinop Ole (Etempvar _dYaw tshort)
                  (Econst_int (Int.repr 16384) tint) tint) tbool))
            (Sset _t'2 (Econst_int (Int.repr 0) tint)))
          (Sifthenelse (Etempvar _t'2 tint)
            (Sset _t'3 (Ecast (Econst_int (Int.repr 1) tint) tint))
            (Sset _t'3 (Ecast (Econst_int (Int.repr 2) tint) tint))))
        (Sreturn (Some (Etempvar _t'3 tint)))))))
|}.

Definition f_take_damage_from_interact_object := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_shake, tint) :: (_damage, tint) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: (_t'3, tuint) ::
               (_t'2, tuint) :: (_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _interactObj
        (tptr (Tstruct _Object noattr))))
    (Sset _damage
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Ederef (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
            _asS32 (tarray tint 80)) (Econst_int (Int.repr 62) tint)
          (tptr tint)) tint)))
  (Ssequence
    (Sifthenelse (Ebinop Oge (Etempvar _damage tint)
                   (Econst_int (Int.repr 4) tint) tint)
      (Sset _shake (Econst_int (Int.repr 5) tint))
      (Sifthenelse (Ebinop Oge (Etempvar _damage tint)
                     (Econst_int (Int.repr 2) tint) tint)
        (Sset _shake (Econst_int (Int.repr 4) tint))
        (Sset _shake (Econst_int (Int.repr 3) tint))))
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _flags tuint))
        (Sifthenelse (Eunop Onotbool
                       (Ebinop Oand (Etempvar _t'3 tuint)
                         (Econst_int (Int.repr 16) tint) tuint) tint)
          (Sset _damage
            (Ebinop Oadd (Etempvar _damage tint)
              (Ebinop Odiv
                (Ebinop Oadd (Etempvar _damage tint)
                  (Econst_int (Int.repr 1) tint) tint)
                (Econst_int (Int.repr 2) tint) tint) tint))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'2
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _flags tuint))
          (Sifthenelse (Ebinop Oand (Etempvar _t'2 tuint)
                         (Econst_int (Int.repr 4) tint) tuint)
            (Sset _damage (Econst_int (Int.repr 0) tint))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'1
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _hurtCounter tuchar))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _hurtCounter tuchar)
              (Ebinop Oadd (Etempvar _t'1 tuchar)
                (Ebinop Omul (Econst_int (Int.repr 4) tint)
                  (Etempvar _damage tint) tint) tint)))
          (Ssequence
            (Scall None
              (Evar _set_camera_shake_from_hit (Tfunction (tshort :: nil)
                                                 tvoid cc_default))
              ((Etempvar _shake tint) :: nil))
            (Sreturn (Some (Etempvar _damage tint)))))))))
|}.

Definition f_take_damage_and_knock_back := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_damage, tuint) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'12, tuint) :: (_t'11, tshort) :: (_t'10, tuint) ::
               (_t'9, tuint) :: (_t'8, (tptr (Tstruct _Object noattr))) ::
               (_t'7, tint) :: (_t'6, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'11 (Evar _sInvulnerable tshort))
        (Sifthenelse (Eunop Onotbool (Etempvar _t'11 tshort) tint)
          (Ssequence
            (Sset _t'12
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _flags tuint))
            (Sset _t'4
              (Ecast
                (Eunop Onotbool
                  (Ebinop Oand (Etempvar _t'12 tuint)
                    (Econst_int (Int.repr 2) tint) tuint) tint) tbool)))
          (Sset _t'4 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'4 tint)
        (Ssequence
          (Sset _t'10
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asU32 (tarray tuint 80))
                (Econst_int (Int.repr 66) tint) (tptr tuint)) tuint))
          (Sset _t'5
            (Ecast
              (Eunop Onotbool
                (Ebinop Oand (Etempvar _t'10 tuint)
                  (Econst_int (Int.repr 2) tint) tuint) tint) tbool)))
        (Sset _t'5 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'5 tint)
      (Ssequence
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
              (tptr tint)) tint)
          (Ebinop Oor
            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
              (Econst_int (Int.repr 15) tint) tint)
            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
              (Econst_int (Int.repr 13) tint) tint) tint))
        (Ssequence
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _interactObj
              (tptr (Tstruct _Object noattr)))
            (Etempvar _o (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Ssequence
              (Scall (Some _t'1)
                (Evar _take_damage_from_interact_object (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           nil) tuint
                                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sset _damage (Etempvar _t'1 tuint)))
            (Ssequence
              (Ssequence
                (Sset _t'9
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _o (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asU32 (tarray tuint 80))
                      (Econst_int (Int.repr 66) tint) (tptr tuint)) tuint))
                (Sifthenelse (Ebinop Oand (Etempvar _t'9 tuint)
                               (Econst_int (Int.repr 8) tint) tuint)
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1109393408)) tfloat))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _t'7
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _o (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __665 noattr)) _asS32 (tarray tint 80))
                        (Econst_int (Int.repr 62) tint) (tptr tint)) tint))
                  (Sifthenelse (Ebinop Ogt (Etempvar _t'7 tint)
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
                (Ssequence
                  (Scall None
                    (Evar _update_mario_sound_and_camera (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            nil) tvoid
                                                           cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'6
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _o (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __665 noattr)) _asS32
                                (tarray tint 80))
                              (Econst_int (Int.repr 62) tint) (tptr tint))
                            tint))
                        (Scall (Some _t'2)
                          (Evar _determine_knockback_action (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               tint :: nil)
                                                              tuint
                                                              cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Etempvar _t'6 tint) :: nil)))
                      (Scall (Some _t'3)
                        (Evar _drop_and_set_mario_action (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            tuint :: tuint ::
                                                            nil) tint
                                                           cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Etempvar _t'2 tuint) :: (Etempvar _damage tuint) ::
                         nil)))
                    (Sreturn (Some (Etempvar _t'3 tint))))))))))
      Sskip))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_reset_mario_pitch := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) :: (_t'10, tuint) ::
               (_t'9, tuint) :: (_t'8, tuint) :: (_t'7, tuchar) ::
               (_t'6, (tptr (Tstruct _Camera noattr))) ::
               (_t'5, (tptr (Tstruct _Area noattr))) ::
               (_t'4, (tptr (Tstruct _Camera noattr))) ::
               (_t'3, (tptr (Tstruct _Area noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'9
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _action tuint))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tuint)
                     (Econst_int (Int.repr 16779401) tint) tint)
        (Sset _t'1 (Econst_int (Int.repr 1) tint))
        (Ssequence
          (Sset _t'10
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _action tuint))
          (Sset _t'1
            (Ecast
              (Ebinop Oeq (Etempvar _t'10 tuint)
                (Econst_int (Int.repr 8915096) tint) tint) tbool)))))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sset _t'2 (Econst_int (Int.repr 1) tint))
      (Ssequence
        (Sset _t'8
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _action tuint))
        (Sset _t'2
          (Ecast
            (Ebinop Oeq (Etempvar _t'8 tuint)
              (Econst_int (Int.repr 277350553) tint) tint) tbool)))))
  (Sifthenelse (Etempvar _t'2 tint)
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _area
            (tptr (Tstruct _Area noattr))))
        (Ssequence
          (Sset _t'4
            (Efield
              (Ederef (Etempvar _t'3 (tptr (Tstruct _Area noattr)))
                (Tstruct _Area noattr)) _camera
              (tptr (Tstruct _Camera noattr))))
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
                    (Ederef (Etempvar _t'6 (tptr (Tstruct _Camera noattr)))
                      (Tstruct _Camera noattr)) _defMode tuchar))
                (Scall None
                  (Evar _set_camera_mode (Tfunction
                                           ((tptr (Tstruct _Camera noattr)) ::
                                            tshort :: tshort :: nil) tvoid
                                           cc_default))
                  ((Etempvar _t'4 (tptr (Tstruct _Camera noattr))) ::
                   (Etempvar _t'7 tuchar) ::
                   (Econst_int (Int.repr 1) tint) :: nil)))))))
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
            (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort)
        (Econst_int (Int.repr 0) tint)))
    Sskip))
|}.

Definition f_interact_coin := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'12, tint) :: (_t'11, tshort) :: (_t'10, tint) ::
               (_t'9, tuchar) :: (_t'8, tshort) :: (_t'7, tshort) ::
               (_t'6, tint) :: (_t'5, tshort) :: (_t'4, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'11
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _numCoins tshort))
    (Ssequence
      (Sset _t'12
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 62) tint)
            (tptr tint)) tint))
      (Sassign
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _numCoins tshort)
        (Ebinop Oadd (Etempvar _t'11 tshort) (Etempvar _t'12 tint) tint))))
  (Ssequence
    (Ssequence
      (Sset _t'9
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _healCounter tuchar))
      (Ssequence
        (Sset _t'10
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 62) tint)
              (tptr tint)) tint))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _healCounter tuchar)
          (Ebinop Oadd (Etempvar _t'9 tuchar)
            (Ebinop Omul (Econst_int (Int.repr 4) tint) (Etempvar _t'10 tint)
              tint) tint))))
    (Ssequence
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
            (tptr tint)) tint)
        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
          (Econst_int (Int.repr 15) tint) tint))
      (Ssequence
        (Ssequence
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'7 (Evar _gCurrCourseNum tshort))
                (Sifthenelse (Ebinop Oge (Etempvar _t'7 tshort)
                               (Econst_int (Int.repr 1) tint) tint)
                  (Ssequence
                    (Sset _t'8 (Evar _gCurrCourseNum tshort))
                    (Sset _t'1
                      (Ecast
                        (Ebinop Ole (Etempvar _t'8 tshort)
                          (Econst_int (Int.repr 15) tint) tint) tbool)))
                  (Sset _t'1 (Econst_int (Int.repr 0) tint))))
              (Sifthenelse (Etempvar _t'1 tint)
                (Ssequence
                  (Sset _t'5
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _numCoins tshort))
                  (Ssequence
                    (Sset _t'6
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _o (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __665 noattr)) _asS32 (tarray tint 80))
                          (Econst_int (Int.repr 62) tint) (tptr tint)) tint))
                    (Sset _t'2
                      (Ecast
                        (Ebinop Olt
                          (Ebinop Osub (Etempvar _t'5 tshort)
                            (Etempvar _t'6 tint) tint)
                          (Econst_int (Int.repr 100) tint) tint) tbool))))
                (Sset _t'2 (Econst_int (Int.repr 0) tint))))
            (Sifthenelse (Etempvar _t'2 tint)
              (Ssequence
                (Sset _t'4
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _numCoins tshort))
                (Sset _t'3
                  (Ecast
                    (Ebinop Oge (Etempvar _t'4 tshort)
                      (Econst_int (Int.repr 100) tint) tint) tbool)))
              (Sset _t'3 (Econst_int (Int.repr 0) tint))))
          (Sifthenelse (Etempvar _t'3 tint)
            (Scall None
              (Evar _bhv_spawn_star_no_level_exit (Tfunction (tuint :: nil)
                                                    tvoid cc_default))
              ((Econst_int (Int.repr 6) tint) :: nil))
            Sskip))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_interact_water_ring := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _healCounter tuchar))
    (Ssequence
      (Sset _t'2
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 62) tint)
            (tptr tint)) tint))
      (Sassign
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _healCounter tuchar)
        (Ebinop Oadd (Etempvar _t'1 tuchar)
          (Ebinop Omul (Econst_int (Int.repr 4) tint) (Etempvar _t'2 tint)
            tint) tint))))
  (Ssequence
    (Sassign
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
            _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
          (tptr tint)) tint)
      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
        (Econst_int (Int.repr 15) tint) tint))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_interact_star_or_key := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_starIndex, tuint) :: (_starGrabAction, tuint) ::
               (_noExit, tuint) :: (_grandStar, tuint) :: (_t'3, tuint) ::
               (_t'2, tuint) :: (_t'1, tint) :: (_t'14, tuint) ::
               (_t'13, tuint) :: (_t'12, tushort) :: (_t'11, tuint) ::
               (_t'10, tuint) :: (_t'9, tuint) :: (_t'8, tint) ::
               (_t'7, tshort) :: (_t'6, tshort) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: (_t'4, tshort) ::
               nil);
  fn_body :=
(Ssequence
  (Sset _starGrabAction (Econst_int (Int.repr 4866) tint))
  (Ssequence
    (Ssequence
      (Sset _t'14
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asU32 (tarray tuint 80)) (Econst_int (Int.repr 66) tint)
            (tptr tuint)) tuint))
      (Sset _noExit
        (Ebinop One
          (Ebinop Oand (Etempvar _t'14 tuint)
            (Econst_int (Int.repr 1024) tint) tuint)
          (Econst_int (Int.repr 0) tint) tint)))
    (Ssequence
      (Ssequence
        (Sset _t'13
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asU32 (tarray tuint 80)) (Econst_int (Int.repr 66) tint)
              (tptr tuint)) tuint))
        (Sset _grandStar
          (Ebinop One
            (Ebinop Oand (Etempvar _t'13 tuint)
              (Econst_int (Int.repr 2048) tint) tuint)
            (Econst_int (Int.repr 0) tint) tint)))
      (Ssequence
        (Ssequence
          (Sset _t'4
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _health tshort))
          (Sifthenelse (Ebinop Oge (Etempvar _t'4 tshort)
                         (Econst_int (Int.repr 256) tint) tint)
            (Ssequence
              (Scall None
                (Evar _mario_stop_riding_and_holding (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        nil) tvoid
                                                       cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Ssequence
                (Sifthenelse (Eunop Onotbool (Etempvar _noExit tuint) tint)
                  (Ssequence
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _hurtCounter tuchar)
                      (Econst_int (Int.repr 0) tint))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _healCounter
                          tuchar) (Econst_int (Int.repr 0) tint))
                      (Ssequence
                        (Sset _t'12
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _capTimer
                            tushort))
                        (Sifthenelse (Ebinop Ogt (Etempvar _t'12 tushort)
                                       (Econst_int (Int.repr 1) tint) tint)
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _capTimer
                              tushort) (Econst_int (Int.repr 1) tint))
                          Sskip))))
                  Sskip)
                (Ssequence
                  (Sifthenelse (Etempvar _noExit tuint)
                    (Sset _starGrabAction (Econst_int (Int.repr 4871) tint))
                    Sskip)
                  (Ssequence
                    (Ssequence
                      (Sset _t'11
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _action tuint))
                      (Sifthenelse (Ebinop Oand (Etempvar _t'11 tuint)
                                     (Ebinop Oshl
                                       (Econst_int (Int.repr 1) tint)
                                       (Econst_int (Int.repr 13) tint) tint)
                                     tuint)
                        (Sset _starGrabAction
                          (Econst_int (Int.repr 4867) tint))
                        Sskip))
                    (Ssequence
                      (Ssequence
                        (Sset _t'10
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _action tuint))
                        (Sifthenelse (Ebinop Oand (Etempvar _t'10 tuint)
                                       (Ebinop Oshl
                                         (Econst_int (Int.repr 1) tint)
                                         (Econst_int (Int.repr 14) tint)
                                         tint) tuint)
                          (Sset _starGrabAction
                            (Econst_int (Int.repr 4867) tint))
                          Sskip))
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
                                           (Econst_int (Int.repr 11) tint)
                                           tint) tuint)
                            (Sset _starGrabAction
                              (Econst_int (Int.repr 6404) tint))
                            Sskip))
                        (Ssequence
                          (Scall None
                            (Evar _spawn_object (Tfunction
                                                  ((tptr (Tstruct _Object noattr)) ::
                                                   tint :: (tptr tuint) ::
                                                   nil)
                                                  (tptr (Tstruct _Object noattr))
                                                  cc_default))
                            ((Etempvar _o (tptr (Tstruct _Object noattr))) ::
                             (Econst_int (Int.repr 0) tint) ::
                             (Evar _bhvStarKeyCollectionPuffSpawner (tarray tuint 0)) ::
                             nil))
                          (Ssequence
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _o (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _rawData
                                      (Tunion __665 noattr)) _asS32
                                    (tarray tint 80))
                                  (Econst_int (Int.repr 43) tint)
                                  (tptr tint)) tint)
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 15) tint) tint))
                            (Ssequence
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr))
                                  _interactObj
                                  (tptr (Tstruct _Object noattr)))
                                (Etempvar _o (tptr (Tstruct _Object noattr))))
                              (Ssequence
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _usedObj
                                    (tptr (Tstruct _Object noattr)))
                                  (Etempvar _o (tptr (Tstruct _Object noattr))))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'8
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _o (tptr (Tstruct _Object noattr)))
                                                (Tstruct _Object noattr))
                                              _rawData (Tunion __665 noattr))
                                            _asS32 (tarray tint 80))
                                          (Econst_int (Int.repr 64) tint)
                                          (tptr tint)) tint))
                                    (Sset _starIndex
                                      (Ebinop Oand
                                        (Ebinop Oshr (Etempvar _t'8 tint)
                                          (Econst_int (Int.repr 24) tint)
                                          tint)
                                        (Econst_int (Int.repr 31) tint) tint)))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'7
                                        (Efield
                                          (Ederef
                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _numCoins tshort))
                                      (Scall None
                                        (Evar _save_file_collect_star_or_key 
                                        (Tfunction (tshort :: tshort :: nil)
                                          tvoid cc_default))
                                        ((Etempvar _t'7 tshort) ::
                                         (Etempvar _starIndex tuint) :: nil)))
                                    (Ssequence
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'6
                                            (Evar _gCurrSaveFileNum tshort))
                                          (Scall (Some _t'1)
                                            (Evar _save_file_get_total_star_count 
                                            (Tfunction
                                              (tint :: tint :: tint :: nil)
                                              tint cc_default))
                                            ((Ebinop Osub
                                               (Etempvar _t'6 tshort)
                                               (Econst_int (Int.repr 1) tint)
                                               tint) ::
                                             (Ebinop Osub
                                               (Econst_int (Int.repr 1) tint)
                                               (Econst_int (Int.repr 1) tint)
                                               tint) ::
                                             (Ebinop Osub
                                               (Econst_int (Int.repr 25) tint)
                                               (Econst_int (Int.repr 1) tint)
                                               tint) :: nil)))
                                        (Sassign
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _numStars tshort)
                                          (Etempvar _t'1 tint)))
                                      (Ssequence
                                        (Sifthenelse (Eunop Onotbool
                                                       (Etempvar _noExit tuint)
                                                       tint)
                                          (Ssequence
                                            (Scall None
                                              (Evar _drop_queued_background_music 
                                              (Tfunction nil tvoid
                                                cc_default)) nil)
                                            (Scall None
                                              (Evar _fadeout_level_music 
                                              (Tfunction (tshort :: nil)
                                                tvoid cc_default))
                                              ((Econst_int (Int.repr 126) tint) ::
                                               nil)))
                                          Sskip)
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'5
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
                                                           (Econst_int (Int.repr 7) tint)
                                                           tuint)
                                                         (Econst_int (Int.repr 28) tint)
                                                         tuint)
                                                       (Ebinop Oshl
                                                         (Ecast
                                                           (Econst_int (Int.repr 30) tint)
                                                           tuint)
                                                         (Econst_int (Int.repr 16) tint)
                                                         tuint) tuint)
                                                     (Ebinop Oshl
                                                       (Ecast
                                                         (Econst_int (Int.repr 255) tint)
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
                                                       (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                                                       (Tstruct _Object noattr))
                                                     _header
                                                     (Tstruct _ObjectNode noattr))
                                                   _gfx
                                                   (Tstruct _GraphNodeObject noattr))
                                                 _cameraToObject
                                                 (tarray tfloat 3)) :: nil)))
                                          (Ssequence
                                            (Scall None
                                              (Evar _update_mario_sound_and_camera 
                                              (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tvoid cc_default))
                                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                               nil))
                                            (Ssequence
                                              (Sifthenelse (Etempvar _grandStar tuint)
                                                (Ssequence
                                                  (Scall (Some _t'2)
                                                    (Evar _set_mario_action 
                                                    (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: tuint :: nil)
                                                      tuint cc_default))
                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                     (Econst_int (Int.repr 6409) tint) ::
                                                     (Econst_int (Int.repr 0) tint) ::
                                                     nil))
                                                  (Sreturn (Some (Etempvar _t'2 tuint))))
                                                Sskip)
                                              (Ssequence
                                                (Scall (Some _t'3)
                                                  (Evar _set_mario_action 
                                                  (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                   (Etempvar _starGrabAction tuint) ::
                                                   (Ebinop Oadd
                                                     (Etempvar _noExit tuint)
                                                     (Ebinop Omul
                                                       (Econst_int (Int.repr 2) tint)
                                                       (Etempvar _grandStar tuint)
                                                       tuint) tuint) :: nil))
                                                (Sreturn (Some (Etempvar _t'3 tuint)))))))))))))))))))))
            Sskip))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_interact_bbh_entrance := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'6, tuint) :: (_t'5, tuint) :: (_t'4, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _action tuint))
      (Sifthenelse (Ebinop One (Etempvar _t'5 tuint)
                     (Econst_int (Int.repr 5429) tint) tint)
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _action tuint))
          (Sset _t'3
            (Ecast
              (Ebinop One (Etempvar _t'6 tuint)
                (Econst_int (Int.repr 6452) tint) tint) tbool)))
        (Sset _t'3 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'3 tint)
      (Ssequence
        (Scall None
          (Evar _mario_stop_riding_and_holding (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Ssequence
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asS32 (tarray tint 80))
                (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
              (Econst_int (Int.repr 15) tint) tint))
          (Ssequence
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _interactObj
                (tptr (Tstruct _Object noattr)))
              (Etempvar _o (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _usedObj
                  (tptr (Tstruct _Object noattr)))
                (Etempvar _o (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Ssequence
                  (Sset _t'4
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _action tuint))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'4 tuint)
                                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                   (Econst_int (Int.repr 11) tint) tint)
                                 tuint)
                    (Ssequence
                      (Scall (Some _t'1)
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 5429) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil))
                      (Sreturn (Some (Etempvar _t'1 tuint))))
                    Sskip))
                (Ssequence
                  (Scall (Some _t'2)
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 6452) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sreturn (Some (Etempvar _t'2 tuint)))))))))
      Sskip))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_interact_warp := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_action, tuint) :: (_t'7, tuint) :: (_t'6, tuint) ::
               (_t'5, (tptr tvoid)) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tuint) :: (_t'12, tuchar) ::
               (_t'11, (tptr tvoid)) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tuint) ::
               (_t'8, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
            _asU32 (tarray tuint 80)) (Econst_int (Int.repr 66) tint)
          (tptr tuint)) tuint))
    (Sifthenelse (Ebinop Oand (Etempvar _t'8 tuint)
                   (Econst_int (Int.repr 1) tint) tuint)
      (Ssequence
        (Sset _action
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _action tuint))
        (Sifthenelse (Ebinop Oeq (Etempvar _action tuint)
                       (Econst_int (Int.repr 4919) tint) tint)
          (Sassign (Evar _sJustTeleported tuchar)
            (Econst_int (Int.repr 1) tint))
          (Ssequence
            (Sset _t'12 (Evar _sJustTeleported tuchar))
            (Sifthenelse (Eunop Onotbool (Etempvar _t'12 tuchar) tint)
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sifthenelse (Ebinop Oeq (Etempvar _action tuint)
                                   (Econst_int (Int.repr 205521409) tint)
                                   tint)
                      (Sset _t'2 (Econst_int (Int.repr 1) tint))
                      (Sset _t'2
                        (Ecast
                          (Ebinop Oeq (Etempvar _action tuint)
                            (Econst_int (Int.repr 205521413) tint) tint)
                          tbool)))
                    (Sifthenelse (Etempvar _t'2 tint)
                      (Sset _t'3 (Econst_int (Int.repr 1) tint))
                      (Sset _t'3
                        (Ecast
                          (Ebinop Oeq (Etempvar _action tuint)
                            (Econst_int (Int.repr 205521417) tint) tint)
                          tbool))))
                  (Sifthenelse (Etempvar _t'3 tint)
                    (Sset _t'4 (Econst_int (Int.repr 1) tint))
                    (Sset _t'4
                      (Ecast
                        (Ebinop Oeq (Etempvar _action tuint)
                          (Econst_int (Int.repr 201359904) tint) tint) tbool))))
                (Sifthenelse (Etempvar _t'4 tint)
                  (Ssequence
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _interactObj
                        (tptr (Tstruct _Object noattr)))
                      (Etempvar _o (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _usedObj
                          (tptr (Tstruct _Object noattr)))
                        (Etempvar _o (tptr (Tstruct _Object noattr))))
                      (Ssequence
                        (Sassign (Evar _sJustTeleported tuchar)
                          (Econst_int (Int.repr 1) tint))
                        (Ssequence
                          (Scall (Some _t'1)
                            (Evar _set_mario_action (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: tuint :: nil)
                                                      tuint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 4918) tint) ::
                             (Econst_int (Int.repr 0) tint) :: nil))
                          (Sreturn (Some (Etempvar _t'1 tuint)))))))
                  Sskip))
              Sskip))))
      (Ssequence
        (Sset _t'9
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _action tuint))
        (Sifthenelse (Ebinop One (Etempvar _t'9 tuint)
                       (Econst_int (Int.repr 6435) tint) tint)
          (Ssequence
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __665 noattr)) _asS32 (tarray tint 80))
                  (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 15) tint) tint))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _interactObj
                  (tptr (Tstruct _Object noattr)))
                (Etempvar _o (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _usedObj
                    (tptr (Tstruct _Object noattr)))
                  (Etempvar _o (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'5)
                        (Evar _segmented_to_virtual (Tfunction
                                                      ((tptr tvoid) :: nil)
                                                      (tptr tvoid)
                                                      cc_default))
                        ((Evar _warp_pipe_seg3_collision_03009AC8 (tarray tshort 0)) ::
                         nil))
                      (Ssequence
                        (Sset _t'11
                          (Efield
                            (Ederef
                              (Etempvar _o (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _collisionData
                            (tptr tvoid)))
                        (Sifthenelse (Ebinop Oeq
                                       (Etempvar _t'11 (tptr tvoid))
                                       (Etempvar _t'5 (tptr tvoid)) tint)
                          (Sset _t'6
                            (Ecast
                              (Ebinop Oor
                                (Ebinop Oor
                                  (Ebinop Oor
                                    (Ebinop Oor
                                      (Ebinop Oshl
                                        (Ecast (Econst_int (Int.repr 7) tint)
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
                                      (Ecast (Econst_int (Int.repr 160) tint)
                                        tuint) (Econst_int (Int.repr 8) tint)
                                      tuint) tuint)
                                  (Econst_int (Int.repr 128) tint) tuint)
                                (Econst_int (Int.repr 1) tint) tuint) tuint))
                          (Sset _t'6
                            (Ecast
                              (Ebinop Oor
                                (Ebinop Oor
                                  (Ebinop Oor
                                    (Ebinop Oor
                                      (Ebinop Oshl
                                        (Ecast (Econst_int (Int.repr 7) tint)
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
                                      (Ecast (Econst_int (Int.repr 128) tint)
                                        tuint) (Econst_int (Int.repr 8) tint)
                                      tuint) tuint)
                                  (Ebinop Oor
                                    (Econst_int (Int.repr 16777216) tint)
                                    (Econst_int (Int.repr 128) tint) tint)
                                  tuint) (Econst_int (Int.repr 1) tint)
                                tuint) tuint)))))
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
                        ((Etempvar _t'6 tuint) ::
                         (Efield
                           (Efield
                             (Efield
                               (Ederef
                                 (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                                 (Tstruct _Object noattr)) _header
                               (Tstruct _ObjectNode noattr)) _gfx
                             (Tstruct _GraphNodeObject noattr))
                           _cameraToObject (tarray tfloat 3)) :: nil))))
                  (Ssequence
                    (Scall None
                      (Evar _mario_stop_riding_object (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tvoid
                                                        cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Ssequence
                      (Scall (Some _t'7)
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 4864) tint) ::
                         (Ebinop Oadd
                           (Ebinop Oshl (Econst_int (Int.repr 4) tint)
                             (Econst_int (Int.repr 16) tint) tint)
                           (Econst_int (Int.repr 2) tint) tint) :: nil))
                      (Sreturn (Some (Etempvar _t'7 tuint)))))))))
          Sskip))))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_interact_warp_door := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_doorAction, tuint) :: (_saveFlags, tuint) ::
               (_warpDoorId, tshort) :: (_actionArg, tuint) ::
               (_t'9, tint) :: (_t'8, tint) :: (_t'7, tuint) ::
               (_t'6, tuint) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tuint) ::
               (_t'16, tint) :: (_t'15, tuint) :: (_t'14, tuint) ::
               (_t'13, tuchar) :: (_t'12, tuchar) :: (_t'11, tuint) ::
               (_t'10, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _doorAction (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _save_file_get_flags (Tfunction nil tuint cc_default)) nil)
      (Sset _saveFlags (Etempvar _t'1 tuint)))
    (Ssequence
      (Ssequence
        (Sset _t'16
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 64) tint)
              (tptr tint)) tint))
        (Sset _warpDoorId
          (Ecast
            (Ebinop Oshr (Etempvar _t'16 tint)
              (Econst_int (Int.repr 24) tint) tint) tshort)))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'14
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _action tuint))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'14 tuint)
                           (Econst_int (Int.repr 67109952) tint) tint)
              (Sset _t'9 (Econst_int (Int.repr 1) tint))
              (Ssequence
                (Sset _t'15
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _action tuint))
                (Sset _t'9
                  (Ecast
                    (Ebinop Oeq (Etempvar _t'15 tuint)
                      (Econst_int (Int.repr 67109962) tint) tint) tbool)))))
          (Sifthenelse (Etempvar _t'9 tint)
            (Ssequence
              (Ssequence
                (Sifthenelse (Ebinop Oeq (Etempvar _warpDoorId tshort)
                               (Econst_int (Int.repr 1) tint) tint)
                  (Sset _t'3
                    (Ecast
                      (Eunop Onotbool
                        (Ebinop Oand (Etempvar _saveFlags tuint)
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 7) tint) tint) tuint) tint)
                      tbool))
                  (Sset _t'3 (Econst_int (Int.repr 0) tint)))
                (Sifthenelse (Etempvar _t'3 tint)
                  (Ssequence
                    (Sifthenelse (Eunop Onotbool
                                   (Ebinop Oand (Etempvar _saveFlags tuint)
                                     (Ebinop Oshl
                                       (Econst_int (Int.repr 1) tint)
                                       (Econst_int (Int.repr 5) tint) tint)
                                     tuint) tint)
                      (Ssequence
                        (Ssequence
                          (Sset _t'13 (Evar _sDisplayingDoorText tuchar))
                          (Sifthenelse (Eunop Onotbool
                                         (Etempvar _t'13 tuchar) tint)
                            (Ssequence
                              (Sifthenelse (Ebinop Oand
                                             (Etempvar _saveFlags tuint)
                                             (Ebinop Oshl
                                               (Econst_int (Int.repr 1) tint)
                                               (Econst_int (Int.repr 4) tint)
                                               tint) tuint)
                                (Sset _t'2
                                  (Ecast (Econst_int (Int.repr 23) tint)
                                    tint))
                                (Sset _t'2
                                  (Ecast (Econst_int (Int.repr 22) tint)
                                    tint)))
                              (Scall None
                                (Evar _set_mario_action (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           tuint :: tuint ::
                                                           nil) tuint
                                                          cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 (Econst_int (Int.repr 536875781) tint) ::
                                 (Etempvar _t'2 tint) :: nil)))
                            Sskip))
                        (Ssequence
                          (Sassign (Evar _sDisplayingDoorText tuchar)
                            (Econst_int (Int.repr 1) tint))
                          (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
                      Sskip)
                    (Sset _doorAction (Econst_int (Int.repr 4910) tint)))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sifthenelse (Ebinop Oeq (Etempvar _warpDoorId tshort)
                                 (Econst_int (Int.repr 2) tint) tint)
                    (Sset _t'5
                      (Ecast
                        (Eunop Onotbool
                          (Ebinop Oand (Etempvar _saveFlags tuint)
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 6) tint) tint) tuint)
                          tint) tbool))
                    (Sset _t'5 (Econst_int (Int.repr 0) tint)))
                  (Sifthenelse (Etempvar _t'5 tint)
                    (Ssequence
                      (Sifthenelse (Eunop Onotbool
                                     (Ebinop Oand (Etempvar _saveFlags tuint)
                                       (Ebinop Oshl
                                         (Econst_int (Int.repr 1) tint)
                                         (Econst_int (Int.repr 4) tint) tint)
                                       tuint) tint)
                        (Ssequence
                          (Ssequence
                            (Sset _t'12 (Evar _sDisplayingDoorText tuchar))
                            (Sifthenelse (Eunop Onotbool
                                           (Etempvar _t'12 tuchar) tint)
                              (Ssequence
                                (Sifthenelse (Ebinop Oand
                                               (Etempvar _saveFlags tuint)
                                               (Ebinop Oshl
                                                 (Econst_int (Int.repr 1) tint)
                                                 (Econst_int (Int.repr 5) tint)
                                                 tint) tuint)
                                  (Sset _t'4
                                    (Ecast (Econst_int (Int.repr 23) tint)
                                      tint))
                                  (Sset _t'4
                                    (Ecast (Econst_int (Int.repr 22) tint)
                                      tint)))
                                (Scall None
                                  (Evar _set_mario_action (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             tuint ::
                                                             tuint :: nil)
                                                            tuint cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   (Econst_int (Int.repr 536875781) tint) ::
                                   (Etempvar _t'4 tint) :: nil)))
                              Sskip))
                          (Ssequence
                            (Sassign (Evar _sDisplayingDoorText tuchar)
                              (Econst_int (Int.repr 1) tint))
                            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
                        Sskip)
                      (Sset _doorAction (Econst_int (Int.repr 4910) tint)))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sset _t'10
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _action tuint))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'10 tuint)
                                   (Econst_int (Int.repr 67109952) tint)
                                   tint)
                      (Sset _t'8 (Econst_int (Int.repr 1) tint))
                      (Ssequence
                        (Sset _t'11
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _action tuint))
                        (Sset _t'8
                          (Ecast
                            (Ebinop Oeq (Etempvar _t'11 tuint)
                              (Econst_int (Int.repr 67109962) tint) tint)
                            tbool)))))
                  (Sifthenelse (Etempvar _t'8 tint)
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'6)
                          (Evar _should_push_or_pull_door (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             (tptr (Tstruct _Object noattr)) ::
                                                             nil) tuint
                                                            cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Etempvar _o (tptr (Tstruct _Object noattr))) ::
                           nil))
                        (Sset _actionArg
                          (Ebinop Oadd (Etempvar _t'6 tuint)
                            (Econst_int (Int.repr 4) tint) tuint)))
                      (Ssequence
                        (Sifthenelse (Ebinop Oeq (Etempvar _doorAction tuint)
                                       (Econst_int (Int.repr 0) tint) tint)
                          (Sifthenelse (Ebinop Oand
                                         (Etempvar _actionArg tuint)
                                         (Econst_int (Int.repr 1) tint)
                                         tuint)
                            (Sset _doorAction
                              (Econst_int (Int.repr 4896) tint))
                            (Sset _doorAction
                              (Econst_int (Int.repr 4897) tint)))
                          Sskip)
                        (Ssequence
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _interactObj
                              (tptr (Tstruct _Object noattr)))
                            (Etempvar _o (tptr (Tstruct _Object noattr))))
                          (Ssequence
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _usedObj
                                (tptr (Tstruct _Object noattr)))
                              (Etempvar _o (tptr (Tstruct _Object noattr))))
                            (Ssequence
                              (Scall (Some _t'7)
                                (Evar _set_mario_action (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           tuint :: tuint ::
                                                           nil) tuint
                                                          cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 (Etempvar _doorAction tuint) ::
                                 (Etempvar _actionArg tuint) :: nil))
                              (Sreturn (Some (Etempvar _t'7 tuint))))))))
                    Sskip))))
            Sskip))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_get_door_save_file_flag := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_door, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_saveFileFlag, tuint) :: (_requiredNumStars, tshort) ::
               (_isCCMDoor, tshort) :: (_isPSSDoor, tshort) ::
               (_t'3, tint) :: (_t'2, tfloat) :: (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _saveFileFlag (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _door (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 64) tint)
            (tptr tint)) tint))
      (Sset _requiredNumStars
        (Ecast
          (Ebinop Oshr (Etempvar _t'3 tint) (Econst_int (Int.repr 24) tint)
            tint) tshort)))
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _door (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asF32 (tarray tfloat 80))
              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                (Econst_int (Int.repr 0) tint) tint) (tptr tfloat)) tfloat))
        (Sset _isCCMDoor
          (Ecast
            (Ebinop Olt (Etempvar _t'2 tfloat)
              (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) tint)
            tshort)))
      (Ssequence
        (Ssequence
          (Sset _t'1
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _door (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                  (Econst_int (Int.repr 1) tint) tint) (tptr tfloat)) tfloat))
          (Sset _isPSSDoor
            (Ecast
              (Ebinop Ogt (Etempvar _t'1 tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1140457472)) tfloat)
                tint) tshort)))
        (Ssequence
          (Sswitch (Etempvar _requiredNumStars tshort)
            (LScons (Some 1)
              (Ssequence
                (Sifthenelse (Etempvar _isPSSDoor tshort)
                  (Sset _saveFileFlag
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 10) tint) tint))
                  (Sset _saveFileFlag
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 11) tint) tint)))
                Sbreak)
              (LScons (Some 3)
                (Ssequence
                  (Sifthenelse (Etempvar _isCCMDoor tshort)
                    (Sset _saveFileFlag
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 12) tint) tint))
                    (Sset _saveFileFlag
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 13) tint) tint)))
                  Sbreak)
                (LScons (Some 8)
                  (Ssequence
                    (Sset _saveFileFlag
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 14) tint) tint))
                    Sbreak)
                  (LScons (Some 30)
                    (Ssequence
                      (Sset _saveFileFlag
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 15) tint) tint))
                      Sbreak)
                    (LScons (Some 50)
                      (Ssequence
                        (Sset _saveFileFlag
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 20) tint) tint))
                        Sbreak)
                      LSnil))))))
          (Sreturn (Some (Etempvar _saveFileFlag tuint))))))))
|}.

Definition f_interact_door := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_requiredNumStars, tshort) :: (_numStars, tshort) ::
               (_actionArg, tuint) :: (_enterDoorAction, tuint) ::
               (_doorSaveFileFlag, tuint) :: (_text, tuint) ::
               (_t'12, tint) :: (_t'11, tint) :: (_t'10, tint) ::
               (_t'9, tuint) :: (_t'8, tuint) :: (_t'7, tuint) ::
               (_t'6, tuint) :: (_t'5, tuint) :: (_t'4, tint) ::
               (_t'3, tuint) :: (_t'2, tuint) :: (_t'1, tint) ::
               (_t'20, tint) :: (_t'19, tshort) :: (_t'18, tuint) ::
               (_t'17, tuint) :: (_t'16, tuint) :: (_t'15, tuchar) ::
               (_t'14, tuchar) :: (_t'13, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'20
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
            _asS32 (tarray tint 80)) (Econst_int (Int.repr 64) tint)
          (tptr tint)) tint))
    (Sset _requiredNumStars
      (Ecast
        (Ebinop Oshr (Etempvar _t'20 tint) (Econst_int (Int.repr 24) tint)
          tint) tshort)))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'19 (Evar _gCurrSaveFileNum tshort))
        (Scall (Some _t'1)
          (Evar _save_file_get_total_star_count (Tfunction
                                                  (tint :: tint :: tint ::
                                                   nil) tint cc_default))
          ((Ebinop Osub (Etempvar _t'19 tshort)
             (Econst_int (Int.repr 1) tint) tint) ::
           (Ebinop Osub (Econst_int (Int.repr 1) tint)
             (Econst_int (Int.repr 1) tint) tint) ::
           (Ebinop Osub (Econst_int (Int.repr 25) tint)
             (Econst_int (Int.repr 1) tint) tint) :: nil)))
      (Sset _numStars (Ecast (Etempvar _t'1 tint) tshort)))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'17
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _action tuint))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'17 tuint)
                         (Econst_int (Int.repr 67109952) tint) tint)
            (Sset _t'12 (Econst_int (Int.repr 1) tint))
            (Ssequence
              (Sset _t'18
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _action tuint))
              (Sset _t'12
                (Ecast
                  (Ebinop Oeq (Etempvar _t'18 tuint)
                    (Econst_int (Int.repr 67109962) tint) tint) tbool)))))
        (Sifthenelse (Etempvar _t'12 tint)
          (Sifthenelse (Ebinop Oge (Etempvar _numStars tshort)
                         (Etempvar _requiredNumStars tshort) tint)
            (Ssequence
              (Ssequence
                (Scall (Some _t'2)
                  (Evar _should_push_or_pull_door (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     (tptr (Tstruct _Object noattr)) ::
                                                     nil) tuint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Etempvar _o (tptr (Tstruct _Object noattr))) :: nil))
                (Sset _actionArg (Etempvar _t'2 tuint)))
              (Ssequence
                (Sifthenelse (Ebinop Oand (Etempvar _actionArg tuint)
                               (Econst_int (Int.repr 1) tint) tuint)
                  (Sset _enterDoorAction (Econst_int (Int.repr 4896) tint))
                  (Sset _enterDoorAction (Econst_int (Int.repr 4897) tint)))
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'3)
                      (Evar _get_door_save_file_flag (Tfunction
                                                       ((tptr (Tstruct _Object noattr)) ::
                                                        nil) tuint
                                                       cc_default))
                      ((Etempvar _o (tptr (Tstruct _Object noattr))) :: nil))
                    (Sset _doorSaveFileFlag (Etempvar _t'3 tuint)))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _interactObj
                        (tptr (Tstruct _Object noattr)))
                      (Etempvar _o (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _usedObj
                          (tptr (Tstruct _Object noattr)))
                        (Etempvar _o (tptr (Tstruct _Object noattr))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'16
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _o (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __665 noattr)) _asU32
                                  (tarray tuint 80))
                                (Econst_int (Int.repr 66) tint) (tptr tuint))
                              tuint))
                          (Sifthenelse (Ebinop Oand (Etempvar _t'16 tuint)
                                         (Econst_int (Int.repr 32) tint)
                                         tuint)
                            (Sset _enterDoorAction
                              (Econst_int (Int.repr 4913) tint))
                            Sskip))
                        (Ssequence
                          (Ssequence
                            (Sifthenelse (Ebinop One
                                           (Etempvar _doorSaveFileFlag tuint)
                                           (Econst_int (Int.repr 0) tint)
                                           tint)
                              (Ssequence
                                (Scall (Some _t'5)
                                  (Evar _save_file_get_flags (Tfunction nil
                                                               tuint
                                                               cc_default))
                                  nil)
                                (Sset _t'4
                                  (Ecast
                                    (Eunop Onotbool
                                      (Ebinop Oand (Etempvar _t'5 tuint)
                                        (Etempvar _doorSaveFileFlag tuint)
                                        tuint) tint) tbool)))
                              (Sset _t'4 (Econst_int (Int.repr 0) tint)))
                            (Sifthenelse (Etempvar _t'4 tint)
                              (Sset _enterDoorAction
                                (Econst_int (Int.repr 4911) tint))
                              Sskip))
                          (Ssequence
                            (Scall (Some _t'6)
                              (Evar _set_mario_action (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         tuint :: tuint ::
                                                         nil) tuint
                                                        cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Etempvar _enterDoorAction tuint) ::
                               (Etempvar _actionArg tuint) :: nil))
                            (Sreturn (Some (Etempvar _t'6 tuint)))))))))))
            (Ssequence
              (Sset _t'15 (Evar _sDisplayingDoorText tuchar))
              (Sifthenelse (Eunop Onotbool (Etempvar _t'15 tuchar) tint)
                (Ssequence
                  (Sset _text
                    (Ebinop Oshl (Econst_int (Int.repr 22) tint)
                      (Econst_int (Int.repr 16) tint) tint))
                  (Ssequence
                    (Sswitch (Etempvar _requiredNumStars tshort)
                      (LScons (Some 1)
                        (Ssequence
                          (Sset _text
                            (Ebinop Oshl (Econst_int (Int.repr 24) tint)
                              (Econst_int (Int.repr 16) tint) tint))
                          Sbreak)
                        (LScons (Some 3)
                          (Ssequence
                            (Sset _text
                              (Ebinop Oshl (Econst_int (Int.repr 25) tint)
                                (Econst_int (Int.repr 16) tint) tint))
                            Sbreak)
                          (LScons (Some 8)
                            (Ssequence
                              (Sset _text
                                (Ebinop Oshl (Econst_int (Int.repr 26) tint)
                                  (Econst_int (Int.repr 16) tint) tint))
                              Sbreak)
                            (LScons (Some 30)
                              (Ssequence
                                (Sset _text
                                  (Ebinop Oshl
                                    (Econst_int (Int.repr 27) tint)
                                    (Econst_int (Int.repr 16) tint) tint))
                                Sbreak)
                              (LScons (Some 50)
                                (Ssequence
                                  (Sset _text
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 28) tint)
                                      (Econst_int (Int.repr 16) tint) tint))
                                  Sbreak)
                                (LScons (Some 70)
                                  (Ssequence
                                    (Sset _text
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 29) tint)
                                        (Econst_int (Int.repr 16) tint) tint))
                                    Sbreak)
                                  LSnil)))))))
                    (Ssequence
                      (Sset _text
                        (Ebinop Oadd (Etempvar _text tuint)
                          (Ebinop Osub (Etempvar _requiredNumStars tshort)
                            (Etempvar _numStars tshort) tint) tuint))
                      (Ssequence
                        (Sassign (Evar _sDisplayingDoorText tuchar)
                          (Econst_int (Int.repr 1) tint))
                        (Ssequence
                          (Scall (Some _t'7)
                            (Evar _set_mario_action (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: tuint :: nil)
                                                      tuint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 536875781) tint) ::
                             (Etempvar _text tuint) :: nil))
                          (Sreturn (Some (Etempvar _t'7 tuint))))))))
                Sskip)))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'13
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _action tuint))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'13 tuint)
                               (Econst_int (Int.repr 205521409) tint) tint)
                  (Ssequence
                    (Sset _t'14 (Evar _sDisplayingDoorText tuchar))
                    (Sset _t'10
                      (Ecast
                        (Ebinop Oeq (Etempvar _t'14 tuchar)
                          (Econst_int (Int.repr 1) tint) tint) tbool)))
                  (Sset _t'10 (Econst_int (Int.repr 0) tint))))
              (Sifthenelse (Etempvar _t'10 tint)
                (Sset _t'11
                  (Ecast
                    (Ebinop Oeq (Etempvar _requiredNumStars tshort)
                      (Econst_int (Int.repr 70) tint) tint) tbool))
                (Sset _t'11 (Econst_int (Int.repr 0) tint))))
            (Sifthenelse (Etempvar _t'11 tint)
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _interactObj
                    (tptr (Tstruct _Object noattr)))
                  (Etempvar _o (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _usedObj
                      (tptr (Tstruct _Object noattr)))
                    (Etempvar _o (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'8)
                        (Evar _should_push_or_pull_door (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           (tptr (Tstruct _Object noattr)) ::
                                                           nil) tuint
                                                          cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Etempvar _o (tptr (Tstruct _Object noattr))) ::
                         nil))
                      (Scall (Some _t'9)
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 4913) tint) ::
                         (Etempvar _t'8 tuint) :: nil)))
                    (Sreturn (Some (Etempvar _t'9 tuint))))))
              Sskip))))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_interact_cannon_base := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: (_t'2, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _action tuint))
    (Sifthenelse (Ebinop One (Etempvar _t'2 tuint)
                   (Econst_int (Int.repr 4977) tint) tint)
      (Ssequence
        (Scall None
          (Evar _mario_stop_riding_and_holding (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Ssequence
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asS32 (tarray tint 80))
                (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
              (Econst_int (Int.repr 15) tint) tint))
          (Ssequence
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _interactObj
                (tptr (Tstruct _Object noattr)))
              (Etempvar _o (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _usedObj
                  (tptr (Tstruct _Object noattr)))
                (Etempvar _o (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Scall (Some _t'1)
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 4977) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                (Sreturn (Some (Etempvar _t'1 tuint))))))))
      Sskip))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_interact_igloo_barrier := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sassign
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _interactObj
      (tptr (Tstruct _Object noattr)))
    (Etempvar _o (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Sassign
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _usedObj
        (tptr (Tstruct _Object noattr)))
      (Etempvar _o (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Scall None
        (Evar _push_mario_out_of_object (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           (tptr (Tstruct _Object noattr)) ::
                                           tfloat :: nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Etempvar _o (tptr (Tstruct _Object noattr))) ::
         (Econst_single (Float32.of_bits (Int.repr 1084227584)) tfloat) ::
         nil))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_interact_tornado := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_t'2, tint) :: (_t'1, tuint) :: (_t'8, tuint) ::
               (_t'7, tuint) :: (_t'6, tfloat) :: (_t'5, tfloat) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: (_t'3, tuint) ::
               nil);
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
        (Sset _t'7
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _action tuint))
        (Sifthenelse (Ebinop One (Etempvar _t'7 tuint)
                       (Econst_int (Int.repr 268567410) tint) tint)
          (Ssequence
            (Sset _t'8
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _action tuint))
            (Sset _t'2
              (Ecast
                (Ebinop One (Etempvar _t'8 tuint)
                  (Econst_int (Int.repr 131897) tint) tint) tbool)))
          (Sset _t'2 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'2 tint)
        (Ssequence
          (Scall None
            (Evar _mario_stop_riding_and_holding (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Scall None
              (Evar _mario_set_forward_vel (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tfloat :: nil) tvoid
                                             cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) :: nil))
            (Ssequence
              (Scall None
                (Evar _update_mario_sound_and_camera (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        nil) tvoid
                                                       cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Ssequence
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _o (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asS32 (tarray tint 80))
                      (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 15) tint) tint))
                (Ssequence
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _interactObj
                      (tptr (Tstruct _Object noattr)))
                    (Etempvar _o (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _usedObj
                        (tptr (Tstruct _Object noattr)))
                      (Etempvar _o (tptr (Tstruct _Object noattr))))
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
                            (Econst_int (Int.repr 33) tint) (tptr tint))
                          tint) (Econst_int (Int.repr 1024) tint))
                      (Ssequence
                        (Ssequence
                          (Sset _t'5
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
                            (Sset _t'6
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _o (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _rawData
                                      (Tunion __665 noattr)) _asF32
                                    (tarray tfloat 80))
                                  (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  (tptr tfloat)) tfloat))
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
                              (Ebinop Osub (Etempvar _t'5 tfloat)
                                (Etempvar _t'6 tfloat) tfloat))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'4
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
                                           (Econst_int (Int.repr 16) tint)
                                           tuint)
                                         (Econst_int (Int.repr 16) tint)
                                         tuint) tuint)
                                     (Ebinop Oshl
                                       (Ecast
                                         (Econst_int (Int.repr 192) tint)
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
                                       (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                                       (Tstruct _Object noattr)) _header
                                     (Tstruct _ObjectNode noattr)) _gfx
                                   (Tstruct _GraphNodeObject noattr))
                                 _cameraToObject (tarray tfloat 3)) :: nil)))
                          (Ssequence
                            (Ssequence
                              (Sset _t'3
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _action
                                  tuint))
                              (Scall (Some _t'1)
                                (Evar _set_mario_action (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           tuint :: tuint ::
                                                           nil) tuint
                                                          cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 (Econst_int (Int.repr 268567410) tint) ::
                                 (Ebinop Oeq (Etempvar _t'3 tuint)
                                   (Econst_int (Int.repr 276826276) tint)
                                   tint) :: nil)))
                            (Sreturn (Some (Etempvar _t'1 tuint)))))))))))))
        Sskip))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_interact_whirlpool := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_t'1, tuint) :: (_t'5, tfloat) :: (_t'4, tfloat) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: (_t'2, tuint) ::
               nil);
  fn_body :=
(Ssequence
  (Sset _marioObj
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _action tuint))
      (Sifthenelse (Ebinop One (Etempvar _t'2 tuint)
                     (Econst_int (Int.repr 805446371) tint) tint)
        (Ssequence
          (Scall None
            (Evar _mario_stop_riding_and_holding (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __665 noattr)) _asS32 (tarray tint 80))
                  (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 15) tint) tint))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _interactObj
                  (tptr (Tstruct _Object noattr)))
                (Etempvar _o (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _usedObj
                    (tptr (Tstruct _Object noattr)))
                  (Etempvar _o (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                  (Ssequence
                    (Ssequence
                      (Sset _t'4
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
                        (Sset _t'5
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _o (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __665 noattr)) _asF32
                                (tarray tfloat 80))
                              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                                (Econst_int (Int.repr 1) tint) tint)
                              (tptr tfloat)) tfloat))
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
                              (Econst_int (Int.repr 34) tint) (tptr tfloat))
                            tfloat)
                          (Ebinop Osub (Etempvar _t'4 tfloat)
                            (Etempvar _t'5 tfloat) tfloat))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'3
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
                                     (Ecast (Econst_int (Int.repr 16) tint)
                                       tuint) (Econst_int (Int.repr 16) tint)
                                     tuint) tuint)
                                 (Ebinop Oshl
                                   (Ecast (Econst_int (Int.repr 192) tint)
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
                                   (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                                   (Tstruct _Object noattr)) _header
                                 (Tstruct _ObjectNode noattr)) _gfx
                               (Tstruct _GraphNodeObject noattr))
                             _cameraToObject (tarray tfloat 3)) :: nil)))
                      (Ssequence
                        (Scall (Some _t'1)
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 805446371) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))
                        (Sreturn (Some (Etempvar _t'1 tuint)))))))))))
        Sskip))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_interact_strong_wind := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_t'1, tuint) :: (_t'4, tint) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: (_t'2, tuint) ::
               nil);
  fn_body :=
(Ssequence
  (Sset _marioObj
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _action tuint))
      (Sifthenelse (Ebinop One (Etempvar _t'2 tuint)
                     (Econst_int (Int.repr 16910520) tint) tint)
        (Ssequence
          (Scall None
            (Evar _mario_stop_riding_and_holding (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __665 noattr)) _asS32 (tarray tint 80))
                  (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 15) tint) tint))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _interactObj
                  (tptr (Tstruct _Object noattr)))
                (Etempvar _o (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _usedObj
                    (tptr (Tstruct _Object noattr)))
                  (Etempvar _o (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Ssequence
                    (Sset _t'4
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _o (tptr (Tstruct _Object noattr)))
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
                          (tptr tshort)) tshort)
                      (Ebinop Oadd (Etempvar _t'4 tint)
                        (Econst_int (Int.repr 32768) tint) tint)))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _gettingBlownGravity
                        tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1053609165)) tfloat))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _forwardVel tfloat)
                        (Eunop Oneg
                          (Econst_single (Float32.of_bits (Int.repr 1103101952)) tfloat)
                          tfloat))
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
                          (Econst_single (Float32.of_bits (Int.repr 1094713344)) tfloat))
                        (Ssequence
                          (Ssequence
                            (Sset _t'3
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
                                           (Econst_int (Int.repr 16) tint)
                                           tuint)
                                         (Econst_int (Int.repr 16) tint)
                                         tuint) tuint)
                                     (Ebinop Oshl
                                       (Ecast
                                         (Econst_int (Int.repr 192) tint)
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
                                       (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                                       (Tstruct _Object noattr)) _header
                                     (Tstruct _ObjectNode noattr)) _gfx
                                   (Tstruct _GraphNodeObject noattr))
                                 _cameraToObject (tarray tfloat 3)) :: nil)))
                          (Ssequence
                            (Scall None
                              (Evar _update_mario_sound_and_camera (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               nil))
                            (Ssequence
                              (Scall (Some _t'1)
                                (Evar _set_mario_action (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           tuint :: tuint ::
                                                           nil) tuint
                                                          cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 (Econst_int (Int.repr 16910520) tint) ::
                                 (Econst_int (Int.repr 0) tint) :: nil))
                              (Sreturn (Some (Etempvar _t'1 tuint))))))))))))))
        Sskip))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_interact_flame := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_burningAction, tuint) :: (_t'6, tint) :: (_t'5, tint) ::
               (_t'4, tint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'18, tuint) :: (_t'17, tshort) ::
               (_t'16, tuint) :: (_t'15, tuint) :: (_t'14, tfloat) ::
               (_t'13, tshort) :: (_t'12, tuint) ::
               (_t'11, (tptr (Tstruct _Object noattr))) ::
               (_t'10, (tptr (Tstruct _Object noattr))) ::
               (_t'9, (tptr (Tstruct _Object noattr))) :: (_t'8, tfloat) ::
               (_t'7, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _burningAction (Econst_int (Int.repr 16910516) tint))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'17 (Evar _sInvulnerable tshort))
            (Sifthenelse (Eunop Onotbool (Etempvar _t'17 tshort) tint)
              (Ssequence
                (Sset _t'18
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _flags tuint))
                (Sset _t'4
                  (Ecast
                    (Eunop Onotbool
                      (Ebinop Oand (Etempvar _t'18 tuint)
                        (Econst_int (Int.repr 4) tint) tuint) tint) tbool)))
              (Sset _t'4 (Econst_int (Int.repr 0) tint))))
          (Sifthenelse (Etempvar _t'4 tint)
            (Ssequence
              (Sset _t'16
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _flags tuint))
              (Sset _t'5
                (Ecast
                  (Eunop Onotbool
                    (Ebinop Oand (Etempvar _t'16 tuint)
                      (Econst_int (Int.repr 2) tint) tuint) tint) tbool)))
            (Sset _t'5 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'5 tint)
          (Ssequence
            (Sset _t'15
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __665 noattr)) _asU32 (tarray tuint 80))
                  (Econst_int (Int.repr 66) tint) (tptr tuint)) tuint))
            (Sset _t'6
              (Ecast
                (Eunop Onotbool
                  (Ebinop Oand (Etempvar _t'15 tuint)
                    (Econst_int (Int.repr 2) tint) tuint) tint) tbool)))
          (Sset _t'6 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'6 tint)
        (Ssequence
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asS32 (tarray tint 80))
                (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
              (Econst_int (Int.repr 15) tint) tint))
          (Ssequence
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _interactObj
                (tptr (Tstruct _Object noattr)))
              (Etempvar _o (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Ssequence
                (Sset _t'12
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _action tuint))
                (Sifthenelse (Ebinop Oand (Etempvar _t'12 tuint)
                               (Ebinop Oor
                                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                   (Econst_int (Int.repr 13) tint) tint)
                                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                   (Econst_int (Int.repr 14) tint) tint)
                                 tint) tuint)
                  (Sset _t'3 (Econst_int (Int.repr 1) tint))
                  (Ssequence
                    (Sset _t'13
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _waterLevel tshort))
                    (Ssequence
                      (Sset _t'14
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _pos
                              (tarray tfloat 3))
                            (Econst_int (Int.repr 1) tint) (tptr tfloat))
                          tfloat))
                      (Sset _t'3
                        (Ecast
                          (Ebinop Ogt
                            (Ebinop Osub (Etempvar _t'13 tshort)
                              (Etempvar _t'14 tfloat) tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat)
                            tint) tbool))))))
              (Sifthenelse (Etempvar _t'3 tint)
                (Ssequence
                  (Sset _t'11
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
                             (Etempvar _t'11 (tptr (Tstruct _Object noattr)))
                             (Tstruct _Object noattr)) _header
                           (Tstruct _ObjectNode noattr)) _gfx
                         (Tstruct _GraphNodeObject noattr)) _cameraToObject
                       (tarray tfloat 3)) :: nil)))
                (Ssequence
                  (Ssequence
                    (Sset _t'10
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
                                (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __665 noattr)) _asS32 (tarray tint 80))
                          (Econst_int (Int.repr 34) tint) (tptr tint)) tint)
                      (Econst_int (Int.repr 0) tint)))
                  (Ssequence
                    (Scall None
                      (Evar _update_mario_sound_and_camera (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              nil) tvoid
                                                             cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Ssequence
                      (Ssequence
                        (Sset _t'9
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
                                     (Ecast (Econst_int (Int.repr 20) tint)
                                       tuint) (Econst_int (Int.repr 16) tint)
                                     tuint) tuint)
                                 (Ebinop Oshl
                                   (Ecast (Econst_int (Int.repr 160) tint)
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
                                   (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                                   (Tstruct _Object noattr)) _header
                                 (Tstruct _ObjectNode noattr)) _gfx
                               (Tstruct _GraphNodeObject noattr))
                             _cameraToObject (tarray tfloat 3)) :: nil)))
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'7
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _action
                                tuint))
                            (Sifthenelse (Ebinop Oand (Etempvar _t'7 tuint)
                                           (Ebinop Oshl
                                             (Econst_int (Int.repr 1) tint)
                                             (Econst_int (Int.repr 11) tint)
                                             tint) tuint)
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
                                (Sset _t'1
                                  (Ecast
                                    (Ebinop Ole (Etempvar _t'8 tfloat)
                                      (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                      tint) tbool)))
                              (Sset _t'1 (Econst_int (Int.repr 0) tint))))
                          (Sifthenelse (Etempvar _t'1 tint)
                            (Sset _burningAction
                              (Econst_int (Int.repr 16910517) tint))
                            Sskip))
                        (Ssequence
                          (Scall (Some _t'2)
                            (Evar _drop_and_set_mario_action (Tfunction
                                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                                tuint ::
                                                                tuint :: nil)
                                                               tint
                                                               cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Etempvar _burningAction tuint) ::
                             (Econst_int (Int.repr 1) tint) :: nil))
                          (Sreturn (Some (Etempvar _t'2 tint))))))))))))
        Sskip))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_interact_snufit_bullet := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tuint) ::
               (_t'11, tuint) :: (_t'10, tshort) ::
               (_t'9, (tptr (Tstruct _Object noattr))) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tint) ::
               (_t'6, tint) :: (_t'5, tuint) :: (_t'4, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'10 (Evar _sInvulnerable tshort))
      (Sifthenelse (Eunop Onotbool (Etempvar _t'10 tshort) tint)
        (Ssequence
          (Sset _t'11
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _flags tuint))
          (Sset _t'3
            (Ecast
              (Eunop Onotbool
                (Ebinop Oand (Etempvar _t'11 tuint)
                  (Econst_int (Int.repr 2) tint) tuint) tint) tbool)))
        (Sset _t'3 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'3 tint)
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _flags tuint))
        (Sifthenelse (Ebinop Oand (Etempvar _t'5 tuint)
                       (Econst_int (Int.repr 4) tint) tuint)
          (Ssequence
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __665 noattr)) _asS32 (tarray tint 80))
                  (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
              (Ebinop Oor
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 15) tint) tint)
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 14) tint) tint) tint))
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
                           (Ecast (Econst_int (Int.repr 0) tint) tuint)
                           (Econst_int (Int.repr 28) tint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 88) tint) tuint)
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
                         (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                         (Tstruct _Object noattr)) _header
                       (Tstruct _ObjectNode noattr)) _gfx
                     (Tstruct _GraphNodeObject noattr)) _cameraToObject
                   (tarray tfloat 3)) :: nil))))
          (Ssequence
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __665 noattr)) _asS32 (tarray tint 80))
                  (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
              (Ebinop Oor
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 15) tint) tint)
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 13) tint) tint) tint))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _interactObj
                  (tptr (Tstruct _Object noattr)))
                (Etempvar _o (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Scall None
                  (Evar _take_damage_from_interact_object (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             nil) tuint
                                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Ssequence
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
                                 (Ecast (Econst_int (Int.repr 2) tint) tuint)
                                 (Econst_int (Int.repr 28) tint) tuint)
                               (Ebinop Oshl
                                 (Ecast (Econst_int (Int.repr 10) tint)
                                   tuint) (Econst_int (Int.repr 16) tint)
                                 tuint) tuint)
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
                               (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                               (Tstruct _Object noattr)) _header
                             (Tstruct _ObjectNode noattr)) _gfx
                           (Tstruct _GraphNodeObject noattr)) _cameraToObject
                         (tarray tfloat 3)) :: nil)))
                  (Ssequence
                    (Scall None
                      (Evar _update_mario_sound_and_camera (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              nil) tvoid
                                                             cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'7
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _o (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __665 noattr)) _asS32
                                  (tarray tint 80))
                                (Econst_int (Int.repr 62) tint) (tptr tint))
                              tint))
                          (Scall (Some _t'1)
                            (Evar _determine_knockback_action (Tfunction
                                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                                 tint :: nil)
                                                                tuint
                                                                cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Etempvar _t'7 tint) :: nil)))
                        (Ssequence
                          (Sset _t'6
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _o (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __665 noattr)) _asS32
                                  (tarray tint 80))
                                (Econst_int (Int.repr 62) tint) (tptr tint))
                              tint))
                          (Scall (Some _t'2)
                            (Evar _drop_and_set_mario_action (Tfunction
                                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                                tuint ::
                                                                tuint :: nil)
                                                               tint
                                                               cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Etempvar _t'1 tuint) :: (Etempvar _t'6 tint) ::
                             nil))))
                      (Sreturn (Some (Etempvar _t'2 tint)))))))))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'4
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asU32 (tarray tuint 80)) (Econst_int (Int.repr 66) tint)
            (tptr tuint)) tuint))
      (Sifthenelse (Eunop Onotbool
                     (Ebinop Oand (Etempvar _t'4 tuint)
                       (Econst_int (Int.repr 2) tint) tuint) tint)
        (Sassign (Evar _sDelayInvincTimer tuchar)
          (Econst_int (Int.repr 1) tint))
        Sskip))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_interact_clam_or_bubba := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tuint) :: (_t'1, tuint) :: (_t'4, tuint) ::
               (_t'3, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
            _asU32 (tarray tuint 80)) (Econst_int (Int.repr 66) tint)
          (tptr tuint)) tuint))
    (Sifthenelse (Ebinop Oand (Etempvar _t'4 tuint)
                   (Econst_int (Int.repr 8192) tint) tuint)
      (Ssequence
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
              (tptr tint)) tint)
          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
            (Econst_int (Int.repr 15) tint) tint))
        (Ssequence
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _interactObj
              (tptr (Tstruct _Object noattr)))
            (Etempvar _o (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Scall (Some _t'1)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 135959) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'1 tuint))))))
      (Ssequence
        (Scall (Some _t'2)
          (Evar _take_damage_and_knock_back (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               (tptr (Tstruct _Object noattr)) ::
                                               nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Etempvar _o (tptr (Tstruct _Object noattr))) :: nil))
        (Sifthenelse (Etempvar _t'2 tuint)
          (Sreturn (Some (Econst_int (Int.repr 1) tint)))
          Sskip))))
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asU32 (tarray tuint 80)) (Econst_int (Int.repr 66) tint)
            (tptr tuint)) tuint))
      (Sifthenelse (Eunop Onotbool
                     (Ebinop Oand (Etempvar _t'3 tuint)
                       (Econst_int (Int.repr 2) tint) tuint) tint)
        (Sassign (Evar _sDelayInvincTimer tuchar)
          (Econst_int (Int.repr 1) tint))
        Sskip))
    (Sreturn (Some (Econst_int (Int.repr 1) tint)))))
|}.

Definition f_interact_bully := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := ((_filler, (tarray tuchar 4)) :: nil);
  fn_temps := ((_interaction, tuint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tuint) :: (_t'1, tuint) :: (_t'12, tuint) ::
               (_t'11, tshort) :: (_t'10, tfloat) :: (_t'9, tuint) ::
               (_t'8, tshort) :: (_t'7, tuint) ::
               (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'12
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sifthenelse (Ebinop Oand (Etempvar _t'12 tuint)
                   (Econst_int (Int.repr 4) tint) tuint)
      (Sset _interaction
        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
          (Econst_int (Int.repr 5) tint) tint))
      (Ssequence
        (Scall (Some _t'1)
          (Evar _determine_interaction (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          (tptr (Tstruct _Object noattr)) ::
                                          nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Etempvar _o (tptr (Tstruct _Object noattr))) :: nil))
        (Sset _interaction (Etempvar _t'1 tuint)))))
  (Ssequence
    (Sassign
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _interactObj
        (tptr (Tstruct _Object noattr)))
      (Etempvar _o (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sifthenelse (Ebinop Oand (Etempvar _interaction tuint)
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                   (Econst_int (Int.repr 0) tint) tint)
                                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                   (Econst_int (Int.repr 1) tint) tint) tint)
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 2) tint) tint) tint)
                             (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                               (Econst_int (Int.repr 3) tint) tint) tint)
                           (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                             (Econst_int (Int.repr 4) tint) tint) tint)
                         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 5) tint) tint) tint)
                       (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 6) tint) tint) tint) tuint)
        (Ssequence
          (Scall None
            (Evar _push_mario_out_of_object (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               (tptr (Tstruct _Object noattr)) ::
                                               tfloat :: nil) tvoid
                                              cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _o (tptr (Tstruct _Object noattr))) ::
             (Econst_single (Float32.of_bits (Int.repr 1084227584)) tfloat) ::
             nil))
          (Ssequence
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat)
              (Eunop Oneg
                (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                tfloat))
            (Ssequence
              (Ssequence
                (Sset _t'11
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
                        (Efield
                          (Ederef
                            (Etempvar _o (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asS32 (tarray tint 80))
                      (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                        (Econst_int (Int.repr 1) tint) tint) (tptr tint))
                    tint) (Etempvar _t'11 tshort)))
              (Ssequence
                (Ssequence
                  (Sset _t'10
                    (Efield
                      (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _hitboxRadius tfloat))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _o (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                        (Econst_int (Int.repr 12) tint) (tptr tfloat))
                      tfloat)
                    (Ebinop Odiv
                      (Econst_single (Float32.of_bits (Int.repr 1163132928)) tfloat)
                      (Etempvar _t'10 tfloat) tfloat)))
                (Ssequence
                  (Scall None
                    (Evar _attack_object (Tfunction
                                           ((tptr (Tstruct _Object noattr)) ::
                                            tint :: nil) tuint cc_default))
                    ((Etempvar _o (tptr (Tstruct _Object noattr))) ::
                     (Etempvar _interaction tuint) :: nil))
                  (Ssequence
                    (Scall None
                      (Evar _bounce_back_from_attack (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tuint :: nil) tvoid
                                                       cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Etempvar _interaction tuint) :: nil))
                    (Sreturn (Some (Econst_int (Int.repr 1) tint)))))))))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'8 (Evar _sInvulnerable tshort))
              (Sifthenelse (Eunop Onotbool (Etempvar _t'8 tshort) tint)
                (Ssequence
                  (Sset _t'9
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _flags tuint))
                  (Sset _t'3
                    (Ecast
                      (Eunop Onotbool
                        (Ebinop Oand (Etempvar _t'9 tuint)
                          (Econst_int (Int.repr 2) tint) tuint) tint) tbool)))
                (Sset _t'3 (Econst_int (Int.repr 0) tint))))
            (Sifthenelse (Etempvar _t'3 tint)
              (Ssequence
                (Sset _t'7
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _o (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asU32 (tarray tuint 80))
                      (Econst_int (Int.repr 66) tint) (tptr tuint)) tuint))
                (Sset _t'4
                  (Ecast
                    (Eunop Onotbool
                      (Ebinop Oand (Etempvar _t'7 tuint)
                        (Econst_int (Int.repr 2) tint) tuint) tint) tbool)))
              (Sset _t'4 (Econst_int (Int.repr 0) tint))))
          (Sifthenelse (Etempvar _t'4 tint)
            (Ssequence
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __665 noattr)) _asS32 (tarray tint 80))
                    (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 15) tint) tint))
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _invincTimer tshort)
                  (Econst_int (Int.repr 2) tint))
                (Ssequence
                  (Scall None
                    (Evar _update_mario_sound_and_camera (Tfunction
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
                                   (Ecast (Econst_int (Int.repr 9) tint)
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
                                 (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                                 (Tstruct _Object noattr)) _header
                               (Tstruct _ObjectNode noattr)) _gfx
                             (Tstruct _GraphNodeObject noattr))
                           _cameraToObject (tarray tfloat 3)) :: nil)))
                    (Ssequence
                      (Ssequence
                        (Sset _t'5
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
                                     (Ecast (Econst_int (Int.repr 5) tint)
                                       tuint) (Econst_int (Int.repr 28) tint)
                                     tuint)
                                   (Ebinop Oshl
                                     (Ecast (Econst_int (Int.repr 23) tint)
                                       tuint) (Econst_int (Int.repr 16) tint)
                                     tuint) tuint)
                                 (Ebinop Oshl
                                   (Ecast (Econst_int (Int.repr 128) tint)
                                     tuint) (Econst_int (Int.repr 8) tint)
                                   tuint) tuint)
                               (Econst_int (Int.repr 128) tint) tuint)
                             (Econst_int (Int.repr 1) tint) tuint) ::
                           (Efield
                             (Efield
                               (Efield
                                 (Ederef
                                   (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                                   (Tstruct _Object noattr)) _header
                                 (Tstruct _ObjectNode noattr)) _gfx
                               (Tstruct _GraphNodeObject noattr))
                             _cameraToObject (tarray tfloat 3)) :: nil)))
                      (Ssequence
                        (Scall None
                          (Evar _push_mario_out_of_object (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             (tptr (Tstruct _Object noattr)) ::
                                                             tfloat :: nil)
                                                            tvoid cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Etempvar _o (tptr (Tstruct _Object noattr))) ::
                           (Econst_single (Float32.of_bits (Int.repr 1084227584)) tfloat) ::
                           nil))
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'2)
                              (Evar _bully_knock_back_mario (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               nil) tuint
                                                              cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               nil))
                            (Scall None
                              (Evar _drop_and_set_mario_action (Tfunction
                                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                                  tuint ::
                                                                  tuint ::
                                                                  nil) tint
                                                                 cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Etempvar _t'2 tuint) ::
                               (Econst_int (Int.repr 0) tint) :: nil)))
                          (Sreturn (Some (Econst_int (Int.repr 1) tint))))))))))
            Sskip)))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_interact_shock := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_actionArg, tuint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'11, tuint) ::
               (_t'10, tshort) :: (_t'9, tuint) :: (_t'8, tuint) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tuint) ::
               (_t'5, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'10 (Evar _sInvulnerable tshort))
        (Sifthenelse (Eunop Onotbool (Etempvar _t'10 tshort) tint)
          (Ssequence
            (Sset _t'11
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _flags tuint))
            (Sset _t'3
              (Ecast
                (Eunop Onotbool
                  (Ebinop Oand (Etempvar _t'11 tuint)
                    (Econst_int (Int.repr 2) tint) tuint) tint) tbool)))
          (Sset _t'3 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'3 tint)
        (Ssequence
          (Sset _t'9
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asU32 (tarray tuint 80))
                (Econst_int (Int.repr 66) tint) (tptr tuint)) tuint))
          (Sset _t'4
            (Ecast
              (Eunop Onotbool
                (Ebinop Oand (Etempvar _t'9 tuint)
                  (Econst_int (Int.repr 2) tint) tuint) tint) tbool)))
        (Sset _t'4 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'4 tint)
      (Ssequence
        (Ssequence
          (Sset _t'8
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _action tuint))
          (Sset _actionArg
            (Ebinop Oeq
              (Ebinop Oand (Etempvar _t'8 tuint)
                (Ebinop Oor
                  (Ebinop Oor
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 11) tint) tint)
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 20) tint) tint) tint)
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 21) tint) tint) tint) tuint)
              (Econst_int (Int.repr 0) tint) tint)))
        (Ssequence
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asS32 (tarray tint 80))
                (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
            (Ebinop Oor
              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 15) tint) tint)
              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 13) tint) tint) tint))
          (Ssequence
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _interactObj
                (tptr (Tstruct _Object noattr)))
              (Etempvar _o (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Scall None
                (Evar _take_damage_from_interact_object (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           nil) tuint
                                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Ssequence
                (Ssequence
                  (Sset _t'7
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
                               (Ecast (Econst_int (Int.repr 10) tint) tuint)
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
                             (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                             (Tstruct _Object noattr)) _header
                           (Tstruct _ObjectNode noattr)) _gfx
                         (Tstruct _GraphNodeObject noattr)) _cameraToObject
                       (tarray tfloat 3)) :: nil)))
                (Ssequence
                  (Sset _t'6
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _action tuint))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'6 tuint)
                                 (Ebinop Oor
                                   (Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 13) tint) tint)
                                   (Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 14) tint) tint)
                                   tint) tuint)
                    (Ssequence
                      (Scall (Some _t'1)
                        (Evar _drop_and_set_mario_action (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            tuint :: tuint ::
                                                            nil) tint
                                                           cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 805446344) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil))
                      (Sreturn (Some (Etempvar _t'1 tint))))
                    (Ssequence
                      (Scall None
                        (Evar _update_mario_sound_and_camera (Tfunction
                                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                                nil) tvoid
                                                               cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      (Ssequence
                        (Scall (Some _t'2)
                          (Evar _drop_and_set_mario_action (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              tuint ::
                                                              tuint :: nil)
                                                             tint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 131896) tint) ::
                           (Etempvar _actionArg tuint) :: nil))
                        (Sreturn (Some (Etempvar _t'2 tint))))))))))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asU32 (tarray tuint 80)) (Econst_int (Int.repr 66) tint)
            (tptr tuint)) tuint))
      (Sifthenelse (Eunop Onotbool
                     (Ebinop Oand (Etempvar _t'5 tuint)
                       (Econst_int (Int.repr 2) tint) tuint) tint)
        (Sassign (Evar _sDelayInvincTimer tuchar)
          (Econst_int (Int.repr 1) tint))
        Sskip))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_interact_mr_blizzard := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: (_t'2, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _take_damage_and_knock_back (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           (tptr (Tstruct _Object noattr)) ::
                                           nil) tuint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _o (tptr (Tstruct _Object noattr))) :: nil))
    (Sifthenelse (Etempvar _t'1 tuint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asU32 (tarray tuint 80)) (Econst_int (Int.repr 66) tint)
            (tptr tuint)) tuint))
      (Sifthenelse (Eunop Onotbool
                     (Ebinop Oand (Etempvar _t'2 tuint)
                       (Econst_int (Int.repr 2) tint) tuint) tint)
        (Sassign (Evar _sDelayInvincTimer tuchar)
          (Econst_int (Int.repr 1) tint))
        Sskip))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_interact_hit_from_below := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := ((_filler, (tarray tuchar 4)) :: nil);
  fn_temps := ((_interaction, tuint) :: (_t'3, tuint) :: (_t'2, tint) ::
               (_t'1, tuint) :: (_t'7, tuint) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tuint) ::
               (_t'4, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sifthenelse (Ebinop Oand (Etempvar _t'7 tuint)
                   (Econst_int (Int.repr 4) tint) tuint)
      (Sset _interaction
        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
          (Econst_int (Int.repr 5) tint) tint))
      (Ssequence
        (Scall (Some _t'1)
          (Evar _determine_interaction (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          (tptr (Tstruct _Object noattr)) ::
                                          nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Etempvar _o (tptr (Tstruct _Object noattr))) :: nil))
        (Sset _interaction (Etempvar _t'1 tuint)))))
  (Ssequence
    (Sifthenelse (Ebinop Oand (Etempvar _interaction tuint)
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                   (Econst_int (Int.repr 0) tint) tint)
                                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                   (Econst_int (Int.repr 1) tint) tint) tint)
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 2) tint) tint) tint)
                             (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                               (Econst_int (Int.repr 3) tint) tint) tint)
                           (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                             (Econst_int (Int.repr 4) tint) tint) tint)
                         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 5) tint) tint) tint)
                       (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 6) tint) tint) tint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 7) tint) tint) tint) tuint)
      (Ssequence
        (Scall None
          (Evar _attack_object (Tfunction
                                 ((tptr (Tstruct _Object noattr)) :: tint ::
                                  nil) tuint cc_default))
          ((Etempvar _o (tptr (Tstruct _Object noattr))) ::
           (Etempvar _interaction tuint) :: nil))
        (Ssequence
          (Scall None
            (Evar _bounce_back_from_attack (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tuint :: nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _interaction tuint) :: nil))
          (Ssequence
            (Sifthenelse (Ebinop Oand (Etempvar _interaction tuint)
                           (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                             (Econst_int (Int.repr 7) tint) tint) tuint)
              (Scall None
                (Evar _hit_object_from_below (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                (tptr (Tstruct _Object noattr)) ::
                                                nil) tvoid cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Etempvar _o (tptr (Tstruct _Object noattr))) :: nil))
              Sskip)
            (Sifthenelse (Ebinop Oand (Etempvar _interaction tuint)
                           (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                             (Econst_int (Int.repr 6) tint) tint) tuint)
              (Ssequence
                (Sset _t'5
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _o (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asU32 (tarray tuint 80))
                      (Econst_int (Int.repr 66) tint) (tptr tuint)) tuint))
                (Sifthenelse (Ebinop Oand (Etempvar _t'5 tuint)
                               (Econst_int (Int.repr 128) tint) tuint)
                  (Ssequence
                    (Scall None
                      (Evar _bounce_off_object (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  (tptr (Tstruct _Object noattr)) ::
                                                  tfloat :: nil) tvoid
                                                 cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Etempvar _o (tptr (Tstruct _Object noattr))) ::
                       (Econst_single (Float32.of_bits (Int.repr 1117782016)) tfloat) ::
                       nil))
                    (Ssequence
                      (Scall None
                        (Evar _reset_mario_pitch (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    nil) tvoid cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      (Ssequence
                        (Ssequence
                          (Sset _t'6
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
                                       (Ecast (Econst_int (Int.repr 52) tint)
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
                                     (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
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
                                                               tint
                                                               cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 276826276) tint) ::
                             (Econst_int (Int.repr 0) tint) :: nil))
                          (Sreturn (Some (Etempvar _t'2 tint)))))))
                  (Scall None
                    (Evar _bounce_off_object (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                (tptr (Tstruct _Object noattr)) ::
                                                tfloat :: nil) tvoid
                                               cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Etempvar _o (tptr (Tstruct _Object noattr))) ::
                     (Econst_single (Float32.of_bits (Int.repr 1106247680)) tfloat) ::
                     nil))))
              Sskip))))
      (Ssequence
        (Scall (Some _t'3)
          (Evar _take_damage_and_knock_back (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               (tptr (Tstruct _Object noattr)) ::
                                               nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Etempvar _o (tptr (Tstruct _Object noattr))) :: nil))
        (Sifthenelse (Etempvar _t'3 tuint)
          (Sreturn (Some (Econst_int (Int.repr 1) tint)))
          Sskip)))
    (Ssequence
      (Ssequence
        (Sset _t'4
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asU32 (tarray tuint 80)) (Econst_int (Int.repr 66) tint)
              (tptr tuint)) tuint))
        (Sifthenelse (Eunop Onotbool
                       (Ebinop Oand (Etempvar _t'4 tuint)
                         (Econst_int (Int.repr 2) tint) tuint) tint)
          (Sassign (Evar _sDelayInvincTimer tuchar)
            (Econst_int (Int.repr 1) tint))
          Sskip))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_interact_bounce_top := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_interaction, tuint) :: (_t'3, tuint) :: (_t'2, tint) ::
               (_t'1, tuint) :: (_t'7, tuint) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tuint) ::
               (_t'4, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sifthenelse (Ebinop Oand (Etempvar _t'7 tuint)
                   (Econst_int (Int.repr 4) tint) tuint)
      (Sset _interaction
        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
          (Econst_int (Int.repr 5) tint) tint))
      (Ssequence
        (Scall (Some _t'1)
          (Evar _determine_interaction (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          (tptr (Tstruct _Object noattr)) ::
                                          nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Etempvar _o (tptr (Tstruct _Object noattr))) :: nil))
        (Sset _interaction (Etempvar _t'1 tuint)))))
  (Ssequence
    (Sifthenelse (Ebinop Oand (Etempvar _interaction tuint)
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oor
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 0) tint) tint)
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 1) tint) tint) tint)
                             (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                               (Econst_int (Int.repr 2) tint) tint) tint)
                           (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                             (Econst_int (Int.repr 3) tint) tint) tint)
                         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 4) tint) tint) tint)
                       (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 5) tint) tint) tint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 6) tint) tint) tint) tuint)
      (Ssequence
        (Scall None
          (Evar _attack_object (Tfunction
                                 ((tptr (Tstruct _Object noattr)) :: tint ::
                                  nil) tuint cc_default))
          ((Etempvar _o (tptr (Tstruct _Object noattr))) ::
           (Etempvar _interaction tuint) :: nil))
        (Ssequence
          (Scall None
            (Evar _bounce_back_from_attack (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tuint :: nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _interaction tuint) :: nil))
          (Sifthenelse (Ebinop Oand (Etempvar _interaction tuint)
                         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 6) tint) tint) tuint)
            (Ssequence
              (Sset _t'5
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __665 noattr)) _asU32 (tarray tuint 80))
                    (Econst_int (Int.repr 66) tint) (tptr tuint)) tuint))
              (Sifthenelse (Ebinop Oand (Etempvar _t'5 tuint)
                             (Econst_int (Int.repr 128) tint) tuint)
                (Ssequence
                  (Scall None
                    (Evar _bounce_off_object (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                (tptr (Tstruct _Object noattr)) ::
                                                tfloat :: nil) tvoid
                                               cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Etempvar _o (tptr (Tstruct _Object noattr))) ::
                     (Econst_single (Float32.of_bits (Int.repr 1117782016)) tfloat) ::
                     nil))
                  (Ssequence
                    (Scall None
                      (Evar _reset_mario_pitch (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tvoid cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Ssequence
                      (Ssequence
                        (Sset _t'6
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
                                     (Ecast (Econst_int (Int.repr 52) tint)
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
                                   (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
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
                           (Econst_int (Int.repr 276826276) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))
                        (Sreturn (Some (Etempvar _t'2 tint)))))))
                (Scall None
                  (Evar _bounce_off_object (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              (tptr (Tstruct _Object noattr)) ::
                                              tfloat :: nil) tvoid
                                             cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Etempvar _o (tptr (Tstruct _Object noattr))) ::
                   (Econst_single (Float32.of_bits (Int.repr 1106247680)) tfloat) ::
                   nil))))
            Sskip)))
      (Ssequence
        (Scall (Some _t'3)
          (Evar _take_damage_and_knock_back (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               (tptr (Tstruct _Object noattr)) ::
                                               nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Etempvar _o (tptr (Tstruct _Object noattr))) :: nil))
        (Sifthenelse (Etempvar _t'3 tuint)
          (Sreturn (Some (Econst_int (Int.repr 1) tint)))
          Sskip)))
    (Ssequence
      (Ssequence
        (Sset _t'4
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asU32 (tarray tuint 80)) (Econst_int (Int.repr 66) tint)
              (tptr tuint)) tuint))
        (Sifthenelse (Eunop Onotbool
                       (Ebinop Oand (Etempvar _t'4 tuint)
                         (Econst_int (Int.repr 2) tint) tuint) tint)
          (Sassign (Evar _sDelayInvincTimer tuchar)
            (Econst_int (Int.repr 1) tint))
          Sskip))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_interact_unknown_08 := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_interaction, tuint) :: (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'3, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _determine_interaction (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      (tptr (Tstruct _Object noattr)) :: nil)
                                     tuint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _o (tptr (Tstruct _Object noattr))) :: nil))
    (Sset _interaction (Etempvar _t'1 tuint)))
  (Ssequence
    (Sifthenelse (Ebinop Oand (Etempvar _interaction tuint)
                   (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                     (Econst_int (Int.repr 1) tint) tint) tuint)
      (Ssequence
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
              (tptr tint)) tint)
          (Ebinop Oor
            (Ebinop Oor
              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 15) tint) tint)
              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 14) tint) tint) tint)
            (Econst_int (Int.repr 1) tint) tint))
        (Scall None
          (Evar _bounce_back_from_attack (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tuint :: nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Etempvar _interaction tuint) :: nil)))
      (Ssequence
        (Scall (Some _t'2)
          (Evar _take_damage_and_knock_back (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               (tptr (Tstruct _Object noattr)) ::
                                               nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Etempvar _o (tptr (Tstruct _Object noattr))) :: nil))
        (Sifthenelse (Etempvar _t'2 tuint)
          (Sreturn (Some (Econst_int (Int.repr 1) tint)))
          Sskip)))
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asU32 (tarray tuint 80)) (Econst_int (Int.repr 66) tint)
              (tptr tuint)) tuint))
        (Sifthenelse (Eunop Onotbool
                       (Ebinop Oand (Etempvar _t'3 tuint)
                         (Econst_int (Int.repr 2) tint) tuint) tint)
          (Sassign (Evar _sDelayInvincTimer tuchar)
            (Econst_int (Int.repr 1) tint))
          Sskip))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_interact_damage := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: (_t'2, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _take_damage_and_knock_back (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           (tptr (Tstruct _Object noattr)) ::
                                           nil) tuint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _o (tptr (Tstruct _Object noattr))) :: nil))
    (Sifthenelse (Etempvar _t'1 tuint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asU32 (tarray tuint 80)) (Econst_int (Int.repr 66) tint)
            (tptr tuint)) tuint))
      (Sifthenelse (Eunop Onotbool
                     (Ebinop Oand (Etempvar _t'2 tuint)
                       (Econst_int (Int.repr 2) tint) tuint) tint)
        (Sassign (Evar _sDelayInvincTimer tuchar)
          (Econst_int (Int.repr 1) tint))
        Sskip))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_interact_breakable := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_interaction, tuint) :: (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _determine_interaction (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      (tptr (Tstruct _Object noattr)) :: nil)
                                     tuint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _o (tptr (Tstruct _Object noattr))) :: nil))
    (Sset _interaction (Etempvar _t'1 tuint)))
  (Ssequence
    (Sifthenelse (Ebinop Oand (Etempvar _interaction tuint)
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                             (Econst_int (Int.repr 0) tint) tint)
                           (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                             (Econst_int (Int.repr 1) tint) tint) tint)
                         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 2) tint) tint) tint)
                       (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 3) tint) tint) tint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 7) tint) tint) tint) tuint)
      (Ssequence
        (Scall None
          (Evar _attack_object (Tfunction
                                 ((tptr (Tstruct _Object noattr)) :: tint ::
                                  nil) tuint cc_default))
          ((Etempvar _o (tptr (Tstruct _Object noattr))) ::
           (Etempvar _interaction tuint) :: nil))
        (Ssequence
          (Scall None
            (Evar _bounce_back_from_attack (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tuint :: nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _interaction tuint) :: nil))
          (Ssequence
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _interactObj
                (tptr (Tstruct _Object noattr)))
              (Etempvar _o (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sswitch (Etempvar _interaction tuint)
                (LScons (Some 64)
                  (Ssequence
                    (Scall None
                      (Evar _bounce_off_object (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  (tptr (Tstruct _Object noattr)) ::
                                                  tfloat :: nil) tvoid
                                                 cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Etempvar _o (tptr (Tstruct _Object noattr))) ::
                       (Econst_single (Float32.of_bits (Int.repr 1106247680)) tfloat) ::
                       nil))
                    Sbreak)
                  (LScons (Some 128)
                    (Ssequence
                      (Scall None
                        (Evar _hit_object_from_below (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        (tptr (Tstruct _Object noattr)) ::
                                                        nil) tvoid
                                                       cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Etempvar _o (tptr (Tstruct _Object noattr))) ::
                         nil))
                      Sbreak)
                    LSnil)))
              (Sreturn (Some (Econst_int (Int.repr 1) tint)))))))
      Sskip)
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_interact_koopa_shell := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_interaction, tuint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tuint) :: (_t'1, tuint) :: (_t'7, tuint) ::
               (_t'6, tuint) :: (_t'5, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _action tuint))
    (Sifthenelse (Eunop Onotbool
                   (Ebinop Oand (Etempvar _t'5 tuint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 16) tint) tint) tuint) tint)
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _determine_interaction (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            (tptr (Tstruct _Object noattr)) ::
                                            nil) tuint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _o (tptr (Tstruct _Object noattr))) :: nil))
          (Sset _interaction (Etempvar _t'1 tuint)))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sifthenelse (Ebinop Oeq (Etempvar _interaction tuint)
                             (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                               (Econst_int (Int.repr 6) tint) tint) tint)
                (Sset _t'3 (Econst_int (Int.repr 1) tint))
                (Ssequence
                  (Sset _t'7
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _action tuint))
                  (Sset _t'3
                    (Ecast
                      (Ebinop Oeq (Etempvar _t'7 tuint)
                        (Econst_int (Int.repr 67109952) tint) tint) tbool))))
              (Sifthenelse (Etempvar _t'3 tint)
                (Sset _t'4 (Econst_int (Int.repr 1) tint))
                (Ssequence
                  (Sset _t'6
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _action tuint))
                  (Sset _t'4
                    (Ecast
                      (Ebinop Oeq (Etempvar _t'6 tuint)
                        (Econst_int (Int.repr 1090) tint) tint) tbool)))))
            (Sifthenelse (Etempvar _t'4 tint)
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _interactObj
                    (tptr (Tstruct _Object noattr)))
                  (Etempvar _o (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _usedObj
                      (tptr (Tstruct _Object noattr)))
                    (Etempvar _o (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _riddenObj
                        (tptr (Tstruct _Object noattr)))
                      (Etempvar _o (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Scall None
                        (Evar _attack_object (Tfunction
                                               ((tptr (Tstruct _Object noattr)) ::
                                                tint :: nil) tuint
                                               cc_default))
                        ((Etempvar _o (tptr (Tstruct _Object noattr))) ::
                         (Etempvar _interaction tuint) :: nil))
                      (Ssequence
                        (Scall None
                          (Evar _update_mario_sound_and_camera (Tfunction
                                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                                  nil) tvoid
                                                                 cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        (Ssequence
                          (Scall None
                            (Evar _play_shell_music (Tfunction nil tvoid
                                                      cc_default)) nil)
                          (Ssequence
                            (Scall None
                              (Evar _mario_drop_held_object (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               nil) tvoid
                                                              cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               nil))
                            (Ssequence
                              (Scall (Some _t'2)
                                (Evar _set_mario_action (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           tuint :: tuint ::
                                                           nil) tuint
                                                          cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 (Econst_int (Int.repr 545326150) tint) ::
                                 (Econst_int (Int.repr 0) tint) :: nil))
                              (Sreturn (Some (Etempvar _t'2 tuint)))))))))))
              Sskip))
          (Scall None
            (Evar _push_mario_out_of_object (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               (tptr (Tstruct _Object noattr)) ::
                                               tfloat :: nil) tvoid
                                              cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _o (tptr (Tstruct _Object noattr))) ::
             (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat) ::
             nil))))
      Sskip))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_check_object_grab_mario := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tint) :: (_t'3, tint) :: (_t'2, tuint) ::
               (_t'1, tuint) :: (_t'9, tshort) :: (_t'8, tuint) ::
               (_t'7, tuint) :: (_t'6, tint) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'8
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _action tuint))
        (Sifthenelse (Eunop Onotbool
                       (Ebinop Oand (Etempvar _t'8 tuint)
                         (Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                               (Econst_int (Int.repr 11) tint) tint)
                             (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                               (Econst_int (Int.repr 17) tint) tint) tint)
                           (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                             (Econst_int (Int.repr 23) tint) tint) tint)
                         tuint) tint)
          (Sset _t'3 (Econst_int (Int.repr 1) tint))
          (Ssequence
            (Sset _t'9 (Evar _sInvulnerable tshort))
            (Sset _t'3
              (Ecast (Eunop Onotbool (Etempvar _t'9 tshort) tint) tbool)))))
      (Sifthenelse (Etempvar _t'3 tint)
        (Ssequence
          (Sset _t'7
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asU32 (tarray tuint 80))
                (Econst_int (Int.repr 66) tint) (tptr tuint)) tuint))
          (Sset _t'4
            (Ecast
              (Ebinop Oand (Etempvar _t'7 tuint)
                (Econst_int (Int.repr 4) tint) tuint) tbool)))
        (Sset _t'4 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'4 tint)
      (Ssequence
        (Scall (Some _t'2)
          (Evar _object_facing_mario (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        (tptr (Tstruct _Object noattr)) ::
                                        tshort :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Etempvar _o (tptr (Tstruct _Object noattr))) ::
           (Econst_int (Int.repr 10922) tint) :: nil))
        (Sifthenelse (Etempvar _t'2 tuint)
          (Ssequence
            (Scall None
              (Evar _mario_stop_riding_and_holding (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Ssequence
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __665 noattr)) _asS32 (tarray tint 80))
                    (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
                (Ebinop Oor
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 15) tint) tint)
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 11) tint) tint) tint))
              (Ssequence
                (Ssequence
                  (Sset _t'6
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _o (tptr (Tstruct _Object noattr)))
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
                        (tptr tshort)) tshort) (Etempvar _t'6 tint)))
                (Ssequence
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _interactObj
                      (tptr (Tstruct _Object noattr)))
                    (Etempvar _o (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _usedObj
                        (tptr (Tstruct _Object noattr)))
                      (Etempvar _o (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Scall None
                        (Evar _update_mario_sound_and_camera (Tfunction
                                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                                nil) tvoid
                                                               cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      (Ssequence
                        (Ssequence
                          (Sset _t'5
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
                                       (Ecast (Econst_int (Int.repr 11) tint)
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
                                     (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                                     (Tstruct _Object noattr)) _header
                                   (Tstruct _ObjectNode noattr)) _gfx
                                 (Tstruct _GraphNodeObject noattr))
                               _cameraToObject (tarray tfloat 3)) :: nil)))
                        (Ssequence
                          (Scall (Some _t'1)
                            (Evar _set_mario_action (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: tuint :: nil)
                                                      tuint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 131952) tint) ::
                             (Econst_int (Int.repr 0) tint) :: nil))
                          (Sreturn (Some (Etempvar _t'1 tuint)))))))))))
          Sskip))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _push_mario_out_of_object (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         (tptr (Tstruct _Object noattr)) ::
                                         tfloat :: nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _o (tptr (Tstruct _Object noattr))) ::
       (Eunop Oneg
         (Econst_single (Float32.of_bits (Int.repr 1084227584)) tfloat)
         tfloat) :: nil))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_interact_pole := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_actionId, tint) :: (_lowSpeed, tuint) ::
               (_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_t'4, tint) :: (_t'3, tint) :: (_t'2, tuint) ::
               (_t'1, tuint) :: (_t'11, tuint) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tuint) ::
               (_t'8, tfloat) :: (_t'7, tfloat) :: (_t'6, tfloat) ::
               (_t'5, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'11
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _action tuint))
    (Sset _actionId
      (Ebinop Oand (Etempvar _t'11 tuint) (Econst_int (Int.repr 511) tint)
        tuint)))
  (Ssequence
    (Ssequence
      (Sifthenelse (Ebinop Oge (Etempvar _actionId tint)
                     (Econst_int (Int.repr 128) tint) tint)
        (Sset _t'4
          (Ecast
            (Ebinop Olt (Etempvar _actionId tint)
              (Econst_int (Int.repr 160) tint) tint) tbool))
        (Sset _t'4 (Econst_int (Int.repr 0) tint)))
      (Sifthenelse (Etempvar _t'4 tint)
        (Ssequence
          (Ssequence
            (Sset _t'9
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _prevAction tuint))
            (Sifthenelse (Eunop Onotbool
                           (Ebinop Oand (Etempvar _t'9 tuint)
                             (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                               (Econst_int (Int.repr 20) tint) tint) tuint)
                           tint)
              (Sset _t'3 (Econst_int (Int.repr 1) tint))
              (Ssequence
                (Sset _t'10
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _usedObj
                    (tptr (Tstruct _Object noattr))))
                (Sset _t'3
                  (Ecast
                    (Ebinop One
                      (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                      (Etempvar _o (tptr (Tstruct _Object noattr))) tint)
                    tbool)))))
          (Sifthenelse (Etempvar _t'3 tint)
            (Ssequence
              (Ssequence
                (Sset _t'8
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
                (Sset _lowSpeed
                  (Ebinop Ole (Etempvar _t'8 tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                    tint)))
              (Ssequence
                (Sset _marioObj
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _marioObj
                    (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Scall None
                    (Evar _mario_stop_riding_and_holding (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            nil) tvoid
                                                           cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _interactObj
                        (tptr (Tstruct _Object noattr)))
                      (Etempvar _o (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _usedObj
                          (tptr (Tstruct _Object noattr)))
                        (Etempvar _o (tptr (Tstruct _Object noattr))))
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
                          (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                        (Ssequence
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _forwardVel
                              tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
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
                                  (Econst_int (Int.repr 32) tint)
                                  (tptr tint)) tint)
                              (Econst_int (Int.repr 0) tint))
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
                              (Ssequence
                                (Ssequence
                                  (Sset _t'6
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
                                    (Sset _t'7
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _o (tptr (Tstruct _Object noattr)))
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
                                      (Ebinop Osub (Etempvar _t'6 tfloat)
                                        (Etempvar _t'7 tfloat) tfloat))))
                                (Ssequence
                                  (Sifthenelse (Etempvar _lowSpeed tuint)
                                    (Ssequence
                                      (Scall (Some _t'1)
                                        (Evar _set_mario_action (Tfunction
                                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                                   tuint ::
                                                                   tuint ::
                                                                   nil) tuint
                                                                  cc_default))
                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                         (Econst_int (Int.repr 1049409) tint) ::
                                         (Econst_int (Int.repr 0) tint) ::
                                         nil))
                                      (Sreturn (Some (Etempvar _t'1 tuint))))
                                    Sskip)
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'5
                                        (Efield
                                          (Ederef
                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _forwardVel tfloat))
                                      (Sassign
                                        (Ederef
                                          (Ebinop Oadd
                                            (Efield
                                              (Efield
                                                (Ederef
                                                  (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                                  (Tstruct _Object noattr))
                                                _rawData
                                                (Tunion __665 noattr)) _asS32
                                              (tarray tint 80))
                                            (Econst_int (Int.repr 33) tint)
                                            (tptr tint)) tint)
                                        (Ecast
                                          (Ebinop Oadd
                                            (Ebinop Omul
                                              (Etempvar _t'5 tfloat)
                                              (Econst_int (Int.repr 256) tint)
                                              tfloat)
                                            (Econst_int (Int.repr 4096) tint)
                                            tfloat) tint)))
                                    (Ssequence
                                      (Scall None
                                        (Evar _reset_mario_pitch (Tfunction
                                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil)
                                                                   tvoid
                                                                   cc_default))
                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                         nil))
                                      (Ssequence
                                        (Scall (Some _t'2)
                                          (Evar _set_mario_action (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    tuint ::
                                                                    tuint ::
                                                                    nil)
                                                                    tuint
                                                                    cc_default))
                                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                           (Econst_int (Int.repr 1049410) tint) ::
                                           (Econst_int (Int.repr 0) tint) ::
                                           nil))
                                        (Sreturn (Some (Etempvar _t'2 tuint)))))))))))))))))
            Sskip))
        Sskip))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_interact_hoot := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_actionId, tint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tuint) :: (_t'7, tuint) :: (_t'6, tint) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: (_t'4, tuint) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _action tuint))
    (Sset _actionId
      (Ebinop Oand (Etempvar _t'7 tuint) (Econst_int (Int.repr 511) tint)
        tuint)))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sifthenelse (Ebinop Oge (Etempvar _actionId tint)
                       (Econst_int (Int.repr 128) tint) tint)
          (Sset _t'2
            (Ecast
              (Ebinop Olt (Etempvar _actionId tint)
                (Econst_int (Int.repr 152) tint) tint) tbool))
          (Sset _t'2 (Econst_int (Int.repr 0) tint)))
        (Sifthenelse (Etempvar _t'2 tint)
          (Ssequence
            (Sset _t'4 (Evar _gGlobalTimer tuint))
            (Ssequence
              (Sset _t'5
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _usedObj
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
                (Sset _t'3
                  (Ecast
                    (Ebinop Ogt
                      (Ebinop Osub (Etempvar _t'4 tuint) (Etempvar _t'6 tint)
                        tuint) (Econst_int (Int.repr 30) tint) tint) tbool)))))
          (Sset _t'3 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'3 tint)
        (Ssequence
          (Scall None
            (Evar _mario_stop_riding_and_holding (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __665 noattr)) _asS32 (tarray tint 80))
                  (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
              (Econst_int (Int.repr 1) tint))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _interactObj
                  (tptr (Tstruct _Object noattr)))
                (Etempvar _o (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _usedObj
                    (tptr (Tstruct _Object noattr)))
                  (Etempvar _o (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Scall None
                    (Evar _update_mario_sound_and_camera (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            nil) tvoid
                                                           cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Ssequence
                    (Scall (Some _t'1)
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 1192) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    (Sreturn (Some (Etempvar _t'1 tuint)))))))))
        Sskip))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_interact_cap := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_capFlag, tuint) :: (_capMusic, tushort) ::
               (_capTime, tushort) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tuint) :: (_t'13, tuint) :: (_t'12, tuint) ::
               (_t'11, tuint) :: (_t'10, tushort) :: (_t'9, tuint) ::
               (_t'8, tuint) :: (_t'7, tuint) :: (_t'6, tuint) ::
               (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _get_mario_cap_flag (Tfunction
                                  ((tptr (Tstruct _Object noattr)) :: nil)
                                  tuint cc_default))
      ((Etempvar _o (tptr (Tstruct _Object noattr))) :: nil))
    (Sset _capFlag (Etempvar _t'1 tuint)))
  (Ssequence
    (Sset _capMusic (Ecast (Econst_int (Int.repr 0) tint) tushort))
    (Ssequence
      (Sset _capTime (Ecast (Econst_int (Int.repr 0) tint) tushort))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'13
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _action tuint))
            (Sifthenelse (Ebinop One (Etempvar _t'13 tuint)
                           (Econst_int (Int.repr 16910520) tint) tint)
              (Sset _t'3
                (Ecast
                  (Ebinop One (Etempvar _capFlag tuint)
                    (Econst_int (Int.repr 0) tint) tint) tbool))
              (Sset _t'3 (Econst_int (Int.repr 0) tint))))
          (Sifthenelse (Etempvar _t'3 tint)
            (Ssequence
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _interactObj
                  (tptr (Tstruct _Object noattr)))
                (Etempvar _o (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _o (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asS32 (tarray tint 80))
                      (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 15) tint) tint))
                (Ssequence
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
                        (Ebinop Oand
                          (Eunop Onotint (Econst_int (Int.repr 16) tint)
                            tint)
                          (Eunop Onotint (Econst_int (Int.repr 32) tint)
                            tint) tint) tuint)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'11
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _flags tuint))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _flags tuint)
                        (Ebinop Oor (Etempvar _t'11 tuint)
                          (Etempvar _capFlag tuint) tuint)))
                    (Ssequence
                      (Sswitch (Etempvar _capFlag tuint)
                        (LScons (Some 2)
                          (Ssequence
                            (Sset _capTime
                              (Ecast (Econst_int (Int.repr 600) tint)
                                tushort))
                            (Ssequence
                              (Sset _capMusic
                                (Ecast
                                  (Ebinop Oor
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 4) tint)
                                      (Econst_int (Int.repr 8) tint) tint)
                                    (Econst_int (Int.repr 14) tint) tint)
                                  tushort))
                              Sbreak))
                          (LScons (Some 4)
                            (Ssequence
                              (Sset _capTime
                                (Ecast (Econst_int (Int.repr 600) tint)
                                  tushort))
                              (Ssequence
                                (Sset _capMusic
                                  (Ecast
                                    (Ebinop Oor
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 4) tint)
                                        (Econst_int (Int.repr 8) tint) tint)
                                      (Econst_int (Int.repr 15) tint) tint)
                                    tushort))
                                Sbreak))
                            (LScons (Some 8)
                              (Ssequence
                                (Sset _capTime
                                  (Ecast (Econst_int (Int.repr 1800) tint)
                                    tushort))
                                (Ssequence
                                  (Sset _capMusic
                                    (Ecast
                                      (Ebinop Oor
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 4) tint)
                                          (Econst_int (Int.repr 8) tint)
                                          tint)
                                        (Econst_int (Int.repr 14) tint) tint)
                                      tushort))
                                  Sbreak))
                              LSnil))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'10
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _capTimer
                              tushort))
                          (Sifthenelse (Ebinop Ogt
                                         (Etempvar _capTime tushort)
                                         (Etempvar _t'10 tushort) tint)
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _capTimer
                                tushort) (Etempvar _capTime tushort))
                            Sskip))
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Sset _t'8
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _action
                                  tuint))
                              (Sifthenelse (Ebinop Oand (Etempvar _t'8 tuint)
                                             (Ebinop Oshl
                                               (Econst_int (Int.repr 1) tint)
                                               (Econst_int (Int.repr 22) tint)
                                               tint) tuint)
                                (Sset _t'2 (Econst_int (Int.repr 1) tint))
                                (Ssequence
                                  (Sset _t'9
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr)) _action
                                      tuint))
                                  (Sset _t'2
                                    (Ecast
                                      (Ebinop Oeq (Etempvar _t'9 tuint)
                                        (Econst_int (Int.repr 67109952) tint)
                                        tint) tbool)))))
                            (Sifthenelse (Etempvar _t'2 tint)
                              (Ssequence
                                (Ssequence
                                  (Sset _t'7
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr)) _flags
                                      tuint))
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr)) _flags
                                      tuint)
                                    (Ebinop Oor (Etempvar _t'7 tuint)
                                      (Econst_int (Int.repr 32) tint) tuint)))
                                (Scall None
                                  (Evar _set_mario_action (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             tuint ::
                                                             tuint :: nil)
                                                            tuint cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   (Econst_int (Int.repr 4925) tint) ::
                                   (Econst_int (Int.repr 0) tint) :: nil)))
                              (Ssequence
                                (Sset _t'6
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _flags
                                    tuint))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _flags
                                    tuint)
                                  (Ebinop Oor (Etempvar _t'6 tuint)
                                    (Econst_int (Int.repr 16) tint) tuint)))))
                          (Ssequence
                            (Ssequence
                              (Sset _t'5
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
                                             (Econst_int (Int.repr 7) tint)
                                             tuint)
                                           (Econst_int (Int.repr 28) tint)
                                           tuint)
                                         (Ebinop Oshl
                                           (Ecast
                                             (Econst_int (Int.repr 30) tint)
                                             tuint)
                                           (Econst_int (Int.repr 16) tint)
                                           tuint) tuint)
                                       (Ebinop Oshl
                                         (Ecast
                                           (Econst_int (Int.repr 255) tint)
                                           tuint)
                                         (Econst_int (Int.repr 8) tint)
                                         tuint) tuint)
                                     (Econst_int (Int.repr 128) tint) tuint)
                                   (Econst_int (Int.repr 1) tint) tuint) ::
                                 (Efield
                                   (Efield
                                     (Efield
                                       (Ederef
                                         (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                                         (Tstruct _Object noattr)) _header
                                       (Tstruct _ObjectNode noattr)) _gfx
                                     (Tstruct _GraphNodeObject noattr))
                                   _cameraToObject (tarray tfloat 3)) :: nil)))
                            (Ssequence
                              (Ssequence
                                (Sset _t'4
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
                                               (Econst_int (Int.repr 12) tint)
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
                                           (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                                           (Tstruct _Object noattr)) _header
                                         (Tstruct _ObjectNode noattr)) _gfx
                                       (Tstruct _GraphNodeObject noattr))
                                     _cameraToObject (tarray tfloat 3)) ::
                                   nil)))
                              (Ssequence
                                (Sifthenelse (Ebinop One
                                               (Etempvar _capMusic tushort)
                                               (Econst_int (Int.repr 0) tint)
                                               tint)
                                  (Scall None
                                    (Evar _play_cap_music (Tfunction
                                                            (tushort :: nil)
                                                            tvoid cc_default))
                                    ((Etempvar _capMusic tushort) :: nil))
                                  Sskip)
                                (Sreturn (Some (Econst_int (Int.repr 1) tint)))))))))))))
            Sskip))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_interact_grabbable := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_script, (tptr tuint)) :: (_interaction, tuint) ::
               (_t'4, tuint) :: (_t'3, tuint) :: (_t'2, tuint) ::
               (_t'1, (tptr tvoid)) :: (_t'9, (tptr tuint)) ::
               (_t'8, tuint) :: (_t'7, tuint) :: (_t'6, tushort) ::
               (_t'5, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'9
        (Efield
          (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
            (Tstruct _Object noattr)) _behavior (tptr tuint)))
      (Scall (Some _t'1)
        (Evar _virtual_to_segmented (Tfunction (tuint :: (tptr tvoid) :: nil)
                                      (tptr tvoid) cc_default))
        ((Econst_int (Int.repr 19) tint) :: (Etempvar _t'9 (tptr tuint)) ::
         nil)))
    (Sset _script (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Ssequence
      (Sset _t'8
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asU32 (tarray tuint 80)) (Econst_int (Int.repr 66) tint)
            (tptr tuint)) tuint))
      (Sifthenelse (Ebinop Oand (Etempvar _t'8 tuint)
                     (Econst_int (Int.repr 256) tint) tuint)
        (Ssequence
          (Ssequence
            (Scall (Some _t'2)
              (Evar _determine_interaction (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              (tptr (Tstruct _Object noattr)) ::
                                              nil) tuint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Etempvar _o (tptr (Tstruct _Object noattr))) :: nil))
            (Sset _interaction (Etempvar _t'2 tuint)))
          (Sifthenelse (Ebinop Oand (Etempvar _interaction tuint)
                         (Ebinop Oor
                           (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                             (Econst_int (Int.repr 2) tint) tint)
                           (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                             (Econst_int (Int.repr 3) tint) tint) tint)
                         tuint)
            (Ssequence
              (Scall None
                (Evar _attack_object (Tfunction
                                       ((tptr (Tstruct _Object noattr)) ::
                                        tint :: nil) tuint cc_default))
                ((Etempvar _o (tptr (Tstruct _Object noattr))) ::
                 (Etempvar _interaction tuint) :: nil))
              (Ssequence
                (Scall None
                  (Evar _bounce_back_from_attack (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tuint :: nil) tvoid
                                                   cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Etempvar _interaction tuint) :: nil))
                (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
            Sskip))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'7
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asU32 (tarray tuint 80)) (Econst_int (Int.repr 66) tint)
              (tptr tuint)) tuint))
        (Sifthenelse (Ebinop Oand (Etempvar _t'7 tuint)
                       (Econst_int (Int.repr 4) tint) tuint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _check_object_grab_mario (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint ::
                                                (tptr (Tstruct _Object noattr)) ::
                                                nil) tuint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Etempvar _interactType tuint) ::
               (Etempvar _o (tptr (Tstruct _Object noattr))) :: nil))
            (Sifthenelse (Etempvar _t'3 tuint)
              (Sreturn (Some (Econst_int (Int.repr 1) tint)))
              Sskip))
          Sskip))
      (Ssequence
        (Ssequence
          (Scall (Some _t'4)
            (Evar _able_to_grab_object (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          (tptr (Tstruct _Object noattr)) ::
                                          nil) tuint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _o (tptr (Tstruct _Object noattr))) :: nil))
          (Sifthenelse (Etempvar _t'4 tuint)
            (Ssequence
              (Sset _t'5
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __665 noattr)) _asU32 (tarray tuint 80))
                    (Econst_int (Int.repr 66) tint) (tptr tuint)) tuint))
              (Sifthenelse (Eunop Onotbool
                             (Ebinop Oand (Etempvar _t'5 tuint)
                               (Econst_int (Int.repr 512) tint) tuint) tint)
                (Ssequence
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _interactObj
                      (tptr (Tstruct _Object noattr)))
                    (Etempvar _o (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'6
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _input tushort))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _input tushort)
                        (Ebinop Oor (Etempvar _t'6 tushort)
                          (Econst_int (Int.repr 2048) tint) tint)))
                    (Sreturn (Some (Econst_int (Int.repr 1) tint)))))
                Sskip))
            Sskip))
        (Ssequence
          (Sifthenelse (Ebinop One (Etempvar _script (tptr tuint))
                         (Evar _bhvBowser (tarray tuint 0)) tint)
            (Scall None
              (Evar _push_mario_out_of_object (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 (tptr (Tstruct _Object noattr)) ::
                                                 tfloat :: nil) tvoid
                                                cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Etempvar _o (tptr (Tstruct _Object noattr))) ::
               (Eunop Oneg
                 (Econst_single (Float32.of_bits (Int.repr 1084227584)) tfloat)
                 tfloat) :: nil))
            Sskip)
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_mario_can_talk := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: (_arg, tuint) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_val6, tshort) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'6, tuint) :: (_t'5, tshort) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: (_t'3, tuint) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _action tuint))
    (Sifthenelse (Ebinop One
                   (Ebinop Oand (Etempvar _t'6 tuint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 22) tint) tint) tuint)
                   (Econst_int (Int.repr 0) tint) tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _action tuint))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tuint)
                     (Econst_int (Int.repr 67109952) tint) tint)
        (Ssequence
          (Sifthenelse (Etempvar _arg tuint)
            (Sreturn (Some (Econst_int (Int.repr 1) tint)))
            Sskip)
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
                      (Tstruct _AnimInfo noattr)) _animID tshort))
                (Sset _val6 (Ecast (Etempvar _t'5 tshort) tshort))))
            (Ssequence
              (Ssequence
                (Sifthenelse (Ebinop Oeq (Etempvar _val6 tshort)
                               (Econst_int (Int.repr 128) tint) tint)
                  (Sset _t'1 (Econst_int (Int.repr 1) tint))
                  (Sset _t'1
                    (Ecast
                      (Ebinop Oeq (Etempvar _val6 tshort)
                        (Econst_int (Int.repr 127) tint) tint) tbool)))
                (Sifthenelse (Etempvar _t'1 tint)
                  (Sset _t'2 (Econst_int (Int.repr 1) tint))
                  (Sset _t'2
                    (Ecast
                      (Ebinop Oeq (Etempvar _val6 tshort)
                        (Econst_int (Int.repr 108) tint) tint) tbool))))
              (Sifthenelse (Etempvar _t'2 tint)
                (Sreturn (Some (Econst_int (Int.repr 1) tint)))
                Sskip))))
        Sskip))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_check_read_sign := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_facingDYaw, tshort) :: (_targetX, tfloat) ::
               (_targetZ, tfloat) :: (_t'6, tuint) :: (_t'5, tint) ::
               (_t'4, tuint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tuint) :: (_t'20, tushort) :: (_t'19, tshort) ::
               (_t'18, tint) :: (_t'17, tfloat) :: (_t'16, tint) ::
               (_t'15, tfloat) :: (_t'14, tfloat) :: (_t'13, tint) ::
               (_t'12, tfloat) :: (_t'11, (tptr (Tstruct _Object noattr))) ::
               (_t'10, tfloat) :: (_t'9, (tptr (Tstruct _Object noattr))) ::
               (_t'8, tfloat) :: (_t'7, (tptr (Tstruct _Object noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'20
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'20 tushort)
                       (Ebinop Oor (Econst_int (Int.repr 8192) tint)
                         (Econst_int (Int.repr 2) tint) tint) tint)
          (Ssequence
            (Scall (Some _t'4)
              (Evar _mario_can_talk (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: nil) tuint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sset _t'3 (Ecast (Etempvar _t'4 tuint) tbool)))
          (Sset _t'3 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'3 tint)
        (Ssequence
          (Scall (Some _t'6)
            (Evar _object_facing_mario (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          (tptr (Tstruct _Object noattr)) ::
                                          tshort :: nil) tuint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _o (tptr (Tstruct _Object noattr))) ::
             (Econst_int (Int.repr 16384) tint) :: nil))
          (Sset _t'5 (Ecast (Etempvar _t'6 tuint) tbool)))
        (Sset _t'5 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'5 tint)
      (Ssequence
        (Ssequence
          (Sset _t'18
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asS32 (tarray tint 80))
                (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                  (Econst_int (Int.repr 1) tint) tint) (tptr tint)) tint))
          (Ssequence
            (Sset _t'19
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _faceAngle
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort))
            (Sset _facingDYaw
              (Ecast
                (Ebinop Osub
                  (Ecast
                    (Ebinop Oadd (Etempvar _t'18 tint)
                      (Econst_int (Int.repr 32768) tint) tint) tshort)
                  (Etempvar _t'19 tshort) tint) tshort))))
        (Ssequence
          (Sifthenelse (Ebinop Oge (Etempvar _facingDYaw tshort)
                         (Eunop Oneg (Econst_int (Int.repr 16384) tint) tint)
                         tint)
            (Sset _t'2
              (Ecast
                (Ebinop Ole (Etempvar _facingDYaw tshort)
                  (Econst_int (Int.repr 16384) tint) tint) tbool))
            (Sset _t'2 (Econst_int (Int.repr 0) tint)))
          (Sifthenelse (Etempvar _t'2 tint)
            (Ssequence
              (Ssequence
                (Sset _t'15
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _o (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                      (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                        (Econst_int (Int.repr 0) tint) tint) (tptr tfloat))
                    tfloat))
                (Ssequence
                  (Sset _t'16
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _o (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __665 noattr)) _asS32 (tarray tint 80))
                        (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                          (Econst_int (Int.repr 1) tint) tint) (tptr tint))
                      tint))
                  (Ssequence
                    (Sset _t'17
                      (Ederef
                        (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                          (Ebinop Oshr (Ecast (Etempvar _t'16 tint) tushort)
                            (Econst_int (Int.repr 4) tint) tint)
                          (tptr tfloat)) tfloat))
                    (Sset _targetX
                      (Ebinop Oadd (Etempvar _t'15 tfloat)
                        (Ebinop Omul
                          (Econst_single (Float32.of_bits (Int.repr 1121058816)) tfloat)
                          (Etempvar _t'17 tfloat) tfloat) tfloat)))))
              (Ssequence
                (Ssequence
                  (Sset _t'12
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _o (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                        (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                          (Econst_int (Int.repr 2) tint) tint) (tptr tfloat))
                      tfloat))
                  (Ssequence
                    (Sset _t'13
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _o (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __665 noattr)) _asS32 (tarray tint 80))
                          (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                            (Econst_int (Int.repr 1) tint) tint) (tptr tint))
                        tint))
                    (Ssequence
                      (Sset _t'14
                        (Ederef
                          (Ebinop Oadd
                            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                              (Econst_int (Int.repr 1024) tint)
                              (tptr tfloat))
                            (Ebinop Oshr
                              (Ecast (Etempvar _t'13 tint) tushort)
                              (Econst_int (Int.repr 4) tint) tint)
                            (tptr tfloat)) tfloat))
                      (Sset _targetZ
                        (Ebinop Oadd (Etempvar _t'12 tfloat)
                          (Ebinop Omul
                            (Econst_single (Float32.of_bits (Int.repr 1121058816)) tfloat)
                            (Etempvar _t'14 tfloat) tfloat) tfloat)))))
                (Ssequence
                  (Ssequence
                    (Sset _t'11
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
                                (Etempvar _t'11 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __665 noattr)) _asS32 (tarray tint 80))
                          (Econst_int (Int.repr 32) tint) (tptr tint)) tint)
                      (Etempvar _facingDYaw tshort)))
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
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _pos
                                (tarray tfloat 3))
                              (Econst_int (Int.repr 0) tint) (tptr tfloat))
                            tfloat))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __665 noattr)) _asF32
                                (tarray tfloat 80))
                              (Econst_int (Int.repr 33) tint) (tptr tfloat))
                            tfloat)
                          (Ebinop Osub (Etempvar _targetX tfloat)
                            (Etempvar _t'10 tfloat) tfloat))))
                    (Ssequence
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
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _pos
                                  (tarray tfloat 3))
                                (Econst_int (Int.repr 2) tint) (tptr tfloat))
                              tfloat))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __665 noattr)) _asF32
                                  (tarray tfloat 80))
                                (Econst_int (Int.repr 34) tint)
                                (tptr tfloat)) tfloat)
                            (Ebinop Osub (Etempvar _targetZ tfloat)
                              (Etempvar _t'8 tfloat) tfloat))))
                      (Ssequence
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _interactObj
                            (tptr (Tstruct _Object noattr)))
                          (Etempvar _o (tptr (Tstruct _Object noattr))))
                        (Ssequence
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _usedObj
                              (tptr (Tstruct _Object noattr)))
                            (Etempvar _o (tptr (Tstruct _Object noattr))))
                          (Ssequence
                            (Scall (Some _t'1)
                              (Evar _set_mario_action (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         tuint :: tuint ::
                                                         nil) tuint
                                                        cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 4872) tint) ::
                               (Econst_int (Int.repr 0) tint) :: nil))
                            (Sreturn (Some (Etempvar _t'1 tuint)))))))))))
            Sskip)))
      Sskip))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_check_npc_talk := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_facingDYaw, tshort) :: (_t'5, tuint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tuint) :: (_t'1, tshort) ::
               (_t'7, tushort) :: (_t'6, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'7
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'7 tushort)
                     (Ebinop Oor (Econst_int (Int.repr 8192) tint)
                       (Econst_int (Int.repr 2) tint) tint) tint)
        (Ssequence
          (Scall (Some _t'5)
            (Evar _mario_can_talk (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: nil) tuint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 1) tint) :: nil))
          (Sset _t'4 (Ecast (Etempvar _t'5 tuint) tbool)))
        (Sset _t'4 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'4 tint)
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _mario_obj_angle_to_object (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                (tptr (Tstruct _Object noattr)) ::
                                                nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _o (tptr (Tstruct _Object noattr))) :: nil))
          (Ssequence
            (Sset _t'6
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _faceAngle
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort))
            (Sset _facingDYaw
              (Ecast
                (Ebinop Osub (Etempvar _t'1 tshort) (Etempvar _t'6 tshort)
                  tint) tshort))))
        (Ssequence
          (Sifthenelse (Ebinop Oge (Etempvar _facingDYaw tshort)
                         (Eunop Oneg (Econst_int (Int.repr 16384) tint) tint)
                         tint)
            (Sset _t'3
              (Ecast
                (Ebinop Ole (Etempvar _facingDYaw tshort)
                  (Econst_int (Int.repr 16384) tint) tint) tbool))
            (Sset _t'3 (Econst_int (Int.repr 0) tint)))
          (Sifthenelse (Etempvar _t'3 tint)
            (Ssequence
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __665 noattr)) _asS32 (tarray tint 80))
                    (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 15) tint) tint))
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _interactObj
                    (tptr (Tstruct _Object noattr)))
                  (Etempvar _o (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _usedObj
                      (tptr (Tstruct _Object noattr)))
                    (Etempvar _o (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Scall None
                      (Evar _push_mario_out_of_object (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         (tptr (Tstruct _Object noattr)) ::
                                                         tfloat :: nil) tvoid
                                                        cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Etempvar _o (tptr (Tstruct _Object noattr))) ::
                       (Eunop Oneg
                         (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                         tfloat) :: nil))
                    (Ssequence
                      (Scall (Some _t'2)
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 4874) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil))
                      (Sreturn (Some (Etempvar _t'2 tuint))))))))
            Sskip)))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _push_mario_out_of_object (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         (tptr (Tstruct _Object noattr)) ::
                                         tfloat :: nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _o (tptr (Tstruct _Object noattr))) ::
       (Eunop Oneg
         (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
         tfloat) :: nil))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_interact_text := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_interactType, tuint) ::
                (_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_interact, tuint) :: (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'4, tuint) :: (_t'3, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _interact (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asU32 (tarray tuint 80)) (Econst_int (Int.repr 66) tint)
            (tptr tuint)) tuint))
      (Sifthenelse (Ebinop Oand (Etempvar _t'3 tuint)
                     (Econst_int (Int.repr 4096) tint) tuint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _check_read_sign (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      (tptr (Tstruct _Object noattr)) :: nil)
                                     tuint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _o (tptr (Tstruct _Object noattr))) :: nil))
          (Sset _interact (Etempvar _t'1 tuint)))
        (Ssequence
          (Sset _t'4
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asU32 (tarray tuint 80))
                (Econst_int (Int.repr 66) tint) (tptr tuint)) tuint))
          (Sifthenelse (Ebinop Oand (Etempvar _t'4 tuint)
                         (Econst_int (Int.repr 16384) tint) tuint)
            (Ssequence
              (Scall (Some _t'2)
                (Evar _check_npc_talk (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         (tptr (Tstruct _Object noattr)) ::
                                         nil) tuint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Etempvar _o (tptr (Tstruct _Object noattr))) :: nil))
              (Sset _interact (Etempvar _t'2 tuint)))
            (Scall None
              (Evar _push_mario_out_of_object (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 (tptr (Tstruct _Object noattr)) ::
                                                 tfloat :: nil) tvoid
                                                cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Etempvar _o (tptr (Tstruct _Object noattr))) ::
               (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat) ::
               nil))))))
    (Sreturn (Some (Etempvar _interact tuint)))))
|}.

Definition f_check_kick_or_punch_wall := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := ((_detector, (tarray tfloat 3)) :: nil);
  fn_temps := ((_t'2, (tptr (Tstruct _Surface noattr))) :: (_t'1, tint) ::
               (_t'18, tfloat) :: (_t'17, tshort) :: (_t'16, tfloat) ::
               (_t'15, tfloat) :: (_t'14, tshort) :: (_t'13, tfloat) ::
               (_t'12, tfloat) :: (_t'11, tfloat) :: (_t'10, tuint) ::
               (_t'9, tuint) :: (_t'8, (tptr (Tstruct _Object noattr))) ::
               (_t'7, tuint) :: (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, tuint) :: (_t'4, tuint) :: (_t'3, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'3
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _flags tuint))
  (Sifthenelse (Ebinop Oand (Etempvar _t'3 tuint)
                 (Ebinop Oor
                   (Ebinop Oor (Econst_int (Int.repr 1048576) tint)
                     (Econst_int (Int.repr 2097152) tint) tint)
                   (Econst_int (Int.repr 4194304) tint) tint) tuint)
    (Ssequence
      (Ssequence
        (Sset _t'16
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
        (Ssequence
          (Sset _t'17
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _faceAngle
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort))
          (Ssequence
            (Sset _t'18
              (Ederef
                (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                  (Ebinop Oshr (Ecast (Etempvar _t'17 tshort) tushort)
                    (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                tfloat))
            (Sassign
              (Ederef
                (Ebinop Oadd (Evar _detector (tarray tfloat 3))
                  (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
              (Ebinop Oadd (Etempvar _t'16 tfloat)
                (Ebinop Omul
                  (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat)
                  (Etempvar _t'18 tfloat) tfloat) tfloat)))))
      (Ssequence
        (Ssequence
          (Sset _t'13
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
          (Ssequence
            (Sset _t'14
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _faceAngle
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort))
            (Ssequence
              (Sset _t'15
                (Ederef
                  (Ebinop Oadd
                    (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                      (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                    (Ebinop Oshr (Ecast (Etempvar _t'14 tshort) tushort)
                      (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                  tfloat))
              (Sassign
                (Ederef
                  (Ebinop Oadd (Evar _detector (tarray tfloat 3))
                    (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat)
                (Ebinop Oadd (Etempvar _t'13 tfloat)
                  (Ebinop Omul
                    (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat)
                    (Etempvar _t'15 tfloat) tfloat) tfloat)))))
        (Ssequence
          (Ssequence
            (Sset _t'12
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
            (Sassign
              (Ederef
                (Ebinop Oadd (Evar _detector (tarray tfloat 3))
                  (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
              (Etempvar _t'12 tfloat)))
          (Ssequence
            (Scall (Some _t'2)
              (Evar _resolve_and_return_wall_collisions (Tfunction
                                                          ((tptr tfloat) ::
                                                           tfloat ::
                                                           tfloat :: nil)
                                                          (tptr (Tstruct _Surface noattr))
                                                          cc_default))
              ((Evar _detector (tarray tfloat 3)) ::
               (Econst_single (Float32.of_bits (Int.repr 1117782016)) tfloat) ::
               (Econst_single (Float32.of_bits (Int.repr 1084227584)) tfloat) ::
               nil))
            (Sifthenelse (Ebinop One
                           (Etempvar _t'2 (tptr (Tstruct _Surface noattr)))
                           (Ecast (Econst_int (Int.repr 0) tint)
                             (tptr tvoid)) tint)
              (Ssequence
                (Ssequence
                  (Sset _t'10
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _action tuint))
                  (Sifthenelse (Ebinop One (Etempvar _t'10 tuint)
                                 (Econst_int (Int.repr 8389719) tint) tint)
                    (Sset _t'1 (Econst_int (Int.repr 1) tint))
                    (Ssequence
                      (Sset _t'11
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _forwardVel tfloat))
                      (Sset _t'1
                        (Ecast
                          (Ebinop Oge (Etempvar _t'11 tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                            tint) tbool)))))
                (Sifthenelse (Etempvar _t'1 tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'9
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _action tuint))
                      (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tuint)
                                     (Econst_int (Int.repr 8389504) tint)
                                     tint)
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _action tuint)
                          (Econst_int (Int.repr 8389719) tint))
                        Sskip))
                    (Ssequence
                      (Scall None
                        (Evar _mario_set_forward_vel (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tfloat :: nil) tvoid
                                                       cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Eunop Oneg
                           (Econst_single (Float32.of_bits (Int.repr 1111490560)) tfloat)
                           tfloat) :: nil))
                      (Ssequence
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
                                       (Ecast (Econst_int (Int.repr 68) tint)
                                         tuint)
                                       (Econst_int (Int.repr 16) tint) tuint)
                                     tuint)
                                   (Ebinop Oshl
                                     (Ecast (Econst_int (Int.repr 176) tint)
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
                                (Econst_int (Int.repr 18) tint) tint) tuint))))))
                  (Ssequence
                    (Sset _t'4
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _action tuint))
                    (Sifthenelse (Ebinop Oand (Etempvar _t'4 tuint)
                                   (Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 11) tint) tint)
                                   tuint)
                      (Ssequence
                        (Scall None
                          (Evar _mario_set_forward_vel (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          tfloat :: nil)
                                                         tvoid cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Eunop Oneg
                             (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                             tfloat) :: nil))
                        (Ssequence
                          (Ssequence
                            (Sset _t'6
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
                                           (Econst_int (Int.repr 68) tint)
                                           tuint)
                                         (Econst_int (Int.repr 16) tint)
                                         tuint) tuint)
                                     (Ebinop Oshl
                                       (Ecast
                                         (Econst_int (Int.repr 176) tint)
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
                                       (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                                       (Tstruct _Object noattr)) _header
                                     (Tstruct _ObjectNode noattr)) _gfx
                                   (Tstruct _GraphNodeObject noattr))
                                 _cameraToObject (tarray tfloat 3)) :: nil)))
                          (Ssequence
                            (Sset _t'5
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
                              (Ebinop Oor (Etempvar _t'5 tuint)
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 18) tint) tint)
                                tuint)))))
                      Sskip))))
              Sskip)))))
    Sskip))
|}.

Definition f_mario_process_interactions := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_interactType, tuint) ::
               (_object, (tptr (Tstruct _Object noattr))) :: (_t'5, tint) ::
               (_t'4, tint) :: (_t'3, tuint) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: (_t'1, tint) ::
               (_t'21, tshort) :: (_t'20, tuint) :: (_t'19, tuint) ::
               (_t'18, tuint) :: (_t'17, tuint) ::
               (_t'16,
                (tptr (Tfunction
                        ((tptr (Tstruct _MarioState noattr)) :: tuint ::
                         (tptr (Tstruct _Object noattr)) :: nil) tuint
                        cc_default))) :: (_t'15, tint) :: (_t'14, tuint) ::
               (_t'13, tuchar) :: (_t'12, tshort) :: (_t'11, tshort) ::
               (_t'10, tuint) :: (_t'9, tuint) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tuint) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _sDelayInvincTimer tuchar) (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'20
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _action tuint))
        (Sifthenelse (Ebinop Oand (Etempvar _t'20 tuint)
                       (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 17) tint) tint) tuint)
          (Sset _t'1 (Econst_int (Int.repr 1) tint))
          (Ssequence
            (Sset _t'21
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _invincTimer tshort))
            (Sset _t'1
              (Ecast
                (Ebinop One (Etempvar _t'21 tshort)
                  (Econst_int (Int.repr 0) tint) tint) tbool)))))
      (Sassign (Evar _sInvulnerable tshort) (Etempvar _t'1 tint)))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'18
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _action tuint))
          (Sifthenelse (Eunop Onotbool
                         (Ebinop Oand (Etempvar _t'18 tuint)
                           (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                             (Econst_int (Int.repr 12) tint) tint) tuint)
                         tint)
            (Ssequence
              (Sset _t'19
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _collidedObjInteractTypes
                  tuint))
              (Sset _t'4
                (Ecast
                  (Ebinop One (Etempvar _t'19 tuint)
                    (Econst_int (Int.repr 0) tint) tint) tbool)))
            (Sset _t'4 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'4 tint)
          (Ssequence
            (Sset _i (Econst_int (Int.repr 0) tint))
            (Sloop
              (Ssequence
                (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                               (Ecast
                                 (Ebinop Odiv
                                   (Esizeof (tarray (Tstruct _InteractionHandler noattr) 31) tulong)
                                   (Esizeof (Tstruct _InteractionHandler noattr) tulong)
                                   tulong) tint) tint)
                  Sskip
                  Sbreak)
                (Ssequence
                  (Sset _interactType
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Evar _sInteractionHandlers (tarray (Tstruct _InteractionHandler noattr) 31))
                          (Etempvar _i tint)
                          (tptr (Tstruct _InteractionHandler noattr)))
                        (Tstruct _InteractionHandler noattr)) _interactType
                      tuint))
                  (Ssequence
                    (Sset _t'14
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr))
                        _collidedObjInteractTypes tuint))
                    (Sifthenelse (Ebinop Oand (Etempvar _t'14 tuint)
                                   (Etempvar _interactType tuint) tuint)
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'2)
                            (Evar _mario_get_collided_object (Tfunction
                                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                                tuint :: nil)
                                                               (tptr (Tstruct _Object noattr))
                                                               cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Etempvar _interactType tuint) :: nil))
                          (Sset _object
                            (Etempvar _t'2 (tptr (Tstruct _Object noattr)))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'17
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr))
                                _collidedObjInteractTypes tuint))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr))
                                _collidedObjInteractTypes tuint)
                              (Ebinop Oand (Etempvar _t'17 tuint)
                                (Eunop Onotint (Etempvar _interactType tuint)
                                  tuint) tuint)))
                          (Ssequence
                            (Sset _t'15
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _object (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _rawData
                                      (Tunion __665 noattr)) _asS32
                                    (tarray tint 80))
                                  (Econst_int (Int.repr 43) tint)
                                  (tptr tint)) tint))
                            (Sifthenelse (Eunop Onotbool
                                           (Ebinop Oand (Etempvar _t'15 tint)
                                             (Ebinop Oshl
                                               (Econst_int (Int.repr 1) tint)
                                               (Econst_int (Int.repr 15) tint)
                                               tint) tint) tint)
                              (Ssequence
                                (Ssequence
                                  (Sset _t'16
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Evar _sInteractionHandlers (tarray (Tstruct _InteractionHandler noattr) 31))
                                          (Etempvar _i tint)
                                          (tptr (Tstruct _InteractionHandler noattr)))
                                        (Tstruct _InteractionHandler noattr))
                                      _handler
                                      (tptr (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint ::
                                               (tptr (Tstruct _Object noattr)) ::
                                               nil) tuint cc_default))))
                                  (Scall (Some _t'3)
                                    (Etempvar _t'16 (tptr (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             tuint ::
                                                             (tptr (Tstruct _Object noattr)) ::
                                                             nil) tuint
                                                            cc_default)))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     (Etempvar _interactType tuint) ::
                                     (Etempvar _object (tptr (Tstruct _Object noattr))) ::
                                     nil)))
                                (Sifthenelse (Etempvar _t'3 tuint)
                                  Sbreak
                                  Sskip))
                              Sskip))))
                      Sskip))))
              (Sset _i
                (Ebinop Oadd (Etempvar _i tint)
                  (Econst_int (Int.repr 1) tint) tint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'12
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _invincTimer tshort))
            (Sifthenelse (Ebinop Ogt (Etempvar _t'12 tshort)
                           (Econst_int (Int.repr 0) tint) tint)
              (Ssequence
                (Sset _t'13 (Evar _sDelayInvincTimer tuchar))
                (Sset _t'5
                  (Ecast (Eunop Onotbool (Etempvar _t'13 tuchar) tint) tbool)))
              (Sset _t'5 (Econst_int (Int.repr 0) tint))))
          (Sifthenelse (Etempvar _t'5 tint)
            (Ssequence
              (Sset _t'11
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _invincTimer tshort))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _invincTimer tshort)
                (Ebinop Osub (Etempvar _t'11 tshort)
                  (Econst_int (Int.repr 1) tint) tint)))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _check_kick_or_punch_wall (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Ssequence
              (Sset _t'10
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _flags tuint))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _flags tuint)
                (Ebinop Oand (Etempvar _t'10 tuint)
                  (Ebinop Oand
                    (Ebinop Oand
                      (Eunop Onotint (Econst_int (Int.repr 1048576) tint)
                        tint)
                      (Eunop Onotint (Econst_int (Int.repr 2097152) tint)
                        tint) tint)
                    (Eunop Onotint (Econst_int (Int.repr 4194304) tint) tint)
                    tint) tuint)))
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
                      (Ederef (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _collidedObjInteractTypes
                      tuint))
                  (Sifthenelse (Eunop Onotbool
                                 (Ebinop Oand (Etempvar _t'9 tuint)
                                   (Ebinop Oor
                                     (Ebinop Oshl
                                       (Econst_int (Int.repr 1) tint)
                                       (Econst_int (Int.repr 11) tint) tint)
                                     (Ebinop Oshl
                                       (Econst_int (Int.repr 1) tint)
                                       (Econst_int (Int.repr 2) tint) tint)
                                     tint) tuint) tint)
                    (Sassign (Evar _sDisplayingDoorText tuchar)
                      (Econst_int (Int.repr 0) tint))
                    Sskip)))
              (Ssequence
                (Sset _t'6
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _marioObj
                    (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'7
                    (Efield
                      (Ederef (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _collidedObjInteractTypes
                      tuint))
                  (Sifthenelse (Eunop Onotbool
                                 (Ebinop Oand (Etempvar _t'7 tuint)
                                   (Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 13) tint) tint)
                                   tuint) tint)
                    (Sassign (Evar _sJustTeleported tuchar)
                      (Econst_int (Int.repr 0) tint))
                    Sskip))))))))))
|}.

Definition f_check_death_barrier := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tshort) :: (_t'6, tuint) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: (_t'4, tfloat) ::
               (_t'3, tfloat) :: nil);
  fn_body :=
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
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _floorHeight tfloat))
    (Sifthenelse (Ebinop Olt (Etempvar _t'3 tfloat)
                   (Ebinop Oadd (Etempvar _t'4 tfloat)
                     (Econst_single (Float32.of_bits (Int.repr 1157627904)) tfloat)
                     tfloat) tint)
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _level_trigger_warp (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 19) tint) :: nil))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tshort)
                         (Econst_int (Int.repr 20) tint) tint)
            (Ssequence
              (Sset _t'6
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _flags tuint))
              (Sset _t'2
                (Ecast
                  (Eunop Onotbool
                    (Ebinop Oand (Etempvar _t'6 tuint)
                      (Econst_int (Int.repr 262144) tint) tuint) tint) tbool)))
            (Sset _t'2 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'2 tint)
          (Ssequence
            (Sset _t'5
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
                     (Ederef (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                       (Tstruct _Object noattr)) _header
                     (Tstruct _ObjectNode noattr)) _gfx
                   (Tstruct _GraphNodeObject noattr)) _cameraToObject
                 (tarray tfloat 3)) :: nil)))
          Sskip))
      Sskip)))
|}.

Definition f_check_lava_boost := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) :: (_t'8, tfloat) ::
               (_t'7, tfloat) :: (_t'6, tuint) :: (_t'5, tuint) ::
               (_t'4, tuchar) :: (_t'3, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _action tuint))
    (Sifthenelse (Eunop Onotbool
                   (Ebinop Oand (Etempvar _t'6 tuint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 16) tint) tint) tuint) tint)
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
                (Tstruct _MarioState noattr)) _floorHeight tfloat))
          (Sset _t'2
            (Ecast
              (Ebinop Olt (Etempvar _t'7 tfloat)
                (Ebinop Oadd (Etempvar _t'8 tfloat)
                  (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                  tfloat) tint) tbool))))
      (Sset _t'2 (Econst_int (Int.repr 0) tint))))
  (Sifthenelse (Etempvar _t'2 tint)
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _flags tuint))
        (Sifthenelse (Eunop Onotbool
                       (Ebinop Oand (Etempvar _t'3 tuint)
                         (Econst_int (Int.repr 4) tint) tuint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'5
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _flags tuint))
              (Sifthenelse (Ebinop Oand (Etempvar _t'5 tuint)
                             (Econst_int (Int.repr 16) tint) tuint)
                (Sset _t'1 (Ecast (Econst_int (Int.repr 12) tint) tint))
                (Sset _t'1 (Ecast (Econst_int (Int.repr 18) tint) tint))))
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _hurtCounter tuchar))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _hurtCounter tuchar)
                (Ebinop Oadd (Etempvar _t'4 tuchar) (Etempvar _t'1 tint)
                  tint))))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _update_mario_sound_and_camera (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Scall None
          (Evar _drop_and_set_mario_action (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tuint :: tuint :: nil) tint
                                             cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 16910519) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))))
    Sskip))
|}.

Definition f_pss_begin_slide := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr)) _flags tshort))
  (Sifthenelse (Eunop Onotbool
                 (Ebinop Oand (Etempvar _t'1 tshort)
                   (Econst_int (Int.repr 64) tint) tint) tint)
    (Ssequence
      (Scall None
        (Evar _level_control_timer (Tfunction (tint :: nil) tushort
                                     cc_default))
        ((Econst_int (Int.repr 0) tint) :: nil))
      (Ssequence
        (Scall None
          (Evar _level_control_timer (Tfunction (tint :: nil) tushort
                                       cc_default))
          ((Econst_int (Int.repr 1) tint) :: nil))
        (Sassign (Evar _sPSSSlideStarted tuchar)
          (Econst_int (Int.repr 1) tint))))
    Sskip))
|}.

Definition f_pss_end_slide := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_slideTime, tushort) :: (_t'1, tushort) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: (_t'2, tuchar) ::
               nil);
  fn_body :=
(Ssequence
  (Sset _t'2 (Evar _sPSSSlideStarted tuchar))
  (Sifthenelse (Etempvar _t'2 tuchar)
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _level_control_timer (Tfunction (tint :: nil) tushort
                                       cc_default))
          ((Econst_int (Int.repr 2) tint) :: nil))
        (Sset _slideTime (Ecast (Etempvar _t'1 tushort) tushort)))
      (Ssequence
        (Sifthenelse (Ebinop Olt (Etempvar _slideTime tushort)
                       (Econst_int (Int.repr 630) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'3
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioObj
                  (tptr (Tstruct _Object noattr))))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __665 noattr)) _asS32 (tarray tint 80))
                    (Econst_int (Int.repr 64) tint) (tptr tint)) tint)
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 24) tint) tint)))
            (Scall None
              (Evar _spawn_default_star (Tfunction
                                          (tfloat :: tfloat :: tfloat :: nil)
                                          tvoid cc_default))
              ((Eunop Oneg
                 (Econst_single (Float32.of_bits (Int.repr 1170649088)) tfloat)
                 tfloat) ::
               (Eunop Oneg
                 (Econst_single (Float32.of_bits (Int.repr 1166434304)) tfloat)
                 tfloat) ::
               (Econst_single (Float32.of_bits (Int.repr 1167253504)) tfloat) ::
               nil)))
          Sskip)
        (Sassign (Evar _sPSSSlideStarted tuchar)
          (Econst_int (Int.repr 0) tint))))
    Sskip))
|}.

Definition f_mario_handle_special_floors := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_floorType, tint) :: (_t'1, tint) :: (_t'6, tuint) ::
               (_t'5, (tptr (Tstruct _Surface noattr))) :: (_t'4, tuint) ::
               (_t'3, tuint) :: (_t'2, (tptr (Tstruct _Surface noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _action tuint))
    (Sifthenelse (Ebinop Oeq
                   (Ebinop Oand (Etempvar _t'6 tuint)
                     (Econst_int (Int.repr 448) tint) tuint)
                   (Ebinop Oshl (Econst_int (Int.repr 4) tint)
                     (Econst_int (Int.repr 6) tint) tint) tint)
      (Sreturn None)
      Sskip))
  (Ssequence
    (Sset _t'2
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _floor
        (tptr (Tstruct _Surface noattr))))
    (Sifthenelse (Ebinop One (Etempvar _t'2 (tptr (Tstruct _Surface noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _floor
              (tptr (Tstruct _Surface noattr))))
          (Sset _floorType
            (Efield
              (Ederef (Etempvar _t'5 (tptr (Tstruct _Surface noattr)))
                (Tstruct _Surface noattr)) _type tshort)))
        (Ssequence
          (Sswitch (Etempvar _floorType tint)
            (LScons (Some 10)
              Sskip
              (LScons (Some 56)
                (Ssequence
                  (Scall None
                    (Evar _check_death_barrier (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tvoid cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  Sbreak)
                (LScons (Some 50)
                  (Ssequence
                    (Scall None
                      (Evar _level_trigger_warp (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tint :: nil) tshort
                                                  cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 19) tint) :: nil))
                    Sbreak)
                  (LScons (Some 51)
                    (Ssequence
                      (Scall None
                        (Evar _pss_begin_slide (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tvoid cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      Sbreak)
                    (LScons (Some 52)
                      (Ssequence
                        (Scall None
                          (Evar _pss_end_slide (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tvoid cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        Sbreak)
                      LSnil))))))
          (Ssequence
            (Ssequence
              (Sset _t'3
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _action tuint))
              (Sifthenelse (Eunop Onotbool
                             (Ebinop Oand (Etempvar _t'3 tuint)
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 11) tint) tint) tuint)
                             tint)
                (Ssequence
                  (Sset _t'4
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _action tuint))
                  (Sset _t'1
                    (Ecast
                      (Eunop Onotbool
                        (Ebinop Oand (Etempvar _t'4 tuint)
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 13) tint) tint) tuint)
                        tint) tbool)))
                (Sset _t'1 (Econst_int (Int.repr 0) tint))))
            (Sifthenelse (Etempvar _t'1 tint)
              (Sswitch (Etempvar _floorType tint)
                (LScons (Some 1)
                  (Ssequence
                    (Scall None
                      (Evar _check_lava_boost (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tvoid cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    Sbreak)
                  LSnil))
              Sskip))))
      Sskip)))
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
 Composite _HudDisplay Struct
   (Member_plain _lives tshort :: Member_plain _coins tshort ::
    Member_plain _stars tshort :: Member_plain _wedges tshort ::
    Member_plain _keys tshort :: Member_plain _flags tshort ::
    Member_plain _timer tushort :: nil)
   noattr ::
 Composite _BullyCollisionData Struct
   (Member_plain _conversionRatio tfloat :: Member_plain _radius tfloat ::
    Member_plain _posX tfloat :: Member_plain _posZ tfloat ::
    Member_plain _velX tfloat :: Member_plain _velZ tfloat :: nil)
   noattr ::
 Composite _ChainSegment Struct
   (Member_plain _posX tfloat :: Member_plain _posY tfloat ::
    Member_plain _posZ tfloat :: Member_plain _pitch tshort ::
    Member_plain _yaw tshort :: Member_plain _roll tshort :: nil)
   noattr ::
 Composite _InteractionHandler Struct
   (Member_plain _interactType tuint ::
    Member_plain _handler
      (tptr (Tfunction
              ((tptr (Tstruct _MarioState noattr)) :: tuint ::
               (tptr (Tstruct _Object noattr)) :: nil) tuint cc_default)) ::
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
 (_segmented_to_virtual,
   Gfun(External (EF_external "segmented_to_virtual"
                   (mksignature (AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr tvoid) :: nil) (tptr tvoid) cc_default)) ::
 (_virtual_to_segmented,
   Gfun(External (EF_external "virtual_to_segmented"
                   (mksignature (AST.Xint :: AST.Xptr :: nil) AST.Xptr
                     cc_default)) (tuint :: (tptr tvoid) :: nil) (tptr tvoid)
     cc_default)) ::
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
     cc_default)) :: (_gCurrCourseNum, Gvar v_gCurrCourseNum) ::
 (_gCurrSaveFileNum, Gvar v_gCurrSaveFileNum) ::
 (_warp_pipe_seg3_collision_03009AC8, Gvar v_warp_pipe_seg3_collision_03009AC8) ::
 (_play_sound,
   Gfun(External (EF_external "play_sound"
                   (mksignature (AST.Xint :: AST.Xptr :: nil) AST.Xvoid
                     cc_default)) (tint :: (tptr tfloat) :: nil) tvoid
     cc_default)) ::
 (_drop_queued_background_music,
   Gfun(External (EF_external "drop_queued_background_music"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_spawn_star_no_level_exit,
   Gfun(External (EF_external "bhv_spawn_star_no_level_exit"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tuint :: nil) tvoid cc_default)) ::
 (_bhvKoopaShellUnderwater, Gvar v_bhvKoopaShellUnderwater) ::
 (_bhvBowser, Gvar v_bhvBowser) ::
 (_bhvCarrySomething3, Gvar v_bhvCarrySomething3) ::
 (_bhvCarrySomething4, Gvar v_bhvCarrySomething4) ::
 (_bhvCarrySomething5, Gvar v_bhvCarrySomething5) ::
 (_bhvStarKeyCollectionPuffSpawner, Gvar v_bhvStarKeyCollectionPuffSpawner) ::
 (_bhvWingCap, Gvar v_bhvWingCap) :: (_bhvMetalCap, Gvar v_bhvMetalCap) ::
 (_bhvNormalCap, Gvar v_bhvNormalCap) ::
 (_bhvVanishCap, Gvar v_bhvVanishCap) :: (_gSineTable, Gvar v_gSineTable) ::
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
 (_find_floor,
   Gfun(External (EF_external "find_floor"
                   (mksignature
                     (AST.Xsingle :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xptr :: nil) AST.Xsingle cc_default))
     (tfloat :: tfloat :: tfloat ::
      (tptr (tptr (Tstruct _Surface noattr))) :: nil) tfloat cc_default)) ::
 (_gGlobalTimer, Gvar v_gGlobalTimer) ::
 (_gMarioState, Gvar v_gMarioState) :: (_gHudDisplay, Gvar v_gHudDisplay) ::
 (_level_control_timer,
   Gfun(External (EF_external "level_control_timer"
                   (mksignature (AST.Xint :: nil) AST.Xint16unsigned
                     cc_default)) (tint :: nil) tushort cc_default)) ::
 (_level_trigger_warp,
   Gfun(External (EF_external "level_trigger_warp"
                   (mksignature (AST.Xptr :: AST.Xint :: nil)
                     AST.Xint16signed cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tint :: nil) tshort cc_default)) ::
 (_mario_set_forward_vel,
   Gfun(External (EF_external "mario_set_forward_vel"
                   (mksignature (AST.Xptr :: AST.Xsingle :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tfloat :: nil) tvoid
     cc_default)) ::
 (_resolve_and_return_wall_collisions,
   Gfun(External (EF_external "resolve_and_return_wall_collisions"
                   (mksignature
                     (AST.Xptr :: AST.Xsingle :: AST.Xsingle :: nil) AST.Xptr
                     cc_default)) ((tptr tfloat) :: tfloat :: tfloat :: nil)
     (tptr (Tstruct _Surface noattr)) cc_default)) ::
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
 (_transfer_bully_speed,
   Gfun(External (EF_external "transfer_bully_speed"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _BullyCollisionData noattr)) ::
      (tptr (Tstruct _BullyCollisionData noattr)) :: nil) tvoid cc_default)) ::
 (_init_bully_collision_data,
   Gfun(External (EF_external "init_bully_collision_data"
                   (mksignature
                     (AST.Xptr :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xsingle :: AST.Xint16signed :: AST.Xsingle ::
                      AST.Xsingle :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _BullyCollisionData noattr)) :: tfloat :: tfloat ::
      tfloat :: tshort :: tfloat :: tfloat :: nil) tvoid cc_default)) ::
 (_spawn_default_star,
   Gfun(External (EF_external "spawn_default_star"
                   (mksignature
                     (AST.Xsingle :: AST.Xsingle :: AST.Xsingle :: nil)
                     AST.Xvoid cc_default))
     (tfloat :: tfloat :: tfloat :: nil) tvoid cc_default)) ::
 (_obj_set_held_state,
   Gfun(External (EF_external "obj_set_held_state"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _Object noattr)) :: (tptr tuint) :: nil) tvoid
     cc_default)) ::
 (_spawn_object,
   Gfun(External (EF_external "spawn_object"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xptr :: nil)
                     AST.Xptr cc_default))
     ((tptr (Tstruct _Object noattr)) :: tint :: (tptr tuint) :: nil)
     (tptr (Tstruct _Object noattr)) cc_default)) ::
 (_save_file_collect_star_or_key,
   Gfun(External (EF_external "save_file_collect_star_or_key"
                   (mksignature (AST.Xint16signed :: AST.Xint16signed :: nil)
                     AST.Xvoid cc_default)) (tshort :: tshort :: nil) tvoid
     cc_default)) ::
 (_save_file_get_total_star_count,
   Gfun(External (EF_external "save_file_get_total_star_count"
                   (mksignature (AST.Xint :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint cc_default)) (tint :: tint :: tint :: nil) tint
     cc_default)) ::
 (_save_file_set_flags,
   Gfun(External (EF_external "save_file_set_flags"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tuint :: nil) tvoid cc_default)) ::
 (_save_file_clear_flags,
   Gfun(External (EF_external "save_file_clear_flags"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tuint :: nil) tvoid cc_default)) ::
 (_save_file_get_flags,
   Gfun(External (EF_external "save_file_get_flags"
                   (mksignature nil AST.Xint cc_default)) nil tuint
     cc_default)) ::
 (_save_file_set_cap_pos,
   Gfun(External (EF_external "save_file_set_cap_pos"
                   (mksignature
                     (AST.Xint16signed :: AST.Xint16signed ::
                      AST.Xint16signed :: nil) AST.Xvoid cc_default))
     (tshort :: tshort :: tshort :: nil) tvoid cc_default)) ::
 (_fadeout_level_music,
   Gfun(External (EF_external "fadeout_level_music"
                   (mksignature (AST.Xint16signed :: nil) AST.Xvoid
                     cc_default)) (tshort :: nil) tvoid cc_default)) ::
 (_play_shell_music,
   Gfun(External (EF_external "play_shell_music"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_stop_shell_music,
   Gfun(External (EF_external "stop_shell_music"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_play_cap_music,
   Gfun(External (EF_external "play_cap_music"
                   (mksignature (AST.Xint16unsigned :: nil) AST.Xvoid
                     cc_default)) (tushort :: nil) tvoid cc_default)) ::
 (_sDelayInvincTimer, Gvar v_sDelayInvincTimer) ::
 (_sInvulnerable, Gvar v_sInvulnerable) ::
 (_sInteractionHandlers, Gvar v_sInteractionHandlers) ::
 (_sForwardKnockbackActions, Gvar v_sForwardKnockbackActions) ::
 (_sBackwardKnockbackActions, Gvar v_sBackwardKnockbackActions) ::
 (_sDisplayingDoorText, Gvar v_sDisplayingDoorText) ::
 (_sJustTeleported, Gvar v_sJustTeleported) ::
 (_sPSSSlideStarted, Gvar v_sPSSSlideStarted) ::
 (_get_mario_cap_flag, Gfun(Internal f_get_mario_cap_flag)) ::
 (_object_facing_mario, Gfun(Internal f_object_facing_mario)) ::
 (_mario_obj_angle_to_object, Gfun(Internal f_mario_obj_angle_to_object)) ::
 (_determine_interaction, Gfun(Internal f_determine_interaction)) ::
 (_attack_object, Gfun(Internal f_attack_object)) ::
 (_mario_stop_riding_object, Gfun(Internal f_mario_stop_riding_object)) ::
 (_mario_grab_used_object, Gfun(Internal f_mario_grab_used_object)) ::
 (_mario_drop_held_object, Gfun(Internal f_mario_drop_held_object)) ::
 (_mario_throw_held_object, Gfun(Internal f_mario_throw_held_object)) ::
 (_mario_stop_riding_and_holding, Gfun(Internal f_mario_stop_riding_and_holding)) ::
 (_does_mario_have_normal_cap_on_head, Gfun(Internal f_does_mario_have_normal_cap_on_head)) ::
 (_mario_blow_off_cap, Gfun(Internal f_mario_blow_off_cap)) ::
 (_mario_lose_cap_to_enemy, Gfun(Internal f_mario_lose_cap_to_enemy)) ::
 (_mario_retrieve_cap, Gfun(Internal f_mario_retrieve_cap)) ::
 (_able_to_grab_object, Gfun(Internal f_able_to_grab_object)) ::
 (_mario_get_collided_object, Gfun(Internal f_mario_get_collided_object)) ::
 (_mario_check_object_grab, Gfun(Internal f_mario_check_object_grab)) ::
 (_bully_knock_back_mario, Gfun(Internal f_bully_knock_back_mario)) ::
 (_bounce_off_object, Gfun(Internal f_bounce_off_object)) ::
 (_hit_object_from_below, Gfun(Internal f_hit_object_from_below)) ::
 (_determine_knockback_action, Gfun(Internal f_determine_knockback_action)) ::
 (_push_mario_out_of_object, Gfun(Internal f_push_mario_out_of_object)) ::
 (_bounce_back_from_attack, Gfun(Internal f_bounce_back_from_attack)) ::
 (_should_push_or_pull_door, Gfun(Internal f_should_push_or_pull_door)) ::
 (_take_damage_from_interact_object, Gfun(Internal f_take_damage_from_interact_object)) ::
 (_take_damage_and_knock_back, Gfun(Internal f_take_damage_and_knock_back)) ::
 (_reset_mario_pitch, Gfun(Internal f_reset_mario_pitch)) ::
 (_interact_coin, Gfun(Internal f_interact_coin)) ::
 (_interact_water_ring, Gfun(Internal f_interact_water_ring)) ::
 (_interact_star_or_key, Gfun(Internal f_interact_star_or_key)) ::
 (_interact_bbh_entrance, Gfun(Internal f_interact_bbh_entrance)) ::
 (_interact_warp, Gfun(Internal f_interact_warp)) ::
 (_interact_warp_door, Gfun(Internal f_interact_warp_door)) ::
 (_get_door_save_file_flag, Gfun(Internal f_get_door_save_file_flag)) ::
 (_interact_door, Gfun(Internal f_interact_door)) ::
 (_interact_cannon_base, Gfun(Internal f_interact_cannon_base)) ::
 (_interact_igloo_barrier, Gfun(Internal f_interact_igloo_barrier)) ::
 (_interact_tornado, Gfun(Internal f_interact_tornado)) ::
 (_interact_whirlpool, Gfun(Internal f_interact_whirlpool)) ::
 (_interact_strong_wind, Gfun(Internal f_interact_strong_wind)) ::
 (_interact_flame, Gfun(Internal f_interact_flame)) ::
 (_interact_snufit_bullet, Gfun(Internal f_interact_snufit_bullet)) ::
 (_interact_clam_or_bubba, Gfun(Internal f_interact_clam_or_bubba)) ::
 (_interact_bully, Gfun(Internal f_interact_bully)) ::
 (_interact_shock, Gfun(Internal f_interact_shock)) ::
 (_interact_mr_blizzard, Gfun(Internal f_interact_mr_blizzard)) ::
 (_interact_hit_from_below, Gfun(Internal f_interact_hit_from_below)) ::
 (_interact_bounce_top, Gfun(Internal f_interact_bounce_top)) ::
 (_interact_unknown_08, Gfun(Internal f_interact_unknown_08)) ::
 (_interact_damage, Gfun(Internal f_interact_damage)) ::
 (_interact_breakable, Gfun(Internal f_interact_breakable)) ::
 (_interact_koopa_shell, Gfun(Internal f_interact_koopa_shell)) ::
 (_check_object_grab_mario, Gfun(Internal f_check_object_grab_mario)) ::
 (_interact_pole, Gfun(Internal f_interact_pole)) ::
 (_interact_hoot, Gfun(Internal f_interact_hoot)) ::
 (_interact_cap, Gfun(Internal f_interact_cap)) ::
 (_interact_grabbable, Gfun(Internal f_interact_grabbable)) ::
 (_mario_can_talk, Gfun(Internal f_mario_can_talk)) ::
 (_check_read_sign, Gfun(Internal f_check_read_sign)) ::
 (_check_npc_talk, Gfun(Internal f_check_npc_talk)) ::
 (_interact_text, Gfun(Internal f_interact_text)) ::
 (_check_kick_or_punch_wall, Gfun(Internal f_check_kick_or_punch_wall)) ::
 (_mario_process_interactions, Gfun(Internal f_mario_process_interactions)) ::
 (_check_death_barrier, Gfun(Internal f_check_death_barrier)) ::
 (_check_lava_boost, Gfun(Internal f_check_lava_boost)) ::
 (_pss_begin_slide, Gfun(Internal f_pss_begin_slide)) ::
 (_pss_end_slide, Gfun(Internal f_pss_end_slide)) ::
 (_mario_handle_special_floors, Gfun(Internal f_mario_handle_special_floors)) ::
 nil).

Definition public_idents : list ident :=
(_mario_handle_special_floors :: _pss_end_slide :: _pss_begin_slide ::
 _check_lava_boost :: _check_death_barrier :: _mario_process_interactions ::
 _check_kick_or_punch_wall :: _interact_text :: _check_npc_talk ::
 _check_read_sign :: _mario_can_talk :: _interact_grabbable ::
 _interact_cap :: _interact_hoot :: _interact_pole ::
 _check_object_grab_mario :: _interact_koopa_shell :: _interact_breakable ::
 _interact_damage :: _interact_unknown_08 :: _interact_bounce_top ::
 _interact_hit_from_below :: _interact_mr_blizzard :: _interact_shock ::
 _interact_bully :: _interact_clam_or_bubba :: _interact_snufit_bullet ::
 _interact_flame :: _interact_strong_wind :: _interact_whirlpool ::
 _interact_tornado :: _interact_igloo_barrier :: _interact_cannon_base ::
 _interact_door :: _get_door_save_file_flag :: _interact_warp_door ::
 _interact_warp :: _interact_bbh_entrance :: _interact_star_or_key ::
 _interact_water_ring :: _interact_coin :: _reset_mario_pitch ::
 _take_damage_and_knock_back :: _take_damage_from_interact_object ::
 _should_push_or_pull_door :: _bounce_back_from_attack ::
 _push_mario_out_of_object :: _determine_knockback_action ::
 _hit_object_from_below :: _bounce_off_object :: _bully_knock_back_mario ::
 _mario_check_object_grab :: _mario_get_collided_object ::
 _able_to_grab_object :: _mario_retrieve_cap :: _mario_lose_cap_to_enemy ::
 _mario_blow_off_cap :: _does_mario_have_normal_cap_on_head ::
 _mario_stop_riding_and_holding :: _mario_throw_held_object ::
 _mario_drop_held_object :: _mario_grab_used_object ::
 _mario_stop_riding_object :: _attack_object :: _determine_interaction ::
 _mario_obj_angle_to_object :: _object_facing_mario :: _get_mario_cap_flag ::
 _sInvulnerable :: _sDelayInvincTimer :: _play_cap_music ::
 _stop_shell_music :: _play_shell_music :: _fadeout_level_music ::
 _save_file_set_cap_pos :: _save_file_get_flags :: _save_file_clear_flags ::
 _save_file_set_flags :: _save_file_get_total_star_count ::
 _save_file_collect_star_or_key :: _spawn_object :: _obj_set_held_state ::
 _spawn_default_star :: _init_bully_collision_data ::
 _transfer_bully_speed :: _drop_and_set_mario_action :: _set_mario_action ::
 _update_mario_sound_and_camera :: _resolve_and_return_wall_collisions ::
 _mario_set_forward_vel :: _level_trigger_warp :: _level_control_timer ::
 _gHudDisplay :: _gMarioState :: _gGlobalTimer :: _find_floor ::
 _f32_find_wall_collision :: _atan2s :: _gSineTable :: _bhvVanishCap ::
 _bhvNormalCap :: _bhvMetalCap :: _bhvWingCap ::
 _bhvStarKeyCollectionPuffSpawner :: _bhvCarrySomething5 ::
 _bhvCarrySomething4 :: _bhvCarrySomething3 :: _bhvBowser ::
 _bhvKoopaShellUnderwater :: _bhv_spawn_star_no_level_exit ::
 _drop_queued_background_music :: _play_sound ::
 _warp_pipe_seg3_collision_03009AC8 :: _gCurrSaveFileNum ::
 _gCurrCourseNum :: _set_camera_mode :: _set_camera_shake_from_hit ::
 _virtual_to_segmented :: _segmented_to_virtual :: _sqrtf ::
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


