(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_US
   Source:          src/engine/surface_load.c
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1
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
  Definition source_file := "build/pinned-sm64/src/engine/surface_load.c".
  Definition normalized := true.
End Info.

Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _GraphNode : ident := $"GraphNode".
Definition _GraphNodeObject : ident := $"GraphNodeObject".
Definition _Object : ident := $"Object".
Definition _ObjectNode : ident := $"ObjectNode".
Definition _SpawnInfo : ident := $"SpawnInfo".
Definition _Surface : ident := $"Surface".
Definition _SurfaceNode : ident := $"SurfaceNode".
Definition _Waypoint : ident := $"Waypoint".
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
Definition _a0 : ident := $"a0".
Definition _a1 : ident := $"a1".
Definition _a2 : ident := $"a2".
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _add_surface : ident := $"add_surface".
Definition _add_surface_to_cell : ident := $"add_surface_to_cell".
Definition _alloc_surface : ident := $"alloc_surface".
Definition _alloc_surface_node : ident := $"alloc_surface_node".
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
Definition _bhvDDDWarp : ident := $"bhvDDDWarp".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _cellX : ident := $"cellX".
Definition _cellZ : ident := $"cellZ".
Definition _cells : ident := $"cells".
Definition _children : ident := $"children".
Definition _clear_dynamic_surfaces : ident := $"clear_dynamic_surfaces".
Definition _clear_spatial_partition : ident := $"clear_spatial_partition".
Definition _clear_static_surfaces : ident := $"clear_static_surfaces".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _coord : ident := $"coord".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _data : ident := $"data".
Definition _dist_between_objects : ident := $"dist_between_objects".
Definition _dynamic : ident := $"dynamic".
Definition _filler : ident := $"filler".
Definition _flags : ident := $"flags".
Definition _force : ident := $"force".
Definition _gCCMEnteredSlide : ident := $"gCCMEnteredSlide".
Definition _gCurrentObject : ident := $"gCurrentObject".
Definition _gDynamicSurfacePartition : ident := $"gDynamicSurfacePartition".
Definition _gEnvironmentLevels : ident := $"gEnvironmentLevels".
Definition _gEnvironmentRegions : ident := $"gEnvironmentRegions".
Definition _gMarioObject : ident := $"gMarioObject".
Definition _gNumStaticSurfaceNodes : ident := $"gNumStaticSurfaceNodes".
Definition _gNumStaticSurfaces : ident := $"gNumStaticSurfaces".
Definition _gStaticSurfacePartition : ident := $"gStaticSurfacePartition".
Definition _gSurfaceNodesAllocated : ident := $"gSurfaceNodesAllocated".
Definition _gSurfacesAllocated : ident := $"gSurfacesAllocated".
Definition _gTimeStopState : ident := $"gTimeStopState".
Definition _gfx : ident := $"gfx".
Definition _hasForce : ident := $"hasForce".
Definition _header : ident := $"header".
Definition _height : ident := $"height".
Definition _hiX : ident := $"hiX".
Definition _hiZ : ident := $"hiZ".
Definition _hitboxDownOffset : ident := $"hitboxDownOffset".
Definition _hitboxHeight : ident := $"hitboxHeight".
Definition _hitboxRadius : ident := $"hitboxRadius".
Definition _hurtboxHeight : ident := $"hurtboxHeight".
Definition _hurtboxRadius : ident := $"hurtboxRadius".
Definition _i : ident := $"i".
Definition _index : ident := $"index".
Definition _length : ident := $"length".
Definition _list : ident := $"list".
Definition _listIndex : ident := $"listIndex".
Definition _loX : ident := $"loX".
Definition _loZ : ident := $"loZ".
Definition _load_area_terrain : ident := $"load_area_terrain".
Definition _load_environmental_regions : ident := $"load_environmental_regions".
Definition _load_object_collision_model : ident := $"load_object_collision_model".
Definition _load_object_surfaces : ident := $"load_object_surfaces".
Definition _load_static_surfaces : ident := $"load_static_surfaces".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _lower_cell_index : ident := $"lower_cell_index".
Definition _m : ident := $"m".
Definition _macroObjects : ident := $"macroObjects".
Definition _mag : ident := $"mag".
Definition _main : ident := $"main".
Definition _main_pool_alloc : ident := $"main_pool_alloc".
Definition _marioDist : ident := $"marioDist".
Definition _maxCellX : ident := $"maxCellX".
Definition _maxCellZ : ident := $"maxCellZ".
Definition _maxX : ident := $"maxX".
Definition _maxY : ident := $"maxY".
Definition _maxZ : ident := $"maxZ".
Definition _max_3 : ident := $"max_3".
Definition _minCellX : ident := $"minCellX".
Definition _minCellZ : ident := $"minCellZ".
Definition _minX : ident := $"minX".
Definition _minY : ident := $"minY".
Definition _minZ : ident := $"minZ".
Definition _min_3 : ident := $"min_3".
Definition _model : ident := $"model".
Definition _newNode : ident := $"newNode".
Definition _next : ident := $"next".
Definition _node : ident := $"node".
Definition _normal : ident := $"normal".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _numRegions : ident := $"numRegions".
Definition _numSurfaces : ident := $"numSurfaces".
Definition _numVertices : ident := $"numVertices".
Definition _nx : ident := $"nx".
Definition _ny : ident := $"ny".
Definition _nz : ident := $"nz".
Definition _obj_apply_scale_to_matrix : ident := $"obj_apply_scale_to_matrix".
Definition _obj_build_transform_from_pos_and_angle : ident := $"obj_build_transform_from_pos_and_angle".
Definition _object : ident := $"object".
Definition _objectTransform : ident := $"objectTransform".
Definition _offset1 : ident := $"offset1".
Definition _offset2 : ident := $"offset2".
Definition _offset3 : ident := $"offset3".
Definition _originOffset : ident := $"originOffset".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _pitch : ident := $"pitch".
Definition _platform : ident := $"platform".
Definition _pos : ident := $"pos".
Definition _posX : ident := $"posX".
Definition _posY : ident := $"posY".
Definition _posZ : ident := $"posZ".
Definition _prev : ident := $"prev".
Definition _prevObj : ident := $"prevObj".
Definition _priority : ident := $"priority".
Definition _rawData : ident := $"rawData".
Definition _read_surface_data : ident := $"read_surface_data".
Definition _read_vertex_data : ident := $"read_vertex_data".
Definition _reset_red_coins_collected : ident := $"reset_red_coins_collected".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _roll : ident := $"roll".
Definition _room : ident := $"room".
Definition _sSurfaceNodePool : ident := $"sSurfaceNodePool".
Definition _sSurfacePool : ident := $"sSurfacePool".
Definition _sSurfacePoolSize : ident := $"sSurfacePoolSize".
Definition _scale : ident := $"scale".
Definition _segmented_to_virtual : ident := $"segmented_to_virtual".
Definition _sharedChild : ident := $"sharedChild".
Definition _sortDir : ident := $"sortDir".
Definition _spawn_macro_objects : ident := $"spawn_macro_objects".
Definition _spawn_macro_objects_hardcoded : ident := $"spawn_macro_objects_hardcoded".
Definition _spawn_special_objects : ident := $"spawn_special_objects".
Definition _sqrtf : ident := $"sqrtf".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
Definition _surf_has_no_cam_collision : ident := $"surf_has_no_cam_collision".
Definition _surface : ident := $"surface".
Definition _surfacePriority : ident := $"surfacePriority".
Definition _surfaceRooms : ident := $"surfaceRooms".
Definition _surfaceType : ident := $"surfaceType".
Definition _surface_has_force : ident := $"surface_has_force".
Definition _tangibleDist : ident := $"tangibleDist".
Definition _terrainLoadType : ident := $"terrainLoadType".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _transform : ident := $"transform".
Definition _transform_object_vertices : ident := $"transform_object_vertices".
Definition _type : ident := $"type".
Definition _unk4C : ident := $"unk4C".
Definition _unused1 : ident := $"unused1".
Definition _unused2 : ident := $"unused2".
Definition _unused3 : ident := $"unused3".
Definition _unused8038BE90 : ident := $"unused8038BE90".
Definition _unused8038EEA8 : ident := $"unused8038EEA8".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _upperY : ident := $"upperY".
Definition _upper_cell_index : ident := $"upper_cell_index".
Definition _val : ident := $"val".
Definition _values : ident := $"values".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _vertexData : ident := $"vertexData".
Definition _vertexIndices : ident := $"vertexIndices".
Definition _vertices : ident := $"vertices".
Definition _vx : ident := $"vx".
Definition _vy : ident := $"vy".
Definition _vz : ident := $"vz".
Definition _x : ident := $"x".
Definition _x1 : ident := $"x1".
Definition _x2 : ident := $"x2".
Definition _x3 : ident := $"x3".
Definition _y : ident := $"y".
Definition _y1 : ident := $"y1".
Definition _y2 : ident := $"y2".
Definition _y3 : ident := $"y3".
Definition _yaw : ident := $"yaw".
Definition _z : ident := $"z".
Definition _z1 : ident := $"z1".
Definition _z2 : ident := $"z2".
Definition _z3 : ident := $"z3".
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

Definition v_bhvDDDWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_gTimeStopState := {|
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

Definition v_gCurrentObject := {|
  gvar_info := (tptr (Tstruct _Object noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSurfaceNodesAllocated := {|
  gvar_info := tint;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSurfacesAllocated := {|
  gvar_info := tint;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gNumStaticSurfaceNodes := {|
  gvar_info := tint;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gNumStaticSurfaces := {|
  gvar_info := tint;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gEnvironmentRegions := {|
  gvar_info := (tptr tshort);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gEnvironmentLevels := {|
  gvar_info := (tarray tint 20);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCCMEnteredSlide := {|
  gvar_info := tshort;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_unused8038BE90 := {|
  gvar_info := tint;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gStaticSurfacePartition := {|
  gvar_info := (tarray (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16) 16);
  gvar_init := (Init_space 6144 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDynamicSurfacePartition := {|
  gvar_info := (tarray (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16) 16);
  gvar_init := (Init_space 6144 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSurfaceNodePool := {|
  gvar_info := (tptr (Tstruct _SurfaceNode noattr));
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSurfacePool := {|
  gvar_info := (tptr (Tstruct _Surface noattr));
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSurfacePoolSize := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_unused8038EEA8 := {|
  gvar_info := (tarray tuchar 48);
  gvar_init := (Init_space 48 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_alloc_surface_node := {|
  fn_return := (tptr (Tstruct _SurfaceNode noattr));
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_node, (tptr (Tstruct _SurfaceNode noattr))) ::
               (_t'3, tint) ::
               (_t'2, (tptr (Tstruct _SurfaceNode noattr))) ::
               (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2 (Evar _sSurfaceNodePool (tptr (Tstruct _SurfaceNode noattr))))
    (Ssequence
      (Sset _t'3 (Evar _gSurfaceNodesAllocated tint))
      (Sset _node
        (Ebinop Oadd (Etempvar _t'2 (tptr (Tstruct _SurfaceNode noattr)))
          (Etempvar _t'3 tint) (tptr (Tstruct _SurfaceNode noattr))))))
  (Ssequence
    (Ssequence
      (Sset _t'1 (Evar _gSurfaceNodesAllocated tint))
      (Sassign (Evar _gSurfaceNodesAllocated tint)
        (Ebinop Oadd (Etempvar _t'1 tint) (Econst_int (Int.repr 1) tint)
          tint)))
    (Ssequence
      (Sassign
        (Efield
          (Ederef (Etempvar _node (tptr (Tstruct _SurfaceNode noattr)))
            (Tstruct _SurfaceNode noattr)) _next
          (tptr (Tstruct _SurfaceNode noattr)))
        (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
      (Ssequence
        Sskip
        (Sreturn (Some (Etempvar _node (tptr (Tstruct _SurfaceNode noattr)))))))))
|}.

Definition f_alloc_surface := {|
  fn_return := (tptr (Tstruct _Surface noattr));
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_surface, (tptr (Tstruct _Surface noattr))) ::
               (_t'3, tint) :: (_t'2, (tptr (Tstruct _Surface noattr))) ::
               (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2 (Evar _sSurfacePool (tptr (Tstruct _Surface noattr))))
    (Ssequence
      (Sset _t'3 (Evar _gSurfacesAllocated tint))
      (Sset _surface
        (Ebinop Oadd (Etempvar _t'2 (tptr (Tstruct _Surface noattr)))
          (Etempvar _t'3 tint) (tptr (Tstruct _Surface noattr))))))
  (Ssequence
    (Ssequence
      (Sset _t'1 (Evar _gSurfacesAllocated tint))
      (Sassign (Evar _gSurfacesAllocated tint)
        (Ebinop Oadd (Etempvar _t'1 tint) (Econst_int (Int.repr 1) tint)
          tint)))
    (Ssequence
      Sskip
      (Ssequence
        (Sassign
          (Efield
            (Ederef (Etempvar _surface (tptr (Tstruct _Surface noattr)))
              (Tstruct _Surface noattr)) _type tshort)
          (Econst_int (Int.repr 0) tint))
        (Ssequence
          (Sassign
            (Efield
              (Ederef (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                (Tstruct _Surface noattr)) _force tshort)
            (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Sassign
              (Efield
                (Ederef (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                  (Tstruct _Surface noattr)) _flags tschar)
              (Econst_int (Int.repr 0) tint))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                    (Tstruct _Surface noattr)) _room tschar)
                (Econst_int (Int.repr 0) tint))
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                      (Tstruct _Surface noattr)) _object
                    (tptr (Tstruct _Object noattr)))
                  (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
                (Sreturn (Some (Etempvar _surface (tptr (Tstruct _Surface noattr)))))))))))))
|}.

Definition f_clear_spatial_partition := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_cells, (tptr (tarray (Tstruct _SurfaceNode noattr) 3))) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _i
    (Ebinop Omul
      (Ebinop Odiv
        (Ebinop Omul (Econst_int (Int.repr 2) tint)
          (Econst_int (Int.repr 8192) tint) tint)
        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
          (Econst_int (Int.repr 10) tint) tint) tint)
      (Ebinop Odiv
        (Ebinop Omul (Econst_int (Int.repr 2) tint)
          (Econst_int (Int.repr 8192) tint) tint)
        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
          (Econst_int (Int.repr 10) tint) tint) tint) tint))
  (Sloop
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'1 (Etempvar _i tint))
          (Sset _i
            (Ebinop Osub (Etempvar _t'1 tint) (Econst_int (Int.repr 1) tint)
              tint)))
        (Sifthenelse (Etempvar _t'1 tint) Sskip Sbreak))
      (Ssequence
        (Sassign
          (Efield
            (Ederef
              (Ebinop Oadd
                (Ederef
                  (Etempvar _cells (tptr (tarray (Tstruct _SurfaceNode noattr) 3)))
                  (tarray (Tstruct _SurfaceNode noattr) 3))
                (Econst_int (Int.repr 0) tint)
                (tptr (Tstruct _SurfaceNode noattr)))
              (Tstruct _SurfaceNode noattr)) _next
            (tptr (Tstruct _SurfaceNode noattr)))
          (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
        (Ssequence
          (Sassign
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Ederef
                    (Etempvar _cells (tptr (tarray (Tstruct _SurfaceNode noattr) 3)))
                    (tarray (Tstruct _SurfaceNode noattr) 3))
                  (Econst_int (Int.repr 1) tint)
                  (tptr (Tstruct _SurfaceNode noattr)))
                (Tstruct _SurfaceNode noattr)) _next
              (tptr (Tstruct _SurfaceNode noattr)))
            (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
          (Ssequence
            (Sassign
              (Efield
                (Ederef
                  (Ebinop Oadd
                    (Ederef
                      (Etempvar _cells (tptr (tarray (Tstruct _SurfaceNode noattr) 3)))
                      (tarray (Tstruct _SurfaceNode noattr) 3))
                    (Econst_int (Int.repr 2) tint)
                    (tptr (Tstruct _SurfaceNode noattr)))
                  (Tstruct _SurfaceNode noattr)) _next
                (tptr (Tstruct _SurfaceNode noattr)))
              (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
            (Sset _cells
              (Ebinop Oadd
                (Etempvar _cells (tptr (tarray (Tstruct _SurfaceNode noattr) 3)))
                (Econst_int (Int.repr 1) tint)
                (tptr (tarray (Tstruct _SurfaceNode noattr) 3))))))))
    Sskip))
|}.

Definition f_clear_static_surfaces := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Scall None
  (Evar _clear_spatial_partition (Tfunction
                                   ((tptr (tarray (Tstruct _SurfaceNode noattr) 3)) ::
                                    nil) tvoid cc_default))
  ((Ebinop Oadd
     (Ederef
       (Ebinop Oadd
         (Evar _gStaticSurfacePartition (tarray (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16) 16))
         (Econst_int (Int.repr 0) tint)
         (tptr (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16)))
       (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16))
     (Econst_int (Int.repr 0) tint)
     (tptr (tarray (Tstruct _SurfaceNode noattr) 3))) :: nil))
|}.

Definition f_add_surface_to_cell := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_dynamic, tshort) :: (_cellX, tshort) :: (_cellZ, tshort) ::
                (_surface, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_newNode, (tptr (Tstruct _SurfaceNode noattr))) ::
               (_list, (tptr (Tstruct _SurfaceNode noattr))) ::
               (_surfacePriority, tshort) :: (_priority, tshort) ::
               (_sortDir, tshort) :: (_listIndex, tshort) :: (_t'2, tint) ::
               (_t'1, (tptr (Tstruct _SurfaceNode noattr))) ::
               (_t'13, tfloat) :: (_t'12, tfloat) :: (_t'11, tschar) ::
               (_t'10, tfloat) :: (_t'9, tfloat) :: (_t'8, tshort) ::
               (_t'7, (tptr (Tstruct _SurfaceNode noattr))) ::
               (_t'6, tshort) :: (_t'5, (tptr (Tstruct _Surface noattr))) ::
               (_t'4, (tptr (Tstruct _SurfaceNode noattr))) ::
               (_t'3, (tptr (Tstruct _SurfaceNode noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _alloc_surface_node (Tfunction nil
                                  (tptr (Tstruct _SurfaceNode noattr))
                                  cc_default)) nil)
    (Sset _newNode (Etempvar _t'1 (tptr (Tstruct _SurfaceNode noattr)))))
  (Ssequence
    (Ssequence
      (Sset _t'9
        (Efield
          (Efield
            (Ederef (Etempvar _surface (tptr (Tstruct _Surface noattr)))
              (Tstruct _Surface noattr)) _normal (Tstruct __769 noattr)) _y
          tfloat))
      (Sifthenelse (Ebinop Ogt (Etempvar _t'9 tfloat)
                     (Econst_float (Float.of_bits (Int64.repr 4576918229304087675)) tdouble)
                     tint)
        (Ssequence
          (Sset _listIndex (Ecast (Econst_int (Int.repr 0) tint) tshort))
          (Sset _sortDir (Ecast (Econst_int (Int.repr 1) tint) tshort)))
        (Ssequence
          (Sset _t'10
            (Efield
              (Efield
                (Ederef (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                  (Tstruct _Surface noattr)) _normal (Tstruct __769 noattr))
              _y tfloat))
          (Sifthenelse (Ebinop Olt (Etempvar _t'10 tfloat)
                         (Eunop Oneg
                           (Econst_float (Float.of_bits (Int64.repr 4576918229304087675)) tdouble)
                           tdouble) tint)
            (Ssequence
              (Sset _listIndex (Ecast (Econst_int (Int.repr 1) tint) tshort))
              (Sset _sortDir
                (Ecast (Eunop Oneg (Econst_int (Int.repr 1) tint) tint)
                  tshort)))
            (Ssequence
              (Sset _listIndex (Ecast (Econst_int (Int.repr 2) tint) tshort))
              (Ssequence
                (Sset _sortDir (Ecast (Econst_int (Int.repr 0) tint) tshort))
                (Ssequence
                  (Ssequence
                    (Sset _t'12
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                            (Tstruct _Surface noattr)) _normal
                          (Tstruct __769 noattr)) _x tfloat))
                    (Sifthenelse (Ebinop Olt (Etempvar _t'12 tfloat)
                                   (Eunop Oneg
                                     (Econst_float (Float.of_bits (Int64.repr 4604543309418378297)) tdouble)
                                     tdouble) tint)
                      (Sset _t'2 (Econst_int (Int.repr 1) tint))
                      (Ssequence
                        (Sset _t'13
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                (Tstruct _Surface noattr)) _normal
                              (Tstruct __769 noattr)) _x tfloat))
                        (Sset _t'2
                          (Ecast
                            (Ebinop Ogt (Etempvar _t'13 tfloat)
                              (Econst_float (Float.of_bits (Int64.repr 4604543309418378297)) tdouble)
                              tint) tbool)))))
                  (Sifthenelse (Etempvar _t'2 tint)
                    (Ssequence
                      (Sset _t'11
                        (Efield
                          (Ederef
                            (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                            (Tstruct _Surface noattr)) _flags tschar))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                            (Tstruct _Surface noattr)) _flags tschar)
                        (Ebinop Oor (Etempvar _t'11 tschar)
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 3) tint) tint) tint)))
                    Sskip))))))))
    (Ssequence
      (Ssequence
        (Sset _t'8
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                  (Tstruct _Surface noattr)) _vertex1 (tarray tshort 3))
              (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
        (Sset _surfacePriority
          (Ecast
            (Ebinop Omul (Etempvar _t'8 tshort) (Etempvar _sortDir tshort)
              tint) tshort)))
      (Ssequence
        (Sassign
          (Efield
            (Ederef (Etempvar _newNode (tptr (Tstruct _SurfaceNode noattr)))
              (Tstruct _SurfaceNode noattr)) _surface
            (tptr (Tstruct _Surface noattr)))
          (Etempvar _surface (tptr (Tstruct _Surface noattr))))
        (Ssequence
          (Sifthenelse (Etempvar _dynamic tshort)
            (Sset _list
              (Ebinop Oadd
                (Ederef
                  (Ebinop Oadd
                    (Ederef
                      (Ebinop Oadd
                        (Evar _gDynamicSurfacePartition (tarray (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16) 16))
                        (Etempvar _cellZ tshort)
                        (tptr (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16)))
                      (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16))
                    (Etempvar _cellX tshort)
                    (tptr (tarray (Tstruct _SurfaceNode noattr) 3)))
                  (tarray (Tstruct _SurfaceNode noattr) 3))
                (Etempvar _listIndex tshort)
                (tptr (Tstruct _SurfaceNode noattr))))
            (Sset _list
              (Ebinop Oadd
                (Ederef
                  (Ebinop Oadd
                    (Ederef
                      (Ebinop Oadd
                        (Evar _gStaticSurfacePartition (tarray (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16) 16))
                        (Etempvar _cellZ tshort)
                        (tptr (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16)))
                      (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16))
                    (Etempvar _cellX tshort)
                    (tptr (tarray (Tstruct _SurfaceNode noattr) 3)))
                  (tarray (Tstruct _SurfaceNode noattr) 3))
                (Etempvar _listIndex tshort)
                (tptr (Tstruct _SurfaceNode noattr)))))
          (Ssequence
            (Sloop
              (Ssequence
                (Ssequence
                  (Sset _t'7
                    (Efield
                      (Ederef
                        (Etempvar _list (tptr (Tstruct _SurfaceNode noattr)))
                        (Tstruct _SurfaceNode noattr)) _next
                      (tptr (Tstruct _SurfaceNode noattr))))
                  (Sifthenelse (Ebinop One
                                 (Etempvar _t'7 (tptr (Tstruct _SurfaceNode noattr)))
                                 (Ecast (Econst_int (Int.repr 0) tint)
                                   (tptr tvoid)) tint)
                    Sskip
                    Sbreak))
                (Ssequence
                  (Ssequence
                    (Sset _t'4
                      (Efield
                        (Ederef
                          (Etempvar _list (tptr (Tstruct _SurfaceNode noattr)))
                          (Tstruct _SurfaceNode noattr)) _next
                        (tptr (Tstruct _SurfaceNode noattr))))
                    (Ssequence
                      (Sset _t'5
                        (Efield
                          (Ederef
                            (Etempvar _t'4 (tptr (Tstruct _SurfaceNode noattr)))
                            (Tstruct _SurfaceNode noattr)) _surface
                          (tptr (Tstruct _Surface noattr))))
                      (Ssequence
                        (Sset _t'6
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _t'5 (tptr (Tstruct _Surface noattr)))
                                  (Tstruct _Surface noattr)) _vertex1
                                (tarray tshort 3))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))
                            tshort))
                        (Sset _priority
                          (Ecast
                            (Ebinop Omul (Etempvar _t'6 tshort)
                              (Etempvar _sortDir tshort) tint) tshort)))))
                  (Ssequence
                    (Sifthenelse (Ebinop Ogt
                                   (Etempvar _surfacePriority tshort)
                                   (Etempvar _priority tshort) tint)
                      Sbreak
                      Sskip)
                    (Sset _list
                      (Efield
                        (Ederef
                          (Etempvar _list (tptr (Tstruct _SurfaceNode noattr)))
                          (Tstruct _SurfaceNode noattr)) _next
                        (tptr (Tstruct _SurfaceNode noattr)))))))
              Sskip)
            (Ssequence
              (Ssequence
                (Sset _t'3
                  (Efield
                    (Ederef
                      (Etempvar _list (tptr (Tstruct _SurfaceNode noattr)))
                      (Tstruct _SurfaceNode noattr)) _next
                    (tptr (Tstruct _SurfaceNode noattr))))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _newNode (tptr (Tstruct _SurfaceNode noattr)))
                      (Tstruct _SurfaceNode noattr)) _next
                    (tptr (Tstruct _SurfaceNode noattr)))
                  (Etempvar _t'3 (tptr (Tstruct _SurfaceNode noattr)))))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _list (tptr (Tstruct _SurfaceNode noattr)))
                    (Tstruct _SurfaceNode noattr)) _next
                  (tptr (Tstruct _SurfaceNode noattr)))
                (Etempvar _newNode (tptr (Tstruct _SurfaceNode noattr)))))))))))
|}.

Definition f_min_3 := {|
  fn_return := tshort;
  fn_callconv := cc_default;
  fn_params := ((_a0, tshort) :: (_a1, tshort) :: (_a2, tshort) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Olt (Etempvar _a1 tshort) (Etempvar _a0 tshort) tint)
    (Sset _a0 (Ecast (Etempvar _a1 tshort) tshort))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop Olt (Etempvar _a2 tshort) (Etempvar _a0 tshort)
                   tint)
      (Sset _a0 (Ecast (Etempvar _a2 tshort) tshort))
      Sskip)
    (Sreturn (Some (Etempvar _a0 tshort)))))
|}.

Definition f_max_3 := {|
  fn_return := tshort;
  fn_callconv := cc_default;
  fn_params := ((_a0, tshort) :: (_a1, tshort) :: (_a2, tshort) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Ogt (Etempvar _a1 tshort) (Etempvar _a0 tshort) tint)
    (Sset _a0 (Ecast (Etempvar _a1 tshort) tshort))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop Ogt (Etempvar _a2 tshort) (Etempvar _a0 tshort)
                   tint)
      (Sset _a0 (Ecast (Etempvar _a2 tshort) tshort))
      Sskip)
    (Sreturn (Some (Etempvar _a0 tshort)))))
|}.

Definition f_lower_cell_index := {|
  fn_return := tshort;
  fn_callconv := cc_default;
  fn_params := ((_coord, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_index, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _coord
    (Ecast
      (Ebinop Oadd (Etempvar _coord tshort) (Econst_int (Int.repr 8192) tint)
        tint) tshort))
  (Ssequence
    (Sifthenelse (Ebinop Olt (Etempvar _coord tshort)
                   (Econst_int (Int.repr 0) tint) tint)
      (Sset _coord (Ecast (Econst_int (Int.repr 0) tint) tshort))
      Sskip)
    (Ssequence
      (Sset _index
        (Ecast
          (Ebinop Odiv (Etempvar _coord tshort)
            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
              (Econst_int (Int.repr 10) tint) tint) tint) tshort))
      (Ssequence
        (Sifthenelse (Ebinop Olt
                       (Ebinop Omod (Etempvar _coord tshort)
                         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 10) tint) tint) tint)
                       (Econst_int (Int.repr 50) tint) tint)
          (Sset _index
            (Ecast
              (Ebinop Osub (Etempvar _index tshort)
                (Econst_int (Int.repr 1) tint) tint) tshort))
          Sskip)
        (Ssequence
          (Sifthenelse (Ebinop Olt (Etempvar _index tshort)
                         (Econst_int (Int.repr 0) tint) tint)
            (Sset _index (Ecast (Econst_int (Int.repr 0) tint) tshort))
            Sskip)
          (Sreturn (Some (Etempvar _index tshort))))))))
|}.

Definition f_upper_cell_index := {|
  fn_return := tshort;
  fn_callconv := cc_default;
  fn_params := ((_coord, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_index, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _coord
    (Ecast
      (Ebinop Oadd (Etempvar _coord tshort) (Econst_int (Int.repr 8192) tint)
        tint) tshort))
  (Ssequence
    (Sifthenelse (Ebinop Olt (Etempvar _coord tshort)
                   (Econst_int (Int.repr 0) tint) tint)
      (Sset _coord (Ecast (Econst_int (Int.repr 0) tint) tshort))
      Sskip)
    (Ssequence
      (Sset _index
        (Ecast
          (Ebinop Odiv (Etempvar _coord tshort)
            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
              (Econst_int (Int.repr 10) tint) tint) tint) tshort))
      (Ssequence
        (Sifthenelse (Ebinop Ogt
                       (Ebinop Omod (Etempvar _coord tshort)
                         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 10) tint) tint) tint)
                       (Ebinop Osub
                         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 10) tint) tint)
                         (Econst_int (Int.repr 50) tint) tint) tint)
          (Sset _index
            (Ecast
              (Ebinop Oadd (Etempvar _index tshort)
                (Econst_int (Int.repr 1) tint) tint) tshort))
          Sskip)
        (Ssequence
          (Sifthenelse (Ebinop Ogt (Etempvar _index tshort)
                         (Ebinop Osub
                           (Ebinop Odiv
                             (Ebinop Omul (Econst_int (Int.repr 2) tint)
                               (Econst_int (Int.repr 8192) tint) tint)
                             (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                               (Econst_int (Int.repr 10) tint) tint) tint)
                           (Econst_int (Int.repr 1) tint) tint) tint)
            (Sset _index
              (Ecast
                (Ebinop Osub
                  (Ebinop Odiv
                    (Ebinop Omul (Econst_int (Int.repr 2) tint)
                      (Econst_int (Int.repr 8192) tint) tint)
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 10) tint) tint) tint)
                  (Econst_int (Int.repr 1) tint) tint) tshort))
            Sskip)
          (Sreturn (Some (Etempvar _index tshort))))))))
|}.

Definition f_add_surface := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_surface, (tptr (Tstruct _Surface noattr))) ::
                (_dynamic, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_unused1, tint) :: (_unused2, tint) :: (_minX, tshort) ::
               (_minZ, tshort) :: (_maxX, tshort) :: (_maxZ, tshort) ::
               (_minCellX, tshort) :: (_minCellZ, tshort) ::
               (_maxCellX, tshort) :: (_maxCellZ, tshort) ::
               (_cellZ, tshort) :: (_cellX, tshort) :: (_unused3, tint) ::
               (_t'8, tshort) :: (_t'7, tshort) :: (_t'6, tshort) ::
               (_t'5, tshort) :: (_t'4, tshort) :: (_t'3, tshort) ::
               (_t'2, tshort) :: (_t'1, tshort) :: (_t'20, tshort) ::
               (_t'19, tshort) :: (_t'18, tshort) :: (_t'17, tshort) ::
               (_t'16, tshort) :: (_t'15, tshort) :: (_t'14, tshort) ::
               (_t'13, tshort) :: (_t'12, tshort) :: (_t'11, tshort) ::
               (_t'10, tshort) :: (_t'9, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _unused3 (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'18
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                  (Tstruct _Surface noattr)) _vertex1 (tarray tshort 3))
              (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
        (Ssequence
          (Sset _t'19
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef
                    (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                    (Tstruct _Surface noattr)) _vertex2 (tarray tshort 3))
                (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
          (Ssequence
            (Sset _t'20
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef
                      (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                      (Tstruct _Surface noattr)) _vertex3 (tarray tshort 3))
                  (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
            (Scall (Some _t'1)
              (Evar _min_3 (Tfunction (tshort :: tshort :: tshort :: nil)
                             tshort cc_default))
              ((Etempvar _t'18 tshort) :: (Etempvar _t'19 tshort) ::
               (Etempvar _t'20 tshort) :: nil)))))
      (Sset _minX (Ecast (Etempvar _t'1 tshort) tshort)))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'15
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef
                    (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                    (Tstruct _Surface noattr)) _vertex1 (tarray tshort 3))
                (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort))
          (Ssequence
            (Sset _t'16
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef
                      (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                      (Tstruct _Surface noattr)) _vertex2 (tarray tshort 3))
                  (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort))
            (Ssequence
              (Sset _t'17
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                        (Tstruct _Surface noattr)) _vertex3
                      (tarray tshort 3)) (Econst_int (Int.repr 2) tint)
                    (tptr tshort)) tshort))
              (Scall (Some _t'2)
                (Evar _min_3 (Tfunction (tshort :: tshort :: tshort :: nil)
                               tshort cc_default))
                ((Etempvar _t'15 tshort) :: (Etempvar _t'16 tshort) ::
                 (Etempvar _t'17 tshort) :: nil)))))
        (Sset _minZ (Ecast (Etempvar _t'2 tshort) tshort)))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'12
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef
                      (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                      (Tstruct _Surface noattr)) _vertex1 (tarray tshort 3))
                  (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
            (Ssequence
              (Sset _t'13
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                        (Tstruct _Surface noattr)) _vertex2
                      (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                    (tptr tshort)) tshort))
              (Ssequence
                (Sset _t'14
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                          (Tstruct _Surface noattr)) _vertex3
                        (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tshort)) tshort))
                (Scall (Some _t'3)
                  (Evar _max_3 (Tfunction (tshort :: tshort :: tshort :: nil)
                                 tshort cc_default))
                  ((Etempvar _t'12 tshort) :: (Etempvar _t'13 tshort) ::
                   (Etempvar _t'14 tshort) :: nil)))))
          (Sset _maxX (Ecast (Etempvar _t'3 tshort) tshort)))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'9
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                        (Tstruct _Surface noattr)) _vertex1
                      (tarray tshort 3)) (Econst_int (Int.repr 2) tint)
                    (tptr tshort)) tshort))
              (Ssequence
                (Sset _t'10
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                          (Tstruct _Surface noattr)) _vertex2
                        (tarray tshort 3)) (Econst_int (Int.repr 2) tint)
                      (tptr tshort)) tshort))
                (Ssequence
                  (Sset _t'11
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                            (Tstruct _Surface noattr)) _vertex3
                          (tarray tshort 3)) (Econst_int (Int.repr 2) tint)
                        (tptr tshort)) tshort))
                  (Scall (Some _t'4)
                    (Evar _max_3 (Tfunction
                                   (tshort :: tshort :: tshort :: nil) tshort
                                   cc_default))
                    ((Etempvar _t'9 tshort) :: (Etempvar _t'10 tshort) ::
                     (Etempvar _t'11 tshort) :: nil)))))
            (Sset _maxZ (Ecast (Etempvar _t'4 tshort) tshort)))
          (Ssequence
            (Ssequence
              (Scall (Some _t'5)
                (Evar _lower_cell_index (Tfunction (tshort :: nil) tshort
                                          cc_default))
                ((Etempvar _minX tshort) :: nil))
              (Sset _minCellX (Ecast (Etempvar _t'5 tshort) tshort)))
            (Ssequence
              (Ssequence
                (Scall (Some _t'6)
                  (Evar _upper_cell_index (Tfunction (tshort :: nil) tshort
                                            cc_default))
                  ((Etempvar _maxX tshort) :: nil))
                (Sset _maxCellX (Ecast (Etempvar _t'6 tshort) tshort)))
              (Ssequence
                (Ssequence
                  (Scall (Some _t'7)
                    (Evar _lower_cell_index (Tfunction (tshort :: nil) tshort
                                              cc_default))
                    ((Etempvar _minZ tshort) :: nil))
                  (Sset _minCellZ (Ecast (Etempvar _t'7 tshort) tshort)))
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'8)
                      (Evar _upper_cell_index (Tfunction (tshort :: nil)
                                                tshort cc_default))
                      ((Etempvar _maxZ tshort) :: nil))
                    (Sset _maxCellZ (Ecast (Etempvar _t'8 tshort) tshort)))
                  (Ssequence
                    (Sset _cellZ (Ecast (Etempvar _minCellZ tshort) tshort))
                    (Sloop
                      (Ssequence
                        (Sifthenelse (Ebinop Ole (Etempvar _cellZ tshort)
                                       (Etempvar _maxCellZ tshort) tint)
                          Sskip
                          Sbreak)
                        (Ssequence
                          (Sset _cellX
                            (Ecast (Etempvar _minCellX tshort) tshort))
                          (Sloop
                            (Ssequence
                              (Sifthenelse (Ebinop Ole
                                             (Etempvar _cellX tshort)
                                             (Etempvar _maxCellX tshort)
                                             tint)
                                Sskip
                                Sbreak)
                              (Scall None
                                (Evar _add_surface_to_cell (Tfunction
                                                             (tshort ::
                                                              tshort ::
                                                              tshort ::
                                                              (tptr (Tstruct _Surface noattr)) ::
                                                              nil) tvoid
                                                             cc_default))
                                ((Etempvar _dynamic tint) ::
                                 (Etempvar _cellX tshort) ::
                                 (Etempvar _cellZ tshort) ::
                                 (Etempvar _surface (tptr (Tstruct _Surface noattr))) ::
                                 nil)))
                            (Sset _cellX
                              (Ecast
                                (Ebinop Oadd (Etempvar _cellX tshort)
                                  (Econst_int (Int.repr 1) tint) tint)
                                tshort)))))
                      (Sset _cellZ
                        (Ecast
                          (Ebinop Oadd (Etempvar _cellZ tshort)
                            (Econst_int (Int.repr 1) tint) tint) tshort)))))))))))))
|}.

Definition f_read_surface_data := {|
  fn_return := (tptr (Tstruct _Surface noattr));
  fn_callconv := cc_default;
  fn_params := ((_vertexData, (tptr tshort)) ::
                (_vertexIndices, (tptr (tptr tshort))) :: nil);
  fn_vars := nil;
  fn_temps := ((_surface, (tptr (Tstruct _Surface noattr))) :: (_x1, tint) ::
               (_y1, tint) :: (_z1, tint) :: (_x2, tint) :: (_y2, tint) ::
               (_z2, tint) :: (_x3, tint) :: (_y3, tint) :: (_z3, tint) ::
               (_maxY, tint) :: (_minY, tint) :: (_nx, tfloat) ::
               (_ny, tfloat) :: (_nz, tfloat) :: (_mag, tfloat) ::
               (_offset1, tshort) :: (_offset2, tshort) ::
               (_offset3, tshort) ::
               (_t'2, (tptr (Tstruct _Surface noattr))) :: (_t'1, tfloat) ::
               (_t'8, tshort) :: (_t'7, (tptr tshort)) :: (_t'6, tshort) ::
               (_t'5, (tptr tshort)) :: (_t'4, tshort) ::
               (_t'3, (tptr tshort)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7
      (Ederef (Etempvar _vertexIndices (tptr (tptr tshort))) (tptr tshort)))
    (Ssequence
      (Sset _t'8
        (Ederef
          (Ebinop Oadd (Etempvar _t'7 (tptr tshort))
            (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
      (Sset _offset1
        (Ecast
          (Ebinop Omul (Econst_int (Int.repr 3) tint) (Etempvar _t'8 tshort)
            tint) tshort))))
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Ederef (Etempvar _vertexIndices (tptr (tptr tshort))) (tptr tshort)))
      (Ssequence
        (Sset _t'6
          (Ederef
            (Ebinop Oadd (Etempvar _t'5 (tptr tshort))
              (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
        (Sset _offset2
          (Ecast
            (Ebinop Omul (Econst_int (Int.repr 3) tint)
              (Etempvar _t'6 tshort) tint) tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Ederef (Etempvar _vertexIndices (tptr (tptr tshort)))
            (tptr tshort)))
        (Ssequence
          (Sset _t'4
            (Ederef
              (Ebinop Oadd (Etempvar _t'3 (tptr tshort))
                (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort))
          (Sset _offset3
            (Ecast
              (Ebinop Omul (Econst_int (Int.repr 3) tint)
                (Etempvar _t'4 tshort) tint) tshort))))
      (Ssequence
        (Sset _x1
          (Ederef
            (Ebinop Oadd
              (Ebinop Oadd (Etempvar _vertexData (tptr tshort))
                (Etempvar _offset1 tshort) (tptr tshort))
              (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
        (Ssequence
          (Sset _y1
            (Ederef
              (Ebinop Oadd
                (Ebinop Oadd (Etempvar _vertexData (tptr tshort))
                  (Etempvar _offset1 tshort) (tptr tshort))
                (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
          (Ssequence
            (Sset _z1
              (Ederef
                (Ebinop Oadd
                  (Ebinop Oadd (Etempvar _vertexData (tptr tshort))
                    (Etempvar _offset1 tshort) (tptr tshort))
                  (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort))
            (Ssequence
              (Sset _x2
                (Ederef
                  (Ebinop Oadd
                    (Ebinop Oadd (Etempvar _vertexData (tptr tshort))
                      (Etempvar _offset2 tshort) (tptr tshort))
                    (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
              (Ssequence
                (Sset _y2
                  (Ederef
                    (Ebinop Oadd
                      (Ebinop Oadd (Etempvar _vertexData (tptr tshort))
                        (Etempvar _offset2 tshort) (tptr tshort))
                      (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
                (Ssequence
                  (Sset _z2
                    (Ederef
                      (Ebinop Oadd
                        (Ebinop Oadd (Etempvar _vertexData (tptr tshort))
                          (Etempvar _offset2 tshort) (tptr tshort))
                        (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort))
                  (Ssequence
                    (Sset _x3
                      (Ederef
                        (Ebinop Oadd
                          (Ebinop Oadd (Etempvar _vertexData (tptr tshort))
                            (Etempvar _offset3 tshort) (tptr tshort))
                          (Econst_int (Int.repr 0) tint) (tptr tshort))
                        tshort))
                    (Ssequence
                      (Sset _y3
                        (Ederef
                          (Ebinop Oadd
                            (Ebinop Oadd (Etempvar _vertexData (tptr tshort))
                              (Etempvar _offset3 tshort) (tptr tshort))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))
                          tshort))
                      (Ssequence
                        (Sset _z3
                          (Ederef
                            (Ebinop Oadd
                              (Ebinop Oadd
                                (Etempvar _vertexData (tptr tshort))
                                (Etempvar _offset3 tshort) (tptr tshort))
                              (Econst_int (Int.repr 2) tint) (tptr tshort))
                            tshort))
                        (Ssequence
                          (Sset _nx
                            (Ecast
                              (Ebinop Osub
                                (Ebinop Omul
                                  (Ebinop Osub (Etempvar _y2 tint)
                                    (Etempvar _y1 tint) tint)
                                  (Ebinop Osub (Etempvar _z3 tint)
                                    (Etempvar _z2 tint) tint) tint)
                                (Ebinop Omul
                                  (Ebinop Osub (Etempvar _z2 tint)
                                    (Etempvar _z1 tint) tint)
                                  (Ebinop Osub (Etempvar _y3 tint)
                                    (Etempvar _y2 tint) tint) tint) tint)
                              tfloat))
                          (Ssequence
                            (Sset _ny
                              (Ecast
                                (Ebinop Osub
                                  (Ebinop Omul
                                    (Ebinop Osub (Etempvar _z2 tint)
                                      (Etempvar _z1 tint) tint)
                                    (Ebinop Osub (Etempvar _x3 tint)
                                      (Etempvar _x2 tint) tint) tint)
                                  (Ebinop Omul
                                    (Ebinop Osub (Etempvar _x2 tint)
                                      (Etempvar _x1 tint) tint)
                                    (Ebinop Osub (Etempvar _z3 tint)
                                      (Etempvar _z2 tint) tint) tint) tint)
                                tfloat))
                            (Ssequence
                              (Sset _nz
                                (Ecast
                                  (Ebinop Osub
                                    (Ebinop Omul
                                      (Ebinop Osub (Etempvar _x2 tint)
                                        (Etempvar _x1 tint) tint)
                                      (Ebinop Osub (Etempvar _y3 tint)
                                        (Etempvar _y2 tint) tint) tint)
                                    (Ebinop Omul
                                      (Ebinop Osub (Etempvar _y2 tint)
                                        (Etempvar _y1 tint) tint)
                                      (Ebinop Osub (Etempvar _x3 tint)
                                        (Etempvar _x2 tint) tint) tint) tint)
                                  tfloat))
                              (Ssequence
                                (Ssequence
                                  (Scall (Some _t'1)
                                    (Evar _sqrtf (Tfunction (tfloat :: nil)
                                                   tfloat cc_default))
                                    ((Ebinop Oadd
                                       (Ebinop Oadd
                                         (Ebinop Omul (Etempvar _nx tfloat)
                                           (Etempvar _nx tfloat) tfloat)
                                         (Ebinop Omul (Etempvar _ny tfloat)
                                           (Etempvar _ny tfloat) tfloat)
                                         tfloat)
                                       (Ebinop Omul (Etempvar _nz tfloat)
                                         (Etempvar _nz tfloat) tfloat)
                                       tfloat) :: nil))
                                  (Sset _mag (Etempvar _t'1 tfloat)))
                                (Ssequence
                                  (Sset _minY (Etempvar _y1 tint))
                                  (Ssequence
                                    (Sifthenelse (Ebinop Olt
                                                   (Etempvar _y2 tint)
                                                   (Etempvar _minY tint)
                                                   tint)
                                      (Sset _minY (Etempvar _y2 tint))
                                      Sskip)
                                    (Ssequence
                                      (Sifthenelse (Ebinop Olt
                                                     (Etempvar _y3 tint)
                                                     (Etempvar _minY tint)
                                                     tint)
                                        (Sset _minY (Etempvar _y3 tint))
                                        Sskip)
                                      (Ssequence
                                        (Sset _maxY (Etempvar _y1 tint))
                                        (Ssequence
                                          (Sifthenelse (Ebinop Ogt
                                                         (Etempvar _y2 tint)
                                                         (Etempvar _maxY tint)
                                                         tint)
                                            (Sset _maxY (Etempvar _y2 tint))
                                            Sskip)
                                          (Ssequence
                                            (Sifthenelse (Ebinop Ogt
                                                           (Etempvar _y3 tint)
                                                           (Etempvar _maxY tint)
                                                           tint)
                                              (Sset _maxY
                                                (Etempvar _y3 tint))
                                              Sskip)
                                            (Ssequence
                                              (Sifthenelse (Ebinop Olt
                                                             (Etempvar _mag tfloat)
                                                             (Econst_float (Float.of_bits (Int64.repr 4547007122018943789)) tdouble)
                                                             tint)
                                                (Sreturn (Some (Ecast
                                                                 (Econst_int (Int.repr 0) tint)
                                                                 (tptr tvoid))))
                                                Sskip)
                                              (Ssequence
                                                (Sset _mag
                                                  (Ecast
                                                    (Ebinop Odiv
                                                      (Econst_float (Float.of_bits (Int64.repr 4607182418800017408)) tdouble)
                                                      (Etempvar _mag tfloat)
                                                      tdouble) tfloat))
                                                (Ssequence
                                                  (Sset _nx
                                                    (Ebinop Omul
                                                      (Etempvar _nx tfloat)
                                                      (Etempvar _mag tfloat)
                                                      tfloat))
                                                  (Ssequence
                                                    (Sset _ny
                                                      (Ebinop Omul
                                                        (Etempvar _ny tfloat)
                                                        (Etempvar _mag tfloat)
                                                        tfloat))
                                                    (Ssequence
                                                      (Sset _nz
                                                        (Ebinop Omul
                                                          (Etempvar _nz tfloat)
                                                          (Etempvar _mag tfloat)
                                                          tfloat))
                                                      (Ssequence
                                                        (Ssequence
                                                          (Scall (Some _t'2)
                                                            (Evar _alloc_surface 
                                                            (Tfunction nil
                                                              (tptr (Tstruct _Surface noattr))
                                                              cc_default))
                                                            nil)
                                                          (Sset _surface
                                                            (Etempvar _t'2 (tptr (Tstruct _Surface noattr)))))
                                                        (Ssequence
                                                          (Sassign
                                                            (Ederef
                                                              (Ebinop Oadd
                                                                (Efield
                                                                  (Ederef
                                                                    (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                                                    (Tstruct _Surface noattr))
                                                                  _vertex1
                                                                  (tarray tshort 3))
                                                                (Econst_int (Int.repr 0) tint)
                                                                (tptr tshort))
                                                              tshort)
                                                            (Etempvar _x1 tint))
                                                          (Ssequence
                                                            (Sassign
                                                              (Ederef
                                                                (Ebinop Oadd
                                                                  (Efield
                                                                    (Ederef
                                                                    (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                                                    (Tstruct _Surface noattr))
                                                                    _vertex2
                                                                    (tarray tshort 3))
                                                                  (Econst_int (Int.repr 0) tint)
                                                                  (tptr tshort))
                                                                tshort)
                                                              (Etempvar _x2 tint))
                                                            (Ssequence
                                                              (Sassign
                                                                (Ederef
                                                                  (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                                                    (Tstruct _Surface noattr))
                                                                    _vertex3
                                                                    (tarray tshort 3))
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    (tptr tshort))
                                                                  tshort)
                                                                (Etempvar _x3 tint))
                                                              (Ssequence
                                                                (Sassign
                                                                  (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                                                    (Tstruct _Surface noattr))
                                                                    _vertex1
                                                                    (tarray tshort 3))
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (tptr tshort))
                                                                    tshort)
                                                                  (Etempvar _y1 tint))
                                                                (Ssequence
                                                                  (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                                                    (Tstruct _Surface noattr))
                                                                    _vertex2
                                                                    (tarray tshort 3))
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (tptr tshort))
                                                                    tshort)
                                                                    (Etempvar _y2 tint))
                                                                  (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                                                    (Tstruct _Surface noattr))
                                                                    _vertex3
                                                                    (tarray tshort 3))
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (tptr tshort))
                                                                    tshort)
                                                                    (Etempvar _y3 tint))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                                                    (Tstruct _Surface noattr))
                                                                    _vertex1
                                                                    (tarray tshort 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr tshort))
                                                                    tshort)
                                                                    (Etempvar _z1 tint))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                                                    (Tstruct _Surface noattr))
                                                                    _vertex2
                                                                    (tarray tshort 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr tshort))
                                                                    tshort)
                                                                    (Etempvar _z2 tint))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                                                    (Tstruct _Surface noattr))
                                                                    _vertex3
                                                                    (tarray tshort 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr tshort))
                                                                    tshort)
                                                                    (Etempvar _z3 tint))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Efield
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                                                    (Tstruct _Surface noattr))
                                                                    _normal
                                                                    (Tstruct __769 noattr))
                                                                    _x
                                                                    tfloat)
                                                                    (Etempvar _nx tfloat))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Efield
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                                                    (Tstruct _Surface noattr))
                                                                    _normal
                                                                    (Tstruct __769 noattr))
                                                                    _y
                                                                    tfloat)
                                                                    (Etempvar _ny tfloat))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Efield
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                                                    (Tstruct _Surface noattr))
                                                                    _normal
                                                                    (Tstruct __769 noattr))
                                                                    _z
                                                                    tfloat)
                                                                    (Etempvar _nz tfloat))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                                                    (Tstruct _Surface noattr))
                                                                    _originOffset
                                                                    tfloat)
                                                                    (Eunop Oneg
                                                                    (Ebinop Oadd
                                                                    (Ebinop Oadd
                                                                    (Ebinop Omul
                                                                    (Etempvar _nx tfloat)
                                                                    (Etempvar _x1 tint)
                                                                    tfloat)
                                                                    (Ebinop Omul
                                                                    (Etempvar _ny tfloat)
                                                                    (Etempvar _y1 tint)
                                                                    tfloat)
                                                                    tfloat)
                                                                    (Ebinop Omul
                                                                    (Etempvar _nz tfloat)
                                                                    (Etempvar _z1 tint)
                                                                    tfloat)
                                                                    tfloat)
                                                                    tfloat))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                                                    (Tstruct _Surface noattr))
                                                                    _lowerY
                                                                    tshort)
                                                                    (Ebinop Osub
                                                                    (Etempvar _minY tint)
                                                                    (Econst_int (Int.repr 5) tint)
                                                                    tint))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                                                    (Tstruct _Surface noattr))
                                                                    _upperY
                                                                    tshort)
                                                                    (Ebinop Oadd
                                                                    (Etempvar _maxY tint)
                                                                    (Econst_int (Int.repr 5) tint)
                                                                    tint))
                                                                    (Sreturn (Some (Etempvar _surface (tptr (Tstruct _Surface noattr))))))))))))))))))))))))))))))))))))))))))))))))
|}.

Definition f_surface_has_force := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_surfaceType, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_hasForce, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _hasForce (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sswitch (Etempvar _surfaceType tshort)
      (LScons (Some 4)
        Sskip
        (LScons (Some 14)
          Sskip
          (LScons (Some 36)
            Sskip
            (LScons (Some 37)
              Sskip
              (LScons (Some 39)
                Sskip
                (LScons (Some 44)
                  Sskip
                  (LScons (Some 45)
                    (Ssequence
                      (Sset _hasForce (Econst_int (Int.repr 1) tint))
                      Sbreak)
                    (LScons None Sbreak LSnil)))))))))
    (Sreturn (Some (Etempvar _hasForce tint)))))
|}.

Definition f_surf_has_no_cam_collision := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_surfaceType, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_flags, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _flags (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sswitch (Etempvar _surfaceType tshort)
      (LScons (Some 118)
        Sskip
        (LScons (Some 119)
          Sskip
          (LScons (Some 120)
            Sskip
            (LScons (Some 122)
              (Ssequence
                (Sset _flags
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 1) tint) tint))
                Sbreak)
              (LScons None Sbreak LSnil))))))
    (Sreturn (Some (Etempvar _flags tint)))))
|}.

Definition f_load_static_surfaces := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_data, (tptr (tptr tshort))) ::
                (_vertexData, (tptr tshort)) :: (_surfaceType, tshort) ::
                (_surfaceRooms, (tptr (tptr tschar))) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_numSurfaces, tint) ::
               (_surface, (tptr (Tstruct _Surface noattr))) ::
               (_room, tschar) :: (_hasForce, tshort) :: (_flags, tshort) ::
               (_t'3, (tptr (Tstruct _Surface noattr))) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'13, (tptr tshort)) ::
               (_t'12, (tptr tshort)) :: (_t'11, tschar) ::
               (_t'10, (tptr tschar)) :: (_t'9, (tptr tschar)) ::
               (_t'8, (tptr tschar)) :: (_t'7, tshort) ::
               (_t'6, (tptr tshort)) :: (_t'5, (tptr tshort)) ::
               (_t'4, (tptr tshort)) :: nil);
  fn_body :=
(Ssequence
  (Sset _room (Ecast (Econst_int (Int.repr 0) tint) tschar))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _surface_has_force (Tfunction (tshort :: nil) tint cc_default))
        ((Etempvar _surfaceType tshort) :: nil))
      (Sset _hasForce (Ecast (Etempvar _t'1 tint) tshort)))
    (Ssequence
      (Ssequence
        (Scall (Some _t'2)
          (Evar _surf_has_no_cam_collision (Tfunction (tshort :: nil) tint
                                             cc_default))
          ((Etempvar _surfaceType tshort) :: nil))
        (Sset _flags (Ecast (Etempvar _t'2 tint) tshort)))
      (Ssequence
        (Ssequence
          (Sset _t'13
            (Ederef (Etempvar _data (tptr (tptr tshort))) (tptr tshort)))
          (Sset _numSurfaces (Ederef (Etempvar _t'13 (tptr tshort)) tshort)))
        (Ssequence
          (Ssequence
            (Sset _t'12
              (Ederef (Etempvar _data (tptr (tptr tshort))) (tptr tshort)))
            (Sassign
              (Ederef (Etempvar _data (tptr (tptr tshort))) (tptr tshort))
              (Ebinop Oadd (Etempvar _t'12 (tptr tshort))
                (Econst_int (Int.repr 1) tint) (tptr tshort))))
          (Ssequence
            (Sset _i (Econst_int (Int.repr 0) tint))
            (Sloop
              (Ssequence
                (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                               (Etempvar _numSurfaces tint) tint)
                  Sskip
                  Sbreak)
                (Ssequence
                  (Ssequence
                    (Sset _t'8
                      (Ederef (Etempvar _surfaceRooms (tptr (tptr tschar)))
                        (tptr tschar)))
                    (Sifthenelse (Ebinop One (Etempvar _t'8 (tptr tschar))
                                   (Ecast (Econst_int (Int.repr 0) tint)
                                     (tptr tvoid)) tint)
                      (Ssequence
                        (Ssequence
                          (Sset _t'10
                            (Ederef
                              (Etempvar _surfaceRooms (tptr (tptr tschar)))
                              (tptr tschar)))
                          (Ssequence
                            (Sset _t'11
                              (Ederef (Etempvar _t'10 (tptr tschar)) tschar))
                            (Sset _room
                              (Ecast (Etempvar _t'11 tschar) tschar))))
                        (Ssequence
                          (Sset _t'9
                            (Ederef
                              (Etempvar _surfaceRooms (tptr (tptr tschar)))
                              (tptr tschar)))
                          (Sassign
                            (Ederef
                              (Etempvar _surfaceRooms (tptr (tptr tschar)))
                              (tptr tschar))
                            (Ebinop Oadd (Etempvar _t'9 (tptr tschar))
                              (Econst_int (Int.repr 1) tint) (tptr tschar)))))
                      Sskip))
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'3)
                        (Evar _read_surface_data (Tfunction
                                                   ((tptr tshort) ::
                                                    (tptr (tptr tshort)) ::
                                                    nil)
                                                   (tptr (Tstruct _Surface noattr))
                                                   cc_default))
                        ((Etempvar _vertexData (tptr tshort)) ::
                         (Etempvar _data (tptr (tptr tshort))) :: nil))
                      (Sset _surface
                        (Etempvar _t'3 (tptr (Tstruct _Surface noattr)))))
                    (Ssequence
                      (Sifthenelse (Ebinop One
                                     (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                     (Ecast (Econst_int (Int.repr 0) tint)
                                       (tptr tvoid)) tint)
                        (Ssequence
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                (Tstruct _Surface noattr)) _room tschar)
                            (Etempvar _room tschar))
                          (Ssequence
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                  (Tstruct _Surface noattr)) _type tshort)
                              (Etempvar _surfaceType tshort))
                            (Ssequence
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                    (Tstruct _Surface noattr)) _flags tschar)
                                (Ecast (Etempvar _flags tshort) tschar))
                              (Ssequence
                                (Sifthenelse (Etempvar _hasForce tshort)
                                  (Ssequence
                                    (Sset _t'6
                                      (Ederef
                                        (Etempvar _data (tptr (tptr tshort)))
                                        (tptr tshort)))
                                    (Ssequence
                                      (Sset _t'7
                                        (Ederef
                                          (Ebinop Oadd
                                            (Etempvar _t'6 (tptr tshort))
                                            (Econst_int (Int.repr 3) tint)
                                            (tptr tshort)) tshort))
                                      (Sassign
                                        (Efield
                                          (Ederef
                                            (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                            (Tstruct _Surface noattr)) _force
                                          tshort) (Etempvar _t'7 tshort))))
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                        (Tstruct _Surface noattr)) _force
                                      tshort) (Econst_int (Int.repr 0) tint)))
                                (Scall None
                                  (Evar _add_surface (Tfunction
                                                       ((tptr (Tstruct _Surface noattr)) ::
                                                        tint :: nil) tvoid
                                                       cc_default))
                                  ((Etempvar _surface (tptr (Tstruct _Surface noattr))) ::
                                   (Econst_int (Int.repr 0) tint) :: nil))))))
                        Sskip)
                      (Ssequence
                        (Ssequence
                          (Sset _t'5
                            (Ederef (Etempvar _data (tptr (tptr tshort)))
                              (tptr tshort)))
                          (Sassign
                            (Ederef (Etempvar _data (tptr (tptr tshort)))
                              (tptr tshort))
                            (Ebinop Oadd (Etempvar _t'5 (tptr tshort))
                              (Econst_int (Int.repr 3) tint) (tptr tshort))))
                        (Sifthenelse (Etempvar _hasForce tshort)
                          (Ssequence
                            (Sset _t'4
                              (Ederef (Etempvar _data (tptr (tptr tshort)))
                                (tptr tshort)))
                            (Sassign
                              (Ederef (Etempvar _data (tptr (tptr tshort)))
                                (tptr tshort))
                              (Ebinop Oadd (Etempvar _t'4 (tptr tshort))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))))
                          Sskip))))))
              (Sset _i
                (Ebinop Oadd (Etempvar _i tint)
                  (Econst_int (Int.repr 1) tint) tint)))))))))
|}.

Definition f_read_vertex_data := {|
  fn_return := (tptr tshort);
  fn_callconv := cc_default;
  fn_params := ((_data, (tptr (tptr tshort))) :: nil);
  fn_vars := ((_filler, (tarray tuchar 16)) :: nil);
  fn_temps := ((_numVertices, tint) :: (_vertexData, (tptr tshort)) ::
               (_t'3, (tptr tshort)) :: (_t'2, (tptr tshort)) ::
               (_t'1, (tptr tshort)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3 (Ederef (Etempvar _data (tptr (tptr tshort))) (tptr tshort)))
    (Sset _numVertices (Ederef (Etempvar _t'3 (tptr tshort)) tshort)))
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Ederef (Etempvar _data (tptr (tptr tshort))) (tptr tshort)))
      (Sassign (Ederef (Etempvar _data (tptr (tptr tshort))) (tptr tshort))
        (Ebinop Oadd (Etempvar _t'2 (tptr tshort))
          (Econst_int (Int.repr 1) tint) (tptr tshort))))
    (Ssequence
      (Sset _vertexData
        (Ederef (Etempvar _data (tptr (tptr tshort))) (tptr tshort)))
      (Ssequence
        (Ssequence
          (Sset _t'1
            (Ederef (Etempvar _data (tptr (tptr tshort))) (tptr tshort)))
          (Sassign
            (Ederef (Etempvar _data (tptr (tptr tshort))) (tptr tshort))
            (Ebinop Oadd (Etempvar _t'1 (tptr tshort))
              (Ebinop Omul (Econst_int (Int.repr 3) tint)
                (Etempvar _numVertices tint) tint) (tptr tshort))))
        (Sreturn (Some (Etempvar _vertexData (tptr tshort))))))))
|}.

Definition f_load_environmental_regions := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_data, (tptr (tptr tshort))) :: nil);
  fn_vars := nil;
  fn_temps := ((_numRegions, tint) :: (_i, tint) :: (_val, tshort) ::
               (_loX, tshort) :: (_loZ, tshort) :: (_hiX, tshort) ::
               (_hiZ, tshort) :: (_height, tshort) ::
               (_t'7, (tptr tshort)) :: (_t'6, (tptr tshort)) ::
               (_t'5, (tptr tshort)) :: (_t'4, (tptr tshort)) ::
               (_t'3, (tptr tshort)) :: (_t'2, (tptr tshort)) ::
               (_t'1, (tptr tshort)) :: (_t'14, (tptr tshort)) ::
               (_t'13, tshort) :: (_t'12, tshort) :: (_t'11, tshort) ::
               (_t'10, tshort) :: (_t'9, tshort) :: (_t'8, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'14 (Ederef (Etempvar _data (tptr (tptr tshort))) (tptr tshort)))
    (Sassign (Evar _gEnvironmentRegions (tptr tshort))
      (Etempvar _t'14 (tptr tshort))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'1
          (Ederef (Etempvar _data (tptr (tptr tshort))) (tptr tshort)))
        (Sassign (Ederef (Etempvar _data (tptr (tptr tshort))) (tptr tshort))
          (Ebinop Oadd (Etempvar _t'1 (tptr tshort))
            (Econst_int (Int.repr 1) tint) (tptr tshort))))
      (Sset _numRegions (Ederef (Etempvar _t'1 (tptr tshort)) tshort)))
    (Ssequence
      Sskip
      (Ssequence
        (Sset _i (Econst_int (Int.repr 0) tint))
        (Sloop
          (Ssequence
            (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                           (Etempvar _numRegions tint) tint)
              Sskip
              Sbreak)
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'2
                    (Ederef (Etempvar _data (tptr (tptr tshort)))
                      (tptr tshort)))
                  (Sassign
                    (Ederef (Etempvar _data (tptr (tptr tshort)))
                      (tptr tshort))
                    (Ebinop Oadd (Etempvar _t'2 (tptr tshort))
                      (Econst_int (Int.repr 1) tint) (tptr tshort))))
                (Ssequence
                  (Sset _t'13 (Ederef (Etempvar _t'2 (tptr tshort)) tshort))
                  (Sset _val (Ecast (Etempvar _t'13 tshort) tshort))))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'3
                      (Ederef (Etempvar _data (tptr (tptr tshort)))
                        (tptr tshort)))
                    (Sassign
                      (Ederef (Etempvar _data (tptr (tptr tshort)))
                        (tptr tshort))
                      (Ebinop Oadd (Etempvar _t'3 (tptr tshort))
                        (Econst_int (Int.repr 1) tint) (tptr tshort))))
                  (Ssequence
                    (Sset _t'12
                      (Ederef (Etempvar _t'3 (tptr tshort)) tshort))
                    (Sset _loX (Ecast (Etempvar _t'12 tshort) tshort))))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'4
                        (Ederef (Etempvar _data (tptr (tptr tshort)))
                          (tptr tshort)))
                      (Sassign
                        (Ederef (Etempvar _data (tptr (tptr tshort)))
                          (tptr tshort))
                        (Ebinop Oadd (Etempvar _t'4 (tptr tshort))
                          (Econst_int (Int.repr 1) tint) (tptr tshort))))
                    (Ssequence
                      (Sset _t'11
                        (Ederef (Etempvar _t'4 (tptr tshort)) tshort))
                      (Sset _hiX (Ecast (Etempvar _t'11 tshort) tshort))))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'5
                          (Ederef (Etempvar _data (tptr (tptr tshort)))
                            (tptr tshort)))
                        (Sassign
                          (Ederef (Etempvar _data (tptr (tptr tshort)))
                            (tptr tshort))
                          (Ebinop Oadd (Etempvar _t'5 (tptr tshort))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))))
                      (Ssequence
                        (Sset _t'10
                          (Ederef (Etempvar _t'5 (tptr tshort)) tshort))
                        (Sset _loZ (Ecast (Etempvar _t'10 tshort) tshort))))
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'6
                            (Ederef (Etempvar _data (tptr (tptr tshort)))
                              (tptr tshort)))
                          (Sassign
                            (Ederef (Etempvar _data (tptr (tptr tshort)))
                              (tptr tshort))
                            (Ebinop Oadd (Etempvar _t'6 (tptr tshort))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))))
                        (Ssequence
                          (Sset _t'9
                            (Ederef (Etempvar _t'6 (tptr tshort)) tshort))
                          (Sset _hiZ (Ecast (Etempvar _t'9 tshort) tshort))))
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'7
                              (Ederef (Etempvar _data (tptr (tptr tshort)))
                                (tptr tshort)))
                            (Sassign
                              (Ederef (Etempvar _data (tptr (tptr tshort)))
                                (tptr tshort))
                              (Ebinop Oadd (Etempvar _t'7 (tptr tshort))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))))
                          (Ssequence
                            (Sset _t'8
                              (Ederef (Etempvar _t'7 (tptr tshort)) tshort))
                            (Sset _height
                              (Ecast (Etempvar _t'8 tshort) tshort))))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Evar _gEnvironmentLevels (tarray tint 20))
                              (Etempvar _i tint) (tptr tint)) tint)
                          (Etempvar _height tshort)))))))))
          (Sset _i
            (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint)
              tint)))))))
|}.

Definition f_alloc_surface_pools := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, (tptr tvoid)) :: (_t'1, (tptr tvoid)) ::
               (_t'3, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _sSurfacePoolSize tshort) (Econst_int (Int.repr 2300) tint))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _main_pool_alloc (Tfunction (tuint :: tuint :: nil)
                                 (tptr tvoid) cc_default))
        ((Ebinop Omul (Econst_int (Int.repr 7000) tint)
           (Esizeof (Tstruct _SurfaceNode noattr) tuint) tuint) ::
         (Econst_int (Int.repr 0) tint) :: nil))
      (Sassign (Evar _sSurfaceNodePool (tptr (Tstruct _SurfaceNode noattr)))
        (Etempvar _t'1 (tptr tvoid))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'3 (Evar _sSurfacePoolSize tshort))
          (Scall (Some _t'2)
            (Evar _main_pool_alloc (Tfunction (tuint :: tuint :: nil)
                                     (tptr tvoid) cc_default))
            ((Ebinop Omul (Etempvar _t'3 tshort)
               (Esizeof (Tstruct _Surface noattr) tuint) tuint) ::
             (Econst_int (Int.repr 0) tint) :: nil)))
        (Sassign (Evar _sSurfacePool (tptr (Tstruct _Surface noattr)))
          (Etempvar _t'2 (tptr tvoid))))
      (Ssequence
        (Sassign (Evar _gCCMEnteredSlide tshort)
          (Econst_int (Int.repr 0) tint))
        (Scall None
          (Evar _reset_red_coins_collected (Tfunction nil tvoid cc_default))
          nil)))))
|}.

Definition f_load_area_terrain := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_index, tshort) :: (_data, (tptr tshort)) ::
                (_surfaceRooms, (tptr tschar)) ::
                (_macroObjects, (tptr tshort)) :: nil);
  fn_vars := ((_data, (tptr tshort)) :: (_surfaceRooms, (tptr tschar)) ::
              (_filler, (tarray tuchar 4)) :: nil);
  fn_temps := ((_terrainLoadType, tshort) :: (_vertexData, (tptr tshort)) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, (tptr tshort)) ::
               (_t'11, tshort) :: (_t'10, (tptr tshort)) ::
               (_t'9, (tptr tshort)) :: (_t'8, tshort) :: (_t'7, tshort) ::
               (_t'6, tshort) :: (_t'5, tint) :: (_t'4, tint) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _data (tptr tshort)) (Etempvar _data (tptr tshort)))
  (Ssequence
    (Sassign (Evar _surfaceRooms (tptr tschar))
      (Etempvar _surfaceRooms (tptr tschar)))
    (Ssequence
      (Sassign (Evar _gEnvironmentRegions (tptr tshort))
        (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
      (Ssequence
        (Sassign (Evar _unused8038BE90 tint) (Econst_int (Int.repr 0) tint))
        (Ssequence
          (Sassign (Evar _gSurfaceNodesAllocated tint)
            (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Sassign (Evar _gSurfacesAllocated tint)
              (Econst_int (Int.repr 0) tint))
            (Ssequence
              (Scall None
                (Evar _clear_static_surfaces (Tfunction nil tvoid cc_default))
                nil)
              (Ssequence
                (Sloop
                  (Ssequence
                    Sskip
                    (Ssequence
                      (Ssequence
                        (Sset _t'10 (Evar _data (tptr tshort)))
                        (Ssequence
                          (Sset _t'11
                            (Ederef (Etempvar _t'10 (tptr tshort)) tshort))
                          (Sset _terrainLoadType
                            (Ecast (Etempvar _t'11 tshort) tshort))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'9 (Evar _data (tptr tshort)))
                          (Sassign (Evar _data (tptr tshort))
                            (Ebinop Oadd (Etempvar _t'9 (tptr tshort))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))))
                        (Sifthenelse (Ebinop Olt
                                       (Etempvar _terrainLoadType tshort)
                                       (Econst_int (Int.repr 64) tint) tint)
                          (Scall None
                            (Evar _load_static_surfaces (Tfunction
                                                          ((tptr (tptr tshort)) ::
                                                           (tptr tshort) ::
                                                           tshort ::
                                                           (tptr (tptr tschar)) ::
                                                           nil) tvoid
                                                          cc_default))
                            ((Eaddrof (Evar _data (tptr tshort))
                               (tptr (tptr tshort))) ::
                             (Etempvar _vertexData (tptr tshort)) ::
                             (Etempvar _terrainLoadType tshort) ::
                             (Eaddrof (Evar _surfaceRooms (tptr tschar))
                               (tptr (tptr tschar))) :: nil))
                          (Sifthenelse (Ebinop Oeq
                                         (Etempvar _terrainLoadType tshort)
                                         (Econst_int (Int.repr 64) tint)
                                         tint)
                            (Ssequence
                              (Scall (Some _t'1)
                                (Evar _read_vertex_data (Tfunction
                                                          ((tptr (tptr tshort)) ::
                                                           nil) (tptr tshort)
                                                          cc_default))
                                ((Eaddrof (Evar _data (tptr tshort))
                                   (tptr (tptr tshort))) :: nil))
                              (Sset _vertexData
                                (Etempvar _t'1 (tptr tshort))))
                            (Sifthenelse (Ebinop Oeq
                                           (Etempvar _terrainLoadType tshort)
                                           (Econst_int (Int.repr 67) tint)
                                           tint)
                              (Scall None
                                (Evar _spawn_special_objects (Tfunction
                                                               (tshort ::
                                                                (tptr (tptr tshort)) ::
                                                                nil) tvoid
                                                               cc_default))
                                ((Etempvar _index tshort) ::
                                 (Eaddrof (Evar _data (tptr tshort))
                                   (tptr (tptr tshort))) :: nil))
                              (Sifthenelse (Ebinop Oeq
                                             (Etempvar _terrainLoadType tshort)
                                             (Econst_int (Int.repr 68) tint)
                                             tint)
                                (Scall None
                                  (Evar _load_environmental_regions (Tfunction
                                                                    ((tptr (tptr tshort)) ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                  ((Eaddrof (Evar _data (tptr tshort))
                                     (tptr (tptr tshort))) :: nil))
                                (Sifthenelse (Ebinop Oeq
                                               (Etempvar _terrainLoadType tshort)
                                               (Econst_int (Int.repr 65) tint)
                                               tint)
                                  Scontinue
                                  (Sifthenelse (Ebinop Oeq
                                                 (Etempvar _terrainLoadType tshort)
                                                 (Econst_int (Int.repr 66) tint)
                                                 tint)
                                    Sbreak
                                    (Sifthenelse (Ebinop Oge
                                                   (Etempvar _terrainLoadType tshort)
                                                   (Econst_int (Int.repr 101) tint)
                                                   tint)
                                      (Scall None
                                        (Evar _load_static_surfaces (Tfunction
                                                                    ((tptr (tptr tshort)) ::
                                                                    (tptr tshort) ::
                                                                    tshort ::
                                                                    (tptr (tptr tschar)) ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                        ((Eaddrof (Evar _data (tptr tshort))
                                           (tptr (tptr tshort))) ::
                                         (Etempvar _vertexData (tptr tshort)) ::
                                         (Etempvar _terrainLoadType tshort) ::
                                         (Eaddrof
                                           (Evar _surfaceRooms (tptr tschar))
                                           (tptr (tptr tschar))) :: nil))
                                      Sskip))))))))))
                  Sskip)
                (Ssequence
                  (Ssequence
                    (Sifthenelse (Ebinop One
                                   (Etempvar _macroObjects (tptr tshort))
                                   (Ecast (Econst_int (Int.repr 0) tint)
                                     (tptr tvoid)) tint)
                      (Ssequence
                        (Sset _t'8
                          (Ederef (Etempvar _macroObjects (tptr tshort))
                            tshort))
                        (Sset _t'3
                          (Ecast
                            (Ebinop One (Etempvar _t'8 tshort)
                              (Eunop Oneg (Econst_int (Int.repr 1) tint)
                                tint) tint) tbool)))
                      (Sset _t'3 (Econst_int (Int.repr 0) tint)))
                    (Sifthenelse (Etempvar _t'3 tint)
                      (Ssequence
                        (Ssequence
                          (Sset _t'6
                            (Ederef (Etempvar _macroObjects (tptr tshort))
                              tshort))
                          (Sifthenelse (Ebinop Ole
                                         (Econst_int (Int.repr 0) tint)
                                         (Etempvar _t'6 tshort) tint)
                            (Ssequence
                              (Sset _t'7
                                (Ederef
                                  (Etempvar _macroObjects (tptr tshort))
                                  tshort))
                              (Sset _t'2
                                (Ecast
                                  (Ebinop Olt (Etempvar _t'7 tshort)
                                    (Econst_int (Int.repr 30) tint) tint)
                                  tbool)))
                            (Sset _t'2 (Econst_int (Int.repr 0) tint))))
                        (Sifthenelse (Etempvar _t'2 tint)
                          (Scall None
                            (Evar _spawn_macro_objects_hardcoded (Tfunction
                                                                   (tshort ::
                                                                    (tptr tshort) ::
                                                                    nil)
                                                                   tvoid
                                                                   cc_default))
                            ((Etempvar _index tshort) ::
                             (Etempvar _macroObjects (tptr tshort)) :: nil))
                          (Scall None
                            (Evar _spawn_macro_objects (Tfunction
                                                         (tshort ::
                                                          (tptr tshort) ::
                                                          nil) tvoid
                                                         cc_default))
                            ((Etempvar _index tshort) ::
                             (Etempvar _macroObjects (tptr tshort)) :: nil))))
                      Sskip))
                  (Ssequence
                    (Ssequence
                      (Sset _t'5 (Evar _gSurfaceNodesAllocated tint))
                      (Sassign (Evar _gNumStaticSurfaceNodes tint)
                        (Etempvar _t'5 tint)))
                    (Ssequence
                      (Sset _t'4 (Evar _gSurfacesAllocated tint))
                      (Sassign (Evar _gNumStaticSurfaces tint)
                        (Etempvar _t'4 tint)))))))))))))
|}.

Definition f_clear_dynamic_surfaces := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _gTimeStopState tuint))
  (Sifthenelse (Eunop Onotbool
                 (Ebinop Oand (Etempvar _t'1 tuint)
                   (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                     (Econst_int (Int.repr 6) tint) tint) tuint) tint)
    (Ssequence
      (Ssequence
        (Sset _t'3 (Evar _gNumStaticSurfaces tint))
        (Sassign (Evar _gSurfacesAllocated tint) (Etempvar _t'3 tint)))
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _gNumStaticSurfaceNodes tint))
          (Sassign (Evar _gSurfaceNodesAllocated tint) (Etempvar _t'2 tint)))
        (Scall None
          (Evar _clear_spatial_partition (Tfunction
                                           ((tptr (tarray (Tstruct _SurfaceNode noattr) 3)) ::
                                            nil) tvoid cc_default))
          ((Ebinop Oadd
             (Ederef
               (Ebinop Oadd
                 (Evar _gDynamicSurfacePartition (tarray (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16) 16))
                 (Econst_int (Int.repr 0) tint)
                 (tptr (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16)))
               (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16))
             (Econst_int (Int.repr 0) tint)
             (tptr (tarray (Tstruct _SurfaceNode noattr) 3))) :: nil))))
    Sskip))
|}.

Definition f_transform_object_vertices := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_data, (tptr (tptr tshort))) ::
                (_vertexData, (tptr tshort)) :: nil);
  fn_vars := ((_m, (tarray (tarray tfloat 4) 4)) :: nil);
  fn_temps := ((_vertices, (tptr tshort)) :: (_vx, tfloat) ::
               (_vy, tfloat) :: (_vz, tfloat) :: (_numVertices, tint) ::
               (_objectTransform, (tptr (tarray (tarray tfloat 4) 4))) ::
               (_t'7, (tptr tshort)) :: (_t'6, (tptr tshort)) ::
               (_t'5, (tptr tshort)) :: (_t'4, (tptr tshort)) ::
               (_t'3, (tptr tshort)) :: (_t'2, (tptr tshort)) ::
               (_t'1, tint) :: (_t'30, (tptr (Tstruct _Object noattr))) ::
               (_t'29, (tptr tshort)) :: (_t'28, (tptr tshort)) ::
               (_t'27, (tptr (Tstruct _Object noattr))) ::
               (_t'26, (tptr (Tstruct _Object noattr))) ::
               (_t'25, (tptr (tarray (tarray tfloat 4) 4))) ::
               (_t'24, (tptr (Tstruct _Object noattr))) ::
               (_t'23, (tptr (Tstruct _Object noattr))) :: (_t'22, tshort) ::
               (_t'21, tshort) :: (_t'20, tshort) :: (_t'19, tfloat) ::
               (_t'18, tfloat) :: (_t'17, tfloat) :: (_t'16, tfloat) ::
               (_t'15, tfloat) :: (_t'14, tfloat) :: (_t'13, tfloat) ::
               (_t'12, tfloat) :: (_t'11, tfloat) :: (_t'10, tfloat) ::
               (_t'9, tfloat) :: (_t'8, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'30 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
    (Sset _objectTransform
      (Eaddrof
        (Efield
          (Ederef (Etempvar _t'30 (tptr (Tstruct _Object noattr)))
            (Tstruct _Object noattr)) _transform
          (tarray (tarray tfloat 4) 4)) (tptr (tarray (tarray tfloat 4) 4)))))
  (Ssequence
    (Ssequence
      (Sset _t'29
        (Ederef (Etempvar _data (tptr (tptr tshort))) (tptr tshort)))
      (Sset _numVertices (Ederef (Etempvar _t'29 (tptr tshort)) tshort)))
    (Ssequence
      (Ssequence
        (Sset _t'28
          (Ederef (Etempvar _data (tptr (tptr tshort))) (tptr tshort)))
        (Sassign (Ederef (Etempvar _data (tptr (tptr tshort))) (tptr tshort))
          (Ebinop Oadd (Etempvar _t'28 (tptr tshort))
            (Econst_int (Int.repr 1) tint) (tptr tshort))))
      (Ssequence
        (Sset _vertices
          (Ederef (Etempvar _data (tptr (tptr tshort))) (tptr tshort)))
        (Ssequence
          (Ssequence
            (Sset _t'24
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'25
                (Efield
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _t'24 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _header
                      (Tstruct _ObjectNode noattr)) _gfx
                    (Tstruct _GraphNodeObject noattr)) _throwMatrix
                  (tptr (tarray (tarray tfloat 4) 4))))
              (Sifthenelse (Ebinop Oeq
                             (Etempvar _t'25 (tptr (tarray (tarray tfloat 4) 4)))
                             (Ecast (Econst_int (Int.repr 0) tint)
                               (tptr tvoid)) tint)
                (Ssequence
                  (Ssequence
                    (Sset _t'27
                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                    (Sassign
                      (Efield
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'27 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _header
                            (Tstruct _ObjectNode noattr)) _gfx
                          (Tstruct _GraphNodeObject noattr)) _throwMatrix
                        (tptr (tarray (tarray tfloat 4) 4)))
                      (Etempvar _objectTransform (tptr (tarray (tarray tfloat 4) 4)))))
                  (Ssequence
                    (Sset _t'26
                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                    (Scall None
                      (Evar _obj_build_transform_from_pos_and_angle (Tfunction
                                                                    ((tptr (Tstruct _Object noattr)) ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                      ((Etempvar _t'26 (tptr (Tstruct _Object noattr))) ::
                       (Econst_int (Int.repr 6) tint) ::
                       (Econst_int (Int.repr 18) tint) :: nil))))
                Sskip)))
          (Ssequence
            (Ssequence
              (Sset _t'23
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Scall None
                (Evar _obj_apply_scale_to_matrix (Tfunction
                                                   ((tptr (Tstruct _Object noattr)) ::
                                                    (tptr (tarray tfloat 4)) ::
                                                    (tptr (tarray tfloat 4)) ::
                                                    nil) tvoid cc_default))
                ((Etempvar _t'23 (tptr (Tstruct _Object noattr))) ::
                 (Evar _m (tarray (tarray tfloat 4) 4)) ::
                 (Ederef
                   (Etempvar _objectTransform (tptr (tarray (tarray tfloat 4) 4)))
                   (tarray (tarray tfloat 4) 4)) :: nil)))
            (Ssequence
              (Sloop
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'1 (Etempvar _numVertices tint))
                      (Sset _numVertices
                        (Ebinop Osub (Etempvar _t'1 tint)
                          (Econst_int (Int.repr 1) tint) tint)))
                    (Sifthenelse (Etempvar _t'1 tint) Sskip Sbreak))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'2 (Etempvar _vertices (tptr tshort)))
                        (Sset _vertices
                          (Ebinop Oadd (Etempvar _t'2 (tptr tshort))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))))
                      (Ssequence
                        (Sset _t'22
                          (Ederef (Etempvar _t'2 (tptr tshort)) tshort))
                        (Sset _vx (Ecast (Etempvar _t'22 tshort) tfloat))))
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'3 (Etempvar _vertices (tptr tshort)))
                          (Sset _vertices
                            (Ebinop Oadd (Etempvar _t'3 (tptr tshort))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))))
                        (Ssequence
                          (Sset _t'21
                            (Ederef (Etempvar _t'3 (tptr tshort)) tshort))
                          (Sset _vy (Ecast (Etempvar _t'21 tshort) tfloat))))
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'4 (Etempvar _vertices (tptr tshort)))
                            (Sset _vertices
                              (Ebinop Oadd (Etempvar _t'4 (tptr tshort))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))))
                          (Ssequence
                            (Sset _t'20
                              (Ederef (Etempvar _t'4 (tptr tshort)) tshort))
                            (Sset _vz (Ecast (Etempvar _t'20 tshort) tfloat))))
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Sset _t'5
                                (Etempvar _vertexData (tptr tshort)))
                              (Sset _vertexData
                                (Ebinop Oadd (Etempvar _t'5 (tptr tshort))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tshort))))
                            (Ssequence
                              (Sset _t'16
                                (Ederef
                                  (Ebinop Oadd
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _m (tarray (tarray tfloat 4) 4))
                                        (Econst_int (Int.repr 0) tint)
                                        (tptr (tarray tfloat 4)))
                                      (tarray tfloat 4))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr tfloat)) tfloat))
                              (Ssequence
                                (Sset _t'17
                                  (Ederef
                                    (Ebinop Oadd
                                      (Ederef
                                        (Ebinop Oadd
                                          (Evar _m (tarray (tarray tfloat 4) 4))
                                          (Econst_int (Int.repr 1) tint)
                                          (tptr (tarray tfloat 4)))
                                        (tarray tfloat 4))
                                      (Econst_int (Int.repr 0) tint)
                                      (tptr tfloat)) tfloat))
                                (Ssequence
                                  (Sset _t'18
                                    (Ederef
                                      (Ebinop Oadd
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _m (tarray (tarray tfloat 4) 4))
                                            (Econst_int (Int.repr 2) tint)
                                            (tptr (tarray tfloat 4)))
                                          (tarray tfloat 4))
                                        (Econst_int (Int.repr 0) tint)
                                        (tptr tfloat)) tfloat))
                                  (Ssequence
                                    (Sset _t'19
                                      (Ederef
                                        (Ebinop Oadd
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _m (tarray (tarray tfloat 4) 4))
                                              (Econst_int (Int.repr 3) tint)
                                              (tptr (tarray tfloat 4)))
                                            (tarray tfloat 4))
                                          (Econst_int (Int.repr 0) tint)
                                          (tptr tfloat)) tfloat))
                                    (Sassign
                                      (Ederef (Etempvar _t'5 (tptr tshort))
                                        tshort)
                                      (Ecast
                                        (Ebinop Oadd
                                          (Ebinop Oadd
                                            (Ebinop Oadd
                                              (Ebinop Omul
                                                (Etempvar _vx tfloat)
                                                (Etempvar _t'16 tfloat)
                                                tfloat)
                                              (Ebinop Omul
                                                (Etempvar _vy tfloat)
                                                (Etempvar _t'17 tfloat)
                                                tfloat) tfloat)
                                            (Ebinop Omul
                                              (Etempvar _vz tfloat)
                                              (Etempvar _t'18 tfloat) tfloat)
                                            tfloat) (Etempvar _t'19 tfloat)
                                          tfloat) tshort)))))))
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Sset _t'6
                                  (Etempvar _vertexData (tptr tshort)))
                                (Sset _vertexData
                                  (Ebinop Oadd (Etempvar _t'6 (tptr tshort))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr tshort))))
                              (Ssequence
                                (Sset _t'12
                                  (Ederef
                                    (Ebinop Oadd
                                      (Ederef
                                        (Ebinop Oadd
                                          (Evar _m (tarray (tarray tfloat 4) 4))
                                          (Econst_int (Int.repr 0) tint)
                                          (tptr (tarray tfloat 4)))
                                        (tarray tfloat 4))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr tfloat)) tfloat))
                                (Ssequence
                                  (Sset _t'13
                                    (Ederef
                                      (Ebinop Oadd
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _m (tarray (tarray tfloat 4) 4))
                                            (Econst_int (Int.repr 1) tint)
                                            (tptr (tarray tfloat 4)))
                                          (tarray tfloat 4))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr tfloat)) tfloat))
                                  (Ssequence
                                    (Sset _t'14
                                      (Ederef
                                        (Ebinop Oadd
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _m (tarray (tarray tfloat 4) 4))
                                              (Econst_int (Int.repr 2) tint)
                                              (tptr (tarray tfloat 4)))
                                            (tarray tfloat 4))
                                          (Econst_int (Int.repr 1) tint)
                                          (tptr tfloat)) tfloat))
                                    (Ssequence
                                      (Sset _t'15
                                        (Ederef
                                          (Ebinop Oadd
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _m (tarray (tarray tfloat 4) 4))
                                                (Econst_int (Int.repr 3) tint)
                                                (tptr (tarray tfloat 4)))
                                              (tarray tfloat 4))
                                            (Econst_int (Int.repr 1) tint)
                                            (tptr tfloat)) tfloat))
                                      (Sassign
                                        (Ederef (Etempvar _t'6 (tptr tshort))
                                          tshort)
                                        (Ecast
                                          (Ebinop Oadd
                                            (Ebinop Oadd
                                              (Ebinop Oadd
                                                (Ebinop Omul
                                                  (Etempvar _vx tfloat)
                                                  (Etempvar _t'12 tfloat)
                                                  tfloat)
                                                (Ebinop Omul
                                                  (Etempvar _vy tfloat)
                                                  (Etempvar _t'13 tfloat)
                                                  tfloat) tfloat)
                                              (Ebinop Omul
                                                (Etempvar _vz tfloat)
                                                (Etempvar _t'14 tfloat)
                                                tfloat) tfloat)
                                            (Etempvar _t'15 tfloat) tfloat)
                                          tshort)))))))
                            (Ssequence
                              (Ssequence
                                (Sset _t'7
                                  (Etempvar _vertexData (tptr tshort)))
                                (Sset _vertexData
                                  (Ebinop Oadd (Etempvar _t'7 (tptr tshort))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr tshort))))
                              (Ssequence
                                (Sset _t'8
                                  (Ederef
                                    (Ebinop Oadd
                                      (Ederef
                                        (Ebinop Oadd
                                          (Evar _m (tarray (tarray tfloat 4) 4))
                                          (Econst_int (Int.repr 0) tint)
                                          (tptr (tarray tfloat 4)))
                                        (tarray tfloat 4))
                                      (Econst_int (Int.repr 2) tint)
                                      (tptr tfloat)) tfloat))
                                (Ssequence
                                  (Sset _t'9
                                    (Ederef
                                      (Ebinop Oadd
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _m (tarray (tarray tfloat 4) 4))
                                            (Econst_int (Int.repr 1) tint)
                                            (tptr (tarray tfloat 4)))
                                          (tarray tfloat 4))
                                        (Econst_int (Int.repr 2) tint)
                                        (tptr tfloat)) tfloat))
                                  (Ssequence
                                    (Sset _t'10
                                      (Ederef
                                        (Ebinop Oadd
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _m (tarray (tarray tfloat 4) 4))
                                              (Econst_int (Int.repr 2) tint)
                                              (tptr (tarray tfloat 4)))
                                            (tarray tfloat 4))
                                          (Econst_int (Int.repr 2) tint)
                                          (tptr tfloat)) tfloat))
                                    (Ssequence
                                      (Sset _t'11
                                        (Ederef
                                          (Ebinop Oadd
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _m (tarray (tarray tfloat 4) 4))
                                                (Econst_int (Int.repr 3) tint)
                                                (tptr (tarray tfloat 4)))
                                              (tarray tfloat 4))
                                            (Econst_int (Int.repr 2) tint)
                                            (tptr tfloat)) tfloat))
                                      (Sassign
                                        (Ederef (Etempvar _t'7 (tptr tshort))
                                          tshort)
                                        (Ecast
                                          (Ebinop Oadd
                                            (Ebinop Oadd
                                              (Ebinop Oadd
                                                (Ebinop Omul
                                                  (Etempvar _vx tfloat)
                                                  (Etempvar _t'8 tfloat)
                                                  tfloat)
                                                (Ebinop Omul
                                                  (Etempvar _vy tfloat)
                                                  (Etempvar _t'9 tfloat)
                                                  tfloat) tfloat)
                                              (Ebinop Omul
                                                (Etempvar _vz tfloat)
                                                (Etempvar _t'10 tfloat)
                                                tfloat) tfloat)
                                            (Etempvar _t'11 tfloat) tfloat)
                                          tshort)))))))))))))
                Sskip)
              (Sassign
                (Ederef (Etempvar _data (tptr (tptr tshort))) (tptr tshort))
                (Etempvar _vertices (tptr tshort))))))))))
|}.

Definition f_load_object_surfaces := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_data, (tptr (tptr tshort))) ::
                (_vertexData, (tptr tshort)) :: nil);
  fn_vars := nil;
  fn_temps := ((_surfaceType, tint) :: (_i, tint) :: (_numSurfaces, tint) ::
               (_hasForce, tshort) :: (_flags, tshort) :: (_room, tshort) ::
               (_surface, (tptr (Tstruct _Surface noattr))) ::
               (_t'4, (tptr (Tstruct _Surface noattr))) ::
               (_t'3, (tptr tvoid)) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'16, (tptr tshort)) :: (_t'15, (tptr tshort)) ::
               (_t'14, (tptr tshort)) :: (_t'13, (tptr tshort)) ::
               (_t'12, (tptr tuint)) ::
               (_t'11, (tptr (Tstruct _Object noattr))) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tshort) ::
               (_t'8, (tptr tshort)) :: (_t'7, tschar) ::
               (_t'6, (tptr tshort)) :: (_t'5, (tptr tshort)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'16 (Ederef (Etempvar _data (tptr (tptr tshort))) (tptr tshort)))
    (Sset _surfaceType (Ederef (Etempvar _t'16 (tptr tshort)) tshort)))
  (Ssequence
    (Ssequence
      (Sset _t'15
        (Ederef (Etempvar _data (tptr (tptr tshort))) (tptr tshort)))
      (Sassign (Ederef (Etempvar _data (tptr (tptr tshort))) (tptr tshort))
        (Ebinop Oadd (Etempvar _t'15 (tptr tshort))
          (Econst_int (Int.repr 1) tint) (tptr tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'14
          (Ederef (Etempvar _data (tptr (tptr tshort))) (tptr tshort)))
        (Sset _numSurfaces (Ederef (Etempvar _t'14 (tptr tshort)) tshort)))
      (Ssequence
        (Ssequence
          (Sset _t'13
            (Ederef (Etempvar _data (tptr (tptr tshort))) (tptr tshort)))
          (Sassign
            (Ederef (Etempvar _data (tptr (tptr tshort))) (tptr tshort))
            (Ebinop Oadd (Etempvar _t'13 (tptr tshort))
              (Econst_int (Int.repr 1) tint) (tptr tshort))))
        (Ssequence
          (Ssequence
            (Scall (Some _t'1)
              (Evar _surface_has_force (Tfunction (tshort :: nil) tint
                                         cc_default))
              ((Etempvar _surfaceType tint) :: nil))
            (Sset _hasForce (Ecast (Etempvar _t'1 tint) tshort)))
          (Ssequence
            (Ssequence
              (Scall (Some _t'2)
                (Evar _surf_has_no_cam_collision (Tfunction (tshort :: nil)
                                                   tint cc_default))
                ((Etempvar _surfaceType tint) :: nil))
              (Sset _flags (Ecast (Etempvar _t'2 tint) tshort)))
            (Ssequence
              (Sset _flags
                (Ecast
                  (Ebinop Oor (Etempvar _flags tshort)
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 0) tint) tint) tint) tshort))
              (Ssequence
                (Ssequence
                  (Scall (Some _t'3)
                    (Evar _segmented_to_virtual (Tfunction
                                                  ((tptr tvoid) :: nil)
                                                  (tptr tvoid) cc_default))
                    ((Evar _bhvDDDWarp (tarray tuint 0)) :: nil))
                  (Ssequence
                    (Sset _t'11
                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sset _t'12
                        (Efield
                          (Ederef
                            (Etempvar _t'11 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _behavior (tptr tuint)))
                      (Sifthenelse (Ebinop Oeq (Etempvar _t'12 (tptr tuint))
                                     (Etempvar _t'3 (tptr tvoid)) tint)
                        (Sset _room
                          (Ecast (Econst_int (Int.repr 5) tint) tshort))
                        (Sset _room
                          (Ecast (Econst_int (Int.repr 0) tint) tshort))))))
                (Ssequence
                  (Sset _i (Econst_int (Int.repr 0) tint))
                  (Sloop
                    (Ssequence
                      (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                                     (Etempvar _numSurfaces tint) tint)
                        Sskip
                        Sbreak)
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'4)
                            (Evar _read_surface_data (Tfunction
                                                       ((tptr tshort) ::
                                                        (tptr (tptr tshort)) ::
                                                        nil)
                                                       (tptr (Tstruct _Surface noattr))
                                                       cc_default))
                            ((Etempvar _vertexData (tptr tshort)) ::
                             (Etempvar _data (tptr (tptr tshort))) :: nil))
                          (Sset _surface
                            (Etempvar _t'4 (tptr (Tstruct _Surface noattr)))))
                        (Ssequence
                          (Sifthenelse (Ebinop One
                                         (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                         (Ecast
                                           (Econst_int (Int.repr 0) tint)
                                           (tptr tvoid)) tint)
                            (Ssequence
                              (Ssequence
                                (Sset _t'10
                                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                      (Tstruct _Surface noattr)) _object
                                    (tptr (Tstruct _Object noattr)))
                                  (Etempvar _t'10 (tptr (Tstruct _Object noattr)))))
                              (Ssequence
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                      (Tstruct _Surface noattr)) _type
                                    tshort) (Etempvar _surfaceType tint))
                                (Ssequence
                                  (Sifthenelse (Etempvar _hasForce tshort)
                                    (Ssequence
                                      (Sset _t'8
                                        (Ederef
                                          (Etempvar _data (tptr (tptr tshort)))
                                          (tptr tshort)))
                                      (Ssequence
                                        (Sset _t'9
                                          (Ederef
                                            (Ebinop Oadd
                                              (Etempvar _t'8 (tptr tshort))
                                              (Econst_int (Int.repr 3) tint)
                                              (tptr tshort)) tshort))
                                        (Sassign
                                          (Efield
                                            (Ederef
                                              (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                              (Tstruct _Surface noattr))
                                            _force tshort)
                                          (Etempvar _t'9 tshort))))
                                    (Sassign
                                      (Efield
                                        (Ederef
                                          (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                          (Tstruct _Surface noattr)) _force
                                        tshort)
                                      (Econst_int (Int.repr 0) tint)))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'7
                                        (Efield
                                          (Ederef
                                            (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                            (Tstruct _Surface noattr)) _flags
                                          tschar))
                                      (Sassign
                                        (Efield
                                          (Ederef
                                            (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                            (Tstruct _Surface noattr)) _flags
                                          tschar)
                                        (Ebinop Oor (Etempvar _t'7 tschar)
                                          (Etempvar _flags tshort) tint)))
                                    (Ssequence
                                      (Sassign
                                        (Efield
                                          (Ederef
                                            (Etempvar _surface (tptr (Tstruct _Surface noattr)))
                                            (Tstruct _Surface noattr)) _room
                                          tschar)
                                        (Ecast (Etempvar _room tshort)
                                          tschar))
                                      (Scall None
                                        (Evar _add_surface (Tfunction
                                                             ((tptr (Tstruct _Surface noattr)) ::
                                                              tint :: nil)
                                                             tvoid
                                                             cc_default))
                                        ((Etempvar _surface (tptr (Tstruct _Surface noattr))) ::
                                         (Econst_int (Int.repr 1) tint) ::
                                         nil)))))))
                            Sskip)
                          (Sifthenelse (Etempvar _hasForce tshort)
                            (Ssequence
                              (Sset _t'6
                                (Ederef (Etempvar _data (tptr (tptr tshort)))
                                  (tptr tshort)))
                              (Sassign
                                (Ederef (Etempvar _data (tptr (tptr tshort)))
                                  (tptr tshort))
                                (Ebinop Oadd (Etempvar _t'6 (tptr tshort))
                                  (Econst_int (Int.repr 4) tint)
                                  (tptr tshort))))
                            (Ssequence
                              (Sset _t'5
                                (Ederef (Etempvar _data (tptr (tptr tshort)))
                                  (tptr tshort)))
                              (Sassign
                                (Ederef (Etempvar _data (tptr (tptr tshort)))
                                  (tptr tshort))
                                (Ebinop Oadd (Etempvar _t'5 (tptr tshort))
                                  (Econst_int (Int.repr 3) tint)
                                  (tptr tshort))))))))
                    (Sset _i
                      (Ebinop Oadd (Etempvar _i tint)
                        (Econst_int (Int.repr 1) tint) tint))))))))))))
|}.

Definition f_load_object_collision_model := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_filler, (tarray tuchar 4)) ::
              (_vertexData, (tarray tshort 600)) ::
              (_collisionData, (tptr tshort)) :: nil);
  fn_temps := ((_marioDist, tfloat) :: (_tangibleDist, tfloat) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tfloat) ::
               (_t'30, (tptr tvoid)) ::
               (_t'29, (tptr (Tstruct _Object noattr))) ::
               (_t'28, (tptr (Tstruct _Object noattr))) ::
               (_t'27, (tptr (Tstruct _Object noattr))) ::
               (_t'26, (tptr (Tstruct _Object noattr))) ::
               (_t'25, (tptr (Tstruct _Object noattr))) :: (_t'24, tfloat) ::
               (_t'23, (tptr (Tstruct _Object noattr))) :: (_t'22, tfloat) ::
               (_t'21, (tptr (Tstruct _Object noattr))) ::
               (_t'20, (tptr (Tstruct _Object noattr))) :: (_t'19, tfloat) ::
               (_t'18, (tptr (Tstruct _Object noattr))) :: (_t'17, tuint) ::
               (_t'16, tshort) :: (_t'15, (tptr (Tstruct _Object noattr))) ::
               (_t'14, (tptr tshort)) :: (_t'13, tshort) ::
               (_t'12, (tptr tshort)) :: (_t'11, tshort) ::
               (_t'10, (tptr (Tstruct _Object noattr))) ::
               (_t'9, (tptr (Tstruct _Object noattr))) :: (_t'8, tshort) ::
               (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tfloat) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'29 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'30
        (Efield
          (Ederef (Etempvar _t'29 (tptr (Tstruct _Object noattr)))
            (Tstruct _Object noattr)) _collisionData (tptr tvoid)))
      (Sassign (Evar _collisionData (tptr tshort))
        (Etempvar _t'30 (tptr tvoid)))))
  (Ssequence
    (Ssequence
      (Sset _t'28 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Sset _marioDist
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'28 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
              _asF32 (tarray tfloat 80)) (Econst_int (Int.repr 53) tint)
            (tptr tfloat)) tfloat)))
    (Ssequence
      (Ssequence
        (Sset _t'27 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Sset _tangibleDist
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'27 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
                _asF32 (tarray tfloat 80)) (Econst_int (Int.repr 67) tint)
              (tptr tfloat)) tfloat)))
      (Ssequence
        (Ssequence
          (Sset _t'23 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'24
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _t'23 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                  (Econst_int (Int.repr 53) tint) (tptr tfloat)) tfloat))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'24 tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 1184133120)) tfloat)
                           tint)
              (Ssequence
                (Ssequence
                  (Sset _t'25
                    (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sset _t'26
                      (Evar _gMarioObject (tptr (Tstruct _Object noattr))))
                    (Scall (Some _t'1)
                      (Evar _dist_between_objects (Tfunction
                                                    ((tptr (Tstruct _Object noattr)) ::
                                                     (tptr (Tstruct _Object noattr)) ::
                                                     nil) tfloat cc_default))
                      ((Etempvar _t'25 (tptr (Tstruct _Object noattr))) ::
                       (Etempvar _t'26 (tptr (Tstruct _Object noattr))) ::
                       nil))))
                (Sset _marioDist (Etempvar _t'1 tfloat)))
              Sskip)))
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
                        (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                    (Econst_int (Int.repr 67) tint) (tptr tfloat)) tfloat))
              (Sifthenelse (Ebinop Ogt (Etempvar _t'19 tfloat)
                             (Econst_single (Float32.of_bits (Int.repr 1165623296)) tfloat)
                             tint)
                (Ssequence
                  (Sset _t'20
                    (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
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
                                (Tunion __764 noattr)) _asF32
                              (tarray tfloat 80))
                            (Econst_int (Int.repr 67) tint) (tptr tfloat))
                          tfloat))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'20 (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _rawData
                                (Tunion __764 noattr)) _asF32
                              (tarray tfloat 80))
                            (Econst_int (Int.repr 69) tint) (tptr tfloat))
                          tfloat) (Etempvar _t'22 tfloat)))))
                Sskip)))
          (Ssequence
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'17 (Evar _gTimeStopState tuint))
                  (Sifthenelse (Eunop Onotbool
                                 (Ebinop Oand (Etempvar _t'17 tuint)
                                   (Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 6) tint) tint)
                                   tuint) tint)
                    (Sset _t'2
                      (Ecast
                        (Ebinop Olt (Etempvar _marioDist tfloat)
                          (Etempvar _tangibleDist tfloat) tint) tbool))
                    (Sset _t'2 (Econst_int (Int.repr 0) tint))))
                (Sifthenelse (Etempvar _t'2 tint)
                  (Ssequence
                    (Sset _t'15
                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sset _t'16
                        (Efield
                          (Ederef
                            (Etempvar _t'15 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _activeFlags tshort))
                      (Sset _t'3
                        (Ecast
                          (Eunop Onotbool
                            (Ebinop Oand (Etempvar _t'16 tshort)
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 3) tint) tint) tint)
                            tint) tbool))))
                  (Sset _t'3 (Econst_int (Int.repr 0) tint))))
              (Sifthenelse (Etempvar _t'3 tint)
                (Ssequence
                  (Ssequence
                    (Sset _t'14 (Evar _collisionData (tptr tshort)))
                    (Sassign (Evar _collisionData (tptr tshort))
                      (Ebinop Oadd (Etempvar _t'14 (tptr tshort))
                        (Econst_int (Int.repr 1) tint) (tptr tshort))))
                  (Ssequence
                    (Scall None
                      (Evar _transform_object_vertices (Tfunction
                                                         ((tptr (tptr tshort)) ::
                                                          (tptr tshort) ::
                                                          nil) tvoid
                                                         cc_default))
                      ((Eaddrof (Evar _collisionData (tptr tshort))
                         (tptr (tptr tshort))) ::
                       (Evar _vertexData (tarray tshort 600)) :: nil))
                    (Sloop
                      (Ssequence
                        (Ssequence
                          (Sset _t'12 (Evar _collisionData (tptr tshort)))
                          (Ssequence
                            (Sset _t'13
                              (Ederef (Etempvar _t'12 (tptr tshort)) tshort))
                            (Sifthenelse (Ebinop One (Etempvar _t'13 tshort)
                                           (Econst_int (Int.repr 65) tint)
                                           tint)
                              Sskip
                              Sbreak)))
                        (Scall None
                          (Evar _load_object_surfaces (Tfunction
                                                        ((tptr (tptr tshort)) ::
                                                         (tptr tshort) ::
                                                         nil) tvoid
                                                        cc_default))
                          ((Eaddrof (Evar _collisionData (tptr tshort))
                             (tptr (tptr tshort))) ::
                           (Evar _vertexData (tarray tshort 600)) :: nil)))
                      Sskip)))
                Sskip))
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
                          (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                      (Econst_int (Int.repr 69) tint) (tptr tfloat)) tfloat))
                (Sifthenelse (Ebinop Olt (Etempvar _marioDist tfloat)
                               (Etempvar _t'5 tfloat) tint)
                  (Ssequence
                    (Sset _t'9
                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sset _t'10
                        (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                      (Ssequence
                        (Sset _t'11
                          (Efield
                            (Efield
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _header
                                  (Tstruct _ObjectNode noattr)) _gfx
                                (Tstruct _GraphNodeObject noattr)) _node
                              (Tstruct _GraphNode noattr)) _flags tshort))
                        (Sassign
                          (Efield
                            (Efield
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _header
                                  (Tstruct _ObjectNode noattr)) _gfx
                                (Tstruct _GraphNodeObject noattr)) _node
                              (Tstruct _GraphNode noattr)) _flags tshort)
                          (Ebinop Oor (Etempvar _t'11 tshort)
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 0) tint) tint) tint)))))
                  (Ssequence
                    (Sset _t'6
                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sset _t'7
                        (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                      (Ssequence
                        (Sset _t'8
                          (Efield
                            (Efield
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _header
                                  (Tstruct _ObjectNode noattr)) _gfx
                                (Tstruct _GraphNodeObject noattr)) _node
                              (Tstruct _GraphNode noattr)) _flags tshort))
                        (Sassign
                          (Efield
                            (Efield
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _header
                                  (Tstruct _ObjectNode noattr)) _gfx
                                (Tstruct _GraphNodeObject noattr)) _node
                              (Tstruct _GraphNode noattr)) _flags tshort)
                          (Ebinop Oand (Etempvar _t'8 tshort)
                            (Eunop Onotint
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 0) tint) tint) tint)
                            tint))))))))))))))
|}.

Definition composites : list composite_definition :=
(Composite _Animation Struct
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
 Composite _SurfaceNode Struct
   (Member_plain _next (tptr (Tstruct _SurfaceNode noattr)) ::
    Member_plain _surface (tptr (Tstruct _Surface noattr)) :: nil)
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
 (_sqrtf,
   Gfun(External (EF_external "sqrtf"
                   (mksignature (AST.Xsingle :: nil) AST.Xsingle cc_default))
     (tfloat :: nil) tfloat cc_default)) ::
 (_reset_red_coins_collected,
   Gfun(External (EF_external "reset_red_coins_collected"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_segmented_to_virtual,
   Gfun(External (EF_external "segmented_to_virtual"
                   (mksignature (AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr tvoid) :: nil) (tptr tvoid) cc_default)) ::
 (_main_pool_alloc,
   Gfun(External (EF_external "main_pool_alloc"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xptr
                     cc_default)) (tuint :: tuint :: nil) (tptr tvoid)
     cc_default)) :: (_bhvDDDWarp, Gvar v_bhvDDDWarp) ::
 (_obj_apply_scale_to_matrix,
   Gfun(External (EF_external "obj_apply_scale_to_matrix"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xvoid cc_default))
     ((tptr (Tstruct _Object noattr)) :: (tptr (tarray tfloat 4)) ::
      (tptr (tarray tfloat 4)) :: nil) tvoid cc_default)) ::
 (_dist_between_objects,
   Gfun(External (EF_external "dist_between_objects"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xsingle
                     cc_default))
     ((tptr (Tstruct _Object noattr)) :: (tptr (Tstruct _Object noattr)) ::
      nil) tfloat cc_default)) ::
 (_obj_build_transform_from_pos_and_angle,
   Gfun(External (EF_external "obj_build_transform_from_pos_and_angle"
                   (mksignature
                     (AST.Xptr :: AST.Xint16signed :: AST.Xint16signed ::
                      nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _Object noattr)) :: tshort :: tshort :: nil) tvoid
     cc_default)) ::
 (_spawn_macro_objects,
   Gfun(External (EF_external "spawn_macro_objects"
                   (mksignature (AST.Xint16signed :: AST.Xptr :: nil)
                     AST.Xvoid cc_default)) (tshort :: (tptr tshort) :: nil)
     tvoid cc_default)) ::
 (_spawn_macro_objects_hardcoded,
   Gfun(External (EF_external "spawn_macro_objects_hardcoded"
                   (mksignature (AST.Xint16signed :: AST.Xptr :: nil)
                     AST.Xvoid cc_default)) (tshort :: (tptr tshort) :: nil)
     tvoid cc_default)) ::
 (_spawn_special_objects,
   Gfun(External (EF_external "spawn_special_objects"
                   (mksignature (AST.Xint16signed :: AST.Xptr :: nil)
                     AST.Xvoid cc_default))
     (tshort :: (tptr (tptr tshort)) :: nil) tvoid cc_default)) ::
 (_gTimeStopState, Gvar v_gTimeStopState) ::
 (_gMarioObject, Gvar v_gMarioObject) ::
 (_gCurrentObject, Gvar v_gCurrentObject) ::
 (_gSurfaceNodesAllocated, Gvar v_gSurfaceNodesAllocated) ::
 (_gSurfacesAllocated, Gvar v_gSurfacesAllocated) ::
 (_gNumStaticSurfaceNodes, Gvar v_gNumStaticSurfaceNodes) ::
 (_gNumStaticSurfaces, Gvar v_gNumStaticSurfaces) ::
 (_gEnvironmentRegions, Gvar v_gEnvironmentRegions) ::
 (_gEnvironmentLevels, Gvar v_gEnvironmentLevels) ::
 (_gCCMEnteredSlide, Gvar v_gCCMEnteredSlide) ::
 (_unused8038BE90, Gvar v_unused8038BE90) ::
 (_gStaticSurfacePartition, Gvar v_gStaticSurfacePartition) ::
 (_gDynamicSurfacePartition, Gvar v_gDynamicSurfacePartition) ::
 (_sSurfaceNodePool, Gvar v_sSurfaceNodePool) ::
 (_sSurfacePool, Gvar v_sSurfacePool) ::
 (_sSurfacePoolSize, Gvar v_sSurfacePoolSize) ::
 (_unused8038EEA8, Gvar v_unused8038EEA8) ::
 (_alloc_surface_node, Gfun(Internal f_alloc_surface_node)) ::
 (_alloc_surface, Gfun(Internal f_alloc_surface)) ::
 (_clear_spatial_partition, Gfun(Internal f_clear_spatial_partition)) ::
 (_clear_static_surfaces, Gfun(Internal f_clear_static_surfaces)) ::
 (_add_surface_to_cell, Gfun(Internal f_add_surface_to_cell)) ::
 (_min_3, Gfun(Internal f_min_3)) :: (_max_3, Gfun(Internal f_max_3)) ::
 (_lower_cell_index, Gfun(Internal f_lower_cell_index)) ::
 (_upper_cell_index, Gfun(Internal f_upper_cell_index)) ::
 (_add_surface, Gfun(Internal f_add_surface)) ::
 (_read_surface_data, Gfun(Internal f_read_surface_data)) ::
 (_surface_has_force, Gfun(Internal f_surface_has_force)) ::
 (_surf_has_no_cam_collision, Gfun(Internal f_surf_has_no_cam_collision)) ::
 (_load_static_surfaces, Gfun(Internal f_load_static_surfaces)) ::
 (_read_vertex_data, Gfun(Internal f_read_vertex_data)) ::
 (_load_environmental_regions, Gfun(Internal f_load_environmental_regions)) ::
 (_alloc_surface_pools, Gfun(Internal f_alloc_surface_pools)) ::
 (_load_area_terrain, Gfun(Internal f_load_area_terrain)) ::
 (_clear_dynamic_surfaces, Gfun(Internal f_clear_dynamic_surfaces)) ::
 (_transform_object_vertices, Gfun(Internal f_transform_object_vertices)) ::
 (_load_object_surfaces, Gfun(Internal f_load_object_surfaces)) ::
 (_load_object_collision_model, Gfun(Internal f_load_object_collision_model)) ::
 nil).

Definition public_idents : list ident :=
(_load_object_collision_model :: _load_object_surfaces ::
 _transform_object_vertices :: _clear_dynamic_surfaces ::
 _load_area_terrain :: _alloc_surface_pools :: _unused8038EEA8 ::
 _sSurfacePoolSize :: _sSurfacePool :: _sSurfaceNodePool ::
 _gDynamicSurfacePartition :: _gStaticSurfacePartition :: _unused8038BE90 ::
 _gCCMEnteredSlide :: _gEnvironmentLevels :: _gEnvironmentRegions ::
 _gNumStaticSurfaces :: _gNumStaticSurfaceNodes :: _gSurfacesAllocated ::
 _gSurfaceNodesAllocated :: _gCurrentObject :: _gMarioObject ::
 _gTimeStopState :: _spawn_special_objects ::
 _spawn_macro_objects_hardcoded :: _spawn_macro_objects ::
 _obj_build_transform_from_pos_and_angle :: _dist_between_objects ::
 _obj_apply_scale_to_matrix :: _bhvDDDWarp :: _main_pool_alloc ::
 _segmented_to_virtual :: _reset_red_coins_collected :: _sqrtf ::
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


