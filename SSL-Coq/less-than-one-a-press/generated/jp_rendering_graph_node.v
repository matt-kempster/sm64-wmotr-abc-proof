(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_JP
   Source:          src/game/rendering_graph_node.c
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_JP=1 -DF3D_OLD=1
   Link hygiene:    private __stringlit_N atoms prefixed with jp_rendering_graph_node
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
  Definition source_file := "build/pinned-sm64/src/game/rendering_graph_node.c".
  Definition normalized := true.
End Info.

Definition _AllocOnlyPool : ident := $"AllocOnlyPool".
Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _Camera : ident := $"Camera".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _DisplayListNode : ident := $"DisplayListNode".
Definition _FnGraphNode : ident := $"FnGraphNode".
Definition _GeoAnimState : ident := $"GeoAnimState".
Definition _GraphNode : ident := $"GraphNode".
Definition _GraphNodeAnimatedPart : ident := $"GraphNodeAnimatedPart".
Definition _GraphNodeBackground : ident := $"GraphNodeBackground".
Definition _GraphNodeBillboard : ident := $"GraphNodeBillboard".
Definition _GraphNodeCamera : ident := $"GraphNodeCamera".
Definition _GraphNodeCullingRadius : ident := $"GraphNodeCullingRadius".
Definition _GraphNodeDisplayList : ident := $"GraphNodeDisplayList".
Definition _GraphNodeGenerated : ident := $"GraphNodeGenerated".
Definition _GraphNodeHeldObject : ident := $"GraphNodeHeldObject".
Definition _GraphNodeLevelOfDetail : ident := $"GraphNodeLevelOfDetail".
Definition _GraphNodeMasterList : ident := $"GraphNodeMasterList".
Definition _GraphNodeObject : ident := $"GraphNodeObject".
Definition _GraphNodeObjectParent : ident := $"GraphNodeObjectParent".
Definition _GraphNodeOrthoProjection : ident := $"GraphNodeOrthoProjection".
Definition _GraphNodePerspective : ident := $"GraphNodePerspective".
Definition _GraphNodeRoot : ident := $"GraphNodeRoot".
Definition _GraphNodeRotation : ident := $"GraphNodeRotation".
Definition _GraphNodeScale : ident := $"GraphNodeScale".
Definition _GraphNodeShadow : ident := $"GraphNodeShadow".
Definition _GraphNodeSwitchCase : ident := $"GraphNodeSwitchCase".
Definition _GraphNodeTranslation : ident := $"GraphNodeTranslation".
Definition _GraphNodeTranslationRotation : ident := $"GraphNodeTranslationRotation".
Definition _Object : ident := $"Object".
Definition _ObjectNode : ident := $"ObjectNode".
Definition _RenderModeContainer : ident := $"RenderModeContainer".
Definition _SpawnInfo : ident := $"SpawnInfo".
Definition _Surface : ident := $"Surface".
Definition _Waypoint : ident := $"Waypoint".
Definition __472 : ident := $"_472".
Definition __474 : ident := $"_474".
Definition __476 : ident := $"_476".
Definition __510 : ident := $"_510".
Definition __512 : ident := $"_512".
Definition __727 : ident := $"_727".
Definition __732 : ident := $"_732".
Definition __918 : ident := $"_918".
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
Definition ___stringlit_1 : ident := $"__jp_rendering_graph_node_stringlit_1".
Definition __g : ident := $"_g".
Definition __g__1 : ident := $"_g__1".
Definition __g__2 : ident := $"_g__2".
Definition __g__3 : ident := $"_g__3".
Definition __g__4 : ident := $"_g__4".
Definition __g__5 : ident := $"_g__5".
Definition __g__6 : ident := $"_g__6".
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _alloc_display_list : ident := $"alloc_display_list".
Definition _alloc_only_pool_alloc : ident := $"alloc_only_pool_alloc".
Definition _alloc_only_pool_init : ident := $"alloc_only_pool_init".
Definition _angle : ident := $"angle".
Definition _anim : ident := $"anim".
Definition _animAccel : ident := $"animAccel".
Definition _animFrame : ident := $"animFrame".
Definition _animFrameAccelAssist : ident := $"animFrameAccelAssist".
Definition _animID : ident := $"animID".
Definition _animInfo : ident := $"animInfo".
Definition _animOffset : ident := $"animOffset".
Definition _animTimer : ident := $"animTimer".
Definition _animYTrans : ident := $"animYTrans".
Definition _animYTransDivisor : ident := $"animYTransDivisor".
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
Definition _aspect : ident := $"aspect".
Definition _attribute : ident := $"attribute".
Definition _b : ident := $"b".
Definition _background : ident := $"background".
Definition _behavior : ident := $"behavior".
Definition _behaviorArg : ident := $"behaviorArg".
Definition _behaviorScript : ident := $"behaviorScript".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _bottom : ident := $"bottom".
Definition _c : ident := $"c".
Definition _camera : ident := $"camera".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _cameraTransform : ident := $"cameraTransform".
Definition _children : ident := $"children".
Definition _clearColor : ident := $"clearColor".
Definition _clear_framebuffer : ident := $"clear_framebuffer".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _config : ident := $"config".
Definition _cosAng : ident := $"cosAng".
Definition _create_shadow_below_xyz : ident := $"create_shadow_below_xyz".
Definition _cullingRadius : ident := $"cullingRadius".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _curGraphNode : ident := $"curGraphNode".
Definition _currList : ident := $"currList".
Definition _cutscene : ident := $"cutscene".
Definition _data : ident := $"data".
Definition _defMode : ident := $"defMode".
Definition _displayList : ident := $"displayList".
Definition _distanceFromCam : ident := $"distanceFromCam".
Definition _doorStatus : ident := $"doorStatus".
Definition _enableZBuffer : ident := $"enableZBuffer".
Definition _enabled : ident := $"enabled".
Definition _far : ident := $"far".
Definition _filler : ident := $"filler".
Definition _filler1 : ident := $"filler1".
Definition _filler2 : ident := $"filler2".
Definition _firstNode : ident := $"firstNode".
Definition _flags : ident := $"flags".
Definition _fnNode : ident := $"fnNode".
Definition _focus : ident := $"focus".
Definition _force : ident := $"force".
Definition _force_structure_alignment : ident := $"force_structure_alignment".
Definition _fov : ident := $"fov".
Definition _frame : ident := $"frame".
Definition _freePtr : ident := $"freePtr".
Definition _func : ident := $"func".
Definition _gAreaUpdateCounter : ident := $"gAreaUpdateCounter".
Definition _gCurGraphNodeCamFrustum : ident := $"gCurGraphNodeCamFrustum".
Definition _gCurGraphNodeCamera : ident := $"gCurGraphNodeCamera".
Definition _gCurGraphNodeHeldObject : ident := $"gCurGraphNodeHeldObject".
Definition _gCurGraphNodeMasterList : ident := $"gCurGraphNodeMasterList".
Definition _gCurGraphNodeObject : ident := $"gCurGraphNodeObject".
Definition _gCurGraphNodeRoot : ident := $"gCurGraphNodeRoot".
Definition _gCurrAnimAttribute : ident := $"gCurrAnimAttribute".
Definition _gCurrAnimData : ident := $"gCurrAnimData".
Definition _gCurrAnimEnabled : ident := $"gCurrAnimEnabled".
Definition _gCurrAnimFrame : ident := $"gCurrAnimFrame".
Definition _gCurrAnimTranslationMultiplier : ident := $"gCurrAnimTranslationMultiplier".
Definition _gCurrAnimType : ident := $"gCurrAnimType".
Definition _gDisplayListHead : ident := $"gDisplayListHead".
Definition _gDisplayListHeap : ident := $"gDisplayListHeap".
Definition _gGeoTempState : ident := $"gGeoTempState".
Definition _gMarioOnIceOrCarpet : ident := $"gMarioOnIceOrCarpet".
Definition _gMatStack : ident := $"gMatStack".
Definition _gMatStackFixed : ident := $"gMatStackFixed".
Definition _gMatStackIndex : ident := $"gMatStackIndex".
Definition _gShadowAboveWaterOrLava : ident := $"gShadowAboveWaterOrLava".
Definition _gShowDebugText : ident := $"gShowDebugText".
Definition _gSineTable : ident := $"gSineTable".
Definition _gVec3fZero : ident := $"gVec3fZero".
Definition _gVec3sZero : ident := $"gVec3sZero".
Definition _geo : ident := $"geo".
Definition _geo_append_display_list : ident := $"geo_append_display_list".
Definition _geo_process_animated_part : ident := $"geo_process_animated_part".
Definition _geo_process_background : ident := $"geo_process_background".
Definition _geo_process_billboard : ident := $"geo_process_billboard".
Definition _geo_process_camera : ident := $"geo_process_camera".
Definition _geo_process_display_list : ident := $"geo_process_display_list".
Definition _geo_process_generated_list : ident := $"geo_process_generated_list".
Definition _geo_process_held_object : ident := $"geo_process_held_object".
Definition _geo_process_level_of_detail : ident := $"geo_process_level_of_detail".
Definition _geo_process_master_list : ident := $"geo_process_master_list".
Definition _geo_process_master_list_sub : ident := $"geo_process_master_list_sub".
Definition _geo_process_node_and_siblings : ident := $"geo_process_node_and_siblings".
Definition _geo_process_object : ident := $"geo_process_object".
Definition _geo_process_object_parent : ident := $"geo_process_object_parent".
Definition _geo_process_ortho_projection : ident := $"geo_process_ortho_projection".
Definition _geo_process_perspective : ident := $"geo_process_perspective".
Definition _geo_process_root : ident := $"geo_process_root".
Definition _geo_process_rotation : ident := $"geo_process_rotation".
Definition _geo_process_scale : ident := $"geo_process_scale".
Definition _geo_process_shadow : ident := $"geo_process_shadow".
Definition _geo_process_switch : ident := $"geo_process_switch".
Definition _geo_process_translation : ident := $"geo_process_translation".
Definition _geo_process_translation_rotation : ident := $"geo_process_translation_rotation".
Definition _geo_set_animation_globals : ident := $"geo_set_animation_globals".
Definition _geo_try_process_children : ident := $"geo_try_process_children".
Definition _geo_update_animation_frame : ident := $"geo_update_animation_frame".
Definition _get_pos_from_transform_mtx : ident := $"get_pos_from_transform_mtx".
Definition _gfx : ident := $"gfx".
Definition _gfxStart : ident := $"gfxStart".
Definition _guOrtho : ident := $"guOrtho".
Definition _guPerspective : ident := $"guPerspective".
Definition _hScreenEdge : ident := $"hScreenEdge".
Definition _halfFov : ident := $"halfFov".
Definition _hasAnimation : ident := $"hasAnimation".
Definition _header : ident := $"header".
Definition _height : ident := $"height".
Definition _hitboxDownOffset : ident := $"hitboxDownOffset".
Definition _hitboxHeight : ident := $"hitboxHeight".
Definition _hitboxRadius : ident := $"hitboxRadius".
Definition _hurtboxHeight : ident := $"hurtboxHeight".
Definition _hurtboxRadius : ident := $"hurtboxRadius".
Definition _i : ident := $"i".
Definition _index : ident := $"index".
Definition _initialMatrix : ident := $"initialMatrix".
Definition _iterateChildren : ident := $"iterateChildren".
Definition _layer : ident := $"layer".
Definition _left : ident := $"left".
Definition _length : ident := $"length".
Definition _list : ident := $"list".
Definition _listHeads : ident := $"listHeads".
Definition _listNode : ident := $"listNode".
Definition _listTails : ident := $"listTails".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _m : ident := $"m".
Definition _main : ident := $"main".
Definition _main_pool_available : ident := $"main_pool_available".
Definition _main_pool_free : ident := $"main_pool_free".
Definition _make_viewport_clip_rect : ident := $"make_viewport_clip_rect".
Definition _mat : ident := $"mat".
Definition _matrix : ident := $"matrix".
Definition _matrixPtr : ident := $"matrixPtr".
Definition _maxDistance : ident := $"maxDistance".
Definition _minDistance : ident := $"minDistance".
Definition _mode : ident := $"mode".
Definition _mode2List : ident := $"mode2List".
Definition _modeList : ident := $"modeList".
Definition _model : ident := $"model".
Definition _modes : ident := $"modes".
Definition _mtx : ident := $"mtx".
Definition _mtxf : ident := $"mtxf".
Definition _mtxf_billboard : ident := $"mtxf_billboard".
Definition _mtxf_copy : ident := $"mtxf_copy".
Definition _mtxf_identity : ident := $"mtxf_identity".
Definition _mtxf_lookat : ident := $"mtxf_lookat".
Definition _mtxf_mul : ident := $"mtxf_mul".
Definition _mtxf_rotate_xy : ident := $"mtxf_rotate_xy".
Definition _mtxf_rotate_xyz_and_translate : ident := $"mtxf_rotate_xyz_and_translate".
Definition _mtxf_rotate_zxy_and_translate : ident := $"mtxf_rotate_zxy_and_translate".
Definition _mtxf_scale_vec3f : ident := $"mtxf_scale_vec3f".
Definition _mtxf_to_mtx : ident := $"mtxf_to_mtx".
Definition _mtxf_translate : ident := $"mtxf_translate".
Definition _near : ident := $"near".
Definition _next : ident := $"next".
Definition _nextYaw : ident := $"nextYaw".
Definition _node : ident := $"node".
Definition _normal : ident := $"normal".
Definition _numCases : ident := $"numCases".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _numViews : ident := $"numViews".
Definition _objNode : ident := $"objNode".
Definition _objScale : ident := $"objScale".
Definition _obj_is_in_view : ident := $"obj_is_in_view".
Definition _object : ident := $"object".
Definition _originOffset : ident := $"originOffset".
Definition _parameter : ident := $"parameter".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _perspNorm : ident := $"perspNorm".
Definition _platform : ident := $"platform".
Definition _playerIndex : ident := $"playerIndex".
Definition _pos : ident := $"pos".
Definition _prev : ident := $"prev".
Definition _prevObj : ident := $"prevObj".
Definition _print_text_fmt_int : ident := $"print_text_fmt_int".
Definition _rawData : ident := $"rawData".
Definition _renderModeTable_1Cycle : ident := $"renderModeTable_1Cycle".
Definition _renderModeTable_2Cycle : ident := $"renderModeTable_2Cycle".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _retrieve_animation_index : ident := $"retrieve_animation_index".
Definition _right : ident := $"right".
Definition _roll : ident := $"roll".
Definition _rollMtx : ident := $"rollMtx".
Definition _rollScreen : ident := $"rollScreen".
Definition _room : ident := $"room".
Definition _rotation : ident := $"rotation".
Definition _scale : ident := $"scale".
Definition _scaleVec : ident := $"scaleVec".
Definition _segmented_to_virtual : ident := $"segmented_to_virtual".
Definition _selectedCase : ident := $"selectedCase".
Definition _selectedChild : ident := $"selectedChild".
Definition _shadowList : ident := $"shadowList".
Definition _shadowPos : ident := $"shadowPos".
Definition _shadowScale : ident := $"shadowScale".
Definition _shadowSolidity : ident := $"shadowSolidity".
Definition _shadowType : ident := $"shadowType".
Definition _sharedChild : ident := $"sharedChild".
Definition _sinAng : ident := $"sinAng".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
Definition _startPtr : ident := $"startPtr".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _top : ident := $"top".
Definition _totalSpace : ident := $"totalSpace".
Definition _transform : ident := $"transform".
Definition _translation : ident := $"translation".
Definition _translationMultiplier : ident := $"translationMultiplier".
Definition _type : ident := $"type".
Definition _unk15 : ident := $"unk15".
Definition _unk4C : ident := $"unk4C".
Definition _unused : ident := $"unused".
Definition _unused1 : ident := $"unused1".
Definition _unused2 : ident := $"unused2".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _unusedVec1 : ident := $"unusedVec1".
Definition _upperY : ident := $"upperY".
Definition _usedSpace : ident := $"usedSpace".
Definition _values : ident := $"values".
Definition _vec3f_copy : ident := $"vec3f_copy".
Definition _vec3f_set : ident := $"vec3f_set".
Definition _vec3s_copy : ident := $"vec3s_copy".
Definition _vec3s_set : ident := $"vec3s_set".
Definition _vec3s_to_vec3f : ident := $"vec3s_to_vec3f".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _viewport : ident := $"viewport".
Definition _views : ident := $"views".
Definition _vp : ident := $"vp".
Definition _vscale : ident := $"vscale".
Definition _vtrans : ident := $"vtrans".
Definition _w0 : ident := $"w0".
Definition _w1 : ident := $"w1".
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
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v___stringlit_1 := {|
  gvar_info := (tarray tuchar 7);
  gvar_init := (Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 37) :: Init_int8 (Int.repr 100) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

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

Definition v_gSineTable := {|
  gvar_info := (tarray tfloat 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDisplayListHead := {|
  gvar_info := (tptr (Tunion __512 noattr));
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

Definition v_gShadowAboveWaterOrLava := {|
  gvar_info := tschar;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMarioOnIceOrCarpet := {|
  gvar_info := tschar;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMatStackIndex := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMatStack := {|
  gvar_info := (tarray (tarray (tarray tfloat 4) 4) 32);
  gvar_init := (Init_space 2048 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMatStackFixed := {|
  gvar_info := (tarray (tptr (Tunion __472 noattr)) 32);
  gvar_init := (Init_space 128 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGeoTempState := {|
  gvar_info := (Tstruct _GeoAnimState noattr);
  gvar_init := (Init_space 16 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrAnimType := {|
  gvar_info := tuchar;
  gvar_init := (Init_space 1 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrAnimEnabled := {|
  gvar_info := tuchar;
  gvar_init := (Init_space 1 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrAnimFrame := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrAnimTranslationMultiplier := {|
  gvar_info := tfloat;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrAnimAttribute := {|
  gvar_info := (tptr tushort);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrAnimData := {|
  gvar_info := (tptr tshort);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDisplayListHeap := {|
  gvar_info := (tptr (Tstruct _AllocOnlyPool noattr));
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_renderModeTable_1Cycle := {|
  gvar_info := (tarray (Tstruct _RenderModeContainer noattr) 2);
  gvar_init := (Init_int32 (Int.repr 201867264) ::
                Init_int32 (Int.repr 4464712) ::
                Init_int32 (Int.repr 4464712) ::
                Init_int32 (Int.repr 4464712) ::
                Init_int32 (Int.repr 4468808) ::
                Init_int32 (Int.repr 4211144) ::
                Init_int32 (Int.repr 4211144) ::
                Init_int32 (Int.repr 4211144) ::
                Init_int32 (Int.repr 4465200) ::
                Init_int32 (Int.repr 4464760) ::
                Init_int32 (Int.repr 4468056) ::
                Init_int32 (Int.repr 4465784) ::
                Init_int32 (Int.repr 4468856) ::
                Init_int32 (Int.repr 4213208) ::
                Init_int32 (Int.repr 4214232) ::
                Init_int32 (Int.repr 4212184) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_renderModeTable_2Cycle := {|
  gvar_info := (tarray (Tstruct _RenderModeContainer noattr) 2);
  gvar_init := (Init_int32 (Int.repr 50479104) ::
                Init_int32 (Int.repr 1122376) ::
                Init_int32 (Int.repr 1122376) ::
                Init_int32 (Int.repr 1122376) ::
                Init_int32 (Int.repr 1126472) ::
                Init_int32 (Int.repr 1065416) ::
                Init_int32 (Int.repr 1065416) ::
                Init_int32 (Int.repr 1065416) ::
                Init_int32 (Int.repr 1122864) ::
                Init_int32 (Int.repr 1122424) ::
                Init_int32 (Int.repr 1125720) ::
                Init_int32 (Int.repr 1123448) ::
                Init_int32 (Int.repr 1126520) ::
                Init_int32 (Int.repr 1067480) ::
                Init_int32 (Int.repr 1068504) ::
                Init_int32 (Int.repr 1066456) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurGraphNodeRoot := {|
  gvar_info := (tptr (Tstruct _GraphNodeRoot noattr));
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurGraphNodeMasterList := {|
  gvar_info := (tptr (Tstruct _GraphNodeMasterList noattr));
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurGraphNodeCamFrustum := {|
  gvar_info := (tptr (Tstruct _GraphNodePerspective noattr));
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurGraphNodeCamera := {|
  gvar_info := (tptr (Tstruct _GraphNodeCamera noattr));
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurGraphNodeObject := {|
  gvar_info := (tptr (Tstruct _GraphNodeObject noattr));
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurGraphNodeHeldObject := {|
  gvar_info := (tptr (Tstruct _GraphNodeHeldObject noattr));
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAreaUpdateCounter := {|
  gvar_info := tushort;
  gvar_init := (Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_geo_process_master_list_sub := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _GraphNodeMasterList noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_currList, (tptr (Tstruct _DisplayListNode noattr))) ::
               (_i, tint) :: (_enableZBuffer, tint) ::
               (_modeList, (tptr (Tstruct _RenderModeContainer noattr))) ::
               (_mode2List, (tptr (Tstruct _RenderModeContainer noattr))) ::
               (__g, (tptr (Tunion __512 noattr))) ::
               (__g__1, (tptr (Tunion __512 noattr))) ::
               (__g__2, (tptr (Tunion __512 noattr))) ::
               (__g__3, (tptr (Tunion __512 noattr))) ::
               (__g__4, (tptr (Tunion __512 noattr))) ::
               (__g__5, (tptr (Tunion __512 noattr))) ::
               (__g__6, (tptr (Tunion __512 noattr))) ::
               (_t'8, (tptr (Tunion __512 noattr))) ::
               (_t'7, (tptr (Tunion __512 noattr))) ::
               (_t'6, (tptr (Tstruct _DisplayListNode noattr))) ::
               (_t'5, (tptr (Tunion __512 noattr))) ::
               (_t'4, (tptr (Tunion __512 noattr))) ::
               (_t'3, (tptr (Tunion __512 noattr))) ::
               (_t'2, (tptr (Tunion __512 noattr))) ::
               (_t'1, (tptr (Tunion __512 noattr))) :: (_t'14, tshort) ::
               (_t'13, (tptr (Tstruct _DisplayListNode noattr))) ::
               (_t'12, tuint) :: (_t'11, tuint) ::
               (_t'10, (tptr (Tunion __472 noattr))) ::
               (_t'9, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'14
      (Efield
        (Efield
          (Ederef
            (Etempvar _node (tptr (Tstruct _GraphNodeMasterList noattr)))
            (Tstruct _GraphNodeMasterList noattr)) _node
          (Tstruct _GraphNode noattr)) _flags tshort))
    (Sset _enableZBuffer
      (Ebinop One
        (Ebinop Oand (Etempvar _t'14 tshort)
          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
            (Econst_int (Int.repr 3) tint) tint) tint)
        (Econst_int (Int.repr 0) tint) tint)))
  (Ssequence
    (Sset _modeList
      (Ebinop Oadd
        (Evar _renderModeTable_1Cycle (tarray (Tstruct _RenderModeContainer noattr) 2))
        (Etempvar _enableZBuffer tint)
        (tptr (Tstruct _RenderModeContainer noattr))))
    (Ssequence
      (Sset _mode2List
        (Ebinop Oadd
          (Evar _renderModeTable_2Cycle (tarray (Tstruct _RenderModeContainer noattr) 2))
          (Etempvar _enableZBuffer tint)
          (tptr (Tstruct _RenderModeContainer noattr))))
      (Ssequence
        (Sifthenelse (Ebinop One (Etempvar _enableZBuffer tint)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'1
                    (Evar _gDisplayListHead (tptr (Tunion __512 noattr))))
                  (Sassign
                    (Evar _gDisplayListHead (tptr (Tunion __512 noattr)))
                    (Ebinop Oadd (Etempvar _t'1 (tptr (Tunion __512 noattr)))
                      (Econst_int (Int.repr 1) tint)
                      (tptr (Tunion __512 noattr)))))
                (Sset __g
                  (Ecast (Etempvar _t'1 (tptr (Tunion __512 noattr)))
                    (tptr (Tunion __512 noattr)))))
              (Ssequence
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g (tptr (Tunion __512 noattr)))
                        (Tunion __512 noattr)) _words (Tstruct __510 noattr))
                    _w0 tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 231) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 8) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 24) tint) tuint) tuint))
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g (tptr (Tunion __512 noattr)))
                        (Tunion __512 noattr)) _words (Tstruct __510 noattr))
                    _w1 tuint) (Econst_int (Int.repr 0) tint))))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'2
                    (Evar _gDisplayListHead (tptr (Tunion __512 noattr))))
                  (Sassign
                    (Evar _gDisplayListHead (tptr (Tunion __512 noattr)))
                    (Ebinop Oadd (Etempvar _t'2 (tptr (Tunion __512 noattr)))
                      (Econst_int (Int.repr 1) tint)
                      (tptr (Tunion __512 noattr)))))
                (Sset __g__1
                  (Ecast (Etempvar _t'2 (tptr (Tunion __512 noattr)))
                    (tptr (Tunion __512 noattr)))))
              (Ssequence
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__1 (tptr (Tunion __512 noattr)))
                        (Tunion __512 noattr)) _words (Tstruct __510 noattr))
                    _w0 tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast
                          (Ebinop Osub
                            (Eunop Oneg (Econst_int (Int.repr 65) tint) tint)
                            (Econst_int (Int.repr 8) tint) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 8) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 24) tint) tuint) tuint))
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__1 (tptr (Tunion __512 noattr)))
                        (Tunion __512 noattr)) _words (Tstruct __510 noattr))
                    _w1 tuint) (Ecast (Econst_int (Int.repr 1) tint) tuint)))))
          Sskip)
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
                  (Ssequence
                    (Ssequence
                      (Sset _t'13
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _node (tptr (Tstruct _GraphNodeMasterList noattr)))
                                (Tstruct _GraphNodeMasterList noattr))
                              _listHeads
                              (tarray (tptr (Tstruct _DisplayListNode noattr)) 8))
                            (Etempvar _i tint)
                            (tptr (tptr (Tstruct _DisplayListNode noattr))))
                          (tptr (Tstruct _DisplayListNode noattr))))
                      (Sset _t'6
                        (Ecast
                          (Etempvar _t'13 (tptr (Tstruct _DisplayListNode noattr)))
                          (tptr (Tstruct _DisplayListNode noattr)))))
                    (Sset _currList
                      (Etempvar _t'6 (tptr (Tstruct _DisplayListNode noattr)))))
                  (Sifthenelse (Ebinop One
                                 (Etempvar _t'6 (tptr (Tstruct _DisplayListNode noattr)))
                                 (Ecast (Econst_int (Int.repr 0) tint)
                                   (tptr tvoid)) tint)
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'3
                              (Evar _gDisplayListHead (tptr (Tunion __512 noattr))))
                            (Sassign
                              (Evar _gDisplayListHead (tptr (Tunion __512 noattr)))
                              (Ebinop Oadd
                                (Etempvar _t'3 (tptr (Tunion __512 noattr)))
                                (Econst_int (Int.repr 1) tint)
                                (tptr (Tunion __512 noattr)))))
                          (Sset __g__2
                            (Ecast
                              (Etempvar _t'3 (tptr (Tunion __512 noattr)))
                              (tptr (Tunion __512 noattr)))))
                        (Ssequence
                          (Sassign
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar __g__2 (tptr (Tunion __512 noattr)))
                                  (Tunion __512 noattr)) _words
                                (Tstruct __510 noattr)) _w0 tuint)
                            (Ebinop Oor
                              (Ebinop Oor
                                (Ecast
                                  (Ebinop Oshl
                                    (Ebinop Oand
                                      (Ecast
                                        (Ebinop Osub
                                          (Eunop Oneg
                                            (Econst_int (Int.repr 65) tint)
                                            tint)
                                          (Econst_int (Int.repr 6) tint)
                                          tint) tuint)
                                      (Ebinop Osub
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 8) tint)
                                          tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuint) (Econst_int (Int.repr 24) tint)
                                    tuint) tuint)
                                (Ecast
                                  (Ebinop Oshl
                                    (Ebinop Oand
                                      (Ecast (Econst_int (Int.repr 3) tint)
                                        tuint)
                                      (Ebinop Osub
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 8) tint)
                                          tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuint) (Econst_int (Int.repr 8) tint)
                                    tuint) tuint) tuint)
                              (Ecast
                                (Ebinop Oshl
                                  (Ebinop Oand
                                    (Ecast (Econst_int (Int.repr 29) tint)
                                      tuint)
                                    (Ebinop Osub
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 8) tint) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuint) (Econst_int (Int.repr 0) tint)
                                  tuint) tuint) tuint))
                          (Ssequence
                            (Sset _t'11
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _modeList (tptr (Tstruct _RenderModeContainer noattr)))
                                      (Tstruct _RenderModeContainer noattr))
                                    _modes (tarray tuint 8))
                                  (Etempvar _i tint) (tptr tuint)) tuint))
                            (Ssequence
                              (Sset _t'12
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Etempvar _mode2List (tptr (Tstruct _RenderModeContainer noattr)))
                                        (Tstruct _RenderModeContainer noattr))
                                      _modes (tarray tuint 8))
                                    (Etempvar _i tint) (tptr tuint)) tuint))
                              (Sassign
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar __g__2 (tptr (Tunion __512 noattr)))
                                      (Tunion __512 noattr)) _words
                                    (Tstruct __510 noattr)) _w1 tuint)
                                (Ecast
                                  (Ebinop Oor (Etempvar _t'11 tuint)
                                    (Etempvar _t'12 tuint) tuint) tuint))))))
                      (Swhile
                        (Ebinop One
                          (Etempvar _currList (tptr (Tstruct _DisplayListNode noattr)))
                          (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                          tint)
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Sset _t'4
                                  (Evar _gDisplayListHead (tptr (Tunion __512 noattr))))
                                (Sassign
                                  (Evar _gDisplayListHead (tptr (Tunion __512 noattr)))
                                  (Ebinop Oadd
                                    (Etempvar _t'4 (tptr (Tunion __512 noattr)))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr (Tunion __512 noattr)))))
                              (Sset __g__3
                                (Ecast
                                  (Etempvar _t'4 (tptr (Tunion __512 noattr)))
                                  (tptr (Tunion __512 noattr)))))
                            (Ssequence
                              (Sassign
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar __g__3 (tptr (Tunion __512 noattr)))
                                      (Tunion __512 noattr)) _words
                                    (Tstruct __510 noattr)) _w0 tuint)
                                (Ebinop Oor
                                  (Ebinop Oor
                                    (Ecast
                                      (Ebinop Oshl
                                        (Ebinop Oand
                                          (Ecast
                                            (Econst_int (Int.repr 1) tint)
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
                                            (Ebinop Oor
                                              (Ebinop Oor
                                                (Econst_int (Int.repr 0) tint)
                                                (Econst_int (Int.repr 2) tint)
                                                tint)
                                              (Econst_int (Int.repr 0) tint)
                                              tint) tuint)
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
                                          (Esizeof (Tunion __472 noattr) tuint)
                                          tuint)
                                        (Ebinop Osub
                                          (Ebinop Oshl
                                            (Econst_int (Int.repr 1) tint)
                                            (Econst_int (Int.repr 16) tint)
                                            tint)
                                          (Econst_int (Int.repr 1) tint)
                                          tint) tuint)
                                      (Econst_int (Int.repr 0) tint) tuint)
                                    tuint) tuint))
                              (Ssequence
                                (Sset _t'10
                                  (Efield
                                    (Ederef
                                      (Etempvar _currList (tptr (Tstruct _DisplayListNode noattr)))
                                      (Tstruct _DisplayListNode noattr))
                                    _transform (tptr (Tunion __472 noattr))))
                                (Sassign
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar __g__3 (tptr (Tunion __512 noattr)))
                                        (Tunion __512 noattr)) _words
                                      (Tstruct __510 noattr)) _w1 tuint)
                                  (Ecast
                                    (Ebinop Oand
                                      (Ecast
                                        (Etempvar _t'10 (tptr (Tunion __472 noattr)))
                                        tuint)
                                      (Econst_int (Int.repr 536870911) tint)
                                      tuint) tuint)))))
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Ssequence
                                  (Sset _t'5
                                    (Evar _gDisplayListHead (tptr (Tunion __512 noattr))))
                                  (Sassign
                                    (Evar _gDisplayListHead (tptr (Tunion __512 noattr)))
                                    (Ebinop Oadd
                                      (Etempvar _t'5 (tptr (Tunion __512 noattr)))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr (Tunion __512 noattr)))))
                                (Sset __g__4
                                  (Ecast
                                    (Etempvar _t'5 (tptr (Tunion __512 noattr)))
                                    (tptr (Tunion __512 noattr)))))
                              (Ssequence
                                (Sassign
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar __g__4 (tptr (Tunion __512 noattr)))
                                        (Tunion __512 noattr)) _words
                                      (Tstruct __510 noattr)) _w0 tuint)
                                  (Ebinop Oor
                                    (Ebinop Oor
                                      (Ecast
                                        (Ebinop Oshl
                                          (Ebinop Oand
                                            (Ecast
                                              (Econst_int (Int.repr 6) tint)
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
                                        (Econst_int (Int.repr 0) tint) tuint)
                                      tuint) tuint))
                                (Ssequence
                                  (Sset _t'9
                                    (Efield
                                      (Ederef
                                        (Etempvar _currList (tptr (Tstruct _DisplayListNode noattr)))
                                        (Tstruct _DisplayListNode noattr))
                                      _displayList (tptr tvoid)))
                                  (Sassign
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar __g__4 (tptr (Tunion __512 noattr)))
                                          (Tunion __512 noattr)) _words
                                        (Tstruct __510 noattr)) _w1 tuint)
                                    (Ecast (Etempvar _t'9 (tptr tvoid))
                                      tuint)))))
                            (Sset _currList
                              (Efield
                                (Ederef
                                  (Etempvar _currList (tptr (Tstruct _DisplayListNode noattr)))
                                  (Tstruct _DisplayListNode noattr)) _next
                                (tptr (Tstruct _DisplayListNode noattr))))))))
                    Sskip)))
              (Sset _i
                (Ebinop Oadd (Etempvar _i tint)
                  (Econst_int (Int.repr 1) tint) tint))))
          (Sifthenelse (Ebinop One (Etempvar _enableZBuffer tint)
                         (Econst_int (Int.repr 0) tint) tint)
            (Ssequence
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'7
                      (Evar _gDisplayListHead (tptr (Tunion __512 noattr))))
                    (Sassign
                      (Evar _gDisplayListHead (tptr (Tunion __512 noattr)))
                      (Ebinop Oadd
                        (Etempvar _t'7 (tptr (Tunion __512 noattr)))
                        (Econst_int (Int.repr 1) tint)
                        (tptr (Tunion __512 noattr)))))
                  (Sset __g__5
                    (Ecast (Etempvar _t'7 (tptr (Tunion __512 noattr)))
                      (tptr (Tunion __512 noattr)))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__5 (tptr (Tunion __512 noattr)))
                          (Tunion __512 noattr)) _words
                        (Tstruct __510 noattr)) _w0 tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 231) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 24) tint) tuint) tuint))
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__5 (tptr (Tunion __512 noattr)))
                          (Tunion __512 noattr)) _words
                        (Tstruct __510 noattr)) _w1 tuint)
                    (Econst_int (Int.repr 0) tint))))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'8
                      (Evar _gDisplayListHead (tptr (Tunion __512 noattr))))
                    (Sassign
                      (Evar _gDisplayListHead (tptr (Tunion __512 noattr)))
                      (Ebinop Oadd
                        (Etempvar _t'8 (tptr (Tunion __512 noattr)))
                        (Econst_int (Int.repr 1) tint)
                        (tptr (Tunion __512 noattr)))))
                  (Sset __g__6
                    (Ecast (Etempvar _t'8 (tptr (Tunion __512 noattr)))
                      (tptr (Tunion __512 noattr)))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__6 (tptr (Tunion __512 noattr)))
                          (Tunion __512 noattr)) _words
                        (Tstruct __510 noattr)) _w0 tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast
                            (Ebinop Osub
                              (Eunop Oneg (Econst_int (Int.repr 65) tint)
                                tint) (Econst_int (Int.repr 9) tint) tint)
                            tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 24) tint) tuint) tuint))
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__6 (tptr (Tunion __512 noattr)))
                          (Tunion __512 noattr)) _words
                        (Tstruct __510 noattr)) _w1 tuint)
                    (Ecast (Econst_int (Int.repr 1) tint) tuint)))))
            Sskip))))))
|}.

Definition f_geo_append_display_list := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_displayList, (tptr tvoid)) :: (_layer, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_listNode, (tptr (Tstruct _DisplayListNode noattr))) ::
               (_t'1, (tptr tvoid)) ::
               (_t'11, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'10, (tptr (Tunion __472 noattr))) :: (_t'9, tshort) ::
               (_t'8, (tptr (Tstruct _GraphNodeMasterList noattr))) ::
               (_t'7, (tptr (Tstruct _DisplayListNode noattr))) ::
               (_t'6, (tptr (Tstruct _GraphNodeMasterList noattr))) ::
               (_t'5, (tptr (Tstruct _DisplayListNode noattr))) ::
               (_t'4, (tptr (Tstruct _GraphNodeMasterList noattr))) ::
               (_t'3, (tptr (Tstruct _GraphNodeMasterList noattr))) ::
               (_t'2, (tptr (Tstruct _GraphNodeMasterList noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'2
    (Evar _gCurGraphNodeMasterList (tptr (Tstruct _GraphNodeMasterList noattr))))
  (Sifthenelse (Ebinop One
                 (Etempvar _t'2 (tptr (Tstruct _GraphNodeMasterList noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'11
            (Evar _gDisplayListHeap (tptr (Tstruct _AllocOnlyPool noattr))))
          (Scall (Some _t'1)
            (Evar _alloc_only_pool_alloc (Tfunction
                                           ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                            tint :: nil) (tptr tvoid)
                                           cc_default))
            ((Etempvar _t'11 (tptr (Tstruct _AllocOnlyPool noattr))) ::
             (Esizeof (Tstruct _DisplayListNode noattr) tuint) :: nil)))
        (Sset _listNode (Etempvar _t'1 (tptr tvoid))))
      (Ssequence
        (Ssequence
          (Sset _t'9 (Evar _gMatStackIndex tshort))
          (Ssequence
            (Sset _t'10
              (Ederef
                (Ebinop Oadd
                  (Evar _gMatStackFixed (tarray (tptr (Tunion __472 noattr)) 32))
                  (Etempvar _t'9 tshort) (tptr (tptr (Tunion __472 noattr))))
                (tptr (Tunion __472 noattr))))
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _listNode (tptr (Tstruct _DisplayListNode noattr)))
                  (Tstruct _DisplayListNode noattr)) _transform
                (tptr (Tunion __472 noattr)))
              (Etempvar _t'10 (tptr (Tunion __472 noattr))))))
        (Ssequence
          (Sassign
            (Efield
              (Ederef
                (Etempvar _listNode (tptr (Tstruct _DisplayListNode noattr)))
                (Tstruct _DisplayListNode noattr)) _displayList (tptr tvoid))
            (Etempvar _displayList (tptr tvoid)))
          (Ssequence
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _listNode (tptr (Tstruct _DisplayListNode noattr)))
                  (Tstruct _DisplayListNode noattr)) _next
                (tptr (Tstruct _DisplayListNode noattr)))
              (Econst_int (Int.repr 0) tint))
            (Ssequence
              (Ssequence
                (Sset _t'4
                  (Evar _gCurGraphNodeMasterList (tptr (Tstruct _GraphNodeMasterList noattr))))
                (Ssequence
                  (Sset _t'5
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _t'4 (tptr (Tstruct _GraphNodeMasterList noattr)))
                            (Tstruct _GraphNodeMasterList noattr)) _listHeads
                          (tarray (tptr (Tstruct _DisplayListNode noattr)) 8))
                        (Etempvar _layer tshort)
                        (tptr (tptr (Tstruct _DisplayListNode noattr))))
                      (tptr (Tstruct _DisplayListNode noattr))))
                  (Sifthenelse (Ebinop Oeq
                                 (Etempvar _t'5 (tptr (Tstruct _DisplayListNode noattr)))
                                 (Ecast (Econst_int (Int.repr 0) tint)
                                   (tptr tvoid)) tint)
                    (Ssequence
                      (Sset _t'8
                        (Evar _gCurGraphNodeMasterList (tptr (Tstruct _GraphNodeMasterList noattr))))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _t'8 (tptr (Tstruct _GraphNodeMasterList noattr)))
                                (Tstruct _GraphNodeMasterList noattr))
                              _listHeads
                              (tarray (tptr (Tstruct _DisplayListNode noattr)) 8))
                            (Etempvar _layer tshort)
                            (tptr (tptr (Tstruct _DisplayListNode noattr))))
                          (tptr (Tstruct _DisplayListNode noattr)))
                        (Etempvar _listNode (tptr (Tstruct _DisplayListNode noattr)))))
                    (Ssequence
                      (Sset _t'6
                        (Evar _gCurGraphNodeMasterList (tptr (Tstruct _GraphNodeMasterList noattr))))
                      (Ssequence
                        (Sset _t'7
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _t'6 (tptr (Tstruct _GraphNodeMasterList noattr)))
                                  (Tstruct _GraphNodeMasterList noattr))
                                _listTails
                                (tarray (tptr (Tstruct _DisplayListNode noattr)) 8))
                              (Etempvar _layer tshort)
                              (tptr (tptr (Tstruct _DisplayListNode noattr))))
                            (tptr (Tstruct _DisplayListNode noattr))))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _t'7 (tptr (Tstruct _DisplayListNode noattr)))
                              (Tstruct _DisplayListNode noattr)) _next
                            (tptr (Tstruct _DisplayListNode noattr)))
                          (Etempvar _listNode (tptr (Tstruct _DisplayListNode noattr)))))))))
              (Ssequence
                (Sset _t'3
                  (Evar _gCurGraphNodeMasterList (tptr (Tstruct _GraphNodeMasterList noattr))))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _t'3 (tptr (Tstruct _GraphNodeMasterList noattr)))
                          (Tstruct _GraphNodeMasterList noattr)) _listTails
                        (tarray (tptr (Tstruct _DisplayListNode noattr)) 8))
                      (Etempvar _layer tshort)
                      (tptr (tptr (Tstruct _DisplayListNode noattr))))
                    (tptr (Tstruct _DisplayListNode noattr)))
                  (Etempvar _listNode (tptr (Tstruct _DisplayListNode noattr))))))))))
    Sskip))
|}.

Definition f_geo_process_master_list := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _GraphNodeMasterList noattr))) :: nil);
  fn_vars := ((_filler, (tarray tuchar 4)) :: nil);
  fn_temps := ((_i, tint) :: (_t'1, tint) ::
               (_t'4, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'3, (tptr (Tstruct _GraphNodeMasterList noattr))) ::
               (_t'2, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3
      (Evar _gCurGraphNodeMasterList (tptr (Tstruct _GraphNodeMasterList noattr))))
    (Sifthenelse (Ebinop Oeq
                   (Etempvar _t'3 (tptr (Tstruct _GraphNodeMasterList noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Sset _t'4
          (Efield
            (Efield
              (Ederef
                (Etempvar _node (tptr (Tstruct _GraphNodeMasterList noattr)))
                (Tstruct _GraphNodeMasterList noattr)) _node
              (Tstruct _GraphNode noattr)) _children
            (tptr (Tstruct _GraphNode noattr))))
        (Sset _t'1
          (Ecast
            (Ebinop One (Etempvar _t'4 (tptr (Tstruct _GraphNode noattr)))
              (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
            tbool)))
      (Sset _t'1 (Econst_int (Int.repr 0) tint))))
  (Sifthenelse (Etempvar _t'1 tint)
    (Ssequence
      (Sassign
        (Evar _gCurGraphNodeMasterList (tptr (Tstruct _GraphNodeMasterList noattr)))
        (Etempvar _node (tptr (Tstruct _GraphNodeMasterList noattr))))
      (Ssequence
        (Ssequence
          (Sset _i (Econst_int (Int.repr 0) tint))
          (Sloop
            (Ssequence
              (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                             (Econst_int (Int.repr 8) tint) tint)
                Sskip
                Sbreak)
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _node (tptr (Tstruct _GraphNodeMasterList noattr)))
                        (Tstruct _GraphNodeMasterList noattr)) _listHeads
                      (tarray (tptr (Tstruct _DisplayListNode noattr)) 8))
                    (Etempvar _i tint)
                    (tptr (tptr (Tstruct _DisplayListNode noattr))))
                  (tptr (Tstruct _DisplayListNode noattr)))
                (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
            (Sset _i
              (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint)
                tint))))
        (Ssequence
          (Ssequence
            (Sset _t'2
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _node (tptr (Tstruct _GraphNodeMasterList noattr)))
                    (Tstruct _GraphNodeMasterList noattr)) _node
                  (Tstruct _GraphNode noattr)) _children
                (tptr (Tstruct _GraphNode noattr))))
            (Scall None
              (Evar _geo_process_node_and_siblings (Tfunction
                                                     ((tptr (Tstruct _GraphNode noattr)) ::
                                                      nil) tvoid cc_default))
              ((Etempvar _t'2 (tptr (Tstruct _GraphNode noattr))) :: nil)))
          (Ssequence
            (Scall None
              (Evar _geo_process_master_list_sub (Tfunction
                                                   ((tptr (Tstruct _GraphNodeMasterList noattr)) ::
                                                    nil) tvoid cc_default))
              ((Etempvar _node (tptr (Tstruct _GraphNodeMasterList noattr))) ::
               nil))
            (Sassign
              (Evar _gCurGraphNodeMasterList (tptr (Tstruct _GraphNodeMasterList noattr)))
              (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))))))
    Sskip))
|}.

Definition f_geo_process_ortho_projection := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _GraphNodeOrthoProjection noattr))) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_mtx, (tptr (Tunion __472 noattr))) :: (_left, tfloat) ::
               (_right, tfloat) :: (_top, tfloat) :: (_bottom, tfloat) ::
               (__g, (tptr (Tunion __512 noattr))) ::
               (__g__1, (tptr (Tunion __512 noattr))) ::
               (_t'3, (tptr (Tunion __512 noattr))) ::
               (_t'2, (tptr (Tunion __512 noattr))) ::
               (_t'1, (tptr tvoid)) :: (_t'25, tfloat) :: (_t'24, tshort) ::
               (_t'23, (tptr (Tstruct _GraphNodeRoot noattr))) ::
               (_t'22, tshort) ::
               (_t'21, (tptr (Tstruct _GraphNodeRoot noattr))) ::
               (_t'20, tfloat) :: (_t'19, tshort) ::
               (_t'18, (tptr (Tstruct _GraphNodeRoot noattr))) ::
               (_t'17, tshort) ::
               (_t'16, (tptr (Tstruct _GraphNodeRoot noattr))) ::
               (_t'15, tfloat) :: (_t'14, tshort) ::
               (_t'13, (tptr (Tstruct _GraphNodeRoot noattr))) ::
               (_t'12, tshort) ::
               (_t'11, (tptr (Tstruct _GraphNodeRoot noattr))) ::
               (_t'10, tfloat) :: (_t'9, tshort) ::
               (_t'8, (tptr (Tstruct _GraphNodeRoot noattr))) ::
               (_t'7, tshort) ::
               (_t'6, (tptr (Tstruct _GraphNodeRoot noattr))) ::
               (_t'5, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'4, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'4
    (Efield
      (Efield
        (Ederef
          (Etempvar _node (tptr (Tstruct _GraphNodeOrthoProjection noattr)))
          (Tstruct _GraphNodeOrthoProjection noattr)) _node
        (Tstruct _GraphNode noattr)) _children
      (tptr (Tstruct _GraphNode noattr))))
  (Sifthenelse (Ebinop One (Etempvar _t'4 (tptr (Tstruct _GraphNode noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                      cc_default))
          ((Esizeof (Tunion __472 noattr) tuint) :: nil))
        (Sset _mtx (Etempvar _t'1 (tptr tvoid))))
      (Ssequence
        (Ssequence
          (Sset _t'21
            (Evar _gCurGraphNodeRoot (tptr (Tstruct _GraphNodeRoot noattr))))
          (Ssequence
            (Sset _t'22
              (Efield
                (Ederef
                  (Etempvar _t'21 (tptr (Tstruct _GraphNodeRoot noattr)))
                  (Tstruct _GraphNodeRoot noattr)) _x tshort))
            (Ssequence
              (Sset _t'23
                (Evar _gCurGraphNodeRoot (tptr (Tstruct _GraphNodeRoot noattr))))
              (Ssequence
                (Sset _t'24
                  (Efield
                    (Ederef
                      (Etempvar _t'23 (tptr (Tstruct _GraphNodeRoot noattr)))
                      (Tstruct _GraphNodeRoot noattr)) _width tshort))
                (Ssequence
                  (Sset _t'25
                    (Efield
                      (Ederef
                        (Etempvar _node (tptr (Tstruct _GraphNodeOrthoProjection noattr)))
                        (Tstruct _GraphNodeOrthoProjection noattr)) _scale
                      tfloat))
                  (Sset _left
                    (Ebinop Omul
                      (Ebinop Odiv
                        (Ebinop Osub (Etempvar _t'22 tshort)
                          (Etempvar _t'24 tshort) tint)
                        (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                        tfloat) (Etempvar _t'25 tfloat) tfloat)))))))
        (Ssequence
          (Ssequence
            (Sset _t'16
              (Evar _gCurGraphNodeRoot (tptr (Tstruct _GraphNodeRoot noattr))))
            (Ssequence
              (Sset _t'17
                (Efield
                  (Ederef
                    (Etempvar _t'16 (tptr (Tstruct _GraphNodeRoot noattr)))
                    (Tstruct _GraphNodeRoot noattr)) _x tshort))
              (Ssequence
                (Sset _t'18
                  (Evar _gCurGraphNodeRoot (tptr (Tstruct _GraphNodeRoot noattr))))
                (Ssequence
                  (Sset _t'19
                    (Efield
                      (Ederef
                        (Etempvar _t'18 (tptr (Tstruct _GraphNodeRoot noattr)))
                        (Tstruct _GraphNodeRoot noattr)) _width tshort))
                  (Ssequence
                    (Sset _t'20
                      (Efield
                        (Ederef
                          (Etempvar _node (tptr (Tstruct _GraphNodeOrthoProjection noattr)))
                          (Tstruct _GraphNodeOrthoProjection noattr)) _scale
                        tfloat))
                    (Sset _right
                      (Ebinop Omul
                        (Ebinop Odiv
                          (Ebinop Oadd (Etempvar _t'17 tshort)
                            (Etempvar _t'19 tshort) tint)
                          (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                          tfloat) (Etempvar _t'20 tfloat) tfloat)))))))
          (Ssequence
            (Ssequence
              (Sset _t'11
                (Evar _gCurGraphNodeRoot (tptr (Tstruct _GraphNodeRoot noattr))))
              (Ssequence
                (Sset _t'12
                  (Efield
                    (Ederef
                      (Etempvar _t'11 (tptr (Tstruct _GraphNodeRoot noattr)))
                      (Tstruct _GraphNodeRoot noattr)) _y tshort))
                (Ssequence
                  (Sset _t'13
                    (Evar _gCurGraphNodeRoot (tptr (Tstruct _GraphNodeRoot noattr))))
                  (Ssequence
                    (Sset _t'14
                      (Efield
                        (Ederef
                          (Etempvar _t'13 (tptr (Tstruct _GraphNodeRoot noattr)))
                          (Tstruct _GraphNodeRoot noattr)) _height tshort))
                    (Ssequence
                      (Sset _t'15
                        (Efield
                          (Ederef
                            (Etempvar _node (tptr (Tstruct _GraphNodeOrthoProjection noattr)))
                            (Tstruct _GraphNodeOrthoProjection noattr))
                          _scale tfloat))
                      (Sset _top
                        (Ebinop Omul
                          (Ebinop Odiv
                            (Ebinop Osub (Etempvar _t'12 tshort)
                              (Etempvar _t'14 tshort) tint)
                            (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                            tfloat) (Etempvar _t'15 tfloat) tfloat)))))))
            (Ssequence
              (Ssequence
                (Sset _t'6
                  (Evar _gCurGraphNodeRoot (tptr (Tstruct _GraphNodeRoot noattr))))
                (Ssequence
                  (Sset _t'7
                    (Efield
                      (Ederef
                        (Etempvar _t'6 (tptr (Tstruct _GraphNodeRoot noattr)))
                        (Tstruct _GraphNodeRoot noattr)) _y tshort))
                  (Ssequence
                    (Sset _t'8
                      (Evar _gCurGraphNodeRoot (tptr (Tstruct _GraphNodeRoot noattr))))
                    (Ssequence
                      (Sset _t'9
                        (Efield
                          (Ederef
                            (Etempvar _t'8 (tptr (Tstruct _GraphNodeRoot noattr)))
                            (Tstruct _GraphNodeRoot noattr)) _height tshort))
                      (Ssequence
                        (Sset _t'10
                          (Efield
                            (Ederef
                              (Etempvar _node (tptr (Tstruct _GraphNodeOrthoProjection noattr)))
                              (Tstruct _GraphNodeOrthoProjection noattr))
                            _scale tfloat))
                        (Sset _bottom
                          (Ebinop Omul
                            (Ebinop Odiv
                              (Ebinop Oadd (Etempvar _t'7 tshort)
                                (Etempvar _t'9 tshort) tint)
                              (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                              tfloat) (Etempvar _t'10 tfloat) tfloat)))))))
              (Ssequence
                (Scall None
                  (Evar _guOrtho (Tfunction
                                   ((tptr (Tunion __472 noattr)) :: tfloat ::
                                    tfloat :: tfloat :: tfloat :: tfloat ::
                                    tfloat :: tfloat :: nil) tvoid
                                   cc_default))
                  ((Etempvar _mtx (tptr (Tunion __472 noattr))) ::
                   (Etempvar _left tfloat) :: (Etempvar _right tfloat) ::
                   (Etempvar _bottom tfloat) :: (Etempvar _top tfloat) ::
                   (Eunop Oneg
                     (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                     tfloat) ::
                   (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat) ::
                   (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat) ::
                   nil))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'2
                          (Evar _gDisplayListHead (tptr (Tunion __512 noattr))))
                        (Sassign
                          (Evar _gDisplayListHead (tptr (Tunion __512 noattr)))
                          (Ebinop Oadd
                            (Etempvar _t'2 (tptr (Tunion __512 noattr)))
                            (Econst_int (Int.repr 1) tint)
                            (tptr (Tunion __512 noattr)))))
                      (Sset __g
                        (Ecast (Etempvar _t'2 (tptr (Tunion __512 noattr)))
                          (tptr (Tunion __512 noattr)))))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar __g (tptr (Tunion __512 noattr)))
                              (Tunion __512 noattr)) _words
                            (Tstruct __510 noattr)) _w0 tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast
                                (Ebinop Osub
                                  (Eunop Oneg (Econst_int (Int.repr 65) tint)
                                    tint) (Econst_int (Int.repr 11) tint)
                                  tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 8) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 24) tint) tuint) tuint))
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar __g (tptr (Tunion __512 noattr)))
                              (Tunion __512 noattr)) _words
                            (Tstruct __510 noattr)) _w1 tuint)
                        (Econst_int (Int.repr 65535) tint))))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'3
                            (Evar _gDisplayListHead (tptr (Tunion __512 noattr))))
                          (Sassign
                            (Evar _gDisplayListHead (tptr (Tunion __512 noattr)))
                            (Ebinop Oadd
                              (Etempvar _t'3 (tptr (Tunion __512 noattr)))
                              (Econst_int (Int.repr 1) tint)
                              (tptr (Tunion __512 noattr)))))
                        (Sset __g__1
                          (Ecast (Etempvar _t'3 (tptr (Tunion __512 noattr)))
                            (tptr (Tunion __512 noattr)))))
                      (Ssequence
                        (Sassign
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar __g__1 (tptr (Tunion __512 noattr)))
                                (Tunion __512 noattr)) _words
                              (Tstruct __510 noattr)) _w0 tuint)
                          (Ebinop Oor
                            (Ebinop Oor
                              (Ecast
                                (Ebinop Oshl
                                  (Ebinop Oand
                                    (Ecast (Econst_int (Int.repr 1) tint)
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
                                      (Ebinop Oor
                                        (Ebinop Oor
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 2) tint)
                                          tint)
                                        (Econst_int (Int.repr 0) tint) tint)
                                      tuint)
                                    (Ebinop Osub
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 8) tint) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuint) (Econst_int (Int.repr 16) tint)
                                  tuint) tuint) tuint)
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast
                                    (Esizeof (Tunion __472 noattr) tuint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 16) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 0) tint)
                                tuint) tuint) tuint))
                        (Sassign
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar __g__1 (tptr (Tunion __512 noattr)))
                                (Tunion __512 noattr)) _words
                              (Tstruct __510 noattr)) _w1 tuint)
                          (Ecast
                            (Ebinop Oand
                              (Ecast
                                (Etempvar _mtx (tptr (Tunion __472 noattr)))
                                tuint) (Econst_int (Int.repr 536870911) tint)
                              tuint) tuint))))
                    (Ssequence
                      (Sset _t'5
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _node (tptr (Tstruct _GraphNodeOrthoProjection noattr)))
                              (Tstruct _GraphNodeOrthoProjection noattr))
                            _node (Tstruct _GraphNode noattr)) _children
                          (tptr (Tstruct _GraphNode noattr))))
                      (Scall None
                        (Evar _geo_process_node_and_siblings (Tfunction
                                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                                nil) tvoid
                                                               cc_default))
                        ((Etempvar _t'5 (tptr (Tstruct _GraphNode noattr))) ::
                         nil)))))))))))
    Sskip))
|}.

Definition f_geo_process_perspective := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _GraphNodePerspective noattr))) ::
                nil);
  fn_vars := ((_perspNorm, tushort) :: nil);
  fn_temps := ((_mtx, (tptr (Tunion __472 noattr))) :: (_aspect, tfloat) ::
               (__g, (tptr (Tunion __512 noattr))) ::
               (__g__1, (tptr (Tunion __512 noattr))) ::
               (_t'3, (tptr (Tunion __512 noattr))) ::
               (_t'2, (tptr (Tunion __512 noattr))) ::
               (_t'1, (tptr tvoid)) :: (_t'16, tshort) ::
               (_t'15,
                (tptr (Tfunction
                        (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                         (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                        cc_default))) ::
               (_t'14,
                (tptr (Tfunction
                        (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                         (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                        cc_default))) :: (_t'13, tshort) ::
               (_t'12, (tptr (Tstruct _GraphNodeRoot noattr))) ::
               (_t'11, tshort) ::
               (_t'10, (tptr (Tstruct _GraphNodeRoot noattr))) ::
               (_t'9, tshort) :: (_t'8, tshort) :: (_t'7, tfloat) ::
               (_t'6, tushort) ::
               (_t'5, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'4, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'14
      (Efield
        (Efield
          (Ederef
            (Etempvar _node (tptr (Tstruct _GraphNodePerspective noattr)))
            (Tstruct _GraphNodePerspective noattr)) _fnNode
          (Tstruct _FnGraphNode noattr)) _func
        (tptr (Tfunction
                (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                 (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                cc_default))))
    (Sifthenelse (Ebinop One
                   (Etempvar _t'14 (tptr (Tfunction
                                           (tint ::
                                            (tptr (Tstruct _GraphNode noattr)) ::
                                            (tptr tvoid) :: nil)
                                           (tptr (Tunion __512 noattr))
                                           cc_default)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Sset _t'15
          (Efield
            (Efield
              (Ederef
                (Etempvar _node (tptr (Tstruct _GraphNodePerspective noattr)))
                (Tstruct _GraphNodePerspective noattr)) _fnNode
              (Tstruct _FnGraphNode noattr)) _func
            (tptr (Tfunction
                    (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                     (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                    cc_default))))
        (Ssequence
          (Sset _t'16 (Evar _gMatStackIndex tshort))
          (Scall None
            (Etempvar _t'15 (tptr (Tfunction
                                    (tint ::
                                     (tptr (Tstruct _GraphNode noattr)) ::
                                     (tptr tvoid) :: nil)
                                    (tptr (Tunion __512 noattr)) cc_default)))
            ((Econst_int (Int.repr 1) tint) ::
             (Eaddrof
               (Efield
                 (Efield
                   (Ederef
                     (Etempvar _node (tptr (Tstruct _GraphNodePerspective noattr)))
                     (Tstruct _GraphNodePerspective noattr)) _fnNode
                   (Tstruct _FnGraphNode noattr)) _node
                 (Tstruct _GraphNode noattr))
               (tptr (Tstruct _GraphNode noattr))) ::
             (Ederef
               (Ebinop Oadd
                 (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                 (Etempvar _t'16 tshort) (tptr (tarray (tarray tfloat 4) 4)))
               (tarray (tarray tfloat 4) 4)) :: nil))))
      Sskip))
  (Ssequence
    (Sset _t'4
      (Efield
        (Efield
          (Efield
            (Ederef
              (Etempvar _node (tptr (Tstruct _GraphNodePerspective noattr)))
              (Tstruct _GraphNodePerspective noattr)) _fnNode
            (Tstruct _FnGraphNode noattr)) _node (Tstruct _GraphNode noattr))
        _children (tptr (Tstruct _GraphNode noattr))))
    (Sifthenelse (Ebinop One
                   (Etempvar _t'4 (tptr (Tstruct _GraphNode noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                        cc_default))
            ((Esizeof (Tunion __472 noattr) tuint) :: nil))
          (Sset _mtx (Etempvar _t'1 (tptr tvoid))))
        (Ssequence
          (Ssequence
            (Sset _t'10
              (Evar _gCurGraphNodeRoot (tptr (Tstruct _GraphNodeRoot noattr))))
            (Ssequence
              (Sset _t'11
                (Efield
                  (Ederef
                    (Etempvar _t'10 (tptr (Tstruct _GraphNodeRoot noattr)))
                    (Tstruct _GraphNodeRoot noattr)) _width tshort))
              (Ssequence
                (Sset _t'12
                  (Evar _gCurGraphNodeRoot (tptr (Tstruct _GraphNodeRoot noattr))))
                (Ssequence
                  (Sset _t'13
                    (Efield
                      (Ederef
                        (Etempvar _t'12 (tptr (Tstruct _GraphNodeRoot noattr)))
                        (Tstruct _GraphNodeRoot noattr)) _height tshort))
                  (Sset _aspect
                    (Ebinop Odiv (Ecast (Etempvar _t'11 tshort) tfloat)
                      (Ecast (Etempvar _t'13 tshort) tfloat) tfloat))))))
          (Ssequence
            (Ssequence
              (Sset _t'7
                (Efield
                  (Ederef
                    (Etempvar _node (tptr (Tstruct _GraphNodePerspective noattr)))
                    (Tstruct _GraphNodePerspective noattr)) _fov tfloat))
              (Ssequence
                (Sset _t'8
                  (Efield
                    (Ederef
                      (Etempvar _node (tptr (Tstruct _GraphNodePerspective noattr)))
                      (Tstruct _GraphNodePerspective noattr)) _near tshort))
                (Ssequence
                  (Sset _t'9
                    (Efield
                      (Ederef
                        (Etempvar _node (tptr (Tstruct _GraphNodePerspective noattr)))
                        (Tstruct _GraphNodePerspective noattr)) _far tshort))
                  (Scall None
                    (Evar _guPerspective (Tfunction
                                           ((tptr (Tunion __472 noattr)) ::
                                            (tptr tushort) :: tfloat ::
                                            tfloat :: tfloat :: tfloat ::
                                            tfloat :: nil) tvoid cc_default))
                    ((Etempvar _mtx (tptr (Tunion __472 noattr))) ::
                     (Eaddrof (Evar _perspNorm tushort) (tptr tushort)) ::
                     (Etempvar _t'7 tfloat) :: (Etempvar _aspect tfloat) ::
                     (Etempvar _t'8 tshort) :: (Etempvar _t'9 tshort) ::
                     (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat) ::
                     nil)))))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'2
                      (Evar _gDisplayListHead (tptr (Tunion __512 noattr))))
                    (Sassign
                      (Evar _gDisplayListHead (tptr (Tunion __512 noattr)))
                      (Ebinop Oadd
                        (Etempvar _t'2 (tptr (Tunion __512 noattr)))
                        (Econst_int (Int.repr 1) tint)
                        (tptr (Tunion __512 noattr)))))
                  (Sset __g
                    (Ecast (Etempvar _t'2 (tptr (Tunion __512 noattr)))
                      (tptr (Tunion __512 noattr)))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef (Etempvar __g (tptr (Tunion __512 noattr)))
                          (Tunion __512 noattr)) _words
                        (Tstruct __510 noattr)) _w0 tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast
                            (Ebinop Osub
                              (Eunop Oneg (Econst_int (Int.repr 65) tint)
                                tint) (Econst_int (Int.repr 11) tint) tint)
                            tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 24) tint) tuint) tuint))
                  (Ssequence
                    (Sset _t'6 (Evar _perspNorm tushort))
                    (Sassign
                      (Efield
                        (Efield
                          (Ederef (Etempvar __g (tptr (Tunion __512 noattr)))
                            (Tunion __512 noattr)) _words
                          (Tstruct __510 noattr)) _w1 tuint)
                      (Etempvar _t'6 tushort)))))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'3
                        (Evar _gDisplayListHead (tptr (Tunion __512 noattr))))
                      (Sassign
                        (Evar _gDisplayListHead (tptr (Tunion __512 noattr)))
                        (Ebinop Oadd
                          (Etempvar _t'3 (tptr (Tunion __512 noattr)))
                          (Econst_int (Int.repr 1) tint)
                          (tptr (Tunion __512 noattr)))))
                    (Sset __g__1
                      (Ecast (Etempvar _t'3 (tptr (Tunion __512 noattr)))
                        (tptr (Tunion __512 noattr)))))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar __g__1 (tptr (Tunion __512 noattr)))
                            (Tunion __512 noattr)) _words
                          (Tstruct __510 noattr)) _w0 tuint)
                      (Ebinop Oor
                        (Ebinop Oor
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast (Econst_int (Int.repr 1) tint) tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 8) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 24) tint) tuint) tuint)
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast
                                  (Ebinop Oor
                                    (Ebinop Oor
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 2) tint) tint)
                                    (Econst_int (Int.repr 0) tint) tint)
                                  tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 8) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 16) tint) tuint) tuint)
                          tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Esizeof (Tunion __472 noattr) tuint)
                                tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 16) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 0) tint) tuint) tuint)
                        tuint))
                    (Sassign
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar __g__1 (tptr (Tunion __512 noattr)))
                            (Tunion __512 noattr)) _words
                          (Tstruct __510 noattr)) _w1 tuint)
                      (Ecast
                        (Ebinop Oand
                          (Ecast (Etempvar _mtx (tptr (Tunion __472 noattr)))
                            tuint) (Econst_int (Int.repr 536870911) tint)
                          tuint) tuint))))
                (Ssequence
                  (Sassign
                    (Evar _gCurGraphNodeCamFrustum (tptr (Tstruct _GraphNodePerspective noattr)))
                    (Etempvar _node (tptr (Tstruct _GraphNodePerspective noattr))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'5
                        (Efield
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _node (tptr (Tstruct _GraphNodePerspective noattr)))
                                (Tstruct _GraphNodePerspective noattr))
                              _fnNode (Tstruct _FnGraphNode noattr)) _node
                            (Tstruct _GraphNode noattr)) _children
                          (tptr (Tstruct _GraphNode noattr))))
                      (Scall None
                        (Evar _geo_process_node_and_siblings (Tfunction
                                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                                nil) tvoid
                                                               cc_default))
                        ((Etempvar _t'5 (tptr (Tstruct _GraphNode noattr))) ::
                         nil)))
                    (Sassign
                      (Evar _gCurGraphNodeCamFrustum (tptr (Tstruct _GraphNodePerspective noattr)))
                      (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))))))))
      Sskip)))
|}.

Definition f_geo_process_level_of_detail := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _GraphNodeLevelOfDetail noattr))) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_mtx, (tptr (Tunion __472 noattr))) ::
               (_distanceFromCam, tshort) :: (_t'1, tint) ::
               (_t'7, tshort) :: (_t'6, tint) :: (_t'5, tshort) ::
               (_t'4, tshort) ::
               (_t'3, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'2, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7 (Evar _gMatStackIndex tshort))
    (Sset _mtx
      (Ederef
        (Ebinop Oadd
          (Evar _gMatStackFixed (tarray (tptr (Tunion __472 noattr)) 32))
          (Etempvar _t'7 tshort) (tptr (tptr (Tunion __472 noattr))))
        (tptr (Tunion __472 noattr)))))
  (Ssequence
    (Ssequence
      (Sset _t'6
        (Ederef
          (Ebinop Oadd
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _mtx (tptr (Tunion __472 noattr)))
                    (Tunion __472 noattr)) _m (tarray (tarray tint 4) 4))
                (Econst_int (Int.repr 1) tint) (tptr (tarray tint 4)))
              (tarray tint 4)) (Econst_int (Int.repr 3) tint) (tptr tint))
          tint))
      (Sset _distanceFromCam
        (Ecast
          (Eunop Oneg
            (Ecast
              (Ebinop Oshr (Etempvar _t'6 tint)
                (Econst_int (Int.repr 16) tint) tint) tshort) tint) tshort)))
    (Ssequence
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef
              (Etempvar _node (tptr (Tstruct _GraphNodeLevelOfDetail noattr)))
              (Tstruct _GraphNodeLevelOfDetail noattr)) _minDistance tshort))
        (Sifthenelse (Ebinop Ole (Etempvar _t'4 tshort)
                       (Etempvar _distanceFromCam tshort) tint)
          (Ssequence
            (Sset _t'5
              (Efield
                (Ederef
                  (Etempvar _node (tptr (Tstruct _GraphNodeLevelOfDetail noattr)))
                  (Tstruct _GraphNodeLevelOfDetail noattr)) _maxDistance
                tshort))
            (Sset _t'1
              (Ecast
                (Ebinop Olt (Etempvar _distanceFromCam tshort)
                  (Etempvar _t'5 tshort) tint) tbool)))
          (Sset _t'1 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'1 tint)
        (Ssequence
          (Sset _t'2
            (Efield
              (Efield
                (Ederef
                  (Etempvar _node (tptr (Tstruct _GraphNodeLevelOfDetail noattr)))
                  (Tstruct _GraphNodeLevelOfDetail noattr)) _node
                (Tstruct _GraphNode noattr)) _children
              (tptr (Tstruct _GraphNode noattr))))
          (Sifthenelse (Ebinop One
                         (Etempvar _t'2 (tptr (Tstruct _GraphNode noattr)))
                         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                         tint)
            (Ssequence
              (Sset _t'3
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _node (tptr (Tstruct _GraphNodeLevelOfDetail noattr)))
                      (Tstruct _GraphNodeLevelOfDetail noattr)) _node
                    (Tstruct _GraphNode noattr)) _children
                  (tptr (Tstruct _GraphNode noattr))))
              (Scall None
                (Evar _geo_process_node_and_siblings (Tfunction
                                                       ((tptr (Tstruct _GraphNode noattr)) ::
                                                        nil) tvoid
                                                       cc_default))
                ((Etempvar _t'3 (tptr (Tstruct _GraphNode noattr))) :: nil)))
            Sskip))
        Sskip))))
|}.

Definition f_geo_process_switch := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _GraphNodeSwitchCase noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_selectedChild, (tptr (Tstruct _GraphNode noattr))) ::
               (_i, tint) :: (_t'1, tint) :: (_t'5, tshort) ::
               (_t'4,
                (tptr (Tfunction
                        (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                         (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                        cc_default))) ::
               (_t'3,
                (tptr (Tfunction
                        (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                         (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                        cc_default))) :: (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _selectedChild
    (Efield
      (Efield
        (Efield
          (Ederef
            (Etempvar _node (tptr (Tstruct _GraphNodeSwitchCase noattr)))
            (Tstruct _GraphNodeSwitchCase noattr)) _fnNode
          (Tstruct _FnGraphNode noattr)) _node (Tstruct _GraphNode noattr))
      _children (tptr (Tstruct _GraphNode noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Efield
          (Efield
            (Ederef
              (Etempvar _node (tptr (Tstruct _GraphNodeSwitchCase noattr)))
              (Tstruct _GraphNodeSwitchCase noattr)) _fnNode
            (Tstruct _FnGraphNode noattr)) _func
          (tptr (Tfunction
                  (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                   (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                  cc_default))))
      (Sifthenelse (Ebinop One
                     (Etempvar _t'3 (tptr (Tfunction
                                            (tint ::
                                             (tptr (Tstruct _GraphNode noattr)) ::
                                             (tptr tvoid) :: nil)
                                            (tptr (Tunion __512 noattr))
                                            cc_default)))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Ssequence
          (Sset _t'4
            (Efield
              (Efield
                (Ederef
                  (Etempvar _node (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                  (Tstruct _GraphNodeSwitchCase noattr)) _fnNode
                (Tstruct _FnGraphNode noattr)) _func
              (tptr (Tfunction
                      (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                       (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                      cc_default))))
          (Ssequence
            (Sset _t'5 (Evar _gMatStackIndex tshort))
            (Scall None
              (Etempvar _t'4 (tptr (Tfunction
                                     (tint ::
                                      (tptr (Tstruct _GraphNode noattr)) ::
                                      (tptr tvoid) :: nil)
                                     (tptr (Tunion __512 noattr)) cc_default)))
              ((Econst_int (Int.repr 1) tint) ::
               (Eaddrof
                 (Efield
                   (Efield
                     (Ederef
                       (Etempvar _node (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                       (Tstruct _GraphNodeSwitchCase noattr)) _fnNode
                     (Tstruct _FnGraphNode noattr)) _node
                   (Tstruct _GraphNode noattr))
                 (tptr (Tstruct _GraphNode noattr))) ::
               (Ederef
                 (Ebinop Oadd
                   (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                   (Etempvar _t'5 tshort)
                   (tptr (tarray (tarray tfloat 4) 4)))
                 (tarray (tarray tfloat 4) 4)) :: nil))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _i (Econst_int (Int.repr 0) tint))
        (Sloop
          (Ssequence
            (Ssequence
              (Sifthenelse (Ebinop One
                             (Etempvar _selectedChild (tptr (Tstruct _GraphNode noattr)))
                             (Ecast (Econst_int (Int.repr 0) tint)
                               (tptr tvoid)) tint)
                (Ssequence
                  (Sset _t'2
                    (Efield
                      (Ederef
                        (Etempvar _node (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                        (Tstruct _GraphNodeSwitchCase noattr)) _selectedCase
                      tshort))
                  (Sset _t'1
                    (Ecast
                      (Ebinop Ogt (Etempvar _t'2 tshort) (Etempvar _i tint)
                        tint) tbool)))
                (Sset _t'1 (Econst_int (Int.repr 0) tint)))
              (Sifthenelse (Etempvar _t'1 tint) Sskip Sbreak))
            (Sset _selectedChild
              (Efield
                (Ederef
                  (Etempvar _selectedChild (tptr (Tstruct _GraphNode noattr)))
                  (Tstruct _GraphNode noattr)) _next
                (tptr (Tstruct _GraphNode noattr)))))
          (Sset _i
            (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint)
              tint))))
      (Sifthenelse (Ebinop One
                     (Etempvar _selectedChild (tptr (Tstruct _GraphNode noattr)))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Scall None
          (Evar _geo_process_node_and_siblings (Tfunction
                                                 ((tptr (Tstruct _GraphNode noattr)) ::
                                                  nil) tvoid cc_default))
          ((Etempvar _selectedChild (tptr (Tstruct _GraphNode noattr))) ::
           nil))
        Sskip))))
|}.

Definition f_geo_process_camera := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _GraphNodeCamera noattr))) :: nil);
  fn_vars := ((_cameraTransform, (tarray (tarray tfloat 4) 4)) :: nil);
  fn_temps := ((_rollMtx, (tptr (Tunion __472 noattr))) ::
               (_mtx, (tptr (Tunion __472 noattr))) ::
               (__g, (tptr (Tunion __512 noattr))) ::
               (_t'3, (tptr (Tunion __512 noattr))) ::
               (_t'2, (tptr tvoid)) :: (_t'1, (tptr tvoid)) ::
               (_t'17, tshort) ::
               (_t'16,
                (tptr (Tfunction
                        (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                         (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                        cc_default))) ::
               (_t'15,
                (tptr (Tfunction
                        (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                         (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                        cc_default))) :: (_t'14, tshort) ::
               (_t'13, tshort) :: (_t'12, tshort) :: (_t'11, tshort) ::
               (_t'10, tshort) :: (_t'9, tshort) :: (_t'8, tshort) ::
               (_t'7, tshort) ::
               (_t'6, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'5, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'4, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                  cc_default))
      ((Esizeof (Tunion __472 noattr) tuint) :: nil))
    (Sset _rollMtx (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Ssequence
      (Scall (Some _t'2)
        (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                    cc_default))
        ((Esizeof (Tunion __472 noattr) tuint) :: nil))
      (Sset _mtx (Etempvar _t'2 (tptr tvoid))))
    (Ssequence
      (Ssequence
        (Sset _t'15
          (Efield
            (Efield
              (Ederef
                (Etempvar _node (tptr (Tstruct _GraphNodeCamera noattr)))
                (Tstruct _GraphNodeCamera noattr)) _fnNode
              (Tstruct _FnGraphNode noattr)) _func
            (tptr (Tfunction
                    (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                     (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                    cc_default))))
        (Sifthenelse (Ebinop One
                       (Etempvar _t'15 (tptr (Tfunction
                                               (tint ::
                                                (tptr (Tstruct _GraphNode noattr)) ::
                                                (tptr tvoid) :: nil)
                                               (tptr (Tunion __512 noattr))
                                               cc_default)))
                       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                       tint)
          (Ssequence
            (Sset _t'16
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _node (tptr (Tstruct _GraphNodeCamera noattr)))
                    (Tstruct _GraphNodeCamera noattr)) _fnNode
                  (Tstruct _FnGraphNode noattr)) _func
                (tptr (Tfunction
                        (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                         (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                        cc_default))))
            (Ssequence
              (Sset _t'17 (Evar _gMatStackIndex tshort))
              (Scall None
                (Etempvar _t'16 (tptr (Tfunction
                                        (tint ::
                                         (tptr (Tstruct _GraphNode noattr)) ::
                                         (tptr tvoid) :: nil)
                                        (tptr (Tunion __512 noattr))
                                        cc_default)))
                ((Econst_int (Int.repr 1) tint) ::
                 (Eaddrof
                   (Efield
                     (Efield
                       (Ederef
                         (Etempvar _node (tptr (Tstruct _GraphNodeCamera noattr)))
                         (Tstruct _GraphNodeCamera noattr)) _fnNode
                       (Tstruct _FnGraphNode noattr)) _node
                     (Tstruct _GraphNode noattr))
                   (tptr (Tstruct _GraphNode noattr))) ::
                 (Ederef
                   (Ebinop Oadd
                     (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                     (Etempvar _t'17 tshort)
                     (tptr (tarray (tarray tfloat 4) 4)))
                   (tarray (tarray tfloat 4) 4)) :: nil))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'14
            (Efield
              (Ederef
                (Etempvar _node (tptr (Tstruct _GraphNodeCamera noattr)))
                (Tstruct _GraphNodeCamera noattr)) _rollScreen tshort))
          (Scall None
            (Evar _mtxf_rotate_xy (Tfunction
                                    ((tptr (Tunion __472 noattr)) ::
                                     tshort :: nil) tvoid cc_default))
            ((Etempvar _rollMtx (tptr (Tunion __472 noattr))) ::
             (Etempvar _t'14 tshort) :: nil)))
        (Ssequence
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'3
                  (Evar _gDisplayListHead (tptr (Tunion __512 noattr))))
                (Sassign
                  (Evar _gDisplayListHead (tptr (Tunion __512 noattr)))
                  (Ebinop Oadd (Etempvar _t'3 (tptr (Tunion __512 noattr)))
                    (Econst_int (Int.repr 1) tint)
                    (tptr (Tunion __512 noattr)))))
              (Sset __g
                (Ecast (Etempvar _t'3 (tptr (Tunion __512 noattr)))
                  (tptr (Tunion __512 noattr)))))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g (tptr (Tunion __512 noattr)))
                      (Tunion __512 noattr)) _words (Tstruct __510 noattr))
                  _w0 tuint)
                (Ebinop Oor
                  (Ebinop Oor
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 1) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 24) tint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast
                            (Ebinop Oor
                              (Ebinop Oor (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 0) tint) tint)
                              (Econst_int (Int.repr 0) tint) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 16) tint) tuint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Esizeof (Tunion __472 noattr) tuint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 16) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g (tptr (Tunion __512 noattr)))
                      (Tunion __512 noattr)) _words (Tstruct __510 noattr))
                  _w1 tuint)
                (Ecast
                  (Ebinop Oand
                    (Ecast (Etempvar _rollMtx (tptr (Tunion __472 noattr)))
                      tuint) (Econst_int (Int.repr 536870911) tint) tuint)
                  tuint))))
          (Ssequence
            (Ssequence
              (Sset _t'13
                (Efield
                  (Ederef
                    (Etempvar _node (tptr (Tstruct _GraphNodeCamera noattr)))
                    (Tstruct _GraphNodeCamera noattr)) _roll tshort))
              (Scall None
                (Evar _mtxf_lookat (Tfunction
                                     ((tptr (tarray tfloat 4)) ::
                                      (tptr tfloat) :: (tptr tfloat) ::
                                      tshort :: nil) tvoid cc_default))
                ((Evar _cameraTransform (tarray (tarray tfloat 4) 4)) ::
                 (Efield
                   (Ederef
                     (Etempvar _node (tptr (Tstruct _GraphNodeCamera noattr)))
                     (Tstruct _GraphNodeCamera noattr)) _pos
                   (tarray tfloat 3)) ::
                 (Efield
                   (Ederef
                     (Etempvar _node (tptr (Tstruct _GraphNodeCamera noattr)))
                     (Tstruct _GraphNodeCamera noattr)) _focus
                   (tarray tfloat 3)) :: (Etempvar _t'13 tshort) :: nil)))
            (Ssequence
              (Ssequence
                (Sset _t'11 (Evar _gMatStackIndex tshort))
                (Ssequence
                  (Sset _t'12 (Evar _gMatStackIndex tshort))
                  (Scall None
                    (Evar _mtxf_mul (Tfunction
                                      ((tptr (tarray tfloat 4)) ::
                                       (tptr (tarray tfloat 4)) ::
                                       (tptr (tarray tfloat 4)) :: nil) tvoid
                                      cc_default))
                    ((Ederef
                       (Ebinop Oadd
                         (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                         (Ebinop Oadd (Etempvar _t'11 tshort)
                           (Econst_int (Int.repr 1) tint) tint)
                         (tptr (tarray (tarray tfloat 4) 4)))
                       (tarray (tarray tfloat 4) 4)) ::
                     (Evar _cameraTransform (tarray (tarray tfloat 4) 4)) ::
                     (Ederef
                       (Ebinop Oadd
                         (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                         (Etempvar _t'12 tshort)
                         (tptr (tarray (tarray tfloat 4) 4)))
                       (tarray (tarray tfloat 4) 4)) :: nil))))
              (Ssequence
                (Ssequence
                  (Sset _t'10 (Evar _gMatStackIndex tshort))
                  (Sassign (Evar _gMatStackIndex tshort)
                    (Ebinop Oadd (Etempvar _t'10 tshort)
                      (Econst_int (Int.repr 1) tint) tint)))
                (Ssequence
                  (Ssequence
                    (Sset _t'9 (Evar _gMatStackIndex tshort))
                    (Scall None
                      (Evar _mtxf_to_mtx (Tfunction
                                           ((tptr (Tunion __472 noattr)) ::
                                            (tptr (tarray tfloat 4)) :: nil)
                                           tvoid cc_default))
                      ((Etempvar _mtx (tptr (Tunion __472 noattr))) ::
                       (Ederef
                         (Ebinop Oadd
                           (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                           (Etempvar _t'9 tshort)
                           (tptr (tarray (tarray tfloat 4) 4)))
                         (tarray (tarray tfloat 4) 4)) :: nil)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'8 (Evar _gMatStackIndex tshort))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Evar _gMatStackFixed (tarray (tptr (Tunion __472 noattr)) 32))
                            (Etempvar _t'8 tshort)
                            (tptr (tptr (Tunion __472 noattr))))
                          (tptr (Tunion __472 noattr)))
                        (Etempvar _mtx (tptr (Tunion __472 noattr)))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'5
                          (Efield
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _node (tptr (Tstruct _GraphNodeCamera noattr)))
                                  (Tstruct _GraphNodeCamera noattr)) _fnNode
                                (Tstruct _FnGraphNode noattr)) _node
                              (Tstruct _GraphNode noattr)) _children
                            (tptr (Tstruct _GraphNode noattr))))
                        (Sifthenelse (Ebinop One
                                       (Etempvar _t'5 (tptr (Tstruct _GraphNode noattr)))
                                       (Ecast (Econst_int (Int.repr 0) tint)
                                         (tptr tvoid)) tint)
                          (Ssequence
                            (Sassign
                              (Evar _gCurGraphNodeCamera (tptr (Tstruct _GraphNodeCamera noattr)))
                              (Etempvar _node (tptr (Tstruct _GraphNodeCamera noattr))))
                            (Ssequence
                              (Ssequence
                                (Sset _t'7 (Evar _gMatStackIndex tshort))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _node (tptr (Tstruct _GraphNodeCamera noattr)))
                                      (Tstruct _GraphNodeCamera noattr))
                                    _matrixPtr
                                    (tptr (tarray (tarray tfloat 4) 4)))
                                  (Ebinop Oadd
                                    (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                    (Etempvar _t'7 tshort)
                                    (tptr (tarray (tarray tfloat 4) 4)))))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'6
                                    (Efield
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _node (tptr (Tstruct _GraphNodeCamera noattr)))
                                            (Tstruct _GraphNodeCamera noattr))
                                          _fnNode
                                          (Tstruct _FnGraphNode noattr))
                                        _node (Tstruct _GraphNode noattr))
                                      _children
                                      (tptr (Tstruct _GraphNode noattr))))
                                  (Scall None
                                    (Evar _geo_process_node_and_siblings 
                                    (Tfunction
                                      ((tptr (Tstruct _GraphNode noattr)) ::
                                       nil) tvoid cc_default))
                                    ((Etempvar _t'6 (tptr (Tstruct _GraphNode noattr))) ::
                                     nil)))
                                (Sassign
                                  (Evar _gCurGraphNodeCamera (tptr (Tstruct _GraphNodeCamera noattr)))
                                  (Ecast (Econst_int (Int.repr 0) tint)
                                    (tptr tvoid))))))
                          Sskip))
                      (Ssequence
                        (Sset _t'4 (Evar _gMatStackIndex tshort))
                        (Sassign (Evar _gMatStackIndex tshort)
                          (Ebinop Osub (Etempvar _t'4 tshort)
                            (Econst_int (Int.repr 1) tint) tint))))))))))))))
|}.

Definition f_geo_process_translation_rotation := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_node,
                 (tptr (Tstruct _GraphNodeTranslationRotation noattr))) ::
                nil);
  fn_vars := ((_mtxf, (tarray (tarray tfloat 4) 4)) ::
              (_translation, (tarray tfloat 3)) :: nil);
  fn_temps := ((_mtx, (tptr (Tunion __472 noattr))) ::
               (_t'1, (tptr tvoid)) :: (_t'12, tshort) :: (_t'11, tshort) ::
               (_t'10, tshort) :: (_t'9, tshort) :: (_t'8, tshort) ::
               (_t'7, tshort) :: (_t'6, (tptr tvoid)) ::
               (_t'5, (tptr tvoid)) ::
               (_t'4, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'3, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                  cc_default))
      ((Esizeof (Tunion __472 noattr) tuint) :: nil))
    (Sset _mtx (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Scall None
      (Evar _vec3s_to_vec3f (Tfunction
                              ((tptr tfloat) :: (tptr tshort) :: nil)
                              (tptr tvoid) cc_default))
      ((Evar _translation (tarray tfloat 3)) ::
       (Efield
         (Ederef
           (Etempvar _node (tptr (Tstruct _GraphNodeTranslationRotation noattr)))
           (Tstruct _GraphNodeTranslationRotation noattr)) _translation
         (tarray tshort 3)) :: nil))
    (Ssequence
      (Scall None
        (Evar _mtxf_rotate_zxy_and_translate (Tfunction
                                               ((tptr (tarray tfloat 4)) ::
                                                (tptr tfloat) ::
                                                (tptr tshort) :: nil) tvoid
                                               cc_default))
        ((Evar _mtxf (tarray (tarray tfloat 4) 4)) ::
         (Evar _translation (tarray tfloat 3)) ::
         (Efield
           (Ederef
             (Etempvar _node (tptr (Tstruct _GraphNodeTranslationRotation noattr)))
             (Tstruct _GraphNodeTranslationRotation noattr)) _rotation
           (tarray tshort 3)) :: nil))
      (Ssequence
        (Ssequence
          (Sset _t'11 (Evar _gMatStackIndex tshort))
          (Ssequence
            (Sset _t'12 (Evar _gMatStackIndex tshort))
            (Scall None
              (Evar _mtxf_mul (Tfunction
                                ((tptr (tarray tfloat 4)) ::
                                 (tptr (tarray tfloat 4)) ::
                                 (tptr (tarray tfloat 4)) :: nil) tvoid
                                cc_default))
              ((Ederef
                 (Ebinop Oadd
                   (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                   (Ebinop Oadd (Etempvar _t'11 tshort)
                     (Econst_int (Int.repr 1) tint) tint)
                   (tptr (tarray (tarray tfloat 4) 4)))
                 (tarray (tarray tfloat 4) 4)) ::
               (Evar _mtxf (tarray (tarray tfloat 4) 4)) ::
               (Ederef
                 (Ebinop Oadd
                   (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                   (Etempvar _t'12 tshort)
                   (tptr (tarray (tarray tfloat 4) 4)))
                 (tarray (tarray tfloat 4) 4)) :: nil))))
        (Ssequence
          (Ssequence
            (Sset _t'10 (Evar _gMatStackIndex tshort))
            (Sassign (Evar _gMatStackIndex tshort)
              (Ebinop Oadd (Etempvar _t'10 tshort)
                (Econst_int (Int.repr 1) tint) tint)))
          (Ssequence
            (Ssequence
              (Sset _t'9 (Evar _gMatStackIndex tshort))
              (Scall None
                (Evar _mtxf_to_mtx (Tfunction
                                     ((tptr (Tunion __472 noattr)) ::
                                      (tptr (tarray tfloat 4)) :: nil) tvoid
                                     cc_default))
                ((Etempvar _mtx (tptr (Tunion __472 noattr))) ::
                 (Ederef
                   (Ebinop Oadd
                     (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                     (Etempvar _t'9 tshort)
                     (tptr (tarray (tarray tfloat 4) 4)))
                   (tarray (tarray tfloat 4) 4)) :: nil)))
            (Ssequence
              (Ssequence
                (Sset _t'8 (Evar _gMatStackIndex tshort))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Evar _gMatStackFixed (tarray (tptr (Tunion __472 noattr)) 32))
                      (Etempvar _t'8 tshort)
                      (tptr (tptr (Tunion __472 noattr))))
                    (tptr (Tunion __472 noattr)))
                  (Etempvar _mtx (tptr (Tunion __472 noattr)))))
              (Ssequence
                (Ssequence
                  (Sset _t'5
                    (Efield
                      (Ederef
                        (Etempvar _node (tptr (Tstruct _GraphNodeTranslationRotation noattr)))
                        (Tstruct _GraphNodeTranslationRotation noattr))
                      _displayList (tptr tvoid)))
                  (Sifthenelse (Ebinop One (Etempvar _t'5 (tptr tvoid))
                                 (Ecast (Econst_int (Int.repr 0) tint)
                                   (tptr tvoid)) tint)
                    (Ssequence
                      (Sset _t'6
                        (Efield
                          (Ederef
                            (Etempvar _node (tptr (Tstruct _GraphNodeTranslationRotation noattr)))
                            (Tstruct _GraphNodeTranslationRotation noattr))
                          _displayList (tptr tvoid)))
                      (Ssequence
                        (Sset _t'7
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _node (tptr (Tstruct _GraphNodeTranslationRotation noattr)))
                                (Tstruct _GraphNodeTranslationRotation noattr))
                              _node (Tstruct _GraphNode noattr)) _flags
                            tshort))
                        (Scall None
                          (Evar _geo_append_display_list (Tfunction
                                                           ((tptr tvoid) ::
                                                            tshort :: nil)
                                                           tvoid cc_default))
                          ((Etempvar _t'6 (tptr tvoid)) ::
                           (Ebinop Oshr (Etempvar _t'7 tshort)
                             (Econst_int (Int.repr 8) tint) tint) :: nil))))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sset _t'3
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _node (tptr (Tstruct _GraphNodeTranslationRotation noattr)))
                            (Tstruct _GraphNodeTranslationRotation noattr))
                          _node (Tstruct _GraphNode noattr)) _children
                        (tptr (Tstruct _GraphNode noattr))))
                    (Sifthenelse (Ebinop One
                                   (Etempvar _t'3 (tptr (Tstruct _GraphNode noattr)))
                                   (Ecast (Econst_int (Int.repr 0) tint)
                                     (tptr tvoid)) tint)
                      (Ssequence
                        (Sset _t'4
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _node (tptr (Tstruct _GraphNodeTranslationRotation noattr)))
                                (Tstruct _GraphNodeTranslationRotation noattr))
                              _node (Tstruct _GraphNode noattr)) _children
                            (tptr (Tstruct _GraphNode noattr))))
                        (Scall None
                          (Evar _geo_process_node_and_siblings (Tfunction
                                                                 ((tptr (Tstruct _GraphNode noattr)) ::
                                                                  nil) tvoid
                                                                 cc_default))
                          ((Etempvar _t'4 (tptr (Tstruct _GraphNode noattr))) ::
                           nil)))
                      Sskip))
                  (Ssequence
                    (Sset _t'2 (Evar _gMatStackIndex tshort))
                    (Sassign (Evar _gMatStackIndex tshort)
                      (Ebinop Osub (Etempvar _t'2 tshort)
                        (Econst_int (Int.repr 1) tint) tint))))))))))))
|}.

Definition f_geo_process_translation := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _GraphNodeTranslation noattr))) ::
                nil);
  fn_vars := ((_mtxf, (tarray (tarray tfloat 4) 4)) ::
              (_translation, (tarray tfloat 3)) :: nil);
  fn_temps := ((_mtx, (tptr (Tunion __472 noattr))) ::
               (_t'1, (tptr tvoid)) :: (_t'12, tshort) :: (_t'11, tshort) ::
               (_t'10, tshort) :: (_t'9, tshort) :: (_t'8, tshort) ::
               (_t'7, tshort) :: (_t'6, (tptr tvoid)) ::
               (_t'5, (tptr tvoid)) ::
               (_t'4, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'3, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                  cc_default))
      ((Esizeof (Tunion __472 noattr) tuint) :: nil))
    (Sset _mtx (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Scall None
      (Evar _vec3s_to_vec3f (Tfunction
                              ((tptr tfloat) :: (tptr tshort) :: nil)
                              (tptr tvoid) cc_default))
      ((Evar _translation (tarray tfloat 3)) ::
       (Efield
         (Ederef
           (Etempvar _node (tptr (Tstruct _GraphNodeTranslation noattr)))
           (Tstruct _GraphNodeTranslation noattr)) _translation
         (tarray tshort 3)) :: nil))
    (Ssequence
      (Scall None
        (Evar _mtxf_rotate_zxy_and_translate (Tfunction
                                               ((tptr (tarray tfloat 4)) ::
                                                (tptr tfloat) ::
                                                (tptr tshort) :: nil) tvoid
                                               cc_default))
        ((Evar _mtxf (tarray (tarray tfloat 4) 4)) ::
         (Evar _translation (tarray tfloat 3)) ::
         (Evar _gVec3sZero (tarray tshort 3)) :: nil))
      (Ssequence
        (Ssequence
          (Sset _t'11 (Evar _gMatStackIndex tshort))
          (Ssequence
            (Sset _t'12 (Evar _gMatStackIndex tshort))
            (Scall None
              (Evar _mtxf_mul (Tfunction
                                ((tptr (tarray tfloat 4)) ::
                                 (tptr (tarray tfloat 4)) ::
                                 (tptr (tarray tfloat 4)) :: nil) tvoid
                                cc_default))
              ((Ederef
                 (Ebinop Oadd
                   (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                   (Ebinop Oadd (Etempvar _t'11 tshort)
                     (Econst_int (Int.repr 1) tint) tint)
                   (tptr (tarray (tarray tfloat 4) 4)))
                 (tarray (tarray tfloat 4) 4)) ::
               (Evar _mtxf (tarray (tarray tfloat 4) 4)) ::
               (Ederef
                 (Ebinop Oadd
                   (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                   (Etempvar _t'12 tshort)
                   (tptr (tarray (tarray tfloat 4) 4)))
                 (tarray (tarray tfloat 4) 4)) :: nil))))
        (Ssequence
          (Ssequence
            (Sset _t'10 (Evar _gMatStackIndex tshort))
            (Sassign (Evar _gMatStackIndex tshort)
              (Ebinop Oadd (Etempvar _t'10 tshort)
                (Econst_int (Int.repr 1) tint) tint)))
          (Ssequence
            (Ssequence
              (Sset _t'9 (Evar _gMatStackIndex tshort))
              (Scall None
                (Evar _mtxf_to_mtx (Tfunction
                                     ((tptr (Tunion __472 noattr)) ::
                                      (tptr (tarray tfloat 4)) :: nil) tvoid
                                     cc_default))
                ((Etempvar _mtx (tptr (Tunion __472 noattr))) ::
                 (Ederef
                   (Ebinop Oadd
                     (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                     (Etempvar _t'9 tshort)
                     (tptr (tarray (tarray tfloat 4) 4)))
                   (tarray (tarray tfloat 4) 4)) :: nil)))
            (Ssequence
              (Ssequence
                (Sset _t'8 (Evar _gMatStackIndex tshort))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Evar _gMatStackFixed (tarray (tptr (Tunion __472 noattr)) 32))
                      (Etempvar _t'8 tshort)
                      (tptr (tptr (Tunion __472 noattr))))
                    (tptr (Tunion __472 noattr)))
                  (Etempvar _mtx (tptr (Tunion __472 noattr)))))
              (Ssequence
                (Ssequence
                  (Sset _t'5
                    (Efield
                      (Ederef
                        (Etempvar _node (tptr (Tstruct _GraphNodeTranslation noattr)))
                        (Tstruct _GraphNodeTranslation noattr)) _displayList
                      (tptr tvoid)))
                  (Sifthenelse (Ebinop One (Etempvar _t'5 (tptr tvoid))
                                 (Ecast (Econst_int (Int.repr 0) tint)
                                   (tptr tvoid)) tint)
                    (Ssequence
                      (Sset _t'6
                        (Efield
                          (Ederef
                            (Etempvar _node (tptr (Tstruct _GraphNodeTranslation noattr)))
                            (Tstruct _GraphNodeTranslation noattr))
                          _displayList (tptr tvoid)))
                      (Ssequence
                        (Sset _t'7
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _node (tptr (Tstruct _GraphNodeTranslation noattr)))
                                (Tstruct _GraphNodeTranslation noattr)) _node
                              (Tstruct _GraphNode noattr)) _flags tshort))
                        (Scall None
                          (Evar _geo_append_display_list (Tfunction
                                                           ((tptr tvoid) ::
                                                            tshort :: nil)
                                                           tvoid cc_default))
                          ((Etempvar _t'6 (tptr tvoid)) ::
                           (Ebinop Oshr (Etempvar _t'7 tshort)
                             (Econst_int (Int.repr 8) tint) tint) :: nil))))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sset _t'3
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _node (tptr (Tstruct _GraphNodeTranslation noattr)))
                            (Tstruct _GraphNodeTranslation noattr)) _node
                          (Tstruct _GraphNode noattr)) _children
                        (tptr (Tstruct _GraphNode noattr))))
                    (Sifthenelse (Ebinop One
                                   (Etempvar _t'3 (tptr (Tstruct _GraphNode noattr)))
                                   (Ecast (Econst_int (Int.repr 0) tint)
                                     (tptr tvoid)) tint)
                      (Ssequence
                        (Sset _t'4
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _node (tptr (Tstruct _GraphNodeTranslation noattr)))
                                (Tstruct _GraphNodeTranslation noattr)) _node
                              (Tstruct _GraphNode noattr)) _children
                            (tptr (Tstruct _GraphNode noattr))))
                        (Scall None
                          (Evar _geo_process_node_and_siblings (Tfunction
                                                                 ((tptr (Tstruct _GraphNode noattr)) ::
                                                                  nil) tvoid
                                                                 cc_default))
                          ((Etempvar _t'4 (tptr (Tstruct _GraphNode noattr))) ::
                           nil)))
                      Sskip))
                  (Ssequence
                    (Sset _t'2 (Evar _gMatStackIndex tshort))
                    (Sassign (Evar _gMatStackIndex tshort)
                      (Ebinop Osub (Etempvar _t'2 tshort)
                        (Econst_int (Int.repr 1) tint) tint))))))))))))
|}.

Definition f_geo_process_rotation := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _GraphNodeRotation noattr))) :: nil);
  fn_vars := ((_mtxf, (tarray (tarray tfloat 4) 4)) :: nil);
  fn_temps := ((_mtx, (tptr (Tunion __472 noattr))) ::
               (_t'1, (tptr tvoid)) :: (_t'12, tshort) :: (_t'11, tshort) ::
               (_t'10, tshort) :: (_t'9, tshort) :: (_t'8, tshort) ::
               (_t'7, tshort) :: (_t'6, (tptr tvoid)) ::
               (_t'5, (tptr tvoid)) ::
               (_t'4, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'3, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                  cc_default))
      ((Esizeof (Tunion __472 noattr) tuint) :: nil))
    (Sset _mtx (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Scall None
      (Evar _mtxf_rotate_zxy_and_translate (Tfunction
                                             ((tptr (tarray tfloat 4)) ::
                                              (tptr tfloat) ::
                                              (tptr tshort) :: nil) tvoid
                                             cc_default))
      ((Evar _mtxf (tarray (tarray tfloat 4) 4)) ::
       (Evar _gVec3fZero (tarray tfloat 3)) ::
       (Efield
         (Ederef (Etempvar _node (tptr (Tstruct _GraphNodeRotation noattr)))
           (Tstruct _GraphNodeRotation noattr)) _rotation (tarray tshort 3)) ::
       nil))
    (Ssequence
      (Ssequence
        (Sset _t'11 (Evar _gMatStackIndex tshort))
        (Ssequence
          (Sset _t'12 (Evar _gMatStackIndex tshort))
          (Scall None
            (Evar _mtxf_mul (Tfunction
                              ((tptr (tarray tfloat 4)) ::
                               (tptr (tarray tfloat 4)) ::
                               (tptr (tarray tfloat 4)) :: nil) tvoid
                              cc_default))
            ((Ederef
               (Ebinop Oadd
                 (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                 (Ebinop Oadd (Etempvar _t'11 tshort)
                   (Econst_int (Int.repr 1) tint) tint)
                 (tptr (tarray (tarray tfloat 4) 4)))
               (tarray (tarray tfloat 4) 4)) ::
             (Evar _mtxf (tarray (tarray tfloat 4) 4)) ::
             (Ederef
               (Ebinop Oadd
                 (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                 (Etempvar _t'12 tshort) (tptr (tarray (tarray tfloat 4) 4)))
               (tarray (tarray tfloat 4) 4)) :: nil))))
      (Ssequence
        (Ssequence
          (Sset _t'10 (Evar _gMatStackIndex tshort))
          (Sassign (Evar _gMatStackIndex tshort)
            (Ebinop Oadd (Etempvar _t'10 tshort)
              (Econst_int (Int.repr 1) tint) tint)))
        (Ssequence
          (Ssequence
            (Sset _t'9 (Evar _gMatStackIndex tshort))
            (Scall None
              (Evar _mtxf_to_mtx (Tfunction
                                   ((tptr (Tunion __472 noattr)) ::
                                    (tptr (tarray tfloat 4)) :: nil) tvoid
                                   cc_default))
              ((Etempvar _mtx (tptr (Tunion __472 noattr))) ::
               (Ederef
                 (Ebinop Oadd
                   (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                   (Etempvar _t'9 tshort)
                   (tptr (tarray (tarray tfloat 4) 4)))
                 (tarray (tarray tfloat 4) 4)) :: nil)))
          (Ssequence
            (Ssequence
              (Sset _t'8 (Evar _gMatStackIndex tshort))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Evar _gMatStackFixed (tarray (tptr (Tunion __472 noattr)) 32))
                    (Etempvar _t'8 tshort)
                    (tptr (tptr (Tunion __472 noattr))))
                  (tptr (Tunion __472 noattr)))
                (Etempvar _mtx (tptr (Tunion __472 noattr)))))
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef
                      (Etempvar _node (tptr (Tstruct _GraphNodeRotation noattr)))
                      (Tstruct _GraphNodeRotation noattr)) _displayList
                    (tptr tvoid)))
                (Sifthenelse (Ebinop One (Etempvar _t'5 (tptr tvoid))
                               (Ecast (Econst_int (Int.repr 0) tint)
                                 (tptr tvoid)) tint)
                  (Ssequence
                    (Sset _t'6
                      (Efield
                        (Ederef
                          (Etempvar _node (tptr (Tstruct _GraphNodeRotation noattr)))
                          (Tstruct _GraphNodeRotation noattr)) _displayList
                        (tptr tvoid)))
                    (Ssequence
                      (Sset _t'7
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _node (tptr (Tstruct _GraphNodeRotation noattr)))
                              (Tstruct _GraphNodeRotation noattr)) _node
                            (Tstruct _GraphNode noattr)) _flags tshort))
                      (Scall None
                        (Evar _geo_append_display_list (Tfunction
                                                         ((tptr tvoid) ::
                                                          tshort :: nil)
                                                         tvoid cc_default))
                        ((Etempvar _t'6 (tptr tvoid)) ::
                         (Ebinop Oshr (Etempvar _t'7 tshort)
                           (Econst_int (Int.repr 8) tint) tint) :: nil))))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _t'3
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _node (tptr (Tstruct _GraphNodeRotation noattr)))
                          (Tstruct _GraphNodeRotation noattr)) _node
                        (Tstruct _GraphNode noattr)) _children
                      (tptr (Tstruct _GraphNode noattr))))
                  (Sifthenelse (Ebinop One
                                 (Etempvar _t'3 (tptr (Tstruct _GraphNode noattr)))
                                 (Ecast (Econst_int (Int.repr 0) tint)
                                   (tptr tvoid)) tint)
                    (Ssequence
                      (Sset _t'4
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _node (tptr (Tstruct _GraphNodeRotation noattr)))
                              (Tstruct _GraphNodeRotation noattr)) _node
                            (Tstruct _GraphNode noattr)) _children
                          (tptr (Tstruct _GraphNode noattr))))
                      (Scall None
                        (Evar _geo_process_node_and_siblings (Tfunction
                                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                                nil) tvoid
                                                               cc_default))
                        ((Etempvar _t'4 (tptr (Tstruct _GraphNode noattr))) ::
                         nil)))
                    Sskip))
                (Ssequence
                  (Sset _t'2 (Evar _gMatStackIndex tshort))
                  (Sassign (Evar _gMatStackIndex tshort)
                    (Ebinop Osub (Etempvar _t'2 tshort)
                      (Econst_int (Int.repr 1) tint) tint)))))))))))
|}.

Definition f_geo_process_scale := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _GraphNodeScale noattr))) :: nil);
  fn_vars := ((_transform, (tarray (tarray tfloat 4) 4)) ::
              (_scaleVec, (tarray tfloat 3)) :: nil);
  fn_temps := ((_mtx, (tptr (Tunion __472 noattr))) ::
               (_t'1, (tptr tvoid)) :: (_t'15, tfloat) :: (_t'14, tfloat) ::
               (_t'13, tfloat) :: (_t'12, tshort) :: (_t'11, tshort) ::
               (_t'10, tshort) :: (_t'9, tshort) :: (_t'8, tshort) ::
               (_t'7, tshort) :: (_t'6, (tptr tvoid)) ::
               (_t'5, (tptr tvoid)) ::
               (_t'4, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'3, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                  cc_default))
      ((Esizeof (Tunion __472 noattr) tuint) :: nil))
    (Sset _mtx (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Ssequence
      (Sset _t'13
        (Efield
          (Ederef (Etempvar _node (tptr (Tstruct _GraphNodeScale noattr)))
            (Tstruct _GraphNodeScale noattr)) _scale tfloat))
      (Ssequence
        (Sset _t'14
          (Efield
            (Ederef (Etempvar _node (tptr (Tstruct _GraphNodeScale noattr)))
              (Tstruct _GraphNodeScale noattr)) _scale tfloat))
        (Ssequence
          (Sset _t'15
            (Efield
              (Ederef
                (Etempvar _node (tptr (Tstruct _GraphNodeScale noattr)))
                (Tstruct _GraphNodeScale noattr)) _scale tfloat))
          (Scall None
            (Evar _vec3f_set (Tfunction
                               ((tptr tfloat) :: tfloat :: tfloat ::
                                tfloat :: nil) (tptr tvoid) cc_default))
            ((Evar _scaleVec (tarray tfloat 3)) :: (Etempvar _t'13 tfloat) ::
             (Etempvar _t'14 tfloat) :: (Etempvar _t'15 tfloat) :: nil)))))
    (Ssequence
      (Ssequence
        (Sset _t'11 (Evar _gMatStackIndex tshort))
        (Ssequence
          (Sset _t'12 (Evar _gMatStackIndex tshort))
          (Scall None
            (Evar _mtxf_scale_vec3f (Tfunction
                                      ((tptr (tarray tfloat 4)) ::
                                       (tptr (tarray tfloat 4)) ::
                                       (tptr tfloat) :: nil) tvoid
                                      cc_default))
            ((Ederef
               (Ebinop Oadd
                 (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                 (Ebinop Oadd (Etempvar _t'11 tshort)
                   (Econst_int (Int.repr 1) tint) tint)
                 (tptr (tarray (tarray tfloat 4) 4)))
               (tarray (tarray tfloat 4) 4)) ::
             (Ederef
               (Ebinop Oadd
                 (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                 (Etempvar _t'12 tshort) (tptr (tarray (tarray tfloat 4) 4)))
               (tarray (tarray tfloat 4) 4)) ::
             (Evar _scaleVec (tarray tfloat 3)) :: nil))))
      (Ssequence
        (Ssequence
          (Sset _t'10 (Evar _gMatStackIndex tshort))
          (Sassign (Evar _gMatStackIndex tshort)
            (Ebinop Oadd (Etempvar _t'10 tshort)
              (Econst_int (Int.repr 1) tint) tint)))
        (Ssequence
          (Ssequence
            (Sset _t'9 (Evar _gMatStackIndex tshort))
            (Scall None
              (Evar _mtxf_to_mtx (Tfunction
                                   ((tptr (Tunion __472 noattr)) ::
                                    (tptr (tarray tfloat 4)) :: nil) tvoid
                                   cc_default))
              ((Etempvar _mtx (tptr (Tunion __472 noattr))) ::
               (Ederef
                 (Ebinop Oadd
                   (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                   (Etempvar _t'9 tshort)
                   (tptr (tarray (tarray tfloat 4) 4)))
                 (tarray (tarray tfloat 4) 4)) :: nil)))
          (Ssequence
            (Ssequence
              (Sset _t'8 (Evar _gMatStackIndex tshort))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Evar _gMatStackFixed (tarray (tptr (Tunion __472 noattr)) 32))
                    (Etempvar _t'8 tshort)
                    (tptr (tptr (Tunion __472 noattr))))
                  (tptr (Tunion __472 noattr)))
                (Etempvar _mtx (tptr (Tunion __472 noattr)))))
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef
                      (Etempvar _node (tptr (Tstruct _GraphNodeScale noattr)))
                      (Tstruct _GraphNodeScale noattr)) _displayList
                    (tptr tvoid)))
                (Sifthenelse (Ebinop One (Etempvar _t'5 (tptr tvoid))
                               (Ecast (Econst_int (Int.repr 0) tint)
                                 (tptr tvoid)) tint)
                  (Ssequence
                    (Sset _t'6
                      (Efield
                        (Ederef
                          (Etempvar _node (tptr (Tstruct _GraphNodeScale noattr)))
                          (Tstruct _GraphNodeScale noattr)) _displayList
                        (tptr tvoid)))
                    (Ssequence
                      (Sset _t'7
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _node (tptr (Tstruct _GraphNodeScale noattr)))
                              (Tstruct _GraphNodeScale noattr)) _node
                            (Tstruct _GraphNode noattr)) _flags tshort))
                      (Scall None
                        (Evar _geo_append_display_list (Tfunction
                                                         ((tptr tvoid) ::
                                                          tshort :: nil)
                                                         tvoid cc_default))
                        ((Etempvar _t'6 (tptr tvoid)) ::
                         (Ebinop Oshr (Etempvar _t'7 tshort)
                           (Econst_int (Int.repr 8) tint) tint) :: nil))))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _t'3
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _node (tptr (Tstruct _GraphNodeScale noattr)))
                          (Tstruct _GraphNodeScale noattr)) _node
                        (Tstruct _GraphNode noattr)) _children
                      (tptr (Tstruct _GraphNode noattr))))
                  (Sifthenelse (Ebinop One
                                 (Etempvar _t'3 (tptr (Tstruct _GraphNode noattr)))
                                 (Ecast (Econst_int (Int.repr 0) tint)
                                   (tptr tvoid)) tint)
                    (Ssequence
                      (Sset _t'4
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _node (tptr (Tstruct _GraphNodeScale noattr)))
                              (Tstruct _GraphNodeScale noattr)) _node
                            (Tstruct _GraphNode noattr)) _children
                          (tptr (Tstruct _GraphNode noattr))))
                      (Scall None
                        (Evar _geo_process_node_and_siblings (Tfunction
                                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                                nil) tvoid
                                                               cc_default))
                        ((Etempvar _t'4 (tptr (Tstruct _GraphNode noattr))) ::
                         nil)))
                    Sskip))
                (Ssequence
                  (Sset _t'2 (Evar _gMatStackIndex tshort))
                  (Sassign (Evar _gMatStackIndex tshort)
                    (Ebinop Osub (Etempvar _t'2 tshort)
                      (Econst_int (Int.repr 1) tint) tint)))))))))))
|}.

Definition f_geo_process_billboard := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _GraphNodeBillboard noattr))) :: nil);
  fn_vars := ((_translation, (tarray tfloat 3)) :: nil);
  fn_temps := ((_mtx, (tptr (Tunion __472 noattr))) ::
               (_t'1, (tptr tvoid)) :: (_t'23, tshort) :: (_t'22, tshort) ::
               (_t'21, (tptr (Tstruct _GraphNodeCamera noattr))) ::
               (_t'20, tshort) :: (_t'19, tshort) ::
               (_t'18, (tptr (Tstruct _Object noattr))) ::
               (_t'17, (tptr (Tstruct _GraphNodeHeldObject noattr))) ::
               (_t'16, tshort) :: (_t'15, tshort) ::
               (_t'14, (tptr (Tstruct _GraphNodeObject noattr))) ::
               (_t'13, tshort) :: (_t'12, tshort) ::
               (_t'11, (tptr (Tstruct _GraphNodeObject noattr))) ::
               (_t'10, (tptr (Tstruct _GraphNodeHeldObject noattr))) ::
               (_t'9, tshort) :: (_t'8, tshort) :: (_t'7, tshort) ::
               (_t'6, (tptr tvoid)) :: (_t'5, (tptr tvoid)) ::
               (_t'4, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'3, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                  cc_default))
      ((Esizeof (Tunion __472 noattr) tuint) :: nil))
    (Sset _mtx (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Ssequence
      (Sset _t'23 (Evar _gMatStackIndex tshort))
      (Sassign (Evar _gMatStackIndex tshort)
        (Ebinop Oadd (Etempvar _t'23 tshort) (Econst_int (Int.repr 1) tint)
          tint)))
    (Ssequence
      (Scall None
        (Evar _vec3s_to_vec3f (Tfunction
                                ((tptr tfloat) :: (tptr tshort) :: nil)
                                (tptr tvoid) cc_default))
        ((Evar _translation (tarray tfloat 3)) ::
         (Efield
           (Ederef
             (Etempvar _node (tptr (Tstruct _GraphNodeBillboard noattr)))
             (Tstruct _GraphNodeBillboard noattr)) _translation
           (tarray tshort 3)) :: nil))
      (Ssequence
        (Ssequence
          (Sset _t'19 (Evar _gMatStackIndex tshort))
          (Ssequence
            (Sset _t'20 (Evar _gMatStackIndex tshort))
            (Ssequence
              (Sset _t'21
                (Evar _gCurGraphNodeCamera (tptr (Tstruct _GraphNodeCamera noattr))))
              (Ssequence
                (Sset _t'22
                  (Efield
                    (Ederef
                      (Etempvar _t'21 (tptr (Tstruct _GraphNodeCamera noattr)))
                      (Tstruct _GraphNodeCamera noattr)) _roll tshort))
                (Scall None
                  (Evar _mtxf_billboard (Tfunction
                                          ((tptr (tarray tfloat 4)) ::
                                           (tptr (tarray tfloat 4)) ::
                                           (tptr tfloat) :: tshort :: nil)
                                          tvoid cc_default))
                  ((Ederef
                     (Ebinop Oadd
                       (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                       (Etempvar _t'19 tshort)
                       (tptr (tarray (tarray tfloat 4) 4)))
                     (tarray (tarray tfloat 4) 4)) ::
                   (Ederef
                     (Ebinop Oadd
                       (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                       (Ebinop Osub (Etempvar _t'20 tshort)
                         (Econst_int (Int.repr 1) tint) tint)
                       (tptr (tarray (tarray tfloat 4) 4)))
                     (tarray (tarray tfloat 4) 4)) ::
                   (Evar _translation (tarray tfloat 3)) ::
                   (Etempvar _t'22 tshort) :: nil))))))
        (Ssequence
          (Ssequence
            (Sset _t'10
              (Evar _gCurGraphNodeHeldObject (tptr (Tstruct _GraphNodeHeldObject noattr))))
            (Sifthenelse (Ebinop One
                           (Etempvar _t'10 (tptr (Tstruct _GraphNodeHeldObject noattr)))
                           (Ecast (Econst_int (Int.repr 0) tint)
                             (tptr tvoid)) tint)
              (Ssequence
                (Sset _t'15 (Evar _gMatStackIndex tshort))
                (Ssequence
                  (Sset _t'16 (Evar _gMatStackIndex tshort))
                  (Ssequence
                    (Sset _t'17
                      (Evar _gCurGraphNodeHeldObject (tptr (Tstruct _GraphNodeHeldObject noattr))))
                    (Ssequence
                      (Sset _t'18
                        (Efield
                          (Ederef
                            (Etempvar _t'17 (tptr (Tstruct _GraphNodeHeldObject noattr)))
                            (Tstruct _GraphNodeHeldObject noattr)) _objNode
                          (tptr (Tstruct _Object noattr))))
                      (Scall None
                        (Evar _mtxf_scale_vec3f (Tfunction
                                                  ((tptr (tarray tfloat 4)) ::
                                                   (tptr (tarray tfloat 4)) ::
                                                   (tptr tfloat) :: nil)
                                                  tvoid cc_default))
                        ((Ederef
                           (Ebinop Oadd
                             (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                             (Etempvar _t'15 tshort)
                             (tptr (tarray (tarray tfloat 4) 4)))
                           (tarray (tarray tfloat 4) 4)) ::
                         (Ederef
                           (Ebinop Oadd
                             (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                             (Etempvar _t'16 tshort)
                             (tptr (tarray (tarray tfloat 4) 4)))
                           (tarray (tarray tfloat 4) 4)) ::
                         (Efield
                           (Efield
                             (Efield
                               (Ederef
                                 (Etempvar _t'18 (tptr (Tstruct _Object noattr)))
                                 (Tstruct _Object noattr)) _header
                               (Tstruct _ObjectNode noattr)) _gfx
                             (Tstruct _GraphNodeObject noattr)) _scale
                           (tarray tfloat 3)) :: nil))))))
              (Ssequence
                (Sset _t'11
                  (Evar _gCurGraphNodeObject (tptr (Tstruct _GraphNodeObject noattr))))
                (Sifthenelse (Ebinop One
                               (Etempvar _t'11 (tptr (Tstruct _GraphNodeObject noattr)))
                               (Ecast (Econst_int (Int.repr 0) tint)
                                 (tptr tvoid)) tint)
                  (Ssequence
                    (Sset _t'12 (Evar _gMatStackIndex tshort))
                    (Ssequence
                      (Sset _t'13 (Evar _gMatStackIndex tshort))
                      (Ssequence
                        (Sset _t'14
                          (Evar _gCurGraphNodeObject (tptr (Tstruct _GraphNodeObject noattr))))
                        (Scall None
                          (Evar _mtxf_scale_vec3f (Tfunction
                                                    ((tptr (tarray tfloat 4)) ::
                                                     (tptr (tarray tfloat 4)) ::
                                                     (tptr tfloat) :: nil)
                                                    tvoid cc_default))
                          ((Ederef
                             (Ebinop Oadd
                               (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                               (Etempvar _t'12 tshort)
                               (tptr (tarray (tarray tfloat 4) 4)))
                             (tarray (tarray tfloat 4) 4)) ::
                           (Ederef
                             (Ebinop Oadd
                               (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                               (Etempvar _t'13 tshort)
                               (tptr (tarray (tarray tfloat 4) 4)))
                             (tarray (tarray tfloat 4) 4)) ::
                           (Efield
                             (Ederef
                               (Etempvar _t'14 (tptr (Tstruct _GraphNodeObject noattr)))
                               (Tstruct _GraphNodeObject noattr)) _scale
                             (tarray tfloat 3)) :: nil)))))
                  Sskip))))
          (Ssequence
            (Ssequence
              (Sset _t'9 (Evar _gMatStackIndex tshort))
              (Scall None
                (Evar _mtxf_to_mtx (Tfunction
                                     ((tptr (Tunion __472 noattr)) ::
                                      (tptr (tarray tfloat 4)) :: nil) tvoid
                                     cc_default))
                ((Etempvar _mtx (tptr (Tunion __472 noattr))) ::
                 (Ederef
                   (Ebinop Oadd
                     (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                     (Etempvar _t'9 tshort)
                     (tptr (tarray (tarray tfloat 4) 4)))
                   (tarray (tarray tfloat 4) 4)) :: nil)))
            (Ssequence
              (Ssequence
                (Sset _t'8 (Evar _gMatStackIndex tshort))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Evar _gMatStackFixed (tarray (tptr (Tunion __472 noattr)) 32))
                      (Etempvar _t'8 tshort)
                      (tptr (tptr (Tunion __472 noattr))))
                    (tptr (Tunion __472 noattr)))
                  (Etempvar _mtx (tptr (Tunion __472 noattr)))))
              (Ssequence
                (Ssequence
                  (Sset _t'5
                    (Efield
                      (Ederef
                        (Etempvar _node (tptr (Tstruct _GraphNodeBillboard noattr)))
                        (Tstruct _GraphNodeBillboard noattr)) _displayList
                      (tptr tvoid)))
                  (Sifthenelse (Ebinop One (Etempvar _t'5 (tptr tvoid))
                                 (Ecast (Econst_int (Int.repr 0) tint)
                                   (tptr tvoid)) tint)
                    (Ssequence
                      (Sset _t'6
                        (Efield
                          (Ederef
                            (Etempvar _node (tptr (Tstruct _GraphNodeBillboard noattr)))
                            (Tstruct _GraphNodeBillboard noattr))
                          _displayList (tptr tvoid)))
                      (Ssequence
                        (Sset _t'7
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _node (tptr (Tstruct _GraphNodeBillboard noattr)))
                                (Tstruct _GraphNodeBillboard noattr)) _node
                              (Tstruct _GraphNode noattr)) _flags tshort))
                        (Scall None
                          (Evar _geo_append_display_list (Tfunction
                                                           ((tptr tvoid) ::
                                                            tshort :: nil)
                                                           tvoid cc_default))
                          ((Etempvar _t'6 (tptr tvoid)) ::
                           (Ebinop Oshr (Etempvar _t'7 tshort)
                             (Econst_int (Int.repr 8) tint) tint) :: nil))))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sset _t'3
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _node (tptr (Tstruct _GraphNodeBillboard noattr)))
                            (Tstruct _GraphNodeBillboard noattr)) _node
                          (Tstruct _GraphNode noattr)) _children
                        (tptr (Tstruct _GraphNode noattr))))
                    (Sifthenelse (Ebinop One
                                   (Etempvar _t'3 (tptr (Tstruct _GraphNode noattr)))
                                   (Ecast (Econst_int (Int.repr 0) tint)
                                     (tptr tvoid)) tint)
                      (Ssequence
                        (Sset _t'4
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _node (tptr (Tstruct _GraphNodeBillboard noattr)))
                                (Tstruct _GraphNodeBillboard noattr)) _node
                              (Tstruct _GraphNode noattr)) _children
                            (tptr (Tstruct _GraphNode noattr))))
                        (Scall None
                          (Evar _geo_process_node_and_siblings (Tfunction
                                                                 ((tptr (Tstruct _GraphNode noattr)) ::
                                                                  nil) tvoid
                                                                 cc_default))
                          ((Etempvar _t'4 (tptr (Tstruct _GraphNode noattr))) ::
                           nil)))
                      Sskip))
                  (Ssequence
                    (Sset _t'2 (Evar _gMatStackIndex tshort))
                    (Sassign (Evar _gMatStackIndex tshort)
                      (Ebinop Osub (Etempvar _t'2 tshort)
                        (Econst_int (Int.repr 1) tint) tint))))))))))))
|}.

Definition f_geo_process_display_list := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _GraphNodeDisplayList noattr))) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_t'5, tshort) :: (_t'4, (tptr tvoid)) ::
               (_t'3, (tptr tvoid)) ::
               (_t'2, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'1, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3
      (Efield
        (Ederef
          (Etempvar _node (tptr (Tstruct _GraphNodeDisplayList noattr)))
          (Tstruct _GraphNodeDisplayList noattr)) _displayList (tptr tvoid)))
    (Sifthenelse (Ebinop One (Etempvar _t'3 (tptr tvoid))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef
              (Etempvar _node (tptr (Tstruct _GraphNodeDisplayList noattr)))
              (Tstruct _GraphNodeDisplayList noattr)) _displayList
            (tptr tvoid)))
        (Ssequence
          (Sset _t'5
            (Efield
              (Efield
                (Ederef
                  (Etempvar _node (tptr (Tstruct _GraphNodeDisplayList noattr)))
                  (Tstruct _GraphNodeDisplayList noattr)) _node
                (Tstruct _GraphNode noattr)) _flags tshort))
          (Scall None
            (Evar _geo_append_display_list (Tfunction
                                             ((tptr tvoid) :: tshort :: nil)
                                             tvoid cc_default))
            ((Etempvar _t'4 (tptr tvoid)) ::
             (Ebinop Oshr (Etempvar _t'5 tshort)
               (Econst_int (Int.repr 8) tint) tint) :: nil))))
      Sskip))
  (Ssequence
    (Sset _t'1
      (Efield
        (Efield
          (Ederef
            (Etempvar _node (tptr (Tstruct _GraphNodeDisplayList noattr)))
            (Tstruct _GraphNodeDisplayList noattr)) _node
          (Tstruct _GraphNode noattr)) _children
        (tptr (Tstruct _GraphNode noattr))))
    (Sifthenelse (Ebinop One
                   (Etempvar _t'1 (tptr (Tstruct _GraphNode noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Sset _t'2
          (Efield
            (Efield
              (Ederef
                (Etempvar _node (tptr (Tstruct _GraphNodeDisplayList noattr)))
                (Tstruct _GraphNodeDisplayList noattr)) _node
              (Tstruct _GraphNode noattr)) _children
            (tptr (Tstruct _GraphNode noattr))))
        (Scall None
          (Evar _geo_process_node_and_siblings (Tfunction
                                                 ((tptr (Tstruct _GraphNode noattr)) ::
                                                  nil) tvoid cc_default))
          ((Etempvar _t'2 (tptr (Tstruct _GraphNode noattr))) :: nil)))
      Sskip)))
|}.

Definition f_geo_process_generated_list := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _GraphNodeGenerated noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_list, (tptr (Tunion __512 noattr))) ::
               (_t'1, (tptr (Tunion __512 noattr))) :: (_t'7, tshort) ::
               (_t'6,
                (tptr (Tfunction
                        (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                         (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                        cc_default))) :: (_t'5, tshort) ::
               (_t'4,
                (tptr (Tfunction
                        (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                         (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                        cc_default))) ::
               (_t'3, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'2, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4
      (Efield
        (Efield
          (Ederef
            (Etempvar _node (tptr (Tstruct _GraphNodeGenerated noattr)))
            (Tstruct _GraphNodeGenerated noattr)) _fnNode
          (Tstruct _FnGraphNode noattr)) _func
        (tptr (Tfunction
                (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                 (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                cc_default))))
    (Sifthenelse (Ebinop One
                   (Etempvar _t'4 (tptr (Tfunction
                                          (tint ::
                                           (tptr (Tstruct _GraphNode noattr)) ::
                                           (tptr tvoid) :: nil)
                                          (tptr (Tunion __512 noattr))
                                          cc_default)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'6
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _node (tptr (Tstruct _GraphNodeGenerated noattr)))
                    (Tstruct _GraphNodeGenerated noattr)) _fnNode
                  (Tstruct _FnGraphNode noattr)) _func
                (tptr (Tfunction
                        (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                         (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                        cc_default))))
            (Ssequence
              (Sset _t'7 (Evar _gMatStackIndex tshort))
              (Scall (Some _t'1)
                (Etempvar _t'6 (tptr (Tfunction
                                       (tint ::
                                        (tptr (Tstruct _GraphNode noattr)) ::
                                        (tptr tvoid) :: nil)
                                       (tptr (Tunion __512 noattr))
                                       cc_default)))
                ((Econst_int (Int.repr 1) tint) ::
                 (Eaddrof
                   (Efield
                     (Efield
                       (Ederef
                         (Etempvar _node (tptr (Tstruct _GraphNodeGenerated noattr)))
                         (Tstruct _GraphNodeGenerated noattr)) _fnNode
                       (Tstruct _FnGraphNode noattr)) _node
                     (Tstruct _GraphNode noattr))
                   (tptr (Tstruct _GraphNode noattr))) ::
                 (Ecast
                   (Ederef
                     (Ebinop Oadd
                       (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                       (Etempvar _t'7 tshort)
                       (tptr (tarray (tarray tfloat 4) 4)))
                     (tarray (tarray tfloat 4) 4))
                   (tptr (Tstruct _AllocOnlyPool noattr))) :: nil))))
          (Sset _list (Etempvar _t'1 (tptr (Tunion __512 noattr)))))
        (Sifthenelse (Ebinop One
                       (Etempvar _list (tptr (Tunion __512 noattr)))
                       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                       tint)
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
            (Scall None
              (Evar _geo_append_display_list (Tfunction
                                               ((tptr tvoid) :: tshort ::
                                                nil) tvoid cc_default))
              ((Ecast
                 (Ebinop Oand
                   (Ecast (Etempvar _list (tptr (Tunion __512 noattr)))
                     tuint) (Econst_int (Int.repr 536870911) tint) tuint)
                 (tptr tvoid)) ::
               (Ebinop Oshr (Etempvar _t'5 tshort)
                 (Econst_int (Int.repr 8) tint) tint) :: nil)))
          Sskip))
      Sskip))
  (Ssequence
    (Sset _t'2
      (Efield
        (Efield
          (Efield
            (Ederef
              (Etempvar _node (tptr (Tstruct _GraphNodeGenerated noattr)))
              (Tstruct _GraphNodeGenerated noattr)) _fnNode
            (Tstruct _FnGraphNode noattr)) _node (Tstruct _GraphNode noattr))
        _children (tptr (Tstruct _GraphNode noattr))))
    (Sifthenelse (Ebinop One
                   (Etempvar _t'2 (tptr (Tstruct _GraphNode noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Sset _t'3
          (Efield
            (Efield
              (Efield
                (Ederef
                  (Etempvar _node (tptr (Tstruct _GraphNodeGenerated noattr)))
                  (Tstruct _GraphNodeGenerated noattr)) _fnNode
                (Tstruct _FnGraphNode noattr)) _node
              (Tstruct _GraphNode noattr)) _children
            (tptr (Tstruct _GraphNode noattr))))
        (Scall None
          (Evar _geo_process_node_and_siblings (Tfunction
                                                 ((tptr (Tstruct _GraphNode noattr)) ::
                                                  nil) tvoid cc_default))
          ((Etempvar _t'3 (tptr (Tstruct _GraphNode noattr))) :: nil)))
      Sskip)))
|}.

Definition f_geo_process_background := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _GraphNodeBackground noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_list, (tptr (Tunion __512 noattr))) ::
               (_gfxStart, (tptr (Tunion __512 noattr))) ::
               (_gfx, (tptr (Tunion __512 noattr))) ::
               (__g, (tptr (Tunion __512 noattr))) ::
               (__g__1, (tptr (Tunion __512 noattr))) ::
               (__g__2, (tptr (Tunion __512 noattr))) ::
               (__g__3, (tptr (Tunion __512 noattr))) ::
               (__g__4, (tptr (Tunion __512 noattr))) ::
               (__g__5, (tptr (Tunion __512 noattr))) ::
               (__g__6, (tptr (Tunion __512 noattr))) ::
               (_t'9, (tptr (Tunion __512 noattr))) ::
               (_t'8, (tptr (Tunion __512 noattr))) ::
               (_t'7, (tptr (Tunion __512 noattr))) ::
               (_t'6, (tptr (Tunion __512 noattr))) ::
               (_t'5, (tptr (Tunion __512 noattr))) ::
               (_t'4, (tptr (Tunion __512 noattr))) ::
               (_t'3, (tptr (Tunion __512 noattr))) ::
               (_t'2, (tptr tvoid)) ::
               (_t'1, (tptr (Tunion __512 noattr))) :: (_t'17, tshort) ::
               (_t'16,
                (tptr (Tfunction
                        (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                         (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                        cc_default))) ::
               (_t'15,
                (tptr (Tfunction
                        (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                         (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                        cc_default))) :: (_t'14, tshort) :: (_t'13, tint) ::
               (_t'12, (tptr (Tstruct _GraphNodeMasterList noattr))) ::
               (_t'11, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'10, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _list (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Ssequence
      (Sset _t'15
        (Efield
          (Efield
            (Ederef
              (Etempvar _node (tptr (Tstruct _GraphNodeBackground noattr)))
              (Tstruct _GraphNodeBackground noattr)) _fnNode
            (Tstruct _FnGraphNode noattr)) _func
          (tptr (Tfunction
                  (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                   (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                  cc_default))))
      (Sifthenelse (Ebinop One
                     (Etempvar _t'15 (tptr (Tfunction
                                             (tint ::
                                              (tptr (Tstruct _GraphNode noattr)) ::
                                              (tptr tvoid) :: nil)
                                             (tptr (Tunion __512 noattr))
                                             cc_default)))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Ssequence
          (Ssequence
            (Sset _t'16
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _node (tptr (Tstruct _GraphNodeBackground noattr)))
                    (Tstruct _GraphNodeBackground noattr)) _fnNode
                  (Tstruct _FnGraphNode noattr)) _func
                (tptr (Tfunction
                        (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                         (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                        cc_default))))
            (Ssequence
              (Sset _t'17 (Evar _gMatStackIndex tshort))
              (Scall (Some _t'1)
                (Etempvar _t'16 (tptr (Tfunction
                                        (tint ::
                                         (tptr (Tstruct _GraphNode noattr)) ::
                                         (tptr tvoid) :: nil)
                                        (tptr (Tunion __512 noattr))
                                        cc_default)))
                ((Econst_int (Int.repr 1) tint) ::
                 (Eaddrof
                   (Efield
                     (Efield
                       (Ederef
                         (Etempvar _node (tptr (Tstruct _GraphNodeBackground noattr)))
                         (Tstruct _GraphNodeBackground noattr)) _fnNode
                       (Tstruct _FnGraphNode noattr)) _node
                     (Tstruct _GraphNode noattr))
                   (tptr (Tstruct _GraphNode noattr))) ::
                 (Ecast
                   (Ederef
                     (Ebinop Oadd
                       (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                       (Etempvar _t'17 tshort)
                       (tptr (tarray (tarray tfloat 4) 4)))
                     (tarray (tarray tfloat 4) 4))
                   (tptr (Tstruct _AllocOnlyPool noattr))) :: nil))))
          (Sset _list (Etempvar _t'1 (tptr (Tunion __512 noattr)))))
        Sskip))
    (Ssequence
      (Sifthenelse (Ebinop One (Etempvar _list (tptr (Tunion __512 noattr)))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Ssequence
          (Sset _t'14
            (Efield
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _node (tptr (Tstruct _GraphNodeBackground noattr)))
                    (Tstruct _GraphNodeBackground noattr)) _fnNode
                  (Tstruct _FnGraphNode noattr)) _node
                (Tstruct _GraphNode noattr)) _flags tshort))
          (Scall None
            (Evar _geo_append_display_list (Tfunction
                                             ((tptr tvoid) :: tshort :: nil)
                                             tvoid cc_default))
            ((Ecast
               (Ebinop Oand
                 (Ecast (Etempvar _list (tptr (Tunion __512 noattr))) tuint)
                 (Econst_int (Int.repr 536870911) tint) tuint) (tptr tvoid)) ::
             (Ebinop Oshr (Etempvar _t'14 tshort)
               (Econst_int (Int.repr 8) tint) tint) :: nil)))
        (Ssequence
          (Sset _t'12
            (Evar _gCurGraphNodeMasterList (tptr (Tstruct _GraphNodeMasterList noattr))))
          (Sifthenelse (Ebinop One
                         (Etempvar _t'12 (tptr (Tstruct _GraphNodeMasterList noattr)))
                         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                         tint)
            (Ssequence
              (Ssequence
                (Scall (Some _t'2)
                  (Evar _alloc_display_list (Tfunction (tuint :: nil)
                                              (tptr tvoid) cc_default))
                  ((Ebinop Omul (Esizeof (Tunion __512 noattr) tuint)
                     (Econst_int (Int.repr 7) tint) tuint) :: nil))
                (Sset _gfxStart (Etempvar _t'2 (tptr tvoid))))
              (Ssequence
                (Sset _gfx (Etempvar _gfxStart (tptr (Tunion __512 noattr))))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'3
                          (Etempvar _gfx (tptr (Tunion __512 noattr))))
                        (Sset _gfx
                          (Ebinop Oadd
                            (Etempvar _t'3 (tptr (Tunion __512 noattr)))
                            (Econst_int (Int.repr 1) tint)
                            (tptr (Tunion __512 noattr)))))
                      (Sset __g
                        (Ecast (Etempvar _t'3 (tptr (Tunion __512 noattr)))
                          (tptr (Tunion __512 noattr)))))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar __g (tptr (Tunion __512 noattr)))
                              (Tunion __512 noattr)) _words
                            (Tstruct __510 noattr)) _w0 tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 231) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 8) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 24) tint) tuint) tuint))
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar __g (tptr (Tunion __512 noattr)))
                              (Tunion __512 noattr)) _words
                            (Tstruct __510 noattr)) _w1 tuint)
                        (Econst_int (Int.repr 0) tint))))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'4
                            (Etempvar _gfx (tptr (Tunion __512 noattr))))
                          (Sset _gfx
                            (Ebinop Oadd
                              (Etempvar _t'4 (tptr (Tunion __512 noattr)))
                              (Econst_int (Int.repr 1) tint)
                              (tptr (Tunion __512 noattr)))))
                        (Sset __g__1
                          (Ecast (Etempvar _t'4 (tptr (Tunion __512 noattr)))
                            (tptr (Tunion __512 noattr)))))
                      (Ssequence
                        (Sassign
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar __g__1 (tptr (Tunion __512 noattr)))
                                (Tunion __512 noattr)) _words
                              (Tstruct __510 noattr)) _w0 tuint)
                          (Ebinop Oor
                            (Ebinop Oor
                              (Ecast
                                (Ebinop Oshl
                                  (Ebinop Oand
                                    (Ecast
                                      (Ebinop Osub
                                        (Eunop Oneg
                                          (Econst_int (Int.repr 65) tint)
                                          tint)
                                        (Econst_int (Int.repr 5) tint) tint)
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
                                    (Ecast (Econst_int (Int.repr 20) tint)
                                      tuint)
                                    (Ebinop Osub
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 8) tint) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuint) (Econst_int (Int.repr 8) tint)
                                  tuint) tuint) tuint)
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Econst_int (Int.repr 2) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 8) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 0) tint)
                                tuint) tuint) tuint))
                        (Sassign
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar __g__1 (tptr (Tunion __512 noattr)))
                                (Tunion __512 noattr)) _words
                              (Tstruct __510 noattr)) _w1 tuint)
                          (Ecast
                            (Ebinop Oshl (Econst_int (Int.repr 3) tint)
                              (Econst_int (Int.repr 20) tint) tint) tuint))))
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'5
                              (Etempvar _gfx (tptr (Tunion __512 noattr))))
                            (Sset _gfx
                              (Ebinop Oadd
                                (Etempvar _t'5 (tptr (Tunion __512 noattr)))
                                (Econst_int (Int.repr 1) tint)
                                (tptr (Tunion __512 noattr)))))
                          (Sset __g__2
                            (Ecast
                              (Etempvar _t'5 (tptr (Tunion __512 noattr)))
                              (tptr (Tunion __512 noattr)))))
                        (Ssequence
                          (Sassign
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar __g__2 (tptr (Tunion __512 noattr)))
                                  (Tunion __512 noattr)) _words
                                (Tstruct __510 noattr)) _w0 tuint)
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Econst_int (Int.repr 247) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 8) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 24) tint)
                                tuint) tuint))
                          (Ssequence
                            (Sset _t'13
                              (Efield
                                (Ederef
                                  (Etempvar _node (tptr (Tstruct _GraphNodeBackground noattr)))
                                  (Tstruct _GraphNodeBackground noattr))
                                _background tint))
                            (Sassign
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar __g__2 (tptr (Tunion __512 noattr)))
                                    (Tunion __512 noattr)) _words
                                  (Tstruct __510 noattr)) _w1 tuint)
                              (Ecast (Etempvar _t'13 tint) tuint)))))
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Sset _t'6
                                (Etempvar _gfx (tptr (Tunion __512 noattr))))
                              (Sset _gfx
                                (Ebinop Oadd
                                  (Etempvar _t'6 (tptr (Tunion __512 noattr)))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr (Tunion __512 noattr)))))
                            (Sset __g__3
                              (Ecast
                                (Etempvar _t'6 (tptr (Tunion __512 noattr)))
                                (tptr (Tunion __512 noattr)))))
                          (Ssequence
                            (Sassign
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar __g__3 (tptr (Tunion __512 noattr)))
                                    (Tunion __512 noattr)) _words
                                  (Tstruct __510 noattr)) _w0 tuint)
                              (Ebinop Oor
                                (Ebinop Oor
                                  (Ecast
                                    (Ebinop Oshl
                                      (Ebinop Oand
                                        (Ecast
                                          (Econst_int (Int.repr 246) tint)
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
                                          (Ebinop Osub
                                            (Ebinop Osub
                                              (Econst_int (Int.repr 320) tint)
                                              (Econst_int (Int.repr 0) tint)
                                              tint)
                                            (Econst_int (Int.repr 1) tint)
                                            tint) tuint)
                                        (Ebinop Osub
                                          (Ebinop Oshl
                                            (Econst_int (Int.repr 1) tint)
                                            (Econst_int (Int.repr 10) tint)
                                            tint)
                                          (Econst_int (Int.repr 1) tint)
                                          tint) tuint)
                                      (Econst_int (Int.repr 14) tint) tuint)
                                    tuint) tuint)
                                (Ecast
                                  (Ebinop Oshl
                                    (Ebinop Oand
                                      (Ecast
                                        (Ebinop Osub
                                          (Ebinop Osub
                                            (Econst_int (Int.repr 240) tint)
                                            (Econst_int (Int.repr 8) tint)
                                            tint)
                                          (Econst_int (Int.repr 1) tint)
                                          tint) tuint)
                                      (Ebinop Osub
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 10) tint)
                                          tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuint) (Econst_int (Int.repr 2) tint)
                                    tuint) tuint) tuint))
                            (Sassign
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar __g__3 (tptr (Tunion __512 noattr)))
                                    (Tunion __512 noattr)) _words
                                  (Tstruct __510 noattr)) _w1 tuint)
                              (Ebinop Oor
                                (Ecast
                                  (Ebinop Oshl
                                    (Ebinop Oand
                                      (Ecast (Econst_int (Int.repr 0) tint)
                                        tuint)
                                      (Ebinop Osub
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 10) tint)
                                          tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuint) (Econst_int (Int.repr 14) tint)
                                    tuint) tuint)
                                (Ecast
                                  (Ebinop Oshl
                                    (Ebinop Oand
                                      (Ecast (Econst_int (Int.repr 8) tint)
                                        tuint)
                                      (Ebinop Osub
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 10) tint)
                                          tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuint) (Econst_int (Int.repr 2) tint)
                                    tuint) tuint) tuint))))
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Sset _t'7
                                  (Etempvar _gfx (tptr (Tunion __512 noattr))))
                                (Sset _gfx
                                  (Ebinop Oadd
                                    (Etempvar _t'7 (tptr (Tunion __512 noattr)))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr (Tunion __512 noattr)))))
                              (Sset __g__4
                                (Ecast
                                  (Etempvar _t'7 (tptr (Tunion __512 noattr)))
                                  (tptr (Tunion __512 noattr)))))
                            (Ssequence
                              (Sassign
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar __g__4 (tptr (Tunion __512 noattr)))
                                      (Tunion __512 noattr)) _words
                                    (Tstruct __510 noattr)) _w0 tuint)
                                (Ecast
                                  (Ebinop Oshl
                                    (Ebinop Oand
                                      (Ecast (Econst_int (Int.repr 231) tint)
                                        tuint)
                                      (Ebinop Osub
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 8) tint)
                                          tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuint) (Econst_int (Int.repr 24) tint)
                                    tuint) tuint))
                              (Sassign
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar __g__4 (tptr (Tunion __512 noattr)))
                                      (Tunion __512 noattr)) _words
                                    (Tstruct __510 noattr)) _w1 tuint)
                                (Econst_int (Int.repr 0) tint))))
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Ssequence
                                  (Sset _t'8
                                    (Etempvar _gfx (tptr (Tunion __512 noattr))))
                                  (Sset _gfx
                                    (Ebinop Oadd
                                      (Etempvar _t'8 (tptr (Tunion __512 noattr)))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr (Tunion __512 noattr)))))
                                (Sset __g__5
                                  (Ecast
                                    (Etempvar _t'8 (tptr (Tunion __512 noattr)))
                                    (tptr (Tunion __512 noattr)))))
                              (Ssequence
                                (Sassign
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar __g__5 (tptr (Tunion __512 noattr)))
                                        (Tunion __512 noattr)) _words
                                      (Tstruct __510 noattr)) _w0 tuint)
                                  (Ebinop Oor
                                    (Ebinop Oor
                                      (Ecast
                                        (Ebinop Oshl
                                          (Ebinop Oand
                                            (Ecast
                                              (Ebinop Osub
                                                (Eunop Oneg
                                                  (Econst_int (Int.repr 65) tint)
                                                  tint)
                                                (Econst_int (Int.repr 5) tint)
                                                tint) tuint)
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
                                              (Econst_int (Int.repr 20) tint)
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
                                            (Econst_int (Int.repr 2) tint)
                                            tuint)
                                          (Ebinop Osub
                                            (Ebinop Oshl
                                              (Econst_int (Int.repr 1) tint)
                                              (Econst_int (Int.repr 8) tint)
                                              tint)
                                            (Econst_int (Int.repr 1) tint)
                                            tint) tuint)
                                        (Econst_int (Int.repr 0) tint) tuint)
                                      tuint) tuint))
                                (Sassign
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar __g__5 (tptr (Tunion __512 noattr)))
                                        (Tunion __512 noattr)) _words
                                      (Tstruct __510 noattr)) _w1 tuint)
                                  (Ecast
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 0) tint)
                                      (Econst_int (Int.repr 20) tint) tint)
                                    tuint))))
                            (Ssequence
                              (Ssequence
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'9
                                      (Etempvar _gfx (tptr (Tunion __512 noattr))))
                                    (Sset _gfx
                                      (Ebinop Oadd
                                        (Etempvar _t'9 (tptr (Tunion __512 noattr)))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr (Tunion __512 noattr)))))
                                  (Sset __g__6
                                    (Ecast
                                      (Etempvar _t'9 (tptr (Tunion __512 noattr)))
                                      (tptr (Tunion __512 noattr)))))
                                (Ssequence
                                  (Sassign
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar __g__6 (tptr (Tunion __512 noattr)))
                                          (Tunion __512 noattr)) _words
                                        (Tstruct __510 noattr)) _w0 tuint)
                                    (Ecast
                                      (Ebinop Oshl
                                        (Ebinop Oand
                                          (Ecast
                                            (Ebinop Osub
                                              (Eunop Oneg
                                                (Econst_int (Int.repr 65) tint)
                                                tint)
                                              (Econst_int (Int.repr 7) tint)
                                              tint) tuint)
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
                                          (Etempvar __g__6 (tptr (Tunion __512 noattr)))
                                          (Tunion __512 noattr)) _words
                                        (Tstruct __510 noattr)) _w1 tuint)
                                    (Econst_int (Int.repr 0) tint))))
                              (Scall None
                                (Evar _geo_append_display_list (Tfunction
                                                                 ((tptr tvoid) ::
                                                                  tshort ::
                                                                  nil) tvoid
                                                                 cc_default))
                                ((Ecast
                                   (Ebinop Oand
                                     (Ecast
                                       (Etempvar _gfxStart (tptr (Tunion __512 noattr)))
                                       tuint)
                                     (Econst_int (Int.repr 536870911) tint)
                                     tuint) (tptr tvoid)) ::
                                 (Econst_int (Int.repr 0) tint) :: nil)))))))))))
            Sskip)))
      (Ssequence
        (Sset _t'10
          (Efield
            (Efield
              (Efield
                (Ederef
                  (Etempvar _node (tptr (Tstruct _GraphNodeBackground noattr)))
                  (Tstruct _GraphNodeBackground noattr)) _fnNode
                (Tstruct _FnGraphNode noattr)) _node
              (Tstruct _GraphNode noattr)) _children
            (tptr (Tstruct _GraphNode noattr))))
        (Sifthenelse (Ebinop One
                       (Etempvar _t'10 (tptr (Tstruct _GraphNode noattr)))
                       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                       tint)
          (Ssequence
            (Sset _t'11
              (Efield
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _node (tptr (Tstruct _GraphNodeBackground noattr)))
                      (Tstruct _GraphNodeBackground noattr)) _fnNode
                    (Tstruct _FnGraphNode noattr)) _node
                  (Tstruct _GraphNode noattr)) _children
                (tptr (Tstruct _GraphNode noattr))))
            (Scall None
              (Evar _geo_process_node_and_siblings (Tfunction
                                                     ((tptr (Tstruct _GraphNode noattr)) ::
                                                      nil) tvoid cc_default))
              ((Etempvar _t'11 (tptr (Tstruct _GraphNode noattr))) :: nil)))
          Sskip)))))
|}.

Definition f_geo_process_animated_part := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _GraphNodeAnimatedPart noattr))) ::
                nil);
  fn_vars := ((_matrix, (tarray (tarray tfloat 4) 4)) ::
              (_rotation, (tarray tshort 3)) ::
              (_translation, (tarray tfloat 3)) :: nil);
  fn_temps := ((_matrixPtr, (tptr (Tunion __472 noattr))) :: (_t'10, tint) ::
               (_t'9, tint) :: (_t'8, tint) :: (_t'7, tint) ::
               (_t'6, tint) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, (tptr tvoid)) ::
               (_t'72, tshort) :: (_t'71, tshort) :: (_t'70, tshort) ::
               (_t'69, tshort) :: (_t'68, tfloat) :: (_t'67, tshort) ::
               (_t'66, (tptr tshort)) :: (_t'65, tfloat) ::
               (_t'64, tshort) :: (_t'63, tfloat) :: (_t'62, tshort) ::
               (_t'61, (tptr tshort)) :: (_t'60, tfloat) ::
               (_t'59, tshort) :: (_t'58, tfloat) :: (_t'57, tshort) ::
               (_t'56, (tptr tshort)) :: (_t'55, tfloat) ::
               (_t'54, tshort) :: (_t'53, tfloat) :: (_t'52, tshort) ::
               (_t'51, (tptr tshort)) :: (_t'50, tfloat) ::
               (_t'49, (tptr tushort)) :: (_t'48, tshort) ::
               (_t'47, tfloat) :: (_t'46, tshort) ::
               (_t'45, (tptr tshort)) :: (_t'44, tfloat) ::
               (_t'43, (tptr tushort)) :: (_t'42, tshort) ::
               (_t'41, tfloat) :: (_t'40, tshort) ::
               (_t'39, (tptr tshort)) :: (_t'38, tfloat) ::
               (_t'37, (tptr tushort)) :: (_t'36, (tptr tushort)) ::
               (_t'35, tuchar) :: (_t'34, tuchar) :: (_t'33, tuchar) ::
               (_t'32, tuchar) :: (_t'31, tshort) :: (_t'30, tshort) ::
               (_t'29, (tptr tshort)) :: (_t'28, tshort) ::
               (_t'27, tshort) :: (_t'26, (tptr tshort)) ::
               (_t'25, tshort) :: (_t'24, tshort) ::
               (_t'23, (tptr tshort)) :: (_t'22, tuchar) ::
               (_t'21, tshort) :: (_t'20, tshort) :: (_t'19, tshort) ::
               (_t'18, tshort) :: (_t'17, tshort) :: (_t'16, tshort) ::
               (_t'15, (tptr tvoid)) :: (_t'14, (tptr tvoid)) ::
               (_t'13, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'12, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'11, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                  cc_default))
      ((Esizeof (Tunion __472 noattr) tuint) :: nil))
    (Sset _matrixPtr (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Scall None
      (Evar _vec3s_copy (Tfunction ((tptr tshort) :: (tptr tshort) :: nil)
                          (tptr tvoid) cc_default))
      ((Evar _rotation (tarray tshort 3)) ::
       (Evar _gVec3sZero (tarray tshort 3)) :: nil))
    (Ssequence
      (Ssequence
        (Sset _t'70
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef
                  (Etempvar _node (tptr (Tstruct _GraphNodeAnimatedPart noattr)))
                  (Tstruct _GraphNodeAnimatedPart noattr)) _translation
                (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
              (tptr tshort)) tshort))
        (Ssequence
          (Sset _t'71
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef
                    (Etempvar _node (tptr (Tstruct _GraphNodeAnimatedPart noattr)))
                    (Tstruct _GraphNodeAnimatedPart noattr)) _translation
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort))
          (Ssequence
            (Sset _t'72
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef
                      (Etempvar _node (tptr (Tstruct _GraphNodeAnimatedPart noattr)))
                      (Tstruct _GraphNodeAnimatedPart noattr)) _translation
                    (tarray tshort 3)) (Econst_int (Int.repr 2) tint)
                  (tptr tshort)) tshort))
            (Scall None
              (Evar _vec3f_set (Tfunction
                                 ((tptr tfloat) :: tfloat :: tfloat ::
                                  tfloat :: nil) (tptr tvoid) cc_default))
              ((Evar _translation (tarray tfloat 3)) ::
               (Etempvar _t'70 tshort) :: (Etempvar _t'71 tshort) ::
               (Etempvar _t'72 tshort) :: nil)))))
      (Ssequence
        (Ssequence
          (Sset _t'32 (Evar _gCurrAnimType tuchar))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'32 tuchar)
                         (Econst_int (Int.repr 1) tint) tint)
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'69 (Evar _gCurrAnimFrame tshort))
                  (Scall (Some _t'2)
                    (Evar _retrieve_animation_index (Tfunction
                                                      (tint ::
                                                       (tptr (tptr tushort)) ::
                                                       nil) tint cc_default))
                    ((Etempvar _t'69 tshort) ::
                     (Eaddrof (Evar _gCurrAnimAttribute (tptr tushort))
                       (tptr (tptr tushort))) :: nil)))
                (Ssequence
                  (Sset _t'65
                    (Ederef
                      (Ebinop Oadd (Evar _translation (tarray tfloat 3))
                        (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
                  (Ssequence
                    (Sset _t'66 (Evar _gCurrAnimData (tptr tshort)))
                    (Ssequence
                      (Sset _t'67
                        (Ederef
                          (Ebinop Oadd (Etempvar _t'66 (tptr tshort))
                            (Etempvar _t'2 tint) (tptr tshort)) tshort))
                      (Ssequence
                        (Sset _t'68
                          (Evar _gCurrAnimTranslationMultiplier tfloat))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Evar _translation (tarray tfloat 3))
                              (Econst_int (Int.repr 0) tint) (tptr tfloat))
                            tfloat)
                          (Ebinop Oadd (Etempvar _t'65 tfloat)
                            (Ebinop Omul (Etempvar _t'67 tshort)
                              (Etempvar _t'68 tfloat) tfloat) tfloat)))))))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'64 (Evar _gCurrAnimFrame tshort))
                    (Scall (Some _t'3)
                      (Evar _retrieve_animation_index (Tfunction
                                                        (tint ::
                                                         (tptr (tptr tushort)) ::
                                                         nil) tint
                                                        cc_default))
                      ((Etempvar _t'64 tshort) ::
                       (Eaddrof (Evar _gCurrAnimAttribute (tptr tushort))
                         (tptr (tptr tushort))) :: nil)))
                  (Ssequence
                    (Sset _t'60
                      (Ederef
                        (Ebinop Oadd (Evar _translation (tarray tfloat 3))
                          (Econst_int (Int.repr 1) tint) (tptr tfloat))
                        tfloat))
                    (Ssequence
                      (Sset _t'61 (Evar _gCurrAnimData (tptr tshort)))
                      (Ssequence
                        (Sset _t'62
                          (Ederef
                            (Ebinop Oadd (Etempvar _t'61 (tptr tshort))
                              (Etempvar _t'3 tint) (tptr tshort)) tshort))
                        (Ssequence
                          (Sset _t'63
                            (Evar _gCurrAnimTranslationMultiplier tfloat))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Evar _translation (tarray tfloat 3))
                                (Econst_int (Int.repr 1) tint) (tptr tfloat))
                              tfloat)
                            (Ebinop Oadd (Etempvar _t'60 tfloat)
                              (Ebinop Omul (Etempvar _t'62 tshort)
                                (Etempvar _t'63 tfloat) tfloat) tfloat)))))))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'59 (Evar _gCurrAnimFrame tshort))
                      (Scall (Some _t'4)
                        (Evar _retrieve_animation_index (Tfunction
                                                          (tint ::
                                                           (tptr (tptr tushort)) ::
                                                           nil) tint
                                                          cc_default))
                        ((Etempvar _t'59 tshort) ::
                         (Eaddrof (Evar _gCurrAnimAttribute (tptr tushort))
                           (tptr (tptr tushort))) :: nil)))
                    (Ssequence
                      (Sset _t'55
                        (Ederef
                          (Ebinop Oadd (Evar _translation (tarray tfloat 3))
                            (Econst_int (Int.repr 2) tint) (tptr tfloat))
                          tfloat))
                      (Ssequence
                        (Sset _t'56 (Evar _gCurrAnimData (tptr tshort)))
                        (Ssequence
                          (Sset _t'57
                            (Ederef
                              (Ebinop Oadd (Etempvar _t'56 (tptr tshort))
                                (Etempvar _t'4 tint) (tptr tshort)) tshort))
                          (Ssequence
                            (Sset _t'58
                              (Evar _gCurrAnimTranslationMultiplier tfloat))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Evar _translation (tarray tfloat 3))
                                  (Econst_int (Int.repr 2) tint)
                                  (tptr tfloat)) tfloat)
                              (Ebinop Oadd (Etempvar _t'55 tfloat)
                                (Ebinop Omul (Etempvar _t'57 tshort)
                                  (Etempvar _t'58 tfloat) tfloat) tfloat)))))))
                  (Sassign (Evar _gCurrAnimType tuchar)
                    (Econst_int (Int.repr 5) tint)))))
            (Ssequence
              (Sset _t'33 (Evar _gCurrAnimType tuchar))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'33 tuchar)
                             (Econst_int (Int.repr 3) tint) tint)
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'54 (Evar _gCurrAnimFrame tshort))
                      (Scall (Some _t'5)
                        (Evar _retrieve_animation_index (Tfunction
                                                          (tint ::
                                                           (tptr (tptr tushort)) ::
                                                           nil) tint
                                                          cc_default))
                        ((Etempvar _t'54 tshort) ::
                         (Eaddrof (Evar _gCurrAnimAttribute (tptr tushort))
                           (tptr (tptr tushort))) :: nil)))
                    (Ssequence
                      (Sset _t'50
                        (Ederef
                          (Ebinop Oadd (Evar _translation (tarray tfloat 3))
                            (Econst_int (Int.repr 0) tint) (tptr tfloat))
                          tfloat))
                      (Ssequence
                        (Sset _t'51 (Evar _gCurrAnimData (tptr tshort)))
                        (Ssequence
                          (Sset _t'52
                            (Ederef
                              (Ebinop Oadd (Etempvar _t'51 (tptr tshort))
                                (Etempvar _t'5 tint) (tptr tshort)) tshort))
                          (Ssequence
                            (Sset _t'53
                              (Evar _gCurrAnimTranslationMultiplier tfloat))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Evar _translation (tarray tfloat 3))
                                  (Econst_int (Int.repr 0) tint)
                                  (tptr tfloat)) tfloat)
                              (Ebinop Oadd (Etempvar _t'50 tfloat)
                                (Ebinop Omul (Etempvar _t'52 tshort)
                                  (Etempvar _t'53 tfloat) tfloat) tfloat)))))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'49 (Evar _gCurrAnimAttribute (tptr tushort)))
                      (Sassign (Evar _gCurrAnimAttribute (tptr tushort))
                        (Ebinop Oadd (Etempvar _t'49 (tptr tushort))
                          (Econst_int (Int.repr 2) tint) (tptr tushort))))
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'48 (Evar _gCurrAnimFrame tshort))
                          (Scall (Some _t'6)
                            (Evar _retrieve_animation_index (Tfunction
                                                              (tint ::
                                                               (tptr (tptr tushort)) ::
                                                               nil) tint
                                                              cc_default))
                            ((Etempvar _t'48 tshort) ::
                             (Eaddrof
                               (Evar _gCurrAnimAttribute (tptr tushort))
                               (tptr (tptr tushort))) :: nil)))
                        (Ssequence
                          (Sset _t'44
                            (Ederef
                              (Ebinop Oadd
                                (Evar _translation (tarray tfloat 3))
                                (Econst_int (Int.repr 2) tint) (tptr tfloat))
                              tfloat))
                          (Ssequence
                            (Sset _t'45 (Evar _gCurrAnimData (tptr tshort)))
                            (Ssequence
                              (Sset _t'46
                                (Ederef
                                  (Ebinop Oadd (Etempvar _t'45 (tptr tshort))
                                    (Etempvar _t'6 tint) (tptr tshort))
                                  tshort))
                              (Ssequence
                                (Sset _t'47
                                  (Evar _gCurrAnimTranslationMultiplier tfloat))
                                (Sassign
                                  (Ederef
                                    (Ebinop Oadd
                                      (Evar _translation (tarray tfloat 3))
                                      (Econst_int (Int.repr 2) tint)
                                      (tptr tfloat)) tfloat)
                                  (Ebinop Oadd (Etempvar _t'44 tfloat)
                                    (Ebinop Omul (Etempvar _t'46 tshort)
                                      (Etempvar _t'47 tfloat) tfloat) tfloat)))))))
                      (Sassign (Evar _gCurrAnimType tuchar)
                        (Econst_int (Int.repr 5) tint)))))
                (Ssequence
                  (Sset _t'34 (Evar _gCurrAnimType tuchar))
                  (Sifthenelse (Ebinop Oeq (Etempvar _t'34 tuchar)
                                 (Econst_int (Int.repr 2) tint) tint)
                    (Ssequence
                      (Ssequence
                        (Sset _t'43
                          (Evar _gCurrAnimAttribute (tptr tushort)))
                        (Sassign (Evar _gCurrAnimAttribute (tptr tushort))
                          (Ebinop Oadd (Etempvar _t'43 (tptr tushort))
                            (Econst_int (Int.repr 2) tint) (tptr tushort))))
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'42 (Evar _gCurrAnimFrame tshort))
                            (Scall (Some _t'7)
                              (Evar _retrieve_animation_index (Tfunction
                                                                (tint ::
                                                                 (tptr (tptr tushort)) ::
                                                                 nil) tint
                                                                cc_default))
                              ((Etempvar _t'42 tshort) ::
                               (Eaddrof
                                 (Evar _gCurrAnimAttribute (tptr tushort))
                                 (tptr (tptr tushort))) :: nil)))
                          (Ssequence
                            (Sset _t'38
                              (Ederef
                                (Ebinop Oadd
                                  (Evar _translation (tarray tfloat 3))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tfloat)) tfloat))
                            (Ssequence
                              (Sset _t'39
                                (Evar _gCurrAnimData (tptr tshort)))
                              (Ssequence
                                (Sset _t'40
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'39 (tptr tshort))
                                      (Etempvar _t'7 tint) (tptr tshort))
                                    tshort))
                                (Ssequence
                                  (Sset _t'41
                                    (Evar _gCurrAnimTranslationMultiplier tfloat))
                                  (Sassign
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _translation (tarray tfloat 3))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr tfloat)) tfloat)
                                    (Ebinop Oadd (Etempvar _t'38 tfloat)
                                      (Ebinop Omul (Etempvar _t'40 tshort)
                                        (Etempvar _t'41 tfloat) tfloat)
                                      tfloat)))))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'37
                              (Evar _gCurrAnimAttribute (tptr tushort)))
                            (Sassign
                              (Evar _gCurrAnimAttribute (tptr tushort))
                              (Ebinop Oadd (Etempvar _t'37 (tptr tushort))
                                (Econst_int (Int.repr 2) tint)
                                (tptr tushort))))
                          (Sassign (Evar _gCurrAnimType tuchar)
                            (Econst_int (Int.repr 5) tint)))))
                    (Ssequence
                      (Sset _t'35 (Evar _gCurrAnimType tuchar))
                      (Sifthenelse (Ebinop Oeq (Etempvar _t'35 tuchar)
                                     (Econst_int (Int.repr 4) tint) tint)
                        (Ssequence
                          (Ssequence
                            (Sset _t'36
                              (Evar _gCurrAnimAttribute (tptr tushort)))
                            (Sassign
                              (Evar _gCurrAnimAttribute (tptr tushort))
                              (Ebinop Oadd (Etempvar _t'36 (tptr tushort))
                                (Econst_int (Int.repr 6) tint)
                                (tptr tushort))))
                          (Sassign (Evar _gCurrAnimType tuchar)
                            (Econst_int (Int.repr 5) tint)))
                        Sskip))))))))
        (Ssequence
          (Ssequence
            (Sset _t'22 (Evar _gCurrAnimType tuchar))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'22 tuchar)
                           (Econst_int (Int.repr 5) tint) tint)
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'31 (Evar _gCurrAnimFrame tshort))
                    (Scall (Some _t'8)
                      (Evar _retrieve_animation_index (Tfunction
                                                        (tint ::
                                                         (tptr (tptr tushort)) ::
                                                         nil) tint
                                                        cc_default))
                      ((Etempvar _t'31 tshort) ::
                       (Eaddrof (Evar _gCurrAnimAttribute (tptr tushort))
                         (tptr (tptr tushort))) :: nil)))
                  (Ssequence
                    (Sset _t'29 (Evar _gCurrAnimData (tptr tshort)))
                    (Ssequence
                      (Sset _t'30
                        (Ederef
                          (Ebinop Oadd (Etempvar _t'29 (tptr tshort))
                            (Etempvar _t'8 tint) (tptr tshort)) tshort))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd (Evar _rotation (tarray tshort 3))
                            (Econst_int (Int.repr 0) tint) (tptr tshort))
                          tshort) (Etempvar _t'30 tshort)))))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'28 (Evar _gCurrAnimFrame tshort))
                      (Scall (Some _t'9)
                        (Evar _retrieve_animation_index (Tfunction
                                                          (tint ::
                                                           (tptr (tptr tushort)) ::
                                                           nil) tint
                                                          cc_default))
                        ((Etempvar _t'28 tshort) ::
                         (Eaddrof (Evar _gCurrAnimAttribute (tptr tushort))
                           (tptr (tptr tushort))) :: nil)))
                    (Ssequence
                      (Sset _t'26 (Evar _gCurrAnimData (tptr tshort)))
                      (Ssequence
                        (Sset _t'27
                          (Ederef
                            (Ebinop Oadd (Etempvar _t'26 (tptr tshort))
                              (Etempvar _t'9 tint) (tptr tshort)) tshort))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd (Evar _rotation (tarray tshort 3))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))
                            tshort) (Etempvar _t'27 tshort)))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'25 (Evar _gCurrAnimFrame tshort))
                      (Scall (Some _t'10)
                        (Evar _retrieve_animation_index (Tfunction
                                                          (tint ::
                                                           (tptr (tptr tushort)) ::
                                                           nil) tint
                                                          cc_default))
                        ((Etempvar _t'25 tshort) ::
                         (Eaddrof (Evar _gCurrAnimAttribute (tptr tushort))
                           (tptr (tptr tushort))) :: nil)))
                    (Ssequence
                      (Sset _t'23 (Evar _gCurrAnimData (tptr tshort)))
                      (Ssequence
                        (Sset _t'24
                          (Ederef
                            (Ebinop Oadd (Etempvar _t'23 (tptr tshort))
                              (Etempvar _t'10 tint) (tptr tshort)) tshort))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd (Evar _rotation (tarray tshort 3))
                              (Econst_int (Int.repr 2) tint) (tptr tshort))
                            tshort) (Etempvar _t'24 tshort)))))))
              Sskip))
          (Ssequence
            (Scall None
              (Evar _mtxf_rotate_xyz_and_translate (Tfunction
                                                     ((tptr (tarray tfloat 4)) ::
                                                      (tptr tfloat) ::
                                                      (tptr tshort) :: nil)
                                                     tvoid cc_default))
              ((Evar _matrix (tarray (tarray tfloat 4) 4)) ::
               (Evar _translation (tarray tfloat 3)) ::
               (Evar _rotation (tarray tshort 3)) :: nil))
            (Ssequence
              (Ssequence
                (Sset _t'20 (Evar _gMatStackIndex tshort))
                (Ssequence
                  (Sset _t'21 (Evar _gMatStackIndex tshort))
                  (Scall None
                    (Evar _mtxf_mul (Tfunction
                                      ((tptr (tarray tfloat 4)) ::
                                       (tptr (tarray tfloat 4)) ::
                                       (tptr (tarray tfloat 4)) :: nil) tvoid
                                      cc_default))
                    ((Ederef
                       (Ebinop Oadd
                         (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                         (Ebinop Oadd (Etempvar _t'20 tshort)
                           (Econst_int (Int.repr 1) tint) tint)
                         (tptr (tarray (tarray tfloat 4) 4)))
                       (tarray (tarray tfloat 4) 4)) ::
                     (Evar _matrix (tarray (tarray tfloat 4) 4)) ::
                     (Ederef
                       (Ebinop Oadd
                         (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                         (Etempvar _t'21 tshort)
                         (tptr (tarray (tarray tfloat 4) 4)))
                       (tarray (tarray tfloat 4) 4)) :: nil))))
              (Ssequence
                (Ssequence
                  (Sset _t'19 (Evar _gMatStackIndex tshort))
                  (Sassign (Evar _gMatStackIndex tshort)
                    (Ebinop Oadd (Etempvar _t'19 tshort)
                      (Econst_int (Int.repr 1) tint) tint)))
                (Ssequence
                  (Ssequence
                    (Sset _t'18 (Evar _gMatStackIndex tshort))
                    (Scall None
                      (Evar _mtxf_to_mtx (Tfunction
                                           ((tptr (Tunion __472 noattr)) ::
                                            (tptr (tarray tfloat 4)) :: nil)
                                           tvoid cc_default))
                      ((Etempvar _matrixPtr (tptr (Tunion __472 noattr))) ::
                       (Ederef
                         (Ebinop Oadd
                           (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                           (Etempvar _t'18 tshort)
                           (tptr (tarray (tarray tfloat 4) 4)))
                         (tarray (tarray tfloat 4) 4)) :: nil)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'17 (Evar _gMatStackIndex tshort))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Evar _gMatStackFixed (tarray (tptr (Tunion __472 noattr)) 32))
                            (Etempvar _t'17 tshort)
                            (tptr (tptr (Tunion __472 noattr))))
                          (tptr (Tunion __472 noattr)))
                        (Etempvar _matrixPtr (tptr (Tunion __472 noattr)))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'14
                          (Efield
                            (Ederef
                              (Etempvar _node (tptr (Tstruct _GraphNodeAnimatedPart noattr)))
                              (Tstruct _GraphNodeAnimatedPart noattr))
                            _displayList (tptr tvoid)))
                        (Sifthenelse (Ebinop One
                                       (Etempvar _t'14 (tptr tvoid))
                                       (Ecast (Econst_int (Int.repr 0) tint)
                                         (tptr tvoid)) tint)
                          (Ssequence
                            (Sset _t'15
                              (Efield
                                (Ederef
                                  (Etempvar _node (tptr (Tstruct _GraphNodeAnimatedPart noattr)))
                                  (Tstruct _GraphNodeAnimatedPart noattr))
                                _displayList (tptr tvoid)))
                            (Ssequence
                              (Sset _t'16
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _node (tptr (Tstruct _GraphNodeAnimatedPart noattr)))
                                      (Tstruct _GraphNodeAnimatedPart noattr))
                                    _node (Tstruct _GraphNode noattr)) _flags
                                  tshort))
                              (Scall None
                                (Evar _geo_append_display_list (Tfunction
                                                                 ((tptr tvoid) ::
                                                                  tshort ::
                                                                  nil) tvoid
                                                                 cc_default))
                                ((Etempvar _t'15 (tptr tvoid)) ::
                                 (Ebinop Oshr (Etempvar _t'16 tshort)
                                   (Econst_int (Int.repr 8) tint) tint) ::
                                 nil))))
                          Sskip))
                      (Ssequence
                        (Ssequence
                          (Sset _t'12
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _node (tptr (Tstruct _GraphNodeAnimatedPart noattr)))
                                  (Tstruct _GraphNodeAnimatedPart noattr))
                                _node (Tstruct _GraphNode noattr)) _children
                              (tptr (Tstruct _GraphNode noattr))))
                          (Sifthenelse (Ebinop One
                                         (Etempvar _t'12 (tptr (Tstruct _GraphNode noattr)))
                                         (Ecast
                                           (Econst_int (Int.repr 0) tint)
                                           (tptr tvoid)) tint)
                            (Ssequence
                              (Sset _t'13
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _node (tptr (Tstruct _GraphNodeAnimatedPart noattr)))
                                      (Tstruct _GraphNodeAnimatedPart noattr))
                                    _node (Tstruct _GraphNode noattr))
                                  _children
                                  (tptr (Tstruct _GraphNode noattr))))
                              (Scall None
                                (Evar _geo_process_node_and_siblings 
                                (Tfunction
                                  ((tptr (Tstruct _GraphNode noattr)) :: nil)
                                  tvoid cc_default))
                                ((Etempvar _t'13 (tptr (Tstruct _GraphNode noattr))) ::
                                 nil)))
                            Sskip))
                        (Ssequence
                          (Sset _t'11 (Evar _gMatStackIndex tshort))
                          (Sassign (Evar _gMatStackIndex tshort)
                            (Ebinop Osub (Etempvar _t'11 tshort)
                              (Econst_int (Int.repr 1) tint) tint)))))))))))))))
|}.

Definition f_geo_set_animation_globals := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _AnimInfo noattr))) ::
                (_hasAnimation, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_anim, (tptr (Tstruct _Animation noattr))) ::
               (_t'3, (tptr tvoid)) :: (_t'2, (tptr tvoid)) ::
               (_t'1, tshort) :: (_t'14, tushort) :: (_t'13, tshort) ::
               (_t'12, tshort) :: (_t'11, tshort) :: (_t'10, tshort) ::
               (_t'9, tshort) :: (_t'8, (tptr tushort)) ::
               (_t'7, (tptr tshort)) :: (_t'6, tshort) :: (_t'5, tshort) ::
               (_t'4, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _anim
    (Efield
      (Ederef (Etempvar _node (tptr (Tstruct _AnimInfo noattr)))
        (Tstruct _AnimInfo noattr)) _curAnim
      (tptr (Tstruct _Animation noattr))))
  (Ssequence
    (Sifthenelse (Etempvar _hasAnimation tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _geo_update_animation_frame (Tfunction
                                              ((tptr (Tstruct _AnimInfo noattr)) ::
                                               (tptr tint) :: nil) tshort
                                              cc_default))
          ((Etempvar _node (tptr (Tstruct _AnimInfo noattr))) ::
           (Eaddrof
             (Efield
               (Ederef (Etempvar _node (tptr (Tstruct _AnimInfo noattr)))
                 (Tstruct _AnimInfo noattr)) _animFrameAccelAssist tint)
             (tptr tint)) :: nil))
        (Sassign
          (Efield
            (Ederef (Etempvar _node (tptr (Tstruct _AnimInfo noattr)))
              (Tstruct _AnimInfo noattr)) _animFrame tshort)
          (Etempvar _t'1 tshort)))
      Sskip)
    (Ssequence
      (Ssequence
        (Sset _t'14 (Evar _gAreaUpdateCounter tushort))
        (Sassign
          (Efield
            (Ederef (Etempvar _node (tptr (Tstruct _AnimInfo noattr)))
              (Tstruct _AnimInfo noattr)) _animTimer tushort)
          (Etempvar _t'14 tushort)))
      (Ssequence
        (Ssequence
          (Sset _t'11
            (Efield
              (Ederef (Etempvar _anim (tptr (Tstruct _Animation noattr)))
                (Tstruct _Animation noattr)) _flags tshort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'11 tshort)
                         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 3) tint) tint) tint)
            (Sassign (Evar _gCurrAnimType tuchar)
              (Econst_int (Int.repr 2) tint))
            (Ssequence
              (Sset _t'12
                (Efield
                  (Ederef (Etempvar _anim (tptr (Tstruct _Animation noattr)))
                    (Tstruct _Animation noattr)) _flags tshort))
              (Sifthenelse (Ebinop Oand (Etempvar _t'12 tshort)
                             (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                               (Econst_int (Int.repr 4) tint) tint) tint)
                (Sassign (Evar _gCurrAnimType tuchar)
                  (Econst_int (Int.repr 3) tint))
                (Ssequence
                  (Sset _t'13
                    (Efield
                      (Ederef
                        (Etempvar _anim (tptr (Tstruct _Animation noattr)))
                        (Tstruct _Animation noattr)) _flags tshort))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'13 tshort)
                                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                   (Econst_int (Int.repr 6) tint) tint) tint)
                    (Sassign (Evar _gCurrAnimType tuchar)
                      (Econst_int (Int.repr 4) tint))
                    (Sassign (Evar _gCurrAnimType tuchar)
                      (Econst_int (Int.repr 1) tint))))))))
        (Ssequence
          (Ssequence
            (Sset _t'10
              (Efield
                (Ederef (Etempvar _node (tptr (Tstruct _AnimInfo noattr)))
                  (Tstruct _AnimInfo noattr)) _animFrame tshort))
            (Sassign (Evar _gCurrAnimFrame tshort) (Etempvar _t'10 tshort)))
          (Ssequence
            (Ssequence
              (Sset _t'9
                (Efield
                  (Ederef (Etempvar _anim (tptr (Tstruct _Animation noattr)))
                    (Tstruct _Animation noattr)) _flags tshort))
              (Sassign (Evar _gCurrAnimEnabled tuchar)
                (Ebinop Oeq
                  (Ebinop Oand (Etempvar _t'9 tshort)
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 5) tint) tint) tint)
                  (Econst_int (Int.repr 0) tint) tint)))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'8
                    (Efield
                      (Ederef
                        (Etempvar _anim (tptr (Tstruct _Animation noattr)))
                        (Tstruct _Animation noattr)) _index (tptr tushort)))
                  (Scall (Some _t'2)
                    (Evar _segmented_to_virtual (Tfunction
                                                  ((tptr tvoid) :: nil)
                                                  (tptr tvoid) cc_default))
                    ((Ecast (Etempvar _t'8 (tptr tushort)) (tptr tvoid)) ::
                     nil)))
                (Sassign (Evar _gCurrAnimAttribute (tptr tushort))
                  (Etempvar _t'2 (tptr tvoid))))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'7
                      (Efield
                        (Ederef
                          (Etempvar _anim (tptr (Tstruct _Animation noattr)))
                          (Tstruct _Animation noattr)) _values (tptr tshort)))
                    (Scall (Some _t'3)
                      (Evar _segmented_to_virtual (Tfunction
                                                    ((tptr tvoid) :: nil)
                                                    (tptr tvoid) cc_default))
                      ((Ecast (Etempvar _t'7 (tptr tshort)) (tptr tvoid)) ::
                       nil)))
                  (Sassign (Evar _gCurrAnimData (tptr tshort))
                    (Etempvar _t'3 (tptr tvoid))))
                (Ssequence
                  (Sset _t'4
                    (Efield
                      (Ederef
                        (Etempvar _anim (tptr (Tstruct _Animation noattr)))
                        (Tstruct _Animation noattr)) _animYTransDivisor
                      tshort))
                  (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tshort)
                                 (Econst_int (Int.repr 0) tint) tint)
                    (Sassign (Evar _gCurrAnimTranslationMultiplier tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat))
                    (Ssequence
                      (Sset _t'5
                        (Efield
                          (Ederef
                            (Etempvar _node (tptr (Tstruct _AnimInfo noattr)))
                            (Tstruct _AnimInfo noattr)) _animYTrans tshort))
                      (Ssequence
                        (Sset _t'6
                          (Efield
                            (Ederef
                              (Etempvar _anim (tptr (Tstruct _Animation noattr)))
                              (Tstruct _Animation noattr)) _animYTransDivisor
                            tshort))
                        (Sassign
                          (Evar _gCurrAnimTranslationMultiplier tfloat)
                          (Ebinop Odiv (Ecast (Etempvar _t'5 tshort) tfloat)
                            (Ecast (Etempvar _t'6 tshort) tfloat) tfloat))))))))))))))
|}.

Definition f_geo_process_shadow := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _GraphNodeShadow noattr))) :: nil);
  fn_vars := ((_mtxf, (tarray (tarray tfloat 4) 4)) ::
              (_shadowPos, (tarray tfloat 3)) ::
              (_animOffset, (tarray tfloat 3)) :: nil);
  fn_temps := ((_shadowList, (tptr (Tunion __512 noattr))) ::
               (_objScale, tfloat) :: (_shadowScale, tfloat) ::
               (_sinAng, tfloat) :: (_cosAng, tfloat) ::
               (_geo, (tptr (Tstruct _GraphNode noattr))) ::
               (_mtx, (tptr (Tunion __472 noattr))) :: (_t'7, tint) ::
               (_t'6, (tptr tvoid)) ::
               (_t'5, (tptr (Tunion __512 noattr))) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'58, (tptr (Tstruct _GraphNodeObject noattr))) ::
               (_t'57, (tptr (Tstruct _GraphNodeCamera noattr))) ::
               (_t'56, (tptr (tarray (tarray tfloat 4) 4))) ::
               (_t'55, (tptr (Tstruct _GraphNodeCamera noattr))) ::
               (_t'54, tshort) :: (_t'53, tshort) ::
               (_t'52, (tptr (Tstruct _GraphNodeObject noattr))) ::
               (_t'51, tfloat) ::
               (_t'50, (tptr (Tstruct _GraphNodeObject noattr))) ::
               (_t'49, tshort) ::
               (_t'48, (tptr (Tstruct _GraphNodeHeldObject noattr))) ::
               (_t'47, tuchar) :: (_t'46, tuchar) :: (_t'45, tshort) ::
               (_t'44, tshort) :: (_t'43, tfloat) :: (_t'42, tshort) ::
               (_t'41, (tptr tshort)) :: (_t'40, (tptr tushort)) ::
               (_t'39, tshort) :: (_t'38, tfloat) :: (_t'37, tshort) ::
               (_t'36, (tptr tshort)) :: (_t'35, (tptr tushort)) ::
               (_t'34, tshort) ::
               (_t'33, (tptr (Tstruct _GraphNodeObject noattr))) ::
               (_t'32, tshort) ::
               (_t'31, (tptr (Tstruct _GraphNodeObject noattr))) ::
               (_t'30, tfloat) :: (_t'29, tfloat) :: (_t'28, tfloat) ::
               (_t'27, tfloat) :: (_t'26, tfloat) :: (_t'25, tfloat) ::
               (_t'24, tuchar) :: (_t'23, tuchar) :: (_t'22, tuchar) ::
               (_t'21, tfloat) :: (_t'20, tfloat) :: (_t'19, tfloat) ::
               (_t'18, tshort) ::
               (_t'17, (tptr (tarray (tarray tfloat 4) 4))) ::
               (_t'16, (tptr (Tstruct _GraphNodeCamera noattr))) ::
               (_t'15, tshort) :: (_t'14, tshort) :: (_t'13, tshort) ::
               (_t'12, tschar) :: (_t'11, tschar) :: (_t'10, tshort) ::
               (_t'9, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'8, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'57
        (Evar _gCurGraphNodeCamera (tptr (Tstruct _GraphNodeCamera noattr))))
      (Sifthenelse (Ebinop One
                     (Etempvar _t'57 (tptr (Tstruct _GraphNodeCamera noattr)))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Ssequence
          (Sset _t'58
            (Evar _gCurGraphNodeObject (tptr (Tstruct _GraphNodeObject noattr))))
          (Sset _t'7
            (Ecast
              (Ebinop One
                (Etempvar _t'58 (tptr (Tstruct _GraphNodeObject noattr)))
                (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
              tbool)))
        (Sset _t'7 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'7 tint)
      (Ssequence
        (Ssequence
          (Sset _t'48
            (Evar _gCurGraphNodeHeldObject (tptr (Tstruct _GraphNodeHeldObject noattr))))
          (Sifthenelse (Ebinop One
                         (Etempvar _t'48 (tptr (Tstruct _GraphNodeHeldObject noattr)))
                         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                         tint)
            (Ssequence
              (Ssequence
                (Sset _t'54 (Evar _gMatStackIndex tshort))
                (Ssequence
                  (Sset _t'55
                    (Evar _gCurGraphNodeCamera (tptr (Tstruct _GraphNodeCamera noattr))))
                  (Ssequence
                    (Sset _t'56
                      (Efield
                        (Ederef
                          (Etempvar _t'55 (tptr (Tstruct _GraphNodeCamera noattr)))
                          (Tstruct _GraphNodeCamera noattr)) _matrixPtr
                        (tptr (tarray (tarray tfloat 4) 4))))
                    (Scall None
                      (Evar _get_pos_from_transform_mtx (Tfunction
                                                          ((tptr tfloat) ::
                                                           (tptr (tarray tfloat 4)) ::
                                                           (tptr (tarray tfloat 4)) ::
                                                           nil) tvoid
                                                          cc_default))
                      ((Evar _shadowPos (tarray tfloat 3)) ::
                       (Ederef
                         (Ebinop Oadd
                           (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                           (Etempvar _t'54 tshort)
                           (tptr (tarray (tarray tfloat 4) 4)))
                         (tarray (tarray tfloat 4) 4)) ::
                       (Ederef
                         (Etempvar _t'56 (tptr (tarray (tarray tfloat 4) 4)))
                         (tarray (tarray tfloat 4) 4)) :: nil)))))
              (Ssequence
                (Sset _t'53
                  (Efield
                    (Ederef
                      (Etempvar _node (tptr (Tstruct _GraphNodeShadow noattr)))
                      (Tstruct _GraphNodeShadow noattr)) _shadowScale tshort))
                (Sset _shadowScale (Ecast (Etempvar _t'53 tshort) tfloat))))
            (Ssequence
              (Ssequence
                (Sset _t'52
                  (Evar _gCurGraphNodeObject (tptr (Tstruct _GraphNodeObject noattr))))
                (Scall None
                  (Evar _vec3f_copy (Tfunction
                                      ((tptr tfloat) :: (tptr tfloat) :: nil)
                                      (tptr tvoid) cc_default))
                  ((Evar _shadowPos (tarray tfloat 3)) ::
                   (Efield
                     (Ederef
                       (Etempvar _t'52 (tptr (Tstruct _GraphNodeObject noattr)))
                       (Tstruct _GraphNodeObject noattr)) _pos
                     (tarray tfloat 3)) :: nil)))
              (Ssequence
                (Sset _t'49
                  (Efield
                    (Ederef
                      (Etempvar _node (tptr (Tstruct _GraphNodeShadow noattr)))
                      (Tstruct _GraphNodeShadow noattr)) _shadowScale tshort))
                (Ssequence
                  (Sset _t'50
                    (Evar _gCurGraphNodeObject (tptr (Tstruct _GraphNodeObject noattr))))
                  (Ssequence
                    (Sset _t'51
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _t'50 (tptr (Tstruct _GraphNodeObject noattr)))
                              (Tstruct _GraphNodeObject noattr)) _scale
                            (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                          (tptr tfloat)) tfloat))
                    (Sset _shadowScale
                      (Ebinop Omul (Etempvar _t'49 tshort)
                        (Etempvar _t'51 tfloat) tfloat))))))))
        (Ssequence
          (Sset _objScale
            (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat))
          (Ssequence
            (Ssequence
              (Sset _t'24 (Evar _gCurrAnimEnabled tuchar))
              (Sifthenelse (Etempvar _t'24 tuchar)
                (Ssequence
                  (Ssequence
                    (Sset _t'46 (Evar _gCurrAnimType tuchar))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'46 tuchar)
                                   (Econst_int (Int.repr 1) tint) tint)
                      (Sset _t'4 (Econst_int (Int.repr 1) tint))
                      (Ssequence
                        (Sset _t'47 (Evar _gCurrAnimType tuchar))
                        (Sset _t'4
                          (Ecast
                            (Ebinop Oeq (Etempvar _t'47 tuchar)
                              (Econst_int (Int.repr 3) tint) tint) tbool)))))
                  (Sifthenelse (Etempvar _t'4 tint)
                    (Ssequence
                      (Sset _geo
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _node (tptr (Tstruct _GraphNodeShadow noattr)))
                              (Tstruct _GraphNodeShadow noattr)) _node
                            (Tstruct _GraphNode noattr)) _children
                          (tptr (Tstruct _GraphNode noattr))))
                      (Ssequence
                        (Ssequence
                          (Sifthenelse (Ebinop One
                                         (Etempvar _geo (tptr (Tstruct _GraphNode noattr)))
                                         (Ecast
                                           (Econst_int (Int.repr 0) tint)
                                           (tptr tvoid)) tint)
                            (Ssequence
                              (Sset _t'45
                                (Efield
                                  (Ederef
                                    (Etempvar _geo (tptr (Tstruct _GraphNode noattr)))
                                    (Tstruct _GraphNode noattr)) _type
                                  tshort))
                              (Sset _t'1
                                (Ecast
                                  (Ebinop Oeq (Etempvar _t'45 tshort)
                                    (Econst_int (Int.repr 28) tint) tint)
                                  tbool)))
                            (Sset _t'1 (Econst_int (Int.repr 0) tint)))
                          (Sifthenelse (Etempvar _t'1 tint)
                            (Sset _objScale
                              (Efield
                                (Ederef
                                  (Ecast
                                    (Etempvar _geo (tptr (Tstruct _GraphNode noattr)))
                                    (tptr (Tstruct _GraphNodeScale noattr)))
                                  (Tstruct _GraphNodeScale noattr)) _scale
                                tfloat))
                            Sskip))
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Sset _t'44 (Evar _gCurrAnimFrame tshort))
                              (Scall (Some _t'2)
                                (Evar _retrieve_animation_index (Tfunction
                                                                  (tint ::
                                                                   (tptr (tptr tushort)) ::
                                                                   nil) tint
                                                                  cc_default))
                                ((Etempvar _t'44 tshort) ::
                                 (Eaddrof
                                   (Evar _gCurrAnimAttribute (tptr tushort))
                                   (tptr (tptr tushort))) :: nil)))
                            (Ssequence
                              (Sset _t'41
                                (Evar _gCurrAnimData (tptr tshort)))
                              (Ssequence
                                (Sset _t'42
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'41 (tptr tshort))
                                      (Etempvar _t'2 tint) (tptr tshort))
                                    tshort))
                                (Ssequence
                                  (Sset _t'43
                                    (Evar _gCurrAnimTranslationMultiplier tfloat))
                                  (Sassign
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _animOffset (tarray tfloat 3))
                                        (Econst_int (Int.repr 0) tint)
                                        (tptr tfloat)) tfloat)
                                    (Ebinop Omul
                                      (Ebinop Omul (Etempvar _t'42 tshort)
                                        (Etempvar _t'43 tfloat) tfloat)
                                      (Etempvar _objScale tfloat) tfloat))))))
                          (Ssequence
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Evar _animOffset (tarray tfloat 3))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tfloat)) tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                            (Ssequence
                              (Ssequence
                                (Sset _t'40
                                  (Evar _gCurrAnimAttribute (tptr tushort)))
                                (Sassign
                                  (Evar _gCurrAnimAttribute (tptr tushort))
                                  (Ebinop Oadd
                                    (Etempvar _t'40 (tptr tushort))
                                    (Econst_int (Int.repr 2) tint)
                                    (tptr tushort))))
                              (Ssequence
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'39
                                      (Evar _gCurrAnimFrame tshort))
                                    (Scall (Some _t'3)
                                      (Evar _retrieve_animation_index 
                                      (Tfunction
                                        (tint :: (tptr (tptr tushort)) ::
                                         nil) tint cc_default))
                                      ((Etempvar _t'39 tshort) ::
                                       (Eaddrof
                                         (Evar _gCurrAnimAttribute (tptr tushort))
                                         (tptr (tptr tushort))) :: nil)))
                                  (Ssequence
                                    (Sset _t'36
                                      (Evar _gCurrAnimData (tptr tshort)))
                                    (Ssequence
                                      (Sset _t'37
                                        (Ederef
                                          (Ebinop Oadd
                                            (Etempvar _t'36 (tptr tshort))
                                            (Etempvar _t'3 tint)
                                            (tptr tshort)) tshort))
                                      (Ssequence
                                        (Sset _t'38
                                          (Evar _gCurrAnimTranslationMultiplier tfloat))
                                        (Sassign
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _animOffset (tarray tfloat 3))
                                              (Econst_int (Int.repr 2) tint)
                                              (tptr tfloat)) tfloat)
                                          (Ebinop Omul
                                            (Ebinop Omul
                                              (Etempvar _t'37 tshort)
                                              (Etempvar _t'38 tfloat) tfloat)
                                            (Etempvar _objScale tfloat)
                                            tfloat))))))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'35
                                      (Evar _gCurrAnimAttribute (tptr tushort)))
                                    (Sassign
                                      (Evar _gCurrAnimAttribute (tptr tushort))
                                      (Ebinop Osub
                                        (Etempvar _t'35 (tptr tushort))
                                        (Econst_int (Int.repr 6) tint)
                                        (tptr tushort))))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'33
                                        (Evar _gCurGraphNodeObject (tptr (Tstruct _GraphNodeObject noattr))))
                                      (Ssequence
                                        (Sset _t'34
                                          (Ederef
                                            (Ebinop Oadd
                                              (Efield
                                                (Ederef
                                                  (Etempvar _t'33 (tptr (Tstruct _GraphNodeObject noattr)))
                                                  (Tstruct _GraphNodeObject noattr))
                                                _angle (tarray tshort 3))
                                              (Econst_int (Int.repr 1) tint)
                                              (tptr tshort)) tshort))
                                        (Sset _sinAng
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _gSineTable (tarray tfloat 0))
                                              (Ebinop Oshr
                                                (Ecast
                                                  (Etempvar _t'34 tshort)
                                                  tushort)
                                                (Econst_int (Int.repr 4) tint)
                                                tint) (tptr tfloat)) tfloat))))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'31
                                          (Evar _gCurGraphNodeObject (tptr (Tstruct _GraphNodeObject noattr))))
                                        (Ssequence
                                          (Sset _t'32
                                            (Ederef
                                              (Ebinop Oadd
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _t'31 (tptr (Tstruct _GraphNodeObject noattr)))
                                                    (Tstruct _GraphNodeObject noattr))
                                                  _angle (tarray tshort 3))
                                                (Econst_int (Int.repr 1) tint)
                                                (tptr tshort)) tshort))
                                          (Sset _cosAng
                                            (Ederef
                                              (Ebinop Oadd
                                                (Ebinop Oadd
                                                  (Evar _gSineTable (tarray tfloat 0))
                                                  (Econst_int (Int.repr 1024) tint)
                                                  (tptr tfloat))
                                                (Ebinop Oshr
                                                  (Ecast
                                                    (Etempvar _t'32 tshort)
                                                    tushort)
                                                  (Econst_int (Int.repr 4) tint)
                                                  tint) (tptr tfloat))
                                              tfloat))))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'28
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _shadowPos (tarray tfloat 3))
                                                (Econst_int (Int.repr 0) tint)
                                                (tptr tfloat)) tfloat))
                                          (Ssequence
                                            (Sset _t'29
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _animOffset (tarray tfloat 3))
                                                  (Econst_int (Int.repr 0) tint)
                                                  (tptr tfloat)) tfloat))
                                            (Ssequence
                                              (Sset _t'30
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Evar _animOffset (tarray tfloat 3))
                                                    (Econst_int (Int.repr 2) tint)
                                                    (tptr tfloat)) tfloat))
                                              (Sassign
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Evar _shadowPos (tarray tfloat 3))
                                                    (Econst_int (Int.repr 0) tint)
                                                    (tptr tfloat)) tfloat)
                                                (Ebinop Oadd
                                                  (Etempvar _t'28 tfloat)
                                                  (Ebinop Oadd
                                                    (Ebinop Omul
                                                      (Etempvar _t'29 tfloat)
                                                      (Etempvar _cosAng tfloat)
                                                      tfloat)
                                                    (Ebinop Omul
                                                      (Etempvar _t'30 tfloat)
                                                      (Etempvar _sinAng tfloat)
                                                      tfloat) tfloat) tfloat)))))
                                        (Ssequence
                                          (Sset _t'25
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _shadowPos (tarray tfloat 3))
                                                (Econst_int (Int.repr 2) tint)
                                                (tptr tfloat)) tfloat))
                                          (Ssequence
                                            (Sset _t'26
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _animOffset (tarray tfloat 3))
                                                  (Econst_int (Int.repr 0) tint)
                                                  (tptr tfloat)) tfloat))
                                            (Ssequence
                                              (Sset _t'27
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Evar _animOffset (tarray tfloat 3))
                                                    (Econst_int (Int.repr 2) tint)
                                                    (tptr tfloat)) tfloat))
                                              (Sassign
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Evar _shadowPos (tarray tfloat 3))
                                                    (Econst_int (Int.repr 2) tint)
                                                    (tptr tfloat)) tfloat)
                                                (Ebinop Oadd
                                                  (Etempvar _t'25 tfloat)
                                                  (Ebinop Oadd
                                                    (Ebinop Omul
                                                      (Eunop Oneg
                                                        (Etempvar _t'26 tfloat)
                                                        tfloat)
                                                      (Etempvar _sinAng tfloat)
                                                      tfloat)
                                                    (Ebinop Omul
                                                      (Etempvar _t'27 tfloat)
                                                      (Etempvar _cosAng tfloat)
                                                      tfloat) tfloat) tfloat)))))))))))))))
                    Sskip))
                Sskip))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'19
                    (Ederef
                      (Ebinop Oadd (Evar _shadowPos (tarray tfloat 3))
                        (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
                  (Ssequence
                    (Sset _t'20
                      (Ederef
                        (Ebinop Oadd (Evar _shadowPos (tarray tfloat 3))
                          (Econst_int (Int.repr 1) tint) (tptr tfloat))
                        tfloat))
                    (Ssequence
                      (Sset _t'21
                        (Ederef
                          (Ebinop Oadd (Evar _shadowPos (tarray tfloat 3))
                            (Econst_int (Int.repr 2) tint) (tptr tfloat))
                          tfloat))
                      (Ssequence
                        (Sset _t'22
                          (Efield
                            (Ederef
                              (Etempvar _node (tptr (Tstruct _GraphNodeShadow noattr)))
                              (Tstruct _GraphNodeShadow noattr))
                            _shadowSolidity tuchar))
                        (Ssequence
                          (Sset _t'23
                            (Efield
                              (Ederef
                                (Etempvar _node (tptr (Tstruct _GraphNodeShadow noattr)))
                                (Tstruct _GraphNodeShadow noattr))
                              _shadowType tuchar))
                          (Scall (Some _t'5)
                            (Evar _create_shadow_below_xyz (Tfunction
                                                             (tfloat ::
                                                              tfloat ::
                                                              tfloat ::
                                                              tshort ::
                                                              tuchar ::
                                                              tschar :: nil)
                                                             (tptr (Tunion __512 noattr))
                                                             cc_default))
                            ((Etempvar _t'19 tfloat) ::
                             (Etempvar _t'20 tfloat) ::
                             (Etempvar _t'21 tfloat) ::
                             (Etempvar _shadowScale tfloat) ::
                             (Etempvar _t'22 tuchar) ::
                             (Etempvar _t'23 tuchar) :: nil)))))))
                (Sset _shadowList
                  (Etempvar _t'5 (tptr (Tunion __512 noattr)))))
              (Sifthenelse (Ebinop One
                             (Etempvar _shadowList (tptr (Tunion __512 noattr)))
                             (Ecast (Econst_int (Int.repr 0) tint)
                               (tptr tvoid)) tint)
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'6)
                      (Evar _alloc_display_list (Tfunction (tuint :: nil)
                                                  (tptr tvoid) cc_default))
                      ((Esizeof (Tunion __472 noattr) tuint) :: nil))
                    (Sset _mtx (Etempvar _t'6 (tptr tvoid))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'18 (Evar _gMatStackIndex tshort))
                      (Sassign (Evar _gMatStackIndex tshort)
                        (Ebinop Oadd (Etempvar _t'18 tshort)
                          (Econst_int (Int.repr 1) tint) tint)))
                    (Ssequence
                      (Scall None
                        (Evar _mtxf_translate (Tfunction
                                                ((tptr (tarray tfloat 4)) ::
                                                 (tptr tfloat) :: nil) tvoid
                                                cc_default))
                        ((Evar _mtxf (tarray (tarray tfloat 4) 4)) ::
                         (Evar _shadowPos (tarray tfloat 3)) :: nil))
                      (Ssequence
                        (Ssequence
                          (Sset _t'15 (Evar _gMatStackIndex tshort))
                          (Ssequence
                            (Sset _t'16
                              (Evar _gCurGraphNodeCamera (tptr (Tstruct _GraphNodeCamera noattr))))
                            (Ssequence
                              (Sset _t'17
                                (Efield
                                  (Ederef
                                    (Etempvar _t'16 (tptr (Tstruct _GraphNodeCamera noattr)))
                                    (Tstruct _GraphNodeCamera noattr))
                                  _matrixPtr
                                  (tptr (tarray (tarray tfloat 4) 4))))
                              (Scall None
                                (Evar _mtxf_mul (Tfunction
                                                  ((tptr (tarray tfloat 4)) ::
                                                   (tptr (tarray tfloat 4)) ::
                                                   (tptr (tarray tfloat 4)) ::
                                                   nil) tvoid cc_default))
                                ((Ederef
                                   (Ebinop Oadd
                                     (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                     (Etempvar _t'15 tshort)
                                     (tptr (tarray (tarray tfloat 4) 4)))
                                   (tarray (tarray tfloat 4) 4)) ::
                                 (Evar _mtxf (tarray (tarray tfloat 4) 4)) ::
                                 (Ederef
                                   (Etempvar _t'17 (tptr (tarray (tarray tfloat 4) 4)))
                                   (tarray (tarray tfloat 4) 4)) :: nil)))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'14 (Evar _gMatStackIndex tshort))
                            (Scall None
                              (Evar _mtxf_to_mtx (Tfunction
                                                   ((tptr (Tunion __472 noattr)) ::
                                                    (tptr (tarray tfloat 4)) ::
                                                    nil) tvoid cc_default))
                              ((Etempvar _mtx (tptr (Tunion __472 noattr))) ::
                               (Ederef
                                 (Ebinop Oadd
                                   (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                   (Etempvar _t'14 tshort)
                                   (tptr (tarray (tarray tfloat 4) 4)))
                                 (tarray (tarray tfloat 4) 4)) :: nil)))
                          (Ssequence
                            (Ssequence
                              (Sset _t'13 (Evar _gMatStackIndex tshort))
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _gMatStackFixed (tarray (tptr (Tunion __472 noattr)) 32))
                                    (Etempvar _t'13 tshort)
                                    (tptr (tptr (Tunion __472 noattr))))
                                  (tptr (Tunion __472 noattr)))
                                (Etempvar _mtx (tptr (Tunion __472 noattr)))))
                            (Ssequence
                              (Ssequence
                                (Sset _t'11
                                  (Evar _gShadowAboveWaterOrLava tschar))
                                (Sifthenelse (Ebinop Oeq
                                               (Etempvar _t'11 tschar)
                                               (Econst_int (Int.repr 1) tint)
                                               tint)
                                  (Scall None
                                    (Evar _geo_append_display_list (Tfunction
                                                                    ((tptr tvoid) ::
                                                                    tshort ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                    ((Ecast
                                       (Ebinop Oand
                                         (Ecast
                                           (Etempvar _shadowList (tptr (Tunion __512 noattr)))
                                           tuint)
                                         (Econst_int (Int.repr 536870911) tint)
                                         tuint) (tptr tvoid)) ::
                                     (Econst_int (Int.repr 4) tint) :: nil))
                                  (Ssequence
                                    (Sset _t'12
                                      (Evar _gMarioOnIceOrCarpet tschar))
                                    (Sifthenelse (Ebinop Oeq
                                                   (Etempvar _t'12 tschar)
                                                   (Econst_int (Int.repr 1) tint)
                                                   tint)
                                      (Scall None
                                        (Evar _geo_append_display_list 
                                        (Tfunction
                                          ((tptr tvoid) :: tshort :: nil)
                                          tvoid cc_default))
                                        ((Ecast
                                           (Ebinop Oand
                                             (Ecast
                                               (Etempvar _shadowList (tptr (Tunion __512 noattr)))
                                               tuint)
                                             (Econst_int (Int.repr 536870911) tint)
                                             tuint) (tptr tvoid)) ::
                                         (Econst_int (Int.repr 5) tint) ::
                                         nil))
                                      (Scall None
                                        (Evar _geo_append_display_list 
                                        (Tfunction
                                          ((tptr tvoid) :: tshort :: nil)
                                          tvoid cc_default))
                                        ((Ecast
                                           (Ebinop Oand
                                             (Ecast
                                               (Etempvar _shadowList (tptr (Tunion __512 noattr)))
                                               tuint)
                                             (Econst_int (Int.repr 536870911) tint)
                                             tuint) (tptr tvoid)) ::
                                         (Econst_int (Int.repr 6) tint) ::
                                         nil))))))
                              (Ssequence
                                (Sset _t'10 (Evar _gMatStackIndex tshort))
                                (Sassign (Evar _gMatStackIndex tshort)
                                  (Ebinop Osub (Etempvar _t'10 tshort)
                                    (Econst_int (Int.repr 1) tint) tint))))))))))
                Sskip)))))
      Sskip))
  (Ssequence
    (Sset _t'8
      (Efield
        (Efield
          (Ederef (Etempvar _node (tptr (Tstruct _GraphNodeShadow noattr)))
            (Tstruct _GraphNodeShadow noattr)) _node
          (Tstruct _GraphNode noattr)) _children
        (tptr (Tstruct _GraphNode noattr))))
    (Sifthenelse (Ebinop One
                   (Etempvar _t'8 (tptr (Tstruct _GraphNode noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Sset _t'9
          (Efield
            (Efield
              (Ederef
                (Etempvar _node (tptr (Tstruct _GraphNodeShadow noattr)))
                (Tstruct _GraphNodeShadow noattr)) _node
              (Tstruct _GraphNode noattr)) _children
            (tptr (Tstruct _GraphNode noattr))))
        (Scall None
          (Evar _geo_process_node_and_siblings (Tfunction
                                                 ((tptr (Tstruct _GraphNode noattr)) ::
                                                  nil) tvoid cc_default))
          ((Etempvar _t'9 (tptr (Tstruct _GraphNode noattr))) :: nil)))
      Sskip)))
|}.

Definition f_obj_is_in_view := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _GraphNodeObject noattr))) ::
                (_matrix, (tptr (tarray tfloat 4))) :: nil);
  fn_vars := nil;
  fn_temps := ((_cullingRadius, tshort) :: (_halfFov, tshort) ::
               (_geo, (tptr (Tstruct _GraphNode noattr))) ::
               (_hScreenEdge, tfloat) :: (_t'1, tint) :: (_t'13, tshort) ::
               (_t'12, tfloat) ::
               (_t'11, (tptr (Tstruct _GraphNodePerspective noattr))) ::
               (_t'10, tfloat) :: (_t'9, tfloat) :: (_t'8, tfloat) ::
               (_t'7, tshort) :: (_t'6, tshort) :: (_t'5, tfloat) ::
               (_t'4, tfloat) :: (_t'3, tfloat) :: (_t'2, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'13
      (Efield
        (Efield
          (Ederef (Etempvar _node (tptr (Tstruct _GraphNodeObject noattr)))
            (Tstruct _GraphNodeObject noattr)) _node
          (Tstruct _GraphNode noattr)) _flags tshort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'13 tshort)
                   (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                     (Econst_int (Int.repr 4) tint) tint) tint)
      (Sreturn (Some (Econst_int (Int.repr 0) tint)))
      Sskip))
  (Ssequence
    (Sset _geo
      (Efield
        (Ederef (Etempvar _node (tptr (Tstruct _GraphNodeObject noattr)))
          (Tstruct _GraphNodeObject noattr)) _sharedChild
        (tptr (Tstruct _GraphNode noattr))))
    (Ssequence
      (Ssequence
        (Sset _t'11
          (Evar _gCurGraphNodeCamFrustum (tptr (Tstruct _GraphNodePerspective noattr))))
        (Ssequence
          (Sset _t'12
            (Efield
              (Ederef
                (Etempvar _t'11 (tptr (Tstruct _GraphNodePerspective noattr)))
                (Tstruct _GraphNodePerspective noattr)) _fov tfloat))
          (Sset _halfFov
            (Ecast
              (Ebinop Oadd
                (Ebinop Odiv
                  (Ebinop Omul
                    (Ebinop Oadd
                      (Ebinop Odiv (Etempvar _t'12 tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                        tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                      tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1191182336)) tfloat)
                    tfloat)
                  (Econst_single (Float32.of_bits (Int.repr 1127481344)) tfloat)
                  tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat)
                tfloat) tshort))))
      (Ssequence
        (Ssequence
          (Sset _t'8
            (Ederef
              (Ebinop Oadd
                (Ederef
                  (Ebinop Oadd (Etempvar _matrix (tptr (tarray tfloat 4)))
                    (Econst_int (Int.repr 3) tint) (tptr (tarray tfloat 4)))
                  (tarray tfloat 4)) (Econst_int (Int.repr 2) tint)
                (tptr tfloat)) tfloat))
          (Ssequence
            (Sset _t'9
              (Ederef
                (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                  (Ebinop Oshr (Ecast (Etempvar _halfFov tshort) tushort)
                    (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                tfloat))
            (Ssequence
              (Sset _t'10
                (Ederef
                  (Ebinop Oadd
                    (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                      (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                    (Ebinop Oshr (Ecast (Etempvar _halfFov tshort) tushort)
                      (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                  tfloat))
              (Sset _hScreenEdge
                (Ebinop Odiv
                  (Ebinop Omul (Eunop Oneg (Etempvar _t'8 tfloat) tfloat)
                    (Etempvar _t'9 tfloat) tfloat) (Etempvar _t'10 tfloat)
                  tfloat)))))
        (Ssequence
          (Ssequence
            (Sifthenelse (Ebinop One
                           (Etempvar _geo (tptr (Tstruct _GraphNode noattr)))
                           (Ecast (Econst_int (Int.repr 0) tint)
                             (tptr tvoid)) tint)
              (Ssequence
                (Sset _t'7
                  (Efield
                    (Ederef
                      (Etempvar _geo (tptr (Tstruct _GraphNode noattr)))
                      (Tstruct _GraphNode noattr)) _type tshort))
                (Sset _t'1
                  (Ecast
                    (Ebinop Oeq (Etempvar _t'7 tshort)
                      (Econst_int (Int.repr 47) tint) tint) tbool)))
              (Sset _t'1 (Econst_int (Int.repr 0) tint)))
            (Sifthenelse (Etempvar _t'1 tint)
              (Ssequence
                (Sset _t'6
                  (Efield
                    (Ederef
                      (Ecast
                        (Etempvar _geo (tptr (Tstruct _GraphNode noattr)))
                        (tptr (Tstruct _GraphNodeCullingRadius noattr)))
                      (Tstruct _GraphNodeCullingRadius noattr))
                    _cullingRadius tshort))
                (Sset _cullingRadius
                  (Ecast (Ecast (Etempvar _t'6 tshort) tfloat) tshort)))
              (Sset _cullingRadius
                (Ecast (Econst_int (Int.repr 300) tint) tshort))))
          (Ssequence
            (Ssequence
              (Sset _t'5
                (Ederef
                  (Ebinop Oadd
                    (Ederef
                      (Ebinop Oadd
                        (Etempvar _matrix (tptr (tarray tfloat 4)))
                        (Econst_int (Int.repr 3) tint)
                        (tptr (tarray tfloat 4))) (tarray tfloat 4))
                    (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
              (Sifthenelse (Ebinop Ogt (Etempvar _t'5 tfloat)
                             (Ebinop Oadd
                               (Eunop Oneg
                                 (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                                 tfloat) (Etempvar _cullingRadius tshort)
                               tfloat) tint)
                (Sreturn (Some (Econst_int (Int.repr 0) tint)))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'4
                  (Ederef
                    (Ebinop Oadd
                      (Ederef
                        (Ebinop Oadd
                          (Etempvar _matrix (tptr (tarray tfloat 4)))
                          (Econst_int (Int.repr 3) tint)
                          (tptr (tarray tfloat 4))) (tarray tfloat 4))
                      (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
                (Sifthenelse (Ebinop Olt (Etempvar _t'4 tfloat)
                               (Ebinop Osub
                                 (Eunop Oneg
                                   (Econst_single (Float32.of_bits (Int.repr 1184645120)) tfloat)
                                   tfloat) (Etempvar _cullingRadius tshort)
                                 tfloat) tint)
                  (Sreturn (Some (Econst_int (Int.repr 0) tint)))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _t'3
                    (Ederef
                      (Ebinop Oadd
                        (Ederef
                          (Ebinop Oadd
                            (Etempvar _matrix (tptr (tarray tfloat 4)))
                            (Econst_int (Int.repr 3) tint)
                            (tptr (tarray tfloat 4))) (tarray tfloat 4))
                        (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
                  (Sifthenelse (Ebinop Ogt (Etempvar _t'3 tfloat)
                                 (Ebinop Oadd (Etempvar _hScreenEdge tfloat)
                                   (Etempvar _cullingRadius tshort) tfloat)
                                 tint)
                    (Sreturn (Some (Econst_int (Int.repr 0) tint)))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sset _t'2
                      (Ederef
                        (Ebinop Oadd
                          (Ederef
                            (Ebinop Oadd
                              (Etempvar _matrix (tptr (tarray tfloat 4)))
                              (Econst_int (Int.repr 3) tint)
                              (tptr (tarray tfloat 4))) (tarray tfloat 4))
                          (Econst_int (Int.repr 0) tint) (tptr tfloat))
                        tfloat))
                    (Sifthenelse (Ebinop Olt (Etempvar _t'2 tfloat)
                                   (Ebinop Osub
                                     (Eunop Oneg
                                       (Etempvar _hScreenEdge tfloat) tfloat)
                                     (Etempvar _cullingRadius tshort) tfloat)
                                   tint)
                      (Sreturn (Some (Econst_int (Int.repr 0) tint)))
                      Sskip))
                  (Sreturn (Some (Econst_int (Int.repr 1) tint))))))))))))
|}.

Definition f_geo_process_object := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := ((_mtxf, (tarray (tarray tfloat 4) 4)) :: nil);
  fn_temps := ((_hasAnimation, tint) ::
               (_mtx, (tptr (Tunion __472 noattr))) :: (_t'3, tint) ::
               (_t'2, (tptr tvoid)) :: (_t'1, tshort) :: (_t'38, tshort) ::
               (_t'37, tshort) ::
               (_t'36, (tptr (tarray (tarray tfloat 4) 4))) ::
               (_t'35, tshort) :: (_t'34, tshort) ::
               (_t'33, (tptr (Tstruct _GraphNodeCamera noattr))) ::
               (_t'32, tshort) :: (_t'31, tshort) :: (_t'30, tshort) ::
               (_t'29, tshort) :: (_t'28, tshort) ::
               (_t'27, (tptr (tarray (tarray tfloat 4) 4))) ::
               (_t'26, tshort) :: (_t'25, tshort) :: (_t'24, tshort) ::
               (_t'23, tfloat) :: (_t'22, tshort) :: (_t'21, tfloat) ::
               (_t'20, tshort) :: (_t'19, tfloat) :: (_t'18, tshort) ::
               (_t'17, (tptr (Tstruct _Animation noattr))) ::
               (_t'16, tshort) :: (_t'15, tshort) :: (_t'14, tshort) ::
               (_t'13, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'12, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'11, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'10, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'9, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'8, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'7, tshort) :: (_t'6, tuchar) ::
               (_t'5, (tptr (Tstruct _GraphNodeRoot noattr))) ::
               (_t'4, tschar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'38
      (Efield
        (Efield
          (Efield
            (Efield
              (Ederef (Etempvar _node (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _header
              (Tstruct _ObjectNode noattr)) _gfx
            (Tstruct _GraphNodeObject noattr)) _node
          (Tstruct _GraphNode noattr)) _flags tshort))
    (Sset _hasAnimation
      (Ebinop One
        (Ebinop Oand (Etempvar _t'38 tshort)
          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
            (Econst_int (Int.repr 5) tint) tint) tint)
        (Econst_int (Int.repr 0) tint) tint)))
  (Ssequence
    (Sset _t'4
      (Efield
        (Efield
          (Efield
            (Ederef (Etempvar _node (tptr (Tstruct _Object noattr)))
              (Tstruct _Object noattr)) _header (Tstruct _ObjectNode noattr))
          _gfx (Tstruct _GraphNodeObject noattr)) _areaIndex tschar))
    (Ssequence
      (Sset _t'5
        (Evar _gCurGraphNodeRoot (tptr (Tstruct _GraphNodeRoot noattr))))
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _t'5 (tptr (Tstruct _GraphNodeRoot noattr)))
              (Tstruct _GraphNodeRoot noattr)) _areaIndex tuchar))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tschar)
                       (Etempvar _t'6 tuchar) tint)
          (Ssequence
            (Ssequence
              (Sset _t'27
                (Efield
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _node (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _header
                      (Tstruct _ObjectNode noattr)) _gfx
                    (Tstruct _GraphNodeObject noattr)) _throwMatrix
                  (tptr (tarray (tarray tfloat 4) 4))))
              (Sifthenelse (Ebinop One
                             (Etempvar _t'27 (tptr (tarray (tarray tfloat 4) 4)))
                             (Ecast (Econst_int (Int.repr 0) tint)
                               (tptr tvoid)) tint)
                (Ssequence
                  (Sset _t'35 (Evar _gMatStackIndex tshort))
                  (Ssequence
                    (Sset _t'36
                      (Efield
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _node (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _header
                            (Tstruct _ObjectNode noattr)) _gfx
                          (Tstruct _GraphNodeObject noattr)) _throwMatrix
                        (tptr (tarray (tarray tfloat 4) 4))))
                    (Ssequence
                      (Sset _t'37 (Evar _gMatStackIndex tshort))
                      (Scall None
                        (Evar _mtxf_mul (Tfunction
                                          ((tptr (tarray tfloat 4)) ::
                                           (tptr (tarray tfloat 4)) ::
                                           (tptr (tarray tfloat 4)) :: nil)
                                          tvoid cc_default))
                        ((Ederef
                           (Ebinop Oadd
                             (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                             (Ebinop Oadd (Etempvar _t'35 tshort)
                               (Econst_int (Int.repr 1) tint) tint)
                             (tptr (tarray (tarray tfloat 4) 4)))
                           (tarray (tarray tfloat 4) 4)) ::
                         (Ederef
                           (Etempvar _t'36 (tptr (tarray (tarray tfloat 4) 4)))
                           (tarray (tarray tfloat 4) 4)) ::
                         (Ederef
                           (Ebinop Oadd
                             (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                             (Etempvar _t'37 tshort)
                             (tptr (tarray (tarray tfloat 4) 4)))
                           (tarray (tarray tfloat 4) 4)) :: nil)))))
                (Ssequence
                  (Sset _t'28
                    (Efield
                      (Efield
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _node (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _header
                            (Tstruct _ObjectNode noattr)) _gfx
                          (Tstruct _GraphNodeObject noattr)) _node
                        (Tstruct _GraphNode noattr)) _flags tshort))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'28 tshort)
                                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                   (Econst_int (Int.repr 2) tint) tint) tint)
                    (Ssequence
                      (Sset _t'31 (Evar _gMatStackIndex tshort))
                      (Ssequence
                        (Sset _t'32 (Evar _gMatStackIndex tshort))
                        (Ssequence
                          (Sset _t'33
                            (Evar _gCurGraphNodeCamera (tptr (Tstruct _GraphNodeCamera noattr))))
                          (Ssequence
                            (Sset _t'34
                              (Efield
                                (Ederef
                                  (Etempvar _t'33 (tptr (Tstruct _GraphNodeCamera noattr)))
                                  (Tstruct _GraphNodeCamera noattr)) _roll
                                tshort))
                            (Scall None
                              (Evar _mtxf_billboard (Tfunction
                                                      ((tptr (tarray tfloat 4)) ::
                                                       (tptr (tarray tfloat 4)) ::
                                                       (tptr tfloat) ::
                                                       tshort :: nil) tvoid
                                                      cc_default))
                              ((Ederef
                                 (Ebinop Oadd
                                   (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                   (Ebinop Oadd (Etempvar _t'31 tshort)
                                     (Econst_int (Int.repr 1) tint) tint)
                                   (tptr (tarray (tarray tfloat 4) 4)))
                                 (tarray (tarray tfloat 4) 4)) ::
                               (Ederef
                                 (Ebinop Oadd
                                   (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                   (Etempvar _t'32 tshort)
                                   (tptr (tarray (tarray tfloat 4) 4)))
                                 (tarray (tarray tfloat 4) 4)) ::
                               (Efield
                                 (Efield
                                   (Efield
                                     (Ederef
                                       (Etempvar _node (tptr (Tstruct _Object noattr)))
                                       (Tstruct _Object noattr)) _header
                                     (Tstruct _ObjectNode noattr)) _gfx
                                   (Tstruct _GraphNodeObject noattr)) _pos
                                 (tarray tfloat 3)) ::
                               (Etempvar _t'34 tshort) :: nil))))))
                    (Ssequence
                      (Scall None
                        (Evar _mtxf_rotate_zxy_and_translate (Tfunction
                                                               ((tptr (tarray tfloat 4)) ::
                                                                (tptr tfloat) ::
                                                                (tptr tshort) ::
                                                                nil) tvoid
                                                               cc_default))
                        ((Evar _mtxf (tarray (tarray tfloat 4) 4)) ::
                         (Efield
                           (Efield
                             (Efield
                               (Ederef
                                 (Etempvar _node (tptr (Tstruct _Object noattr)))
                                 (Tstruct _Object noattr)) _header
                               (Tstruct _ObjectNode noattr)) _gfx
                             (Tstruct _GraphNodeObject noattr)) _pos
                           (tarray tfloat 3)) ::
                         (Efield
                           (Efield
                             (Efield
                               (Ederef
                                 (Etempvar _node (tptr (Tstruct _Object noattr)))
                                 (Tstruct _Object noattr)) _header
                               (Tstruct _ObjectNode noattr)) _gfx
                             (Tstruct _GraphNodeObject noattr)) _angle
                           (tarray tshort 3)) :: nil))
                      (Ssequence
                        (Sset _t'29 (Evar _gMatStackIndex tshort))
                        (Ssequence
                          (Sset _t'30 (Evar _gMatStackIndex tshort))
                          (Scall None
                            (Evar _mtxf_mul (Tfunction
                                              ((tptr (tarray tfloat 4)) ::
                                               (tptr (tarray tfloat 4)) ::
                                               (tptr (tarray tfloat 4)) ::
                                               nil) tvoid cc_default))
                            ((Ederef
                               (Ebinop Oadd
                                 (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                 (Ebinop Oadd (Etempvar _t'29 tshort)
                                   (Econst_int (Int.repr 1) tint) tint)
                                 (tptr (tarray (tarray tfloat 4) 4)))
                               (tarray (tarray tfloat 4) 4)) ::
                             (Evar _mtxf (tarray (tarray tfloat 4) 4)) ::
                             (Ederef
                               (Ebinop Oadd
                                 (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                 (Etempvar _t'30 tshort)
                                 (tptr (tarray (tarray tfloat 4) 4)))
                               (tarray (tarray tfloat 4) 4)) :: nil)))))))))
            (Ssequence
              (Ssequence
                (Sset _t'25 (Evar _gMatStackIndex tshort))
                (Ssequence
                  (Sset _t'26 (Evar _gMatStackIndex tshort))
                  (Scall None
                    (Evar _mtxf_scale_vec3f (Tfunction
                                              ((tptr (tarray tfloat 4)) ::
                                               (tptr (tarray tfloat 4)) ::
                                               (tptr tfloat) :: nil) tvoid
                                              cc_default))
                    ((Ederef
                       (Ebinop Oadd
                         (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                         (Ebinop Oadd (Etempvar _t'25 tshort)
                           (Econst_int (Int.repr 1) tint) tint)
                         (tptr (tarray (tarray tfloat 4) 4)))
                       (tarray (tarray tfloat 4) 4)) ::
                     (Ederef
                       (Ebinop Oadd
                         (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                         (Ebinop Oadd (Etempvar _t'26 tshort)
                           (Econst_int (Int.repr 1) tint) tint)
                         (tptr (tarray (tarray tfloat 4) 4)))
                       (tarray (tarray tfloat 4) 4)) ::
                     (Efield
                       (Efield
                         (Efield
                           (Ederef
                             (Etempvar _node (tptr (Tstruct _Object noattr)))
                             (Tstruct _Object noattr)) _header
                           (Tstruct _ObjectNode noattr)) _gfx
                         (Tstruct _GraphNodeObject noattr)) _scale
                       (tarray tfloat 3)) :: nil))))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'24 (Evar _gMatStackIndex tshort))
                      (Sset _t'1
                        (Ecast
                          (Ebinop Oadd (Etempvar _t'24 tshort)
                            (Econst_int (Int.repr 1) tint) tint) tshort)))
                    (Sassign (Evar _gMatStackIndex tshort)
                      (Etempvar _t'1 tshort)))
                  (Sassign
                    (Efield
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _node (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _header
                          (Tstruct _ObjectNode noattr)) _gfx
                        (Tstruct _GraphNodeObject noattr)) _throwMatrix
                      (tptr (tarray (tarray tfloat 4) 4)))
                    (Ebinop Oadd
                      (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                      (Etempvar _t'1 tshort)
                      (tptr (tarray (tarray tfloat 4) 4)))))
                (Ssequence
                  (Ssequence
                    (Sset _t'22 (Evar _gMatStackIndex tshort))
                    (Ssequence
                      (Sset _t'23
                        (Ederef
                          (Ebinop Oadd
                            (Ederef
                              (Ebinop Oadd
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                    (Etempvar _t'22 tshort)
                                    (tptr (tarray (tarray tfloat 4) 4)))
                                  (tarray (tarray tfloat 4) 4))
                                (Econst_int (Int.repr 3) tint)
                                (tptr (tarray tfloat 4))) (tarray tfloat 4))
                            (Econst_int (Int.repr 0) tint) (tptr tfloat))
                          tfloat))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _node (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _header
                                  (Tstruct _ObjectNode noattr)) _gfx
                                (Tstruct _GraphNodeObject noattr))
                              _cameraToObject (tarray tfloat 3))
                            (Econst_int (Int.repr 0) tint) (tptr tfloat))
                          tfloat) (Etempvar _t'23 tfloat))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'20 (Evar _gMatStackIndex tshort))
                      (Ssequence
                        (Sset _t'21
                          (Ederef
                            (Ebinop Oadd
                              (Ederef
                                (Ebinop Oadd
                                  (Ederef
                                    (Ebinop Oadd
                                      (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                      (Etempvar _t'20 tshort)
                                      (tptr (tarray (tarray tfloat 4) 4)))
                                    (tarray (tarray tfloat 4) 4))
                                  (Econst_int (Int.repr 3) tint)
                                  (tptr (tarray tfloat 4)))
                                (tarray tfloat 4))
                              (Econst_int (Int.repr 1) tint) (tptr tfloat))
                            tfloat))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _node (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _header
                                    (Tstruct _ObjectNode noattr)) _gfx
                                  (Tstruct _GraphNodeObject noattr))
                                _cameraToObject (tarray tfloat 3))
                              (Econst_int (Int.repr 1) tint) (tptr tfloat))
                            tfloat) (Etempvar _t'21 tfloat))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'18 (Evar _gMatStackIndex tshort))
                        (Ssequence
                          (Sset _t'19
                            (Ederef
                              (Ebinop Oadd
                                (Ederef
                                  (Ebinop Oadd
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                        (Etempvar _t'18 tshort)
                                        (tptr (tarray (tarray tfloat 4) 4)))
                                      (tarray (tarray tfloat 4) 4))
                                    (Econst_int (Int.repr 3) tint)
                                    (tptr (tarray tfloat 4)))
                                  (tarray tfloat 4))
                                (Econst_int (Int.repr 2) tint) (tptr tfloat))
                              tfloat))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _node (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _header
                                      (Tstruct _ObjectNode noattr)) _gfx
                                    (Tstruct _GraphNodeObject noattr))
                                  _cameraToObject (tarray tfloat 3))
                                (Econst_int (Int.repr 2) tint) (tptr tfloat))
                              tfloat) (Etempvar _t'19 tfloat))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'17
                            (Efield
                              (Efield
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _node (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _header
                                    (Tstruct _ObjectNode noattr)) _gfx
                                  (Tstruct _GraphNodeObject noattr))
                                _animInfo (Tstruct _AnimInfo noattr))
                              _curAnim (tptr (Tstruct _Animation noattr))))
                          (Sifthenelse (Ebinop One
                                         (Etempvar _t'17 (tptr (Tstruct _Animation noattr)))
                                         (Ecast
                                           (Econst_int (Int.repr 0) tint)
                                           (tptr tvoid)) tint)
                            (Scall None
                              (Evar _geo_set_animation_globals (Tfunction
                                                                 ((tptr (Tstruct _AnimInfo noattr)) ::
                                                                  tint ::
                                                                  nil) tvoid
                                                                 cc_default))
                              ((Eaddrof
                                 (Efield
                                   (Efield
                                     (Efield
                                       (Ederef
                                         (Etempvar _node (tptr (Tstruct _Object noattr)))
                                         (Tstruct _Object noattr)) _header
                                       (Tstruct _ObjectNode noattr)) _gfx
                                     (Tstruct _GraphNodeObject noattr))
                                   _animInfo (Tstruct _AnimInfo noattr))
                                 (tptr (Tstruct _AnimInfo noattr))) ::
                               (Etempvar _hasAnimation tint) :: nil))
                            Sskip))
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Sset _t'16 (Evar _gMatStackIndex tshort))
                              (Scall (Some _t'3)
                                (Evar _obj_is_in_view (Tfunction
                                                        ((tptr (Tstruct _GraphNodeObject noattr)) ::
                                                         (tptr (tarray tfloat 4)) ::
                                                         nil) tint
                                                        cc_default))
                                ((Eaddrof
                                   (Efield
                                     (Efield
                                       (Ederef
                                         (Etempvar _node (tptr (Tstruct _Object noattr)))
                                         (Tstruct _Object noattr)) _header
                                       (Tstruct _ObjectNode noattr)) _gfx
                                     (Tstruct _GraphNodeObject noattr))
                                   (tptr (Tstruct _GraphNodeObject noattr))) ::
                                 (Ederef
                                   (Ebinop Oadd
                                     (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                     (Etempvar _t'16 tshort)
                                     (tptr (tarray (tarray tfloat 4) 4)))
                                   (tarray (tarray tfloat 4) 4)) :: nil)))
                            (Sifthenelse (Etempvar _t'3 tint)
                              (Ssequence
                                (Ssequence
                                  (Scall (Some _t'2)
                                    (Evar _alloc_display_list (Tfunction
                                                                (tuint ::
                                                                 nil)
                                                                (tptr tvoid)
                                                                cc_default))
                                    ((Esizeof (Tunion __472 noattr) tuint) ::
                                     nil))
                                  (Sset _mtx (Etempvar _t'2 (tptr tvoid))))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'15
                                      (Evar _gMatStackIndex tshort))
                                    (Scall None
                                      (Evar _mtxf_to_mtx (Tfunction
                                                           ((tptr (Tunion __472 noattr)) ::
                                                            (tptr (tarray tfloat 4)) ::
                                                            nil) tvoid
                                                           cc_default))
                                      ((Etempvar _mtx (tptr (Tunion __472 noattr))) ::
                                       (Ederef
                                         (Ebinop Oadd
                                           (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                           (Etempvar _t'15 tshort)
                                           (tptr (tarray (tarray tfloat 4) 4)))
                                         (tarray (tarray tfloat 4) 4)) ::
                                       nil)))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'14
                                        (Evar _gMatStackIndex tshort))
                                      (Sassign
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _gMatStackFixed (tarray (tptr (Tunion __472 noattr)) 32))
                                            (Etempvar _t'14 tshort)
                                            (tptr (tptr (Tunion __472 noattr))))
                                          (tptr (Tunion __472 noattr)))
                                        (Etempvar _mtx (tptr (Tunion __472 noattr)))))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'10
                                          (Efield
                                            (Efield
                                              (Efield
                                                (Ederef
                                                  (Etempvar _node (tptr (Tstruct _Object noattr)))
                                                  (Tstruct _Object noattr))
                                                _header
                                                (Tstruct _ObjectNode noattr))
                                              _gfx
                                              (Tstruct _GraphNodeObject noattr))
                                            _sharedChild
                                            (tptr (Tstruct _GraphNode noattr))))
                                        (Sifthenelse (Ebinop One
                                                       (Etempvar _t'10 (tptr (Tstruct _GraphNode noattr)))
                                                       (Ecast
                                                         (Econst_int (Int.repr 0) tint)
                                                         (tptr tvoid)) tint)
                                          (Ssequence
                                            (Sassign
                                              (Evar _gCurGraphNodeObject (tptr (Tstruct _GraphNodeObject noattr)))
                                              (Ecast
                                                (Etempvar _node (tptr (Tstruct _Object noattr)))
                                                (tptr (Tstruct _GraphNodeObject noattr))))
                                            (Ssequence
                                              (Ssequence
                                                (Sset _t'13
                                                  (Efield
                                                    (Efield
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _node (tptr (Tstruct _Object noattr)))
                                                          (Tstruct _Object noattr))
                                                        _header
                                                        (Tstruct _ObjectNode noattr))
                                                      _gfx
                                                      (Tstruct _GraphNodeObject noattr))
                                                    _sharedChild
                                                    (tptr (Tstruct _GraphNode noattr))))
                                                (Sassign
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _t'13 (tptr (Tstruct _GraphNode noattr)))
                                                      (Tstruct _GraphNode noattr))
                                                    _parent
                                                    (tptr (Tstruct _GraphNode noattr)))
                                                  (Eaddrof
                                                    (Efield
                                                      (Efield
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar _node (tptr (Tstruct _Object noattr)))
                                                            (Tstruct _Object noattr))
                                                          _header
                                                          (Tstruct _ObjectNode noattr))
                                                        _gfx
                                                        (Tstruct _GraphNodeObject noattr))
                                                      _node
                                                      (Tstruct _GraphNode noattr))
                                                    (tptr (Tstruct _GraphNode noattr)))))
                                              (Ssequence
                                                (Ssequence
                                                  (Sset _t'12
                                                    (Efield
                                                      (Efield
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar _node (tptr (Tstruct _Object noattr)))
                                                            (Tstruct _Object noattr))
                                                          _header
                                                          (Tstruct _ObjectNode noattr))
                                                        _gfx
                                                        (Tstruct _GraphNodeObject noattr))
                                                      _sharedChild
                                                      (tptr (Tstruct _GraphNode noattr))))
                                                  (Scall None
                                                    (Evar _geo_process_node_and_siblings 
                                                    (Tfunction
                                                      ((tptr (Tstruct _GraphNode noattr)) ::
                                                       nil) tvoid cc_default))
                                                    ((Etempvar _t'12 (tptr (Tstruct _GraphNode noattr))) ::
                                                     nil)))
                                                (Ssequence
                                                  (Ssequence
                                                    (Sset _t'11
                                                      (Efield
                                                        (Efield
                                                          (Efield
                                                            (Ederef
                                                              (Etempvar _node (tptr (Tstruct _Object noattr)))
                                                              (Tstruct _Object noattr))
                                                            _header
                                                            (Tstruct _ObjectNode noattr))
                                                          _gfx
                                                          (Tstruct _GraphNodeObject noattr))
                                                        _sharedChild
                                                        (tptr (Tstruct _GraphNode noattr))))
                                                    (Sassign
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _t'11 (tptr (Tstruct _GraphNode noattr)))
                                                          (Tstruct _GraphNode noattr))
                                                        _parent
                                                        (tptr (Tstruct _GraphNode noattr)))
                                                      (Ecast
                                                        (Econst_int (Int.repr 0) tint)
                                                        (tptr tvoid))))
                                                  (Sassign
                                                    (Evar _gCurGraphNodeObject (tptr (Tstruct _GraphNodeObject noattr)))
                                                    (Ecast
                                                      (Econst_int (Int.repr 0) tint)
                                                      (tptr tvoid)))))))
                                          Sskip))
                                      (Ssequence
                                        (Sset _t'8
                                          (Efield
                                            (Efield
                                              (Efield
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _node (tptr (Tstruct _Object noattr)))
                                                    (Tstruct _Object noattr))
                                                  _header
                                                  (Tstruct _ObjectNode noattr))
                                                _gfx
                                                (Tstruct _GraphNodeObject noattr))
                                              _node
                                              (Tstruct _GraphNode noattr))
                                            _children
                                            (tptr (Tstruct _GraphNode noattr))))
                                        (Sifthenelse (Ebinop One
                                                       (Etempvar _t'8 (tptr (Tstruct _GraphNode noattr)))
                                                       (Ecast
                                                         (Econst_int (Int.repr 0) tint)
                                                         (tptr tvoid)) tint)
                                          (Ssequence
                                            (Sset _t'9
                                              (Efield
                                                (Efield
                                                  (Efield
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _node (tptr (Tstruct _Object noattr)))
                                                        (Tstruct _Object noattr))
                                                      _header
                                                      (Tstruct _ObjectNode noattr))
                                                    _gfx
                                                    (Tstruct _GraphNodeObject noattr))
                                                  _node
                                                  (Tstruct _GraphNode noattr))
                                                _children
                                                (tptr (Tstruct _GraphNode noattr))))
                                            (Scall None
                                              (Evar _geo_process_node_and_siblings 
                                              (Tfunction
                                                ((tptr (Tstruct _GraphNode noattr)) ::
                                                 nil) tvoid cc_default))
                                              ((Etempvar _t'9 (tptr (Tstruct _GraphNode noattr))) ::
                                               nil)))
                                          Sskip))))))
                              Sskip))
                          (Ssequence
                            (Ssequence
                              (Sset _t'7 (Evar _gMatStackIndex tshort))
                              (Sassign (Evar _gMatStackIndex tshort)
                                (Ebinop Osub (Etempvar _t'7 tshort)
                                  (Econst_int (Int.repr 1) tint) tint)))
                            (Ssequence
                              (Sassign (Evar _gCurrAnimType tuchar)
                                (Econst_int (Int.repr 0) tint))
                              (Sassign
                                (Efield
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _node (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _header
                                      (Tstruct _ObjectNode noattr)) _gfx
                                    (Tstruct _GraphNodeObject noattr))
                                  _throwMatrix
                                  (tptr (tarray (tarray tfloat 4) 4)))
                                (Ecast (Econst_int (Int.repr 0) tint)
                                  (tptr tvoid)))))))))))))
          Sskip)))))
|}.

Definition f_geo_process_object_parent := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _GraphNodeObjectParent noattr))) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_t'6, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'5, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'4, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'3, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'2, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'1, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3
      (Efield
        (Ederef
          (Etempvar _node (tptr (Tstruct _GraphNodeObjectParent noattr)))
          (Tstruct _GraphNodeObjectParent noattr)) _sharedChild
        (tptr (Tstruct _GraphNode noattr))))
    (Sifthenelse (Ebinop One
                   (Etempvar _t'3 (tptr (Tstruct _GraphNode noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef
                (Etempvar _node (tptr (Tstruct _GraphNodeObjectParent noattr)))
                (Tstruct _GraphNodeObjectParent noattr)) _sharedChild
              (tptr (Tstruct _GraphNode noattr))))
          (Sassign
            (Efield
              (Ederef (Etempvar _t'6 (tptr (Tstruct _GraphNode noattr)))
                (Tstruct _GraphNode noattr)) _parent
              (tptr (Tstruct _GraphNode noattr)))
            (Ecast
              (Etempvar _node (tptr (Tstruct _GraphNodeObjectParent noattr)))
              (tptr (Tstruct _GraphNode noattr)))))
        (Ssequence
          (Ssequence
            (Sset _t'5
              (Efield
                (Ederef
                  (Etempvar _node (tptr (Tstruct _GraphNodeObjectParent noattr)))
                  (Tstruct _GraphNodeObjectParent noattr)) _sharedChild
                (tptr (Tstruct _GraphNode noattr))))
            (Scall None
              (Evar _geo_process_node_and_siblings (Tfunction
                                                     ((tptr (Tstruct _GraphNode noattr)) ::
                                                      nil) tvoid cc_default))
              ((Etempvar _t'5 (tptr (Tstruct _GraphNode noattr))) :: nil)))
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef
                  (Etempvar _node (tptr (Tstruct _GraphNodeObjectParent noattr)))
                  (Tstruct _GraphNodeObjectParent noattr)) _sharedChild
                (tptr (Tstruct _GraphNode noattr))))
            (Sassign
              (Efield
                (Ederef (Etempvar _t'4 (tptr (Tstruct _GraphNode noattr)))
                  (Tstruct _GraphNode noattr)) _parent
                (tptr (Tstruct _GraphNode noattr)))
              (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))))
      Sskip))
  (Ssequence
    (Sset _t'1
      (Efield
        (Efield
          (Ederef
            (Etempvar _node (tptr (Tstruct _GraphNodeObjectParent noattr)))
            (Tstruct _GraphNodeObjectParent noattr)) _node
          (Tstruct _GraphNode noattr)) _children
        (tptr (Tstruct _GraphNode noattr))))
    (Sifthenelse (Ebinop One
                   (Etempvar _t'1 (tptr (Tstruct _GraphNode noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Sset _t'2
          (Efield
            (Efield
              (Ederef
                (Etempvar _node (tptr (Tstruct _GraphNodeObjectParent noattr)))
                (Tstruct _GraphNodeObjectParent noattr)) _node
              (Tstruct _GraphNode noattr)) _children
            (tptr (Tstruct _GraphNode noattr))))
        (Scall None
          (Evar _geo_process_node_and_siblings (Tfunction
                                                 ((tptr (Tstruct _GraphNode noattr)) ::
                                                  nil) tvoid cc_default))
          ((Etempvar _t'2 (tptr (Tstruct _GraphNode noattr))) :: nil)))
      Sskip)))
|}.

Definition f_geo_process_held_object := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _GraphNodeHeldObject noattr))) :: nil);
  fn_vars := ((_mat, (tarray (tarray tfloat 4) 4)) ::
              (_translation, (tarray tfloat 3)) :: nil);
  fn_temps := ((_mtx, (tptr (Tunion __472 noattr))) ::
               (_hasAnimation, tint) :: (_t'2, tint) ::
               (_t'1, (tptr tvoid)) :: (_t'56, tshort) ::
               (_t'55,
                (tptr (Tfunction
                        (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                         (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                        cc_default))) ::
               (_t'54,
                (tptr (Tfunction
                        (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                         (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                        cc_default))) ::
               (_t'53, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'52, (tptr (Tstruct _Object noattr))) ::
               (_t'51, (tptr (Tstruct _Object noattr))) :: (_t'50, tshort) ::
               (_t'49, (tptr (Tstruct _Object noattr))) :: (_t'48, tshort) ::
               (_t'47, tshort) :: (_t'46, tshort) ::
               (_t'45, (tptr (tarray (tarray tfloat 4) 4))) ::
               (_t'44, (tptr (Tstruct _GraphNodeObject noattr))) ::
               (_t'43, tshort) :: (_t'42, tfloat) :: (_t'41, tshort) ::
               (_t'40, tshort) :: (_t'39, tfloat) :: (_t'38, tshort) ::
               (_t'37, tshort) :: (_t'36, tfloat) :: (_t'35, tshort) ::
               (_t'34, tshort) :: (_t'33, tshort) :: (_t'32, tshort) ::
               (_t'31, (tptr (Tstruct _Object noattr))) :: (_t'30, tshort) ::
               (_t'29, tshort) :: (_t'28, tshort) ::
               (_t'27,
                (tptr (Tfunction
                        (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                         (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                        cc_default))) ::
               (_t'26,
                (tptr (Tfunction
                        (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                         (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                        cc_default))) :: (_t'25, tshort) ::
               (_t'24, tshort) :: (_t'23, tshort) :: (_t'22, tuchar) ::
               (_t'21, tuchar) :: (_t'20, tshort) :: (_t'19, tfloat) ::
               (_t'18, (tptr tushort)) :: (_t'17, (tptr tshort)) ::
               (_t'16, (tptr (Tstruct _Object noattr))) ::
               (_t'15, (tptr (Tstruct _Animation noattr))) ::
               (_t'14, (tptr (Tstruct _Object noattr))) ::
               (_t'13, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'12, (tptr (Tstruct _Object noattr))) :: (_t'11, tuchar) ::
               (_t'10, tuchar) :: (_t'9, tshort) :: (_t'8, tfloat) ::
               (_t'7, (tptr tushort)) :: (_t'6, (tptr tshort)) ::
               (_t'5, tshort) ::
               (_t'4, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'3, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                  cc_default))
      ((Esizeof (Tunion __472 noattr) tuint) :: nil))
    (Sset _mtx (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Ssequence
      (Sset _t'54
        (Efield
          (Efield
            (Ederef
              (Etempvar _node (tptr (Tstruct _GraphNodeHeldObject noattr)))
              (Tstruct _GraphNodeHeldObject noattr)) _fnNode
            (Tstruct _FnGraphNode noattr)) _func
          (tptr (Tfunction
                  (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                   (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                  cc_default))))
      (Sifthenelse (Ebinop One
                     (Etempvar _t'54 (tptr (Tfunction
                                             (tint ::
                                              (tptr (Tstruct _GraphNode noattr)) ::
                                              (tptr tvoid) :: nil)
                                             (tptr (Tunion __512 noattr))
                                             cc_default)))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Ssequence
          (Sset _t'55
            (Efield
              (Efield
                (Ederef
                  (Etempvar _node (tptr (Tstruct _GraphNodeHeldObject noattr)))
                  (Tstruct _GraphNodeHeldObject noattr)) _fnNode
                (Tstruct _FnGraphNode noattr)) _func
              (tptr (Tfunction
                      (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                       (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                      cc_default))))
          (Ssequence
            (Sset _t'56 (Evar _gMatStackIndex tshort))
            (Scall None
              (Etempvar _t'55 (tptr (Tfunction
                                      (tint ::
                                       (tptr (Tstruct _GraphNode noattr)) ::
                                       (tptr tvoid) :: nil)
                                      (tptr (Tunion __512 noattr))
                                      cc_default)))
              ((Econst_int (Int.repr 1) tint) ::
               (Eaddrof
                 (Efield
                   (Efield
                     (Ederef
                       (Etempvar _node (tptr (Tstruct _GraphNodeHeldObject noattr)))
                       (Tstruct _GraphNodeHeldObject noattr)) _fnNode
                     (Tstruct _FnGraphNode noattr)) _node
                   (Tstruct _GraphNode noattr))
                 (tptr (Tstruct _GraphNode noattr))) ::
               (Ederef
                 (Ebinop Oadd
                   (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                   (Etempvar _t'56 tshort)
                   (tptr (tarray (tarray tfloat 4) 4)))
                 (tarray (tarray tfloat 4) 4)) :: nil))))
        Sskip))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'51
            (Efield
              (Ederef
                (Etempvar _node (tptr (Tstruct _GraphNodeHeldObject noattr)))
                (Tstruct _GraphNodeHeldObject noattr)) _objNode
              (tptr (Tstruct _Object noattr))))
          (Sifthenelse (Ebinop One
                         (Etempvar _t'51 (tptr (Tstruct _Object noattr)))
                         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                         tint)
            (Ssequence
              (Sset _t'52
                (Efield
                  (Ederef
                    (Etempvar _node (tptr (Tstruct _GraphNodeHeldObject noattr)))
                    (Tstruct _GraphNodeHeldObject noattr)) _objNode
                  (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'53
                  (Efield
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'52 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _header
                        (Tstruct _ObjectNode noattr)) _gfx
                      (Tstruct _GraphNodeObject noattr)) _sharedChild
                    (tptr (Tstruct _GraphNode noattr))))
                (Sset _t'2
                  (Ecast
                    (Ebinop One
                      (Etempvar _t'53 (tptr (Tstruct _GraphNode noattr)))
                      (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                      tint) tbool))))
            (Sset _t'2 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'2 tint)
          (Ssequence
            (Ssequence
              (Sset _t'49
                (Efield
                  (Ederef
                    (Etempvar _node (tptr (Tstruct _GraphNodeHeldObject noattr)))
                    (Tstruct _GraphNodeHeldObject noattr)) _objNode
                  (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'50
                  (Efield
                    (Efield
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'49 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _header
                          (Tstruct _ObjectNode noattr)) _gfx
                        (Tstruct _GraphNodeObject noattr)) _node
                      (Tstruct _GraphNode noattr)) _flags tshort))
                (Sset _hasAnimation
                  (Ebinop One
                    (Ebinop Oand (Etempvar _t'50 tshort)
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 5) tint) tint) tint)
                    (Econst_int (Int.repr 0) tint) tint))))
            (Ssequence
              (Ssequence
                (Sset _t'48
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _node (tptr (Tstruct _GraphNodeHeldObject noattr)))
                          (Tstruct _GraphNodeHeldObject noattr)) _translation
                        (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tshort)) tshort))
                (Sassign
                  (Ederef
                    (Ebinop Oadd (Evar _translation (tarray tfloat 3))
                      (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
                  (Ebinop Odiv (Etempvar _t'48 tshort)
                    (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                    tfloat)))
              (Ssequence
                (Ssequence
                  (Sset _t'47
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _node (tptr (Tstruct _GraphNodeHeldObject noattr)))
                            (Tstruct _GraphNodeHeldObject noattr))
                          _translation (tarray tshort 3))
                        (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd (Evar _translation (tarray tfloat 3))
                        (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
                    (Ebinop Odiv (Etempvar _t'47 tshort)
                      (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                      tfloat)))
                (Ssequence
                  (Ssequence
                    (Sset _t'46
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _node (tptr (Tstruct _GraphNodeHeldObject noattr)))
                              (Tstruct _GraphNodeHeldObject noattr))
                            _translation (tarray tshort 3))
                          (Econst_int (Int.repr 2) tint) (tptr tshort))
                        tshort))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd (Evar _translation (tarray tfloat 3))
                          (Econst_int (Int.repr 2) tint) (tptr tfloat))
                        tfloat)
                      (Ebinop Odiv (Etempvar _t'46 tshort)
                        (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                        tfloat)))
                  (Ssequence
                    (Scall None
                      (Evar _mtxf_translate (Tfunction
                                              ((tptr (tarray tfloat 4)) ::
                                               (tptr tfloat) :: nil) tvoid
                                              cc_default))
                      ((Evar _mat (tarray (tarray tfloat 4) 4)) ::
                       (Evar _translation (tarray tfloat 3)) :: nil))
                    (Ssequence
                      (Ssequence
                        (Sset _t'43 (Evar _gMatStackIndex tshort))
                        (Ssequence
                          (Sset _t'44
                            (Evar _gCurGraphNodeObject (tptr (Tstruct _GraphNodeObject noattr))))
                          (Ssequence
                            (Sset _t'45
                              (Efield
                                (Ederef
                                  (Etempvar _t'44 (tptr (Tstruct _GraphNodeObject noattr)))
                                  (Tstruct _GraphNodeObject noattr))
                                _throwMatrix
                                (tptr (tarray (tarray tfloat 4) 4))))
                            (Scall None
                              (Evar _mtxf_copy (Tfunction
                                                 ((tptr (tarray tfloat 4)) ::
                                                  (tptr (tarray tfloat 4)) ::
                                                  nil) tvoid cc_default))
                              ((Ederef
                                 (Ebinop Oadd
                                   (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                   (Ebinop Oadd (Etempvar _t'43 tshort)
                                     (Econst_int (Int.repr 1) tint) tint)
                                   (tptr (tarray (tarray tfloat 4) 4)))
                                 (tarray (tarray tfloat 4) 4)) ::
                               (Ederef
                                 (Etempvar _t'45 (tptr (tarray (tarray tfloat 4) 4)))
                                 (tarray (tarray tfloat 4) 4)) :: nil)))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'40 (Evar _gMatStackIndex tshort))
                          (Ssequence
                            (Sset _t'41 (Evar _gMatStackIndex tshort))
                            (Ssequence
                              (Sset _t'42
                                (Ederef
                                  (Ebinop Oadd
                                    (Ederef
                                      (Ebinop Oadd
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                            (Etempvar _t'41 tshort)
                                            (tptr (tarray (tarray tfloat 4) 4)))
                                          (tarray (tarray tfloat 4) 4))
                                        (Econst_int (Int.repr 3) tint)
                                        (tptr (tarray tfloat 4)))
                                      (tarray tfloat 4))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr tfloat)) tfloat))
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd
                                    (Ederef
                                      (Ebinop Oadd
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                            (Ebinop Oadd
                                              (Etempvar _t'40 tshort)
                                              (Econst_int (Int.repr 1) tint)
                                              tint)
                                            (tptr (tarray (tarray tfloat 4) 4)))
                                          (tarray (tarray tfloat 4) 4))
                                        (Econst_int (Int.repr 3) tint)
                                        (tptr (tarray tfloat 4)))
                                      (tarray tfloat 4))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr tfloat)) tfloat)
                                (Etempvar _t'42 tfloat)))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'37 (Evar _gMatStackIndex tshort))
                            (Ssequence
                              (Sset _t'38 (Evar _gMatStackIndex tshort))
                              (Ssequence
                                (Sset _t'39
                                  (Ederef
                                    (Ebinop Oadd
                                      (Ederef
                                        (Ebinop Oadd
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                              (Etempvar _t'38 tshort)
                                              (tptr (tarray (tarray tfloat 4) 4)))
                                            (tarray (tarray tfloat 4) 4))
                                          (Econst_int (Int.repr 3) tint)
                                          (tptr (tarray tfloat 4)))
                                        (tarray tfloat 4))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr tfloat)) tfloat))
                                (Sassign
                                  (Ederef
                                    (Ebinop Oadd
                                      (Ederef
                                        (Ebinop Oadd
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                              (Ebinop Oadd
                                                (Etempvar _t'37 tshort)
                                                (Econst_int (Int.repr 1) tint)
                                                tint)
                                              (tptr (tarray (tarray tfloat 4) 4)))
                                            (tarray (tarray tfloat 4) 4))
                                          (Econst_int (Int.repr 3) tint)
                                          (tptr (tarray tfloat 4)))
                                        (tarray tfloat 4))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr tfloat)) tfloat)
                                  (Etempvar _t'39 tfloat)))))
                          (Ssequence
                            (Ssequence
                              (Sset _t'34 (Evar _gMatStackIndex tshort))
                              (Ssequence
                                (Sset _t'35 (Evar _gMatStackIndex tshort))
                                (Ssequence
                                  (Sset _t'36
                                    (Ederef
                                      (Ebinop Oadd
                                        (Ederef
                                          (Ebinop Oadd
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                                (Etempvar _t'35 tshort)
                                                (tptr (tarray (tarray tfloat 4) 4)))
                                              (tarray (tarray tfloat 4) 4))
                                            (Econst_int (Int.repr 3) tint)
                                            (tptr (tarray tfloat 4)))
                                          (tarray tfloat 4))
                                        (Econst_int (Int.repr 2) tint)
                                        (tptr tfloat)) tfloat))
                                  (Sassign
                                    (Ederef
                                      (Ebinop Oadd
                                        (Ederef
                                          (Ebinop Oadd
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                                (Ebinop Oadd
                                                  (Etempvar _t'34 tshort)
                                                  (Econst_int (Int.repr 1) tint)
                                                  tint)
                                                (tptr (tarray (tarray tfloat 4) 4)))
                                              (tarray (tarray tfloat 4) 4))
                                            (Econst_int (Int.repr 3) tint)
                                            (tptr (tarray tfloat 4)))
                                          (tarray tfloat 4))
                                        (Econst_int (Int.repr 2) tint)
                                        (tptr tfloat)) tfloat)
                                    (Etempvar _t'36 tfloat)))))
                            (Ssequence
                              (Ssequence
                                (Sset _t'32 (Evar _gMatStackIndex tshort))
                                (Ssequence
                                  (Sset _t'33 (Evar _gMatStackIndex tshort))
                                  (Scall None
                                    (Evar _mtxf_mul (Tfunction
                                                      ((tptr (tarray tfloat 4)) ::
                                                       (tptr (tarray tfloat 4)) ::
                                                       (tptr (tarray tfloat 4)) ::
                                                       nil) tvoid cc_default))
                                    ((Ederef
                                       (Ebinop Oadd
                                         (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                         (Ebinop Oadd (Etempvar _t'32 tshort)
                                           (Econst_int (Int.repr 1) tint)
                                           tint)
                                         (tptr (tarray (tarray tfloat 4) 4)))
                                       (tarray (tarray tfloat 4) 4)) ::
                                     (Evar _mat (tarray (tarray tfloat 4) 4)) ::
                                     (Ederef
                                       (Ebinop Oadd
                                         (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                         (Ebinop Oadd (Etempvar _t'33 tshort)
                                           (Econst_int (Int.repr 1) tint)
                                           tint)
                                         (tptr (tarray (tarray tfloat 4) 4)))
                                       (tarray (tarray tfloat 4) 4)) :: nil))))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'29 (Evar _gMatStackIndex tshort))
                                  (Ssequence
                                    (Sset _t'30
                                      (Evar _gMatStackIndex tshort))
                                    (Ssequence
                                      (Sset _t'31
                                        (Efield
                                          (Ederef
                                            (Etempvar _node (tptr (Tstruct _GraphNodeHeldObject noattr)))
                                            (Tstruct _GraphNodeHeldObject noattr))
                                          _objNode
                                          (tptr (Tstruct _Object noattr))))
                                      (Scall None
                                        (Evar _mtxf_scale_vec3f (Tfunction
                                                                  ((tptr (tarray tfloat 4)) ::
                                                                   (tptr (tarray tfloat 4)) ::
                                                                   (tptr tfloat) ::
                                                                   nil) tvoid
                                                                  cc_default))
                                        ((Ederef
                                           (Ebinop Oadd
                                             (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                             (Ebinop Oadd
                                               (Etempvar _t'29 tshort)
                                               (Econst_int (Int.repr 1) tint)
                                               tint)
                                             (tptr (tarray (tarray tfloat 4) 4)))
                                           (tarray (tarray tfloat 4) 4)) ::
                                         (Ederef
                                           (Ebinop Oadd
                                             (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                             (Ebinop Oadd
                                               (Etempvar _t'30 tshort)
                                               (Econst_int (Int.repr 1) tint)
                                               tint)
                                             (tptr (tarray (tarray tfloat 4) 4)))
                                           (tarray (tarray tfloat 4) 4)) ::
                                         (Efield
                                           (Efield
                                             (Efield
                                               (Ederef
                                                 (Etempvar _t'31 (tptr (Tstruct _Object noattr)))
                                                 (Tstruct _Object noattr))
                                               _header
                                               (Tstruct _ObjectNode noattr))
                                             _gfx
                                             (Tstruct _GraphNodeObject noattr))
                                           _scale (tarray tfloat 3)) :: nil)))))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'26
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _node (tptr (Tstruct _GraphNodeHeldObject noattr)))
                                            (Tstruct _GraphNodeHeldObject noattr))
                                          _fnNode
                                          (Tstruct _FnGraphNode noattr))
                                        _func
                                        (tptr (Tfunction
                                                (tint ::
                                                 (tptr (Tstruct _GraphNode noattr)) ::
                                                 (tptr tvoid) :: nil)
                                                (tptr (Tunion __512 noattr))
                                                cc_default))))
                                    (Sifthenelse (Ebinop One
                                                   (Etempvar _t'26 (tptr 
                                                   (Tfunction
                                                     (tint ::
                                                      (tptr (Tstruct _GraphNode noattr)) ::
                                                      (tptr tvoid) :: nil)
                                                     (tptr (Tunion __512 noattr))
                                                     cc_default)))
                                                   (Ecast
                                                     (Econst_int (Int.repr 0) tint)
                                                     (tptr tvoid)) tint)
                                      (Ssequence
                                        (Sset _t'27
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _node (tptr (Tstruct _GraphNodeHeldObject noattr)))
                                                (Tstruct _GraphNodeHeldObject noattr))
                                              _fnNode
                                              (Tstruct _FnGraphNode noattr))
                                            _func
                                            (tptr (Tfunction
                                                    (tint ::
                                                     (tptr (Tstruct _GraphNode noattr)) ::
                                                     (tptr tvoid) :: nil)
                                                    (tptr (Tunion __512 noattr))
                                                    cc_default))))
                                        (Ssequence
                                          (Sset _t'28
                                            (Evar _gMatStackIndex tshort))
                                          (Scall None
                                            (Etempvar _t'27 (tptr (Tfunction
                                                                    (tint ::
                                                                    (tptr (Tstruct _GraphNode noattr)) ::
                                                                    (tptr tvoid) ::
                                                                    nil)
                                                                    (tptr (Tunion __512 noattr))
                                                                    cc_default)))
                                            ((Econst_int (Int.repr 5) tint) ::
                                             (Eaddrof
                                               (Efield
                                                 (Efield
                                                   (Ederef
                                                     (Etempvar _node (tptr (Tstruct _GraphNodeHeldObject noattr)))
                                                     (Tstruct _GraphNodeHeldObject noattr))
                                                   _fnNode
                                                   (Tstruct _FnGraphNode noattr))
                                                 _node
                                                 (Tstruct _GraphNode noattr))
                                               (tptr (Tstruct _GraphNode noattr))) ::
                                             (Ecast
                                               (Ederef
                                                 (Ebinop Oadd
                                                   (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                                   (Ebinop Oadd
                                                     (Etempvar _t'28 tshort)
                                                     (Econst_int (Int.repr 1) tint)
                                                     tint)
                                                   (tptr (tarray (tarray tfloat 4) 4)))
                                                 (tarray (tarray tfloat 4) 4))
                                               (tptr (Tstruct _AllocOnlyPool noattr))) ::
                                             nil))))
                                      Sskip))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'25
                                        (Evar _gMatStackIndex tshort))
                                      (Sassign (Evar _gMatStackIndex tshort)
                                        (Ebinop Oadd (Etempvar _t'25 tshort)
                                          (Econst_int (Int.repr 1) tint)
                                          tint)))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'24
                                          (Evar _gMatStackIndex tshort))
                                        (Scall None
                                          (Evar _mtxf_to_mtx (Tfunction
                                                               ((tptr (Tunion __472 noattr)) ::
                                                                (tptr (tarray tfloat 4)) ::
                                                                nil) tvoid
                                                               cc_default))
                                          ((Etempvar _mtx (tptr (Tunion __472 noattr))) ::
                                           (Ederef
                                             (Ebinop Oadd
                                               (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                               (Etempvar _t'24 tshort)
                                               (tptr (tarray (tarray tfloat 4) 4)))
                                             (tarray (tarray tfloat 4) 4)) ::
                                           nil)))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'23
                                            (Evar _gMatStackIndex tshort))
                                          (Sassign
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _gMatStackFixed (tarray (tptr (Tunion __472 noattr)) 32))
                                                (Etempvar _t'23 tshort)
                                                (tptr (tptr (Tunion __472 noattr))))
                                              (tptr (Tunion __472 noattr)))
                                            (Etempvar _mtx (tptr (Tunion __472 noattr)))))
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'22
                                              (Evar _gCurrAnimType tuchar))
                                            (Sassign
                                              (Efield
                                                (Evar _gGeoTempState (Tstruct _GeoAnimState noattr))
                                                _type tuchar)
                                              (Etempvar _t'22 tuchar)))
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'21
                                                (Evar _gCurrAnimEnabled tuchar))
                                              (Sassign
                                                (Efield
                                                  (Evar _gGeoTempState (Tstruct _GeoAnimState noattr))
                                                  _enabled tuchar)
                                                (Etempvar _t'21 tuchar)))
                                            (Ssequence
                                              (Ssequence
                                                (Sset _t'20
                                                  (Evar _gCurrAnimFrame tshort))
                                                (Sassign
                                                  (Efield
                                                    (Evar _gGeoTempState (Tstruct _GeoAnimState noattr))
                                                    _frame tshort)
                                                  (Etempvar _t'20 tshort)))
                                              (Ssequence
                                                (Ssequence
                                                  (Sset _t'19
                                                    (Evar _gCurrAnimTranslationMultiplier tfloat))
                                                  (Sassign
                                                    (Efield
                                                      (Evar _gGeoTempState (Tstruct _GeoAnimState noattr))
                                                      _translationMultiplier
                                                      tfloat)
                                                    (Etempvar _t'19 tfloat)))
                                                (Ssequence
                                                  (Ssequence
                                                    (Sset _t'18
                                                      (Evar _gCurrAnimAttribute (tptr tushort)))
                                                    (Sassign
                                                      (Efield
                                                        (Evar _gGeoTempState (Tstruct _GeoAnimState noattr))
                                                        _attribute
                                                        (tptr tushort))
                                                      (Etempvar _t'18 (tptr tushort))))
                                                  (Ssequence
                                                    (Ssequence
                                                      (Sset _t'17
                                                        (Evar _gCurrAnimData (tptr tshort)))
                                                      (Sassign
                                                        (Efield
                                                          (Evar _gGeoTempState (Tstruct _GeoAnimState noattr))
                                                          _data
                                                          (tptr tshort))
                                                        (Etempvar _t'17 (tptr tshort))))
                                                    (Ssequence
                                                      (Sassign
                                                        (Evar _gCurrAnimType tuchar)
                                                        (Econst_int (Int.repr 0) tint))
                                                      (Ssequence
                                                        (Sassign
                                                          (Evar _gCurGraphNodeHeldObject (tptr (Tstruct _GraphNodeHeldObject noattr)))
                                                          (Ecast
                                                            (Etempvar _node (tptr (Tstruct _GraphNodeHeldObject noattr)))
                                                            (tptr tvoid)))
                                                        (Ssequence
                                                          (Ssequence
                                                            (Sset _t'14
                                                              (Efield
                                                                (Ederef
                                                                  (Etempvar _node (tptr (Tstruct _GraphNodeHeldObject noattr)))
                                                                  (Tstruct _GraphNodeHeldObject noattr))
                                                                _objNode
                                                                (tptr (Tstruct _Object noattr))))
                                                            (Ssequence
                                                              (Sset _t'15
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
                                                                  _curAnim
                                                                  (tptr (Tstruct _Animation noattr))))
                                                              (Sifthenelse 
                                                                (Ebinop One
                                                                  (Etempvar _t'15 (tptr (Tstruct _Animation noattr)))
                                                                  (Ecast
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    (tptr tvoid))
                                                                  tint)
                                                                (Ssequence
                                                                  (Sset _t'16
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _node (tptr (Tstruct _GraphNodeHeldObject noattr)))
                                                                    (Tstruct _GraphNodeHeldObject noattr))
                                                                    _objNode
                                                                    (tptr (Tstruct _Object noattr))))
                                                                  (Scall None
                                                                    (Evar _geo_set_animation_globals 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _AnimInfo noattr)) ::
                                                                    tint ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                                                    ((Eaddrof
                                                                    (Efield
                                                                    (Efield
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'16 (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _header
                                                                    (Tstruct _ObjectNode noattr))
                                                                    _gfx
                                                                    (Tstruct _GraphNodeObject noattr))
                                                                    _animInfo
                                                                    (Tstruct _AnimInfo noattr))
                                                                    (tptr (Tstruct _AnimInfo noattr))) ::
                                                                    (Etempvar _hasAnimation tint) ::
                                                                    nil)))
                                                                Sskip)))
                                                          (Ssequence
                                                            (Ssequence
                                                              (Sset _t'12
                                                                (Efield
                                                                  (Ederef
                                                                    (Etempvar _node (tptr (Tstruct _GraphNodeHeldObject noattr)))
                                                                    (Tstruct _GraphNodeHeldObject noattr))
                                                                  _objNode
                                                                  (tptr (Tstruct _Object noattr))))
                                                              (Ssequence
                                                                (Sset _t'13
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
                                                                    _sharedChild
                                                                    (tptr (Tstruct _GraphNode noattr))))
                                                                (Scall None
                                                                  (Evar _geo_process_node_and_siblings 
                                                                  (Tfunction
                                                                    ((tptr (Tstruct _GraphNode noattr)) ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                                                  ((Etempvar _t'13 (tptr (Tstruct _GraphNode noattr))) ::
                                                                   nil))))
                                                            (Ssequence
                                                              (Sassign
                                                                (Evar _gCurGraphNodeHeldObject (tptr (Tstruct _GraphNodeHeldObject noattr)))
                                                                (Ecast
                                                                  (Econst_int (Int.repr 0) tint)
                                                                  (tptr tvoid)))
                                                              (Ssequence
                                                                (Ssequence
                                                                  (Sset _t'11
                                                                    (Efield
                                                                    (Evar _gGeoTempState (Tstruct _GeoAnimState noattr))
                                                                    _type
                                                                    tuchar))
                                                                  (Sassign
                                                                    (Evar _gCurrAnimType tuchar)
                                                                    (Etempvar _t'11 tuchar)))
                                                                (Ssequence
                                                                  (Ssequence
                                                                    (Sset _t'10
                                                                    (Efield
                                                                    (Evar _gGeoTempState (Tstruct _GeoAnimState noattr))
                                                                    _enabled
                                                                    tuchar))
                                                                    (Sassign
                                                                    (Evar _gCurrAnimEnabled tuchar)
                                                                    (Etempvar _t'10 tuchar)))
                                                                  (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'9
                                                                    (Efield
                                                                    (Evar _gGeoTempState (Tstruct _GeoAnimState noattr))
                                                                    _frame
                                                                    tshort))
                                                                    (Sassign
                                                                    (Evar _gCurrAnimFrame tshort)
                                                                    (Etempvar _t'9 tshort)))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'8
                                                                    (Efield
                                                                    (Evar _gGeoTempState (Tstruct _GeoAnimState noattr))
                                                                    _translationMultiplier
                                                                    tfloat))
                                                                    (Sassign
                                                                    (Evar _gCurrAnimTranslationMultiplier tfloat)
                                                                    (Etempvar _t'8 tfloat)))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'7
                                                                    (Efield
                                                                    (Evar _gGeoTempState (Tstruct _GeoAnimState noattr))
                                                                    _attribute
                                                                    (tptr tushort)))
                                                                    (Sassign
                                                                    (Evar _gCurrAnimAttribute (tptr tushort))
                                                                    (Etempvar _t'7 (tptr tushort))))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'6
                                                                    (Efield
                                                                    (Evar _gGeoTempState (Tstruct _GeoAnimState noattr))
                                                                    _data
                                                                    (tptr tshort)))
                                                                    (Sassign
                                                                    (Evar _gCurrAnimData (tptr tshort))
                                                                    (Etempvar _t'6 (tptr tshort))))
                                                                    (Ssequence
                                                                    (Sset _t'5
                                                                    (Evar _gMatStackIndex tshort))
                                                                    (Sassign
                                                                    (Evar _gMatStackIndex tshort)
                                                                    (Ebinop Osub
                                                                    (Etempvar _t'5 tshort)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)))))))))))))))))))))))))))))))))))
          Sskip))
      (Ssequence
        (Sset _t'3
          (Efield
            (Efield
              (Efield
                (Ederef
                  (Etempvar _node (tptr (Tstruct _GraphNodeHeldObject noattr)))
                  (Tstruct _GraphNodeHeldObject noattr)) _fnNode
                (Tstruct _FnGraphNode noattr)) _node
              (Tstruct _GraphNode noattr)) _children
            (tptr (Tstruct _GraphNode noattr))))
        (Sifthenelse (Ebinop One
                       (Etempvar _t'3 (tptr (Tstruct _GraphNode noattr)))
                       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                       tint)
          (Ssequence
            (Sset _t'4
              (Efield
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _node (tptr (Tstruct _GraphNodeHeldObject noattr)))
                      (Tstruct _GraphNodeHeldObject noattr)) _fnNode
                    (Tstruct _FnGraphNode noattr)) _node
                  (Tstruct _GraphNode noattr)) _children
                (tptr (Tstruct _GraphNode noattr))))
            (Scall None
              (Evar _geo_process_node_and_siblings (Tfunction
                                                     ((tptr (Tstruct _GraphNode noattr)) ::
                                                      nil) tvoid cc_default))
              ((Etempvar _t'4 (tptr (Tstruct _GraphNode noattr))) :: nil)))
          Sskip)))))
|}.

Definition f_geo_try_process_children := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'1, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Efield
      (Ederef (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
        (Tstruct _GraphNode noattr)) _children
      (tptr (Tstruct _GraphNode noattr))))
  (Sifthenelse (Ebinop One (Etempvar _t'1 (tptr (Tstruct _GraphNode noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Sset _t'2
        (Efield
          (Ederef (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
            (Tstruct _GraphNode noattr)) _children
          (tptr (Tstruct _GraphNode noattr))))
      (Scall None
        (Evar _geo_process_node_and_siblings (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                nil) tvoid cc_default))
        ((Etempvar _t'2 (tptr (Tstruct _GraphNode noattr))) :: nil)))
    Sskip))
|}.

Definition f_geo_process_node_and_siblings := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_firstNode, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_iterateChildren, tshort) ::
               (_curGraphNode, (tptr (Tstruct _GraphNode noattr))) ::
               (_parent, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'2, (tptr (Tstruct _GraphNode noattr))) :: (_t'1, tint) ::
               (_t'8, tshort) :: (_t'7, tshort) :: (_t'6, tshort) ::
               (_t'5, tshort) :: (_t'4, tshort) ::
               (_t'3, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _iterateChildren (Ecast (Econst_int (Int.repr 1) tint) tshort))
  (Ssequence
    (Sset _curGraphNode
      (Etempvar _firstNode (tptr (Tstruct _GraphNode noattr))))
    (Ssequence
      (Sset _parent
        (Efield
          (Ederef (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
            (Tstruct _GraphNode noattr)) _parent
          (tptr (Tstruct _GraphNode noattr))))
      (Ssequence
        (Sifthenelse (Ebinop One
                       (Etempvar _parent (tptr (Tstruct _GraphNode noattr)))
                       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                       tint)
          (Ssequence
            (Sset _t'8
              (Efield
                (Ederef (Etempvar _parent (tptr (Tstruct _GraphNode noattr)))
                  (Tstruct _GraphNode noattr)) _type tshort))
            (Sset _iterateChildren
              (Ecast
                (Ebinop One (Etempvar _t'8 tshort)
                  (Ebinop Oor (Econst_int (Int.repr 12) tint)
                    (Econst_int (Int.repr 256) tint) tint) tint) tshort)))
          Sskip)
        (Sloop
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef
                  (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                  (Tstruct _GraphNode noattr)) _flags tshort))
            (Sifthenelse (Ebinop Oand (Etempvar _t'4 tshort)
                           (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                             (Econst_int (Int.repr 0) tint) tint) tint)
              (Ssequence
                (Sset _t'6
                  (Efield
                    (Ederef
                      (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                      (Tstruct _GraphNode noattr)) _flags tshort))
                (Sifthenelse (Ebinop Oand (Etempvar _t'6 tshort)
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 1) tint) tint) tint)
                  (Scall None
                    (Evar _geo_try_process_children (Tfunction
                                                      ((tptr (Tstruct _GraphNode noattr)) ::
                                                       nil) tvoid cc_default))
                    ((Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr))) ::
                     nil))
                  (Ssequence
                    (Sset _t'7
                      (Efield
                        (Ederef
                          (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                          (Tstruct _GraphNode noattr)) _type tshort))
                    (Sswitch (Etempvar _t'7 tshort)
                      (LScons (Some 2)
                        (Ssequence
                          (Scall None
                            (Evar _geo_process_ortho_projection (Tfunction
                                                                  ((tptr (Tstruct _GraphNodeOrthoProjection noattr)) ::
                                                                   nil) tvoid
                                                                  cc_default))
                            ((Ecast
                               (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                               (tptr (Tstruct _GraphNodeOrthoProjection noattr))) ::
                             nil))
                          Sbreak)
                        (LScons (Some 259)
                          (Ssequence
                            (Scall None
                              (Evar _geo_process_perspective (Tfunction
                                                               ((tptr (Tstruct _GraphNodePerspective noattr)) ::
                                                                nil) tvoid
                                                               cc_default))
                              ((Ecast
                                 (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                                 (tptr (Tstruct _GraphNodePerspective noattr))) ::
                               nil))
                            Sbreak)
                          (LScons (Some 4)
                            (Ssequence
                              (Scall None
                                (Evar _geo_process_master_list (Tfunction
                                                                 ((tptr (Tstruct _GraphNodeMasterList noattr)) ::
                                                                  nil) tvoid
                                                                 cc_default))
                                ((Ecast
                                   (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                                   (tptr (Tstruct _GraphNodeMasterList noattr))) ::
                                 nil))
                              Sbreak)
                            (LScons (Some 11)
                              (Ssequence
                                (Scall None
                                  (Evar _geo_process_level_of_detail 
                                  (Tfunction
                                    ((tptr (Tstruct _GraphNodeLevelOfDetail noattr)) ::
                                     nil) tvoid cc_default))
                                  ((Ecast
                                     (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                                     (tptr (Tstruct _GraphNodeLevelOfDetail noattr))) ::
                                   nil))
                                Sbreak)
                              (LScons (Some 268)
                                (Ssequence
                                  (Scall None
                                    (Evar _geo_process_switch (Tfunction
                                                                ((tptr (Tstruct _GraphNodeSwitchCase noattr)) ::
                                                                 nil) tvoid
                                                                cc_default))
                                    ((Ecast
                                       (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                                       (tptr (Tstruct _GraphNodeSwitchCase noattr))) ::
                                     nil))
                                  Sbreak)
                                (LScons (Some 276)
                                  (Ssequence
                                    (Scall None
                                      (Evar _geo_process_camera (Tfunction
                                                                  ((tptr (Tstruct _GraphNodeCamera noattr)) ::
                                                                   nil) tvoid
                                                                  cc_default))
                                      ((Ecast
                                         (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                                         (tptr (Tstruct _GraphNodeCamera noattr))) ::
                                       nil))
                                    Sbreak)
                                  (LScons (Some 21)
                                    (Ssequence
                                      (Scall None
                                        (Evar _geo_process_translation_rotation 
                                        (Tfunction
                                          ((tptr (Tstruct _GraphNodeTranslationRotation noattr)) ::
                                           nil) tvoid cc_default))
                                        ((Ecast
                                           (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                                           (tptr (Tstruct _GraphNodeTranslationRotation noattr))) ::
                                         nil))
                                      Sbreak)
                                    (LScons (Some 22)
                                      (Ssequence
                                        (Scall None
                                          (Evar _geo_process_translation 
                                          (Tfunction
                                            ((tptr (Tstruct _GraphNodeTranslation noattr)) ::
                                             nil) tvoid cc_default))
                                          ((Ecast
                                             (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                                             (tptr (Tstruct _GraphNodeTranslation noattr))) ::
                                           nil))
                                        Sbreak)
                                      (LScons (Some 23)
                                        (Ssequence
                                          (Scall None
                                            (Evar _geo_process_rotation 
                                            (Tfunction
                                              ((tptr (Tstruct _GraphNodeRotation noattr)) ::
                                               nil) tvoid cc_default))
                                            ((Ecast
                                               (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                                               (tptr (Tstruct _GraphNodeRotation noattr))) ::
                                             nil))
                                          Sbreak)
                                        (LScons (Some 24)
                                          (Ssequence
                                            (Scall None
                                              (Evar _geo_process_object 
                                              (Tfunction
                                                ((tptr (Tstruct _Object noattr)) ::
                                                 nil) tvoid cc_default))
                                              ((Ecast
                                                 (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                                                 (tptr (Tstruct _Object noattr))) ::
                                               nil))
                                            Sbreak)
                                          (LScons (Some 25)
                                            (Ssequence
                                              (Scall None
                                                (Evar _geo_process_animated_part 
                                                (Tfunction
                                                  ((tptr (Tstruct _GraphNodeAnimatedPart noattr)) ::
                                                   nil) tvoid cc_default))
                                                ((Ecast
                                                   (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                                                   (tptr (Tstruct _GraphNodeAnimatedPart noattr))) ::
                                                 nil))
                                              Sbreak)
                                            (LScons (Some 26)
                                              (Ssequence
                                                (Scall None
                                                  (Evar _geo_process_billboard 
                                                  (Tfunction
                                                    ((tptr (Tstruct _GraphNodeBillboard noattr)) ::
                                                     nil) tvoid cc_default))
                                                  ((Ecast
                                                     (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                                                     (tptr (Tstruct _GraphNodeBillboard noattr))) ::
                                                   nil))
                                                Sbreak)
                                              (LScons (Some 27)
                                                (Ssequence
                                                  (Scall None
                                                    (Evar _geo_process_display_list 
                                                    (Tfunction
                                                      ((tptr (Tstruct _GraphNodeDisplayList noattr)) ::
                                                       nil) tvoid cc_default))
                                                    ((Ecast
                                                       (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                                                       (tptr (Tstruct _GraphNodeDisplayList noattr))) ::
                                                     nil))
                                                  Sbreak)
                                                (LScons (Some 28)
                                                  (Ssequence
                                                    (Scall None
                                                      (Evar _geo_process_scale 
                                                      (Tfunction
                                                        ((tptr (Tstruct _GraphNodeScale noattr)) ::
                                                         nil) tvoid
                                                        cc_default))
                                                      ((Ecast
                                                         (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                                                         (tptr (Tstruct _GraphNodeScale noattr))) ::
                                                       nil))
                                                    Sbreak)
                                                  (LScons (Some 40)
                                                    (Ssequence
                                                      (Scall None
                                                        (Evar _geo_process_shadow 
                                                        (Tfunction
                                                          ((tptr (Tstruct _GraphNodeShadow noattr)) ::
                                                           nil) tvoid
                                                          cc_default))
                                                        ((Ecast
                                                           (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                                                           (tptr (Tstruct _GraphNodeShadow noattr))) ::
                                                         nil))
                                                      Sbreak)
                                                    (LScons (Some 41)
                                                      (Ssequence
                                                        (Scall None
                                                          (Evar _geo_process_object_parent 
                                                          (Tfunction
                                                            ((tptr (Tstruct _GraphNodeObjectParent noattr)) ::
                                                             nil) tvoid
                                                            cc_default))
                                                          ((Ecast
                                                             (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                                                             (tptr (Tstruct _GraphNodeObjectParent noattr))) ::
                                                           nil))
                                                        Sbreak)
                                                      (LScons (Some 298)
                                                        (Ssequence
                                                          (Scall None
                                                            (Evar _geo_process_generated_list 
                                                            (Tfunction
                                                              ((tptr (Tstruct _GraphNodeGenerated noattr)) ::
                                                               nil) tvoid
                                                              cc_default))
                                                            ((Ecast
                                                               (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                                                               (tptr (Tstruct _GraphNodeGenerated noattr))) ::
                                                             nil))
                                                          Sbreak)
                                                        (LScons (Some 300)
                                                          (Ssequence
                                                            (Scall None
                                                              (Evar _geo_process_background 
                                                              (Tfunction
                                                                ((tptr (Tstruct _GraphNodeBackground noattr)) ::
                                                                 nil) tvoid
                                                                cc_default))
                                                              ((Ecast
                                                                 (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                                                                 (tptr (Tstruct _GraphNodeBackground noattr))) ::
                                                               nil))
                                                            Sbreak)
                                                          (LScons (Some 302)
                                                            (Ssequence
                                                              (Scall None
                                                                (Evar _geo_process_held_object 
                                                                (Tfunction
                                                                  ((tptr (Tstruct _GraphNodeHeldObject noattr)) ::
                                                                   nil) tvoid
                                                                  cc_default))
                                                                ((Ecast
                                                                   (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                                                                   (tptr (Tstruct _GraphNodeHeldObject noattr))) ::
                                                                 nil))
                                                              Sbreak)
                                                            (LScons None
                                                              (Ssequence
                                                                (Scall None
                                                                  (Evar _geo_try_process_children 
                                                                  (Tfunction
                                                                    ((tptr (Tstruct _GraphNode noattr)) ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                                                  ((Ecast
                                                                    (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                                                                    (tptr (Tstruct _GraphNode noattr))) ::
                                                                   nil))
                                                                Sbreak)
                                                              LSnil))))))))))))))))))))))))
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef
                      (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                      (Tstruct _GraphNode noattr)) _type tshort))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tshort)
                               (Econst_int (Int.repr 24) tint) tint)
                  (Sassign
                    (Efield
                      (Ederef
                        (Ecast
                          (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                          (tptr (Tstruct _GraphNodeObject noattr)))
                        (Tstruct _GraphNodeObject noattr)) _throwMatrix
                      (tptr (tarray (tarray tfloat 4) 4)))
                    (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
                  Sskip))))
          (Ssequence
            (Sifthenelse (Etempvar _iterateChildren tshort)
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'3
                      (Efield
                        (Ederef
                          (Etempvar _curGraphNode (tptr (Tstruct _GraphNode noattr)))
                          (Tstruct _GraphNode noattr)) _next
                        (tptr (Tstruct _GraphNode noattr))))
                    (Sset _t'2
                      (Ecast
                        (Etempvar _t'3 (tptr (Tstruct _GraphNode noattr)))
                        (tptr (Tstruct _GraphNode noattr)))))
                  (Sset _curGraphNode
                    (Etempvar _t'2 (tptr (Tstruct _GraphNode noattr)))))
                (Sset _t'1
                  (Ecast
                    (Ebinop One
                      (Etempvar _t'2 (tptr (Tstruct _GraphNode noattr)))
                      (Etempvar _firstNode (tptr (Tstruct _GraphNode noattr)))
                      tint) tbool)))
              (Sset _t'1 (Econst_int (Int.repr 0) tint)))
            (Sifthenelse (Etempvar _t'1 tint) Sskip Sbreak)))))))
|}.

Definition f_geo_process_root := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_node, (tptr (Tstruct _GraphNodeRoot noattr))) ::
                (_b, (tptr (Tunion __476 noattr))) ::
                (_c, (tptr (Tunion __476 noattr))) :: (_clearColor, tint) ::
                nil);
  fn_vars := ((_filler, (tarray tuchar 4)) :: nil);
  fn_temps := ((_initialMatrix, (tptr (Tunion __472 noattr))) ::
               (_viewport, (tptr (Tunion __476 noattr))) ::
               (__g, (tptr (Tunion __512 noattr))) ::
               (__g__1, (tptr (Tunion __512 noattr))) ::
               (_t'6, (tptr (Tunion __512 noattr))) ::
               (_t'5, (tptr (Tunion __512 noattr))) ::
               (_t'4, (tptr tvoid)) ::
               (_t'3, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'2, tuint) :: (_t'1, (tptr tvoid)) :: (_t'24, tshort) ::
               (_t'23, tshort) :: (_t'22, tshort) :: (_t'21, tshort) ::
               (_t'20, tshort) :: (_t'19, tshort) :: (_t'18, tshort) ::
               (_t'17, (tptr (Tunion __472 noattr))) :: (_t'16, tshort) ::
               (_t'15, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'14, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'13, tint) ::
               (_t'12, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'11, tint) ::
               (_t'10, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'9, tschar) ::
               (_t'8, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'7, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'7
    (Efield
      (Efield
        (Ederef (Etempvar _node (tptr (Tstruct _GraphNodeRoot noattr)))
          (Tstruct _GraphNodeRoot noattr)) _node (Tstruct _GraphNode noattr))
      _flags tshort))
  (Sifthenelse (Ebinop Oand (Etempvar _t'7 tshort)
                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                   (Econst_int (Int.repr 0) tint) tint) tint)
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                      cc_default))
          ((Esizeof (Tunion __476 noattr) tuint) :: nil))
        (Sset _viewport (Etempvar _t'1 (tptr tvoid))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Scall (Some _t'2)
              (Evar _main_pool_available (Tfunction nil tuint cc_default))
              nil)
            (Scall (Some _t'3)
              (Evar _alloc_only_pool_init (Tfunction (tuint :: tuint :: nil)
                                            (tptr (Tstruct _AllocOnlyPool noattr))
                                            cc_default))
              ((Ebinop Osub (Etempvar _t'2 tuint)
                 (Esizeof (Tstruct _AllocOnlyPool noattr) tuint) tuint) ::
               (Econst_int (Int.repr 0) tint) :: nil)))
          (Sassign
            (Evar _gDisplayListHeap (tptr (Tstruct _AllocOnlyPool noattr)))
            (Etempvar _t'3 (tptr (Tstruct _AllocOnlyPool noattr)))))
        (Ssequence
          (Ssequence
            (Scall (Some _t'4)
              (Evar _alloc_display_list (Tfunction (tuint :: nil)
                                          (tptr tvoid) cc_default))
              ((Esizeof (Tunion __472 noattr) tuint) :: nil))
            (Sset _initialMatrix (Etempvar _t'4 (tptr tvoid))))
          (Ssequence
            (Sassign (Evar _gMatStackIndex tshort)
              (Econst_int (Int.repr 0) tint))
            (Ssequence
              (Sassign (Evar _gCurrAnimType tuchar)
                (Econst_int (Int.repr 0) tint))
              (Ssequence
                (Ssequence
                  (Sset _t'23
                    (Efield
                      (Ederef
                        (Etempvar _node (tptr (Tstruct _GraphNodeRoot noattr)))
                        (Tstruct _GraphNodeRoot noattr)) _x tshort))
                  (Ssequence
                    (Sset _t'24
                      (Efield
                        (Ederef
                          (Etempvar _node (tptr (Tstruct _GraphNodeRoot noattr)))
                          (Tstruct _GraphNodeRoot noattr)) _y tshort))
                    (Scall None
                      (Evar _vec3s_set (Tfunction
                                         ((tptr tshort) :: tshort ::
                                          tshort :: tshort :: nil)
                                         (tptr tvoid) cc_default))
                      ((Efield
                         (Efield
                           (Ederef
                             (Etempvar _viewport (tptr (Tunion __476 noattr)))
                             (Tunion __476 noattr)) _vp
                           (Tstruct __474 noattr)) _vtrans (tarray tshort 4)) ::
                       (Ebinop Omul (Etempvar _t'23 tshort)
                         (Econst_int (Int.repr 4) tint) tint) ::
                       (Ebinop Omul (Etempvar _t'24 tshort)
                         (Econst_int (Int.repr 4) tint) tint) ::
                       (Econst_int (Int.repr 511) tint) :: nil))))
                (Ssequence
                  (Ssequence
                    (Sset _t'21
                      (Efield
                        (Ederef
                          (Etempvar _node (tptr (Tstruct _GraphNodeRoot noattr)))
                          (Tstruct _GraphNodeRoot noattr)) _width tshort))
                    (Ssequence
                      (Sset _t'22
                        (Efield
                          (Ederef
                            (Etempvar _node (tptr (Tstruct _GraphNodeRoot noattr)))
                            (Tstruct _GraphNodeRoot noattr)) _height tshort))
                      (Scall None
                        (Evar _vec3s_set (Tfunction
                                           ((tptr tshort) :: tshort ::
                                            tshort :: tshort :: nil)
                                           (tptr tvoid) cc_default))
                        ((Efield
                           (Efield
                             (Ederef
                               (Etempvar _viewport (tptr (Tunion __476 noattr)))
                               (Tunion __476 noattr)) _vp
                             (Tstruct __474 noattr)) _vscale
                           (tarray tshort 4)) ::
                         (Ebinop Omul (Etempvar _t'21 tshort)
                           (Econst_int (Int.repr 4) tint) tint) ::
                         (Ebinop Omul (Etempvar _t'22 tshort)
                           (Econst_int (Int.repr 4) tint) tint) ::
                         (Econst_int (Int.repr 511) tint) :: nil))))
                  (Ssequence
                    (Sifthenelse (Ebinop One
                                   (Etempvar _b (tptr (Tunion __476 noattr)))
                                   (Ecast (Econst_int (Int.repr 0) tint)
                                     (tptr tvoid)) tint)
                      (Ssequence
                        (Scall None
                          (Evar _clear_framebuffer (Tfunction (tint :: nil)
                                                     tvoid cc_default))
                          ((Etempvar _clearColor tint) :: nil))
                        (Ssequence
                          (Scall None
                            (Evar _make_viewport_clip_rect (Tfunction
                                                             ((tptr (Tunion __476 noattr)) ::
                                                              nil) tvoid
                                                             cc_default))
                            ((Etempvar _b (tptr (Tunion __476 noattr))) ::
                             nil))
                          (Sassign
                            (Ederef
                              (Etempvar _viewport (tptr (Tunion __476 noattr)))
                              (Tunion __476 noattr))
                            (Ederef
                              (Etempvar _b (tptr (Tunion __476 noattr)))
                              (Tunion __476 noattr)))))
                      (Sifthenelse (Ebinop One
                                     (Etempvar _c (tptr (Tunion __476 noattr)))
                                     (Ecast (Econst_int (Int.repr 0) tint)
                                       (tptr tvoid)) tint)
                        (Ssequence
                          (Scall None
                            (Evar _clear_framebuffer (Tfunction (tint :: nil)
                                                       tvoid cc_default))
                            ((Etempvar _clearColor tint) :: nil))
                          (Scall None
                            (Evar _make_viewport_clip_rect (Tfunction
                                                             ((tptr (Tunion __476 noattr)) ::
                                                              nil) tvoid
                                                             cc_default))
                            ((Etempvar _c (tptr (Tunion __476 noattr))) ::
                             nil)))
                        Sskip))
                    (Ssequence
                      (Ssequence
                        (Sset _t'20 (Evar _gMatStackIndex tshort))
                        (Scall None
                          (Evar _mtxf_identity (Tfunction
                                                 ((tptr (tarray tfloat 4)) ::
                                                  nil) tvoid cc_default))
                          ((Ederef
                             (Ebinop Oadd
                               (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                               (Etempvar _t'20 tshort)
                               (tptr (tarray (tarray tfloat 4) 4)))
                             (tarray (tarray tfloat 4) 4)) :: nil)))
                      (Ssequence
                        (Ssequence
                          (Sset _t'19 (Evar _gMatStackIndex tshort))
                          (Scall None
                            (Evar _mtxf_to_mtx (Tfunction
                                                 ((tptr (Tunion __472 noattr)) ::
                                                  (tptr (tarray tfloat 4)) ::
                                                  nil) tvoid cc_default))
                            ((Etempvar _initialMatrix (tptr (Tunion __472 noattr))) ::
                             (Ederef
                               (Ebinop Oadd
                                 (Evar _gMatStack (tarray (tarray (tarray tfloat 4) 4) 32))
                                 (Etempvar _t'19 tshort)
                                 (tptr (tarray (tarray tfloat 4) 4)))
                               (tarray (tarray tfloat 4) 4)) :: nil)))
                        (Ssequence
                          (Ssequence
                            (Sset _t'18 (Evar _gMatStackIndex tshort))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Evar _gMatStackFixed (tarray (tptr (Tunion __472 noattr)) 32))
                                  (Etempvar _t'18 tshort)
                                  (tptr (tptr (Tunion __472 noattr))))
                                (tptr (Tunion __472 noattr)))
                              (Etempvar _initialMatrix (tptr (Tunion __472 noattr)))))
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Ssequence
                                  (Sset _t'5
                                    (Evar _gDisplayListHead (tptr (Tunion __512 noattr))))
                                  (Sassign
                                    (Evar _gDisplayListHead (tptr (Tunion __512 noattr)))
                                    (Ebinop Oadd
                                      (Etempvar _t'5 (tptr (Tunion __512 noattr)))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr (Tunion __512 noattr)))))
                                (Sset __g
                                  (Ecast
                                    (Etempvar _t'5 (tptr (Tunion __512 noattr)))
                                    (tptr (Tunion __512 noattr)))))
                              (Ssequence
                                (Sassign
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar __g (tptr (Tunion __512 noattr)))
                                        (Tunion __512 noattr)) _words
                                      (Tstruct __510 noattr)) _w0 tuint)
                                  (Ebinop Oor
                                    (Ebinop Oor
                                      (Ecast
                                        (Ebinop Oshl
                                          (Ebinop Oand
                                            (Ecast
                                              (Econst_int (Int.repr 3) tint)
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
                                              (Econst_int (Int.repr 128) tint)
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
                                            (Esizeof (Tunion __476 noattr) tuint)
                                            tuint)
                                          (Ebinop Osub
                                            (Ebinop Oshl
                                              (Econst_int (Int.repr 1) tint)
                                              (Econst_int (Int.repr 16) tint)
                                              tint)
                                            (Econst_int (Int.repr 1) tint)
                                            tint) tuint)
                                        (Econst_int (Int.repr 0) tint) tuint)
                                      tuint) tuint))
                                (Sassign
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar __g (tptr (Tunion __512 noattr)))
                                        (Tunion __512 noattr)) _words
                                      (Tstruct __510 noattr)) _w1 tuint)
                                  (Ecast
                                    (Ebinop Oand
                                      (Ecast
                                        (Etempvar _viewport (tptr (Tunion __476 noattr)))
                                        tuint)
                                      (Econst_int (Int.repr 536870911) tint)
                                      tuint) tuint))))
                            (Ssequence
                              (Ssequence
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'6
                                      (Evar _gDisplayListHead (tptr (Tunion __512 noattr))))
                                    (Sassign
                                      (Evar _gDisplayListHead (tptr (Tunion __512 noattr)))
                                      (Ebinop Oadd
                                        (Etempvar _t'6 (tptr (Tunion __512 noattr)))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr (Tunion __512 noattr)))))
                                  (Sset __g__1
                                    (Ecast
                                      (Etempvar _t'6 (tptr (Tunion __512 noattr)))
                                      (tptr (Tunion __512 noattr)))))
                                (Ssequence
                                  (Sassign
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar __g__1 (tptr (Tunion __512 noattr)))
                                          (Tunion __512 noattr)) _words
                                        (Tstruct __510 noattr)) _w0 tuint)
                                    (Ebinop Oor
                                      (Ebinop Oor
                                        (Ecast
                                          (Ebinop Oshl
                                            (Ebinop Oand
                                              (Ecast
                                                (Econst_int (Int.repr 1) tint)
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
                                                (Ebinop Oor
                                                  (Ebinop Oor
                                                    (Econst_int (Int.repr 0) tint)
                                                    (Econst_int (Int.repr 2) tint)
                                                    tint)
                                                  (Econst_int (Int.repr 0) tint)
                                                  tint) tuint)
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
                                              (Esizeof (Tunion __472 noattr) tuint)
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
                                  (Ssequence
                                    (Sset _t'16
                                      (Evar _gMatStackIndex tshort))
                                    (Ssequence
                                      (Sset _t'17
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _gMatStackFixed (tarray (tptr (Tunion __472 noattr)) 32))
                                            (Etempvar _t'16 tshort)
                                            (tptr (tptr (Tunion __472 noattr))))
                                          (tptr (Tunion __472 noattr))))
                                      (Sassign
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar __g__1 (tptr (Tunion __512 noattr)))
                                              (Tunion __512 noattr)) _words
                                            (Tstruct __510 noattr)) _w1
                                          tuint)
                                        (Ecast
                                          (Ebinop Oand
                                            (Ecast
                                              (Etempvar _t'17 (tptr (Tunion __472 noattr)))
                                              tuint)
                                            (Econst_int (Int.repr 536870911) tint)
                                            tuint) tuint))))))
                              (Ssequence
                                (Sassign
                                  (Evar _gCurGraphNodeRoot (tptr (Tstruct _GraphNodeRoot noattr)))
                                  (Etempvar _node (tptr (Tstruct _GraphNodeRoot noattr))))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'14
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _node (tptr (Tstruct _GraphNodeRoot noattr)))
                                            (Tstruct _GraphNodeRoot noattr))
                                          _node (Tstruct _GraphNode noattr))
                                        _children
                                        (tptr (Tstruct _GraphNode noattr))))
                                    (Sifthenelse (Ebinop One
                                                   (Etempvar _t'14 (tptr (Tstruct _GraphNode noattr)))
                                                   (Ecast
                                                     (Econst_int (Int.repr 0) tint)
                                                     (tptr tvoid)) tint)
                                      (Ssequence
                                        (Sset _t'15
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _node (tptr (Tstruct _GraphNodeRoot noattr)))
                                                (Tstruct _GraphNodeRoot noattr))
                                              _node
                                              (Tstruct _GraphNode noattr))
                                            _children
                                            (tptr (Tstruct _GraphNode noattr))))
                                        (Scall None
                                          (Evar _geo_process_node_and_siblings 
                                          (Tfunction
                                            ((tptr (Tstruct _GraphNode noattr)) ::
                                             nil) tvoid cc_default))
                                          ((Etempvar _t'15 (tptr (Tstruct _GraphNode noattr))) ::
                                           nil)))
                                      Sskip))
                                  (Ssequence
                                    (Sassign
                                      (Evar _gCurGraphNodeRoot (tptr (Tstruct _GraphNodeRoot noattr)))
                                      (Ecast (Econst_int (Int.repr 0) tint)
                                        (tptr tvoid)))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'9
                                          (Evar _gShowDebugText tschar))
                                        (Sifthenelse (Etempvar _t'9 tschar)
                                          (Ssequence
                                            (Sset _t'10
                                              (Evar _gDisplayListHeap (tptr (Tstruct _AllocOnlyPool noattr))))
                                            (Ssequence
                                              (Sset _t'11
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _t'10 (tptr (Tstruct _AllocOnlyPool noattr)))
                                                    (Tstruct _AllocOnlyPool noattr))
                                                  _totalSpace tint))
                                              (Ssequence
                                                (Sset _t'12
                                                  (Evar _gDisplayListHeap (tptr (Tstruct _AllocOnlyPool noattr))))
                                                (Ssequence
                                                  (Sset _t'13
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _t'12 (tptr (Tstruct _AllocOnlyPool noattr)))
                                                        (Tstruct _AllocOnlyPool noattr))
                                                      _usedSpace tint))
                                                  (Scall None
                                                    (Evar _print_text_fmt_int 
                                                    (Tfunction
                                                      (tint :: tint ::
                                                       (tptr tuchar) ::
                                                       tint :: nil) tvoid
                                                      cc_default))
                                                    ((Econst_int (Int.repr 180) tint) ::
                                                     (Econst_int (Int.repr 36) tint) ::
                                                     (Evar ___stringlit_1 (tarray tuchar 7)) ::
                                                     (Ebinop Osub
                                                       (Etempvar _t'11 tint)
                                                       (Etempvar _t'13 tint)
                                                       tint) :: nil))))))
                                          Sskip))
                                      (Ssequence
                                        (Sset _t'8
                                          (Evar _gDisplayListHeap (tptr (Tstruct _AllocOnlyPool noattr))))
                                        (Scall None
                                          (Evar _main_pool_free (Tfunction
                                                                  ((tptr tvoid) ::
                                                                   nil) tuint
                                                                  cc_default))
                                          ((Etempvar _t'8 (tptr (Tstruct _AllocOnlyPool noattr))) ::
                                           nil))))))))))))))))))))
    Sskip))
|}.

Definition composites : list composite_definition :=
(Composite __472 Union
   (Member_plain _m (tarray (tarray tint 4) 4) ::
    Member_plain _force_structure_alignment tlong :: nil)
   noattr ::
 Composite __474 Struct
   (Member_plain _vscale (tarray tshort 4) ::
    Member_plain _vtrans (tarray tshort 4) :: nil)
   noattr ::
 Composite __476 Union
   (Member_plain _vp (Tstruct __474 noattr) ::
    Member_plain _force_structure_alignment tlong :: nil)
   noattr ::
 Composite __510 Struct
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
 Composite _GraphNodeOrthoProjection Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _scale tfloat :: nil)
   noattr ::
 Composite _GraphNodePerspective Struct
   (Member_plain _fnNode (Tstruct _FnGraphNode noattr) ::
    Member_plain _unused tint :: Member_plain _fov tfloat ::
    Member_plain _near tshort :: Member_plain _far tshort :: nil)
   noattr ::
 Composite _DisplayListNode Struct
   (Member_plain _transform (tptr (Tunion __472 noattr)) ::
    Member_plain _displayList (tptr tvoid) ::
    Member_plain _next (tptr (Tstruct _DisplayListNode noattr)) :: nil)
   noattr ::
 Composite _GraphNodeMasterList Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _listHeads
      (tarray (tptr (Tstruct _DisplayListNode noattr)) 8) ::
    Member_plain _listTails
      (tarray (tptr (Tstruct _DisplayListNode noattr)) 8) :: nil)
   noattr ::
 Composite _GraphNodeLevelOfDetail Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _minDistance tshort :: Member_plain _maxDistance tshort ::
    nil)
   noattr ::
 Composite _GraphNodeSwitchCase Struct
   (Member_plain _fnNode (Tstruct _FnGraphNode noattr) ::
    Member_plain _unused tint :: Member_plain _numCases tshort ::
    Member_plain _selectedCase tshort :: nil)
   noattr ::
 Composite __918 Union
   (Member_plain _mode tint ::
    Member_plain _camera (tptr (Tstruct _Camera noattr)) :: nil)
   noattr ::
 Composite _GraphNodeCamera Struct
   (Member_plain _fnNode (Tstruct _FnGraphNode noattr) ::
    Member_plain _config (Tunion __918 noattr) ::
    Member_plain _pos (tarray tfloat 3) ::
    Member_plain _focus (tarray tfloat 3) ::
    Member_plain _matrixPtr (tptr (tarray (tarray tfloat 4) 4)) ::
    Member_plain _roll tshort :: Member_plain _rollScreen tshort :: nil)
   noattr ::
 Composite _GraphNodeTranslationRotation Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _displayList (tptr tvoid) ::
    Member_plain _translation (tarray tshort 3) ::
    Member_plain _rotation (tarray tshort 3) :: nil)
   noattr ::
 Composite _GraphNodeTranslation Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _displayList (tptr tvoid) ::
    Member_plain _translation (tarray tshort 3) ::
    Member_plain _filler (tarray tuchar 2) :: nil)
   noattr ::
 Composite _GraphNodeRotation Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _displayList (tptr tvoid) ::
    Member_plain _rotation (tarray tshort 3) ::
    Member_plain _filler (tarray tuchar 2) :: nil)
   noattr ::
 Composite _GraphNodeAnimatedPart Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _displayList (tptr tvoid) ::
    Member_plain _translation (tarray tshort 3) :: nil)
   noattr ::
 Composite _GraphNodeBillboard Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _displayList (tptr tvoid) ::
    Member_plain _translation (tarray tshort 3) :: nil)
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
 Composite _GraphNodeShadow Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _shadowScale tshort ::
    Member_plain _shadowSolidity tuchar :: Member_plain _shadowType tuchar ::
    nil)
   noattr ::
 Composite _GraphNodeObjectParent Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _sharedChild (tptr (Tstruct _GraphNode noattr)) :: nil)
   noattr ::
 Composite _GraphNodeGenerated Struct
   (Member_plain _fnNode (Tstruct _FnGraphNode noattr) ::
    Member_plain _parameter tuint :: nil)
   noattr ::
 Composite _GraphNodeBackground Struct
   (Member_plain _fnNode (Tstruct _FnGraphNode noattr) ::
    Member_plain _unused tint :: Member_plain _background tint :: nil)
   noattr ::
 Composite _GraphNodeHeldObject Struct
   (Member_plain _fnNode (Tstruct _FnGraphNode noattr) ::
    Member_plain _playerIndex tint ::
    Member_plain _objNode (tptr (Tstruct _Object noattr)) ::
    Member_plain _translation (tarray tshort 3) :: nil)
   noattr ::
 Composite _GraphNodeCullingRadius Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _cullingRadius tshort ::
    Member_plain _filler (tarray tuchar 2) :: nil)
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
 Composite _SpawnInfo Struct
   (Member_plain _startPos (tarray tshort 3) ::
    Member_plain _startAngle (tarray tshort 3) ::
    Member_plain _areaIndex tschar :: Member_plain _activeAreaIndex tschar ::
    Member_plain _behaviorArg tuint ::
    Member_plain _behaviorScript (tptr tvoid) ::
    Member_plain _model (tptr (Tstruct _GraphNode noattr)) ::
    Member_plain _next (tptr (Tstruct _SpawnInfo noattr)) :: nil)
   noattr ::
 Composite _GeoAnimState Struct
   (Member_plain _type tuchar :: Member_plain _enabled tuchar ::
    Member_plain _frame tshort ::
    Member_plain _translationMultiplier tfloat ::
    Member_plain _attribute (tptr tushort) ::
    Member_plain _data (tptr tshort) :: nil)
   noattr ::
 Composite _RenderModeContainer Struct
   (Member_plain _modes (tarray tuint 8) :: nil)
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
     cc_default)) :: (___stringlit_1, Gvar v___stringlit_1) ::
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
 (_guPerspective,
   Gfun(External (EF_external "guPerspective"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xsingle :: AST.Xsingle :: AST.Xsingle :: nil)
                     AST.Xvoid cc_default))
     ((tptr (Tunion __472 noattr)) :: (tptr tushort) :: tfloat :: tfloat ::
      tfloat :: tfloat :: tfloat :: nil) tvoid cc_default)) ::
 (_guOrtho,
   Gfun(External (EF_external "guOrtho"
                   (mksignature
                     (AST.Xptr :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xsingle :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xsingle :: AST.Xsingle :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tunion __472 noattr)) :: tfloat :: tfloat :: tfloat :: tfloat ::
      tfloat :: tfloat :: tfloat :: nil) tvoid cc_default)) ::
 (_segmented_to_virtual,
   Gfun(External (EF_external "segmented_to_virtual"
                   (mksignature (AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr tvoid) :: nil) (tptr tvoid) cc_default)) ::
 (_main_pool_free,
   Gfun(External (EF_external "main_pool_free"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr tvoid) :: nil) tuint cc_default)) ::
 (_main_pool_available,
   Gfun(External (EF_external "main_pool_available"
                   (mksignature nil AST.Xint cc_default)) nil tuint
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
 (_alloc_display_list,
   Gfun(External (EF_external "alloc_display_list"
                   (mksignature (AST.Xint :: nil) AST.Xptr cc_default))
     (tuint :: nil) (tptr tvoid) cc_default)) ::
 (_gVec3fZero, Gvar v_gVec3fZero) :: (_gVec3sZero, Gvar v_gVec3sZero) ::
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
     cc_default)) :: (_gSineTable, Gvar v_gSineTable) ::
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
 (_mtxf_copy,
   Gfun(External (EF_external "mtxf_copy"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xvoid
                     cc_default))
     ((tptr (tarray tfloat 4)) :: (tptr (tarray tfloat 4)) :: nil) tvoid
     cc_default)) ::
 (_mtxf_identity,
   Gfun(External (EF_external "mtxf_identity"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (tarray tfloat 4)) :: nil) tvoid cc_default)) ::
 (_mtxf_translate,
   Gfun(External (EF_external "mtxf_translate"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xvoid
                     cc_default))
     ((tptr (tarray tfloat 4)) :: (tptr tfloat) :: nil) tvoid cc_default)) ::
 (_mtxf_lookat,
   Gfun(External (EF_external "mtxf_lookat"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xptr :: AST.Xint16signed ::
                      nil) AST.Xvoid cc_default))
     ((tptr (tarray tfloat 4)) :: (tptr tfloat) :: (tptr tfloat) :: tshort ::
      nil) tvoid cc_default)) ::
 (_mtxf_rotate_zxy_and_translate,
   Gfun(External (EF_external "mtxf_rotate_zxy_and_translate"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xvoid cc_default))
     ((tptr (tarray tfloat 4)) :: (tptr tfloat) :: (tptr tshort) :: nil)
     tvoid cc_default)) ::
 (_mtxf_rotate_xyz_and_translate,
   Gfun(External (EF_external "mtxf_rotate_xyz_and_translate"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xvoid cc_default))
     ((tptr (tarray tfloat 4)) :: (tptr tfloat) :: (tptr tshort) :: nil)
     tvoid cc_default)) ::
 (_mtxf_billboard,
   Gfun(External (EF_external "mtxf_billboard"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xptr :: AST.Xint16signed ::
                      nil) AST.Xvoid cc_default))
     ((tptr (tarray tfloat 4)) :: (tptr (tarray tfloat 4)) ::
      (tptr tfloat) :: tshort :: nil) tvoid cc_default)) ::
 (_mtxf_mul,
   Gfun(External (EF_external "mtxf_mul"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xvoid cc_default))
     ((tptr (tarray tfloat 4)) :: (tptr (tarray tfloat 4)) ::
      (tptr (tarray tfloat 4)) :: nil) tvoid cc_default)) ::
 (_mtxf_scale_vec3f,
   Gfun(External (EF_external "mtxf_scale_vec3f"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xvoid cc_default))
     ((tptr (tarray tfloat 4)) :: (tptr (tarray tfloat 4)) ::
      (tptr tfloat) :: nil) tvoid cc_default)) ::
 (_mtxf_to_mtx,
   Gfun(External (EF_external "mtxf_to_mtx"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tunion __472 noattr)) :: (tptr (tarray tfloat 4)) :: nil) tvoid
     cc_default)) ::
 (_mtxf_rotate_xy,
   Gfun(External (EF_external "mtxf_rotate_xy"
                   (mksignature (AST.Xptr :: AST.Xint16signed :: nil)
                     AST.Xvoid cc_default))
     ((tptr (Tunion __472 noattr)) :: tshort :: nil) tvoid cc_default)) ::
 (_get_pos_from_transform_mtx,
   Gfun(External (EF_external "get_pos_from_transform_mtx"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xvoid cc_default))
     ((tptr tfloat) :: (tptr (tarray tfloat 4)) ::
      (tptr (tarray tfloat 4)) :: nil) tvoid cc_default)) ::
 (_gDisplayListHead, Gvar v_gDisplayListHead) ::
 (_clear_framebuffer,
   Gfun(External (EF_external "clear_framebuffer"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tint :: nil) tvoid cc_default)) ::
 (_make_viewport_clip_rect,
   Gfun(External (EF_external "make_viewport_clip_rect"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tunion __476 noattr)) :: nil) tvoid cc_default)) ::
 (_gShowDebugText, Gvar v_gShowDebugText) ::
 (_print_text_fmt_int,
   Gfun(External (EF_external "print_text_fmt_int"
                   (mksignature
                     (AST.Xint :: AST.Xint :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     (tint :: tint :: (tptr tuchar) :: tint :: nil) tvoid cc_default)) ::
 (_gShadowAboveWaterOrLava, Gvar v_gShadowAboveWaterOrLava) ::
 (_gMarioOnIceOrCarpet, Gvar v_gMarioOnIceOrCarpet) ::
 (_create_shadow_below_xyz,
   Gfun(External (EF_external "create_shadow_below_xyz"
                   (mksignature
                     (AST.Xsingle :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xint16signed :: AST.Xint8unsigned ::
                      AST.Xint8signed :: nil) AST.Xptr cc_default))
     (tfloat :: tfloat :: tfloat :: tshort :: tuchar :: tschar :: nil)
     (tptr (Tunion __512 noattr)) cc_default)) ::
 (_gMatStackIndex, Gvar v_gMatStackIndex) ::
 (_gMatStack, Gvar v_gMatStack) ::
 (_gMatStackFixed, Gvar v_gMatStackFixed) ::
 (_gGeoTempState, Gvar v_gGeoTempState) ::
 (_gCurrAnimType, Gvar v_gCurrAnimType) ::
 (_gCurrAnimEnabled, Gvar v_gCurrAnimEnabled) ::
 (_gCurrAnimFrame, Gvar v_gCurrAnimFrame) ::
 (_gCurrAnimTranslationMultiplier, Gvar v_gCurrAnimTranslationMultiplier) ::
 (_gCurrAnimAttribute, Gvar v_gCurrAnimAttribute) ::
 (_gCurrAnimData, Gvar v_gCurrAnimData) ::
 (_gDisplayListHeap, Gvar v_gDisplayListHeap) ::
 (_renderModeTable_1Cycle, Gvar v_renderModeTable_1Cycle) ::
 (_renderModeTable_2Cycle, Gvar v_renderModeTable_2Cycle) ::
 (_gCurGraphNodeRoot, Gvar v_gCurGraphNodeRoot) ::
 (_gCurGraphNodeMasterList, Gvar v_gCurGraphNodeMasterList) ::
 (_gCurGraphNodeCamFrustum, Gvar v_gCurGraphNodeCamFrustum) ::
 (_gCurGraphNodeCamera, Gvar v_gCurGraphNodeCamera) ::
 (_gCurGraphNodeObject, Gvar v_gCurGraphNodeObject) ::
 (_gCurGraphNodeHeldObject, Gvar v_gCurGraphNodeHeldObject) ::
 (_gAreaUpdateCounter, Gvar v_gAreaUpdateCounter) ::
 (_geo_process_master_list_sub, Gfun(Internal f_geo_process_master_list_sub)) ::
 (_geo_append_display_list, Gfun(Internal f_geo_append_display_list)) ::
 (_geo_process_master_list, Gfun(Internal f_geo_process_master_list)) ::
 (_geo_process_ortho_projection, Gfun(Internal f_geo_process_ortho_projection)) ::
 (_geo_process_perspective, Gfun(Internal f_geo_process_perspective)) ::
 (_geo_process_level_of_detail, Gfun(Internal f_geo_process_level_of_detail)) ::
 (_geo_process_switch, Gfun(Internal f_geo_process_switch)) ::
 (_geo_process_camera, Gfun(Internal f_geo_process_camera)) ::
 (_geo_process_translation_rotation, Gfun(Internal f_geo_process_translation_rotation)) ::
 (_geo_process_translation, Gfun(Internal f_geo_process_translation)) ::
 (_geo_process_rotation, Gfun(Internal f_geo_process_rotation)) ::
 (_geo_process_scale, Gfun(Internal f_geo_process_scale)) ::
 (_geo_process_billboard, Gfun(Internal f_geo_process_billboard)) ::
 (_geo_process_display_list, Gfun(Internal f_geo_process_display_list)) ::
 (_geo_process_generated_list, Gfun(Internal f_geo_process_generated_list)) ::
 (_geo_process_background, Gfun(Internal f_geo_process_background)) ::
 (_geo_process_animated_part, Gfun(Internal f_geo_process_animated_part)) ::
 (_geo_set_animation_globals, Gfun(Internal f_geo_set_animation_globals)) ::
 (_geo_process_shadow, Gfun(Internal f_geo_process_shadow)) ::
 (_obj_is_in_view, Gfun(Internal f_obj_is_in_view)) ::
 (_geo_process_object, Gfun(Internal f_geo_process_object)) ::
 (_geo_process_object_parent, Gfun(Internal f_geo_process_object_parent)) ::
 (_geo_process_held_object, Gfun(Internal f_geo_process_held_object)) ::
 (_geo_try_process_children, Gfun(Internal f_geo_try_process_children)) ::
 (_geo_process_node_and_siblings, Gfun(Internal f_geo_process_node_and_siblings)) ::
 (_geo_process_root, Gfun(Internal f_geo_process_root)) :: nil).

Definition public_idents : list ident :=
(_geo_process_root :: _geo_process_node_and_siblings ::
 _geo_try_process_children :: _geo_process_held_object ::
 _geo_set_animation_globals :: _gAreaUpdateCounter ::
 _gCurGraphNodeHeldObject :: _gCurGraphNodeObject :: _gCurGraphNodeCamera ::
 _gCurGraphNodeCamFrustum :: _gCurGraphNodeMasterList ::
 _gCurGraphNodeRoot :: _renderModeTable_2Cycle :: _renderModeTable_1Cycle ::
 _gDisplayListHeap :: _gCurrAnimData :: _gCurrAnimAttribute ::
 _gCurrAnimTranslationMultiplier :: _gCurrAnimFrame :: _gCurrAnimEnabled ::
 _gCurrAnimType :: _gGeoTempState :: _gMatStackFixed :: _gMatStack ::
 _gMatStackIndex :: _create_shadow_below_xyz :: _gMarioOnIceOrCarpet ::
 _gShadowAboveWaterOrLava :: _print_text_fmt_int :: _gShowDebugText ::
 _make_viewport_clip_rect :: _clear_framebuffer :: _gDisplayListHead ::
 _get_pos_from_transform_mtx :: _mtxf_rotate_xy :: _mtxf_to_mtx ::
 _mtxf_scale_vec3f :: _mtxf_mul :: _mtxf_billboard ::
 _mtxf_rotate_xyz_and_translate :: _mtxf_rotate_zxy_and_translate ::
 _mtxf_lookat :: _mtxf_translate :: _mtxf_identity :: _mtxf_copy ::
 _vec3s_to_vec3f :: _vec3s_set :: _vec3s_copy :: _vec3f_set :: _vec3f_copy ::
 _gSineTable :: _geo_update_animation_frame :: _retrieve_animation_index ::
 _gVec3sZero :: _gVec3fZero :: _alloc_display_list ::
 _alloc_only_pool_alloc :: _alloc_only_pool_init :: _main_pool_available ::
 _main_pool_free :: _segmented_to_virtual :: _guOrtho :: _guPerspective ::
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


