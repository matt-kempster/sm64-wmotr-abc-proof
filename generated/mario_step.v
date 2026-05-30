(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Produced by: pipeline/clightgen.sh
   From source: vendor/sm64/src/game/mario_step.c
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
  Definition source_file := "vendor/sm64/src/game/mario_step.c".
  Definition normalized := true.
End Info.

Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _Area : ident := $"Area".
Definition _BullyCollisionData : ident := $"BullyCollisionData".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _Controller : ident := $"Controller".
Definition _DmaHandlerList : ident := $"DmaHandlerList".
Definition _DmaTable : ident := $"DmaTable".
Definition _GraphNode : ident := $"GraphNode".
Definition _GraphNodeObject : ident := $"GraphNodeObject".
Definition _MarioBodyState : ident := $"MarioBodyState".
Definition _MarioState : ident := $"MarioState".
Definition _Object : ident := $"Object".
Definition _ObjectNode : ident := $"ObjectNode".
Definition _OffsetSizePair : ident := $"OffsetSizePair".
Definition _PlayerCameraState : ident := $"PlayerCameraState".
Definition _SpawnInfo : ident := $"SpawnInfo".
Definition _Surface : ident := $"Surface".
Definition _Waypoint : ident := $"Waypoint".
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
Definition _apply_gravity : ident := $"apply_gravity".
Definition _apply_twirl_gravity : ident := $"apply_twirl_gravity".
Definition _apply_vertical_wind : ident := $"apply_vertical_wind".
Definition _area : ident := $"area".
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
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _bufTarget : ident := $"bufTarget".
Definition _button : ident := $"button".
Definition _buttonDown : ident := $"buttonDown".
Definition _buttonPressed : ident := $"buttonPressed".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _capState : ident := $"capState".
Definition _capTimer : ident := $"capTimer".
Definition _ceil : ident := $"ceil".
Definition _ceilHeight : ident := $"ceilHeight".
Definition _check_ledge_grab : ident := $"check_ledge_grab".
Definition _children : ident := $"children".
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
Definition _data : ident := $"data".
Definition _displacementX : ident := $"displacementX".
Definition _displacementZ : ident := $"displacementZ".
Definition _dmaTable : ident := $"dmaTable".
Definition _doubleJumpTimer : ident := $"doubleJumpTimer".
Definition _drop_and_set_mario_action : ident := $"drop_and_set_mario_action".
Definition _errnum : ident := $"errnum".
Definition _eyeState : ident := $"eyeState".
Definition _faceAngle : ident := $"faceAngle".
Definition _fadeWarpOpacity : ident := $"fadeWarpOpacity".
Definition _filler : ident := $"filler".
Definition _find_floor : ident := $"find_floor".
Definition _find_water_level : ident := $"find_water_level".
Definition _flags : ident := $"flags".
Definition _floor : ident := $"floor".
Definition _floorAngle : ident := $"floorAngle".
Definition _floorDYaw : ident := $"floorDYaw".
Definition _floorHeight : ident := $"floorHeight".
Definition _floorType : ident := $"floorType".
Definition _force : ident := $"force".
Definition _forwardVel : ident := $"forwardVel".
Definition _framesSinceA : ident := $"framesSinceA".
Definition _framesSinceB : ident := $"framesSinceB".
Definition _gGlobalTimer : ident := $"gGlobalTimer".
Definition _gSineTable : ident := $"gSineTable".
Definition _gWaterSurfacePseudoFloor : ident := $"gWaterSurfacePseudoFloor".
Definition _get_additive_y_vel_for_jumps : ident := $"get_additive_y_vel_for_jumps".
Definition _gettingBlownGravity : ident := $"gettingBlownGravity".
Definition _gfx : ident := $"gfx".
Definition _grabPos : ident := $"grabPos".
Definition _handState : ident := $"handState".
Definition _headAngle : ident := $"headAngle".
Definition _header : ident := $"header".
Definition _healCounter : ident := $"healCounter".
Definition _health : ident := $"health".
Definition _heaviness : ident := $"heaviness".
Definition _heldObj : ident := $"heldObj".
Definition _heldObjLastPosition : ident := $"heldObjLastPosition".
Definition _hitboxDownOffset : ident := $"hitboxDownOffset".
Definition _hitboxHeight : ident := $"hitboxHeight".
Definition _hitboxRadius : ident := $"hitboxRadius".
Definition _hurtCounter : ident := $"hurtCounter".
Definition _hurtboxHeight : ident := $"hurtboxHeight".
Definition _hurtboxRadius : ident := $"hurtboxRadius".
Definition _i : ident := $"i".
Definition _index : ident := $"index".
Definition _init_bully_collision_data : ident := $"init_bully_collision_data".
Definition _input : ident := $"input".
Definition _intendedMag : ident := $"intendedMag".
Definition _intendedPos : ident := $"intendedPos".
Definition _intendedYaw : ident := $"intendedYaw".
Definition _interactObj : ident := $"interactObj".
Definition _invincTimer : ident := $"invincTimer".
Definition _ledgeFloor : ident := $"ledgeFloor".
Definition _ledgePos : ident := $"ledgePos".
Definition _length : ident := $"length".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerWall : ident := $"lowerWall".
Definition _lowerY : ident := $"lowerY".
Definition _m : ident := $"m".
Definition _main : ident := $"main".
Definition _marioBodyState : ident := $"marioBodyState".
Definition _marioObj : ident := $"marioObj".
Definition _mario_bonk_reflection : ident := $"mario_bonk_reflection".
Definition _mario_get_terrain_sound_addend : ident := $"mario_get_terrain_sound_addend".
Definition _mario_push_off_steep_floor : ident := $"mario_push_off_steep_floor".
Definition _mario_set_forward_vel : ident := $"mario_set_forward_vel".
Definition _mario_update_moving_sand : ident := $"mario_update_moving_sand".
Definition _mario_update_quicksand : ident := $"mario_update_quicksand".
Definition _mario_update_windy_ground : ident := $"mario_update_windy_ground".
Definition _maxVelY : ident := $"maxVelY".
Definition _modelState : ident := $"modelState".
Definition _negateSpeed : ident := $"negateSpeed".
Definition _next : ident := $"next".
Definition _nextPos : ident := $"nextPos".
Definition _node : ident := $"node".
Definition _normal : ident := $"normal".
Definition _numCoins : ident := $"numCoins".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _numKeys : ident := $"numKeys".
Definition _numLives : ident := $"numLives".
Definition _numStars : ident := $"numStars".
Definition _obj1 : ident := $"obj1".
Definition _obj2 : ident := $"obj2".
Definition _object : ident := $"object".
Definition _offset : ident := $"offset".
Definition _offsetY : ident := $"offsetY".
Definition _originOffset : ident := $"originOffset".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _particleFlags : ident := $"particleFlags".
Definition _peakHeight : ident := $"peakHeight".
Definition _perform_air_quarter_step : ident := $"perform_air_quarter_step".
Definition _perform_air_step : ident := $"perform_air_step".
Definition _perform_ground_quarter_step : ident := $"perform_ground_quarter_step".
Definition _perform_ground_step : ident := $"perform_ground_step".
Definition _platform : ident := $"platform".
Definition _play_sound : ident := $"play_sound".
Definition _pos : ident := $"pos".
Definition _posX : ident := $"posX".
Definition _posZ : ident := $"posZ".
Definition _prev : ident := $"prev".
Definition _prevAction : ident := $"prevAction".
Definition _prevNumStarsForDialog : ident := $"prevNumStarsForDialog".
Definition _prevObj : ident := $"prevObj".
Definition _projectedV1 : ident := $"projectedV1".
Definition _projectedV2 : ident := $"projectedV2".
Definition _punchState : ident := $"punchState".
Definition _pushAngle : ident := $"pushAngle".
Definition _pushDYaw : ident := $"pushDYaw".
Definition _pushSpeed : ident := $"pushSpeed".
Definition _quarterStepResult : ident := $"quarterStepResult".
Definition _quicksandDepth : ident := $"quicksandDepth".
Definition _radius : ident := $"radius".
Definition _rawData : ident := $"rawData".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _resolve_and_return_wall_collisions : ident := $"resolve_and_return_wall_collisions".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _riddenObj : ident := $"riddenObj".
Definition _room : ident := $"room".
Definition _rx : ident := $"rx".
Definition _rz : ident := $"rz".
Definition _sMovingSandSpeeds : ident := $"sMovingSandSpeeds".
Definition _scale : ident := $"scale".
Definition _set_mario_action : ident := $"set_mario_action".
Definition _set_vel_from_pitch_and_yaw : ident := $"set_vel_from_pitch_and_yaw".
Definition _set_vel_from_yaw : ident := $"set_vel_from_yaw".
Definition _sharedChild : ident := $"sharedChild".
Definition _should_strengthen_gravity_for_jump_ascent : ident := $"should_strengthen_gravity_for_jump_ascent".
Definition _sinkingSpeed : ident := $"sinkingSpeed".
Definition _size : ident := $"size".
Definition _slideVelX : ident := $"slideVelX".
Definition _slideVelZ : ident := $"slideVelZ".
Definition _slideYaw : ident := $"slideYaw".
Definition _spawnInfo : ident := $"spawnInfo".
Definition _squishTimer : ident := $"squishTimer".
Definition _srcAddr : ident := $"srcAddr".
Definition _startFrame : ident := $"startFrame".
Definition _stationary_ground_step : ident := $"stationary_ground_step".
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
Definition _stop_and_set_height_to_floor : ident := $"stop_and_set_height_to_floor".
Definition _stub_mario_step_1 : ident := $"stub_mario_step_1".
Definition _stub_mario_step_2 : ident := $"stub_mario_step_2".
Definition _takeStep : ident := $"takeStep".
Definition _terminalVelocity : ident := $"terminalVelocity".
Definition _terrainSoundAddend : ident := $"terrainSoundAddend".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _torsoAngle : ident := $"torsoAngle".
Definition _transfer_bully_speed : ident := $"transfer_bully_speed".
Definition _transform : ident := $"transform".
Definition _twirlYaw : ident := $"twirlYaw".
Definition _type : ident := $"type".
Definition _unk00 : ident := $"unk00".
Definition _unk4C : ident := $"unk4C".
Definition _unkB0 : ident := $"unkB0".
Definition _unused1 : ident := $"unused1".
Definition _unused2 : ident := $"unused2".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _update_mario_sound_and_camera : ident := $"update_mario_sound_and_camera".
Definition _upperWall : ident := $"upperWall".
Definition _upperY : ident := $"upperY".
Definition _usedObj : ident := $"usedObj".
Definition _values : ident := $"values".
Definition _vec3f_copy : ident := $"vec3f_copy".
Definition _vec3f_find_ceil : ident := $"vec3f_find_ceil".
Definition _vec3f_set : ident := $"vec3f_set".
Definition _vec3s_set : ident := $"vec3s_set".
Definition _vel : ident := $"vel".
Definition _velX : ident := $"velX".
Definition _velZ : ident := $"velZ".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _wall : ident := $"wall".
Definition _wallAngle : ident := $"wallAngle".
Definition _wallDYaw : ident := $"wallDYaw".
Definition _wallKickTimer : ident := $"wallKickTimer".
Definition _waterLevel : ident := $"waterLevel".
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

Definition v_gGlobalTimer := {|
  gvar_info := tuint;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sMovingSandSpeeds := {|
  gvar_info := (tarray tshort 4);
  gvar_init := (Init_int16 (Int.repr 12) :: Init_int16 (Int.repr 8) ::
                Init_int16 (Int.repr 4) :: Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gWaterSurfacePseudoFloor := {|
  gvar_info := (Tstruct _Surface noattr);
  gvar_init := (Init_int16 (Int.repr 19) :: Init_int16 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) ::
                Init_float32 (Float32.of_bits (Int.repr 0)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065353216)) ::
                Init_float32 (Float32.of_bits (Int.repr 0)) ::
                Init_float32 (Float32.of_bits (Int.repr 0)) ::
                Init_space 4 :: Init_int64 (Int64.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_get_additive_y_vel_for_jumps := {|
  fn_return := tfloat;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Sreturn (Some (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)))
|}.

Definition f_stub_mario_step_1 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_x, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
Sskip
|}.

Definition f_stub_mario_step_2 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
Sskip
|}.

Definition f_transfer_bully_speed := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_obj1, (tptr (Tstruct _BullyCollisionData noattr))) ::
                (_obj2, (tptr (Tstruct _BullyCollisionData noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_rx, tfloat) :: (_rz, tfloat) :: (_projectedV1, tfloat) ::
               (_projectedV2, tfloat) :: (_t'16, tfloat) ::
               (_t'15, tfloat) :: (_t'14, tfloat) :: (_t'13, tfloat) ::
               (_t'12, tfloat) :: (_t'11, tfloat) :: (_t'10, tfloat) ::
               (_t'9, tfloat) :: (_t'8, tfloat) :: (_t'7, tfloat) ::
               (_t'6, tfloat) :: (_t'5, tfloat) :: (_t'4, tfloat) ::
               (_t'3, tfloat) :: (_t'2, tfloat) :: (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'15
      (Efield
        (Ederef (Etempvar _obj2 (tptr (Tstruct _BullyCollisionData noattr)))
          (Tstruct _BullyCollisionData noattr)) _posX tfloat))
    (Ssequence
      (Sset _t'16
        (Efield
          (Ederef
            (Etempvar _obj1 (tptr (Tstruct _BullyCollisionData noattr)))
            (Tstruct _BullyCollisionData noattr)) _posX tfloat))
      (Sset _rx
        (Ebinop Osub (Etempvar _t'15 tfloat) (Etempvar _t'16 tfloat) tfloat))))
  (Ssequence
    (Ssequence
      (Sset _t'13
        (Efield
          (Ederef
            (Etempvar _obj2 (tptr (Tstruct _BullyCollisionData noattr)))
            (Tstruct _BullyCollisionData noattr)) _posZ tfloat))
      (Ssequence
        (Sset _t'14
          (Efield
            (Ederef
              (Etempvar _obj1 (tptr (Tstruct _BullyCollisionData noattr)))
              (Tstruct _BullyCollisionData noattr)) _posZ tfloat))
        (Sset _rz
          (Ebinop Osub (Etempvar _t'13 tfloat) (Etempvar _t'14 tfloat)
            tfloat))))
    (Ssequence
      (Ssequence
        (Sset _t'11
          (Efield
            (Ederef
              (Etempvar _obj1 (tptr (Tstruct _BullyCollisionData noattr)))
              (Tstruct _BullyCollisionData noattr)) _velX tfloat))
        (Ssequence
          (Sset _t'12
            (Efield
              (Ederef
                (Etempvar _obj1 (tptr (Tstruct _BullyCollisionData noattr)))
                (Tstruct _BullyCollisionData noattr)) _velZ tfloat))
          (Sset _projectedV1
            (Ebinop Odiv
              (Ebinop Oadd
                (Ebinop Omul (Etempvar _rx tfloat) (Etempvar _t'11 tfloat)
                  tfloat)
                (Ebinop Omul (Etempvar _rz tfloat) (Etempvar _t'12 tfloat)
                  tfloat) tfloat)
              (Ebinop Oadd
                (Ebinop Omul (Etempvar _rx tfloat) (Etempvar _rx tfloat)
                  tfloat)
                (Ebinop Omul (Etempvar _rz tfloat) (Etempvar _rz tfloat)
                  tfloat) tfloat) tfloat))))
      (Ssequence
        (Ssequence
          (Sset _t'9
            (Efield
              (Ederef
                (Etempvar _obj2 (tptr (Tstruct _BullyCollisionData noattr)))
                (Tstruct _BullyCollisionData noattr)) _velX tfloat))
          (Ssequence
            (Sset _t'10
              (Efield
                (Ederef
                  (Etempvar _obj2 (tptr (Tstruct _BullyCollisionData noattr)))
                  (Tstruct _BullyCollisionData noattr)) _velZ tfloat))
            (Sset _projectedV2
              (Ebinop Odiv
                (Ebinop Osub
                  (Ebinop Omul (Eunop Oneg (Etempvar _rx tfloat) tfloat)
                    (Etempvar _t'9 tfloat) tfloat)
                  (Ebinop Omul (Etempvar _rz tfloat) (Etempvar _t'10 tfloat)
                    tfloat) tfloat)
                (Ebinop Oadd
                  (Ebinop Omul (Etempvar _rx tfloat) (Etempvar _rx tfloat)
                    tfloat)
                  (Ebinop Omul (Etempvar _rz tfloat) (Etempvar _rz tfloat)
                    tfloat) tfloat) tfloat))))
        (Ssequence
          (Ssequence
            (Sset _t'7
              (Efield
                (Ederef
                  (Etempvar _obj2 (tptr (Tstruct _BullyCollisionData noattr)))
                  (Tstruct _BullyCollisionData noattr)) _velX tfloat))
            (Ssequence
              (Sset _t'8
                (Efield
                  (Ederef
                    (Etempvar _obj2 (tptr (Tstruct _BullyCollisionData noattr)))
                    (Tstruct _BullyCollisionData noattr)) _conversionRatio
                  tfloat))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _obj2 (tptr (Tstruct _BullyCollisionData noattr)))
                    (Tstruct _BullyCollisionData noattr)) _velX tfloat)
                (Ebinop Oadd (Etempvar _t'7 tfloat)
                  (Ebinop Osub
                    (Ebinop Omul
                      (Ebinop Omul (Etempvar _t'8 tfloat)
                        (Etempvar _projectedV1 tfloat) tfloat)
                      (Etempvar _rx tfloat) tfloat)
                    (Ebinop Omul (Etempvar _projectedV2 tfloat)
                      (Eunop Oneg (Etempvar _rx tfloat) tfloat) tfloat)
                    tfloat) tfloat))))
          (Ssequence
            (Ssequence
              (Sset _t'5
                (Efield
                  (Ederef
                    (Etempvar _obj2 (tptr (Tstruct _BullyCollisionData noattr)))
                    (Tstruct _BullyCollisionData noattr)) _velZ tfloat))
              (Ssequence
                (Sset _t'6
                  (Efield
                    (Ederef
                      (Etempvar _obj2 (tptr (Tstruct _BullyCollisionData noattr)))
                      (Tstruct _BullyCollisionData noattr)) _conversionRatio
                    tfloat))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _obj2 (tptr (Tstruct _BullyCollisionData noattr)))
                      (Tstruct _BullyCollisionData noattr)) _velZ tfloat)
                  (Ebinop Oadd (Etempvar _t'5 tfloat)
                    (Ebinop Osub
                      (Ebinop Omul
                        (Ebinop Omul (Etempvar _t'6 tfloat)
                          (Etempvar _projectedV1 tfloat) tfloat)
                        (Etempvar _rz tfloat) tfloat)
                      (Ebinop Omul (Etempvar _projectedV2 tfloat)
                        (Eunop Oneg (Etempvar _rz tfloat) tfloat) tfloat)
                      tfloat) tfloat))))
            (Ssequence
              (Ssequence
                (Sset _t'3
                  (Efield
                    (Ederef
                      (Etempvar _obj1 (tptr (Tstruct _BullyCollisionData noattr)))
                      (Tstruct _BullyCollisionData noattr)) _velX tfloat))
                (Ssequence
                  (Sset _t'4
                    (Efield
                      (Ederef
                        (Etempvar _obj1 (tptr (Tstruct _BullyCollisionData noattr)))
                        (Tstruct _BullyCollisionData noattr))
                      _conversionRatio tfloat))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _obj1 (tptr (Tstruct _BullyCollisionData noattr)))
                        (Tstruct _BullyCollisionData noattr)) _velX tfloat)
                    (Ebinop Oadd (Etempvar _t'3 tfloat)
                      (Ebinop Oadd
                        (Ebinop Omul
                          (Eunop Oneg (Etempvar _projectedV1 tfloat) tfloat)
                          (Etempvar _rx tfloat) tfloat)
                        (Ebinop Omul
                          (Ebinop Omul (Etempvar _t'4 tfloat)
                            (Etempvar _projectedV2 tfloat) tfloat)
                          (Eunop Oneg (Etempvar _rx tfloat) tfloat) tfloat)
                        tfloat) tfloat))))
              (Ssequence
                (Sset _t'1
                  (Efield
                    (Ederef
                      (Etempvar _obj1 (tptr (Tstruct _BullyCollisionData noattr)))
                      (Tstruct _BullyCollisionData noattr)) _velZ tfloat))
                (Ssequence
                  (Sset _t'2
                    (Efield
                      (Ederef
                        (Etempvar _obj1 (tptr (Tstruct _BullyCollisionData noattr)))
                        (Tstruct _BullyCollisionData noattr))
                      _conversionRatio tfloat))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _obj1 (tptr (Tstruct _BullyCollisionData noattr)))
                        (Tstruct _BullyCollisionData noattr)) _velZ tfloat)
                    (Ebinop Oadd (Etempvar _t'1 tfloat)
                      (Ebinop Oadd
                        (Ebinop Omul
                          (Eunop Oneg (Etempvar _projectedV1 tfloat) tfloat)
                          (Etempvar _rz tfloat) tfloat)
                        (Ebinop Omul
                          (Ebinop Omul (Etempvar _t'2 tfloat)
                            (Etempvar _projectedV2 tfloat) tfloat)
                          (Eunop Oneg (Etempvar _rz tfloat) tfloat) tfloat)
                        tfloat) tfloat)))))))))))
|}.

Definition f_init_bully_collision_data := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_data, (tptr (Tstruct _BullyCollisionData noattr))) ::
                (_posX, tfloat) :: (_posZ, tfloat) ::
                (_forwardVel, tfloat) :: (_yaw, tshort) ::
                (_conversionRatio, tfloat) :: (_radius, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tfloat) :: (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Olt (Etempvar _forwardVel tfloat)
                 (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) tint)
    (Ssequence
      (Sset _forwardVel
        (Ebinop Omul (Etempvar _forwardVel tfloat)
          (Eunop Oneg
            (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
            tfloat) tfloat))
      (Sset _yaw
        (Ecast
          (Ebinop Oadd (Etempvar _yaw tshort)
            (Econst_int (Int.repr 32768) tint) tint) tshort)))
    Sskip)
  (Ssequence
    (Sassign
      (Efield
        (Ederef (Etempvar _data (tptr (Tstruct _BullyCollisionData noattr)))
          (Tstruct _BullyCollisionData noattr)) _radius tfloat)
      (Etempvar _radius tfloat))
    (Ssequence
      (Sassign
        (Efield
          (Ederef
            (Etempvar _data (tptr (Tstruct _BullyCollisionData noattr)))
            (Tstruct _BullyCollisionData noattr)) _conversionRatio tfloat)
        (Etempvar _conversionRatio tfloat))
      (Ssequence
        (Sassign
          (Efield
            (Ederef
              (Etempvar _data (tptr (Tstruct _BullyCollisionData noattr)))
              (Tstruct _BullyCollisionData noattr)) _posX tfloat)
          (Etempvar _posX tfloat))
        (Ssequence
          (Sassign
            (Efield
              (Ederef
                (Etempvar _data (tptr (Tstruct _BullyCollisionData noattr)))
                (Tstruct _BullyCollisionData noattr)) _posZ tfloat)
            (Etempvar _posZ tfloat))
          (Ssequence
            (Ssequence
              (Sset _t'2
                (Ederef
                  (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                    (Ebinop Oshr (Ecast (Etempvar _yaw tshort) tushort)
                      (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                  tfloat))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _data (tptr (Tstruct _BullyCollisionData noattr)))
                    (Tstruct _BullyCollisionData noattr)) _velX tfloat)
                (Ebinop Omul (Etempvar _forwardVel tfloat)
                  (Etempvar _t'2 tfloat) tfloat)))
            (Ssequence
              (Sset _t'1
                (Ederef
                  (Ebinop Oadd
                    (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                      (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                    (Ebinop Oshr (Ecast (Etempvar _yaw tshort) tushort)
                      (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                  tfloat))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _data (tptr (Tstruct _BullyCollisionData noattr)))
                    (Tstruct _BullyCollisionData noattr)) _velZ tfloat)
                (Ebinop Omul (Etempvar _forwardVel tfloat)
                  (Etempvar _t'1 tfloat) tfloat)))))))))
|}.

Definition f_mario_bonk_reflection := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_negateSpeed, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_wallAngle, tshort) :: (_t'2, tuint) :: (_t'1, tshort) ::
               (_t'13, tfloat) ::
               (_t'12, (tptr (Tstruct _Surface noattr))) ::
               (_t'11, tfloat) ::
               (_t'10, (tptr (Tstruct _Surface noattr))) :: (_t'9, tshort) ::
               (_t'8, tuint) :: (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _Surface noattr))) :: (_t'4, tfloat) ::
               (_t'3, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _wall
        (tptr (Tstruct _Surface noattr))))
    (Sifthenelse (Ebinop One (Etempvar _t'5 (tptr (Tstruct _Surface noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'10
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _wall
                (tptr (Tstruct _Surface noattr))))
            (Ssequence
              (Sset _t'11
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'10 (tptr (Tstruct _Surface noattr)))
                      (Tstruct _Surface noattr)) _normal
                    (Tstruct __670 noattr)) _z tfloat))
              (Ssequence
                (Sset _t'12
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _wall
                    (tptr (Tstruct _Surface noattr))))
                (Ssequence
                  (Sset _t'13
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'12 (tptr (Tstruct _Surface noattr)))
                          (Tstruct _Surface noattr)) _normal
                        (Tstruct __670 noattr)) _x tfloat))
                  (Scall (Some _t'1)
                    (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil) tshort
                                    cc_default))
                    ((Etempvar _t'11 tfloat) :: (Etempvar _t'13 tfloat) ::
                     nil))))))
          (Sset _wallAngle (Ecast (Etempvar _t'1 tshort) tshort)))
        (Ssequence
          (Ssequence
            (Sset _t'9
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
              (Ebinop Osub (Etempvar _wallAngle tshort)
                (Ecast
                  (Ebinop Osub (Etempvar _t'9 tshort)
                    (Etempvar _wallAngle tshort) tint) tshort) tint)))
          (Ssequence
            (Ssequence
              (Sset _t'8
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _flags tuint))
              (Sifthenelse (Ebinop Oand (Etempvar _t'8 tuint)
                             (Econst_int (Int.repr 4) tint) tuint)
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
                              (Ecast (Econst_int (Int.repr 66) tint) tuint)
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
                              (Ecast (Econst_int (Int.repr 69) tint) tuint)
                              (Econst_int (Int.repr 16) tint) tuint) tuint)
                          (Ebinop Oshl
                            (Ecast (Econst_int (Int.repr 160) tint) tuint)
                            (Econst_int (Int.repr 8) tint) tuint) tuint)
                        (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                          (Econst_int (Int.repr 128) tint) tint) tuint)
                      (Econst_int (Int.repr 1) tint) tuint) tuint))))
            (Ssequence
              (Sset _t'7
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
                       (Ederef
                         (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                         (Tstruct _Object noattr)) _header
                       (Tstruct _ObjectNode noattr)) _gfx
                     (Tstruct _GraphNodeObject noattr)) _cameraToObject
                   (tarray tfloat 3)) :: nil))))))
      (Ssequence
        (Sset _t'6
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
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 192) tint) tuint)
                   (Econst_int (Int.repr 8) tint) tuint) tuint)
               (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                 (Econst_int (Int.repr 128) tint) tint) tuint)
             (Econst_int (Int.repr 1) tint) tuint) ::
           (Efield
             (Efield
               (Efield
                 (Ederef (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                   (Tstruct _Object noattr)) _header
                 (Tstruct _ObjectNode noattr)) _gfx
               (Tstruct _GraphNodeObject noattr)) _cameraToObject
             (tarray tfloat 3)) :: nil)))))
  (Sifthenelse (Etempvar _negateSpeed tuint)
    (Ssequence
      (Sset _t'4
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _forwardVel tfloat))
      (Scall None
        (Evar _mario_set_forward_vel (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tfloat :: nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Eunop Oneg (Etempvar _t'4 tfloat) tfloat) :: nil)))
    (Ssequence
      (Sset _t'3
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
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
            (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort)
        (Ebinop Oadd (Etempvar _t'3 tshort)
          (Econst_int (Int.repr 32768) tint) tint)))))
|}.

Definition f_mario_update_quicksand := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_sinkingSpeed, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'6, tint) :: (_t'5, tfloat) :: (_t'4, tint) ::
               (_t'3, tfloat) :: (_t'2, tfloat) :: (_t'1, tfloat) ::
               (_t'14, tfloat) :: (_t'13, tfloat) :: (_t'12, tfloat) ::
               (_t'11, tfloat) :: (_t'10, tfloat) :: (_t'9, tshort) ::
               (_t'8, (tptr (Tstruct _Surface noattr))) :: (_t'7, tuint) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _action tuint))
    (Sifthenelse (Ebinop Oand (Etempvar _t'7 tuint)
                   (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                     (Econst_int (Int.repr 16) tint) tint) tuint)
      (Sassign
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _quicksandDepth tfloat)
        (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
      (Ssequence
        (Ssequence
          (Sset _t'14
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _quicksandDepth tfloat))
          (Sifthenelse (Ebinop Olt (Etempvar _t'14 tfloat)
                         (Econst_single (Float32.of_bits (Int.repr 1066192077)) tfloat)
                         tint)
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _quicksandDepth tfloat)
              (Econst_single (Float32.of_bits (Int.repr 1066192077)) tfloat))
            Sskip))
        (Ssequence
          (Sset _t'8
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _floor
              (tptr (Tstruct _Surface noattr))))
          (Ssequence
            (Sset _t'9
              (Efield
                (Ederef (Etempvar _t'8 (tptr (Tstruct _Surface noattr)))
                  (Tstruct _Surface noattr)) _type tshort))
            (Sswitch (Etempvar _t'9 tshort)
              (LScons (Some 33)
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'13
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _quicksandDepth
                            tfloat))
                        (Sset _t'1
                          (Ecast
                            (Ebinop Oadd (Etempvar _t'13 tfloat)
                              (Etempvar _sinkingSpeed tfloat) tfloat) tfloat)))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _quicksandDepth
                          tfloat) (Etempvar _t'1 tfloat)))
                    (Sifthenelse (Ebinop Oge (Etempvar _t'1 tfloat)
                                   (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                                   tint)
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _quicksandDepth
                          tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat))
                      Sskip))
                  Sbreak)
                (LScons (Some 37)
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'12
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _quicksandDepth
                              tfloat))
                          (Sset _t'2
                            (Ecast
                              (Ebinop Oadd (Etempvar _t'12 tfloat)
                                (Etempvar _sinkingSpeed tfloat) tfloat)
                              tfloat)))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _quicksandDepth
                            tfloat) (Etempvar _t'2 tfloat)))
                      (Sifthenelse (Ebinop Oge (Etempvar _t'2 tfloat)
                                     (Econst_single (Float32.of_bits (Int.repr 1103626240)) tfloat)
                                     tint)
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _quicksandDepth
                            tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1103626240)) tfloat))
                        Sskip))
                    Sbreak)
                  (LScons (Some 38)
                    Sskip
                    (LScons (Some 39)
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Sset _t'11
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr))
                                  _quicksandDepth tfloat))
                              (Sset _t'3
                                (Ecast
                                  (Ebinop Oadd (Etempvar _t'11 tfloat)
                                    (Etempvar _sinkingSpeed tfloat) tfloat)
                                  tfloat)))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr))
                                _quicksandDepth tfloat)
                              (Etempvar _t'3 tfloat)))
                          (Sifthenelse (Ebinop Oge (Etempvar _t'3 tfloat)
                                         (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat)
                                         tint)
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr))
                                _quicksandDepth tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat))
                            Sskip))
                        Sbreak)
                      (LScons (Some 34)
                        Sskip
                        (LScons (Some 36)
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Ssequence
                                  (Sset _t'10
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _quicksandDepth tfloat))
                                  (Sset _t'5
                                    (Ecast
                                      (Ebinop Oadd (Etempvar _t'10 tfloat)
                                        (Etempvar _sinkingSpeed tfloat)
                                        tfloat) tfloat)))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _quicksandDepth tfloat)
                                  (Etempvar _t'5 tfloat)))
                              (Sifthenelse (Ebinop Oge (Etempvar _t'5 tfloat)
                                             (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat)
                                             tint)
                                (Ssequence
                                  (Scall None
                                    (Evar _update_mario_sound_and_camera 
                                    (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       nil) tvoid cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     nil))
                                  (Ssequence
                                    (Scall (Some _t'4)
                                      (Evar _drop_and_set_mario_action 
                                      (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tint
                                        cc_default))
                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                       (Econst_int (Int.repr 135954) tint) ::
                                       (Econst_int (Int.repr 0) tint) :: nil))
                                    (Sreturn (Some (Etempvar _t'4 tint)))))
                                Sskip))
                            Sbreak)
                          (LScons (Some 35)
                            Sskip
                            (LScons (Some 45)
                              (Ssequence
                                (Scall None
                                  (Evar _update_mario_sound_and_camera 
                                  (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tvoid cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   nil))
                                (Ssequence
                                  (Ssequence
                                    (Scall (Some _t'6)
                                      (Evar _drop_and_set_mario_action 
                                      (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tint
                                        cc_default))
                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                       (Econst_int (Int.repr 135954) tint) ::
                                       (Econst_int (Int.repr 0) tint) :: nil))
                                    (Sreturn (Some (Etempvar _t'6 tint))))
                                  Sbreak))
                              (LScons None
                                (Ssequence
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _quicksandDepth tfloat)
                                    (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                                  Sbreak)
                                LSnil)))))))))))))))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_mario_push_off_steep_floor := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_action, tuint) :: (_actionArg, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_floorDYaw, tshort) :: (_t'2, tuint) :: (_t'1, tint) ::
               (_t'6, tshort) :: (_t'5, tshort) :: (_t'4, tshort) ::
               (_t'3, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _floorAngle tshort))
    (Ssequence
      (Sset _t'6
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
            (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
      (Sset _floorDYaw
        (Ecast
          (Ebinop Osub (Etempvar _t'5 tshort) (Etempvar _t'6 tshort) tint)
          tshort))))
  (Ssequence
    (Ssequence
      (Sifthenelse (Ebinop Ogt (Etempvar _floorDYaw tshort)
                     (Eunop Oneg (Econst_int (Int.repr 16384) tint) tint)
                     tint)
        (Sset _t'1
          (Ecast
            (Ebinop Olt (Etempvar _floorDYaw tshort)
              (Econst_int (Int.repr 16384) tint) tint) tbool))
        (Sset _t'1 (Econst_int (Int.repr 0) tint)))
      (Sifthenelse (Etempvar _t'1 tint)
        (Ssequence
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat)
            (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat))
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _floorAngle tshort))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _faceAngle
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort) (Etempvar _t'4 tshort))))
        (Ssequence
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat)
            (Eunop Oneg
              (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
              tfloat))
          (Ssequence
            (Sset _t'3
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _floorAngle tshort))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _faceAngle
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort)
              (Ebinop Oadd (Etempvar _t'3 tshort)
                (Econst_int (Int.repr 32768) tint) tint))))))
    (Ssequence
      (Scall (Some _t'2)
        (Evar _set_mario_action (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   tuint :: tuint :: nil) tuint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Etempvar _action tuint) :: (Etempvar _actionArg tuint) :: nil))
      (Sreturn (Some (Etempvar _t'2 tuint))))))
|}.

Definition f_mario_update_moving_sand := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_floor, (tptr (Tstruct _Surface noattr))) ::
               (_floorType, tint) :: (_pushAngle, tshort) ::
               (_pushSpeed, tfloat) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'10, tshort) :: (_t'9, tshort) ::
               (_t'8, tshort) :: (_t'7, tfloat) :: (_t'6, tfloat) ::
               (_t'5, tfloat) :: (_t'4, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _floor
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _floor
      (tptr (Tstruct _Surface noattr))))
  (Ssequence
    (Sset _floorType
      (Efield
        (Ederef (Etempvar _floor (tptr (Tstruct _Surface noattr)))
          (Tstruct _Surface noattr)) _type tshort))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sifthenelse (Ebinop Oeq (Etempvar _floorType tint)
                           (Econst_int (Int.repr 36) tint) tint)
              (Sset _t'1 (Econst_int (Int.repr 1) tint))
              (Sset _t'1
                (Ecast
                  (Ebinop Oeq (Etempvar _floorType tint)
                    (Econst_int (Int.repr 37) tint) tint) tbool)))
            (Sifthenelse (Etempvar _t'1 tint)
              (Sset _t'2 (Econst_int (Int.repr 1) tint))
              (Sset _t'2
                (Ecast
                  (Ebinop Oeq (Etempvar _floorType tint)
                    (Econst_int (Int.repr 39) tint) tint) tbool))))
          (Sifthenelse (Etempvar _t'2 tint)
            (Sset _t'3 (Econst_int (Int.repr 1) tint))
            (Sset _t'3
              (Ecast
                (Ebinop Oeq (Etempvar _floorType tint)
                  (Econst_int (Int.repr 45) tint) tint) tbool))))
        (Sifthenelse (Etempvar _t'3 tint)
          (Ssequence
            (Ssequence
              (Sset _t'10
                (Efield
                  (Ederef (Etempvar _floor (tptr (Tstruct _Surface noattr)))
                    (Tstruct _Surface noattr)) _force tshort))
              (Sset _pushAngle
                (Ecast
                  (Ebinop Oshl (Etempvar _t'10 tshort)
                    (Econst_int (Int.repr 8) tint) tint) tshort)))
            (Ssequence
              (Ssequence
                (Sset _t'8
                  (Efield
                    (Ederef
                      (Etempvar _floor (tptr (Tstruct _Surface noattr)))
                      (Tstruct _Surface noattr)) _force tshort))
                (Ssequence
                  (Sset _t'9
                    (Ederef
                      (Ebinop Oadd
                        (Evar _sMovingSandSpeeds (tarray tshort 4))
                        (Ebinop Oshr (Etempvar _t'8 tshort)
                          (Econst_int (Int.repr 8) tint) tint) (tptr tshort))
                      tshort))
                  (Sset _pushSpeed (Ecast (Etempvar _t'9 tshort) tfloat))))
              (Ssequence
                (Ssequence
                  (Sset _t'6
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _vel
                          (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tfloat)) tfloat))
                  (Ssequence
                    (Sset _t'7
                      (Ederef
                        (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                          (Ebinop Oshr
                            (Ecast (Etempvar _pushAngle tshort) tushort)
                            (Econst_int (Int.repr 4) tint) tint)
                          (tptr tfloat)) tfloat))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _vel
                            (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                          (tptr tfloat)) tfloat)
                      (Ebinop Oadd (Etempvar _t'6 tfloat)
                        (Ebinop Omul (Etempvar _pushSpeed tfloat)
                          (Etempvar _t'7 tfloat) tfloat) tfloat))))
                (Ssequence
                  (Ssequence
                    (Sset _t'4
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _vel
                            (tarray tfloat 3)) (Econst_int (Int.repr 2) tint)
                          (tptr tfloat)) tfloat))
                    (Ssequence
                      (Sset _t'5
                        (Ederef
                          (Ebinop Oadd
                            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                              (Econst_int (Int.repr 1024) tint)
                              (tptr tfloat))
                            (Ebinop Oshr
                              (Ecast (Etempvar _pushAngle tshort) tushort)
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
                        (Ebinop Oadd (Etempvar _t'4 tfloat)
                          (Ebinop Omul (Etempvar _pushSpeed tfloat)
                            (Etempvar _t'5 tfloat) tfloat) tfloat))))
                  (Sreturn (Some (Econst_int (Int.repr 1) tint)))))))
          Sskip))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_mario_update_windy_ground := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_floor, (tptr (Tstruct _Surface noattr))) ::
               (_pushSpeed, tfloat) :: (_pushAngle, tshort) ::
               (_pushDYaw, tshort) :: (_t'2, tint) :: (_t'1, tfloat) ::
               (_t'14, tshort) :: (_t'13, tshort) :: (_t'12, tfloat) ::
               (_t'11, tfloat) :: (_t'10, tfloat) :: (_t'9, tuint) ::
               (_t'8, tuint) :: (_t'7, tfloat) :: (_t'6, tfloat) ::
               (_t'5, tfloat) :: (_t'4, tfloat) :: (_t'3, tshort) :: nil);
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
            (Sset _t'14
              (Efield
                (Ederef (Etempvar _floor (tptr (Tstruct _Surface noattr)))
                  (Tstruct _Surface noattr)) _force tshort))
            (Sset _pushAngle
              (Ecast
                (Ebinop Oshl (Etempvar _t'14 tshort)
                  (Econst_int (Int.repr 8) tint) tint) tshort)))
          (Ssequence
            (Ssequence
              (Sset _t'8
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _action tuint))
              (Sifthenelse (Ebinop Oand (Etempvar _t'8 tuint)
                             (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                               (Econst_int (Int.repr 10) tint) tint) tuint)
                (Ssequence
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
                    (Sset _pushDYaw
                      (Ecast
                        (Ebinop Osub (Etempvar _t'13 tshort)
                          (Etempvar _pushAngle tshort) tint) tshort)))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'11
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _forwardVel
                            tfloat))
                        (Sifthenelse (Ebinop Ogt (Etempvar _t'11 tfloat)
                                       (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                       tint)
                          (Ssequence
                            (Sset _t'12
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _forwardVel
                                tfloat))
                            (Sset _t'1
                              (Ecast
                                (Ebinop Omul
                                  (Eunop Oneg (Etempvar _t'12 tfloat) tfloat)
                                  (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat)
                                  tfloat) tfloat)))
                          (Sset _t'1
                            (Ecast
                              (Eunop Oneg
                                (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat)
                                tfloat) tfloat))))
                      (Sset _pushSpeed (Etempvar _t'1 tfloat)))
                    (Ssequence
                      (Ssequence
                        (Sifthenelse (Ebinop Ogt (Etempvar _pushDYaw tshort)
                                       (Eunop Oneg
                                         (Econst_int (Int.repr 16384) tint)
                                         tint) tint)
                          (Sset _t'2
                            (Ecast
                              (Ebinop Olt (Etempvar _pushDYaw tshort)
                                (Econst_int (Int.repr 16384) tint) tint)
                              tbool))
                          (Sset _t'2 (Econst_int (Int.repr 0) tint)))
                        (Sifthenelse (Etempvar _t'2 tint)
                          (Sset _pushSpeed
                            (Ebinop Omul (Etempvar _pushSpeed tfloat)
                              (Eunop Oneg
                                (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                                tfloat) tfloat))
                          Sskip))
                      (Ssequence
                        (Sset _t'10
                          (Ederef
                            (Ebinop Oadd
                              (Ebinop Oadd
                                (Evar _gSineTable (tarray tfloat 0))
                                (Econst_int (Int.repr 1024) tint)
                                (tptr tfloat))
                              (Ebinop Oshr
                                (Ecast (Etempvar _pushDYaw tshort) tushort)
                                (Econst_int (Int.repr 4) tint) tint)
                              (tptr tfloat)) tfloat))
                        (Sset _pushSpeed
                          (Ebinop Omul (Etempvar _pushSpeed tfloat)
                            (Etempvar _t'10 tfloat) tfloat))))))
                (Ssequence
                  (Sset _t'9 (Evar _gGlobalTimer tuint))
                  (Sset _pushSpeed
                    (Ebinop Oadd
                      (Econst_single (Float32.of_bits (Int.repr 1078774989)) tfloat)
                      (Ebinop Omod (Etempvar _t'9 tuint)
                        (Econst_int (Int.repr 4) tint) tuint) tfloat)))))
            (Ssequence
              (Ssequence
                (Sset _t'6
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _vel
                        (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tfloat)) tfloat))
                (Ssequence
                  (Sset _t'7
                    (Ederef
                      (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                        (Ebinop Oshr
                          (Ecast (Etempvar _pushAngle tshort) tushort)
                          (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                      tfloat))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _vel
                          (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tfloat)) tfloat)
                    (Ebinop Oadd (Etempvar _t'6 tfloat)
                      (Ebinop Omul (Etempvar _pushSpeed tfloat)
                        (Etempvar _t'7 tfloat) tfloat) tfloat))))
              (Ssequence
                (Ssequence
                  (Sset _t'4
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _vel
                          (tarray tfloat 3)) (Econst_int (Int.repr 2) tint)
                        (tptr tfloat)) tfloat))
                  (Ssequence
                    (Sset _t'5
                      (Ederef
                        (Ebinop Oadd
                          (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                            (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                          (Ebinop Oshr
                            (Ecast (Etempvar _pushAngle tshort) tushort)
                            (Econst_int (Int.repr 4) tint) tint)
                          (tptr tfloat)) tfloat))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _vel
                            (tarray tfloat 3)) (Econst_int (Int.repr 2) tint)
                          (tptr tfloat)) tfloat)
                      (Ebinop Oadd (Etempvar _t'4 tfloat)
                        (Ebinop Omul (Etempvar _pushSpeed tfloat)
                          (Etempvar _t'5 tfloat) tfloat) tfloat))))
                (Sreturn (Some (Econst_int (Int.repr 1) tint)))))))
        Sskip))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_stop_and_set_height_to_floor := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_t'2, tfloat) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _marioObj
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Scall None
      (Evar _mario_set_forward_vel (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tfloat :: nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) :: nil))
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
        (Ssequence
          (Sset _t'2
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
            (Etempvar _t'2 tfloat)))
        (Ssequence
          (Scall None
            (Evar _vec3f_copy (Tfunction
                                ((tptr tfloat) :: (tptr tfloat) :: nil)
                                (tptr tvoid) cc_default))
            ((Efield
               (Efield
                 (Efield
                   (Ederef
                     (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                     (Tstruct _Object noattr)) _header
                   (Tstruct _ObjectNode noattr)) _gfx
                 (Tstruct _GraphNodeObject noattr)) _pos (tarray tfloat 3)) ::
             (Efield
               (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                 (Tstruct _MarioState noattr)) _pos (tarray tfloat 3)) ::
             nil))
          (Ssequence
            (Sset _t'1
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
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
                       (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                       (Tstruct _Object noattr)) _header
                     (Tstruct _ObjectNode noattr)) _gfx
                   (Tstruct _GraphNodeObject noattr)) _angle
                 (tarray tshort 3)) :: (Econst_int (Int.repr 0) tint) ::
               (Etempvar _t'1 tshort) :: (Econst_int (Int.repr 0) tint) ::
               nil))))))))
|}.

Definition f_stationary_ground_step := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_takeStep, tuint) ::
               (_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_stepResult, tuint) :: (_t'3, tint) :: (_t'2, tuint) ::
               (_t'1, tuint) :: (_t'5, tfloat) :: (_t'4, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _marioObj
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Sset _stepResult (Econst_int (Int.repr 1) tint))
    (Ssequence
      (Scall None
        (Evar _mario_set_forward_vel (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tfloat :: nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) :: nil))
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _mario_update_moving_sand (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tuint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sset _takeStep (Etempvar _t'1 tuint)))
        (Ssequence
          (Ssequence
            (Scall (Some _t'2)
              (Evar _mario_update_windy_ground (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tuint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Sset _takeStep
              (Ebinop Oor (Etempvar _takeStep tuint) (Etempvar _t'2 tuint)
                tuint)))
          (Ssequence
            (Sifthenelse (Etempvar _takeStep tuint)
              (Ssequence
                (Scall (Some _t'3)
                  (Evar _perform_ground_step (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Sset _stepResult (Etempvar _t'3 tint)))
              (Ssequence
                (Ssequence
                  (Sset _t'5
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _floorHeight tfloat))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _pos
                          (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tfloat)) tfloat) (Etempvar _t'5 tfloat)))
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
                    (Sset _t'4
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
                       (Econst_int (Int.repr 0) tint) ::
                       (Etempvar _t'4 tshort) ::
                       (Econst_int (Int.repr 0) tint) :: nil))))))
            (Sreturn (Some (Etempvar _stepResult tuint)))))))))
|}.

Definition f_perform_ground_quarter_step := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_nextPos, (tptr tfloat)) :: nil);
  fn_vars := ((_ceil, (tptr (Tstruct _Surface noattr))) ::
              (_floor, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_temps := ((_lowerWall, (tptr (Tstruct _Surface noattr))) ::
               (_upperWall, (tptr (Tstruct _Surface noattr))) ::
               (_ceilHeight, tfloat) :: (_floorHeight, tfloat) ::
               (_waterLevel, tfloat) :: (_wallDYaw, tshort) ::
               (_t'9, tint) :: (_t'8, tint) :: (_t'7, tshort) ::
               (_t'6, tint) :: (_t'5, tfloat) :: (_t'4, tfloat) ::
               (_t'3, tfloat) :: (_t'2, (tptr (Tstruct _Surface noattr))) ::
               (_t'1, (tptr (Tstruct _Surface noattr))) :: (_t'26, tfloat) ::
               (_t'25, tfloat) :: (_t'24, tfloat) :: (_t'23, tfloat) ::
               (_t'22, tfloat) ::
               (_t'21, (tptr (Tstruct _Surface noattr))) :: (_t'20, tuint) ::
               (_t'19, (tptr (Tstruct _Surface noattr))) ::
               (_t'18, tfloat) ::
               (_t'17, (tptr (Tstruct _Surface noattr))) ::
               (_t'16, tfloat) :: (_t'15, tfloat) :: (_t'14, tfloat) ::
               (_t'13, (tptr (Tstruct _Surface noattr))) ::
               (_t'12, tfloat) :: (_t'11, tfloat) :: (_t'10, tshort) :: nil);
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
       (Econst_single (Float32.of_bits (Int.repr 1106247680)) tfloat) ::
       (Econst_single (Float32.of_bits (Int.repr 1103101952)) tfloat) :: nil))
    (Sset _lowerWall (Etempvar _t'1 (tptr (Tstruct _Surface noattr)))))
  (Ssequence
    (Ssequence
      (Scall (Some _t'2)
        (Evar _resolve_and_return_wall_collisions (Tfunction
                                                    ((tptr tfloat) ::
                                                     tfloat :: tfloat :: nil)
                                                    (tptr (Tstruct _Surface noattr))
                                                    cc_default))
        ((Etempvar _nextPos (tptr tfloat)) ::
         (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat) ::
         (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat) ::
         nil))
      (Sset _upperWall (Etempvar _t'2 (tptr (Tstruct _Surface noattr)))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'24
            (Ederef
              (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
          (Ssequence
            (Sset _t'25
              (Ederef
                (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                  (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
            (Ssequence
              (Sset _t'26
                (Ederef
                  (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                    (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
              (Scall (Some _t'3)
                (Evar _find_floor (Tfunction
                                    (tfloat :: tfloat :: tfloat ::
                                     (tptr (tptr (Tstruct _Surface noattr))) ::
                                     nil) tfloat cc_default))
                ((Etempvar _t'24 tfloat) :: (Etempvar _t'25 tfloat) ::
                 (Etempvar _t'26 tfloat) ::
                 (Eaddrof (Evar _floor (tptr (Tstruct _Surface noattr)))
                   (tptr (tptr (Tstruct _Surface noattr)))) :: nil)))))
        (Sset _floorHeight (Etempvar _t'3 tfloat)))
      (Ssequence
        (Ssequence
          (Scall (Some _t'4)
            (Evar _vec3f_find_ceil (Tfunction
                                     ((tptr tfloat) :: tfloat ::
                                      (tptr (tptr (Tstruct _Surface noattr))) ::
                                      nil) tfloat cc_default))
            ((Etempvar _nextPos (tptr tfloat)) ::
             (Etempvar _floorHeight tfloat) ::
             (Eaddrof (Evar _ceil (tptr (Tstruct _Surface noattr)))
               (tptr (tptr (Tstruct _Surface noattr)))) :: nil))
          (Sset _ceilHeight (Etempvar _t'4 tfloat)))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'22
                (Ederef
                  (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                    (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
              (Ssequence
                (Sset _t'23
                  (Ederef
                    (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                      (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
                (Scall (Some _t'5)
                  (Evar _find_water_level (Tfunction
                                            (tfloat :: tfloat :: nil) tfloat
                                            cc_default))
                  ((Etempvar _t'22 tfloat) :: (Etempvar _t'23 tfloat) :: nil))))
            (Sset _waterLevel (Etempvar _t'5 tfloat)))
          (Ssequence
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _wall
                (tptr (Tstruct _Surface noattr)))
              (Etempvar _upperWall (tptr (Tstruct _Surface noattr))))
            (Ssequence
              (Ssequence
                (Sset _t'21 (Evar _floor (tptr (Tstruct _Surface noattr))))
                (Sifthenelse (Ebinop Oeq
                               (Etempvar _t'21 (tptr (Tstruct _Surface noattr)))
                               (Ecast (Econst_int (Int.repr 0) tint)
                                 (tptr tvoid)) tint)
                  (Sreturn (Some (Econst_int (Int.repr 2) tint)))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'20
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _action tuint))
                    (Sifthenelse (Ebinop Oand (Etempvar _t'20 tuint)
                                   (Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 16) tint) tint)
                                   tuint)
                      (Sset _t'6
                        (Ecast
                          (Ebinop Olt (Etempvar _floorHeight tfloat)
                            (Etempvar _waterLevel tfloat) tint) tbool))
                      (Sset _t'6 (Econst_int (Int.repr 0) tint))))
                  (Sifthenelse (Etempvar _t'6 tint)
                    (Ssequence
                      (Sset _floorHeight (Etempvar _waterLevel tfloat))
                      (Ssequence
                        (Sassign
                          (Evar _floor (tptr (Tstruct _Surface noattr)))
                          (Eaddrof
                            (Evar _gWaterSurfacePseudoFloor (Tstruct _Surface noattr))
                            (tptr (Tstruct _Surface noattr))))
                        (Ssequence
                          (Sset _t'19
                            (Evar _floor (tptr (Tstruct _Surface noattr))))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _t'19 (tptr (Tstruct _Surface noattr)))
                                (Tstruct _Surface noattr)) _originOffset
                              tfloat) (Etempvar _floorHeight tfloat)))))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sset _t'16
                      (Ederef
                        (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                          (Econst_int (Int.repr 1) tint) (tptr tfloat))
                        tfloat))
                    (Sifthenelse (Ebinop Ogt (Etempvar _t'16 tfloat)
                                   (Ebinop Oadd
                                     (Etempvar _floorHeight tfloat)
                                     (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                                     tfloat) tint)
                      (Ssequence
                        (Ssequence
                          (Sset _t'18
                            (Ederef
                              (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                                (Econst_int (Int.repr 1) tint) (tptr tfloat))
                              tfloat))
                          (Sifthenelse (Ebinop Oge
                                         (Ebinop Oadd (Etempvar _t'18 tfloat)
                                           (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat)
                                           tfloat)
                                         (Etempvar _ceilHeight tfloat) tint)
                            (Sreturn (Some (Econst_int (Int.repr 2) tint)))
                            Sskip))
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
                              (Sset _t'17
                                (Evar _floor (tptr (Tstruct _Surface noattr))))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _floor
                                  (tptr (Tstruct _Surface noattr)))
                                (Etempvar _t'17 (tptr (Tstruct _Surface noattr)))))
                            (Ssequence
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr))
                                  _floorHeight tfloat)
                                (Etempvar _floorHeight tfloat))
                              (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
                      Sskip))
                  (Ssequence
                    (Sifthenelse (Ebinop Oge
                                   (Ebinop Oadd
                                     (Etempvar _floorHeight tfloat)
                                     (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat)
                                     tfloat) (Etempvar _ceilHeight tfloat)
                                   tint)
                      (Sreturn (Some (Econst_int (Int.repr 2) tint)))
                      Sskip)
                    (Ssequence
                      (Ssequence
                        (Sset _t'14
                          (Ederef
                            (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                              (Econst_int (Int.repr 0) tint) (tptr tfloat))
                            tfloat))
                        (Ssequence
                          (Sset _t'15
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
                               (tarray tfloat 3)) ::
                             (Etempvar _t'14 tfloat) ::
                             (Etempvar _floorHeight tfloat) ::
                             (Etempvar _t'15 tfloat) :: nil))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'13
                            (Evar _floor (tptr (Tstruct _Surface noattr))))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _floor
                              (tptr (Tstruct _Surface noattr)))
                            (Etempvar _t'13 (tptr (Tstruct _Surface noattr)))))
                        (Ssequence
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _floorHeight
                              tfloat) (Etempvar _floorHeight tfloat))
                          (Ssequence
                            (Sifthenelse (Ebinop One
                                           (Etempvar _upperWall (tptr (Tstruct _Surface noattr)))
                                           (Ecast
                                             (Econst_int (Int.repr 0) tint)
                                             (tptr tvoid)) tint)
                              (Ssequence
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'11
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _upperWall (tptr (Tstruct _Surface noattr)))
                                            (Tstruct _Surface noattr))
                                          _normal (Tstruct __670 noattr)) _z
                                        tfloat))
                                    (Ssequence
                                      (Sset _t'12
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar _upperWall (tptr (Tstruct _Surface noattr)))
                                              (Tstruct _Surface noattr))
                                            _normal (Tstruct __670 noattr))
                                          _x tfloat))
                                      (Scall (Some _t'7)
                                        (Evar _atan2s (Tfunction
                                                        (tfloat :: tfloat ::
                                                         nil) tshort
                                                        cc_default))
                                        ((Etempvar _t'11 tfloat) ::
                                         (Etempvar _t'12 tfloat) :: nil))))
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
                                    (Sset _wallDYaw
                                      (Ecast
                                        (Ebinop Osub (Etempvar _t'7 tshort)
                                          (Etempvar _t'10 tshort) tint)
                                        tshort))))
                                (Ssequence
                                  (Ssequence
                                    (Sifthenelse (Ebinop Oge
                                                   (Etempvar _wallDYaw tshort)
                                                   (Econst_int (Int.repr 10922) tint)
                                                   tint)
                                      (Sset _t'8
                                        (Ecast
                                          (Ebinop Ole
                                            (Etempvar _wallDYaw tshort)
                                            (Econst_int (Int.repr 21845) tint)
                                            tint) tbool))
                                      (Sset _t'8
                                        (Econst_int (Int.repr 0) tint)))
                                    (Sifthenelse (Etempvar _t'8 tint)
                                      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
                                      Sskip))
                                  (Ssequence
                                    (Ssequence
                                      (Sifthenelse (Ebinop Ole
                                                     (Etempvar _wallDYaw tshort)
                                                     (Eunop Oneg
                                                       (Econst_int (Int.repr 10922) tint)
                                                       tint) tint)
                                        (Sset _t'9
                                          (Ecast
                                            (Ebinop Oge
                                              (Etempvar _wallDYaw tshort)
                                              (Eunop Oneg
                                                (Econst_int (Int.repr 21845) tint)
                                                tint) tint) tbool))
                                        (Sset _t'9
                                          (Econst_int (Int.repr 0) tint)))
                                      (Sifthenelse (Etempvar _t'9 tint)
                                        (Sreturn (Some (Econst_int (Int.repr 1) tint)))
                                        Sskip))
                                    (Sreturn (Some (Econst_int (Int.repr 3) tint))))))
                              Sskip)
                            (Sreturn (Some (Econst_int (Int.repr 1) tint)))))))))))))))))
|}.

Definition f_perform_ground_step := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := ((_intendedPos, (tarray tfloat 3)) :: nil);
  fn_temps := ((_i, tint) :: (_stepResult, tuint) :: (_t'3, tuint) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'15, tfloat) ::
               (_t'14, tfloat) ::
               (_t'13, (tptr (Tstruct _Surface noattr))) ::
               (_t'12, tfloat) :: (_t'11, tfloat) :: (_t'10, tfloat) ::
               (_t'9, (tptr (Tstruct _Surface noattr))) :: (_t'8, tfloat) ::
               (_t'7, tfloat) :: (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, tshort) :: (_t'4, (tptr (Tstruct _Object noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _i (Econst_int (Int.repr 0) tint))
    (Sloop
      (Ssequence
        (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                       (Econst_int (Int.repr 4) tint) tint)
          Sskip
          Sbreak)
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
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _floor
                  (tptr (Tstruct _Surface noattr))))
              (Ssequence
                (Sset _t'14
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _t'13 (tptr (Tstruct _Surface noattr)))
                        (Tstruct _Surface noattr)) _normal
                      (Tstruct __670 noattr)) _y tfloat))
                (Ssequence
                  (Sset _t'15
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _vel
                          (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tfloat)) tfloat))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd (Evar _intendedPos (tarray tfloat 3))
                        (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
                    (Ebinop Oadd (Etempvar _t'12 tfloat)
                      (Ebinop Omul (Etempvar _t'14 tfloat)
                        (Ebinop Odiv (Etempvar _t'15 tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                          tfloat) tfloat) tfloat))))))
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
                        (Tstruct __670 noattr)) _y tfloat))
                  (Ssequence
                    (Sset _t'11
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _vel
                            (tarray tfloat 3)) (Econst_int (Int.repr 2) tint)
                          (tptr tfloat)) tfloat))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd (Evar _intendedPos (tarray tfloat 3))
                          (Econst_int (Int.repr 2) tint) (tptr tfloat))
                        tfloat)
                      (Ebinop Oadd (Etempvar _t'8 tfloat)
                        (Ebinop Omul (Etempvar _t'10 tfloat)
                          (Ebinop Odiv (Etempvar _t'11 tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                            tfloat) tfloat) tfloat))))))
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
                (Sassign
                  (Ederef
                    (Ebinop Oadd (Evar _intendedPos (tarray tfloat 3))
                      (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
                  (Etempvar _t'7 tfloat)))
              (Ssequence
                (Ssequence
                  (Scall (Some _t'1)
                    (Evar _perform_ground_quarter_step (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          (tptr tfloat) ::
                                                          nil) tint
                                                         cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Evar _intendedPos (tarray tfloat 3)) :: nil))
                  (Sset _stepResult (Etempvar _t'1 tint)))
                (Ssequence
                  (Sifthenelse (Ebinop Oeq (Etempvar _stepResult tuint)
                                 (Econst_int (Int.repr 0) tint) tint)
                    (Sset _t'2 (Econst_int (Int.repr 1) tint))
                    (Sset _t'2
                      (Ecast
                        (Ebinop Oeq (Etempvar _stepResult tuint)
                          (Econst_int (Int.repr 2) tint) tint) tbool)))
                  (Sifthenelse (Etempvar _t'2 tint) Sbreak Sskip)))))))
      (Sset _i
        (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint) tint))))
  (Ssequence
    (Ssequence
      (Scall (Some _t'3)
        (Evar _mario_get_terrain_sound_addend (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tuint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Sassign
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _terrainSoundAddend tuint)
        (Etempvar _t'3 tuint)))
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
             (Efield
               (Efield
                 (Ederef (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                   (Tstruct _Object noattr)) _header
                 (Tstruct _ObjectNode noattr)) _gfx
               (Tstruct _GraphNodeObject noattr)) _pos (tarray tfloat 3)) ::
           (Efield
             (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
               (Tstruct _MarioState noattr)) _pos (tarray tfloat 3)) :: nil)))
      (Ssequence
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
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
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
                     (Ederef (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                       (Tstruct _Object noattr)) _header
                     (Tstruct _ObjectNode noattr)) _gfx
                   (Tstruct _GraphNodeObject noattr)) _angle
                 (tarray tshort 3)) :: (Econst_int (Int.repr 0) tint) ::
               (Etempvar _t'5 tshort) :: (Econst_int (Int.repr 0) tint) ::
               nil))))
        (Ssequence
          (Sifthenelse (Ebinop Oeq (Etempvar _stepResult tuint)
                         (Econst_int (Int.repr 3) tint) tint)
            (Sset _stepResult (Econst_int (Int.repr 2) tint))
            Sskip)
          (Sreturn (Some (Etempvar _stepResult tuint))))))))
|}.

Definition f_check_ledge_grab := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_wall, (tptr (Tstruct _Surface noattr))) ::
                (_intendedPos, (tptr tfloat)) :: (_nextPos, (tptr tfloat)) ::
                nil);
  fn_vars := ((_ledgeFloor, (tptr (Tstruct _Surface noattr))) ::
              (_ledgePos, (tarray tfloat 3)) :: nil);
  fn_temps := ((_displacementX, tfloat) :: (_displacementZ, tfloat) ::
               (_t'3, tshort) :: (_t'2, tshort) :: (_t'1, tfloat) ::
               (_t'27, tfloat) :: (_t'26, tfloat) :: (_t'25, tfloat) ::
               (_t'24, tfloat) :: (_t'23, tfloat) :: (_t'22, tfloat) ::
               (_t'21, tfloat) :: (_t'20, tfloat) :: (_t'19, tfloat) ::
               (_t'18, tfloat) :: (_t'17, tfloat) :: (_t'16, tfloat) ::
               (_t'15, tfloat) :: (_t'14, tfloat) :: (_t'13, tfloat) ::
               (_t'12, tfloat) ::
               (_t'11, (tptr (Tstruct _Surface noattr))) ::
               (_t'10, tfloat) :: (_t'9, tfloat) ::
               (_t'8, (tptr (Tstruct _Surface noattr))) :: (_t'7, tfloat) ::
               (_t'6, (tptr (Tstruct _Surface noattr))) :: (_t'5, tfloat) ::
               (_t'4, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'27
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
          (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
    (Sifthenelse (Ebinop Ogt (Etempvar _t'27 tfloat)
                   (Econst_int (Int.repr 0) tint) tint)
      (Sreturn (Some (Econst_int (Int.repr 0) tint)))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'25
        (Ederef
          (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
            (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
      (Ssequence
        (Sset _t'26
          (Ederef
            (Ebinop Oadd (Etempvar _intendedPos (tptr tfloat))
              (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
        (Sset _displacementX
          (Ebinop Osub (Etempvar _t'25 tfloat) (Etempvar _t'26 tfloat)
            tfloat))))
    (Ssequence
      (Ssequence
        (Sset _t'23
          (Ederef
            (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
              (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
        (Ssequence
          (Sset _t'24
            (Ederef
              (Ebinop Oadd (Etempvar _intendedPos (tptr tfloat))
                (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
          (Sset _displacementZ
            (Ebinop Osub (Etempvar _t'23 tfloat) (Etempvar _t'24 tfloat)
              tfloat))))
      (Ssequence
        (Ssequence
          (Sset _t'21
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
          (Ssequence
            (Sset _t'22
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                  (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
            (Sifthenelse (Ebinop Ogt
                           (Ebinop Oadd
                             (Ebinop Omul (Etempvar _displacementX tfloat)
                               (Etempvar _t'21 tfloat) tfloat)
                             (Ebinop Omul (Etempvar _displacementZ tfloat)
                               (Etempvar _t'22 tfloat) tfloat) tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                           tint)
              (Sreturn (Some (Econst_int (Int.repr 0) tint)))
              Sskip)))
        (Ssequence
          (Ssequence
            (Sset _t'19
              (Ederef
                (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                  (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
            (Ssequence
              (Sset _t'20
                (Efield
                  (Efield
                    (Ederef (Etempvar _wall (tptr (Tstruct _Surface noattr)))
                      (Tstruct _Surface noattr)) _normal
                    (Tstruct __670 noattr)) _x tfloat))
              (Sassign
                (Ederef
                  (Ebinop Oadd (Evar _ledgePos (tarray tfloat 3))
                    (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
                (Ebinop Osub (Etempvar _t'19 tfloat)
                  (Ebinop Omul (Etempvar _t'20 tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat)
                    tfloat) tfloat))))
          (Ssequence
            (Ssequence
              (Sset _t'17
                (Ederef
                  (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                    (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
              (Ssequence
                (Sset _t'18
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _wall (tptr (Tstruct _Surface noattr)))
                        (Tstruct _Surface noattr)) _normal
                      (Tstruct __670 noattr)) _z tfloat))
                (Sassign
                  (Ederef
                    (Ebinop Oadd (Evar _ledgePos (tarray tfloat 3))
                      (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat)
                  (Ebinop Osub (Etempvar _t'17 tfloat)
                    (Ebinop Omul (Etempvar _t'18 tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat)
                      tfloat) tfloat))))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'14
                    (Ederef
                      (Ebinop Oadd (Evar _ledgePos (tarray tfloat 3))
                        (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
                  (Ssequence
                    (Sset _t'15
                      (Ederef
                        (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                          (Econst_int (Int.repr 1) tint) (tptr tfloat))
                        tfloat))
                    (Ssequence
                      (Sset _t'16
                        (Ederef
                          (Ebinop Oadd (Evar _ledgePos (tarray tfloat 3))
                            (Econst_int (Int.repr 2) tint) (tptr tfloat))
                          tfloat))
                      (Scall (Some _t'1)
                        (Evar _find_floor (Tfunction
                                            (tfloat :: tfloat :: tfloat ::
                                             (tptr (tptr (Tstruct _Surface noattr))) ::
                                             nil) tfloat cc_default))
                        ((Etempvar _t'14 tfloat) ::
                         (Ebinop Oadd (Etempvar _t'15 tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat)
                           tfloat) :: (Etempvar _t'16 tfloat) ::
                         (Eaddrof
                           (Evar _ledgeFloor (tptr (Tstruct _Surface noattr)))
                           (tptr (tptr (Tstruct _Surface noattr)))) :: nil)))))
                (Sassign
                  (Ederef
                    (Ebinop Oadd (Evar _ledgePos (tarray tfloat 3))
                      (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
                  (Etempvar _t'1 tfloat)))
              (Ssequence
                (Ssequence
                  (Sset _t'12
                    (Ederef
                      (Ebinop Oadd (Evar _ledgePos (tarray tfloat 3))
                        (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
                  (Ssequence
                    (Sset _t'13
                      (Ederef
                        (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                          (Econst_int (Int.repr 1) tint) (tptr tfloat))
                        tfloat))
                    (Sifthenelse (Ebinop Ole
                                   (Ebinop Osub (Etempvar _t'12 tfloat)
                                     (Etempvar _t'13 tfloat) tfloat)
                                   (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                                   tint)
                      (Sreturn (Some (Econst_int (Int.repr 0) tint)))
                      Sskip)))
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
                     (Evar _ledgePos (tarray tfloat 3)) :: nil))
                  (Ssequence
                    (Ssequence
                      (Sset _t'11
                        (Evar _ledgeFloor (tptr (Tstruct _Surface noattr))))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _floor
                          (tptr (Tstruct _Surface noattr)))
                        (Etempvar _t'11 (tptr (Tstruct _Surface noattr)))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'10
                          (Ederef
                            (Ebinop Oadd (Evar _ledgePos (tarray tfloat 3))
                              (Econst_int (Int.repr 1) tint) (tptr tfloat))
                            tfloat))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _floorHeight
                            tfloat) (Etempvar _t'10 tfloat)))
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'6
                              (Evar _ledgeFloor (tptr (Tstruct _Surface noattr))))
                            (Ssequence
                              (Sset _t'7
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'6 (tptr (Tstruct _Surface noattr)))
                                      (Tstruct _Surface noattr)) _normal
                                    (Tstruct __670 noattr)) _z tfloat))
                              (Ssequence
                                (Sset _t'8
                                  (Evar _ledgeFloor (tptr (Tstruct _Surface noattr))))
                                (Ssequence
                                  (Sset _t'9
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'8 (tptr (Tstruct _Surface noattr)))
                                          (Tstruct _Surface noattr)) _normal
                                        (Tstruct __670 noattr)) _x tfloat))
                                  (Scall (Some _t'2)
                                    (Evar _atan2s (Tfunction
                                                    (tfloat :: tfloat :: nil)
                                                    tshort cc_default))
                                    ((Etempvar _t'7 tfloat) ::
                                     (Etempvar _t'9 tfloat) :: nil))))))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _floorAngle
                              tshort) (Etempvar _t'2 tshort)))
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
                              (Ssequence
                                (Sset _t'4
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _wall (tptr (Tstruct _Surface noattr)))
                                        (Tstruct _Surface noattr)) _normal
                                      (Tstruct __670 noattr)) _z tfloat))
                                (Ssequence
                                  (Sset _t'5
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _wall (tptr (Tstruct _Surface noattr)))
                                          (Tstruct _Surface noattr)) _normal
                                        (Tstruct __670 noattr)) _x tfloat))
                                  (Scall (Some _t'3)
                                    (Evar _atan2s (Tfunction
                                                    (tfloat :: tfloat :: nil)
                                                    tshort cc_default))
                                    ((Etempvar _t'4 tfloat) ::
                                     (Etempvar _t'5 tfloat) :: nil))))
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
                            (Sreturn (Some (Econst_int (Int.repr 1) tint)))))))))))))))))
|}.

Definition f_perform_air_quarter_step := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_intendedPos, (tptr tfloat)) :: (_stepArg, tuint) :: nil);
  fn_vars := ((_nextPos, (tarray tfloat 3)) ::
              (_ceil, (tptr (Tstruct _Surface noattr))) ::
              (_floor, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_temps := ((_wallDYaw, tshort) ::
               (_upperWall, (tptr (Tstruct _Surface noattr))) ::
               (_lowerWall, (tptr (Tstruct _Surface noattr))) ::
               (_ceilHeight, tfloat) :: (_floorHeight, tfloat) ::
               (_waterLevel, tfloat) :: (_t'15, tint) :: (_t'14, tint) ::
               (_t'13, tshort) ::
               (_t'12, (tptr (Tstruct _Surface noattr))) :: (_t'11, tint) ::
               (_t'10, tint) :: (_t'9, tuint) :: (_t'8, tint) ::
               (_t'7, tint) :: (_t'6, tint) :: (_t'5, tfloat) ::
               (_t'4, tfloat) :: (_t'3, tfloat) ::
               (_t'2, (tptr (Tstruct _Surface noattr))) ::
               (_t'1, (tptr (Tstruct _Surface noattr))) :: (_t'50, tfloat) ::
               (_t'49, tfloat) :: (_t'48, tfloat) :: (_t'47, tfloat) ::
               (_t'46, tfloat) :: (_t'45, tfloat) :: (_t'44, tfloat) ::
               (_t'43, tfloat) :: (_t'42, tfloat) ::
               (_t'41, (tptr (Tstruct _Surface noattr))) :: (_t'40, tuint) ::
               (_t'39, (tptr (Tstruct _Surface noattr))) ::
               (_t'38, tfloat) :: (_t'37, tfloat) ::
               (_t'36, (tptr (Tstruct _Surface noattr))) ::
               (_t'35, tfloat) ::
               (_t'34, (tptr (Tstruct _Surface noattr))) ::
               (_t'33, tshort) ::
               (_t'32, (tptr (Tstruct _Surface noattr))) ::
               (_t'31, tfloat) :: (_t'30, tfloat) :: (_t'29, tfloat) ::
               (_t'28, tfloat) :: (_t'27, tfloat) :: (_t'26, tfloat) ::
               (_t'25, (tptr (Tstruct _Surface noattr))) ::
               (_t'24, (tptr (Tstruct _Surface noattr))) ::
               (_t'23, tfloat) ::
               (_t'22, (tptr (Tstruct _Surface noattr))) ::
               (_t'21, tfloat) ::
               (_t'20, (tptr (Tstruct _Surface noattr))) ::
               (_t'19, tshort) :: (_t'18, tshort) ::
               (_t'17, (tptr (Tstruct _Surface noattr))) :: (_t'16, tuint) ::
               nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _vec3f_copy (Tfunction ((tptr tfloat) :: (tptr tfloat) :: nil)
                        (tptr tvoid) cc_default))
    ((Evar _nextPos (tarray tfloat 3)) ::
     (Etempvar _intendedPos (tptr tfloat)) :: nil))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _resolve_and_return_wall_collisions (Tfunction
                                                    ((tptr tfloat) ::
                                                     tfloat :: tfloat :: nil)
                                                    (tptr (Tstruct _Surface noattr))
                                                    cc_default))
        ((Evar _nextPos (tarray tfloat 3)) ::
         (Econst_single (Float32.of_bits (Int.repr 1125515264)) tfloat) ::
         (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat) ::
         nil))
      (Sset _upperWall (Etempvar _t'1 (tptr (Tstruct _Surface noattr)))))
    (Ssequence
      (Ssequence
        (Scall (Some _t'2)
          (Evar _resolve_and_return_wall_collisions (Tfunction
                                                      ((tptr tfloat) ::
                                                       tfloat :: tfloat ::
                                                       nil)
                                                      (tptr (Tstruct _Surface noattr))
                                                      cc_default))
          ((Evar _nextPos (tarray tfloat 3)) ::
           (Econst_single (Float32.of_bits (Int.repr 1106247680)) tfloat) ::
           (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat) ::
           nil))
        (Sset _lowerWall (Etempvar _t'2 (tptr (Tstruct _Surface noattr)))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'48
              (Ederef
                (Ebinop Oadd (Evar _nextPos (tarray tfloat 3))
                  (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
            (Ssequence
              (Sset _t'49
                (Ederef
                  (Ebinop Oadd (Evar _nextPos (tarray tfloat 3))
                    (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
              (Ssequence
                (Sset _t'50
                  (Ederef
                    (Ebinop Oadd (Evar _nextPos (tarray tfloat 3))
                      (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
                (Scall (Some _t'3)
                  (Evar _find_floor (Tfunction
                                      (tfloat :: tfloat :: tfloat ::
                                       (tptr (tptr (Tstruct _Surface noattr))) ::
                                       nil) tfloat cc_default))
                  ((Etempvar _t'48 tfloat) :: (Etempvar _t'49 tfloat) ::
                   (Etempvar _t'50 tfloat) ::
                   (Eaddrof (Evar _floor (tptr (Tstruct _Surface noattr)))
                     (tptr (tptr (Tstruct _Surface noattr)))) :: nil)))))
          (Sset _floorHeight (Etempvar _t'3 tfloat)))
        (Ssequence
          (Ssequence
            (Scall (Some _t'4)
              (Evar _vec3f_find_ceil (Tfunction
                                       ((tptr tfloat) :: tfloat ::
                                        (tptr (tptr (Tstruct _Surface noattr))) ::
                                        nil) tfloat cc_default))
              ((Evar _nextPos (tarray tfloat 3)) ::
               (Etempvar _floorHeight tfloat) ::
               (Eaddrof (Evar _ceil (tptr (Tstruct _Surface noattr)))
                 (tptr (tptr (Tstruct _Surface noattr)))) :: nil))
            (Sset _ceilHeight (Etempvar _t'4 tfloat)))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'46
                  (Ederef
                    (Ebinop Oadd (Evar _nextPos (tarray tfloat 3))
                      (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
                (Ssequence
                  (Sset _t'47
                    (Ederef
                      (Ebinop Oadd (Evar _nextPos (tarray tfloat 3))
                        (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
                  (Scall (Some _t'5)
                    (Evar _find_water_level (Tfunction
                                              (tfloat :: tfloat :: nil)
                                              tfloat cc_default))
                    ((Etempvar _t'46 tfloat) :: (Etempvar _t'47 tfloat) ::
                     nil))))
              (Sset _waterLevel (Etempvar _t'5 tfloat)))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _wall
                  (tptr (Tstruct _Surface noattr)))
                (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
              (Ssequence
                (Ssequence
                  (Sset _t'41 (Evar _floor (tptr (Tstruct _Surface noattr))))
                  (Sifthenelse (Ebinop Oeq
                                 (Etempvar _t'41 (tptr (Tstruct _Surface noattr)))
                                 (Ecast (Econst_int (Int.repr 0) tint)
                                   (tptr tvoid)) tint)
                    (Ssequence
                      (Ssequence
                        (Sset _t'43
                          (Ederef
                            (Ebinop Oadd (Evar _nextPos (tarray tfloat 3))
                              (Econst_int (Int.repr 1) tint) (tptr tfloat))
                            tfloat))
                        (Ssequence
                          (Sset _t'44
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _floorHeight
                              tfloat))
                          (Sifthenelse (Ebinop Ole (Etempvar _t'43 tfloat)
                                         (Etempvar _t'44 tfloat) tint)
                            (Ssequence
                              (Ssequence
                                (Sset _t'45
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
                                          (Tstruct _MarioState noattr)) _pos
                                        (tarray tfloat 3))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr tfloat)) tfloat)
                                  (Etempvar _t'45 tfloat)))
                              (Sreturn (Some (Econst_int (Int.repr 1) tint))))
                            Sskip)))
                      (Ssequence
                        (Ssequence
                          (Sset _t'42
                            (Ederef
                              (Ebinop Oadd (Evar _nextPos (tarray tfloat 3))
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
                              tfloat) (Etempvar _t'42 tfloat)))
                        (Sreturn (Some (Econst_int (Int.repr 2) tint)))))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'40
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _action tuint))
                      (Sifthenelse (Ebinop Oand (Etempvar _t'40 tuint)
                                     (Ebinop Oshl
                                       (Econst_int (Int.repr 1) tint)
                                       (Econst_int (Int.repr 16) tint) tint)
                                     tuint)
                        (Sset _t'6
                          (Ecast
                            (Ebinop Olt (Etempvar _floorHeight tfloat)
                              (Etempvar _waterLevel tfloat) tint) tbool))
                        (Sset _t'6 (Econst_int (Int.repr 0) tint))))
                    (Sifthenelse (Etempvar _t'6 tint)
                      (Ssequence
                        (Sset _floorHeight (Etempvar _waterLevel tfloat))
                        (Ssequence
                          (Sassign
                            (Evar _floor (tptr (Tstruct _Surface noattr)))
                            (Eaddrof
                              (Evar _gWaterSurfacePseudoFloor (Tstruct _Surface noattr))
                              (tptr (Tstruct _Surface noattr))))
                          (Ssequence
                            (Sset _t'39
                              (Evar _floor (tptr (Tstruct _Surface noattr))))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _t'39 (tptr (Tstruct _Surface noattr)))
                                  (Tstruct _Surface noattr)) _originOffset
                                tfloat) (Etempvar _floorHeight tfloat)))))
                      Sskip))
                  (Ssequence
                    (Ssequence
                      (Sset _t'35
                        (Ederef
                          (Ebinop Oadd (Evar _nextPos (tarray tfloat 3))
                            (Econst_int (Int.repr 1) tint) (tptr tfloat))
                          tfloat))
                      (Sifthenelse (Ebinop Ole (Etempvar _t'35 tfloat)
                                     (Etempvar _floorHeight tfloat) tint)
                        (Ssequence
                          (Sifthenelse (Ebinop Ogt
                                         (Ebinop Osub
                                           (Etempvar _ceilHeight tfloat)
                                           (Etempvar _floorHeight tfloat)
                                           tfloat)
                                         (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat)
                                         tint)
                            (Ssequence
                              (Ssequence
                                (Sset _t'38
                                  (Ederef
                                    (Ebinop Oadd
                                      (Evar _nextPos (tarray tfloat 3))
                                      (Econst_int (Int.repr 0) tint)
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
                                  (Etempvar _t'38 tfloat)))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'37
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _nextPos (tarray tfloat 3))
                                        (Econst_int (Int.repr 2) tint)
                                        (tptr tfloat)) tfloat))
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
                                    (Etempvar _t'37 tfloat)))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'36
                                      (Evar _floor (tptr (Tstruct _Surface noattr))))
                                    (Sassign
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _floor
                                        (tptr (Tstruct _Surface noattr)))
                                      (Etempvar _t'36 (tptr (Tstruct _Surface noattr)))))
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _floorHeight tfloat)
                                    (Etempvar _floorHeight tfloat)))))
                            Sskip)
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
                            (Sreturn (Some (Econst_int (Int.repr 1) tint)))))
                        Sskip))
                    (Ssequence
                      (Ssequence
                        (Sset _t'26
                          (Ederef
                            (Ebinop Oadd (Evar _nextPos (tarray tfloat 3))
                              (Econst_int (Int.repr 1) tint) (tptr tfloat))
                            tfloat))
                        (Sifthenelse (Ebinop Ogt
                                       (Ebinop Oadd (Etempvar _t'26 tfloat)
                                         (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat)
                                         tfloat)
                                       (Etempvar _ceilHeight tfloat) tint)
                          (Ssequence
                            (Ssequence
                              (Sset _t'31
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr)) _vel
                                      (tarray tfloat 3))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr tfloat)) tfloat))
                              (Sifthenelse (Ebinop Oge
                                             (Etempvar _t'31 tfloat)
                                             (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                             tint)
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
                                    (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                                  (Ssequence
                                    (Ssequence
                                      (Ssequence
                                        (Sifthenelse (Ebinop Oand
                                                       (Etempvar _stepArg tuint)
                                                       (Econst_int (Int.repr 2) tint)
                                                       tuint)
                                          (Ssequence
                                            (Sset _t'34
                                              (Efield
                                                (Ederef
                                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                  (Tstruct _MarioState noattr))
                                                _ceil
                                                (tptr (Tstruct _Surface noattr))))
                                            (Sset _t'7
                                              (Ecast
                                                (Ebinop One
                                                  (Etempvar _t'34 (tptr (Tstruct _Surface noattr)))
                                                  (Ecast
                                                    (Econst_int (Int.repr 0) tint)
                                                    (tptr tvoid)) tint)
                                                tbool)))
                                          (Sset _t'7
                                            (Econst_int (Int.repr 0) tint)))
                                        (Sifthenelse (Etempvar _t'7 tint)
                                          (Ssequence
                                            (Sset _t'32
                                              (Efield
                                                (Ederef
                                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                  (Tstruct _MarioState noattr))
                                                _ceil
                                                (tptr (Tstruct _Surface noattr))))
                                            (Ssequence
                                              (Sset _t'33
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _t'32 (tptr (Tstruct _Surface noattr)))
                                                    (Tstruct _Surface noattr))
                                                  _type tshort))
                                              (Sset _t'8
                                                (Ecast
                                                  (Ebinop Oeq
                                                    (Etempvar _t'33 tshort)
                                                    (Econst_int (Int.repr 5) tint)
                                                    tint) tbool))))
                                          (Sset _t'8
                                            (Econst_int (Int.repr 0) tint))))
                                      (Sifthenelse (Etempvar _t'8 tint)
                                        (Sreturn (Some (Econst_int (Int.repr 4) tint)))
                                        Sskip))
                                    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
                                Sskip))
                            (Ssequence
                              (Ssequence
                                (Sset _t'28
                                  (Ederef
                                    (Ebinop Oadd
                                      (Evar _nextPos (tarray tfloat 3))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr tfloat)) tfloat))
                                (Ssequence
                                  (Sset _t'29
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _floorHeight tfloat))
                                  (Sifthenelse (Ebinop Ole
                                                 (Etempvar _t'28 tfloat)
                                                 (Etempvar _t'29 tfloat)
                                                 tint)
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'30
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
                                                _pos (tarray tfloat 3))
                                              (Econst_int (Int.repr 1) tint)
                                              (tptr tfloat)) tfloat)
                                          (Etempvar _t'30 tfloat)))
                                      (Sreturn (Some (Econst_int (Int.repr 1) tint))))
                                    Sskip)))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'27
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _nextPos (tarray tfloat 3))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr tfloat)) tfloat))
                                  (Sassign
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Ederef
                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _pos (tarray tfloat 3))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr tfloat)) tfloat)
                                    (Etempvar _t'27 tfloat)))
                                (Sreturn (Some (Econst_int (Int.repr 2) tint))))))
                          Sskip))
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sifthenelse (Ebinop Oand
                                           (Etempvar _stepArg tuint)
                                           (Econst_int (Int.repr 1) tint)
                                           tuint)
                              (Sset _t'10
                                (Ecast
                                  (Ebinop Oeq
                                    (Etempvar _upperWall (tptr (Tstruct _Surface noattr)))
                                    (Ecast (Econst_int (Int.repr 0) tint)
                                      (tptr tvoid)) tint) tbool))
                              (Sset _t'10 (Econst_int (Int.repr 0) tint)))
                            (Sifthenelse (Etempvar _t'10 tint)
                              (Sset _t'11
                                (Ecast
                                  (Ebinop One
                                    (Etempvar _lowerWall (tptr (Tstruct _Surface noattr)))
                                    (Ecast (Econst_int (Int.repr 0) tint)
                                      (tptr tvoid)) tint) tbool))
                              (Sset _t'11 (Econst_int (Int.repr 0) tint))))
                          (Sifthenelse (Etempvar _t'11 tint)
                            (Ssequence
                              (Ssequence
                                (Scall (Some _t'9)
                                  (Evar _check_ledge_grab (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             (tptr (Tstruct _Surface noattr)) ::
                                                             (tptr tfloat) ::
                                                             (tptr tfloat) ::
                                                             nil) tuint
                                                            cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   (Etempvar _lowerWall (tptr (Tstruct _Surface noattr))) ::
                                   (Etempvar _intendedPos (tptr tfloat)) ::
                                   (Evar _nextPos (tarray tfloat 3)) :: nil))
                                (Sifthenelse (Etempvar _t'9 tuint)
                                  (Sreturn (Some (Econst_int (Int.repr 3) tint)))
                                  Sskip))
                              (Ssequence
                                (Scall None
                                  (Evar _vec3f_copy (Tfunction
                                                      ((tptr tfloat) ::
                                                       (tptr tfloat) :: nil)
                                                      (tptr tvoid)
                                                      cc_default))
                                  ((Efield
                                     (Ederef
                                       (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                       (Tstruct _MarioState noattr)) _pos
                                     (tarray tfloat 3)) ::
                                   (Evar _nextPos (tarray tfloat 3)) :: nil))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'25
                                      (Evar _floor (tptr (Tstruct _Surface noattr))))
                                    (Sassign
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _floor
                                        (tptr (Tstruct _Surface noattr)))
                                      (Etempvar _t'25 (tptr (Tstruct _Surface noattr)))))
                                  (Ssequence
                                    (Sassign
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _floorHeight tfloat)
                                      (Etempvar _floorHeight tfloat))
                                    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
                            Sskip))
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
                             (Evar _nextPos (tarray tfloat 3)) :: nil))
                          (Ssequence
                            (Ssequence
                              (Sset _t'24
                                (Evar _floor (tptr (Tstruct _Surface noattr))))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _floor
                                  (tptr (Tstruct _Surface noattr)))
                                (Etempvar _t'24 (tptr (Tstruct _Surface noattr)))))
                            (Ssequence
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr))
                                  _floorHeight tfloat)
                                (Etempvar _floorHeight tfloat))
                              (Ssequence
                                (Ssequence
                                  (Sifthenelse (Ebinop One
                                                 (Etempvar _upperWall (tptr (Tstruct _Surface noattr)))
                                                 (Ecast
                                                   (Econst_int (Int.repr 0) tint)
                                                   (tptr tvoid)) tint)
                                    (Sset _t'15
                                      (Econst_int (Int.repr 1) tint))
                                    (Sset _t'15
                                      (Ecast
                                        (Ebinop One
                                          (Etempvar _lowerWall (tptr (Tstruct _Surface noattr)))
                                          (Ecast
                                            (Econst_int (Int.repr 0) tint)
                                            (tptr tvoid)) tint) tbool)))
                                  (Sifthenelse (Etempvar _t'15 tint)
                                    (Ssequence
                                      (Ssequence
                                        (Sifthenelse (Ebinop One
                                                       (Etempvar _upperWall (tptr (Tstruct _Surface noattr)))
                                                       (Ecast
                                                         (Econst_int (Int.repr 0) tint)
                                                         (tptr tvoid)) tint)
                                          (Sset _t'12
                                            (Ecast
                                              (Etempvar _upperWall (tptr (Tstruct _Surface noattr)))
                                              (tptr (Tstruct _Surface noattr))))
                                          (Sset _t'12
                                            (Ecast
                                              (Etempvar _lowerWall (tptr (Tstruct _Surface noattr)))
                                              (tptr (Tstruct _Surface noattr)))))
                                        (Sassign
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _wall
                                            (tptr (Tstruct _Surface noattr)))
                                          (Etempvar _t'12 (tptr (Tstruct _Surface noattr)))))
                                      (Ssequence
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'20
                                              (Efield
                                                (Ederef
                                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                  (Tstruct _MarioState noattr))
                                                _wall
                                                (tptr (Tstruct _Surface noattr))))
                                            (Ssequence
                                              (Sset _t'21
                                                (Efield
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _t'20 (tptr (Tstruct _Surface noattr)))
                                                      (Tstruct _Surface noattr))
                                                    _normal
                                                    (Tstruct __670 noattr))
                                                  _z tfloat))
                                              (Ssequence
                                                (Sset _t'22
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                      (Tstruct _MarioState noattr))
                                                    _wall
                                                    (tptr (Tstruct _Surface noattr))))
                                                (Ssequence
                                                  (Sset _t'23
                                                    (Efield
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _t'22 (tptr (Tstruct _Surface noattr)))
                                                          (Tstruct _Surface noattr))
                                                        _normal
                                                        (Tstruct __670 noattr))
                                                      _x tfloat))
                                                  (Scall (Some _t'13)
                                                    (Evar _atan2s (Tfunction
                                                                    (tfloat ::
                                                                    tfloat ::
                                                                    nil)
                                                                    tshort
                                                                    cc_default))
                                                    ((Etempvar _t'21 tfloat) ::
                                                     (Etempvar _t'23 tfloat) ::
                                                     nil))))))
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
                                                  (tptr tshort)) tshort))
                                            (Sset _wallDYaw
                                              (Ecast
                                                (Ebinop Osub
                                                  (Etempvar _t'13 tshort)
                                                  (Etempvar _t'19 tshort)
                                                  tint) tshort))))
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'17
                                              (Efield
                                                (Ederef
                                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                  (Tstruct _MarioState noattr))
                                                _wall
                                                (tptr (Tstruct _Surface noattr))))
                                            (Ssequence
                                              (Sset _t'18
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _t'17 (tptr (Tstruct _Surface noattr)))
                                                    (Tstruct _Surface noattr))
                                                  _type tshort))
                                              (Sifthenelse (Ebinop Oeq
                                                             (Etempvar _t'18 tshort)
                                                             (Econst_int (Int.repr 1) tint)
                                                             tint)
                                                (Sreturn (Some (Econst_int (Int.repr 6) tint)))
                                                Sskip)))
                                          (Ssequence
                                            (Sifthenelse (Ebinop Olt
                                                           (Etempvar _wallDYaw tshort)
                                                           (Eunop Oneg
                                                             (Econst_int (Int.repr 24576) tint)
                                                             tint) tint)
                                              (Sset _t'14
                                                (Econst_int (Int.repr 1) tint))
                                              (Sset _t'14
                                                (Ecast
                                                  (Ebinop Ogt
                                                    (Etempvar _wallDYaw tshort)
                                                    (Econst_int (Int.repr 24576) tint)
                                                    tint) tbool)))
                                            (Sifthenelse (Etempvar _t'14 tint)
                                              (Ssequence
                                                (Ssequence
                                                  (Sset _t'16
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                        (Tstruct _MarioState noattr))
                                                      _flags tuint))
                                                  (Sassign
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                        (Tstruct _MarioState noattr))
                                                      _flags tuint)
                                                    (Ebinop Oor
                                                      (Etempvar _t'16 tuint)
                                                      (Econst_int (Int.repr 1073741824) tint)
                                                      tuint)))
                                                (Sreturn (Some (Econst_int (Int.repr 2) tint))))
                                              Sskip)))))
                                    Sskip))
                                (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))))))))))
|}.

Definition f_apply_twirl_gravity := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_terminalVelocity, tfloat) :: (_heaviness, tfloat) ::
               (_t'4, tshort) :: (_t'3, tshort) :: (_t'2, tfloat) ::
               (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _heaviness
    (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat))
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _angleVel (tarray tshort 3))
            (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
      (Sifthenelse (Ebinop Ogt (Etempvar _t'3 tshort)
                     (Econst_int (Int.repr 1024) tint) tint)
        (Ssequence
          (Sset _t'4
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _angleVel
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort))
          (Sset _heaviness
            (Ebinop Odiv
              (Econst_single (Float32.of_bits (Int.repr 1149239296)) tfloat)
              (Etempvar _t'4 tshort) tfloat)))
        Sskip))
    (Ssequence
      (Sset _terminalVelocity
        (Ebinop Omul
          (Eunop Oneg
            (Econst_single (Float32.of_bits (Int.repr 1117126656)) tfloat)
            tfloat) (Etempvar _heaviness tfloat) tfloat))
      (Ssequence
        (Ssequence
          (Sset _t'2
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
            (Ebinop Osub (Etempvar _t'2 tfloat)
              (Ebinop Omul
                (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                (Etempvar _heaviness tfloat) tfloat) tfloat)))
        (Ssequence
          (Sset _t'1
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
          (Sifthenelse (Ebinop Olt (Etempvar _t'1 tfloat)
                         (Etempvar _terminalVelocity tfloat) tint)
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                  (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
              (Etempvar _terminalVelocity tfloat))
            Sskip))))))
|}.

Definition f_should_strengthen_gravity_for_jump_ascent := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'6, tuint) :: (_t'5, tuint) ::
               (_t'4, tfloat) :: (_t'3, tushort) :: (_t'2, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sifthenelse (Eunop Onotbool
                   (Ebinop Oand (Etempvar _t'6 tuint)
                     (Econst_int (Int.repr 256) tint) tuint) tint)
      (Sreturn (Some (Econst_int (Int.repr 0) tint)))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _action tuint))
      (Sifthenelse (Ebinop Oand (Etempvar _t'5 tuint)
                     (Ebinop Oor
                       (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 12) tint) tint)
                       (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 17) tint) tint) tint) tuint)
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))
        Sskip))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Eunop Onotbool
                         (Ebinop Oand (Etempvar _t'3 tushort)
                           (Econst_int (Int.repr 128) tint) tint) tint)
            (Ssequence
              (Sset _t'4
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                    (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
              (Sset _t'1
                (Ecast
                  (Ebinop Ogt (Etempvar _t'4 tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1101004800)) tfloat)
                    tint) tbool)))
            (Sset _t'1 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'1 tint)
          (Ssequence
            (Sset _t'2
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _action tuint))
            (Sreturn (Some (Ebinop One
                             (Ebinop Oand (Etempvar _t'2 tuint)
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 25) tint) tint) tuint)
                             (Econst_int (Int.repr 0) tint) tint))))
          Sskip))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_apply_gravity := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'8, tint) :: (_t'7, tint) :: (_t'6, tint) ::
               (_t'5, tint) :: (_t'4, tuint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tfloat) :: (_t'39, tfloat) ::
               (_t'38, tuint) :: (_t'37, tfloat) :: (_t'36, tfloat) ::
               (_t'35, tuint) :: (_t'34, tuint) :: (_t'33, tuint) ::
               (_t'32, tfloat) :: (_t'31, tfloat) :: (_t'30, tuint) ::
               (_t'29, tuint) :: (_t'28, tfloat) :: (_t'27, tfloat) ::
               (_t'26, tfloat) :: (_t'25, tfloat) :: (_t'24, tfloat) ::
               (_t'23, tfloat) :: (_t'22, tfloat) :: (_t'21, tfloat) ::
               (_t'20, tfloat) :: (_t'19, tuint) :: (_t'18, tushort) ::
               (_t'17, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'16, tfloat) :: (_t'15, tfloat) :: (_t'14, tfloat) ::
               (_t'13, tfloat) :: (_t'12, tfloat) :: (_t'11, tuint) ::
               (_t'10, tuint) :: (_t'9, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'38
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _action tuint))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'38 tuint)
                   (Econst_int (Int.repr 276826276) tint) tint)
      (Ssequence
        (Sset _t'39
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
              (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
        (Sset _t'8
          (Ecast
            (Ebinop Olt (Etempvar _t'39 tfloat)
              (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) tint)
            tbool)))
      (Sset _t'8 (Econst_int (Int.repr 0) tint))))
  (Sifthenelse (Etempvar _t'8 tint)
    (Scall None
      (Evar _apply_twirl_gravity (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Ssequence
      (Sset _t'9
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _action tuint))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tuint)
                     (Econst_int (Int.repr 8915096) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'37
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
              (Ebinop Osub (Etempvar _t'37 tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                tfloat)))
          (Ssequence
            (Sset _t'36
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                  (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
            (Sifthenelse (Ebinop Olt (Etempvar _t'36 tfloat)
                           (Eunop Oneg
                             (Econst_single (Float32.of_bits (Int.repr 1117126656)) tfloat)
                             tfloat) tint)
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                    (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
                (Eunop Oneg
                  (Econst_single (Float32.of_bits (Int.repr 1117126656)) tfloat)
                  tfloat))
              Sskip)))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'34
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _action tuint))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'34 tuint)
                             (Econst_int (Int.repr 50333832) tint) tint)
                (Sset _t'6 (Econst_int (Int.repr 1) tint))
                (Ssequence
                  (Sset _t'35
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _action tuint))
                  (Sset _t'6
                    (Ecast
                      (Ebinop Oeq (Etempvar _t'35 tuint)
                        (Econst_int (Int.repr 25168042) tint) tint) tbool)))))
            (Sifthenelse (Etempvar _t'6 tint)
              (Sset _t'7 (Econst_int (Int.repr 1) tint))
              (Ssequence
                (Sset _t'33
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _action tuint))
                (Sset _t'7
                  (Ecast
                    (Ebinop Oeq (Etempvar _t'33 tuint)
                      (Econst_int (Int.repr 5429) tint) tint) tbool)))))
          (Sifthenelse (Etempvar _t'7 tint)
            (Ssequence
              (Ssequence
                (Sset _t'32
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
                  (Ebinop Osub (Etempvar _t'32 tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                    tfloat)))
              (Ssequence
                (Sset _t'31
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _vel
                        (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tfloat)) tfloat))
                (Sifthenelse (Ebinop Olt (Etempvar _t'31 tfloat)
                               (Eunop Oneg
                                 (Econst_single (Float32.of_bits (Int.repr 1117126656)) tfloat)
                                 tfloat) tint)
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _vel
                          (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tfloat)) tfloat)
                    (Eunop Oneg
                      (Econst_single (Float32.of_bits (Int.repr 1117126656)) tfloat)
                      tfloat))
                  Sskip)))
            (Ssequence
              (Ssequence
                (Sset _t'29
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _action tuint))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'29 tuint)
                               (Econst_int (Int.repr 16910519) tint) tint)
                  (Sset _t'5 (Econst_int (Int.repr 1) tint))
                  (Ssequence
                    (Sset _t'30
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _action tuint))
                    (Sset _t'5
                      (Ecast
                        (Ebinop Oeq (Etempvar _t'30 tuint)
                          (Econst_int (Int.repr 6404) tint) tint) tbool)))))
              (Sifthenelse (Etempvar _t'5 tint)
                (Ssequence
                  (Ssequence
                    (Sset _t'28
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
                      (Ebinop Osub (Etempvar _t'28 tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1078774989)) tfloat)
                        tfloat)))
                  (Ssequence
                    (Sset _t'27
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _vel
                            (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tfloat)) tfloat))
                    (Sifthenelse (Ebinop Olt (Etempvar _t'27 tfloat)
                                   (Eunop Oneg
                                     (Econst_single (Float32.of_bits (Int.repr 1115815936)) tfloat)
                                     tfloat) tint)
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
                        (Eunop Oneg
                          (Econst_single (Float32.of_bits (Int.repr 1115815936)) tfloat)
                          tfloat))
                      Sskip)))
                (Ssequence
                  (Sset _t'10
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _action tuint))
                  (Sifthenelse (Ebinop Oeq (Etempvar _t'10 tuint)
                                 (Econst_int (Int.repr 16910520) tint) tint)
                    (Ssequence
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
                        (Ssequence
                          (Sset _t'26
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr))
                              _gettingBlownGravity tfloat))
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
                            (Ebinop Osub (Etempvar _t'25 tfloat)
                              (Etempvar _t'26 tfloat) tfloat))))
                      (Ssequence
                        (Sset _t'24
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _vel
                                (tarray tfloat 3))
                              (Econst_int (Int.repr 1) tint) (tptr tfloat))
                            tfloat))
                        (Sifthenelse (Ebinop Olt (Etempvar _t'24 tfloat)
                                       (Eunop Oneg
                                         (Econst_single (Float32.of_bits (Int.repr 1117126656)) tfloat)
                                         tfloat) tint)
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
                            (Eunop Oneg
                              (Econst_single (Float32.of_bits (Int.repr 1117126656)) tfloat)
                              tfloat))
                          Sskip)))
                    (Ssequence
                      (Scall (Some _t'4)
                        (Evar _should_strengthen_gravity_for_jump_ascent 
                        (Tfunction
                          ((tptr (Tstruct _MarioState noattr)) :: nil) tuint
                          cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      (Sifthenelse (Etempvar _t'4 tuint)
                        (Ssequence
                          (Sset _t'23
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
                            (Ebinop Odiv (Etempvar _t'23 tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                              tfloat)))
                        (Ssequence
                          (Sset _t'11
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _action tuint))
                          (Sifthenelse (Ebinop Oand (Etempvar _t'11 tuint)
                                         (Ebinop Oshl
                                           (Econst_int (Int.repr 1) tint)
                                           (Econst_int (Int.repr 14) tint)
                                           tint) tuint)
                            (Ssequence
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
                                  (Ebinop Osub (Etempvar _t'22 tfloat)
                                    (Econst_single (Float32.of_bits (Int.repr 1070386381)) tfloat)
                                    tfloat)))
                              (Ssequence
                                (Sset _t'21
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
                                               (Etempvar _t'21 tfloat)
                                               (Eunop Oneg
                                                 (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                                                 tfloat) tint)
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
                                    (Eunop Oneg
                                      (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                                      tfloat))
                                  Sskip)))
                            (Ssequence
                              (Ssequence
                                (Ssequence
                                  (Sset _t'19
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr)) _flags
                                      tuint))
                                  (Sifthenelse (Ebinop Oand
                                                 (Etempvar _t'19 tuint)
                                                 (Econst_int (Int.repr 8) tint)
                                                 tuint)
                                    (Ssequence
                                      (Sset _t'20
                                        (Ederef
                                          (Ebinop Oadd
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _vel (tarray tfloat 3))
                                            (Econst_int (Int.repr 1) tint)
                                            (tptr tfloat)) tfloat))
                                      (Sset _t'2
                                        (Ecast
                                          (Ebinop Olt (Etempvar _t'20 tfloat)
                                            (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                            tint) tbool)))
                                    (Sset _t'2
                                      (Econst_int (Int.repr 0) tint))))
                                (Sifthenelse (Etempvar _t'2 tint)
                                  (Ssequence
                                    (Sset _t'18
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _input tushort))
                                    (Sset _t'3
                                      (Ecast
                                        (Ebinop Oand (Etempvar _t'18 tushort)
                                          (Econst_int (Int.repr 128) tint)
                                          tint) tbool)))
                                  (Sset _t'3 (Econst_int (Int.repr 0) tint))))
                              (Sifthenelse (Etempvar _t'3 tint)
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'17
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _marioBodyState
                                        (tptr (Tstruct _MarioBodyState noattr))))
                                    (Sassign
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'17 (tptr (Tstruct _MarioBodyState noattr)))
                                          (Tstruct _MarioBodyState noattr))
                                        _wingFlutter tschar)
                                      (Econst_int (Int.repr 1) tint)))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'16
                                        (Ederef
                                          (Ebinop Oadd
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _vel (tarray tfloat 3))
                                            (Econst_int (Int.repr 1) tint)
                                            (tptr tfloat)) tfloat))
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
                                        (Ebinop Osub (Etempvar _t'16 tfloat)
                                          (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                                          tfloat)))
                                    (Ssequence
                                      (Sset _t'14
                                        (Ederef
                                          (Ebinop Oadd
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _vel (tarray tfloat 3))
                                            (Econst_int (Int.repr 1) tint)
                                            (tptr tfloat)) tfloat))
                                      (Sifthenelse (Ebinop Olt
                                                     (Etempvar _t'14 tfloat)
                                                     (Eunop Oneg
                                                       (Econst_single (Float32.of_bits (Int.repr 1108738048)) tfloat)
                                                       tfloat) tint)
                                        (Ssequence
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'15
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                        (Tstruct _MarioState noattr))
                                                      _vel (tarray tfloat 3))
                                                    (Econst_int (Int.repr 1) tint)
                                                    (tptr tfloat)) tfloat))
                                              (Sset _t'1
                                                (Ecast
                                                  (Ebinop Oadd
                                                    (Etempvar _t'15 tfloat)
                                                    (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                                    tfloat) tfloat)))
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
                                              (Etempvar _t'1 tfloat)))
                                          (Sifthenelse (Ebinop Ogt
                                                         (Etempvar _t'1 tfloat)
                                                         (Eunop Oneg
                                                           (Econst_single (Float32.of_bits (Int.repr 1108738048)) tfloat)
                                                           tfloat) tint)
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
                                              (Eunop Oneg
                                                (Econst_single (Float32.of_bits (Int.repr 1108738048)) tfloat)
                                                tfloat))
                                            Sskip))
                                        Sskip))))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'13
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _vel (tarray tfloat 3))
                                          (Econst_int (Int.repr 1) tint)
                                          (tptr tfloat)) tfloat))
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
                                      (Ebinop Osub (Etempvar _t'13 tfloat)
                                        (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                        tfloat)))
                                  (Ssequence
                                    (Sset _t'12
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _vel (tarray tfloat 3))
                                          (Econst_int (Int.repr 1) tint)
                                          (tptr tfloat)) tfloat))
                                    (Sifthenelse (Ebinop Olt
                                                   (Etempvar _t'12 tfloat)
                                                   (Eunop Oneg
                                                     (Econst_single (Float32.of_bits (Int.repr 1117126656)) tfloat)
                                                     tfloat) tint)
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
                                        (Eunop Oneg
                                          (Econst_single (Float32.of_bits (Int.repr 1117126656)) tfloat)
                                          tfloat))
                                      Sskip)))))))))))))))))))
|}.

Definition f_apply_vertical_wind := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_maxVelY, tfloat) :: (_offsetY, tfloat) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tfloat) :: (_t'9, tfloat) ::
               (_t'8, tshort) :: (_t'7, (tptr (Tstruct _Surface noattr))) ::
               (_t'6, tfloat) :: (_t'5, tfloat) :: (_t'4, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'4
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _action tuint))
  (Sifthenelse (Ebinop One (Etempvar _t'4 tuint)
                 (Econst_int (Int.repr 8390825) tint) tint)
    (Ssequence
      (Ssequence
        (Sset _t'9
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
        (Sset _offsetY
          (Ebinop Osub (Etempvar _t'9 tfloat)
            (Eunop Oneg
              (Econst_single (Float32.of_bits (Int.repr 1153138688)) tfloat)
              tfloat) tfloat)))
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
                  (Ederef (Etempvar _t'7 (tptr (Tstruct _Surface noattr)))
                    (Tstruct _Surface noattr)) _type tshort))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'8 tshort)
                             (Econst_int (Int.repr 56) tint) tint)
                (Sset _t'2
                  (Ecast
                    (Ebinop Olt
                      (Eunop Oneg
                        (Econst_single (Float32.of_bits (Int.repr 1161527296)) tfloat)
                        tfloat) (Etempvar _offsetY tfloat) tint) tbool))
                (Sset _t'2 (Econst_int (Int.repr 0) tint)))))
          (Sifthenelse (Etempvar _t'2 tint)
            (Sset _t'3
              (Ecast
                (Ebinop Olt (Etempvar _offsetY tfloat)
                  (Econst_single (Float32.of_bits (Int.repr 1157234688)) tfloat)
                  tint) tbool))
            (Sset _t'3 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'3 tint)
          (Ssequence
            (Sifthenelse (Ebinop Oge (Etempvar _offsetY tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                           tint)
              (Sset _maxVelY
                (Ebinop Odiv
                  (Econst_single (Float32.of_bits (Int.repr 1176256512)) tfloat)
                  (Ebinop Oadd (Etempvar _offsetY tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1128792064)) tfloat)
                    tfloat) tfloat))
              (Sset _maxVelY
                (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat)))
            (Ssequence
              (Sset _t'5
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                    (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
              (Sifthenelse (Ebinop Olt (Etempvar _t'5 tfloat)
                             (Etempvar _maxVelY tfloat) tint)
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'6
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
                          (Ebinop Oadd (Etempvar _t'6 tfloat)
                            (Ebinop Odiv (Etempvar _maxVelY tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat)
                              tfloat) tfloat) tfloat)))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _vel
                            (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tfloat)) tfloat) (Etempvar _t'1 tfloat)))
                  (Sifthenelse (Ebinop Ogt (Etempvar _t'1 tfloat)
                                 (Etempvar _maxVelY tfloat) tint)
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _vel
                            (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tfloat)) tfloat) (Etempvar _maxVelY tfloat))
                    Sskip))
                Sskip)))
          Sskip)))
    Sskip))
|}.

Definition f_perform_air_step := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_stepArg, tuint) :: nil);
  fn_vars := ((_intendedPos, (tarray tfloat 3)) :: nil);
  fn_temps := ((_i, tint) :: (_quarterStepResult, tint) ::
               (_stepResult, tint) :: (_t'5, tuint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'17, tfloat) :: (_t'16, tfloat) :: (_t'15, tfloat) ::
               (_t'14, tfloat) :: (_t'13, tfloat) :: (_t'12, tfloat) ::
               (_t'11, tfloat) :: (_t'10, tfloat) :: (_t'9, tuint) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tshort) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _stepResult (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sassign
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _wall
        (tptr (Tstruct _Surface noattr)))
      (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
    (Ssequence
      (Ssequence
        (Sset _i (Econst_int (Int.repr 0) tint))
        (Sloop
          (Ssequence
            (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                           (Econst_int (Int.repr 4) tint) tint)
              Sskip
              Sbreak)
            (Ssequence
              (Ssequence
                (Sset _t'16
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _pos
                        (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tfloat)) tfloat))
                (Ssequence
                  (Sset _t'17
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _vel
                          (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tfloat)) tfloat))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd (Evar _intendedPos (tarray tfloat 3))
                        (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
                    (Ebinop Oadd (Etempvar _t'16 tfloat)
                      (Ebinop Odiv (Etempvar _t'17 tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                        tfloat) tfloat))))
              (Ssequence
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
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _vel
                            (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tfloat)) tfloat))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd (Evar _intendedPos (tarray tfloat 3))
                          (Econst_int (Int.repr 1) tint) (tptr tfloat))
                        tfloat)
                      (Ebinop Oadd (Etempvar _t'14 tfloat)
                        (Ebinop Odiv (Etempvar _t'15 tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                          tfloat) tfloat))))
                (Ssequence
                  (Ssequence
                    (Sset _t'12
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _pos
                            (tarray tfloat 3)) (Econst_int (Int.repr 2) tint)
                          (tptr tfloat)) tfloat))
                    (Ssequence
                      (Sset _t'13
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _vel
                              (tarray tfloat 3))
                            (Econst_int (Int.repr 2) tint) (tptr tfloat))
                          tfloat))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd (Evar _intendedPos (tarray tfloat 3))
                            (Econst_int (Int.repr 2) tint) (tptr tfloat))
                          tfloat)
                        (Ebinop Oadd (Etempvar _t'12 tfloat)
                          (Ebinop Odiv (Etempvar _t'13 tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                            tfloat) tfloat))))
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'1)
                        (Evar _perform_air_quarter_step (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           (tptr tfloat) ::
                                                           tuint :: nil) tint
                                                          cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Evar _intendedPos (tarray tfloat 3)) ::
                         (Etempvar _stepArg tuint) :: nil))
                      (Sset _quarterStepResult (Etempvar _t'1 tint)))
                    (Ssequence
                      (Sifthenelse (Ebinop One
                                     (Etempvar _quarterStepResult tint)
                                     (Econst_int (Int.repr 0) tint) tint)
                        (Sset _stepResult (Etempvar _quarterStepResult tint))
                        Sskip)
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sifthenelse (Ebinop Oeq
                                           (Etempvar _quarterStepResult tint)
                                           (Econst_int (Int.repr 1) tint)
                                           tint)
                              (Sset _t'2 (Econst_int (Int.repr 1) tint))
                              (Sset _t'2
                                (Ecast
                                  (Ebinop Oeq
                                    (Etempvar _quarterStepResult tint)
                                    (Econst_int (Int.repr 3) tint) tint)
                                  tbool)))
                            (Sifthenelse (Etempvar _t'2 tint)
                              (Sset _t'3 (Econst_int (Int.repr 1) tint))
                              (Sset _t'3
                                (Ecast
                                  (Ebinop Oeq
                                    (Etempvar _quarterStepResult tint)
                                    (Econst_int (Int.repr 4) tint) tint)
                                  tbool))))
                          (Sifthenelse (Etempvar _t'3 tint)
                            (Sset _t'4 (Econst_int (Int.repr 1) tint))
                            (Sset _t'4
                              (Ecast
                                (Ebinop Oeq
                                  (Etempvar _quarterStepResult tint)
                                  (Econst_int (Int.repr 6) tint) tint) tbool))))
                        (Sifthenelse (Etempvar _t'4 tint) Sbreak Sskip))))))))
          (Sset _i
            (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint)
              tint))))
      (Ssequence
        (Ssequence
          (Sset _t'10
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
          (Sifthenelse (Ebinop Oge (Etempvar _t'10 tfloat)
                         (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                         tint)
            (Ssequence
              (Sset _t'11
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                    (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _peakHeight tfloat)
                (Etempvar _t'11 tfloat)))
            Sskip))
        (Ssequence
          (Ssequence
            (Scall (Some _t'5)
              (Evar _mario_get_terrain_sound_addend (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       nil) tuint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _terrainSoundAddend tuint)
              (Etempvar _t'5 tuint)))
          (Ssequence
            (Ssequence
              (Sset _t'9
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _action tuint))
              (Sifthenelse (Ebinop One (Etempvar _t'9 tuint)
                             (Econst_int (Int.repr 277350553) tint) tint)
                (Scall None
                  (Evar _apply_gravity (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          nil) tvoid cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                Sskip))
            (Ssequence
              (Scall None
                (Evar _apply_vertical_wind (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tvoid cc_default))
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
                    (Evar _vec3f_copy (Tfunction
                                        ((tptr tfloat) :: (tptr tfloat) ::
                                         nil) (tptr tvoid) cc_default))
                    ((Efield
                       (Efield
                         (Efield
                           (Ederef
                             (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
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
                                 (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                                 (Tstruct _Object noattr)) _header
                               (Tstruct _ObjectNode noattr)) _gfx
                             (Tstruct _GraphNodeObject noattr)) _angle
                           (tarray tshort 3)) ::
                         (Econst_int (Int.repr 0) tint) ::
                         (Etempvar _t'7 tshort) ::
                         (Econst_int (Int.repr 0) tint) :: nil))))
                  (Sreturn (Some (Etempvar _stepResult tint))))))))))))
|}.

Definition f_set_vel_from_pitch_and_yaw := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'13, tfloat) :: (_t'12, tshort) :: (_t'11, tfloat) ::
               (_t'10, tshort) :: (_t'9, tfloat) :: (_t'8, tfloat) ::
               (_t'7, tshort) :: (_t'6, tfloat) :: (_t'5, tfloat) ::
               (_t'4, tshort) :: (_t'3, tfloat) :: (_t'2, tshort) ::
               (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _forwardVel tfloat))
    (Ssequence
      (Sset _t'10
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
            (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
      (Ssequence
        (Sset _t'11
          (Ederef
            (Ebinop Oadd
              (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                (Econst_int (Int.repr 1024) tint) (tptr tfloat))
              (Ebinop Oshr (Ecast (Etempvar _t'10 tshort) tushort)
                (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
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
                      (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                  (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
              (Ebinop Omul
                (Ebinop Omul (Etempvar _t'9 tfloat) (Etempvar _t'11 tfloat)
                  tfloat) (Etempvar _t'13 tfloat) tfloat)))))))
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
                  (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
              (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
        (Ssequence
          (Sset _t'8
            (Ederef
              (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                (Ebinop Oshr (Ecast (Etempvar _t'7 tshort) tushort)
                  (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
            (Ebinop Omul (Etempvar _t'6 tfloat) (Etempvar _t'8 tfloat)
              tfloat)))))
    (Ssequence
      (Sset _t'1
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _forwardVel tfloat))
      (Ssequence
        (Sset _t'2
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
              (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
        (Ssequence
          (Sset _t'3
            (Ederef
              (Ebinop Oadd
                (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                  (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                (Ebinop Oshr (Ecast (Etempvar _t'2 tshort) tushort)
                  (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
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
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                    (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat)
                (Ebinop Omul
                  (Ebinop Omul (Etempvar _t'1 tfloat) (Etempvar _t'3 tfloat)
                    tfloat) (Etempvar _t'5 tfloat) tfloat)))))))))
|}.

Definition f_set_vel_from_yaw := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tfloat) :: (_t'1, tfloat) :: (_t'8, tfloat) ::
               (_t'7, tshort) :: (_t'6, tfloat) :: (_t'5, tfloat) ::
               (_t'4, tshort) :: (_t'3, tfloat) :: nil);
  fn_body :=
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
    (Sassign
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
          (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
      (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
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
 Composite _BullyCollisionData Struct
   (Member_plain _conversionRatio tfloat :: Member_plain _radius tfloat ::
    Member_plain _posX tfloat :: Member_plain _posZ tfloat ::
    Member_plain _velX tfloat :: Member_plain _velZ tfloat :: nil)
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
 (_atan2s,
   Gfun(External (EF_external "atan2s"
                   (mksignature (AST.Xsingle :: AST.Xsingle :: nil)
                     AST.Xint16signed cc_default)) (tfloat :: tfloat :: nil)
     tshort cc_default)) ::
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
 (_mario_set_forward_vel,
   Gfun(External (EF_external "mario_set_forward_vel"
                   (mksignature (AST.Xptr :: AST.Xsingle :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tfloat :: nil) tvoid
     cc_default)) ::
 (_mario_get_terrain_sound_addend,
   Gfun(External (EF_external "mario_get_terrain_sound_addend"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tuint cc_default)) ::
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
 (_play_sound,
   Gfun(External (EF_external "play_sound"
                   (mksignature (AST.Xint :: AST.Xptr :: nil) AST.Xvoid
                     cc_default)) (tint :: (tptr tfloat) :: nil) tvoid
     cc_default)) :: (_gGlobalTimer, Gvar v_gGlobalTimer) ::
 (_sMovingSandSpeeds, Gvar v_sMovingSandSpeeds) ::
 (_gWaterSurfacePseudoFloor, Gvar v_gWaterSurfacePseudoFloor) ::
 (_get_additive_y_vel_for_jumps, Gfun(Internal f_get_additive_y_vel_for_jumps)) ::
 (_stub_mario_step_1, Gfun(Internal f_stub_mario_step_1)) ::
 (_stub_mario_step_2, Gfun(Internal f_stub_mario_step_2)) ::
 (_transfer_bully_speed, Gfun(Internal f_transfer_bully_speed)) ::
 (_init_bully_collision_data, Gfun(Internal f_init_bully_collision_data)) ::
 (_mario_bonk_reflection, Gfun(Internal f_mario_bonk_reflection)) ::
 (_mario_update_quicksand, Gfun(Internal f_mario_update_quicksand)) ::
 (_mario_push_off_steep_floor, Gfun(Internal f_mario_push_off_steep_floor)) ::
 (_mario_update_moving_sand, Gfun(Internal f_mario_update_moving_sand)) ::
 (_mario_update_windy_ground, Gfun(Internal f_mario_update_windy_ground)) ::
 (_stop_and_set_height_to_floor, Gfun(Internal f_stop_and_set_height_to_floor)) ::
 (_stationary_ground_step, Gfun(Internal f_stationary_ground_step)) ::
 (_perform_ground_quarter_step, Gfun(Internal f_perform_ground_quarter_step)) ::
 (_perform_ground_step, Gfun(Internal f_perform_ground_step)) ::
 (_check_ledge_grab, Gfun(Internal f_check_ledge_grab)) ::
 (_perform_air_quarter_step, Gfun(Internal f_perform_air_quarter_step)) ::
 (_apply_twirl_gravity, Gfun(Internal f_apply_twirl_gravity)) ::
 (_should_strengthen_gravity_for_jump_ascent, Gfun(Internal f_should_strengthen_gravity_for_jump_ascent)) ::
 (_apply_gravity, Gfun(Internal f_apply_gravity)) ::
 (_apply_vertical_wind, Gfun(Internal f_apply_vertical_wind)) ::
 (_perform_air_step, Gfun(Internal f_perform_air_step)) ::
 (_set_vel_from_pitch_and_yaw, Gfun(Internal f_set_vel_from_pitch_and_yaw)) ::
 (_set_vel_from_yaw, Gfun(Internal f_set_vel_from_yaw)) :: nil).

Definition public_idents : list ident :=
(_set_vel_from_yaw :: _set_vel_from_pitch_and_yaw :: _perform_air_step ::
 _apply_vertical_wind :: _apply_gravity ::
 _should_strengthen_gravity_for_jump_ascent :: _apply_twirl_gravity ::
 _perform_air_quarter_step :: _check_ledge_grab :: _perform_ground_step ::
 _stationary_ground_step :: _stop_and_set_height_to_floor ::
 _mario_update_windy_ground :: _mario_update_moving_sand ::
 _mario_push_off_steep_floor :: _mario_update_quicksand ::
 _mario_bonk_reflection :: _init_bully_collision_data ::
 _transfer_bully_speed :: _stub_mario_step_2 :: _stub_mario_step_1 ::
 _get_additive_y_vel_for_jumps :: _gWaterSurfacePseudoFloor ::
 _gGlobalTimer :: _play_sound :: _drop_and_set_mario_action ::
 _set_mario_action :: _update_mario_sound_and_camera :: _vec3f_find_ceil ::
 _resolve_and_return_wall_collisions :: _mario_get_terrain_sound_addend ::
 _mario_set_forward_vel :: _find_water_level :: _find_floor :: _atan2s ::
 _vec3s_set :: _vec3f_set :: _vec3f_copy :: _gSineTable ::
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


