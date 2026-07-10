(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Produced by: pipeline/clightgen.sh
   From source: ../reference-sm64-decomp/src/game/object_list_processor.c
   clightgen:   The CompCert CompCert AST generator, version 3.15
   Flags:       -normalize -nostdinc -fstruct-passing -I../reference-sm64-decomp/include -I../reference-sm64-decomp/build/us -I../reference-sm64-decomp/build/us/include -I../reference-sm64-decomp/src -I../reference-sm64-decomp -I../reference-sm64-decomp/include/libc -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1 -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1
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
  Definition source_file := "../reference-sm64-decomp/src/game/object_list_processor.c".
  Definition normalized := true.
End Info.

Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _Area : ident := $"Area".
Definition _Camera : ident := $"Camera".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _Controller : ident := $"Controller".
Definition _D_8035FEE2 : ident := $"D_8035FEE2".
Definition _D_8035FEE4 : ident := $"D_8035FEE4".
Definition _DmaHandlerList : ident := $"DmaHandlerList".
Definition _DmaTable : ident := $"DmaTable".
Definition _GraphNode : ident := $"GraphNode".
Definition _GraphNodeObject : ident := $"GraphNodeObject".
Definition _GraphNodeRoot : ident := $"GraphNodeRoot".
Definition _InstantWarp : ident := $"InstantWarp".
Definition _MarioBodyState : ident := $"MarioBodyState".
Definition _MarioState : ident := $"MarioState".
Definition _MemoryPool : ident := $"MemoryPool".
Definition _NumTimesCalled : ident := $"NumTimesCalled".
Definition _Object : ident := $"Object".
Definition _ObjectNode : ident := $"ObjectNode".
Definition _ObjectWarpNode : ident := $"ObjectWarpNode".
Definition _OffsetSizePair : ident := $"OffsetSizePair".
Definition _ParticleProperties : ident := $"ParticleProperties".
Definition _PlayerCameraState : ident := $"PlayerCameraState".
Definition _SpawnInfo : ident := $"SpawnInfo".
Definition _Surface : ident := $"Surface".
Definition _UnusedArea28 : ident := $"UnusedArea28".
Definition _WarpNode : ident := $"WarpNode".
Definition _Waypoint : ident := $"Waypoint".
Definition _Whirlpool : ident := $"Whirlpool".
Definition __317 : ident := $"_317".
Definition __319 : ident := $"_319".
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
Definition _action : ident := $"action".
Definition _actionArg : ident := $"actionArg".
Definition _actionState : ident := $"actionState".
Definition _actionTimer : ident := $"actionTimer".
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _activeParticleFlag : ident := $"activeParticleFlag".
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
Definition _apply_mario_platform_displacement : ident := $"apply_mario_platform_displacement".
Definition _area : ident := $"area".
Definition _areaCenX : ident := $"areaCenX".
Definition _areaCenY : ident := $"areaCenY".
Definition _areaCenZ : ident := $"areaCenZ".
Definition _areaIndex : ident := $"areaIndex".
Definition _arg16 : ident := $"arg16".
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
Definition _bhvBreathParticleSpawner : ident := $"bhvBreathParticleSpawner".
Definition _bhvBubbleParticleSpawner : ident := $"bhvBubbleParticleSpawner".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvDirtParticleSpawner : ident := $"bhvDirtParticleSpawner".
Definition _bhvFireParticleSpawner : ident := $"bhvFireParticleSpawner".
Definition _bhvHorStarParticleSpawner : ident := $"bhvHorStarParticleSpawner".
Definition _bhvIdleWaterWave : ident := $"bhvIdleWaterWave".
Definition _bhvLeafParticleSpawner : ident := $"bhvLeafParticleSpawner".
Definition _bhvMistCircParticleSpawner : ident := $"bhvMistCircParticleSpawner".
Definition _bhvMistParticleSpawner : ident := $"bhvMistParticleSpawner".
Definition _bhvPlungeBubble : ident := $"bhvPlungeBubble".
Definition _bhvShallowWaterSplash : ident := $"bhvShallowWaterSplash".
Definition _bhvShallowWaterWave : ident := $"bhvShallowWaterWave".
Definition _bhvSnowParticleSpawner : ident := $"bhvSnowParticleSpawner".
Definition _bhvSparkleParticleSpawner : ident := $"bhvSparkleParticleSpawner".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _bhvTriangleParticleSpawner : ident := $"bhvTriangleParticleSpawner".
Definition _bhvVertStarParticleSpawner : ident := $"bhvVertStarParticleSpawner".
Definition _bhvWaterSplash : ident := $"bhvWaterSplash".
Definition _bhvWaveTrail : ident := $"bhvWaveTrail".
Definition _bhv_mario_update : ident := $"bhv_mario_update".
Definition _bits : ident := $"bits".
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
Definition _children : ident := $"children".
Definition _clear_dynamic_surfaces : ident := $"clear_dynamic_surfaces".
Definition _clear_mario_platform : ident := $"clear_mario_platform".
Definition _clear_object_lists : ident := $"clear_object_lists".
Definition _clear_objects : ident := $"clear_objects".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _controller : ident := $"controller".
Definition _controllerData : ident := $"controllerData".
Definition _copy_mario_state_to_object : ident := $"copy_mario_state_to_object".
Definition _count : ident := $"count".
Definition _create_object : ident := $"create_object".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _cur_obj_update : ident := $"cur_obj_update".
Definition _currentAddr : ident := $"currentAddr".
Definition _cutscene : ident := $"cutscene".
Definition _cycleCounts : ident := $"cycleCounts".
Definition _debug_unknown_level_select_check : ident := $"debug_unknown_level_select_check".
Definition _defMode : ident := $"defMode".
Definition _destArea : ident := $"destArea".
Definition _destLevel : ident := $"destLevel".
Definition _destNode : ident := $"destNode".
Definition _detect_object_collisions : ident := $"detect_object_collisions".
Definition _dialog : ident := $"dialog".
Definition _displacement : ident := $"displacement".
Definition _dmaTable : ident := $"dmaTable".
Definition _doorStatus : ident := $"doorStatus".
Definition _doubleJumpTimer : ident := $"doubleJumpTimer".
Definition _errnum : ident := $"errnum".
Definition _execute_mario_action : ident := $"execute_mario_action".
Definition _eyeState : ident := $"eyeState".
Definition _faceAngle : ident := $"faceAngle".
Definition _fadeWarpOpacity : ident := $"fadeWarpOpacity".
Definition _filler : ident := $"filler".
Definition _filler1 : ident := $"filler1".
Definition _filler2 : ident := $"filler2".
Definition _firstObj : ident := $"firstObj".
Definition _flags : ident := $"flags".
Definition _floor : ident := $"floor".
Definition _floorAngle : ident := $"floorAngle".
Definition _floorHeight : ident := $"floorHeight".
Definition _focus : ident := $"focus".
Definition _force : ident := $"force".
Definition _forwardVel : ident := $"forwardVel".
Definition _framesSinceA : ident := $"framesSinceA".
Definition _framesSinceB : ident := $"framesSinceB".
Definition _gCCMEnteredSlide : ident := $"gCCMEnteredSlide".
Definition _gCheckingSurfaceCollisionsForCamera : ident := $"gCheckingSurfaceCollisionsForCamera".
Definition _gCurBhvCommand : ident := $"gCurBhvCommand".
Definition _gCurrAreaIndex : ident := $"gCurrAreaIndex".
Definition _gCurrentObject : ident := $"gCurrentObject".
Definition _gDebugInfo : ident := $"gDebugInfo".
Definition _gDebugInfoFlags : ident := $"gDebugInfoFlags".
Definition _gDebugInfoOverwrite : ident := $"gDebugInfoOverwrite".
Definition _gDoorAdjacentRooms : ident := $"gDoorAdjacentRooms".
Definition _gEnvironmentLevels : ident := $"gEnvironmentLevels".
Definition _gEnvironmentRegions : ident := $"gEnvironmentRegions".
Definition _gFindFloorIncludeSurfaceIntangible : ident := $"gFindFloorIncludeSurfaceIntangible".
Definition _gFreeObjectList : ident := $"gFreeObjectList".
Definition _gLuigiObject : ident := $"gLuigiObject".
Definition _gMacroObjectDefaultParent : ident := $"gMacroObjectDefaultParent".
Definition _gMarioCurrentRoom : ident := $"gMarioCurrentRoom".
Definition _gMarioObject : ident := $"gMarioObject".
Definition _gMarioOnMerryGoRound : ident := $"gMarioOnMerryGoRound".
Definition _gMarioShotFromCannon : ident := $"gMarioShotFromCannon".
Definition _gMarioStates : ident := $"gMarioStates".
Definition _gNumCalls : ident := $"gNumCalls".
Definition _gNumFindFloorMisses : ident := $"gNumFindFloorMisses".
Definition _gNumRoomedObjectsInMarioRoom : ident := $"gNumRoomedObjectsInMarioRoom".
Definition _gNumRoomedObjectsNotInMarioRoom : ident := $"gNumRoomedObjectsNotInMarioRoom".
Definition _gNumStaticSurfaceNodes : ident := $"gNumStaticSurfaceNodes".
Definition _gNumStaticSurfaces : ident := $"gNumStaticSurfaces".
Definition _gObjectCounter : ident := $"gObjectCounter".
Definition _gObjectListArray : ident := $"gObjectListArray".
Definition _gObjectLists : ident := $"gObjectLists".
Definition _gObjectMemoryPool : ident := $"gObjectMemoryPool".
Definition _gObjectPool : ident := $"gObjectPool".
Definition _gPrevFrameObjectCount : ident := $"gPrevFrameObjectCount".
Definition _gSurfaceNodesAllocated : ident := $"gSurfaceNodesAllocated".
Definition _gSurfacesAllocated : ident := $"gSurfacesAllocated".
Definition _gTHIWaterDrained : ident := $"gTHIWaterDrained".
Definition _gTTCSpeedSetting : ident := $"gTTCSpeedSetting".
Definition _gTimeStopState : ident := $"gTimeStopState".
Definition _gUnknownWallCount : ident := $"gUnknownWallCount".
Definition _gWDWWaterLevelChanging : ident := $"gWDWWaterLevelChanging".
Definition _geo_make_first_child : ident := $"geo_make_first_child".
Definition _geo_obj_init_spawninfo : ident := $"geo_obj_init_spawninfo".
Definition _geo_reset_object_node : ident := $"geo_reset_object_node".
Definition _get_clock_difference : ident := $"get_clock_difference".
Definition _get_current_clock : ident := $"get_current_clock".
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
Definition _hitboxDownOffset : ident := $"hitboxDownOffset".
Definition _hitboxHeight : ident := $"hitboxHeight".
Definition _hitboxRadius : ident := $"hitboxRadius".
Definition _hurtCounter : ident := $"hurtCounter".
Definition _hurtboxHeight : ident := $"hurtboxHeight".
Definition _hurtboxRadius : ident := $"hurtboxRadius".
Definition _i : ident := $"i".
Definition _id : ident := $"id".
Definition _index : ident := $"index".
Definition _info16 : ident := $"info16".
Definition _info32 : ident := $"info32".
Definition _init_free_object_list : ident := $"init_free_object_list".
Definition _input : ident := $"input".
Definition _instantWarps : ident := $"instantWarps".
Definition _intendedMag : ident := $"intendedMag".
Definition _intendedYaw : ident := $"intendedYaw".
Definition _interactObj : ident := $"interactObj".
Definition _invincTimer : ident := $"invincTimer".
Definition _length : ident := $"length".
Definition _list : ident := $"list".
Definition _listIndex : ident := $"listIndex".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _macroObjects : ident := $"macroObjects".
Definition _main : ident := $"main".
Definition _marioBodyState : ident := $"marioBodyState".
Definition _marioObj : ident := $"marioObj".
Definition _mem_pool_init : ident := $"mem_pool_init".
Definition _mode : ident := $"mode".
Definition _model : ident := $"model".
Definition _modelState : ident := $"modelState".
Definition _musicParam : ident := $"musicParam".
Definition _musicParam2 : ident := $"musicParam2".
Definition _next : ident := $"next".
Definition _nextYaw : ident := $"nextYaw".
Definition _node : ident := $"node".
Definition _normal : ident := $"normal".
Definition _numCoins : ident := $"numCoins".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _numKeys : ident := $"numKeys".
Definition _numLives : ident := $"numLives".
Definition _numStars : ident := $"numStars".
Definition _numViews : ident := $"numViews".
Definition _obj : ident := $"obj".
Definition _objList : ident := $"objList".
Definition _obj_copy_pos_and_angle : ident := $"obj_copy_pos_and_angle".
Definition _object : ident := $"object".
Definition _objectSpawnInfos : ident := $"objectSpawnInfos".
Definition _offset : ident := $"offset".
Definition _originOffset : ident := $"originOffset".
Definition _paintingWarpNodes : ident := $"paintingWarpNodes".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _particle : ident := $"particle".
Definition _particleFlag : ident := $"particleFlag".
Definition _particleFlags : ident := $"particleFlags".
Definition _peakHeight : ident := $"peakHeight".
Definition _pitch : ident := $"pitch".
Definition _platform : ident := $"platform".
Definition _pos : ident := $"pos".
Definition _posX : ident := $"posX".
Definition _posY : ident := $"posY".
Definition _posZ : ident := $"posZ".
Definition _prev : ident := $"prev".
Definition _prevAction : ident := $"prevAction".
Definition _prevNumStarsForDialog : ident := $"prevNumStarsForDialog".
Definition _prevObj : ident := $"prevObj".
Definition _punchState : ident := $"punchState".
Definition _quicksandDepth : ident := $"quicksandDepth".
Definition _rawData : ident := $"rawData".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _reset_debug_objectinfo : ident := $"reset_debug_objectinfo".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _riddenObj : ident := $"riddenObj".
Definition _roll : ident := $"roll".
Definition _room : ident := $"room".
Definition _sObjectListUpdateOrder : ident := $"sObjectListUpdateOrder".
Definition _sParticleTypes : ident := $"sParticleTypes".
Definition _scale : ident := $"scale".
Definition _script : ident := $"script".
Definition _segmented_to_virtual : ident := $"segmented_to_virtual".
Definition _set_object_respawn_info_bits : ident := $"set_object_respawn_info_bits".
Definition _sharedChild : ident := $"sharedChild".
Definition _size : ident := $"size".
Definition _slideVelX : ident := $"slideVelX".
Definition _slideVelZ : ident := $"slideVelZ".
Definition _slideYaw : ident := $"slideYaw".
Definition _spawnInfo : ident := $"spawnInfo".
Definition _spawn_object_at_origin : ident := $"spawn_object_at_origin".
Definition _spawn_objects_from_info : ident := $"spawn_objects_from_info".
Definition _spawn_particle : ident := $"spawn_particle".
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
Definition _stub_behavior_script_2 : ident := $"stub_behavior_script_2".
Definition _stub_debug_5 : ident := $"stub_debug_5".
Definition _stub_obj_list_processor_1 : ident := $"stub_obj_list_processor_1".
Definition _surfaceRooms : ident := $"surfaceRooms".
Definition _terrainData : ident := $"terrainData".
Definition _terrainSoundAddend : ident := $"terrainSoundAddend".
Definition _terrainType : ident := $"terrainType".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _torsoAngle : ident := $"torsoAngle".
Definition _transform : ident := $"transform".
Definition _try_print_debug_mario_object_info : ident := $"try_print_debug_mario_object_info".
Definition _twirlYaw : ident := $"twirlYaw".
Definition _type : ident := $"type".
Definition _unfrozen : ident := $"unfrozen".
Definition _unk00 : ident := $"unk00".
Definition _unk02 : ident := $"unk02".
Definition _unk04 : ident := $"unk04".
Definition _unk06 : ident := $"unk06".
Definition _unk08 : ident := $"unk08".
Definition _unk15 : ident := $"unk15".
Definition _unk4C : ident := $"unk4C".
Definition _unkB0 : ident := $"unkB0".
Definition _unload_deactivated_objects : ident := $"unload_deactivated_objects".
Definition _unload_deactivated_objects_in_list : ident := $"unload_deactivated_objects_in_list".
Definition _unload_object : ident := $"unload_object".
Definition _unload_objects_from_area : ident := $"unload_objects_from_area".
Definition _unused : ident := $"unused".
Definition _unused1 : ident := $"unused1".
Definition _unused2 : ident := $"unused2".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _unusedVec1 : ident := $"unusedVec1".
Definition _unused_8033BEF8 : ident := $"unused_8033BEF8".
Definition _update_mario_platform : ident := $"update_mario_platform".
Definition _update_non_terrain_objects : ident := $"update_non_terrain_objects".
Definition _update_objects : ident := $"update_objects".
Definition _update_objects_during_time_stop : ident := $"update_objects_during_time_stop".
Definition _update_objects_in_list : ident := $"update_objects_in_list".
Definition _update_objects_starting_at : ident := $"update_objects_starting_at".
Definition _update_terrain_objects : ident := $"update_terrain_objects".
Definition _upperY : ident := $"upperY".
Definition _usedObj : ident := $"usedObj".
Definition _values : ident := $"values".
Definition _vel : ident := $"vel".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _views : ident := $"views".
Definition _wall : ident := $"wall".
Definition _wallKickTimer : ident := $"wallKickTimer".
Definition _warpNodes : ident := $"warpNodes".
Definition _waterLevel : ident := $"waterLevel".
Definition _whirlpools : ident := $"whirlpools".
Definition _width : ident := $"width".
Definition _wingFlutter : ident := $"wingFlutter".
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
Definition _t'4 : ident := 131%positive.
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v_gCurrAreaIndex := {|
  gvar_info := tshort;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBubbleParticleSpawner := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvPlungeBubble := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvVertStarParticleSpawner := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvHorStarParticleSpawner := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvTriangleParticleSpawner := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBreathParticleSpawner := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvMistCircParticleSpawner := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvDirtParticleSpawner := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSnowParticleSpawner := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvFireParticleSpawner := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvLeafParticleSpawner := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvMistParticleSpawner := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSparkleParticleSpawner := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvWaterSplash := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvIdleWaterWave := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvShallowWaterWave := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvShallowWaterSplash := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvWaveTrail := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_gMarioStates := {|
  gvar_info := (tarray (Tstruct _MarioState noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDebugInfoFlags := {|
  gvar_info := tint;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gNumFindFloorMisses := {|
  gvar_info := tint;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_unused_8033BEF8 := {|
  gvar_info := tint;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gUnknownWallCount := {|
  gvar_info := tint;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gObjectCounter := {|
  gvar_info := tuint;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gNumCalls := {|
  gvar_info := (Tstruct _NumTimesCalled noattr);
  gvar_init := (Init_space 6 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDebugInfo := {|
  gvar_info := (tarray (tarray tshort 8) 16);
  gvar_init := (Init_space 256 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDebugInfoOverwrite := {|
  gvar_info := (tarray (tarray tshort 8) 16);
  gvar_init := (Init_space 256 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gTimeStopState := {|
  gvar_info := tuint;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gObjectPool := {|
  gvar_info := (tarray (Tstruct _Object noattr) 240);
  gvar_init := (Init_space 145920 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMacroObjectDefaultParent := {|
  gvar_info := (Tstruct _Object noattr);
  gvar_init := (Init_space 608 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gObjectLists := {|
  gvar_info := (tptr (Tstruct _ObjectNode noattr));
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gFreeObjectList := {|
  gvar_info := (Tstruct _ObjectNode noattr);
  gvar_init := (Init_space 104 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMarioObject := {|
  gvar_info := (tptr (Tstruct _Object noattr));
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gLuigiObject := {|
  gvar_info := (tptr (Tstruct _Object noattr));
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrentObject := {|
  gvar_info := (tptr (Tstruct _Object noattr));
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurBhvCommand := {|
  gvar_info := (tptr tuint);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gPrevFrameObjectCount := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSurfaceNodesAllocated := {|
  gvar_info := tint;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSurfacesAllocated := {|
  gvar_info := tint;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gNumStaticSurfaceNodes := {|
  gvar_info := tint;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gNumStaticSurfaces := {|
  gvar_info := tint;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gObjectMemoryPool := {|
  gvar_info := (tptr (Tstruct _MemoryPool noattr));
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCheckingSurfaceCollisionsForCamera := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gFindFloorIncludeSurfaceIntangible := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gEnvironmentRegions := {|
  gvar_info := (tptr tshort);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gEnvironmentLevels := {|
  gvar_info := (tarray tint 20);
  gvar_init := (Init_space 80 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDoorAdjacentRooms := {|
  gvar_info := (tarray (tarray tschar 2) 60);
  gvar_init := (Init_space 120 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMarioCurrentRoom := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_8035FEE2 := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_8035FEE4 := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gTHIWaterDrained := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gTTCSpeedSetting := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMarioShotFromCannon := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCCMEnteredSlide := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gNumRoomedObjectsInMarioRoom := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gNumRoomedObjectsNotInMarioRoom := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gWDWWaterLevelChanging := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMarioOnMerryGoRound := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gObjectListArray := {|
  gvar_info := (tarray (Tstruct _ObjectNode noattr) 16);
  gvar_init := (Init_space 1664 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sObjectListUpdateOrder := {|
  gvar_info := (tarray tschar 11);
  gvar_init := (Init_int8 (Int.repr 11) :: Init_int8 (Int.repr 9) ::
                Init_int8 (Int.repr 10) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 5) :: Init_int8 (Int.repr 4) ::
                Init_int8 (Int.repr 2) :: Init_int8 (Int.repr 6) ::
                Init_int8 (Int.repr 8) :: Init_int8 (Int.repr 12) ::
                Init_int8 (Int.repr (-1)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sParticleTypes := {|
  gvar_info := (tarray (Tstruct _ParticleProperties noattr) 19);
  gvar_init := (Init_int32 (Int.repr 1) :: Init_int32 (Int.repr 1) ::
                Init_int8 (Int.repr 142) :: Init_space 3 ::
                Init_addrof _bhvMistParticleSpawner (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 2) :: Init_int32 (Int.repr 262144) ::
                Init_int8 (Int.repr 0) :: Init_space 3 ::
                Init_addrof _bhvVertStarParticleSpawner (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 16) :: Init_int32 (Int.repr 16) ::
                Init_int8 (Int.repr 0) :: Init_space 3 ::
                Init_addrof _bhvHorStarParticleSpawner (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 8) :: Init_int32 (Int.repr 8) ::
                Init_int8 (Int.repr 149) :: Init_space 3 ::
                Init_addrof _bhvSparkleParticleSpawner (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 32) :: Init_int32 (Int.repr 32) ::
                Init_int8 (Int.repr 168) :: Init_space 3 ::
                Init_addrof _bhvBubbleParticleSpawner (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 64) :: Init_int32 (Int.repr 64) ::
                Init_int8 (Int.repr 167) :: Init_space 3 ::
                Init_addrof _bhvWaterSplash (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 128) :: Init_int32 (Int.repr 128) ::
                Init_int8 (Int.repr 166) :: Init_space 3 ::
                Init_addrof _bhvIdleWaterWave (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 512) :: Init_int32 (Int.repr 512) ::
                Init_int8 (Int.repr 164) :: Init_space 3 ::
                Init_addrof _bhvPlungeBubble (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 1024) :: Init_int32 (Int.repr 1024) ::
                Init_int8 (Int.repr 163) :: Init_space 3 ::
                Init_addrof _bhvWaveTrail (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 2048) :: Init_int32 (Int.repr 2048) ::
                Init_int8 (Int.repr 144) :: Init_space 3 ::
                Init_addrof _bhvFireParticleSpawner (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 256) :: Init_int32 (Int.repr 256) ::
                Init_int8 (Int.repr 0) :: Init_space 3 ::
                Init_addrof _bhvShallowWaterWave (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 4096) :: Init_int32 (Int.repr 4096) ::
                Init_int8 (Int.repr 0) :: Init_space 3 ::
                Init_addrof _bhvShallowWaterSplash (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 8192) :: Init_int32 (Int.repr 8192) ::
                Init_int8 (Int.repr 0) :: Init_space 3 ::
                Init_addrof _bhvLeafParticleSpawner (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 16384) :: Init_int32 (Int.repr 65536) ::
                Init_int8 (Int.repr 0) :: Init_space 3 ::
                Init_addrof _bhvSnowParticleSpawner (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 131072) ::
                Init_int32 (Int.repr 131072) :: Init_int8 (Int.repr 0) ::
                Init_space 3 ::
                Init_addrof _bhvBreathParticleSpawner (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 32768) :: Init_int32 (Int.repr 16384) ::
                Init_int8 (Int.repr 0) :: Init_space 3 ::
                Init_addrof _bhvDirtParticleSpawner (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 65536) :: Init_int32 (Int.repr 32768) ::
                Init_int8 (Int.repr 0) :: Init_space 3 ::
                Init_addrof _bhvMistCircParticleSpawner (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 524288) :: Init_int8 (Int.repr 0) ::
                Init_space 3 ::
                Init_addrof _bhvTriangleParticleSpawner (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_space 3 ::
                Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_copy_mario_state_to_object := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_t'38, (tptr (Tstruct _Object noattr))) ::
               (_t'37, (tptr (Tstruct _Object noattr))) :: (_t'36, tfloat) ::
               (_t'35, (tptr (Tstruct _Object noattr))) :: (_t'34, tfloat) ::
               (_t'33, (tptr (Tstruct _Object noattr))) :: (_t'32, tfloat) ::
               (_t'31, (tptr (Tstruct _Object noattr))) :: (_t'30, tfloat) ::
               (_t'29, (tptr (Tstruct _Object noattr))) :: (_t'28, tfloat) ::
               (_t'27, (tptr (Tstruct _Object noattr))) :: (_t'26, tfloat) ::
               (_t'25, (tptr (Tstruct _Object noattr))) :: (_t'24, tshort) ::
               (_t'23, (tptr (Tstruct _Object noattr))) ::
               (_t'22, (tptr (Tstruct _Object noattr))) :: (_t'21, tshort) ::
               (_t'20, (tptr (Tstruct _Object noattr))) ::
               (_t'19, (tptr (Tstruct _Object noattr))) :: (_t'18, tshort) ::
               (_t'17, (tptr (Tstruct _Object noattr))) ::
               (_t'16, (tptr (Tstruct _Object noattr))) :: (_t'15, tshort) ::
               (_t'14, (tptr (Tstruct _Object noattr))) ::
               (_t'13, (tptr (Tstruct _Object noattr))) :: (_t'12, tshort) ::
               (_t'11, (tptr (Tstruct _Object noattr))) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tshort) ::
               (_t'8, (tptr (Tstruct _Object noattr))) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tshort) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: (_t'4, tshort) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: (_t'2, tshort) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _i (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Sset _t'37 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'38 (Evar _gMarioObject (tptr (Tstruct _Object noattr))))
        (Sifthenelse (Ebinop One
                       (Etempvar _t'37 (tptr (Tstruct _Object noattr)))
                       (Etempvar _t'38 (tptr (Tstruct _Object noattr))) tint)
          (Sset _i
            (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint)
              tint))
          Sskip)))
    (Ssequence
      (Ssequence
        (Sset _t'35 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'36
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
                      (Etempvar _i tint) (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'35 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                (Econst_int (Int.repr 9) tint) (tptr tfloat)) tfloat)
            (Etempvar _t'36 tfloat))))
      (Ssequence
        (Ssequence
          (Sset _t'33 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'34
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
                        (Etempvar _i tint)
                        (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                  (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _t'33 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                  (Econst_int (Int.repr 10) tint) (tptr tfloat)) tfloat)
              (Etempvar _t'34 tfloat))))
        (Ssequence
          (Ssequence
            (Sset _t'31
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'32
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
                          (Etempvar _i tint)
                          (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                    (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'31 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                    (Econst_int (Int.repr 11) tint) (tptr tfloat)) tfloat)
                (Etempvar _t'32 tfloat))))
          (Ssequence
            (Ssequence
              (Sset _t'29
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'30
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
                            (Etempvar _i tint)
                            (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _pos
                        (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tfloat)) tfloat))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'29 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                      (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                        (Econst_int (Int.repr 0) tint) tint) (tptr tfloat))
                    tfloat) (Etempvar _t'30 tfloat))))
            (Ssequence
              (Ssequence
                (Sset _t'27
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'28
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Ebinop Oadd
                              (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
                              (Etempvar _i tint)
                              (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _pos
                          (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tfloat)) tfloat))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'27 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                        (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                          (Econst_int (Int.repr 1) tint) tint) (tptr tfloat))
                      tfloat) (Etempvar _t'28 tfloat))))
              (Ssequence
                (Ssequence
                  (Sset _t'25
                    (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sset _t'26
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
                                (Etempvar _i tint)
                                (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _pos
                            (tarray tfloat 3)) (Econst_int (Int.repr 2) tint)
                          (tptr tfloat)) tfloat))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'25 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __764 noattr)) _asF32
                            (tarray tfloat 80))
                          (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                            (Econst_int (Int.repr 2) tint) tint)
                          (tptr tfloat)) tfloat) (Etempvar _t'26 tfloat))))
                (Ssequence
                  (Ssequence
                    (Sset _t'22
                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sset _t'23
                        (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                      (Ssequence
                        (Sset _t'24
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'23 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _header
                                    (Tstruct _ObjectNode noattr)) _gfx
                                  (Tstruct _GraphNodeObject noattr)) _angle
                                (tarray tshort 3))
                              (Econst_int (Int.repr 0) tint) (tptr tshort))
                            tshort))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'22 (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __764 noattr)) _asS32
                                (tarray tint 80))
                              (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                                (Econst_int (Int.repr 0) tint) tint)
                              (tptr tint)) tint) (Etempvar _t'24 tshort)))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'19
                        (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                      (Ssequence
                        (Sset _t'20
                          (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                        (Ssequence
                          (Sset _t'21
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'20 (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _header
                                      (Tstruct _ObjectNode noattr)) _gfx
                                    (Tstruct _GraphNodeObject noattr)) _angle
                                  (tarray tshort 3))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))
                              tshort))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'19 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __764 noattr)) _asS32
                                  (tarray tint 80))
                                (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                                  (Econst_int (Int.repr 1) tint) tint)
                                (tptr tint)) tint) (Etempvar _t'21 tshort)))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'16
                          (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                        (Ssequence
                          (Sset _t'17
                            (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                          (Ssequence
                            (Sset _t'18
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'17 (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _header
                                        (Tstruct _ObjectNode noattr)) _gfx
                                      (Tstruct _GraphNodeObject noattr))
                                    _angle (tarray tshort 3))
                                  (Econst_int (Int.repr 2) tint)
                                  (tptr tshort)) tshort))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'16 (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _rawData
                                      (Tunion __764 noattr)) _asS32
                                    (tarray tint 80))
                                  (Ebinop Oadd
                                    (Econst_int (Int.repr 15) tint)
                                    (Econst_int (Int.repr 2) tint) tint)
                                  (tptr tint)) tint) (Etempvar _t'18 tshort)))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'13
                            (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                          (Ssequence
                            (Sset _t'14
                              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                            (Ssequence
                              (Sset _t'15
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'14 (tptr (Tstruct _Object noattr)))
                                            (Tstruct _Object noattr)) _header
                                          (Tstruct _ObjectNode noattr)) _gfx
                                        (Tstruct _GraphNodeObject noattr))
                                      _angle (tarray tshort 3))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr tshort)) tshort))
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'13 (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _rawData
                                        (Tunion __764 noattr)) _asS32
                                      (tarray tint 80))
                                    (Ebinop Oadd
                                      (Econst_int (Int.repr 18) tint)
                                      (Econst_int (Int.repr 0) tint) tint)
                                    (tptr tint)) tint)
                                (Etempvar _t'15 tshort)))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'10
                              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                            (Ssequence
                              (Sset _t'11
                                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                              (Ssequence
                                (Sset _t'12
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'11 (tptr (Tstruct _Object noattr)))
                                              (Tstruct _Object noattr))
                                            _header
                                            (Tstruct _ObjectNode noattr))
                                          _gfx
                                          (Tstruct _GraphNodeObject noattr))
                                        _angle (tarray tshort 3))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr tshort)) tshort))
                                (Sassign
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                                            (Tstruct _Object noattr))
                                          _rawData (Tunion __764 noattr))
                                        _asS32 (tarray tint 80))
                                      (Ebinop Oadd
                                        (Econst_int (Int.repr 18) tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      (tptr tint)) tint)
                                  (Etempvar _t'12 tshort)))))
                          (Ssequence
                            (Ssequence
                              (Sset _t'7
                                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                              (Ssequence
                                (Sset _t'8
                                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                (Ssequence
                                  (Sset _t'9
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                                                (Tstruct _Object noattr))
                                              _header
                                              (Tstruct _ObjectNode noattr))
                                            _gfx
                                            (Tstruct _GraphNodeObject noattr))
                                          _angle (tarray tshort 3))
                                        (Econst_int (Int.repr 2) tint)
                                        (tptr tshort)) tshort))
                                  (Sassign
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                                              (Tstruct _Object noattr))
                                            _rawData (Tunion __764 noattr))
                                          _asS32 (tarray tint 80))
                                        (Ebinop Oadd
                                          (Econst_int (Int.repr 18) tint)
                                          (Econst_int (Int.repr 2) tint)
                                          tint) (tptr tint)) tint)
                                    (Etempvar _t'9 tshort)))))
                            (Ssequence
                              (Ssequence
                                (Sset _t'5
                                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                (Ssequence
                                  (Sset _t'6
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
                                              (Etempvar _i tint)
                                              (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _angleVel (tarray tshort 3))
                                        (Econst_int (Int.repr 0) tint)
                                        (tptr tshort)) tshort))
                                  (Sassign
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                                              (Tstruct _Object noattr))
                                            _rawData (Tunion __764 noattr))
                                          _asS32 (tarray tint 80))
                                        (Econst_int (Int.repr 35) tint)
                                        (tptr tint)) tint)
                                    (Etempvar _t'6 tshort))))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'3
                                    (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                  (Ssequence
                                    (Sset _t'4
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
                                                (Etempvar _i tint)
                                                (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _angleVel (tarray tshort 3))
                                          (Econst_int (Int.repr 1) tint)
                                          (tptr tshort)) tshort))
                                    (Sassign
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                                                (Tstruct _Object noattr))
                                              _rawData (Tunion __764 noattr))
                                            _asS32 (tarray tint 80))
                                          (Econst_int (Int.repr 36) tint)
                                          (tptr tint)) tint)
                                      (Etempvar _t'4 tshort))))
                                (Ssequence
                                  (Sset _t'1
                                    (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                  (Ssequence
                                    (Sset _t'2
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
                                                (Etempvar _i tint)
                                                (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _angleVel (tarray tshort 3))
                                          (Econst_int (Int.repr 2) tint)
                                          (tptr tshort)) tshort))
                                    (Sassign
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
                                                (Tstruct _Object noattr))
                                              _rawData (Tunion __764 noattr))
                                            _asS32 (tarray tint 80))
                                          (Econst_int (Int.repr 37) tint)
                                          (tptr tint)) tint)
                                      (Etempvar _t'2 tshort))))))))))))))))))))
|}.

Definition f_spawn_particle := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_activeParticleFlag, tuint) :: (_model, tshort) ::
                (_behavior, (tptr tuint)) :: nil);
  fn_vars := nil;
  fn_temps := ((_particle, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: (_t'8, tuint) ::
               (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: (_t'3, tuint) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Sset _t'3
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
            _asU32 (tarray tuint 80)) (Econst_int (Int.repr 22) tint)
          (tptr tuint)) tuint))
    (Sifthenelse (Eunop Onotbool
                   (Ebinop Oand (Etempvar _t'3 tuint)
                     (Etempvar _activeParticleFlag tuint) tuint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'6 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
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
                        (Tunion __764 noattr)) _asU32 (tarray tuint 80))
                    (Econst_int (Int.repr 22) tint) (tptr tuint)) tuint))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __764 noattr)) _asU32 (tarray tuint 80))
                    (Econst_int (Int.repr 22) tint) (tptr tuint)) tuint)
                (Ebinop Oor (Etempvar _t'8 tuint)
                  (Etempvar _activeParticleFlag tuint) tuint)))))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'5
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Scall (Some _t'1)
                (Evar _spawn_object_at_origin (Tfunction
                                                ((tptr (Tstruct _Object noattr)) ::
                                                 tint :: tuint ::
                                                 (tptr tuint) :: nil)
                                                (tptr (Tstruct _Object noattr))
                                                cc_default))
                ((Etempvar _t'5 (tptr (Tstruct _Object noattr))) ::
                 (Econst_int (Int.repr 0) tint) ::
                 (Etempvar _model tshort) ::
                 (Etempvar _behavior (tptr tuint)) :: nil)))
            (Sset _particle (Etempvar _t'1 (tptr (Tstruct _Object noattr)))))
          (Ssequence
            (Sset _t'4
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Scall None
              (Evar _obj_copy_pos_and_angle (Tfunction
                                              ((tptr (Tstruct _Object noattr)) ::
                                               (tptr (Tstruct _Object noattr)) ::
                                               nil) tvoid cc_default))
              ((Etempvar _particle (tptr (Tstruct _Object noattr))) ::
               (Etempvar _t'4 (tptr (Tstruct _Object noattr))) :: nil)))))
      Sskip)))
|}.

Definition f_bhv_mario_update := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_particleFlags, tuint) :: (_i, tint) :: (_t'1, tint) ::
               (_t'8, (tptr (Tstruct _Object noattr))) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tuint) ::
               (_t'5, (tptr tuint)) :: (_t'4, tuchar) :: (_t'3, tuint) ::
               (_t'2, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _particleFlags (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'8 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Scall (Some _t'1)
          (Evar _execute_mario_action (Tfunction
                                        ((tptr (Tstruct _Object noattr)) ::
                                         nil) tint cc_default))
          ((Etempvar _t'8 (tptr (Tstruct _Object noattr))) :: nil)))
      (Sset _particleFlags (Etempvar _t'1 tint)))
    (Ssequence
      (Ssequence
        (Sset _t'7 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 27) tint)
              (tptr tint)) tint) (Etempvar _particleFlags tuint)))
      (Ssequence
        (Scall None
          (Evar _copy_mario_state_to_object (Tfunction nil tvoid cc_default))
          nil)
        (Ssequence
          (Sset _i (Econst_int (Int.repr 0) tint))
          (Sloop
            (Ssequence
              (Ssequence
                (Sset _t'6
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Evar _sParticleTypes (tarray (Tstruct _ParticleProperties noattr) 19))
                        (Etempvar _i tint)
                        (tptr (Tstruct _ParticleProperties noattr)))
                      (Tstruct _ParticleProperties noattr)) _particleFlag
                    tuint))
                (Sifthenelse (Ebinop One (Etempvar _t'6 tuint)
                               (Econst_int (Int.repr 0) tint) tint)
                  Sskip
                  Sbreak))
              (Ssequence
                (Ssequence
                  (Sset _t'2
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Evar _sParticleTypes (tarray (Tstruct _ParticleProperties noattr) 19))
                          (Etempvar _i tint)
                          (tptr (Tstruct _ParticleProperties noattr)))
                        (Tstruct _ParticleProperties noattr)) _particleFlag
                      tuint))
                  (Sifthenelse (Ebinop Oand (Etempvar _particleFlags tuint)
                                 (Etempvar _t'2 tuint) tuint)
                    (Ssequence
                      (Sset _t'3
                        (Efield
                          (Ederef
                            (Ebinop Oadd
                              (Evar _sParticleTypes (tarray (Tstruct _ParticleProperties noattr) 19))
                              (Etempvar _i tint)
                              (tptr (Tstruct _ParticleProperties noattr)))
                            (Tstruct _ParticleProperties noattr))
                          _activeParticleFlag tuint))
                      (Ssequence
                        (Sset _t'4
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Evar _sParticleTypes (tarray (Tstruct _ParticleProperties noattr) 19))
                                (Etempvar _i tint)
                                (tptr (Tstruct _ParticleProperties noattr)))
                              (Tstruct _ParticleProperties noattr)) _model
                            tuchar))
                        (Ssequence
                          (Sset _t'5
                            (Efield
                              (Ederef
                                (Ebinop Oadd
                                  (Evar _sParticleTypes (tarray (Tstruct _ParticleProperties noattr) 19))
                                  (Etempvar _i tint)
                                  (tptr (Tstruct _ParticleProperties noattr)))
                                (Tstruct _ParticleProperties noattr))
                              _behavior (tptr tuint)))
                          (Scall None
                            (Evar _spawn_particle (Tfunction
                                                    (tuint :: tshort ::
                                                     (tptr tuint) :: nil)
                                                    tvoid cc_default))
                            ((Etempvar _t'3 tuint) ::
                             (Etempvar _t'4 tuchar) ::
                             (Etempvar _t'5 (tptr tuint)) :: nil)))))
                    Sskip))
                (Sset _i
                  (Ebinop Oadd (Etempvar _i tint)
                    (Econst_int (Int.repr 1) tint) tint))))
            Sskip))))))
|}.

Definition f_update_objects_starting_at := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_objList, (tptr (Tstruct _ObjectNode noattr))) ::
                (_firstObj, (tptr (Tstruct _ObjectNode noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_count, tint) :: (_t'3, tshort) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _count (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Swhile
      (Ebinop One (Etempvar _objList (tptr (Tstruct _ObjectNode noattr)))
        (Etempvar _firstObj (tptr (Tstruct _ObjectNode noattr))) tint)
      (Ssequence
        (Sassign (Evar _gCurrentObject (tptr (Tstruct _Object noattr)))
          (Ecast (Etempvar _firstObj (tptr (Tstruct _ObjectNode noattr)))
            (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Ssequence
            (Sset _t'1
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'2
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'3
                  (Efield
                    (Efield
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
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
                            (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _header
                          (Tstruct _ObjectNode noattr)) _gfx
                        (Tstruct _GraphNodeObject noattr)) _node
                      (Tstruct _GraphNode noattr)) _flags tshort)
                  (Ebinop Oor (Etempvar _t'3 tshort)
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 5) tint) tint) tint)))))
          (Ssequence
            (Scall None
              (Evar _cur_obj_update (Tfunction nil tvoid cc_default)) nil)
            (Ssequence
              (Sset _firstObj
                (Efield
                  (Ederef
                    (Etempvar _firstObj (tptr (Tstruct _ObjectNode noattr)))
                    (Tstruct _ObjectNode noattr)) _next
                  (tptr (Tstruct _ObjectNode noattr))))
              (Sset _count
                (Ebinop Oadd (Etempvar _count tint)
                  (Econst_int (Int.repr 1) tint) tint)))))))
    (Sreturn (Some (Etempvar _count tint)))))
|}.

Definition f_update_objects_during_time_stop := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_objList, (tptr (Tstruct _ObjectNode noattr))) ::
                (_firstObj, (tptr (Tstruct _ObjectNode noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_count, tint) :: (_unfrozen, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'17, tuint) ::
               (_t'16, (tptr (Tstruct _Object noattr))) ::
               (_t'15, (tptr (Tstruct _Object noattr))) :: (_t'14, tuint) ::
               (_t'13, tuint) :: (_t'12, (tptr (Tstruct _Object noattr))) ::
               (_t'11, tshort) :: (_t'10, (tptr (Tstruct _Object noattr))) ::
               (_t'9, tuint) :: (_t'8, tshort) ::
               (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tshort) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _count (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Swhile
      (Ebinop One (Etempvar _objList (tptr (Tstruct _ObjectNode noattr)))
        (Etempvar _firstObj (tptr (Tstruct _ObjectNode noattr))) tint)
      (Ssequence
        (Sassign (Evar _gCurrentObject (tptr (Tstruct _Object noattr)))
          (Ecast (Etempvar _firstObj (tptr (Tstruct _ObjectNode noattr)))
            (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _unfrozen (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Ssequence
              (Sset _t'9 (Evar _gTimeStopState tuint))
              (Sifthenelse (Eunop Onotbool
                             (Ebinop Oand (Etempvar _t'9 tuint)
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 4) tint) tint) tuint)
                             tint)
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'15
                        (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                      (Ssequence
                        (Sset _t'16
                          (Evar _gMarioObject (tptr (Tstruct _Object noattr))))
                        (Sifthenelse (Ebinop Oeq
                                       (Etempvar _t'15 (tptr (Tstruct _Object noattr)))
                                       (Etempvar _t'16 (tptr (Tstruct _Object noattr)))
                                       tint)
                          (Ssequence
                            (Sset _t'17 (Evar _gTimeStopState tuint))
                            (Sset _t'1
                              (Ecast
                                (Eunop Onotbool
                                  (Ebinop Oand (Etempvar _t'17 tuint)
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 3) tint) tint)
                                    tuint) tint) tbool)))
                          (Sset _t'1 (Econst_int (Int.repr 0) tint)))))
                    (Sifthenelse (Etempvar _t'1 tint)
                      (Sset _unfrozen (Econst_int (Int.repr 1) tint))
                      Sskip))
                  (Ssequence
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
                                    (Tunion __764 noattr)) _asU32
                                  (tarray tuint 80))
                                (Econst_int (Int.repr 42) tint) (tptr tuint))
                              tuint))
                          (Sifthenelse (Ebinop Oand (Etempvar _t'13 tuint)
                                         (Ebinop Oor
                                           (Ebinop Oshl
                                             (Econst_int (Int.repr 1) tint)
                                             (Econst_int (Int.repr 2) tint)
                                             tint)
                                           (Ebinop Oshl
                                             (Econst_int (Int.repr 1) tint)
                                             (Econst_int (Int.repr 11) tint)
                                             tint) tint) tuint)
                            (Ssequence
                              (Sset _t'14 (Evar _gTimeStopState tuint))
                              (Sset _t'2
                                (Ecast
                                  (Eunop Onotbool
                                    (Ebinop Oand (Etempvar _t'14 tuint)
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 3) tint) tint)
                                      tuint) tint) tbool)))
                            (Sset _t'2 (Econst_int (Int.repr 0) tint)))))
                      (Sifthenelse (Etempvar _t'2 tint)
                        (Sset _unfrozen (Econst_int (Int.repr 1) tint))
                        Sskip))
                    (Ssequence
                      (Sset _t'10
                        (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                      (Ssequence
                        (Sset _t'11
                          (Efield
                            (Ederef
                              (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _activeFlags tshort))
                        (Sifthenelse (Ebinop Oand (Etempvar _t'11 tshort)
                                       (Ebinop Oor
                                         (Ebinop Oshl
                                           (Econst_int (Int.repr 1) tint)
                                           (Econst_int (Int.repr 4) tint)
                                           tint)
                                         (Ebinop Oshl
                                           (Econst_int (Int.repr 1) tint)
                                           (Econst_int (Int.repr 5) tint)
                                           tint) tint) tint)
                          (Sset _unfrozen (Econst_int (Int.repr 1) tint))
                          Sskip)))))
                Sskip))
            (Ssequence
              (Sifthenelse (Etempvar _unfrozen tint)
                (Ssequence
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
                          (Ebinop Oor (Etempvar _t'8 tshort)
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 5) tint) tint) tint)))))
                  (Scall None
                    (Evar _cur_obj_update (Tfunction nil tvoid cc_default))
                    nil))
                (Ssequence
                  (Sset _t'3
                    (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sset _t'4
                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sset _t'5
                        (Efield
                          (Efield
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
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
                                  (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _header
                                (Tstruct _ObjectNode noattr)) _gfx
                              (Tstruct _GraphNodeObject noattr)) _node
                            (Tstruct _GraphNode noattr)) _flags tshort)
                        (Ebinop Oand (Etempvar _t'5 tshort)
                          (Eunop Onotint
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 5) tint) tint) tint)
                          tint))))))
              (Ssequence
                (Sset _firstObj
                  (Efield
                    (Ederef
                      (Etempvar _firstObj (tptr (Tstruct _ObjectNode noattr)))
                      (Tstruct _ObjectNode noattr)) _next
                    (tptr (Tstruct _ObjectNode noattr))))
                (Sset _count
                  (Ebinop Oadd (Etempvar _count tint)
                    (Econst_int (Int.repr 1) tint) tint))))))))
    (Sreturn (Some (Etempvar _count tint)))))
|}.

Definition f_update_objects_in_list := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_objList, (tptr (Tstruct _ObjectNode noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_count, tint) ::
               (_firstObj, (tptr (Tstruct _ObjectNode noattr))) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'3, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _firstObj
    (Efield
      (Ederef (Etempvar _objList (tptr (Tstruct _ObjectNode noattr)))
        (Tstruct _ObjectNode noattr)) _next
      (tptr (Tstruct _ObjectNode noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'3 (Evar _gTimeStopState tuint))
      (Sifthenelse (Eunop Onotbool
                     (Ebinop Oand (Etempvar _t'3 tuint)
                       (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 6) tint) tint) tuint) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _update_objects_starting_at (Tfunction
                                                ((tptr (Tstruct _ObjectNode noattr)) ::
                                                 (tptr (Tstruct _ObjectNode noattr)) ::
                                                 nil) tint cc_default))
            ((Etempvar _objList (tptr (Tstruct _ObjectNode noattr))) ::
             (Etempvar _firstObj (tptr (Tstruct _ObjectNode noattr))) :: nil))
          (Sset _count (Etempvar _t'1 tint)))
        (Ssequence
          (Scall (Some _t'2)
            (Evar _update_objects_during_time_stop (Tfunction
                                                     ((tptr (Tstruct _ObjectNode noattr)) ::
                                                      (tptr (Tstruct _ObjectNode noattr)) ::
                                                      nil) tint cc_default))
            ((Etempvar _objList (tptr (Tstruct _ObjectNode noattr))) ::
             (Etempvar _firstObj (tptr (Tstruct _ObjectNode noattr))) :: nil))
          (Sset _count (Etempvar _t'2 tint)))))
    (Sreturn (Some (Etempvar _count tint)))))
|}.

Definition f_unload_deactivated_objects_in_list := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_objList, (tptr (Tstruct _ObjectNode noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_obj, (tptr (Tstruct _ObjectNode noattr))) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tuint) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: (_t'2, tshort) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _obj
    (Efield
      (Ederef (Etempvar _objList (tptr (Tstruct _ObjectNode noattr)))
        (Tstruct _ObjectNode noattr)) _next
      (tptr (Tstruct _ObjectNode noattr))))
  (Ssequence
    (Swhile
      (Ebinop One (Etempvar _objList (tptr (Tstruct _ObjectNode noattr)))
        (Etempvar _obj (tptr (Tstruct _ObjectNode noattr))) tint)
      (Ssequence
        (Sassign (Evar _gCurrentObject (tptr (Tstruct _Object noattr)))
          (Ecast (Etempvar _obj (tptr (Tstruct _ObjectNode noattr)))
            (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _obj
            (Efield
              (Ederef (Etempvar _obj (tptr (Tstruct _ObjectNode noattr)))
                (Tstruct _ObjectNode noattr)) _next
              (tptr (Tstruct _ObjectNode noattr))))
          (Ssequence
            (Sset _t'1
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'2
                (Efield
                  (Ederef (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _activeFlags tshort))
              (Sifthenelse (Ebinop One
                             (Ebinop Oand (Etempvar _t'2 tshort)
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 0) tint) tint) tint)
                             (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                               (Econst_int (Int.repr 0) tint) tint) tint)
                (Ssequence
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
                                (Tunion __764 noattr)) _asU32
                              (tarray tuint 80))
                            (Econst_int (Int.repr 1) tint) (tptr tuint))
                          tuint))
                      (Sifthenelse (Eunop Onotbool
                                     (Ebinop Oand (Etempvar _t'5 tuint)
                                       (Ebinop Oshl
                                         (Econst_int (Int.repr 1) tint)
                                         (Econst_int (Int.repr 14) tint)
                                         tint) tuint) tint)
                        (Ssequence
                          (Sset _t'6
                            (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                          (Scall None
                            (Evar _set_object_respawn_info_bits (Tfunction
                                                                  ((tptr (Tstruct _Object noattr)) ::
                                                                   tuchar ::
                                                                   nil) tvoid
                                                                  cc_default))
                            ((Etempvar _t'6 (tptr (Tstruct _Object noattr))) ::
                             (Econst_int (Int.repr 255) tint) :: nil)))
                        Sskip)))
                  (Ssequence
                    (Sset _t'3
                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                    (Scall None
                      (Evar _unload_object (Tfunction
                                             ((tptr (Tstruct _Object noattr)) ::
                                              nil) tvoid cc_default))
                      ((Etempvar _t'3 (tptr (Tstruct _Object noattr))) ::
                       nil))))
                Sskip))))))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_set_object_respawn_info_bits := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_obj, (tptr (Tstruct _Object noattr))) :: (_bits, tuchar) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_info32, (tptr tuint)) :: (_info16, (tptr tushort)) ::
               (_t'5, (tptr tvoid)) :: (_t'4, tuint) ::
               (_t'3, (tptr tvoid)) :: (_t'2, tushort) :: (_t'1, tshort) ::
               nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Efield
      (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
        (Tstruct _Object noattr)) _respawnInfoType tshort))
  (Sswitch (Etempvar _t'1 tshort)
    (LScons (Some 1)
      (Ssequence
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _respawnInfo (tptr tvoid)))
          (Sset _info32 (Ecast (Etempvar _t'5 (tptr tvoid)) (tptr tuint))))
        (Ssequence
          (Ssequence
            (Sset _t'4 (Ederef (Etempvar _info32 (tptr tuint)) tuint))
            (Sassign (Ederef (Etempvar _info32 (tptr tuint)) tuint)
              (Ebinop Oor (Etempvar _t'4 tuint)
                (Ebinop Oshl (Etempvar _bits tuchar)
                  (Econst_int (Int.repr 8) tint) tint) tuint)))
          Sbreak))
      (LScons (Some 2)
        (Ssequence
          (Ssequence
            (Sset _t'3
              (Efield
                (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _respawnInfo (tptr tvoid)))
            (Sset _info16
              (Ecast (Etempvar _t'3 (tptr tvoid)) (tptr tushort))))
          (Ssequence
            (Ssequence
              (Sset _t'2 (Ederef (Etempvar _info16 (tptr tushort)) tushort))
              (Sassign (Ederef (Etempvar _info16 (tptr tushort)) tushort)
                (Ebinop Oor (Etempvar _t'2 tushort)
                  (Ebinop Oshl (Etempvar _bits tuchar)
                    (Econst_int (Int.repr 8) tint) tint) tint)))
            Sbreak))
        LSnil))))
|}.

Definition f_unload_objects_from_area := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_unused, tint) :: (_areaIndex, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_obj, (tptr (Tstruct _Object noattr))) ::
               (_node, (tptr (Tstruct _ObjectNode noattr))) ::
               (_list, (tptr (Tstruct _ObjectNode noattr))) :: (_i, tint) ::
               (_t'2, (tptr (Tstruct _ObjectNode noattr))) ::
               (_t'1, tschar) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _gObjectLists (tptr (Tstruct _ObjectNode noattr)))
    (Evar _gObjectListArray (tarray (Tstruct _ObjectNode noattr) 16)))
  (Ssequence
    (Sset _i (Econst_int (Int.repr 0) tint))
    (Sloop
      (Ssequence
        (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                       (Econst_int (Int.repr 13) tint) tint)
          Sskip
          Sbreak)
        (Ssequence
          (Ssequence
            (Sset _t'2
              (Evar _gObjectLists (tptr (Tstruct _ObjectNode noattr))))
            (Sset _list
              (Ebinop Oadd
                (Etempvar _t'2 (tptr (Tstruct _ObjectNode noattr)))
                (Etempvar _i tint) (tptr (Tstruct _ObjectNode noattr)))))
          (Ssequence
            (Sset _node
              (Efield
                (Ederef (Etempvar _list (tptr (Tstruct _ObjectNode noattr)))
                  (Tstruct _ObjectNode noattr)) _next
                (tptr (Tstruct _ObjectNode noattr))))
            (Swhile
              (Ebinop One
                (Etempvar _node (tptr (Tstruct _ObjectNode noattr)))
                (Etempvar _list (tptr (Tstruct _ObjectNode noattr))) tint)
              (Ssequence
                (Sset _obj
                  (Ecast (Etempvar _node (tptr (Tstruct _ObjectNode noattr)))
                    (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _node
                    (Efield
                      (Ederef
                        (Etempvar _node (tptr (Tstruct _ObjectNode noattr)))
                        (Tstruct _ObjectNode noattr)) _next
                      (tptr (Tstruct _ObjectNode noattr))))
                  (Ssequence
                    (Sset _t'1
                      (Efield
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _obj (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _header
                            (Tstruct _ObjectNode noattr)) _gfx
                          (Tstruct _GraphNodeObject noattr)) _activeAreaIndex
                        tschar))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tschar)
                                   (Etempvar _areaIndex tint) tint)
                      (Scall None
                        (Evar _unload_object (Tfunction
                                               ((tptr (Tstruct _Object noattr)) ::
                                                nil) tvoid cc_default))
                        ((Etempvar _obj (tptr (Tstruct _Object noattr))) ::
                         nil))
                      Sskip))))))))
      (Sset _i
        (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint) tint)))))
|}.

Definition f_spawn_objects_from_info := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_unused, tint) ::
                (_spawnInfo, (tptr (Tstruct _SpawnInfo noattr))) :: nil);
  fn_vars := ((_filler, (tarray tuchar 4)) :: nil);
  fn_temps := ((_object, (tptr (Tstruct _Object noattr))) ::
               (_script, (tptr tuint)) :: (_arg16, tshort) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr tvoid)) :: (_t'19, tshort) :: (_t'18, tshort) ::
               (_t'17, tuint) :: (_t'16, (tptr tvoid)) :: (_t'15, tuint) ::
               (_t'14, tuint) :: (_t'13, tuint) :: (_t'12, tshort) ::
               (_t'11, tshort) :: (_t'10, tshort) :: (_t'9, tshort) ::
               (_t'8, tshort) :: (_t'7, tshort) :: (_t'6, tshort) ::
               (_t'5, tshort) :: (_t'4, tshort) :: (_t'3, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _gObjectLists (tptr (Tstruct _ObjectNode noattr)))
    (Evar _gObjectListArray (tarray (Tstruct _ObjectNode noattr) 16)))
  (Ssequence
    (Sassign (Evar _gTimeStopState tuint) (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Sassign (Evar _gWDWWaterLevelChanging tshort)
        (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Sassign (Evar _gMarioOnMerryGoRound tshort)
          (Econst_int (Int.repr 0) tint))
        (Ssequence
          (Scall None
            (Evar _clear_mario_platform (Tfunction nil tvoid cc_default))
            nil)
          (Ssequence
            (Ssequence
              (Sset _t'18 (Evar _gCurrAreaIndex tshort))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'18 tshort)
                             (Econst_int (Int.repr 2) tint) tint)
                (Ssequence
                  (Sset _t'19 (Evar _gCCMEnteredSlide tshort))
                  (Sassign (Evar _gCCMEnteredSlide tshort)
                    (Ebinop Oor (Etempvar _t'19 tshort)
                      (Econst_int (Int.repr 1) tint) tint)))
                Sskip))
            (Swhile
              (Ebinop One
                (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
              (Ssequence
                (Ssequence
                  (Sset _t'17
                    (Efield
                      (Ederef
                        (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                        (Tstruct _SpawnInfo noattr)) _behaviorArg tuint))
                  (Sset _arg16
                    (Ecast
                      (Ecast
                        (Ebinop Oand (Etempvar _t'17 tuint)
                          (Econst_int (Int.repr 65535) tint) tuint) tshort)
                      tshort)))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'16
                        (Efield
                          (Ederef
                            (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                            (Tstruct _SpawnInfo noattr)) _behaviorScript
                          (tptr tvoid)))
                      (Scall (Some _t'1)
                        (Evar _segmented_to_virtual (Tfunction
                                                      ((tptr tvoid) :: nil)
                                                      (tptr tvoid)
                                                      cc_default))
                        ((Etempvar _t'16 (tptr tvoid)) :: nil)))
                    (Sset _script (Etempvar _t'1 (tptr tvoid))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'3
                        (Efield
                          (Ederef
                            (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                            (Tstruct _SpawnInfo noattr)) _behaviorArg tuint))
                      (Sifthenelse (Ebinop One
                                     (Ebinop Oand (Etempvar _t'3 tuint)
                                       (Ebinop Oshl
                                         (Econst_int (Int.repr 255) tint)
                                         (Econst_int (Int.repr 8) tint) tint)
                                       tuint)
                                     (Ebinop Oshl
                                       (Econst_int (Int.repr 255) tint)
                                       (Econst_int (Int.repr 8) tint) tint)
                                     tint)
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'2)
                              (Evar _create_object (Tfunction
                                                     ((tptr tuint) :: nil)
                                                     (tptr (Tstruct _Object noattr))
                                                     cc_default))
                              ((Etempvar _script (tptr tuint)) :: nil))
                            (Sset _object
                              (Etempvar _t'2 (tptr (Tstruct _Object noattr)))))
                          (Ssequence
                            (Ssequence
                              (Sset _t'15
                                (Efield
                                  (Ederef
                                    (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                                    (Tstruct _SpawnInfo noattr)) _behaviorArg
                                  tuint))
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _object (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _rawData
                                        (Tunion __764 noattr)) _asS32
                                      (tarray tint 80))
                                    (Econst_int (Int.repr 64) tint)
                                    (tptr tint)) tint)
                                (Etempvar _t'15 tuint)))
                            (Ssequence
                              (Ssequence
                                (Sset _t'14
                                  (Efield
                                    (Ederef
                                      (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                                      (Tstruct _SpawnInfo noattr))
                                    _behaviorArg tuint))
                                (Sassign
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _object (tptr (Tstruct _Object noattr)))
                                            (Tstruct _Object noattr))
                                          _rawData (Tunion __764 noattr))
                                        _asS32 (tarray tint 80))
                                      (Econst_int (Int.repr 47) tint)
                                      (tptr tint)) tint)
                                  (Ebinop Oand
                                    (Ebinop Oshr (Etempvar _t'14 tuint)
                                      (Econst_int (Int.repr 16) tint) tuint)
                                    (Econst_int (Int.repr 255) tint) tuint)))
                              (Ssequence
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _object (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _behavior
                                    (tptr tuint))
                                  (Etempvar _script (tptr tuint)))
                                (Ssequence
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Etempvar _object (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _unused1
                                      tuint) (Econst_int (Int.repr 0) tint))
                                  (Ssequence
                                    (Sassign
                                      (Efield
                                        (Ederef
                                          (Etempvar _object (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr))
                                        _respawnInfoType tshort)
                                      (Econst_int (Int.repr 1) tint))
                                    (Ssequence
                                      (Sassign
                                        (Efield
                                          (Ederef
                                            (Etempvar _object (tptr (Tstruct _Object noattr)))
                                            (Tstruct _Object noattr))
                                          _respawnInfo (tptr tvoid))
                                        (Eaddrof
                                          (Efield
                                            (Ederef
                                              (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                                              (Tstruct _SpawnInfo noattr))
                                            _behaviorArg tuint) (tptr tuint)))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'13
                                            (Efield
                                              (Ederef
                                                (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                                                (Tstruct _SpawnInfo noattr))
                                              _behaviorArg tuint))
                                          (Sifthenelse (Ebinop Oand
                                                         (Etempvar _t'13 tuint)
                                                         (Econst_int (Int.repr 1) tint)
                                                         tuint)
                                            (Ssequence
                                              (Sassign
                                                (Evar _gMarioObject (tptr (Tstruct _Object noattr)))
                                                (Etempvar _object (tptr (Tstruct _Object noattr))))
                                              (Scall None
                                                (Evar _geo_make_first_child 
                                                (Tfunction
                                                  ((tptr (Tstruct _GraphNode noattr)) ::
                                                   nil)
                                                  (tptr (Tstruct _GraphNode noattr))
                                                  cc_default))
                                                ((Eaddrof
                                                   (Efield
                                                     (Efield
                                                       (Efield
                                                         (Ederef
                                                           (Etempvar _object (tptr (Tstruct _Object noattr)))
                                                           (Tstruct _Object noattr))
                                                         _header
                                                         (Tstruct _ObjectNode noattr))
                                                       _gfx
                                                       (Tstruct _GraphNodeObject noattr))
                                                     _node
                                                     (Tstruct _GraphNode noattr))
                                                   (tptr (Tstruct _GraphNode noattr))) ::
                                                 nil)))
                                            Sskip))
                                        (Ssequence
                                          (Scall None
                                            (Evar _geo_obj_init_spawninfo 
                                            (Tfunction
                                              ((tptr (Tstruct _GraphNodeObject noattr)) ::
                                               (tptr (Tstruct _SpawnInfo noattr)) ::
                                               nil) tvoid cc_default))
                                            ((Eaddrof
                                               (Efield
                                                 (Efield
                                                   (Ederef
                                                     (Etempvar _object (tptr (Tstruct _Object noattr)))
                                                     (Tstruct _Object noattr))
                                                   _header
                                                   (Tstruct _ObjectNode noattr))
                                                 _gfx
                                                 (Tstruct _GraphNodeObject noattr))
                                               (tptr (Tstruct _GraphNodeObject noattr))) ::
                                             (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr))) ::
                                             nil))
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'12
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                                                        (Tstruct _SpawnInfo noattr))
                                                      _startPos
                                                      (tarray tshort 3))
                                                    (Econst_int (Int.repr 0) tint)
                                                    (tptr tshort)) tshort))
                                              (Sassign
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Efield
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _object (tptr (Tstruct _Object noattr)))
                                                          (Tstruct _Object noattr))
                                                        _rawData
                                                        (Tunion __764 noattr))
                                                      _asF32
                                                      (tarray tfloat 80))
                                                    (Ebinop Oadd
                                                      (Econst_int (Int.repr 6) tint)
                                                      (Econst_int (Int.repr 0) tint)
                                                      tint) (tptr tfloat))
                                                  tfloat)
                                                (Etempvar _t'12 tshort)))
                                            (Ssequence
                                              (Ssequence
                                                (Sset _t'11
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                                                          (Tstruct _SpawnInfo noattr))
                                                        _startPos
                                                        (tarray tshort 3))
                                                      (Econst_int (Int.repr 1) tint)
                                                      (tptr tshort)) tshort))
                                                (Sassign
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Efield
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar _object (tptr (Tstruct _Object noattr)))
                                                            (Tstruct _Object noattr))
                                                          _rawData
                                                          (Tunion __764 noattr))
                                                        _asF32
                                                        (tarray tfloat 80))
                                                      (Ebinop Oadd
                                                        (Econst_int (Int.repr 6) tint)
                                                        (Econst_int (Int.repr 1) tint)
                                                        tint) (tptr tfloat))
                                                    tfloat)
                                                  (Etempvar _t'11 tshort)))
                                              (Ssequence
                                                (Ssequence
                                                  (Sset _t'10
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                                                            (Tstruct _SpawnInfo noattr))
                                                          _startPos
                                                          (tarray tshort 3))
                                                        (Econst_int (Int.repr 2) tint)
                                                        (tptr tshort))
                                                      tshort))
                                                  (Sassign
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Efield
                                                          (Efield
                                                            (Ederef
                                                              (Etempvar _object (tptr (Tstruct _Object noattr)))
                                                              (Tstruct _Object noattr))
                                                            _rawData
                                                            (Tunion __764 noattr))
                                                          _asF32
                                                          (tarray tfloat 80))
                                                        (Ebinop Oadd
                                                          (Econst_int (Int.repr 6) tint)
                                                          (Econst_int (Int.repr 2) tint)
                                                          tint)
                                                        (tptr tfloat))
                                                      tfloat)
                                                    (Etempvar _t'10 tshort)))
                                                (Ssequence
                                                  (Ssequence
                                                    (Sset _t'9
                                                      (Ederef
                                                        (Ebinop Oadd
                                                          (Efield
                                                            (Ederef
                                                              (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                                                              (Tstruct _SpawnInfo noattr))
                                                            _startAngle
                                                            (tarray tshort 3))
                                                          (Econst_int (Int.repr 0) tint)
                                                          (tptr tshort))
                                                        tshort))
                                                    (Sassign
                                                      (Ederef
                                                        (Ebinop Oadd
                                                          (Efield
                                                            (Efield
                                                              (Ederef
                                                                (Etempvar _object (tptr (Tstruct _Object noattr)))
                                                                (Tstruct _Object noattr))
                                                              _rawData
                                                              (Tunion __764 noattr))
                                                            _asS32
                                                            (tarray tint 80))
                                                          (Ebinop Oadd
                                                            (Econst_int (Int.repr 18) tint)
                                                            (Econst_int (Int.repr 0) tint)
                                                            tint)
                                                          (tptr tint)) tint)
                                                      (Etempvar _t'9 tshort)))
                                                  (Ssequence
                                                    (Ssequence
                                                      (Sset _t'8
                                                        (Ederef
                                                          (Ebinop Oadd
                                                            (Efield
                                                              (Ederef
                                                                (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                                                                (Tstruct _SpawnInfo noattr))
                                                              _startAngle
                                                              (tarray tshort 3))
                                                            (Econst_int (Int.repr 1) tint)
                                                            (tptr tshort))
                                                          tshort))
                                                      (Sassign
                                                        (Ederef
                                                          (Ebinop Oadd
                                                            (Efield
                                                              (Efield
                                                                (Ederef
                                                                  (Etempvar _object (tptr (Tstruct _Object noattr)))
                                                                  (Tstruct _Object noattr))
                                                                _rawData
                                                                (Tunion __764 noattr))
                                                              _asS32
                                                              (tarray tint 80))
                                                            (Ebinop Oadd
                                                              (Econst_int (Int.repr 18) tint)
                                                              (Econst_int (Int.repr 1) tint)
                                                              tint)
                                                            (tptr tint))
                                                          tint)
                                                        (Etempvar _t'8 tshort)))
                                                    (Ssequence
                                                      (Ssequence
                                                        (Sset _t'7
                                                          (Ederef
                                                            (Ebinop Oadd
                                                              (Efield
                                                                (Ederef
                                                                  (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                                                                  (Tstruct _SpawnInfo noattr))
                                                                _startAngle
                                                                (tarray tshort 3))
                                                              (Econst_int (Int.repr 2) tint)
                                                              (tptr tshort))
                                                            tshort))
                                                        (Sassign
                                                          (Ederef
                                                            (Ebinop Oadd
                                                              (Efield
                                                                (Efield
                                                                  (Ederef
                                                                    (Etempvar _object (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                  _rawData
                                                                  (Tunion __764 noattr))
                                                                _asS32
                                                                (tarray tint 80))
                                                              (Ebinop Oadd
                                                                (Econst_int (Int.repr 18) tint)
                                                                (Econst_int (Int.repr 2) tint)
                                                                tint)
                                                              (tptr tint))
                                                            tint)
                                                          (Etempvar _t'7 tshort)))
                                                      (Ssequence
                                                        (Ssequence
                                                          (Sset _t'6
                                                            (Ederef
                                                              (Ebinop Oadd
                                                                (Efield
                                                                  (Ederef
                                                                    (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                                                                    (Tstruct _SpawnInfo noattr))
                                                                  _startAngle
                                                                  (tarray tshort 3))
                                                                (Econst_int (Int.repr 0) tint)
                                                                (tptr tshort))
                                                              tshort))
                                                          (Sassign
                                                            (Ederef
                                                              (Ebinop Oadd
                                                                (Efield
                                                                  (Efield
                                                                    (Ederef
                                                                    (Etempvar _object (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _rawData
                                                                    (Tunion __764 noattr))
                                                                  _asS32
                                                                  (tarray tint 80))
                                                                (Ebinop Oadd
                                                                  (Econst_int (Int.repr 15) tint)
                                                                  (Econst_int (Int.repr 0) tint)
                                                                  tint)
                                                                (tptr tint))
                                                              tint)
                                                            (Etempvar _t'6 tshort)))
                                                        (Ssequence
                                                          (Ssequence
                                                            (Sset _t'5
                                                              (Ederef
                                                                (Ebinop Oadd
                                                                  (Efield
                                                                    (Ederef
                                                                    (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                                                                    (Tstruct _SpawnInfo noattr))
                                                                    _startAngle
                                                                    (tarray tshort 3))
                                                                  (Econst_int (Int.repr 1) tint)
                                                                  (tptr tshort))
                                                                tshort))
                                                            (Sassign
                                                              (Ederef
                                                                (Ebinop Oadd
                                                                  (Efield
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _object (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _rawData
                                                                    (Tunion __764 noattr))
                                                                    _asS32
                                                                    (tarray tint 80))
                                                                  (Ebinop Oadd
                                                                    (Econst_int (Int.repr 15) tint)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                  (tptr tint))
                                                                tint)
                                                              (Etempvar _t'5 tshort)))
                                                          (Ssequence
                                                            (Sset _t'4
                                                              (Ederef
                                                                (Ebinop Oadd
                                                                  (Efield
                                                                    (Ederef
                                                                    (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                                                                    (Tstruct _SpawnInfo noattr))
                                                                    _startAngle
                                                                    (tarray tshort 3))
                                                                  (Econst_int (Int.repr 2) tint)
                                                                  (tptr tshort))
                                                                tshort))
                                                            (Sassign
                                                              (Ederef
                                                                (Ebinop Oadd
                                                                  (Efield
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _object (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _rawData
                                                                    (Tunion __764 noattr))
                                                                    _asS32
                                                                    (tarray tint 80))
                                                                  (Ebinop Oadd
                                                                    (Econst_int (Int.repr 15) tint)
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    tint)
                                                                  (tptr tint))
                                                                tint)
                                                              (Etempvar _t'4 tshort))))))))))))))))))))
                        Sskip))
                    (Sset _spawnInfo
                      (Efield
                        (Ederef
                          (Etempvar _spawnInfo (tptr (Tstruct _SpawnInfo noattr)))
                          (Tstruct _SpawnInfo noattr)) _next
                        (tptr (Tstruct _SpawnInfo noattr))))))))))))))
|}.

Definition f_stub_obj_list_processor_1 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
Sskip
|}.

Definition f_clear_objects := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_t'1, (tptr (Tstruct _MemoryPool noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _gTHIWaterDrained tshort) (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sassign (Evar _gTimeStopState tuint) (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Sassign (Evar _gMarioObject (tptr (Tstruct _Object noattr)))
        (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
      (Ssequence
        (Sassign (Evar _gMarioCurrentRoom tshort)
          (Econst_int (Int.repr 0) tint))
        (Ssequence
          (Ssequence
            (Sset _i (Econst_int (Int.repr 0) tint))
            (Sloop
              (Ssequence
                (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                               (Econst_int (Int.repr 60) tint) tint)
                  Sskip
                  Sbreak)
                (Ssequence
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Ederef
                          (Ebinop Oadd
                            (Evar _gDoorAdjacentRooms (tarray (tarray tschar 2) 60))
                            (Etempvar _i tint) (tptr (tarray tschar 2)))
                          (tarray tschar 2)) (Econst_int (Int.repr 0) tint)
                        (tptr tschar)) tschar)
                    (Econst_int (Int.repr 0) tint))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Ederef
                          (Ebinop Oadd
                            (Evar _gDoorAdjacentRooms (tarray (tarray tschar 2) 60))
                            (Etempvar _i tint) (tptr (tarray tschar 2)))
                          (tarray tschar 2)) (Econst_int (Int.repr 1) tint)
                        (tptr tschar)) tschar)
                    (Econst_int (Int.repr 0) tint))))
              (Sset _i
                (Ebinop Oadd (Etempvar _i tint)
                  (Econst_int (Int.repr 1) tint) tint))))
          (Ssequence
            (Scall None
              (Evar _debug_unknown_level_select_check (Tfunction nil tvoid
                                                        cc_default)) nil)
            (Ssequence
              (Scall None
                (Evar _init_free_object_list (Tfunction nil tvoid cc_default))
                nil)
              (Ssequence
                (Scall None
                  (Evar _clear_object_lists (Tfunction
                                              ((tptr (Tstruct _ObjectNode noattr)) ::
                                               nil) tvoid cc_default))
                  ((Evar _gObjectListArray (tarray (Tstruct _ObjectNode noattr) 16)) ::
                   nil))
                (Ssequence
                  (Scall None
                    (Evar _stub_behavior_script_2 (Tfunction nil tvoid
                                                    cc_default)) nil)
                  (Ssequence
                    (Scall None
                      (Evar _stub_obj_list_processor_1 (Tfunction nil tvoid
                                                         cc_default)) nil)
                    (Ssequence
                      (Ssequence
                        (Sset _i (Econst_int (Int.repr 0) tint))
                        (Sloop
                          (Ssequence
                            (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                                           (Econst_int (Int.repr 240) tint)
                                           tint)
                              Sskip
                              Sbreak)
                            (Ssequence
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Evar _gObjectPool (tarray (Tstruct _Object noattr) 240))
                                      (Etempvar _i tint)
                                      (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _activeFlags
                                  tshort) (Econst_int (Int.repr 0) tint))
                              (Scall None
                                (Evar _geo_reset_object_node (Tfunction
                                                               ((tptr (Tstruct _GraphNodeObject noattr)) ::
                                                                nil) tvoid
                                                               cc_default))
                                ((Eaddrof
                                   (Efield
                                     (Efield
                                       (Ederef
                                         (Ebinop Oadd
                                           (Evar _gObjectPool (tarray (Tstruct _Object noattr) 240))
                                           (Etempvar _i tint)
                                           (tptr (Tstruct _Object noattr)))
                                         (Tstruct _Object noattr)) _header
                                       (Tstruct _ObjectNode noattr)) _gfx
                                     (Tstruct _GraphNodeObject noattr))
                                   (tptr (Tstruct _GraphNodeObject noattr))) ::
                                 nil))))
                          (Sset _i
                            (Ebinop Oadd (Etempvar _i tint)
                              (Econst_int (Int.repr 1) tint) tint))))
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'1)
                            (Evar _mem_pool_init (Tfunction
                                                   (tuint :: tuint :: nil)
                                                   (tptr (Tstruct _MemoryPool noattr))
                                                   cc_default))
                            ((Econst_int (Int.repr 2048) tint) ::
                             (Econst_int (Int.repr 0) tint) :: nil))
                          (Sassign
                            (Evar _gObjectMemoryPool (tptr (Tstruct _MemoryPool noattr)))
                            (Etempvar _t'1 (tptr (Tstruct _MemoryPool noattr)))))
                        (Ssequence
                          (Sassign
                            (Evar _gObjectLists (tptr (Tstruct _ObjectNode noattr)))
                            (Evar _gObjectListArray (tarray (Tstruct _ObjectNode noattr) 16)))
                          (Scall None
                            (Evar _clear_dynamic_surfaces (Tfunction nil
                                                            tvoid cc_default))
                            nil))))))))))))))
|}.

Definition f_update_terrain_objects := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) ::
               (_t'4, (tptr (Tstruct _ObjectNode noattr))) ::
               (_t'3, (tptr (Tstruct _ObjectNode noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'4 (Evar _gObjectLists (tptr (Tstruct _ObjectNode noattr))))
      (Scall (Some _t'1)
        (Evar _update_objects_in_list (Tfunction
                                        ((tptr (Tstruct _ObjectNode noattr)) ::
                                         nil) tint cc_default))
        ((Ebinop Oadd (Etempvar _t'4 (tptr (Tstruct _ObjectNode noattr)))
           (Econst_int (Int.repr 11) tint)
           (tptr (Tstruct _ObjectNode noattr))) :: nil)))
    (Sassign (Evar _gObjectCounter tuint) (Etempvar _t'1 tint)))
  (Ssequence
    (Ssequence
      (Sset _t'3 (Evar _gObjectLists (tptr (Tstruct _ObjectNode noattr))))
      (Scall (Some _t'2)
        (Evar _update_objects_in_list (Tfunction
                                        ((tptr (Tstruct _ObjectNode noattr)) ::
                                         nil) tint cc_default))
        ((Ebinop Oadd (Etempvar _t'3 (tptr (Tstruct _ObjectNode noattr)))
           (Econst_int (Int.repr 9) tint)
           (tptr (Tstruct _ObjectNode noattr))) :: nil)))
    (Sassign (Evar _gObjectCounter tuint) (Etempvar _t'2 tint))))
|}.

Definition f_update_non_terrain_objects := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_filler, (tarray tuchar 4)) :: nil);
  fn_temps := ((_listIndex, tint) :: (_i, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'5, tschar) ::
               (_t'4, (tptr (Tstruct _ObjectNode noattr))) ::
               (_t'3, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _i (Econst_int (Int.repr 2) tint))
  (Sloop
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'5
              (Ederef
                (Ebinop Oadd
                  (Evar _sObjectListUpdateOrder (tarray tschar 11))
                  (Etempvar _i tint) (tptr tschar)) tschar))
            (Sset _t'1 (Ecast (Etempvar _t'5 tschar) tint)))
          (Sset _listIndex (Etempvar _t'1 tint)))
        (Sifthenelse (Ebinop One (Etempvar _t'1 tint)
                       (Eunop Oneg (Econst_int (Int.repr 1) tint) tint) tint)
          Sskip
          Sbreak))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'4
              (Evar _gObjectLists (tptr (Tstruct _ObjectNode noattr))))
            (Scall (Some _t'2)
              (Evar _update_objects_in_list (Tfunction
                                              ((tptr (Tstruct _ObjectNode noattr)) ::
                                               nil) tint cc_default))
              ((Ebinop Oadd
                 (Etempvar _t'4 (tptr (Tstruct _ObjectNode noattr)))
                 (Etempvar _listIndex tint)
                 (tptr (Tstruct _ObjectNode noattr))) :: nil)))
          (Ssequence
            (Sset _t'3 (Evar _gObjectCounter tuint))
            (Sassign (Evar _gObjectCounter tuint)
              (Ebinop Oadd (Etempvar _t'3 tuint) (Etempvar _t'2 tint) tuint))))
        (Sset _i
          (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint)
            tint))))
    Sskip))
|}.

Definition f_unload_deactivated_objects := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_filler, (tarray tuchar 4)) :: nil);
  fn_temps := ((_listIndex, tint) :: (_i, tint) :: (_t'1, tint) ::
               (_t'4, tschar) ::
               (_t'3, (tptr (Tstruct _ObjectNode noattr))) ::
               (_t'2, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _i (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sloop
      (Ssequence
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Ederef
                  (Ebinop Oadd
                    (Evar _sObjectListUpdateOrder (tarray tschar 11))
                    (Etempvar _i tint) (tptr tschar)) tschar))
              (Sset _t'1 (Ecast (Etempvar _t'4 tschar) tint)))
            (Sset _listIndex (Etempvar _t'1 tint)))
          (Sifthenelse (Ebinop One (Etempvar _t'1 tint)
                         (Eunop Oneg (Econst_int (Int.repr 1) tint) tint)
                         tint)
            Sskip
            Sbreak))
        (Ssequence
          (Ssequence
            (Sset _t'3
              (Evar _gObjectLists (tptr (Tstruct _ObjectNode noattr))))
            (Scall None
              (Evar _unload_deactivated_objects_in_list (Tfunction
                                                          ((tptr (Tstruct _ObjectNode noattr)) ::
                                                           nil) tint
                                                          cc_default))
              ((Ebinop Oadd
                 (Etempvar _t'3 (tptr (Tstruct _ObjectNode noattr)))
                 (Etempvar _listIndex tint)
                 (tptr (Tstruct _ObjectNode noattr))) :: nil)))
          (Sset _i
            (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint)
              tint))))
      Sskip)
    (Ssequence
      (Sset _t'2 (Evar _gTimeStopState tuint))
      (Sassign (Evar _gTimeStopState tuint)
        (Ebinop Oand (Etempvar _t'2 tuint)
          (Eunop Onotint
            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
              (Econst_int (Int.repr 0) tint) tint) tint) tuint)))))
|}.

Definition f_update_objects := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_unused, tint) :: nil);
  fn_vars := ((_cycleCounts, (tarray tlong 30)) :: nil);
  fn_temps := ((_t'8, tlong) :: (_t'7, tlong) :: (_t'6, tlong) ::
               (_t'5, tlong) :: (_t'4, tlong) :: (_t'3, tlong) ::
               (_t'2, tlong) :: (_t'1, tlong) :: (_t'20, tuint) ::
               (_t'19, tlong) :: (_t'18, tlong) :: (_t'17, tlong) ::
               (_t'16, tlong) :: (_t'15, tlong) :: (_t'14, tlong) ::
               (_t'13, tlong) :: (_t'12, tuint) :: (_t'11, tuint) ::
               (_t'10, tuint) :: (_t'9, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _get_current_clock (Tfunction nil tlong cc_default)) nil)
    (Sassign
      (Ederef
        (Ebinop Oadd (Evar _cycleCounts (tarray tlong 30))
          (Econst_int (Int.repr 0) tint) (tptr tlong)) tlong)
      (Etempvar _t'1 tlong)))
  (Ssequence
    (Ssequence
      (Sset _t'20 (Evar _gTimeStopState tuint))
      (Sassign (Evar _gTimeStopState tuint)
        (Ebinop Oand (Etempvar _t'20 tuint)
          (Eunop Onotint
            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
              (Econst_int (Int.repr 5) tint) tint) tint) tuint)))
    (Ssequence
      (Sassign (Evar _gNumRoomedObjectsInMarioRoom tshort)
        (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Sassign (Evar _gNumRoomedObjectsNotInMarioRoom tshort)
          (Econst_int (Int.repr 0) tint))
        (Ssequence
          (Sassign (Evar _gCheckingSurfaceCollisionsForCamera tshort)
            (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Scall None
              (Evar _reset_debug_objectinfo (Tfunction nil tvoid cc_default))
              nil)
            (Ssequence
              (Scall None
                (Evar _stub_debug_5 (Tfunction nil tvoid cc_default)) nil)
              (Ssequence
                (Sassign
                  (Evar _gObjectLists (tptr (Tstruct _ObjectNode noattr)))
                  (Evar _gObjectListArray (tarray (Tstruct _ObjectNode noattr) 16)))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'19
                        (Ederef
                          (Ebinop Oadd (Evar _cycleCounts (tarray tlong 30))
                            (Econst_int (Int.repr 0) tint) (tptr tlong))
                          tlong))
                      (Scall (Some _t'2)
                        (Evar _get_clock_difference (Tfunction (tlong :: nil)
                                                      tlong cc_default))
                        ((Etempvar _t'19 tlong) :: nil)))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd (Evar _cycleCounts (tarray tlong 30))
                          (Econst_int (Int.repr 1) tint) (tptr tlong)) tlong)
                      (Etempvar _t'2 tlong)))
                  (Ssequence
                    (Scall None
                      (Evar _clear_dynamic_surfaces (Tfunction nil tvoid
                                                      cc_default)) nil)
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'18
                            (Ederef
                              (Ebinop Oadd
                                (Evar _cycleCounts (tarray tlong 30))
                                (Econst_int (Int.repr 0) tint) (tptr tlong))
                              tlong))
                          (Scall (Some _t'3)
                            (Evar _get_clock_difference (Tfunction
                                                          (tlong :: nil)
                                                          tlong cc_default))
                            ((Etempvar _t'18 tlong) :: nil)))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Evar _cycleCounts (tarray tlong 30))
                              (Econst_int (Int.repr 2) tint) (tptr tlong))
                            tlong) (Etempvar _t'3 tlong)))
                      (Ssequence
                        (Scall None
                          (Evar _update_terrain_objects (Tfunction nil tvoid
                                                          cc_default)) nil)
                        (Ssequence
                          (Scall None
                            (Evar _apply_mario_platform_displacement 
                            (Tfunction nil tvoid cc_default)) nil)
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Sset _t'17
                                  (Ederef
                                    (Ebinop Oadd
                                      (Evar _cycleCounts (tarray tlong 30))
                                      (Econst_int (Int.repr 0) tint)
                                      (tptr tlong)) tlong))
                                (Scall (Some _t'4)
                                  (Evar _get_clock_difference (Tfunction
                                                                (tlong ::
                                                                 nil) tlong
                                                                cc_default))
                                  ((Etempvar _t'17 tlong) :: nil)))
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _cycleCounts (tarray tlong 30))
                                    (Econst_int (Int.repr 3) tint)
                                    (tptr tlong)) tlong)
                                (Etempvar _t'4 tlong)))
                            (Ssequence
                              (Scall None
                                (Evar _detect_object_collisions (Tfunction
                                                                  nil tvoid
                                                                  cc_default))
                                nil)
                              (Ssequence
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'16
                                      (Ederef
                                        (Ebinop Oadd
                                          (Evar _cycleCounts (tarray tlong 30))
                                          (Econst_int (Int.repr 0) tint)
                                          (tptr tlong)) tlong))
                                    (Scall (Some _t'5)
                                      (Evar _get_clock_difference (Tfunction
                                                                    (tlong ::
                                                                    nil)
                                                                    tlong
                                                                    cc_default))
                                      ((Etempvar _t'16 tlong) :: nil)))
                                  (Sassign
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _cycleCounts (tarray tlong 30))
                                        (Econst_int (Int.repr 4) tint)
                                        (tptr tlong)) tlong)
                                    (Etempvar _t'5 tlong)))
                                (Ssequence
                                  (Scall None
                                    (Evar _update_non_terrain_objects 
                                    (Tfunction nil tvoid cc_default)) nil)
                                  (Ssequence
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'15
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _cycleCounts (tarray tlong 30))
                                              (Econst_int (Int.repr 0) tint)
                                              (tptr tlong)) tlong))
                                        (Scall (Some _t'6)
                                          (Evar _get_clock_difference 
                                          (Tfunction (tlong :: nil) tlong
                                            cc_default))
                                          ((Etempvar _t'15 tlong) :: nil)))
                                      (Sassign
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _cycleCounts (tarray tlong 30))
                                            (Econst_int (Int.repr 5) tint)
                                            (tptr tlong)) tlong)
                                        (Etempvar _t'6 tlong)))
                                    (Ssequence
                                      (Scall None
                                        (Evar _unload_deactivated_objects 
                                        (Tfunction nil tvoid cc_default))
                                        nil)
                                      (Ssequence
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'14
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _cycleCounts (tarray tlong 30))
                                                  (Econst_int (Int.repr 0) tint)
                                                  (tptr tlong)) tlong))
                                            (Scall (Some _t'7)
                                              (Evar _get_clock_difference 
                                              (Tfunction (tlong :: nil) tlong
                                                cc_default))
                                              ((Etempvar _t'14 tlong) :: nil)))
                                          (Sassign
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _cycleCounts (tarray tlong 30))
                                                (Econst_int (Int.repr 6) tint)
                                                (tptr tlong)) tlong)
                                            (Etempvar _t'7 tlong)))
                                        (Ssequence
                                          (Scall None
                                            (Evar _update_mario_platform 
                                            (Tfunction nil tvoid cc_default))
                                            nil)
                                          (Ssequence
                                            (Ssequence
                                              (Ssequence
                                                (Sset _t'13
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Evar _cycleCounts (tarray tlong 30))
                                                      (Econst_int (Int.repr 0) tint)
                                                      (tptr tlong)) tlong))
                                                (Scall (Some _t'8)
                                                  (Evar _get_clock_difference 
                                                  (Tfunction (tlong :: nil)
                                                    tlong cc_default))
                                                  ((Etempvar _t'13 tlong) ::
                                                   nil)))
                                              (Sassign
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Evar _cycleCounts (tarray tlong 30))
                                                    (Econst_int (Int.repr 7) tint)
                                                    (tptr tlong)) tlong)
                                                (Etempvar _t'8 tlong)))
                                            (Ssequence
                                              (Sassign
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Evar _cycleCounts (tarray tlong 30))
                                                    (Econst_int (Int.repr 0) tint)
                                                    (tptr tlong)) tlong)
                                                (Econst_int (Int.repr 0) tint))
                                              (Ssequence
                                                (Scall None
                                                  (Evar _try_print_debug_mario_object_info 
                                                  (Tfunction nil tvoid
                                                    cc_default)) nil)
                                                (Ssequence
                                                  (Ssequence
                                                    (Sset _t'10
                                                      (Evar _gTimeStopState tuint))
                                                    (Sifthenelse (Ebinop Oand
                                                                   (Etempvar _t'10 tuint)
                                                                   (Ebinop Oshl
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                   tuint)
                                                      (Ssequence
                                                        (Sset _t'12
                                                          (Evar _gTimeStopState tuint))
                                                        (Sassign
                                                          (Evar _gTimeStopState tuint)
                                                          (Ebinop Oor
                                                            (Etempvar _t'12 tuint)
                                                            (Ebinop Oshl
                                                              (Econst_int (Int.repr 1) tint)
                                                              (Econst_int (Int.repr 6) tint)
                                                              tint) tuint)))
                                                      (Ssequence
                                                        (Sset _t'11
                                                          (Evar _gTimeStopState tuint))
                                                        (Sassign
                                                          (Evar _gTimeStopState tuint)
                                                          (Ebinop Oand
                                                            (Etempvar _t'11 tuint)
                                                            (Eunop Onotint
                                                              (Ebinop Oshl
                                                                (Econst_int (Int.repr 1) tint)
                                                                (Econst_int (Int.repr 6) tint)
                                                                tint) tint)
                                                            tuint)))))
                                                  (Ssequence
                                                    (Sset _t'9
                                                      (Evar _gObjectCounter tuint))
                                                    (Sassign
                                                      (Evar _gPrevFrameObjectCount tshort)
                                                      (Etempvar _t'9 tuint))))))))))))))))))))))))))))
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
 Composite _ChainSegment Struct
   (Member_plain _posX tfloat :: Member_plain _posY tfloat ::
    Member_plain _posZ tfloat :: Member_plain _pitch tshort ::
    Member_plain _yaw tshort :: Member_plain _roll tshort :: nil)
   noattr ::
 Composite _NumTimesCalled Struct
   (Member_plain _floor tshort :: Member_plain _ceil tshort ::
    Member_plain _wall tshort :: nil)
   noattr ::
 Composite _ParticleProperties Struct
   (Member_plain _particleFlag tuint ::
    Member_plain _activeParticleFlag tuint :: Member_plain _model tuchar ::
    Member_plain _behavior (tptr tuint) :: nil)
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
 (_mem_pool_init,
   Gfun(External (EF_external "mem_pool_init"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xptr
                     cc_default)) (tuint :: tuint :: nil)
     (tptr (Tstruct _MemoryPool noattr)) cc_default)) ::
 (_geo_make_first_child,
   Gfun(External (EF_external "geo_make_first_child"
                   (mksignature (AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr (Tstruct _GraphNode noattr)) :: nil)
     (tptr (Tstruct _GraphNode noattr)) cc_default)) ::
 (_geo_reset_object_node,
   Gfun(External (EF_external "geo_reset_object_node"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _GraphNodeObject noattr)) :: nil) tvoid cc_default)) ::
 (_geo_obj_init_spawninfo,
   Gfun(External (EF_external "geo_obj_init_spawninfo"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _GraphNodeObject noattr)) ::
      (tptr (Tstruct _SpawnInfo noattr)) :: nil) tvoid cc_default)) ::
 (_gCurrAreaIndex, Gvar v_gCurrAreaIndex) ::
 (_bhvBubbleParticleSpawner, Gvar v_bhvBubbleParticleSpawner) ::
 (_bhvPlungeBubble, Gvar v_bhvPlungeBubble) ::
 (_bhvVertStarParticleSpawner, Gvar v_bhvVertStarParticleSpawner) ::
 (_bhvHorStarParticleSpawner, Gvar v_bhvHorStarParticleSpawner) ::
 (_bhvTriangleParticleSpawner, Gvar v_bhvTriangleParticleSpawner) ::
 (_bhvBreathParticleSpawner, Gvar v_bhvBreathParticleSpawner) ::
 (_bhvMistCircParticleSpawner, Gvar v_bhvMistCircParticleSpawner) ::
 (_bhvDirtParticleSpawner, Gvar v_bhvDirtParticleSpawner) ::
 (_bhvSnowParticleSpawner, Gvar v_bhvSnowParticleSpawner) ::
 (_bhvFireParticleSpawner, Gvar v_bhvFireParticleSpawner) ::
 (_bhvLeafParticleSpawner, Gvar v_bhvLeafParticleSpawner) ::
 (_bhvMistParticleSpawner, Gvar v_bhvMistParticleSpawner) ::
 (_bhvSparkleParticleSpawner, Gvar v_bhvSparkleParticleSpawner) ::
 (_bhvWaterSplash, Gvar v_bhvWaterSplash) ::
 (_bhvIdleWaterWave, Gvar v_bhvIdleWaterWave) ::
 (_bhvShallowWaterWave, Gvar v_bhvShallowWaterWave) ::
 (_bhvShallowWaterSplash, Gvar v_bhvShallowWaterSplash) ::
 (_bhvWaveTrail, Gvar v_bhvWaveTrail) ::
 (_get_current_clock,
   Gfun(External (EF_external "get_current_clock"
                   (mksignature nil AST.Xlong cc_default)) nil tlong
     cc_default)) ::
 (_get_clock_difference,
   Gfun(External (EF_external "get_clock_difference"
                   (mksignature (AST.Xlong :: nil) AST.Xlong cc_default))
     (tlong :: nil) tlong cc_default)) ::
 (_debug_unknown_level_select_check,
   Gfun(External (EF_external "debug_unknown_level_select_check"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_reset_debug_objectinfo,
   Gfun(External (EF_external "reset_debug_objectinfo"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_stub_debug_5,
   Gfun(External (EF_external "stub_debug_5"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_try_print_debug_mario_object_info,
   Gfun(External (EF_external "try_print_debug_mario_object_info"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_stub_behavior_script_2,
   Gfun(External (EF_external "stub_behavior_script_2"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_cur_obj_update,
   Gfun(External (EF_external "cur_obj_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_clear_dynamic_surfaces,
   Gfun(External (EF_external "clear_dynamic_surfaces"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) :: (_gMarioStates, Gvar v_gMarioStates) ::
 (_execute_mario_action,
   Gfun(External (EF_external "execute_mario_action"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _Object noattr)) :: nil) tint cc_default)) ::
 (_detect_object_collisions,
   Gfun(External (EF_external "detect_object_collisions"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_spawn_object_at_origin,
   Gfun(External (EF_external "spawn_object_at_origin"
                   (mksignature
                     (AST.Xptr :: AST.Xint :: AST.Xint :: AST.Xptr :: nil)
                     AST.Xptr cc_default))
     ((tptr (Tstruct _Object noattr)) :: tint :: tuint :: (tptr tuint) ::
      nil) (tptr (Tstruct _Object noattr)) cc_default)) ::
 (_obj_copy_pos_and_angle,
   Gfun(External (EF_external "obj_copy_pos_and_angle"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _Object noattr)) :: (tptr (Tstruct _Object noattr)) ::
      nil) tvoid cc_default)) ::
 (_update_mario_platform,
   Gfun(External (EF_external "update_mario_platform"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_apply_mario_platform_displacement,
   Gfun(External (EF_external "apply_mario_platform_displacement"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_clear_mario_platform,
   Gfun(External (EF_external "clear_mario_platform"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_init_free_object_list,
   Gfun(External (EF_external "init_free_object_list"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_clear_object_lists,
   Gfun(External (EF_external "clear_object_lists"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _ObjectNode noattr)) :: nil) tvoid cc_default)) ::
 (_unload_object,
   Gfun(External (EF_external "unload_object"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _Object noattr)) :: nil) tvoid cc_default)) ::
 (_create_object,
   Gfun(External (EF_external "create_object"
                   (mksignature (AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr tuint) :: nil) (tptr (Tstruct _Object noattr)) cc_default)) ::
 (_gDebugInfoFlags, Gvar v_gDebugInfoFlags) ::
 (_gNumFindFloorMisses, Gvar v_gNumFindFloorMisses) ::
 (_unused_8033BEF8, Gvar v_unused_8033BEF8) ::
 (_gUnknownWallCount, Gvar v_gUnknownWallCount) ::
 (_gObjectCounter, Gvar v_gObjectCounter) ::
 (_gNumCalls, Gvar v_gNumCalls) :: (_gDebugInfo, Gvar v_gDebugInfo) ::
 (_gDebugInfoOverwrite, Gvar v_gDebugInfoOverwrite) ::
 (_gTimeStopState, Gvar v_gTimeStopState) ::
 (_gObjectPool, Gvar v_gObjectPool) ::
 (_gMacroObjectDefaultParent, Gvar v_gMacroObjectDefaultParent) ::
 (_gObjectLists, Gvar v_gObjectLists) ::
 (_gFreeObjectList, Gvar v_gFreeObjectList) ::
 (_gMarioObject, Gvar v_gMarioObject) ::
 (_gLuigiObject, Gvar v_gLuigiObject) ::
 (_gCurrentObject, Gvar v_gCurrentObject) ::
 (_gCurBhvCommand, Gvar v_gCurBhvCommand) ::
 (_gPrevFrameObjectCount, Gvar v_gPrevFrameObjectCount) ::
 (_gSurfaceNodesAllocated, Gvar v_gSurfaceNodesAllocated) ::
 (_gSurfacesAllocated, Gvar v_gSurfacesAllocated) ::
 (_gNumStaticSurfaceNodes, Gvar v_gNumStaticSurfaceNodes) ::
 (_gNumStaticSurfaces, Gvar v_gNumStaticSurfaces) ::
 (_gObjectMemoryPool, Gvar v_gObjectMemoryPool) ::
 (_gCheckingSurfaceCollisionsForCamera, Gvar v_gCheckingSurfaceCollisionsForCamera) ::
 (_gFindFloorIncludeSurfaceIntangible, Gvar v_gFindFloorIncludeSurfaceIntangible) ::
 (_gEnvironmentRegions, Gvar v_gEnvironmentRegions) ::
 (_gEnvironmentLevels, Gvar v_gEnvironmentLevels) ::
 (_gDoorAdjacentRooms, Gvar v_gDoorAdjacentRooms) ::
 (_gMarioCurrentRoom, Gvar v_gMarioCurrentRoom) ::
 (_D_8035FEE2, Gvar v_D_8035FEE2) :: (_D_8035FEE4, Gvar v_D_8035FEE4) ::
 (_gTHIWaterDrained, Gvar v_gTHIWaterDrained) ::
 (_gTTCSpeedSetting, Gvar v_gTTCSpeedSetting) ::
 (_gMarioShotFromCannon, Gvar v_gMarioShotFromCannon) ::
 (_gCCMEnteredSlide, Gvar v_gCCMEnteredSlide) ::
 (_gNumRoomedObjectsInMarioRoom, Gvar v_gNumRoomedObjectsInMarioRoom) ::
 (_gNumRoomedObjectsNotInMarioRoom, Gvar v_gNumRoomedObjectsNotInMarioRoom) ::
 (_gWDWWaterLevelChanging, Gvar v_gWDWWaterLevelChanging) ::
 (_gMarioOnMerryGoRound, Gvar v_gMarioOnMerryGoRound) ::
 (_gObjectListArray, Gvar v_gObjectListArray) ::
 (_sObjectListUpdateOrder, Gvar v_sObjectListUpdateOrder) ::
 (_sParticleTypes, Gvar v_sParticleTypes) ::
 (_copy_mario_state_to_object, Gfun(Internal f_copy_mario_state_to_object)) ::
 (_spawn_particle, Gfun(Internal f_spawn_particle)) ::
 (_bhv_mario_update, Gfun(Internal f_bhv_mario_update)) ::
 (_update_objects_starting_at, Gfun(Internal f_update_objects_starting_at)) ::
 (_update_objects_during_time_stop, Gfun(Internal f_update_objects_during_time_stop)) ::
 (_update_objects_in_list, Gfun(Internal f_update_objects_in_list)) ::
 (_unload_deactivated_objects_in_list, Gfun(Internal f_unload_deactivated_objects_in_list)) ::
 (_set_object_respawn_info_bits, Gfun(Internal f_set_object_respawn_info_bits)) ::
 (_unload_objects_from_area, Gfun(Internal f_unload_objects_from_area)) ::
 (_spawn_objects_from_info, Gfun(Internal f_spawn_objects_from_info)) ::
 (_stub_obj_list_processor_1, Gfun(Internal f_stub_obj_list_processor_1)) ::
 (_clear_objects, Gfun(Internal f_clear_objects)) ::
 (_update_terrain_objects, Gfun(Internal f_update_terrain_objects)) ::
 (_update_non_terrain_objects, Gfun(Internal f_update_non_terrain_objects)) ::
 (_unload_deactivated_objects, Gfun(Internal f_unload_deactivated_objects)) ::
 (_update_objects, Gfun(Internal f_update_objects)) :: nil).

Definition public_idents : list ident :=
(_update_objects :: _unload_deactivated_objects ::
 _update_non_terrain_objects :: _update_terrain_objects :: _clear_objects ::
 _stub_obj_list_processor_1 :: _spawn_objects_from_info ::
 _unload_objects_from_area :: _set_object_respawn_info_bits ::
 _unload_deactivated_objects_in_list :: _update_objects_in_list ::
 _update_objects_during_time_stop :: _update_objects_starting_at ::
 _bhv_mario_update :: _spawn_particle :: _copy_mario_state_to_object ::
 _sParticleTypes :: _sObjectListUpdateOrder :: _gObjectListArray ::
 _gMarioOnMerryGoRound :: _gWDWWaterLevelChanging ::
 _gNumRoomedObjectsNotInMarioRoom :: _gNumRoomedObjectsInMarioRoom ::
 _gCCMEnteredSlide :: _gMarioShotFromCannon :: _gTTCSpeedSetting ::
 _gTHIWaterDrained :: _D_8035FEE4 :: _D_8035FEE2 :: _gMarioCurrentRoom ::
 _gDoorAdjacentRooms :: _gEnvironmentLevels :: _gEnvironmentRegions ::
 _gFindFloorIncludeSurfaceIntangible ::
 _gCheckingSurfaceCollisionsForCamera :: _gObjectMemoryPool ::
 _gNumStaticSurfaces :: _gNumStaticSurfaceNodes :: _gSurfacesAllocated ::
 _gSurfaceNodesAllocated :: _gPrevFrameObjectCount :: _gCurBhvCommand ::
 _gCurrentObject :: _gLuigiObject :: _gMarioObject :: _gFreeObjectList ::
 _gObjectLists :: _gMacroObjectDefaultParent :: _gObjectPool ::
 _gTimeStopState :: _gDebugInfoOverwrite :: _gDebugInfo :: _gNumCalls ::
 _gObjectCounter :: _gUnknownWallCount :: _unused_8033BEF8 ::
 _gNumFindFloorMisses :: _gDebugInfoFlags :: _create_object ::
 _unload_object :: _clear_object_lists :: _init_free_object_list ::
 _clear_mario_platform :: _apply_mario_platform_displacement ::
 _update_mario_platform :: _obj_copy_pos_and_angle ::
 _spawn_object_at_origin :: _detect_object_collisions ::
 _execute_mario_action :: _gMarioStates :: _clear_dynamic_surfaces ::
 _cur_obj_update :: _stub_behavior_script_2 ::
 _try_print_debug_mario_object_info :: _stub_debug_5 ::
 _reset_debug_objectinfo :: _debug_unknown_level_select_check ::
 _get_clock_difference :: _get_current_clock :: _bhvWaveTrail ::
 _bhvShallowWaterSplash :: _bhvShallowWaterWave :: _bhvIdleWaterWave ::
 _bhvWaterSplash :: _bhvSparkleParticleSpawner :: _bhvMistParticleSpawner ::
 _bhvLeafParticleSpawner :: _bhvFireParticleSpawner ::
 _bhvSnowParticleSpawner :: _bhvDirtParticleSpawner ::
 _bhvMistCircParticleSpawner :: _bhvBreathParticleSpawner ::
 _bhvTriangleParticleSpawner :: _bhvHorStarParticleSpawner ::
 _bhvVertStarParticleSpawner :: _bhvPlungeBubble ::
 _bhvBubbleParticleSpawner :: _gCurrAreaIndex :: _geo_obj_init_spawninfo ::
 _geo_reset_object_node :: _geo_make_first_child :: _mem_pool_init ::
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


