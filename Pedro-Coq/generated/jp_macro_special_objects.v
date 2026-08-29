(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_JP
   Source:          src/game/macro_special_objects.c
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_JP=1 -DF3D_OLD=1
   Link hygiene:    private __stringlit_N atoms prefixed with jp_macro_special_objects
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
  Definition source_file := "build/pinned-sm64/src/game/macro_special_objects.c".
  Definition normalized := true.
End Info.

Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _GraphNode : ident := $"GraphNode".
Definition _GraphNodeObject : ident := $"GraphNodeObject".
Definition _LoadedPreset : ident := $"LoadedPreset".
Definition _MacroPreset : ident := $"MacroPreset".
Definition _Object : ident := $"Object".
Definition _ObjectNode : ident := $"ObjectNode".
Definition _SpawnInfo : ident := $"SpawnInfo".
Definition _SpecialPreset : ident := $"SpecialPreset".
Definition _Surface : ident := $"Surface".
Definition _Waypoint : ident := $"Waypoint".
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
Definition _bhv1Up : ident := $"bhv1Up".
Definition _bhv1UpJumpOnApproach : ident := $"bhv1UpJumpOnApproach".
Definition _bhv1UpSliding : ident := $"bhv1UpSliding".
Definition _bhvActivatedBackAndForthPlatform : ident := $"bhvActivatedBackAndForthPlatform".
Definition _bhvAlphaBooKey : ident := $"bhvAlphaBooKey".
Definition _bhvAnimatesOnFloorSwitchPress : ident := $"bhvAnimatesOnFloorSwitchPress".
Definition _bhvAnotherTiltingPlatform : ident := $"bhvAnotherTiltingPlatform".
Definition _bhvBBHTiltingTrapPlatform : ident := $"bhvBBHTiltingTrapPlatform".
Definition _bhvBBHTumblingBridge : ident := $"bhvBBHTumblingBridge".
Definition _bhvBetaChestBottom : ident := $"bhvBetaChestBottom".
Definition _bhvBetaFishSplashSpawner : ident := $"bhvBetaFishSplashSpawner".
Definition _bhvBetaTrampolineTop : ident := $"bhvBetaTrampolineTop".
Definition _bhvBigBully : ident := $"bhvBigBully".
Definition _bhvBlueCoinSliding : ident := $"bhvBlueCoinSliding".
Definition _bhvBlueCoinSwitch : ident := $"bhvBlueCoinSwitch".
Definition _bhvBobomb : ident := $"bhvBobomb".
Definition _bhvBobombBuddyOpensCannon : ident := $"bhvBobombBuddyOpensCannon".
Definition _bhvBooStaircase : ident := $"bhvBooStaircase".
Definition _bhvBooWithCage : ident := $"bhvBooWithCage".
Definition _bhvBouncingFireball : ident := $"bhvBouncingFireball".
Definition _bhvBowser : ident := $"bhvBowser".
Definition _bhvBowserBomb : ident := $"bhvBowserBomb".
Definition _bhvBreakableBox : ident := $"bhvBreakableBox".
Definition _bhvBreakableBoxSmall : ident := $"bhvBreakableBoxSmall".
Definition _bhvBulletBill : ident := $"bhvBulletBill".
Definition _bhvButterfly : ident := $"bhvButterfly".
Definition _bhvCannon : ident := $"bhvCannon".
Definition _bhvCannonClosed : ident := $"bhvCannonClosed".
Definition _bhvCapSwitch : ident := $"bhvCapSwitch".
Definition _bhvCarrySomething1 : ident := $"bhvCarrySomething1".
Definition _bhvCastleFloorTrap : ident := $"bhvCastleFloorTrap".
Definition _bhvChainChomp : ident := $"bhvChainChomp".
Definition _bhvChirpChirp : ident := $"bhvChirpChirp".
Definition _bhvChuckya : ident := $"bhvChuckya".
Definition _bhvCirclingAmp : ident := $"bhvCirclingAmp".
Definition _bhvClamShell : ident := $"bhvClamShell".
Definition _bhvCoinFormation : ident := $"bhvCoinFormation".
Definition _bhvCourtyardBooTriplet : ident := $"bhvCourtyardBooTriplet".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvDoor : ident := $"bhvDoor".
Definition _bhvDoorWarp : ident := $"bhvDoorWarp".
Definition _bhvEnemyLakitu : ident := $"bhvEnemyLakitu".
Definition _bhvExclamationBox : ident := $"bhvExclamationBox".
Definition _bhvFerrisWheelAxle : ident := $"bhvFerrisWheelAxle".
Definition _bhvFirePiranhaPlant : ident := $"bhvFirePiranhaPlant".
Definition _bhvFireSpitter : ident := $"bhvFireSpitter".
Definition _bhvFishSpawner : ident := $"bhvFishSpawner".
Definition _bhvFlamethrower : ident := $"bhvFlamethrower".
Definition _bhvFloorSwitchHiddenObjects : ident := $"bhvFloorSwitchHiddenObjects".
Definition _bhvFlyGuy : ident := $"bhvFlyGuy".
Definition _bhvFreeBowlingBall : ident := $"bhvFreeBowlingBall".
Definition _bhvGhostHuntBoo : ident := $"bhvGhostHuntBoo".
Definition _bhvGoomba : ident := $"bhvGoomba".
Definition _bhvGoombaTripletSpawner : ident := $"bhvGoombaTripletSpawner".
Definition _bhvHauntedBookshelf : ident := $"bhvHauntedBookshelf".
Definition _bhvHauntedChair : ident := $"bhvHauntedChair".
Definition _bhvHeaveHo : ident := $"bhvHeaveHo".
Definition _bhvHidden1Up : ident := $"bhvHidden1Up".
Definition _bhvHidden1UpInPoleSpawner : ident := $"bhvHidden1UpInPoleSpawner".
Definition _bhvHidden1UpTrigger : ident := $"bhvHidden1UpTrigger".
Definition _bhvHiddenBlueCoin : ident := $"bhvHiddenBlueCoin".
Definition _bhvHiddenObject : ident := $"bhvHiddenObject".
Definition _bhvHiddenStarTrigger : ident := $"bhvHiddenStarTrigger".
Definition _bhvHomingAmp : ident := $"bhvHomingAmp".
Definition _bhvJetStreamRingSpawner : ident := $"bhvJetStreamRingSpawner".
Definition _bhvJumpingBox : ident := $"bhvJumpingBox".
Definition _bhvKoopa : ident := $"bhvKoopa".
Definition _bhvKoopaRaceEndpoint : ident := $"bhvKoopaRaceEndpoint".
Definition _bhvKoopaShellUnderwater : ident := $"bhvKoopaShellUnderwater".
Definition _bhvLLLBowserPuzzle : ident := $"bhvLLLBowserPuzzle".
Definition _bhvLLLDrawbridgeSpawner : ident := $"bhvLLLDrawbridgeSpawner".
Definition _bhvLLLFloatingWoodBridge : ident := $"bhvLLLFloatingWoodBridge".
Definition _bhvLLLMovingOctagonalMeshPlatform : ident := $"bhvLLLMovingOctagonalMeshPlatform".
Definition _bhvLLLRotatingBlockWithFireBars : ident := $"bhvLLLRotatingBlockWithFireBars".
Definition _bhvLLLRotatingHexagonalRing : ident := $"bhvLLLRotatingHexagonalRing".
Definition _bhvLLLSinkingRectangularPlatform : ident := $"bhvLLLSinkingRectangularPlatform".
Definition _bhvLLLSinkingSquarePlatforms : ident := $"bhvLLLSinkingSquarePlatforms".
Definition _bhvLLLTiltingInvertedPyramid : ident := $"bhvLLLTiltingInvertedPyramid".
Definition _bhvLLLTumblingBridge : ident := $"bhvLLLTumblingBridge".
Definition _bhvLargeBomp : ident := $"bhvLargeBomp".
Definition _bhvMacroUkiki : ident := $"bhvMacroUkiki".
Definition _bhvMeshElevator : ident := $"bhvMeshElevator".
Definition _bhvMessagePanel : ident := $"bhvMessagePanel".
Definition _bhvMoneybagHidden : ident := $"bhvMoneybagHidden".
Definition _bhvMontyMole : ident := $"bhvMontyMole".
Definition _bhvMontyMoleHole : ident := $"bhvMontyMoleHole".
Definition _bhvMovingBlueCoin : ident := $"bhvMovingBlueCoin".
Definition _bhvMrBlizzard : ident := $"bhvMrBlizzard".
Definition _bhvMrI : ident := $"bhvMrI".
Definition _bhvOctagonalPlatformRotating : ident := $"bhvOctagonalPlatformRotating".
Definition _bhvOneCoin : ident := $"bhvOneCoin".
Definition _bhvPiranhaPlant : ident := $"bhvPiranhaPlant".
Definition _bhvPokey : ident := $"bhvPokey".
Definition _bhvPushableMetalBox : ident := $"bhvPushableMetalBox".
Definition _bhvRecoveryHeart : ident := $"bhvRecoveryHeart".
Definition _bhvRedCoin : ident := $"bhvRedCoin".
Definition _bhvRotatingCounterClockwise : ident := $"bhvRotatingCounterClockwise".
Definition _bhvScuttlebug : ident := $"bhvScuttlebug".
Definition _bhvScuttlebugSpawn : ident := $"bhvScuttlebugSpawn".
Definition _bhvSeaweedBundle : ident := $"bhvSeaweedBundle".
Definition _bhvSeesawPlatform : ident := $"bhvSeesawPlatform".
Definition _bhvSignOnWall : ident := $"bhvSignOnWall".
Definition _bhvSkeeter : ident := $"bhvSkeeter".
Definition _bhvSlidingPlatform2 : ident := $"bhvSlidingPlatform2".
Definition _bhvSmallBomp : ident := $"bhvSmallBomp".
Definition _bhvSmallBully : ident := $"bhvSmallBully".
Definition _bhvSmallPenguin : ident := $"bhvSmallPenguin".
Definition _bhvSmallWhomp : ident := $"bhvSmallWhomp".
Definition _bhvSnowBall : ident := $"bhvSnowBall".
Definition _bhvSnufit : ident := $"bhvSnufit".
Definition _bhvSpindrift : ident := $"bhvSpindrift".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _bhvStaticObject : ident := $"bhvStaticObject".
Definition _bhvStub1D0C : ident := $"bhvStub1D0C".
Definition _bhvSushiShark : ident := $"bhvSushiShark".
Definition _bhvSwoop : ident := $"bhvSwoop".
Definition _bhvTTC2DRotator : ident := $"bhvTTC2DRotator".
Definition _bhvTTCCog : ident := $"bhvTTCCog".
Definition _bhvTTCElevator : ident := $"bhvTTCElevator".
Definition _bhvTTCMovingBar : ident := $"bhvTTCMovingBar".
Definition _bhvTTCPendulum : ident := $"bhvTTCPendulum".
Definition _bhvTTCPitBlock : ident := $"bhvTTCPitBlock".
Definition _bhvTTCRotatingSolid : ident := $"bhvTTCRotatingSolid".
Definition _bhvTTCSpinner : ident := $"bhvTTCSpinner".
Definition _bhvTTCTreadmill : ident := $"bhvTTCTreadmill".
Definition _bhvThwomp : ident := $"bhvThwomp".
Definition _bhvTowerPlatformGroup : ident := $"bhvTowerPlatformGroup".
Definition _bhvToxBox : ident := $"bhvToxBox".
Definition _bhvTree : ident := $"bhvTree".
Definition _bhvTripletButterfly : ident := $"bhvTripletButterfly".
Definition _bhvTumblingBridge : ident := $"bhvTumblingBridge".
Definition _bhvTuxiesMother : ident := $"bhvTuxiesMother".
Definition _bhvTweester : ident := $"bhvTweester".
Definition _bhvUnagi : ident := $"bhvUnagi".
Definition _bhvUnusedFakeStar : ident := $"bhvUnusedFakeStar".
Definition _bhvWFRotatingWoodenPlatform : ident := $"bhvWFRotatingWoodenPlatform".
Definition _bhvWFSlidingPlatform : ident := $"bhvWFSlidingPlatform".
Definition _bhvWaterBombCannon : ident := $"bhvWaterBombCannon".
Definition _bhvWaterBombSpawner : ident := $"bhvWaterBombSpawner".
Definition _bhvWaterLevelDiamond : ident := $"bhvWaterLevelDiamond".
Definition _bhvWigglerHead : ident := $"bhvWigglerHead".
Definition _bhvWoodenPost : ident := $"bhvWoodenPost".
Definition _bhvYellowCoin : ident := $"bhvYellowCoin".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _children : ident := $"children".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _convert_rotation : ident := $"convert_rotation".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _defParam : ident := $"defParam".
Definition _defaultParam : ident := $"defaultParam".
Definition _extraParams : ident := $"extraParams".
Definition _filler : ident := $"filler".
Definition _filler1 : ident := $"filler1".
Definition _filler2 : ident := $"filler2".
Definition _flags : ident := $"flags".
Definition _force : ident := $"force".
Definition _gMacroObjectDefaultParent : ident := $"gMacroObjectDefaultParent".
Definition _gfx : ident := $"gfx".
Definition _header : ident := $"header".
Definition _hitboxDownOffset : ident := $"hitboxDownOffset".
Definition _hitboxHeight : ident := $"hitboxHeight".
Definition _hitboxRadius : ident := $"hitboxRadius".
Definition _hurtboxHeight : ident := $"hurtboxHeight".
Definition _hurtboxRadius : ident := $"hurtboxRadius".
Definition _i : ident := $"i".
Definition _inRotation : ident := $"inRotation".
Definition _index : ident := $"index".
Definition _length : ident := $"length".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _macroObjList : ident := $"macroObjList".
Definition _macroObjPreset : ident := $"macroObjPreset".
Definition _macroObjRY : ident := $"macroObjRY".
Definition _macroObjX : ident := $"macroObjX".
Definition _macroObjY : ident := $"macroObjY".
Definition _macroObjZ : ident := $"macroObjZ".
Definition _macroObject : ident := $"macroObject".
Definition _main : ident := $"main".
Definition _model : ident := $"model".
Definition _newObj : ident := $"newObj".
Definition _next : ident := $"next".
Definition _node : ident := $"node".
Definition _normal : ident := $"normal".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _numOfSpecialObjects : ident := $"numOfSpecialObjects".
Definition _object : ident := $"object".
Definition _offset : ident := $"offset".
Definition _originOffset : ident := $"originOffset".
Definition _param : ident := $"param".
Definition _params : ident := $"params".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _pitch : ident := $"pitch".
Definition _platform : ident := $"platform".
Definition _pos : ident := $"pos".
Definition _posX : ident := $"posX".
Definition _posY : ident := $"posY".
Definition _posZ : ident := $"posZ".
Definition _preset : ident := $"preset".
Definition _presetID : ident := $"presetID".
Definition _prev : ident := $"prev".
Definition _prevObj : ident := $"prevObj".
Definition _rawData : ident := $"rawData".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _roll : ident := $"roll".
Definition _room : ident := $"room".
Definition _rotation : ident := $"rotation".
Definition _ry : ident := $"ry".
Definition _sMacroObjectPresets : ident := $"sMacroObjectPresets".
Definition _sSpecialObjectPresets : ident := $"sSpecialObjectPresets".
Definition _scale : ident := $"scale".
Definition _sharedChild : ident := $"sharedChild".
Definition _spawn_macro_abs_special : ident := $"spawn_macro_abs_special".
Definition _spawn_macro_abs_yrot_2params : ident := $"spawn_macro_abs_yrot_2params".
Definition _spawn_macro_abs_yrot_param1 : ident := $"spawn_macro_abs_yrot_param1".
Definition _spawn_macro_objects : ident := $"spawn_macro_objects".
Definition _spawn_macro_objects_hardcoded : ident := $"spawn_macro_objects_hardcoded".
Definition _spawn_object_abs_with_rot : ident := $"spawn_object_abs_with_rot".
Definition _spawn_special_objects : ident := $"spawn_special_objects".
Definition _specialObjList : ident := $"specialObjList".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _transform : ident := $"transform".
Definition _type : ident := $"type".
Definition _unk4C : ident := $"unk4C".
Definition _unkA : ident := $"unkA".
Definition _unkB : ident := $"unkB".
Definition _unkC : ident := $"unkC".
Definition _unused1 : ident := $"unused1".
Definition _unused2 : ident := $"unused2".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _upperY : ident := $"upperY".
Definition _values : ident := $"values".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
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
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v_gMacroObjectDefaultParent := {|
  gvar_info := (Tstruct _Object noattr);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMrI := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvCapSwitch := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBetaChestBottom := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvCannon := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvChuckya := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvRotatingCounterClockwise := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvWFRotatingWoodenPlatform := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvKoopaShellUnderwater := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvCoinFormation := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvOneCoin := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvYellowCoin := {|
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

Definition v_bhvDoor := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvThwomp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvTumblingBridge := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBBHTumblingBridge := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvLLLTumblingBridge := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvFlamethrower := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBouncingFireball := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBetaFishSplashSpawner := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSpindrift := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvTowerPlatformGroup := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvAnotherTiltingPlatform := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvFloorSwitchHiddenObjects := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvHiddenObject := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBreakableBox := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvPushableMetalBox := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvHeaveHo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBetaTrampolineTop := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvJumpingBox := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvAlphaBooKey := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBulletBill := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBowser := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvMacroUkiki := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvStub1D0C := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvLLLMovingOctagonalMeshPlatform := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSnowBall := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvLLLRotatingBlockWithFireBars := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvLLLFloatingWoodBridge := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvLLLRotatingHexagonalRing := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvLLLSinkingRectangularPlatform := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvLLLSinkingSquarePlatforms := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvLLLTiltingInvertedPyramid := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvToxBox := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvPiranhaPlant := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvLLLBowserPuzzle := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvTuxiesMother := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSmallPenguin := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvFishSpawner := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvChirpChirp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvExclamationBox := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSushiShark := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBlueCoinSwitch := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvHiddenBlueCoin := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvWaterLevelDiamond := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvTweester := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBooWithCage := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvCourtyardBooTriplet := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvGhostHuntBoo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBooStaircase := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBBHTiltingTrapPlatform := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvHauntedBookshelf := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvMeshElevator := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvStaticObject := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvCastleFloorTrap := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvTree := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvScuttlebug := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvScuttlebugSpawn := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSmallWhomp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvMovingBlueCoin := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBlueCoinSliding := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSeaweedBundle := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBobomb := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBobombBuddyOpensCannon := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvCannonClosed := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvMessagePanel := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSignOnWall := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvHomingAmp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvCirclingAmp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvButterfly := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvCarrySomething1 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSmallBully := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBigBully := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvJetStreamRingSpawner := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBowserBomb := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvLLLDrawbridgeSpawner := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSmallBomp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvLargeBomp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvWFSlidingPlatform := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvMoneybagHidden := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvFreeBowlingBall := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvRedCoin := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvHiddenStarTrigger := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhv1UpSliding := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhv1Up := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhv1UpJumpOnApproach := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvHidden1Up := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvHidden1UpTrigger := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvHidden1UpInPoleSpawner := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBreakableBoxSmall := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvKoopa := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvKoopaRaceEndpoint := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvPokey := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSwoop := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvFlyGuy := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvGoomba := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvGoombaTripletSpawner := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvChainChomp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvWoodenPost := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvWigglerHead := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvEnemyLakitu := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvMontyMole := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvMontyMoleHole := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSeesawPlatform := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvFerrisWheelAxle := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvWaterBombSpawner := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvTTCRotatingSolid := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvTTCPendulum := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvTTCTreadmill := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvTTCMovingBar := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvTTCCog := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvTTCPitBlock := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvTTCElevator := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvTTC2DRotator := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvTTCSpinner := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvMrBlizzard := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSlidingPlatform2 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvOctagonalPlatformRotating := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvAnimatesOnFloorSwitchPress := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvActivatedBackAndForthPlatform := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvRecoveryHeart := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvWaterBombCannon := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvUnagi := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvHauntedChair := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvFirePiranhaPlant := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvFireSpitter := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSnufit := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvClamShell := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSkeeter := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvTripletButterfly := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvUnusedFakeStar := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_sMacroObjectPresets := {|
  gvar_info := (tarray (Tstruct _MacroPreset noattr) 366);
  gvar_init := (Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvOneCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvMovingBlueCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 118) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvBlueCoinSliding (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 118) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvRedCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 215) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvCoinFormation (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvCoinFormation (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 2) ::
                Init_addrof _bhvCoinFormation (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 4) ::
                Init_addrof _bhvCoinFormation (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 16) ::
                Init_addrof _bhvCoinFormation (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 17) ::
                Init_addrof _bhvCoinFormation (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 18) ::
                Init_addrof _bhvCoinFormation (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 19) ::
                Init_addrof _bhvCoinFormation (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 20) ::
                Init_addrof _bhvHiddenStarTrigger (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvUnusedFakeStar (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 122) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvMessagePanel (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 124) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvCannonClosed (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 201) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvBobombBuddyOpensCannon (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 195) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvButterfly (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 187) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvBouncingFireball (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvFishSpawner (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvFishSpawner (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 1) ::
                Init_addrof _bhvBetaFishSplashSpawner (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvHidden1UpInPoleSpawner (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvGoomba (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 192) :: Init_int16 (Int.repr 1) ::
                Init_addrof _bhvGoomba (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 192) :: Init_int16 (Int.repr 2) ::
                Init_addrof _bhvGoombaTripletSpawner (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvGoombaTripletSpawner (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 8) ::
                Init_addrof _bhvSignOnWall (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvChuckya (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 223) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvCannon (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 128) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvGoomba (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 192) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvHomingAmp (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 194) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvCirclingAmp (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 194) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvCarrySomething1 (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 125) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvBetaTrampolineTop (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 181) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvFreeBowlingBall (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 180) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvSnufit (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 206) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvRecoveryHeart (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 120) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhv1UpSliding (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 212) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhv1Up (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 212) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhv1UpJumpOnApproach (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 212) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvHidden1Up (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 212) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvHidden1UpTrigger (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhv1Up (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 212) :: Init_int16 (Int.repr 1) ::
                Init_addrof _bhv1Up (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 212) :: Init_int16 (Int.repr 2) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvBlueCoinSwitch (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 140) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvHiddenBlueCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 118) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvCapSwitch (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 85) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvCapSwitch (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 85) :: Init_int16 (Int.repr 1) ::
                Init_addrof _bhvCapSwitch (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 85) :: Init_int16 (Int.repr 2) ::
                Init_addrof _bhvCapSwitch (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 85) :: Init_int16 (Int.repr 3) ::
                Init_addrof _bhvWaterLevelDiamond (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 129) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvExclamationBox (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 137) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvExclamationBox (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 137) :: Init_int16 (Int.repr 1) ::
                Init_addrof _bhvExclamationBox (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 137) :: Init_int16 (Int.repr 2) ::
                Init_addrof _bhvExclamationBox (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 137) :: Init_int16 (Int.repr 3) ::
                Init_addrof _bhvExclamationBox (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 137) :: Init_int16 (Int.repr 4) ::
                Init_addrof _bhvExclamationBox (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 137) :: Init_int16 (Int.repr 5) ::
                Init_addrof _bhvExclamationBox (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 137) :: Init_int16 (Int.repr 6) ::
                Init_addrof _bhvExclamationBox (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 137) :: Init_int16 (Int.repr 7) ::
                Init_addrof _bhvExclamationBox (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 137) :: Init_int16 (Int.repr 8) ::
                Init_addrof _bhvBreakableBox (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 129) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvBreakableBox (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 129) :: Init_int16 (Int.repr 1) ::
                Init_addrof _bhvPushableMetalBox (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 217) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvBreakableBoxSmall (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 130) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvFloorSwitchHiddenObjects (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 207) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvHiddenObject (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 129) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvHiddenObject (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 129) :: Init_int16 (Int.repr 1) ::
                Init_addrof _bhvHiddenObject (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 129) :: Init_int16 (Int.repr 2) ::
                Init_addrof _bhvBreakableBox (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 129) :: Init_int16 (Int.repr 3) ::
                Init_addrof _bhvKoopaShellUnderwater (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 190) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvExclamationBox (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 137) :: Init_int16 (Int.repr 9) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvBulletBill (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 84) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvHeaveHo (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 89) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvThwomp (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 88) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvFireSpitter (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 180) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvFlyGuy (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 220) :: Init_int16 (Int.repr 1) ::
                Init_addrof _bhvJumpingBox (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 129) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvTripletButterfly (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 187) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvTripletButterfly (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 187) :: Init_int16 (Int.repr 4) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvSmallBully (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 86) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvSmallBully (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 87) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvStub1D0C (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 88) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvBouncingFireball (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvFlamethrower (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 4) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvWoodenPost (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 107) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvWaterBombSpawner (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvEnemyLakitu (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 84) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvKoopa (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 104) :: Init_int16 (Int.repr 2) ::
                Init_addrof _bhvKoopaRaceEndpoint (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvBobomb (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 188) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvWaterBombCannon (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 128) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvBobombBuddyOpensCannon (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 195) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvWaterBombCannon (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 128) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvBobomb (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 188) :: Init_int16 (Int.repr 1) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvUnusedFakeStar (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 84) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvUnagi (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 85) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvSushiShark (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 86) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 87) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvTweester (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 86) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvPokey (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvPokey (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvToxBox (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 199) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvMontyMole (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 85) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvMontyMole (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 85) :: Init_int16 (Int.repr 1) ::
                Init_addrof _bhvMontyMoleHole (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 84) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvFlyGuy (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 220) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvWigglerHead (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 87) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvSpindrift (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 84) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvMrBlizzard (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 85) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvMrBlizzard (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 85) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvSmallPenguin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 87) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvTuxiesMother (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 87) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvTuxiesMother (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 87) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvMrBlizzard (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 85) :: Init_int16 (Int.repr 1) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvHauntedChair (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 86) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvHauntedChair (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 86) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvHauntedChair (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 86) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvGhostHuntBoo (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 84) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvGhostHuntBoo (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 84) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvCourtyardBooTriplet (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 84) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvBooWithCage (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 84) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvAlphaBooKey (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 85) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvChirpChirp (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvSeaweedBundle (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvBetaChestBottom (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 101) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvBowserBomb (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 179) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvFishSpawner (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 2) ::
                Init_addrof _bhvFishSpawner (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 3) ::
                Init_addrof _bhvJetStreamRingSpawner (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 104) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvJetStreamRingSpawner (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 104) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvSkeeter (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 105) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvClamShell (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 88) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvMacroUkiki (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 86) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvMacroUkiki (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 86) :: Init_int16 (Int.repr 1) ::
                Init_addrof _bhvPiranhaPlant (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 100) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvSmallWhomp (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 103) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvChainChomp (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 102) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvKoopa (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 104) :: Init_int16 (Int.repr 1) ::
                Init_addrof _bhvKoopa (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 191) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvWoodenPost (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 107) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvFirePiranhaPlant (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 100) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvFirePiranhaPlant (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 100) :: Init_int16 (Int.repr 1) ::
                Init_addrof _bhvKoopa (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 104) :: Init_int16 (Int.repr 4) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvMoneybagHidden (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvSwoop (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 100) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvSwoop (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 100) :: Init_int16 (Int.repr 1) ::
                Init_addrof _bhvMrI (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvScuttlebugSpawn (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvScuttlebug (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 101) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 84) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvTTCRotatingSolid (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 54) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvTTCRotatingSolid (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 55) :: Init_int16 (Int.repr 1) ::
                Init_addrof _bhvTTCPendulum (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 56) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvTTCTreadmill (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 57) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvTTCTreadmill (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 58) :: Init_int16 (Int.repr 1) ::
                Init_addrof _bhvTTCMovingBar (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 59) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvTTCCog (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 60) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvTTCCog (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 61) :: Init_int16 (Int.repr 2) ::
                Init_addrof _bhvTTCPitBlock (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 62) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvTTCPitBlock (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 63) :: Init_int16 (Int.repr 1) ::
                Init_addrof _bhvTTCElevator (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 64) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvTTC2DRotator (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 65) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvTTCSpinner (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 66) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvTTC2DRotator (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 67) :: Init_int16 (Int.repr 1) ::
                Init_addrof _bhvTTC2DRotator (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 68) :: Init_int16 (Int.repr 1) ::
                Init_addrof _bhvTTCTreadmill (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 57) :: Init_int16 (Int.repr 2) ::
                Init_addrof _bhvTTCTreadmill (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 58) :: Init_int16 (Int.repr 3) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvExclamationBox (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 137) :: Init_int16 (Int.repr 10) ::
                Init_addrof _bhvExclamationBox (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 137) :: Init_int16 (Int.repr 11) ::
                Init_addrof _bhvExclamationBox (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 137) :: Init_int16 (Int.repr 12) ::
                Init_addrof _bhvExclamationBox (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 137) :: Init_int16 (Int.repr 13) ::
                Init_addrof _bhvExclamationBox (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 137) :: Init_int16 (Int.repr 14) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvSlidingPlatform2 (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 54) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvSlidingPlatform2 (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 55) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvAnotherTiltingPlatform (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 56) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvOctagonalPlatformRotating (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 57) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvAnimatesOnFloorSwitchPress (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 65) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvFerrisWheelAxle (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 61) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvActivatedBackAndForthPlatform (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 62) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvSeesawPlatform (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 63) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvSeesawPlatform (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 64) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSpecialObjectPresets := {|
  gvar_info := (tarray (Tstruct _SpecialPreset noattr) 83);
  gvar_init := (Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int32 (Int.repr 0) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 116) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 2) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 116) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 3) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 184) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 4) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 84) ::
                Init_addrof _bhvCourtyardBooTriplet (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 5) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 172) ::
                Init_addrof _bhvCastleFloorTrap (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 6) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 54) ::
                Init_addrof _bhvLLLMovingOctagonalMeshPlatform (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 7) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 55) ::
                Init_addrof _bhvSnowBall (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 8) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 56) ::
                Init_addrof _bhvLLLDrawbridgeSpawner (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 9) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 10) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 58) ::
                Init_addrof _bhvLLLRotatingBlockWithFireBars (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 11) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_addrof _bhvLLLFloatingWoodBridge (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 12) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_addrof _bhvLLLTumblingBridge (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 13) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 62) ::
                Init_addrof _bhvLLLRotatingHexagonalRing (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 14) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 63) ::
                Init_addrof _bhvLLLSinkingRectangularPlatform (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 15) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 64) ::
                Init_addrof _bhvLLLSinkingSquarePlatforms (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 16) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 65) ::
                Init_addrof _bhvLLLTiltingInvertedPyramid (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 17) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_addrof _bhvLLLBowserPuzzle (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 18) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_addrof _bhvMrI (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 19) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 86) ::
                Init_addrof _bhvSmallBully (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 20) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 87) ::
                Init_addrof _bhvBigBully (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 21) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 22) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 23) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 24) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 25) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 26) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 116) ::
                Init_addrof _bhvMovingBlueCoin (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 27) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 101) ::
                Init_addrof _bhvBetaChestBottom (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 28) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 104) ::
                Init_addrof _bhvJetStreamRingSpawner (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 29) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 179) ::
                Init_addrof _bhvBowserBomb (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 30) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 31) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 187) ::
                Init_addrof _bhvButterfly (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 33) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 100) ::
                Init_addrof _bhvBowser (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 34) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 175) ::
                Init_addrof _bhvWFRotatingWoodenPlatform (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 35) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 174) ::
                Init_addrof _bhvSmallBomp (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 36) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 173) ::
                Init_addrof _bhvWFSlidingPlatform (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 37) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_addrof _bhvTowerPlatformGroup (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 38) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_addrof _bhvRotatingCounterClockwise (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 39) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 178) ::
                Init_addrof _bhvTumblingBridge (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 40) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 177) ::
                Init_addrof _bhvLargeBomp (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 101) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 3) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 102) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 4) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 103) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 5) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 104) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 6) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 105) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 7) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 106) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 8) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 107) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 9) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 108) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 10) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 109) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 11) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 110) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 12) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 111) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 13) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 112) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 14) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 113) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 15) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 114) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 16) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 115) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 17) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 116) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 18) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 117) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 19) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 118) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 20) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 119) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 21) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 120) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 22) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 121) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 23) ::
                Init_addrof _bhvTree (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 122) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 24) ::
                Init_addrof _bhvTree (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 123) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 25) ::
                Init_addrof _bhvTree (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 124) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 26) ::
                Init_addrof _bhvTree (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 125) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 27) ::
                Init_addrof _bhvTree (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 137) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 28) ::
                Init_addrof _bhvDoor (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 126) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 29) ::
                Init_addrof _bhvDoor (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 127) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 30) ::
                Init_addrof _bhvDoor (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 128) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 31) ::
                Init_addrof _bhvDoor (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 129) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 32) ::
                Init_addrof _bhvDoor (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 130) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 33) ::
                Init_addrof _bhvDoor (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 138) :: Init_int8 (Int.repr 4) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 34) ::
                Init_addrof _bhvDoor (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 139) :: Init_int8 (Int.repr 4) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 35) ::
                Init_addrof _bhvDoor (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 140) :: Init_int8 (Int.repr 4) ::
                Init_int8 (Int.repr 3) :: Init_int8 (Int.repr 36) ::
                Init_addrof _bhvDoor (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 141) :: Init_int8 (Int.repr 4) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 37) ::
                Init_addrof _bhvDoor (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 136) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 38) ::
                Init_addrof _bhvDoorWarp (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 131) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 39) ::
                Init_addrof _bhvDoorWarp (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 132) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 40) ::
                Init_addrof _bhvDoorWarp (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 133) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 41) ::
                Init_addrof _bhvDoorWarp (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 134) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 42) ::
                Init_addrof _bhvDoorWarp (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 135) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 43) ::
                Init_addrof _bhvDoorWarp (Ptrofs.repr 0) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_convert_rotation := {|
  fn_return := tshort;
  fn_callconv := cc_default;
  fn_params := ((_inRotation, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_rotation, tushort) :: nil);
  fn_body :=
(Ssequence
  (Sset _rotation
    (Ecast
      (Ecast
        (Ebinop Oand (Etempvar _inRotation tshort)
          (Econst_int (Int.repr 255) tint) tint) tushort) tushort))
  (Ssequence
    (Sset _rotation
      (Ecast
        (Ebinop Oshl (Etempvar _rotation tushort)
          (Econst_int (Int.repr 8) tint) tint) tushort))
    (Ssequence
      (Sifthenelse (Ebinop Oeq (Etempvar _rotation tushort)
                     (Econst_int (Int.repr 16128) tint) tint)
        (Sset _rotation (Ecast (Econst_int (Int.repr 16384) tint) tushort))
        Sskip)
      (Ssequence
        (Sifthenelse (Ebinop Oeq (Etempvar _rotation tushort)
                       (Econst_int (Int.repr 32512) tint) tint)
          (Sset _rotation (Ecast (Econst_int (Int.repr 32768) tint) tushort))
          Sskip)
        (Ssequence
          (Sifthenelse (Ebinop Oeq (Etempvar _rotation tushort)
                         (Econst_int (Int.repr 48896) tint) tint)
            (Sset _rotation
              (Ecast (Econst_int (Int.repr 49152) tint) tushort))
            Sskip)
          (Ssequence
            (Sifthenelse (Ebinop Oeq (Etempvar _rotation tushort)
                           (Econst_int (Int.repr 65280) tint) tint)
              (Sset _rotation (Ecast (Econst_int (Int.repr 0) tint) tushort))
              Sskip)
            (Sreturn (Some (Ecast (Etempvar _rotation tushort) tshort)))))))))
|}.

Definition f_spawn_macro_abs_yrot_2params := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_model, tint) :: (_behavior, (tptr tuint)) ::
                (_x, tshort) :: (_y, tshort) :: (_z, tshort) ::
                (_ry, tshort) :: (_params, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_newObj, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: (_t'1, tshort) ::
               nil);
  fn_body :=
(Sifthenelse (Ebinop One (Etempvar _behavior (tptr tuint))
               (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
  (Ssequence
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _convert_rotation (Tfunction (tshort :: nil) tshort
                                    cc_default))
          ((Etempvar _ry tshort) :: nil))
        (Scall (Some _t'2)
          (Evar _spawn_object_abs_with_rot (Tfunction
                                             ((tptr (Tstruct _Object noattr)) ::
                                              tshort :: tuint ::
                                              (tptr tuint) :: tshort ::
                                              tshort :: tshort :: tshort ::
                                              tshort :: tshort :: nil)
                                             (tptr (Tstruct _Object noattr))
                                             cc_default))
          ((Eaddrof
             (Evar _gMacroObjectDefaultParent (Tstruct _Object noattr))
             (tptr (Tstruct _Object noattr))) ::
           (Econst_int (Int.repr 0) tint) :: (Etempvar _model tint) ::
           (Etempvar _behavior (tptr tuint)) :: (Etempvar _x tshort) ::
           (Etempvar _y tshort) :: (Etempvar _z tshort) ::
           (Econst_int (Int.repr 0) tint) :: (Etempvar _t'1 tshort) ::
           (Econst_int (Int.repr 0) tint) :: nil)))
      (Sset _newObj (Etempvar _t'2 (tptr (Tstruct _Object noattr)))))
    (Sassign
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Ederef (Etempvar _newObj (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _rawData (Tunion __727 noattr))
            _asS32 (tarray tint 80)) (Econst_int (Int.repr 64) tint)
          (tptr tint)) tint)
      (Ebinop Oshl (Ecast (Etempvar _params tshort) tuint)
        (Econst_int (Int.repr 16) tint) tuint)))
  Sskip)
|}.

Definition f_spawn_macro_abs_yrot_param1 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_model, tint) :: (_behavior, (tptr tuint)) ::
                (_x, tshort) :: (_y, tshort) :: (_z, tshort) ::
                (_ry, tshort) :: (_param, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_newObj, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: (_t'1, tshort) ::
               nil);
  fn_body :=
(Sifthenelse (Ebinop One (Etempvar _behavior (tptr tuint))
               (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
  (Ssequence
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _convert_rotation (Tfunction (tshort :: nil) tshort
                                    cc_default))
          ((Etempvar _ry tshort) :: nil))
        (Scall (Some _t'2)
          (Evar _spawn_object_abs_with_rot (Tfunction
                                             ((tptr (Tstruct _Object noattr)) ::
                                              tshort :: tuint ::
                                              (tptr tuint) :: tshort ::
                                              tshort :: tshort :: tshort ::
                                              tshort :: tshort :: nil)
                                             (tptr (Tstruct _Object noattr))
                                             cc_default))
          ((Eaddrof
             (Evar _gMacroObjectDefaultParent (Tstruct _Object noattr))
             (tptr (Tstruct _Object noattr))) ::
           (Econst_int (Int.repr 0) tint) :: (Etempvar _model tint) ::
           (Etempvar _behavior (tptr tuint)) :: (Etempvar _x tshort) ::
           (Etempvar _y tshort) :: (Etempvar _z tshort) ::
           (Econst_int (Int.repr 0) tint) :: (Etempvar _t'1 tshort) ::
           (Econst_int (Int.repr 0) tint) :: nil)))
      (Sset _newObj (Etempvar _t'2 (tptr (Tstruct _Object noattr)))))
    (Sassign
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Ederef (Etempvar _newObj (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _rawData (Tunion __727 noattr))
            _asS32 (tarray tint 80)) (Econst_int (Int.repr 64) tint)
          (tptr tint)) tint)
      (Ebinop Oshl (Ecast (Etempvar _param tshort) tuint)
        (Econst_int (Int.repr 24) tint) tuint)))
  Sskip)
|}.

Definition f_spawn_macro_abs_special := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_model, tint) :: (_behavior, (tptr tuint)) ::
                (_x, tshort) :: (_y, tshort) :: (_z, tshort) ::
                (_unkA, tshort) :: (_unkB, tshort) :: (_unkC, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_newObj, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _spawn_object_abs_with_rot (Tfunction
                                         ((tptr (Tstruct _Object noattr)) ::
                                          tshort :: tuint :: (tptr tuint) ::
                                          tshort :: tshort :: tshort ::
                                          tshort :: tshort :: tshort :: nil)
                                         (tptr (Tstruct _Object noattr))
                                         cc_default))
      ((Eaddrof (Evar _gMacroObjectDefaultParent (Tstruct _Object noattr))
         (tptr (Tstruct _Object noattr))) ::
       (Econst_int (Int.repr 0) tint) :: (Etempvar _model tint) ::
       (Etempvar _behavior (tptr tuint)) :: (Etempvar _x tshort) ::
       (Etempvar _y tshort) :: (Etempvar _z tshort) ::
       (Econst_int (Int.repr 0) tint) :: (Econst_int (Int.repr 0) tint) ::
       (Econst_int (Int.repr 0) tint) :: nil))
    (Sset _newObj (Etempvar _t'1 (tptr (Tstruct _Object noattr)))))
  (Ssequence
    (Sassign
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Ederef (Etempvar _newObj (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _rawData (Tunion __727 noattr))
            _asF32 (tarray tfloat 80)) (Econst_int (Int.repr 32) tint)
          (tptr tfloat)) tfloat) (Ecast (Etempvar _unkA tshort) tfloat))
    (Ssequence
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _newObj (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __727 noattr))
              _asF32 (tarray tfloat 80)) (Econst_int (Int.repr 33) tint)
            (tptr tfloat)) tfloat) (Ecast (Etempvar _unkB tshort) tfloat))
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _newObj (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __727 noattr))
              _asF32 (tarray tfloat 80)) (Econst_int (Int.repr 34) tint)
            (tptr tfloat)) tfloat) (Ecast (Etempvar _unkC tshort) tfloat)))))
|}.

Definition f_spawn_macro_objects := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_areaIndex, tshort) :: (_macroObjList, (tptr tshort)) ::
                nil);
  fn_vars := ((_filler, (tarray tuchar 4)) ::
              (_macroObject, (tarray tshort 5)) ::
              (_preset, (Tstruct _LoadedPreset noattr)) :: nil);
  fn_temps := ((_presetID, tint) ::
               (_newObj, (tptr (Tstruct _Object noattr))) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tshort) ::
               (_t'5, (tptr tshort)) :: (_t'4, (tptr tshort)) ::
               (_t'3, (tptr tshort)) :: (_t'2, (tptr tshort)) ::
               (_t'1, (tptr tshort)) :: (_t'31, tshort) :: (_t'30, tshort) ::
               (_t'29, tshort) :: (_t'28, tshort) :: (_t'27, tshort) ::
               (_t'26, tshort) :: (_t'25, tshort) :: (_t'24, tshort) ::
               (_t'23, (tptr tuint)) :: (_t'22, tshort) :: (_t'21, tshort) ::
               (_t'20, tshort) :: (_t'19, tshort) :: (_t'18, tshort) ::
               (_t'17, tshort) :: (_t'16, tshort) :: (_t'15, tshort) ::
               (_t'14, (tptr tuint)) :: (_t'13, tshort) :: (_t'12, tshort) ::
               (_t'11, tshort) :: (_t'10, tshort) :: (_t'9, tshort) ::
               (_t'8, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sassign
    (Efield
      (Efield
        (Efield (Evar _gMacroObjectDefaultParent (Tstruct _Object noattr))
          _header (Tstruct _ObjectNode noattr)) _gfx
        (Tstruct _GraphNodeObject noattr)) _areaIndex tschar)
    (Etempvar _areaIndex tshort))
  (Ssequence
    (Sassign
      (Efield
        (Efield
          (Efield (Evar _gMacroObjectDefaultParent (Tstruct _Object noattr))
            _header (Tstruct _ObjectNode noattr)) _gfx
          (Tstruct _GraphNodeObject noattr)) _activeAreaIndex tschar)
      (Etempvar _areaIndex tshort))
    (Sloop
      (Ssequence
        Sskip
        (Ssequence
          (Ssequence
            (Sset _t'31
              (Ederef (Etempvar _macroObjList (tptr tshort)) tshort))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'31 tshort)
                           (Eunop Oneg (Econst_int (Int.repr 1) tint) tint)
                           tint)
              Sbreak
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'30
                (Ederef (Etempvar _macroObjList (tptr tshort)) tshort))
              (Sset _presetID
                (Ebinop Osub
                  (Ebinop Oand (Etempvar _t'30 tshort)
                    (Econst_int (Int.repr 511) tint) tint)
                  (Econst_int (Int.repr 31) tint) tint)))
            (Ssequence
              (Sifthenelse (Ebinop Olt (Etempvar _presetID tint)
                             (Econst_int (Int.repr 0) tint) tint)
                Sbreak
                Sskip)
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'1 (Etempvar _macroObjList (tptr tshort)))
                    (Sset _macroObjList
                      (Ebinop Oadd (Etempvar _t'1 (tptr tshort))
                        (Econst_int (Int.repr 1) tint) (tptr tshort))))
                  (Ssequence
                    (Sset _t'29
                      (Ederef (Etempvar _t'1 (tptr tshort)) tshort))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd (Evar _macroObject (tarray tshort 5))
                          (Econst_int (Int.repr 0) tint) (tptr tshort))
                        tshort)
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ebinop Oshr (Etempvar _t'29 tshort)
                            (Econst_int (Int.repr 9) tint) tint)
                          (Econst_int (Int.repr 127) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint))))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'2 (Etempvar _macroObjList (tptr tshort)))
                      (Sset _macroObjList
                        (Ebinop Oadd (Etempvar _t'2 (tptr tshort))
                          (Econst_int (Int.repr 1) tint) (tptr tshort))))
                    (Ssequence
                      (Sset _t'28
                        (Ederef (Etempvar _t'2 (tptr tshort)) tshort))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd (Evar _macroObject (tarray tshort 5))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))
                          tshort) (Etempvar _t'28 tshort))))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'3 (Etempvar _macroObjList (tptr tshort)))
                        (Sset _macroObjList
                          (Ebinop Oadd (Etempvar _t'3 (tptr tshort))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))))
                      (Ssequence
                        (Sset _t'27
                          (Ederef (Etempvar _t'3 (tptr tshort)) tshort))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Evar _macroObject (tarray tshort 5))
                              (Econst_int (Int.repr 2) tint) (tptr tshort))
                            tshort) (Etempvar _t'27 tshort))))
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'4 (Etempvar _macroObjList (tptr tshort)))
                          (Sset _macroObjList
                            (Ebinop Oadd (Etempvar _t'4 (tptr tshort))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))))
                        (Ssequence
                          (Sset _t'26
                            (Ederef (Etempvar _t'4 (tptr tshort)) tshort))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Evar _macroObject (tarray tshort 5))
                                (Econst_int (Int.repr 3) tint) (tptr tshort))
                              tshort) (Etempvar _t'26 tshort))))
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'5
                              (Etempvar _macroObjList (tptr tshort)))
                            (Sset _macroObjList
                              (Ebinop Oadd (Etempvar _t'5 (tptr tshort))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))))
                          (Ssequence
                            (Sset _t'25
                              (Ederef (Etempvar _t'5 (tptr tshort)) tshort))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Evar _macroObject (tarray tshort 5))
                                  (Econst_int (Int.repr 4) tint)
                                  (tptr tshort)) tshort)
                              (Etempvar _t'25 tshort))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'24
                              (Efield
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _sMacroObjectPresets (tarray (Tstruct _MacroPreset noattr) 366))
                                    (Etempvar _presetID tint)
                                    (tptr (Tstruct _MacroPreset noattr)))
                                  (Tstruct _MacroPreset noattr)) _model
                                tshort))
                            (Sassign
                              (Efield
                                (Evar _preset (Tstruct _LoadedPreset noattr))
                                _model tshort) (Etempvar _t'24 tshort)))
                          (Ssequence
                            (Ssequence
                              (Sset _t'23
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Evar _sMacroObjectPresets (tarray (Tstruct _MacroPreset noattr) 366))
                                      (Etempvar _presetID tint)
                                      (tptr (Tstruct _MacroPreset noattr)))
                                    (Tstruct _MacroPreset noattr)) _behavior
                                  (tptr tuint)))
                              (Sassign
                                (Efield
                                  (Evar _preset (Tstruct _LoadedPreset noattr))
                                  _behavior (tptr tuint))
                                (Etempvar _t'23 (tptr tuint))))
                            (Ssequence
                              (Ssequence
                                (Sset _t'22
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _sMacroObjectPresets (tarray (Tstruct _MacroPreset noattr) 366))
                                        (Etempvar _presetID tint)
                                        (tptr (Tstruct _MacroPreset noattr)))
                                      (Tstruct _MacroPreset noattr)) _param
                                    tshort))
                                (Sassign
                                  (Efield
                                    (Evar _preset (Tstruct _LoadedPreset noattr))
                                    _param tshort) (Etempvar _t'22 tshort)))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'19
                                    (Efield
                                      (Evar _preset (Tstruct _LoadedPreset noattr))
                                      _param tshort))
                                  (Sifthenelse (Ebinop One
                                                 (Etempvar _t'19 tshort)
                                                 (Econst_int (Int.repr 0) tint)
                                                 tint)
                                    (Ssequence
                                      (Sset _t'20
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _macroObject (tarray tshort 5))
                                            (Econst_int (Int.repr 4) tint)
                                            (tptr tshort)) tshort))
                                      (Ssequence
                                        (Sset _t'21
                                          (Efield
                                            (Evar _preset (Tstruct _LoadedPreset noattr))
                                            _param tshort))
                                        (Sassign
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _macroObject (tarray tshort 5))
                                              (Econst_int (Int.repr 4) tint)
                                              (tptr tshort)) tshort)
                                          (Ebinop Oadd
                                            (Ebinop Oand
                                              (Etempvar _t'20 tshort)
                                              (Econst_int (Int.repr 65280) tint)
                                              tint)
                                            (Ebinop Oand
                                              (Etempvar _t'21 tshort)
                                              (Econst_int (Int.repr 255) tint)
                                              tint) tint))))
                                    Sskip))
                                (Ssequence
                                  (Sset _t'8
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _macroObject (tarray tshort 5))
                                        (Econst_int (Int.repr 4) tint)
                                        (tptr tshort)) tshort))
                                  (Sifthenelse (Ebinop One
                                                 (Ebinop Oand
                                                   (Ebinop Oshr
                                                     (Etempvar _t'8 tshort)
                                                     (Econst_int (Int.repr 8) tint)
                                                     tint)
                                                   (Econst_int (Int.repr 255) tint)
                                                   tint)
                                                 (Econst_int (Int.repr 255) tint)
                                                 tint)
                                    (Ssequence
                                      (Ssequence
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'18
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _macroObject (tarray tshort 5))
                                                  (Econst_int (Int.repr 0) tint)
                                                  (tptr tshort)) tshort))
                                            (Scall (Some _t'6)
                                              (Evar _convert_rotation
                                              (Tfunction (tshort :: nil)
                                                tshort cc_default))
                                              ((Etempvar _t'18 tshort) ::
                                               nil)))
                                          (Ssequence
                                            (Sset _t'13
                                              (Efield
                                                (Evar _preset (Tstruct _LoadedPreset noattr))
                                                _model tshort))
                                            (Ssequence
                                              (Sset _t'14
                                                (Efield
                                                  (Evar _preset (Tstruct _LoadedPreset noattr))
                                                  _behavior (tptr tuint)))
                                              (Ssequence
                                                (Sset _t'15
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Evar _macroObject (tarray tshort 5))
                                                      (Econst_int (Int.repr 1) tint)
                                                      (tptr tshort)) tshort))
                                                (Ssequence
                                                  (Sset _t'16
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Evar _macroObject (tarray tshort 5))
                                                        (Econst_int (Int.repr 2) tint)
                                                        (tptr tshort))
                                                      tshort))
                                                  (Ssequence
                                                    (Sset _t'17
                                                      (Ederef
                                                        (Ebinop Oadd
                                                          (Evar _macroObject (tarray tshort 5))
                                                          (Econst_int (Int.repr 3) tint)
                                                          (tptr tshort))
                                                        tshort))
                                                    (Scall (Some _t'7)
                                                      (Evar _spawn_object_abs_with_rot
                                                      (Tfunction
                                                        ((tptr (Tstruct _Object noattr)) ::
                                                         tshort :: tuint ::
                                                         (tptr tuint) ::
                                                         tshort :: tshort ::
                                                         tshort :: tshort ::
                                                         tshort :: tshort ::
                                                         nil)
                                                        (tptr (Tstruct _Object noattr))
                                                        cc_default))
                                                      ((Eaddrof
                                                         (Evar _gMacroObjectDefaultParent (Tstruct _Object noattr))
                                                         (tptr (Tstruct _Object noattr))) ::
                                                       (Econst_int (Int.repr 0) tint) ::
                                                       (Etempvar _t'13 tshort) ::
                                                       (Etempvar _t'14 (tptr tuint)) ::
                                                       (Etempvar _t'15 tshort) ::
                                                       (Etempvar _t'16 tshort) ::
                                                       (Etempvar _t'17 tshort) ::
                                                       (Econst_int (Int.repr 0) tint) ::
                                                       (Etempvar _t'6 tshort) ::
                                                       (Econst_int (Int.repr 0) tint) ::
                                                       nil))))))))
                                        (Sset _newObj
                                          (Etempvar _t'7 (tptr (Tstruct _Object noattr)))))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'12
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _macroObject (tarray tshort 5))
                                                (Econst_int (Int.repr 4) tint)
                                                (tptr tshort)) tshort))
                                          (Sassign
                                            (Ederef
                                              (Ebinop Oadd
                                                (Efield
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _newObj (tptr (Tstruct _Object noattr)))
                                                      (Tstruct _Object noattr))
                                                    _rawData
                                                    (Tunion __727 noattr))
                                                  _asU32 (tarray tuint 80))
                                                (Econst_int (Int.repr 72) tint)
                                                (tptr tuint)) tuint)
                                            (Etempvar _t'12 tshort)))
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'10
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _macroObject (tarray tshort 5))
                                                  (Econst_int (Int.repr 4) tint)
                                                  (tptr tshort)) tshort))
                                            (Ssequence
                                              (Sset _t'11
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Evar _macroObject (tarray tshort 5))
                                                    (Econst_int (Int.repr 4) tint)
                                                    (tptr tshort)) tshort))
                                              (Sassign
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Efield
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _newObj (tptr (Tstruct _Object noattr)))
                                                          (Tstruct _Object noattr))
                                                        _rawData
                                                        (Tunion __727 noattr))
                                                      _asS32
                                                      (tarray tint 80))
                                                    (Econst_int (Int.repr 64) tint)
                                                    (tptr tint)) tint)
                                                (Ebinop Oadd
                                                  (Ebinop Oshl
                                                    (Ebinop Oand
                                                      (Etempvar _t'10 tshort)
                                                      (Econst_int (Int.repr 255) tint)
                                                      tint)
                                                    (Econst_int (Int.repr 16) tint)
                                                    tint)
                                                  (Ebinop Oand
                                                    (Etempvar _t'11 tshort)
                                                    (Econst_int (Int.repr 65280) tint)
                                                    tint) tint))))
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'9
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Evar _macroObject (tarray tshort 5))
                                                    (Econst_int (Int.repr 4) tint)
                                                    (tptr tshort)) tshort))
                                              (Sassign
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Efield
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _newObj (tptr (Tstruct _Object noattr)))
                                                          (Tstruct _Object noattr))
                                                        _rawData
                                                        (Tunion __727 noattr))
                                                      _asS32
                                                      (tarray tint 80))
                                                    (Econst_int (Int.repr 47) tint)
                                                    (tptr tint)) tint)
                                                (Ebinop Oand
                                                  (Etempvar _t'9 tshort)
                                                  (Econst_int (Int.repr 255) tint)
                                                  tint)))
                                            (Ssequence
                                              (Sassign
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _newObj (tptr (Tstruct _Object noattr)))
                                                    (Tstruct _Object noattr))
                                                  _respawnInfoType tshort)
                                                (Econst_int (Int.repr 2) tint))
                                              (Ssequence
                                                (Sassign
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _newObj (tptr (Tstruct _Object noattr)))
                                                      (Tstruct _Object noattr))
                                                    _respawnInfo
                                                    (tptr tvoid))
                                                  (Ebinop Osub
                                                    (Etempvar _macroObjList (tptr tshort))
                                                    (Econst_int (Int.repr 1) tint)
                                                    (tptr tshort)))
                                                (Sassign
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _newObj (tptr (Tstruct _Object noattr)))
                                                      (Tstruct _Object noattr))
                                                    _parentObj
                                                    (tptr (Tstruct _Object noattr)))
                                                  (Etempvar _newObj (tptr (Tstruct _Object noattr))))))))))
                                    Sskip)))))))))))))))
      Sskip)))
|}.

Definition f_spawn_macro_objects_hardcoded := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_areaIndex, tshort) :: (_macroObjList, (tptr tshort)) ::
                nil);
  fn_vars := ((_filler1, (tarray tuchar 8)) ::
              (_filler2, (tarray tuchar 10)) :: nil);
  fn_temps := ((_macroObjX, tshort) :: (_macroObjY, tshort) ::
               (_macroObjZ, tshort) :: (_macroObjPreset, tshort) ::
               (_macroObjRY, tshort) :: (_t'5, (tptr tshort)) ::
               (_t'4, (tptr tshort)) :: (_t'3, (tptr tshort)) ::
               (_t'2, (tptr tshort)) :: (_t'1, (tptr tshort)) ::
               (_t'10, tshort) :: (_t'9, tshort) :: (_t'8, tshort) ::
               (_t'7, tshort) :: (_t'6, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sassign
    (Efield
      (Efield
        (Efield (Evar _gMacroObjectDefaultParent (Tstruct _Object noattr))
          _header (Tstruct _ObjectNode noattr)) _gfx
        (Tstruct _GraphNodeObject noattr)) _areaIndex tschar)
    (Etempvar _areaIndex tshort))
  (Ssequence
    (Sassign
      (Efield
        (Efield
          (Efield (Evar _gMacroObjectDefaultParent (Tstruct _Object noattr))
            _header (Tstruct _ObjectNode noattr)) _gfx
          (Tstruct _GraphNodeObject noattr)) _activeAreaIndex tschar)
      (Etempvar _areaIndex tshort))
    (Sloop
      (Ssequence
        Sskip
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'1 (Etempvar _macroObjList (tptr tshort)))
              (Sset _macroObjList
                (Ebinop Oadd (Etempvar _t'1 (tptr tshort))
                  (Econst_int (Int.repr 1) tint) (tptr tshort))))
            (Ssequence
              (Sset _t'10 (Ederef (Etempvar _t'1 (tptr tshort)) tshort))
              (Sset _macroObjPreset (Ecast (Etempvar _t'10 tshort) tshort))))
          (Ssequence
            (Sifthenelse (Ebinop Olt (Etempvar _macroObjPreset tshort)
                           (Econst_int (Int.repr 0) tint) tint)
              Sbreak
              Sskip)
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'2 (Etempvar _macroObjList (tptr tshort)))
                  (Sset _macroObjList
                    (Ebinop Oadd (Etempvar _t'2 (tptr tshort))
                      (Econst_int (Int.repr 1) tint) (tptr tshort))))
                (Ssequence
                  (Sset _t'9 (Ederef (Etempvar _t'2 (tptr tshort)) tshort))
                  (Sset _macroObjX (Ecast (Etempvar _t'9 tshort) tshort))))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'3 (Etempvar _macroObjList (tptr tshort)))
                    (Sset _macroObjList
                      (Ebinop Oadd (Etempvar _t'3 (tptr tshort))
                        (Econst_int (Int.repr 1) tint) (tptr tshort))))
                  (Ssequence
                    (Sset _t'8 (Ederef (Etempvar _t'3 (tptr tshort)) tshort))
                    (Sset _macroObjY (Ecast (Etempvar _t'8 tshort) tshort))))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'4 (Etempvar _macroObjList (tptr tshort)))
                      (Sset _macroObjList
                        (Ebinop Oadd (Etempvar _t'4 (tptr tshort))
                          (Econst_int (Int.repr 1) tint) (tptr tshort))))
                    (Ssequence
                      (Sset _t'7
                        (Ederef (Etempvar _t'4 (tptr tshort)) tshort))
                      (Sset _macroObjZ (Ecast (Etempvar _t'7 tshort) tshort))))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'5 (Etempvar _macroObjList (tptr tshort)))
                        (Sset _macroObjList
                          (Ebinop Oadd (Etempvar _t'5 (tptr tshort))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))))
                      (Ssequence
                        (Sset _t'6
                          (Ederef (Etempvar _t'5 (tptr tshort)) tshort))
                        (Sset _macroObjRY
                          (Ecast (Etempvar _t'6 tshort) tshort))))
                    (Sswitch (Etempvar _macroObjPreset tshort)
                      (LScons (Some 0)
                        (Ssequence
                          (Scall None
                            (Evar _spawn_macro_abs_yrot_2params (Tfunction
                                                                  (tint ::
                                                                   (tptr tuint) ::
                                                                   tshort ::
                                                                   tshort ::
                                                                   tshort ::
                                                                   tshort ::
                                                                   tshort ::
                                                                   nil) tvoid
                                                                  cc_default))
                            ((Econst_int (Int.repr 0) tint) ::
                             (Evar _bhvBooStaircase (tarray tuint 0)) ::
                             (Etempvar _macroObjX tshort) ::
                             (Etempvar _macroObjY tshort) ::
                             (Etempvar _macroObjZ tshort) ::
                             (Etempvar _macroObjRY tshort) ::
                             (Econst_int (Int.repr 0) tint) :: nil))
                          Sbreak)
                        (LScons (Some 1)
                          (Ssequence
                            (Scall None
                              (Evar _spawn_macro_abs_yrot_2params (Tfunction
                                                                    (tint ::
                                                                    (tptr tuint) ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                              ((Econst_int (Int.repr 54) tint) ::
                               (Evar _bhvBBHTiltingTrapPlatform (tarray tuint 0)) ::
                               (Etempvar _macroObjX tshort) ::
                               (Etempvar _macroObjY tshort) ::
                               (Etempvar _macroObjZ tshort) ::
                               (Etempvar _macroObjRY tshort) ::
                               (Econst_int (Int.repr 0) tint) :: nil))
                            Sbreak)
                          (LScons (Some 2)
                            (Ssequence
                              (Scall None
                                (Evar _spawn_macro_abs_yrot_2params (Tfunction
                                                                    (tint ::
                                                                    (tptr tuint) ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                ((Econst_int (Int.repr 55) tint) ::
                                 (Evar _bhvBBHTumblingBridge (tarray tuint 0)) ::
                                 (Etempvar _macroObjX tshort) ::
                                 (Etempvar _macroObjY tshort) ::
                                 (Etempvar _macroObjZ tshort) ::
                                 (Etempvar _macroObjRY tshort) ::
                                 (Econst_int (Int.repr 0) tint) :: nil))
                              Sbreak)
                            (LScons (Some 3)
                              (Ssequence
                                (Scall None
                                  (Evar _spawn_macro_abs_yrot_2params
                                  (Tfunction
                                    (tint :: (tptr tuint) :: tshort ::
                                     tshort :: tshort :: tshort :: tshort ::
                                     nil) tvoid cc_default))
                                  ((Econst_int (Int.repr 57) tint) ::
                                   (Evar _bhvHauntedBookshelf (tarray tuint 0)) ::
                                   (Etempvar _macroObjX tshort) ::
                                   (Etempvar _macroObjY tshort) ::
                                   (Etempvar _macroObjZ tshort) ::
                                   (Etempvar _macroObjRY tshort) ::
                                   (Econst_int (Int.repr 0) tint) :: nil))
                                Sbreak)
                              (LScons (Some 4)
                                (Ssequence
                                  (Scall None
                                    (Evar _spawn_macro_abs_yrot_2params
                                    (Tfunction
                                      (tint :: (tptr tuint) :: tshort ::
                                       tshort :: tshort :: tshort ::
                                       tshort :: nil) tvoid cc_default))
                                    ((Econst_int (Int.repr 58) tint) ::
                                     (Evar _bhvMeshElevator (tarray tuint 0)) ::
                                     (Etempvar _macroObjX tshort) ::
                                     (Etempvar _macroObjY tshort) ::
                                     (Etempvar _macroObjZ tshort) ::
                                     (Etempvar _macroObjRY tshort) ::
                                     (Econst_int (Int.repr 0) tint) :: nil))
                                  Sbreak)
                                (LScons (Some 20)
                                  (Ssequence
                                    (Scall None
                                      (Evar _spawn_macro_abs_yrot_2params
                                      (Tfunction
                                        (tint :: (tptr tuint) :: tshort ::
                                         tshort :: tshort :: tshort ::
                                         tshort :: nil) tvoid cc_default))
                                      ((Econst_int (Int.repr 116) tint) ::
                                       (Evar _bhvYellowCoin (tarray tuint 0)) ::
                                       (Etempvar _macroObjX tshort) ::
                                       (Etempvar _macroObjY tshort) ::
                                       (Etempvar _macroObjZ tshort) ::
                                       (Etempvar _macroObjRY tshort) ::
                                       (Econst_int (Int.repr 0) tint) :: nil))
                                    Sbreak)
                                  (LScons (Some 21)
                                    (Ssequence
                                      (Scall None
                                        (Evar _spawn_macro_abs_yrot_2params
                                        (Tfunction
                                          (tint :: (tptr tuint) :: tshort ::
                                           tshort :: tshort :: tshort ::
                                           tshort :: nil) tvoid cc_default))
                                        ((Econst_int (Int.repr 116) tint) ::
                                         (Evar _bhvYellowCoin (tarray tuint 0)) ::
                                         (Etempvar _macroObjX tshort) ::
                                         (Etempvar _macroObjY tshort) ::
                                         (Etempvar _macroObjZ tshort) ::
                                         (Etempvar _macroObjRY tshort) ::
                                         (Econst_int (Int.repr 0) tint) ::
                                         nil))
                                      Sbreak)
                                    (LScons None Sbreak LSnil))))))))))))))))
      Sskip)))
|}.

Definition f_spawn_special_objects := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_areaIndex, tshort) ::
                (_specialObjList, (tptr (tptr tshort))) :: nil);
  fn_vars := ((_extraParams, (tarray tshort 4)) :: nil);
  fn_temps := ((_numOfSpecialObjects, tint) :: (_i, tint) ::
               (_offset, tint) :: (_x, tshort) :: (_y, tshort) ::
               (_z, tshort) :: (_model, tuchar) :: (_type, tuchar) ::
               (_presetID, tuchar) :: (_defaultParam, tuchar) ::
               (_behavior, (tptr tuint)) :: (_t'46, (tptr tshort)) ::
               (_t'45, (tptr tshort)) :: (_t'44, tshort) ::
               (_t'43, (tptr tshort)) :: (_t'42, (tptr tshort)) ::
               (_t'41, tshort) :: (_t'40, (tptr tshort)) ::
               (_t'39, (tptr tshort)) :: (_t'38, tshort) ::
               (_t'37, (tptr tshort)) :: (_t'36, (tptr tshort)) ::
               (_t'35, tshort) :: (_t'34, (tptr tshort)) ::
               (_t'33, (tptr tshort)) :: (_t'32, tuchar) ::
               (_t'31, tuchar) :: (_t'30, tuchar) :: (_t'29, tuchar) ::
               (_t'28, tshort) :: (_t'27, (tptr tshort)) ::
               (_t'26, (tptr tshort)) :: (_t'25, tshort) ::
               (_t'24, tshort) :: (_t'23, (tptr tshort)) ::
               (_t'22, (tptr tshort)) :: (_t'21, tshort) ::
               (_t'20, (tptr tshort)) :: (_t'19, (tptr tshort)) ::
               (_t'18, tshort) :: (_t'17, tshort) :: (_t'16, tshort) ::
               (_t'15, (tptr tshort)) :: (_t'14, (tptr tshort)) ::
               (_t'13, tshort) :: (_t'12, (tptr tshort)) ::
               (_t'11, (tptr tshort)) :: (_t'10, tshort) ::
               (_t'9, (tptr tshort)) :: (_t'8, (tptr tshort)) ::
               (_t'7, tshort) :: (_t'6, tshort) :: (_t'5, tshort) ::
               (_t'4, tshort) :: (_t'3, (tptr tshort)) ::
               (_t'2, (tptr tshort)) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'46
      (Ederef (Etempvar _specialObjList (tptr (tptr tshort))) (tptr tshort)))
    (Sset _numOfSpecialObjects
      (Ederef (Etempvar _t'46 (tptr tshort)) tshort)))
  (Ssequence
    (Ssequence
      (Sset _t'45
        (Ederef (Etempvar _specialObjList (tptr (tptr tshort)))
          (tptr tshort)))
      (Sassign
        (Ederef (Etempvar _specialObjList (tptr (tptr tshort)))
          (tptr tshort))
        (Ebinop Oadd (Etempvar _t'45 (tptr tshort))
          (Econst_int (Int.repr 1) tint) (tptr tshort))))
    (Ssequence
      (Sassign
        (Efield
          (Efield
            (Efield
              (Evar _gMacroObjectDefaultParent (Tstruct _Object noattr))
              _header (Tstruct _ObjectNode noattr)) _gfx
            (Tstruct _GraphNodeObject noattr)) _areaIndex tschar)
        (Etempvar _areaIndex tshort))
      (Ssequence
        (Sassign
          (Efield
            (Efield
              (Efield
                (Evar _gMacroObjectDefaultParent (Tstruct _Object noattr))
                _header (Tstruct _ObjectNode noattr)) _gfx
              (Tstruct _GraphNodeObject noattr)) _activeAreaIndex tschar)
          (Etempvar _areaIndex tshort))
        (Ssequence
          (Sset _i (Econst_int (Int.repr 0) tint))
          (Sloop
            (Ssequence
              (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                             (Etempvar _numOfSpecialObjects tint) tint)
                Sskip
                Sbreak)
              (Ssequence
                (Ssequence
                  (Sset _t'43
                    (Ederef (Etempvar _specialObjList (tptr (tptr tshort)))
                      (tptr tshort)))
                  (Ssequence
                    (Sset _t'44
                      (Ederef (Etempvar _t'43 (tptr tshort)) tshort))
                    (Sset _presetID
                      (Ecast (Ecast (Etempvar _t'44 tshort) tuchar) tuchar))))
                (Ssequence
                  (Ssequence
                    (Sset _t'42
                      (Ederef (Etempvar _specialObjList (tptr (tptr tshort)))
                        (tptr tshort)))
                    (Sassign
                      (Ederef (Etempvar _specialObjList (tptr (tptr tshort)))
                        (tptr tshort))
                      (Ebinop Oadd (Etempvar _t'42 (tptr tshort))
                        (Econst_int (Int.repr 1) tint) (tptr tshort))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'40
                        (Ederef
                          (Etempvar _specialObjList (tptr (tptr tshort)))
                          (tptr tshort)))
                      (Ssequence
                        (Sset _t'41
                          (Ederef (Etempvar _t'40 (tptr tshort)) tshort))
                        (Sset _x (Ecast (Etempvar _t'41 tshort) tshort))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'39
                          (Ederef
                            (Etempvar _specialObjList (tptr (tptr tshort)))
                            (tptr tshort)))
                        (Sassign
                          (Ederef
                            (Etempvar _specialObjList (tptr (tptr tshort)))
                            (tptr tshort))
                          (Ebinop Oadd (Etempvar _t'39 (tptr tshort))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'37
                            (Ederef
                              (Etempvar _specialObjList (tptr (tptr tshort)))
                              (tptr tshort)))
                          (Ssequence
                            (Sset _t'38
                              (Ederef (Etempvar _t'37 (tptr tshort)) tshort))
                            (Sset _y (Ecast (Etempvar _t'38 tshort) tshort))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'36
                              (Ederef
                                (Etempvar _specialObjList (tptr (tptr tshort)))
                                (tptr tshort)))
                            (Sassign
                              (Ederef
                                (Etempvar _specialObjList (tptr (tptr tshort)))
                                (tptr tshort))
                              (Ebinop Oadd (Etempvar _t'36 (tptr tshort))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))))
                          (Ssequence
                            (Ssequence
                              (Sset _t'34
                                (Ederef
                                  (Etempvar _specialObjList (tptr (tptr tshort)))
                                  (tptr tshort)))
                              (Ssequence
                                (Sset _t'35
                                  (Ederef (Etempvar _t'34 (tptr tshort))
                                    tshort))
                                (Sset _z
                                  (Ecast (Etempvar _t'35 tshort) tshort))))
                            (Ssequence
                              (Ssequence
                                (Sset _t'33
                                  (Ederef
                                    (Etempvar _specialObjList (tptr (tptr tshort)))
                                    (tptr tshort)))
                                (Sassign
                                  (Ederef
                                    (Etempvar _specialObjList (tptr (tptr tshort)))
                                    (tptr tshort))
                                  (Ebinop Oadd (Etempvar _t'33 (tptr tshort))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr tshort))))
                              (Ssequence
                                (Sset _offset (Econst_int (Int.repr 0) tint))
                                (Ssequence
                                  (Sloop
                                    (Ssequence
                                      Sskip
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'32
                                            (Efield
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _sSpecialObjectPresets (tarray (Tstruct _SpecialPreset noattr) 83))
                                                  (Etempvar _offset tint)
                                                  (tptr (Tstruct _SpecialPreset noattr)))
                                                (Tstruct _SpecialPreset noattr))
                                              _presetID tuchar))
                                          (Sifthenelse (Ebinop Oeq
                                                         (Etempvar _t'32 tuchar)
                                                         (Etempvar _presetID tuchar)
                                                         tint)
                                            Sbreak
                                            Sskip))
                                        (Ssequence
                                          Sskip
                                          (Sset _offset
                                            (Ebinop Oadd
                                              (Etempvar _offset tint)
                                              (Econst_int (Int.repr 1) tint)
                                              tint)))))
                                    Sskip)
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'31
                                        (Efield
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _sSpecialObjectPresets (tarray (Tstruct _SpecialPreset noattr) 83))
                                              (Etempvar _offset tint)
                                              (tptr (Tstruct _SpecialPreset noattr)))
                                            (Tstruct _SpecialPreset noattr))
                                          _model tuchar))
                                      (Sset _model
                                        (Ecast (Etempvar _t'31 tuchar)
                                          tuchar)))
                                    (Ssequence
                                      (Sset _behavior
                                        (Efield
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _sSpecialObjectPresets (tarray (Tstruct _SpecialPreset noattr) 83))
                                              (Etempvar _offset tint)
                                              (tptr (Tstruct _SpecialPreset noattr)))
                                            (Tstruct _SpecialPreset noattr))
                                          _behavior (tptr tuint)))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'30
                                            (Efield
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _sSpecialObjectPresets (tarray (Tstruct _SpecialPreset noattr) 83))
                                                  (Etempvar _offset tint)
                                                  (tptr (Tstruct _SpecialPreset noattr)))
                                                (Tstruct _SpecialPreset noattr))
                                              _type tuchar))
                                          (Sset _type
                                            (Ecast (Etempvar _t'30 tuchar)
                                              tuchar)))
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'29
                                              (Efield
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Evar _sSpecialObjectPresets (tarray (Tstruct _SpecialPreset noattr) 83))
                                                    (Etempvar _offset tint)
                                                    (tptr (Tstruct _SpecialPreset noattr)))
                                                  (Tstruct _SpecialPreset noattr))
                                                _defParam tuchar))
                                            (Sset _defaultParam
                                              (Ecast (Etempvar _t'29 tuchar)
                                                tuchar)))
                                          (Sswitch (Etempvar _type tuchar)
                                            (LScons (Some 0)
                                              (Ssequence
                                                (Scall None
                                                  (Evar _spawn_macro_abs_yrot_2params
                                                  (Tfunction
                                                    (tint :: (tptr tuint) ::
                                                     tshort :: tshort ::
                                                     tshort :: tshort ::
                                                     tshort :: nil) tvoid
                                                    cc_default))
                                                  ((Etempvar _model tuchar) ::
                                                   (Etempvar _behavior (tptr tuint)) ::
                                                   (Etempvar _x tshort) ::
                                                   (Etempvar _y tshort) ::
                                                   (Etempvar _z tshort) ::
                                                   (Econst_int (Int.repr 0) tint) ::
                                                   (Econst_int (Int.repr 0) tint) ::
                                                   nil))
                                                Sbreak)
                                              (LScons (Some 1)
                                                (Ssequence
                                                  (Ssequence
                                                    (Sset _t'27
                                                      (Ederef
                                                        (Etempvar _specialObjList (tptr (tptr tshort)))
                                                        (tptr tshort)))
                                                    (Ssequence
                                                      (Sset _t'28
                                                        (Ederef
                                                          (Etempvar _t'27 (tptr tshort))
                                                          tshort))
                                                      (Sassign
                                                        (Ederef
                                                          (Ebinop Oadd
                                                            (Evar _extraParams (tarray tshort 4))
                                                            (Econst_int (Int.repr 0) tint)
                                                            (tptr tshort))
                                                          tshort)
                                                        (Etempvar _t'28 tshort))))
                                                  (Ssequence
                                                    (Ssequence
                                                      (Sset _t'26
                                                        (Ederef
                                                          (Etempvar _specialObjList (tptr (tptr tshort)))
                                                          (tptr tshort)))
                                                      (Sassign
                                                        (Ederef
                                                          (Etempvar _specialObjList (tptr (tptr tshort)))
                                                          (tptr tshort))
                                                        (Ebinop Oadd
                                                          (Etempvar _t'26 (tptr tshort))
                                                          (Econst_int (Int.repr 1) tint)
                                                          (tptr tshort))))
                                                    (Ssequence
                                                      (Ssequence
                                                        (Sset _t'25
                                                          (Ederef
                                                            (Ebinop Oadd
                                                              (Evar _extraParams (tarray tshort 4))
                                                              (Econst_int (Int.repr 0) tint)
                                                              (tptr tshort))
                                                            tshort))
                                                        (Scall None
                                                          (Evar _spawn_macro_abs_yrot_2params
                                                          (Tfunction
                                                            (tint ::
                                                             (tptr tuint) ::
                                                             tshort ::
                                                             tshort ::
                                                             tshort ::
                                                             tshort ::
                                                             tshort :: nil)
                                                            tvoid cc_default))
                                                          ((Etempvar _model tuchar) ::
                                                           (Etempvar _behavior (tptr tuint)) ::
                                                           (Etempvar _x tshort) ::
                                                           (Etempvar _y tshort) ::
                                                           (Etempvar _z tshort) ::
                                                           (Etempvar _t'25 tshort) ::
                                                           (Econst_int (Int.repr 0) tint) ::
                                                           nil)))
                                                      Sbreak)))
                                                (LScons (Some 2)
                                                  (Ssequence
                                                    (Ssequence
                                                      (Sset _t'23
                                                        (Ederef
                                                          (Etempvar _specialObjList (tptr (tptr tshort)))
                                                          (tptr tshort)))
                                                      (Ssequence
                                                        (Sset _t'24
                                                          (Ederef
                                                            (Etempvar _t'23 (tptr tshort))
                                                            tshort))
                                                        (Sassign
                                                          (Ederef
                                                            (Ebinop Oadd
                                                              (Evar _extraParams (tarray tshort 4))
                                                              (Econst_int (Int.repr 0) tint)
                                                              (tptr tshort))
                                                            tshort)
                                                          (Etempvar _t'24 tshort))))
                                                    (Ssequence
                                                      (Ssequence
                                                        (Sset _t'22
                                                          (Ederef
                                                            (Etempvar _specialObjList (tptr (tptr tshort)))
                                                            (tptr tshort)))
                                                        (Sassign
                                                          (Ederef
                                                            (Etempvar _specialObjList (tptr (tptr tshort)))
                                                            (tptr tshort))
                                                          (Ebinop Oadd
                                                            (Etempvar _t'22 (tptr tshort))
                                                            (Econst_int (Int.repr 1) tint)
                                                            (tptr tshort))))
                                                      (Ssequence
                                                        (Ssequence
                                                          (Sset _t'20
                                                            (Ederef
                                                              (Etempvar _specialObjList (tptr (tptr tshort)))
                                                              (tptr tshort)))
                                                          (Ssequence
                                                            (Sset _t'21
                                                              (Ederef
                                                                (Etempvar _t'20 (tptr tshort))
                                                                tshort))
                                                            (Sassign
                                                              (Ederef
                                                                (Ebinop Oadd
                                                                  (Evar _extraParams (tarray tshort 4))
                                                                  (Econst_int (Int.repr 1) tint)
                                                                  (tptr tshort))
                                                                tshort)
                                                              (Etempvar _t'21 tshort))))
                                                        (Ssequence
                                                          (Ssequence
                                                            (Sset _t'19
                                                              (Ederef
                                                                (Etempvar _specialObjList (tptr (tptr tshort)))
                                                                (tptr tshort)))
                                                            (Sassign
                                                              (Ederef
                                                                (Etempvar _specialObjList (tptr (tptr tshort)))
                                                                (tptr tshort))
                                                              (Ebinop Oadd
                                                                (Etempvar _t'19 (tptr tshort))
                                                                (Econst_int (Int.repr 1) tint)
                                                                (tptr tshort))))
                                                          (Ssequence
                                                            (Ssequence
                                                              (Sset _t'17
                                                                (Ederef
                                                                  (Ebinop Oadd
                                                                    (Evar _extraParams (tarray tshort 4))
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    (tptr tshort))
                                                                  tshort))
                                                              (Ssequence
                                                                (Sset _t'18
                                                                  (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _extraParams (tarray tshort 4))
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (tptr tshort))
                                                                    tshort))
                                                                (Scall None
                                                                  (Evar _spawn_macro_abs_yrot_2params
                                                                  (Tfunction
                                                                    (tint ::
                                                                    (tptr tuint) ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                                                  ((Etempvar _model tuchar) ::
                                                                   (Etempvar _behavior (tptr tuint)) ::
                                                                   (Etempvar _x tshort) ::
                                                                   (Etempvar _y tshort) ::
                                                                   (Etempvar _z tshort) ::
                                                                   (Etempvar _t'17 tshort) ::
                                                                   (Etempvar _t'18 tshort) ::
                                                                   nil))))
                                                            Sbreak)))))
                                                  (LScons (Some 3)
                                                    (Ssequence
                                                      (Ssequence
                                                        (Sset _t'15
                                                          (Ederef
                                                            (Etempvar _specialObjList (tptr (tptr tshort)))
                                                            (tptr tshort)))
                                                        (Ssequence
                                                          (Sset _t'16
                                                            (Ederef
                                                              (Etempvar _t'15 (tptr tshort))
                                                              tshort))
                                                          (Sassign
                                                            (Ederef
                                                              (Ebinop Oadd
                                                                (Evar _extraParams (tarray tshort 4))
                                                                (Econst_int (Int.repr 0) tint)
                                                                (tptr tshort))
                                                              tshort)
                                                            (Etempvar _t'16 tshort))))
                                                      (Ssequence
                                                        (Ssequence
                                                          (Sset _t'14
                                                            (Ederef
                                                              (Etempvar _specialObjList (tptr (tptr tshort)))
                                                              (tptr tshort)))
                                                          (Sassign
                                                            (Ederef
                                                              (Etempvar _specialObjList (tptr (tptr tshort)))
                                                              (tptr tshort))
                                                            (Ebinop Oadd
                                                              (Etempvar _t'14 (tptr tshort))
                                                              (Econst_int (Int.repr 1) tint)
                                                              (tptr tshort))))
                                                        (Ssequence
                                                          (Ssequence
                                                            (Sset _t'12
                                                              (Ederef
                                                                (Etempvar _specialObjList (tptr (tptr tshort)))
                                                                (tptr tshort)))
                                                            (Ssequence
                                                              (Sset _t'13
                                                                (Ederef
                                                                  (Etempvar _t'12 (tptr tshort))
                                                                  tshort))
                                                              (Sassign
                                                                (Ederef
                                                                  (Ebinop Oadd
                                                                    (Evar _extraParams (tarray tshort 4))
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (tptr tshort))
                                                                  tshort)
                                                                (Etempvar _t'13 tshort))))
                                                          (Ssequence
                                                            (Ssequence
                                                              (Sset _t'11
                                                                (Ederef
                                                                  (Etempvar _specialObjList (tptr (tptr tshort)))
                                                                  (tptr tshort)))
                                                              (Sassign
                                                                (Ederef
                                                                  (Etempvar _specialObjList (tptr (tptr tshort)))
                                                                  (tptr tshort))
                                                                (Ebinop Oadd
                                                                  (Etempvar _t'11 (tptr tshort))
                                                                  (Econst_int (Int.repr 1) tint)
                                                                  (tptr tshort))))
                                                            (Ssequence
                                                              (Ssequence
                                                                (Sset _t'9
                                                                  (Ederef
                                                                    (Etempvar _specialObjList (tptr (tptr tshort)))
                                                                    (tptr tshort)))
                                                                (Ssequence
                                                                  (Sset _t'10
                                                                    (Ederef
                                                                    (Etempvar _t'9 (tptr tshort))
                                                                    tshort))
                                                                  (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _extraParams (tarray tshort 4))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr tshort))
                                                                    tshort)
                                                                    (Etempvar _t'10 tshort))))
                                                              (Ssequence
                                                                (Ssequence
                                                                  (Sset _t'8
                                                                    (Ederef
                                                                    (Etempvar _specialObjList (tptr (tptr tshort)))
                                                                    (tptr tshort)))
                                                                  (Sassign
                                                                    (Ederef
                                                                    (Etempvar _specialObjList (tptr (tptr tshort)))
                                                                    (tptr tshort))
                                                                    (Ebinop Oadd
                                                                    (Etempvar _t'8 (tptr tshort))
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (tptr tshort))))
                                                                (Ssequence
                                                                  (Ssequence
                                                                    (Sset _t'5
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _extraParams (tarray tshort 4))
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    (tptr tshort))
                                                                    tshort))
                                                                    (Ssequence
                                                                    (Sset _t'6
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _extraParams (tarray tshort 4))
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (tptr tshort))
                                                                    tshort))
                                                                    (Ssequence
                                                                    (Sset _t'7
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _extraParams (tarray tshort 4))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr tshort))
                                                                    tshort))
                                                                    (Scall None
                                                                    (Evar _spawn_macro_abs_special
                                                                    (Tfunction
                                                                    (tint ::
                                                                    (tptr tuint) ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                                                    ((Etempvar _model tuchar) ::
                                                                    (Etempvar _behavior (tptr tuint)) ::
                                                                    (Etempvar _x tshort) ::
                                                                    (Etempvar _y tshort) ::
                                                                    (Etempvar _z tshort) ::
                                                                    (Etempvar _t'5 tshort) ::
                                                                    (Etempvar _t'6 tshort) ::
                                                                    (Etempvar _t'7 tshort) ::
                                                                    nil)))))
                                                                  Sbreak)))))))
                                                    (LScons (Some 4)
                                                      (Ssequence
                                                        (Ssequence
                                                          (Sset _t'3
                                                            (Ederef
                                                              (Etempvar _specialObjList (tptr (tptr tshort)))
                                                              (tptr tshort)))
                                                          (Ssequence
                                                            (Sset _t'4
                                                              (Ederef
                                                                (Etempvar _t'3 (tptr tshort))
                                                                tshort))
                                                            (Sassign
                                                              (Ederef
                                                                (Ebinop Oadd
                                                                  (Evar _extraParams (tarray tshort 4))
                                                                  (Econst_int (Int.repr 0) tint)
                                                                  (tptr tshort))
                                                                tshort)
                                                              (Etempvar _t'4 tshort))))
                                                        (Ssequence
                                                          (Ssequence
                                                            (Sset _t'2
                                                              (Ederef
                                                                (Etempvar _specialObjList (tptr (tptr tshort)))
                                                                (tptr tshort)))
                                                            (Sassign
                                                              (Ederef
                                                                (Etempvar _specialObjList (tptr (tptr tshort)))
                                                                (tptr tshort))
                                                              (Ebinop Oadd
                                                                (Etempvar _t'2 (tptr tshort))
                                                                (Econst_int (Int.repr 1) tint)
                                                                (tptr tshort))))
                                                          (Ssequence
                                                            (Ssequence
                                                              (Sset _t'1
                                                                (Ederef
                                                                  (Ebinop Oadd
                                                                    (Evar _extraParams (tarray tshort 4))
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    (tptr tshort))
                                                                  tshort))
                                                              (Scall None
                                                                (Evar _spawn_macro_abs_yrot_param1
                                                                (Tfunction
                                                                  (tint ::
                                                                   (tptr tuint) ::
                                                                   tshort ::
                                                                   tshort ::
                                                                   tshort ::
                                                                   tshort ::
                                                                   tshort ::
                                                                   nil) tvoid
                                                                  cc_default))
                                                                ((Etempvar _model tuchar) ::
                                                                 (Etempvar _behavior (tptr tuint)) ::
                                                                 (Etempvar _x tshort) ::
                                                                 (Etempvar _y tshort) ::
                                                                 (Etempvar _z tshort) ::
                                                                 (Etempvar _t'1 tshort) ::
                                                                 (Etempvar _defaultParam tuchar) ::
                                                                 nil)))
                                                            Sbreak)))
                                                      (LScons None
                                                        Sbreak
                                                        LSnil))))))))))))))))))))))
            (Sset _i
              (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint)
                tint))))))))
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
 Composite _MacroPreset Struct
   (Member_plain _behavior (tptr tuint) :: Member_plain _model tshort ::
    Member_plain _param tshort :: nil)
   noattr ::
 Composite _SpecialPreset Struct
   (Member_plain _presetID tuchar :: Member_plain _type tuchar ::
    Member_plain _defParam tuchar :: Member_plain _model tuchar ::
    Member_plain _behavior (tptr tuint) :: nil)
   noattr ::
 Composite _LoadedPreset Struct
   (Member_plain _behavior (tptr tuint) :: Member_plain _param tshort ::
    Member_plain _model tshort :: nil)
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
 (_gMacroObjectDefaultParent, Gvar v_gMacroObjectDefaultParent) ::
 (_bhvMrI, Gvar v_bhvMrI) :: (_bhvCapSwitch, Gvar v_bhvCapSwitch) ::
 (_bhvBetaChestBottom, Gvar v_bhvBetaChestBottom) ::
 (_bhvCannon, Gvar v_bhvCannon) :: (_bhvChuckya, Gvar v_bhvChuckya) ::
 (_bhvRotatingCounterClockwise, Gvar v_bhvRotatingCounterClockwise) ::
 (_bhvWFRotatingWoodenPlatform, Gvar v_bhvWFRotatingWoodenPlatform) ::
 (_bhvKoopaShellUnderwater, Gvar v_bhvKoopaShellUnderwater) ::
 (_bhvCoinFormation, Gvar v_bhvCoinFormation) ::
 (_bhvOneCoin, Gvar v_bhvOneCoin) ::
 (_bhvYellowCoin, Gvar v_bhvYellowCoin) ::
 (_bhvDoorWarp, Gvar v_bhvDoorWarp) :: (_bhvDoor, Gvar v_bhvDoor) ::
 (_bhvThwomp, Gvar v_bhvThwomp) ::
 (_bhvTumblingBridge, Gvar v_bhvTumblingBridge) ::
 (_bhvBBHTumblingBridge, Gvar v_bhvBBHTumblingBridge) ::
 (_bhvLLLTumblingBridge, Gvar v_bhvLLLTumblingBridge) ::
 (_bhvFlamethrower, Gvar v_bhvFlamethrower) ::
 (_bhvBouncingFireball, Gvar v_bhvBouncingFireball) ::
 (_bhvBetaFishSplashSpawner, Gvar v_bhvBetaFishSplashSpawner) ::
 (_bhvSpindrift, Gvar v_bhvSpindrift) ::
 (_bhvTowerPlatformGroup, Gvar v_bhvTowerPlatformGroup) ::
 (_bhvAnotherTiltingPlatform, Gvar v_bhvAnotherTiltingPlatform) ::
 (_bhvFloorSwitchHiddenObjects, Gvar v_bhvFloorSwitchHiddenObjects) ::
 (_bhvHiddenObject, Gvar v_bhvHiddenObject) ::
 (_bhvBreakableBox, Gvar v_bhvBreakableBox) ::
 (_bhvPushableMetalBox, Gvar v_bhvPushableMetalBox) ::
 (_bhvHeaveHo, Gvar v_bhvHeaveHo) ::
 (_bhvBetaTrampolineTop, Gvar v_bhvBetaTrampolineTop) ::
 (_bhvJumpingBox, Gvar v_bhvJumpingBox) ::
 (_bhvAlphaBooKey, Gvar v_bhvAlphaBooKey) ::
 (_bhvBulletBill, Gvar v_bhvBulletBill) :: (_bhvBowser, Gvar v_bhvBowser) ::
 (_bhvMacroUkiki, Gvar v_bhvMacroUkiki) ::
 (_bhvStub1D0C, Gvar v_bhvStub1D0C) ::
 (_bhvLLLMovingOctagonalMeshPlatform, Gvar v_bhvLLLMovingOctagonalMeshPlatform) ::
 (_bhvSnowBall, Gvar v_bhvSnowBall) ::
 (_bhvLLLRotatingBlockWithFireBars, Gvar v_bhvLLLRotatingBlockWithFireBars) ::
 (_bhvLLLFloatingWoodBridge, Gvar v_bhvLLLFloatingWoodBridge) ::
 (_bhvLLLRotatingHexagonalRing, Gvar v_bhvLLLRotatingHexagonalRing) ::
 (_bhvLLLSinkingRectangularPlatform, Gvar v_bhvLLLSinkingRectangularPlatform) ::
 (_bhvLLLSinkingSquarePlatforms, Gvar v_bhvLLLSinkingSquarePlatforms) ::
 (_bhvLLLTiltingInvertedPyramid, Gvar v_bhvLLLTiltingInvertedPyramid) ::
 (_bhvToxBox, Gvar v_bhvToxBox) ::
 (_bhvPiranhaPlant, Gvar v_bhvPiranhaPlant) ::
 (_bhvLLLBowserPuzzle, Gvar v_bhvLLLBowserPuzzle) ::
 (_bhvTuxiesMother, Gvar v_bhvTuxiesMother) ::
 (_bhvSmallPenguin, Gvar v_bhvSmallPenguin) ::
 (_bhvFishSpawner, Gvar v_bhvFishSpawner) ::
 (_bhvChirpChirp, Gvar v_bhvChirpChirp) ::
 (_bhvExclamationBox, Gvar v_bhvExclamationBox) ::
 (_bhvSushiShark, Gvar v_bhvSushiShark) ::
 (_bhvBlueCoinSwitch, Gvar v_bhvBlueCoinSwitch) ::
 (_bhvHiddenBlueCoin, Gvar v_bhvHiddenBlueCoin) ::
 (_bhvWaterLevelDiamond, Gvar v_bhvWaterLevelDiamond) ::
 (_bhvTweester, Gvar v_bhvTweester) ::
 (_bhvBooWithCage, Gvar v_bhvBooWithCage) ::
 (_bhvCourtyardBooTriplet, Gvar v_bhvCourtyardBooTriplet) ::
 (_bhvGhostHuntBoo, Gvar v_bhvGhostHuntBoo) ::
 (_bhvBooStaircase, Gvar v_bhvBooStaircase) ::
 (_bhvBBHTiltingTrapPlatform, Gvar v_bhvBBHTiltingTrapPlatform) ::
 (_bhvHauntedBookshelf, Gvar v_bhvHauntedBookshelf) ::
 (_bhvMeshElevator, Gvar v_bhvMeshElevator) ::
 (_bhvStaticObject, Gvar v_bhvStaticObject) ::
 (_bhvCastleFloorTrap, Gvar v_bhvCastleFloorTrap) ::
 (_bhvTree, Gvar v_bhvTree) :: (_bhvScuttlebug, Gvar v_bhvScuttlebug) ::
 (_bhvScuttlebugSpawn, Gvar v_bhvScuttlebugSpawn) ::
 (_bhvSmallWhomp, Gvar v_bhvSmallWhomp) ::
 (_bhvMovingBlueCoin, Gvar v_bhvMovingBlueCoin) ::
 (_bhvBlueCoinSliding, Gvar v_bhvBlueCoinSliding) ::
 (_bhvSeaweedBundle, Gvar v_bhvSeaweedBundle) ::
 (_bhvBobomb, Gvar v_bhvBobomb) ::
 (_bhvBobombBuddyOpensCannon, Gvar v_bhvBobombBuddyOpensCannon) ::
 (_bhvCannonClosed, Gvar v_bhvCannonClosed) ::
 (_bhvMessagePanel, Gvar v_bhvMessagePanel) ::
 (_bhvSignOnWall, Gvar v_bhvSignOnWall) ::
 (_bhvHomingAmp, Gvar v_bhvHomingAmp) ::
 (_bhvCirclingAmp, Gvar v_bhvCirclingAmp) ::
 (_bhvButterfly, Gvar v_bhvButterfly) ::
 (_bhvCarrySomething1, Gvar v_bhvCarrySomething1) ::
 (_bhvSmallBully, Gvar v_bhvSmallBully) ::
 (_bhvBigBully, Gvar v_bhvBigBully) ::
 (_bhvJetStreamRingSpawner, Gvar v_bhvJetStreamRingSpawner) ::
 (_bhvBowserBomb, Gvar v_bhvBowserBomb) ::
 (_bhvLLLDrawbridgeSpawner, Gvar v_bhvLLLDrawbridgeSpawner) ::
 (_bhvSmallBomp, Gvar v_bhvSmallBomp) ::
 (_bhvLargeBomp, Gvar v_bhvLargeBomp) ::
 (_bhvWFSlidingPlatform, Gvar v_bhvWFSlidingPlatform) ::
 (_bhvMoneybagHidden, Gvar v_bhvMoneybagHidden) ::
 (_bhvFreeBowlingBall, Gvar v_bhvFreeBowlingBall) ::
 (_bhvRedCoin, Gvar v_bhvRedCoin) ::
 (_bhvHiddenStarTrigger, Gvar v_bhvHiddenStarTrigger) ::
 (_bhv1UpSliding, Gvar v_bhv1UpSliding) :: (_bhv1Up, Gvar v_bhv1Up) ::
 (_bhv1UpJumpOnApproach, Gvar v_bhv1UpJumpOnApproach) ::
 (_bhvHidden1Up, Gvar v_bhvHidden1Up) ::
 (_bhvHidden1UpTrigger, Gvar v_bhvHidden1UpTrigger) ::
 (_bhvHidden1UpInPoleSpawner, Gvar v_bhvHidden1UpInPoleSpawner) ::
 (_bhvBreakableBoxSmall, Gvar v_bhvBreakableBoxSmall) ::
 (_bhvKoopa, Gvar v_bhvKoopa) ::
 (_bhvKoopaRaceEndpoint, Gvar v_bhvKoopaRaceEndpoint) ::
 (_bhvPokey, Gvar v_bhvPokey) :: (_bhvSwoop, Gvar v_bhvSwoop) ::
 (_bhvFlyGuy, Gvar v_bhvFlyGuy) :: (_bhvGoomba, Gvar v_bhvGoomba) ::
 (_bhvGoombaTripletSpawner, Gvar v_bhvGoombaTripletSpawner) ::
 (_bhvChainChomp, Gvar v_bhvChainChomp) ::
 (_bhvWoodenPost, Gvar v_bhvWoodenPost) ::
 (_bhvWigglerHead, Gvar v_bhvWigglerHead) ::
 (_bhvEnemyLakitu, Gvar v_bhvEnemyLakitu) ::
 (_bhvMontyMole, Gvar v_bhvMontyMole) ::
 (_bhvMontyMoleHole, Gvar v_bhvMontyMoleHole) ::
 (_bhvSeesawPlatform, Gvar v_bhvSeesawPlatform) ::
 (_bhvFerrisWheelAxle, Gvar v_bhvFerrisWheelAxle) ::
 (_bhvWaterBombSpawner, Gvar v_bhvWaterBombSpawner) ::
 (_bhvTTCRotatingSolid, Gvar v_bhvTTCRotatingSolid) ::
 (_bhvTTCPendulum, Gvar v_bhvTTCPendulum) ::
 (_bhvTTCTreadmill, Gvar v_bhvTTCTreadmill) ::
 (_bhvTTCMovingBar, Gvar v_bhvTTCMovingBar) ::
 (_bhvTTCCog, Gvar v_bhvTTCCog) ::
 (_bhvTTCPitBlock, Gvar v_bhvTTCPitBlock) ::
 (_bhvTTCElevator, Gvar v_bhvTTCElevator) ::
 (_bhvTTC2DRotator, Gvar v_bhvTTC2DRotator) ::
 (_bhvTTCSpinner, Gvar v_bhvTTCSpinner) ::
 (_bhvMrBlizzard, Gvar v_bhvMrBlizzard) ::
 (_bhvSlidingPlatform2, Gvar v_bhvSlidingPlatform2) ::
 (_bhvOctagonalPlatformRotating, Gvar v_bhvOctagonalPlatformRotating) ::
 (_bhvAnimatesOnFloorSwitchPress, Gvar v_bhvAnimatesOnFloorSwitchPress) ::
 (_bhvActivatedBackAndForthPlatform, Gvar v_bhvActivatedBackAndForthPlatform) ::
 (_bhvRecoveryHeart, Gvar v_bhvRecoveryHeart) ::
 (_bhvWaterBombCannon, Gvar v_bhvWaterBombCannon) ::
 (_bhvUnagi, Gvar v_bhvUnagi) ::
 (_bhvHauntedChair, Gvar v_bhvHauntedChair) ::
 (_bhvFirePiranhaPlant, Gvar v_bhvFirePiranhaPlant) ::
 (_bhvFireSpitter, Gvar v_bhvFireSpitter) ::
 (_bhvSnufit, Gvar v_bhvSnufit) :: (_bhvClamShell, Gvar v_bhvClamShell) ::
 (_bhvSkeeter, Gvar v_bhvSkeeter) ::
 (_bhvTripletButterfly, Gvar v_bhvTripletButterfly) ::
 (_bhvUnusedFakeStar, Gvar v_bhvUnusedFakeStar) ::
 (_sMacroObjectPresets, Gvar v_sMacroObjectPresets) ::
 (_sSpecialObjectPresets, Gvar v_sSpecialObjectPresets) ::
 (_convert_rotation, Gfun(Internal f_convert_rotation)) ::
 (_spawn_macro_abs_yrot_2params, Gfun(Internal f_spawn_macro_abs_yrot_2params)) ::
 (_spawn_macro_abs_yrot_param1, Gfun(Internal f_spawn_macro_abs_yrot_param1)) ::
 (_spawn_macro_abs_special, Gfun(Internal f_spawn_macro_abs_special)) ::
 (_spawn_macro_objects, Gfun(Internal f_spawn_macro_objects)) ::
 (_spawn_macro_objects_hardcoded, Gfun(Internal f_spawn_macro_objects_hardcoded)) ::
 (_spawn_special_objects, Gfun(Internal f_spawn_special_objects)) :: nil).

Definition public_idents : list ident :=
(_spawn_special_objects :: _spawn_macro_objects_hardcoded ::
 _spawn_macro_objects :: _spawn_macro_abs_special ::
 _spawn_macro_abs_yrot_param1 :: _spawn_macro_abs_yrot_2params ::
 _convert_rotation :: _bhvUnusedFakeStar :: _bhvTripletButterfly ::
 _bhvSkeeter :: _bhvClamShell :: _bhvSnufit :: _bhvFireSpitter ::
 _bhvFirePiranhaPlant :: _bhvHauntedChair :: _bhvUnagi ::
 _bhvWaterBombCannon :: _bhvRecoveryHeart ::
 _bhvActivatedBackAndForthPlatform :: _bhvAnimatesOnFloorSwitchPress ::
 _bhvOctagonalPlatformRotating :: _bhvSlidingPlatform2 :: _bhvMrBlizzard ::
 _bhvTTCSpinner :: _bhvTTC2DRotator :: _bhvTTCElevator :: _bhvTTCPitBlock ::
 _bhvTTCCog :: _bhvTTCMovingBar :: _bhvTTCTreadmill :: _bhvTTCPendulum ::
 _bhvTTCRotatingSolid :: _bhvWaterBombSpawner :: _bhvFerrisWheelAxle ::
 _bhvSeesawPlatform :: _bhvMontyMoleHole :: _bhvMontyMole ::
 _bhvEnemyLakitu :: _bhvWigglerHead :: _bhvWoodenPost :: _bhvChainChomp ::
 _bhvGoombaTripletSpawner :: _bhvGoomba :: _bhvFlyGuy :: _bhvSwoop ::
 _bhvPokey :: _bhvKoopaRaceEndpoint :: _bhvKoopa :: _bhvBreakableBoxSmall ::
 _bhvHidden1UpInPoleSpawner :: _bhvHidden1UpTrigger :: _bhvHidden1Up ::
 _bhv1UpJumpOnApproach :: _bhv1Up :: _bhv1UpSliding ::
 _bhvHiddenStarTrigger :: _bhvRedCoin :: _bhvFreeBowlingBall ::
 _bhvMoneybagHidden :: _bhvWFSlidingPlatform :: _bhvLargeBomp ::
 _bhvSmallBomp :: _bhvLLLDrawbridgeSpawner :: _bhvBowserBomb ::
 _bhvJetStreamRingSpawner :: _bhvBigBully :: _bhvSmallBully ::
 _bhvCarrySomething1 :: _bhvButterfly :: _bhvCirclingAmp :: _bhvHomingAmp ::
 _bhvSignOnWall :: _bhvMessagePanel :: _bhvCannonClosed ::
 _bhvBobombBuddyOpensCannon :: _bhvBobomb :: _bhvSeaweedBundle ::
 _bhvBlueCoinSliding :: _bhvMovingBlueCoin :: _bhvSmallWhomp ::
 _bhvScuttlebugSpawn :: _bhvScuttlebug :: _bhvTree :: _bhvCastleFloorTrap ::
 _bhvStaticObject :: _bhvMeshElevator :: _bhvHauntedBookshelf ::
 _bhvBBHTiltingTrapPlatform :: _bhvBooStaircase :: _bhvGhostHuntBoo ::
 _bhvCourtyardBooTriplet :: _bhvBooWithCage :: _bhvTweester ::
 _bhvWaterLevelDiamond :: _bhvHiddenBlueCoin :: _bhvBlueCoinSwitch ::
 _bhvSushiShark :: _bhvExclamationBox :: _bhvChirpChirp :: _bhvFishSpawner ::
 _bhvSmallPenguin :: _bhvTuxiesMother :: _bhvLLLBowserPuzzle ::
 _bhvPiranhaPlant :: _bhvToxBox :: _bhvLLLTiltingInvertedPyramid ::
 _bhvLLLSinkingSquarePlatforms :: _bhvLLLSinkingRectangularPlatform ::
 _bhvLLLRotatingHexagonalRing :: _bhvLLLFloatingWoodBridge ::
 _bhvLLLRotatingBlockWithFireBars :: _bhvSnowBall ::
 _bhvLLLMovingOctagonalMeshPlatform :: _bhvStub1D0C :: _bhvMacroUkiki ::
 _bhvBowser :: _bhvBulletBill :: _bhvAlphaBooKey :: _bhvJumpingBox ::
 _bhvBetaTrampolineTop :: _bhvHeaveHo :: _bhvPushableMetalBox ::
 _bhvBreakableBox :: _bhvHiddenObject :: _bhvFloorSwitchHiddenObjects ::
 _bhvAnotherTiltingPlatform :: _bhvTowerPlatformGroup :: _bhvSpindrift ::
 _bhvBetaFishSplashSpawner :: _bhvBouncingFireball :: _bhvFlamethrower ::
 _bhvLLLTumblingBridge :: _bhvBBHTumblingBridge :: _bhvTumblingBridge ::
 _bhvThwomp :: _bhvDoor :: _bhvDoorWarp :: _bhvYellowCoin :: _bhvOneCoin ::
 _bhvCoinFormation :: _bhvKoopaShellUnderwater ::
 _bhvWFRotatingWoodenPlatform :: _bhvRotatingCounterClockwise ::
 _bhvChuckya :: _bhvCannon :: _bhvBetaChestBottom :: _bhvCapSwitch ::
 _bhvMrI :: _gMacroObjectDefaultParent :: _spawn_object_abs_with_rot ::
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
