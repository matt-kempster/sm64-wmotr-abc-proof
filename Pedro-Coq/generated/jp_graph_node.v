(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_JP
   Source:          src/engine/graph_node.c
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_JP=1 -DF3D_OLD=1
   Link hygiene:    private __stringlit_N atoms prefixed with jp_graph_node
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
  Definition source_file := "build/pinned-sm64/src/engine/graph_node.c".
  Definition normalized := true.
End Info.

Definition _AllocOnlyPool : ident := $"AllocOnlyPool".
Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _Camera : ident := $"Camera".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _DisplayListNode : ident := $"DisplayListNode".
Definition _FnGraphNode : ident := $"FnGraphNode".
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
Definition __1341 : ident := $"_1341".
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
Definition _accelAssist : ident := $"accelAssist".
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _alloc_only_pool_alloc : ident := $"alloc_only_pool_alloc".
Definition _angle : ident := $"angle".
Definition _anim : ident := $"anim".
Definition _animAccel : ident := $"animAccel".
Definition _animFrame : ident := $"animFrame".
Definition _animFrameAccelAssist : ident := $"animFrameAccelAssist".
Definition _animID : ident := $"animID".
Definition _animInfo : ident := $"animInfo".
Definition _animPtrAddr : ident := $"animPtrAddr".
Definition _animSegmented : ident := $"animSegmented".
Definition _animTimer : ident := $"animTimer".
Definition _animYTrans : ident := $"animYTrans".
Definition _animYTransDivisor : ident := $"animYTransDivisor".
Definition _animation : ident := $"animation".
Definition _areaCenX : ident := $"areaCenX".
Definition _areaCenY : ident := $"areaCenY".
Definition _areaCenZ : ident := $"areaCenZ".
Definition _areaIndex : ident := $"areaIndex".
Definition _asAnims : ident := $"asAnims".
Definition _asChainSegment : ident := $"asChainSegment".
Definition _asConstVoidPtr : ident := $"asConstVoidPtr".
Definition _asF32 : ident := $"asF32".
Definition _asFnNode : ident := $"asFnNode".
Definition _asObject : ident := $"asObject".
Definition _asS16 : ident := $"asS16".
Definition _asS16P : ident := $"asS16P".
Definition _asS32 : ident := $"asS32".
Definition _asS32P : ident := $"asS32P".
Definition _asSurface : ident := $"asSurface".
Definition _asU32 : ident := $"asU32".
Definition _asVoidPtr : ident := $"asVoidPtr".
Definition _asWaypoint : ident := $"asWaypoint".
Definition _attribute : ident := $"attribute".
Definition _attributes : ident := $"attributes".
Definition _background : ident := $"background".
Definition _backgroundFunc : ident := $"backgroundFunc".
Definition _behavior : ident := $"behavior".
Definition _behaviorArg : ident := $"behaviorArg".
Definition _behaviorScript : ident := $"behaviorScript".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _callContext : ident := $"callContext".
Definition _camera : ident := $"camera".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _childNode : ident := $"childNode".
Definition _children : ident := $"children".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _config : ident := $"config".
Definition _cullingRadius : ident := $"cullingRadius".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _curNode : ident := $"curNode".
Definition _cutscene : ident := $"cutscene".
Definition _defMode : ident := $"defMode".
Definition _displayList : ident := $"displayList".
Definition _doorStatus : ident := $"doorStatus".
Definition _drawingLayer : ident := $"drawingLayer".
Definition _far : ident := $"far".
Definition _filler : ident := $"filler".
Definition _filler1 : ident := $"filler1".
Definition _filler2 : ident := $"filler2".
Definition _firstChild : ident := $"firstChild".
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
Definition _gCurGraphNodeMasterList : ident := $"gCurGraphNodeMasterList".
Definition _gCurGraphNodeObject : ident := $"gCurGraphNodeObject".
Definition _gCurGraphNodeRoot : ident := $"gCurGraphNodeRoot".
Definition _gObjParentGraphNode : ident := $"gObjParentGraphNode".
Definition _gVec3fOne : ident := $"gVec3fOne".
Definition _gVec3fZero : ident := $"gVec3fZero".
Definition _gVec3sOne : ident := $"gVec3sOne".
Definition _gVec3sZero : ident := $"gVec3sZero".
Definition _geo_add_child : ident := $"geo_add_child".
Definition _geo_call_global_function_nodes : ident := $"geo_call_global_function_nodes".
Definition _geo_call_global_function_nodes_helper : ident := $"geo_call_global_function_nodes_helper".
Definition _geo_find_root : ident := $"geo_find_root".
Definition _geo_make_first_child : ident := $"geo_make_first_child".
Definition _geo_obj_init : ident := $"geo_obj_init".
Definition _geo_obj_init_animation : ident := $"geo_obj_init_animation".
Definition _geo_obj_init_animation_accel : ident := $"geo_obj_init_animation_accel".
Definition _geo_obj_init_spawninfo : ident := $"geo_obj_init_spawninfo".
Definition _geo_remove_child : ident := $"geo_remove_child".
Definition _geo_reset_object_node : ident := $"geo_reset_object_node".
Definition _geo_retreive_animation_translation : ident := $"geo_retreive_animation_translation".
Definition _geo_update_animation_frame : ident := $"geo_update_animation_frame".
Definition _gfx : ident := $"gfx".
Definition _gfxFunc : ident := $"gfxFunc".
Definition _globalPtr : ident := $"globalPtr".
Definition _graphNode : ident := $"graphNode".
Definition _header : ident := $"header".
Definition _height : ident := $"height".
Definition _hitboxDownOffset : ident := $"hitboxDownOffset".
Definition _hitboxHeight : ident := $"hitboxHeight".
Definition _hitboxRadius : ident := $"hitboxRadius".
Definition _hurtboxHeight : ident := $"hurtboxHeight".
Definition _hurtboxRadius : ident := $"hurtboxRadius".
Definition _identityMtx : ident := $"identityMtx".
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
Definition _init_graph_node_object : ident := $"init_graph_node_object".
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
Definition _init_scene_graph_node_links : ident := $"init_scene_graph_node_links".
Definition _lastSibling : ident := $"lastSibling".
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
Definition _model : ident := $"model".
Definition _near : ident := $"near".
Definition _newFirstChild : ident := $"newFirstChild".
Definition _next : ident := $"next".
Definition _nextYaw : ident := $"nextYaw".
Definition _node : ident := $"node".
Definition _nodeFunc : ident := $"nodeFunc".
Definition _normal : ident := $"normal".
Definition _numCases : ident := $"numCases".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _numViews : ident := $"numViews".
Definition _obj : ident := $"obj".
Definition _objNode : ident := $"objNode".
Definition _object : ident := $"object".
Definition _on : ident := $"on".
Definition _originOffset : ident := $"originOffset".
Definition _parameter : ident := $"parameter".
Definition _parent : ident := $"parent".
Definition _parentFirstChild : ident := $"parentFirstChild".
Definition _parentLastChild : ident := $"parentLastChild".
Definition _parentObj : ident := $"parentObj".
Definition _platform : ident := $"platform".
Definition _playerIndex : ident := $"playerIndex".
Definition _pool : ident := $"pool".
Definition _pos : ident := $"pos".
Definition _position : ident := $"position".
Definition _prev : ident := $"prev".
Definition _prevObj : ident := $"prevObj".
Definition _radius : ident := $"radius".
Definition _rawData : ident := $"rawData".
Definition _resGraphNode : ident := $"resGraphNode".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _result : ident := $"result".
Definition _retrieve_animation_index : ident := $"retrieve_animation_index".
Definition _roll : ident := $"roll".
Definition _rollScreen : ident := $"rollScreen".
Definition _room : ident := $"room".
Definition _rotation : ident := $"rotation".
Definition _scale : ident := $"scale".
Definition _segmented_to_virtual : ident := $"segmented_to_virtual".
Definition _selectedCase : ident := $"selectedCase".
Definition _shadowScale : ident := $"shadowScale".
Definition _shadowSolidity : ident := $"shadowSolidity".
Definition _shadowType : ident := $"shadowType".
Definition _sharedChild : ident := $"sharedChild".
Definition _spawn : ident := $"spawn".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
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
Definition _unusedVec1 : ident := $"unusedVec1".
Definition _upperY : ident := $"upperY".
Definition _usedSpace : ident := $"usedSpace".
Definition _values : ident := $"values".
Definition _vec3f_copy : ident := $"vec3f_copy".
Definition _vec3f_set : ident := $"vec3f_set".
Definition _vec3s_copy : ident := $"vec3s_copy".
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
Definition _yaw : ident := $"yaw".
Definition _z : ident := $"z".
Definition _zero : ident := $"zero".
Definition _zeroMtx : ident := $"zeroMtx".
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
Definition _t'3 : ident := 130%positive.
Definition _t'4 : ident := 131%positive.
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v_gCurGraphNodeRoot := {|
  gvar_info := (tptr (Tstruct _GraphNodeRoot noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurGraphNodeMasterList := {|
  gvar_info := (tptr (Tstruct _GraphNodeMasterList noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurGraphNodeCamFrustum := {|
  gvar_info := (tptr (Tstruct _GraphNodePerspective noattr));
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

Definition v_gObjParentGraphNode := {|
  gvar_info := (Tstruct _GraphNode noattr);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_identityMtx := {|
  gvar_info := (tarray (tarray tshort 4) 4);
  gvar_init := (Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 1) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 1) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_zeroMtx := {|
  gvar_info := (tarray (tarray tshort 4) 4);
  gvar_init := (Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gVec3fZero := {|
  gvar_info := (tarray tfloat 3);
  gvar_init := (Init_float32 (Float32.of_bits (Int.repr 0)) ::
                Init_float32 (Float32.of_bits (Int.repr 0)) ::
                Init_float32 (Float32.of_bits (Int.repr 0)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gVec3sZero := {|
  gvar_info := (tarray tshort 3);
  gvar_init := (Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gVec3fOne := {|
  gvar_info := (tarray tfloat 3);
  gvar_init := (Init_float32 (Float32.of_bits (Int.repr 1065353216)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065353216)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065353216)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gVec3sOne := {|
  gvar_info := (tarray tshort 3);
  gvar_init := (Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 1) ::
                Init_int16 (Int.repr 1) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_init_scene_graph_node_links := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_graphNode, (tptr (Tstruct _GraphNode noattr))) ::
                (_type, tint) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sassign
    (Efield
      (Ederef (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
        (Tstruct _GraphNode noattr)) _type tshort) (Etempvar _type tint))
  (Ssequence
    (Sassign
      (Efield
        (Ederef (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
          (Tstruct _GraphNode noattr)) _flags tshort)
      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
        (Econst_int (Int.repr 0) tint) tint))
    (Ssequence
      (Sassign
        (Efield
          (Ederef (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
            (Tstruct _GraphNode noattr)) _prev
          (tptr (Tstruct _GraphNode noattr)))
        (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr))))
      (Ssequence
        (Sassign
          (Efield
            (Ederef (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
              (Tstruct _GraphNode noattr)) _next
            (tptr (Tstruct _GraphNode noattr)))
          (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr))))
        (Ssequence
          (Sassign
            (Efield
              (Ederef
                (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
                (Tstruct _GraphNode noattr)) _parent
              (tptr (Tstruct _GraphNode noattr)))
            (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
          (Sassign
            (Efield
              (Ederef
                (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
                (Tstruct _GraphNode noattr)) _children
              (tptr (Tstruct _GraphNode noattr)))
            (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))))))
|}.

Definition f_init_graph_node_root := {|
  fn_return := (tptr (Tstruct _GraphNodeRoot noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_graphNode, (tptr (Tstruct _GraphNodeRoot noattr))) ::
                (_areaIndex, tshort) :: (_x, tshort) :: (_y, tshort) ::
                (_width, tshort) :: (_height, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One
                 (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_only_pool_alloc (Tfunction
                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                        tint :: nil) (tptr tvoid) cc_default))
        ((Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Esizeof (Tstruct _GraphNodeRoot noattr) tuint) :: nil))
      (Sset _graphNode (Etempvar _t'1 (tptr tvoid))))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop One
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeRoot noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Scall None
          (Evar _init_scene_graph_node_links (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                tint :: nil) tvoid
                                               cc_default))
          ((Eaddrof
             (Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeRoot noattr)))
                 (Tstruct _GraphNodeRoot noattr)) _node
               (Tstruct _GraphNode noattr))
             (tptr (Tstruct _GraphNode noattr))) ::
           (Econst_int (Int.repr 1) tint) :: nil))
        (Ssequence
          (Sassign
            (Efield
              (Ederef
                (Etempvar _graphNode (tptr (Tstruct _GraphNodeRoot noattr)))
                (Tstruct _GraphNodeRoot noattr)) _areaIndex tuchar)
            (Etempvar _areaIndex tshort))
          (Ssequence
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _graphNode (tptr (Tstruct _GraphNodeRoot noattr)))
                  (Tstruct _GraphNodeRoot noattr)) _unk15 tschar)
              (Econst_int (Int.repr 0) tint))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _graphNode (tptr (Tstruct _GraphNodeRoot noattr)))
                    (Tstruct _GraphNodeRoot noattr)) _x tshort)
                (Etempvar _x tshort))
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeRoot noattr)))
                      (Tstruct _GraphNodeRoot noattr)) _y tshort)
                  (Etempvar _y tshort))
                (Ssequence
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _graphNode (tptr (Tstruct _GraphNodeRoot noattr)))
                        (Tstruct _GraphNodeRoot noattr)) _width tshort)
                    (Etempvar _width tshort))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _graphNode (tptr (Tstruct _GraphNodeRoot noattr)))
                          (Tstruct _GraphNodeRoot noattr)) _height tshort)
                      (Etempvar _height tshort))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _graphNode (tptr (Tstruct _GraphNodeRoot noattr)))
                            (Tstruct _GraphNodeRoot noattr)) _views
                          (tptr (tptr (Tstruct _GraphNode noattr))))
                        (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _graphNode (tptr (Tstruct _GraphNodeRoot noattr)))
                            (Tstruct _GraphNodeRoot noattr)) _numViews
                          tshort) (Econst_int (Int.repr 0) tint))))))))))
      Sskip)
    (Sreturn (Some (Etempvar _graphNode (tptr (Tstruct _GraphNodeRoot noattr)))))))
|}.

Definition f_init_graph_node_ortho_projection := {|
  fn_return := (tptr (Tstruct _GraphNodeOrthoProjection noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_graphNode,
                 (tptr (Tstruct _GraphNodeOrthoProjection noattr))) ::
                (_scale, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One
                 (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_only_pool_alloc (Tfunction
                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                        tint :: nil) (tptr tvoid) cc_default))
        ((Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Esizeof (Tstruct _GraphNodeOrthoProjection noattr) tuint) :: nil))
      (Sset _graphNode (Etempvar _t'1 (tptr tvoid))))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop One
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeOrthoProjection noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Scall None
          (Evar _init_scene_graph_node_links (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                tint :: nil) tvoid
                                               cc_default))
          ((Eaddrof
             (Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeOrthoProjection noattr)))
                 (Tstruct _GraphNodeOrthoProjection noattr)) _node
               (Tstruct _GraphNode noattr))
             (tptr (Tstruct _GraphNode noattr))) ::
           (Econst_int (Int.repr 2) tint) :: nil))
        (Sassign
          (Efield
            (Ederef
              (Etempvar _graphNode (tptr (Tstruct _GraphNodeOrthoProjection noattr)))
              (Tstruct _GraphNodeOrthoProjection noattr)) _scale tfloat)
          (Etempvar _scale tfloat)))
      Sskip)
    (Sreturn (Some (Etempvar _graphNode (tptr (Tstruct _GraphNodeOrthoProjection noattr)))))))
|}.

Definition f_init_graph_node_perspective := {|
  fn_return := (tptr (Tstruct _GraphNodePerspective noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_graphNode, (tptr (Tstruct _GraphNodePerspective noattr))) ::
                (_fov, tfloat) :: (_near, tshort) :: (_far, tshort) ::
                (_nodeFunc,
                 (tptr (Tfunction
                         (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                          (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                         cc_default))) :: (_unused, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One
                 (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_only_pool_alloc (Tfunction
                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                        tint :: nil) (tptr tvoid) cc_default))
        ((Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Esizeof (Tstruct _GraphNodePerspective noattr) tuint) :: nil))
      (Sset _graphNode (Etempvar _t'1 (tptr tvoid))))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop One
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodePerspective noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Scall None
          (Evar _init_scene_graph_node_links (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                tint :: nil) tvoid
                                               cc_default))
          ((Eaddrof
             (Efield
               (Efield
                 (Ederef
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodePerspective noattr)))
                   (Tstruct _GraphNodePerspective noattr)) _fnNode
                 (Tstruct _FnGraphNode noattr)) _node
               (Tstruct _GraphNode noattr))
             (tptr (Tstruct _GraphNode noattr))) ::
           (Ebinop Oor (Econst_int (Int.repr 3) tint)
             (Econst_int (Int.repr 256) tint) tint) :: nil))
        (Ssequence
          (Sassign
            (Efield
              (Ederef
                (Etempvar _graphNode (tptr (Tstruct _GraphNodePerspective noattr)))
                (Tstruct _GraphNodePerspective noattr)) _fov tfloat)
            (Etempvar _fov tfloat))
          (Ssequence
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _graphNode (tptr (Tstruct _GraphNodePerspective noattr)))
                  (Tstruct _GraphNodePerspective noattr)) _near tshort)
              (Etempvar _near tshort))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _graphNode (tptr (Tstruct _GraphNodePerspective noattr)))
                    (Tstruct _GraphNodePerspective noattr)) _far tshort)
                (Etempvar _far tshort))
              (Ssequence
                (Sassign
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _graphNode (tptr (Tstruct _GraphNodePerspective noattr)))
                        (Tstruct _GraphNodePerspective noattr)) _fnNode
                      (Tstruct _FnGraphNode noattr)) _func
                    (tptr (Tfunction
                            (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                             (tptr tvoid) :: nil)
                            (tptr (Tunion __512 noattr)) cc_default)))
                  (Etempvar _nodeFunc (tptr (Tfunction
                                              (tint ::
                                               (tptr (Tstruct _GraphNode noattr)) ::
                                               (tptr tvoid) :: nil)
                                              (tptr (Tunion __512 noattr))
                                              cc_default))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _graphNode (tptr (Tstruct _GraphNodePerspective noattr)))
                        (Tstruct _GraphNodePerspective noattr)) _unused tint)
                    (Etempvar _unused tint))
                  (Sifthenelse (Ebinop One
                                 (Etempvar _nodeFunc (tptr (Tfunction
                                                             (tint ::
                                                              (tptr (Tstruct _GraphNode noattr)) ::
                                                              (tptr tvoid) ::
                                                              nil)
                                                             (tptr (Tunion __512 noattr))
                                                             cc_default)))
                                 (Ecast (Econst_int (Int.repr 0) tint)
                                   (tptr tvoid)) tint)
                    (Scall None
                      (Etempvar _nodeFunc (tptr (Tfunction
                                                  (tint ::
                                                   (tptr (Tstruct _GraphNode noattr)) ::
                                                   (tptr tvoid) :: nil)
                                                  (tptr (Tunion __512 noattr))
                                                  cc_default)))
                      ((Econst_int (Int.repr 0) tint) ::
                       (Eaddrof
                         (Efield
                           (Efield
                             (Ederef
                               (Etempvar _graphNode (tptr (Tstruct _GraphNodePerspective noattr)))
                               (Tstruct _GraphNodePerspective noattr))
                             _fnNode (Tstruct _FnGraphNode noattr)) _node
                           (Tstruct _GraphNode noattr))
                         (tptr (Tstruct _GraphNode noattr))) ::
                       (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
                       nil))
                    Sskip)))))))
      Sskip)
    (Sreturn (Some (Etempvar _graphNode (tptr (Tstruct _GraphNodePerspective noattr)))))))
|}.

Definition f_init_graph_node_start := {|
  fn_return := (tptr (Tstruct _GraphNodeStart noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_graphNode, (tptr (Tstruct _GraphNodeStart noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One
                 (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_only_pool_alloc (Tfunction
                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                        tint :: nil) (tptr tvoid) cc_default))
        ((Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Esizeof (Tstruct _GraphNodeStart noattr) tuint) :: nil))
      (Sset _graphNode (Etempvar _t'1 (tptr tvoid))))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop One
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeStart noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Scall None
        (Evar _init_scene_graph_node_links (Tfunction
                                             ((tptr (Tstruct _GraphNode noattr)) ::
                                              tint :: nil) tvoid cc_default))
        ((Eaddrof
           (Efield
             (Ederef
               (Etempvar _graphNode (tptr (Tstruct _GraphNodeStart noattr)))
               (Tstruct _GraphNodeStart noattr)) _node
             (Tstruct _GraphNode noattr)) (tptr (Tstruct _GraphNode noattr))) ::
         (Econst_int (Int.repr 10) tint) :: nil))
      Sskip)
    (Sreturn (Some (Etempvar _graphNode (tptr (Tstruct _GraphNodeStart noattr)))))))
|}.

Definition f_init_graph_node_master_list := {|
  fn_return := (tptr (Tstruct _GraphNodeMasterList noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_graphNode, (tptr (Tstruct _GraphNodeMasterList noattr))) ::
                (_on, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One
                 (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_only_pool_alloc (Tfunction
                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                        tint :: nil) (tptr tvoid) cc_default))
        ((Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Esizeof (Tstruct _GraphNodeMasterList noattr) tuint) :: nil))
      (Sset _graphNode (Etempvar _t'1 (tptr tvoid))))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop One
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeMasterList noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Scall None
          (Evar _init_scene_graph_node_links (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                tint :: nil) tvoid
                                               cc_default))
          ((Eaddrof
             (Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeMasterList noattr)))
                 (Tstruct _GraphNodeMasterList noattr)) _node
               (Tstruct _GraphNode noattr))
             (tptr (Tstruct _GraphNode noattr))) ::
           (Econst_int (Int.repr 4) tint) :: nil))
        (Sifthenelse (Etempvar _on tshort)
          (Ssequence
            (Sset _t'2
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _graphNode (tptr (Tstruct _GraphNodeMasterList noattr)))
                    (Tstruct _GraphNodeMasterList noattr)) _node
                  (Tstruct _GraphNode noattr)) _flags tshort))
            (Sassign
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _graphNode (tptr (Tstruct _GraphNodeMasterList noattr)))
                    (Tstruct _GraphNodeMasterList noattr)) _node
                  (Tstruct _GraphNode noattr)) _flags tshort)
              (Ebinop Oor (Etempvar _t'2 tshort)
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 3) tint) tint) tint)))
          Sskip))
      Sskip)
    (Sreturn (Some (Etempvar _graphNode (tptr (Tstruct _GraphNodeMasterList noattr)))))))
|}.

Definition f_init_graph_node_render_range := {|
  fn_return := (tptr (Tstruct _GraphNodeLevelOfDetail noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_graphNode, (tptr (Tstruct _GraphNodeLevelOfDetail noattr))) ::
                (_minDistance, tshort) :: (_maxDistance, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One
                 (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_only_pool_alloc (Tfunction
                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                        tint :: nil) (tptr tvoid) cc_default))
        ((Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Esizeof (Tstruct _GraphNodeLevelOfDetail noattr) tuint) :: nil))
      (Sset _graphNode (Etempvar _t'1 (tptr tvoid))))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop One
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeLevelOfDetail noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Scall None
          (Evar _init_scene_graph_node_links (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                tint :: nil) tvoid
                                               cc_default))
          ((Eaddrof
             (Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeLevelOfDetail noattr)))
                 (Tstruct _GraphNodeLevelOfDetail noattr)) _node
               (Tstruct _GraphNode noattr))
             (tptr (Tstruct _GraphNode noattr))) ::
           (Econst_int (Int.repr 11) tint) :: nil))
        (Ssequence
          (Sassign
            (Efield
              (Ederef
                (Etempvar _graphNode (tptr (Tstruct _GraphNodeLevelOfDetail noattr)))
                (Tstruct _GraphNodeLevelOfDetail noattr)) _minDistance
              tshort) (Etempvar _minDistance tshort))
          (Sassign
            (Efield
              (Ederef
                (Etempvar _graphNode (tptr (Tstruct _GraphNodeLevelOfDetail noattr)))
                (Tstruct _GraphNodeLevelOfDetail noattr)) _maxDistance
              tshort) (Etempvar _maxDistance tshort))))
      Sskip)
    (Sreturn (Some (Etempvar _graphNode (tptr (Tstruct _GraphNodeLevelOfDetail noattr)))))))
|}.

Definition f_init_graph_node_switch_case := {|
  fn_return := (tptr (Tstruct _GraphNodeSwitchCase noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_graphNode, (tptr (Tstruct _GraphNodeSwitchCase noattr))) ::
                (_numCases, tshort) :: (_selectedCase, tshort) ::
                (_nodeFunc,
                 (tptr (Tfunction
                         (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                          (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                         cc_default))) :: (_unused, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One
                 (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_only_pool_alloc (Tfunction
                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                        tint :: nil) (tptr tvoid) cc_default))
        ((Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Esizeof (Tstruct _GraphNodeSwitchCase noattr) tuint) :: nil))
      (Sset _graphNode (Etempvar _t'1 (tptr tvoid))))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop One
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Scall None
          (Evar _init_scene_graph_node_links (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                tint :: nil) tvoid
                                               cc_default))
          ((Eaddrof
             (Efield
               (Efield
                 (Ederef
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                   (Tstruct _GraphNodeSwitchCase noattr)) _fnNode
                 (Tstruct _FnGraphNode noattr)) _node
               (Tstruct _GraphNode noattr))
             (tptr (Tstruct _GraphNode noattr))) ::
           (Ebinop Oor (Econst_int (Int.repr 12) tint)
             (Econst_int (Int.repr 256) tint) tint) :: nil))
        (Ssequence
          (Sassign
            (Efield
              (Ederef
                (Etempvar _graphNode (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                (Tstruct _GraphNodeSwitchCase noattr)) _numCases tshort)
            (Etempvar _numCases tshort))
          (Ssequence
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _graphNode (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                  (Tstruct _GraphNodeSwitchCase noattr)) _selectedCase
                tshort) (Etempvar _selectedCase tshort))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                      (Tstruct _GraphNodeSwitchCase noattr)) _fnNode
                    (Tstruct _FnGraphNode noattr)) _func
                  (tptr (Tfunction
                          (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                           (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                          cc_default)))
                (Etempvar _nodeFunc (tptr (Tfunction
                                            (tint ::
                                             (tptr (Tstruct _GraphNode noattr)) ::
                                             (tptr tvoid) :: nil)
                                            (tptr (Tunion __512 noattr))
                                            cc_default))))
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                      (Tstruct _GraphNodeSwitchCase noattr)) _unused tint)
                  (Etempvar _unused tint))
                (Sifthenelse (Ebinop One
                               (Etempvar _nodeFunc (tptr (Tfunction
                                                           (tint ::
                                                            (tptr (Tstruct _GraphNode noattr)) ::
                                                            (tptr tvoid) ::
                                                            nil)
                                                           (tptr (Tunion __512 noattr))
                                                           cc_default)))
                               (Ecast (Econst_int (Int.repr 0) tint)
                                 (tptr tvoid)) tint)
                  (Scall None
                    (Etempvar _nodeFunc (tptr (Tfunction
                                                (tint ::
                                                 (tptr (Tstruct _GraphNode noattr)) ::
                                                 (tptr tvoid) :: nil)
                                                (tptr (Tunion __512 noattr))
                                                cc_default)))
                    ((Econst_int (Int.repr 0) tint) ::
                     (Eaddrof
                       (Efield
                         (Efield
                           (Ederef
                             (Etempvar _graphNode (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                             (Tstruct _GraphNodeSwitchCase noattr)) _fnNode
                           (Tstruct _FnGraphNode noattr)) _node
                         (Tstruct _GraphNode noattr))
                       (tptr (Tstruct _GraphNode noattr))) ::
                     (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
                     nil))
                  Sskip))))))
      Sskip)
    (Sreturn (Some (Etempvar _graphNode (tptr (Tstruct _GraphNodeSwitchCase noattr)))))))
|}.

Definition f_init_graph_node_camera := {|
  fn_return := (tptr (Tstruct _GraphNodeCamera noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_graphNode, (tptr (Tstruct _GraphNodeCamera noattr))) ::
                (_pos, (tptr tfloat)) :: (_focus, (tptr tfloat)) ::
                (_func,
                 (tptr (Tfunction
                         (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                          (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                         cc_default))) :: (_mode, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One
                 (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_only_pool_alloc (Tfunction
                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                        tint :: nil) (tptr tvoid) cc_default))
        ((Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Esizeof (Tstruct _GraphNodeCamera noattr) tuint) :: nil))
      (Sset _graphNode (Etempvar _t'1 (tptr tvoid))))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop One
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeCamera noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Scall None
          (Evar _init_scene_graph_node_links (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                tint :: nil) tvoid
                                               cc_default))
          ((Eaddrof
             (Efield
               (Efield
                 (Ederef
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeCamera noattr)))
                   (Tstruct _GraphNodeCamera noattr)) _fnNode
                 (Tstruct _FnGraphNode noattr)) _node
               (Tstruct _GraphNode noattr))
             (tptr (Tstruct _GraphNode noattr))) ::
           (Ebinop Oor (Econst_int (Int.repr 20) tint)
             (Econst_int (Int.repr 256) tint) tint) :: nil))
        (Ssequence
          (Scall None
            (Evar _vec3f_copy (Tfunction
                                ((tptr tfloat) :: (tptr tfloat) :: nil)
                                (tptr tvoid) cc_default))
            ((Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeCamera noattr)))
                 (Tstruct _GraphNodeCamera noattr)) _pos (tarray tfloat 3)) ::
             (Etempvar _pos (tptr tfloat)) :: nil))
          (Ssequence
            (Scall None
              (Evar _vec3f_copy (Tfunction
                                  ((tptr tfloat) :: (tptr tfloat) :: nil)
                                  (tptr tvoid) cc_default))
              ((Efield
                 (Ederef
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeCamera noattr)))
                   (Tstruct _GraphNodeCamera noattr)) _focus
                 (tarray tfloat 3)) :: (Etempvar _focus (tptr tfloat)) ::
               nil))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeCamera noattr)))
                      (Tstruct _GraphNodeCamera noattr)) _fnNode
                    (Tstruct _FnGraphNode noattr)) _func
                  (tptr (Tfunction
                          (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                           (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                          cc_default)))
                (Etempvar _func (tptr (Tfunction
                                        (tint ::
                                         (tptr (Tstruct _GraphNode noattr)) ::
                                         (tptr tvoid) :: nil)
                                        (tptr (Tunion __512 noattr))
                                        cc_default))))
              (Ssequence
                (Sassign
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _graphNode (tptr (Tstruct _GraphNodeCamera noattr)))
                        (Tstruct _GraphNodeCamera noattr)) _config
                      (Tunion __1341 noattr)) _mode tint)
                  (Etempvar _mode tint))
                (Ssequence
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _graphNode (tptr (Tstruct _GraphNodeCamera noattr)))
                        (Tstruct _GraphNodeCamera noattr)) _roll tshort)
                    (Econst_int (Int.repr 0) tint))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _graphNode (tptr (Tstruct _GraphNodeCamera noattr)))
                          (Tstruct _GraphNodeCamera noattr)) _rollScreen
                        tshort) (Econst_int (Int.repr 0) tint))
                    (Sifthenelse (Ebinop One
                                   (Etempvar _func (tptr (Tfunction
                                                           (tint ::
                                                            (tptr (Tstruct _GraphNode noattr)) ::
                                                            (tptr tvoid) ::
                                                            nil)
                                                           (tptr (Tunion __512 noattr))
                                                           cc_default)))
                                   (Ecast (Econst_int (Int.repr 0) tint)
                                     (tptr tvoid)) tint)
                      (Scall None
                        (Etempvar _func (tptr (Tfunction
                                                (tint ::
                                                 (tptr (Tstruct _GraphNode noattr)) ::
                                                 (tptr tvoid) :: nil)
                                                (tptr (Tunion __512 noattr))
                                                cc_default)))
                        ((Econst_int (Int.repr 0) tint) ::
                         (Eaddrof
                           (Efield
                             (Efield
                               (Ederef
                                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeCamera noattr)))
                                 (Tstruct _GraphNodeCamera noattr)) _fnNode
                               (Tstruct _FnGraphNode noattr)) _node
                             (Tstruct _GraphNode noattr))
                           (tptr (Tstruct _GraphNode noattr))) ::
                         (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
                         nil))
                      Sskip))))))))
      Sskip)
    (Sreturn (Some (Etempvar _graphNode (tptr (Tstruct _GraphNodeCamera noattr)))))))
|}.

Definition f_init_graph_node_translation_rotation := {|
  fn_return := (tptr (Tstruct _GraphNodeTranslationRotation noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_graphNode,
                 (tptr (Tstruct _GraphNodeTranslationRotation noattr))) ::
                (_drawingLayer, tint) :: (_displayList, (tptr tvoid)) ::
                (_translation, (tptr tshort)) ::
                (_rotation, (tptr tshort)) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One
                 (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_only_pool_alloc (Tfunction
                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                        tint :: nil) (tptr tvoid) cc_default))
        ((Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Esizeof (Tstruct _GraphNodeTranslationRotation noattr) tuint) ::
         nil))
      (Sset _graphNode (Etempvar _t'1 (tptr tvoid))))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop One
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeTranslationRotation noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Scall None
          (Evar _init_scene_graph_node_links (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                tint :: nil) tvoid
                                               cc_default))
          ((Eaddrof
             (Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeTranslationRotation noattr)))
                 (Tstruct _GraphNodeTranslationRotation noattr)) _node
               (Tstruct _GraphNode noattr))
             (tptr (Tstruct _GraphNode noattr))) ::
           (Econst_int (Int.repr 21) tint) :: nil))
        (Ssequence
          (Scall None
            (Evar _vec3s_copy (Tfunction
                                ((tptr tshort) :: (tptr tshort) :: nil)
                                (tptr tvoid) cc_default))
            ((Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeTranslationRotation noattr)))
                 (Tstruct _GraphNodeTranslationRotation noattr)) _translation
               (tarray tshort 3)) :: (Etempvar _translation (tptr tshort)) ::
             nil))
          (Ssequence
            (Scall None
              (Evar _vec3s_copy (Tfunction
                                  ((tptr tshort) :: (tptr tshort) :: nil)
                                  (tptr tvoid) cc_default))
              ((Efield
                 (Ederef
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeTranslationRotation noattr)))
                   (Tstruct _GraphNodeTranslationRotation noattr)) _rotation
                 (tarray tshort 3)) :: (Etempvar _rotation (tptr tshort)) ::
               nil))
            (Ssequence
              (Ssequence
                (Sset _t'2
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _graphNode (tptr (Tstruct _GraphNodeTranslationRotation noattr)))
                        (Tstruct _GraphNodeTranslationRotation noattr)) _node
                      (Tstruct _GraphNode noattr)) _flags tshort))
                (Sassign
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _graphNode (tptr (Tstruct _GraphNodeTranslationRotation noattr)))
                        (Tstruct _GraphNodeTranslationRotation noattr)) _node
                      (Tstruct _GraphNode noattr)) _flags tshort)
                  (Ebinop Oor
                    (Ebinop Oshl (Etempvar _drawingLayer tint)
                      (Econst_int (Int.repr 8) tint) tint)
                    (Ebinop Oand (Etempvar _t'2 tshort)
                      (Econst_int (Int.repr 255) tint) tint) tint)))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _graphNode (tptr (Tstruct _GraphNodeTranslationRotation noattr)))
                    (Tstruct _GraphNodeTranslationRotation noattr))
                  _displayList (tptr tvoid))
                (Etempvar _displayList (tptr tvoid)))))))
      Sskip)
    (Sreturn (Some (Etempvar _graphNode (tptr (Tstruct _GraphNodeTranslationRotation noattr)))))))
|}.

Definition f_init_graph_node_translation := {|
  fn_return := (tptr (Tstruct _GraphNodeTranslation noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_graphNode, (tptr (Tstruct _GraphNodeTranslation noattr))) ::
                (_drawingLayer, tint) :: (_displayList, (tptr tvoid)) ::
                (_translation, (tptr tshort)) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One
                 (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_only_pool_alloc (Tfunction
                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                        tint :: nil) (tptr tvoid) cc_default))
        ((Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Esizeof (Tstruct _GraphNodeTranslation noattr) tuint) :: nil))
      (Sset _graphNode (Etempvar _t'1 (tptr tvoid))))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop One
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeTranslation noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Scall None
          (Evar _init_scene_graph_node_links (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                tint :: nil) tvoid
                                               cc_default))
          ((Eaddrof
             (Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeTranslation noattr)))
                 (Tstruct _GraphNodeTranslation noattr)) _node
               (Tstruct _GraphNode noattr))
             (tptr (Tstruct _GraphNode noattr))) ::
           (Econst_int (Int.repr 22) tint) :: nil))
        (Ssequence
          (Scall None
            (Evar _vec3s_copy (Tfunction
                                ((tptr tshort) :: (tptr tshort) :: nil)
                                (tptr tvoid) cc_default))
            ((Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeTranslation noattr)))
                 (Tstruct _GraphNodeTranslation noattr)) _translation
               (tarray tshort 3)) :: (Etempvar _translation (tptr tshort)) ::
             nil))
          (Ssequence
            (Ssequence
              (Sset _t'2
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeTranslation noattr)))
                      (Tstruct _GraphNodeTranslation noattr)) _node
                    (Tstruct _GraphNode noattr)) _flags tshort))
              (Sassign
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeTranslation noattr)))
                      (Tstruct _GraphNodeTranslation noattr)) _node
                    (Tstruct _GraphNode noattr)) _flags tshort)
                (Ebinop Oor
                  (Ebinop Oshl (Etempvar _drawingLayer tint)
                    (Econst_int (Int.repr 8) tint) tint)
                  (Ebinop Oand (Etempvar _t'2 tshort)
                    (Econst_int (Int.repr 255) tint) tint) tint)))
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _graphNode (tptr (Tstruct _GraphNodeTranslation noattr)))
                  (Tstruct _GraphNodeTranslation noattr)) _displayList
                (tptr tvoid)) (Etempvar _displayList (tptr tvoid))))))
      Sskip)
    (Sreturn (Some (Etempvar _graphNode (tptr (Tstruct _GraphNodeTranslation noattr)))))))
|}.

Definition f_init_graph_node_rotation := {|
  fn_return := (tptr (Tstruct _GraphNodeRotation noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_graphNode, (tptr (Tstruct _GraphNodeRotation noattr))) ::
                (_drawingLayer, tint) :: (_displayList, (tptr tvoid)) ::
                (_rotation, (tptr tshort)) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One
                 (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_only_pool_alloc (Tfunction
                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                        tint :: nil) (tptr tvoid) cc_default))
        ((Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Esizeof (Tstruct _GraphNodeRotation noattr) tuint) :: nil))
      (Sset _graphNode (Etempvar _t'1 (tptr tvoid))))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop One
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeRotation noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Scall None
          (Evar _init_scene_graph_node_links (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                tint :: nil) tvoid
                                               cc_default))
          ((Eaddrof
             (Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeRotation noattr)))
                 (Tstruct _GraphNodeRotation noattr)) _node
               (Tstruct _GraphNode noattr))
             (tptr (Tstruct _GraphNode noattr))) ::
           (Econst_int (Int.repr 23) tint) :: nil))
        (Ssequence
          (Scall None
            (Evar _vec3s_copy (Tfunction
                                ((tptr tshort) :: (tptr tshort) :: nil)
                                (tptr tvoid) cc_default))
            ((Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeRotation noattr)))
                 (Tstruct _GraphNodeRotation noattr)) _rotation
               (tarray tshort 3)) :: (Etempvar _rotation (tptr tshort)) ::
             nil))
          (Ssequence
            (Ssequence
              (Sset _t'2
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeRotation noattr)))
                      (Tstruct _GraphNodeRotation noattr)) _node
                    (Tstruct _GraphNode noattr)) _flags tshort))
              (Sassign
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeRotation noattr)))
                      (Tstruct _GraphNodeRotation noattr)) _node
                    (Tstruct _GraphNode noattr)) _flags tshort)
                (Ebinop Oor
                  (Ebinop Oshl (Etempvar _drawingLayer tint)
                    (Econst_int (Int.repr 8) tint) tint)
                  (Ebinop Oand (Etempvar _t'2 tshort)
                    (Econst_int (Int.repr 255) tint) tint) tint)))
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _graphNode (tptr (Tstruct _GraphNodeRotation noattr)))
                  (Tstruct _GraphNodeRotation noattr)) _displayList
                (tptr tvoid)) (Etempvar _displayList (tptr tvoid))))))
      Sskip)
    (Sreturn (Some (Etempvar _graphNode (tptr (Tstruct _GraphNodeRotation noattr)))))))
|}.

Definition f_init_graph_node_scale := {|
  fn_return := (tptr (Tstruct _GraphNodeScale noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_graphNode, (tptr (Tstruct _GraphNodeScale noattr))) ::
                (_drawingLayer, tint) :: (_displayList, (tptr tvoid)) ::
                (_scale, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One
                 (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_only_pool_alloc (Tfunction
                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                        tint :: nil) (tptr tvoid) cc_default))
        ((Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Esizeof (Tstruct _GraphNodeScale noattr) tuint) :: nil))
      (Sset _graphNode (Etempvar _t'1 (tptr tvoid))))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop One
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeScale noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Scall None
          (Evar _init_scene_graph_node_links (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                tint :: nil) tvoid
                                               cc_default))
          ((Eaddrof
             (Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeScale noattr)))
                 (Tstruct _GraphNodeScale noattr)) _node
               (Tstruct _GraphNode noattr))
             (tptr (Tstruct _GraphNode noattr))) ::
           (Econst_int (Int.repr 28) tint) :: nil))
        (Ssequence
          (Ssequence
            (Sset _t'2
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _graphNode (tptr (Tstruct _GraphNodeScale noattr)))
                    (Tstruct _GraphNodeScale noattr)) _node
                  (Tstruct _GraphNode noattr)) _flags tshort))
            (Sassign
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _graphNode (tptr (Tstruct _GraphNodeScale noattr)))
                    (Tstruct _GraphNodeScale noattr)) _node
                  (Tstruct _GraphNode noattr)) _flags tshort)
              (Ebinop Oor
                (Ebinop Oshl (Etempvar _drawingLayer tint)
                  (Econst_int (Int.repr 8) tint) tint)
                (Ebinop Oand (Etempvar _t'2 tshort)
                  (Econst_int (Int.repr 255) tint) tint) tint)))
          (Ssequence
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _graphNode (tptr (Tstruct _GraphNodeScale noattr)))
                  (Tstruct _GraphNodeScale noattr)) _scale tfloat)
              (Etempvar _scale tfloat))
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _graphNode (tptr (Tstruct _GraphNodeScale noattr)))
                  (Tstruct _GraphNodeScale noattr)) _displayList
                (tptr tvoid)) (Etempvar _displayList (tptr tvoid))))))
      Sskip)
    (Sreturn (Some (Etempvar _graphNode (tptr (Tstruct _GraphNodeScale noattr)))))))
|}.

Definition f_init_graph_node_object := {|
  fn_return := (tptr (Tstruct _GraphNodeObject noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_graphNode, (tptr (Tstruct _GraphNodeObject noattr))) ::
                (_sharedChild, (tptr (Tstruct _GraphNode noattr))) ::
                (_pos, (tptr tfloat)) :: (_angle, (tptr tshort)) ::
                (_scale, (tptr tfloat)) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One
                 (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_only_pool_alloc (Tfunction
                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                        tint :: nil) (tptr tvoid) cc_default))
        ((Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Esizeof (Tstruct _GraphNodeObject noattr) tuint) :: nil))
      (Sset _graphNode (Etempvar _t'1 (tptr tvoid))))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop One
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Scall None
          (Evar _init_scene_graph_node_links (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                tint :: nil) tvoid
                                               cc_default))
          ((Eaddrof
             (Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                 (Tstruct _GraphNodeObject noattr)) _node
               (Tstruct _GraphNode noattr))
             (tptr (Tstruct _GraphNode noattr))) ::
           (Econst_int (Int.repr 24) tint) :: nil))
        (Ssequence
          (Scall None
            (Evar _vec3f_copy (Tfunction
                                ((tptr tfloat) :: (tptr tfloat) :: nil)
                                (tptr tvoid) cc_default))
            ((Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                 (Tstruct _GraphNodeObject noattr)) _pos (tarray tfloat 3)) ::
             (Etempvar _pos (tptr tfloat)) :: nil))
          (Ssequence
            (Scall None
              (Evar _vec3f_copy (Tfunction
                                  ((tptr tfloat) :: (tptr tfloat) :: nil)
                                  (tptr tvoid) cc_default))
              ((Efield
                 (Ederef
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                   (Tstruct _GraphNodeObject noattr)) _scale
                 (tarray tfloat 3)) :: (Etempvar _scale (tptr tfloat)) ::
               nil))
            (Ssequence
              (Scall None
                (Evar _vec3s_copy (Tfunction
                                    ((tptr tshort) :: (tptr tshort) :: nil)
                                    (tptr tvoid) cc_default))
                ((Efield
                   (Ederef
                     (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                     (Tstruct _GraphNodeObject noattr)) _angle
                   (tarray tshort 3)) :: (Etempvar _angle (tptr tshort)) ::
                 nil))
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                      (Tstruct _GraphNodeObject noattr)) _sharedChild
                    (tptr (Tstruct _GraphNode noattr)))
                  (Etempvar _sharedChild (tptr (Tstruct _GraphNode noattr))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                        (Tstruct _GraphNodeObject noattr)) _throwMatrix
                      (tptr (tarray (tarray tfloat 4) 4)))
                    (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                            (Tstruct _GraphNodeObject noattr)) _animInfo
                          (Tstruct _AnimInfo noattr)) _animID tshort)
                      (Econst_int (Int.repr 0) tint))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                              (Tstruct _GraphNodeObject noattr)) _animInfo
                            (Tstruct _AnimInfo noattr)) _curAnim
                          (tptr (Tstruct _Animation noattr)))
                        (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
                      (Ssequence
                        (Sassign
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                                (Tstruct _GraphNodeObject noattr)) _animInfo
                              (Tstruct _AnimInfo noattr)) _animFrame tshort)
                          (Econst_int (Int.repr 0) tint))
                        (Ssequence
                          (Sassign
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                                  (Tstruct _GraphNodeObject noattr))
                                _animInfo (Tstruct _AnimInfo noattr))
                              _animFrameAccelAssist tint)
                            (Econst_int (Int.repr 0) tint))
                          (Ssequence
                            (Sassign
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                                    (Tstruct _GraphNodeObject noattr))
                                  _animInfo (Tstruct _AnimInfo noattr))
                                _animAccel tint)
                              (Econst_int (Int.repr 65536) tint))
                            (Ssequence
                              (Sassign
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                                      (Tstruct _GraphNodeObject noattr))
                                    _animInfo (Tstruct _AnimInfo noattr))
                                  _animTimer tushort)
                                (Econst_int (Int.repr 0) tint))
                              (Ssequence
                                (Sset _t'2
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                                        (Tstruct _GraphNodeObject noattr))
                                      _node (Tstruct _GraphNode noattr))
                                    _flags tshort))
                                (Sassign
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                                        (Tstruct _GraphNodeObject noattr))
                                      _node (Tstruct _GraphNode noattr))
                                    _flags tshort)
                                  (Ebinop Oor (Etempvar _t'2 tshort)
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 5) tint) tint)
                                    tint)))))))))))))))
      Sskip)
    (Sreturn (Some (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))))))
|}.

Definition f_init_graph_node_culling_radius := {|
  fn_return := (tptr (Tstruct _GraphNodeCullingRadius noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_graphNode, (tptr (Tstruct _GraphNodeCullingRadius noattr))) ::
                (_radius, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One
                 (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_only_pool_alloc (Tfunction
                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                        tint :: nil) (tptr tvoid) cc_default))
        ((Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Esizeof (Tstruct _GraphNodeCullingRadius noattr) tuint) :: nil))
      (Sset _graphNode (Etempvar _t'1 (tptr tvoid))))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop One
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeCullingRadius noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Scall None
          (Evar _init_scene_graph_node_links (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                tint :: nil) tvoid
                                               cc_default))
          ((Eaddrof
             (Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeCullingRadius noattr)))
                 (Tstruct _GraphNodeCullingRadius noattr)) _node
               (Tstruct _GraphNode noattr))
             (tptr (Tstruct _GraphNode noattr))) ::
           (Econst_int (Int.repr 47) tint) :: nil))
        (Sassign
          (Efield
            (Ederef
              (Etempvar _graphNode (tptr (Tstruct _GraphNodeCullingRadius noattr)))
              (Tstruct _GraphNodeCullingRadius noattr)) _cullingRadius
            tshort) (Etempvar _radius tshort)))
      Sskip)
    (Sreturn (Some (Etempvar _graphNode (tptr (Tstruct _GraphNodeCullingRadius noattr)))))))
|}.

Definition f_init_graph_node_animated_part := {|
  fn_return := (tptr (Tstruct _GraphNodeAnimatedPart noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_graphNode, (tptr (Tstruct _GraphNodeAnimatedPart noattr))) ::
                (_drawingLayer, tint) :: (_displayList, (tptr tvoid)) ::
                (_translation, (tptr tshort)) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One
                 (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_only_pool_alloc (Tfunction
                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                        tint :: nil) (tptr tvoid) cc_default))
        ((Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Esizeof (Tstruct _GraphNodeAnimatedPart noattr) tuint) :: nil))
      (Sset _graphNode (Etempvar _t'1 (tptr tvoid))))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop One
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeAnimatedPart noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Scall None
          (Evar _init_scene_graph_node_links (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                tint :: nil) tvoid
                                               cc_default))
          ((Eaddrof
             (Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeAnimatedPart noattr)))
                 (Tstruct _GraphNodeAnimatedPart noattr)) _node
               (Tstruct _GraphNode noattr))
             (tptr (Tstruct _GraphNode noattr))) ::
           (Econst_int (Int.repr 25) tint) :: nil))
        (Ssequence
          (Scall None
            (Evar _vec3s_copy (Tfunction
                                ((tptr tshort) :: (tptr tshort) :: nil)
                                (tptr tvoid) cc_default))
            ((Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeAnimatedPart noattr)))
                 (Tstruct _GraphNodeAnimatedPart noattr)) _translation
               (tarray tshort 3)) :: (Etempvar _translation (tptr tshort)) ::
             nil))
          (Ssequence
            (Ssequence
              (Sset _t'2
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeAnimatedPart noattr)))
                      (Tstruct _GraphNodeAnimatedPart noattr)) _node
                    (Tstruct _GraphNode noattr)) _flags tshort))
              (Sassign
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeAnimatedPart noattr)))
                      (Tstruct _GraphNodeAnimatedPart noattr)) _node
                    (Tstruct _GraphNode noattr)) _flags tshort)
                (Ebinop Oor
                  (Ebinop Oshl (Etempvar _drawingLayer tint)
                    (Econst_int (Int.repr 8) tint) tint)
                  (Ebinop Oand (Etempvar _t'2 tshort)
                    (Econst_int (Int.repr 255) tint) tint) tint)))
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _graphNode (tptr (Tstruct _GraphNodeAnimatedPart noattr)))
                  (Tstruct _GraphNodeAnimatedPart noattr)) _displayList
                (tptr tvoid)) (Etempvar _displayList (tptr tvoid))))))
      Sskip)
    (Sreturn (Some (Etempvar _graphNode (tptr (Tstruct _GraphNodeAnimatedPart noattr)))))))
|}.

Definition f_init_graph_node_billboard := {|
  fn_return := (tptr (Tstruct _GraphNodeBillboard noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_graphNode, (tptr (Tstruct _GraphNodeBillboard noattr))) ::
                (_drawingLayer, tint) :: (_displayList, (tptr tvoid)) ::
                (_translation, (tptr tshort)) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One
                 (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_only_pool_alloc (Tfunction
                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                        tint :: nil) (tptr tvoid) cc_default))
        ((Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Esizeof (Tstruct _GraphNodeBillboard noattr) tuint) :: nil))
      (Sset _graphNode (Etempvar _t'1 (tptr tvoid))))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop One
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeBillboard noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Scall None
          (Evar _init_scene_graph_node_links (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                tint :: nil) tvoid
                                               cc_default))
          ((Eaddrof
             (Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeBillboard noattr)))
                 (Tstruct _GraphNodeBillboard noattr)) _node
               (Tstruct _GraphNode noattr))
             (tptr (Tstruct _GraphNode noattr))) ::
           (Econst_int (Int.repr 26) tint) :: nil))
        (Ssequence
          (Scall None
            (Evar _vec3s_copy (Tfunction
                                ((tptr tshort) :: (tptr tshort) :: nil)
                                (tptr tvoid) cc_default))
            ((Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeBillboard noattr)))
                 (Tstruct _GraphNodeBillboard noattr)) _translation
               (tarray tshort 3)) :: (Etempvar _translation (tptr tshort)) ::
             nil))
          (Ssequence
            (Ssequence
              (Sset _t'2
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeBillboard noattr)))
                      (Tstruct _GraphNodeBillboard noattr)) _node
                    (Tstruct _GraphNode noattr)) _flags tshort))
              (Sassign
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeBillboard noattr)))
                      (Tstruct _GraphNodeBillboard noattr)) _node
                    (Tstruct _GraphNode noattr)) _flags tshort)
                (Ebinop Oor
                  (Ebinop Oshl (Etempvar _drawingLayer tint)
                    (Econst_int (Int.repr 8) tint) tint)
                  (Ebinop Oand (Etempvar _t'2 tshort)
                    (Econst_int (Int.repr 255) tint) tint) tint)))
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _graphNode (tptr (Tstruct _GraphNodeBillboard noattr)))
                  (Tstruct _GraphNodeBillboard noattr)) _displayList
                (tptr tvoid)) (Etempvar _displayList (tptr tvoid))))))
      Sskip)
    (Sreturn (Some (Etempvar _graphNode (tptr (Tstruct _GraphNodeBillboard noattr)))))))
|}.

Definition f_init_graph_node_display_list := {|
  fn_return := (tptr (Tstruct _GraphNodeDisplayList noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_graphNode, (tptr (Tstruct _GraphNodeDisplayList noattr))) ::
                (_drawingLayer, tint) :: (_displayList, (tptr tvoid)) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One
                 (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_only_pool_alloc (Tfunction
                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                        tint :: nil) (tptr tvoid) cc_default))
        ((Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Esizeof (Tstruct _GraphNodeDisplayList noattr) tuint) :: nil))
      (Sset _graphNode (Etempvar _t'1 (tptr tvoid))))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop One
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeDisplayList noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Scall None
          (Evar _init_scene_graph_node_links (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                tint :: nil) tvoid
                                               cc_default))
          ((Eaddrof
             (Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeDisplayList noattr)))
                 (Tstruct _GraphNodeDisplayList noattr)) _node
               (Tstruct _GraphNode noattr))
             (tptr (Tstruct _GraphNode noattr))) ::
           (Econst_int (Int.repr 27) tint) :: nil))
        (Ssequence
          (Ssequence
            (Sset _t'2
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _graphNode (tptr (Tstruct _GraphNodeDisplayList noattr)))
                    (Tstruct _GraphNodeDisplayList noattr)) _node
                  (Tstruct _GraphNode noattr)) _flags tshort))
            (Sassign
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _graphNode (tptr (Tstruct _GraphNodeDisplayList noattr)))
                    (Tstruct _GraphNodeDisplayList noattr)) _node
                  (Tstruct _GraphNode noattr)) _flags tshort)
              (Ebinop Oor
                (Ebinop Oshl (Etempvar _drawingLayer tint)
                  (Econst_int (Int.repr 8) tint) tint)
                (Ebinop Oand (Etempvar _t'2 tshort)
                  (Econst_int (Int.repr 255) tint) tint) tint)))
          (Sassign
            (Efield
              (Ederef
                (Etempvar _graphNode (tptr (Tstruct _GraphNodeDisplayList noattr)))
                (Tstruct _GraphNodeDisplayList noattr)) _displayList
              (tptr tvoid)) (Etempvar _displayList (tptr tvoid)))))
      Sskip)
    (Sreturn (Some (Etempvar _graphNode (tptr (Tstruct _GraphNodeDisplayList noattr)))))))
|}.

Definition f_init_graph_node_shadow := {|
  fn_return := (tptr (Tstruct _GraphNodeShadow noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_graphNode, (tptr (Tstruct _GraphNodeShadow noattr))) ::
                (_shadowScale, tshort) :: (_shadowSolidity, tuchar) ::
                (_shadowType, tuchar) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One
                 (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_only_pool_alloc (Tfunction
                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                        tint :: nil) (tptr tvoid) cc_default))
        ((Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Esizeof (Tstruct _GraphNodeShadow noattr) tuint) :: nil))
      (Sset _graphNode (Etempvar _t'1 (tptr tvoid))))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop One
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeShadow noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Scall None
          (Evar _init_scene_graph_node_links (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                tint :: nil) tvoid
                                               cc_default))
          ((Eaddrof
             (Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeShadow noattr)))
                 (Tstruct _GraphNodeShadow noattr)) _node
               (Tstruct _GraphNode noattr))
             (tptr (Tstruct _GraphNode noattr))) ::
           (Econst_int (Int.repr 40) tint) :: nil))
        (Ssequence
          (Sassign
            (Efield
              (Ederef
                (Etempvar _graphNode (tptr (Tstruct _GraphNodeShadow noattr)))
                (Tstruct _GraphNodeShadow noattr)) _shadowScale tshort)
            (Etempvar _shadowScale tshort))
          (Ssequence
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _graphNode (tptr (Tstruct _GraphNodeShadow noattr)))
                  (Tstruct _GraphNodeShadow noattr)) _shadowSolidity tuchar)
              (Etempvar _shadowSolidity tuchar))
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _graphNode (tptr (Tstruct _GraphNodeShadow noattr)))
                  (Tstruct _GraphNodeShadow noattr)) _shadowType tuchar)
              (Etempvar _shadowType tuchar)))))
      Sskip)
    (Sreturn (Some (Etempvar _graphNode (tptr (Tstruct _GraphNodeShadow noattr)))))))
|}.

Definition f_init_graph_node_object_parent := {|
  fn_return := (tptr (Tstruct _GraphNodeObjectParent noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_graphNode, (tptr (Tstruct _GraphNodeObjectParent noattr))) ::
                (_sharedChild, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One
                 (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_only_pool_alloc (Tfunction
                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                        tint :: nil) (tptr tvoid) cc_default))
        ((Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Esizeof (Tstruct _GraphNodeObjectParent noattr) tuint) :: nil))
      (Sset _graphNode (Etempvar _t'1 (tptr tvoid))))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop One
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeObjectParent noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Scall None
          (Evar _init_scene_graph_node_links (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                tint :: nil) tvoid
                                               cc_default))
          ((Eaddrof
             (Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeObjectParent noattr)))
                 (Tstruct _GraphNodeObjectParent noattr)) _node
               (Tstruct _GraphNode noattr))
             (tptr (Tstruct _GraphNode noattr))) ::
           (Econst_int (Int.repr 41) tint) :: nil))
        (Sassign
          (Efield
            (Ederef
              (Etempvar _graphNode (tptr (Tstruct _GraphNodeObjectParent noattr)))
              (Tstruct _GraphNodeObjectParent noattr)) _sharedChild
            (tptr (Tstruct _GraphNode noattr)))
          (Etempvar _sharedChild (tptr (Tstruct _GraphNode noattr)))))
      Sskip)
    (Sreturn (Some (Etempvar _graphNode (tptr (Tstruct _GraphNodeObjectParent noattr)))))))
|}.

Definition f_init_graph_node_generated := {|
  fn_return := (tptr (Tstruct _GraphNodeGenerated noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_graphNode, (tptr (Tstruct _GraphNodeGenerated noattr))) ::
                (_gfxFunc,
                 (tptr (Tfunction
                         (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                          (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                         cc_default))) :: (_parameter, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One
                 (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_only_pool_alloc (Tfunction
                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                        tint :: nil) (tptr tvoid) cc_default))
        ((Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Esizeof (Tstruct _GraphNodeGenerated noattr) tuint) :: nil))
      (Sset _graphNode (Etempvar _t'1 (tptr tvoid))))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop One
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeGenerated noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Scall None
          (Evar _init_scene_graph_node_links (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                tint :: nil) tvoid
                                               cc_default))
          ((Eaddrof
             (Efield
               (Efield
                 (Ederef
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeGenerated noattr)))
                   (Tstruct _GraphNodeGenerated noattr)) _fnNode
                 (Tstruct _FnGraphNode noattr)) _node
               (Tstruct _GraphNode noattr))
             (tptr (Tstruct _GraphNode noattr))) ::
           (Ebinop Oor (Econst_int (Int.repr 42) tint)
             (Econst_int (Int.repr 256) tint) tint) :: nil))
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Ederef
                  (Etempvar _graphNode (tptr (Tstruct _GraphNodeGenerated noattr)))
                  (Tstruct _GraphNodeGenerated noattr)) _fnNode
                (Tstruct _FnGraphNode noattr)) _func
              (tptr (Tfunction
                      (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                       (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                      cc_default)))
            (Etempvar _gfxFunc (tptr (Tfunction
                                       (tint ::
                                        (tptr (Tstruct _GraphNode noattr)) ::
                                        (tptr tvoid) :: nil)
                                       (tptr (Tunion __512 noattr))
                                       cc_default))))
          (Ssequence
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _graphNode (tptr (Tstruct _GraphNodeGenerated noattr)))
                  (Tstruct _GraphNodeGenerated noattr)) _parameter tuint)
              (Etempvar _parameter tint))
            (Sifthenelse (Ebinop One
                           (Etempvar _gfxFunc (tptr (Tfunction
                                                      (tint ::
                                                       (tptr (Tstruct _GraphNode noattr)) ::
                                                       (tptr tvoid) :: nil)
                                                      (tptr (Tunion __512 noattr))
                                                      cc_default)))
                           (Ecast (Econst_int (Int.repr 0) tint)
                             (tptr tvoid)) tint)
              (Scall None
                (Etempvar _gfxFunc (tptr (Tfunction
                                           (tint ::
                                            (tptr (Tstruct _GraphNode noattr)) ::
                                            (tptr tvoid) :: nil)
                                           (tptr (Tunion __512 noattr))
                                           cc_default)))
                ((Econst_int (Int.repr 0) tint) ::
                 (Eaddrof
                   (Efield
                     (Efield
                       (Ederef
                         (Etempvar _graphNode (tptr (Tstruct _GraphNodeGenerated noattr)))
                         (Tstruct _GraphNodeGenerated noattr)) _fnNode
                       (Tstruct _FnGraphNode noattr)) _node
                     (Tstruct _GraphNode noattr))
                   (tptr (Tstruct _GraphNode noattr))) ::
                 (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
                 nil))
              Sskip))))
      Sskip)
    (Sreturn (Some (Etempvar _graphNode (tptr (Tstruct _GraphNodeGenerated noattr)))))))
|}.

Definition f_init_graph_node_background := {|
  fn_return := (tptr (Tstruct _GraphNodeBackground noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_graphNode, (tptr (Tstruct _GraphNodeBackground noattr))) ::
                (_background, tushort) ::
                (_backgroundFunc,
                 (tptr (Tfunction
                         (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                          (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                         cc_default))) :: (_zero, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One
                 (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_only_pool_alloc (Tfunction
                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                        tint :: nil) (tptr tvoid) cc_default))
        ((Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Esizeof (Tstruct _GraphNodeBackground noattr) tuint) :: nil))
      (Sset _graphNode (Etempvar _t'1 (tptr tvoid))))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop One
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeBackground noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Scall None
          (Evar _init_scene_graph_node_links (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                tint :: nil) tvoid
                                               cc_default))
          ((Eaddrof
             (Efield
               (Efield
                 (Ederef
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeBackground noattr)))
                   (Tstruct _GraphNodeBackground noattr)) _fnNode
                 (Tstruct _FnGraphNode noattr)) _node
               (Tstruct _GraphNode noattr))
             (tptr (Tstruct _GraphNode noattr))) ::
           (Ebinop Oor (Econst_int (Int.repr 44) tint)
             (Econst_int (Int.repr 256) tint) tint) :: nil))
        (Ssequence
          (Sassign
            (Efield
              (Ederef
                (Etempvar _graphNode (tptr (Tstruct _GraphNodeBackground noattr)))
                (Tstruct _GraphNodeBackground noattr)) _background tint)
            (Ebinop Oor
              (Ebinop Oshl (Etempvar _background tushort)
                (Econst_int (Int.repr 16) tint) tint)
              (Etempvar _background tushort) tint))
          (Ssequence
            (Sassign
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _graphNode (tptr (Tstruct _GraphNodeBackground noattr)))
                    (Tstruct _GraphNodeBackground noattr)) _fnNode
                  (Tstruct _FnGraphNode noattr)) _func
                (tptr (Tfunction
                        (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                         (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                        cc_default)))
              (Etempvar _backgroundFunc (tptr (Tfunction
                                                (tint ::
                                                 (tptr (Tstruct _GraphNode noattr)) ::
                                                 (tptr tvoid) :: nil)
                                                (tptr (Tunion __512 noattr))
                                                cc_default))))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _graphNode (tptr (Tstruct _GraphNodeBackground noattr)))
                    (Tstruct _GraphNodeBackground noattr)) _unused tint)
                (Etempvar _zero tint))
              (Sifthenelse (Ebinop One
                             (Etempvar _backgroundFunc (tptr (Tfunction
                                                               (tint ::
                                                                (tptr (Tstruct _GraphNode noattr)) ::
                                                                (tptr tvoid) ::
                                                                nil)
                                                               (tptr (Tunion __512 noattr))
                                                               cc_default)))
                             (Ecast (Econst_int (Int.repr 0) tint)
                               (tptr tvoid)) tint)
                (Scall None
                  (Etempvar _backgroundFunc (tptr (Tfunction
                                                    (tint ::
                                                     (tptr (Tstruct _GraphNode noattr)) ::
                                                     (tptr tvoid) :: nil)
                                                    (tptr (Tunion __512 noattr))
                                                    cc_default)))
                  ((Econst_int (Int.repr 0) tint) ::
                   (Eaddrof
                     (Efield
                       (Efield
                         (Ederef
                           (Etempvar _graphNode (tptr (Tstruct _GraphNodeBackground noattr)))
                           (Tstruct _GraphNodeBackground noattr)) _fnNode
                         (Tstruct _FnGraphNode noattr)) _node
                       (Tstruct _GraphNode noattr))
                     (tptr (Tstruct _GraphNode noattr))) ::
                   (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
                   nil))
                Sskip)))))
      Sskip)
    (Sreturn (Some (Etempvar _graphNode (tptr (Tstruct _GraphNodeBackground noattr)))))))
|}.

Definition f_init_graph_node_held_object := {|
  fn_return := (tptr (Tstruct _GraphNodeHeldObject noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_graphNode, (tptr (Tstruct _GraphNodeHeldObject noattr))) ::
                (_objNode, (tptr (Tstruct _Object noattr))) ::
                (_translation, (tptr tshort)) ::
                (_nodeFunc,
                 (tptr (Tfunction
                         (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                          (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                         cc_default))) :: (_playerIndex, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One
                 (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_only_pool_alloc (Tfunction
                                       ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                        tint :: nil) (tptr tvoid) cc_default))
        ((Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Esizeof (Tstruct _GraphNodeHeldObject noattr) tuint) :: nil))
      (Sset _graphNode (Etempvar _t'1 (tptr tvoid))))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop One
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeHeldObject noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Scall None
          (Evar _init_scene_graph_node_links (Tfunction
                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                tint :: nil) tvoid
                                               cc_default))
          ((Eaddrof
             (Efield
               (Efield
                 (Ederef
                   (Etempvar _graphNode (tptr (Tstruct _GraphNodeHeldObject noattr)))
                   (Tstruct _GraphNodeHeldObject noattr)) _fnNode
                 (Tstruct _FnGraphNode noattr)) _node
               (Tstruct _GraphNode noattr))
             (tptr (Tstruct _GraphNode noattr))) ::
           (Ebinop Oor (Econst_int (Int.repr 46) tint)
             (Econst_int (Int.repr 256) tint) tint) :: nil))
        (Ssequence
          (Scall None
            (Evar _vec3s_copy (Tfunction
                                ((tptr tshort) :: (tptr tshort) :: nil)
                                (tptr tvoid) cc_default))
            ((Efield
               (Ederef
                 (Etempvar _graphNode (tptr (Tstruct _GraphNodeHeldObject noattr)))
                 (Tstruct _GraphNodeHeldObject noattr)) _translation
               (tarray tshort 3)) :: (Etempvar _translation (tptr tshort)) ::
             nil))
          (Ssequence
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _graphNode (tptr (Tstruct _GraphNodeHeldObject noattr)))
                  (Tstruct _GraphNodeHeldObject noattr)) _objNode
                (tptr (Tstruct _Object noattr)))
              (Etempvar _objNode (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeHeldObject noattr)))
                      (Tstruct _GraphNodeHeldObject noattr)) _fnNode
                    (Tstruct _FnGraphNode noattr)) _func
                  (tptr (Tfunction
                          (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                           (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                          cc_default)))
                (Etempvar _nodeFunc (tptr (Tfunction
                                            (tint ::
                                             (tptr (Tstruct _GraphNode noattr)) ::
                                             (tptr tvoid) :: nil)
                                            (tptr (Tunion __512 noattr))
                                            cc_default))))
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeHeldObject noattr)))
                      (Tstruct _GraphNodeHeldObject noattr)) _playerIndex
                    tint) (Etempvar _playerIndex tint))
                (Sifthenelse (Ebinop One
                               (Etempvar _nodeFunc (tptr (Tfunction
                                                           (tint ::
                                                            (tptr (Tstruct _GraphNode noattr)) ::
                                                            (tptr tvoid) ::
                                                            nil)
                                                           (tptr (Tunion __512 noattr))
                                                           cc_default)))
                               (Ecast (Econst_int (Int.repr 0) tint)
                                 (tptr tvoid)) tint)
                  (Scall None
                    (Etempvar _nodeFunc (tptr (Tfunction
                                                (tint ::
                                                 (tptr (Tstruct _GraphNode noattr)) ::
                                                 (tptr tvoid) :: nil)
                                                (tptr (Tunion __512 noattr))
                                                cc_default)))
                    ((Econst_int (Int.repr 0) tint) ::
                     (Eaddrof
                       (Efield
                         (Efield
                           (Ederef
                             (Etempvar _graphNode (tptr (Tstruct _GraphNodeHeldObject noattr)))
                             (Tstruct _GraphNodeHeldObject noattr)) _fnNode
                           (Tstruct _FnGraphNode noattr)) _node
                         (Tstruct _GraphNode noattr))
                       (tptr (Tstruct _GraphNode noattr))) ::
                     (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
                     nil))
                  Sskip))))))
      Sskip)
    (Sreturn (Some (Etempvar _graphNode (tptr (Tstruct _GraphNodeHeldObject noattr)))))))
|}.

Definition f_geo_add_child := {|
  fn_return := (tptr (Tstruct _GraphNode noattr));
  fn_callconv := cc_default;
  fn_params := ((_parent, (tptr (Tstruct _GraphNode noattr))) ::
                (_childNode, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_parentFirstChild, (tptr (Tstruct _GraphNode noattr))) ::
               (_parentLastChild, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One
                 (Etempvar _childNode (tptr (Tstruct _GraphNode noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Sassign
        (Efield
          (Ederef (Etempvar _childNode (tptr (Tstruct _GraphNode noattr)))
            (Tstruct _GraphNode noattr)) _parent
          (tptr (Tstruct _GraphNode noattr)))
        (Etempvar _parent (tptr (Tstruct _GraphNode noattr))))
      (Ssequence
        (Sset _parentFirstChild
          (Efield
            (Ederef (Etempvar _parent (tptr (Tstruct _GraphNode noattr)))
              (Tstruct _GraphNode noattr)) _children
            (tptr (Tstruct _GraphNode noattr))))
        (Sifthenelse (Ebinop Oeq
                       (Etempvar _parentFirstChild (tptr (Tstruct _GraphNode noattr)))
                       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                       tint)
          (Ssequence
            (Sassign
              (Efield
                (Ederef (Etempvar _parent (tptr (Tstruct _GraphNode noattr)))
                  (Tstruct _GraphNode noattr)) _children
                (tptr (Tstruct _GraphNode noattr)))
              (Etempvar _childNode (tptr (Tstruct _GraphNode noattr))))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _childNode (tptr (Tstruct _GraphNode noattr)))
                    (Tstruct _GraphNode noattr)) _prev
                  (tptr (Tstruct _GraphNode noattr)))
                (Etempvar _childNode (tptr (Tstruct _GraphNode noattr))))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _childNode (tptr (Tstruct _GraphNode noattr)))
                    (Tstruct _GraphNode noattr)) _next
                  (tptr (Tstruct _GraphNode noattr)))
                (Etempvar _childNode (tptr (Tstruct _GraphNode noattr))))))
          (Ssequence
            (Sset _parentLastChild
              (Efield
                (Ederef
                  (Etempvar _parentFirstChild (tptr (Tstruct _GraphNode noattr)))
                  (Tstruct _GraphNode noattr)) _prev
                (tptr (Tstruct _GraphNode noattr))))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _childNode (tptr (Tstruct _GraphNode noattr)))
                    (Tstruct _GraphNode noattr)) _prev
                  (tptr (Tstruct _GraphNode noattr)))
                (Etempvar _parentLastChild (tptr (Tstruct _GraphNode noattr))))
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _childNode (tptr (Tstruct _GraphNode noattr)))
                      (Tstruct _GraphNode noattr)) _next
                    (tptr (Tstruct _GraphNode noattr)))
                  (Etempvar _parentFirstChild (tptr (Tstruct _GraphNode noattr))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _parentFirstChild (tptr (Tstruct _GraphNode noattr)))
                        (Tstruct _GraphNode noattr)) _prev
                      (tptr (Tstruct _GraphNode noattr)))
                    (Etempvar _childNode (tptr (Tstruct _GraphNode noattr))))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _parentLastChild (tptr (Tstruct _GraphNode noattr)))
                        (Tstruct _GraphNode noattr)) _next
                      (tptr (Tstruct _GraphNode noattr)))
                    (Etempvar _childNode (tptr (Tstruct _GraphNode noattr)))))))))))
    Sskip)
  (Sreturn (Some (Etempvar _childNode (tptr (Tstruct _GraphNode noattr))))))
|}.

Definition f_geo_remove_child := {|
  fn_return := (tptr (Tstruct _GraphNode noattr));
  fn_callconv := cc_default;
  fn_params := ((_graphNode, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_parent, (tptr (Tstruct _GraphNode noattr))) ::
               (_firstChild, (tptr (tptr (Tstruct _GraphNode noattr)))) ::
               (_t'7, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'6, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'5, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'4, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'3, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'2, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'1, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _parent
    (Efield
      (Ederef (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
        (Tstruct _GraphNode noattr)) _parent
      (tptr (Tstruct _GraphNode noattr))))
  (Ssequence
    (Sset _firstChild
      (Eaddrof
        (Efield
          (Ederef (Etempvar _parent (tptr (Tstruct _GraphNode noattr)))
            (Tstruct _GraphNode noattr)) _children
          (tptr (Tstruct _GraphNode noattr)))
        (tptr (tptr (Tstruct _GraphNode noattr)))))
    (Ssequence
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
              (Tstruct _GraphNode noattr)) _prev
            (tptr (Tstruct _GraphNode noattr))))
        (Ssequence
          (Sset _t'7
            (Efield
              (Ederef
                (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
                (Tstruct _GraphNode noattr)) _next
              (tptr (Tstruct _GraphNode noattr))))
          (Sassign
            (Efield
              (Ederef (Etempvar _t'6 (tptr (Tstruct _GraphNode noattr)))
                (Tstruct _GraphNode noattr)) _next
              (tptr (Tstruct _GraphNode noattr)))
            (Etempvar _t'7 (tptr (Tstruct _GraphNode noattr))))))
      (Ssequence
        (Ssequence
          (Sset _t'4
            (Efield
              (Ederef
                (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
                (Tstruct _GraphNode noattr)) _next
              (tptr (Tstruct _GraphNode noattr))))
          (Ssequence
            (Sset _t'5
              (Efield
                (Ederef
                  (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
                  (Tstruct _GraphNode noattr)) _prev
                (tptr (Tstruct _GraphNode noattr))))
            (Sassign
              (Efield
                (Ederef (Etempvar _t'4 (tptr (Tstruct _GraphNode noattr)))
                  (Tstruct _GraphNode noattr)) _prev
                (tptr (Tstruct _GraphNode noattr)))
              (Etempvar _t'5 (tptr (Tstruct _GraphNode noattr))))))
        (Ssequence
          (Ssequence
            (Sset _t'1
              (Ederef
                (Etempvar _firstChild (tptr (tptr (Tstruct _GraphNode noattr))))
                (tptr (Tstruct _GraphNode noattr))))
            (Sifthenelse (Ebinop Oeq
                           (Etempvar _t'1 (tptr (Tstruct _GraphNode noattr)))
                           (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
                           tint)
              (Ssequence
                (Sset _t'2
                  (Efield
                    (Ederef
                      (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
                      (Tstruct _GraphNode noattr)) _next
                    (tptr (Tstruct _GraphNode noattr))))
                (Sifthenelse (Ebinop Oeq
                               (Etempvar _t'2 (tptr (Tstruct _GraphNode noattr)))
                               (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
                               tint)
                  (Sassign
                    (Ederef
                      (Etempvar _firstChild (tptr (tptr (Tstruct _GraphNode noattr))))
                      (tptr (Tstruct _GraphNode noattr)))
                    (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
                  (Ssequence
                    (Sset _t'3
                      (Efield
                        (Ederef
                          (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
                          (Tstruct _GraphNode noattr)) _next
                        (tptr (Tstruct _GraphNode noattr))))
                    (Sassign
                      (Ederef
                        (Etempvar _firstChild (tptr (tptr (Tstruct _GraphNode noattr))))
                        (tptr (Tstruct _GraphNode noattr)))
                      (Etempvar _t'3 (tptr (Tstruct _GraphNode noattr)))))))
              Sskip))
          (Sreturn (Some (Etempvar _parent (tptr (Tstruct _GraphNode noattr))))))))))
|}.

Definition f_geo_make_first_child := {|
  fn_return := (tptr (Tstruct _GraphNode noattr));
  fn_callconv := cc_default;
  fn_params := ((_newFirstChild, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_lastSibling, (tptr (Tstruct _GraphNode noattr))) ::
               (_parent, (tptr (Tstruct _GraphNode noattr))) ::
               (_firstChild, (tptr (tptr (Tstruct _GraphNode noattr)))) ::
               (_t'10, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'9, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'8, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'7, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'6, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'5, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'4, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'3, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'2, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'1, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _parent
    (Efield
      (Ederef (Etempvar _newFirstChild (tptr (Tstruct _GraphNode noattr)))
        (Tstruct _GraphNode noattr)) _parent
      (tptr (Tstruct _GraphNode noattr))))
  (Ssequence
    (Sset _firstChild
      (Eaddrof
        (Efield
          (Ederef (Etempvar _parent (tptr (Tstruct _GraphNode noattr)))
            (Tstruct _GraphNode noattr)) _children
          (tptr (Tstruct _GraphNode noattr)))
        (tptr (tptr (Tstruct _GraphNode noattr)))))
    (Ssequence
      (Ssequence
        (Sset _t'1
          (Ederef
            (Etempvar _firstChild (tptr (tptr (Tstruct _GraphNode noattr))))
            (tptr (Tstruct _GraphNode noattr))))
        (Sifthenelse (Ebinop One
                       (Etempvar _t'1 (tptr (Tstruct _GraphNode noattr)))
                       (Etempvar _newFirstChild (tptr (Tstruct _GraphNode noattr)))
                       tint)
          (Ssequence
            (Ssequence
              (Sset _t'2
                (Ederef
                  (Etempvar _firstChild (tptr (tptr (Tstruct _GraphNode noattr))))
                  (tptr (Tstruct _GraphNode noattr))))
              (Ssequence
                (Sset _t'3
                  (Efield
                    (Ederef
                      (Etempvar _t'2 (tptr (Tstruct _GraphNode noattr)))
                      (Tstruct _GraphNode noattr)) _prev
                    (tptr (Tstruct _GraphNode noattr))))
                (Sifthenelse (Ebinop One
                               (Etempvar _t'3 (tptr (Tstruct _GraphNode noattr)))
                               (Etempvar _newFirstChild (tptr (Tstruct _GraphNode noattr)))
                               tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'9
                        (Efield
                          (Ederef
                            (Etempvar _newFirstChild (tptr (Tstruct _GraphNode noattr)))
                            (Tstruct _GraphNode noattr)) _prev
                          (tptr (Tstruct _GraphNode noattr))))
                      (Ssequence
                        (Sset _t'10
                          (Efield
                            (Ederef
                              (Etempvar _newFirstChild (tptr (Tstruct _GraphNode noattr)))
                              (Tstruct _GraphNode noattr)) _next
                            (tptr (Tstruct _GraphNode noattr))))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _t'9 (tptr (Tstruct _GraphNode noattr)))
                              (Tstruct _GraphNode noattr)) _next
                            (tptr (Tstruct _GraphNode noattr)))
                          (Etempvar _t'10 (tptr (Tstruct _GraphNode noattr))))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'7
                          (Efield
                            (Ederef
                              (Etempvar _newFirstChild (tptr (Tstruct _GraphNode noattr)))
                              (Tstruct _GraphNode noattr)) _next
                            (tptr (Tstruct _GraphNode noattr))))
                        (Ssequence
                          (Sset _t'8
                            (Efield
                              (Ederef
                                (Etempvar _newFirstChild (tptr (Tstruct _GraphNode noattr)))
                                (Tstruct _GraphNode noattr)) _prev
                              (tptr (Tstruct _GraphNode noattr))))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _t'7 (tptr (Tstruct _GraphNode noattr)))
                                (Tstruct _GraphNode noattr)) _prev
                              (tptr (Tstruct _GraphNode noattr)))
                            (Etempvar _t'8 (tptr (Tstruct _GraphNode noattr))))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'6
                            (Ederef
                              (Etempvar _firstChild (tptr (tptr (Tstruct _GraphNode noattr))))
                              (tptr (Tstruct _GraphNode noattr))))
                          (Sset _lastSibling
                            (Efield
                              (Ederef
                                (Etempvar _t'6 (tptr (Tstruct _GraphNode noattr)))
                                (Tstruct _GraphNode noattr)) _prev
                              (tptr (Tstruct _GraphNode noattr)))))
                        (Ssequence
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _newFirstChild (tptr (Tstruct _GraphNode noattr)))
                                (Tstruct _GraphNode noattr)) _prev
                              (tptr (Tstruct _GraphNode noattr)))
                            (Etempvar _lastSibling (tptr (Tstruct _GraphNode noattr))))
                          (Ssequence
                            (Ssequence
                              (Sset _t'5
                                (Ederef
                                  (Etempvar _firstChild (tptr (tptr (Tstruct _GraphNode noattr))))
                                  (tptr (Tstruct _GraphNode noattr))))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _newFirstChild (tptr (Tstruct _GraphNode noattr)))
                                    (Tstruct _GraphNode noattr)) _next
                                  (tptr (Tstruct _GraphNode noattr)))
                                (Etempvar _t'5 (tptr (Tstruct _GraphNode noattr)))))
                            (Ssequence
                              (Ssequence
                                (Sset _t'4
                                  (Ederef
                                    (Etempvar _firstChild (tptr (tptr (Tstruct _GraphNode noattr))))
                                    (tptr (Tstruct _GraphNode noattr))))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'4 (tptr (Tstruct _GraphNode noattr)))
                                      (Tstruct _GraphNode noattr)) _prev
                                    (tptr (Tstruct _GraphNode noattr)))
                                  (Etempvar _newFirstChild (tptr (Tstruct _GraphNode noattr)))))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _lastSibling (tptr (Tstruct _GraphNode noattr)))
                                    (Tstruct _GraphNode noattr)) _next
                                  (tptr (Tstruct _GraphNode noattr)))
                                (Etempvar _newFirstChild (tptr (Tstruct _GraphNode noattr))))))))))
                  Sskip)))
            (Sassign
              (Ederef
                (Etempvar _firstChild (tptr (tptr (Tstruct _GraphNode noattr))))
                (tptr (Tstruct _GraphNode noattr)))
              (Etempvar _newFirstChild (tptr (Tstruct _GraphNode noattr)))))
          Sskip))
      (Sreturn (Some (Etempvar _parent (tptr (Tstruct _GraphNode noattr))))))))
|}.

Definition f_geo_call_global_function_nodes_helper := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_graphNode, (tptr (Tstruct _GraphNode noattr))) ::
                (_callContext, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_globalPtr, (tptr (tptr (Tstruct _GraphNode noattr)))) ::
               (_curNode, (tptr (Tstruct _GraphNode noattr))) ::
               (_asFnNode, (tptr (Tstruct _FnGraphNode noattr))) ::
               (_t'1, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'8,
                (tptr (Tfunction
                        (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                         (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                        cc_default))) ::
               (_t'7,
                (tptr (Tfunction
                        (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                         (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                        cc_default))) :: (_t'6, tshort) :: (_t'5, tshort) ::
               (_t'4, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'3, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'2, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _curNode (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr))))
  (Sloop
    (Ssequence
      (Sset _asFnNode
        (Ecast (Etempvar _curNode (tptr (Tstruct _GraphNode noattr)))
          (tptr (Tstruct _FnGraphNode noattr))))
      (Ssequence
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _curNode (tptr (Tstruct _GraphNode noattr)))
                (Tstruct _GraphNode noattr)) _type tshort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'6 tshort)
                         (Econst_int (Int.repr 256) tint) tint)
            (Ssequence
              (Sset _t'7
                (Efield
                  (Ederef
                    (Etempvar _asFnNode (tptr (Tstruct _FnGraphNode noattr)))
                    (Tstruct _FnGraphNode noattr)) _func
                  (tptr (Tfunction
                          (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                           (tptr tvoid) :: nil) (tptr (Tunion __512 noattr))
                          cc_default))))
              (Sifthenelse (Ebinop One
                             (Etempvar _t'7 (tptr (Tfunction
                                                    (tint ::
                                                     (tptr (Tstruct _GraphNode noattr)) ::
                                                     (tptr tvoid) :: nil)
                                                    (tptr (Tunion __512 noattr))
                                                    cc_default)))
                             (Ecast (Econst_int (Int.repr 0) tint)
                               (tptr tvoid)) tint)
                (Ssequence
                  (Sset _t'8
                    (Efield
                      (Ederef
                        (Etempvar _asFnNode (tptr (Tstruct _FnGraphNode noattr)))
                        (Tstruct _FnGraphNode noattr)) _func
                      (tptr (Tfunction
                              (tint :: (tptr (Tstruct _GraphNode noattr)) ::
                               (tptr tvoid) :: nil)
                              (tptr (Tunion __512 noattr)) cc_default))))
                  (Scall None
                    (Etempvar _t'8 (tptr (Tfunction
                                           (tint ::
                                            (tptr (Tstruct _GraphNode noattr)) ::
                                            (tptr tvoid) :: nil)
                                           (tptr (Tunion __512 noattr))
                                           cc_default)))
                    ((Etempvar _callContext tint) ::
                     (Etempvar _curNode (tptr (Tstruct _GraphNode noattr))) ::
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
                     nil)))
                Sskip))
            Sskip))
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef (Etempvar _curNode (tptr (Tstruct _GraphNode noattr)))
                (Tstruct _GraphNode noattr)) _children
              (tptr (Tstruct _GraphNode noattr))))
          (Sifthenelse (Ebinop One
                         (Etempvar _t'3 (tptr (Tstruct _GraphNode noattr)))
                         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                         tint)
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef
                      (Etempvar _curNode (tptr (Tstruct _GraphNode noattr)))
                      (Tstruct _GraphNode noattr)) _type tshort))
                (Sswitch (Etempvar _t'5 tshort)
                  (LScons (Some 4)
                    (Ssequence
                      (Sset _globalPtr
                        (Ecast
                          (Eaddrof
                            (Evar _gCurGraphNodeMasterList (tptr (Tstruct _GraphNodeMasterList noattr)))
                            (tptr (tptr (Tstruct _GraphNodeMasterList noattr))))
                          (tptr (tptr (Tstruct _GraphNode noattr)))))
                      Sbreak)
                    (LScons (Some 259)
                      (Ssequence
                        (Sset _globalPtr
                          (Ecast
                            (Eaddrof
                              (Evar _gCurGraphNodeCamFrustum (tptr (Tstruct _GraphNodePerspective noattr)))
                              (tptr (tptr (Tstruct _GraphNodePerspective noattr))))
                            (tptr (tptr (Tstruct _GraphNode noattr)))))
                        Sbreak)
                      (LScons (Some 276)
                        (Ssequence
                          (Sset _globalPtr
                            (Ecast
                              (Eaddrof
                                (Evar _gCurGraphNodeCamera (tptr (Tstruct _GraphNodeCamera noattr)))
                                (tptr (tptr (Tstruct _GraphNodeCamera noattr))))
                              (tptr (tptr (Tstruct _GraphNode noattr)))))
                          Sbreak)
                        (LScons (Some 24)
                          (Ssequence
                            (Sset _globalPtr
                              (Ecast
                                (Eaddrof
                                  (Evar _gCurGraphNodeObject (tptr (Tstruct _GraphNodeObject noattr)))
                                  (tptr (tptr (Tstruct _GraphNodeObject noattr))))
                                (tptr (tptr (Tstruct _GraphNode noattr)))))
                            Sbreak)
                          (LScons None
                            (Ssequence
                              (Sset _globalPtr
                                (Ecast (Econst_int (Int.repr 0) tint)
                                  (tptr tvoid)))
                              Sbreak)
                            LSnil)))))))
              (Ssequence
                (Sifthenelse (Ebinop One
                               (Etempvar _globalPtr (tptr (tptr (Tstruct _GraphNode noattr))))
                               (Ecast (Econst_int (Int.repr 0) tint)
                                 (tptr tvoid)) tint)
                  (Sassign
                    (Ederef
                      (Etempvar _globalPtr (tptr (tptr (Tstruct _GraphNode noattr))))
                      (tptr (Tstruct _GraphNode noattr)))
                    (Etempvar _curNode (tptr (Tstruct _GraphNode noattr))))
                  Sskip)
                (Ssequence
                  (Ssequence
                    (Sset _t'4
                      (Efield
                        (Ederef
                          (Etempvar _curNode (tptr (Tstruct _GraphNode noattr)))
                          (Tstruct _GraphNode noattr)) _children
                        (tptr (Tstruct _GraphNode noattr))))
                    (Scall None
                      (Evar _geo_call_global_function_nodes_helper (Tfunction
                                                                    ((tptr (Tstruct _GraphNode noattr)) ::
                                                                    tint ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                      ((Etempvar _t'4 (tptr (Tstruct _GraphNode noattr))) ::
                       (Etempvar _callContext tint) :: nil)))
                  (Sifthenelse (Ebinop One
                                 (Etempvar _globalPtr (tptr (tptr (Tstruct _GraphNode noattr))))
                                 (Ecast (Econst_int (Int.repr 0) tint)
                                   (tptr tvoid)) tint)
                    (Sassign
                      (Ederef
                        (Etempvar _globalPtr (tptr (tptr (Tstruct _GraphNode noattr))))
                        (tptr (Tstruct _GraphNode noattr)))
                      (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
                    Sskip))))
            Sskip))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'2
            (Efield
              (Ederef (Etempvar _curNode (tptr (Tstruct _GraphNode noattr)))
                (Tstruct _GraphNode noattr)) _next
              (tptr (Tstruct _GraphNode noattr))))
          (Sset _t'1
            (Ecast (Etempvar _t'2 (tptr (Tstruct _GraphNode noattr)))
              (tptr (Tstruct _GraphNode noattr)))))
        (Sset _curNode (Etempvar _t'1 (tptr (Tstruct _GraphNode noattr)))))
      (Sifthenelse (Ebinop One
                     (Etempvar _t'1 (tptr (Tstruct _GraphNode noattr)))
                     (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
                     tint)
        Sskip
        Sbreak))))
|}.

Definition f_geo_call_global_function_nodes := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_graphNode, (tptr (Tstruct _GraphNode noattr))) ::
                (_callContext, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'2, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Efield
      (Ederef (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
        (Tstruct _GraphNode noattr)) _flags tshort))
  (Sifthenelse (Ebinop Oand (Etempvar _t'1 tshort)
                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                   (Econst_int (Int.repr 0) tint) tint) tint)
    (Ssequence
      (Sassign
        (Evar _gCurGraphNodeRoot (tptr (Tstruct _GraphNodeRoot noattr)))
        (Ecast (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
          (tptr (Tstruct _GraphNodeRoot noattr))))
      (Ssequence
        (Ssequence
          (Sset _t'2
            (Efield
              (Ederef
                (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
                (Tstruct _GraphNode noattr)) _children
              (tptr (Tstruct _GraphNode noattr))))
          (Sifthenelse (Ebinop One
                         (Etempvar _t'2 (tptr (Tstruct _GraphNode noattr)))
                         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                         tint)
            (Ssequence
              (Sset _t'3
                (Efield
                  (Ederef
                    (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
                    (Tstruct _GraphNode noattr)) _children
                  (tptr (Tstruct _GraphNode noattr))))
              (Scall None
                (Evar _geo_call_global_function_nodes_helper (Tfunction
                                                               ((tptr (Tstruct _GraphNode noattr)) ::
                                                                tint :: nil)
                                                               tvoid
                                                               cc_default))
                ((Etempvar _t'3 (tptr (Tstruct _GraphNode noattr))) ::
                 (Etempvar _callContext tint) :: nil)))
            Sskip))
        (Sassign
          (Evar _gCurGraphNodeRoot (tptr (Tstruct _GraphNodeRoot noattr)))
          (Econst_int (Int.repr 0) tint))))
    Sskip))
|}.

Definition f_geo_reset_object_node := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_graphNode, (tptr (Tstruct _GraphNodeObject noattr))) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _init_graph_node_object (Tfunction
                                    ((tptr (Tstruct _AllocOnlyPool noattr)) ::
                                     (tptr (Tstruct _GraphNodeObject noattr)) ::
                                     (tptr (Tstruct _GraphNode noattr)) ::
                                     (tptr tfloat) :: (tptr tshort) ::
                                     (tptr tfloat) :: nil)
                                    (tptr (Tstruct _GraphNodeObject noattr))
                                    cc_default))
    ((Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
     (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr))) ::
     (Econst_int (Int.repr 0) tint) ::
     (Evar _gVec3fZero (tarray tfloat 3)) ::
     (Evar _gVec3sZero (tarray tshort 3)) ::
     (Evar _gVec3fOne (tarray tfloat 3)) :: nil))
  (Ssequence
    (Scall None
      (Evar _geo_add_child (Tfunction
                             ((tptr (Tstruct _GraphNode noattr)) ::
                              (tptr (Tstruct _GraphNode noattr)) :: nil)
                             (tptr (Tstruct _GraphNode noattr)) cc_default))
      ((Eaddrof (Evar _gObjParentGraphNode (Tstruct _GraphNode noattr))
         (tptr (Tstruct _GraphNode noattr))) ::
       (Eaddrof
         (Efield
           (Ederef
             (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
             (Tstruct _GraphNodeObject noattr)) _node
           (Tstruct _GraphNode noattr)) (tptr (Tstruct _GraphNode noattr))) ::
       nil))
    (Ssequence
      (Sset _t'1
        (Efield
          (Efield
            (Ederef
              (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
              (Tstruct _GraphNodeObject noattr)) _node
            (Tstruct _GraphNode noattr)) _flags tshort))
      (Sassign
        (Efield
          (Efield
            (Ederef
              (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
              (Tstruct _GraphNodeObject noattr)) _node
            (Tstruct _GraphNode noattr)) _flags tshort)
        (Ebinop Oand (Etempvar _t'1 tshort)
          (Eunop Onotint
            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
              (Econst_int (Int.repr 0) tint) tint) tint) tint)))))
|}.

Definition f_geo_obj_init := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_graphNode, (tptr (Tstruct _GraphNodeObject noattr))) ::
                (_sharedChild, (tptr tvoid)) :: (_pos, (tptr tfloat)) ::
                (_angle, (tptr tshort)) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tshort) :: (_t'3, tshort) :: (_t'2, tshort) ::
               (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _vec3f_set (Tfunction
                       ((tptr tfloat) :: tfloat :: tfloat :: tfloat :: nil)
                       (tptr tvoid) cc_default))
    ((Efield
       (Ederef (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
         (Tstruct _GraphNodeObject noattr)) _scale (tarray tfloat 3)) ::
     (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat) ::
     (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat) ::
     (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat) :: nil))
  (Ssequence
    (Scall None
      (Evar _vec3f_copy (Tfunction ((tptr tfloat) :: (tptr tfloat) :: nil)
                          (tptr tvoid) cc_default))
      ((Efield
         (Ederef
           (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
           (Tstruct _GraphNodeObject noattr)) _pos (tarray tfloat 3)) ::
       (Etempvar _pos (tptr tfloat)) :: nil))
    (Ssequence
      (Scall None
        (Evar _vec3s_copy (Tfunction ((tptr tshort) :: (tptr tshort) :: nil)
                            (tptr tvoid) cc_default))
        ((Efield
           (Ederef
             (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
             (Tstruct _GraphNodeObject noattr)) _angle (tarray tshort 3)) ::
         (Etempvar _angle (tptr tshort)) :: nil))
      (Ssequence
        (Sassign
          (Efield
            (Ederef
              (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
              (Tstruct _GraphNodeObject noattr)) _sharedChild
            (tptr (Tstruct _GraphNode noattr)))
          (Etempvar _sharedChild (tptr tvoid)))
        (Ssequence
          (Sassign
            (Efield
              (Ederef
                (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                (Tstruct _GraphNodeObject noattr)) _unk4C
              (tptr (Tstruct _SpawnInfo noattr)))
            (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                  (Tstruct _GraphNodeObject noattr)) _throwMatrix
                (tptr (tarray (tarray tfloat 4) 4)))
              (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                      (Tstruct _GraphNodeObject noattr)) _animInfo
                    (Tstruct _AnimInfo noattr)) _curAnim
                  (tptr (Tstruct _Animation noattr)))
                (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
              (Ssequence
                (Ssequence
                  (Sset _t'4
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                          (Tstruct _GraphNodeObject noattr)) _node
                        (Tstruct _GraphNode noattr)) _flags tshort))
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                          (Tstruct _GraphNodeObject noattr)) _node
                        (Tstruct _GraphNode noattr)) _flags tshort)
                    (Ebinop Oor (Etempvar _t'4 tshort)
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 0) tint) tint) tint)))
                (Ssequence
                  (Ssequence
                    (Sset _t'3
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                            (Tstruct _GraphNodeObject noattr)) _node
                          (Tstruct _GraphNode noattr)) _flags tshort))
                    (Sassign
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                            (Tstruct _GraphNodeObject noattr)) _node
                          (Tstruct _GraphNode noattr)) _flags tshort)
                      (Ebinop Oand (Etempvar _t'3 tshort)
                        (Eunop Onotint
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 4) tint) tint) tint) tint)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'2
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                              (Tstruct _GraphNodeObject noattr)) _node
                            (Tstruct _GraphNode noattr)) _flags tshort))
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                              (Tstruct _GraphNodeObject noattr)) _node
                            (Tstruct _GraphNode noattr)) _flags tshort)
                        (Ebinop Oor (Etempvar _t'2 tshort)
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 5) tint) tint) tint)))
                    (Ssequence
                      (Sset _t'1
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                              (Tstruct _GraphNodeObject noattr)) _node
                            (Tstruct _GraphNode noattr)) _flags tshort))
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                              (Tstruct _GraphNodeObject noattr)) _node
                            (Tstruct _GraphNode noattr)) _flags tshort)
                        (Ebinop Oand (Etempvar _t'1 tshort)
                          (Eunop Onotint
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 2) tint) tint) tint)
                          tint)))))))))))))
|}.

Definition f_geo_obj_init_spawninfo := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_graphNode, (tptr (Tstruct _GraphNodeObject noattr))) ::
                (_spawn, (tptr (Tstruct _SpawnInfo noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'10, tshort) :: (_t'9, tshort) :: (_t'8, tshort) ::
               (_t'7, tschar) :: (_t'6, tschar) ::
               (_t'5, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'4, tshort) :: (_t'3, tshort) :: (_t'2, tshort) ::
               (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _vec3f_set (Tfunction
                       ((tptr tfloat) :: tfloat :: tfloat :: tfloat :: nil)
                       (tptr tvoid) cc_default))
    ((Efield
       (Ederef (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
         (Tstruct _GraphNodeObject noattr)) _scale (tarray tfloat 3)) ::
     (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat) ::
     (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat) ::
     (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat) :: nil))
  (Ssequence
    (Scall None
      (Evar _vec3s_copy (Tfunction ((tptr tshort) :: (tptr tshort) :: nil)
                          (tptr tvoid) cc_default))
      ((Efield
         (Ederef
           (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
           (Tstruct _GraphNodeObject noattr)) _angle (tarray tshort 3)) ::
       (Efield
         (Ederef (Etempvar _spawn (tptr (Tstruct _SpawnInfo noattr)))
           (Tstruct _SpawnInfo noattr)) _startAngle (tarray tshort 3)) ::
       nil))
    (Ssequence
      (Ssequence
        (Sset _t'10
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _spawn (tptr (Tstruct _SpawnInfo noattr)))
                  (Tstruct _SpawnInfo noattr)) _startPos (tarray tshort 3))
              (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef
                  (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                  (Tstruct _GraphNodeObject noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
          (Ecast (Etempvar _t'10 tshort) tfloat)))
      (Ssequence
        (Ssequence
          (Sset _t'9
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef
                    (Etempvar _spawn (tptr (Tstruct _SpawnInfo noattr)))
                    (Tstruct _SpawnInfo noattr)) _startPos (tarray tshort 3))
                (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef
                    (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                    (Tstruct _GraphNodeObject noattr)) _pos
                  (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                (tptr tfloat)) tfloat) (Ecast (Etempvar _t'9 tshort) tfloat)))
        (Ssequence
          (Ssequence
            (Sset _t'8
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef
                      (Etempvar _spawn (tptr (Tstruct _SpawnInfo noattr)))
                      (Tstruct _SpawnInfo noattr)) _startPos
                    (tarray tshort 3)) (Econst_int (Int.repr 2) tint)
                  (tptr tshort)) tshort))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef
                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                      (Tstruct _GraphNodeObject noattr)) _pos
                    (tarray tfloat 3)) (Econst_int (Int.repr 2) tint)
                  (tptr tfloat)) tfloat)
              (Ecast (Etempvar _t'8 tshort) tfloat)))
          (Ssequence
            (Ssequence
              (Sset _t'7
                (Efield
                  (Ederef
                    (Etempvar _spawn (tptr (Tstruct _SpawnInfo noattr)))
                    (Tstruct _SpawnInfo noattr)) _areaIndex tschar))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                    (Tstruct _GraphNodeObject noattr)) _areaIndex tschar)
                (Etempvar _t'7 tschar)))
            (Ssequence
              (Ssequence
                (Sset _t'6
                  (Efield
                    (Ederef
                      (Etempvar _spawn (tptr (Tstruct _SpawnInfo noattr)))
                      (Tstruct _SpawnInfo noattr)) _activeAreaIndex tschar))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                      (Tstruct _GraphNodeObject noattr)) _activeAreaIndex
                    tschar) (Etempvar _t'6 tschar)))
              (Ssequence
                (Ssequence
                  (Sset _t'5
                    (Efield
                      (Ederef
                        (Etempvar _spawn (tptr (Tstruct _SpawnInfo noattr)))
                        (Tstruct _SpawnInfo noattr)) _model
                      (tptr (Tstruct _GraphNode noattr))))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                        (Tstruct _GraphNodeObject noattr)) _sharedChild
                      (tptr (Tstruct _GraphNode noattr)))
                    (Etempvar _t'5 (tptr (Tstruct _GraphNode noattr)))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                        (Tstruct _GraphNodeObject noattr)) _unk4C
                      (tptr (Tstruct _SpawnInfo noattr)))
                    (Etempvar _spawn (tptr (Tstruct _SpawnInfo noattr))))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                          (Tstruct _GraphNodeObject noattr)) _throwMatrix
                        (tptr (tarray (tarray tfloat 4) 4)))
                      (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                              (Tstruct _GraphNodeObject noattr)) _animInfo
                            (Tstruct _AnimInfo noattr)) _curAnim
                          (tptr (Tstruct _Animation noattr)))
                        (Econst_int (Int.repr 0) tint))
                      (Ssequence
                        (Ssequence
                          (Sset _t'4
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                                  (Tstruct _GraphNodeObject noattr)) _node
                                (Tstruct _GraphNode noattr)) _flags tshort))
                          (Sassign
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                                  (Tstruct _GraphNodeObject noattr)) _node
                                (Tstruct _GraphNode noattr)) _flags tshort)
                            (Ebinop Oor (Etempvar _t'4 tshort)
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 0) tint) tint) tint)))
                        (Ssequence
                          (Ssequence
                            (Sset _t'3
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                                    (Tstruct _GraphNodeObject noattr)) _node
                                  (Tstruct _GraphNode noattr)) _flags tshort))
                            (Sassign
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                                    (Tstruct _GraphNodeObject noattr)) _node
                                  (Tstruct _GraphNode noattr)) _flags tshort)
                              (Ebinop Oand (Etempvar _t'3 tshort)
                                (Eunop Onotint
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 4) tint) tint)
                                  tint) tint)))
                          (Ssequence
                            (Ssequence
                              (Sset _t'2
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                                      (Tstruct _GraphNodeObject noattr))
                                    _node (Tstruct _GraphNode noattr)) _flags
                                  tshort))
                              (Sassign
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                                      (Tstruct _GraphNodeObject noattr))
                                    _node (Tstruct _GraphNode noattr)) _flags
                                  tshort)
                                (Ebinop Oor (Etempvar _t'2 tshort)
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 5) tint) tint)
                                  tint)))
                            (Ssequence
                              (Sset _t'1
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                                      (Tstruct _GraphNodeObject noattr))
                                    _node (Tstruct _GraphNode noattr)) _flags
                                  tshort))
                              (Sassign
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                                      (Tstruct _GraphNodeObject noattr))
                                    _node (Tstruct _GraphNode noattr)) _flags
                                  tshort)
                                (Ebinop Oand (Etempvar _t'1 tshort)
                                  (Eunop Onotint
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 2) tint) tint)
                                    tint) tint)))))))))))))))))
|}.

Definition f_geo_obj_init_animation := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_graphNode, (tptr (Tstruct _GraphNodeObject noattr))) ::
                (_animPtrAddr, (tptr (tptr (Tstruct _Animation noattr)))) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_animSegmented, (tptr (tptr (Tstruct _Animation noattr)))) ::
               (_anim, (tptr (Tstruct _Animation noattr))) :: (_t'3, tint) ::
               (_t'2, (tptr tvoid)) :: (_t'1, (tptr tvoid)) ::
               (_t'7, (tptr (Tstruct _Animation noattr))) ::
               (_t'6, tshort) :: (_t'5, tshort) ::
               (_t'4, (tptr (Tstruct _Animation noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                    (tptr tvoid) cc_default))
      ((Etempvar _animPtrAddr (tptr (tptr (Tstruct _Animation noattr)))) ::
       nil))
    (Sset _animSegmented (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'7
          (Ederef
            (Etempvar _animSegmented (tptr (tptr (Tstruct _Animation noattr))))
            (tptr (Tstruct _Animation noattr))))
        (Scall (Some _t'2)
          (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                        (tptr tvoid) cc_default))
          ((Etempvar _t'7 (tptr (Tstruct _Animation noattr))) :: nil)))
      (Sset _anim (Etempvar _t'2 (tptr tvoid))))
    (Ssequence
      (Sset _t'4
        (Efield
          (Efield
            (Ederef
              (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
              (Tstruct _GraphNodeObject noattr)) _animInfo
            (Tstruct _AnimInfo noattr)) _curAnim
          (tptr (Tstruct _Animation noattr))))
      (Sifthenelse (Ebinop One
                     (Etempvar _t'4 (tptr (Tstruct _Animation noattr)))
                     (Etempvar _anim (tptr (Tstruct _Animation noattr)))
                     tint)
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Ederef
                  (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                  (Tstruct _GraphNodeObject noattr)) _animInfo
                (Tstruct _AnimInfo noattr)) _curAnim
              (tptr (Tstruct _Animation noattr)))
            (Etempvar _anim (tptr (Tstruct _Animation noattr))))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'6
                  (Efield
                    (Ederef
                      (Etempvar _anim (tptr (Tstruct _Animation noattr)))
                      (Tstruct _Animation noattr)) _flags tshort))
                (Sifthenelse (Ebinop Oand (Etempvar _t'6 tshort)
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 1) tint) tint) tint)
                  (Sset _t'3 (Ecast (Econst_int (Int.repr 1) tint) tint))
                  (Sset _t'3
                    (Ecast (Eunop Oneg (Econst_int (Int.repr 1) tint) tint)
                      tint))))
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef
                      (Etempvar _anim (tptr (Tstruct _Animation noattr)))
                      (Tstruct _Animation noattr)) _startFrame tshort))
                (Sassign
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                        (Tstruct _GraphNodeObject noattr)) _animInfo
                      (Tstruct _AnimInfo noattr)) _animFrame tshort)
                  (Ebinop Oadd (Etempvar _t'5 tshort) (Etempvar _t'3 tint)
                    tint))))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                      (Tstruct _GraphNodeObject noattr)) _animInfo
                    (Tstruct _AnimInfo noattr)) _animAccel tint)
                (Econst_int (Int.repr 0) tint))
              (Sassign
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                      (Tstruct _GraphNodeObject noattr)) _animInfo
                    (Tstruct _AnimInfo noattr)) _animYTrans tshort)
                (Econst_int (Int.repr 0) tint)))))
        Sskip))))
|}.

Definition f_geo_obj_init_animation_accel := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_graphNode, (tptr (Tstruct _GraphNodeObject noattr))) ::
                (_animPtrAddr, (tptr (tptr (Tstruct _Animation noattr)))) ::
                (_animAccel, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_animSegmented, (tptr (tptr (Tstruct _Animation noattr)))) ::
               (_anim, (tptr (Tstruct _Animation noattr))) ::
               (_t'3, tuint) :: (_t'2, (tptr tvoid)) ::
               (_t'1, (tptr tvoid)) ::
               (_t'8, (tptr (Tstruct _Animation noattr))) ::
               (_t'7, tshort) :: (_t'6, tshort) :: (_t'5, tint) ::
               (_t'4, (tptr (Tstruct _Animation noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                    (tptr tvoid) cc_default))
      ((Etempvar _animPtrAddr (tptr (tptr (Tstruct _Animation noattr)))) ::
       nil))
    (Sset _animSegmented (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'8
          (Ederef
            (Etempvar _animSegmented (tptr (tptr (Tstruct _Animation noattr))))
            (tptr (Tstruct _Animation noattr))))
        (Scall (Some _t'2)
          (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                        (tptr tvoid) cc_default))
          ((Etempvar _t'8 (tptr (Tstruct _Animation noattr))) :: nil)))
      (Sset _anim (Etempvar _t'2 (tptr tvoid))))
    (Ssequence
      (Ssequence
        (Sset _t'4
          (Efield
            (Efield
              (Ederef
                (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                (Tstruct _GraphNodeObject noattr)) _animInfo
              (Tstruct _AnimInfo noattr)) _curAnim
            (tptr (Tstruct _Animation noattr))))
        (Sifthenelse (Ebinop One
                       (Etempvar _t'4 (tptr (Tstruct _Animation noattr)))
                       (Etempvar _anim (tptr (Tstruct _Animation noattr)))
                       tint)
          (Ssequence
            (Sassign
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                    (Tstruct _GraphNodeObject noattr)) _animInfo
                  (Tstruct _AnimInfo noattr)) _curAnim
                (tptr (Tstruct _Animation noattr)))
              (Etempvar _anim (tptr (Tstruct _Animation noattr))))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                      (Tstruct _GraphNodeObject noattr)) _animInfo
                    (Tstruct _AnimInfo noattr)) _animYTrans tshort)
                (Econst_int (Int.repr 0) tint))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'7
                      (Efield
                        (Ederef
                          (Etempvar _anim (tptr (Tstruct _Animation noattr)))
                          (Tstruct _Animation noattr)) _flags tshort))
                    (Sifthenelse (Ebinop Oand (Etempvar _t'7 tshort)
                                   (Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 1) tint) tint)
                                   tint)
                      (Sset _t'3 (Ecast (Etempvar _animAccel tuint) tuint))
                      (Sset _t'3
                        (Ecast (Eunop Oneg (Etempvar _animAccel tuint) tuint)
                          tuint))))
                  (Ssequence
                    (Sset _t'6
                      (Efield
                        (Ederef
                          (Etempvar _anim (tptr (Tstruct _Animation noattr)))
                          (Tstruct _Animation noattr)) _startFrame tshort))
                    (Sassign
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                            (Tstruct _GraphNodeObject noattr)) _animInfo
                          (Tstruct _AnimInfo noattr)) _animFrameAccelAssist
                        tint)
                      (Ebinop Oadd
                        (Ebinop Oshl (Etempvar _t'6 tshort)
                          (Econst_int (Int.repr 16) tint) tint)
                        (Etempvar _t'3 tuint) tuint))))
                (Ssequence
                  (Sset _t'5
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                          (Tstruct _GraphNodeObject noattr)) _animInfo
                        (Tstruct _AnimInfo noattr)) _animFrameAccelAssist
                      tint))
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
                          (Tstruct _GraphNodeObject noattr)) _animInfo
                        (Tstruct _AnimInfo noattr)) _animFrame tshort)
                    (Ebinop Oshr (Etempvar _t'5 tint)
                      (Econst_int (Int.repr 16) tint) tint))))))
          Sskip))
      (Sassign
        (Efield
          (Efield
            (Ederef
              (Etempvar _graphNode (tptr (Tstruct _GraphNodeObject noattr)))
              (Tstruct _GraphNodeObject noattr)) _animInfo
            (Tstruct _AnimInfo noattr)) _animAccel tint)
        (Etempvar _animAccel tuint)))))
|}.

Definition f_retrieve_animation_index := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_frame, tint) :: (_attributes, (tptr (tptr tushort))) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_result, tint) :: (_t'9, tushort) ::
               (_t'8, (tptr tushort)) :: (_t'7, tushort) ::
               (_t'6, (tptr tushort)) :: (_t'5, tushort) ::
               (_t'4, (tptr tushort)) :: (_t'3, tushort) ::
               (_t'2, (tptr tushort)) :: (_t'1, (tptr tushort)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2
      (Ederef (Etempvar _attributes (tptr (tptr tushort))) (tptr tushort)))
    (Ssequence
      (Sset _t'3
        (Ederef
          (Ebinop Oadd (Etempvar _t'2 (tptr tushort))
            (Econst_int (Int.repr 0) tint) (tptr tushort)) tushort))
      (Sifthenelse (Ebinop Olt (Etempvar _frame tint) (Etempvar _t'3 tushort)
                     tint)
        (Ssequence
          (Sset _t'8
            (Ederef (Etempvar _attributes (tptr (tptr tushort)))
              (tptr tushort)))
          (Ssequence
            (Sset _t'9
              (Ederef
                (Ebinop Oadd (Etempvar _t'8 (tptr tushort))
                  (Econst_int (Int.repr 1) tint) (tptr tushort)) tushort))
            (Sset _result
              (Ebinop Oadd (Etempvar _t'9 tushort) (Etempvar _frame tint)
                tint))))
        (Ssequence
          (Sset _t'4
            (Ederef (Etempvar _attributes (tptr (tptr tushort)))
              (tptr tushort)))
          (Ssequence
            (Sset _t'5
              (Ederef
                (Ebinop Oadd (Etempvar _t'4 (tptr tushort))
                  (Econst_int (Int.repr 1) tint) (tptr tushort)) tushort))
            (Ssequence
              (Sset _t'6
                (Ederef (Etempvar _attributes (tptr (tptr tushort)))
                  (tptr tushort)))
              (Ssequence
                (Sset _t'7
                  (Ederef
                    (Ebinop Oadd (Etempvar _t'6 (tptr tushort))
                      (Econst_int (Int.repr 0) tint) (tptr tushort)) tushort))
                (Sset _result
                  (Ebinop Osub
                    (Ebinop Oadd (Etempvar _t'5 tushort)
                      (Etempvar _t'7 tushort) tint)
                    (Econst_int (Int.repr 1) tint) tint)))))))))
  (Ssequence
    (Ssequence
      (Sset _t'1
        (Ederef (Etempvar _attributes (tptr (tptr tushort))) (tptr tushort)))
      (Sassign
        (Ederef (Etempvar _attributes (tptr (tptr tushort))) (tptr tushort))
        (Ebinop Oadd (Etempvar _t'1 (tptr tushort))
          (Econst_int (Int.repr 2) tint) (tptr tushort))))
    (Sreturn (Some (Etempvar _result tint)))))
|}.

Definition f_geo_update_animation_frame := {|
  fn_return := tshort;
  fn_callconv := cc_default;
  fn_params := ((_obj, (tptr (Tstruct _AnimInfo noattr))) ::
                (_accelAssist, (tptr tint)) :: nil);
  fn_vars := nil;
  fn_temps := ((_result, tint) ::
               (_anim, (tptr (Tstruct _Animation noattr))) :: (_t'1, tint) ::
               (_t'23, tshort) :: (_t'22, tushort) :: (_t'21, tushort) ::
               (_t'20, tint) :: (_t'19, tshort) :: (_t'18, tint) ::
               (_t'17, tint) :: (_t'16, tshort) :: (_t'15, tint) ::
               (_t'14, tshort) :: (_t'13, tshort) :: (_t'12, tshort) ::
               (_t'11, tshort) :: (_t'10, tint) :: (_t'9, tint) ::
               (_t'8, tshort) :: (_t'7, tint) :: (_t'6, tshort) ::
               (_t'5, tshort) :: (_t'4, tshort) :: (_t'3, tshort) ::
               (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _anim
    (Efield
      (Ederef (Etempvar _obj (tptr (Tstruct _AnimInfo noattr)))
        (Tstruct _AnimInfo noattr)) _curAnim
      (tptr (Tstruct _Animation noattr))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'21
          (Efield
            (Ederef (Etempvar _obj (tptr (Tstruct _AnimInfo noattr)))
              (Tstruct _AnimInfo noattr)) _animTimer tushort))
        (Ssequence
          (Sset _t'22 (Evar _gAreaUpdateCounter tushort))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'21 tushort)
                         (Etempvar _t'22 tushort) tint)
            (Sset _t'1 (Econst_int (Int.repr 1) tint))
            (Ssequence
              (Sset _t'23
                (Efield
                  (Ederef (Etempvar _anim (tptr (Tstruct _Animation noattr)))
                    (Tstruct _Animation noattr)) _flags tshort))
              (Sset _t'1
                (Ecast
                  (Ebinop Oand (Etempvar _t'23 tshort)
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 2) tint) tint) tint) tbool))))))
      (Sifthenelse (Etempvar _t'1 tint)
        (Ssequence
          (Sifthenelse (Ebinop One (Etempvar _accelAssist (tptr tint))
                         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                         tint)
            (Ssequence
              (Sset _t'20
                (Efield
                  (Ederef (Etempvar _obj (tptr (Tstruct _AnimInfo noattr)))
                    (Tstruct _AnimInfo noattr)) _animFrameAccelAssist tint))
              (Sassign
                (Ederef
                  (Ebinop Oadd (Etempvar _accelAssist (tptr tint))
                    (Econst_int (Int.repr 0) tint) (tptr tint)) tint)
                (Etempvar _t'20 tint)))
            Sskip)
          (Ssequence
            (Sset _t'19
              (Efield
                (Ederef (Etempvar _obj (tptr (Tstruct _AnimInfo noattr)))
                  (Tstruct _AnimInfo noattr)) _animFrame tshort))
            (Sreturn (Some (Etempvar _t'19 tshort)))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _anim (tptr (Tstruct _Animation noattr)))
              (Tstruct _Animation noattr)) _flags tshort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'2 tshort)
                       (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 1) tint) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'15
                (Efield
                  (Ederef (Etempvar _obj (tptr (Tstruct _AnimInfo noattr)))
                    (Tstruct _AnimInfo noattr)) _animAccel tint))
              (Sifthenelse (Ebinop One (Etempvar _t'15 tint)
                             (Econst_int (Int.repr 0) tint) tint)
                (Ssequence
                  (Sset _t'17
                    (Efield
                      (Ederef
                        (Etempvar _obj (tptr (Tstruct _AnimInfo noattr)))
                        (Tstruct _AnimInfo noattr)) _animFrameAccelAssist
                      tint))
                  (Ssequence
                    (Sset _t'18
                      (Efield
                        (Ederef
                          (Etempvar _obj (tptr (Tstruct _AnimInfo noattr)))
                          (Tstruct _AnimInfo noattr)) _animAccel tint))
                    (Sset _result
                      (Ebinop Osub (Etempvar _t'17 tint)
                        (Etempvar _t'18 tint) tint))))
                (Ssequence
                  (Sset _t'16
                    (Efield
                      (Ederef
                        (Etempvar _obj (tptr (Tstruct _AnimInfo noattr)))
                        (Tstruct _AnimInfo noattr)) _animFrame tshort))
                  (Sset _result
                    (Ebinop Oshl
                      (Ebinop Osub (Etempvar _t'16 tshort)
                        (Econst_int (Int.repr 1) tint) tint)
                      (Econst_int (Int.repr 16) tint) tint)))))
            (Ssequence
              (Sset _t'11
                (Efield
                  (Ederef (Etempvar _anim (tptr (Tstruct _Animation noattr)))
                    (Tstruct _Animation noattr)) _loopStart tshort))
              (Sifthenelse (Ebinop Olt
                             (Ecast
                               (Ebinop Oshr (Etempvar _result tint)
                                 (Econst_int (Int.repr 16) tint) tint)
                               tshort) (Etempvar _t'11 tshort) tint)
                (Ssequence
                  (Sset _t'12
                    (Efield
                      (Ederef
                        (Etempvar _anim (tptr (Tstruct _Animation noattr)))
                        (Tstruct _Animation noattr)) _flags tshort))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'12 tshort)
                                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                   (Econst_int (Int.repr 0) tint) tint) tint)
                    (Ssequence
                      (Sset _t'14
                        (Efield
                          (Ederef
                            (Etempvar _anim (tptr (Tstruct _Animation noattr)))
                            (Tstruct _Animation noattr)) _loopStart tshort))
                      (Sset _result
                        (Ebinop Oor
                          (Ebinop Oand (Etempvar _result tint)
                            (Econst_int (Int.repr 65535) tint) tint)
                          (Ebinop Oshl (Etempvar _t'14 tshort)
                            (Econst_int (Int.repr 16) tint) tint) tint)))
                    (Ssequence
                      (Sset _t'13
                        (Efield
                          (Ederef
                            (Etempvar _anim (tptr (Tstruct _Animation noattr)))
                            (Tstruct _Animation noattr)) _loopEnd tshort))
                      (Sset _result
                        (Ebinop Oor
                          (Ebinop Oand (Etempvar _result tint)
                            (Econst_int (Int.repr 65535) tint) tint)
                          (Ebinop Oshl
                            (Ebinop Osub (Etempvar _t'13 tshort)
                              (Econst_int (Int.repr 1) tint) tint)
                            (Econst_int (Int.repr 16) tint) tint) tint)))))
                Sskip)))
          (Ssequence
            (Ssequence
              (Sset _t'7
                (Efield
                  (Ederef (Etempvar _obj (tptr (Tstruct _AnimInfo noattr)))
                    (Tstruct _AnimInfo noattr)) _animAccel tint))
              (Sifthenelse (Ebinop One (Etempvar _t'7 tint)
                             (Econst_int (Int.repr 0) tint) tint)
                (Ssequence
                  (Sset _t'9
                    (Efield
                      (Ederef
                        (Etempvar _obj (tptr (Tstruct _AnimInfo noattr)))
                        (Tstruct _AnimInfo noattr)) _animFrameAccelAssist
                      tint))
                  (Ssequence
                    (Sset _t'10
                      (Efield
                        (Ederef
                          (Etempvar _obj (tptr (Tstruct _AnimInfo noattr)))
                          (Tstruct _AnimInfo noattr)) _animAccel tint))
                    (Sset _result
                      (Ebinop Oadd (Etempvar _t'9 tint) (Etempvar _t'10 tint)
                        tint))))
                (Ssequence
                  (Sset _t'8
                    (Efield
                      (Ederef
                        (Etempvar _obj (tptr (Tstruct _AnimInfo noattr)))
                        (Tstruct _AnimInfo noattr)) _animFrame tshort))
                  (Sset _result
                    (Ebinop Oshl
                      (Ebinop Oadd (Etempvar _t'8 tshort)
                        (Econst_int (Int.repr 1) tint) tint)
                      (Econst_int (Int.repr 16) tint) tint)))))
            (Ssequence
              (Sset _t'3
                (Efield
                  (Ederef (Etempvar _anim (tptr (Tstruct _Animation noattr)))
                    (Tstruct _Animation noattr)) _loopEnd tshort))
              (Sifthenelse (Ebinop Oge
                             (Ecast
                               (Ebinop Oshr (Etempvar _result tint)
                                 (Econst_int (Int.repr 16) tint) tint)
                               tshort) (Etempvar _t'3 tshort) tint)
                (Ssequence
                  (Sset _t'4
                    (Efield
                      (Ederef
                        (Etempvar _anim (tptr (Tstruct _Animation noattr)))
                        (Tstruct _Animation noattr)) _flags tshort))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'4 tshort)
                                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                   (Econst_int (Int.repr 0) tint) tint) tint)
                    (Ssequence
                      (Sset _t'6
                        (Efield
                          (Ederef
                            (Etempvar _anim (tptr (Tstruct _Animation noattr)))
                            (Tstruct _Animation noattr)) _loopEnd tshort))
                      (Sset _result
                        (Ebinop Oor
                          (Ebinop Oand (Etempvar _result tint)
                            (Econst_int (Int.repr 65535) tint) tint)
                          (Ebinop Oshl
                            (Ebinop Osub (Etempvar _t'6 tshort)
                              (Econst_int (Int.repr 1) tint) tint)
                            (Econst_int (Int.repr 16) tint) tint) tint)))
                    (Ssequence
                      (Sset _t'5
                        (Efield
                          (Ederef
                            (Etempvar _anim (tptr (Tstruct _Animation noattr)))
                            (Tstruct _Animation noattr)) _loopStart tshort))
                      (Sset _result
                        (Ebinop Oor
                          (Ebinop Oand (Etempvar _result tint)
                            (Econst_int (Int.repr 65535) tint) tint)
                          (Ebinop Oshl (Etempvar _t'5 tshort)
                            (Econst_int (Int.repr 16) tint) tint) tint)))))
                Sskip)))))
      (Ssequence
        (Sifthenelse (Ebinop One (Etempvar _accelAssist (tptr tint))
                       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                       tint)
          (Sassign
            (Ederef
              (Ebinop Oadd (Etempvar _accelAssist (tptr tint))
                (Econst_int (Int.repr 0) tint) (tptr tint)) tint)
            (Etempvar _result tint))
          Sskip)
        (Sreturn (Some (Ecast
                         (Ebinop Oshr (Etempvar _result tint)
                           (Econst_int (Int.repr 16) tint) tint) tshort)))))))
|}.

Definition f_geo_retreive_animation_translation := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_obj, (tptr (Tstruct _GraphNodeObject noattr))) ::
                (_position, (tptr tfloat)) :: nil);
  fn_vars := ((_attribute, (tptr tushort)) :: nil);
  fn_temps := ((_animation, (tptr (Tstruct _Animation noattr))) ::
               (_values, (tptr tshort)) :: (_frame, tshort) ::
               (_t'5, tint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, (tptr tvoid)) :: (_t'1, (tptr tvoid)) ::
               (_t'11, (tptr tushort)) :: (_t'10, (tptr tshort)) ::
               (_t'9, tshort) :: (_t'8, tshort) :: (_t'7, tshort) ::
               (_t'6, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _animation
    (Efield
      (Efield
        (Ederef (Etempvar _obj (tptr (Tstruct _GraphNodeObject noattr)))
          (Tstruct _GraphNodeObject noattr)) _animInfo
        (Tstruct _AnimInfo noattr)) _curAnim
      (tptr (Tstruct _Animation noattr))))
  (Sifthenelse (Ebinop One
                 (Etempvar _animation (tptr (Tstruct _Animation noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'11
            (Efield
              (Ederef
                (Etempvar _animation (tptr (Tstruct _Animation noattr)))
                (Tstruct _Animation noattr)) _index (tptr tushort)))
          (Scall (Some _t'1)
            (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                          (tptr tvoid) cc_default))
            ((Ecast (Etempvar _t'11 (tptr tushort)) (tptr tvoid)) :: nil)))
        (Sassign (Evar _attribute (tptr tushort))
          (Etempvar _t'1 (tptr tvoid))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'10
              (Efield
                (Ederef
                  (Etempvar _animation (tptr (Tstruct _Animation noattr)))
                  (Tstruct _Animation noattr)) _values (tptr tshort)))
            (Scall (Some _t'2)
              (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                            (tptr tvoid) cc_default))
              ((Ecast (Etempvar _t'10 (tptr tshort)) (tptr tvoid)) :: nil)))
          (Sset _values (Etempvar _t'2 (tptr tvoid))))
        (Ssequence
          (Ssequence
            (Sset _t'9
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _obj (tptr (Tstruct _GraphNodeObject noattr)))
                    (Tstruct _GraphNodeObject noattr)) _animInfo
                  (Tstruct _AnimInfo noattr)) _animFrame tshort))
            (Sset _frame (Ecast (Etempvar _t'9 tshort) tshort)))
          (Ssequence
            (Sifthenelse (Ebinop Olt (Etempvar _frame tshort)
                           (Econst_int (Int.repr 0) tint) tint)
              (Sset _frame (Ecast (Econst_int (Int.repr 0) tint) tshort))
              Sskip)
            (Ssequence
              (Ssequence
                (Scall (Some _t'3)
                  (Evar _retrieve_animation_index (Tfunction
                                                    (tint ::
                                                     (tptr (tptr tushort)) ::
                                                     nil) tint cc_default))
                  ((Etempvar _frame tshort) ::
                   (Eaddrof (Evar _attribute (tptr tushort))
                     (tptr (tptr tushort))) :: nil))
                (Ssequence
                  (Sset _t'8
                    (Ederef
                      (Ebinop Oadd (Etempvar _values (tptr tshort))
                        (Etempvar _t'3 tint) (tptr tshort)) tshort))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd (Etempvar _position (tptr tfloat))
                        (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
                    (Ecast (Etempvar _t'8 tshort) tfloat))))
              (Ssequence
                (Ssequence
                  (Scall (Some _t'4)
                    (Evar _retrieve_animation_index (Tfunction
                                                      (tint ::
                                                       (tptr (tptr tushort)) ::
                                                       nil) tint cc_default))
                    ((Etempvar _frame tshort) ::
                     (Eaddrof (Evar _attribute (tptr tushort))
                       (tptr (tptr tushort))) :: nil))
                  (Ssequence
                    (Sset _t'7
                      (Ederef
                        (Ebinop Oadd (Etempvar _values (tptr tshort))
                          (Etempvar _t'4 tint) (tptr tshort)) tshort))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd (Etempvar _position (tptr tfloat))
                          (Econst_int (Int.repr 1) tint) (tptr tfloat))
                        tfloat) (Ecast (Etempvar _t'7 tshort) tfloat))))
                (Ssequence
                  (Scall (Some _t'5)
                    (Evar _retrieve_animation_index (Tfunction
                                                      (tint ::
                                                       (tptr (tptr tushort)) ::
                                                       nil) tint cc_default))
                    ((Etempvar _frame tshort) ::
                     (Eaddrof (Evar _attribute (tptr tushort))
                       (tptr (tptr tushort))) :: nil))
                  (Ssequence
                    (Sset _t'6
                      (Ederef
                        (Ebinop Oadd (Etempvar _values (tptr tshort))
                          (Etempvar _t'5 tint) (tptr tshort)) tshort))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd (Etempvar _position (tptr tfloat))
                          (Econst_int (Int.repr 2) tint) (tptr tfloat))
                        tfloat) (Ecast (Etempvar _t'6 tshort) tfloat))))))))))
    (Scall None
      (Evar _vec3f_set (Tfunction
                         ((tptr tfloat) :: tfloat :: tfloat :: tfloat :: nil)
                         (tptr tvoid) cc_default))
      ((Etempvar _position (tptr tfloat)) ::
       (Econst_int (Int.repr 0) tint) :: (Econst_int (Int.repr 0) tint) ::
       (Econst_int (Int.repr 0) tint) :: nil))))
|}.

Definition f_geo_find_root := {|
  fn_return := (tptr (Tstruct _GraphNodeRoot noattr));
  fn_callconv := cc_default;
  fn_params := ((_graphNode, (tptr (Tstruct _GraphNode noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_resGraphNode, (tptr (Tstruct _GraphNodeRoot noattr))) ::
               (_t'2, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _resGraphNode (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Sloop
      (Ssequence
        (Ssequence
          (Sset _t'2
            (Efield
              (Ederef
                (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
                (Tstruct _GraphNode noattr)) _parent
              (tptr (Tstruct _GraphNode noattr))))
          (Sifthenelse (Ebinop One
                         (Etempvar _t'2 (tptr (Tstruct _GraphNode noattr)))
                         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                         tint)
            Sskip
            Sbreak))
        (Sset _graphNode
          (Efield
            (Ederef (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
              (Tstruct _GraphNode noattr)) _parent
            (tptr (Tstruct _GraphNode noattr)))))
      Sskip)
    (Ssequence
      (Ssequence
        (Sset _t'1
          (Efield
            (Ederef (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
              (Tstruct _GraphNode noattr)) _type tshort))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tshort)
                       (Econst_int (Int.repr 1) tint) tint)
          (Sset _resGraphNode
            (Ecast (Etempvar _graphNode (tptr (Tstruct _GraphNode noattr)))
              (tptr (Tstruct _GraphNodeRoot noattr))))
          Sskip))
      (Sreturn (Some (Etempvar _resGraphNode (tptr (Tstruct _GraphNodeRoot noattr))))))))
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
 Composite __1341 Union
   (Member_plain _mode tint ::
    Member_plain _camera (tptr (Tstruct _Camera noattr)) :: nil)
   noattr ::
 Composite _GraphNodeCamera Struct
   (Member_plain _fnNode (Tstruct _FnGraphNode noattr) ::
    Member_plain _config (Tunion __1341 noattr) ::
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
 (_segmented_to_virtual,
   Gfun(External (EF_external "segmented_to_virtual"
                   (mksignature (AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr tvoid) :: nil) (tptr tvoid) cc_default)) ::
 (_alloc_only_pool_alloc,
   Gfun(External (EF_external "alloc_only_pool_alloc"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xptr
                     cc_default))
     ((tptr (Tstruct _AllocOnlyPool noattr)) :: tint :: nil) (tptr tvoid)
     cc_default)) :: (_gCurGraphNodeRoot, Gvar v_gCurGraphNodeRoot) ::
 (_gCurGraphNodeMasterList, Gvar v_gCurGraphNodeMasterList) ::
 (_gCurGraphNodeCamFrustum, Gvar v_gCurGraphNodeCamFrustum) ::
 (_gCurGraphNodeCamera, Gvar v_gCurGraphNodeCamera) ::
 (_gCurGraphNodeObject, Gvar v_gCurGraphNodeObject) ::
 (_gAreaUpdateCounter, Gvar v_gAreaUpdateCounter) ::
 (_gObjParentGraphNode, Gvar v_gObjParentGraphNode) ::
 (_identityMtx, Gvar v_identityMtx) :: (_zeroMtx, Gvar v_zeroMtx) ::
 (_gVec3fZero, Gvar v_gVec3fZero) :: (_gVec3sZero, Gvar v_gVec3sZero) ::
 (_gVec3fOne, Gvar v_gVec3fOne) :: (_gVec3sOne, Gvar v_gVec3sOne) ::
 (_init_scene_graph_node_links, Gfun(Internal f_init_scene_graph_node_links)) ::
 (_init_graph_node_root, Gfun(Internal f_init_graph_node_root)) ::
 (_init_graph_node_ortho_projection, Gfun(Internal f_init_graph_node_ortho_projection)) ::
 (_init_graph_node_perspective, Gfun(Internal f_init_graph_node_perspective)) ::
 (_init_graph_node_start, Gfun(Internal f_init_graph_node_start)) ::
 (_init_graph_node_master_list, Gfun(Internal f_init_graph_node_master_list)) ::
 (_init_graph_node_render_range, Gfun(Internal f_init_graph_node_render_range)) ::
 (_init_graph_node_switch_case, Gfun(Internal f_init_graph_node_switch_case)) ::
 (_init_graph_node_camera, Gfun(Internal f_init_graph_node_camera)) ::
 (_init_graph_node_translation_rotation, Gfun(Internal f_init_graph_node_translation_rotation)) ::
 (_init_graph_node_translation, Gfun(Internal f_init_graph_node_translation)) ::
 (_init_graph_node_rotation, Gfun(Internal f_init_graph_node_rotation)) ::
 (_init_graph_node_scale, Gfun(Internal f_init_graph_node_scale)) ::
 (_init_graph_node_object, Gfun(Internal f_init_graph_node_object)) ::
 (_init_graph_node_culling_radius, Gfun(Internal f_init_graph_node_culling_radius)) ::
 (_init_graph_node_animated_part, Gfun(Internal f_init_graph_node_animated_part)) ::
 (_init_graph_node_billboard, Gfun(Internal f_init_graph_node_billboard)) ::
 (_init_graph_node_display_list, Gfun(Internal f_init_graph_node_display_list)) ::
 (_init_graph_node_shadow, Gfun(Internal f_init_graph_node_shadow)) ::
 (_init_graph_node_object_parent, Gfun(Internal f_init_graph_node_object_parent)) ::
 (_init_graph_node_generated, Gfun(Internal f_init_graph_node_generated)) ::
 (_init_graph_node_background, Gfun(Internal f_init_graph_node_background)) ::
 (_init_graph_node_held_object, Gfun(Internal f_init_graph_node_held_object)) ::
 (_geo_add_child, Gfun(Internal f_geo_add_child)) ::
 (_geo_remove_child, Gfun(Internal f_geo_remove_child)) ::
 (_geo_make_first_child, Gfun(Internal f_geo_make_first_child)) ::
 (_geo_call_global_function_nodes_helper, Gfun(Internal f_geo_call_global_function_nodes_helper)) ::
 (_geo_call_global_function_nodes, Gfun(Internal f_geo_call_global_function_nodes)) ::
 (_geo_reset_object_node, Gfun(Internal f_geo_reset_object_node)) ::
 (_geo_obj_init, Gfun(Internal f_geo_obj_init)) ::
 (_geo_obj_init_spawninfo, Gfun(Internal f_geo_obj_init_spawninfo)) ::
 (_geo_obj_init_animation, Gfun(Internal f_geo_obj_init_animation)) ::
 (_geo_obj_init_animation_accel, Gfun(Internal f_geo_obj_init_animation_accel)) ::
 (_retrieve_animation_index, Gfun(Internal f_retrieve_animation_index)) ::
 (_geo_update_animation_frame, Gfun(Internal f_geo_update_animation_frame)) ::
 (_geo_retreive_animation_translation, Gfun(Internal f_geo_retreive_animation_translation)) ::
 (_geo_find_root, Gfun(Internal f_geo_find_root)) :: nil).

Definition public_idents : list ident :=
(_geo_find_root :: _geo_retreive_animation_translation ::
 _geo_update_animation_frame :: _retrieve_animation_index ::
 _geo_obj_init_animation_accel :: _geo_obj_init_animation ::
 _geo_obj_init_spawninfo :: _geo_obj_init :: _geo_reset_object_node ::
 _geo_call_global_function_nodes :: _geo_call_global_function_nodes_helper ::
 _geo_make_first_child :: _geo_remove_child :: _geo_add_child ::
 _init_graph_node_held_object :: _init_graph_node_background ::
 _init_graph_node_generated :: _init_graph_node_object_parent ::
 _init_graph_node_shadow :: _init_graph_node_display_list ::
 _init_graph_node_billboard :: _init_graph_node_animated_part ::
 _init_graph_node_culling_radius :: _init_graph_node_object ::
 _init_graph_node_scale :: _init_graph_node_rotation ::
 _init_graph_node_translation :: _init_graph_node_translation_rotation ::
 _init_graph_node_camera :: _init_graph_node_switch_case ::
 _init_graph_node_render_range :: _init_graph_node_master_list ::
 _init_graph_node_start :: _init_graph_node_perspective ::
 _init_graph_node_ortho_projection :: _init_graph_node_root ::
 _init_scene_graph_node_links :: _gVec3sOne :: _gVec3fOne :: _gVec3sZero ::
 _gVec3fZero :: _zeroMtx :: _identityMtx :: _gObjParentGraphNode ::
 _gAreaUpdateCounter :: _gCurGraphNodeObject :: _gCurGraphNodeCamera ::
 _gCurGraphNodeCamFrustum :: _gCurGraphNodeMasterList ::
 _gCurGraphNodeRoot :: _alloc_only_pool_alloc :: _segmented_to_virtual ::
 _vec3s_copy :: _vec3f_set :: _vec3f_copy :: ___builtin_debug ::
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
