(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   JP / VERSION_JP Clight artifact for ssl-spawning-displacement-proof.
   Produced by: pipeline/clightgen.sh
   From source: ../../reference-sm64-decomp/src/engine/level_script.c
   clightgen:   The CompCert CompCert AST generator, version 3.15
   Flags:       -normalize -nostdinc -fstruct-passing -I../../reference-sm64-decomp/include -I../../reference-sm64-decomp/build/jp -I../../reference-sm64-decomp/build/jp/include -I../../reference-sm64-decomp/src -I../../reference-sm64-decomp/src/game -I../../reference-sm64-decomp -I../../reference-sm64-decomp/include/libc -DVERSION_JP=1 -DF3D_OLD=1 -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1
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
  Definition source_file := "../../reference-sm64-decomp/src/engine/level_script.c".
  Definition normalized := true.
End Info.

Definition _AllocOnlyPool : ident := $"AllocOnlyPool".
Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _Area : ident := $"Area".
Definition _Camera : ident := $"Camera".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _FnGraphNode : ident := $"FnGraphNode".
Definition _GraphNode : ident := $"GraphNode".
Definition _GraphNodeCamera : ident := $"GraphNodeCamera".
Definition _GraphNodeDisplayList : ident := $"GraphNodeDisplayList".
Definition _GraphNodeObject : ident := $"GraphNodeObject".
Definition _GraphNodeRoot : ident := $"GraphNodeRoot".
Definition _GraphNodeScale : ident := $"GraphNodeScale".
Definition _GraphNodeStart : ident := $"GraphNodeStart".
Definition _InstantWarp : ident := $"InstantWarp".
Definition _LevelCommand : ident := $"LevelCommand".
Definition _LevelScriptJumpTable : ident := $"LevelScriptJumpTable".
Definition _Object : ident := $"Object".
Definition _ObjectNode : ident := $"ObjectNode".
Definition _ObjectWarpNode : ident := $"ObjectWarpNode".
Definition _SpawnInfo : ident := $"SpawnInfo".
Definition _Surface : ident := $"Surface".
Definition _UnusedArea28 : ident := $"UnusedArea28".
Definition _WarpNode : ident := $"WarpNode".
Definition _Waypoint : ident := $"Waypoint".
Definition _Whirlpool : ident := $"Whirlpool".
Definition __1252 : ident := $"_1252".
Definition __3650 : ident := $"_3650".
Definition __510 : ident := $"_510".
Definition __512 : ident := $"_512".
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
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _addr : ident := $"addr".
Definition _alloc_display_list : ident := $"alloc_display_list".
Definition _alloc_only_pool_alloc : ident := $"alloc_only_pool_alloc".
Definition _alloc_only_pool_init : ident := $"alloc_only_pool_init".
Definition _alloc_only_pool_resize : ident := $"alloc_only_pool_resize".
Definition _alloc_surface_pools : ident := $"alloc_surface_pools".
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
Definition _areaIndex : ident := $"areaIndex".
Definition _area_update_objects : ident := $"area_update_objects".
Definition _arg : ident := $"arg".
Definition _arg0 : ident := $"arg0".
Definition _arg0H : ident := $"arg0H".
Definition _arg1 : ident := $"arg1".
Definition _arg2 : ident := $"arg2".
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
Definition _beatBowser2 : ident := $"beatBowser2".
Definition _behavior : ident := $"behavior".
Definition _behaviorArg : ident := $"behaviorArg".
Definition _behaviorScript : ident := $"behaviorScript".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _camera : ident := $"camera".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _children : ident := $"children".
Definition _clear_area_graph_nodes : ident := $"clear_area_graph_nodes".
Definition _clear_areas : ident := $"clear_areas".
Definition _clear_objects : ident := $"clear_objects".
Definition _cmd : ident := $"cmd".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _config : ident := $"config".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _cutscene : ident := $"cutscene".
Definition _defMode : ident := $"defMode".
Definition _destArea : ident := $"destArea".
Definition _destLevel : ident := $"destLevel".
Definition _destNode : ident := $"destNode".
Definition _dialog : ident := $"dialog".
Definition _displacement : ident := $"displacement".
Definition _displayList : ident := $"displayList".
Definition _doorStatus : ident := $"doorStatus".
Definition _end_master_display_list : ident := $"end_master_display_list".
Definition _eval_script_op : ident := $"eval_script_op".
Definition _f : ident := $"f".
Definition _fadeout_music : ident := $"fadeout_music".
Definition _filler1 : ident := $"filler1".
Definition _filler2 : ident := $"filler2".
Definition _flags : ident := $"flags".
Definition _fnNode : ident := $"fnNode".
Definition _focus : ident := $"focus".
Definition _force : ident := $"force".
Definition _force_structure_alignment : ident := $"force_structure_alignment".
Definition _freePtr : ident := $"freePtr".
Definition _func : ident := $"func".
Definition _gAreaData : ident := $"gAreaData".
Definition _gAreas : ident := $"gAreas".
Definition _gCurrActNum : ident := $"gCurrActNum".
Definition _gCurrAreaIndex : ident := $"gCurrAreaIndex".
Definition _gCurrCourseNum : ident := $"gCurrCourseNum".
Definition _gCurrLevelNum : ident := $"gCurrLevelNum".
Definition _gCurrSaveFileNum : ident := $"gCurrSaveFileNum".
Definition _gCurrentArea : ident := $"gCurrentArea".
Definition _gFramebuffers : ident := $"gFramebuffers".
Definition _gLoadedGraphNodes : ident := $"gLoadedGraphNodes".
Definition _gMarioSpawnInfo : ident := $"gMarioSpawnInfo".
Definition _gObjParentGraphNode : ident := $"gObjParentGraphNode".
Definition _gZBuffer : ident := $"gZBuffer".
Definition _gd_add_to_heap : ident := $"gd_add_to_heap".
Definition _gdm_init : ident := $"gdm_init".
Definition _gdm_maketestdl : ident := $"gdm_maketestdl".
Definition _gdm_setup : ident := $"gdm_setup".
Definition _geoLayoutAddr : ident := $"geoLayoutAddr".
Definition _gfx : ident := $"gfx".
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
Definition _init_graph_node_display_list : ident := $"init_graph_node_display_list".
Definition _init_graph_node_scale : ident := $"init_graph_node_scale".
Definition _init_graph_node_start : ident := $"init_graph_node_start".
Definition _init_rcp : ident := $"init_rcp".
Definition _instantWarps : ident := $"instantWarps".
Definition _length : ident := $"length".
Definition _level_cmd_23 : ident := $"level_cmd_23".
Definition _level_cmd_2C : ident := $"level_cmd_2C".
Definition _level_cmd_2D : ident := $"level_cmd_2D".
Definition _level_cmd_38 : ident := $"level_cmd_38".
Definition _level_cmd_3A : ident := $"level_cmd_3A".
Definition _level_cmd_alloc_level_pool : ident := $"level_cmd_alloc_level_pool".
Definition _level_cmd_begin_area : ident := $"level_cmd_begin_area".
Definition _level_cmd_call : ident := $"level_cmd_call".
Definition _level_cmd_call_loop : ident := $"level_cmd_call_loop".
Definition _level_cmd_clear_level : ident := $"level_cmd_clear_level".
Definition _level_cmd_create_instant_warp : ident := $"level_cmd_create_instant_warp".
Definition _level_cmd_create_painting_warp_node : ident := $"level_cmd_create_painting_warp_node".
Definition _level_cmd_create_warp_node : ident := $"level_cmd_create_warp_node".
Definition _level_cmd_create_whirlpool : ident := $"level_cmd_create_whirlpool".
Definition _level_cmd_end_area : ident := $"level_cmd_end_area".
Definition _level_cmd_exit : ident := $"level_cmd_exit".
Definition _level_cmd_exit_and_execute : ident := $"level_cmd_exit_and_execute".
Definition _level_cmd_free_level_pool : ident := $"level_cmd_free_level_pool".
Definition _level_cmd_get_or_set_var : ident := $"level_cmd_get_or_set_var".
Definition _level_cmd_init_level : ident := $"level_cmd_init_level".
Definition _level_cmd_init_mario : ident := $"level_cmd_init_mario".
Definition _level_cmd_jump : ident := $"level_cmd_jump".
Definition _level_cmd_jump_and_link : ident := $"level_cmd_jump_and_link".
Definition _level_cmd_jump_and_link_if : ident := $"level_cmd_jump_and_link_if".
Definition _level_cmd_jump_and_link_push_arg : ident := $"level_cmd_jump_and_link_push_arg".
Definition _level_cmd_jump_if : ident := $"level_cmd_jump_if".
Definition _level_cmd_jump_repeat : ident := $"level_cmd_jump_repeat".
Definition _level_cmd_load_and_execute : ident := $"level_cmd_load_and_execute".
Definition _level_cmd_load_area : ident := $"level_cmd_load_area".
Definition _level_cmd_load_mario_head : ident := $"level_cmd_load_mario_head".
Definition _level_cmd_load_mio0 : ident := $"level_cmd_load_mio0".
Definition _level_cmd_load_mio0_texture : ident := $"level_cmd_load_mio0_texture".
Definition _level_cmd_load_model_from_dl : ident := $"level_cmd_load_model_from_dl".
Definition _level_cmd_load_model_from_geo : ident := $"level_cmd_load_model_from_geo".
Definition _level_cmd_load_raw : ident := $"level_cmd_load_raw".
Definition _level_cmd_load_to_fixed_address : ident := $"level_cmd_load_to_fixed_address".
Definition _level_cmd_loop_begin : ident := $"level_cmd_loop_begin".
Definition _level_cmd_loop_until : ident := $"level_cmd_loop_until".
Definition _level_cmd_nop : ident := $"level_cmd_nop".
Definition _level_cmd_place_object : ident := $"level_cmd_place_object".
Definition _level_cmd_pop_pool_state : ident := $"level_cmd_pop_pool_state".
Definition _level_cmd_push_pool_state : ident := $"level_cmd_push_pool_state".
Definition _level_cmd_return : ident := $"level_cmd_return".
Definition _level_cmd_set_blackout : ident := $"level_cmd_set_blackout".
Definition _level_cmd_set_gamma : ident := $"level_cmd_set_gamma".
Definition _level_cmd_set_macro_objects : ident := $"level_cmd_set_macro_objects".
Definition _level_cmd_set_mario_start_pos : ident := $"level_cmd_set_mario_start_pos".
Definition _level_cmd_set_menu_music : ident := $"level_cmd_set_menu_music".
Definition _level_cmd_set_music : ident := $"level_cmd_set_music".
Definition _level_cmd_set_register : ident := $"level_cmd_set_register".
Definition _level_cmd_set_rooms : ident := $"level_cmd_set_rooms".
Definition _level_cmd_set_terrain_data : ident := $"level_cmd_set_terrain_data".
Definition _level_cmd_set_terrain_type : ident := $"level_cmd_set_terrain_type".
Definition _level_cmd_set_transition : ident := $"level_cmd_set_transition".
Definition _level_cmd_show_dialog : ident := $"level_cmd_show_dialog".
Definition _level_cmd_skip : ident := $"level_cmd_skip".
Definition _level_cmd_skip_if : ident := $"level_cmd_skip_if".
Definition _level_cmd_skippable_nop : ident := $"level_cmd_skippable_nop".
Definition _level_cmd_sleep : ident := $"level_cmd_sleep".
Definition _level_cmd_sleep2 : ident := $"level_cmd_sleep2".
Definition _level_cmd_unload_area : ident := $"level_cmd_unload_area".
Definition _level_script_execute : ident := $"level_script_execute".
Definition _load_area : ident := $"load_area".
Definition _load_segment : ident := $"load_segment".
Definition _load_segment_decompress : ident := $"load_segment_decompress".
Definition _load_segment_decompress_heap : ident := $"load_segment_decompress_heap".
Definition _load_to_fixed_pool_addr : ident := $"load_to_fixed_pool_addr".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _macroObjects : ident := $"macroObjects".
Definition _main : ident := $"main".
Definition _main_pool_alloc : ident := $"main_pool_alloc".
Definition _main_pool_available : ident := $"main_pool_available".
Definition _main_pool_pop_state : ident := $"main_pool_pop_state".
Definition _main_pool_push_state : ident := $"main_pool_push_state".
Definition _matrixPtr : ident := $"matrixPtr".
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
Definition _object : ident := $"object".
Definition _objectSpawnInfos : ident := $"objectSpawnInfos".
Definition _op : ident := $"op".
Definition _originOffset : ident := $"originOffset".
Definition _osViBlack : ident := $"osViBlack".
Definition _osViSetSpecialFeatures : ident := $"osViSetSpecialFeatures".
Definition _paintingWarpNodes : ident := $"paintingWarpNodes".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _pitch : ident := $"pitch".
Definition _platform : ident := $"platform".
Definition _play_transition : ident := $"play_transition".
Definition _pos : ident := $"pos".
Definition _posX : ident := $"posX".
Definition _posY : ident := $"posY".
Definition _posZ : ident := $"posZ".
Definition _prev : ident := $"prev".
Definition _prevObj : ident := $"prevObj".
Definition _process_geo_layout : ident := $"process_geo_layout".
Definition _profiler_log_thread5_time : ident := $"profiler_log_thread5_time".
Definition _rawData : ident := $"rawData".
Definition _render_game : ident := $"render_game".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _result : ident := $"result".
Definition _roll : ident := $"roll".
Definition _rollScreen : ident := $"rollScreen".
Definition _room : ident := $"room".
Definition _sCurrAreaIndex : ident := $"sCurrAreaIndex".
Definition _sCurrentCmd : ident := $"sCurrentCmd".
Definition _sDelayFrames : ident := $"sDelayFrames".
Definition _sDelayFrames2 : ident := $"sDelayFrames2".
Definition _sLevelPool : ident := $"sLevelPool".
Definition _sRegister : ident := $"sRegister".
Definition _sScriptStatus : ident := $"sScriptStatus".
Definition _sStack : ident := $"sStack".
Definition _sStackBase : ident := $"sStackBase".
Definition _sStackTop : ident := $"sStackTop".
Definition _save_file_get_flags : ident := $"save_file_get_flags".
Definition _scale : ident := $"scale".
Definition _screenArea : ident := $"screenArea".
Definition _segmented_to_virtual : ident := $"segmented_to_virtual".
Definition _set_background_music : ident := $"set_background_music".
Definition _sharedChild : ident := $"sharedChild".
Definition _size : ident := $"size".
Definition _spawnInfo : ident := $"spawnInfo".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
Definition _startPtr : ident := $"startPtr".
Definition _stop_sounds_in_continuous_banks : ident := $"stop_sounds_in_continuous_banks".
Definition _strength : ident := $"strength".
Definition _surfaceRooms : ident := $"surfaceRooms".
Definition _targetAddr : ident := $"targetAddr".
Definition _terrainData : ident := $"terrainData".
Definition _terrainType : ident := $"terrainType".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _totalSpace : ident := $"totalSpace".
Definition _transform : ident := $"transform".
Definition _type : ident := $"type".
Definition _unk00 : ident := $"unk00".
Definition _unk02 : ident := $"unk02".
Definition _unk04 : ident := $"unk04".
Definition _unk06 : ident := $"unk06".
Definition _unk08 : ident := $"unk08".
Definition _unk15 : ident := $"unk15".
Definition _unk4C : ident := $"unk4C".
Definition _unload_area : ident := $"unload_area".
Definition _unload_mario_area : ident := $"unload_mario_area".
Definition _unused : ident := $"unused".
Definition _unused1 : ident := $"unused1".
Definition _unused2 : ident := $"unused2".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _unusedVec1 : ident := $"unusedVec1".
Definition _upperY : ident := $"upperY".
Definition _usedSpace : ident := $"usedSpace".
Definition _val : ident := $"val".
Definition _val1 : ident := $"val1".
Definition _val2 : ident := $"val2".
Definition _val3 : ident := $"val3".
Definition _val4 : ident := $"val4".
Definition _val7 : ident := $"val7".
Definition _values : ident := $"values".
Definition _vec3s_copy : ident := $"vec3s_copy".
Definition _vec3s_set : ident := $"vec3s_set".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _views : ident := $"views".
Definition _w0 : ident := $"w0".
Definition _w1 : ident := $"w1".
Definition _warp : ident := $"warp".
Definition _warpNode : ident := $"warpNode".
Definition _warpNodes : ident := $"warpNodes".
Definition _whirlpool : ident := $"whirlpool".
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

Definition v_gFramebuffers := {|
  gvar_info := (tarray (tarray tushort 76800) 3);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gZBuffer := {|
  gvar_info := (tarray tushort 76800);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gObjParentGraphNode := {|
  gvar_info := (Tstruct _GraphNode noattr);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gLoadedGraphNodes := {|
  gvar_info := (tptr (tptr (Tstruct _GraphNode noattr)));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAreaData := {|
  gvar_info := (tarray (Tstruct _Area noattr) 0);
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

Definition v_gMarioSpawnInfo := {|
  gvar_info := (tptr (Tstruct _SpawnInfo noattr));
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

Definition v_sStack := {|
  gvar_info := (tarray tuint 32);
  gvar_init := (Init_space 128 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sLevelPool := {|
  gvar_info := (tptr (Tstruct _AllocOnlyPool noattr));
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDelayFrames := {|
  gvar_info := tushort;
  gvar_init := (Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDelayFrames2 := {|
  gvar_info := tushort;
  gvar_init := (Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sCurrAreaIndex := {|
  gvar_info := tshort;
  gvar_init := (Init_int16 (Int.repr (-1)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sStackTop := {|
  gvar_info := (tptr tuint);
  gvar_init := (Init_addrof _sStack (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sStackBase := {|
  gvar_info := (tptr tuint);
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sScriptStatus := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sRegister := {|
  gvar_info := tint;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sCurrentCmd := {|
  gvar_info := (tptr (Tstruct _LevelCommand noattr));
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_eval_script_op := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_op, tschar) :: (_arg, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_result, tint) :: (_t'8, tint) :: (_t'7, tint) ::
               (_t'6, tint) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _result (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sswitch (Etempvar _op tschar)
      (LScons (Some 0)
        (Ssequence
          (Ssequence
            (Sset _t'8 (Evar _sRegister tint))
            (Sset _result
              (Ebinop Oand (Etempvar _t'8 tint) (Etempvar _arg tint) tint)))
          Sbreak)
        (LScons (Some 1)
          (Ssequence
            (Ssequence
              (Sset _t'7 (Evar _sRegister tint))
              (Sset _result
                (Eunop Onotbool
                  (Ebinop Oand (Etempvar _t'7 tint) (Etempvar _arg tint)
                    tint) tint)))
            Sbreak)
          (LScons (Some 2)
            (Ssequence
              (Ssequence
                (Sset _t'6 (Evar _sRegister tint))
                (Sset _result
                  (Ebinop Oeq (Etempvar _t'6 tint) (Etempvar _arg tint) tint)))
              Sbreak)
            (LScons (Some 3)
              (Ssequence
                (Ssequence
                  (Sset _t'5 (Evar _sRegister tint))
                  (Sset _result
                    (Ebinop One (Etempvar _t'5 tint) (Etempvar _arg tint)
                      tint)))
                Sbreak)
              (LScons (Some 4)
                (Ssequence
                  (Ssequence
                    (Sset _t'4 (Evar _sRegister tint))
                    (Sset _result
                      (Ebinop Olt (Etempvar _t'4 tint) (Etempvar _arg tint)
                        tint)))
                  Sbreak)
                (LScons (Some 5)
                  (Ssequence
                    (Ssequence
                      (Sset _t'3 (Evar _sRegister tint))
                      (Sset _result
                        (Ebinop Ole (Etempvar _t'3 tint) (Etempvar _arg tint)
                          tint)))
                    Sbreak)
                  (LScons (Some 6)
                    (Ssequence
                      (Ssequence
                        (Sset _t'2 (Evar _sRegister tint))
                        (Sset _result
                          (Ebinop Ogt (Etempvar _t'2 tint)
                            (Etempvar _arg tint) tint)))
                      Sbreak)
                    (LScons (Some 7)
                      (Ssequence
                        (Ssequence
                          (Sset _t'1 (Evar _sRegister tint))
                          (Sset _result
                            (Ebinop Oge (Etempvar _t'1 tint)
                              (Etempvar _arg tint) tint)))
                        Sbreak)
                      LSnil)))))))))
    (Sreturn (Some (Etempvar _result tint)))))
|}.

Definition f_level_cmd_load_and_execute := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'3, (tptr tvoid)) :: (_t'2, (tptr tuint)) ::
               (_t'1, (tptr tuint)) :: (_t'16, (tptr tvoid)) ::
               (_t'15, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'14, (tptr tvoid)) ::
               (_t'13, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'12, tshort) ::
               (_t'11, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'10, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'9, tuchar) ::
               (_t'8, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'7, (tptr tuint)) :: (_t'6, (tptr tuint)) ::
               (_t'5, (tptr tvoid)) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Scall None (Evar _main_pool_push_state (Tfunction nil tuint cc_default))
    nil)
  (Ssequence
    (Ssequence
      (Sset _t'11 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'12
          (Ederef
            (Ecast
              (Ebinop Oadd
                (Ebinop Oor
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Econst_int (Int.repr 3) tint) tint)
                  (Ebinop Oshl
                    (Ebinop Oand (Econst_int (Int.repr 2) tint)
                      (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                      tint)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                (Ecast (Etempvar _t'11 (tptr (Tstruct _LevelCommand noattr)))
                  (tptr tuchar)) (tptr tuchar)) (tptr tshort)) tshort))
        (Ssequence
          (Sset _t'13
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'14
              (Ederef
                (Ecast
                  (Ebinop Oadd
                    (Ebinop Oor
                      (Ebinop Oand (Econst_int (Int.repr 4) tint)
                        (Econst_int (Int.repr 3) tint) tint)
                      (Ebinop Oshl
                        (Ebinop Oand (Econst_int (Int.repr 4) tint)
                          (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                          tint)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                    (Ecast
                      (Etempvar _t'13 (tptr (Tstruct _LevelCommand noattr)))
                      (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
                (tptr tvoid)))
            (Ssequence
              (Sset _t'15
                (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
              (Ssequence
                (Sset _t'16
                  (Ederef
                    (Ecast
                      (Ebinop Oadd
                        (Ebinop Oor
                          (Ebinop Oand (Econst_int (Int.repr 8) tint)
                            (Econst_int (Int.repr 3) tint) tint)
                          (Ebinop Oshl
                            (Ebinop Oand (Econst_int (Int.repr 8) tint)
                              (Eunop Onotint (Econst_int (Int.repr 3) tint)
                                tint) tint)
                            (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                              (Econst_int (Int.repr 3) tint) tuint) tint)
                          tint)
                        (Ecast
                          (Etempvar _t'15 (tptr (Tstruct _LevelCommand noattr)))
                          (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
                    (tptr tvoid)))
                (Scall None
                  (Evar _load_segment (Tfunction
                                        (tint :: (tptr tuchar) ::
                                         (tptr tuchar) :: tuint :: nil)
                                        (tptr tvoid) cc_default))
                  ((Etempvar _t'12 tshort) ::
                   (Etempvar _t'14 (tptr tvoid)) ::
                   (Etempvar _t'16 (tptr tvoid)) ::
                   (Econst_int (Int.repr 0) tint) :: nil))))))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'1 (Evar _sStackTop (tptr tuint)))
          (Sassign (Evar _sStackTop (tptr tuint))
            (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
              (Econst_int (Int.repr 1) tint) (tptr tuint))))
        (Ssequence
          (Sset _t'8
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'9
              (Efield
                (Ederef (Etempvar _t'8 (tptr (Tstruct _LevelCommand noattr)))
                  (Tstruct _LevelCommand noattr)) _size tuchar))
            (Ssequence
              (Sset _t'10
                (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
              (Sassign (Ederef (Etempvar _t'1 (tptr tuint)) tuint)
                (Ecast
                  (Ecast
                    (Ebinop Oadd
                      (Ebinop Oshl (Etempvar _t'9 tuchar)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint)
                      (Ecast
                        (Etempvar _t'10 (tptr (Tstruct _LevelCommand noattr)))
                        (tptr tuchar)) (tptr tuchar))
                    (tptr (Tstruct _LevelCommand noattr))) tuint))))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'2 (Evar _sStackTop (tptr tuint)))
            (Sassign (Evar _sStackTop (tptr tuint))
              (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
                (Econst_int (Int.repr 1) tint) (tptr tuint))))
          (Ssequence
            (Sset _t'7 (Evar _sStackBase (tptr tuint)))
            (Sassign (Ederef (Etempvar _t'2 (tptr tuint)) tuint)
              (Ecast (Etempvar _t'7 (tptr tuint)) tuint))))
        (Ssequence
          (Ssequence
            (Sset _t'6 (Evar _sStackTop (tptr tuint)))
            (Sassign (Evar _sStackBase (tptr tuint))
              (Etempvar _t'6 (tptr tuint))))
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
              (Ssequence
                (Sset _t'5
                  (Ederef
                    (Ecast
                      (Ebinop Oadd
                        (Ebinop Oor
                          (Ebinop Oand (Econst_int (Int.repr 12) tint)
                            (Econst_int (Int.repr 3) tint) tint)
                          (Ebinop Oshl
                            (Ebinop Oand (Econst_int (Int.repr 12) tint)
                              (Eunop Onotint (Econst_int (Int.repr 3) tint)
                                tint) tint)
                            (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                              (Econst_int (Int.repr 3) tint) tuint) tint)
                          tint)
                        (Ecast
                          (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
                          (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
                    (tptr tvoid)))
                (Scall (Some _t'3)
                  (Evar _segmented_to_virtual (Tfunction
                                                ((tptr tvoid) :: nil)
                                                (tptr tvoid) cc_default))
                  ((Etempvar _t'5 (tptr tvoid)) :: nil))))
            (Sassign
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
              (Etempvar _t'3 (tptr tvoid)))))))))
|}.

Definition f_level_cmd_exit_and_execute := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_targetAddr, (tptr tvoid)) :: (_t'1, (tptr tvoid)) ::
               (_t'9, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'8, (tptr tvoid)) ::
               (_t'7, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'6, (tptr tvoid)) ::
               (_t'5, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'4, tshort) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'2, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Sset _targetAddr
      (Ederef
        (Ecast
          (Ebinop Oadd
            (Ebinop Oor
              (Ebinop Oand (Econst_int (Int.repr 12) tint)
                (Econst_int (Int.repr 3) tint) tint)
              (Ebinop Oshl
                (Ebinop Oand (Econst_int (Int.repr 12) tint)
                  (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) tint)
            (Ecast (Etempvar _t'9 (tptr (Tstruct _LevelCommand noattr)))
              (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
        (tptr tvoid))))
  (Ssequence
    (Scall None (Evar _main_pool_pop_state (Tfunction nil tuint cc_default))
      nil)
    (Ssequence
      (Scall None
        (Evar _main_pool_push_state (Tfunction nil tuint cc_default)) nil)
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'4
              (Ederef
                (Ecast
                  (Ebinop Oadd
                    (Ebinop Oor
                      (Ebinop Oand (Econst_int (Int.repr 2) tint)
                        (Econst_int (Int.repr 3) tint) tint)
                      (Ebinop Oshl
                        (Ebinop Oand (Econst_int (Int.repr 2) tint)
                          (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                          tint)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                    (Ecast
                      (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
                      (tptr tuchar)) (tptr tuchar)) (tptr tshort)) tshort))
            (Ssequence
              (Sset _t'5
                (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
              (Ssequence
                (Sset _t'6
                  (Ederef
                    (Ecast
                      (Ebinop Oadd
                        (Ebinop Oor
                          (Ebinop Oand (Econst_int (Int.repr 4) tint)
                            (Econst_int (Int.repr 3) tint) tint)
                          (Ebinop Oshl
                            (Ebinop Oand (Econst_int (Int.repr 4) tint)
                              (Eunop Onotint (Econst_int (Int.repr 3) tint)
                                tint) tint)
                            (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                              (Econst_int (Int.repr 3) tint) tuint) tint)
                          tint)
                        (Ecast
                          (Etempvar _t'5 (tptr (Tstruct _LevelCommand noattr)))
                          (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
                    (tptr tvoid)))
                (Ssequence
                  (Sset _t'7
                    (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                  (Ssequence
                    (Sset _t'8
                      (Ederef
                        (Ecast
                          (Ebinop Oadd
                            (Ebinop Oor
                              (Ebinop Oand (Econst_int (Int.repr 8) tint)
                                (Econst_int (Int.repr 3) tint) tint)
                              (Ebinop Oshl
                                (Ebinop Oand (Econst_int (Int.repr 8) tint)
                                  (Eunop Onotint
                                    (Econst_int (Int.repr 3) tint) tint)
                                  tint)
                                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                  (Econst_int (Int.repr 3) tint) tuint) tint)
                              tint)
                            (Ecast
                              (Etempvar _t'7 (tptr (Tstruct _LevelCommand noattr)))
                              (tptr tuchar)) (tptr tuchar))
                          (tptr (tptr tvoid))) (tptr tvoid)))
                    (Scall None
                      (Evar _load_segment (Tfunction
                                            (tint :: (tptr tuchar) ::
                                             (tptr tuchar) :: tuint :: nil)
                                            (tptr tvoid) cc_default))
                      ((Etempvar _t'4 tshort) ::
                       (Etempvar _t'6 (tptr tvoid)) ::
                       (Etempvar _t'8 (tptr tvoid)) ::
                       (Econst_int (Int.repr 0) tint) :: nil))))))))
        (Ssequence
          (Ssequence
            (Sset _t'2 (Evar _sStackBase (tptr tuint)))
            (Sassign (Evar _sStackTop (tptr tuint))
              (Etempvar _t'2 (tptr tuint))))
          (Ssequence
            (Scall (Some _t'1)
              (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                            (tptr tvoid) cc_default))
              ((Etempvar _targetAddr (tptr tvoid)) :: nil))
            (Sassign
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
              (Etempvar _t'1 (tptr tvoid)))))))))
|}.

Definition f_level_cmd_exit := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, (tptr tuint)) :: (_t'1, (tptr tuint)) ::
               (_t'7, (tptr tuint)) :: (_t'6, (tptr tuint)) ::
               (_t'5, tuint) :: (_t'4, (tptr tuint)) :: (_t'3, tuint) :: nil);
  fn_body :=
(Ssequence
  (Scall None (Evar _main_pool_pop_state (Tfunction nil tuint cc_default))
    nil)
  (Ssequence
    (Ssequence
      (Sset _t'7 (Evar _sStackBase (tptr tuint)))
      (Sassign (Evar _sStackTop (tptr tuint)) (Etempvar _t'7 (tptr tuint))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'6 (Evar _sStackTop (tptr tuint)))
            (Sset _t'1
              (Ecast
                (Ebinop Osub (Etempvar _t'6 (tptr tuint))
                  (Econst_int (Int.repr 1) tint) (tptr tuint)) (tptr tuint))))
          (Sassign (Evar _sStackTop (tptr tuint))
            (Etempvar _t'1 (tptr tuint))))
        (Ssequence
          (Sset _t'5 (Ederef (Etempvar _t'1 (tptr tuint)) tuint))
          (Sassign (Evar _sStackBase (tptr tuint))
            (Ecast (Etempvar _t'5 tuint) (tptr tuint)))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'4 (Evar _sStackTop (tptr tuint)))
            (Sset _t'2
              (Ecast
                (Ebinop Osub (Etempvar _t'4 (tptr tuint))
                  (Econst_int (Int.repr 1) tint) (tptr tuint)) (tptr tuint))))
          (Sassign (Evar _sStackTop (tptr tuint))
            (Etempvar _t'2 (tptr tuint))))
        (Ssequence
          (Sset _t'3 (Ederef (Etempvar _t'2 (tptr tuint)) tuint))
          (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
            (Ecast (Etempvar _t'3 tuint)
              (tptr (Tstruct _LevelCommand noattr)))))))))
|}.

Definition f_level_cmd_sleep := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tushort) :: (_t'8, tshort) ::
               (_t'7, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'6, tushort) :: (_t'5, tuchar) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'2, tushort) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _sScriptStatus tshort) (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sset _t'2 (Evar _sDelayFrames tushort))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tushort)
                   (Econst_int (Int.repr 0) tint) tint)
      (Ssequence
        (Sset _t'7 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'8
            (Ederef
              (Ecast
                (Ebinop Oadd
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 2) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 2) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (Ecast
                    (Etempvar _t'7 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar)) (tptr tuchar)) (tptr tshort)) tshort))
          (Sassign (Evar _sDelayFrames tushort) (Etempvar _t'8 tshort))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'6 (Evar _sDelayFrames tushort))
            (Sset _t'1
              (Ecast
                (Ebinop Osub (Etempvar _t'6 tushort)
                  (Econst_int (Int.repr 1) tint) tint) tushort)))
          (Sassign (Evar _sDelayFrames tushort) (Etempvar _t'1 tushort)))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tushort)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'3
                (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
              (Ssequence
                (Sset _t'4
                  (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                (Ssequence
                  (Sset _t'5
                    (Efield
                      (Ederef
                        (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
                        (Tstruct _LevelCommand noattr)) _size tuchar))
                  (Sassign
                    (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
                    (Ecast
                      (Ebinop Oadd
                        (Ecast
                          (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
                          (tptr tuchar))
                        (Ebinop Oshl (Etempvar _t'5 tuchar)
                          (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                            (Econst_int (Int.repr 3) tint) tuint) tint)
                        (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr)))))))
            (Sassign (Evar _sScriptStatus tshort)
              (Econst_int (Int.repr 1) tint)))
          Sskip)))))
|}.

Definition f_level_cmd_sleep2 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tushort) :: (_t'8, tshort) ::
               (_t'7, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'6, tushort) :: (_t'5, tuchar) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'2, tushort) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _sScriptStatus tshort) (Econst_int (Int.repr (-1)) tint))
  (Ssequence
    (Sset _t'2 (Evar _sDelayFrames2 tushort))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tushort)
                   (Econst_int (Int.repr 0) tint) tint)
      (Ssequence
        (Sset _t'7 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'8
            (Ederef
              (Ecast
                (Ebinop Oadd
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 2) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 2) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (Ecast
                    (Etempvar _t'7 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar)) (tptr tuchar)) (tptr tshort)) tshort))
          (Sassign (Evar _sDelayFrames2 tushort) (Etempvar _t'8 tshort))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'6 (Evar _sDelayFrames2 tushort))
            (Sset _t'1
              (Ecast
                (Ebinop Osub (Etempvar _t'6 tushort)
                  (Econst_int (Int.repr 1) tint) tint) tushort)))
          (Sassign (Evar _sDelayFrames2 tushort) (Etempvar _t'1 tushort)))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tushort)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'3
                (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
              (Ssequence
                (Sset _t'4
                  (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                (Ssequence
                  (Sset _t'5
                    (Efield
                      (Ederef
                        (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
                        (Tstruct _LevelCommand noattr)) _size tuchar))
                  (Sassign
                    (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
                    (Ecast
                      (Ebinop Oadd
                        (Ecast
                          (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
                          (tptr tuchar))
                        (Ebinop Oshl (Etempvar _t'5 tuchar)
                          (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                            (Econst_int (Int.repr 3) tint) tuint) tint)
                        (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr)))))))
            (Sassign (Evar _sScriptStatus tshort)
              (Econst_int (Int.repr 1) tint)))
          Sskip)))))
|}.

Definition f_level_cmd_jump := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: (_t'3, (tptr tvoid)) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'3
        (Ederef
          (Ecast
            (Ebinop Oadd
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 4) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 4) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (Ecast (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
          (tptr tvoid)))
      (Scall (Some _t'1)
        (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                      (tptr tvoid) cc_default))
        ((Etempvar _t'3 (tptr tvoid)) :: nil))))
  (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
    (Etempvar _t'1 (tptr tvoid))))
|}.

Definition f_level_cmd_jump_and_link := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, (tptr tvoid)) :: (_t'1, (tptr tuint)) ::
               (_t'7, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'6, tuchar) ::
               (_t'5, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'4, (tptr tvoid)) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'1 (Evar _sStackTop (tptr tuint)))
      (Sassign (Evar _sStackTop (tptr tuint))
        (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
          (Econst_int (Int.repr 1) tint) (tptr tuint))))
    (Ssequence
      (Sset _t'5 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _t'5 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Ssequence
          (Sset _t'7
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Sassign (Ederef (Etempvar _t'1 (tptr tuint)) tuint)
            (Ecast
              (Ecast
                (Ebinop Oadd
                  (Ebinop Oshl (Etempvar _t'6 tuchar)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint)
                  (Ecast
                    (Etempvar _t'7 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar)) (tptr tuchar))
                (tptr (Tstruct _LevelCommand noattr))) tuint))))))
  (Ssequence
    (Ssequence
      (Sset _t'3 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'4
          (Ederef
            (Ecast
              (Ebinop Oadd
                (Ebinop Oor
                  (Ebinop Oand (Econst_int (Int.repr 4) tint)
                    (Econst_int (Int.repr 3) tint) tint)
                  (Ebinop Oshl
                    (Ebinop Oand (Econst_int (Int.repr 4) tint)
                      (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                      tint)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                (Ecast (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
                  (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
            (tptr tvoid)))
        (Scall (Some _t'2)
          (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                        (tptr tvoid) cc_default))
          ((Etempvar _t'4 (tptr tvoid)) :: nil))))
    (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
      (Etempvar _t'2 (tptr tvoid)))))
|}.

Definition f_level_cmd_return := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tuint)) :: (_t'3, (tptr tuint)) ::
               (_t'2, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'3 (Evar _sStackTop (tptr tuint)))
      (Sset _t'1
        (Ecast
          (Ebinop Osub (Etempvar _t'3 (tptr tuint))
            (Econst_int (Int.repr 1) tint) (tptr tuint)) (tptr tuint))))
    (Sassign (Evar _sStackTop (tptr tuint)) (Etempvar _t'1 (tptr tuint))))
  (Ssequence
    (Sset _t'2 (Ederef (Etempvar _t'1 (tptr tuint)) tuint))
    (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
      (Ecast (Etempvar _t'2 tuint) (tptr (Tstruct _LevelCommand noattr))))))
|}.

Definition f_level_cmd_jump_and_link_push_arg := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, (tptr tuint)) :: (_t'1, (tptr tuint)) ::
               (_t'10, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'9, tuchar) ::
               (_t'8, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'7, tshort) ::
               (_t'6, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'5, tuchar) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'1 (Evar _sStackTop (tptr tuint)))
      (Sassign (Evar _sStackTop (tptr tuint))
        (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
          (Econst_int (Int.repr 1) tint) (tptr tuint))))
    (Ssequence
      (Sset _t'8 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'9
          (Efield
            (Ederef (Etempvar _t'8 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Ssequence
          (Sset _t'10
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Sassign (Ederef (Etempvar _t'1 (tptr tuint)) tuint)
            (Ecast
              (Ecast
                (Ebinop Oadd
                  (Ebinop Oshl (Etempvar _t'9 tuchar)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint)
                  (Ecast
                    (Etempvar _t'10 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar)) (tptr tuchar))
                (tptr (Tstruct _LevelCommand noattr))) tuint))))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'2 (Evar _sStackTop (tptr tuint)))
        (Sassign (Evar _sStackTop (tptr tuint))
          (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
            (Econst_int (Int.repr 1) tint) (tptr tuint))))
      (Ssequence
        (Sset _t'6 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'7
            (Ederef
              (Ecast
                (Ebinop Oadd
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 2) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 2) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (Ecast
                    (Etempvar _t'6 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar)) (tptr tuchar)) (tptr tshort)) tshort))
          (Sassign (Ederef (Etempvar _t'2 (tptr tuint)) tuint)
            (Etempvar _t'7 tshort)))))
    (Ssequence
      (Sset _t'3 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'4 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
                (Tstruct _LevelCommand noattr)) _size tuchar))
          (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
            (Ecast
              (Ebinop Oadd
                (Ecast (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
                  (tptr tuchar))
                (Ebinop Oshl (Etempvar _t'5 tuchar)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint)
                (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr)))))))))
|}.

Definition f_level_cmd_jump_repeat := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_val, tint) :: (_t'1, tint) :: (_t'11, (tptr tuint)) ::
               (_t'10, tuint) :: (_t'9, (tptr tuint)) ::
               (_t'8, (tptr tuint)) :: (_t'7, tuint) ::
               (_t'6, (tptr tuint)) :: (_t'5, tuchar) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'2, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'11 (Evar _sStackTop (tptr tuint)))
    (Sset _val
      (Ederef
        (Ebinop Osub (Etempvar _t'11 (tptr tuint))
          (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint)))
  (Sifthenelse (Ebinop Oeq (Etempvar _val tint)
                 (Econst_int (Int.repr 0) tint) tint)
    (Ssequence
      (Sset _t'9 (Evar _sStackTop (tptr tuint)))
      (Ssequence
        (Sset _t'10
          (Ederef
            (Ebinop Osub (Etempvar _t'9 (tptr tuint))
              (Econst_int (Int.repr 2) tint) (tptr tuint)) tuint))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast (Etempvar _t'10 tuint)
            (tptr (Tstruct _LevelCommand noattr))))))
    (Ssequence
      (Ssequence
        (Sset _t'1
          (Ecast
            (Ebinop Osub (Etempvar _val tint) (Econst_int (Int.repr 1) tint)
              tint) tint))
        (Sset _val (Etempvar _t'1 tint)))
      (Sifthenelse (Ebinop One (Etempvar _t'1 tint)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'8 (Evar _sStackTop (tptr tuint)))
            (Sassign
              (Ederef
                (Ebinop Osub (Etempvar _t'8 (tptr tuint))
                  (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint)
              (Etempvar _val tint)))
          (Ssequence
            (Sset _t'6 (Evar _sStackTop (tptr tuint)))
            (Ssequence
              (Sset _t'7
                (Ederef
                  (Ebinop Osub (Etempvar _t'6 (tptr tuint))
                    (Econst_int (Int.repr 2) tint) (tptr tuint)) tuint))
              (Sassign
                (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
                (Ecast (Etempvar _t'7 tuint)
                  (tptr (Tstruct _LevelCommand noattr)))))))
        (Ssequence
          (Ssequence
            (Sset _t'3
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
            (Ssequence
              (Sset _t'4
                (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef
                      (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
                      (Tstruct _LevelCommand noattr)) _size tuchar))
                (Sassign
                  (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
                  (Ecast
                    (Ebinop Oadd
                      (Ecast
                        (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
                        (tptr tuchar))
                      (Ebinop Oshl (Etempvar _t'5 tuchar)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint)
                      (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr)))))))
          (Ssequence
            (Sset _t'2 (Evar _sStackTop (tptr tuint)))
            (Sassign (Evar _sStackTop (tptr tuint))
              (Ebinop Osub (Etempvar _t'2 (tptr tuint))
                (Econst_int (Int.repr 2) tint) (tptr tuint)))))))))
|}.

Definition f_level_cmd_loop_begin := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, (tptr tuint)) :: (_t'1, (tptr tuint)) ::
               (_t'8, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'7, tuchar) ::
               (_t'6, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'5, tuchar) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'1 (Evar _sStackTop (tptr tuint)))
      (Sassign (Evar _sStackTop (tptr tuint))
        (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
          (Econst_int (Int.repr 1) tint) (tptr tuint))))
    (Ssequence
      (Sset _t'6 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'7
          (Efield
            (Ederef (Etempvar _t'6 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Ssequence
          (Sset _t'8
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Sassign (Ederef (Etempvar _t'1 (tptr tuint)) tuint)
            (Ecast
              (Ecast
                (Ebinop Oadd
                  (Ebinop Oshl (Etempvar _t'7 tuchar)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint)
                  (Ecast
                    (Etempvar _t'8 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar)) (tptr tuchar))
                (tptr (Tstruct _LevelCommand noattr))) tuint))))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'2 (Evar _sStackTop (tptr tuint)))
        (Sassign (Evar _sStackTop (tptr tuint))
          (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
            (Econst_int (Int.repr 1) tint) (tptr tuint))))
      (Sassign (Ederef (Etempvar _t'2 (tptr tuint)) tuint)
        (Econst_int (Int.repr 0) tint)))
    (Ssequence
      (Sset _t'3 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'4 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
                (Tstruct _LevelCommand noattr)) _size tuchar))
          (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
            (Ecast
              (Ebinop Oadd
                (Ecast (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
                  (tptr tuchar))
                (Ebinop Oshl (Etempvar _t'5 tuchar)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint)
                (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr)))))))))
|}.

Definition f_level_cmd_loop_until := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'11, tint) ::
               (_t'10, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'9, tuchar) ::
               (_t'8, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'7, tuchar) ::
               (_t'6, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'5, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'4, (tptr tuint)) :: (_t'3, tuint) ::
               (_t'2, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'9
        (Ederef
          (Ecast
            (Ebinop Oadd
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (Ecast (Etempvar _t'8 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar)) (tptr tuchar)) (tptr tuchar)) tuchar))
      (Ssequence
        (Sset _t'10
          (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'11
            (Ederef
              (Ecast
                (Ebinop Oadd
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 4) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 4) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (Ecast
                    (Etempvar _t'10 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar)) (tptr tuchar)) (tptr tint)) tint))
          (Scall (Some _t'1)
            (Evar _eval_script_op (Tfunction (tschar :: tint :: nil) tint
                                    cc_default))
            ((Etempvar _t'9 tuchar) :: (Etempvar _t'11 tint) :: nil))))))
  (Sifthenelse (Ebinop One (Etempvar _t'1 tint)
                 (Econst_int (Int.repr 0) tint) tint)
    (Ssequence
      (Ssequence
        (Sset _t'5 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'6
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'7
              (Efield
                (Ederef (Etempvar _t'6 (tptr (Tstruct _LevelCommand noattr)))
                  (Tstruct _LevelCommand noattr)) _size tuchar))
            (Sassign
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
              (Ecast
                (Ebinop Oadd
                  (Ecast
                    (Etempvar _t'5 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar))
                  (Ebinop Oshl (Etempvar _t'7 tuchar)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint)
                  (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr)))))))
      (Ssequence
        (Sset _t'4 (Evar _sStackTop (tptr tuint)))
        (Sassign (Evar _sStackTop (tptr tuint))
          (Ebinop Osub (Etempvar _t'4 (tptr tuint))
            (Econst_int (Int.repr 2) tint) (tptr tuint)))))
    (Ssequence
      (Sset _t'2 (Evar _sStackTop (tptr tuint)))
      (Ssequence
        (Sset _t'3
          (Ederef
            (Ebinop Osub (Etempvar _t'2 (tptr tuint))
              (Econst_int (Int.repr 2) tint) (tptr tuint)) tuint))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast (Etempvar _t'3 tuint) (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_jump_if := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, (tptr tvoid)) :: (_t'11, tint) ::
               (_t'10, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'9, tuchar) ::
               (_t'8, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'7, (tptr tvoid)) ::
               (_t'6, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'5, tuchar) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'9
        (Ederef
          (Ecast
            (Ebinop Oadd
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (Ecast (Etempvar _t'8 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar)) (tptr tuchar)) (tptr tuchar)) tuchar))
      (Ssequence
        (Sset _t'10
          (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'11
            (Ederef
              (Ecast
                (Ebinop Oadd
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 4) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 4) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (Ecast
                    (Etempvar _t'10 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar)) (tptr tuchar)) (tptr tint)) tint))
          (Scall (Some _t'2)
            (Evar _eval_script_op (Tfunction (tschar :: tint :: nil) tint
                                    cc_default))
            ((Etempvar _t'9 tuchar) :: (Etempvar _t'11 tint) :: nil))))))
  (Sifthenelse (Ebinop One (Etempvar _t'2 tint)
                 (Econst_int (Int.repr 0) tint) tint)
    (Ssequence
      (Ssequence
        (Sset _t'6 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'7
            (Ederef
              (Ecast
                (Ebinop Oadd
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 8) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 8) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (Ecast
                    (Etempvar _t'6 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
              (tptr tvoid)))
          (Scall (Some _t'1)
            (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                          (tptr tvoid) cc_default))
            ((Etempvar _t'7 (tptr tvoid)) :: nil))))
      (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
        (Etempvar _t'1 (tptr tvoid))))
    (Ssequence
      (Sset _t'3 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'4 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
                (Tstruct _LevelCommand noattr)) _size tuchar))
          (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
            (Ecast
              (Ebinop Oadd
                (Ecast (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
                  (tptr tuchar))
                (Ebinop Oshl (Etempvar _t'5 tuchar)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint)
                (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr)))))))))
|}.

Definition f_level_cmd_jump_and_link_if := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, (tptr tvoid)) ::
               (_t'1, (tptr tuint)) :: (_t'15, tint) ::
               (_t'14, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'13, tuchar) ::
               (_t'12, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'11, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'10, tuchar) ::
               (_t'9, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'8, (tptr tvoid)) ::
               (_t'7, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'6, tuchar) ::
               (_t'5, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'12 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'13
        (Ederef
          (Ecast
            (Ebinop Oadd
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (Ecast (Etempvar _t'12 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar)) (tptr tuchar)) (tptr tuchar)) tuchar))
      (Ssequence
        (Sset _t'14
          (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'15
            (Ederef
              (Ecast
                (Ebinop Oadd
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 4) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 4) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (Ecast
                    (Etempvar _t'14 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar)) (tptr tuchar)) (tptr tint)) tint))
          (Scall (Some _t'3)
            (Evar _eval_script_op (Tfunction (tschar :: tint :: nil) tint
                                    cc_default))
            ((Etempvar _t'13 tuchar) :: (Etempvar _t'15 tint) :: nil))))))
  (Sifthenelse (Ebinop One (Etempvar _t'3 tint)
                 (Econst_int (Int.repr 0) tint) tint)
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'1 (Evar _sStackTop (tptr tuint)))
          (Sassign (Evar _sStackTop (tptr tuint))
            (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
              (Econst_int (Int.repr 1) tint) (tptr tuint))))
        (Ssequence
          (Sset _t'9
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'10
              (Efield
                (Ederef (Etempvar _t'9 (tptr (Tstruct _LevelCommand noattr)))
                  (Tstruct _LevelCommand noattr)) _size tuchar))
            (Ssequence
              (Sset _t'11
                (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
              (Sassign (Ederef (Etempvar _t'1 (tptr tuint)) tuint)
                (Ecast
                  (Ecast
                    (Ebinop Oadd
                      (Ebinop Oshl (Etempvar _t'10 tuchar)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint)
                      (Ecast
                        (Etempvar _t'11 (tptr (Tstruct _LevelCommand noattr)))
                        (tptr tuchar)) (tptr tuchar))
                    (tptr (Tstruct _LevelCommand noattr))) tuint))))))
      (Ssequence
        (Ssequence
          (Sset _t'7
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'8
              (Ederef
                (Ecast
                  (Ebinop Oadd
                    (Ebinop Oor
                      (Ebinop Oand (Econst_int (Int.repr 8) tint)
                        (Econst_int (Int.repr 3) tint) tint)
                      (Ebinop Oshl
                        (Ebinop Oand (Econst_int (Int.repr 8) tint)
                          (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                          tint)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                    (Ecast
                      (Etempvar _t'7 (tptr (Tstruct _LevelCommand noattr)))
                      (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
                (tptr tvoid)))
            (Scall (Some _t'2)
              (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                            (tptr tvoid) cc_default))
              ((Etempvar _t'8 (tptr tvoid)) :: nil))))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Etempvar _t'2 (tptr tvoid)))))
    (Ssequence
      (Sset _t'4 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'5 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _t'5 (tptr (Tstruct _LevelCommand noattr)))
                (Tstruct _LevelCommand noattr)) _size tuchar))
          (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
            (Ecast
              (Ebinop Oadd
                (Ecast (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
                  (tptr tuchar))
                (Ebinop Oshl (Etempvar _t'6 tuchar)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint)
                (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr)))))))))
|}.

Definition f_level_cmd_skip_if := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) :: (_t'16, tint) ::
               (_t'15, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'14, tuchar) ::
               (_t'13, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'12, tuchar) ::
               (_t'11, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'10, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'9, tuchar) ::
               (_t'8, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'7, tuchar) ::
               (_t'6, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'5, tuchar) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'13 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'14
          (Ederef
            (Ecast
              (Ebinop Oadd
                (Ebinop Oor
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Econst_int (Int.repr 3) tint) tint)
                  (Ebinop Oshl
                    (Ebinop Oand (Econst_int (Int.repr 2) tint)
                      (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                      tint)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                (Ecast (Etempvar _t'13 (tptr (Tstruct _LevelCommand noattr)))
                  (tptr tuchar)) (tptr tuchar)) (tptr tuchar)) tuchar))
        (Ssequence
          (Sset _t'15
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'16
              (Ederef
                (Ecast
                  (Ebinop Oadd
                    (Ebinop Oor
                      (Ebinop Oand (Econst_int (Int.repr 4) tint)
                        (Econst_int (Int.repr 3) tint) tint)
                      (Ebinop Oshl
                        (Ebinop Oand (Econst_int (Int.repr 4) tint)
                          (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                          tint)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                    (Ecast
                      (Etempvar _t'15 (tptr (Tstruct _LevelCommand noattr)))
                      (tptr tuchar)) (tptr tuchar)) (tptr tint)) tint))
            (Scall (Some _t'2)
              (Evar _eval_script_op (Tfunction (tschar :: tint :: nil) tint
                                      cc_default))
              ((Etempvar _t'14 tuchar) :: (Etempvar _t'16 tint) :: nil))))))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tint)
                   (Econst_int (Int.repr 0) tint) tint)
      (Sloop
        (Ssequence
          (Sset _t'10
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'11
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
            (Ssequence
              (Sset _t'12
                (Efield
                  (Ederef
                    (Etempvar _t'11 (tptr (Tstruct _LevelCommand noattr)))
                    (Tstruct _LevelCommand noattr)) _size tuchar))
              (Sassign
                (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
                (Ecast
                  (Ebinop Oadd
                    (Ecast
                      (Etempvar _t'10 (tptr (Tstruct _LevelCommand noattr)))
                      (tptr tuchar))
                    (Ebinop Oshl (Etempvar _t'12 tuchar)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint)
                    (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr)))))))
        (Ssequence
          (Ssequence
            (Sset _t'6
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
            (Ssequence
              (Sset _t'7
                (Efield
                  (Ederef
                    (Etempvar _t'6 (tptr (Tstruct _LevelCommand noattr)))
                    (Tstruct _LevelCommand noattr)) _type tuchar))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'7 tuchar)
                             (Econst_int (Int.repr 15) tint) tint)
                (Sset _t'1 (Econst_int (Int.repr 1) tint))
                (Ssequence
                  (Sset _t'8
                    (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                  (Ssequence
                    (Sset _t'9
                      (Efield
                        (Ederef
                          (Etempvar _t'8 (tptr (Tstruct _LevelCommand noattr)))
                          (Tstruct _LevelCommand noattr)) _type tuchar))
                    (Sset _t'1
                      (Ecast
                        (Ebinop Oeq (Etempvar _t'9 tuchar)
                          (Econst_int (Int.repr 16) tint) tint) tbool)))))))
          (Sifthenelse (Etempvar _t'1 tint) Sskip Sbreak)))
      Sskip))
  (Ssequence
    (Sset _t'3 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'4 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'5 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_skip := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'8, tuchar) ::
               (_t'7, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'6, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'5, tuchar) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sloop
    (Ssequence
      (Sset _t'6 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'7 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'8
            (Efield
              (Ederef (Etempvar _t'7 (tptr (Tstruct _LevelCommand noattr)))
                (Tstruct _LevelCommand noattr)) _size tuchar))
          (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
            (Ecast
              (Ebinop Oadd
                (Ecast (Etempvar _t'6 (tptr (Tstruct _LevelCommand noattr)))
                  (tptr tuchar))
                (Ebinop Oshl (Etempvar _t'8 tuchar)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint)
                (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr)))))))
    (Ssequence
      (Sset _t'4 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _type tuchar))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tuchar)
                       (Econst_int (Int.repr 16) tint) tint)
          Sskip
          Sbreak))))
  (Ssequence
    (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'3 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_skippable_nop := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
  (Ssequence
    (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
            (Tstruct _LevelCommand noattr)) _size tuchar))
      (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
        (Ecast
          (Ebinop Oadd
            (Ecast (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
              (tptr tuchar))
            (Ebinop Oshl (Etempvar _t'3 tuchar)
              (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
          (tptr (Tstruct _LevelCommand noattr)))))))
|}.

Definition f_level_cmd_call := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_func,
                (tptr (Tfunction (tshort :: tint :: nil) tint cc_default))) ::
               (_t'1, tint) ::
               (_t'8, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'7, tint) :: (_t'6, tshort) ::
               (_t'5, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'4, tuchar) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Sset _func
      (Ederef
        (Ecast
          (Ebinop Oadd
            (Ebinop Oor
              (Ebinop Oand (Econst_int (Int.repr 4) tint)
                (Econst_int (Int.repr 3) tint) tint)
              (Ebinop Oshl
                (Ebinop Oand (Econst_int (Int.repr 4) tint)
                  (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) tint)
            (Ecast (Etempvar _t'8 (tptr (Tstruct _LevelCommand noattr)))
              (tptr tuchar)) (tptr tuchar))
          (tptr (tptr (Tfunction (tshort :: tint :: nil) tint cc_default))))
        (tptr (Tfunction (tshort :: tint :: nil) tint cc_default)))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'5 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'6
            (Ederef
              (Ecast
                (Ebinop Oadd
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 2) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 2) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (Ecast
                    (Etempvar _t'5 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar)) (tptr tuchar)) (tptr tshort)) tshort))
          (Ssequence
            (Sset _t'7 (Evar _sRegister tint))
            (Scall (Some _t'1)
              (Etempvar _func (tptr (Tfunction (tshort :: tint :: nil) tint
                                      cc_default)))
              ((Etempvar _t'6 tshort) :: (Etempvar _t'7 tint) :: nil)))))
      (Sassign (Evar _sRegister tint) (Etempvar _t'1 tint)))
    (Ssequence
      (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'3 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'4
            (Efield
              (Ederef (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
                (Tstruct _LevelCommand noattr)) _size tuchar))
          (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
            (Ecast
              (Ebinop Oadd
                (Ecast (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
                  (tptr tuchar))
                (Ebinop Oshl (Etempvar _t'4 tuchar)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint)
                (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr)))))))))
|}.

Definition f_level_cmd_call_loop := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_func,
                (tptr (Tfunction (tshort :: tint :: nil) tint cc_default))) ::
               (_t'1, tint) ::
               (_t'9, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'8, tint) :: (_t'7, tshort) ::
               (_t'6, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'5, tuchar) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'2, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Sset _func
      (Ederef
        (Ecast
          (Ebinop Oadd
            (Ebinop Oor
              (Ebinop Oand (Econst_int (Int.repr 4) tint)
                (Econst_int (Int.repr 3) tint) tint)
              (Ebinop Oshl
                (Ebinop Oand (Econst_int (Int.repr 4) tint)
                  (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) tint)
            (Ecast (Etempvar _t'9 (tptr (Tstruct _LevelCommand noattr)))
              (tptr tuchar)) (tptr tuchar))
          (tptr (tptr (Tfunction (tshort :: tint :: nil) tint cc_default))))
        (tptr (Tfunction (tshort :: tint :: nil) tint cc_default)))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'6 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'7
            (Ederef
              (Ecast
                (Ebinop Oadd
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 2) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 2) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (Ecast
                    (Etempvar _t'6 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar)) (tptr tuchar)) (tptr tshort)) tshort))
          (Ssequence
            (Sset _t'8 (Evar _sRegister tint))
            (Scall (Some _t'1)
              (Etempvar _func (tptr (Tfunction (tshort :: tint :: nil) tint
                                      cc_default)))
              ((Etempvar _t'7 tshort) :: (Etempvar _t'8 tint) :: nil)))))
      (Sassign (Evar _sRegister tint) (Etempvar _t'1 tint)))
    (Ssequence
      (Sset _t'2 (Evar _sRegister tint))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tint)
                     (Econst_int (Int.repr 0) tint) tint)
        (Sassign (Evar _sScriptStatus tshort) (Econst_int (Int.repr 0) tint))
        (Ssequence
          (Sassign (Evar _sScriptStatus tshort)
            (Econst_int (Int.repr 1) tint))
          (Ssequence
            (Sset _t'3
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
            (Ssequence
              (Sset _t'4
                (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef
                      (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
                      (Tstruct _LevelCommand noattr)) _size tuchar))
                (Sassign
                  (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
                  (Ecast
                    (Ebinop Oadd
                      (Ecast
                        (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
                        (tptr tuchar))
                      (Ebinop Oshl (Etempvar _t'5 tuchar)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint)
                      (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr))))))))))))
|}.

Definition f_level_cmd_set_register := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'5, tshort) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'5
        (Ederef
          (Ecast
            (Ebinop Oadd
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (Ecast (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar)) (tptr tuchar)) (tptr tshort)) tshort))
      (Sassign (Evar _sRegister tint) (Etempvar _t'5 tshort))))
  (Ssequence
    (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'3 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_push_pool_state := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Scall None (Evar _main_pool_push_state (Tfunction nil tuint cc_default))
    nil)
  (Ssequence
    (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'3 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_pop_pool_state := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Scall None (Evar _main_pool_pop_state (Tfunction nil tuint cc_default))
    nil)
  (Ssequence
    (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'3 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_load_to_fixed_address := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'9, (tptr tvoid)) ::
               (_t'8, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'7, (tptr tvoid)) ::
               (_t'6, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'5, (tptr tvoid)) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'5
        (Ederef
          (Ecast
            (Ebinop Oadd
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 4) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 4) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (Ecast (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
          (tptr tvoid)))
      (Ssequence
        (Sset _t'6 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'7
            (Ederef
              (Ecast
                (Ebinop Oadd
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 8) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 8) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (Ecast
                    (Etempvar _t'6 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
              (tptr tvoid)))
          (Ssequence
            (Sset _t'8
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
            (Ssequence
              (Sset _t'9
                (Ederef
                  (Ecast
                    (Ebinop Oadd
                      (Ebinop Oor
                        (Ebinop Oand (Econst_int (Int.repr 12) tint)
                          (Econst_int (Int.repr 3) tint) tint)
                        (Ebinop Oshl
                          (Ebinop Oand (Econst_int (Int.repr 12) tint)
                            (Eunop Onotint (Econst_int (Int.repr 3) tint)
                              tint) tint)
                          (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                            (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                      (Ecast
                        (Etempvar _t'8 (tptr (Tstruct _LevelCommand noattr)))
                        (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
                  (tptr tvoid)))
              (Scall None
                (Evar _load_to_fixed_pool_addr (Tfunction
                                                 ((tptr tuchar) ::
                                                  (tptr tuchar) ::
                                                  (tptr tuchar) :: nil)
                                                 (tptr tvoid) cc_default))
                ((Etempvar _t'5 (tptr tvoid)) ::
                 (Etempvar _t'7 (tptr tvoid)) ::
                 (Etempvar _t'9 (tptr tvoid)) :: nil))))))))
  (Ssequence
    (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'3 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_load_raw := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'9, (tptr tvoid)) ::
               (_t'8, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'7, (tptr tvoid)) ::
               (_t'6, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'5, tshort) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'5
        (Ederef
          (Ecast
            (Ebinop Oadd
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (Ecast (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar)) (tptr tuchar)) (tptr tshort)) tshort))
      (Ssequence
        (Sset _t'6 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'7
            (Ederef
              (Ecast
                (Ebinop Oadd
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 4) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 4) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (Ecast
                    (Etempvar _t'6 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
              (tptr tvoid)))
          (Ssequence
            (Sset _t'8
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
            (Ssequence
              (Sset _t'9
                (Ederef
                  (Ecast
                    (Ebinop Oadd
                      (Ebinop Oor
                        (Ebinop Oand (Econst_int (Int.repr 8) tint)
                          (Econst_int (Int.repr 3) tint) tint)
                        (Ebinop Oshl
                          (Ebinop Oand (Econst_int (Int.repr 8) tint)
                            (Eunop Onotint (Econst_int (Int.repr 3) tint)
                              tint) tint)
                          (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                            (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                      (Ecast
                        (Etempvar _t'8 (tptr (Tstruct _LevelCommand noattr)))
                        (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
                  (tptr tvoid)))
              (Scall None
                (Evar _load_segment (Tfunction
                                      (tint :: (tptr tuchar) ::
                                       (tptr tuchar) :: tuint :: nil)
                                      (tptr tvoid) cc_default))
                ((Etempvar _t'5 tshort) :: (Etempvar _t'7 (tptr tvoid)) ::
                 (Etempvar _t'9 (tptr tvoid)) ::
                 (Econst_int (Int.repr 0) tint) :: nil))))))))
  (Ssequence
    (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'3 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_load_mio0 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'9, (tptr tvoid)) ::
               (_t'8, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'7, (tptr tvoid)) ::
               (_t'6, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'5, tshort) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'5
        (Ederef
          (Ecast
            (Ebinop Oadd
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (Ecast (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar)) (tptr tuchar)) (tptr tshort)) tshort))
      (Ssequence
        (Sset _t'6 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'7
            (Ederef
              (Ecast
                (Ebinop Oadd
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 4) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 4) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (Ecast
                    (Etempvar _t'6 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
              (tptr tvoid)))
          (Ssequence
            (Sset _t'8
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
            (Ssequence
              (Sset _t'9
                (Ederef
                  (Ecast
                    (Ebinop Oadd
                      (Ebinop Oor
                        (Ebinop Oand (Econst_int (Int.repr 8) tint)
                          (Econst_int (Int.repr 3) tint) tint)
                        (Ebinop Oshl
                          (Ebinop Oand (Econst_int (Int.repr 8) tint)
                            (Eunop Onotint (Econst_int (Int.repr 3) tint)
                              tint) tint)
                          (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                            (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                      (Ecast
                        (Etempvar _t'8 (tptr (Tstruct _LevelCommand noattr)))
                        (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
                  (tptr tvoid)))
              (Scall None
                (Evar _load_segment_decompress (Tfunction
                                                 (tint :: (tptr tuchar) ::
                                                  (tptr tuchar) :: nil)
                                                 (tptr tvoid) cc_default))
                ((Etempvar _t'5 tshort) :: (Etempvar _t'7 (tptr tvoid)) ::
                 (Etempvar _t'9 (tptr tvoid)) :: nil))))))))
  (Ssequence
    (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'3 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_load_mario_head := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_addr, (tptr tvoid)) :: (_t'1, (tptr tvoid)) ::
               (_t'6, tshort) ::
               (_t'5, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'4, tuchar) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _main_pool_alloc (Tfunction (tuint :: tuint :: nil) (tptr tvoid)
                               cc_default))
      ((Ebinop Omul (Econst_int (Int.repr 921600) tint)
         (Ebinop Odiv (Esizeof (tptr tvoid) tuint)
           (Econst_int (Int.repr 4) tint) tuint) tuint) ::
       (Econst_int (Int.repr 0) tint) :: nil))
    (Sset _addr (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Sifthenelse (Ebinop One (Etempvar _addr (tptr tvoid))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Scall None
          (Evar _gdm_init (Tfunction ((tptr tvoid) :: tuint :: nil) tvoid
                            cc_default))
          ((Etempvar _addr (tptr tvoid)) ::
           (Ebinop Omul (Econst_int (Int.repr 921600) tint)
             (Ebinop Odiv (Esizeof (tptr tvoid) tuint)
               (Econst_int (Int.repr 4) tint) tuint) tuint) :: nil))
        (Ssequence
          (Scall None
            (Evar _gd_add_to_heap (Tfunction ((tptr tvoid) :: tuint :: nil)
                                    tvoid cc_default))
            ((Evar _gZBuffer (tarray tushort 76800)) ::
             (Esizeof (tarray tushort 76800) tuint) :: nil))
          (Ssequence
            (Scall None
              (Evar _gd_add_to_heap (Tfunction ((tptr tvoid) :: tuint :: nil)
                                      tvoid cc_default))
              ((Ederef
                 (Ebinop Oadd
                   (Evar _gFramebuffers (tarray (tarray tushort 76800) 3))
                   (Econst_int (Int.repr 0) tint)
                   (tptr (tarray tushort 76800))) (tarray tushort 76800)) ::
               (Ebinop Omul (Econst_int (Int.repr 3) tint)
                 (Esizeof (tarray tushort 76800) tuint) tuint) :: nil))
            (Ssequence
              (Scall None (Evar _gdm_setup (Tfunction nil tvoid cc_default))
                nil)
              (Ssequence
                (Sset _t'5
                  (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                (Ssequence
                  (Sset _t'6
                    (Ederef
                      (Ecast
                        (Ebinop Oadd
                          (Ebinop Oor
                            (Ebinop Oand (Econst_int (Int.repr 2) tint)
                              (Econst_int (Int.repr 3) tint) tint)
                            (Ebinop Oshl
                              (Ebinop Oand (Econst_int (Int.repr 2) tint)
                                (Eunop Onotint (Econst_int (Int.repr 3) tint)
                                  tint) tint)
                              (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                (Econst_int (Int.repr 3) tint) tuint) tint)
                            tint)
                          (Ecast
                            (Etempvar _t'5 (tptr (Tstruct _LevelCommand noattr)))
                            (tptr tuchar)) (tptr tuchar)) (tptr tshort))
                      tshort))
                  (Scall None
                    (Evar _gdm_maketestdl (Tfunction (tint :: nil) tvoid
                                            cc_default))
                    ((Etempvar _t'6 tshort) :: nil))))))))
      Sskip)
    (Ssequence
      (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'3 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'4
            (Efield
              (Ederef (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
                (Tstruct _LevelCommand noattr)) _size tuchar))
          (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
            (Ecast
              (Ebinop Oadd
                (Ecast (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
                  (tptr tuchar))
                (Ebinop Oshl (Etempvar _t'4 tuchar)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint)
                (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr)))))))))
|}.

Definition f_level_cmd_load_mio0_texture := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'9, (tptr tvoid)) ::
               (_t'8, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'7, (tptr tvoid)) ::
               (_t'6, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'5, tshort) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'5
        (Ederef
          (Ecast
            (Ebinop Oadd
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (Ecast (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar)) (tptr tuchar)) (tptr tshort)) tshort))
      (Ssequence
        (Sset _t'6 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'7
            (Ederef
              (Ecast
                (Ebinop Oadd
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 4) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 4) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (Ecast
                    (Etempvar _t'6 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
              (tptr tvoid)))
          (Ssequence
            (Sset _t'8
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
            (Ssequence
              (Sset _t'9
                (Ederef
                  (Ecast
                    (Ebinop Oadd
                      (Ebinop Oor
                        (Ebinop Oand (Econst_int (Int.repr 8) tint)
                          (Econst_int (Int.repr 3) tint) tint)
                        (Ebinop Oshl
                          (Ebinop Oand (Econst_int (Int.repr 8) tint)
                            (Eunop Onotint (Econst_int (Int.repr 3) tint)
                              tint) tint)
                          (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                            (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                      (Ecast
                        (Etempvar _t'8 (tptr (Tstruct _LevelCommand noattr)))
                        (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
                  (tptr tvoid)))
              (Scall None
                (Evar _load_segment_decompress_heap (Tfunction
                                                      (tuint ::
                                                       (tptr tuchar) ::
                                                       (tptr tuchar) :: nil)
                                                      (tptr tvoid)
                                                      cc_default))
                ((Etempvar _t'5 tshort) :: (Etempvar _t'7 (tptr tvoid)) ::
                 (Etempvar _t'9 (tptr tvoid)) :: nil))))))))
  (Ssequence
    (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'3 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_init_level := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _init_graph_node_start (Tfunction
                                   ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                    (tptr (Tstruct _GraphNodeStart noattr)) ::
                                    nil)
                                   (tptr (Tstruct _GraphNodeStart noattr))
                                   cc_default))
    ((Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
     (Ecast
       (Eaddrof (Evar _gObjParentGraphNode (Tstruct _GraphNode noattr))
         (tptr (Tstruct _GraphNode noattr)))
       (tptr (Tstruct _GraphNodeStart noattr))) :: nil))
  (Ssequence
    (Scall None (Evar _clear_objects (Tfunction nil tvoid cc_default)) nil)
    (Ssequence
      (Scall None (Evar _clear_areas (Tfunction nil tvoid cc_default)) nil)
      (Ssequence
        (Scall None
          (Evar _main_pool_push_state (Tfunction nil tuint cc_default)) nil)
        (Ssequence
          (Sset _t'1
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'2
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
            (Ssequence
              (Sset _t'3
                (Efield
                  (Ederef
                    (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
                    (Tstruct _LevelCommand noattr)) _size tuchar))
              (Sassign
                (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
                (Ecast
                  (Ebinop Oadd
                    (Ecast
                      (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                      (tptr tuchar))
                    (Ebinop Oshl (Etempvar _t'3 tuchar)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint)
                    (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr)))))))))))
|}.

Definition f_level_cmd_clear_level := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Scall None (Evar _clear_objects (Tfunction nil tvoid cc_default)) nil)
  (Ssequence
    (Scall None
      (Evar _clear_area_graph_nodes (Tfunction nil tvoid cc_default)) nil)
    (Ssequence
      (Scall None (Evar _clear_areas (Tfunction nil tvoid cc_default)) nil)
      (Ssequence
        (Scall None
          (Evar _main_pool_pop_state (Tfunction nil tuint cc_default)) nil)
        (Ssequence
          (Sset _t'1
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'2
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
            (Ssequence
              (Sset _t'3
                (Efield
                  (Ederef
                    (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
                    (Tstruct _LevelCommand noattr)) _size tuchar))
              (Sassign
                (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
                (Ecast
                  (Ebinop Oadd
                    (Ecast
                      (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                      (tptr tuchar))
                    (Ebinop Oshl (Etempvar _t'3 tuchar)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint)
                    (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr)))))))))))
|}.

Definition f_level_cmd_alloc_level_pool := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'1, tuint) ::
               (_t'6, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'5, tuchar) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6 (Evar _sLevelPool (tptr (Tstruct _AllocOnlyPool noattr))))
    (Sifthenelse (Ebinop Oeq
                   (Etempvar _t'6 (tptr (Tstruct _AllocOnlyPool noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _main_pool_available (Tfunction nil tuint cc_default)) nil)
          (Scall (Some _t'2)
            (Evar _alloc_only_pool_init (Tfunction (tuint :: tuint :: nil)
                                          (tptr (Tstruct _AllocOnlyPool noattr))
                                          cc_default))
            ((Ebinop Osub (Etempvar _t'1 tuint)
               (Esizeof (Tstruct _AllocOnlyPool noattr) tuint) tuint) ::
             (Econst_int (Int.repr 0) tint) :: nil)))
        (Sassign (Evar _sLevelPool (tptr (Tstruct _AllocOnlyPool noattr)))
          (Etempvar _t'2 (tptr (Tstruct _AllocOnlyPool noattr)))))
      Sskip))
  (Ssequence
    (Sset _t'3 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'4 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'5 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_free_level_pool := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_t'7, tint) ::
               (_t'6, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'5, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'4, (tptr tshort)) :: (_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5 (Evar _sLevelPool (tptr (Tstruct _AllocOnlyPool noattr))))
    (Ssequence
      (Sset _t'6 (Evar _sLevelPool (tptr (Tstruct _AllocOnlyPool noattr))))
      (Ssequence
        (Sset _t'7
          (Efield
            (Ederef (Etempvar _t'6 (tptr (Tstruct _AllocOnlyPool noattr)))
              (Tstruct _AllocOnlyPool noattr)) _usedSpace tint))
        (Scall None
          (Evar _alloc_only_pool_resize (Tfunction
                                          ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                           tuint :: nil)
                                          (tptr (Tstruct _AllocOnlyPool noattr))
                                          cc_default))
          ((Etempvar _t'5 (tptr (Tstruct _AllocOnlyPool noattr))) ::
           (Etempvar _t'7 tint) :: nil)))))
  (Ssequence
    (Sassign (Evar _sLevelPool (tptr (Tstruct _AllocOnlyPool noattr)))
      (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
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
              (Sset _t'4
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Evar _gAreaData (tarray (Tstruct _Area noattr) 0))
                      (Etempvar _i tint) (tptr (Tstruct _Area noattr)))
                    (Tstruct _Area noattr)) _terrainData (tptr tshort)))
              (Sifthenelse (Ebinop One (Etempvar _t'4 (tptr tshort))
                             (Ecast (Econst_int (Int.repr 0) tint)
                               (tptr tvoid)) tint)
                (Ssequence
                  (Scall None
                    (Evar _alloc_surface_pools (Tfunction nil tvoid
                                                 cc_default)) nil)
                  Sbreak)
                Sskip)))
          (Sset _i
            (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint)
              tint))))
      (Ssequence
        (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'2
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'3
              (Efield
                (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
                  (Tstruct _LevelCommand noattr)) _size tuchar))
            (Sassign
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
              (Ecast
                (Ebinop Oadd
                  (Ecast
                    (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar))
                  (Ebinop Oshl (Etempvar _t'3 tuchar)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint)
                  (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr))))))))))
|}.

Definition f_level_cmd_begin_area := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_areaIndex, tuchar) :: (_geoLayoutAddr, (tptr tvoid)) ::
               (_screenArea, (tptr (Tstruct _GraphNodeRoot noattr))) ::
               (_node, (tptr (Tstruct _GraphNodeCamera noattr))) ::
               (_t'1, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'14, tuchar) ::
               (_t'13, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'12, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'11, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'10, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'9, (tptr (tptr (Tstruct _GraphNode noattr)))) ::
               (_t'8, (tptr (Tstruct _Area noattr))) ::
               (_t'7, (tptr (Tstruct _Camera noattr))) ::
               (_t'6, (tptr (Tstruct _Area noattr))) ::
               (_t'5, (tptr (Tstruct _Area noattr))) :: (_t'4, tuchar) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'13 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'14
        (Ederef
          (Ecast
            (Ebinop Oadd
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (Ecast (Etempvar _t'13 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar)) (tptr tuchar)) (tptr tuchar)) tuchar))
      (Sset _areaIndex (Ecast (Etempvar _t'14 tuchar) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'12 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Sset _geoLayoutAddr
        (Ederef
          (Ecast
            (Ebinop Oadd
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 4) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 4) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (Ecast (Etempvar _t'12 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
          (tptr tvoid))))
    (Ssequence
      (Sifthenelse (Ebinop Olt (Etempvar _areaIndex tuchar)
                     (Econst_int (Int.repr 8) tint) tint)
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'11
                (Evar _sLevelPool (tptr (Tstruct _AllocOnlyPool noattr))))
              (Scall (Some _t'1)
                (Evar _process_geo_layout (Tfunction
                                            ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                             (tptr tvoid) :: nil)
                                            (tptr (Tstruct _GraphNode noattr))
                                            cc_default))
                ((Etempvar _t'11 (tptr (Tstruct _AllocOnlyPool noattr))) ::
                 (Etempvar _geoLayoutAddr (tptr tvoid)) :: nil)))
            (Sset _screenArea
              (Ecast (Etempvar _t'1 (tptr (Tstruct _GraphNode noattr)))
                (tptr (Tstruct _GraphNodeRoot noattr)))))
          (Ssequence
            (Ssequence
              (Sset _t'9
                (Efield
                  (Ederef
                    (Etempvar _screenArea (tptr (Tstruct _GraphNodeRoot noattr)))
                    (Tstruct _GraphNodeRoot noattr)) _views
                  (tptr (tptr (Tstruct _GraphNode noattr)))))
              (Ssequence
                (Sset _t'10
                  (Ederef
                    (Ebinop Oadd
                      (Etempvar _t'9 (tptr (tptr (Tstruct _GraphNode noattr))))
                      (Econst_int (Int.repr 0) tint)
                      (tptr (tptr (Tstruct _GraphNode noattr))))
                    (tptr (Tstruct _GraphNode noattr))))
                (Sset _node
                  (Ecast (Etempvar _t'10 (tptr (Tstruct _GraphNode noattr)))
                    (tptr (Tstruct _GraphNodeCamera noattr))))))
            (Ssequence
              (Sassign (Evar _sCurrAreaIndex tshort)
                (Etempvar _areaIndex tuchar))
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _screenArea (tptr (Tstruct _GraphNodeRoot noattr)))
                      (Tstruct _GraphNodeRoot noattr)) _areaIndex tuchar)
                  (Etempvar _areaIndex tuchar))
                (Ssequence
                  (Ssequence
                    (Sset _t'8 (Evar _gAreas (tptr (Tstruct _Area noattr))))
                    (Sassign
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Etempvar _t'8 (tptr (Tstruct _Area noattr)))
                            (Etempvar _areaIndex tuchar)
                            (tptr (Tstruct _Area noattr)))
                          (Tstruct _Area noattr)) _unk04
                        (tptr (Tstruct _GraphNodeRoot noattr)))
                      (Etempvar _screenArea (tptr (Tstruct _GraphNodeRoot noattr)))))
                  (Sifthenelse (Ebinop One
                                 (Etempvar _node (tptr (Tstruct _GraphNodeCamera noattr)))
                                 (Ecast (Econst_int (Int.repr 0) tint)
                                   (tptr tvoid)) tint)
                    (Ssequence
                      (Sset _t'6
                        (Evar _gAreas (tptr (Tstruct _Area noattr))))
                      (Ssequence
                        (Sset _t'7
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _node (tptr (Tstruct _GraphNodeCamera noattr)))
                                (Tstruct _GraphNodeCamera noattr)) _config
                              (Tunion __1252 noattr)) _camera
                            (tptr (Tstruct _Camera noattr))))
                        (Sassign
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Etempvar _t'6 (tptr (Tstruct _Area noattr)))
                                (Etempvar _areaIndex tuchar)
                                (tptr (Tstruct _Area noattr)))
                              (Tstruct _Area noattr)) _camera
                            (tptr (Tstruct _Camera noattr)))
                          (Ecast
                            (Etempvar _t'7 (tptr (Tstruct _Camera noattr)))
                            (tptr (Tstruct _Camera noattr))))))
                    (Ssequence
                      (Sset _t'5
                        (Evar _gAreas (tptr (Tstruct _Area noattr))))
                      (Sassign
                        (Efield
                          (Ederef
                            (Ebinop Oadd
                              (Etempvar _t'5 (tptr (Tstruct _Area noattr)))
                              (Etempvar _areaIndex tuchar)
                              (tptr (Tstruct _Area noattr)))
                            (Tstruct _Area noattr)) _camera
                          (tptr (Tstruct _Camera noattr)))
                        (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))))))))
        Sskip)
      (Ssequence
        (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'3
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
                  (Tstruct _LevelCommand noattr)) _size tuchar))
            (Sassign
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
              (Ecast
                (Ebinop Oadd
                  (Ecast
                    (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar))
                  (Ebinop Oshl (Etempvar _t'4 tuchar)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint)
                  (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr))))))))))
|}.

Definition f_level_cmd_end_area := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _sCurrAreaIndex tshort)
    (Eunop Oneg (Econst_int (Int.repr 1) tint) tint))
  (Ssequence
    (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'3 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_load_model_from_dl := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_val1, tshort) :: (_val2, tshort) :: (_val3, (tptr tvoid)) ::
               (_t'1, (tptr (Tstruct _GraphNodeDisplayList noattr))) ::
               (_t'11, tshort) ::
               (_t'10, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'9, tshort) ::
               (_t'8, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'7, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'6, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'5, (tptr (tptr (Tstruct _GraphNode noattr)))) ::
               (_t'4, tuchar) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'10 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'11
        (Ederef
          (Ecast
            (Ebinop Oadd
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (Ecast (Etempvar _t'10 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar)) (tptr tuchar)) (tptr tshort)) tshort))
      (Sset _val1
        (Ecast
          (Ebinop Oand (Etempvar _t'11 tshort)
            (Econst_int (Int.repr 4095) tint) tint) tshort))))
  (Ssequence
    (Ssequence
      (Sset _t'8 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'9
          (Ederef
            (Ecast
              (Ebinop Oadd
                (Ebinop Oor
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Econst_int (Int.repr 3) tint) tint)
                  (Ebinop Oshl
                    (Ebinop Oand (Econst_int (Int.repr 2) tint)
                      (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                      tint)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                (Ecast (Etempvar _t'8 (tptr (Tstruct _LevelCommand noattr)))
                  (tptr tuchar)) (tptr tuchar)) (tptr tshort)) tshort))
        (Sset _val2
          (Ecast
            (Ebinop Oshr (Ecast (Etempvar _t'9 tshort) tushort)
              (Econst_int (Int.repr 12) tint) tint) tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'7 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Sset _val3
          (Ederef
            (Ecast
              (Ebinop Oadd
                (Ebinop Oor
                  (Ebinop Oand (Econst_int (Int.repr 4) tint)
                    (Econst_int (Int.repr 3) tint) tint)
                  (Ebinop Oshl
                    (Ebinop Oand (Econst_int (Int.repr 4) tint)
                      (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                      tint)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                (Ecast (Etempvar _t'7 (tptr (Tstruct _LevelCommand noattr)))
                  (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
            (tptr tvoid))))
      (Ssequence
        (Sifthenelse (Ebinop Olt (Etempvar _val1 tshort)
                       (Econst_int (Int.repr 256) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'6
                (Evar _sLevelPool (tptr (Tstruct _AllocOnlyPool noattr))))
              (Scall (Some _t'1)
                (Evar _init_graph_node_display_list (Tfunction
                                                      ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                       (tptr (Tstruct _GraphNodeDisplayList noattr)) ::
                                                       tint ::
                                                       (tptr tvoid) :: nil)
                                                      (tptr (Tstruct _GraphNodeDisplayList noattr))
                                                      cc_default))
                ((Etempvar _t'6 (tptr (Tstruct _AllocOnlyPool noattr))) ::
                 (Econst_int (Int.repr 0) tint) :: (Etempvar _val2 tshort) ::
                 (Etempvar _val3 (tptr tvoid)) :: nil)))
            (Ssequence
              (Sset _t'5
                (Evar _gLoadedGraphNodes (tptr (tptr (Tstruct _GraphNode noattr)))))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Etempvar _t'5 (tptr (tptr (Tstruct _GraphNode noattr))))
                    (Etempvar _val1 tshort)
                    (tptr (tptr (Tstruct _GraphNode noattr))))
                  (tptr (Tstruct _GraphNode noattr)))
                (Ecast
                  (Etempvar _t'1 (tptr (Tstruct _GraphNodeDisplayList noattr)))
                  (tptr (Tstruct _GraphNode noattr))))))
          Sskip)
        (Ssequence
          (Sset _t'2
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'3
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef
                    (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
                    (Tstruct _LevelCommand noattr)) _size tuchar))
              (Sassign
                (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
                (Ecast
                  (Ebinop Oadd
                    (Ecast
                      (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
                      (tptr tuchar))
                    (Ebinop Oshl (Etempvar _t'4 tuchar)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint)
                    (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr)))))))))))
|}.

Definition f_level_cmd_load_model_from_geo := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_arg0, tshort) :: (_arg1, (tptr tvoid)) ::
               (_t'1, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'9, tshort) ::
               (_t'8, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'7, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'6, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'5, (tptr (tptr (Tstruct _GraphNode noattr)))) ::
               (_t'4, tuchar) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'9
        (Ederef
          (Ecast
            (Ebinop Oadd
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (Ecast (Etempvar _t'8 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar)) (tptr tuchar)) (tptr tshort)) tshort))
      (Sset _arg0 (Ecast (Etempvar _t'9 tshort) tshort))))
  (Ssequence
    (Ssequence
      (Sset _t'7 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Sset _arg1
        (Ederef
          (Ecast
            (Ebinop Oadd
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 4) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 4) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (Ecast (Etempvar _t'7 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
          (tptr tvoid))))
    (Ssequence
      (Sifthenelse (Ebinop Olt (Etempvar _arg0 tshort)
                     (Econst_int (Int.repr 256) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'6
              (Evar _sLevelPool (tptr (Tstruct _AllocOnlyPool noattr))))
            (Scall (Some _t'1)
              (Evar _process_geo_layout (Tfunction
                                          ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                           (tptr tvoid) :: nil)
                                          (tptr (Tstruct _GraphNode noattr))
                                          cc_default))
              ((Etempvar _t'6 (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (Etempvar _arg1 (tptr tvoid)) :: nil)))
          (Ssequence
            (Sset _t'5
              (Evar _gLoadedGraphNodes (tptr (tptr (Tstruct _GraphNode noattr)))))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Etempvar _t'5 (tptr (tptr (Tstruct _GraphNode noattr))))
                  (Etempvar _arg0 tshort)
                  (tptr (tptr (Tstruct _GraphNode noattr))))
                (tptr (Tstruct _GraphNode noattr)))
              (Etempvar _t'1 (tptr (Tstruct _GraphNode noattr))))))
        Sskip)
      (Ssequence
        (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'3
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
                  (Tstruct _LevelCommand noattr)) _size tuchar))
            (Sassign
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
              (Ecast
                (Ebinop Oadd
                  (Ecast
                    (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar))
                  (Ebinop Oshl (Etempvar _t'4 tuchar)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint)
                  (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr))))))))))
|}.

Definition f_level_cmd_23 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_arg2, (Tunion __3650 noattr)) :: nil);
  fn_temps := ((_model, tshort) :: (_arg0H, tshort) ::
               (_arg1, (tptr tvoid)) ::
               (_t'1, (tptr (Tstruct _GraphNodeScale noattr))) ::
               (_t'14, tshort) ::
               (_t'13, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'12, tshort) ::
               (_t'11, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'10, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'9, tint) ::
               (_t'8, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'7, tfloat) ::
               (_t'6, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'5, (tptr (tptr (Tstruct _GraphNode noattr)))) ::
               (_t'4, tuchar) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'13 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'14
        (Ederef
          (Ecast
            (Ebinop Oadd
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (Ecast (Etempvar _t'13 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar)) (tptr tuchar)) (tptr tshort)) tshort))
      (Sset _model
        (Ecast
          (Ebinop Oand (Etempvar _t'14 tshort)
            (Econst_int (Int.repr 4095) tint) tint) tshort))))
  (Ssequence
    (Ssequence
      (Sset _t'11 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'12
          (Ederef
            (Ecast
              (Ebinop Oadd
                (Ebinop Oor
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Econst_int (Int.repr 3) tint) tint)
                  (Ebinop Oshl
                    (Ebinop Oand (Econst_int (Int.repr 2) tint)
                      (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                      tint)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                (Ecast (Etempvar _t'11 (tptr (Tstruct _LevelCommand noattr)))
                  (tptr tuchar)) (tptr tuchar)) (tptr tshort)) tshort))
        (Sset _arg0H
          (Ecast
            (Ebinop Oshr (Ecast (Etempvar _t'12 tshort) tushort)
              (Econst_int (Int.repr 12) tint) tint) tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'10
          (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Sset _arg1
          (Ederef
            (Ecast
              (Ebinop Oadd
                (Ebinop Oor
                  (Ebinop Oand (Econst_int (Int.repr 4) tint)
                    (Econst_int (Int.repr 3) tint) tint)
                  (Ebinop Oshl
                    (Ebinop Oand (Econst_int (Int.repr 4) tint)
                      (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                      tint)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                (Ecast (Etempvar _t'10 (tptr (Tstruct _LevelCommand noattr)))
                  (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
            (tptr tvoid))))
      (Ssequence
        (Ssequence
          (Sset _t'8
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'9
              (Ederef
                (Ecast
                  (Ebinop Oadd
                    (Ebinop Oor
                      (Ebinop Oand (Econst_int (Int.repr 8) tint)
                        (Econst_int (Int.repr 3) tint) tint)
                      (Ebinop Oshl
                        (Ebinop Oand (Econst_int (Int.repr 8) tint)
                          (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                          tint)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                    (Ecast
                      (Etempvar _t'8 (tptr (Tstruct _LevelCommand noattr)))
                      (tptr tuchar)) (tptr tuchar)) (tptr tint)) tint))
            (Sassign (Efield (Evar _arg2 (Tunion __3650 noattr)) _i tint)
              (Etempvar _t'9 tint))))
        (Ssequence
          (Sifthenelse (Ebinop Olt (Etempvar _model tshort)
                         (Econst_int (Int.repr 256) tint) tint)
            (Ssequence
              (Ssequence
                (Sset _t'6
                  (Evar _sLevelPool (tptr (Tstruct _AllocOnlyPool noattr))))
                (Ssequence
                  (Sset _t'7
                    (Efield (Evar _arg2 (Tunion __3650 noattr)) _f tfloat))
                  (Scall (Some _t'1)
                    (Evar _init_graph_node_scale (Tfunction
                                                   ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                    (tptr (Tstruct _GraphNodeScale noattr)) ::
                                                    tint :: (tptr tvoid) ::
                                                    tfloat :: nil)
                                                   (tptr (Tstruct _GraphNodeScale noattr))
                                                   cc_default))
                    ((Etempvar _t'6 (tptr (Tstruct _AllocOnlyPool noattr))) ::
                     (Econst_int (Int.repr 0) tint) ::
                     (Etempvar _arg0H tshort) ::
                     (Etempvar _arg1 (tptr tvoid)) ::
                     (Etempvar _t'7 tfloat) :: nil))))
              (Ssequence
                (Sset _t'5
                  (Evar _gLoadedGraphNodes (tptr (tptr (Tstruct _GraphNode noattr)))))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Etempvar _t'5 (tptr (tptr (Tstruct _GraphNode noattr))))
                      (Etempvar _model tshort)
                      (tptr (tptr (Tstruct _GraphNode noattr))))
                    (tptr (Tstruct _GraphNode noattr)))
                  (Ecast
                    (Etempvar _t'1 (tptr (Tstruct _GraphNodeScale noattr)))
                    (tptr (Tstruct _GraphNode noattr))))))
            Sskip)
          (Ssequence
            (Sset _t'2
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
            (Ssequence
              (Sset _t'3
                (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
              (Ssequence
                (Sset _t'4
                  (Efield
                    (Ederef
                      (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
                      (Tstruct _LevelCommand noattr)) _size tuchar))
                (Sassign
                  (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
                  (Ecast
                    (Ebinop Oadd
                      (Ecast
                        (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
                        (tptr tuchar))
                      (Ebinop Oshl (Etempvar _t'4 tuchar)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint)
                      (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr))))))))))))
|}.

Definition f_level_cmd_init_mario := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'19, (tptr (Tstruct _SpawnInfo noattr))) ::
               (_t'18, (tptr (Tstruct _SpawnInfo noattr))) ::
               (_t'17, (tptr (Tstruct _SpawnInfo noattr))) ::
               (_t'16, (tptr (Tstruct _SpawnInfo noattr))) ::
               (_t'15, tuint) ::
               (_t'14, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'13, (tptr (Tstruct _SpawnInfo noattr))) ::
               (_t'12, (tptr tvoid)) ::
               (_t'11, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'10, (tptr (Tstruct _SpawnInfo noattr))) ::
               (_t'9, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'8, tuchar) ::
               (_t'7, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'6, (tptr (tptr (Tstruct _GraphNode noattr)))) ::
               (_t'5, (tptr (Tstruct _SpawnInfo noattr))) ::
               (_t'4, (tptr (Tstruct _SpawnInfo noattr))) ::
               (_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'19 (Evar _gMarioSpawnInfo (tptr (Tstruct _SpawnInfo noattr))))
    (Scall None
      (Evar _vec3s_set (Tfunction
                         ((tptr tshort) :: tshort :: tshort :: tshort :: nil)
                         (tptr tvoid) cc_default))
      ((Efield
         (Ederef (Etempvar _t'19 (tptr (Tstruct _SpawnInfo noattr)))
           (Tstruct _SpawnInfo noattr)) _startPos (tarray tshort 3)) ::
       (Econst_int (Int.repr 0) tint) :: (Econst_int (Int.repr 0) tint) ::
       (Econst_int (Int.repr 0) tint) :: nil)))
  (Ssequence
    (Ssequence
      (Sset _t'18 (Evar _gMarioSpawnInfo (tptr (Tstruct _SpawnInfo noattr))))
      (Scall None
        (Evar _vec3s_set (Tfunction
                           ((tptr tshort) :: tshort :: tshort :: tshort ::
                            nil) (tptr tvoid) cc_default))
        ((Efield
           (Ederef (Etempvar _t'18 (tptr (Tstruct _SpawnInfo noattr)))
             (Tstruct _SpawnInfo noattr)) _startAngle (tarray tshort 3)) ::
         (Econst_int (Int.repr 0) tint) :: (Econst_int (Int.repr 0) tint) ::
         (Econst_int (Int.repr 0) tint) :: nil)))
    (Ssequence
      (Ssequence
        (Sset _t'17
          (Evar _gMarioSpawnInfo (tptr (Tstruct _SpawnInfo noattr))))
        (Sassign
          (Efield
            (Ederef (Etempvar _t'17 (tptr (Tstruct _SpawnInfo noattr)))
              (Tstruct _SpawnInfo noattr)) _activeAreaIndex tschar)
          (Eunop Oneg (Econst_int (Int.repr 1) tint) tint)))
      (Ssequence
        (Ssequence
          (Sset _t'16
            (Evar _gMarioSpawnInfo (tptr (Tstruct _SpawnInfo noattr))))
          (Sassign
            (Efield
              (Ederef (Etempvar _t'16 (tptr (Tstruct _SpawnInfo noattr)))
                (Tstruct _SpawnInfo noattr)) _areaIndex tschar)
            (Econst_int (Int.repr 0) tint)))
        (Ssequence
          (Ssequence
            (Sset _t'13
              (Evar _gMarioSpawnInfo (tptr (Tstruct _SpawnInfo noattr))))
            (Ssequence
              (Sset _t'14
                (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
              (Ssequence
                (Sset _t'15
                  (Ederef
                    (Ecast
                      (Ebinop Oadd
                        (Ebinop Oor
                          (Ebinop Oand (Econst_int (Int.repr 4) tint)
                            (Econst_int (Int.repr 3) tint) tint)
                          (Ebinop Oshl
                            (Ebinop Oand (Econst_int (Int.repr 4) tint)
                              (Eunop Onotint (Econst_int (Int.repr 3) tint)
                                tint) tint)
                            (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                              (Econst_int (Int.repr 3) tint) tuint) tint)
                          tint)
                        (Ecast
                          (Etempvar _t'14 (tptr (Tstruct _LevelCommand noattr)))
                          (tptr tuchar)) (tptr tuchar)) (tptr tuint)) tuint))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _t'13 (tptr (Tstruct _SpawnInfo noattr)))
                      (Tstruct _SpawnInfo noattr)) _behaviorArg tuint)
                  (Etempvar _t'15 tuint)))))
          (Ssequence
            (Ssequence
              (Sset _t'10
                (Evar _gMarioSpawnInfo (tptr (Tstruct _SpawnInfo noattr))))
              (Ssequence
                (Sset _t'11
                  (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                (Ssequence
                  (Sset _t'12
                    (Ederef
                      (Ecast
                        (Ebinop Oadd
                          (Ebinop Oor
                            (Ebinop Oand (Econst_int (Int.repr 8) tint)
                              (Econst_int (Int.repr 3) tint) tint)
                            (Ebinop Oshl
                              (Ebinop Oand (Econst_int (Int.repr 8) tint)
                                (Eunop Onotint (Econst_int (Int.repr 3) tint)
                                  tint) tint)
                              (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                (Econst_int (Int.repr 3) tint) tuint) tint)
                            tint)
                          (Ecast
                            (Etempvar _t'11 (tptr (Tstruct _LevelCommand noattr)))
                            (tptr tuchar)) (tptr tuchar))
                        (tptr (tptr tvoid))) (tptr tvoid)))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _t'10 (tptr (Tstruct _SpawnInfo noattr)))
                        (Tstruct _SpawnInfo noattr)) _behaviorScript
                      (tptr tvoid)) (Etempvar _t'12 (tptr tvoid))))))
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Evar _gMarioSpawnInfo (tptr (Tstruct _SpawnInfo noattr))))
                (Ssequence
                  (Sset _t'6
                    (Evar _gLoadedGraphNodes (tptr (tptr (Tstruct _GraphNode noattr)))))
                  (Ssequence
                    (Sset _t'7
                      (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                    (Ssequence
                      (Sset _t'8
                        (Ederef
                          (Ecast
                            (Ebinop Oadd
                              (Ebinop Oor
                                (Ebinop Oand (Econst_int (Int.repr 3) tint)
                                  (Econst_int (Int.repr 3) tint) tint)
                                (Ebinop Oshl
                                  (Ebinop Oand (Econst_int (Int.repr 3) tint)
                                    (Eunop Onotint
                                      (Econst_int (Int.repr 3) tint) tint)
                                    tint)
                                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                    (Econst_int (Int.repr 3) tint) tuint)
                                  tint) tint)
                              (Ecast
                                (Etempvar _t'7 (tptr (Tstruct _LevelCommand noattr)))
                                (tptr tuchar)) (tptr tuchar)) (tptr tuchar))
                          tuchar))
                      (Ssequence
                        (Sset _t'9
                          (Ederef
                            (Ebinop Oadd
                              (Etempvar _t'6 (tptr (tptr (Tstruct _GraphNode noattr))))
                              (Etempvar _t'8 tuchar)
                              (tptr (tptr (Tstruct _GraphNode noattr))))
                            (tptr (Tstruct _GraphNode noattr))))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _t'5 (tptr (Tstruct _SpawnInfo noattr)))
                              (Tstruct _SpawnInfo noattr)) _model
                            (tptr (Tstruct _GraphNode noattr)))
                          (Etempvar _t'9 (tptr (Tstruct _GraphNode noattr)))))))))
              (Ssequence
                (Ssequence
                  (Sset _t'4
                    (Evar _gMarioSpawnInfo (tptr (Tstruct _SpawnInfo noattr))))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _t'4 (tptr (Tstruct _SpawnInfo noattr)))
                        (Tstruct _SpawnInfo noattr)) _next
                      (tptr (Tstruct _SpawnInfo noattr)))
                    (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
                (Ssequence
                  (Sset _t'1
                    (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                  (Ssequence
                    (Sset _t'2
                      (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                    (Ssequence
                      (Sset _t'3
                        (Efield
                          (Ederef
                            (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
                            (Tstruct _LevelCommand noattr)) _size tuchar))
                      (Sassign
                        (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
                        (Ecast
                          (Ebinop Oadd
                            (Ecast
                              (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                              (tptr tuchar))
                            (Ebinop Oshl (Etempvar _t'3 tuchar)
                              (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                (Econst_int (Int.repr 3) tint) tuint) tint)
                            (tptr tuchar))
                          (tptr (Tstruct _LevelCommand noattr)))))))))))))))
|}.

Definition f_level_cmd_place_object := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_val7, tuchar) :: (_model, tushort) ::
               (_spawnInfo, (tptr (Tstruct _SpawnInfo noattr))) ::
               (_t'2, tint) :: (_t'1, (tptr tvoid)) :: (_t'39, tshort) ::
               (_t'38, tuchar) ::
               (_t'37, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'36, tuchar) ::
               (_t'35, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'34, tshort) :: (_t'33, tuchar) ::
               (_t'32, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'31, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'30, tshort) ::
               (_t'29, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'28, tshort) ::
               (_t'27, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'26, tshort) ::
               (_t'25, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'24, tshort) ::
               (_t'23, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'22, tshort) ::
               (_t'21, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'20, tshort) ::
               (_t'19, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'18, tshort) :: (_t'17, tshort) :: (_t'16, tuint) ::
               (_t'15, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'14, (tptr tvoid)) ::
               (_t'13, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'12, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'11, (tptr (tptr (Tstruct _GraphNode noattr)))) ::
               (_t'10, (tptr (Tstruct _SpawnInfo noattr))) ::
               (_t'9, tshort) :: (_t'8, (tptr (Tstruct _Area noattr))) ::
               (_t'7, tshort) :: (_t'6, (tptr (Tstruct _Area noattr))) ::
               (_t'5, tuchar) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'39 (Evar _gCurrActNum tshort))
    (Sset _val7
      (Ecast
        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
          (Ebinop Osub (Etempvar _t'39 tshort) (Econst_int (Int.repr 1) tint)
            tint) tint) tuchar)))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'34 (Evar _sCurrAreaIndex tshort))
        (Sifthenelse (Ebinop One (Etempvar _t'34 tshort)
                       (Eunop Oneg (Econst_int (Int.repr 1) tint) tint) tint)
          (Ssequence
            (Sset _t'35
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
            (Ssequence
              (Sset _t'36
                (Ederef
                  (Ecast
                    (Ebinop Oadd
                      (Ebinop Oor
                        (Ebinop Oand (Econst_int (Int.repr 2) tint)
                          (Econst_int (Int.repr 3) tint) tint)
                        (Ebinop Oshl
                          (Ebinop Oand (Econst_int (Int.repr 2) tint)
                            (Eunop Onotint (Econst_int (Int.repr 3) tint)
                              tint) tint)
                          (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                            (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                      (Ecast
                        (Etempvar _t'35 (tptr (Tstruct _LevelCommand noattr)))
                        (tptr tuchar)) (tptr tuchar)) (tptr tuchar)) tuchar))
              (Sifthenelse (Ebinop Oand (Etempvar _t'36 tuchar)
                             (Etempvar _val7 tuchar) tint)
                (Sset _t'2 (Ecast (Econst_int (Int.repr 1) tint) tbool))
                (Ssequence
                  (Ssequence
                    (Sset _t'37
                      (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                    (Ssequence
                      (Sset _t'38
                        (Ederef
                          (Ecast
                            (Ebinop Oadd
                              (Ebinop Oor
                                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                                  (Econst_int (Int.repr 3) tint) tint)
                                (Ebinop Oshl
                                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                                    (Eunop Onotint
                                      (Econst_int (Int.repr 3) tint) tint)
                                    tint)
                                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                    (Econst_int (Int.repr 3) tint) tuint)
                                  tint) tint)
                              (Ecast
                                (Etempvar _t'37 (tptr (Tstruct _LevelCommand noattr)))
                                (tptr tuchar)) (tptr tuchar)) (tptr tuchar))
                          tuchar))
                      (Sset _t'2
                        (Ecast
                          (Ebinop Oeq (Etempvar _t'38 tuchar)
                            (Econst_int (Int.repr 31) tint) tint) tbool))))
                  (Sset _t'2 (Ecast (Etempvar _t'2 tint) tbool))))))
          (Sset _t'2 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'2 tint)
        (Ssequence
          (Ssequence
            (Sset _t'32
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
            (Ssequence
              (Sset _t'33
                (Ederef
                  (Ecast
                    (Ebinop Oadd
                      (Ebinop Oor
                        (Ebinop Oand (Econst_int (Int.repr 3) tint)
                          (Econst_int (Int.repr 3) tint) tint)
                        (Ebinop Oshl
                          (Ebinop Oand (Econst_int (Int.repr 3) tint)
                            (Eunop Onotint (Econst_int (Int.repr 3) tint)
                              tint) tint)
                          (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                            (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                      (Ecast
                        (Etempvar _t'32 (tptr (Tstruct _LevelCommand noattr)))
                        (tptr tuchar)) (tptr tuchar)) (tptr tuchar)) tuchar))
              (Sset _model (Ecast (Etempvar _t'33 tuchar) tushort))))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'31
                  (Evar _sLevelPool (tptr (Tstruct _AllocOnlyPool noattr))))
                (Scall (Some _t'1)
                  (Evar _alloc_only_pool_alloc (Tfunction
                                                 ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                  tint :: nil) (tptr tvoid)
                                                 cc_default))
                  ((Etempvar _t'31 (tptr (Tstruct _AllocOnlyPool noattr))) ::
                   (Esizeof (Tstruct _SpawnInfo noattr) tuint) :: nil)))
              (Sset _spawnInfo (Etempvar _t'1 (tptr tvoid))))
            (Ssequence
              (Ssequence
                (Sset _t'29
                  (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                (Ssequence
                  (Sset _t'30
                    (Ederef
                      (Ecast
                        (Ebinop Oadd
                          (Ebinop Oor
                            (Ebinop Oand (Econst_int (Int.repr 4) tint)
                              (Econst_int (Int.repr 3) tint) tint)
                            (Ebinop Oshl
                              (Ebinop Oand (Econst_int (Int.repr 4) tint)
                                (Eunop Onotint (Econst_int (Int.repr 3) tint)
                                  tint) tint)
                              (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                (Econst_int (Int.repr 3) tint) tuint) tint)
                            tint)
                          (Ecast
                            (Etempvar _t'29 (tptr (Tstruct _LevelCommand noattr)))
                            (tptr tuchar)) (tptr tuchar)) (tptr tshort))
                      tshort))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                            (Tstruct _SpawnInfo noattr)) _startPos
                          (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tshort)) tshort) (Etempvar _t'30 tshort))))
              (Ssequence
                (Ssequence
                  (Sset _t'27
                    (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                  (Ssequence
                    (Sset _t'28
                      (Ederef
                        (Ecast
                          (Ebinop Oadd
                            (Ebinop Oor
                              (Ebinop Oand (Econst_int (Int.repr 6) tint)
                                (Econst_int (Int.repr 3) tint) tint)
                              (Ebinop Oshl
                                (Ebinop Oand (Econst_int (Int.repr 6) tint)
                                  (Eunop Onotint
                                    (Econst_int (Int.repr 3) tint) tint)
                                  tint)
                                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                  (Econst_int (Int.repr 3) tint) tuint) tint)
                              tint)
                            (Ecast
                              (Etempvar _t'27 (tptr (Tstruct _LevelCommand noattr)))
                              (tptr tuchar)) (tptr tuchar)) (tptr tshort))
                        tshort))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                              (Tstruct _SpawnInfo noattr)) _startPos
                            (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tshort)) tshort) (Etempvar _t'28 tshort))))
                (Ssequence
                  (Ssequence
                    (Sset _t'25
                      (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                    (Ssequence
                      (Sset _t'26
                        (Ederef
                          (Ecast
                            (Ebinop Oadd
                              (Ebinop Oor
                                (Ebinop Oand (Econst_int (Int.repr 8) tint)
                                  (Econst_int (Int.repr 3) tint) tint)
                                (Ebinop Oshl
                                  (Ebinop Oand (Econst_int (Int.repr 8) tint)
                                    (Eunop Onotint
                                      (Econst_int (Int.repr 3) tint) tint)
                                    tint)
                                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                    (Econst_int (Int.repr 3) tint) tuint)
                                  tint) tint)
                              (Ecast
                                (Etempvar _t'25 (tptr (Tstruct _LevelCommand noattr)))
                                (tptr tuchar)) (tptr tuchar)) (tptr tshort))
                          tshort))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                                (Tstruct _SpawnInfo noattr)) _startPos
                              (tarray tshort 3))
                            (Econst_int (Int.repr 2) tint) (tptr tshort))
                          tshort) (Etempvar _t'26 tshort))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'23
                        (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                      (Ssequence
                        (Sset _t'24
                          (Ederef
                            (Ecast
                              (Ebinop Oadd
                                (Ebinop Oor
                                  (Ebinop Oand
                                    (Econst_int (Int.repr 10) tint)
                                    (Econst_int (Int.repr 3) tint) tint)
                                  (Ebinop Oshl
                                    (Ebinop Oand
                                      (Econst_int (Int.repr 10) tint)
                                      (Eunop Onotint
                                        (Econst_int (Int.repr 3) tint) tint)
                                      tint)
                                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                      (Econst_int (Int.repr 3) tint) tuint)
                                    tint) tint)
                                (Ecast
                                  (Etempvar _t'23 (tptr (Tstruct _LevelCommand noattr)))
                                  (tptr tuchar)) (tptr tuchar))
                              (tptr tshort)) tshort))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                                  (Tstruct _SpawnInfo noattr)) _startAngle
                                (tarray tshort 3))
                              (Econst_int (Int.repr 0) tint) (tptr tshort))
                            tshort)
                          (Ebinop Odiv
                            (Ebinop Omul (Etempvar _t'24 tshort)
                              (Econst_int (Int.repr 32768) tint) tint)
                            (Econst_int (Int.repr 180) tint) tint))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'21
                          (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                        (Ssequence
                          (Sset _t'22
                            (Ederef
                              (Ecast
                                (Ebinop Oadd
                                  (Ebinop Oor
                                    (Ebinop Oand
                                      (Econst_int (Int.repr 12) tint)
                                      (Econst_int (Int.repr 3) tint) tint)
                                    (Ebinop Oshl
                                      (Ebinop Oand
                                        (Econst_int (Int.repr 12) tint)
                                        (Eunop Onotint
                                          (Econst_int (Int.repr 3) tint)
                                          tint) tint)
                                      (Ebinop Oshr
                                        (Esizeof (tptr tvoid) tuint)
                                        (Econst_int (Int.repr 3) tint) tuint)
                                      tint) tint)
                                  (Ecast
                                    (Etempvar _t'21 (tptr (Tstruct _LevelCommand noattr)))
                                    (tptr tuchar)) (tptr tuchar))
                                (tptr tshort)) tshort))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                                    (Tstruct _SpawnInfo noattr)) _startAngle
                                  (tarray tshort 3))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))
                              tshort)
                            (Ebinop Odiv
                              (Ebinop Omul (Etempvar _t'22 tshort)
                                (Econst_int (Int.repr 32768) tint) tint)
                              (Econst_int (Int.repr 180) tint) tint))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'19
                            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                          (Ssequence
                            (Sset _t'20
                              (Ederef
                                (Ecast
                                  (Ebinop Oadd
                                    (Ebinop Oor
                                      (Ebinop Oand
                                        (Econst_int (Int.repr 14) tint)
                                        (Econst_int (Int.repr 3) tint) tint)
                                      (Ebinop Oshl
                                        (Ebinop Oand
                                          (Econst_int (Int.repr 14) tint)
                                          (Eunop Onotint
                                            (Econst_int (Int.repr 3) tint)
                                            tint) tint)
                                        (Ebinop Oshr
                                          (Esizeof (tptr tvoid) tuint)
                                          (Econst_int (Int.repr 3) tint)
                                          tuint) tint) tint)
                                    (Ecast
                                      (Etempvar _t'19 (tptr (Tstruct _LevelCommand noattr)))
                                      (tptr tuchar)) (tptr tuchar))
                                  (tptr tshort)) tshort))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                                      (Tstruct _SpawnInfo noattr))
                                    _startAngle (tarray tshort 3))
                                  (Econst_int (Int.repr 2) tint)
                                  (tptr tshort)) tshort)
                              (Ebinop Odiv
                                (Ebinop Omul (Etempvar _t'20 tshort)
                                  (Econst_int (Int.repr 32768) tint) tint)
                                (Econst_int (Int.repr 180) tint) tint))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'18 (Evar _sCurrAreaIndex tshort))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                                  (Tstruct _SpawnInfo noattr)) _areaIndex
                                tschar) (Etempvar _t'18 tshort)))
                          (Ssequence
                            (Ssequence
                              (Sset _t'17 (Evar _sCurrAreaIndex tshort))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                                    (Tstruct _SpawnInfo noattr))
                                  _activeAreaIndex tschar)
                                (Etempvar _t'17 tshort)))
                            (Ssequence
                              (Ssequence
                                (Sset _t'15
                                  (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                                (Ssequence
                                  (Sset _t'16
                                    (Ederef
                                      (Ecast
                                        (Ebinop Oadd
                                          (Ebinop Oor
                                            (Ebinop Oand
                                              (Econst_int (Int.repr 16) tint)
                                              (Econst_int (Int.repr 3) tint)
                                              tint)
                                            (Ebinop Oshl
                                              (Ebinop Oand
                                                (Econst_int (Int.repr 16) tint)
                                                (Eunop Onotint
                                                  (Econst_int (Int.repr 3) tint)
                                                  tint) tint)
                                              (Ebinop Oshr
                                                (Esizeof (tptr tvoid) tuint)
                                                (Econst_int (Int.repr 3) tint)
                                                tuint) tint) tint)
                                          (Ecast
                                            (Etempvar _t'15 (tptr (Tstruct _LevelCommand noattr)))
                                            (tptr tuchar)) (tptr tuchar))
                                        (tptr tuint)) tuint))
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                                        (Tstruct _SpawnInfo noattr))
                                      _behaviorArg tuint)
                                    (Etempvar _t'16 tuint))))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'13
                                    (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                                  (Ssequence
                                    (Sset _t'14
                                      (Ederef
                                        (Ecast
                                          (Ebinop Oadd
                                            (Ebinop Oor
                                              (Ebinop Oand
                                                (Econst_int (Int.repr 20) tint)
                                                (Econst_int (Int.repr 3) tint)
                                                tint)
                                              (Ebinop Oshl
                                                (Ebinop Oand
                                                  (Econst_int (Int.repr 20) tint)
                                                  (Eunop Onotint
                                                    (Econst_int (Int.repr 3) tint)
                                                    tint) tint)
                                                (Ebinop Oshr
                                                  (Esizeof (tptr tvoid) tuint)
                                                  (Econst_int (Int.repr 3) tint)
                                                  tuint) tint) tint)
                                            (Ecast
                                              (Etempvar _t'13 (tptr (Tstruct _LevelCommand noattr)))
                                              (tptr tuchar)) (tptr tuchar))
                                          (tptr (tptr tvoid))) (tptr tvoid)))
                                    (Sassign
                                      (Efield
                                        (Ederef
                                          (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                                          (Tstruct _SpawnInfo noattr))
                                        _behaviorScript (tptr tvoid))
                                      (Etempvar _t'14 (tptr tvoid)))))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'11
                                      (Evar _gLoadedGraphNodes (tptr (tptr (Tstruct _GraphNode noattr)))))
                                    (Ssequence
                                      (Sset _t'12
                                        (Ederef
                                          (Ebinop Oadd
                                            (Etempvar _t'11 (tptr (tptr (Tstruct _GraphNode noattr))))
                                            (Etempvar _model tushort)
                                            (tptr (tptr (Tstruct _GraphNode noattr))))
                                          (tptr (Tstruct _GraphNode noattr))))
                                      (Sassign
                                        (Efield
                                          (Ederef
                                            (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                                            (Tstruct _SpawnInfo noattr))
                                          _model
                                          (tptr (Tstruct _GraphNode noattr)))
                                        (Etempvar _t'12 (tptr (Tstruct _GraphNode noattr))))))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'8
                                        (Evar _gAreas (tptr (Tstruct _Area noattr))))
                                      (Ssequence
                                        (Sset _t'9
                                          (Evar _sCurrAreaIndex tshort))
                                        (Ssequence
                                          (Sset _t'10
                                            (Efield
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Etempvar _t'8 (tptr (Tstruct _Area noattr)))
                                                  (Etempvar _t'9 tshort)
                                                  (tptr (Tstruct _Area noattr)))
                                                (Tstruct _Area noattr))
                                              _objectSpawnInfos
                                              (tptr (Tstruct _SpawnInfo noattr))))
                                          (Sassign
                                            (Efield
                                              (Ederef
                                                (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                                                (Tstruct _SpawnInfo noattr))
                                              _next
                                              (tptr (Tstruct _SpawnInfo noattr)))
                                            (Etempvar _t'10 (tptr (Tstruct _SpawnInfo noattr)))))))
                                    (Ssequence
                                      (Sset _t'6
                                        (Evar _gAreas (tptr (Tstruct _Area noattr))))
                                      (Ssequence
                                        (Sset _t'7
                                          (Evar _sCurrAreaIndex tshort))
                                        (Sassign
                                          (Efield
                                            (Ederef
                                              (Ebinop Oadd
                                                (Etempvar _t'6 (tptr (Tstruct _Area noattr)))
                                                (Etempvar _t'7 tshort)
                                                (tptr (Tstruct _Area noattr)))
                                              (Tstruct _Area noattr))
                                            _objectSpawnInfos
                                            (tptr (Tstruct _SpawnInfo noattr)))
                                          (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr))))))))))))))))))))
        Sskip))
    (Ssequence
      (Sset _t'3 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'4 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
                (Tstruct _LevelCommand noattr)) _size tuchar))
          (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
            (Ecast
              (Ebinop Oadd
                (Ecast (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
                  (tptr tuchar))
                (Ebinop Oshl (Etempvar _t'5 tuchar)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint)
                (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr)))))))))
|}.

Definition f_level_cmd_create_warp_node := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_warpNode, (tptr (Tstruct _ObjectWarpNode noattr))) ::
               (_t'1, (tptr tvoid)) ::
               (_t'21, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'20, tuchar) ::
               (_t'19, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'18, tuchar) ::
               (_t'17, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'16, tuchar) ::
               (_t'15, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'14, tuchar) ::
               (_t'13, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'12, tuchar) ::
               (_t'11, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'10, (tptr (Tstruct _ObjectWarpNode noattr))) ::
               (_t'9, tshort) :: (_t'8, (tptr (Tstruct _Area noattr))) ::
               (_t'7, tshort) :: (_t'6, (tptr (Tstruct _Area noattr))) ::
               (_t'5, tshort) :: (_t'4, tuchar) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5 (Evar _sCurrAreaIndex tshort))
    (Sifthenelse (Ebinop One (Etempvar _t'5 tshort)
                   (Eunop Oneg (Econst_int (Int.repr 1) tint) tint) tint)
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'21
              (Evar _sLevelPool (tptr (Tstruct _AllocOnlyPool noattr))))
            (Scall (Some _t'1)
              (Evar _alloc_only_pool_alloc (Tfunction
                                             ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                              tint :: nil) (tptr tvoid)
                                             cc_default))
              ((Etempvar _t'21 (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (Esizeof (Tstruct _ObjectWarpNode noattr) tuint) :: nil)))
          (Sset _warpNode (Etempvar _t'1 (tptr tvoid))))
        (Ssequence
          (Ssequence
            (Sset _t'19
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
            (Ssequence
              (Sset _t'20
                (Ederef
                  (Ecast
                    (Ebinop Oadd
                      (Ebinop Oor
                        (Ebinop Oand (Econst_int (Int.repr 2) tint)
                          (Econst_int (Int.repr 3) tint) tint)
                        (Ebinop Oshl
                          (Ebinop Oand (Econst_int (Int.repr 2) tint)
                            (Eunop Onotint (Econst_int (Int.repr 3) tint)
                              tint) tint)
                          (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                            (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                      (Ecast
                        (Etempvar _t'19 (tptr (Tstruct _LevelCommand noattr)))
                        (tptr tuchar)) (tptr tuchar)) (tptr tuchar)) tuchar))
              (Sassign
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _warpNode (tptr (Tstruct _ObjectWarpNode noattr)))
                      (Tstruct _ObjectWarpNode noattr)) _node
                    (Tstruct _WarpNode noattr)) _id tuchar)
                (Etempvar _t'20 tuchar))))
          (Ssequence
            (Ssequence
              (Sset _t'15
                (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
              (Ssequence
                (Sset _t'16
                  (Ederef
                    (Ecast
                      (Ebinop Oadd
                        (Ebinop Oor
                          (Ebinop Oand (Econst_int (Int.repr 3) tint)
                            (Econst_int (Int.repr 3) tint) tint)
                          (Ebinop Oshl
                            (Ebinop Oand (Econst_int (Int.repr 3) tint)
                              (Eunop Onotint (Econst_int (Int.repr 3) tint)
                                tint) tint)
                            (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                              (Econst_int (Int.repr 3) tint) tuint) tint)
                          tint)
                        (Ecast
                          (Etempvar _t'15 (tptr (Tstruct _LevelCommand noattr)))
                          (tptr tuchar)) (tptr tuchar)) (tptr tuchar))
                    tuchar))
                (Ssequence
                  (Sset _t'17
                    (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                  (Ssequence
                    (Sset _t'18
                      (Ederef
                        (Ecast
                          (Ebinop Oadd
                            (Ebinop Oor
                              (Ebinop Oand (Econst_int (Int.repr 6) tint)
                                (Econst_int (Int.repr 3) tint) tint)
                              (Ebinop Oshl
                                (Ebinop Oand (Econst_int (Int.repr 6) tint)
                                  (Eunop Onotint
                                    (Econst_int (Int.repr 3) tint) tint)
                                  tint)
                                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                  (Econst_int (Int.repr 3) tint) tuint) tint)
                              tint)
                            (Ecast
                              (Etempvar _t'17 (tptr (Tstruct _LevelCommand noattr)))
                              (tptr tuchar)) (tptr tuchar)) (tptr tuchar))
                        tuchar))
                    (Sassign
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _warpNode (tptr (Tstruct _ObjectWarpNode noattr)))
                            (Tstruct _ObjectWarpNode noattr)) _node
                          (Tstruct _WarpNode noattr)) _destLevel tuchar)
                      (Ebinop Oadd (Etempvar _t'16 tuchar)
                        (Etempvar _t'18 tuchar) tint))))))
            (Ssequence
              (Ssequence
                (Sset _t'13
                  (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                (Ssequence
                  (Sset _t'14
                    (Ederef
                      (Ecast
                        (Ebinop Oadd
                          (Ebinop Oor
                            (Ebinop Oand (Econst_int (Int.repr 4) tint)
                              (Econst_int (Int.repr 3) tint) tint)
                            (Ebinop Oshl
                              (Ebinop Oand (Econst_int (Int.repr 4) tint)
                                (Eunop Onotint (Econst_int (Int.repr 3) tint)
                                  tint) tint)
                              (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                (Econst_int (Int.repr 3) tint) tuint) tint)
                            tint)
                          (Ecast
                            (Etempvar _t'13 (tptr (Tstruct _LevelCommand noattr)))
                            (tptr tuchar)) (tptr tuchar)) (tptr tuchar))
                      tuchar))
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _warpNode (tptr (Tstruct _ObjectWarpNode noattr)))
                          (Tstruct _ObjectWarpNode noattr)) _node
                        (Tstruct _WarpNode noattr)) _destArea tuchar)
                    (Etempvar _t'14 tuchar))))
              (Ssequence
                (Ssequence
                  (Sset _t'11
                    (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                  (Ssequence
                    (Sset _t'12
                      (Ederef
                        (Ecast
                          (Ebinop Oadd
                            (Ebinop Oor
                              (Ebinop Oand (Econst_int (Int.repr 5) tint)
                                (Econst_int (Int.repr 3) tint) tint)
                              (Ebinop Oshl
                                (Ebinop Oand (Econst_int (Int.repr 5) tint)
                                  (Eunop Onotint
                                    (Econst_int (Int.repr 3) tint) tint)
                                  tint)
                                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                  (Econst_int (Int.repr 3) tint) tuint) tint)
                              tint)
                            (Ecast
                              (Etempvar _t'11 (tptr (Tstruct _LevelCommand noattr)))
                              (tptr tuchar)) (tptr tuchar)) (tptr tuchar))
                        tuchar))
                    (Sassign
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _warpNode (tptr (Tstruct _ObjectWarpNode noattr)))
                            (Tstruct _ObjectWarpNode noattr)) _node
                          (Tstruct _WarpNode noattr)) _destNode tuchar)
                      (Etempvar _t'12 tuchar))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _warpNode (tptr (Tstruct _ObjectWarpNode noattr)))
                        (Tstruct _ObjectWarpNode noattr)) _object
                      (tptr (Tstruct _Object noattr)))
                    (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'8
                        (Evar _gAreas (tptr (Tstruct _Area noattr))))
                      (Ssequence
                        (Sset _t'9 (Evar _sCurrAreaIndex tshort))
                        (Ssequence
                          (Sset _t'10
                            (Efield
                              (Ederef
                                (Ebinop Oadd
                                  (Etempvar _t'8 (tptr (Tstruct _Area noattr)))
                                  (Etempvar _t'9 tshort)
                                  (tptr (Tstruct _Area noattr)))
                                (Tstruct _Area noattr)) _warpNodes
                              (tptr (Tstruct _ObjectWarpNode noattr))))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _warpNode (tptr (Tstruct _ObjectWarpNode noattr)))
                                (Tstruct _ObjectWarpNode noattr)) _next
                              (tptr (Tstruct _ObjectWarpNode noattr)))
                            (Etempvar _t'10 (tptr (Tstruct _ObjectWarpNode noattr)))))))
                    (Ssequence
                      (Sset _t'6
                        (Evar _gAreas (tptr (Tstruct _Area noattr))))
                      (Ssequence
                        (Sset _t'7 (Evar _sCurrAreaIndex tshort))
                        (Sassign
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Etempvar _t'6 (tptr (Tstruct _Area noattr)))
                                (Etempvar _t'7 tshort)
                                (tptr (Tstruct _Area noattr)))
                              (Tstruct _Area noattr)) _warpNodes
                            (tptr (Tstruct _ObjectWarpNode noattr)))
                          (Etempvar _warpNode (tptr (Tstruct _ObjectWarpNode noattr)))))))))))))
      Sskip))
  (Ssequence
    (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'3 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'4 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_create_instant_warp := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_warp, (tptr (Tstruct _InstantWarp noattr))) ::
               (_t'1, (tptr tvoid)) ::
               (_t'27, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'26, tshort) :: (_t'25, (tptr (Tstruct _Area noattr))) ::
               (_t'24, (tptr (Tstruct _InstantWarp noattr))) ::
               (_t'23, tshort) :: (_t'22, (tptr (Tstruct _Area noattr))) ::
               (_t'21, (tptr (Tstruct _InstantWarp noattr))) ::
               (_t'20, tshort) :: (_t'19, (tptr (Tstruct _Area noattr))) ::
               (_t'18, tuchar) ::
               (_t'17, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'16, (tptr (Tstruct _InstantWarp noattr))) ::
               (_t'15, tshort) :: (_t'14, (tptr (Tstruct _Area noattr))) ::
               (_t'13, tuchar) ::
               (_t'12, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'11, tshort) ::
               (_t'10, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'9, tshort) ::
               (_t'8, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'7, tshort) ::
               (_t'6, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'5, tshort) :: (_t'4, tuchar) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5 (Evar _sCurrAreaIndex tshort))
    (Sifthenelse (Ebinop One (Etempvar _t'5 tshort)
                   (Eunop Oneg (Econst_int (Int.repr 1) tint) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'19 (Evar _gAreas (tptr (Tstruct _Area noattr))))
          (Ssequence
            (Sset _t'20 (Evar _sCurrAreaIndex tshort))
            (Ssequence
              (Sset _t'21
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Etempvar _t'19 (tptr (Tstruct _Area noattr)))
                      (Etempvar _t'20 tshort) (tptr (Tstruct _Area noattr)))
                    (Tstruct _Area noattr)) _instantWarps
                  (tptr (Tstruct _InstantWarp noattr))))
              (Sifthenelse (Ebinop Oeq
                             (Etempvar _t'21 (tptr (Tstruct _InstantWarp noattr)))
                             (Ecast (Econst_int (Int.repr 0) tint)
                               (tptr tvoid)) tint)
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'27
                        (Evar _sLevelPool (tptr (Tstruct _AllocOnlyPool noattr))))
                      (Scall (Some _t'1)
                        (Evar _alloc_only_pool_alloc (Tfunction
                                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                        tint :: nil)
                                                       (tptr tvoid)
                                                       cc_default))
                        ((Etempvar _t'27 (tptr (Tstruct _AllocOnlyPool noattr))) ::
                         (Ebinop Omul (Econst_int (Int.repr 4) tint)
                           (Esizeof (Tstruct _InstantWarp noattr) tuint)
                           tuint) :: nil)))
                    (Ssequence
                      (Sset _t'25
                        (Evar _gAreas (tptr (Tstruct _Area noattr))))
                      (Ssequence
                        (Sset _t'26 (Evar _sCurrAreaIndex tshort))
                        (Sassign
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Etempvar _t'25 (tptr (Tstruct _Area noattr)))
                                (Etempvar _t'26 tshort)
                                (tptr (Tstruct _Area noattr)))
                              (Tstruct _Area noattr)) _instantWarps
                            (tptr (Tstruct _InstantWarp noattr)))
                          (Etempvar _t'1 (tptr tvoid))))))
                  (Ssequence
                    (Sset _i (Econst_int (Int.repr 0) tint))
                    (Sloop
                      (Ssequence
                        (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                                       (Econst_int (Int.repr 4) tint) tint)
                          Sskip
                          Sbreak)
                        (Ssequence
                          (Sset _t'22
                            (Evar _gAreas (tptr (Tstruct _Area noattr))))
                          (Ssequence
                            (Sset _t'23 (Evar _sCurrAreaIndex tshort))
                            (Ssequence
                              (Sset _t'24
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'22 (tptr (Tstruct _Area noattr)))
                                      (Etempvar _t'23 tshort)
                                      (tptr (Tstruct _Area noattr)))
                                    (Tstruct _Area noattr)) _instantWarps
                                  (tptr (Tstruct _InstantWarp noattr))))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'24 (tptr (Tstruct _InstantWarp noattr)))
                                      (Etempvar _i tint)
                                      (tptr (Tstruct _InstantWarp noattr)))
                                    (Tstruct _InstantWarp noattr)) _id
                                  tuchar) (Econst_int (Int.repr 0) tint))))))
                      (Sset _i
                        (Ebinop Oadd (Etempvar _i tint)
                          (Econst_int (Int.repr 1) tint) tint)))))
                Sskip))))
        (Ssequence
          (Ssequence
            (Sset _t'14 (Evar _gAreas (tptr (Tstruct _Area noattr))))
            (Ssequence
              (Sset _t'15 (Evar _sCurrAreaIndex tshort))
              (Ssequence
                (Sset _t'16
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Etempvar _t'14 (tptr (Tstruct _Area noattr)))
                        (Etempvar _t'15 tshort)
                        (tptr (Tstruct _Area noattr)))
                      (Tstruct _Area noattr)) _instantWarps
                    (tptr (Tstruct _InstantWarp noattr))))
                (Ssequence
                  (Sset _t'17
                    (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                  (Ssequence
                    (Sset _t'18
                      (Ederef
                        (Ecast
                          (Ebinop Oadd
                            (Ebinop Oor
                              (Ebinop Oand (Econst_int (Int.repr 2) tint)
                                (Econst_int (Int.repr 3) tint) tint)
                              (Ebinop Oshl
                                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                                  (Eunop Onotint
                                    (Econst_int (Int.repr 3) tint) tint)
                                  tint)
                                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                  (Econst_int (Int.repr 3) tint) tuint) tint)
                              tint)
                            (Ecast
                              (Etempvar _t'17 (tptr (Tstruct _LevelCommand noattr)))
                              (tptr tuchar)) (tptr tuchar)) (tptr tuchar))
                        tuchar))
                    (Sset _warp
                      (Ebinop Oadd
                        (Etempvar _t'16 (tptr (Tstruct _InstantWarp noattr)))
                        (Etempvar _t'18 tuchar)
                        (tptr (Tstruct _InstantWarp noattr)))))))))
          (Ssequence
            (Sassign
              (Efield
                (Ederef
                  (Ebinop Oadd
                    (Etempvar _warp (tptr (Tstruct _InstantWarp noattr)))
                    (Econst_int (Int.repr 0) tint)
                    (tptr (Tstruct _InstantWarp noattr)))
                  (Tstruct _InstantWarp noattr)) _id tuchar)
              (Econst_int (Int.repr 1) tint))
            (Ssequence
              (Ssequence
                (Sset _t'12
                  (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                (Ssequence
                  (Sset _t'13
                    (Ederef
                      (Ecast
                        (Ebinop Oadd
                          (Ebinop Oor
                            (Ebinop Oand (Econst_int (Int.repr 3) tint)
                              (Econst_int (Int.repr 3) tint) tint)
                            (Ebinop Oshl
                              (Ebinop Oand (Econst_int (Int.repr 3) tint)
                                (Eunop Onotint (Econst_int (Int.repr 3) tint)
                                  tint) tint)
                              (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                (Econst_int (Int.repr 3) tint) tuint) tint)
                            tint)
                          (Ecast
                            (Etempvar _t'12 (tptr (Tstruct _LevelCommand noattr)))
                            (tptr tuchar)) (tptr tuchar)) (tptr tuchar))
                      tuchar))
                  (Sassign
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Etempvar _warp (tptr (Tstruct _InstantWarp noattr)))
                          (Econst_int (Int.repr 0) tint)
                          (tptr (Tstruct _InstantWarp noattr)))
                        (Tstruct _InstantWarp noattr)) _area tuchar)
                    (Etempvar _t'13 tuchar))))
              (Ssequence
                (Ssequence
                  (Sset _t'10
                    (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                  (Ssequence
                    (Sset _t'11
                      (Ederef
                        (Ecast
                          (Ebinop Oadd
                            (Ebinop Oor
                              (Ebinop Oand (Econst_int (Int.repr 4) tint)
                                (Econst_int (Int.repr 3) tint) tint)
                              (Ebinop Oshl
                                (Ebinop Oand (Econst_int (Int.repr 4) tint)
                                  (Eunop Onotint
                                    (Econst_int (Int.repr 3) tint) tint)
                                  tint)
                                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                  (Econst_int (Int.repr 3) tint) tuint) tint)
                              tint)
                            (Ecast
                              (Etempvar _t'10 (tptr (Tstruct _LevelCommand noattr)))
                              (tptr tuchar)) (tptr tuchar)) (tptr tshort))
                        tshort))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Etempvar _warp (tptr (Tstruct _InstantWarp noattr)))
                                (Econst_int (Int.repr 0) tint)
                                (tptr (Tstruct _InstantWarp noattr)))
                              (Tstruct _InstantWarp noattr)) _displacement
                            (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                          (tptr tshort)) tshort) (Etempvar _t'11 tshort))))
                (Ssequence
                  (Ssequence
                    (Sset _t'8
                      (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                    (Ssequence
                      (Sset _t'9
                        (Ederef
                          (Ecast
                            (Ebinop Oadd
                              (Ebinop Oor
                                (Ebinop Oand (Econst_int (Int.repr 6) tint)
                                  (Econst_int (Int.repr 3) tint) tint)
                                (Ebinop Oshl
                                  (Ebinop Oand (Econst_int (Int.repr 6) tint)
                                    (Eunop Onotint
                                      (Econst_int (Int.repr 3) tint) tint)
                                    tint)
                                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                    (Econst_int (Int.repr 3) tint) tuint)
                                  tint) tint)
                              (Ecast
                                (Etempvar _t'8 (tptr (Tstruct _LevelCommand noattr)))
                                (tptr tuchar)) (tptr tuchar)) (tptr tshort))
                          tshort))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Ebinop Oadd
                                  (Etempvar _warp (tptr (Tstruct _InstantWarp noattr)))
                                  (Econst_int (Int.repr 0) tint)
                                  (tptr (Tstruct _InstantWarp noattr)))
                                (Tstruct _InstantWarp noattr)) _displacement
                              (tarray tshort 3))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))
                          tshort) (Etempvar _t'9 tshort))))
                  (Ssequence
                    (Sset _t'6
                      (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                    (Ssequence
                      (Sset _t'7
                        (Ederef
                          (Ecast
                            (Ebinop Oadd
                              (Ebinop Oor
                                (Ebinop Oand (Econst_int (Int.repr 8) tint)
                                  (Econst_int (Int.repr 3) tint) tint)
                                (Ebinop Oshl
                                  (Ebinop Oand (Econst_int (Int.repr 8) tint)
                                    (Eunop Onotint
                                      (Econst_int (Int.repr 3) tint) tint)
                                    tint)
                                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                    (Econst_int (Int.repr 3) tint) tuint)
                                  tint) tint)
                              (Ecast
                                (Etempvar _t'6 (tptr (Tstruct _LevelCommand noattr)))
                                (tptr tuchar)) (tptr tuchar)) (tptr tshort))
                          tshort))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Ebinop Oadd
                                  (Etempvar _warp (tptr (Tstruct _InstantWarp noattr)))
                                  (Econst_int (Int.repr 0) tint)
                                  (tptr (Tstruct _InstantWarp noattr)))
                                (Tstruct _InstantWarp noattr)) _displacement
                              (tarray tshort 3))
                            (Econst_int (Int.repr 2) tint) (tptr tshort))
                          tshort) (Etempvar _t'7 tshort))))))))))
      Sskip))
  (Ssequence
    (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'3 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'4 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_set_terrain_type := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'11, tshort) ::
               (_t'10, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'9, tushort) :: (_t'8, tshort) ::
               (_t'7, (tptr (Tstruct _Area noattr))) :: (_t'6, tshort) ::
               (_t'5, (tptr (Tstruct _Area noattr))) :: (_t'4, tshort) ::
               (_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _sCurrAreaIndex tshort))
    (Sifthenelse (Ebinop One (Etempvar _t'4 tshort)
                   (Eunop Oneg (Econst_int (Int.repr 1) tint) tint) tint)
      (Ssequence
        (Sset _t'5 (Evar _gAreas (tptr (Tstruct _Area noattr))))
        (Ssequence
          (Sset _t'6 (Evar _sCurrAreaIndex tshort))
          (Ssequence
            (Sset _t'7 (Evar _gAreas (tptr (Tstruct _Area noattr))))
            (Ssequence
              (Sset _t'8 (Evar _sCurrAreaIndex tshort))
              (Ssequence
                (Sset _t'9
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Etempvar _t'7 (tptr (Tstruct _Area noattr)))
                        (Etempvar _t'8 tshort) (tptr (Tstruct _Area noattr)))
                      (Tstruct _Area noattr)) _terrainType tushort))
                (Ssequence
                  (Sset _t'10
                    (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                  (Ssequence
                    (Sset _t'11
                      (Ederef
                        (Ecast
                          (Ebinop Oadd
                            (Ebinop Oor
                              (Ebinop Oand (Econst_int (Int.repr 2) tint)
                                (Econst_int (Int.repr 3) tint) tint)
                              (Ebinop Oshl
                                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                                  (Eunop Onotint
                                    (Econst_int (Int.repr 3) tint) tint)
                                  tint)
                                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                  (Econst_int (Int.repr 3) tint) tuint) tint)
                              tint)
                            (Ecast
                              (Etempvar _t'10 (tptr (Tstruct _LevelCommand noattr)))
                              (tptr tuchar)) (tptr tuchar)) (tptr tshort))
                        tshort))
                    (Sassign
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Etempvar _t'5 (tptr (Tstruct _Area noattr)))
                            (Etempvar _t'6 tshort)
                            (tptr (Tstruct _Area noattr)))
                          (Tstruct _Area noattr)) _terrainType tushort)
                      (Ebinop Oor (Etempvar _t'9 tushort)
                        (Etempvar _t'11 tshort) tint)))))))))
      Sskip))
  (Ssequence
    (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'3 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_create_painting_warp_node := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_node, (tptr (Tstruct _WarpNode noattr))) ::
               (_t'1, (tptr tvoid)) ::
               (_t'27, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'26, tshort) :: (_t'25, (tptr (Tstruct _Area noattr))) ::
               (_t'24, (tptr (Tstruct _WarpNode noattr))) ::
               (_t'23, tshort) :: (_t'22, (tptr (Tstruct _Area noattr))) ::
               (_t'21, (tptr (Tstruct _WarpNode noattr))) ::
               (_t'20, tshort) :: (_t'19, (tptr (Tstruct _Area noattr))) ::
               (_t'18, tuchar) ::
               (_t'17, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'16, (tptr (Tstruct _WarpNode noattr))) ::
               (_t'15, tshort) :: (_t'14, (tptr (Tstruct _Area noattr))) ::
               (_t'13, tuchar) ::
               (_t'12, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'11, tuchar) ::
               (_t'10, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'9, tuchar) ::
               (_t'8, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'7, tuchar) ::
               (_t'6, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'5, tshort) :: (_t'4, tuchar) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5 (Evar _sCurrAreaIndex tshort))
    (Sifthenelse (Ebinop One (Etempvar _t'5 tshort)
                   (Eunop Oneg (Econst_int (Int.repr 1) tint) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'19 (Evar _gAreas (tptr (Tstruct _Area noattr))))
          (Ssequence
            (Sset _t'20 (Evar _sCurrAreaIndex tshort))
            (Ssequence
              (Sset _t'21
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Etempvar _t'19 (tptr (Tstruct _Area noattr)))
                      (Etempvar _t'20 tshort) (tptr (Tstruct _Area noattr)))
                    (Tstruct _Area noattr)) _paintingWarpNodes
                  (tptr (Tstruct _WarpNode noattr))))
              (Sifthenelse (Ebinop Oeq
                             (Etempvar _t'21 (tptr (Tstruct _WarpNode noattr)))
                             (Ecast (Econst_int (Int.repr 0) tint)
                               (tptr tvoid)) tint)
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'27
                        (Evar _sLevelPool (tptr (Tstruct _AllocOnlyPool noattr))))
                      (Scall (Some _t'1)
                        (Evar _alloc_only_pool_alloc (Tfunction
                                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                        tint :: nil)
                                                       (tptr tvoid)
                                                       cc_default))
                        ((Etempvar _t'27 (tptr (Tstruct _AllocOnlyPool noattr))) ::
                         (Ebinop Omul (Econst_int (Int.repr 45) tint)
                           (Esizeof (Tstruct _WarpNode noattr) tuint) tuint) ::
                         nil)))
                    (Ssequence
                      (Sset _t'25
                        (Evar _gAreas (tptr (Tstruct _Area noattr))))
                      (Ssequence
                        (Sset _t'26 (Evar _sCurrAreaIndex tshort))
                        (Sassign
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Etempvar _t'25 (tptr (Tstruct _Area noattr)))
                                (Etempvar _t'26 tshort)
                                (tptr (Tstruct _Area noattr)))
                              (Tstruct _Area noattr)) _paintingWarpNodes
                            (tptr (Tstruct _WarpNode noattr)))
                          (Etempvar _t'1 (tptr tvoid))))))
                  (Ssequence
                    (Sset _i (Econst_int (Int.repr 0) tint))
                    (Sloop
                      (Ssequence
                        (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                                       (Econst_int (Int.repr 45) tint) tint)
                          Sskip
                          Sbreak)
                        (Ssequence
                          (Sset _t'22
                            (Evar _gAreas (tptr (Tstruct _Area noattr))))
                          (Ssequence
                            (Sset _t'23 (Evar _sCurrAreaIndex tshort))
                            (Ssequence
                              (Sset _t'24
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'22 (tptr (Tstruct _Area noattr)))
                                      (Etempvar _t'23 tshort)
                                      (tptr (Tstruct _Area noattr)))
                                    (Tstruct _Area noattr))
                                  _paintingWarpNodes
                                  (tptr (Tstruct _WarpNode noattr))))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'24 (tptr (Tstruct _WarpNode noattr)))
                                      (Etempvar _i tint)
                                      (tptr (Tstruct _WarpNode noattr)))
                                    (Tstruct _WarpNode noattr)) _id tuchar)
                                (Econst_int (Int.repr 0) tint))))))
                      (Sset _i
                        (Ebinop Oadd (Etempvar _i tint)
                          (Econst_int (Int.repr 1) tint) tint)))))
                Sskip))))
        (Ssequence
          (Ssequence
            (Sset _t'14 (Evar _gAreas (tptr (Tstruct _Area noattr))))
            (Ssequence
              (Sset _t'15 (Evar _sCurrAreaIndex tshort))
              (Ssequence
                (Sset _t'16
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Etempvar _t'14 (tptr (Tstruct _Area noattr)))
                        (Etempvar _t'15 tshort)
                        (tptr (Tstruct _Area noattr)))
                      (Tstruct _Area noattr)) _paintingWarpNodes
                    (tptr (Tstruct _WarpNode noattr))))
                (Ssequence
                  (Sset _t'17
                    (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                  (Ssequence
                    (Sset _t'18
                      (Ederef
                        (Ecast
                          (Ebinop Oadd
                            (Ebinop Oor
                              (Ebinop Oand (Econst_int (Int.repr 2) tint)
                                (Econst_int (Int.repr 3) tint) tint)
                              (Ebinop Oshl
                                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                                  (Eunop Onotint
                                    (Econst_int (Int.repr 3) tint) tint)
                                  tint)
                                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                  (Econst_int (Int.repr 3) tint) tuint) tint)
                              tint)
                            (Ecast
                              (Etempvar _t'17 (tptr (Tstruct _LevelCommand noattr)))
                              (tptr tuchar)) (tptr tuchar)) (tptr tuchar))
                        tuchar))
                    (Sset _node
                      (Ebinop Oadd
                        (Etempvar _t'16 (tptr (Tstruct _WarpNode noattr)))
                        (Etempvar _t'18 tuchar)
                        (tptr (Tstruct _WarpNode noattr)))))))))
          (Ssequence
            (Sassign
              (Efield
                (Ederef (Etempvar _node (tptr (Tstruct _WarpNode noattr)))
                  (Tstruct _WarpNode noattr)) _id tuchar)
              (Econst_int (Int.repr 1) tint))
            (Ssequence
              (Ssequence
                (Sset _t'10
                  (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                (Ssequence
                  (Sset _t'11
                    (Ederef
                      (Ecast
                        (Ebinop Oadd
                          (Ebinop Oor
                            (Ebinop Oand (Econst_int (Int.repr 3) tint)
                              (Econst_int (Int.repr 3) tint) tint)
                            (Ebinop Oshl
                              (Ebinop Oand (Econst_int (Int.repr 3) tint)
                                (Eunop Onotint (Econst_int (Int.repr 3) tint)
                                  tint) tint)
                              (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                (Econst_int (Int.repr 3) tint) tuint) tint)
                            tint)
                          (Ecast
                            (Etempvar _t'10 (tptr (Tstruct _LevelCommand noattr)))
                            (tptr tuchar)) (tptr tuchar)) (tptr tuchar))
                      tuchar))
                  (Ssequence
                    (Sset _t'12
                      (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                    (Ssequence
                      (Sset _t'13
                        (Ederef
                          (Ecast
                            (Ebinop Oadd
                              (Ebinop Oor
                                (Ebinop Oand (Econst_int (Int.repr 6) tint)
                                  (Econst_int (Int.repr 3) tint) tint)
                                (Ebinop Oshl
                                  (Ebinop Oand (Econst_int (Int.repr 6) tint)
                                    (Eunop Onotint
                                      (Econst_int (Int.repr 3) tint) tint)
                                    tint)
                                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                    (Econst_int (Int.repr 3) tint) tuint)
                                  tint) tint)
                              (Ecast
                                (Etempvar _t'12 (tptr (Tstruct _LevelCommand noattr)))
                                (tptr tuchar)) (tptr tuchar)) (tptr tuchar))
                          tuchar))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _node (tptr (Tstruct _WarpNode noattr)))
                            (Tstruct _WarpNode noattr)) _destLevel tuchar)
                        (Ebinop Oadd (Etempvar _t'11 tuchar)
                          (Etempvar _t'13 tuchar) tint))))))
              (Ssequence
                (Ssequence
                  (Sset _t'8
                    (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                  (Ssequence
                    (Sset _t'9
                      (Ederef
                        (Ecast
                          (Ebinop Oadd
                            (Ebinop Oor
                              (Ebinop Oand (Econst_int (Int.repr 4) tint)
                                (Econst_int (Int.repr 3) tint) tint)
                              (Ebinop Oshl
                                (Ebinop Oand (Econst_int (Int.repr 4) tint)
                                  (Eunop Onotint
                                    (Econst_int (Int.repr 3) tint) tint)
                                  tint)
                                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                  (Econst_int (Int.repr 3) tint) tuint) tint)
                              tint)
                            (Ecast
                              (Etempvar _t'8 (tptr (Tstruct _LevelCommand noattr)))
                              (tptr tuchar)) (tptr tuchar)) (tptr tuchar))
                        tuchar))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _node (tptr (Tstruct _WarpNode noattr)))
                          (Tstruct _WarpNode noattr)) _destArea tuchar)
                      (Etempvar _t'9 tuchar))))
                (Ssequence
                  (Sset _t'6
                    (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                  (Ssequence
                    (Sset _t'7
                      (Ederef
                        (Ecast
                          (Ebinop Oadd
                            (Ebinop Oor
                              (Ebinop Oand (Econst_int (Int.repr 5) tint)
                                (Econst_int (Int.repr 3) tint) tint)
                              (Ebinop Oshl
                                (Ebinop Oand (Econst_int (Int.repr 5) tint)
                                  (Eunop Onotint
                                    (Econst_int (Int.repr 3) tint) tint)
                                  tint)
                                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                  (Econst_int (Int.repr 3) tint) tuint) tint)
                              tint)
                            (Ecast
                              (Etempvar _t'6 (tptr (Tstruct _LevelCommand noattr)))
                              (tptr tuchar)) (tptr tuchar)) (tptr tuchar))
                        tuchar))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _node (tptr (Tstruct _WarpNode noattr)))
                          (Tstruct _WarpNode noattr)) _destNode tuchar)
                      (Etempvar _t'7 tuchar)))))))))
      Sskip))
  (Ssequence
    (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'3 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'4 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_3A := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_val4, (tptr (Tstruct _UnusedArea28 noattr))) ::
               (_t'3, (tptr (Tstruct _UnusedArea28 noattr))) ::
               (_t'2, (tptr (Tstruct _UnusedArea28 noattr))) ::
               (_t'1, (tptr tvoid)) ::
               (_t'23, (tptr (Tstruct _UnusedArea28 noattr))) ::
               (_t'22, tshort) :: (_t'21, (tptr (Tstruct _Area noattr))) ::
               (_t'20, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'19, tshort) :: (_t'18, (tptr (Tstruct _Area noattr))) ::
               (_t'17, tshort) ::
               (_t'16, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'15, tshort) ::
               (_t'14, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'13, tshort) ::
               (_t'12, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'11, tshort) ::
               (_t'10, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'9, tshort) ::
               (_t'8, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'7, tshort) :: (_t'6, tuchar) ::
               (_t'5, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7 (Evar _sCurrAreaIndex tshort))
    (Sifthenelse (Ebinop One (Etempvar _t'7 tshort)
                   (Eunop Oneg (Econst_int (Int.repr 1) tint) tint) tint)
      (Ssequence
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'21 (Evar _gAreas (tptr (Tstruct _Area noattr))))
              (Ssequence
                (Sset _t'22 (Evar _sCurrAreaIndex tshort))
                (Ssequence
                  (Sset _t'23
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Etempvar _t'21 (tptr (Tstruct _Area noattr)))
                          (Etempvar _t'22 tshort)
                          (tptr (Tstruct _Area noattr)))
                        (Tstruct _Area noattr)) _unused
                      (tptr (Tstruct _UnusedArea28 noattr))))
                  (Sset _t'3
                    (Ecast
                      (Etempvar _t'23 (tptr (Tstruct _UnusedArea28 noattr)))
                      (tptr (Tstruct _UnusedArea28 noattr)))))))
            (Sset _val4
              (Etempvar _t'3 (tptr (Tstruct _UnusedArea28 noattr)))))
          (Sifthenelse (Ebinop Oeq
                         (Etempvar _t'3 (tptr (Tstruct _UnusedArea28 noattr)))
                         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                         tint)
            (Ssequence
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'20
                      (Evar _sLevelPool (tptr (Tstruct _AllocOnlyPool noattr))))
                    (Scall (Some _t'1)
                      (Evar _alloc_only_pool_alloc (Tfunction
                                                     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                      tint :: nil)
                                                     (tptr tvoid) cc_default))
                      ((Etempvar _t'20 (tptr (Tstruct _AllocOnlyPool noattr))) ::
                       (Esizeof (Tstruct _UnusedArea28 noattr) tuint) :: nil)))
                  (Sset _t'2
                    (Ecast (Etempvar _t'1 (tptr tvoid))
                      (tptr (Tstruct _UnusedArea28 noattr)))))
                (Ssequence
                  (Sset _t'18 (Evar _gAreas (tptr (Tstruct _Area noattr))))
                  (Ssequence
                    (Sset _t'19 (Evar _sCurrAreaIndex tshort))
                    (Sassign
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Etempvar _t'18 (tptr (Tstruct _Area noattr)))
                            (Etempvar _t'19 tshort)
                            (tptr (Tstruct _Area noattr)))
                          (Tstruct _Area noattr)) _unused
                        (tptr (Tstruct _UnusedArea28 noattr)))
                      (Etempvar _t'2 (tptr (Tstruct _UnusedArea28 noattr)))))))
              (Sset _val4
                (Etempvar _t'2 (tptr (Tstruct _UnusedArea28 noattr)))))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'16
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
            (Ssequence
              (Sset _t'17
                (Ederef
                  (Ecast
                    (Ebinop Oadd
                      (Ebinop Oor
                        (Ebinop Oand (Econst_int (Int.repr 2) tint)
                          (Econst_int (Int.repr 3) tint) tint)
                        (Ebinop Oshl
                          (Ebinop Oand (Econst_int (Int.repr 2) tint)
                            (Eunop Onotint (Econst_int (Int.repr 3) tint)
                              tint) tint)
                          (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                            (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                      (Ecast
                        (Etempvar _t'16 (tptr (Tstruct _LevelCommand noattr)))
                        (tptr tuchar)) (tptr tuchar)) (tptr tshort)) tshort))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _val4 (tptr (Tstruct _UnusedArea28 noattr)))
                    (Tstruct _UnusedArea28 noattr)) _unk00 tshort)
                (Etempvar _t'17 tshort))))
          (Ssequence
            (Ssequence
              (Sset _t'14
                (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
              (Ssequence
                (Sset _t'15
                  (Ederef
                    (Ecast
                      (Ebinop Oadd
                        (Ebinop Oor
                          (Ebinop Oand (Econst_int (Int.repr 4) tint)
                            (Econst_int (Int.repr 3) tint) tint)
                          (Ebinop Oshl
                            (Ebinop Oand (Econst_int (Int.repr 4) tint)
                              (Eunop Onotint (Econst_int (Int.repr 3) tint)
                                tint) tint)
                            (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                              (Econst_int (Int.repr 3) tint) tuint) tint)
                          tint)
                        (Ecast
                          (Etempvar _t'14 (tptr (Tstruct _LevelCommand noattr)))
                          (tptr tuchar)) (tptr tuchar)) (tptr tshort))
                    tshort))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _val4 (tptr (Tstruct _UnusedArea28 noattr)))
                      (Tstruct _UnusedArea28 noattr)) _unk02 tshort)
                  (Etempvar _t'15 tshort))))
            (Ssequence
              (Ssequence
                (Sset _t'12
                  (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                (Ssequence
                  (Sset _t'13
                    (Ederef
                      (Ecast
                        (Ebinop Oadd
                          (Ebinop Oor
                            (Ebinop Oand (Econst_int (Int.repr 6) tint)
                              (Econst_int (Int.repr 3) tint) tint)
                            (Ebinop Oshl
                              (Ebinop Oand (Econst_int (Int.repr 6) tint)
                                (Eunop Onotint (Econst_int (Int.repr 3) tint)
                                  tint) tint)
                              (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                (Econst_int (Int.repr 3) tint) tuint) tint)
                            tint)
                          (Ecast
                            (Etempvar _t'12 (tptr (Tstruct _LevelCommand noattr)))
                            (tptr tuchar)) (tptr tuchar)) (tptr tshort))
                      tshort))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _val4 (tptr (Tstruct _UnusedArea28 noattr)))
                        (Tstruct _UnusedArea28 noattr)) _unk04 tshort)
                    (Etempvar _t'13 tshort))))
              (Ssequence
                (Ssequence
                  (Sset _t'10
                    (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                  (Ssequence
                    (Sset _t'11
                      (Ederef
                        (Ecast
                          (Ebinop Oadd
                            (Ebinop Oor
                              (Ebinop Oand (Econst_int (Int.repr 8) tint)
                                (Econst_int (Int.repr 3) tint) tint)
                              (Ebinop Oshl
                                (Ebinop Oand (Econst_int (Int.repr 8) tint)
                                  (Eunop Onotint
                                    (Econst_int (Int.repr 3) tint) tint)
                                  tint)
                                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                  (Econst_int (Int.repr 3) tint) tuint) tint)
                              tint)
                            (Ecast
                              (Etempvar _t'10 (tptr (Tstruct _LevelCommand noattr)))
                              (tptr tuchar)) (tptr tuchar)) (tptr tshort))
                        tshort))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _val4 (tptr (Tstruct _UnusedArea28 noattr)))
                          (Tstruct _UnusedArea28 noattr)) _unk06 tshort)
                      (Etempvar _t'11 tshort))))
                (Ssequence
                  (Sset _t'8
                    (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                  (Ssequence
                    (Sset _t'9
                      (Ederef
                        (Ecast
                          (Ebinop Oadd
                            (Ebinop Oor
                              (Ebinop Oand (Econst_int (Int.repr 10) tint)
                                (Econst_int (Int.repr 3) tint) tint)
                              (Ebinop Oshl
                                (Ebinop Oand (Econst_int (Int.repr 10) tint)
                                  (Eunop Onotint
                                    (Econst_int (Int.repr 3) tint) tint)
                                  tint)
                                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                  (Econst_int (Int.repr 3) tint) tuint) tint)
                              tint)
                            (Ecast
                              (Etempvar _t'8 (tptr (Tstruct _LevelCommand noattr)))
                              (tptr tuchar)) (tptr tuchar)) (tptr tshort))
                        tshort))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _val4 (tptr (Tstruct _UnusedArea28 noattr)))
                          (Tstruct _UnusedArea28 noattr)) _unk08 tshort)
                      (Etempvar _t'9 tshort)))))))))
      Sskip))
  (Ssequence
    (Sset _t'4 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'5 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _t'5 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'6 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_create_whirlpool := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_whirlpool, (tptr (Tstruct _Whirlpool noattr))) ::
               (_index, tint) :: (_beatBowser2, tint) :: (_t'7, tint) ::
               (_t'6, tint) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, (tptr (Tstruct _Whirlpool noattr))) ::
               (_t'2, (tptr tvoid)) :: (_t'1, tuint) ::
               (_t'35, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'34, tuchar) ::
               (_t'33, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'32, tuchar) ::
               (_t'31, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'30, tuchar) ::
               (_t'29, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'28, tshort) :: (_t'27, tuchar) ::
               (_t'26, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'25, tshort) ::
               (_t'24, (tptr (Tstruct _Whirlpool noattr))) ::
               (_t'23, tshort) :: (_t'22, (tptr (Tstruct _Area noattr))) ::
               (_t'21, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'20, tshort) :: (_t'19, (tptr (Tstruct _Area noattr))) ::
               (_t'18, tshort) ::
               (_t'17, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'16, tshort) ::
               (_t'15, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'14, tshort) ::
               (_t'13, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'12, tshort) ::
               (_t'11, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'10, tuchar) ::
               (_t'9, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'8, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'35 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Sset _index
      (Ederef
        (Ecast
          (Ebinop Oadd
            (Ebinop Oor
              (Ebinop Oand (Econst_int (Int.repr 2) tint)
                (Econst_int (Int.repr 3) tint) tint)
              (Ebinop Oshl
                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                  (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) tint)
            (Ecast (Etempvar _t'35 (tptr (Tstruct _LevelCommand noattr)))
              (tptr tuchar)) (tptr tuchar)) (tptr tuchar)) tuchar)))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _save_file_get_flags (Tfunction nil tuint cc_default)) nil)
      (Sset _beatBowser2
        (Ebinop One
          (Ebinop Oand (Etempvar _t'1 tuint)
            (Ebinop Oor
              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 5) tint) tint)
              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 7) tint) tint) tint) tuint)
          (Econst_int (Int.repr 0) tint) tint)))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'31
                (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
              (Ssequence
                (Sset _t'32
                  (Ederef
                    (Ecast
                      (Ebinop Oadd
                        (Ebinop Oor
                          (Ebinop Oand (Econst_int (Int.repr 3) tint)
                            (Econst_int (Int.repr 3) tint) tint)
                          (Ebinop Oshl
                            (Ebinop Oand (Econst_int (Int.repr 3) tint)
                              (Eunop Onotint (Econst_int (Int.repr 3) tint)
                                tint) tint)
                            (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                              (Econst_int (Int.repr 3) tint) tuint) tint)
                          tint)
                        (Ecast
                          (Etempvar _t'31 (tptr (Tstruct _LevelCommand noattr)))
                          (tptr tuchar)) (tptr tuchar)) (tptr tuchar))
                    tuchar))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'32 tuchar)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Sset _t'5 (Econst_int (Int.repr 1) tint))
                  (Ssequence
                    (Sset _t'33
                      (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                    (Ssequence
                      (Sset _t'34
                        (Ederef
                          (Ecast
                            (Ebinop Oadd
                              (Ebinop Oor
                                (Ebinop Oand (Econst_int (Int.repr 3) tint)
                                  (Econst_int (Int.repr 3) tint) tint)
                                (Ebinop Oshl
                                  (Ebinop Oand (Econst_int (Int.repr 3) tint)
                                    (Eunop Onotint
                                      (Econst_int (Int.repr 3) tint) tint)
                                    tint)
                                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                    (Econst_int (Int.repr 3) tint) tuint)
                                  tint) tint)
                              (Ecast
                                (Etempvar _t'33 (tptr (Tstruct _LevelCommand noattr)))
                                (tptr tuchar)) (tptr tuchar)) (tptr tuchar))
                          tuchar))
                      (Sifthenelse (Ebinop Oeq (Etempvar _t'34 tuchar)
                                     (Econst_int (Int.repr 1) tint) tint)
                        (Ssequence
                          (Sset _t'5
                            (Ecast
                              (Eunop Onotbool (Etempvar _beatBowser2 tint)
                                tint) tbool))
                          (Sset _t'5 (Ecast (Etempvar _t'5 tint) tbool)))
                        (Sset _t'5
                          (Ecast (Econst_int (Int.repr 0) tint) tbool))))))))
            (Sifthenelse (Etempvar _t'5 tint)
              (Sset _t'6 (Econst_int (Int.repr 1) tint))
              (Ssequence
                (Sset _t'29
                  (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                (Ssequence
                  (Sset _t'30
                    (Ederef
                      (Ecast
                        (Ebinop Oadd
                          (Ebinop Oor
                            (Ebinop Oand (Econst_int (Int.repr 3) tint)
                              (Econst_int (Int.repr 3) tint) tint)
                            (Ebinop Oshl
                              (Ebinop Oand (Econst_int (Int.repr 3) tint)
                                (Eunop Onotint (Econst_int (Int.repr 3) tint)
                                  tint) tint)
                              (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                (Econst_int (Int.repr 3) tint) tuint) tint)
                            tint)
                          (Ecast
                            (Etempvar _t'29 (tptr (Tstruct _LevelCommand noattr)))
                            (tptr tuchar)) (tptr tuchar)) (tptr tuchar))
                      tuchar))
                  (Sifthenelse (Ebinop Oeq (Etempvar _t'30 tuchar)
                                 (Econst_int (Int.repr 2) tint) tint)
                    (Ssequence
                      (Sset _t'6 (Ecast (Etempvar _beatBowser2 tint) tbool))
                      (Sset _t'6 (Ecast (Etempvar _t'6 tint) tbool)))
                    (Sset _t'6 (Ecast (Econst_int (Int.repr 0) tint) tbool)))))))
          (Sifthenelse (Etempvar _t'6 tint)
            (Sset _t'7 (Econst_int (Int.repr 1) tint))
            (Ssequence
              (Sset _t'26
                (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
              (Ssequence
                (Sset _t'27
                  (Ederef
                    (Ecast
                      (Ebinop Oadd
                        (Ebinop Oor
                          (Ebinop Oand (Econst_int (Int.repr 3) tint)
                            (Econst_int (Int.repr 3) tint) tint)
                          (Ebinop Oshl
                            (Ebinop Oand (Econst_int (Int.repr 3) tint)
                              (Eunop Onotint (Econst_int (Int.repr 3) tint)
                                tint) tint)
                            (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                              (Econst_int (Int.repr 3) tint) tuint) tint)
                          tint)
                        (Ecast
                          (Etempvar _t'26 (tptr (Tstruct _LevelCommand noattr)))
                          (tptr tuchar)) (tptr tuchar)) (tptr tuchar))
                    tuchar))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'27 tuchar)
                               (Econst_int (Int.repr 3) tint) tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'28 (Evar _gCurrActNum tshort))
                      (Sset _t'7
                        (Ecast
                          (Ebinop Oge (Etempvar _t'28 tshort)
                            (Econst_int (Int.repr 2) tint) tint) tbool)))
                    (Sset _t'7 (Ecast (Etempvar _t'7 tint) tbool)))
                  (Sset _t'7 (Ecast (Econst_int (Int.repr 0) tint) tbool)))))))
        (Sifthenelse (Etempvar _t'7 tint)
          (Ssequence
            (Ssequence
              (Sset _t'25 (Evar _sCurrAreaIndex tshort))
              (Sifthenelse (Ebinop One (Etempvar _t'25 tshort)
                             (Eunop Oneg (Econst_int (Int.repr 1) tint) tint)
                             tint)
                (Sset _t'4
                  (Ecast
                    (Ebinop Olt (Etempvar _index tint)
                      (Econst_int (Int.repr 2) tint) tint) tbool))
                (Sset _t'4 (Econst_int (Int.repr 0) tint))))
            (Sifthenelse (Etempvar _t'4 tint)
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'22
                        (Evar _gAreas (tptr (Tstruct _Area noattr))))
                      (Ssequence
                        (Sset _t'23 (Evar _sCurrAreaIndex tshort))
                        (Ssequence
                          (Sset _t'24
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'22 (tptr (Tstruct _Area noattr)))
                                      (Etempvar _t'23 tshort)
                                      (tptr (Tstruct _Area noattr)))
                                    (Tstruct _Area noattr)) _whirlpools
                                  (tarray (tptr (Tstruct _Whirlpool noattr)) 2))
                                (Etempvar _index tint)
                                (tptr (tptr (Tstruct _Whirlpool noattr))))
                              (tptr (Tstruct _Whirlpool noattr))))
                          (Sset _t'3
                            (Ecast
                              (Etempvar _t'24 (tptr (Tstruct _Whirlpool noattr)))
                              (tptr (Tstruct _Whirlpool noattr)))))))
                    (Sset _whirlpool
                      (Etempvar _t'3 (tptr (Tstruct _Whirlpool noattr)))))
                  (Sifthenelse (Ebinop Oeq
                                 (Etempvar _t'3 (tptr (Tstruct _Whirlpool noattr)))
                                 (Ecast (Econst_int (Int.repr 0) tint)
                                   (tptr tvoid)) tint)
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'21
                            (Evar _sLevelPool (tptr (Tstruct _AllocOnlyPool noattr))))
                          (Scall (Some _t'2)
                            (Evar _alloc_only_pool_alloc (Tfunction
                                                           ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                            tint :: nil)
                                                           (tptr tvoid)
                                                           cc_default))
                            ((Etempvar _t'21 (tptr (Tstruct _AllocOnlyPool noattr))) ::
                             (Esizeof (Tstruct _Whirlpool noattr) tuint) ::
                             nil)))
                        (Sset _whirlpool (Etempvar _t'2 (tptr tvoid))))
                      (Ssequence
                        (Sset _t'19
                          (Evar _gAreas (tptr (Tstruct _Area noattr))))
                        (Ssequence
                          (Sset _t'20 (Evar _sCurrAreaIndex tshort))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'19 (tptr (Tstruct _Area noattr)))
                                      (Etempvar _t'20 tshort)
                                      (tptr (Tstruct _Area noattr)))
                                    (Tstruct _Area noattr)) _whirlpools
                                  (tarray (tptr (Tstruct _Whirlpool noattr)) 2))
                                (Etempvar _index tint)
                                (tptr (tptr (Tstruct _Whirlpool noattr))))
                              (tptr (Tstruct _Whirlpool noattr)))
                            (Etempvar _whirlpool (tptr (Tstruct _Whirlpool noattr)))))))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sset _t'13
                      (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                    (Ssequence
                      (Sset _t'14
                        (Ederef
                          (Ecast
                            (Ebinop Oadd
                              (Ebinop Oor
                                (Ebinop Oand (Econst_int (Int.repr 4) tint)
                                  (Econst_int (Int.repr 3) tint) tint)
                                (Ebinop Oshl
                                  (Ebinop Oand (Econst_int (Int.repr 4) tint)
                                    (Eunop Onotint
                                      (Econst_int (Int.repr 3) tint) tint)
                                    tint)
                                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                    (Econst_int (Int.repr 3) tint) tuint)
                                  tint) tint)
                              (Ecast
                                (Etempvar _t'13 (tptr (Tstruct _LevelCommand noattr)))
                                (tptr tuchar)) (tptr tuchar)) (tptr tshort))
                          tshort))
                      (Ssequence
                        (Sset _t'15
                          (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                        (Ssequence
                          (Sset _t'16
                            (Ederef
                              (Ecast
                                (Ebinop Oadd
                                  (Ebinop Oor
                                    (Ebinop Oand
                                      (Econst_int (Int.repr 6) tint)
                                      (Econst_int (Int.repr 3) tint) tint)
                                    (Ebinop Oshl
                                      (Ebinop Oand
                                        (Econst_int (Int.repr 6) tint)
                                        (Eunop Onotint
                                          (Econst_int (Int.repr 3) tint)
                                          tint) tint)
                                      (Ebinop Oshr
                                        (Esizeof (tptr tvoid) tuint)
                                        (Econst_int (Int.repr 3) tint) tuint)
                                      tint) tint)
                                  (Ecast
                                    (Etempvar _t'15 (tptr (Tstruct _LevelCommand noattr)))
                                    (tptr tuchar)) (tptr tuchar))
                                (tptr tshort)) tshort))
                          (Ssequence
                            (Sset _t'17
                              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                            (Ssequence
                              (Sset _t'18
                                (Ederef
                                  (Ecast
                                    (Ebinop Oadd
                                      (Ebinop Oor
                                        (Ebinop Oand
                                          (Econst_int (Int.repr 8) tint)
                                          (Econst_int (Int.repr 3) tint)
                                          tint)
                                        (Ebinop Oshl
                                          (Ebinop Oand
                                            (Econst_int (Int.repr 8) tint)
                                            (Eunop Onotint
                                              (Econst_int (Int.repr 3) tint)
                                              tint) tint)
                                          (Ebinop Oshr
                                            (Esizeof (tptr tvoid) tuint)
                                            (Econst_int (Int.repr 3) tint)
                                            tuint) tint) tint)
                                      (Ecast
                                        (Etempvar _t'17 (tptr (Tstruct _LevelCommand noattr)))
                                        (tptr tuchar)) (tptr tuchar))
                                    (tptr tshort)) tshort))
                              (Scall None
                                (Evar _vec3s_set (Tfunction
                                                   ((tptr tshort) ::
                                                    tshort :: tshort ::
                                                    tshort :: nil)
                                                   (tptr tvoid) cc_default))
                                ((Efield
                                   (Ederef
                                     (Etempvar _whirlpool (tptr (Tstruct _Whirlpool noattr)))
                                     (Tstruct _Whirlpool noattr)) _pos
                                   (tarray tshort 3)) ::
                                 (Etempvar _t'14 tshort) ::
                                 (Etempvar _t'16 tshort) ::
                                 (Etempvar _t'18 tshort) :: nil))))))))
                  (Ssequence
                    (Sset _t'11
                      (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                    (Ssequence
                      (Sset _t'12
                        (Ederef
                          (Ecast
                            (Ebinop Oadd
                              (Ebinop Oor
                                (Ebinop Oand (Econst_int (Int.repr 10) tint)
                                  (Econst_int (Int.repr 3) tint) tint)
                                (Ebinop Oshl
                                  (Ebinop Oand
                                    (Econst_int (Int.repr 10) tint)
                                    (Eunop Onotint
                                      (Econst_int (Int.repr 3) tint) tint)
                                    tint)
                                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                    (Econst_int (Int.repr 3) tint) tuint)
                                  tint) tint)
                              (Ecast
                                (Etempvar _t'11 (tptr (Tstruct _LevelCommand noattr)))
                                (tptr tuchar)) (tptr tuchar)) (tptr tshort))
                          tshort))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _whirlpool (tptr (Tstruct _Whirlpool noattr)))
                            (Tstruct _Whirlpool noattr)) _strength tshort)
                        (Etempvar _t'12 tshort))))))
              Sskip))
          Sskip))
      (Ssequence
        (Sset _t'8 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'9
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'10
              (Efield
                (Ederef (Etempvar _t'9 (tptr (Tstruct _LevelCommand noattr)))
                  (Tstruct _LevelCommand noattr)) _size tuchar))
            (Sassign
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
              (Ecast
                (Ebinop Oadd
                  (Ecast
                    (Etempvar _t'8 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar))
                  (Ebinop Oshl (Etempvar _t'10 tuchar)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint)
                  (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr))))))))))
|}.

Definition f_level_cmd_set_blackout := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'5, tuchar) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'5
        (Ederef
          (Ecast
            (Ebinop Oadd
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (Ecast (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar)) (tptr tuchar)) (tptr tuchar)) tuchar))
      (Scall None
        (Evar _osViBlack (Tfunction (tuchar :: nil) tvoid cc_default))
        ((Etempvar _t'5 tuchar) :: nil))))
  (Ssequence
    (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'3 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_set_gamma := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'6, tuchar) ::
               (_t'5, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'4, tuchar) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'5 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'6
          (Ederef
            (Ecast
              (Ebinop Oadd
                (Ebinop Oor
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Econst_int (Int.repr 3) tint) tint)
                  (Ebinop Oshl
                    (Ebinop Oand (Econst_int (Int.repr 2) tint)
                      (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                      tint)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                (Ecast (Etempvar _t'5 (tptr (Tstruct _LevelCommand noattr)))
                  (tptr tuchar)) (tptr tuchar)) (tptr tuchar)) tuchar))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'6 tuchar)
                       (Econst_int (Int.repr 0) tint) tint)
          (Sset _t'1 (Ecast (Econst_int (Int.repr 2) tint) tint))
          (Sset _t'1 (Ecast (Econst_int (Int.repr 1) tint) tint)))))
    (Scall None
      (Evar _osViSetSpecialFeatures (Tfunction (tuint :: nil) tvoid
                                      cc_default))
      ((Etempvar _t'1 tint) :: nil)))
  (Ssequence
    (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'3 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'4 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_set_terrain_data := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: (_t'9, (tptr tvoid)) ::
               (_t'8, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'7, tshort) :: (_t'6, (tptr (Tstruct _Area noattr))) ::
               (_t'5, tshort) :: (_t'4, tuchar) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5 (Evar _sCurrAreaIndex tshort))
    (Sifthenelse (Ebinop One (Etempvar _t'5 tshort)
                   (Eunop Oneg (Econst_int (Int.repr 1) tint) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'8
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'9
              (Ederef
                (Ecast
                  (Ebinop Oadd
                    (Ebinop Oor
                      (Ebinop Oand (Econst_int (Int.repr 4) tint)
                        (Econst_int (Int.repr 3) tint) tint)
                      (Ebinop Oshl
                        (Ebinop Oand (Econst_int (Int.repr 4) tint)
                          (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                          tint)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                    (Ecast
                      (Etempvar _t'8 (tptr (Tstruct _LevelCommand noattr)))
                      (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
                (tptr tvoid)))
            (Scall (Some _t'1)
              (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                            (tptr tvoid) cc_default))
              ((Etempvar _t'9 (tptr tvoid)) :: nil))))
        (Ssequence
          (Sset _t'6 (Evar _gAreas (tptr (Tstruct _Area noattr))))
          (Ssequence
            (Sset _t'7 (Evar _sCurrAreaIndex tshort))
            (Sassign
              (Efield
                (Ederef
                  (Ebinop Oadd (Etempvar _t'6 (tptr (Tstruct _Area noattr)))
                    (Etempvar _t'7 tshort) (tptr (Tstruct _Area noattr)))
                  (Tstruct _Area noattr)) _terrainData (tptr tshort))
              (Etempvar _t'1 (tptr tvoid))))))
      Sskip))
  (Ssequence
    (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'3 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'4 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_set_rooms := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: (_t'9, (tptr tvoid)) ::
               (_t'8, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'7, tshort) :: (_t'6, (tptr (Tstruct _Area noattr))) ::
               (_t'5, tshort) :: (_t'4, tuchar) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5 (Evar _sCurrAreaIndex tshort))
    (Sifthenelse (Ebinop One (Etempvar _t'5 tshort)
                   (Eunop Oneg (Econst_int (Int.repr 1) tint) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'8
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'9
              (Ederef
                (Ecast
                  (Ebinop Oadd
                    (Ebinop Oor
                      (Ebinop Oand (Econst_int (Int.repr 4) tint)
                        (Econst_int (Int.repr 3) tint) tint)
                      (Ebinop Oshl
                        (Ebinop Oand (Econst_int (Int.repr 4) tint)
                          (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                          tint)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                    (Ecast
                      (Etempvar _t'8 (tptr (Tstruct _LevelCommand noattr)))
                      (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
                (tptr tvoid)))
            (Scall (Some _t'1)
              (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                            (tptr tvoid) cc_default))
              ((Etempvar _t'9 (tptr tvoid)) :: nil))))
        (Ssequence
          (Sset _t'6 (Evar _gAreas (tptr (Tstruct _Area noattr))))
          (Ssequence
            (Sset _t'7 (Evar _sCurrAreaIndex tshort))
            (Sassign
              (Efield
                (Ederef
                  (Ebinop Oadd (Etempvar _t'6 (tptr (Tstruct _Area noattr)))
                    (Etempvar _t'7 tshort) (tptr (Tstruct _Area noattr)))
                  (Tstruct _Area noattr)) _surfaceRooms (tptr tschar))
              (Etempvar _t'1 (tptr tvoid))))))
      Sskip))
  (Ssequence
    (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'3 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'4 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_set_macro_objects := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: (_t'9, (tptr tvoid)) ::
               (_t'8, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'7, tshort) :: (_t'6, (tptr (Tstruct _Area noattr))) ::
               (_t'5, tshort) :: (_t'4, tuchar) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5 (Evar _sCurrAreaIndex tshort))
    (Sifthenelse (Ebinop One (Etempvar _t'5 tshort)
                   (Eunop Oneg (Econst_int (Int.repr 1) tint) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'8
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'9
              (Ederef
                (Ecast
                  (Ebinop Oadd
                    (Ebinop Oor
                      (Ebinop Oand (Econst_int (Int.repr 4) tint)
                        (Econst_int (Int.repr 3) tint) tint)
                      (Ebinop Oshl
                        (Ebinop Oand (Econst_int (Int.repr 4) tint)
                          (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                          tint)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                    (Ecast
                      (Etempvar _t'8 (tptr (Tstruct _LevelCommand noattr)))
                      (tptr tuchar)) (tptr tuchar)) (tptr (tptr tvoid)))
                (tptr tvoid)))
            (Scall (Some _t'1)
              (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                            (tptr tvoid) cc_default))
              ((Etempvar _t'9 (tptr tvoid)) :: nil))))
        (Ssequence
          (Sset _t'6 (Evar _gAreas (tptr (Tstruct _Area noattr))))
          (Ssequence
            (Sset _t'7 (Evar _sCurrAreaIndex tshort))
            (Sassign
              (Efield
                (Ederef
                  (Ebinop Oadd (Etempvar _t'6 (tptr (Tstruct _Area noattr)))
                    (Etempvar _t'7 tshort) (tptr (Tstruct _Area noattr)))
                  (Tstruct _Area noattr)) _macroObjects (tptr tshort))
              (Etempvar _t'1 (tptr tvoid))))))
      Sskip))
  (Ssequence
    (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'3 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'4 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_load_area := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_areaIndex, tshort) :: (_unused, (tptr tvoid)) ::
               (_t'6, tuchar) ::
               (_t'5, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'6
        (Ederef
          (Ecast
            (Ebinop Oadd
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (Ecast (Etempvar _t'5 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar)) (tptr tuchar)) (tptr tuchar)) tuchar))
      (Sset _areaIndex (Ecast (Etempvar _t'6 tuchar) tshort))))
  (Ssequence
    (Ssequence
      (Sset _t'4 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Sset _unused
        (Ebinop Oadd
          (Ecast (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
            (tptr tuchar)) (Econst_int (Int.repr 4) tint) (tptr tuchar))))
    (Ssequence
      (Scall None
        (Evar _stop_sounds_in_continuous_banks (Tfunction nil tvoid
                                                 cc_default)) nil)
      (Ssequence
        (Scall None
          (Evar _load_area (Tfunction (tint :: nil) tvoid cc_default))
          ((Etempvar _areaIndex tshort) :: nil))
        (Ssequence
          (Sset _t'1
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'2
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
            (Ssequence
              (Sset _t'3
                (Efield
                  (Ederef
                    (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
                    (Tstruct _LevelCommand noattr)) _size tuchar))
              (Sassign
                (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
                (Ecast
                  (Ebinop Oadd
                    (Ecast
                      (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                      (tptr tuchar))
                    (Ebinop Oshl (Etempvar _t'3 tuchar)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint)
                    (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr)))))))))))
|}.

Definition f_level_cmd_unload_area := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Scall None (Evar _unload_area (Tfunction nil tvoid cc_default)) nil)
  (Ssequence
    (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'3 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_set_mario_start_pos := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'11, tuchar) ::
               (_t'10, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'9, (tptr (Tstruct _SpawnInfo noattr))) ::
               (_t'8, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'7, (tptr (Tstruct _SpawnInfo noattr))) ::
               (_t'6, tshort) ::
               (_t'5, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'4, (tptr (Tstruct _SpawnInfo noattr))) ::
               (_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9 (Evar _gMarioSpawnInfo (tptr (Tstruct _SpawnInfo noattr))))
    (Ssequence
      (Sset _t'10 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'11
          (Ederef
            (Ecast
              (Ebinop Oadd
                (Ebinop Oor
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Econst_int (Int.repr 3) tint) tint)
                  (Ebinop Oshl
                    (Ebinop Oand (Econst_int (Int.repr 2) tint)
                      (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                      tint)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                (Ecast (Etempvar _t'10 (tptr (Tstruct _LevelCommand noattr)))
                  (tptr tuchar)) (tptr tuchar)) (tptr tuchar)) tuchar))
        (Sassign
          (Efield
            (Ederef (Etempvar _t'9 (tptr (Tstruct _SpawnInfo noattr)))
              (Tstruct _SpawnInfo noattr)) _areaIndex tschar)
          (Etempvar _t'11 tuchar)))))
  (Ssequence
    (Ssequence
      (Sset _t'7 (Evar _gMarioSpawnInfo (tptr (Tstruct _SpawnInfo noattr))))
      (Ssequence
        (Sset _t'8 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Scall None
          (Evar _vec3s_copy (Tfunction
                              ((tptr tshort) :: (tptr tshort) :: nil)
                              (tptr tvoid) cc_default))
          ((Efield
             (Ederef (Etempvar _t'7 (tptr (Tstruct _SpawnInfo noattr)))
               (Tstruct _SpawnInfo noattr)) _startPos (tarray tshort 3)) ::
           (Ederef
             (Ecast
               (Ebinop Oadd
                 (Ebinop Oor
                   (Ebinop Oand (Econst_int (Int.repr 6) tint)
                     (Econst_int (Int.repr 3) tint) tint)
                   (Ebinop Oshl
                     (Ebinop Oand (Econst_int (Int.repr 6) tint)
                       (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                       tint)
                     (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                       (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                 (Ecast (Etempvar _t'8 (tptr (Tstruct _LevelCommand noattr)))
                   (tptr tuchar)) (tptr tuchar)) (tptr (tarray tshort 3)))
             (tarray tshort 3)) :: nil))))
    (Ssequence
      (Ssequence
        (Sset _t'4
          (Evar _gMarioSpawnInfo (tptr (Tstruct _SpawnInfo noattr))))
        (Ssequence
          (Sset _t'5
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'6
              (Ederef
                (Ecast
                  (Ebinop Oadd
                    (Ebinop Oor
                      (Ebinop Oand (Econst_int (Int.repr 4) tint)
                        (Econst_int (Int.repr 3) tint) tint)
                      (Ebinop Oshl
                        (Ebinop Oand (Econst_int (Int.repr 4) tint)
                          (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                          tint)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                    (Ecast
                      (Etempvar _t'5 (tptr (Tstruct _LevelCommand noattr)))
                      (tptr tuchar)) (tptr tuchar)) (tptr tshort)) tshort))
            (Scall None
              (Evar _vec3s_set (Tfunction
                                 ((tptr tshort) :: tshort :: tshort ::
                                  tshort :: nil) (tptr tvoid) cc_default))
              ((Efield
                 (Ederef (Etempvar _t'4 (tptr (Tstruct _SpawnInfo noattr)))
                   (Tstruct _SpawnInfo noattr)) _startAngle
                 (tarray tshort 3)) :: (Econst_int (Int.repr 0) tint) ::
               (Ebinop Odiv
                 (Ebinop Omul (Etempvar _t'6 tshort)
                   (Econst_int (Int.repr 32768) tint) tint)
                 (Econst_int (Int.repr 180) tint) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil)))))
      (Ssequence
        (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'2
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'3
              (Efield
                (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
                  (Tstruct _LevelCommand noattr)) _size tuchar))
            (Sassign
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
              (Ecast
                (Ebinop Oadd
                  (Ecast
                    (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar))
                  (Ebinop Oshl (Etempvar _t'3 tuchar)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint)
                  (tptr tuchar)) (tptr (Tstruct _LevelCommand noattr))))))))))
|}.

Definition f_level_cmd_2C := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Scall None (Evar _unload_mario_area (Tfunction nil tvoid cc_default)) nil)
  (Ssequence
    (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'3 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_2D := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Scall None (Evar _area_update_objects (Tfunction nil tvoid cc_default))
    nil)
  (Ssequence
    (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'3 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_set_transition := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'14, tuchar) ::
               (_t'13, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'12, tuchar) ::
               (_t'11, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'10, tuchar) ::
               (_t'9, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'8, tuchar) ::
               (_t'7, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'6, tuchar) ::
               (_t'5, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'4, (tptr (Tstruct _Area noattr))) :: (_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
    (Sifthenelse (Ebinop One (Etempvar _t'4 (tptr (Tstruct _Area noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Sset _t'5 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'6
            (Ederef
              (Ecast
                (Ebinop Oadd
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 2) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 2) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (Ecast
                    (Etempvar _t'5 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar)) (tptr tuchar)) (tptr tuchar)) tuchar))
          (Ssequence
            (Sset _t'7
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
            (Ssequence
              (Sset _t'8
                (Ederef
                  (Ecast
                    (Ebinop Oadd
                      (Ebinop Oor
                        (Ebinop Oand (Econst_int (Int.repr 3) tint)
                          (Econst_int (Int.repr 3) tint) tint)
                        (Ebinop Oshl
                          (Ebinop Oand (Econst_int (Int.repr 3) tint)
                            (Eunop Onotint (Econst_int (Int.repr 3) tint)
                              tint) tint)
                          (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                            (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                      (Ecast
                        (Etempvar _t'7 (tptr (Tstruct _LevelCommand noattr)))
                        (tptr tuchar)) (tptr tuchar)) (tptr tuchar)) tuchar))
              (Ssequence
                (Sset _t'9
                  (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                (Ssequence
                  (Sset _t'10
                    (Ederef
                      (Ecast
                        (Ebinop Oadd
                          (Ebinop Oor
                            (Ebinop Oand (Econst_int (Int.repr 4) tint)
                              (Econst_int (Int.repr 3) tint) tint)
                            (Ebinop Oshl
                              (Ebinop Oand (Econst_int (Int.repr 4) tint)
                                (Eunop Onotint (Econst_int (Int.repr 3) tint)
                                  tint) tint)
                              (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                (Econst_int (Int.repr 3) tint) tuint) tint)
                            tint)
                          (Ecast
                            (Etempvar _t'9 (tptr (Tstruct _LevelCommand noattr)))
                            (tptr tuchar)) (tptr tuchar)) (tptr tuchar))
                      tuchar))
                  (Ssequence
                    (Sset _t'11
                      (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                    (Ssequence
                      (Sset _t'12
                        (Ederef
                          (Ecast
                            (Ebinop Oadd
                              (Ebinop Oor
                                (Ebinop Oand (Econst_int (Int.repr 5) tint)
                                  (Econst_int (Int.repr 3) tint) tint)
                                (Ebinop Oshl
                                  (Ebinop Oand (Econst_int (Int.repr 5) tint)
                                    (Eunop Onotint
                                      (Econst_int (Int.repr 3) tint) tint)
                                    tint)
                                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                    (Econst_int (Int.repr 3) tint) tuint)
                                  tint) tint)
                              (Ecast
                                (Etempvar _t'11 (tptr (Tstruct _LevelCommand noattr)))
                                (tptr tuchar)) (tptr tuchar)) (tptr tuchar))
                          tuchar))
                      (Ssequence
                        (Sset _t'13
                          (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                        (Ssequence
                          (Sset _t'14
                            (Ederef
                              (Ecast
                                (Ebinop Oadd
                                  (Ebinop Oor
                                    (Ebinop Oand
                                      (Econst_int (Int.repr 6) tint)
                                      (Econst_int (Int.repr 3) tint) tint)
                                    (Ebinop Oshl
                                      (Ebinop Oand
                                        (Econst_int (Int.repr 6) tint)
                                        (Eunop Onotint
                                          (Econst_int (Int.repr 3) tint)
                                          tint) tint)
                                      (Ebinop Oshr
                                        (Esizeof (tptr tvoid) tuint)
                                        (Econst_int (Int.repr 3) tint) tuint)
                                      tint) tint)
                                  (Ecast
                                    (Etempvar _t'13 (tptr (Tstruct _LevelCommand noattr)))
                                    (tptr tuchar)) (tptr tuchar))
                                (tptr tuchar)) tuchar))
                          (Scall None
                            (Evar _play_transition (Tfunction
                                                     (tshort :: tshort ::
                                                      tuchar :: tuchar ::
                                                      tuchar :: nil) tvoid
                                                     cc_default))
                            ((Etempvar _t'6 tuchar) ::
                             (Etempvar _t'8 tuchar) ::
                             (Etempvar _t'10 tuchar) ::
                             (Etempvar _t'12 tuchar) ::
                             (Etempvar _t'14 tuchar) :: nil))))))))))))
      Sskip))
  (Ssequence
    (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'3 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_nop := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
  (Ssequence
    (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
            (Tstruct _LevelCommand noattr)) _size tuchar))
      (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
        (Ecast
          (Ebinop Oadd
            (Ecast (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
              (tptr tuchar))
            (Ebinop Oshl (Etempvar _t'3 tuchar)
              (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
          (tptr (Tstruct _LevelCommand noattr)))))))
|}.

Definition f_level_cmd_show_dialog := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'12, tuchar) ::
               (_t'11, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'10, tuchar) ::
               (_t'9, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'8, tshort) :: (_t'7, (tptr (Tstruct _Area noattr))) ::
               (_t'6, tuchar) ::
               (_t'5, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'4, tshort) :: (_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _sCurrAreaIndex tshort))
    (Sifthenelse (Ebinop One (Etempvar _t'4 tshort)
                   (Eunop Oneg (Econst_int (Int.repr 1) tint) tint) tint)
      (Ssequence
        (Sset _t'5 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
        (Ssequence
          (Sset _t'6
            (Ederef
              (Ecast
                (Ebinop Oadd
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 2) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 2) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (Ecast
                    (Etempvar _t'5 (tptr (Tstruct _LevelCommand noattr)))
                    (tptr tuchar)) (tptr tuchar)) (tptr tuchar)) tuchar))
          (Sifthenelse (Ebinop Olt (Etempvar _t'6 tuchar)
                         (Econst_int (Int.repr 2) tint) tint)
            (Ssequence
              (Sset _t'7 (Evar _gAreas (tptr (Tstruct _Area noattr))))
              (Ssequence
                (Sset _t'8 (Evar _sCurrAreaIndex tshort))
                (Ssequence
                  (Sset _t'9
                    (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                  (Ssequence
                    (Sset _t'10
                      (Ederef
                        (Ecast
                          (Ebinop Oadd
                            (Ebinop Oor
                              (Ebinop Oand (Econst_int (Int.repr 2) tint)
                                (Econst_int (Int.repr 3) tint) tint)
                              (Ebinop Oshl
                                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                                  (Eunop Onotint
                                    (Econst_int (Int.repr 3) tint) tint)
                                  tint)
                                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                  (Econst_int (Int.repr 3) tint) tuint) tint)
                              tint)
                            (Ecast
                              (Etempvar _t'9 (tptr (Tstruct _LevelCommand noattr)))
                              (tptr tuchar)) (tptr tuchar)) (tptr tuchar))
                        tuchar))
                    (Ssequence
                      (Sset _t'11
                        (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                      (Ssequence
                        (Sset _t'12
                          (Ederef
                            (Ecast
                              (Ebinop Oadd
                                (Ebinop Oor
                                  (Ebinop Oand (Econst_int (Int.repr 3) tint)
                                    (Econst_int (Int.repr 3) tint) tint)
                                  (Ebinop Oshl
                                    (Ebinop Oand
                                      (Econst_int (Int.repr 3) tint)
                                      (Eunop Onotint
                                        (Econst_int (Int.repr 3) tint) tint)
                                      tint)
                                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                      (Econst_int (Int.repr 3) tint) tuint)
                                    tint) tint)
                                (Ecast
                                  (Etempvar _t'11 (tptr (Tstruct _LevelCommand noattr)))
                                  (tptr tuchar)) (tptr tuchar))
                              (tptr tuchar)) tuchar))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Ebinop Oadd
                                    (Etempvar _t'7 (tptr (Tstruct _Area noattr)))
                                    (Etempvar _t'8 tshort)
                                    (tptr (Tstruct _Area noattr)))
                                  (Tstruct _Area noattr)) _dialog
                                (tarray tuchar 2)) (Etempvar _t'10 tuchar)
                              (tptr tuchar)) tuchar) (Etempvar _t'12 tuchar))))))))
            Sskip)))
      Sskip))
  (Ssequence
    (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'3 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_set_music := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'12, tshort) ::
               (_t'11, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'10, tshort) :: (_t'9, (tptr (Tstruct _Area noattr))) ::
               (_t'8, tshort) ::
               (_t'7, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'6, tshort) :: (_t'5, (tptr (Tstruct _Area noattr))) ::
               (_t'4, tshort) :: (_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _sCurrAreaIndex tshort))
    (Sifthenelse (Ebinop One (Etempvar _t'4 tshort)
                   (Eunop Oneg (Econst_int (Int.repr 1) tint) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'9 (Evar _gAreas (tptr (Tstruct _Area noattr))))
          (Ssequence
            (Sset _t'10 (Evar _sCurrAreaIndex tshort))
            (Ssequence
              (Sset _t'11
                (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
              (Ssequence
                (Sset _t'12
                  (Ederef
                    (Ecast
                      (Ebinop Oadd
                        (Ebinop Oor
                          (Ebinop Oand (Econst_int (Int.repr 2) tint)
                            (Econst_int (Int.repr 3) tint) tint)
                          (Ebinop Oshl
                            (Ebinop Oand (Econst_int (Int.repr 2) tint)
                              (Eunop Onotint (Econst_int (Int.repr 3) tint)
                                tint) tint)
                            (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                              (Econst_int (Int.repr 3) tint) tuint) tint)
                          tint)
                        (Ecast
                          (Etempvar _t'11 (tptr (Tstruct _LevelCommand noattr)))
                          (tptr tuchar)) (tptr tuchar)) (tptr tshort))
                    tshort))
                (Sassign
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Etempvar _t'9 (tptr (Tstruct _Area noattr)))
                        (Etempvar _t'10 tshort)
                        (tptr (Tstruct _Area noattr)))
                      (Tstruct _Area noattr)) _musicParam tushort)
                  (Etempvar _t'12 tshort))))))
        (Ssequence
          (Sset _t'5 (Evar _gAreas (tptr (Tstruct _Area noattr))))
          (Ssequence
            (Sset _t'6 (Evar _sCurrAreaIndex tshort))
            (Ssequence
              (Sset _t'7
                (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
              (Ssequence
                (Sset _t'8
                  (Ederef
                    (Ecast
                      (Ebinop Oadd
                        (Ebinop Oor
                          (Ebinop Oand (Econst_int (Int.repr 4) tint)
                            (Econst_int (Int.repr 3) tint) tint)
                          (Ebinop Oshl
                            (Ebinop Oand (Econst_int (Int.repr 4) tint)
                              (Eunop Onotint (Econst_int (Int.repr 3) tint)
                                tint) tint)
                            (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                              (Econst_int (Int.repr 3) tint) tuint) tint)
                          tint)
                        (Ecast
                          (Etempvar _t'7 (tptr (Tstruct _LevelCommand noattr)))
                          (tptr tuchar)) (tptr tuchar)) (tptr tshort))
                    tshort))
                (Sassign
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Etempvar _t'5 (tptr (Tstruct _Area noattr)))
                        (Etempvar _t'6 tshort) (tptr (Tstruct _Area noattr)))
                      (Tstruct _Area noattr)) _musicParam2 tushort)
                  (Etempvar _t'8 tshort)))))))
      Sskip))
  (Ssequence
    (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'3 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_set_menu_music := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'5, tshort) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'5
        (Ederef
          (Ecast
            (Ebinop Oadd
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (Ecast (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar)) (tptr tuchar)) (tptr tshort)) tshort))
      (Scall None
        (Evar _set_background_music (Tfunction
                                      (tushort :: tushort :: tshort :: nil)
                                      tvoid cc_default))
        ((Econst_int (Int.repr 0) tint) :: (Etempvar _t'5 tshort) ::
         (Econst_int (Int.repr 0) tint) :: nil))))
  (Ssequence
    (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'3 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_38 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'5, tshort) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'5
        (Ederef
          (Ecast
            (Ebinop Oadd
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (Ecast (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar)) (tptr tuchar)) (tptr tshort)) tshort))
      (Scall None
        (Evar _fadeout_music (Tfunction (tshort :: nil) tvoid cc_default))
        ((Etempvar _t'5 tshort) :: nil))))
  (Ssequence
    (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'3 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition f_level_cmd_get_or_set_var := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'19, tint) :: (_t'18, tint) :: (_t'17, tint) ::
               (_t'16, tint) :: (_t'15, tint) :: (_t'14, tuchar) ::
               (_t'13, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'12, tshort) :: (_t'11, tshort) :: (_t'10, tshort) ::
               (_t'9, tshort) :: (_t'8, tshort) :: (_t'7, tuchar) ::
               (_t'6, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'5, tuchar) ::
               (_t'4, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'5
        (Ederef
          (Ecast
            (Ebinop Oadd
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (Ecast (Etempvar _t'4 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar)) (tptr tuchar)) (tptr tuchar)) tuchar))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tuchar)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Sset _t'13
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'14
              (Ederef
                (Ecast
                  (Ebinop Oadd
                    (Ebinop Oor
                      (Ebinop Oand (Econst_int (Int.repr 3) tint)
                        (Econst_int (Int.repr 3) tint) tint)
                      (Ebinop Oshl
                        (Ebinop Oand (Econst_int (Int.repr 3) tint)
                          (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                          tint)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                    (Ecast
                      (Etempvar _t'13 (tptr (Tstruct _LevelCommand noattr)))
                      (tptr tuchar)) (tptr tuchar)) (tptr tuchar)) tuchar))
            (Sswitch (Etempvar _t'14 tuchar)
              (LScons (Some 0)
                (Ssequence
                  (Ssequence
                    (Sset _t'19 (Evar _sRegister tint))
                    (Sassign (Evar _gCurrSaveFileNum tshort)
                      (Etempvar _t'19 tint)))
                  Sbreak)
                (LScons (Some 1)
                  (Ssequence
                    (Ssequence
                      (Sset _t'18 (Evar _sRegister tint))
                      (Sassign (Evar _gCurrCourseNum tshort)
                        (Etempvar _t'18 tint)))
                    Sbreak)
                  (LScons (Some 2)
                    (Ssequence
                      (Ssequence
                        (Sset _t'17 (Evar _sRegister tint))
                        (Sassign (Evar _gCurrActNum tshort)
                          (Etempvar _t'17 tint)))
                      Sbreak)
                    (LScons (Some 3)
                      (Ssequence
                        (Ssequence
                          (Sset _t'16 (Evar _sRegister tint))
                          (Sassign (Evar _gCurrLevelNum tshort)
                            (Etempvar _t'16 tint)))
                        Sbreak)
                      (LScons (Some 4)
                        (Ssequence
                          (Ssequence
                            (Sset _t'15 (Evar _sRegister tint))
                            (Sassign (Evar _gCurrAreaIndex tshort)
                              (Etempvar _t'15 tint)))
                          Sbreak)
                        LSnil))))))))
        (Ssequence
          (Sset _t'6
            (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
          (Ssequence
            (Sset _t'7
              (Ederef
                (Ecast
                  (Ebinop Oadd
                    (Ebinop Oor
                      (Ebinop Oand (Econst_int (Int.repr 3) tint)
                        (Econst_int (Int.repr 3) tint) tint)
                      (Ebinop Oshl
                        (Ebinop Oand (Econst_int (Int.repr 3) tint)
                          (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                          tint)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                    (Ecast
                      (Etempvar _t'6 (tptr (Tstruct _LevelCommand noattr)))
                      (tptr tuchar)) (tptr tuchar)) (tptr tuchar)) tuchar))
            (Sswitch (Etempvar _t'7 tuchar)
              (LScons (Some 0)
                (Ssequence
                  (Ssequence
                    (Sset _t'12 (Evar _gCurrSaveFileNum tshort))
                    (Sassign (Evar _sRegister tint) (Etempvar _t'12 tshort)))
                  Sbreak)
                (LScons (Some 1)
                  (Ssequence
                    (Ssequence
                      (Sset _t'11 (Evar _gCurrCourseNum tshort))
                      (Sassign (Evar _sRegister tint)
                        (Etempvar _t'11 tshort)))
                    Sbreak)
                  (LScons (Some 2)
                    (Ssequence
                      (Ssequence
                        (Sset _t'10 (Evar _gCurrActNum tshort))
                        (Sassign (Evar _sRegister tint)
                          (Etempvar _t'10 tshort)))
                      Sbreak)
                    (LScons (Some 3)
                      (Ssequence
                        (Ssequence
                          (Sset _t'9 (Evar _gCurrLevelNum tshort))
                          (Sassign (Evar _sRegister tint)
                            (Etempvar _t'9 tshort)))
                        Sbreak)
                      (LScons (Some 4)
                        (Ssequence
                          (Ssequence
                            (Sset _t'8 (Evar _gCurrAreaIndex tshort))
                            (Sassign (Evar _sRegister tint)
                              (Etempvar _t'8 tshort)))
                          Sbreak)
                        LSnil)))))))))))
  (Ssequence
    (Sset _t'1 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sset _t'2 (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
              (Tstruct _LevelCommand noattr)) _size tuchar))
        (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
          (Ecast
            (Ebinop Oadd
              (Ecast (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr)))
                (tptr tuchar))
              (Ebinop Oshl (Etempvar _t'3 tuchar)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))
            (tptr (Tstruct _LevelCommand noattr))))))))
|}.

Definition v_LevelScriptJumpTable := {|
  gvar_info := (tarray (tptr (Tfunction nil tvoid cc_default)) 61);
  gvar_init := (Init_addrof _level_cmd_load_and_execute (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_exit_and_execute (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_exit (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_sleep (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_sleep2 (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_jump (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_jump_and_link (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_return (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_jump_and_link_push_arg (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_jump_repeat (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_loop_begin (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_loop_until (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_jump_if (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_jump_and_link_if (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_skip_if (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_skip (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_skippable_nop (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_call (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_call_loop (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_set_register (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_push_pool_state (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_pop_pool_state (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_load_to_fixed_address (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_load_raw (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_load_mio0 (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_load_mario_head (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_load_mio0_texture (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_init_level (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_clear_level (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_alloc_level_pool (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_free_level_pool (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_begin_area (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_end_area (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_load_model_from_dl (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_load_model_from_geo (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_23 (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_place_object (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_init_mario (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_create_warp_node (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_create_painting_warp_node (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_create_instant_warp (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_load_area (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_unload_area (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_set_mario_start_pos (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_2C (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_2D (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_set_terrain_data (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_set_rooms (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_show_dialog (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_set_terrain_type (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_nop (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_set_transition (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_set_blackout (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_set_gamma (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_set_music (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_set_menu_music (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_38 (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_set_macro_objects (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_3A (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_create_whirlpool (Ptrofs.repr 0) ::
                Init_addrof _level_cmd_get_or_set_var (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_level_script_execute := {|
  fn_return := (tptr (Tstruct _LevelCommand noattr));
  fn_callconv := cc_default;
  fn_params := ((_cmd, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'5, tshort) ::
               (_t'4, (tptr (Tfunction nil tvoid cc_default))) ::
               (_t'3, tuchar) ::
               (_t'2, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'1, (tptr (Tstruct _LevelCommand noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _sScriptStatus tshort) (Econst_int (Int.repr 1) tint))
  (Ssequence
    (Sassign (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr)))
      (Etempvar _cmd (tptr (Tstruct _LevelCommand noattr))))
    (Ssequence
      (Sloop
        (Ssequence
          (Ssequence
            (Sset _t'5 (Evar _sScriptStatus tshort))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tshort)
                           (Econst_int (Int.repr 1) tint) tint)
              Sskip
              Sbreak))
          (Ssequence
            (Sset _t'2
              (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
            (Ssequence
              (Sset _t'3
                (Efield
                  (Ederef
                    (Etempvar _t'2 (tptr (Tstruct _LevelCommand noattr)))
                    (Tstruct _LevelCommand noattr)) _type tuchar))
              (Ssequence
                (Sset _t'4
                  (Ederef
                    (Ebinop Oadd
                      (Evar _LevelScriptJumpTable (tarray (tptr (Tfunction
                                                                  nil tvoid
                                                                  cc_default)) 61))
                      (Etempvar _t'3 tuchar)
                      (tptr (tptr (Tfunction nil tvoid cc_default))))
                    (tptr (Tfunction nil tvoid cc_default))))
                (Scall None
                  (Etempvar _t'4 (tptr (Tfunction nil tvoid cc_default)))
                  nil)))))
        Sskip)
      (Ssequence
        (Scall None
          (Evar _profiler_log_thread5_time (Tfunction (tint :: nil) tvoid
                                             cc_default))
          ((Econst_int (Int.repr 1) tint) :: nil))
        (Ssequence
          (Scall None (Evar _init_rcp (Tfunction nil tvoid cc_default)) nil)
          (Ssequence
            (Scall None (Evar _render_game (Tfunction nil tvoid cc_default))
              nil)
            (Ssequence
              (Scall None
                (Evar _end_master_display_list (Tfunction nil tvoid
                                                 cc_default)) nil)
              (Ssequence
                (Scall None
                  (Evar _alloc_display_list (Tfunction (tuint :: nil)
                                              (tptr tvoid) cc_default))
                  ((Econst_int (Int.repr 0) tint) :: nil))
                (Ssequence
                  (Sset _t'1
                    (Evar _sCurrentCmd (tptr (Tstruct _LevelCommand noattr))))
                  (Sreturn (Some (Etempvar _t'1 (tptr (Tstruct _LevelCommand noattr))))))))))))))
|}.

Definition composites : list composite_definition :=
(Composite __510 Struct
   (Member_plain _w0 tuint :: Member_plain _w1 tuint :: nil)
   noattr ::
 Composite __512 Union
   (Member_plain _words (Tstruct __510 noattr) ::
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
 Composite _AllocOnlyPool Struct
   (Member_plain _totalSpace tint :: Member_plain _usedSpace tint ::
    Member_plain _startPtr (tptr tuchar) ::
    Member_plain _freePtr (tptr tuchar) :: nil)
   noattr ::
 Composite _FnGraphNode Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _func
      (tptr (Tfunction
              (tint :: (tptr (Tstruct _GraphNode noattr)) :: (tptr tvoid) ::
               nil) (tptr (Tunion __512 noattr)) cc_default)) :: nil)
   noattr ::
 Composite _GraphNodeRoot Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _areaIndex tuchar :: Member_plain _unk15 tschar ::
    Member_plain _x tshort :: Member_plain _y tshort ::
    Member_plain _width tshort :: Member_plain _height tshort ::
    Member_plain _numViews tshort ::
    Member_plain _views (tptr (tptr (Tstruct _GraphNode noattr))) :: nil)
   noattr ::
 Composite _GraphNodeStart Struct
   (Member_plain _node (Tstruct _GraphNode noattr) :: nil)
   noattr ::
 Composite __1252 Union
   (Member_plain _mode tint ::
    Member_plain _camera (tptr (Tstruct _Camera noattr)) :: nil)
   noattr ::
 Composite _GraphNodeCamera Struct
   (Member_plain _fnNode (Tstruct _FnGraphNode noattr) ::
    Member_plain _config (Tunion __1252 noattr) ::
    Member_plain _pos (tarray tfloat 3) ::
    Member_plain _focus (tarray tfloat 3) ::
    Member_plain _matrixPtr (tptr (tarray (tarray tfloat 4) 4)) ::
    Member_plain _roll tshort :: Member_plain _rollScreen tshort :: nil)
   noattr ::
 Composite _GraphNodeDisplayList Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _displayList (tptr tvoid) :: nil)
   noattr ::
 Composite _GraphNodeScale Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _displayList (tptr tvoid) :: Member_plain _scale tfloat ::
    nil)
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
 Composite _ChainSegment Struct
   (Member_plain _posX tfloat :: Member_plain _posY tfloat ::
    Member_plain _posZ tfloat :: Member_plain _pitch tshort ::
    Member_plain _yaw tshort :: Member_plain _roll tshort :: nil)
   noattr ::
 Composite _LevelCommand Struct
   (Member_plain _type tuchar :: Member_plain _size tuchar :: nil)
   noattr ::
 Composite __3650 Union
   (Member_plain _i tint :: Member_plain _f tfloat :: nil)
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
 (_osViBlack,
   Gfun(External (EF_external "osViBlack"
                   (mksignature (AST.Xint8unsigned :: nil) AST.Xvoid
                     cc_default)) (tuchar :: nil) tvoid cc_default)) ::
 (_osViSetSpecialFeatures,
   Gfun(External (EF_external "osViSetSpecialFeatures"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tuint :: nil) tvoid cc_default)) ::
 (_stop_sounds_in_continuous_banks,
   Gfun(External (EF_external "stop_sounds_in_continuous_banks"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) :: (_gFramebuffers, Gvar v_gFramebuffers) ::
 (_gZBuffer, Gvar v_gZBuffer) ::
 (_segmented_to_virtual,
   Gfun(External (EF_external "segmented_to_virtual"
                   (mksignature (AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr tvoid) :: nil) (tptr tvoid) cc_default)) ::
 (_main_pool_alloc,
   Gfun(External (EF_external "main_pool_alloc"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xptr
                     cc_default)) (tuint :: tuint :: nil) (tptr tvoid)
     cc_default)) ::
 (_main_pool_available,
   Gfun(External (EF_external "main_pool_available"
                   (mksignature nil AST.Xint cc_default)) nil tuint
     cc_default)) ::
 (_main_pool_push_state,
   Gfun(External (EF_external "main_pool_push_state"
                   (mksignature nil AST.Xint cc_default)) nil tuint
     cc_default)) ::
 (_main_pool_pop_state,
   Gfun(External (EF_external "main_pool_pop_state"
                   (mksignature nil AST.Xint cc_default)) nil tuint
     cc_default)) ::
 (_load_segment,
   Gfun(External (EF_external "load_segment"
                   (mksignature
                     (AST.Xint :: AST.Xptr :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xptr cc_default))
     (tint :: (tptr tuchar) :: (tptr tuchar) :: tuint :: nil) (tptr tvoid)
     cc_default)) ::
 (_load_to_fixed_pool_addr,
   Gfun(External (EF_external "load_to_fixed_pool_addr"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xptr cc_default))
     ((tptr tuchar) :: (tptr tuchar) :: (tptr tuchar) :: nil) (tptr tvoid)
     cc_default)) ::
 (_load_segment_decompress,
   Gfun(External (EF_external "load_segment_decompress"
                   (mksignature (AST.Xint :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xptr cc_default))
     (tint :: (tptr tuchar) :: (tptr tuchar) :: nil) (tptr tvoid)
     cc_default)) ::
 (_load_segment_decompress_heap,
   Gfun(External (EF_external "load_segment_decompress_heap"
                   (mksignature (AST.Xint :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xptr cc_default))
     (tuint :: (tptr tuchar) :: (tptr tuchar) :: nil) (tptr tvoid)
     cc_default)) ::
 (_alloc_only_pool_init,
   Gfun(External (EF_external "alloc_only_pool_init"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xptr
                     cc_default)) (tuint :: tuint :: nil)
     (tptr (Tstruct _AllocOnlyPool noattr)) cc_default)) ::
 (_alloc_only_pool_alloc,
   Gfun(External (EF_external "alloc_only_pool_alloc"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xptr
                     cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) :: tint :: nil) (tptr tvoid)
     cc_default)) ::
 (_alloc_only_pool_resize,
   Gfun(External (EF_external "alloc_only_pool_resize"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xptr
                     cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) :: tuint :: nil)
     (tptr (Tstruct _AllocOnlyPool noattr)) cc_default)) ::
 (_alloc_display_list,
   Gfun(External (EF_external "alloc_display_list"
                   (mksignature (AST.Xint :: nil) AST.Xptr cc_default))
     (tuint :: nil) (tptr tvoid) cc_default)) ::
 (_gObjParentGraphNode, Gvar v_gObjParentGraphNode) ::
 (_process_geo_layout,
   Gfun(External (EF_external "process_geo_layout"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xptr
                     cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) :: (tptr tvoid) :: nil)
     (tptr (Tstruct _GraphNode noattr)) cc_default)) ::
 (_init_graph_node_start,
   Gfun(External (EF_external "init_graph_node_start"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xptr
                     cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeStart noattr)) :: nil)
     (tptr (Tstruct _GraphNodeStart noattr)) cc_default)) ::
 (_init_graph_node_scale,
   Gfun(External (EF_external "init_graph_node_scale"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xint :: AST.Xptr ::
                      AST.Xsingle :: nil) AST.Xptr cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeScale noattr)) :: tint :: (tptr tvoid) ::
      tfloat :: nil) (tptr (Tstruct _GraphNodeScale noattr)) cc_default)) ::
 (_init_graph_node_display_list,
   Gfun(External (EF_external "init_graph_node_display_list"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xint :: AST.Xptr :: nil)
                     AST.Xptr cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeDisplayList noattr)) :: tint ::
      (tptr tvoid) :: nil) (tptr (Tstruct _GraphNodeDisplayList noattr))
     cc_default)) :: (_gLoadedGraphNodes, Gvar v_gLoadedGraphNodes) ::
 (_gAreaData, Gvar v_gAreaData) ::
 (_gCurrCourseNum, Gvar v_gCurrCourseNum) ::
 (_gCurrActNum, Gvar v_gCurrActNum) ::
 (_gCurrAreaIndex, Gvar v_gCurrAreaIndex) ::
 (_gMarioSpawnInfo, Gvar v_gMarioSpawnInfo) :: (_gAreas, Gvar v_gAreas) ::
 (_gCurrentArea, Gvar v_gCurrentArea) ::
 (_gCurrSaveFileNum, Gvar v_gCurrSaveFileNum) ::
 (_gCurrLevelNum, Gvar v_gCurrLevelNum) ::
 (_clear_areas,
   Gfun(External (EF_external "clear_areas"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_clear_area_graph_nodes,
   Gfun(External (EF_external "clear_area_graph_nodes"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_load_area,
   Gfun(External (EF_external "load_area"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tint :: nil) tvoid cc_default)) ::
 (_unload_area,
   Gfun(External (EF_external "unload_area"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_unload_mario_area,
   Gfun(External (EF_external "unload_mario_area"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
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
 (_render_game,
   Gfun(External (EF_external "render_game"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_init_rcp,
   Gfun(External (EF_external "init_rcp"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_end_master_display_list,
   Gfun(External (EF_external "end_master_display_list"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_clear_objects,
   Gfun(External (EF_external "clear_objects"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_profiler_log_thread5_time,
   Gfun(External (EF_external "profiler_log_thread5_time"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tint :: nil) tvoid cc_default)) ::
 (_save_file_get_flags,
   Gfun(External (EF_external "save_file_get_flags"
                   (mksignature nil AST.Xint cc_default)) nil tuint
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
 (_gd_add_to_heap,
   Gfun(External (EF_external "gd_add_to_heap"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default)) ((tptr tvoid) :: tuint :: nil) tvoid
     cc_default)) ::
 (_gdm_init,
   Gfun(External (EF_external "gdm_init"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default)) ((tptr tvoid) :: tuint :: nil) tvoid
     cc_default)) ::
 (_gdm_setup,
   Gfun(External (EF_external "gdm_setup"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_gdm_maketestdl,
   Gfun(External (EF_external "gdm_maketestdl"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tint :: nil) tvoid cc_default)) ::
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
 (_alloc_surface_pools,
   Gfun(External (EF_external "alloc_surface_pools"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) :: (_sStack, Gvar v_sStack) ::
 (_sLevelPool, Gvar v_sLevelPool) :: (_sDelayFrames, Gvar v_sDelayFrames) ::
 (_sDelayFrames2, Gvar v_sDelayFrames2) ::
 (_sCurrAreaIndex, Gvar v_sCurrAreaIndex) ::
 (_sStackTop, Gvar v_sStackTop) :: (_sStackBase, Gvar v_sStackBase) ::
 (_sScriptStatus, Gvar v_sScriptStatus) :: (_sRegister, Gvar v_sRegister) ::
 (_sCurrentCmd, Gvar v_sCurrentCmd) ::
 (_eval_script_op, Gfun(Internal f_eval_script_op)) ::
 (_level_cmd_load_and_execute, Gfun(Internal f_level_cmd_load_and_execute)) ::
 (_level_cmd_exit_and_execute, Gfun(Internal f_level_cmd_exit_and_execute)) ::
 (_level_cmd_exit, Gfun(Internal f_level_cmd_exit)) ::
 (_level_cmd_sleep, Gfun(Internal f_level_cmd_sleep)) ::
 (_level_cmd_sleep2, Gfun(Internal f_level_cmd_sleep2)) ::
 (_level_cmd_jump, Gfun(Internal f_level_cmd_jump)) ::
 (_level_cmd_jump_and_link, Gfun(Internal f_level_cmd_jump_and_link)) ::
 (_level_cmd_return, Gfun(Internal f_level_cmd_return)) ::
 (_level_cmd_jump_and_link_push_arg, Gfun(Internal f_level_cmd_jump_and_link_push_arg)) ::
 (_level_cmd_jump_repeat, Gfun(Internal f_level_cmd_jump_repeat)) ::
 (_level_cmd_loop_begin, Gfun(Internal f_level_cmd_loop_begin)) ::
 (_level_cmd_loop_until, Gfun(Internal f_level_cmd_loop_until)) ::
 (_level_cmd_jump_if, Gfun(Internal f_level_cmd_jump_if)) ::
 (_level_cmd_jump_and_link_if, Gfun(Internal f_level_cmd_jump_and_link_if)) ::
 (_level_cmd_skip_if, Gfun(Internal f_level_cmd_skip_if)) ::
 (_level_cmd_skip, Gfun(Internal f_level_cmd_skip)) ::
 (_level_cmd_skippable_nop, Gfun(Internal f_level_cmd_skippable_nop)) ::
 (_level_cmd_call, Gfun(Internal f_level_cmd_call)) ::
 (_level_cmd_call_loop, Gfun(Internal f_level_cmd_call_loop)) ::
 (_level_cmd_set_register, Gfun(Internal f_level_cmd_set_register)) ::
 (_level_cmd_push_pool_state, Gfun(Internal f_level_cmd_push_pool_state)) ::
 (_level_cmd_pop_pool_state, Gfun(Internal f_level_cmd_pop_pool_state)) ::
 (_level_cmd_load_to_fixed_address, Gfun(Internal f_level_cmd_load_to_fixed_address)) ::
 (_level_cmd_load_raw, Gfun(Internal f_level_cmd_load_raw)) ::
 (_level_cmd_load_mio0, Gfun(Internal f_level_cmd_load_mio0)) ::
 (_level_cmd_load_mario_head, Gfun(Internal f_level_cmd_load_mario_head)) ::
 (_level_cmd_load_mio0_texture, Gfun(Internal f_level_cmd_load_mio0_texture)) ::
 (_level_cmd_init_level, Gfun(Internal f_level_cmd_init_level)) ::
 (_level_cmd_clear_level, Gfun(Internal f_level_cmd_clear_level)) ::
 (_level_cmd_alloc_level_pool, Gfun(Internal f_level_cmd_alloc_level_pool)) ::
 (_level_cmd_free_level_pool, Gfun(Internal f_level_cmd_free_level_pool)) ::
 (_level_cmd_begin_area, Gfun(Internal f_level_cmd_begin_area)) ::
 (_level_cmd_end_area, Gfun(Internal f_level_cmd_end_area)) ::
 (_level_cmd_load_model_from_dl, Gfun(Internal f_level_cmd_load_model_from_dl)) ::
 (_level_cmd_load_model_from_geo, Gfun(Internal f_level_cmd_load_model_from_geo)) ::
 (_level_cmd_23, Gfun(Internal f_level_cmd_23)) ::
 (_level_cmd_init_mario, Gfun(Internal f_level_cmd_init_mario)) ::
 (_level_cmd_place_object, Gfun(Internal f_level_cmd_place_object)) ::
 (_level_cmd_create_warp_node, Gfun(Internal f_level_cmd_create_warp_node)) ::
 (_level_cmd_create_instant_warp, Gfun(Internal f_level_cmd_create_instant_warp)) ::
 (_level_cmd_set_terrain_type, Gfun(Internal f_level_cmd_set_terrain_type)) ::
 (_level_cmd_create_painting_warp_node, Gfun(Internal f_level_cmd_create_painting_warp_node)) ::
 (_level_cmd_3A, Gfun(Internal f_level_cmd_3A)) ::
 (_level_cmd_create_whirlpool, Gfun(Internal f_level_cmd_create_whirlpool)) ::
 (_level_cmd_set_blackout, Gfun(Internal f_level_cmd_set_blackout)) ::
 (_level_cmd_set_gamma, Gfun(Internal f_level_cmd_set_gamma)) ::
 (_level_cmd_set_terrain_data, Gfun(Internal f_level_cmd_set_terrain_data)) ::
 (_level_cmd_set_rooms, Gfun(Internal f_level_cmd_set_rooms)) ::
 (_level_cmd_set_macro_objects, Gfun(Internal f_level_cmd_set_macro_objects)) ::
 (_level_cmd_load_area, Gfun(Internal f_level_cmd_load_area)) ::
 (_level_cmd_unload_area, Gfun(Internal f_level_cmd_unload_area)) ::
 (_level_cmd_set_mario_start_pos, Gfun(Internal f_level_cmd_set_mario_start_pos)) ::
 (_level_cmd_2C, Gfun(Internal f_level_cmd_2C)) ::
 (_level_cmd_2D, Gfun(Internal f_level_cmd_2D)) ::
 (_level_cmd_set_transition, Gfun(Internal f_level_cmd_set_transition)) ::
 (_level_cmd_nop, Gfun(Internal f_level_cmd_nop)) ::
 (_level_cmd_show_dialog, Gfun(Internal f_level_cmd_show_dialog)) ::
 (_level_cmd_set_music, Gfun(Internal f_level_cmd_set_music)) ::
 (_level_cmd_set_menu_music, Gfun(Internal f_level_cmd_set_menu_music)) ::
 (_level_cmd_38, Gfun(Internal f_level_cmd_38)) ::
 (_level_cmd_get_or_set_var, Gfun(Internal f_level_cmd_get_or_set_var)) ::
 (_LevelScriptJumpTable, Gvar v_LevelScriptJumpTable) ::
 (_level_script_execute, Gfun(Internal f_level_script_execute)) :: nil).

Definition public_idents : list ident :=
(_level_script_execute :: _alloc_surface_pools :: _vec3s_set ::
 _vec3s_copy :: _gdm_maketestdl :: _gdm_setup :: _gdm_init ::
 _gd_add_to_heap :: _fadeout_music :: _set_background_music ::
 _save_file_get_flags :: _profiler_log_thread5_time :: _clear_objects ::
 _end_master_display_list :: _init_rcp :: _render_game :: _play_transition ::
 _area_update_objects :: _unload_mario_area :: _unload_area :: _load_area ::
 _clear_area_graph_nodes :: _clear_areas :: _gCurrLevelNum ::
 _gCurrSaveFileNum :: _gCurrentArea :: _gAreas :: _gMarioSpawnInfo ::
 _gCurrAreaIndex :: _gCurrActNum :: _gCurrCourseNum :: _gAreaData ::
 _gLoadedGraphNodes :: _init_graph_node_display_list ::
 _init_graph_node_scale :: _init_graph_node_start :: _process_geo_layout ::
 _gObjParentGraphNode :: _alloc_display_list :: _alloc_only_pool_resize ::
 _alloc_only_pool_alloc :: _alloc_only_pool_init ::
 _load_segment_decompress_heap :: _load_segment_decompress ::
 _load_to_fixed_pool_addr :: _load_segment :: _main_pool_pop_state ::
 _main_pool_push_state :: _main_pool_available :: _main_pool_alloc ::
 _segmented_to_virtual :: _gZBuffer :: _gFramebuffers ::
 _stop_sounds_in_continuous_banks :: _osViSetSpecialFeatures :: _osViBlack ::
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


