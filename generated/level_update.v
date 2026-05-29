(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Produced by: pipeline/clightgen.sh
   From source: vendor/sm64/src/game/level_update.c
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
  Definition source_file := "vendor/sm64/src/game/level_update.c".
  Definition normalized := true.
End Info.

Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _Area : ident := $"Area".
Definition _Camera : ident := $"Camera".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _Controller : ident := $"Controller".
Definition _CreditsEntry : ident := $"CreditsEntry".
Definition _D_80339ECA : ident := $"D_80339ECA".
Definition _D_80339EE0 : ident := $"D_80339EE0".
Definition _DemoInput : ident := $"DemoInput".
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
Definition _WarpDest : ident := $"WarpDest".
Definition _WarpNode : ident := $"WarpNode".
Definition _WarpTransition : ident := $"WarpTransition".
Definition _WarpTransitionData : ident := $"WarpTransitionData".
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
Definition ___stringlit_10 : ident := $"__stringlit_10".
Definition ___stringlit_11 : ident := $"__stringlit_11".
Definition ___stringlit_12 : ident := $"__stringlit_12".
Definition ___stringlit_13 : ident := $"__stringlit_13".
Definition ___stringlit_14 : ident := $"__stringlit_14".
Definition ___stringlit_15 : ident := $"__stringlit_15".
Definition ___stringlit_16 : ident := $"__stringlit_16".
Definition ___stringlit_17 : ident := $"__stringlit_17".
Definition ___stringlit_18 : ident := $"__stringlit_18".
Definition ___stringlit_19 : ident := $"__stringlit_19".
Definition ___stringlit_2 : ident := $"__stringlit_2".
Definition ___stringlit_20 : ident := $"__stringlit_20".
Definition ___stringlit_21 : ident := $"__stringlit_21".
Definition ___stringlit_22 : ident := $"__stringlit_22".
Definition ___stringlit_23 : ident := $"__stringlit_23".
Definition ___stringlit_24 : ident := $"__stringlit_24".
Definition ___stringlit_25 : ident := $"__stringlit_25".
Definition ___stringlit_26 : ident := $"__stringlit_26".
Definition ___stringlit_27 : ident := $"__stringlit_27".
Definition ___stringlit_28 : ident := $"__stringlit_28".
Definition ___stringlit_29 : ident := $"__stringlit_29".
Definition ___stringlit_3 : ident := $"__stringlit_3".
Definition ___stringlit_30 : ident := $"__stringlit_30".
Definition ___stringlit_31 : ident := $"__stringlit_31".
Definition ___stringlit_32 : ident := $"__stringlit_32".
Definition ___stringlit_33 : ident := $"__stringlit_33".
Definition ___stringlit_34 : ident := $"__stringlit_34".
Definition ___stringlit_35 : ident := $"__stringlit_35".
Definition ___stringlit_36 : ident := $"__stringlit_36".
Definition ___stringlit_37 : ident := $"__stringlit_37".
Definition ___stringlit_38 : ident := $"__stringlit_38".
Definition ___stringlit_39 : ident := $"__stringlit_39".
Definition ___stringlit_4 : ident := $"__stringlit_4".
Definition ___stringlit_40 : ident := $"__stringlit_40".
Definition ___stringlit_41 : ident := $"__stringlit_41".
Definition ___stringlit_42 : ident := $"__stringlit_42".
Definition ___stringlit_43 : ident := $"__stringlit_43".
Definition ___stringlit_44 : ident := $"__stringlit_44".
Definition ___stringlit_45 : ident := $"__stringlit_45".
Definition ___stringlit_46 : ident := $"__stringlit_46".
Definition ___stringlit_47 : ident := $"__stringlit_47".
Definition ___stringlit_48 : ident := $"__stringlit_48".
Definition ___stringlit_49 : ident := $"__stringlit_49".
Definition ___stringlit_5 : ident := $"__stringlit_5".
Definition ___stringlit_50 : ident := $"__stringlit_50".
Definition ___stringlit_51 : ident := $"__stringlit_51".
Definition ___stringlit_52 : ident := $"__stringlit_52".
Definition ___stringlit_53 : ident := $"__stringlit_53".
Definition ___stringlit_54 : ident := $"__stringlit_54".
Definition ___stringlit_55 : ident := $"__stringlit_55".
Definition ___stringlit_56 : ident := $"__stringlit_56".
Definition ___stringlit_57 : ident := $"__stringlit_57".
Definition ___stringlit_58 : ident := $"__stringlit_58".
Definition ___stringlit_59 : ident := $"__stringlit_59".
Definition ___stringlit_6 : ident := $"__stringlit_6".
Definition ___stringlit_60 : ident := $"__stringlit_60".
Definition ___stringlit_7 : ident := $"__stringlit_7".
Definition ___stringlit_8 : ident := $"__stringlit_8".
Definition ___stringlit_9 : ident := $"__stringlit_9".
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
Definition _areaIdx : ident := $"areaIdx".
Definition _areaIndex : ident := $"areaIndex".
Definition _area_get_warp_node : ident := $"area_get_warp_node".
Definition _area_update_objects : ident := $"area_update_objects".
Definition _arg : ident := $"arg".
Definition _arg0 : ident := $"arg0".
Definition _arg1 : ident := $"arg1".
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
Definition _basic_update : ident := $"basic_update".
Definition _behavior : ident := $"behavior".
Definition _behaviorArg : ident := $"behaviorArg".
Definition _behaviorScript : ident := $"behaviorScript".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _blue : ident := $"blue".
Definition _bufTarget : ident := $"bufTarget".
Definition _button : ident := $"button".
Definition _buttonDown : ident := $"buttonDown".
Definition _buttonMask : ident := $"buttonMask".
Definition _buttonPressed : ident := $"buttonPressed".
Definition _camera : ident := $"camera".
Definition _cameraAngle : ident := $"cameraAngle".
Definition _cameraEvent : ident := $"cameraEvent".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _capCourseIndex : ident := $"capCourseIndex".
Definition _capState : ident := $"capState".
Definition _capTimer : ident := $"capTimer".
Definition _ceil : ident := $"ceil".
Definition _ceilHeight : ident := $"ceilHeight".
Definition _changeLevel : ident := $"changeLevel".
Definition _change_area : ident := $"change_area".
Definition _check_if_should_set_warp_checkpoint : ident := $"check_if_should_set_warp_checkpoint".
Definition _check_instant_warp : ident := $"check_instant_warp".
Definition _check_warp_checkpoint : ident := $"check_warp_checkpoint".
Definition _children : ident := $"children".
Definition _coinSound : ident := $"coinSound".
Definition _coins : ident := $"coins".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _color : ident := $"color".
Definition _controller : ident := $"controller".
Definition _controllerData : ident := $"controllerData".
Definition _count : ident := $"count".
Definition _create_dialog_box : ident := $"create_dialog_box".
Definition _credits01 : ident := $"credits01".
Definition _credits02 : ident := $"credits02".
Definition _credits03 : ident := $"credits03".
Definition _credits04 : ident := $"credits04".
Definition _credits05 : ident := $"credits05".
Definition _credits06 : ident := $"credits06".
Definition _credits07 : ident := $"credits07".
Definition _credits08 : ident := $"credits08".
Definition _credits09 : ident := $"credits09".
Definition _credits10 : ident := $"credits10".
Definition _credits11 : ident := $"credits11".
Definition _credits12 : ident := $"credits12".
Definition _credits13 : ident := $"credits13".
Definition _credits14 : ident := $"credits14".
Definition _credits15 : ident := $"credits15".
Definition _credits16 : ident := $"credits16".
Definition _credits17 : ident := $"credits17".
Definition _credits18 : ident := $"credits18".
Definition _credits19 : ident := $"credits19".
Definition _credits20 : ident := $"credits20".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _currentAddr : ident := $"currentAddr".
Definition _cutscene : ident := $"cutscene".
Definition _data : ident := $"data".
Definition _defMode : ident := $"defMode".
Definition _destArea : ident := $"destArea".
Definition _destLevel : ident := $"destLevel".
Definition _destNode : ident := $"destNode".
Definition _destWarpNode : ident := $"destWarpNode".
Definition _dialog : ident := $"dialog".
Definition _dialogActive : ident := $"dialogActive".
Definition _dialogID : ident := $"dialogID".
Definition _disable_warp_checkpoint : ident := $"disable_warp_checkpoint".
Definition _displacement : ident := $"displacement".
Definition _dmaTable : ident := $"dmaTable".
Definition _doorStatus : ident := $"doorStatus".
Definition _doubleJumpTimer : ident := $"doubleJumpTimer".
Definition _enable_background_sound : ident := $"enable_background_sound".
Definition _endTexRadius : ident := $"endTexRadius".
Definition _endTexX : ident := $"endTexX".
Definition _endTexY : ident := $"endTexY".
Definition _errnum : ident := $"errnum".
Definition _eyeState : ident := $"eyeState".
Definition _faceAngle : ident := $"faceAngle".
Definition _fadeWarpOpacity : ident := $"fadeWarpOpacity".
Definition _fade_into_special_warp : ident := $"fade_into_special_warp".
Definition _fadeout_music : ident := $"fadeout_music".
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
Definition _framesSinceA : ident := $"framesSinceA".
Definition _framesSinceB : ident := $"framesSinceB".
Definition _gAreas : ident := $"gAreas".
Definition _gCameraMovementFlags : ident := $"gCameraMovementFlags".
Definition _gCurrActNum : ident := $"gCurrActNum".
Definition _gCurrAreaIndex : ident := $"gCurrAreaIndex".
Definition _gCurrCourseNum : ident := $"gCurrCourseNum".
Definition _gCurrCourseStarFlags : ident := $"gCurrCourseStarFlags".
Definition _gCurrCreditsEntry : ident := $"gCurrCreditsEntry".
Definition _gCurrDemoInput : ident := $"gCurrDemoInput".
Definition _gCurrLevelNum : ident := $"gCurrLevelNum".
Definition _gCurrSaveFileNum : ident := $"gCurrSaveFileNum".
Definition _gCurrentArea : ident := $"gCurrentArea".
Definition _gDebugLevelSelect : ident := $"gDebugLevelSelect".
Definition _gGlobalSoundSource : ident := $"gGlobalSoundSource".
Definition _gGlobalTimer : ident := $"gGlobalTimer".
Definition _gHudDisplay : ident := $"gHudDisplay".
Definition _gLevelToCourseNumTable : ident := $"gLevelToCourseNumTable".
Definition _gMarioState : ident := $"gMarioState".
Definition _gMarioStates : ident := $"gMarioStates".
Definition _gMenuOptSelectIndex : ident := $"gMenuOptSelectIndex".
Definition _gNeverEnteredCastle : ident := $"gNeverEnteredCastle".
Definition _gPlayer1Controller : ident := $"gPlayer1Controller".
Definition _gPlayerSpawnInfos : ident := $"gPlayerSpawnInfos".
Definition _gSavedCourseNum : ident := $"gSavedCourseNum".
Definition _gShowProfiler : ident := $"gShowProfiler".
Definition _gSineTable : ident := $"gSineTable".
Definition _gSpecialTripleJump : ident := $"gSpecialTripleJump".
Definition _gWarpTransition : ident := $"gWarpTransition".
Definition _get_current_background_music : ident := $"get_current_background_music".
Definition _get_dialog_id : ident := $"get_dialog_id".
Definition _get_mario_spawn_type : ident := $"get_mario_spawn_type".
Definition _get_painting_warp_node : ident := $"get_painting_warp_node".
Definition _gettingBlownGravity : ident := $"gettingBlownGravity".
Definition _gfx : ident := $"gfx".
Definition _gotAchievement : ident := $"gotAchievement".
Definition _grabPos : ident := $"grabPos".
Definition _green : ident := $"green".
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
Definition _initOrUpdate : ident := $"initOrUpdate".
Definition _init_door_warp : ident := $"init_door_warp".
Definition _init_level : ident := $"init_level".
Definition _init_mario : ident := $"init_mario".
Definition _init_mario_after_warp : ident := $"init_mario_after_warp".
Definition _init_mario_from_save_file : ident := $"init_mario_from_save_file".
Definition _initiate_delayed_warp : ident := $"initiate_delayed_warp".
Definition _initiate_painting_warp : ident := $"initiate_painting_warp".
Definition _initiate_warp : ident := $"initiate_warp".
Definition _input : ident := $"input".
Definition _instantWarps : ident := $"instantWarps".
Definition _intangible : ident := $"intangible".
Definition _intendedMag : ident := $"intendedMag".
Definition _intendedYaw : ident := $"intendedYaw".
Definition _interactObj : ident := $"interactObj".
Definition _invincTimer : ident := $"invincTimer".
Definition _isActive : ident := $"isActive".
Definition _keys : ident := $"keys".
Definition _length : ident := $"length".
Definition _levelNum : ident := $"levelNum".
Definition _level_control_timer : ident := $"level_control_timer".
Definition _level_set_transition : ident := $"level_set_transition".
Definition _level_trigger_warp : ident := $"level_trigger_warp".
Definition _lives : ident := $"lives".
Definition _load_area : ident := $"load_area".
Definition _load_level_init_text : ident := $"load_level_init_text".
Definition _load_mario_area : ident := $"load_mario_area".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _lower_background_noise : ident := $"lower_background_noise".
Definition _lvl_init_from_save_file : ident := $"lvl_init_from_save_file".
Definition _lvl_init_or_update : ident := $"lvl_init_or_update".
Definition _lvl_play_the_end_screen_sound : ident := $"lvl_play_the_end_screen_sound".
Definition _lvl_set_current_level : ident := $"lvl_set_current_level".
Definition _m : ident := $"m".
Definition _macroObjects : ident := $"macroObjects".
Definition _main : ident := $"main".
Definition _marioAction : ident := $"marioAction".
Definition _marioAngle : ident := $"marioAngle".
Definition _marioBodyState : ident := $"marioBodyState".
Definition _marioObj : ident := $"marioObj".
Definition _marioPos : ident := $"marioPos".
Definition _marioSpawnType : ident := $"marioSpawnType".
Definition _mode : ident := $"mode".
Definition _model : ident := $"model".
Definition _modelState : ident := $"modelState".
Definition _musicParam : ident := $"musicParam".
Definition _musicParam2 : ident := $"musicParam2".
Definition _music_changed_through_warp : ident := $"music_changed_through_warp".
Definition _next : ident := $"next".
Definition _nextYaw : ident := $"nextYaw".
Definition _node : ident := $"node".
Definition _nodeId : ident := $"nodeId".
Definition _nop_change_course : ident := $"nop_change_course".
Definition _normal : ident := $"normal".
Definition _numCoins : ident := $"numCoins".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _numHealthWedges : ident := $"numHealthWedges".
Definition _numKeys : ident := $"numKeys".
Definition _numLives : ident := $"numLives".
Definition _numStars : ident := $"numStars".
Definition _numViews : ident := $"numViews".
Definition _object : ident := $"object".
Definition _objectSpawnInfos : ident := $"objectSpawnInfos".
Definition _offset : ident := $"offset".
Definition _originOffset : ident := $"originOffset".
Definition _pWarpNode : ident := $"pWarpNode".
Definition _paintingIndex : ident := $"paintingIndex".
Definition _paintingWarpNodes : ident := $"paintingWarpNodes".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _particleFlags : ident := $"particleFlags".
Definition _pauseRendering : ident := $"pauseRendering".
Definition _peakHeight : ident := $"peakHeight".
Definition _platform : ident := $"platform".
Definition _playMode : ident := $"playMode".
Definition _play_cap_music : ident := $"play_cap_music".
Definition _play_mode_change_area : ident := $"play_mode_change_area".
Definition _play_mode_change_level : ident := $"play_mode_change_level".
Definition _play_mode_frame_advance : ident := $"play_mode_frame_advance".
Definition _play_mode_normal : ident := $"play_mode_normal".
Definition _play_mode_paused : ident := $"play_mode_paused".
Definition _play_music : ident := $"play_music".
Definition _play_painting_eject_sound : ident := $"play_painting_eject_sound".
Definition _play_sound : ident := $"play_sound".
Definition _play_transition : ident := $"play_transition".
Definition _play_transition_after_delay : ident := $"play_transition_after_delay".
Definition _pos : ident := $"pos".
Definition _pressed_pause : ident := $"pressed_pause".
Definition _prev : ident := $"prev".
Definition _prevAction : ident := $"prevAction".
Definition _prevNumStarsForDialog : ident := $"prevNumStarsForDialog".
Definition _prevObj : ident := $"prevObj".
Definition _print_intro_text : ident := $"print_intro_text".
Definition _punchState : ident := $"punchState".
Definition _quicksandDepth : ident := $"quicksandDepth".
Definition _raise_background_noise : ident := $"raise_background_noise".
Definition _rawData : ident := $"rawData".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _red : ident := $"red".
Definition _reset_camera : ident := $"reset_camera".
Definition _reset_dialog_render_state : ident := $"reset_dialog_render_state".
Definition _reset_volume : ident := $"reset_volume".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _result : ident := $"result".
Definition _riddenObj : ident := $"riddenObj".
Definition _room : ident := $"room".
Definition _sCreditsSequence : ident := $"sCreditsSequence".
Definition _sCurrPlayMode : ident := $"sCurrPlayMode".
Definition _sDelayedWarpArg : ident := $"sDelayedWarpArg".
Definition _sDelayedWarpOp : ident := $"sDelayedWarpOp".
Definition _sDelayedWarpTimer : ident := $"sDelayedWarpTimer".
Definition _sSourceWarpNodeId : ident := $"sSourceWarpNodeId".
Definition _sTimerRunning : ident := $"sTimerRunning".
Definition _sTransitionTimer : ident := $"sTransitionTimer".
Definition _sTransitionUpdate : ident := $"sTransitionUpdate".
Definition _sUnusedLevelUpdateBss : ident := $"sUnusedLevelUpdateBss".
Definition _sWarpCheckpointActive : ident := $"sWarpCheckpointActive".
Definition _sWarpDest : ident := $"sWarpDest".
Definition _save_file_exists : ident := $"save_file_exists".
Definition _save_file_get_flags : ident := $"save_file_get_flags".
Definition _save_file_get_star_flags : ident := $"save_file_get_star_flags".
Definition _save_file_get_total_star_count : ident := $"save_file_get_total_star_count".
Definition _save_file_move_cap_to_default_location : ident := $"save_file_move_cap_to_default_location".
Definition _save_file_reload : ident := $"save_file_reload".
Definition _scale : ident := $"scale".
Definition _select_mario_cam_mode : ident := $"select_mario_cam_mode".
Definition _set_background_music : ident := $"set_background_music".
Definition _set_mario_action : ident := $"set_mario_action".
Definition _set_mario_initial_action : ident := $"set_mario_initial_action".
Definition _set_mario_initial_cap_powerup : ident := $"set_mario_initial_cap_powerup".
Definition _set_menu_mode : ident := $"set_menu_mode".
Definition _set_play_mode : ident := $"set_play_mode".
Definition _set_yoshi_as_not_dead : ident := $"set_yoshi_as_not_dead".
Definition _sharedChild : ident := $"sharedChild".
Definition _size : ident := $"size".
Definition _slideVelX : ident := $"slideVelX".
Definition _slideVelZ : ident := $"slideVelZ".
Definition _slideYaw : ident := $"slideYaw".
Definition _sound_banks_disable : ident := $"sound_banks_disable".
Definition _sound_banks_enable : ident := $"sound_banks_enable".
Definition _sp2C : ident := $"sp2C".
Definition _spawnInfo : ident := $"spawnInfo".
Definition _spawnNode : ident := $"spawnNode".
Definition _spawnType : ident := $"spawnType".
Definition _squishTimer : ident := $"squishTimer".
Definition _srcAddr : ident := $"srcAddr".
Definition _stars : ident := $"stars".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
Definition _startTexRadius : ident := $"startTexRadius".
Definition _startTexX : ident := $"startTexX".
Definition _startTexY : ident := $"startTexY".
Definition _status : ident := $"status".
Definition _statusData : ident := $"statusData".
Definition _statusForCamera : ident := $"statusForCamera".
Definition _stickMag : ident := $"stickMag".
Definition _stickX : ident := $"stickX".
Definition _stickY : ident := $"stickY".
Definition _stick_x : ident := $"stick_x".
Definition _stick_y : ident := $"stick_y".
Definition _strength : ident := $"strength".
Definition _stub_level_update_1 : ident := $"stub_level_update_1".
Definition _surfaceRooms : ident := $"surfaceRooms".
Definition _terrainData : ident := $"terrainData".
Definition _terrainSoundAddend : ident := $"terrainSoundAddend".
Definition _terrainType : ident := $"terrainType".
Definition _texTimer : ident := $"texTimer".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _time : ident := $"time".
Definition _timer : ident := $"timer".
Definition _timerOp : ident := $"timerOp".
Definition _torsoAngle : ident := $"torsoAngle".
Definition _transform : ident := $"transform".
Definition _twirlYaw : ident := $"twirlYaw".
Definition _type : ident := $"type".
Definition _unk00 : ident := $"unk00".
Definition _unk02 : ident := $"unk02".
Definition _unk04 : ident := $"unk04".
Definition _unk06 : ident := $"unk06".
Definition _unk08 : ident := $"unk08".
Definition _unk0C : ident := $"unk0C".
Definition _unk15 : ident := $"unk15".
Definition _unk4C : ident := $"unk4C".
Definition _unkB0 : ident := $"unkB0".
Definition _unload_mario_area : ident := $"unload_mario_area".
Definition _unused : ident := $"unused".
Definition _unused1 : ident := $"unused1".
Definition _unused2 : ident := $"unused2".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _unusedVec1 : ident := $"unusedVec1".
Definition _updateFunction : ident := $"updateFunction".
Definition _update_camera : ident := $"update_camera".
Definition _update_hud_values : ident := $"update_hud_values".
Definition _update_level : ident := $"update_level".
Definition _upperY : ident := $"upperY".
Definition _usedObj : ident := $"usedObj".
Definition _val04 : ident := $"val04".
Definition _val4 : ident := $"val4".
Definition _val6 : ident := $"val6".
Definition _val8 : ident := $"val8".
Definition _values : ident := $"values".
Definition _vec3s_set : ident := $"vec3s_set".
Definition _vel : ident := $"vel".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _views : ident := $"views".
Definition _wall : ident := $"wall".
Definition _wallKickTimer : ident := $"wallKickTimer".
Definition _warp : ident := $"warp".
Definition _warpCheckpointActive : ident := $"warpCheckpointActive".
Definition _warpNode : ident := $"warpNode".
Definition _warpNodes : ident := $"warpNodes".
Definition _warpOp : ident := $"warpOp".
Definition _warp_area : ident := $"warp_area".
Definition _warp_camera : ident := $"warp_camera".
Definition _warp_credits : ident := $"warp_credits".
Definition _warp_level : ident := $"warp_level".
Definition _warp_special : ident := $"warp_special".
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
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v___stringlit_6 := {|
  gvar_info := (tarray tschar 19);
  gvar_init := (Init_int8 (Int.repr 89) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 72) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_18 := {|
  gvar_info := (tarray tschar 14);
  gvar_init := (Init_int8 (Int.repr 89) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 67) ::
                Init_int8 (Int.repr 72) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 89) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 77) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 68) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_10 := {|
  gvar_info := (tarray tschar 14);
  gvar_init := (Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 75) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 87) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 77) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_35 := {|
  gvar_info := (tarray tschar 16);
  gvar_init := (Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 77) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_23 := {|
  gvar_info := (tarray tschar 16);
  gvar_init := (Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 85) :: Init_int8 (Int.repr 72) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 75) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_4 := {|
  gvar_info := (tarray tschar 17);
  gvar_init := (Init_int8 (Int.repr 89) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 72) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 75) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 90) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_17 := {|
  gvar_info := (tarray tschar 18);
  gvar_init := (Init_int8 (Int.repr 89) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 72) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 89) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 77) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 77) ::
                Init_int8 (Int.repr 85) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_27 := {|
  gvar_info := (tarray tschar 11);
  gvar_init := (Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 74) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 75) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_47 := {|
  gvar_info := (tarray tschar 11);
  gvar_init := (Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_30 := {|
  gvar_info := (tarray tschar 13);
  gvar_init := (Init_int8 (Int.repr 89) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 74) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 71) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_32 := {|
  gvar_info := (tarray tschar 15);
  gvar_init := (Init_int8 (Int.repr 52) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 68) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 70) :: Init_int8 (Int.repr 70) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 67) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_42 := {|
  gvar_info := (tarray tschar 19);
  gvar_init := (Init_int8 (Int.repr 49) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 67) ::
                Init_int8 (Int.repr 72) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 67) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 76) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 85) :: Init_int8 (Int.repr 80) ::
                Init_int8 (Int.repr 80) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_21 := {|
  gvar_info := (tarray tschar 11);
  gvar_init := (Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 85) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 85) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_40 := {|
  gvar_info := (tarray tschar 19);
  gvar_init := (Init_int8 (Int.repr 51) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 67) ::
                Init_int8 (Int.repr 72) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 67) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 76) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 85) :: Init_int8 (Int.repr 80) ::
                Init_int8 (Int.repr 80) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_45 := {|
  gvar_info := (tarray tschar 21);
  gvar_init := (Init_int8 (Int.repr 50) :: Init_int8 (Int.repr 80) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 71) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 71) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_2 := {|
  gvar_info := (tarray tschar 15);
  gvar_init := (Init_int8 (Int.repr 49) :: Init_int8 (Int.repr 71) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 77) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 67) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_13 := {|
  gvar_info := (tarray tschar 14);
  gvar_init := (Init_int8 (Int.repr 71) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 76) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 71) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 68) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_28 := {|
  gvar_info := (tarray tschar 16);
  gvar_init := (Init_int8 (Int.repr 49) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 68) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 67) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 77) ::
                Init_int8 (Int.repr 80) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_8 := {|
  gvar_info := (tarray tschar 20);
  gvar_init := (Init_int8 (Int.repr 50) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 89) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 80) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 71) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 77) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_60 := {|
  gvar_info := (tarray tschar 20);
  gvar_init := (Init_int8 (Int.repr 49) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 88) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 67) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 86) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 80) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 67) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_36 := {|
  gvar_info := (tarray tschar 21);
  gvar_init := (Init_int8 (Int.repr 49) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 68) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 76) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 71) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 80) ::
                Init_int8 (Int.repr 72) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 67) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_53 := {|
  gvar_info := (tarray tschar 13);
  gvar_init := (Init_int8 (Int.repr 52) :: Init_int8 (Int.repr 77) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 86) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 67) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_55 := {|
  gvar_info := (tarray tschar 23);
  gvar_init := (Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 76) ::
                Init_int8 (Int.repr 76) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 80) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 76) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_9 := {|
  gvar_info := (tarray tschar 15);
  gvar_init := (Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 72) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 87) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 87) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_50 := {|
  gvar_info := (tarray tschar 20);
  gvar_init := (Init_int8 (Int.repr 53) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 67) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 88) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 87) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_3 := {|
  gvar_info := (tarray tschar 15);
  gvar_init := (Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 72) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 90) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_48 := {|
  gvar_info := (tarray tschar 12);
  gvar_init := (Init_int8 (Int.repr 76) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 76) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 87) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_44 := {|
  gvar_info := (tarray tschar 16);
  gvar_init := (Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 89) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 72) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 70) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_5 := {|
  gvar_info := (tarray tschar 21);
  gvar_init := (Init_int8 (Int.repr 50) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 68) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 67) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_33 := {|
  gvar_info := (tarray tschar 16);
  gvar_init := (Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 75) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 90) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 87) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_39 := {|
  gvar_info := (tarray tschar 13);
  gvar_init := (Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 87) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_16 := {|
  gvar_info := (tarray tschar 19);
  gvar_init := (Init_int8 (Int.repr 52) :: Init_int8 (Int.repr 67) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 77) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 80) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 71) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 77) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_25 := {|
  gvar_info := (tarray tschar 17);
  gvar_init := (Init_int8 (Int.repr 89) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 72) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 75) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 72) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 72) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_38 := {|
  gvar_info := (tarray tschar 19);
  gvar_init := (Init_int8 (Int.repr 72) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 72) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 89) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 72) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_24 := {|
  gvar_info := (tarray tschar 16);
  gvar_init := (Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 77) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 89) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 71) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_41 := {|
  gvar_info := (tarray tschar 22);
  gvar_init := (Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 71) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 54) ::
                Init_int8 (Int.repr 52) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 80) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 74) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 67) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 70) ::
                Init_int8 (Int.repr 70) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_58 := {|
  gvar_info := (tarray tschar 10);
  gvar_init := (Init_int8 (Int.repr 49) :: Init_int8 (Int.repr 80) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 67) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_11 := {|
  gvar_info := (tarray tschar 14);
  gvar_init := (Init_int8 (Int.repr 72) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 74) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 89) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 74) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 77) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_22 := {|
  gvar_info := (tarray tschar 18);
  gvar_init := (Init_int8 (Int.repr 50) :: Init_int8 (Int.repr 67) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 71) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_12 := {|
  gvar_info := (tarray tschar 13);
  gvar_init := (Init_int8 (Int.repr 51) :: Init_int8 (Int.repr 80) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 71) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 77) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_14 := {|
  gvar_info := (tarray tschar 15);
  gvar_init := (Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 75) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 87) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 71) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_57 := {|
  gvar_info := (tarray tschar 19);
  gvar_init := (Init_int8 (Int.repr 51) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 80) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 67) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 76) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 72) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 75) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_51 := {|
  gvar_info := (tarray tschar 17);
  gvar_init := (Init_int8 (Int.repr 67) :: Init_int8 (Int.repr 72) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 76) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_46 := {|
  gvar_info := (tarray tschar 12);
  gvar_init := (Init_int8 (Int.repr 72) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 89) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 77) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 68) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_52 := {|
  gvar_info := (tarray tschar 12);
  gvar_init := (Init_int8 (Int.repr 80) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 67) ::
                Init_int8 (Int.repr 72) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 86) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 67) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_19 := {|
  gvar_info := (tarray tschar 18);
  gvar_init := (Init_int8 (Int.repr 50) :: Init_int8 (Int.repr 67) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 67) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_31 := {|
  gvar_info := (tarray tschar 17);
  gvar_init := (Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 85) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 80) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 71) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 77) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_49 := {|
  gvar_info := (tarray tschar 12);
  gvar_init := (Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 76) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_59 := {|
  gvar_info := (tarray tschar 17);
  gvar_init := (Init_int8 (Int.repr 72) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 72) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 89) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 85) :: Init_int8 (Int.repr 67) ::
                Init_int8 (Int.repr 72) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_7 := {|
  gvar_info := (tarray tschar 17);
  gvar_init := (Init_int8 (Int.repr 89) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 72) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_1 := {|
  gvar_info := (tarray tschar 17);
  gvar_init := (Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 72) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 71) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 85) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 89) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_15 := {|
  gvar_info := (tarray tschar 22);
  gvar_init := (Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 70) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 67) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 80) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 71) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 77) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_26 := {|
  gvar_info := (tarray tschar 18);
  gvar_init := (Init_int8 (Int.repr 51) :: Init_int8 (Int.repr 67) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 71) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_43 := {|
  gvar_info := (tarray tschar 11);
  gvar_init := (Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 90) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_37 := {|
  gvar_info := (tarray tschar 12);
  gvar_init := (Init_int8 (Int.repr 72) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 89) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 68) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_29 := {|
  gvar_info := (tarray tschar 16);
  gvar_init := (Init_int8 (Int.repr 72) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 75) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 72) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 77) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 90) ::
                Init_int8 (Int.repr 85) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_54 := {|
  gvar_info := (tarray tschar 17);
  gvar_init := (Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 67) :: Init_int8 (Int.repr 76) ::
                Init_int8 (Int.repr 85) :: Init_int8 (Int.repr 66) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 70) :: Init_int8 (Int.repr 70) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_56 := {|
  gvar_info := (tarray tschar 10);
  gvar_init := (Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 70) ::
                Init_int8 (Int.repr 70) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_20 := {|
  gvar_info := (tarray tschar 11);
  gvar_init := (Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 75) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_34 := {|
  gvar_info := (tarray tschar 15);
  gvar_init := (Init_int8 (Int.repr 50) :: Init_int8 (Int.repr 51) ::
                Init_int8 (Int.repr 45) :: Init_int8 (Int.repr 68) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_gGlobalSoundSource := {|
  gvar_info := (tarray tfloat 3);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrCreditsEntry := {|
  gvar_info := (tptr (Tstruct _CreditsEntry noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gPlayer1Controller := {|
  gvar_info := (tptr (Tstruct _Controller noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrDemoInput := {|
  gvar_info := (tptr (Tstruct _DemoInput noattr));
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

Definition v_gDebugLevelSelect := {|
  gvar_info := tschar;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gShowProfiler := {|
  gvar_info := tschar;
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

Definition v_gWarpTransition := {|
  gvar_info := (Tstruct _WarpTransition noattr);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrCourseNum := {|
  gvar_info := tshort;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrActNum := {|
  gvar_info := tshort;
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

Definition v_gSavedCourseNum := {|
  gvar_info := tshort;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMenuOptSelectIndex := {|
  gvar_info := tshort;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAreas := {|
  gvar_info := (tptr (Tstruct _Area noattr));
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

Definition v_gCurrCourseStarFlags := {|
  gvar_info := tuchar;
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

Definition v_gLevelToCourseNumTable := {|
  gvar_info := (tarray tschar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_credits01 := {|
  gvar_info := (tarray (tptr tschar) 2);
  gvar_init := (Init_addrof ___stringlit_2 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_1 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_credits02 := {|
  gvar_info := (tarray (tptr tschar) 3);
  gvar_init := (Init_addrof ___stringlit_5 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_4 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_3 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_credits03 := {|
  gvar_info := (tarray (tptr tschar) 3);
  gvar_init := (Init_addrof ___stringlit_8 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_7 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_6 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_credits04 := {|
  gvar_info := (tarray (tptr tschar) 4);
  gvar_init := (Init_addrof ___stringlit_12 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_11 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_10 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_9 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_credits05 := {|
  gvar_info := (tarray (tptr tschar) 4);
  gvar_init := (Init_addrof ___stringlit_16 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_15 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_14 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_13 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_credits06 := {|
  gvar_info := (tarray (tptr tschar) 3);
  gvar_init := (Init_addrof ___stringlit_19 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_18 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_17 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_credits07 := {|
  gvar_info := (tarray (tptr tschar) 3);
  gvar_init := (Init_addrof ___stringlit_22 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_21 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_20 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_credits08 := {|
  gvar_info := (tarray (tptr tschar) 4);
  gvar_init := (Init_addrof ___stringlit_26 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_25 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_24 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_23 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_credits09 := {|
  gvar_info := (tarray (tptr tschar) 2);
  gvar_init := (Init_addrof ___stringlit_28 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_27 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_credits10 := {|
  gvar_info := (tarray (tptr tschar) 4);
  gvar_init := (Init_addrof ___stringlit_32 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_31 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_30 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_29 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_credits11 := {|
  gvar_info := (tarray (tptr tschar) 3);
  gvar_init := (Init_addrof ___stringlit_34 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_4 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_33 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_credits12 := {|
  gvar_info := (tarray (tptr tschar) 2);
  gvar_init := (Init_addrof ___stringlit_36 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_35 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_credits13 := {|
  gvar_info := (tarray (tptr tschar) 4);
  gvar_init := (Init_addrof ___stringlit_40 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_39 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_38 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_37 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_credits14 := {|
  gvar_info := (tarray (tptr tschar) 2);
  gvar_init := (Init_addrof ___stringlit_42 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_41 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_credits15 := {|
  gvar_info := (tarray (tptr tschar) 3);
  gvar_init := (Init_addrof ___stringlit_45 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_44 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_43 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_credits16 := {|
  gvar_info := (tarray (tptr tschar) 5);
  gvar_init := (Init_addrof ___stringlit_50 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_49 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_48 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_47 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_46 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_credits17 := {|
  gvar_info := (tarray (tptr tschar) 4);
  gvar_init := (Init_addrof ___stringlit_53 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_52 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_51 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_48 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_credits18 := {|
  gvar_info := (tarray (tptr tschar) 4);
  gvar_init := (Init_addrof ___stringlit_57 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_56 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_55 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_54 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_credits19 := {|
  gvar_info := (tarray (tptr tschar) 2);
  gvar_init := (Init_addrof ___stringlit_58 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_1 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_credits20 := {|
  gvar_info := (tarray (tptr tschar) 2);
  gvar_init := (Init_addrof ___stringlit_60 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_59 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sCreditsSequence := {|
  gvar_info := (tarray (Tstruct _CreditsEntry noattr) 23);
  gvar_init := (Init_int8 (Int.repr 16) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr (-128)) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 8000) ::
                Init_int16 (Int.repr 0) :: Init_space 6 ::
                Init_int64 (Int64.repr 0) :: Init_int8 (Int.repr 9) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 117) :: Init_int16 (Int.repr 713) ::
                Init_int16 (Int.repr 3918) ::
                Init_int16 (Int.repr (-3889)) :: Init_space 6 ::
                Init_addrof _credits01 (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 24) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 50) :: Init_int8 (Int.repr 46) ::
                Init_int16 (Int.repr 347) :: Init_int16 (Int.repr 5376) ::
                Init_int16 (Int.repr 326) :: Init_space 6 ::
                Init_addrof _credits02 (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 12) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 18) :: Init_int8 (Int.repr 22) ::
                Init_int16 (Int.repr 3800) ::
                Init_int16 (Int.repr (-4840)) ::
                Init_int16 (Int.repr 2727) :: Init_space 6 ::
                Init_addrof _credits03 (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 5) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 34) :: Init_int8 (Int.repr 25) ::
                Init_int16 (Int.repr (-5464)) ::
                Init_int16 (Int.repr 6656) ::
                Init_int16 (Int.repr (-6575)) :: Init_space 6 ::
                Init_addrof _credits04 (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 4) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 60) ::
                Init_int16 (Int.repr 257) :: Init_int16 (Int.repr 1922) ::
                Init_int16 (Int.repr 2580) :: Init_space 6 ::
                Init_addrof _credits05 (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 7) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 241) :: Init_int8 (Int.repr 123) ::
                Init_int16 (Int.repr (-6469)) ::
                Init_int16 (Int.repr 1616) ::
                Init_int16 (Int.repr (-6054)) :: Init_space 6 ::
                Init_addrof _credits06 (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 13) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 17) :: Init_int8 (Int.repr (-32)) ::
                Init_int16 (Int.repr 508) :: Init_int16 (Int.repr 1024) ::
                Init_int16 (Int.repr 1942) :: Init_space 6 ::
                Init_addrof _credits07 (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 22) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 33) :: Init_int8 (Int.repr 124) ::
                Init_int16 (Int.repr (-73)) :: Init_int16 (Int.repr 82) ::
                Init_int16 (Int.repr (-1467)) :: Init_space 6 ::
                Init_addrof _credits08 (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 8) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 98) ::
                Init_int16 (Int.repr (-5906)) ::
                Init_int16 (Int.repr 1024) ::
                Init_int16 (Int.repr (-2576)) :: Init_space 6 ::
                Init_addrof _credits09 (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 23) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 50) :: Init_int8 (Int.repr 47) ::
                Init_int16 (Int.repr (-4884)) ::
                Init_int16 (Int.repr (-4607)) ::
                Init_int16 (Int.repr (-272)) :: Init_space 6 ::
                Init_addrof _credits10 (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 10) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 17) :: Init_int8 (Int.repr (-34)) ::
                Init_int16 (Int.repr 1925) :: Init_int16 (Int.repr 3328) ::
                Init_int16 (Int.repr 563) :: Init_space 6 ::
                Init_addrof _credits11 (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 11) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 33) :: Init_int8 (Int.repr 105) ::
                Init_int16 (Int.repr (-537)) :: Init_int16 (Int.repr 1850) ::
                Init_int16 (Int.repr 1818) :: Init_space 6 ::
                Init_addrof _credits12 (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 36) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 2) :: Init_int8 (Int.repr (-33)) ::
                Init_int16 (Int.repr 2613) :: Init_int16 (Int.repr 313) ::
                Init_int16 (Int.repr 1074) :: Init_space 6 ::
                Init_addrof _credits13 (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 13) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 51) :: Init_int8 (Int.repr 54) ::
                Init_int16 (Int.repr (-2609)) :: Init_int16 (Int.repr 512) ::
                Init_int16 (Int.repr 856) :: Init_space 6 ::
                Init_addrof _credits14 (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 14) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 17) :: Init_int8 (Int.repr (-72)) ::
                Init_int16 (Int.repr (-1304)) ::
                Init_int16 (Int.repr (-71)) ::
                Init_int16 (Int.repr (-967)) :: Init_space 6 ::
                Init_addrof _credits15 (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 15) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 33) :: Init_int8 (Int.repr 64) ::
                Init_int16 (Int.repr 1565) :: Init_int16 (Int.repr 1024) ::
                Init_int16 (Int.repr (-148)) :: Init_space 6 ::
                Init_addrof _credits16 (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 20) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 24) ::
                Init_int16 (Int.repr (-1050)) ::
                Init_int16 (Int.repr (-1330)) ::
                Init_int16 (Int.repr (-1559)) :: Init_space 6 ::
                Init_addrof _credits17 (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 28) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 49) :: Init_int8 (Int.repr (-16)) ::
                Init_int16 (Int.repr (-254)) :: Init_int16 (Int.repr 415) ::
                Init_int16 (Int.repr (-6045)) :: Init_space 6 ::
                Init_addrof _credits18 (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 23) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 145) :: Init_int8 (Int.repr (-64)) ::
                Init_int16 (Int.repr 3948) :: Init_int16 (Int.repr 1185) ::
                Init_int16 (Int.repr (-104)) :: Init_space 6 ::
                Init_addrof _credits19 (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 5) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 33) :: Init_int8 (Int.repr 31) ::
                Init_int16 (Int.repr 3169) ::
                Init_int16 (Int.repr (-4607)) ::
                Init_int16 (Int.repr 5240) :: Init_space 6 ::
                Init_addrof _credits20 (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 16) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr (-128)) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 906) ::
                Init_int16 (Int.repr (-1200)) :: Init_space 6 ::
                Init_int64 (Int64.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_space 6 :: Init_int64 (Int64.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMarioStates := {|
  gvar_info := (tarray (Tstruct _MarioState noattr) 1);
  gvar_init := (Init_space 264 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gHudDisplay := {|
  gvar_info := (Tstruct _HudDisplay noattr);
  gvar_init := (Init_space 14 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sCurrPlayMode := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_80339ECA := {|
  gvar_info := tushort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sTransitionTimer := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sTransitionUpdate := {|
  gvar_info := (tptr (Tfunction ((tptr tshort) :: nil) tvoid cc_default));
  gvar_init := (Init_space 8 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sWarpDest := {|
  gvar_info := (Tstruct _WarpDest noattr);
  gvar_init := (Init_space 8 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_80339EE0 := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDelayedWarpOp := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDelayedWarpTimer := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSourceWarpNodeId := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDelayedWarpArg := {|
  gvar_info := tint;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sUnusedLevelUpdateBss := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sTimerRunning := {|
  gvar_info := tschar;
  gvar_init := (Init_space 1 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gNeverEnteredCastle := {|
  gvar_info := tschar;
  gvar_init := (Init_space 1 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMarioState := {|
  gvar_info := (tptr (Tstruct _MarioState noattr));
  gvar_init := (Init_addrof _gMarioStates (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_unused1 := {|
  gvar_info := (tarray tuchar 2);
  gvar_init := (Init_int8 (Int.repr 0) :: Init_space 1 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sWarpCheckpointActive := {|
  gvar_info := tschar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_unused2 := {|
  gvar_info := (tarray tuchar 4);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_level_control_timer := {|
  fn_return := tushort;
  fn_callconv := cc_default;
  fn_params := ((_timerOp, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tshort) :: (_t'2, tshort) :: (_t'1, tushort) :: nil);
  fn_body :=
(Ssequence
  (Sswitch (Etempvar _timerOp tint)
    (LScons (Some 0)
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr)) _flags
              tshort))
          (Sassign
            (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr)) _flags
              tshort)
            (Ebinop Oor (Etempvar _t'3 tshort)
              (Econst_int (Int.repr 64) tint) tint)))
        (Ssequence
          (Sassign (Evar _sTimerRunning tschar)
            (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Sassign
              (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr)) _timer
                tushort) (Econst_int (Int.repr 0) tint))
            Sbreak)))
      (LScons (Some 1)
        (Ssequence
          (Sassign (Evar _sTimerRunning tschar)
            (Econst_int (Int.repr 1) tint))
          Sbreak)
        (LScons (Some 2)
          (Ssequence
            (Sassign (Evar _sTimerRunning tschar)
              (Econst_int (Int.repr 0) tint))
            Sbreak)
          (LScons (Some 3)
            (Ssequence
              (Ssequence
                (Sset _t'2
                  (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                    _flags tshort))
                (Sassign
                  (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                    _flags tshort)
                  (Ebinop Oand (Etempvar _t'2 tshort)
                    (Eunop Onotint (Econst_int (Int.repr 64) tint) tint)
                    tint)))
              (Ssequence
                (Sassign (Evar _sTimerRunning tschar)
                  (Econst_int (Int.repr 0) tint))
                (Ssequence
                  (Sassign
                    (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                      _timer tushort) (Econst_int (Int.repr 0) tint))
                  Sbreak)))
            LSnil)))))
  (Ssequence
    (Sset _t'1
      (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr)) _timer
        tushort))
    (Sreturn (Some (Etempvar _t'1 tushort)))))
|}.

Definition f_pressed_pause := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_dialogActive, tuint) :: (_intangible, tuint) ::
               (_t'5, tint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tshort) :: (_t'11, tuint) ::
               (_t'10, (tptr (Tstruct _MarioState noattr))) ::
               (_t'9, tuchar) :: (_t'8, tshort) :: (_t'7, tushort) ::
               (_t'6, (tptr (Tstruct _Controller noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _get_dialog_id (Tfunction nil tshort cc_default)) nil)
    (Sset _dialogActive
      (Ebinop Oge (Etempvar _t'1 tshort) (Econst_int (Int.repr 0) tint) tint)))
  (Ssequence
    (Ssequence
      (Sset _t'10 (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
      (Ssequence
        (Sset _t'11
          (Efield
            (Ederef (Etempvar _t'10 (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _action tuint))
        (Sset _intangible
          (Ebinop One
            (Ebinop Oand (Etempvar _t'11 tuint)
              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 12) tint) tint) tuint)
            (Econst_int (Int.repr 0) tint) tint))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Ssequence
              (Sifthenelse (Eunop Onotbool (Etempvar _intangible tuint) tint)
                (Sset _t'2
                  (Ecast (Eunop Onotbool (Etempvar _dialogActive tuint) tint)
                    tbool))
                (Sset _t'2 (Econst_int (Int.repr 0) tint)))
              (Sifthenelse (Etempvar _t'2 tint)
                (Ssequence
                  (Sset _t'9
                    (Efield
                      (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                      _isActive tuchar))
                  (Sset _t'3
                    (Ecast (Eunop Onotbool (Etempvar _t'9 tuchar) tint)
                      tbool)))
                (Sset _t'3 (Econst_int (Int.repr 0) tint))))
            (Sifthenelse (Etempvar _t'3 tint)
              (Ssequence
                (Sset _t'8 (Evar _sDelayedWarpOp tshort))
                (Sset _t'4
                  (Ecast
                    (Ebinop Oeq (Etempvar _t'8 tshort)
                      (Econst_int (Int.repr 0) tint) tint) tbool)))
              (Sset _t'4 (Econst_int (Int.repr 0) tint))))
          (Sifthenelse (Etempvar _t'4 tint)
            (Ssequence
              (Sset _t'6
                (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
              (Ssequence
                (Sset _t'7
                  (Efield
                    (Ederef
                      (Etempvar _t'6 (tptr (Tstruct _Controller noattr)))
                      (Tstruct _Controller noattr)) _buttonPressed tushort))
                (Sset _t'5
                  (Ecast
                    (Ebinop Oand (Etempvar _t'7 tushort)
                      (Econst_int (Int.repr 4096) tint) tint) tbool))))
            (Sset _t'5 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'5 tint)
          (Sreturn (Some (Econst_int (Int.repr 1) tint)))
          Sskip))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_set_play_mode := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_playMode, tshort) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sassign (Evar _sCurrPlayMode tshort) (Etempvar _playMode tshort))
  (Sassign (Evar _D_80339ECA tushort) (Econst_int (Int.repr 0) tint)))
|}.

Definition f_warp_special := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_arg, tint) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sassign (Evar _sCurrPlayMode tshort) (Econst_int (Int.repr 4) tint))
  (Ssequence
    (Sassign (Evar _D_80339ECA tushort) (Econst_int (Int.repr 0) tint))
    (Sassign (Evar _D_80339EE0 tshort) (Etempvar _arg tint))))
|}.

Definition f_fade_into_special_warp := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_arg, tuint) :: (_color, tuint) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One (Etempvar _color tuint)
                 (Econst_int (Int.repr 0) tint) tint)
    (Sset _color (Econst_int (Int.repr 255) tint))
    Sskip)
  (Ssequence
    (Scall None
      (Evar _fadeout_music (Tfunction (tshort :: nil) tvoid cc_default))
      ((Econst_int (Int.repr 190) tint) :: nil))
    (Ssequence
      (Scall None
        (Evar _play_transition (Tfunction
                                 (tshort :: tshort :: tuchar :: tuchar ::
                                  tuchar :: nil) tvoid cc_default))
        ((Econst_int (Int.repr 1) tint) :: (Econst_int (Int.repr 16) tint) ::
         (Etempvar _color tuint) :: (Etempvar _color tuint) ::
         (Etempvar _color tuint) :: nil))
      (Ssequence
        (Scall None
          (Evar _level_set_transition (Tfunction
                                        (tshort ::
                                         (tptr (Tfunction
                                                 ((tptr tshort) :: nil) tvoid
                                                 cc_default)) :: nil) tvoid
                                        cc_default))
          ((Econst_int (Int.repr 30) tint) ::
           (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) :: nil))
        (Scall None
          (Evar _warp_special (Tfunction (tint :: nil) tvoid cc_default))
          ((Etempvar _arg tuint) :: nil))))))
|}.

Definition f_stub_level_update_1 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
Sskip
|}.

Definition f_load_level_init_text := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_arg, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_gotAchievement, tint) :: (_dialogID, tint) ::
               (_t'4, tuint) :: (_t'3, tuint) :: (_t'2, tuint) ::
               (_t'1, tuint) :: (_t'7, (tptr (Tstruct _Area noattr))) ::
               (_t'6, tshort) :: (_t'5, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
    (Sset _dialogID
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _t'7 (tptr (Tstruct _Area noattr)))
              (Tstruct _Area noattr)) _dialog (tarray tuchar 2))
          (Etempvar _arg tuint) (tptr tuchar)) tuchar)))
  (Ssequence
    (Sswitch (Etempvar _dialogID tint)
      (LScons (Some 129)
        (Ssequence
          (Ssequence
            (Scall (Some _t'1)
              (Evar _save_file_get_flags (Tfunction nil tuint cc_default))
              nil)
            (Sset _gotAchievement
              (Ebinop Oand (Etempvar _t'1 tuint)
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 3) tint) tint) tuint)))
          Sbreak)
        (LScons (Some 130)
          (Ssequence
            (Ssequence
              (Scall (Some _t'2)
                (Evar _save_file_get_flags (Tfunction nil tuint cc_default))
                nil)
              (Sset _gotAchievement
                (Ebinop Oand (Etempvar _t'2 tuint)
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 2) tint) tint) tuint)))
            Sbreak)
          (LScons (Some 131)
            (Ssequence
              (Ssequence
                (Scall (Some _t'3)
                  (Evar _save_file_get_flags (Tfunction nil tuint cc_default))
                  nil)
                (Sset _gotAchievement
                  (Ebinop Oand (Etempvar _t'3 tuint)
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)))
              Sbreak)
            (LScons (Some 255)
              (Ssequence
                (Sset _gotAchievement (Econst_int (Int.repr 1) tint))
                Sbreak)
              (LScons None
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'5 (Evar _gCurrSaveFileNum tshort))
                      (Ssequence
                        (Sset _t'6 (Evar _gCurrCourseNum tshort))
                        (Scall (Some _t'4)
                          (Evar _save_file_get_star_flags (Tfunction
                                                            (tint :: tint ::
                                                             nil) tuint
                                                            cc_default))
                          ((Ebinop Osub (Etempvar _t'5 tshort)
                             (Econst_int (Int.repr 1) tint) tint) ::
                           (Ebinop Osub (Etempvar _t'6 tshort)
                             (Econst_int (Int.repr 1) tint) tint) :: nil))))
                    (Sset _gotAchievement (Etempvar _t'4 tuint)))
                  Sbreak)
                LSnil))))))
    (Sifthenelse (Eunop Onotbool (Etempvar _gotAchievement tint) tint)
      (Ssequence
        (Scall None
          (Evar _level_set_transition (Tfunction
                                        (tshort ::
                                         (tptr (Tfunction
                                                 ((tptr tshort) :: nil) tvoid
                                                 cc_default)) :: nil) tvoid
                                        cc_default))
          ((Eunop Oneg (Econst_int (Int.repr 1) tint) tint) ::
           (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) :: nil))
        (Scall None
          (Evar _create_dialog_box (Tfunction (tshort :: nil) tvoid
                                     cc_default))
          ((Etempvar _dialogID tint) :: nil)))
      Sskip)))
|}.

Definition f_init_door_warp := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_spawnInfo, (tptr (Tstruct _SpawnInfo noattr))) ::
                (_arg1, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'7, tshort) :: (_t'6, tfloat) :: (_t'5, tshort) ::
               (_t'4, tshort) :: (_t'3, tfloat) :: (_t'2, tshort) ::
               (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Oand (Etempvar _arg1 tuint)
                 (Econst_int (Int.repr 2) tint) tuint)
    (Ssequence
      (Sset _t'7
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef
                (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                (Tstruct _SpawnInfo noattr)) _startAngle (tarray tshort 3))
            (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef
                (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                (Tstruct _SpawnInfo noattr)) _startAngle (tarray tshort 3))
            (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort)
        (Ebinop Oadd (Etempvar _t'7 tshort)
          (Econst_int (Int.repr 32768) tint) tint)))
    Sskip)
  (Ssequence
    (Ssequence
      (Sset _t'4
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef
                (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                (Tstruct _SpawnInfo noattr)) _startPos (tarray tshort 3))
            (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
      (Ssequence
        (Sset _t'5
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef
                  (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                  (Tstruct _SpawnInfo noattr)) _startAngle (tarray tshort 3))
              (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
        (Ssequence
          (Sset _t'6
            (Ederef
              (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                (Ebinop Oshr (Ecast (Etempvar _t'5 tshort) tushort)
                  (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef
                    (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                    (Tstruct _SpawnInfo noattr)) _startPos (tarray tshort 3))
                (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort)
            (Ebinop Oadd (Etempvar _t'4 tshort)
              (Ebinop Omul
                (Econst_single (Float32.of_bits (Int.repr 1133903872)) tfloat)
                (Etempvar _t'6 tfloat) tfloat) tfloat)))))
    (Ssequence
      (Sset _t'1
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef
                (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                (Tstruct _SpawnInfo noattr)) _startPos (tarray tshort 3))
            (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort))
      (Ssequence
        (Sset _t'2
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef
                  (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                  (Tstruct _SpawnInfo noattr)) _startAngle (tarray tshort 3))
              (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
        (Ssequence
          (Sset _t'3
            (Ederef
              (Ebinop Oadd
                (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                  (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                (Ebinop Oshr (Ecast (Etempvar _t'2 tshort) tushort)
                  (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef
                    (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                    (Tstruct _SpawnInfo noattr)) _startPos (tarray tshort 3))
                (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort)
            (Ebinop Oadd (Etempvar _t'1 tshort)
              (Ebinop Omul
                (Econst_single (Float32.of_bits (Int.repr 1133903872)) tfloat)
                (Etempvar _t'3 tfloat) tfloat) tfloat)))))))
|}.

Definition f_set_mario_initial_cap_powerup := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_capCourseIndex, tint) :: (_t'4, tshort) :: (_t'3, tuint) ::
               (_t'2, tuint) :: (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _gCurrCourseNum tshort))
    (Sset _capCourseIndex
      (Ebinop Osub (Etempvar _t'4 tshort) (Econst_int (Int.repr 20) tint)
        tint)))
  (Sswitch (Etempvar _capCourseIndex tint)
    (LScons (Some 0)
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _flags tuint))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _flags tuint)
            (Ebinop Oor (Etempvar _t'3 tuint)
              (Ebinop Oor (Econst_int (Int.repr 4) tint)
                (Econst_int (Int.repr 16) tint) tint) tuint)))
        (Ssequence
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _capTimer tushort)
            (Econst_int (Int.repr 600) tint))
          Sbreak))
      (LScons (Some 1)
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
              (Ebinop Oor (Etempvar _t'2 tuint)
                (Ebinop Oor (Econst_int (Int.repr 8) tint)
                  (Econst_int (Int.repr 16) tint) tint) tuint)))
          (Ssequence
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _capTimer tushort)
              (Econst_int (Int.repr 1200) tint))
            Sbreak))
        (LScons (Some 2)
          (Ssequence
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
                  (Ebinop Oor (Econst_int (Int.repr 2) tint)
                    (Econst_int (Int.repr 16) tint) tint) tuint)))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _capTimer tushort)
                (Econst_int (Int.repr 600) tint))
              Sbreak))
          LSnil)))))
|}.

Definition f_set_mario_initial_action := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_spawnType, tuint) :: (_actionArg, tuint) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sswitch (Etempvar _spawnType tuint)
    (LScons (Some 1)
      (Ssequence
        (Scall None
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 4898) tint) ::
           (Etempvar _actionArg tuint) :: nil))
        Sbreak)
      (LScons (Some 2)
        (Ssequence
          (Scall None
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 205521409) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          Sbreak)
        (LScons (Some 3)
          (Ssequence
            (Scall None
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 6435) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            Sbreak)
          (LScons (Some 4)
            (Ssequence
              (Scall None
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 4919) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              Sbreak)
            (LScons (Some 16)
              (Ssequence
                (Scall None
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 205521409) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                Sbreak)
              (LScons (Some 18)
                (Ssequence
                  (Scall None
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 6450) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  Sbreak)
                (LScons (Some 19)
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
                  (LScons (Some 20)
                    (Ssequence
                      (Scall None
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 6436) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil))
                      Sbreak)
                    (LScons (Some 21)
                      (Ssequence
                        (Scall None
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 6442) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))
                        Sbreak)
                      (LScons (Some 22)
                        (Ssequence
                          (Scall None
                            (Evar _set_mario_action (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: tuint :: nil)
                                                      tuint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 6436) tint) ::
                             (Econst_int (Int.repr 0) tint) :: nil))
                          Sbreak)
                        (LScons (Some 23)
                          (Ssequence
                            (Scall None
                              (Evar _set_mario_action (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         tuint :: tuint ::
                                                         nil) tuint
                                                        cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 277350553) tint) ::
                               (Econst_int (Int.repr 2) tint) :: nil))
                            Sbreak)
                          (LScons (Some 17)
                            (Ssequence
                              (Scall None
                                (Evar _set_mario_action (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           tuint :: tuint ::
                                                           nil) tuint
                                                          cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 (Econst_int (Int.repr 939532992) tint) ::
                                 (Econst_int (Int.repr 1) tint) :: nil))
                              Sbreak)
                            (LScons (Some 32)
                              (Ssequence
                                (Scall None
                                  (Evar _set_mario_action (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             tuint ::
                                                             tuint :: nil)
                                                            tuint cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   (Econst_int (Int.repr 6438) tint) ::
                                   (Econst_int (Int.repr 0) tint) :: nil))
                                Sbreak)
                              (LScons (Some 33)
                                (Ssequence
                                  (Scall None
                                    (Evar _set_mario_action (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               tuint ::
                                                               tuint :: nil)
                                                              tuint
                                                              cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     (Econst_int (Int.repr 6440) tint) ::
                                     (Econst_int (Int.repr 0) tint) :: nil))
                                  Sbreak)
                                (LScons (Some 34)
                                  (Ssequence
                                    (Scall None
                                      (Evar _set_mario_action (Tfunction
                                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                                 tuint ::
                                                                 tuint ::
                                                                 nil) tuint
                                                                cc_default))
                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                       (Econst_int (Int.repr 6445) tint) ::
                                       (Econst_int (Int.repr 0) tint) :: nil))
                                    Sbreak)
                                  (LScons (Some 35)
                                    (Ssequence
                                      (Scall None
                                        (Evar _set_mario_action (Tfunction
                                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                                   tuint ::
                                                                   tuint ::
                                                                   nil) tuint
                                                                  cc_default))
                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                         (Econst_int (Int.repr 6441) tint) ::
                                         (Econst_int (Int.repr 0) tint) ::
                                         nil))
                                      Sbreak)
                                    (LScons (Some 36)
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
                                           (Econst_int (Int.repr 6443) tint) ::
                                           (Econst_int (Int.repr 0) tint) ::
                                           nil))
                                        Sbreak)
                                      (LScons (Some 37)
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
                                             (Econst_int (Int.repr 6444) tint) ::
                                             (Econst_int (Int.repr 0) tint) ::
                                             nil))
                                          Sbreak)
                                        LSnil)))))))))))))))))))
  (Scall None
    (Evar _set_mario_initial_cap_powerup (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil)))
|}.

Definition f_init_mario_after_warp := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_spawnNode, (tptr (Tstruct _ObjectWarpNode noattr))) ::
               (_marioSpawnType, tuint) :: (_t'12, tint) :: (_t'11, tint) ::
               (_t'10, tint) :: (_t'9, tint) :: (_t'8, tint) ::
               (_t'7, tint) :: (_t'6, tint) :: (_t'5, tushort) ::
               (_t'4, tint) :: (_t'3, tint) :: (_t'2, tuint) ::
               (_t'1, (tptr (Tstruct _ObjectWarpNode noattr))) ::
               (_t'57, tuchar) :: (_t'56, (tptr (Tstruct _Object noattr))) ::
               (_t'55, tfloat) :: (_t'54, (tptr (Tstruct _Object noattr))) ::
               (_t'53, tfloat) :: (_t'52, (tptr (Tstruct _Object noattr))) ::
               (_t'51, tfloat) :: (_t'50, (tptr (Tstruct _Object noattr))) ::
               (_t'49, tint) :: (_t'48, (tptr (Tstruct _Object noattr))) ::
               (_t'47, tuint) :: (_t'46, tuchar) :: (_t'45, tuchar) ::
               (_t'44, tuchar) :: (_t'43, tuint) ::
               (_t'42, (tptr (Tstruct _MarioState noattr))) ::
               (_t'41, (tptr (Tstruct _Object noattr))) ::
               (_t'40, (tptr (Tstruct _MarioState noattr))) ::
               (_t'39, (tptr (Tstruct _Object noattr))) ::
               (_t'38, (tptr (Tstruct _MarioState noattr))) ::
               (_t'37, tuint) ::
               (_t'36, (tptr (Tstruct _MarioState noattr))) ::
               (_t'35, (tptr (Tstruct _Camera noattr))) ::
               (_t'34, (tptr (Tstruct _Area noattr))) :: (_t'33, tushort) ::
               (_t'32, (tptr (Tstruct _Area noattr))) :: (_t'31, tushort) ::
               (_t'30, (tptr (Tstruct _Area noattr))) :: (_t'29, tuint) ::
               (_t'28, (tptr (Tstruct _MarioState noattr))) ::
               (_t'27, tuint) ::
               (_t'26, (tptr (Tstruct _MarioState noattr))) ::
               (_t'25, tshort) :: (_t'24, tschar) :: (_t'23, tuchar) ::
               (_t'22, tuchar) :: (_t'21, tuchar) :: (_t'20, tuchar) ::
               (_t'19, tuchar) :: (_t'18, tuchar) :: (_t'17, tuchar) ::
               (_t'16, tuchar) :: (_t'15, tuchar) :: (_t'14, tuchar) ::
               (_t'13, (tptr (Tstruct _DemoInput noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'57
        (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr)) _nodeId tuchar))
      (Scall (Some _t'1)
        (Evar _area_get_warp_node (Tfunction (tuchar :: nil)
                                    (tptr (Tstruct _ObjectWarpNode noattr))
                                    cc_default))
        ((Etempvar _t'57 tuchar) :: nil)))
    (Sset _spawnNode (Etempvar _t'1 (tptr (Tstruct _ObjectWarpNode noattr)))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'56
          (Efield
            (Ederef
              (Etempvar _spawnNode (tptr (Tstruct _ObjectWarpNode noattr)))
              (Tstruct _ObjectWarpNode noattr)) _object
            (tptr (Tstruct _Object noattr))))
        (Scall (Some _t'2)
          (Evar _get_mario_spawn_type (Tfunction
                                        ((tptr (Tstruct _Object noattr)) ::
                                         nil) tuint cc_default))
          ((Etempvar _t'56 (tptr (Tstruct _Object noattr))) :: nil)))
      (Sset _marioSpawnType (Etempvar _t'2 tuint)))
    (Ssequence
      (Ssequence
        (Sset _t'36 (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
        (Ssequence
          (Sset _t'37
            (Efield
              (Ederef (Etempvar _t'36 (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _action tuint))
          (Sifthenelse (Ebinop One (Etempvar _t'37 tuint)
                         (Econst_int (Int.repr 0) tint) tint)
            (Ssequence
              (Ssequence
                (Sset _t'54
                  (Efield
                    (Ederef
                      (Etempvar _spawnNode (tptr (Tstruct _ObjectWarpNode noattr)))
                      (Tstruct _ObjectWarpNode noattr)) _object
                    (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'55
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'54 (tptr (Tstruct _Object noattr)))
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
                            (Ebinop Oadd
                              (Evar _gPlayerSpawnInfos (tarray (Tstruct _SpawnInfo noattr) 0))
                              (Econst_int (Int.repr 0) tint)
                              (tptr (Tstruct _SpawnInfo noattr)))
                            (Tstruct _SpawnInfo noattr)) _startPos
                          (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tshort)) tshort)
                    (Ecast (Etempvar _t'55 tfloat) tshort))))
              (Ssequence
                (Ssequence
                  (Sset _t'52
                    (Efield
                      (Ederef
                        (Etempvar _spawnNode (tptr (Tstruct _ObjectWarpNode noattr)))
                        (Tstruct _ObjectWarpNode noattr)) _object
                      (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sset _t'53
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'52 (tptr (Tstruct _Object noattr)))
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
                            (Ederef
                              (Ebinop Oadd
                                (Evar _gPlayerSpawnInfos (tarray (Tstruct _SpawnInfo noattr) 0))
                                (Econst_int (Int.repr 0) tint)
                                (tptr (Tstruct _SpawnInfo noattr)))
                              (Tstruct _SpawnInfo noattr)) _startPos
                            (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tshort)) tshort)
                      (Ecast (Etempvar _t'53 tfloat) tshort))))
                (Ssequence
                  (Ssequence
                    (Sset _t'50
                      (Efield
                        (Ederef
                          (Etempvar _spawnNode (tptr (Tstruct _ObjectWarpNode noattr)))
                          (Tstruct _ObjectWarpNode noattr)) _object
                        (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sset _t'51
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'50 (tptr (Tstruct _Object noattr)))
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
                                (Ebinop Oadd
                                  (Evar _gPlayerSpawnInfos (tarray (Tstruct _SpawnInfo noattr) 0))
                                  (Econst_int (Int.repr 0) tint)
                                  (tptr (Tstruct _SpawnInfo noattr)))
                                (Tstruct _SpawnInfo noattr)) _startPos
                              (tarray tshort 3))
                            (Econst_int (Int.repr 2) tint) (tptr tshort))
                          tshort) (Ecast (Etempvar _t'51 tfloat) tshort))))
                  (Ssequence
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Evar _gPlayerSpawnInfos (tarray (Tstruct _SpawnInfo noattr) 0))
                                (Econst_int (Int.repr 0) tint)
                                (tptr (Tstruct _SpawnInfo noattr)))
                              (Tstruct _SpawnInfo noattr)) _startAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                          (tptr tshort)) tshort)
                      (Econst_int (Int.repr 0) tint))
                    (Ssequence
                      (Ssequence
                        (Sset _t'48
                          (Efield
                            (Ederef
                              (Etempvar _spawnNode (tptr (Tstruct _ObjectWarpNode noattr)))
                              (Tstruct _ObjectWarpNode noattr)) _object
                            (tptr (Tstruct _Object noattr))))
                        (Ssequence
                          (Sset _t'49
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'48 (tptr (Tstruct _Object noattr)))
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
                                    (Ebinop Oadd
                                      (Evar _gPlayerSpawnInfos (tarray (Tstruct _SpawnInfo noattr) 0))
                                      (Econst_int (Int.repr 0) tint)
                                      (tptr (Tstruct _SpawnInfo noattr)))
                                    (Tstruct _SpawnInfo noattr)) _startAngle
                                  (tarray tshort 3))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))
                              tshort) (Etempvar _t'49 tint))))
                      (Ssequence
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _gPlayerSpawnInfos (tarray (Tstruct _SpawnInfo noattr) 0))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr (Tstruct _SpawnInfo noattr)))
                                  (Tstruct _SpawnInfo noattr)) _startAngle
                                (tarray tshort 3))
                              (Econst_int (Int.repr 2) tint) (tptr tshort))
                            tshort) (Econst_int (Int.repr 0) tint))
                        (Ssequence
                          (Sifthenelse (Ebinop Oeq
                                         (Etempvar _marioSpawnType tuint)
                                         (Econst_int (Int.repr 1) tint) tint)
                            (Ssequence
                              (Sset _t'47
                                (Efield
                                  (Evar _sWarpDest (Tstruct _WarpDest noattr))
                                  _arg tuint))
                              (Scall None
                                (Evar _init_door_warp (Tfunction
                                                        ((tptr (Tstruct _SpawnInfo noattr)) ::
                                                         tuint :: nil) tvoid
                                                        cc_default))
                                ((Ebinop Oadd
                                   (Evar _gPlayerSpawnInfos (tarray (Tstruct _SpawnInfo noattr) 0))
                                   (Econst_int (Int.repr 0) tint)
                                   (tptr (Tstruct _SpawnInfo noattr))) ::
                                 (Etempvar _t'47 tuint) :: nil)))
                            Sskip)
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Sset _t'45
                                  (Efield
                                    (Evar _sWarpDest (Tstruct _WarpDest noattr))
                                    _type tuchar))
                                (Sifthenelse (Ebinop Oeq
                                               (Etempvar _t'45 tuchar)
                                               (Econst_int (Int.repr 1) tint)
                                               tint)
                                  (Sset _t'3 (Econst_int (Int.repr 1) tint))
                                  (Ssequence
                                    (Sset _t'46
                                      (Efield
                                        (Evar _sWarpDest (Tstruct _WarpDest noattr))
                                        _type tuchar))
                                    (Sset _t'3
                                      (Ecast
                                        (Ebinop Oeq (Etempvar _t'46 tuchar)
                                          (Econst_int (Int.repr 2) tint)
                                          tint) tbool)))))
                              (Sifthenelse (Etempvar _t'3 tint)
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'44
                                      (Efield
                                        (Evar _sWarpDest (Tstruct _WarpDest noattr))
                                        _areaIdx tuchar))
                                    (Sassign
                                      (Efield
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _gPlayerSpawnInfos (tarray (Tstruct _SpawnInfo noattr) 0))
                                            (Econst_int (Int.repr 0) tint)
                                            (tptr (Tstruct _SpawnInfo noattr)))
                                          (Tstruct _SpawnInfo noattr))
                                        _areaIndex tschar)
                                      (Etempvar _t'44 tuchar)))
                                  (Scall None
                                    (Evar _load_mario_area (Tfunction nil
                                                             tvoid
                                                             cc_default))
                                    nil))
                                Sskip))
                            (Ssequence
                              (Scall None
                                (Evar _init_mario (Tfunction nil tvoid
                                                    cc_default)) nil)
                              (Ssequence
                                (Ssequence
                                  (Sset _t'42
                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                  (Ssequence
                                    (Sset _t'43
                                      (Efield
                                        (Evar _sWarpDest (Tstruct _WarpDest noattr))
                                        _arg tuint))
                                    (Scall None
                                      (Evar _set_mario_initial_action 
                                      (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tvoid
                                        cc_default))
                                      ((Etempvar _t'42 (tptr (Tstruct _MarioState noattr))) ::
                                       (Etempvar _marioSpawnType tuint) ::
                                       (Etempvar _t'43 tuint) :: nil))))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'40
                                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                    (Ssequence
                                      (Sset _t'41
                                        (Efield
                                          (Ederef
                                            (Etempvar _spawnNode (tptr (Tstruct _ObjectWarpNode noattr)))
                                            (Tstruct _ObjectWarpNode noattr))
                                          _object
                                          (tptr (Tstruct _Object noattr))))
                                      (Sassign
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'40 (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _interactObj
                                          (tptr (Tstruct _Object noattr)))
                                        (Etempvar _t'41 (tptr (Tstruct _Object noattr))))))
                                  (Ssequence
                                    (Sset _t'38
                                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                    (Ssequence
                                      (Sset _t'39
                                        (Efield
                                          (Ederef
                                            (Etempvar _spawnNode (tptr (Tstruct _ObjectWarpNode noattr)))
                                            (Tstruct _ObjectWarpNode noattr))
                                          _object
                                          (tptr (Tstruct _Object noattr))))
                                      (Sassign
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'38 (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _usedObj
                                          (tptr (Tstruct _Object noattr)))
                                        (Etempvar _t'39 (tptr (Tstruct _Object noattr)))))))))))))))))
            Sskip)))
      (Ssequence
        (Ssequence
          (Sset _t'34 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
          (Ssequence
            (Sset _t'35
              (Efield
                (Ederef (Etempvar _t'34 (tptr (Tstruct _Area noattr)))
                  (Tstruct _Area noattr)) _camera
                (tptr (Tstruct _Camera noattr))))
            (Scall None
              (Evar _reset_camera (Tfunction
                                    ((tptr (Tstruct _Camera noattr)) :: nil)
                                    tvoid cc_default))
              ((Etempvar _t'35 (tptr (Tstruct _Camera noattr))) :: nil))))
        (Ssequence
          (Sassign
            (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr)) _type
              tuchar) (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Sassign (Evar _sDelayedWarpOp tshort)
              (Econst_int (Int.repr 0) tint))
            (Ssequence
              (Sswitch (Etempvar _marioSpawnType tuint)
                (LScons (Some 3)
                  (Ssequence
                    (Scall None
                      (Evar _play_transition (Tfunction
                                               (tshort :: tshort :: tuchar ::
                                                tuchar :: tuchar :: nil)
                                               tvoid cc_default))
                      ((Econst_int (Int.repr 8) tint) ::
                       (Econst_int (Int.repr 16) tint) ::
                       (Econst_int (Int.repr 0) tint) ::
                       (Econst_int (Int.repr 0) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    Sbreak)
                  (LScons (Some 1)
                    (Ssequence
                      (Scall None
                        (Evar _play_transition (Tfunction
                                                 (tshort :: tshort ::
                                                  tuchar :: tuchar ::
                                                  tuchar :: nil) tvoid
                                                 cc_default))
                        ((Econst_int (Int.repr 10) tint) ::
                         (Econst_int (Int.repr 16) tint) ::
                         (Econst_int (Int.repr 0) tint) ::
                         (Econst_int (Int.repr 0) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil))
                      Sbreak)
                    (LScons (Some 4)
                      (Ssequence
                        (Scall None
                          (Evar _play_transition (Tfunction
                                                   (tshort :: tshort ::
                                                    tuchar :: tuchar ::
                                                    tuchar :: nil) tvoid
                                                   cc_default))
                          ((Econst_int (Int.repr 0) tint) ::
                           (Econst_int (Int.repr 20) tint) ::
                           (Econst_int (Int.repr 255) tint) ::
                           (Econst_int (Int.repr 255) tint) ::
                           (Econst_int (Int.repr 255) tint) :: nil))
                        Sbreak)
                      (LScons (Some 22)
                        (Ssequence
                          (Scall None
                            (Evar _play_transition (Tfunction
                                                     (tshort :: tshort ::
                                                      tuchar :: tuchar ::
                                                      tuchar :: nil) tvoid
                                                     cc_default))
                            ((Econst_int (Int.repr 0) tint) ::
                             (Econst_int (Int.repr 26) tint) ::
                             (Econst_int (Int.repr 255) tint) ::
                             (Econst_int (Int.repr 255) tint) ::
                             (Econst_int (Int.repr 255) tint) :: nil))
                          Sbreak)
                        (LScons (Some 20)
                          (Ssequence
                            (Scall None
                              (Evar _play_transition (Tfunction
                                                       (tshort :: tshort ::
                                                        tuchar :: tuchar ::
                                                        tuchar :: nil) tvoid
                                                       cc_default))
                              ((Econst_int (Int.repr 10) tint) ::
                               (Econst_int (Int.repr 16) tint) ::
                               (Econst_int (Int.repr 0) tint) ::
                               (Econst_int (Int.repr 0) tint) ::
                               (Econst_int (Int.repr 0) tint) :: nil))
                            Sbreak)
                          (LScons (Some 39)
                            (Ssequence
                              (Scall None
                                (Evar _play_transition (Tfunction
                                                         (tshort :: tshort ::
                                                          tuchar :: tuchar ::
                                                          tuchar :: nil)
                                                         tvoid cc_default))
                                ((Econst_int (Int.repr 0) tint) ::
                                 (Econst_int (Int.repr 16) tint) ::
                                 (Econst_int (Int.repr 0) tint) ::
                                 (Econst_int (Int.repr 0) tint) ::
                                 (Econst_int (Int.repr 0) tint) :: nil))
                              Sbreak)
                            (LScons None
                              (Ssequence
                                (Scall None
                                  (Evar _play_transition (Tfunction
                                                           (tshort ::
                                                            tshort ::
                                                            tuchar ::
                                                            tuchar ::
                                                            tuchar :: nil)
                                                           tvoid cc_default))
                                  ((Econst_int (Int.repr 8) tint) ::
                                   (Econst_int (Int.repr 16) tint) ::
                                   (Econst_int (Int.repr 0) tint) ::
                                   (Econst_int (Int.repr 0) tint) ::
                                   (Econst_int (Int.repr 0) tint) :: nil))
                                Sbreak)
                              LSnil))))))))
              (Ssequence
                (Sset _t'13
                  (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr))))
                (Sifthenelse (Ebinop Oeq
                               (Etempvar _t'13 (tptr (Tstruct _DemoInput noattr)))
                               (Ecast (Econst_int (Int.repr 0) tint)
                                 (tptr tvoid)) tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'30
                        (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                      (Ssequence
                        (Sset _t'31
                          (Efield
                            (Ederef
                              (Etempvar _t'30 (tptr (Tstruct _Area noattr)))
                              (Tstruct _Area noattr)) _musicParam tushort))
                        (Ssequence
                          (Sset _t'32
                            (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                          (Ssequence
                            (Sset _t'33
                              (Efield
                                (Ederef
                                  (Etempvar _t'32 (tptr (Tstruct _Area noattr)))
                                  (Tstruct _Area noattr)) _musicParam2
                                tushort))
                            (Scall None
                              (Evar _set_background_music (Tfunction
                                                            (tushort ::
                                                             tushort ::
                                                             tshort :: nil)
                                                            tvoid cc_default))
                              ((Etempvar _t'31 tushort) ::
                               (Etempvar _t'33 tushort) ::
                               (Econst_int (Int.repr 0) tint) :: nil))))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'28
                          (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                        (Ssequence
                          (Sset _t'29
                            (Efield
                              (Ederef
                                (Etempvar _t'28 (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _flags tuint))
                          (Sifthenelse (Ebinop Oand (Etempvar _t'29 tuint)
                                         (Econst_int (Int.repr 4) tint)
                                         tuint)
                            (Scall None
                              (Evar _play_cap_music (Tfunction
                                                      (tushort :: nil) tvoid
                                                      cc_default))
                              ((Ebinop Oor
                                 (Ebinop Oshl (Econst_int (Int.repr 4) tint)
                                   (Econst_int (Int.repr 8) tint) tint)
                                 (Econst_int (Int.repr 15) tint) tint) ::
                               nil))
                            Sskip)))
                      (Ssequence
                        (Ssequence
                          (Sset _t'26
                            (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                          (Ssequence
                            (Sset _t'27
                              (Efield
                                (Ederef
                                  (Etempvar _t'26 (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _flags tuint))
                            (Sifthenelse (Ebinop Oand (Etempvar _t'27 tuint)
                                           (Ebinop Oor
                                             (Econst_int (Int.repr 2) tint)
                                             (Econst_int (Int.repr 8) tint)
                                             tint) tuint)
                              (Scall None
                                (Evar _play_cap_music (Tfunction
                                                        (tushort :: nil)
                                                        tvoid cc_default))
                                ((Ebinop Oor
                                   (Ebinop Oshl
                                     (Econst_int (Int.repr 4) tint)
                                     (Econst_int (Int.repr 8) tint) tint)
                                   (Econst_int (Int.repr 14) tint) tint) ::
                                 nil))
                              Sskip)))
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Sset _t'25 (Evar _gCurrLevelNum tshort))
                                (Sifthenelse (Ebinop Oeq
                                               (Etempvar _t'25 tshort)
                                               (Econst_int (Int.repr 9) tint)
                                               tint)
                                  (Ssequence
                                    (Scall (Some _t'5)
                                      (Evar _get_current_background_music 
                                      (Tfunction nil tushort cc_default))
                                      nil)
                                    (Sset _t'4
                                      (Ecast
                                        (Ebinop One (Etempvar _t'5 tushort)
                                          (Ebinop Oor
                                            (Ebinop Oshl
                                              (Econst_int (Int.repr 4) tint)
                                              (Econst_int (Int.repr 8) tint)
                                              tint)
                                            (Econst_int (Int.repr 9) tint)
                                            tint) tint) tbool)))
                                  (Sset _t'4 (Econst_int (Int.repr 0) tint))))
                              (Sifthenelse (Etempvar _t'4 tint)
                                (Ssequence
                                  (Sset _t'24 (Evar _sTimerRunning tschar))
                                  (Sset _t'6
                                    (Ecast (Etempvar _t'24 tschar) tbool)))
                                (Sset _t'6 (Econst_int (Int.repr 0) tint))))
                            (Sifthenelse (Etempvar _t'6 tint)
                              (Scall None
                                (Evar _play_music (Tfunction
                                                    (tuchar :: tushort ::
                                                     tushort :: nil) tvoid
                                                    cc_default))
                                ((Econst_int (Int.repr 0) tint) ::
                                 (Ebinop Oor
                                   (Ebinop Oshl
                                     (Econst_int (Int.repr 4) tint)
                                     (Econst_int (Int.repr 8) tint) tint)
                                   (Econst_int (Int.repr 9) tint) tint) ::
                                 (Econst_int (Int.repr 0) tint) :: nil))
                              Sskip))
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Ssequence
                                  (Sset _t'22
                                    (Efield
                                      (Evar _sWarpDest (Tstruct _WarpDest noattr))
                                      _levelNum tuchar))
                                  (Sifthenelse (Ebinop Oeq
                                                 (Etempvar _t'22 tuchar)
                                                 (Econst_int (Int.repr 6) tint)
                                                 tint)
                                    (Ssequence
                                      (Sset _t'23
                                        (Efield
                                          (Evar _sWarpDest (Tstruct _WarpDest noattr))
                                          _areaIdx tuchar))
                                      (Sset _t'7
                                        (Ecast
                                          (Ebinop Oeq (Etempvar _t'23 tuchar)
                                            (Econst_int (Int.repr 1) tint)
                                            tint) tbool)))
                                    (Sset _t'7
                                      (Econst_int (Int.repr 0) tint))))
                                (Sifthenelse (Etempvar _t'7 tint)
                                  (Ssequence
                                    (Sset _t'20
                                      (Efield
                                        (Evar _sWarpDest (Tstruct _WarpDest noattr))
                                        _nodeId tuchar))
                                    (Sifthenelse (Ebinop Oeq
                                                   (Etempvar _t'20 tuchar)
                                                   (Econst_int (Int.repr 31) tint)
                                                   tint)
                                      (Sset _t'8
                                        (Ecast (Econst_int (Int.repr 1) tint)
                                          tbool))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'21
                                            (Efield
                                              (Evar _sWarpDest (Tstruct _WarpDest noattr))
                                              _nodeId tuchar))
                                          (Sset _t'8
                                            (Ecast
                                              (Ebinop Oeq
                                                (Etempvar _t'21 tuchar)
                                                (Econst_int (Int.repr 32) tint)
                                                tint) tbool)))
                                        (Sset _t'8
                                          (Ecast (Etempvar _t'8 tint) tbool)))))
                                  (Sset _t'8 (Econst_int (Int.repr 0) tint))))
                              (Sifthenelse (Etempvar _t'8 tint)
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
                                               (Econst_int (Int.repr 7) tint)
                                               tuint)
                                             (Econst_int (Int.repr 28) tint)
                                             tuint)
                                           (Ebinop Oshl
                                             (Ecast
                                               (Econst_int (Int.repr 29) tint)
                                               tuint)
                                             (Econst_int (Int.repr 16) tint)
                                             tuint) tuint)
                                         (Ebinop Oshl
                                           (Ecast
                                             (Econst_int (Int.repr 176) tint)
                                             tuint)
                                           (Econst_int (Int.repr 8) tint)
                                           tuint) tuint)
                                       (Econst_int (Int.repr 128) tint)
                                       tuint) (Econst_int (Int.repr 1) tint)
                                     tuint) ::
                                   (Evar _gGlobalSoundSource (tarray tfloat 3)) ::
                                   nil))
                                Sskip))
                            (Ssequence
                              (Ssequence
                                (Ssequence
                                  (Sset _t'18
                                    (Efield
                                      (Evar _sWarpDest (Tstruct _WarpDest noattr))
                                      _levelNum tuchar))
                                  (Sifthenelse (Ebinop Oeq
                                                 (Etempvar _t'18 tuchar)
                                                 (Econst_int (Int.repr 16) tint)
                                                 tint)
                                    (Ssequence
                                      (Sset _t'19
                                        (Efield
                                          (Evar _sWarpDest (Tstruct _WarpDest noattr))
                                          _areaIdx tuchar))
                                      (Sset _t'9
                                        (Ecast
                                          (Ebinop Oeq (Etempvar _t'19 tuchar)
                                            (Econst_int (Int.repr 1) tint)
                                            tint) tbool)))
                                    (Sset _t'9
                                      (Econst_int (Int.repr 0) tint))))
                                (Sifthenelse (Etempvar _t'9 tint)
                                  (Ssequence
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'16
                                          (Efield
                                            (Evar _sWarpDest (Tstruct _WarpDest noattr))
                                            _nodeId tuchar))
                                        (Sifthenelse (Ebinop Oeq
                                                       (Etempvar _t'16 tuchar)
                                                       (Econst_int (Int.repr 7) tint)
                                                       tint)
                                          (Sset _t'11
                                            (Econst_int (Int.repr 1) tint))
                                          (Ssequence
                                            (Sset _t'17
                                              (Efield
                                                (Evar _sWarpDest (Tstruct _WarpDest noattr))
                                                _nodeId tuchar))
                                            (Sset _t'11
                                              (Ecast
                                                (Ebinop Oeq
                                                  (Etempvar _t'17 tuchar)
                                                  (Econst_int (Int.repr 10) tint)
                                                  tint) tbool)))))
                                      (Sifthenelse (Etempvar _t'11 tint)
                                        (Sset _t'12
                                          (Econst_int (Int.repr 1) tint))
                                        (Ssequence
                                          (Sset _t'15
                                            (Efield
                                              (Evar _sWarpDest (Tstruct _WarpDest noattr))
                                              _nodeId tuchar))
                                          (Sset _t'12
                                            (Ecast
                                              (Ebinop Oeq
                                                (Etempvar _t'15 tuchar)
                                                (Econst_int (Int.repr 20) tint)
                                                tint) tbool)))))
                                    (Sifthenelse (Etempvar _t'12 tint)
                                      (Sset _t'10
                                        (Ecast (Econst_int (Int.repr 1) tint)
                                          tbool))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'14
                                            (Efield
                                              (Evar _sWarpDest (Tstruct _WarpDest noattr))
                                              _nodeId tuchar))
                                          (Sset _t'10
                                            (Ecast
                                              (Ebinop Oeq
                                                (Etempvar _t'14 tuchar)
                                                (Econst_int (Int.repr 30) tint)
                                                tint) tbool)))
                                        (Sset _t'10
                                          (Ecast (Etempvar _t'10 tint) tbool)))))
                                  (Sset _t'10 (Econst_int (Int.repr 0) tint))))
                              (Sifthenelse (Etempvar _t'10 tint)
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
                                               (Econst_int (Int.repr 7) tint)
                                               tuint)
                                             (Econst_int (Int.repr 28) tint)
                                             tuint)
                                           (Ebinop Oshl
                                             (Ecast
                                               (Econst_int (Int.repr 29) tint)
                                               tuint)
                                             (Econst_int (Int.repr 16) tint)
                                             tuint) tuint)
                                         (Ebinop Oshl
                                           (Ecast
                                             (Econst_int (Int.repr 176) tint)
                                             tuint)
                                           (Econst_int (Int.repr 8) tint)
                                           tuint) tuint)
                                       (Econst_int (Int.repr 128) tint)
                                       tuint) (Econst_int (Int.repr 1) tint)
                                     tuint) ::
                                   (Evar _gGlobalSoundSource (tarray tfloat 3)) ::
                                   nil))
                                Sskip)))))))
                  Sskip)))))))))
|}.

Definition f_warp_area := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'3, tuchar) :: (_t'2, tuchar) :: (_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr)) _type tuchar))
  (Sifthenelse (Ebinop One (Etempvar _t'1 tuchar)
                 (Econst_int (Int.repr 0) tint) tint)
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr)) _type tuchar))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tuchar)
                       (Econst_int (Int.repr 2) tint) tint)
          (Ssequence
            (Scall None
              (Evar _level_control_timer (Tfunction (tint :: nil) tushort
                                           cc_default))
              ((Econst_int (Int.repr 3) tint) :: nil))
            (Ssequence
              (Scall None
                (Evar _unload_mario_area (Tfunction nil tvoid cc_default))
                nil)
              (Ssequence
                (Sset _t'3
                  (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr))
                    _areaIdx tuchar))
                (Scall None
                  (Evar _load_area (Tfunction (tint :: nil) tvoid cc_default))
                  ((Etempvar _t'3 tuchar) :: nil)))))
          Sskip))
      (Scall None
        (Evar _init_mario_after_warp (Tfunction nil tvoid cc_default)) nil))
    Sskip))
|}.

Definition f_warp_level := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, tuchar) :: (_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2
      (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr)) _levelNum tuchar))
    (Sassign (Evar _gCurrLevelNum tshort) (Etempvar _t'2 tuchar)))
  (Ssequence
    (Scall None
      (Evar _level_control_timer (Tfunction (tint :: nil) tushort cc_default))
      ((Econst_int (Int.repr 3) tint) :: nil))
    (Ssequence
      (Ssequence
        (Sset _t'1
          (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr)) _areaIdx
            tuchar))
        (Scall None
          (Evar _load_area (Tfunction (tint :: nil) tvoid cc_default))
          ((Etempvar _t'1 tuchar) :: nil)))
      (Scall None
        (Evar _init_mario_after_warp (Tfunction nil tvoid cc_default)) nil))))
|}.

Definition f_warp_credits := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_marioAction, tint) :: (_t'1, tint) :: (_t'22, tuchar) ::
               (_t'21, tuchar) :: (_t'20, tuchar) :: (_t'19, tshort) ::
               (_t'18, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'17, tshort) ::
               (_t'16, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'15, tshort) ::
               (_t'14, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'13, tschar) ::
               (_t'12, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'11, tuchar) ::
               (_t'10, (tptr (Tstruct _MarioState noattr))) ::
               (_t'9, (tptr (Tstruct _Camera noattr))) ::
               (_t'8, (tptr (Tstruct _Area noattr))) ::
               (_t'7, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'6, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'5, tushort) :: (_t'4, (tptr (Tstruct _Area noattr))) ::
               (_t'3, tushort) :: (_t'2, (tptr (Tstruct _Area noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'22
      (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr)) _nodeId tuchar))
    (Sswitch (Etempvar _t'22 tuchar)
      (LScons (Some 248)
        (Ssequence
          (Sset _marioAction (Econst_int (Int.repr 6424) tint))
          Sbreak)
        (LScons (Some 249)
          (Ssequence
            (Sset _marioAction (Econst_int (Int.repr 4889) tint))
            Sbreak)
          (LScons (Some 250)
            (Ssequence
              (Sset _marioAction (Econst_int (Int.repr 4890) tint))
              Sbreak)
            LSnil)))))
  (Ssequence
    (Ssequence
      (Sset _t'21
        (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr)) _levelNum
          tuchar))
      (Sassign (Evar _gCurrLevelNum tshort) (Etempvar _t'21 tuchar)))
    (Ssequence
      (Ssequence
        (Sset _t'20
          (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr)) _areaIdx
            tuchar))
        (Scall None
          (Evar _load_area (Tfunction (tint :: nil) tvoid cc_default))
          ((Etempvar _t'20 tuchar) :: nil)))
      (Ssequence
        (Ssequence
          (Sset _t'14
            (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
          (Ssequence
            (Sset _t'15
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef
                      (Etempvar _t'14 (tptr (Tstruct _CreditsEntry noattr)))
                      (Tstruct _CreditsEntry noattr)) _marioPos
                    (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                  (tptr tshort)) tshort))
            (Ssequence
              (Sset _t'16
                (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
              (Ssequence
                (Sset _t'17
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _t'16 (tptr (Tstruct _CreditsEntry noattr)))
                          (Tstruct _CreditsEntry noattr)) _marioPos
                        (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tshort)) tshort))
                (Ssequence
                  (Sset _t'18
                    (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
                  (Ssequence
                    (Sset _t'19
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _t'18 (tptr (Tstruct _CreditsEntry noattr)))
                              (Tstruct _CreditsEntry noattr)) _marioPos
                            (tarray tshort 3)) (Econst_int (Int.repr 2) tint)
                          (tptr tshort)) tshort))
                    (Scall None
                      (Evar _vec3s_set (Tfunction
                                         ((tptr tshort) :: tshort ::
                                          tshort :: tshort :: nil)
                                         (tptr tvoid) cc_default))
                      ((Efield
                         (Ederef
                           (Ebinop Oadd
                             (Evar _gPlayerSpawnInfos (tarray (Tstruct _SpawnInfo noattr) 0))
                             (Econst_int (Int.repr 0) tint)
                             (tptr (Tstruct _SpawnInfo noattr)))
                           (Tstruct _SpawnInfo noattr)) _startPos
                         (tarray tshort 3)) :: (Etempvar _t'15 tshort) ::
                       (Etempvar _t'17 tshort) :: (Etempvar _t'19 tshort) ::
                       nil))))))))
        (Ssequence
          (Ssequence
            (Sset _t'12
              (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
            (Ssequence
              (Sset _t'13
                (Efield
                  (Ederef
                    (Etempvar _t'12 (tptr (Tstruct _CreditsEntry noattr)))
                    (Tstruct _CreditsEntry noattr)) _marioAngle tschar))
              (Scall None
                (Evar _vec3s_set (Tfunction
                                   ((tptr tshort) :: tshort :: tshort ::
                                    tshort :: nil) (tptr tvoid) cc_default))
                ((Efield
                   (Ederef
                     (Ebinop Oadd
                       (Evar _gPlayerSpawnInfos (tarray (Tstruct _SpawnInfo noattr) 0))
                       (Econst_int (Int.repr 0) tint)
                       (tptr (Tstruct _SpawnInfo noattr)))
                     (Tstruct _SpawnInfo noattr)) _startAngle
                   (tarray tshort 3)) :: (Econst_int (Int.repr 0) tint) ::
                 (Ebinop Oshl (Etempvar _t'13 tschar)
                   (Econst_int (Int.repr 8) tint) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))))
          (Ssequence
            (Ssequence
              (Sset _t'11
                (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr)) _areaIdx
                  tuchar))
              (Sassign
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Evar _gPlayerSpawnInfos (tarray (Tstruct _SpawnInfo noattr) 0))
                      (Econst_int (Int.repr 0) tint)
                      (tptr (Tstruct _SpawnInfo noattr)))
                    (Tstruct _SpawnInfo noattr)) _areaIndex tschar)
                (Etempvar _t'11 tuchar)))
            (Ssequence
              (Scall None
                (Evar _load_mario_area (Tfunction nil tvoid cc_default)) nil)
              (Ssequence
                (Scall None
                  (Evar _init_mario (Tfunction nil tvoid cc_default)) nil)
                (Ssequence
                  (Ssequence
                    (Sset _t'10
                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                    (Scall None
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _t'10 (tptr (Tstruct _MarioState noattr))) ::
                       (Etempvar _marioAction tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'8
                        (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                      (Ssequence
                        (Sset _t'9
                          (Efield
                            (Ederef
                              (Etempvar _t'8 (tptr (Tstruct _Area noattr)))
                              (Tstruct _Area noattr)) _camera
                            (tptr (Tstruct _Camera noattr))))
                        (Scall None
                          (Evar _reset_camera (Tfunction
                                                ((tptr (Tstruct _Camera noattr)) ::
                                                 nil) tvoid cc_default))
                          ((Etempvar _t'9 (tptr (Tstruct _Camera noattr))) ::
                           nil))))
                    (Ssequence
                      (Sassign
                        (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr))
                          _type tuchar) (Econst_int (Int.repr 0) tint))
                      (Ssequence
                        (Sassign (Evar _sDelayedWarpOp tshort)
                          (Econst_int (Int.repr 0) tint))
                        (Ssequence
                          (Scall None
                            (Evar _play_transition (Tfunction
                                                     (tshort :: tshort ::
                                                      tuchar :: tuchar ::
                                                      tuchar :: nil) tvoid
                                                     cc_default))
                            ((Econst_int (Int.repr 0) tint) ::
                             (Econst_int (Int.repr 20) tint) ::
                             (Econst_int (Int.repr 0) tint) ::
                             (Econst_int (Int.repr 0) tint) ::
                             (Econst_int (Int.repr 0) tint) :: nil))
                          (Ssequence
                            (Ssequence
                              (Sset _t'6
                                (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
                              (Sifthenelse (Ebinop Oeq
                                             (Etempvar _t'6 (tptr (Tstruct _CreditsEntry noattr)))
                                             (Ecast
                                               (Econst_int (Int.repr 0) tint)
                                               (tptr tvoid)) tint)
                                (Sset _t'1 (Econst_int (Int.repr 1) tint))
                                (Ssequence
                                  (Sset _t'7
                                    (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
                                  (Sset _t'1
                                    (Ecast
                                      (Ebinop Oeq
                                        (Etempvar _t'7 (tptr (Tstruct _CreditsEntry noattr)))
                                        (Evar _sCreditsSequence (tarray (Tstruct _CreditsEntry noattr) 23))
                                        tint) tbool)))))
                            (Sifthenelse (Etempvar _t'1 tint)
                              (Ssequence
                                (Sset _t'2
                                  (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                                (Ssequence
                                  (Sset _t'3
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'2 (tptr (Tstruct _Area noattr)))
                                        (Tstruct _Area noattr)) _musicParam
                                      tushort))
                                  (Ssequence
                                    (Sset _t'4
                                      (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                                    (Ssequence
                                      (Sset _t'5
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'4 (tptr (Tstruct _Area noattr)))
                                            (Tstruct _Area noattr))
                                          _musicParam2 tushort))
                                      (Scall None
                                        (Evar _set_background_music (Tfunction
                                                                    (tushort ::
                                                                    tushort ::
                                                                    tshort ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                        ((Etempvar _t'3 tushort) ::
                                         (Etempvar _t'5 tushort) ::
                                         (Econst_int (Int.repr 0) tint) ::
                                         nil))))))
                              Sskip)))))))))))))))
|}.

Definition f_check_instant_warp := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_cameraAngle, tshort) ::
               (_floor, (tptr (Tstruct _Surface noattr))) ::
               (_index, tint) ::
               (_warp, (tptr (Tstruct _InstantWarp noattr))) ::
               (_t'5, (tptr (Tstruct _Surface noattr))) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'52, tshort) :: (_t'51, tshort) ::
               (_t'50, (tptr (Tstruct _Surface noattr))) ::
               (_t'49, (tptr (Tstruct _MarioState noattr))) ::
               (_t'48, tshort) ::
               (_t'47, (tptr (Tstruct _InstantWarp noattr))) ::
               (_t'46, (tptr (Tstruct _Area noattr))) ::
               (_t'45, (tptr (Tstruct _InstantWarp noattr))) ::
               (_t'44, (tptr (Tstruct _Area noattr))) :: (_t'43, tshort) ::
               (_t'42, tfloat) ::
               (_t'41, (tptr (Tstruct _MarioState noattr))) ::
               (_t'40, (tptr (Tstruct _MarioState noattr))) ::
               (_t'39, tshort) :: (_t'38, tfloat) ::
               (_t'37, (tptr (Tstruct _MarioState noattr))) ::
               (_t'36, (tptr (Tstruct _MarioState noattr))) ::
               (_t'35, tshort) :: (_t'34, tfloat) ::
               (_t'33, (tptr (Tstruct _MarioState noattr))) ::
               (_t'32, (tptr (Tstruct _MarioState noattr))) ::
               (_t'31, tfloat) ::
               (_t'30, (tptr (Tstruct _MarioState noattr))) ::
               (_t'29, (tptr (Tstruct _Object noattr))) ::
               (_t'28, (tptr (Tstruct _MarioState noattr))) ::
               (_t'27, tfloat) ::
               (_t'26, (tptr (Tstruct _MarioState noattr))) ::
               (_t'25, (tptr (Tstruct _Object noattr))) ::
               (_t'24, (tptr (Tstruct _MarioState noattr))) ::
               (_t'23, tfloat) ::
               (_t'22, (tptr (Tstruct _MarioState noattr))) ::
               (_t'21, (tptr (Tstruct _Object noattr))) ::
               (_t'20, (tptr (Tstruct _MarioState noattr))) ::
               (_t'19, tshort) :: (_t'18, (tptr (Tstruct _Camera noattr))) ::
               (_t'17, (tptr (Tstruct _Area noattr))) ::
               (_t'16, (tptr (Tstruct _MarioState noattr))) ::
               (_t'15, tuchar) :: (_t'14, (tptr (Tstruct _Area noattr))) ::
               (_t'13, (tptr (Tstruct _MarioState noattr))) ::
               (_t'12, tshort) :: (_t'11, tshort) :: (_t'10, tshort) ::
               (_t'9, (tptr (Tstruct _Camera noattr))) ::
               (_t'8, (tptr (Tstruct _Area noattr))) ::
               (_t'7, (tptr (Tstruct _MarioState noattr))) ::
               (_t'6, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'51 (Evar _gCurrLevelNum tshort))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'51 tshort)
                     (Econst_int (Int.repr 6) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'52 (Evar _gCurrSaveFileNum tshort))
            (Scall (Some _t'2)
              (Evar _save_file_get_total_star_count (Tfunction
                                                      (tint :: tint ::
                                                       tint :: nil) tint
                                                      cc_default))
              ((Ebinop Osub (Etempvar _t'52 tshort)
                 (Econst_int (Int.repr 1) tint) tint) ::
               (Ebinop Osub (Econst_int (Int.repr 1) tint)
                 (Econst_int (Int.repr 1) tint) tint) ::
               (Ebinop Osub (Econst_int (Int.repr 25) tint)
                 (Econst_int (Int.repr 1) tint) tint) :: nil)))
          (Sset _t'1
            (Ecast
              (Ebinop Oge (Etempvar _t'2 tint)
                (Econst_int (Int.repr 70) tint) tint) tbool)))
        (Sset _t'1 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'1 tint) (Sreturn None) Sskip))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'49 (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
        (Ssequence
          (Sset _t'50
            (Efield
              (Ederef (Etempvar _t'49 (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _floor
              (tptr (Tstruct _Surface noattr))))
          (Sset _t'5
            (Ecast (Etempvar _t'50 (tptr (Tstruct _Surface noattr)))
              (tptr (Tstruct _Surface noattr))))))
      (Sset _floor (Etempvar _t'5 (tptr (Tstruct _Surface noattr)))))
    (Sifthenelse (Ebinop One (Etempvar _t'5 (tptr (Tstruct _Surface noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Ssequence
          (Sset _t'48
            (Efield
              (Ederef (Etempvar _floor (tptr (Tstruct _Surface noattr)))
                (Tstruct _Surface noattr)) _type tshort))
          (Sset _index
            (Ebinop Osub (Etempvar _t'48 tshort)
              (Econst_int (Int.repr 27) tint) tint)))
        (Ssequence
          (Ssequence
            (Sifthenelse (Ebinop Oge (Etempvar _index tint)
                           (Econst_int (Int.repr 0) tint) tint)
              (Sset _t'3
                (Ecast
                  (Ebinop Olt (Etempvar _index tint)
                    (Econst_int (Int.repr 4) tint) tint) tbool))
              (Sset _t'3 (Econst_int (Int.repr 0) tint)))
            (Sifthenelse (Etempvar _t'3 tint)
              (Ssequence
                (Sset _t'46
                  (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                (Ssequence
                  (Sset _t'47
                    (Efield
                      (Ederef (Etempvar _t'46 (tptr (Tstruct _Area noattr)))
                        (Tstruct _Area noattr)) _instantWarps
                      (tptr (Tstruct _InstantWarp noattr))))
                  (Sset _t'4
                    (Ecast
                      (Ebinop One
                        (Etempvar _t'47 (tptr (Tstruct _InstantWarp noattr)))
                        (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                        tint) tbool))))
              (Sset _t'4 (Econst_int (Int.repr 0) tint))))
          (Sifthenelse (Etempvar _t'4 tint)
            (Ssequence
              (Ssequence
                (Sset _t'44
                  (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                (Ssequence
                  (Sset _t'45
                    (Efield
                      (Ederef (Etempvar _t'44 (tptr (Tstruct _Area noattr)))
                        (Tstruct _Area noattr)) _instantWarps
                      (tptr (Tstruct _InstantWarp noattr))))
                  (Sset _warp
                    (Ebinop Oadd
                      (Etempvar _t'45 (tptr (Tstruct _InstantWarp noattr)))
                      (Etempvar _index tint)
                      (tptr (Tstruct _InstantWarp noattr))))))
              (Ssequence
                (Sset _t'6
                  (Efield
                    (Ederef
                      (Etempvar _warp (tptr (Tstruct _InstantWarp noattr)))
                      (Tstruct _InstantWarp noattr)) _id tuchar))
                (Sifthenelse (Ebinop One (Etempvar _t'6 tuchar)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'40
                        (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
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
                                    (Tstruct _MarioState noattr)) _pos
                                  (tarray tfloat 3))
                                (Econst_int (Int.repr 0) tint) (tptr tfloat))
                              tfloat))
                          (Ssequence
                            (Sset _t'43
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _warp (tptr (Tstruct _InstantWarp noattr)))
                                      (Tstruct _InstantWarp noattr))
                                    _displacement (tarray tshort 3))
                                  (Econst_int (Int.repr 0) tint)
                                  (tptr tshort)) tshort))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'40 (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _pos
                                    (tarray tfloat 3))
                                  (Econst_int (Int.repr 0) tint)
                                  (tptr tfloat)) tfloat)
                              (Ebinop Oadd (Etempvar _t'42 tfloat)
                                (Etempvar _t'43 tshort) tfloat))))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'36
                          (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
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
                                      (Tstruct _MarioState noattr)) _pos
                                    (tarray tfloat 3))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tfloat)) tfloat))
                            (Ssequence
                              (Sset _t'39
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Etempvar _warp (tptr (Tstruct _InstantWarp noattr)))
                                        (Tstruct _InstantWarp noattr))
                                      _displacement (tarray tshort 3))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr tshort)) tshort))
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'36 (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr)) _pos
                                      (tarray tfloat 3))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr tfloat)) tfloat)
                                (Ebinop Oadd (Etempvar _t'38 tfloat)
                                  (Etempvar _t'39 tshort) tfloat))))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'32
                            (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
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
                                        (Tstruct _MarioState noattr)) _pos
                                      (tarray tfloat 3))
                                    (Econst_int (Int.repr 2) tint)
                                    (tptr tfloat)) tfloat))
                              (Ssequence
                                (Sset _t'35
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Ederef
                                          (Etempvar _warp (tptr (Tstruct _InstantWarp noattr)))
                                          (Tstruct _InstantWarp noattr))
                                        _displacement (tarray tshort 3))
                                      (Econst_int (Int.repr 2) tint)
                                      (tptr tshort)) tshort))
                                (Sassign
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'32 (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr)) _pos
                                        (tarray tfloat 3))
                                      (Econst_int (Int.repr 2) tint)
                                      (tptr tfloat)) tfloat)
                                  (Ebinop Oadd (Etempvar _t'34 tfloat)
                                    (Etempvar _t'35 tshort) tfloat))))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'28
                              (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                            (Ssequence
                              (Sset _t'29
                                (Efield
                                  (Ederef
                                    (Etempvar _t'28 (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _marioObj
                                  (tptr (Tstruct _Object noattr))))
                              (Ssequence
                                (Sset _t'30
                                  (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                (Ssequence
                                  (Sset _t'31
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'30 (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _pos (tarray tfloat 3))
                                        (Econst_int (Int.repr 0) tint)
                                        (tptr tfloat)) tfloat))
                                  (Sassign
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'29 (tptr (Tstruct _Object noattr)))
                                              (Tstruct _Object noattr))
                                            _rawData (Tunion __665 noattr))
                                          _asF32 (tarray tfloat 80))
                                        (Ebinop Oadd
                                          (Econst_int (Int.repr 6) tint)
                                          (Econst_int (Int.repr 0) tint)
                                          tint) (tptr tfloat)) tfloat)
                                    (Etempvar _t'31 tfloat))))))
                          (Ssequence
                            (Ssequence
                              (Sset _t'24
                                (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                              (Ssequence
                                (Sset _t'25
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'24 (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _marioObj
                                    (tptr (Tstruct _Object noattr))))
                                (Ssequence
                                  (Sset _t'26
                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                  (Ssequence
                                    (Sset _t'27
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'26 (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _pos (tarray tfloat 3))
                                          (Econst_int (Int.repr 1) tint)
                                          (tptr tfloat)) tfloat))
                                    (Sassign
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'25 (tptr (Tstruct _Object noattr)))
                                                (Tstruct _Object noattr))
                                              _rawData (Tunion __665 noattr))
                                            _asF32 (tarray tfloat 80))
                                          (Ebinop Oadd
                                            (Econst_int (Int.repr 6) tint)
                                            (Econst_int (Int.repr 1) tint)
                                            tint) (tptr tfloat)) tfloat)
                                      (Etempvar _t'27 tfloat))))))
                            (Ssequence
                              (Ssequence
                                (Sset _t'20
                                  (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                (Ssequence
                                  (Sset _t'21
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'20 (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _marioObj
                                      (tptr (Tstruct _Object noattr))))
                                  (Ssequence
                                    (Sset _t'22
                                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                    (Ssequence
                                      (Sset _t'23
                                        (Ederef
                                          (Ebinop Oadd
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'22 (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _pos (tarray tfloat 3))
                                            (Econst_int (Int.repr 2) tint)
                                            (tptr tfloat)) tfloat))
                                      (Sassign
                                        (Ederef
                                          (Ebinop Oadd
                                            (Efield
                                              (Efield
                                                (Ederef
                                                  (Etempvar _t'21 (tptr (Tstruct _Object noattr)))
                                                  (Tstruct _Object noattr))
                                                _rawData
                                                (Tunion __665 noattr)) _asF32
                                              (tarray tfloat 80))
                                            (Ebinop Oadd
                                              (Econst_int (Int.repr 6) tint)
                                              (Econst_int (Int.repr 2) tint)
                                              tint) (tptr tfloat)) tfloat)
                                        (Etempvar _t'23 tfloat))))))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'16
                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                  (Ssequence
                                    (Sset _t'17
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'16 (tptr (Tstruct _MarioState noattr)))
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
                                              (Etempvar _t'18 (tptr (Tstruct _Camera noattr)))
                                              (Tstruct _Camera noattr)) _yaw
                                            tshort))
                                        (Sset _cameraAngle
                                          (Ecast (Etempvar _t'19 tshort)
                                            tshort))))))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'15
                                      (Efield
                                        (Ederef
                                          (Etempvar _warp (tptr (Tstruct _InstantWarp noattr)))
                                          (Tstruct _InstantWarp noattr))
                                        _area tuchar))
                                    (Scall None
                                      (Evar _change_area (Tfunction
                                                           (tint :: nil)
                                                           tvoid cc_default))
                                      ((Etempvar _t'15 tuchar) :: nil)))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'13
                                        (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                      (Ssequence
                                        (Sset _t'14
                                          (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                                        (Sassign
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'13 (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _area
                                            (tptr (Tstruct _Area noattr)))
                                          (Etempvar _t'14 (tptr (Tstruct _Area noattr))))))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'10
                                          (Ederef
                                            (Ebinop Oadd
                                              (Efield
                                                (Ederef
                                                  (Etempvar _warp (tptr (Tstruct _InstantWarp noattr)))
                                                  (Tstruct _InstantWarp noattr))
                                                _displacement
                                                (tarray tshort 3))
                                              (Econst_int (Int.repr 0) tint)
                                              (tptr tshort)) tshort))
                                        (Ssequence
                                          (Sset _t'11
                                            (Ederef
                                              (Ebinop Oadd
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _warp (tptr (Tstruct _InstantWarp noattr)))
                                                    (Tstruct _InstantWarp noattr))
                                                  _displacement
                                                  (tarray tshort 3))
                                                (Econst_int (Int.repr 1) tint)
                                                (tptr tshort)) tshort))
                                          (Ssequence
                                            (Sset _t'12
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _warp (tptr (Tstruct _InstantWarp noattr)))
                                                      (Tstruct _InstantWarp noattr))
                                                    _displacement
                                                    (tarray tshort 3))
                                                  (Econst_int (Int.repr 2) tint)
                                                  (tptr tshort)) tshort))
                                            (Scall None
                                              (Evar _warp_camera (Tfunction
                                                                   (tfloat ::
                                                                    tfloat ::
                                                                    tfloat ::
                                                                    nil)
                                                                   tvoid
                                                                   cc_default))
                                              ((Etempvar _t'10 tshort) ::
                                               (Etempvar _t'11 tshort) ::
                                               (Etempvar _t'12 tshort) ::
                                               nil)))))
                                      (Ssequence
                                        (Sset _t'7
                                          (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                        (Ssequence
                                          (Sset _t'8
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'7 (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _area
                                              (tptr (Tstruct _Area noattr))))
                                          (Ssequence
                                            (Sset _t'9
                                              (Efield
                                                (Ederef
                                                  (Etempvar _t'8 (tptr (Tstruct _Area noattr)))
                                                  (Tstruct _Area noattr))
                                                _camera
                                                (tptr (Tstruct _Camera noattr))))
                                            (Sassign
                                              (Efield
                                                (Ederef
                                                  (Etempvar _t'9 (tptr (Tstruct _Camera noattr)))
                                                  (Tstruct _Camera noattr))
                                                _yaw tshort)
                                              (Etempvar _cameraAngle tshort)))))))))))))))
                  Sskip)))
            Sskip)))
      Sskip)))
|}.

Definition f_music_changed_through_warp := {|
  fn_return := tshort;
  fn_callconv := cc_default;
  fn_params := ((_arg, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_warpNode, (tptr (Tstruct _ObjectWarpNode noattr))) ::
               (_levelNum, tshort) :: (_destArea, tshort) ::
               (_val4, tshort) :: (_sp2C, tshort) :: (_val8, tushort) ::
               (_val6, tushort) :: (_t'8, tint) :: (_t'7, tint) ::
               (_t'6, tushort) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tushort) ::
               (_t'1, (tptr (Tstruct _ObjectWarpNode noattr))) ::
               (_t'21, tuchar) :: (_t'20, tuchar) :: (_t'19, tshort) ::
               (_t'18, tshort) :: (_t'17, tushort) ::
               (_t'16, (tptr (Tstruct _Area noattr))) :: (_t'15, tushort) ::
               (_t'14, (tptr (Tstruct _Area noattr))) :: (_t'13, tushort) ::
               (_t'12, (tptr (Tstruct _Area noattr))) :: (_t'11, tshort) ::
               (_t'10, tushort) :: (_t'9, (tptr (Tstruct _Area noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _area_get_warp_node (Tfunction (tuchar :: nil)
                                  (tptr (Tstruct _ObjectWarpNode noattr))
                                  cc_default))
      ((Etempvar _arg tshort) :: nil))
    (Sset _warpNode (Etempvar _t'1 (tptr (Tstruct _ObjectWarpNode noattr)))))
  (Ssequence
    (Ssequence
      (Sset _t'21
        (Efield
          (Efield
            (Ederef
              (Etempvar _warpNode (tptr (Tstruct _ObjectWarpNode noattr)))
              (Tstruct _ObjectWarpNode noattr)) _node
            (Tstruct _WarpNode noattr)) _destLevel tuchar))
      (Sset _levelNum
        (Ecast
          (Ebinop Oand (Etempvar _t'21 tuchar)
            (Econst_int (Int.repr 127) tint) tint) tshort)))
    (Ssequence
      (Ssequence
        (Sset _t'20
          (Efield
            (Efield
              (Ederef
                (Etempvar _warpNode (tptr (Tstruct _ObjectWarpNode noattr)))
                (Tstruct _ObjectWarpNode noattr)) _node
              (Tstruct _WarpNode noattr)) _destArea tuchar))
        (Sset _destArea (Ecast (Etempvar _t'20 tuchar) tshort)))
      (Ssequence
        (Sset _val4 (Ecast (Econst_int (Int.repr 1) tint) tshort))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sifthenelse (Ebinop Oeq (Etempvar _levelNum tshort)
                             (Econst_int (Int.repr 9) tint) tint)
                (Ssequence
                  (Sset _t'19 (Evar _gCurrLevelNum tshort))
                  (Sset _t'7
                    (Ecast
                      (Ebinop Oeq (Etempvar _levelNum tshort)
                        (Etempvar _t'19 tshort) tint) tbool)))
                (Sset _t'7 (Econst_int (Int.repr 0) tint)))
              (Sifthenelse (Etempvar _t'7 tint)
                (Ssequence
                  (Sset _t'18 (Evar _gCurrAreaIndex tshort))
                  (Sset _t'8
                    (Ecast
                      (Ebinop Oeq (Etempvar _destArea tshort)
                        (Etempvar _t'18 tshort) tint) tbool)))
                (Sset _t'8 (Econst_int (Int.repr 0) tint))))
            (Sifthenelse (Etempvar _t'8 tint)
              (Ssequence
                (Ssequence
                  (Scall (Some _t'2)
                    (Evar _get_current_background_music (Tfunction nil
                                                          tushort cc_default))
                    nil)
                  (Sset _sp2C (Ecast (Etempvar _t'2 tushort) tshort)))
                (Ssequence
                  (Sifthenelse (Ebinop Oeq (Etempvar _sp2C tshort)
                                 (Ebinop Oor
                                   (Ebinop Oor
                                     (Ebinop Oshl
                                       (Econst_int (Int.repr 4) tint)
                                       (Econst_int (Int.repr 8) tint) tint)
                                     (Econst_int (Int.repr 14) tint) tint)
                                   (Econst_int (Int.repr 128) tint) tint)
                                 tint)
                    (Sset _t'3 (Econst_int (Int.repr 1) tint))
                    (Sset _t'3
                      (Ecast
                        (Ebinop Oeq (Etempvar _sp2C tshort)
                          (Ebinop Oor
                            (Ebinop Oshl (Econst_int (Int.repr 4) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 14) tint) tint) tint)
                        tbool)))
                  (Sifthenelse (Etempvar _t'3 tint)
                    (Sset _val4
                      (Ecast (Econst_int (Int.repr 0) tint) tshort))
                    Sskip)))
              (Ssequence
                (Ssequence
                  (Sset _t'16 (Evar _gAreas (tptr (Tstruct _Area noattr))))
                  (Ssequence
                    (Sset _t'17
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Etempvar _t'16 (tptr (Tstruct _Area noattr)))
                            (Etempvar _destArea tshort)
                            (tptr (Tstruct _Area noattr)))
                          (Tstruct _Area noattr)) _musicParam tushort))
                    (Sset _val8 (Ecast (Etempvar _t'17 tushort) tushort))))
                (Ssequence
                  (Ssequence
                    (Sset _t'14 (Evar _gAreas (tptr (Tstruct _Area noattr))))
                    (Ssequence
                      (Sset _t'15
                        (Efield
                          (Ederef
                            (Ebinop Oadd
                              (Etempvar _t'14 (tptr (Tstruct _Area noattr)))
                              (Etempvar _destArea tshort)
                              (tptr (Tstruct _Area noattr)))
                            (Tstruct _Area noattr)) _musicParam2 tushort))
                      (Sset _val6 (Ecast (Etempvar _t'15 tushort) tushort))))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'11 (Evar _gCurrLevelNum tshort))
                          (Sifthenelse (Ebinop Oeq
                                         (Etempvar _levelNum tshort)
                                         (Etempvar _t'11 tshort) tint)
                            (Ssequence
                              (Sset _t'12
                                (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                              (Ssequence
                                (Sset _t'13
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'12 (tptr (Tstruct _Area noattr)))
                                      (Tstruct _Area noattr)) _musicParam
                                    tushort))
                                (Sset _t'4
                                  (Ecast
                                    (Ebinop Oeq (Etempvar _val8 tushort)
                                      (Etempvar _t'13 tushort) tint) tbool))))
                            (Sset _t'4 (Econst_int (Int.repr 0) tint))))
                        (Sifthenelse (Etempvar _t'4 tint)
                          (Ssequence
                            (Sset _t'9
                              (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                            (Ssequence
                              (Sset _t'10
                                (Efield
                                  (Ederef
                                    (Etempvar _t'9 (tptr (Tstruct _Area noattr)))
                                    (Tstruct _Area noattr)) _musicParam2
                                  tushort))
                              (Sset _t'5
                                (Ecast
                                  (Ebinop Oeq (Etempvar _val6 tushort)
                                    (Etempvar _t'10 tushort) tint) tbool))))
                          (Sset _t'5 (Econst_int (Int.repr 0) tint))))
                      (Sset _val4 (Ecast (Etempvar _t'5 tint) tshort)))
                    (Ssequence
                      (Scall (Some _t'6)
                        (Evar _get_current_background_music (Tfunction nil
                                                              tushort
                                                              cc_default))
                        nil)
                      (Sifthenelse (Ebinop One (Etempvar _t'6 tushort)
                                     (Etempvar _val6 tushort) tint)
                        (Sset _val4
                          (Ecast (Econst_int (Int.repr 0) tint) tshort))
                        Sskip)))))))
          (Sreturn (Some (Etempvar _val4 tshort))))))))
|}.

Definition f_initiate_warp := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_destLevel, tshort) :: (_destArea, tshort) ::
                (_destWarpNode, tshort) :: (_arg3, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tschar) :: (_t'2, (tptr (Tstruct _Area noattr))) ::
               (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Oge (Etempvar _destWarpNode tshort)
                 (Econst_int (Int.repr 248) tint) tint)
    (Sassign
      (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr)) _type tuchar)
      (Econst_int (Int.repr 1) tint))
    (Ssequence
      (Sset _t'1 (Evar _gCurrLevelNum tshort))
      (Sifthenelse (Ebinop One (Etempvar _destLevel tshort)
                     (Etempvar _t'1 tshort) tint)
        (Sassign
          (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr)) _type tuchar)
          (Econst_int (Int.repr 1) tint))
        (Ssequence
          (Sset _t'2 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
          (Ssequence
            (Sset _t'3
              (Efield
                (Ederef (Etempvar _t'2 (tptr (Tstruct _Area noattr)))
                  (Tstruct _Area noattr)) _index tschar))
            (Sifthenelse (Ebinop One (Etempvar _destArea tshort)
                           (Etempvar _t'3 tschar) tint)
              (Sassign
                (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr)) _type
                  tuchar) (Econst_int (Int.repr 2) tint))
              (Sassign
                (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr)) _type
                  tuchar) (Econst_int (Int.repr 3) tint))))))))
  (Ssequence
    (Sassign
      (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr)) _levelNum tuchar)
      (Etempvar _destLevel tshort))
    (Ssequence
      (Sassign
        (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr)) _areaIdx tuchar)
        (Etempvar _destArea tshort))
      (Ssequence
        (Sassign
          (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr)) _nodeId
            tuchar) (Etempvar _destWarpNode tshort))
        (Sassign
          (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr)) _arg tuint)
          (Etempvar _arg3 tint))))))
|}.

Definition f_get_painting_warp_node := {|
  fn_return := (tptr (Tstruct _WarpNode noattr));
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_warpNode, (tptr (Tstruct _WarpNode noattr))) ::
               (_paintingIndex, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'11, tshort) ::
               (_t'10, (tptr (Tstruct _Surface noattr))) ::
               (_t'9, (tptr (Tstruct _MarioState noattr))) ::
               (_t'8, tfloat) ::
               (_t'7, (tptr (Tstruct _MarioState noattr))) ::
               (_t'6, tfloat) ::
               (_t'5, (tptr (Tstruct _MarioState noattr))) ::
               (_t'4, (tptr (Tstruct _WarpNode noattr))) ::
               (_t'3, (tptr (Tstruct _Area noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _warpNode (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Ssequence
      (Sset _t'9 (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
      (Ssequence
        (Sset _t'10
          (Efield
            (Ederef (Etempvar _t'9 (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _floor
            (tptr (Tstruct _Surface noattr))))
        (Ssequence
          (Sset _t'11
            (Efield
              (Ederef (Etempvar _t'10 (tptr (Tstruct _Surface noattr)))
                (Tstruct _Surface noattr)) _type tshort))
          (Sset _paintingIndex
            (Ebinop Osub (Etempvar _t'11 tshort)
              (Econst_int (Int.repr 211) tint) tint)))))
    (Ssequence
      (Ssequence
        (Sifthenelse (Ebinop Oge (Etempvar _paintingIndex tint)
                       (Econst_int (Int.repr 0) tint) tint)
          (Sset _t'2
            (Ecast
              (Ebinop Olt (Etempvar _paintingIndex tint)
                (Econst_int (Int.repr 45) tint) tint) tbool))
          (Sset _t'2 (Econst_int (Int.repr 0) tint)))
        (Sifthenelse (Etempvar _t'2 tint)
          (Ssequence
            (Sifthenelse (Ebinop Olt (Etempvar _paintingIndex tint)
                           (Econst_int (Int.repr 42) tint) tint)
              (Sset _t'1 (Econst_int (Int.repr 1) tint))
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
                          (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tfloat)) tfloat))
                  (Ssequence
                    (Sset _t'7
                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                    (Ssequence
                      (Sset _t'8
                        (Efield
                          (Ederef
                            (Etempvar _t'7 (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _floorHeight
                          tfloat))
                      (Sset _t'1
                        (Ecast
                          (Ebinop Olt
                            (Ebinop Osub (Etempvar _t'6 tfloat)
                              (Etempvar _t'8 tfloat) tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1117782016)) tfloat)
                            tint) tbool)))))))
            (Sifthenelse (Etempvar _t'1 tint)
              (Ssequence
                (Sset _t'3
                  (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                (Ssequence
                  (Sset _t'4
                    (Efield
                      (Ederef (Etempvar _t'3 (tptr (Tstruct _Area noattr)))
                        (Tstruct _Area noattr)) _paintingWarpNodes
                      (tptr (Tstruct _WarpNode noattr))))
                  (Sset _warpNode
                    (Ebinop Oadd
                      (Etempvar _t'4 (tptr (Tstruct _WarpNode noattr)))
                      (Etempvar _paintingIndex tint)
                      (tptr (Tstruct _WarpNode noattr))))))
              Sskip))
          Sskip))
      (Sreturn (Some (Etempvar _warpNode (tptr (Tstruct _WarpNode noattr))))))))
|}.

Definition f_initiate_painting_warp := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_warpNode, (Tstruct _WarpNode noattr)) :: nil);
  fn_temps := ((_pWarpNode, (tptr (Tstruct _WarpNode noattr))) ::
               (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, (tptr (Tstruct _WarpNode noattr))) ::
               (_t'20, (tptr (Tstruct _Surface noattr))) ::
               (_t'19, (tptr (Tstruct _MarioState noattr))) ::
               (_t'18, (tptr (Tstruct _WarpNode noattr))) ::
               (_t'17, (tptr (Tstruct _Area noattr))) :: (_t'16, tuchar) ::
               (_t'15, tuchar) :: (_t'14, tuchar) :: (_t'13, tuchar) ::
               (_t'12, (tptr (Tstruct _MarioState noattr))) ::
               (_t'11, tshort) :: (_t'10, (tptr (Tstruct _Object noattr))) ::
               (_t'9, (tptr (Tstruct _MarioState noattr))) ::
               (_t'8, (tptr (Tstruct _Object noattr))) ::
               (_t'7, (tptr (Tstruct _MarioState noattr))) ::
               (_t'6, tuchar) :: (_t'5, tuint) ::
               (_t'4, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'17 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
    (Ssequence
      (Sset _t'18
        (Efield
          (Ederef (Etempvar _t'17 (tptr (Tstruct _Area noattr)))
            (Tstruct _Area noattr)) _paintingWarpNodes
          (tptr (Tstruct _WarpNode noattr))))
      (Sifthenelse (Ebinop One
                     (Etempvar _t'18 (tptr (Tstruct _WarpNode noattr)))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Ssequence
          (Sset _t'19
            (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
          (Ssequence
            (Sset _t'20
              (Efield
                (Ederef (Etempvar _t'19 (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _floor
                (tptr (Tstruct _Surface noattr))))
            (Sset _t'3
              (Ecast
                (Ebinop One (Etempvar _t'20 (tptr (Tstruct _Surface noattr)))
                  (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
                tbool))))
        (Sset _t'3 (Econst_int (Int.repr 0) tint)))))
  (Sifthenelse (Etempvar _t'3 tint)
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _get_painting_warp_node (Tfunction nil
                                          (tptr (Tstruct _WarpNode noattr))
                                          cc_default)) nil)
        (Sset _pWarpNode (Etempvar _t'1 (tptr (Tstruct _WarpNode noattr)))))
      (Sifthenelse (Ebinop One
                     (Etempvar _pWarpNode (tptr (Tstruct _WarpNode noattr)))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Ssequence
          (Sset _t'4 (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
          (Ssequence
            (Sset _t'5
              (Efield
                (Ederef (Etempvar _t'4 (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _action tuint))
            (Sifthenelse (Ebinop Oand (Etempvar _t'5 tuint)
                           (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                             (Econst_int (Int.repr 12) tint) tint) tuint)
              (Scall None
                (Evar _play_painting_eject_sound (Tfunction nil tvoid
                                                   cc_default)) nil)
              (Ssequence
                (Sset _t'6
                  (Efield
                    (Ederef
                      (Etempvar _pWarpNode (tptr (Tstruct _WarpNode noattr)))
                      (Tstruct _WarpNode noattr)) _id tuchar))
                (Sifthenelse (Ebinop One (Etempvar _t'6 tuchar)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Ssequence
                    (Sassign (Evar _warpNode (Tstruct _WarpNode noattr))
                      (Ederef
                        (Etempvar _pWarpNode (tptr (Tstruct _WarpNode noattr)))
                        (Tstruct _WarpNode noattr)))
                    (Ssequence
                      (Ssequence
                        (Sset _t'16
                          (Efield (Evar _warpNode (Tstruct _WarpNode noattr))
                            _destLevel tuchar))
                        (Sifthenelse (Eunop Onotbool
                                       (Ebinop Oand (Etempvar _t'16 tuchar)
                                         (Econst_int (Int.repr 128) tint)
                                         tint) tint)
                          (Ssequence
                            (Scall (Some _t'2)
                              (Evar _check_warp_checkpoint (Tfunction
                                                             ((tptr (Tstruct _WarpNode noattr)) ::
                                                              nil) tint
                                                             cc_default))
                              ((Eaddrof
                                 (Evar _warpNode (Tstruct _WarpNode noattr))
                                 (tptr (Tstruct _WarpNode noattr))) :: nil))
                            (Sassign (Evar _sWarpCheckpointActive tschar)
                              (Etempvar _t'2 tint)))
                          Sskip))
                      (Ssequence
                        (Ssequence
                          (Sset _t'13
                            (Efield
                              (Evar _warpNode (Tstruct _WarpNode noattr))
                              _destLevel tuchar))
                          (Ssequence
                            (Sset _t'14
                              (Efield
                                (Evar _warpNode (Tstruct _WarpNode noattr))
                                _destArea tuchar))
                            (Ssequence
                              (Sset _t'15
                                (Efield
                                  (Evar _warpNode (Tstruct _WarpNode noattr))
                                  _destNode tuchar))
                              (Scall None
                                (Evar _initiate_warp (Tfunction
                                                       (tshort :: tshort ::
                                                        tshort :: tint ::
                                                        nil) tvoid
                                                       cc_default))
                                ((Ebinop Oand (Etempvar _t'13 tuchar)
                                   (Econst_int (Int.repr 127) tint) tint) ::
                                 (Etempvar _t'14 tuchar) ::
                                 (Etempvar _t'15 tuchar) ::
                                 (Econst_int (Int.repr 0) tint) :: nil)))))
                        (Ssequence
                          (Scall None
                            (Evar _check_if_should_set_warp_checkpoint 
                            (Tfunction
                              ((tptr (Tstruct _WarpNode noattr)) :: nil)
                              tvoid cc_default))
                            ((Eaddrof
                               (Evar _warpNode (Tstruct _WarpNode noattr))
                               (tptr (Tstruct _WarpNode noattr))) :: nil))
                          (Ssequence
                            (Scall None
                              (Evar _play_transition_after_delay (Tfunction
                                                                   (tshort ::
                                                                    tshort ::
                                                                    tuchar ::
                                                                    tuchar ::
                                                                    tuchar ::
                                                                    tshort ::
                                                                    nil)
                                                                   tvoid
                                                                   cc_default))
                              ((Econst_int (Int.repr 1) tint) ::
                               (Econst_int (Int.repr 30) tint) ::
                               (Econst_int (Int.repr 255) tint) ::
                               (Econst_int (Int.repr 255) tint) ::
                               (Econst_int (Int.repr 255) tint) ::
                               (Econst_int (Int.repr 45) tint) :: nil))
                            (Ssequence
                              (Scall None
                                (Evar _level_set_transition (Tfunction
                                                              (tshort ::
                                                               (tptr 
                                                               (Tfunction
                                                                 ((tptr tshort) ::
                                                                  nil) tvoid
                                                                 cc_default)) ::
                                                               nil) tvoid
                                                              cc_default))
                                ((Econst_int (Int.repr 74) tint) ::
                                 (Evar _basic_update (Tfunction
                                                       ((tptr tshort) :: nil)
                                                       tvoid cc_default)) ::
                                 nil))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'12
                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                  (Scall None
                                    (Evar _set_mario_action (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               tuint ::
                                                               tuint :: nil)
                                                              tuint
                                                              cc_default))
                                    ((Etempvar _t'12 (tptr (Tstruct _MarioState noattr))) ::
                                     (Econst_int (Int.repr 4864) tint) ::
                                     (Econst_int (Int.repr 0) tint) :: nil)))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'7
                                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                    (Ssequence
                                      (Sset _t'8
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'7 (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _marioObj
                                          (tptr (Tstruct _Object noattr))))
                                      (Ssequence
                                        (Sset _t'9
                                          (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                        (Ssequence
                                          (Sset _t'10
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'9 (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _marioObj
                                              (tptr (Tstruct _Object noattr))))
                                          (Ssequence
                                            (Sset _t'11
                                              (Efield
                                                (Efield
                                                  (Efield
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
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
                                                        (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                                                        (Tstruct _Object noattr))
                                                      _header
                                                      (Tstruct _ObjectNode noattr))
                                                    _gfx
                                                    (Tstruct _GraphNodeObject noattr))
                                                  _node
                                                  (Tstruct _GraphNode noattr))
                                                _flags tshort)
                                              (Ebinop Oand
                                                (Etempvar _t'11 tshort)
                                                (Eunop Onotint
                                                  (Ebinop Oshl
                                                    (Econst_int (Int.repr 1) tint)
                                                    (Econst_int (Int.repr 0) tint)
                                                    tint) tint) tint)))))))
                                  (Ssequence
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
                                       (Evar _gGlobalSoundSource (tarray tfloat 3)) ::
                                       nil))
                                    (Scall None
                                      (Evar _fadeout_music (Tfunction
                                                             (tshort :: nil)
                                                             tvoid
                                                             cc_default))
                                      ((Econst_int (Int.repr 398) tint) ::
                                       nil)))))))))))
                  Sskip)))))
        Sskip))
    Sskip))
|}.

Definition f_level_trigger_warp := {|
  fn_return := tshort;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_warpOp, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_val04, tint) :: (_t'5, tint) :: (_t'4, tshort) ::
               (_t'3, tshort) :: (_t'2, tshort) ::
               (_t'1, (tptr (Tstruct _ObjectWarpNode noattr))) ::
               (_t'25, tschar) :: (_t'24, tshort) :: (_t'23, tschar) ::
               (_t'22, tint) :: (_t'21, (tptr (Tstruct _Object noattr))) ::
               (_t'20, tint) :: (_t'19, (tptr (Tstruct _Object noattr))) ::
               (_t'18, tshort) :: (_t'17, tuint) :: (_t'16, tint) ::
               (_t'15, (tptr (Tstruct _Object noattr))) :: (_t'14, tshort) ::
               (_t'13, tint) :: (_t'12, (tptr (Tstruct _Object noattr))) ::
               (_t'11, tshort) ::
               (_t'10, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'9, (tptr (Tstruct _DemoInput noattr))) ::
               (_t'8, tshort) :: (_t'7, tshort) :: (_t'6, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _val04 (Econst_int (Int.repr 1) tint))
  (Ssequence
    (Ssequence
      (Sset _t'7 (Evar _sDelayedWarpOp tshort))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'7 tshort)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _invincTimer tshort)
            (Eunop Oneg (Econst_int (Int.repr 1) tint) tint))
          (Ssequence
            (Sassign (Evar _sDelayedWarpArg tint)
              (Econst_int (Int.repr 0) tint))
            (Ssequence
              (Sassign (Evar _sDelayedWarpOp tshort) (Etempvar _warpOp tint))
              (Ssequence
                (Sswitch (Etempvar _warpOp tint)
                  (LScons (Some 22)
                    Sskip
                    (LScons (Some 25)
                      (Ssequence
                        (Sassign (Evar _sDelayedWarpTimer tshort)
                          (Econst_int (Int.repr 20) tint))
                        (Ssequence
                          (Sassign (Evar _sSourceWarpNodeId tshort)
                            (Econst_int (Int.repr 240) tint))
                          (Ssequence
                            (Sassign (Evar _gSavedCourseNum tshort)
                              (Econst_int (Int.repr 0) tint))
                            (Ssequence
                              (Sset _val04 (Econst_int (Int.repr 0) tint))
                              (Ssequence
                                (Scall None
                                  (Evar _play_transition (Tfunction
                                                           (tshort ::
                                                            tshort ::
                                                            tuchar ::
                                                            tuchar ::
                                                            tuchar :: nil)
                                                           tvoid cc_default))
                                  ((Econst_int (Int.repr 9) tint) ::
                                   (Econst_int (Int.repr 20) tint) ::
                                   (Econst_int (Int.repr 0) tint) ::
                                   (Econst_int (Int.repr 0) tint) ::
                                   (Econst_int (Int.repr 0) tint) :: nil))
                                Sbreak)))))
                      (LScons (Some 21)
                        (Ssequence
                          (Sassign (Evar _sDelayedWarpTimer tshort)
                            (Econst_int (Int.repr 60) tint))
                          (Ssequence
                            (Sassign (Evar _sSourceWarpNodeId tshort)
                              (Econst_int (Int.repr 240) tint))
                            (Ssequence
                              (Sset _val04 (Econst_int (Int.repr 0) tint))
                              (Ssequence
                                (Sassign (Evar _gSavedCourseNum tshort)
                                  (Econst_int (Int.repr 0) tint))
                                (Ssequence
                                  (Scall None
                                    (Evar _play_transition (Tfunction
                                                             (tshort ::
                                                              tshort ::
                                                              tuchar ::
                                                              tuchar ::
                                                              tuchar :: nil)
                                                             tvoid
                                                             cc_default))
                                    ((Econst_int (Int.repr 1) tint) ::
                                     (Econst_int (Int.repr 60) tint) ::
                                     (Econst_int (Int.repr 0) tint) ::
                                     (Econst_int (Int.repr 0) tint) ::
                                     (Econst_int (Int.repr 0) tint) :: nil))
                                  Sbreak)))))
                        (LScons (Some 17)
                          (Ssequence
                            (Sassign (Evar _sDelayedWarpTimer tshort)
                              (Econst_int (Int.repr 32) tint))
                            (Ssequence
                              (Sassign (Evar _sSourceWarpNodeId tshort)
                                (Econst_int (Int.repr 240) tint))
                              (Ssequence
                                (Sassign (Evar _gSavedCourseNum tshort)
                                  (Econst_int (Int.repr 0) tint))
                                (Ssequence
                                  (Scall None
                                    (Evar _play_transition (Tfunction
                                                             (tshort ::
                                                              tshort ::
                                                              tuchar ::
                                                              tuchar ::
                                                              tuchar :: nil)
                                                             tvoid
                                                             cc_default))
                                    ((Econst_int (Int.repr 17) tint) ::
                                     (Econst_int (Int.repr 32) tint) ::
                                     (Econst_int (Int.repr 0) tint) ::
                                     (Econst_int (Int.repr 0) tint) ::
                                     (Econst_int (Int.repr 0) tint) :: nil))
                                  Sbreak))))
                          (LScons (Some 18)
                            (Ssequence
                              (Ssequence
                                (Sset _t'25
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _numLives
                                    tschar))
                                (Sifthenelse (Ebinop Oeq
                                               (Etempvar _t'25 tschar)
                                               (Econst_int (Int.repr 0) tint)
                                               tint)
                                  (Sassign (Evar _sDelayedWarpOp tshort)
                                    (Econst_int (Int.repr 20) tint))
                                  Sskip))
                              (Ssequence
                                (Sassign (Evar _sDelayedWarpTimer tshort)
                                  (Econst_int (Int.repr 48) tint))
                                (Ssequence
                                  (Sassign (Evar _sSourceWarpNodeId tshort)
                                    (Econst_int (Int.repr 241) tint))
                                  (Ssequence
                                    (Scall None
                                      (Evar _play_transition (Tfunction
                                                               (tshort ::
                                                                tshort ::
                                                                tuchar ::
                                                                tuchar ::
                                                                tuchar ::
                                                                nil) tvoid
                                                               cc_default))
                                      ((Econst_int (Int.repr 19) tint) ::
                                       (Econst_int (Int.repr 48) tint) ::
                                       (Econst_int (Int.repr 0) tint) ::
                                       (Econst_int (Int.repr 0) tint) ::
                                       (Econst_int (Int.repr 0) tint) :: nil))
                                    (Ssequence
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
                                                     (Econst_int (Int.repr 24) tint)
                                                     tuint)
                                                   (Econst_int (Int.repr 16) tint)
                                                   tuint) tuint)
                                               (Ebinop Oshl
                                                 (Ecast
                                                   (Econst_int (Int.repr 128) tint)
                                                   tuint)
                                                 (Econst_int (Int.repr 8) tint)
                                                 tuint) tuint)
                                             (Econst_int (Int.repr 128) tint)
                                             tuint)
                                           (Econst_int (Int.repr 1) tint)
                                           tuint) ::
                                         (Evar _gGlobalSoundSource (tarray tfloat 3)) ::
                                         nil))
                                      Sbreak)))))
                            (LScons (Some 19)
                              (Ssequence
                                (Sassign (Evar _sSourceWarpNodeId tshort)
                                  (Econst_int (Int.repr 243) tint))
                                (Ssequence
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'24
                                        (Evar _sSourceWarpNodeId tshort))
                                      (Scall (Some _t'1)
                                        (Evar _area_get_warp_node (Tfunction
                                                                    (tuchar ::
                                                                    nil)
                                                                    (tptr (Tstruct _ObjectWarpNode noattr))
                                                                    cc_default))
                                        ((Etempvar _t'24 tshort) :: nil)))
                                    (Sifthenelse (Ebinop Oeq
                                                   (Etempvar _t'1 (tptr (Tstruct _ObjectWarpNode noattr)))
                                                   (Ecast
                                                     (Econst_int (Int.repr 0) tint)
                                                     (tptr tvoid)) tint)
                                      (Ssequence
                                        (Sset _t'23
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _numLives tschar))
                                        (Sifthenelse (Ebinop Oeq
                                                       (Etempvar _t'23 tschar)
                                                       (Econst_int (Int.repr 0) tint)
                                                       tint)
                                          (Sassign
                                            (Evar _sDelayedWarpOp tshort)
                                            (Econst_int (Int.repr 20) tint))
                                          (Sassign
                                            (Evar _sSourceWarpNodeId tshort)
                                            (Econst_int (Int.repr 241) tint))))
                                      Sskip))
                                  (Ssequence
                                    (Sassign (Evar _sDelayedWarpTimer tshort)
                                      (Econst_int (Int.repr 20) tint))
                                    (Ssequence
                                      (Scall None
                                        (Evar _play_transition (Tfunction
                                                                 (tshort ::
                                                                  tshort ::
                                                                  tuchar ::
                                                                  tuchar ::
                                                                  tuchar ::
                                                                  nil) tvoid
                                                                 cc_default))
                                        ((Econst_int (Int.repr 11) tint) ::
                                         (Econst_int (Int.repr 20) tint) ::
                                         (Econst_int (Int.repr 0) tint) ::
                                         (Econst_int (Int.repr 0) tint) ::
                                         (Econst_int (Int.repr 0) tint) ::
                                         nil))
                                      Sbreak))))
                              (LScons (Some 1)
                                (Ssequence
                                  (Sassign (Evar _sDelayedWarpTimer tshort)
                                    (Econst_int (Int.repr 30) tint))
                                  (Ssequence
                                    (Sassign (Evar _sSourceWarpNodeId tshort)
                                      (Econst_int (Int.repr 242) tint))
                                    (Ssequence
                                      (Scall None
                                        (Evar _play_transition (Tfunction
                                                                 (tshort ::
                                                                  tshort ::
                                                                  tuchar ::
                                                                  tuchar ::
                                                                  tuchar ::
                                                                  nil) tvoid
                                                                 cc_default))
                                        ((Econst_int (Int.repr 1) tint) ::
                                         (Econst_int (Int.repr 30) tint) ::
                                         (Econst_int (Int.repr 255) tint) ::
                                         (Econst_int (Int.repr 255) tint) ::
                                         (Econst_int (Int.repr 255) tint) ::
                                         nil))
                                      (Ssequence
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
                                           (Evar _gGlobalSoundSource (tarray tfloat 3)) ::
                                           nil))
                                        Sbreak))))
                                (LScons (Some 2)
                                  (Ssequence
                                    (Sassign (Evar _sDelayedWarpTimer tshort)
                                      (Econst_int (Int.repr 30) tint))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'21
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _usedObj
                                            (tptr (Tstruct _Object noattr))))
                                        (Ssequence
                                          (Sset _t'22
                                            (Ederef
                                              (Ebinop Oadd
                                                (Efield
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _t'21 (tptr (Tstruct _Object noattr)))
                                                      (Tstruct _Object noattr))
                                                    _rawData
                                                    (Tunion __665 noattr))
                                                  _asS32 (tarray tint 80))
                                                (Econst_int (Int.repr 64) tint)
                                                (tptr tint)) tint))
                                          (Sassign
                                            (Evar _sSourceWarpNodeId tshort)
                                            (Ebinop Oshr
                                              (Ebinop Oand
                                                (Etempvar _t'22 tint)
                                                (Econst_int (Int.repr 16711680) tint)
                                                tint)
                                              (Econst_int (Int.repr 16) tint)
                                              tint))))
                                      (Ssequence
                                        (Scall None
                                          (Evar _play_transition (Tfunction
                                                                   (tshort ::
                                                                    tshort ::
                                                                    tuchar ::
                                                                    tuchar ::
                                                                    tuchar ::
                                                                    nil)
                                                                   tvoid
                                                                   cc_default))
                                          ((Econst_int (Int.repr 1) tint) ::
                                           (Econst_int (Int.repr 30) tint) ::
                                           (Econst_int (Int.repr 255) tint) ::
                                           (Econst_int (Int.repr 255) tint) ::
                                           (Econst_int (Int.repr 255) tint) ::
                                           nil))
                                        Sbreak)))
                                  (LScons (Some 5)
                                    (Ssequence
                                      (Sassign
                                        (Evar _sDelayedWarpTimer tshort)
                                        (Econst_int (Int.repr 20) tint))
                                      (Ssequence
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
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Efield
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _t'19 (tptr (Tstruct _Object noattr)))
                                                        (Tstruct _Object noattr))
                                                      _rawData
                                                      (Tunion __665 noattr))
                                                    _asS32 (tarray tint 80))
                                                  (Econst_int (Int.repr 64) tint)
                                                  (tptr tint)) tint))
                                            (Sassign
                                              (Evar _sSourceWarpNodeId tshort)
                                              (Ebinop Oshr
                                                (Ebinop Oand
                                                  (Etempvar _t'20 tint)
                                                  (Econst_int (Int.repr 16711680) tint)
                                                  tint)
                                                (Econst_int (Int.repr 16) tint)
                                                tint))))
                                        (Ssequence
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'18
                                                (Evar _sSourceWarpNodeId tshort))
                                              (Scall (Some _t'2)
                                                (Evar _music_changed_through_warp 
                                                (Tfunction (tshort :: nil)
                                                  tshort cc_default))
                                                ((Etempvar _t'18 tshort) ::
                                                 nil)))
                                            (Sset _val04
                                              (Eunop Onotbool
                                                (Etempvar _t'2 tshort) tint)))
                                          (Ssequence
                                            (Scall None
                                              (Evar _play_transition 
                                              (Tfunction
                                                (tshort :: tshort ::
                                                 tuchar :: tuchar ::
                                                 tuchar :: nil) tvoid
                                                cc_default))
                                              ((Econst_int (Int.repr 1) tint) ::
                                               (Econst_int (Int.repr 20) tint) ::
                                               (Econst_int (Int.repr 255) tint) ::
                                               (Econst_int (Int.repr 255) tint) ::
                                               (Econst_int (Int.repr 255) tint) ::
                                               nil))
                                            Sbreak))))
                                    (LScons (Some 3)
                                      (Ssequence
                                        (Sassign
                                          (Evar _sDelayedWarpTimer tshort)
                                          (Econst_int (Int.repr 20) tint))
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'17
                                              (Efield
                                                (Ederef
                                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                  (Tstruct _MarioState noattr))
                                                _actionArg tuint))
                                            (Sassign
                                              (Evar _sDelayedWarpArg tint)
                                              (Etempvar _t'17 tuint)))
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'15
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                    (Tstruct _MarioState noattr))
                                                  _usedObj
                                                  (tptr (Tstruct _Object noattr))))
                                              (Ssequence
                                                (Sset _t'16
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Efield
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar _t'15 (tptr (Tstruct _Object noattr)))
                                                            (Tstruct _Object noattr))
                                                          _rawData
                                                          (Tunion __665 noattr))
                                                        _asS32
                                                        (tarray tint 80))
                                                      (Econst_int (Int.repr 64) tint)
                                                      (tptr tint)) tint))
                                                (Sassign
                                                  (Evar _sSourceWarpNodeId tshort)
                                                  (Ebinop Oshr
                                                    (Ebinop Oand
                                                      (Etempvar _t'16 tint)
                                                      (Econst_int (Int.repr 16711680) tint)
                                                      tint)
                                                    (Econst_int (Int.repr 16) tint)
                                                    tint))))
                                            (Ssequence
                                              (Ssequence
                                                (Ssequence
                                                  (Sset _t'14
                                                    (Evar _sSourceWarpNodeId tshort))
                                                  (Scall (Some _t'3)
                                                    (Evar _music_changed_through_warp 
                                                    (Tfunction
                                                      (tshort :: nil) tshort
                                                      cc_default))
                                                    ((Etempvar _t'14 tshort) ::
                                                     nil)))
                                                (Sset _val04
                                                  (Eunop Onotbool
                                                    (Etempvar _t'3 tshort)
                                                    tint)))
                                              (Ssequence
                                                (Scall None
                                                  (Evar _play_transition 
                                                  (Tfunction
                                                    (tshort :: tshort ::
                                                     tuchar :: tuchar ::
                                                     tuchar :: nil) tvoid
                                                    cc_default))
                                                  ((Econst_int (Int.repr 11) tint) ::
                                                   (Econst_int (Int.repr 20) tint) ::
                                                   (Econst_int (Int.repr 0) tint) ::
                                                   (Econst_int (Int.repr 0) tint) ::
                                                   (Econst_int (Int.repr 0) tint) ::
                                                   nil))
                                                Sbreak)))))
                                      (LScons (Some 4)
                                        (Ssequence
                                          (Sassign
                                            (Evar _sDelayedWarpTimer tshort)
                                            (Econst_int (Int.repr 20) tint))
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'12
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                    (Tstruct _MarioState noattr))
                                                  _usedObj
                                                  (tptr (Tstruct _Object noattr))))
                                              (Ssequence
                                                (Sset _t'13
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Efield
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar _t'12 (tptr (Tstruct _Object noattr)))
                                                            (Tstruct _Object noattr))
                                                          _rawData
                                                          (Tunion __665 noattr))
                                                        _asS32
                                                        (tarray tint 80))
                                                      (Econst_int (Int.repr 64) tint)
                                                      (tptr tint)) tint))
                                                (Sassign
                                                  (Evar _sSourceWarpNodeId tshort)
                                                  (Ebinop Oshr
                                                    (Ebinop Oand
                                                      (Etempvar _t'13 tint)
                                                      (Econst_int (Int.repr 16711680) tint)
                                                      tint)
                                                    (Econst_int (Int.repr 16) tint)
                                                    tint))))
                                            (Ssequence
                                              (Ssequence
                                                (Ssequence
                                                  (Sset _t'11
                                                    (Evar _sSourceWarpNodeId tshort))
                                                  (Scall (Some _t'4)
                                                    (Evar _music_changed_through_warp 
                                                    (Tfunction
                                                      (tshort :: nil) tshort
                                                      cc_default))
                                                    ((Etempvar _t'11 tshort) ::
                                                     nil)))
                                                (Sset _val04
                                                  (Eunop Onotbool
                                                    (Etempvar _t'4 tshort)
                                                    tint)))
                                              (Ssequence
                                                (Scall None
                                                  (Evar _play_transition 
                                                  (Tfunction
                                                    (tshort :: tshort ::
                                                     tuchar :: tuchar ::
                                                     tuchar :: nil) tvoid
                                                    cc_default))
                                                  ((Econst_int (Int.repr 9) tint) ::
                                                   (Econst_int (Int.repr 20) tint) ::
                                                   (Econst_int (Int.repr 0) tint) ::
                                                   (Econst_int (Int.repr 0) tint) ::
                                                   (Econst_int (Int.repr 0) tint) ::
                                                   nil))
                                                Sbreak))))
                                        (LScons (Some 23)
                                          (Ssequence
                                            (Sassign
                                              (Evar _sDelayedWarpTimer tshort)
                                              (Econst_int (Int.repr 30) tint))
                                            (Ssequence
                                              (Scall None
                                                (Evar _play_transition 
                                                (Tfunction
                                                  (tshort :: tshort ::
                                                   tuchar :: tuchar ::
                                                   tuchar :: nil) tvoid
                                                  cc_default))
                                                ((Econst_int (Int.repr 1) tint) ::
                                                 (Econst_int (Int.repr 30) tint) ::
                                                 (Econst_int (Int.repr 0) tint) ::
                                                 (Econst_int (Int.repr 0) tint) ::
                                                 (Econst_int (Int.repr 0) tint) ::
                                                 nil))
                                              Sbreak))
                                          (LScons (Some 24)
                                            (Ssequence
                                              (Ssequence
                                                (Sset _t'10
                                                  (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
                                                (Sifthenelse (Ebinop Oeq
                                                               (Etempvar _t'10 (tptr (Tstruct _CreditsEntry noattr)))
                                                               (Ebinop Oadd
                                                                 (Evar _sCreditsSequence (tarray (Tstruct _CreditsEntry noattr) 23))
                                                                 (Econst_int (Int.repr 0) tint)
                                                                 (tptr (Tstruct _CreditsEntry noattr)))
                                                               tint)
                                                  (Ssequence
                                                    (Sassign
                                                      (Evar _sDelayedWarpTimer tshort)
                                                      (Econst_int (Int.repr 60) tint))
                                                    (Scall None
                                                      (Evar _play_transition 
                                                      (Tfunction
                                                        (tshort :: tshort ::
                                                         tuchar :: tuchar ::
                                                         tuchar :: nil) tvoid
                                                        cc_default))
                                                      ((Econst_int (Int.repr 1) tint) ::
                                                       (Econst_int (Int.repr 60) tint) ::
                                                       (Econst_int (Int.repr 0) tint) ::
                                                       (Econst_int (Int.repr 0) tint) ::
                                                       (Econst_int (Int.repr 0) tint) ::
                                                       nil)))
                                                  (Ssequence
                                                    (Sassign
                                                      (Evar _sDelayedWarpTimer tshort)
                                                      (Econst_int (Int.repr 20) tint))
                                                    (Scall None
                                                      (Evar _play_transition 
                                                      (Tfunction
                                                        (tshort :: tshort ::
                                                         tuchar :: tuchar ::
                                                         tuchar :: nil) tvoid
                                                        cc_default))
                                                      ((Econst_int (Int.repr 1) tint) ::
                                                       (Econst_int (Int.repr 20) tint) ::
                                                       (Econst_int (Int.repr 0) tint) ::
                                                       (Econst_int (Int.repr 0) tint) ::
                                                       (Econst_int (Int.repr 0) tint) ::
                                                       nil)))))
                                              (Ssequence
                                                (Sset _val04
                                                  (Econst_int (Int.repr 0) tint))
                                                Sbreak))
                                            LSnil))))))))))))))
                (Ssequence
                  (Sifthenelse (Etempvar _val04 tint)
                    (Ssequence
                      (Sset _t'9
                        (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr))))
                      (Sset _t'5
                        (Ecast
                          (Ebinop Oeq
                            (Etempvar _t'9 (tptr (Tstruct _DemoInput noattr)))
                            (Ecast (Econst_int (Int.repr 0) tint)
                              (tptr tvoid)) tint) tbool)))
                    (Sset _t'5 (Econst_int (Int.repr 0) tint)))
                  (Sifthenelse (Etempvar _t'5 tint)
                    (Ssequence
                      (Sset _t'8 (Evar _sDelayedWarpTimer tshort))
                      (Scall None
                        (Evar _fadeout_music (Tfunction (tshort :: nil) tvoid
                                               cc_default))
                        ((Ebinop Osub
                           (Ebinop Omul
                             (Ebinop Odiv
                               (Ebinop Omul (Econst_int (Int.repr 3) tint)
                                 (Etempvar _t'8 tshort) tint)
                               (Econst_int (Int.repr 2) tint) tint)
                             (Econst_int (Int.repr 8) tint) tint)
                           (Econst_int (Int.repr 2) tint) tint) :: nil)))
                    Sskip))))))
        Sskip))
    (Ssequence
      (Sset _t'6 (Evar _sDelayedWarpTimer tshort))
      (Sreturn (Some (Etempvar _t'6 tshort))))))
|}.

Definition f_initiate_delayed_warp := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_warpNode, (tptr (Tstruct _ObjectWarpNode noattr))) ::
               (_destWarpNode, tint) :: (_t'4, tshort) :: (_t'3, tint) ::
               (_t'2, tint) ::
               (_t'1, (tptr (Tstruct _ObjectWarpNode noattr))) ::
               (_t'30, tshort) :: (_t'29, tshort) :: (_t'28, tshort) ::
               (_t'27, tschar) :: (_t'26, tshort) :: (_t'25, tuchar) ::
               (_t'24, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'23, tuchar) ::
               (_t'22, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'21, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'20, tuchar) ::
               (_t'19, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'18, tuchar) ::
               (_t'17, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'16, tuchar) ::
               (_t'15, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'14, tuchar) ::
               (_t'13, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'12, tshort) :: (_t'11, tint) :: (_t'10, tuchar) ::
               (_t'9, tuchar) :: (_t'8, tuchar) :: (_t'7, tuchar) ::
               (_t'6, tshort) ::
               (_t'5, (tptr (Tstruct _DemoInput noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'29 (Evar _sDelayedWarpOp tshort))
    (Sifthenelse (Ebinop One (Etempvar _t'29 tshort)
                   (Econst_int (Int.repr 0) tint) tint)
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'30 (Evar _sDelayedWarpTimer tshort))
            (Sset _t'4
              (Ecast
                (Ebinop Osub (Etempvar _t'30 tshort)
                  (Econst_int (Int.repr 1) tint) tint) tshort)))
          (Sassign (Evar _sDelayedWarpTimer tshort) (Etempvar _t'4 tshort)))
        (Sset _t'3
          (Ecast
            (Ebinop Oeq (Etempvar _t'4 tshort) (Econst_int (Int.repr 0) tint)
              tint) tbool)))
      (Sset _t'3 (Econst_int (Int.repr 0) tint))))
  (Sifthenelse (Etempvar _t'3 tint)
    (Ssequence
      (Scall None
        (Evar _reset_dialog_render_state (Tfunction nil tvoid cc_default))
        nil)
      (Ssequence
        (Ssequence
          (Sset _t'27 (Evar _gDebugLevelSelect tschar))
          (Sifthenelse (Etempvar _t'27 tschar)
            (Ssequence
              (Sset _t'28 (Evar _sDelayedWarpOp tshort))
              (Sset _t'2
                (Ecast
                  (Ebinop Oand (Etempvar _t'28 tshort)
                    (Econst_int (Int.repr 16) tint) tint) tbool)))
            (Sset _t'2 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'2 tint)
          (Scall None
            (Evar _warp_special (Tfunction (tint :: nil) tvoid cc_default))
            ((Eunop Oneg (Econst_int (Int.repr 9) tint) tint) :: nil))
          (Ssequence
            (Sset _t'5
              (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr))))
            (Sifthenelse (Ebinop One
                           (Etempvar _t'5 (tptr (Tstruct _DemoInput noattr)))
                           (Ecast (Econst_int (Int.repr 0) tint)
                             (tptr tvoid)) tint)
              (Ssequence
                (Sset _t'26 (Evar _sDelayedWarpOp tshort))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'26 tshort)
                               (Econst_int (Int.repr 25) tint) tint)
                  (Scall None
                    (Evar _warp_special (Tfunction (tint :: nil) tvoid
                                          cc_default))
                    ((Eunop Oneg (Econst_int (Int.repr 8) tint) tint) :: nil))
                  (Scall None
                    (Evar _warp_special (Tfunction (tint :: nil) tvoid
                                          cc_default))
                    ((Eunop Oneg (Econst_int (Int.repr 2) tint) tint) :: nil))))
              (Ssequence
                (Sset _t'6 (Evar _sDelayedWarpOp tshort))
                (Sswitch (Etempvar _t'6 tshort)
                  (LScons (Some 20)
                    (Ssequence
                      (Scall None
                        (Evar _save_file_reload (Tfunction nil tvoid
                                                  cc_default)) nil)
                      (Ssequence
                        (Scall None
                          (Evar _warp_special (Tfunction (tint :: nil) tvoid
                                                cc_default))
                          ((Eunop Oneg (Econst_int (Int.repr 3) tint) tint) ::
                           nil))
                        Sbreak))
                    (LScons (Some 21)
                      (Ssequence
                        (Scall None
                          (Evar _warp_special (Tfunction (tint :: nil) tvoid
                                                cc_default))
                          ((Eunop Oneg (Econst_int (Int.repr 1) tint) tint) ::
                           nil))
                        (Ssequence
                          (Scall None
                            (Evar _sound_banks_enable (Tfunction
                                                        (tuchar :: tushort ::
                                                         nil) tvoid
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
                                     (Ebinop Oor
                                       (Ebinop Oshl
                                         (Econst_int (Int.repr 1) tint)
                                         (Econst_int (Int.repr 0) tint) tint)
                                       (Ebinop Oshl
                                         (Econst_int (Int.repr 1) tint)
                                         (Econst_int (Int.repr 1) tint) tint)
                                       tint)
                                     (Ebinop Oshl
                                       (Econst_int (Int.repr 1) tint)
                                       (Econst_int (Int.repr 2) tint) tint)
                                     tint)
                                   (Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 3) tint) tint)
                                   tint) tint) tint) :: nil))
                          Sbreak))
                      (LScons (Some 22)
                        (Ssequence
                          (Scall None
                            (Evar _warp_special (Tfunction (tint :: nil)
                                                  tvoid cc_default))
                            ((Eunop Oneg (Econst_int (Int.repr 2) tint) tint) ::
                             nil))
                          Sbreak)
                        (LScons (Some 23)
                          (Ssequence
                            (Sassign
                              (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr)))
                              (Ebinop Oadd
                                (Evar _sCreditsSequence (tarray (Tstruct _CreditsEntry noattr) 23))
                                (Econst_int (Int.repr 0) tint)
                                (tptr (Tstruct _CreditsEntry noattr))))
                            (Ssequence
                              (Ssequence
                                (Sset _t'22
                                  (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
                                (Ssequence
                                  (Sset _t'23
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'22 (tptr (Tstruct _CreditsEntry noattr)))
                                        (Tstruct _CreditsEntry noattr))
                                      _levelNum tuchar))
                                  (Ssequence
                                    (Sset _t'24
                                      (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
                                    (Ssequence
                                      (Sset _t'25
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'24 (tptr (Tstruct _CreditsEntry noattr)))
                                            (Tstruct _CreditsEntry noattr))
                                          _areaIndex tuchar))
                                      (Scall None
                                        (Evar _initiate_warp (Tfunction
                                                               (tshort ::
                                                                tshort ::
                                                                tshort ::
                                                                tint :: nil)
                                                               tvoid
                                                               cc_default))
                                        ((Etempvar _t'23 tuchar) ::
                                         (Etempvar _t'25 tuchar) ::
                                         (Econst_int (Int.repr 248) tint) ::
                                         (Econst_int (Int.repr 0) tint) ::
                                         nil))))))
                              Sbreak))
                          (LScons (Some 24)
                            (Ssequence
                              (Scall None
                                (Evar _sound_banks_disable (Tfunction
                                                             (tuchar ::
                                                              tushort :: nil)
                                                             tvoid
                                                             cc_default))
                                ((Econst_int (Int.repr 2) tint) ::
                                 (Ebinop Osub
                                   (Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 10) tint) tint)
                                   (Econst_int (Int.repr 1) tint) tint) ::
                                 nil))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'21
                                    (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
                                  (Sassign
                                    (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr)))
                                    (Ebinop Oadd
                                      (Etempvar _t'21 (tptr (Tstruct _CreditsEntry noattr)))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr (Tstruct _CreditsEntry noattr)))))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'19
                                      (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
                                    (Ssequence
                                      (Sset _t'20
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'19 (tptr (Tstruct _CreditsEntry noattr)))
                                            (Tstruct _CreditsEntry noattr))
                                          _unk02 tuchar))
                                      (Sassign (Evar _gCurrActNum tshort)
                                        (Ebinop Oand (Etempvar _t'20 tuchar)
                                          (Econst_int (Int.repr 7) tint)
                                          tint))))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'17
                                        (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
                                      (Ssequence
                                        (Sset _t'18
                                          (Efield
                                            (Ederef
                                              (Ebinop Oadd
                                                (Etempvar _t'17 (tptr (Tstruct _CreditsEntry noattr)))
                                                (Econst_int (Int.repr 1) tint)
                                                (tptr (Tstruct _CreditsEntry noattr)))
                                              (Tstruct _CreditsEntry noattr))
                                            _levelNum tuchar))
                                        (Sifthenelse (Ebinop Oeq
                                                       (Etempvar _t'18 tuchar)
                                                       (Econst_int (Int.repr 0) tint)
                                                       tint)
                                          (Sset _destWarpNode
                                            (Econst_int (Int.repr 250) tint))
                                          (Sset _destWarpNode
                                            (Econst_int (Int.repr 249) tint)))))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'13
                                          (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
                                        (Ssequence
                                          (Sset _t'14
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'13 (tptr (Tstruct _CreditsEntry noattr)))
                                                (Tstruct _CreditsEntry noattr))
                                              _levelNum tuchar))
                                          (Ssequence
                                            (Sset _t'15
                                              (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
                                            (Ssequence
                                              (Sset _t'16
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _t'15 (tptr (Tstruct _CreditsEntry noattr)))
                                                    (Tstruct _CreditsEntry noattr))
                                                  _areaIndex tuchar))
                                              (Scall None
                                                (Evar _initiate_warp 
                                                (Tfunction
                                                  (tshort :: tshort ::
                                                   tshort :: tint :: nil)
                                                  tvoid cc_default))
                                                ((Etempvar _t'14 tuchar) ::
                                                 (Etempvar _t'16 tuchar) ::
                                                 (Etempvar _destWarpNode tint) ::
                                                 (Econst_int (Int.repr 0) tint) ::
                                                 nil))))))
                                      Sbreak)))))
                            (LScons None
                              (Ssequence
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'12
                                      (Evar _sSourceWarpNodeId tshort))
                                    (Scall (Some _t'1)
                                      (Evar _area_get_warp_node (Tfunction
                                                                  (tuchar ::
                                                                   nil)
                                                                  (tptr (Tstruct _ObjectWarpNode noattr))
                                                                  cc_default))
                                      ((Etempvar _t'12 tshort) :: nil)))
                                  (Sset _warpNode
                                    (Etempvar _t'1 (tptr (Tstruct _ObjectWarpNode noattr)))))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'8
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _warpNode (tptr (Tstruct _ObjectWarpNode noattr)))
                                            (Tstruct _ObjectWarpNode noattr))
                                          _node (Tstruct _WarpNode noattr))
                                        _destLevel tuchar))
                                    (Ssequence
                                      (Sset _t'9
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar _warpNode (tptr (Tstruct _ObjectWarpNode noattr)))
                                              (Tstruct _ObjectWarpNode noattr))
                                            _node (Tstruct _WarpNode noattr))
                                          _destArea tuchar))
                                      (Ssequence
                                        (Sset _t'10
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _warpNode (tptr (Tstruct _ObjectWarpNode noattr)))
                                                (Tstruct _ObjectWarpNode noattr))
                                              _node
                                              (Tstruct _WarpNode noattr))
                                            _destNode tuchar))
                                        (Ssequence
                                          (Sset _t'11
                                            (Evar _sDelayedWarpArg tint))
                                          (Scall None
                                            (Evar _initiate_warp (Tfunction
                                                                   (tshort ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    tint ::
                                                                    nil)
                                                                   tvoid
                                                                   cc_default))
                                            ((Ebinop Oand
                                               (Etempvar _t'8 tuchar)
                                               (Econst_int (Int.repr 127) tint)
                                               tint) ::
                                             (Etempvar _t'9 tuchar) ::
                                             (Etempvar _t'10 tuchar) ::
                                             (Etempvar _t'11 tint) :: nil))))))
                                  (Ssequence
                                    (Scall None
                                      (Evar _check_if_should_set_warp_checkpoint 
                                      (Tfunction
                                        ((tptr (Tstruct _WarpNode noattr)) ::
                                         nil) tvoid cc_default))
                                      ((Eaddrof
                                         (Efield
                                           (Ederef
                                             (Etempvar _warpNode (tptr (Tstruct _ObjectWarpNode noattr)))
                                             (Tstruct _ObjectWarpNode noattr))
                                           _node (Tstruct _WarpNode noattr))
                                         (tptr (Tstruct _WarpNode noattr))) ::
                                       nil))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'7
                                          (Efield
                                            (Evar _sWarpDest (Tstruct _WarpDest noattr))
                                            _type tuchar))
                                        (Sifthenelse (Ebinop One
                                                       (Etempvar _t'7 tuchar)
                                                       (Econst_int (Int.repr 1) tint)
                                                       tint)
                                          (Scall None
                                            (Evar _level_set_transition 
                                            (Tfunction
                                              (tshort ::
                                               (tptr (Tfunction
                                                       ((tptr tshort) :: nil)
                                                       tvoid cc_default)) ::
                                               nil) tvoid cc_default))
                                            ((Econst_int (Int.repr 2) tint) ::
                                             (Ecast
                                               (Econst_int (Int.repr 0) tint)
                                               (tptr tvoid)) :: nil))
                                          Sskip))
                                      Sbreak))))
                              LSnil)))))))))))))
    Sskip))
|}.

Definition f_update_hud_values := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_numHealthWedges, tshort) :: (_coinSound, tuint) ::
               (_t'1, tint) :: (_t'36, tshort) ::
               (_t'35, (tptr (Tstruct _MarioState noattr))) ::
               (_t'34, tshort) ::
               (_t'33, (tptr (Tstruct _MarioState noattr))) ::
               (_t'32, tshort) :: (_t'31, tshort) :: (_t'30, tshort) ::
               (_t'29, tuint) ::
               (_t'28, (tptr (Tstruct _MarioState noattr))) ::
               (_t'27, tshort) :: (_t'26, (tptr (Tstruct _Object noattr))) ::
               (_t'25, (tptr (Tstruct _MarioState noattr))) ::
               (_t'24, tuint) :: (_t'23, tshort) ::
               (_t'22, (tptr (Tstruct _MarioState noattr))) ::
               (_t'21, tshort) ::
               (_t'20, (tptr (Tstruct _MarioState noattr))) ::
               (_t'19, tschar) ::
               (_t'18, (tptr (Tstruct _MarioState noattr))) ::
               (_t'17, (tptr (Tstruct _MarioState noattr))) ::
               (_t'16, tshort) ::
               (_t'15, (tptr (Tstruct _MarioState noattr))) ::
               (_t'14, tshort) :: (_t'13, tshort) ::
               (_t'12, (tptr (Tstruct _MarioState noattr))) ::
               (_t'11, tschar) ::
               (_t'10, (tptr (Tstruct _MarioState noattr))) ::
               (_t'9, tschar) ::
               (_t'8, (tptr (Tstruct _MarioState noattr))) ::
               (_t'7, tshort) :: (_t'6, tshort) :: (_t'5, tshort) ::
               (_t'4, tuchar) ::
               (_t'3, (tptr (Tstruct _MarioState noattr))) ::
               (_t'2, (tptr (Tstruct _CreditsEntry noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'2 (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
  (Sifthenelse (Ebinop Oeq
                 (Etempvar _t'2 (tptr (Tstruct _CreditsEntry noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'33
            (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
          (Ssequence
            (Sset _t'34
              (Efield
                (Ederef (Etempvar _t'33 (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _health tshort))
            (Sifthenelse (Ebinop Ogt (Etempvar _t'34 tshort)
                           (Econst_int (Int.repr 0) tint) tint)
              (Ssequence
                (Sset _t'35
                  (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                (Ssequence
                  (Sset _t'36
                    (Efield
                      (Ederef
                        (Etempvar _t'35 (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _health tshort))
                  (Sset _t'1
                    (Ecast
                      (Ebinop Oshr (Etempvar _t'36 tshort)
                        (Econst_int (Int.repr 8) tint) tint) tint))))
              (Sset _t'1 (Ecast (Econst_int (Int.repr 0) tint) tint)))))
        (Sset _numHealthWedges (Ecast (Etempvar _t'1 tint) tshort)))
      (Ssequence
        (Ssequence
          (Sset _t'30 (Evar _gCurrCourseNum tshort))
          (Sifthenelse (Ebinop Oge (Etempvar _t'30 tshort)
                         (Econst_int (Int.repr 1) tint) tint)
            (Ssequence
              (Sset _t'32
                (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                  _flags tshort))
              (Sassign
                (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                  _flags tshort)
                (Ebinop Oor (Etempvar _t'32 tshort)
                  (Econst_int (Int.repr 2) tint) tint)))
            (Ssequence
              (Sset _t'31
                (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                  _flags tshort))
              (Sassign
                (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                  _flags tshort)
                (Ebinop Oand (Etempvar _t'31 tshort)
                  (Eunop Onotint (Econst_int (Int.repr 2) tint) tint) tint)))))
        (Ssequence
          (Ssequence
            (Sset _t'21
              (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr)) _coins
                tshort))
            (Ssequence
              (Sset _t'22
                (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
              (Ssequence
                (Sset _t'23
                  (Efield
                    (Ederef
                      (Etempvar _t'22 (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _numCoins tshort))
                (Sifthenelse (Ebinop Olt (Etempvar _t'21 tshort)
                               (Etempvar _t'23 tshort) tint)
                  (Ssequence
                    (Sset _t'24 (Evar _gGlobalTimer tuint))
                    (Sifthenelse (Ebinop Oand (Etempvar _t'24 tuint)
                                   (Econst_int (Int.repr 1) tint) tuint)
                      (Ssequence
                        (Ssequence
                          (Sset _t'28
                            (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                          (Ssequence
                            (Sset _t'29
                              (Efield
                                (Ederef
                                  (Etempvar _t'28 (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _action
                                tuint))
                            (Sifthenelse (Ebinop Oand (Etempvar _t'29 tuint)
                                           (Ebinop Oor
                                             (Ebinop Oshl
                                               (Econst_int (Int.repr 1) tint)
                                               (Econst_int (Int.repr 13) tint)
                                               tint)
                                             (Ebinop Oshl
                                               (Econst_int (Int.repr 1) tint)
                                               (Econst_int (Int.repr 14) tint)
                                               tint) tint) tuint)
                              (Sset _coinSound
                                (Ebinop Oor
                                  (Ebinop Oor
                                    (Ebinop Oor
                                      (Ebinop Oor
                                        (Ebinop Oshl
                                          (Ecast
                                            (Econst_int (Int.repr 3) tint)
                                            tuint)
                                          (Econst_int (Int.repr 28) tint)
                                          tuint)
                                        (Ebinop Oshl
                                          (Ecast
                                            (Econst_int (Int.repr 18) tint)
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
                                      (Econst_int (Int.repr 134217728) tint)
                                      (Econst_int (Int.repr 128) tint) tint)
                                    tuint) (Econst_int (Int.repr 1) tint)
                                  tuint))
                              (Sset _coinSound
                                (Ebinop Oor
                                  (Ebinop Oor
                                    (Ebinop Oor
                                      (Ebinop Oor
                                        (Ebinop Oshl
                                          (Ecast
                                            (Econst_int (Int.repr 3) tint)
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
                                          (Econst_int (Int.repr 128) tint)
                                          tuint)
                                        (Econst_int (Int.repr 8) tint) tuint)
                                      tuint)
                                    (Ebinop Oor
                                      (Econst_int (Int.repr 134217728) tint)
                                      (Econst_int (Int.repr 128) tint) tint)
                                    tuint) (Econst_int (Int.repr 1) tint)
                                  tuint)))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'27
                              (Efield
                                (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                                _coins tshort))
                            (Sassign
                              (Efield
                                (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                                _coins tshort)
                              (Ebinop Oadd (Etempvar _t'27 tshort)
                                (Econst_int (Int.repr 1) tint) tint)))
                          (Ssequence
                            (Sset _t'25
                              (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                            (Ssequence
                              (Sset _t'26
                                (Efield
                                  (Ederef
                                    (Etempvar _t'25 (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _marioObj
                                  (tptr (Tstruct _Object noattr))))
                              (Scall None
                                (Evar _play_sound (Tfunction
                                                    (tint :: (tptr tfloat) ::
                                                     nil) tvoid cc_default))
                                ((Etempvar _coinSound tuint) ::
                                 (Efield
                                   (Efield
                                     (Efield
                                       (Ederef
                                         (Etempvar _t'26 (tptr (Tstruct _Object noattr)))
                                         (Tstruct _Object noattr)) _header
                                       (Tstruct _ObjectNode noattr)) _gfx
                                     (Tstruct _GraphNodeObject noattr))
                                   _cameraToObject (tarray tfloat 3)) :: nil))))))
                      Sskip))
                  Sskip))))
          (Ssequence
            (Ssequence
              (Sset _t'18
                (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
              (Ssequence
                (Sset _t'19
                  (Efield
                    (Ederef
                      (Etempvar _t'18 (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _numLives tschar))
                (Sifthenelse (Ebinop Ogt (Etempvar _t'19 tschar)
                               (Econst_int (Int.repr 100) tint) tint)
                  (Ssequence
                    (Sset _t'20
                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _t'20 (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _numLives tschar)
                      (Econst_int (Int.repr 100) tint)))
                  Sskip)))
            (Ssequence
              (Ssequence
                (Sset _t'15
                  (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                (Ssequence
                  (Sset _t'16
                    (Efield
                      (Ederef
                        (Etempvar _t'15 (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _numCoins tshort))
                  (Sifthenelse (Ebinop Ogt (Etempvar _t'16 tshort)
                                 (Econst_int (Int.repr 999) tint) tint)
                    (Ssequence
                      (Sset _t'17
                        (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _t'17 (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _numCoins tshort)
                        (Econst_int (Int.repr 999) tint)))
                    Sskip)))
              (Ssequence
                (Ssequence
                  (Sset _t'14
                    (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                      _coins tshort))
                  (Sifthenelse (Ebinop Ogt (Etempvar _t'14 tshort)
                                 (Econst_int (Int.repr 999) tint) tint)
                    (Sassign
                      (Efield
                        (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                        _coins tshort) (Econst_int (Int.repr 999) tint))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sset _t'12
                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                    (Ssequence
                      (Sset _t'13
                        (Efield
                          (Ederef
                            (Etempvar _t'12 (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _numStars tshort))
                      (Sassign
                        (Efield
                          (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                          _stars tshort) (Etempvar _t'13 tshort))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'10
                        (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                      (Ssequence
                        (Sset _t'11
                          (Efield
                            (Ederef
                              (Etempvar _t'10 (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _numLives tschar))
                        (Sassign
                          (Efield
                            (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                            _lives tshort) (Etempvar _t'11 tschar))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'8
                          (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                        (Ssequence
                          (Sset _t'9
                            (Efield
                              (Ederef
                                (Etempvar _t'8 (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _numKeys
                              tschar))
                          (Sassign
                            (Efield
                              (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                              _keys tshort) (Etempvar _t'9 tschar))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'7
                            (Efield
                              (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                              _wedges tshort))
                          (Sifthenelse (Ebinop Ogt
                                         (Etempvar _numHealthWedges tshort)
                                         (Etempvar _t'7 tshort) tint)
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
                                           (Econst_int (Int.repr 13) tint)
                                           tuint)
                                         (Econst_int (Int.repr 16) tint)
                                         tuint) tuint)
                                     (Ebinop Oshl
                                       (Ecast (Econst_int (Int.repr 0) tint)
                                         tuint)
                                       (Econst_int (Int.repr 8) tint) tuint)
                                     tuint) (Econst_int (Int.repr 128) tint)
                                   tuint) (Econst_int (Int.repr 1) tint)
                                 tuint) ::
                               (Evar _gGlobalSoundSource (tarray tfloat 3)) ::
                               nil))
                            Sskip))
                        (Ssequence
                          (Sassign
                            (Efield
                              (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                              _wedges tshort)
                            (Etempvar _numHealthWedges tshort))
                          (Ssequence
                            (Sset _t'3
                              (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                            (Ssequence
                              (Sset _t'4
                                (Efield
                                  (Ederef
                                    (Etempvar _t'3 (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr))
                                  _hurtCounter tuchar))
                              (Sifthenelse (Ebinop Ogt (Etempvar _t'4 tuchar)
                                             (Econst_int (Int.repr 0) tint)
                                             tint)
                                (Ssequence
                                  (Sset _t'6
                                    (Efield
                                      (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                                      _flags tshort))
                                  (Sassign
                                    (Efield
                                      (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                                      _flags tshort)
                                    (Ebinop Oor (Etempvar _t'6 tshort)
                                      (Econst_int (Int.repr 32768) tint)
                                      tint)))
                                (Ssequence
                                  (Sset _t'5
                                    (Efield
                                      (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                                      _flags tshort))
                                  (Sassign
                                    (Efield
                                      (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                                      _flags tshort)
                                    (Ebinop Oand (Etempvar _t'5 tshort)
                                      (Eunop Onotint
                                        (Econst_int (Int.repr 32768) tint)
                                        tint) tint)))))))))))))))))
    Sskip))
|}.

Definition f_basic_update := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_arg, (tptr tshort)) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, (tptr (Tstruct _Camera noattr))) ::
               (_t'2, (tptr (Tstruct _Area noattr))) ::
               (_t'1, (tptr (Tstruct _Area noattr))) :: nil);
  fn_body :=
(Ssequence
  (Scall None (Evar _area_update_objects (Tfunction nil tvoid cc_default))
    nil)
  (Ssequence
    (Scall None (Evar _update_hud_values (Tfunction nil tvoid cc_default))
      nil)
    (Ssequence
      (Sset _t'1 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
      (Sifthenelse (Ebinop One (Etempvar _t'1 (tptr (Tstruct _Area noattr)))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Ssequence
          (Sset _t'2 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
          (Ssequence
            (Sset _t'3
              (Efield
                (Ederef (Etempvar _t'2 (tptr (Tstruct _Area noattr)))
                  (Tstruct _Area noattr)) _camera
                (tptr (Tstruct _Camera noattr))))
            (Scall None
              (Evar _update_camera (Tfunction
                                     ((tptr (Tstruct _Camera noattr)) :: nil)
                                     tvoid cc_default))
              ((Etempvar _t'3 (tptr (Tstruct _Camera noattr))) :: nil))))
        Sskip))))
|}.

Definition f_play_mode_normal := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'5, tuint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'25, tshort) ::
               (_t'24, (tptr (Tstruct _MarioState noattr))) ::
               (_t'23, tshort) :: (_t'22, tuchar) :: (_t'21, tushort) ::
               (_t'20, (tptr (Tstruct _Controller noattr))) ::
               (_t'19, (tptr (Tstruct _MarioState noattr))) ::
               (_t'18, tushort) ::
               (_t'17, (tptr (Tstruct _Controller noattr))) ::
               (_t'16, (tptr (Tstruct _DemoInput noattr))) ::
               (_t'15, tushort) :: (_t'14, tschar) :: (_t'13, tushort) ::
               (_t'12, (tptr (Tstruct _Camera noattr))) ::
               (_t'11, (tptr (Tstruct _Area noattr))) ::
               (_t'10, (tptr (Tstruct _Area noattr))) :: (_t'9, tshort) ::
               (_t'8, tshort) :: (_t'7, tuchar) :: (_t'6, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'16 (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr))))
    (Sifthenelse (Ebinop One
                   (Etempvar _t'16 (tptr (Tstruct _DemoInput noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Scall None (Evar _print_intro_text (Tfunction nil tvoid cc_default))
          nil)
        (Ssequence
          (Sset _t'17
            (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
          (Ssequence
            (Sset _t'18
              (Efield
                (Ederef (Etempvar _t'17 (tptr (Tstruct _Controller noattr)))
                  (Tstruct _Controller noattr)) _buttonPressed tushort))
            (Sifthenelse (Ebinop Oand (Etempvar _t'18 tushort)
                           (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                             (Econst_int (Int.repr 7) tint) tint) tint)
              (Ssequence
                (Ssequence
                  (Sset _t'25 (Evar _gCurrLevelNum tshort))
                  (Sifthenelse (Ebinop Oeq (Etempvar _t'25 tshort)
                                 (Econst_int (Int.repr 27) tint) tint)
                    (Sset _t'1 (Ecast (Econst_int (Int.repr 25) tint) tint))
                    (Sset _t'1 (Ecast (Econst_int (Int.repr 22) tint) tint))))
                (Ssequence
                  (Sset _t'24
                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                  (Scall None
                    (Evar _level_trigger_warp (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tint :: nil) tshort
                                                cc_default))
                    ((Etempvar _t'24 (tptr (Tstruct _MarioState noattr))) ::
                     (Etempvar _t'1 tint) :: nil))))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'22
                      (Efield
                        (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                        _isActive tuchar))
                    (Sifthenelse (Eunop Onotbool (Etempvar _t'22 tuchar)
                                   tint)
                      (Ssequence
                        (Sset _t'23 (Evar _sDelayedWarpOp tshort))
                        (Sset _t'2
                          (Ecast
                            (Ebinop Oeq (Etempvar _t'23 tshort)
                              (Econst_int (Int.repr 0) tint) tint) tbool)))
                      (Sset _t'2 (Econst_int (Int.repr 0) tint))))
                  (Sifthenelse (Etempvar _t'2 tint)
                    (Ssequence
                      (Sset _t'20
                        (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
                      (Ssequence
                        (Sset _t'21
                          (Efield
                            (Ederef
                              (Etempvar _t'20 (tptr (Tstruct _Controller noattr)))
                              (Tstruct _Controller noattr)) _buttonPressed
                            tushort))
                        (Sset _t'3
                          (Ecast
                            (Ebinop Oand (Etempvar _t'21 tushort)
                              (Econst_int (Int.repr 4096) tint) tint) tbool))))
                    (Sset _t'3 (Econst_int (Int.repr 0) tint))))
                (Sifthenelse (Etempvar _t'3 tint)
                  (Ssequence
                    (Sset _t'19
                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                    (Scall None
                      (Evar _level_trigger_warp (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tint :: nil) tshort
                                                  cc_default))
                      ((Etempvar _t'19 (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 22) tint) :: nil)))
                  Sskip))))))
      Sskip))
  (Ssequence
    (Scall None (Evar _warp_area (Tfunction nil tvoid cc_default)) nil)
    (Ssequence
      (Scall None (Evar _check_instant_warp (Tfunction nil tvoid cc_default))
        nil)
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'14 (Evar _sTimerRunning tschar))
            (Sifthenelse (Etempvar _t'14 tschar)
              (Ssequence
                (Sset _t'15
                  (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                    _timer tushort))
                (Sset _t'4
                  (Ecast
                    (Ebinop Olt (Etempvar _t'15 tushort)
                      (Econst_int (Int.repr 17999) tint) tint) tbool)))
              (Sset _t'4 (Econst_int (Int.repr 0) tint))))
          (Sifthenelse (Etempvar _t'4 tint)
            (Ssequence
              (Sset _t'13
                (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                  _timer tushort))
              (Sassign
                (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                  _timer tushort)
                (Ebinop Oadd (Etempvar _t'13 tushort)
                  (Econst_int (Int.repr 1) tint) tint)))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _area_update_objects (Tfunction nil tvoid cc_default)) nil)
          (Ssequence
            (Scall None
              (Evar _update_hud_values (Tfunction nil tvoid cc_default)) nil)
            (Ssequence
              (Ssequence
                (Sset _t'10
                  (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                (Sifthenelse (Ebinop One
                               (Etempvar _t'10 (tptr (Tstruct _Area noattr)))
                               (Ecast (Econst_int (Int.repr 0) tint)
                                 (tptr tvoid)) tint)
                  (Ssequence
                    (Sset _t'11
                      (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                    (Ssequence
                      (Sset _t'12
                        (Efield
                          (Ederef
                            (Etempvar _t'11 (tptr (Tstruct _Area noattr)))
                            (Tstruct _Area noattr)) _camera
                          (tptr (Tstruct _Camera noattr))))
                      (Scall None
                        (Evar _update_camera (Tfunction
                                               ((tptr (Tstruct _Camera noattr)) ::
                                                nil) tvoid cc_default))
                        ((Etempvar _t'12 (tptr (Tstruct _Camera noattr))) ::
                         nil))))
                  Sskip))
              (Ssequence
                (Scall None
                  (Evar _initiate_painting_warp (Tfunction nil tvoid
                                                  cc_default)) nil)
                (Ssequence
                  (Scall None
                    (Evar _initiate_delayed_warp (Tfunction nil tvoid
                                                   cc_default)) nil)
                  (Ssequence
                    (Ssequence
                      (Sset _t'6 (Evar _sCurrPlayMode tshort))
                      (Sifthenelse (Ebinop Oeq (Etempvar _t'6 tshort)
                                     (Econst_int (Int.repr 0) tint) tint)
                        (Ssequence
                          (Sset _t'7
                            (Efield
                              (Evar _sWarpDest (Tstruct _WarpDest noattr))
                              _type tuchar))
                          (Sifthenelse (Ebinop Oeq (Etempvar _t'7 tuchar)
                                         (Econst_int (Int.repr 1) tint) tint)
                            (Scall None
                              (Evar _set_play_mode (Tfunction (tshort :: nil)
                                                     tvoid cc_default))
                              ((Econst_int (Int.repr 4) tint) :: nil))
                            (Ssequence
                              (Sset _t'8 (Evar _sTransitionTimer tshort))
                              (Sifthenelse (Ebinop One (Etempvar _t'8 tshort)
                                             (Econst_int (Int.repr 0) tint)
                                             tint)
                                (Scall None
                                  (Evar _set_play_mode (Tfunction
                                                         (tshort :: nil)
                                                         tvoid cc_default))
                                  ((Econst_int (Int.repr 3) tint) :: nil))
                                (Ssequence
                                  (Scall (Some _t'5)
                                    (Evar _pressed_pause (Tfunction nil tuint
                                                           cc_default)) nil)
                                  (Sifthenelse (Etempvar _t'5 tuint)
                                    (Ssequence
                                      (Scall None
                                        (Evar _lower_background_noise 
                                        (Tfunction (tint :: nil) tvoid
                                          cc_default))
                                        ((Econst_int (Int.repr 1) tint) ::
                                         nil))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'9
                                            (Evar _gCameraMovementFlags tshort))
                                          (Sassign
                                            (Evar _gCameraMovementFlags tshort)
                                            (Ebinop Oor
                                              (Etempvar _t'9 tshort)
                                              (Econst_int (Int.repr 32768) tint)
                                              tint)))
                                        (Scall None
                                          (Evar _set_play_mode (Tfunction
                                                                 (tshort ::
                                                                  nil) tvoid
                                                                 cc_default))
                                          ((Econst_int (Int.repr 2) tint) ::
                                           nil))))
                                    Sskip))))))
                        Sskip))
                    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))))
|}.

Definition f_play_mode_paused := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'5, tshort) :: (_t'4, tschar) :: (_t'3, tshort) ::
               (_t'2, tshort) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1 (Evar _gMenuOptSelectIndex tshort))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tshort)
                   (Econst_int (Int.repr 0) tint) tint)
      (Scall None
        (Evar _set_menu_mode (Tfunction (tshort :: nil) tvoid cc_default))
        ((Econst_int (Int.repr 1) tint) :: nil))
      (Ssequence
        (Sset _t'2 (Evar _gMenuOptSelectIndex tshort))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tshort)
                       (Econst_int (Int.repr 1) tint) tint)
          (Ssequence
            (Scall None
              (Evar _raise_background_noise (Tfunction (tint :: nil) tvoid
                                              cc_default))
              ((Econst_int (Int.repr 1) tint) :: nil))
            (Ssequence
              (Ssequence
                (Sset _t'5 (Evar _gCameraMovementFlags tshort))
                (Sassign (Evar _gCameraMovementFlags tshort)
                  (Ebinop Oand (Etempvar _t'5 tshort)
                    (Eunop Onotint (Econst_int (Int.repr 32768) tint) tint)
                    tint)))
              (Scall None
                (Evar _set_play_mode (Tfunction (tshort :: nil) tvoid
                                       cc_default))
                ((Econst_int (Int.repr 0) tint) :: nil))))
          (Ssequence
            (Ssequence
              (Sset _t'4 (Evar _gDebugLevelSelect tschar))
              (Sifthenelse (Etempvar _t'4 tschar)
                (Scall None
                  (Evar _fade_into_special_warp (Tfunction
                                                  (tuint :: tuint :: nil)
                                                  tvoid cc_default))
                  ((Eunop Oneg (Econst_int (Int.repr 9) tint) tint) ::
                   (Econst_int (Int.repr 1) tint) :: nil))
                (Ssequence
                  (Scall None
                    (Evar _initiate_warp (Tfunction
                                           (tshort :: tshort :: tshort ::
                                            tint :: nil) tvoid cc_default))
                    ((Econst_int (Int.repr 6) tint) ::
                     (Econst_int (Int.repr 1) tint) ::
                     (Econst_int (Int.repr 31) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Ssequence
                    (Scall None
                      (Evar _fade_into_special_warp (Tfunction
                                                      (tuint :: tuint :: nil)
                                                      tvoid cc_default))
                      ((Econst_int (Int.repr 0) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    (Sassign (Evar _gSavedCourseNum tshort)
                      (Econst_int (Int.repr 0) tint))))))
            (Ssequence
              (Sset _t'3 (Evar _gCameraMovementFlags tshort))
              (Sassign (Evar _gCameraMovementFlags tshort)
                (Ebinop Oand (Etempvar _t'3 tshort)
                  (Eunop Onotint (Econst_int (Int.repr 32768) tint) tint)
                  tint))))))))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_play_mode_frame_advance := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'7, tshort) :: (_t'6, tshort) :: (_t'5, tshort) ::
               (_t'4, tushort) ::
               (_t'3, (tptr (Tstruct _Controller noattr))) ::
               (_t'2, tushort) ::
               (_t'1, (tptr (Tstruct _Controller noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1
      (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
    (Ssequence
      (Sset _t'2
        (Efield
          (Ederef (Etempvar _t'1 (tptr (Tstruct _Controller noattr)))
            (Tstruct _Controller noattr)) _buttonPressed tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'2 tushort)
                     (Econst_int (Int.repr 1024) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'7 (Evar _gCameraMovementFlags tshort))
            (Sassign (Evar _gCameraMovementFlags tshort)
              (Ebinop Oand (Etempvar _t'7 tshort)
                (Eunop Onotint (Econst_int (Int.repr 32768) tint) tint) tint)))
          (Scall None
            (Evar _play_mode_normal (Tfunction nil tint cc_default)) nil))
        (Ssequence
          (Sset _t'3
            (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef (Etempvar _t'3 (tptr (Tstruct _Controller noattr)))
                  (Tstruct _Controller noattr)) _buttonPressed tushort))
            (Sifthenelse (Ebinop Oand (Etempvar _t'4 tushort)
                           (Econst_int (Int.repr 4096) tint) tint)
              (Ssequence
                (Ssequence
                  (Sset _t'6 (Evar _gCameraMovementFlags tshort))
                  (Sassign (Evar _gCameraMovementFlags tshort)
                    (Ebinop Oand (Etempvar _t'6 tshort)
                      (Eunop Onotint (Econst_int (Int.repr 32768) tint) tint)
                      tint)))
                (Ssequence
                  (Scall None
                    (Evar _raise_background_noise (Tfunction (tint :: nil)
                                                    tvoid cc_default))
                    ((Econst_int (Int.repr 1) tint) :: nil))
                  (Scall None
                    (Evar _set_play_mode (Tfunction (tshort :: nil) tvoid
                                           cc_default))
                    ((Econst_int (Int.repr 0) tint) :: nil))))
              (Ssequence
                (Sset _t'5 (Evar _gCameraMovementFlags tshort))
                (Sassign (Evar _gCameraMovementFlags tshort)
                  (Ebinop Oor (Etempvar _t'5 tshort)
                    (Econst_int (Int.repr 32768) tint) tint)))))))))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_level_set_transition := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_length, tshort) ::
                (_updateFunction,
                 (tptr (Tfunction ((tptr tshort) :: nil) tvoid cc_default))) ::
                nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sassign (Evar _sTransitionTimer tshort) (Etempvar _length tshort))
  (Sassign
    (Evar _sTransitionUpdate (tptr (Tfunction ((tptr tshort) :: nil) tvoid
                                     cc_default)))
    (Etempvar _updateFunction (tptr (Tfunction ((tptr tshort) :: nil) tvoid
                                      cc_default)))))
|}.

Definition f_play_mode_change_area := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'8, (tptr (Tstruct _Camera noattr))) ::
               (_t'7, (tptr (Tstruct _Area noattr))) ::
               (_t'6,
                (tptr (Tfunction ((tptr tshort) :: nil) tvoid cc_default))) ::
               (_t'5,
                (tptr (Tfunction ((tptr tshort) :: nil) tvoid cc_default))) ::
               (_t'4,
                (tptr (Tfunction ((tptr tshort) :: nil) tvoid cc_default))) ::
               (_t'3, tshort) :: (_t'2, tshort) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4
      (Evar _sTransitionUpdate (tptr (Tfunction ((tptr tshort) :: nil) tvoid
                                       cc_default))))
    (Sifthenelse (Ebinop Oeq
                   (Etempvar _t'4 (tptr (Tfunction ((tptr tshort) :: nil)
                                          tvoid cc_default)))
                   (Ecast (Eunop Oneg (Econst_int (Int.repr 1) tint) tint)
                     (tptr (Tfunction ((tptr tshort) :: nil) tvoid
                             cc_default))) tint)
      (Ssequence
        (Sset _t'7 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
        (Ssequence
          (Sset _t'8
            (Efield
              (Ederef (Etempvar _t'7 (tptr (Tstruct _Area noattr)))
                (Tstruct _Area noattr)) _camera
              (tptr (Tstruct _Camera noattr))))
          (Scall None
            (Evar _update_camera (Tfunction
                                   ((tptr (Tstruct _Camera noattr)) :: nil)
                                   tvoid cc_default))
            ((Etempvar _t'8 (tptr (Tstruct _Camera noattr))) :: nil))))
      (Ssequence
        (Sset _t'5
          (Evar _sTransitionUpdate (tptr (Tfunction ((tptr tshort) :: nil)
                                           tvoid cc_default))))
        (Sifthenelse (Ebinop One
                       (Etempvar _t'5 (tptr (Tfunction ((tptr tshort) :: nil)
                                              tvoid cc_default)))
                       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                       tint)
          (Ssequence
            (Sset _t'6
              (Evar _sTransitionUpdate (tptr (Tfunction
                                               ((tptr tshort) :: nil) tvoid
                                               cc_default))))
            (Scall None
              (Etempvar _t'6 (tptr (Tfunction ((tptr tshort) :: nil) tvoid
                                     cc_default)))
              ((Eaddrof (Evar _sTransitionTimer tshort) (tptr tshort)) ::
               nil)))
          Sskip))))
  (Ssequence
    (Ssequence
      (Sset _t'2 (Evar _sTransitionTimer tshort))
      (Sifthenelse (Ebinop Ogt (Etempvar _t'2 tshort)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Sset _t'3 (Evar _sTransitionTimer tshort))
          (Sassign (Evar _sTransitionTimer tshort)
            (Ebinop Osub (Etempvar _t'3 tshort)
              (Econst_int (Int.repr 1) tint) tint)))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'1 (Evar _sTransitionTimer tshort))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tshort)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Sassign
              (Evar _sTransitionUpdate (tptr (Tfunction
                                               ((tptr tshort) :: nil) tvoid
                                               cc_default)))
              (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
            (Scall None
              (Evar _set_play_mode (Tfunction (tshort :: nil) tvoid
                                     cc_default))
              ((Econst_int (Int.repr 0) tint) :: nil)))
          Sskip))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_play_mode_change_level := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tshort) ::
               (_t'7,
                (tptr (Tfunction ((tptr tshort) :: nil) tvoid cc_default))) ::
               (_t'6,
                (tptr (Tfunction ((tptr tshort) :: nil) tvoid cc_default))) ::
               (_t'5, tshort) :: (_t'4, tuchar) :: (_t'3, tshort) ::
               (_t'2, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6
      (Evar _sTransitionUpdate (tptr (Tfunction ((tptr tshort) :: nil) tvoid
                                       cc_default))))
    (Sifthenelse (Ebinop One
                   (Etempvar _t'6 (tptr (Tfunction ((tptr tshort) :: nil)
                                          tvoid cc_default)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Sset _t'7
          (Evar _sTransitionUpdate (tptr (Tfunction ((tptr tshort) :: nil)
                                           tvoid cc_default))))
        (Scall None
          (Etempvar _t'7 (tptr (Tfunction ((tptr tshort) :: nil) tvoid
                                 cc_default)))
          ((Eaddrof (Evar _sTransitionTimer tshort) (tptr tshort)) :: nil)))
      Sskip))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'5 (Evar _sTransitionTimer tshort))
          (Sset _t'1
            (Ecast
              (Ebinop Osub (Etempvar _t'5 tshort)
                (Econst_int (Int.repr 1) tint) tint) tshort)))
        (Sassign (Evar _sTransitionTimer tshort) (Etempvar _t'1 tshort)))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tshort)
                     (Eunop Oneg (Econst_int (Int.repr 1) tint) tint) tint)
        (Ssequence
          (Sassign
            (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr)) _flags
              tshort) (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Sassign (Evar _sTransitionTimer tshort)
              (Econst_int (Int.repr 0) tint))
            (Ssequence
              (Sassign
                (Evar _sTransitionUpdate (tptr (Tfunction
                                                 ((tptr tshort) :: nil) tvoid
                                                 cc_default)))
                (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
              (Ssequence
                (Sset _t'2
                  (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr)) _type
                    tuchar))
                (Sifthenelse (Ebinop One (Etempvar _t'2 tuchar)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Ssequence
                    (Sset _t'4
                      (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr))
                        _levelNum tuchar))
                    (Sreturn (Some (Etempvar _t'4 tuchar))))
                  (Ssequence
                    (Sset _t'3 (Evar _D_80339EE0 tshort))
                    (Sreturn (Some (Etempvar _t'3 tshort)))))))))
        Sskip))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_update_level := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_changeLevel, tint) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'6, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6 (Evar _sCurrPlayMode tshort))
    (Sswitch (Etempvar _t'6 tshort)
      (LScons (Some 0)
        (Ssequence
          (Ssequence
            (Scall (Some _t'1)
              (Evar _play_mode_normal (Tfunction nil tint cc_default)) nil)
            (Sset _changeLevel (Etempvar _t'1 tint)))
          Sbreak)
        (LScons (Some 2)
          (Ssequence
            (Ssequence
              (Scall (Some _t'2)
                (Evar _play_mode_paused (Tfunction nil tint cc_default)) nil)
              (Sset _changeLevel (Etempvar _t'2 tint)))
            Sbreak)
          (LScons (Some 3)
            (Ssequence
              (Ssequence
                (Scall (Some _t'3)
                  (Evar _play_mode_change_area (Tfunction nil tint
                                                 cc_default)) nil)
                (Sset _changeLevel (Etempvar _t'3 tint)))
              Sbreak)
            (LScons (Some 4)
              (Ssequence
                (Ssequence
                  (Scall (Some _t'4)
                    (Evar _play_mode_change_level (Tfunction nil tint
                                                    cc_default)) nil)
                  (Sset _changeLevel (Etempvar _t'4 tint)))
                Sbreak)
              (LScons (Some 5)
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'5)
                      (Evar _play_mode_frame_advance (Tfunction nil tint
                                                       cc_default)) nil)
                    (Sset _changeLevel (Etempvar _t'5 tint)))
                  Sbreak)
                LSnil)))))))
  (Ssequence
    (Sifthenelse (Etempvar _changeLevel tint)
      (Ssequence
        (Scall None (Evar _reset_volume (Tfunction nil tvoid cc_default))
          nil)
        (Scall None
          (Evar _enable_background_sound (Tfunction nil tvoid cc_default))
          nil))
      Sskip)
    (Sreturn (Some (Etempvar _changeLevel tint)))))
|}.

Definition f_init_level := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_val4, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'24, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'23, tuchar) :: (_t'22, tschar) ::
               (_t'21, (tptr (Tstruct _Camera noattr))) ::
               (_t'20, (tptr (Tstruct _Area noattr))) ::
               (_t'19, (tptr (Tstruct _MarioState noattr))) ::
               (_t'18, tshort) ::
               (_t'17, (tptr (Tstruct _MarioState noattr))) ::
               (_t'16, (tptr (Tstruct _MarioState noattr))) ::
               (_t'15, tuint) ::
               (_t'14, (tptr (Tstruct _MarioState noattr))) ::
               (_t'13, tschar) ::
               (_t'12, (tptr (Tstruct _DemoInput noattr))) ::
               (_t'11, (tptr (Tstruct _Area noattr))) :: (_t'10, tushort) ::
               (_t'9, (tptr (Tstruct _Area noattr))) :: (_t'8, tushort) ::
               (_t'7, (tptr (Tstruct _Area noattr))) ::
               (_t'6, (tptr (Tstruct _DemoInput noattr))) ::
               (_t'5, tuchar) :: (_t'4, tuint) ::
               (_t'3, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _val4 (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Scall None
      (Evar _set_play_mode (Tfunction (tshort :: nil) tvoid cc_default))
      ((Econst_int (Int.repr 0) tint) :: nil))
    (Ssequence
      (Sassign (Evar _sDelayedWarpOp tshort) (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Sassign (Evar _sTransitionTimer tshort)
          (Econst_int (Int.repr 0) tint))
        (Ssequence
          (Sassign (Evar _D_80339EE0 tshort) (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'24
                  (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
                (Sifthenelse (Ebinop Oeq
                               (Etempvar _t'24 (tptr (Tstruct _CreditsEntry noattr)))
                               (Ecast (Econst_int (Int.repr 0) tint)
                                 (tptr tvoid)) tint)
                  (Sset _t'1 (Ecast (Econst_int (Int.repr 63) tint) tint))
                  (Sset _t'1 (Ecast (Econst_int (Int.repr 0) tint) tint))))
              (Sassign
                (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                  _flags tshort) (Etempvar _t'1 tint)))
            (Ssequence
              (Sassign (Evar _sTimerRunning tschar)
                (Econst_int (Int.repr 0) tint))
              (Ssequence
                (Ssequence
                  (Sset _t'5
                    (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr))
                      _type tuchar))
                  (Sifthenelse (Ebinop One (Etempvar _t'5 tuchar)
                                 (Econst_int (Int.repr 0) tint) tint)
                    (Ssequence
                      (Sset _t'23
                        (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr))
                          _nodeId tuchar))
                      (Sifthenelse (Ebinop Oge (Etempvar _t'23 tuchar)
                                     (Econst_int (Int.repr 248) tint) tint)
                        (Scall None
                          (Evar _warp_credits (Tfunction nil tvoid
                                                cc_default)) nil)
                        (Scall None
                          (Evar _warp_level (Tfunction nil tvoid cc_default))
                          nil)))
                    (Ssequence
                      (Ssequence
                        (Sset _t'22
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Evar _gPlayerSpawnInfos (tarray (Tstruct _SpawnInfo noattr) 0))
                                (Econst_int (Int.repr 0) tint)
                                (tptr (Tstruct _SpawnInfo noattr)))
                              (Tstruct _SpawnInfo noattr)) _areaIndex tschar))
                        (Sifthenelse (Ebinop Oge (Etempvar _t'22 tschar)
                                       (Econst_int (Int.repr 0) tint) tint)
                          (Ssequence
                            (Scall None
                              (Evar _load_mario_area (Tfunction nil tvoid
                                                       cc_default)) nil)
                            (Scall None
                              (Evar _init_mario (Tfunction nil tvoid
                                                  cc_default)) nil))
                          Sskip))
                      (Ssequence
                        (Ssequence
                          (Sset _t'11
                            (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                          (Sifthenelse (Ebinop One
                                         (Etempvar _t'11 (tptr (Tstruct _Area noattr)))
                                         (Ecast
                                           (Econst_int (Int.repr 0) tint)
                                           (tptr tvoid)) tint)
                            (Ssequence
                              (Ssequence
                                (Sset _t'20
                                  (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                                (Ssequence
                                  (Sset _t'21
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'20 (tptr (Tstruct _Area noattr)))
                                        (Tstruct _Area noattr)) _camera
                                      (tptr (Tstruct _Camera noattr))))
                                  (Scall None
                                    (Evar _reset_camera (Tfunction
                                                          ((tptr (Tstruct _Camera noattr)) ::
                                                           nil) tvoid
                                                          cc_default))
                                    ((Etempvar _t'21 (tptr (Tstruct _Camera noattr))) ::
                                     nil))))
                              (Ssequence
                                (Sset _t'12
                                  (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr))))
                                (Sifthenelse (Ebinop One
                                               (Etempvar _t'12 (tptr (Tstruct _DemoInput noattr)))
                                               (Ecast
                                                 (Econst_int (Int.repr 0) tint)
                                                 (tptr tvoid)) tint)
                                  (Ssequence
                                    (Sset _t'19
                                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                    (Scall None
                                      (Evar _set_mario_action (Tfunction
                                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                                 tuint ::
                                                                 tuint ::
                                                                 nil) tuint
                                                                cc_default))
                                      ((Etempvar _t'19 (tptr (Tstruct _MarioState noattr))) ::
                                       (Econst_int (Int.repr 205521409) tint) ::
                                       (Econst_int (Int.repr 0) tint) :: nil)))
                                  (Ssequence
                                    (Sset _t'13
                                      (Evar _gDebugLevelSelect tschar))
                                    (Sifthenelse (Eunop Onotbool
                                                   (Etempvar _t'13 tschar)
                                                   tint)
                                      (Ssequence
                                        (Sset _t'14
                                          (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                        (Ssequence
                                          (Sset _t'15
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'14 (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _action tuint))
                                          (Sifthenelse (Ebinop One
                                                         (Etempvar _t'15 tuint)
                                                         (Econst_int (Int.repr 0) tint)
                                                         tint)
                                            (Ssequence
                                              (Ssequence
                                                (Sset _t'18
                                                  (Evar _gCurrSaveFileNum tshort))
                                                (Scall (Some _t'2)
                                                  (Evar _save_file_exists 
                                                  (Tfunction (tint :: nil)
                                                    tint cc_default))
                                                  ((Ebinop Osub
                                                     (Etempvar _t'18 tshort)
                                                     (Econst_int (Int.repr 1) tint)
                                                     tint) :: nil)))
                                              (Sifthenelse (Etempvar _t'2 tint)
                                                (Ssequence
                                                  (Sset _t'17
                                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                  (Scall None
                                                    (Evar _set_mario_action 
                                                    (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: tuint :: nil)
                                                      tuint cc_default))
                                                    ((Etempvar _t'17 (tptr (Tstruct _MarioState noattr))) ::
                                                     (Econst_int (Int.repr 205521409) tint) ::
                                                     (Econst_int (Int.repr 0) tint) ::
                                                     nil)))
                                                (Ssequence
                                                  (Ssequence
                                                    (Sset _t'16
                                                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                    (Scall None
                                                      (Evar _set_mario_action 
                                                      (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         tuint :: tuint ::
                                                         nil) tuint
                                                        cc_default))
                                                      ((Etempvar _t'16 (tptr (Tstruct _MarioState noattr))) ::
                                                       (Econst_int (Int.repr 67113729) tint) ::
                                                       (Econst_int (Int.repr 0) tint) ::
                                                       nil)))
                                                  (Sset _val4
                                                    (Econst_int (Int.repr 1) tint)))))
                                            Sskip)))
                                      Sskip)))))
                            Sskip))
                        (Ssequence
                          (Sifthenelse (Etempvar _val4 tint)
                            (Scall None
                              (Evar _play_transition (Tfunction
                                                       (tshort :: tshort ::
                                                        tuchar :: tuchar ::
                                                        tuchar :: nil) tvoid
                                                       cc_default))
                              ((Econst_int (Int.repr 0) tint) ::
                               (Econst_int (Int.repr 90) tint) ::
                               (Econst_int (Int.repr 255) tint) ::
                               (Econst_int (Int.repr 255) tint) ::
                               (Econst_int (Int.repr 255) tint) :: nil))
                            (Scall None
                              (Evar _play_transition (Tfunction
                                                       (tshort :: tshort ::
                                                        tuchar :: tuchar ::
                                                        tuchar :: nil) tvoid
                                                       cc_default))
                              ((Econst_int (Int.repr 8) tint) ::
                               (Econst_int (Int.repr 16) tint) ::
                               (Econst_int (Int.repr 255) tint) ::
                               (Econst_int (Int.repr 255) tint) ::
                               (Econst_int (Int.repr 255) tint) :: nil)))
                          (Ssequence
                            (Sset _t'6
                              (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr))))
                            (Sifthenelse (Ebinop Oeq
                                           (Etempvar _t'6 (tptr (Tstruct _DemoInput noattr)))
                                           (Ecast
                                             (Econst_int (Int.repr 0) tint)
                                             (tptr tvoid)) tint)
                              (Ssequence
                                (Sset _t'7
                                  (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                                (Ssequence
                                  (Sset _t'8
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'7 (tptr (Tstruct _Area noattr)))
                                        (Tstruct _Area noattr)) _musicParam
                                      tushort))
                                  (Ssequence
                                    (Sset _t'9
                                      (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                                    (Ssequence
                                      (Sset _t'10
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'9 (tptr (Tstruct _Area noattr)))
                                            (Tstruct _Area noattr))
                                          _musicParam2 tushort))
                                      (Scall None
                                        (Evar _set_background_music (Tfunction
                                                                    (tushort ::
                                                                    tushort ::
                                                                    tshort ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                        ((Etempvar _t'8 tushort) ::
                                         (Etempvar _t'10 tushort) ::
                                         (Econst_int (Int.repr 0) tint) ::
                                         nil))))))
                              Sskip)))))))
                (Ssequence
                  (Ssequence
                    (Sset _t'3
                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                    (Ssequence
                      (Sset _t'4
                        (Efield
                          (Ederef
                            (Etempvar _t'3 (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _action tuint))
                      (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tuint)
                                     (Econst_int (Int.repr 67113729) tint)
                                     tint)
                        (Scall None
                          (Evar _sound_banks_disable (Tfunction
                                                       (tuchar :: tushort ::
                                                        nil) tvoid
                                                       cc_default))
                          ((Econst_int (Int.repr 2) tint) ::
                           (Ebinop Oor
                             (Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                   (Econst_int (Int.repr 4) tint) tint)
                                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                   (Econst_int (Int.repr 5) tint) tint) tint)
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 8) tint) tint) tint)
                             (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                               (Econst_int (Int.repr 9) tint) tint) tint) ::
                           nil))
                        Sskip)))
                  (Sreturn (Some (Econst_int (Int.repr 1) tint))))))))))))
|}.

Definition f_lvl_init_or_update := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_initOrUpdate, tshort) :: (_unused, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_result, tint) :: (_t'2, tint) :: (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _result (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sswitch (Etempvar _initOrUpdate tshort)
      (LScons (Some 0)
        (Ssequence
          (Ssequence
            (Scall (Some _t'1)
              (Evar _init_level (Tfunction nil tint cc_default)) nil)
            (Sset _result (Etempvar _t'1 tint)))
          Sbreak)
        (LScons (Some 1)
          (Ssequence
            (Ssequence
              (Scall (Some _t'2)
                (Evar _update_level (Tfunction nil tint cc_default)) nil)
              (Sset _result (Etempvar _t'2 tint)))
            Sbreak)
          LSnil)))
    (Sreturn (Some (Etempvar _result tint)))))
|}.

Definition f_lvl_init_from_save_file := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_arg0, tshort) :: (_levelNum, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Efield (Evar _sWarpDest (Tstruct _WarpDest noattr)) _type tuchar)
    (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sassign (Evar _sDelayedWarpOp tshort) (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _gCurrSaveFileNum tshort))
          (Scall (Some _t'1)
            (Evar _save_file_exists (Tfunction (tint :: nil) tint cc_default))
            ((Ebinop Osub (Etempvar _t'2 tshort)
               (Econst_int (Int.repr 1) tint) tint) :: nil)))
        (Sassign (Evar _gNeverEnteredCastle tschar)
          (Eunop Onotbool (Etempvar _t'1 tint) tint)))
      (Ssequence
        (Sassign (Evar _gCurrLevelNum tshort) (Etempvar _levelNum tint))
        (Ssequence
          (Sassign (Evar _gCurrCourseNum tshort)
            (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Sassign (Evar _gSavedCourseNum tshort)
              (Econst_int (Int.repr 0) tint))
            (Ssequence
              (Sassign
                (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr)))
                (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
              (Ssequence
                (Sassign (Evar _gSpecialTripleJump tuchar)
                  (Econst_int (Int.repr 0) tint))
                (Ssequence
                  (Scall None
                    (Evar _init_mario_from_save_file (Tfunction nil tvoid
                                                       cc_default)) nil)
                  (Ssequence
                    (Scall None
                      (Evar _disable_warp_checkpoint (Tfunction nil tvoid
                                                       cc_default)) nil)
                    (Ssequence
                      (Scall None
                        (Evar _save_file_move_cap_to_default_location 
                        (Tfunction nil tvoid cc_default)) nil)
                      (Ssequence
                        (Scall None
                          (Evar _select_mario_cam_mode (Tfunction nil tvoid
                                                         cc_default)) nil)
                        (Ssequence
                          (Scall None
                            (Evar _set_yoshi_as_not_dead (Tfunction nil tvoid
                                                           cc_default)) nil)
                          (Sreturn (Some (Etempvar _levelNum tint))))))))))))))))
|}.

Definition f_lvl_set_current_level := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_arg0, tshort) :: (_levelNum, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_warpCheckpointActive, tint) :: (_t'7, tint) ::
               (_t'6, tint) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tuint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'23, tschar) ::
               (_t'22, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'21, (tptr (Tstruct _DemoInput noattr))) ::
               (_t'20, tshort) :: (_t'19, tshort) :: (_t'18, tshort) ::
               (_t'17, tshort) ::
               (_t'16, (tptr (Tstruct _MarioState noattr))) ::
               (_t'15, tshort) :: (_t'14, tshort) :: (_t'13, tshort) ::
               (_t'12, tshort) :: (_t'11, tshort) :: (_t'10, tshort) ::
               (_t'9, tschar) :: (_t'8, tschar) :: nil);
  fn_body :=
(Ssequence
  (Sset _warpCheckpointActive (Evar _sWarpCheckpointActive tschar))
  (Ssequence
    (Sassign (Evar _sWarpCheckpointActive tschar)
      (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Sassign (Evar _gCurrLevelNum tshort) (Etempvar _levelNum tint))
      (Ssequence
        (Ssequence
          (Sset _t'23
            (Ederef
              (Ebinop Oadd (Evar _gLevelToCourseNumTable (tarray tschar 0))
                (Ebinop Osub (Etempvar _levelNum tint)
                  (Econst_int (Int.repr 1) tint) tint) (tptr tschar)) tschar))
          (Sassign (Evar _gCurrCourseNum tshort) (Etempvar _t'23 tschar)))
        (Ssequence
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'21
                  (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr))))
                (Sifthenelse (Ebinop One
                               (Etempvar _t'21 (tptr (Tstruct _DemoInput noattr)))
                               (Ecast (Econst_int (Int.repr 0) tint)
                                 (tptr tvoid)) tint)
                  (Sset _t'1 (Econst_int (Int.repr 1) tint))
                  (Ssequence
                    (Sset _t'22
                      (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
                    (Sset _t'1
                      (Ecast
                        (Ebinop One
                          (Etempvar _t'22 (tptr (Tstruct _CreditsEntry noattr)))
                          (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                          tint) tbool)))))
              (Sifthenelse (Etempvar _t'1 tint)
                (Sset _t'2 (Econst_int (Int.repr 1) tint))
                (Ssequence
                  (Sset _t'20 (Evar _gCurrCourseNum tshort))
                  (Sset _t'2
                    (Ecast
                      (Ebinop Oeq (Etempvar _t'20 tshort)
                        (Econst_int (Int.repr 0) tint) tint) tbool)))))
            (Sifthenelse (Etempvar _t'2 tint)
              (Sreturn (Some (Econst_int (Int.repr 0) tint)))
              Sskip))
          (Ssequence
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'18 (Evar _gCurrLevelNum tshort))
                  (Sifthenelse (Ebinop One (Etempvar _t'18 tshort)
                                 (Econst_int (Int.repr 30) tint) tint)
                    (Ssequence
                      (Sset _t'19 (Evar _gCurrLevelNum tshort))
                      (Sset _t'4
                        (Ecast
                          (Ebinop One (Etempvar _t'19 tshort)
                            (Econst_int (Int.repr 33) tint) tint) tbool)))
                    (Sset _t'4 (Econst_int (Int.repr 0) tint))))
                (Sifthenelse (Etempvar _t'4 tint)
                  (Ssequence
                    (Sset _t'17 (Evar _gCurrLevelNum tshort))
                    (Sset _t'5
                      (Ecast
                        (Ebinop One (Etempvar _t'17 tshort)
                          (Econst_int (Int.repr 34) tint) tint) tbool)))
                  (Sset _t'5 (Econst_int (Int.repr 0) tint))))
              (Sifthenelse (Etempvar _t'5 tint)
                (Ssequence
                  (Ssequence
                    (Sset _t'16
                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _t'16 (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _numCoins tshort)
                      (Econst_int (Int.repr 0) tint)))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                        _coins tshort) (Econst_int (Int.repr 0) tint))
                    (Ssequence
                      (Ssequence
                        (Sset _t'14 (Evar _gCurrSaveFileNum tshort))
                        (Ssequence
                          (Sset _t'15 (Evar _gCurrCourseNum tshort))
                          (Scall (Some _t'3)
                            (Evar _save_file_get_star_flags (Tfunction
                                                              (tint ::
                                                               tint :: nil)
                                                              tuint
                                                              cc_default))
                            ((Ebinop Osub (Etempvar _t'14 tshort)
                               (Econst_int (Int.repr 1) tint) tint) ::
                             (Ebinop Osub (Etempvar _t'15 tshort)
                               (Econst_int (Int.repr 1) tint) tint) :: nil))))
                      (Sassign (Evar _gCurrCourseStarFlags tuchar)
                        (Etempvar _t'3 tuint)))))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'11 (Evar _gSavedCourseNum tshort))
                (Ssequence
                  (Sset _t'12 (Evar _gCurrCourseNum tshort))
                  (Sifthenelse (Ebinop One (Etempvar _t'11 tshort)
                                 (Etempvar _t'12 tshort) tint)
                    (Ssequence
                      (Ssequence
                        (Sset _t'13 (Evar _gCurrCourseNum tshort))
                        (Sassign (Evar _gSavedCourseNum tshort)
                          (Etempvar _t'13 tshort)))
                      (Ssequence
                        (Scall None
                          (Evar _nop_change_course (Tfunction nil tvoid
                                                     cc_default)) nil)
                        (Scall None
                          (Evar _disable_warp_checkpoint (Tfunction nil tvoid
                                                           cc_default)) nil)))
                    Sskip)))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'10 (Evar _gCurrCourseNum tshort))
                    (Sifthenelse (Ebinop Ogt (Etempvar _t'10 tshort)
                                   (Econst_int (Int.repr 15) tint) tint)
                      (Sset _t'6 (Econst_int (Int.repr 1) tint))
                      (Sset _t'6
                        (Ecast (Etempvar _warpCheckpointActive tint) tbool))))
                  (Sifthenelse (Etempvar _t'6 tint)
                    (Sreturn (Some (Econst_int (Int.repr 0) tint)))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'8 (Evar _gDebugLevelSelect tschar))
                      (Sifthenelse (Etempvar _t'8 tschar)
                        (Ssequence
                          (Sset _t'9 (Evar _gShowProfiler tschar))
                          (Sset _t'7
                            (Ecast
                              (Eunop Onotbool (Etempvar _t'9 tschar) tint)
                              tbool)))
                        (Sset _t'7 (Econst_int (Int.repr 0) tint))))
                    (Sifthenelse (Etempvar _t'7 tint)
                      (Sreturn (Some (Econst_int (Int.repr 0) tint)))
                      Sskip))
                  (Sreturn (Some (Econst_int (Int.repr 1) tint))))))))))))
|}.

Definition f_lvl_play_the_end_screen_sound := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_arg0, tshort) :: (_arg1, tint) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                        cc_default))
    ((Ebinop Oor
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 7) tint) tuint)
               (Econst_int (Int.repr 28) tint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 31) tint) tuint)
               (Econst_int (Int.repr 16) tint) tuint) tuint)
           (Ebinop Oshl (Ecast (Econst_int (Int.repr 255) tint) tuint)
             (Econst_int (Int.repr 8) tint) tuint) tuint)
         (Econst_int (Int.repr 128) tint) tuint)
       (Econst_int (Int.repr 1) tint) tuint) ::
     (Evar _gGlobalSoundSource (tarray tfloat 3)) :: nil))
  (Sreturn (Some (Econst_int (Int.repr 1) tint))))
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
 Composite _CreditsEntry Struct
   (Member_plain _levelNum tuchar :: Member_plain _areaIndex tuchar ::
    Member_plain _unk02 tuchar :: Member_plain _marioAngle tschar ::
    Member_plain _marioPos (tarray tshort 3) ::
    Member_plain _unk0C (tptr (tptr tschar)) :: nil)
   noattr ::
 Composite _WarpDest Struct
   (Member_plain _type tuchar :: Member_plain _levelNum tuchar ::
    Member_plain _areaIdx tuchar :: Member_plain _nodeId tuchar ::
    Member_plain _arg tuint :: nil)
   noattr ::
 Composite _HudDisplay Struct
   (Member_plain _lives tshort :: Member_plain _coins tshort ::
    Member_plain _stars tshort :: Member_plain _wedges tshort ::
    Member_plain _keys tshort :: Member_plain _flags tshort ::
    Member_plain _timer tushort :: nil)
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
 Composite _DemoInput Struct
   (Member_plain _timer tuchar :: Member_plain _rawStickX tschar ::
    Member_plain _rawStickY tschar :: Member_plain _buttonMask tuchar :: nil)
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
 Composite _WarpTransitionData Struct
   (Member_plain _red tuchar :: Member_plain _green tuchar ::
    Member_plain _blue tuchar :: Member_plain _startTexRadius tshort ::
    Member_plain _endTexRadius tshort :: Member_plain _startTexX tshort ::
    Member_plain _startTexY tshort :: Member_plain _endTexX tshort ::
    Member_plain _endTexY tshort :: Member_plain _texTimer tshort :: nil)
   noattr ::
 Composite _WarpTransition Struct
   (Member_plain _isActive tuchar :: Member_plain _type tuchar ::
    Member_plain _time tuchar :: Member_plain _pauseRendering tuchar ::
    Member_plain _data (Tstruct _WarpTransitionData noattr) :: nil)
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
     cc_default)) :: (___stringlit_6, Gvar v___stringlit_6) ::
 (___stringlit_18, Gvar v___stringlit_18) ::
 (___stringlit_10, Gvar v___stringlit_10) ::
 (___stringlit_35, Gvar v___stringlit_35) ::
 (___stringlit_23, Gvar v___stringlit_23) ::
 (___stringlit_4, Gvar v___stringlit_4) ::
 (___stringlit_17, Gvar v___stringlit_17) ::
 (___stringlit_27, Gvar v___stringlit_27) ::
 (___stringlit_47, Gvar v___stringlit_47) ::
 (___stringlit_30, Gvar v___stringlit_30) ::
 (___stringlit_32, Gvar v___stringlit_32) ::
 (___stringlit_42, Gvar v___stringlit_42) ::
 (___stringlit_21, Gvar v___stringlit_21) ::
 (___stringlit_40, Gvar v___stringlit_40) ::
 (___stringlit_45, Gvar v___stringlit_45) ::
 (___stringlit_2, Gvar v___stringlit_2) ::
 (___stringlit_13, Gvar v___stringlit_13) ::
 (___stringlit_28, Gvar v___stringlit_28) ::
 (___stringlit_8, Gvar v___stringlit_8) ::
 (___stringlit_60, Gvar v___stringlit_60) ::
 (___stringlit_36, Gvar v___stringlit_36) ::
 (___stringlit_53, Gvar v___stringlit_53) ::
 (___stringlit_55, Gvar v___stringlit_55) ::
 (___stringlit_9, Gvar v___stringlit_9) ::
 (___stringlit_50, Gvar v___stringlit_50) ::
 (___stringlit_3, Gvar v___stringlit_3) ::
 (___stringlit_48, Gvar v___stringlit_48) ::
 (___stringlit_44, Gvar v___stringlit_44) ::
 (___stringlit_5, Gvar v___stringlit_5) ::
 (___stringlit_33, Gvar v___stringlit_33) ::
 (___stringlit_39, Gvar v___stringlit_39) ::
 (___stringlit_16, Gvar v___stringlit_16) ::
 (___stringlit_25, Gvar v___stringlit_25) ::
 (___stringlit_38, Gvar v___stringlit_38) ::
 (___stringlit_24, Gvar v___stringlit_24) ::
 (___stringlit_41, Gvar v___stringlit_41) ::
 (___stringlit_58, Gvar v___stringlit_58) ::
 (___stringlit_11, Gvar v___stringlit_11) ::
 (___stringlit_22, Gvar v___stringlit_22) ::
 (___stringlit_12, Gvar v___stringlit_12) ::
 (___stringlit_14, Gvar v___stringlit_14) ::
 (___stringlit_57, Gvar v___stringlit_57) ::
 (___stringlit_51, Gvar v___stringlit_51) ::
 (___stringlit_46, Gvar v___stringlit_46) ::
 (___stringlit_52, Gvar v___stringlit_52) ::
 (___stringlit_19, Gvar v___stringlit_19) ::
 (___stringlit_31, Gvar v___stringlit_31) ::
 (___stringlit_49, Gvar v___stringlit_49) ::
 (___stringlit_59, Gvar v___stringlit_59) ::
 (___stringlit_7, Gvar v___stringlit_7) ::
 (___stringlit_1, Gvar v___stringlit_1) ::
 (___stringlit_15, Gvar v___stringlit_15) ::
 (___stringlit_26, Gvar v___stringlit_26) ::
 (___stringlit_43, Gvar v___stringlit_43) ::
 (___stringlit_37, Gvar v___stringlit_37) ::
 (___stringlit_29, Gvar v___stringlit_29) ::
 (___stringlit_54, Gvar v___stringlit_54) ::
 (___stringlit_56, Gvar v___stringlit_56) ::
 (___stringlit_20, Gvar v___stringlit_20) ::
 (___stringlit_34, Gvar v___stringlit_34) ::
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
 (_gGlobalSoundSource, Gvar v_gGlobalSoundSource) ::
 (_play_sound,
   Gfun(External (EF_external "play_sound"
                   (mksignature (AST.Xint :: AST.Xptr :: nil) AST.Xvoid
                     cc_default)) (tint :: (tptr tfloat) :: nil) tvoid
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
 (_get_current_background_music,
   Gfun(External (EF_external "get_current_background_music"
                   (mksignature nil AST.Xint16unsigned cc_default)) nil
     tushort cc_default)) ::
 (_gCurrCreditsEntry, Gvar v_gCurrCreditsEntry) ::
 (_gPlayer1Controller, Gvar v_gPlayer1Controller) ::
 (_gCurrDemoInput, Gvar v_gCurrDemoInput) ::
 (_gGlobalTimer, Gvar v_gGlobalTimer) ::
 (_gDebugLevelSelect, Gvar v_gDebugLevelSelect) ::
 (_gShowProfiler, Gvar v_gShowProfiler) ::
 (_gSineTable, Gvar v_gSineTable) ::
 (_vec3s_set,
   Gfun(External (EF_external "vec3s_set"
                   (mksignature
                     (AST.Xptr :: AST.Xint16signed :: AST.Xint16signed ::
                      AST.Xint16signed :: nil) AST.Xptr cc_default))
     ((tptr tshort) :: tshort :: tshort :: tshort :: nil) (tptr tvoid)
     cc_default)) :: (_gCameraMovementFlags, Gvar v_gCameraMovementFlags) ::
 (_update_camera,
   Gfun(External (EF_external "update_camera"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _Camera noattr)) :: nil) tvoid cc_default)) ::
 (_reset_camera,
   Gfun(External (EF_external "reset_camera"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _Camera noattr)) :: nil) tvoid cc_default)) ::
 (_select_mario_cam_mode,
   Gfun(External (EF_external "select_mario_cam_mode"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_warp_camera,
   Gfun(External (EF_external "warp_camera"
                   (mksignature
                     (AST.Xsingle :: AST.Xsingle :: AST.Xsingle :: nil)
                     AST.Xvoid cc_default))
     (tfloat :: tfloat :: tfloat :: nil) tvoid cc_default)) ::
 (_gPlayerSpawnInfos, Gvar v_gPlayerSpawnInfos) ::
 (_gWarpTransition, Gvar v_gWarpTransition) ::
 (_gCurrCourseNum, Gvar v_gCurrCourseNum) ::
 (_gCurrActNum, Gvar v_gCurrActNum) ::
 (_gCurrAreaIndex, Gvar v_gCurrAreaIndex) ::
 (_gSavedCourseNum, Gvar v_gSavedCourseNum) ::
 (_gMenuOptSelectIndex, Gvar v_gMenuOptSelectIndex) ::
 (_gAreas, Gvar v_gAreas) :: (_gCurrentArea, Gvar v_gCurrentArea) ::
 (_gCurrSaveFileNum, Gvar v_gCurrSaveFileNum) ::
 (_gCurrLevelNum, Gvar v_gCurrLevelNum) ::
 (_print_intro_text,
   Gfun(External (EF_external "print_intro_text"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_get_mario_spawn_type,
   Gfun(External (EF_external "get_mario_spawn_type"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _Object noattr)) :: nil) tuint cc_default)) ::
 (_area_get_warp_node,
   Gfun(External (EF_external "area_get_warp_node"
                   (mksignature (AST.Xint8unsigned :: nil) AST.Xptr
                     cc_default)) (tuchar :: nil)
     (tptr (Tstruct _ObjectWarpNode noattr)) cc_default)) ::
 (_load_area,
   Gfun(External (EF_external "load_area"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tint :: nil) tvoid cc_default)) ::
 (_load_mario_area,
   Gfun(External (EF_external "load_mario_area"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_unload_mario_area,
   Gfun(External (EF_external "unload_mario_area"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_change_area,
   Gfun(External (EF_external "change_area"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tint :: nil) tvoid cc_default)) ::
 (_area_update_objects,
   Gfun(External (EF_external "area_update_objects"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_play_transition,
   Gfun(External (EF_external "play_transition"
                   (mksignature
                     (AST.Xint16signed :: AST.Xint16signed ::
                      AST.Xint8unsigned :: AST.Xint8unsigned ::
                      AST.Xint8unsigned :: nil) AST.Xvoid cc_default))
     (tshort :: tshort :: tuchar :: tuchar :: tuchar :: nil) tvoid
     cc_default)) ::
 (_play_transition_after_delay,
   Gfun(External (EF_external "play_transition_after_delay"
                   (mksignature
                     (AST.Xint16signed :: AST.Xint16signed ::
                      AST.Xint8unsigned :: AST.Xint8unsigned ::
                      AST.Xint8unsigned :: AST.Xint16signed :: nil) AST.Xvoid
                     cc_default))
     (tshort :: tshort :: tuchar :: tuchar :: tuchar :: tshort :: nil) tvoid
     cc_default)) :: (_gCurrCourseStarFlags, Gvar v_gCurrCourseStarFlags) ::
 (_gSpecialTripleJump, Gvar v_gSpecialTripleJump) ::
 (_gLevelToCourseNumTable, Gvar v_gLevelToCourseNumTable) ::
 (_save_file_reload,
   Gfun(External (EF_external "save_file_reload"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_save_file_exists,
   Gfun(External (EF_external "save_file_exists"
                   (mksignature (AST.Xint :: nil) AST.Xint cc_default))
     (tint :: nil) tint cc_default)) ::
 (_save_file_get_total_star_count,
   Gfun(External (EF_external "save_file_get_total_star_count"
                   (mksignature (AST.Xint :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint cc_default)) (tint :: tint :: tint :: nil) tint
     cc_default)) ::
 (_save_file_get_flags,
   Gfun(External (EF_external "save_file_get_flags"
                   (mksignature nil AST.Xint cc_default)) nil tuint
     cc_default)) ::
 (_save_file_get_star_flags,
   Gfun(External (EF_external "save_file_get_star_flags"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xint
                     cc_default)) (tint :: tint :: nil) tuint cc_default)) ::
 (_save_file_move_cap_to_default_location,
   Gfun(External (EF_external "save_file_move_cap_to_default_location"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_disable_warp_checkpoint,
   Gfun(External (EF_external "disable_warp_checkpoint"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_check_if_should_set_warp_checkpoint,
   Gfun(External (EF_external "check_if_should_set_warp_checkpoint"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _WarpNode noattr)) :: nil) tvoid cc_default)) ::
 (_check_warp_checkpoint,
   Gfun(External (EF_external "check_warp_checkpoint"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _WarpNode noattr)) :: nil) tint cc_default)) ::
 (_reset_volume,
   Gfun(External (EF_external "reset_volume"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_raise_background_noise,
   Gfun(External (EF_external "raise_background_noise"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tint :: nil) tvoid cc_default)) ::
 (_lower_background_noise,
   Gfun(External (EF_external "lower_background_noise"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tint :: nil) tvoid cc_default)) ::
 (_enable_background_sound,
   Gfun(External (EF_external "enable_background_sound"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_play_painting_eject_sound,
   Gfun(External (EF_external "play_painting_eject_sound"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_set_background_music,
   Gfun(External (EF_external "set_background_music"
                   (mksignature
                     (AST.Xint16unsigned :: AST.Xint16unsigned ::
                      AST.Xint16signed :: nil) AST.Xvoid cc_default))
     (tushort :: tushort :: tshort :: nil) tvoid cc_default)) ::
 (_fadeout_music,
   Gfun(External (EF_external "fadeout_music"
                   (mksignature (AST.Xint16signed :: nil) AST.Xvoid
                     cc_default)) (tshort :: nil) tvoid cc_default)) ::
 (_play_cap_music,
   Gfun(External (EF_external "play_cap_music"
                   (mksignature (AST.Xint16unsigned :: nil) AST.Xvoid
                     cc_default)) (tushort :: nil) tvoid cc_default)) ::
 (_set_mario_action,
   Gfun(External (EF_external "set_mario_action"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: tuint :: nil) tuint
     cc_default)) ::
 (_init_mario,
   Gfun(External (EF_external "init_mario"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_init_mario_from_save_file,
   Gfun(External (EF_external "init_mario_from_save_file"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_get_dialog_id,
   Gfun(External (EF_external "get_dialog_id"
                   (mksignature nil AST.Xint16signed cc_default)) nil tshort
     cc_default)) ::
 (_create_dialog_box,
   Gfun(External (EF_external "create_dialog_box"
                   (mksignature (AST.Xint16signed :: nil) AST.Xvoid
                     cc_default)) (tshort :: nil) tvoid cc_default)) ::
 (_reset_dialog_render_state,
   Gfun(External (EF_external "reset_dialog_render_state"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_set_menu_mode,
   Gfun(External (EF_external "set_menu_mode"
                   (mksignature (AST.Xint16signed :: nil) AST.Xvoid
                     cc_default)) (tshort :: nil) tvoid cc_default)) ::
 (_set_yoshi_as_not_dead,
   Gfun(External (EF_external "set_yoshi_as_not_dead"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_nop_change_course,
   Gfun(External (EF_external "nop_change_course"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) :: (_credits01, Gvar v_credits01) ::
 (_credits02, Gvar v_credits02) :: (_credits03, Gvar v_credits03) ::
 (_credits04, Gvar v_credits04) :: (_credits05, Gvar v_credits05) ::
 (_credits06, Gvar v_credits06) :: (_credits07, Gvar v_credits07) ::
 (_credits08, Gvar v_credits08) :: (_credits09, Gvar v_credits09) ::
 (_credits10, Gvar v_credits10) :: (_credits11, Gvar v_credits11) ::
 (_credits12, Gvar v_credits12) :: (_credits13, Gvar v_credits13) ::
 (_credits14, Gvar v_credits14) :: (_credits15, Gvar v_credits15) ::
 (_credits16, Gvar v_credits16) :: (_credits17, Gvar v_credits17) ::
 (_credits18, Gvar v_credits18) :: (_credits19, Gvar v_credits19) ::
 (_credits20, Gvar v_credits20) ::
 (_sCreditsSequence, Gvar v_sCreditsSequence) ::
 (_gMarioStates, Gvar v_gMarioStates) ::
 (_gHudDisplay, Gvar v_gHudDisplay) ::
 (_sCurrPlayMode, Gvar v_sCurrPlayMode) ::
 (_D_80339ECA, Gvar v_D_80339ECA) ::
 (_sTransitionTimer, Gvar v_sTransitionTimer) ::
 (_sTransitionUpdate, Gvar v_sTransitionUpdate) ::
 (_sWarpDest, Gvar v_sWarpDest) :: (_D_80339EE0, Gvar v_D_80339EE0) ::
 (_sDelayedWarpOp, Gvar v_sDelayedWarpOp) ::
 (_sDelayedWarpTimer, Gvar v_sDelayedWarpTimer) ::
 (_sSourceWarpNodeId, Gvar v_sSourceWarpNodeId) ::
 (_sDelayedWarpArg, Gvar v_sDelayedWarpArg) ::
 (_sUnusedLevelUpdateBss, Gvar v_sUnusedLevelUpdateBss) ::
 (_sTimerRunning, Gvar v_sTimerRunning) ::
 (_gNeverEnteredCastle, Gvar v_gNeverEnteredCastle) ::
 (_gMarioState, Gvar v_gMarioState) :: (_unused1, Gvar v_unused1) ::
 (_sWarpCheckpointActive, Gvar v_sWarpCheckpointActive) ::
 (_unused2, Gvar v_unused2) ::
 (_level_control_timer, Gfun(Internal f_level_control_timer)) ::
 (_pressed_pause, Gfun(Internal f_pressed_pause)) ::
 (_set_play_mode, Gfun(Internal f_set_play_mode)) ::
 (_warp_special, Gfun(Internal f_warp_special)) ::
 (_fade_into_special_warp, Gfun(Internal f_fade_into_special_warp)) ::
 (_stub_level_update_1, Gfun(Internal f_stub_level_update_1)) ::
 (_load_level_init_text, Gfun(Internal f_load_level_init_text)) ::
 (_init_door_warp, Gfun(Internal f_init_door_warp)) ::
 (_set_mario_initial_cap_powerup, Gfun(Internal f_set_mario_initial_cap_powerup)) ::
 (_set_mario_initial_action, Gfun(Internal f_set_mario_initial_action)) ::
 (_init_mario_after_warp, Gfun(Internal f_init_mario_after_warp)) ::
 (_warp_area, Gfun(Internal f_warp_area)) ::
 (_warp_level, Gfun(Internal f_warp_level)) ::
 (_warp_credits, Gfun(Internal f_warp_credits)) ::
 (_check_instant_warp, Gfun(Internal f_check_instant_warp)) ::
 (_music_changed_through_warp, Gfun(Internal f_music_changed_through_warp)) ::
 (_initiate_warp, Gfun(Internal f_initiate_warp)) ::
 (_get_painting_warp_node, Gfun(Internal f_get_painting_warp_node)) ::
 (_initiate_painting_warp, Gfun(Internal f_initiate_painting_warp)) ::
 (_level_trigger_warp, Gfun(Internal f_level_trigger_warp)) ::
 (_initiate_delayed_warp, Gfun(Internal f_initiate_delayed_warp)) ::
 (_update_hud_values, Gfun(Internal f_update_hud_values)) ::
 (_basic_update, Gfun(Internal f_basic_update)) ::
 (_play_mode_normal, Gfun(Internal f_play_mode_normal)) ::
 (_play_mode_paused, Gfun(Internal f_play_mode_paused)) ::
 (_play_mode_frame_advance, Gfun(Internal f_play_mode_frame_advance)) ::
 (_level_set_transition, Gfun(Internal f_level_set_transition)) ::
 (_play_mode_change_area, Gfun(Internal f_play_mode_change_area)) ::
 (_play_mode_change_level, Gfun(Internal f_play_mode_change_level)) ::
 (_update_level, Gfun(Internal f_update_level)) ::
 (_init_level, Gfun(Internal f_init_level)) ::
 (_lvl_init_or_update, Gfun(Internal f_lvl_init_or_update)) ::
 (_lvl_init_from_save_file, Gfun(Internal f_lvl_init_from_save_file)) ::
 (_lvl_set_current_level, Gfun(Internal f_lvl_set_current_level)) ::
 (_lvl_play_the_end_screen_sound, Gfun(Internal f_lvl_play_the_end_screen_sound)) ::
 nil).

Definition public_idents : list ident :=
(_lvl_play_the_end_screen_sound :: _lvl_set_current_level ::
 _lvl_init_from_save_file :: _lvl_init_or_update :: _init_level ::
 _update_level :: _play_mode_change_level :: _play_mode_change_area ::
 _level_set_transition :: _play_mode_frame_advance :: _play_mode_paused ::
 _play_mode_normal :: _basic_update :: _update_hud_values ::
 _initiate_delayed_warp :: _level_trigger_warp :: _initiate_painting_warp ::
 _get_painting_warp_node :: _initiate_warp :: _music_changed_through_warp ::
 _check_instant_warp :: _warp_credits :: _warp_level :: _warp_area ::
 _init_mario_after_warp :: _set_mario_initial_action ::
 _set_mario_initial_cap_powerup :: _init_door_warp ::
 _load_level_init_text :: _stub_level_update_1 :: _fade_into_special_warp ::
 _warp_special :: _set_play_mode :: _pressed_pause :: _level_control_timer ::
 _unused2 :: _sWarpCheckpointActive :: _unused1 :: _gMarioState ::
 _gNeverEnteredCastle :: _sTimerRunning :: _sUnusedLevelUpdateBss ::
 _sDelayedWarpArg :: _sSourceWarpNodeId :: _sDelayedWarpTimer ::
 _sDelayedWarpOp :: _D_80339EE0 :: _sWarpDest :: _sTransitionUpdate ::
 _sTransitionTimer :: _D_80339ECA :: _sCurrPlayMode :: _gHudDisplay ::
 _gMarioStates :: _sCreditsSequence :: _credits20 :: _credits19 ::
 _credits18 :: _credits17 :: _credits16 :: _credits15 :: _credits14 ::
 _credits13 :: _credits12 :: _credits11 :: _credits10 :: _credits09 ::
 _credits08 :: _credits07 :: _credits06 :: _credits05 :: _credits04 ::
 _credits03 :: _credits02 :: _credits01 :: _nop_change_course ::
 _set_yoshi_as_not_dead :: _set_menu_mode :: _reset_dialog_render_state ::
 _create_dialog_box :: _get_dialog_id :: _init_mario_from_save_file ::
 _init_mario :: _set_mario_action :: _play_cap_music :: _fadeout_music ::
 _set_background_music :: _play_painting_eject_sound ::
 _enable_background_sound :: _lower_background_noise ::
 _raise_background_noise :: _reset_volume :: _check_warp_checkpoint ::
 _check_if_should_set_warp_checkpoint :: _disable_warp_checkpoint ::
 _save_file_move_cap_to_default_location :: _save_file_get_star_flags ::
 _save_file_get_flags :: _save_file_get_total_star_count ::
 _save_file_exists :: _save_file_reload :: _gLevelToCourseNumTable ::
 _gSpecialTripleJump :: _gCurrCourseStarFlags ::
 _play_transition_after_delay :: _play_transition :: _area_update_objects ::
 _change_area :: _unload_mario_area :: _load_mario_area :: _load_area ::
 _area_get_warp_node :: _get_mario_spawn_type :: _print_intro_text ::
 _gCurrLevelNum :: _gCurrSaveFileNum :: _gCurrentArea :: _gAreas ::
 _gMenuOptSelectIndex :: _gSavedCourseNum :: _gCurrAreaIndex ::
 _gCurrActNum :: _gCurrCourseNum :: _gWarpTransition :: _gPlayerSpawnInfos ::
 _warp_camera :: _select_mario_cam_mode :: _reset_camera :: _update_camera ::
 _gCameraMovementFlags :: _vec3s_set :: _gSineTable :: _gShowProfiler ::
 _gDebugLevelSelect :: _gGlobalTimer :: _gCurrDemoInput ::
 _gPlayer1Controller :: _gCurrCreditsEntry ::
 _get_current_background_music :: _play_music :: _sound_banks_enable ::
 _sound_banks_disable :: _play_sound :: _gGlobalSoundSource ::
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


