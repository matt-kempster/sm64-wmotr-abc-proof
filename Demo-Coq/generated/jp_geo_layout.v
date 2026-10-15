(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_JP
   Source:          src/engine/geo_layout.c
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_JP=1 -DF3D_OLD=1
   Link hygiene:    private globals scoped by translation unit geo_layout
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
  Definition source_file := "build/pinned-sm64/src/engine/geo_layout.c".
  Definition normalized := true.
End Info.

Definition _AllocOnlyPool : ident := $"AllocOnlyPool".
Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _Camera : ident := $"Camera".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _D_8038BCA8 : ident := $"D_8038BCA8".
Definition _D_8038BD7C : ident := $"D_8038BD7C".
Definition _DisplayListNode : ident := $"DisplayListNode".
Definition _FnGraphNode : ident := $"FnGraphNode".
Definition _GeoLayoutJumpTable : ident := $"GeoLayoutJumpTable".
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
Definition _GraphNodeStart : ident := $"GraphNodeStart".
Definition _GraphNodeSwitchCase : ident := $"GraphNodeSwitchCase".
Definition _GraphNodeTranslation : ident := $"GraphNodeTranslation".
Definition _GraphNodeTranslationRotation : ident := $"GraphNodeTranslationRotation".
Definition _Object : ident := $"Object".
Definition _ObjectNode : ident := $"ObjectNode".
Definition _SpawnInfo : ident := $"SpawnInfo".
Definition _Surface : ident := $"Surface".
Definition _Waypoint : ident := $"Waypoint".
Definition __1299 : ident := $"_1299".
Definition __472 : ident := $"_472".
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
Definition _alloc_only_pool_alloc : ident := $"alloc_only_pool_alloc".
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
Definition _background : ident := $"background".
Definition _behavior : ident := $"behavior".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _camera : ident := $"camera".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _children : ident := $"children".
Definition _cmdPos : ident := $"cmdPos".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _config : ident := $"config".
Definition _cullingRadius : ident := $"cullingRadius".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _displayList : ident := $"displayList".
Definition _drawingLayer : ident := $"drawingLayer".
Definition _far : ident := $"far".
Definition _filler : ident := $"filler".
Definition _flagBits : ident := $"flagBits".
Definition _flags : ident := $"flags".
Definition _fnNode : ident := $"fnNode".
Definition _focus : ident := $"focus".
Definition _force : ident := $"force".
Definition _force_structure_alignment : ident := $"force_structure_alignment".
Definition _fov : ident := $"fov".
Definition _freePtr : ident := $"freePtr".
Definition _frustumFunc : ident := $"frustumFunc".
Definition _func : ident := $"func".
Definition _gCurGraphNodeIndex : ident := $"gCurGraphNodeIndex".
Definition _gCurGraphNodeList : ident := $"gCurGraphNodeList".
Definition _gCurRootGraphNode : ident := $"gCurRootGraphNode".
Definition _gGeoLayoutCommand : ident := $"gGeoLayoutCommand".
Definition _gGeoLayoutReturnIndex : ident := $"gGeoLayoutReturnIndex".
Definition _gGeoLayoutStack : ident := $"gGeoLayoutStack".
Definition _gGeoLayoutStackIndex : ident := $"gGeoLayoutStackIndex".
Definition _gGeoNumViews : ident := $"gGeoNumViews".
Definition _gGeoViews : ident := $"gGeoViews".
Definition _gGraphNodePool : ident := $"gGraphNodePool".
Definition _gObjParentGraphNode : ident := $"gObjParentGraphNode".
Definition _gVec3sZero : ident := $"gVec3sZero".
Definition _geo_layout_cmd_assign_as_view : ident := $"geo_layout_cmd_assign_as_view".
Definition _geo_layout_cmd_branch : ident := $"geo_layout_cmd_branch".
Definition _geo_layout_cmd_branch_and_link : ident := $"geo_layout_cmd_branch_and_link".
Definition _geo_layout_cmd_close_node : ident := $"geo_layout_cmd_close_node".
Definition _geo_layout_cmd_copy_view : ident := $"geo_layout_cmd_copy_view".
Definition _geo_layout_cmd_end : ident := $"geo_layout_cmd_end".
Definition _geo_layout_cmd_node_animated_part : ident := $"geo_layout_cmd_node_animated_part".
Definition _geo_layout_cmd_node_background : ident := $"geo_layout_cmd_node_background".
Definition _geo_layout_cmd_node_billboard : ident := $"geo_layout_cmd_node_billboard".
Definition _geo_layout_cmd_node_camera : ident := $"geo_layout_cmd_node_camera".
Definition _geo_layout_cmd_node_culling_radius : ident := $"geo_layout_cmd_node_culling_radius".
Definition _geo_layout_cmd_node_display_list : ident := $"geo_layout_cmd_node_display_list".
Definition _geo_layout_cmd_node_generated : ident := $"geo_layout_cmd_node_generated".
Definition _geo_layout_cmd_node_held_obj : ident := $"geo_layout_cmd_node_held_obj".
Definition _geo_layout_cmd_node_level_of_detail : ident := $"geo_layout_cmd_node_level_of_detail".
Definition _geo_layout_cmd_node_master_list : ident := $"geo_layout_cmd_node_master_list".
Definition _geo_layout_cmd_node_object_parent : ident := $"geo_layout_cmd_node_object_parent".
Definition _geo_layout_cmd_node_ortho_projection : ident := $"geo_layout_cmd_node_ortho_projection".
Definition _geo_layout_cmd_node_perspective : ident := $"geo_layout_cmd_node_perspective".
Definition _geo_layout_cmd_node_root : ident := $"geo_layout_cmd_node_root".
Definition _geo_layout_cmd_node_rotation : ident := $"geo_layout_cmd_node_rotation".
Definition _geo_layout_cmd_node_scale : ident := $"geo_layout_cmd_node_scale".
Definition _geo_layout_cmd_node_shadow : ident := $"geo_layout_cmd_node_shadow".
Definition _geo_layout_cmd_node_start : ident := $"geo_layout_cmd_node_start".
Definition _geo_layout_cmd_node_switch_case : ident := $"geo_layout_cmd_node_switch_case".
Definition _geo_layout_cmd_node_translation : ident := $"geo_layout_cmd_node_translation".
Definition _geo_layout_cmd_node_translation_rotation : ident := $"geo_layout_cmd_node_translation_rotation".
Definition _geo_layout_cmd_nop : ident := $"geo_layout_cmd_nop".
Definition _geo_layout_cmd_nop2 : ident := $"geo_layout_cmd_nop2".
Definition _geo_layout_cmd_nop3 : ident := $"geo_layout_cmd_nop3".
Definition _geo_layout_cmd_open_node : ident := $"geo_layout_cmd_open_node".
Definition _geo_layout_cmd_return : ident := $"geo_layout_cmd_return".
Definition _geo_layout_cmd_update_node_flags : ident := $"geo_layout_cmd_update_node_flags".
Definition _gfx : ident := $"gfx".
Definition _graphNode : ident := $"graphNode".
Definition _header : ident := $"header".
Definition _height : ident := $"height".
Definition _hitboxDownOffset : ident := $"hitboxDownOffset".
Definition _hitboxHeight : ident := $"hitboxHeight".
Definition _hitboxRadius : ident := $"hitboxRadius".
Definition _hurtboxHeight : ident := $"hurtboxHeight".
Definition _hurtboxRadius : ident := $"hurtboxRadius".
Definition _i : ident := $"i".
Definition _index : ident := $"index".
Definition _init_graph_node_animated_part : ident := $"init_graph_node_animated_part".
Definition _init_graph_node_background : ident := $"init_graph_node_background".
Definition _init_graph_node_billboard : ident := $"init_graph_node_billboard".
Definition _init_graph_node_camera : ident := $"init_graph_node_camera".
Definition _init_graph_node_culling_radius : ident := $"init_graph_node_culling_radius".
Definition _init_graph_node_display_list : ident := $"init_graph_node_display_list".
Definition _init_graph_node_generated : ident := $"init_graph_node_generated".
Definition _init_graph_node_held_object : ident := $"init_graph_node_held_object".
Definition _init_graph_node_master_list : ident := $"init_graph_node_master_list".
Definition _init_graph_node_object_parent : ident := $"init_graph_node_object_parent".
Definition _init_graph_node_ortho_projection : ident := $"init_graph_node_ortho_projection".
Definition _init_graph_node_perspective : ident := $"init_graph_node_perspective".
Definition _init_graph_node_render_range : ident := $"init_graph_node_render_range".
Definition _init_graph_node_root : ident := $"init_graph_node_root".
Definition _init_graph_node_rotation : ident := $"init_graph_node_rotation".
Definition _init_graph_node_scale : ident := $"init_graph_node_scale".
Definition _init_graph_node_shadow : ident := $"init_graph_node_shadow".
Definition _init_graph_node_start : ident := $"init_graph_node_start".
Definition _init_graph_node_switch_case : ident := $"init_graph_node_switch_case".
Definition _init_graph_node_translation : ident := $"init_graph_node_translation".
Definition _init_graph_node_translation_rotation : ident := $"init_graph_node_translation_rotation".
Definition _length : ident := $"length".
Definition _listHeads : ident := $"listHeads".
Definition _listTails : ident := $"listTails".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _m : ident := $"m".
Definition _main : ident := $"main".
Definition _matrixPtr : ident := $"matrixPtr".
Definition _maxDistance : ident := $"maxDistance".
Definition _minDistance : ident := $"minDistance".
Definition _mode : ident := $"mode".
Definition _near : ident := $"near".
Definition _next : ident := $"next".
Definition _node : ident := $"node".
Definition _normal : ident := $"normal".
Definition _numCases : ident := $"numCases".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _numViews : ident := $"numViews".
Definition _objNode : ident := $"objNode".
Definition _object : ident := $"object".
Definition _offset : ident := $"offset".
Definition _operation : ident := $"operation".
Definition _originOffset : ident := $"originOffset".
Definition _parameter : ident := $"parameter".
Definition _params : ident := $"params".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _platform : ident := $"platform".
Definition _playerIndex : ident := $"playerIndex".
Definition _pool : ident := $"pool".
Definition _pos : ident := $"pos".
Definition _prev : ident := $"prev".
Definition _prevObj : ident := $"prevObj".
Definition _process_geo_layout : ident := $"process_geo_layout".
Definition _rawData : ident := $"rawData".
Definition _read_vec3s : ident := $"read_vec3s".
Definition _read_vec3s_angle : ident := $"read_vec3s_angle".
Definition _read_vec3s_to_vec3f : ident := $"read_vec3s_to_vec3f".
Definition _register_scene_graph_node : ident := $"register_scene_graph_node".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _roll : ident := $"roll".
Definition _rollScreen : ident := $"rollScreen".
Definition _room : ident := $"room".
Definition _rotation : ident := $"rotation".
Definition _scale : ident := $"scale".
Definition _segmented_to_virtual : ident := $"segmented_to_virtual".
Definition _segptr : ident := $"segptr".
Definition _selectedCase : ident := $"selectedCase".
Definition _shadowScale : ident := $"shadowScale".
Definition _shadowSolidity : ident := $"shadowSolidity".
Definition _shadowType : ident := $"shadowType".
Definition _sharedChild : ident := $"sharedChild".
Definition _sp2c : ident := $"sp2c".
Definition _startFrame : ident := $"startFrame".
Definition _startPtr : ident := $"startPtr".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _totalSpace : ident := $"totalSpace".
Definition _transform : ident := $"transform".
Definition _translation : ident := $"translation".
Definition _type : ident := $"type".
Definition _unk15 : ident := $"unk15".
Definition _unk4C : ident := $"unk4C".
Definition _unused : ident := $"unused".
Definition _unused1 : ident := $"unused1".
Definition _unused2 : ident := $"unused2".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _unused_8038B894 : ident := $"unused_8038B894".
Definition _upperY : ident := $"upperY".
Definition _usedSpace : ident := $"usedSpace".
Definition _values : ident := $"values".
Definition _vec3s_copy : ident := $"vec3s_copy".
Definition _vec3s_set : ident := $"vec3s_set".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _views : ident := $"views".
Definition _w0 : ident := $"w0".
Definition _w1 : ident := $"w1".
Definition _width : ident := $"width".
Definition _words : ident := $"words".
Definition _x : ident := $"x".
Definition _y : ident := $"y".
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
Definition _t'3 : ident := 130%positive.
Definition _t'4 : ident := 131%positive.
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v_gVec3sZero := {|
  gvar_info := (tarray tshort 3);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_GeoLayoutJumpTable := {|
  gvar_info := (tarray (tptr (Tfunction nil tvoid cc_default)) 33);
  gvar_init := (Init_addrof _geo_layout_cmd_branch_and_link (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_end (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_branch (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_return (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_open_node (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_close_node (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_assign_as_view (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_update_node_flags (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_node_root (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_node_ortho_projection (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_node_perspective (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_node_start (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_node_master_list (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_node_level_of_detail (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_node_switch_case (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_node_camera (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_node_translation_rotation (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_node_translation (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_node_rotation (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_node_animated_part (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_node_billboard (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_node_display_list (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_node_shadow (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_node_object_parent (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_node_generated (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_node_background (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_nop (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_copy_view (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_node_held_obj (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_node_scale (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_nop2 (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_nop3 (Ptrofs.repr 0) ::
                Init_addrof _geo_layout_cmd_node_culling_radius (Ptrofs.repr 0) ::
                nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gObjParentGraphNode := {|
  gvar_info := (Tstruct _GraphNode noattr);
  gvar_init := (Init_space 20 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGraphNodePool := {|
  gvar_info := (tptr (Tstruct _AllocOnlyPool noattr));
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurRootGraphNode := {|
  gvar_info := (tptr (Tstruct _GraphNode noattr));
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_8038BCA8 := {|
  gvar_info := tint;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGeoViews := {|
  gvar_info := (tptr (tptr (Tstruct _GraphNode noattr)));
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGeoNumViews := {|
  gvar_info := tushort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGeoLayoutStack := {|
  gvar_info := (tarray tuint 16);
  gvar_init := (Init_space 64 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurGraphNodeList := {|
  gvar_info := (tarray (tptr (Tstruct _GraphNode noattr)) 32);
  gvar_init := (Init_space 128 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurGraphNodeIndex := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGeoLayoutStackIndex := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_8038BD7C := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGeoLayoutReturnIndex := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGeoLayoutCommand := {|
  gvar_info := (tptr tuchar);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_unused_8038B894 := {|
  gvar_info := (tarray tuint 3);
  gvar_init := (Init_int32 (Int.repr 0) :: Init_space 8 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_geo_layout_cmd_branch_and_link := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'3, (tptr tvoid)) :: (_t'2, tshort) :: (_t'1, tshort) ::
               (_t'9, (tptr tuchar)) :: (_t'8, tshort) :: (_t'7, tshort) ::
               (_t'6, tshort) :: (_t'5, (tptr tvoid)) ::
               (_t'4, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'1 (Evar _gGeoLayoutStackIndex tshort))
      (Sassign (Evar _gGeoLayoutStackIndex tshort)
        (Ebinop Oadd (Etempvar _t'1 tshort) (Econst_int (Int.repr 1) tint)
          tint)))
    (Ssequence
      (Sset _t'9 (Evar _gGeoLayoutCommand (tptr tuchar)))
      (Sassign
        (Ederef
          (Ebinop Oadd (Evar _gGeoLayoutStack (tarray tuint 16))
            (Etempvar _t'1 tshort) (tptr tuint)) tuint)
        (Ecast
          (Ebinop Oadd (Etempvar _t'9 (tptr tuchar))
            (Ebinop Oor
              (Ebinop Oand (Econst_int (Int.repr 8) tint)
                (Econst_int (Int.repr 3) tint) tint)
              (Ebinop Oshl
                (Ebinop Oand (Econst_int (Int.repr 8) tint)
                  (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) tint)
            (tptr tuchar)) tuint))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'2 (Evar _gGeoLayoutStackIndex tshort))
        (Sassign (Evar _gGeoLayoutStackIndex tshort)
          (Ebinop Oadd (Etempvar _t'2 tshort) (Econst_int (Int.repr 1) tint)
            tint)))
      (Ssequence
        (Sset _t'7 (Evar _gCurGraphNodeIndex tshort))
        (Ssequence
          (Sset _t'8 (Evar _gGeoLayoutReturnIndex tshort))
          (Sassign
            (Ederef
              (Ebinop Oadd (Evar _gGeoLayoutStack (tarray tuint 16))
                (Etempvar _t'2 tshort) (tptr tuint)) tuint)
            (Ebinop Oadd
              (Ebinop Oshl (Etempvar _t'7 tshort)
                (Econst_int (Int.repr 16) tint) tint) (Etempvar _t'8 tshort)
              tint)))))
    (Ssequence
      (Ssequence
        (Sset _t'6 (Evar _gGeoLayoutStackIndex tshort))
        (Sassign (Evar _gGeoLayoutReturnIndex tshort) (Etempvar _t'6 tshort)))
      (Ssequence
        (Ssequence
          (Sset _t'4 (Evar _gGeoLayoutCommand (tptr tuchar)))
          (Ssequence
            (Sset _t'5
              (Ederef
                (Ecast
                  (Ebinop Oadd (Etempvar _t'4 (tptr tuchar))
                    (Ebinop Oor
                      (Ebinop Oand (Econst_int (Int.repr 4) tint)
                        (Econst_int (Int.repr 3) tint) tint)
                      (Ebinop Oshl
                        (Ebinop Oand (Econst_int (Int.repr 4) tint)
                          (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                          tint)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                    (tptr tuchar)) (tptr (tptr tvoid))) (tptr tvoid)))
            (Scall (Some _t'3)
              (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                            (tptr tvoid) cc_default))
              ((Etempvar _t'5 (tptr tvoid)) :: nil))))
        (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
          (Etempvar _t'3 (tptr tvoid)))))))
|}.

Definition f_geo_layout_cmd_end := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, tshort) :: (_t'1, tshort) :: (_t'9, tshort) ::
               (_t'8, tshort) :: (_t'7, tuint) :: (_t'6, tuint) ::
               (_t'5, tshort) :: (_t'4, tshort) :: (_t'3, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9 (Evar _gGeoLayoutReturnIndex tshort))
    (Sassign (Evar _gGeoLayoutStackIndex tshort) (Etempvar _t'9 tshort)))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'8 (Evar _gGeoLayoutStackIndex tshort))
          (Sset _t'1
            (Ecast
              (Ebinop Osub (Etempvar _t'8 tshort)
                (Econst_int (Int.repr 1) tint) tint) tshort)))
        (Sassign (Evar _gGeoLayoutStackIndex tshort) (Etempvar _t'1 tshort)))
      (Ssequence
        (Sset _t'7
          (Ederef
            (Ebinop Oadd (Evar _gGeoLayoutStack (tarray tuint 16))
              (Etempvar _t'1 tshort) (tptr tuint)) tuint))
        (Sassign (Evar _gGeoLayoutReturnIndex tshort)
          (Ebinop Oand (Etempvar _t'7 tuint)
            (Econst_int (Int.repr 65535) tint) tuint))))
    (Ssequence
      (Ssequence
        (Sset _t'5 (Evar _gGeoLayoutStackIndex tshort))
        (Ssequence
          (Sset _t'6
            (Ederef
              (Ebinop Oadd (Evar _gGeoLayoutStack (tarray tuint 16))
                (Etempvar _t'5 tshort) (tptr tuint)) tuint))
          (Sassign (Evar _gCurGraphNodeIndex tshort)
            (Ebinop Oshr (Etempvar _t'6 tuint)
              (Econst_int (Int.repr 16) tint) tuint))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'4 (Evar _gGeoLayoutStackIndex tshort))
            (Sset _t'2
              (Ecast
                (Ebinop Osub (Etempvar _t'4 tshort)
                  (Econst_int (Int.repr 1) tint) tint) tshort)))
          (Sassign (Evar _gGeoLayoutStackIndex tshort)
            (Etempvar _t'2 tshort)))
        (Ssequence
          (Sset _t'3
            (Ederef
              (Ebinop Oadd (Evar _gGeoLayoutStack (tarray tuint 16))
                (Etempvar _t'2 tshort) (tptr tuint)) tuint))
          (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
            (Ecast (Etempvar _t'3 tuint) (tptr tuchar))))))))
|}.

Definition f_geo_layout_cmd_branch := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, (tptr tvoid)) :: (_t'1, tshort) ::
               (_t'7, (tptr tuchar)) :: (_t'6, tuchar) ::
               (_t'5, (tptr tuchar)) :: (_t'4, (tptr tvoid)) ::
               (_t'3, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5 (Evar _gGeoLayoutCommand (tptr tuchar)))
    (Ssequence
      (Sset _t'6
        (Ederef
          (Ebinop Oadd (Etempvar _t'5 (tptr tuchar))
            (Ebinop Oor
              (Ebinop Oand (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 3) tint) tint)
              (Ebinop Oshl
                (Ebinop Oand (Econst_int (Int.repr 1) tint)
                  (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) tint)
            (tptr tuchar)) tuchar))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'6 tuchar)
                     (Econst_int (Int.repr 1) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'1 (Evar _gGeoLayoutStackIndex tshort))
            (Sassign (Evar _gGeoLayoutStackIndex tshort)
              (Ebinop Oadd (Etempvar _t'1 tshort)
                (Econst_int (Int.repr 1) tint) tint)))
          (Ssequence
            (Sset _t'7 (Evar _gGeoLayoutCommand (tptr tuchar)))
            (Sassign
              (Ederef
                (Ebinop Oadd (Evar _gGeoLayoutStack (tarray tuint 16))
                  (Etempvar _t'1 tshort) (tptr tuint)) tuint)
              (Ecast
                (Ebinop Oadd (Etempvar _t'7 (tptr tuchar))
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 8) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 8) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (tptr tuchar)) tuint))))
        Sskip)))
  (Ssequence
    (Ssequence
      (Sset _t'3 (Evar _gGeoLayoutCommand (tptr tuchar)))
      (Ssequence
        (Sset _t'4
          (Ederef
            (Ecast
              (Ebinop Oadd (Etempvar _t'3 (tptr tuchar))
                (Ebinop Oor
                  (Ebinop Oand (Econst_int (Int.repr 4) tint)
                    (Econst_int (Int.repr 3) tint) tint)
                  (Ebinop Oshl
                    (Ebinop Oand (Econst_int (Int.repr 4) tint)
                      (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                      tint)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                (tptr tuchar)) (tptr (tptr tvoid))) (tptr tvoid)))
        (Scall (Some _t'2)
          (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                        (tptr tvoid) cc_default))
          ((Etempvar _t'4 (tptr tvoid)) :: nil))))
    (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
      (Etempvar _t'2 (tptr tvoid)))))
|}.

Definition f_geo_layout_cmd_return := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tshort) :: (_t'3, tshort) :: (_t'2, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'3 (Evar _gGeoLayoutStackIndex tshort))
      (Sset _t'1
        (Ecast
          (Ebinop Osub (Etempvar _t'3 tshort) (Econst_int (Int.repr 1) tint)
            tint) tshort)))
    (Sassign (Evar _gGeoLayoutStackIndex tshort) (Etempvar _t'1 tshort)))
  (Ssequence
    (Sset _t'2
      (Ederef
        (Ebinop Oadd (Evar _gGeoLayoutStack (tarray tuint 16))
          (Etempvar _t'1 tshort) (tptr tuint)) tuint))
    (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
      (Ecast (Etempvar _t'2 tuint) (tptr tuchar)))))
|}.

Definition f_geo_layout_cmd_open_node := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'5, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'4, tshort) :: (_t'3, tshort) :: (_t'2, tshort) ::
               (_t'1, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3 (Evar _gCurGraphNodeIndex tshort))
    (Ssequence
      (Sset _t'4 (Evar _gCurGraphNodeIndex tshort))
      (Ssequence
        (Sset _t'5
          (Ederef
            (Ebinop Oadd
              (Evar _gCurGraphNodeList (tarray (tptr (Tstruct _GraphNode noattr)) 32))
              (Etempvar _t'4 tshort)
              (tptr (tptr (Tstruct _GraphNode noattr))))
            (tptr (Tstruct _GraphNode noattr))))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Evar _gCurGraphNodeList (tarray (tptr (Tstruct _GraphNode noattr)) 32))
              (Ebinop Oadd (Etempvar _t'3 tshort)
                (Econst_int (Int.repr 1) tint) tint)
              (tptr (tptr (Tstruct _GraphNode noattr))))
            (tptr (Tstruct _GraphNode noattr)))
          (Etempvar _t'5 (tptr (Tstruct _GraphNode noattr)))))))
  (Ssequence
    (Ssequence
      (Sset _t'2 (Evar _gCurGraphNodeIndex tshort))
      (Sassign (Evar _gCurGraphNodeIndex tshort)
        (Ebinop Oadd (Etempvar _t'2 tshort) (Econst_int (Int.repr 1) tint)
          tint)))
    (Ssequence
      (Sset _t'1 (Evar _gGeoLayoutCommand (tptr tuchar)))
      (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
        (Ebinop Oadd (Etempvar _t'1 (tptr tuchar))
          (Ebinop Oshl (Econst_int (Int.repr 4) tint)
            (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
              (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))))))
|}.

Definition f_geo_layout_cmd_close_node := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, tshort) :: (_t'1, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2 (Evar _gCurGraphNodeIndex tshort))
    (Sassign (Evar _gCurGraphNodeIndex tshort)
      (Ebinop Osub (Etempvar _t'2 tshort) (Econst_int (Int.repr 1) tint)
        tint)))
  (Ssequence
    (Sset _t'1 (Evar _gGeoLayoutCommand (tptr tuchar)))
    (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
      (Ebinop Oadd (Etempvar _t'1 (tptr tuchar))
        (Ebinop Oshl (Econst_int (Int.repr 4) tint)
          (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
            (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar)))))
|}.

Definition f_geo_layout_cmd_assign_as_view := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_index, tushort) :: (_t'7, tshort) ::
               (_t'6, (tptr tuchar)) ::
               (_t'5, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'4, tshort) ::
               (_t'3, (tptr (tptr (Tstruct _GraphNode noattr)))) ::
               (_t'2, tushort) :: (_t'1, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6 (Evar _gGeoLayoutCommand (tptr tuchar)))
    (Ssequence
      (Sset _t'7
        (Ederef
          (Ecast
            (Ebinop Oadd (Etempvar _t'6 (tptr tuchar))
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (tptr tuchar)) (tptr tshort)) tshort))
      (Sset _index (Ecast (Etempvar _t'7 tshort) tushort))))
  (Ssequence
    (Ssequence
      (Sset _t'2 (Evar _gGeoNumViews tushort))
      (Sifthenelse (Ebinop Olt (Etempvar _index tushort)
                     (Etempvar _t'2 tushort) tint)
        (Ssequence
          (Sset _t'3
            (Evar _gGeoViews (tptr (tptr (Tstruct _GraphNode noattr)))))
          (Ssequence
            (Sset _t'4 (Evar _gCurGraphNodeIndex tshort))
            (Ssequence
              (Sset _t'5
                (Ederef
                  (Ebinop Oadd
                    (Evar _gCurGraphNodeList (tarray (tptr (Tstruct _GraphNode noattr)) 32))
                    (Etempvar _t'4 tshort)
                    (tptr (tptr (Tstruct _GraphNode noattr))))
                  (tptr (Tstruct _GraphNode noattr))))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Etempvar _t'3 (tptr (tptr (Tstruct _GraphNode noattr))))
                    (Etempvar _index tushort)
                    (tptr (tptr (Tstruct _GraphNode noattr))))
                  (tptr (Tstruct _GraphNode noattr)))
                (Etempvar _t'5 (tptr (Tstruct _GraphNode noattr)))))))
        Sskip))
    (Ssequence
      (Sset _t'1 (Evar _gGeoLayoutCommand (tptr tuchar)))
      (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
        (Ebinop Oadd (Etempvar _t'1 (tptr tuchar))
          (Ebinop Oshl (Econst_int (Int.repr 4) tint)
            (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
              (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))))))
|}.

Definition f_geo_layout_cmd_update_node_flags := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_operation, tushort) :: (_flagBits, tushort) ::
               (_t'17, tuchar) :: (_t'16, (tptr tuchar)) ::
               (_t'15, tshort) :: (_t'14, (tptr tuchar)) ::
               (_t'13, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'12, tshort) :: (_t'11, tshort) ::
               (_t'10, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'9, tshort) ::
               (_t'8, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'7, tshort) :: (_t'6, tshort) ::
               (_t'5, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'4, tshort) ::
               (_t'3, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'2, tshort) :: (_t'1, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'16 (Evar _gGeoLayoutCommand (tptr tuchar)))
    (Ssequence
      (Sset _t'17
        (Ederef
          (Ebinop Oadd (Etempvar _t'16 (tptr tuchar))
            (Ebinop Oor
              (Ebinop Oand (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 3) tint) tint)
              (Ebinop Oshl
                (Ebinop Oand (Econst_int (Int.repr 1) tint)
                  (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) tint)
            (tptr tuchar)) tuchar))
      (Sset _operation (Ecast (Etempvar _t'17 tuchar) tushort))))
  (Ssequence
    (Ssequence
      (Sset _t'14 (Evar _gGeoLayoutCommand (tptr tuchar)))
      (Ssequence
        (Sset _t'15
          (Ederef
            (Ecast
              (Ebinop Oadd (Etempvar _t'14 (tptr tuchar))
                (Ebinop Oor
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Econst_int (Int.repr 3) tint) tint)
                  (Ebinop Oshl
                    (Ebinop Oand (Econst_int (Int.repr 2) tint)
                      (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                      tint)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                (tptr tuchar)) (tptr tshort)) tshort))
        (Sset _flagBits (Ecast (Etempvar _t'15 tshort) tushort))))
    (Ssequence
      (Sswitch (Etempvar _operation tushort)
        (LScons (Some 0)
          (Ssequence
            (Ssequence
              (Sset _t'12 (Evar _gCurGraphNodeIndex tshort))
              (Ssequence
                (Sset _t'13
                  (Ederef
                    (Ebinop Oadd
                      (Evar _gCurGraphNodeList (tarray (tptr (Tstruct _GraphNode noattr)) 32))
                      (Etempvar _t'12 tshort)
                      (tptr (tptr (Tstruct _GraphNode noattr))))
                    (tptr (Tstruct _GraphNode noattr))))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _t'13 (tptr (Tstruct _GraphNode noattr)))
                      (Tstruct _GraphNode noattr)) _flags tshort)
                  (Etempvar _flagBits tushort))))
            Sbreak)
          (LScons (Some 1)
            (Ssequence
              (Ssequence
                (Sset _t'7 (Evar _gCurGraphNodeIndex tshort))
                (Ssequence
                  (Sset _t'8
                    (Ederef
                      (Ebinop Oadd
                        (Evar _gCurGraphNodeList (tarray (tptr (Tstruct _GraphNode noattr)) 32))
                        (Etempvar _t'7 tshort)
                        (tptr (tptr (Tstruct _GraphNode noattr))))
                      (tptr (Tstruct _GraphNode noattr))))
                  (Ssequence
                    (Sset _t'9 (Evar _gCurGraphNodeIndex tshort))
                    (Ssequence
                      (Sset _t'10
                        (Ederef
                          (Ebinop Oadd
                            (Evar _gCurGraphNodeList (tarray (tptr (Tstruct _GraphNode noattr)) 32))
                            (Etempvar _t'9 tshort)
                            (tptr (tptr (Tstruct _GraphNode noattr))))
                          (tptr (Tstruct _GraphNode noattr))))
                      (Ssequence
                        (Sset _t'11
                          (Efield
                            (Ederef
                              (Etempvar _t'10 (tptr (Tstruct _GraphNode noattr)))
                              (Tstruct _GraphNode noattr)) _flags tshort))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _t'8 (tptr (Tstruct _GraphNode noattr)))
                              (Tstruct _GraphNode noattr)) _flags tshort)
                          (Ebinop Oor (Etempvar _t'11 tshort)
                            (Etempvar _flagBits tushort) tint)))))))
              Sbreak)
            (LScons (Some 2)
              (Ssequence
                (Ssequence
                  (Sset _t'2 (Evar _gCurGraphNodeIndex tshort))
                  (Ssequence
                    (Sset _t'3
                      (Ederef
                        (Ebinop Oadd
                          (Evar _gCurGraphNodeList (tarray (tptr (Tstruct _GraphNode noattr)) 32))
                          (Etempvar _t'2 tshort)
                          (tptr (tptr (Tstruct _GraphNode noattr))))
                        (tptr (Tstruct _GraphNode noattr))))
                    (Ssequence
                      (Sset _t'4 (Evar _gCurGraphNodeIndex tshort))
                      (Ssequence
                        (Sset _t'5
                          (Ederef
                            (Ebinop Oadd
                              (Evar _gCurGraphNodeList (tarray (tptr (Tstruct _GraphNode noattr)) 32))
                              (Etempvar _t'4 tshort)
                              (tptr (tptr (Tstruct _GraphNode noattr))))
                            (tptr (Tstruct _GraphNode noattr))))
                        (Ssequence
                          (Sset _t'6
                            (Efield
                              (Ederef
                                (Etempvar _t'5 (tptr (Tstruct _GraphNode noattr)))
                                (Tstruct _GraphNode noattr)) _flags tshort))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _t'3 (tptr (Tstruct _GraphNode noattr)))
                                (Tstruct _GraphNode noattr)) _flags tshort)
                            (Ebinop Oand (Etempvar _t'6 tshort)
                              (Eunop Onotint (Etempvar _flagBits tushort)
                                tint) tint)))))))
                Sbreak)
              LSnil))))
      (Ssequence
        (Sset _t'1 (Evar _gGeoLayoutCommand (tptr tuchar)))
        (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
          (Ebinop Oadd (Etempvar _t'1 (tptr tuchar))
            (Ebinop Oshl (Econst_int (Int.repr 4) tint)
              (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar)))))))
|}.

Definition f_geo_layout_cmd_node_root := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_i, tint) ::
               (_graphNode, (tptr (Tstruct _GraphNodeRoot noattr))) ::
               (_x, tshort) :: (_y, tshort) :: (_width, tshort) ::
               (_height, tshort) :: (_t'2, (tptr tvoid)) ::
               (_t'1, (tptr (Tstruct _GraphNodeRoot noattr))) ::
               (_t'20, tshort) :: (_t'19, (tptr tuchar)) ::
               (_t'18, tshort) :: (_t'17, (tptr tuchar)) ::
               (_t'16, tshort) :: (_t'15, (tptr tuchar)) ::
               (_t'14, tshort) :: (_t'13, (tptr tuchar)) ::
               (_t'12, tshort) :: (_t'11, (tptr tuchar)) ::
               (_t'10, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'9, tushort) ::
               (_t'8, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'7, (tptr (tptr (Tstruct _GraphNode noattr)))) ::
               (_t'6, tushort) :: (_t'5, tushort) ::
               (_t'4, (tptr (tptr (Tstruct _GraphNode noattr)))) ::
               (_t'3, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'19 (Evar _gGeoLayoutCommand (tptr tuchar)))
    (Ssequence
      (Sset _t'20
        (Ederef
          (Ecast
            (Ebinop Oadd (Etempvar _t'19 (tptr tuchar))
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 4) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 4) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (tptr tuchar)) (tptr tshort)) tshort))
      (Sset _x (Ecast (Etempvar _t'20 tshort) tshort))))
  (Ssequence
    (Ssequence
      (Sset _t'17 (Evar _gGeoLayoutCommand (tptr tuchar)))
      (Ssequence
        (Sset _t'18
          (Ederef
            (Ecast
              (Ebinop Oadd (Etempvar _t'17 (tptr tuchar))
                (Ebinop Oor
                  (Ebinop Oand (Econst_int (Int.repr 6) tint)
                    (Econst_int (Int.repr 3) tint) tint)
                  (Ebinop Oshl
                    (Ebinop Oand (Econst_int (Int.repr 6) tint)
                      (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                      tint)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                (tptr tuchar)) (tptr tshort)) tshort))
        (Sset _y (Ecast (Etempvar _t'18 tshort) tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'15 (Evar _gGeoLayoutCommand (tptr tuchar)))
        (Ssequence
          (Sset _t'16
            (Ederef
              (Ecast
                (Ebinop Oadd (Etempvar _t'15 (tptr tuchar))
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 8) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 8) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (tptr tuchar)) (tptr tshort)) tshort))
          (Sset _width (Ecast (Etempvar _t'16 tshort) tshort))))
      (Ssequence
        (Ssequence
          (Sset _t'13 (Evar _gGeoLayoutCommand (tptr tuchar)))
          (Ssequence
            (Sset _t'14
              (Ederef
                (Ecast
                  (Ebinop Oadd (Etempvar _t'13 (tptr tuchar))
                    (Ebinop Oor
                      (Ebinop Oand (Econst_int (Int.repr 10) tint)
                        (Econst_int (Int.repr 3) tint) tint)
                      (Ebinop Oshl
                        (Ebinop Oand (Econst_int (Int.repr 10) tint)
                          (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                          tint)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                    (tptr tuchar)) (tptr tshort)) tshort))
            (Sset _height (Ecast (Etempvar _t'14 tshort) tshort))))
        (Ssequence
          (Ssequence
            (Sset _t'11 (Evar _gGeoLayoutCommand (tptr tuchar)))
            (Ssequence
              (Sset _t'12
                (Ederef
                  (Ecast
                    (Ebinop Oadd (Etempvar _t'11 (tptr tuchar))
                      (Ebinop Oor
                        (Ebinop Oand (Econst_int (Int.repr 2) tint)
                          (Econst_int (Int.repr 3) tint) tint)
                        (Ebinop Oshl
                          (Ebinop Oand (Econst_int (Int.repr 2) tint)
                            (Eunop Onotint (Econst_int (Int.repr 3) tint)
                              tint) tint)
                          (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                            (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                      (tptr tuchar)) (tptr tshort)) tshort))
              (Sassign (Evar _gGeoNumViews tushort)
                (Ebinop Oadd (Etempvar _t'12 tshort)
                  (Econst_int (Int.repr 2) tint) tint))))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'10
                  (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr))))
                (Scall (Some _t'1)
                  (Evar _init_graph_node_root (Tfunction
                                                ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                 (tptr (Tstruct _GraphNodeRoot noattr)) ::
                                                 tshort :: tshort ::
                                                 tshort :: tshort ::
                                                 tshort :: nil)
                                                (tptr (Tstruct _GraphNodeRoot noattr))
                                                cc_default))
                  ((Etempvar _t'10 (tptr (Tstruct _AllocOnlyPool noattr))) ::
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
                   (Econst_int (Int.repr 0) tint) :: (Etempvar _x tshort) ::
                   (Etempvar _y tshort) :: (Etempvar _width tshort) ::
                   (Etempvar _height tshort) :: nil)))
              (Sset _graphNode
                (Etempvar _t'1 (tptr (Tstruct _GraphNodeRoot noattr)))))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'8
                    (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr))))
                  (Ssequence
                    (Sset _t'9 (Evar _gGeoNumViews tushort))
                    (Scall (Some _t'2)
                      (Evar _alloc_only_pool_alloc (Tfunction
                                                     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                      tint :: nil)
                                                     (tptr tvoid) cc_default))
                      ((Etempvar _t'8 (tptr (Tstruct _AllocOnlyPool noattr))) ::
                       (Ebinop Omul (Etempvar _t'9 tushort)
                         (Esizeof (tptr (Tstruct _GraphNode noattr)) tuint)
                         tuint) :: nil))))
                (Sassign
                  (Evar _gGeoViews (tptr (tptr (Tstruct _GraphNode noattr))))
                  (Etempvar _t'2 (tptr tvoid))))
              (Ssequence
                (Ssequence
                  (Sset _t'7
                    (Evar _gGeoViews (tptr (tptr (Tstruct _GraphNode noattr)))))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _graphNode (tptr (Tstruct _GraphNodeRoot noattr)))
                        (Tstruct _GraphNodeRoot noattr)) _views
                      (tptr (tptr (Tstruct _GraphNode noattr))))
                    (Etempvar _t'7 (tptr (tptr (Tstruct _GraphNode noattr))))))
                (Ssequence
                  (Ssequence
                    (Sset _t'6 (Evar _gGeoNumViews tushort))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _graphNode (tptr (Tstruct _GraphNodeRoot noattr)))
                          (Tstruct _GraphNodeRoot noattr)) _numViews tshort)
                      (Etempvar _t'6 tushort)))
                  (Ssequence
                    (Ssequence
                      (Sset _i (Econst_int (Int.repr 0) tint))
                      (Sloop
                        (Ssequence
                          (Ssequence
                            (Sset _t'5 (Evar _gGeoNumViews tushort))
                            (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                                           (Etempvar _t'5 tushort) tint)
                              Sskip
                              Sbreak))
                          (Ssequence
                            (Sset _t'4
                              (Evar _gGeoViews (tptr (tptr (Tstruct _GraphNode noattr)))))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Etempvar _t'4 (tptr (tptr (Tstruct _GraphNode noattr))))
                                  (Etempvar _i tint)
                                  (tptr (tptr (Tstruct _GraphNode noattr))))
                                (tptr (Tstruct _GraphNode noattr)))
                              (Ecast (Econst_int (Int.repr 0) tint)
                                (tptr tvoid)))))
                        (Sset _i
                          (Ebinop Oadd (Etempvar _i tint)
                            (Econst_int (Int.repr 1) tint) tint))))
                    (Ssequence
                      (Scall None
                        (Evar _register_scene_graph_node (Tfunction
                                                           ((tptr (Tstruct _GraphNode noattr)) ::
                                                            nil) tvoid
                                                           cc_default))
                        ((Eaddrof
                           (Efield
                             (Ederef
                               (Etempvar _graphNode (tptr (Tstruct _GraphNodeRoot noattr)))
                               (Tstruct _GraphNodeRoot noattr)) _node
                             (Tstruct _GraphNode noattr))
                           (tptr (Tstruct _GraphNode noattr))) :: nil))
                      (Ssequence
                        (Sset _t'3 (Evar _gGeoLayoutCommand (tptr tuchar)))
                        (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
                          (Ebinop Oadd (Etempvar _t'3 (tptr tuchar))
                            (Ebinop Oshl (Econst_int (Int.repr 12) tint)
                              (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                (Econst_int (Int.repr 3) tint) tuint) tint)
                            (tptr tuchar)))))))))))))))
|}.

Definition f_geo_layout_cmd_node_ortho_projection := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_graphNode,
                (tptr (Tstruct _GraphNodeOrthoProjection noattr))) ::
               (_scale, tfloat) ::
               (_t'1, (tptr (Tstruct _GraphNodeOrthoProjection noattr))) ::
               (_t'5, tshort) :: (_t'4, (tptr tuchar)) ::
               (_t'3, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'2, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _gGeoLayoutCommand (tptr tuchar)))
    (Ssequence
      (Sset _t'5
        (Ederef
          (Ecast
            (Ebinop Oadd (Etempvar _t'4 (tptr tuchar))
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (tptr tuchar)) (tptr tshort)) tshort))
      (Sset _scale
        (Ebinop Odiv (Ecast (Etempvar _t'5 tshort) tfloat)
          (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
          tfloat))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr))))
        (Scall (Some _t'1)
          (Evar _init_graph_node_ortho_projection (Tfunction
                                                    ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                     (tptr (Tstruct _GraphNodeOrthoProjection noattr)) ::
                                                     tfloat :: nil)
                                                    (tptr (Tstruct _GraphNodeOrthoProjection noattr))
                                                    cc_default))
          ((Etempvar _t'3 (tptr (Tstruct _AllocOnlyPool noattr))) ::
           (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
           (Etempvar _scale tfloat) :: nil)))
      (Sset _graphNode
        (Etempvar _t'1 (tptr (Tstruct _GraphNodeOrthoProjection noattr)))))
    (Ssequence
      (Scall None
        (Evar _register_scene_graph_node (Tfunction
                                           ((tptr (Tstruct _GraphNode noattr)) ::
                                            nil) tvoid cc_default))
        ((Eaddrof
           (Efield
             (Ederef
               (Etempvar _graphNode (tptr (Tstruct _GraphNodeOrthoProjection noattr)))
               (Tstruct _GraphNodeOrthoProjection noattr)) _node
             (Tstruct _GraphNode noattr)) (tptr (Tstruct _GraphNode noattr))) ::
         nil))
      (Ssequence
        (Sset _t'2 (Evar _gGeoLayoutCommand (tptr tuchar)))
        (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
          (Ebinop Oadd (Etempvar _t'2 (tptr tuchar))
            (Ebinop Oshl (Econst_int (Int.repr 4) tint)
              (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar)))))))
|}.

Definition f_geo_layout_cmd_node_perspective := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_graphNode, (tptr (Tstruct _GraphNodePerspective noattr))) ::
               (_frustumFunc,
                (tptr (Tfunction
                        (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                         (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                        cc_default))) :: (_fov, tshort) :: (_near, tshort) ::
               (_far, tshort) ::
               (_t'1, (tptr (Tstruct _GraphNodePerspective noattr))) ::
               (_t'14, tshort) :: (_t'13, (tptr tuchar)) ::
               (_t'12, tshort) :: (_t'11, (tptr tuchar)) ::
               (_t'10, tshort) :: (_t'9, (tptr tuchar)) ::
               (_t'8, (tptr tvoid)) :: (_t'7, (tptr tuchar)) ::
               (_t'6, (tptr tuchar)) :: (_t'5, tuchar) ::
               (_t'4, (tptr tuchar)) ::
               (_t'3, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'2, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Sset _frustumFunc (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Ssequence
      (Sset _t'13 (Evar _gGeoLayoutCommand (tptr tuchar)))
      (Ssequence
        (Sset _t'14
          (Ederef
            (Ecast
              (Ebinop Oadd (Etempvar _t'13 (tptr tuchar))
                (Ebinop Oor
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Econst_int (Int.repr 3) tint) tint)
                  (Ebinop Oshl
                    (Ebinop Oand (Econst_int (Int.repr 2) tint)
                      (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                      tint)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                (tptr tuchar)) (tptr tshort)) tshort))
        (Sset _fov (Ecast (Etempvar _t'14 tshort) tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'11 (Evar _gGeoLayoutCommand (tptr tuchar)))
        (Ssequence
          (Sset _t'12
            (Ederef
              (Ecast
                (Ebinop Oadd (Etempvar _t'11 (tptr tuchar))
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 4) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 4) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (tptr tuchar)) (tptr tshort)) tshort))
          (Sset _near (Ecast (Etempvar _t'12 tshort) tshort))))
      (Ssequence
        (Ssequence
          (Sset _t'9 (Evar _gGeoLayoutCommand (tptr tuchar)))
          (Ssequence
            (Sset _t'10
              (Ederef
                (Ecast
                  (Ebinop Oadd (Etempvar _t'9 (tptr tuchar))
                    (Ebinop Oor
                      (Ebinop Oand (Econst_int (Int.repr 6) tint)
                        (Econst_int (Int.repr 3) tint) tint)
                      (Ebinop Oshl
                        (Ebinop Oand (Econst_int (Int.repr 6) tint)
                          (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                          tint)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                    (tptr tuchar)) (tptr tshort)) tshort))
            (Sset _far (Ecast (Etempvar _t'10 tshort) tshort))))
        (Ssequence
          (Ssequence
            (Sset _t'4 (Evar _gGeoLayoutCommand (tptr tuchar)))
            (Ssequence
              (Sset _t'5
                (Ederef
                  (Ebinop Oadd (Etempvar _t'4 (tptr tuchar))
                    (Ebinop Oor
                      (Ebinop Oand (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 3) tint) tint)
                      (Ebinop Oshl
                        (Ebinop Oand (Econst_int (Int.repr 1) tint)
                          (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                          tint)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                    (tptr tuchar)) tuchar))
              (Sifthenelse (Ebinop One (Etempvar _t'5 tuchar)
                             (Econst_int (Int.repr 0) tint) tint)
                (Ssequence
                  (Ssequence
                    (Sset _t'7 (Evar _gGeoLayoutCommand (tptr tuchar)))
                    (Ssequence
                      (Sset _t'8
                        (Ederef
                          (Ecast
                            (Ebinop Oadd (Etempvar _t'7 (tptr tuchar))
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
                                  tint) tint) (tptr tuchar))
                            (tptr (tptr tvoid))) (tptr tvoid)))
                      (Sset _frustumFunc
                        (Ecast (Etempvar _t'8 (tptr tvoid))
                          (tptr (Tfunction
                                  (tint ::
                                   (tptr (Tstruct _GraphNode noattr)) ::
                                   (tptr tvoid) :: nil)
                                  (tptr (Tunion __512 noattr)) cc_default))))))
                  (Ssequence
                    (Sset _t'6 (Evar _gGeoLayoutCommand (tptr tuchar)))
                    (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
                      (Ebinop Oadd (Etempvar _t'6 (tptr tuchar))
                        (Ebinop Oshl (Econst_int (Int.repr 4) tint)
                          (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                            (Econst_int (Int.repr 3) tint) tuint) tint)
                        (tptr tuchar)))))
                Sskip)))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'3
                  (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr))))
                (Scall (Some _t'1)
                  (Evar _init_graph_node_perspective (Tfunction
                                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                        (tptr (Tstruct _GraphNodePerspective noattr)) ::
                                                        tfloat :: tshort ::
                                                        tshort ::
                                                        (tptr (Tfunction
                                                                (tint ::
                                                                 (tptr (Tstruct _GraphNode noattr)) ::
                                                                 (tptr tvoid) ::
                                                                 nil)
                                                                (tptr (Tunion __512 noattr))
                                                                cc_default)) ::
                                                        tint :: nil)
                                                       (tptr (Tstruct _GraphNodePerspective noattr))
                                                       cc_default))
                  ((Etempvar _t'3 (tptr (Tstruct _AllocOnlyPool noattr))) ::
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
                   (Ecast (Etempvar _fov tshort) tfloat) ::
                   (Etempvar _near tshort) :: (Etempvar _far tshort) ::
                   (Etempvar _frustumFunc (tptr (Tfunction
                                                  (tint ::
                                                   (tptr (Tstruct _GraphNode noattr)) ::
                                                   (tptr tvoid) :: nil)
                                                  (tptr (Tunion __512 noattr))
                                                  cc_default))) ::
                   (Econst_int (Int.repr 0) tint) :: nil)))
              (Sset _graphNode
                (Etempvar _t'1 (tptr (Tstruct _GraphNodePerspective noattr)))))
            (Ssequence
              (Scall None
                (Evar _register_scene_graph_node (Tfunction
                                                   ((tptr (Tstruct _GraphNode noattr)) ::
                                                    nil) tvoid cc_default))
                ((Eaddrof
                   (Efield
                     (Efield
                       (Ederef
                         (Etempvar _graphNode (tptr (Tstruct _GraphNodePerspective noattr)))
                         (Tstruct _GraphNodePerspective noattr)) _fnNode
                       (Tstruct _FnGraphNode noattr)) _node
                     (Tstruct _GraphNode noattr))
                   (tptr (Tstruct _GraphNode noattr))) :: nil))
              (Ssequence
                (Sset _t'2 (Evar _gGeoLayoutCommand (tptr tuchar)))
                (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
                  (Ebinop Oadd (Etempvar _t'2 (tptr tuchar))
                    (Ebinop Oshl (Econst_int (Int.repr 8) tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint)
                    (tptr tuchar)))))))))))
|}.

Definition f_geo_layout_cmd_node_start := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_graphNode, (tptr (Tstruct _GraphNodeStart noattr))) ::
               (_t'1, (tptr (Tstruct _GraphNodeStart noattr))) ::
               (_t'3, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'2, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr))))
      (Scall (Some _t'1)
        (Evar _init_graph_node_start (Tfunction
                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                        (tptr (Tstruct _GraphNodeStart noattr)) ::
                                        nil)
                                       (tptr (Tstruct _GraphNodeStart noattr))
                                       cc_default))
        ((Etempvar _t'3 (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) :: nil)))
    (Sset _graphNode (Etempvar _t'1 (tptr (Tstruct _GraphNodeStart noattr)))))
  (Ssequence
    (Scall None
      (Evar _register_scene_graph_node (Tfunction
                                         ((tptr (Tstruct _GraphNode noattr)) ::
                                          nil) tvoid cc_default))
      ((Eaddrof
         (Efield
           (Ederef
             (Etempvar _graphNode (tptr (Tstruct _GraphNodeStart noattr)))
             (Tstruct _GraphNodeStart noattr)) _node
           (Tstruct _GraphNode noattr)) (tptr (Tstruct _GraphNode noattr))) ::
       nil))
    (Ssequence
      (Sset _t'2 (Evar _gGeoLayoutCommand (tptr tuchar)))
      (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
        (Ebinop Oadd (Etempvar _t'2 (tptr tuchar))
          (Ebinop Oshl (Econst_int (Int.repr 4) tint)
            (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
              (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))))))
|}.

Definition f_geo_layout_cmd_nop3 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _gGeoLayoutCommand (tptr tuchar)))
  (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
    (Ebinop Oadd (Etempvar _t'1 (tptr tuchar))
      (Ebinop Oshl (Econst_int (Int.repr 16) tint)
        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
          (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))))
|}.

Definition f_geo_layout_cmd_node_master_list := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_graphNode, (tptr (Tstruct _GraphNodeMasterList noattr))) ::
               (_t'1, (tptr (Tstruct _GraphNodeMasterList noattr))) ::
               (_t'5, tuchar) :: (_t'4, (tptr tuchar)) ::
               (_t'3, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'2, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr))))
      (Ssequence
        (Sset _t'4 (Evar _gGeoLayoutCommand (tptr tuchar)))
        (Ssequence
          (Sset _t'5
            (Ederef
              (Ebinop Oadd (Etempvar _t'4 (tptr tuchar))
                (Ebinop Oor
                  (Ebinop Oand (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 3) tint) tint)
                  (Ebinop Oshl
                    (Ebinop Oand (Econst_int (Int.repr 1) tint)
                      (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                      tint)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                (tptr tuchar)) tuchar))
          (Scall (Some _t'1)
            (Evar _init_graph_node_master_list (Tfunction
                                                 ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                  (tptr (Tstruct _GraphNodeMasterList noattr)) ::
                                                  tshort :: nil)
                                                 (tptr (Tstruct _GraphNodeMasterList noattr))
                                                 cc_default))
            ((Etempvar _t'3 (tptr (Tstruct _AllocOnlyPool noattr))) ::
             (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
             (Etempvar _t'5 tuchar) :: nil)))))
    (Sset _graphNode
      (Etempvar _t'1 (tptr (Tstruct _GraphNodeMasterList noattr)))))
  (Ssequence
    (Scall None
      (Evar _register_scene_graph_node (Tfunction
                                         ((tptr (Tstruct _GraphNode noattr)) ::
                                          nil) tvoid cc_default))
      ((Eaddrof
         (Efield
           (Ederef
             (Etempvar _graphNode (tptr (Tstruct _GraphNodeMasterList noattr)))
             (Tstruct _GraphNodeMasterList noattr)) _node
           (Tstruct _GraphNode noattr)) (tptr (Tstruct _GraphNode noattr))) ::
       nil))
    (Ssequence
      (Sset _t'2 (Evar _gGeoLayoutCommand (tptr tuchar)))
      (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
        (Ebinop Oadd (Etempvar _t'2 (tptr tuchar))
          (Ebinop Oshl (Econst_int (Int.repr 4) tint)
            (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
              (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))))))
|}.

Definition f_geo_layout_cmd_node_level_of_detail := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_graphNode, (tptr (Tstruct _GraphNodeLevelOfDetail noattr))) ::
               (_minDistance, tshort) :: (_maxDistance, tshort) ::
               (_t'1, (tptr (Tstruct _GraphNodeLevelOfDetail noattr))) ::
               (_t'7, tshort) :: (_t'6, (tptr tuchar)) :: (_t'5, tshort) ::
               (_t'4, (tptr tuchar)) ::
               (_t'3, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'2, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6 (Evar _gGeoLayoutCommand (tptr tuchar)))
    (Ssequence
      (Sset _t'7
        (Ederef
          (Ecast
            (Ebinop Oadd (Etempvar _t'6 (tptr tuchar))
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 4) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 4) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (tptr tuchar)) (tptr tshort)) tshort))
      (Sset _minDistance (Ecast (Etempvar _t'7 tshort) tshort))))
  (Ssequence
    (Ssequence
      (Sset _t'4 (Evar _gGeoLayoutCommand (tptr tuchar)))
      (Ssequence
        (Sset _t'5
          (Ederef
            (Ecast
              (Ebinop Oadd (Etempvar _t'4 (tptr tuchar))
                (Ebinop Oor
                  (Ebinop Oand (Econst_int (Int.repr 6) tint)
                    (Econst_int (Int.repr 3) tint) tint)
                  (Ebinop Oshl
                    (Ebinop Oand (Econst_int (Int.repr 6) tint)
                      (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                      tint)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                (tptr tuchar)) (tptr tshort)) tshort))
        (Sset _maxDistance (Ecast (Etempvar _t'5 tshort) tshort))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr))))
          (Scall (Some _t'1)
            (Evar _init_graph_node_render_range (Tfunction
                                                  ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                   (tptr (Tstruct _GraphNodeLevelOfDetail noattr)) ::
                                                   tshort :: tshort :: nil)
                                                  (tptr (Tstruct _GraphNodeLevelOfDetail noattr))
                                                  cc_default))
            ((Etempvar _t'3 (tptr (Tstruct _AllocOnlyPool noattr))) ::
             (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
             (Etempvar _minDistance tshort) ::
             (Etempvar _maxDistance tshort) :: nil)))
        (Sset _graphNode
          (Etempvar _t'1 (tptr (Tstruct _GraphNodeLevelOfDetail noattr)))))
      (Ssequence
        (Scall None
          (Evar _register_scene_graph_node (Tfunction
                                             ((tptr (Tstruct _GraphNode noattr)) ::
                                              nil) tvoid cc_default))
          ((Eaddrof
             (Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeLevelOfDetail noattr)))
                 (Tstruct _GraphNodeLevelOfDetail noattr)) _node
               (Tstruct _GraphNode noattr))
             (tptr (Tstruct _GraphNode noattr))) :: nil))
        (Ssequence
          (Sset _t'2 (Evar _gGeoLayoutCommand (tptr tuchar)))
          (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
            (Ebinop Oadd (Etempvar _t'2 (tptr tuchar))
              (Ebinop Oshl (Econst_int (Int.repr 8) tint)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))))))))
|}.

Definition f_geo_layout_cmd_node_switch_case := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_graphNode, (tptr (Tstruct _GraphNodeSwitchCase noattr))) ::
               (_t'1, (tptr (Tstruct _GraphNodeSwitchCase noattr))) ::
               (_t'7, (tptr tvoid)) :: (_t'6, (tptr tuchar)) ::
               (_t'5, tshort) :: (_t'4, (tptr tuchar)) ::
               (_t'3, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'2, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr))))
      (Ssequence
        (Sset _t'4 (Evar _gGeoLayoutCommand (tptr tuchar)))
        (Ssequence
          (Sset _t'5
            (Ederef
              (Ecast
                (Ebinop Oadd (Etempvar _t'4 (tptr tuchar))
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 2) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 2) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (tptr tuchar)) (tptr tshort)) tshort))
          (Ssequence
            (Sset _t'6 (Evar _gGeoLayoutCommand (tptr tuchar)))
            (Ssequence
              (Sset _t'7
                (Ederef
                  (Ecast
                    (Ebinop Oadd (Etempvar _t'6 (tptr tuchar))
                      (Ebinop Oor
                        (Ebinop Oand (Econst_int (Int.repr 4) tint)
                          (Econst_int (Int.repr 3) tint) tint)
                        (Ebinop Oshl
                          (Ebinop Oand (Econst_int (Int.repr 4) tint)
                            (Eunop Onotint (Econst_int (Int.repr 3) tint)
                              tint) tint)
                          (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                            (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                      (tptr tuchar)) (tptr (tptr tvoid))) (tptr tvoid)))
              (Scall (Some _t'1)
                (Evar _init_graph_node_switch_case (Tfunction
                                                     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                      (tptr (Tstruct _GraphNodeSwitchCase noattr)) ::
                                                      tshort :: tshort ::
                                                      (tptr (Tfunction
                                                              (tint ::
                                                               (tptr (Tstruct _GraphNode noattr)) ::
                                                               (tptr tvoid) ::
                                                               nil)
                                                              (tptr (Tunion __512 noattr))
                                                              cc_default)) ::
                                                      tint :: nil)
                                                     (tptr (Tstruct _GraphNodeSwitchCase noattr))
                                                     cc_default))
                ((Etempvar _t'3 (tptr (Tstruct _AllocOnlyPool noattr))) ::
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
                 (Etempvar _t'5 tshort) :: (Econst_int (Int.repr 0) tint) ::
                 (Ecast (Etempvar _t'7 (tptr tvoid))
                   (tptr (Tfunction
                           (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                            (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                           cc_default))) :: (Econst_int (Int.repr 0) tint) ::
                 nil)))))))
    (Sset _graphNode
      (Etempvar _t'1 (tptr (Tstruct _GraphNodeSwitchCase noattr)))))
  (Ssequence
    (Scall None
      (Evar _register_scene_graph_node (Tfunction
                                         ((tptr (Tstruct _GraphNode noattr)) ::
                                          nil) tvoid cc_default))
      ((Eaddrof
         (Efield
           (Efield
             (Ederef
               (Etempvar _graphNode (tptr (Tstruct _GraphNodeSwitchCase noattr)))
               (Tstruct _GraphNodeSwitchCase noattr)) _fnNode
             (Tstruct _FnGraphNode noattr)) _node
           (Tstruct _GraphNode noattr)) (tptr (Tstruct _GraphNode noattr))) ::
       nil))
    (Ssequence
      (Sset _t'2 (Evar _gGeoLayoutCommand (tptr tuchar)))
      (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
        (Ebinop Oadd (Etempvar _t'2 (tptr tuchar))
          (Ebinop Oshl (Econst_int (Int.repr 8) tint)
            (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
              (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))))))
|}.

Definition f_geo_layout_cmd_node_camera := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_pos, (tarray tfloat 3)) :: (_focus, (tarray tfloat 3)) ::
              nil);
  fn_temps := ((_graphNode, (tptr (Tstruct _GraphNodeCamera noattr))) ::
               (_cmdPos, (tptr tshort)) ::
               (_t'3, (tptr (Tstruct _GraphNodeCamera noattr))) ::
               (_t'2, (tptr tshort)) :: (_t'1, (tptr tshort)) ::
               (_t'11, (tptr tuchar)) :: (_t'10, tshort) ::
               (_t'9, (tptr tuchar)) :: (_t'8, (tptr tvoid)) ::
               (_t'7, (tptr tuchar)) ::
               (_t'6, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'5, (tptr (tptr (Tstruct _GraphNode noattr)))) ::
               (_t'4, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'11 (Evar _gGeoLayoutCommand (tptr tuchar)))
    (Sset _cmdPos
      (Ecast
        (Ebinop Oadd (Etempvar _t'11 (tptr tuchar))
          (Econst_int (Int.repr 4) tint) (tptr tuchar)) (tptr tshort))))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _read_vec3s_to_vec3f (Tfunction
                                     ((tptr tfloat) :: (tptr tshort) :: nil)
                                     (tptr tshort) cc_default))
        ((Evar _pos (tarray tfloat 3)) :: (Etempvar _cmdPos (tptr tshort)) ::
         nil))
      (Sset _cmdPos (Etempvar _t'1 (tptr tshort))))
    (Ssequence
      (Ssequence
        (Scall (Some _t'2)
          (Evar _read_vec3s_to_vec3f (Tfunction
                                       ((tptr tfloat) :: (tptr tshort) ::
                                        nil) (tptr tshort) cc_default))
          ((Evar _focus (tarray tfloat 3)) ::
           (Etempvar _cmdPos (tptr tshort)) :: nil))
        (Sset _cmdPos (Etempvar _t'2 (tptr tshort))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'6
              (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr))))
            (Ssequence
              (Sset _t'7 (Evar _gGeoLayoutCommand (tptr tuchar)))
              (Ssequence
                (Sset _t'8
                  (Ederef
                    (Ecast
                      (Ebinop Oadd (Etempvar _t'7 (tptr tuchar))
                        (Ebinop Oor
                          (Ebinop Oand (Econst_int (Int.repr 16) tint)
                            (Econst_int (Int.repr 3) tint) tint)
                          (Ebinop Oshl
                            (Ebinop Oand (Econst_int (Int.repr 16) tint)
                              (Eunop Onotint (Econst_int (Int.repr 3) tint)
                                tint) tint)
                            (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                              (Econst_int (Int.repr 3) tint) tuint) tint)
                          tint) (tptr tuchar)) (tptr (tptr tvoid)))
                    (tptr tvoid)))
                (Ssequence
                  (Sset _t'9 (Evar _gGeoLayoutCommand (tptr tuchar)))
                  (Ssequence
                    (Sset _t'10
                      (Ederef
                        (Ecast
                          (Ebinop Oadd (Etempvar _t'9 (tptr tuchar))
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
                              tint) (tptr tuchar)) (tptr tshort)) tshort))
                    (Scall (Some _t'3)
                      (Evar _init_graph_node_camera (Tfunction
                                                      ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                       (tptr (Tstruct _GraphNodeCamera noattr)) ::
                                                       (tptr tfloat) ::
                                                       (tptr tfloat) ::
                                                       (tptr (Tfunction
                                                               (tint ::
                                                                (tptr (Tstruct _GraphNode noattr)) ::
                                                                (tptr tvoid) ::
                                                                nil)
                                                               (tptr (Tunion __512 noattr))
                                                               cc_default)) ::
                                                       tint :: nil)
                                                      (tptr (Tstruct _GraphNodeCamera noattr))
                                                      cc_default))
                      ((Etempvar _t'6 (tptr (Tstruct _AllocOnlyPool noattr))) ::
                       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
                       (Evar _pos (tarray tfloat 3)) ::
                       (Evar _focus (tarray tfloat 3)) ::
                       (Ecast (Etempvar _t'8 (tptr tvoid))
                         (tptr (Tfunction
                                 (tint ::
                                  (tptr (Tstruct _GraphNode noattr)) ::
                                  (tptr tvoid) :: nil)
                                 (tptr (Tunion __512 noattr)) cc_default))) ::
                       (Etempvar _t'10 tshort) :: nil)))))))
          (Sset _graphNode
            (Etempvar _t'3 (tptr (Tstruct _GraphNodeCamera noattr)))))
        (Ssequence
          (Scall None
            (Evar _register_scene_graph_node (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                nil) tvoid cc_default))
            ((Eaddrof
               (Efield
                 (Efield
                   (Ederef
                     (Etempvar _graphNode (tptr (Tstruct _GraphNodeCamera noattr)))
                     (Tstruct _GraphNodeCamera noattr)) _fnNode
                   (Tstruct _FnGraphNode noattr)) _node
                 (Tstruct _GraphNode noattr))
               (tptr (Tstruct _GraphNode noattr))) :: nil))
          (Ssequence
            (Ssequence
              (Sset _t'5
                (Evar _gGeoViews (tptr (tptr (Tstruct _GraphNode noattr)))))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Etempvar _t'5 (tptr (tptr (Tstruct _GraphNode noattr))))
                    (Econst_int (Int.repr 0) tint)
                    (tptr (tptr (Tstruct _GraphNode noattr))))
                  (tptr (Tstruct _GraphNode noattr)))
                (Eaddrof
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _graphNode (tptr (Tstruct _GraphNodeCamera noattr)))
                        (Tstruct _GraphNodeCamera noattr)) _fnNode
                      (Tstruct _FnGraphNode noattr)) _node
                    (Tstruct _GraphNode noattr))
                  (tptr (Tstruct _GraphNode noattr)))))
            (Ssequence
              (Sset _t'4 (Evar _gGeoLayoutCommand (tptr tuchar)))
              (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
                (Ebinop Oadd (Etempvar _t'4 (tptr tuchar))
                  (Ebinop Oshl (Econst_int (Int.repr 20) tint)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint)
                  (tptr tuchar))))))))))
|}.

Definition f_geo_layout_cmd_node_translation_rotation := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_translation, (tarray tshort 3)) ::
              (_rotation, (tarray tshort 3)) :: nil);
  fn_temps := ((_graphNode,
                (tptr (Tstruct _GraphNodeTranslationRotation noattr))) ::
               (_displayList, (tptr tvoid)) :: (_drawingLayer, tshort) ::
               (_params, tshort) :: (_cmdPos, (tptr tshort)) ::
               (_t'5, (tptr (Tstruct _GraphNodeTranslationRotation noattr))) ::
               (_t'4, (tptr tshort)) :: (_t'3, (tptr tshort)) ::
               (_t'2, (tptr tshort)) :: (_t'1, (tptr tshort)) ::
               (_t'10, tuchar) :: (_t'9, (tptr tuchar)) ::
               (_t'8, (tptr tuchar)) :: (_t'7, tshort) ::
               (_t'6, (tptr (Tstruct _AllocOnlyPool noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _displayList (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Sset _drawingLayer (Ecast (Econst_int (Int.repr 0) tint) tshort))
    (Ssequence
      (Ssequence
        (Sset _t'9 (Evar _gGeoLayoutCommand (tptr tuchar)))
        (Ssequence
          (Sset _t'10
            (Ederef
              (Ebinop Oadd (Etempvar _t'9 (tptr tuchar))
                (Ebinop Oor
                  (Ebinop Oand (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 3) tint) tint)
                  (Ebinop Oshl
                    (Ebinop Oand (Econst_int (Int.repr 1) tint)
                      (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                      tint)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                (tptr tuchar)) tuchar))
          (Sset _params (Ecast (Etempvar _t'10 tuchar) tshort))))
      (Ssequence
        (Ssequence
          (Sset _t'8 (Evar _gGeoLayoutCommand (tptr tuchar)))
          (Sset _cmdPos (Ecast (Etempvar _t'8 (tptr tuchar)) (tptr tshort))))
        (Ssequence
          (Sswitch (Ebinop Oshr
                     (Ebinop Oand (Etempvar _params tshort)
                       (Econst_int (Int.repr 112) tint) tint)
                     (Econst_int (Int.repr 4) tint) tint)
            (LScons (Some 0)
              (Ssequence
                (Ssequence
                  (Scall (Some _t'1)
                    (Evar _read_vec3s (Tfunction
                                        ((tptr tshort) :: (tptr tshort) ::
                                         nil) (tptr tshort) cc_default))
                    ((Evar _translation (tarray tshort 3)) ::
                     (Ebinop Oadd (Etempvar _cmdPos (tptr tshort))
                       (Econst_int (Int.repr 2) tint) (tptr tshort)) :: nil))
                  (Sset _cmdPos (Etempvar _t'1 (tptr tshort))))
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'2)
                      (Evar _read_vec3s_angle (Tfunction
                                                ((tptr tshort) ::
                                                 (tptr tshort) :: nil)
                                                (tptr tshort) cc_default))
                      ((Evar _rotation (tarray tshort 3)) ::
                       (Etempvar _cmdPos (tptr tshort)) :: nil))
                    (Sset _cmdPos (Etempvar _t'2 (tptr tshort))))
                  Sbreak))
              (LScons (Some 1)
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'3)
                      (Evar _read_vec3s (Tfunction
                                          ((tptr tshort) :: (tptr tshort) ::
                                           nil) (tptr tshort) cc_default))
                      ((Evar _translation (tarray tshort 3)) ::
                       (Ebinop Oadd (Etempvar _cmdPos (tptr tshort))
                         (Econst_int (Int.repr 1) tint) (tptr tshort)) ::
                       nil))
                    (Sset _cmdPos (Etempvar _t'3 (tptr tshort))))
                  (Ssequence
                    (Scall None
                      (Evar _vec3s_copy (Tfunction
                                          ((tptr tshort) :: (tptr tshort) ::
                                           nil) (tptr tvoid) cc_default))
                      ((Evar _rotation (tarray tshort 3)) ::
                       (Evar _gVec3sZero (tarray tshort 3)) :: nil))
                    Sbreak))
                (LScons (Some 2)
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'4)
                        (Evar _read_vec3s_angle (Tfunction
                                                  ((tptr tshort) ::
                                                   (tptr tshort) :: nil)
                                                  (tptr tshort) cc_default))
                        ((Evar _rotation (tarray tshort 3)) ::
                         (Ebinop Oadd (Etempvar _cmdPos (tptr tshort))
                           (Econst_int (Int.repr 1) tint) (tptr tshort)) ::
                         nil))
                      (Sset _cmdPos (Etempvar _t'4 (tptr tshort))))
                    (Ssequence
                      (Scall None
                        (Evar _vec3s_copy (Tfunction
                                            ((tptr tshort) ::
                                             (tptr tshort) :: nil)
                                            (tptr tvoid) cc_default))
                        ((Evar _translation (tarray tshort 3)) ::
                         (Evar _gVec3sZero (tarray tshort 3)) :: nil))
                      Sbreak))
                  (LScons (Some 3)
                    (Ssequence
                      (Scall None
                        (Evar _vec3s_copy (Tfunction
                                            ((tptr tshort) ::
                                             (tptr tshort) :: nil)
                                            (tptr tvoid) cc_default))
                        ((Evar _translation (tarray tshort 3)) ::
                         (Evar _gVec3sZero (tarray tshort 3)) :: nil))
                      (Ssequence
                        (Ssequence
                          (Sset _t'7
                            (Ederef
                              (Ebinop Oadd (Etempvar _cmdPos (tptr tshort))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))
                              tshort))
                          (Scall None
                            (Evar _vec3s_set (Tfunction
                                               ((tptr tshort) :: tshort ::
                                                tshort :: tshort :: nil)
                                               (tptr tvoid) cc_default))
                            ((Evar _rotation (tarray tshort 3)) ::
                             (Econst_int (Int.repr 0) tint) ::
                             (Ebinop Odiv
                               (Ebinop Oshl (Etempvar _t'7 tshort)
                                 (Econst_int (Int.repr 15) tint) tint)
                               (Econst_int (Int.repr 180) tint) tint) ::
                             (Econst_int (Int.repr 0) tint) :: nil)))
                        (Ssequence
                          (Sset _cmdPos
                            (Ebinop Oadd (Etempvar _cmdPos (tptr tshort))
                              (Ebinop Oshl (Econst_int (Int.repr 2) tint)
                                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                                  (Econst_int (Int.repr 3) tint) tuint) tint)
                              (tptr tshort)))
                          Sbreak)))
                    LSnil)))))
          (Ssequence
            (Sifthenelse (Ebinop Oand (Etempvar _params tshort)
                           (Econst_int (Int.repr 128) tint) tint)
              (Ssequence
                (Sset _displayList
                  (Ederef
                    (Ecast
                      (Ebinop Oadd (Etempvar _cmdPos (tptr tshort))
                        (Econst_int (Int.repr 0) tint) (tptr tshort))
                      (tptr (tptr tvoid))) (tptr tvoid)))
                (Ssequence
                  (Sset _drawingLayer
                    (Ecast
                      (Ebinop Oand (Etempvar _params tshort)
                        (Econst_int (Int.repr 15) tint) tint) tshort))
                  (Sset _cmdPos
                    (Ebinop Oadd (Etempvar _cmdPos (tptr tshort))
                      (Ebinop Oshl (Econst_int (Int.repr 2) tint)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint)
                      (tptr tshort)))))
              Sskip)
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'6
                    (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr))))
                  (Scall (Some _t'5)
                    (Evar _init_graph_node_translation_rotation (Tfunction
                                                                  ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                                   (tptr (Tstruct _GraphNodeTranslationRotation noattr)) ::
                                                                   tint ::
                                                                   (tptr tvoid) ::
                                                                   (tptr tshort) ::
                                                                   (tptr tshort) ::
                                                                   nil)
                                                                  (tptr (Tstruct _GraphNodeTranslationRotation noattr))
                                                                  cc_default))
                    ((Etempvar _t'6 (tptr (Tstruct _AllocOnlyPool noattr))) ::
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
                     (Etempvar _drawingLayer tshort) ::
                     (Etempvar _displayList (tptr tvoid)) ::
                     (Evar _translation (tarray tshort 3)) ::
                     (Evar _rotation (tarray tshort 3)) :: nil)))
                (Sset _graphNode
                  (Etempvar _t'5 (tptr (Tstruct _GraphNodeTranslationRotation noattr)))))
              (Ssequence
                (Scall None
                  (Evar _register_scene_graph_node (Tfunction
                                                     ((tptr (Tstruct _GraphNode noattr)) ::
                                                      nil) tvoid cc_default))
                  ((Eaddrof
                     (Efield
                       (Ederef
                         (Etempvar _graphNode (tptr (Tstruct _GraphNodeTranslationRotation noattr)))
                         (Tstruct _GraphNodeTranslationRotation noattr))
                       _node (Tstruct _GraphNode noattr))
                     (tptr (Tstruct _GraphNode noattr))) :: nil))
                (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
                  (Ecast (Etempvar _cmdPos (tptr tshort)) (tptr tuchar)))))))))))
|}.

Definition f_geo_layout_cmd_node_translation := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_translation, (tarray tshort 3)) :: nil);
  fn_temps := ((_graphNode, (tptr (Tstruct _GraphNodeTranslation noattr))) ::
               (_drawingLayer, tshort) :: (_params, tshort) ::
               (_cmdPos, (tptr tshort)) :: (_displayList, (tptr tvoid)) ::
               (_t'2, (tptr (Tstruct _GraphNodeTranslation noattr))) ::
               (_t'1, (tptr tshort)) :: (_t'6, tuchar) ::
               (_t'5, (tptr tuchar)) :: (_t'4, (tptr tuchar)) ::
               (_t'3, (tptr (Tstruct _AllocOnlyPool noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _drawingLayer (Ecast (Econst_int (Int.repr 0) tint) tshort))
  (Ssequence
    (Ssequence
      (Sset _t'5 (Evar _gGeoLayoutCommand (tptr tuchar)))
      (Ssequence
        (Sset _t'6
          (Ederef
            (Ebinop Oadd (Etempvar _t'5 (tptr tuchar))
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 1) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (tptr tuchar)) tuchar))
        (Sset _params (Ecast (Etempvar _t'6 tuchar) tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'4 (Evar _gGeoLayoutCommand (tptr tuchar)))
        (Sset _cmdPos (Ecast (Etempvar _t'4 (tptr tuchar)) (tptr tshort))))
      (Ssequence
        (Sset _displayList
          (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
        (Ssequence
          (Ssequence
            (Scall (Some _t'1)
              (Evar _read_vec3s (Tfunction
                                  ((tptr tshort) :: (tptr tshort) :: nil)
                                  (tptr tshort) cc_default))
              ((Evar _translation (tarray tshort 3)) ::
               (Ebinop Oadd (Etempvar _cmdPos (tptr tshort))
                 (Econst_int (Int.repr 1) tint) (tptr tshort)) :: nil))
            (Sset _cmdPos (Etempvar _t'1 (tptr tshort))))
          (Ssequence
            (Sifthenelse (Ebinop Oand (Etempvar _params tshort)
                           (Econst_int (Int.repr 128) tint) tint)
              (Ssequence
                (Sset _displayList
                  (Ederef
                    (Ecast
                      (Ebinop Oadd (Etempvar _cmdPos (tptr tshort))
                        (Econst_int (Int.repr 0) tint) (tptr tshort))
                      (tptr (tptr tvoid))) (tptr tvoid)))
                (Ssequence
                  (Sset _drawingLayer
                    (Ecast
                      (Ebinop Oand (Etempvar _params tshort)
                        (Econst_int (Int.repr 15) tint) tint) tshort))
                  (Sset _cmdPos
                    (Ebinop Oadd (Etempvar _cmdPos (tptr tshort))
                      (Ebinop Oshl (Econst_int (Int.repr 2) tint)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint)
                      (tptr tshort)))))
              Sskip)
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'3
                    (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr))))
                  (Scall (Some _t'2)
                    (Evar _init_graph_node_translation (Tfunction
                                                         ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                          (tptr (Tstruct _GraphNodeTranslation noattr)) ::
                                                          tint ::
                                                          (tptr tvoid) ::
                                                          (tptr tshort) ::
                                                          nil)
                                                         (tptr (Tstruct _GraphNodeTranslation noattr))
                                                         cc_default))
                    ((Etempvar _t'3 (tptr (Tstruct _AllocOnlyPool noattr))) ::
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
                     (Etempvar _drawingLayer tshort) ::
                     (Etempvar _displayList (tptr tvoid)) ::
                     (Evar _translation (tarray tshort 3)) :: nil)))
                (Sset _graphNode
                  (Etempvar _t'2 (tptr (Tstruct _GraphNodeTranslation noattr)))))
              (Ssequence
                (Scall None
                  (Evar _register_scene_graph_node (Tfunction
                                                     ((tptr (Tstruct _GraphNode noattr)) ::
                                                      nil) tvoid cc_default))
                  ((Eaddrof
                     (Efield
                       (Ederef
                         (Etempvar _graphNode (tptr (Tstruct _GraphNodeTranslation noattr)))
                         (Tstruct _GraphNodeTranslation noattr)) _node
                       (Tstruct _GraphNode noattr))
                     (tptr (Tstruct _GraphNode noattr))) :: nil))
                (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
                  (Ecast (Etempvar _cmdPos (tptr tshort)) (tptr tuchar)))))))))))
|}.

Definition f_geo_layout_cmd_node_rotation := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_sp2c, (tarray tshort 3)) :: nil);
  fn_temps := ((_graphNode, (tptr (Tstruct _GraphNodeRotation noattr))) ::
               (_drawingLayer, tshort) :: (_params, tshort) ::
               (_cmdPos, (tptr tshort)) :: (_displayList, (tptr tvoid)) ::
               (_t'2, (tptr (Tstruct _GraphNodeRotation noattr))) ::
               (_t'1, (tptr tshort)) :: (_t'6, tuchar) ::
               (_t'5, (tptr tuchar)) :: (_t'4, (tptr tuchar)) ::
               (_t'3, (tptr (Tstruct _AllocOnlyPool noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _drawingLayer (Ecast (Econst_int (Int.repr 0) tint) tshort))
  (Ssequence
    (Ssequence
      (Sset _t'5 (Evar _gGeoLayoutCommand (tptr tuchar)))
      (Ssequence
        (Sset _t'6
          (Ederef
            (Ebinop Oadd (Etempvar _t'5 (tptr tuchar))
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 1) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (tptr tuchar)) tuchar))
        (Sset _params (Ecast (Etempvar _t'6 tuchar) tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'4 (Evar _gGeoLayoutCommand (tptr tuchar)))
        (Sset _cmdPos (Ecast (Etempvar _t'4 (tptr tuchar)) (tptr tshort))))
      (Ssequence
        (Sset _displayList
          (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
        (Ssequence
          (Ssequence
            (Scall (Some _t'1)
              (Evar _read_vec3s_angle (Tfunction
                                        ((tptr tshort) :: (tptr tshort) ::
                                         nil) (tptr tshort) cc_default))
              ((Evar _sp2c (tarray tshort 3)) ::
               (Ebinop Oadd (Etempvar _cmdPos (tptr tshort))
                 (Econst_int (Int.repr 1) tint) (tptr tshort)) :: nil))
            (Sset _cmdPos (Etempvar _t'1 (tptr tshort))))
          (Ssequence
            (Sifthenelse (Ebinop Oand (Etempvar _params tshort)
                           (Econst_int (Int.repr 128) tint) tint)
              (Ssequence
                (Sset _displayList
                  (Ederef
                    (Ecast
                      (Ebinop Oadd (Etempvar _cmdPos (tptr tshort))
                        (Econst_int (Int.repr 0) tint) (tptr tshort))
                      (tptr (tptr tvoid))) (tptr tvoid)))
                (Ssequence
                  (Sset _drawingLayer
                    (Ecast
                      (Ebinop Oand (Etempvar _params tshort)
                        (Econst_int (Int.repr 15) tint) tint) tshort))
                  (Sset _cmdPos
                    (Ebinop Oadd (Etempvar _cmdPos (tptr tshort))
                      (Ebinop Oshl (Econst_int (Int.repr 2) tint)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint)
                      (tptr tshort)))))
              Sskip)
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'3
                    (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr))))
                  (Scall (Some _t'2)
                    (Evar _init_graph_node_rotation (Tfunction
                                                      ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                       (tptr (Tstruct _GraphNodeRotation noattr)) ::
                                                       tint ::
                                                       (tptr tvoid) ::
                                                       (tptr tshort) :: nil)
                                                      (tptr (Tstruct _GraphNodeRotation noattr))
                                                      cc_default))
                    ((Etempvar _t'3 (tptr (Tstruct _AllocOnlyPool noattr))) ::
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
                     (Etempvar _drawingLayer tshort) ::
                     (Etempvar _displayList (tptr tvoid)) ::
                     (Evar _sp2c (tarray tshort 3)) :: nil)))
                (Sset _graphNode
                  (Etempvar _t'2 (tptr (Tstruct _GraphNodeRotation noattr)))))
              (Ssequence
                (Scall None
                  (Evar _register_scene_graph_node (Tfunction
                                                     ((tptr (Tstruct _GraphNode noattr)) ::
                                                      nil) tvoid cc_default))
                  ((Eaddrof
                     (Efield
                       (Ederef
                         (Etempvar _graphNode (tptr (Tstruct _GraphNodeRotation noattr)))
                         (Tstruct _GraphNodeRotation noattr)) _node
                       (Tstruct _GraphNode noattr))
                     (tptr (Tstruct _GraphNode noattr))) :: nil))
                (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
                  (Ecast (Etempvar _cmdPos (tptr tshort)) (tptr tuchar)))))))))))
|}.

Definition f_geo_layout_cmd_node_scale := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_graphNode, (tptr (Tstruct _GraphNodeScale noattr))) ::
               (_drawingLayer, tshort) :: (_params, tshort) ::
               (_scale, tfloat) :: (_displayList, (tptr tvoid)) ::
               (_t'1, (tptr (Tstruct _GraphNodeScale noattr))) ::
               (_t'9, tuchar) :: (_t'8, (tptr tuchar)) :: (_t'7, tuint) ::
               (_t'6, (tptr tuchar)) :: (_t'5, (tptr tuchar)) ::
               (_t'4, (tptr tuchar)) ::
               (_t'3, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'2, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Sset _drawingLayer (Ecast (Econst_int (Int.repr 0) tint) tshort))
  (Ssequence
    (Ssequence
      (Sset _t'8 (Evar _gGeoLayoutCommand (tptr tuchar)))
      (Ssequence
        (Sset _t'9
          (Ederef
            (Ebinop Oadd (Etempvar _t'8 (tptr tuchar))
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 1) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (tptr tuchar)) tuchar))
        (Sset _params (Ecast (Etempvar _t'9 tuchar) tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'6 (Evar _gGeoLayoutCommand (tptr tuchar)))
        (Ssequence
          (Sset _t'7
            (Ederef
              (Ecast
                (Ebinop Oadd (Etempvar _t'6 (tptr tuchar))
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 4) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 4) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (tptr tuchar)) (tptr tuint)) tuint))
          (Sset _scale
            (Ebinop Odiv (Etempvar _t'7 tuint)
              (Econst_single (Float32.of_bits (Int.repr 1199570944)) tfloat)
              tfloat))))
      (Ssequence
        (Sset _displayList
          (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
        (Ssequence
          (Sifthenelse (Ebinop Oand (Etempvar _params tshort)
                         (Econst_int (Int.repr 128) tint) tint)
            (Ssequence
              (Ssequence
                (Sset _t'5 (Evar _gGeoLayoutCommand (tptr tuchar)))
                (Sset _displayList
                  (Ederef
                    (Ecast
                      (Ebinop Oadd (Etempvar _t'5 (tptr tuchar))
                        (Ebinop Oor
                          (Ebinop Oand (Econst_int (Int.repr 8) tint)
                            (Econst_int (Int.repr 3) tint) tint)
                          (Ebinop Oshl
                            (Ebinop Oand (Econst_int (Int.repr 8) tint)
                              (Eunop Onotint (Econst_int (Int.repr 3) tint)
                                tint) tint)
                            (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                              (Econst_int (Int.repr 3) tint) tuint) tint)
                          tint) (tptr tuchar)) (tptr (tptr tvoid)))
                    (tptr tvoid))))
              (Ssequence
                (Sset _drawingLayer
                  (Ecast
                    (Ebinop Oand (Etempvar _params tshort)
                      (Econst_int (Int.repr 15) tint) tint) tshort))
                (Ssequence
                  (Sset _t'4 (Evar _gGeoLayoutCommand (tptr tuchar)))
                  (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
                    (Ebinop Oadd (Etempvar _t'4 (tptr tuchar))
                      (Ebinop Oshl (Econst_int (Int.repr 4) tint)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint)
                      (tptr tuchar))))))
            Sskip)
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'3
                  (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr))))
                (Scall (Some _t'1)
                  (Evar _init_graph_node_scale (Tfunction
                                                 ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                  (tptr (Tstruct _GraphNodeScale noattr)) ::
                                                  tint :: (tptr tvoid) ::
                                                  tfloat :: nil)
                                                 (tptr (Tstruct _GraphNodeScale noattr))
                                                 cc_default))
                  ((Etempvar _t'3 (tptr (Tstruct _AllocOnlyPool noattr))) ::
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
                   (Etempvar _drawingLayer tshort) ::
                   (Etempvar _displayList (tptr tvoid)) ::
                   (Etempvar _scale tfloat) :: nil)))
              (Sset _graphNode
                (Etempvar _t'1 (tptr (Tstruct _GraphNodeScale noattr)))))
            (Ssequence
              (Scall None
                (Evar _register_scene_graph_node (Tfunction
                                                   ((tptr (Tstruct _GraphNode noattr)) ::
                                                    nil) tvoid cc_default))
                ((Eaddrof
                   (Efield
                     (Ederef
                       (Etempvar _graphNode (tptr (Tstruct _GraphNodeScale noattr)))
                       (Tstruct _GraphNodeScale noattr)) _node
                     (Tstruct _GraphNode noattr))
                   (tptr (Tstruct _GraphNode noattr))) :: nil))
              (Ssequence
                (Sset _t'2 (Evar _gGeoLayoutCommand (tptr tuchar)))
                (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
                  (Ebinop Oadd (Etempvar _t'2 (tptr tuchar))
                    (Ebinop Oshl (Econst_int (Int.repr 8) tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint)
                    (tptr tuchar)))))))))))
|}.

Definition f_geo_layout_cmd_nop2 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _gGeoLayoutCommand (tptr tuchar)))
  (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
    (Ebinop Oadd (Etempvar _t'1 (tptr tuchar))
      (Ebinop Oshl (Econst_int (Int.repr 8) tint)
        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
          (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))))
|}.

Definition f_geo_layout_cmd_node_animated_part := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_translation, (tarray tshort 3)) :: nil);
  fn_temps := ((_graphNode, (tptr (Tstruct _GraphNodeAnimatedPart noattr))) ::
               (_drawingLayer, tint) :: (_displayList, (tptr tvoid)) ::
               (_cmdPos, (tptr tshort)) ::
               (_t'1, (tptr (Tstruct _GraphNodeAnimatedPart noattr))) ::
               (_t'6, (tptr tuchar)) :: (_t'5, (tptr tuchar)) ::
               (_t'4, (tptr tuchar)) ::
               (_t'3, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'2, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6 (Evar _gGeoLayoutCommand (tptr tuchar)))
    (Sset _drawingLayer
      (Ederef
        (Ebinop Oadd (Etempvar _t'6 (tptr tuchar))
          (Ebinop Oor
            (Ebinop Oand (Econst_int (Int.repr 1) tint)
              (Econst_int (Int.repr 3) tint) tint)
            (Ebinop Oshl
              (Ebinop Oand (Econst_int (Int.repr 1) tint)
                (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
              (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                (Econst_int (Int.repr 3) tint) tuint) tint) tint)
          (tptr tuchar)) tuchar)))
  (Ssequence
    (Ssequence
      (Sset _t'5 (Evar _gGeoLayoutCommand (tptr tuchar)))
      (Sset _displayList
        (Ederef
          (Ecast
            (Ebinop Oadd (Etempvar _t'5 (tptr tuchar))
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 8) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 8) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (tptr tuchar)) (tptr (tptr tvoid))) (tptr tvoid))))
    (Ssequence
      (Ssequence
        (Sset _t'4 (Evar _gGeoLayoutCommand (tptr tuchar)))
        (Sset _cmdPos (Ecast (Etempvar _t'4 (tptr tuchar)) (tptr tshort))))
      (Ssequence
        (Scall None
          (Evar _read_vec3s (Tfunction
                              ((tptr tshort) :: (tptr tshort) :: nil)
                              (tptr tshort) cc_default))
          ((Evar _translation (tarray tshort 3)) ::
           (Ebinop Oadd (Etempvar _cmdPos (tptr tshort))
             (Econst_int (Int.repr 1) tint) (tptr tshort)) :: nil))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'3
                (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr))))
              (Scall (Some _t'1)
                (Evar _init_graph_node_animated_part (Tfunction
                                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                        (tptr (Tstruct _GraphNodeAnimatedPart noattr)) ::
                                                        tint ::
                                                        (tptr tvoid) ::
                                                        (tptr tshort) :: nil)
                                                       (tptr (Tstruct _GraphNodeAnimatedPart noattr))
                                                       cc_default))
                ((Etempvar _t'3 (tptr (Tstruct _AllocOnlyPool noattr))) ::
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
                 (Etempvar _drawingLayer tint) ::
                 (Etempvar _displayList (tptr tvoid)) ::
                 (Evar _translation (tarray tshort 3)) :: nil)))
            (Sset _graphNode
              (Etempvar _t'1 (tptr (Tstruct _GraphNodeAnimatedPart noattr)))))
          (Ssequence
            (Scall None
              (Evar _register_scene_graph_node (Tfunction
                                                 ((tptr (Tstruct _GraphNode noattr)) ::
                                                  nil) tvoid cc_default))
              ((Eaddrof
                 (Efield
                   (Ederef
                     (Etempvar _graphNode (tptr (Tstruct _GraphNodeAnimatedPart noattr)))
                     (Tstruct _GraphNodeAnimatedPart noattr)) _node
                   (Tstruct _GraphNode noattr))
                 (tptr (Tstruct _GraphNode noattr))) :: nil))
            (Ssequence
              (Sset _t'2 (Evar _gGeoLayoutCommand (tptr tuchar)))
              (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
                (Ebinop Oadd (Etempvar _t'2 (tptr tuchar))
                  (Ebinop Oshl (Econst_int (Int.repr 12) tint)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint)
                  (tptr tuchar))))))))))
|}.

Definition f_geo_layout_cmd_node_billboard := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_translation, (tarray tshort 3)) :: nil);
  fn_temps := ((_graphNode, (tptr (Tstruct _GraphNodeBillboard noattr))) ::
               (_drawingLayer, tshort) :: (_params, tshort) ::
               (_cmdPos, (tptr tshort)) :: (_displayList, (tptr tvoid)) ::
               (_t'2, (tptr (Tstruct _GraphNodeBillboard noattr))) ::
               (_t'1, (tptr tshort)) :: (_t'6, tuchar) ::
               (_t'5, (tptr tuchar)) :: (_t'4, (tptr tuchar)) ::
               (_t'3, (tptr (Tstruct _AllocOnlyPool noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _drawingLayer (Ecast (Econst_int (Int.repr 0) tint) tshort))
  (Ssequence
    (Ssequence
      (Sset _t'5 (Evar _gGeoLayoutCommand (tptr tuchar)))
      (Ssequence
        (Sset _t'6
          (Ederef
            (Ebinop Oadd (Etempvar _t'5 (tptr tuchar))
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 1) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (tptr tuchar)) tuchar))
        (Sset _params (Ecast (Etempvar _t'6 tuchar) tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'4 (Evar _gGeoLayoutCommand (tptr tuchar)))
        (Sset _cmdPos (Ecast (Etempvar _t'4 (tptr tuchar)) (tptr tshort))))
      (Ssequence
        (Sset _displayList
          (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
        (Ssequence
          (Ssequence
            (Scall (Some _t'1)
              (Evar _read_vec3s (Tfunction
                                  ((tptr tshort) :: (tptr tshort) :: nil)
                                  (tptr tshort) cc_default))
              ((Evar _translation (tarray tshort 3)) ::
               (Ebinop Oadd (Etempvar _cmdPos (tptr tshort))
                 (Econst_int (Int.repr 1) tint) (tptr tshort)) :: nil))
            (Sset _cmdPos (Etempvar _t'1 (tptr tshort))))
          (Ssequence
            (Sifthenelse (Ebinop Oand (Etempvar _params tshort)
                           (Econst_int (Int.repr 128) tint) tint)
              (Ssequence
                (Sset _displayList
                  (Ederef
                    (Ecast
                      (Ebinop Oadd (Etempvar _cmdPos (tptr tshort))
                        (Econst_int (Int.repr 0) tint) (tptr tshort))
                      (tptr (tptr tvoid))) (tptr tvoid)))
                (Ssequence
                  (Sset _drawingLayer
                    (Ecast
                      (Ebinop Oand (Etempvar _params tshort)
                        (Econst_int (Int.repr 15) tint) tint) tshort))
                  (Sset _cmdPos
                    (Ebinop Oadd (Etempvar _cmdPos (tptr tshort))
                      (Ebinop Oshl (Econst_int (Int.repr 2) tint)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint)
                      (tptr tshort)))))
              Sskip)
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'3
                    (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr))))
                  (Scall (Some _t'2)
                    (Evar _init_graph_node_billboard (Tfunction
                                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                        (tptr (Tstruct _GraphNodeBillboard noattr)) ::
                                                        tint ::
                                                        (tptr tvoid) ::
                                                        (tptr tshort) :: nil)
                                                       (tptr (Tstruct _GraphNodeBillboard noattr))
                                                       cc_default))
                    ((Etempvar _t'3 (tptr (Tstruct _AllocOnlyPool noattr))) ::
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
                     (Etempvar _drawingLayer tshort) ::
                     (Etempvar _displayList (tptr tvoid)) ::
                     (Evar _translation (tarray tshort 3)) :: nil)))
                (Sset _graphNode
                  (Etempvar _t'2 (tptr (Tstruct _GraphNodeBillboard noattr)))))
              (Ssequence
                (Scall None
                  (Evar _register_scene_graph_node (Tfunction
                                                     ((tptr (Tstruct _GraphNode noattr)) ::
                                                      nil) tvoid cc_default))
                  ((Eaddrof
                     (Efield
                       (Ederef
                         (Etempvar _graphNode (tptr (Tstruct _GraphNodeBillboard noattr)))
                         (Tstruct _GraphNodeBillboard noattr)) _node
                       (Tstruct _GraphNode noattr))
                     (tptr (Tstruct _GraphNode noattr))) :: nil))
                (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
                  (Ecast (Etempvar _cmdPos (tptr tshort)) (tptr tuchar)))))))))))
|}.

Definition f_geo_layout_cmd_node_display_list := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_graphNode, (tptr (Tstruct _GraphNodeDisplayList noattr))) ::
               (_drawingLayer, tint) :: (_displayList, (tptr tvoid)) ::
               (_t'1, (tptr (Tstruct _GraphNodeDisplayList noattr))) ::
               (_t'5, (tptr tuchar)) :: (_t'4, (tptr tuchar)) ::
               (_t'3, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'2, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5 (Evar _gGeoLayoutCommand (tptr tuchar)))
    (Sset _drawingLayer
      (Ederef
        (Ebinop Oadd (Etempvar _t'5 (tptr tuchar))
          (Ebinop Oor
            (Ebinop Oand (Econst_int (Int.repr 1) tint)
              (Econst_int (Int.repr 3) tint) tint)
            (Ebinop Oshl
              (Ebinop Oand (Econst_int (Int.repr 1) tint)
                (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
              (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                (Econst_int (Int.repr 3) tint) tuint) tint) tint)
          (tptr tuchar)) tuchar)))
  (Ssequence
    (Ssequence
      (Sset _t'4 (Evar _gGeoLayoutCommand (tptr tuchar)))
      (Sset _displayList
        (Ederef
          (Ecast
            (Ebinop Oadd (Etempvar _t'4 (tptr tuchar))
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 4) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 4) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (tptr tuchar)) (tptr (tptr tvoid))) (tptr tvoid))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr))))
          (Scall (Some _t'1)
            (Evar _init_graph_node_display_list (Tfunction
                                                  ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                   (tptr (Tstruct _GraphNodeDisplayList noattr)) ::
                                                   tint :: (tptr tvoid) ::
                                                   nil)
                                                  (tptr (Tstruct _GraphNodeDisplayList noattr))
                                                  cc_default))
            ((Etempvar _t'3 (tptr (Tstruct _AllocOnlyPool noattr))) ::
             (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
             (Etempvar _drawingLayer tint) ::
             (Etempvar _displayList (tptr tvoid)) :: nil)))
        (Sset _graphNode
          (Etempvar _t'1 (tptr (Tstruct _GraphNodeDisplayList noattr)))))
      (Ssequence
        (Scall None
          (Evar _register_scene_graph_node (Tfunction
                                             ((tptr (Tstruct _GraphNode noattr)) ::
                                              nil) tvoid cc_default))
          ((Eaddrof
             (Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeDisplayList noattr)))
                 (Tstruct _GraphNodeDisplayList noattr)) _node
               (Tstruct _GraphNode noattr))
             (tptr (Tstruct _GraphNode noattr))) :: nil))
        (Ssequence
          (Sset _t'2 (Evar _gGeoLayoutCommand (tptr tuchar)))
          (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
            (Ebinop Oadd (Etempvar _t'2 (tptr tuchar))
              (Ebinop Oshl (Econst_int (Int.repr 8) tint)
                (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                  (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))))))))
|}.

Definition f_geo_layout_cmd_node_shadow := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_graphNode, (tptr (Tstruct _GraphNodeShadow noattr))) ::
               (_shadowType, tuchar) :: (_shadowSolidity, tuchar) ::
               (_shadowScale, tshort) ::
               (_t'1, (tptr (Tstruct _GraphNodeShadow noattr))) ::
               (_t'9, tshort) :: (_t'8, (tptr tuchar)) :: (_t'7, tshort) ::
               (_t'6, (tptr tuchar)) :: (_t'5, tshort) ::
               (_t'4, (tptr tuchar)) ::
               (_t'3, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'2, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8 (Evar _gGeoLayoutCommand (tptr tuchar)))
    (Ssequence
      (Sset _t'9
        (Ederef
          (Ecast
            (Ebinop Oadd (Etempvar _t'8 (tptr tuchar))
              (Ebinop Oor
                (Ebinop Oand (Econst_int (Int.repr 2) tint)
                  (Econst_int (Int.repr 3) tint) tint)
                (Ebinop Oshl
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint) tint)
              (tptr tuchar)) (tptr tshort)) tshort))
      (Sset _shadowType (Ecast (Etempvar _t'9 tshort) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'6 (Evar _gGeoLayoutCommand (tptr tuchar)))
      (Ssequence
        (Sset _t'7
          (Ederef
            (Ecast
              (Ebinop Oadd (Etempvar _t'6 (tptr tuchar))
                (Ebinop Oor
                  (Ebinop Oand (Econst_int (Int.repr 4) tint)
                    (Econst_int (Int.repr 3) tint) tint)
                  (Ebinop Oshl
                    (Ebinop Oand (Econst_int (Int.repr 4) tint)
                      (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                      tint)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                (tptr tuchar)) (tptr tshort)) tshort))
        (Sset _shadowSolidity (Ecast (Etempvar _t'7 tshort) tuchar))))
    (Ssequence
      (Ssequence
        (Sset _t'4 (Evar _gGeoLayoutCommand (tptr tuchar)))
        (Ssequence
          (Sset _t'5
            (Ederef
              (Ecast
                (Ebinop Oadd (Etempvar _t'4 (tptr tuchar))
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 6) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 6) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (tptr tuchar)) (tptr tshort)) tshort))
          (Sset _shadowScale (Ecast (Etempvar _t'5 tshort) tshort))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'3
              (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr))))
            (Scall (Some _t'1)
              (Evar _init_graph_node_shadow (Tfunction
                                              ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                               (tptr (Tstruct _GraphNodeShadow noattr)) ::
                                               tshort :: tuchar :: tuchar ::
                                               nil)
                                              (tptr (Tstruct _GraphNodeShadow noattr))
                                              cc_default))
              ((Etempvar _t'3 (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
               (Etempvar _shadowScale tshort) ::
               (Etempvar _shadowSolidity tuchar) ::
               (Etempvar _shadowType tuchar) :: nil)))
          (Sset _graphNode
            (Etempvar _t'1 (tptr (Tstruct _GraphNodeShadow noattr)))))
        (Ssequence
          (Scall None
            (Evar _register_scene_graph_node (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                nil) tvoid cc_default))
            ((Eaddrof
               (Efield
                 (Ederef
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeShadow noattr)))
                   (Tstruct _GraphNodeShadow noattr)) _node
                 (Tstruct _GraphNode noattr))
               (tptr (Tstruct _GraphNode noattr))) :: nil))
          (Ssequence
            (Sset _t'2 (Evar _gGeoLayoutCommand (tptr tuchar)))
            (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
              (Ebinop Oadd (Etempvar _t'2 (tptr tuchar))
                (Ebinop Oshl (Econst_int (Int.repr 8) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint)
                (tptr tuchar)))))))))
|}.

Definition f_geo_layout_cmd_node_object_parent := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_graphNode, (tptr (Tstruct _GraphNodeObjectParent noattr))) ::
               (_t'1, (tptr (Tstruct _GraphNodeObjectParent noattr))) ::
               (_t'3, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'2, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr))))
      (Scall (Some _t'1)
        (Evar _init_graph_node_object_parent (Tfunction
                                               ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                (tptr (Tstruct _GraphNodeObjectParent noattr)) ::
                                                (tptr (Tstruct _GraphNode noattr)) ::
                                                nil)
                                               (tptr (Tstruct _GraphNodeObjectParent noattr))
                                               cc_default))
        ((Etempvar _t'3 (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
         (Eaddrof (Evar _gObjParentGraphNode (Tstruct _GraphNode noattr))
           (tptr (Tstruct _GraphNode noattr))) :: nil)))
    (Sset _graphNode
      (Etempvar _t'1 (tptr (Tstruct _GraphNodeObjectParent noattr)))))
  (Ssequence
    (Scall None
      (Evar _register_scene_graph_node (Tfunction
                                         ((tptr (Tstruct _GraphNode noattr)) ::
                                          nil) tvoid cc_default))
      ((Eaddrof
         (Efield
           (Ederef
             (Etempvar _graphNode (tptr (Tstruct _GraphNodeObjectParent noattr)))
             (Tstruct _GraphNodeObjectParent noattr)) _node
           (Tstruct _GraphNode noattr)) (tptr (Tstruct _GraphNode noattr))) ::
       nil))
    (Ssequence
      (Sset _t'2 (Evar _gGeoLayoutCommand (tptr tuchar)))
      (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
        (Ebinop Oadd (Etempvar _t'2 (tptr tuchar))
          (Ebinop Oshl (Econst_int (Int.repr 4) tint)
            (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
              (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))))))
|}.

Definition f_geo_layout_cmd_node_generated := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_graphNode, (tptr (Tstruct _GraphNodeGenerated noattr))) ::
               (_t'1, (tptr (Tstruct _GraphNodeGenerated noattr))) ::
               (_t'7, tshort) :: (_t'6, (tptr tuchar)) ::
               (_t'5, (tptr tvoid)) :: (_t'4, (tptr tuchar)) ::
               (_t'3, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'2, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr))))
      (Ssequence
        (Sset _t'4 (Evar _gGeoLayoutCommand (tptr tuchar)))
        (Ssequence
          (Sset _t'5
            (Ederef
              (Ecast
                (Ebinop Oadd (Etempvar _t'4 (tptr tuchar))
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 4) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 4) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (tptr tuchar)) (tptr (tptr tvoid))) (tptr tvoid)))
          (Ssequence
            (Sset _t'6 (Evar _gGeoLayoutCommand (tptr tuchar)))
            (Ssequence
              (Sset _t'7
                (Ederef
                  (Ecast
                    (Ebinop Oadd (Etempvar _t'6 (tptr tuchar))
                      (Ebinop Oor
                        (Ebinop Oand (Econst_int (Int.repr 2) tint)
                          (Econst_int (Int.repr 3) tint) tint)
                        (Ebinop Oshl
                          (Ebinop Oand (Econst_int (Int.repr 2) tint)
                            (Eunop Onotint (Econst_int (Int.repr 3) tint)
                              tint) tint)
                          (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                            (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                      (tptr tuchar)) (tptr tshort)) tshort))
              (Scall (Some _t'1)
                (Evar _init_graph_node_generated (Tfunction
                                                   ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                    (tptr (Tstruct _GraphNodeGenerated noattr)) ::
                                                    (tptr (Tfunction
                                                            (tint ::
                                                             (tptr (Tstruct _GraphNode noattr)) ::
                                                             (tptr tvoid) ::
                                                             nil)
                                                            (tptr (Tunion __512 noattr))
                                                            cc_default)) ::
                                                    tint :: nil)
                                                   (tptr (Tstruct _GraphNodeGenerated noattr))
                                                   cc_default))
                ((Etempvar _t'3 (tptr (Tstruct _AllocOnlyPool noattr))) ::
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
                 (Ecast (Etempvar _t'5 (tptr tvoid))
                   (tptr (Tfunction
                           (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                            (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                           cc_default))) :: (Etempvar _t'7 tshort) :: nil)))))))
    (Sset _graphNode
      (Etempvar _t'1 (tptr (Tstruct _GraphNodeGenerated noattr)))))
  (Ssequence
    (Scall None
      (Evar _register_scene_graph_node (Tfunction
                                         ((tptr (Tstruct _GraphNode noattr)) ::
                                          nil) tvoid cc_default))
      ((Eaddrof
         (Efield
           (Efield
             (Ederef
               (Etempvar _graphNode (tptr (Tstruct _GraphNodeGenerated noattr)))
               (Tstruct _GraphNodeGenerated noattr)) _fnNode
             (Tstruct _FnGraphNode noattr)) _node
           (Tstruct _GraphNode noattr)) (tptr (Tstruct _GraphNode noattr))) ::
       nil))
    (Ssequence
      (Sset _t'2 (Evar _gGeoLayoutCommand (tptr tuchar)))
      (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
        (Ebinop Oadd (Etempvar _t'2 (tptr tuchar))
          (Ebinop Oshl (Econst_int (Int.repr 8) tint)
            (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
              (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))))))
|}.

Definition f_geo_layout_cmd_node_background := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_graphNode, (tptr (Tstruct _GraphNodeBackground noattr))) ::
               (_t'1, (tptr (Tstruct _GraphNodeBackground noattr))) ::
               (_t'7, (tptr tvoid)) :: (_t'6, (tptr tuchar)) ::
               (_t'5, tshort) :: (_t'4, (tptr tuchar)) ::
               (_t'3, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'2, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr))))
      (Ssequence
        (Sset _t'4 (Evar _gGeoLayoutCommand (tptr tuchar)))
        (Ssequence
          (Sset _t'5
            (Ederef
              (Ecast
                (Ebinop Oadd (Etempvar _t'4 (tptr tuchar))
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 2) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 2) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (tptr tuchar)) (tptr tshort)) tshort))
          (Ssequence
            (Sset _t'6 (Evar _gGeoLayoutCommand (tptr tuchar)))
            (Ssequence
              (Sset _t'7
                (Ederef
                  (Ecast
                    (Ebinop Oadd (Etempvar _t'6 (tptr tuchar))
                      (Ebinop Oor
                        (Ebinop Oand (Econst_int (Int.repr 4) tint)
                          (Econst_int (Int.repr 3) tint) tint)
                        (Ebinop Oshl
                          (Ebinop Oand (Econst_int (Int.repr 4) tint)
                            (Eunop Onotint (Econst_int (Int.repr 3) tint)
                              tint) tint)
                          (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                            (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                      (tptr tuchar)) (tptr (tptr tvoid))) (tptr tvoid)))
              (Scall (Some _t'1)
                (Evar _init_graph_node_background (Tfunction
                                                    ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                     (tptr (Tstruct _GraphNodeBackground noattr)) ::
                                                     tushort ::
                                                     (tptr (Tfunction
                                                             (tint ::
                                                              (tptr (Tstruct _GraphNode noattr)) ::
                                                              (tptr tvoid) ::
                                                              nil)
                                                             (tptr (Tunion __512 noattr))
                                                             cc_default)) ::
                                                     tint :: nil)
                                                    (tptr (Tstruct _GraphNodeBackground noattr))
                                                    cc_default))
                ((Etempvar _t'3 (tptr (Tstruct _AllocOnlyPool noattr))) ::
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
                 (Etempvar _t'5 tshort) ::
                 (Ecast (Etempvar _t'7 (tptr tvoid))
                   (tptr (Tfunction
                           (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                            (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                           cc_default))) :: (Econst_int (Int.repr 0) tint) ::
                 nil)))))))
    (Sset _graphNode
      (Etempvar _t'1 (tptr (Tstruct _GraphNodeBackground noattr)))))
  (Ssequence
    (Scall None
      (Evar _register_scene_graph_node (Tfunction
                                         ((tptr (Tstruct _GraphNode noattr)) ::
                                          nil) tvoid cc_default))
      ((Eaddrof
         (Efield
           (Efield
             (Ederef
               (Etempvar _graphNode (tptr (Tstruct _GraphNodeBackground noattr)))
               (Tstruct _GraphNodeBackground noattr)) _fnNode
             (Tstruct _FnGraphNode noattr)) _node
           (Tstruct _GraphNode noattr)) (tptr (Tstruct _GraphNode noattr))) ::
       nil))
    (Ssequence
      (Sset _t'2 (Evar _gGeoLayoutCommand (tptr tuchar)))
      (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
        (Ebinop Oadd (Etempvar _t'2 (tptr tuchar))
          (Ebinop Oshl (Econst_int (Int.repr 8) tint)
            (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
              (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))))))
|}.

Definition f_geo_layout_cmd_nop := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _gGeoLayoutCommand (tptr tuchar)))
  (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
    (Ebinop Oadd (Etempvar _t'1 (tptr tuchar))
      (Ebinop Oshl (Econst_int (Int.repr 8) tint)
        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
          (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))))
|}.

Definition f_geo_layout_cmd_copy_view := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_graphNode, (tptr (Tstruct _GraphNodeObjectParent noattr))) ::
               (_node, (tptr (Tstruct _GraphNode noattr))) ::
               (_index, tshort) ::
               (_t'1, (tptr (Tstruct _GraphNodeObjectParent noattr))) ::
               (_t'7, tshort) :: (_t'6, (tptr tuchar)) ::
               (_t'5, (tptr (tptr (Tstruct _GraphNode noattr)))) ::
               (_t'4, tshort) ::
               (_t'3, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'2, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Sset _node (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Ssequence
      (Sset _t'6 (Evar _gGeoLayoutCommand (tptr tuchar)))
      (Ssequence
        (Sset _t'7
          (Ederef
            (Ecast
              (Ebinop Oadd (Etempvar _t'6 (tptr tuchar))
                (Ebinop Oor
                  (Ebinop Oand (Econst_int (Int.repr 2) tint)
                    (Econst_int (Int.repr 3) tint) tint)
                  (Ebinop Oshl
                    (Ebinop Oand (Econst_int (Int.repr 2) tint)
                      (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                      tint)
                    (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                      (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                (tptr tuchar)) (tptr tshort)) tshort))
        (Sset _index (Ecast (Etempvar _t'7 tshort) tshort))))
    (Ssequence
      (Sifthenelse (Ebinop Oge (Etempvar _index tshort)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'5
              (Evar _gGeoViews (tptr (tptr (Tstruct _GraphNode noattr)))))
            (Sset _node
              (Ederef
                (Ebinop Oadd
                  (Etempvar _t'5 (tptr (tptr (Tstruct _GraphNode noattr))))
                  (Etempvar _index tshort)
                  (tptr (tptr (Tstruct _GraphNode noattr))))
                (tptr (Tstruct _GraphNode noattr)))))
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
                  (Tstruct _GraphNode noattr)) _type tshort))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tshort)
                           (Econst_int (Int.repr 41) tint) tint)
              (Sset _node
                (Efield
                  (Ederef
                    (Ecast
                      (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
                      (tptr (Tstruct _GraphNodeObjectParent noattr)))
                    (Tstruct _GraphNodeObjectParent noattr)) _sharedChild
                  (tptr (Tstruct _GraphNode noattr))))
              (Sset _node
                (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))))
        Sskip)
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'3
              (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr))))
            (Scall (Some _t'1)
              (Evar _init_graph_node_object_parent (Tfunction
                                                     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                      (tptr (Tstruct _GraphNodeObjectParent noattr)) ::
                                                      (tptr (Tstruct _GraphNode noattr)) ::
                                                      nil)
                                                     (tptr (Tstruct _GraphNodeObjectParent noattr))
                                                     cc_default))
              ((Etempvar _t'3 (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
               (Etempvar _node (tptr (Tstruct _GraphNode noattr))) :: nil)))
          (Sset _graphNode
            (Etempvar _t'1 (tptr (Tstruct _GraphNodeObjectParent noattr)))))
        (Ssequence
          (Scall None
            (Evar _register_scene_graph_node (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                nil) tvoid cc_default))
            ((Eaddrof
               (Efield
                 (Ederef
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeObjectParent noattr)))
                   (Tstruct _GraphNodeObjectParent noattr)) _node
                 (Tstruct _GraphNode noattr))
               (tptr (Tstruct _GraphNode noattr))) :: nil))
          (Ssequence
            (Sset _t'2 (Evar _gGeoLayoutCommand (tptr tuchar)))
            (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
              (Ebinop Oadd (Etempvar _t'2 (tptr tuchar))
                (Ebinop Oshl (Econst_int (Int.repr 4) tint)
                  (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                    (Econst_int (Int.repr 3) tint) tuint) tint)
                (tptr tuchar)))))))))
|}.

Definition f_geo_layout_cmd_node_held_obj := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_offset, (tarray tshort 3)) :: nil);
  fn_temps := ((_graphNode, (tptr (Tstruct _GraphNodeHeldObject noattr))) ::
               (_t'1, (tptr (Tstruct _GraphNodeHeldObject noattr))) ::
               (_t'8, (tptr tuchar)) :: (_t'7, tuchar) ::
               (_t'6, (tptr tuchar)) :: (_t'5, (tptr tvoid)) ::
               (_t'4, (tptr tuchar)) ::
               (_t'3, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'2, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8 (Evar _gGeoLayoutCommand (tptr tuchar)))
    (Scall None
      (Evar _read_vec3s (Tfunction ((tptr tshort) :: (tptr tshort) :: nil)
                          (tptr tshort) cc_default))
      ((Evar _offset (tarray tshort 3)) ::
       (Ecast
         (Ebinop Oadd (Etempvar _t'8 (tptr tuchar))
           (Econst_int (Int.repr 2) tint) (tptr tuchar)) (tptr tshort)) ::
       nil)))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr))))
        (Ssequence
          (Sset _t'4 (Evar _gGeoLayoutCommand (tptr tuchar)))
          (Ssequence
            (Sset _t'5
              (Ederef
                (Ecast
                  (Ebinop Oadd (Etempvar _t'4 (tptr tuchar))
                    (Ebinop Oor
                      (Ebinop Oand (Econst_int (Int.repr 8) tint)
                        (Econst_int (Int.repr 3) tint) tint)
                      (Ebinop Oshl
                        (Ebinop Oand (Econst_int (Int.repr 8) tint)
                          (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                          tint)
                        (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                    (tptr tuchar)) (tptr (tptr tvoid))) (tptr tvoid)))
            (Ssequence
              (Sset _t'6 (Evar _gGeoLayoutCommand (tptr tuchar)))
              (Ssequence
                (Sset _t'7
                  (Ederef
                    (Ebinop Oadd (Etempvar _t'6 (tptr tuchar))
                      (Ebinop Oor
                        (Ebinop Oand (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 3) tint) tint)
                        (Ebinop Oshl
                          (Ebinop Oand (Econst_int (Int.repr 1) tint)
                            (Eunop Onotint (Econst_int (Int.repr 3) tint)
                              tint) tint)
                          (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                            (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                      (tptr tuchar)) tuchar))
                (Scall (Some _t'1)
                  (Evar _init_graph_node_held_object (Tfunction
                                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                        (tptr (Tstruct _GraphNodeHeldObject noattr)) ::
                                                        (tptr (Tstruct _Object noattr)) ::
                                                        (tptr tshort) ::
                                                        (tptr (Tfunction
                                                                (tint ::
                                                                 (tptr (Tstruct _GraphNode noattr)) ::
                                                                 (tptr tvoid) ::
                                                                 nil)
                                                                (tptr (Tunion __512 noattr))
                                                                cc_default)) ::
                                                        tint :: nil)
                                                       (tptr (Tstruct _GraphNodeHeldObject noattr))
                                                       cc_default))
                  ((Etempvar _t'3 (tptr (Tstruct _AllocOnlyPool noattr))) ::
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
                   (Evar _offset (tarray tshort 3)) ::
                   (Ecast (Etempvar _t'5 (tptr tvoid))
                     (tptr (Tfunction
                             (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                              (tptr tvoid) :: nil)
                             (tptr (Tunion __512 noattr)) cc_default))) ::
                   (Etempvar _t'7 tuchar) :: nil)))))))
      (Sset _graphNode
        (Etempvar _t'1 (tptr (Tstruct _GraphNodeHeldObject noattr)))))
    (Ssequence
      (Scall None
        (Evar _register_scene_graph_node (Tfunction
                                           ((tptr (Tstruct _GraphNode noattr)) ::
                                            nil) tvoid cc_default))
        ((Eaddrof
           (Efield
             (Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeHeldObject noattr)))
                 (Tstruct _GraphNodeHeldObject noattr)) _fnNode
               (Tstruct _FnGraphNode noattr)) _node
             (Tstruct _GraphNode noattr)) (tptr (Tstruct _GraphNode noattr))) ::
         nil))
      (Ssequence
        (Sset _t'2 (Evar _gGeoLayoutCommand (tptr tuchar)))
        (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
          (Ebinop Oadd (Etempvar _t'2 (tptr tuchar))
            (Ebinop Oshl (Econst_int (Int.repr 12) tint)
              (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar)))))))
|}.

Definition f_geo_layout_cmd_node_culling_radius := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_graphNode, (tptr (Tstruct _GraphNodeCullingRadius noattr))) ::
               (_t'1, (tptr (Tstruct _GraphNodeCullingRadius noattr))) ::
               (_t'5, tshort) :: (_t'4, (tptr tuchar)) ::
               (_t'3, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'2, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr))))
      (Ssequence
        (Sset _t'4 (Evar _gGeoLayoutCommand (tptr tuchar)))
        (Ssequence
          (Sset _t'5
            (Ederef
              (Ecast
                (Ebinop Oadd (Etempvar _t'4 (tptr tuchar))
                  (Ebinop Oor
                    (Ebinop Oand (Econst_int (Int.repr 2) tint)
                      (Econst_int (Int.repr 3) tint) tint)
                    (Ebinop Oshl
                      (Ebinop Oand (Econst_int (Int.repr 2) tint)
                        (Eunop Onotint (Econst_int (Int.repr 3) tint) tint)
                        tint)
                      (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
                        (Econst_int (Int.repr 3) tint) tuint) tint) tint)
                  (tptr tuchar)) (tptr tshort)) tshort))
          (Scall (Some _t'1)
            (Evar _init_graph_node_culling_radius (Tfunction
                                                    ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                                     (tptr (Tstruct _GraphNodeCullingRadius noattr)) ::
                                                     tshort :: nil)
                                                    (tptr (Tstruct _GraphNodeCullingRadius noattr))
                                                    cc_default))
            ((Etempvar _t'3 (tptr (Tstruct _AllocOnlyPool noattr))) ::
             (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
             (Etempvar _t'5 tshort) :: nil)))))
    (Sset _graphNode
      (Etempvar _t'1 (tptr (Tstruct _GraphNodeCullingRadius noattr)))))
  (Ssequence
    (Scall None
      (Evar _register_scene_graph_node (Tfunction
                                         ((tptr (Tstruct _GraphNode noattr)) ::
                                          nil) tvoid cc_default))
      ((Eaddrof
         (Efield
           (Ederef
             (Etempvar _graphNode (tptr (Tstruct _GraphNodeCullingRadius noattr)))
             (Tstruct _GraphNodeCullingRadius noattr)) _node
           (Tstruct _GraphNode noattr)) (tptr (Tstruct _GraphNode noattr))) ::
       nil))
    (Ssequence
      (Sset _t'2 (Evar _gGeoLayoutCommand (tptr tuchar)))
      (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
        (Ebinop Oadd (Etempvar _t'2 (tptr tuchar))
          (Ebinop Oshl (Econst_int (Int.repr 4) tint)
            (Ebinop Oshr (Esizeof (tptr tvoid) tuint)
              (Econst_int (Int.repr 3) tint) tuint) tint) (tptr tuchar))))))
|}.

Definition f_process_geo_layout := {|
  fn_return := (tptr (Tstruct _GraphNode noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_segptr, (tptr tvoid)) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: (_t'6, (tptr tuchar)) ::
               (_t'5, (tptr (Tfunction nil tvoid cc_default))) ::
               (_t'4, tuchar) :: (_t'3, (tptr tuchar)) ::
               (_t'2, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _gCurRootGraphNode (tptr (Tstruct _GraphNode noattr)))
    (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Sassign (Evar _gGeoNumViews tushort) (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Evar _gCurGraphNodeList (tarray (tptr (Tstruct _GraphNode noattr)) 32))
            (Econst_int (Int.repr 0) tint)
            (tptr (tptr (Tstruct _GraphNode noattr))))
          (tptr (Tstruct _GraphNode noattr))) (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Sassign (Evar _gCurGraphNodeIndex tshort)
          (Econst_int (Int.repr 0) tint))
        (Ssequence
          (Sassign (Evar _gGeoLayoutStackIndex tshort)
            (Econst_int (Int.repr 2) tint))
          (Ssequence
            (Sassign (Evar _gGeoLayoutReturnIndex tshort)
              (Econst_int (Int.repr 2) tint))
            (Ssequence
              (Ssequence
                (Scall (Some _t'1)
                  (Evar _segmented_to_virtual (Tfunction
                                                ((tptr tvoid) :: nil)
                                                (tptr tvoid) cc_default))
                  ((Etempvar _segptr (tptr tvoid)) :: nil))
                (Sassign (Evar _gGeoLayoutCommand (tptr tuchar))
                  (Etempvar _t'1 (tptr tvoid))))
              (Ssequence
                (Sassign
                  (Evar _gGraphNodePool (tptr (Tstruct _AllocOnlyPool noattr)))
                  (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))))
                (Ssequence
                  (Sassign
                    (Ederef
                      (Ebinop Oadd (Evar _gGeoLayoutStack (tarray tuint 16))
                        (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint)
                    (Econst_int (Int.repr 0) tint))
                  (Ssequence
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Evar _gGeoLayoutStack (tarray tuint 16))
                          (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint)
                      (Econst_int (Int.repr 0) tint))
                    (Ssequence
                      (Sloop
                        (Ssequence
                          (Ssequence
                            (Sset _t'6
                              (Evar _gGeoLayoutCommand (tptr tuchar)))
                            (Sifthenelse (Ebinop One
                                           (Etempvar _t'6 (tptr tuchar))
                                           (Ecast
                                             (Econst_int (Int.repr 0) tint)
                                             (tptr tvoid)) tint)
                              Sskip
                              Sbreak))
                          (Ssequence
                            (Sset _t'3
                              (Evar _gGeoLayoutCommand (tptr tuchar)))
                            (Ssequence
                              (Sset _t'4
                                (Ederef
                                  (Ebinop Oadd (Etempvar _t'3 (tptr tuchar))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr tuchar)) tuchar))
                              (Ssequence
                                (Sset _t'5
                                  (Ederef
                                    (Ebinop Oadd
                                      (Evar _GeoLayoutJumpTable (tarray (tptr
                                      (Tfunction nil tvoid cc_default)) 33))
                                      (Etempvar _t'4 tuchar)
                                      (tptr (tptr (Tfunction nil tvoid
                                                    cc_default))))
                                    (tptr (Tfunction nil tvoid cc_default))))
                                (Scall None
                                  (Etempvar _t'5 (tptr (Tfunction nil tvoid
                                                         cc_default))) nil)))))
                        Sskip)
                      (Ssequence
                        (Sset _t'2
                          (Evar _gCurRootGraphNode (tptr (Tstruct _GraphNode noattr))))
                        (Sreturn (Some (Etempvar _t'2 (tptr (Tstruct _GraphNode noattr)))))))))))))))))
|}.

Definition composites : list composite_definition :=
(Composite __472 Union
   (Member_plain _m (tarray (tarray tint 4) 4) ::
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
 Composite _GraphNodeStart Struct
   (Member_plain _node (Tstruct _GraphNode noattr) :: nil)
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
 Composite __1299 Union
   (Member_plain _mode tint ::
    Member_plain _camera (tptr (Tstruct _Camera noattr)) :: nil)
   noattr ::
 Composite _GraphNodeCamera Struct
   (Member_plain _fnNode (Tstruct _FnGraphNode noattr) ::
    Member_plain _config (Tunion __1299 noattr) ::
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
 (_segmented_to_virtual,
   Gfun(External (EF_external "segmented_to_virtual"
                   (mksignature (AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr tvoid) :: nil) (tptr tvoid) cc_default)) ::
 (_alloc_only_pool_alloc,
   Gfun(External (EF_external "alloc_only_pool_alloc"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xptr
                     cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) :: tint :: nil) (tptr tvoid)
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
     cc_default)) :: (_gVec3sZero, Gvar v_gVec3sZero) ::
 (_init_graph_node_root,
   Gfun(External (EF_external "init_graph_node_root"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xint16signed ::
                      AST.Xint16signed :: AST.Xint16signed ::
                      AST.Xint16signed :: AST.Xint16signed :: nil) AST.Xptr
                     cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeRoot noattr)) :: tshort :: tshort :: tshort ::
      tshort :: tshort :: nil) (tptr (Tstruct _GraphNodeRoot noattr))
     cc_default)) ::
 (_init_graph_node_ortho_projection,
   Gfun(External (EF_external "init_graph_node_ortho_projection"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xsingle :: nil)
                     AST.Xptr cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeOrthoProjection noattr)) :: tfloat :: nil)
     (tptr (Tstruct _GraphNodeOrthoProjection noattr)) cc_default)) ::
 (_init_graph_node_perspective,
   Gfun(External (EF_external "init_graph_node_perspective"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xsingle ::
                      AST.Xint16signed :: AST.Xint16signed :: AST.Xptr ::
                      AST.Xint :: nil) AST.Xptr cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodePerspective noattr)) :: tfloat :: tshort ::
      tshort ::
      (tptr (Tfunction
              (tint :: (tptr (Tstruct _GraphNode noattr)) :: (tptr tvoid) ::
               nil) (tptr (Tunion __512 noattr)) cc_default)) :: tint :: nil)
     (tptr (Tstruct _GraphNodePerspective noattr)) cc_default)) ::
 (_init_graph_node_start,
   Gfun(External (EF_external "init_graph_node_start"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xptr
                     cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeStart noattr)) :: nil)
     (tptr (Tstruct _GraphNodeStart noattr)) cc_default)) ::
 (_init_graph_node_master_list,
   Gfun(External (EF_external "init_graph_node_master_list"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xint16signed :: nil)
                     AST.Xptr cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeMasterList noattr)) :: tshort :: nil)
     (tptr (Tstruct _GraphNodeMasterList noattr)) cc_default)) ::
 (_init_graph_node_render_range,
   Gfun(External (EF_external "init_graph_node_render_range"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xint16signed ::
                      AST.Xint16signed :: nil) AST.Xptr cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeLevelOfDetail noattr)) :: tshort :: tshort ::
      nil) (tptr (Tstruct _GraphNodeLevelOfDetail noattr)) cc_default)) ::
 (_init_graph_node_switch_case,
   Gfun(External (EF_external "init_graph_node_switch_case"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xint16signed ::
                      AST.Xint16signed :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xptr cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeSwitchCase noattr)) :: tshort :: tshort ::
      (tptr (Tfunction
              (tint :: (tptr (Tstruct _GraphNode noattr)) :: (tptr tvoid) ::
               nil) (tptr (Tunion __512 noattr)) cc_default)) :: tint :: nil)
     (tptr (Tstruct _GraphNodeSwitchCase noattr)) cc_default)) ::
 (_init_graph_node_camera,
   Gfun(External (EF_external "init_graph_node_camera"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xptr :: AST.Xptr ::
                      AST.Xptr :: AST.Xint :: nil) AST.Xptr cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeCamera noattr)) :: (tptr tfloat) ::
      (tptr tfloat) ::
      (tptr (Tfunction
              (tint :: (tptr (Tstruct _GraphNode noattr)) :: (tptr tvoid) ::
               nil) (tptr (Tunion __512 noattr)) cc_default)) :: tint :: nil)
     (tptr (Tstruct _GraphNodeCamera noattr)) cc_default)) ::
 (_init_graph_node_translation_rotation,
   Gfun(External (EF_external "init_graph_node_translation_rotation"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xint :: AST.Xptr ::
                      AST.Xptr :: AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeTranslationRotation noattr)) :: tint ::
      (tptr tvoid) :: (tptr tshort) :: (tptr tshort) :: nil)
     (tptr (Tstruct _GraphNodeTranslationRotation noattr)) cc_default)) ::
 (_init_graph_node_translation,
   Gfun(External (EF_external "init_graph_node_translation"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xint :: AST.Xptr ::
                      AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeTranslation noattr)) :: tint ::
      (tptr tvoid) :: (tptr tshort) :: nil)
     (tptr (Tstruct _GraphNodeTranslation noattr)) cc_default)) ::
 (_init_graph_node_rotation,
   Gfun(External (EF_external "init_graph_node_rotation"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xint :: AST.Xptr ::
                      AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeRotation noattr)) :: tint :: (tptr tvoid) ::
      (tptr tshort) :: nil) (tptr (Tstruct _GraphNodeRotation noattr))
     cc_default)) ::
 (_init_graph_node_scale,
   Gfun(External (EF_external "init_graph_node_scale"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xint :: AST.Xptr ::
                      AST.Xsingle :: nil) AST.Xptr cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeScale noattr)) :: tint :: (tptr tvoid) ::
      tfloat :: nil) (tptr (Tstruct _GraphNodeScale noattr)) cc_default)) ::
 (_init_graph_node_culling_radius,
   Gfun(External (EF_external "init_graph_node_culling_radius"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xint16signed :: nil)
                     AST.Xptr cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeCullingRadius noattr)) :: tshort :: nil)
     (tptr (Tstruct _GraphNodeCullingRadius noattr)) cc_default)) ::
 (_init_graph_node_animated_part,
   Gfun(External (EF_external "init_graph_node_animated_part"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xint :: AST.Xptr ::
                      AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeAnimatedPart noattr)) :: tint ::
      (tptr tvoid) :: (tptr tshort) :: nil)
     (tptr (Tstruct _GraphNodeAnimatedPart noattr)) cc_default)) ::
 (_init_graph_node_billboard,
   Gfun(External (EF_external "init_graph_node_billboard"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xint :: AST.Xptr ::
                      AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeBillboard noattr)) :: tint :: (tptr tvoid) ::
      (tptr tshort) :: nil) (tptr (Tstruct _GraphNodeBillboard noattr))
     cc_default)) ::
 (_init_graph_node_display_list,
   Gfun(External (EF_external "init_graph_node_display_list"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xint :: AST.Xptr :: nil)
                     AST.Xptr cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeDisplayList noattr)) :: tint ::
      (tptr tvoid) :: nil) (tptr (Tstruct _GraphNodeDisplayList noattr))
     cc_default)) ::
 (_init_graph_node_shadow,
   Gfun(External (EF_external "init_graph_node_shadow"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xint16signed ::
                      AST.Xint8unsigned :: AST.Xint8unsigned :: nil) AST.Xptr
                     cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeShadow noattr)) :: tshort :: tuchar ::
      tuchar :: nil) (tptr (Tstruct _GraphNodeShadow noattr)) cc_default)) ::
 (_init_graph_node_object_parent,
   Gfun(External (EF_external "init_graph_node_object_parent"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xptr cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeObjectParent noattr)) ::
      (tptr (Tstruct _GraphNode noattr)) :: nil)
     (tptr (Tstruct _GraphNodeObjectParent noattr)) cc_default)) ::
 (_init_graph_node_generated,
   Gfun(External (EF_external "init_graph_node_generated"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xptr cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeGenerated noattr)) ::
      (tptr (Tfunction
              (tint :: (tptr (Tstruct _GraphNode noattr)) :: (tptr tvoid) ::
               nil) (tptr (Tunion __512 noattr)) cc_default)) :: tint :: nil)
     (tptr (Tstruct _GraphNodeGenerated noattr)) cc_default)) ::
 (_init_graph_node_background,
   Gfun(External (EF_external "init_graph_node_background"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xint16unsigned ::
                      AST.Xptr :: AST.Xint :: nil) AST.Xptr cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeBackground noattr)) :: tushort ::
      (tptr (Tfunction
              (tint :: (tptr (Tstruct _GraphNode noattr)) :: (tptr tvoid) ::
               nil) (tptr (Tunion __512 noattr)) cc_default)) :: tint :: nil)
     (tptr (Tstruct _GraphNodeBackground noattr)) cc_default)) ::
 (_init_graph_node_held_object,
   Gfun(External (EF_external "init_graph_node_held_object"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xptr :: AST.Xptr ::
                      AST.Xptr :: AST.Xint :: nil) AST.Xptr cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) ::
      (tptr (Tstruct _GraphNodeHeldObject noattr)) ::
      (tptr (Tstruct _Object noattr)) :: (tptr tshort) ::
      (tptr (Tfunction
              (tint :: (tptr (Tstruct _GraphNode noattr)) :: (tptr tvoid) ::
               nil) (tptr (Tunion __512 noattr)) cc_default)) :: tint :: nil)
     (tptr (Tstruct _GraphNodeHeldObject noattr)) cc_default)) ::
 (_read_vec3s_to_vec3f,
   Gfun(External (EF_external "read_vec3s_to_vec3f"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xptr
                     cc_default)) ((tptr tfloat) :: (tptr tshort) :: nil)
     (tptr tshort) cc_default)) ::
 (_read_vec3s,
   Gfun(External (EF_external "read_vec3s"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xptr
                     cc_default)) ((tptr tshort) :: (tptr tshort) :: nil)
     (tptr tshort) cc_default)) ::
 (_read_vec3s_angle,
   Gfun(External (EF_external "read_vec3s_angle"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xptr
                     cc_default)) ((tptr tshort) :: (tptr tshort) :: nil)
     (tptr tshort) cc_default)) ::
 (_register_scene_graph_node,
   Gfun(External (EF_external "register_scene_graph_node"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _GraphNode noattr)) :: nil) tvoid cc_default)) ::
 (_GeoLayoutJumpTable, Gvar v_GeoLayoutJumpTable) ::
 (_gObjParentGraphNode, Gvar v_gObjParentGraphNode) ::
 (_gGraphNodePool, Gvar v_gGraphNodePool) ::
 (_gCurRootGraphNode, Gvar v_gCurRootGraphNode) ::
 (_D_8038BCA8, Gvar v_D_8038BCA8) :: (_gGeoViews, Gvar v_gGeoViews) ::
 (_gGeoNumViews, Gvar v_gGeoNumViews) ::
 (_gGeoLayoutStack, Gvar v_gGeoLayoutStack) ::
 (_gCurGraphNodeList, Gvar v_gCurGraphNodeList) ::
 (_gCurGraphNodeIndex, Gvar v_gCurGraphNodeIndex) ::
 (_gGeoLayoutStackIndex, Gvar v_gGeoLayoutStackIndex) ::
 (_D_8038BD7C, Gvar v_D_8038BD7C) ::
 (_gGeoLayoutReturnIndex, Gvar v_gGeoLayoutReturnIndex) ::
 (_gGeoLayoutCommand, Gvar v_gGeoLayoutCommand) ::
 (_unused_8038B894, Gvar v_unused_8038B894) ::
 (_geo_layout_cmd_branch_and_link, Gfun(Internal f_geo_layout_cmd_branch_and_link)) ::
 (_geo_layout_cmd_end, Gfun(Internal f_geo_layout_cmd_end)) ::
 (_geo_layout_cmd_branch, Gfun(Internal f_geo_layout_cmd_branch)) ::
 (_geo_layout_cmd_return, Gfun(Internal f_geo_layout_cmd_return)) ::
 (_geo_layout_cmd_open_node, Gfun(Internal f_geo_layout_cmd_open_node)) ::
 (_geo_layout_cmd_close_node, Gfun(Internal f_geo_layout_cmd_close_node)) ::
 (_geo_layout_cmd_assign_as_view, Gfun(Internal f_geo_layout_cmd_assign_as_view)) ::
 (_geo_layout_cmd_update_node_flags, Gfun(Internal f_geo_layout_cmd_update_node_flags)) ::
 (_geo_layout_cmd_node_root, Gfun(Internal f_geo_layout_cmd_node_root)) ::
 (_geo_layout_cmd_node_ortho_projection, Gfun(Internal f_geo_layout_cmd_node_ortho_projection)) ::
 (_geo_layout_cmd_node_perspective, Gfun(Internal f_geo_layout_cmd_node_perspective)) ::
 (_geo_layout_cmd_node_start, Gfun(Internal f_geo_layout_cmd_node_start)) ::
 (_geo_layout_cmd_nop3, Gfun(Internal f_geo_layout_cmd_nop3)) ::
 (_geo_layout_cmd_node_master_list, Gfun(Internal f_geo_layout_cmd_node_master_list)) ::
 (_geo_layout_cmd_node_level_of_detail, Gfun(Internal f_geo_layout_cmd_node_level_of_detail)) ::
 (_geo_layout_cmd_node_switch_case, Gfun(Internal f_geo_layout_cmd_node_switch_case)) ::
 (_geo_layout_cmd_node_camera, Gfun(Internal f_geo_layout_cmd_node_camera)) ::
 (_geo_layout_cmd_node_translation_rotation, Gfun(Internal f_geo_layout_cmd_node_translation_rotation)) ::
 (_geo_layout_cmd_node_translation, Gfun(Internal f_geo_layout_cmd_node_translation)) ::
 (_geo_layout_cmd_node_rotation, Gfun(Internal f_geo_layout_cmd_node_rotation)) ::
 (_geo_layout_cmd_node_scale, Gfun(Internal f_geo_layout_cmd_node_scale)) ::
 (_geo_layout_cmd_nop2, Gfun(Internal f_geo_layout_cmd_nop2)) ::
 (_geo_layout_cmd_node_animated_part, Gfun(Internal f_geo_layout_cmd_node_animated_part)) ::
 (_geo_layout_cmd_node_billboard, Gfun(Internal f_geo_layout_cmd_node_billboard)) ::
 (_geo_layout_cmd_node_display_list, Gfun(Internal f_geo_layout_cmd_node_display_list)) ::
 (_geo_layout_cmd_node_shadow, Gfun(Internal f_geo_layout_cmd_node_shadow)) ::
 (_geo_layout_cmd_node_object_parent, Gfun(Internal f_geo_layout_cmd_node_object_parent)) ::
 (_geo_layout_cmd_node_generated, Gfun(Internal f_geo_layout_cmd_node_generated)) ::
 (_geo_layout_cmd_node_background, Gfun(Internal f_geo_layout_cmd_node_background)) ::
 (_geo_layout_cmd_nop, Gfun(Internal f_geo_layout_cmd_nop)) ::
 (_geo_layout_cmd_copy_view, Gfun(Internal f_geo_layout_cmd_copy_view)) ::
 (_geo_layout_cmd_node_held_obj, Gfun(Internal f_geo_layout_cmd_node_held_obj)) ::
 (_geo_layout_cmd_node_culling_radius, Gfun(Internal f_geo_layout_cmd_node_culling_radius)) ::
 (_process_geo_layout, Gfun(Internal f_process_geo_layout)) :: nil).

Definition public_idents : list ident :=
(_process_geo_layout :: _geo_layout_cmd_node_culling_radius ::
 _geo_layout_cmd_node_held_obj :: _geo_layout_cmd_copy_view ::
 _geo_layout_cmd_nop :: _geo_layout_cmd_node_background ::
 _geo_layout_cmd_node_generated :: _geo_layout_cmd_node_object_parent ::
 _geo_layout_cmd_node_shadow :: _geo_layout_cmd_node_display_list ::
 _geo_layout_cmd_node_billboard :: _geo_layout_cmd_node_animated_part ::
 _geo_layout_cmd_nop2 :: _geo_layout_cmd_node_scale ::
 _geo_layout_cmd_node_rotation :: _geo_layout_cmd_node_translation ::
 _geo_layout_cmd_node_translation_rotation :: _geo_layout_cmd_node_camera ::
 _geo_layout_cmd_node_switch_case :: _geo_layout_cmd_node_level_of_detail ::
 _geo_layout_cmd_node_master_list :: _geo_layout_cmd_nop3 ::
 _geo_layout_cmd_node_start :: _geo_layout_cmd_node_perspective ::
 _geo_layout_cmd_node_ortho_projection :: _geo_layout_cmd_node_root ::
 _geo_layout_cmd_update_node_flags :: _geo_layout_cmd_assign_as_view ::
 _geo_layout_cmd_close_node :: _geo_layout_cmd_open_node ::
 _geo_layout_cmd_return :: _geo_layout_cmd_branch :: _geo_layout_cmd_end ::
 _geo_layout_cmd_branch_and_link :: _unused_8038B894 :: _gGeoLayoutCommand ::
 _gGeoLayoutReturnIndex :: _D_8038BD7C :: _gGeoLayoutStackIndex ::
 _gCurGraphNodeIndex :: _gCurGraphNodeList :: _gGeoLayoutStack ::
 _gGeoNumViews :: _gGeoViews :: _D_8038BCA8 :: _gCurRootGraphNode ::
 _gGraphNodePool :: _gObjParentGraphNode :: _GeoLayoutJumpTable ::
 _register_scene_graph_node :: _read_vec3s_angle :: _read_vec3s ::
 _read_vec3s_to_vec3f :: _init_graph_node_held_object ::
 _init_graph_node_background :: _init_graph_node_generated ::
 _init_graph_node_object_parent :: _init_graph_node_shadow ::
 _init_graph_node_display_list :: _init_graph_node_billboard ::
 _init_graph_node_animated_part :: _init_graph_node_culling_radius ::
 _init_graph_node_scale :: _init_graph_node_rotation ::
 _init_graph_node_translation :: _init_graph_node_translation_rotation ::
 _init_graph_node_camera :: _init_graph_node_switch_case ::
 _init_graph_node_render_range :: _init_graph_node_master_list ::
 _init_graph_node_start :: _init_graph_node_perspective ::
 _init_graph_node_ortho_projection :: _init_graph_node_root :: _gVec3sZero ::
 _vec3s_set :: _vec3s_copy :: _alloc_only_pool_alloc ::
 _segmented_to_virtual :: ___builtin_debug ::
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
