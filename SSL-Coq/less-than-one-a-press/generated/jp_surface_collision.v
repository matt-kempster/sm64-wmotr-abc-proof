(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_JP
   Source:          src/engine/surface_collision.c
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
  Definition source_file := "build/pinned-sm64/src/engine/surface_collision.c".
  Definition normalized := true.
End Info.

Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _Area : ident := $"Area".
Definition _Camera : ident := $"Camera".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _Controller : ident := $"Controller".
Definition _DmaHandlerList : ident := $"DmaHandlerList".
Definition _DmaTable : ident := $"DmaTable".
Definition _FloorGeometry : ident := $"FloorGeometry".
Definition _GraphNode : ident := $"GraphNode".
Definition _GraphNodeObject : ident := $"GraphNodeObject".
Definition _GraphNodeRoot : ident := $"GraphNodeRoot".
Definition _InstantWarp : ident := $"InstantWarp".
Definition _MarioBodyState : ident := $"MarioBodyState".
Definition _MarioState : ident := $"MarioState".
Definition _NumTimesCalled : ident := $"NumTimesCalled".
Definition _Object : ident := $"Object".
Definition _ObjectNode : ident := $"ObjectNode".
Definition _ObjectWarpNode : ident := $"ObjectWarpNode".
Definition _OffsetSizePair : ident := $"OffsetSizePair".
Definition _PlayerCameraState : ident := $"PlayerCameraState".
Definition _SpawnInfo : ident := $"SpawnInfo".
Definition _Surface : ident := $"Surface".
Definition _SurfaceNode : ident := $"SurfaceNode".
Definition _UnusedArea28 : ident := $"UnusedArea28".
Definition _WallCollisionData : ident := $"WallCollisionData".
Definition _WarpNode : ident := $"WarpNode".
Definition _Waypoint : ident := $"Waypoint".
Definition _Whirlpool : ident := $"Whirlpool".
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
Definition ___stringlit_2 : ident := $"__stringlit_2".
Definition ___stringlit_3 : ident := $"__stringlit_3".
Definition ___stringlit_4 : ident := $"__stringlit_4".
Definition ___stringlit_5 : ident := $"__stringlit_5".
Definition ___stringlit_6 : ident := $"__stringlit_6".
Definition ___stringlit_7 : ident := $"__stringlit_7".
Definition ___stringlit_8 : ident := $"__stringlit_8".
Definition _action : ident := $"action".
Definition _actionArg : ident := $"actionArg".
Definition _actionState : ident := $"actionState".
Definition _actionTimer : ident := $"actionTimer".
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _angle : ident := $"angle".
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
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _bufTarget : ident := $"bufTarget".
Definition _button : ident := $"button".
Definition _buttonDown : ident := $"buttonDown".
Definition _buttonPressed : ident := $"buttonPressed".
Definition _camera : ident := $"camera".
Definition _cameraEvent : ident := $"cameraEvent".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _capState : ident := $"capState".
Definition _capTimer : ident := $"capTimer".
Definition _ceil : ident := $"ceil".
Definition _ceilHeight : ident := $"ceilHeight".
Definition _cellX : ident := $"cellX".
Definition _cellZ : ident := $"cellZ".
Definition _checkCeil : ident := $"checkCeil".
Definition _children : ident := $"children".
Definition _colData : ident := $"colData".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collision : ident := $"collision".
Definition _collisionData : ident := $"collisionData".
Definition _controller : ident := $"controller".
Definition _controllerData : ident := $"controllerData".
Definition _count : ident := $"count".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _currentAddr : ident := $"currentAddr".
Definition _cutscene : ident := $"cutscene".
Definition _data : ident := $"data".
Definition _debug_surface_list_info : ident := $"debug_surface_list_info".
Definition _defMode : ident := $"defMode".
Definition _destArea : ident := $"destArea".
Definition _destLevel : ident := $"destLevel".
Definition _destNode : ident := $"destNode".
Definition _dialog : ident := $"dialog".
Definition _displacement : ident := $"displacement".
Definition _distance : ident := $"distance".
Definition _dmaTable : ident := $"dmaTable".
Definition _doorStatus : ident := $"doorStatus".
Definition _doubleJumpTimer : ident := $"doubleJumpTimer".
Definition _dynamicCeil : ident := $"dynamicCeil".
Definition _dynamicFloor : ident := $"dynamicFloor".
Definition _dynamicHeight : ident := $"dynamicHeight".
Definition _errnum : ident := $"errnum".
Definition _eyeState : ident := $"eyeState".
Definition _f32_find_wall_collision : ident := $"f32_find_wall_collision".
Definition _faceAngle : ident := $"faceAngle".
Definition _fadeWarpOpacity : ident := $"fadeWarpOpacity".
Definition _filler : ident := $"filler".
Definition _filler1 : ident := $"filler1".
Definition _filler2 : ident := $"filler2".
Definition _find_ceil : ident := $"find_ceil".
Definition _find_ceil_from_list : ident := $"find_ceil_from_list".
Definition _find_floor : ident := $"find_floor".
Definition _find_floor_from_list : ident := $"find_floor_from_list".
Definition _find_floor_height : ident := $"find_floor_height".
Definition _find_floor_height_and_data : ident := $"find_floor_height_and_data".
Definition _find_poison_gas_level : ident := $"find_poison_gas_level".
Definition _find_wall_collisions : ident := $"find_wall_collisions".
Definition _find_wall_collisions_from_list : ident := $"find_wall_collisions_from_list".
Definition _find_water_level : ident := $"find_water_level".
Definition _flags : ident := $"flags".
Definition _floor : ident := $"floor".
Definition _floorAngle : ident := $"floorAngle".
Definition _floorGeo : ident := $"floorGeo".
Definition _floorHeight : ident := $"floorHeight".
Definition _focus : ident := $"focus".
Definition _force : ident := $"force".
Definition _forwardVel : ident := $"forwardVel".
Definition _framesSinceA : ident := $"framesSinceA".
Definition _framesSinceB : ident := $"framesSinceB".
Definition _gCheckingSurfaceCollisionsForCamera : ident := $"gCheckingSurfaceCollisionsForCamera".
Definition _gCurrentObject : ident := $"gCurrentObject".
Definition _gDynamicSurfacePartition : ident := $"gDynamicSurfacePartition".
Definition _gEnvironmentRegions : ident := $"gEnvironmentRegions".
Definition _gFindFloorIncludeSurfaceIntangible : ident := $"gFindFloorIncludeSurfaceIntangible".
Definition _gMarioObject : ident := $"gMarioObject".
Definition _gMarioState : ident := $"gMarioState".
Definition _gNumCalls : ident := $"gNumCalls".
Definition _gNumFindFloorMisses : ident := $"gNumFindFloorMisses".
Definition _gNumStaticSurfaces : ident := $"gNumStaticSurfaces".
Definition _gStaticSurfacePartition : ident := $"gStaticSurfacePartition".
Definition _gSurfaceNodesAllocated : ident := $"gSurfaceNodesAllocated".
Definition _gSurfacesAllocated : ident := $"gSurfacesAllocated".
Definition _gasLevel : ident := $"gasLevel".
Definition _gettingBlownGravity : ident := $"gettingBlownGravity".
Definition _gfx : ident := $"gfx".
Definition _grabPos : ident := $"grabPos".
Definition _handState : ident := $"handState".
Definition _headAngle : ident := $"headAngle".
Definition _headRotation : ident := $"headRotation".
Definition _header : ident := $"header".
Definition _healCounter : ident := $"healCounter".
Definition _health : ident := $"health".
Definition _height : ident := $"height".
Definition _heldObj : ident := $"heldObj".
Definition _heldObjLastPosition : ident := $"heldObjLastPosition".
Definition _hiX : ident := $"hiX".
Definition _hiZ : ident := $"hiZ".
Definition _hitboxDownOffset : ident := $"hitboxDownOffset".
Definition _hitboxHeight : ident := $"hitboxHeight".
Definition _hitboxRadius : ident := $"hitboxRadius".
Definition _hurtCounter : ident := $"hurtCounter".
Definition _hurtboxHeight : ident := $"hurtboxHeight".
Definition _hurtboxRadius : ident := $"hurtboxRadius".
Definition _i : ident := $"i".
Definition _id : ident := $"id".
Definition _index : ident := $"index".
Definition _input : ident := $"input".
Definition _instantWarps : ident := $"instantWarps".
Definition _intendedMag : ident := $"intendedMag".
Definition _intendedYaw : ident := $"intendedYaw".
Definition _interactObj : ident := $"interactObj".
Definition _invincTimer : ident := $"invincTimer".
Definition _length : ident := $"length".
Definition _list : ident := $"list".
Definition _loX : ident := $"loX".
Definition _loZ : ident := $"loZ".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _macroObjects : ident := $"macroObjects".
Definition _main : ident := $"main".
Definition _marioBodyState : ident := $"marioBodyState".
Definition _marioObj : ident := $"marioObj".
Definition _mode : ident := $"mode".
Definition _model : ident := $"model".
Definition _modelState : ident := $"modelState".
Definition _musicParam : ident := $"musicParam".
Definition _musicParam2 : ident := $"musicParam2".
Definition _next : ident := $"next".
Definition _nextYaw : ident := $"nextYaw".
Definition _node : ident := $"node".
Definition _normal : ident := $"normal".
Definition _normalX : ident := $"normalX".
Definition _normalY : ident := $"normalY".
Definition _normalZ : ident := $"normalZ".
Definition _numCeils : ident := $"numCeils".
Definition _numCoins : ident := $"numCoins".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _numCollisions : ident := $"numCollisions".
Definition _numCols : ident := $"numCols".
Definition _numFloors : ident := $"numFloors".
Definition _numKeys : ident := $"numKeys".
Definition _numLives : ident := $"numLives".
Definition _numRegions : ident := $"numRegions".
Definition _numStars : ident := $"numStars".
Definition _numViews : ident := $"numViews".
Definition _numWalls : ident := $"numWalls".
Definition _nx : ident := $"nx".
Definition _ny : ident := $"ny".
Definition _nz : ident := $"nz".
Definition _obj : ident := $"obj".
Definition _object : ident := $"object".
Definition _objectSpawnInfos : ident := $"objectSpawnInfos".
Definition _offset : ident := $"offset".
Definition _offsetY : ident := $"offsetY".
Definition _oo : ident := $"oo".
Definition _originOffset : ident := $"originOffset".
Definition _p : ident := $"p".
Definition _paintingWarpNodes : ident := $"paintingWarpNodes".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _particleFlags : ident := $"particleFlags".
Definition _pceil : ident := $"pceil".
Definition _peakHeight : ident := $"peakHeight".
Definition _pfloor : ident := $"pfloor".
Definition _pheight : ident := $"pheight".
Definition _platform : ident := $"platform".
Definition _pos : ident := $"pos".
Definition _posX : ident := $"posX".
Definition _posY : ident := $"posY".
Definition _posZ : ident := $"posZ".
Definition _prev : ident := $"prev".
Definition _prevAction : ident := $"prevAction".
Definition _prevNumStarsForDialog : ident := $"prevNumStarsForDialog".
Definition _prevObj : ident := $"prevObj".
Definition _print_debug_top_down_mapinfo : ident := $"print_debug_top_down_mapinfo".
Definition _psurface : ident := $"psurface".
Definition _punchState : ident := $"punchState".
Definition _px : ident := $"px".
Definition _py : ident := $"py".
Definition _pz : ident := $"pz".
Definition _quicksandDepth : ident := $"quicksandDepth".
Definition _radius : ident := $"radius".
Definition _rawData : ident := $"rawData".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _riddenObj : ident := $"riddenObj".
Definition _room : ident := $"room".
Definition _sFloorGeo : ident := $"sFloorGeo".
Definition _scale : ident := $"scale".
Definition _set_text_array_x_y : ident := $"set_text_array_x_y".
Definition _sharedChild : ident := $"sharedChild".
Definition _size : ident := $"size".
Definition _slideVelX : ident := $"slideVelX".
Definition _slideVelZ : ident := $"slideVelZ".
Definition _slideYaw : ident := $"slideYaw".
Definition _spawnInfo : ident := $"spawnInfo".
Definition _squishTimer : ident := $"squishTimer".
Definition _srcAddr : ident := $"srcAddr".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
Definition _status : ident := $"status".
Definition _statusData : ident := $"statusData".
Definition _statusForCamera : ident := $"statusForCamera".
Definition _stickMag : ident := $"stickMag".
Definition _stickX : ident := $"stickX".
Definition _stickY : ident := $"stickY".
Definition _stick_x : ident := $"stick_x".
Definition _stick_y : ident := $"stick_y".
Definition _strength : ident := $"strength".
Definition _surf : ident := $"surf".
Definition _surface : ident := $"surface".
Definition _surfaceHeight : ident := $"surfaceHeight".
Definition _surfaceList : ident := $"surfaceList".
Definition _surfaceNode : ident := $"surfaceNode".
Definition _surfaceRooms : ident := $"surfaceRooms".
Definition _surface_list_length : ident := $"surface_list_length".
Definition _terrainData : ident := $"terrainData".
Definition _terrainSoundAddend : ident := $"terrainSoundAddend".
Definition _terrainType : ident := $"terrainType".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _torsoAngle : ident := $"torsoAngle".
Definition _transform : ident := $"transform".
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
Definition _unused_find_dynamic_floor : ident := $"unused_find_dynamic_floor".
Definition _unused_obj_find_floor_height : ident := $"unused_obj_find_floor_height".
Definition _unused_resolve_floor_or_ceil_collisions : ident := $"unused_resolve_floor_or_ceil_collisions".
Definition _upperY : ident := $"upperY".
Definition _usedObj : ident := $"usedObj".
Definition _val : ident := $"val".
Definition _values : ident := $"values".
Definition _vel : ident := $"vel".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _views : ident := $"views".
Definition _w1 : ident := $"w1".
Definition _w2 : ident := $"w2".
Definition _w3 : ident := $"w3".
Definition _wall : ident := $"wall".
Definition _wallKickTimer : ident := $"wallKickTimer".
Definition _walls : ident := $"walls".
Definition _warpNodes : ident := $"warpNodes".
Definition _waterLevel : ident := $"waterLevel".
Definition _whirlpools : ident := $"whirlpools".
Definition _width : ident := $"width".
Definition _wingFlutter : ident := $"wingFlutter".
Definition _x : ident := $"x".
Definition _x1 : ident := $"x1".
Definition _x2 : ident := $"x2".
Definition _x3 : ident := $"x3".
Definition _xPos : ident := $"xPos".
Definition _xPtr : ident := $"xPtr".
Definition _y : ident := $"y".
Definition _y1 : ident := $"y1".
Definition _y2 : ident := $"y2".
Definition _y3 : ident := $"y3".
Definition _yPos : ident := $"yPos".
Definition _yPtr : ident := $"yPtr".
Definition _yaw : ident := $"yaw".
Definition _z : ident := $"z".
Definition _z1 : ident := $"z1".
Definition _z2 : ident := $"z2".
Definition _z3 : ident := $"z3".
Definition _zPos : ident := $"zPos".
Definition _zPtr : ident := $"zPtr".
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
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v___stringlit_4 := {|
  gvar_info := (tarray tuchar 6);
  gvar_init := (Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 114) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_6 := {|
  gvar_info := (tarray tuchar 10);
  gvar_init := (Init_int8 (Int.repr 108) :: Init_int8 (Int.repr 105) ::
                Init_int8 (Int.repr 115) :: Init_int8 (Int.repr 116) ::
                Init_int8 (Int.repr 97) :: Init_int8 (Int.repr 108) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_8 := {|
  gvar_info := (tarray tuchar 10);
  gvar_init := (Init_int8 (Int.repr 109) :: Init_int8 (Int.repr 111) ::
                Init_int8 (Int.repr 118) :: Init_int8 (Int.repr 101) ::
                Init_int8 (Int.repr 98) :: Init_int8 (Int.repr 103) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_1 := {|
  gvar_info := (tarray tuchar 10);
  gvar_init := (Init_int8 (Int.repr 97) :: Init_int8 (Int.repr 114) ::
                Init_int8 (Int.repr 101) :: Init_int8 (Int.repr 97) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 120) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_2 := {|
  gvar_info := (tarray tuchar 6);
  gvar_init := (Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 103) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_3 := {|
  gvar_info := (tarray tuchar 6);
  gvar_init := (Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 119) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_5 := {|
  gvar_info := (tarray tuchar 3);
  gvar_init := (Init_int8 (Int.repr 37) :: Init_int8 (Int.repr 100) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_7 := {|
  gvar_info := (tarray tuchar 10);
  gvar_init := (Init_int8 (Int.repr 115) :: Init_int8 (Int.repr 116) ::
                Init_int8 (Int.repr 97) :: Init_int8 (Int.repr 116) ::
                Init_int8 (Int.repr 98) :: Init_int8 (Int.repr 103) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_gMarioState := {|
  gvar_info := (tptr (Tstruct _MarioState noattr));
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

Definition v_gNumCalls := {|
  gvar_info := (Tstruct _NumTimesCalled noattr);
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

Definition v_gNumStaticSurfaces := {|
  gvar_info := tint;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCheckingSurfaceCollisionsForCamera := {|
  gvar_info := tshort;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gFindFloorIncludeSurfaceIntangible := {|
  gvar_info := tshort;
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

Definition v_gStaticSurfacePartition := {|
  gvar_info := (tarray (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16) 16);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDynamicSurfacePartition := {|
  gvar_info := (tarray (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16) 16);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_find_wall_collisions_from_list := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_surfaceNode, (tptr (Tstruct _SurfaceNode noattr))) ::
                (_data, (tptr (Tstruct _WallCollisionData noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_surf, (tptr (Tstruct _Surface noattr))) ::
               (_offset, tfloat) :: (_radius, tfloat) :: (_x, tfloat) ::
               (_y, tfloat) :: (_z, tfloat) :: (_px, tfloat) ::
               (_pz, tfloat) :: (_w1, tfloat) :: (_w2, tfloat) ::
               (_w3, tfloat) :: (_y1, tfloat) :: (_y2, tfloat) ::
               (_y3, tfloat) :: (_numCols, tint) :: (_t'6, tshort) ::
               (_t'5, tint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'46, tfloat) ::
               (_t'45, tfloat) :: (_t'44, tshort) :: (_t'43, tshort) ::
               (_t'42, tfloat) :: (_t'41, tfloat) :: (_t'40, tfloat) ::
               (_t'39, tfloat) :: (_t'38, tshort) :: (_t'37, tshort) ::
               (_t'36, tshort) :: (_t'35, tshort) :: (_t'34, tshort) ::
               (_t'33, tshort) :: (_t'32, tfloat) :: (_t'31, tshort) ::
               (_t'30, tshort) :: (_t'29, tshort) :: (_t'28, tshort) ::
               (_t'27, tshort) :: (_t'26, tshort) :: (_t'25, tfloat) ::
               (_t'24, tschar) :: (_t'23, tschar) :: (_t'22, tshort) ::
               (_t'21, tshort) :: (_t'20, (tptr (Tstruct _Object noattr))) ::
               (_t'19, (tptr (Tstruct _Object noattr))) ::
               (_t'18, (tptr (Tstruct _Object noattr))) ::
               (_t'17, (tptr (Tstruct _Object noattr))) ::
               (_t'16, (tptr (Tstruct _Object noattr))) :: (_t'15, tuint) ::
               (_t'14, (tptr (Tstruct _MarioState noattr))) ::
               (_t'13, tshort) :: (_t'12, tshort) :: (_t'11, tfloat) ::
               (_t'10, tfloat) :: (_t'9, tfloat) :: (_t'8, tfloat) ::
               (_t'7, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _radius
    (Efield
      (Ederef (Etempvar _data (tptr (Tstruct _WallCollisionData noattr)))
        (Tstruct _WallCollisionData noattr)) _radius tfloat))
  (Ssequence
    (Sset _x
      (Efield
        (Ederef (Etempvar _data (tptr (Tstruct _WallCollisionData noattr)))
          (Tstruct _WallCollisionData noattr)) _x tfloat))
    (Ssequence
      (Ssequence
        (Sset _t'45
          (Efield
            (Ederef
              (Etempvar _data (tptr (Tstruct _WallCollisionData noattr)))
              (Tstruct _WallCollisionData noattr)) _y tfloat))
        (Ssequence
          (Sset _t'46
            (Efield
              (Ederef
                (Etempvar _data (tptr (Tstruct _WallCollisionData noattr)))
                (Tstruct _WallCollisionData noattr)) _offsetY tfloat))
          (Sset _y
            (Ebinop Oadd (Etempvar _t'45 tfloat) (Etempvar _t'46 tfloat)
              tfloat))))
      (Ssequence
        (Sset _z
          (Efield
            (Ederef
              (Etempvar _data (tptr (Tstruct _WallCollisionData noattr)))
              (Tstruct _WallCollisionData noattr)) _z tfloat))
        (Ssequence
          (Sset _numCols (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Sifthenelse (Ebinop Ogt (Etempvar _radius tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 1128792064)) tfloat)
                           tint)
              (Sset _radius
                (Econst_single (Float32.of_bits (Int.repr 1128792064)) tfloat))
              Sskip)
            (Ssequence
              (Swhile
                (Ebinop One
                  (Etempvar _surfaceNode (tptr (Tstruct _SurfaceNode noattr)))
                  (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
                (Ssequence
                  (Sset _surf
                    (Efield
                      (Ederef
                        (Etempvar _surfaceNode (tptr (Tstruct _SurfaceNode noattr)))
                        (Tstruct _SurfaceNode noattr)) _surface
                      (tptr (Tstruct _Surface noattr))))
                  (Ssequence
                    (Sset _surfaceNode
                      (Efield
                        (Ederef
                          (Etempvar _surfaceNode (tptr (Tstruct _SurfaceNode noattr)))
                          (Tstruct _SurfaceNode noattr)) _next
                        (tptr (Tstruct _SurfaceNode noattr))))
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'43
                            (Efield
                              (Ederef
                                (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                (Tstruct _Surface noattr)) _lowerY tshort))
                          (Sifthenelse (Ebinop Olt (Etempvar _y tfloat)
                                         (Etempvar _t'43 tshort) tint)
                            (Sset _t'1 (Econst_int (Int.repr 1) tint))
                            (Ssequence
                              (Sset _t'44
                                (Efield
                                  (Ederef
                                    (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                    (Tstruct _Surface noattr)) _upperY
                                  tshort))
                              (Sset _t'1
                                (Ecast
                                  (Ebinop Ogt (Etempvar _y tfloat)
                                    (Etempvar _t'44 tshort) tint) tbool)))))
                        (Sifthenelse (Etempvar _t'1 tint) Scontinue Sskip))
                      (Ssequence
                        (Ssequence
                          (Sset _t'39
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                  (Tstruct _Surface noattr)) _normal
                                (Tstruct __732 noattr)) _x tfloat))
                          (Ssequence
                            (Sset _t'40
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                    (Tstruct _Surface noattr)) _normal
                                  (Tstruct __732 noattr)) _y tfloat))
                            (Ssequence
                              (Sset _t'41
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                      (Tstruct _Surface noattr)) _normal
                                    (Tstruct __732 noattr)) _z tfloat))
                              (Ssequence
                                (Sset _t'42
                                  (Efield
                                    (Ederef
                                      (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                      (Tstruct _Surface noattr))
                                    _originOffset tfloat))
                                (Sset _offset
                                  (Ebinop Oadd
                                    (Ebinop Oadd
                                      (Ebinop Oadd
                                        (Ebinop Omul (Etempvar _t'39 tfloat)
                                          (Etempvar _x tfloat) tfloat)
                                        (Ebinop Omul (Etempvar _t'40 tfloat)
                                          (Etempvar _y tfloat) tfloat)
                                        tfloat)
                                      (Ebinop Omul (Etempvar _t'41 tfloat)
                                        (Etempvar _z tfloat) tfloat) tfloat)
                                    (Etempvar _t'42 tfloat) tfloat))))))
                        (Ssequence
                          (Ssequence
                            (Sifthenelse (Ebinop Olt
                                           (Etempvar _offset tfloat)
                                           (Eunop Oneg
                                             (Etempvar _radius tfloat)
                                             tfloat) tint)
                              (Sset _t'2 (Econst_int (Int.repr 1) tint))
                              (Sset _t'2
                                (Ecast
                                  (Ebinop Ogt (Etempvar _offset tfloat)
                                    (Etempvar _radius tfloat) tint) tbool)))
                            (Sifthenelse (Etempvar _t'2 tint)
                              Scontinue
                              Sskip))
                          (Ssequence
                            (Sset _px (Etempvar _x tfloat))
                            (Ssequence
                              (Sset _pz (Etempvar _z tfloat))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'24
                                    (Efield
                                      (Ederef
                                        (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                        (Tstruct _Surface noattr)) _flags
                                      tschar))
                                  (Sifthenelse (Ebinop Oand
                                                 (Etempvar _t'24 tschar)
                                                 (Ebinop Oshl
                                                   (Econst_int (Int.repr 1) tint)
                                                   (Econst_int (Int.repr 3) tint)
                                                   tint) tint)
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'38
                                          (Ederef
                                            (Ebinop Oadd
                                              (Efield
                                                (Ederef
                                                  (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                                  (Tstruct _Surface noattr))
                                                _vertex1 (tarray tshort 3))
                                              (Econst_int (Int.repr 2) tint)
                                              (tptr tshort)) tshort))
                                        (Sset _w1
                                          (Ecast
                                            (Eunop Oneg
                                              (Etempvar _t'38 tshort) tint)
                                            tfloat)))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'37
                                            (Ederef
                                              (Ebinop Oadd
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                                    (Tstruct _Surface noattr))
                                                  _vertex2 (tarray tshort 3))
                                                (Econst_int (Int.repr 2) tint)
                                                (tptr tshort)) tshort))
                                          (Sset _w2
                                            (Ecast
                                              (Eunop Oneg
                                                (Etempvar _t'37 tshort) tint)
                                              tfloat)))
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'36
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                                      (Tstruct _Surface noattr))
                                                    _vertex3
                                                    (tarray tshort 3))
                                                  (Econst_int (Int.repr 2) tint)
                                                  (tptr tshort)) tshort))
                                            (Sset _w3
                                              (Ecast
                                                (Eunop Oneg
                                                  (Etempvar _t'36 tshort)
                                                  tint) tfloat)))
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'35
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                                        (Tstruct _Surface noattr))
                                                      _vertex1
                                                      (tarray tshort 3))
                                                    (Econst_int (Int.repr 1) tint)
                                                    (tptr tshort)) tshort))
                                              (Sset _y1
                                                (Ecast
                                                  (Etempvar _t'35 tshort)
                                                  tfloat)))
                                            (Ssequence
                                              (Ssequence
                                                (Sset _t'34
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                                          (Tstruct _Surface noattr))
                                                        _vertex2
                                                        (tarray tshort 3))
                                                      (Econst_int (Int.repr 1) tint)
                                                      (tptr tshort)) tshort))
                                                (Sset _y2
                                                  (Ecast
                                                    (Etempvar _t'34 tshort)
                                                    tfloat)))
                                              (Ssequence
                                                (Ssequence
                                                  (Sset _t'33
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                                            (Tstruct _Surface noattr))
                                                          _vertex3
                                                          (tarray tshort 3))
                                                        (Econst_int (Int.repr 1) tint)
                                                        (tptr tshort))
                                                      tshort))
                                                  (Sset _y3
                                                    (Ecast
                                                      (Etempvar _t'33 tshort)
                                                      tfloat)))
                                                (Ssequence
                                                  (Sset _t'32
                                                    (Efield
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                                          (Tstruct _Surface noattr))
                                                        _normal
                                                        (Tstruct __732 noattr))
                                                      _x tfloat))
                                                  (Sifthenelse (Ebinop Ogt
                                                                 (Etempvar _t'32 tfloat)
                                                                 (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                                                 tint)
                                                    (Ssequence
                                                      (Sifthenelse (Ebinop Ogt
                                                                    (Ebinop Osub
                                                                    (Ebinop Omul
                                                                    (Ebinop Osub
                                                                    (Etempvar _y1 tfloat)
                                                                    (Etempvar _y tfloat)
                                                                    tfloat)
                                                                    (Ebinop Osub
                                                                    (Etempvar _w2 tfloat)
                                                                    (Etempvar _w1 tfloat)
                                                                    tfloat)
                                                                    tfloat)
                                                                    (Ebinop Omul
                                                                    (Ebinop Osub
                                                                    (Etempvar _w1 tfloat)
                                                                    (Eunop Oneg
                                                                    (Etempvar _pz tfloat)
                                                                    tfloat)
                                                                    tfloat)
                                                                    (Ebinop Osub
                                                                    (Etempvar _y2 tfloat)
                                                                    (Etempvar _y1 tfloat)
                                                                    tfloat)
                                                                    tfloat)
                                                                    tfloat)
                                                                    (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                                                    tint)
                                                        Scontinue
                                                        Sskip)
                                                      (Ssequence
                                                        (Sifthenelse 
                                                          (Ebinop Ogt
                                                            (Ebinop Osub
                                                              (Ebinop Omul
                                                                (Ebinop Osub
                                                                  (Etempvar _y2 tfloat)
                                                                  (Etempvar _y tfloat)
                                                                  tfloat)
                                                                (Ebinop Osub
                                                                  (Etempvar _w3 tfloat)
                                                                  (Etempvar _w2 tfloat)
                                                                  tfloat)
                                                                tfloat)
                                                              (Ebinop Omul
                                                                (Ebinop Osub
                                                                  (Etempvar _w2 tfloat)
                                                                  (Eunop Oneg
                                                                    (Etempvar _pz tfloat)
                                                                    tfloat)
                                                                  tfloat)
                                                                (Ebinop Osub
                                                                  (Etempvar _y3 tfloat)
                                                                  (Etempvar _y2 tfloat)
                                                                  tfloat)
                                                                tfloat)
                                                              tfloat)
                                                            (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                                            tint)
                                                          Scontinue
                                                          Sskip)
                                                        (Sifthenelse 
                                                          (Ebinop Ogt
                                                            (Ebinop Osub
                                                              (Ebinop Omul
                                                                (Ebinop Osub
                                                                  (Etempvar _y3 tfloat)
                                                                  (Etempvar _y tfloat)
                                                                  tfloat)
                                                                (Ebinop Osub
                                                                  (Etempvar _w1 tfloat)
                                                                  (Etempvar _w3 tfloat)
                                                                  tfloat)
                                                                tfloat)
                                                              (Ebinop Omul
                                                                (Ebinop Osub
                                                                  (Etempvar _w3 tfloat)
                                                                  (Eunop Oneg
                                                                    (Etempvar _pz tfloat)
                                                                    tfloat)
                                                                  tfloat)
                                                                (Ebinop Osub
                                                                  (Etempvar _y1 tfloat)
                                                                  (Etempvar _y3 tfloat)
                                                                  tfloat)
                                                                tfloat)
                                                              tfloat)
                                                            (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                                            tint)
                                                          Scontinue
                                                          Sskip)))
                                                    (Ssequence
                                                      (Sifthenelse (Ebinop Olt
                                                                    (Ebinop Osub
                                                                    (Ebinop Omul
                                                                    (Ebinop Osub
                                                                    (Etempvar _y1 tfloat)
                                                                    (Etempvar _y tfloat)
                                                                    tfloat)
                                                                    (Ebinop Osub
                                                                    (Etempvar _w2 tfloat)
                                                                    (Etempvar _w1 tfloat)
                                                                    tfloat)
                                                                    tfloat)
                                                                    (Ebinop Omul
                                                                    (Ebinop Osub
                                                                    (Etempvar _w1 tfloat)
                                                                    (Eunop Oneg
                                                                    (Etempvar _pz tfloat)
                                                                    tfloat)
                                                                    tfloat)
                                                                    (Ebinop Osub
                                                                    (Etempvar _y2 tfloat)
                                                                    (Etempvar _y1 tfloat)
                                                                    tfloat)
                                                                    tfloat)
                                                                    tfloat)
                                                                    (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                                                    tint)
                                                        Scontinue
                                                        Sskip)
                                                      (Ssequence
                                                        (Sifthenelse 
                                                          (Ebinop Olt
                                                            (Ebinop Osub
                                                              (Ebinop Omul
                                                                (Ebinop Osub
                                                                  (Etempvar _y2 tfloat)
                                                                  (Etempvar _y tfloat)
                                                                  tfloat)
                                                                (Ebinop Osub
                                                                  (Etempvar _w3 tfloat)
                                                                  (Etempvar _w2 tfloat)
                                                                  tfloat)
                                                                tfloat)
                                                              (Ebinop Omul
                                                                (Ebinop Osub
                                                                  (Etempvar _w2 tfloat)
                                                                  (Eunop Oneg
                                                                    (Etempvar _pz tfloat)
                                                                    tfloat)
                                                                  tfloat)
                                                                (Ebinop Osub
                                                                  (Etempvar _y3 tfloat)
                                                                  (Etempvar _y2 tfloat)
                                                                  tfloat)
                                                                tfloat)
                                                              tfloat)
                                                            (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                                            tint)
                                                          Scontinue
                                                          Sskip)
                                                        (Sifthenelse 
                                                          (Ebinop Olt
                                                            (Ebinop Osub
                                                              (Ebinop Omul
                                                                (Ebinop Osub
                                                                  (Etempvar _y3 tfloat)
                                                                  (Etempvar _y tfloat)
                                                                  tfloat)
                                                                (Ebinop Osub
                                                                  (Etempvar _w1 tfloat)
                                                                  (Etempvar _w3 tfloat)
                                                                  tfloat)
                                                                tfloat)
                                                              (Ebinop Omul
                                                                (Ebinop Osub
                                                                  (Etempvar _w3 tfloat)
                                                                  (Eunop Oneg
                                                                    (Etempvar _pz tfloat)
                                                                    tfloat)
                                                                  tfloat)
                                                                (Ebinop Osub
                                                                  (Etempvar _y1 tfloat)
                                                                  (Etempvar _y3 tfloat)
                                                                  tfloat)
                                                                tfloat)
                                                              tfloat)
                                                            (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                                            tint)
                                                          Scontinue
                                                          Sskip)))))))))))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'31
                                          (Ederef
                                            (Ebinop Oadd
                                              (Efield
                                                (Ederef
                                                  (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                                  (Tstruct _Surface noattr))
                                                _vertex1 (tarray tshort 3))
                                              (Econst_int (Int.repr 0) tint)
                                              (tptr tshort)) tshort))
                                        (Sset _w1
                                          (Ecast (Etempvar _t'31 tshort)
                                            tfloat)))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'30
                                            (Ederef
                                              (Ebinop Oadd
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                                    (Tstruct _Surface noattr))
                                                  _vertex2 (tarray tshort 3))
                                                (Econst_int (Int.repr 0) tint)
                                                (tptr tshort)) tshort))
                                          (Sset _w2
                                            (Ecast (Etempvar _t'30 tshort)
                                              tfloat)))
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'29
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                                      (Tstruct _Surface noattr))
                                                    _vertex3
                                                    (tarray tshort 3))
                                                  (Econst_int (Int.repr 0) tint)
                                                  (tptr tshort)) tshort))
                                            (Sset _w3
                                              (Ecast (Etempvar _t'29 tshort)
                                                tfloat)))
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'28
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                                        (Tstruct _Surface noattr))
                                                      _vertex1
                                                      (tarray tshort 3))
                                                    (Econst_int (Int.repr 1) tint)
                                                    (tptr tshort)) tshort))
                                              (Sset _y1
                                                (Ecast
                                                  (Etempvar _t'28 tshort)
                                                  tfloat)))
                                            (Ssequence
                                              (Ssequence
                                                (Sset _t'27
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                                          (Tstruct _Surface noattr))
                                                        _vertex2
                                                        (tarray tshort 3))
                                                      (Econst_int (Int.repr 1) tint)
                                                      (tptr tshort)) tshort))
                                                (Sset _y2
                                                  (Ecast
                                                    (Etempvar _t'27 tshort)
                                                    tfloat)))
                                              (Ssequence
                                                (Ssequence
                                                  (Sset _t'26
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                                            (Tstruct _Surface noattr))
                                                          _vertex3
                                                          (tarray tshort 3))
                                                        (Econst_int (Int.repr 1) tint)
                                                        (tptr tshort))
                                                      tshort))
                                                  (Sset _y3
                                                    (Ecast
                                                      (Etempvar _t'26 tshort)
                                                      tfloat)))
                                                (Ssequence
                                                  (Sset _t'25
                                                    (Efield
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                                          (Tstruct _Surface noattr))
                                                        _normal
                                                        (Tstruct __732 noattr))
                                                      _z tfloat))
                                                  (Sifthenelse (Ebinop Ogt
                                                                 (Etempvar _t'25 tfloat)
                                                                 (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                                                 tint)
                                                    (Ssequence
                                                      (Sifthenelse (Ebinop Ogt
                                                                    (Ebinop Osub
                                                                    (Ebinop Omul
                                                                    (Ebinop Osub
                                                                    (Etempvar _y1 tfloat)
                                                                    (Etempvar _y tfloat)
                                                                    tfloat)
                                                                    (Ebinop Osub
                                                                    (Etempvar _w2 tfloat)
                                                                    (Etempvar _w1 tfloat)
                                                                    tfloat)
                                                                    tfloat)
                                                                    (Ebinop Omul
                                                                    (Ebinop Osub
                                                                    (Etempvar _w1 tfloat)
                                                                    (Etempvar _px tfloat)
                                                                    tfloat)
                                                                    (Ebinop Osub
                                                                    (Etempvar _y2 tfloat)
                                                                    (Etempvar _y1 tfloat)
                                                                    tfloat)
                                                                    tfloat)
                                                                    tfloat)
                                                                    (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                                                    tint)
                                                        Scontinue
                                                        Sskip)
                                                      (Ssequence
                                                        (Sifthenelse 
                                                          (Ebinop Ogt
                                                            (Ebinop Osub
                                                              (Ebinop Omul
                                                                (Ebinop Osub
                                                                  (Etempvar _y2 tfloat)
                                                                  (Etempvar _y tfloat)
                                                                  tfloat)
                                                                (Ebinop Osub
                                                                  (Etempvar _w3 tfloat)
                                                                  (Etempvar _w2 tfloat)
                                                                  tfloat)
                                                                tfloat)
                                                              (Ebinop Omul
                                                                (Ebinop Osub
                                                                  (Etempvar _w2 tfloat)
                                                                  (Etempvar _px tfloat)
                                                                  tfloat)
                                                                (Ebinop Osub
                                                                  (Etempvar _y3 tfloat)
                                                                  (Etempvar _y2 tfloat)
                                                                  tfloat)
                                                                tfloat)
                                                              tfloat)
                                                            (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                                            tint)
                                                          Scontinue
                                                          Sskip)
                                                        (Sifthenelse 
                                                          (Ebinop Ogt
                                                            (Ebinop Osub
                                                              (Ebinop Omul
                                                                (Ebinop Osub
                                                                  (Etempvar _y3 tfloat)
                                                                  (Etempvar _y tfloat)
                                                                  tfloat)
                                                                (Ebinop Osub
                                                                  (Etempvar _w1 tfloat)
                                                                  (Etempvar _w3 tfloat)
                                                                  tfloat)
                                                                tfloat)
                                                              (Ebinop Omul
                                                                (Ebinop Osub
                                                                  (Etempvar _w3 tfloat)
                                                                  (Etempvar _px tfloat)
                                                                  tfloat)
                                                                (Ebinop Osub
                                                                  (Etempvar _y1 tfloat)
                                                                  (Etempvar _y3 tfloat)
                                                                  tfloat)
                                                                tfloat)
                                                              tfloat)
                                                            (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                                            tint)
                                                          Scontinue
                                                          Sskip)))
                                                    (Ssequence
                                                      (Sifthenelse (Ebinop Olt
                                                                    (Ebinop Osub
                                                                    (Ebinop Omul
                                                                    (Ebinop Osub
                                                                    (Etempvar _y1 tfloat)
                                                                    (Etempvar _y tfloat)
                                                                    tfloat)
                                                                    (Ebinop Osub
                                                                    (Etempvar _w2 tfloat)
                                                                    (Etempvar _w1 tfloat)
                                                                    tfloat)
                                                                    tfloat)
                                                                    (Ebinop Omul
                                                                    (Ebinop Osub
                                                                    (Etempvar _w1 tfloat)
                                                                    (Etempvar _px tfloat)
                                                                    tfloat)
                                                                    (Ebinop Osub
                                                                    (Etempvar _y2 tfloat)
                                                                    (Etempvar _y1 tfloat)
                                                                    tfloat)
                                                                    tfloat)
                                                                    tfloat)
                                                                    (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                                                    tint)
                                                        Scontinue
                                                        Sskip)
                                                      (Ssequence
                                                        (Sifthenelse 
                                                          (Ebinop Olt
                                                            (Ebinop Osub
                                                              (Ebinop Omul
                                                                (Ebinop Osub
                                                                  (Etempvar _y2 tfloat)
                                                                  (Etempvar _y tfloat)
                                                                  tfloat)
                                                                (Ebinop Osub
                                                                  (Etempvar _w3 tfloat)
                                                                  (Etempvar _w2 tfloat)
                                                                  tfloat)
                                                                tfloat)
                                                              (Ebinop Omul
                                                                (Ebinop Osub
                                                                  (Etempvar _w2 tfloat)
                                                                  (Etempvar _px tfloat)
                                                                  tfloat)
                                                                (Ebinop Osub
                                                                  (Etempvar _y3 tfloat)
                                                                  (Etempvar _y2 tfloat)
                                                                  tfloat)
                                                                tfloat)
                                                              tfloat)
                                                            (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                                            tint)
                                                          Scontinue
                                                          Sskip)
                                                        (Sifthenelse 
                                                          (Ebinop Olt
                                                            (Ebinop Osub
                                                              (Ebinop Omul
                                                                (Ebinop Osub
                                                                  (Etempvar _y3 tfloat)
                                                                  (Etempvar _y tfloat)
                                                                  tfloat)
                                                                (Ebinop Osub
                                                                  (Etempvar _w1 tfloat)
                                                                  (Etempvar _w3 tfloat)
                                                                  tfloat)
                                                                tfloat)
                                                              (Ebinop Omul
                                                                (Ebinop Osub
                                                                  (Etempvar _w3 tfloat)
                                                                  (Etempvar _px tfloat)
                                                                  tfloat)
                                                                (Ebinop Osub
                                                                  (Etempvar _y1 tfloat)
                                                                  (Etempvar _y3 tfloat)
                                                                  tfloat)
                                                                tfloat)
                                                              tfloat)
                                                            (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                                            tint)
                                                          Scontinue
                                                          Sskip)))))))))))))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'12
                                      (Evar _gCheckingSurfaceCollisionsForCamera tshort))
                                    (Sifthenelse (Etempvar _t'12 tshort)
                                      (Ssequence
                                        (Sset _t'23
                                          (Efield
                                            (Ederef
                                              (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                              (Tstruct _Surface noattr))
                                            _flags tschar))
                                        (Sifthenelse (Ebinop Oand
                                                       (Etempvar _t'23 tschar)
                                                       (Ebinop Oshl
                                                         (Econst_int (Int.repr 1) tint)
                                                         (Econst_int (Int.repr 1) tint)
                                                         tint) tint)
                                          Scontinue
                                          Sskip))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'22
                                            (Efield
                                              (Ederef
                                                (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                                (Tstruct _Surface noattr))
                                              _type tshort))
                                          (Sifthenelse (Ebinop Oeq
                                                         (Etempvar _t'22 tshort)
                                                         (Econst_int (Int.repr 114) tint)
                                                         tint)
                                            Scontinue
                                            Sskip))
                                        (Ssequence
                                          (Sset _t'13
                                            (Efield
                                              (Ederef
                                                (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                                (Tstruct _Surface noattr))
                                              _type tshort))
                                          (Sifthenelse (Ebinop Oeq
                                                         (Etempvar _t'13 tshort)
                                                         (Econst_int (Int.repr 123) tint)
                                                         tint)
                                            (Ssequence
                                              (Ssequence
                                                (Ssequence
                                                  (Sset _t'19
                                                    (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                                  (Sifthenelse (Ebinop One
                                                                 (Etempvar _t'19 (tptr (Tstruct _Object noattr)))
                                                                 (Ecast
                                                                   (Econst_int (Int.repr 0) tint)
                                                                   (tptr tvoid))
                                                                 tint)
                                                    (Ssequence
                                                      (Sset _t'20
                                                        (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                                      (Ssequence
                                                        (Sset _t'21
                                                          (Efield
                                                            (Ederef
                                                              (Etempvar _t'20 (tptr (Tstruct _Object noattr)))
                                                              (Tstruct _Object noattr))
                                                            _activeFlags
                                                            tshort))
                                                        (Sset _t'3
                                                          (Ecast
                                                            (Ebinop Oand
                                                              (Etempvar _t'21 tshort)
                                                              (Ebinop Oshl
                                                                (Econst_int (Int.repr 1) tint)
                                                                (Econst_int (Int.repr 6) tint)
                                                                tint) tint)
                                                            tbool))))
                                                    (Sset _t'3
                                                      (Econst_int (Int.repr 0) tint))))
                                                (Sifthenelse (Etempvar _t'3 tint)
                                                  Scontinue
                                                  Sskip))
                                              (Ssequence
                                                (Ssequence
                                                  (Ssequence
                                                    (Sset _t'16
                                                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                                    (Sifthenelse (Ebinop One
                                                                   (Etempvar _t'16 (tptr (Tstruct _Object noattr)))
                                                                   (Ecast
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    (tptr tvoid))
                                                                   tint)
                                                      (Ssequence
                                                        (Sset _t'17
                                                          (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                                        (Ssequence
                                                          (Sset _t'18
                                                            (Evar _gMarioObject (tptr (Tstruct _Object noattr))))
                                                          (Sset _t'4
                                                            (Ecast
                                                              (Ebinop Oeq
                                                                (Etempvar _t'17 (tptr (Tstruct _Object noattr)))
                                                                (Etempvar _t'18 (tptr (Tstruct _Object noattr)))
                                                                tint) tbool))))
                                                      (Sset _t'4
                                                        (Econst_int (Int.repr 0) tint))))
                                                  (Sifthenelse (Etempvar _t'4 tint)
                                                    (Ssequence
                                                      (Sset _t'14
                                                        (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                      (Ssequence
                                                        (Sset _t'15
                                                          (Efield
                                                            (Ederef
                                                              (Etempvar _t'14 (tptr (Tstruct _MarioState noattr)))
                                                              (Tstruct _MarioState noattr))
                                                            _flags tuint))
                                                        (Sset _t'5
                                                          (Ecast
                                                            (Ebinop Oand
                                                              (Etempvar _t'15 tuint)
                                                              (Econst_int (Int.repr 2) tint)
                                                              tuint) tbool))))
                                                    (Sset _t'5
                                                      (Econst_int (Int.repr 0) tint))))
                                                (Sifthenelse (Etempvar _t'5 tint)
                                                  Scontinue
                                                  Sskip)))
                                            Sskip)))))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'10
                                        (Efield
                                          (Ederef
                                            (Etempvar _data (tptr (Tstruct _WallCollisionData noattr)))
                                            (Tstruct _WallCollisionData noattr))
                                          _x tfloat))
                                      (Ssequence
                                        (Sset _t'11
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                                (Tstruct _Surface noattr))
                                              _normal (Tstruct __732 noattr))
                                            _x tfloat))
                                        (Sassign
                                          (Efield
                                            (Ederef
                                              (Etempvar _data (tptr (Tstruct _WallCollisionData noattr)))
                                              (Tstruct _WallCollisionData noattr))
                                            _x tfloat)
                                          (Ebinop Oadd
                                            (Etempvar _t'10 tfloat)
                                            (Ebinop Omul
                                              (Etempvar _t'11 tfloat)
                                              (Ebinop Osub
                                                (Etempvar _radius tfloat)
                                                (Etempvar _offset tfloat)
                                                tfloat) tfloat) tfloat))))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'8
                                          (Efield
                                            (Ederef
                                              (Etempvar _data (tptr (Tstruct _WallCollisionData noattr)))
                                              (Tstruct _WallCollisionData noattr))
                                            _z tfloat))
                                        (Ssequence
                                          (Sset _t'9
                                            (Efield
                                              (Efield
                                                (Ederef
                                                  (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                                  (Tstruct _Surface noattr))
                                                _normal
                                                (Tstruct __732 noattr)) _z
                                              tfloat))
                                          (Sassign
                                            (Efield
                                              (Ederef
                                                (Etempvar _data (tptr (Tstruct _WallCollisionData noattr)))
                                                (Tstruct _WallCollisionData noattr))
                                              _z tfloat)
                                            (Ebinop Oadd
                                              (Etempvar _t'8 tfloat)
                                              (Ebinop Omul
                                                (Etempvar _t'9 tfloat)
                                                (Ebinop Osub
                                                  (Etempvar _radius tfloat)
                                                  (Etempvar _offset tfloat)
                                                  tfloat) tfloat) tfloat))))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'7
                                            (Efield
                                              (Ederef
                                                (Etempvar _data (tptr (Tstruct _WallCollisionData noattr)))
                                                (Tstruct _WallCollisionData noattr))
                                              _numWalls tshort))
                                          (Sifthenelse (Ebinop Olt
                                                         (Etempvar _t'7 tshort)
                                                         (Econst_int (Int.repr 4) tint)
                                                         tint)
                                            (Ssequence
                                              (Ssequence
                                                (Sset _t'6
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _data (tptr (Tstruct _WallCollisionData noattr)))
                                                      (Tstruct _WallCollisionData noattr))
                                                    _numWalls tshort))
                                                (Sassign
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _data (tptr (Tstruct _WallCollisionData noattr)))
                                                      (Tstruct _WallCollisionData noattr))
                                                    _numWalls tshort)
                                                  (Ebinop Oadd
                                                    (Etempvar _t'6 tshort)
                                                    (Econst_int (Int.repr 1) tint)
                                                    tint)))
                                              (Sassign
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _data (tptr (Tstruct _WallCollisionData noattr)))
                                                        (Tstruct _WallCollisionData noattr))
                                                      _walls
                                                      (tarray (tptr (Tstruct _Surface noattr)) 4))
                                                    (Etempvar _t'6 tshort)
                                                    (tptr (tptr (Tstruct _Surface noattr))))
                                                  (tptr (Tstruct _Surface noattr)))
                                                (Etempvar _surf (tptr (Tstruct _Surface noattr)))))
                                            Sskip))
                                        (Sset _numCols
                                          (Ebinop Oadd
                                            (Etempvar _numCols tint)
                                            (Econst_int (Int.repr 1) tint)
                                            tint)))))))))))))))
              (Sreturn (Some (Etempvar _numCols tint))))))))))
|}.

Definition f_f32_find_wall_collision := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_xPtr, (tptr tfloat)) :: (_yPtr, (tptr tfloat)) ::
                (_zPtr, (tptr tfloat)) :: (_offsetY, tfloat) ::
                (_radius, tfloat) :: nil);
  fn_vars := ((_collision, (Tstruct _WallCollisionData noattr)) :: nil);
  fn_temps := ((_numCollisions, tint) :: (_t'1, tint) :: (_t'7, tfloat) ::
               (_t'6, tfloat) :: (_t'5, tfloat) :: (_t'4, tfloat) ::
               (_t'3, tfloat) :: (_t'2, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _numCollisions (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sassign
      (Efield (Evar _collision (Tstruct _WallCollisionData noattr)) _offsetY
        tfloat) (Etempvar _offsetY tfloat))
    (Ssequence
      (Sassign
        (Efield (Evar _collision (Tstruct _WallCollisionData noattr)) _radius
          tfloat) (Etempvar _radius tfloat))
      (Ssequence
        (Ssequence
          (Sset _t'7 (Ederef (Etempvar _xPtr (tptr tfloat)) tfloat))
          (Sassign
            (Efield (Evar _collision (Tstruct _WallCollisionData noattr)) _x
              tfloat) (Etempvar _t'7 tfloat)))
        (Ssequence
          (Ssequence
            (Sset _t'6 (Ederef (Etempvar _yPtr (tptr tfloat)) tfloat))
            (Sassign
              (Efield (Evar _collision (Tstruct _WallCollisionData noattr))
                _y tfloat) (Etempvar _t'6 tfloat)))
          (Ssequence
            (Ssequence
              (Sset _t'5 (Ederef (Etempvar _zPtr (tptr tfloat)) tfloat))
              (Sassign
                (Efield (Evar _collision (Tstruct _WallCollisionData noattr))
                  _z tfloat) (Etempvar _t'5 tfloat)))
            (Ssequence
              (Sassign
                (Efield (Evar _collision (Tstruct _WallCollisionData noattr))
                  _numWalls tshort) (Econst_int (Int.repr 0) tint))
              (Ssequence
                (Ssequence
                  (Scall (Some _t'1)
                    (Evar _find_wall_collisions (Tfunction
                                                  ((tptr (Tstruct _WallCollisionData noattr)) ::
                                                   nil) tint cc_default))
                    ((Eaddrof
                       (Evar _collision (Tstruct _WallCollisionData noattr))
                       (tptr (Tstruct _WallCollisionData noattr))) :: nil))
                  (Sset _numCollisions (Etempvar _t'1 tint)))
                (Ssequence
                  (Ssequence
                    (Sset _t'4
                      (Efield
                        (Evar _collision (Tstruct _WallCollisionData noattr))
                        _x tfloat))
                    (Sassign (Ederef (Etempvar _xPtr (tptr tfloat)) tfloat)
                      (Etempvar _t'4 tfloat)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'3
                        (Efield
                          (Evar _collision (Tstruct _WallCollisionData noattr))
                          _y tfloat))
                      (Sassign (Ederef (Etempvar _yPtr (tptr tfloat)) tfloat)
                        (Etempvar _t'3 tfloat)))
                    (Ssequence
                      (Ssequence
                        (Sset _t'2
                          (Efield
                            (Evar _collision (Tstruct _WallCollisionData noattr))
                            _z tfloat))
                        (Sassign
                          (Ederef (Etempvar _zPtr (tptr tfloat)) tfloat)
                          (Etempvar _t'2 tfloat)))
                      (Sreturn (Some (Etempvar _numCollisions tint))))))))))))))
|}.

Definition f_find_wall_collisions := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_colData, (tptr (Tstruct _WallCollisionData noattr))) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_node, (tptr (Tstruct _SurfaceNode noattr))) ::
               (_cellX, tshort) :: (_cellZ, tshort) ::
               (_numCollisions, tint) :: (_x, tshort) :: (_z, tshort) ::
               (_t'4, tint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'7, tfloat) :: (_t'6, tfloat) ::
               (_t'5, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _numCollisions (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Sset _t'7
        (Efield
          (Ederef
            (Etempvar _colData (tptr (Tstruct _WallCollisionData noattr)))
            (Tstruct _WallCollisionData noattr)) _x tfloat))
      (Sset _x (Ecast (Etempvar _t'7 tfloat) tshort)))
    (Ssequence
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef
              (Etempvar _colData (tptr (Tstruct _WallCollisionData noattr)))
              (Tstruct _WallCollisionData noattr)) _z tfloat))
        (Sset _z (Ecast (Etempvar _t'6 tfloat) tshort)))
      (Ssequence
        (Sassign
          (Efield
            (Ederef
              (Etempvar _colData (tptr (Tstruct _WallCollisionData noattr)))
              (Tstruct _WallCollisionData noattr)) _numWalls tshort)
          (Econst_int (Int.repr 0) tint))
        (Ssequence
          (Ssequence
            (Sifthenelse (Ebinop Ole (Etempvar _x tshort)
                           (Eunop Oneg (Econst_int (Int.repr 8192) tint)
                             tint) tint)
              (Sset _t'1 (Econst_int (Int.repr 1) tint))
              (Sset _t'1
                (Ecast
                  (Ebinop Oge (Etempvar _x tshort)
                    (Econst_int (Int.repr 8192) tint) tint) tbool)))
            (Sifthenelse (Etempvar _t'1 tint)
              (Sreturn (Some (Etempvar _numCollisions tint)))
              Sskip))
          (Ssequence
            (Ssequence
              (Sifthenelse (Ebinop Ole (Etempvar _z tshort)
                             (Eunop Oneg (Econst_int (Int.repr 8192) tint)
                               tint) tint)
                (Sset _t'2 (Econst_int (Int.repr 1) tint))
                (Sset _t'2
                  (Ecast
                    (Ebinop Oge (Etempvar _z tshort)
                      (Econst_int (Int.repr 8192) tint) tint) tbool)))
              (Sifthenelse (Etempvar _t'2 tint)
                (Sreturn (Some (Etempvar _numCollisions tint)))
                Sskip))
            (Ssequence
              (Sset _cellX
                (Ecast
                  (Ebinop Oand
                    (Ebinop Odiv
                      (Ebinop Oadd (Etempvar _x tshort)
                        (Econst_int (Int.repr 8192) tint) tint)
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 10) tint) tint) tint)
                    (Ebinop Osub
                      (Ebinop Odiv
                        (Ebinop Omul (Econst_int (Int.repr 2) tint)
                          (Econst_int (Int.repr 8192) tint) tint)
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 10) tint) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tint) tshort))
              (Ssequence
                (Sset _cellZ
                  (Ecast
                    (Ebinop Oand
                      (Ebinop Odiv
                        (Ebinop Oadd (Etempvar _z tshort)
                          (Econst_int (Int.repr 8192) tint) tint)
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 10) tint) tint) tint)
                      (Ebinop Osub
                        (Ebinop Odiv
                          (Ebinop Omul (Econst_int (Int.repr 2) tint)
                            (Econst_int (Int.repr 8192) tint) tint)
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 10) tint) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tint) tshort))
                (Ssequence
                  (Sset _node
                    (Efield
                      (Ederef
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
                          (Econst_int (Int.repr 2) tint)
                          (tptr (Tstruct _SurfaceNode noattr)))
                        (Tstruct _SurfaceNode noattr)) _next
                      (tptr (Tstruct _SurfaceNode noattr))))
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'3)
                        (Evar _find_wall_collisions_from_list (Tfunction
                                                                ((tptr (Tstruct _SurfaceNode noattr)) ::
                                                                 (tptr (Tstruct _WallCollisionData noattr)) ::
                                                                 nil) tint
                                                                cc_default))
                        ((Etempvar _node (tptr (Tstruct _SurfaceNode noattr))) ::
                         (Etempvar _colData (tptr (Tstruct _WallCollisionData noattr))) ::
                         nil))
                      (Sset _numCollisions
                        (Ebinop Oadd (Etempvar _numCollisions tint)
                          (Etempvar _t'3 tint) tint)))
                    (Ssequence
                      (Sset _node
                        (Efield
                          (Ederef
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
                              (Econst_int (Int.repr 2) tint)
                              (tptr (Tstruct _SurfaceNode noattr)))
                            (Tstruct _SurfaceNode noattr)) _next
                          (tptr (Tstruct _SurfaceNode noattr))))
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'4)
                            (Evar _find_wall_collisions_from_list (Tfunction
                                                                    ((tptr (Tstruct _SurfaceNode noattr)) ::
                                                                    (tptr (Tstruct _WallCollisionData noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                            ((Etempvar _node (tptr (Tstruct _SurfaceNode noattr))) ::
                             (Etempvar _colData (tptr (Tstruct _WallCollisionData noattr))) ::
                             nil))
                          (Sset _numCollisions
                            (Ebinop Oadd (Etempvar _numCollisions tint)
                              (Etempvar _t'4 tint) tint)))
                        (Ssequence
                          (Ssequence
                            (Sset _t'5
                              (Efield
                                (Evar _gNumCalls (Tstruct _NumTimesCalled noattr))
                                _wall tshort))
                            (Sassign
                              (Efield
                                (Evar _gNumCalls (Tstruct _NumTimesCalled noattr))
                                _wall tshort)
                              (Ebinop Oadd (Etempvar _t'5 tshort)
                                (Econst_int (Int.repr 1) tint) tint)))
                          (Sreturn (Some (Etempvar _numCollisions tint))))))))))))))))
|}.

Definition f_find_ceil_from_list := {|
  fn_return := (tptr (Tstruct _Surface noattr));
  fn_callconv := cc_default;
  fn_params := ((_surfaceNode, (tptr (Tstruct _SurfaceNode noattr))) ::
                (_x, tint) :: (_y, tint) :: (_z, tint) ::
                (_pheight, (tptr tfloat)) :: nil);
  fn_vars := nil;
  fn_temps := ((_surf, (tptr (Tstruct _Surface noattr))) :: (_x1, tint) ::
               (_z1, tint) :: (_x2, tint) :: (_z2, tint) :: (_x3, tint) ::
               (_z3, tint) :: (_ceil, (tptr (Tstruct _Surface noattr))) ::
               (_nx, tfloat) :: (_ny, tfloat) :: (_nz, tfloat) ::
               (_oo, tfloat) :: (_height, tfloat) :: (_t'3, tschar) ::
               (_t'2, tshort) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _ceil (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Sset _ceil (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
    (Ssequence
      (Swhile
        (Ebinop One
          (Etempvar _surfaceNode (tptr (Tstruct _SurfaceNode noattr)))
          (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
        (Ssequence
          (Sset _surf
            (Efield
              (Ederef
                (Etempvar _surfaceNode (tptr (Tstruct _SurfaceNode noattr)))
                (Tstruct _SurfaceNode noattr)) _surface
              (tptr (Tstruct _Surface noattr))))
          (Ssequence
            (Sset _surfaceNode
              (Efield
                (Ederef
                  (Etempvar _surfaceNode (tptr (Tstruct _SurfaceNode noattr)))
                  (Tstruct _SurfaceNode noattr)) _next
                (tptr (Tstruct _SurfaceNode noattr))))
            (Ssequence
              (Sset _x1
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                        (Tstruct _Surface noattr)) _vertex1
                      (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                    (tptr tshort)) tshort))
              (Ssequence
                (Sset _z1
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                          (Tstruct _Surface noattr)) _vertex1
                        (tarray tshort 3)) (Econst_int (Int.repr 2) tint)
                      (tptr tshort)) tshort))
                (Ssequence
                  (Sset _z2
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                            (Tstruct _Surface noattr)) _vertex2
                          (tarray tshort 3)) (Econst_int (Int.repr 2) tint)
                        (tptr tshort)) tshort))
                  (Ssequence
                    (Sset _x2
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                              (Tstruct _Surface noattr)) _vertex2
                            (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                          (tptr tshort)) tshort))
                    (Ssequence
                      (Sifthenelse (Ebinop Ogt
                                     (Ebinop Osub
                                       (Ebinop Omul
                                         (Ebinop Osub (Etempvar _z1 tint)
                                           (Etempvar _z tint) tint)
                                         (Ebinop Osub (Etempvar _x2 tint)
                                           (Etempvar _x1 tint) tint) tint)
                                       (Ebinop Omul
                                         (Ebinop Osub (Etempvar _x1 tint)
                                           (Etempvar _x tint) tint)
                                         (Ebinop Osub (Etempvar _z2 tint)
                                           (Etempvar _z1 tint) tint) tint)
                                       tint) (Econst_int (Int.repr 0) tint)
                                     tint)
                        Scontinue
                        Sskip)
                      (Ssequence
                        (Sset _x3
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                  (Tstruct _Surface noattr)) _vertex3
                                (tarray tshort 3))
                              (Econst_int (Int.repr 0) tint) (tptr tshort))
                            tshort))
                        (Ssequence
                          (Sset _z3
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                    (Tstruct _Surface noattr)) _vertex3
                                  (tarray tshort 3))
                                (Econst_int (Int.repr 2) tint) (tptr tshort))
                              tshort))
                          (Ssequence
                            (Sifthenelse (Ebinop Ogt
                                           (Ebinop Osub
                                             (Ebinop Omul
                                               (Ebinop Osub
                                                 (Etempvar _z2 tint)
                                                 (Etempvar _z tint) tint)
                                               (Ebinop Osub
                                                 (Etempvar _x3 tint)
                                                 (Etempvar _x2 tint) tint)
                                               tint)
                                             (Ebinop Omul
                                               (Ebinop Osub
                                                 (Etempvar _x2 tint)
                                                 (Etempvar _x tint) tint)
                                               (Ebinop Osub
                                                 (Etempvar _z3 tint)
                                                 (Etempvar _z2 tint) tint)
                                               tint) tint)
                                           (Econst_int (Int.repr 0) tint)
                                           tint)
                              Scontinue
                              Sskip)
                            (Ssequence
                              (Sifthenelse (Ebinop Ogt
                                             (Ebinop Osub
                                               (Ebinop Omul
                                                 (Ebinop Osub
                                                   (Etempvar _z3 tint)
                                                   (Etempvar _z tint) tint)
                                                 (Ebinop Osub
                                                   (Etempvar _x1 tint)
                                                   (Etempvar _x3 tint) tint)
                                                 tint)
                                               (Ebinop Omul
                                                 (Ebinop Osub
                                                   (Etempvar _x3 tint)
                                                   (Etempvar _x tint) tint)
                                                 (Ebinop Osub
                                                   (Etempvar _z1 tint)
                                                   (Etempvar _z3 tint) tint)
                                                 tint) tint)
                                             (Econst_int (Int.repr 0) tint)
                                             tint)
                                Scontinue
                                Sskip)
                              (Ssequence
                                (Ssequence
                                  (Sset _t'1
                                    (Evar _gCheckingSurfaceCollisionsForCamera tshort))
                                  (Sifthenelse (Ebinop One
                                                 (Etempvar _t'1 tshort)
                                                 (Econst_int (Int.repr 0) tint)
                                                 tint)
                                    (Ssequence
                                      (Sset _t'3
                                        (Efield
                                          (Ederef
                                            (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                            (Tstruct _Surface noattr)) _flags
                                          tschar))
                                      (Sifthenelse (Ebinop Oand
                                                     (Etempvar _t'3 tschar)
                                                     (Ebinop Oshl
                                                       (Econst_int (Int.repr 1) tint)
                                                       (Econst_int (Int.repr 1) tint)
                                                       tint) tint)
                                        Scontinue
                                        Sskip))
                                    (Ssequence
                                      (Sset _t'2
                                        (Efield
                                          (Ederef
                                            (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                            (Tstruct _Surface noattr)) _type
                                          tshort))
                                      (Sifthenelse (Ebinop Oeq
                                                     (Etempvar _t'2 tshort)
                                                     (Econst_int (Int.repr 114) tint)
                                                     tint)
                                        Scontinue
                                        Sskip))))
                                (Ssequence
                                  (Sset _nx
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                          (Tstruct _Surface noattr)) _normal
                                        (Tstruct __732 noattr)) _x tfloat))
                                  (Ssequence
                                    (Sset _ny
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                            (Tstruct _Surface noattr))
                                          _normal (Tstruct __732 noattr)) _y
                                        tfloat))
                                    (Ssequence
                                      (Sset _nz
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                              (Tstruct _Surface noattr))
                                            _normal (Tstruct __732 noattr))
                                          _z tfloat))
                                      (Ssequence
                                        (Sset _oo
                                          (Efield
                                            (Ederef
                                              (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                              (Tstruct _Surface noattr))
                                            _originOffset tfloat))
                                        (Ssequence
                                          (Sifthenelse (Ebinop Oeq
                                                         (Etempvar _ny tfloat)
                                                         (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                                         tint)
                                            Scontinue
                                            Sskip)
                                          (Ssequence
                                            (Sset _height
                                              (Ebinop Odiv
                                                (Eunop Oneg
                                                  (Ebinop Oadd
                                                    (Ebinop Oadd
                                                      (Ebinop Omul
                                                        (Etempvar _x tint)
                                                        (Etempvar _nx tfloat)
                                                        tfloat)
                                                      (Ebinop Omul
                                                        (Etempvar _nz tfloat)
                                                        (Etempvar _z tint)
                                                        tfloat) tfloat)
                                                    (Etempvar _oo tfloat)
                                                    tfloat) tfloat)
                                                (Etempvar _ny tfloat) tfloat))
                                            (Ssequence
                                              (Sifthenelse (Ebinop Ogt
                                                             (Ebinop Osub
                                                               (Etempvar _y tint)
                                                               (Ebinop Osub
                                                                 (Etempvar _height tfloat)
                                                                 (Eunop Oneg
                                                                   (Econst_single (Float32.of_bits (Int.repr 1117519872)) tfloat)
                                                                   tfloat)
                                                                 tfloat)
                                                               tfloat)
                                                             (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                                             tint)
                                                Scontinue
                                                Sskip)
                                              (Ssequence
                                                (Sassign
                                                  (Ederef
                                                    (Etempvar _pheight (tptr tfloat))
                                                    tfloat)
                                                  (Etempvar _height tfloat))
                                                (Ssequence
                                                  (Sset _ceil
                                                    (Etempvar _surf (tptr (Tstruct _Surface noattr))))
                                                  Sbreak))))))))))))))))))))))
      (Sreturn (Some (Etempvar _ceil (tptr (Tstruct _Surface noattr))))))))
|}.

Definition f_find_ceil := {|
  fn_return := tfloat;
  fn_callconv := cc_default;
  fn_params := ((_posX, tfloat) :: (_posY, tfloat) :: (_posZ, tfloat) ::
                (_pceil, (tptr (tptr (Tstruct _Surface noattr)))) :: nil);
  fn_vars := ((_height, tfloat) :: (_dynamicHeight, tfloat) :: nil);
  fn_temps := ((_cellZ, tshort) :: (_cellX, tshort) ::
               (_ceil, (tptr (Tstruct _Surface noattr))) ::
               (_dynamicCeil, (tptr (Tstruct _Surface noattr))) ::
               (_surfaceList, (tptr (Tstruct _SurfaceNode noattr))) ::
               (_x, tshort) :: (_y, tshort) :: (_z, tshort) ::
               (_t'4, (tptr (Tstruct _Surface noattr))) ::
               (_t'3, (tptr (Tstruct _Surface noattr))) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'11, tfloat) :: (_t'10, tfloat) ::
               (_t'9, tfloat) :: (_t'8, tfloat) :: (_t'7, tfloat) ::
               (_t'6, tshort) :: (_t'5, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _height tfloat) (Econst_int (Int.repr 20000) tint))
  (Ssequence
    (Sassign (Evar _dynamicHeight tfloat) (Econst_int (Int.repr 20000) tint))
    (Ssequence
      (Sset _x (Ecast (Ecast (Etempvar _posX tfloat) tshort) tshort))
      (Ssequence
        (Sset _y (Ecast (Ecast (Etempvar _posY tfloat) tshort) tshort))
        (Ssequence
          (Sset _z (Ecast (Ecast (Etempvar _posZ tfloat) tshort) tshort))
          (Ssequence
            (Sassign
              (Ederef
                (Etempvar _pceil (tptr (tptr (Tstruct _Surface noattr))))
                (tptr (Tstruct _Surface noattr)))
              (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
            (Ssequence
              (Ssequence
                (Sifthenelse (Ebinop Ole (Etempvar _x tshort)
                               (Eunop Oneg (Econst_int (Int.repr 8192) tint)
                                 tint) tint)
                  (Sset _t'1 (Econst_int (Int.repr 1) tint))
                  (Sset _t'1
                    (Ecast
                      (Ebinop Oge (Etempvar _x tshort)
                        (Econst_int (Int.repr 8192) tint) tint) tbool)))
                (Sifthenelse (Etempvar _t'1 tint)
                  (Ssequence
                    (Sset _t'11 (Evar _height tfloat))
                    (Sreturn (Some (Etempvar _t'11 tfloat))))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sifthenelse (Ebinop Ole (Etempvar _z tshort)
                                 (Eunop Oneg
                                   (Econst_int (Int.repr 8192) tint) tint)
                                 tint)
                    (Sset _t'2 (Econst_int (Int.repr 1) tint))
                    (Sset _t'2
                      (Ecast
                        (Ebinop Oge (Etempvar _z tshort)
                          (Econst_int (Int.repr 8192) tint) tint) tbool)))
                  (Sifthenelse (Etempvar _t'2 tint)
                    (Ssequence
                      (Sset _t'10 (Evar _height tfloat))
                      (Sreturn (Some (Etempvar _t'10 tfloat))))
                    Sskip))
                (Ssequence
                  (Sset _cellX
                    (Ecast
                      (Ebinop Oand
                        (Ebinop Odiv
                          (Ebinop Oadd (Etempvar _x tshort)
                            (Econst_int (Int.repr 8192) tint) tint)
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 10) tint) tint) tint)
                        (Ebinop Osub
                          (Ebinop Odiv
                            (Ebinop Omul (Econst_int (Int.repr 2) tint)
                              (Econst_int (Int.repr 8192) tint) tint)
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 10) tint) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tint) tshort))
                  (Ssequence
                    (Sset _cellZ
                      (Ecast
                        (Ebinop Oand
                          (Ebinop Odiv
                            (Ebinop Oadd (Etempvar _z tshort)
                              (Econst_int (Int.repr 8192) tint) tint)
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 10) tint) tint) tint)
                          (Ebinop Osub
                            (Ebinop Odiv
                              (Ebinop Omul (Econst_int (Int.repr 2) tint)
                                (Econst_int (Int.repr 8192) tint) tint)
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 10) tint) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tint)
                        tshort))
                    (Ssequence
                      (Sset _surfaceList
                        (Efield
                          (Ederef
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
                              (Econst_int (Int.repr 1) tint)
                              (tptr (Tstruct _SurfaceNode noattr)))
                            (Tstruct _SurfaceNode noattr)) _next
                          (tptr (Tstruct _SurfaceNode noattr))))
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'3)
                            (Evar _find_ceil_from_list (Tfunction
                                                         ((tptr (Tstruct _SurfaceNode noattr)) ::
                                                          tint :: tint ::
                                                          tint ::
                                                          (tptr tfloat) ::
                                                          nil)
                                                         (tptr (Tstruct _Surface noattr))
                                                         cc_default))
                            ((Etempvar _surfaceList (tptr (Tstruct _SurfaceNode noattr))) ::
                             (Etempvar _x tshort) :: (Etempvar _y tshort) ::
                             (Etempvar _z tshort) ::
                             (Eaddrof (Evar _dynamicHeight tfloat)
                               (tptr tfloat)) :: nil))
                          (Sset _dynamicCeil
                            (Etempvar _t'3 (tptr (Tstruct _Surface noattr)))))
                        (Ssequence
                          (Sset _surfaceList
                            (Efield
                              (Ederef
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
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr (Tstruct _SurfaceNode noattr)))
                                (Tstruct _SurfaceNode noattr)) _next
                              (tptr (Tstruct _SurfaceNode noattr))))
                          (Ssequence
                            (Ssequence
                              (Scall (Some _t'4)
                                (Evar _find_ceil_from_list (Tfunction
                                                             ((tptr (Tstruct _SurfaceNode noattr)) ::
                                                              tint :: tint ::
                                                              tint ::
                                                              (tptr tfloat) ::
                                                              nil)
                                                             (tptr (Tstruct _Surface noattr))
                                                             cc_default))
                                ((Etempvar _surfaceList (tptr (Tstruct _SurfaceNode noattr))) ::
                                 (Etempvar _x tshort) ::
                                 (Etempvar _y tshort) ::
                                 (Etempvar _z tshort) ::
                                 (Eaddrof (Evar _height tfloat)
                                   (tptr tfloat)) :: nil))
                              (Sset _ceil
                                (Etempvar _t'4 (tptr (Tstruct _Surface noattr)))))
                            (Ssequence
                              (Ssequence
                                (Sset _t'7 (Evar _dynamicHeight tfloat))
                                (Ssequence
                                  (Sset _t'8 (Evar _height tfloat))
                                  (Sifthenelse (Ebinop Olt
                                                 (Etempvar _t'7 tfloat)
                                                 (Etempvar _t'8 tfloat) tint)
                                    (Ssequence
                                      (Sset _ceil
                                        (Etempvar _dynamicCeil (tptr (Tstruct _Surface noattr))))
                                      (Ssequence
                                        (Sset _t'9
                                          (Evar _dynamicHeight tfloat))
                                        (Sassign (Evar _height tfloat)
                                          (Etempvar _t'9 tfloat))))
                                    Sskip)))
                              (Ssequence
                                (Sassign
                                  (Ederef
                                    (Etempvar _pceil (tptr (tptr (Tstruct _Surface noattr))))
                                    (tptr (Tstruct _Surface noattr)))
                                  (Etempvar _ceil (tptr (Tstruct _Surface noattr))))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'6
                                      (Efield
                                        (Evar _gNumCalls (Tstruct _NumTimesCalled noattr))
                                        _ceil tshort))
                                    (Sassign
                                      (Efield
                                        (Evar _gNumCalls (Tstruct _NumTimesCalled noattr))
                                        _ceil tshort)
                                      (Ebinop Oadd (Etempvar _t'6 tshort)
                                        (Econst_int (Int.repr 1) tint) tint)))
                                  (Ssequence
                                    (Sset _t'5 (Evar _height tfloat))
                                    (Sreturn (Some (Etempvar _t'5 tfloat)))))))))))))))))))))
|}.

Definition f_unused_obj_find_floor_height := {|
  fn_return := tfloat;
  fn_callconv := cc_default;
  fn_params := ((_obj, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := ((_floor, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_temps := ((_floorHeight, tfloat) :: (_t'1, tfloat) :: (_t'4, tfloat) ::
               (_t'3, tfloat) :: (_t'2, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __727 noattr))
              _asF32 (tarray tfloat 80))
            (Ebinop Oadd (Econst_int (Int.repr 6) tint)
              (Econst_int (Int.repr 0) tint) tint) (tptr tfloat)) tfloat))
      (Ssequence
        (Sset _t'3
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __727 noattr))
                _asF32 (tarray tfloat 80))
              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                (Econst_int (Int.repr 1) tint) tint) (tptr tfloat)) tfloat))
        (Ssequence
          (Sset _t'4
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __727 noattr)) _asF32 (tarray tfloat 80))
                (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                  (Econst_int (Int.repr 2) tint) tint) (tptr tfloat)) tfloat))
          (Scall (Some _t'1)
            (Evar _find_floor (Tfunction
                                (tfloat :: tfloat :: tfloat ::
                                 (tptr (tptr (Tstruct _Surface noattr))) ::
                                 nil) tfloat cc_default))
            ((Etempvar _t'2 tfloat) :: (Etempvar _t'3 tfloat) ::
             (Etempvar _t'4 tfloat) ::
             (Eaddrof (Evar _floor (tptr (Tstruct _Surface noattr)))
               (tptr (tptr (Tstruct _Surface noattr)))) :: nil)))))
    (Sset _floorHeight (Etempvar _t'1 tfloat)))
  (Sreturn (Some (Etempvar _floorHeight tfloat))))
|}.

Definition v_sFloorGeo := {|
  gvar_info := (Tstruct _FloorGeometry noattr);
  gvar_init := (Init_space 32 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_find_floor_height_and_data := {|
  fn_return := tfloat;
  fn_callconv := cc_default;
  fn_params := ((_xPos, tfloat) :: (_yPos, tfloat) :: (_zPos, tfloat) ::
                (_floorGeo, (tptr (tptr (Tstruct _FloorGeometry noattr)))) ::
                nil);
  fn_vars := ((_floor, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_temps := ((_floorHeight, tfloat) :: (_t'1, tfloat) :: (_t'10, tfloat) ::
               (_t'9, (tptr (Tstruct _Surface noattr))) :: (_t'8, tfloat) ::
               (_t'7, (tptr (Tstruct _Surface noattr))) :: (_t'6, tfloat) ::
               (_t'5, (tptr (Tstruct _Surface noattr))) :: (_t'4, tfloat) ::
               (_t'3, (tptr (Tstruct _Surface noattr))) ::
               (_t'2, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _find_floor (Tfunction
                          (tfloat :: tfloat :: tfloat ::
                           (tptr (tptr (Tstruct _Surface noattr))) :: nil)
                          tfloat cc_default))
      ((Etempvar _xPos tfloat) :: (Etempvar _yPos tfloat) ::
       (Etempvar _zPos tfloat) ::
       (Eaddrof (Evar _floor (tptr (Tstruct _Surface noattr)))
         (tptr (tptr (Tstruct _Surface noattr)))) :: nil))
    (Sset _floorHeight (Etempvar _t'1 tfloat)))
  (Ssequence
    (Sassign
      (Ederef
        (Etempvar _floorGeo (tptr (tptr (Tstruct _FloorGeometry noattr))))
        (tptr (Tstruct _FloorGeometry noattr)))
      (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
    (Ssequence
      (Ssequence
        (Sset _t'2 (Evar _floor (tptr (Tstruct _Surface noattr))))
        (Sifthenelse (Ebinop One
                       (Etempvar _t'2 (tptr (Tstruct _Surface noattr)))
                       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                       tint)
          (Ssequence
            (Ssequence
              (Sset _t'9 (Evar _floor (tptr (Tstruct _Surface noattr))))
              (Ssequence
                (Sset _t'10
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _t'9 (tptr (Tstruct _Surface noattr)))
                        (Tstruct _Surface noattr)) _normal
                      (Tstruct __732 noattr)) _x tfloat))
                (Sassign
                  (Efield (Evar _sFloorGeo (Tstruct _FloorGeometry noattr))
                    _normalX tfloat) (Etempvar _t'10 tfloat))))
            (Ssequence
              (Ssequence
                (Sset _t'7 (Evar _floor (tptr (Tstruct _Surface noattr))))
                (Ssequence
                  (Sset _t'8
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'7 (tptr (Tstruct _Surface noattr)))
                          (Tstruct _Surface noattr)) _normal
                        (Tstruct __732 noattr)) _y tfloat))
                  (Sassign
                    (Efield (Evar _sFloorGeo (Tstruct _FloorGeometry noattr))
                      _normalY tfloat) (Etempvar _t'8 tfloat))))
              (Ssequence
                (Ssequence
                  (Sset _t'5 (Evar _floor (tptr (Tstruct _Surface noattr))))
                  (Ssequence
                    (Sset _t'6
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'5 (tptr (Tstruct _Surface noattr)))
                            (Tstruct _Surface noattr)) _normal
                          (Tstruct __732 noattr)) _z tfloat))
                    (Sassign
                      (Efield
                        (Evar _sFloorGeo (Tstruct _FloorGeometry noattr))
                        _normalZ tfloat) (Etempvar _t'6 tfloat))))
                (Ssequence
                  (Ssequence
                    (Sset _t'3
                      (Evar _floor (tptr (Tstruct _Surface noattr))))
                    (Ssequence
                      (Sset _t'4
                        (Efield
                          (Ederef
                            (Etempvar _t'3 (tptr (Tstruct _Surface noattr)))
                            (Tstruct _Surface noattr)) _originOffset tfloat))
                      (Sassign
                        (Efield
                          (Evar _sFloorGeo (Tstruct _FloorGeometry noattr))
                          _originOffset tfloat) (Etempvar _t'4 tfloat))))
                  (Sassign
                    (Ederef
                      (Etempvar _floorGeo (tptr (tptr (Tstruct _FloorGeometry noattr))))
                      (tptr (Tstruct _FloorGeometry noattr)))
                    (Eaddrof
                      (Evar _sFloorGeo (Tstruct _FloorGeometry noattr))
                      (tptr (Tstruct _FloorGeometry noattr))))))))
          Sskip))
      (Sreturn (Some (Etempvar _floorHeight tfloat))))))
|}.

Definition f_find_floor_from_list := {|
  fn_return := (tptr (Tstruct _Surface noattr));
  fn_callconv := cc_default;
  fn_params := ((_surfaceNode, (tptr (Tstruct _SurfaceNode noattr))) ::
                (_x, tint) :: (_y, tint) :: (_z, tint) ::
                (_pheight, (tptr tfloat)) :: nil);
  fn_vars := nil;
  fn_temps := ((_surf, (tptr (Tstruct _Surface noattr))) :: (_x1, tint) ::
               (_z1, tint) :: (_x2, tint) :: (_z2, tint) :: (_x3, tint) ::
               (_z3, tint) :: (_nx, tfloat) :: (_ny, tfloat) ::
               (_nz, tfloat) :: (_oo, tfloat) :: (_height, tfloat) ::
               (_floor, (tptr (Tstruct _Surface noattr))) ::
               (_t'3, tschar) :: (_t'2, tshort) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _floor (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Swhile
      (Ebinop One
        (Etempvar _surfaceNode (tptr (Tstruct _SurfaceNode noattr)))
        (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Sset _surf
          (Efield
            (Ederef
              (Etempvar _surfaceNode (tptr (Tstruct _SurfaceNode noattr)))
              (Tstruct _SurfaceNode noattr)) _surface
            (tptr (Tstruct _Surface noattr))))
        (Ssequence
          (Sset _surfaceNode
            (Efield
              (Ederef
                (Etempvar _surfaceNode (tptr (Tstruct _SurfaceNode noattr)))
                (Tstruct _SurfaceNode noattr)) _next
              (tptr (Tstruct _SurfaceNode noattr))))
          (Ssequence
            (Sset _x1
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                      (Tstruct _Surface noattr)) _vertex1 (tarray tshort 3))
                  (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
            (Ssequence
              (Sset _z1
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                        (Tstruct _Surface noattr)) _vertex1
                      (tarray tshort 3)) (Econst_int (Int.repr 2) tint)
                    (tptr tshort)) tshort))
              (Ssequence
                (Sset _x2
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                          (Tstruct _Surface noattr)) _vertex2
                        (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tshort)) tshort))
                (Ssequence
                  (Sset _z2
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                            (Tstruct _Surface noattr)) _vertex2
                          (tarray tshort 3)) (Econst_int (Int.repr 2) tint)
                        (tptr tshort)) tshort))
                  (Ssequence
                    (Sifthenelse (Ebinop Olt
                                   (Ebinop Osub
                                     (Ebinop Omul
                                       (Ebinop Osub (Etempvar _z1 tint)
                                         (Etempvar _z tint) tint)
                                       (Ebinop Osub (Etempvar _x2 tint)
                                         (Etempvar _x1 tint) tint) tint)
                                     (Ebinop Omul
                                       (Ebinop Osub (Etempvar _x1 tint)
                                         (Etempvar _x tint) tint)
                                       (Ebinop Osub (Etempvar _z2 tint)
                                         (Etempvar _z1 tint) tint) tint)
                                     tint) (Econst_int (Int.repr 0) tint)
                                   tint)
                      Scontinue
                      Sskip)
                    (Ssequence
                      (Sset _x3
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                (Tstruct _Surface noattr)) _vertex3
                              (tarray tshort 3))
                            (Econst_int (Int.repr 0) tint) (tptr tshort))
                          tshort))
                      (Ssequence
                        (Sset _z3
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                  (Tstruct _Surface noattr)) _vertex3
                                (tarray tshort 3))
                              (Econst_int (Int.repr 2) tint) (tptr tshort))
                            tshort))
                        (Ssequence
                          (Sifthenelse (Ebinop Olt
                                         (Ebinop Osub
                                           (Ebinop Omul
                                             (Ebinop Osub (Etempvar _z2 tint)
                                               (Etempvar _z tint) tint)
                                             (Ebinop Osub (Etempvar _x3 tint)
                                               (Etempvar _x2 tint) tint)
                                             tint)
                                           (Ebinop Omul
                                             (Ebinop Osub (Etempvar _x2 tint)
                                               (Etempvar _x tint) tint)
                                             (Ebinop Osub (Etempvar _z3 tint)
                                               (Etempvar _z2 tint) tint)
                                             tint) tint)
                                         (Econst_int (Int.repr 0) tint) tint)
                            Scontinue
                            Sskip)
                          (Ssequence
                            (Sifthenelse (Ebinop Olt
                                           (Ebinop Osub
                                             (Ebinop Omul
                                               (Ebinop Osub
                                                 (Etempvar _z3 tint)
                                                 (Etempvar _z tint) tint)
                                               (Ebinop Osub
                                                 (Etempvar _x1 tint)
                                                 (Etempvar _x3 tint) tint)
                                               tint)
                                             (Ebinop Omul
                                               (Ebinop Osub
                                                 (Etempvar _x3 tint)
                                                 (Etempvar _x tint) tint)
                                               (Ebinop Osub
                                                 (Etempvar _z1 tint)
                                                 (Etempvar _z3 tint) tint)
                                               tint) tint)
                                           (Econst_int (Int.repr 0) tint)
                                           tint)
                              Scontinue
                              Sskip)
                            (Ssequence
                              (Ssequence
                                (Sset _t'1
                                  (Evar _gCheckingSurfaceCollisionsForCamera tshort))
                                (Sifthenelse (Ebinop One
                                               (Etempvar _t'1 tshort)
                                               (Econst_int (Int.repr 0) tint)
                                               tint)
                                  (Ssequence
                                    (Sset _t'3
                                      (Efield
                                        (Ederef
                                          (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                          (Tstruct _Surface noattr)) _flags
                                        tschar))
                                    (Sifthenelse (Ebinop Oand
                                                   (Etempvar _t'3 tschar)
                                                   (Ebinop Oshl
                                                     (Econst_int (Int.repr 1) tint)
                                                     (Econst_int (Int.repr 1) tint)
                                                     tint) tint)
                                      Scontinue
                                      Sskip))
                                  (Ssequence
                                    (Sset _t'2
                                      (Efield
                                        (Ederef
                                          (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                          (Tstruct _Surface noattr)) _type
                                        tshort))
                                    (Sifthenelse (Ebinop Oeq
                                                   (Etempvar _t'2 tshort)
                                                   (Econst_int (Int.repr 114) tint)
                                                   tint)
                                      Scontinue
                                      Sskip))))
                              (Ssequence
                                (Sset _nx
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                        (Tstruct _Surface noattr)) _normal
                                      (Tstruct __732 noattr)) _x tfloat))
                                (Ssequence
                                  (Sset _ny
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                          (Tstruct _Surface noattr)) _normal
                                        (Tstruct __732 noattr)) _y tfloat))
                                  (Ssequence
                                    (Sset _nz
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                            (Tstruct _Surface noattr))
                                          _normal (Tstruct __732 noattr)) _z
                                        tfloat))
                                    (Ssequence
                                      (Sset _oo
                                        (Efield
                                          (Ederef
                                            (Etempvar _surf (tptr (Tstruct _Surface noattr)))
                                            (Tstruct _Surface noattr))
                                          _originOffset tfloat))
                                      (Ssequence
                                        (Sifthenelse (Ebinop Oeq
                                                       (Etempvar _ny tfloat)
                                                       (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                                       tint)
                                          Scontinue
                                          Sskip)
                                        (Ssequence
                                          (Sset _height
                                            (Ebinop Odiv
                                              (Eunop Oneg
                                                (Ebinop Oadd
                                                  (Ebinop Oadd
                                                    (Ebinop Omul
                                                      (Etempvar _x tint)
                                                      (Etempvar _nx tfloat)
                                                      tfloat)
                                                    (Ebinop Omul
                                                      (Etempvar _nz tfloat)
                                                      (Etempvar _z tint)
                                                      tfloat) tfloat)
                                                  (Etempvar _oo tfloat)
                                                  tfloat) tfloat)
                                              (Etempvar _ny tfloat) tfloat))
                                          (Ssequence
                                            (Sifthenelse (Ebinop Olt
                                                           (Ebinop Osub
                                                             (Etempvar _y tint)
                                                             (Ebinop Oadd
                                                               (Etempvar _height tfloat)
                                                               (Eunop Oneg
                                                                 (Econst_single (Float32.of_bits (Int.repr 1117519872)) tfloat)
                                                                 tfloat)
                                                               tfloat)
                                                             tfloat)
                                                           (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                                           tint)
                                              Scontinue
                                              Sskip)
                                            (Ssequence
                                              (Sassign
                                                (Ederef
                                                  (Etempvar _pheight (tptr tfloat))
                                                  tfloat)
                                                (Etempvar _height tfloat))
                                              (Ssequence
                                                (Sset _floor
                                                  (Etempvar _surf (tptr (Tstruct _Surface noattr))))
                                                Sbreak))))))))))))))))))))))
    (Sreturn (Some (Etempvar _floor (tptr (Tstruct _Surface noattr)))))))
|}.

Definition f_find_floor_height := {|
  fn_return := tfloat;
  fn_callconv := cc_default;
  fn_params := ((_x, tfloat) :: (_y, tfloat) :: (_z, tfloat) :: nil);
  fn_vars := ((_floor, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_temps := ((_floorHeight, tfloat) :: (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _find_floor (Tfunction
                          (tfloat :: tfloat :: tfloat ::
                           (tptr (tptr (Tstruct _Surface noattr))) :: nil)
                          tfloat cc_default))
      ((Etempvar _x tfloat) :: (Etempvar _y tfloat) ::
       (Etempvar _z tfloat) ::
       (Eaddrof (Evar _floor (tptr (Tstruct _Surface noattr)))
         (tptr (tptr (Tstruct _Surface noattr)))) :: nil))
    (Sset _floorHeight (Etempvar _t'1 tfloat)))
  (Sreturn (Some (Etempvar _floorHeight tfloat))))
|}.

Definition f_unused_find_dynamic_floor := {|
  fn_return := tfloat;
  fn_callconv := cc_default;
  fn_params := ((_xPos, tfloat) :: (_yPos, tfloat) :: (_zPos, tfloat) ::
                (_pfloor, (tptr (tptr (Tstruct _Surface noattr)))) :: nil);
  fn_vars := ((_floorHeight, tfloat) :: nil);
  fn_temps := ((_surfaceList, (tptr (Tstruct _SurfaceNode noattr))) ::
               (_floor, (tptr (Tstruct _Surface noattr))) :: (_x, tshort) ::
               (_y, tshort) :: (_z, tshort) :: (_cellX, tshort) ::
               (_cellZ, tshort) ::
               (_t'1, (tptr (Tstruct _Surface noattr))) :: (_t'2, tfloat) ::
               nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _floorHeight tfloat)
    (Eunop Oneg (Econst_int (Int.repr 11000) tint) tint))
  (Ssequence
    (Sset _x (Ecast (Ecast (Etempvar _xPos tfloat) tshort) tshort))
    (Ssequence
      (Sset _y (Ecast (Ecast (Etempvar _yPos tfloat) tshort) tshort))
      (Ssequence
        (Sset _z (Ecast (Ecast (Etempvar _zPos tfloat) tshort) tshort))
        (Ssequence
          (Sset _cellX
            (Ecast
              (Ebinop Oand
                (Ebinop Odiv
                  (Ebinop Oadd (Etempvar _x tshort)
                    (Econst_int (Int.repr 8192) tint) tint)
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 10) tint) tint) tint)
                (Ebinop Osub
                  (Ebinop Odiv
                    (Ebinop Omul (Econst_int (Int.repr 2) tint)
                      (Econst_int (Int.repr 8192) tint) tint)
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 10) tint) tint) tint)
                  (Econst_int (Int.repr 1) tint) tint) tint) tshort))
          (Ssequence
            (Sset _cellZ
              (Ecast
                (Ebinop Oand
                  (Ebinop Odiv
                    (Ebinop Oadd (Etempvar _z tshort)
                      (Econst_int (Int.repr 8192) tint) tint)
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 10) tint) tint) tint)
                  (Ebinop Osub
                    (Ebinop Odiv
                      (Ebinop Omul (Econst_int (Int.repr 2) tint)
                        (Econst_int (Int.repr 8192) tint) tint)
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 10) tint) tint) tint)
                    (Econst_int (Int.repr 1) tint) tint) tint) tshort))
            (Ssequence
              (Sset _surfaceList
                (Efield
                  (Ederef
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
                      (Econst_int (Int.repr 0) tint)
                      (tptr (Tstruct _SurfaceNode noattr)))
                    (Tstruct _SurfaceNode noattr)) _next
                  (tptr (Tstruct _SurfaceNode noattr))))
              (Ssequence
                (Ssequence
                  (Scall (Some _t'1)
                    (Evar _find_floor_from_list (Tfunction
                                                  ((tptr (Tstruct _SurfaceNode noattr)) ::
                                                   tint :: tint :: tint ::
                                                   (tptr tfloat) :: nil)
                                                  (tptr (Tstruct _Surface noattr))
                                                  cc_default))
                    ((Etempvar _surfaceList (tptr (Tstruct _SurfaceNode noattr))) ::
                     (Etempvar _x tshort) :: (Etempvar _y tshort) ::
                     (Etempvar _z tshort) ::
                     (Eaddrof (Evar _floorHeight tfloat) (tptr tfloat)) ::
                     nil))
                  (Sset _floor
                    (Etempvar _t'1 (tptr (Tstruct _Surface noattr)))))
                (Ssequence
                  (Sassign
                    (Ederef
                      (Etempvar _pfloor (tptr (tptr (Tstruct _Surface noattr))))
                      (tptr (Tstruct _Surface noattr)))
                    (Etempvar _floor (tptr (Tstruct _Surface noattr))))
                  (Ssequence
                    (Sset _t'2 (Evar _floorHeight tfloat))
                    (Sreturn (Some (Etempvar _t'2 tfloat)))))))))))))
|}.

Definition f_find_floor := {|
  fn_return := tfloat;
  fn_callconv := cc_default;
  fn_params := ((_xPos, tfloat) :: (_yPos, tfloat) :: (_zPos, tfloat) ::
                (_pfloor, (tptr (tptr (Tstruct _Surface noattr)))) :: nil);
  fn_vars := ((_height, tfloat) :: (_dynamicHeight, tfloat) :: nil);
  fn_temps := ((_cellZ, tshort) :: (_cellX, tshort) ::
               (_floor, (tptr (Tstruct _Surface noattr))) ::
               (_dynamicFloor, (tptr (Tstruct _Surface noattr))) ::
               (_surfaceList, (tptr (Tstruct _SurfaceNode noattr))) ::
               (_x, tshort) :: (_y, tshort) :: (_z, tshort) ::
               (_t'6, tint) :: (_t'5, (tptr (Tstruct _Surface noattr))) ::
               (_t'4, (tptr (Tstruct _Surface noattr))) ::
               (_t'3, (tptr (Tstruct _Surface noattr))) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'17, tfloat) :: (_t'16, tfloat) ::
               (_t'15, tshort) :: (_t'14, tfloat) :: (_t'13, tshort) ::
               (_t'12, tint) :: (_t'11, tfloat) :: (_t'10, tfloat) ::
               (_t'9, tfloat) :: (_t'8, tshort) :: (_t'7, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _height tfloat)
    (Eunop Oneg (Econst_int (Int.repr 11000) tint) tint))
  (Ssequence
    (Sassign (Evar _dynamicHeight tfloat)
      (Eunop Oneg (Econst_int (Int.repr 11000) tint) tint))
    (Ssequence
      (Sset _x (Ecast (Ecast (Etempvar _xPos tfloat) tshort) tshort))
      (Ssequence
        (Sset _y (Ecast (Ecast (Etempvar _yPos tfloat) tshort) tshort))
        (Ssequence
          (Sset _z (Ecast (Ecast (Etempvar _zPos tfloat) tshort) tshort))
          (Ssequence
            (Sassign
              (Ederef
                (Etempvar _pfloor (tptr (tptr (Tstruct _Surface noattr))))
                (tptr (Tstruct _Surface noattr)))
              (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
            (Ssequence
              (Ssequence
                (Sifthenelse (Ebinop Ole (Etempvar _x tshort)
                               (Eunop Oneg (Econst_int (Int.repr 8192) tint)
                                 tint) tint)
                  (Sset _t'1 (Econst_int (Int.repr 1) tint))
                  (Sset _t'1
                    (Ecast
                      (Ebinop Oge (Etempvar _x tshort)
                        (Econst_int (Int.repr 8192) tint) tint) tbool)))
                (Sifthenelse (Etempvar _t'1 tint)
                  (Ssequence
                    (Sset _t'17 (Evar _height tfloat))
                    (Sreturn (Some (Etempvar _t'17 tfloat))))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sifthenelse (Ebinop Ole (Etempvar _z tshort)
                                 (Eunop Oneg
                                   (Econst_int (Int.repr 8192) tint) tint)
                                 tint)
                    (Sset _t'2 (Econst_int (Int.repr 1) tint))
                    (Sset _t'2
                      (Ecast
                        (Ebinop Oge (Etempvar _z tshort)
                          (Econst_int (Int.repr 8192) tint) tint) tbool)))
                  (Sifthenelse (Etempvar _t'2 tint)
                    (Ssequence
                      (Sset _t'16 (Evar _height tfloat))
                      (Sreturn (Some (Etempvar _t'16 tfloat))))
                    Sskip))
                (Ssequence
                  (Sset _cellX
                    (Ecast
                      (Ebinop Oand
                        (Ebinop Odiv
                          (Ebinop Oadd (Etempvar _x tshort)
                            (Econst_int (Int.repr 8192) tint) tint)
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 10) tint) tint) tint)
                        (Ebinop Osub
                          (Ebinop Odiv
                            (Ebinop Omul (Econst_int (Int.repr 2) tint)
                              (Econst_int (Int.repr 8192) tint) tint)
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 10) tint) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tint) tshort))
                  (Ssequence
                    (Sset _cellZ
                      (Ecast
                        (Ebinop Oand
                          (Ebinop Odiv
                            (Ebinop Oadd (Etempvar _z tshort)
                              (Econst_int (Int.repr 8192) tint) tint)
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 10) tint) tint) tint)
                          (Ebinop Osub
                            (Ebinop Odiv
                              (Ebinop Omul (Econst_int (Int.repr 2) tint)
                                (Econst_int (Int.repr 8192) tint) tint)
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 10) tint) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tint)
                        tshort))
                    (Ssequence
                      (Sset _surfaceList
                        (Efield
                          (Ederef
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
                              (Econst_int (Int.repr 0) tint)
                              (tptr (Tstruct _SurfaceNode noattr)))
                            (Tstruct _SurfaceNode noattr)) _next
                          (tptr (Tstruct _SurfaceNode noattr))))
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'3)
                            (Evar _find_floor_from_list (Tfunction
                                                          ((tptr (Tstruct _SurfaceNode noattr)) ::
                                                           tint :: tint ::
                                                           tint ::
                                                           (tptr tfloat) ::
                                                           nil)
                                                          (tptr (Tstruct _Surface noattr))
                                                          cc_default))
                            ((Etempvar _surfaceList (tptr (Tstruct _SurfaceNode noattr))) ::
                             (Etempvar _x tshort) :: (Etempvar _y tshort) ::
                             (Etempvar _z tshort) ::
                             (Eaddrof (Evar _dynamicHeight tfloat)
                               (tptr tfloat)) :: nil))
                          (Sset _dynamicFloor
                            (Etempvar _t'3 (tptr (Tstruct _Surface noattr)))))
                        (Ssequence
                          (Sset _surfaceList
                            (Efield
                              (Ederef
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
                                  (Econst_int (Int.repr 0) tint)
                                  (tptr (Tstruct _SurfaceNode noattr)))
                                (Tstruct _SurfaceNode noattr)) _next
                              (tptr (Tstruct _SurfaceNode noattr))))
                          (Ssequence
                            (Ssequence
                              (Scall (Some _t'4)
                                (Evar _find_floor_from_list (Tfunction
                                                              ((tptr (Tstruct _SurfaceNode noattr)) ::
                                                               tint ::
                                                               tint ::
                                                               tint ::
                                                               (tptr tfloat) ::
                                                               nil)
                                                              (tptr (Tstruct _Surface noattr))
                                                              cc_default))
                                ((Etempvar _surfaceList (tptr (Tstruct _SurfaceNode noattr))) ::
                                 (Etempvar _x tshort) ::
                                 (Etempvar _y tshort) ::
                                 (Etempvar _z tshort) ::
                                 (Eaddrof (Evar _height tfloat)
                                   (tptr tfloat)) :: nil))
                              (Sset _floor
                                (Etempvar _t'4 (tptr (Tstruct _Surface noattr)))))
                            (Ssequence
                              (Ssequence
                                (Sset _t'13
                                  (Evar _gFindFloorIncludeSurfaceIntangible tshort))
                                (Sifthenelse (Eunop Onotbool
                                               (Etempvar _t'13 tshort) tint)
                                  (Ssequence
                                    (Sifthenelse (Ebinop One
                                                   (Etempvar _floor (tptr (Tstruct _Surface noattr)))
                                                   (Ecast
                                                     (Econst_int (Int.repr 0) tint)
                                                     (tptr tvoid)) tint)
                                      (Ssequence
                                        (Sset _t'15
                                          (Efield
                                            (Ederef
                                              (Etempvar _floor (tptr (Tstruct _Surface noattr)))
                                              (Tstruct _Surface noattr))
                                            _type tshort))
                                        (Sset _t'6
                                          (Ecast
                                            (Ebinop Oeq
                                              (Etempvar _t'15 tshort)
                                              (Econst_int (Int.repr 18) tint)
                                              tint) tbool)))
                                      (Sset _t'6
                                        (Econst_int (Int.repr 0) tint)))
                                    (Sifthenelse (Etempvar _t'6 tint)
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'14 (Evar _height tfloat))
                                          (Scall (Some _t'5)
                                            (Evar _find_floor_from_list 
                                            (Tfunction
                                              ((tptr (Tstruct _SurfaceNode noattr)) ::
                                               tint :: tint :: tint ::
                                               (tptr tfloat) :: nil)
                                              (tptr (Tstruct _Surface noattr))
                                              cc_default))
                                            ((Etempvar _surfaceList (tptr (Tstruct _SurfaceNode noattr))) ::
                                             (Etempvar _x tshort) ::
                                             (Ecast
                                               (Ebinop Osub
                                                 (Etempvar _t'14 tfloat)
                                                 (Econst_single (Float32.of_bits (Int.repr 1128792064)) tfloat)
                                                 tfloat) tint) ::
                                             (Etempvar _z tshort) ::
                                             (Eaddrof (Evar _height tfloat)
                                               (tptr tfloat)) :: nil)))
                                        (Sset _floor
                                          (Etempvar _t'5 (tptr (Tstruct _Surface noattr)))))
                                      Sskip))
                                  (Sassign
                                    (Evar _gFindFloorIncludeSurfaceIntangible tshort)
                                    (Econst_int (Int.repr 0) tint))))
                              (Ssequence
                                (Sifthenelse (Ebinop Oeq
                                               (Etempvar _floor (tptr (Tstruct _Surface noattr)))
                                               (Ecast
                                                 (Econst_int (Int.repr 0) tint)
                                                 (tptr tvoid)) tint)
                                  (Ssequence
                                    (Sset _t'12
                                      (Evar _gNumFindFloorMisses tint))
                                    (Sassign (Evar _gNumFindFloorMisses tint)
                                      (Ebinop Oadd (Etempvar _t'12 tint)
                                        (Econst_int (Int.repr 1) tint) tint)))
                                  Sskip)
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'9 (Evar _dynamicHeight tfloat))
                                    (Ssequence
                                      (Sset _t'10 (Evar _height tfloat))
                                      (Sifthenelse (Ebinop Ogt
                                                     (Etempvar _t'9 tfloat)
                                                     (Etempvar _t'10 tfloat)
                                                     tint)
                                        (Ssequence
                                          (Sset _floor
                                            (Etempvar _dynamicFloor (tptr (Tstruct _Surface noattr))))
                                          (Ssequence
                                            (Sset _t'11
                                              (Evar _dynamicHeight tfloat))
                                            (Sassign (Evar _height tfloat)
                                              (Etempvar _t'11 tfloat))))
                                        Sskip)))
                                  (Ssequence
                                    (Sassign
                                      (Ederef
                                        (Etempvar _pfloor (tptr (tptr (Tstruct _Surface noattr))))
                                        (tptr (Tstruct _Surface noattr)))
                                      (Etempvar _floor (tptr (Tstruct _Surface noattr))))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'8
                                          (Efield
                                            (Evar _gNumCalls (Tstruct _NumTimesCalled noattr))
                                            _floor tshort))
                                        (Sassign
                                          (Efield
                                            (Evar _gNumCalls (Tstruct _NumTimesCalled noattr))
                                            _floor tshort)
                                          (Ebinop Oadd (Etempvar _t'8 tshort)
                                            (Econst_int (Int.repr 1) tint)
                                            tint)))
                                      (Ssequence
                                        (Sset _t'7 (Evar _height tfloat))
                                        (Sreturn (Some (Etempvar _t'7 tfloat)))))))))))))))))))))))
|}.

Definition f_find_water_level := {|
  fn_return := tfloat;
  fn_callconv := cc_default;
  fn_params := ((_x, tfloat) :: (_z, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_numRegions, tint) :: (_val, tshort) ::
               (_loX, tfloat) :: (_hiX, tfloat) :: (_loZ, tfloat) ::
               (_hiZ, tfloat) :: (_waterLevel, tfloat) ::
               (_p, (tptr tshort)) :: (_t'10, tint) :: (_t'9, tint) ::
               (_t'8, tint) :: (_t'7, tint) :: (_t'6, (tptr tshort)) ::
               (_t'5, (tptr tshort)) :: (_t'4, (tptr tshort)) ::
               (_t'3, (tptr tshort)) :: (_t'2, (tptr tshort)) ::
               (_t'1, (tptr tshort)) :: (_t'16, tshort) :: (_t'15, tshort) ::
               (_t'14, tshort) :: (_t'13, tshort) :: (_t'12, tshort) ::
               (_t'11, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _waterLevel
    (Ecast (Eunop Oneg (Econst_int (Int.repr 11000) tint) tint) tfloat))
  (Ssequence
    (Sset _p (Evar _gEnvironmentRegions (tptr tshort)))
    (Ssequence
      (Sifthenelse (Ebinop One (Etempvar _p (tptr tshort))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'1 (Etempvar _p (tptr tshort)))
              (Sset _p
                (Ebinop Oadd (Etempvar _t'1 (tptr tshort))
                  (Econst_int (Int.repr 1) tint) (tptr tshort))))
            (Sset _numRegions (Ederef (Etempvar _t'1 (tptr tshort)) tshort)))
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
                      (Sset _t'2 (Etempvar _p (tptr tshort)))
                      (Sset _p
                        (Ebinop Oadd (Etempvar _t'2 (tptr tshort))
                          (Econst_int (Int.repr 1) tint) (tptr tshort))))
                    (Ssequence
                      (Sset _t'16
                        (Ederef (Etempvar _t'2 (tptr tshort)) tshort))
                      (Sset _val (Ecast (Etempvar _t'16 tshort) tshort))))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'3 (Etempvar _p (tptr tshort)))
                        (Sset _p
                          (Ebinop Oadd (Etempvar _t'3 (tptr tshort))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))))
                      (Ssequence
                        (Sset _t'15
                          (Ederef (Etempvar _t'3 (tptr tshort)) tshort))
                        (Sset _loX (Ecast (Etempvar _t'15 tshort) tfloat))))
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'4 (Etempvar _p (tptr tshort)))
                          (Sset _p
                            (Ebinop Oadd (Etempvar _t'4 (tptr tshort))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))))
                        (Ssequence
                          (Sset _t'14
                            (Ederef (Etempvar _t'4 (tptr tshort)) tshort))
                          (Sset _loZ (Ecast (Etempvar _t'14 tshort) tfloat))))
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'5 (Etempvar _p (tptr tshort)))
                            (Sset _p
                              (Ebinop Oadd (Etempvar _t'5 (tptr tshort))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))))
                          (Ssequence
                            (Sset _t'13
                              (Ederef (Etempvar _t'5 (tptr tshort)) tshort))
                            (Sset _hiX
                              (Ecast (Etempvar _t'13 tshort) tfloat))))
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Sset _t'6 (Etempvar _p (tptr tshort)))
                              (Sset _p
                                (Ebinop Oadd (Etempvar _t'6 (tptr tshort))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tshort))))
                            (Ssequence
                              (Sset _t'12
                                (Ederef (Etempvar _t'6 (tptr tshort)) tshort))
                              (Sset _hiZ
                                (Ecast (Etempvar _t'12 tshort) tfloat))))
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Ssequence
                                  (Ssequence
                                    (Sifthenelse (Ebinop Olt
                                                   (Etempvar _loX tfloat)
                                                   (Etempvar _x tfloat) tint)
                                      (Sset _t'7
                                        (Ecast
                                          (Ebinop Olt (Etempvar _x tfloat)
                                            (Etempvar _hiX tfloat) tint)
                                          tbool))
                                      (Sset _t'7
                                        (Econst_int (Int.repr 0) tint)))
                                    (Sifthenelse (Etempvar _t'7 tint)
                                      (Sset _t'8
                                        (Ecast
                                          (Ebinop Olt (Etempvar _loZ tfloat)
                                            (Etempvar _z tfloat) tint) tbool))
                                      (Sset _t'8
                                        (Econst_int (Int.repr 0) tint))))
                                  (Sifthenelse (Etempvar _t'8 tint)
                                    (Sset _t'9
                                      (Ecast
                                        (Ebinop Olt (Etempvar _z tfloat)
                                          (Etempvar _hiZ tfloat) tint) tbool))
                                    (Sset _t'9
                                      (Econst_int (Int.repr 0) tint))))
                                (Sifthenelse (Etempvar _t'9 tint)
                                  (Sset _t'10
                                    (Ecast
                                      (Ebinop Olt (Etempvar _val tshort)
                                        (Econst_int (Int.repr 50) tint) tint)
                                      tbool))
                                  (Sset _t'10 (Econst_int (Int.repr 0) tint))))
                              (Sifthenelse (Etempvar _t'10 tint)
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'11
                                      (Ederef (Etempvar _p (tptr tshort))
                                        tshort))
                                    (Sset _waterLevel
                                      (Ecast (Etempvar _t'11 tshort) tfloat)))
                                  Sbreak)
                                Sskip))
                            (Sset _p
                              (Ebinop Oadd (Etempvar _p (tptr tshort))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))))))))))
              (Sset _i
                (Ebinop Oadd (Etempvar _i tint)
                  (Econst_int (Int.repr 1) tint) tint)))))
        Sskip)
      (Sreturn (Some (Etempvar _waterLevel tfloat))))))
|}.

Definition f_find_poison_gas_level := {|
  fn_return := tfloat;
  fn_callconv := cc_default;
  fn_params := ((_x, tfloat) :: (_z, tfloat) :: nil);
  fn_vars := ((_filler, (tarray tuchar 4)) :: nil);
  fn_temps := ((_i, tint) :: (_numRegions, tint) :: (_val, tshort) ::
               (_loX, tfloat) :: (_hiX, tfloat) :: (_loZ, tfloat) ::
               (_hiZ, tfloat) :: (_gasLevel, tfloat) ::
               (_p, (tptr tshort)) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, (tptr tshort)) ::
               (_t'11, tshort) :: (_t'10, tshort) :: (_t'9, tshort) ::
               (_t'8, tshort) :: (_t'7, tshort) :: (_t'6, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _gasLevel
    (Ecast (Eunop Oneg (Econst_int (Int.repr 11000) tint) tint) tfloat))
  (Ssequence
    (Sset _p (Evar _gEnvironmentRegions (tptr tshort)))
    (Ssequence
      (Sifthenelse (Ebinop One (Etempvar _p (tptr tshort))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'1 (Etempvar _p (tptr tshort)))
              (Sset _p
                (Ebinop Oadd (Etempvar _t'1 (tptr tshort))
                  (Econst_int (Int.repr 1) tint) (tptr tshort))))
            (Sset _numRegions (Ederef (Etempvar _t'1 (tptr tshort)) tshort)))
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
                    (Sset _t'11 (Ederef (Etempvar _p (tptr tshort)) tshort))
                    (Sset _val (Ecast (Etempvar _t'11 tshort) tshort)))
                  (Ssequence
                    (Sifthenelse (Ebinop Oge (Etempvar _val tshort)
                                   (Econst_int (Int.repr 50) tint) tint)
                      (Ssequence
                        (Ssequence
                          (Sset _t'10
                            (Ederef
                              (Ebinop Oadd (Etempvar _p (tptr tshort))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))
                              tshort))
                          (Sset _loX (Ecast (Etempvar _t'10 tshort) tfloat)))
                        (Ssequence
                          (Ssequence
                            (Sset _t'9
                              (Ederef
                                (Ebinop Oadd (Etempvar _p (tptr tshort))
                                  (Econst_int (Int.repr 2) tint)
                                  (tptr tshort)) tshort))
                            (Sset _loZ (Ecast (Etempvar _t'9 tshort) tfloat)))
                          (Ssequence
                            (Ssequence
                              (Sset _t'8
                                (Ederef
                                  (Ebinop Oadd (Etempvar _p (tptr tshort))
                                    (Econst_int (Int.repr 3) tint)
                                    (tptr tshort)) tshort))
                              (Sset _hiX
                                (Ecast (Etempvar _t'8 tshort) tfloat)))
                            (Ssequence
                              (Ssequence
                                (Sset _t'7
                                  (Ederef
                                    (Ebinop Oadd (Etempvar _p (tptr tshort))
                                      (Econst_int (Int.repr 4) tint)
                                      (tptr tshort)) tshort))
                                (Sset _hiZ
                                  (Ecast (Etempvar _t'7 tshort) tfloat)))
                              (Ssequence
                                (Ssequence
                                  (Ssequence
                                    (Ssequence
                                      (Sifthenelse (Ebinop Olt
                                                     (Etempvar _loX tfloat)
                                                     (Etempvar _x tfloat)
                                                     tint)
                                        (Sset _t'2
                                          (Ecast
                                            (Ebinop Olt (Etempvar _x tfloat)
                                              (Etempvar _hiX tfloat) tint)
                                            tbool))
                                        (Sset _t'2
                                          (Econst_int (Int.repr 0) tint)))
                                      (Sifthenelse (Etempvar _t'2 tint)
                                        (Sset _t'3
                                          (Ecast
                                            (Ebinop Olt
                                              (Etempvar _loZ tfloat)
                                              (Etempvar _z tfloat) tint)
                                            tbool))
                                        (Sset _t'3
                                          (Econst_int (Int.repr 0) tint))))
                                    (Sifthenelse (Etempvar _t'3 tint)
                                      (Sset _t'4
                                        (Ecast
                                          (Ebinop Olt (Etempvar _z tfloat)
                                            (Etempvar _hiZ tfloat) tint)
                                          tbool))
                                      (Sset _t'4
                                        (Econst_int (Int.repr 0) tint))))
                                  (Sifthenelse (Etempvar _t'4 tint)
                                    (Sset _t'5
                                      (Ecast
                                        (Ebinop Oeq
                                          (Ebinop Omod (Etempvar _val tshort)
                                            (Econst_int (Int.repr 10) tint)
                                            tint)
                                          (Econst_int (Int.repr 0) tint)
                                          tint) tbool))
                                    (Sset _t'5
                                      (Econst_int (Int.repr 0) tint))))
                                (Sifthenelse (Etempvar _t'5 tint)
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'6
                                        (Ederef
                                          (Ebinop Oadd
                                            (Etempvar _p (tptr tshort))
                                            (Econst_int (Int.repr 5) tint)
                                            (tptr tshort)) tshort))
                                      (Sset _gasLevel
                                        (Ecast (Etempvar _t'6 tshort) tfloat)))
                                    Sbreak)
                                  Sskip))))))
                      Sskip)
                    (Sset _p
                      (Ebinop Oadd (Etempvar _p (tptr tshort))
                        (Econst_int (Int.repr 6) tint) (tptr tshort))))))
              (Sset _i
                (Ebinop Oadd (Etempvar _i tint)
                  (Econst_int (Int.repr 1) tint) tint)))))
        Sskip)
      (Sreturn (Some (Etempvar _gasLevel tfloat))))))
|}.

Definition f_surface_list_length := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_list, (tptr (Tstruct _SurfaceNode noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_count, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _count (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Swhile
      (Ebinop One (Etempvar _list (tptr (Tstruct _SurfaceNode noattr)))
        (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Sset _list
          (Efield
            (Ederef (Etempvar _list (tptr (Tstruct _SurfaceNode noattr)))
              (Tstruct _SurfaceNode noattr)) _next
            (tptr (Tstruct _SurfaceNode noattr))))
        (Sset _count
          (Ebinop Oadd (Etempvar _count tint) (Econst_int (Int.repr 1) tint)
            tint))))
    (Sreturn (Some (Etempvar _count tint)))))
|}.

Definition f_debug_surface_list_info := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_xPos, tfloat) :: (_zPos, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_list, (tptr (Tstruct _SurfaceNode noattr))) ::
               (_numFloors, tint) :: (_numWalls, tint) ::
               (_numCeils, tint) :: (_cellX, tint) :: (_cellZ, tint) ::
               (_t'6, tint) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'13, tshort) :: (_t'12, tshort) :: (_t'11, tshort) ::
               (_t'10, tint) :: (_t'9, tint) :: (_t'8, tint) ::
               (_t'7, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _numFloors (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sset _numWalls (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Sset _numCeils (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Sset _cellX
          (Ecast
            (Ebinop Odiv
              (Ebinop Oadd (Etempvar _xPos tfloat)
                (Econst_int (Int.repr 8192) tint) tfloat)
              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 10) tint) tint) tfloat) tint))
        (Ssequence
          (Sset _cellZ
            (Ecast
              (Ebinop Odiv
                (Ebinop Oadd (Etempvar _zPos tfloat)
                  (Econst_int (Int.repr 8192) tint) tfloat)
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 10) tint) tint) tfloat) tint))
          (Ssequence
            (Sset _list
              (Efield
                (Ederef
                  (Ebinop Oadd
                    (Ederef
                      (Ebinop Oadd
                        (Ederef
                          (Ebinop Oadd
                            (Evar _gStaticSurfacePartition (tarray (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16) 16))
                            (Ebinop Oand (Etempvar _cellZ tint)
                              (Ebinop Osub
                                (Ebinop Odiv
                                  (Ebinop Omul (Econst_int (Int.repr 2) tint)
                                    (Econst_int (Int.repr 8192) tint) tint)
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 10) tint) tint)
                                  tint) (Econst_int (Int.repr 1) tint) tint)
                              tint)
                            (tptr (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16)))
                          (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16))
                        (Ebinop Oand (Etempvar _cellX tint)
                          (Ebinop Osub
                            (Ebinop Odiv
                              (Ebinop Omul (Econst_int (Int.repr 2) tint)
                                (Econst_int (Int.repr 8192) tint) tint)
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 10) tint) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tint)
                        (tptr (tarray (Tstruct _SurfaceNode noattr) 3)))
                      (tarray (Tstruct _SurfaceNode noattr) 3))
                    (Econst_int (Int.repr 0) tint)
                    (tptr (Tstruct _SurfaceNode noattr)))
                  (Tstruct _SurfaceNode noattr)) _next
                (tptr (Tstruct _SurfaceNode noattr))))
            (Ssequence
              (Ssequence
                (Scall (Some _t'1)
                  (Evar _surface_list_length (Tfunction
                                               ((tptr (Tstruct _SurfaceNode noattr)) ::
                                                nil) tint cc_default))
                  ((Etempvar _list (tptr (Tstruct _SurfaceNode noattr))) ::
                   nil))
                (Sset _numFloors
                  (Ebinop Oadd (Etempvar _numFloors tint)
                    (Etempvar _t'1 tint) tint)))
              (Ssequence
                (Sset _list
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Ederef
                          (Ebinop Oadd
                            (Ederef
                              (Ebinop Oadd
                                (Evar _gDynamicSurfacePartition (tarray (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16) 16))
                                (Ebinop Oand (Etempvar _cellZ tint)
                                  (Ebinop Osub
                                    (Ebinop Odiv
                                      (Ebinop Omul
                                        (Econst_int (Int.repr 2) tint)
                                        (Econst_int (Int.repr 8192) tint)
                                        tint)
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 10) tint) tint)
                                      tint) (Econst_int (Int.repr 1) tint)
                                    tint) tint)
                                (tptr (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16)))
                              (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16))
                            (Ebinop Oand (Etempvar _cellX tint)
                              (Ebinop Osub
                                (Ebinop Odiv
                                  (Ebinop Omul (Econst_int (Int.repr 2) tint)
                                    (Econst_int (Int.repr 8192) tint) tint)
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 10) tint) tint)
                                  tint) (Econst_int (Int.repr 1) tint) tint)
                              tint)
                            (tptr (tarray (Tstruct _SurfaceNode noattr) 3)))
                          (tarray (Tstruct _SurfaceNode noattr) 3))
                        (Econst_int (Int.repr 0) tint)
                        (tptr (Tstruct _SurfaceNode noattr)))
                      (Tstruct _SurfaceNode noattr)) _next
                    (tptr (Tstruct _SurfaceNode noattr))))
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'2)
                      (Evar _surface_list_length (Tfunction
                                                   ((tptr (Tstruct _SurfaceNode noattr)) ::
                                                    nil) tint cc_default))
                      ((Etempvar _list (tptr (Tstruct _SurfaceNode noattr))) ::
                       nil))
                    (Sset _numFloors
                      (Ebinop Oadd (Etempvar _numFloors tint)
                        (Etempvar _t'2 tint) tint)))
                  (Ssequence
                    (Sset _list
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Ederef
                              (Ebinop Oadd
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _gStaticSurfacePartition (tarray (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16) 16))
                                    (Ebinop Oand (Etempvar _cellZ tint)
                                      (Ebinop Osub
                                        (Ebinop Odiv
                                          (Ebinop Omul
                                            (Econst_int (Int.repr 2) tint)
                                            (Econst_int (Int.repr 8192) tint)
                                            tint)
                                          (Ebinop Oshl
                                            (Econst_int (Int.repr 1) tint)
                                            (Econst_int (Int.repr 10) tint)
                                            tint) tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tint)
                                    (tptr (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16)))
                                  (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16))
                                (Ebinop Oand (Etempvar _cellX tint)
                                  (Ebinop Osub
                                    (Ebinop Odiv
                                      (Ebinop Omul
                                        (Econst_int (Int.repr 2) tint)
                                        (Econst_int (Int.repr 8192) tint)
                                        tint)
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 10) tint) tint)
                                      tint) (Econst_int (Int.repr 1) tint)
                                    tint) tint)
                                (tptr (tarray (Tstruct _SurfaceNode noattr) 3)))
                              (tarray (Tstruct _SurfaceNode noattr) 3))
                            (Econst_int (Int.repr 2) tint)
                            (tptr (Tstruct _SurfaceNode noattr)))
                          (Tstruct _SurfaceNode noattr)) _next
                        (tptr (Tstruct _SurfaceNode noattr))))
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'3)
                          (Evar _surface_list_length (Tfunction
                                                       ((tptr (Tstruct _SurfaceNode noattr)) ::
                                                        nil) tint cc_default))
                          ((Etempvar _list (tptr (Tstruct _SurfaceNode noattr))) ::
                           nil))
                        (Sset _numWalls
                          (Ebinop Oadd (Etempvar _numWalls tint)
                            (Etempvar _t'3 tint) tint)))
                      (Ssequence
                        (Sset _list
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Ederef
                                  (Ebinop Oadd
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _gDynamicSurfacePartition (tarray (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16) 16))
                                        (Ebinop Oand (Etempvar _cellZ tint)
                                          (Ebinop Osub
                                            (Ebinop Odiv
                                              (Ebinop Omul
                                                (Econst_int (Int.repr 2) tint)
                                                (Econst_int (Int.repr 8192) tint)
                                                tint)
                                              (Ebinop Oshl
                                                (Econst_int (Int.repr 1) tint)
                                                (Econst_int (Int.repr 10) tint)
                                                tint) tint)
                                            (Econst_int (Int.repr 1) tint)
                                            tint) tint)
                                        (tptr (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16)))
                                      (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16))
                                    (Ebinop Oand (Etempvar _cellX tint)
                                      (Ebinop Osub
                                        (Ebinop Odiv
                                          (Ebinop Omul
                                            (Econst_int (Int.repr 2) tint)
                                            (Econst_int (Int.repr 8192) tint)
                                            tint)
                                          (Ebinop Oshl
                                            (Econst_int (Int.repr 1) tint)
                                            (Econst_int (Int.repr 10) tint)
                                            tint) tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tint)
                                    (tptr (tarray (Tstruct _SurfaceNode noattr) 3)))
                                  (tarray (Tstruct _SurfaceNode noattr) 3))
                                (Econst_int (Int.repr 2) tint)
                                (tptr (Tstruct _SurfaceNode noattr)))
                              (Tstruct _SurfaceNode noattr)) _next
                            (tptr (Tstruct _SurfaceNode noattr))))
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'4)
                              (Evar _surface_list_length (Tfunction
                                                           ((tptr (Tstruct _SurfaceNode noattr)) ::
                                                            nil) tint
                                                           cc_default))
                              ((Etempvar _list (tptr (Tstruct _SurfaceNode noattr))) ::
                               nil))
                            (Sset _numWalls
                              (Ebinop Oadd (Etempvar _numWalls tint)
                                (Etempvar _t'4 tint) tint)))
                          (Ssequence
                            (Sset _list
                              (Efield
                                (Ederef
                                  (Ebinop Oadd
                                    (Ederef
                                      (Ebinop Oadd
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _gStaticSurfacePartition (tarray (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16) 16))
                                            (Ebinop Oand
                                              (Etempvar _cellZ tint)
                                              (Ebinop Osub
                                                (Ebinop Odiv
                                                  (Ebinop Omul
                                                    (Econst_int (Int.repr 2) tint)
                                                    (Econst_int (Int.repr 8192) tint)
                                                    tint)
                                                  (Ebinop Oshl
                                                    (Econst_int (Int.repr 1) tint)
                                                    (Econst_int (Int.repr 10) tint)
                                                    tint) tint)
                                                (Econst_int (Int.repr 1) tint)
                                                tint) tint)
                                            (tptr (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16)))
                                          (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16))
                                        (Ebinop Oand (Etempvar _cellX tint)
                                          (Ebinop Osub
                                            (Ebinop Odiv
                                              (Ebinop Omul
                                                (Econst_int (Int.repr 2) tint)
                                                (Econst_int (Int.repr 8192) tint)
                                                tint)
                                              (Ebinop Oshl
                                                (Econst_int (Int.repr 1) tint)
                                                (Econst_int (Int.repr 10) tint)
                                                tint) tint)
                                            (Econst_int (Int.repr 1) tint)
                                            tint) tint)
                                        (tptr (tarray (Tstruct _SurfaceNode noattr) 3)))
                                      (tarray (Tstruct _SurfaceNode noattr) 3))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr (Tstruct _SurfaceNode noattr)))
                                  (Tstruct _SurfaceNode noattr)) _next
                                (tptr (Tstruct _SurfaceNode noattr))))
                            (Ssequence
                              (Ssequence
                                (Scall (Some _t'5)
                                  (Evar _surface_list_length (Tfunction
                                                               ((tptr (Tstruct _SurfaceNode noattr)) ::
                                                                nil) tint
                                                               cc_default))
                                  ((Etempvar _list (tptr (Tstruct _SurfaceNode noattr))) ::
                                   nil))
                                (Sset _numCeils
                                  (Ebinop Oadd (Etempvar _numCeils tint)
                                    (Etempvar _t'5 tint) tint)))
                              (Ssequence
                                (Sset _list
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Ederef
                                          (Ebinop Oadd
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _gDynamicSurfacePartition (tarray (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16) 16))
                                                (Ebinop Oand
                                                  (Etempvar _cellZ tint)
                                                  (Ebinop Osub
                                                    (Ebinop Odiv
                                                      (Ebinop Omul
                                                        (Econst_int (Int.repr 2) tint)
                                                        (Econst_int (Int.repr 8192) tint)
                                                        tint)
                                                      (Ebinop Oshl
                                                        (Econst_int (Int.repr 1) tint)
                                                        (Econst_int (Int.repr 10) tint)
                                                        tint) tint)
                                                    (Econst_int (Int.repr 1) tint)
                                                    tint) tint)
                                                (tptr (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16)))
                                              (tarray (tarray (Tstruct _SurfaceNode noattr) 3) 16))
                                            (Ebinop Oand
                                              (Etempvar _cellX tint)
                                              (Ebinop Osub
                                                (Ebinop Odiv
                                                  (Ebinop Omul
                                                    (Econst_int (Int.repr 2) tint)
                                                    (Econst_int (Int.repr 8192) tint)
                                                    tint)
                                                  (Ebinop Oshl
                                                    (Econst_int (Int.repr 1) tint)
                                                    (Econst_int (Int.repr 10) tint)
                                                    tint) tint)
                                                (Econst_int (Int.repr 1) tint)
                                                tint) tint)
                                            (tptr (tarray (Tstruct _SurfaceNode noattr) 3)))
                                          (tarray (Tstruct _SurfaceNode noattr) 3))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr (Tstruct _SurfaceNode noattr)))
                                      (Tstruct _SurfaceNode noattr)) _next
                                    (tptr (Tstruct _SurfaceNode noattr))))
                                (Ssequence
                                  (Ssequence
                                    (Scall (Some _t'6)
                                      (Evar _surface_list_length (Tfunction
                                                                   ((tptr (Tstruct _SurfaceNode noattr)) ::
                                                                    nil) tint
                                                                   cc_default))
                                      ((Etempvar _list (tptr (Tstruct _SurfaceNode noattr))) ::
                                       nil))
                                    (Sset _numCeils
                                      (Ebinop Oadd (Etempvar _numCeils tint)
                                        (Etempvar _t'6 tint) tint)))
                                  (Ssequence
                                    (Scall None
                                      (Evar _print_debug_top_down_mapinfo 
                                      (Tfunction
                                        ((tptr tuchar) :: tint :: nil) tvoid
                                        cc_default))
                                      ((Evar ___stringlit_1 (tarray tuchar 10)) ::
                                       (Ebinop Oadd
                                         (Ebinop Omul (Etempvar _cellZ tint)
                                           (Ebinop Odiv
                                             (Ebinop Omul
                                               (Econst_int (Int.repr 2) tint)
                                               (Econst_int (Int.repr 8192) tint)
                                               tint)
                                             (Ebinop Oshl
                                               (Econst_int (Int.repr 1) tint)
                                               (Econst_int (Int.repr 10) tint)
                                               tint) tint) tint)
                                         (Etempvar _cellX tint) tint) :: nil))
                                    (Ssequence
                                      (Scall None
                                        (Evar _print_debug_top_down_mapinfo 
                                        (Tfunction
                                          ((tptr tuchar) :: tint :: nil)
                                          tvoid cc_default))
                                        ((Evar ___stringlit_2 (tarray tuchar 6)) ::
                                         (Etempvar _numFloors tint) :: nil))
                                      (Ssequence
                                        (Scall None
                                          (Evar _print_debug_top_down_mapinfo 
                                          (Tfunction
                                            ((tptr tuchar) :: tint :: nil)
                                            tvoid cc_default))
                                          ((Evar ___stringlit_3 (tarray tuchar 6)) ::
                                           (Etempvar _numWalls tint) :: nil))
                                        (Ssequence
                                          (Scall None
                                            (Evar _print_debug_top_down_mapinfo 
                                            (Tfunction
                                              ((tptr tuchar) :: tint :: nil)
                                              tvoid cc_default))
                                            ((Evar ___stringlit_4 (tarray tuchar 6)) ::
                                             (Etempvar _numCeils tint) ::
                                             nil))
                                          (Ssequence
                                            (Scall None
                                              (Evar _set_text_array_x_y 
                                              (Tfunction
                                                (tint :: tint :: nil) tvoid
                                                cc_default))
                                              ((Econst_int (Int.repr 80) tint) ::
                                               (Eunop Oneg
                                                 (Econst_int (Int.repr 3) tint)
                                                 tint) :: nil))
                                            (Ssequence
                                              (Ssequence
                                                (Sset _t'13
                                                  (Efield
                                                    (Evar _gNumCalls (Tstruct _NumTimesCalled noattr))
                                                    _floor tshort))
                                                (Scall None
                                                  (Evar _print_debug_top_down_mapinfo 
                                                  (Tfunction
                                                    ((tptr tuchar) :: tint ::
                                                     nil) tvoid cc_default))
                                                  ((Evar ___stringlit_5 (tarray tuchar 3)) ::
                                                   (Etempvar _t'13 tshort) ::
                                                   nil)))
                                              (Ssequence
                                                (Ssequence
                                                  (Sset _t'12
                                                    (Efield
                                                      (Evar _gNumCalls (Tstruct _NumTimesCalled noattr))
                                                      _wall tshort))
                                                  (Scall None
                                                    (Evar _print_debug_top_down_mapinfo 
                                                    (Tfunction
                                                      ((tptr tuchar) ::
                                                       tint :: nil) tvoid
                                                      cc_default))
                                                    ((Evar ___stringlit_5 (tarray tuchar 3)) ::
                                                     (Etempvar _t'12 tshort) ::
                                                     nil)))
                                                (Ssequence
                                                  (Ssequence
                                                    (Sset _t'11
                                                      (Efield
                                                        (Evar _gNumCalls (Tstruct _NumTimesCalled noattr))
                                                        _ceil tshort))
                                                    (Scall None
                                                      (Evar _print_debug_top_down_mapinfo 
                                                      (Tfunction
                                                        ((tptr tuchar) ::
                                                         tint :: nil) tvoid
                                                        cc_default))
                                                      ((Evar ___stringlit_5 (tarray tuchar 3)) ::
                                                       (Etempvar _t'11 tshort) ::
                                                       nil)))
                                                  (Ssequence
                                                    (Scall None
                                                      (Evar _set_text_array_x_y 
                                                      (Tfunction
                                                        (tint :: tint :: nil)
                                                        tvoid cc_default))
                                                      ((Eunop Oneg
                                                         (Econst_int (Int.repr 80) tint)
                                                         tint) ::
                                                       (Econst_int (Int.repr 0) tint) ::
                                                       nil))
                                                    (Ssequence
                                                      (Ssequence
                                                        (Sset _t'10
                                                          (Evar _gSurfaceNodesAllocated tint))
                                                        (Scall None
                                                          (Evar _print_debug_top_down_mapinfo 
                                                          (Tfunction
                                                            ((tptr tuchar) ::
                                                             tint :: nil)
                                                            tvoid cc_default))
                                                          ((Evar ___stringlit_6 (tarray tuchar 10)) ::
                                                           (Etempvar _t'10 tint) ::
                                                           nil)))
                                                      (Ssequence
                                                        (Ssequence
                                                          (Sset _t'9
                                                            (Evar _gNumStaticSurfaces tint))
                                                          (Scall None
                                                            (Evar _print_debug_top_down_mapinfo 
                                                            (Tfunction
                                                              ((tptr tuchar) ::
                                                               tint :: nil)
                                                              tvoid
                                                              cc_default))
                                                            ((Evar ___stringlit_7 (tarray tuchar 10)) ::
                                                             (Etempvar _t'9 tint) ::
                                                             nil)))
                                                        (Ssequence
                                                          (Ssequence
                                                            (Sset _t'7
                                                              (Evar _gSurfacesAllocated tint))
                                                            (Ssequence
                                                              (Sset _t'8
                                                                (Evar _gNumStaticSurfaces tint))
                                                              (Scall None
                                                                (Evar _print_debug_top_down_mapinfo 
                                                                (Tfunction
                                                                  ((tptr tuchar) ::
                                                                   tint ::
                                                                   nil) tvoid
                                                                  cc_default))
                                                                ((Evar ___stringlit_8 (tarray tuchar 10)) ::
                                                                 (Ebinop Osub
                                                                   (Etempvar _t'7 tint)
                                                                   (Etempvar _t'8 tint)
                                                                   tint) ::
                                                                 nil))))
                                                          (Ssequence
                                                            (Sassign
                                                              (Efield
                                                                (Evar _gNumCalls (Tstruct _NumTimesCalled noattr))
                                                                _floor
                                                                tshort)
                                                              (Econst_int (Int.repr 0) tint))
                                                            (Ssequence
                                                              (Sassign
                                                                (Efield
                                                                  (Evar _gNumCalls (Tstruct _NumTimesCalled noattr))
                                                                  _ceil
                                                                  tshort)
                                                                (Econst_int (Int.repr 0) tint))
                                                              (Sassign
                                                                (Efield
                                                                  (Evar _gNumCalls (Tstruct _NumTimesCalled noattr))
                                                                  _wall
                                                                  tshort)
                                                                (Econst_int (Int.repr 0) tint)))))))))))))))))))))))))))))))))
|}.

Definition f_unused_resolve_floor_or_ceil_collisions := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_checkCeil, tint) :: (_px, (tptr tfloat)) ::
                (_py, (tptr tfloat)) :: (_pz, (tptr tfloat)) ::
                (_radius, tfloat) ::
                (_psurface, (tptr (tptr (Tstruct _Surface noattr)))) ::
                (_surfaceHeight, (tptr tfloat)) :: nil);
  fn_vars := nil;
  fn_temps := ((_nx, tfloat) :: (_ny, tfloat) :: (_nz, tfloat) ::
               (_oo, tfloat) :: (_x, tfloat) :: (_y, tfloat) ::
               (_z, tfloat) :: (_offset, tfloat) :: (_distance, tfloat) ::
               (_t'3, tfloat) :: (_t'2, tfloat) :: (_t'1, tfloat) ::
               (_t'11, (tptr (Tstruct _Surface noattr))) ::
               (_t'10, (tptr (Tstruct _Surface noattr))) ::
               (_t'9, (tptr (Tstruct _Surface noattr))) ::
               (_t'8, (tptr (Tstruct _Surface noattr))) ::
               (_t'7, (tptr (Tstruct _Surface noattr))) :: (_t'6, tfloat) ::
               (_t'5, tfloat) :: (_t'4, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _x (Ederef (Etempvar _px (tptr tfloat)) tfloat))
  (Ssequence
    (Sset _y (Ederef (Etempvar _py (tptr tfloat)) tfloat))
    (Ssequence
      (Sset _z (Ederef (Etempvar _pz (tptr tfloat)) tfloat))
      (Ssequence
        (Sassign
          (Ederef
            (Etempvar _psurface (tptr (tptr (Tstruct _Surface noattr))))
            (tptr (Tstruct _Surface noattr)))
          (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
        (Ssequence
          (Sifthenelse (Etempvar _checkCeil tint)
            (Ssequence
              (Scall (Some _t'1)
                (Evar _find_ceil (Tfunction
                                   (tfloat :: tfloat :: tfloat ::
                                    (tptr (tptr (Tstruct _Surface noattr))) ::
                                    nil) tfloat cc_default))
                ((Etempvar _x tfloat) :: (Etempvar _y tfloat) ::
                 (Etempvar _z tfloat) ::
                 (Etempvar _psurface (tptr (tptr (Tstruct _Surface noattr)))) ::
                 nil))
              (Sassign
                (Ederef (Etempvar _surfaceHeight (tptr tfloat)) tfloat)
                (Etempvar _t'1 tfloat)))
            (Ssequence
              (Scall (Some _t'2)
                (Evar _find_floor (Tfunction
                                    (tfloat :: tfloat :: tfloat ::
                                     (tptr (tptr (Tstruct _Surface noattr))) ::
                                     nil) tfloat cc_default))
                ((Etempvar _x tfloat) :: (Etempvar _y tfloat) ::
                 (Etempvar _z tfloat) ::
                 (Etempvar _psurface (tptr (tptr (Tstruct _Surface noattr)))) ::
                 nil))
              (Sassign
                (Ederef (Etempvar _surfaceHeight (tptr tfloat)) tfloat)
                (Etempvar _t'2 tfloat))))
          (Ssequence
            (Ssequence
              (Sset _t'11
                (Ederef
                  (Etempvar _psurface (tptr (tptr (Tstruct _Surface noattr))))
                  (tptr (Tstruct _Surface noattr))))
              (Sifthenelse (Ebinop Oeq
                             (Etempvar _t'11 (tptr (Tstruct _Surface noattr)))
                             (Ecast (Econst_int (Int.repr 0) tint)
                               (tptr tvoid)) tint)
                (Sreturn (Some (Eunop Oneg (Econst_int (Int.repr 1) tint)
                                 tint)))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'10
                  (Ederef
                    (Etempvar _psurface (tptr (tptr (Tstruct _Surface noattr))))
                    (tptr (Tstruct _Surface noattr))))
                (Sset _nx
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _t'10 (tptr (Tstruct _Surface noattr)))
                        (Tstruct _Surface noattr)) _normal
                      (Tstruct __732 noattr)) _x tfloat)))
              (Ssequence
                (Ssequence
                  (Sset _t'9
                    (Ederef
                      (Etempvar _psurface (tptr (tptr (Tstruct _Surface noattr))))
                      (tptr (Tstruct _Surface noattr))))
                  (Sset _ny
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'9 (tptr (Tstruct _Surface noattr)))
                          (Tstruct _Surface noattr)) _normal
                        (Tstruct __732 noattr)) _y tfloat)))
                (Ssequence
                  (Ssequence
                    (Sset _t'8
                      (Ederef
                        (Etempvar _psurface (tptr (tptr (Tstruct _Surface noattr))))
                        (tptr (Tstruct _Surface noattr))))
                    (Sset _nz
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'8 (tptr (Tstruct _Surface noattr)))
                            (Tstruct _Surface noattr)) _normal
                          (Tstruct __732 noattr)) _z tfloat)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'7
                        (Ederef
                          (Etempvar _psurface (tptr (tptr (Tstruct _Surface noattr))))
                          (tptr (Tstruct _Surface noattr))))
                      (Sset _oo
                        (Efield
                          (Ederef
                            (Etempvar _t'7 (tptr (Tstruct _Surface noattr)))
                            (Tstruct _Surface noattr)) _originOffset tfloat)))
                    (Ssequence
                      (Sset _offset
                        (Ebinop Oadd
                          (Ebinop Oadd
                            (Ebinop Oadd
                              (Ebinop Omul (Etempvar _nx tfloat)
                                (Etempvar _x tfloat) tfloat)
                              (Ebinop Omul (Etempvar _ny tfloat)
                                (Etempvar _y tfloat) tfloat) tfloat)
                            (Ebinop Omul (Etempvar _nz tfloat)
                              (Etempvar _z tfloat) tfloat) tfloat)
                          (Etempvar _oo tfloat) tfloat))
                      (Ssequence
                        (Ssequence
                          (Sifthenelse (Ebinop Oge (Etempvar _offset tfloat)
                                         (Econst_int (Int.repr 0) tint) tint)
                            (Sset _t'3
                              (Ecast (Etempvar _offset tfloat) tfloat))
                            (Sset _t'3
                              (Ecast
                                (Eunop Oneg (Etempvar _offset tfloat) tfloat)
                                tfloat)))
                          (Sset _distance (Etempvar _t'3 tfloat)))
                        (Ssequence
                          (Sifthenelse (Ebinop Olt
                                         (Etempvar _distance tfloat)
                                         (Etempvar _radius tfloat) tint)
                            (Ssequence
                              (Ssequence
                                (Sset _t'6
                                  (Ederef (Etempvar _px (tptr tfloat))
                                    tfloat))
                                (Sassign
                                  (Ederef (Etempvar _px (tptr tfloat))
                                    tfloat)
                                  (Ebinop Oadd (Etempvar _t'6 tfloat)
                                    (Ebinop Omul (Etempvar _nx tfloat)
                                      (Ebinop Osub (Etempvar _radius tfloat)
                                        (Etempvar _offset tfloat) tfloat)
                                      tfloat) tfloat)))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'5
                                    (Ederef (Etempvar _py (tptr tfloat))
                                      tfloat))
                                  (Sassign
                                    (Ederef (Etempvar _py (tptr tfloat))
                                      tfloat)
                                    (Ebinop Oadd (Etempvar _t'5 tfloat)
                                      (Ebinop Omul (Etempvar _ny tfloat)
                                        (Ebinop Osub
                                          (Etempvar _radius tfloat)
                                          (Etempvar _offset tfloat) tfloat)
                                        tfloat) tfloat)))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'4
                                      (Ederef (Etempvar _pz (tptr tfloat))
                                        tfloat))
                                    (Sassign
                                      (Ederef (Etempvar _pz (tptr tfloat))
                                        tfloat)
                                      (Ebinop Oadd (Etempvar _t'4 tfloat)
                                        (Ebinop Omul (Etempvar _nz tfloat)
                                          (Ebinop Osub
                                            (Etempvar _radius tfloat)
                                            (Etempvar _offset tfloat) tfloat)
                                          tfloat) tfloat)))
                                  (Sreturn (Some (Econst_int (Int.repr 1) tint))))))
                            Sskip)
                          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))))))
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
 Composite _GraphNodeRoot Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _areaIndex tuchar :: Member_plain _unk15 tschar ::
    Member_plain _x tshort :: Member_plain _y tshort ::
    Member_plain _width tshort :: Member_plain _height tshort ::
    Member_plain _numViews tshort ::
    Member_plain _views (tptr (tptr (Tstruct _GraphNode noattr))) :: nil)
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
 Composite _NumTimesCalled Struct
   (Member_plain _floor tshort :: Member_plain _ceil tshort ::
    Member_plain _wall tshort :: nil)
   noattr ::
 Composite _WallCollisionData Struct
   (Member_plain _x tfloat :: Member_plain _y tfloat ::
    Member_plain _z tfloat :: Member_plain _offsetY tfloat ::
    Member_plain _radius tfloat :: Member_plain _filler (tarray tuchar 2) ::
    Member_plain _numWalls tshort ::
    Member_plain _walls (tarray (tptr (Tstruct _Surface noattr)) 4) :: nil)
   noattr ::
 Composite _FloorGeometry Struct
   (Member_plain _filler (tarray tuchar 16) ::
    Member_plain _normalX tfloat :: Member_plain _normalY tfloat ::
    Member_plain _normalZ tfloat :: Member_plain _originOffset tfloat :: nil)
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
     cc_default)) :: (___stringlit_4, Gvar v___stringlit_4) ::
 (___stringlit_6, Gvar v___stringlit_6) ::
 (___stringlit_8, Gvar v___stringlit_8) ::
 (___stringlit_1, Gvar v___stringlit_1) ::
 (___stringlit_2, Gvar v___stringlit_2) ::
 (___stringlit_3, Gvar v___stringlit_3) ::
 (___stringlit_5, Gvar v___stringlit_5) ::
 (___stringlit_7, Gvar v___stringlit_7) ::
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
 (_set_text_array_x_y,
   Gfun(External (EF_external "set_text_array_x_y"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xvoid
                     cc_default)) (tint :: tint :: nil) tvoid cc_default)) ::
 (_print_debug_top_down_mapinfo,
   Gfun(External (EF_external "print_debug_top_down_mapinfo"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default)) ((tptr tuchar) :: tint :: nil) tvoid
     cc_default)) :: (_gMarioState, Gvar v_gMarioState) ::
 (_gNumFindFloorMisses, Gvar v_gNumFindFloorMisses) ::
 (_gNumCalls, Gvar v_gNumCalls) :: (_gMarioObject, Gvar v_gMarioObject) ::
 (_gCurrentObject, Gvar v_gCurrentObject) ::
 (_gSurfaceNodesAllocated, Gvar v_gSurfaceNodesAllocated) ::
 (_gSurfacesAllocated, Gvar v_gSurfacesAllocated) ::
 (_gNumStaticSurfaces, Gvar v_gNumStaticSurfaces) ::
 (_gCheckingSurfaceCollisionsForCamera, Gvar v_gCheckingSurfaceCollisionsForCamera) ::
 (_gFindFloorIncludeSurfaceIntangible, Gvar v_gFindFloorIncludeSurfaceIntangible) ::
 (_gEnvironmentRegions, Gvar v_gEnvironmentRegions) ::
 (_gStaticSurfacePartition, Gvar v_gStaticSurfacePartition) ::
 (_gDynamicSurfacePartition, Gvar v_gDynamicSurfacePartition) ::
 (_find_wall_collisions_from_list, Gfun(Internal f_find_wall_collisions_from_list)) ::
 (_f32_find_wall_collision, Gfun(Internal f_f32_find_wall_collision)) ::
 (_find_wall_collisions, Gfun(Internal f_find_wall_collisions)) ::
 (_find_ceil_from_list, Gfun(Internal f_find_ceil_from_list)) ::
 (_find_ceil, Gfun(Internal f_find_ceil)) ::
 (_unused_obj_find_floor_height, Gfun(Internal f_unused_obj_find_floor_height)) ::
 (_sFloorGeo, Gvar v_sFloorGeo) ::
 (_find_floor_height_and_data, Gfun(Internal f_find_floor_height_and_data)) ::
 (_find_floor_from_list, Gfun(Internal f_find_floor_from_list)) ::
 (_find_floor_height, Gfun(Internal f_find_floor_height)) ::
 (_unused_find_dynamic_floor, Gfun(Internal f_unused_find_dynamic_floor)) ::
 (_find_floor, Gfun(Internal f_find_floor)) ::
 (_find_water_level, Gfun(Internal f_find_water_level)) ::
 (_find_poison_gas_level, Gfun(Internal f_find_poison_gas_level)) ::
 (_surface_list_length, Gfun(Internal f_surface_list_length)) ::
 (_debug_surface_list_info, Gfun(Internal f_debug_surface_list_info)) ::
 (_unused_resolve_floor_or_ceil_collisions, Gfun(Internal f_unused_resolve_floor_or_ceil_collisions)) ::
 nil).

Definition public_idents : list ident :=
(_unused_resolve_floor_or_ceil_collisions :: _debug_surface_list_info ::
 _find_poison_gas_level :: _find_water_level :: _find_floor ::
 _unused_find_dynamic_floor :: _find_floor_height ::
 _find_floor_height_and_data :: _sFloorGeo ::
 _unused_obj_find_floor_height :: _find_ceil :: _find_wall_collisions ::
 _f32_find_wall_collision :: _gDynamicSurfacePartition ::
 _gStaticSurfacePartition :: _gEnvironmentRegions ::
 _gFindFloorIncludeSurfaceIntangible ::
 _gCheckingSurfaceCollisionsForCamera :: _gNumStaticSurfaces ::
 _gSurfacesAllocated :: _gSurfaceNodesAllocated :: _gCurrentObject ::
 _gMarioObject :: _gNumCalls :: _gNumFindFloorMisses :: _gMarioState ::
 _print_debug_top_down_mapinfo :: _set_text_array_x_y :: ___builtin_debug ::
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


