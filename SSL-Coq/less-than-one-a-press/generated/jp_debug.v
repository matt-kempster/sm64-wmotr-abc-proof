(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_JP
   Source:          src/game/debug.c
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_JP=1 -DF3D_OLD=1
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
  Definition arch := "powerpc".
  Definition model := "ppc32".
  Definition abi := "eabi".
  Definition bitsize := 32.
  Definition big_endian := true.
  Definition source_file := "build/pinned-sm64/src/game/debug.c".
  Definition normalized := true.
End Info.

Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _Controller : ident := $"Controller".
Definition _D_8035FEE2 : ident := $"D_8035FEE2".
Definition _D_8035FEE4 : ident := $"D_8035FEE4".
Definition _GraphNode : ident := $"GraphNode".
Definition _GraphNodeObject : ident := $"GraphNodeObject".
Definition _NumTimesCalled : ident := $"NumTimesCalled".
Definition _Object : ident := $"Object".
Definition _ObjectNode : ident := $"ObjectNode".
Definition _SpawnInfo : ident := $"SpawnInfo".
Definition _Surface : ident := $"Surface".
Definition _Waypoint : ident := $"Waypoint".
Definition __317 : ident := $"_317".
Definition __319 : ident := $"_319".
Definition __727 : ident := $"_727".
Definition __732 : ident := $"_732".
Definition ___builtin_ais_annot : ident := $"__builtin_ais_annot".
Definition ___builtin_annot : ident := $"__builtin_annot".
Definition ___builtin_annot_intval : ident := $"__builtin_annot_intval".
Definition ___builtin_atomic_compare_exchange : ident := $"__builtin_atomic_compare_exchange".
Definition ___builtin_atomic_exchange : ident := $"__builtin_atomic_exchange".
Definition ___builtin_atomic_load : ident := $"__builtin_atomic_load".
Definition ___builtin_bsel : ident := $"__builtin_bsel".
Definition ___builtin_bswap : ident := $"__builtin_bswap".
Definition ___builtin_bswap16 : ident := $"__builtin_bswap16".
Definition ___builtin_bswap32 : ident := $"__builtin_bswap32".
Definition ___builtin_bswap64 : ident := $"__builtin_bswap64".
Definition ___builtin_call_frame : ident := $"__builtin_call_frame".
Definition ___builtin_clz : ident := $"__builtin_clz".
Definition ___builtin_clzl : ident := $"__builtin_clzl".
Definition ___builtin_clzll : ident := $"__builtin_clzll".
Definition ___builtin_cmpb : ident := $"__builtin_cmpb".
Definition ___builtin_ctz : ident := $"__builtin_ctz".
Definition ___builtin_ctzl : ident := $"__builtin_ctzl".
Definition ___builtin_ctzll : ident := $"__builtin_ctzll".
Definition ___builtin_dcbf : ident := $"__builtin_dcbf".
Definition ___builtin_dcbi : ident := $"__builtin_dcbi".
Definition ___builtin_dcbtls : ident := $"__builtin_dcbtls".
Definition ___builtin_dcbz : ident := $"__builtin_dcbz".
Definition ___builtin_debug : ident := $"__builtin_debug".
Definition ___builtin_eieio : ident := $"__builtin_eieio".
Definition ___builtin_expect : ident := $"__builtin_expect".
Definition ___builtin_fabs : ident := $"__builtin_fabs".
Definition ___builtin_fabsf : ident := $"__builtin_fabsf".
Definition ___builtin_fcti : ident := $"__builtin_fcti".
Definition ___builtin_fmadd : ident := $"__builtin_fmadd".
Definition ___builtin_fmsub : ident := $"__builtin_fmsub".
Definition ___builtin_fnmadd : ident := $"__builtin_fnmadd".
Definition ___builtin_fnmsub : ident := $"__builtin_fnmsub".
Definition ___builtin_fres : ident := $"__builtin_fres".
Definition ___builtin_frsqrte : ident := $"__builtin_frsqrte".
Definition ___builtin_fsel : ident := $"__builtin_fsel".
Definition ___builtin_fsqrt : ident := $"__builtin_fsqrt".
Definition ___builtin_get_spr : ident := $"__builtin_get_spr".
Definition ___builtin_get_spr64 : ident := $"__builtin_get_spr64".
Definition ___builtin_icbi : ident := $"__builtin_icbi".
Definition ___builtin_icbtls : ident := $"__builtin_icbtls".
Definition ___builtin_isel : ident := $"__builtin_isel".
Definition ___builtin_isel64 : ident := $"__builtin_isel64".
Definition ___builtin_isync : ident := $"__builtin_isync".
Definition ___builtin_lwsync : ident := $"__builtin_lwsync".
Definition ___builtin_mbar : ident := $"__builtin_mbar".
Definition ___builtin_membar : ident := $"__builtin_membar".
Definition ___builtin_memcpy_aligned : ident := $"__builtin_memcpy_aligned".
Definition ___builtin_mr : ident := $"__builtin_mr".
Definition ___builtin_mulhd : ident := $"__builtin_mulhd".
Definition ___builtin_mulhdu : ident := $"__builtin_mulhdu".
Definition ___builtin_mulhw : ident := $"__builtin_mulhw".
Definition ___builtin_mulhwu : ident := $"__builtin_mulhwu".
Definition ___builtin_nop : ident := $"__builtin_nop".
Definition ___builtin_prefetch : ident := $"__builtin_prefetch".
Definition ___builtin_read16_reversed : ident := $"__builtin_read16_reversed".
Definition ___builtin_read32_reversed : ident := $"__builtin_read32_reversed".
Definition ___builtin_read64_reversed : ident := $"__builtin_read64_reversed".
Definition ___builtin_return_address : ident := $"__builtin_return_address".
Definition ___builtin_sel : ident := $"__builtin_sel".
Definition ___builtin_set_spr : ident := $"__builtin_set_spr".
Definition ___builtin_set_spr64 : ident := $"__builtin_set_spr64".
Definition ___builtin_sqrt : ident := $"__builtin_sqrt".
Definition ___builtin_sync : ident := $"__builtin_sync".
Definition ___builtin_sync_fetch_and_add : ident := $"__builtin_sync_fetch_and_add".
Definition ___builtin_trap : ident := $"__builtin_trap".
Definition ___builtin_uisel : ident := $"__builtin_uisel".
Definition ___builtin_uisel64 : ident := $"__builtin_uisel64".
Definition ___builtin_unreachable : ident := $"__builtin_unreachable".
Definition ___builtin_va_arg : ident := $"__builtin_va_arg".
Definition ___builtin_va_copy : ident := $"__builtin_va_copy".
Definition ___builtin_va_end : ident := $"__builtin_va_end".
Definition ___builtin_va_start : ident := $"__builtin_va_start".
Definition ___builtin_write16_reversed : ident := $"__builtin_write16_reversed".
Definition ___builtin_write32_reversed : ident := $"__builtin_write32_reversed".
Definition ___builtin_write64_reversed : ident := $"__builtin_write64_reversed".
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
Definition ___stringlit_5 : ident := $"__stringlit_5".
Definition ___stringlit_6 : ident := $"__stringlit_6".
Definition ___stringlit_7 : ident := $"__stringlit_7".
Definition ___stringlit_8 : ident := $"__stringlit_8".
Definition ___stringlit_9 : ident := $"__stringlit_9".
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _angY : ident := $"angY".
Definition _angle : ident := $"angle".
Definition _animAccel : ident := $"animAccel".
Definition _animFrame : ident := $"animFrame".
Definition _animFrameAccelAssist : ident := $"animFrameAccelAssist".
Definition _animID : ident := $"animID".
Definition _animInfo : ident := $"animInfo".
Definition _animTimer : ident := $"animTimer".
Definition _animYTrans : ident := $"animYTrans".
Definition _animYTransDivisor : ident := $"animYTransDivisor".
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
Definition _behavior : ident := $"behavior".
Definition _behaviorArg : ident := $"behaviorArg".
Definition _behaviorScript : ident := $"behaviorScript".
Definition _bgY : ident := $"bgY".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvJumpingBox : ident := $"bhvJumpingBox".
Definition _bhvKoopaShell : ident := $"bhvKoopaShell".
Definition _bhvKoopaShellUnderwater : ident := $"bhvKoopaShellUnderwater".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _button : ident := $"button".
Definition _buttonDown : ident := $"buttonDown".
Definition _buttonPressed : ident := $"buttonPressed".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _ceil : ident := $"ceil".
Definition _children : ident := $"children".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _controllerData : ident := $"controllerData".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _cycles : ident := $"cycles".
Definition _dPadMask : ident := $"dPadMask".
Definition _debug_enemy_unknown : ident := $"debug_enemy_unknown".
Definition _debug_print_obj_move_flags : ident := $"debug_print_obj_move_flags".
Definition _debug_surface_list_info : ident := $"debug_surface_list_info".
Definition _debug_unknown_level_select_check : ident := $"debug_unknown_level_select_check".
Definition _enemyArr : ident := $"enemyArr".
Definition _errnum : ident := $"errnum".
Definition _filler : ident := $"filler".
Definition _find_floor : ident := $"find_floor".
Definition _find_water_level : ident := $"find_water_level".
Definition _flags : ident := $"flags".
Definition _floor : ident := $"floor".
Definition _force : ident := $"force".
Definition _gCurrentObject : ident := $"gCurrentObject".
Definition _gDebugInfo : ident := $"gDebugInfo".
Definition _gDebugInfoFlags : ident := $"gDebugInfoFlags".
Definition _gDebugInfoOverwrite : ident := $"gDebugInfoOverwrite".
Definition _gDebugLevelSelect : ident := $"gDebugLevelSelect".
Definition _gDebugPrintState1 : ident := $"gDebugPrintState1".
Definition _gDebugPrintState2 : ident := $"gDebugPrintState2".
Definition _gMarioObject : ident := $"gMarioObject".
Definition _gNumCalls : ident := $"gNumCalls".
Definition _gNumFindFloorMisses : ident := $"gNumFindFloorMisses".
Definition _gObjectCounter : ident := $"gObjectCounter".
Definition _gPlayer1Controller : ident := $"gPlayer1Controller".
Definition _gTTCSpeedSetting : ident := $"gTTCSpeedSetting".
Definition _gUnknownWallCount : ident := $"gUnknownWallCount".
Definition _get_clock_difference : ident := $"get_clock_difference".
Definition _get_current_clock : ident := $"get_current_clock".
Definition _gfx : ident := $"gfx".
Definition _header : ident := $"header".
Definition _hitboxDownOffset : ident := $"hitboxDownOffset".
Definition _hitboxHeight : ident := $"hitboxHeight".
Definition _hitboxRadius : ident := $"hitboxRadius".
Definition _hurtboxHeight : ident := $"hurtboxHeight".
Definition _hurtboxRadius : ident := $"hurtboxRadius".
Definition _i : ident := $"i".
Definition _index : ident := $"index".
Definition _length : ident := $"length".
Definition _lineYOffset : ident := $"lineYOffset".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _main : ident := $"main".
Definition _maxXCursor : ident := $"maxXCursor".
Definition _minYCursor : ident := $"minYCursor".
Definition _model : ident := $"model".
Definition _next : ident := $"next".
Definition _node : ident := $"node".
Definition _normal : ident := $"normal".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _number : ident := $"number".
Definition _object : ident := $"object".
Definition _originOffset : ident := $"originOffset".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _pfloor : ident := $"pfloor".
Definition _pitch : ident := $"pitch".
Definition _platform : ident := $"platform".
Definition _pos : ident := $"pos".
Definition _posX : ident := $"posX".
Definition _posY : ident := $"posY".
Definition _posZ : ident := $"posZ".
Definition _prev : ident := $"prev".
Definition _prevObj : ident := $"prevObj".
Definition _printState : ident := $"printState".
Definition _print_checkinfo : ident := $"print_checkinfo".
Definition _print_debug_bottom_up : ident := $"print_debug_bottom_up".
Definition _print_debug_top_down_mapinfo : ident := $"print_debug_top_down_mapinfo".
Definition _print_debug_top_down_normal : ident := $"print_debug_top_down_normal".
Definition _print_debug_top_down_objectinfo : ident := $"print_debug_top_down_objectinfo".
Definition _print_effectinfo : ident := $"print_effectinfo".
Definition _print_enemyinfo : ident := $"print_enemyinfo".
Definition _print_mapinfo : ident := $"print_mapinfo".
Definition _print_stageinfo : ident := $"print_stageinfo".
Definition _print_string_array_info : ident := $"print_string_array_info".
Definition _print_surfaceinfo : ident := $"print_surfaceinfo".
Definition _print_text : ident := $"print_text".
Definition _print_text_array_info : ident := $"print_text_array_info".
Definition _print_text_fmt_int : ident := $"print_text_fmt_int".
Definition _rawData : ident := $"rawData".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _reset_debug_objectinfo : ident := $"reset_debug_objectinfo".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _roll : ident := $"roll".
Definition _room : ident := $"room".
Definition _sDebugEffectStringInfo : ident := $"sDebugEffectStringInfo".
Definition _sDebugEnemyStringInfo : ident := $"sDebugEnemyStringInfo".
Definition _sDebugInfoButtonSeq : ident := $"sDebugInfoButtonSeq".
Definition _sDebugInfoButtonSeqID : ident := $"sDebugInfoButtonSeqID".
Definition _sDebugInfoDPadMask : ident := $"sDebugInfoDPadMask".
Definition _sDebugInfoDPadUpdID : ident := $"sDebugInfoDPadUpdID".
Definition _sDebugLvSelectCheckFlag : ident := $"sDebugLvSelectCheckFlag".
Definition _sDebugPage : ident := $"sDebugPage".
Definition _sDebugStringArrPrinted : ident := $"sDebugStringArrPrinted".
Definition _sDebugSysCursor : ident := $"sDebugSysCursor".
Definition _sNoExtraDebug : ident := $"sNoExtraDebug".
Definition _scale : ident := $"scale".
Definition _set_print_state_info : ident := $"set_print_state_info".
Definition _set_text_array_x_y : ident := $"set_text_array_x_y".
Definition _sharedChild : ident := $"sharedChild".
Definition _sp4 : ident := $"sp4".
Definition _spawn_object_relative : ident := $"spawn_object_relative".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
Definition _status : ident := $"status".
Definition _statusData : ident := $"statusData".
Definition _stickMag : ident := $"stickMag".
Definition _stickX : ident := $"stickX".
Definition _stickY : ident := $"stickY".
Definition _stick_x : ident := $"stick_x".
Definition _stick_y : ident := $"stick_y".
Definition _str : ident := $"str".
Definition _strArr : ident := $"strArr".
Definition _stub_debug_1 : ident := $"stub_debug_1".
Definition _stub_debug_2 : ident := $"stub_debug_2".
Definition _stub_debug_3 : ident := $"stub_debug_3".
Definition _stub_debug_4 : ident := $"stub_debug_4".
Definition _stub_debug_5 : ident := $"stub_debug_5".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _transform : ident := $"transform".
Definition _try_do_mario_debug_object_spawn : ident := $"try_do_mario_debug_object_spawn".
Definition _try_modify_debug_controls : ident := $"try_modify_debug_controls".
Definition _try_print_debug_mario_level_info : ident := $"try_print_debug_mario_level_info".
Definition _try_print_debug_mario_object_info : ident := $"try_print_debug_mario_object_info".
Definition _type : ident := $"type".
Definition _unk4C : ident := $"unk4C".
Definition _unused1 : ident := $"unused1".
Definition _unused2 : ident := $"unused2".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _update_debug_dpadmask : ident := $"update_debug_dpadmask".
Definition _upperY : ident := $"upperY".
Definition _values : ident := $"values".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _wall : ident := $"wall".
Definition _water : ident := $"water".
Definition _wtf : ident := $"wtf".
Definition _x : ident := $"x".
Definition _xCursor : ident := $"xCursor".
Definition _xOffset : ident := $"xOffset".
Definition _y : ident := $"y".
Definition _yCursor : ident := $"yCursor".
Definition _yOffset : ident := $"yOffset".
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
Definition _t'4 : ident := 131%positive.
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v___stringlit_40 := {|
  gvar_info := (tarray tuchar 11);
  gvar_init := (Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 85) :: Init_int8 (Int.repr 67) ::
                Init_int8 (Int.repr 72) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 37) :: Init_int8 (Int.repr 120) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_10 := {|
  gvar_info := (tarray tuchar 2);
  gvar_init := (Init_int8 (Int.repr 66) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_19 := {|
  gvar_info := (tarray tuchar 12);
  gvar_init := (Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 80) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 86) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_27 := {|
  gvar_info := (tarray tuchar 12);
  gvar_init := (Init_int8 (Int.repr 98) :: Init_int8 (Int.repr 103) ::
                Init_int8 (Int.repr 99) :: Init_int8 (Int.repr 111) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 101) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_46 := {|
  gvar_info := (tarray tuchar 11);
  gvar_init := (Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 75) ::
                Init_int8 (Int.repr 89) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 37) :: Init_int8 (Int.repr 120) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_7 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 97) :: Init_int8 (Int.repr 50) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_15 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 98) :: Init_int8 (Int.repr 51) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_26 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 97) :: Init_int8 (Int.repr 110) ::
                Init_int8 (Int.repr 103) :: Init_int8 (Int.repr 89) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_41 := {|
  gvar_info := (tarray tuchar 11);
  gvar_init := (Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 70) ::
                Init_int8 (Int.repr 70) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 37) :: Init_int8 (Int.repr 120) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_2 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 97) :: Init_int8 (Int.repr 55) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_28 := {|
  gvar_info := (tarray tuchar 12);
  gvar_init := (Init_int8 (Int.repr 98) :: Init_int8 (Int.repr 103) ::
                Init_int8 (Int.repr 115) :: Init_int8 (Int.repr 116) ::
                Init_int8 (Int.repr 97) :: Init_int8 (Int.repr 116) ::
                Init_int8 (Int.repr 117) :: Init_int8 (Int.repr 115) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_45 := {|
  gvar_info := (tarray tuchar 11);
  gvar_init := (Init_int8 (Int.repr 66) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 87) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 37) :: Init_int8 (Int.repr 120) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_22 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 119) :: Init_int8 (Int.repr 120) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_35 := {|
  gvar_info := (tarray tuchar 10);
  gvar_init := (Init_int8 (Int.repr 101) :: Init_int8 (Int.repr 110) ::
                Init_int8 (Int.repr 101) :: Init_int8 (Int.repr 109) ::
                Init_int8 (Int.repr 121) :: Init_int8 (Int.repr 105) ::
                Init_int8 (Int.repr 110) :: Init_int8 (Int.repr 102) ::
                Init_int8 (Int.repr 111) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_43 := {|
  gvar_info := (tarray tuchar 11);
  gvar_init := (Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 87) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 37) :: Init_int8 (Int.repr 120) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_11 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 98) :: Init_int8 (Int.repr 55) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_33 := {|
  gvar_info := (tarray tuchar 15);
  gvar_init := (Init_int8 (Int.repr 115) :: Init_int8 (Int.repr 116) ::
                Init_int8 (Int.repr 97) :: Init_int8 (Int.repr 103) ::
                Init_int8 (Int.repr 101) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 112) :: Init_int8 (Int.repr 97) ::
                Init_int8 (Int.repr 114) :: Init_int8 (Int.repr 97) ::
                Init_int8 (Int.repr 109) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 37) :: Init_int8 (Int.repr 100) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_8 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 97) :: Init_int8 (Int.repr 49) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_29 := {|
  gvar_info := (tarray tuchar 12);
  gvar_init := (Init_int8 (Int.repr 98) :: Init_int8 (Int.repr 103) ::
                Init_int8 (Int.repr 97) :: Init_int8 (Int.repr 114) ::
                Init_int8 (Int.repr 101) :: Init_int8 (Int.repr 97) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_44 := {|
  gvar_info := (tarray tuchar 11);
  gvar_init := (Init_int8 (Int.repr 85) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 87) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 37) :: Init_int8 (Int.repr 120) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_5 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 97) :: Init_int8 (Int.repr 52) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_30 := {|
  gvar_info := (tarray tuchar 9);
  gvar_init := (Init_int8 (Int.repr 119) :: Init_int8 (Int.repr 97) ::
                Init_int8 (Int.repr 116) :: Init_int8 (Int.repr 101) ::
                Init_int8 (Int.repr 114) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 37) :: Init_int8 (Int.repr 100) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_4 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 97) :: Init_int8 (Int.repr 53) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_34 := {|
  gvar_info := (tarray tuchar 11);
  gvar_init := (Init_int8 (Int.repr 101) :: Init_int8 (Int.repr 102) ::
                Init_int8 (Int.repr 102) :: Init_int8 (Int.repr 101) ::
                Init_int8 (Int.repr 99) :: Init_int8 (Int.repr 116) ::
                Init_int8 (Int.repr 105) :: Init_int8 (Int.repr 110) ::
                Init_int8 (Int.repr 102) :: Init_int8 (Int.repr 111) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_31 := {|
  gvar_info := (tarray tuchar 10);
  gvar_init := (Init_int8 (Int.repr 99) :: Init_int8 (Int.repr 104) ::
                Init_int8 (Int.repr 101) :: Init_int8 (Int.repr 99) ::
                Init_int8 (Int.repr 107) :: Init_int8 (Int.repr 105) ::
                Init_int8 (Int.repr 110) :: Init_int8 (Int.repr 102) ::
                Init_int8 (Int.repr 111) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_38 := {|
  gvar_info := (tarray tuchar 10);
  gvar_init := (Init_int8 (Int.repr 87) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 76) :: Init_int8 (Int.repr 76) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_1 := {|
  gvar_info := (tarray tuchar 2);
  gvar_init := (Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_17 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 98) :: Init_int8 (Int.repr 49) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_18 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 98) :: Init_int8 (Int.repr 48) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_20 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 109) :: Init_int8 (Int.repr 97) ::
                Init_int8 (Int.repr 112) :: Init_int8 (Int.repr 105) ::
                Init_int8 (Int.repr 110) :: Init_int8 (Int.repr 102) ::
                Init_int8 (Int.repr 111) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_24 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 119) :: Init_int8 (Int.repr 122) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_13 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 98) :: Init_int8 (Int.repr 53) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_23 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 119) :: Init_int8 (Int.repr 121) ::
                Init_int8 (Int.repr 9) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_25 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 98) :: Init_int8 (Int.repr 103) ::
                Init_int8 (Int.repr 89) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_12 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 98) :: Init_int8 (Int.repr 54) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_9 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 97) :: Init_int8 (Int.repr 48) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_14 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 98) :: Init_int8 (Int.repr 52) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_16 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 98) :: Init_int8 (Int.repr 50) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_32 := {|
  gvar_info := (tarray tuchar 10);
  gvar_init := (Init_int8 (Int.repr 115) :: Init_int8 (Int.repr 116) ::
                Init_int8 (Int.repr 97) :: Init_int8 (Int.repr 103) ::
                Init_int8 (Int.repr 101) :: Init_int8 (Int.repr 105) ::
                Init_int8 (Int.repr 110) :: Init_int8 (Int.repr 102) ::
                Init_int8 (Int.repr 111) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_36 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 111) :: Init_int8 (Int.repr 98) ::
                Init_int8 (Int.repr 106) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_37 := {|
  gvar_info := (tarray tuchar 10);
  gvar_init := (Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 76) :: Init_int8 (Int.repr 76) ::
                Init_int8 (Int.repr 66) :: Init_int8 (Int.repr 71) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_47 := {|
  gvar_info := (tarray tuchar 13);
  gvar_init := (Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 67) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 80) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 37) :: Init_int8 (Int.repr 120) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_6 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 97) :: Init_int8 (Int.repr 51) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_39 := {|
  gvar_info := (tarray tuchar 11);
  gvar_init := (Init_int8 (Int.repr 66) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 85) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 37) :: Init_int8 (Int.repr 120) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_3 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 97) :: Init_int8 (Int.repr 54) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_21 := {|
  gvar_info := (tarray tuchar 8);
  gvar_init := (Init_int8 (Int.repr 97) :: Init_int8 (Int.repr 114) ::
                Init_int8 (Int.repr 101) :: Init_int8 (Int.repr 97) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 120) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_42 := {|
  gvar_info := (tarray tuchar 11);
  gvar_init := (Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 86) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 37) :: Init_int8 (Int.repr 120) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvKoopaShellUnderwater := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvJumpingBox := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvKoopaShell := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_gPlayer1Controller := {|
  gvar_info := (tptr (Tstruct _Controller noattr));
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

Definition v_gDebugInfoFlags := {|
  gvar_info := tint;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gNumFindFloorMisses := {|
  gvar_info := tint;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gUnknownWallCount := {|
  gvar_info := tint;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gObjectCounter := {|
  gvar_info := tuint;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gNumCalls := {|
  gvar_info := (Tstruct _NumTimesCalled noattr);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDebugInfo := {|
  gvar_info := (tarray (tarray tshort 8) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDebugInfoOverwrite := {|
  gvar_info := (tarray (tarray tshort 8) 0);
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

Definition v_gCurrentObject := {|
  gvar_info := (tptr (Tstruct _Object noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_8035FEE2 := {|
  gvar_info := tshort;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_8035FEE4 := {|
  gvar_info := tshort;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gTTCSpeedSetting := {|
  gvar_info := tshort;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDebugPrintState1 := {|
  gvar_info := (tarray tshort 6);
  gvar_init := (Init_space 12 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDebugPrintState2 := {|
  gvar_info := (tarray tshort 6);
  gvar_init := (Init_space 12 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDebugEffectStringInfo := {|
  gvar_info := (tarray (tptr tuchar) 9);
  gvar_init := (Init_addrof ___stringlit_9 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_8 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_7 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_6 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_5 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_4 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_3 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_2 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_1 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDebugEnemyStringInfo := {|
  gvar_info := (tarray (tptr tuchar) 9);
  gvar_init := (Init_addrof ___stringlit_18 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_17 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_16 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_15 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_14 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_13 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_12 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_11 (Ptrofs.repr 0) ::
                Init_addrof ___stringlit_10 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDebugInfoDPadMask := {|
  gvar_info := tint;
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDebugInfoDPadUpdID := {|
  gvar_info := tint;
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDebugLvSelectCheckFlag := {|
  gvar_info := tschar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDebugPage := {|
  gvar_info := tschar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sNoExtraDebug := {|
  gvar_info := tschar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDebugStringArrPrinted := {|
  gvar_info := tschar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDebugSysCursor := {|
  gvar_info := tschar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDebugInfoButtonSeqID := {|
  gvar_info := tschar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDebugInfoButtonSeq := {|
  gvar_info := (tarray tshort 5);
  gvar_init := (Init_int16 (Int.repr 8) :: Init_int16 (Int.repr 2) ::
                Init_int16 (Int.repr 4) :: Init_int16 (Int.repr 1) ::
                Init_int16 (Int.repr (-1)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_stub_debug_1 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
Sskip
|}.

Definition f_stub_debug_2 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
Sskip
|}.

Definition f_stub_debug_3 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
Sskip
|}.

Definition f_stub_debug_4 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
Sskip
|}.

Definition f_get_current_clock := {|
  fn_return := tlong;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_wtf, tlong) :: nil);
  fn_body :=
(Ssequence
  (Sset _wtf (Ecast (Econst_int (Int.repr 0) tint) tlong))
  (Sreturn (Some (Etempvar _wtf tlong))))
|}.

Definition f_get_clock_difference := {|
  fn_return := tlong;
  fn_callconv := cc_default;
  fn_params := ((_cycles, tlong) :: nil);
  fn_vars := nil;
  fn_temps := ((_wtf, tlong) :: nil);
  fn_body :=
(Ssequence
  (Sset _wtf (Ecast (Econst_int (Int.repr 0) tint) tlong))
  (Sreturn (Some (Etempvar _wtf tlong))))
|}.

Definition f_set_print_state_info := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_printState, (tptr tshort)) :: (_xCursor, tshort) ::
                (_yCursor, tshort) :: (_minYCursor, tshort) ::
                (_maxXCursor, tshort) :: (_lineYOffset, tshort) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sassign
    (Ederef
      (Ebinop Oadd (Etempvar _printState (tptr tshort))
        (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort)
    (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sassign
      (Ederef
        (Ebinop Oadd (Etempvar _printState (tptr tshort))
          (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort)
      (Etempvar _xCursor tshort))
    (Ssequence
      (Sassign
        (Ederef
          (Ebinop Oadd (Etempvar _printState (tptr tshort))
            (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort)
        (Etempvar _yCursor tshort))
      (Ssequence
        (Sassign
          (Ederef
            (Ebinop Oadd (Etempvar _printState (tptr tshort))
              (Econst_int (Int.repr 3) tint) (tptr tshort)) tshort)
          (Etempvar _minYCursor tshort))
        (Ssequence
          (Sassign
            (Ederef
              (Ebinop Oadd (Etempvar _printState (tptr tshort))
                (Econst_int (Int.repr 4) tint) (tptr tshort)) tshort)
            (Etempvar _maxXCursor tshort))
          (Sassign
            (Ederef
              (Ebinop Oadd (Etempvar _printState (tptr tshort))
                (Econst_int (Int.repr 5) tint) (tptr tshort)) tshort)
            (Etempvar _lineYOffset tshort)))))))
|}.

Definition f_print_text_array_info := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_printState, (tptr tshort)) :: (_str, (tptr tuchar)) ::
                (_number, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'13, tshort) :: (_t'12, tshort) ::
               (_t'11, tshort) :: (_t'10, tshort) :: (_t'9, tshort) ::
               (_t'8, tshort) :: (_t'7, tshort) :: (_t'6, tshort) ::
               (_t'5, tshort) :: (_t'4, tshort) :: (_t'3, tshort) ::
               (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'2
    (Ederef
      (Ebinop Oadd (Etempvar _printState (tptr tshort))
        (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
  (Sifthenelse (Eunop Onotbool (Etempvar _t'2 tshort) tint)
    (Ssequence
      (Ssequence
        (Sset _t'10
          (Ederef
            (Ebinop Oadd (Etempvar _printState (tptr tshort))
              (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort))
        (Ssequence
          (Sset _t'11
            (Ederef
              (Ebinop Oadd (Etempvar _printState (tptr tshort))
                (Econst_int (Int.repr 3) tint) (tptr tshort)) tshort))
          (Sifthenelse (Ebinop Olt (Etempvar _t'10 tshort)
                         (Etempvar _t'11 tshort) tint)
            (Sset _t'1 (Econst_int (Int.repr 1) tint))
            (Ssequence
              (Sset _t'12
                (Ederef
                  (Ebinop Oadd (Etempvar _printState (tptr tshort))
                    (Econst_int (Int.repr 4) tint) (tptr tshort)) tshort))
              (Ssequence
                (Sset _t'13
                  (Ederef
                    (Ebinop Oadd (Etempvar _printState (tptr tshort))
                      (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort))
                (Sset _t'1
                  (Ecast
                    (Ebinop Olt (Etempvar _t'12 tshort)
                      (Etempvar _t'13 tshort) tint) tbool)))))))
      (Sifthenelse (Etempvar _t'1 tint)
        (Ssequence
          (Ssequence
            (Sset _t'8
              (Ederef
                (Ebinop Oadd (Etempvar _printState (tptr tshort))
                  (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
            (Ssequence
              (Sset _t'9
                (Ederef
                  (Ebinop Oadd (Etempvar _printState (tptr tshort))
                    (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort))
              (Scall None
                (Evar _print_text (Tfunction
                                    (tint :: tint :: (tptr tuchar) :: nil)
                                    tvoid cc_default))
                ((Etempvar _t'8 tshort) :: (Etempvar _t'9 tshort) ::
                 (Evar ___stringlit_19 (tarray tuchar 12)) :: nil))))
          (Ssequence
            (Sset _t'7
              (Ederef
                (Ebinop Oadd (Etempvar _printState (tptr tshort))
                  (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
            (Sassign
              (Ederef
                (Ebinop Oadd (Etempvar _printState (tptr tshort))
                  (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort)
              (Ebinop Oadd (Etempvar _t'7 tshort)
                (Econst_int (Int.repr 1) tint) tint))))
        (Ssequence
          (Ssequence
            (Sset _t'5
              (Ederef
                (Ebinop Oadd (Etempvar _printState (tptr tshort))
                  (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
            (Ssequence
              (Sset _t'6
                (Ederef
                  (Ebinop Oadd (Etempvar _printState (tptr tshort))
                    (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort))
              (Scall None
                (Evar _print_text_fmt_int (Tfunction
                                            (tint :: tint :: (tptr tuchar) ::
                                             tint :: nil) tvoid cc_default))
                ((Etempvar _t'5 tshort) :: (Etempvar _t'6 tshort) ::
                 (Etempvar _str (tptr tuchar)) :: (Etempvar _number tint) ::
                 nil))))
          (Ssequence
            (Sset _t'3
              (Ederef
                (Ebinop Oadd (Etempvar _printState (tptr tshort))
                  (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort))
            (Ssequence
              (Sset _t'4
                (Ederef
                  (Ebinop Oadd (Etempvar _printState (tptr tshort))
                    (Econst_int (Int.repr 5) tint) (tptr tshort)) tshort))
              (Sassign
                (Ederef
                  (Ebinop Oadd (Etempvar _printState (tptr tshort))
                    (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort)
                (Ebinop Oadd (Etempvar _t'3 tshort) (Etempvar _t'4 tshort)
                  tint)))))))
    Sskip))
|}.

Definition f_set_text_array_x_y := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_xOffset, tint) :: (_yOffset, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_printState, (tptr tshort)) :: (_t'3, tshort) ::
               (_t'2, tshort) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _printState (Evar _gDebugPrintState1 (tarray tshort 6)))
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Ederef
          (Ebinop Oadd (Etempvar _printState (tptr tshort))
            (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
      (Sassign
        (Ederef
          (Ebinop Oadd (Etempvar _printState (tptr tshort))
            (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort)
        (Ebinop Oadd (Etempvar _t'3 tshort) (Etempvar _xOffset tint) tint)))
    (Ssequence
      (Sset _t'1
        (Ederef
          (Ebinop Oadd (Etempvar _printState (tptr tshort))
            (Econst_int (Int.repr 5) tint) (tptr tshort)) tshort))
      (Ssequence
        (Sset _t'2
          (Ederef
            (Ebinop Oadd (Etempvar _printState (tptr tshort))
              (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort))
        (Sassign
          (Ederef
            (Ebinop Oadd (Etempvar _printState (tptr tshort))
              (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort)
          (Ebinop Oadd
            (Ebinop Omul (Etempvar _yOffset tint) (Etempvar _t'1 tshort)
              tint) (Etempvar _t'2 tshort) tint))))))
|}.

Definition f_print_debug_bottom_up := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_str, (tptr tuchar)) :: (_number, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _gDebugInfoFlags tint))
  (Sifthenelse (Ebinop Oand (Etempvar _t'1 tint)
                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                   (Econst_int (Int.repr 0) tint) tint) tint)
    (Scall None
      (Evar _print_text_array_info (Tfunction
                                     ((tptr tshort) :: (tptr tuchar) ::
                                      tint :: nil) tvoid cc_default))
      ((Evar _gDebugPrintState2 (tarray tshort 6)) ::
       (Etempvar _str (tptr tuchar)) :: (Etempvar _number tint) :: nil))
    Sskip))
|}.

Definition f_print_debug_top_down_objectinfo := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_str, (tptr tuchar)) :: (_number, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'3, tschar) :: (_t'2, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2 (Evar _gDebugInfoFlags tint))
    (Sifthenelse (Ebinop Oand (Etempvar _t'2 tint)
                   (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                     (Econst_int (Int.repr 0) tint) tint) tint)
      (Ssequence
        (Sset _t'3 (Evar _sDebugPage tschar))
        (Sset _t'1
          (Ecast
            (Ebinop Oeq (Etempvar _t'3 tschar) (Econst_int (Int.repr 0) tint)
              tint) tbool)))
      (Sset _t'1 (Econst_int (Int.repr 0) tint))))
  (Sifthenelse (Etempvar _t'1 tint)
    (Scall None
      (Evar _print_text_array_info (Tfunction
                                     ((tptr tshort) :: (tptr tuchar) ::
                                      tint :: nil) tvoid cc_default))
      ((Evar _gDebugPrintState1 (tarray tshort 6)) ::
       (Etempvar _str (tptr tuchar)) :: (Etempvar _number tint) :: nil))
    Sskip))
|}.

Definition f_print_debug_top_down_mapinfo := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_str, (tptr tuchar)) :: (_number, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tschar) :: (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2 (Evar _sNoExtraDebug tschar))
    (Sifthenelse (Etempvar _t'2 tschar) (Sreturn None) Sskip))
  (Ssequence
    (Sset _t'1 (Evar _gDebugInfoFlags tint))
    (Sifthenelse (Ebinop Oand (Etempvar _t'1 tint)
                   (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                     (Econst_int (Int.repr 0) tint) tint) tint)
      (Scall None
        (Evar _print_text_array_info (Tfunction
                                       ((tptr tshort) :: (tptr tuchar) ::
                                        tint :: nil) tvoid cc_default))
        ((Evar _gDebugPrintState1 (tarray tshort 6)) ::
         (Etempvar _str (tptr tuchar)) :: (Etempvar _number tint) :: nil))
      Sskip)))
|}.

Definition f_print_debug_top_down_normal := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_str, (tptr tuchar)) :: (_number, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _gDebugInfoFlags tint))
  (Sifthenelse (Ebinop Oand (Etempvar _t'1 tint)
                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                   (Econst_int (Int.repr 0) tint) tint) tint)
    (Scall None
      (Evar _print_text_array_info (Tfunction
                                     ((tptr tshort) :: (tptr tuchar) ::
                                      tint :: nil) tvoid cc_default))
      ((Evar _gDebugPrintState1 (tarray tshort 6)) ::
       (Etempvar _str (tptr tuchar)) :: (Etempvar _number tint) :: nil))
    Sskip))
|}.

Definition f_print_mapinfo := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_pfloor, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_temps := ((_bgY, tfloat) :: (_water, tfloat) :: (_area, tint) ::
               (_angY, tint) :: (_t'2, tfloat) :: (_t'1, tfloat) ::
               (_t'33, tint) :: (_t'32, (tptr (Tstruct _Object noattr))) ::
               (_t'31, tfloat) :: (_t'30, (tptr (Tstruct _Object noattr))) ::
               (_t'29, tfloat) :: (_t'28, (tptr (Tstruct _Object noattr))) ::
               (_t'27, tfloat) :: (_t'26, (tptr (Tstruct _Object noattr))) ::
               (_t'25, tfloat) :: (_t'24, (tptr (Tstruct _Object noattr))) ::
               (_t'23, tfloat) :: (_t'22, (tptr (Tstruct _Object noattr))) ::
               (_t'21, tfloat) :: (_t'20, (tptr (Tstruct _Object noattr))) ::
               (_t'19, tfloat) :: (_t'18, (tptr (Tstruct _Object noattr))) ::
               (_t'17, tfloat) :: (_t'16, (tptr (Tstruct _Object noattr))) ::
               (_t'15, tfloat) :: (_t'14, (tptr (Tstruct _Object noattr))) ::
               (_t'13, tfloat) :: (_t'12, (tptr (Tstruct _Object noattr))) ::
               (_t'11, tshort) ::
               (_t'10, (tptr (Tstruct _Surface noattr))) :: (_t'9, tschar) ::
               (_t'8, (tptr (Tstruct _Surface noattr))) :: (_t'7, tschar) ::
               (_t'6, (tptr (Tstruct _Surface noattr))) ::
               (_t'5, (tptr (Tstruct _Surface noattr))) :: (_t'4, tfloat) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'32 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'33
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'32 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __727 noattr))
              _asS32 (tarray tint 80))
            (Ebinop Oadd (Econst_int (Int.repr 15) tint)
              (Econst_int (Int.repr 1) tint) tint) (tptr tint)) tint))
      (Sset _angY
        (Ecast
          (Ebinop Odiv (Etempvar _t'33 tint)
            (Econst_float (Float.of_bits (Int64.repr 4640609120396779717)) tdouble)
            tdouble) tint))))
  (Ssequence
    (Ssequence
      (Sset _t'28 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'29
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'28 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __727 noattr))
                _asF32 (tarray tfloat 80))
              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                (Econst_int (Int.repr 0) tint) tint) (tptr tfloat)) tfloat))
        (Ssequence
          (Sset _t'30 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'31
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _t'30 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __727 noattr)) _asF32 (tarray tfloat 80))
                  (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                    (Econst_int (Int.repr 2) tint) tint) (tptr tfloat))
                tfloat))
            (Sset _area
              (Ebinop Oadd
                (Ebinop Odiv
                  (Ebinop Oadd (Ecast (Etempvar _t'29 tfloat) tint)
                    (Econst_int (Int.repr 8192) tint) tint)
                  (Econst_int (Int.repr 1024) tint) tint)
                (Ebinop Omul
                  (Ebinop Odiv
                    (Ebinop Oadd (Ecast (Etempvar _t'31 tfloat) tint)
                      (Econst_int (Int.repr 8192) tint) tint)
                    (Econst_int (Int.repr 1024) tint) tint)
                  (Econst_int (Int.repr 16) tint) tint) tint))))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'22 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'23
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _t'22 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __727 noattr)) _asF32 (tarray tfloat 80))
                  (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                    (Econst_int (Int.repr 0) tint) tint) (tptr tfloat))
                tfloat))
            (Ssequence
              (Sset _t'24
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'25
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'24 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __727 noattr)) _asF32 (tarray tfloat 80))
                      (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                        (Econst_int (Int.repr 1) tint) tint) (tptr tfloat))
                    tfloat))
                (Ssequence
                  (Sset _t'26
                    (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sset _t'27
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'26 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __727 noattr)) _asF32
                            (tarray tfloat 80))
                          (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                            (Econst_int (Int.repr 2) tint) tint)
                          (tptr tfloat)) tfloat))
                    (Scall (Some _t'1)
                      (Evar _find_floor (Tfunction
                                          (tfloat :: tfloat :: tfloat ::
                                           (tptr (tptr (Tstruct _Surface noattr))) ::
                                           nil) tfloat cc_default))
                      ((Etempvar _t'23 tfloat) :: (Etempvar _t'25 tfloat) ::
                       (Etempvar _t'27 tfloat) ::
                       (Eaddrof
                         (Evar _pfloor (tptr (Tstruct _Surface noattr)))
                         (tptr (tptr (Tstruct _Surface noattr)))) :: nil))))))))
        (Sset _bgY (Etempvar _t'1 tfloat)))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'18
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'19
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'18 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __727 noattr)) _asF32 (tarray tfloat 80))
                    (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                      (Econst_int (Int.repr 0) tint) tint) (tptr tfloat))
                  tfloat))
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
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __727 noattr)) _asF32 (tarray tfloat 80))
                        (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                          (Econst_int (Int.repr 2) tint) tint) (tptr tfloat))
                      tfloat))
                  (Scall (Some _t'2)
                    (Evar _find_water_level (Tfunction
                                              (tfloat :: tfloat :: nil)
                                              tfloat cc_default))
                    ((Etempvar _t'19 tfloat) :: (Etempvar _t'21 tfloat) ::
                     nil))))))
          (Sset _water (Etempvar _t'2 tfloat)))
        (Ssequence
          (Scall None
            (Evar _print_debug_top_down_normal (Tfunction
                                                 ((tptr tuchar) :: tint ::
                                                  nil) tvoid cc_default))
            ((Evar ___stringlit_20 (tarray tuchar 8)) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Ssequence
            (Scall None
              (Evar _print_debug_top_down_mapinfo (Tfunction
                                                    ((tptr tuchar) :: tint ::
                                                     nil) tvoid cc_default))
              ((Evar ___stringlit_21 (tarray tuchar 8)) ::
               (Etempvar _area tint) :: nil))
            (Ssequence
              (Ssequence
                (Sset _t'16
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'17
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'16 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __727 noattr)) _asF32 (tarray tfloat 80))
                        (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                          (Econst_int (Int.repr 0) tint) tint) (tptr tfloat))
                      tfloat))
                  (Scall None
                    (Evar _print_debug_top_down_mapinfo (Tfunction
                                                          ((tptr tuchar) ::
                                                           tint :: nil) tvoid
                                                          cc_default))
                    ((Evar ___stringlit_22 (tarray tuchar 8)) ::
                     (Etempvar _t'17 tfloat) :: nil))))
              (Ssequence
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
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __727 noattr)) _asF32
                            (tarray tfloat 80))
                          (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                            (Econst_int (Int.repr 1) tint) tint)
                          (tptr tfloat)) tfloat))
                    (Scall None
                      (Evar _print_debug_top_down_mapinfo (Tfunction
                                                            ((tptr tuchar) ::
                                                             tint :: nil)
                                                            tvoid cc_default))
                      ((Evar ___stringlit_23 (tarray tuchar 8)) ::
                       (Etempvar _t'15 tfloat) :: nil))))
                (Ssequence
                  (Ssequence
                    (Sset _t'12
                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sset _t'13
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'12 (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _rawData
                                (Tunion __727 noattr)) _asF32
                              (tarray tfloat 80))
                            (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                              (Econst_int (Int.repr 2) tint) tint)
                            (tptr tfloat)) tfloat))
                      (Scall None
                        (Evar _print_debug_top_down_mapinfo (Tfunction
                                                              ((tptr tuchar) ::
                                                               tint :: nil)
                                                              tvoid
                                                              cc_default))
                        ((Evar ___stringlit_24 (tarray tuchar 8)) ::
                         (Etempvar _t'13 tfloat) :: nil))))
                  (Ssequence
                    (Scall None
                      (Evar _print_debug_top_down_mapinfo (Tfunction
                                                            ((tptr tuchar) ::
                                                             tint :: nil)
                                                            tvoid cc_default))
                      ((Evar ___stringlit_25 (tarray tuchar 8)) ::
                       (Etempvar _bgY tfloat) :: nil))
                    (Ssequence
                      (Scall None
                        (Evar _print_debug_top_down_mapinfo (Tfunction
                                                              ((tptr tuchar) ::
                                                               tint :: nil)
                                                              tvoid
                                                              cc_default))
                        ((Evar ___stringlit_26 (tarray tuchar 8)) ::
                         (Etempvar _angY tint) :: nil))
                      (Ssequence
                        (Ssequence
                          (Sset _t'5
                            (Evar _pfloor (tptr (Tstruct _Surface noattr))))
                          (Sifthenelse (Ebinop One
                                         (Etempvar _t'5 (tptr (Tstruct _Surface noattr)))
                                         (Ecast
                                           (Econst_int (Int.repr 0) tint)
                                           (tptr tvoid)) tint)
                            (Ssequence
                              (Ssequence
                                (Sset _t'10
                                  (Evar _pfloor (tptr (Tstruct _Surface noattr))))
                                (Ssequence
                                  (Sset _t'11
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'10 (tptr (Tstruct _Surface noattr)))
                                        (Tstruct _Surface noattr)) _type
                                      tshort))
                                  (Scall None
                                    (Evar _print_debug_top_down_mapinfo 
                                    (Tfunction ((tptr tuchar) :: tint :: nil)
                                      tvoid cc_default))
                                    ((Evar ___stringlit_27 (tarray tuchar 12)) ::
                                     (Etempvar _t'11 tshort) :: nil))))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'8
                                    (Evar _pfloor (tptr (Tstruct _Surface noattr))))
                                  (Ssequence
                                    (Sset _t'9
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'8 (tptr (Tstruct _Surface noattr)))
                                          (Tstruct _Surface noattr)) _flags
                                        tschar))
                                    (Scall None
                                      (Evar _print_debug_top_down_mapinfo 
                                      (Tfunction
                                        ((tptr tuchar) :: tint :: nil) tvoid
                                        cc_default))
                                      ((Evar ___stringlit_28 (tarray tuchar 12)) ::
                                       (Etempvar _t'9 tschar) :: nil))))
                                (Ssequence
                                  (Sset _t'6
                                    (Evar _pfloor (tptr (Tstruct _Surface noattr))))
                                  (Ssequence
                                    (Sset _t'7
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'6 (tptr (Tstruct _Surface noattr)))
                                          (Tstruct _Surface noattr)) _room
                                        tschar))
                                    (Scall None
                                      (Evar _print_debug_top_down_mapinfo 
                                      (Tfunction
                                        ((tptr tuchar) :: tint :: nil) tvoid
                                        cc_default))
                                      ((Evar ___stringlit_29 (tarray tuchar 12)) ::
                                       (Etempvar _t'7 tschar) :: nil))))))
                            Sskip))
                        (Ssequence
                          (Sset _t'3
                            (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                          (Ssequence
                            (Sset _t'4
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _rawData
                                      (Tunion __727 noattr)) _asF32
                                    (tarray tfloat 80))
                                  (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  (tptr tfloat)) tfloat))
                            (Sifthenelse (Ebinop Olt (Etempvar _t'4 tfloat)
                                           (Etempvar _water tfloat) tint)
                              (Scall None
                                (Evar _print_debug_top_down_mapinfo (Tfunction
                                                                    ((tptr tuchar) ::
                                                                    tint ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                ((Evar ___stringlit_30 (tarray tuchar 9)) ::
                                 (Etempvar _water tfloat) :: nil))
                              Sskip)))))))))))))))
|}.

Definition f_print_checkinfo := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Scall None
  (Evar _print_debug_top_down_normal (Tfunction
                                       ((tptr tuchar) :: tint :: nil) tvoid
                                       cc_default))
  ((Evar ___stringlit_31 (tarray tuchar 10)) ::
   (Econst_int (Int.repr 0) tint) :: nil))
|}.

Definition f_print_surfaceinfo := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'4, tfloat) :: (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, tfloat) :: (_t'1, (tptr (Tstruct _Object noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _gMarioObject (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Sset _t'2
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Ederef (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _rawData (Tunion __727 noattr))
            _asF32 (tarray tfloat 80))
          (Ebinop Oadd (Econst_int (Int.repr 6) tint)
            (Econst_int (Int.repr 0) tint) tint) (tptr tfloat)) tfloat))
    (Ssequence
      (Sset _t'3 (Evar _gMarioObject (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'4
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __727 noattr))
                _asF32 (tarray tfloat 80))
              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                (Econst_int (Int.repr 2) tint) tint) (tptr tfloat)) tfloat))
        (Scall None
          (Evar _debug_surface_list_info (Tfunction (tfloat :: tfloat :: nil)
                                           tvoid cc_default))
          ((Etempvar _t'2 tfloat) :: (Etempvar _t'4 tfloat) :: nil))))))
|}.

Definition f_print_stageinfo := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _print_debug_top_down_normal (Tfunction
                                         ((tptr tuchar) :: tint :: nil) tvoid
                                         cc_default))
    ((Evar ___stringlit_32 (tarray tuchar 10)) ::
     (Econst_int (Int.repr 0) tint) :: nil))
  (Ssequence
    (Sset _t'1 (Evar _gTTCSpeedSetting tshort))
    (Scall None
      (Evar _print_debug_top_down_normal (Tfunction
                                           ((tptr tuchar) :: tint :: nil)
                                           tvoid cc_default))
      ((Evar ___stringlit_33 (tarray tuchar 15)) :: (Etempvar _t'1 tshort) ::
       nil))))
|}.

Definition f_print_string_array_info := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_strArr, (tptr (tptr tuchar))) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_t'8, tschar) :: (_t'7, tshort) ::
               (_t'6, tschar) :: (_t'5, (tptr tuchar)) :: (_t'4, tschar) ::
               (_t'3, (tptr tuchar)) :: (_t'2, tschar) :: (_t'1, tschar) ::
               nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _sDebugStringArrPrinted tschar))
  (Sifthenelse (Eunop Onotbool (Etempvar _t'1 tschar) tint)
    (Ssequence
      (Ssequence
        (Sset _t'8 (Evar _sDebugStringArrPrinted tschar))
        (Sassign (Evar _sDebugStringArrPrinted tschar)
          (Ebinop Oadd (Etempvar _t'8 tschar) (Econst_int (Int.repr 1) tint)
            tint)))
      (Ssequence
        (Ssequence
          (Sset _i (Econst_int (Int.repr 0) tint))
          (Sloop
            (Ssequence
              (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                             (Econst_int (Int.repr 8) tint) tint)
                Sskip
                Sbreak)
              (Ssequence
                (Sset _t'5
                  (Ederef
                    (Ebinop Oadd (Etempvar _strArr (tptr (tptr tuchar)))
                      (Etempvar _i tint) (tptr (tptr tuchar))) (tptr tuchar)))
                (Ssequence
                  (Sset _t'6 (Evar _sDebugPage tschar))
                  (Ssequence
                    (Sset _t'7
                      (Ederef
                        (Ebinop Oadd
                          (Ederef
                            (Ebinop Oadd
                              (Evar _gDebugInfo (tarray (tarray tshort 8) 0))
                              (Etempvar _t'6 tschar)
                              (tptr (tarray tshort 8))) (tarray tshort 8))
                          (Etempvar _i tint) (tptr tshort)) tshort))
                    (Scall None
                      (Evar _print_debug_top_down_mapinfo (Tfunction
                                                            ((tptr tuchar) ::
                                                             tint :: nil)
                                                            tvoid cc_default))
                      ((Etempvar _t'5 (tptr tuchar)) ::
                       (Etempvar _t'7 tshort) :: nil))))))
            (Sset _i
              (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint)
                tint))))
        (Ssequence
          (Ssequence
            (Sset _t'4 (Evar _sDebugSysCursor tschar))
            (Scall None
              (Evar _set_text_array_x_y (Tfunction (tint :: tint :: nil)
                                          tvoid cc_default))
              ((Econst_int (Int.repr 0) tint) ::
               (Ebinop Osub (Eunop Oneg (Econst_int (Int.repr 1) tint) tint)
                 (Ecast
                   (Ebinop Osub (Econst_int (Int.repr 7) tint)
                     (Etempvar _t'4 tschar) tint) tuint) tuint) :: nil)))
          (Ssequence
            (Ssequence
              (Sset _t'3
                (Ederef
                  (Ebinop Oadd (Etempvar _strArr (tptr (tptr tuchar)))
                    (Econst_int (Int.repr 8) tint) (tptr (tptr tuchar)))
                  (tptr tuchar)))
              (Scall None
                (Evar _print_debug_top_down_mapinfo (Tfunction
                                                      ((tptr tuchar) ::
                                                       tint :: nil) tvoid
                                                      cc_default))
                ((Etempvar _t'3 (tptr tuchar)) ::
                 (Econst_int (Int.repr 0) tint) :: nil)))
            (Ssequence
              (Sset _t'2 (Evar _sDebugSysCursor tschar))
              (Scall None
                (Evar _set_text_array_x_y (Tfunction (tint :: tint :: nil)
                                            tvoid cc_default))
                ((Econst_int (Int.repr 0) tint) ::
                 (Ebinop Osub (Econst_int (Int.repr 7) tint)
                   (Etempvar _t'2 tschar) tint) :: nil)))))))
    Sskip))
|}.

Definition f_print_effectinfo := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _print_debug_top_down_normal (Tfunction
                                         ((tptr tuchar) :: tint :: nil) tvoid
                                         cc_default))
    ((Evar ___stringlit_34 (tarray tuchar 11)) ::
     (Econst_int (Int.repr 0) tint) :: nil))
  (Scall None
    (Evar _print_string_array_info (Tfunction ((tptr (tptr tuchar)) :: nil)
                                     tvoid cc_default))
    ((Evar _sDebugEffectStringInfo (tarray (tptr tuchar) 9)) :: nil)))
|}.

Definition f_print_enemyinfo := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _print_debug_top_down_normal (Tfunction
                                         ((tptr tuchar) :: tint :: nil) tvoid
                                         cc_default))
    ((Evar ___stringlit_35 (tarray tuchar 10)) ::
     (Econst_int (Int.repr 0) tint) :: nil))
  (Scall None
    (Evar _print_string_array_info (Tfunction ((tptr (tptr tuchar)) :: nil)
                                     tvoid cc_default))
    ((Evar _sDebugEnemyStringInfo (tarray (tptr tuchar) 9)) :: nil)))
|}.

Definition f_update_debug_dpadmask := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_dPadMask, tint) :: (_t'6, tushort) ::
               (_t'5, (tptr (Tstruct _Controller noattr))) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5
      (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
    (Ssequence
      (Sset _t'6
        (Efield
          (Ederef (Etempvar _t'5 (tptr (Tstruct _Controller noattr)))
            (Tstruct _Controller noattr)) _buttonDown tushort))
      (Sset _dPadMask
        (Ebinop Oand (Etempvar _t'6 tushort)
          (Ebinop Oor
            (Ebinop Oor
              (Ebinop Oor (Econst_int (Int.repr 2048) tint)
                (Econst_int (Int.repr 1024) tint) tint)
              (Econst_int (Int.repr 512) tint) tint)
            (Econst_int (Int.repr 256) tint) tint) tint))))
  (Sifthenelse (Eunop Onotbool (Etempvar _dPadMask tint) tint)
    (Ssequence
      (Sassign (Evar _sDebugInfoDPadUpdID tint)
        (Econst_int (Int.repr 0) tint))
      (Sassign (Evar _sDebugInfoDPadMask tint)
        (Econst_int (Int.repr 0) tint)))
    (Ssequence
      (Ssequence
        (Sset _t'3 (Evar _sDebugInfoDPadUpdID tint))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tint)
                       (Econst_int (Int.repr 0) tint) tint)
          (Sassign (Evar _sDebugInfoDPadMask tint) (Etempvar _dPadMask tint))
          (Ssequence
            (Sset _t'4 (Evar _sDebugInfoDPadUpdID tint))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tint)
                           (Econst_int (Int.repr 6) tint) tint)
              (Sassign (Evar _sDebugInfoDPadMask tint)
                (Etempvar _dPadMask tint))
              (Sassign (Evar _sDebugInfoDPadMask tint)
                (Econst_int (Int.repr 0) tint))))))
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _sDebugInfoDPadUpdID tint))
          (Sassign (Evar _sDebugInfoDPadUpdID tint)
            (Ebinop Oadd (Etempvar _t'2 tint) (Econst_int (Int.repr 1) tint)
              tint)))
        (Ssequence
          (Sset _t'1 (Evar _sDebugInfoDPadUpdID tint))
          (Sifthenelse (Ebinop Oge (Etempvar _t'1 tint)
                         (Econst_int (Int.repr 8) tint) tint)
            (Sassign (Evar _sDebugInfoDPadUpdID tint)
              (Econst_int (Int.repr 6) tint))
            Sskip))))))
|}.

Definition f_debug_unknown_level_select_check := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'3, tschar) :: (_t'2, tschar) :: (_t'1, tschar) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _sDebugLvSelectCheckFlag tschar))
  (Sifthenelse (Eunop Onotbool (Etempvar _t'1 tschar) tint)
    (Ssequence
      (Ssequence
        (Sset _t'3 (Evar _sDebugLvSelectCheckFlag tschar))
        (Sassign (Evar _sDebugLvSelectCheckFlag tschar)
          (Ebinop Oadd (Etempvar _t'3 tschar) (Econst_int (Int.repr 1) tint)
            tint)))
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _gDebugLevelSelect tschar))
          (Sifthenelse (Eunop Onotbool (Etempvar _t'2 tschar) tint)
            (Sassign (Evar _gDebugInfoFlags tint)
              (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                (Econst_int (Int.repr 0) tint) tint))
            (Sassign (Evar _gDebugInfoFlags tint)
              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 1) tint) tint))))
        (Ssequence
          (Sassign
            (Efield (Evar _gNumCalls (Tstruct _NumTimesCalled noattr)) _floor
              tshort) (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Sassign
              (Efield (Evar _gNumCalls (Tstruct _NumTimesCalled noattr))
                _ceil tshort) (Econst_int (Int.repr 0) tint))
            (Sassign
              (Efield (Evar _gNumCalls (Tstruct _NumTimesCalled noattr))
                _wall tshort) (Econst_int (Int.repr 0) tint))))))
    Sskip))
|}.

Definition f_reset_debug_objectinfo := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sassign (Evar _gNumFindFloorMisses tint) (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sassign (Evar _gUnknownWallCount tint) (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Sassign (Evar _gObjectCounter tuint) (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Sassign (Evar _sDebugStringArrPrinted tschar)
          (Econst_int (Int.repr 0) tint))
        (Ssequence
          (Sassign (Evar _D_8035FEE2 tshort) (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Sassign (Evar _D_8035FEE4 tshort)
              (Econst_int (Int.repr 0) tint))
            (Ssequence
              (Scall None
                (Evar _set_print_state_info (Tfunction
                                              ((tptr tshort) :: tshort ::
                                               tshort :: tshort :: tshort ::
                                               tshort :: nil) tvoid
                                              cc_default))
                ((Evar _gDebugPrintState1 (tarray tshort 6)) ::
                 (Econst_int (Int.repr 20) tint) ::
                 (Econst_int (Int.repr 185) tint) ::
                 (Econst_int (Int.repr 40) tint) ::
                 (Econst_int (Int.repr 200) tint) ::
                 (Eunop Oneg (Econst_int (Int.repr 15) tint) tint) :: nil))
              (Ssequence
                (Scall None
                  (Evar _set_print_state_info (Tfunction
                                                ((tptr tshort) :: tshort ::
                                                 tshort :: tshort ::
                                                 tshort :: tshort :: nil)
                                                tvoid cc_default))
                  ((Evar _gDebugPrintState2 (tarray tshort 6)) ::
                   (Econst_int (Int.repr 180) tint) ::
                   (Econst_int (Int.repr 30) tint) ::
                   (Econst_int (Int.repr 0) tint) ::
                   (Econst_int (Int.repr 150) tint) ::
                   (Econst_int (Int.repr 15) tint) :: nil))
                (Scall None
                  (Evar _update_debug_dpadmask (Tfunction nil tvoid
                                                 cc_default)) nil)))))))))
|}.

Definition f_try_modify_debug_controls := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_sp4, tint) :: (_t'1, tint) :: (_t'34, tschar) ::
               (_t'33, tushort) ::
               (_t'32, (tptr (Tstruct _Controller noattr))) ::
               (_t'31, tschar) :: (_t'30, tushort) ::
               (_t'29, (tptr (Tstruct _Controller noattr))) ::
               (_t'28, tushort) ::
               (_t'27, (tptr (Tstruct _Controller noattr))) ::
               (_t'26, tschar) :: (_t'25, tschar) :: (_t'24, tint) ::
               (_t'23, tschar) :: (_t'22, tschar) :: (_t'21, tint) ::
               (_t'20, tshort) :: (_t'19, tschar) :: (_t'18, tschar) ::
               (_t'17, tschar) :: (_t'16, tschar) :: (_t'15, tshort) ::
               (_t'14, tschar) :: (_t'13, tschar) :: (_t'12, tschar) ::
               (_t'11, tschar) :: (_t'10, tushort) ::
               (_t'9, (tptr (Tstruct _Controller noattr))) :: (_t'8, tint) ::
               (_t'7, tshort) :: (_t'6, tschar) :: (_t'5, tschar) ::
               (_t'4, tschar) :: (_t'3, tschar) :: (_t'2, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'32
      (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
    (Ssequence
      (Sset _t'33
        (Efield
          (Ederef (Etempvar _t'32 (tptr (Tstruct _Controller noattr)))
            (Tstruct _Controller noattr)) _buttonPressed tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'33 tushort)
                     (Econst_int (Int.repr 8192) tint) tint)
        (Ssequence
          (Sset _t'34 (Evar _sNoExtraDebug tschar))
          (Sassign (Evar _sNoExtraDebug tschar)
            (Ebinop Oxor (Etempvar _t'34 tschar)
              (Econst_int (Int.repr 1) tint) tint)))
        Sskip)))
  (Ssequence
    (Ssequence
      (Sset _t'29
        (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
      (Ssequence
        (Sset _t'30
          (Efield
            (Ederef (Etempvar _t'29 (tptr (Tstruct _Controller noattr)))
              (Tstruct _Controller noattr)) _buttonDown tushort))
        (Sifthenelse (Eunop Onotbool
                       (Ebinop Oand (Etempvar _t'30 tushort)
                         (Ebinop Oor (Econst_int (Int.repr 32) tint)
                           (Econst_int (Int.repr 16) tint) tint) tint) tint)
          (Ssequence
            (Sset _t'31 (Evar _sNoExtraDebug tschar))
            (Sset _t'1
              (Ecast (Eunop Onotbool (Etempvar _t'31 tschar) tint) tbool)))
          (Sset _t'1 (Econst_int (Int.repr 0) tint)))))
    (Sifthenelse (Etempvar _t'1 tint)
      (Ssequence
        (Sset _sp4 (Econst_int (Int.repr 1) tint))
        (Ssequence
          (Ssequence
            (Sset _t'27
              (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
            (Ssequence
              (Sset _t'28
                (Efield
                  (Ederef
                    (Etempvar _t'27 (tptr (Tstruct _Controller noattr)))
                    (Tstruct _Controller noattr)) _buttonDown tushort))
              (Sifthenelse (Ebinop Oand (Etempvar _t'28 tushort)
                             (Econst_int (Int.repr 16384) tint) tint)
                (Sset _sp4 (Econst_int (Int.repr 100) tint))
                Sskip)))
          (Ssequence
            (Ssequence
              (Sset _t'24 (Evar _sDebugInfoDPadMask tint))
              (Sifthenelse (Ebinop Oand (Etempvar _t'24 tint)
                             (Econst_int (Int.repr 2048) tint) tint)
                (Ssequence
                  (Ssequence
                    (Sset _t'26 (Evar _sDebugSysCursor tschar))
                    (Sassign (Evar _sDebugSysCursor tschar)
                      (Ebinop Osub (Etempvar _t'26 tschar)
                        (Econst_int (Int.repr 1) tint) tint)))
                  (Ssequence
                    (Sset _t'25 (Evar _sDebugSysCursor tschar))
                    (Sifthenelse (Ebinop Olt (Etempvar _t'25 tschar)
                                   (Econst_int (Int.repr 0) tint) tint)
                      (Sassign (Evar _sDebugSysCursor tschar)
                        (Econst_int (Int.repr 0) tint))
                      Sskip)))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'21 (Evar _sDebugInfoDPadMask tint))
                (Sifthenelse (Ebinop Oand (Etempvar _t'21 tint)
                               (Econst_int (Int.repr 1024) tint) tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'23 (Evar _sDebugSysCursor tschar))
                      (Sassign (Evar _sDebugSysCursor tschar)
                        (Ebinop Oadd (Etempvar _t'23 tschar)
                          (Econst_int (Int.repr 1) tint) tint)))
                    (Ssequence
                      (Sset _t'22 (Evar _sDebugSysCursor tschar))
                      (Sifthenelse (Ebinop Oge (Etempvar _t'22 tschar)
                                     (Econst_int (Int.repr 8) tint) tint)
                        (Sassign (Evar _sDebugSysCursor tschar)
                          (Econst_int (Int.repr 7) tint))
                        Sskip)))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _t'8 (Evar _sDebugInfoDPadMask tint))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'8 tint)
                                 (Econst_int (Int.repr 512) tint) tint)
                    (Ssequence
                      (Sset _t'9
                        (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
                      (Ssequence
                        (Sset _t'10
                          (Efield
                            (Ederef
                              (Etempvar _t'9 (tptr (Tstruct _Controller noattr)))
                              (Tstruct _Controller noattr)) _buttonDown
                            tushort))
                        (Sifthenelse (Ebinop Oand (Etempvar _t'10 tushort)
                                       (Econst_int (Int.repr 32768) tint)
                                       tint)
                          (Ssequence
                            (Sset _t'16 (Evar _sDebugPage tschar))
                            (Ssequence
                              (Sset _t'17 (Evar _sDebugSysCursor tschar))
                              (Ssequence
                                (Sset _t'18 (Evar _sDebugPage tschar))
                                (Ssequence
                                  (Sset _t'19 (Evar _sDebugSysCursor tschar))
                                  (Ssequence
                                    (Sset _t'20
                                      (Ederef
                                        (Ebinop Oadd
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _gDebugInfoOverwrite (tarray (tarray tshort 8) 0))
                                              (Etempvar _t'18 tschar)
                                              (tptr (tarray tshort 8)))
                                            (tarray tshort 8))
                                          (Etempvar _t'19 tschar)
                                          (tptr tshort)) tshort))
                                    (Sassign
                                      (Ederef
                                        (Ebinop Oadd
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _gDebugInfo (tarray (tarray tshort 8) 0))
                                              (Etempvar _t'16 tschar)
                                              (tptr (tarray tshort 8)))
                                            (tarray tshort 8))
                                          (Etempvar _t'17 tschar)
                                          (tptr tshort)) tshort)
                                      (Etempvar _t'20 tshort)))))))
                          (Ssequence
                            (Sset _t'11 (Evar _sDebugPage tschar))
                            (Ssequence
                              (Sset _t'12 (Evar _sDebugSysCursor tschar))
                              (Ssequence
                                (Sset _t'13 (Evar _sDebugPage tschar))
                                (Ssequence
                                  (Sset _t'14 (Evar _sDebugSysCursor tschar))
                                  (Ssequence
                                    (Sset _t'15
                                      (Ederef
                                        (Ebinop Oadd
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _gDebugInfo (tarray (tarray tshort 8) 0))
                                              (Etempvar _t'13 tschar)
                                              (tptr (tarray tshort 8)))
                                            (tarray tshort 8))
                                          (Etempvar _t'14 tschar)
                                          (tptr tshort)) tshort))
                                    (Sassign
                                      (Ederef
                                        (Ebinop Oadd
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _gDebugInfo (tarray (tarray tshort 8) 0))
                                              (Etempvar _t'11 tschar)
                                              (tptr (tarray tshort 8)))
                                            (tarray tshort 8))
                                          (Etempvar _t'12 tschar)
                                          (tptr tshort)) tshort)
                                      (Ebinop Osub (Etempvar _t'15 tshort)
                                        (Etempvar _sp4 tint) tint))))))))))
                    Sskip))
                (Ssequence
                  (Sset _t'2 (Evar _sDebugInfoDPadMask tint))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'2 tint)
                                 (Econst_int (Int.repr 256) tint) tint)
                    (Ssequence
                      (Sset _t'3 (Evar _sDebugPage tschar))
                      (Ssequence
                        (Sset _t'4 (Evar _sDebugSysCursor tschar))
                        (Ssequence
                          (Sset _t'5 (Evar _sDebugPage tschar))
                          (Ssequence
                            (Sset _t'6 (Evar _sDebugSysCursor tschar))
                            (Ssequence
                              (Sset _t'7
                                (Ederef
                                  (Ebinop Oadd
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _gDebugInfo (tarray (tarray tshort 8) 0))
                                        (Etempvar _t'5 tschar)
                                        (tptr (tarray tshort 8)))
                                      (tarray tshort 8))
                                    (Etempvar _t'6 tschar) (tptr tshort))
                                  tshort))
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _gDebugInfo (tarray (tarray tshort 8) 0))
                                        (Etempvar _t'3 tschar)
                                        (tptr (tarray tshort 8)))
                                      (tarray tshort 8))
                                    (Etempvar _t'4 tschar) (tptr tshort))
                                  tshort)
                                (Ebinop Oadd (Etempvar _t'7 tshort)
                                  (Etempvar _sp4 tint) tint)))))))
                    Sskip)))))))
      Sskip)))
|}.

Definition f_stub_debug_5 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
Sskip
|}.

Definition f_try_print_debug_mario_object_info := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'7, tschar) :: (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, tuint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6 (Evar _gMarioObject (tptr (Tstruct _Object noattr))))
    (Sifthenelse (Ebinop One (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Sset _t'7 (Evar _sDebugPage tschar))
        (Sswitch (Etempvar _t'7 tschar)
          (LScons (Some 1)
            (Ssequence
              (Scall None
                (Evar _print_surfaceinfo (Tfunction nil tvoid cc_default))
                nil)
              Sbreak)
            (LScons (Some 4)
              (Ssequence
                (Scall None
                  (Evar _print_effectinfo (Tfunction nil tvoid cc_default))
                  nil)
                Sbreak)
              (LScons (Some 5)
                (Ssequence
                  (Scall None
                    (Evar _print_enemyinfo (Tfunction nil tvoid cc_default))
                    nil)
                  Sbreak)
                (LScons None Sbreak LSnil))))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'5 (Evar _gObjectCounter tuint))
      (Scall None
        (Evar _print_debug_top_down_mapinfo (Tfunction
                                              ((tptr tuchar) :: tint :: nil)
                                              tvoid cc_default))
        ((Evar ___stringlit_36 (tarray tuchar 8)) :: (Etempvar _t'5 tuint) ::
         nil)))
    (Ssequence
      (Ssequence
        (Sset _t'3 (Evar _gNumFindFloorMisses tint))
        (Sifthenelse (Ebinop One (Etempvar _t'3 tint)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Sset _t'4 (Evar _gNumFindFloorMisses tint))
            (Scall None
              (Evar _print_debug_bottom_up (Tfunction
                                             ((tptr tuchar) :: tint :: nil)
                                             tvoid cc_default))
              ((Evar ___stringlit_37 (tarray tuchar 10)) ::
               (Etempvar _t'4 tint) :: nil)))
          Sskip))
      (Ssequence
        (Sset _t'1 (Evar _gUnknownWallCount tint))
        (Sifthenelse (Ebinop One (Etempvar _t'1 tint)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Sset _t'2 (Evar _gUnknownWallCount tint))
            (Scall None
              (Evar _print_debug_bottom_up (Tfunction
                                             ((tptr tuchar) :: tint :: nil)
                                             tvoid cc_default))
              ((Evar ___stringlit_38 (tarray tuchar 10)) ::
               (Etempvar _t'2 tint) :: nil)))
          Sskip)))))
|}.

Definition f_try_print_debug_mario_level_info := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tschar) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _sDebugPage tschar))
  (Sswitch (Etempvar _t'1 tschar)
    (LScons (Some 0)
      Sbreak
      (LScons (Some 1)
        (Ssequence
          (Scall None
            (Evar _print_checkinfo (Tfunction nil tvoid cc_default)) nil)
          Sbreak)
        (LScons (Some 2)
          (Ssequence
            (Scall None
              (Evar _print_mapinfo (Tfunction nil tvoid cc_default)) nil)
            Sbreak)
          (LScons (Some 3)
            (Ssequence
              (Scall None
                (Evar _print_stageinfo (Tfunction nil tvoid cc_default)) nil)
              Sbreak)
            (LScons None Sbreak LSnil)))))))
|}.

Definition f_try_do_mario_debug_object_spawn := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_filler, (tarray tuchar 4)) :: nil);
  fn_temps := ((_t'1, tint) :: (_t'12, tshort) :: (_t'11, tschar) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tushort) ::
               (_t'8, (tptr (Tstruct _Controller noattr))) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tushort) ::
               (_t'5, (tptr (Tstruct _Controller noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: (_t'3, tushort) ::
               (_t'2, (tptr (Tstruct _Controller noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'11 (Evar _sDebugPage tschar))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'11 tschar)
                   (Econst_int (Int.repr 3) tint) tint)
      (Ssequence
        (Sset _t'12
          (Ederef
            (Ebinop Oadd
              (Ederef
                (Ebinop Oadd (Evar _gDebugInfo (tarray (tarray tshort 8) 0))
                  (Econst_int (Int.repr 5) tint) (tptr (tarray tshort 8)))
                (tarray tshort 8)) (Econst_int (Int.repr 7) tint)
              (tptr tshort)) tshort))
        (Sset _t'1
          (Ecast
            (Ebinop Oeq (Etempvar _t'12 tshort)
              (Econst_int (Int.repr 1) tint) tint) tbool)))
      (Sset _t'1 (Econst_int (Int.repr 0) tint))))
  (Sifthenelse (Etempvar _t'1 tint)
    (Ssequence
      (Ssequence
        (Sset _t'8
          (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
        (Ssequence
          (Sset _t'9
            (Efield
              (Ederef (Etempvar _t'8 (tptr (Tstruct _Controller noattr)))
                (Tstruct _Controller noattr)) _buttonPressed tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'9 tushort)
                         (Econst_int (Int.repr 256) tint) tint)
            (Ssequence
              (Sset _t'10
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Scall None
                (Evar _spawn_object_relative (Tfunction
                                               (tshort :: tshort :: tshort ::
                                                tshort ::
                                                (tptr (Tstruct _Object noattr)) ::
                                                tint :: (tptr tuint) :: nil)
                                               (tptr (Tstruct _Object noattr))
                                               cc_default))
                ((Econst_int (Int.repr 0) tint) ::
                 (Econst_int (Int.repr 0) tint) ::
                 (Econst_int (Int.repr 100) tint) ::
                 (Econst_int (Int.repr 200) tint) ::
                 (Etempvar _t'10 (tptr (Tstruct _Object noattr))) ::
                 (Econst_int (Int.repr 190) tint) ::
                 (Evar _bhvKoopaShell (tarray tuint 0)) :: nil)))
            Sskip)))
      (Ssequence
        (Ssequence
          (Sset _t'5
            (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
          (Ssequence
            (Sset _t'6
              (Efield
                (Ederef (Etempvar _t'5 (tptr (Tstruct _Controller noattr)))
                  (Tstruct _Controller noattr)) _buttonPressed tushort))
            (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                           (Econst_int (Int.repr 512) tint) tint)
              (Ssequence
                (Sset _t'7
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                (Scall None
                  (Evar _spawn_object_relative (Tfunction
                                                 (tshort :: tshort ::
                                                  tshort :: tshort ::
                                                  (tptr (Tstruct _Object noattr)) ::
                                                  tint :: (tptr tuint) ::
                                                  nil)
                                                 (tptr (Tstruct _Object noattr))
                                                 cc_default))
                  ((Econst_int (Int.repr 0) tint) ::
                   (Econst_int (Int.repr 0) tint) ::
                   (Econst_int (Int.repr 100) tint) ::
                   (Econst_int (Int.repr 200) tint) ::
                   (Etempvar _t'7 (tptr (Tstruct _Object noattr))) ::
                   (Econst_int (Int.repr 130) tint) ::
                   (Evar _bhvJumpingBox (tarray tuint 0)) :: nil)))
              Sskip)))
        (Ssequence
          (Sset _t'2
            (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
          (Ssequence
            (Sset _t'3
              (Efield
                (Ederef (Etempvar _t'2 (tptr (Tstruct _Controller noattr)))
                  (Tstruct _Controller noattr)) _buttonPressed tushort))
            (Sifthenelse (Ebinop Oand (Etempvar _t'3 tushort)
                           (Econst_int (Int.repr 1024) tint) tint)
              (Ssequence
                (Sset _t'4
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                (Scall None
                  (Evar _spawn_object_relative (Tfunction
                                                 (tshort :: tshort ::
                                                  tshort :: tshort ::
                                                  (tptr (Tstruct _Object noattr)) ::
                                                  tint :: (tptr tuint) ::
                                                  nil)
                                                 (tptr (Tstruct _Object noattr))
                                                 cc_default))
                  ((Econst_int (Int.repr 0) tint) ::
                   (Econst_int (Int.repr 0) tint) ::
                   (Econst_int (Int.repr 100) tint) ::
                   (Econst_int (Int.repr 200) tint) ::
                   (Etempvar _t'4 (tptr (Tstruct _Object noattr))) ::
                   (Econst_int (Int.repr 190) tint) ::
                   (Evar _bhvKoopaShellUnderwater (tarray tuint 0)) :: nil)))
              Sskip)))))
    Sskip))
|}.

Definition f_debug_print_obj_move_flags := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'36, tuint) :: (_t'35, (tptr (Tstruct _Object noattr))) ::
               (_t'34, tuint) :: (_t'33, (tptr (Tstruct _Object noattr))) ::
               (_t'32, tuint) :: (_t'31, (tptr (Tstruct _Object noattr))) ::
               (_t'30, tuint) :: (_t'29, (tptr (Tstruct _Object noattr))) ::
               (_t'28, tuint) :: (_t'27, (tptr (Tstruct _Object noattr))) ::
               (_t'26, tuint) :: (_t'25, (tptr (Tstruct _Object noattr))) ::
               (_t'24, tuint) :: (_t'23, (tptr (Tstruct _Object noattr))) ::
               (_t'22, tuint) :: (_t'21, (tptr (Tstruct _Object noattr))) ::
               (_t'20, tuint) :: (_t'19, (tptr (Tstruct _Object noattr))) ::
               (_t'18, tuint) :: (_t'17, (tptr (Tstruct _Object noattr))) ::
               (_t'16, tuint) :: (_t'15, (tptr (Tstruct _Object noattr))) ::
               (_t'14, tuint) :: (_t'13, (tptr (Tstruct _Object noattr))) ::
               (_t'12, tuint) :: (_t'11, (tptr (Tstruct _Object noattr))) ::
               (_t'10, tuint) :: (_t'9, (tptr (Tstruct _Object noattr))) ::
               (_t'8, tuint) :: (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, tuint) :: (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, tuint) :: (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, tuint) :: (_t'1, (tptr (Tstruct _Object noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'33 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'34
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'33 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __727 noattr))
              _asU32 (tarray tuint 80)) (Econst_int (Int.repr 25) tint)
            (tptr tuint)) tuint))
      (Sifthenelse (Ebinop Oand (Etempvar _t'34 tuint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 0) tint) tint) tuint)
        (Ssequence
          (Sset _t'35 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'36
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _t'35 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __727 noattr)) _asU32 (tarray tuint 80))
                  (Econst_int (Int.repr 25) tint) (tptr tuint)) tuint))
            (Scall None
              (Evar _print_debug_top_down_objectinfo (Tfunction
                                                       ((tptr tuchar) ::
                                                        tint :: nil) tvoid
                                                       cc_default))
              ((Evar ___stringlit_39 (tarray tuchar 11)) ::
               (Etempvar _t'36 tuint) :: nil))))
        Sskip)))
  (Ssequence
    (Ssequence
      (Sset _t'29 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'30
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'29 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __727 noattr))
                _asU32 (tarray tuint 80)) (Econst_int (Int.repr 25) tint)
              (tptr tuint)) tuint))
        (Sifthenelse (Ebinop Oand (Etempvar _t'30 tuint)
                       (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 1) tint) tint) tuint)
          (Ssequence
            (Sset _t'31
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'32
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'31 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __727 noattr)) _asU32 (tarray tuint 80))
                    (Econst_int (Int.repr 25) tint) (tptr tuint)) tuint))
              (Scall None
                (Evar _print_debug_top_down_objectinfo (Tfunction
                                                         ((tptr tuchar) ::
                                                          tint :: nil) tvoid
                                                         cc_default))
                ((Evar ___stringlit_40 (tarray tuchar 11)) ::
                 (Etempvar _t'32 tuint) :: nil))))
          Sskip)))
    (Ssequence
      (Ssequence
        (Sset _t'25 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'26
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'25 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __727 noattr)) _asU32 (tarray tuint 80))
                (Econst_int (Int.repr 25) tint) (tptr tuint)) tuint))
          (Sifthenelse (Ebinop Oand (Etempvar _t'26 tuint)
                         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 2) tint) tint) tuint)
            (Ssequence
              (Sset _t'27
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'28
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'27 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __727 noattr)) _asU32 (tarray tuint 80))
                      (Econst_int (Int.repr 25) tint) (tptr tuint)) tuint))
                (Scall None
                  (Evar _print_debug_top_down_objectinfo (Tfunction
                                                           ((tptr tuchar) ::
                                                            tint :: nil)
                                                           tvoid cc_default))
                  ((Evar ___stringlit_41 (tarray tuchar 11)) ::
                   (Etempvar _t'28 tuint) :: nil))))
            Sskip)))
      (Ssequence
        (Ssequence
          (Sset _t'21 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'22
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _t'21 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __727 noattr)) _asU32 (tarray tuint 80))
                  (Econst_int (Int.repr 25) tint) (tptr tuint)) tuint))
            (Sifthenelse (Ebinop Oand (Etempvar _t'22 tuint)
                           (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                             (Econst_int (Int.repr 3) tint) tint) tuint)
              (Ssequence
                (Sset _t'23
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'24
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'23 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __727 noattr)) _asU32 (tarray tuint 80))
                        (Econst_int (Int.repr 25) tint) (tptr tuint)) tuint))
                  (Scall None
                    (Evar _print_debug_top_down_objectinfo (Tfunction
                                                             ((tptr tuchar) ::
                                                              tint :: nil)
                                                             tvoid
                                                             cc_default))
                    ((Evar ___stringlit_42 (tarray tuchar 11)) ::
                     (Etempvar _t'24 tuint) :: nil))))
              Sskip)))
        (Ssequence
          (Ssequence
            (Sset _t'17
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'18
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'17 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __727 noattr)) _asU32 (tarray tuint 80))
                    (Econst_int (Int.repr 25) tint) (tptr tuint)) tuint))
              (Sifthenelse (Ebinop Oand (Etempvar _t'18 tuint)
                             (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                               (Econst_int (Int.repr 4) tint) tint) tuint)
                (Ssequence
                  (Sset _t'19
                    (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sset _t'20
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'19 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __727 noattr)) _asU32
                            (tarray tuint 80))
                          (Econst_int (Int.repr 25) tint) (tptr tuint))
                        tuint))
                    (Scall None
                      (Evar _print_debug_top_down_objectinfo (Tfunction
                                                               ((tptr tuchar) ::
                                                                tint :: nil)
                                                               tvoid
                                                               cc_default))
                      ((Evar ___stringlit_43 (tarray tuchar 11)) ::
                       (Etempvar _t'20 tuint) :: nil))))
                Sskip)))
          (Ssequence
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
                          (Tunion __727 noattr)) _asU32 (tarray tuint 80))
                      (Econst_int (Int.repr 25) tint) (tptr tuint)) tuint))
                (Sifthenelse (Ebinop Oand (Etempvar _t'14 tuint)
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 5) tint) tint) tuint)
                  (Ssequence
                    (Sset _t'15
                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sset _t'16
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'15 (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _rawData
                                (Tunion __727 noattr)) _asU32
                              (tarray tuint 80))
                            (Econst_int (Int.repr 25) tint) (tptr tuint))
                          tuint))
                      (Scall None
                        (Evar _print_debug_top_down_objectinfo (Tfunction
                                                                 ((tptr tuchar) ::
                                                                  tint ::
                                                                  nil) tvoid
                                                                 cc_default))
                        ((Evar ___stringlit_44 (tarray tuchar 11)) ::
                         (Etempvar _t'16 tuint) :: nil))))
                  Sskip)))
            (Ssequence
              (Ssequence
                (Sset _t'9
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'10
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __727 noattr)) _asU32 (tarray tuint 80))
                        (Econst_int (Int.repr 25) tint) (tptr tuint)) tuint))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'10 tuint)
                                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                   (Econst_int (Int.repr 6) tint) tint)
                                 tuint)
                    (Ssequence
                      (Sset _t'11
                        (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                      (Ssequence
                        (Sset _t'12
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'11 (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __727 noattr)) _asU32
                                (tarray tuint 80))
                              (Econst_int (Int.repr 25) tint) (tptr tuint))
                            tuint))
                        (Scall None
                          (Evar _print_debug_top_down_objectinfo (Tfunction
                                                                   ((tptr tuchar) ::
                                                                    tint ::
                                                                    nil)
                                                                   tvoid
                                                                   cc_default))
                          ((Evar ___stringlit_45 (tarray tuchar 11)) ::
                           (Etempvar _t'12 tuint) :: nil))))
                    Sskip)))
              (Ssequence
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
                              (Tunion __727 noattr)) _asU32
                            (tarray tuint 80))
                          (Econst_int (Int.repr 25) tint) (tptr tuint))
                        tuint))
                    (Sifthenelse (Ebinop Oand (Etempvar _t'6 tuint)
                                   (Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 7) tint) tint)
                                   tuint)
                      (Ssequence
                        (Sset _t'7
                          (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                        (Ssequence
                          (Sset _t'8
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __727 noattr)) _asU32
                                  (tarray tuint 80))
                                (Econst_int (Int.repr 25) tint) (tptr tuint))
                              tuint))
                          (Scall None
                            (Evar _print_debug_top_down_objectinfo (Tfunction
                                                                    ((tptr tuchar) ::
                                                                    tint ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                            ((Evar ___stringlit_46 (tarray tuchar 11)) ::
                             (Etempvar _t'8 tuint) :: nil))))
                      Sskip)))
                (Ssequence
                  (Sset _t'1
                    (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sset _t'2
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __727 noattr)) _asU32
                            (tarray tuint 80))
                          (Econst_int (Int.repr 25) tint) (tptr tuint))
                        tuint))
                    (Sifthenelse (Ebinop Oand (Etempvar _t'2 tuint)
                                   (Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 8) tint) tint)
                                   tuint)
                      (Ssequence
                        (Sset _t'3
                          (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                        (Ssequence
                          (Sset _t'4
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __727 noattr)) _asU32
                                  (tarray tuint 80))
                                (Econst_int (Int.repr 25) tint) (tptr tuint))
                              tuint))
                          (Scall None
                            (Evar _print_debug_top_down_objectinfo (Tfunction
                                                                    ((tptr tuchar) ::
                                                                    tint ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                            ((Evar ___stringlit_47 (tarray tuchar 13)) ::
                             (Etempvar _t'4 tuint) :: nil))))
                      Sskip)))))))))))
|}.

Definition f_debug_enemy_unknown := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_enemyArr, (tptr tshort)) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tshort) :: (_t'3, tshort) :: (_t'2, tshort) ::
               (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4
      (Ederef
        (Ebinop Oadd
          (Ederef
            (Ebinop Oadd (Evar _gDebugInfo (tarray (tarray tshort 8) 0))
              (Econst_int (Int.repr 5) tint) (tptr (tarray tshort 8)))
            (tarray tshort 8)) (Econst_int (Int.repr 1) tint) (tptr tshort))
        tshort))
    (Sassign
      (Ederef
        (Ebinop Oadd (Etempvar _enemyArr (tptr tshort))
          (Econst_int (Int.repr 4) tint) (tptr tshort)) tshort)
      (Etempvar _t'4 tshort)))
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Ederef
          (Ebinop Oadd
            (Ederef
              (Ebinop Oadd (Evar _gDebugInfo (tarray (tarray tshort 8) 0))
                (Econst_int (Int.repr 5) tint) (tptr (tarray tshort 8)))
              (tarray tshort 8)) (Econst_int (Int.repr 2) tint)
            (tptr tshort)) tshort))
      (Sassign
        (Ederef
          (Ebinop Oadd (Etempvar _enemyArr (tptr tshort))
            (Econst_int (Int.repr 5) tint) (tptr tshort)) tshort)
        (Etempvar _t'3 tshort)))
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Ederef
            (Ebinop Oadd
              (Ederef
                (Ebinop Oadd (Evar _gDebugInfo (tarray (tarray tshort 8) 0))
                  (Econst_int (Int.repr 5) tint) (tptr (tarray tshort 8)))
                (tarray tshort 8)) (Econst_int (Int.repr 3) tint)
              (tptr tshort)) tshort))
        (Sassign
          (Ederef
            (Ebinop Oadd (Etempvar _enemyArr (tptr tshort))
              (Econst_int (Int.repr 6) tint) (tptr tshort)) tshort)
          (Etempvar _t'2 tshort)))
      (Ssequence
        (Sset _t'1
          (Ederef
            (Ebinop Oadd
              (Ederef
                (Ebinop Oadd (Evar _gDebugInfo (tarray (tarray tshort 8) 0))
                  (Econst_int (Int.repr 5) tint) (tptr (tarray tshort 8)))
                (tarray tshort 8)) (Econst_int (Int.repr 4) tint)
              (tptr tshort)) tshort))
        (Sassign
          (Ederef
            (Ebinop Oadd (Etempvar _enemyArr (tptr tshort))
              (Econst_int (Int.repr 7) tint) (tptr tshort)) tshort)
          (Etempvar _t'1 tshort))))))
|}.

Definition composites : list composite_definition :=
(Composite __317 Struct
   (Member_plain _type tushort :: Member_plain _status tuchar ::
    Member_plain _errnum tuchar :: nil)
   noattr ::
 Composite __319 Struct
   (Member_plain _button tushort :: Member_plain _stick_x tschar ::
    Member_plain _stick_y tschar :: Member_plain _errnum tuchar :: nil)
   noattr ::
 Composite _Controller Struct
   (Member_plain _rawStickX tshort :: Member_plain _rawStickY tshort ::
    Member_plain _stickX tfloat :: Member_plain _stickY tfloat ::
    Member_plain _stickMag tfloat :: Member_plain _buttonDown tushort ::
    Member_plain _buttonPressed tushort ::
    Member_plain _statusData (tptr (Tstruct __317 noattr)) ::
    Member_plain _controllerData (tptr (Tstruct __319 noattr)) :: nil)
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
 Composite __727 Union
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
    Member_plain _rawData (Tunion __727 noattr) ::
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
 Composite __732 Struct
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
    Member_plain _normal (Tstruct __732 noattr) ::
    Member_plain _originOffset tfloat ::
    Member_plain _object (tptr (Tstruct _Object noattr)) :: nil)
   noattr ::
 Composite _ChainSegment Struct
   (Member_plain _posX tfloat :: Member_plain _posY tfloat ::
    Member_plain _posZ tfloat :: Member_plain _pitch tshort ::
    Member_plain _yaw tshort :: Member_plain _roll tshort :: nil)
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
 Composite _NumTimesCalled Struct
   (Member_plain _floor tshort :: Member_plain _ceil tshort ::
    Member_plain _wall tshort :: nil)
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
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xptr
                     cc_default)) ((tptr tvoid) :: tuint :: nil) (tptr tvoid)
     cc_default)) ::
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
     cc_default)) :: (___stringlit_40, Gvar v___stringlit_40) ::
 (___stringlit_10, Gvar v___stringlit_10) ::
 (___stringlit_19, Gvar v___stringlit_19) ::
 (___stringlit_27, Gvar v___stringlit_27) ::
 (___stringlit_46, Gvar v___stringlit_46) ::
 (___stringlit_7, Gvar v___stringlit_7) ::
 (___stringlit_15, Gvar v___stringlit_15) ::
 (___stringlit_26, Gvar v___stringlit_26) ::
 (___stringlit_41, Gvar v___stringlit_41) ::
 (___stringlit_2, Gvar v___stringlit_2) ::
 (___stringlit_28, Gvar v___stringlit_28) ::
 (___stringlit_45, Gvar v___stringlit_45) ::
 (___stringlit_22, Gvar v___stringlit_22) ::
 (___stringlit_35, Gvar v___stringlit_35) ::
 (___stringlit_43, Gvar v___stringlit_43) ::
 (___stringlit_11, Gvar v___stringlit_11) ::
 (___stringlit_33, Gvar v___stringlit_33) ::
 (___stringlit_8, Gvar v___stringlit_8) ::
 (___stringlit_29, Gvar v___stringlit_29) ::
 (___stringlit_44, Gvar v___stringlit_44) ::
 (___stringlit_5, Gvar v___stringlit_5) ::
 (___stringlit_30, Gvar v___stringlit_30) ::
 (___stringlit_4, Gvar v___stringlit_4) ::
 (___stringlit_34, Gvar v___stringlit_34) ::
 (___stringlit_31, Gvar v___stringlit_31) ::
 (___stringlit_38, Gvar v___stringlit_38) ::
 (___stringlit_1, Gvar v___stringlit_1) ::
 (___stringlit_17, Gvar v___stringlit_17) ::
 (___stringlit_18, Gvar v___stringlit_18) ::
 (___stringlit_20, Gvar v___stringlit_20) ::
 (___stringlit_24, Gvar v___stringlit_24) ::
 (___stringlit_13, Gvar v___stringlit_13) ::
 (___stringlit_23, Gvar v___stringlit_23) ::
 (___stringlit_25, Gvar v___stringlit_25) ::
 (___stringlit_12, Gvar v___stringlit_12) ::
 (___stringlit_9, Gvar v___stringlit_9) ::
 (___stringlit_14, Gvar v___stringlit_14) ::
 (___stringlit_16, Gvar v___stringlit_16) ::
 (___stringlit_32, Gvar v___stringlit_32) ::
 (___stringlit_36, Gvar v___stringlit_36) ::
 (___stringlit_37, Gvar v___stringlit_37) ::
 (___stringlit_47, Gvar v___stringlit_47) ::
 (___stringlit_6, Gvar v___stringlit_6) ::
 (___stringlit_39, Gvar v___stringlit_39) ::
 (___stringlit_3, Gvar v___stringlit_3) ::
 (___stringlit_21, Gvar v___stringlit_21) ::
 (___stringlit_42, Gvar v___stringlit_42) ::
 (___builtin_ais_annot,
   Gfun(External (EF_builtin "__builtin_ais_annot"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid
                     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|}))
     ((tptr tuchar) :: nil) tvoid
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
                   (mksignature (AST.Xint :: nil) AST.Xint cc_default))
     (tuint :: nil) tint cc_default)) ::
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
                   (mksignature (AST.Xint :: nil) AST.Xint cc_default))
     (tuint :: nil) tint cc_default)) ::
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
                     (AST.Xptr :: AST.Xptr :: AST.Xint :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     ((tptr tvoid) :: (tptr tvoid) :: tuint :: tuint :: nil) tvoid
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
     ((tptr tuchar) :: nil) tvoid
     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|})) ::
 (___builtin_annot_intval,
   Gfun(External (EF_builtin "__builtin_annot_intval"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xint
                     cc_default)) ((tptr tuchar) :: tint :: nil) tint
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
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xint
                     cc_default)) (tint :: tint :: nil) tint cc_default)) ::
 (___builtin_mulhw,
   Gfun(External (EF_builtin "__builtin_mulhw"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xint
                     cc_default)) (tint :: tint :: nil) tint cc_default)) ::
 (___builtin_mulhwu,
   Gfun(External (EF_builtin "__builtin_mulhwu"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xint
                     cc_default)) (tuint :: tuint :: nil) tuint cc_default)) ::
 (___builtin_cmpb,
   Gfun(External (EF_builtin "__builtin_cmpb"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xint
                     cc_default)) (tuint :: tuint :: nil) tuint cc_default)) ::
 (___builtin_mulhd,
   Gfun(External (EF_builtin "__builtin_mulhd"
                   (mksignature (AST.Xlong :: AST.Xlong :: nil) AST.Xlong
                     cc_default)) (tlong :: tlong :: nil) tlong cc_default)) ::
 (___builtin_mulhdu,
   Gfun(External (EF_builtin "__builtin_mulhdu"
                   (mksignature (AST.Xlong :: AST.Xlong :: nil) AST.Xlong
                     cc_default)) (tulong :: tulong :: nil) tulong
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
 (___builtin_frsqrte,
   Gfun(External (EF_builtin "__builtin_frsqrte"
                   (mksignature (AST.Xfloat :: nil) AST.Xfloat cc_default))
     (tdouble :: nil) tdouble cc_default)) ::
 (___builtin_fres,
   Gfun(External (EF_builtin "__builtin_fres"
                   (mksignature (AST.Xsingle :: nil) AST.Xsingle cc_default))
     (tfloat :: nil) tfloat cc_default)) ::
 (___builtin_fsel,
   Gfun(External (EF_builtin "__builtin_fsel"
                   (mksignature
                     (AST.Xfloat :: AST.Xfloat :: AST.Xfloat :: nil)
                     AST.Xfloat cc_default))
     (tdouble :: tdouble :: tdouble :: nil) tdouble cc_default)) ::
 (___builtin_fcti,
   Gfun(External (EF_builtin "__builtin_fcti"
                   (mksignature (AST.Xfloat :: nil) AST.Xint cc_default))
     (tdouble :: nil) tint cc_default)) ::
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
 (___builtin_read64_reversed,
   Gfun(External (EF_builtin "__builtin_read64_reversed"
                   (mksignature (AST.Xptr :: nil) AST.Xlong cc_default))
     ((tptr tulong) :: nil) tulong cc_default)) ::
 (___builtin_write64_reversed,
   Gfun(External (EF_builtin "__builtin_write64_reversed"
                   (mksignature (AST.Xptr :: AST.Xlong :: nil) AST.Xvoid
                     cc_default)) ((tptr tulong) :: tulong :: nil) tvoid
     cc_default)) ::
 (___builtin_eieio,
   Gfun(External (EF_builtin "__builtin_eieio"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (___builtin_sync,
   Gfun(External (EF_builtin "__builtin_sync"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (___builtin_isync,
   Gfun(External (EF_builtin "__builtin_isync"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (___builtin_lwsync,
   Gfun(External (EF_builtin "__builtin_lwsync"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (___builtin_mbar,
   Gfun(External (EF_builtin "__builtin_mbar"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tint :: nil) tvoid cc_default)) ::
 (___builtin_trap,
   Gfun(External (EF_builtin "__builtin_trap"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (___builtin_dcbf,
   Gfun(External (EF_builtin "__builtin_dcbf"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr tvoid) :: nil) tvoid cc_default)) ::
 (___builtin_dcbi,
   Gfun(External (EF_builtin "__builtin_dcbi"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr tvoid) :: nil) tvoid cc_default)) ::
 (___builtin_icbi,
   Gfun(External (EF_builtin "__builtin_icbi"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr tvoid) :: nil) tvoid cc_default)) ::
 (___builtin_prefetch,
   Gfun(External (EF_builtin "__builtin_prefetch"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     ((tptr tvoid) :: tint :: tint :: nil) tvoid cc_default)) ::
 (___builtin_dcbtls,
   Gfun(External (EF_builtin "__builtin_dcbtls"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default)) ((tptr tvoid) :: tint :: nil) tvoid
     cc_default)) ::
 (___builtin_icbtls,
   Gfun(External (EF_builtin "__builtin_icbtls"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default)) ((tptr tvoid) :: tint :: nil) tvoid
     cc_default)) ::
 (___builtin_dcbz,
   Gfun(External (EF_builtin "__builtin_dcbz"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr tvoid) :: nil) tvoid cc_default)) ::
 (___builtin_get_spr,
   Gfun(External (EF_builtin "__builtin_get_spr"
                   (mksignature (AST.Xint :: nil) AST.Xint cc_default))
     (tint :: nil) tuint cc_default)) ::
 (___builtin_set_spr,
   Gfun(External (EF_builtin "__builtin_set_spr"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xvoid
                     cc_default)) (tint :: tuint :: nil) tvoid cc_default)) ::
 (___builtin_get_spr64,
   Gfun(External (EF_builtin "__builtin_get_spr64"
                   (mksignature (AST.Xint :: nil) AST.Xlong cc_default))
     (tint :: nil) tulong cc_default)) ::
 (___builtin_set_spr64,
   Gfun(External (EF_builtin "__builtin_set_spr64"
                   (mksignature (AST.Xint :: AST.Xlong :: nil) AST.Xvoid
                     cc_default)) (tint :: tulong :: nil) tvoid cc_default)) ::
 (___builtin_mr,
   Gfun(External (EF_builtin "__builtin_mr"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xvoid
                     cc_default)) (tint :: tint :: nil) tvoid cc_default)) ::
 (___builtin_call_frame,
   Gfun(External (EF_builtin "__builtin_call_frame"
                   (mksignature nil AST.Xptr cc_default)) nil (tptr tvoid)
     cc_default)) ::
 (___builtin_return_address,
   Gfun(External (EF_builtin "__builtin_return_address"
                   (mksignature nil AST.Xptr cc_default)) nil (tptr tvoid)
     cc_default)) ::
 (___builtin_isel,
   Gfun(External (EF_builtin "__builtin_isel"
                   (mksignature (AST.Xbool :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint cc_default)) (tbool :: tint :: tint :: nil)
     tint cc_default)) ::
 (___builtin_uisel,
   Gfun(External (EF_builtin "__builtin_uisel"
                   (mksignature (AST.Xbool :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint cc_default)) (tbool :: tuint :: tuint :: nil)
     tuint cc_default)) ::
 (___builtin_isel64,
   Gfun(External (EF_builtin "__builtin_isel64"
                   (mksignature (AST.Xbool :: AST.Xlong :: AST.Xlong :: nil)
                     AST.Xlong cc_default)) (tbool :: tlong :: tlong :: nil)
     tlong cc_default)) ::
 (___builtin_uisel64,
   Gfun(External (EF_builtin "__builtin_uisel64"
                   (mksignature (AST.Xbool :: AST.Xlong :: AST.Xlong :: nil)
                     AST.Xlong cc_default))
     (tbool :: tulong :: tulong :: nil) tulong cc_default)) ::
 (___builtin_bsel,
   Gfun(External (EF_builtin "__builtin_bsel"
                   (mksignature (AST.Xbool :: AST.Xbool :: AST.Xbool :: nil)
                     AST.Xbool cc_default)) (tbool :: tbool :: tbool :: nil)
     tbool cc_default)) ::
 (___builtin_nop,
   Gfun(External (EF_builtin "__builtin_nop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (___builtin_atomic_exchange,
   Gfun(External (EF_builtin "__builtin_atomic_exchange"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xvoid cc_default))
     ((tptr tint) :: (tptr tint) :: (tptr tint) :: nil) tvoid cc_default)) ::
 (___builtin_atomic_load,
   Gfun(External (EF_builtin "__builtin_atomic_load"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xvoid
                     cc_default)) ((tptr tint) :: (tptr tint) :: nil) tvoid
     cc_default)) ::
 (___builtin_atomic_compare_exchange,
   Gfun(External (EF_builtin "__builtin_atomic_compare_exchange"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xbool cc_default))
     ((tptr tint) :: (tptr tint) :: (tptr tint) :: nil) tbool cc_default)) ::
 (___builtin_sync_fetch_and_add,
   Gfun(External (EF_builtin "__builtin_sync_fetch_and_add"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xint
                     cc_default)) ((tptr tint) :: tint :: nil) tint
     cc_default)) ::
 (___builtin_debug,
   Gfun(External (EF_external "__builtin_debug"
                   (mksignature (AST.Xint :: nil) AST.Xvoid
                     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|}))
     (tint :: nil) tvoid
     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|})) ::
 (_bhvKoopaShellUnderwater, Gvar v_bhvKoopaShellUnderwater) ::
 (_bhvJumpingBox, Gvar v_bhvJumpingBox) ::
 (_bhvKoopaShell, Gvar v_bhvKoopaShell) ::
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
 (_debug_surface_list_info,
   Gfun(External (EF_external "debug_surface_list_info"
                   (mksignature (AST.Xsingle :: AST.Xsingle :: nil) AST.Xvoid
                     cc_default)) (tfloat :: tfloat :: nil) tvoid
     cc_default)) :: (_gPlayer1Controller, Gvar v_gPlayer1Controller) ::
 (_gDebugLevelSelect, Gvar v_gDebugLevelSelect) ::
 (_spawn_object_relative,
   Gfun(External (EF_external "spawn_object_relative"
                   (mksignature
                     (AST.Xint16signed :: AST.Xint16signed ::
                      AST.Xint16signed :: AST.Xint16signed :: AST.Xptr ::
                      AST.Xint :: AST.Xptr :: nil) AST.Xptr cc_default))
     (tshort :: tshort :: tshort :: tshort ::
      (tptr (Tstruct _Object noattr)) :: tint :: (tptr tuint) :: nil)
     (tptr (Tstruct _Object noattr)) cc_default)) ::
 (_gDebugInfoFlags, Gvar v_gDebugInfoFlags) ::
 (_gNumFindFloorMisses, Gvar v_gNumFindFloorMisses) ::
 (_gUnknownWallCount, Gvar v_gUnknownWallCount) ::
 (_gObjectCounter, Gvar v_gObjectCounter) ::
 (_gNumCalls, Gvar v_gNumCalls) :: (_gDebugInfo, Gvar v_gDebugInfo) ::
 (_gDebugInfoOverwrite, Gvar v_gDebugInfoOverwrite) ::
 (_gMarioObject, Gvar v_gMarioObject) ::
 (_gCurrentObject, Gvar v_gCurrentObject) ::
 (_D_8035FEE2, Gvar v_D_8035FEE2) :: (_D_8035FEE4, Gvar v_D_8035FEE4) ::
 (_gTTCSpeedSetting, Gvar v_gTTCSpeedSetting) ::
 (_print_text_fmt_int,
   Gfun(External (EF_external "print_text_fmt_int"
                   (mksignature
                     (AST.Xint :: AST.Xint :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     (tint :: tint :: (tptr tuchar) :: tint :: nil) tvoid cc_default)) ::
 (_print_text,
   Gfun(External (EF_external "print_text"
                   (mksignature (AST.Xint :: AST.Xint :: AST.Xptr :: nil)
                     AST.Xvoid cc_default))
     (tint :: tint :: (tptr tuchar) :: nil) tvoid cc_default)) ::
 (_gDebugPrintState1, Gvar v_gDebugPrintState1) ::
 (_gDebugPrintState2, Gvar v_gDebugPrintState2) ::
 (_sDebugEffectStringInfo, Gvar v_sDebugEffectStringInfo) ::
 (_sDebugEnemyStringInfo, Gvar v_sDebugEnemyStringInfo) ::
 (_sDebugInfoDPadMask, Gvar v_sDebugInfoDPadMask) ::
 (_sDebugInfoDPadUpdID, Gvar v_sDebugInfoDPadUpdID) ::
 (_sDebugLvSelectCheckFlag, Gvar v_sDebugLvSelectCheckFlag) ::
 (_sDebugPage, Gvar v_sDebugPage) ::
 (_sNoExtraDebug, Gvar v_sNoExtraDebug) ::
 (_sDebugStringArrPrinted, Gvar v_sDebugStringArrPrinted) ::
 (_sDebugSysCursor, Gvar v_sDebugSysCursor) ::
 (_sDebugInfoButtonSeqID, Gvar v_sDebugInfoButtonSeqID) ::
 (_sDebugInfoButtonSeq, Gvar v_sDebugInfoButtonSeq) ::
 (_stub_debug_1, Gfun(Internal f_stub_debug_1)) ::
 (_stub_debug_2, Gfun(Internal f_stub_debug_2)) ::
 (_stub_debug_3, Gfun(Internal f_stub_debug_3)) ::
 (_stub_debug_4, Gfun(Internal f_stub_debug_4)) ::
 (_get_current_clock, Gfun(Internal f_get_current_clock)) ::
 (_get_clock_difference, Gfun(Internal f_get_clock_difference)) ::
 (_set_print_state_info, Gfun(Internal f_set_print_state_info)) ::
 (_print_text_array_info, Gfun(Internal f_print_text_array_info)) ::
 (_set_text_array_x_y, Gfun(Internal f_set_text_array_x_y)) ::
 (_print_debug_bottom_up, Gfun(Internal f_print_debug_bottom_up)) ::
 (_print_debug_top_down_objectinfo, Gfun(Internal f_print_debug_top_down_objectinfo)) ::
 (_print_debug_top_down_mapinfo, Gfun(Internal f_print_debug_top_down_mapinfo)) ::
 (_print_debug_top_down_normal, Gfun(Internal f_print_debug_top_down_normal)) ::
 (_print_mapinfo, Gfun(Internal f_print_mapinfo)) ::
 (_print_checkinfo, Gfun(Internal f_print_checkinfo)) ::
 (_print_surfaceinfo, Gfun(Internal f_print_surfaceinfo)) ::
 (_print_stageinfo, Gfun(Internal f_print_stageinfo)) ::
 (_print_string_array_info, Gfun(Internal f_print_string_array_info)) ::
 (_print_effectinfo, Gfun(Internal f_print_effectinfo)) ::
 (_print_enemyinfo, Gfun(Internal f_print_enemyinfo)) ::
 (_update_debug_dpadmask, Gfun(Internal f_update_debug_dpadmask)) ::
 (_debug_unknown_level_select_check, Gfun(Internal f_debug_unknown_level_select_check)) ::
 (_reset_debug_objectinfo, Gfun(Internal f_reset_debug_objectinfo)) ::
 (_try_modify_debug_controls, Gfun(Internal f_try_modify_debug_controls)) ::
 (_stub_debug_5, Gfun(Internal f_stub_debug_5)) ::
 (_try_print_debug_mario_object_info, Gfun(Internal f_try_print_debug_mario_object_info)) ::
 (_try_print_debug_mario_level_info, Gfun(Internal f_try_print_debug_mario_level_info)) ::
 (_try_do_mario_debug_object_spawn, Gfun(Internal f_try_do_mario_debug_object_spawn)) ::
 (_debug_print_obj_move_flags, Gfun(Internal f_debug_print_obj_move_flags)) ::
 (_debug_enemy_unknown, Gfun(Internal f_debug_enemy_unknown)) :: nil).

Definition public_idents : list ident :=
(_debug_enemy_unknown :: _debug_print_obj_move_flags ::
 _try_do_mario_debug_object_spawn :: _try_print_debug_mario_level_info ::
 _try_print_debug_mario_object_info :: _stub_debug_5 ::
 _try_modify_debug_controls :: _reset_debug_objectinfo ::
 _debug_unknown_level_select_check :: _update_debug_dpadmask ::
 _print_enemyinfo :: _print_effectinfo :: _print_string_array_info ::
 _print_stageinfo :: _print_surfaceinfo :: _print_checkinfo ::
 _print_mapinfo :: _print_debug_top_down_normal ::
 _print_debug_top_down_mapinfo :: _print_debug_top_down_objectinfo ::
 _print_debug_bottom_up :: _set_text_array_x_y :: _print_text_array_info ::
 _set_print_state_info :: _get_clock_difference :: _get_current_clock ::
 _stub_debug_4 :: _stub_debug_3 :: _stub_debug_2 :: _stub_debug_1 ::
 _sDebugInfoButtonSeq :: _sDebugInfoButtonSeqID :: _sDebugSysCursor ::
 _sDebugStringArrPrinted :: _sNoExtraDebug :: _sDebugPage ::
 _sDebugLvSelectCheckFlag :: _sDebugInfoDPadUpdID :: _sDebugInfoDPadMask ::
 _sDebugEnemyStringInfo :: _sDebugEffectStringInfo :: _gDebugPrintState2 ::
 _gDebugPrintState1 :: _print_text :: _print_text_fmt_int ::
 _gTTCSpeedSetting :: _D_8035FEE4 :: _D_8035FEE2 :: _gCurrentObject ::
 _gMarioObject :: _gDebugInfoOverwrite :: _gDebugInfo :: _gNumCalls ::
 _gObjectCounter :: _gUnknownWallCount :: _gNumFindFloorMisses ::
 _gDebugInfoFlags :: _spawn_object_relative :: _gDebugLevelSelect ::
 _gPlayer1Controller :: _debug_surface_list_info :: _find_water_level ::
 _find_floor :: _bhvKoopaShell :: _bhvJumpingBox ::
 _bhvKoopaShellUnderwater :: ___builtin_debug ::
 ___builtin_sync_fetch_and_add :: ___builtin_atomic_compare_exchange ::
 ___builtin_atomic_load :: ___builtin_atomic_exchange :: ___builtin_nop ::
 ___builtin_bsel :: ___builtin_uisel64 :: ___builtin_isel64 ::
 ___builtin_uisel :: ___builtin_isel :: ___builtin_return_address ::
 ___builtin_call_frame :: ___builtin_mr :: ___builtin_set_spr64 ::
 ___builtin_get_spr64 :: ___builtin_set_spr :: ___builtin_get_spr ::
 ___builtin_dcbz :: ___builtin_icbtls :: ___builtin_dcbtls ::
 ___builtin_prefetch :: ___builtin_icbi :: ___builtin_dcbi ::
 ___builtin_dcbf :: ___builtin_trap :: ___builtin_mbar ::
 ___builtin_lwsync :: ___builtin_isync :: ___builtin_sync ::
 ___builtin_eieio :: ___builtin_write64_reversed ::
 ___builtin_read64_reversed :: ___builtin_write32_reversed ::
 ___builtin_write16_reversed :: ___builtin_read32_reversed ::
 ___builtin_read16_reversed :: ___builtin_fcti :: ___builtin_fsel ::
 ___builtin_fres :: ___builtin_frsqrte :: ___builtin_fnmsub ::
 ___builtin_fnmadd :: ___builtin_fmsub :: ___builtin_fmadd ::
 ___builtin_mulhdu :: ___builtin_mulhd :: ___builtin_cmpb ::
 ___builtin_mulhwu :: ___builtin_mulhw :: ___builtin_expect ::
 ___builtin_unreachable :: ___builtin_va_end :: ___builtin_va_copy ::
 ___builtin_va_arg :: ___builtin_va_start :: ___builtin_membar ::
 ___builtin_annot_intval :: ___builtin_annot :: ___builtin_sel ::
 ___builtin_memcpy_aligned :: ___builtin_sqrt :: ___builtin_fsqrt ::
 ___builtin_fabsf :: ___builtin_fabs :: ___builtin_ctzll ::
 ___builtin_ctzl :: ___builtin_ctz :: ___builtin_clzll :: ___builtin_clzl ::
 ___builtin_clz :: ___builtin_bswap16 :: ___builtin_bswap32 ::
 ___builtin_bswap :: ___builtin_bswap64 :: ___builtin_ais_annot ::
 ___compcert_i64_umulh :: ___compcert_i64_smulh :: ___compcert_i64_sar ::
 ___compcert_i64_shr :: ___compcert_i64_shl :: ___compcert_i64_umod ::
 ___compcert_i64_smod :: ___compcert_i64_udiv :: ___compcert_i64_sdiv ::
 ___compcert_i64_utof :: ___compcert_i64_stof :: ___compcert_i64_utod ::
 ___compcert_i64_stod :: ___compcert_i64_dtou :: ___compcert_i64_dtos ::
 ___compcert_va_composite :: ___compcert_va_float64 ::
 ___compcert_va_int64 :: ___compcert_va_int32 :: nil).

Definition prog : Clight.program := 
  mkprogram composites global_definitions public_idents _main Logic.I.


