(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_US
   Source:          src/menu/star_select.c
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -I/mnt/c/Users/tariq/OneDrive/Documents/sm64 - the item-grab proof/reference-sm64-wmotr-abc-proof/Demo-Coq/build/text-us -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1
   Link hygiene:    private __stringlit_N atoms prefixed with us_star_select
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
  Definition source_file := "build/pinned-sm64/src/menu/star_select.c".
  Definition normalized := true.
End Info.

Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _Controller : ident := $"Controller".
Definition _GraphNode : ident := $"GraphNode".
Definition _GraphNodeObject : ident := $"GraphNodeObject".
Definition _Object : ident := $"Object".
Definition _ObjectNode : ident := $"ObjectNode".
Definition _SpawnInfo : ident := $"SpawnInfo".
Definition _Surface : ident := $"Surface".
Definition _Waypoint : ident := $"Waypoint".
Definition __317 : ident := $"_317".
Definition __319 : ident := $"_319".
Definition __469 : ident := $"_469".
Definition __510 : ident := $"_510".
Definition __512 : ident := $"_512".
Definition __514 : ident := $"_514".
Definition __516 : ident := $"_516".
Definition __518 : ident := $"_518".
Definition __520 : ident := $"_520".
Definition __522 : ident := $"_522".
Definition __524 : ident := $"_524".
Definition __526 : ident := $"_526".
Definition __528 : ident := $"_528".
Definition __530 : ident := $"_530".
Definition __532 : ident := $"_532".
Definition __534 : ident := $"_534".
Definition __536 : ident := $"_536".
Definition __538 : ident := $"_538".
Definition __547 : ident := $"_547".
Definition __549 : ident := $"_549".
Definition __764 : ident := $"_764".
Definition __769 : ident := $"_769".
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
Definition __g : ident := $"_g".
Definition __g__1 : ident := $"_g__1".
Definition __g__2 : ident := $"_g__2".
Definition __g__3 : ident := $"_g__3".
Definition __g__4 : ident := $"_g__4".
Definition __g__5 : ident := $"_g__5".
Definition __g__6 : ident := $"_g__6".
Definition __g__7 : ident := $"_g__7".
Definition __g__8 : ident := $"_g__8".
Definition _actNameTbl : ident := $"actNameTbl".
Definition _actNameX : ident := $"actNameX".
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _addr : ident := $"addr".
Definition _angle : ident := $"angle".
Definition _animAccel : ident := $"animAccel".
Definition _animFrame : ident := $"animFrame".
Definition _animFrameAccelAssist : ident := $"animFrameAccelAssist".
Definition _animID : ident := $"animID".
Definition _animInfo : ident := $"animInfo".
Definition _animTimer : ident := $"animTimer".
Definition _animYTrans : ident := $"animYTrans".
Definition _animYTransDivisor : ident := $"animYTransDivisor".
Definition _areaIndex : ident := $"areaIndex".
Definition _area_update_objects : ident := $"area_update_objects".
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
Definition _base : ident := $"base".
Definition _behavior : ident := $"behavior".
Definition _behaviorArg : ident := $"behaviorArg".
Definition _behaviorScript : ident := $"behaviorScript".
Definition _bhvActSelectorStarType : ident := $"bhvActSelectorStarType".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _bhv_act_selector_init : ident := $"bhv_act_selector_init".
Definition _bhv_act_selector_loop : ident := $"bhv_act_selector_loop".
Definition _bhv_act_selector_star_type_loop : ident := $"bhv_act_selector_star_type_loop".
Definition _button : ident := $"button".
Definition _buttonDown : ident := $"buttonDown".
Definition _buttonPressed : ident := $"buttonPressed".
Definition _callContext : ident := $"callContext".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _children : ident := $"children".
Definition _cmd : ident := $"cmd".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _color : ident := $"color".
Definition _context : ident := $"context".
Definition _controllerData : ident := $"controllerData".
Definition _courseNum : ident := $"courseNum".
Definition _create_dl_ortho_matrix : ident := $"create_dl_ortho_matrix".
Definition _create_dl_translation_matrix : ident := $"create_dl_translation_matrix".
Definition _cs : ident := $"cs".
Definition _ct : ident := $"ct".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _cur_obj_scale : ident := $"cur_obj_scale".
Definition _currLevelName : ident := $"currLevelName".
Definition _data : ident := $"data".
Definition _dl_ia_text_begin : ident := $"dl_ia_text_begin".
Definition _dl_ia_text_end : ident := $"dl_ia_text_end".
Definition _dl_menu_ia8_text_begin : ident := $"dl_menu_ia8_text_begin".
Definition _dl_menu_ia8_text_end : ident := $"dl_menu_ia8_text_end".
Definition _dl_menu_rgba16_wood_course : ident := $"dl_menu_rgba16_wood_course".
Definition _dl_rgba16_text_begin : ident := $"dl_rgba16_text_begin".
Definition _dl_rgba16_text_end : ident := $"dl_rgba16_text_end".
Definition _dma : ident := $"dma".
Definition _dram : ident := $"dram".
Definition _errnum : ident := $"errnum".
Definition _fillrect : ident := $"fillrect".
Definition _flag : ident := $"flag".
Definition _flags : ident := $"flags".
Definition _fmt : ident := $"fmt".
Definition _force : ident := $"force".
Definition _force_structure_alignment : ident := $"force_structure_alignment".
Definition _gCurrCourseNum : ident := $"gCurrCourseNum".
Definition _gCurrSaveFileNum : ident := $"gCurrSaveFileNum".
Definition _gCurrentObject : ident := $"gCurrentObject".
Definition _gDialogCourseActNum : ident := $"gDialogCourseActNum".
Definition _gDisplayListHead : ident := $"gDisplayListHead".
Definition _gGlobalSoundSource : ident := $"gGlobalSoundSource".
Definition _gPlayer3Controller : ident := $"gPlayer3Controller".
Definition _geo_act_selector_strings : ident := $"geo_act_selector_strings".
Definition _get_str_x_pos_from_center : ident := $"get_str_x_pos_from_center".
Definition _gfx : ident := $"gfx".
Definition _handle_menu_scrolling : ident := $"handle_menu_scrolling".
Definition _header : ident := $"header".
Definition _hitboxDownOffset : ident := $"hitboxDownOffset".
Definition _hitboxHeight : ident := $"hitboxHeight".
Definition _hitboxRadius : ident := $"hitboxRadius".
Definition _hurtboxHeight : ident := $"hurtboxHeight".
Definition _hurtboxRadius : ident := $"hurtboxRadius".
Definition _i : ident := $"i".
Definition _index : ident := $"index".
Definition _int_to_str : ident := $"int_to_str".
Definition _len : ident := $"len".
Definition _length : ident := $"length".
Definition _levelNameTbl : ident := $"levelNameTbl".
Definition _line : ident := $"line".
Definition _loadtile : ident := $"loadtile".
Definition _loadtlut : ident := $"loadtlut".
Definition _lodscale : ident := $"lodscale".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _lvlNameX : ident := $"lvlNameX".
Definition _lvl_init_act_selector_values_and_stars : ident := $"lvl_init_act_selector_values_and_stars".
Definition _lvl_update_obj_and_load_act_button_actions : ident := $"lvl_update_obj_and_load_act_button_actions".
Definition _main : ident := $"main".
Definition _masks : ident := $"masks".
Definition _maskt : ident := $"maskt".
Definition _model : ident := $"model".
Definition _ms : ident := $"ms".
Definition _mt : ident := $"mt".
Definition _muxs0 : ident := $"muxs0".
Definition _muxs1 : ident := $"muxs1".
Definition _mw_index : ident := $"mw_index".
Definition _myScore : ident := $"myScore".
Definition _next : ident := $"next".
Definition _node : ident := $"node".
Definition _normal : ident := $"normal".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _number : ident := $"number".
Definition _object : ident := $"object".
Definition _on : ident := $"on".
Definition _originOffset : ident := $"originOffset".
Definition _pad : ident := $"pad".
Definition _pad0 : ident := $"pad0".
Definition _pad1 : ident := $"pad1".
Definition _pad2 : ident := $"pad2".
Definition _palette : ident := $"palette".
Definition _par : ident := $"par".
Definition _param : ident := $"param".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _perspnorm : ident := $"perspnorm".
Definition _pitch : ident := $"pitch".
Definition _platform : ident := $"platform".
Definition _play_sound : ident := $"play_sound".
Definition _popmtx : ident := $"popmtx".
Definition _pos : ident := $"pos".
Definition _posX : ident := $"posX".
Definition _posY : ident := $"posY".
Definition _posZ : ident := $"posZ".
Definition _prev : ident := $"prev".
Definition _prevObj : ident := $"prevObj".
Definition _prim_level : ident := $"prim_level".
Definition _prim_min_level : ident := $"prim_min_level".
Definition _print_act_selector_strings : ident := $"print_act_selector_strings".
Definition _print_course_number : ident := $"print_course_number".
Definition _print_generic_string : ident := $"print_generic_string".
Definition _print_hud_lut_string : ident := $"print_hud_lut_string".
Definition _print_hud_my_score_coins : ident := $"print_hud_my_score_coins".
Definition _print_menu_generic_string : ident := $"print_menu_generic_string".
Definition _rawData : ident := $"rawData".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _render_100_coin_star : ident := $"render_100_coin_star".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _roll : ident := $"roll".
Definition _room : ident := $"room".
Definition _s : ident := $"s".
Definition _sActSelectorMenuTimer : ident := $"sActSelectorMenuTimer".
Definition _sInitSelectedActNum : ident := $"sInitSelectedActNum".
Definition _sLoadedActNum : ident := $"sLoadedActNum".
Definition _sObtainedStars : ident := $"sObtainedStars".
Definition _sSelectableStarIndex : ident := $"sSelectableStarIndex".
Definition _sSelectedActIndex : ident := $"sSelectedActIndex".
Definition _sStarSelectorModels : ident := $"sStarSelectorModels".
Definition _sVisibleStars : ident := $"sVisibleStars".
Definition _save_file_get_course_coin_score : ident := $"save_file_get_course_coin_score".
Definition _save_file_get_course_star_count : ident := $"save_file_get_course_star_count".
Definition _save_file_get_star_flags : ident := $"save_file_get_star_flags".
Definition _scale : ident := $"scale".
Definition _seg2_act_name_table : ident := $"seg2_act_name_table".
Definition _seg2_course_name_table : ident := $"seg2_course_name_table".
Definition _segment : ident := $"segment".
Definition _segmented_to_virtual : ident := $"segmented_to_virtual".
Definition _selectedActName : ident := $"selectedActName".
Definition _selectorModelIDs : ident := $"selectorModelIDs".
Definition _setcolor : ident := $"setcolor".
Definition _setcombine : ident := $"setcombine".
Definition _setimg : ident := $"setimg".
Definition _setothermodeH : ident := $"setothermodeH".
Definition _setothermodeL : ident := $"setothermodeL".
Definition _settile : ident := $"settile".
Definition _settilesize : ident := $"settilesize".
Definition _sft : ident := $"sft".
Definition _sh : ident := $"sh".
Definition _sharedChild : ident := $"sharedChild".
Definition _shifts : ident := $"shifts".
Definition _shiftt : ident := $"shiftt".
Definition _siz : ident := $"siz".
Definition _sl : ident := $"sl".
Definition _spawn_object_abs_with_rot : ident := $"spawn_object_abs_with_rot".
Definition _starIndexCounter : ident := $"starIndexCounter".
Definition _starNumbers : ident := $"starNumbers".
Definition _stars : ident := $"stars".
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
Definition _t : ident := $"t".
Definition _texture : ident := $"texture".
Definition _th : ident := $"th".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _tile : ident := $"tile".
Definition _tl : ident := $"tl".
Definition _tmem : ident := $"tmem".
Definition _transform : ident := $"transform".
Definition _tri : ident := $"tri".
Definition _type : ident := $"type".
Definition _unk4C : ident := $"unk4C".
Definition _unused : ident := $"unused".
Definition _unused1 : ident := $"unused1".
Definition _unused2 : ident := $"unused2".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _upperY : ident := $"upperY".
Definition _v : ident := $"v".
Definition _values : ident := $"values".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _w0 : ident := $"w0".
Definition _w1 : ident := $"w1".
Definition _wd : ident := $"wd".
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
Definition _t'3 : ident := 130%positive.
Definition _t'4 : ident := 131%positive.
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v_gGlobalSoundSource := {|
  gvar_info := (tarray tfloat 3);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvActSelectorStarType := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

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

Definition v_gDisplayListHead := {|
  gvar_info := (tptr (Tunion __549 noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gPlayer3Controller := {|
  gvar_info := (tptr (Tstruct _Controller noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDialogCourseActNum := {|
  gvar_info := tschar;
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

Definition v_seg2_course_name_table := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_seg2_act_name_table := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_dl_rgba16_text_begin := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_dl_rgba16_text_end := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_dl_ia_text_begin := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_dl_ia_text_end := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_dl_menu_ia8_text_begin := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_dl_menu_ia8_text_end := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_dl_menu_rgba16_wood_course := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sStarSelectorModels := {|
  gvar_info := (tarray (tptr (Tstruct _Object noattr)) 8);
  gvar_init := (Init_space 32 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sLoadedActNum := {|
  gvar_info := tschar;
  gvar_init := (Init_space 1 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sObtainedStars := {|
  gvar_info := tuchar;
  gvar_init := (Init_space 1 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sVisibleStars := {|
  gvar_info := tschar;
  gvar_init := (Init_space 1 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sInitSelectedActNum := {|
  gvar_info := tuchar;
  gvar_init := (Init_space 1 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSelectedActIndex := {|
  gvar_info := tschar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSelectableStarIndex := {|
  gvar_info := tschar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sActSelectorMenuTimer := {|
  gvar_info := tint;
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_bhv_act_selector_star_type_loop := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'26, tfloat) :: (_t'25, (tptr (Tstruct _Object noattr))) ::
               (_t'24, (tptr (Tstruct _Object noattr))) ::
               (_t'23, (tptr (Tstruct _Object noattr))) :: (_t'22, tfloat) ::
               (_t'21, (tptr (Tstruct _Object noattr))) ::
               (_t'20, (tptr (Tstruct _Object noattr))) :: (_t'19, tfloat) ::
               (_t'18, (tptr (Tstruct _Object noattr))) ::
               (_t'17, (tptr (Tstruct _Object noattr))) ::
               (_t'16, (tptr (Tstruct _Object noattr))) :: (_t'15, tfloat) ::
               (_t'14, (tptr (Tstruct _Object noattr))) :: (_t'13, tint) ::
               (_t'12, (tptr (Tstruct _Object noattr))) ::
               (_t'11, (tptr (Tstruct _Object noattr))) :: (_t'10, tint) ::
               (_t'9, (tptr (Tstruct _Object noattr))) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tint) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tfloat) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: (_t'3, tint) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'7
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 27) tint)
            (tptr tint)) tint))
      (Sswitch (Etempvar _t'7 tint)
        (LScons (Some 0)
          (Ssequence
            (Ssequence
              (Sset _t'24
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
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
                            (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                        (Econst_int (Int.repr 32) tint) (tptr tfloat))
                      tfloat))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'24 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                        (Econst_int (Int.repr 32) tint) (tptr tfloat))
                      tfloat)
                    (Ebinop Osub (Etempvar _t'26 tfloat)
                      (Econst_float (Float.of_bits (Int64.repr 4591870180066957722)) tdouble)
                      tdouble)))))
            (Ssequence
              (Ssequence
                (Sset _t'21
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'22
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'21 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                        (Econst_int (Int.repr 32) tint) (tptr tfloat))
                      tfloat))
                  (Sifthenelse (Ebinop Olt (Etempvar _t'22 tfloat)
                                 (Econst_float (Float.of_bits (Int64.repr 4607182418800017408)) tdouble)
                                 tint)
                    (Ssequence
                      (Sset _t'23
                        (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'23 (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _rawData
                                (Tunion __764 noattr)) _asF32
                              (tarray tfloat 80))
                            (Econst_int (Int.repr 32) tint) (tptr tfloat))
                          tfloat)
                        (Econst_float (Float.of_bits (Int64.repr 4607182418800017408)) tdouble)))
                    Sskip)))
              (Ssequence
                (Ssequence
                  (Sset _t'20
                    (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'20 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __764 noattr)) _asS32 (tarray tint 80))
                        (Ebinop Oadd (Econst_int (Int.repr 18) tint)
                          (Econst_int (Int.repr 1) tint) tint) (tptr tint))
                      tint) (Econst_int (Int.repr 0) tint)))
                Sbreak)))
          (LScons (Some 1)
            (Ssequence
              (Ssequence
                (Sset _t'17
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
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
                              (Tunion __764 noattr)) _asF32
                            (tarray tfloat 80))
                          (Econst_int (Int.repr 32) tint) (tptr tfloat))
                        tfloat))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'17 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __764 noattr)) _asF32
                            (tarray tfloat 80))
                          (Econst_int (Int.repr 32) tint) (tptr tfloat))
                        tfloat)
                      (Ebinop Oadd (Etempvar _t'19 tfloat)
                        (Econst_float (Float.of_bits (Int64.repr 4591870180066957722)) tdouble)
                        tdouble)))))
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
                              (Tunion __764 noattr)) _asF32
                            (tarray tfloat 80))
                          (Econst_int (Int.repr 32) tint) (tptr tfloat))
                        tfloat))
                    (Sifthenelse (Ebinop Ogt (Etempvar _t'15 tfloat)
                                   (Econst_float (Float.of_bits (Int64.repr 4608533498688228557)) tdouble)
                                   tint)
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
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __764 noattr)) _asF32
                                (tarray tfloat 80))
                              (Econst_int (Int.repr 32) tint) (tptr tfloat))
                            tfloat)
                          (Econst_float (Float.of_bits (Int64.repr 4608533498688228557)) tdouble)))
                      Sskip)))
                (Ssequence
                  (Ssequence
                    (Sset _t'11
                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
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
                                  (Tunion __764 noattr)) _asS32
                                (tarray tint 80))
                              (Ebinop Oadd (Econst_int (Int.repr 18) tint)
                                (Econst_int (Int.repr 1) tint) tint)
                              (tptr tint)) tint))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'11 (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __764 noattr)) _asS32
                                (tarray tint 80))
                              (Ebinop Oadd (Econst_int (Int.repr 18) tint)
                                (Econst_int (Int.repr 1) tint) tint)
                              (tptr tint)) tint)
                          (Ebinop Oadd (Etempvar _t'13 tint)
                            (Econst_int (Int.repr 2048) tint) tint)))))
                  Sbreak)))
            (LScons (Some 2)
              (Ssequence
                (Ssequence
                  (Sset _t'8
                    (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
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
                                (Tunion __764 noattr)) _asS32
                              (tarray tint 80))
                            (Ebinop Oadd (Econst_int (Int.repr 18) tint)
                              (Econst_int (Int.repr 1) tint) tint)
                            (tptr tint)) tint))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _rawData
                                (Tunion __764 noattr)) _asS32
                              (tarray tint 80))
                            (Ebinop Oadd (Econst_int (Int.repr 18) tint)
                              (Econst_int (Int.repr 1) tint) tint)
                            (tptr tint)) tint)
                        (Ebinop Oadd (Etempvar _t'10 tint)
                          (Econst_int (Int.repr 2048) tint) tint)))))
                Sbreak)
              LSnil))))))
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
                    (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
                _asF32 (tarray tfloat 80)) (Econst_int (Int.repr 32) tint)
              (tptr tfloat)) tfloat))
        (Scall None
          (Evar _cur_obj_scale (Tfunction (tfloat :: nil) tvoid cc_default))
          ((Etempvar _t'5 tfloat) :: nil))))
    (Ssequence
      (Sset _t'1 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
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
                    (Tunion __764 noattr)) _asS32 (tarray tint 80))
                (Econst_int (Int.repr 28) tint) (tptr tint)) tint))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __764 noattr)) _asS32 (tarray tint 80))
                (Econst_int (Int.repr 28) tint) (tptr tint)) tint)
            (Ebinop Oadd (Etempvar _t'3 tint) (Econst_int (Int.repr 1) tint)
              tint)))))))
|}.

Definition f_render_100_coin_star := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_stars, tuchar) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Sifthenelse (Ebinop Oand (Etempvar _stars tuchar)
               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                 (Econst_int (Int.repr 6) tint) tint) tint)
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'4 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Scall (Some _t'1)
          (Evar _spawn_object_abs_with_rot (Tfunction
                                             ((tptr (Tstruct _Object noattr)) ::
                                              tshort :: tuint ::
                                              (tptr tuint) :: tshort ::
                                              tshort :: tshort :: tshort ::
                                              tshort :: tshort :: nil)
                                             (tptr (Tstruct _Object noattr))
                                             cc_default))
          ((Etempvar _t'4 (tptr (Tstruct _Object noattr))) ::
           (Econst_int (Int.repr 0) tint) ::
           (Econst_int (Int.repr 122) tint) ::
           (Evar _bhvActSelectorStarType (tarray tuint 0)) ::
           (Econst_int (Int.repr 370) tint) ::
           (Econst_int (Int.repr 24) tint) ::
           (Eunop Oneg (Econst_int (Int.repr 300) tint) tint) ::
           (Econst_int (Int.repr 0) tint) ::
           (Econst_int (Int.repr 0) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil)))
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Evar _sStarSelectorModels (tarray (tptr (Tstruct _Object noattr)) 8))
            (Econst_int (Int.repr 6) tint)
            (tptr (tptr (Tstruct _Object noattr))))
          (tptr (Tstruct _Object noattr)))
        (Etempvar _t'1 (tptr (Tstruct _Object noattr)))))
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Ederef
            (Ebinop Oadd
              (Evar _sStarSelectorModels (tarray (tptr (Tstruct _Object noattr)) 8))
              (Econst_int (Int.repr 6) tint)
              (tptr (tptr (Tstruct _Object noattr))))
            (tptr (Tstruct _Object noattr))))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
                _asF32 (tarray tfloat 80)) (Econst_int (Int.repr 32) tint)
              (tptr tfloat)) tfloat)
          (Econst_float (Float.of_bits (Int64.repr 4605380978949069210)) tdouble)))
      (Ssequence
        (Sset _t'2
          (Ederef
            (Ebinop Oadd
              (Evar _sStarSelectorModels (tarray (tptr (Tstruct _Object noattr)) 8))
              (Econst_int (Int.repr 6) tint)
              (tptr (tptr (Tstruct _Object noattr))))
            (tptr (Tstruct _Object noattr))))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 27) tint)
              (tptr tint)) tint) (Econst_int (Int.repr 2) tint)))))
  Sskip)
|}.

Definition f_bhv_act_selector_init := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_selectorModelIDs, (tarray tint 10)) :: nil);
  fn_temps := ((_i, tshort) :: (_stars, tuchar) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: (_t'2, tint) ::
               (_t'1, tuint) :: (_t'28, tshort) :: (_t'27, tshort) ::
               (_t'26, tuchar) :: (_t'25, tschar) :: (_t'24, tschar) ::
               (_t'23, tschar) :: (_t'22, tschar) :: (_t'21, tuchar) ::
               (_t'20, tschar) :: (_t'19, tschar) :: (_t'18, tschar) ::
               (_t'17, tuchar) :: (_t'16, tschar) :: (_t'15, tschar) ::
               (_t'14, tschar) :: (_t'13, tschar) :: (_t'12, tschar) ::
               (_t'11, tschar) :: (_t'10, tuchar) :: (_t'9, tuchar) ::
               (_t'8, tschar) :: (_t'7, tschar) :: (_t'6, tint) ::
               (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tshort))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'27 (Evar _gCurrSaveFileNum tshort))
        (Ssequence
          (Sset _t'28 (Evar _gCurrCourseNum tshort))
          (Scall (Some _t'1)
            (Evar _save_file_get_star_flags (Tfunction (tint :: tint :: nil)
                                              tuint cc_default))
            ((Ebinop Osub (Etempvar _t'27 tshort)
               (Econst_int (Int.repr 1) tint) tint) ::
             (Ebinop Osub (Etempvar _t'28 tshort)
               (Econst_int (Int.repr 1) tint) tint) :: nil))))
      (Sset _stars (Ecast (Etempvar _t'1 tuint) tuchar)))
    (Ssequence
      (Sassign (Evar _sVisibleStars tschar) (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Sloop
          (Ssequence
            (Ssequence
              (Sset _t'26 (Evar _sObtainedStars tuchar))
              (Sifthenelse (Ebinop One (Etempvar _i tshort)
                             (Etempvar _t'26 tuchar) tint)
                Sskip
                Sbreak))
            (Ssequence
              (Ssequence
                (Sset _t'20 (Evar _sVisibleStars tschar))
                (Sifthenelse (Ebinop Oand (Etempvar _stars tuchar)
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Etempvar _t'20 tschar) tint) tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'25 (Evar _sVisibleStars tschar))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Evar _selectorModelIDs (tarray tint 10))
                            (Etempvar _t'25 tschar) (tptr tint)) tint)
                        (Econst_int (Int.repr 122) tint)))
                    (Sset _i
                      (Ecast
                        (Ebinop Oadd (Etempvar _i tshort)
                          (Econst_int (Int.repr 1) tint) tint) tshort)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'24 (Evar _sVisibleStars tschar))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Evar _selectorModelIDs (tarray tint 10))
                            (Etempvar _t'24 tschar) (tptr tint)) tint)
                        (Econst_int (Int.repr 121) tint)))
                    (Ssequence
                      (Sset _t'21 (Evar _sInitSelectedActNum tuchar))
                      (Sifthenelse (Ebinop Oeq (Etempvar _t'21 tuchar)
                                     (Econst_int (Int.repr 0) tint) tint)
                        (Ssequence
                          (Ssequence
                            (Sset _t'23 (Evar _sVisibleStars tschar))
                            (Sassign (Evar _sInitSelectedActNum tuchar)
                              (Ebinop Oadd (Etempvar _t'23 tschar)
                                (Econst_int (Int.repr 1) tint) tint)))
                          (Ssequence
                            (Sset _t'22 (Evar _sVisibleStars tschar))
                            (Sassign (Evar _sSelectableStarIndex tschar)
                              (Etempvar _t'22 tschar))))
                        Sskip)))))
              (Ssequence
                (Sset _t'19 (Evar _sVisibleStars tschar))
                (Sassign (Evar _sVisibleStars tschar)
                  (Ebinop Oadd (Etempvar _t'19 tschar)
                    (Econst_int (Int.repr 1) tint) tint)))))
          Sskip)
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'16 (Evar _sVisibleStars tschar))
              (Ssequence
                (Sset _t'17 (Evar _sObtainedStars tuchar))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'16 tschar)
                               (Etempvar _t'17 tuchar) tint)
                  (Ssequence
                    (Sset _t'18 (Evar _sVisibleStars tschar))
                    (Sset _t'2
                      (Ecast
                        (Ebinop One (Etempvar _t'18 tschar)
                          (Econst_int (Int.repr 6) tint) tint) tbool)))
                  (Sset _t'2 (Econst_int (Int.repr 0) tint)))))
            (Sifthenelse (Etempvar _t'2 tint)
              (Ssequence
                (Ssequence
                  (Sset _t'15 (Evar _sVisibleStars tschar))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd (Evar _selectorModelIDs (tarray tint 10))
                        (Etempvar _t'15 tschar) (tptr tint)) tint)
                    (Econst_int (Int.repr 121) tint)))
                (Ssequence
                  (Ssequence
                    (Sset _t'14 (Evar _sVisibleStars tschar))
                    (Sassign (Evar _sInitSelectedActNum tuchar)
                      (Ebinop Oadd (Etempvar _t'14 tschar)
                        (Econst_int (Int.repr 1) tint) tint)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'13 (Evar _sVisibleStars tschar))
                      (Sassign (Evar _sSelectableStarIndex tschar)
                        (Etempvar _t'13 tschar)))
                    (Ssequence
                      (Sset _t'12 (Evar _sVisibleStars tschar))
                      (Sassign (Evar _sVisibleStars tschar)
                        (Ebinop Oadd (Etempvar _t'12 tschar)
                          (Econst_int (Int.repr 1) tint) tint))))))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'10 (Evar _sObtainedStars tuchar))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'10 tuchar)
                             (Econst_int (Int.repr 6) tint) tint)
                (Ssequence
                  (Sset _t'11 (Evar _sVisibleStars tschar))
                  (Sassign (Evar _sInitSelectedActNum tuchar)
                    (Etempvar _t'11 tschar)))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'9 (Evar _sObtainedStars tuchar))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tuchar)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Sassign (Evar _sInitSelectedActNum tuchar)
                    (Econst_int (Int.repr 1) tint))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tshort))
                  (Sloop
                    (Ssequence
                      (Ssequence
                        (Sset _t'8 (Evar _sVisibleStars tschar))
                        (Sifthenelse (Ebinop Olt (Etempvar _i tshort)
                                       (Etempvar _t'8 tschar) tint)
                          Sskip
                          Sbreak))
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'5
                              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                            (Ssequence
                              (Sset _t'6
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _selectorModelIDs (tarray tint 10))
                                    (Etempvar _i tshort) (tptr tint)) tint))
                              (Ssequence
                                (Sset _t'7 (Evar _sVisibleStars tschar))
                                (Scall (Some _t'3)
                                  (Evar _spawn_object_abs_with_rot (Tfunction
                                                                    ((tptr (Tstruct _Object noattr)) ::
                                                                    tshort ::
                                                                    tuint ::
                                                                    (tptr tuint) ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    nil)
                                                                    (tptr (Tstruct _Object noattr))
                                                                    cc_default))
                                  ((Etempvar _t'5 (tptr (Tstruct _Object noattr))) ::
                                   (Econst_int (Int.repr 0) tint) ::
                                   (Etempvar _t'6 tint) ::
                                   (Evar _bhvActSelectorStarType (tarray tuint 0)) ::
                                   (Ebinop Oadd
                                     (Ebinop Omul
                                       (Ebinop Osub (Etempvar _t'7 tschar)
                                         (Econst_int (Int.repr 1) tint) tint)
                                       (Eunop Oneg
                                         (Econst_int (Int.repr 75) tint)
                                         tint) tint)
                                     (Ebinop Omul (Etempvar _i tshort)
                                       (Econst_int (Int.repr 152) tint) tint)
                                     tint) ::
                                   (Econst_int (Int.repr 248) tint) ::
                                   (Eunop Oneg
                                     (Econst_int (Int.repr 300) tint) tint) ::
                                   (Econst_int (Int.repr 0) tint) ::
                                   (Econst_int (Int.repr 0) tint) ::
                                   (Econst_int (Int.repr 0) tint) :: nil)))))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Evar _sStarSelectorModels (tarray (tptr (Tstruct _Object noattr)) 8))
                                (Etempvar _i tshort)
                                (tptr (tptr (Tstruct _Object noattr))))
                              (tptr (Tstruct _Object noattr)))
                            (Etempvar _t'3 (tptr (Tstruct _Object noattr)))))
                        (Ssequence
                          (Sset _t'4
                            (Ederef
                              (Ebinop Oadd
                                (Evar _sStarSelectorModels (tarray (tptr (Tstruct _Object noattr)) 8))
                                (Etempvar _i tshort)
                                (tptr (tptr (Tstruct _Object noattr))))
                              (tptr (Tstruct _Object noattr))))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __764 noattr)) _asF32
                                  (tarray tfloat 80))
                                (Econst_int (Int.repr 32) tint)
                                (tptr tfloat)) tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)))))
                    (Sset _i
                      (Ecast
                        (Ebinop Oadd (Etempvar _i tshort)
                          (Econst_int (Int.repr 1) tint) tint) tshort))))
                (Scall None
                  (Evar _render_100_coin_star (Tfunction (tuchar :: nil)
                                                tvoid cc_default))
                  ((Etempvar _stars tuchar) :: nil))))))))))
|}.

Definition f_bhv_act_selector_loop := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_i, tschar) :: (_starIndexCounter, tuchar) ::
               (_stars, tuchar) :: (_t'2, tint) :: (_t'1, tuint) ::
               (_t'15, tshort) :: (_t'14, tshort) :: (_t'13, tuchar) ::
               (_t'12, tschar) :: (_t'11, tschar) :: (_t'10, tuchar) ::
               (_t'9, tschar) :: (_t'8, tschar) :: (_t'7, tuchar) ::
               (_t'6, tschar) :: (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: (_t'3, tschar) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'14 (Evar _gCurrSaveFileNum tshort))
      (Ssequence
        (Sset _t'15 (Evar _gCurrCourseNum tshort))
        (Scall (Some _t'1)
          (Evar _save_file_get_star_flags (Tfunction (tint :: tint :: nil)
                                            tuint cc_default))
          ((Ebinop Osub (Etempvar _t'14 tshort)
             (Econst_int (Int.repr 1) tint) tint) ::
           (Ebinop Osub (Etempvar _t'15 tshort)
             (Econst_int (Int.repr 1) tint) tint) :: nil))))
    (Sset _stars (Ecast (Etempvar _t'1 tuint) tuchar)))
  (Ssequence
    (Ssequence
      (Sset _t'7 (Evar _sObtainedStars tuchar))
      (Sifthenelse (Ebinop One (Etempvar _t'7 tuchar)
                     (Econst_int (Int.repr 6) tint) tint)
        (Ssequence
          (Sassign (Evar _sSelectedActIndex tschar)
            (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Ssequence
              (Sset _t'13 (Evar _sObtainedStars tuchar))
              (Scall None
                (Evar _handle_menu_scrolling (Tfunction
                                               (tschar :: (tptr tschar) ::
                                                tschar :: tschar :: nil)
                                               tvoid cc_default))
                ((Econst_int (Int.repr 2) tint) ::
                 (Eaddrof (Evar _sSelectableStarIndex tschar) (tptr tschar)) ::
                 (Econst_int (Int.repr 0) tint) :: (Etempvar _t'13 tuchar) ::
                 nil)))
            (Ssequence
              (Ssequence
                (Sset _t'12 (Evar _sSelectableStarIndex tschar))
                (Sset _starIndexCounter
                  (Ecast (Etempvar _t'12 tschar) tuchar)))
              (Ssequence
                (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tschar))
                (Sloop
                  (Ssequence
                    (Ssequence
                      (Sset _t'11 (Evar _sVisibleStars tschar))
                      (Sifthenelse (Ebinop Olt (Etempvar _i tschar)
                                     (Etempvar _t'11 tschar) tint)
                        Sskip
                        Sbreak))
                    (Ssequence
                      (Sifthenelse (Ebinop Oand (Etempvar _stars tuchar)
                                     (Ebinop Oshl
                                       (Econst_int (Int.repr 1) tint)
                                       (Etempvar _i tschar) tint) tint)
                        (Sset _t'2 (Econst_int (Int.repr 1) tint))
                        (Ssequence
                          (Sset _t'10 (Evar _sInitSelectedActNum tuchar))
                          (Sset _t'2
                            (Ecast
                              (Ebinop Oeq (Etempvar _i tschar)
                                (Ebinop Osub (Etempvar _t'10 tuchar)
                                  (Econst_int (Int.repr 1) tint) tint) tint)
                              tbool))))
                      (Sifthenelse (Etempvar _t'2 tint)
                        (Ssequence
                          (Sifthenelse (Ebinop Oeq
                                         (Etempvar _starIndexCounter tuchar)
                                         (Econst_int (Int.repr 0) tint) tint)
                            (Ssequence
                              (Sassign (Evar _sSelectedActIndex tschar)
                                (Etempvar _i tschar))
                              Sbreak)
                            Sskip)
                          (Sset _starIndexCounter
                            (Ecast
                              (Ebinop Osub
                                (Etempvar _starIndexCounter tuchar)
                                (Econst_int (Int.repr 1) tint) tint) tuchar)))
                        Sskip)))
                  (Sset _i
                    (Ecast
                      (Ebinop Oadd (Etempvar _i tschar)
                        (Econst_int (Int.repr 1) tint) tint) tschar)))))))
        (Ssequence
          (Ssequence
            (Sset _t'9 (Evar _sVisibleStars tschar))
            (Scall None
              (Evar _handle_menu_scrolling (Tfunction
                                             (tschar :: (tptr tschar) ::
                                              tschar :: tschar :: nil) tvoid
                                             cc_default))
              ((Econst_int (Int.repr 2) tint) ::
               (Eaddrof (Evar _sSelectableStarIndex tschar) (tptr tschar)) ::
               (Econst_int (Int.repr 0) tint) ::
               (Ebinop Osub (Etempvar _t'9 tschar)
                 (Econst_int (Int.repr 1) tint) tint) :: nil)))
          (Ssequence
            (Sset _t'8 (Evar _sSelectableStarIndex tschar))
            (Sassign (Evar _sSelectedActIndex tschar) (Etempvar _t'8 tschar))))))
    (Ssequence
      (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tschar))
      (Sloop
        (Ssequence
          (Ssequence
            (Sset _t'6 (Evar _sVisibleStars tschar))
            (Sifthenelse (Ebinop Olt (Etempvar _i tschar)
                           (Etempvar _t'6 tschar) tint)
              Sskip
              Sbreak))
          (Ssequence
            (Sset _t'3 (Evar _sSelectedActIndex tschar))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tschar)
                           (Etempvar _i tschar) tint)
              (Ssequence
                (Sset _t'5
                  (Ederef
                    (Ebinop Oadd
                      (Evar _sStarSelectorModels (tarray (tptr (Tstruct _Object noattr)) 8))
                      (Etempvar _i tschar)
                      (tptr (tptr (Tstruct _Object noattr))))
                    (tptr (Tstruct _Object noattr))))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __764 noattr)) _asS32 (tarray tint 80))
                      (Econst_int (Int.repr 27) tint) (tptr tint)) tint)
                  (Econst_int (Int.repr 1) tint)))
              (Ssequence
                (Sset _t'4
                  (Ederef
                    (Ebinop Oadd
                      (Evar _sStarSelectorModels (tarray (tptr (Tstruct _Object noattr)) 8))
                      (Etempvar _i tschar)
                      (tptr (tptr (Tstruct _Object noattr))))
                    (tptr (Tstruct _Object noattr))))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __764 noattr)) _asS32 (tarray tint 80))
                      (Econst_int (Int.repr 27) tint) (tptr tint)) tint)
                  (Econst_int (Int.repr 0) tint))))))
        (Sset _i
          (Ecast
            (Ebinop Oadd (Etempvar _i tschar) (Econst_int (Int.repr 1) tint)
              tint) tschar))))))
|}.

Definition f_print_course_number := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_courseNum, (tarray tuchar 4)) :: nil);
  fn_temps := ((__g, (tptr (Tunion __549 noattr))) ::
               (__g__1, (tptr (Tunion __549 noattr))) ::
               (__g__2, (tptr (Tunion __549 noattr))) ::
               (__g__3, (tptr (Tunion __549 noattr))) ::
               (__g__4, (tptr (Tunion __549 noattr))) ::
               (_t'5, (tptr (Tunion __549 noattr))) ::
               (_t'4, (tptr (Tunion __549 noattr))) ::
               (_t'3, (tptr (Tunion __549 noattr))) ::
               (_t'2, (tptr (Tunion __549 noattr))) ::
               (_t'1, (tptr (Tunion __549 noattr))) :: (_t'7, tshort) ::
               (_t'6, tshort) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _create_dl_translation_matrix (Tfunction
                                          (tschar :: tfloat :: tfloat ::
                                           tfloat :: nil) tvoid cc_default))
    ((Econst_int (Int.repr 1) tint) ::
     (Econst_single (Float32.of_bits (Int.repr 1126039552)) tfloat) ::
     (Econst_single (Float32.of_bits (Int.repr 1117913088)) tfloat) ::
     (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) :: nil))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'1 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
          (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
            (Ebinop Oadd (Etempvar _t'1 (tptr (Tunion __549 noattr)))
              (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
        (Sset __g
          (Ecast (Etempvar _t'1 (tptr (Tunion __549 noattr)))
            (tptr (Tunion __549 noattr)))))
      (Ssequence
        (Sassign
          (Efield
            (Efield
              (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
                (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
            tuint)
          (Ebinop Oor
            (Ebinop Oor
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand (Ecast (Econst_int (Int.repr 222) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 8) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 24) tint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 8) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 16) tint) tuint) tuint) tuint)
            (Ecast
              (Ebinop Oshl
                (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                  (Ebinop Osub
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 16) tint) tint)
                    (Econst_int (Int.repr 1) tint) tint) tuint)
                (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
        (Sassign
          (Efield
            (Efield
              (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
                (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
            tuint)
          (Ecast (Evar _dl_menu_rgba16_wood_course (tarray tuchar 0)) tuint))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'2 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
            (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
              (Ebinop Oadd (Etempvar _t'2 (tptr (Tunion __549 noattr)))
                (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
          (Sset __g__1
            (Ecast (Etempvar _t'2 (tptr (Tunion __549 noattr)))
              (tptr (Tunion __549 noattr)))))
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                  (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
              tuint)
            (Ebinop Oor
              (Ebinop Oor
                (Ebinop Oor
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 216) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 8) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 24) tint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast
                          (Ebinop Odiv
                            (Ebinop Osub (Econst_int (Int.repr 64) tint)
                              (Econst_int (Int.repr 1) tint) tint)
                            (Econst_int (Int.repr 8) tint) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 5) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 19) tint) tuint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast
                        (Ebinop Odiv (Econst_int (Int.repr 0) tint)
                          (Econst_int (Int.repr 8) tint) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 8) tint) tuint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand (Ecast (Econst_int (Int.repr 2) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 8) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                  (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
              tuint)
            (Ecast
              (Ebinop Omul (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 64) tint) tint) tuint))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'3
                (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
              (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                (Ebinop Oadd (Etempvar _t'3 (tptr (Tunion __549 noattr)))
                  (Econst_int (Int.repr 1) tint)
                  (tptr (Tunion __549 noattr)))))
            (Sset __g__2
              (Ecast (Etempvar _t'3 (tptr (Tunion __549 noattr)))
                (tptr (Tunion __549 noattr)))))
          (Ssequence
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
                tuint)
              (Ebinop Oor
                (Ebinop Oor
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 222) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 8) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 24) tint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 0) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 8) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 16) tint) tuint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 16) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
                tuint)
              (Ecast
                (Evar _dl_rgba16_text_begin (tarray (Tunion __549 noattr) 0))
                tuint))))
        (Ssequence
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'4
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                (Sassign
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                  (Ebinop Oadd (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                    (Econst_int (Int.repr 1) tint)
                    (tptr (Tunion __549 noattr)))))
              (Sset __g__3
                (Ecast (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                  (tptr (Tunion __549 noattr)))))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w0 tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast (Econst_int (Int.repr 251) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 24) tint) tuint) tuint))
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w1 tuint)
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
                            (Econst_int (Int.repr 16) tint) tuint) tuint)
                        tuint)
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
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 255) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 0) tint) tuint) tuint) tuint)
                  tuint))))
          (Ssequence
            (Ssequence
              (Sset _t'7 (Evar _gCurrCourseNum tshort))
              (Scall None
                (Evar _int_to_str (Tfunction (tint :: (tptr tuchar) :: nil)
                                    tvoid cc_default))
                ((Etempvar _t'7 tshort) ::
                 (Evar _courseNum (tarray tuchar 4)) :: nil)))
            (Ssequence
              (Ssequence
                (Sset _t'6 (Evar _gCurrCourseNum tshort))
                (Sifthenelse (Ebinop Olt (Etempvar _t'6 tshort)
                               (Econst_int (Int.repr 10) tint) tint)
                  (Scall None
                    (Evar _print_hud_lut_string (Tfunction
                                                  (tschar :: tshort ::
                                                   tshort :: (tptr tuchar) ::
                                                   nil) tvoid cc_default))
                    ((Econst_int (Int.repr 2) tint) ::
                     (Econst_int (Int.repr 152) tint) ::
                     (Econst_int (Int.repr 158) tint) ::
                     (Evar _courseNum (tarray tuchar 4)) :: nil))
                  (Scall None
                    (Evar _print_hud_lut_string (Tfunction
                                                  (tschar :: tshort ::
                                                   tshort :: (tptr tuchar) ::
                                                   nil) tvoid cc_default))
                    ((Econst_int (Int.repr 2) tint) ::
                     (Econst_int (Int.repr 143) tint) ::
                     (Econst_int (Int.repr 158) tint) ::
                     (Evar _courseNum (tarray tuchar 4)) :: nil))))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'5
                      (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                    (Sassign
                      (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                      (Ebinop Oadd
                        (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                        (Econst_int (Int.repr 1) tint)
                        (tptr (Tunion __549 noattr)))))
                  (Sset __g__4
                    (Ecast (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                      (tptr (Tunion __549 noattr)))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                          (Tunion __549 noattr)) _words
                        (Tstruct __547 noattr)) _w0 tuint)
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 222) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 8) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 24) tint) tuint) tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 0) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 8) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 16) tint) tuint) tuint)
                        tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 0) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 16) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                          (Tunion __549 noattr)) _words
                        (Tstruct __547 noattr)) _w1 tuint)
                    (Ecast
                      (Evar _dl_rgba16_text_end (tarray (Tunion __549 noattr) 0))
                      tuint)))))))))))
|}.

Definition f_print_act_selector_strings := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_myScore, (tarray tuchar 8)) ::
              (_starNumbers, (tarray tuchar 2)) :: nil);
  fn_temps := ((_levelNameTbl, (tptr (tptr tuchar))) ::
               (_currLevelName, (tptr tuchar)) ::
               (_actNameTbl, (tptr (tptr tuchar))) ::
               (_selectedActName, (tptr tuchar)) :: (_lvlNameX, tshort) ::
               (_actNameX, tshort) :: (_i, tschar) ::
               (__g, (tptr (Tunion __549 noattr))) ::
               (__g__1, (tptr (Tunion __549 noattr))) ::
               (__g__2, (tptr (Tunion __549 noattr))) ::
               (__g__3, (tptr (Tunion __549 noattr))) ::
               (__g__4, (tptr (Tunion __549 noattr))) ::
               (__g__5, (tptr (Tunion __549 noattr))) ::
               (__g__6, (tptr (Tunion __549 noattr))) ::
               (__g__7, (tptr (Tunion __549 noattr))) ::
               (__g__8, (tptr (Tunion __549 noattr))) ::
               (_t'16, (tptr (Tunion __549 noattr))) :: (_t'15, tshort) ::
               (_t'14, (tptr tvoid)) ::
               (_t'13, (tptr (Tunion __549 noattr))) ::
               (_t'12, (tptr (Tunion __549 noattr))) ::
               (_t'11, (tptr (Tunion __549 noattr))) :: (_t'10, tshort) ::
               (_t'9, tint) :: (_t'8, (tptr (Tunion __549 noattr))) ::
               (_t'7, (tptr (Tunion __549 noattr))) ::
               (_t'6, (tptr (Tunion __549 noattr))) ::
               (_t'5, (tptr (Tunion __549 noattr))) ::
               (_t'4, (tptr (Tunion __549 noattr))) ::
               (_t'3, (tptr tvoid)) :: (_t'2, (tptr tvoid)) ::
               (_t'1, (tptr tvoid)) :: (_t'28, (tptr tuchar)) ::
               (_t'27, tshort) :: (_t'26, tshort) :: (_t'25, tshort) ::
               (_t'24, tshort) :: (_t'23, tshort) ::
               (_t'22, (tptr tuchar)) :: (_t'21, tschar) ::
               (_t'20, tshort) :: (_t'19, tschar) :: (_t'18, tschar) ::
               (_t'17, tschar) :: nil);
  fn_body :=
(Ssequence
  (Sassign
    (Ederef
      (Ebinop Oadd (Evar _myScore (tarray tuchar 8))
        (Econst_int (Int.repr 0) tint) (tptr tuchar)) tuchar)
    (Econst_int (Int.repr 22) tint))
  (Ssequence
    (Sassign
      (Ederef
        (Ebinop Oadd (Evar _myScore (tarray tuchar 8))
          (Econst_int (Int.repr 1) tint) (tptr tuchar)) tuchar)
      (Econst_int (Int.repr 34) tint))
    (Ssequence
      (Sassign
        (Ederef
          (Ebinop Oadd (Evar _myScore (tarray tuchar 8))
            (Econst_int (Int.repr 2) tint) (tptr tuchar)) tuchar)
        (Econst_int (Int.repr 28) tint))
      (Ssequence
        (Sassign
          (Ederef
            (Ebinop Oadd (Evar _myScore (tarray tuchar 8))
              (Econst_int (Int.repr 3) tint) (tptr tuchar)) tuchar)
          (Econst_int (Int.repr 12) tint))
        (Ssequence
          (Sassign
            (Ederef
              (Ebinop Oadd (Evar _myScore (tarray tuchar 8))
                (Econst_int (Int.repr 4) tint) (tptr tuchar)) tuchar)
            (Econst_int (Int.repr 24) tint))
          (Ssequence
            (Sassign
              (Ederef
                (Ebinop Oadd (Evar _myScore (tarray tuchar 8))
                  (Econst_int (Int.repr 5) tint) (tptr tuchar)) tuchar)
              (Econst_int (Int.repr 27) tint))
            (Ssequence
              (Sassign
                (Ederef
                  (Ebinop Oadd (Evar _myScore (tarray tuchar 8))
                    (Econst_int (Int.repr 6) tint) (tptr tuchar)) tuchar)
                (Econst_int (Int.repr 14) tint))
              (Ssequence
                (Sassign
                  (Ederef
                    (Ebinop Oadd (Evar _myScore (tarray tuchar 8))
                      (Econst_int (Int.repr 7) tint) (tptr tuchar)) tuchar)
                  (Econst_int (Int.repr 255) tint))
                (Ssequence
                  (Sassign
                    (Ederef
                      (Ebinop Oadd (Evar _starNumbers (tarray tuchar 2))
                        (Econst_int (Int.repr 0) tint) (tptr tuchar)) tuchar)
                    (Econst_int (Int.repr 0) tint))
                  (Ssequence
                    (Sassign
                      (Ederef
                        (Ebinop Oadd (Evar _starNumbers (tarray tuchar 2))
                          (Econst_int (Int.repr 1) tint) (tptr tuchar))
                        tuchar) (Econst_int (Int.repr 255) tint))
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'1)
                          (Evar _segmented_to_virtual (Tfunction
                                                        ((tptr tvoid) :: nil)
                                                        (tptr tvoid)
                                                        cc_default))
                          ((Evar _seg2_course_name_table (tarray tuchar 0)) ::
                           nil))
                        (Sset _levelNameTbl (Etempvar _t'1 (tptr tvoid))))
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'27 (Evar _gCurrCourseNum tshort))
                            (Ssequence
                              (Sset _t'28
                                (Ederef
                                  (Ebinop Oadd
                                    (Etempvar _levelNameTbl (tptr (tptr tuchar)))
                                    (Ebinop Osub (Etempvar _t'27 tshort)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    (tptr (tptr tuchar))) (tptr tuchar)))
                              (Scall (Some _t'2)
                                (Evar _segmented_to_virtual (Tfunction
                                                              ((tptr tvoid) ::
                                                               nil)
                                                              (tptr tvoid)
                                                              cc_default))
                                ((Etempvar _t'28 (tptr tuchar)) :: nil))))
                          (Sset _currLevelName (Etempvar _t'2 (tptr tvoid))))
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'3)
                              (Evar _segmented_to_virtual (Tfunction
                                                            ((tptr tvoid) ::
                                                             nil)
                                                            (tptr tvoid)
                                                            cc_default))
                              ((Evar _seg2_act_name_table (tarray tuchar 0)) ::
                               nil))
                            (Sset _actNameTbl (Etempvar _t'3 (tptr tvoid))))
                          (Ssequence
                            (Scall None
                              (Evar _create_dl_ortho_matrix (Tfunction nil
                                                              tvoid
                                                              cc_default))
                              nil)
                            (Ssequence
                              (Ssequence
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'4
                                      (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                                    (Sassign
                                      (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                                      (Ebinop Oadd
                                        (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr (Tunion __549 noattr)))))
                                  (Sset __g
                                    (Ecast
                                      (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                                      (tptr (Tunion __549 noattr)))))
                                (Ssequence
                                  (Sassign
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar __g (tptr (Tunion __549 noattr)))
                                          (Tunion __549 noattr)) _words
                                        (Tstruct __547 noattr)) _w0 tuint)
                                    (Ebinop Oor
                                      (Ebinop Oor
                                        (Ecast
                                          (Ebinop Oshl
                                            (Ebinop Oand
                                              (Ecast
                                                (Econst_int (Int.repr 222) tint)
                                                tuint)
                                              (Ebinop Osub
                                                (Ebinop Oshl
                                                  (Econst_int (Int.repr 1) tint)
                                                  (Econst_int (Int.repr 8) tint)
                                                  tint)
                                                (Econst_int (Int.repr 1) tint)
                                                tint) tuint)
                                            (Econst_int (Int.repr 24) tint)
                                            tuint) tuint)
                                        (Ecast
                                          (Ebinop Oshl
                                            (Ebinop Oand
                                              (Ecast
                                                (Econst_int (Int.repr 0) tint)
                                                tuint)
                                              (Ebinop Osub
                                                (Ebinop Oshl
                                                  (Econst_int (Int.repr 1) tint)
                                                  (Econst_int (Int.repr 8) tint)
                                                  tint)
                                                (Econst_int (Int.repr 1) tint)
                                                tint) tuint)
                                            (Econst_int (Int.repr 16) tint)
                                            tuint) tuint) tuint)
                                      (Ecast
                                        (Ebinop Oshl
                                          (Ebinop Oand
                                            (Ecast
                                              (Econst_int (Int.repr 0) tint)
                                              tuint)
                                            (Ebinop Osub
                                              (Ebinop Oshl
                                                (Econst_int (Int.repr 1) tint)
                                                (Econst_int (Int.repr 16) tint)
                                                tint)
                                              (Econst_int (Int.repr 1) tint)
                                              tint) tuint)
                                          (Econst_int (Int.repr 0) tint)
                                          tuint) tuint) tuint))
                                  (Sassign
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar __g (tptr (Tunion __549 noattr)))
                                          (Tunion __549 noattr)) _words
                                        (Tstruct __547 noattr)) _w1 tuint)
                                    (Ecast
                                      (Evar _dl_rgba16_text_begin (tarray (Tunion __549 noattr) 0))
                                      tuint))))
                              (Ssequence
                                (Ssequence
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'5
                                        (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                                      (Sassign
                                        (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                                        (Ebinop Oadd
                                          (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                                          (Econst_int (Int.repr 1) tint)
                                          (tptr (Tunion __549 noattr)))))
                                    (Sset __g__1
                                      (Ecast
                                        (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                                        (tptr (Tunion __549 noattr)))))
                                  (Ssequence
                                    (Sassign
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                                            (Tunion __549 noattr)) _words
                                          (Tstruct __547 noattr)) _w0 tuint)
                                      (Ecast
                                        (Ebinop Oshl
                                          (Ebinop Oand
                                            (Ecast
                                              (Econst_int (Int.repr 251) tint)
                                              tuint)
                                            (Ebinop Osub
                                              (Ebinop Oshl
                                                (Econst_int (Int.repr 1) tint)
                                                (Econst_int (Int.repr 8) tint)
                                                tint)
                                              (Econst_int (Int.repr 1) tint)
                                              tint) tuint)
                                          (Econst_int (Int.repr 24) tint)
                                          tuint) tuint))
                                    (Sassign
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                                            (Tunion __549 noattr)) _words
                                          (Tstruct __547 noattr)) _w1 tuint)
                                      (Ecast
                                        (Ebinop Oor
                                          (Ebinop Oor
                                            (Ebinop Oor
                                              (Ecast
                                                (Ebinop Oshl
                                                  (Ebinop Oand
                                                    (Ecast
                                                      (Econst_int (Int.repr 255) tint)
                                                      tuint)
                                                    (Ebinop Osub
                                                      (Ebinop Oshl
                                                        (Econst_int (Int.repr 1) tint)
                                                        (Econst_int (Int.repr 8) tint)
                                                        tint)
                                                      (Econst_int (Int.repr 1) tint)
                                                      tint) tuint)
                                                  (Econst_int (Int.repr 24) tint)
                                                  tuint) tuint)
                                              (Ecast
                                                (Ebinop Oshl
                                                  (Ebinop Oand
                                                    (Ecast
                                                      (Econst_int (Int.repr 255) tint)
                                                      tuint)
                                                    (Ebinop Osub
                                                      (Ebinop Oshl
                                                        (Econst_int (Int.repr 1) tint)
                                                        (Econst_int (Int.repr 8) tint)
                                                        tint)
                                                      (Econst_int (Int.repr 1) tint)
                                                      tint) tuint)
                                                  (Econst_int (Int.repr 16) tint)
                                                  tuint) tuint) tuint)
                                            (Ecast
                                              (Ebinop Oshl
                                                (Ebinop Oand
                                                  (Ecast
                                                    (Econst_int (Int.repr 255) tint)
                                                    tuint)
                                                  (Ebinop Osub
                                                    (Ebinop Oshl
                                                      (Econst_int (Int.repr 1) tint)
                                                      (Econst_int (Int.repr 8) tint)
                                                      tint)
                                                    (Econst_int (Int.repr 1) tint)
                                                    tint) tuint)
                                                (Econst_int (Int.repr 8) tint)
                                                tuint) tuint) tuint)
                                          (Ecast
                                            (Ebinop Oshl
                                              (Ebinop Oand
                                                (Ecast
                                                  (Econst_int (Int.repr 255) tint)
                                                  tuint)
                                                (Ebinop Osub
                                                  (Ebinop Oshl
                                                    (Econst_int (Int.repr 1) tint)
                                                    (Econst_int (Int.repr 8) tint)
                                                    tint)
                                                  (Econst_int (Int.repr 1) tint)
                                                  tint) tuint)
                                              (Econst_int (Int.repr 0) tint)
                                              tuint) tuint) tuint) tuint))))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'25
                                      (Evar _gCurrSaveFileNum tshort))
                                    (Ssequence
                                      (Sset _t'26
                                        (Evar _gCurrCourseNum tshort))
                                      (Scall None
                                        (Evar _print_hud_my_score_coins
                                        (Tfunction
                                          (tint :: tschar :: tschar ::
                                           tshort :: tshort :: nil) tvoid
                                          cc_default))
                                        ((Econst_int (Int.repr 1) tint) ::
                                         (Ebinop Osub (Etempvar _t'25 tshort)
                                           (Econst_int (Int.repr 1) tint)
                                           tint) ::
                                         (Ebinop Osub (Etempvar _t'26 tshort)
                                           (Econst_int (Int.repr 1) tint)
                                           tint) ::
                                         (Econst_int (Int.repr 155) tint) ::
                                         (Econst_int (Int.repr 106) tint) ::
                                         nil))))
                                  (Ssequence
                                    (Ssequence
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'6
                                            (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                                          (Sassign
                                            (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                                            (Ebinop Oadd
                                              (Etempvar _t'6 (tptr (Tunion __549 noattr)))
                                              (Econst_int (Int.repr 1) tint)
                                              (tptr (Tunion __549 noattr)))))
                                        (Sset __g__2
                                          (Ecast
                                            (Etempvar _t'6 (tptr (Tunion __549 noattr)))
                                            (tptr (Tunion __549 noattr)))))
                                      (Ssequence
                                        (Sassign
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                                                (Tunion __549 noattr)) _words
                                              (Tstruct __547 noattr)) _w0
                                            tuint)
                                          (Ebinop Oor
                                            (Ebinop Oor
                                              (Ecast
                                                (Ebinop Oshl
                                                  (Ebinop Oand
                                                    (Ecast
                                                      (Econst_int (Int.repr 222) tint)
                                                      tuint)
                                                    (Ebinop Osub
                                                      (Ebinop Oshl
                                                        (Econst_int (Int.repr 1) tint)
                                                        (Econst_int (Int.repr 8) tint)
                                                        tint)
                                                      (Econst_int (Int.repr 1) tint)
                                                      tint) tuint)
                                                  (Econst_int (Int.repr 24) tint)
                                                  tuint) tuint)
                                              (Ecast
                                                (Ebinop Oshl
                                                  (Ebinop Oand
                                                    (Ecast
                                                      (Econst_int (Int.repr 0) tint)
                                                      tuint)
                                                    (Ebinop Osub
                                                      (Ebinop Oshl
                                                        (Econst_int (Int.repr 1) tint)
                                                        (Econst_int (Int.repr 8) tint)
                                                        tint)
                                                      (Econst_int (Int.repr 1) tint)
                                                      tint) tuint)
                                                  (Econst_int (Int.repr 16) tint)
                                                  tuint) tuint) tuint)
                                            (Ecast
                                              (Ebinop Oshl
                                                (Ebinop Oand
                                                  (Ecast
                                                    (Econst_int (Int.repr 0) tint)
                                                    tuint)
                                                  (Ebinop Osub
                                                    (Ebinop Oshl
                                                      (Econst_int (Int.repr 1) tint)
                                                      (Econst_int (Int.repr 16) tint)
                                                      tint)
                                                    (Econst_int (Int.repr 1) tint)
                                                    tint) tuint)
                                                (Econst_int (Int.repr 0) tint)
                                                tuint) tuint) tuint))
                                        (Sassign
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                                                (Tunion __549 noattr)) _words
                                              (Tstruct __547 noattr)) _w1
                                            tuint)
                                          (Ecast
                                            (Evar _dl_rgba16_text_end (tarray (Tunion __549 noattr) 0))
                                            tuint))))
                                    (Ssequence
                                      (Ssequence
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'7
                                              (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                                            (Sassign
                                              (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                                              (Ebinop Oadd
                                                (Etempvar _t'7 (tptr (Tunion __549 noattr)))
                                                (Econst_int (Int.repr 1) tint)
                                                (tptr (Tunion __549 noattr)))))
                                          (Sset __g__3
                                            (Ecast
                                              (Etempvar _t'7 (tptr (Tunion __549 noattr)))
                                              (tptr (Tunion __549 noattr)))))
                                        (Ssequence
                                          (Sassign
                                            (Efield
                                              (Efield
                                                (Ederef
                                                  (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                                                  (Tunion __549 noattr))
                                                _words
                                                (Tstruct __547 noattr)) _w0
                                              tuint)
                                            (Ebinop Oor
                                              (Ebinop Oor
                                                (Ecast
                                                  (Ebinop Oshl
                                                    (Ebinop Oand
                                                      (Ecast
                                                        (Econst_int (Int.repr 222) tint)
                                                        tuint)
                                                      (Ebinop Osub
                                                        (Ebinop Oshl
                                                          (Econst_int (Int.repr 1) tint)
                                                          (Econst_int (Int.repr 8) tint)
                                                          tint)
                                                        (Econst_int (Int.repr 1) tint)
                                                        tint) tuint)
                                                    (Econst_int (Int.repr 24) tint)
                                                    tuint) tuint)
                                                (Ecast
                                                  (Ebinop Oshl
                                                    (Ebinop Oand
                                                      (Ecast
                                                        (Econst_int (Int.repr 0) tint)
                                                        tuint)
                                                      (Ebinop Osub
                                                        (Ebinop Oshl
                                                          (Econst_int (Int.repr 1) tint)
                                                          (Econst_int (Int.repr 8) tint)
                                                          tint)
                                                        (Econst_int (Int.repr 1) tint)
                                                        tint) tuint)
                                                    (Econst_int (Int.repr 16) tint)
                                                    tuint) tuint) tuint)
                                              (Ecast
                                                (Ebinop Oshl
                                                  (Ebinop Oand
                                                    (Ecast
                                                      (Econst_int (Int.repr 0) tint)
                                                      tuint)
                                                    (Ebinop Osub
                                                      (Ebinop Oshl
                                                        (Econst_int (Int.repr 1) tint)
                                                        (Econst_int (Int.repr 16) tint)
                                                        tint)
                                                      (Econst_int (Int.repr 1) tint)
                                                      tint) tuint)
                                                  (Econst_int (Int.repr 0) tint)
                                                  tuint) tuint) tuint))
                                          (Sassign
                                            (Efield
                                              (Efield
                                                (Ederef
                                                  (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                                                  (Tunion __549 noattr))
                                                _words
                                                (Tstruct __547 noattr)) _w1
                                              tuint)
                                            (Ecast
                                              (Evar _dl_ia_text_begin (tarray (Tunion __549 noattr) 0))
                                              tuint))))
                                      (Ssequence
                                        (Ssequence
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'8
                                                (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                                              (Sassign
                                                (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                                                (Ebinop Oadd
                                                  (Etempvar _t'8 (tptr (Tunion __549 noattr)))
                                                  (Econst_int (Int.repr 1) tint)
                                                  (tptr (Tunion __549 noattr)))))
                                            (Sset __g__4
                                              (Ecast
                                                (Etempvar _t'8 (tptr (Tunion __549 noattr)))
                                                (tptr (Tunion __549 noattr)))))
                                          (Ssequence
                                            (Sassign
                                              (Efield
                                                (Efield
                                                  (Ederef
                                                    (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                                                    (Tunion __549 noattr))
                                                  _words
                                                  (Tstruct __547 noattr)) _w0
                                                tuint)
                                              (Ecast
                                                (Ebinop Oshl
                                                  (Ebinop Oand
                                                    (Ecast
                                                      (Econst_int (Int.repr 251) tint)
                                                      tuint)
                                                    (Ebinop Osub
                                                      (Ebinop Oshl
                                                        (Econst_int (Int.repr 1) tint)
                                                        (Econst_int (Int.repr 8) tint)
                                                        tint)
                                                      (Econst_int (Int.repr 1) tint)
                                                      tint) tuint)
                                                  (Econst_int (Int.repr 24) tint)
                                                  tuint) tuint))
                                            (Sassign
                                              (Efield
                                                (Efield
                                                  (Ederef
                                                    (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                                                    (Tunion __549 noattr))
                                                  _words
                                                  (Tstruct __547 noattr)) _w1
                                                tuint)
                                              (Ecast
                                                (Ebinop Oor
                                                  (Ebinop Oor
                                                    (Ebinop Oor
                                                      (Ecast
                                                        (Ebinop Oshl
                                                          (Ebinop Oand
                                                            (Ecast
                                                              (Econst_int (Int.repr 0) tint)
                                                              tuint)
                                                            (Ebinop Osub
                                                              (Ebinop Oshl
                                                                (Econst_int (Int.repr 1) tint)
                                                                (Econst_int (Int.repr 8) tint)
                                                                tint)
                                                              (Econst_int (Int.repr 1) tint)
                                                              tint) tuint)
                                                          (Econst_int (Int.repr 24) tint)
                                                          tuint) tuint)
                                                      (Ecast
                                                        (Ebinop Oshl
                                                          (Ebinop Oand
                                                            (Ecast
                                                              (Econst_int (Int.repr 0) tint)
                                                              tuint)
                                                            (Ebinop Osub
                                                              (Ebinop Oshl
                                                                (Econst_int (Int.repr 1) tint)
                                                                (Econst_int (Int.repr 8) tint)
                                                                tint)
                                                              (Econst_int (Int.repr 1) tint)
                                                              tint) tuint)
                                                          (Econst_int (Int.repr 16) tint)
                                                          tuint) tuint)
                                                      tuint)
                                                    (Ecast
                                                      (Ebinop Oshl
                                                        (Ebinop Oand
                                                          (Ecast
                                                            (Econst_int (Int.repr 0) tint)
                                                            tuint)
                                                          (Ebinop Osub
                                                            (Ebinop Oshl
                                                              (Econst_int (Int.repr 1) tint)
                                                              (Econst_int (Int.repr 8) tint)
                                                              tint)
                                                            (Econst_int (Int.repr 1) tint)
                                                            tint) tuint)
                                                        (Econst_int (Int.repr 8) tint)
                                                        tuint) tuint) tuint)
                                                  (Ecast
                                                    (Ebinop Oshl
                                                      (Ebinop Oand
                                                        (Ecast
                                                          (Econst_int (Int.repr 255) tint)
                                                          tuint)
                                                        (Ebinop Osub
                                                          (Ebinop Oshl
                                                            (Econst_int (Int.repr 1) tint)
                                                            (Econst_int (Int.repr 8) tint)
                                                            tint)
                                                          (Econst_int (Int.repr 1) tint)
                                                          tint) tuint)
                                                      (Econst_int (Int.repr 0) tint)
                                                      tuint) tuint) tuint)
                                                tuint))))
                                        (Ssequence
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'23
                                                (Evar _gCurrSaveFileNum tshort))
                                              (Ssequence
                                                (Sset _t'24
                                                  (Evar _gCurrCourseNum tshort))
                                                (Scall (Some _t'9)
                                                  (Evar _save_file_get_course_coin_score
                                                  (Tfunction
                                                    (tint :: tint :: nil)
                                                    tint cc_default))
                                                  ((Ebinop Osub
                                                     (Etempvar _t'23 tshort)
                                                     (Econst_int (Int.repr 1) tint)
                                                     tint) ::
                                                   (Ebinop Osub
                                                     (Etempvar _t'24 tshort)
                                                     (Econst_int (Int.repr 1) tint)
                                                     tint) :: nil))))
                                            (Sifthenelse (Ebinop One
                                                           (Etempvar _t'9 tint)
                                                           (Econst_int (Int.repr 0) tint)
                                                           tint)
                                              (Scall None
                                                (Evar _print_generic_string
                                                (Tfunction
                                                  (tshort :: tshort ::
                                                   (tptr tuchar) :: nil)
                                                  tvoid cc_default))
                                                ((Econst_int (Int.repr 102) tint) ::
                                                 (Econst_int (Int.repr 118) tint) ::
                                                 (Evar _myScore (tarray tuchar 8)) ::
                                                 nil))
                                              Sskip))
                                          (Ssequence
                                            (Ssequence
                                              (Scall (Some _t'10)
                                                (Evar _get_str_x_pos_from_center
                                                (Tfunction
                                                  (tshort :: (tptr tuchar) ::
                                                   tfloat :: nil) tshort
                                                  cc_default))
                                                ((Econst_int (Int.repr 160) tint) ::
                                                 (Ebinop Oadd
                                                   (Etempvar _currLevelName (tptr tuchar))
                                                   (Econst_int (Int.repr 3) tint)
                                                   (tptr tuchar)) ::
                                                 (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat) ::
                                                 nil))
                                              (Sset _lvlNameX
                                                (Ecast
                                                  (Etempvar _t'10 tshort)
                                                  tshort)))
                                            (Ssequence
                                              (Scall None
                                                (Evar _print_generic_string
                                                (Tfunction
                                                  (tshort :: tshort ::
                                                   (tptr tuchar) :: nil)
                                                  tvoid cc_default))
                                                ((Etempvar _lvlNameX tshort) ::
                                                 (Econst_int (Int.repr 33) tint) ::
                                                 (Ebinop Oadd
                                                   (Etempvar _currLevelName (tptr tuchar))
                                                   (Econst_int (Int.repr 3) tint)
                                                   (tptr tuchar)) :: nil))
                                              (Ssequence
                                                (Ssequence
                                                  (Ssequence
                                                    (Ssequence
                                                      (Sset _t'11
                                                        (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                                                      (Sassign
                                                        (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                                                        (Ebinop Oadd
                                                          (Etempvar _t'11 (tptr (Tunion __549 noattr)))
                                                          (Econst_int (Int.repr 1) tint)
                                                          (tptr (Tunion __549 noattr)))))
                                                    (Sset __g__5
                                                      (Ecast
                                                        (Etempvar _t'11 (tptr (Tunion __549 noattr)))
                                                        (tptr (Tunion __549 noattr)))))
                                                  (Ssequence
                                                    (Sassign
                                                      (Efield
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar __g__5 (tptr (Tunion __549 noattr)))
                                                            (Tunion __549 noattr))
                                                          _words
                                                          (Tstruct __547 noattr))
                                                        _w0 tuint)
                                                      (Ebinop Oor
                                                        (Ebinop Oor
                                                          (Ecast
                                                            (Ebinop Oshl
                                                              (Ebinop Oand
                                                                (Ecast
                                                                  (Econst_int (Int.repr 222) tint)
                                                                  tuint)
                                                                (Ebinop Osub
                                                                  (Ebinop Oshl
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (Econst_int (Int.repr 8) tint)
                                                                    tint)
                                                                  (Econst_int (Int.repr 1) tint)
                                                                  tint)
                                                                tuint)
                                                              (Econst_int (Int.repr 24) tint)
                                                              tuint) tuint)
                                                          (Ecast
                                                            (Ebinop Oshl
                                                              (Ebinop Oand
                                                                (Ecast
                                                                  (Econst_int (Int.repr 0) tint)
                                                                  tuint)
                                                                (Ebinop Osub
                                                                  (Ebinop Oshl
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (Econst_int (Int.repr 8) tint)
                                                                    tint)
                                                                  (Econst_int (Int.repr 1) tint)
                                                                  tint)
                                                                tuint)
                                                              (Econst_int (Int.repr 16) tint)
                                                              tuint) tuint)
                                                          tuint)
                                                        (Ecast
                                                          (Ebinop Oshl
                                                            (Ebinop Oand
                                                              (Ecast
                                                                (Econst_int (Int.repr 0) tint)
                                                                tuint)
                                                              (Ebinop Osub
                                                                (Ebinop Oshl
                                                                  (Econst_int (Int.repr 1) tint)
                                                                  (Econst_int (Int.repr 16) tint)
                                                                  tint)
                                                                (Econst_int (Int.repr 1) tint)
                                                                tint) tuint)
                                                            (Econst_int (Int.repr 0) tint)
                                                            tuint) tuint)
                                                        tuint))
                                                    (Sassign
                                                      (Efield
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar __g__5 (tptr (Tunion __549 noattr)))
                                                            (Tunion __549 noattr))
                                                          _words
                                                          (Tstruct __547 noattr))
                                                        _w1 tuint)
                                                      (Ecast
                                                        (Evar _dl_ia_text_end (tarray (Tunion __549 noattr) 0))
                                                        tuint))))
                                                (Ssequence
                                                  (Scall None
                                                    (Evar _print_course_number
                                                    (Tfunction nil tvoid
                                                      cc_default)) nil)
                                                  (Ssequence
                                                    (Ssequence
                                                      (Ssequence
                                                        (Ssequence
                                                          (Sset _t'12
                                                            (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                                                          (Sassign
                                                            (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                                                            (Ebinop Oadd
                                                              (Etempvar _t'12 (tptr (Tunion __549 noattr)))
                                                              (Econst_int (Int.repr 1) tint)
                                                              (tptr (Tunion __549 noattr)))))
                                                        (Sset __g__6
                                                          (Ecast
                                                            (Etempvar _t'12 (tptr (Tunion __549 noattr)))
                                                            (tptr (Tunion __549 noattr)))))
                                                      (Ssequence
                                                        (Sassign
                                                          (Efield
                                                            (Efield
                                                              (Ederef
                                                                (Etempvar __g__6 (tptr (Tunion __549 noattr)))
                                                                (Tunion __549 noattr))
                                                              _words
                                                              (Tstruct __547 noattr))
                                                            _w0 tuint)
                                                          (Ebinop Oor
                                                            (Ebinop Oor
                                                              (Ecast
                                                                (Ebinop Oshl
                                                                  (Ebinop Oand
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 222) tint)
                                                                    tuint)
                                                                    (Ebinop Osub
                                                                    (Ebinop Oshl
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (Econst_int (Int.repr 8) tint)
                                                                    tint)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    tuint)
                                                                  (Econst_int (Int.repr 24) tint)
                                                                  tuint)
                                                                tuint)
                                                              (Ecast
                                                                (Ebinop Oshl
                                                                  (Ebinop Oand
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tuint)
                                                                    (Ebinop Osub
                                                                    (Ebinop Oshl
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (Econst_int (Int.repr 8) tint)
                                                                    tint)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    tuint)
                                                                  (Econst_int (Int.repr 16) tint)
                                                                  tuint)
                                                                tuint) tuint)
                                                            (Ecast
                                                              (Ebinop Oshl
                                                                (Ebinop Oand
                                                                  (Ecast
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tuint)
                                                                  (Ebinop Osub
                                                                    (Ebinop Oshl
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (Econst_int (Int.repr 16) tint)
                                                                    tint)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                  tuint)
                                                                (Econst_int (Int.repr 0) tint)
                                                                tuint) tuint)
                                                            tuint))
                                                        (Sassign
                                                          (Efield
                                                            (Efield
                                                              (Ederef
                                                                (Etempvar __g__6 (tptr (Tunion __549 noattr)))
                                                                (Tunion __549 noattr))
                                                              _words
                                                              (Tstruct __547 noattr))
                                                            _w1 tuint)
                                                          (Ecast
                                                            (Evar _dl_menu_ia8_text_begin (tarray tuchar 0))
                                                            tuint))))
                                                    (Ssequence
                                                      (Ssequence
                                                        (Ssequence
                                                          (Ssequence
                                                            (Sset _t'13
                                                              (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                                                            (Sassign
                                                              (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                                                              (Ebinop Oadd
                                                                (Etempvar _t'13 (tptr (Tunion __549 noattr)))
                                                                (Econst_int (Int.repr 1) tint)
                                                                (tptr (Tunion __549 noattr)))))
                                                          (Sset __g__7
                                                            (Ecast
                                                              (Etempvar _t'13 (tptr (Tunion __549 noattr)))
                                                              (tptr (Tunion __549 noattr)))))
                                                        (Ssequence
                                                          (Sassign
                                                            (Efield
                                                              (Efield
                                                                (Ederef
                                                                  (Etempvar __g__7 (tptr (Tunion __549 noattr)))
                                                                  (Tunion __549 noattr))
                                                                _words
                                                                (Tstruct __547 noattr))
                                                              _w0 tuint)
                                                            (Ecast
                                                              (Ebinop Oshl
                                                                (Ebinop Oand
                                                                  (Ecast
                                                                    (Econst_int (Int.repr 251) tint)
                                                                    tuint)
                                                                  (Ebinop Osub
                                                                    (Ebinop Oshl
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (Econst_int (Int.repr 8) tint)
                                                                    tint)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                  tuint)
                                                                (Econst_int (Int.repr 24) tint)
                                                                tuint) tuint))
                                                          (Sassign
                                                            (Efield
                                                              (Efield
                                                                (Ederef
                                                                  (Etempvar __g__7 (tptr (Tunion __549 noattr)))
                                                                  (Tunion __549 noattr))
                                                                _words
                                                                (Tstruct __547 noattr))
                                                              _w1 tuint)
                                                            (Ecast
                                                              (Ebinop Oor
                                                                (Ebinop Oor
                                                                  (Ebinop Oor
                                                                    (Ecast
                                                                    (Ebinop Oshl
                                                                    (Ebinop Oand
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tuint)
                                                                    (Ebinop Osub
                                                                    (Ebinop Oshl
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (Econst_int (Int.repr 8) tint)
                                                                    tint)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    tuint)
                                                                    (Econst_int (Int.repr 24) tint)
                                                                    tuint)
                                                                    tuint)
                                                                    (Ecast
                                                                    (Ebinop Oshl
                                                                    (Ebinop Oand
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tuint)
                                                                    (Ebinop Osub
                                                                    (Ebinop Oshl
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (Econst_int (Int.repr 8) tint)
                                                                    tint)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    tuint)
                                                                    (Econst_int (Int.repr 16) tint)
                                                                    tuint)
                                                                    tuint)
                                                                    tuint)
                                                                  (Ecast
                                                                    (Ebinop Oshl
                                                                    (Ebinop Oand
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tuint)
                                                                    (Ebinop Osub
                                                                    (Ebinop Oshl
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (Econst_int (Int.repr 8) tint)
                                                                    tint)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    tuint)
                                                                    (Econst_int (Int.repr 8) tint)
                                                                    tuint)
                                                                    tuint)
                                                                  tuint)
                                                                (Ecast
                                                                  (Ebinop Oshl
                                                                    (Ebinop Oand
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 255) tint)
                                                                    tuint)
                                                                    (Ebinop Osub
                                                                    (Ebinop Oshl
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (Econst_int (Int.repr 8) tint)
                                                                    tint)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    tuint)
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tuint)
                                                                  tuint)
                                                                tuint) tuint))))
                                                      (Ssequence
                                                        (Ssequence
                                                          (Sset _t'19
                                                            (Evar _sVisibleStars tschar))
                                                          (Sifthenelse
                                                            (Ebinop One
                                                              (Etempvar _t'19 tschar)
                                                              (Econst_int (Int.repr 0) tint)
                                                              tint)
                                                            (Ssequence
                                                              (Ssequence
                                                                (Ssequence
                                                                  (Sset _t'20
                                                                    (Evar _gCurrCourseNum tshort))
                                                                  (Ssequence
                                                                    (Sset _t'21
                                                                    (Evar _sSelectedActIndex tschar))
                                                                    (Ssequence
                                                                    (Sset _t'22
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Etempvar _actNameTbl (tptr (tptr tuchar)))
                                                                    (Ebinop Oadd
                                                                    (Ebinop Omul
                                                                    (Ebinop Osub
                                                                    (Etempvar _t'20 tshort)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    (Econst_int (Int.repr 6) tint)
                                                                    tint)
                                                                    (Etempvar _t'21 tschar)
                                                                    tint)
                                                                    (tptr (tptr tuchar)))
                                                                    (tptr tuchar)))
                                                                    (Scall (Some _t'14)
                                                                    (Evar _segmented_to_virtual
                                                                    (Tfunction
                                                                    ((tptr tvoid) ::
                                                                    nil)
                                                                    (tptr tvoid)
                                                                    cc_default))
                                                                    ((Etempvar _t'22 (tptr tuchar)) ::
                                                                    nil)))))
                                                                (Sset _selectedActName
                                                                  (Etempvar _t'14 (tptr tvoid))))
                                                              (Ssequence
                                                                (Ssequence
                                                                  (Scall (Some _t'15)
                                                                    (Evar _get_str_x_pos_from_center
                                                                    (Tfunction
                                                                    (tshort ::
                                                                    (tptr tuchar) ::
                                                                    tfloat ::
                                                                    nil)
                                                                    tshort
                                                                    cc_default))
                                                                    ((Econst_int (Int.repr 163) tint) ::
                                                                    (Etempvar _selectedActName (tptr tuchar)) ::
                                                                    (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat) ::
                                                                    nil))
                                                                  (Sset _actNameX
                                                                    (Ecast
                                                                    (Etempvar _t'15 tshort)
                                                                    tshort)))
                                                                (Scall None
                                                                  (Evar _print_menu_generic_string
                                                                  (Tfunction
                                                                    (tshort ::
                                                                    tshort ::
                                                                    (tptr tuchar) ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                                                  ((Etempvar _actNameX tshort) ::
                                                                   (Econst_int (Int.repr 81) tint) ::
                                                                   (Etempvar _selectedActName (tptr tuchar)) ::
                                                                   nil))))
                                                            Sskip))
                                                        (Ssequence
                                                          (Ssequence
                                                            (Sset _i
                                                              (Ecast
                                                                (Econst_int (Int.repr 1) tint)
                                                                tschar))
                                                            (Sloop
                                                              (Ssequence
                                                                (Ssequence
                                                                  (Sset _t'18
                                                                    (Evar _sVisibleStars tschar))
                                                                  (Sifthenelse
                                                                    (Ebinop Ole
                                                                    (Etempvar _i tschar)
                                                                    (Etempvar _t'18 tschar)
                                                                    tint)
                                                                    Sskip
                                                                    Sbreak))
                                                                (Ssequence
                                                                  (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _starNumbers (tarray tuchar 2))
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Etempvar _i tschar))
                                                                  (Ssequence
                                                                    (Sset _t'17
                                                                    (Evar _sVisibleStars tschar))
                                                                    (Scall None
                                                                    (Evar _print_menu_generic_string
                                                                    (Tfunction
                                                                    (tshort ::
                                                                    tshort ::
                                                                    (tptr tuchar) ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                                                    ((Ebinop Oadd
                                                                    (Ebinop Osub
                                                                    (Econst_int (Int.repr 122) tint)
                                                                    (Ebinop Omul
                                                                    (Ebinop Osub
                                                                    (Etempvar _t'17 tschar)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    (Econst_int (Int.repr 17) tint)
                                                                    tint)
                                                                    tint)
                                                                    (Ebinop Omul
                                                                    (Etempvar _i tschar)
                                                                    (Econst_int (Int.repr 34) tint)
                                                                    tint)
                                                                    tint) ::
                                                                    (Econst_int (Int.repr 38) tint) ::
                                                                    (Evar _starNumbers (tarray tuchar 2)) ::
                                                                    nil)))))
                                                              (Sset _i
                                                                (Ecast
                                                                  (Ebinop Oadd
                                                                    (Etempvar _i tschar)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                  tschar))))
                                                          (Ssequence
                                                            (Ssequence
                                                              (Ssequence
                                                                (Sset _t'16
                                                                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                                                                (Sassign
                                                                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                                                                  (Ebinop Oadd
                                                                    (Etempvar _t'16 (tptr (Tunion __549 noattr)))
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (tptr (Tunion __549 noattr)))))
                                                              (Sset __g__8
                                                                (Ecast
                                                                  (Etempvar _t'16 (tptr (Tunion __549 noattr)))
                                                                  (tptr (Tunion __549 noattr)))))
                                                            (Ssequence
                                                              (Sassign
                                                                (Efield
                                                                  (Efield
                                                                    (Ederef
                                                                    (Etempvar __g__8 (tptr (Tunion __549 noattr)))
                                                                    (Tunion __549 noattr))
                                                                    _words
                                                                    (Tstruct __547 noattr))
                                                                  _w0 tuint)
                                                                (Ebinop Oor
                                                                  (Ebinop Oor
                                                                    (Ecast
                                                                    (Ebinop Oshl
                                                                    (Ebinop Oand
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 222) tint)
                                                                    tuint)
                                                                    (Ebinop Osub
                                                                    (Ebinop Oshl
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (Econst_int (Int.repr 8) tint)
                                                                    tint)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    tuint)
                                                                    (Econst_int (Int.repr 24) tint)
                                                                    tuint)
                                                                    tuint)
                                                                    (Ecast
                                                                    (Ebinop Oshl
                                                                    (Ebinop Oand
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tuint)
                                                                    (Ebinop Osub
                                                                    (Ebinop Oshl
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (Econst_int (Int.repr 8) tint)
                                                                    tint)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    tuint)
                                                                    (Econst_int (Int.repr 16) tint)
                                                                    tuint)
                                                                    tuint)
                                                                    tuint)
                                                                  (Ecast
                                                                    (Ebinop Oshl
                                                                    (Ebinop Oand
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tuint)
                                                                    (Ebinop Osub
                                                                    (Ebinop Oshl
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (Econst_int (Int.repr 16) tint)
                                                                    tint)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    tuint)
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tuint)
                                                                    tuint)
                                                                  tuint))
                                                              (Sassign
                                                                (Efield
                                                                  (Efield
                                                                    (Ederef
                                                                    (Etempvar __g__8 (tptr (Tunion __549 noattr)))
                                                                    (Tunion __549 noattr))
                                                                    _words
                                                                    (Tstruct __547 noattr))
                                                                  _w1 tuint)
                                                                (Ecast
                                                                  (Evar _dl_menu_ia8_text_end (tarray tuchar 0))
                                                                  tuint)))))))))))))))))))))))))))))))))
|}.

Definition f_geo_act_selector_strings := {|
  fn_return := (tptr (Tunion __549 noattr));
  fn_callconv := cc_default;
  fn_params := ((_callContext, tshort) ::
                (_node, (tptr (Tstruct _GraphNode noattr))) ::
                (_context, (tptr tvoid)) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Oeq (Etempvar _callContext tshort)
                 (Econst_int (Int.repr 1) tint) tint)
    (Scall None
      (Evar _print_act_selector_strings (Tfunction nil tvoid cc_default))
      nil)
    Sskip)
  (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))))
|}.

Definition f_lvl_init_act_selector_values_and_stars := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_arg, tint) :: (_unused, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_stars, tuchar) :: (_t'2, tint) :: (_t'1, tuint) ::
               (_t'7, tshort) :: (_t'6, tshort) :: (_t'5, tshort) ::
               (_t'4, tshort) :: (_t'3, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'6 (Evar _gCurrSaveFileNum tshort))
      (Ssequence
        (Sset _t'7 (Evar _gCurrCourseNum tshort))
        (Scall (Some _t'1)
          (Evar _save_file_get_star_flags (Tfunction (tint :: tint :: nil)
                                            tuint cc_default))
          ((Ebinop Osub (Etempvar _t'6 tshort) (Econst_int (Int.repr 1) tint)
             tint) ::
           (Ebinop Osub (Etempvar _t'7 tshort) (Econst_int (Int.repr 1) tint)
             tint) :: nil))))
    (Sset _stars (Ecast (Etempvar _t'1 tuint) tuchar)))
  (Ssequence
    (Sassign (Evar _sLoadedActNum tschar) (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Sassign (Evar _sInitSelectedActNum tuchar)
        (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Sassign (Evar _sVisibleStars tschar) (Econst_int (Int.repr 0) tint))
        (Ssequence
          (Sassign (Evar _sActSelectorMenuTimer tint)
            (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'4 (Evar _gCurrSaveFileNum tshort))
                (Ssequence
                  (Sset _t'5 (Evar _gCurrCourseNum tshort))
                  (Scall (Some _t'2)
                    (Evar _save_file_get_course_star_count (Tfunction
                                                             (tint :: tint ::
                                                              nil) tint
                                                             cc_default))
                    ((Ebinop Osub (Etempvar _t'4 tshort)
                       (Econst_int (Int.repr 1) tint) tint) ::
                     (Ebinop Osub (Etempvar _t'5 tshort)
                       (Econst_int (Int.repr 1) tint) tint) :: nil))))
              (Sassign (Evar _sObtainedStars tuchar) (Etempvar _t'2 tint)))
            (Ssequence
              (Sifthenelse (Ebinop Oand (Etempvar _stars tuchar)
                             (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                               (Econst_int (Int.repr 6) tint) tint) tint)
                (Ssequence
                  (Sset _t'3 (Evar _sObtainedStars tuchar))
                  (Sassign (Evar _sObtainedStars tuchar)
                    (Ebinop Osub (Etempvar _t'3 tuchar)
                      (Econst_int (Int.repr 1) tint) tint)))
                Sskip)
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_lvl_update_obj_and_load_act_button_actions := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_arg, tint) :: (_unused, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) :: (_t'16, tushort) ::
               (_t'15, (tptr (Tstruct _Controller noattr))) ::
               (_t'14, tushort) ::
               (_t'13, (tptr (Tstruct _Controller noattr))) ::
               (_t'12, tushort) ::
               (_t'11, (tptr (Tstruct _Controller noattr))) ::
               (_t'10, tschar) :: (_t'9, tuchar) :: (_t'8, tschar) ::
               (_t'7, tuchar) :: (_t'6, tschar) :: (_t'5, tint) ::
               (_t'4, tint) :: (_t'3, tschar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5 (Evar _sActSelectorMenuTimer tint))
    (Sifthenelse (Ebinop Ogt (Etempvar _t'5 tint)
                   (Econst_int (Int.repr 10) tint) tint)
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'13
              (Evar _gPlayer3Controller (tptr (Tstruct _Controller noattr))))
            (Ssequence
              (Sset _t'14
                (Efield
                  (Ederef
                    (Etempvar _t'13 (tptr (Tstruct _Controller noattr)))
                    (Tstruct _Controller noattr)) _buttonPressed tushort))
              (Sifthenelse (Ebinop Oand (Etempvar _t'14 tushort)
                             (Econst_int (Int.repr 32768) tint) tint)
                (Sset _t'1 (Econst_int (Int.repr 1) tint))
                (Ssequence
                  (Sset _t'15
                    (Evar _gPlayer3Controller (tptr (Tstruct _Controller noattr))))
                  (Ssequence
                    (Sset _t'16
                      (Efield
                        (Ederef
                          (Etempvar _t'15 (tptr (Tstruct _Controller noattr)))
                          (Tstruct _Controller noattr)) _buttonPressed
                        tushort))
                    (Sset _t'1
                      (Ecast
                        (Ebinop Oand (Etempvar _t'16 tushort)
                          (Econst_int (Int.repr 4096) tint) tint) tbool)))))))
          (Sifthenelse (Etempvar _t'1 tint)
            (Sset _t'2 (Econst_int (Int.repr 1) tint))
            (Ssequence
              (Sset _t'11
                (Evar _gPlayer3Controller (tptr (Tstruct _Controller noattr))))
              (Ssequence
                (Sset _t'12
                  (Efield
                    (Ederef
                      (Etempvar _t'11 (tptr (Tstruct _Controller noattr)))
                      (Tstruct _Controller noattr)) _buttonPressed tushort))
                (Sset _t'2
                  (Ecast
                    (Ebinop Oand (Etempvar _t'12 tushort)
                      (Econst_int (Int.repr 16384) tint) tint) tbool))))))
        (Sifthenelse (Etempvar _t'2 tint)
          (Ssequence
            (Scall None
              (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil)
                                  tvoid cc_default))
              ((Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 7) tint) tuint)
                         (Econst_int (Int.repr 28) tint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 36) tint) tuint)
                         (Econst_int (Int.repr 16) tint) tuint) tuint)
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 255) tint) tuint)
                       (Econst_int (Int.repr 8) tint) tuint) tuint)
                   (Econst_int (Int.repr 128) tint) tuint)
                 (Econst_int (Int.repr 1) tint) tuint) ::
               (Evar _gGlobalSoundSource (tarray tfloat 3)) :: nil))
            (Ssequence
              (Ssequence
                (Sset _t'7 (Evar _sInitSelectedActNum tuchar))
                (Ssequence
                  (Sset _t'8 (Evar _sSelectedActIndex tschar))
                  (Sifthenelse (Ebinop Oge (Etempvar _t'7 tuchar)
                                 (Ebinop Oadd (Etempvar _t'8 tschar)
                                   (Econst_int (Int.repr 1) tint) tint) tint)
                    (Ssequence
                      (Sset _t'10 (Evar _sSelectedActIndex tschar))
                      (Sassign (Evar _sLoadedActNum tschar)
                        (Ebinop Oadd (Etempvar _t'10 tschar)
                          (Econst_int (Int.repr 1) tint) tint)))
                    (Ssequence
                      (Sset _t'9 (Evar _sInitSelectedActNum tuchar))
                      (Sassign (Evar _sLoadedActNum tschar)
                        (Etempvar _t'9 tuchar))))))
              (Ssequence
                (Sset _t'6 (Evar _sSelectedActIndex tschar))
                (Sassign (Evar _gDialogCourseActNum tschar)
                  (Ebinop Oadd (Etempvar _t'6 tschar)
                    (Econst_int (Int.repr 1) tint) tint)))))
          Sskip))
      Sskip))
  (Ssequence
    (Scall None (Evar _area_update_objects (Tfunction nil tvoid cc_default))
      nil)
    (Ssequence
      (Ssequence
        (Sset _t'4 (Evar _sActSelectorMenuTimer tint))
        (Sassign (Evar _sActSelectorMenuTimer tint)
          (Ebinop Oadd (Etempvar _t'4 tint) (Econst_int (Int.repr 1) tint)
            tint)))
      (Ssequence
        (Sset _t'3 (Evar _sLoadedActNum tschar))
        (Sreturn (Some (Etempvar _t'3 tschar)))))))
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
 Composite __469 Struct
   (Member_plain _flag tuchar :: Member_plain _v (tarray tuchar 3) :: nil)
   noattr ::
 Composite __510 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _par I32 Unsigned noattr 8 false ::
    Member_bitfield _len I32 Unsigned noattr 16 false ::
    Member_plain _addr tuint :: nil)
   noattr ::
 Composite __512 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad I32 Signed noattr 24 false ::
    Member_plain _tri (Tstruct __469 noattr) :: nil)
   noattr ::
 Composite __514 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad1 I32 Signed noattr 24 false ::
    Member_bitfield _pad2 I32 Signed noattr 24 false ::
    Member_bitfield _param I8 Unsigned noattr 8 false :: nil)
   noattr ::
 Composite __516 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad0 I32 Signed noattr 8 false ::
    Member_bitfield _mw_index I32 Signed noattr 8 false ::
    Member_bitfield _number I32 Signed noattr 8 false ::
    Member_bitfield _pad1 I32 Signed noattr 8 false ::
    Member_bitfield _base I32 Signed noattr 24 false :: nil)
   noattr ::
 Composite __518 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad0 I32 Signed noattr 8 false ::
    Member_bitfield _sft I32 Signed noattr 8 false ::
    Member_bitfield _len I32 Signed noattr 8 false ::
    Member_bitfield _data I32 Unsigned noattr 32 false :: nil)
   noattr ::
 Composite __520 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad0 I32 Signed noattr 8 false ::
    Member_bitfield _sft I32 Signed noattr 8 false ::
    Member_bitfield _len I32 Signed noattr 8 false ::
    Member_bitfield _data I32 Unsigned noattr 32 false :: nil)
   noattr ::
 Composite __522 Struct
   (Member_plain _cmd tuchar :: Member_plain _lodscale tuchar ::
    Member_plain _tile tuchar :: Member_plain _on tuchar ::
    Member_plain _s tushort :: Member_plain _t tushort :: nil)
   noattr ::
 Composite __524 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad I32 Signed noattr 24 false ::
    Member_plain _line (Tstruct __469 noattr) :: nil)
   noattr ::
 Composite __526 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad1 I32 Signed noattr 24 false ::
    Member_plain _pad2 tshort :: Member_plain _scale tshort :: nil)
   noattr ::
 Composite __528 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _fmt I32 Unsigned noattr 3 false ::
    Member_bitfield _siz I32 Unsigned noattr 2 false ::
    Member_bitfield _pad I32 Unsigned noattr 7 false ::
    Member_bitfield _wd I32 Unsigned noattr 12 false ::
    Member_plain _dram tuint :: nil)
   noattr ::
 Composite __530 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _muxs0 I32 Unsigned noattr 24 false ::
    Member_bitfield _muxs1 I32 Unsigned noattr 32 false :: nil)
   noattr ::
 Composite __532 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_plain _pad tuchar :: Member_plain _prim_min_level tuchar ::
    Member_plain _prim_level tuchar :: Member_plain _color tuint :: nil)
   noattr ::
 Composite __534 Struct
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
 Composite __536 Struct
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
 Composite __538 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _sl I32 Unsigned noattr 12 false ::
    Member_bitfield _tl I32 Unsigned noattr 12 false ::
    Member_bitfield _pad I32 Signed noattr 5 false ::
    Member_bitfield _tile I32 Unsigned noattr 3 false ::
    Member_bitfield _sh I32 Unsigned noattr 12 false ::
    Member_bitfield _th I32 Unsigned noattr 12 false :: nil)
   noattr ::
 Composite __547 Struct
   (Member_plain _w0 tuint :: Member_plain _w1 tuint :: nil)
   noattr ::
 Composite __549 Union
   (Member_plain _words (Tstruct __547 noattr) ::
    Member_plain _dma (Tstruct __510 noattr) ::
    Member_plain _tri (Tstruct __512 noattr) ::
    Member_plain _line (Tstruct __524 noattr) ::
    Member_plain _popmtx (Tstruct __514 noattr) ::
    Member_plain _segment (Tstruct __516 noattr) ::
    Member_plain _setothermodeH (Tstruct __520 noattr) ::
    Member_plain _setothermodeL (Tstruct __518 noattr) ::
    Member_plain _texture (Tstruct __522 noattr) ::
    Member_plain _perspnorm (Tstruct __526 noattr) ::
    Member_plain _setimg (Tstruct __528 noattr) ::
    Member_plain _setcombine (Tstruct __530 noattr) ::
    Member_plain _setcolor (Tstruct __532 noattr) ::
    Member_plain _fillrect (Tstruct __534 noattr) ::
    Member_plain _settile (Tstruct __536 noattr) ::
    Member_plain _loadtile (Tstruct __538 noattr) ::
    Member_plain _settilesize (Tstruct __538 noattr) ::
    Member_plain _loadtlut (Tstruct __538 noattr) ::
    Member_plain _force_structure_alignment tlong :: nil)
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
 Composite __764 Union
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
    Member_plain _rawData (Tunion __764 noattr) ::
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
 Composite __769 Struct
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
    Member_plain _normal (Tstruct __769 noattr) ::
    Member_plain _originOffset tfloat ::
    Member_plain _object (tptr (Tstruct _Object noattr)) :: nil)
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
     cc_default)) ::
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
 (_gGlobalSoundSource, Gvar v_gGlobalSoundSource) ::
 (_play_sound,
   Gfun(External (EF_external "play_sound"
                   (mksignature (AST.Xint :: AST.Xptr :: nil) AST.Xvoid
                     cc_default)) (tint :: (tptr tfloat) :: nil) tvoid
     cc_default)) ::
 (_bhvActSelectorStarType, Gvar v_bhvActSelectorStarType) ::
 (_segmented_to_virtual,
   Gfun(External (EF_external "segmented_to_virtual"
                   (mksignature (AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr tvoid) :: nil) (tptr tvoid) cc_default)) ::
 (_gCurrCourseNum, Gvar v_gCurrCourseNum) ::
 (_gCurrSaveFileNum, Gvar v_gCurrSaveFileNum) ::
 (_area_update_objects,
   Gfun(External (EF_external "area_update_objects"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) :: (_gDisplayListHead, Gvar v_gDisplayListHead) ::
 (_gPlayer3Controller, Gvar v_gPlayer3Controller) ::
 (_gDialogCourseActNum, Gvar v_gDialogCourseActNum) ::
 (_create_dl_translation_matrix,
   Gfun(External (EF_external "create_dl_translation_matrix"
                   (mksignature
                     (AST.Xint8signed :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xsingle :: nil) AST.Xvoid cc_default))
     (tschar :: tfloat :: tfloat :: tfloat :: nil) tvoid cc_default)) ::
 (_create_dl_ortho_matrix,
   Gfun(External (EF_external "create_dl_ortho_matrix"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_print_generic_string,
   Gfun(External (EF_external "print_generic_string"
                   (mksignature
                     (AST.Xint16signed :: AST.Xint16signed :: AST.Xptr ::
                      nil) AST.Xvoid cc_default))
     (tshort :: tshort :: (tptr tuchar) :: nil) tvoid cc_default)) ::
 (_print_hud_lut_string,
   Gfun(External (EF_external "print_hud_lut_string"
                   (mksignature
                     (AST.Xint8signed :: AST.Xint16signed ::
                      AST.Xint16signed :: AST.Xptr :: nil) AST.Xvoid
                     cc_default))
     (tschar :: tshort :: tshort :: (tptr tuchar) :: nil) tvoid cc_default)) ::
 (_print_menu_generic_string,
   Gfun(External (EF_external "print_menu_generic_string"
                   (mksignature
                     (AST.Xint16signed :: AST.Xint16signed :: AST.Xptr ::
                      nil) AST.Xvoid cc_default))
     (tshort :: tshort :: (tptr tuchar) :: nil) tvoid cc_default)) ::
 (_handle_menu_scrolling,
   Gfun(External (EF_external "handle_menu_scrolling"
                   (mksignature
                     (AST.Xint8signed :: AST.Xptr :: AST.Xint8signed ::
                      AST.Xint8signed :: nil) AST.Xvoid cc_default))
     (tschar :: (tptr tschar) :: tschar :: tschar :: nil) tvoid cc_default)) ::
 (_get_str_x_pos_from_center,
   Gfun(External (EF_external "get_str_x_pos_from_center"
                   (mksignature
                     (AST.Xint16signed :: AST.Xptr :: AST.Xsingle :: nil)
                     AST.Xint16signed cc_default))
     (tshort :: (tptr tuchar) :: tfloat :: nil) tshort cc_default)) ::
 (_print_hud_my_score_coins,
   Gfun(External (EF_external "print_hud_my_score_coins"
                   (mksignature
                     (AST.Xint :: AST.Xint8signed :: AST.Xint8signed ::
                      AST.Xint16signed :: AST.Xint16signed :: nil) AST.Xvoid
                     cc_default))
     (tint :: tschar :: tschar :: tshort :: tshort :: nil) tvoid cc_default)) ::
 (_int_to_str,
   Gfun(External (EF_external "int_to_str"
                   (mksignature (AST.Xint :: AST.Xptr :: nil) AST.Xvoid
                     cc_default)) (tint :: (tptr tuchar) :: nil) tvoid
     cc_default)) ::
 (_spawn_object_abs_with_rot,
   Gfun(External (EF_external "spawn_object_abs_with_rot"
                   (mksignature
                     (AST.Xptr :: AST.Xint16signed :: AST.Xint :: AST.Xptr ::
                      AST.Xint16signed :: AST.Xint16signed ::
                      AST.Xint16signed :: AST.Xint16signed ::
                      AST.Xint16signed :: AST.Xint16signed :: nil) AST.Xptr
                     cc_default))
     ((tptr (Tstruct _Object noattr)) :: tshort :: tuint :: (tptr tuint) ::
      tshort :: tshort :: tshort :: tshort :: tshort :: tshort :: nil)
     (tptr (Tstruct _Object noattr)) cc_default)) ::
 (_cur_obj_scale,
   Gfun(External (EF_external "cur_obj_scale"
                   (mksignature (AST.Xsingle :: nil) AST.Xvoid cc_default))
     (tfloat :: nil) tvoid cc_default)) ::
 (_gCurrentObject, Gvar v_gCurrentObject) ::
 (_save_file_get_course_star_count,
   Gfun(External (EF_external "save_file_get_course_star_count"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xint
                     cc_default)) (tint :: tint :: nil) tint cc_default)) ::
 (_save_file_get_star_flags,
   Gfun(External (EF_external "save_file_get_star_flags"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xint
                     cc_default)) (tint :: tint :: nil) tuint cc_default)) ::
 (_save_file_get_course_coin_score,
   Gfun(External (EF_external "save_file_get_course_coin_score"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xint
                     cc_default)) (tint :: tint :: nil) tint cc_default)) ::
 (_seg2_course_name_table, Gvar v_seg2_course_name_table) ::
 (_seg2_act_name_table, Gvar v_seg2_act_name_table) ::
 (_dl_rgba16_text_begin, Gvar v_dl_rgba16_text_begin) ::
 (_dl_rgba16_text_end, Gvar v_dl_rgba16_text_end) ::
 (_dl_ia_text_begin, Gvar v_dl_ia_text_begin) ::
 (_dl_ia_text_end, Gvar v_dl_ia_text_end) ::
 (_dl_menu_ia8_text_begin, Gvar v_dl_menu_ia8_text_begin) ::
 (_dl_menu_ia8_text_end, Gvar v_dl_menu_ia8_text_end) ::
 (_dl_menu_rgba16_wood_course, Gvar v_dl_menu_rgba16_wood_course) ::
 (_sStarSelectorModels, Gvar v_sStarSelectorModels) ::
 (_sLoadedActNum, Gvar v_sLoadedActNum) ::
 (_sObtainedStars, Gvar v_sObtainedStars) ::
 (_sVisibleStars, Gvar v_sVisibleStars) ::
 (_sInitSelectedActNum, Gvar v_sInitSelectedActNum) ::
 (_sSelectedActIndex, Gvar v_sSelectedActIndex) ::
 (_sSelectableStarIndex, Gvar v_sSelectableStarIndex) ::
 (_sActSelectorMenuTimer, Gvar v_sActSelectorMenuTimer) ::
 (_bhv_act_selector_star_type_loop, Gfun(Internal f_bhv_act_selector_star_type_loop)) ::
 (_render_100_coin_star, Gfun(Internal f_render_100_coin_star)) ::
 (_bhv_act_selector_init, Gfun(Internal f_bhv_act_selector_init)) ::
 (_bhv_act_selector_loop, Gfun(Internal f_bhv_act_selector_loop)) ::
 (_print_course_number, Gfun(Internal f_print_course_number)) ::
 (_print_act_selector_strings, Gfun(Internal f_print_act_selector_strings)) ::
 (_geo_act_selector_strings, Gfun(Internal f_geo_act_selector_strings)) ::
 (_lvl_init_act_selector_values_and_stars, Gfun(Internal f_lvl_init_act_selector_values_and_stars)) ::
 (_lvl_update_obj_and_load_act_button_actions, Gfun(Internal f_lvl_update_obj_and_load_act_button_actions)) ::
 nil).

Definition public_idents : list ident :=
(_lvl_update_obj_and_load_act_button_actions ::
 _lvl_init_act_selector_values_and_stars :: _geo_act_selector_strings ::
 _print_act_selector_strings :: _print_course_number ::
 _bhv_act_selector_loop :: _bhv_act_selector_init :: _render_100_coin_star ::
 _bhv_act_selector_star_type_loop :: _dl_menu_rgba16_wood_course ::
 _dl_menu_ia8_text_end :: _dl_menu_ia8_text_begin :: _dl_ia_text_end ::
 _dl_ia_text_begin :: _dl_rgba16_text_end :: _dl_rgba16_text_begin ::
 _seg2_act_name_table :: _seg2_course_name_table ::
 _save_file_get_course_coin_score :: _save_file_get_star_flags ::
 _save_file_get_course_star_count :: _gCurrentObject :: _cur_obj_scale ::
 _spawn_object_abs_with_rot :: _int_to_str :: _print_hud_my_score_coins ::
 _get_str_x_pos_from_center :: _handle_menu_scrolling ::
 _print_menu_generic_string :: _print_hud_lut_string ::
 _print_generic_string :: _create_dl_ortho_matrix ::
 _create_dl_translation_matrix :: _gDialogCourseActNum ::
 _gPlayer3Controller :: _gDisplayListHead :: _area_update_objects ::
 _gCurrSaveFileNum :: _gCurrCourseNum :: _segmented_to_virtual ::
 _bhvActSelectorStarType :: _play_sound :: _gGlobalSoundSource ::
 ___builtin_debug :: ___builtin_sync_fetch_and_add ::
 ___builtin_atomic_compare_exchange :: ___builtin_atomic_load ::
 ___builtin_atomic_exchange :: ___builtin_nop :: ___builtin_bsel ::
 ___builtin_uisel64 :: ___builtin_isel64 :: ___builtin_uisel ::
 ___builtin_isel :: ___builtin_return_address :: ___builtin_call_frame ::
 ___builtin_mr :: ___builtin_set_spr64 :: ___builtin_get_spr64 ::
 ___builtin_set_spr :: ___builtin_get_spr :: ___builtin_dcbz ::
 ___builtin_icbtls :: ___builtin_dcbtls :: ___builtin_prefetch ::
 ___builtin_icbi :: ___builtin_dcbi :: ___builtin_dcbf :: ___builtin_trap ::
 ___builtin_mbar :: ___builtin_lwsync :: ___builtin_isync ::
 ___builtin_sync :: ___builtin_eieio :: ___builtin_write64_reversed ::
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
