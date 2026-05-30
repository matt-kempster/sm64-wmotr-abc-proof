(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Produced by: pipeline/clightgen.sh
   From source: vendor/sm64/src/game/mario_misc.c
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
  Definition source_file := "vendor/sm64/src/game/mario_misc.c".
  Definition normalized := true.
End Info.

Definition _AllocOnlyPool : ident := $"AllocOnlyPool".
Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _Area : ident := $"Area".
Definition _Camera : ident := $"Camera".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _Controller : ident := $"Controller".
Definition _DmaHandlerList : ident := $"DmaHandlerList".
Definition _DmaTable : ident := $"DmaTable".
Definition _FnGraphNode : ident := $"FnGraphNode".
Definition _GraphNode : ident := $"GraphNode".
Definition _GraphNodeCamera : ident := $"GraphNodeCamera".
Definition _GraphNodeGenerated : ident := $"GraphNodeGenerated".
Definition _GraphNodeHeldObject : ident := $"GraphNodeHeldObject".
Definition _GraphNodeObject : ident := $"GraphNodeObject".
Definition _GraphNodeRoot : ident := $"GraphNodeRoot".
Definition _GraphNodeRotation : ident := $"GraphNodeRotation".
Definition _GraphNodeScale : ident := $"GraphNodeScale".
Definition _GraphNodeSwitchCase : ident := $"GraphNodeSwitchCase".
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
Definition _WarpTransition : ident := $"WarpTransition".
Definition _WarpTransitionData : ident := $"WarpTransitionData".
Definition _Waypoint : ident := $"Waypoint".
Definition _Whirlpool : ident := $"Whirlpool".
Definition __1093 : ident := $"_1093".
Definition __218 : ident := $"_218".
Definition __220 : ident := $"_220".
Definition __370 : ident := $"_370".
Definition __411 : ident := $"_411".
Definition __413 : ident := $"_413".
Definition __415 : ident := $"_415".
Definition __417 : ident := $"_417".
Definition __419 : ident := $"_419".
Definition __421 : ident := $"_421".
Definition __423 : ident := $"_423".
Definition __425 : ident := $"_425".
Definition __427 : ident := $"_427".
Definition __429 : ident := $"_429".
Definition __431 : ident := $"_431".
Definition __433 : ident := $"_433".
Definition __435 : ident := $"_435".
Definition __437 : ident := $"_437".
Definition __439 : ident := $"_439".
Definition __448 : ident := $"_448".
Definition __450 : ident := $"_450".
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
Definition __g : ident := $"_g".
Definition __g__1 : ident := $"_g__1".
Definition __g__2 : ident := $"_g__2".
Definition __g__3 : ident := $"_g__3".
Definition __g__4 : ident := $"_g__4".
Definition __g__5 : ident := $"_g__5".
Definition _action : ident := $"action".
Definition _actionArg : ident := $"actionArg".
Definition _actionState : ident := $"actionState".
Definition _actionTimer : ident := $"actionTimer".
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _addr : ident := $"addr".
Definition _alloc_display_list : ident := $"alloc_display_list".
Definition _alpha : ident := $"alpha".
Definition _angle : ident := $"angle".
Definition _angleOffset : ident := $"angleOffset".
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
Definition _asAnims : ident := $"asAnims".
Definition _asChainSegment : ident := $"asChainSegment".
Definition _asConstVoidPtr : ident := $"asConstVoidPtr".
Definition _asF32 : ident := $"asF32".
Definition _asGenerated : ident := $"asGenerated".
Definition _asHeldObj : ident := $"asHeldObj".
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
Definition _base : ident := $"base".
Definition _behavior : ident := $"behavior".
Definition _behaviorArg : ident := $"behaviorArg".
Definition _behaviorScript : ident := $"behaviorScript".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvSparkleSpawn : ident := $"bhvSparkleSpawn".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _bhv_spawn_star_no_level_exit : ident := $"bhv_spawn_star_no_level_exit".
Definition _bhv_toad_message_init : ident := $"bhv_toad_message_init".
Definition _bhv_toad_message_loop : ident := $"bhv_toad_message_loop".
Definition _bhv_unlock_door_star_init : ident := $"bhv_unlock_door_star_init".
Definition _bhv_unlock_door_star_loop : ident := $"bhv_unlock_door_star_loop".
Definition _blinkFrame : ident := $"blinkFrame".
Definition _blue : ident := $"blue".
Definition _bodyState : ident := $"bodyState".
Definition _bufTarget : ident := $"bufTarget".
Definition _button : ident := $"button".
Definition _buttonDown : ident := $"buttonDown".
Definition _buttonPressed : ident := $"buttonPressed".
Definition _c : ident := $"c".
Definition _callContext : ident := $"callContext".
Definition _camera : ident := $"camera".
Definition _cameraEvent : ident := $"cameraEvent".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _capState : ident := $"capState".
Definition _capTimer : ident := $"capTimer".
Definition _ceil : ident := $"ceil".
Definition _ceilHeight : ident := $"ceilHeight".
Definition _children : ident := $"children".
Definition _cmd : ident := $"cmd".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _color : ident := $"color".
Definition _config : ident := $"config".
Definition _controller : ident := $"controller".
Definition _controllerData : ident := $"controllerData".
Definition _count : ident := $"count".
Definition _cs : ident := $"cs".
Definition _ct : ident := $"ct".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _curTransform : ident := $"curTransform".
Definition _cur_obj_hide : ident := $"cur_obj_hide".
Definition _cur_obj_update_dialog_with_cutscene : ident := $"cur_obj_update_dialog_with_cutscene".
Definition _currentAddr : ident := $"currentAddr".
Definition _cutscene : ident := $"cutscene".
Definition _data : ident := $"data".
Definition _defMode : ident := $"defMode".
Definition _destArea : ident := $"destArea".
Definition _destLevel : ident := $"destLevel".
Definition _destNode : ident := $"destNode".
Definition _dialog : ident := $"dialog".
Definition _dialogID : ident := $"dialogID".
Definition _displacement : ident := $"displacement".
Definition _displayList : ident := $"displayList".
Definition _dma : ident := $"dma".
Definition _dmaTable : ident := $"dmaTable".
Definition _doorStatus : ident := $"doorStatus".
Definition _doubleJumpTimer : ident := $"doubleJumpTimer".
Definition _dram : ident := $"dram".
Definition _endTexRadius : ident := $"endTexRadius".
Definition _endTexX : ident := $"endTexX".
Definition _endTexY : ident := $"endTexY".
Definition _enoughStars : ident := $"enoughStars".
Definition _errnum : ident := $"errnum".
Definition _eyeState : ident := $"eyeState".
Definition _faceAngle : ident := $"faceAngle".
Definition _fadeWarpOpacity : ident := $"fadeWarpOpacity".
Definition _filler : ident := $"filler".
Definition _filler1 : ident := $"filler1".
Definition _filler2 : ident := $"filler2".
Definition _fillrect : ident := $"fillrect".
Definition _flag : ident := $"flag".
Definition _flags : ident := $"flags".
Definition _floor : ident := $"floor".
Definition _floorAngle : ident := $"floorAngle".
Definition _floorHeight : ident := $"floorHeight".
Definition _fmt : ident := $"fmt".
Definition _fnNode : ident := $"fnNode".
Definition _focus : ident := $"focus".
Definition _force : ident := $"force".
Definition _force_structure_alignment : ident := $"force_structure_alignment".
Definition _forwardVel : ident := $"forwardVel".
Definition _framesSinceA : ident := $"framesSinceA".
Definition _framesSinceB : ident := $"framesSinceB".
Definition _freePtr : ident := $"freePtr".
Definition _func : ident := $"func".
Definition _gAreaUpdateCounter : ident := $"gAreaUpdateCounter".
Definition _gBodyStates : ident := $"gBodyStates".
Definition _gCurGraphNodeCamera : ident := $"gCurGraphNodeCamera".
Definition _gCurGraphNodeObject : ident := $"gCurGraphNodeObject".
Definition _gCurrSaveFileNum : ident := $"gCurrSaveFileNum".
Definition _gCurrentObject : ident := $"gCurrentObject".
Definition _gGoddardVblankCallback : ident := $"gGoddardVblankCallback".
Definition _gMarioAttackScaleAnimation : ident := $"gMarioAttackScaleAnimation".
Definition _gMarioBlinkAnimation : ident := $"gMarioBlinkAnimation".
Definition _gMarioState : ident := $"gMarioState".
Definition _gMarioStates : ident := $"gMarioStates".
Definition _gMirrorMario : ident := $"gMirrorMario".
Definition _gPlayer1Controller : ident := $"gPlayer1Controller".
Definition _gPlayerCameraState : ident := $"gPlayerCameraState".
Definition _gSineTable : ident := $"gSineTable".
Definition _gVec3fOne : ident := $"gVec3fOne".
Definition _gVec3fZero : ident := $"gVec3fZero".
Definition _gVec3sZero : ident := $"gVec3sZero".
Definition _gWarpTransition : ident := $"gWarpTransition".
Definition _gd_copy_p1_contpad : ident := $"gd_copy_p1_contpad".
Definition _gd_sfx_to_play : ident := $"gd_sfx_to_play".
Definition _gd_vblank : ident := $"gd_vblank".
Definition _gdm_gettestdl : ident := $"gdm_gettestdl".
Definition _geo_add_child : ident := $"geo_add_child".
Definition _geo_draw_mario_head_goddard : ident := $"geo_draw_mario_head_goddard".
Definition _geo_mario_hand_foot_scaler : ident := $"geo_mario_hand_foot_scaler".
Definition _geo_mario_head_rotation : ident := $"geo_mario_head_rotation".
Definition _geo_mario_rotate_wing_cap_wings : ident := $"geo_mario_rotate_wing_cap_wings".
Definition _geo_mario_tilt_torso : ident := $"geo_mario_tilt_torso".
Definition _geo_mirror_mario_backface_culling : ident := $"geo_mirror_mario_backface_culling".
Definition _geo_mirror_mario_set_alpha : ident := $"geo_mirror_mario_set_alpha".
Definition _geo_remove_child : ident := $"geo_remove_child".
Definition _geo_render_mirror_mario : ident := $"geo_render_mirror_mario".
Definition _geo_switch_mario_cap_effect : ident := $"geo_switch_mario_cap_effect".
Definition _geo_switch_mario_cap_on_off : ident := $"geo_switch_mario_cap_on_off".
Definition _geo_switch_mario_eyes : ident := $"geo_switch_mario_eyes".
Definition _geo_switch_mario_hand : ident := $"geo_switch_mario_hand".
Definition _geo_switch_mario_hand_grab_pos : ident := $"geo_switch_mario_hand_grab_pos".
Definition _geo_switch_mario_stand_run : ident := $"geo_switch_mario_stand_run".
Definition _get_pos_from_transform_mtx : ident := $"get_pos_from_transform_mtx".
Definition _gettingBlownGravity : ident := $"gettingBlownGravity".
Definition _gfx : ident := $"gfx".
Definition _gfxHead : ident := $"gfxHead".
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
Definition _init_graph_node_object : ident := $"init_graph_node_object".
Definition _input : ident := $"input".
Definition _instantWarps : ident := $"instantWarps".
Definition _intendedMag : ident := $"intendedMag".
Definition _intendedYaw : ident := $"intendedYaw".
Definition _interactObj : ident := $"interactObj".
Definition _invincTimer : ident := $"invincTimer".
Definition _isActive : ident := $"isActive".
Definition _len : ident := $"len".
Definition _length : ident := $"length".
Definition _line : ident := $"line".
Definition _loadtile : ident := $"loadtile".
Definition _loadtlut : ident := $"loadtlut".
Definition _lodscale : ident := $"lodscale".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _macroObjects : ident := $"macroObjects".
Definition _main : ident := $"main".
Definition _make_gfx_mario_alpha : ident := $"make_gfx_mario_alpha".
Definition _mario : ident := $"mario".
Definition _marioBodyState : ident := $"marioBodyState".
Definition _marioObj : ident := $"marioObj".
Definition _marioState : ident := $"marioState".
Definition _masks : ident := $"masks".
Definition _maskt : ident := $"maskt".
Definition _matrixPtr : ident := $"matrixPtr".
Definition _mirroredX : ident := $"mirroredX".
Definition _mode : ident := $"mode".
Definition _model : ident := $"model".
Definition _modelState : ident := $"modelState".
Definition _ms : ident := $"ms".
Definition _mt : ident := $"mt".
Definition _mtx : ident := $"mtx".
Definition _musicParam : ident := $"musicParam".
Definition _musicParam2 : ident := $"musicParam2".
Definition _muxs0 : ident := $"muxs0".
Definition _muxs1 : ident := $"muxs1".
Definition _mw_index : ident := $"mw_index".
Definition _next : ident := $"next".
Definition _nextYaw : ident := $"nextYaw".
Definition _node : ident := $"node".
Definition _normal : ident := $"normal".
Definition _numCases : ident := $"numCases".
Definition _numCoins : ident := $"numCoins".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _numKeys : ident := $"numKeys".
Definition _numLives : ident := $"numLives".
Definition _numStars : ident := $"numStars".
Definition _numViews : ident := $"numViews".
Definition _number : ident := $"number".
Definition _objNode : ident := $"objNode".
Definition _obj_mark_for_deletion : ident := $"obj_mark_for_deletion".
Definition _obj_scale : ident := $"obj_scale".
Definition _object : ident := $"object".
Definition _objectSpawnInfos : ident := $"objectSpawnInfos".
Definition _offset : ident := $"offset".
Definition _on : ident := $"on".
Definition _originOffset : ident := $"originOffset".
Definition _pad : ident := $"pad".
Definition _pad0 : ident := $"pad0".
Definition _pad1 : ident := $"pad1".
Definition _pad2 : ident := $"pad2".
Definition _paintingWarpNodes : ident := $"paintingWarpNodes".
Definition _palette : ident := $"palette".
Definition _par : ident := $"par".
Definition _param : ident := $"param".
Definition _parameter : ident := $"parameter".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _particleFlags : ident := $"particleFlags".
Definition _pauseRendering : ident := $"pauseRendering".
Definition _peakHeight : ident := $"peakHeight".
Definition _perspnorm : ident := $"perspnorm".
Definition _pitch : ident := $"pitch".
Definition _platform : ident := $"platform".
Definition _play_menu_sounds : ident := $"play_menu_sounds".
Definition _play_sound : ident := $"play_sound".
Definition _play_toads_jingle : ident := $"play_toads_jingle".
Definition _playerIndex : ident := $"playerIndex".
Definition _popmtx : ident := $"popmtx".
Definition _pos : ident := $"pos".
Definition _posX : ident := $"posX".
Definition _posY : ident := $"posY".
Definition _posZ : ident := $"posZ".
Definition _prev : ident := $"prev".
Definition _prevAction : ident := $"prevAction".
Definition _prevNumStarsForDialog : ident := $"prevNumStarsForDialog".
Definition _prevObj : ident := $"prevObj".
Definition _prevYaw : ident := $"prevYaw".
Definition _prim_level : ident := $"prim_level".
Definition _prim_min_level : ident := $"prim_min_level".
Definition _punchState : ident := $"punchState".
Definition _quicksandDepth : ident := $"quicksandDepth".
Definition _rawData : ident := $"rawData".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _red : ident := $"red".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _riddenObj : ident := $"riddenObj".
Definition _roll : ident := $"roll".
Definition _rollScreen : ident := $"rollScreen".
Definition _room : ident := $"room".
Definition _rotNode : ident := $"rotNode".
Definition _rotX : ident := $"rotX".
Definition _rotation : ident := $"rotation".
Definition _s : ident := $"s".
Definition _sMarioAttackAnimCounter : ident := $"sMarioAttackAnimCounter".
Definition _saveFlags : ident := $"saveFlags".
Definition _save_file_get_flags : ident := $"save_file_get_flags".
Definition _save_file_get_total_star_count : ident := $"save_file_get_total_star_count".
Definition _scale : ident := $"scale".
Definition _scaleNode : ident := $"scaleNode".
Definition _segment : ident := $"segment".
Definition _selectedCase : ident := $"selectedCase".
Definition _setcolor : ident := $"setcolor".
Definition _setcombine : ident := $"setcombine".
Definition _setimg : ident := $"setimg".
Definition _setothermodeH : ident := $"setothermodeH".
Definition _setothermodeL : ident := $"setothermodeL".
Definition _settile : ident := $"settile".
Definition _settilesize : ident := $"settilesize".
Definition _sft : ident := $"sft".
Definition _sfx : ident := $"sfx".
Definition _sh : ident := $"sh".
Definition _sharedChild : ident := $"sharedChild".
Definition _shifts : ident := $"shifts".
Definition _shiftt : ident := $"shiftt".
Definition _siz : ident := $"siz".
Definition _size : ident := $"size".
Definition _sl : ident := $"sl".
Definition _slideVelX : ident := $"slideVelX".
Definition _slideVelZ : ident := $"slideVelZ".
Definition _slideYaw : ident := $"slideYaw".
Definition _sparkleParticle : ident := $"sparkleParticle".
Definition _spawnInfo : ident := $"spawnInfo".
Definition _spawn_object : ident := $"spawn_object".
Definition _squishTimer : ident := $"squishTimer".
Definition _srcAddr : ident := $"srcAddr".
Definition _starCount : ident := $"starCount".
Definition _star_door_unlock_spawn_particles : ident := $"star_door_unlock_spawn_particles".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
Definition _startPtr : ident := $"startPtr".
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
Definition _surfaceRooms : ident := $"surfaceRooms".
Definition _switchCase : ident := $"switchCase".
Definition _t : ident := $"t".
Definition _terrainData : ident := $"terrainData".
Definition _terrainSoundAddend : ident := $"terrainSoundAddend".
Definition _terrainType : ident := $"terrainType".
Definition _texTimer : ident := $"texTimer".
Definition _texture : ident := $"texture".
Definition _th : ident := $"th".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _tile : ident := $"tile".
Definition _time : ident := $"time".
Definition _tl : ident := $"tl".
Definition _tmem : ident := $"tmem".
Definition _toad_message_faded : ident := $"toad_message_faded".
Definition _toad_message_fading : ident := $"toad_message_fading".
Definition _toad_message_opacifying : ident := $"toad_message_opacifying".
Definition _toad_message_opaque : ident := $"toad_message_opaque".
Definition _toad_message_talking : ident := $"toad_message_talking".
Definition _torsoAngle : ident := $"torsoAngle".
Definition _totalSpace : ident := $"totalSpace".
Definition _transform : ident := $"transform".
Definition _translation : ident := $"translation".
Definition _tri : ident := $"tri".
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
Definition _upperY : ident := $"upperY".
Definition _usedObj : ident := $"usedObj".
Definition _usedSpace : ident := $"usedSpace".
Definition _v : ident := $"v".
Definition _values : ident := $"values".
Definition _vec3f_copy : ident := $"vec3f_copy".
Definition _vec3s_copy : ident := $"vec3s_copy".
Definition _vec3s_set : ident := $"vec3s_set".
Definition _vel : ident := $"vel".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _views : ident := $"views".
Definition _w0 : ident := $"w0".
Definition _w1 : ident := $"w1".
Definition _wall : ident := $"wall".
Definition _wallKickTimer : ident := $"wallKickTimer".
Definition _warpNodes : ident := $"warpNodes".
Definition _waterLevel : ident := $"waterLevel".
Definition _wd : ident := $"wd".
Definition _whirlpools : ident := $"whirlpools".
Definition _width : ident := $"width".
Definition _wingFlutter : ident := $"wingFlutter".
Definition _words : ident := $"words".
Definition _x : ident := $"x".
Definition _x0 : ident := $"x0".
Definition _x0frac : ident := $"x0frac".
Definition _x1 : ident := $"x1".
Definition _x1frac : ident := $"x1frac".
Definition _y : ident := $"y".
Definition _y0 : ident := $"y0".
Definition _y0frac : ident := $"y0frac".
Definition _y1 : ident := $"y1".
Definition _y1frac : ident := $"y1frac".
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
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v_gVec3fZero := {|
  gvar_info := (tarray tfloat 3);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gVec3sZero := {|
  gvar_info := (tarray tshort 3);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gVec3fOne := {|
  gvar_info := (tarray tfloat 3);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gPlayerCameraState := {|
  gvar_info := (tarray (Tstruct _PlayerCameraState noattr) 2);
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

Definition v_gCurrSaveFileNum := {|
  gvar_info := tshort;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSparkleSpawn := {|
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

Definition v_gGoddardVblankCallback := {|
  gvar_info := (tptr (Tfunction nil tvoid cc_default));
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

Definition v_gMarioStates := {|
  gvar_info := (tarray (Tstruct _MarioState noattr) 0);
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

Definition v_gCurrentObject := {|
  gvar_info := (tptr (Tstruct _Object noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurGraphNodeCamera := {|
  gvar_info := (tptr (Tstruct _GraphNodeCamera noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurGraphNodeObject := {|
  gvar_info := (tptr (Tstruct _GraphNodeObject noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAreaUpdateCounter := {|
  gvar_info := tushort;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMarioBlinkAnimation := {|
  gvar_info := (tarray tschar 7);
  gvar_init := (Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 1) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMarioAttackScaleAnimation := {|
  gvar_info := (tarray tschar 18);
  gvar_init := (Init_int8 (Int.repr 10) :: Init_int8 (Int.repr 12) ::
                Init_int8 (Int.repr 16) :: Init_int8 (Int.repr 24) ::
                Init_int8 (Int.repr 10) :: Init_int8 (Int.repr 10) ::
                Init_int8 (Int.repr 10) :: Init_int8 (Int.repr 14) ::
                Init_int8 (Int.repr 20) :: Init_int8 (Int.repr 30) ::
                Init_int8 (Int.repr 10) :: Init_int8 (Int.repr 10) ::
                Init_int8 (Int.repr 10) :: Init_int8 (Int.repr 16) ::
                Init_int8 (Int.repr 20) :: Init_int8 (Int.repr 26) ::
                Init_int8 (Int.repr 26) :: Init_int8 (Int.repr 20) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gBodyStates := {|
  gvar_info := (tarray (Tstruct _MarioBodyState noattr) 2);
  gvar_init := (Init_space 80 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMirrorMario := {|
  gvar_info := (Tstruct _GraphNodeObject noattr);
  gvar_init := (Init_space 144 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_geo_draw_mario_head_goddard := {|
  fn_return := (tptr (Tunion __450 noattr));
  fn_callconv := cc_default;
  fn_params := ((_callContext, tint) ::
                (_node, (tptr (Tstruct _GraphNode noattr))) ::
                (_c, (tptr (tarray (tarray tfloat 4) 4))) :: nil);
  fn_vars := nil;
  fn_temps := ((_gfx, (tptr (Tunion __450 noattr))) :: (_sfx, tshort) ::
               (_asGenerated, (tptr (Tstruct _GraphNodeGenerated noattr))) ::
               (_transform, (tptr (tarray (tarray tfloat 4) 4))) ::
               (_t'3, tint) :: (_t'2, (tptr (Tunion __450 noattr))) ::
               (_t'1, tint) :: (_t'9, tuchar) ::
               (_t'8, (tptr (Tstruct __220 noattr))) ::
               (_t'7, (tptr (Tstruct _Controller noattr))) ::
               (_t'6, (tptr (Tstruct __220 noattr))) ::
               (_t'5, (tptr (Tstruct _Controller noattr))) ::
               (_t'4, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _gfx (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Sset _sfx (Ecast (Econst_int (Int.repr 0) tint) tshort))
    (Ssequence
      (Sset _asGenerated
        (Ecast (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
          (tptr (Tstruct _GraphNodeGenerated noattr))))
      (Ssequence
        (Sset _transform (Etempvar _c (tptr (tarray (tarray tfloat 4) 4))))
        (Ssequence
          (Sifthenelse (Ebinop Oeq (Etempvar _callContext tint)
                         (Econst_int (Int.repr 1) tint) tint)
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'7
                    (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
                  (Ssequence
                    (Sset _t'8
                      (Efield
                        (Ederef
                          (Etempvar _t'7 (tptr (Tstruct _Controller noattr)))
                          (Tstruct _Controller noattr)) _controllerData
                        (tptr (Tstruct __220 noattr))))
                    (Sifthenelse (Ebinop One
                                   (Etempvar _t'8 (tptr (Tstruct __220 noattr)))
                                   (Ecast (Econst_int (Int.repr 0) tint)
                                     (tptr tvoid)) tint)
                      (Ssequence
                        (Sset _t'9
                          (Efield
                            (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                            _isActive tuchar))
                        (Sset _t'1
                          (Ecast (Eunop Onotbool (Etempvar _t'9 tuchar) tint)
                            tbool)))
                      (Sset _t'1 (Econst_int (Int.repr 0) tint)))))
                (Sifthenelse (Etempvar _t'1 tint)
                  (Ssequence
                    (Sset _t'5
                      (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
                    (Ssequence
                      (Sset _t'6
                        (Efield
                          (Ederef
                            (Etempvar _t'5 (tptr (Tstruct _Controller noattr)))
                            (Tstruct _Controller noattr)) _controllerData
                          (tptr (Tstruct __220 noattr))))
                      (Scall None
                        (Evar _gd_copy_p1_contpad (Tfunction
                                                    ((tptr (Tstruct __220 noattr)) ::
                                                     nil) tvoid cc_default))
                        ((Etempvar _t'6 (tptr (Tstruct __220 noattr))) ::
                         nil))))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'4
                      (Efield
                        (Ederef
                          (Etempvar _asGenerated (tptr (Tstruct _GraphNodeGenerated noattr)))
                          (Tstruct _GraphNodeGenerated noattr)) _parameter
                        tuint))
                    (Scall (Some _t'2)
                      (Evar _gdm_gettestdl (Tfunction (tint :: nil)
                                             (tptr (Tunion __450 noattr))
                                             cc_default))
                      ((Etempvar _t'4 tuint) :: nil)))
                  (Sset _gfx
                    (Ecast
                      (Ebinop Oor
                        (Ecast (Etempvar _t'2 (tptr (Tunion __450 noattr)))
                          tuint) (Econst_int (Int.repr (-2147483648)) tuint)
                        tuint) (tptr (Tunion __450 noattr)))))
                (Ssequence
                  (Sassign
                    (Evar _gGoddardVblankCallback (tptr (Tfunction nil tvoid
                                                          cc_default)))
                    (Evar _gd_vblank (Tfunction nil tvoid cc_default)))
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'3)
                        (Evar _gd_sfx_to_play (Tfunction nil tint cc_default))
                        nil)
                      (Sset _sfx (Ecast (Etempvar _t'3 tint) tshort)))
                    (Scall None
                      (Evar _play_menu_sounds (Tfunction (tshort :: nil)
                                                tvoid cc_default))
                      ((Etempvar _sfx tshort) :: nil))))))
            Sskip)
          (Sreturn (Some (Etempvar _gfx (tptr (Tunion __450 noattr))))))))))
|}.

Definition f_toad_message_faded := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'9, (tptr (Tstruct _Object noattr))) ::
               (_t'8, tfloat) :: (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, tfloat) :: (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, tint) :: (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'8
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asF32 (tarray tfloat 80)) (Econst_int (Int.repr 53) tint)
            (tptr tfloat)) tfloat))
      (Sifthenelse (Ebinop Ogt (Etempvar _t'8 tfloat)
                     (Econst_single (Float32.of_bits (Int.repr 1143930880)) tfloat)
                     tint)
        (Ssequence
          (Sset _t'9 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asS32 (tarray tint 80))
                (Econst_int (Int.repr 33) tint) (tptr tint)) tint)
            (Econst_int (Int.repr 0) tint)))
        Sskip)))
  (Ssequence
    (Ssequence
      (Sset _t'3 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'4
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 33) tint)
              (tptr tint)) tint))
        (Sifthenelse (Eunop Onotbool (Etempvar _t'4 tint) tint)
          (Ssequence
            (Sset _t'5
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'6
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                    (Econst_int (Int.repr 53) tint) (tptr tfloat)) tfloat))
              (Sset _t'1
                (Ecast
                  (Ebinop Olt (Etempvar _t'6 tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1142292480)) tfloat)
                    tint) tbool))))
          (Sset _t'1 (Econst_int (Int.repr 0) tint)))))
    (Sifthenelse (Etempvar _t'1 tint)
      (Ssequence
        (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 34) tint)
              (tptr tint)) tint) (Econst_int (Int.repr 2) tint)))
      Sskip)))
|}.

Definition f_toad_message_opaque := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'10, (tptr (Tstruct _Object noattr))) ::
               (_t'9, (tptr (Tstruct _Object noattr))) ::
               (_t'8, (tptr (Tstruct _Object noattr))) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tint) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: (_t'4, tint) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: (_t'2, tfloat) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Sset _t'2
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Ederef (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
            _asF32 (tarray tfloat 80)) (Econst_int (Int.repr 53) tint)
          (tptr tfloat)) tfloat))
    (Sifthenelse (Ebinop Ogt (Etempvar _t'2 tfloat)
                   (Econst_single (Float32.of_bits (Int.repr 1143930880)) tfloat)
                   tint)
      (Ssequence
        (Sset _t'10 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 34) tint)
              (tptr tint)) tint) (Econst_int (Int.repr 3) tint)))
      (Ssequence
        (Sset _t'3 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'4
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asS32 (tarray tint 80))
                (Econst_int (Int.repr 33) tint) (tptr tint)) tint))
          (Sifthenelse (Eunop Onotbool (Etempvar _t'4 tint) tint)
            (Ssequence
              (Ssequence
                (Sset _t'9
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asU32 (tarray tuint 80))
                      (Econst_int (Int.repr 66) tint) (tptr tuint)) tuint)
                  (Econst_int (Int.repr 16384) tint)))
              (Ssequence
                (Sset _t'5
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
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
                        (Econst_int (Int.repr 43) tint) (tptr tint)) tint))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'6 tint)
                                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                   (Econst_int (Int.repr 15) tint) tint)
                                 tint)
                    (Ssequence
                      (Ssequence
                        (Sset _t'8
                          (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __665 noattr)) _asS32
                                (tarray tint 80))
                              (Econst_int (Int.repr 43) tint) (tptr tint))
                            tint) (Econst_int (Int.repr 0) tint)))
                      (Ssequence
                        (Ssequence
                          (Sset _t'7
                            (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __665 noattr)) _asS32
                                  (tarray tint 80))
                                (Econst_int (Int.repr 34) tint) (tptr tint))
                              tint) (Econst_int (Int.repr 4) tint)))
                        (Scall None
                          (Evar _play_toads_jingle (Tfunction nil tvoid
                                                     cc_default)) nil)))
                    Sskip))))
            Sskip))))))
|}.

Definition f_toad_message_talking := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'10, tuint) ::
               (_t'9, (tptr (Tstruct _Object noattr))) ::
               (_t'8, (tptr (Tstruct _Object noattr))) ::
               (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: (_t'3, tuint) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'10
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asU32 (tarray tuint 80)) (Econst_int (Int.repr 32) tint)
            (tptr tuint)) tuint))
      (Scall (Some _t'1)
        (Evar _cur_obj_update_dialog_with_cutscene (Tfunction
                                                     (tint :: tint :: tint ::
                                                      tint :: nil) tint
                                                     cc_default))
        ((Econst_int (Int.repr 3) tint) ::
         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
           (Econst_int (Int.repr 0) tint) tint) ::
         (Econst_int (Int.repr 162) tint) :: (Etempvar _t'10 tuint) :: nil))))
  (Sifthenelse (Etempvar _t'1 tint)
    (Ssequence
      (Ssequence
        (Sset _t'8 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 33) tint)
              (tptr tint)) tint) (Econst_int (Int.repr 1) tint)))
      (Ssequence
        (Ssequence
          (Sset _t'7 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asS32 (tarray tint 80))
                (Econst_int (Int.repr 34) tint) (tptr tint)) tint)
            (Econst_int (Int.repr 3) tint)))
        (Ssequence
          (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'3
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __665 noattr)) _asU32 (tarray tuint 80))
                  (Econst_int (Int.repr 32) tint) (tptr tuint)) tuint))
            (Sswitch (Etempvar _t'3 tuint)
              (LScons (Some 82)
                (Ssequence
                  (Ssequence
                    (Sset _t'6
                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __665 noattr)) _asU32
                            (tarray tuint 80))
                          (Econst_int (Int.repr 32) tint) (tptr tuint))
                        tuint) (Econst_int (Int.repr 154) tint)))
                  (Ssequence
                    (Scall None
                      (Evar _bhv_spawn_star_no_level_exit (Tfunction
                                                            (tuint :: nil)
                                                            tvoid cc_default))
                      ((Econst_int (Int.repr 0) tint) :: nil))
                    Sbreak))
                (LScons (Some 76)
                  (Ssequence
                    (Ssequence
                      (Sset _t'5
                        (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _rawData
                                (Tunion __665 noattr)) _asU32
                              (tarray tuint 80))
                            (Econst_int (Int.repr 32) tint) (tptr tuint))
                          tuint) (Econst_int (Int.repr 155) tint)))
                    (Ssequence
                      (Scall None
                        (Evar _bhv_spawn_star_no_level_exit (Tfunction
                                                              (tuint :: nil)
                                                              tvoid
                                                              cc_default))
                        ((Econst_int (Int.repr 1) tint) :: nil))
                      Sbreak))
                  (LScons (Some 83)
                    (Ssequence
                      (Ssequence
                        (Sset _t'4
                          (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __665 noattr)) _asU32
                                (tarray tuint 80))
                              (Econst_int (Int.repr 32) tint) (tptr tuint))
                            tuint) (Econst_int (Int.repr 156) tint)))
                      (Ssequence
                        (Scall None
                          (Evar _bhv_spawn_star_no_level_exit (Tfunction
                                                                (tuint ::
                                                                 nil) tvoid
                                                                cc_default))
                          ((Econst_int (Int.repr 2) tint) :: nil))
                        Sbreak))
                    LSnil))))))))
    Sskip))
|}.

Definition f_toad_message_opacifying := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'5, tint) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'4 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'5
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 61) tint)
              (tptr tint)) tint))
        (Sset _t'1
          (Ecast
            (Ebinop Oadd (Etempvar _t'5 tint) (Econst_int (Int.repr 6) tint)
              tint) tint))))
    (Ssequence
      (Sset _t'3 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 61) tint)
            (tptr tint)) tint) (Etempvar _t'1 tint))))
  (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tint)
                 (Econst_int (Int.repr 255) tint) tint)
    (Ssequence
      (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 34) tint)
            (tptr tint)) tint) (Econst_int (Int.repr 1) tint)))
    Sskip))
|}.

Definition f_toad_message_fading := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'5, tint) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'4 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'5
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 61) tint)
              (tptr tint)) tint))
        (Sset _t'1
          (Ecast
            (Ebinop Osub (Etempvar _t'5 tint) (Econst_int (Int.repr 6) tint)
              tint) tint))))
    (Ssequence
      (Sset _t'3 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 61) tint)
            (tptr tint)) tint) (Etempvar _t'1 tint))))
  (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tint)
                 (Econst_int (Int.repr 81) tint) tint)
    (Ssequence
      (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 34) tint)
            (tptr tint)) tint) (Econst_int (Int.repr 0) tint)))
    Sskip))
|}.

Definition f_bhv_toad_message_loop := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'5, (tptr (Tstruct _Object noattr))) :: (_t'4, tint) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: (_t'2, tshort) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Sset _t'2
      (Efield
        (Efield
          (Efield
            (Efield
              (Ederef (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _header
              (Tstruct _ObjectNode noattr)) _gfx
            (Tstruct _GraphNodeObject noattr)) _node
          (Tstruct _GraphNode noattr)) _flags tshort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'2 tshort)
                   (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                     (Econst_int (Int.repr 0) tint) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'5 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asU32 (tarray tuint 80))
                (Econst_int (Int.repr 66) tint) (tptr tuint)) tuint)
            (Econst_int (Int.repr 0) tint)))
        (Ssequence
          (Sset _t'3 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
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
            (Sswitch (Etempvar _t'4 tint)
              (LScons (Some 0)
                (Ssequence
                  (Scall None
                    (Evar _toad_message_faded (Tfunction nil tvoid
                                                cc_default)) nil)
                  Sbreak)
                (LScons (Some 1)
                  (Ssequence
                    (Scall None
                      (Evar _toad_message_opaque (Tfunction nil tvoid
                                                   cc_default)) nil)
                    Sbreak)
                  (LScons (Some 2)
                    (Ssequence
                      (Scall None
                        (Evar _toad_message_opacifying (Tfunction nil tvoid
                                                         cc_default)) nil)
                      Sbreak)
                    (LScons (Some 3)
                      (Ssequence
                        (Scall None
                          (Evar _toad_message_fading (Tfunction nil tvoid
                                                       cc_default)) nil)
                        Sbreak)
                      (LScons (Some 4)
                        (Ssequence
                          (Scall None
                            (Evar _toad_message_talking (Tfunction nil tvoid
                                                          cc_default)) nil)
                          Sbreak)
                        LSnil)))))))))
      Sskip)))
|}.

Definition f_bhv_toad_message_init := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_saveFlags, tint) :: (_starCount, tint) ::
               (_dialogID, tint) :: (_enoughStars, tint) :: (_t'2, tint) ::
               (_t'1, tuint) :: (_t'10, tshort) :: (_t'9, tint) ::
               (_t'8, (tptr (Tstruct _Object noattr))) ::
               (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _save_file_get_flags (Tfunction nil tuint cc_default)) nil)
    (Sset _saveFlags (Etempvar _t'1 tuint)))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'10 (Evar _gCurrSaveFileNum tshort))
        (Scall (Some _t'2)
          (Evar _save_file_get_total_star_count (Tfunction
                                                  (tint :: tint :: tint ::
                                                   nil) tint cc_default))
          ((Ebinop Osub (Etempvar _t'10 tshort)
             (Econst_int (Int.repr 1) tint) tint) ::
           (Ebinop Osub (Econst_int (Int.repr 1) tint)
             (Econst_int (Int.repr 1) tint) tint) ::
           (Ebinop Osub (Econst_int (Int.repr 25) tint)
             (Econst_int (Int.repr 1) tint) tint) :: nil)))
      (Sset _starCount (Etempvar _t'2 tint)))
    (Ssequence
      (Ssequence
        (Sset _t'8 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'9
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asS32 (tarray tint 80))
                (Econst_int (Int.repr 64) tint) (tptr tint)) tint))
          (Sset _dialogID
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'9 tint)
                (Econst_int (Int.repr 24) tint) tint)
              (Econst_int (Int.repr 255) tint) tint))))
      (Ssequence
        (Sset _enoughStars (Econst_int (Int.repr 1) tint))
        (Ssequence
          (Sswitch (Etempvar _dialogID tint)
            (LScons (Some 82)
              (Ssequence
                (Sset _enoughStars
                  (Ebinop Oge (Etempvar _starCount tint)
                    (Econst_int (Int.repr 12) tint) tint))
                (Ssequence
                  (Sifthenelse (Ebinop Oand (Etempvar _saveFlags tint)
                                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                   (Econst_int (Int.repr 24) tint) tint)
                                 tint)
                    (Sset _dialogID (Econst_int (Int.repr 154) tint))
                    Sskip)
                  Sbreak))
              (LScons (Some 76)
                (Ssequence
                  (Sset _enoughStars
                    (Ebinop Oge (Etempvar _starCount tint)
                      (Econst_int (Int.repr 25) tint) tint))
                  (Ssequence
                    (Sifthenelse (Ebinop Oand (Etempvar _saveFlags tint)
                                   (Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 25) tint) tint)
                                   tint)
                      (Sset _dialogID (Econst_int (Int.repr 155) tint))
                      Sskip)
                    Sbreak))
                (LScons (Some 83)
                  (Ssequence
                    (Sset _enoughStars
                      (Ebinop Oge (Etempvar _starCount tint)
                        (Econst_int (Int.repr 35) tint) tint))
                    (Ssequence
                      (Sifthenelse (Ebinop Oand (Etempvar _saveFlags tint)
                                     (Ebinop Oshl
                                       (Econst_int (Int.repr 1) tint)
                                       (Econst_int (Int.repr 26) tint) tint)
                                     tint)
                        (Sset _dialogID (Econst_int (Int.repr 156) tint))
                        Sskip)
                      Sbreak))
                  LSnil))))
          (Sifthenelse (Etempvar _enoughStars tint)
            (Ssequence
              (Ssequence
                (Sset _t'7
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asU32 (tarray tuint 80))
                      (Econst_int (Int.repr 32) tint) (tptr tuint)) tuint)
                  (Etempvar _dialogID tint)))
              (Ssequence
                (Ssequence
                  (Sset _t'6
                    (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __665 noattr)) _asS32 (tarray tint 80))
                        (Econst_int (Int.repr 33) tint) (tptr tint)) tint)
                    (Econst_int (Int.repr 0) tint)))
                (Ssequence
                  (Ssequence
                    (Sset _t'5
                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __665 noattr)) _asS32 (tarray tint 80))
                          (Econst_int (Int.repr 34) tint) (tptr tint)) tint)
                      (Econst_int (Int.repr 0) tint)))
                  (Ssequence
                    (Sset _t'4
                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __665 noattr)) _asS32 (tarray tint 80))
                          (Econst_int (Int.repr 61) tint) (tptr tint)) tint)
                      (Econst_int (Int.repr 81) tint))))))
            (Ssequence
              (Sset _t'3
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Scall None
                (Evar _obj_mark_for_deletion (Tfunction
                                               ((tptr (Tstruct _Object noattr)) ::
                                                nil) tvoid cc_default))
                ((Etempvar _t'3 (tptr (Tstruct _Object noattr))) :: nil)))))))))
|}.

Definition f_star_door_unlock_spawn_particles := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_angleOffset, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_sparkleParticle, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr (Tstruct _Object noattr))) ::
               (_t'13, (tptr (Tstruct _Object noattr))) :: (_t'12, tfloat) ::
               (_t'11, tint) :: (_t'10, (tptr (Tstruct _Object noattr))) ::
               (_t'9, tfloat) :: (_t'8, tfloat) :: (_t'7, tint) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tfloat) ::
               (_t'4, tint) :: (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'13 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Scall (Some _t'1)
        (Evar _spawn_object (Tfunction
                              ((tptr (Tstruct _Object noattr)) :: tint ::
                               (tptr tuint) :: nil)
                              (tptr (Tstruct _Object noattr)) cc_default))
        ((Etempvar _t'13 (tptr (Tstruct _Object noattr))) ::
         (Econst_int (Int.repr 0) tint) ::
         (Evar _bhvSparkleSpawn (tarray tuint 0)) :: nil)))
    (Sset _sparkleParticle (Etempvar _t'1 (tptr (Tstruct _Object noattr)))))
  (Ssequence
    (Ssequence
      (Sset _t'9
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef
                  (Etempvar _sparkleParticle (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asF32 (tarray tfloat 80))
            (Ebinop Oadd (Econst_int (Int.repr 6) tint)
              (Econst_int (Int.repr 0) tint) tint) (tptr tfloat)) tfloat))
      (Ssequence
        (Sset _t'10 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'11
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asS32 (tarray tint 80))
                (Econst_int (Int.repr 33) tint) (tptr tint)) tint))
          (Ssequence
            (Sset _t'12
              (Ederef
                (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                  (Ebinop Oshr
                    (Ecast
                      (Ebinop Oadd
                        (Ebinop Omul (Etempvar _t'11 tint)
                          (Econst_int (Int.repr 10240) tint) tint)
                        (Etempvar _angleOffset tshort) tint) tushort)
                    (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                tfloat))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _sparkleParticle (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                  (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                    (Econst_int (Int.repr 0) tint) tint) (tptr tfloat))
                tfloat)
              (Ebinop Oadd (Etempvar _t'9 tfloat)
                (Ebinop Omul
                  (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                  (Etempvar _t'12 tfloat) tfloat) tfloat))))))
    (Ssequence
      (Ssequence
        (Sset _t'5
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _sparkleParticle (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asF32 (tarray tfloat 80))
              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                (Econst_int (Int.repr 2) tint) tint) (tptr tfloat)) tfloat))
        (Ssequence
          (Sset _t'6 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'7
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __665 noattr)) _asS32 (tarray tint 80))
                  (Econst_int (Int.repr 33) tint) (tptr tint)) tint))
            (Ssequence
              (Sset _t'8
                (Ederef
                  (Ebinop Oadd
                    (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                      (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                    (Ebinop Oshr
                      (Ecast
                        (Ebinop Oadd
                          (Ebinop Omul (Etempvar _t'7 tint)
                            (Econst_int (Int.repr 10240) tint) tint)
                          (Etempvar _angleOffset tshort) tint) tushort)
                      (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                  tfloat))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _sparkleParticle (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                    (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                      (Econst_int (Int.repr 2) tint) tint) (tptr tfloat))
                  tfloat)
                (Ebinop Oadd (Etempvar _t'5 tfloat)
                  (Ebinop Omul
                    (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                    (Etempvar _t'8 tfloat) tfloat) tfloat))))))
      (Ssequence
        (Sset _t'2
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _sparkleParticle (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asF32 (tarray tfloat 80))
              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                (Econst_int (Int.repr 1) tint) tint) (tptr tfloat)) tfloat))
        (Ssequence
          (Sset _t'3 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'4
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __665 noattr)) _asS32 (tarray tint 80))
                  (Econst_int (Int.repr 33) tint) (tptr tint)) tint))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _sparkleParticle (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                  (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                    (Econst_int (Int.repr 1) tint) tint) (tptr tfloat))
                tfloat)
              (Ebinop Osub (Etempvar _t'2 tfloat)
                (Ebinop Omul (Etempvar _t'4 tint)
                  (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                  tfloat) tfloat))))))))
|}.

Definition f_bhv_unlock_door_star_init := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'20, (tptr (Tstruct _Object noattr))) ::
               (_t'19, (tptr (Tstruct _Object noattr))) ::
               (_t'18, (tptr (Tstruct _Object noattr))) :: (_t'17, tfloat) ::
               (_t'16, tshort) ::
               (_t'15, (tptr (Tstruct _MarioState noattr))) ::
               (_t'14, tfloat) :: (_t'13, (tptr (Tstruct _Object noattr))) ::
               (_t'12, (tptr (Tstruct _Object noattr))) :: (_t'11, tfloat) ::
               (_t'10, (tptr (Tstruct _Object noattr))) ::
               (_t'9, (tptr (Tstruct _Object noattr))) :: (_t'8, tfloat) ::
               (_t'7, tshort) ::
               (_t'6, (tptr (Tstruct _MarioState noattr))) ::
               (_t'5, tfloat) :: (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'20 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
    (Sassign
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Ederef (Etempvar _t'20 (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
            _asU32 (tarray tuint 80)) (Econst_int (Int.repr 32) tint)
          (tptr tuint)) tuint) (Econst_int (Int.repr 0) tint)))
  (Ssequence
    (Ssequence
      (Sset _t'19 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'19 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 33) tint)
            (tptr tint)) tint) (Econst_int (Int.repr 0) tint)))
    (Ssequence
      (Ssequence
        (Sset _t'18 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'18 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 34) tint)
              (tptr tint)) tint) (Econst_int (Int.repr 4096) tint)))
      (Ssequence
        (Ssequence
          (Sset _t'12 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'13
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
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
                      (Econst_int (Int.repr 0) tint) tint) (tptr tfloat))
                  tfloat))
              (Ssequence
                (Sset _t'15
                  (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                (Ssequence
                  (Sset _t'16
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _t'15 (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _faceAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tshort)) tshort))
                  (Ssequence
                    (Sset _t'17
                      (Ederef
                        (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                          (Ebinop Oshr
                            (Ecast
                              (Ebinop Osub (Etempvar _t'16 tshort)
                                (Econst_int (Int.repr 16384) tint) tint)
                              tushort) (Econst_int (Int.repr 4) tint) tint)
                          (tptr tfloat)) tfloat))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'12 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __665 noattr)) _asF32
                            (tarray tfloat 80))
                          (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                            (Econst_int (Int.repr 0) tint) tint)
                          (tptr tfloat)) tfloat)
                      (Ebinop Oadd (Etempvar _t'14 tfloat)
                        (Ebinop Omul
                          (Econst_single (Float32.of_bits (Int.repr 1106247680)) tfloat)
                          (Etempvar _t'17 tfloat) tfloat) tfloat))))))))
        (Ssequence
          (Ssequence
            (Sset _t'9
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'10
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'11
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
                    tfloat))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                      (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                        (Econst_int (Int.repr 1) tint) tint) (tptr tfloat))
                    tfloat)
                  (Ebinop Oadd (Etempvar _t'11 tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat)
                    tfloat)))))
          (Ssequence
            (Ssequence
              (Sset _t'3
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'4
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'5
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                        (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                          (Econst_int (Int.repr 2) tint) tint) (tptr tfloat))
                      tfloat))
                  (Ssequence
                    (Sset _t'6
                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                    (Ssequence
                      (Sset _t'7
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _t'6 (tptr (Tstruct _MarioState noattr)))
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
                                (Ecast
                                  (Ebinop Osub (Etempvar _t'7 tshort)
                                    (Econst_int (Int.repr 16384) tint) tint)
                                  tushort) (Econst_int (Int.repr 4) tint)
                                tint) (tptr tfloat)) tfloat))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __665 noattr)) _asF32
                                (tarray tfloat 80))
                              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                                (Econst_int (Int.repr 2) tint) tint)
                              (tptr tfloat)) tfloat)
                          (Ebinop Oadd (Etempvar _t'5 tfloat)
                            (Ebinop Omul
                              (Econst_single (Float32.of_bits (Int.repr 1106247680)) tfloat)
                              (Etempvar _t'8 tfloat) tfloat) tfloat))))))))
            (Ssequence
              (Ssequence
                (Sset _t'2
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asS32 (tarray tint 80))
                      (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                        (Econst_int (Int.repr 1) tint) tint) (tptr tint))
                    tint) (Econst_int (Int.repr 30720) tint)))
              (Ssequence
                (Sset _t'1
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                (Scall None
                  (Evar _obj_scale (Tfunction
                                     ((tptr (Tstruct _Object noattr)) ::
                                      tfloat :: nil) tvoid cc_default))
                  ((Etempvar _t'1 (tptr (Tstruct _Object noattr))) ::
                   (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat) ::
                   nil))))))))))
|}.

Definition f_bhv_unlock_door_star_loop := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_filler1, (tarray tuchar 4)) ::
              (_filler2, (tarray tuchar 4)) :: nil);
  fn_temps := ((_prevYaw, tshort) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'56, tint) ::
               (_t'55, (tptr (Tstruct _Object noattr))) :: (_t'54, tint) ::
               (_t'53, (tptr (Tstruct _Object noattr))) ::
               (_t'52, (tptr (Tstruct _Object noattr))) :: (_t'51, tint) ::
               (_t'50, (tptr (Tstruct _Object noattr))) :: (_t'49, tfloat) ::
               (_t'48, (tptr (Tstruct _Object noattr))) ::
               (_t'47, (tptr (Tstruct _Object noattr))) :: (_t'46, tint) ::
               (_t'45, (tptr (Tstruct _Object noattr))) :: (_t'44, tint) ::
               (_t'43, (tptr (Tstruct _Object noattr))) ::
               (_t'42, (tptr (Tstruct _Object noattr))) :: (_t'41, tint) ::
               (_t'40, (tptr (Tstruct _Object noattr))) ::
               (_t'39, (tptr (Tstruct _Object noattr))) :: (_t'38, tint) ::
               (_t'37, (tptr (Tstruct _Object noattr))) ::
               (_t'36, (tptr (Tstruct _Object noattr))) ::
               (_t'35, (tptr (Tstruct _Object noattr))) :: (_t'34, tuint) ::
               (_t'33, (tptr (Tstruct _Object noattr))) ::
               (_t'32, (tptr (Tstruct _Object noattr))) :: (_t'31, tint) ::
               (_t'30, (tptr (Tstruct _Object noattr))) :: (_t'29, tint) ::
               (_t'28, (tptr (Tstruct _Object noattr))) ::
               (_t'27, (tptr (Tstruct _Object noattr))) :: (_t'26, tint) ::
               (_t'25, (tptr (Tstruct _Object noattr))) ::
               (_t'24, (tptr (Tstruct _Object noattr))) ::
               (_t'23, (tptr (Tstruct _Object noattr))) ::
               (_t'22, (tptr (Tstruct _Object noattr))) :: (_t'21, tuint) ::
               (_t'20, (tptr (Tstruct _Object noattr))) ::
               (_t'19, (tptr (Tstruct _Object noattr))) ::
               (_t'18, (tptr (Tstruct _Object noattr))) ::
               (_t'17, (tptr (Tstruct _Object noattr))) ::
               (_t'16, (tptr (Tstruct _Object noattr))) :: (_t'15, tuint) ::
               (_t'14, (tptr (Tstruct _Object noattr))) ::
               (_t'13, (tptr (Tstruct _Object noattr))) ::
               (_t'12, (tptr (Tstruct _Object noattr))) ::
               (_t'11, (tptr (Tstruct _Object noattr))) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tuint) ::
               (_t'8, (tptr (Tstruct _Object noattr))) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tint) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'55 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'56
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'55 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80))
            (Ebinop Oadd (Econst_int (Int.repr 15) tint)
              (Econst_int (Int.repr 1) tint) tint) (tptr tint)) tint))
      (Sset _prevYaw (Ecast (Etempvar _t'56 tint) tshort))))
  (Ssequence
    (Ssequence
      (Sset _t'50 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'51
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'50 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 34) tint)
              (tptr tint)) tint))
        (Sifthenelse (Ebinop Olt (Etempvar _t'51 tint)
                       (Econst_int (Int.repr 9216) tint) tint)
          (Ssequence
            (Sset _t'52
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'53
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'54
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'53 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asS32 (tarray tint 80))
                      (Econst_int (Int.repr 34) tint) (tptr tint)) tint))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'52 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asS32 (tarray tint 80))
                      (Econst_int (Int.repr 34) tint) (tptr tint)) tint)
                  (Ebinop Oadd (Etempvar _t'54 tint)
                    (Econst_int (Int.repr 96) tint) tint)))))
          Sskip)))
    (Ssequence
      (Ssequence
        (Sset _t'8 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'9
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asU32 (tarray tuint 80))
                (Econst_int (Int.repr 32) tint) (tptr tuint)) tuint))
          (Sswitch (Etempvar _t'9 tuint)
            (LScons (Some 0)
              (Ssequence
                (Ssequence
                  (Sset _t'47
                    (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sset _t'48
                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sset _t'49
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'48 (tptr (Tstruct _Object noattr)))
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
                                  (Etempvar _t'47 (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _rawData
                                (Tunion __665 noattr)) _asF32
                              (tarray tfloat 80))
                            (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                              (Econst_int (Int.repr 1) tint) tint)
                            (tptr tfloat)) tfloat)
                        (Ebinop Oadd (Etempvar _t'49 tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1079613850)) tfloat)
                          tfloat)))))
                (Ssequence
                  (Ssequence
                    (Sset _t'42
                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
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
                                  (Tunion __665 noattr)) _asS32
                                (tarray tint 80))
                              (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                                (Econst_int (Int.repr 1) tint) tint)
                              (tptr tint)) tint))
                        (Ssequence
                          (Sset _t'45
                            (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
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
                                  (Econst_int (Int.repr 34) tint)
                                  (tptr tint)) tint))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'42 (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _rawData
                                      (Tunion __665 noattr)) _asS32
                                    (tarray tint 80))
                                  (Ebinop Oadd
                                    (Econst_int (Int.repr 15) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  (tptr tint)) tint)
                              (Ebinop Oadd (Etempvar _t'44 tint)
                                (Etempvar _t'46 tint) tint)))))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'39
                        (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                      (Ssequence
                        (Sset _t'40
                          (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                        (Ssequence
                          (Sset _t'41
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'40 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __665 noattr)) _asS32
                                  (tarray tint 80))
                                (Econst_int (Int.repr 33) tint) (tptr tint))
                              tint))
                          (Scall None
                            (Evar _obj_scale (Tfunction
                                               ((tptr (Tstruct _Object noattr)) ::
                                                tfloat :: nil) tvoid
                                               cc_default))
                            ((Etempvar _t'39 (tptr (Tstruct _Object noattr))) ::
                             (Ebinop Oadd
                               (Ebinop Odiv (Etempvar _t'41 tint)
                                 (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat)
                                 tfloat)
                               (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat)
                               tfloat) :: nil)))))
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'37
                              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                            (Ssequence
                              (Sset _t'38
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'37 (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _rawData
                                        (Tunion __665 noattr)) _asS32
                                      (tarray tint 80))
                                    (Econst_int (Int.repr 33) tint)
                                    (tptr tint)) tint))
                              (Sset _t'1
                                (Ecast
                                  (Ebinop Oadd (Etempvar _t'38 tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tint))))
                          (Ssequence
                            (Sset _t'36
                              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'36 (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _rawData
                                      (Tunion __665 noattr)) _asS32
                                    (tarray tint 80))
                                  (Econst_int (Int.repr 33) tint)
                                  (tptr tint)) tint) (Etempvar _t'1 tint))))
                        (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tint)
                                       (Econst_int (Int.repr 30) tint) tint)
                          (Ssequence
                            (Ssequence
                              (Sset _t'35
                                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'35 (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _rawData
                                        (Tunion __665 noattr)) _asS32
                                      (tarray tint 80))
                                    (Econst_int (Int.repr 33) tint)
                                    (tptr tint)) tint)
                                (Econst_int (Int.repr 0) tint)))
                            (Ssequence
                              (Sset _t'32
                                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                              (Ssequence
                                (Sset _t'33
                                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                (Ssequence
                                  (Sset _t'34
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'33 (tptr (Tstruct _Object noattr)))
                                              (Tstruct _Object noattr))
                                            _rawData (Tunion __665 noattr))
                                          _asU32 (tarray tuint 80))
                                        (Econst_int (Int.repr 32) tint)
                                        (tptr tuint)) tuint))
                                  (Sassign
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'32 (tptr (Tstruct _Object noattr)))
                                              (Tstruct _Object noattr))
                                            _rawData (Tunion __665 noattr))
                                          _asU32 (tarray tuint 80))
                                        (Econst_int (Int.repr 32) tint)
                                        (tptr tuint)) tuint)
                                    (Ebinop Oadd (Etempvar _t'34 tuint)
                                      (Econst_int (Int.repr 1) tint) tuint))))))
                          Sskip))
                      Sbreak))))
              (LScons (Some 1)
                (Ssequence
                  (Ssequence
                    (Sset _t'27
                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sset _t'28
                        (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                      (Ssequence
                        (Sset _t'29
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'28 (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __665 noattr)) _asS32
                                (tarray tint 80))
                              (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                                (Econst_int (Int.repr 1) tint) tint)
                              (tptr tint)) tint))
                        (Ssequence
                          (Sset _t'30
                            (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                          (Ssequence
                            (Sset _t'31
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'30 (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _rawData
                                      (Tunion __665 noattr)) _asS32
                                    (tarray tint 80))
                                  (Econst_int (Int.repr 34) tint)
                                  (tptr tint)) tint))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'27 (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _rawData
                                      (Tunion __665 noattr)) _asS32
                                    (tarray tint 80))
                                  (Ebinop Oadd
                                    (Econst_int (Int.repr 15) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  (tptr tint)) tint)
                              (Ebinop Oadd (Etempvar _t'29 tint)
                                (Etempvar _t'31 tint) tint)))))))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'25
                            (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                          (Ssequence
                            (Sset _t'26
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'25 (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _rawData
                                      (Tunion __665 noattr)) _asS32
                                    (tarray tint 80))
                                  (Econst_int (Int.repr 33) tint)
                                  (tptr tint)) tint))
                            (Sset _t'2
                              (Ecast
                                (Ebinop Oadd (Etempvar _t'26 tint)
                                  (Econst_int (Int.repr 1) tint) tint) tint))))
                        (Ssequence
                          (Sset _t'24
                            (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'24 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __665 noattr)) _asS32
                                  (tarray tint 80))
                                (Econst_int (Int.repr 33) tint) (tptr tint))
                              tint) (Etempvar _t'2 tint))))
                      (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tint)
                                     (Econst_int (Int.repr 30) tint) tint)
                        (Ssequence
                          (Ssequence
                            (Sset _t'23
                              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
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
                                       (Econst_int (Int.repr 8) tint) tuint)
                                     tuint) (Econst_int (Int.repr 128) tint)
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
                                 _cameraToObject (tarray tfloat 3)) :: nil)))
                          (Ssequence
                            (Scall None
                              (Evar _cur_obj_hide (Tfunction nil tvoid
                                                    cc_default)) nil)
                            (Ssequence
                              (Ssequence
                                (Sset _t'22
                                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                (Sassign
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'22 (tptr (Tstruct _Object noattr)))
                                            (Tstruct _Object noattr))
                                          _rawData (Tunion __665 noattr))
                                        _asS32 (tarray tint 80))
                                      (Econst_int (Int.repr 33) tint)
                                      (tptr tint)) tint)
                                  (Econst_int (Int.repr 0) tint)))
                              (Ssequence
                                (Sset _t'19
                                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                (Ssequence
                                  (Sset _t'20
                                    (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                  (Ssequence
                                    (Sset _t'21
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'20 (tptr (Tstruct _Object noattr)))
                                                (Tstruct _Object noattr))
                                              _rawData (Tunion __665 noattr))
                                            _asU32 (tarray tuint 80))
                                          (Econst_int (Int.repr 32) tint)
                                          (tptr tuint)) tuint))
                                    (Sassign
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'19 (tptr (Tstruct _Object noattr)))
                                                (Tstruct _Object noattr))
                                              _rawData (Tunion __665 noattr))
                                            _asU32 (tarray tuint 80))
                                          (Econst_int (Int.repr 32) tint)
                                          (tptr tuint)) tuint)
                                      (Ebinop Oadd (Etempvar _t'21 tuint)
                                        (Econst_int (Int.repr 1) tint) tuint))))))))
                        Sskip))
                    Sbreak))
                (LScons (Some 2)
                  (Ssequence
                    (Scall None
                      (Evar _star_door_unlock_spawn_particles (Tfunction
                                                                (tshort ::
                                                                 nil) tvoid
                                                                cc_default))
                      ((Econst_int (Int.repr 0) tint) :: nil))
                    (Ssequence
                      (Scall None
                        (Evar _star_door_unlock_spawn_particles (Tfunction
                                                                  (tshort ::
                                                                   nil) tvoid
                                                                  cc_default))
                        ((Econst_int (Int.repr 32768) tint) :: nil))
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Sset _t'18
                                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                              (Sset _t'3
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'18 (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _rawData
                                        (Tunion __665 noattr)) _asS32
                                      (tarray tint 80))
                                    (Econst_int (Int.repr 33) tint)
                                    (tptr tint)) tint)))
                            (Ssequence
                              (Sset _t'17
                                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'17 (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _rawData
                                        (Tunion __665 noattr)) _asS32
                                      (tarray tint 80))
                                    (Econst_int (Int.repr 33) tint)
                                    (tptr tint)) tint)
                                (Ebinop Oadd (Etempvar _t'3 tint)
                                  (Econst_int (Int.repr 1) tint) tint))))
                          (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tint)
                                         (Econst_int (Int.repr 20) tint)
                                         tint)
                            (Ssequence
                              (Ssequence
                                (Sset _t'16
                                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                (Sassign
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'16 (tptr (Tstruct _Object noattr)))
                                            (Tstruct _Object noattr))
                                          _rawData (Tunion __665 noattr))
                                        _asS32 (tarray tint 80))
                                      (Econst_int (Int.repr 33) tint)
                                      (tptr tint)) tint)
                                  (Econst_int (Int.repr 0) tint)))
                              (Ssequence
                                (Sset _t'13
                                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                (Ssequence
                                  (Sset _t'14
                                    (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                  (Ssequence
                                    (Sset _t'15
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'14 (tptr (Tstruct _Object noattr)))
                                                (Tstruct _Object noattr))
                                              _rawData (Tunion __665 noattr))
                                            _asU32 (tarray tuint 80))
                                          (Econst_int (Int.repr 32) tint)
                                          (tptr tuint)) tuint))
                                    (Sassign
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'13 (tptr (Tstruct _Object noattr)))
                                                (Tstruct _Object noattr))
                                              _rawData (Tunion __665 noattr))
                                            _asU32 (tarray tuint 80))
                                          (Econst_int (Int.repr 32) tint)
                                          (tptr tuint)) tuint)
                                      (Ebinop Oadd (Etempvar _t'15 tuint)
                                        (Econst_int (Int.repr 1) tint) tuint))))))
                            Sskip))
                        Sbreak)))
                  (LScons (Some 3)
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'12
                              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                            (Sset _t'4
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'12 (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _rawData
                                      (Tunion __665 noattr)) _asS32
                                    (tarray tint 80))
                                  (Econst_int (Int.repr 33) tint)
                                  (tptr tint)) tint)))
                          (Ssequence
                            (Sset _t'11
                              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'11 (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _rawData
                                      (Tunion __665 noattr)) _asS32
                                    (tarray tint 80))
                                  (Econst_int (Int.repr 33) tint)
                                  (tptr tint)) tint)
                              (Ebinop Oadd (Etempvar _t'4 tint)
                                (Econst_int (Int.repr 1) tint) tint))))
                        (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tint)
                                       (Econst_int (Int.repr 50) tint) tint)
                          (Ssequence
                            (Sset _t'10
                              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                            (Scall None
                              (Evar _obj_mark_for_deletion (Tfunction
                                                             ((tptr (Tstruct _Object noattr)) ::
                                                              nil) tvoid
                                                             cc_default))
                              ((Etempvar _t'10 (tptr (Tstruct _Object noattr))) ::
                               nil)))
                          Sskip))
                      Sbreak)
                    LSnil)))))))
      (Ssequence
        (Sset _t'5 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'6
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asS32 (tarray tint 80))
                (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                  (Econst_int (Int.repr 1) tint) tint) (tptr tint)) tint))
          (Sifthenelse (Ebinop Ogt (Etempvar _prevYaw tshort)
                         (Ecast (Etempvar _t'6 tint) tshort) tint)
            (Ssequence
              (Sset _t'7
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Scall None
                (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil)
                                    tvoid cc_default))
                ((Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 3) tint) tuint)
                           (Econst_int (Int.repr 28) tint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 22) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 0) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Ebinop Oor (Econst_int (Int.repr 16) tint)
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
            Sskip))))))
|}.

Definition f_make_gfx_mario_alpha := {|
  fn_return := (tptr (Tunion __450 noattr));
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _GraphNodeGenerated noattr))) ::
                (_alpha, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_gfx, (tptr (Tunion __450 noattr))) ::
               (_gfxHead, (tptr (Tunion __450 noattr))) ::
               (__g, (tptr (Tunion __450 noattr))) ::
               (__g__1, (tptr (Tunion __450 noattr))) ::
               (__g__2, (tptr (Tunion __450 noattr))) ::
               (_t'4, (tptr (Tunion __450 noattr))) ::
               (_t'3, (tptr (Tunion __450 noattr))) ::
               (_t'2, (tptr tvoid)) :: (_t'1, (tptr tvoid)) ::
               (_t'6, tshort) :: (_t'5, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _gfxHead (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Sifthenelse (Ebinop Oeq (Etempvar _alpha tshort)
                   (Econst_int (Int.repr 255) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'6
            (Efield
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _node (tptr (Tstruct _GraphNodeGenerated noattr)))
                    (Tstruct _GraphNodeGenerated noattr)) _fnNode
                  (Tstruct _FnGraphNode noattr)) _node
                (Tstruct _GraphNode noattr)) _flags tshort))
          (Sassign
            (Efield
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _node (tptr (Tstruct _GraphNodeGenerated noattr)))
                    (Tstruct _GraphNodeGenerated noattr)) _fnNode
                  (Tstruct _FnGraphNode noattr)) _node
                (Tstruct _GraphNode noattr)) _flags tshort)
            (Ebinop Oor
              (Ebinop Oand (Etempvar _t'6 tshort)
                (Econst_int (Int.repr 255) tint) tint)
              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 8) tint) tint) tint)))
        (Ssequence
          (Ssequence
            (Scall (Some _t'1)
              (Evar _alloc_display_list (Tfunction (tuint :: nil)
                                          (tptr tvoid) cc_default))
              ((Ebinop Omul (Econst_int (Int.repr 2) tint)
                 (Esizeof (Tunion __450 noattr) tulong) tulong) :: nil))
            (Sset _gfxHead (Etempvar _t'1 (tptr tvoid))))
          (Sset _gfx (Etempvar _gfxHead (tptr (Tunion __450 noattr))))))
      (Ssequence
        (Ssequence
          (Sset _t'5
            (Efield
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _node (tptr (Tstruct _GraphNodeGenerated noattr)))
                    (Tstruct _GraphNodeGenerated noattr)) _fnNode
                  (Tstruct _FnGraphNode noattr)) _node
                (Tstruct _GraphNode noattr)) _flags tshort))
          (Sassign
            (Efield
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _node (tptr (Tstruct _GraphNodeGenerated noattr)))
                    (Tstruct _GraphNodeGenerated noattr)) _fnNode
                  (Tstruct _FnGraphNode noattr)) _node
                (Tstruct _GraphNode noattr)) _flags tshort)
            (Ebinop Oor
              (Ebinop Oand (Etempvar _t'5 tshort)
                (Econst_int (Int.repr 255) tint) tint)
              (Ebinop Oshl (Econst_int (Int.repr 5) tint)
                (Econst_int (Int.repr 8) tint) tint) tint)))
        (Ssequence
          (Ssequence
            (Scall (Some _t'2)
              (Evar _alloc_display_list (Tfunction (tuint :: nil)
                                          (tptr tvoid) cc_default))
              ((Ebinop Omul (Econst_int (Int.repr 3) tint)
                 (Esizeof (Tunion __450 noattr) tulong) tulong) :: nil))
            (Sset _gfxHead (Etempvar _t'2 (tptr tvoid))))
          (Ssequence
            (Sset _gfx (Etempvar _gfxHead (tptr (Tunion __450 noattr))))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'3 (Etempvar _gfx (tptr (Tunion __450 noattr))))
                  (Sset _gfx
                    (Ebinop Oadd (Etempvar _t'3 (tptr (Tunion __450 noattr)))
                      (Econst_int (Int.repr 1) tint)
                      (tptr (Tunion __450 noattr)))))
                (Sset __g
                  (Ecast (Etempvar _t'3 (tptr (Tunion __450 noattr)))
                    (tptr (Tunion __450 noattr)))))
              (Ssequence
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g (tptr (Tunion __450 noattr)))
                        (Tunion __450 noattr)) _words (Tstruct __448 noattr))
                    _w0 tuint)
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 226) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 24) tint) tuint) tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast
                              (Ebinop Osub
                                (Ebinop Osub (Econst_int (Int.repr 32) tint)
                                  (Econst_int (Int.repr 0) tint) tint)
                                (Econst_int (Int.repr 2) tint) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 8) tint) tuint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast
                            (Ebinop Osub (Econst_int (Int.repr 2) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g (tptr (Tunion __450 noattr)))
                        (Tunion __450 noattr)) _words (Tstruct __448 noattr))
                    _w1 tuint)
                  (Ecast
                    (Ebinop Oshl (Econst_int (Int.repr 3) tint)
                      (Econst_int (Int.repr 0) tint) tint) tuint))))))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'4 (Etempvar _gfx (tptr (Tunion __450 noattr))))
            (Sset _gfx
              (Ebinop Oadd (Etempvar _t'4 (tptr (Tunion __450 noattr)))
                (Econst_int (Int.repr 1) tint) (tptr (Tunion __450 noattr)))))
          (Sset __g__1
            (Ecast (Etempvar _t'4 (tptr (Tunion __450 noattr)))
              (tptr (Tunion __450 noattr)))))
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__1 (tptr (Tunion __450 noattr)))
                  (Tunion __450 noattr)) _words (Tstruct __448 noattr)) _w0
              tuint)
            (Ecast
              (Ebinop Oshl
                (Ebinop Oand (Ecast (Econst_int (Int.repr 251) tint) tuint)
                  (Ebinop Osub
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 8) tint) tint)
                    (Econst_int (Int.repr 1) tint) tint) tuint)
                (Econst_int (Int.repr 24) tint) tuint) tuint))
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__1 (tptr (Tunion __450 noattr)))
                  (Tunion __450 noattr)) _words (Tstruct __448 noattr)) _w1
              tuint)
            (Ecast
              (Ebinop Oor
                (Ebinop Oor
                  (Ebinop Oor
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 255) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 24) tint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 255) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 16) tint) tuint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 255) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 8) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 8) tint) tuint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand (Ecast (Etempvar _alpha tshort) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 0) tint) tuint) tuint) tuint)
              tuint))))
      (Ssequence
        (Ssequence
          (Sset __g__2
            (Ecast (Etempvar _gfx (tptr (Tunion __450 noattr)))
              (tptr (Tunion __450 noattr))))
          (Ssequence
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__2 (tptr (Tunion __450 noattr)))
                    (Tunion __450 noattr)) _words (Tstruct __448 noattr)) _w0
                tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand (Ecast (Econst_int (Int.repr 223) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 8) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 24) tint) tuint) tuint))
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__2 (tptr (Tunion __450 noattr)))
                    (Tunion __450 noattr)) _words (Tstruct __448 noattr)) _w1
                tuint) (Econst_int (Int.repr 0) tint))))
        (Sreturn (Some (Etempvar _gfxHead (tptr (Tunion __450 noattr)))))))))
|}.

Definition f_geo_mirror_mario_set_alpha := {|
  fn_return := (tptr (Tunion __450 noattr));
  fn_callconv := cc_default;
  fn_params := ((_callContext, tint) ::
                (_node, (tptr (Tstruct _GraphNode noattr))) ::
                (_c, (tptr (tarray (tarray tfloat 4) 4))) :: nil);
  fn_vars := ((_filler1, (tarray tuchar 4)) ::
              (_filler2, (tarray tuchar 4)) :: nil);
  fn_temps := ((_gfx, (tptr (Tunion __450 noattr))) ::
               (_asGenerated, (tptr (Tstruct _GraphNodeGenerated noattr))) ::
               (_bodyState, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_alpha, tshort) :: (_t'2, (tptr (Tunion __450 noattr))) ::
               (_t'1, tint) :: (_t'5, tuint) :: (_t'4, tshort) ::
               (_t'3, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _gfx (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Sset _asGenerated
      (Ecast (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
        (tptr (Tstruct _GraphNodeGenerated noattr))))
    (Ssequence
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef
              (Etempvar _asGenerated (tptr (Tstruct _GraphNodeGenerated noattr)))
              (Tstruct _GraphNodeGenerated noattr)) _parameter tuint))
        (Sset _bodyState
          (Ebinop Oadd
            (Evar _gBodyStates (tarray (Tstruct _MarioBodyState noattr) 2))
            (Etempvar _t'5 tuint) (tptr (Tstruct _MarioBodyState noattr)))))
      (Ssequence
        (Sifthenelse (Ebinop Oeq (Etempvar _callContext tint)
                       (Econst_int (Int.repr 1) tint) tint)
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'3
                  (Efield
                    (Ederef
                      (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                      (Tstruct _MarioBodyState noattr)) _modelState tshort))
                (Sifthenelse (Ebinop Oand (Etempvar _t'3 tshort)
                               (Econst_int (Int.repr 256) tint) tint)
                  (Ssequence
                    (Sset _t'4
                      (Efield
                        (Ederef
                          (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                          (Tstruct _MarioBodyState noattr)) _modelState
                        tshort))
                    (Sset _t'1
                      (Ecast
                        (Ebinop Oand (Etempvar _t'4 tshort)
                          (Econst_int (Int.repr 255) tint) tint) tint)))
                  (Sset _t'1 (Ecast (Econst_int (Int.repr 255) tint) tint))))
              (Sset _alpha (Ecast (Etempvar _t'1 tint) tshort)))
            (Ssequence
              (Scall (Some _t'2)
                (Evar _make_gfx_mario_alpha (Tfunction
                                              ((tptr (Tstruct _GraphNodeGenerated noattr)) ::
                                               tshort :: nil)
                                              (tptr (Tunion __450 noattr))
                                              cc_default))
                ((Etempvar _asGenerated (tptr (Tstruct _GraphNodeGenerated noattr))) ::
                 (Etempvar _alpha tshort) :: nil))
              (Sset _gfx (Etempvar _t'2 (tptr (Tunion __450 noattr))))))
          Sskip)
        (Sreturn (Some (Etempvar _gfx (tptr (Tunion __450 noattr)))))))))
|}.

Definition f_geo_switch_mario_stand_run := {|
  fn_return := (tptr (Tunion __450 noattr));
  fn_callconv := cc_default;
  fn_params := ((_callContext, tint) ::
                (_node, (tptr (Tstruct _GraphNode noattr))) ::
                (_mtx, (tptr (tarray (tarray tfloat 4) 4))) :: nil);
  fn_vars := nil;
  fn_temps := ((_switchCase, (tptr (Tstruct _GraphNodeSwitchCase noattr))) ::
               (_bodyState, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'2, tshort) :: (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _switchCase
    (Ecast (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
      (tptr (Tstruct _GraphNodeSwitchCase noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Efield
          (Ederef
            (Etempvar _switchCase (tptr (Tstruct _GraphNodeSwitchCase noattr)))
            (Tstruct _GraphNodeSwitchCase noattr)) _numCases tshort))
      (Sset _bodyState
        (Ebinop Oadd
          (Evar _gBodyStates (tarray (Tstruct _MarioBodyState noattr) 2))
          (Etempvar _t'2 tshort) (tptr (Tstruct _MarioBodyState noattr)))))
    (Ssequence
      (Sifthenelse (Ebinop Oeq (Etempvar _callContext tint)
                     (Econst_int (Int.repr 1) tint) tint)
        (Ssequence
          (Sset _t'1
            (Efield
              (Ederef
                (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                (Tstruct _MarioBodyState noattr)) _action tuint))
          (Sassign
            (Efield
              (Ederef
                (Etempvar _switchCase (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                (Tstruct _GraphNodeSwitchCase noattr)) _selectedCase tshort)
            (Ebinop Oeq
              (Ebinop Oand (Etempvar _t'1 tuint)
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 9) tint) tint) tuint)
              (Econst_int (Int.repr 0) tint) tint)))
        Sskip)
      (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))))))
|}.

Definition f_geo_switch_mario_eyes := {|
  fn_return := (tptr (Tunion __450 noattr));
  fn_callconv := cc_default;
  fn_params := ((_callContext, tint) ::
                (_node, (tptr (Tstruct _GraphNode noattr))) ::
                (_c, (tptr (tarray (tarray tfloat 4) 4))) :: nil);
  fn_vars := nil;
  fn_temps := ((_switchCase, (tptr (Tstruct _GraphNodeSwitchCase noattr))) ::
               (_bodyState, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_blinkFrame, tshort) :: (_t'6, tshort) :: (_t'5, tushort) ::
               (_t'4, tshort) :: (_t'3, tschar) :: (_t'2, tschar) ::
               (_t'1, tschar) :: nil);
  fn_body :=
(Ssequence
  (Sset _switchCase
    (Ecast (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
      (tptr (Tstruct _GraphNodeSwitchCase noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'6
        (Efield
          (Ederef
            (Etempvar _switchCase (tptr (Tstruct _GraphNodeSwitchCase noattr)))
            (Tstruct _GraphNodeSwitchCase noattr)) _numCases tshort))
      (Sset _bodyState
        (Ebinop Oadd
          (Evar _gBodyStates (tarray (Tstruct _MarioBodyState noattr) 2))
          (Etempvar _t'6 tshort) (tptr (Tstruct _MarioBodyState noattr)))))
    (Ssequence
      (Sifthenelse (Ebinop Oeq (Etempvar _callContext tint)
                     (Econst_int (Int.repr 1) tint) tint)
        (Ssequence
          (Sset _t'1
            (Efield
              (Ederef
                (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                (Tstruct _MarioBodyState noattr)) _eyeState tschar))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tschar)
                         (Econst_int (Int.repr 0) tint) tint)
            (Ssequence
              (Ssequence
                (Sset _t'4
                  (Efield
                    (Ederef
                      (Etempvar _switchCase (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                      (Tstruct _GraphNodeSwitchCase noattr)) _numCases
                    tshort))
                (Ssequence
                  (Sset _t'5 (Evar _gAreaUpdateCounter tushort))
                  (Sset _blinkFrame
                    (Ecast
                      (Ebinop Oand
                        (Ebinop Oshr
                          (Ebinop Oadd
                            (Ebinop Omul (Etempvar _t'4 tshort)
                              (Econst_int (Int.repr 32) tint) tint)
                            (Etempvar _t'5 tushort) tint)
                          (Econst_int (Int.repr 1) tint) tint)
                        (Econst_int (Int.repr 31) tint) tint) tshort))))
              (Sifthenelse (Ebinop Olt (Etempvar _blinkFrame tshort)
                             (Econst_int (Int.repr 7) tint) tint)
                (Ssequence
                  (Sset _t'3
                    (Ederef
                      (Ebinop Oadd
                        (Evar _gMarioBlinkAnimation (tarray tschar 7))
                        (Etempvar _blinkFrame tshort) (tptr tschar)) tschar))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _switchCase (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                        (Tstruct _GraphNodeSwitchCase noattr)) _selectedCase
                      tshort) (Etempvar _t'3 tschar)))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _switchCase (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                      (Tstruct _GraphNodeSwitchCase noattr)) _selectedCase
                    tshort) (Econst_int (Int.repr 0) tint))))
            (Ssequence
              (Sset _t'2
                (Efield
                  (Ederef
                    (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                    (Tstruct _MarioBodyState noattr)) _eyeState tschar))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _switchCase (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                    (Tstruct _GraphNodeSwitchCase noattr)) _selectedCase
                  tshort)
                (Ebinop Osub (Etempvar _t'2 tschar)
                  (Econst_int (Int.repr 1) tint) tint)))))
        Sskip)
      (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))))))
|}.

Definition f_geo_mario_tilt_torso := {|
  fn_return := (tptr (Tunion __450 noattr));
  fn_callconv := cc_default;
  fn_params := ((_callContext, tint) ::
                (_node, (tptr (Tstruct _GraphNode noattr))) ::
                (_c, (tptr (tarray (tarray tfloat 4) 4))) :: nil);
  fn_vars := nil;
  fn_temps := ((_asGenerated, (tptr (Tstruct _GraphNodeGenerated noattr))) ::
               (_bodyState, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_action, tint) ::
               (_rotNode, (tptr (Tstruct _GraphNodeRotation noattr))) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'8, tuint) :: (_t'7, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'6, tshort) :: (_t'5, tshort) :: (_t'4, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _asGenerated
    (Ecast (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
      (tptr (Tstruct _GraphNodeGenerated noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'8
        (Efield
          (Ederef
            (Etempvar _asGenerated (tptr (Tstruct _GraphNodeGenerated noattr)))
            (Tstruct _GraphNodeGenerated noattr)) _parameter tuint))
      (Sset _bodyState
        (Ebinop Oadd
          (Evar _gBodyStates (tarray (Tstruct _MarioBodyState noattr) 2))
          (Etempvar _t'8 tuint) (tptr (Tstruct _MarioBodyState noattr)))))
    (Ssequence
      (Sset _action
        (Efield
          (Ederef
            (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
            (Tstruct _MarioBodyState noattr)) _action tuint))
      (Ssequence
        (Sifthenelse (Ebinop Oeq (Etempvar _callContext tint)
                       (Econst_int (Int.repr 1) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'7
                (Efield
                  (Ederef (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
                    (Tstruct _GraphNode noattr)) _next
                  (tptr (Tstruct _GraphNode noattr))))
              (Sset _rotNode
                (Ecast (Etempvar _t'7 (tptr (Tstruct _GraphNode noattr)))
                  (tptr (Tstruct _GraphNodeRotation noattr)))))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sifthenelse (Ebinop One (Etempvar _action tint)
                                   (Econst_int (Int.repr 8651858) tint) tint)
                      (Sset _t'1
                        (Ecast
                          (Ebinop One (Etempvar _action tint)
                            (Econst_int (Int.repr 8651860) tint) tint) tbool))
                      (Sset _t'1 (Econst_int (Int.repr 0) tint)))
                    (Sifthenelse (Etempvar _t'1 tint)
                      (Sset _t'2
                        (Ecast
                          (Ebinop One (Etempvar _action tint)
                            (Econst_int (Int.repr 67109952) tint) tint)
                          tbool))
                      (Sset _t'2 (Econst_int (Int.repr 0) tint))))
                  (Sifthenelse (Etempvar _t'2 tint)
                    (Sset _t'3
                      (Ecast
                        (Ebinop One (Etempvar _action tint)
                          (Econst_int (Int.repr 545326150) tint) tint) tbool))
                    (Sset _t'3 (Econst_int (Int.repr 0) tint))))
                (Sifthenelse (Etempvar _t'3 tint)
                  (Scall None
                    (Evar _vec3s_copy (Tfunction
                                        ((tptr tshort) :: (tptr tshort) ::
                                         nil) (tptr tvoid) cc_default))
                    ((Efield
                       (Ederef
                         (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                         (Tstruct _MarioBodyState noattr)) _torsoAngle
                       (tarray tshort 3)) ::
                     (Evar _gVec3sZero (tarray tshort 3)) :: nil))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _t'6
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                            (Tstruct _MarioBodyState noattr)) _torsoAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tshort)) tshort))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _rotNode (tptr (Tstruct _GraphNodeRotation noattr)))
                            (Tstruct _GraphNodeRotation noattr)) _rotation
                          (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tshort)) tshort) (Etempvar _t'6 tshort)))
                (Ssequence
                  (Ssequence
                    (Sset _t'5
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                              (Tstruct _MarioBodyState noattr)) _torsoAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 2) tint)
                          (tptr tshort)) tshort))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _rotNode (tptr (Tstruct _GraphNodeRotation noattr)))
                              (Tstruct _GraphNodeRotation noattr)) _rotation
                            (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tshort)) tshort) (Etempvar _t'5 tshort)))
                  (Ssequence
                    (Sset _t'4
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                              (Tstruct _MarioBodyState noattr)) _torsoAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                          (tptr tshort)) tshort))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _rotNode (tptr (Tstruct _GraphNodeRotation noattr)))
                              (Tstruct _GraphNodeRotation noattr)) _rotation
                            (tarray tshort 3)) (Econst_int (Int.repr 2) tint)
                          (tptr tshort)) tshort) (Etempvar _t'4 tshort)))))))
          Sskip)
        (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))))))
|}.

Definition f_geo_mario_head_rotation := {|
  fn_return := (tptr (Tunion __450 noattr));
  fn_callconv := cc_default;
  fn_params := ((_callContext, tint) ::
                (_node, (tptr (Tstruct _GraphNode noattr))) ::
                (_c, (tptr (tarray (tarray tfloat 4) 4))) :: nil);
  fn_vars := nil;
  fn_temps := ((_asGenerated, (tptr (Tstruct _GraphNodeGenerated noattr))) ::
               (_bodyState, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_action, tint) ::
               (_rotNode, (tptr (Tstruct _GraphNodeRotation noattr))) ::
               (_camera, (tptr (Tstruct _Camera noattr))) :: (_t'9, tuint) ::
               (_t'8, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'7, (tptr (Tstruct _GraphNodeCamera noattr))) ::
               (_t'6, tshort) :: (_t'5, tshort) :: (_t'4, tshort) ::
               (_t'3, tshort) :: (_t'2, tshort) :: (_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _asGenerated
    (Ecast (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
      (tptr (Tstruct _GraphNodeGenerated noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'9
        (Efield
          (Ederef
            (Etempvar _asGenerated (tptr (Tstruct _GraphNodeGenerated noattr)))
            (Tstruct _GraphNodeGenerated noattr)) _parameter tuint))
      (Sset _bodyState
        (Ebinop Oadd
          (Evar _gBodyStates (tarray (Tstruct _MarioBodyState noattr) 2))
          (Etempvar _t'9 tuint) (tptr (Tstruct _MarioBodyState noattr)))))
    (Ssequence
      (Sset _action
        (Efield
          (Ederef
            (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
            (Tstruct _MarioBodyState noattr)) _action tuint))
      (Ssequence
        (Sifthenelse (Ebinop Oeq (Etempvar _callContext tint)
                       (Econst_int (Int.repr 1) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'8
                (Efield
                  (Ederef (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
                    (Tstruct _GraphNode noattr)) _next
                  (tptr (Tstruct _GraphNode noattr))))
              (Sset _rotNode
                (Ecast (Etempvar _t'8 (tptr (Tstruct _GraphNode noattr)))
                  (tptr (Tstruct _GraphNodeRotation noattr)))))
            (Ssequence
              (Ssequence
                (Sset _t'7
                  (Evar _gCurGraphNodeCamera (tptr (Tstruct _GraphNodeCamera noattr))))
                (Sset _camera
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _t'7 (tptr (Tstruct _GraphNodeCamera noattr)))
                        (Tstruct _GraphNodeCamera noattr)) _config
                      (Tunion __1093 noattr)) _camera
                    (tptr (Tstruct _Camera noattr)))))
              (Ssequence
                (Sset _t'1
                  (Efield
                    (Ederef
                      (Etempvar _camera (tptr (Tstruct _Camera noattr)))
                      (Tstruct _Camera noattr)) _mode tuchar))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tuchar)
                               (Econst_int (Int.repr 6) tint) tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'6
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Evar _gPlayerCameraState (tarray (Tstruct _PlayerCameraState noattr) 2))
                                (Tstruct _PlayerCameraState noattr))
                              _headRotation (tarray tshort 3))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))
                          tshort))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _rotNode (tptr (Tstruct _GraphNodeRotation noattr)))
                                (Tstruct _GraphNodeRotation noattr))
                              _rotation (tarray tshort 3))
                            (Econst_int (Int.repr 0) tint) (tptr tshort))
                          tshort) (Etempvar _t'6 tshort)))
                    (Ssequence
                      (Sset _t'5
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Evar _gPlayerCameraState (tarray (Tstruct _PlayerCameraState noattr) 2))
                                (Tstruct _PlayerCameraState noattr))
                              _headRotation (tarray tshort 3))
                            (Econst_int (Int.repr 0) tint) (tptr tshort))
                          tshort))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _rotNode (tptr (Tstruct _GraphNodeRotation noattr)))
                                (Tstruct _GraphNodeRotation noattr))
                              _rotation (tarray tshort 3))
                            (Econst_int (Int.repr 2) tint) (tptr tshort))
                          tshort) (Etempvar _t'5 tshort))))
                  (Sifthenelse (Ebinop Oand (Etempvar _action tint)
                                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                   (Econst_int (Int.repr 29) tint) tint)
                                 tint)
                    (Ssequence
                      (Ssequence
                        (Sset _t'4
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                                  (Tstruct _MarioBodyState noattr))
                                _headAngle (tarray tshort 3))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))
                            tshort))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _rotNode (tptr (Tstruct _GraphNodeRotation noattr)))
                                  (Tstruct _GraphNodeRotation noattr))
                                _rotation (tarray tshort 3))
                              (Econst_int (Int.repr 0) tint) (tptr tshort))
                            tshort) (Etempvar _t'4 tshort)))
                      (Ssequence
                        (Ssequence
                          (Sset _t'3
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                                    (Tstruct _MarioBodyState noattr))
                                  _headAngle (tarray tshort 3))
                                (Econst_int (Int.repr 2) tint) (tptr tshort))
                              tshort))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _rotNode (tptr (Tstruct _GraphNodeRotation noattr)))
                                    (Tstruct _GraphNodeRotation noattr))
                                  _rotation (tarray tshort 3))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))
                              tshort) (Etempvar _t'3 tshort)))
                        (Ssequence
                          (Sset _t'2
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                                    (Tstruct _MarioBodyState noattr))
                                  _headAngle (tarray tshort 3))
                                (Econst_int (Int.repr 0) tint) (tptr tshort))
                              tshort))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _rotNode (tptr (Tstruct _GraphNodeRotation noattr)))
                                    (Tstruct _GraphNodeRotation noattr))
                                  _rotation (tarray tshort 3))
                                (Econst_int (Int.repr 2) tint) (tptr tshort))
                              tshort) (Etempvar _t'2 tshort)))))
                    (Ssequence
                      (Scall None
                        (Evar _vec3s_set (Tfunction
                                           ((tptr tshort) :: tshort ::
                                            tshort :: tshort :: nil)
                                           (tptr tvoid) cc_default))
                        ((Efield
                           (Ederef
                             (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                             (Tstruct _MarioBodyState noattr)) _headAngle
                           (tarray tshort 3)) ::
                         (Econst_int (Int.repr 0) tint) ::
                         (Econst_int (Int.repr 0) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil))
                      (Scall None
                        (Evar _vec3s_set (Tfunction
                                           ((tptr tshort) :: tshort ::
                                            tshort :: tshort :: nil)
                                           (tptr tvoid) cc_default))
                        ((Efield
                           (Ederef
                             (Etempvar _rotNode (tptr (Tstruct _GraphNodeRotation noattr)))
                             (Tstruct _GraphNodeRotation noattr)) _rotation
                           (tarray tshort 3)) ::
                         (Econst_int (Int.repr 0) tint) ::
                         (Econst_int (Int.repr 0) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil))))))))
          Sskip)
        (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))))))
|}.

Definition f_geo_switch_mario_hand := {|
  fn_return := (tptr (Tunion __450 noattr));
  fn_callconv := cc_default;
  fn_params := ((_callContext, tint) ::
                (_node, (tptr (Tstruct _GraphNode noattr))) ::
                (_c, (tptr (tarray (tarray tfloat 4) 4))) :: nil);
  fn_vars := nil;
  fn_temps := ((_switchCase, (tptr (Tstruct _GraphNodeSwitchCase noattr))) ::
               (_bodyState, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'9, tuint) ::
               (_t'8, tschar) :: (_t'7, tschar) :: (_t'6, tschar) ::
               (_t'5, tschar) :: (_t'4, tshort) :: (_t'3, tschar) :: nil);
  fn_body :=
(Ssequence
  (Sset _switchCase
    (Ecast (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
      (tptr (Tstruct _GraphNodeSwitchCase noattr))))
  (Ssequence
    (Sset _bodyState
      (Ebinop Oadd
        (Evar _gBodyStates (tarray (Tstruct _MarioBodyState noattr) 2))
        (Econst_int (Int.repr 0) tint)
        (tptr (Tstruct _MarioBodyState noattr))))
    (Ssequence
      (Sifthenelse (Ebinop Oeq (Etempvar _callContext tint)
                     (Econst_int (Int.repr 1) tint) tint)
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef
                (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                (Tstruct _MarioBodyState noattr)) _handState tschar))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tschar)
                         (Econst_int (Int.repr 0) tint) tint)
            (Ssequence
              (Sset _t'9
                (Efield
                  (Ederef
                    (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                    (Tstruct _MarioBodyState noattr)) _action tuint))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _switchCase (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                    (Tstruct _GraphNodeSwitchCase noattr)) _selectedCase
                  tshort)
                (Ebinop One
                  (Ebinop Oand (Etempvar _t'9 tuint)
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 28) tint) tint) tuint)
                  (Econst_int (Int.repr 0) tint) tint)))
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef
                    (Etempvar _switchCase (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                    (Tstruct _GraphNodeSwitchCase noattr)) _numCases tshort))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tshort)
                             (Econst_int (Int.repr 0) tint) tint)
                (Ssequence
                  (Ssequence
                    (Sset _t'7
                      (Efield
                        (Ederef
                          (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                          (Tstruct _MarioBodyState noattr)) _handState
                        tschar))
                    (Sifthenelse (Ebinop Olt (Etempvar _t'7 tschar)
                                   (Econst_int (Int.repr 5) tint) tint)
                      (Ssequence
                        (Sset _t'8
                          (Efield
                            (Ederef
                              (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                              (Tstruct _MarioBodyState noattr)) _handState
                            tschar))
                        (Sset _t'1 (Ecast (Etempvar _t'8 tschar) tint)))
                      (Sset _t'1 (Ecast (Econst_int (Int.repr 1) tint) tint))))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _switchCase (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                        (Tstruct _GraphNodeSwitchCase noattr)) _selectedCase
                      tshort) (Etempvar _t'1 tint)))
                (Ssequence
                  (Ssequence
                    (Sset _t'5
                      (Efield
                        (Ederef
                          (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                          (Tstruct _MarioBodyState noattr)) _handState
                        tschar))
                    (Sifthenelse (Ebinop Olt (Etempvar _t'5 tschar)
                                   (Econst_int (Int.repr 2) tint) tint)
                      (Ssequence
                        (Sset _t'6
                          (Efield
                            (Ederef
                              (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                              (Tstruct _MarioBodyState noattr)) _handState
                            tschar))
                        (Sset _t'2 (Ecast (Etempvar _t'6 tschar) tint)))
                      (Sset _t'2 (Ecast (Econst_int (Int.repr 0) tint) tint))))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _switchCase (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                        (Tstruct _GraphNodeSwitchCase noattr)) _selectedCase
                      tshort) (Etempvar _t'2 tint)))))))
        Sskip)
      (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))))))
|}.

Definition v_sMarioAttackAnimCounter := {|
  gvar_info := tshort;
  gvar_init := (Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_geo_mario_hand_foot_scaler := {|
  fn_return := (tptr (Tunion __450 noattr));
  fn_callconv := cc_default;
  fn_params := ((_callContext, tint) ::
                (_node, (tptr (Tstruct _GraphNode noattr))) ::
                (_c, (tptr (tarray (tarray tfloat 4) 4))) :: nil);
  fn_vars := nil;
  fn_temps := ((_asGenerated, (tptr (Tstruct _GraphNodeGenerated noattr))) ::
               (_scaleNode, (tptr (Tstruct _GraphNodeScale noattr))) ::
               (_bodyState, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'1, tint) :: (_t'12, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'11, tuchar) :: (_t'10, tushort) :: (_t'9, tshort) ::
               (_t'8, tuchar) :: (_t'7, tushort) :: (_t'6, tschar) ::
               (_t'5, tuchar) :: (_t'4, tuint) :: (_t'3, tuchar) ::
               (_t'2, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _asGenerated
    (Ecast (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
      (tptr (Tstruct _GraphNodeGenerated noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'12
        (Efield
          (Ederef (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
            (Tstruct _GraphNode noattr)) _next
          (tptr (Tstruct _GraphNode noattr))))
      (Sset _scaleNode
        (Ecast (Etempvar _t'12 (tptr (Tstruct _GraphNode noattr)))
          (tptr (Tstruct _GraphNodeScale noattr)))))
    (Ssequence
      (Sset _bodyState
        (Ebinop Oadd
          (Evar _gBodyStates (tarray (Tstruct _MarioBodyState noattr) 2))
          (Econst_int (Int.repr 0) tint)
          (tptr (Tstruct _MarioBodyState noattr))))
      (Ssequence
        (Sifthenelse (Ebinop Oeq (Etempvar _callContext tint)
                       (Econst_int (Int.repr 1) tint) tint)
          (Ssequence
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _scaleNode (tptr (Tstruct _GraphNodeScale noattr)))
                  (Tstruct _GraphNodeScale noattr)) _scale tfloat)
              (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat))
            (Ssequence
              (Sset _t'2
                (Efield
                  (Ederef
                    (Etempvar _asGenerated (tptr (Tstruct _GraphNodeGenerated noattr)))
                    (Tstruct _GraphNodeGenerated noattr)) _parameter tuint))
              (Ssequence
                (Sset _t'3
                  (Efield
                    (Ederef
                      (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                      (Tstruct _MarioBodyState noattr)) _punchState tuchar))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tuint)
                               (Ebinop Oshr (Etempvar _t'3 tuchar)
                                 (Econst_int (Int.repr 6) tint) tint) tint)
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'9 (Evar _sMarioAttackAnimCounter tshort))
                        (Ssequence
                          (Sset _t'10 (Evar _gAreaUpdateCounter tushort))
                          (Sifthenelse (Ebinop One (Etempvar _t'9 tshort)
                                         (Etempvar _t'10 tushort) tint)
                            (Ssequence
                              (Sset _t'11
                                (Efield
                                  (Ederef
                                    (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                                    (Tstruct _MarioBodyState noattr))
                                  _punchState tuchar))
                              (Sset _t'1
                                (Ecast
                                  (Ebinop Ogt
                                    (Ebinop Oand (Etempvar _t'11 tuchar)
                                      (Econst_int (Int.repr 63) tint) tint)
                                    (Econst_int (Int.repr 0) tint) tint)
                                  tbool)))
                            (Sset _t'1 (Econst_int (Int.repr 0) tint)))))
                      (Sifthenelse (Etempvar _t'1 tint)
                        (Ssequence
                          (Ssequence
                            (Sset _t'8
                              (Efield
                                (Ederef
                                  (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                                  (Tstruct _MarioBodyState noattr))
                                _punchState tuchar))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                                  (Tstruct _MarioBodyState noattr))
                                _punchState tuchar)
                              (Ebinop Osub (Etempvar _t'8 tuchar)
                                (Econst_int (Int.repr 1) tint) tint)))
                          (Ssequence
                            (Sset _t'7 (Evar _gAreaUpdateCounter tushort))
                            (Sassign (Evar _sMarioAttackAnimCounter tshort)
                              (Etempvar _t'7 tushort))))
                        Sskip))
                    (Ssequence
                      (Sset _t'4
                        (Efield
                          (Ederef
                            (Etempvar _asGenerated (tptr (Tstruct _GraphNodeGenerated noattr)))
                            (Tstruct _GraphNodeGenerated noattr)) _parameter
                          tuint))
                      (Ssequence
                        (Sset _t'5
                          (Efield
                            (Ederef
                              (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                              (Tstruct _MarioBodyState noattr)) _punchState
                            tuchar))
                        (Ssequence
                          (Sset _t'6
                            (Ederef
                              (Ebinop Oadd
                                (Evar _gMarioAttackScaleAnimation (tarray tschar 18))
                                (Ebinop Oadd
                                  (Ebinop Omul (Etempvar _t'4 tuint)
                                    (Econst_int (Int.repr 6) tint) tuint)
                                  (Ebinop Oand (Etempvar _t'5 tuchar)
                                    (Econst_int (Int.repr 63) tint) tint)
                                  tuint) (tptr tschar)) tschar))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _scaleNode (tptr (Tstruct _GraphNodeScale noattr)))
                                (Tstruct _GraphNodeScale noattr)) _scale
                              tfloat)
                            (Ebinop Odiv (Etempvar _t'6 tschar)
                              (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                              tfloat))))))
                  Sskip))))
          Sskip)
        (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))))))
|}.

Definition f_geo_switch_mario_cap_effect := {|
  fn_return := (tptr (Tunion __450 noattr));
  fn_callconv := cc_default;
  fn_params := ((_callContext, tint) ::
                (_node, (tptr (Tstruct _GraphNode noattr))) ::
                (_c, (tptr (tarray (tarray tfloat 4) 4))) :: nil);
  fn_vars := nil;
  fn_temps := ((_switchCase, (tptr (Tstruct _GraphNodeSwitchCase noattr))) ::
               (_bodyState, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'2, tshort) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _switchCase
    (Ecast (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
      (tptr (Tstruct _GraphNodeSwitchCase noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Efield
          (Ederef
            (Etempvar _switchCase (tptr (Tstruct _GraphNodeSwitchCase noattr)))
            (Tstruct _GraphNodeSwitchCase noattr)) _numCases tshort))
      (Sset _bodyState
        (Ebinop Oadd
          (Evar _gBodyStates (tarray (Tstruct _MarioBodyState noattr) 2))
          (Etempvar _t'2 tshort) (tptr (Tstruct _MarioBodyState noattr)))))
    (Ssequence
      (Sifthenelse (Ebinop Oeq (Etempvar _callContext tint)
                     (Econst_int (Int.repr 1) tint) tint)
        (Ssequence
          (Sset _t'1
            (Efield
              (Ederef
                (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                (Tstruct _MarioBodyState noattr)) _modelState tshort))
          (Sassign
            (Efield
              (Ederef
                (Etempvar _switchCase (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                (Tstruct _GraphNodeSwitchCase noattr)) _selectedCase tshort)
            (Ebinop Oshr (Etempvar _t'1 tshort)
              (Econst_int (Int.repr 8) tint) tint)))
        Sskip)
      (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))))))
|}.

Definition f_geo_switch_mario_cap_on_off := {|
  fn_return := (tptr (Tunion __450 noattr));
  fn_callconv := cc_default;
  fn_params := ((_callContext, tint) ::
                (_node, (tptr (Tstruct _GraphNode noattr))) ::
                (_c, (tptr (tarray (tarray tfloat 4) 4))) :: nil);
  fn_vars := nil;
  fn_temps := ((_next, (tptr (Tstruct _GraphNode noattr))) ::
               (_switchCase, (tptr (Tstruct _GraphNodeSwitchCase noattr))) ::
               (_bodyState, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'6, tshort) :: (_t'5, tschar) :: (_t'4, tshort) ::
               (_t'3, tshort) :: (_t'2, tschar) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _next
    (Efield
      (Ederef (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
        (Tstruct _GraphNode noattr)) _next
      (tptr (Tstruct _GraphNode noattr))))
  (Ssequence
    (Sset _switchCase
      (Ecast (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
        (tptr (Tstruct _GraphNodeSwitchCase noattr))))
    (Ssequence
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef
              (Etempvar _switchCase (tptr (Tstruct _GraphNodeSwitchCase noattr)))
              (Tstruct _GraphNodeSwitchCase noattr)) _numCases tshort))
        (Sset _bodyState
          (Ebinop Oadd
            (Evar _gBodyStates (tarray (Tstruct _MarioBodyState noattr) 2))
            (Etempvar _t'6 tshort) (tptr (Tstruct _MarioBodyState noattr)))))
      (Ssequence
        (Sifthenelse (Ebinop Oeq (Etempvar _callContext tint)
                       (Econst_int (Int.repr 1) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'5
                (Efield
                  (Ederef
                    (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                    (Tstruct _MarioBodyState noattr)) _capState tschar))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _switchCase (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                    (Tstruct _GraphNodeSwitchCase noattr)) _selectedCase
                  tshort)
                (Ebinop Oand (Etempvar _t'5 tschar)
                  (Econst_int (Int.repr 1) tint) tint)))
            (Swhile
              (Ebinop One (Etempvar _next (tptr (Tstruct _GraphNode noattr)))
                (Etempvar _node (tptr (Tstruct _GraphNode noattr))) tint)
              (Ssequence
                (Ssequence
                  (Sset _t'1
                    (Efield
                      (Ederef
                        (Etempvar _next (tptr (Tstruct _GraphNode noattr)))
                        (Tstruct _GraphNode noattr)) _type tshort))
                  (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tshort)
                                 (Econst_int (Int.repr 21) tint) tint)
                    (Ssequence
                      (Sset _t'2
                        (Efield
                          (Ederef
                            (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                            (Tstruct _MarioBodyState noattr)) _capState
                          tschar))
                      (Sifthenelse (Ebinop Oand (Etempvar _t'2 tschar)
                                     (Econst_int (Int.repr 2) tint) tint)
                        (Ssequence
                          (Sset _t'4
                            (Efield
                              (Ederef
                                (Etempvar _next (tptr (Tstruct _GraphNode noattr)))
                                (Tstruct _GraphNode noattr)) _flags tshort))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _next (tptr (Tstruct _GraphNode noattr)))
                                (Tstruct _GraphNode noattr)) _flags tshort)
                            (Ebinop Oor (Etempvar _t'4 tshort)
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 0) tint) tint) tint)))
                        (Ssequence
                          (Sset _t'3
                            (Efield
                              (Ederef
                                (Etempvar _next (tptr (Tstruct _GraphNode noattr)))
                                (Tstruct _GraphNode noattr)) _flags tshort))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _next (tptr (Tstruct _GraphNode noattr)))
                                (Tstruct _GraphNode noattr)) _flags tshort)
                            (Ebinop Oand (Etempvar _t'3 tshort)
                              (Eunop Onotint
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 0) tint) tint) tint)
                              tint)))))
                    Sskip))
                (Sset _next
                  (Efield
                    (Ederef
                      (Etempvar _next (tptr (Tstruct _GraphNode noattr)))
                      (Tstruct _GraphNode noattr)) _next
                    (tptr (Tstruct _GraphNode noattr)))))))
          Sskip)
        (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))))))
|}.

Definition f_geo_mario_rotate_wing_cap_wings := {|
  fn_return := (tptr (Tunion __450 noattr));
  fn_callconv := cc_default;
  fn_params := ((_callContext, tint) ::
                (_node, (tptr (Tstruct _GraphNode noattr))) ::
                (_c, (tptr (tarray (tarray tfloat 4) 4))) :: nil);
  fn_vars := nil;
  fn_temps := ((_rotX, tshort) ::
               (_asGenerated, (tptr (Tstruct _GraphNodeGenerated noattr))) ::
               (_rotNode, (tptr (Tstruct _GraphNodeRotation noattr))) ::
               (_t'8, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'7, tfloat) :: (_t'6, tushort) :: (_t'5, tfloat) ::
               (_t'4, tushort) :: (_t'3, tschar) :: (_t'2, tuint) ::
               (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _asGenerated
    (Ecast (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
      (tptr (Tstruct _GraphNodeGenerated noattr))))
  (Ssequence
    (Sifthenelse (Ebinop Oeq (Etempvar _callContext tint)
                   (Econst_int (Int.repr 1) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'8
            (Efield
              (Ederef (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
                (Tstruct _GraphNode noattr)) _next
              (tptr (Tstruct _GraphNode noattr))))
          (Sset _rotNode
            (Ecast (Etempvar _t'8 (tptr (Tstruct _GraphNode noattr)))
              (tptr (Tstruct _GraphNodeRotation noattr)))))
        (Ssequence
          (Ssequence
            (Sset _t'2
              (Efield
                (Ederef
                  (Etempvar _asGenerated (tptr (Tstruct _GraphNodeGenerated noattr)))
                  (Tstruct _GraphNodeGenerated noattr)) _parameter tuint))
            (Ssequence
              (Sset _t'3
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Evar _gBodyStates (tarray (Tstruct _MarioBodyState noattr) 2))
                      (Ebinop Oshr (Etempvar _t'2 tuint)
                        (Econst_int (Int.repr 1) tint) tuint)
                      (tptr (Tstruct _MarioBodyState noattr)))
                    (Tstruct _MarioBodyState noattr)) _wingFlutter tschar))
              (Sifthenelse (Eunop Onotbool (Etempvar _t'3 tschar) tint)
                (Ssequence
                  (Sset _t'6 (Evar _gAreaUpdateCounter tushort))
                  (Ssequence
                    (Sset _t'7
                      (Ederef
                        (Ebinop Oadd
                          (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                            (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                          (Ebinop Oshr
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand (Etempvar _t'6 tushort)
                                  (Econst_int (Int.repr 15) tint) tint)
                                (Econst_int (Int.repr 12) tint) tint)
                              tushort) (Econst_int (Int.repr 4) tint) tint)
                          (tptr tfloat)) tfloat))
                    (Sset _rotX
                      (Ecast
                        (Ebinop Omul
                          (Ebinop Oadd (Etempvar _t'7 tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                            tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1166016512)) tfloat)
                          tfloat) tshort))))
                (Ssequence
                  (Sset _t'4 (Evar _gAreaUpdateCounter tushort))
                  (Ssequence
                    (Sset _t'5
                      (Ederef
                        (Ebinop Oadd
                          (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                            (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                          (Ebinop Oshr
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand (Etempvar _t'4 tushort)
                                  (Econst_int (Int.repr 7) tint) tint)
                                (Econst_int (Int.repr 13) tint) tint)
                              tushort) (Econst_int (Int.repr 4) tint) tint)
                          (tptr tfloat)) tfloat))
                    (Sset _rotX
                      (Ecast
                        (Ebinop Omul
                          (Ebinop Oadd (Etempvar _t'5 tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                            tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1170210816)) tfloat)
                          tfloat) tshort)))))))
          (Ssequence
            (Sset _t'1
              (Efield
                (Ederef
                  (Etempvar _asGenerated (tptr (Tstruct _GraphNodeGenerated noattr)))
                  (Tstruct _GraphNodeGenerated noattr)) _parameter tuint))
            (Sifthenelse (Eunop Onotbool
                           (Ebinop Oand (Etempvar _t'1 tuint)
                             (Econst_int (Int.repr 1) tint) tuint) tint)
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _rotNode (tptr (Tstruct _GraphNodeRotation noattr)))
                        (Tstruct _GraphNodeRotation noattr)) _rotation
                      (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                    (tptr tshort)) tshort)
                (Eunop Oneg (Etempvar _rotX tshort) tint))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _rotNode (tptr (Tstruct _GraphNodeRotation noattr)))
                        (Tstruct _GraphNodeRotation noattr)) _rotation
                      (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                    (tptr tshort)) tshort) (Etempvar _rotX tshort))))))
      Sskip)
    (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))))
|}.

Definition f_geo_switch_mario_hand_grab_pos := {|
  fn_return := (tptr (Tunion __450 noattr));
  fn_callconv := cc_default;
  fn_params := ((_callContext, tint) ::
                (_b, (tptr (Tstruct _GraphNode noattr))) ::
                (_mtx, (tptr (tarray (tarray tfloat 4) 4))) :: nil);
  fn_vars := nil;
  fn_temps := ((_asHeldObj, (tptr (Tstruct _GraphNodeHeldObject noattr))) ::
               (_curTransform, (tptr (tarray (tarray tfloat 4) 4))) ::
               (_marioState, (tptr (Tstruct _MarioState noattr))) ::
               (_t'9, tint) :: (_t'8, (tptr (Tstruct _Object noattr))) ::
               (_t'7, tuint) :: (_t'6, tschar) ::
               (_t'5, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (tarray (tarray tfloat 4) 4))) ::
               (_t'2, (tptr (Tstruct _GraphNodeCamera noattr))) ::
               (_t'1, (tptr (Tstruct _MarioBodyState noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _asHeldObj
    (Ecast (Etempvar _b (tptr (Tstruct _GraphNode noattr)))
      (tptr (Tstruct _GraphNodeHeldObject noattr))))
  (Ssequence
    (Sset _curTransform (Etempvar _mtx (tptr (tarray (tarray tfloat 4) 4))))
    (Ssequence
      (Ssequence
        (Sset _t'9
          (Efield
            (Ederef
              (Etempvar _asHeldObj (tptr (Tstruct _GraphNodeHeldObject noattr)))
              (Tstruct _GraphNodeHeldObject noattr)) _playerIndex tint))
        (Sset _marioState
          (Ebinop Oadd
            (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
            (Etempvar _t'9 tint) (tptr (Tstruct _MarioState noattr)))))
      (Ssequence
        (Sifthenelse (Ebinop Oeq (Etempvar _callContext tint)
                       (Econst_int (Int.repr 1) tint) tint)
          (Ssequence
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _asHeldObj (tptr (Tstruct _GraphNodeHeldObject noattr)))
                  (Tstruct _GraphNodeHeldObject noattr)) _objNode
                (tptr (Tstruct _Object noattr)))
              (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef
                    (Etempvar _marioState (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _heldObj
                  (tptr (Tstruct _Object noattr))))
              (Sifthenelse (Ebinop One
                             (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                             (Ecast (Econst_int (Int.repr 0) tint)
                               (tptr tvoid)) tint)
                (Ssequence
                  (Ssequence
                    (Sset _t'8
                      (Efield
                        (Ederef
                          (Etempvar _marioState (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _heldObj
                        (tptr (Tstruct _Object noattr))))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _asHeldObj (tptr (Tstruct _GraphNodeHeldObject noattr)))
                          (Tstruct _GraphNodeHeldObject noattr)) _objNode
                        (tptr (Tstruct _Object noattr)))
                      (Etempvar _t'8 (tptr (Tstruct _Object noattr)))))
                  (Ssequence
                    (Sset _t'5
                      (Efield
                        (Ederef
                          (Etempvar _marioState (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _marioBodyState
                        (tptr (Tstruct _MarioBodyState noattr))))
                    (Ssequence
                      (Sset _t'6
                        (Efield
                          (Ederef
                            (Etempvar _t'5 (tptr (Tstruct _MarioBodyState noattr)))
                            (Tstruct _MarioBodyState noattr)) _grabPos
                          tschar))
                      (Sswitch (Etempvar _t'6 tschar)
                        (LScons (Some 1)
                          (Ssequence
                            (Ssequence
                              (Sset _t'7
                                (Efield
                                  (Ederef
                                    (Etempvar _marioState (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _action
                                  tuint))
                              (Sifthenelse (Ebinop Oand (Etempvar _t'7 tuint)
                                             (Ebinop Oshl
                                               (Econst_int (Int.repr 1) tint)
                                               (Econst_int (Int.repr 31) tint)
                                               tint) tuint)
                                (Scall None
                                  (Evar _vec3s_set (Tfunction
                                                     ((tptr tshort) ::
                                                      tshort :: tshort ::
                                                      tshort :: nil)
                                                     (tptr tvoid) cc_default))
                                  ((Efield
                                     (Ederef
                                       (Etempvar _asHeldObj (tptr (Tstruct _GraphNodeHeldObject noattr)))
                                       (Tstruct _GraphNodeHeldObject noattr))
                                     _translation (tarray tshort 3)) ::
                                   (Econst_int (Int.repr 50) tint) ::
                                   (Econst_int (Int.repr 0) tint) ::
                                   (Econst_int (Int.repr 0) tint) :: nil))
                                (Scall None
                                  (Evar _vec3s_set (Tfunction
                                                     ((tptr tshort) ::
                                                      tshort :: tshort ::
                                                      tshort :: nil)
                                                     (tptr tvoid) cc_default))
                                  ((Efield
                                     (Ederef
                                       (Etempvar _asHeldObj (tptr (Tstruct _GraphNodeHeldObject noattr)))
                                       (Tstruct _GraphNodeHeldObject noattr))
                                     _translation (tarray tshort 3)) ::
                                   (Econst_int (Int.repr 50) tint) ::
                                   (Econst_int (Int.repr 0) tint) ::
                                   (Econst_int (Int.repr 110) tint) :: nil))))
                            Sbreak)
                          (LScons (Some 2)
                            (Ssequence
                              (Scall None
                                (Evar _vec3s_set (Tfunction
                                                   ((tptr tshort) ::
                                                    tshort :: tshort ::
                                                    tshort :: nil)
                                                   (tptr tvoid) cc_default))
                                ((Efield
                                   (Ederef
                                     (Etempvar _asHeldObj (tptr (Tstruct _GraphNodeHeldObject noattr)))
                                     (Tstruct _GraphNodeHeldObject noattr))
                                   _translation (tarray tshort 3)) ::
                                 (Econst_int (Int.repr 145) tint) ::
                                 (Eunop Oneg (Econst_int (Int.repr 173) tint)
                                   tint) ::
                                 (Econst_int (Int.repr 180) tint) :: nil))
                              Sbreak)
                            (LScons (Some 3)
                              (Ssequence
                                (Scall None
                                  (Evar _vec3s_set (Tfunction
                                                     ((tptr tshort) ::
                                                      tshort :: tshort ::
                                                      tshort :: nil)
                                                     (tptr tvoid) cc_default))
                                  ((Efield
                                     (Ederef
                                       (Etempvar _asHeldObj (tptr (Tstruct _GraphNodeHeldObject noattr)))
                                       (Tstruct _GraphNodeHeldObject noattr))
                                     _translation (tarray tshort 3)) ::
                                   (Econst_int (Int.repr 80) tint) ::
                                   (Eunop Oneg
                                     (Econst_int (Int.repr 270) tint) tint) ::
                                   (Econst_int (Int.repr 1260) tint) :: nil))
                                Sbreak)
                              LSnil)))))))
                Sskip)))
          (Sifthenelse (Ebinop Oeq (Etempvar _callContext tint)
                         (Econst_int (Int.repr 5) tint) tint)
            (Ssequence
              (Sset _t'1
                (Efield
                  (Ederef
                    (Etempvar _marioState (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioBodyState
                  (tptr (Tstruct _MarioBodyState noattr))))
              (Ssequence
                (Sset _t'2
                  (Evar _gCurGraphNodeCamera (tptr (Tstruct _GraphNodeCamera noattr))))
                (Ssequence
                  (Sset _t'3
                    (Efield
                      (Ederef
                        (Etempvar _t'2 (tptr (Tstruct _GraphNodeCamera noattr)))
                        (Tstruct _GraphNodeCamera noattr)) _matrixPtr
                      (tptr (tarray (tarray tfloat 4) 4))))
                  (Scall None
                    (Evar _get_pos_from_transform_mtx (Tfunction
                                                        ((tptr tfloat) ::
                                                         (tptr (tarray tfloat 4)) ::
                                                         (tptr (tarray tfloat 4)) ::
                                                         nil) tvoid
                                                        cc_default))
                    ((Efield
                       (Ederef
                         (Etempvar _t'1 (tptr (Tstruct _MarioBodyState noattr)))
                         (Tstruct _MarioBodyState noattr))
                       _heldObjLastPosition (tarray tfloat 3)) ::
                     (Ederef
                       (Etempvar _curTransform (tptr (tarray (tarray tfloat 4) 4)))
                       (tarray (tarray tfloat 4) 4)) ::
                     (Ederef
                       (Etempvar _t'3 (tptr (tarray (tarray tfloat 4) 4)))
                       (tarray (tarray tfloat 4) 4)) :: nil)))))
            Sskip))
        (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))))))
|}.

Definition f_geo_render_mirror_mario := {|
  fn_return := (tptr (Tunion __450 noattr));
  fn_callconv := cc_default;
  fn_params := ((_callContext, tint) ::
                (_node, (tptr (Tstruct _GraphNode noattr))) ::
                (_c, (tptr (tarray (tarray tfloat 4) 4))) :: nil);
  fn_vars := nil;
  fn_temps := ((_mirroredX, tfloat) ::
               (_mario, (tptr (Tstruct _Object noattr))) ::
               (_t'8, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'7, tschar) :: (_t'6, tfloat) :: (_t'5, tshort) ::
               (_t'4, tfloat) :: (_t'3, tshort) :: (_t'2, tshort) ::
               (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _mario
    (Efield
      (Ederef
        (Ebinop Oadd
          (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
          (Econst_int (Int.repr 0) tint) (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Sswitch (Etempvar _callContext tint)
      (LScons (Some 0)
        (Ssequence
          (Scall None
            (Evar _init_graph_node_object (Tfunction
                                            ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                             (tptr (Tstruct _GraphNodeObject noattr)) ::
                                             (tptr (Tstruct _GraphNode noattr)) ::
                                             (tptr tfloat) ::
                                             (tptr tshort) ::
                                             (tptr tfloat) :: nil)
                                            (tptr (Tstruct _GraphNodeObject noattr))
                                            cc_default))
            ((Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
             (Eaddrof (Evar _gMirrorMario (Tstruct _GraphNodeObject noattr))
               (tptr (Tstruct _GraphNodeObject noattr))) ::
             (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
             (Evar _gVec3fZero (tarray tfloat 3)) ::
             (Evar _gVec3sZero (tarray tshort 3)) ::
             (Evar _gVec3fOne (tarray tfloat 3)) :: nil))
          Sbreak)
        (LScons (Some 3)
          (Ssequence
            (Scall None
              (Evar _geo_add_child (Tfunction
                                     ((tptr (Tstruct _GraphNode noattr)) ::
                                      (tptr (Tstruct _GraphNode noattr)) ::
                                      nil) (tptr (Tstruct _GraphNode noattr))
                                     cc_default))
              ((Etempvar _node (tptr (Tstruct _GraphNode noattr))) ::
               (Eaddrof
                 (Efield
                   (Evar _gMirrorMario (Tstruct _GraphNodeObject noattr))
                   _node (Tstruct _GraphNode noattr))
                 (tptr (Tstruct _GraphNode noattr))) :: nil))
            Sbreak)
          (LScons (Some 2)
            (Ssequence
              (Scall None
                (Evar _geo_remove_child (Tfunction
                                          ((tptr (Tstruct _GraphNode noattr)) ::
                                           nil)
                                          (tptr (Tstruct _GraphNode noattr))
                                          cc_default))
                ((Eaddrof
                   (Efield
                     (Evar _gMirrorMario (Tstruct _GraphNodeObject noattr))
                     _node (Tstruct _GraphNode noattr))
                   (tptr (Tstruct _GraphNode noattr))) :: nil))
              Sbreak)
            (LScons (Some 1)
              (Ssequence
                (Ssequence
                  (Sset _t'1
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _mario (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _header
                              (Tstruct _ObjectNode noattr)) _gfx
                            (Tstruct _GraphNodeObject noattr)) _pos
                          (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tfloat)) tfloat))
                  (Sifthenelse (Ebinop Ogt (Etempvar _t'1 tfloat)
                                 (Econst_single (Float32.of_bits (Int.repr 1154777088)) tfloat)
                                 tint)
                    (Ssequence
                      (Ssequence
                        (Sset _t'8
                          (Efield
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _mario (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _header
                                (Tstruct _ObjectNode noattr)) _gfx
                              (Tstruct _GraphNodeObject noattr)) _sharedChild
                            (tptr (Tstruct _GraphNode noattr))))
                        (Sassign
                          (Efield
                            (Evar _gMirrorMario (Tstruct _GraphNodeObject noattr))
                            _sharedChild (tptr (Tstruct _GraphNode noattr)))
                          (Etempvar _t'8 (tptr (Tstruct _GraphNode noattr)))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'7
                            (Efield
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _mario (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _header
                                  (Tstruct _ObjectNode noattr)) _gfx
                                (Tstruct _GraphNodeObject noattr)) _areaIndex
                              tschar))
                          (Sassign
                            (Efield
                              (Evar _gMirrorMario (Tstruct _GraphNodeObject noattr))
                              _areaIndex tschar) (Etempvar _t'7 tschar)))
                        (Ssequence
                          (Scall None
                            (Evar _vec3s_copy (Tfunction
                                                ((tptr tshort) ::
                                                 (tptr tshort) :: nil)
                                                (tptr tvoid) cc_default))
                            ((Efield
                               (Evar _gMirrorMario (Tstruct _GraphNodeObject noattr))
                               _angle (tarray tshort 3)) ::
                             (Efield
                               (Efield
                                 (Efield
                                   (Ederef
                                     (Etempvar _mario (tptr (Tstruct _Object noattr)))
                                     (Tstruct _Object noattr)) _header
                                   (Tstruct _ObjectNode noattr)) _gfx
                                 (Tstruct _GraphNodeObject noattr)) _angle
                               (tarray tshort 3)) :: nil))
                          (Ssequence
                            (Scall None
                              (Evar _vec3f_copy (Tfunction
                                                  ((tptr tfloat) ::
                                                   (tptr tfloat) :: nil)
                                                  (tptr tvoid) cc_default))
                              ((Efield
                                 (Evar _gMirrorMario (Tstruct _GraphNodeObject noattr))
                                 _pos (tarray tfloat 3)) ::
                               (Efield
                                 (Efield
                                   (Efield
                                     (Ederef
                                       (Etempvar _mario (tptr (Tstruct _Object noattr)))
                                       (Tstruct _Object noattr)) _header
                                     (Tstruct _ObjectNode noattr)) _gfx
                                   (Tstruct _GraphNodeObject noattr)) _pos
                                 (tarray tfloat 3)) :: nil))
                            (Ssequence
                              (Scall None
                                (Evar _vec3f_copy (Tfunction
                                                    ((tptr tfloat) ::
                                                     (tptr tfloat) :: nil)
                                                    (tptr tvoid) cc_default))
                                ((Efield
                                   (Evar _gMirrorMario (Tstruct _GraphNodeObject noattr))
                                   _scale (tarray tfloat 3)) ::
                                 (Efield
                                   (Efield
                                     (Efield
                                       (Ederef
                                         (Etempvar _mario (tptr (Tstruct _Object noattr)))
                                         (Tstruct _Object noattr)) _header
                                       (Tstruct _ObjectNode noattr)) _gfx
                                     (Tstruct _GraphNodeObject noattr))
                                   _scale (tarray tfloat 3)) :: nil))
                              (Ssequence
                                (Sassign
                                  (Efield
                                    (Evar _gMirrorMario (Tstruct _GraphNodeObject noattr))
                                    _animInfo (Tstruct _AnimInfo noattr))
                                  (Efield
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _mario (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _header
                                        (Tstruct _ObjectNode noattr)) _gfx
                                      (Tstruct _GraphNodeObject noattr))
                                    _animInfo (Tstruct _AnimInfo noattr)))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'6
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Evar _gMirrorMario (Tstruct _GraphNodeObject noattr))
                                            _pos (tarray tfloat 3))
                                          (Econst_int (Int.repr 0) tint)
                                          (tptr tfloat)) tfloat))
                                    (Sset _mirroredX
                                      (Ecast
                                        (Ebinop Osub
                                          (Econst_float (Float.of_bits (Int64.repr 4661484582302153441)) tdouble)
                                          (Etempvar _t'6 tfloat) tdouble)
                                        tfloat)))
                                  (Ssequence
                                    (Sassign
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Evar _gMirrorMario (Tstruct _GraphNodeObject noattr))
                                            _pos (tarray tfloat 3))
                                          (Econst_int (Int.repr 0) tint)
                                          (tptr tfloat)) tfloat)
                                      (Ebinop Oadd
                                        (Etempvar _mirroredX tfloat)
                                        (Econst_float (Float.of_bits (Int64.repr 4661484582302153441)) tdouble)
                                        tdouble))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'5
                                          (Ederef
                                            (Ebinop Oadd
                                              (Efield
                                                (Evar _gMirrorMario (Tstruct _GraphNodeObject noattr))
                                                _angle (tarray tshort 3))
                                              (Econst_int (Int.repr 1) tint)
                                              (tptr tshort)) tshort))
                                        (Sassign
                                          (Ederef
                                            (Ebinop Oadd
                                              (Efield
                                                (Evar _gMirrorMario (Tstruct _GraphNodeObject noattr))
                                                _angle (tarray tshort 3))
                                              (Econst_int (Int.repr 1) tint)
                                              (tptr tshort)) tshort)
                                          (Eunop Oneg (Etempvar _t'5 tshort)
                                            tint)))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'4
                                            (Ederef
                                              (Ebinop Oadd
                                                (Efield
                                                  (Evar _gMirrorMario (Tstruct _GraphNodeObject noattr))
                                                  _scale (tarray tfloat 3))
                                                (Econst_int (Int.repr 0) tint)
                                                (tptr tfloat)) tfloat))
                                          (Sassign
                                            (Ederef
                                              (Ebinop Oadd
                                                (Efield
                                                  (Evar _gMirrorMario (Tstruct _GraphNodeObject noattr))
                                                  _scale (tarray tfloat 3))
                                                (Econst_int (Int.repr 0) tint)
                                                (tptr tfloat)) tfloat)
                                            (Ebinop Omul
                                              (Etempvar _t'4 tfloat)
                                              (Eunop Oneg
                                                (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                                                tfloat) tfloat)))
                                        (Ssequence
                                          (Sset _t'3
                                            (Efield
                                              (Ederef
                                                (Ecast
                                                  (Eaddrof
                                                    (Evar _gMirrorMario (Tstruct _GraphNodeObject noattr))
                                                    (tptr (Tstruct _GraphNodeObject noattr)))
                                                  (tptr (Tstruct _GraphNode noattr)))
                                                (Tstruct _GraphNode noattr))
                                              _flags tshort))
                                          (Sassign
                                            (Efield
                                              (Ederef
                                                (Ecast
                                                  (Eaddrof
                                                    (Evar _gMirrorMario (Tstruct _GraphNodeObject noattr))
                                                    (tptr (Tstruct _GraphNodeObject noattr)))
                                                  (tptr (Tstruct _GraphNode noattr)))
                                                (Tstruct _GraphNode noattr))
                                              _flags tshort)
                                            (Ebinop Oor
                                              (Etempvar _t'3 tshort)
                                              (Ebinop Oshl
                                                (Econst_int (Int.repr 1) tint)
                                                (Econst_int (Int.repr 0) tint)
                                                tint) tint)))))))))))))
                    (Ssequence
                      (Sset _t'2
                        (Efield
                          (Ederef
                            (Ecast
                              (Eaddrof
                                (Evar _gMirrorMario (Tstruct _GraphNodeObject noattr))
                                (tptr (Tstruct _GraphNodeObject noattr)))
                              (tptr (Tstruct _GraphNode noattr)))
                            (Tstruct _GraphNode noattr)) _flags tshort))
                      (Sassign
                        (Efield
                          (Ederef
                            (Ecast
                              (Eaddrof
                                (Evar _gMirrorMario (Tstruct _GraphNodeObject noattr))
                                (tptr (Tstruct _GraphNodeObject noattr)))
                              (tptr (Tstruct _GraphNode noattr)))
                            (Tstruct _GraphNode noattr)) _flags tshort)
                        (Ebinop Oand (Etempvar _t'2 tshort)
                          (Eunop Onotint
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 0) tint) tint) tint)
                          tint)))))
                Sbreak)
              LSnil)))))
    (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))))
|}.

Definition f_geo_mirror_mario_backface_culling := {|
  fn_return := (tptr (Tunion __450 noattr));
  fn_callconv := cc_default;
  fn_params := ((_callContext, tint) ::
                (_node, (tptr (Tstruct _GraphNode noattr))) ::
                (_c, (tptr (tarray (tarray tfloat 4) 4))) :: nil);
  fn_vars := nil;
  fn_temps := ((_asGenerated, (tptr (Tstruct _GraphNodeGenerated noattr))) ::
               (_gfx, (tptr (Tunion __450 noattr))) ::
               (__g, (tptr (Tunion __450 noattr))) ::
               (__g__1, (tptr (Tunion __450 noattr))) ::
               (__g__2, (tptr (Tunion __450 noattr))) ::
               (__g__3, (tptr (Tunion __450 noattr))) ::
               (__g__4, (tptr (Tunion __450 noattr))) ::
               (__g__5, (tptr (Tunion __450 noattr))) :: (_t'2, tint) ::
               (_t'1, (tptr tvoid)) ::
               (_t'5, (tptr (Tstruct _GraphNodeObject noattr))) ::
               (_t'4, tuint) :: (_t'3, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _asGenerated
    (Ecast (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
      (tptr (Tstruct _GraphNodeGenerated noattr))))
  (Ssequence
    (Sset _gfx (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
    (Ssequence
      (Ssequence
        (Sifthenelse (Ebinop Oeq (Etempvar _callContext tint)
                       (Econst_int (Int.repr 1) tint) tint)
          (Ssequence
            (Sset _t'5
              (Evar _gCurGraphNodeObject (tptr (Tstruct _GraphNodeObject noattr))))
            (Sset _t'2
              (Ecast
                (Ebinop Oeq
                  (Etempvar _t'5 (tptr (Tstruct _GraphNodeObject noattr)))
                  (Eaddrof
                    (Evar _gMirrorMario (Tstruct _GraphNodeObject noattr))
                    (tptr (Tstruct _GraphNodeObject noattr))) tint) tbool)))
          (Sset _t'2 (Econst_int (Int.repr 0) tint)))
        (Sifthenelse (Etempvar _t'2 tint)
          (Ssequence
            (Ssequence
              (Scall (Some _t'1)
                (Evar _alloc_display_list (Tfunction (tuint :: nil)
                                            (tptr tvoid) cc_default))
                ((Ebinop Omul (Econst_int (Int.repr 3) tint)
                   (Esizeof (Tunion __450 noattr) tulong) tulong) :: nil))
              (Sset _gfx (Etempvar _t'1 (tptr tvoid))))
            (Ssequence
              (Ssequence
                (Sset _t'4
                  (Efield
                    (Ederef
                      (Etempvar _asGenerated (tptr (Tstruct _GraphNodeGenerated noattr)))
                      (Tstruct _GraphNodeGenerated noattr)) _parameter tuint))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tuint)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Ssequence
                    (Ssequence
                      (Sset __g
                        (Ecast
                          (Ebinop Oadd
                            (Etempvar _gfx (tptr (Tunion __450 noattr)))
                            (Econst_int (Int.repr 0) tint)
                            (tptr (Tunion __450 noattr)))
                          (tptr (Tunion __450 noattr))))
                      (Ssequence
                        (Sassign
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar __g (tptr (Tunion __450 noattr)))
                                (Tunion __450 noattr)) _words
                              (Tstruct __448 noattr)) _w0 tuint)
                          (Ebinop Oor
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Econst_int (Int.repr 217) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 8) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 24) tint)
                                tuint) tuint)
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast
                                    (Eunop Onotint
                                      (Ecast
                                        (Econst_int (Int.repr 1024) tint)
                                        tuint) tuint) tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 24) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 0) tint)
                                tuint) tuint) tuint))
                        (Sassign
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar __g (tptr (Tunion __450 noattr)))
                                (Tunion __450 noattr)) _words
                              (Tstruct __448 noattr)) _w1 tuint)
                          (Ecast (Econst_int (Int.repr 0) tint) tuint))))
                    (Ssequence
                      (Ssequence
                        (Sset __g__1
                          (Ecast
                            (Ebinop Oadd
                              (Etempvar _gfx (tptr (Tunion __450 noattr)))
                              (Econst_int (Int.repr 1) tint)
                              (tptr (Tunion __450 noattr)))
                            (tptr (Tunion __450 noattr))))
                        (Ssequence
                          (Sassign
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar __g__1 (tptr (Tunion __450 noattr)))
                                  (Tunion __450 noattr)) _words
                                (Tstruct __448 noattr)) _w0 tuint)
                            (Ebinop Oor
                              (Ecast
                                (Ebinop Oshl
                                  (Ebinop Oand
                                    (Ecast (Econst_int (Int.repr 217) tint)
                                      tuint)
                                    (Ebinop Osub
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 8) tint) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuint) (Econst_int (Int.repr 24) tint)
                                  tuint) tuint)
                              (Ecast
                                (Ebinop Oshl
                                  (Ebinop Oand
                                    (Ecast
                                      (Eunop Onotint
                                        (Ecast (Econst_int (Int.repr 0) tint)
                                          tuint) tuint) tuint)
                                    (Ebinop Osub
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 24) tint) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuint) (Econst_int (Int.repr 0) tint)
                                  tuint) tuint) tuint))
                          (Sassign
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar __g__1 (tptr (Tunion __450 noattr)))
                                  (Tunion __450 noattr)) _words
                                (Tstruct __448 noattr)) _w1 tuint)
                            (Ecast (Econst_int (Int.repr 512) tint) tuint))))
                      (Ssequence
                        (Sset __g__2
                          (Ecast
                            (Ebinop Oadd
                              (Etempvar _gfx (tptr (Tunion __450 noattr)))
                              (Econst_int (Int.repr 2) tint)
                              (tptr (Tunion __450 noattr)))
                            (tptr (Tunion __450 noattr))))
                        (Ssequence
                          (Sassign
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar __g__2 (tptr (Tunion __450 noattr)))
                                  (Tunion __450 noattr)) _words
                                (Tstruct __448 noattr)) _w0 tuint)
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Econst_int (Int.repr 223) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 8) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 24) tint)
                                tuint) tuint))
                          (Sassign
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar __g__2 (tptr (Tunion __450 noattr)))
                                  (Tunion __450 noattr)) _words
                                (Tstruct __448 noattr)) _w1 tuint)
                            (Econst_int (Int.repr 0) tint))))))
                  (Ssequence
                    (Ssequence
                      (Sset __g__3
                        (Ecast
                          (Ebinop Oadd
                            (Etempvar _gfx (tptr (Tunion __450 noattr)))
                            (Econst_int (Int.repr 0) tint)
                            (tptr (Tunion __450 noattr)))
                          (tptr (Tunion __450 noattr))))
                      (Ssequence
                        (Sassign
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar __g__3 (tptr (Tunion __450 noattr)))
                                (Tunion __450 noattr)) _words
                              (Tstruct __448 noattr)) _w0 tuint)
                          (Ebinop Oor
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Econst_int (Int.repr 217) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 8) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 24) tint)
                                tuint) tuint)
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast
                                    (Eunop Onotint
                                      (Ecast (Econst_int (Int.repr 512) tint)
                                        tuint) tuint) tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 24) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 0) tint)
                                tuint) tuint) tuint))
                        (Sassign
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar __g__3 (tptr (Tunion __450 noattr)))
                                (Tunion __450 noattr)) _words
                              (Tstruct __448 noattr)) _w1 tuint)
                          (Ecast (Econst_int (Int.repr 0) tint) tuint))))
                    (Ssequence
                      (Ssequence
                        (Sset __g__4
                          (Ecast
                            (Ebinop Oadd
                              (Etempvar _gfx (tptr (Tunion __450 noattr)))
                              (Econst_int (Int.repr 1) tint)
                              (tptr (Tunion __450 noattr)))
                            (tptr (Tunion __450 noattr))))
                        (Ssequence
                          (Sassign
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar __g__4 (tptr (Tunion __450 noattr)))
                                  (Tunion __450 noattr)) _words
                                (Tstruct __448 noattr)) _w0 tuint)
                            (Ebinop Oor
                              (Ecast
                                (Ebinop Oshl
                                  (Ebinop Oand
                                    (Ecast (Econst_int (Int.repr 217) tint)
                                      tuint)
                                    (Ebinop Osub
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 8) tint) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuint) (Econst_int (Int.repr 24) tint)
                                  tuint) tuint)
                              (Ecast
                                (Ebinop Oshl
                                  (Ebinop Oand
                                    (Ecast
                                      (Eunop Onotint
                                        (Ecast (Econst_int (Int.repr 0) tint)
                                          tuint) tuint) tuint)
                                    (Ebinop Osub
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 24) tint) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuint) (Econst_int (Int.repr 0) tint)
                                  tuint) tuint) tuint))
                          (Sassign
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar __g__4 (tptr (Tunion __450 noattr)))
                                  (Tunion __450 noattr)) _words
                                (Tstruct __448 noattr)) _w1 tuint)
                            (Ecast (Econst_int (Int.repr 1024) tint) tuint))))
                      (Ssequence
                        (Sset __g__5
                          (Ecast
                            (Ebinop Oadd
                              (Etempvar _gfx (tptr (Tunion __450 noattr)))
                              (Econst_int (Int.repr 2) tint)
                              (tptr (Tunion __450 noattr)))
                            (tptr (Tunion __450 noattr))))
                        (Ssequence
                          (Sassign
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar __g__5 (tptr (Tunion __450 noattr)))
                                  (Tunion __450 noattr)) _words
                                (Tstruct __448 noattr)) _w0 tuint)
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Econst_int (Int.repr 223) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 8) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 24) tint)
                                tuint) tuint))
                          (Sassign
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar __g__5 (tptr (Tunion __450 noattr)))
                                  (Tunion __450 noattr)) _words
                                (Tstruct __448 noattr)) _w1 tuint)
                            (Econst_int (Int.repr 0) tint))))))))
              (Ssequence
                (Sset _t'3
                  (Efield
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _asGenerated (tptr (Tstruct _GraphNodeGenerated noattr)))
                          (Tstruct _GraphNodeGenerated noattr)) _fnNode
                        (Tstruct _FnGraphNode noattr)) _node
                      (Tstruct _GraphNode noattr)) _flags tshort))
                (Sassign
                  (Efield
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _asGenerated (tptr (Tstruct _GraphNodeGenerated noattr)))
                          (Tstruct _GraphNodeGenerated noattr)) _fnNode
                        (Tstruct _FnGraphNode noattr)) _node
                      (Tstruct _GraphNode noattr)) _flags tshort)
                  (Ebinop Oor
                    (Ebinop Oand (Etempvar _t'3 tshort)
                      (Econst_int (Int.repr 255) tint) tint)
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 8) tint) tint) tint)))))
          Sskip))
      (Sreturn (Some (Etempvar _gfx (tptr (Tunion __450 noattr))))))))
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
 Composite __370 Struct
   (Member_plain _flag tuchar :: Member_plain _v (tarray tuchar 3) :: nil)
   noattr ::
 Composite __411 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _par I32 Unsigned noattr 8 false ::
    Member_bitfield _len I32 Unsigned noattr 16 false ::
    Member_plain _addr tuint :: nil)
   noattr ::
 Composite __413 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad I32 Signed noattr 24 false ::
    Member_plain _tri (Tstruct __370 noattr) :: nil)
   noattr ::
 Composite __415 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad1 I32 Signed noattr 24 false ::
    Member_bitfield _pad2 I32 Signed noattr 24 false ::
    Member_bitfield _param I8 Unsigned noattr 8 false :: nil)
   noattr ::
 Composite __417 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad0 I32 Signed noattr 8 false ::
    Member_bitfield _mw_index I32 Signed noattr 8 false ::
    Member_bitfield _number I32 Signed noattr 8 false ::
    Member_bitfield _pad1 I32 Signed noattr 8 false ::
    Member_bitfield _base I32 Signed noattr 24 false :: nil)
   noattr ::
 Composite __419 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad0 I32 Signed noattr 8 false ::
    Member_bitfield _sft I32 Signed noattr 8 false ::
    Member_bitfield _len I32 Signed noattr 8 false ::
    Member_bitfield _data I32 Unsigned noattr 32 false :: nil)
   noattr ::
 Composite __421 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad0 I32 Signed noattr 8 false ::
    Member_bitfield _sft I32 Signed noattr 8 false ::
    Member_bitfield _len I32 Signed noattr 8 false ::
    Member_bitfield _data I32 Unsigned noattr 32 false :: nil)
   noattr ::
 Composite __423 Struct
   (Member_plain _cmd tuchar :: Member_plain _lodscale tuchar ::
    Member_plain _tile tuchar :: Member_plain _on tuchar ::
    Member_plain _s tushort :: Member_plain _t tushort :: nil)
   noattr ::
 Composite __425 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad I32 Signed noattr 24 false ::
    Member_plain _line (Tstruct __370 noattr) :: nil)
   noattr ::
 Composite __427 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad1 I32 Signed noattr 24 false ::
    Member_plain _pad2 tshort :: Member_plain _scale tshort :: nil)
   noattr ::
 Composite __429 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _fmt I32 Unsigned noattr 3 false ::
    Member_bitfield _siz I32 Unsigned noattr 2 false ::
    Member_bitfield _pad I32 Unsigned noattr 7 false ::
    Member_bitfield _wd I32 Unsigned noattr 12 false ::
    Member_plain _dram tuint :: nil)
   noattr ::
 Composite __431 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _muxs0 I32 Unsigned noattr 24 false ::
    Member_bitfield _muxs1 I32 Unsigned noattr 32 false :: nil)
   noattr ::
 Composite __433 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_plain _pad tuchar :: Member_plain _prim_min_level tuchar ::
    Member_plain _prim_level tuchar :: Member_plain _color tulong :: nil)
   noattr ::
 Composite __435 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _x0 I32 Signed noattr 10 false ::
    Member_bitfield _x0frac I32 Signed noattr 2 false ::
    Member_bitfield _y0 I32 Signed noattr 10 false ::
    Member_bitfield _y0frac I32 Signed noattr 2 false ::
    Member_bitfield _pad I32 Unsigned noattr 8 false ::
    Member_bitfield _x1 I32 Signed noattr 10 false ::
    Member_bitfield _x1frac I32 Signed noattr 2 false ::
    Member_bitfield _y1 I32 Signed noattr 10 false ::
    Member_bitfield _y1frac I32 Signed noattr 2 false :: nil)
   noattr ::
 Composite __437 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _fmt I32 Unsigned noattr 3 false ::
    Member_bitfield _siz I32 Unsigned noattr 2 false ::
    Member_bitfield _pad0 I32 Unsigned noattr 1 false ::
    Member_bitfield _line I32 Unsigned noattr 9 false ::
    Member_bitfield _tmem I32 Unsigned noattr 9 false ::
    Member_bitfield _pad1 I32 Unsigned noattr 5 false ::
    Member_bitfield _tile I32 Unsigned noattr 3 false ::
    Member_bitfield _palette I32 Unsigned noattr 4 false ::
    Member_bitfield _ct I32 Unsigned noattr 1 false ::
    Member_bitfield _mt I32 Unsigned noattr 1 false ::
    Member_bitfield _maskt I32 Unsigned noattr 4 false ::
    Member_bitfield _shiftt I32 Unsigned noattr 4 false ::
    Member_bitfield _cs I32 Unsigned noattr 1 false ::
    Member_bitfield _ms I32 Unsigned noattr 1 false ::
    Member_bitfield _masks I32 Unsigned noattr 4 false ::
    Member_bitfield _shifts I32 Unsigned noattr 4 false :: nil)
   noattr ::
 Composite __439 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _sl I32 Unsigned noattr 12 false ::
    Member_bitfield _tl I32 Unsigned noattr 12 false ::
    Member_bitfield _pad I32 Signed noattr 5 false ::
    Member_bitfield _tile I32 Unsigned noattr 3 false ::
    Member_bitfield _sh I32 Unsigned noattr 12 false ::
    Member_bitfield _th I32 Unsigned noattr 12 false :: nil)
   noattr ::
 Composite __448 Struct
   (Member_plain _w0 tuint :: Member_plain _w1 tuint :: nil)
   noattr ::
 Composite __450 Union
   (Member_plain _words (Tstruct __448 noattr) ::
    Member_plain _dma (Tstruct __411 noattr) ::
    Member_plain _tri (Tstruct __413 noattr) ::
    Member_plain _line (Tstruct __425 noattr) ::
    Member_plain _popmtx (Tstruct __415 noattr) ::
    Member_plain _segment (Tstruct __417 noattr) ::
    Member_plain _setothermodeH (Tstruct __421 noattr) ::
    Member_plain _setothermodeL (Tstruct __419 noattr) ::
    Member_plain _texture (Tstruct __423 noattr) ::
    Member_plain _perspnorm (Tstruct __427 noattr) ::
    Member_plain _setimg (Tstruct __429 noattr) ::
    Member_plain _setcombine (Tstruct __431 noattr) ::
    Member_plain _setcolor (Tstruct __433 noattr) ::
    Member_plain _fillrect (Tstruct __435 noattr) ::
    Member_plain _settile (Tstruct __437 noattr) ::
    Member_plain _loadtile (Tstruct __439 noattr) ::
    Member_plain _settilesize (Tstruct __439 noattr) ::
    Member_plain _loadtlut (Tstruct __439 noattr) ::
    Member_plain _force_structure_alignment tlong :: nil)
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
 Composite _AllocOnlyPool Struct
   (Member_plain _totalSpace tint :: Member_plain _usedSpace tint ::
    Member_plain _startPtr (tptr tuchar) ::
    Member_plain _freePtr (tptr tuchar) :: nil)
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
 Composite _FnGraphNode Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _func
      (tptr (Tfunction
              (tint :: (tptr (Tstruct _GraphNode noattr)) :: (tptr tvoid) ::
               nil) (tptr (Tunion __450 noattr)) cc_default)) :: nil)
   noattr ::
 Composite _GraphNodeRoot Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _areaIndex tuchar :: Member_plain _unk15 tschar ::
    Member_plain _x tshort :: Member_plain _y tshort ::
    Member_plain _width tshort :: Member_plain _height tshort ::
    Member_plain _numViews tshort ::
    Member_plain _views (tptr (tptr (Tstruct _GraphNode noattr))) :: nil)
   noattr ::
 Composite _GraphNodeSwitchCase Struct
   (Member_plain _fnNode (Tstruct _FnGraphNode noattr) ::
    Member_plain _unused tint :: Member_plain _numCases tshort ::
    Member_plain _selectedCase tshort :: nil)
   noattr ::
 Composite __1093 Union
   (Member_plain _mode tint ::
    Member_plain _camera (tptr (Tstruct _Camera noattr)) :: nil)
   noattr ::
 Composite _GraphNodeCamera Struct
   (Member_plain _fnNode (Tstruct _FnGraphNode noattr) ::
    Member_plain _config (Tunion __1093 noattr) ::
    Member_plain _pos (tarray tfloat 3) ::
    Member_plain _focus (tarray tfloat 3) ::
    Member_plain _matrixPtr (tptr (tarray (tarray tfloat 4) 4)) ::
    Member_plain _roll tshort :: Member_plain _rollScreen tshort :: nil)
   noattr ::
 Composite _GraphNodeRotation Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _displayList (tptr tvoid) ::
    Member_plain _rotation (tarray tshort 3) ::
    Member_plain _filler (tarray tuchar 2) :: nil)
   noattr ::
 Composite _GraphNodeScale Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _displayList (tptr tvoid) :: Member_plain _scale tfloat ::
    nil)
   noattr ::
 Composite _GraphNodeGenerated Struct
   (Member_plain _fnNode (Tstruct _FnGraphNode noattr) ::
    Member_plain _parameter tuint :: nil)
   noattr ::
 Composite _GraphNodeHeldObject Struct
   (Member_plain _fnNode (Tstruct _FnGraphNode noattr) ::
    Member_plain _playerIndex tint ::
    Member_plain _objNode (tptr (Tstruct _Object noattr)) ::
    Member_plain _translation (tarray tshort 3) :: nil)
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
 (_alloc_display_list,
   Gfun(External (EF_external "alloc_display_list"
                   (mksignature (AST.Xint :: nil) AST.Xptr cc_default))
     (tuint :: nil) (tptr tvoid) cc_default)) ::
 (_gVec3fZero, Gvar v_gVec3fZero) :: (_gVec3sZero, Gvar v_gVec3sZero) ::
 (_gVec3fOne, Gvar v_gVec3fOne) ::
 (_init_graph_node_object,
   Gfun(External (EF_external "init_graph_node_object"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xptr :: AST.Xptr ::
                      AST.Xptr :: AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeObject noattr)) ::
      (tptr (Tstruct _GraphNode noattr)) :: (tptr tfloat) :: (tptr tshort) ::
      (tptr tfloat) :: nil) (tptr (Tstruct _GraphNodeObject noattr))
     cc_default)) ::
 (_geo_add_child,
   Gfun(External (EF_external "geo_add_child"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xptr
                     cc_default))
     ((tptr (Tstruct _GraphNode noattr)) ::
      (tptr (Tstruct _GraphNode noattr)) :: nil)
     (tptr (Tstruct _GraphNode noattr)) cc_default)) ::
 (_geo_remove_child,
   Gfun(External (EF_external "geo_remove_child"
                   (mksignature (AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr (Tstruct _GraphNode noattr)) :: nil)
     (tptr (Tstruct _GraphNode noattr)) cc_default)) ::
 (_gPlayerCameraState, Gvar v_gPlayerCameraState) ::
 (_gWarpTransition, Gvar v_gWarpTransition) ::
 (_gCurrSaveFileNum, Gvar v_gCurrSaveFileNum) ::
 (_play_sound,
   Gfun(External (EF_external "play_sound"
                   (mksignature (AST.Xint :: AST.Xptr :: nil) AST.Xvoid
                     cc_default)) (tint :: (tptr tfloat) :: nil) tvoid
     cc_default)) ::
 (_play_toads_jingle,
   Gfun(External (EF_external "play_toads_jingle"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_spawn_star_no_level_exit,
   Gfun(External (EF_external "bhv_spawn_star_no_level_exit"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tuint :: nil) tvoid cc_default)) ::
 (_bhvSparkleSpawn, Gvar v_bhvSparkleSpawn) ::
 (_gSineTable, Gvar v_gSineTable) ::
 (_vec3f_copy,
   Gfun(External (EF_external "vec3f_copy"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xptr
                     cc_default)) ((tptr tfloat) :: (tptr tfloat) :: nil)
     (tptr tvoid) cc_default)) ::
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
 (_get_pos_from_transform_mtx,
   Gfun(External (EF_external "get_pos_from_transform_mtx"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xvoid cc_default))
     ((tptr tfloat) :: (tptr (tarray tfloat 4)) ::
      (tptr (tarray tfloat 4)) :: nil) tvoid cc_default)) ::
 (_gGoddardVblankCallback, Gvar v_gGoddardVblankCallback) ::
 (_gPlayer1Controller, Gvar v_gPlayer1Controller) ::
 (_gd_vblank,
   Gfun(External (EF_external "gd_vblank"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_gd_copy_p1_contpad,
   Gfun(External (EF_external "gd_copy_p1_contpad"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct __220 noattr)) :: nil) tvoid cc_default)) ::
 (_gd_sfx_to_play,
   Gfun(External (EF_external "gd_sfx_to_play"
                   (mksignature nil AST.Xint cc_default)) nil tint
     cc_default)) ::
 (_gdm_gettestdl,
   Gfun(External (EF_external "gdm_gettestdl"
                   (mksignature (AST.Xint :: nil) AST.Xptr cc_default))
     (tint :: nil) (tptr (Tunion __450 noattr)) cc_default)) ::
 (_gMarioStates, Gvar v_gMarioStates) ::
 (_gMarioState, Gvar v_gMarioState) ::
 (_spawn_object,
   Gfun(External (EF_external "spawn_object"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xptr :: nil)
                     AST.Xptr cc_default))
     ((tptr (Tstruct _Object noattr)) :: tint :: (tptr tuint) :: nil)
     (tptr (Tstruct _Object noattr)) cc_default)) ::
 (_obj_scale,
   Gfun(External (EF_external "obj_scale"
                   (mksignature (AST.Xptr :: AST.Xsingle :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _Object noattr)) :: tfloat :: nil) tvoid cc_default)) ::
 (_cur_obj_hide,
   Gfun(External (EF_external "cur_obj_hide"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_obj_mark_for_deletion,
   Gfun(External (EF_external "obj_mark_for_deletion"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _Object noattr)) :: nil) tvoid cc_default)) ::
 (_cur_obj_update_dialog_with_cutscene,
   Gfun(External (EF_external "cur_obj_update_dialog_with_cutscene"
                   (mksignature
                     (AST.Xint :: AST.Xint :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint cc_default))
     (tint :: tint :: tint :: tint :: nil) tint cc_default)) ::
 (_gCurrentObject, Gvar v_gCurrentObject) ::
 (_gCurGraphNodeCamera, Gvar v_gCurGraphNodeCamera) ::
 (_gCurGraphNodeObject, Gvar v_gCurGraphNodeObject) ::
 (_gAreaUpdateCounter, Gvar v_gAreaUpdateCounter) ::
 (_save_file_get_total_star_count,
   Gfun(External (EF_external "save_file_get_total_star_count"
                   (mksignature (AST.Xint :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint cc_default)) (tint :: tint :: tint :: nil) tint
     cc_default)) ::
 (_save_file_get_flags,
   Gfun(External (EF_external "save_file_get_flags"
                   (mksignature nil AST.Xint cc_default)) nil tuint
     cc_default)) ::
 (_play_menu_sounds,
   Gfun(External (EF_external "play_menu_sounds"
                   (mksignature (AST.Xint16signed :: nil) AST.Xvoid
                     cc_default)) (tshort :: nil) tvoid cc_default)) ::
 (_gMarioBlinkAnimation, Gvar v_gMarioBlinkAnimation) ::
 (_gMarioAttackScaleAnimation, Gvar v_gMarioAttackScaleAnimation) ::
 (_gBodyStates, Gvar v_gBodyStates) ::
 (_gMirrorMario, Gvar v_gMirrorMario) ::
 (_geo_draw_mario_head_goddard, Gfun(Internal f_geo_draw_mario_head_goddard)) ::
 (_toad_message_faded, Gfun(Internal f_toad_message_faded)) ::
 (_toad_message_opaque, Gfun(Internal f_toad_message_opaque)) ::
 (_toad_message_talking, Gfun(Internal f_toad_message_talking)) ::
 (_toad_message_opacifying, Gfun(Internal f_toad_message_opacifying)) ::
 (_toad_message_fading, Gfun(Internal f_toad_message_fading)) ::
 (_bhv_toad_message_loop, Gfun(Internal f_bhv_toad_message_loop)) ::
 (_bhv_toad_message_init, Gfun(Internal f_bhv_toad_message_init)) ::
 (_star_door_unlock_spawn_particles, Gfun(Internal f_star_door_unlock_spawn_particles)) ::
 (_bhv_unlock_door_star_init, Gfun(Internal f_bhv_unlock_door_star_init)) ::
 (_bhv_unlock_door_star_loop, Gfun(Internal f_bhv_unlock_door_star_loop)) ::
 (_make_gfx_mario_alpha, Gfun(Internal f_make_gfx_mario_alpha)) ::
 (_geo_mirror_mario_set_alpha, Gfun(Internal f_geo_mirror_mario_set_alpha)) ::
 (_geo_switch_mario_stand_run, Gfun(Internal f_geo_switch_mario_stand_run)) ::
 (_geo_switch_mario_eyes, Gfun(Internal f_geo_switch_mario_eyes)) ::
 (_geo_mario_tilt_torso, Gfun(Internal f_geo_mario_tilt_torso)) ::
 (_geo_mario_head_rotation, Gfun(Internal f_geo_mario_head_rotation)) ::
 (_geo_switch_mario_hand, Gfun(Internal f_geo_switch_mario_hand)) ::
 (_sMarioAttackAnimCounter, Gvar v_sMarioAttackAnimCounter) ::
 (_geo_mario_hand_foot_scaler, Gfun(Internal f_geo_mario_hand_foot_scaler)) ::
 (_geo_switch_mario_cap_effect, Gfun(Internal f_geo_switch_mario_cap_effect)) ::
 (_geo_switch_mario_cap_on_off, Gfun(Internal f_geo_switch_mario_cap_on_off)) ::
 (_geo_mario_rotate_wing_cap_wings, Gfun(Internal f_geo_mario_rotate_wing_cap_wings)) ::
 (_geo_switch_mario_hand_grab_pos, Gfun(Internal f_geo_switch_mario_hand_grab_pos)) ::
 (_geo_render_mirror_mario, Gfun(Internal f_geo_render_mirror_mario)) ::
 (_geo_mirror_mario_backface_culling, Gfun(Internal f_geo_mirror_mario_backface_culling)) ::
 nil).

Definition public_idents : list ident :=
(_geo_mirror_mario_backface_culling :: _geo_render_mirror_mario ::
 _geo_switch_mario_hand_grab_pos :: _geo_mario_rotate_wing_cap_wings ::
 _geo_switch_mario_cap_on_off :: _geo_switch_mario_cap_effect ::
 _geo_mario_hand_foot_scaler :: _geo_switch_mario_hand ::
 _geo_mario_head_rotation :: _geo_mario_tilt_torso ::
 _geo_switch_mario_eyes :: _geo_switch_mario_stand_run ::
 _geo_mirror_mario_set_alpha :: _bhv_unlock_door_star_loop ::
 _bhv_unlock_door_star_init :: _bhv_toad_message_init ::
 _bhv_toad_message_loop :: _geo_draw_mario_head_goddard :: _gMirrorMario ::
 _gBodyStates :: _play_menu_sounds :: _save_file_get_flags ::
 _save_file_get_total_star_count :: _gAreaUpdateCounter ::
 _gCurGraphNodeObject :: _gCurGraphNodeCamera :: _gCurrentObject ::
 _cur_obj_update_dialog_with_cutscene :: _obj_mark_for_deletion ::
 _cur_obj_hide :: _obj_scale :: _spawn_object :: _gMarioState ::
 _gMarioStates :: _gdm_gettestdl :: _gd_sfx_to_play :: _gd_copy_p1_contpad ::
 _gd_vblank :: _gPlayer1Controller :: _gGoddardVblankCallback ::
 _get_pos_from_transform_mtx :: _vec3s_set :: _vec3s_copy :: _vec3f_copy ::
 _gSineTable :: _bhvSparkleSpawn :: _bhv_spawn_star_no_level_exit ::
 _play_toads_jingle :: _play_sound :: _gCurrSaveFileNum ::
 _gWarpTransition :: _gPlayerCameraState :: _geo_remove_child ::
 _geo_add_child :: _init_graph_node_object :: _gVec3fOne :: _gVec3sZero ::
 _gVec3fZero :: _alloc_display_list :: ___builtin_debug ::
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


