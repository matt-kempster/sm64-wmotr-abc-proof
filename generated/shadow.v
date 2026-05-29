(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Produced by: pipeline/clightgen.sh
   From source: vendor/sm64/src/game/shadow.c
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
  Definition source_file := "vendor/sm64/src/game/shadow.c".
  Definition normalized := true.
End Info.

Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _FloorGeometry : ident := $"FloorGeometry".
Definition _GraphNode : ident := $"GraphNode".
Definition _GraphNodeObject : ident := $"GraphNodeObject".
Definition _Object : ident := $"Object".
Definition _ObjectNode : ident := $"ObjectNode".
Definition _Shadow : ident := $"Shadow".
Definition _SpawnInfo : ident := $"SpawnInfo".
Definition _Surface : ident := $"Surface".
Definition _Waypoint : ident := $"Waypoint".
Definition __116 : ident := $"_116".
Definition __118 : ident := $"_118".
Definition __120 : ident := $"_120".
Definition __204 : ident := $"_204".
Definition __206 : ident := $"_206".
Definition __2146 : ident := $"_2146".
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
Definition __g__6 : ident := $"_g__6".
Definition __g__7 : ident := $"_g__7".
Definition _a : ident := $"a".
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _add_shadow_to_display_list : ident := $"add_shadow_to_display_list".
Definition _alloc_display_list : ident := $"alloc_display_list".
Definition _alpha : ident := $"alpha".
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
Definition _atan2_deg : ident := $"atan2_deg".
Definition _atan2s : ident := $"atan2s".
Definition _b : ident := $"b".
Definition _backLeftX : ident := $"backLeftX".
Definition _backLeftZ : ident := $"backLeftZ".
Definition _backRightX : ident := $"backRightX".
Definition _backRightZ : ident := $"backRightZ".
Definition _behavior : ident := $"behavior".
Definition _behaviorArg : ident := $"behaviorArg".
Definition _behaviorScript : ident := $"behaviorScript".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _calculate_vertex_xyz : ident := $"calculate_vertex_xyz".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _children : ident := $"children".
Definition _cn : ident := $"cn".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _correct_lava_shadow_height : ident := $"correct_lava_shadow_height".
Definition _correct_shadow_solidity_for_animations : ident := $"correct_shadow_solidity_for_animations".
Definition _cosf : ident := $"cosf".
Definition _create_shadow_below_xyz : ident := $"create_shadow_below_xyz".
Definition _create_shadow_circle_4_verts : ident := $"create_shadow_circle_4_verts".
Definition _create_shadow_circle_9_verts : ident := $"create_shadow_circle_9_verts".
Definition _create_shadow_circle_assuming_flat_ground : ident := $"create_shadow_circle_assuming_flat_ground".
Definition _create_shadow_hardcoded_rectangle : ident := $"create_shadow_hardcoded_rectangle".
Definition _create_shadow_player : ident := $"create_shadow_player".
Definition _create_shadow_rectangle : ident := $"create_shadow_rectangle".
Definition _create_shadow_square : ident := $"create_shadow_square".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _curr : ident := $"curr".
Definition _dim_shadow_with_distance : ident := $"dim_shadow_with_distance".
Definition _disable_shadow_with_distance : ident := $"disable_shadow_with_distance".
Definition _displayList : ident := $"displayList".
Definition _displayListHead : ident := $"displayListHead".
Definition _distBelowFloor : ident := $"distBelowFloor".
Definition _distFromFloor : ident := $"distFromFloor".
Definition _distFromShadow : ident := $"distFromShadow".
Definition _dl_shadow_4_verts : ident := $"dl_shadow_4_verts".
Definition _dl_shadow_9_verts : ident := $"dl_shadow_9_verts".
Definition _dl_shadow_circle : ident := $"dl_shadow_circle".
Definition _dl_shadow_end : ident := $"dl_shadow_end".
Definition _dl_shadow_square : ident := $"dl_shadow_square".
Definition _downwardAngle : ident := $"downwardAngle".
Definition _dummy : ident := $"dummy".
Definition _end : ident := $"end".
Definition _extrapolate_vertex_y_position : ident := $"extrapolate_vertex_y_position".
Definition _filler : ident := $"filler".
Definition _finalSolidity : ident := $"finalSolidity".
Definition _find_floor : ident := $"find_floor".
Definition _find_floor_height_and_data : ident := $"find_floor_height_and_data".
Definition _find_water_level : ident := $"find_water_level".
Definition _flag : ident := $"flag".
Definition _flags : ident := $"flags".
Definition _floorDownwardAngle : ident := $"floorDownwardAngle".
Definition _floorGeometry : ident := $"floorGeometry".
Definition _floorHeight : ident := $"floorHeight".
Definition _floorNormalX : ident := $"floorNormalX".
Definition _floorNormalY : ident := $"floorNormalY".
Definition _floorNormalZ : ident := $"floorNormalZ".
Definition _floorOriginOffset : ident := $"floorOriginOffset".
Definition _floorSteepness : ident := $"floorSteepness".
Definition _floorTilt : ident := $"floorTilt".
Definition _floor_local_tilt : ident := $"floor_local_tilt".
Definition _force : ident := $"force".
Definition _force_structure_alignment : ident := $"force_structure_alignment".
Definition _frontLeftX : ident := $"frontLeftX".
Definition _frontLeftZ : ident := $"frontLeftZ".
Definition _frontRightX : ident := $"frontRightX".
Definition _frontRightZ : ident := $"frontRightZ".
Definition _gCurGraphNodeObject : ident := $"gCurGraphNodeObject".
Definition _gCurrAreaIndex : ident := $"gCurrAreaIndex".
Definition _gCurrLevelNum : ident := $"gCurrLevelNum".
Definition _gEnvironmentRegions : ident := $"gEnvironmentRegions".
Definition _gFlyingCarpetState : ident := $"gFlyingCarpetState".
Definition _gLuigiObject : ident := $"gLuigiObject".
Definition _gMarioObject : ident := $"gMarioObject".
Definition _gMarioOnIceOrCarpet : ident := $"gMarioOnIceOrCarpet".
Definition _gShadowAboveWaterOrLava : ident := $"gShadowAboveWaterOrLava".
Definition _gSineTable : ident := $"gSineTable".
Definition _get_shadow_height_solidity : ident := $"get_shadow_height_solidity".
Definition _get_texture_coords_4_vertices : ident := $"get_texture_coords_4_vertices".
Definition _get_texture_coords_9_vertices : ident := $"get_texture_coords_9_vertices".
Definition _get_vertex_coords : ident := $"get_vertex_coords".
Definition _get_water_level_below_shadow : ident := $"get_water_level_below_shadow".
Definition _gfx : ident := $"gfx".
Definition _halfLength : ident := $"halfLength".
Definition _halfScale : ident := $"halfScale".
Definition _halfTiltedScale : ident := $"halfTiltedScale".
Definition _halfWidth : ident := $"halfWidth".
Definition _header : ident := $"header".
Definition _hitboxDownOffset : ident := $"hitboxDownOffset".
Definition _hitboxHeight : ident := $"hitboxHeight".
Definition _hitboxRadius : ident := $"hitboxRadius".
Definition _hurtboxHeight : ident := $"hurtboxHeight".
Definition _hurtboxRadius : ident := $"hurtboxRadius".
Definition _i : ident := $"i".
Definition _idx : ident := $"idx".
Definition _index : ident := $"index".
Definition _init_shadow : ident := $"init_shadow".
Definition _initial : ident := $"initial".
Definition _initialSolidity : ident := $"initialSolidity".
Definition _isLuigi : ident := $"isLuigi".
Definition _length : ident := $"length".
Definition _linearly_interpolate_solidity_negative : ident := $"linearly_interpolate_solidity_negative".
Definition _linearly_interpolate_solidity_positive : ident := $"linearly_interpolate_solidity_positive".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _main : ident := $"main".
Definition _make_shadow_vertex : ident := $"make_shadow_vertex".
Definition _make_shadow_vertex_at_xyz : ident := $"make_shadow_vertex_at_xyz".
Definition _make_vertex : ident := $"make_vertex".
Definition _model : ident := $"model".
Definition _n : ident := $"n".
Definition _newScale : ident := $"newScale".
Definition _newX : ident := $"newX".
Definition _newZ : ident := $"newZ".
Definition _next : ident := $"next".
Definition _node : ident := $"node".
Definition _normal : ident := $"normal".
Definition _normalX : ident := $"normalX".
Definition _normalY : ident := $"normalY".
Definition _normalZ : ident := $"normalZ".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _ob : ident := $"ob".
Definition _obj : ident := $"obj".
Definition _object : ident := $"object".
Definition _oldX : ident := $"oldX".
Definition _oldZ : ident := $"oldZ".
Definition _originOffset : ident := $"originOffset".
Definition _overwriteSolidity : ident := $"overwriteSolidity".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _parentX : ident := $"parentX".
Definition _parentY : ident := $"parentY".
Definition _parentZ : ident := $"parentZ".
Definition _pfloor : ident := $"pfloor".
Definition _platform : ident := $"platform".
Definition _player : ident := $"player".
Definition _pos : ident := $"pos".
Definition _prev : ident := $"prev".
Definition _prevObj : ident := $"prevObj".
Definition _radius : ident := $"radius".
Definition _rawData : ident := $"rawData".
Definition _rectangles : ident := $"rectangles".
Definition _relX : ident := $"relX".
Definition _relY : ident := $"relY".
Definition _relZ : ident := $"relZ".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _ret : ident := $"ret".
Definition _room : ident := $"room".
Definition _rotate_rectangle : ident := $"rotate_rectangle".
Definition _round_float : ident := $"round_float".
Definition _s : ident := $"s".
Definition _sMarioOnFlyingCarpet : ident := $"sMarioOnFlyingCarpet".
Definition _sSurfaceTypeBelowShadow : ident := $"sSurfaceTypeBelowShadow".
Definition _scale : ident := $"scale".
Definition _scaleWithDistance : ident := $"scaleWithDistance".
Definition _scale_shadow_with_distance : ident := $"scale_shadow_with_distance".
Definition _shadow : ident := $"shadow".
Definition _shadowHeight : ident := $"shadowHeight".
Definition _shadowRadius : ident := $"shadowRadius".
Definition _shadowScale : ident := $"shadowScale".
Definition _shadowShape : ident := $"shadowShape".
Definition _shadowSolidity : ident := $"shadowSolidity".
Definition _shadowType : ident := $"shadowType".
Definition _shadowVertexType : ident := $"shadowVertexType".
Definition _sharedChild : ident := $"sharedChild".
Definition _sinf : ident := $"sinf".
Definition _solidity : ident := $"solidity".
Definition _sqrtf : ident := $"sqrtf".
Definition _start : ident := $"start".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
Definition _tc : ident := $"tc".
Definition _textureX : ident := $"textureX".
Definition _textureY : ident := $"textureY".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _tiltedScale : ident := $"tiltedScale".
Definition _transform : ident := $"transform".
Definition _type : ident := $"type".
Definition _unk4C : ident := $"unk4C".
Definition _unused1 : ident := $"unused1".
Definition _unused2 : ident := $"unused2".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _upperY : ident := $"upperY".
Definition _v : ident := $"v".
Definition _values : ident := $"values".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _vertexNum : ident := $"vertexNum".
Definition _vertices : ident := $"vertices".
Definition _verts : ident := $"verts".
Definition _vtxX : ident := $"vtxX".
Definition _vtxY : ident := $"vtxY".
Definition _vtxZ : ident := $"vtxZ".
Definition _w0 : ident := $"w0".
Definition _w1 : ident := $"w1".
Definition _waterLevel : ident := $"waterLevel".
Definition _words : ident := $"words".
Definition _x : ident := $"x".
Definition _xCoord : ident := $"xCoord".
Definition _xCoordUnit : ident := $"xCoordUnit".
Definition _xPos : ident := $"xPos".
Definition _xPosVtx : ident := $"xPosVtx".
Definition _y : ident := $"y".
Definition _yPos : ident := $"yPos".
Definition _yPosVtx : ident := $"yPosVtx".
Definition _z : ident := $"z".
Definition _zCoord : ident := $"zCoord".
Definition _zCoordUnit : ident := $"zCoordUnit".
Definition _zPos : ident := $"zPos".
Definition _zPosVtx : ident := $"zPosVtx".
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
Definition _t'4 : ident := 131%positive.
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v_gSineTable := {|
  gvar_info := (tarray tfloat 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gFlyingCarpetState := {|
  gvar_info := tschar;
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

Definition v_gCurrLevelNum := {|
  gvar_info := tshort;
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

Definition v_gLuigiObject := {|
  gvar_info := (tptr (Tstruct _Object noattr));
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

Definition v_gCurGraphNodeObject := {|
  gvar_info := (tptr (Tstruct _GraphNodeObject noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_dl_shadow_circle := {|
  gvar_info := (tarray (Tunion __206 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_dl_shadow_square := {|
  gvar_info := (tarray (Tunion __206 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_dl_shadow_9_verts := {|
  gvar_info := (tarray (Tunion __206 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_dl_shadow_4_verts := {|
  gvar_info := (tarray (Tunion __206 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_dl_shadow_end := {|
  gvar_info := (tarray (Tunion __206 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_rectangles := {|
  gvar_info := (tarray (Tstruct __2146 noattr) 2);
  gvar_init := (Init_float32 (Float32.of_bits (Int.repr 1135869952)) ::
                Init_float32 (Float32.of_bits (Int.repr 1130758144)) ::
                Init_int8 (Int.repr 1) :: Init_space 3 ::
                Init_float32 (Float32.of_bits (Int.repr 1128792064)) ::
                Init_float32 (Float32.of_bits (Int.repr 1127481344)) ::
                Init_int8 (Int.repr 1) :: Init_space 3 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gShadowAboveWaterOrLava := {|
  gvar_info := tschar;
  gvar_init := (Init_space 1 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMarioOnIceOrCarpet := {|
  gvar_info := tschar;
  gvar_init := (Init_space 1 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sMarioOnFlyingCarpet := {|
  gvar_info := tschar;
  gvar_init := (Init_space 1 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSurfaceTypeBelowShadow := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_rotate_rectangle := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_newZ, (tptr tfloat)) :: (_newX, (tptr tfloat)) ::
                (_oldZ, tfloat) :: (_oldX, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_obj, (tptr (Tstruct _Object noattr))) ::
               (_t'9, (tptr (Tstruct _GraphNodeObject noattr))) ::
               (_t'8, tfloat) :: (_t'7, tint) :: (_t'6, tfloat) ::
               (_t'5, tint) :: (_t'4, tfloat) :: (_t'3, tint) ::
               (_t'2, tfloat) :: (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9
      (Evar _gCurGraphNodeObject (tptr (Tstruct _GraphNodeObject noattr))))
    (Sset _obj
      (Ecast (Etempvar _t'9 (tptr (Tstruct _GraphNodeObject noattr)))
        (tptr (Tstruct _Object noattr)))))
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80))
            (Ebinop Oadd (Econst_int (Int.repr 18) tint)
              (Econst_int (Int.repr 1) tint) tint) (tptr tint)) tint))
      (Ssequence
        (Sset _t'6
          (Ederef
            (Ebinop Oadd
              (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                (Econst_int (Int.repr 1024) tint) (tptr tfloat))
              (Ebinop Oshr (Ecast (Etempvar _t'5 tint) tushort)
                (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
        (Ssequence
          (Sset _t'7
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asS32 (tarray tint 80))
                (Ebinop Oadd (Econst_int (Int.repr 18) tint)
                  (Econst_int (Int.repr 1) tint) tint) (tptr tint)) tint))
          (Ssequence
            (Sset _t'8
              (Ederef
                (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                  (Ebinop Oshr (Ecast (Etempvar _t'7 tint) tushort)
                    (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                tfloat))
            (Sassign (Ederef (Etempvar _newZ (tptr tfloat)) tfloat)
              (Ebinop Osub
                (Ebinop Omul (Etempvar _oldZ tfloat) (Etempvar _t'6 tfloat)
                  tfloat)
                (Ebinop Omul (Etempvar _oldX tfloat) (Etempvar _t'8 tfloat)
                  tfloat) tfloat))))))
    (Ssequence
      (Sset _t'1
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80))
            (Ebinop Oadd (Econst_int (Int.repr 18) tint)
              (Econst_int (Int.repr 1) tint) tint) (tptr tint)) tint))
      (Ssequence
        (Sset _t'2
          (Ederef
            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
              (Ebinop Oshr (Ecast (Etempvar _t'1 tint) tushort)
                (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
        (Ssequence
          (Sset _t'3
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asS32 (tarray tint 80))
                (Ebinop Oadd (Econst_int (Int.repr 18) tint)
                  (Econst_int (Int.repr 1) tint) tint) (tptr tint)) tint))
          (Ssequence
            (Sset _t'4
              (Ederef
                (Ebinop Oadd
                  (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                    (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                  (Ebinop Oshr (Ecast (Etempvar _t'3 tint) tushort)
                    (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                tfloat))
            (Sassign (Ederef (Etempvar _newX (tptr tfloat)) tfloat)
              (Ebinop Oadd
                (Ebinop Omul (Etempvar _oldZ tfloat) (Etempvar _t'2 tfloat)
                  tfloat)
                (Ebinop Omul (Etempvar _oldX tfloat) (Etempvar _t'4 tfloat)
                  tfloat) tfloat))))))))
|}.

Definition f_atan2_deg := {|
  fn_return := tfloat;
  fn_callconv := cc_default;
  fn_params := ((_a, tfloat) :: (_b, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Scall (Some _t'1)
    (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil) tshort cc_default))
    ((Etempvar _a tfloat) :: (Etempvar _b tfloat) :: nil))
  (Sreturn (Some (Ebinop Omul
                   (Ebinop Odiv (Ecast (Etempvar _t'1 tshort) tfloat)
                     (Econst_float (Float.of_bits (Int64.repr 4679239875398991872)) tdouble)
                     tdouble)
                   (Econst_float (Float.of_bits (Int64.repr 4645040803167600640)) tdouble)
                   tdouble))))
|}.

Definition f_scale_shadow_with_distance := {|
  fn_return := tfloat;
  fn_callconv := cc_default;
  fn_params := ((_initial, tfloat) :: (_distFromFloor, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_newScale, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Ole (Etempvar _distFromFloor tfloat)
                 (Econst_float (Float.of_bits (Int64.repr 0)) tdouble) tint)
    (Sset _newScale (Etempvar _initial tfloat))
    (Sifthenelse (Ebinop Oge (Etempvar _distFromFloor tfloat)
                   (Econst_float (Float.of_bits (Int64.repr 4648488871632306176)) tdouble)
                   tint)
      (Sset _newScale
        (Ecast
          (Ebinop Omul (Etempvar _initial tfloat)
            (Econst_float (Float.of_bits (Int64.repr 4602678819172646912)) tdouble)
            tdouble) tfloat))
      (Sset _newScale
        (Ecast
          (Ebinop Omul (Etempvar _initial tfloat)
            (Ebinop Osub
              (Econst_float (Float.of_bits (Int64.repr 4607182418800017408)) tdouble)
              (Ebinop Odiv
                (Ebinop Omul
                  (Econst_float (Float.of_bits (Int64.repr 4602678819172646912)) tdouble)
                  (Etempvar _distFromFloor tfloat) tdouble)
                (Econst_float (Float.of_bits (Int64.repr 4648488871632306176)) tdouble)
                tdouble) tdouble) tdouble) tfloat))))
  (Sreturn (Some (Etempvar _newScale tfloat))))
|}.

Definition f_disable_shadow_with_distance := {|
  fn_return := tfloat;
  fn_callconv := cc_default;
  fn_params := ((_shadowScale, tfloat) :: (_distFromFloor, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Sifthenelse (Ebinop Oge (Etempvar _distFromFloor tfloat)
               (Econst_float (Float.of_bits (Int64.repr 4648488871632306176)) tdouble)
               tint)
  (Sreturn (Some (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)))
  (Sreturn (Some (Etempvar _shadowScale tfloat))))
|}.

Definition f_dim_shadow_with_distance := {|
  fn_return := tuchar;
  fn_callconv := cc_default;
  fn_params := ((_solidity, tuchar) :: (_distFromFloor, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_ret, tfloat) :: nil);
  fn_body :=
(Sifthenelse (Ebinop Olt (Etempvar _solidity tuchar)
               (Econst_int (Int.repr 121) tint) tint)
  (Sreturn (Some (Etempvar _solidity tuchar)))
  (Sifthenelse (Ebinop Ole (Etempvar _distFromFloor tfloat)
                 (Econst_float (Float.of_bits (Int64.repr 0)) tdouble) tint)
    (Sreturn (Some (Etempvar _solidity tuchar)))
    (Sifthenelse (Ebinop Oge (Etempvar _distFromFloor tfloat)
                   (Econst_float (Float.of_bits (Int64.repr 4648488871632306176)) tdouble)
                   tint)
      (Sreturn (Some (Econst_int (Int.repr 120) tint)))
      (Ssequence
        (Sset _ret
          (Ecast
            (Ebinop Oadd
              (Ebinop Odiv
                (Ebinop Omul
                  (Ebinop Osub (Econst_int (Int.repr 120) tint)
                    (Etempvar _solidity tuchar) tint)
                  (Etempvar _distFromFloor tfloat) tfloat)
                (Econst_float (Float.of_bits (Int64.repr 4648488871632306176)) tdouble)
                tdouble) (Ecast (Etempvar _solidity tuchar) tfloat) tdouble)
            tfloat))
        (Sreturn (Some (Etempvar _ret tfloat)))))))
|}.

Definition f_get_water_level_below_shadow := {|
  fn_return := tfloat;
  fn_callconv := cc_default;
  fn_params := ((_s, (tptr (Tstruct _Shadow noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_waterLevel, tfloat) :: (_t'2, tint) :: (_t'1, tfloat) ::
               (_t'6, tfloat) :: (_t'5, tfloat) :: (_t'4, tfloat) ::
               (_t'3, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Efield
          (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
            (Tstruct _Shadow noattr)) _parentX tfloat))
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
              (Tstruct _Shadow noattr)) _parentZ tfloat))
        (Scall (Some _t'1)
          (Evar _find_water_level (Tfunction (tfloat :: tfloat :: nil) tfloat
                                    cc_default))
          ((Etempvar _t'5 tfloat) :: (Etempvar _t'6 tfloat) :: nil))))
    (Sset _waterLevel (Etempvar _t'1 tfloat)))
  (Ssequence
    (Sifthenelse (Ebinop Olt (Etempvar _waterLevel tfloat)
                   (Ebinop Oadd
                     (Eunop Oneg (Econst_int (Int.repr 11000) tint) tint)
                     (Econst_float (Float.of_bits (Int64.repr 4652007308841189376)) tdouble)
                     tdouble) tint)
      (Sreturn (Some (Econst_int (Int.repr 0) tint)))
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                (Tstruct _Shadow noattr)) _parentY tfloat))
          (Sifthenelse (Ebinop Oge (Etempvar _t'3 tfloat)
                         (Etempvar _waterLevel tfloat) tint)
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                    (Tstruct _Shadow noattr)) _floorHeight tfloat))
              (Sset _t'2
                (Ecast
                  (Ebinop Ole (Etempvar _t'4 tfloat)
                    (Etempvar _waterLevel tfloat) tint) tbool)))
            (Sset _t'2 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'2 tint)
          (Ssequence
            (Sassign (Evar _gShadowAboveWaterOrLava tschar)
              (Econst_int (Int.repr 1) tint))
            (Sreturn (Some (Etempvar _waterLevel tfloat))))
          Sskip)))
    (Sreturn (Some (Etempvar _waterLevel tfloat)))))
|}.

Definition f_init_shadow := {|
  fn_return := tschar;
  fn_callconv := cc_default;
  fn_params := ((_s, (tptr (Tstruct _Shadow noattr))) :: (_xPos, tfloat) ::
                (_yPos, tfloat) :: (_zPos, tfloat) ::
                (_shadowScale, tshort) :: (_overwriteSolidity, tuchar) ::
                nil);
  fn_vars := ((_floorGeometry, (tptr (Tstruct _FloorGeometry noattr))) ::
              nil);
  fn_temps := ((_waterLevel, tfloat) :: (_floorSteepness, tfloat) ::
               (_t'8, tfloat) :: (_t'7, tfloat) :: (_t'6, tfloat) ::
               (_t'5, tfloat) :: (_t'4, tuchar) :: (_t'3, tint) ::
               (_t'2, tfloat) :: (_t'1, tfloat) :: (_t'33, tfloat) ::
               (_t'32, tfloat) :: (_t'31, tfloat) ::
               (_t'30, (tptr tshort)) :: (_t'29, tfloat) ::
               (_t'28, (tptr (Tstruct _FloorGeometry noattr))) ::
               (_t'27, tfloat) :: (_t'26, tfloat) ::
               (_t'25, (tptr (Tstruct _FloorGeometry noattr))) ::
               (_t'24, tfloat) ::
               (_t'23, (tptr (Tstruct _FloorGeometry noattr))) ::
               (_t'22, tfloat) ::
               (_t'21, (tptr (Tstruct _FloorGeometry noattr))) ::
               (_t'20, tfloat) ::
               (_t'19, (tptr (Tstruct _FloorGeometry noattr))) ::
               (_t'18, tschar) :: (_t'17, tfloat) :: (_t'16, tfloat) ::
               (_t'15, tfloat) :: (_t'14, tfloat) :: (_t'13, tfloat) ::
               (_t'12, tfloat) :: (_t'11, tfloat) :: (_t'10, tfloat) ::
               (_t'9, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sassign
    (Efield
      (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
        (Tstruct _Shadow noattr)) _parentX tfloat) (Etempvar _xPos tfloat))
  (Ssequence
    (Sassign
      (Efield
        (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
          (Tstruct _Shadow noattr)) _parentY tfloat) (Etempvar _yPos tfloat))
    (Ssequence
      (Sassign
        (Efield
          (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
            (Tstruct _Shadow noattr)) _parentZ tfloat)
        (Etempvar _zPos tfloat))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'31
              (Efield
                (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                  (Tstruct _Shadow noattr)) _parentX tfloat))
            (Ssequence
              (Sset _t'32
                (Efield
                  (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                    (Tstruct _Shadow noattr)) _parentY tfloat))
              (Ssequence
                (Sset _t'33
                  (Efield
                    (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                      (Tstruct _Shadow noattr)) _parentZ tfloat))
                (Scall (Some _t'1)
                  (Evar _find_floor_height_and_data (Tfunction
                                                      (tfloat :: tfloat ::
                                                       tfloat ::
                                                       (tptr (tptr (Tstruct _FloorGeometry noattr))) ::
                                                       nil) tfloat
                                                      cc_default))
                  ((Etempvar _t'31 tfloat) :: (Etempvar _t'32 tfloat) ::
                   (Etempvar _t'33 tfloat) ::
                   (Eaddrof
                     (Evar _floorGeometry (tptr (Tstruct _FloorGeometry noattr)))
                     (tptr (tptr (Tstruct _FloorGeometry noattr)))) :: nil)))))
          (Sassign
            (Efield
              (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                (Tstruct _Shadow noattr)) _floorHeight tfloat)
            (Etempvar _t'1 tfloat)))
        (Ssequence
          (Ssequence
            (Sset _t'30 (Evar _gEnvironmentRegions (tptr tshort)))
            (Sifthenelse (Ebinop One (Etempvar _t'30 (tptr tshort))
                           (Ecast (Econst_int (Int.repr 0) tint)
                             (tptr tvoid)) tint)
              (Ssequence
                (Scall (Some _t'2)
                  (Evar _get_water_level_below_shadow (Tfunction
                                                        ((tptr (Tstruct _Shadow noattr)) ::
                                                         nil) tfloat
                                                        cc_default))
                  ((Etempvar _s (tptr (Tstruct _Shadow noattr))) :: nil))
                (Sset _waterLevel (Etempvar _t'2 tfloat)))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'18 (Evar _gShadowAboveWaterOrLava tschar))
              (Sifthenelse (Etempvar _t'18 tschar)
                (Ssequence
                  (Sassign
                    (Efield
                      (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                        (Tstruct _Shadow noattr)) _floorHeight tfloat)
                    (Etempvar _waterLevel tfloat))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                          (Tstruct _Shadow noattr)) _floorNormalX tfloat)
                      (Econst_int (Int.repr 0) tint))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                            (Tstruct _Shadow noattr)) _floorNormalY tfloat)
                        (Econst_float (Float.of_bits (Int64.repr 4607182418800017408)) tdouble))
                      (Ssequence
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                              (Tstruct _Shadow noattr)) _floorNormalZ tfloat)
                          (Econst_int (Int.repr 0) tint))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                              (Tstruct _Shadow noattr)) _floorOriginOffset
                            tfloat)
                          (Eunop Oneg (Etempvar _waterLevel tfloat) tfloat))))))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'27
                        (Efield
                          (Ederef
                            (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                            (Tstruct _Shadow noattr)) _floorHeight tfloat))
                      (Sifthenelse (Ebinop Olt (Etempvar _t'27 tfloat)
                                     (Ebinop Oadd
                                       (Eunop Oneg
                                         (Econst_int (Int.repr 11000) tint)
                                         tint)
                                       (Econst_float (Float.of_bits (Int64.repr 4652007308841189376)) tdouble)
                                       tdouble) tint)
                        (Sset _t'3 (Econst_int (Int.repr 1) tint))
                        (Ssequence
                          (Sset _t'28
                            (Evar _floorGeometry (tptr (Tstruct _FloorGeometry noattr))))
                          (Ssequence
                            (Sset _t'29
                              (Efield
                                (Ederef
                                  (Etempvar _t'28 (tptr (Tstruct _FloorGeometry noattr)))
                                  (Tstruct _FloorGeometry noattr)) _normalY
                                tfloat))
                            (Sset _t'3
                              (Ecast
                                (Ebinop Ole (Etempvar _t'29 tfloat)
                                  (Econst_float (Float.of_bits (Int64.repr 0)) tdouble)
                                  tint) tbool))))))
                    (Sifthenelse (Etempvar _t'3 tint)
                      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
                      Sskip))
                  (Ssequence
                    (Ssequence
                      (Sset _t'25
                        (Evar _floorGeometry (tptr (Tstruct _FloorGeometry noattr))))
                      (Ssequence
                        (Sset _t'26
                          (Efield
                            (Ederef
                              (Etempvar _t'25 (tptr (Tstruct _FloorGeometry noattr)))
                              (Tstruct _FloorGeometry noattr)) _normalX
                            tfloat))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                              (Tstruct _Shadow noattr)) _floorNormalX tfloat)
                          (Etempvar _t'26 tfloat))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'23
                          (Evar _floorGeometry (tptr (Tstruct _FloorGeometry noattr))))
                        (Ssequence
                          (Sset _t'24
                            (Efield
                              (Ederef
                                (Etempvar _t'23 (tptr (Tstruct _FloorGeometry noattr)))
                                (Tstruct _FloorGeometry noattr)) _normalY
                              tfloat))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                                (Tstruct _Shadow noattr)) _floorNormalY
                              tfloat) (Etempvar _t'24 tfloat))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'21
                            (Evar _floorGeometry (tptr (Tstruct _FloorGeometry noattr))))
                          (Ssequence
                            (Sset _t'22
                              (Efield
                                (Ederef
                                  (Etempvar _t'21 (tptr (Tstruct _FloorGeometry noattr)))
                                  (Tstruct _FloorGeometry noattr)) _normalZ
                                tfloat))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                                  (Tstruct _Shadow noattr)) _floorNormalZ
                                tfloat) (Etempvar _t'22 tfloat))))
                        (Ssequence
                          (Sset _t'19
                            (Evar _floorGeometry (tptr (Tstruct _FloorGeometry noattr))))
                          (Ssequence
                            (Sset _t'20
                              (Efield
                                (Ederef
                                  (Etempvar _t'19 (tptr (Tstruct _FloorGeometry noattr)))
                                  (Tstruct _FloorGeometry noattr))
                                _originOffset tfloat))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                                  (Tstruct _Shadow noattr))
                                _floorOriginOffset tfloat)
                              (Etempvar _t'20 tfloat))))))))))
            (Ssequence
              (Sifthenelse (Etempvar _overwriteSolidity tuchar)
                (Ssequence
                  (Ssequence
                    (Sset _t'17
                      (Efield
                        (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                          (Tstruct _Shadow noattr)) _floorHeight tfloat))
                    (Scall (Some _t'4)
                      (Evar _dim_shadow_with_distance (Tfunction
                                                        (tuchar :: tfloat ::
                                                         nil) tuchar
                                                        cc_default))
                      ((Etempvar _overwriteSolidity tuchar) ::
                       (Ebinop Osub (Etempvar _yPos tfloat)
                         (Etempvar _t'17 tfloat) tfloat) :: nil)))
                  (Sassign
                    (Efield
                      (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                        (Tstruct _Shadow noattr)) _solidity tuchar)
                    (Etempvar _t'4 tuchar)))
                Sskip)
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'16
                      (Efield
                        (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                          (Tstruct _Shadow noattr)) _floorHeight tfloat))
                    (Scall (Some _t'5)
                      (Evar _scale_shadow_with_distance (Tfunction
                                                          (tfloat ::
                                                           tfloat :: nil)
                                                          tfloat cc_default))
                      ((Etempvar _shadowScale tshort) ::
                       (Ebinop Osub (Etempvar _yPos tfloat)
                         (Etempvar _t'16 tfloat) tfloat) :: nil)))
                  (Sassign
                    (Efield
                      (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                        (Tstruct _Shadow noattr)) _shadowScale tfloat)
                    (Etempvar _t'5 tfloat)))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'14
                        (Efield
                          (Ederef
                            (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                            (Tstruct _Shadow noattr)) _floorNormalZ tfloat))
                      (Ssequence
                        (Sset _t'15
                          (Efield
                            (Ederef
                              (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                              (Tstruct _Shadow noattr)) _floorNormalX tfloat))
                        (Scall (Some _t'6)
                          (Evar _atan2_deg (Tfunction
                                             (tfloat :: tfloat :: nil) tfloat
                                             cc_default))
                          ((Etempvar _t'14 tfloat) ::
                           (Etempvar _t'15 tfloat) :: nil))))
                    (Sassign
                      (Efield
                        (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                          (Tstruct _Shadow noattr)) _floorDownwardAngle
                        tfloat) (Etempvar _t'6 tfloat)))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'10
                          (Efield
                            (Ederef
                              (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                              (Tstruct _Shadow noattr)) _floorNormalX tfloat))
                        (Ssequence
                          (Sset _t'11
                            (Efield
                              (Ederef
                                (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                                (Tstruct _Shadow noattr)) _floorNormalX
                              tfloat))
                          (Ssequence
                            (Sset _t'12
                              (Efield
                                (Ederef
                                  (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                                  (Tstruct _Shadow noattr)) _floorNormalZ
                                tfloat))
                            (Ssequence
                              (Sset _t'13
                                (Efield
                                  (Ederef
                                    (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                                    (Tstruct _Shadow noattr)) _floorNormalZ
                                  tfloat))
                              (Scall (Some _t'7)
                                (Evar _sqrtf (Tfunction (tfloat :: nil)
                                               tfloat cc_default))
                                ((Ebinop Oadd
                                   (Ebinop Omul (Etempvar _t'10 tfloat)
                                     (Etempvar _t'11 tfloat) tfloat)
                                   (Ebinop Omul (Etempvar _t'12 tfloat)
                                     (Etempvar _t'13 tfloat) tfloat) tfloat) ::
                                 nil))))))
                      (Sset _floorSteepness (Etempvar _t'7 tfloat)))
                    (Ssequence
                      (Sifthenelse (Ebinop Oeq
                                     (Etempvar _floorSteepness tfloat)
                                     (Econst_float (Float.of_bits (Int64.repr 0)) tdouble)
                                     tint)
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                              (Tstruct _Shadow noattr)) _floorTilt tfloat)
                          (Econst_int (Int.repr 0) tint))
                        (Ssequence
                          (Ssequence
                            (Sset _t'9
                              (Efield
                                (Ederef
                                  (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                                  (Tstruct _Shadow noattr)) _floorNormalY
                                tfloat))
                            (Scall (Some _t'8)
                              (Evar _atan2_deg (Tfunction
                                                 (tfloat :: tfloat :: nil)
                                                 tfloat cc_default))
                              ((Etempvar _floorSteepness tfloat) ::
                               (Etempvar _t'9 tfloat) :: nil)))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                                (Tstruct _Shadow noattr)) _floorTilt tfloat)
                            (Ebinop Osub
                              (Econst_float (Float.of_bits (Int64.repr 4636033603912859648)) tdouble)
                              (Etempvar _t'8 tfloat) tdouble))))
                      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))))
|}.

Definition f_get_texture_coords_9_vertices := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_vertexNum, tschar) :: (_textureX, (tptr tshort)) ::
                (_textureY, (tptr tshort)) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sassign (Ederef (Etempvar _textureX (tptr tshort)) tshort)
    (Ebinop Osub
      (Ebinop Omul
        (Ebinop Omod (Etempvar _vertexNum tschar)
          (Econst_int (Int.repr 3) tint) tint)
        (Econst_int (Int.repr 15) tint) tint) (Econst_int (Int.repr 15) tint)
      tint))
  (Sassign (Ederef (Etempvar _textureY (tptr tshort)) tshort)
    (Ebinop Osub
      (Ebinop Omul
        (Ebinop Odiv (Etempvar _vertexNum tschar)
          (Econst_int (Int.repr 3) tint) tint)
        (Econst_int (Int.repr 15) tint) tint) (Econst_int (Int.repr 15) tint)
      tint)))
|}.

Definition f_get_texture_coords_4_vertices := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_vertexNum, tschar) :: (_textureX, (tptr tshort)) ::
                (_textureY, (tptr tshort)) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sassign (Ederef (Etempvar _textureX (tptr tshort)) tshort)
    (Ebinop Osub
      (Ebinop Omul
        (Ebinop Omul
          (Ebinop Omod (Etempvar _vertexNum tschar)
            (Econst_int (Int.repr 2) tint) tint)
          (Econst_int (Int.repr 2) tint) tint)
        (Econst_int (Int.repr 15) tint) tint) (Econst_int (Int.repr 15) tint)
      tint))
  (Sassign (Ederef (Etempvar _textureY (tptr tshort)) tshort)
    (Ebinop Osub
      (Ebinop Omul
        (Ebinop Omul
          (Ebinop Odiv (Etempvar _vertexNum tschar)
            (Econst_int (Int.repr 2) tint) tint)
          (Econst_int (Int.repr 2) tint) tint)
        (Econst_int (Int.repr 15) tint) tint) (Econst_int (Int.repr 15) tint)
      tint)))
|}.

Definition f_make_shadow_vertex_at_xyz := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_vertices, (tptr (Tunion __120 noattr))) ::
                (_index, tschar) :: (_relX, tfloat) :: (_relY, tfloat) ::
                (_relZ, tfloat) :: (_alpha, tuchar) ::
                (_shadowVertexType, tschar) :: nil);
  fn_vars := ((_textureX, tshort) :: (_textureY, tshort) :: nil);
  fn_temps := ((_vtxX, tshort) :: (_vtxY, tshort) :: (_vtxZ, tshort) ::
               (_t'3, tshort) :: (_t'2, tshort) :: (_t'1, tshort) ::
               (_t'6, tschar) :: (_t'5, tshort) :: (_t'4, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _round_float (Tfunction (tfloat :: nil) tshort cc_default))
      ((Etempvar _relX tfloat) :: nil))
    (Sset _vtxX (Ecast (Etempvar _t'1 tshort) tshort)))
  (Ssequence
    (Ssequence
      (Scall (Some _t'2)
        (Evar _round_float (Tfunction (tfloat :: nil) tshort cc_default))
        ((Etempvar _relY tfloat) :: nil))
      (Sset _vtxY (Ecast (Etempvar _t'2 tshort) tshort)))
    (Ssequence
      (Ssequence
        (Scall (Some _t'3)
          (Evar _round_float (Tfunction (tfloat :: nil) tshort cc_default))
          ((Etempvar _relZ tfloat) :: nil))
        (Sset _vtxZ (Ecast (Etempvar _t'3 tshort) tshort)))
      (Ssequence
        (Sswitch (Etempvar _shadowVertexType tschar)
          (LScons (Some 0)
            (Ssequence
              (Scall None
                (Evar _get_texture_coords_9_vertices (Tfunction
                                                       (tschar ::
                                                        (tptr tshort) ::
                                                        (tptr tshort) :: nil)
                                                       tvoid cc_default))
                ((Etempvar _index tschar) ::
                 (Eaddrof (Evar _textureX tshort) (tptr tshort)) ::
                 (Eaddrof (Evar _textureY tshort) (tptr tshort)) :: nil))
              Sbreak)
            (LScons (Some 1)
              (Ssequence
                (Scall None
                  (Evar _get_texture_coords_4_vertices (Tfunction
                                                         (tschar ::
                                                          (tptr tshort) ::
                                                          (tptr tshort) ::
                                                          nil) tvoid
                                                         cc_default))
                  ((Etempvar _index tschar) ::
                   (Eaddrof (Evar _textureX tshort) (tptr tshort)) ::
                   (Eaddrof (Evar _textureY tshort) (tptr tshort)) :: nil))
                Sbreak)
              LSnil)))
        (Ssequence
          (Ssequence
            (Sset _t'6 (Evar _sMarioOnFlyingCarpet tschar))
            (Sifthenelse (Etempvar _t'6 tschar)
              (Ssequence
                (Sset _vtxX
                  (Ecast
                    (Ebinop Oadd (Etempvar _vtxX tshort)
                      (Econst_int (Int.repr 5) tint) tint) tshort))
                (Ssequence
                  (Sset _vtxY
                    (Ecast
                      (Ebinop Oadd (Etempvar _vtxY tshort)
                        (Econst_int (Int.repr 5) tint) tint) tshort))
                  (Sset _vtxZ
                    (Ecast
                      (Ebinop Oadd (Etempvar _vtxZ tshort)
                        (Econst_int (Int.repr 5) tint) tint) tshort))))
              Sskip))
          (Ssequence
            (Sset _t'4 (Evar _textureX tshort))
            (Ssequence
              (Sset _t'5 (Evar _textureY tshort))
              (Scall None
                (Evar _make_vertex (Tfunction
                                     ((tptr (Tunion __120 noattr)) :: tint ::
                                      tshort :: tshort :: tshort :: tshort ::
                                      tshort :: tuchar :: tuchar :: tuchar ::
                                      tuchar :: nil) tvoid cc_default))
                ((Etempvar _vertices (tptr (Tunion __120 noattr))) ::
                 (Etempvar _index tschar) :: (Etempvar _vtxX tshort) ::
                 (Etempvar _vtxY tshort) :: (Etempvar _vtxZ tshort) ::
                 (Ebinop Oshl (Etempvar _t'4 tshort)
                   (Econst_int (Int.repr 5) tint) tint) ::
                 (Ebinop Oshl (Etempvar _t'5 tshort)
                   (Econst_int (Int.repr 5) tint) tint) ::
                 (Econst_int (Int.repr 255) tint) ::
                 (Econst_int (Int.repr 255) tint) ::
                 (Econst_int (Int.repr 255) tint) ::
                 (Etempvar _alpha tuchar) :: nil)))))))))
|}.

Definition f_extrapolate_vertex_y_position := {|
  fn_return := tfloat;
  fn_callconv := cc_default;
  fn_params := ((_s, (Tstruct _Shadow noattr)) :: (_vtxX, tfloat) ::
                (_vtxZ, tfloat) :: nil);
  fn_vars := ((_s, (Tstruct _Shadow noattr)) :: nil);
  fn_temps := ((_t'4, tfloat) :: (_t'3, tfloat) :: (_t'2, tfloat) ::
               (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _s (Tstruct _Shadow noattr))
    (Etempvar _s (Tstruct _Shadow noattr)))
  (Ssequence
    (Sset _t'1
      (Efield (Evar _s (Tstruct _Shadow noattr)) _floorNormalX tfloat))
    (Ssequence
      (Sset _t'2
        (Efield (Evar _s (Tstruct _Shadow noattr)) _floorNormalZ tfloat))
      (Ssequence
        (Sset _t'3
          (Efield (Evar _s (Tstruct _Shadow noattr)) _floorOriginOffset
            tfloat))
        (Ssequence
          (Sset _t'4
            (Efield (Evar _s (Tstruct _Shadow noattr)) _floorNormalY tfloat))
          (Sreturn (Some (Ebinop Odiv
                           (Eunop Oneg
                             (Ebinop Oadd
                               (Ebinop Oadd
                                 (Ebinop Omul (Etempvar _t'1 tfloat)
                                   (Etempvar _vtxX tfloat) tfloat)
                                 (Ebinop Omul (Etempvar _t'2 tfloat)
                                   (Etempvar _vtxZ tfloat) tfloat) tfloat)
                               (Etempvar _t'3 tfloat) tfloat) tfloat)
                           (Etempvar _t'4 tfloat) tfloat))))))))
|}.

Definition f_get_vertex_coords := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_index, tschar) :: (_shadowVertexType, tschar) ::
                (_xCoord, (tptr tschar)) :: (_zCoord, (tptr tschar)) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tschar) :: (_t'1, tschar) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Ederef (Etempvar _xCoord (tptr tschar)) tschar)
    (Ebinop Osub
      (Ebinop Omod (Etempvar _index tschar)
        (Ebinop Osub (Econst_int (Int.repr 3) tint)
          (Etempvar _shadowVertexType tschar) tint) tint)
      (Econst_int (Int.repr 1) tint) tint))
  (Ssequence
    (Sassign (Ederef (Etempvar _zCoord (tptr tschar)) tschar)
      (Ebinop Osub
        (Ebinop Odiv (Etempvar _index tschar)
          (Ebinop Osub (Econst_int (Int.repr 3) tint)
            (Etempvar _shadowVertexType tschar) tint) tint)
        (Econst_int (Int.repr 1) tint) tint))
    (Sifthenelse (Ebinop Oeq (Etempvar _shadowVertexType tschar)
                   (Econst_int (Int.repr 1) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'2 (Ederef (Etempvar _xCoord (tptr tschar)) tschar))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tschar)
                         (Econst_int (Int.repr 0) tint) tint)
            (Sassign (Ederef (Etempvar _xCoord (tptr tschar)) tschar)
              (Econst_int (Int.repr 1) tint))
            Sskip))
        (Ssequence
          (Sset _t'1 (Ederef (Etempvar _zCoord (tptr tschar)) tschar))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tschar)
                         (Econst_int (Int.repr 0) tint) tint)
            (Sassign (Ederef (Etempvar _zCoord (tptr tschar)) tschar)
              (Econst_int (Int.repr 1) tint))
            Sskip)))
      Sskip)))
|}.

Definition f_calculate_vertex_xyz := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_index, tschar) :: (_s, (Tstruct _Shadow noattr)) ::
                (_xPosVtx, (tptr tfloat)) :: (_yPosVtx, (tptr tfloat)) ::
                (_zPosVtx, (tptr tfloat)) :: (_shadowVertexType, tschar) ::
                nil);
  fn_vars := ((_s, (Tstruct _Shadow noattr)) :: (_xCoordUnit, tschar) ::
              (_zCoordUnit, tschar) ::
              (_dummy, (tptr (Tstruct _FloorGeometry noattr))) :: nil);
  fn_temps := ((_tiltedScale, tfloat) :: (_downwardAngle, tfloat) ::
               (_halfScale, tfloat) :: (_halfTiltedScale, tfloat) ::
               (_t'7, tfloat) :: (_t'6, tfloat) :: (_t'5, tfloat) ::
               (_t'4, tfloat) :: (_t'3, tfloat) :: (_t'2, tfloat) ::
               (_t'1, tfloat) :: (_t'22, tfloat) :: (_t'21, tfloat) ::
               (_t'20, tfloat) :: (_t'19, tfloat) :: (_t'18, tschar) ::
               (_t'17, tschar) :: (_t'16, tfloat) :: (_t'15, tfloat) ::
               (_t'14, tfloat) :: (_t'13, tfloat) :: (_t'12, tfloat) ::
               (_t'11, tfloat) :: (_t'10, tfloat) :: (_t'9, tfloat) ::
               (_t'8, tschar) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _s (Tstruct _Shadow noattr))
    (Etempvar _s (Tstruct _Shadow noattr)))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'22
          (Efield (Evar _s (Tstruct _Shadow noattr)) _floorTilt tfloat))
        (Scall (Some _t'1)
          (Evar _cosf (Tfunction (tfloat :: nil) tfloat cc_default))
          ((Ebinop Odiv
             (Ebinop Omul (Etempvar _t'22 tfloat)
               (Econst_float (Float.of_bits (Int64.repr 4614256656552045848)) tdouble)
               tdouble)
             (Econst_float (Float.of_bits (Int64.repr 4640537203540230144)) tdouble)
             tdouble) :: nil)))
      (Ssequence
        (Sset _t'21
          (Efield (Evar _s (Tstruct _Shadow noattr)) _shadowScale tfloat))
        (Sset _tiltedScale
          (Ebinop Omul (Etempvar _t'1 tfloat) (Etempvar _t'21 tfloat) tfloat))))
    (Ssequence
      (Ssequence
        (Sset _t'20
          (Efield (Evar _s (Tstruct _Shadow noattr)) _floorDownwardAngle
            tfloat))
        (Sset _downwardAngle
          (Ecast
            (Ebinop Odiv
              (Ebinop Omul (Etempvar _t'20 tfloat)
                (Econst_float (Float.of_bits (Int64.repr 4614256656552045848)) tdouble)
                tdouble)
              (Econst_float (Float.of_bits (Int64.repr 4640537203540230144)) tdouble)
              tdouble) tfloat)))
      (Ssequence
        (Scall None
          (Evar _get_vertex_coords (Tfunction
                                     (tschar :: tschar :: (tptr tschar) ::
                                      (tptr tschar) :: nil) tvoid cc_default))
          ((Etempvar _index tschar) :: (Etempvar _shadowVertexType tschar) ::
           (Eaddrof (Evar _xCoordUnit tschar) (tptr tschar)) ::
           (Eaddrof (Evar _zCoordUnit tschar) (tptr tschar)) :: nil))
        (Ssequence
          (Ssequence
            (Sset _t'18 (Evar _xCoordUnit tschar))
            (Ssequence
              (Sset _t'19
                (Efield (Evar _s (Tstruct _Shadow noattr)) _shadowScale
                  tfloat))
              (Sset _halfScale
                (Ecast
                  (Ebinop Odiv
                    (Ebinop Omul (Etempvar _t'18 tschar)
                      (Etempvar _t'19 tfloat) tfloat)
                    (Econst_float (Float.of_bits (Int64.repr 4611686018427387904)) tdouble)
                    tdouble) tfloat))))
          (Ssequence
            (Ssequence
              (Sset _t'17 (Evar _zCoordUnit tschar))
              (Sset _halfTiltedScale
                (Ecast
                  (Ebinop Odiv
                    (Ebinop Omul (Etempvar _t'17 tschar)
                      (Etempvar _tiltedScale tfloat) tfloat)
                    (Econst_float (Float.of_bits (Int64.repr 4611686018427387904)) tdouble)
                    tdouble) tfloat)))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Scall (Some _t'2)
                    (Evar _sinf (Tfunction (tfloat :: nil) tfloat cc_default))
                    ((Etempvar _downwardAngle tfloat) :: nil))
                  (Scall (Some _t'3)
                    (Evar _cosf (Tfunction (tfloat :: nil) tfloat cc_default))
                    ((Etempvar _downwardAngle tfloat) :: nil)))
                (Ssequence
                  (Sset _t'16
                    (Efield (Evar _s (Tstruct _Shadow noattr)) _parentX
                      tfloat))
                  (Sassign (Ederef (Etempvar _xPosVtx (tptr tfloat)) tfloat)
                    (Ebinop Oadd
                      (Ebinop Oadd
                        (Ebinop Omul (Etempvar _halfTiltedScale tfloat)
                          (Etempvar _t'2 tfloat) tfloat)
                        (Ebinop Omul (Etempvar _halfScale tfloat)
                          (Etempvar _t'3 tfloat) tfloat) tfloat)
                      (Etempvar _t'16 tfloat) tfloat))))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'4)
                      (Evar _cosf (Tfunction (tfloat :: nil) tfloat
                                    cc_default))
                      ((Etempvar _downwardAngle tfloat) :: nil))
                    (Scall (Some _t'5)
                      (Evar _sinf (Tfunction (tfloat :: nil) tfloat
                                    cc_default))
                      ((Etempvar _downwardAngle tfloat) :: nil)))
                  (Ssequence
                    (Sset _t'15
                      (Efield (Evar _s (Tstruct _Shadow noattr)) _parentZ
                        tfloat))
                    (Sassign
                      (Ederef (Etempvar _zPosVtx (tptr tfloat)) tfloat)
                      (Ebinop Oadd
                        (Ebinop Osub
                          (Ebinop Omul (Etempvar _halfTiltedScale tfloat)
                            (Etempvar _t'4 tfloat) tfloat)
                          (Ebinop Omul (Etempvar _halfScale tfloat)
                            (Etempvar _t'5 tfloat) tfloat) tfloat)
                        (Etempvar _t'15 tfloat) tfloat))))
                (Ssequence
                  (Sset _t'8 (Evar _gShadowAboveWaterOrLava tschar))
                  (Sifthenelse (Etempvar _t'8 tschar)
                    (Ssequence
                      (Sset _t'14
                        (Efield (Evar _s (Tstruct _Shadow noattr))
                          _floorHeight tfloat))
                      (Sassign
                        (Ederef (Etempvar _yPosVtx (tptr tfloat)) tfloat)
                        (Etempvar _t'14 tfloat)))
                    (Sswitch (Etempvar _shadowVertexType tschar)
                      (LScons (Some 0)
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Sset _t'11
                                (Ederef (Etempvar _xPosVtx (tptr tfloat))
                                  tfloat))
                              (Ssequence
                                (Sset _t'12
                                  (Efield (Evar _s (Tstruct _Shadow noattr))
                                    _parentY tfloat))
                                (Ssequence
                                  (Sset _t'13
                                    (Ederef (Etempvar _zPosVtx (tptr tfloat))
                                      tfloat))
                                  (Scall (Some _t'6)
                                    (Evar _find_floor_height_and_data 
                                    (Tfunction
                                      (tfloat :: tfloat :: tfloat ::
                                       (tptr (tptr (Tstruct _FloorGeometry noattr))) ::
                                       nil) tfloat cc_default))
                                    ((Etempvar _t'11 tfloat) ::
                                     (Etempvar _t'12 tfloat) ::
                                     (Etempvar _t'13 tfloat) ::
                                     (Eaddrof
                                       (Evar _dummy (tptr (Tstruct _FloorGeometry noattr)))
                                       (tptr (tptr (Tstruct _FloorGeometry noattr)))) ::
                                     nil)))))
                            (Sassign
                              (Ederef (Etempvar _yPosVtx (tptr tfloat))
                                tfloat) (Etempvar _t'6 tfloat)))
                          Sbreak)
                        (LScons (Some 1)
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Sset _t'9
                                  (Ederef (Etempvar _xPosVtx (tptr tfloat))
                                    tfloat))
                                (Ssequence
                                  (Sset _t'10
                                    (Ederef (Etempvar _zPosVtx (tptr tfloat))
                                      tfloat))
                                  (Scall (Some _t'7)
                                    (Evar _extrapolate_vertex_y_position 
                                    (Tfunction
                                      ((Tstruct _Shadow noattr) :: tfloat ::
                                       tfloat :: nil) tfloat cc_default))
                                    ((Evar _s (Tstruct _Shadow noattr)) ::
                                     (Etempvar _t'9 tfloat) ::
                                     (Etempvar _t'10 tfloat) :: nil))))
                              (Sassign
                                (Ederef (Etempvar _yPosVtx (tptr tfloat))
                                  tfloat) (Etempvar _t'7 tfloat)))
                            Sbreak)
                          LSnil)))))))))))))
|}.

Definition f_floor_local_tilt := {|
  fn_return := tshort;
  fn_callconv := cc_default;
  fn_params := ((_s, (Tstruct _Shadow noattr)) :: (_vtxX, tfloat) ::
                (_vtxY, tfloat) :: (_vtxZ, tfloat) :: nil);
  fn_vars := ((_s, (Tstruct _Shadow noattr)) :: nil);
  fn_temps := ((_relX, tfloat) :: (_relY, tfloat) :: (_relZ, tfloat) ::
               (_ret, tfloat) :: (_t'6, tfloat) :: (_t'5, tfloat) ::
               (_t'4, tfloat) :: (_t'3, tfloat) :: (_t'2, tfloat) ::
               (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _s (Tstruct _Shadow noattr))
    (Etempvar _s (Tstruct _Shadow noattr)))
  (Ssequence
    (Ssequence
      (Sset _t'6 (Efield (Evar _s (Tstruct _Shadow noattr)) _parentX tfloat))
      (Sset _relX
        (Ebinop Osub (Etempvar _vtxX tfloat) (Etempvar _t'6 tfloat) tfloat)))
    (Ssequence
      (Ssequence
        (Sset _t'5
          (Efield (Evar _s (Tstruct _Shadow noattr)) _floorHeight tfloat))
        (Sset _relY
          (Ebinop Osub (Etempvar _vtxY tfloat) (Etempvar _t'5 tfloat) tfloat)))
      (Ssequence
        (Ssequence
          (Sset _t'4
            (Efield (Evar _s (Tstruct _Shadow noattr)) _parentZ tfloat))
          (Sset _relZ
            (Ebinop Osub (Etempvar _vtxZ tfloat) (Etempvar _t'4 tfloat)
              tfloat)))
        (Ssequence
          (Ssequence
            (Sset _t'1
              (Efield (Evar _s (Tstruct _Shadow noattr)) _floorNormalX
                tfloat))
            (Ssequence
              (Sset _t'2
                (Efield (Evar _s (Tstruct _Shadow noattr)) _floorNormalY
                  tfloat))
              (Ssequence
                (Sset _t'3
                  (Efield (Evar _s (Tstruct _Shadow noattr)) _floorNormalZ
                    tfloat))
                (Sset _ret
                  (Ebinop Oadd
                    (Ebinop Oadd
                      (Ebinop Omul (Etempvar _relX tfloat)
                        (Etempvar _t'1 tfloat) tfloat)
                      (Ebinop Omul (Etempvar _relY tfloat)
                        (Etempvar _t'2 tfloat) tfloat) tfloat)
                    (Ebinop Omul (Etempvar _relZ tfloat)
                      (Etempvar _t'3 tfloat) tfloat) tfloat)))))
          (Sreturn (Some (Etempvar _ret tfloat))))))))
|}.

Definition f_make_shadow_vertex := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_vertices, (tptr (Tunion __120 noattr))) ::
                (_index, tschar) :: (_s, (Tstruct _Shadow noattr)) ::
                (_shadowVertexType, tschar) :: nil);
  fn_vars := ((_s, (Tstruct _Shadow noattr)) :: (_xPosVtx, tfloat) ::
              (_yPosVtx, tfloat) :: (_zPosVtx, tfloat) :: nil);
  fn_temps := ((_relX, tfloat) :: (_relY, tfloat) :: (_relZ, tfloat) ::
               (_solidity, tuchar) :: (_t'4, tshort) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tfloat) :: (_t'18, tuchar) ::
               (_t'17, tschar) :: (_t'16, tschar) :: (_t'15, tfloat) ::
               (_t'14, tfloat) :: (_t'13, tfloat) :: (_t'12, tfloat) ::
               (_t'11, tfloat) :: (_t'10, tfloat) :: (_t'9, tfloat) ::
               (_t'8, tfloat) :: (_t'7, tfloat) :: (_t'6, tfloat) ::
               (_t'5, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _s (Tstruct _Shadow noattr))
    (Etempvar _s (Tstruct _Shadow noattr)))
  (Ssequence
    (Ssequence
      (Sset _t'18
        (Efield (Evar _s (Tstruct _Shadow noattr)) _solidity tuchar))
      (Sset _solidity (Ecast (Etempvar _t'18 tuchar) tuchar)))
    (Ssequence
      (Ssequence
        (Sset _t'17 (Evar _gShadowAboveWaterOrLava tschar))
        (Sifthenelse (Etempvar _t'17 tschar)
          (Sset _solidity (Ecast (Econst_int (Int.repr 200) tint) tuchar))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _calculate_vertex_xyz (Tfunction
                                        (tschar ::
                                         (Tstruct _Shadow noattr) ::
                                         (tptr tfloat) :: (tptr tfloat) ::
                                         (tptr tfloat) :: tschar :: nil)
                                        tvoid cc_default))
          ((Etempvar _index tschar) :: (Evar _s (Tstruct _Shadow noattr)) ::
           (Eaddrof (Evar _xPosVtx tfloat) (tptr tfloat)) ::
           (Eaddrof (Evar _yPosVtx tfloat) (tptr tfloat)) ::
           (Eaddrof (Evar _zPosVtx tfloat) (tptr tfloat)) ::
           (Etempvar _shadowVertexType tschar) :: nil))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sifthenelse (Ebinop Oeq (Etempvar _shadowVertexType tschar)
                             (Econst_int (Int.repr 0) tint) tint)
                (Ssequence
                  (Sset _t'16 (Evar _gShadowAboveWaterOrLava tschar))
                  (Sset _t'2
                    (Ecast (Eunop Onotbool (Etempvar _t'16 tschar) tint)
                      tbool)))
                (Sset _t'2 (Econst_int (Int.repr 0) tint)))
              (Sifthenelse (Etempvar _t'2 tint)
                (Ssequence
                  (Ssequence
                    (Sset _t'13 (Evar _xPosVtx tfloat))
                    (Ssequence
                      (Sset _t'14 (Evar _yPosVtx tfloat))
                      (Ssequence
                        (Sset _t'15 (Evar _zPosVtx tfloat))
                        (Scall (Some _t'4)
                          (Evar _floor_local_tilt (Tfunction
                                                    ((Tstruct _Shadow noattr) ::
                                                     tfloat :: tfloat ::
                                                     tfloat :: nil) tshort
                                                    cc_default))
                          ((Evar _s (Tstruct _Shadow noattr)) ::
                           (Etempvar _t'13 tfloat) ::
                           (Etempvar _t'14 tfloat) ::
                           (Etempvar _t'15 tfloat) :: nil)))))
                  (Sset _t'3
                    (Ecast
                      (Ebinop One (Etempvar _t'4 tshort)
                        (Econst_int (Int.repr 0) tint) tint) tbool)))
                (Sset _t'3 (Econst_int (Int.repr 0) tint))))
            (Sifthenelse (Etempvar _t'3 tint)
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'11 (Evar _xPosVtx tfloat))
                    (Ssequence
                      (Sset _t'12 (Evar _zPosVtx tfloat))
                      (Scall (Some _t'1)
                        (Evar _extrapolate_vertex_y_position (Tfunction
                                                               ((Tstruct _Shadow noattr) ::
                                                                tfloat ::
                                                                tfloat ::
                                                                nil) tfloat
                                                               cc_default))
                        ((Evar _s (Tstruct _Shadow noattr)) ::
                         (Etempvar _t'11 tfloat) ::
                         (Etempvar _t'12 tfloat) :: nil))))
                  (Sassign (Evar _yPosVtx tfloat) (Etempvar _t'1 tfloat)))
                (Sset _solidity
                  (Ecast (Econst_int (Int.repr 0) tint) tuchar)))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'9 (Evar _xPosVtx tfloat))
              (Ssequence
                (Sset _t'10
                  (Efield (Evar _s (Tstruct _Shadow noattr)) _parentX tfloat))
                (Sset _relX
                  (Ebinop Osub (Etempvar _t'9 tfloat) (Etempvar _t'10 tfloat)
                    tfloat))))
            (Ssequence
              (Ssequence
                (Sset _t'7 (Evar _yPosVtx tfloat))
                (Ssequence
                  (Sset _t'8
                    (Efield (Evar _s (Tstruct _Shadow noattr)) _parentY
                      tfloat))
                  (Sset _relY
                    (Ebinop Osub (Etempvar _t'7 tfloat)
                      (Etempvar _t'8 tfloat) tfloat))))
              (Ssequence
                (Ssequence
                  (Sset _t'5 (Evar _zPosVtx tfloat))
                  (Ssequence
                    (Sset _t'6
                      (Efield (Evar _s (Tstruct _Shadow noattr)) _parentZ
                        tfloat))
                    (Sset _relZ
                      (Ebinop Osub (Etempvar _t'5 tfloat)
                        (Etempvar _t'6 tfloat) tfloat))))
                (Scall None
                  (Evar _make_shadow_vertex_at_xyz (Tfunction
                                                     ((tptr (Tunion __120 noattr)) ::
                                                      tschar :: tfloat ::
                                                      tfloat :: tfloat ::
                                                      tuchar :: tschar ::
                                                      nil) tvoid cc_default))
                  ((Etempvar _vertices (tptr (Tunion __120 noattr))) ::
                   (Etempvar _index tschar) :: (Etempvar _relX tfloat) ::
                   (Etempvar _relY tfloat) :: (Etempvar _relZ tfloat) ::
                   (Etempvar _solidity tuchar) ::
                   (Etempvar _shadowVertexType tschar) :: nil))))))))))
|}.

Definition f_add_shadow_to_display_list := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_displayListHead, (tptr (Tunion __206 noattr))) ::
                (_verts, (tptr (Tunion __120 noattr))) ::
                (_shadowVertexType, tschar) :: (_shadowShape, tschar) :: nil);
  fn_vars := nil;
  fn_temps := ((__g, (tptr (Tunion __206 noattr))) ::
               (__g__1, (tptr (Tunion __206 noattr))) ::
               (__g__2, (tptr (Tunion __206 noattr))) ::
               (__g__3, (tptr (Tunion __206 noattr))) ::
               (__g__4, (tptr (Tunion __206 noattr))) ::
               (__g__5, (tptr (Tunion __206 noattr))) ::
               (__g__6, (tptr (Tunion __206 noattr))) ::
               (__g__7, (tptr (Tunion __206 noattr))) ::
               (_t'7, (tptr (Tunion __206 noattr))) ::
               (_t'6, (tptr (Tunion __206 noattr))) ::
               (_t'5, (tptr (Tunion __206 noattr))) ::
               (_t'4, (tptr (Tunion __206 noattr))) ::
               (_t'3, (tptr (Tunion __206 noattr))) ::
               (_t'2, (tptr (Tunion __206 noattr))) ::
               (_t'1, (tptr (Tunion __206 noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sswitch (Etempvar _shadowShape tschar)
    (LScons (Some 10)
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'1
              (Etempvar _displayListHead (tptr (Tunion __206 noattr))))
            (Sset _displayListHead
              (Ebinop Oadd (Etempvar _t'1 (tptr (Tunion __206 noattr)))
                (Econst_int (Int.repr 1) tint) (tptr (Tunion __206 noattr)))))
          (Sset __g
            (Ecast (Etempvar _t'1 (tptr (Tunion __206 noattr)))
              (tptr (Tunion __206 noattr)))))
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g (tptr (Tunion __206 noattr)))
                  (Tunion __206 noattr)) _words (Tstruct __204 noattr)) _w0
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
          (Ssequence
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g (tptr (Tunion __206 noattr)))
                    (Tunion __206 noattr)) _words (Tstruct __204 noattr)) _w1
                tuint)
              (Ecast
                (Evar _dl_shadow_circle (tarray (Tunion __206 noattr) 0))
                tuint))
            Sbreak)))
      (LScons (Some 20)
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'2
                (Etempvar _displayListHead (tptr (Tunion __206 noattr))))
              (Sset _displayListHead
                (Ebinop Oadd (Etempvar _t'2 (tptr (Tunion __206 noattr)))
                  (Econst_int (Int.repr 1) tint)
                  (tptr (Tunion __206 noattr)))))
            (Sset __g__1
              (Ecast (Etempvar _t'2 (tptr (Tunion __206 noattr)))
                (tptr (Tunion __206 noattr)))))
          (Ssequence
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__1 (tptr (Tunion __206 noattr)))
                    (Tunion __206 noattr)) _words (Tstruct __204 noattr)) _w0
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
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__1 (tptr (Tunion __206 noattr)))
                      (Tunion __206 noattr)) _words (Tstruct __204 noattr))
                  _w1 tuint)
                (Ecast
                  (Evar _dl_shadow_square (tarray (Tunion __206 noattr) 0))
                  tuint))
              Sbreak)))
        LSnil)))
  (Ssequence
    (Sswitch (Etempvar _shadowVertexType tschar)
      (LScons (Some 0)
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'3
                (Etempvar _displayListHead (tptr (Tunion __206 noattr))))
              (Sset _displayListHead
                (Ebinop Oadd (Etempvar _t'3 (tptr (Tunion __206 noattr)))
                  (Econst_int (Int.repr 1) tint)
                  (tptr (Tunion __206 noattr)))))
            (Sset __g__2
              (Ecast (Etempvar _t'3 (tptr (Tunion __206 noattr)))
                (tptr (Tunion __206 noattr)))))
          (Ssequence
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__2 (tptr (Tunion __206 noattr)))
                    (Tunion __206 noattr)) _words (Tstruct __204 noattr)) _w0
                tuint)
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
                        (Ecast (Econst_int (Int.repr 9) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 8) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 12) tint) tuint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast
                        (Ebinop Oadd (Econst_int (Int.repr 0) tint)
                          (Econst_int (Int.repr 9) tint) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 7) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 1) tint) tuint) tuint) tuint))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__2 (tptr (Tunion __206 noattr)))
                      (Tunion __206 noattr)) _words (Tstruct __204 noattr))
                  _w1 tuint)
                (Ecast (Etempvar _verts (tptr (Tunion __120 noattr))) tuint))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'4
                      (Etempvar _displayListHead (tptr (Tunion __206 noattr))))
                    (Sset _displayListHead
                      (Ebinop Oadd
                        (Etempvar _t'4 (tptr (Tunion __206 noattr)))
                        (Econst_int (Int.repr 1) tint)
                        (tptr (Tunion __206 noattr)))))
                  (Sset __g__3
                    (Ecast (Etempvar _t'4 (tptr (Tunion __206 noattr)))
                      (tptr (Tunion __206 noattr)))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__3 (tptr (Tunion __206 noattr)))
                          (Tunion __206 noattr)) _words
                        (Tstruct __204 noattr)) _w0 tuint)
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
                  (Ssequence
                    (Sassign
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar __g__3 (tptr (Tunion __206 noattr)))
                            (Tunion __206 noattr)) _words
                          (Tstruct __204 noattr)) _w1 tuint)
                      (Ecast
                        (Evar _dl_shadow_9_verts (tarray (Tunion __206 noattr) 0))
                        tuint))
                    Sbreak))))))
        (LScons (Some 1)
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Etempvar _displayListHead (tptr (Tunion __206 noattr))))
                (Sset _displayListHead
                  (Ebinop Oadd (Etempvar _t'5 (tptr (Tunion __206 noattr)))
                    (Econst_int (Int.repr 1) tint)
                    (tptr (Tunion __206 noattr)))))
              (Sset __g__4
                (Ecast (Etempvar _t'5 (tptr (Tunion __206 noattr)))
                  (tptr (Tunion __206 noattr)))))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__4 (tptr (Tunion __206 noattr)))
                      (Tunion __206 noattr)) _words (Tstruct __204 noattr))
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
                          (Ecast (Econst_int (Int.repr 4) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 12) tint) tuint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast
                          (Ebinop Oadd (Econst_int (Int.repr 0) tint)
                            (Econst_int (Int.repr 4) tint) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 7) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 1) tint) tuint) tuint) tuint))
              (Ssequence
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__4 (tptr (Tunion __206 noattr)))
                        (Tunion __206 noattr)) _words (Tstruct __204 noattr))
                    _w1 tuint)
                  (Ecast (Etempvar _verts (tptr (Tunion __120 noattr)))
                    tuint))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'6
                        (Etempvar _displayListHead (tptr (Tunion __206 noattr))))
                      (Sset _displayListHead
                        (Ebinop Oadd
                          (Etempvar _t'6 (tptr (Tunion __206 noattr)))
                          (Econst_int (Int.repr 1) tint)
                          (tptr (Tunion __206 noattr)))))
                    (Sset __g__5
                      (Ecast (Etempvar _t'6 (tptr (Tunion __206 noattr)))
                        (tptr (Tunion __206 noattr)))))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar __g__5 (tptr (Tunion __206 noattr)))
                            (Tunion __206 noattr)) _words
                          (Tstruct __204 noattr)) _w0 tuint)
                      (Ebinop Oor
                        (Ebinop Oor
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast (Econst_int (Int.repr 222) tint)
                                  tuint)
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
                            (Econst_int (Int.repr 0) tint) tuint) tuint)
                        tuint))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar __g__5 (tptr (Tunion __206 noattr)))
                              (Tunion __206 noattr)) _words
                            (Tstruct __204 noattr)) _w1 tuint)
                        (Ecast
                          (Evar _dl_shadow_4_verts (tarray (Tunion __206 noattr) 0))
                          tuint))
                      Sbreak))))))
          LSnil)))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'7
              (Etempvar _displayListHead (tptr (Tunion __206 noattr))))
            (Sset _displayListHead
              (Ebinop Oadd (Etempvar _t'7 (tptr (Tunion __206 noattr)))
                (Econst_int (Int.repr 1) tint) (tptr (Tunion __206 noattr)))))
          (Sset __g__6
            (Ecast (Etempvar _t'7 (tptr (Tunion __206 noattr)))
              (tptr (Tunion __206 noattr)))))
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__6 (tptr (Tunion __206 noattr)))
                  (Tunion __206 noattr)) _words (Tstruct __204 noattr)) _w0
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
                (Ederef (Etempvar __g__6 (tptr (Tunion __206 noattr)))
                  (Tunion __206 noattr)) _words (Tstruct __204 noattr)) _w1
              tuint)
            (Ecast (Evar _dl_shadow_end (tarray (Tunion __206 noattr) 0))
              tuint))))
      (Ssequence
        (Sset __g__7
          (Ecast (Etempvar _displayListHead (tptr (Tunion __206 noattr)))
            (tptr (Tunion __206 noattr))))
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__7 (tptr (Tunion __206 noattr)))
                  (Tunion __206 noattr)) _words (Tstruct __204 noattr)) _w0
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
                (Ederef (Etempvar __g__7 (tptr (Tunion __206 noattr)))
                  (Tunion __206 noattr)) _words (Tstruct __204 noattr)) _w1
              tuint) (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_linearly_interpolate_solidity_positive := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_s, (tptr (Tstruct _Shadow noattr))) ::
                (_finalSolidity, tuchar) :: (_curr, tshort) ::
                (_start, tshort) :: (_end, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Oge (Etempvar _curr tshort)
                 (Econst_int (Int.repr 0) tint) tint)
    (Sset _t'1
      (Ecast
        (Ebinop Olt (Etempvar _curr tshort) (Etempvar _start tshort) tint)
        tbool))
    (Sset _t'1 (Econst_int (Int.repr 0) tint)))
  (Sifthenelse (Etempvar _t'1 tint)
    (Sassign
      (Efield
        (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
          (Tstruct _Shadow noattr)) _solidity tuchar)
      (Econst_int (Int.repr 0) tint))
    (Sifthenelse (Ebinop Olt (Etempvar _end tshort) (Etempvar _curr tshort)
                   tint)
      (Sassign
        (Efield
          (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
            (Tstruct _Shadow noattr)) _solidity tuchar)
        (Etempvar _finalSolidity tuchar))
      (Sassign
        (Efield
          (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
            (Tstruct _Shadow noattr)) _solidity tuchar)
        (Ebinop Odiv
          (Ebinop Omul (Ecast (Etempvar _finalSolidity tuchar) tfloat)
            (Ebinop Osub (Etempvar _curr tshort) (Etempvar _start tshort)
              tint) tfloat)
          (Ebinop Osub (Etempvar _end tshort) (Etempvar _start tshort) tint)
          tfloat)))))
|}.

Definition f_linearly_interpolate_solidity_negative := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_s, (tptr (Tstruct _Shadow noattr))) ::
                (_initialSolidity, tuchar) :: (_curr, tshort) ::
                (_start, tshort) :: (_end, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Oge (Etempvar _curr tshort) (Etempvar _start tshort)
                 tint)
    (Sset _t'1
      (Ecast (Ebinop Oge (Etempvar _end tshort) (Etempvar _curr tshort) tint)
        tbool))
    (Sset _t'1 (Econst_int (Int.repr 0) tint)))
  (Sifthenelse (Etempvar _t'1 tint)
    (Sassign
      (Efield
        (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
          (Tstruct _Shadow noattr)) _solidity tuchar)
      (Ebinop Omul (Ecast (Etempvar _initialSolidity tuchar) tfloat)
        (Ebinop Osub
          (Econst_float (Float.of_bits (Int64.repr 4607182418800017408)) tdouble)
          (Ebinop Odiv
            (Ecast
              (Ebinop Osub (Etempvar _curr tshort) (Etempvar _start tshort)
                tint) tfloat)
            (Ebinop Osub (Etempvar _end tshort) (Etempvar _start tshort)
              tint) tfloat) tdouble) tdouble))
    (Sassign
      (Efield
        (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
          (Tstruct _Shadow noattr)) _solidity tuchar)
      (Econst_int (Int.repr 0) tint))))
|}.

Definition f_correct_shadow_solidity_for_animations := {|
  fn_return := tschar;
  fn_callconv := cc_default;
  fn_params := ((_isLuigi, tint) :: (_initialSolidity, tuchar) ::
                (_shadow, (tptr (Tstruct _Shadow noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_player, (tptr (Tstruct _Object noattr))) ::
               (_ret, tschar) :: (_animFrame, tshort) :: (_t'2, tshort) ::
               (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sswitch (Etempvar _isLuigi tint)
    (LScons (Some 0)
      (Ssequence
        (Sset _player (Evar _gMarioObject (tptr (Tstruct _Object noattr))))
        Sbreak)
      (LScons (Some 1)
        (Ssequence
          (Sset _player (Evar _gLuigiObject (tptr (Tstruct _Object noattr))))
          Sbreak)
        LSnil)))
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Efield
          (Efield
            (Efield
              (Efield
                (Ederef (Etempvar _player (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _header
                (Tstruct _ObjectNode noattr)) _gfx
              (Tstruct _GraphNodeObject noattr)) _animInfo
            (Tstruct _AnimInfo noattr)) _animFrame tshort))
      (Sset _animFrame (Ecast (Etempvar _t'2 tshort) tshort)))
    (Ssequence
      (Ssequence
        (Sset _t'1
          (Efield
            (Efield
              (Efield
                (Efield
                  (Ederef (Etempvar _player (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _header
                  (Tstruct _ObjectNode noattr)) _gfx
                (Tstruct _GraphNodeObject noattr)) _animInfo
              (Tstruct _AnimInfo noattr)) _animID tshort))
        (Sswitch (Etempvar _t'1 tshort)
          (LScons (Some 51)
            (Ssequence
              (Sset _ret (Ecast (Econst_int (Int.repr 0) tint) tschar))
              Sbreak)
            (LScons (Some 52)
              (Ssequence
                (Scall None
                  (Evar _linearly_interpolate_solidity_positive (Tfunction
                                                                  ((tptr (Tstruct _Shadow noattr)) ::
                                                                   tuchar ::
                                                                   tshort ::
                                                                   tshort ::
                                                                   tshort ::
                                                                   nil) tvoid
                                                                  cc_default))
                  ((Etempvar _shadow (tptr (Tstruct _Shadow noattr))) ::
                   (Etempvar _initialSolidity tuchar) ::
                   (Etempvar _animFrame tshort) ::
                   (Econst_int (Int.repr 5) tint) ::
                   (Econst_int (Int.repr 14) tint) :: nil))
                (Ssequence
                  (Sset _ret (Ecast (Econst_int (Int.repr 1) tint) tschar))
                  Sbreak))
              (LScons (Some 0)
                (Ssequence
                  (Scall None
                    (Evar _linearly_interpolate_solidity_positive (Tfunction
                                                                    ((tptr (Tstruct _Shadow noattr)) ::
                                                                    tuchar ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                    ((Etempvar _shadow (tptr (Tstruct _Shadow noattr))) ::
                     (Etempvar _initialSolidity tuchar) ::
                     (Etempvar _animFrame tshort) ::
                     (Econst_int (Int.repr 21) tint) ::
                     (Econst_int (Int.repr 33) tint) :: nil))
                  (Ssequence
                    (Sset _ret (Ecast (Econst_int (Int.repr 1) tint) tschar))
                    Sbreak))
                (LScons (Some 28)
                  (Ssequence
                    (Scall None
                      (Evar _linearly_interpolate_solidity_negative (Tfunction
                                                                    ((tptr (Tstruct _Shadow noattr)) ::
                                                                    tuchar ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                      ((Etempvar _shadow (tptr (Tstruct _Shadow noattr))) ::
                       (Etempvar _initialSolidity tuchar) ::
                       (Etempvar _animFrame tshort) ::
                       (Econst_int (Int.repr 0) tint) ::
                       (Econst_int (Int.repr 5) tint) :: nil))
                    (Ssequence
                      (Sset _ret
                        (Ecast (Econst_int (Int.repr 1) tint) tschar))
                      Sbreak))
                  (LScons None
                    (Ssequence
                      (Sset _ret
                        (Ecast (Econst_int (Int.repr 2) tint) tschar))
                      Sbreak)
                    LSnil)))))))
      (Sreturn (Some (Etempvar _ret tschar))))))
|}.

Definition f_correct_lava_shadow_height := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_s, (tptr (Tstruct _Shadow noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'10, tshort) :: (_t'9, tshort) :: (_t'8, tfloat) ::
               (_t'7, tfloat) :: (_t'6, tshort) :: (_t'5, tshort) ::
               (_t'4, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9 (Evar _gCurrLevelNum tshort))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tshort)
                   (Econst_int (Int.repr 19) tint) tint)
      (Ssequence
        (Sset _t'10 (Evar _sSurfaceTypeBelowShadow tshort))
        (Sset _t'3
          (Ecast
            (Ebinop Oeq (Etempvar _t'10 tshort)
              (Econst_int (Int.repr 1) tint) tint) tbool)))
      (Sset _t'3 (Econst_int (Int.repr 0) tint))))
  (Sifthenelse (Etempvar _t'3 tint)
    (Ssequence
      (Sset _t'7
        (Efield
          (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
            (Tstruct _Shadow noattr)) _floorHeight tfloat))
      (Sifthenelse (Ebinop Olt (Etempvar _t'7 tfloat)
                     (Eunop Oneg
                       (Econst_float (Float.of_bits (Int64.repr 4658815484840378368)) tdouble)
                       tdouble) tint)
        (Ssequence
          (Sassign
            (Efield
              (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                (Tstruct _Shadow noattr)) _floorHeight tfloat)
            (Eunop Oneg
              (Econst_float (Float.of_bits (Int64.repr 4658951824282222592)) tdouble)
              tdouble))
          (Sassign (Evar _gShadowAboveWaterOrLava tschar)
            (Econst_int (Int.repr 1) tint)))
        (Ssequence
          (Sset _t'8
            (Efield
              (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                (Tstruct _Shadow noattr)) _floorHeight tfloat))
          (Sifthenelse (Ebinop Ogt (Etempvar _t'8 tfloat)
                         (Econst_float (Float.of_bits (Int64.repr 4659695094142599168)) tdouble)
                         tint)
            (Ssequence
              (Sassign
                (Efield
                  (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                    (Tstruct _Shadow noattr)) _floorHeight tfloat)
                (Econst_float (Float.of_bits (Int64.repr 4659897404282109952)) tdouble))
              (Sassign (Evar _gShadowAboveWaterOrLava tschar)
                (Econst_int (Int.repr 1) tint)))
            Sskip))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'5 (Evar _gCurrLevelNum tshort))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tshort)
                         (Econst_int (Int.repr 22) tint) tint)
            (Ssequence
              (Sset _t'6 (Evar _gCurrAreaIndex tshort))
              (Sset _t'1
                (Ecast
                  (Ebinop Oeq (Etempvar _t'6 tshort)
                    (Econst_int (Int.repr 1) tint) tint) tbool)))
            (Sset _t'1 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'1 tint)
          (Ssequence
            (Sset _t'4 (Evar _sSurfaceTypeBelowShadow tshort))
            (Sset _t'2
              (Ecast
                (Ebinop Oeq (Etempvar _t'4 tshort)
                  (Econst_int (Int.repr 1) tint) tint) tbool)))
          (Sset _t'2 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'2 tint)
        (Ssequence
          (Sassign
            (Efield
              (Ederef (Etempvar _s (tptr (Tstruct _Shadow noattr)))
                (Tstruct _Shadow noattr)) _floorHeight tfloat)
            (Econst_float (Float.of_bits (Int64.repr 4617315517961601024)) tdouble))
          (Sassign (Evar _gShadowAboveWaterOrLava tschar)
            (Econst_int (Int.repr 1) tint)))
        Sskip))))
|}.

Definition f_create_shadow_player := {|
  fn_return := (tptr (Tunion __206 noattr));
  fn_callconv := cc_default;
  fn_params := ((_xPos, tfloat) :: (_yPos, tfloat) :: (_zPos, tfloat) ::
                (_shadowScale, tshort) :: (_solidity, tuchar) ::
                (_isLuigi, tint) :: nil);
  fn_vars := ((_shadow, (Tstruct _Shadow noattr)) :: nil);
  fn_temps := ((_verts, (tptr (Tunion __120 noattr))) ::
               (_displayList, (tptr (Tunion __206 noattr))) ::
               (_ret, tschar) :: (_i, tint) :: (_t'7, tint) ::
               (_t'6, (tptr tvoid)) :: (_t'5, (tptr tvoid)) ::
               (_t'4, tschar) :: (_t'3, tschar) :: (_t'2, tschar) ::
               (_t'1, tint) :: (_t'10, tshort) :: (_t'9, tshort) ::
               (_t'8, tschar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'9 (Evar _gCurrLevelNum tshort))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tshort)
                     (Econst_int (Int.repr 15) tint) tint)
        (Ssequence
          (Sset _t'10 (Evar _sSurfaceTypeBelowShadow tshort))
          (Sset _t'1
            (Ecast
              (Ebinop One (Etempvar _t'10 tshort)
                (Econst_int (Int.repr 10) tint) tint) tbool)))
        (Sset _t'1 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'1 tint)
      (Ssequence
        (Sset _t'8 (Evar _gFlyingCarpetState tschar))
        (Sswitch (Etempvar _t'8 tschar)
          (LScons (Some 1)
            (Ssequence
              (Sassign (Evar _gMarioOnIceOrCarpet tschar)
                (Econst_int (Int.repr 1) tint))
              (Ssequence
                (Sassign (Evar _sMarioOnFlyingCarpet tschar)
                  (Econst_int (Int.repr 1) tint))
                Sbreak))
            (LScons (Some 2)
              (Ssequence
                (Sassign (Evar _gMarioOnIceOrCarpet tschar)
                  (Econst_int (Int.repr 1) tint))
                Sbreak)
              LSnil))))
      Sskip))
  (Ssequence
    (Ssequence
      (Scall (Some _t'2)
        (Evar _correct_shadow_solidity_for_animations (Tfunction
                                                        (tint :: tuchar ::
                                                         (tptr (Tstruct _Shadow noattr)) ::
                                                         nil) tschar
                                                        cc_default))
        ((Etempvar _isLuigi tint) :: (Etempvar _solidity tuchar) ::
         (Eaddrof (Evar _shadow (Tstruct _Shadow noattr))
           (tptr (Tstruct _Shadow noattr))) :: nil))
      (Sswitch (Etempvar _t'2 tschar)
        (LScons (Some 0)
          (Ssequence
            (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint)
                             (tptr tvoid))))
            Sbreak)
          (LScons (Some 1)
            (Ssequence
              (Ssequence
                (Scall (Some _t'3)
                  (Evar _init_shadow (Tfunction
                                       ((tptr (Tstruct _Shadow noattr)) ::
                                        tfloat :: tfloat :: tfloat ::
                                        tshort :: tuchar :: nil) tschar
                                       cc_default))
                  ((Eaddrof (Evar _shadow (Tstruct _Shadow noattr))
                     (tptr (Tstruct _Shadow noattr))) ::
                   (Etempvar _xPos tfloat) :: (Etempvar _yPos tfloat) ::
                   (Etempvar _zPos tfloat) ::
                   (Etempvar _shadowScale tshort) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                (Sset _ret (Ecast (Etempvar _t'3 tschar) tschar)))
              Sbreak)
            (LScons (Some 2)
              (Ssequence
                (Ssequence
                  (Scall (Some _t'4)
                    (Evar _init_shadow (Tfunction
                                         ((tptr (Tstruct _Shadow noattr)) ::
                                          tfloat :: tfloat :: tfloat ::
                                          tshort :: tuchar :: nil) tschar
                                         cc_default))
                    ((Eaddrof (Evar _shadow (Tstruct _Shadow noattr))
                       (tptr (Tstruct _Shadow noattr))) ::
                     (Etempvar _xPos tfloat) :: (Etempvar _yPos tfloat) ::
                     (Etempvar _zPos tfloat) ::
                     (Etempvar _shadowScale tshort) ::
                     (Etempvar _solidity tuchar) :: nil))
                  (Sset _ret (Ecast (Etempvar _t'4 tschar) tschar)))
                Sbreak)
              LSnil)))))
    (Ssequence
      (Sifthenelse (Ebinop One (Etempvar _ret tschar)
                     (Econst_int (Int.repr 0) tint) tint)
        (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
        Sskip)
      (Ssequence
        (Ssequence
          (Scall (Some _t'5)
            (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                        cc_default))
            ((Ebinop Omul (Econst_int (Int.repr 9) tint)
               (Esizeof (Tunion __120 noattr) tulong) tulong) :: nil))
          (Sset _verts (Etempvar _t'5 (tptr tvoid))))
        (Ssequence
          (Ssequence
            (Scall (Some _t'6)
              (Evar _alloc_display_list (Tfunction (tuint :: nil)
                                          (tptr tvoid) cc_default))
              ((Ebinop Omul (Econst_int (Int.repr 5) tint)
                 (Esizeof (Tunion __206 noattr) tulong) tulong) :: nil))
            (Sset _displayList (Etempvar _t'6 (tptr tvoid))))
          (Ssequence
            (Ssequence
              (Sifthenelse (Ebinop Oeq
                             (Etempvar _verts (tptr (Tunion __120 noattr)))
                             (Ecast (Econst_int (Int.repr 0) tint)
                               (tptr tvoid)) tint)
                (Sset _t'7 (Econst_int (Int.repr 1) tint))
                (Sset _t'7
                  (Ecast
                    (Ebinop Oeq
                      (Etempvar _displayList (tptr (Tunion __206 noattr)))
                      (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                      tint) tbool)))
              (Sifthenelse (Etempvar _t'7 tint)
                (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint)
                                 (tptr tvoid))))
                Sskip))
            (Ssequence
              (Scall None
                (Evar _correct_lava_shadow_height (Tfunction
                                                    ((tptr (Tstruct _Shadow noattr)) ::
                                                     nil) tvoid cc_default))
                ((Eaddrof (Evar _shadow (Tstruct _Shadow noattr))
                   (tptr (Tstruct _Shadow noattr))) :: nil))
              (Ssequence
                (Ssequence
                  (Sset _i (Econst_int (Int.repr 0) tint))
                  (Sloop
                    (Ssequence
                      (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                                     (Econst_int (Int.repr 9) tint) tint)
                        Sskip
                        Sbreak)
                      (Scall None
                        (Evar _make_shadow_vertex (Tfunction
                                                    ((tptr (Tunion __120 noattr)) ::
                                                     tschar ::
                                                     (Tstruct _Shadow noattr) ::
                                                     tschar :: nil) tvoid
                                                    cc_default))
                        ((Etempvar _verts (tptr (Tunion __120 noattr))) ::
                         (Etempvar _i tint) ::
                         (Evar _shadow (Tstruct _Shadow noattr)) ::
                         (Econst_int (Int.repr 0) tint) :: nil)))
                    (Sset _i
                      (Ebinop Oadd (Etempvar _i tint)
                        (Econst_int (Int.repr 1) tint) tint))))
                (Ssequence
                  (Scall None
                    (Evar _add_shadow_to_display_list (Tfunction
                                                        ((tptr (Tunion __206 noattr)) ::
                                                         (tptr (Tunion __120 noattr)) ::
                                                         tschar :: tschar ::
                                                         nil) tvoid
                                                        cc_default))
                    ((Etempvar _displayList (tptr (Tunion __206 noattr))) ::
                     (Etempvar _verts (tptr (Tunion __120 noattr))) ::
                     (Econst_int (Int.repr 0) tint) ::
                     (Econst_int (Int.repr 10) tint) :: nil))
                  (Sreturn (Some (Etempvar _displayList (tptr (Tunion __206 noattr))))))))))))))
|}.

Definition f_create_shadow_circle_9_verts := {|
  fn_return := (tptr (Tunion __206 noattr));
  fn_callconv := cc_default;
  fn_params := ((_xPos, tfloat) :: (_yPos, tfloat) :: (_zPos, tfloat) ::
                (_shadowScale, tshort) :: (_solidity, tuchar) :: nil);
  fn_vars := ((_shadow, (Tstruct _Shadow noattr)) :: nil);
  fn_temps := ((_verts, (tptr (Tunion __120 noattr))) ::
               (_displayList, (tptr (Tunion __206 noattr))) :: (_i, tint) ::
               (_t'4, tint) :: (_t'3, (tptr tvoid)) ::
               (_t'2, (tptr tvoid)) :: (_t'1, tschar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _init_shadow (Tfunction
                           ((tptr (Tstruct _Shadow noattr)) :: tfloat ::
                            tfloat :: tfloat :: tshort :: tuchar :: nil)
                           tschar cc_default))
      ((Eaddrof (Evar _shadow (Tstruct _Shadow noattr))
         (tptr (Tstruct _Shadow noattr))) :: (Etempvar _xPos tfloat) ::
       (Etempvar _yPos tfloat) :: (Etempvar _zPos tfloat) ::
       (Etempvar _shadowScale tshort) :: (Etempvar _solidity tuchar) :: nil))
    (Sifthenelse (Ebinop One (Etempvar _t'1 tschar)
                   (Econst_int (Int.repr 0) tint) tint)
      (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
      Sskip))
  (Ssequence
    (Ssequence
      (Scall (Some _t'2)
        (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                    cc_default))
        ((Ebinop Omul (Econst_int (Int.repr 9) tint)
           (Esizeof (Tunion __120 noattr) tulong) tulong) :: nil))
      (Sset _verts (Etempvar _t'2 (tptr tvoid))))
    (Ssequence
      (Ssequence
        (Scall (Some _t'3)
          (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                      cc_default))
          ((Ebinop Omul (Econst_int (Int.repr 5) tint)
             (Esizeof (Tunion __206 noattr) tulong) tulong) :: nil))
        (Sset _displayList (Etempvar _t'3 (tptr tvoid))))
      (Ssequence
        (Ssequence
          (Sifthenelse (Ebinop Oeq
                         (Etempvar _verts (tptr (Tunion __120 noattr)))
                         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                         tint)
            (Sset _t'4 (Econst_int (Int.repr 1) tint))
            (Sset _t'4
              (Ecast
                (Ebinop Oeq
                  (Etempvar _displayList (tptr (Tunion __206 noattr)))
                  (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
                tbool)))
          (Sifthenelse (Etempvar _t'4 tint)
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _i (Econst_int (Int.repr 0) tint))
            (Sloop
              (Ssequence
                (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                               (Econst_int (Int.repr 9) tint) tint)
                  Sskip
                  Sbreak)
                (Scall None
                  (Evar _make_shadow_vertex (Tfunction
                                              ((tptr (Tunion __120 noattr)) ::
                                               tschar ::
                                               (Tstruct _Shadow noattr) ::
                                               tschar :: nil) tvoid
                                              cc_default))
                  ((Etempvar _verts (tptr (Tunion __120 noattr))) ::
                   (Etempvar _i tint) ::
                   (Evar _shadow (Tstruct _Shadow noattr)) ::
                   (Econst_int (Int.repr 0) tint) :: nil)))
              (Sset _i
                (Ebinop Oadd (Etempvar _i tint)
                  (Econst_int (Int.repr 1) tint) tint))))
          (Ssequence
            (Scall None
              (Evar _add_shadow_to_display_list (Tfunction
                                                  ((tptr (Tunion __206 noattr)) ::
                                                   (tptr (Tunion __120 noattr)) ::
                                                   tschar :: tschar :: nil)
                                                  tvoid cc_default))
              ((Etempvar _displayList (tptr (Tunion __206 noattr))) ::
               (Etempvar _verts (tptr (Tunion __120 noattr))) ::
               (Econst_int (Int.repr 0) tint) ::
               (Econst_int (Int.repr 10) tint) :: nil))
            (Sreturn (Some (Etempvar _displayList (tptr (Tunion __206 noattr)))))))))))
|}.

Definition f_create_shadow_circle_4_verts := {|
  fn_return := (tptr (Tunion __206 noattr));
  fn_callconv := cc_default;
  fn_params := ((_xPos, tfloat) :: (_yPos, tfloat) :: (_zPos, tfloat) ::
                (_shadowScale, tshort) :: (_solidity, tuchar) :: nil);
  fn_vars := ((_shadow, (Tstruct _Shadow noattr)) :: nil);
  fn_temps := ((_verts, (tptr (Tunion __120 noattr))) ::
               (_displayList, (tptr (Tunion __206 noattr))) :: (_i, tint) ::
               (_t'4, tint) :: (_t'3, (tptr tvoid)) ::
               (_t'2, (tptr tvoid)) :: (_t'1, tschar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _init_shadow (Tfunction
                           ((tptr (Tstruct _Shadow noattr)) :: tfloat ::
                            tfloat :: tfloat :: tshort :: tuchar :: nil)
                           tschar cc_default))
      ((Eaddrof (Evar _shadow (Tstruct _Shadow noattr))
         (tptr (Tstruct _Shadow noattr))) :: (Etempvar _xPos tfloat) ::
       (Etempvar _yPos tfloat) :: (Etempvar _zPos tfloat) ::
       (Etempvar _shadowScale tshort) :: (Etempvar _solidity tuchar) :: nil))
    (Sifthenelse (Ebinop One (Etempvar _t'1 tschar)
                   (Econst_int (Int.repr 0) tint) tint)
      (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
      Sskip))
  (Ssequence
    (Ssequence
      (Scall (Some _t'2)
        (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                    cc_default))
        ((Ebinop Omul (Econst_int (Int.repr 4) tint)
           (Esizeof (Tunion __120 noattr) tulong) tulong) :: nil))
      (Sset _verts (Etempvar _t'2 (tptr tvoid))))
    (Ssequence
      (Ssequence
        (Scall (Some _t'3)
          (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                      cc_default))
          ((Ebinop Omul (Econst_int (Int.repr 5) tint)
             (Esizeof (Tunion __206 noattr) tulong) tulong) :: nil))
        (Sset _displayList (Etempvar _t'3 (tptr tvoid))))
      (Ssequence
        (Ssequence
          (Sifthenelse (Ebinop Oeq
                         (Etempvar _verts (tptr (Tunion __120 noattr)))
                         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                         tint)
            (Sset _t'4 (Econst_int (Int.repr 1) tint))
            (Sset _t'4
              (Ecast
                (Ebinop Oeq
                  (Etempvar _displayList (tptr (Tunion __206 noattr)))
                  (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
                tbool)))
          (Sifthenelse (Etempvar _t'4 tint)
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _i (Econst_int (Int.repr 0) tint))
            (Sloop
              (Ssequence
                (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                               (Econst_int (Int.repr 4) tint) tint)
                  Sskip
                  Sbreak)
                (Scall None
                  (Evar _make_shadow_vertex (Tfunction
                                              ((tptr (Tunion __120 noattr)) ::
                                               tschar ::
                                               (Tstruct _Shadow noattr) ::
                                               tschar :: nil) tvoid
                                              cc_default))
                  ((Etempvar _verts (tptr (Tunion __120 noattr))) ::
                   (Etempvar _i tint) ::
                   (Evar _shadow (Tstruct _Shadow noattr)) ::
                   (Econst_int (Int.repr 1) tint) :: nil)))
              (Sset _i
                (Ebinop Oadd (Etempvar _i tint)
                  (Econst_int (Int.repr 1) tint) tint))))
          (Ssequence
            (Scall None
              (Evar _add_shadow_to_display_list (Tfunction
                                                  ((tptr (Tunion __206 noattr)) ::
                                                   (tptr (Tunion __120 noattr)) ::
                                                   tschar :: tschar :: nil)
                                                  tvoid cc_default))
              ((Etempvar _displayList (tptr (Tunion __206 noattr))) ::
               (Etempvar _verts (tptr (Tunion __120 noattr))) ::
               (Econst_int (Int.repr 1) tint) ::
               (Econst_int (Int.repr 10) tint) :: nil))
            (Sreturn (Some (Etempvar _displayList (tptr (Tunion __206 noattr)))))))))))
|}.

Definition f_create_shadow_circle_assuming_flat_ground := {|
  fn_return := (tptr (Tunion __206 noattr));
  fn_callconv := cc_default;
  fn_params := ((_xPos, tfloat) :: (_yPos, tfloat) :: (_zPos, tfloat) ::
                (_shadowScale, tshort) :: (_solidity, tuchar) :: nil);
  fn_vars := ((_dummy, (tptr (Tstruct _FloorGeometry noattr))) :: nil);
  fn_temps := ((_verts, (tptr (Tunion __120 noattr))) ::
               (_displayList, (tptr (Tunion __206 noattr))) ::
               (_distBelowFloor, tfloat) :: (_floorHeight, tfloat) ::
               (_radius, tfloat) :: (_t'4, tint) :: (_t'3, (tptr tvoid)) ::
               (_t'2, (tptr tvoid)) :: (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _find_floor_height_and_data (Tfunction
                                          (tfloat :: tfloat :: tfloat ::
                                           (tptr (tptr (Tstruct _FloorGeometry noattr))) ::
                                           nil) tfloat cc_default))
      ((Etempvar _xPos tfloat) :: (Etempvar _yPos tfloat) ::
       (Etempvar _zPos tfloat) ::
       (Eaddrof (Evar _dummy (tptr (Tstruct _FloorGeometry noattr)))
         (tptr (tptr (Tstruct _FloorGeometry noattr)))) :: nil))
    (Sset _floorHeight (Etempvar _t'1 tfloat)))
  (Ssequence
    (Sset _radius
      (Ecast
        (Ebinop Odiv (Etempvar _shadowScale tshort)
          (Econst_int (Int.repr 2) tint) tint) tfloat))
    (Ssequence
      (Sifthenelse (Ebinop Olt (Etempvar _floorHeight tfloat)
                     (Ebinop Oadd
                       (Eunop Oneg (Econst_int (Int.repr 11000) tint) tint)
                       (Econst_float (Float.of_bits (Int64.repr 4652007308841189376)) tdouble)
                       tdouble) tint)
        (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
        (Sset _distBelowFloor
          (Ebinop Osub (Etempvar _floorHeight tfloat) (Etempvar _yPos tfloat)
            tfloat)))
      (Ssequence
        (Ssequence
          (Scall (Some _t'2)
            (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                        cc_default))
            ((Ebinop Omul (Econst_int (Int.repr 4) tint)
               (Esizeof (Tunion __120 noattr) tulong) tulong) :: nil))
          (Sset _verts (Etempvar _t'2 (tptr tvoid))))
        (Ssequence
          (Ssequence
            (Scall (Some _t'3)
              (Evar _alloc_display_list (Tfunction (tuint :: nil)
                                          (tptr tvoid) cc_default))
              ((Ebinop Omul (Econst_int (Int.repr 5) tint)
                 (Esizeof (Tunion __206 noattr) tulong) tulong) :: nil))
            (Sset _displayList (Etempvar _t'3 (tptr tvoid))))
          (Ssequence
            (Ssequence
              (Sifthenelse (Ebinop Oeq
                             (Etempvar _verts (tptr (Tunion __120 noattr)))
                             (Ecast (Econst_int (Int.repr 0) tint)
                               (tptr tvoid)) tint)
                (Sset _t'4 (Econst_int (Int.repr 1) tint))
                (Sset _t'4
                  (Ecast
                    (Ebinop Oeq
                      (Etempvar _displayList (tptr (Tunion __206 noattr)))
                      (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                      tint) tbool)))
              (Sifthenelse (Etempvar _t'4 tint)
                (Sreturn (Some (Econst_int (Int.repr 0) tint)))
                Sskip))
            (Ssequence
              (Scall None
                (Evar _make_shadow_vertex_at_xyz (Tfunction
                                                   ((tptr (Tunion __120 noattr)) ::
                                                    tschar :: tfloat ::
                                                    tfloat :: tfloat ::
                                                    tuchar :: tschar :: nil)
                                                   tvoid cc_default))
                ((Etempvar _verts (tptr (Tunion __120 noattr))) ::
                 (Econst_int (Int.repr 0) tint) ::
                 (Eunop Oneg (Etempvar _radius tfloat) tfloat) ::
                 (Etempvar _distBelowFloor tfloat) ::
                 (Eunop Oneg (Etempvar _radius tfloat) tfloat) ::
                 (Etempvar _solidity tuchar) ::
                 (Econst_int (Int.repr 1) tint) :: nil))
              (Ssequence
                (Scall None
                  (Evar _make_shadow_vertex_at_xyz (Tfunction
                                                     ((tptr (Tunion __120 noattr)) ::
                                                      tschar :: tfloat ::
                                                      tfloat :: tfloat ::
                                                      tuchar :: tschar ::
                                                      nil) tvoid cc_default))
                  ((Etempvar _verts (tptr (Tunion __120 noattr))) ::
                   (Econst_int (Int.repr 1) tint) ::
                   (Etempvar _radius tfloat) ::
                   (Etempvar _distBelowFloor tfloat) ::
                   (Eunop Oneg (Etempvar _radius tfloat) tfloat) ::
                   (Etempvar _solidity tuchar) ::
                   (Econst_int (Int.repr 1) tint) :: nil))
                (Ssequence
                  (Scall None
                    (Evar _make_shadow_vertex_at_xyz (Tfunction
                                                       ((tptr (Tunion __120 noattr)) ::
                                                        tschar :: tfloat ::
                                                        tfloat :: tfloat ::
                                                        tuchar :: tschar ::
                                                        nil) tvoid
                                                       cc_default))
                    ((Etempvar _verts (tptr (Tunion __120 noattr))) ::
                     (Econst_int (Int.repr 2) tint) ::
                     (Eunop Oneg (Etempvar _radius tfloat) tfloat) ::
                     (Etempvar _distBelowFloor tfloat) ::
                     (Etempvar _radius tfloat) ::
                     (Etempvar _solidity tuchar) ::
                     (Econst_int (Int.repr 1) tint) :: nil))
                  (Ssequence
                    (Scall None
                      (Evar _make_shadow_vertex_at_xyz (Tfunction
                                                         ((tptr (Tunion __120 noattr)) ::
                                                          tschar :: tfloat ::
                                                          tfloat :: tfloat ::
                                                          tuchar :: tschar ::
                                                          nil) tvoid
                                                         cc_default))
                      ((Etempvar _verts (tptr (Tunion __120 noattr))) ::
                       (Econst_int (Int.repr 3) tint) ::
                       (Etempvar _radius tfloat) ::
                       (Etempvar _distBelowFloor tfloat) ::
                       (Etempvar _radius tfloat) ::
                       (Etempvar _solidity tuchar) ::
                       (Econst_int (Int.repr 1) tint) :: nil))
                    (Ssequence
                      (Scall None
                        (Evar _add_shadow_to_display_list (Tfunction
                                                            ((tptr (Tunion __206 noattr)) ::
                                                             (tptr (Tunion __120 noattr)) ::
                                                             tschar ::
                                                             tschar :: nil)
                                                            tvoid cc_default))
                        ((Etempvar _displayList (tptr (Tunion __206 noattr))) ::
                         (Etempvar _verts (tptr (Tunion __120 noattr))) ::
                         (Econst_int (Int.repr 1) tint) ::
                         (Econst_int (Int.repr 10) tint) :: nil))
                      (Sreturn (Some (Etempvar _displayList (tptr (Tunion __206 noattr))))))))))))))))
|}.

Definition f_create_shadow_rectangle := {|
  fn_return := (tptr (Tunion __206 noattr));
  fn_callconv := cc_default;
  fn_params := ((_halfWidth, tfloat) :: (_halfLength, tfloat) ::
                (_relY, tfloat) :: (_solidity, tuchar) :: nil);
  fn_vars := ((_frontLeftX, tfloat) :: (_frontLeftZ, tfloat) ::
              (_frontRightX, tfloat) :: (_frontRightZ, tfloat) ::
              (_backLeftX, tfloat) :: (_backLeftZ, tfloat) ::
              (_backRightX, tfloat) :: (_backRightZ, tfloat) :: nil);
  fn_temps := ((_verts, (tptr (Tunion __120 noattr))) ::
               (_displayList, (tptr (Tunion __206 noattr))) ::
               (_t'3, tint) :: (_t'2, (tptr tvoid)) ::
               (_t'1, (tptr tvoid)) :: (_t'11, tfloat) :: (_t'10, tfloat) ::
               (_t'9, tfloat) :: (_t'8, tfloat) :: (_t'7, tfloat) ::
               (_t'6, tfloat) :: (_t'5, tfloat) :: (_t'4, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                  cc_default))
      ((Ebinop Omul (Econst_int (Int.repr 4) tint)
         (Esizeof (Tunion __120 noattr) tulong) tulong) :: nil))
    (Sset _verts (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Ssequence
      (Scall (Some _t'2)
        (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                    cc_default))
        ((Ebinop Omul (Econst_int (Int.repr 5) tint)
           (Esizeof (Tunion __206 noattr) tulong) tulong) :: nil))
      (Sset _displayList (Etempvar _t'2 (tptr tvoid))))
    (Ssequence
      (Ssequence
        (Sifthenelse (Ebinop Oeq
                       (Etempvar _verts (tptr (Tunion __120 noattr)))
                       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                       tint)
          (Sset _t'3 (Econst_int (Int.repr 1) tint))
          (Sset _t'3
            (Ecast
              (Ebinop Oeq
                (Etempvar _displayList (tptr (Tunion __206 noattr)))
                (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
              tbool)))
        (Sifthenelse (Etempvar _t'3 tint)
          (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _rotate_rectangle (Tfunction
                                    ((tptr tfloat) :: (tptr tfloat) ::
                                     tfloat :: tfloat :: nil) tvoid
                                    cc_default))
          ((Eaddrof (Evar _frontLeftZ tfloat) (tptr tfloat)) ::
           (Eaddrof (Evar _frontLeftX tfloat) (tptr tfloat)) ::
           (Eunop Oneg (Etempvar _halfLength tfloat) tfloat) ::
           (Eunop Oneg (Etempvar _halfWidth tfloat) tfloat) :: nil))
        (Ssequence
          (Scall None
            (Evar _rotate_rectangle (Tfunction
                                      ((tptr tfloat) :: (tptr tfloat) ::
                                       tfloat :: tfloat :: nil) tvoid
                                      cc_default))
            ((Eaddrof (Evar _frontRightZ tfloat) (tptr tfloat)) ::
             (Eaddrof (Evar _frontRightX tfloat) (tptr tfloat)) ::
             (Eunop Oneg (Etempvar _halfLength tfloat) tfloat) ::
             (Etempvar _halfWidth tfloat) :: nil))
          (Ssequence
            (Scall None
              (Evar _rotate_rectangle (Tfunction
                                        ((tptr tfloat) :: (tptr tfloat) ::
                                         tfloat :: tfloat :: nil) tvoid
                                        cc_default))
              ((Eaddrof (Evar _backLeftZ tfloat) (tptr tfloat)) ::
               (Eaddrof (Evar _backLeftX tfloat) (tptr tfloat)) ::
               (Etempvar _halfLength tfloat) ::
               (Eunop Oneg (Etempvar _halfWidth tfloat) tfloat) :: nil))
            (Ssequence
              (Scall None
                (Evar _rotate_rectangle (Tfunction
                                          ((tptr tfloat) :: (tptr tfloat) ::
                                           tfloat :: tfloat :: nil) tvoid
                                          cc_default))
                ((Eaddrof (Evar _backRightZ tfloat) (tptr tfloat)) ::
                 (Eaddrof (Evar _backRightX tfloat) (tptr tfloat)) ::
                 (Etempvar _halfLength tfloat) ::
                 (Etempvar _halfWidth tfloat) :: nil))
              (Ssequence
                (Ssequence
                  (Sset _t'10 (Evar _frontLeftX tfloat))
                  (Ssequence
                    (Sset _t'11 (Evar _frontLeftZ tfloat))
                    (Scall None
                      (Evar _make_shadow_vertex_at_xyz (Tfunction
                                                         ((tptr (Tunion __120 noattr)) ::
                                                          tschar :: tfloat ::
                                                          tfloat :: tfloat ::
                                                          tuchar :: tschar ::
                                                          nil) tvoid
                                                         cc_default))
                      ((Etempvar _verts (tptr (Tunion __120 noattr))) ::
                       (Econst_int (Int.repr 0) tint) ::
                       (Etempvar _t'10 tfloat) :: (Etempvar _relY tfloat) ::
                       (Etempvar _t'11 tfloat) ::
                       (Etempvar _solidity tuchar) ::
                       (Econst_int (Int.repr 1) tint) :: nil))))
                (Ssequence
                  (Ssequence
                    (Sset _t'8 (Evar _frontRightX tfloat))
                    (Ssequence
                      (Sset _t'9 (Evar _frontRightZ tfloat))
                      (Scall None
                        (Evar _make_shadow_vertex_at_xyz (Tfunction
                                                           ((tptr (Tunion __120 noattr)) ::
                                                            tschar ::
                                                            tfloat ::
                                                            tfloat ::
                                                            tfloat ::
                                                            tuchar ::
                                                            tschar :: nil)
                                                           tvoid cc_default))
                        ((Etempvar _verts (tptr (Tunion __120 noattr))) ::
                         (Econst_int (Int.repr 1) tint) ::
                         (Etempvar _t'8 tfloat) :: (Etempvar _relY tfloat) ::
                         (Etempvar _t'9 tfloat) ::
                         (Etempvar _solidity tuchar) ::
                         (Econst_int (Int.repr 1) tint) :: nil))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'6 (Evar _backLeftX tfloat))
                      (Ssequence
                        (Sset _t'7 (Evar _backLeftZ tfloat))
                        (Scall None
                          (Evar _make_shadow_vertex_at_xyz (Tfunction
                                                             ((tptr (Tunion __120 noattr)) ::
                                                              tschar ::
                                                              tfloat ::
                                                              tfloat ::
                                                              tfloat ::
                                                              tuchar ::
                                                              tschar :: nil)
                                                             tvoid
                                                             cc_default))
                          ((Etempvar _verts (tptr (Tunion __120 noattr))) ::
                           (Econst_int (Int.repr 2) tint) ::
                           (Etempvar _t'6 tfloat) ::
                           (Etempvar _relY tfloat) ::
                           (Etempvar _t'7 tfloat) ::
                           (Etempvar _solidity tuchar) ::
                           (Econst_int (Int.repr 1) tint) :: nil))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'4 (Evar _backRightX tfloat))
                        (Ssequence
                          (Sset _t'5 (Evar _backRightZ tfloat))
                          (Scall None
                            (Evar _make_shadow_vertex_at_xyz (Tfunction
                                                               ((tptr (Tunion __120 noattr)) ::
                                                                tschar ::
                                                                tfloat ::
                                                                tfloat ::
                                                                tfloat ::
                                                                tuchar ::
                                                                tschar ::
                                                                nil) tvoid
                                                               cc_default))
                            ((Etempvar _verts (tptr (Tunion __120 noattr))) ::
                             (Econst_int (Int.repr 3) tint) ::
                             (Etempvar _t'4 tfloat) ::
                             (Etempvar _relY tfloat) ::
                             (Etempvar _t'5 tfloat) ::
                             (Etempvar _solidity tuchar) ::
                             (Econst_int (Int.repr 1) tint) :: nil))))
                      (Ssequence
                        (Scall None
                          (Evar _add_shadow_to_display_list (Tfunction
                                                              ((tptr (Tunion __206 noattr)) ::
                                                               (tptr (Tunion __120 noattr)) ::
                                                               tschar ::
                                                               tschar :: nil)
                                                              tvoid
                                                              cc_default))
                          ((Etempvar _displayList (tptr (Tunion __206 noattr))) ::
                           (Etempvar _verts (tptr (Tunion __120 noattr))) ::
                           (Econst_int (Int.repr 1) tint) ::
                           (Econst_int (Int.repr 20) tint) :: nil))
                        (Sreturn (Some (Etempvar _displayList (tptr (Tunion __206 noattr)))))))))))))))))
|}.

Definition f_get_shadow_height_solidity := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_xPos, tfloat) :: (_yPos, tfloat) :: (_zPos, tfloat) ::
                (_shadowHeight, (tptr tfloat)) ::
                (_solidity, (tptr tuchar)) :: nil);
  fn_vars := ((_dummy, (tptr (Tstruct _FloorGeometry noattr))) :: nil);
  fn_temps := ((_waterLevel, tfloat) :: (_t'3, tint) :: (_t'2, tfloat) ::
               (_t'1, tfloat) :: (_t'5, tfloat) :: (_t'4, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _find_floor_height_and_data (Tfunction
                                          (tfloat :: tfloat :: tfloat ::
                                           (tptr (tptr (Tstruct _FloorGeometry noattr))) ::
                                           nil) tfloat cc_default))
      ((Etempvar _xPos tfloat) :: (Etempvar _yPos tfloat) ::
       (Etempvar _zPos tfloat) ::
       (Eaddrof (Evar _dummy (tptr (Tstruct _FloorGeometry noattr)))
         (tptr (tptr (Tstruct _FloorGeometry noattr)))) :: nil))
    (Sassign (Ederef (Etempvar _shadowHeight (tptr tfloat)) tfloat)
      (Etempvar _t'1 tfloat)))
  (Ssequence
    (Ssequence
      (Sset _t'4 (Ederef (Etempvar _shadowHeight (tptr tfloat)) tfloat))
      (Sifthenelse (Ebinop Olt (Etempvar _t'4 tfloat)
                     (Ebinop Oadd
                       (Eunop Oneg (Econst_int (Int.repr 11000) tint) tint)
                       (Econst_float (Float.of_bits (Int64.repr 4652007308841189376)) tdouble)
                       tdouble) tint)
        (Sreturn (Some (Econst_int (Int.repr 1) tint)))
        (Ssequence
          (Ssequence
            (Scall (Some _t'2)
              (Evar _find_water_level (Tfunction (tfloat :: tfloat :: nil)
                                        tfloat cc_default))
              ((Etempvar _xPos tfloat) :: (Etempvar _zPos tfloat) :: nil))
            (Sset _waterLevel (Etempvar _t'2 tfloat)))
          (Sifthenelse (Ebinop Olt (Etempvar _waterLevel tfloat)
                         (Ebinop Oadd
                           (Eunop Oneg (Econst_int (Int.repr 11000) tint)
                             tint)
                           (Econst_float (Float.of_bits (Int64.repr 4652007308841189376)) tdouble)
                           tdouble) tint)
            Sskip
            (Ssequence
              (Sifthenelse (Ebinop Oge (Etempvar _yPos tfloat)
                             (Etempvar _waterLevel tfloat) tint)
                (Ssequence
                  (Sset _t'5
                    (Ederef (Etempvar _shadowHeight (tptr tfloat)) tfloat))
                  (Sset _t'3
                    (Ecast
                      (Ebinop Oge (Etempvar _waterLevel tfloat)
                        (Etempvar _t'5 tfloat) tint) tbool)))
                (Sset _t'3 (Econst_int (Int.repr 0) tint)))
              (Sifthenelse (Etempvar _t'3 tint)
                (Ssequence
                  (Sassign (Evar _gShadowAboveWaterOrLava tschar)
                    (Econst_int (Int.repr 1) tint))
                  (Ssequence
                    (Sassign
                      (Ederef (Etempvar _shadowHeight (tptr tfloat)) tfloat)
                      (Etempvar _waterLevel tfloat))
                    (Sassign
                      (Ederef (Etempvar _solidity (tptr tuchar)) tuchar)
                      (Econst_int (Int.repr 200) tint))))
                Sskip))))))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_create_shadow_square := {|
  fn_return := (tptr (Tunion __206 noattr));
  fn_callconv := cc_default;
  fn_params := ((_xPos, tfloat) :: (_yPos, tfloat) :: (_zPos, tfloat) ::
                (_shadowScale, tshort) :: (_solidity, tuchar) ::
                (_shadowType, tschar) :: nil);
  fn_vars := ((_solidity, tuchar) :: (_shadowHeight, tfloat) :: nil);
  fn_temps := ((_distFromShadow, tfloat) :: (_shadowRadius, tfloat) ::
               (_t'4, (tptr (Tunion __206 noattr))) :: (_t'3, tfloat) ::
               (_t'2, tfloat) :: (_t'1, tint) :: (_t'6, tfloat) ::
               (_t'5, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _solidity tuchar) (Etempvar _solidity tuchar))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _get_shadow_height_solidity (Tfunction
                                            (tfloat :: tfloat :: tfloat ::
                                             (tptr tfloat) ::
                                             (tptr tuchar) :: nil) tint
                                            cc_default))
        ((Etempvar _xPos tfloat) :: (Etempvar _yPos tfloat) ::
         (Etempvar _zPos tfloat) ::
         (Eaddrof (Evar _shadowHeight tfloat) (tptr tfloat)) ::
         (Eaddrof (Evar _solidity tuchar) (tptr tuchar)) :: nil))
      (Sifthenelse (Ebinop One (Etempvar _t'1 tint)
                     (Econst_int (Int.repr 0) tint) tint)
        (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'6 (Evar _shadowHeight tfloat))
        (Sset _distFromShadow
          (Ebinop Osub (Etempvar _yPos tfloat) (Etempvar _t'6 tfloat) tfloat)))
      (Ssequence
        (Sswitch (Etempvar _shadowType tschar)
          (LScons (Some 10)
            (Ssequence
              (Sset _shadowRadius
                (Ecast
                  (Ebinop Odiv (Etempvar _shadowScale tshort)
                    (Econst_int (Int.repr 2) tint) tint) tfloat))
              Sbreak)
            (LScons (Some 11)
              (Ssequence
                (Ssequence
                  (Scall (Some _t'2)
                    (Evar _scale_shadow_with_distance (Tfunction
                                                        (tfloat :: tfloat ::
                                                         nil) tfloat
                                                        cc_default))
                    ((Etempvar _shadowScale tshort) ::
                     (Etempvar _distFromShadow tfloat) :: nil))
                  (Sset _shadowRadius
                    (Ecast
                      (Ebinop Odiv (Etempvar _t'2 tfloat)
                        (Econst_float (Float.of_bits (Int64.repr 4611686018427387904)) tdouble)
                        tdouble) tfloat)))
                Sbreak)
              (LScons (Some 12)
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'3)
                      (Evar _disable_shadow_with_distance (Tfunction
                                                            (tfloat ::
                                                             tfloat :: nil)
                                                            tfloat
                                                            cc_default))
                      ((Etempvar _shadowScale tshort) ::
                       (Etempvar _distFromShadow tfloat) :: nil))
                    (Sset _shadowRadius
                      (Ecast
                        (Ebinop Odiv (Etempvar _t'3 tfloat)
                          (Econst_float (Float.of_bits (Int64.repr 4611686018427387904)) tdouble)
                          tdouble) tfloat)))
                  Sbreak)
                (LScons None
                  (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint)
                                   (tptr tvoid))))
                  LSnil)))))
        (Ssequence
          (Ssequence
            (Sset _t'5 (Evar _solidity tuchar))
            (Scall (Some _t'4)
              (Evar _create_shadow_rectangle (Tfunction
                                               (tfloat :: tfloat :: tfloat ::
                                                tuchar :: nil)
                                               (tptr (Tunion __206 noattr))
                                               cc_default))
              ((Etempvar _shadowRadius tfloat) ::
               (Etempvar _shadowRadius tfloat) ::
               (Eunop Oneg (Etempvar _distFromShadow tfloat) tfloat) ::
               (Etempvar _t'5 tuchar) :: nil)))
          (Sreturn (Some (Etempvar _t'4 (tptr (Tunion __206 noattr))))))))))
|}.

Definition f_create_shadow_hardcoded_rectangle := {|
  fn_return := (tptr (Tunion __206 noattr));
  fn_callconv := cc_default;
  fn_params := ((_xPos, tfloat) :: (_yPos, tfloat) :: (_zPos, tfloat) ::
                (_shadowScale, tshort) :: (_solidity, tuchar) ::
                (_shadowType, tschar) :: nil);
  fn_vars := ((_solidity, tuchar) :: (_shadowHeight, tfloat) :: nil);
  fn_temps := ((_distFromShadow, tfloat) :: (_halfWidth, tfloat) ::
               (_halfLength, tfloat) :: (_idx, tschar) ::
               (_t'4, (tptr (Tunion __206 noattr))) :: (_t'3, tfloat) ::
               (_t'2, tfloat) :: (_t'1, tint) :: (_t'9, tfloat) ::
               (_t'8, tfloat) :: (_t'7, tfloat) :: (_t'6, tschar) ::
               (_t'5, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _solidity tuchar) (Etempvar _solidity tuchar))
  (Ssequence
    (Sset _idx
      (Ecast
        (Ebinop Osub (Etempvar _shadowType tschar)
          (Econst_int (Int.repr 50) tint) tint) tschar))
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _get_shadow_height_solidity (Tfunction
                                              (tfloat :: tfloat :: tfloat ::
                                               (tptr tfloat) ::
                                               (tptr tuchar) :: nil) tint
                                              cc_default))
          ((Etempvar _xPos tfloat) :: (Etempvar _yPos tfloat) ::
           (Etempvar _zPos tfloat) ::
           (Eaddrof (Evar _shadowHeight tfloat) (tptr tfloat)) ::
           (Eaddrof (Evar _solidity tuchar) (tptr tuchar)) :: nil))
        (Sifthenelse (Ebinop One (Etempvar _t'1 tint)
                       (Econst_int (Int.repr 0) tint) tint)
          (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'9 (Evar _shadowHeight tfloat))
          (Sset _distFromShadow
            (Ebinop Osub (Etempvar _yPos tfloat) (Etempvar _t'9 tfloat)
              tfloat)))
        (Ssequence
          (Ssequence
            (Sset _t'6
              (Efield
                (Ederef
                  (Ebinop Oadd
                    (Evar _rectangles (tarray (Tstruct __2146 noattr) 2))
                    (Etempvar _idx tschar) (tptr (Tstruct __2146 noattr)))
                  (Tstruct __2146 noattr)) _scaleWithDistance tschar))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'6 tschar)
                           (Econst_int (Int.repr 1) tint) tint)
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'8
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Evar _rectangles (tarray (Tstruct __2146 noattr) 2))
                            (Etempvar _idx tschar)
                            (tptr (Tstruct __2146 noattr)))
                          (Tstruct __2146 noattr)) _halfWidth tfloat))
                    (Scall (Some _t'2)
                      (Evar _scale_shadow_with_distance (Tfunction
                                                          (tfloat ::
                                                           tfloat :: nil)
                                                          tfloat cc_default))
                      ((Etempvar _t'8 tfloat) ::
                       (Etempvar _distFromShadow tfloat) :: nil)))
                  (Sset _halfWidth (Etempvar _t'2 tfloat)))
                (Ssequence
                  (Ssequence
                    (Sset _t'7
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Evar _rectangles (tarray (Tstruct __2146 noattr) 2))
                            (Etempvar _idx tschar)
                            (tptr (Tstruct __2146 noattr)))
                          (Tstruct __2146 noattr)) _halfLength tfloat))
                    (Scall (Some _t'3)
                      (Evar _scale_shadow_with_distance (Tfunction
                                                          (tfloat ::
                                                           tfloat :: nil)
                                                          tfloat cc_default))
                      ((Etempvar _t'7 tfloat) ::
                       (Etempvar _distFromShadow tfloat) :: nil)))
                  (Sset _halfLength (Etempvar _t'3 tfloat))))
              (Ssequence
                (Sset _halfWidth
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Evar _rectangles (tarray (Tstruct __2146 noattr) 2))
                        (Etempvar _idx tschar)
                        (tptr (Tstruct __2146 noattr)))
                      (Tstruct __2146 noattr)) _halfWidth tfloat))
                (Sset _halfLength
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Evar _rectangles (tarray (Tstruct __2146 noattr) 2))
                        (Etempvar _idx tschar)
                        (tptr (Tstruct __2146 noattr)))
                      (Tstruct __2146 noattr)) _halfLength tfloat)))))
          (Ssequence
            (Ssequence
              (Sset _t'5 (Evar _solidity tuchar))
              (Scall (Some _t'4)
                (Evar _create_shadow_rectangle (Tfunction
                                                 (tfloat :: tfloat ::
                                                  tfloat :: tuchar :: nil)
                                                 (tptr (Tunion __206 noattr))
                                                 cc_default))
                ((Etempvar _halfWidth tfloat) ::
                 (Etempvar _halfLength tfloat) ::
                 (Eunop Oneg (Etempvar _distFromShadow tfloat) tfloat) ::
                 (Etempvar _t'5 tuchar) :: nil)))
            (Sreturn (Some (Etempvar _t'4 (tptr (Tunion __206 noattr)))))))))))
|}.

Definition f_create_shadow_below_xyz := {|
  fn_return := (tptr (Tunion __206 noattr));
  fn_callconv := cc_default;
  fn_params := ((_xPos, tfloat) :: (_yPos, tfloat) :: (_zPos, tfloat) ::
                (_shadowScale, tshort) :: (_shadowSolidity, tuchar) ::
                (_shadowType, tschar) :: nil);
  fn_vars := ((_pfloor, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_temps := ((_displayList, (tptr (Tunion __206 noattr))) ::
               (_t'8, (tptr (Tunion __206 noattr))) ::
               (_t'7, (tptr (Tunion __206 noattr))) ::
               (_t'6, (tptr (Tunion __206 noattr))) ::
               (_t'5, (tptr (Tunion __206 noattr))) ::
               (_t'4, (tptr (Tunion __206 noattr))) ::
               (_t'3, (tptr (Tunion __206 noattr))) ::
               (_t'2, (tptr (Tunion __206 noattr))) ::
               (_t'1, (tptr (Tunion __206 noattr))) :: (_t'13, tshort) ::
               (_t'12, (tptr (Tstruct _Surface noattr))) ::
               (_t'11, tshort) ::
               (_t'10, (tptr (Tstruct _Surface noattr))) ::
               (_t'9, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _displayList (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Scall None
      (Evar _find_floor (Tfunction
                          (tfloat :: tfloat :: tfloat ::
                           (tptr (tptr (Tstruct _Surface noattr))) :: nil)
                          tfloat cc_default))
      ((Etempvar _xPos tfloat) :: (Etempvar _yPos tfloat) ::
       (Etempvar _zPos tfloat) ::
       (Eaddrof (Evar _pfloor (tptr (Tstruct _Surface noattr)))
         (tptr (tptr (Tstruct _Surface noattr)))) :: nil))
    (Ssequence
      (Sassign (Evar _gShadowAboveWaterOrLava tschar)
        (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Sassign (Evar _gMarioOnIceOrCarpet tschar)
          (Econst_int (Int.repr 0) tint))
        (Ssequence
          (Sassign (Evar _sMarioOnFlyingCarpet tschar)
            (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Ssequence
              (Sset _t'9 (Evar _pfloor (tptr (Tstruct _Surface noattr))))
              (Sifthenelse (Ebinop One
                             (Etempvar _t'9 (tptr (Tstruct _Surface noattr)))
                             (Ecast (Econst_int (Int.repr 0) tint)
                               (tptr tvoid)) tint)
                (Ssequence
                  (Ssequence
                    (Sset _t'12
                      (Evar _pfloor (tptr (Tstruct _Surface noattr))))
                    (Ssequence
                      (Sset _t'13
                        (Efield
                          (Ederef
                            (Etempvar _t'12 (tptr (Tstruct _Surface noattr)))
                            (Tstruct _Surface noattr)) _type tshort))
                      (Sifthenelse (Ebinop Oeq (Etempvar _t'13 tshort)
                                     (Econst_int (Int.repr 46) tint) tint)
                        (Sassign (Evar _gMarioOnIceOrCarpet tschar)
                          (Econst_int (Int.repr 1) tint))
                        Sskip)))
                  (Ssequence
                    (Sset _t'10
                      (Evar _pfloor (tptr (Tstruct _Surface noattr))))
                    (Ssequence
                      (Sset _t'11
                        (Efield
                          (Ederef
                            (Etempvar _t'10 (tptr (Tstruct _Surface noattr)))
                            (Tstruct _Surface noattr)) _type tshort))
                      (Sassign (Evar _sSurfaceTypeBelowShadow tshort)
                        (Etempvar _t'11 tshort)))))
                Sskip))
            (Ssequence
              (Sswitch (Etempvar _shadowType tschar)
                (LScons (Some 0)
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'1)
                        (Evar _create_shadow_circle_9_verts (Tfunction
                                                              (tfloat ::
                                                               tfloat ::
                                                               tfloat ::
                                                               tshort ::
                                                               tuchar :: nil)
                                                              (tptr (Tunion __206 noattr))
                                                              cc_default))
                        ((Etempvar _xPos tfloat) ::
                         (Etempvar _yPos tfloat) ::
                         (Etempvar _zPos tfloat) ::
                         (Etempvar _shadowScale tshort) ::
                         (Etempvar _shadowSolidity tuchar) :: nil))
                      (Sset _displayList
                        (Etempvar _t'1 (tptr (Tunion __206 noattr)))))
                    Sbreak)
                  (LScons (Some 1)
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'2)
                          (Evar _create_shadow_circle_4_verts (Tfunction
                                                                (tfloat ::
                                                                 tfloat ::
                                                                 tfloat ::
                                                                 tshort ::
                                                                 tuchar ::
                                                                 nil)
                                                                (tptr (Tunion __206 noattr))
                                                                cc_default))
                          ((Etempvar _xPos tfloat) ::
                           (Etempvar _yPos tfloat) ::
                           (Etempvar _zPos tfloat) ::
                           (Etempvar _shadowScale tshort) ::
                           (Etempvar _shadowSolidity tuchar) :: nil))
                        (Sset _displayList
                          (Etempvar _t'2 (tptr (Tunion __206 noattr)))))
                      Sbreak)
                    (LScons (Some 2)
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'3)
                            (Evar _create_shadow_circle_assuming_flat_ground 
                            (Tfunction
                              (tfloat :: tfloat :: tfloat :: tshort ::
                               tuchar :: nil) (tptr (Tunion __206 noattr))
                              cc_default))
                            ((Etempvar _xPos tfloat) ::
                             (Etempvar _yPos tfloat) ::
                             (Etempvar _zPos tfloat) ::
                             (Etempvar _shadowScale tshort) ::
                             (Etempvar _shadowSolidity tuchar) :: nil))
                          (Sset _displayList
                            (Etempvar _t'3 (tptr (Tunion __206 noattr)))))
                        Sbreak)
                      (LScons (Some 10)
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'4)
                              (Evar _create_shadow_square (Tfunction
                                                            (tfloat ::
                                                             tfloat ::
                                                             tfloat ::
                                                             tshort ::
                                                             tuchar ::
                                                             tschar :: nil)
                                                            (tptr (Tunion __206 noattr))
                                                            cc_default))
                              ((Etempvar _xPos tfloat) ::
                               (Etempvar _yPos tfloat) ::
                               (Etempvar _zPos tfloat) ::
                               (Etempvar _shadowScale tshort) ::
                               (Etempvar _shadowSolidity tuchar) ::
                               (Etempvar _shadowType tschar) :: nil))
                            (Sset _displayList
                              (Etempvar _t'4 (tptr (Tunion __206 noattr)))))
                          Sbreak)
                        (LScons (Some 11)
                          (Ssequence
                            (Ssequence
                              (Scall (Some _t'5)
                                (Evar _create_shadow_square (Tfunction
                                                              (tfloat ::
                                                               tfloat ::
                                                               tfloat ::
                                                               tshort ::
                                                               tuchar ::
                                                               tschar :: nil)
                                                              (tptr (Tunion __206 noattr))
                                                              cc_default))
                                ((Etempvar _xPos tfloat) ::
                                 (Etempvar _yPos tfloat) ::
                                 (Etempvar _zPos tfloat) ::
                                 (Etempvar _shadowScale tshort) ::
                                 (Etempvar _shadowSolidity tuchar) ::
                                 (Etempvar _shadowType tschar) :: nil))
                              (Sset _displayList
                                (Etempvar _t'5 (tptr (Tunion __206 noattr)))))
                            Sbreak)
                          (LScons (Some 12)
                            (Ssequence
                              (Ssequence
                                (Scall (Some _t'6)
                                  (Evar _create_shadow_square (Tfunction
                                                                (tfloat ::
                                                                 tfloat ::
                                                                 tfloat ::
                                                                 tshort ::
                                                                 tuchar ::
                                                                 tschar ::
                                                                 nil)
                                                                (tptr (Tunion __206 noattr))
                                                                cc_default))
                                  ((Etempvar _xPos tfloat) ::
                                   (Etempvar _yPos tfloat) ::
                                   (Etempvar _zPos tfloat) ::
                                   (Etempvar _shadowScale tshort) ::
                                   (Etempvar _shadowSolidity tuchar) ::
                                   (Etempvar _shadowType tschar) :: nil))
                                (Sset _displayList
                                  (Etempvar _t'6 (tptr (Tunion __206 noattr)))))
                              Sbreak)
                            (LScons (Some 99)
                              (Ssequence
                                (Ssequence
                                  (Scall (Some _t'7)
                                    (Evar _create_shadow_player (Tfunction
                                                                  (tfloat ::
                                                                   tfloat ::
                                                                   tfloat ::
                                                                   tshort ::
                                                                   tuchar ::
                                                                   tint ::
                                                                   nil)
                                                                  (tptr (Tunion __206 noattr))
                                                                  cc_default))
                                    ((Etempvar _xPos tfloat) ::
                                     (Etempvar _yPos tfloat) ::
                                     (Etempvar _zPos tfloat) ::
                                     (Etempvar _shadowScale tshort) ::
                                     (Etempvar _shadowSolidity tuchar) ::
                                     (Econst_int (Int.repr 0) tint) :: nil))
                                  (Sset _displayList
                                    (Etempvar _t'7 (tptr (Tunion __206 noattr)))))
                                Sbreak)
                              (LScons None
                                (Ssequence
                                  (Ssequence
                                    (Scall (Some _t'8)
                                      (Evar _create_shadow_hardcoded_rectangle 
                                      (Tfunction
                                        (tfloat :: tfloat :: tfloat ::
                                         tshort :: tuchar :: tschar :: nil)
                                        (tptr (Tunion __206 noattr))
                                        cc_default))
                                      ((Etempvar _xPos tfloat) ::
                                       (Etempvar _yPos tfloat) ::
                                       (Etempvar _zPos tfloat) ::
                                       (Etempvar _shadowScale tshort) ::
                                       (Etempvar _shadowSolidity tuchar) ::
                                       (Etempvar _shadowType tschar) :: nil))
                                    (Sset _displayList
                                      (Etempvar _t'8 (tptr (Tunion __206 noattr)))))
                                  Sbreak)
                                LSnil)))))))))
              (Sreturn (Some (Etempvar _displayList (tptr (Tunion __206 noattr))))))))))))
|}.

Definition composites : list composite_definition :=
(Composite __116 Struct
   (Member_plain _ob (tarray tshort 3) :: Member_plain _flag tushort ::
    Member_plain _tc (tarray tshort 2) ::
    Member_plain _cn (tarray tuchar 4) :: nil)
   noattr ::
 Composite __118 Struct
   (Member_plain _ob (tarray tshort 3) :: Member_plain _flag tushort ::
    Member_plain _tc (tarray tshort 2) ::
    Member_plain _n (tarray tschar 3) :: Member_plain _a tuchar :: nil)
   noattr ::
 Composite __120 Union
   (Member_plain _v (Tstruct __116 noattr) ::
    Member_plain _n (Tstruct __118 noattr) ::
    Member_plain _force_structure_alignment tlong :: nil)
   noattr ::
 Composite __204 Struct
   (Member_plain _w0 tuint :: Member_plain _w1 tuint :: nil)
   noattr ::
 Composite __206 Union
   (Member_plain _words (Tstruct __204 noattr) ::
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
 Composite _FloorGeometry Struct
   (Member_plain _filler (tarray tuchar 16) ::
    Member_plain _normalX tfloat :: Member_plain _normalY tfloat ::
    Member_plain _normalZ tfloat :: Member_plain _originOffset tfloat :: nil)
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
 Composite _Shadow Struct
   (Member_plain _parentX tfloat :: Member_plain _parentY tfloat ::
    Member_plain _parentZ tfloat :: Member_plain _floorHeight tfloat ::
    Member_plain _shadowScale tfloat :: Member_plain _floorNormalX tfloat ::
    Member_plain _floorNormalY tfloat :: Member_plain _floorNormalZ tfloat ::
    Member_plain _floorOriginOffset tfloat ::
    Member_plain _floorDownwardAngle tfloat ::
    Member_plain _floorTilt tfloat :: Member_plain _solidity tuchar :: nil)
   noattr ::
 Composite __2146 Struct
   (Member_plain _halfWidth tfloat :: Member_plain _halfLength tfloat ::
    Member_plain _scaleWithDistance tschar :: nil)
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
 (_sinf,
   Gfun(External (EF_external "sinf"
                   (mksignature (AST.Xsingle :: nil) AST.Xsingle cc_default))
     (tfloat :: nil) tfloat cc_default)) ::
 (_cosf,
   Gfun(External (EF_external "cosf"
                   (mksignature (AST.Xsingle :: nil) AST.Xsingle cc_default))
     (tfloat :: nil) tfloat cc_default)) ::
 (_sqrtf,
   Gfun(External (EF_external "sqrtf"
                   (mksignature (AST.Xsingle :: nil) AST.Xsingle cc_default))
     (tfloat :: nil) tfloat cc_default)) ::
 (_gSineTable, Gvar v_gSineTable) ::
 (_atan2s,
   Gfun(External (EF_external "atan2s"
                   (mksignature (AST.Xsingle :: AST.Xsingle :: nil)
                     AST.Xint16signed cc_default)) (tfloat :: tfloat :: nil)
     tshort cc_default)) ::
 (_find_floor_height_and_data,
   Gfun(External (EF_external "find_floor_height_and_data"
                   (mksignature
                     (AST.Xsingle :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xptr :: nil) AST.Xsingle cc_default))
     (tfloat :: tfloat :: tfloat ::
      (tptr (tptr (Tstruct _FloorGeometry noattr))) :: nil) tfloat
     cc_default)) ::
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
 (_gFlyingCarpetState, Gvar v_gFlyingCarpetState) ::
 (_make_vertex,
   Gfun(External (EF_external "make_vertex"
                   (mksignature
                     (AST.Xptr :: AST.Xint :: AST.Xint16signed ::
                      AST.Xint16signed :: AST.Xint16signed ::
                      AST.Xint16signed :: AST.Xint16signed ::
                      AST.Xint8unsigned :: AST.Xint8unsigned ::
                      AST.Xint8unsigned :: AST.Xint8unsigned :: nil)
                     AST.Xvoid cc_default))
     ((tptr (Tunion __120 noattr)) :: tint :: tshort :: tshort :: tshort ::
      tshort :: tshort :: tuchar :: tuchar :: tuchar :: tuchar :: nil) tvoid
     cc_default)) ::
 (_round_float,
   Gfun(External (EF_external "round_float"
                   (mksignature (AST.Xsingle :: nil) AST.Xint16signed
                     cc_default)) (tfloat :: nil) tshort cc_default)) ::
 (_alloc_display_list,
   Gfun(External (EF_external "alloc_display_list"
                   (mksignature (AST.Xint :: nil) AST.Xptr cc_default))
     (tuint :: nil) (tptr tvoid) cc_default)) ::
 (_gCurrAreaIndex, Gvar v_gCurrAreaIndex) ::
 (_gCurrLevelNum, Gvar v_gCurrLevelNum) ::
 (_gMarioObject, Gvar v_gMarioObject) ::
 (_gLuigiObject, Gvar v_gLuigiObject) ::
 (_gEnvironmentRegions, Gvar v_gEnvironmentRegions) ::
 (_gCurGraphNodeObject, Gvar v_gCurGraphNodeObject) ::
 (_dl_shadow_circle, Gvar v_dl_shadow_circle) ::
 (_dl_shadow_square, Gvar v_dl_shadow_square) ::
 (_dl_shadow_9_verts, Gvar v_dl_shadow_9_verts) ::
 (_dl_shadow_4_verts, Gvar v_dl_shadow_4_verts) ::
 (_dl_shadow_end, Gvar v_dl_shadow_end) ::
 (_rectangles, Gvar v_rectangles) ::
 (_gShadowAboveWaterOrLava, Gvar v_gShadowAboveWaterOrLava) ::
 (_gMarioOnIceOrCarpet, Gvar v_gMarioOnIceOrCarpet) ::
 (_sMarioOnFlyingCarpet, Gvar v_sMarioOnFlyingCarpet) ::
 (_sSurfaceTypeBelowShadow, Gvar v_sSurfaceTypeBelowShadow) ::
 (_rotate_rectangle, Gfun(Internal f_rotate_rectangle)) ::
 (_atan2_deg, Gfun(Internal f_atan2_deg)) ::
 (_scale_shadow_with_distance, Gfun(Internal f_scale_shadow_with_distance)) ::
 (_disable_shadow_with_distance, Gfun(Internal f_disable_shadow_with_distance)) ::
 (_dim_shadow_with_distance, Gfun(Internal f_dim_shadow_with_distance)) ::
 (_get_water_level_below_shadow, Gfun(Internal f_get_water_level_below_shadow)) ::
 (_init_shadow, Gfun(Internal f_init_shadow)) ::
 (_get_texture_coords_9_vertices, Gfun(Internal f_get_texture_coords_9_vertices)) ::
 (_get_texture_coords_4_vertices, Gfun(Internal f_get_texture_coords_4_vertices)) ::
 (_make_shadow_vertex_at_xyz, Gfun(Internal f_make_shadow_vertex_at_xyz)) ::
 (_extrapolate_vertex_y_position, Gfun(Internal f_extrapolate_vertex_y_position)) ::
 (_get_vertex_coords, Gfun(Internal f_get_vertex_coords)) ::
 (_calculate_vertex_xyz, Gfun(Internal f_calculate_vertex_xyz)) ::
 (_floor_local_tilt, Gfun(Internal f_floor_local_tilt)) ::
 (_make_shadow_vertex, Gfun(Internal f_make_shadow_vertex)) ::
 (_add_shadow_to_display_list, Gfun(Internal f_add_shadow_to_display_list)) ::
 (_linearly_interpolate_solidity_positive, Gfun(Internal f_linearly_interpolate_solidity_positive)) ::
 (_linearly_interpolate_solidity_negative, Gfun(Internal f_linearly_interpolate_solidity_negative)) ::
 (_correct_shadow_solidity_for_animations, Gfun(Internal f_correct_shadow_solidity_for_animations)) ::
 (_correct_lava_shadow_height, Gfun(Internal f_correct_lava_shadow_height)) ::
 (_create_shadow_player, Gfun(Internal f_create_shadow_player)) ::
 (_create_shadow_circle_9_verts, Gfun(Internal f_create_shadow_circle_9_verts)) ::
 (_create_shadow_circle_4_verts, Gfun(Internal f_create_shadow_circle_4_verts)) ::
 (_create_shadow_circle_assuming_flat_ground, Gfun(Internal f_create_shadow_circle_assuming_flat_ground)) ::
 (_create_shadow_rectangle, Gfun(Internal f_create_shadow_rectangle)) ::
 (_get_shadow_height_solidity, Gfun(Internal f_get_shadow_height_solidity)) ::
 (_create_shadow_square, Gfun(Internal f_create_shadow_square)) ::
 (_create_shadow_hardcoded_rectangle, Gfun(Internal f_create_shadow_hardcoded_rectangle)) ::
 (_create_shadow_below_xyz, Gfun(Internal f_create_shadow_below_xyz)) :: nil).

Definition public_idents : list ident :=
(_create_shadow_below_xyz :: _create_shadow_hardcoded_rectangle ::
 _create_shadow_square :: _get_shadow_height_solidity ::
 _create_shadow_rectangle :: _create_shadow_circle_assuming_flat_ground ::
 _create_shadow_circle_4_verts :: _create_shadow_circle_9_verts ::
 _create_shadow_player :: _correct_lava_shadow_height ::
 _correct_shadow_solidity_for_animations ::
 _linearly_interpolate_solidity_negative ::
 _linearly_interpolate_solidity_positive :: _add_shadow_to_display_list ::
 _make_shadow_vertex :: _floor_local_tilt :: _calculate_vertex_xyz ::
 _get_vertex_coords :: _extrapolate_vertex_y_position ::
 _make_shadow_vertex_at_xyz :: _get_texture_coords_4_vertices ::
 _get_texture_coords_9_vertices :: _init_shadow ::
 _get_water_level_below_shadow :: _dim_shadow_with_distance ::
 _disable_shadow_with_distance :: _scale_shadow_with_distance ::
 _atan2_deg :: _rotate_rectangle :: _sSurfaceTypeBelowShadow ::
 _sMarioOnFlyingCarpet :: _gMarioOnIceOrCarpet :: _gShadowAboveWaterOrLava ::
 _rectangles :: _dl_shadow_end :: _dl_shadow_4_verts :: _dl_shadow_9_verts ::
 _dl_shadow_square :: _dl_shadow_circle :: _gCurGraphNodeObject ::
 _gEnvironmentRegions :: _gLuigiObject :: _gMarioObject :: _gCurrLevelNum ::
 _gCurrAreaIndex :: _alloc_display_list :: _round_float :: _make_vertex ::
 _gFlyingCarpetState :: _find_water_level :: _find_floor ::
 _find_floor_height_and_data :: _atan2s :: _gSineTable :: _sqrtf :: _cosf ::
 _sinf :: ___builtin_debug :: ___builtin_write32_reversed ::
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


