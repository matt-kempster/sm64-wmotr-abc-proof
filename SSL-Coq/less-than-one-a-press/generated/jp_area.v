(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_JP
   Source:          src/game/area.c
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_JP=1 -DF3D_OLD=1
   Link hygiene:    private __stringlit_N atoms prefixed with jp_area
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
  Definition source_file := "build/pinned-sm64/src/game/area.c".
  Definition normalized := true.
End Info.

Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _Area : ident := $"Area".
Definition _Camera : ident := $"Camera".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _CreditsEntry : ident := $"CreditsEntry".
Definition _D_8032CE74 : ident := $"D_8032CE74".
Definition _D_8032CE78 : ident := $"D_8032CE78".
Definition _D_8032CF00 : ident := $"D_8032CF00".
Definition _D_8033A160 : ident := $"D_8033A160".
Definition _GraphNode : ident := $"GraphNode".
Definition _GraphNodeObject : ident := $"GraphNodeObject".
Definition _GraphNodeRoot : ident := $"GraphNodeRoot".
Definition _InstantWarp : ident := $"InstantWarp".
Definition _Object : ident := $"Object".
Definition _ObjectNode : ident := $"ObjectNode".
Definition _ObjectWarpNode : ident := $"ObjectWarpNode".
Definition _SpawnInfo : ident := $"SpawnInfo".
Definition _Surface : ident := $"Surface".
Definition _UnusedArea28 : ident := $"UnusedArea28".
Definition _WarpNode : ident := $"WarpNode".
Definition _WarpTransition : ident := $"WarpTransition".
Definition _WarpTransitionData : ident := $"WarpTransitionData".
Definition _Waypoint : ident := $"Waypoint".
Definition _Whirlpool : ident := $"Whirlpool".
Definition __538 : ident := $"_538".
Definition __540 : ident := $"_540".
Definition __574 : ident := $"_574".
Definition __576 : ident := $"_576".
Definition __791 : ident := $"_791".
Definition __796 : ident := $"_796".
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
Definition ___stringlit_1 : ident := $"__jp_area_stringlit_1".
Definition ___stringlit_2 : ident := $"__jp_area_stringlit_2".
Definition ___stringlit_3 : ident := $"__jp_area_stringlit_3".
Definition __g : ident := $"_g".
Definition __g__1 : ident := $"_g__1".
Definition __g__2 : ident := $"_g__2".
Definition __g__3 : ident := $"_g__3".
Definition __g__4 : ident := $"_g__4".
Definition _a : ident := $"a".
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
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
Definition _areaCenX : ident := $"areaCenX".
Definition _areaCenY : ident := $"areaCenY".
Definition _areaCenZ : ident := $"areaCenZ".
Definition _areaFlags : ident := $"areaFlags".
Definition _areaIndex : ident := $"areaIndex".
Definition _area_get_warp_node : ident := $"area_get_warp_node".
Definition _area_get_warp_node_from_params : ident := $"area_get_warp_node_from_params".
Definition _area_update_objects : ident := $"area_update_objects".
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
Definition _b : ident := $"b".
Definition _behavior : ident := $"behavior".
Definition _behaviorArg : ident := $"behaviorArg".
Definition _behaviorScript : ident := $"behaviorScript".
Definition _bhvAirborneDeathWarp : ident := $"bhvAirborneDeathWarp".
Definition _bhvAirborneStarCollectWarp : ident := $"bhvAirborneStarCollectWarp".
Definition _bhvAirborneWarp : ident := $"bhvAirborneWarp".
Definition _bhvDeathWarp : ident := $"bhvDeathWarp".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvDoorWarp : ident := $"bhvDoorWarp".
Definition _bhvExitPodiumWarp : ident := $"bhvExitPodiumWarp".
Definition _bhvFadingWarp : ident := $"bhvFadingWarp".
Definition _bhvFlyingWarp : ident := $"bhvFlyingWarp".
Definition _bhvHardAirKnockBackWarp : ident := $"bhvHardAirKnockBackWarp".
Definition _bhvInstantActiveWarp : ident := $"bhvInstantActiveWarp".
Definition _bhvLaunchDeathWarp : ident := $"bhvLaunchDeathWarp".
Definition _bhvLaunchStarCollectWarp : ident := $"bhvLaunchStarCollectWarp".
Definition _bhvPaintingDeathWarp : ident := $"bhvPaintingDeathWarp".
Definition _bhvPaintingStarCollectWarp : ident := $"bhvPaintingStarCollectWarp".
Definition _bhvSpinAirborneCircleWarp : ident := $"bhvSpinAirborneCircleWarp".
Definition _bhvSpinAirborneWarp : ident := $"bhvSpinAirborneWarp".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _bhvStar : ident := $"bhvStar".
Definition _bhvSwimmingWarp : ident := $"bhvSwimmingWarp".
Definition _bhvWarp : ident := $"bhvWarp".
Definition _bhvWarpPipe : ident := $"bhvWarpPipe".
Definition _blue : ident := $"blue".
Definition _c : ident := $"c".
Definition _camera : ident := $"camera".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _change_area : ident := $"change_area".
Definition _children : ident := $"children".
Definition _clear_area_graph_nodes : ident := $"clear_area_graph_nodes".
Definition _clear_areas : ident := $"clear_areas".
Definition _clear_framebuffer : ident := $"clear_framebuffer".
Definition _clear_viewport : ident := $"clear_viewport".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _cutscene : ident := $"cutscene".
Definition _d : ident := $"d".
Definition _data : ident := $"data".
Definition _defMode : ident := $"defMode".
Definition _delay : ident := $"delay".
Definition _destArea : ident := $"destArea".
Definition _destLevel : ident := $"destLevel".
Definition _destNode : ident := $"destNode".
Definition _dialog : ident := $"dialog".
Definition _displacement : ident := $"displacement".
Definition _do_cutscene_handler : ident := $"do_cutscene_handler".
Definition _doorStatus : ident := $"doorStatus".
Definition _e : ident := $"e".
Definition _endTexRadius : ident := $"endTexRadius".
Definition _endTexX : ident := $"endTexX".
Definition _endTexY : ident := $"endTexY".
Definition _filler1 : ident := $"filler1".
Definition _filler2 : ident := $"filler2".
Definition _flags : ident := $"flags".
Definition _focus : ident := $"focus".
Definition _force : ident := $"force".
Definition _force_structure_alignment : ident := $"force_structure_alignment".
Definition _gAreaData : ident := $"gAreaData".
Definition _gAreaUpdateCounter : ident := $"gAreaUpdateCounter".
Definition _gAreas : ident := $"gAreas".
Definition _gControllerBits : ident := $"gControllerBits".
Definition _gCurrActNum : ident := $"gCurrActNum".
Definition _gCurrAreaIndex : ident := $"gCurrAreaIndex".
Definition _gCurrCourseNum : ident := $"gCurrCourseNum".
Definition _gCurrCreditsEntry : ident := $"gCurrCreditsEntry".
Definition _gCurrLevelNum : ident := $"gCurrLevelNum".
Definition _gCurrSaveFileNum : ident := $"gCurrSaveFileNum".
Definition _gCurrentArea : ident := $"gCurrentArea".
Definition _gDisplayListHead : ident := $"gDisplayListHead".
Definition _gFBSetColor : ident := $"gFBSetColor".
Definition _gGlobalTimer : ident := $"gGlobalTimer".
Definition _gLoadedGraphNodes : ident := $"gLoadedGraphNodes".
Definition _gMarioObject : ident := $"gMarioObject".
Definition _gMarioSpawnInfo : ident := $"gMarioSpawnInfo".
Definition _gMenuOptSelectIndex : ident := $"gMenuOptSelectIndex".
Definition _gObjParentGraphNode : ident := $"gObjParentGraphNode".
Definition _gPlayerSpawnInfos : ident := $"gPlayerSpawnInfos".
Definition _gSaveOptSelectIndex : ident := $"gSaveOptSelectIndex".
Definition _gSavedCourseNum : ident := $"gSavedCourseNum".
Definition _gWarpTransBlue : ident := $"gWarpTransBlue".
Definition _gWarpTransDelay : ident := $"gWarpTransDelay".
Definition _gWarpTransFBSetColor : ident := $"gWarpTransFBSetColor".
Definition _gWarpTransGreen : ident := $"gWarpTransGreen".
Definition _gWarpTransRed : ident := $"gWarpTransRed".
Definition _gWarpTransition : ident := $"gWarpTransition".
Definition _geo_call_global_function_nodes : ident := $"geo_call_global_function_nodes".
Definition _geo_process_root : ident := $"geo_process_root".
Definition _get_mario_spawn_type : ident := $"get_mario_spawn_type".
Definition _gfx : ident := $"gfx".
Definition _green : ident := $"green".
Definition _header : ident := $"header".
Definition _height : ident := $"height".
Definition _hitboxDownOffset : ident := $"hitboxDownOffset".
Definition _hitboxHeight : ident := $"hitboxHeight".
Definition _hitboxRadius : ident := $"hitboxRadius".
Definition _hurtboxHeight : ident := $"hurtboxHeight".
Definition _hurtboxRadius : ident := $"hurtboxRadius".
Definition _i : ident := $"i".
Definition _id : ident := $"id".
Definition _index : ident := $"index".
Definition _instantWarps : ident := $"instantWarps".
Definition _isActive : ident := $"isActive".
Definition _length : ident := $"length".
Definition _levelNum : ident := $"levelNum".
Definition _load_area : ident := $"load_area".
Definition _load_area_terrain : ident := $"load_area_terrain".
Definition _load_mario_area : ident := $"load_mario_area".
Definition _load_obj_warp_nodes : ident := $"load_obj_warp_nodes".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _macroObjects : ident := $"macroObjects".
Definition _main : ident := $"main".
Definition _make_viewport_clip_rect : ident := $"make_viewport_clip_rect".
Definition _marioAngle : ident := $"marioAngle".
Definition _marioPos : ident := $"marioPos".
Definition _mode : ident := $"mode".
Definition _model : ident := $"model".
Definition _musicParam : ident := $"musicParam".
Definition _musicParam2 : ident := $"musicParam2".
Definition _next : ident := $"next".
Definition _nextYaw : ident := $"nextYaw".
Definition _node : ident := $"node".
Definition _normal : ident := $"normal".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _numViews : ident := $"numViews".
Definition _o : ident := $"o".
Definition _object : ident := $"object".
Definition _objectSpawnInfos : ident := $"objectSpawnInfos".
Definition _originOffset : ident := $"originOffset".
Definition _override_viewport_and_clip : ident := $"override_viewport_and_clip".
Definition _paintingWarpNodes : ident := $"paintingWarpNodes".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _pauseRendering : ident := $"pauseRendering".
Definition _platform : ident := $"platform".
Definition _play_transition : ident := $"play_transition".
Definition _play_transition_after_delay : ident := $"play_transition_after_delay".
Definition _pos : ident := $"pos".
Definition _prev : ident := $"prev".
Definition _prevObj : ident := $"prevObj".
Definition _print_displaying_credits_entry : ident := $"print_displaying_credits_entry".
Definition _print_intro_text : ident := $"print_intro_text".
Definition _print_text_centered : ident := $"print_text_centered".
Definition _rawData : ident := $"rawData".
Definition _red : ident := $"red".
Definition _render_game : ident := $"render_game".
Definition _render_hud : ident := $"render_hud".
Definition _render_menus_and_dialogs : ident := $"render_menus_and_dialogs".
Definition _render_screen_transition : ident := $"render_screen_transition".
Definition _render_text_labels : ident := $"render_text_labels".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _room : ident := $"room".
Definition _sSpawnTypeFromWarpBhv : ident := $"sSpawnTypeFromWarpBhv".
Definition _sWarpBhvSpawnTable : ident := $"sWarpBhvSpawnTable".
Definition _scale : ident := $"scale".
Definition _set_warp_transition_rgb : ident := $"set_warp_transition_rgb".
Definition _sharedChild : ident := $"sharedChild".
Definition _sp1C : ident := $"sp1C".
Definition _sp20 : ident := $"sp20".
Definition _sp24 : ident := $"sp24".
Definition _sp6 : ident := $"sp6".
Definition _spawn_objects_from_info : ident := $"spawn_objects_from_info".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
Definition _startTexRadius : ident := $"startTexRadius".
Definition _startTexX : ident := $"startTexX".
Definition _startTexY : ident := $"startTexY".
Definition _stop_sounds_in_continuous_banks : ident := $"stop_sounds_in_continuous_banks".
Definition _strength : ident := $"strength".
Definition _surfaceRooms : ident := $"surfaceRooms".
Definition _terrainData : ident := $"terrainData".
Definition _terrainType : ident := $"terrainType".
Definition _texTimer : ident := $"texTimer".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _time : ident := $"time".
Definition _transType : ident := $"transType".
Definition _transform : ident := $"transform".
Definition _type : ident := $"type".
Definition _unk00 : ident := $"unk00".
Definition _unk02 : ident := $"unk02".
Definition _unk04 : ident := $"unk04".
Definition _unk06 : ident := $"unk06".
Definition _unk08 : ident := $"unk08".
Definition _unk0C : ident := $"unk0C".
Definition _unk15 : ident := $"unk15".
Definition _unk4C : ident := $"unk4C".
Definition _unload_area : ident := $"unload_area".
Definition _unload_mario_area : ident := $"unload_mario_area".
Definition _unload_objects_from_area : ident := $"unload_objects_from_area".
Definition _unused : ident := $"unused".
Definition _unused1 : ident := $"unused1".
Definition _unused2 : ident := $"unused2".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _unusedVec1 : ident := $"unusedVec1".
Definition _update_objects : ident := $"update_objects".
Definition _upperY : ident := $"upperY".
Definition _values : ident := $"values".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _views : ident := $"views".
Definition _virtual_to_segmented : ident := $"virtual_to_segmented".
Definition _vp : ident := $"vp".
Definition _vscale : ident := $"vscale".
Definition _vtrans : ident := $"vtrans".
Definition _w0 : ident := $"w0".
Definition _w1 : ident := $"w1".
Definition _warpNodes : ident := $"warpNodes".
Definition _warpTransitionRGBA16 : ident := $"warpTransitionRGBA16".
Definition _whirlpools : ident := $"whirlpools".
Definition _width : ident := $"width".
Definition _words : ident := $"words".
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
Definition _t'4 : ident := 131%positive.
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v___stringlit_3 := {|
  gvar_info := (tarray tuchar 14);
  gvar_init := (Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 67) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 76) ::
                Init_int8 (Int.repr 76) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_2 := {|
  gvar_info := (tarray tuchar 6);
  gvar_init := (Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_1 := {|
  gvar_info := (tarray tuchar 6);
  gvar_init := (Init_int8 (Int.repr 80) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_gObjParentGraphNode := {|
  gvar_info := (Tstruct _GraphNode noattr);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvExitPodiumWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvFadingWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvWarpPipe := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvDoorWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvInstantActiveWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvAirborneWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvHardAirKnockBackWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSpinAirborneCircleWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvDeathWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSpinAirborneWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvFlyingWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvPaintingStarCollectWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvPaintingDeathWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvAirborneDeathWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvAirborneStarCollectWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvLaunchStarCollectWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvLaunchDeathWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSwimmingWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvStar := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_gDisplayListHead := {|
  gvar_info := (tptr (Tunion __576 noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gControllerBits := {|
  gvar_info := tuchar;
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

Definition v_gMarioObject := {|
  gvar_info := (tptr (Tstruct _Object noattr));
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

Definition v_gPlayerSpawnInfos := {|
  gvar_info := (tarray (Tstruct _SpawnInfo noattr) 1);
  gvar_init := (Init_space 32 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_8033A160 := {|
  gvar_info := (tarray (tptr (Tstruct _GraphNode noattr)) 256);
  gvar_init := (Init_space 1024 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAreaData := {|
  gvar_info := (tarray (Tstruct _Area noattr) 8);
  gvar_init := (Init_space 480 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gWarpTransition := {|
  gvar_info := (Tstruct _WarpTransition noattr);
  gvar_init := (Init_space 22 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrCourseNum := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrActNum := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrAreaIndex := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSavedCourseNum := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMenuOptSelectIndex := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSaveOptSelectIndex := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMarioSpawnInfo := {|
  gvar_info := (tptr (Tstruct _SpawnInfo noattr));
  gvar_init := (Init_addrof _gPlayerSpawnInfos (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gLoadedGraphNodes := {|
  gvar_info := (tptr (tptr (Tstruct _GraphNode noattr)));
  gvar_init := (Init_addrof _D_8033A160 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAreas := {|
  gvar_info := (tptr (Tstruct _Area noattr));
  gvar_init := (Init_addrof _gAreaData (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrentArea := {|
  gvar_info := (tptr (Tstruct _Area noattr));
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrCreditsEntry := {|
  gvar_info := (tptr (Tstruct _CreditsEntry noattr));
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_8032CE74 := {|
  gvar_info := (tptr (Tunion __540 noattr));
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_8032CE78 := {|
  gvar_info := (tptr (Tunion __540 noattr));
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gWarpTransDelay := {|
  gvar_info := tshort;
  gvar_init := (Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gFBSetColor := {|
  gvar_info := tuint;
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gWarpTransFBSetColor := {|
  gvar_info := tuint;
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gWarpTransRed := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gWarpTransGreen := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gWarpTransBlue := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrSaveFileNum := {|
  gvar_info := tshort;
  gvar_init := (Init_int16 (Int.repr 1) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrLevelNum := {|
  gvar_info := tshort;
  gvar_init := (Init_int16 (Int.repr 1) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sWarpBhvSpawnTable := {|
  gvar_info := (tarray (tptr tuint) 20);
  gvar_init := (Init_addrof _bhvDoorWarp (Ptrofs.repr 0) ::
                Init_addrof _bhvStar (Ptrofs.repr 0) ::
                Init_addrof _bhvExitPodiumWarp (Ptrofs.repr 0) ::
                Init_addrof _bhvWarp (Ptrofs.repr 0) ::
                Init_addrof _bhvWarpPipe (Ptrofs.repr 0) ::
                Init_addrof _bhvFadingWarp (Ptrofs.repr 0) ::
                Init_addrof _bhvInstantActiveWarp (Ptrofs.repr 0) ::
                Init_addrof _bhvAirborneWarp (Ptrofs.repr 0) ::
                Init_addrof _bhvHardAirKnockBackWarp (Ptrofs.repr 0) ::
                Init_addrof _bhvSpinAirborneCircleWarp (Ptrofs.repr 0) ::
                Init_addrof _bhvDeathWarp (Ptrofs.repr 0) ::
                Init_addrof _bhvSpinAirborneWarp (Ptrofs.repr 0) ::
                Init_addrof _bhvFlyingWarp (Ptrofs.repr 0) ::
                Init_addrof _bhvSwimmingWarp (Ptrofs.repr 0) ::
                Init_addrof _bhvPaintingStarCollectWarp (Ptrofs.repr 0) ::
                Init_addrof _bhvPaintingDeathWarp (Ptrofs.repr 0) ::
                Init_addrof _bhvAirborneStarCollectWarp (Ptrofs.repr 0) ::
                Init_addrof _bhvAirborneDeathWarp (Ptrofs.repr 0) ::
                Init_addrof _bhvLaunchStarCollectWarp (Ptrofs.repr 0) ::
                Init_addrof _bhvLaunchDeathWarp (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSpawnTypeFromWarpBhv := {|
  gvar_info := (tarray tuchar 20);
  gvar_init := (Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 3) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 3) :: Init_int8 (Int.repr 4) ::
                Init_int8 (Int.repr 16) :: Init_int8 (Int.repr 18) ::
                Init_int8 (Int.repr 19) :: Init_int8 (Int.repr 20) ::
                Init_int8 (Int.repr 21) :: Init_int8 (Int.repr 22) ::
                Init_int8 (Int.repr 23) :: Init_int8 (Int.repr 17) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 33) ::
                Init_int8 (Int.repr 34) :: Init_int8 (Int.repr 35) ::
                Init_int8 (Int.repr 36) :: Init_int8 (Int.repr 37) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_8032CF00 := {|
  gvar_info := (Tunion __540 noattr);
  gvar_init := (Init_int16 (Int.repr 640) :: Init_int16 (Int.repr 480) ::
                Init_int16 (Int.repr 511) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 640) :: Init_int16 (Int.repr 480) ::
                Init_int16 (Int.repr 511) :: Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_override_viewport_and_clip := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_a, (tptr (Tunion __540 noattr))) ::
                (_b, (tptr (Tunion __540 noattr))) :: (_c, tuchar) ::
                (_d, tuchar) :: (_e, tuchar) :: nil);
  fn_vars := nil;
  fn_temps := ((_sp6, tushort) :: nil);
  fn_body :=
(Ssequence
  (Sset _sp6
    (Ecast
      (Ebinop Oor
        (Ebinop Oor
          (Ebinop Oor
            (Ebinop Oshl
              (Ebinop Oshr (Etempvar _c tuchar)
                (Econst_int (Int.repr 3) tint) tint)
              (Econst_int (Int.repr 11) tint) tint)
            (Ebinop Oshl
              (Ebinop Oshr (Etempvar _d tuchar)
                (Econst_int (Int.repr 3) tint) tint)
              (Econst_int (Int.repr 6) tint) tint) tint)
          (Ebinop Oshl
            (Ebinop Oshr (Etempvar _e tuchar) (Econst_int (Int.repr 3) tint)
              tint) (Econst_int (Int.repr 1) tint) tint) tint)
        (Econst_int (Int.repr 1) tint) tint) tushort))
  (Ssequence
    (Sassign (Evar _gFBSetColor tuint)
      (Ebinop Oor
        (Ebinop Oshl (Etempvar _sp6 tushort) (Econst_int (Int.repr 16) tint)
          tint) (Etempvar _sp6 tushort) tint))
    (Ssequence
      (Sassign (Evar _D_8032CE74 (tptr (Tunion __540 noattr)))
        (Etempvar _a (tptr (Tunion __540 noattr))))
      (Sassign (Evar _D_8032CE78 (tptr (Tunion __540 noattr)))
        (Etempvar _b (tptr (Tunion __540 noattr)))))))
|}.

Definition f_set_warp_transition_rgb := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_red, tuchar) :: (_green, tuchar) :: (_blue, tuchar) :: nil);
  fn_vars := nil;
  fn_temps := ((_warpTransitionRGBA16, tushort) :: nil);
  fn_body :=
(Ssequence
  (Sset _warpTransitionRGBA16
    (Ecast
      (Ebinop Oor
        (Ebinop Oor
          (Ebinop Oor
            (Ebinop Oshl
              (Ebinop Oshr (Etempvar _red tuchar)
                (Econst_int (Int.repr 3) tint) tint)
              (Econst_int (Int.repr 11) tint) tint)
            (Ebinop Oshl
              (Ebinop Oshr (Etempvar _green tuchar)
                (Econst_int (Int.repr 3) tint) tint)
              (Econst_int (Int.repr 6) tint) tint) tint)
          (Ebinop Oshl
            (Ebinop Oshr (Etempvar _blue tuchar)
              (Econst_int (Int.repr 3) tint) tint)
            (Econst_int (Int.repr 1) tint) tint) tint)
        (Econst_int (Int.repr 1) tint) tint) tushort))
  (Ssequence
    (Sassign (Evar _gWarpTransFBSetColor tuint)
      (Ebinop Oor
        (Ebinop Oshl (Etempvar _warpTransitionRGBA16 tushort)
          (Econst_int (Int.repr 16) tint) tint)
        (Etempvar _warpTransitionRGBA16 tushort) tint))
    (Ssequence
      (Sassign (Evar _gWarpTransRed tuchar) (Etempvar _red tuchar))
      (Ssequence
        (Sassign (Evar _gWarpTransGreen tuchar) (Etempvar _green tuchar))
        (Sassign (Evar _gWarpTransBlue tuchar) (Etempvar _blue tuchar))))))
|}.

Definition f_print_intro_text := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, tuchar) :: (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _gGlobalTimer tuint))
  (Sifthenelse (Ebinop Olt
                 (Ebinop Oand (Etempvar _t'1 tuint)
                   (Econst_int (Int.repr 31) tint) tuint)
                 (Econst_int (Int.repr 20) tint) tint)
    (Ssequence
      (Sset _t'2 (Evar _gControllerBits tuchar))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tuchar)
                     (Econst_int (Int.repr 0) tint) tint)
        (Scall None
          (Evar _print_text_centered (Tfunction
                                       (tint :: tint :: (tptr tuchar) :: nil)
                                       tvoid cc_default))
          ((Ebinop Odiv (Econst_int (Int.repr 320) tint)
             (Econst_int (Int.repr 2) tint) tint) ::
           (Econst_int (Int.repr 20) tint) ::
           (Evar ___stringlit_3 (tarray tuchar 14)) :: nil))
        (Ssequence
          (Scall None
            (Evar _print_text_centered (Tfunction
                                         (tint :: tint :: (tptr tuchar) ::
                                          nil) tvoid cc_default))
            ((Econst_int (Int.repr 60) tint) ::
             (Econst_int (Int.repr 38) tint) ::
             (Evar ___stringlit_1 (tarray tuchar 6)) :: nil))
          (Scall None
            (Evar _print_text_centered (Tfunction
                                         (tint :: tint :: (tptr tuchar) ::
                                          nil) tvoid cc_default))
            ((Econst_int (Int.repr 60) tint) ::
             (Econst_int (Int.repr 20) tint) ::
             (Evar ___stringlit_2 (tarray tuchar 6)) :: nil)))))
    Sskip))
|}.

Definition f_get_mario_spawn_type := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_behavior, (tptr tuint)) ::
               (_t'1, (tptr tvoid)) :: (_t'4, (tptr tuint)) ::
               (_t'3, tuchar) :: (_t'2, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'4
        (Efield
          (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
            (Tstruct _Object noattr)) _behavior (tptr tuint)))
      (Scall (Some _t'1)
        (Evar _virtual_to_segmented (Tfunction (tuint :: (tptr tvoid) :: nil)
                                      (tptr tvoid) cc_default))
        ((Econst_int (Int.repr 19) tint) :: (Etempvar _t'4 (tptr tuint)) ::
         nil)))
    (Sset _behavior (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Ssequence
      (Sset _i (Econst_int (Int.repr 0) tint))
      (Sloop
        (Ssequence
          (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                         (Econst_int (Int.repr 20) tint) tint)
            Sskip
            Sbreak)
          (Ssequence
            (Sset _t'2
              (Ederef
                (Ebinop Oadd
                  (Evar _sWarpBhvSpawnTable (tarray (tptr tuint) 20))
                  (Etempvar _i tint) (tptr (tptr tuint))) (tptr tuint)))
            (Sifthenelse (Ebinop Oeq (Etempvar _behavior (tptr tuint))
                           (Etempvar _t'2 (tptr tuint)) tint)
              (Ssequence
                (Sset _t'3
                  (Ederef
                    (Ebinop Oadd
                      (Evar _sSpawnTypeFromWarpBhv (tarray tuchar 20))
                      (Etempvar _i tint) (tptr tuchar)) tuchar))
                (Sreturn (Some (Etempvar _t'3 tuchar))))
              Sskip)))
        (Sset _i
          (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint)
            tint))))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_area_get_warp_node := {|
  fn_return := (tptr (Tstruct _ObjectWarpNode noattr));
  fn_callconv := cc_default;
  fn_params := ((_id, tuchar) :: nil);
  fn_vars := nil;
  fn_temps := ((_node, (tptr (Tstruct _ObjectWarpNode noattr))) ::
               (_t'2, (tptr (Tstruct _Area noattr))) :: (_t'1, tuchar) ::
               nil);
  fn_body :=
(Ssequence
  (Sset _node (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'2 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
        (Sset _node
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _Area noattr)))
              (Tstruct _Area noattr)) _warpNodes
            (tptr (Tstruct _ObjectWarpNode noattr)))))
      (Sloop
        (Ssequence
          (Sifthenelse (Ebinop One
                         (Etempvar _node (tptr (Tstruct _ObjectWarpNode noattr)))
                         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                         tint)
            Sskip
            Sbreak)
          (Ssequence
            (Sset _t'1
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _node (tptr (Tstruct _ObjectWarpNode noattr)))
                    (Tstruct _ObjectWarpNode noattr)) _node
                  (Tstruct _WarpNode noattr)) _id tuchar))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tuchar)
                           (Etempvar _id tuchar) tint)
              Sbreak
              Sskip)))
        (Sset _node
          (Efield
            (Ederef (Etempvar _node (tptr (Tstruct _ObjectWarpNode noattr)))
              (Tstruct _ObjectWarpNode noattr)) _next
            (tptr (Tstruct _ObjectWarpNode noattr))))))
    (Sreturn (Some (Etempvar _node (tptr (Tstruct _ObjectWarpNode noattr)))))))
|}.

Definition f_area_get_warp_node_from_params := {|
  fn_return := (tptr (Tstruct _ObjectWarpNode noattr));
  fn_callconv := cc_default;
  fn_params := ((_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_id, tuchar) ::
               (_t'1, (tptr (Tstruct _ObjectWarpNode noattr))) ::
               (_t'2, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _rawData (Tunion __791 noattr))
            _asS32 (tarray tint 80)) (Econst_int (Int.repr 64) tint)
          (tptr tint)) tint))
    (Sset _id
      (Ecast
        (Ebinop Oshr
          (Ebinop Oand (Etempvar _t'2 tint)
            (Econst_int (Int.repr 16711680) tint) tint)
          (Econst_int (Int.repr 16) tint) tint) tuchar)))
  (Ssequence
    (Scall (Some _t'1)
      (Evar _area_get_warp_node (Tfunction (tuchar :: nil)
                                  (tptr (Tstruct _ObjectWarpNode noattr))
                                  cc_default))
      ((Etempvar _id tuchar) :: nil))
    (Sreturn (Some (Etempvar _t'1 (tptr (Tstruct _ObjectWarpNode noattr)))))))
|}.

Definition f_load_obj_warp_nodes := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_sp24, (tptr (Tstruct _ObjectWarpNode noattr))) ::
               (_sp20, (tptr (Tstruct _Object noattr))) ::
               (_sp1C, (tptr (Tstruct _Object noattr))) :: (_t'4, tuint) ::
               (_t'3, tint) ::
               (_t'2, (tptr (Tstruct _ObjectWarpNode noattr))) ::
               (_t'1, (tptr (Tstruct _Object noattr))) ::
               (_t'8, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'7, tshort) ::
               (_t'6, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'5, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8
      (Efield (Evar _gObjParentGraphNode (Tstruct _GraphNode noattr))
        _children (tptr (Tstruct _GraphNode noattr))))
    (Sset _sp20
      (Ecast (Etempvar _t'8 (tptr (Tstruct _GraphNode noattr)))
        (tptr (Tstruct _Object noattr)))))
  (Sloop
    (Ssequence
      (Sset _sp1C (Etempvar _sp20 (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Ssequence
          (Sset _t'7
            (Efield
              (Ederef (Etempvar _sp1C (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _activeFlags tshort))
          (Sifthenelse (Ebinop One (Etempvar _t'7 tshort)
                         (Econst_int (Int.repr 0) tint) tint)
            (Ssequence
              (Scall (Some _t'4)
                (Evar _get_mario_spawn_type (Tfunction
                                              ((tptr (Tstruct _Object noattr)) ::
                                               nil) tuint cc_default))
                ((Etempvar _sp1C (tptr (Tstruct _Object noattr))) :: nil))
              (Sset _t'3
                (Ecast
                  (Ebinop One (Etempvar _t'4 tuint)
                    (Econst_int (Int.repr 0) tint) tint) tbool)))
            (Sset _t'3 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'3 tint)
          (Ssequence
            (Ssequence
              (Scall (Some _t'2)
                (Evar _area_get_warp_node_from_params (Tfunction
                                                        ((tptr (Tstruct _Object noattr)) ::
                                                         nil)
                                                        (tptr (Tstruct _ObjectWarpNode noattr))
                                                        cc_default))
                ((Etempvar _sp1C (tptr (Tstruct _Object noattr))) :: nil))
              (Sset _sp24
                (Etempvar _t'2 (tptr (Tstruct _ObjectWarpNode noattr)))))
            (Sifthenelse (Ebinop One
                           (Etempvar _sp24 (tptr (Tstruct _ObjectWarpNode noattr)))
                           (Ecast (Econst_int (Int.repr 0) tint)
                             (tptr tvoid)) tint)
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _sp24 (tptr (Tstruct _ObjectWarpNode noattr)))
                    (Tstruct _ObjectWarpNode noattr)) _object
                  (tptr (Tstruct _Object noattr)))
                (Etempvar _sp1C (tptr (Tstruct _Object noattr))))
              Sskip))
          Sskip)))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'6
            (Efield
              (Efield
                (Efield
                  (Efield
                    (Ederef (Etempvar _sp20 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _header
                    (Tstruct _ObjectNode noattr)) _gfx
                  (Tstruct _GraphNodeObject noattr)) _node
                (Tstruct _GraphNode noattr)) _next
              (tptr (Tstruct _GraphNode noattr))))
          (Sset _t'1
            (Ecast
              (Ecast (Etempvar _t'6 (tptr (Tstruct _GraphNode noattr)))
                (tptr (Tstruct _Object noattr)))
              (tptr (Tstruct _Object noattr)))))
        (Sset _sp20 (Etempvar _t'1 (tptr (Tstruct _Object noattr)))))
      (Ssequence
        (Sset _t'5
          (Efield (Evar _gObjParentGraphNode (Tstruct _GraphNode noattr))
            _children (tptr (Tstruct _GraphNode noattr))))
        (Sifthenelse (Ebinop One
                       (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
                       (Ecast
                         (Etempvar _t'5 (tptr (Tstruct _GraphNode noattr)))
                         (tptr (Tstruct _Object noattr))) tint)
          Sskip
          Sbreak)))))
|}.

Definition f_clear_areas := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_t'1, (tptr (Tstruct _SpawnInfo noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _gCurrentArea (tptr (Tstruct _Area noattr)))
    (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Sassign
      (Efield (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
        _isActive tuchar) (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Sassign
        (Efield (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
          _pauseRendering tuchar) (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Ssequence
          (Sset _t'1
            (Evar _gMarioSpawnInfo (tptr (Tstruct _SpawnInfo noattr))))
          (Sassign
            (Efield
              (Ederef (Etempvar _t'1 (tptr (Tstruct _SpawnInfo noattr)))
                (Tstruct _SpawnInfo noattr)) _areaIndex tschar)
            (Eunop Oneg (Econst_int (Int.repr 1) tint) tint)))
        (Ssequence
          (Sset _i (Econst_int (Int.repr 0) tint))
          (Sloop
            (Ssequence
              (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                             (Econst_int (Int.repr 8) tint) tint)
                Sskip
                Sbreak)
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
                        (Etempvar _i tint) (tptr (Tstruct _Area noattr)))
                      (Tstruct _Area noattr)) _index tschar)
                  (Etempvar _i tint))
                (Ssequence
                  (Sassign
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
                          (Etempvar _i tint) (tptr (Tstruct _Area noattr)))
                        (Tstruct _Area noattr)) _flags tschar)
                    (Econst_int (Int.repr 0) tint))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
                            (Etempvar _i tint) (tptr (Tstruct _Area noattr)))
                          (Tstruct _Area noattr)) _terrainType tushort)
                      (Econst_int (Int.repr 0) tint))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Ederef
                            (Ebinop Oadd
                              (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
                              (Etempvar _i tint)
                              (tptr (Tstruct _Area noattr)))
                            (Tstruct _Area noattr)) _unk04
                          (tptr (Tstruct _GraphNodeRoot noattr)))
                        (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
                      (Ssequence
                        (Sassign
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
                                (Etempvar _i tint)
                                (tptr (Tstruct _Area noattr)))
                              (Tstruct _Area noattr)) _terrainData
                            (tptr tshort))
                          (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
                        (Ssequence
                          (Sassign
                            (Efield
                              (Ederef
                                (Ebinop Oadd
                                  (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
                                  (Etempvar _i tint)
                                  (tptr (Tstruct _Area noattr)))
                                (Tstruct _Area noattr)) _surfaceRooms
                              (tptr tschar))
                            (Ecast (Econst_int (Int.repr 0) tint)
                              (tptr tvoid)))
                          (Ssequence
                            (Sassign
                              (Efield
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
                                    (Etempvar _i tint)
                                    (tptr (Tstruct _Area noattr)))
                                  (Tstruct _Area noattr)) _macroObjects
                                (tptr tshort))
                              (Ecast (Econst_int (Int.repr 0) tint)
                                (tptr tvoid)))
                            (Ssequence
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
                                      (Etempvar _i tint)
                                      (tptr (Tstruct _Area noattr)))
                                    (Tstruct _Area noattr)) _warpNodes
                                  (tptr (Tstruct _ObjectWarpNode noattr)))
                                (Ecast (Econst_int (Int.repr 0) tint)
                                  (tptr tvoid)))
                              (Ssequence
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _Area noattr)))
                                      (Tstruct _Area noattr))
                                    _paintingWarpNodes
                                    (tptr (Tstruct _WarpNode noattr)))
                                  (Ecast (Econst_int (Int.repr 0) tint)
                                    (tptr tvoid)))
                                (Ssequence
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
                                          (Etempvar _i tint)
                                          (tptr (Tstruct _Area noattr)))
                                        (Tstruct _Area noattr)) _instantWarps
                                      (tptr (Tstruct _InstantWarp noattr)))
                                    (Ecast (Econst_int (Int.repr 0) tint)
                                      (tptr tvoid)))
                                  (Ssequence
                                    (Sassign
                                      (Efield
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
                                            (Etempvar _i tint)
                                            (tptr (Tstruct _Area noattr)))
                                          (Tstruct _Area noattr))
                                        _objectSpawnInfos
                                        (tptr (Tstruct _SpawnInfo noattr)))
                                      (Ecast (Econst_int (Int.repr 0) tint)
                                        (tptr tvoid)))
                                    (Ssequence
                                      (Sassign
                                        (Efield
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
                                              (Etempvar _i tint)
                                              (tptr (Tstruct _Area noattr)))
                                            (Tstruct _Area noattr)) _camera
                                          (tptr (Tstruct _Camera noattr)))
                                        (Ecast (Econst_int (Int.repr 0) tint)
                                          (tptr tvoid)))
                                      (Ssequence
                                        (Sassign
                                          (Efield
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
                                                (Etempvar _i tint)
                                                (tptr (Tstruct _Area noattr)))
                                              (Tstruct _Area noattr)) _unused
                                            (tptr (Tstruct _UnusedArea28 noattr)))
                                          (Ecast
                                            (Econst_int (Int.repr 0) tint)
                                            (tptr tvoid)))
                                        (Ssequence
                                          (Sassign
                                            (Ederef
                                              (Ebinop Oadd
                                                (Efield
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
                                                      (Etempvar _i tint)
                                                      (tptr (Tstruct _Area noattr)))
                                                    (Tstruct _Area noattr))
                                                  _whirlpools
                                                  (tarray (tptr (Tstruct _Whirlpool noattr)) 2))
                                                (Econst_int (Int.repr 0) tint)
                                                (tptr (tptr (Tstruct _Whirlpool noattr))))
                                              (tptr (Tstruct _Whirlpool noattr)))
                                            (Ecast
                                              (Econst_int (Int.repr 0) tint)
                                              (tptr tvoid)))
                                          (Ssequence
                                            (Sassign
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Efield
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
                                                        (Etempvar _i tint)
                                                        (tptr (Tstruct _Area noattr)))
                                                      (Tstruct _Area noattr))
                                                    _whirlpools
                                                    (tarray (tptr (Tstruct _Whirlpool noattr)) 2))
                                                  (Econst_int (Int.repr 1) tint)
                                                  (tptr (tptr (Tstruct _Whirlpool noattr))))
                                                (tptr (Tstruct _Whirlpool noattr)))
                                              (Ecast
                                                (Econst_int (Int.repr 0) tint)
                                                (tptr tvoid)))
                                            (Ssequence
                                              (Sassign
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Efield
                                                      (Ederef
                                                        (Ebinop Oadd
                                                          (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
                                                          (Etempvar _i tint)
                                                          (tptr (Tstruct _Area noattr)))
                                                        (Tstruct _Area noattr))
                                                      _dialog
                                                      (tarray tuchar 2))
                                                    (Econst_int (Int.repr 0) tint)
                                                    (tptr tuchar)) tuchar)
                                                (Econst_int (Int.repr (-1)) tint))
                                              (Ssequence
                                                (Sassign
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Efield
                                                        (Ederef
                                                          (Ebinop Oadd
                                                            (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
                                                            (Etempvar _i tint)
                                                            (tptr (Tstruct _Area noattr)))
                                                          (Tstruct _Area noattr))
                                                        _dialog
                                                        (tarray tuchar 2))
                                                      (Econst_int (Int.repr 1) tint)
                                                      (tptr tuchar)) tuchar)
                                                  (Econst_int (Int.repr (-1)) tint))
                                                (Ssequence
                                                  (Sassign
                                                    (Efield
                                                      (Ederef
                                                        (Ebinop Oadd
                                                          (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
                                                          (Etempvar _i tint)
                                                          (tptr (Tstruct _Area noattr)))
                                                        (Tstruct _Area noattr))
                                                      _musicParam tushort)
                                                    (Econst_int (Int.repr 0) tint))
                                                  (Sassign
                                                    (Efield
                                                      (Ederef
                                                        (Ebinop Oadd
                                                          (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
                                                          (Etempvar _i tint)
                                                          (tptr (Tstruct _Area noattr)))
                                                        (Tstruct _Area noattr))
                                                      _musicParam2 tushort)
                                                    (Econst_int (Int.repr 0) tint)))))))))))))))))))))
            (Sset _i
              (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint)
                tint))))))))
|}.

Definition f_clear_area_graph_nodes := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_i, tint) ::
               (_t'5, (tptr (Tstruct _GraphNodeRoot noattr))) ::
               (_t'4, (tptr (Tstruct _Area noattr))) ::
               (_t'3, (tptr (Tstruct _Area noattr))) ::
               (_t'2, (tptr (Tstruct _GraphNodeRoot noattr))) ::
               (_t'1, (tptr (Tstruct _GraphNodeRoot noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
    (Sifthenelse (Ebinop One (Etempvar _t'3 (tptr (Tstruct _Area noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Ssequence
          (Sset _t'4 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
          (Ssequence
            (Sset _t'5
              (Efield
                (Ederef (Etempvar _t'4 (tptr (Tstruct _Area noattr)))
                  (Tstruct _Area noattr)) _unk04
                (tptr (Tstruct _GraphNodeRoot noattr))))
            (Scall None
              (Evar _geo_call_global_function_nodes (Tfunction
                                                      ((tptr (Tstruct _GraphNode noattr)) ::
                                                       tint :: nil) tvoid
                                                      cc_default))
              ((Eaddrof
                 (Efield
                   (Ederef
                     (Etempvar _t'5 (tptr (Tstruct _GraphNodeRoot noattr)))
                     (Tstruct _GraphNodeRoot noattr)) _node
                   (Tstruct _GraphNode noattr))
                 (tptr (Tstruct _GraphNode noattr))) ::
               (Econst_int (Int.repr 2) tint) :: nil))))
        (Ssequence
          (Sassign (Evar _gCurrentArea (tptr (Tstruct _Area noattr)))
            (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
          (Sassign
            (Efield (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
              _isActive tuchar) (Econst_int (Int.repr 0) tint))))
      Sskip))
  (Ssequence
    (Sset _i (Econst_int (Int.repr 0) tint))
    (Sloop
      (Ssequence
        (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                       (Econst_int (Int.repr 8) tint) tint)
          Sskip
          Sbreak)
        (Ssequence
          (Sset _t'1
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
                  (Etempvar _i tint) (tptr (Tstruct _Area noattr)))
                (Tstruct _Area noattr)) _unk04
              (tptr (Tstruct _GraphNodeRoot noattr))))
          (Sifthenelse (Ebinop One
                         (Etempvar _t'1 (tptr (Tstruct _GraphNodeRoot noattr)))
                         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                         tint)
            (Ssequence
              (Ssequence
                (Sset _t'2
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
                        (Etempvar _i tint) (tptr (Tstruct _Area noattr)))
                      (Tstruct _Area noattr)) _unk04
                    (tptr (Tstruct _GraphNodeRoot noattr))))
                (Scall None
                  (Evar _geo_call_global_function_nodes (Tfunction
                                                          ((tptr (Tstruct _GraphNode noattr)) ::
                                                           tint :: nil) tvoid
                                                          cc_default))
                  ((Eaddrof
                     (Efield
                       (Ederef
                         (Etempvar _t'2 (tptr (Tstruct _GraphNodeRoot noattr)))
                         (Tstruct _GraphNodeRoot noattr)) _node
                       (Tstruct _GraphNode noattr))
                     (tptr (Tstruct _GraphNode noattr))) ::
                   (Econst_int (Int.repr 4) tint) :: nil)))
              (Sassign
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
                      (Etempvar _i tint) (tptr (Tstruct _Area noattr)))
                    (Tstruct _Area noattr)) _unk04
                  (tptr (Tstruct _GraphNodeRoot noattr)))
                (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
            Sskip)))
      (Sset _i
        (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint) tint)))))
|}.

Definition f_load_area := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_index, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) ::
               (_t'19, (tptr (Tstruct _GraphNodeRoot noattr))) ::
               (_t'18, (tptr (Tstruct _Area noattr))) :: (_t'17, tschar) ::
               (_t'16, (tptr (Tstruct _Area noattr))) ::
               (_t'15, (tptr tshort)) ::
               (_t'14, (tptr (Tstruct _Area noattr))) ::
               (_t'13, (tptr tschar)) ::
               (_t'12, (tptr (Tstruct _Area noattr))) ::
               (_t'11, (tptr tshort)) ::
               (_t'10, (tptr (Tstruct _Area noattr))) ::
               (_t'9, (tptr tshort)) ::
               (_t'8, (tptr (Tstruct _Area noattr))) ::
               (_t'7, (tptr (Tstruct _SpawnInfo noattr))) ::
               (_t'6, (tptr (Tstruct _Area noattr))) ::
               (_t'5, (tptr (Tstruct _SpawnInfo noattr))) ::
               (_t'4, (tptr (Tstruct _Area noattr))) ::
               (_t'3, (tptr (Tstruct _GraphNodeRoot noattr))) ::
               (_t'2, (tptr (Tstruct _Area noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'18 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'18 (tptr (Tstruct _Area noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Sset _t'19
          (Efield
            (Ederef
              (Ebinop Oadd
                (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
                (Etempvar _index tint) (tptr (Tstruct _Area noattr)))
              (Tstruct _Area noattr)) _unk04
            (tptr (Tstruct _GraphNodeRoot noattr))))
        (Sset _t'1
          (Ecast
            (Ebinop One
              (Etempvar _t'19 (tptr (Tstruct _GraphNodeRoot noattr)))
              (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
            tbool)))
      (Sset _t'1 (Econst_int (Int.repr 0) tint))))
  (Sifthenelse (Etempvar _t'1 tint)
    (Ssequence
      (Sassign (Evar _gCurrentArea (tptr (Tstruct _Area noattr)))
        (Ebinop Oadd (Evar _gAreaData (tarray (Tstruct _Area noattr) 8))
          (Etempvar _index tint) (tptr (Tstruct _Area noattr))))
      (Ssequence
        (Ssequence
          (Sset _t'16 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
          (Ssequence
            (Sset _t'17
              (Efield
                (Ederef (Etempvar _t'16 (tptr (Tstruct _Area noattr)))
                  (Tstruct _Area noattr)) _index tschar))
            (Sassign (Evar _gCurrAreaIndex tshort) (Etempvar _t'17 tschar))))
        (Ssequence
          (Ssequence
            (Sset _t'8 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
            (Ssequence
              (Sset _t'9
                (Efield
                  (Ederef (Etempvar _t'8 (tptr (Tstruct _Area noattr)))
                    (Tstruct _Area noattr)) _terrainData (tptr tshort)))
              (Sifthenelse (Ebinop One (Etempvar _t'9 (tptr tshort))
                             (Ecast (Econst_int (Int.repr 0) tint)
                               (tptr tvoid)) tint)
                (Ssequence
                  (Sset _t'10
                    (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                  (Ssequence
                    (Sset _t'11
                      (Efield
                        (Ederef
                          (Etempvar _t'10 (tptr (Tstruct _Area noattr)))
                          (Tstruct _Area noattr)) _terrainData (tptr tshort)))
                    (Ssequence
                      (Sset _t'12
                        (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                      (Ssequence
                        (Sset _t'13
                          (Efield
                            (Ederef
                              (Etempvar _t'12 (tptr (Tstruct _Area noattr)))
                              (Tstruct _Area noattr)) _surfaceRooms
                            (tptr tschar)))
                        (Ssequence
                          (Sset _t'14
                            (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                          (Ssequence
                            (Sset _t'15
                              (Efield
                                (Ederef
                                  (Etempvar _t'14 (tptr (Tstruct _Area noattr)))
                                  (Tstruct _Area noattr)) _macroObjects
                                (tptr tshort)))
                            (Scall None
                              (Evar _load_area_terrain (Tfunction
                                                         (tshort ::
                                                          (tptr tshort) ::
                                                          (tptr tschar) ::
                                                          (tptr tshort) ::
                                                          nil) tvoid
                                                         cc_default))
                              ((Etempvar _index tint) ::
                               (Etempvar _t'11 (tptr tshort)) ::
                               (Etempvar _t'13 (tptr tschar)) ::
                               (Etempvar _t'15 (tptr tshort)) :: nil))))))))
                Sskip)))
          (Ssequence
            (Ssequence
              (Sset _t'4 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef (Etempvar _t'4 (tptr (Tstruct _Area noattr)))
                      (Tstruct _Area noattr)) _objectSpawnInfos
                    (tptr (Tstruct _SpawnInfo noattr))))
                (Sifthenelse (Ebinop One
                               (Etempvar _t'5 (tptr (Tstruct _SpawnInfo noattr)))
                               (Ecast (Econst_int (Int.repr 0) tint)
                                 (tptr tvoid)) tint)
                  (Ssequence
                    (Sset _t'6
                      (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                    (Ssequence
                      (Sset _t'7
                        (Efield
                          (Ederef
                            (Etempvar _t'6 (tptr (Tstruct _Area noattr)))
                            (Tstruct _Area noattr)) _objectSpawnInfos
                          (tptr (Tstruct _SpawnInfo noattr))))
                      (Scall None
                        (Evar _spawn_objects_from_info (Tfunction
                                                         (tint ::
                                                          (tptr (Tstruct _SpawnInfo noattr)) ::
                                                          nil) tvoid
                                                         cc_default))
                        ((Econst_int (Int.repr 0) tint) ::
                         (Etempvar _t'7 (tptr (Tstruct _SpawnInfo noattr))) ::
                         nil))))
                  Sskip)))
            (Ssequence
              (Scall None
                (Evar _load_obj_warp_nodes (Tfunction nil tvoid cc_default))
                nil)
              (Ssequence
                (Sset _t'2
                  (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                (Ssequence
                  (Sset _t'3
                    (Efield
                      (Ederef (Etempvar _t'2 (tptr (Tstruct _Area noattr)))
                        (Tstruct _Area noattr)) _unk04
                      (tptr (Tstruct _GraphNodeRoot noattr))))
                  (Scall None
                    (Evar _geo_call_global_function_nodes (Tfunction
                                                            ((tptr (Tstruct _GraphNode noattr)) ::
                                                             tint :: nil)
                                                            tvoid cc_default))
                    ((Eaddrof
                       (Efield
                         (Ederef
                           (Etempvar _t'3 (tptr (Tstruct _GraphNodeRoot noattr)))
                           (Tstruct _GraphNodeRoot noattr)) _node
                         (Tstruct _GraphNode noattr))
                       (tptr (Tstruct _GraphNode noattr))) ::
                     (Econst_int (Int.repr 3) tint) :: nil)))))))))
    Sskip))
|}.

Definition f_unload_area := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'6, tschar) :: (_t'5, (tptr (Tstruct _Area noattr))) ::
               (_t'4, (tptr (Tstruct _GraphNodeRoot noattr))) ::
               (_t'3, (tptr (Tstruct _Area noattr))) ::
               (_t'2, (tptr (Tstruct _Area noattr))) ::
               (_t'1, (tptr (Tstruct _Area noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
  (Sifthenelse (Ebinop One (Etempvar _t'1 (tptr (Tstruct _Area noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Ssequence
        (Sset _t'5 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _t'5 (tptr (Tstruct _Area noattr)))
                (Tstruct _Area noattr)) _index tschar))
          (Scall None
            (Evar _unload_objects_from_area (Tfunction (tint :: tint :: nil)
                                              tvoid cc_default))
            ((Econst_int (Int.repr 0) tint) :: (Etempvar _t'6 tschar) :: nil))))
      (Ssequence
        (Ssequence
          (Sset _t'3 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef (Etempvar _t'3 (tptr (Tstruct _Area noattr)))
                  (Tstruct _Area noattr)) _unk04
                (tptr (Tstruct _GraphNodeRoot noattr))))
            (Scall None
              (Evar _geo_call_global_function_nodes (Tfunction
                                                      ((tptr (Tstruct _GraphNode noattr)) ::
                                                       tint :: nil) tvoid
                                                      cc_default))
              ((Eaddrof
                 (Efield
                   (Ederef
                     (Etempvar _t'4 (tptr (Tstruct _GraphNodeRoot noattr)))
                     (Tstruct _GraphNodeRoot noattr)) _node
                   (Tstruct _GraphNode noattr))
                 (tptr (Tstruct _GraphNode noattr))) ::
               (Econst_int (Int.repr 2) tint) :: nil))))
        (Ssequence
          (Ssequence
            (Sset _t'2 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
            (Sassign
              (Efield
                (Ederef (Etempvar _t'2 (tptr (Tstruct _Area noattr)))
                  (Tstruct _Area noattr)) _flags tschar)
              (Econst_int (Int.repr 0) tint)))
          (Ssequence
            (Sassign (Evar _gCurrentArea (tptr (Tstruct _Area noattr)))
              (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
            (Sassign
              (Efield
                (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                _isActive tuchar) (Econst_int (Int.repr 0) tint))))))
    Sskip))
|}.

Definition f_load_mario_area := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'10, tschar) ::
               (_t'9, (tptr (Tstruct _SpawnInfo noattr))) ::
               (_t'8, tschar) :: (_t'7, (tptr (Tstruct _Area noattr))) ::
               (_t'6, (tptr (Tstruct _Area noattr))) ::
               (_t'5, (tptr (Tstruct _SpawnInfo noattr))) ::
               (_t'4, tschar) ::
               (_t'3, (tptr (Tstruct _SpawnInfo noattr))) ::
               (_t'2, tschar) :: (_t'1, (tptr (Tstruct _Area noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _stop_sounds_in_continuous_banks (Tfunction nil tvoid cc_default))
    nil)
  (Ssequence
    (Ssequence
      (Sset _t'9 (Evar _gMarioSpawnInfo (tptr (Tstruct _SpawnInfo noattr))))
      (Ssequence
        (Sset _t'10
          (Efield
            (Ederef (Etempvar _t'9 (tptr (Tstruct _SpawnInfo noattr)))
              (Tstruct _SpawnInfo noattr)) _areaIndex tschar))
        (Scall None
          (Evar _load_area (Tfunction (tint :: nil) tvoid cc_default))
          ((Etempvar _t'10 tschar) :: nil))))
    (Ssequence
      (Sset _t'1 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _t'1 (tptr (Tstruct _Area noattr)))
              (Tstruct _Area noattr)) _index tschar))
        (Ssequence
          (Sset _t'3
            (Evar _gMarioSpawnInfo (tptr (Tstruct _SpawnInfo noattr))))
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef (Etempvar _t'3 (tptr (Tstruct _SpawnInfo noattr)))
                  (Tstruct _SpawnInfo noattr)) _areaIndex tschar))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tschar)
                           (Etempvar _t'4 tschar) tint)
              (Ssequence
                (Ssequence
                  (Sset _t'6
                    (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                  (Ssequence
                    (Sset _t'7
                      (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                    (Ssequence
                      (Sset _t'8
                        (Efield
                          (Ederef
                            (Etempvar _t'7 (tptr (Tstruct _Area noattr)))
                            (Tstruct _Area noattr)) _flags tschar))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _t'6 (tptr (Tstruct _Area noattr)))
                            (Tstruct _Area noattr)) _flags tschar)
                        (Ebinop Oor (Etempvar _t'8 tschar)
                          (Econst_int (Int.repr 1) tint) tint)))))
                (Ssequence
                  (Sset _t'5
                    (Evar _gMarioSpawnInfo (tptr (Tstruct _SpawnInfo noattr))))
                  (Scall None
                    (Evar _spawn_objects_from_info (Tfunction
                                                     (tint ::
                                                      (tptr (Tstruct _SpawnInfo noattr)) ::
                                                      nil) tvoid cc_default))
                    ((Econst_int (Int.repr 0) tint) ::
                     (Etempvar _t'5 (tptr (Tstruct _SpawnInfo noattr))) ::
                     nil))))
              Sskip)))))))
|}.

Definition f_unload_mario_area := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'11, tschar) ::
               (_t'10, (tptr (Tstruct _Area noattr))) ::
               (_t'9, (tptr (Tstruct _Area noattr))) :: (_t'8, tschar) ::
               (_t'7, (tptr (Tstruct _SpawnInfo noattr))) ::
               (_t'6, tschar) :: (_t'5, (tptr (Tstruct _Area noattr))) ::
               (_t'4, (tptr (Tstruct _Area noattr))) :: (_t'3, tschar) ::
               (_t'2, (tptr (Tstruct _Area noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
    (Sifthenelse (Ebinop One (Etempvar _t'9 (tptr (Tstruct _Area noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Sset _t'10 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
        (Ssequence
          (Sset _t'11
            (Efield
              (Ederef (Etempvar _t'10 (tptr (Tstruct _Area noattr)))
                (Tstruct _Area noattr)) _flags tschar))
          (Sset _t'1
            (Ecast
              (Ebinop Oand (Etempvar _t'11 tschar)
                (Econst_int (Int.repr 1) tint) tint) tbool))))
      (Sset _t'1 (Econst_int (Int.repr 0) tint))))
  (Sifthenelse (Etempvar _t'1 tint)
    (Ssequence
      (Ssequence
        (Sset _t'7
          (Evar _gMarioSpawnInfo (tptr (Tstruct _SpawnInfo noattr))))
        (Ssequence
          (Sset _t'8
            (Efield
              (Ederef (Etempvar _t'7 (tptr (Tstruct _SpawnInfo noattr)))
                (Tstruct _SpawnInfo noattr)) _activeAreaIndex tschar))
          (Scall None
            (Evar _unload_objects_from_area (Tfunction (tint :: tint :: nil)
                                              tvoid cc_default))
            ((Econst_int (Int.repr 0) tint) :: (Etempvar _t'8 tschar) :: nil))))
      (Ssequence
        (Ssequence
          (Sset _t'4 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
          (Ssequence
            (Sset _t'5 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
            (Ssequence
              (Sset _t'6
                (Efield
                  (Ederef (Etempvar _t'5 (tptr (Tstruct _Area noattr)))
                    (Tstruct _Area noattr)) _flags tschar))
              (Sassign
                (Efield
                  (Ederef (Etempvar _t'4 (tptr (Tstruct _Area noattr)))
                    (Tstruct _Area noattr)) _flags tschar)
                (Ebinop Oand (Etempvar _t'6 tschar)
                  (Eunop Onotint (Econst_int (Int.repr 1) tint) tint) tint)))))
        (Ssequence
          (Sset _t'2 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
          (Ssequence
            (Sset _t'3
              (Efield
                (Ederef (Etempvar _t'2 (tptr (Tstruct _Area noattr)))
                  (Tstruct _Area noattr)) _flags tschar))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tschar)
                           (Econst_int (Int.repr 0) tint) tint)
              (Scall None
                (Evar _unload_area (Tfunction nil tvoid cc_default)) nil)
              Sskip)))))
    Sskip))
|}.

Definition f_change_area := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_index, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_areaFlags, tint) :: (_t'6, (tptr (Tstruct _Area noattr))) ::
               (_t'5, (tptr (Tstruct _Area noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: (_t'3, tshort) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr (Tstruct _SpawnInfo noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
    (Sset _areaFlags
      (Efield
        (Ederef (Etempvar _t'6 (tptr (Tstruct _Area noattr)))
          (Tstruct _Area noattr)) _flags tschar)))
  (Ssequence
    (Ssequence
      (Sset _t'3 (Evar _gCurrAreaIndex tshort))
      (Sifthenelse (Ebinop One (Etempvar _t'3 tshort) (Etempvar _index tint)
                     tint)
        (Ssequence
          (Scall None (Evar _unload_area (Tfunction nil tvoid cc_default))
            nil)
          (Ssequence
            (Scall None
              (Evar _load_area (Tfunction (tint :: nil) tvoid cc_default))
              ((Etempvar _index tint) :: nil))
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _t'5 (tptr (Tstruct _Area noattr)))
                      (Tstruct _Area noattr)) _flags tschar)
                  (Etempvar _areaFlags tint)))
              (Ssequence
                (Sset _t'4
                  (Evar _gMarioObject (tptr (Tstruct _Object noattr))))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __791 noattr)) _asU32 (tarray tuint 80))
                      (Econst_int (Int.repr 22) tint) (tptr tuint)) tuint)
                  (Econst_int (Int.repr 0) tint))))))
        Sskip))
    (Sifthenelse (Ebinop Oand (Etempvar _areaFlags tint)
                   (Econst_int (Int.repr 1) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _gMarioObject (tptr (Tstruct _Object noattr))))
          (Sassign
            (Efield
              (Efield
                (Efield
                  (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _header
                  (Tstruct _ObjectNode noattr)) _gfx
                (Tstruct _GraphNodeObject noattr)) _areaIndex tschar)
            (Etempvar _index tint)))
        (Ssequence
          (Sset _t'1
            (Evar _gMarioSpawnInfo (tptr (Tstruct _SpawnInfo noattr))))
          (Sassign
            (Efield
              (Ederef (Etempvar _t'1 (tptr (Tstruct _SpawnInfo noattr)))
                (Tstruct _SpawnInfo noattr)) _areaIndex tschar)
            (Etempvar _index tint))))
      Sskip)))
|}.

Definition f_area_update_objects := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1 (Evar _gAreaUpdateCounter tushort))
    (Sassign (Evar _gAreaUpdateCounter tushort)
      (Ebinop Oadd (Etempvar _t'1 tushort) (Econst_int (Int.repr 1) tint)
        tint)))
  (Scall None
    (Evar _update_objects (Tfunction (tint :: nil) tvoid cc_default))
    ((Econst_int (Int.repr 0) tint) :: nil)))
|}.

Definition f_play_transition := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_transType, tshort) :: (_time, tshort) :: (_red, tuchar) ::
                (_green, tuchar) :: (_blue, tuchar) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tfloat) :: (_t'1, tfloat) :: (_t'5, tuchar) ::
               (_t'4, tuchar) :: (_t'3, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sassign
    (Efield (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
      _isActive tuchar) (Econst_int (Int.repr 1) tint))
  (Ssequence
    (Sassign
      (Efield (Evar _gWarpTransition (Tstruct _WarpTransition noattr)) _type
        tuchar) (Etempvar _transType tshort))
    (Ssequence
      (Sassign
        (Efield (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
          _time tuchar) (Etempvar _time tshort))
      (Ssequence
        (Sassign
          (Efield (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
            _pauseRendering tuchar) (Econst_int (Int.repr 0) tint))
        (Ssequence
          (Sifthenelse (Ebinop Oand (Etempvar _transType tshort)
                         (Econst_int (Int.repr 1) tint) tint)
            (Scall None
              (Evar _set_warp_transition_rgb (Tfunction
                                               (tuchar :: tuchar :: tuchar ::
                                                nil) tvoid cc_default))
              ((Etempvar _red tuchar) :: (Etempvar _green tuchar) ::
               (Etempvar _blue tuchar) :: nil))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'5 (Evar _gWarpTransRed tuchar))
                  (Sset _red (Ecast (Etempvar _t'5 tuchar) tuchar)))
                (Ssequence
                  (Sset _t'4 (Evar _gWarpTransGreen tuchar))
                  (Sset _green (Ecast (Etempvar _t'4 tuchar) tuchar))))
              (Ssequence
                (Sset _t'3 (Evar _gWarpTransBlue tuchar))
                (Sset _blue (Ecast (Etempvar _t'3 tuchar) tuchar)))))
          (Sifthenelse (Ebinop Olt (Etempvar _transType tshort)
                         (Econst_int (Int.repr 8) tint) tint)
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                    _data (Tstruct _WarpTransitionData noattr)) _red tuchar)
                (Etempvar _red tuchar))
              (Ssequence
                (Sassign
                  (Efield
                    (Efield
                      (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                      _data (Tstruct _WarpTransitionData noattr)) _green
                    tuchar) (Etempvar _green tuchar))
                (Sassign
                  (Efield
                    (Efield
                      (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                      _data (Tstruct _WarpTransitionData noattr)) _blue
                    tuchar) (Etempvar _blue tuchar))))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                    _data (Tstruct _WarpTransitionData noattr)) _red tuchar)
                (Etempvar _red tuchar))
              (Ssequence
                (Sassign
                  (Efield
                    (Efield
                      (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                      _data (Tstruct _WarpTransitionData noattr)) _green
                    tuchar) (Etempvar _green tuchar))
                (Ssequence
                  (Sassign
                    (Efield
                      (Efield
                        (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                        _data (Tstruct _WarpTransitionData noattr)) _blue
                      tuchar) (Etempvar _blue tuchar))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Efield
                          (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                          _data (Tstruct _WarpTransitionData noattr))
                        _startTexX tshort)
                      (Ebinop Odiv (Econst_int (Int.repr 320) tint)
                        (Econst_int (Int.repr 2) tint) tint))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Efield
                            (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                            _data (Tstruct _WarpTransitionData noattr))
                          _startTexY tshort)
                        (Ebinop Odiv (Econst_int (Int.repr 240) tint)
                          (Econst_int (Int.repr 2) tint) tint))
                      (Ssequence
                        (Sassign
                          (Efield
                            (Efield
                              (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                              _data (Tstruct _WarpTransitionData noattr))
                            _endTexX tshort)
                          (Ebinop Odiv (Econst_int (Int.repr 320) tint)
                            (Econst_int (Int.repr 2) tint) tint))
                        (Ssequence
                          (Sassign
                            (Efield
                              (Efield
                                (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                                _data (Tstruct _WarpTransitionData noattr))
                              _endTexY tshort)
                            (Ebinop Odiv (Econst_int (Int.repr 240) tint)
                              (Econst_int (Int.repr 2) tint) tint))
                          (Ssequence
                            (Sassign
                              (Efield
                                (Efield
                                  (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                                  _data (Tstruct _WarpTransitionData noattr))
                                _texTimer tshort)
                              (Econst_int (Int.repr 0) tint))
                            (Sifthenelse (Ebinop Oand
                                           (Etempvar _transType tshort)
                                           (Econst_int (Int.repr 1) tint)
                                           tint)
                              (Ssequence
                                (Ssequence
                                  (Sifthenelse (Ebinop Ogt
                                                 (Ebinop Odiv
                                                   (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                                   (Econst_single (Float32.of_bits (Int.repr 1077936128)) tfloat)
                                                   tfloat)
                                                 (Econst_int (Int.repr 1) tint)
                                                 tint)
                                    (Sset _t'1
                                      (Ecast
                                        (Ebinop Odiv
                                          (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                          (Econst_single (Float32.of_bits (Int.repr 1077936128)) tfloat)
                                          tfloat) tfloat))
                                    (Sset _t'1
                                      (Ecast (Econst_int (Int.repr 1) tint)
                                        tfloat)))
                                  (Sassign
                                    (Efield
                                      (Efield
                                        (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                                        _data
                                        (Tstruct _WarpTransitionData noattr))
                                      _startTexRadius tshort)
                                    (Ebinop Omul
                                      (Econst_int (Int.repr 240) tint)
                                      (Etempvar _t'1 tfloat) tfloat)))
                                (Sifthenelse (Ebinop Oge
                                               (Etempvar _transType tshort)
                                               (Econst_int (Int.repr 15) tint)
                                               tint)
                                  (Sassign
                                    (Efield
                                      (Efield
                                        (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                                        _data
                                        (Tstruct _WarpTransitionData noattr))
                                      _endTexRadius tshort)
                                    (Econst_int (Int.repr 16) tint))
                                  (Sassign
                                    (Efield
                                      (Efield
                                        (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                                        _data
                                        (Tstruct _WarpTransitionData noattr))
                                      _endTexRadius tshort)
                                    (Econst_int (Int.repr 0) tint))))
                              (Ssequence
                                (Sifthenelse (Ebinop Oge
                                               (Etempvar _transType tshort)
                                               (Econst_int (Int.repr 14) tint)
                                               tint)
                                  (Sassign
                                    (Efield
                                      (Efield
                                        (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                                        _data
                                        (Tstruct _WarpTransitionData noattr))
                                      _startTexRadius tshort)
                                    (Econst_int (Int.repr 16) tint))
                                  (Sassign
                                    (Efield
                                      (Efield
                                        (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                                        _data
                                        (Tstruct _WarpTransitionData noattr))
                                      _startTexRadius tshort)
                                    (Econst_int (Int.repr 0) tint)))
                                (Ssequence
                                  (Sifthenelse (Ebinop Ogt
                                                 (Ebinop Odiv
                                                   (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                                   (Econst_single (Float32.of_bits (Int.repr 1077936128)) tfloat)
                                                   tfloat)
                                                 (Econst_int (Int.repr 1) tint)
                                                 tint)
                                    (Sset _t'2
                                      (Ecast
                                        (Ebinop Odiv
                                          (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                          (Econst_single (Float32.of_bits (Int.repr 1077936128)) tfloat)
                                          tfloat) tfloat))
                                    (Sset _t'2
                                      (Ecast (Econst_int (Int.repr 1) tint)
                                        tfloat)))
                                  (Sassign
                                    (Efield
                                      (Efield
                                        (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                                        _data
                                        (Tstruct _WarpTransitionData noattr))
                                      _endTexRadius tshort)
                                    (Ebinop Omul
                                      (Econst_int (Int.repr 240) tint)
                                      (Etempvar _t'2 tfloat) tfloat)))))))))))))))))))
|}.

Definition f_play_transition_after_delay := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_transType, tshort) :: (_time, tshort) :: (_red, tuchar) ::
                (_green, tuchar) :: (_blue, tuchar) :: (_delay, tshort) ::
                nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sassign (Evar _gWarpTransDelay tshort) (Etempvar _delay tshort))
  (Scall None
    (Evar _play_transition (Tfunction
                             (tshort :: tshort :: tuchar :: tuchar ::
                              tuchar :: nil) tvoid cc_default))
    ((Etempvar _transType tshort) :: (Etempvar _time tshort) ::
     (Etempvar _red tuchar) :: (Etempvar _green tuchar) ::
     (Etempvar _blue tuchar) :: nil)))
|}.

Definition f_render_game := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((__g, (tptr (Tunion __576 noattr))) ::
               (__g__1, (tptr (Tunion __576 noattr))) ::
               (__g__2, (tptr (Tunion __576 noattr))) ::
               (__g__3, (tptr (Tunion __576 noattr))) ::
               (__g__4, (tptr (Tunion __576 noattr))) :: (_t'8, tint) ::
               (_t'7, tint) :: (_t'6, (tptr (Tunion __576 noattr))) ::
               (_t'5, tshort) :: (_t'4, (tptr (Tunion __576 noattr))) ::
               (_t'3, (tptr (Tunion __576 noattr))) ::
               (_t'2, (tptr (Tunion __576 noattr))) ::
               (_t'1, (tptr (Tunion __576 noattr))) :: (_t'30, tuchar) ::
               (_t'29, (tptr (Tstruct _Area noattr))) :: (_t'28, tuint) ::
               (_t'27, (tptr (Tunion __540 noattr))) ::
               (_t'26, (tptr (Tunion __540 noattr))) ::
               (_t'25, (tptr (Tstruct _GraphNodeRoot noattr))) ::
               (_t'24, (tptr (Tstruct _Area noattr))) :: (_t'23, tshort) ::
               (_t'22, tshort) :: (_t'21, (tptr (Tunion __540 noattr))) ::
               (_t'20, (tptr (Tunion __540 noattr))) :: (_t'19, tuchar) ::
               (_t'18, tuchar) :: (_t'17, tuchar) :: (_t'16, tuchar) ::
               (_t'15, tshort) :: (_t'14, tshort) :: (_t'13, tuchar) ::
               (_t'12, tuint) :: (_t'11, (tptr (Tunion __540 noattr))) ::
               (_t'10, tuint) :: (_t'9, (tptr (Tunion __540 noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'29 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
      (Sifthenelse (Ebinop One (Etempvar _t'29 (tptr (Tstruct _Area noattr)))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Ssequence
          (Sset _t'30
            (Efield (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
              _pauseRendering tuchar))
          (Sset _t'8
            (Ecast (Eunop Onotbool (Etempvar _t'30 tuchar) tint) tbool)))
        (Sset _t'8 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'8 tint)
      (Ssequence
        (Ssequence
          (Sset _t'24 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
          (Ssequence
            (Sset _t'25
              (Efield
                (Ederef (Etempvar _t'24 (tptr (Tstruct _Area noattr)))
                  (Tstruct _Area noattr)) _unk04
                (tptr (Tstruct _GraphNodeRoot noattr))))
            (Ssequence
              (Sset _t'26 (Evar _D_8032CE74 (tptr (Tunion __540 noattr))))
              (Ssequence
                (Sset _t'27 (Evar _D_8032CE78 (tptr (Tunion __540 noattr))))
                (Ssequence
                  (Sset _t'28 (Evar _gFBSetColor tuint))
                  (Scall None
                    (Evar _geo_process_root (Tfunction
                                              ((tptr (Tstruct _GraphNodeRoot noattr)) ::
                                               (tptr (Tunion __540 noattr)) ::
                                               (tptr (Tunion __540 noattr)) ::
                                               tint :: nil) tvoid cc_default))
                    ((Etempvar _t'25 (tptr (Tstruct _GraphNodeRoot noattr))) ::
                     (Etempvar _t'26 (tptr (Tunion __540 noattr))) ::
                     (Etempvar _t'27 (tptr (Tunion __540 noattr))) ::
                     (Etempvar _t'28 tuint) :: nil)))))))
        (Ssequence
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'1
                  (Evar _gDisplayListHead (tptr (Tunion __576 noattr))))
                (Sassign
                  (Evar _gDisplayListHead (tptr (Tunion __576 noattr)))
                  (Ebinop Oadd (Etempvar _t'1 (tptr (Tunion __576 noattr)))
                    (Econst_int (Int.repr 1) tint)
                    (tptr (Tunion __576 noattr)))))
              (Sset __g
                (Ecast (Etempvar _t'1 (tptr (Tunion __576 noattr)))
                  (tptr (Tunion __576 noattr)))))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g (tptr (Tunion __576 noattr)))
                      (Tunion __576 noattr)) _words (Tstruct __574 noattr))
                  _w0 tuint)
                (Ebinop Oor
                  (Ebinop Oor
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 3) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 24) tint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 128) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 16) tint) tuint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Esizeof (Tunion __540 noattr) tuint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 16) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g (tptr (Tunion __576 noattr)))
                      (Tunion __576 noattr)) _words (Tstruct __574 noattr))
                  _w1 tuint)
                (Ecast
                  (Ebinop Oand
                    (Ecast
                      (Eaddrof (Evar _D_8032CF00 (Tunion __540 noattr))
                        (tptr (Tunion __540 noattr))) tuint)
                    (Econst_int (Int.repr 536870911) tint) tuint) tuint))))
          (Ssequence
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'2
                    (Evar _gDisplayListHead (tptr (Tunion __576 noattr))))
                  (Sassign
                    (Evar _gDisplayListHead (tptr (Tunion __576 noattr)))
                    (Ebinop Oadd (Etempvar _t'2 (tptr (Tunion __576 noattr)))
                      (Econst_int (Int.repr 1) tint)
                      (tptr (Tunion __576 noattr)))))
                (Sset __g__1
                  (Ecast (Etempvar _t'2 (tptr (Tunion __576 noattr)))
                    (tptr (Tunion __576 noattr)))))
              (Ssequence
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__1 (tptr (Tunion __576 noattr)))
                        (Tunion __576 noattr)) _words (Tstruct __574 noattr))
                    _w0 tuint)
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 237) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 24) tint) tuint) tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast
                              (Ecast
                                (Ebinop Omul
                                  (Ecast (Econst_int (Int.repr 0) tint)
                                    tfloat)
                                  (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                  tfloat) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 12) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 12) tint) tuint) tuint)
                      tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast
                            (Ecast
                              (Ebinop Omul
                                (Ecast (Econst_int (Int.repr 8) tint) tfloat)
                                (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                tfloat) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 12) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__1 (tptr (Tunion __576 noattr)))
                        (Tunion __576 noattr)) _words (Tstruct __574 noattr))
                    _w1 tuint)
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 0) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 2) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 24) tint) tuint) tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast
                              (Ecast
                                (Ebinop Omul
                                  (Ecast (Econst_int (Int.repr 320) tint)
                                    tfloat)
                                  (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                  tfloat) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 12) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 12) tint) tuint) tuint)
                      tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast
                            (Ecast
                              (Ebinop Omul
                                (Ecast
                                  (Ebinop Osub
                                    (Econst_int (Int.repr 240) tint)
                                    (Econst_int (Int.repr 8) tint) tint)
                                  tfloat)
                                (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                tfloat) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 12) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))))
            (Ssequence
              (Scall None (Evar _render_hud (Tfunction nil tvoid cc_default))
                nil)
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'3
                        (Evar _gDisplayListHead (tptr (Tunion __576 noattr))))
                      (Sassign
                        (Evar _gDisplayListHead (tptr (Tunion __576 noattr)))
                        (Ebinop Oadd
                          (Etempvar _t'3 (tptr (Tunion __576 noattr)))
                          (Econst_int (Int.repr 1) tint)
                          (tptr (Tunion __576 noattr)))))
                    (Sset __g__2
                      (Ecast (Etempvar _t'3 (tptr (Tunion __576 noattr)))
                        (tptr (Tunion __576 noattr)))))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar __g__2 (tptr (Tunion __576 noattr)))
                            (Tunion __576 noattr)) _words
                          (Tstruct __574 noattr)) _w0 tuint)
                      (Ebinop Oor
                        (Ebinop Oor
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast (Econst_int (Int.repr 237) tint)
                                  tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 8) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 24) tint) tuint) tuint)
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast
                                  (Ecast
                                    (Ebinop Omul
                                      (Ecast (Econst_int (Int.repr 0) tint)
                                        tfloat)
                                      (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                      tfloat) tint) tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 12) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 12) tint) tuint) tuint)
                          tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast
                                (Ecast
                                  (Ebinop Omul
                                    (Ecast (Econst_int (Int.repr 0) tint)
                                      tfloat)
                                    (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                    tfloat) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 12) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 0) tint) tuint) tuint)
                        tuint))
                    (Sassign
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar __g__2 (tptr (Tunion __576 noattr)))
                            (Tunion __576 noattr)) _words
                          (Tstruct __574 noattr)) _w1 tuint)
                      (Ebinop Oor
                        (Ebinop Oor
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast (Econst_int (Int.repr 0) tint) tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 2) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 24) tint) tuint) tuint)
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast
                                  (Ecast
                                    (Ebinop Omul
                                      (Ecast (Econst_int (Int.repr 320) tint)
                                        tfloat)
                                      (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                      tfloat) tint) tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 12) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 12) tint) tuint) tuint)
                          tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast
                                (Ecast
                                  (Ebinop Omul
                                    (Ecast (Econst_int (Int.repr 240) tint)
                                      tfloat)
                                    (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                    tfloat) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 12) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 0) tint) tuint) tuint)
                        tuint))))
                (Ssequence
                  (Scall None
                    (Evar _render_text_labels (Tfunction nil tvoid
                                                cc_default)) nil)
                  (Ssequence
                    (Scall None
                      (Evar _do_cutscene_handler (Tfunction nil tvoid
                                                   cc_default)) nil)
                    (Ssequence
                      (Scall None
                        (Evar _print_displaying_credits_entry (Tfunction nil
                                                                tvoid
                                                                cc_default))
                        nil)
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Sset _t'4
                                (Evar _gDisplayListHead (tptr (Tunion __576 noattr))))
                              (Sassign
                                (Evar _gDisplayListHead (tptr (Tunion __576 noattr)))
                                (Ebinop Oadd
                                  (Etempvar _t'4 (tptr (Tunion __576 noattr)))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr (Tunion __576 noattr)))))
                            (Sset __g__3
                              (Ecast
                                (Etempvar _t'4 (tptr (Tunion __576 noattr)))
                                (tptr (Tunion __576 noattr)))))
                          (Ssequence
                            (Sassign
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar __g__3 (tptr (Tunion __576 noattr)))
                                    (Tunion __576 noattr)) _words
                                  (Tstruct __574 noattr)) _w0 tuint)
                              (Ebinop Oor
                                (Ebinop Oor
                                  (Ecast
                                    (Ebinop Oshl
                                      (Ebinop Oand
                                        (Ecast
                                          (Econst_int (Int.repr 237) tint)
                                          tuint)
                                        (Ebinop Osub
                                          (Ebinop Oshl
                                            (Econst_int (Int.repr 1) tint)
                                            (Econst_int (Int.repr 8) tint)
                                            tint)
                                          (Econst_int (Int.repr 1) tint)
                                          tint) tuint)
                                      (Econst_int (Int.repr 24) tint) tuint)
                                    tuint)
                                  (Ecast
                                    (Ebinop Oshl
                                      (Ebinop Oand
                                        (Ecast
                                          (Ecast
                                            (Ebinop Omul
                                              (Ecast
                                                (Econst_int (Int.repr 0) tint)
                                                tfloat)
                                              (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                              tfloat) tint) tuint)
                                        (Ebinop Osub
                                          (Ebinop Oshl
                                            (Econst_int (Int.repr 1) tint)
                                            (Econst_int (Int.repr 12) tint)
                                            tint)
                                          (Econst_int (Int.repr 1) tint)
                                          tint) tuint)
                                      (Econst_int (Int.repr 12) tint) tuint)
                                    tuint) tuint)
                                (Ecast
                                  (Ebinop Oshl
                                    (Ebinop Oand
                                      (Ecast
                                        (Ecast
                                          (Ebinop Omul
                                            (Ecast
                                              (Econst_int (Int.repr 8) tint)
                                              tfloat)
                                            (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                            tfloat) tint) tuint)
                                      (Ebinop Osub
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 12) tint)
                                          tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuint) (Econst_int (Int.repr 0) tint)
                                    tuint) tuint) tuint))
                            (Sassign
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar __g__3 (tptr (Tunion __576 noattr)))
                                    (Tunion __576 noattr)) _words
                                  (Tstruct __574 noattr)) _w1 tuint)
                              (Ebinop Oor
                                (Ebinop Oor
                                  (Ecast
                                    (Ebinop Oshl
                                      (Ebinop Oand
                                        (Ecast (Econst_int (Int.repr 0) tint)
                                          tuint)
                                        (Ebinop Osub
                                          (Ebinop Oshl
                                            (Econst_int (Int.repr 1) tint)
                                            (Econst_int (Int.repr 2) tint)
                                            tint)
                                          (Econst_int (Int.repr 1) tint)
                                          tint) tuint)
                                      (Econst_int (Int.repr 24) tint) tuint)
                                    tuint)
                                  (Ecast
                                    (Ebinop Oshl
                                      (Ebinop Oand
                                        (Ecast
                                          (Ecast
                                            (Ebinop Omul
                                              (Ecast
                                                (Econst_int (Int.repr 320) tint)
                                                tfloat)
                                              (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                              tfloat) tint) tuint)
                                        (Ebinop Osub
                                          (Ebinop Oshl
                                            (Econst_int (Int.repr 1) tint)
                                            (Econst_int (Int.repr 12) tint)
                                            tint)
                                          (Econst_int (Int.repr 1) tint)
                                          tint) tuint)
                                      (Econst_int (Int.repr 12) tint) tuint)
                                    tuint) tuint)
                                (Ecast
                                  (Ebinop Oshl
                                    (Ebinop Oand
                                      (Ecast
                                        (Ecast
                                          (Ebinop Omul
                                            (Ecast
                                              (Ebinop Osub
                                                (Econst_int (Int.repr 240) tint)
                                                (Econst_int (Int.repr 8) tint)
                                                tint) tfloat)
                                            (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                            tfloat) tint) tuint)
                                      (Ebinop Osub
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 12) tint)
                                          tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuint) (Econst_int (Int.repr 0) tint)
                                    tuint) tuint) tuint))))
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'5)
                              (Evar _render_menus_and_dialogs (Tfunction nil
                                                                tshort
                                                                cc_default))
                              nil)
                            (Sassign (Evar _gMenuOptSelectIndex tshort)
                              (Etempvar _t'5 tshort)))
                          (Ssequence
                            (Ssequence
                              (Sset _t'22 (Evar _gMenuOptSelectIndex tshort))
                              (Sifthenelse (Ebinop One
                                             (Etempvar _t'22 tshort)
                                             (Econst_int (Int.repr 0) tint)
                                             tint)
                                (Ssequence
                                  (Sset _t'23
                                    (Evar _gMenuOptSelectIndex tshort))
                                  (Sassign (Evar _gSaveOptSelectIndex tshort)
                                    (Etempvar _t'23 tshort)))
                                Sskip))
                            (Ssequence
                              (Ssequence
                                (Sset _t'20
                                  (Evar _D_8032CE78 (tptr (Tunion __540 noattr))))
                                (Sifthenelse (Ebinop One
                                               (Etempvar _t'20 (tptr (Tunion __540 noattr)))
                                               (Ecast
                                                 (Econst_int (Int.repr 0) tint)
                                                 (tptr tvoid)) tint)
                                  (Ssequence
                                    (Sset _t'21
                                      (Evar _D_8032CE78 (tptr (Tunion __540 noattr))))
                                    (Scall None
                                      (Evar _make_viewport_clip_rect 
                                      (Tfunction
                                        ((tptr (Tunion __540 noattr)) :: nil)
                                        tvoid cc_default))
                                      ((Etempvar _t'21 (tptr (Tunion __540 noattr))) ::
                                       nil)))
                                  (Ssequence
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'6
                                          (Evar _gDisplayListHead (tptr (Tunion __576 noattr))))
                                        (Sassign
                                          (Evar _gDisplayListHead (tptr (Tunion __576 noattr)))
                                          (Ebinop Oadd
                                            (Etempvar _t'6 (tptr (Tunion __576 noattr)))
                                            (Econst_int (Int.repr 1) tint)
                                            (tptr (Tunion __576 noattr)))))
                                      (Sset __g__4
                                        (Ecast
                                          (Etempvar _t'6 (tptr (Tunion __576 noattr)))
                                          (tptr (Tunion __576 noattr)))))
                                    (Ssequence
                                      (Sassign
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar __g__4 (tptr (Tunion __576 noattr)))
                                              (Tunion __576 noattr)) _words
                                            (Tstruct __574 noattr)) _w0
                                          tuint)
                                        (Ebinop Oor
                                          (Ebinop Oor
                                            (Ecast
                                              (Ebinop Oshl
                                                (Ebinop Oand
                                                  (Ecast
                                                    (Econst_int (Int.repr 237) tint)
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
                                                    (Ecast
                                                      (Ebinop Omul
                                                        (Ecast
                                                          (Econst_int (Int.repr 0) tint)
                                                          tfloat)
                                                        (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                                        tfloat) tint) tuint)
                                                  (Ebinop Osub
                                                    (Ebinop Oshl
                                                      (Econst_int (Int.repr 1) tint)
                                                      (Econst_int (Int.repr 12) tint)
                                                      tint)
                                                    (Econst_int (Int.repr 1) tint)
                                                    tint) tuint)
                                                (Econst_int (Int.repr 12) tint)
                                                tuint) tuint) tuint)
                                          (Ecast
                                            (Ebinop Oshl
                                              (Ebinop Oand
                                                (Ecast
                                                  (Ecast
                                                    (Ebinop Omul
                                                      (Ecast
                                                        (Econst_int (Int.repr 8) tint)
                                                        tfloat)
                                                      (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                                      tfloat) tint) tuint)
                                                (Ebinop Osub
                                                  (Ebinop Oshl
                                                    (Econst_int (Int.repr 1) tint)
                                                    (Econst_int (Int.repr 12) tint)
                                                    tint)
                                                  (Econst_int (Int.repr 1) tint)
                                                  tint) tuint)
                                              (Econst_int (Int.repr 0) tint)
                                              tuint) tuint) tuint))
                                      (Sassign
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar __g__4 (tptr (Tunion __576 noattr)))
                                              (Tunion __576 noattr)) _words
                                            (Tstruct __574 noattr)) _w1
                                          tuint)
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
                                                      (Econst_int (Int.repr 2) tint)
                                                      tint)
                                                    (Econst_int (Int.repr 1) tint)
                                                    tint) tuint)
                                                (Econst_int (Int.repr 24) tint)
                                                tuint) tuint)
                                            (Ecast
                                              (Ebinop Oshl
                                                (Ebinop Oand
                                                  (Ecast
                                                    (Ecast
                                                      (Ebinop Omul
                                                        (Ecast
                                                          (Econst_int (Int.repr 320) tint)
                                                          tfloat)
                                                        (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                                        tfloat) tint) tuint)
                                                  (Ebinop Osub
                                                    (Ebinop Oshl
                                                      (Econst_int (Int.repr 1) tint)
                                                      (Econst_int (Int.repr 12) tint)
                                                      tint)
                                                    (Econst_int (Int.repr 1) tint)
                                                    tint) tuint)
                                                (Econst_int (Int.repr 12) tint)
                                                tuint) tuint) tuint)
                                          (Ecast
                                            (Ebinop Oshl
                                              (Ebinop Oand
                                                (Ecast
                                                  (Ecast
                                                    (Ebinop Omul
                                                      (Ecast
                                                        (Ebinop Osub
                                                          (Econst_int (Int.repr 240) tint)
                                                          (Econst_int (Int.repr 8) tint)
                                                          tint) tfloat)
                                                      (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                                      tfloat) tint) tuint)
                                                (Ebinop Osub
                                                  (Ebinop Oshl
                                                    (Econst_int (Int.repr 1) tint)
                                                    (Econst_int (Int.repr 12) tint)
                                                    tint)
                                                  (Econst_int (Int.repr 1) tint)
                                                  tint) tuint)
                                              (Econst_int (Int.repr 0) tint)
                                              tuint) tuint) tuint))))))
                              (Ssequence
                                (Sset _t'13
                                  (Efield
                                    (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                                    _isActive tuchar))
                                (Sifthenelse (Etempvar _t'13 tuchar)
                                  (Ssequence
                                    (Sset _t'14
                                      (Evar _gWarpTransDelay tshort))
                                    (Sifthenelse (Ebinop Oeq
                                                   (Etempvar _t'14 tshort)
                                                   (Econst_int (Int.repr 0) tint)
                                                   tint)
                                      (Ssequence
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'18
                                              (Efield
                                                (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                                                _type tuchar))
                                            (Ssequence
                                              (Sset _t'19
                                                (Efield
                                                  (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                                                  _time tuchar))
                                              (Scall (Some _t'7)
                                                (Evar _render_screen_transition 
                                                (Tfunction
                                                  (tschar :: tschar ::
                                                   tuchar ::
                                                   (tptr (Tstruct _WarpTransitionData noattr)) ::
                                                   nil) tint cc_default))
                                                ((Econst_int (Int.repr 0) tint) ::
                                                 (Etempvar _t'18 tuchar) ::
                                                 (Etempvar _t'19 tuchar) ::
                                                 (Eaddrof
                                                   (Efield
                                                     (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                                                     _data
                                                     (Tstruct _WarpTransitionData noattr))
                                                   (tptr (Tstruct _WarpTransitionData noattr))) ::
                                                 nil))))
                                          (Sassign
                                            (Efield
                                              (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                                              _isActive tuchar)
                                            (Eunop Onotbool
                                              (Etempvar _t'7 tint) tint)))
                                        (Ssequence
                                          (Sset _t'16
                                            (Efield
                                              (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                                              _isActive tuchar))
                                          (Sifthenelse (Eunop Onotbool
                                                         (Etempvar _t'16 tuchar)
                                                         tint)
                                            (Ssequence
                                              (Sset _t'17
                                                (Efield
                                                  (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                                                  _type tuchar))
                                              (Sifthenelse (Ebinop Oand
                                                             (Etempvar _t'17 tuchar)
                                                             (Econst_int (Int.repr 1) tint)
                                                             tint)
                                                (Sassign
                                                  (Efield
                                                    (Evar _gWarpTransition (Tstruct _WarpTransition noattr))
                                                    _pauseRendering tuchar)
                                                  (Econst_int (Int.repr 1) tint))
                                                (Scall None
                                                  (Evar _set_warp_transition_rgb 
                                                  (Tfunction
                                                    (tuchar :: tuchar ::
                                                     tuchar :: nil) tvoid
                                                    cc_default))
                                                  ((Econst_int (Int.repr 0) tint) ::
                                                   (Econst_int (Int.repr 0) tint) ::
                                                   (Econst_int (Int.repr 0) tint) ::
                                                   nil))))
                                            Sskip)))
                                      (Ssequence
                                        (Sset _t'15
                                          (Evar _gWarpTransDelay tshort))
                                        (Sassign
                                          (Evar _gWarpTransDelay tshort)
                                          (Ebinop Osub
                                            (Etempvar _t'15 tshort)
                                            (Econst_int (Int.repr 1) tint)
                                            tint)))))
                                  Sskip))))))))))))))
      (Ssequence
        (Scall None
          (Evar _render_text_labels (Tfunction nil tvoid cc_default)) nil)
        (Ssequence
          (Sset _t'9 (Evar _D_8032CE78 (tptr (Tunion __540 noattr))))
          (Sifthenelse (Ebinop One
                         (Etempvar _t'9 (tptr (Tunion __540 noattr)))
                         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                         tint)
            (Ssequence
              (Sset _t'11 (Evar _D_8032CE78 (tptr (Tunion __540 noattr))))
              (Ssequence
                (Sset _t'12 (Evar _gWarpTransFBSetColor tuint))
                (Scall None
                  (Evar _clear_viewport (Tfunction
                                          ((tptr (Tunion __540 noattr)) ::
                                           tint :: nil) tvoid cc_default))
                  ((Etempvar _t'11 (tptr (Tunion __540 noattr))) ::
                   (Etempvar _t'12 tuint) :: nil))))
            (Ssequence
              (Sset _t'10 (Evar _gWarpTransFBSetColor tuint))
              (Scall None
                (Evar _clear_framebuffer (Tfunction (tint :: nil) tvoid
                                           cc_default))
                ((Etempvar _t'10 tuint) :: nil))))))))
  (Ssequence
    (Sassign (Evar _D_8032CE74 (tptr (Tunion __540 noattr)))
      (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
    (Sassign (Evar _D_8032CE78 (tptr (Tunion __540 noattr)))
      (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))))
|}.

Definition composites : list composite_definition :=
(Composite __538 Struct
   (Member_plain _vscale (tarray tshort 4) ::
    Member_plain _vtrans (tarray tshort 4) :: nil)
   noattr ::
 Composite __540 Union
   (Member_plain _vp (Tstruct __538 noattr) ::
    Member_plain _force_structure_alignment tlong :: nil)
   noattr ::
 Composite __574 Struct
   (Member_plain _w0 tuint :: Member_plain _w1 tuint :: nil)
   noattr ::
 Composite __576 Union
   (Member_plain _words (Tstruct __574 noattr) ::
    Member_plain _force_structure_alignment tlong :: nil)
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
 Composite __791 Union
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
    Member_plain _rawData (Tunion __791 noattr) ::
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
 Composite __796 Struct
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
    Member_plain _normal (Tstruct __796 noattr) ::
    Member_plain _originOffset tfloat ::
    Member_plain _object (tptr (Tstruct _Object noattr)) :: nil)
   noattr ::
 Composite _GraphNodeRoot Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _areaIndex tuchar :: Member_plain _unk15 tschar ::
    Member_plain _x tshort :: Member_plain _y tshort ::
    Member_plain _width tshort :: Member_plain _height tshort ::
    Member_plain _numViews tshort ::
    Member_plain _views (tptr (tptr (Tstruct _GraphNode noattr))) :: nil)
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
 Composite _CreditsEntry Struct
   (Member_plain _levelNum tuchar :: Member_plain _areaIndex tuchar ::
    Member_plain _unk02 tuchar :: Member_plain _marioAngle tschar ::
    Member_plain _marioPos (tarray tshort 3) ::
    Member_plain _unk0C (tptr (tptr tuchar)) :: nil)
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
     cc_default)) :: (___stringlit_3, Gvar v___stringlit_3) ::
 (___stringlit_2, Gvar v___stringlit_2) ::
 (___stringlit_1, Gvar v___stringlit_1) ::
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
 (_virtual_to_segmented,
   Gfun(External (EF_external "virtual_to_segmented"
                   (mksignature (AST.Xint :: AST.Xptr :: nil) AST.Xptr
                     cc_default)) (tuint :: (tptr tvoid) :: nil) (tptr tvoid)
     cc_default)) :: (_gObjParentGraphNode, Gvar v_gObjParentGraphNode) ::
 (_geo_call_global_function_nodes,
   Gfun(External (EF_external "geo_call_global_function_nodes"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _GraphNode noattr)) :: tint :: nil) tvoid cc_default)) ::
 (_bhvExitPodiumWarp, Gvar v_bhvExitPodiumWarp) ::
 (_bhvFadingWarp, Gvar v_bhvFadingWarp) :: (_bhvWarp, Gvar v_bhvWarp) ::
 (_bhvWarpPipe, Gvar v_bhvWarpPipe) :: (_bhvDoorWarp, Gvar v_bhvDoorWarp) ::
 (_bhvInstantActiveWarp, Gvar v_bhvInstantActiveWarp) ::
 (_bhvAirborneWarp, Gvar v_bhvAirborneWarp) ::
 (_bhvHardAirKnockBackWarp, Gvar v_bhvHardAirKnockBackWarp) ::
 (_bhvSpinAirborneCircleWarp, Gvar v_bhvSpinAirborneCircleWarp) ::
 (_bhvDeathWarp, Gvar v_bhvDeathWarp) ::
 (_bhvSpinAirborneWarp, Gvar v_bhvSpinAirborneWarp) ::
 (_bhvFlyingWarp, Gvar v_bhvFlyingWarp) ::
 (_bhvPaintingStarCollectWarp, Gvar v_bhvPaintingStarCollectWarp) ::
 (_bhvPaintingDeathWarp, Gvar v_bhvPaintingDeathWarp) ::
 (_bhvAirborneDeathWarp, Gvar v_bhvAirborneDeathWarp) ::
 (_bhvAirborneStarCollectWarp, Gvar v_bhvAirborneStarCollectWarp) ::
 (_bhvLaunchStarCollectWarp, Gvar v_bhvLaunchStarCollectWarp) ::
 (_bhvLaunchDeathWarp, Gvar v_bhvLaunchDeathWarp) ::
 (_bhvSwimmingWarp, Gvar v_bhvSwimmingWarp) :: (_bhvStar, Gvar v_bhvStar) ::
 (_gDisplayListHead, Gvar v_gDisplayListHead) ::
 (_gControllerBits, Gvar v_gControllerBits) ::
 (_gGlobalTimer, Gvar v_gGlobalTimer) ::
 (_clear_framebuffer,
   Gfun(External (EF_external "clear_framebuffer"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tint :: nil) tvoid cc_default)) ::
 (_clear_viewport,
   Gfun(External (EF_external "clear_viewport"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tunion __540 noattr)) :: tint :: nil) tvoid cc_default)) ::
 (_make_viewport_clip_rect,
   Gfun(External (EF_external "make_viewport_clip_rect"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tunion __540 noattr)) :: nil) tvoid cc_default)) ::
 (_gMarioObject, Gvar v_gMarioObject) ::
 (_unload_objects_from_area,
   Gfun(External (EF_external "unload_objects_from_area"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xvoid
                     cc_default)) (tint :: tint :: nil) tvoid cc_default)) ::
 (_spawn_objects_from_info,
   Gfun(External (EF_external "spawn_objects_from_info"
                   (mksignature (AST.Xint :: AST.Xptr :: nil) AST.Xvoid
                     cc_default))
     (tint :: (tptr (Tstruct _SpawnInfo noattr)) :: nil) tvoid cc_default)) ::
 (_update_objects,
   Gfun(External (EF_external "update_objects"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tint :: nil) tvoid cc_default)) ::
 (_load_area_terrain,
   Gfun(External (EF_external "load_area_terrain"
                   (mksignature
                     (AST.Xint16signed :: AST.Xptr :: AST.Xptr :: AST.Xptr ::
                      nil) AST.Xvoid cc_default))
     (tshort :: (tptr tshort) :: (tptr tschar) :: (tptr tshort) :: nil) tvoid
     cc_default)) ::
 (_do_cutscene_handler,
   Gfun(External (EF_external "do_cutscene_handler"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_render_menus_and_dialogs,
   Gfun(External (EF_external "render_menus_and_dialogs"
                   (mksignature nil AST.Xint16signed cc_default)) nil tshort
     cc_default)) ::
 (_render_screen_transition,
   Gfun(External (EF_external "render_screen_transition"
                   (mksignature
                     (AST.Xint8signed :: AST.Xint8signed ::
                      AST.Xint8unsigned :: AST.Xptr :: nil) AST.Xint
                     cc_default))
     (tschar :: tschar :: tuchar ::
      (tptr (Tstruct _WarpTransitionData noattr)) :: nil) tint cc_default)) ::
 (_print_displaying_credits_entry,
   Gfun(External (EF_external "print_displaying_credits_entry"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_print_text_centered,
   Gfun(External (EF_external "print_text_centered"
                   (mksignature (AST.Xint :: AST.Xint :: AST.Xptr :: nil)
                     AST.Xvoid cc_default))
     (tint :: tint :: (tptr tuchar) :: nil) tvoid cc_default)) ::
 (_render_text_labels,
   Gfun(External (EF_external "render_text_labels"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_render_hud,
   Gfun(External (EF_external "render_hud"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_stop_sounds_in_continuous_banks,
   Gfun(External (EF_external "stop_sounds_in_continuous_banks"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) :: (_gAreaUpdateCounter, Gvar v_gAreaUpdateCounter) ::
 (_geo_process_root,
   Gfun(External (EF_external "geo_process_root"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     ((tptr (Tstruct _GraphNodeRoot noattr)) ::
      (tptr (Tunion __540 noattr)) :: (tptr (Tunion __540 noattr)) :: tint ::
      nil) tvoid cc_default)) ::
 (_gPlayerSpawnInfos, Gvar v_gPlayerSpawnInfos) ::
 (_D_8033A160, Gvar v_D_8033A160) :: (_gAreaData, Gvar v_gAreaData) ::
 (_gWarpTransition, Gvar v_gWarpTransition) ::
 (_gCurrCourseNum, Gvar v_gCurrCourseNum) ::
 (_gCurrActNum, Gvar v_gCurrActNum) ::
 (_gCurrAreaIndex, Gvar v_gCurrAreaIndex) ::
 (_gSavedCourseNum, Gvar v_gSavedCourseNum) ::
 (_gMenuOptSelectIndex, Gvar v_gMenuOptSelectIndex) ::
 (_gSaveOptSelectIndex, Gvar v_gSaveOptSelectIndex) ::
 (_gMarioSpawnInfo, Gvar v_gMarioSpawnInfo) ::
 (_gLoadedGraphNodes, Gvar v_gLoadedGraphNodes) ::
 (_gAreas, Gvar v_gAreas) :: (_gCurrentArea, Gvar v_gCurrentArea) ::
 (_gCurrCreditsEntry, Gvar v_gCurrCreditsEntry) ::
 (_D_8032CE74, Gvar v_D_8032CE74) :: (_D_8032CE78, Gvar v_D_8032CE78) ::
 (_gWarpTransDelay, Gvar v_gWarpTransDelay) ::
 (_gFBSetColor, Gvar v_gFBSetColor) ::
 (_gWarpTransFBSetColor, Gvar v_gWarpTransFBSetColor) ::
 (_gWarpTransRed, Gvar v_gWarpTransRed) ::
 (_gWarpTransGreen, Gvar v_gWarpTransGreen) ::
 (_gWarpTransBlue, Gvar v_gWarpTransBlue) ::
 (_gCurrSaveFileNum, Gvar v_gCurrSaveFileNum) ::
 (_gCurrLevelNum, Gvar v_gCurrLevelNum) ::
 (_sWarpBhvSpawnTable, Gvar v_sWarpBhvSpawnTable) ::
 (_sSpawnTypeFromWarpBhv, Gvar v_sSpawnTypeFromWarpBhv) ::
 (_D_8032CF00, Gvar v_D_8032CF00) ::
 (_override_viewport_and_clip, Gfun(Internal f_override_viewport_and_clip)) ::
 (_set_warp_transition_rgb, Gfun(Internal f_set_warp_transition_rgb)) ::
 (_print_intro_text, Gfun(Internal f_print_intro_text)) ::
 (_get_mario_spawn_type, Gfun(Internal f_get_mario_spawn_type)) ::
 (_area_get_warp_node, Gfun(Internal f_area_get_warp_node)) ::
 (_area_get_warp_node_from_params, Gfun(Internal f_area_get_warp_node_from_params)) ::
 (_load_obj_warp_nodes, Gfun(Internal f_load_obj_warp_nodes)) ::
 (_clear_areas, Gfun(Internal f_clear_areas)) ::
 (_clear_area_graph_nodes, Gfun(Internal f_clear_area_graph_nodes)) ::
 (_load_area, Gfun(Internal f_load_area)) ::
 (_unload_area, Gfun(Internal f_unload_area)) ::
 (_load_mario_area, Gfun(Internal f_load_mario_area)) ::
 (_unload_mario_area, Gfun(Internal f_unload_mario_area)) ::
 (_change_area, Gfun(Internal f_change_area)) ::
 (_area_update_objects, Gfun(Internal f_area_update_objects)) ::
 (_play_transition, Gfun(Internal f_play_transition)) ::
 (_play_transition_after_delay, Gfun(Internal f_play_transition_after_delay)) ::
 (_render_game, Gfun(Internal f_render_game)) :: nil).

Definition public_idents : list ident :=
(_render_game :: _play_transition_after_delay :: _play_transition ::
 _area_update_objects :: _change_area :: _unload_mario_area ::
 _load_mario_area :: _unload_area :: _load_area :: _clear_area_graph_nodes ::
 _clear_areas :: _load_obj_warp_nodes :: _area_get_warp_node_from_params ::
 _area_get_warp_node :: _get_mario_spawn_type :: _print_intro_text ::
 _set_warp_transition_rgb :: _override_viewport_and_clip :: _D_8032CF00 ::
 _sSpawnTypeFromWarpBhv :: _sWarpBhvSpawnTable :: _gCurrLevelNum ::
 _gCurrSaveFileNum :: _gWarpTransBlue :: _gWarpTransGreen ::
 _gWarpTransRed :: _gWarpTransFBSetColor :: _gFBSetColor ::
 _gWarpTransDelay :: _D_8032CE78 :: _D_8032CE74 :: _gCurrCreditsEntry ::
 _gCurrentArea :: _gAreas :: _gLoadedGraphNodes :: _gMarioSpawnInfo ::
 _gSaveOptSelectIndex :: _gMenuOptSelectIndex :: _gSavedCourseNum ::
 _gCurrAreaIndex :: _gCurrActNum :: _gCurrCourseNum :: _gWarpTransition ::
 _gAreaData :: _D_8033A160 :: _gPlayerSpawnInfos :: _geo_process_root ::
 _gAreaUpdateCounter :: _stop_sounds_in_continuous_banks :: _render_hud ::
 _render_text_labels :: _print_text_centered ::
 _print_displaying_credits_entry :: _render_screen_transition ::
 _render_menus_and_dialogs :: _do_cutscene_handler :: _load_area_terrain ::
 _update_objects :: _spawn_objects_from_info :: _unload_objects_from_area ::
 _gMarioObject :: _make_viewport_clip_rect :: _clear_viewport ::
 _clear_framebuffer :: _gGlobalTimer :: _gControllerBits ::
 _gDisplayListHead :: _bhvStar :: _bhvSwimmingWarp :: _bhvLaunchDeathWarp ::
 _bhvLaunchStarCollectWarp :: _bhvAirborneStarCollectWarp ::
 _bhvAirborneDeathWarp :: _bhvPaintingDeathWarp ::
 _bhvPaintingStarCollectWarp :: _bhvFlyingWarp :: _bhvSpinAirborneWarp ::
 _bhvDeathWarp :: _bhvSpinAirborneCircleWarp :: _bhvHardAirKnockBackWarp ::
 _bhvAirborneWarp :: _bhvInstantActiveWarp :: _bhvDoorWarp :: _bhvWarpPipe ::
 _bhvWarp :: _bhvFadingWarp :: _bhvExitPodiumWarp ::
 _geo_call_global_function_nodes :: _gObjParentGraphNode ::
 _virtual_to_segmented :: ___builtin_debug ::
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


