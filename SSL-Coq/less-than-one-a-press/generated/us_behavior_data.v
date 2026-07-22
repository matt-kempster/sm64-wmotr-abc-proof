(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_US
   Source:          data/behavior_data.c
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
  Definition source_file := "build/pinned-sm64/data/behavior_data.c".
  Definition normalized := true.
End Info.

Definition _Animation : ident := $"Animation".
Definition _WaterDropletParams : ident := $"WaterDropletParams".
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
Definition _animYTransDivisor : ident := $"animYTransDivisor".
Definition _bbh_seg7_collision_coffin : ident := $"bbh_seg7_collision_coffin".
Definition _bbh_seg7_collision_haunted_bookshelf : ident := $"bbh_seg7_collision_haunted_bookshelf".
Definition _bbh_seg7_collision_merry_go_round : ident := $"bbh_seg7_collision_merry_go_round".
Definition _bbh_seg7_collision_mesh_elevator : ident := $"bbh_seg7_collision_mesh_elevator".
Definition _bbh_seg7_collision_staircase_step : ident := $"bbh_seg7_collision_staircase_step".
Definition _bbh_seg7_collision_tilt_floor_platform : ident := $"bbh_seg7_collision_tilt_floor_platform".
Definition _beh_yellow_background_menu_init : ident := $"beh_yellow_background_menu_init".
Definition _beh_yellow_background_menu_loop : ident := $"beh_yellow_background_menu_loop".
Definition _behavior : ident := $"behavior".
Definition _bhv1Up : ident := $"bhv1Up".
Definition _bhv1UpJumpOnApproach : ident := $"bhv1UpJumpOnApproach".
Definition _bhv1UpRunningAway : ident := $"bhv1UpRunningAway".
Definition _bhv1UpSliding : ident := $"bhv1UpSliding".
Definition _bhv1UpWalking : ident := $"bhv1UpWalking".
Definition _bhvActSelector : ident := $"bhvActSelector".
Definition _bhvActSelectorStarType : ident := $"bhvActSelectorStarType".
Definition _bhvActivatedBackAndForthPlatform : ident := $"bhvActivatedBackAndForthPlatform".
Definition _bhvAirborneDeathWarp : ident := $"bhvAirborneDeathWarp".
Definition _bhvAirborneStarCollectWarp : ident := $"bhvAirborneStarCollectWarp".
Definition _bhvAirborneWarp : ident := $"bhvAirborneWarp".
Definition _bhvAlphaBooKey : ident := $"bhvAlphaBooKey".
Definition _bhvAmbientSounds : ident := $"bhvAmbientSounds".
Definition _bhvAnimatedTexture : ident := $"bhvAnimatedTexture".
Definition _bhvAnimatesOnFloorSwitchPress : ident := $"bhvAnimatesOnFloorSwitchPress".
Definition _bhvAnotherElavator : ident := $"bhvAnotherElavator".
Definition _bhvAnotherTiltingPlatform : ident := $"bhvAnotherTiltingPlatform".
Definition _bhvArrowLift : ident := $"bhvArrowLift".
Definition _bhvBBHTiltingTrapPlatform : ident := $"bhvBBHTiltingTrapPlatform".
Definition _bhvBBHTumblingBridge : ident := $"bhvBBHTumblingBridge".
Definition _bhvBalconyBigBoo : ident := $"bhvBalconyBigBoo".
Definition _bhvBeginningLakitu : ident := $"bhvBeginningLakitu".
Definition _bhvBeginningPeach : ident := $"bhvBeginningPeach".
Definition _bhvBetaBooKey : ident := $"bhvBetaBooKey".
Definition _bhvBetaBowserAnchor : ident := $"bhvBetaBowserAnchor".
Definition _bhvBetaChestBottom : ident := $"bhvBetaChestBottom".
Definition _bhvBetaChestLid : ident := $"bhvBetaChestLid".
Definition _bhvBetaFishSplashSpawner : ident := $"bhvBetaFishSplashSpawner".
Definition _bhvBetaHoldableObject : ident := $"bhvBetaHoldableObject".
Definition _bhvBetaMovingFlames : ident := $"bhvBetaMovingFlames".
Definition _bhvBetaMovingFlamesSpawn : ident := $"bhvBetaMovingFlamesSpawn".
Definition _bhvBetaTrampolineSpring : ident := $"bhvBetaTrampolineSpring".
Definition _bhvBetaTrampolineTop : ident := $"bhvBetaTrampolineTop".
Definition _bhvBigBoulder : ident := $"bhvBigBoulder".
Definition _bhvBigBoulderGenerator : ident := $"bhvBigBoulderGenerator".
Definition _bhvBigBully : ident := $"bhvBigBully".
Definition _bhvBigBullyWithMinions : ident := $"bhvBigBullyWithMinions".
Definition _bhvBigChillBully : ident := $"bhvBigChillBully".
Definition _bhvBigSnowmanWhole : ident := $"bhvBigSnowmanWhole".
Definition _bhvBird : ident := $"bhvBird".
Definition _bhvBirdsSoundLoop : ident := $"bhvBirdsSoundLoop".
Definition _bhvBitFSSinkingCagePlatform : ident := $"bhvBitFSSinkingCagePlatform".
Definition _bhvBitFSSinkingPlatforms : ident := $"bhvBitFSSinkingPlatforms".
Definition _bhvBitFSTiltingInvertedPyramid : ident := $"bhvBitFSTiltingInvertedPyramid".
Definition _bhvBlackSmokeBowser : ident := $"bhvBlackSmokeBowser".
Definition _bhvBlackSmokeMario : ident := $"bhvBlackSmokeMario".
Definition _bhvBlackSmokeUpward : ident := $"bhvBlackSmokeUpward".
Definition _bhvBlueBowserFlame : ident := $"bhvBlueBowserFlame".
Definition _bhvBlueCoinJumping : ident := $"bhvBlueCoinJumping".
Definition _bhvBlueCoinSliding : ident := $"bhvBlueCoinSliding".
Definition _bhvBlueCoinSwitch : ident := $"bhvBlueCoinSwitch".
Definition _bhvBlueFish : ident := $"bhvBlueFish".
Definition _bhvBlueFlamesGroup : ident := $"bhvBlueFlamesGroup".
Definition _bhvBoBBowlingBallSpawner : ident := $"bhvBoBBowlingBallSpawner".
Definition _bhvBobomb : ident := $"bhvBobomb".
Definition _bhvBobombAnchorMario : ident := $"bhvBobombAnchorMario".
Definition _bhvBobombBuddy : ident := $"bhvBobombBuddy".
Definition _bhvBobombBuddyOpensCannon : ident := $"bhvBobombBuddyOpensCannon".
Definition _bhvBobombBullyDeathSmoke : ident := $"bhvBobombBullyDeathSmoke".
Definition _bhvBobombExplosionBubble : ident := $"bhvBobombExplosionBubble".
Definition _bhvBobombExplosionBubble3600 : ident := $"bhvBobombExplosionBubble3600".
Definition _bhvBobombFuseSmoke : ident := $"bhvBobombFuseSmoke".
Definition _bhvBoo : ident := $"bhvBoo".
Definition _bhvBooCage : ident := $"bhvBooCage".
Definition _bhvBooInCastle : ident := $"bhvBooInCastle".
Definition _bhvBooStaircase : ident := $"bhvBooStaircase".
Definition _bhvBooWithCage : ident := $"bhvBooWithCage".
Definition _bhvBookSwitch : ident := $"bhvBookSwitch".
Definition _bhvBookendSpawn : ident := $"bhvBookendSpawn".
Definition _bhvBouncingFireball : ident := $"bhvBouncingFireball".
Definition _bhvBouncingFireballFlame : ident := $"bhvBouncingFireballFlame".
Definition _bhvBowlingBall : ident := $"bhvBowlingBall".
Definition _bhvBowser : ident := $"bhvBowser".
Definition _bhvBowserBodyAnchor : ident := $"bhvBowserBodyAnchor".
Definition _bhvBowserBomb : ident := $"bhvBowserBomb".
Definition _bhvBowserBombExplosion : ident := $"bhvBowserBombExplosion".
Definition _bhvBowserBombSmoke : ident := $"bhvBowserBombSmoke".
Definition _bhvBowserCourseRedCoinStar : ident := $"bhvBowserCourseRedCoinStar".
Definition _bhvBowserFlameSpawn : ident := $"bhvBowserFlameSpawn".
Definition _bhvBowserKey : ident := $"bhvBowserKey".
Definition _bhvBowserKeyCourseExit : ident := $"bhvBowserKeyCourseExit".
Definition _bhvBowserKeyUnlockDoor : ident := $"bhvBowserKeyUnlockDoor".
Definition _bhvBowserShockWave : ident := $"bhvBowserShockWave".
Definition _bhvBowserSubDoor : ident := $"bhvBowserSubDoor".
Definition _bhvBowserTailAnchor : ident := $"bhvBowserTailAnchor".
Definition _bhvBowsersSub : ident := $"bhvBowsersSub".
Definition _bhvBreakBoxTriangle : ident := $"bhvBreakBoxTriangle".
Definition _bhvBreakableBox : ident := $"bhvBreakableBox".
Definition _bhvBreakableBoxSmall : ident := $"bhvBreakableBoxSmall".
Definition _bhvBreathParticleSpawner : ident := $"bhvBreathParticleSpawner".
Definition _bhvBub : ident := $"bhvBub".
Definition _bhvBubba : ident := $"bhvBubba".
Definition _bhvBubbleMaybe : ident := $"bhvBubbleMaybe".
Definition _bhvBubbleParticleSpawner : ident := $"bhvBubbleParticleSpawner".
Definition _bhvBubbleSplash : ident := $"bhvBubbleSplash".
Definition _bhvBulletBill : ident := $"bhvBulletBill".
Definition _bhvBulletBillCannon : ident := $"bhvBulletBillCannon".
Definition _bhvButterfly : ident := $"bhvButterfly".
Definition _bhvCCMTouchedStarSpawn : ident := $"bhvCCMTouchedStarSpawn".
Definition _bhvCameraLakitu : ident := $"bhvCameraLakitu".
Definition _bhvCannon : ident := $"bhvCannon".
Definition _bhvCannonBarrel : ident := $"bhvCannonBarrel".
Definition _bhvCannonBarrelBubbles : ident := $"bhvCannonBarrelBubbles".
Definition _bhvCannonBaseUnused : ident := $"bhvCannonBaseUnused".
Definition _bhvCannonClosed : ident := $"bhvCannonClosed".
Definition _bhvCapSwitch : ident := $"bhvCapSwitch".
Definition _bhvCapSwitchBase : ident := $"bhvCapSwitchBase".
Definition _bhvCarrySomething1 : ident := $"bhvCarrySomething1".
Definition _bhvCarrySomething2 : ident := $"bhvCarrySomething2".
Definition _bhvCarrySomething3 : ident := $"bhvCarrySomething3".
Definition _bhvCarrySomething4 : ident := $"bhvCarrySomething4".
Definition _bhvCarrySomething5 : ident := $"bhvCarrySomething5".
Definition _bhvCarrySomething6 : ident := $"bhvCarrySomething6".
Definition _bhvCastleFlagWaving : ident := $"bhvCastleFlagWaving".
Definition _bhvCastleFloorTrap : ident := $"bhvCastleFloorTrap".
Definition _bhvCelebrationStar : ident := $"bhvCelebrationStar".
Definition _bhvCelebrationStarSparkle : ident := $"bhvCelebrationStarSparkle".
Definition _bhvChainChomp : ident := $"bhvChainChomp".
Definition _bhvChainChompChainPart : ident := $"bhvChainChompChainPart".
Definition _bhvChainChompGate : ident := $"bhvChainChompGate".
Definition _bhvCheckerboardElevatorGroup : ident := $"bhvCheckerboardElevatorGroup".
Definition _bhvCheckerboardPlatformSub : ident := $"bhvCheckerboardPlatformSub".
Definition _bhvChirpChirp : ident := $"bhvChirpChirp".
Definition _bhvChirpChirpUnused : ident := $"bhvChirpChirpUnused".
Definition _bhvChuckya : ident := $"bhvChuckya".
Definition _bhvChuckyaAnchorMario : ident := $"bhvChuckyaAnchorMario".
Definition _bhvCirclingAmp : ident := $"bhvCirclingAmp".
Definition _bhvClamShell : ident := $"bhvClamShell".
Definition _bhvClockHourHand : ident := $"bhvClockHourHand".
Definition _bhvClockMinuteHand : ident := $"bhvClockMinuteHand".
Definition _bhvCloud : ident := $"bhvCloud".
Definition _bhvCloudPart : ident := $"bhvCloudPart".
Definition _bhvCoffin : ident := $"bhvCoffin".
Definition _bhvCoffinSpawner : ident := $"bhvCoffinSpawner".
Definition _bhvCoinFormation : ident := $"bhvCoinFormation".
Definition _bhvCoinFormationSpawn : ident := $"bhvCoinFormationSpawn".
Definition _bhvCoinInsideBoo : ident := $"bhvCoinInsideBoo".
Definition _bhvCoinSparkles : ident := $"bhvCoinSparkles".
Definition _bhvControllablePlatform : ident := $"bhvControllablePlatform".
Definition _bhvControllablePlatformSub : ident := $"bhvControllablePlatformSub".
Definition _bhvCourtyardBooTriplet : ident := $"bhvCourtyardBooTriplet".
Definition _bhvCutOutObject : ident := $"bhvCutOutObject".
Definition _bhvDDDMovingPole : ident := $"bhvDDDMovingPole".
Definition _bhvDDDPole : ident := $"bhvDDDPole".
Definition _bhvDDDWarp : ident := $"bhvDDDWarp".
Definition _bhvDeathWarp : ident := $"bhvDeathWarp".
Definition _bhvDecorativePendulum : ident := $"bhvDecorativePendulum".
Definition _bhvDirtParticleSpawner : ident := $"bhvDirtParticleSpawner".
Definition _bhvDonutPlatform : ident := $"bhvDonutPlatform".
Definition _bhvDonutPlatformSpawner : ident := $"bhvDonutPlatformSpawner".
Definition _bhvDoor : ident := $"bhvDoor".
Definition _bhvDoorWarp : ident := $"bhvDoorWarp".
Definition _bhvDorrie : ident := $"bhvDorrie".
Definition _bhvEndBirds1 : ident := $"bhvEndBirds1".
Definition _bhvEndBirds2 : ident := $"bhvEndBirds2".
Definition _bhvEndPeach : ident := $"bhvEndPeach".
Definition _bhvEndToad : ident := $"bhvEndToad".
Definition _bhvEnemyLakitu : ident := $"bhvEnemyLakitu".
Definition _bhvExclamationBox : ident := $"bhvExclamationBox".
Definition _bhvExitPodiumWarp : ident := $"bhvExitPodiumWarp".
Definition _bhvExplosion : ident := $"bhvExplosion".
Definition _bhvEyerokBoss : ident := $"bhvEyerokBoss".
Definition _bhvEyerokHand : ident := $"bhvEyerokHand".
Definition _bhvFadingWarp : ident := $"bhvFadingWarp".
Definition _bhvFallingBowserPlatform : ident := $"bhvFallingBowserPlatform".
Definition _bhvFallingPillar : ident := $"bhvFallingPillar".
Definition _bhvFallingPillarHitbox : ident := $"bhvFallingPillarHitbox".
Definition _bhvFerrisWheelAxle : ident := $"bhvFerrisWheelAxle".
Definition _bhvFerrisWheelPlatform : ident := $"bhvFerrisWheelPlatform".
Definition _bhvFewBlueFishSpawner : ident := $"bhvFewBlueFishSpawner".
Definition _bhvFireParticleSpawner : ident := $"bhvFireParticleSpawner".
Definition _bhvFirePiranhaPlant : ident := $"bhvFirePiranhaPlant".
Definition _bhvFireSpitter : ident := $"bhvFireSpitter".
Definition _bhvFish : ident := $"bhvFish".
Definition _bhvFishGroup : ident := $"bhvFishGroup".
Definition _bhvFishSpawner : ident := $"bhvFishSpawner".
Definition _bhvFlame : ident := $"bhvFlame".
Definition _bhvFlameBouncing : ident := $"bhvFlameBouncing".
Definition _bhvFlameBowser : ident := $"bhvFlameBowser".
Definition _bhvFlameFloatingLanding : ident := $"bhvFlameFloatingLanding".
Definition _bhvFlameLargeBurningOut : ident := $"bhvFlameLargeBurningOut".
Definition _bhvFlameMovingForwardGrowing : ident := $"bhvFlameMovingForwardGrowing".
Definition _bhvFlamethrower : ident := $"bhvFlamethrower".
Definition _bhvFlamethrowerFlame : ident := $"bhvFlamethrowerFlame".
Definition _bhvFloorSwitchAnimatesObject : ident := $"bhvFloorSwitchAnimatesObject".
Definition _bhvFloorSwitchGrills : ident := $"bhvFloorSwitchGrills".
Definition _bhvFloorSwitchHardcodedModel : ident := $"bhvFloorSwitchHardcodedModel".
Definition _bhvFloorSwitchHiddenObjects : ident := $"bhvFloorSwitchHiddenObjects".
Definition _bhvFloorTrapInCastle : ident := $"bhvFloorTrapInCastle".
Definition _bhvFlyGuy : ident := $"bhvFlyGuy".
Definition _bhvFlyguyFlame : ident := $"bhvFlyguyFlame".
Definition _bhvFlyingBookend : ident := $"bhvFlyingBookend".
Definition _bhvFlyingWarp : ident := $"bhvFlyingWarp".
Definition _bhvFreeBowlingBall : ident := $"bhvFreeBowlingBall".
Definition _bhvGhostHuntBigBoo : ident := $"bhvGhostHuntBigBoo".
Definition _bhvGhostHuntBoo : ident := $"bhvGhostHuntBoo".
Definition _bhvGiantPole : ident := $"bhvGiantPole".
Definition _bhvGoldenCoinSparkles : ident := $"bhvGoldenCoinSparkles".
Definition _bhvGoomba : ident := $"bhvGoomba".
Definition _bhvGoombaTripletSpawner : ident := $"bhvGoombaTripletSpawner".
Definition _bhvGrandStar : ident := $"bhvGrandStar".
Definition _bhvGrindel : ident := $"bhvGrindel".
Definition _bhvHMCElevatorPlatform : ident := $"bhvHMCElevatorPlatform".
Definition _bhvHardAirKnockBackWarp : ident := $"bhvHardAirKnockBackWarp".
Definition _bhvHauntedBookshelf : ident := $"bhvHauntedBookshelf".
Definition _bhvHauntedBookshelfManager : ident := $"bhvHauntedBookshelfManager".
Definition _bhvHauntedChair : ident := $"bhvHauntedChair".
Definition _bhvHeaveHo : ident := $"bhvHeaveHo".
Definition _bhvHeaveHoThrowMario : ident := $"bhvHeaveHoThrowMario".
Definition _bhvHidden1Up : ident := $"bhvHidden1Up".
Definition _bhvHidden1UpInPole : ident := $"bhvHidden1UpInPole".
Definition _bhvHidden1UpInPoleSpawner : ident := $"bhvHidden1UpInPoleSpawner".
Definition _bhvHidden1UpInPoleTrigger : ident := $"bhvHidden1UpInPoleTrigger".
Definition _bhvHidden1UpTrigger : ident := $"bhvHidden1UpTrigger".
Definition _bhvHiddenAt120Stars : ident := $"bhvHiddenAt120Stars".
Definition _bhvHiddenBlueCoin : ident := $"bhvHiddenBlueCoin".
Definition _bhvHiddenObject : ident := $"bhvHiddenObject".
Definition _bhvHiddenRedCoinStar : ident := $"bhvHiddenRedCoinStar".
Definition _bhvHiddenStaircaseStep : ident := $"bhvHiddenStaircaseStep".
Definition _bhvHiddenStar : ident := $"bhvHiddenStar".
Definition _bhvHiddenStarTrigger : ident := $"bhvHiddenStarTrigger".
Definition _bhvHomingAmp : ident := $"bhvHomingAmp".
Definition _bhvHoot : ident := $"bhvHoot".
Definition _bhvHorStarParticleSpawner : ident := $"bhvHorStarParticleSpawner".
Definition _bhvHorizontalGrindel : ident := $"bhvHorizontalGrindel".
Definition _bhvIdleWaterWave : ident := $"bhvIdleWaterWave".
Definition _bhvIgloo : ident := $"bhvIgloo".
Definition _bhvInSunkenShip : ident := $"bhvInSunkenShip".
Definition _bhvInSunkenShip2 : ident := $"bhvInSunkenShip2".
Definition _bhvInSunkenShip3 : ident := $"bhvInSunkenShip3".
Definition _bhvInitializeChangingWaterLevel : ident := $"bhvInitializeChangingWaterLevel".
Definition _bhvInsideCannon : ident := $"bhvInsideCannon".
Definition _bhvInstantActiveWarp : ident := $"bhvInstantActiveWarp".
Definition _bhvIntroScene : ident := $"bhvIntroScene".
Definition _bhvInvisibleObjectsUnderBridge : ident := $"bhvInvisibleObjectsUnderBridge".
Definition _bhvJRBFloatingBox : ident := $"bhvJRBFloatingBox".
Definition _bhvJRBFloatingPlatform : ident := $"bhvJRBFloatingPlatform".
Definition _bhvJRBSlidingBox : ident := $"bhvJRBSlidingBox".
Definition _bhvJetStream : ident := $"bhvJetStream".
Definition _bhvJetStreamRingSpawner : ident := $"bhvJetStreamRingSpawner".
Definition _bhvJetStreamWaterRing : ident := $"bhvJetStreamWaterRing".
Definition _bhvJumpingBox : ident := $"bhvJumpingBox".
Definition _bhvKickableBoard : ident := $"bhvKickableBoard".
Definition _bhvKingBobomb : ident := $"bhvKingBobomb".
Definition _bhvKlepto : ident := $"bhvKlepto".
Definition _bhvKoopa : ident := $"bhvKoopa".
Definition _bhvKoopaFlag : ident := $"bhvKoopaFlag".
Definition _bhvKoopaRaceEndpoint : ident := $"bhvKoopaRaceEndpoint".
Definition _bhvKoopaShell : ident := $"bhvKoopaShell".
Definition _bhvKoopaShellFlame : ident := $"bhvKoopaShellFlame".
Definition _bhvKoopaShellUnderwater : ident := $"bhvKoopaShellUnderwater".
Definition _bhvLLLBowserPuzzle : ident := $"bhvLLLBowserPuzzle".
Definition _bhvLLLBowserPuzzlePiece : ident := $"bhvLLLBowserPuzzlePiece".
Definition _bhvLLLDrawbridge : ident := $"bhvLLLDrawbridge".
Definition _bhvLLLDrawbridgeSpawner : ident := $"bhvLLLDrawbridgeSpawner".
Definition _bhvLLLFloatingWoodBridge : ident := $"bhvLLLFloatingWoodBridge".
Definition _bhvLLLHexagonalMesh : ident := $"bhvLLLHexagonalMesh".
Definition _bhvLLLMovingOctagonalMeshPlatform : ident := $"bhvLLLMovingOctagonalMeshPlatform".
Definition _bhvLLLRollingLog : ident := $"bhvLLLRollingLog".
Definition _bhvLLLRotatingBlockWithFireBars : ident := $"bhvLLLRotatingBlockWithFireBars".
Definition _bhvLLLRotatingHexFlame : ident := $"bhvLLLRotatingHexFlame".
Definition _bhvLLLRotatingHexagonalPlatform : ident := $"bhvLLLRotatingHexagonalPlatform".
Definition _bhvLLLRotatingHexagonalRing : ident := $"bhvLLLRotatingHexagonalRing".
Definition _bhvLLLSinkingRectangularPlatform : ident := $"bhvLLLSinkingRectangularPlatform".
Definition _bhvLLLSinkingRockBlock : ident := $"bhvLLLSinkingRockBlock".
Definition _bhvLLLSinkingSquarePlatforms : ident := $"bhvLLLSinkingSquarePlatforms".
Definition _bhvLLLTiltingInvertedPyramid : ident := $"bhvLLLTiltingInvertedPyramid".
Definition _bhvLLLTumblingBridge : ident := $"bhvLLLTumblingBridge".
Definition _bhvLLLVolcanoFallingTrap : ident := $"bhvLLLVolcanoFallingTrap".
Definition _bhvLLLWoodPiece : ident := $"bhvLLLWoodPiece".
Definition _bhvLargeBomp : ident := $"bhvLargeBomp".
Definition _bhvLaunchDeathWarp : ident := $"bhvLaunchDeathWarp".
Definition _bhvLaunchStarCollectWarp : ident := $"bhvLaunchStarCollectWarp".
Definition _bhvLeafParticleSpawner : ident := $"bhvLeafParticleSpawner".
Definition _bhvMacroUkiki : ident := $"bhvMacroUkiki".
Definition _bhvMadPiano : ident := $"bhvMadPiano".
Definition _bhvMantaRay : ident := $"bhvMantaRay".
Definition _bhvMantaRayRingManager : ident := $"bhvMantaRayRingManager".
Definition _bhvMantaRayWaterRing : ident := $"bhvMantaRayWaterRing".
Definition _bhvManyBlueFishSpawner : ident := $"bhvManyBlueFishSpawner".
Definition _bhvMario : ident := $"bhvMario".
Definition _bhvMenuButton : ident := $"bhvMenuButton".
Definition _bhvMenuButtonManager : ident := $"bhvMenuButtonManager".
Definition _bhvMerryGoRound : ident := $"bhvMerryGoRound".
Definition _bhvMerryGoRoundBigBoo : ident := $"bhvMerryGoRoundBigBoo".
Definition _bhvMerryGoRoundBoo : ident := $"bhvMerryGoRoundBoo".
Definition _bhvMerryGoRoundBooManager : ident := $"bhvMerryGoRoundBooManager".
Definition _bhvMeshElevator : ident := $"bhvMeshElevator".
Definition _bhvMessagePanel : ident := $"bhvMessagePanel".
Definition _bhvMetalCap : ident := $"bhvMetalCap".
Definition _bhvMips : ident := $"bhvMips".
Definition _bhvMistCircParticleSpawner : ident := $"bhvMistCircParticleSpawner".
Definition _bhvMistParticleSpawner : ident := $"bhvMistParticleSpawner".
Definition _bhvMoatGrills : ident := $"bhvMoatGrills".
Definition _bhvMoneybag : ident := $"bhvMoneybag".
Definition _bhvMoneybagHidden : ident := $"bhvMoneybagHidden".
Definition _bhvMontyMole : ident := $"bhvMontyMole".
Definition _bhvMontyMoleHole : ident := $"bhvMontyMoleHole".
Definition _bhvMontyMoleRock : ident := $"bhvMontyMoleRock".
Definition _bhvMovingBlueCoin : ident := $"bhvMovingBlueCoin".
Definition _bhvMovingYellowCoin : ident := $"bhvMovingYellowCoin".
Definition _bhvMrBlizzard : ident := $"bhvMrBlizzard".
Definition _bhvMrBlizzardSnowball : ident := $"bhvMrBlizzardSnowball".
Definition _bhvMrI : ident := $"bhvMrI".
Definition _bhvMrIBody : ident := $"bhvMrIBody".
Definition _bhvMrIParticle : ident := $"bhvMrIParticle".
Definition _bhvNormalCap : ident := $"bhvNormalCap".
Definition _bhvObjectBubble : ident := $"bhvObjectBubble".
Definition _bhvObjectWaterSplash : ident := $"bhvObjectWaterSplash".
Definition _bhvObjectWaterWave : ident := $"bhvObjectWaterWave".
Definition _bhvObjectWaveTrail : ident := $"bhvObjectWaveTrail".
Definition _bhvOctagonalPlatformRotating : ident := $"bhvOctagonalPlatformRotating".
Definition _bhvOneCoin : ident := $"bhvOneCoin".
Definition _bhvOpenableCageDoor : ident := $"bhvOpenableCageDoor".
Definition _bhvOpenableGrill : ident := $"bhvOpenableGrill".
Definition _bhvOrangeNumber : ident := $"bhvOrangeNumber".
Definition _bhvPaintingDeathWarp : ident := $"bhvPaintingDeathWarp".
Definition _bhvPaintingStarCollectWarp : ident := $"bhvPaintingStarCollectWarp".
Definition _bhvPenguinBaby : ident := $"bhvPenguinBaby".
Definition _bhvPenguinRaceFinishLine : ident := $"bhvPenguinRaceFinishLine".
Definition _bhvPenguinRaceShortcutCheck : ident := $"bhvPenguinRaceShortcutCheck".
Definition _bhvPillarBase : ident := $"bhvPillarBase".
Definition _bhvPiranhaPlant : ident := $"bhvPiranhaPlant".
Definition _bhvPiranhaPlantBubble : ident := $"bhvPiranhaPlantBubble".
Definition _bhvPiranhaPlantWakingBubbles : ident := $"bhvPiranhaPlantWakingBubbles".
Definition _bhvPitBowlingBall : ident := $"bhvPitBowlingBall".
Definition _bhvPlatformOnTrack : ident := $"bhvPlatformOnTrack".
Definition _bhvPlaysMusicTrackWhenTouched : ident := $"bhvPlaysMusicTrackWhenTouched".
Definition _bhvPlungeBubble : ident := $"bhvPlungeBubble".
Definition _bhvPokey : ident := $"bhvPokey".
Definition _bhvPokeyBodyPart : ident := $"bhvPokeyBodyPart".
Definition _bhvPoleGrabbing : ident := $"bhvPoleGrabbing".
Definition _bhvPoundTinyStarParticle : ident := $"bhvPoundTinyStarParticle".
Definition _bhvPunchTinyTriangle : ident := $"bhvPunchTinyTriangle".
Definition _bhvPurpleParticle : ident := $"bhvPurpleParticle".
Definition _bhvPurpleSwitchHiddenBoxes : ident := $"bhvPurpleSwitchHiddenBoxes".
Definition _bhvPushableMetalBox : ident := $"bhvPushableMetalBox".
Definition _bhvPyramidElevator : ident := $"bhvPyramidElevator".
Definition _bhvPyramidElevatorTrajectoryMarkerBall : ident := $"bhvPyramidElevatorTrajectoryMarkerBall".
Definition _bhvPyramidPillarTouchDetector : ident := $"bhvPyramidPillarTouchDetector".
Definition _bhvPyramidTop : ident := $"bhvPyramidTop".
Definition _bhvPyramidTopFragment : ident := $"bhvPyramidTopFragment".
Definition _bhvRRCruiserWing : ident := $"bhvRRCruiserWing".
Definition _bhvRRElevatorPlatform : ident := $"bhvRRElevatorPlatform".
Definition _bhvRRRotatingBridgePlatform : ident := $"bhvRRRotatingBridgePlatform".
Definition _bhvRacingPenguin : ident := $"bhvRacingPenguin".
Definition _bhvRandomAnimatedTexture : ident := $"bhvRandomAnimatedTexture".
Definition _bhvRecoveryHeart : ident := $"bhvRecoveryHeart".
Definition _bhvRedCoin : ident := $"bhvRedCoin".
Definition _bhvRedCoinStarMarker : ident := $"bhvRedCoinStarMarker".
Definition _bhvRespawner : ident := $"bhvRespawner".
Definition _bhvRockSolid : ident := $"bhvRockSolid".
Definition _bhvRotatingCounterClockwise : ident := $"bhvRotatingCounterClockwise".
Definition _bhvRotatingExclamationMark : ident := $"bhvRotatingExclamationMark".
Definition _bhvRotatingPlatform : ident := $"bhvRotatingPlatform".
Definition _bhvSLSnowmanWind : ident := $"bhvSLSnowmanWind".
Definition _bhvSLWalkingPenguin : ident := $"bhvSLWalkingPenguin".
Definition _bhvSSLMovingPyramidWall : ident := $"bhvSSLMovingPyramidWall".
Definition _bhvSandSoundLoop : ident := $"bhvSandSoundLoop".
Definition _bhvScuttlebug : ident := $"bhvScuttlebug".
Definition _bhvScuttlebugSpawn : ident := $"bhvScuttlebugSpawn".
Definition _bhvSeaweed : ident := $"bhvSeaweed".
Definition _bhvSeaweedBundle : ident := $"bhvSeaweedBundle".
Definition _bhvSeesawPlatform : ident := $"bhvSeesawPlatform".
Definition _bhvShallowWaterSplash : ident := $"bhvShallowWaterSplash".
Definition _bhvShallowWaterWave : ident := $"bhvShallowWaterWave".
Definition _bhvShipPart3 : ident := $"bhvShipPart3".
Definition _bhvSignOnWall : ident := $"bhvSignOnWall".
Definition _bhvSingleCoinGetsSpawned : ident := $"bhvSingleCoinGetsSpawned".
Definition _bhvSkeeter : ident := $"bhvSkeeter".
Definition _bhvSkeeterWave : ident := $"bhvSkeeterWave".
Definition _bhvSlidingPlatform2 : ident := $"bhvSlidingPlatform2".
Definition _bhvSlidingSnowMound : ident := $"bhvSlidingSnowMound".
Definition _bhvSmallBomp : ident := $"bhvSmallBomp".
Definition _bhvSmallBully : ident := $"bhvSmallBully".
Definition _bhvSmallChillBully : ident := $"bhvSmallChillBully".
Definition _bhvSmallParticle : ident := $"bhvSmallParticle".
Definition _bhvSmallParticleBubbles : ident := $"bhvSmallParticleBubbles".
Definition _bhvSmallParticleSnow : ident := $"bhvSmallParticleSnow".
Definition _bhvSmallPenguin : ident := $"bhvSmallPenguin".
Definition _bhvSmallPiranhaFlame : ident := $"bhvSmallPiranhaFlame".
Definition _bhvSmallWaterWave : ident := $"bhvSmallWaterWave".
Definition _bhvSmallWaterWave398 : ident := $"bhvSmallWaterWave398".
Definition _bhvSmallWhomp : ident := $"bhvSmallWhomp".
Definition _bhvSmoke : ident := $"bhvSmoke".
Definition _bhvSnowBall : ident := $"bhvSnowBall".
Definition _bhvSnowMoundSpawn : ident := $"bhvSnowMoundSpawn".
Definition _bhvSnowParticleSpawner : ident := $"bhvSnowParticleSpawner".
Definition _bhvSnowmansBodyCheckpoint : ident := $"bhvSnowmansBodyCheckpoint".
Definition _bhvSnowmansBottom : ident := $"bhvSnowmansBottom".
Definition _bhvSnowmansHead : ident := $"bhvSnowmansHead".
Definition _bhvSnufit : ident := $"bhvSnufit".
Definition _bhvSnufitBalls : ident := $"bhvSnufitBalls".
Definition _bhvSoundSpawner : ident := $"bhvSoundSpawner".
Definition _bhvSparkle : ident := $"bhvSparkle".
Definition _bhvSparkleParticleSpawner : ident := $"bhvSparkleParticleSpawner".
Definition _bhvSparkleSpawn : ident := $"bhvSparkleSpawn".
Definition _bhvSpawnedBlueCoin : ident := $"bhvSpawnedBlueCoin".
Definition _bhvSpawnedStar : ident := $"bhvSpawnedStar".
Definition _bhvSpawnedStarNoLevelExit : ident := $"bhvSpawnedStarNoLevelExit".
Definition _bhvSpinAirborneCircleWarp : ident := $"bhvSpinAirborneCircleWarp".
Definition _bhvSpinAirborneWarp : ident := $"bhvSpinAirborneWarp".
Definition _bhvSpindel : ident := $"bhvSpindel".
Definition _bhvSpindrift : ident := $"bhvSpindrift".
Definition _bhvSpiny : ident := $"bhvSpiny".
Definition _bhvSquarishPathMoving : ident := $"bhvSquarishPathMoving".
Definition _bhvSquishablePlatform : ident := $"bhvSquishablePlatform".
Definition _bhvStar : ident := $"bhvStar".
Definition _bhvStarDoor : ident := $"bhvStarDoor".
Definition _bhvStarKeyCollectionPuffSpawner : ident := $"bhvStarKeyCollectionPuffSpawner".
Definition _bhvStarSpawnCoordinates : ident := $"bhvStarSpawnCoordinates".
Definition _bhvStaticCheckeredPlatform : ident := $"bhvStaticCheckeredPlatform".
Definition _bhvStaticObject : ident := $"bhvStaticObject".
Definition _bhvStrongWindParticle : ident := $"bhvStrongWindParticle".
Definition _bhvStub : ident := $"bhvStub".
Definition _bhvStub1D0C : ident := $"bhvStub1D0C".
Definition _bhvStub1D70 : ident := $"bhvStub1D70".
Definition _bhvSunkenShipPart : ident := $"bhvSunkenShipPart".
Definition _bhvSunkenShipPart2 : ident := $"bhvSunkenShipPart2".
Definition _bhvSunkenShipSetRotation : ident := $"bhvSunkenShipSetRotation".
Definition _bhvSushiShark : ident := $"bhvSushiShark".
Definition _bhvSushiSharkCollisionChild : ident := $"bhvSushiSharkCollisionChild".
Definition _bhvSwimmingWarp : ident := $"bhvSwimmingWarp".
Definition _bhvSwingPlatform : ident := $"bhvSwingPlatform".
Definition _bhvSwoop : ident := $"bhvSwoop".
Definition _bhvTHIBowlingBallSpawner : ident := $"bhvTHIBowlingBallSpawner".
Definition _bhvTHIHugeIslandTop : ident := $"bhvTHIHugeIslandTop".
Definition _bhvTHITinyIslandTop : ident := $"bhvTHITinyIslandTop".
Definition _bhvTTC2DRotator : ident := $"bhvTTC2DRotator".
Definition _bhvTTCCog : ident := $"bhvTTCCog".
Definition _bhvTTCElevator : ident := $"bhvTTCElevator".
Definition _bhvTTCMovingBar : ident := $"bhvTTCMovingBar".
Definition _bhvTTCPendulum : ident := $"bhvTTCPendulum".
Definition _bhvTTCPitBlock : ident := $"bhvTTCPitBlock".
Definition _bhvTTCRotatingSolid : ident := $"bhvTTCRotatingSolid".
Definition _bhvTTCSpinner : ident := $"bhvTTCSpinner".
Definition _bhvTTCTreadmill : ident := $"bhvTTCTreadmill".
Definition _bhvTTMBowlingBallSpawner : ident := $"bhvTTMBowlingBallSpawner".
Definition _bhvTTMRollingLog : ident := $"bhvTTMRollingLog".
Definition _bhvTankFishGroup : ident := $"bhvTankFishGroup".
Definition _bhvTemporaryYellowCoin : ident := $"bhvTemporaryYellowCoin".
Definition _bhvTenCoinsSpawn : ident := $"bhvTenCoinsSpawn".
Definition _bhvThreeCoinsSpawn : ident := $"bhvThreeCoinsSpawn".
Definition _bhvThwomp : ident := $"bhvThwomp".
Definition _bhvThwomp2 : ident := $"bhvThwomp2".
Definition _bhvTiltingBowserLavaPlatform : ident := $"bhvTiltingBowserLavaPlatform".
Definition _bhvTinyStrongWindParticle : ident := $"bhvTinyStrongWindParticle".
Definition _bhvToadMessage : ident := $"bhvToadMessage".
Definition _bhvTower : ident := $"bhvTower".
Definition _bhvTowerDoor : ident := $"bhvTowerDoor".
Definition _bhvTowerPlatformGroup : ident := $"bhvTowerPlatformGroup".
Definition _bhvToxBox : ident := $"bhvToxBox".
Definition _bhvTrackBall : ident := $"bhvTrackBall".
Definition _bhvTreasureChestBottom : ident := $"bhvTreasureChestBottom".
Definition _bhvTreasureChestTop : ident := $"bhvTreasureChestTop".
Definition _bhvTreasureChestsDDD : ident := $"bhvTreasureChestsDDD".
Definition _bhvTreasureChestsJRB : ident := $"bhvTreasureChestsJRB".
Definition _bhvTreasureChestsShip : ident := $"bhvTreasureChestsShip".
Definition _bhvTree : ident := $"bhvTree".
Definition _bhvTreeLeaf : ident := $"bhvTreeLeaf".
Definition _bhvTreeSnow : ident := $"bhvTreeSnow".
Definition _bhvTriangleParticleSpawner : ident := $"bhvTriangleParticleSpawner".
Definition _bhvTripletButterfly : ident := $"bhvTripletButterfly".
Definition _bhvTumblingBridge : ident := $"bhvTumblingBridge".
Definition _bhvTumblingBridgePlatform : ident := $"bhvTumblingBridgePlatform".
Definition _bhvTuxiesMother : ident := $"bhvTuxiesMother".
Definition _bhvTweester : ident := $"bhvTweester".
Definition _bhvTweesterSandParticle : ident := $"bhvTweesterSandParticle".
Definition _bhvUkiki : ident := $"bhvUkiki".
Definition _bhvUkikiCage : ident := $"bhvUkikiCage".
Definition _bhvUkikiCageChild : ident := $"bhvUkikiCageChild".
Definition _bhvUkikiCageStar : ident := $"bhvUkikiCageStar".
Definition _bhvUnagi : ident := $"bhvUnagi".
Definition _bhvUnagiSubobject : ident := $"bhvUnagiSubobject".
Definition _bhvUnlockDoorStar : ident := $"bhvUnlockDoorStar".
Definition _bhvUnused05A8 : ident := $"bhvUnused05A8".
Definition _bhvUnused0DFC : ident := $"bhvUnused0DFC".
Definition _bhvUnused1820 : ident := $"bhvUnused1820".
Definition _bhvUnused1F30 : ident := $"bhvUnused1F30".
Definition _bhvUnused20E0 : ident := $"bhvUnused20E0".
Definition _bhvUnused2A10 : ident := $"bhvUnused2A10".
Definition _bhvUnused2A54 : ident := $"bhvUnused2A54".
Definition _bhvUnusedFakeStar : ident := $"bhvUnusedFakeStar".
Definition _bhvUnusedParticleSpawn : ident := $"bhvUnusedParticleSpawn".
Definition _bhvUnusedPoundablePlatform : ident := $"bhvUnusedPoundablePlatform".
Definition _bhvVanishCap : ident := $"bhvVanishCap".
Definition _bhvVertStarParticleSpawner : ident := $"bhvVertStarParticleSpawner".
Definition _bhvVolcanoFlames : ident := $"bhvVolcanoFlames".
Definition _bhvVolcanoSoundLoop : ident := $"bhvVolcanoSoundLoop".
Definition _bhvWDWExpressElevator : ident := $"bhvWDWExpressElevator".
Definition _bhvWDWExpressElevatorPlatform : ident := $"bhvWDWExpressElevatorPlatform".
Definition _bhvWDWRectangularFloatingPlatform : ident := $"bhvWDWRectangularFloatingPlatform".
Definition _bhvWDWSquareFloatingPlatform : ident := $"bhvWDWSquareFloatingPlatform".
Definition _bhvWFBreakableWallLeft : ident := $"bhvWFBreakableWallLeft".
Definition _bhvWFBreakableWallRight : ident := $"bhvWFBreakableWallRight".
Definition _bhvWFElevatorTowerPlatform : ident := $"bhvWFElevatorTowerPlatform".
Definition _bhvWFRotatingWoodenPlatform : ident := $"bhvWFRotatingWoodenPlatform".
Definition _bhvWFSlidingPlatform : ident := $"bhvWFSlidingPlatform".
Definition _bhvWFSlidingTowerPlatform : ident := $"bhvWFSlidingTowerPlatform".
Definition _bhvWFSolidTowerPlatform : ident := $"bhvWFSolidTowerPlatform".
Definition _bhvWallTinyStarParticle : ident := $"bhvWallTinyStarParticle".
Definition _bhvWarp : ident := $"bhvWarp".
Definition _bhvWarpPipe : ident := $"bhvWarpPipe".
Definition _bhvWaterAirBubble : ident := $"bhvWaterAirBubble".
Definition _bhvWaterBomb : ident := $"bhvWaterBomb".
Definition _bhvWaterBombCannon : ident := $"bhvWaterBombCannon".
Definition _bhvWaterBombShadow : ident := $"bhvWaterBombShadow".
Definition _bhvWaterBombSpawner : ident := $"bhvWaterBombSpawner".
Definition _bhvWaterDroplet : ident := $"bhvWaterDroplet".
Definition _bhvWaterDropletSplash : ident := $"bhvWaterDropletSplash".
Definition _bhvWaterLevelDiamond : ident := $"bhvWaterLevelDiamond".
Definition _bhvWaterLevelPillar : ident := $"bhvWaterLevelPillar".
Definition _bhvWaterMist : ident := $"bhvWaterMist".
Definition _bhvWaterMist2 : ident := $"bhvWaterMist2".
Definition _bhvWaterSplash : ident := $"bhvWaterSplash".
Definition _bhvWaterfallSoundLoop : ident := $"bhvWaterfallSoundLoop".
Definition _bhvWaveTrail : ident := $"bhvWaveTrail".
Definition _bhvWhirlpool : ident := $"bhvWhirlpool".
Definition _bhvWhitePuff1 : ident := $"bhvWhitePuff1".
Definition _bhvWhitePuff2 : ident := $"bhvWhitePuff2".
Definition _bhvWhitePuffExplosion : ident := $"bhvWhitePuffExplosion".
Definition _bhvWhitePuffSmoke : ident := $"bhvWhitePuffSmoke".
Definition _bhvWhitePuffSmoke2 : ident := $"bhvWhitePuffSmoke2".
Definition _bhvWhompKingBoss : ident := $"bhvWhompKingBoss".
Definition _bhvWigglerBody : ident := $"bhvWigglerBody".
Definition _bhvWigglerHead : ident := $"bhvWigglerHead".
Definition _bhvWind : ident := $"bhvWind".
Definition _bhvWingCap : ident := $"bhvWingCap".
Definition _bhvWoodenPost : ident := $"bhvWoodenPost".
Definition _bhvYellowBackgroundInMenu : ident := $"bhvYellowBackgroundInMenu".
Definition _bhvYellowBall : ident := $"bhvYellowBall".
Definition _bhvYellowCoin : ident := $"bhvYellowCoin".
Definition _bhvYoshi : ident := $"bhvYoshi".
Definition _bhv_1up_common_init : ident := $"bhv_1up_common_init".
Definition _bhv_1up_hidden_in_pole_loop : ident := $"bhv_1up_hidden_in_pole_loop".
Definition _bhv_1up_hidden_in_pole_spawner_loop : ident := $"bhv_1up_hidden_in_pole_spawner_loop".
Definition _bhv_1up_hidden_in_pole_trigger_loop : ident := $"bhv_1up_hidden_in_pole_trigger_loop".
Definition _bhv_1up_hidden_loop : ident := $"bhv_1up_hidden_loop".
Definition _bhv_1up_hidden_trigger_loop : ident := $"bhv_1up_hidden_trigger_loop".
Definition _bhv_1up_init : ident := $"bhv_1up_init".
Definition _bhv_1up_jump_on_approach_loop : ident := $"bhv_1up_jump_on_approach_loop".
Definition _bhv_1up_loop : ident := $"bhv_1up_loop".
Definition _bhv_1up_running_away_loop : ident := $"bhv_1up_running_away_loop".
Definition _bhv_1up_sliding_loop : ident := $"bhv_1up_sliding_loop".
Definition _bhv_1up_walking_loop : ident := $"bhv_1up_walking_loop".
Definition _bhv_act_selector_init : ident := $"bhv_act_selector_init".
Definition _bhv_act_selector_loop : ident := $"bhv_act_selector_loop".
Definition _bhv_act_selector_star_type_loop : ident := $"bhv_act_selector_star_type_loop".
Definition _bhv_activated_back_and_forth_platform_init : ident := $"bhv_activated_back_and_forth_platform_init".
Definition _bhv_activated_back_and_forth_platform_update : ident := $"bhv_activated_back_and_forth_platform_update".
Definition _bhv_alpha_boo_key_loop : ident := $"bhv_alpha_boo_key_loop".
Definition _bhv_ambient_sounds_init : ident := $"bhv_ambient_sounds_init".
Definition _bhv_animated_texture_loop : ident := $"bhv_animated_texture_loop".
Definition _bhv_animates_on_floor_switch_press_init : ident := $"bhv_animates_on_floor_switch_press_init".
Definition _bhv_animates_on_floor_switch_press_loop : ident := $"bhv_animates_on_floor_switch_press_loop".
Definition _bhv_arrow_lift_loop : ident := $"bhv_arrow_lift_loop".
Definition _bhv_bbh_tilting_trap_platform_loop : ident := $"bhv_bbh_tilting_trap_platform_loop".
Definition _bhv_beta_boo_key_loop : ident := $"bhv_beta_boo_key_loop".
Definition _bhv_beta_bowser_anchor_loop : ident := $"bhv_beta_bowser_anchor_loop".
Definition _bhv_beta_chest_bottom_init : ident := $"bhv_beta_chest_bottom_init".
Definition _bhv_beta_chest_bottom_loop : ident := $"bhv_beta_chest_bottom_loop".
Definition _bhv_beta_chest_lid_loop : ident := $"bhv_beta_chest_lid_loop".
Definition _bhv_beta_fish_splash_spawner_loop : ident := $"bhv_beta_fish_splash_spawner_loop".
Definition _bhv_beta_holdable_object_init : ident := $"bhv_beta_holdable_object_init".
Definition _bhv_beta_holdable_object_loop : ident := $"bhv_beta_holdable_object_loop".
Definition _bhv_beta_moving_flames_loop : ident := $"bhv_beta_moving_flames_loop".
Definition _bhv_beta_moving_flames_spawn_loop : ident := $"bhv_beta_moving_flames_spawn_loop".
Definition _bhv_beta_trampoline_spring_loop : ident := $"bhv_beta_trampoline_spring_loop".
Definition _bhv_beta_trampoline_top_loop : ident := $"bhv_beta_trampoline_top_loop".
Definition _bhv_big_boo_loop : ident := $"bhv_big_boo_loop".
Definition _bhv_big_boulder_generator_loop : ident := $"bhv_big_boulder_generator_loop".
Definition _bhv_big_boulder_init : ident := $"bhv_big_boulder_init".
Definition _bhv_big_boulder_loop : ident := $"bhv_big_boulder_loop".
Definition _bhv_big_bully_init : ident := $"bhv_big_bully_init".
Definition _bhv_big_bully_with_minions_init : ident := $"bhv_big_bully_with_minions_init".
Definition _bhv_big_bully_with_minions_loop : ident := $"bhv_big_bully_with_minions_loop".
Definition _bhv_bird_update : ident := $"bhv_bird_update".
Definition _bhv_birds_sound_loop : ident := $"bhv_birds_sound_loop".
Definition _bhv_bitfs_sinking_cage_platform_loop : ident := $"bhv_bitfs_sinking_cage_platform_loop".
Definition _bhv_bitfs_sinking_platform_loop : ident := $"bhv_bitfs_sinking_platform_loop".
Definition _bhv_black_smoke_bowser_loop : ident := $"bhv_black_smoke_bowser_loop".
Definition _bhv_black_smoke_mario_loop : ident := $"bhv_black_smoke_mario_loop".
Definition _bhv_black_smoke_upward_loop : ident := $"bhv_black_smoke_upward_loop".
Definition _bhv_blue_bowser_flame_init : ident := $"bhv_blue_bowser_flame_init".
Definition _bhv_blue_bowser_flame_loop : ident := $"bhv_blue_bowser_flame_loop".
Definition _bhv_blue_coin_jumping_loop : ident := $"bhv_blue_coin_jumping_loop".
Definition _bhv_blue_coin_sliding_jumping_init : ident := $"bhv_blue_coin_sliding_jumping_init".
Definition _bhv_blue_coin_sliding_loop : ident := $"bhv_blue_coin_sliding_loop".
Definition _bhv_blue_coin_switch_loop : ident := $"bhv_blue_coin_switch_loop".
Definition _bhv_blue_fish_movement_loop : ident := $"bhv_blue_fish_movement_loop".
Definition _bhv_blue_flames_group_loop : ident := $"bhv_blue_flames_group_loop".
Definition _bhv_bob_pit_bowling_ball_init : ident := $"bhv_bob_pit_bowling_ball_init".
Definition _bhv_bob_pit_bowling_ball_loop : ident := $"bhv_bob_pit_bowling_ball_loop".
Definition _bhv_bobomb_anchor_mario_loop : ident := $"bhv_bobomb_anchor_mario_loop".
Definition _bhv_bobomb_buddy_init : ident := $"bhv_bobomb_buddy_init".
Definition _bhv_bobomb_buddy_loop : ident := $"bhv_bobomb_buddy_loop".
Definition _bhv_bobomb_bully_death_smoke_init : ident := $"bhv_bobomb_bully_death_smoke_init".
Definition _bhv_bobomb_explosion_bubble_init : ident := $"bhv_bobomb_explosion_bubble_init".
Definition _bhv_bobomb_explosion_bubble_loop : ident := $"bhv_bobomb_explosion_bubble_loop".
Definition _bhv_bobomb_fuse_smoke_init : ident := $"bhv_bobomb_fuse_smoke_init".
Definition _bhv_bobomb_init : ident := $"bhv_bobomb_init".
Definition _bhv_bobomb_loop : ident := $"bhv_bobomb_loop".
Definition _bhv_boo_cage_loop : ident := $"bhv_boo_cage_loop".
Definition _bhv_boo_in_castle_loop : ident := $"bhv_boo_in_castle_loop".
Definition _bhv_boo_init : ident := $"bhv_boo_init".
Definition _bhv_boo_loop : ident := $"bhv_boo_loop".
Definition _bhv_boo_staircase : ident := $"bhv_boo_staircase".
Definition _bhv_boo_with_cage_init : ident := $"bhv_boo_with_cage_init".
Definition _bhv_boo_with_cage_loop : ident := $"bhv_boo_with_cage_loop".
Definition _bhv_book_switch_loop : ident := $"bhv_book_switch_loop".
Definition _bhv_bookend_spawn_loop : ident := $"bhv_bookend_spawn_loop".
Definition _bhv_bouncing_fireball_flame_loop : ident := $"bhv_bouncing_fireball_flame_loop".
Definition _bhv_bouncing_fireball_loop : ident := $"bhv_bouncing_fireball_loop".
Definition _bhv_bowling_ball_init : ident := $"bhv_bowling_ball_init".
Definition _bhv_bowling_ball_loop : ident := $"bhv_bowling_ball_loop".
Definition _bhv_bowser_body_anchor_loop : ident := $"bhv_bowser_body_anchor_loop".
Definition _bhv_bowser_bomb_explosion_loop : ident := $"bhv_bowser_bomb_explosion_loop".
Definition _bhv_bowser_bomb_loop : ident := $"bhv_bowser_bomb_loop".
Definition _bhv_bowser_bomb_smoke_loop : ident := $"bhv_bowser_bomb_smoke_loop".
Definition _bhv_bowser_course_red_coin_star_loop : ident := $"bhv_bowser_course_red_coin_star_loop".
Definition _bhv_bowser_flame_spawn_loop : ident := $"bhv_bowser_flame_spawn_loop".
Definition _bhv_bowser_init : ident := $"bhv_bowser_init".
Definition _bhv_bowser_key_course_exit_loop : ident := $"bhv_bowser_key_course_exit_loop".
Definition _bhv_bowser_key_loop : ident := $"bhv_bowser_key_loop".
Definition _bhv_bowser_key_unlock_door_loop : ident := $"bhv_bowser_key_unlock_door_loop".
Definition _bhv_bowser_loop : ident := $"bhv_bowser_loop".
Definition _bhv_bowser_shock_wave_loop : ident := $"bhv_bowser_shock_wave_loop".
Definition _bhv_bowser_tail_anchor_loop : ident := $"bhv_bowser_tail_anchor_loop".
Definition _bhv_bowsers_sub_loop : ident := $"bhv_bowsers_sub_loop".
Definition _bhv_breakable_box_loop : ident := $"bhv_breakable_box_loop".
Definition _bhv_breakable_box_small_init : ident := $"bhv_breakable_box_small_init".
Definition _bhv_breakable_box_small_loop : ident := $"bhv_breakable_box_small_loop".
Definition _bhv_bub_loop : ident := $"bhv_bub_loop".
Definition _bhv_bub_spawner_loop : ident := $"bhv_bub_spawner_loop".
Definition _bhv_bubba_loop : ident := $"bhv_bubba_loop".
Definition _bhv_bubble_cannon_barrel_loop : ident := $"bhv_bubble_cannon_barrel_loop".
Definition _bhv_bubble_maybe_loop : ident := $"bhv_bubble_maybe_loop".
Definition _bhv_bubble_splash_init : ident := $"bhv_bubble_splash_init".
Definition _bhv_bubble_wave_init : ident := $"bhv_bubble_wave_init".
Definition _bhv_bullet_bill_init : ident := $"bhv_bullet_bill_init".
Definition _bhv_bullet_bill_loop : ident := $"bhv_bullet_bill_loop".
Definition _bhv_bully_loop : ident := $"bhv_bully_loop".
Definition _bhv_butterfly_init : ident := $"bhv_butterfly_init".
Definition _bhv_butterfly_loop : ident := $"bhv_butterfly_loop".
Definition _bhv_camera_lakitu_init : ident := $"bhv_camera_lakitu_init".
Definition _bhv_camera_lakitu_update : ident := $"bhv_camera_lakitu_update".
Definition _bhv_cannon_barrel_loop : ident := $"bhv_cannon_barrel_loop".
Definition _bhv_cannon_base_loop : ident := $"bhv_cannon_base_loop".
Definition _bhv_cannon_base_unused_loop : ident := $"bhv_cannon_base_unused_loop".
Definition _bhv_cannon_closed_init : ident := $"bhv_cannon_closed_init".
Definition _bhv_cannon_closed_loop : ident := $"bhv_cannon_closed_loop".
Definition _bhv_cap_switch_loop : ident := $"bhv_cap_switch_loop".
Definition _bhv_castle_cannon_grate_init : ident := $"bhv_castle_cannon_grate_init".
Definition _bhv_castle_flag_init : ident := $"bhv_castle_flag_init".
Definition _bhv_castle_floor_trap_init : ident := $"bhv_castle_floor_trap_init".
Definition _bhv_castle_floor_trap_loop : ident := $"bhv_castle_floor_trap_loop".
Definition _bhv_ccm_touched_star_spawn_loop : ident := $"bhv_ccm_touched_star_spawn_loop".
Definition _bhv_celebration_star_init : ident := $"bhv_celebration_star_init".
Definition _bhv_celebration_star_loop : ident := $"bhv_celebration_star_loop".
Definition _bhv_celebration_star_sparkle_loop : ident := $"bhv_celebration_star_sparkle_loop".
Definition _bhv_chain_chomp_chain_part_update : ident := $"bhv_chain_chomp_chain_part_update".
Definition _bhv_chain_chomp_gate_init : ident := $"bhv_chain_chomp_gate_init".
Definition _bhv_chain_chomp_gate_update : ident := $"bhv_chain_chomp_gate_update".
Definition _bhv_chain_chomp_update : ident := $"bhv_chain_chomp_update".
Definition _bhv_checkerboard_elevator_group_init : ident := $"bhv_checkerboard_elevator_group_init".
Definition _bhv_checkerboard_platform_init : ident := $"bhv_checkerboard_platform_init".
Definition _bhv_checkerboard_platform_loop : ident := $"bhv_checkerboard_platform_loop".
Definition _bhv_chuckya_anchor_mario_loop : ident := $"bhv_chuckya_anchor_mario_loop".
Definition _bhv_chuckya_loop : ident := $"bhv_chuckya_loop".
Definition _bhv_circling_amp_init : ident := $"bhv_circling_amp_init".
Definition _bhv_circling_amp_loop : ident := $"bhv_circling_amp_loop".
Definition _bhv_clam_loop : ident := $"bhv_clam_loop".
Definition _bhv_cloud_part_update : ident := $"bhv_cloud_part_update".
Definition _bhv_cloud_update : ident := $"bhv_cloud_update".
Definition _bhv_coffin_loop : ident := $"bhv_coffin_loop".
Definition _bhv_coffin_spawner_loop : ident := $"bhv_coffin_spawner_loop".
Definition _bhv_coin_formation_init : ident := $"bhv_coin_formation_init".
Definition _bhv_coin_formation_loop : ident := $"bhv_coin_formation_loop".
Definition _bhv_coin_formation_spawn_loop : ident := $"bhv_coin_formation_spawn_loop".
Definition _bhv_coin_inside_boo_loop : ident := $"bhv_coin_inside_boo_loop".
Definition _bhv_coin_sparkles_loop : ident := $"bhv_coin_sparkles_loop".
Definition _bhv_collect_star_init : ident := $"bhv_collect_star_init".
Definition _bhv_collect_star_loop : ident := $"bhv_collect_star_loop".
Definition _bhv_controllable_platform_init : ident := $"bhv_controllable_platform_init".
Definition _bhv_controllable_platform_loop : ident := $"bhv_controllable_platform_loop".
Definition _bhv_controllable_platform_sub_loop : ident := $"bhv_controllable_platform_sub_loop".
Definition _bhv_courtyard_boo_triplet_init : ident := $"bhv_courtyard_boo_triplet_init".
Definition _bhv_ddd_moving_pole_loop : ident := $"bhv_ddd_moving_pole_loop".
Definition _bhv_ddd_pole_init : ident := $"bhv_ddd_pole_init".
Definition _bhv_ddd_pole_update : ident := $"bhv_ddd_pole_update".
Definition _bhv_ddd_warp_loop : ident := $"bhv_ddd_warp_loop".
Definition _bhv_decorative_pendulum_init : ident := $"bhv_decorative_pendulum_init".
Definition _bhv_decorative_pendulum_loop : ident := $"bhv_decorative_pendulum_loop".
Definition _bhv_donut_platform_spawner_update : ident := $"bhv_donut_platform_spawner_update".
Definition _bhv_donut_platform_update : ident := $"bhv_donut_platform_update".
Definition _bhv_door_init : ident := $"bhv_door_init".
Definition _bhv_door_loop : ident := $"bhv_door_loop".
Definition _bhv_dorrie_update : ident := $"bhv_dorrie_update".
Definition _bhv_dust_smoke_loop : ident := $"bhv_dust_smoke_loop".
Definition _bhv_elevator_init : ident := $"bhv_elevator_init".
Definition _bhv_elevator_loop : ident := $"bhv_elevator_loop".
Definition _bhv_end_birds_1_loop : ident := $"bhv_end_birds_1_loop".
Definition _bhv_end_birds_2_loop : ident := $"bhv_end_birds_2_loop".
Definition _bhv_end_peach_loop : ident := $"bhv_end_peach_loop".
Definition _bhv_end_toad_loop : ident := $"bhv_end_toad_loop".
Definition _bhv_enemy_lakitu_update : ident := $"bhv_enemy_lakitu_update".
Definition _bhv_exclamation_box_loop : ident := $"bhv_exclamation_box_loop".
Definition _bhv_explosion_init : ident := $"bhv_explosion_init".
Definition _bhv_explosion_loop : ident := $"bhv_explosion_loop".
Definition _bhv_eyerok_boss_loop : ident := $"bhv_eyerok_boss_loop".
Definition _bhv_eyerok_hand_loop : ident := $"bhv_eyerok_hand_loop".
Definition _bhv_fading_warp_loop : ident := $"bhv_fading_warp_loop".
Definition _bhv_falling_bowser_platform_loop : ident := $"bhv_falling_bowser_platform_loop".
Definition _bhv_falling_pillar_hitbox_loop : ident := $"bhv_falling_pillar_hitbox_loop".
Definition _bhv_falling_pillar_init : ident := $"bhv_falling_pillar_init".
Definition _bhv_falling_pillar_loop : ident := $"bhv_falling_pillar_loop".
Definition _bhv_ferris_wheel_axle_init : ident := $"bhv_ferris_wheel_axle_init".
Definition _bhv_ferris_wheel_platform_update : ident := $"bhv_ferris_wheel_platform_update".
Definition _bhv_fire_piranha_plant_init : ident := $"bhv_fire_piranha_plant_init".
Definition _bhv_fire_piranha_plant_update : ident := $"bhv_fire_piranha_plant_update".
Definition _bhv_fire_spitter_update : ident := $"bhv_fire_spitter_update".
Definition _bhv_fish_group_loop : ident := $"bhv_fish_group_loop".
Definition _bhv_fish_loop : ident := $"bhv_fish_loop".
Definition _bhv_fish_spawner_loop : ident := $"bhv_fish_spawner_loop".
Definition _bhv_flame_bouncing_init : ident := $"bhv_flame_bouncing_init".
Definition _bhv_flame_bouncing_loop : ident := $"bhv_flame_bouncing_loop".
Definition _bhv_flame_bowser_init : ident := $"bhv_flame_bowser_init".
Definition _bhv_flame_bowser_loop : ident := $"bhv_flame_bowser_loop".
Definition _bhv_flame_floating_landing_init : ident := $"bhv_flame_floating_landing_init".
Definition _bhv_flame_floating_landing_loop : ident := $"bhv_flame_floating_landing_loop".
Definition _bhv_flame_large_burning_out_init : ident := $"bhv_flame_large_burning_out_init".
Definition _bhv_flame_mario_loop : ident := $"bhv_flame_mario_loop".
Definition _bhv_flame_moving_forward_growing_init : ident := $"bhv_flame_moving_forward_growing_init".
Definition _bhv_flame_moving_forward_growing_loop : ident := $"bhv_flame_moving_forward_growing_loop".
Definition _bhv_flamethrower_flame_loop : ident := $"bhv_flamethrower_flame_loop".
Definition _bhv_flamethrower_loop : ident := $"bhv_flamethrower_loop".
Definition _bhv_floating_platform_loop : ident := $"bhv_floating_platform_loop".
Definition _bhv_floor_trap_in_castle_loop : ident := $"bhv_floor_trap_in_castle_loop".
Definition _bhv_fly_guy_flame_loop : ident := $"bhv_fly_guy_flame_loop".
Definition _bhv_fly_guy_update : ident := $"bhv_fly_guy_update".
Definition _bhv_flying_bookend_loop : ident := $"bhv_flying_bookend_loop".
Definition _bhv_free_bowling_ball_init : ident := $"bhv_free_bowling_ball_init".
Definition _bhv_free_bowling_ball_loop : ident := $"bhv_free_bowling_ball_loop".
Definition _bhv_generic_bowling_ball_spawner_init : ident := $"bhv_generic_bowling_ball_spawner_init".
Definition _bhv_generic_bowling_ball_spawner_loop : ident := $"bhv_generic_bowling_ball_spawner_loop".
Definition _bhv_giant_pole_loop : ident := $"bhv_giant_pole_loop".
Definition _bhv_golden_coin_sparkles_loop : ident := $"bhv_golden_coin_sparkles_loop".
Definition _bhv_goomba_init : ident := $"bhv_goomba_init".
Definition _bhv_goomba_triplet_spawner_update : ident := $"bhv_goomba_triplet_spawner_update".
Definition _bhv_goomba_update : ident := $"bhv_goomba_update".
Definition _bhv_grand_star_loop : ident := $"bhv_grand_star_loop".
Definition _bhv_grindel_thwomp_loop : ident := $"bhv_grindel_thwomp_loop".
Definition _bhv_ground_sand_init : ident := $"bhv_ground_sand_init".
Definition _bhv_ground_snow_init : ident := $"bhv_ground_snow_init".
Definition _bhv_haunted_bookshelf_loop : ident := $"bhv_haunted_bookshelf_loop".
Definition _bhv_haunted_bookshelf_manager_loop : ident := $"bhv_haunted_bookshelf_manager_loop".
Definition _bhv_haunted_chair_init : ident := $"bhv_haunted_chair_init".
Definition _bhv_haunted_chair_loop : ident := $"bhv_haunted_chair_loop".
Definition _bhv_heave_ho_loop : ident := $"bhv_heave_ho_loop".
Definition _bhv_heave_ho_throw_mario_loop : ident := $"bhv_heave_ho_throw_mario_loop".
Definition _bhv_hidden_blue_coin_loop : ident := $"bhv_hidden_blue_coin_loop".
Definition _bhv_hidden_object_loop : ident := $"bhv_hidden_object_loop".
Definition _bhv_hidden_red_coin_star_init : ident := $"bhv_hidden_red_coin_star_init".
Definition _bhv_hidden_red_coin_star_loop : ident := $"bhv_hidden_red_coin_star_loop".
Definition _bhv_hidden_star_init : ident := $"bhv_hidden_star_init".
Definition _bhv_hidden_star_loop : ident := $"bhv_hidden_star_loop".
Definition _bhv_hidden_star_trigger_loop : ident := $"bhv_hidden_star_trigger_loop".
Definition _bhv_homing_amp_init : ident := $"bhv_homing_amp_init".
Definition _bhv_homing_amp_loop : ident := $"bhv_homing_amp_loop".
Definition _bhv_hoot_init : ident := $"bhv_hoot_init".
Definition _bhv_hoot_loop : ident := $"bhv_hoot_loop".
Definition _bhv_horizontal_grindel_init : ident := $"bhv_horizontal_grindel_init".
Definition _bhv_horizontal_grindel_update : ident := $"bhv_horizontal_grindel_update".
Definition _bhv_idle_water_wave_loop : ident := $"bhv_idle_water_wave_loop".
Definition _bhv_init_changing_water_level_loop : ident := $"bhv_init_changing_water_level_loop".
Definition _bhv_init_room : ident := $"bhv_init_room".
Definition _bhv_intro_lakitu_loop : ident := $"bhv_intro_lakitu_loop".
Definition _bhv_intro_peach_loop : ident := $"bhv_intro_peach_loop".
Definition _bhv_intro_scene_loop : ident := $"bhv_intro_scene_loop".
Definition _bhv_invisible_objects_under_bridge_init : ident := $"bhv_invisible_objects_under_bridge_init".
Definition _bhv_jet_stream_loop : ident := $"bhv_jet_stream_loop".
Definition _bhv_jet_stream_ring_spawner_loop : ident := $"bhv_jet_stream_ring_spawner_loop".
Definition _bhv_jet_stream_water_ring_init : ident := $"bhv_jet_stream_water_ring_init".
Definition _bhv_jet_stream_water_ring_loop : ident := $"bhv_jet_stream_water_ring_loop".
Definition _bhv_jrb_floating_box_loop : ident := $"bhv_jrb_floating_box_loop".
Definition _bhv_jrb_sliding_box_loop : ident := $"bhv_jrb_sliding_box_loop".
Definition _bhv_jumping_box_loop : ident := $"bhv_jumping_box_loop".
Definition _bhv_kickable_board_loop : ident := $"bhv_kickable_board_loop".
Definition _bhv_king_bobomb_loop : ident := $"bhv_king_bobomb_loop".
Definition _bhv_klepto_init : ident := $"bhv_klepto_init".
Definition _bhv_klepto_update : ident := $"bhv_klepto_update".
Definition _bhv_koopa_init : ident := $"bhv_koopa_init".
Definition _bhv_koopa_race_endpoint_update : ident := $"bhv_koopa_race_endpoint_update".
Definition _bhv_koopa_shell_flame_loop : ident := $"bhv_koopa_shell_flame_loop".
Definition _bhv_koopa_shell_loop : ident := $"bhv_koopa_shell_loop".
Definition _bhv_koopa_shell_underwater_loop : ident := $"bhv_koopa_shell_underwater_loop".
Definition _bhv_koopa_update : ident := $"bhv_koopa_update".
Definition _bhv_large_bomp_init : ident := $"bhv_large_bomp_init".
Definition _bhv_large_bomp_loop : ident := $"bhv_large_bomp_loop".
Definition _bhv_lll_bowser_puzzle_loop : ident := $"bhv_lll_bowser_puzzle_loop".
Definition _bhv_lll_bowser_puzzle_piece_loop : ident := $"bhv_lll_bowser_puzzle_piece_loop".
Definition _bhv_lll_drawbridge_loop : ident := $"bhv_lll_drawbridge_loop".
Definition _bhv_lll_drawbridge_spawner_loop : ident := $"bhv_lll_drawbridge_spawner_loop".
Definition _bhv_lll_floating_wood_bridge_loop : ident := $"bhv_lll_floating_wood_bridge_loop".
Definition _bhv_lll_moving_octagonal_mesh_platform_loop : ident := $"bhv_lll_moving_octagonal_mesh_platform_loop".
Definition _bhv_lll_rolling_log_init : ident := $"bhv_lll_rolling_log_init".
Definition _bhv_lll_rotating_block_fire_bars_loop : ident := $"bhv_lll_rotating_block_fire_bars_loop".
Definition _bhv_lll_rotating_hex_flame_loop : ident := $"bhv_lll_rotating_hex_flame_loop".
Definition _bhv_lll_rotating_hexagonal_ring_loop : ident := $"bhv_lll_rotating_hexagonal_ring_loop".
Definition _bhv_lll_sinking_rectangular_platform_loop : ident := $"bhv_lll_sinking_rectangular_platform_loop".
Definition _bhv_lll_sinking_rock_block_loop : ident := $"bhv_lll_sinking_rock_block_loop".
Definition _bhv_lll_sinking_square_platforms_loop : ident := $"bhv_lll_sinking_square_platforms_loop".
Definition _bhv_lll_wood_piece_loop : ident := $"bhv_lll_wood_piece_loop".
Definition _bhv_mad_piano_update : ident := $"bhv_mad_piano_update".
Definition _bhv_manta_ray_init : ident := $"bhv_manta_ray_init".
Definition _bhv_manta_ray_loop : ident := $"bhv_manta_ray_loop".
Definition _bhv_manta_ray_water_ring_init : ident := $"bhv_manta_ray_water_ring_init".
Definition _bhv_manta_ray_water_ring_loop : ident := $"bhv_manta_ray_water_ring_loop".
Definition _bhv_mario_update : ident := $"bhv_mario_update".
Definition _bhv_menu_button_init : ident := $"bhv_menu_button_init".
Definition _bhv_menu_button_loop : ident := $"bhv_menu_button_loop".
Definition _bhv_menu_button_manager_init : ident := $"bhv_menu_button_manager_init".
Definition _bhv_menu_button_manager_loop : ident := $"bhv_menu_button_manager_loop".
Definition _bhv_merry_go_round_boo_manager_loop : ident := $"bhv_merry_go_round_boo_manager_loop".
Definition _bhv_merry_go_round_loop : ident := $"bhv_merry_go_round_loop".
Definition _bhv_metal_cap_init : ident := $"bhv_metal_cap_init".
Definition _bhv_metal_cap_loop : ident := $"bhv_metal_cap_loop".
Definition _bhv_mips_init : ident := $"bhv_mips_init".
Definition _bhv_mips_loop : ident := $"bhv_mips_loop".
Definition _bhv_moat_grills_loop : ident := $"bhv_moat_grills_loop".
Definition _bhv_moneybag_hidden_loop : ident := $"bhv_moneybag_hidden_loop".
Definition _bhv_moneybag_init : ident := $"bhv_moneybag_init".
Definition _bhv_moneybag_loop : ident := $"bhv_moneybag_loop".
Definition _bhv_monty_mole_hole_update : ident := $"bhv_monty_mole_hole_update".
Definition _bhv_monty_mole_init : ident := $"bhv_monty_mole_init".
Definition _bhv_monty_mole_rock_update : ident := $"bhv_monty_mole_rock_update".
Definition _bhv_monty_mole_update : ident := $"bhv_monty_mole_update".
Definition _bhv_moving_blue_coin_init : ident := $"bhv_moving_blue_coin_init".
Definition _bhv_moving_blue_coin_loop : ident := $"bhv_moving_blue_coin_loop".
Definition _bhv_moving_yellow_coin_init : ident := $"bhv_moving_yellow_coin_init".
Definition _bhv_moving_yellow_coin_loop : ident := $"bhv_moving_yellow_coin_loop".
Definition _bhv_mr_blizzard_init : ident := $"bhv_mr_blizzard_init".
Definition _bhv_mr_blizzard_snowball : ident := $"bhv_mr_blizzard_snowball".
Definition _bhv_mr_blizzard_update : ident := $"bhv_mr_blizzard_update".
Definition _bhv_mr_i_body_loop : ident := $"bhv_mr_i_body_loop".
Definition _bhv_mr_i_loop : ident := $"bhv_mr_i_loop".
Definition _bhv_mr_i_particle_loop : ident := $"bhv_mr_i_particle_loop".
Definition _bhv_normal_cap_init : ident := $"bhv_normal_cap_init".
Definition _bhv_normal_cap_loop : ident := $"bhv_normal_cap_loop".
Definition _bhv_object_bubble_init : ident := $"bhv_object_bubble_init".
Definition _bhv_object_bubble_loop : ident := $"bhv_object_bubble_loop".
Definition _bhv_object_water_wave_init : ident := $"bhv_object_water_wave_init".
Definition _bhv_object_water_wave_loop : ident := $"bhv_object_water_wave_loop".
Definition _bhv_openable_cage_door_loop : ident := $"bhv_openable_cage_door_loop".
Definition _bhv_openable_grill_loop : ident := $"bhv_openable_grill_loop".
Definition _bhv_orange_number_init : ident := $"bhv_orange_number_init".
Definition _bhv_orange_number_loop : ident := $"bhv_orange_number_loop".
Definition _bhv_particle_init : ident := $"bhv_particle_init".
Definition _bhv_particle_loop : ident := $"bhv_particle_loop".
Definition _bhv_penguin_race_finish_line_update : ident := $"bhv_penguin_race_finish_line_update".
Definition _bhv_penguin_race_shortcut_check_update : ident := $"bhv_penguin_race_shortcut_check_update".
Definition _bhv_piranha_particle_loop : ident := $"bhv_piranha_particle_loop".
Definition _bhv_piranha_plant_bubble_loop : ident := $"bhv_piranha_plant_bubble_loop".
Definition _bhv_piranha_plant_loop : ident := $"bhv_piranha_plant_loop".
Definition _bhv_piranha_plant_waking_bubbles_loop : ident := $"bhv_piranha_plant_waking_bubbles_loop".
Definition _bhv_platform_normals_init : ident := $"bhv_platform_normals_init".
Definition _bhv_platform_on_track_init : ident := $"bhv_platform_on_track_init".
Definition _bhv_platform_on_track_update : ident := $"bhv_platform_on_track_update".
Definition _bhv_play_music_track_when_touched_loop : ident := $"bhv_play_music_track_when_touched_loop".
Definition _bhv_pokey_body_part_update : ident := $"bhv_pokey_body_part_update".
Definition _bhv_pokey_update : ident := $"bhv_pokey_update".
Definition _bhv_pole_base_loop : ident := $"bhv_pole_base_loop".
Definition _bhv_pole_init : ident := $"bhv_pole_init".
Definition _bhv_pound_tiny_star_particle_init : ident := $"bhv_pound_tiny_star_particle_init".
Definition _bhv_pound_tiny_star_particle_loop : ident := $"bhv_pound_tiny_star_particle_loop".
Definition _bhv_pound_white_puffs_init : ident := $"bhv_pound_white_puffs_init".
Definition _bhv_punch_tiny_triangle_init : ident := $"bhv_punch_tiny_triangle_init".
Definition _bhv_punch_tiny_triangle_loop : ident := $"bhv_punch_tiny_triangle_loop".
Definition _bhv_purple_switch_loop : ident := $"bhv_purple_switch_loop".
Definition _bhv_pushable_loop : ident := $"bhv_pushable_loop".
Definition _bhv_pyramid_elevator_init : ident := $"bhv_pyramid_elevator_init".
Definition _bhv_pyramid_elevator_loop : ident := $"bhv_pyramid_elevator_loop".
Definition _bhv_pyramid_elevator_trajectory_marker_ball_loop : ident := $"bhv_pyramid_elevator_trajectory_marker_ball_loop".
Definition _bhv_pyramid_pillar_touch_detector_loop : ident := $"bhv_pyramid_pillar_touch_detector_loop".
Definition _bhv_pyramid_top_fragment_init : ident := $"bhv_pyramid_top_fragment_init".
Definition _bhv_pyramid_top_fragment_loop : ident := $"bhv_pyramid_top_fragment_loop".
Definition _bhv_pyramid_top_init : ident := $"bhv_pyramid_top_init".
Definition _bhv_pyramid_top_loop : ident := $"bhv_pyramid_top_loop".
Definition _bhv_racing_penguin_init : ident := $"bhv_racing_penguin_init".
Definition _bhv_racing_penguin_update : ident := $"bhv_racing_penguin_update".
Definition _bhv_recovery_heart_loop : ident := $"bhv_recovery_heart_loop".
Definition _bhv_red_coin_init : ident := $"bhv_red_coin_init".
Definition _bhv_red_coin_loop : ident := $"bhv_red_coin_loop".
Definition _bhv_red_coin_star_marker_init : ident := $"bhv_red_coin_star_marker_init".
Definition _bhv_respawner_loop : ident := $"bhv_respawner_loop".
Definition _bhv_rolling_log_loop : ident := $"bhv_rolling_log_loop".
Definition _bhv_rotating_clock_arm_loop : ident := $"bhv_rotating_clock_arm_loop".
Definition _bhv_rotating_exclamation_box_loop : ident := $"bhv_rotating_exclamation_box_loop".
Definition _bhv_rotating_octagonal_plat_init : ident := $"bhv_rotating_octagonal_plat_init".
Definition _bhv_rotating_octagonal_plat_loop : ident := $"bhv_rotating_octagonal_plat_loop".
Definition _bhv_rotating_platform_loop : ident := $"bhv_rotating_platform_loop".
Definition _bhv_rr_cruiser_wing_init : ident := $"bhv_rr_cruiser_wing_init".
Definition _bhv_rr_cruiser_wing_loop : ident := $"bhv_rr_cruiser_wing_loop".
Definition _bhv_rr_rotating_bridge_platform_loop : ident := $"bhv_rr_rotating_bridge_platform_loop".
Definition _bhv_sand_sound_loop : ident := $"bhv_sand_sound_loop".
Definition _bhv_scuttlebug_loop : ident := $"bhv_scuttlebug_loop".
Definition _bhv_scuttlebug_spawn_loop : ident := $"bhv_scuttlebug_spawn_loop".
Definition _bhv_seaweed_bundle_init : ident := $"bhv_seaweed_bundle_init".
Definition _bhv_seaweed_init : ident := $"bhv_seaweed_init".
Definition _bhv_seesaw_platform_init : ident := $"bhv_seesaw_platform_init".
Definition _bhv_seesaw_platform_update : ident := $"bhv_seesaw_platform_update".
Definition _bhv_shallow_water_splash_init : ident := $"bhv_shallow_water_splash_init".
Definition _bhv_ship_part_3_loop : ident := $"bhv_ship_part_3_loop".
Definition _bhv_skeeter_update : ident := $"bhv_skeeter_update".
Definition _bhv_skeeter_wave_update : ident := $"bhv_skeeter_wave_update".
Definition _bhv_sl_snowman_wind_loop : ident := $"bhv_sl_snowman_wind_loop".
Definition _bhv_sl_walking_penguin_loop : ident := $"bhv_sl_walking_penguin_loop".
Definition _bhv_sliding_plat_2_init : ident := $"bhv_sliding_plat_2_init".
Definition _bhv_sliding_plat_2_loop : ident := $"bhv_sliding_plat_2_loop".
Definition _bhv_sliding_snow_mound_loop : ident := $"bhv_sliding_snow_mound_loop".
Definition _bhv_small_bomp_init : ident := $"bhv_small_bomp_init".
Definition _bhv_small_bomp_loop : ident := $"bhv_small_bomp_loop".
Definition _bhv_small_bubbles_loop : ident := $"bhv_small_bubbles_loop".
Definition _bhv_small_bully_init : ident := $"bhv_small_bully_init".
Definition _bhv_small_penguin_loop : ident := $"bhv_small_penguin_loop".
Definition _bhv_small_piranha_flame_loop : ident := $"bhv_small_piranha_flame_loop".
Definition _bhv_small_water_wave_loop : ident := $"bhv_small_water_wave_loop".
Definition _bhv_snow_leaf_particle_spawn_init : ident := $"bhv_snow_leaf_particle_spawn_init".
Definition _bhv_snow_mound_spawn_loop : ident := $"bhv_snow_mound_spawn_loop".
Definition _bhv_snowmans_body_checkpoint_loop : ident := $"bhv_snowmans_body_checkpoint_loop".
Definition _bhv_snowmans_bottom_init : ident := $"bhv_snowmans_bottom_init".
Definition _bhv_snowmans_bottom_loop : ident := $"bhv_snowmans_bottom_loop".
Definition _bhv_snowmans_head_init : ident := $"bhv_snowmans_head_init".
Definition _bhv_snowmans_head_loop : ident := $"bhv_snowmans_head_loop".
Definition _bhv_snufit_balls_loop : ident := $"bhv_snufit_balls_loop".
Definition _bhv_snufit_loop : ident := $"bhv_snufit_loop".
Definition _bhv_sound_spawner_init : ident := $"bhv_sound_spawner_init".
Definition _bhv_sparkle_spawn_loop : ident := $"bhv_sparkle_spawn_loop".
Definition _bhv_spawned_coin_init : ident := $"bhv_spawned_coin_init".
Definition _bhv_spawned_coin_loop : ident := $"bhv_spawned_coin_loop".
Definition _bhv_spawned_star_init : ident := $"bhv_spawned_star_init".
Definition _bhv_spawned_star_loop : ident := $"bhv_spawned_star_loop".
Definition _bhv_spindel_init : ident := $"bhv_spindel_init".
Definition _bhv_spindel_loop : ident := $"bhv_spindel_loop".
Definition _bhv_spindrift_loop : ident := $"bhv_spindrift_loop".
Definition _bhv_spiny_update : ident := $"bhv_spiny_update".
Definition _bhv_squarish_path_moving_loop : ident := $"bhv_squarish_path_moving_loop".
Definition _bhv_squishable_platform_loop : ident := $"bhv_squishable_platform_loop".
Definition _bhv_ssl_moving_pyramid_wall_init : ident := $"bhv_ssl_moving_pyramid_wall_init".
Definition _bhv_ssl_moving_pyramid_wall_loop : ident := $"bhv_ssl_moving_pyramid_wall_loop".
Definition _bhv_star_door_loop : ident := $"bhv_star_door_loop".
Definition _bhv_star_door_loop_2 : ident := $"bhv_star_door_loop_2".
Definition _bhv_star_key_collection_puff_spawner_loop : ident := $"bhv_star_key_collection_puff_spawner_loop".
Definition _bhv_star_spawn_init : ident := $"bhv_star_spawn_init".
Definition _bhv_star_spawn_loop : ident := $"bhv_star_spawn_loop".
Definition _bhv_static_checkered_platform_loop : ident := $"bhv_static_checkered_platform_loop".
Definition _bhv_strong_wind_particle_loop : ident := $"bhv_strong_wind_particle_loop".
Definition _bhv_sunken_ship_part_loop : ident := $"bhv_sunken_ship_part_loop".
Definition _bhv_sushi_shark_collision_loop : ident := $"bhv_sushi_shark_collision_loop".
Definition _bhv_sushi_shark_loop : ident := $"bhv_sushi_shark_loop".
Definition _bhv_swing_platform_init : ident := $"bhv_swing_platform_init".
Definition _bhv_swing_platform_update : ident := $"bhv_swing_platform_update".
Definition _bhv_swoop_update : ident := $"bhv_swoop_update".
Definition _bhv_tank_fish_group_loop : ident := $"bhv_tank_fish_group_loop".
Definition _bhv_temp_coin_loop : ident := $"bhv_temp_coin_loop".
Definition _bhv_thi_bowling_ball_spawner_loop : ident := $"bhv_thi_bowling_ball_spawner_loop".
Definition _bhv_thi_huge_island_top_loop : ident := $"bhv_thi_huge_island_top_loop".
Definition _bhv_thi_tiny_island_top_loop : ident := $"bhv_thi_tiny_island_top_loop".
Definition _bhv_tilting_inverted_pyramid_loop : ident := $"bhv_tilting_inverted_pyramid_loop".
Definition _bhv_tiny_star_particles_init : ident := $"bhv_tiny_star_particles_init".
Definition _bhv_toad_message_init : ident := $"bhv_toad_message_init".
Definition _bhv_toad_message_loop : ident := $"bhv_toad_message_loop".
Definition _bhv_tower_door_loop : ident := $"bhv_tower_door_loop".
Definition _bhv_tower_platform_group_loop : ident := $"bhv_tower_platform_group_loop".
Definition _bhv_tox_box_loop : ident := $"bhv_tox_box_loop".
Definition _bhv_track_ball_update : ident := $"bhv_track_ball_update".
Definition _bhv_treasure_chest_bottom_init : ident := $"bhv_treasure_chest_bottom_init".
Definition _bhv_treasure_chest_bottom_loop : ident := $"bhv_treasure_chest_bottom_loop".
Definition _bhv_treasure_chest_ddd_init : ident := $"bhv_treasure_chest_ddd_init".
Definition _bhv_treasure_chest_ddd_loop : ident := $"bhv_treasure_chest_ddd_loop".
Definition _bhv_treasure_chest_jrb_init : ident := $"bhv_treasure_chest_jrb_init".
Definition _bhv_treasure_chest_jrb_loop : ident := $"bhv_treasure_chest_jrb_loop".
Definition _bhv_treasure_chest_ship_init : ident := $"bhv_treasure_chest_ship_init".
Definition _bhv_treasure_chest_ship_loop : ident := $"bhv_treasure_chest_ship_loop".
Definition _bhv_treasure_chest_top_loop : ident := $"bhv_treasure_chest_top_loop".
Definition _bhv_tree_snow_or_leaf_loop : ident := $"bhv_tree_snow_or_leaf_loop".
Definition _bhv_triplet_butterfly_update : ident := $"bhv_triplet_butterfly_update".
Definition _bhv_ttc_2d_rotator_init : ident := $"bhv_ttc_2d_rotator_init".
Definition _bhv_ttc_2d_rotator_update : ident := $"bhv_ttc_2d_rotator_update".
Definition _bhv_ttc_cog_init : ident := $"bhv_ttc_cog_init".
Definition _bhv_ttc_cog_update : ident := $"bhv_ttc_cog_update".
Definition _bhv_ttc_elevator_init : ident := $"bhv_ttc_elevator_init".
Definition _bhv_ttc_elevator_update : ident := $"bhv_ttc_elevator_update".
Definition _bhv_ttc_moving_bar_init : ident := $"bhv_ttc_moving_bar_init".
Definition _bhv_ttc_moving_bar_update : ident := $"bhv_ttc_moving_bar_update".
Definition _bhv_ttc_pendulum_init : ident := $"bhv_ttc_pendulum_init".
Definition _bhv_ttc_pendulum_update : ident := $"bhv_ttc_pendulum_update".
Definition _bhv_ttc_pit_block_init : ident := $"bhv_ttc_pit_block_init".
Definition _bhv_ttc_pit_block_update : ident := $"bhv_ttc_pit_block_update".
Definition _bhv_ttc_rotating_solid_init : ident := $"bhv_ttc_rotating_solid_init".
Definition _bhv_ttc_rotating_solid_update : ident := $"bhv_ttc_rotating_solid_update".
Definition _bhv_ttc_spinner_update : ident := $"bhv_ttc_spinner_update".
Definition _bhv_ttc_treadmill_init : ident := $"bhv_ttc_treadmill_init".
Definition _bhv_ttc_treadmill_update : ident := $"bhv_ttc_treadmill_update".
Definition _bhv_ttm_rolling_log_init : ident := $"bhv_ttm_rolling_log_init".
Definition _bhv_tumbling_bridge_loop : ident := $"bhv_tumbling_bridge_loop".
Definition _bhv_tumbling_bridge_platform_loop : ident := $"bhv_tumbling_bridge_platform_loop".
Definition _bhv_tuxies_mother_loop : ident := $"bhv_tuxies_mother_loop".
Definition _bhv_tweester_loop : ident := $"bhv_tweester_loop".
Definition _bhv_tweester_sand_particle_loop : ident := $"bhv_tweester_sand_particle_loop".
Definition _bhv_ukiki_cage_loop : ident := $"bhv_ukiki_cage_loop".
Definition _bhv_ukiki_cage_star_loop : ident := $"bhv_ukiki_cage_star_loop".
Definition _bhv_ukiki_init : ident := $"bhv_ukiki_init".
Definition _bhv_ukiki_loop : ident := $"bhv_ukiki_loop".
Definition _bhv_unagi_init : ident := $"bhv_unagi_init".
Definition _bhv_unagi_loop : ident := $"bhv_unagi_loop".
Definition _bhv_unagi_subobject_loop : ident := $"bhv_unagi_subobject_loop".
Definition _bhv_unlock_door_star_init : ident := $"bhv_unlock_door_star_init".
Definition _bhv_unlock_door_star_loop : ident := $"bhv_unlock_door_star_loop".
Definition _bhv_unused_particle_spawn_loop : ident := $"bhv_unused_particle_spawn_loop".
Definition _bhv_unused_poundable_platform : ident := $"bhv_unused_poundable_platform".
Definition _bhv_vanish_cap_init : ident := $"bhv_vanish_cap_init".
Definition _bhv_volcano_flames_loop : ident := $"bhv_volcano_flames_loop".
Definition _bhv_volcano_sound_loop : ident := $"bhv_volcano_sound_loop".
Definition _bhv_volcano_trap_loop : ident := $"bhv_volcano_trap_loop".
Definition _bhv_wall_tiny_star_particle_loop : ident := $"bhv_wall_tiny_star_particle_loop".
Definition _bhv_warp_loop : ident := $"bhv_warp_loop".
Definition _bhv_water_air_bubble_init : ident := $"bhv_water_air_bubble_init".
Definition _bhv_water_air_bubble_loop : ident := $"bhv_water_air_bubble_loop".
Definition _bhv_water_bomb_cannon_loop : ident := $"bhv_water_bomb_cannon_loop".
Definition _bhv_water_bomb_shadow_update : ident := $"bhv_water_bomb_shadow_update".
Definition _bhv_water_bomb_spawner_update : ident := $"bhv_water_bomb_spawner_update".
Definition _bhv_water_bomb_update : ident := $"bhv_water_bomb_update".
Definition _bhv_water_droplet_loop : ident := $"bhv_water_droplet_loop".
Definition _bhv_water_droplet_splash_init : ident := $"bhv_water_droplet_splash_init".
Definition _bhv_water_level_diamond_loop : ident := $"bhv_water_level_diamond_loop".
Definition _bhv_water_level_pillar_init : ident := $"bhv_water_level_pillar_init".
Definition _bhv_water_level_pillar_loop : ident := $"bhv_water_level_pillar_loop".
Definition _bhv_water_mist_2_loop : ident := $"bhv_water_mist_2_loop".
Definition _bhv_water_mist_loop : ident := $"bhv_water_mist_loop".
Definition _bhv_water_mist_spawn_loop : ident := $"bhv_water_mist_spawn_loop".
Definition _bhv_water_splash_spawn_droplets : ident := $"bhv_water_splash_spawn_droplets".
Definition _bhv_water_waves_init : ident := $"bhv_water_waves_init".
Definition _bhv_waterfall_sound_loop : ident := $"bhv_waterfall_sound_loop".
Definition _bhv_wave_trail_shrink : ident := $"bhv_wave_trail_shrink".
Definition _bhv_wdw_express_elevator_loop : ident := $"bhv_wdw_express_elevator_loop".
Definition _bhv_wf_breakable_wall_loop : ident := $"bhv_wf_breakable_wall_loop".
Definition _bhv_wf_elevator_tower_platform_loop : ident := $"bhv_wf_elevator_tower_platform_loop".
Definition _bhv_wf_rotating_wooden_platform_loop : ident := $"bhv_wf_rotating_wooden_platform_loop".
Definition _bhv_wf_sliding_platform_init : ident := $"bhv_wf_sliding_platform_init".
Definition _bhv_wf_sliding_platform_loop : ident := $"bhv_wf_sliding_platform_loop".
Definition _bhv_wf_sliding_tower_platform_loop : ident := $"bhv_wf_sliding_tower_platform_loop".
Definition _bhv_wf_solid_tower_platform_loop : ident := $"bhv_wf_solid_tower_platform_loop".
Definition _bhv_whirlpool_init : ident := $"bhv_whirlpool_init".
Definition _bhv_whirlpool_loop : ident := $"bhv_whirlpool_loop".
Definition _bhv_white_puff_1_loop : ident := $"bhv_white_puff_1_loop".
Definition _bhv_white_puff_2_loop : ident := $"bhv_white_puff_2_loop".
Definition _bhv_white_puff_exploding_loop : ident := $"bhv_white_puff_exploding_loop".
Definition _bhv_white_puff_smoke_init : ident := $"bhv_white_puff_smoke_init".
Definition _bhv_whomp_loop : ident := $"bhv_whomp_loop".
Definition _bhv_wiggler_body_part_update : ident := $"bhv_wiggler_body_part_update".
Definition _bhv_wiggler_update : ident := $"bhv_wiggler_update".
Definition _bhv_wind_loop : ident := $"bhv_wind_loop".
Definition _bhv_wing_cap_init : ident := $"bhv_wing_cap_init".
Definition _bhv_wing_vanish_cap_loop : ident := $"bhv_wing_vanish_cap_loop".
Definition _bhv_wooden_post_update : ident := $"bhv_wooden_post_update".
Definition _bhv_yellow_coin_init : ident := $"bhv_yellow_coin_init".
Definition _bhv_yellow_coin_loop : ident := $"bhv_yellow_coin_loop".
Definition _bhv_yoshi_init : ident := $"bhv_yoshi_init".
Definition _bhv_yoshi_loop : ident := $"bhv_yoshi_loop".
Definition _birds_seg5_anims_050009E8 : ident := $"birds_seg5_anims_050009E8".
Definition _bitdw_seg7_collision_moving_pyramid : ident := $"bitdw_seg7_collision_moving_pyramid".
Definition _bitfs_seg7_collision_inverted_pyramid : ident := $"bitfs_seg7_collision_inverted_pyramid".
Definition _bitfs_seg7_collision_sinking_cage_platform : ident := $"bitfs_seg7_collision_sinking_cage_platform".
Definition _bitfs_seg7_collision_sinking_platform : ident := $"bitfs_seg7_collision_sinking_platform".
Definition _bitfs_seg7_collision_squishable_platform : ident := $"bitfs_seg7_collision_squishable_platform".
Definition _blue_coin_switch_seg8_collision_08000E98 : ident := $"blue_coin_switch_seg8_collision_08000E98".
Definition _blue_fish_seg3_anims_0301C2B0 : ident := $"blue_fish_seg3_anims_0301C2B0".
Definition _bob_seg7_collision_chain_chomp_gate : ident := $"bob_seg7_collision_chain_chomp_gate".
Definition _bobomb_seg8_anims_0802396C : ident := $"bobomb_seg8_anims_0802396C".
Definition _bookend_seg5_anims_05002540 : ident := $"bookend_seg5_anims_05002540".
Definition _bowser_2_seg7_collision_tilting_platform : ident := $"bowser_2_seg7_collision_tilting_platform".
Definition _bowser_key_seg3_anims_list : ident := $"bowser_key_seg3_anims_list".
Definition _bowser_seg6_anims_06057690 : ident := $"bowser_seg6_anims_06057690".
Definition _breakable_box_seg8_collision_08012D70 : ident := $"breakable_box_seg8_collision_08012D70".
Definition _bub_seg6_anims_06012354 : ident := $"bub_seg6_anims_06012354".
Definition _bully_seg5_anims_0500470C : ident := $"bully_seg5_anims_0500470C".
Definition _butterfly_seg3_anims_030056B0 : ident := $"butterfly_seg3_anims_030056B0".
Definition _cannon_lid_seg8_collision_08004950 : ident := $"cannon_lid_seg8_collision_08004950".
Definition _capswitch_collision_050033D0 : ident := $"capswitch_collision_050033D0".
Definition _capswitch_collision_05003448 : ident := $"capswitch_collision_05003448".
Definition _castle_grounds_seg7_anims_flags : ident := $"castle_grounds_seg7_anims_flags".
Definition _castle_grounds_seg7_collision_cannon_grill : ident := $"castle_grounds_seg7_collision_cannon_grill".
Definition _castle_grounds_seg7_collision_moat_grills : ident := $"castle_grounds_seg7_collision_moat_grills".
Definition _chain_chomp_seg6_anims_06025178 : ident := $"chain_chomp_seg6_anims_06025178".
Definition _chair_seg5_anims_05005784 : ident := $"chair_seg5_anims_05005784".
Definition _checkerboard_platform_seg8_collision_0800D710 : ident := $"checkerboard_platform_seg8_collision_0800D710".
Definition _chilly_chief_seg6_anims_06003994 : ident := $"chilly_chief_seg6_anims_06003994".
Definition _chuckya_seg8_anims_0800C070 : ident := $"chuckya_seg8_anims_0800C070".
Definition _clam_shell_seg5_anims_05001744 : ident := $"clam_shell_seg5_anims_05001744".
Definition _cur_obj_compute_vel_xz : ident := $"cur_obj_compute_vel_xz".
Definition _cur_obj_move_using_fvel_and_gravity : ident := $"cur_obj_move_using_fvel_and_gravity".
Definition _cur_obj_rotate_face_angle_using_vel : ident := $"cur_obj_rotate_face_angle_using_vel".
Definition _cur_obj_update_floor_and_walls : ident := $"cur_obj_update_floor_and_walls".
Definition _dAmpAnimsList : ident := $"dAmpAnimsList".
Definition _ddd_seg7_collision_bowser_sub_door : ident := $"ddd_seg7_collision_bowser_sub_door".
Definition _ddd_seg7_collision_submarine : ident := $"ddd_seg7_collision_submarine".
Definition _door_seg3_anims_030156C0 : ident := $"door_seg3_anims_030156C0".
Definition _door_seg3_collision_0301CE78 : ident := $"door_seg3_collision_0301CE78".
Definition _dorrie_seg6_anims_0600F638 : ident := $"dorrie_seg6_anims_0600F638".
Definition _dorrie_seg6_collision_0600F644 : ident := $"dorrie_seg6_collision_0600F644".
Definition _exclamation_box_outline_seg8_collision_08025F78 : ident := $"exclamation_box_outline_seg8_collision_08025F78".
Definition _eyerok_seg5_anims_050116E4 : ident := $"eyerok_seg5_anims_050116E4".
Definition _flags : ident := $"flags".
Definition _flyguy_seg8_anims_08011A64 : ident := $"flyguy_seg8_anims_08011A64".
Definition _gShallowWaterSplashDropletParams : ident := $"gShallowWaterSplashDropletParams".
Definition _gShallowWaterWaveDropletParams : ident := $"gShallowWaterWaveDropletParams".
Definition _goomba_seg8_anims_0801DA4C : ident := $"goomba_seg8_anims_0801DA4C".
Definition _heave_ho_seg5_anims_0501534C : ident := $"heave_ho_seg5_anims_0501534C".
Definition _hmc_seg7_collision_controllable_platform : ident := $"hmc_seg7_collision_controllable_platform".
Definition _hmc_seg7_collision_controllable_platform_sub : ident := $"hmc_seg7_collision_controllable_platform_sub".
Definition _hmc_seg7_collision_elevator : ident := $"hmc_seg7_collision_elevator".
Definition _hoot_seg5_anims_05005768 : ident := $"hoot_seg5_anims_05005768".
Definition _index : ident := $"index".
Definition _inside_castle_seg7_collision_floor_trap : ident := $"inside_castle_seg7_collision_floor_trap".
Definition _inside_castle_seg7_collision_star_door : ident := $"inside_castle_seg7_collision_star_door".
Definition _inside_castle_seg7_collision_water_level_pillar : ident := $"inside_castle_seg7_collision_water_level_pillar".
Definition _jrb_seg7_collision_floating_box : ident := $"jrb_seg7_collision_floating_box".
Definition _jrb_seg7_collision_floating_platform : ident := $"jrb_seg7_collision_floating_platform".
Definition _jrb_seg7_collision_in_sunken_ship : ident := $"jrb_seg7_collision_in_sunken_ship".
Definition _jrb_seg7_collision_in_sunken_ship_2 : ident := $"jrb_seg7_collision_in_sunken_ship_2".
Definition _jrb_seg7_collision_in_sunken_ship_3 : ident := $"jrb_seg7_collision_in_sunken_ship_3".
Definition _jrb_seg7_collision_pillar_base : ident := $"jrb_seg7_collision_pillar_base".
Definition _jrb_seg7_collision_rock_solid : ident := $"jrb_seg7_collision_rock_solid".
Definition _king_bobomb_seg5_anims_0500FE30 : ident := $"king_bobomb_seg5_anims_0500FE30".
Definition _klepto_seg5_anims_05008CFC : ident := $"klepto_seg5_anims_05008CFC".
Definition _koopa_flag_seg6_anims_06001028 : ident := $"koopa_flag_seg6_anims_06001028".
Definition _koopa_seg6_anims_06011364 : ident := $"koopa_seg6_anims_06011364".
Definition _lakitu_enemy_seg5_anims_050144D4 : ident := $"lakitu_enemy_seg5_anims_050144D4".
Definition _lakitu_seg6_anims_060058F8 : ident := $"lakitu_seg6_anims_060058F8".
Definition _length : ident := $"length".
Definition _lll_hexagonal_mesh_seg3_collision_0301CECC : ident := $"lll_hexagonal_mesh_seg3_collision_0301CECC".
Definition _lll_seg7_collision_drawbridge : ident := $"lll_seg7_collision_drawbridge".
Definition _lll_seg7_collision_falling_wall : ident := $"lll_seg7_collision_falling_wall".
Definition _lll_seg7_collision_floating_block : ident := $"lll_seg7_collision_floating_block".
Definition _lll_seg7_collision_hexagonal_platform : ident := $"lll_seg7_collision_hexagonal_platform".
Definition _lll_seg7_collision_inverted_pyramid : ident := $"lll_seg7_collision_inverted_pyramid".
Definition _lll_seg7_collision_octagonal_moving_platform : ident := $"lll_seg7_collision_octagonal_moving_platform".
Definition _lll_seg7_collision_pitoune : ident := $"lll_seg7_collision_pitoune".
Definition _lll_seg7_collision_puzzle_piece : ident := $"lll_seg7_collision_puzzle_piece".
Definition _lll_seg7_collision_rotating_fire_bars : ident := $"lll_seg7_collision_rotating_fire_bars".
Definition _lll_seg7_collision_rotating_platform : ident := $"lll_seg7_collision_rotating_platform".
Definition _lll_seg7_collision_sinking_pyramids : ident := $"lll_seg7_collision_sinking_pyramids".
Definition _lll_seg7_collision_slow_tilting_platform : ident := $"lll_seg7_collision_slow_tilting_platform".
Definition _lll_seg7_collision_wood_piece : ident := $"lll_seg7_collision_wood_piece".
Definition _load_object_collision_model : ident := $"load_object_collision_model".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _mad_piano_seg5_anims_05009B14 : ident := $"mad_piano_seg5_anims_05009B14".
Definition _main : ident := $"main".
Definition _manta_seg5_anims_05008EB4 : ident := $"manta_seg5_anims_05008EB4".
Definition _metal_box_seg8_collision_08024C28 : ident := $"metal_box_seg8_collision_08024C28".
Definition _mips_seg6_anims_06015634 : ident := $"mips_seg6_anims_06015634".
Definition _model : ident := $"model".
Definition _moneybag_seg6_anims_06005E5C : ident := $"moneybag_seg6_anims_06005E5C".
Definition _monty_mole_seg5_anims_05007248 : ident := $"monty_mole_seg5_anims_05007248".
Definition _moveAngleRange : ident := $"moveAngleRange".
Definition _moveRange : ident := $"moveRange".
Definition _peach_seg5_anims_0501C41C : ident := $"peach_seg5_anims_0501C41C".
Definition _penguin_seg5_anims_05008B74 : ident := $"penguin_seg5_anims_05008B74".
Definition _penguin_seg5_collision_05008B88 : ident := $"penguin_seg5_collision_05008B88".
Definition _piranha_plant_seg6_anims_0601C31C : ident := $"piranha_plant_seg6_anims_0601C31C".
Definition _poundable_pole_collision_06002490 : ident := $"poundable_pole_collision_06002490".
Definition _purple_switch_seg8_collision_0800C7A8 : ident := $"purple_switch_seg8_collision_0800C7A8".
Definition _randForwardVelOffset : ident := $"randForwardVelOffset".
Definition _randForwardVelScale : ident := $"randForwardVelScale".
Definition _randSizeOffset : ident := $"randSizeOffset".
Definition _randSizeScale : ident := $"randSizeScale".
Definition _randYVelOffset : ident := $"randYVelOffset".
Definition _randYVelScale : ident := $"randYVelScale".
Definition _rr_seg7_collision_donut_platform : ident := $"rr_seg7_collision_donut_platform".
Definition _rr_seg7_collision_elevator_platform : ident := $"rr_seg7_collision_elevator_platform".
Definition _rr_seg7_collision_pendulum : ident := $"rr_seg7_collision_pendulum".
Definition _rr_seg7_collision_rotating_platform_with_fire : ident := $"rr_seg7_collision_rotating_platform_with_fire".
Definition _scuttlebug_seg6_anims_06015064 : ident := $"scuttlebug_seg6_anims_06015064".
Definition _seaweed_seg6_anims_0600A4D4 : ident := $"seaweed_seg6_anims_0600A4D4".
Definition _skeeter_seg6_anims_06007DE0 : ident := $"skeeter_seg6_anims_06007DE0".
Definition _sl_seg7_collision_pound_explodes : ident := $"sl_seg7_collision_pound_explodes".
Definition _sl_seg7_collision_sliding_snow_mound : ident := $"sl_seg7_collision_sliding_snow_mound".
Definition _snowman_seg5_anims_0500D118 : ident := $"snowman_seg5_anims_0500D118".
Definition _spindrift_seg5_anims_05002D68 : ident := $"spindrift_seg5_anims_05002D68".
Definition _spiny_seg5_anims_05016EAC : ident := $"spiny_seg5_anims_05016EAC".
Definition _springboard_collision_05001A28 : ident := $"springboard_collision_05001A28".
Definition _ssl_seg7_collision_0702808C : ident := $"ssl_seg7_collision_0702808C".
Definition _ssl_seg7_collision_grindel : ident := $"ssl_seg7_collision_grindel".
Definition _ssl_seg7_collision_pyramid_elevator : ident := $"ssl_seg7_collision_pyramid_elevator".
Definition _ssl_seg7_collision_pyramid_top : ident := $"ssl_seg7_collision_pyramid_top".
Definition _ssl_seg7_collision_spindel : ident := $"ssl_seg7_collision_spindel".
Definition _ssl_seg7_collision_tox_box : ident := $"ssl_seg7_collision_tox_box".
Definition _startFrame : ident := $"startFrame".
Definition _sushi_seg5_anims_0500AE54 : ident := $"sushi_seg5_anims_0500AE54".
Definition _swoop_seg6_anims_060070D0 : ident := $"swoop_seg6_anims_060070D0".
Definition _thi_seg7_collision_top_trap : ident := $"thi_seg7_collision_top_trap".
Definition _thwomp_seg5_collision_0500B7D0 : ident := $"thwomp_seg5_collision_0500B7D0".
Definition _thwomp_seg5_collision_0500B92C : ident := $"thwomp_seg5_collision_0500B92C".
Definition _toad_seg6_anims_0600FB58 : ident := $"toad_seg6_anims_0600FB58".
Definition _try_do_mario_debug_object_spawn : ident := $"try_do_mario_debug_object_spawn".
Definition _try_print_debug_mario_level_info : ident := $"try_print_debug_mario_level_info".
Definition _ttc_seg7_collision_clock_main_rotation : ident := $"ttc_seg7_collision_clock_main_rotation".
Definition _ttc_seg7_collision_clock_pendulum : ident := $"ttc_seg7_collision_clock_pendulum".
Definition _ttc_seg7_collision_clock_platform : ident := $"ttc_seg7_collision_clock_platform".
Definition _ttc_seg7_collision_rotating_clock_platform2 : ident := $"ttc_seg7_collision_rotating_clock_platform2".
Definition _ttc_seg7_collision_sliding_surface : ident := $"ttc_seg7_collision_sliding_surface".
Definition _ttm_seg7_collision_pitoune_2 : ident := $"ttm_seg7_collision_pitoune_2".
Definition _ttm_seg7_collision_podium_warp : ident := $"ttm_seg7_collision_podium_warp".
Definition _ttm_seg7_collision_ukiki_cage : ident := $"ttm_seg7_collision_ukiki_cage".
Definition _ukiki_seg5_anims_05015784 : ident := $"ukiki_seg5_anims_05015784".
Definition _unagi_seg5_anims_05012824 : ident := $"unagi_seg5_anims_05012824".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _values : ident := $"values".
Definition _warp_pipe_seg3_collision_03009AC8 : ident := $"warp_pipe_seg3_collision_03009AC8".
Definition _water_ring_seg6_anims_06013F7C : ident := $"water_ring_seg6_anims_06013F7C".
Definition _wdw_seg7_collision_arrow_lift : ident := $"wdw_seg7_collision_arrow_lift".
Definition _wdw_seg7_collision_express_elevator_platform : ident := $"wdw_seg7_collision_express_elevator_platform".
Definition _wdw_seg7_collision_rect_floating_platform : ident := $"wdw_seg7_collision_rect_floating_platform".
Definition _wdw_seg7_collision_square_floating_platform : ident := $"wdw_seg7_collision_square_floating_platform".
Definition _wf_seg7_collision_breakable_wall : ident := $"wf_seg7_collision_breakable_wall".
Definition _wf_seg7_collision_breakable_wall_2 : ident := $"wf_seg7_collision_breakable_wall_2".
Definition _wf_seg7_collision_bullet_bill_cannon : ident := $"wf_seg7_collision_bullet_bill_cannon".
Definition _wf_seg7_collision_clocklike_rotation : ident := $"wf_seg7_collision_clocklike_rotation".
Definition _wf_seg7_collision_kickable_board : ident := $"wf_seg7_collision_kickable_board".
Definition _wf_seg7_collision_large_bomp : ident := $"wf_seg7_collision_large_bomp".
Definition _wf_seg7_collision_platform : ident := $"wf_seg7_collision_platform".
Definition _wf_seg7_collision_sliding_brick_platform : ident := $"wf_seg7_collision_sliding_brick_platform".
Definition _wf_seg7_collision_small_bomp : ident := $"wf_seg7_collision_small_bomp".
Definition _wf_seg7_collision_tower : ident := $"wf_seg7_collision_tower".
Definition _wf_seg7_collision_tower_door : ident := $"wf_seg7_collision_tower_door".
Definition _whomp_seg6_anims_06020A04 : ident := $"whomp_seg6_anims_06020A04".
Definition _whomp_seg6_collision_06020A0C : ident := $"whomp_seg6_collision_06020A0C".
Definition _wiggler_seg5_anims_0500C874 : ident := $"wiggler_seg5_anims_0500C874".
Definition _wiggler_seg5_anims_0500EC8C : ident := $"wiggler_seg5_anims_0500EC8C".
Definition _wooden_signpost_seg3_collision_0302DD80 : ident := $"wooden_signpost_seg3_collision_0302DD80".
Definition _yoshi_seg5_anims_05024100 : ident := $"yoshi_seg5_anims_05024100".

Definition v_gShallowWaterSplashDropletParams := {|
  gvar_info := (Tstruct _WaterDropletParams noattr);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gShallowWaterWaveDropletParams := {|
  gvar_info := (Tstruct _WaterDropletParams noattr);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_dAmpAnimsList := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_blue_coin_switch_seg8_collision_08000E98 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bobomb_seg8_anims_0802396C := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_breakable_box_seg8_collision_08012D70 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_cannon_lid_seg8_collision_08004950 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_checkerboard_platform_seg8_collision_0800D710 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_chuckya_seg8_anims_0800C070 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_exclamation_box_outline_seg8_collision_08025F78 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_flyguy_seg8_anims_08011A64 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_goomba_seg8_anims_0801DA4C := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_metal_box_seg8_collision_08024C28 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_purple_switch_seg8_collision_0800C7A8 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_blue_fish_seg3_anims_0301C2B0 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bowser_key_seg3_anims_list := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_butterfly_seg3_anims_030056B0 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_door_seg3_anims_030156C0 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_door_seg3_collision_0301CE78 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_lll_hexagonal_mesh_seg3_collision_0301CECC := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_warp_pipe_seg3_collision_03009AC8 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_wooden_signpost_seg3_collision_0302DD80 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_heave_ho_seg5_anims_0501534C := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_hoot_seg5_anims_05005768 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_thwomp_seg5_collision_0500B7D0 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_thwomp_seg5_collision_0500B92C := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bully_seg5_anims_0500470C := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_king_bobomb_seg5_anims_0500FE30 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_clam_shell_seg5_anims_05001744 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_manta_seg5_anims_05008EB4 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_sushi_seg5_anims_0500AE54 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_unagi_seg5_anims_05012824 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_eyerok_seg5_anims_050116E4 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_klepto_seg5_anims_05008CFC := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_monty_mole_seg5_anims_05007248 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_ukiki_seg5_anims_05015784 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_penguin_seg5_anims_05008B74 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_penguin_seg5_collision_05008B88 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_snowman_seg5_anims_0500D118 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_spindrift_seg5_anims_05002D68 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_capswitch_collision_050033D0 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_capswitch_collision_05003448 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_springboard_collision_05001A28 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bookend_seg5_anims_05002540 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_chair_seg5_anims_05005784 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_mad_piano_seg5_anims_05009B14 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_birds_seg5_anims_050009E8 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_peach_seg5_anims_0501C41C := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_yoshi_seg5_anims_05024100 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_lakitu_enemy_seg5_anims_050144D4 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_spiny_seg5_anims_05016EAC := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_wiggler_seg5_anims_0500C874 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_wiggler_seg5_anims_0500EC8C := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bowser_seg6_anims_06057690 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bub_seg6_anims_06012354 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_seaweed_seg6_anims_0600A4D4 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_skeeter_seg6_anims_06007DE0 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_water_ring_seg6_anims_06013F7C := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_chain_chomp_seg6_anims_06025178 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_koopa_seg6_anims_06011364 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_koopa_flag_seg6_anims_06001028 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_piranha_plant_seg6_anims_0601C31C := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_poundable_pole_collision_06002490 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_whomp_seg6_anims_06020A04 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_whomp_seg6_collision_06020A0C := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_lakitu_seg6_anims_060058F8 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_mips_seg6_anims_06015634 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_toad_seg6_anims_0600FB58 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_chilly_chief_seg6_anims_06003994 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_moneybag_seg6_anims_06005E5C := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_dorrie_seg6_anims_0600F638 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_dorrie_seg6_collision_0600F644 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_scuttlebug_seg6_anims_06015064 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_swoop_seg6_anims_060070D0 := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bbh_seg7_collision_staircase_step := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bbh_seg7_collision_tilt_floor_platform := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bbh_seg7_collision_haunted_bookshelf := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bbh_seg7_collision_mesh_elevator := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bbh_seg7_collision_merry_go_round := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bbh_seg7_collision_coffin := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_inside_castle_seg7_collision_floor_trap := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_inside_castle_seg7_collision_star_door := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_inside_castle_seg7_collision_water_level_pillar := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_hmc_seg7_collision_elevator := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_hmc_seg7_collision_controllable_platform := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_hmc_seg7_collision_controllable_platform_sub := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_ssl_seg7_collision_pyramid_top := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_ssl_seg7_collision_tox_box := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_ssl_seg7_collision_grindel := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_ssl_seg7_collision_spindel := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_ssl_seg7_collision_0702808C := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_ssl_seg7_collision_pyramid_elevator := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bob_seg7_collision_chain_chomp_gate := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_sl_seg7_collision_sliding_snow_mound := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_sl_seg7_collision_pound_explodes := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_wdw_seg7_collision_square_floating_platform := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_wdw_seg7_collision_arrow_lift := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_wdw_seg7_collision_express_elevator_platform := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_wdw_seg7_collision_rect_floating_platform := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_jrb_seg7_collision_rock_solid := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_jrb_seg7_collision_floating_platform := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_jrb_seg7_collision_floating_box := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_jrb_seg7_collision_in_sunken_ship_3 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_jrb_seg7_collision_in_sunken_ship := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_jrb_seg7_collision_in_sunken_ship_2 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_jrb_seg7_collision_pillar_base := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_thi_seg7_collision_top_trap := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_ttc_seg7_collision_clock_pendulum := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_ttc_seg7_collision_sliding_surface := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_ttc_seg7_collision_clock_platform := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_ttc_seg7_collision_clock_main_rotation := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_ttc_seg7_collision_rotating_clock_platform2 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_rr_seg7_collision_pendulum := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_rr_seg7_collision_rotating_platform_with_fire := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_rr_seg7_collision_elevator_platform := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_rr_seg7_collision_donut_platform := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_castle_grounds_seg7_anims_flags := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_castle_grounds_seg7_collision_moat_grills := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_castle_grounds_seg7_collision_cannon_grill := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bitdw_seg7_collision_moving_pyramid := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_lll_seg7_collision_octagonal_moving_platform := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_lll_seg7_collision_drawbridge := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_lll_seg7_collision_rotating_fire_bars := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_lll_seg7_collision_wood_piece := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_lll_seg7_collision_rotating_platform := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_lll_seg7_collision_slow_tilting_platform := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_lll_seg7_collision_sinking_pyramids := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_lll_seg7_collision_inverted_pyramid := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_lll_seg7_collision_puzzle_piece := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_lll_seg7_collision_floating_block := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_lll_seg7_collision_pitoune := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_lll_seg7_collision_hexagonal_platform := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_lll_seg7_collision_falling_wall := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bitfs_seg7_collision_sinking_cage_platform := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bitfs_seg7_collision_inverted_pyramid := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bitfs_seg7_collision_squishable_platform := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bitfs_seg7_collision_sinking_platform := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_ddd_seg7_collision_submarine := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_ddd_seg7_collision_bowser_sub_door := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_wf_seg7_collision_small_bomp := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_wf_seg7_collision_large_bomp := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_wf_seg7_collision_clocklike_rotation := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_wf_seg7_collision_sliding_brick_platform := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_wf_seg7_collision_platform := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_wf_seg7_collision_breakable_wall := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_wf_seg7_collision_breakable_wall_2 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_wf_seg7_collision_kickable_board := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_wf_seg7_collision_tower_door := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_wf_seg7_collision_tower := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_wf_seg7_collision_bullet_bill_cannon := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bowser_2_seg7_collision_tilting_platform := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_ttm_seg7_collision_pitoune_2 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_ttm_seg7_collision_ukiki_cage := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_ttm_seg7_collision_podium_warp := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvStarDoor := {|
  gvar_info := (tarray tuint 21);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 271187972) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _inside_castle_seg7_collision_star_door (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 272760864) ::
                Init_int32 (Int.repr 285278401) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 5242980) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 239423008) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_door_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_star_door_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_star_door_loop_2 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMrI := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278283) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 469762048) ::
                Init_int32 (Int.repr 102) ::
                Init_addrof _bhvMrIBody (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 452984935) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_mr_i_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMrIBody := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_mr_i_body_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMrIParticle := {|
  gvar_info := (tarray tuint 19);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 285278211) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 3276850) ::
                Init_int32 (Int.repr 272498689) ::
                Init_int32 (Int.repr 271187976) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 1966080) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_mr_i_particle_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPurpleParticle := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 83886090) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_piranha_particle_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvGiantPole := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 655360) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 271188032) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 5244980) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_giant_pole_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPoleGrabbing := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 655360) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 271188032) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 5244380) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_pole_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_pole_base_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTHIHugeIslandTop := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _thi_seg7_collision_top_trap (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_thi_huge_island_top_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTHITinyIslandTop := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_thi_tiny_island_top_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCapSwitchBase := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _capswitch_collision_05003448 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCapSwitch := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _capswitch_collision_050033D0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_cap_switch_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvKingBobomb := {|
  gvar_info := (tarray tuint 24);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286601) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _king_bobomb_seg5_anims_0500FE30 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 271187970) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 6553700) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2031216) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 738197504) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvBobombAnchorMario (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 272564227) ::
                Init_int32 (Int.repr 272498689) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_king_bobomb_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBobombAnchorMario := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 237764708) ::
                Init_int32 (Int.repr 237895830) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bobomb_anchor_mario_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBetaChestBottom := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_beta_chest_bottom_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_beta_chest_bottom_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBetaChestLid := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_beta_chest_lid_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBubbleParticleSpawner := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 889192448) ::
                Init_int32 (Int.repr 354091010) ::
                Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 622526464) ::
                Init_int32 (Int.repr 469762048) ::
                Init_int32 (Int.repr 168) ::
                Init_addrof _bhvSmallWaterWave (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 857079808) ::
                Init_int32 (Int.repr 32) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBubbleMaybe := {|
  gvar_info := (tarray tuint 21);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bubble_wave_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 337379253) ::
                Init_int32 (Int.repr 9830400) ::
                Init_int32 (Int.repr 337444789) ::
                Init_int32 (Int.repr 9830400) ::
                Init_int32 (Int.repr 337510325) ::
                Init_int32 (Int.repr 9830400) ::
                Init_int32 (Int.repr 520488475) ::
                Init_int32 (Int.repr 520620060) ::
                Init_int32 (Int.repr 520554269) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 83886140) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bubble_maybe_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSmallWaterWave := {|
  gvar_info := (tarray tuint 24);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bubble_wave_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 337379278) ::
                Init_int32 (Int.repr 6553600) ::
                Init_int32 (Int.repr 337444814) ::
                Init_int32 (Int.repr 6553600) ::
                Init_int32 (Int.repr 520488475) ::
                Init_int32 (Int.repr 520620060) ::
                Init_int32 (Int.repr 337444864) ::
                Init_int32 (Int.repr 3276800) ::
                Init_int32 (Int.repr 520554269) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 33554432) ::
                Init_addrof _bhvSmallWaterWave398 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 83886140) ::
                Init_int32 (Int.repr 33554432) ::
                Init_addrof _bhvSmallWaterWave398 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_small_water_wave_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSmallWaterWave398 := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 218562567) ::
                Init_int32 (Int.repr 337379326) ::
                Init_int32 (Int.repr 327680) ::
                Init_int32 (Int.repr 337444862) ::
                Init_int32 (Int.repr 327680) ::
                Init_int32 (Int.repr 520488475) ::
                Init_int32 (Int.repr 520620060) ::
                Init_int32 (Int.repr 50331648) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWaterAirBubble := {|
  gvar_info := (tarray tuint 17);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 721420288) ::
                Init_int32 (Int.repr 26214550) ::
                Init_int32 (Int.repr (-9830400)) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 65536) ::
                Init_int32 (Int.repr 272498693) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_water_air_bubble_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_water_air_bubble_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSmallParticle := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_particle_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 83886150) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_particle_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPlungeBubble := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 857079808) ::
                Init_int32 (Int.repr 512) ::
                Init_int32 (Int.repr 889192448) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_water_waves_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSmallParticleSnow := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_particle_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 83886110) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_particle_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSmallParticleBubbles := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_particle_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 83886150) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_small_bubbles_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFishGroup := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_fish_group_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCannon := {|
  gvar_info := (tarray tuint 15);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278409) ::
                Init_int32 (Int.repr 469762048) ::
                Init_int32 (Int.repr 127) ::
                Init_addrof _bhvCannonBarrel (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 271204352) ::
                Init_int32 (Int.repr 218627756) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 9830550) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_cannon_base_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCannonBarrel := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278409) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_cannon_barrel_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCannonBaseUnused := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278219) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 83886088) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_cannon_base_unused_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvChuckya := {|
  gvar_info := (tarray tuint 23);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285279305) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _chuckya_seg8_anims_0800C070 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671416320) ::
                Init_int32 (Int.repr 271187970) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 9830500) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2031216) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 738197504) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvChuckyaAnchorMario (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 272891909) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_chuckya_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvChuckyaAnchorMario := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 237895620) ::
                Init_int32 (Int.repr 237895830) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_chuckya_anchor_mario_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvUnused05A8 := {|
  gvar_info := (tarray tuint 3);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvRotatingPlatform := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_rotating_platform_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTower := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _wf_seg7_collision_tower (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 239274936) ::
                Init_int32 (Int.repr 239423008) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBulletBillCannon := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _wf_seg7_collision_bullet_bill_cannon (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 239272236) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWFBreakableWallRight := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _wf_seg7_collision_breakable_wall (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 67108864) ::
                Init_addrof _bhvWFBreakableWallLeft (Ptrofs.repr 12) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWFBreakableWallLeft := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _wf_seg7_collision_breakable_wall_2 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 285278409) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 19661200) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_wf_breakable_wall_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvKickableBoard := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285286601) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _wf_seg7_collision_kickable_board (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 6554800) ::
                Init_int32 (Int.repr 771751936) ::
                Init_int32 (Int.repr 65537) ::
                Init_int32 (Int.repr 239273436) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_kickable_board_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTowerDoor := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278401) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _wf_seg7_collision_tower_door (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 6553700) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_tower_door_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvRotatingCounterClockwise := {|
  gvar_info := (tarray tuint 2);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWFRotatingWoodenPlatform := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _wf_seg7_collision_clocklike_rotation (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_wf_rotating_wooden_platform_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvKoopaShellUnderwater := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285279297) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_koopa_shell_underwater_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvExitPodiumWarp := {|
  gvar_info := (tarray tuint 15);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 271196160) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 239279936) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _ttm_seg7_collision_podium_warp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 3276850) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 271253504) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFadingWarp := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 272760833) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 271196160) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_fading_warp_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWarp := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 271196160) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_warp_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWarpPipe := {|
  gvar_info := (tarray tuint 15);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 271196160) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _warp_pipe_seg3_collision_03009AC8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 239419008) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 4587570) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_warp_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWhitePuffExplosion := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_white_puff_exploding_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSpawnedStar := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 271515649) ::
                Init_int32 (Int.repr 67108864) ::
                Init_addrof _bhvSpawnedStarNoLevelExit (Ptrofs.repr 8) ::
                nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSpawnedStarNoLevelExit := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_spawned_star_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_spawned_star_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSpawnedBlueCoin := {|
  gvar_info := (tarray tuint 22);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 271187984) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 237109268) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2031216) ::
                Init_int32 (Int.repr (-4586520)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_spawned_coin_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 272498693) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 7864384) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_spawned_coin_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCoinInsideBoo := {|
  gvar_info := (tarray tuint 18);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 6553664) ::
                Init_int32 (Int.repr 271187984) ::
                Init_int32 (Int.repr 285278337) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2031216) ::
                Init_int32 (Int.repr (-4586520)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_coin_inside_boo_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCoinFormationSpawn := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_coin_formation_spawn_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCoinFormation := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 720896) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_coin_formation_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_coin_formation_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvOneCoin := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 271515649) ::
                Init_int32 (Int.repr 67108864) ::
                Init_addrof _bhvYellowCoin (Ptrofs.repr 4) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvYellowCoin := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_yellow_coin_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_yellow_coin_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTemporaryYellowCoin := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_yellow_coin_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_temp_coin_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvThreeCoinsSpawn := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 83886083) ::
                Init_int32 (Int.repr 469762048) ::
                Init_int32 (Int.repr 116) ::
                Init_addrof _bhvSingleCoinGetsSpawned (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTenCoinsSpawn := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 83886090) ::
                Init_int32 (Int.repr 469762048) ::
                Init_int32 (Int.repr 116) ::
                Init_addrof _bhvSingleCoinGetsSpawned (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSingleCoinGetsSpawned := {|
  gvar_info := (tarray tuint 15);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_spawned_coin_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2031216) ::
                Init_int32 (Int.repr (-4586520)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_spawned_coin_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCoinSparkles := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 236257305) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 83886088) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 83886082) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_coin_sparkles_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvGoldenCoinSparkles := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 889192448) ::
                Init_int32 (Int.repr 83886083) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_golden_coin_sparkles_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWallTinyStarParticle := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 83886090) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_wall_tiny_star_particle_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvVertStarParticleSpawner := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 889192448) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 857079808) ::
                Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_tiny_star_particles_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPoundTinyStarParticle := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 83886090) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_pound_tiny_star_particle_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvHorStarParticleSpawner := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 889192448) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 857079808) ::
                Init_int32 (Int.repr 16) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_pound_tiny_star_particle_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPunchTinyTriangle := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_punch_tiny_triangle_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTriangleParticleSpawner := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 889192448) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 857079808) ::
                Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_punch_tiny_triangle_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvDoorWarp := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 271190016) ::
                Init_int32 (Int.repr 67108864) ::
                Init_addrof _bhvDoor (Ptrofs.repr 8) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvDoor := {|
  gvar_info := (tarray tuint 19);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 271187972) ::
                Init_int32 (Int.repr 285278409) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _door_seg3_anims_030156C0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _door_seg3_collision_0301CE78 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 5242980) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 239272936) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_door_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_door_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvGrindel := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _ssl_seg7_collision_grindel (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 218562561) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_grindel_thwomp_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvThwomp := {|
  gvar_info := (tarray tuint 15);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _thwomp_seg5_collision_0500B92C (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 218562561) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 838860940) ::
                Init_int32 (Int.repr 239407008) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_grindel_thwomp_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvThwomp2 := {|
  gvar_info := (tarray tuint 15);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _thwomp_seg5_collision_0500B7D0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 218562561) ::
                Init_int32 (Int.repr 838860940) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 239407008) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_grindel_thwomp_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTumblingBridgePlatform := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 239272236) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_tumbling_bridge_platform_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTumblingBridge := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 720896) ::
                Init_int32 (Int.repr 285278401) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_tumbling_bridge_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBBHTumblingBridge := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 720896) ::
                Init_int32 (Int.repr 285278401) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 271515649) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_tumbling_bridge_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvLLLTumblingBridge := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 720896) ::
                Init_int32 (Int.repr 285278401) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 271515650) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_tumbling_bridge_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFlame := {|
  gvar_info := (tarray tuint 17);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 838861500) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 721420288) ::
                Init_int32 (Int.repr 3276825) ::
                Init_int32 (Int.repr 1638400) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 271253504) ::
                Init_int32 (Int.repr 874119170) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvAnotherElavator := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _hmc_seg7_collision_elevator (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_elevator_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_elevator_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvRRElevatorPlatform := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _rr_seg7_collision_elevator_platform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_elevator_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_elevator_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvHMCElevatorPlatform := {|
  gvar_info := (tarray tuint 15);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _hmc_seg7_collision_elevator (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_elevator_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_elevator_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWaterMist := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 272433406) ::
                Init_int32 (Int.repr 235667476) ::
                Init_int32 (Int.repr 235601912) ::
                Init_int32 (Int.repr 218562622) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_water_mist_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBreathParticleSpawner := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 83886088) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_water_mist_spawn_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBreakBoxTriangle := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 83886098) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _cur_obj_rotate_face_angle_using_vel (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _cur_obj_move_using_fvel_and_gravity (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWaterMist2 := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 269664256) ::
                Init_int32 (Int.repr 838862900) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_water_mist_2_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvUnused0DFC := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 236060672) ::
                Init_int32 (Int.repr 236126208) ::
                Init_int32 (Int.repr 236191744) ::
                Init_int32 (Int.repr 83886086) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMistCircParticleSpawner := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_pound_white_puffs_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvDirtParticleSpawner := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ground_sand_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSnowParticleSpawner := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ground_snow_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWind := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_wind_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvEndToad := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _toad_seg6_anims_0600FB58 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_end_toad_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvEndPeach := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _peach_seg5_anims_0501C41C (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_end_peach_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvUnusedParticleSpawn := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2031216) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 2621480) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_unused_particle_spawn_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvUkiki := {|
  gvar_info := (tarray tuint 3);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 67108864) ::
                Init_addrof _bhvMacroUkiki (Ptrofs.repr 4) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvUkikiCageChild := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 235276800) ::
                Init_int32 (Int.repr 235341233) ::
                Init_int32 (Int.repr 235407210) ::
                Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvUkikiCageStar := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ukiki_cage_star_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvUkikiCage := {|
  gvar_info := (tarray tuint 21);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _ttm_seg7_collision_ukiki_cage (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 469762048) ::
                Init_int32 (Int.repr 122) ::
                Init_addrof _bhvUkikiCageStar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 469762048) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvUkikiCageChild (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 239291936) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2031216) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ukiki_cage_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBitFSSinkingPlatforms := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _bitfs_seg7_collision_sinking_platform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bitfs_sinking_platform_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBitFSSinkingCagePlatform := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _bitfs_seg7_collision_sinking_cage_platform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 469762048) ::
                Init_int32 (Int.repr 57) ::
                Init_addrof _bhvDDDMovingPole (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bitfs_sinking_cage_platform_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvDDDMovingPole := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 655360) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 271188032) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 5243590) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ddd_moving_pole_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_pole_base_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBitFSTiltingInvertedPyramid := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _bitfs_seg7_collision_inverted_pyramid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_platform_normals_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_tilting_inverted_pyramid_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSquishablePlatform := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _bitfs_seg7_collision_squishable_platform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 239281936) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_platform_normals_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_squishable_platform_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCutOutObject := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 889192448) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBetaMovingFlamesSpawn := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_beta_moving_flames_spawn_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBetaMovingFlames := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278219) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_beta_moving_flames_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvRRRotatingBridgePlatform := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _rr_seg7_collision_rotating_platform_with_fire (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 239273436) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_rr_rotating_bridge_platform_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFlamethrower := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_flamethrower_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFlamethrowerFlame := {|
  gvar_info := (tarray tuint 17);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 721420288) ::
                Init_int32 (Int.repr 3276825) ::
                Init_int32 (Int.repr 1638400) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_flamethrower_flame_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBouncingFireball := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 889192448) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bouncing_fireball_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBouncingFireballFlame := {|
  gvar_info := (tarray tuint 19);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 236257310) ::
                Init_int32 (Int.repr 721420288) ::
                Init_int32 (Int.repr 3276825) ::
                Init_int32 (Int.repr 1638400) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2031216) ::
                Init_int32 (Int.repr (-4586520)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bouncing_fireball_flame_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBowserShockWave := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278401) ::
                Init_int32 (Int.repr 272433407) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bowser_shock_wave_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFireParticleSpawner := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 236257350) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_flame_mario_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBlackSmokeMario := {|
  gvar_info := (tarray tuint 16);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278219) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 270139396) ::
                Init_int32 (Int.repr 236257330) ::
                Init_int32 (Int.repr 83886088) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_black_smoke_mario_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_black_smoke_mario_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_black_smoke_mario_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBlackSmokeBowser := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278219) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 236257280) ::
                Init_int32 (Int.repr 83886088) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_black_smoke_bowser_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 874119172) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBlackSmokeUpward := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 83886084) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_black_smoke_upward_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBetaFishSplashSpawner := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 889192448) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_beta_fish_splash_spawner_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSpindrift := {|
  gvar_info := (tarray tuint 16);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _spindrift_seg5_anims_05002D68 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2031216) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 272760960) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_spindrift_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTowerPlatformGroup := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 889192448) ::
                Init_int32 (Int.repr 218562860) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_tower_platform_group_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWFSlidingTowerPlatform := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _wf_seg7_collision_platform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_wf_sliding_tower_platform_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWFElevatorTowerPlatform := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _wf_seg7_collision_platform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_wf_elevator_tower_platform_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWFSolidTowerPlatform := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _wf_seg7_collision_platform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_wf_solid_tower_platform_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvLeafParticleSpawner := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_snow_leaf_particle_spawn_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTreeSnow := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278211) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_tree_snow_or_leaf_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTreeLeaf := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278211) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_tree_snow_or_leaf_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvAnotherTiltingPlatform := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_platform_normals_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_tilting_inverted_pyramid_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSquarishPathMoving := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _bitdw_seg7_collision_moving_pyramid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_squarish_path_moving_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPiranhaPlantBubble := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_piranha_plant_bubble_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPiranhaPlantWakingBubbles := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 285278337) ::
                Init_int32 (Int.repr 83886090) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_piranha_plant_waking_bubbles_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFloorSwitchAnimatesObject := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 271515649) ::
                Init_int32 (Int.repr 67108864) ::
                Init_addrof _bhvFloorSwitchHardcodedModel (Ptrofs.repr 4) ::
                nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFloorSwitchGrills := {|
  gvar_info := (tarray tuint 3);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 67108864) ::
                Init_addrof _bhvFloorSwitchHardcodedModel (Ptrofs.repr 4) ::
                nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFloorSwitchHardcodedModel := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _purple_switch_seg8_collision_0800C7A8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_purple_switch_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFloorSwitchHiddenObjects := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 271515650) ::
                Init_int32 (Int.repr 67108864) ::
                Init_addrof _bhvFloorSwitchHardcodedModel (Ptrofs.repr 4) ::
                nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvHiddenObject := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _breakable_box_seg8_collision_08012D70 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 239272236) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_hidden_object_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBreakableBox := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _breakable_box_seg8_collision_08012D70 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 239272436) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_breakable_box_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) ::
                Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPushableMetalBox := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _metal_box_seg8_collision_08024C28 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 239272436) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_pushable_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvHeaveHo := {|
  gvar_info := (tarray tuint 23);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285287497) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _heave_ho_seg5_anims_0501534C (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 13172336) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536600) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 738197504) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvHeaveHoThrowMario (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 271187970) ::
                Init_int32 (Int.repr 272761348) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 7864420) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_heave_ho_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvHeaveHoThrowMario := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_heave_ho_throw_mario_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCCMTouchedStarSpawn := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285294593) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 32768500) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ccm_touched_star_spawn_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvUnusedPoundablePlatform := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _sl_seg7_collision_pound_explodes (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_unused_poundable_platform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBetaTrampolineTop := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _springboard_collision_05001A28 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_beta_trampoline_top_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBetaTrampolineSpring := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_beta_trampoline_spring_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvJumpingBox := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285279297) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2031216) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536600) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_jumping_box_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBooCage := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 236257290) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2031216) ::
                Init_int32 (Int.repr (-3276800)) ::
                Init_int32 (Int.repr 200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_boo_cage_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvStub := {|
  gvar_info := (tarray tuint 3);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 889192448) ::
                Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvIgloo := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 1073741824) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 6553800) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 271253504) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBowserKey := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2031216) ::
                Init_int32 (Int.repr (-4586520)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bowser_key_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvGrandStar := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 4096) ::
                Init_int32 (Int.repr 272762880) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 10485860) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_grand_star_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBetaBooKey := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 2097216) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2031216) ::
                Init_int32 (Int.repr (-4586520)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_beta_boo_key_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvAlphaBooKey := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 2097216) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_alpha_boo_key_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBulletBill := {|
  gvar_info := (tarray tuint 22);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286475) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 721420288) ::
                Init_int32 (Int.repr 3276850) ::
                Init_int32 (Int.repr 3276800) ::
                Init_int32 (Int.repr 788529152) :: Init_int32 (Int.repr 8) ::
                Init_int32 (Int.repr 272498691) ::
                Init_int32 (Int.repr 838860840) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 1966080) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bullet_bill_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bullet_bill_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWhitePuffSmoke := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 218627996) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_white_puff_smoke_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 83886090) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvUnused1820 := {|
  gvar_info := (tarray tuint 2);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBowserTailAnchor := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 721420288) ::
                Init_int32 (Int.repr 6553650) ::
                Init_int32 (Int.repr (-3276800)) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 889192448) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bowser_tail_anchor_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBowser := {|
  gvar_info := (tarray tuint 31);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285287625) ::
                Init_int32 (Int.repr 271187970) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 26214800) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _bowser_seg6_anims_06057690 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 469762048) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvBowserBodyAnchor (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 469762048) ::
                Init_int32 (Int.repr 101) ::
                Init_addrof _bhvBowserFlameSpawn (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 738197504) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvBowserTailAnchor (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 272891954) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 65136) ::
                Init_int32 (Int.repr (-4586520)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bowser_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bowser_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBowserBodyAnchor := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 6553900) ::
                Init_int32 (Int.repr 788529152) :: Init_int32 (Int.repr 8) ::
                Init_int32 (Int.repr 272760840) ::
                Init_int32 (Int.repr 889192448) ::
                Init_int32 (Int.repr 272498690) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bowser_body_anchor_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBowserFlameSpawn := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 452984832) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bowser_flame_spawn_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTiltingBowserLavaPlatform := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285286401) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _bowser_2_seg7_collision_tilting_platform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 239423008) ::
                Init_int32 (Int.repr 239291936) ::
                Init_int32 (Int.repr 269680640) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _cur_obj_rotate_face_angle_using_vel (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFallingBowserPlatform := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 239423008) ::
                Init_int32 (Int.repr 239291936) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_falling_bowser_platform_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBlueBowserFlame := {|
  gvar_info := (tarray tuint 17);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 65136) ::
                Init_int32 (Int.repr (-4586520)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_blue_bowser_flame_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_blue_bowser_flame_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 874119170) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFlameFloatingLanding := {|
  gvar_info := (tarray tuint 17);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 65136) ::
                Init_int32 (Int.repr (-4586520)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_flame_floating_landing_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_flame_floating_landing_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 874119170) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBlueFlamesGroup := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285286401) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_blue_flames_group_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFlameBouncing := {|
  gvar_info := (tarray tuint 17);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285286401) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_flame_bouncing_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 65136) ::
                Init_int32 (Int.repr (-4587520)) ::
                Init_int32 (Int.repr 200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_flame_bouncing_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 874119170) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFlameMovingForwardGrowing := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_flame_moving_forward_growing_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_flame_moving_forward_growing_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 874119170) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFlameBowser := {|
  gvar_info := (tarray tuint 17);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_flame_bowser_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 65136) ::
                Init_int32 (Int.repr (-4586520)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_flame_bowser_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 874119170) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFlameLargeBurningOut := {|
  gvar_info := (tarray tuint 17);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_flame_large_burning_out_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 65136) ::
                Init_int32 (Int.repr (-4586520)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_flame_bowser_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 874119170) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBlueFish := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _blue_fish_seg3_anims_0301C2B0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_blue_fish_movement_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTankFishGroup := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_tank_fish_group_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCheckerboardElevatorGroup := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 720896) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_checkerboard_elevator_group_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCheckerboardPlatformSub := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _checkerboard_platform_seg8_collision_0800D710 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_checkerboard_platform_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_checkerboard_platform_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBowserKeyUnlockDoor := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _bowser_key_seg3_anims_list (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bowser_key_unlock_door_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBowserKeyCourseExit := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _bowser_key_seg3_anims_list (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bowser_key_course_exit_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvInvisibleObjectsUnderBridge := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_invisible_objects_under_bridge_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWaterLevelPillar := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _inside_castle_seg7_collision_water_level_pillar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_water_level_pillar_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_water_level_pillar_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvDDDWarp := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 239301936) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ddd_warp_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMoatGrills := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _castle_grounds_seg7_collision_moat_grills (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 239301936) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_moat_grills_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvClockMinuteHand := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 270925440) ::
                Init_int32 (Int.repr 67108864) ::
                Init_addrof _bhvClockHourHand (Ptrofs.repr 8) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvClockHourHand := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 270925792) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_rotating_clock_arm_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMacroUkiki := {|
  gvar_info := (tarray tuint 23);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285287497) ::
                Init_int32 (Int.repr 271187970) ::
                Init_int32 (Int.repr 272760848) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 2621480) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _ukiki_seg5_anims_05015784 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2031216) ::
                Init_int32 (Int.repr (-3276800)) ::
                Init_int32 (Int.repr 200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ukiki_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ukiki_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvStub1D0C := {|
  gvar_info := (tarray tuint 2);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvLLLRotatingHexagonalPlatform := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _lll_seg7_collision_hexagonal_platform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 270795008) ::
                Init_int32 (Int.repr 252707072) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvLLLSinkingRockBlock := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _lll_seg7_collision_floating_block (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 218628046) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_lll_sinking_rock_block_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvStub1D70 := {|
  gvar_info := (tarray tuint 2);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvLLLMovingOctagonalMeshPlatform := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 218628046) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _lll_seg7_collision_octagonal_moving_platform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_lll_moving_octagonal_mesh_platform_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSnowBall := {|
  gvar_info := (tarray tuint 1);
  gvar_init := (Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvLLLRotatingBlockWithFireBars := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _lll_seg7_collision_rotating_fire_bars (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 239275936) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_lll_rotating_block_fire_bars_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvLLLRotatingHexFlame := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 721420288) ::
                Init_int32 (Int.repr 3276900) ::
                Init_int32 (Int.repr 3276800) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_lll_rotating_hex_flame_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvLLLWoodPiece := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _lll_seg7_collision_wood_piece (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_lll_wood_piece_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvLLLFloatingWoodBridge := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 452984832) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_lll_floating_wood_bridge_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvVolcanoFlames := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_volcano_flames_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvLLLRotatingHexagonalRing := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _lll_seg7_collision_rotating_platform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_lll_rotating_hexagonal_ring_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvLLLSinkingRectangularPlatform := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _lll_seg7_collision_slow_tilting_platform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 239273936) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_lll_sinking_rectangular_platform_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvLLLSinkingSquarePlatforms := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _lll_seg7_collision_sinking_pyramids (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 218562565) ::
                Init_int32 (Int.repr 239273936) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_lll_sinking_square_platforms_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvLLLTiltingInvertedPyramid := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _lll_seg7_collision_inverted_pyramid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 218562565) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_platform_normals_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_tilting_inverted_pyramid_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvUnused1F30 := {|
  gvar_info := (tarray tuint 3);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvKoopaShell := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2031216) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_koopa_shell_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvKoopaShellFlame := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_koopa_shell_flame_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 874119170) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvToxBox := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _ssl_seg7_collision_tox_box (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 218562816) ::
                Init_int32 (Int.repr 239411008) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_tox_box_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPiranhaPlant := {|
  gvar_info := (tarray tuint 23);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _piranha_plant_seg6_anims_0601C31C (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 788529152) :: Init_int32 (Int.repr 8) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 6553800) ::
                Init_int32 (Int.repr 771751936) ::
                Init_int32 (Int.repr 3277000) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 272498691) ::
                Init_int32 (Int.repr 272891909) ::
                Init_int32 (Int.repr 469762048) ::
                Init_int32 (Int.repr 168) ::
                Init_addrof _bhvPiranhaPlantBubble (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 239405008) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_piranha_plant_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvLLLHexagonalMesh := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _lll_hexagonal_mesh_seg3_collision_0301CECC (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvLLLBowserPuzzlePiece := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _lll_seg7_collision_puzzle_piece (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 239274936) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_lll_bowser_puzzle_piece_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvLLLBowserPuzzle := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 720896) ::
                Init_int32 (Int.repr 889192448) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 218693582) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_lll_bowser_puzzle_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTuxiesMother := {|
  gvar_info := (tarray tuint 20);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _penguin_seg5_anims_05008B74 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671285248) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2031216) ::
                Init_int32 (Int.repr (-3276800)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 8388608) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 13107500) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_tuxies_mother_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPenguinBaby := {|
  gvar_info := (tarray tuint 2);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvUnused20E0 := {|
  gvar_info := (tarray tuint 2);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSmallPenguin := {|
  gvar_info := (tarray tuint 21);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285287497) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _penguin_seg5_anims_05008B74 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2031216) ::
                Init_int32 (Int.repr (-3276800)) ::
                Init_int32 (Int.repr 200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 271187970) ::
                Init_int32 (Int.repr 272760848) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 2621480) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_small_penguin_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvManyBlueFishSpawner := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 271515648) ::
                Init_int32 (Int.repr 67108864) ::
                Init_addrof _bhvFishSpawner (Ptrofs.repr 4) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFewBlueFishSpawner := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 271515649) ::
                Init_int32 (Int.repr 67108864) ::
                Init_addrof _bhvFishSpawner (Ptrofs.repr 4) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFishSpawner := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 889192448) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_fish_spawner_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFish := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_fish_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWDWExpressElevator := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _wdw_seg7_collision_express_elevator_platform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_wdw_express_elevator_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWDWExpressElevatorPlatform := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _wdw_seg7_collision_express_elevator_platform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvChirpChirp := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 270204929) ::
                Init_int32 (Int.repr 67108864) ::
                Init_addrof _bhvChirpChirpUnused (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvChirpChirpUnused := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 889192448) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bub_spawner_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBub := {|
  gvar_info := (tarray tuint 17);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _bub_seg6_anims_06012354 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 721420288) ::
                Init_int32 (Int.repr 1310730) ::
                Init_int32 (Int.repr 655360) ::
                Init_int32 (Int.repr 788529152) :: Init_int32 (Int.repr 8) ::
                Init_int32 (Int.repr 272498689) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bub_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvExclamationBox := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _exclamation_box_outline_seg8_collision_08025F78 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 239272236) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_exclamation_box_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvRotatingExclamationMark := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 838861000) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_rotating_exclamation_box_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 252708864) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSoundSpawner := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 16777219) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_sound_spawner_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 16777246) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvRockSolid := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _jrb_seg7_collision_rock_solid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBowserSubDoor := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278337) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _ddd_seg7_collision_bowser_sub_door (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 239423008) ::
                Init_int32 (Int.repr 239291936) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bowsers_sub_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBowsersSub := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278337) ::
                Init_int32 (Int.repr 239423008) ::
                Init_int32 (Int.repr 239291936) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _ddd_seg7_collision_submarine (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bowsers_sub_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSushiShark := {|
  gvar_info := (tarray tuint 20);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _sushi_seg5_anims_0500AE54 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 738197504) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvSushiSharkCollisionChild (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 721420288) ::
                Init_int32 (Int.repr 6553650) ::
                Init_int32 (Int.repr 3276800) ::
                Init_int32 (Int.repr 788529152) :: Init_int32 (Int.repr 8) ::
                Init_int32 (Int.repr 272498691) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_sushi_shark_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSushiSharkCollisionChild := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 889192448) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_sushi_shark_collision_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvJRBSlidingBox := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _jrb_seg7_collision_floating_box (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_jrb_sliding_box_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvShipPart3 := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ship_part_3_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvInSunkenShip3 := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _jrb_seg7_collision_in_sunken_ship_3 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 239275936) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ship_part_3_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSunkenShipPart := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278401) ::
                Init_int32 (Int.repr 838860850) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_sunken_ship_part_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSunkenShipSetRotation := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 269674840) ::
                Init_int32 (Int.repr 269741676) ::
                Init_int32 (Int.repr 269749376) ::
                Init_int32 (Int.repr 50331648) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSunkenShipPart2 := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 838860900) ::
                Init_int32 (Int.repr 239409008) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 33554432) ::
                Init_addrof _bhvSunkenShipSetRotation (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvInSunkenShip := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _jrb_seg7_collision_in_sunken_ship (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 67108864) ::
                Init_addrof _bhvInSunkenShip2 (Ptrofs.repr 12) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvInSunkenShip2 := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _jrb_seg7_collision_in_sunken_ship_2 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 239275936) ::
                Init_int32 (Int.repr 33554432) ::
                Init_addrof _bhvSunkenShipSetRotation (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMistParticleSpawner := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 857079808) :: Init_int32 (Int.repr 1) ::
                Init_int32 (Int.repr 889192448) ::
                Init_int32 (Int.repr 469762048) ::
                Init_int32 (Int.repr 142) ::
                Init_addrof _bhvWhitePuff1 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 469762048) ::
                Init_int32 (Int.repr 150) ::
                Init_addrof _bhvWhitePuff2 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWhitePuff1 := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 857079808) :: Init_int32 (Int.repr 1) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_white_puff_1_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWhitePuff2 := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278211) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 83886087) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_white_puff_2_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWhitePuffSmoke2 := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 83886087) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_white_puff_2_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _cur_obj_move_using_fvel_and_gravity (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPurpleSwitchHiddenBoxes := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 271515650) ::
                Init_int32 (Int.repr 67108864) ::
                Init_addrof _bhvFloorSwitchHardcodedModel (Ptrofs.repr 4) ::
                nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBlueCoinSwitch := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _blue_coin_switch_seg8_collision_08000E98 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_blue_coin_switch_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvHiddenBlueCoin := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 271187984) ::
                Init_int32 (Int.repr 285278401) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 6553664) ::
                Init_int32 (Int.repr 272498693) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_hidden_blue_coin_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvOpenableCageDoor := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_openable_cage_door_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvOpenableGrill := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_openable_grill_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWaterLevelDiamond := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 4587550) ::
                Init_int32 (Int.repr 239272136) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_water_level_diamond_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvInitializeChangingWaterLevel := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_changing_water_level_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTweesterSandParticle := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278211) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_tweester_sand_particle_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTweester := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 655360) ::
                Init_int32 (Int.repr 285286593) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2031216) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_tweester_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMerryGoRoundBooManager := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_merry_go_round_boo_manager_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvAnimatedTexture := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2031216) ::
                Init_int32 (Int.repr (-4586520)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_animated_texture_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 874119170) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBooInCastle := {|
  gvar_info := (tarray tuint 15);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 236257340) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 1966080) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_boo_in_castle_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBooWithCage := {|
  gvar_info := (tarray tuint 22);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 272498691) ::
                Init_int32 (Int.repr 771751936) ::
                Init_int32 (Int.repr 5243000) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 11796620) ::
                Init_int32 (Int.repr 236257340) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 1966080) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_boo_with_cage_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_boo_with_cage_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBalconyBigBoo := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 271515650) ::
                Init_int32 (Int.repr 273219594) ::
                Init_int32 (Int.repr 67108864) ::
                Init_addrof _bhvGhostHuntBigBoo (Ptrofs.repr 4) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMerryGoRoundBigBoo := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 271515649) ::
                Init_int32 (Int.repr 273219594) ::
                Init_int32 (Int.repr 67108864) ::
                Init_addrof _bhvGhostHuntBigBoo (Ptrofs.repr 4) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvGhostHuntBigBoo := {|
  gvar_info := (tarray tuint 16);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 1966080) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_boo_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_big_boo_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCourtyardBooTriplet := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 889192448) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_courtyard_boo_triplet_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBoo := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 271515649) ::
                Init_int32 (Int.repr 67108864) ::
                Init_addrof _bhvGhostHuntBoo (Ptrofs.repr 4) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMerryGoRoundBoo := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 271515650) ::
                Init_int32 (Int.repr 67108864) ::
                Init_addrof _bhvGhostHuntBoo (Ptrofs.repr 4) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvGhostHuntBoo := {|
  gvar_info := (tarray tuint 26);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 272498690) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 9175120) ::
                Init_int32 (Int.repr 771751936) ::
                Init_int32 (Int.repr 2621500) ::
                Init_int32 (Int.repr 236257310) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 469762048) ::
                Init_int32 (Int.repr 116) ::
                Init_addrof _bhvCoinInsideBoo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 1966080) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_boo_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_boo_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvHiddenStaircaseStep := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _bbh_seg7_collision_staircase_step (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 273022977) ::
                Init_int32 (Int.repr 239272936) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBooStaircase := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _bbh_seg7_collision_staircase_step (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 273022977) ::
                Init_int32 (Int.repr 239272936) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_boo_staircase (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBBHTiltingTrapPlatform := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _bbh_seg7_collision_tilt_floor_platform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 273022978) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bbh_tilting_trap_platform_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvHauntedBookshelf := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _bbh_seg7_collision_haunted_bookshelf (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 273022982) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_haunted_bookshelf_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMeshElevator := {|
  gvar_info := (tarray tuint 15);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _bbh_seg7_collision_mesh_elevator (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 273022988) ::
                Init_int32 (Int.repr 271515652) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_elevator_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_elevator_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMerryGoRound := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _bbh_seg7_collision_merry_go_round (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 239273936) ::
                Init_int32 (Int.repr 273022986) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_merry_go_round_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPlaysMusicTrackWhenTouched := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_play_music_track_when_touched_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvInsideCannon := {|
  gvar_info := (tarray tuint 1);
  gvar_init := (Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBetaBowserAnchor := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 131072) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 6553900) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_beta_bowser_anchor_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvStaticCheckeredPlatform := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _checkerboard_platform_seg8_collision_0800D710 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_static_checkered_platform_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvUnused2A10 := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvUnusedFakeStar := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 252838144) ::
                Init_int32 (Int.repr 252903680) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvStaticObject := {|
  gvar_info := (tarray tuint 3);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvUnused2A54 := {|
  gvar_info := (tarray tuint 2);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCastleFloorTrap := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 889192448) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_castle_floor_trap_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_castle_floor_trap_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFloorTrapInCastle := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _inside_castle_seg7_collision_floor_trap (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_floor_trap_in_castle_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTree := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 655360) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 271188032) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 5243380) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_pole_base_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSparkle := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 83886089) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSparkleSpawn := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_sparkle_spawn_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSparkleParticleSpawner := {|
  gvar_info := (tarray tuint 21);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 857079808) :: Init_int32 (Int.repr 8) ::
                Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 236257305) ::
                Init_int32 (Int.repr 337379278) ::
                Init_int32 (Int.repr 6553600) ::
                Init_int32 (Int.repr 520488475) ::
                Init_int32 (Int.repr 337379278) ::
                Init_int32 (Int.repr 6553600) ::
                Init_int32 (Int.repr 520620059) ::
                Init_int32 (Int.repr 337379278) ::
                Init_int32 (Int.repr 6553600) ::
                Init_int32 (Int.repr 520554267) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 83886092) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvScuttlebug := {|
  gvar_info := (tarray tuint 17);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _scuttlebug_seg6_anims_06015064 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 5308016) ::
                Init_int32 (Int.repr (-3276800)) ::
                Init_int32 (Int.repr 200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_scuttlebug_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvScuttlebugSpawn := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 720896) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_scuttlebug_spawn_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWhompKingBoss := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 271515649) ::
                Init_int32 (Int.repr 272564227) ::
                Init_int32 (Int.repr 67108864) ::
                Init_addrof _bhvSmallWhomp (Ptrofs.repr 8) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSmallWhomp := {|
  gvar_info := (tarray tuint 18);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 272891909) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _whomp_seg6_anims_06020A04 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _whomp_seg6_collision_06020A0C (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 65136) ::
                Init_int32 (Int.repr (-3276800)) ::
                Init_int32 (Int.repr 200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_whomp_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWaterSplash := {|
  gvar_info := (tarray tuint 19);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 83886083) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_water_splash_spawn_droplets (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_water_splash_spawn_droplets (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 83886085) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 857079808) ::
                Init_int32 (Int.repr 64) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWaterDroplet := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278219) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_water_droplet_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWaterDropletSplash := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 269615104) ::
                Init_int32 (Int.repr 269680640) ::
                Init_int32 (Int.repr 269746176) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_water_droplet_splash_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 218562565) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 83886086) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBubbleSplash := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 269615104) ::
                Init_int32 (Int.repr 269680640) ::
                Init_int32 (Int.repr 269746176) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bubble_splash_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 83886086) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvIdleWaterWave := {|
  gvar_info := (tarray tuint 18);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 269615104) ::
                Init_int32 (Int.repr 269680640) ::
                Init_int32 (Int.repr 269746176) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_idle_water_wave_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 83886086) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_idle_water_wave_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_idle_water_wave_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvObjectWaterSplash := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 269615104) ::
                Init_int32 (Int.repr 269680640) ::
                Init_int32 (Int.repr 269746176) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 83886086) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvShallowWaterWave := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 889192448) ::
                Init_int32 (Int.repr 83886085) ::
                Init_int32 (Int.repr 922746880) ::
                Init_addrof _gShallowWaterWaveDropletParams (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117440512) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 857079808) ::
                Init_int32 (Int.repr 256) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvShallowWaterSplash := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 889192448) ::
                Init_int32 (Int.repr 83886098) ::
                Init_int32 (Int.repr 922746880) ::
                Init_addrof _gShallowWaterSplashDropletParams (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117440512) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_shallow_water_splash_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 857079808) ::
                Init_int32 (Int.repr 4096) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvObjectWaveTrail := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 67108864) ::
                Init_addrof _bhvWaveTrail (Ptrofs.repr 16) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWaveTrail := {|
  gvar_info := (tarray tuint 17);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 857079808) ::
                Init_int32 (Int.repr 1024) ::
                Init_int32 (Int.repr 236060672) ::
                Init_int32 (Int.repr 236126208) ::
                Init_int32 (Int.repr 236191744) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 83886088) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_wave_trail_shrink (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_wave_trail_shrink (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 486539264) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTinyStrongWindParticle := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_strong_wind_particle_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvStrongWindParticle := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 655360) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_strong_wind_particle_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSLSnowmanWind := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_sl_snowman_wind_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSLWalkingPenguin := {|
  gvar_info := (tarray tuint 20);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _penguin_seg5_collision_05008B88 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _penguin_seg5_anims_05008B74 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 65136) ::
                Init_int32 (Int.repr (-3276800)) ::
                Init_int32 (Int.repr 200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 838861400) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_sl_walking_penguin_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvYellowBall := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMario := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 285278464) ::
                Init_int32 (Int.repr 285409281) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 2424992) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _try_print_debug_mario_level_info (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_mario_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _try_do_mario_debug_object_spawn (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvToadMessage := {|
  gvar_info := (tarray tuint 18);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285294665) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _toad_seg6_anims_0600FB58 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671481856) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 8388608) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 5242980) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_toad_message_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_toad_message_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvUnlockDoorStar := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_unlock_door_star_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_unlock_door_star_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvInstantActiveWarp := {|
  gvar_info := (tarray tuint 1);
  gvar_init := (Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvAirborneWarp := {|
  gvar_info := (tarray tuint 1);
  gvar_init := (Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvHardAirKnockBackWarp := {|
  gvar_info := (tarray tuint 1);
  gvar_init := (Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSpinAirborneCircleWarp := {|
  gvar_info := (tarray tuint 1);
  gvar_init := (Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvDeathWarp := {|
  gvar_info := (tarray tuint 1);
  gvar_init := (Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSpinAirborneWarp := {|
  gvar_info := (tarray tuint 1);
  gvar_init := (Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFlyingWarp := {|
  gvar_info := (tarray tuint 1);
  gvar_init := (Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPaintingStarCollectWarp := {|
  gvar_info := (tarray tuint 1);
  gvar_init := (Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPaintingDeathWarp := {|
  gvar_info := (tarray tuint 1);
  gvar_init := (Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvAirborneDeathWarp := {|
  gvar_info := (tarray tuint 1);
  gvar_init := (Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvAirborneStarCollectWarp := {|
  gvar_info := (tarray tuint 1);
  gvar_init := (Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvLaunchStarCollectWarp := {|
  gvar_info := (tarray tuint 1);
  gvar_init := (Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvLaunchDeathWarp := {|
  gvar_info := (tarray tuint 1);
  gvar_init := (Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSwimmingWarp := {|
  gvar_info := (tarray tuint 1);
  gvar_init := (Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvRandomAnimatedTexture := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 236322800) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvYellowBackgroundInMenu := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _beh_yellow_background_menu_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _beh_yellow_background_menu_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMenuButton := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_menu_button_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_menu_button_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMenuButtonManager := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285280289) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_menu_button_manager_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_menu_button_manager_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvActSelectorStarType := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_act_selector_star_type_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvActSelector := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_act_selector_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_act_selector_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMovingYellowCoin := {|
  gvar_info := (tarray tuint 15);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 6553664) ::
                Init_int32 (Int.repr 271187984) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_moving_yellow_coin_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_moving_yellow_coin_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMovingBlueCoin := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_moving_blue_coin_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_moving_blue_coin_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBlueCoinSliding := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_blue_coin_sliding_jumping_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_blue_coin_sliding_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBlueCoinJumping := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_blue_coin_sliding_jumping_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_blue_coin_jumping_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSeaweed := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _seaweed_seg6_anims_0600A4D4 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_seaweed_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSeaweedBundle := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_seaweed_bundle_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBobomb := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 131072) ::
                Init_int32 (Int.repr 285303881) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _bobomb_seg8_anims_0802396C (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bobomb_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bobomb_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBobombFuseSmoke := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bobomb_fuse_smoke_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_dust_smoke_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBobombBuddy := {|
  gvar_info := (tarray tuint 19);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285287497) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _bobomb_seg8_anims_0802396C (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 8388608) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 6553660) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 270336000) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bobomb_buddy_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bobomb_buddy_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBobombBuddyOpensCannon := {|
  gvar_info := (tarray tuint 19);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285303881) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _bobomb_seg8_anims_0802396C (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 8388608) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 6553660) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 270336001) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bobomb_buddy_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bobomb_buddy_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCannonClosed := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285294593) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _cannon_lid_seg8_collision_08004950 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_cannon_closed_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_cannon_closed_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWhirlpool := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 655360) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_whirlpool_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_whirlpool_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvJetStream := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_jet_stream_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMessagePanel := {|
  gvar_info := (tarray tuint 17);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _wooden_signpost_seg3_collision_0302DD80 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 8388608) ::
                Init_int32 (Int.repr 272764928) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 9830480) ::
                Init_int32 (Int.repr 270204928) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 271253504) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSignOnWall := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 8388608) ::
                Init_int32 (Int.repr 272764928) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 9830480) ::
                Init_int32 (Int.repr 270204928) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 271253504) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvHomingAmp := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286475) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _dAmpAnimsList (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 236257320) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_homing_amp_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_homing_amp_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCirclingAmp := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286467) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _dAmpAnimsList (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 236257320) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_circling_amp_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_circling_amp_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvButterfly := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _butterfly_seg3_anims_030056B0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 236257285) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_butterfly_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_butterfly_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvHoot := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 655360) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _hoot_seg5_anims_05005768 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 271187969) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 4915275) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_hoot_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_hoot_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBetaHoldableObject := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285279233) ::
                Init_int32 (Int.repr 271187970) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 2621490) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_beta_holdable_object_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_beta_holdable_object_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCarrySomething1 := {|
  gvar_info := (tarray tuint 2);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCarrySomething2 := {|
  gvar_info := (tarray tuint 2);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCarrySomething3 := {|
  gvar_info := (tarray tuint 2);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCarrySomething4 := {|
  gvar_info := (tarray tuint 2);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCarrySomething5 := {|
  gvar_info := (tarray tuint 2);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCarrySomething6 := {|
  gvar_info := (tarray tuint 2);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 167772160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvObjectBubble := {|
  gvar_info := (tarray tuint 16);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278215) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_object_bubble_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 336199683) ::
                Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 319815680) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_object_bubble_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvObjectWaterWave := {|
  gvar_info := (tarray tuint 19);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 236060672) ::
                Init_int32 (Int.repr 236126208) ::
                Init_int32 (Int.repr 236191744) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_object_water_wave_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 16777222) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_object_water_wave_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 83886086) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_object_water_wave_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 100663296) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvExplosion := {|
  gvar_info := (tarray tuint 18);
  gvar_init := (Init_int32 (Int.repr 131072) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 788529152) :: Init_int32 (Int.repr 8) ::
                Init_int32 (Int.repr 272498690) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 721420288) ::
                Init_int32 (Int.repr 9830550) ::
                Init_int32 (Int.repr 9830400) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_explosion_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_explosion_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBobombBullyDeathSmoke := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278215) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bobomb_bully_death_smoke_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_dust_smoke_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSmoke := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278215) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_dust_smoke_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBobombExplosionBubble := {|
  gvar_info := (tarray tuint 20);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bobomb_explosion_bubble_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 369557454) ::
                Init_int32 (Int.repr 6553600) ::
                Init_int32 (Int.repr 369622990) ::
                Init_int32 (Int.repr 6553600) ::
                Init_int32 (Int.repr 369688526) ::
                Init_int32 (Int.repr 6553600) ::
                Init_int32 (Int.repr 33554432) ::
                Init_addrof _bhvBobombExplosionBubble3600 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 33554432) ::
                Init_addrof _bhvBobombExplosionBubble3600 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bobomb_explosion_bubble_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBobombExplosionBubble3600 := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 369557502) ::
                Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 369688574) ::
                Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 50331648) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvRespawner := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_respawner_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSmallBully := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _bully_seg5_anims_0500470C (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_small_bully_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bully_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBigBully := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _bully_seg5_anims_0500470C (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_big_bully_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bully_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBigBullyWithMinions := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _bully_seg5_anims_0500470C (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_big_bully_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_big_bully_with_minions_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_big_bully_with_minions_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSmallChillBully := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _chilly_chief_seg6_anims_06003994 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 270204944) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_small_bully_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bully_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBigChillBully := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _chilly_chief_seg6_anims_06003994 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 270204944) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_big_bully_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bully_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvJetStreamRingSpawner := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 570425344) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_jet_stream_ring_spawner_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvJetStreamWaterRing := {|
  gvar_info := (tarray tuint 18);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _water_ring_seg6_anims_06013F7C (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 721420288) ::
                Init_int32 (Int.repr 4915220) ::
                Init_int32 (Int.repr 1310720) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 65536) ::
                Init_int32 (Int.repr 272498690) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_jet_stream_water_ring_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_jet_stream_water_ring_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMantaRayWaterRing := {|
  gvar_info := (tarray tuint 18);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _water_ring_seg6_anims_06013F7C (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 721420288) ::
                Init_int32 (Int.repr 4915220) ::
                Init_int32 (Int.repr 1310720) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 65536) ::
                Init_int32 (Int.repr 272498690) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_manta_ray_water_ring_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_manta_ray_water_ring_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMantaRayRingManager := {|
  gvar_info := (tarray tuint 3);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBowserBomb := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 721420288) ::
                Init_int32 (Int.repr 2621480) ::
                Init_int32 (Int.repr 2621440) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bowser_bomb_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBowserBombExplosion := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 236322528) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bowser_bomb_explosion_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBowserBombSmoke := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 236322528) ::
                Init_int32 (Int.repr 272433407) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bowser_bomb_smoke_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCelebrationStar := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_celebration_star_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_celebration_star_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCelebrationStarSparkle := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 236257305) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_celebration_star_sparkle_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvStarKeyCollectionPuffSpawner := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_star_key_collection_puff_spawner_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvLLLDrawbridgeSpawner := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 570425344) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_lll_drawbridge_spawner_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvLLLDrawbridge := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _lll_seg7_collision_drawbridge (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_lll_drawbridge_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSmallBomp := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278211) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _wf_seg7_collision_small_bomp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_small_bomp_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_small_bomp_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvLargeBomp := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278211) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _wf_seg7_collision_large_bomp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_large_bomp_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_large_bomp_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWFSlidingPlatform := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278211) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _wf_seg7_collision_sliding_brick_platform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_wf_sliding_platform_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_wf_sliding_platform_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMoneybag := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286409) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _moneybag_seg6_anims_06005E5C (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 268828671) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_moneybag_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_moneybag_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMoneybagHidden := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 236257307) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 7209060) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_moneybag_hidden_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPitBowlingBall := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 236257410) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bob_pit_bowling_ball_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bob_pit_bowling_ball_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFreeBowlingBall := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 236257410) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_free_bowling_ball_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_free_bowling_ball_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBowlingBall := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 236257410) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bowling_ball_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bowling_ball_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTTMBowlingBallSpawner := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 270336063) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_generic_bowling_ball_spawner_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_generic_bowling_ball_spawner_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBoBBowlingBallSpawner := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 270336127) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_generic_bowling_ball_spawner_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_generic_bowling_ball_spawner_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTHIBowlingBallSpawner := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_thi_bowling_ball_spawner_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvRRCruiserWing := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_rr_cruiser_wing_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_rr_cruiser_wing_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSpindel := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278225) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _ssl_seg7_collision_spindel (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_spindel_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_spindel_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSSLMovingPyramidWall := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278225) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _ssl_seg7_collision_0702808C (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ssl_moving_pyramid_wall_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ssl_moving_pyramid_wall_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPyramidElevator := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _ssl_seg7_collision_pyramid_elevator (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 239291936) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_pyramid_elevator_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_pyramid_elevator_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPyramidElevatorTrajectoryMarkerBall := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_pyramid_elevator_trajectory_marker_ball_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPyramidTop := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _ssl_seg7_collision_pyramid_top (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 239291936) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_pyramid_top_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_pyramid_top_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPyramidTopFragment := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_pyramid_top_fragment_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_pyramid_top_fragment_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPyramidPillarTouchDetector := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 3276850) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_pyramid_pillar_touch_detector_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWaterfallSoundLoop := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_waterfall_sound_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvVolcanoSoundLoop := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_volcano_sound_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCastleFlagWaving := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _castle_grounds_seg7_anims_flags (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_castle_flag_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBirdsSoundLoop := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_birds_sound_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvAmbientSounds := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ambient_sounds_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSandSoundLoop := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_sand_sound_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvHiddenAt120Stars := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _castle_grounds_seg7_collision_cannon_grill (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 239275936) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_castle_cannon_grate_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSnowmansBottom := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286409) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_snowmans_bottom_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_snowmans_bottom_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSnowmansHead := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285286401) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 236257390) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_snowmans_head_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_snowmans_head_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSnowmansBodyCheckpoint := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_snowmans_body_checkpoint_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBigSnowmanWhole := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 236257460) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 8388608) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 13763110) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBigBoulder := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286409) ::
                Init_int32 (Int.repr 236257460) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_big_boulder_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 239291936) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_big_boulder_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBigBoulderGenerator := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_big_boulder_generator_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWingCap := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285286401) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_wing_cap_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_wing_vanish_cap_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMetalCap := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285286401) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_metal_cap_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_metal_cap_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvNormalCap := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285286401) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_normal_cap_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_normal_cap_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvVanishCap := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285286401) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_vanish_cap_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_wing_vanish_cap_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvStar := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_collect_star_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_collect_star_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvStarSpawnCoordinates := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_collect_star_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_star_spawn_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_star_spawn_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvHiddenRedCoinStar := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285294593) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_hidden_red_coin_star_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_hidden_red_coin_star_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvRedCoin := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 270204927) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_red_coin_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_red_coin_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBowserCourseRedCoinStar := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285294593) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bowser_course_red_coin_star_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvHiddenStar := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285294593) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_hidden_star_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_hidden_star_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvHiddenStarTrigger := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 6553700) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_hidden_star_trigger_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTTMRollingLog := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _ttm_seg7_collision_pitoune_2 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 239273936) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ttm_rolling_log_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_rolling_log_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvLLLVolcanoFallingTrap := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _lll_seg7_collision_falling_wall (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_volcano_trap_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvLLLRollingLog := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _lll_seg7_collision_pitoune (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 239273936) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_lll_rolling_log_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_rolling_log_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhv1UpWalking := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285286401) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 721420288) ::
                Init_int32 (Int.repr 1966110) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 236257310) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_1up_common_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_1up_walking_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhv1UpRunningAway := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285286401) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 721420288) ::
                Init_int32 (Int.repr 1966110) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 236257310) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_1up_common_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_1up_running_away_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhv1UpSliding := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 721420288) ::
                Init_int32 (Int.repr 1966110) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 236257310) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_1up_common_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_1up_sliding_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhv1Up := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 721420288) ::
                Init_int32 (Int.repr 1966110) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 236257310) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_1up_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_1up_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhv1UpJumpOnApproach := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285286401) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 721420288) ::
                Init_int32 (Int.repr 1966110) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 236257310) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_1up_common_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_1up_jump_on_approach_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvHidden1Up := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285286401) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 721420288) ::
                Init_int32 (Int.repr 1966110) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 236257310) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_1up_common_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_1up_hidden_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvHidden1UpTrigger := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 6553700) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_1up_hidden_trigger_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvHidden1UpInPole := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285286401) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 721420288) ::
                Init_int32 (Int.repr 1966110) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 236257310) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_1up_common_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_1up_hidden_in_pole_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvHidden1UpInPoleTrigger := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 6553700) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_1up_hidden_in_pole_trigger_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvHidden1UpInPoleSpawner := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_1up_hidden_in_pole_spawner_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvControllablePlatform := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285280289) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _hmc_seg7_collision_controllable_platform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_controllable_platform_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_controllable_platform_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvControllablePlatformSub := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _hmc_seg7_collision_controllable_platform_sub (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_controllable_platform_sub_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBreakableBoxSmall := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 131072) ::
                Init_int32 (Int.repr 285279305) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_breakable_box_small_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_breakable_box_small_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSlidingSnowMound := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _sl_seg7_collision_sliding_snow_mound (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_sliding_snow_mound_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSnowMoundSpawn := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_snow_mound_spawn_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWDWSquareFloatingPlatform := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _wdw_seg7_collision_square_floating_platform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 236781632) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_floating_platform_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWDWRectangularFloatingPlatform := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _wdw_seg7_collision_rect_floating_platform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 236781632) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_floating_platform_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvJRBFloatingPlatform := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _jrb_seg7_collision_floating_platform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 236781632) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_floating_platform_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvArrowLift := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _wdw_seg7_collision_arrow_lift (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 320733185) ::
                Init_int32 (Int.repr 2097152) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_arrow_lift_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvOrangeNumber := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_orange_number_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_orange_number_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMantaRay := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278225) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _manta_seg5_anims_05008EB4 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_manta_ray_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_manta_ray_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFallingPillar := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286401) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_falling_pillar_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_falling_pillar_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFallingPillarHitbox := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_falling_pillar_hitbox_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPillarBase := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _jrb_seg7_collision_pillar_base (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvJRBFloatingBox := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _jrb_seg7_collision_floating_box (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_jrb_floating_box_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvDecorativePendulum := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_decorative_pendulum_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_decorative_pendulum_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTreasureChestsShip := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_treasure_chest_ship_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_treasure_chest_ship_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTreasureChestsJRB := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_treasure_chest_jrb_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_treasure_chest_jrb_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTreasureChestsDDD := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_treasure_chest_ddd_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_treasure_chest_ddd_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTreasureChestBottom := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_treasure_chest_bottom_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 268828671) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_treasure_chest_bottom_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTreasureChestTop := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_treasure_chest_top_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMips := {|
  gvar_info := (tarray tuint 15);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285279241) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _mips_seg6_anims_06015634 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 271187970) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 3276875) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_mips_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_mips_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvYoshi := {|
  gvar_info := (tarray tuint 18);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286409) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _yoshi_seg5_anims_05024100 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 8388608) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 10485910) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_yoshi_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_yoshi_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvKoopa := {|
  gvar_info := (tarray tuint 20);
  gvar_init := (Init_int32 (Int.repr 327680) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _koopa_seg6_anims_06011364 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671678464) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 3341936) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 838860950) ::
                Init_int32 (Int.repr 236650497) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_koopa_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_koopa_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvKoopaRaceEndpoint := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 687865856) ::
                Init_int32 (Int.repr 106) ::
                Init_addrof _bhvKoopaFlag (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_koopa_race_endpoint_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvKoopaFlag := {|
  gvar_info := (tarray tuint 15);
  gvar_init := (Init_int32 (Int.repr 655360) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 64) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 5243580) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _koopa_flag_seg6_anims_06001028 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_pole_base_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPokey := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 3997296) ::
                Init_int32 (Int.repr 1000) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_pokey_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPokeyBodyPart := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 3997296) ::
                Init_int32 (Int.repr 1000) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_pokey_body_part_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSwoop := {|
  gvar_info := (tarray tuint 17);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _swoop_seg6_anims_060070D0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 3276800) ::
                Init_int32 (Int.repr (-3276800)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 838860800) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_swoop_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFlyGuy := {|
  gvar_info := (tarray tuint 20);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _flyguy_seg8_anims_08011A64 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 3276800) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 65536600) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 272760960) ::
                Init_int32 (Int.repr 236257310) ::
                Init_int32 (Int.repr 838860950) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_fly_guy_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvGoomba := {|
  gvar_info := (tarray tuint 17);
  gvar_init := (Init_int32 (Int.repr 327680) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _goomba_seg8_anims_0801DA4C (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2686576) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536000) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_goomba_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_goomba_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvGoombaTripletSpawner := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 327680) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_goomba_triplet_spawner_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvChainChomp := {|
  gvar_info := (tarray tuint 22);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286601) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _chain_chomp_seg6_anims_06025178 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 65136) ::
                Init_int32 (Int.repr (-3276800)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 570425344) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 236257520) ::
                Init_int32 (Int.repr 838861000) ::
                Init_int32 (Int.repr 687865856) ::
                Init_int32 (Int.repr 107) ::
                Init_addrof _bhvWoodenPost (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_chain_chomp_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvChainChompChainPart := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 65136) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 236257320) ::
                Init_int32 (Int.repr 838861000) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_chain_chomp_chain_part_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWoodenPost := {|
  gvar_info := (tarray tuint 19);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _poundable_pole_collision_06002490 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 65136) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 272891909) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 838860850) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_wooden_post_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvChainChompGate := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _bob_seg7_collision_chain_chomp_gate (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_chain_chomp_gate_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_chain_chomp_gate_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWigglerHead := {|
  gvar_info := (tarray tuint 18);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _wiggler_seg5_anims_0500EC8C (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 3997296) ::
                Init_int32 (Int.repr 1000) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 570425344) ::
                Init_int32 (Int.repr 838861200) ::
                Init_int32 (Int.repr 236655496) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_wiggler_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWigglerBody := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _wiggler_seg5_anims_0500C874 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 65136) :: Init_int32 (Int.repr 1000) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 838861200) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_wiggler_body_part_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvEnemyLakitu := {|
  gvar_info := (tarray tuint 15);
  gvar_init := (Init_int32 (Int.repr 327680) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _lakitu_enemy_seg5_anims_050144D4 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2621440) ::
                Init_int32 (Int.repr (-3276800)) ::
                Init_int32 (Int.repr 200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_enemy_lakitu_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCameraLakitu := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _lakitu_seg6_anims_060058F8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_camera_lakitu_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_camera_lakitu_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCloud := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 272433392) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_cloud_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCloudPart := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 272433392) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_cloud_part_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSpiny := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 327680) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _spiny_seg5_anims_05016EAC (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2686576) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_spiny_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMontyMole := {|
  gvar_info := (tarray tuint 22);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _monty_mole_seg5_anims_05007248 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671285248) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 1966080) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 570425344) ::
                Init_int32 (Int.repr 268828671) ::
                Init_int32 (Int.repr 236322756) ::
                Init_int32 (Int.repr 838860950) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_monty_mole_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_monty_mole_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMontyMoleHole := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 838860950) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_monty_mole_hole_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMontyMoleRock := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278281) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2031216) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 236257290) ::
                Init_int32 (Int.repr 838861000) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_monty_mole_rock_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPlatformOnTrack := {|
  gvar_info := (tarray tuint 17);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 3342236) ::
                Init_int32 (Int.repr (-3276700)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_platform_on_track_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_platform_on_track_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTrackBall := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 838860815) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_track_ball_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSeesawPlatform := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_seesaw_platform_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_seesaw_platform_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFerrisWheelAxle := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 252723200) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ferris_wheel_axle_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 252969360) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFerrisWheelPlatform := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ferris_wheel_platform_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWaterBombSpawner := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_water_bomb_spawner_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWaterBomb := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286401) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 7929456) ::
                Init_int32 (Int.repr 1000) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_water_bomb_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWaterBombShadow := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 838860950) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_water_bomb_shadow_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTTCRotatingSolid := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 239272386) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ttc_rotating_solid_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 270204929) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ttc_rotating_solid_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTTCPendulum := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _ttc_seg7_collision_clock_pendulum (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 239273436) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ttc_pendulum_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 236650497) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ttc_pendulum_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTTCTreadmill := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 239272686) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ttc_treadmill_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 16777217) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ttc_treadmill_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _cur_obj_compute_vel_xz (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTTCMovingBar := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _ttc_seg7_collision_sliding_surface (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 239272486) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ttc_moving_bar_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ttc_moving_bar_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTTCCog := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 239272336) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ttc_cog_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ttc_cog_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTTCPitBlock := {|
  gvar_info := (tarray tuint 12);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 239272286) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ttc_pit_block_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ttc_pit_block_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTTCElevator := {|
  gvar_info := (tarray tuint 15);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _ttc_seg7_collision_clock_platform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 239272336) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ttc_elevator_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 236650497) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ttc_elevator_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTTC2DRotator := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _ttc_seg7_collision_clock_main_rotation (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 239273736) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ttc_2d_rotator_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ttc_2d_rotator_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTTCSpinner := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _ttc_seg7_collision_rotating_clock_platform2 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 239272386) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ttc_spinner_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMrBlizzard := {|
  gvar_info := (tarray tuint 19);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _snowman_seg5_anims_0500D118 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2031216) ::
                Init_int32 (Int.repr 1000) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_mr_blizzard_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 236650497) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_mr_blizzard_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMrBlizzardSnowball := {|
  gvar_info := (tarray tuint 17);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2031316) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 838861000) ::
                Init_int32 (Int.repr 252748968) ::
                Init_int32 (Int.repr 235667461) ::
                Init_int32 (Int.repr 235601919) ::
                Init_int32 (Int.repr 236257290) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_mr_blizzard_snowball (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSlidingPlatform2 := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_sliding_plat_2_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_sliding_plat_2_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvOctagonalPlatformRotating := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_rotating_octagonal_plat_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_rotating_octagonal_plat_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvAnimatesOnFloorSwitchPress := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 239279936) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_animates_on_floor_switch_press_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_animates_on_floor_switch_press_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvActivatedBackAndForthPlatform := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_activated_back_and_forth_platform_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_activated_back_and_forth_platform_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvRecoveryHeart := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_recovery_heart_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvWaterBombCannon := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_water_bomb_cannon_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCannonBarrelBubbles := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278217) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bubble_cannon_barrel_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvUnagi := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _unagi_seg5_anims_05012824 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671481856) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 838861100) ::
                Init_int32 (Int.repr 239409008) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_unagi_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_unagi_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvUnagiSubobject := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_unagi_subobject_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvDorrie := {|
  gvar_info := (tarray tuint 17);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _dorrie_seg6_collision_0600F644 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _dorrie_seg6_anims_0600F638 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 239301936) ::
                Init_int32 (Int.repr 218499024) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_dorrie_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvHauntedChair := {|
  gvar_info := (tarray tuint 20);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _chair_seg5_anims_05005784 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2621440) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_haunted_chair_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_haunted_chair_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvMadPiano := {|
  gvar_info := (tarray tuint 18);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _mad_piano_seg5_anims_05009B14 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2621440) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 252723200) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_mad_piano_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFlyingBookend := {|
  gvar_info := (tarray tuint 18);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _bookend_seg5_anims_05002540 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 3932160) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 270073856) ::
                Init_int32 (Int.repr 838860870) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_flying_bookend_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBookendSpawn := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bookend_spawn_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvHauntedBookshelfManager := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_haunted_bookshelf_manager_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBookSwitch := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 236257310) ::
                Init_int32 (Int.repr 252723200) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_book_switch_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFirePiranhaPlant := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _piranha_plant_seg6_anims_0601C31C (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 570425344) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_fire_piranha_plant_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_fire_piranha_plant_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSmallPiranhaFlame := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 1966080) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_small_piranha_flame_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFireSpitter := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 838860840) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_fire_spitter_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvFlyguyFlame := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 200) :: Init_int32 (Int.repr 1000) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_fly_guy_flame_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 253362177) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSnufit := {|
  gvar_info := (tarray tuint 15);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 1966080) ::
                Init_int32 (Int.repr (-3276800)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 270204928) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_snufit_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSnufitBalls := {|
  gvar_info := (tarray tuint 16);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 553648128) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 655360) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 236257290) ::
                Init_int32 (Int.repr 838860810) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_snufit_balls_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvHorizontalGrindel := {|
  gvar_info := (tarray tuint 22);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _ssl_seg7_collision_grindel (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 2686576) ::
                Init_int32 (Int.repr 1000) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 838860890) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_horizontal_grindel_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _cur_obj_update_floor_and_walls (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_horizontal_grindel_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvEyerokBoss := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_eyerok_boss_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvEyerokHand := {|
  gvar_info := (tarray tuint 16);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285286465) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _eyerok_seg5_anims_050116E4 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671481856) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 9830400) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 270139395) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_eyerok_hand_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvKlepto := {|
  gvar_info := (tarray tuint 17);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286601) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _klepto_seg5_anims_05008CFC (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 6553600) ::
                Init_int32 (Int.repr (-1309720)) ::
                Init_int32 (Int.repr 65536200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_klepto_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_klepto_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBird := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _birds_seg5_anims_050009E8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 570425344) ::
                Init_int32 (Int.repr 838860870) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bird_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvRacingPenguin := {|
  gvar_info := (tarray tuint 17);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286601) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _penguin_seg5_anims_05008B74 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671285248) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 19725536) ::
                Init_int32 (Int.repr (-327680)) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 838861200) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_racing_penguin_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_racing_penguin_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPenguinRaceFinishLine := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278401) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_penguin_race_finish_line_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvPenguinRaceShortcutCheck := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_penguin_race_shortcut_check_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCoffinSpawner := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_coffin_spawner_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvCoffin := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _bbh_seg7_collision_coffin (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_init_room (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_coffin_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvClamShell := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _clam_shell_seg5_anims_05001744 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 236257290) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_clam_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSkeeter := {|
  gvar_info := (tarray tuint 14);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _skeeter_seg6_anims_06007DE0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 11861616) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65537200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_skeeter_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSkeeterWave := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_skeeter_wave_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvSwingPlatform := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _rr_seg7_collision_pendulum (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 239273936) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_swing_platform_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_swing_platform_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _load_object_collision_model (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvDonutPlatformSpawner := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 720896) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_donut_platform_spawner_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvDonutPlatform := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 589824) ::
                Init_int32 (Int.repr 704643072) ::
                Init_addrof _rr_seg7_collision_donut_platform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 285278273) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_donut_platform_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvDDDPole := {|
  gvar_info := (tarray tuint 17);
  gvar_init := (Init_int32 (Int.repr 655360) ::
                Init_int32 (Int.repr 788529152) ::
                Init_int32 (Int.repr 64) ::
                Init_int32 (Int.repr 587202560) ::
                Init_int32 (Int.repr 5243680) ::
                Init_int32 (Int.repr 268763136) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ddd_pole_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 236650506) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_ddd_pole_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_pole_base_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvRedCoinStarMarker := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 503316480) ::
                Init_int32 (Int.repr 838860950) ::
                Init_int32 (Int.repr 269631488) ::
                Init_int32 (Int.repr 218562620) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_red_coin_star_marker_init (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 252903680) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvTripletButterfly := {|
  gvar_info := (tarray tuint 17);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _butterfly_seg3_anims_030056B0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 570425344) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 805306368) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 65536200) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 236650497) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_triplet_butterfly_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBubba := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 262144) ::
                Init_int32 (Int.repr 285286473) ::
                Init_int32 (Int.repr 754974720) ::
                Init_int32 (Int.repr 805306368) ::
                Init_int32 (Int.repr 13172336) ::
                Init_int32 (Int.repr (-3275800)) ::
                Init_int32 (Int.repr 65536000) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 838860850) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_bubba_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBeginningLakitu := {|
  gvar_info := (tarray tuint 10);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _lakitu_seg6_anims_060058F8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 238878720) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_intro_lakitu_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvBeginningPeach := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _peach_seg5_anims_0501C41C (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_intro_peach_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvEndBirds1 := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278225) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _birds_seg5_anims_050009E8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_end_birds_1_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvEndBirds2 := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278225) ::
                Init_int32 (Int.repr 656801792) ::
                Init_addrof _birds_seg5_anims_050009E8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671088640) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_end_birds_2_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvIntroScene := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 524288) ::
                Init_int32 (Int.repr 285278209) ::
                Init_int32 (Int.repr 134217728) ::
                Init_int32 (Int.repr 201326592) ::
                Init_addrof _bhv_intro_scene_loop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 150994944) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition composites : list composite_definition :=
(Composite _Animation Struct
   (Member_plain _flags tshort :: Member_plain _animYTransDivisor tshort ::
    Member_plain _startFrame tshort :: Member_plain _loopStart tshort ::
    Member_plain _loopEnd tshort :: Member_plain _unusedBoneCount tshort ::
    Member_plain _values (tptr tshort) ::
    Member_plain _index (tptr tushort) :: Member_plain _length tuint :: nil)
   noattr ::
 Composite _WaterDropletParams Struct
   (Member_plain _flags tshort :: Member_plain _model tshort ::
    Member_plain _behavior (tptr tuint) ::
    Member_plain _moveAngleRange tshort :: Member_plain _moveRange tshort ::
    Member_plain _randForwardVelOffset tfloat ::
    Member_plain _randForwardVelScale tfloat ::
    Member_plain _randYVelOffset tfloat ::
    Member_plain _randYVelScale tfloat ::
    Member_plain _randSizeOffset tfloat ::
    Member_plain _randSizeScale tfloat :: nil)
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
 (_bhv_mario_update,
   Gfun(External (EF_external "bhv_mario_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_star_door_loop_2,
   Gfun(External (EF_external "bhv_star_door_loop_2"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_cap_switch_loop,
   Gfun(External (EF_external "bhv_cap_switch_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_tiny_star_particles_init,
   Gfun(External (EF_external "bhv_tiny_star_particles_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_grindel_thwomp_loop,
   Gfun(External (EF_external "bhv_grindel_thwomp_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_door_init,
   Gfun(External (EF_external "bhv_door_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_door_loop,
   Gfun(External (EF_external "bhv_door_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_star_door_loop,
   Gfun(External (EF_external "bhv_star_door_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_mr_i_loop,
   Gfun(External (EF_external "bhv_mr_i_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_mr_i_body_loop,
   Gfun(External (EF_external "bhv_mr_i_body_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_mr_i_particle_loop,
   Gfun(External (EF_external "bhv_mr_i_particle_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_piranha_particle_loop,
   Gfun(External (EF_external "bhv_piranha_particle_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_giant_pole_loop,
   Gfun(External (EF_external "bhv_giant_pole_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_pole_init,
   Gfun(External (EF_external "bhv_pole_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_pole_base_loop,
   Gfun(External (EF_external "bhv_pole_base_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_thi_huge_island_top_loop,
   Gfun(External (EF_external "bhv_thi_huge_island_top_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_thi_tiny_island_top_loop,
   Gfun(External (EF_external "bhv_thi_tiny_island_top_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_king_bobomb_loop,
   Gfun(External (EF_external "bhv_king_bobomb_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bobomb_anchor_mario_loop,
   Gfun(External (EF_external "bhv_bobomb_anchor_mario_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_beta_chest_bottom_init,
   Gfun(External (EF_external "bhv_beta_chest_bottom_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_beta_chest_bottom_loop,
   Gfun(External (EF_external "bhv_beta_chest_bottom_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_beta_chest_lid_loop,
   Gfun(External (EF_external "bhv_beta_chest_lid_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bubble_wave_init,
   Gfun(External (EF_external "bhv_bubble_wave_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bubble_maybe_loop,
   Gfun(External (EF_external "bhv_bubble_maybe_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_water_air_bubble_init,
   Gfun(External (EF_external "bhv_water_air_bubble_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_water_air_bubble_loop,
   Gfun(External (EF_external "bhv_water_air_bubble_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_particle_init,
   Gfun(External (EF_external "bhv_particle_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_particle_loop,
   Gfun(External (EF_external "bhv_particle_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_water_waves_init,
   Gfun(External (EF_external "bhv_water_waves_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_small_bubbles_loop,
   Gfun(External (EF_external "bhv_small_bubbles_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_fish_group_loop,
   Gfun(External (EF_external "bhv_fish_group_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_cannon_base_loop,
   Gfun(External (EF_external "bhv_cannon_base_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_cannon_barrel_loop,
   Gfun(External (EF_external "bhv_cannon_barrel_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_cannon_base_unused_loop,
   Gfun(External (EF_external "bhv_cannon_base_unused_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_chuckya_loop,
   Gfun(External (EF_external "bhv_chuckya_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_chuckya_anchor_mario_loop,
   Gfun(External (EF_external "bhv_chuckya_anchor_mario_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_rotating_platform_loop,
   Gfun(External (EF_external "bhv_rotating_platform_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_wf_breakable_wall_loop,
   Gfun(External (EF_external "bhv_wf_breakable_wall_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_kickable_board_loop,
   Gfun(External (EF_external "bhv_kickable_board_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_tower_door_loop,
   Gfun(External (EF_external "bhv_tower_door_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_wf_rotating_wooden_platform_loop,
   Gfun(External (EF_external "bhv_wf_rotating_wooden_platform_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_koopa_shell_underwater_loop,
   Gfun(External (EF_external "bhv_koopa_shell_underwater_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_fading_warp_loop,
   Gfun(External (EF_external "bhv_fading_warp_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_warp_loop,
   Gfun(External (EF_external "bhv_warp_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_white_puff_exploding_loop,
   Gfun(External (EF_external "bhv_white_puff_exploding_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_spawned_star_init,
   Gfun(External (EF_external "bhv_spawned_star_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_spawned_star_loop,
   Gfun(External (EF_external "bhv_spawned_star_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_spawned_coin_init,
   Gfun(External (EF_external "bhv_spawned_coin_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_spawned_coin_loop,
   Gfun(External (EF_external "bhv_spawned_coin_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_coin_inside_boo_loop,
   Gfun(External (EF_external "bhv_coin_inside_boo_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_coin_formation_init,
   Gfun(External (EF_external "bhv_coin_formation_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_coin_formation_spawn_loop,
   Gfun(External (EF_external "bhv_coin_formation_spawn_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_coin_formation_loop,
   Gfun(External (EF_external "bhv_coin_formation_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_temp_coin_loop,
   Gfun(External (EF_external "bhv_temp_coin_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_coin_sparkles_loop,
   Gfun(External (EF_external "bhv_coin_sparkles_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_golden_coin_sparkles_loop,
   Gfun(External (EF_external "bhv_golden_coin_sparkles_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_wall_tiny_star_particle_loop,
   Gfun(External (EF_external "bhv_wall_tiny_star_particle_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_pound_tiny_star_particle_loop,
   Gfun(External (EF_external "bhv_pound_tiny_star_particle_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_pound_tiny_star_particle_init,
   Gfun(External (EF_external "bhv_pound_tiny_star_particle_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_punch_tiny_triangle_loop,
   Gfun(External (EF_external "bhv_punch_tiny_triangle_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_punch_tiny_triangle_init,
   Gfun(External (EF_external "bhv_punch_tiny_triangle_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_tumbling_bridge_platform_loop,
   Gfun(External (EF_external "bhv_tumbling_bridge_platform_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_tumbling_bridge_loop,
   Gfun(External (EF_external "bhv_tumbling_bridge_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_elevator_init,
   Gfun(External (EF_external "bhv_elevator_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_elevator_loop,
   Gfun(External (EF_external "bhv_elevator_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_water_mist_loop,
   Gfun(External (EF_external "bhv_water_mist_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_water_mist_spawn_loop,
   Gfun(External (EF_external "bhv_water_mist_spawn_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_water_mist_2_loop,
   Gfun(External (EF_external "bhv_water_mist_2_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_pound_white_puffs_init,
   Gfun(External (EF_external "bhv_pound_white_puffs_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ground_sand_init,
   Gfun(External (EF_external "bhv_ground_sand_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ground_snow_init,
   Gfun(External (EF_external "bhv_ground_snow_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_wind_loop,
   Gfun(External (EF_external "bhv_wind_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_unused_particle_spawn_loop,
   Gfun(External (EF_external "bhv_unused_particle_spawn_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ukiki_cage_star_loop,
   Gfun(External (EF_external "bhv_ukiki_cage_star_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ukiki_cage_loop,
   Gfun(External (EF_external "bhv_ukiki_cage_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bitfs_sinking_platform_loop,
   Gfun(External (EF_external "bhv_bitfs_sinking_platform_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bitfs_sinking_cage_platform_loop,
   Gfun(External (EF_external "bhv_bitfs_sinking_cage_platform_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ddd_moving_pole_loop,
   Gfun(External (EF_external "bhv_ddd_moving_pole_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_platform_normals_init,
   Gfun(External (EF_external "bhv_platform_normals_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_tilting_inverted_pyramid_loop,
   Gfun(External (EF_external "bhv_tilting_inverted_pyramid_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_squishable_platform_loop,
   Gfun(External (EF_external "bhv_squishable_platform_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_beta_moving_flames_spawn_loop,
   Gfun(External (EF_external "bhv_beta_moving_flames_spawn_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_beta_moving_flames_loop,
   Gfun(External (EF_external "bhv_beta_moving_flames_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_rr_rotating_bridge_platform_loop,
   Gfun(External (EF_external "bhv_rr_rotating_bridge_platform_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_flamethrower_loop,
   Gfun(External (EF_external "bhv_flamethrower_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_flamethrower_flame_loop,
   Gfun(External (EF_external "bhv_flamethrower_flame_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bouncing_fireball_loop,
   Gfun(External (EF_external "bhv_bouncing_fireball_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bouncing_fireball_flame_loop,
   Gfun(External (EF_external "bhv_bouncing_fireball_flame_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bowser_shock_wave_loop,
   Gfun(External (EF_external "bhv_bowser_shock_wave_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_flame_mario_loop,
   Gfun(External (EF_external "bhv_flame_mario_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_black_smoke_mario_loop,
   Gfun(External (EF_external "bhv_black_smoke_mario_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_black_smoke_bowser_loop,
   Gfun(External (EF_external "bhv_black_smoke_bowser_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_black_smoke_upward_loop,
   Gfun(External (EF_external "bhv_black_smoke_upward_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_beta_fish_splash_spawner_loop,
   Gfun(External (EF_external "bhv_beta_fish_splash_spawner_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_spindrift_loop,
   Gfun(External (EF_external "bhv_spindrift_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_tower_platform_group_loop,
   Gfun(External (EF_external "bhv_tower_platform_group_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_wf_sliding_tower_platform_loop,
   Gfun(External (EF_external "bhv_wf_sliding_tower_platform_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_wf_elevator_tower_platform_loop,
   Gfun(External (EF_external "bhv_wf_elevator_tower_platform_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_wf_solid_tower_platform_loop,
   Gfun(External (EF_external "bhv_wf_solid_tower_platform_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_snow_leaf_particle_spawn_init,
   Gfun(External (EF_external "bhv_snow_leaf_particle_spawn_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_tree_snow_or_leaf_loop,
   Gfun(External (EF_external "bhv_tree_snow_or_leaf_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_piranha_plant_bubble_loop,
   Gfun(External (EF_external "bhv_piranha_plant_bubble_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_piranha_plant_waking_bubbles_loop,
   Gfun(External (EF_external "bhv_piranha_plant_waking_bubbles_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_purple_switch_loop,
   Gfun(External (EF_external "bhv_purple_switch_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_hidden_object_loop,
   Gfun(External (EF_external "bhv_hidden_object_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_breakable_box_loop,
   Gfun(External (EF_external "bhv_breakable_box_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_pushable_loop,
   Gfun(External (EF_external "bhv_pushable_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_init_room,
   Gfun(External (EF_external "bhv_init_room"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_small_water_wave_loop,
   Gfun(External (EF_external "bhv_small_water_wave_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_yellow_coin_init,
   Gfun(External (EF_external "bhv_yellow_coin_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_yellow_coin_loop,
   Gfun(External (EF_external "bhv_yellow_coin_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_squarish_path_moving_loop,
   Gfun(External (EF_external "bhv_squarish_path_moving_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_heave_ho_loop,
   Gfun(External (EF_external "bhv_heave_ho_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_heave_ho_throw_mario_loop,
   Gfun(External (EF_external "bhv_heave_ho_throw_mario_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ccm_touched_star_spawn_loop,
   Gfun(External (EF_external "bhv_ccm_touched_star_spawn_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_unused_poundable_platform,
   Gfun(External (EF_external "bhv_unused_poundable_platform"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_beta_trampoline_top_loop,
   Gfun(External (EF_external "bhv_beta_trampoline_top_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_beta_trampoline_spring_loop,
   Gfun(External (EF_external "bhv_beta_trampoline_spring_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_jumping_box_loop,
   Gfun(External (EF_external "bhv_jumping_box_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_boo_cage_loop,
   Gfun(External (EF_external "bhv_boo_cage_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bowser_key_loop,
   Gfun(External (EF_external "bhv_bowser_key_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_grand_star_loop,
   Gfun(External (EF_external "bhv_grand_star_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_beta_boo_key_loop,
   Gfun(External (EF_external "bhv_beta_boo_key_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_alpha_boo_key_loop,
   Gfun(External (EF_external "bhv_alpha_boo_key_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bullet_bill_init,
   Gfun(External (EF_external "bhv_bullet_bill_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bullet_bill_loop,
   Gfun(External (EF_external "bhv_bullet_bill_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_white_puff_smoke_init,
   Gfun(External (EF_external "bhv_white_puff_smoke_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bowser_tail_anchor_loop,
   Gfun(External (EF_external "bhv_bowser_tail_anchor_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bowser_init,
   Gfun(External (EF_external "bhv_bowser_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bowser_loop,
   Gfun(External (EF_external "bhv_bowser_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bowser_body_anchor_loop,
   Gfun(External (EF_external "bhv_bowser_body_anchor_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bowser_flame_spawn_loop,
   Gfun(External (EF_external "bhv_bowser_flame_spawn_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_falling_bowser_platform_loop,
   Gfun(External (EF_external "bhv_falling_bowser_platform_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_blue_bowser_flame_init,
   Gfun(External (EF_external "bhv_blue_bowser_flame_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_blue_bowser_flame_loop,
   Gfun(External (EF_external "bhv_blue_bowser_flame_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_flame_floating_landing_init,
   Gfun(External (EF_external "bhv_flame_floating_landing_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_flame_floating_landing_loop,
   Gfun(External (EF_external "bhv_flame_floating_landing_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_blue_flames_group_loop,
   Gfun(External (EF_external "bhv_blue_flames_group_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_flame_bouncing_init,
   Gfun(External (EF_external "bhv_flame_bouncing_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_flame_bouncing_loop,
   Gfun(External (EF_external "bhv_flame_bouncing_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_flame_moving_forward_growing_init,
   Gfun(External (EF_external "bhv_flame_moving_forward_growing_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_flame_moving_forward_growing_loop,
   Gfun(External (EF_external "bhv_flame_moving_forward_growing_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_flame_bowser_init,
   Gfun(External (EF_external "bhv_flame_bowser_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_flame_bowser_loop,
   Gfun(External (EF_external "bhv_flame_bowser_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_flame_large_burning_out_init,
   Gfun(External (EF_external "bhv_flame_large_burning_out_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_blue_fish_movement_loop,
   Gfun(External (EF_external "bhv_blue_fish_movement_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_tank_fish_group_loop,
   Gfun(External (EF_external "bhv_tank_fish_group_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_checkerboard_elevator_group_init,
   Gfun(External (EF_external "bhv_checkerboard_elevator_group_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_checkerboard_platform_init,
   Gfun(External (EF_external "bhv_checkerboard_platform_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_checkerboard_platform_loop,
   Gfun(External (EF_external "bhv_checkerboard_platform_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bowser_key_unlock_door_loop,
   Gfun(External (EF_external "bhv_bowser_key_unlock_door_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bowser_key_course_exit_loop,
   Gfun(External (EF_external "bhv_bowser_key_course_exit_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_invisible_objects_under_bridge_init,
   Gfun(External (EF_external "bhv_invisible_objects_under_bridge_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_water_level_pillar_init,
   Gfun(External (EF_external "bhv_water_level_pillar_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_water_level_pillar_loop,
   Gfun(External (EF_external "bhv_water_level_pillar_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ddd_warp_loop,
   Gfun(External (EF_external "bhv_ddd_warp_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_moat_grills_loop,
   Gfun(External (EF_external "bhv_moat_grills_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_rotating_clock_arm_loop,
   Gfun(External (EF_external "bhv_rotating_clock_arm_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ukiki_init,
   Gfun(External (EF_external "bhv_ukiki_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ukiki_loop,
   Gfun(External (EF_external "bhv_ukiki_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_lll_sinking_rock_block_loop,
   Gfun(External (EF_external "bhv_lll_sinking_rock_block_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_lll_moving_octagonal_mesh_platform_loop,
   Gfun(External (EF_external "bhv_lll_moving_octagonal_mesh_platform_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_lll_rotating_block_fire_bars_loop,
   Gfun(External (EF_external "bhv_lll_rotating_block_fire_bars_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_lll_rotating_hex_flame_loop,
   Gfun(External (EF_external "bhv_lll_rotating_hex_flame_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_lll_wood_piece_loop,
   Gfun(External (EF_external "bhv_lll_wood_piece_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_lll_floating_wood_bridge_loop,
   Gfun(External (EF_external "bhv_lll_floating_wood_bridge_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_volcano_flames_loop,
   Gfun(External (EF_external "bhv_volcano_flames_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_lll_rotating_hexagonal_ring_loop,
   Gfun(External (EF_external "bhv_lll_rotating_hexagonal_ring_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_lll_sinking_rectangular_platform_loop,
   Gfun(External (EF_external "bhv_lll_sinking_rectangular_platform_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_lll_sinking_square_platforms_loop,
   Gfun(External (EF_external "bhv_lll_sinking_square_platforms_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_koopa_shell_loop,
   Gfun(External (EF_external "bhv_koopa_shell_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_koopa_shell_flame_loop,
   Gfun(External (EF_external "bhv_koopa_shell_flame_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_tox_box_loop,
   Gfun(External (EF_external "bhv_tox_box_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_piranha_plant_loop,
   Gfun(External (EF_external "bhv_piranha_plant_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_lll_bowser_puzzle_piece_loop,
   Gfun(External (EF_external "bhv_lll_bowser_puzzle_piece_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_lll_bowser_puzzle_loop,
   Gfun(External (EF_external "bhv_lll_bowser_puzzle_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_tuxies_mother_loop,
   Gfun(External (EF_external "bhv_tuxies_mother_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_small_penguin_loop,
   Gfun(External (EF_external "bhv_small_penguin_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_fish_spawner_loop,
   Gfun(External (EF_external "bhv_fish_spawner_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_fish_loop,
   Gfun(External (EF_external "bhv_fish_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_wdw_express_elevator_loop,
   Gfun(External (EF_external "bhv_wdw_express_elevator_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bub_spawner_loop,
   Gfun(External (EF_external "bhv_bub_spawner_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bub_loop,
   Gfun(External (EF_external "bhv_bub_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_exclamation_box_loop,
   Gfun(External (EF_external "bhv_exclamation_box_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_rotating_exclamation_box_loop,
   Gfun(External (EF_external "bhv_rotating_exclamation_box_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_sound_spawner_init,
   Gfun(External (EF_external "bhv_sound_spawner_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bowsers_sub_loop,
   Gfun(External (EF_external "bhv_bowsers_sub_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_sushi_shark_loop,
   Gfun(External (EF_external "bhv_sushi_shark_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_sushi_shark_collision_loop,
   Gfun(External (EF_external "bhv_sushi_shark_collision_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_jrb_sliding_box_loop,
   Gfun(External (EF_external "bhv_jrb_sliding_box_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ship_part_3_loop,
   Gfun(External (EF_external "bhv_ship_part_3_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_sunken_ship_part_loop,
   Gfun(External (EF_external "bhv_sunken_ship_part_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_white_puff_1_loop,
   Gfun(External (EF_external "bhv_white_puff_1_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_white_puff_2_loop,
   Gfun(External (EF_external "bhv_white_puff_2_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_blue_coin_switch_loop,
   Gfun(External (EF_external "bhv_blue_coin_switch_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_hidden_blue_coin_loop,
   Gfun(External (EF_external "bhv_hidden_blue_coin_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_openable_cage_door_loop,
   Gfun(External (EF_external "bhv_openable_cage_door_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_openable_grill_loop,
   Gfun(External (EF_external "bhv_openable_grill_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_water_level_diamond_loop,
   Gfun(External (EF_external "bhv_water_level_diamond_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_init_changing_water_level_loop,
   Gfun(External (EF_external "bhv_init_changing_water_level_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_tweester_sand_particle_loop,
   Gfun(External (EF_external "bhv_tweester_sand_particle_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_tweester_loop,
   Gfun(External (EF_external "bhv_tweester_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_merry_go_round_boo_manager_loop,
   Gfun(External (EF_external "bhv_merry_go_round_boo_manager_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_animated_texture_loop,
   Gfun(External (EF_external "bhv_animated_texture_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_boo_in_castle_loop,
   Gfun(External (EF_external "bhv_boo_in_castle_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_boo_with_cage_init,
   Gfun(External (EF_external "bhv_boo_with_cage_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_boo_with_cage_loop,
   Gfun(External (EF_external "bhv_boo_with_cage_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_boo_init,
   Gfun(External (EF_external "bhv_boo_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_big_boo_loop,
   Gfun(External (EF_external "bhv_big_boo_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_courtyard_boo_triplet_init,
   Gfun(External (EF_external "bhv_courtyard_boo_triplet_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_boo_loop,
   Gfun(External (EF_external "bhv_boo_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_boo_staircase,
   Gfun(External (EF_external "bhv_boo_staircase"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bbh_tilting_trap_platform_loop,
   Gfun(External (EF_external "bhv_bbh_tilting_trap_platform_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_haunted_bookshelf_loop,
   Gfun(External (EF_external "bhv_haunted_bookshelf_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_merry_go_round_loop,
   Gfun(External (EF_external "bhv_merry_go_round_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_play_music_track_when_touched_loop,
   Gfun(External (EF_external "bhv_play_music_track_when_touched_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_beta_bowser_anchor_loop,
   Gfun(External (EF_external "bhv_beta_bowser_anchor_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_static_checkered_platform_loop,
   Gfun(External (EF_external "bhv_static_checkered_platform_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_castle_floor_trap_init,
   Gfun(External (EF_external "bhv_castle_floor_trap_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_castle_floor_trap_loop,
   Gfun(External (EF_external "bhv_castle_floor_trap_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_floor_trap_in_castle_loop,
   Gfun(External (EF_external "bhv_floor_trap_in_castle_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_sparkle_spawn_loop,
   Gfun(External (EF_external "bhv_sparkle_spawn_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_scuttlebug_loop,
   Gfun(External (EF_external "bhv_scuttlebug_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_scuttlebug_spawn_loop,
   Gfun(External (EF_external "bhv_scuttlebug_spawn_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_whomp_loop,
   Gfun(External (EF_external "bhv_whomp_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_water_splash_spawn_droplets,
   Gfun(External (EF_external "bhv_water_splash_spawn_droplets"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_water_droplet_loop,
   Gfun(External (EF_external "bhv_water_droplet_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_water_droplet_splash_init,
   Gfun(External (EF_external "bhv_water_droplet_splash_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bubble_splash_init,
   Gfun(External (EF_external "bhv_bubble_splash_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_idle_water_wave_loop,
   Gfun(External (EF_external "bhv_idle_water_wave_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_shallow_water_splash_init,
   Gfun(External (EF_external "bhv_shallow_water_splash_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_wave_trail_shrink,
   Gfun(External (EF_external "bhv_wave_trail_shrink"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_strong_wind_particle_loop,
   Gfun(External (EF_external "bhv_strong_wind_particle_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_sl_snowman_wind_loop,
   Gfun(External (EF_external "bhv_sl_snowman_wind_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_sl_walking_penguin_loop,
   Gfun(External (EF_external "bhv_sl_walking_penguin_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_act_selector_star_type_loop,
   Gfun(External (EF_external "bhv_act_selector_star_type_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_act_selector_init,
   Gfun(External (EF_external "bhv_act_selector_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_act_selector_loop,
   Gfun(External (EF_external "bhv_act_selector_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_moving_yellow_coin_init,
   Gfun(External (EF_external "bhv_moving_yellow_coin_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_moving_yellow_coin_loop,
   Gfun(External (EF_external "bhv_moving_yellow_coin_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_moving_blue_coin_init,
   Gfun(External (EF_external "bhv_moving_blue_coin_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_moving_blue_coin_loop,
   Gfun(External (EF_external "bhv_moving_blue_coin_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_blue_coin_sliding_jumping_init,
   Gfun(External (EF_external "bhv_blue_coin_sliding_jumping_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_blue_coin_sliding_loop,
   Gfun(External (EF_external "bhv_blue_coin_sliding_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_blue_coin_jumping_loop,
   Gfun(External (EF_external "bhv_blue_coin_jumping_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_seaweed_init,
   Gfun(External (EF_external "bhv_seaweed_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_seaweed_bundle_init,
   Gfun(External (EF_external "bhv_seaweed_bundle_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bobomb_init,
   Gfun(External (EF_external "bhv_bobomb_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bobomb_loop,
   Gfun(External (EF_external "bhv_bobomb_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bobomb_fuse_smoke_init,
   Gfun(External (EF_external "bhv_bobomb_fuse_smoke_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bobomb_buddy_init,
   Gfun(External (EF_external "bhv_bobomb_buddy_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bobomb_buddy_loop,
   Gfun(External (EF_external "bhv_bobomb_buddy_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_cannon_closed_init,
   Gfun(External (EF_external "bhv_cannon_closed_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_cannon_closed_loop,
   Gfun(External (EF_external "bhv_cannon_closed_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_whirlpool_init,
   Gfun(External (EF_external "bhv_whirlpool_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_whirlpool_loop,
   Gfun(External (EF_external "bhv_whirlpool_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_jet_stream_loop,
   Gfun(External (EF_external "bhv_jet_stream_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_homing_amp_init,
   Gfun(External (EF_external "bhv_homing_amp_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_homing_amp_loop,
   Gfun(External (EF_external "bhv_homing_amp_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_circling_amp_init,
   Gfun(External (EF_external "bhv_circling_amp_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_circling_amp_loop,
   Gfun(External (EF_external "bhv_circling_amp_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_butterfly_init,
   Gfun(External (EF_external "bhv_butterfly_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_butterfly_loop,
   Gfun(External (EF_external "bhv_butterfly_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_hoot_init,
   Gfun(External (EF_external "bhv_hoot_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_hoot_loop,
   Gfun(External (EF_external "bhv_hoot_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_beta_holdable_object_init,
   Gfun(External (EF_external "bhv_beta_holdable_object_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_beta_holdable_object_loop,
   Gfun(External (EF_external "bhv_beta_holdable_object_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_object_bubble_init,
   Gfun(External (EF_external "bhv_object_bubble_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_object_bubble_loop,
   Gfun(External (EF_external "bhv_object_bubble_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_object_water_wave_init,
   Gfun(External (EF_external "bhv_object_water_wave_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_object_water_wave_loop,
   Gfun(External (EF_external "bhv_object_water_wave_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_explosion_init,
   Gfun(External (EF_external "bhv_explosion_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_explosion_loop,
   Gfun(External (EF_external "bhv_explosion_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bobomb_bully_death_smoke_init,
   Gfun(External (EF_external "bhv_bobomb_bully_death_smoke_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bobomb_explosion_bubble_init,
   Gfun(External (EF_external "bhv_bobomb_explosion_bubble_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bobomb_explosion_bubble_loop,
   Gfun(External (EF_external "bhv_bobomb_explosion_bubble_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_respawner_loop,
   Gfun(External (EF_external "bhv_respawner_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_small_bully_init,
   Gfun(External (EF_external "bhv_small_bully_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bully_loop,
   Gfun(External (EF_external "bhv_bully_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_big_bully_init,
   Gfun(External (EF_external "bhv_big_bully_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_big_bully_with_minions_init,
   Gfun(External (EF_external "bhv_big_bully_with_minions_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_big_bully_with_minions_loop,
   Gfun(External (EF_external "bhv_big_bully_with_minions_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_jet_stream_ring_spawner_loop,
   Gfun(External (EF_external "bhv_jet_stream_ring_spawner_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_jet_stream_water_ring_init,
   Gfun(External (EF_external "bhv_jet_stream_water_ring_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_jet_stream_water_ring_loop,
   Gfun(External (EF_external "bhv_jet_stream_water_ring_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_manta_ray_water_ring_init,
   Gfun(External (EF_external "bhv_manta_ray_water_ring_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_manta_ray_water_ring_loop,
   Gfun(External (EF_external "bhv_manta_ray_water_ring_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bowser_bomb_loop,
   Gfun(External (EF_external "bhv_bowser_bomb_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bowser_bomb_explosion_loop,
   Gfun(External (EF_external "bhv_bowser_bomb_explosion_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bowser_bomb_smoke_loop,
   Gfun(External (EF_external "bhv_bowser_bomb_smoke_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_celebration_star_init,
   Gfun(External (EF_external "bhv_celebration_star_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_celebration_star_loop,
   Gfun(External (EF_external "bhv_celebration_star_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_celebration_star_sparkle_loop,
   Gfun(External (EF_external "bhv_celebration_star_sparkle_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_star_key_collection_puff_spawner_loop,
   Gfun(External (EF_external "bhv_star_key_collection_puff_spawner_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_lll_drawbridge_spawner_loop,
   Gfun(External (EF_external "bhv_lll_drawbridge_spawner_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_lll_drawbridge_loop,
   Gfun(External (EF_external "bhv_lll_drawbridge_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_small_bomp_init,
   Gfun(External (EF_external "bhv_small_bomp_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_small_bomp_loop,
   Gfun(External (EF_external "bhv_small_bomp_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_large_bomp_init,
   Gfun(External (EF_external "bhv_large_bomp_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_large_bomp_loop,
   Gfun(External (EF_external "bhv_large_bomp_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_wf_sliding_platform_init,
   Gfun(External (EF_external "bhv_wf_sliding_platform_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_wf_sliding_platform_loop,
   Gfun(External (EF_external "bhv_wf_sliding_platform_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_moneybag_init,
   Gfun(External (EF_external "bhv_moneybag_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_moneybag_loop,
   Gfun(External (EF_external "bhv_moneybag_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_moneybag_hidden_loop,
   Gfun(External (EF_external "bhv_moneybag_hidden_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bob_pit_bowling_ball_init,
   Gfun(External (EF_external "bhv_bob_pit_bowling_ball_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bob_pit_bowling_ball_loop,
   Gfun(External (EF_external "bhv_bob_pit_bowling_ball_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_free_bowling_ball_init,
   Gfun(External (EF_external "bhv_free_bowling_ball_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_free_bowling_ball_loop,
   Gfun(External (EF_external "bhv_free_bowling_ball_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bowling_ball_init,
   Gfun(External (EF_external "bhv_bowling_ball_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bowling_ball_loop,
   Gfun(External (EF_external "bhv_bowling_ball_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_generic_bowling_ball_spawner_init,
   Gfun(External (EF_external "bhv_generic_bowling_ball_spawner_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_generic_bowling_ball_spawner_loop,
   Gfun(External (EF_external "bhv_generic_bowling_ball_spawner_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_thi_bowling_ball_spawner_loop,
   Gfun(External (EF_external "bhv_thi_bowling_ball_spawner_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_rr_cruiser_wing_init,
   Gfun(External (EF_external "bhv_rr_cruiser_wing_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_rr_cruiser_wing_loop,
   Gfun(External (EF_external "bhv_rr_cruiser_wing_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_spindel_init,
   Gfun(External (EF_external "bhv_spindel_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_spindel_loop,
   Gfun(External (EF_external "bhv_spindel_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ssl_moving_pyramid_wall_init,
   Gfun(External (EF_external "bhv_ssl_moving_pyramid_wall_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ssl_moving_pyramid_wall_loop,
   Gfun(External (EF_external "bhv_ssl_moving_pyramid_wall_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_pyramid_elevator_init,
   Gfun(External (EF_external "bhv_pyramid_elevator_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_pyramid_elevator_loop,
   Gfun(External (EF_external "bhv_pyramid_elevator_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_pyramid_elevator_trajectory_marker_ball_loop,
   Gfun(External (EF_external "bhv_pyramid_elevator_trajectory_marker_ball_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_pyramid_top_init,
   Gfun(External (EF_external "bhv_pyramid_top_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_pyramid_top_loop,
   Gfun(External (EF_external "bhv_pyramid_top_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_pyramid_top_fragment_init,
   Gfun(External (EF_external "bhv_pyramid_top_fragment_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_pyramid_top_fragment_loop,
   Gfun(External (EF_external "bhv_pyramid_top_fragment_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_pyramid_pillar_touch_detector_loop,
   Gfun(External (EF_external "bhv_pyramid_pillar_touch_detector_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_waterfall_sound_loop,
   Gfun(External (EF_external "bhv_waterfall_sound_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_volcano_sound_loop,
   Gfun(External (EF_external "bhv_volcano_sound_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_castle_flag_init,
   Gfun(External (EF_external "bhv_castle_flag_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_birds_sound_loop,
   Gfun(External (EF_external "bhv_birds_sound_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ambient_sounds_init,
   Gfun(External (EF_external "bhv_ambient_sounds_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_sand_sound_loop,
   Gfun(External (EF_external "bhv_sand_sound_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_castle_cannon_grate_init,
   Gfun(External (EF_external "bhv_castle_cannon_grate_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_snowmans_bottom_init,
   Gfun(External (EF_external "bhv_snowmans_bottom_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_snowmans_bottom_loop,
   Gfun(External (EF_external "bhv_snowmans_bottom_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_snowmans_head_init,
   Gfun(External (EF_external "bhv_snowmans_head_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_snowmans_head_loop,
   Gfun(External (EF_external "bhv_snowmans_head_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_snowmans_body_checkpoint_loop,
   Gfun(External (EF_external "bhv_snowmans_body_checkpoint_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_big_boulder_init,
   Gfun(External (EF_external "bhv_big_boulder_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_big_boulder_loop,
   Gfun(External (EF_external "bhv_big_boulder_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_big_boulder_generator_loop,
   Gfun(External (EF_external "bhv_big_boulder_generator_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_wing_cap_init,
   Gfun(External (EF_external "bhv_wing_cap_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_wing_vanish_cap_loop,
   Gfun(External (EF_external "bhv_wing_vanish_cap_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_metal_cap_init,
   Gfun(External (EF_external "bhv_metal_cap_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_metal_cap_loop,
   Gfun(External (EF_external "bhv_metal_cap_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_normal_cap_init,
   Gfun(External (EF_external "bhv_normal_cap_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_normal_cap_loop,
   Gfun(External (EF_external "bhv_normal_cap_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_vanish_cap_init,
   Gfun(External (EF_external "bhv_vanish_cap_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_collect_star_init,
   Gfun(External (EF_external "bhv_collect_star_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_collect_star_loop,
   Gfun(External (EF_external "bhv_collect_star_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_star_spawn_init,
   Gfun(External (EF_external "bhv_star_spawn_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_star_spawn_loop,
   Gfun(External (EF_external "bhv_star_spawn_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_hidden_red_coin_star_init,
   Gfun(External (EF_external "bhv_hidden_red_coin_star_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_hidden_red_coin_star_loop,
   Gfun(External (EF_external "bhv_hidden_red_coin_star_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_red_coin_init,
   Gfun(External (EF_external "bhv_red_coin_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_red_coin_loop,
   Gfun(External (EF_external "bhv_red_coin_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bowser_course_red_coin_star_loop,
   Gfun(External (EF_external "bhv_bowser_course_red_coin_star_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_hidden_star_init,
   Gfun(External (EF_external "bhv_hidden_star_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_hidden_star_loop,
   Gfun(External (EF_external "bhv_hidden_star_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_hidden_star_trigger_loop,
   Gfun(External (EF_external "bhv_hidden_star_trigger_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ttm_rolling_log_init,
   Gfun(External (EF_external "bhv_ttm_rolling_log_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_rolling_log_loop,
   Gfun(External (EF_external "bhv_rolling_log_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_lll_rolling_log_init,
   Gfun(External (EF_external "bhv_lll_rolling_log_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_1up_common_init,
   Gfun(External (EF_external "bhv_1up_common_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_1up_walking_loop,
   Gfun(External (EF_external "bhv_1up_walking_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_1up_running_away_loop,
   Gfun(External (EF_external "bhv_1up_running_away_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_1up_sliding_loop,
   Gfun(External (EF_external "bhv_1up_sliding_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_1up_init,
   Gfun(External (EF_external "bhv_1up_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_1up_loop,
   Gfun(External (EF_external "bhv_1up_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_1up_jump_on_approach_loop,
   Gfun(External (EF_external "bhv_1up_jump_on_approach_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_1up_hidden_loop,
   Gfun(External (EF_external "bhv_1up_hidden_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_1up_hidden_trigger_loop,
   Gfun(External (EF_external "bhv_1up_hidden_trigger_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_1up_hidden_in_pole_loop,
   Gfun(External (EF_external "bhv_1up_hidden_in_pole_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_1up_hidden_in_pole_trigger_loop,
   Gfun(External (EF_external "bhv_1up_hidden_in_pole_trigger_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_1up_hidden_in_pole_spawner_loop,
   Gfun(External (EF_external "bhv_1up_hidden_in_pole_spawner_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_controllable_platform_init,
   Gfun(External (EF_external "bhv_controllable_platform_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_controllable_platform_loop,
   Gfun(External (EF_external "bhv_controllable_platform_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_controllable_platform_sub_loop,
   Gfun(External (EF_external "bhv_controllable_platform_sub_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_breakable_box_small_init,
   Gfun(External (EF_external "bhv_breakable_box_small_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_breakable_box_small_loop,
   Gfun(External (EF_external "bhv_breakable_box_small_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_sliding_snow_mound_loop,
   Gfun(External (EF_external "bhv_sliding_snow_mound_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_snow_mound_spawn_loop,
   Gfun(External (EF_external "bhv_snow_mound_spawn_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_floating_platform_loop,
   Gfun(External (EF_external "bhv_floating_platform_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_arrow_lift_loop,
   Gfun(External (EF_external "bhv_arrow_lift_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_orange_number_init,
   Gfun(External (EF_external "bhv_orange_number_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_orange_number_loop,
   Gfun(External (EF_external "bhv_orange_number_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_manta_ray_init,
   Gfun(External (EF_external "bhv_manta_ray_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_manta_ray_loop,
   Gfun(External (EF_external "bhv_manta_ray_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_falling_pillar_init,
   Gfun(External (EF_external "bhv_falling_pillar_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_falling_pillar_loop,
   Gfun(External (EF_external "bhv_falling_pillar_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_falling_pillar_hitbox_loop,
   Gfun(External (EF_external "bhv_falling_pillar_hitbox_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_jrb_floating_box_loop,
   Gfun(External (EF_external "bhv_jrb_floating_box_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_decorative_pendulum_init,
   Gfun(External (EF_external "bhv_decorative_pendulum_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_decorative_pendulum_loop,
   Gfun(External (EF_external "bhv_decorative_pendulum_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_treasure_chest_ship_init,
   Gfun(External (EF_external "bhv_treasure_chest_ship_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_treasure_chest_ship_loop,
   Gfun(External (EF_external "bhv_treasure_chest_ship_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_treasure_chest_jrb_init,
   Gfun(External (EF_external "bhv_treasure_chest_jrb_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_treasure_chest_jrb_loop,
   Gfun(External (EF_external "bhv_treasure_chest_jrb_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_treasure_chest_ddd_init,
   Gfun(External (EF_external "bhv_treasure_chest_ddd_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_treasure_chest_ddd_loop,
   Gfun(External (EF_external "bhv_treasure_chest_ddd_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_treasure_chest_bottom_init,
   Gfun(External (EF_external "bhv_treasure_chest_bottom_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_treasure_chest_bottom_loop,
   Gfun(External (EF_external "bhv_treasure_chest_bottom_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_treasure_chest_top_loop,
   Gfun(External (EF_external "bhv_treasure_chest_top_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_mips_init,
   Gfun(External (EF_external "bhv_mips_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_mips_loop,
   Gfun(External (EF_external "bhv_mips_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_yoshi_init,
   Gfun(External (EF_external "bhv_yoshi_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_koopa_init,
   Gfun(External (EF_external "bhv_koopa_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_koopa_update,
   Gfun(External (EF_external "bhv_koopa_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_koopa_race_endpoint_update,
   Gfun(External (EF_external "bhv_koopa_race_endpoint_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_pokey_update,
   Gfun(External (EF_external "bhv_pokey_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_pokey_body_part_update,
   Gfun(External (EF_external "bhv_pokey_body_part_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_swoop_update,
   Gfun(External (EF_external "bhv_swoop_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_fly_guy_update,
   Gfun(External (EF_external "bhv_fly_guy_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_goomba_init,
   Gfun(External (EF_external "bhv_goomba_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_goomba_update,
   Gfun(External (EF_external "bhv_goomba_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_goomba_triplet_spawner_update,
   Gfun(External (EF_external "bhv_goomba_triplet_spawner_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_chain_chomp_update,
   Gfun(External (EF_external "bhv_chain_chomp_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_chain_chomp_chain_part_update,
   Gfun(External (EF_external "bhv_chain_chomp_chain_part_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_wooden_post_update,
   Gfun(External (EF_external "bhv_wooden_post_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_chain_chomp_gate_init,
   Gfun(External (EF_external "bhv_chain_chomp_gate_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_chain_chomp_gate_update,
   Gfun(External (EF_external "bhv_chain_chomp_gate_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_wiggler_update,
   Gfun(External (EF_external "bhv_wiggler_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_wiggler_body_part_update,
   Gfun(External (EF_external "bhv_wiggler_body_part_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_enemy_lakitu_update,
   Gfun(External (EF_external "bhv_enemy_lakitu_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_camera_lakitu_init,
   Gfun(External (EF_external "bhv_camera_lakitu_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_camera_lakitu_update,
   Gfun(External (EF_external "bhv_camera_lakitu_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_cloud_update,
   Gfun(External (EF_external "bhv_cloud_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_cloud_part_update,
   Gfun(External (EF_external "bhv_cloud_part_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_spiny_update,
   Gfun(External (EF_external "bhv_spiny_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_monty_mole_init,
   Gfun(External (EF_external "bhv_monty_mole_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_monty_mole_update,
   Gfun(External (EF_external "bhv_monty_mole_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_monty_mole_hole_update,
   Gfun(External (EF_external "bhv_monty_mole_hole_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_monty_mole_rock_update,
   Gfun(External (EF_external "bhv_monty_mole_rock_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_platform_on_track_init,
   Gfun(External (EF_external "bhv_platform_on_track_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_platform_on_track_update,
   Gfun(External (EF_external "bhv_platform_on_track_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_track_ball_update,
   Gfun(External (EF_external "bhv_track_ball_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_seesaw_platform_init,
   Gfun(External (EF_external "bhv_seesaw_platform_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_seesaw_platform_update,
   Gfun(External (EF_external "bhv_seesaw_platform_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ferris_wheel_axle_init,
   Gfun(External (EF_external "bhv_ferris_wheel_axle_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ferris_wheel_platform_update,
   Gfun(External (EF_external "bhv_ferris_wheel_platform_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_water_bomb_spawner_update,
   Gfun(External (EF_external "bhv_water_bomb_spawner_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_water_bomb_update,
   Gfun(External (EF_external "bhv_water_bomb_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_water_bomb_shadow_update,
   Gfun(External (EF_external "bhv_water_bomb_shadow_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ttc_rotating_solid_init,
   Gfun(External (EF_external "bhv_ttc_rotating_solid_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ttc_rotating_solid_update,
   Gfun(External (EF_external "bhv_ttc_rotating_solid_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ttc_pendulum_init,
   Gfun(External (EF_external "bhv_ttc_pendulum_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ttc_pendulum_update,
   Gfun(External (EF_external "bhv_ttc_pendulum_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ttc_treadmill_init,
   Gfun(External (EF_external "bhv_ttc_treadmill_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ttc_treadmill_update,
   Gfun(External (EF_external "bhv_ttc_treadmill_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ttc_moving_bar_init,
   Gfun(External (EF_external "bhv_ttc_moving_bar_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ttc_moving_bar_update,
   Gfun(External (EF_external "bhv_ttc_moving_bar_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ttc_cog_init,
   Gfun(External (EF_external "bhv_ttc_cog_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ttc_cog_update,
   Gfun(External (EF_external "bhv_ttc_cog_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ttc_pit_block_init,
   Gfun(External (EF_external "bhv_ttc_pit_block_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ttc_pit_block_update,
   Gfun(External (EF_external "bhv_ttc_pit_block_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ttc_elevator_init,
   Gfun(External (EF_external "bhv_ttc_elevator_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ttc_elevator_update,
   Gfun(External (EF_external "bhv_ttc_elevator_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ttc_2d_rotator_init,
   Gfun(External (EF_external "bhv_ttc_2d_rotator_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ttc_2d_rotator_update,
   Gfun(External (EF_external "bhv_ttc_2d_rotator_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ttc_spinner_update,
   Gfun(External (EF_external "bhv_ttc_spinner_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_mr_blizzard_init,
   Gfun(External (EF_external "bhv_mr_blizzard_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_mr_blizzard_update,
   Gfun(External (EF_external "bhv_mr_blizzard_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_mr_blizzard_snowball,
   Gfun(External (EF_external "bhv_mr_blizzard_snowball"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_sliding_plat_2_init,
   Gfun(External (EF_external "bhv_sliding_plat_2_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_sliding_plat_2_loop,
   Gfun(External (EF_external "bhv_sliding_plat_2_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_rotating_octagonal_plat_init,
   Gfun(External (EF_external "bhv_rotating_octagonal_plat_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_rotating_octagonal_plat_loop,
   Gfun(External (EF_external "bhv_rotating_octagonal_plat_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_animates_on_floor_switch_press_init,
   Gfun(External (EF_external "bhv_animates_on_floor_switch_press_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_animates_on_floor_switch_press_loop,
   Gfun(External (EF_external "bhv_animates_on_floor_switch_press_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_activated_back_and_forth_platform_init,
   Gfun(External (EF_external "bhv_activated_back_and_forth_platform_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_activated_back_and_forth_platform_update,
   Gfun(External (EF_external "bhv_activated_back_and_forth_platform_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_recovery_heart_loop,
   Gfun(External (EF_external "bhv_recovery_heart_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_water_bomb_cannon_loop,
   Gfun(External (EF_external "bhv_water_bomb_cannon_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bubble_cannon_barrel_loop,
   Gfun(External (EF_external "bhv_bubble_cannon_barrel_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_unagi_init,
   Gfun(External (EF_external "bhv_unagi_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_unagi_loop,
   Gfun(External (EF_external "bhv_unagi_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_unagi_subobject_loop,
   Gfun(External (EF_external "bhv_unagi_subobject_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_dorrie_update,
   Gfun(External (EF_external "bhv_dorrie_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_haunted_chair_init,
   Gfun(External (EF_external "bhv_haunted_chair_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_haunted_chair_loop,
   Gfun(External (EF_external "bhv_haunted_chair_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_mad_piano_update,
   Gfun(External (EF_external "bhv_mad_piano_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_flying_bookend_loop,
   Gfun(External (EF_external "bhv_flying_bookend_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bookend_spawn_loop,
   Gfun(External (EF_external "bhv_bookend_spawn_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_haunted_bookshelf_manager_loop,
   Gfun(External (EF_external "bhv_haunted_bookshelf_manager_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_book_switch_loop,
   Gfun(External (EF_external "bhv_book_switch_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_fire_piranha_plant_init,
   Gfun(External (EF_external "bhv_fire_piranha_plant_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_fire_piranha_plant_update,
   Gfun(External (EF_external "bhv_fire_piranha_plant_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_small_piranha_flame_loop,
   Gfun(External (EF_external "bhv_small_piranha_flame_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_fire_spitter_update,
   Gfun(External (EF_external "bhv_fire_spitter_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_fly_guy_flame_loop,
   Gfun(External (EF_external "bhv_fly_guy_flame_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_snufit_loop,
   Gfun(External (EF_external "bhv_snufit_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_snufit_balls_loop,
   Gfun(External (EF_external "bhv_snufit_balls_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_horizontal_grindel_init,
   Gfun(External (EF_external "bhv_horizontal_grindel_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_horizontal_grindel_update,
   Gfun(External (EF_external "bhv_horizontal_grindel_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_eyerok_boss_loop,
   Gfun(External (EF_external "bhv_eyerok_boss_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_eyerok_hand_loop,
   Gfun(External (EF_external "bhv_eyerok_hand_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_klepto_init,
   Gfun(External (EF_external "bhv_klepto_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_klepto_update,
   Gfun(External (EF_external "bhv_klepto_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bird_update,
   Gfun(External (EF_external "bhv_bird_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_racing_penguin_init,
   Gfun(External (EF_external "bhv_racing_penguin_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_racing_penguin_update,
   Gfun(External (EF_external "bhv_racing_penguin_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_penguin_race_finish_line_update,
   Gfun(External (EF_external "bhv_penguin_race_finish_line_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_penguin_race_shortcut_check_update,
   Gfun(External (EF_external "bhv_penguin_race_shortcut_check_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_coffin_spawner_loop,
   Gfun(External (EF_external "bhv_coffin_spawner_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_coffin_loop,
   Gfun(External (EF_external "bhv_coffin_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_clam_loop,
   Gfun(External (EF_external "bhv_clam_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_skeeter_update,
   Gfun(External (EF_external "bhv_skeeter_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_skeeter_wave_update,
   Gfun(External (EF_external "bhv_skeeter_wave_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_swing_platform_init,
   Gfun(External (EF_external "bhv_swing_platform_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_swing_platform_update,
   Gfun(External (EF_external "bhv_swing_platform_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_donut_platform_spawner_update,
   Gfun(External (EF_external "bhv_donut_platform_spawner_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_donut_platform_update,
   Gfun(External (EF_external "bhv_donut_platform_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ddd_pole_init,
   Gfun(External (EF_external "bhv_ddd_pole_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_ddd_pole_update,
   Gfun(External (EF_external "bhv_ddd_pole_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_red_coin_star_marker_init,
   Gfun(External (EF_external "bhv_red_coin_star_marker_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_triplet_butterfly_update,
   Gfun(External (EF_external "bhv_triplet_butterfly_update"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_bubba_loop,
   Gfun(External (EF_external "bhv_bubba_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_intro_lakitu_loop,
   Gfun(External (EF_external "bhv_intro_lakitu_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_intro_peach_loop,
   Gfun(External (EF_external "bhv_intro_peach_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_end_birds_1_loop,
   Gfun(External (EF_external "bhv_end_birds_1_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_end_birds_2_loop,
   Gfun(External (EF_external "bhv_end_birds_2_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_intro_scene_loop,
   Gfun(External (EF_external "bhv_intro_scene_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_dust_smoke_loop,
   Gfun(External (EF_external "bhv_dust_smoke_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_yoshi_loop,
   Gfun(External (EF_external "bhv_yoshi_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_volcano_trap_loop,
   Gfun(External (EF_external "bhv_volcano_trap_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_gShallowWaterSplashDropletParams, Gvar v_gShallowWaterSplashDropletParams) ::
 (_gShallowWaterWaveDropletParams, Gvar v_gShallowWaterWaveDropletParams) ::
 (_bhv_end_peach_loop,
   Gfun(External (EF_external "bhv_end_peach_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_end_toad_loop,
   Gfun(External (EF_external "bhv_end_toad_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_toad_message_loop,
   Gfun(External (EF_external "bhv_toad_message_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_toad_message_init,
   Gfun(External (EF_external "bhv_toad_message_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_unlock_door_star_init,
   Gfun(External (EF_external "bhv_unlock_door_star_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_unlock_door_star_loop,
   Gfun(External (EF_external "bhv_unlock_door_star_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_cur_obj_compute_vel_xz,
   Gfun(External (EF_external "cur_obj_compute_vel_xz"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_cur_obj_update_floor_and_walls,
   Gfun(External (EF_external "cur_obj_update_floor_and_walls"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_cur_obj_move_using_fvel_and_gravity,
   Gfun(External (EF_external "cur_obj_move_using_fvel_and_gravity"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_cur_obj_rotate_face_angle_using_vel,
   Gfun(External (EF_external "cur_obj_rotate_face_angle_using_vel"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_try_do_mario_debug_object_spawn,
   Gfun(External (EF_external "try_do_mario_debug_object_spawn"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_try_print_debug_mario_level_info,
   Gfun(External (EF_external "try_print_debug_mario_level_info"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_beh_yellow_background_menu_init,
   Gfun(External (EF_external "beh_yellow_background_menu_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_beh_yellow_background_menu_loop,
   Gfun(External (EF_external "beh_yellow_background_menu_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_menu_button_init,
   Gfun(External (EF_external "bhv_menu_button_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_menu_button_loop,
   Gfun(External (EF_external "bhv_menu_button_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_menu_button_manager_init,
   Gfun(External (EF_external "bhv_menu_button_manager_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_bhv_menu_button_manager_loop,
   Gfun(External (EF_external "bhv_menu_button_manager_loop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_load_object_collision_model,
   Gfun(External (EF_external "load_object_collision_model"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) :: (_dAmpAnimsList, Gvar v_dAmpAnimsList) ::
 (_blue_coin_switch_seg8_collision_08000E98, Gvar v_blue_coin_switch_seg8_collision_08000E98) ::
 (_bobomb_seg8_anims_0802396C, Gvar v_bobomb_seg8_anims_0802396C) ::
 (_breakable_box_seg8_collision_08012D70, Gvar v_breakable_box_seg8_collision_08012D70) ::
 (_cannon_lid_seg8_collision_08004950, Gvar v_cannon_lid_seg8_collision_08004950) ::
 (_checkerboard_platform_seg8_collision_0800D710, Gvar v_checkerboard_platform_seg8_collision_0800D710) ::
 (_chuckya_seg8_anims_0800C070, Gvar v_chuckya_seg8_anims_0800C070) ::
 (_exclamation_box_outline_seg8_collision_08025F78, Gvar v_exclamation_box_outline_seg8_collision_08025F78) ::
 (_flyguy_seg8_anims_08011A64, Gvar v_flyguy_seg8_anims_08011A64) ::
 (_goomba_seg8_anims_0801DA4C, Gvar v_goomba_seg8_anims_0801DA4C) ::
 (_metal_box_seg8_collision_08024C28, Gvar v_metal_box_seg8_collision_08024C28) ::
 (_purple_switch_seg8_collision_0800C7A8, Gvar v_purple_switch_seg8_collision_0800C7A8) ::
 (_blue_fish_seg3_anims_0301C2B0, Gvar v_blue_fish_seg3_anims_0301C2B0) ::
 (_bowser_key_seg3_anims_list, Gvar v_bowser_key_seg3_anims_list) ::
 (_butterfly_seg3_anims_030056B0, Gvar v_butterfly_seg3_anims_030056B0) ::
 (_door_seg3_anims_030156C0, Gvar v_door_seg3_anims_030156C0) ::
 (_door_seg3_collision_0301CE78, Gvar v_door_seg3_collision_0301CE78) ::
 (_lll_hexagonal_mesh_seg3_collision_0301CECC, Gvar v_lll_hexagonal_mesh_seg3_collision_0301CECC) ::
 (_warp_pipe_seg3_collision_03009AC8, Gvar v_warp_pipe_seg3_collision_03009AC8) ::
 (_wooden_signpost_seg3_collision_0302DD80, Gvar v_wooden_signpost_seg3_collision_0302DD80) ::
 (_heave_ho_seg5_anims_0501534C, Gvar v_heave_ho_seg5_anims_0501534C) ::
 (_hoot_seg5_anims_05005768, Gvar v_hoot_seg5_anims_05005768) ::
 (_thwomp_seg5_collision_0500B7D0, Gvar v_thwomp_seg5_collision_0500B7D0) ::
 (_thwomp_seg5_collision_0500B92C, Gvar v_thwomp_seg5_collision_0500B92C) ::
 (_bully_seg5_anims_0500470C, Gvar v_bully_seg5_anims_0500470C) ::
 (_king_bobomb_seg5_anims_0500FE30, Gvar v_king_bobomb_seg5_anims_0500FE30) ::
 (_clam_shell_seg5_anims_05001744, Gvar v_clam_shell_seg5_anims_05001744) ::
 (_manta_seg5_anims_05008EB4, Gvar v_manta_seg5_anims_05008EB4) ::
 (_sushi_seg5_anims_0500AE54, Gvar v_sushi_seg5_anims_0500AE54) ::
 (_unagi_seg5_anims_05012824, Gvar v_unagi_seg5_anims_05012824) ::
 (_eyerok_seg5_anims_050116E4, Gvar v_eyerok_seg5_anims_050116E4) ::
 (_klepto_seg5_anims_05008CFC, Gvar v_klepto_seg5_anims_05008CFC) ::
 (_monty_mole_seg5_anims_05007248, Gvar v_monty_mole_seg5_anims_05007248) ::
 (_ukiki_seg5_anims_05015784, Gvar v_ukiki_seg5_anims_05015784) ::
 (_penguin_seg5_anims_05008B74, Gvar v_penguin_seg5_anims_05008B74) ::
 (_penguin_seg5_collision_05008B88, Gvar v_penguin_seg5_collision_05008B88) ::
 (_snowman_seg5_anims_0500D118, Gvar v_snowman_seg5_anims_0500D118) ::
 (_spindrift_seg5_anims_05002D68, Gvar v_spindrift_seg5_anims_05002D68) ::
 (_capswitch_collision_050033D0, Gvar v_capswitch_collision_050033D0) ::
 (_capswitch_collision_05003448, Gvar v_capswitch_collision_05003448) ::
 (_springboard_collision_05001A28, Gvar v_springboard_collision_05001A28) ::
 (_bookend_seg5_anims_05002540, Gvar v_bookend_seg5_anims_05002540) ::
 (_chair_seg5_anims_05005784, Gvar v_chair_seg5_anims_05005784) ::
 (_mad_piano_seg5_anims_05009B14, Gvar v_mad_piano_seg5_anims_05009B14) ::
 (_birds_seg5_anims_050009E8, Gvar v_birds_seg5_anims_050009E8) ::
 (_peach_seg5_anims_0501C41C, Gvar v_peach_seg5_anims_0501C41C) ::
 (_yoshi_seg5_anims_05024100, Gvar v_yoshi_seg5_anims_05024100) ::
 (_lakitu_enemy_seg5_anims_050144D4, Gvar v_lakitu_enemy_seg5_anims_050144D4) ::
 (_spiny_seg5_anims_05016EAC, Gvar v_spiny_seg5_anims_05016EAC) ::
 (_wiggler_seg5_anims_0500C874, Gvar v_wiggler_seg5_anims_0500C874) ::
 (_wiggler_seg5_anims_0500EC8C, Gvar v_wiggler_seg5_anims_0500EC8C) ::
 (_bowser_seg6_anims_06057690, Gvar v_bowser_seg6_anims_06057690) ::
 (_bub_seg6_anims_06012354, Gvar v_bub_seg6_anims_06012354) ::
 (_seaweed_seg6_anims_0600A4D4, Gvar v_seaweed_seg6_anims_0600A4D4) ::
 (_skeeter_seg6_anims_06007DE0, Gvar v_skeeter_seg6_anims_06007DE0) ::
 (_water_ring_seg6_anims_06013F7C, Gvar v_water_ring_seg6_anims_06013F7C) ::
 (_chain_chomp_seg6_anims_06025178, Gvar v_chain_chomp_seg6_anims_06025178) ::
 (_koopa_seg6_anims_06011364, Gvar v_koopa_seg6_anims_06011364) ::
 (_koopa_flag_seg6_anims_06001028, Gvar v_koopa_flag_seg6_anims_06001028) ::
 (_piranha_plant_seg6_anims_0601C31C, Gvar v_piranha_plant_seg6_anims_0601C31C) ::
 (_poundable_pole_collision_06002490, Gvar v_poundable_pole_collision_06002490) ::
 (_whomp_seg6_anims_06020A04, Gvar v_whomp_seg6_anims_06020A04) ::
 (_whomp_seg6_collision_06020A0C, Gvar v_whomp_seg6_collision_06020A0C) ::
 (_lakitu_seg6_anims_060058F8, Gvar v_lakitu_seg6_anims_060058F8) ::
 (_mips_seg6_anims_06015634, Gvar v_mips_seg6_anims_06015634) ::
 (_toad_seg6_anims_0600FB58, Gvar v_toad_seg6_anims_0600FB58) ::
 (_chilly_chief_seg6_anims_06003994, Gvar v_chilly_chief_seg6_anims_06003994) ::
 (_moneybag_seg6_anims_06005E5C, Gvar v_moneybag_seg6_anims_06005E5C) ::
 (_dorrie_seg6_anims_0600F638, Gvar v_dorrie_seg6_anims_0600F638) ::
 (_dorrie_seg6_collision_0600F644, Gvar v_dorrie_seg6_collision_0600F644) ::
 (_scuttlebug_seg6_anims_06015064, Gvar v_scuttlebug_seg6_anims_06015064) ::
 (_swoop_seg6_anims_060070D0, Gvar v_swoop_seg6_anims_060070D0) ::
 (_bbh_seg7_collision_staircase_step, Gvar v_bbh_seg7_collision_staircase_step) ::
 (_bbh_seg7_collision_tilt_floor_platform, Gvar v_bbh_seg7_collision_tilt_floor_platform) ::
 (_bbh_seg7_collision_haunted_bookshelf, Gvar v_bbh_seg7_collision_haunted_bookshelf) ::
 (_bbh_seg7_collision_mesh_elevator, Gvar v_bbh_seg7_collision_mesh_elevator) ::
 (_bbh_seg7_collision_merry_go_round, Gvar v_bbh_seg7_collision_merry_go_round) ::
 (_bbh_seg7_collision_coffin, Gvar v_bbh_seg7_collision_coffin) ::
 (_inside_castle_seg7_collision_floor_trap, Gvar v_inside_castle_seg7_collision_floor_trap) ::
 (_inside_castle_seg7_collision_star_door, Gvar v_inside_castle_seg7_collision_star_door) ::
 (_inside_castle_seg7_collision_water_level_pillar, Gvar v_inside_castle_seg7_collision_water_level_pillar) ::
 (_hmc_seg7_collision_elevator, Gvar v_hmc_seg7_collision_elevator) ::
 (_hmc_seg7_collision_controllable_platform, Gvar v_hmc_seg7_collision_controllable_platform) ::
 (_hmc_seg7_collision_controllable_platform_sub, Gvar v_hmc_seg7_collision_controllable_platform_sub) ::
 (_ssl_seg7_collision_pyramid_top, Gvar v_ssl_seg7_collision_pyramid_top) ::
 (_ssl_seg7_collision_tox_box, Gvar v_ssl_seg7_collision_tox_box) ::
 (_ssl_seg7_collision_grindel, Gvar v_ssl_seg7_collision_grindel) ::
 (_ssl_seg7_collision_spindel, Gvar v_ssl_seg7_collision_spindel) ::
 (_ssl_seg7_collision_0702808C, Gvar v_ssl_seg7_collision_0702808C) ::
 (_ssl_seg7_collision_pyramid_elevator, Gvar v_ssl_seg7_collision_pyramid_elevator) ::
 (_bob_seg7_collision_chain_chomp_gate, Gvar v_bob_seg7_collision_chain_chomp_gate) ::
 (_sl_seg7_collision_sliding_snow_mound, Gvar v_sl_seg7_collision_sliding_snow_mound) ::
 (_sl_seg7_collision_pound_explodes, Gvar v_sl_seg7_collision_pound_explodes) ::
 (_wdw_seg7_collision_square_floating_platform, Gvar v_wdw_seg7_collision_square_floating_platform) ::
 (_wdw_seg7_collision_arrow_lift, Gvar v_wdw_seg7_collision_arrow_lift) ::
 (_wdw_seg7_collision_express_elevator_platform, Gvar v_wdw_seg7_collision_express_elevator_platform) ::
 (_wdw_seg7_collision_rect_floating_platform, Gvar v_wdw_seg7_collision_rect_floating_platform) ::
 (_jrb_seg7_collision_rock_solid, Gvar v_jrb_seg7_collision_rock_solid) ::
 (_jrb_seg7_collision_floating_platform, Gvar v_jrb_seg7_collision_floating_platform) ::
 (_jrb_seg7_collision_floating_box, Gvar v_jrb_seg7_collision_floating_box) ::
 (_jrb_seg7_collision_in_sunken_ship_3, Gvar v_jrb_seg7_collision_in_sunken_ship_3) ::
 (_jrb_seg7_collision_in_sunken_ship, Gvar v_jrb_seg7_collision_in_sunken_ship) ::
 (_jrb_seg7_collision_in_sunken_ship_2, Gvar v_jrb_seg7_collision_in_sunken_ship_2) ::
 (_jrb_seg7_collision_pillar_base, Gvar v_jrb_seg7_collision_pillar_base) ::
 (_thi_seg7_collision_top_trap, Gvar v_thi_seg7_collision_top_trap) ::
 (_ttc_seg7_collision_clock_pendulum, Gvar v_ttc_seg7_collision_clock_pendulum) ::
 (_ttc_seg7_collision_sliding_surface, Gvar v_ttc_seg7_collision_sliding_surface) ::
 (_ttc_seg7_collision_clock_platform, Gvar v_ttc_seg7_collision_clock_platform) ::
 (_ttc_seg7_collision_clock_main_rotation, Gvar v_ttc_seg7_collision_clock_main_rotation) ::
 (_ttc_seg7_collision_rotating_clock_platform2, Gvar v_ttc_seg7_collision_rotating_clock_platform2) ::
 (_rr_seg7_collision_pendulum, Gvar v_rr_seg7_collision_pendulum) ::
 (_rr_seg7_collision_rotating_platform_with_fire, Gvar v_rr_seg7_collision_rotating_platform_with_fire) ::
 (_rr_seg7_collision_elevator_platform, Gvar v_rr_seg7_collision_elevator_platform) ::
 (_rr_seg7_collision_donut_platform, Gvar v_rr_seg7_collision_donut_platform) ::
 (_castle_grounds_seg7_anims_flags, Gvar v_castle_grounds_seg7_anims_flags) ::
 (_castle_grounds_seg7_collision_moat_grills, Gvar v_castle_grounds_seg7_collision_moat_grills) ::
 (_castle_grounds_seg7_collision_cannon_grill, Gvar v_castle_grounds_seg7_collision_cannon_grill) ::
 (_bitdw_seg7_collision_moving_pyramid, Gvar v_bitdw_seg7_collision_moving_pyramid) ::
 (_lll_seg7_collision_octagonal_moving_platform, Gvar v_lll_seg7_collision_octagonal_moving_platform) ::
 (_lll_seg7_collision_drawbridge, Gvar v_lll_seg7_collision_drawbridge) ::
 (_lll_seg7_collision_rotating_fire_bars, Gvar v_lll_seg7_collision_rotating_fire_bars) ::
 (_lll_seg7_collision_wood_piece, Gvar v_lll_seg7_collision_wood_piece) ::
 (_lll_seg7_collision_rotating_platform, Gvar v_lll_seg7_collision_rotating_platform) ::
 (_lll_seg7_collision_slow_tilting_platform, Gvar v_lll_seg7_collision_slow_tilting_platform) ::
 (_lll_seg7_collision_sinking_pyramids, Gvar v_lll_seg7_collision_sinking_pyramids) ::
 (_lll_seg7_collision_inverted_pyramid, Gvar v_lll_seg7_collision_inverted_pyramid) ::
 (_lll_seg7_collision_puzzle_piece, Gvar v_lll_seg7_collision_puzzle_piece) ::
 (_lll_seg7_collision_floating_block, Gvar v_lll_seg7_collision_floating_block) ::
 (_lll_seg7_collision_pitoune, Gvar v_lll_seg7_collision_pitoune) ::
 (_lll_seg7_collision_hexagonal_platform, Gvar v_lll_seg7_collision_hexagonal_platform) ::
 (_lll_seg7_collision_falling_wall, Gvar v_lll_seg7_collision_falling_wall) ::
 (_bitfs_seg7_collision_sinking_cage_platform, Gvar v_bitfs_seg7_collision_sinking_cage_platform) ::
 (_bitfs_seg7_collision_inverted_pyramid, Gvar v_bitfs_seg7_collision_inverted_pyramid) ::
 (_bitfs_seg7_collision_squishable_platform, Gvar v_bitfs_seg7_collision_squishable_platform) ::
 (_bitfs_seg7_collision_sinking_platform, Gvar v_bitfs_seg7_collision_sinking_platform) ::
 (_ddd_seg7_collision_submarine, Gvar v_ddd_seg7_collision_submarine) ::
 (_ddd_seg7_collision_bowser_sub_door, Gvar v_ddd_seg7_collision_bowser_sub_door) ::
 (_wf_seg7_collision_small_bomp, Gvar v_wf_seg7_collision_small_bomp) ::
 (_wf_seg7_collision_large_bomp, Gvar v_wf_seg7_collision_large_bomp) ::
 (_wf_seg7_collision_clocklike_rotation, Gvar v_wf_seg7_collision_clocklike_rotation) ::
 (_wf_seg7_collision_sliding_brick_platform, Gvar v_wf_seg7_collision_sliding_brick_platform) ::
 (_wf_seg7_collision_platform, Gvar v_wf_seg7_collision_platform) ::
 (_wf_seg7_collision_breakable_wall, Gvar v_wf_seg7_collision_breakable_wall) ::
 (_wf_seg7_collision_breakable_wall_2, Gvar v_wf_seg7_collision_breakable_wall_2) ::
 (_wf_seg7_collision_kickable_board, Gvar v_wf_seg7_collision_kickable_board) ::
 (_wf_seg7_collision_tower_door, Gvar v_wf_seg7_collision_tower_door) ::
 (_wf_seg7_collision_tower, Gvar v_wf_seg7_collision_tower) ::
 (_wf_seg7_collision_bullet_bill_cannon, Gvar v_wf_seg7_collision_bullet_bill_cannon) ::
 (_bowser_2_seg7_collision_tilting_platform, Gvar v_bowser_2_seg7_collision_tilting_platform) ::
 (_ttm_seg7_collision_pitoune_2, Gvar v_ttm_seg7_collision_pitoune_2) ::
 (_ttm_seg7_collision_ukiki_cage, Gvar v_ttm_seg7_collision_ukiki_cage) ::
 (_ttm_seg7_collision_podium_warp, Gvar v_ttm_seg7_collision_podium_warp) ::
 (_bhvStarDoor, Gvar v_bhvStarDoor) :: (_bhvMrI, Gvar v_bhvMrI) ::
 (_bhvMrIBody, Gvar v_bhvMrIBody) ::
 (_bhvMrIParticle, Gvar v_bhvMrIParticle) ::
 (_bhvPurpleParticle, Gvar v_bhvPurpleParticle) ::
 (_bhvGiantPole, Gvar v_bhvGiantPole) ::
 (_bhvPoleGrabbing, Gvar v_bhvPoleGrabbing) ::
 (_bhvTHIHugeIslandTop, Gvar v_bhvTHIHugeIslandTop) ::
 (_bhvTHITinyIslandTop, Gvar v_bhvTHITinyIslandTop) ::
 (_bhvCapSwitchBase, Gvar v_bhvCapSwitchBase) ::
 (_bhvCapSwitch, Gvar v_bhvCapSwitch) ::
 (_bhvKingBobomb, Gvar v_bhvKingBobomb) ::
 (_bhvBobombAnchorMario, Gvar v_bhvBobombAnchorMario) ::
 (_bhvBetaChestBottom, Gvar v_bhvBetaChestBottom) ::
 (_bhvBetaChestLid, Gvar v_bhvBetaChestLid) ::
 (_bhvBubbleParticleSpawner, Gvar v_bhvBubbleParticleSpawner) ::
 (_bhvBubbleMaybe, Gvar v_bhvBubbleMaybe) ::
 (_bhvSmallWaterWave, Gvar v_bhvSmallWaterWave) ::
 (_bhvSmallWaterWave398, Gvar v_bhvSmallWaterWave398) ::
 (_bhvWaterAirBubble, Gvar v_bhvWaterAirBubble) ::
 (_bhvSmallParticle, Gvar v_bhvSmallParticle) ::
 (_bhvPlungeBubble, Gvar v_bhvPlungeBubble) ::
 (_bhvSmallParticleSnow, Gvar v_bhvSmallParticleSnow) ::
 (_bhvSmallParticleBubbles, Gvar v_bhvSmallParticleBubbles) ::
 (_bhvFishGroup, Gvar v_bhvFishGroup) :: (_bhvCannon, Gvar v_bhvCannon) ::
 (_bhvCannonBarrel, Gvar v_bhvCannonBarrel) ::
 (_bhvCannonBaseUnused, Gvar v_bhvCannonBaseUnused) ::
 (_bhvChuckya, Gvar v_bhvChuckya) ::
 (_bhvChuckyaAnchorMario, Gvar v_bhvChuckyaAnchorMario) ::
 (_bhvUnused05A8, Gvar v_bhvUnused05A8) ::
 (_bhvRotatingPlatform, Gvar v_bhvRotatingPlatform) ::
 (_bhvTower, Gvar v_bhvTower) ::
 (_bhvBulletBillCannon, Gvar v_bhvBulletBillCannon) ::
 (_bhvWFBreakableWallRight, Gvar v_bhvWFBreakableWallRight) ::
 (_bhvWFBreakableWallLeft, Gvar v_bhvWFBreakableWallLeft) ::
 (_bhvKickableBoard, Gvar v_bhvKickableBoard) ::
 (_bhvTowerDoor, Gvar v_bhvTowerDoor) ::
 (_bhvRotatingCounterClockwise, Gvar v_bhvRotatingCounterClockwise) ::
 (_bhvWFRotatingWoodenPlatform, Gvar v_bhvWFRotatingWoodenPlatform) ::
 (_bhvKoopaShellUnderwater, Gvar v_bhvKoopaShellUnderwater) ::
 (_bhvExitPodiumWarp, Gvar v_bhvExitPodiumWarp) ::
 (_bhvFadingWarp, Gvar v_bhvFadingWarp) :: (_bhvWarp, Gvar v_bhvWarp) ::
 (_bhvWarpPipe, Gvar v_bhvWarpPipe) ::
 (_bhvWhitePuffExplosion, Gvar v_bhvWhitePuffExplosion) ::
 (_bhvSpawnedStar, Gvar v_bhvSpawnedStar) ::
 (_bhvSpawnedStarNoLevelExit, Gvar v_bhvSpawnedStarNoLevelExit) ::
 (_bhvSpawnedBlueCoin, Gvar v_bhvSpawnedBlueCoin) ::
 (_bhvCoinInsideBoo, Gvar v_bhvCoinInsideBoo) ::
 (_bhvCoinFormationSpawn, Gvar v_bhvCoinFormationSpawn) ::
 (_bhvCoinFormation, Gvar v_bhvCoinFormation) ::
 (_bhvOneCoin, Gvar v_bhvOneCoin) ::
 (_bhvYellowCoin, Gvar v_bhvYellowCoin) ::
 (_bhvTemporaryYellowCoin, Gvar v_bhvTemporaryYellowCoin) ::
 (_bhvThreeCoinsSpawn, Gvar v_bhvThreeCoinsSpawn) ::
 (_bhvTenCoinsSpawn, Gvar v_bhvTenCoinsSpawn) ::
 (_bhvSingleCoinGetsSpawned, Gvar v_bhvSingleCoinGetsSpawned) ::
 (_bhvCoinSparkles, Gvar v_bhvCoinSparkles) ::
 (_bhvGoldenCoinSparkles, Gvar v_bhvGoldenCoinSparkles) ::
 (_bhvWallTinyStarParticle, Gvar v_bhvWallTinyStarParticle) ::
 (_bhvVertStarParticleSpawner, Gvar v_bhvVertStarParticleSpawner) ::
 (_bhvPoundTinyStarParticle, Gvar v_bhvPoundTinyStarParticle) ::
 (_bhvHorStarParticleSpawner, Gvar v_bhvHorStarParticleSpawner) ::
 (_bhvPunchTinyTriangle, Gvar v_bhvPunchTinyTriangle) ::
 (_bhvTriangleParticleSpawner, Gvar v_bhvTriangleParticleSpawner) ::
 (_bhvDoorWarp, Gvar v_bhvDoorWarp) :: (_bhvDoor, Gvar v_bhvDoor) ::
 (_bhvGrindel, Gvar v_bhvGrindel) :: (_bhvThwomp, Gvar v_bhvThwomp) ::
 (_bhvThwomp2, Gvar v_bhvThwomp2) ::
 (_bhvTumblingBridgePlatform, Gvar v_bhvTumblingBridgePlatform) ::
 (_bhvTumblingBridge, Gvar v_bhvTumblingBridge) ::
 (_bhvBBHTumblingBridge, Gvar v_bhvBBHTumblingBridge) ::
 (_bhvLLLTumblingBridge, Gvar v_bhvLLLTumblingBridge) ::
 (_bhvFlame, Gvar v_bhvFlame) ::
 (_bhvAnotherElavator, Gvar v_bhvAnotherElavator) ::
 (_bhvRRElevatorPlatform, Gvar v_bhvRRElevatorPlatform) ::
 (_bhvHMCElevatorPlatform, Gvar v_bhvHMCElevatorPlatform) ::
 (_bhvWaterMist, Gvar v_bhvWaterMist) ::
 (_bhvBreathParticleSpawner, Gvar v_bhvBreathParticleSpawner) ::
 (_bhvBreakBoxTriangle, Gvar v_bhvBreakBoxTriangle) ::
 (_bhvWaterMist2, Gvar v_bhvWaterMist2) ::
 (_bhvUnused0DFC, Gvar v_bhvUnused0DFC) ::
 (_bhvMistCircParticleSpawner, Gvar v_bhvMistCircParticleSpawner) ::
 (_bhvDirtParticleSpawner, Gvar v_bhvDirtParticleSpawner) ::
 (_bhvSnowParticleSpawner, Gvar v_bhvSnowParticleSpawner) ::
 (_bhvWind, Gvar v_bhvWind) :: (_bhvEndToad, Gvar v_bhvEndToad) ::
 (_bhvEndPeach, Gvar v_bhvEndPeach) ::
 (_bhvUnusedParticleSpawn, Gvar v_bhvUnusedParticleSpawn) ::
 (_bhvUkiki, Gvar v_bhvUkiki) ::
 (_bhvUkikiCageChild, Gvar v_bhvUkikiCageChild) ::
 (_bhvUkikiCageStar, Gvar v_bhvUkikiCageStar) ::
 (_bhvUkikiCage, Gvar v_bhvUkikiCage) ::
 (_bhvBitFSSinkingPlatforms, Gvar v_bhvBitFSSinkingPlatforms) ::
 (_bhvBitFSSinkingCagePlatform, Gvar v_bhvBitFSSinkingCagePlatform) ::
 (_bhvDDDMovingPole, Gvar v_bhvDDDMovingPole) ::
 (_bhvBitFSTiltingInvertedPyramid, Gvar v_bhvBitFSTiltingInvertedPyramid) ::
 (_bhvSquishablePlatform, Gvar v_bhvSquishablePlatform) ::
 (_bhvCutOutObject, Gvar v_bhvCutOutObject) ::
 (_bhvBetaMovingFlamesSpawn, Gvar v_bhvBetaMovingFlamesSpawn) ::
 (_bhvBetaMovingFlames, Gvar v_bhvBetaMovingFlames) ::
 (_bhvRRRotatingBridgePlatform, Gvar v_bhvRRRotatingBridgePlatform) ::
 (_bhvFlamethrower, Gvar v_bhvFlamethrower) ::
 (_bhvFlamethrowerFlame, Gvar v_bhvFlamethrowerFlame) ::
 (_bhvBouncingFireball, Gvar v_bhvBouncingFireball) ::
 (_bhvBouncingFireballFlame, Gvar v_bhvBouncingFireballFlame) ::
 (_bhvBowserShockWave, Gvar v_bhvBowserShockWave) ::
 (_bhvFireParticleSpawner, Gvar v_bhvFireParticleSpawner) ::
 (_bhvBlackSmokeMario, Gvar v_bhvBlackSmokeMario) ::
 (_bhvBlackSmokeBowser, Gvar v_bhvBlackSmokeBowser) ::
 (_bhvBlackSmokeUpward, Gvar v_bhvBlackSmokeUpward) ::
 (_bhvBetaFishSplashSpawner, Gvar v_bhvBetaFishSplashSpawner) ::
 (_bhvSpindrift, Gvar v_bhvSpindrift) ::
 (_bhvTowerPlatformGroup, Gvar v_bhvTowerPlatformGroup) ::
 (_bhvWFSlidingTowerPlatform, Gvar v_bhvWFSlidingTowerPlatform) ::
 (_bhvWFElevatorTowerPlatform, Gvar v_bhvWFElevatorTowerPlatform) ::
 (_bhvWFSolidTowerPlatform, Gvar v_bhvWFSolidTowerPlatform) ::
 (_bhvLeafParticleSpawner, Gvar v_bhvLeafParticleSpawner) ::
 (_bhvTreeSnow, Gvar v_bhvTreeSnow) :: (_bhvTreeLeaf, Gvar v_bhvTreeLeaf) ::
 (_bhvAnotherTiltingPlatform, Gvar v_bhvAnotherTiltingPlatform) ::
 (_bhvSquarishPathMoving, Gvar v_bhvSquarishPathMoving) ::
 (_bhvPiranhaPlantBubble, Gvar v_bhvPiranhaPlantBubble) ::
 (_bhvPiranhaPlantWakingBubbles, Gvar v_bhvPiranhaPlantWakingBubbles) ::
 (_bhvFloorSwitchAnimatesObject, Gvar v_bhvFloorSwitchAnimatesObject) ::
 (_bhvFloorSwitchGrills, Gvar v_bhvFloorSwitchGrills) ::
 (_bhvFloorSwitchHardcodedModel, Gvar v_bhvFloorSwitchHardcodedModel) ::
 (_bhvFloorSwitchHiddenObjects, Gvar v_bhvFloorSwitchHiddenObjects) ::
 (_bhvHiddenObject, Gvar v_bhvHiddenObject) ::
 (_bhvBreakableBox, Gvar v_bhvBreakableBox) ::
 (_bhvPushableMetalBox, Gvar v_bhvPushableMetalBox) ::
 (_bhvHeaveHo, Gvar v_bhvHeaveHo) ::
 (_bhvHeaveHoThrowMario, Gvar v_bhvHeaveHoThrowMario) ::
 (_bhvCCMTouchedStarSpawn, Gvar v_bhvCCMTouchedStarSpawn) ::
 (_bhvUnusedPoundablePlatform, Gvar v_bhvUnusedPoundablePlatform) ::
 (_bhvBetaTrampolineTop, Gvar v_bhvBetaTrampolineTop) ::
 (_bhvBetaTrampolineSpring, Gvar v_bhvBetaTrampolineSpring) ::
 (_bhvJumpingBox, Gvar v_bhvJumpingBox) ::
 (_bhvBooCage, Gvar v_bhvBooCage) :: (_bhvStub, Gvar v_bhvStub) ::
 (_bhvIgloo, Gvar v_bhvIgloo) :: (_bhvBowserKey, Gvar v_bhvBowserKey) ::
 (_bhvGrandStar, Gvar v_bhvGrandStar) ::
 (_bhvBetaBooKey, Gvar v_bhvBetaBooKey) ::
 (_bhvAlphaBooKey, Gvar v_bhvAlphaBooKey) ::
 (_bhvBulletBill, Gvar v_bhvBulletBill) ::
 (_bhvWhitePuffSmoke, Gvar v_bhvWhitePuffSmoke) ::
 (_bhvUnused1820, Gvar v_bhvUnused1820) ::
 (_bhvBowserTailAnchor, Gvar v_bhvBowserTailAnchor) ::
 (_bhvBowser, Gvar v_bhvBowser) ::
 (_bhvBowserBodyAnchor, Gvar v_bhvBowserBodyAnchor) ::
 (_bhvBowserFlameSpawn, Gvar v_bhvBowserFlameSpawn) ::
 (_bhvTiltingBowserLavaPlatform, Gvar v_bhvTiltingBowserLavaPlatform) ::
 (_bhvFallingBowserPlatform, Gvar v_bhvFallingBowserPlatform) ::
 (_bhvBlueBowserFlame, Gvar v_bhvBlueBowserFlame) ::
 (_bhvFlameFloatingLanding, Gvar v_bhvFlameFloatingLanding) ::
 (_bhvBlueFlamesGroup, Gvar v_bhvBlueFlamesGroup) ::
 (_bhvFlameBouncing, Gvar v_bhvFlameBouncing) ::
 (_bhvFlameMovingForwardGrowing, Gvar v_bhvFlameMovingForwardGrowing) ::
 (_bhvFlameBowser, Gvar v_bhvFlameBowser) ::
 (_bhvFlameLargeBurningOut, Gvar v_bhvFlameLargeBurningOut) ::
 (_bhvBlueFish, Gvar v_bhvBlueFish) ::
 (_bhvTankFishGroup, Gvar v_bhvTankFishGroup) ::
 (_bhvCheckerboardElevatorGroup, Gvar v_bhvCheckerboardElevatorGroup) ::
 (_bhvCheckerboardPlatformSub, Gvar v_bhvCheckerboardPlatformSub) ::
 (_bhvBowserKeyUnlockDoor, Gvar v_bhvBowserKeyUnlockDoor) ::
 (_bhvBowserKeyCourseExit, Gvar v_bhvBowserKeyCourseExit) ::
 (_bhvInvisibleObjectsUnderBridge, Gvar v_bhvInvisibleObjectsUnderBridge) ::
 (_bhvWaterLevelPillar, Gvar v_bhvWaterLevelPillar) ::
 (_bhvDDDWarp, Gvar v_bhvDDDWarp) ::
 (_bhvMoatGrills, Gvar v_bhvMoatGrills) ::
 (_bhvClockMinuteHand, Gvar v_bhvClockMinuteHand) ::
 (_bhvClockHourHand, Gvar v_bhvClockHourHand) ::
 (_bhvMacroUkiki, Gvar v_bhvMacroUkiki) ::
 (_bhvStub1D0C, Gvar v_bhvStub1D0C) ::
 (_bhvLLLRotatingHexagonalPlatform, Gvar v_bhvLLLRotatingHexagonalPlatform) ::
 (_bhvLLLSinkingRockBlock, Gvar v_bhvLLLSinkingRockBlock) ::
 (_bhvStub1D70, Gvar v_bhvStub1D70) ::
 (_bhvLLLMovingOctagonalMeshPlatform, Gvar v_bhvLLLMovingOctagonalMeshPlatform) ::
 (_bhvSnowBall, Gvar v_bhvSnowBall) ::
 (_bhvLLLRotatingBlockWithFireBars, Gvar v_bhvLLLRotatingBlockWithFireBars) ::
 (_bhvLLLRotatingHexFlame, Gvar v_bhvLLLRotatingHexFlame) ::
 (_bhvLLLWoodPiece, Gvar v_bhvLLLWoodPiece) ::
 (_bhvLLLFloatingWoodBridge, Gvar v_bhvLLLFloatingWoodBridge) ::
 (_bhvVolcanoFlames, Gvar v_bhvVolcanoFlames) ::
 (_bhvLLLRotatingHexagonalRing, Gvar v_bhvLLLRotatingHexagonalRing) ::
 (_bhvLLLSinkingRectangularPlatform, Gvar v_bhvLLLSinkingRectangularPlatform) ::
 (_bhvLLLSinkingSquarePlatforms, Gvar v_bhvLLLSinkingSquarePlatforms) ::
 (_bhvLLLTiltingInvertedPyramid, Gvar v_bhvLLLTiltingInvertedPyramid) ::
 (_bhvUnused1F30, Gvar v_bhvUnused1F30) ::
 (_bhvKoopaShell, Gvar v_bhvKoopaShell) ::
 (_bhvKoopaShellFlame, Gvar v_bhvKoopaShellFlame) ::
 (_bhvToxBox, Gvar v_bhvToxBox) ::
 (_bhvPiranhaPlant, Gvar v_bhvPiranhaPlant) ::
 (_bhvLLLHexagonalMesh, Gvar v_bhvLLLHexagonalMesh) ::
 (_bhvLLLBowserPuzzlePiece, Gvar v_bhvLLLBowserPuzzlePiece) ::
 (_bhvLLLBowserPuzzle, Gvar v_bhvLLLBowserPuzzle) ::
 (_bhvTuxiesMother, Gvar v_bhvTuxiesMother) ::
 (_bhvPenguinBaby, Gvar v_bhvPenguinBaby) ::
 (_bhvUnused20E0, Gvar v_bhvUnused20E0) ::
 (_bhvSmallPenguin, Gvar v_bhvSmallPenguin) ::
 (_bhvManyBlueFishSpawner, Gvar v_bhvManyBlueFishSpawner) ::
 (_bhvFewBlueFishSpawner, Gvar v_bhvFewBlueFishSpawner) ::
 (_bhvFishSpawner, Gvar v_bhvFishSpawner) :: (_bhvFish, Gvar v_bhvFish) ::
 (_bhvWDWExpressElevator, Gvar v_bhvWDWExpressElevator) ::
 (_bhvWDWExpressElevatorPlatform, Gvar v_bhvWDWExpressElevatorPlatform) ::
 (_bhvChirpChirp, Gvar v_bhvChirpChirp) ::
 (_bhvChirpChirpUnused, Gvar v_bhvChirpChirpUnused) ::
 (_bhvBub, Gvar v_bhvBub) ::
 (_bhvExclamationBox, Gvar v_bhvExclamationBox) ::
 (_bhvRotatingExclamationMark, Gvar v_bhvRotatingExclamationMark) ::
 (_bhvSoundSpawner, Gvar v_bhvSoundSpawner) ::
 (_bhvRockSolid, Gvar v_bhvRockSolid) ::
 (_bhvBowserSubDoor, Gvar v_bhvBowserSubDoor) ::
 (_bhvBowsersSub, Gvar v_bhvBowsersSub) ::
 (_bhvSushiShark, Gvar v_bhvSushiShark) ::
 (_bhvSushiSharkCollisionChild, Gvar v_bhvSushiSharkCollisionChild) ::
 (_bhvJRBSlidingBox, Gvar v_bhvJRBSlidingBox) ::
 (_bhvShipPart3, Gvar v_bhvShipPart3) ::
 (_bhvInSunkenShip3, Gvar v_bhvInSunkenShip3) ::
 (_bhvSunkenShipPart, Gvar v_bhvSunkenShipPart) ::
 (_bhvSunkenShipSetRotation, Gvar v_bhvSunkenShipSetRotation) ::
 (_bhvSunkenShipPart2, Gvar v_bhvSunkenShipPart2) ::
 (_bhvInSunkenShip, Gvar v_bhvInSunkenShip) ::
 (_bhvInSunkenShip2, Gvar v_bhvInSunkenShip2) ::
 (_bhvMistParticleSpawner, Gvar v_bhvMistParticleSpawner) ::
 (_bhvWhitePuff1, Gvar v_bhvWhitePuff1) ::
 (_bhvWhitePuff2, Gvar v_bhvWhitePuff2) ::
 (_bhvWhitePuffSmoke2, Gvar v_bhvWhitePuffSmoke2) ::
 (_bhvPurpleSwitchHiddenBoxes, Gvar v_bhvPurpleSwitchHiddenBoxes) ::
 (_bhvBlueCoinSwitch, Gvar v_bhvBlueCoinSwitch) ::
 (_bhvHiddenBlueCoin, Gvar v_bhvHiddenBlueCoin) ::
 (_bhvOpenableCageDoor, Gvar v_bhvOpenableCageDoor) ::
 (_bhvOpenableGrill, Gvar v_bhvOpenableGrill) ::
 (_bhvWaterLevelDiamond, Gvar v_bhvWaterLevelDiamond) ::
 (_bhvInitializeChangingWaterLevel, Gvar v_bhvInitializeChangingWaterLevel) ::
 (_bhvTweesterSandParticle, Gvar v_bhvTweesterSandParticle) ::
 (_bhvTweester, Gvar v_bhvTweester) ::
 (_bhvMerryGoRoundBooManager, Gvar v_bhvMerryGoRoundBooManager) ::
 (_bhvAnimatedTexture, Gvar v_bhvAnimatedTexture) ::
 (_bhvBooInCastle, Gvar v_bhvBooInCastle) ::
 (_bhvBooWithCage, Gvar v_bhvBooWithCage) ::
 (_bhvBalconyBigBoo, Gvar v_bhvBalconyBigBoo) ::
 (_bhvMerryGoRoundBigBoo, Gvar v_bhvMerryGoRoundBigBoo) ::
 (_bhvGhostHuntBigBoo, Gvar v_bhvGhostHuntBigBoo) ::
 (_bhvCourtyardBooTriplet, Gvar v_bhvCourtyardBooTriplet) ::
 (_bhvBoo, Gvar v_bhvBoo) ::
 (_bhvMerryGoRoundBoo, Gvar v_bhvMerryGoRoundBoo) ::
 (_bhvGhostHuntBoo, Gvar v_bhvGhostHuntBoo) ::
 (_bhvHiddenStaircaseStep, Gvar v_bhvHiddenStaircaseStep) ::
 (_bhvBooStaircase, Gvar v_bhvBooStaircase) ::
 (_bhvBBHTiltingTrapPlatform, Gvar v_bhvBBHTiltingTrapPlatform) ::
 (_bhvHauntedBookshelf, Gvar v_bhvHauntedBookshelf) ::
 (_bhvMeshElevator, Gvar v_bhvMeshElevator) ::
 (_bhvMerryGoRound, Gvar v_bhvMerryGoRound) ::
 (_bhvPlaysMusicTrackWhenTouched, Gvar v_bhvPlaysMusicTrackWhenTouched) ::
 (_bhvInsideCannon, Gvar v_bhvInsideCannon) ::
 (_bhvBetaBowserAnchor, Gvar v_bhvBetaBowserAnchor) ::
 (_bhvStaticCheckeredPlatform, Gvar v_bhvStaticCheckeredPlatform) ::
 (_bhvUnused2A10, Gvar v_bhvUnused2A10) ::
 (_bhvUnusedFakeStar, Gvar v_bhvUnusedFakeStar) ::
 (_bhvStaticObject, Gvar v_bhvStaticObject) ::
 (_bhvUnused2A54, Gvar v_bhvUnused2A54) ::
 (_bhvCastleFloorTrap, Gvar v_bhvCastleFloorTrap) ::
 (_bhvFloorTrapInCastle, Gvar v_bhvFloorTrapInCastle) ::
 (_bhvTree, Gvar v_bhvTree) :: (_bhvSparkle, Gvar v_bhvSparkle) ::
 (_bhvSparkleSpawn, Gvar v_bhvSparkleSpawn) ::
 (_bhvSparkleParticleSpawner, Gvar v_bhvSparkleParticleSpawner) ::
 (_bhvScuttlebug, Gvar v_bhvScuttlebug) ::
 (_bhvScuttlebugSpawn, Gvar v_bhvScuttlebugSpawn) ::
 (_bhvWhompKingBoss, Gvar v_bhvWhompKingBoss) ::
 (_bhvSmallWhomp, Gvar v_bhvSmallWhomp) ::
 (_bhvWaterSplash, Gvar v_bhvWaterSplash) ::
 (_bhvWaterDroplet, Gvar v_bhvWaterDroplet) ::
 (_bhvWaterDropletSplash, Gvar v_bhvWaterDropletSplash) ::
 (_bhvBubbleSplash, Gvar v_bhvBubbleSplash) ::
 (_bhvIdleWaterWave, Gvar v_bhvIdleWaterWave) ::
 (_bhvObjectWaterSplash, Gvar v_bhvObjectWaterSplash) ::
 (_bhvShallowWaterWave, Gvar v_bhvShallowWaterWave) ::
 (_bhvShallowWaterSplash, Gvar v_bhvShallowWaterSplash) ::
 (_bhvObjectWaveTrail, Gvar v_bhvObjectWaveTrail) ::
 (_bhvWaveTrail, Gvar v_bhvWaveTrail) ::
 (_bhvTinyStrongWindParticle, Gvar v_bhvTinyStrongWindParticle) ::
 (_bhvStrongWindParticle, Gvar v_bhvStrongWindParticle) ::
 (_bhvSLSnowmanWind, Gvar v_bhvSLSnowmanWind) ::
 (_bhvSLWalkingPenguin, Gvar v_bhvSLWalkingPenguin) ::
 (_bhvYellowBall, Gvar v_bhvYellowBall) :: (_bhvMario, Gvar v_bhvMario) ::
 (_bhvToadMessage, Gvar v_bhvToadMessage) ::
 (_bhvUnlockDoorStar, Gvar v_bhvUnlockDoorStar) ::
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
 (_bhvSwimmingWarp, Gvar v_bhvSwimmingWarp) ::
 (_bhvRandomAnimatedTexture, Gvar v_bhvRandomAnimatedTexture) ::
 (_bhvYellowBackgroundInMenu, Gvar v_bhvYellowBackgroundInMenu) ::
 (_bhvMenuButton, Gvar v_bhvMenuButton) ::
 (_bhvMenuButtonManager, Gvar v_bhvMenuButtonManager) ::
 (_bhvActSelectorStarType, Gvar v_bhvActSelectorStarType) ::
 (_bhvActSelector, Gvar v_bhvActSelector) ::
 (_bhvMovingYellowCoin, Gvar v_bhvMovingYellowCoin) ::
 (_bhvMovingBlueCoin, Gvar v_bhvMovingBlueCoin) ::
 (_bhvBlueCoinSliding, Gvar v_bhvBlueCoinSliding) ::
 (_bhvBlueCoinJumping, Gvar v_bhvBlueCoinJumping) ::
 (_bhvSeaweed, Gvar v_bhvSeaweed) ::
 (_bhvSeaweedBundle, Gvar v_bhvSeaweedBundle) ::
 (_bhvBobomb, Gvar v_bhvBobomb) ::
 (_bhvBobombFuseSmoke, Gvar v_bhvBobombFuseSmoke) ::
 (_bhvBobombBuddy, Gvar v_bhvBobombBuddy) ::
 (_bhvBobombBuddyOpensCannon, Gvar v_bhvBobombBuddyOpensCannon) ::
 (_bhvCannonClosed, Gvar v_bhvCannonClosed) ::
 (_bhvWhirlpool, Gvar v_bhvWhirlpool) ::
 (_bhvJetStream, Gvar v_bhvJetStream) ::
 (_bhvMessagePanel, Gvar v_bhvMessagePanel) ::
 (_bhvSignOnWall, Gvar v_bhvSignOnWall) ::
 (_bhvHomingAmp, Gvar v_bhvHomingAmp) ::
 (_bhvCirclingAmp, Gvar v_bhvCirclingAmp) ::
 (_bhvButterfly, Gvar v_bhvButterfly) :: (_bhvHoot, Gvar v_bhvHoot) ::
 (_bhvBetaHoldableObject, Gvar v_bhvBetaHoldableObject) ::
 (_bhvCarrySomething1, Gvar v_bhvCarrySomething1) ::
 (_bhvCarrySomething2, Gvar v_bhvCarrySomething2) ::
 (_bhvCarrySomething3, Gvar v_bhvCarrySomething3) ::
 (_bhvCarrySomething4, Gvar v_bhvCarrySomething4) ::
 (_bhvCarrySomething5, Gvar v_bhvCarrySomething5) ::
 (_bhvCarrySomething6, Gvar v_bhvCarrySomething6) ::
 (_bhvObjectBubble, Gvar v_bhvObjectBubble) ::
 (_bhvObjectWaterWave, Gvar v_bhvObjectWaterWave) ::
 (_bhvExplosion, Gvar v_bhvExplosion) ::
 (_bhvBobombBullyDeathSmoke, Gvar v_bhvBobombBullyDeathSmoke) ::
 (_bhvSmoke, Gvar v_bhvSmoke) ::
 (_bhvBobombExplosionBubble, Gvar v_bhvBobombExplosionBubble) ::
 (_bhvBobombExplosionBubble3600, Gvar v_bhvBobombExplosionBubble3600) ::
 (_bhvRespawner, Gvar v_bhvRespawner) ::
 (_bhvSmallBully, Gvar v_bhvSmallBully) ::
 (_bhvBigBully, Gvar v_bhvBigBully) ::
 (_bhvBigBullyWithMinions, Gvar v_bhvBigBullyWithMinions) ::
 (_bhvSmallChillBully, Gvar v_bhvSmallChillBully) ::
 (_bhvBigChillBully, Gvar v_bhvBigChillBully) ::
 (_bhvJetStreamRingSpawner, Gvar v_bhvJetStreamRingSpawner) ::
 (_bhvJetStreamWaterRing, Gvar v_bhvJetStreamWaterRing) ::
 (_bhvMantaRayWaterRing, Gvar v_bhvMantaRayWaterRing) ::
 (_bhvMantaRayRingManager, Gvar v_bhvMantaRayRingManager) ::
 (_bhvBowserBomb, Gvar v_bhvBowserBomb) ::
 (_bhvBowserBombExplosion, Gvar v_bhvBowserBombExplosion) ::
 (_bhvBowserBombSmoke, Gvar v_bhvBowserBombSmoke) ::
 (_bhvCelebrationStar, Gvar v_bhvCelebrationStar) ::
 (_bhvCelebrationStarSparkle, Gvar v_bhvCelebrationStarSparkle) ::
 (_bhvStarKeyCollectionPuffSpawner, Gvar v_bhvStarKeyCollectionPuffSpawner) ::
 (_bhvLLLDrawbridgeSpawner, Gvar v_bhvLLLDrawbridgeSpawner) ::
 (_bhvLLLDrawbridge, Gvar v_bhvLLLDrawbridge) ::
 (_bhvSmallBomp, Gvar v_bhvSmallBomp) ::
 (_bhvLargeBomp, Gvar v_bhvLargeBomp) ::
 (_bhvWFSlidingPlatform, Gvar v_bhvWFSlidingPlatform) ::
 (_bhvMoneybag, Gvar v_bhvMoneybag) ::
 (_bhvMoneybagHidden, Gvar v_bhvMoneybagHidden) ::
 (_bhvPitBowlingBall, Gvar v_bhvPitBowlingBall) ::
 (_bhvFreeBowlingBall, Gvar v_bhvFreeBowlingBall) ::
 (_bhvBowlingBall, Gvar v_bhvBowlingBall) ::
 (_bhvTTMBowlingBallSpawner, Gvar v_bhvTTMBowlingBallSpawner) ::
 (_bhvBoBBowlingBallSpawner, Gvar v_bhvBoBBowlingBallSpawner) ::
 (_bhvTHIBowlingBallSpawner, Gvar v_bhvTHIBowlingBallSpawner) ::
 (_bhvRRCruiserWing, Gvar v_bhvRRCruiserWing) ::
 (_bhvSpindel, Gvar v_bhvSpindel) ::
 (_bhvSSLMovingPyramidWall, Gvar v_bhvSSLMovingPyramidWall) ::
 (_bhvPyramidElevator, Gvar v_bhvPyramidElevator) ::
 (_bhvPyramidElevatorTrajectoryMarkerBall, Gvar v_bhvPyramidElevatorTrajectoryMarkerBall) ::
 (_bhvPyramidTop, Gvar v_bhvPyramidTop) ::
 (_bhvPyramidTopFragment, Gvar v_bhvPyramidTopFragment) ::
 (_bhvPyramidPillarTouchDetector, Gvar v_bhvPyramidPillarTouchDetector) ::
 (_bhvWaterfallSoundLoop, Gvar v_bhvWaterfallSoundLoop) ::
 (_bhvVolcanoSoundLoop, Gvar v_bhvVolcanoSoundLoop) ::
 (_bhvCastleFlagWaving, Gvar v_bhvCastleFlagWaving) ::
 (_bhvBirdsSoundLoop, Gvar v_bhvBirdsSoundLoop) ::
 (_bhvAmbientSounds, Gvar v_bhvAmbientSounds) ::
 (_bhvSandSoundLoop, Gvar v_bhvSandSoundLoop) ::
 (_bhvHiddenAt120Stars, Gvar v_bhvHiddenAt120Stars) ::
 (_bhvSnowmansBottom, Gvar v_bhvSnowmansBottom) ::
 (_bhvSnowmansHead, Gvar v_bhvSnowmansHead) ::
 (_bhvSnowmansBodyCheckpoint, Gvar v_bhvSnowmansBodyCheckpoint) ::
 (_bhvBigSnowmanWhole, Gvar v_bhvBigSnowmanWhole) ::
 (_bhvBigBoulder, Gvar v_bhvBigBoulder) ::
 (_bhvBigBoulderGenerator, Gvar v_bhvBigBoulderGenerator) ::
 (_bhvWingCap, Gvar v_bhvWingCap) :: (_bhvMetalCap, Gvar v_bhvMetalCap) ::
 (_bhvNormalCap, Gvar v_bhvNormalCap) ::
 (_bhvVanishCap, Gvar v_bhvVanishCap) :: (_bhvStar, Gvar v_bhvStar) ::
 (_bhvStarSpawnCoordinates, Gvar v_bhvStarSpawnCoordinates) ::
 (_bhvHiddenRedCoinStar, Gvar v_bhvHiddenRedCoinStar) ::
 (_bhvRedCoin, Gvar v_bhvRedCoin) ::
 (_bhvBowserCourseRedCoinStar, Gvar v_bhvBowserCourseRedCoinStar) ::
 (_bhvHiddenStar, Gvar v_bhvHiddenStar) ::
 (_bhvHiddenStarTrigger, Gvar v_bhvHiddenStarTrigger) ::
 (_bhvTTMRollingLog, Gvar v_bhvTTMRollingLog) ::
 (_bhvLLLVolcanoFallingTrap, Gvar v_bhvLLLVolcanoFallingTrap) ::
 (_bhvLLLRollingLog, Gvar v_bhvLLLRollingLog) ::
 (_bhv1UpWalking, Gvar v_bhv1UpWalking) ::
 (_bhv1UpRunningAway, Gvar v_bhv1UpRunningAway) ::
 (_bhv1UpSliding, Gvar v_bhv1UpSliding) :: (_bhv1Up, Gvar v_bhv1Up) ::
 (_bhv1UpJumpOnApproach, Gvar v_bhv1UpJumpOnApproach) ::
 (_bhvHidden1Up, Gvar v_bhvHidden1Up) ::
 (_bhvHidden1UpTrigger, Gvar v_bhvHidden1UpTrigger) ::
 (_bhvHidden1UpInPole, Gvar v_bhvHidden1UpInPole) ::
 (_bhvHidden1UpInPoleTrigger, Gvar v_bhvHidden1UpInPoleTrigger) ::
 (_bhvHidden1UpInPoleSpawner, Gvar v_bhvHidden1UpInPoleSpawner) ::
 (_bhvControllablePlatform, Gvar v_bhvControllablePlatform) ::
 (_bhvControllablePlatformSub, Gvar v_bhvControllablePlatformSub) ::
 (_bhvBreakableBoxSmall, Gvar v_bhvBreakableBoxSmall) ::
 (_bhvSlidingSnowMound, Gvar v_bhvSlidingSnowMound) ::
 (_bhvSnowMoundSpawn, Gvar v_bhvSnowMoundSpawn) ::
 (_bhvWDWSquareFloatingPlatform, Gvar v_bhvWDWSquareFloatingPlatform) ::
 (_bhvWDWRectangularFloatingPlatform, Gvar v_bhvWDWRectangularFloatingPlatform) ::
 (_bhvJRBFloatingPlatform, Gvar v_bhvJRBFloatingPlatform) ::
 (_bhvArrowLift, Gvar v_bhvArrowLift) ::
 (_bhvOrangeNumber, Gvar v_bhvOrangeNumber) ::
 (_bhvMantaRay, Gvar v_bhvMantaRay) ::
 (_bhvFallingPillar, Gvar v_bhvFallingPillar) ::
 (_bhvFallingPillarHitbox, Gvar v_bhvFallingPillarHitbox) ::
 (_bhvPillarBase, Gvar v_bhvPillarBase) ::
 (_bhvJRBFloatingBox, Gvar v_bhvJRBFloatingBox) ::
 (_bhvDecorativePendulum, Gvar v_bhvDecorativePendulum) ::
 (_bhvTreasureChestsShip, Gvar v_bhvTreasureChestsShip) ::
 (_bhvTreasureChestsJRB, Gvar v_bhvTreasureChestsJRB) ::
 (_bhvTreasureChestsDDD, Gvar v_bhvTreasureChestsDDD) ::
 (_bhvTreasureChestBottom, Gvar v_bhvTreasureChestBottom) ::
 (_bhvTreasureChestTop, Gvar v_bhvTreasureChestTop) ::
 (_bhvMips, Gvar v_bhvMips) :: (_bhvYoshi, Gvar v_bhvYoshi) ::
 (_bhvKoopa, Gvar v_bhvKoopa) ::
 (_bhvKoopaRaceEndpoint, Gvar v_bhvKoopaRaceEndpoint) ::
 (_bhvKoopaFlag, Gvar v_bhvKoopaFlag) :: (_bhvPokey, Gvar v_bhvPokey) ::
 (_bhvPokeyBodyPart, Gvar v_bhvPokeyBodyPart) ::
 (_bhvSwoop, Gvar v_bhvSwoop) :: (_bhvFlyGuy, Gvar v_bhvFlyGuy) ::
 (_bhvGoomba, Gvar v_bhvGoomba) ::
 (_bhvGoombaTripletSpawner, Gvar v_bhvGoombaTripletSpawner) ::
 (_bhvChainChomp, Gvar v_bhvChainChomp) ::
 (_bhvChainChompChainPart, Gvar v_bhvChainChompChainPart) ::
 (_bhvWoodenPost, Gvar v_bhvWoodenPost) ::
 (_bhvChainChompGate, Gvar v_bhvChainChompGate) ::
 (_bhvWigglerHead, Gvar v_bhvWigglerHead) ::
 (_bhvWigglerBody, Gvar v_bhvWigglerBody) ::
 (_bhvEnemyLakitu, Gvar v_bhvEnemyLakitu) ::
 (_bhvCameraLakitu, Gvar v_bhvCameraLakitu) ::
 (_bhvCloud, Gvar v_bhvCloud) :: (_bhvCloudPart, Gvar v_bhvCloudPart) ::
 (_bhvSpiny, Gvar v_bhvSpiny) :: (_bhvMontyMole, Gvar v_bhvMontyMole) ::
 (_bhvMontyMoleHole, Gvar v_bhvMontyMoleHole) ::
 (_bhvMontyMoleRock, Gvar v_bhvMontyMoleRock) ::
 (_bhvPlatformOnTrack, Gvar v_bhvPlatformOnTrack) ::
 (_bhvTrackBall, Gvar v_bhvTrackBall) ::
 (_bhvSeesawPlatform, Gvar v_bhvSeesawPlatform) ::
 (_bhvFerrisWheelAxle, Gvar v_bhvFerrisWheelAxle) ::
 (_bhvFerrisWheelPlatform, Gvar v_bhvFerrisWheelPlatform) ::
 (_bhvWaterBombSpawner, Gvar v_bhvWaterBombSpawner) ::
 (_bhvWaterBomb, Gvar v_bhvWaterBomb) ::
 (_bhvWaterBombShadow, Gvar v_bhvWaterBombShadow) ::
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
 (_bhvMrBlizzardSnowball, Gvar v_bhvMrBlizzardSnowball) ::
 (_bhvSlidingPlatform2, Gvar v_bhvSlidingPlatform2) ::
 (_bhvOctagonalPlatformRotating, Gvar v_bhvOctagonalPlatformRotating) ::
 (_bhvAnimatesOnFloorSwitchPress, Gvar v_bhvAnimatesOnFloorSwitchPress) ::
 (_bhvActivatedBackAndForthPlatform, Gvar v_bhvActivatedBackAndForthPlatform) ::
 (_bhvRecoveryHeart, Gvar v_bhvRecoveryHeart) ::
 (_bhvWaterBombCannon, Gvar v_bhvWaterBombCannon) ::
 (_bhvCannonBarrelBubbles, Gvar v_bhvCannonBarrelBubbles) ::
 (_bhvUnagi, Gvar v_bhvUnagi) ::
 (_bhvUnagiSubobject, Gvar v_bhvUnagiSubobject) ::
 (_bhvDorrie, Gvar v_bhvDorrie) ::
 (_bhvHauntedChair, Gvar v_bhvHauntedChair) ::
 (_bhvMadPiano, Gvar v_bhvMadPiano) ::
 (_bhvFlyingBookend, Gvar v_bhvFlyingBookend) ::
 (_bhvBookendSpawn, Gvar v_bhvBookendSpawn) ::
 (_bhvHauntedBookshelfManager, Gvar v_bhvHauntedBookshelfManager) ::
 (_bhvBookSwitch, Gvar v_bhvBookSwitch) ::
 (_bhvFirePiranhaPlant, Gvar v_bhvFirePiranhaPlant) ::
 (_bhvSmallPiranhaFlame, Gvar v_bhvSmallPiranhaFlame) ::
 (_bhvFireSpitter, Gvar v_bhvFireSpitter) ::
 (_bhvFlyguyFlame, Gvar v_bhvFlyguyFlame) ::
 (_bhvSnufit, Gvar v_bhvSnufit) ::
 (_bhvSnufitBalls, Gvar v_bhvSnufitBalls) ::
 (_bhvHorizontalGrindel, Gvar v_bhvHorizontalGrindel) ::
 (_bhvEyerokBoss, Gvar v_bhvEyerokBoss) ::
 (_bhvEyerokHand, Gvar v_bhvEyerokHand) :: (_bhvKlepto, Gvar v_bhvKlepto) ::
 (_bhvBird, Gvar v_bhvBird) ::
 (_bhvRacingPenguin, Gvar v_bhvRacingPenguin) ::
 (_bhvPenguinRaceFinishLine, Gvar v_bhvPenguinRaceFinishLine) ::
 (_bhvPenguinRaceShortcutCheck, Gvar v_bhvPenguinRaceShortcutCheck) ::
 (_bhvCoffinSpawner, Gvar v_bhvCoffinSpawner) ::
 (_bhvCoffin, Gvar v_bhvCoffin) :: (_bhvClamShell, Gvar v_bhvClamShell) ::
 (_bhvSkeeter, Gvar v_bhvSkeeter) ::
 (_bhvSkeeterWave, Gvar v_bhvSkeeterWave) ::
 (_bhvSwingPlatform, Gvar v_bhvSwingPlatform) ::
 (_bhvDonutPlatformSpawner, Gvar v_bhvDonutPlatformSpawner) ::
 (_bhvDonutPlatform, Gvar v_bhvDonutPlatform) ::
 (_bhvDDDPole, Gvar v_bhvDDDPole) ::
 (_bhvRedCoinStarMarker, Gvar v_bhvRedCoinStarMarker) ::
 (_bhvTripletButterfly, Gvar v_bhvTripletButterfly) ::
 (_bhvBubba, Gvar v_bhvBubba) ::
 (_bhvBeginningLakitu, Gvar v_bhvBeginningLakitu) ::
 (_bhvBeginningPeach, Gvar v_bhvBeginningPeach) ::
 (_bhvEndBirds1, Gvar v_bhvEndBirds1) ::
 (_bhvEndBirds2, Gvar v_bhvEndBirds2) ::
 (_bhvIntroScene, Gvar v_bhvIntroScene) :: nil).

Definition public_idents : list ident :=
(_bhvIntroScene :: _bhvEndBirds2 :: _bhvEndBirds1 :: _bhvBeginningPeach ::
 _bhvBeginningLakitu :: _bhvBubba :: _bhvTripletButterfly ::
 _bhvRedCoinStarMarker :: _bhvDDDPole :: _bhvDonutPlatform ::
 _bhvDonutPlatformSpawner :: _bhvSwingPlatform :: _bhvSkeeterWave ::
 _bhvSkeeter :: _bhvClamShell :: _bhvCoffin :: _bhvCoffinSpawner ::
 _bhvPenguinRaceShortcutCheck :: _bhvPenguinRaceFinishLine ::
 _bhvRacingPenguin :: _bhvBird :: _bhvKlepto :: _bhvEyerokHand ::
 _bhvEyerokBoss :: _bhvHorizontalGrindel :: _bhvSnufitBalls :: _bhvSnufit ::
 _bhvFlyguyFlame :: _bhvFireSpitter :: _bhvSmallPiranhaFlame ::
 _bhvFirePiranhaPlant :: _bhvBookSwitch :: _bhvHauntedBookshelfManager ::
 _bhvBookendSpawn :: _bhvFlyingBookend :: _bhvMadPiano :: _bhvHauntedChair ::
 _bhvDorrie :: _bhvUnagiSubobject :: _bhvUnagi :: _bhvCannonBarrelBubbles ::
 _bhvWaterBombCannon :: _bhvRecoveryHeart ::
 _bhvActivatedBackAndForthPlatform :: _bhvAnimatesOnFloorSwitchPress ::
 _bhvOctagonalPlatformRotating :: _bhvSlidingPlatform2 ::
 _bhvMrBlizzardSnowball :: _bhvMrBlizzard :: _bhvTTCSpinner ::
 _bhvTTC2DRotator :: _bhvTTCElevator :: _bhvTTCPitBlock :: _bhvTTCCog ::
 _bhvTTCMovingBar :: _bhvTTCTreadmill :: _bhvTTCPendulum ::
 _bhvTTCRotatingSolid :: _bhvWaterBombShadow :: _bhvWaterBomb ::
 _bhvWaterBombSpawner :: _bhvFerrisWheelPlatform :: _bhvFerrisWheelAxle ::
 _bhvSeesawPlatform :: _bhvTrackBall :: _bhvPlatformOnTrack ::
 _bhvMontyMoleRock :: _bhvMontyMoleHole :: _bhvMontyMole :: _bhvSpiny ::
 _bhvCloudPart :: _bhvCloud :: _bhvCameraLakitu :: _bhvEnemyLakitu ::
 _bhvWigglerBody :: _bhvWigglerHead :: _bhvChainChompGate ::
 _bhvWoodenPost :: _bhvChainChompChainPart :: _bhvChainChomp ::
 _bhvGoombaTripletSpawner :: _bhvGoomba :: _bhvFlyGuy :: _bhvSwoop ::
 _bhvPokeyBodyPart :: _bhvPokey :: _bhvKoopaFlag :: _bhvKoopaRaceEndpoint ::
 _bhvKoopa :: _bhvYoshi :: _bhvMips :: _bhvTreasureChestTop ::
 _bhvTreasureChestBottom :: _bhvTreasureChestsDDD :: _bhvTreasureChestsJRB ::
 _bhvTreasureChestsShip :: _bhvDecorativePendulum :: _bhvJRBFloatingBox ::
 _bhvPillarBase :: _bhvFallingPillarHitbox :: _bhvFallingPillar ::
 _bhvMantaRay :: _bhvOrangeNumber :: _bhvArrowLift ::
 _bhvJRBFloatingPlatform :: _bhvWDWRectangularFloatingPlatform ::
 _bhvWDWSquareFloatingPlatform :: _bhvSnowMoundSpawn ::
 _bhvSlidingSnowMound :: _bhvBreakableBoxSmall ::
 _bhvControllablePlatformSub :: _bhvControllablePlatform ::
 _bhvHidden1UpInPoleSpawner :: _bhvHidden1UpInPoleTrigger ::
 _bhvHidden1UpInPole :: _bhvHidden1UpTrigger :: _bhvHidden1Up ::
 _bhv1UpJumpOnApproach :: _bhv1Up :: _bhv1UpSliding :: _bhv1UpRunningAway ::
 _bhv1UpWalking :: _bhvLLLRollingLog :: _bhvLLLVolcanoFallingTrap ::
 _bhvTTMRollingLog :: _bhvHiddenStarTrigger :: _bhvHiddenStar ::
 _bhvBowserCourseRedCoinStar :: _bhvRedCoin :: _bhvHiddenRedCoinStar ::
 _bhvStarSpawnCoordinates :: _bhvStar :: _bhvVanishCap :: _bhvNormalCap ::
 _bhvMetalCap :: _bhvWingCap :: _bhvBigBoulderGenerator :: _bhvBigBoulder ::
 _bhvBigSnowmanWhole :: _bhvSnowmansBodyCheckpoint :: _bhvSnowmansHead ::
 _bhvSnowmansBottom :: _bhvHiddenAt120Stars :: _bhvSandSoundLoop ::
 _bhvAmbientSounds :: _bhvBirdsSoundLoop :: _bhvCastleFlagWaving ::
 _bhvVolcanoSoundLoop :: _bhvWaterfallSoundLoop ::
 _bhvPyramidPillarTouchDetector :: _bhvPyramidTopFragment ::
 _bhvPyramidTop :: _bhvPyramidElevatorTrajectoryMarkerBall ::
 _bhvPyramidElevator :: _bhvSSLMovingPyramidWall :: _bhvSpindel ::
 _bhvRRCruiserWing :: _bhvTHIBowlingBallSpawner ::
 _bhvBoBBowlingBallSpawner :: _bhvTTMBowlingBallSpawner :: _bhvBowlingBall ::
 _bhvFreeBowlingBall :: _bhvPitBowlingBall :: _bhvMoneybagHidden ::
 _bhvMoneybag :: _bhvWFSlidingPlatform :: _bhvLargeBomp :: _bhvSmallBomp ::
 _bhvLLLDrawbridge :: _bhvLLLDrawbridgeSpawner ::
 _bhvStarKeyCollectionPuffSpawner :: _bhvCelebrationStarSparkle ::
 _bhvCelebrationStar :: _bhvBowserBombSmoke :: _bhvBowserBombExplosion ::
 _bhvBowserBomb :: _bhvMantaRayRingManager :: _bhvMantaRayWaterRing ::
 _bhvJetStreamWaterRing :: _bhvJetStreamRingSpawner :: _bhvBigChillBully ::
 _bhvSmallChillBully :: _bhvBigBullyWithMinions :: _bhvBigBully ::
 _bhvSmallBully :: _bhvRespawner :: _bhvBobombExplosionBubble3600 ::
 _bhvBobombExplosionBubble :: _bhvSmoke :: _bhvBobombBullyDeathSmoke ::
 _bhvExplosion :: _bhvObjectWaterWave :: _bhvObjectBubble ::
 _bhvCarrySomething6 :: _bhvCarrySomething5 :: _bhvCarrySomething4 ::
 _bhvCarrySomething3 :: _bhvCarrySomething2 :: _bhvCarrySomething1 ::
 _bhvBetaHoldableObject :: _bhvHoot :: _bhvButterfly :: _bhvCirclingAmp ::
 _bhvHomingAmp :: _bhvSignOnWall :: _bhvMessagePanel :: _bhvJetStream ::
 _bhvWhirlpool :: _bhvCannonClosed :: _bhvBobombBuddyOpensCannon ::
 _bhvBobombBuddy :: _bhvBobombFuseSmoke :: _bhvBobomb :: _bhvSeaweedBundle ::
 _bhvSeaweed :: _bhvBlueCoinJumping :: _bhvBlueCoinSliding ::
 _bhvMovingBlueCoin :: _bhvMovingYellowCoin :: _bhvActSelector ::
 _bhvActSelectorStarType :: _bhvMenuButtonManager :: _bhvMenuButton ::
 _bhvYellowBackgroundInMenu :: _bhvRandomAnimatedTexture ::
 _bhvSwimmingWarp :: _bhvLaunchDeathWarp :: _bhvLaunchStarCollectWarp ::
 _bhvAirborneStarCollectWarp :: _bhvAirborneDeathWarp ::
 _bhvPaintingDeathWarp :: _bhvPaintingStarCollectWarp :: _bhvFlyingWarp ::
 _bhvSpinAirborneWarp :: _bhvDeathWarp :: _bhvSpinAirborneCircleWarp ::
 _bhvHardAirKnockBackWarp :: _bhvAirborneWarp :: _bhvInstantActiveWarp ::
 _bhvUnlockDoorStar :: _bhvToadMessage :: _bhvMario :: _bhvYellowBall ::
 _bhvSLWalkingPenguin :: _bhvSLSnowmanWind :: _bhvStrongWindParticle ::
 _bhvTinyStrongWindParticle :: _bhvWaveTrail :: _bhvObjectWaveTrail ::
 _bhvShallowWaterSplash :: _bhvShallowWaterWave :: _bhvObjectWaterSplash ::
 _bhvIdleWaterWave :: _bhvBubbleSplash :: _bhvWaterDropletSplash ::
 _bhvWaterDroplet :: _bhvWaterSplash :: _bhvSmallWhomp ::
 _bhvWhompKingBoss :: _bhvScuttlebugSpawn :: _bhvScuttlebug ::
 _bhvSparkleParticleSpawner :: _bhvSparkleSpawn :: _bhvSparkle :: _bhvTree ::
 _bhvFloorTrapInCastle :: _bhvCastleFloorTrap :: _bhvUnused2A54 ::
 _bhvStaticObject :: _bhvUnusedFakeStar :: _bhvUnused2A10 ::
 _bhvStaticCheckeredPlatform :: _bhvBetaBowserAnchor :: _bhvInsideCannon ::
 _bhvPlaysMusicTrackWhenTouched :: _bhvMerryGoRound :: _bhvMeshElevator ::
 _bhvHauntedBookshelf :: _bhvBBHTiltingTrapPlatform :: _bhvBooStaircase ::
 _bhvHiddenStaircaseStep :: _bhvGhostHuntBoo :: _bhvMerryGoRoundBoo ::
 _bhvBoo :: _bhvCourtyardBooTriplet :: _bhvGhostHuntBigBoo ::
 _bhvMerryGoRoundBigBoo :: _bhvBalconyBigBoo :: _bhvBooWithCage ::
 _bhvBooInCastle :: _bhvAnimatedTexture :: _bhvMerryGoRoundBooManager ::
 _bhvTweester :: _bhvTweesterSandParticle ::
 _bhvInitializeChangingWaterLevel :: _bhvWaterLevelDiamond ::
 _bhvOpenableGrill :: _bhvOpenableCageDoor :: _bhvHiddenBlueCoin ::
 _bhvBlueCoinSwitch :: _bhvPurpleSwitchHiddenBoxes :: _bhvWhitePuffSmoke2 ::
 _bhvWhitePuff2 :: _bhvWhitePuff1 :: _bhvMistParticleSpawner ::
 _bhvInSunkenShip2 :: _bhvInSunkenShip :: _bhvSunkenShipPart2 ::
 _bhvSunkenShipSetRotation :: _bhvSunkenShipPart :: _bhvInSunkenShip3 ::
 _bhvShipPart3 :: _bhvJRBSlidingBox :: _bhvSushiSharkCollisionChild ::
 _bhvSushiShark :: _bhvBowsersSub :: _bhvBowserSubDoor :: _bhvRockSolid ::
 _bhvSoundSpawner :: _bhvRotatingExclamationMark :: _bhvExclamationBox ::
 _bhvBub :: _bhvChirpChirpUnused :: _bhvChirpChirp ::
 _bhvWDWExpressElevatorPlatform :: _bhvWDWExpressElevator :: _bhvFish ::
 _bhvFishSpawner :: _bhvFewBlueFishSpawner :: _bhvManyBlueFishSpawner ::
 _bhvSmallPenguin :: _bhvUnused20E0 :: _bhvPenguinBaby :: _bhvTuxiesMother ::
 _bhvLLLBowserPuzzle :: _bhvLLLBowserPuzzlePiece :: _bhvLLLHexagonalMesh ::
 _bhvPiranhaPlant :: _bhvToxBox :: _bhvKoopaShellFlame :: _bhvKoopaShell ::
 _bhvUnused1F30 :: _bhvLLLTiltingInvertedPyramid ::
 _bhvLLLSinkingSquarePlatforms :: _bhvLLLSinkingRectangularPlatform ::
 _bhvLLLRotatingHexagonalRing :: _bhvVolcanoFlames ::
 _bhvLLLFloatingWoodBridge :: _bhvLLLWoodPiece :: _bhvLLLRotatingHexFlame ::
 _bhvLLLRotatingBlockWithFireBars :: _bhvSnowBall ::
 _bhvLLLMovingOctagonalMeshPlatform :: _bhvStub1D70 ::
 _bhvLLLSinkingRockBlock :: _bhvLLLRotatingHexagonalPlatform ::
 _bhvStub1D0C :: _bhvMacroUkiki :: _bhvClockHourHand ::
 _bhvClockMinuteHand :: _bhvMoatGrills :: _bhvDDDWarp ::
 _bhvWaterLevelPillar :: _bhvInvisibleObjectsUnderBridge ::
 _bhvBowserKeyCourseExit :: _bhvBowserKeyUnlockDoor ::
 _bhvCheckerboardPlatformSub :: _bhvCheckerboardElevatorGroup ::
 _bhvTankFishGroup :: _bhvBlueFish :: _bhvFlameLargeBurningOut ::
 _bhvFlameBowser :: _bhvFlameMovingForwardGrowing :: _bhvFlameBouncing ::
 _bhvBlueFlamesGroup :: _bhvFlameFloatingLanding :: _bhvBlueBowserFlame ::
 _bhvFallingBowserPlatform :: _bhvTiltingBowserLavaPlatform ::
 _bhvBowserFlameSpawn :: _bhvBowserBodyAnchor :: _bhvBowser ::
 _bhvBowserTailAnchor :: _bhvUnused1820 :: _bhvWhitePuffSmoke ::
 _bhvBulletBill :: _bhvAlphaBooKey :: _bhvBetaBooKey :: _bhvGrandStar ::
 _bhvBowserKey :: _bhvIgloo :: _bhvStub :: _bhvBooCage :: _bhvJumpingBox ::
 _bhvBetaTrampolineSpring :: _bhvBetaTrampolineTop ::
 _bhvUnusedPoundablePlatform :: _bhvCCMTouchedStarSpawn ::
 _bhvHeaveHoThrowMario :: _bhvHeaveHo :: _bhvPushableMetalBox ::
 _bhvBreakableBox :: _bhvHiddenObject :: _bhvFloorSwitchHiddenObjects ::
 _bhvFloorSwitchHardcodedModel :: _bhvFloorSwitchGrills ::
 _bhvFloorSwitchAnimatesObject :: _bhvPiranhaPlantWakingBubbles ::
 _bhvPiranhaPlantBubble :: _bhvSquarishPathMoving ::
 _bhvAnotherTiltingPlatform :: _bhvTreeLeaf :: _bhvTreeSnow ::
 _bhvLeafParticleSpawner :: _bhvWFSolidTowerPlatform ::
 _bhvWFElevatorTowerPlatform :: _bhvWFSlidingTowerPlatform ::
 _bhvTowerPlatformGroup :: _bhvSpindrift :: _bhvBetaFishSplashSpawner ::
 _bhvBlackSmokeUpward :: _bhvBlackSmokeBowser :: _bhvBlackSmokeMario ::
 _bhvFireParticleSpawner :: _bhvBowserShockWave ::
 _bhvBouncingFireballFlame :: _bhvBouncingFireball ::
 _bhvFlamethrowerFlame :: _bhvFlamethrower :: _bhvRRRotatingBridgePlatform ::
 _bhvBetaMovingFlames :: _bhvBetaMovingFlamesSpawn :: _bhvCutOutObject ::
 _bhvSquishablePlatform :: _bhvBitFSTiltingInvertedPyramid ::
 _bhvDDDMovingPole :: _bhvBitFSSinkingCagePlatform ::
 _bhvBitFSSinkingPlatforms :: _bhvUkikiCage :: _bhvUkikiCageStar ::
 _bhvUkikiCageChild :: _bhvUkiki :: _bhvUnusedParticleSpawn ::
 _bhvEndPeach :: _bhvEndToad :: _bhvWind :: _bhvSnowParticleSpawner ::
 _bhvDirtParticleSpawner :: _bhvMistCircParticleSpawner :: _bhvUnused0DFC ::
 _bhvWaterMist2 :: _bhvBreakBoxTriangle :: _bhvBreathParticleSpawner ::
 _bhvWaterMist :: _bhvHMCElevatorPlatform :: _bhvRRElevatorPlatform ::
 _bhvAnotherElavator :: _bhvFlame :: _bhvLLLTumblingBridge ::
 _bhvBBHTumblingBridge :: _bhvTumblingBridge :: _bhvTumblingBridgePlatform ::
 _bhvThwomp2 :: _bhvThwomp :: _bhvGrindel :: _bhvDoor :: _bhvDoorWarp ::
 _bhvTriangleParticleSpawner :: _bhvPunchTinyTriangle ::
 _bhvHorStarParticleSpawner :: _bhvPoundTinyStarParticle ::
 _bhvVertStarParticleSpawner :: _bhvWallTinyStarParticle ::
 _bhvGoldenCoinSparkles :: _bhvCoinSparkles :: _bhvSingleCoinGetsSpawned ::
 _bhvTenCoinsSpawn :: _bhvThreeCoinsSpawn :: _bhvTemporaryYellowCoin ::
 _bhvYellowCoin :: _bhvOneCoin :: _bhvCoinFormation ::
 _bhvCoinFormationSpawn :: _bhvCoinInsideBoo :: _bhvSpawnedBlueCoin ::
 _bhvSpawnedStarNoLevelExit :: _bhvSpawnedStar :: _bhvWhitePuffExplosion ::
 _bhvWarpPipe :: _bhvWarp :: _bhvFadingWarp :: _bhvExitPodiumWarp ::
 _bhvKoopaShellUnderwater :: _bhvWFRotatingWoodenPlatform ::
 _bhvRotatingCounterClockwise :: _bhvTowerDoor :: _bhvKickableBoard ::
 _bhvWFBreakableWallLeft :: _bhvWFBreakableWallRight ::
 _bhvBulletBillCannon :: _bhvTower :: _bhvRotatingPlatform ::
 _bhvUnused05A8 :: _bhvChuckyaAnchorMario :: _bhvChuckya ::
 _bhvCannonBaseUnused :: _bhvCannonBarrel :: _bhvCannon :: _bhvFishGroup ::
 _bhvSmallParticleBubbles :: _bhvSmallParticleSnow :: _bhvPlungeBubble ::
 _bhvSmallParticle :: _bhvWaterAirBubble :: _bhvSmallWaterWave398 ::
 _bhvSmallWaterWave :: _bhvBubbleMaybe :: _bhvBubbleParticleSpawner ::
 _bhvBetaChestLid :: _bhvBetaChestBottom :: _bhvBobombAnchorMario ::
 _bhvKingBobomb :: _bhvCapSwitch :: _bhvCapSwitchBase ::
 _bhvTHITinyIslandTop :: _bhvTHIHugeIslandTop :: _bhvPoleGrabbing ::
 _bhvGiantPole :: _bhvPurpleParticle :: _bhvMrIParticle :: _bhvMrIBody ::
 _bhvMrI :: _bhvStarDoor :: _ttm_seg7_collision_podium_warp ::
 _ttm_seg7_collision_ukiki_cage :: _ttm_seg7_collision_pitoune_2 ::
 _bowser_2_seg7_collision_tilting_platform ::
 _wf_seg7_collision_bullet_bill_cannon :: _wf_seg7_collision_tower ::
 _wf_seg7_collision_tower_door :: _wf_seg7_collision_kickable_board ::
 _wf_seg7_collision_breakable_wall_2 :: _wf_seg7_collision_breakable_wall ::
 _wf_seg7_collision_platform :: _wf_seg7_collision_sliding_brick_platform ::
 _wf_seg7_collision_clocklike_rotation :: _wf_seg7_collision_large_bomp ::
 _wf_seg7_collision_small_bomp :: _ddd_seg7_collision_bowser_sub_door ::
 _ddd_seg7_collision_submarine :: _bitfs_seg7_collision_sinking_platform ::
 _bitfs_seg7_collision_squishable_platform ::
 _bitfs_seg7_collision_inverted_pyramid ::
 _bitfs_seg7_collision_sinking_cage_platform ::
 _lll_seg7_collision_falling_wall ::
 _lll_seg7_collision_hexagonal_platform :: _lll_seg7_collision_pitoune ::
 _lll_seg7_collision_floating_block :: _lll_seg7_collision_puzzle_piece ::
 _lll_seg7_collision_inverted_pyramid ::
 _lll_seg7_collision_sinking_pyramids ::
 _lll_seg7_collision_slow_tilting_platform ::
 _lll_seg7_collision_rotating_platform :: _lll_seg7_collision_wood_piece ::
 _lll_seg7_collision_rotating_fire_bars :: _lll_seg7_collision_drawbridge ::
 _lll_seg7_collision_octagonal_moving_platform ::
 _bitdw_seg7_collision_moving_pyramid ::
 _castle_grounds_seg7_collision_cannon_grill ::
 _castle_grounds_seg7_collision_moat_grills ::
 _castle_grounds_seg7_anims_flags :: _rr_seg7_collision_donut_platform ::
 _rr_seg7_collision_elevator_platform ::
 _rr_seg7_collision_rotating_platform_with_fire ::
 _rr_seg7_collision_pendulum ::
 _ttc_seg7_collision_rotating_clock_platform2 ::
 _ttc_seg7_collision_clock_main_rotation ::
 _ttc_seg7_collision_clock_platform :: _ttc_seg7_collision_sliding_surface ::
 _ttc_seg7_collision_clock_pendulum :: _thi_seg7_collision_top_trap ::
 _jrb_seg7_collision_pillar_base :: _jrb_seg7_collision_in_sunken_ship_2 ::
 _jrb_seg7_collision_in_sunken_ship ::
 _jrb_seg7_collision_in_sunken_ship_3 :: _jrb_seg7_collision_floating_box ::
 _jrb_seg7_collision_floating_platform :: _jrb_seg7_collision_rock_solid ::
 _wdw_seg7_collision_rect_floating_platform ::
 _wdw_seg7_collision_express_elevator_platform ::
 _wdw_seg7_collision_arrow_lift ::
 _wdw_seg7_collision_square_floating_platform ::
 _sl_seg7_collision_pound_explodes ::
 _sl_seg7_collision_sliding_snow_mound ::
 _bob_seg7_collision_chain_chomp_gate ::
 _ssl_seg7_collision_pyramid_elevator :: _ssl_seg7_collision_0702808C ::
 _ssl_seg7_collision_spindel :: _ssl_seg7_collision_grindel ::
 _ssl_seg7_collision_tox_box :: _ssl_seg7_collision_pyramid_top ::
 _hmc_seg7_collision_controllable_platform_sub ::
 _hmc_seg7_collision_controllable_platform :: _hmc_seg7_collision_elevator ::
 _inside_castle_seg7_collision_water_level_pillar ::
 _inside_castle_seg7_collision_star_door ::
 _inside_castle_seg7_collision_floor_trap :: _bbh_seg7_collision_coffin ::
 _bbh_seg7_collision_merry_go_round :: _bbh_seg7_collision_mesh_elevator ::
 _bbh_seg7_collision_haunted_bookshelf ::
 _bbh_seg7_collision_tilt_floor_platform ::
 _bbh_seg7_collision_staircase_step :: _swoop_seg6_anims_060070D0 ::
 _scuttlebug_seg6_anims_06015064 :: _dorrie_seg6_collision_0600F644 ::
 _dorrie_seg6_anims_0600F638 :: _moneybag_seg6_anims_06005E5C ::
 _chilly_chief_seg6_anims_06003994 :: _toad_seg6_anims_0600FB58 ::
 _mips_seg6_anims_06015634 :: _lakitu_seg6_anims_060058F8 ::
 _whomp_seg6_collision_06020A0C :: _whomp_seg6_anims_06020A04 ::
 _poundable_pole_collision_06002490 :: _piranha_plant_seg6_anims_0601C31C ::
 _koopa_flag_seg6_anims_06001028 :: _koopa_seg6_anims_06011364 ::
 _chain_chomp_seg6_anims_06025178 :: _water_ring_seg6_anims_06013F7C ::
 _skeeter_seg6_anims_06007DE0 :: _seaweed_seg6_anims_0600A4D4 ::
 _bub_seg6_anims_06012354 :: _bowser_seg6_anims_06057690 ::
 _wiggler_seg5_anims_0500EC8C :: _wiggler_seg5_anims_0500C874 ::
 _spiny_seg5_anims_05016EAC :: _lakitu_enemy_seg5_anims_050144D4 ::
 _yoshi_seg5_anims_05024100 :: _peach_seg5_anims_0501C41C ::
 _birds_seg5_anims_050009E8 :: _mad_piano_seg5_anims_05009B14 ::
 _chair_seg5_anims_05005784 :: _bookend_seg5_anims_05002540 ::
 _springboard_collision_05001A28 :: _capswitch_collision_05003448 ::
 _capswitch_collision_050033D0 :: _spindrift_seg5_anims_05002D68 ::
 _snowman_seg5_anims_0500D118 :: _penguin_seg5_collision_05008B88 ::
 _penguin_seg5_anims_05008B74 :: _ukiki_seg5_anims_05015784 ::
 _monty_mole_seg5_anims_05007248 :: _klepto_seg5_anims_05008CFC ::
 _eyerok_seg5_anims_050116E4 :: _unagi_seg5_anims_05012824 ::
 _sushi_seg5_anims_0500AE54 :: _manta_seg5_anims_05008EB4 ::
 _clam_shell_seg5_anims_05001744 :: _king_bobomb_seg5_anims_0500FE30 ::
 _bully_seg5_anims_0500470C :: _thwomp_seg5_collision_0500B92C ::
 _thwomp_seg5_collision_0500B7D0 :: _hoot_seg5_anims_05005768 ::
 _heave_ho_seg5_anims_0501534C :: _wooden_signpost_seg3_collision_0302DD80 ::
 _warp_pipe_seg3_collision_03009AC8 ::
 _lll_hexagonal_mesh_seg3_collision_0301CECC ::
 _door_seg3_collision_0301CE78 :: _door_seg3_anims_030156C0 ::
 _butterfly_seg3_anims_030056B0 :: _bowser_key_seg3_anims_list ::
 _blue_fish_seg3_anims_0301C2B0 :: _purple_switch_seg8_collision_0800C7A8 ::
 _metal_box_seg8_collision_08024C28 :: _goomba_seg8_anims_0801DA4C ::
 _flyguy_seg8_anims_08011A64 ::
 _exclamation_box_outline_seg8_collision_08025F78 ::
 _chuckya_seg8_anims_0800C070 ::
 _checkerboard_platform_seg8_collision_0800D710 ::
 _cannon_lid_seg8_collision_08004950 ::
 _breakable_box_seg8_collision_08012D70 :: _bobomb_seg8_anims_0802396C ::
 _blue_coin_switch_seg8_collision_08000E98 :: _dAmpAnimsList ::
 _load_object_collision_model :: _bhv_menu_button_manager_loop ::
 _bhv_menu_button_manager_init :: _bhv_menu_button_loop ::
 _bhv_menu_button_init :: _beh_yellow_background_menu_loop ::
 _beh_yellow_background_menu_init :: _try_print_debug_mario_level_info ::
 _try_do_mario_debug_object_spawn :: _cur_obj_rotate_face_angle_using_vel ::
 _cur_obj_move_using_fvel_and_gravity :: _cur_obj_update_floor_and_walls ::
 _cur_obj_compute_vel_xz :: _bhv_unlock_door_star_loop ::
 _bhv_unlock_door_star_init :: _bhv_toad_message_init ::
 _bhv_toad_message_loop :: _bhv_end_toad_loop :: _bhv_end_peach_loop ::
 _gShallowWaterWaveDropletParams :: _gShallowWaterSplashDropletParams ::
 _bhv_volcano_trap_loop :: _bhv_yoshi_loop :: _bhv_dust_smoke_loop ::
 _bhv_intro_scene_loop :: _bhv_end_birds_2_loop :: _bhv_end_birds_1_loop ::
 _bhv_intro_peach_loop :: _bhv_intro_lakitu_loop :: _bhv_bubba_loop ::
 _bhv_triplet_butterfly_update :: _bhv_red_coin_star_marker_init ::
 _bhv_ddd_pole_update :: _bhv_ddd_pole_init :: _bhv_donut_platform_update ::
 _bhv_donut_platform_spawner_update :: _bhv_swing_platform_update ::
 _bhv_swing_platform_init :: _bhv_skeeter_wave_update ::
 _bhv_skeeter_update :: _bhv_clam_loop :: _bhv_coffin_loop ::
 _bhv_coffin_spawner_loop :: _bhv_penguin_race_shortcut_check_update ::
 _bhv_penguin_race_finish_line_update :: _bhv_racing_penguin_update ::
 _bhv_racing_penguin_init :: _bhv_bird_update :: _bhv_klepto_update ::
 _bhv_klepto_init :: _bhv_eyerok_hand_loop :: _bhv_eyerok_boss_loop ::
 _bhv_horizontal_grindel_update :: _bhv_horizontal_grindel_init ::
 _bhv_snufit_balls_loop :: _bhv_snufit_loop :: _bhv_fly_guy_flame_loop ::
 _bhv_fire_spitter_update :: _bhv_small_piranha_flame_loop ::
 _bhv_fire_piranha_plant_update :: _bhv_fire_piranha_plant_init ::
 _bhv_book_switch_loop :: _bhv_haunted_bookshelf_manager_loop ::
 _bhv_bookend_spawn_loop :: _bhv_flying_bookend_loop ::
 _bhv_mad_piano_update :: _bhv_haunted_chair_loop ::
 _bhv_haunted_chair_init :: _bhv_dorrie_update ::
 _bhv_unagi_subobject_loop :: _bhv_unagi_loop :: _bhv_unagi_init ::
 _bhv_bubble_cannon_barrel_loop :: _bhv_water_bomb_cannon_loop ::
 _bhv_recovery_heart_loop :: _bhv_activated_back_and_forth_platform_update ::
 _bhv_activated_back_and_forth_platform_init ::
 _bhv_animates_on_floor_switch_press_loop ::
 _bhv_animates_on_floor_switch_press_init ::
 _bhv_rotating_octagonal_plat_loop :: _bhv_rotating_octagonal_plat_init ::
 _bhv_sliding_plat_2_loop :: _bhv_sliding_plat_2_init ::
 _bhv_mr_blizzard_snowball :: _bhv_mr_blizzard_update ::
 _bhv_mr_blizzard_init :: _bhv_ttc_spinner_update ::
 _bhv_ttc_2d_rotator_update :: _bhv_ttc_2d_rotator_init ::
 _bhv_ttc_elevator_update :: _bhv_ttc_elevator_init ::
 _bhv_ttc_pit_block_update :: _bhv_ttc_pit_block_init ::
 _bhv_ttc_cog_update :: _bhv_ttc_cog_init :: _bhv_ttc_moving_bar_update ::
 _bhv_ttc_moving_bar_init :: _bhv_ttc_treadmill_update ::
 _bhv_ttc_treadmill_init :: _bhv_ttc_pendulum_update ::
 _bhv_ttc_pendulum_init :: _bhv_ttc_rotating_solid_update ::
 _bhv_ttc_rotating_solid_init :: _bhv_water_bomb_shadow_update ::
 _bhv_water_bomb_update :: _bhv_water_bomb_spawner_update ::
 _bhv_ferris_wheel_platform_update :: _bhv_ferris_wheel_axle_init ::
 _bhv_seesaw_platform_update :: _bhv_seesaw_platform_init ::
 _bhv_track_ball_update :: _bhv_platform_on_track_update ::
 _bhv_platform_on_track_init :: _bhv_monty_mole_rock_update ::
 _bhv_monty_mole_hole_update :: _bhv_monty_mole_update ::
 _bhv_monty_mole_init :: _bhv_spiny_update :: _bhv_cloud_part_update ::
 _bhv_cloud_update :: _bhv_camera_lakitu_update :: _bhv_camera_lakitu_init ::
 _bhv_enemy_lakitu_update :: _bhv_wiggler_body_part_update ::
 _bhv_wiggler_update :: _bhv_chain_chomp_gate_update ::
 _bhv_chain_chomp_gate_init :: _bhv_wooden_post_update ::
 _bhv_chain_chomp_chain_part_update :: _bhv_chain_chomp_update ::
 _bhv_goomba_triplet_spawner_update :: _bhv_goomba_update ::
 _bhv_goomba_init :: _bhv_fly_guy_update :: _bhv_swoop_update ::
 _bhv_pokey_body_part_update :: _bhv_pokey_update ::
 _bhv_koopa_race_endpoint_update :: _bhv_koopa_update :: _bhv_koopa_init ::
 _bhv_yoshi_init :: _bhv_mips_loop :: _bhv_mips_init ::
 _bhv_treasure_chest_top_loop :: _bhv_treasure_chest_bottom_loop ::
 _bhv_treasure_chest_bottom_init :: _bhv_treasure_chest_ddd_loop ::
 _bhv_treasure_chest_ddd_init :: _bhv_treasure_chest_jrb_loop ::
 _bhv_treasure_chest_jrb_init :: _bhv_treasure_chest_ship_loop ::
 _bhv_treasure_chest_ship_init :: _bhv_decorative_pendulum_loop ::
 _bhv_decorative_pendulum_init :: _bhv_jrb_floating_box_loop ::
 _bhv_falling_pillar_hitbox_loop :: _bhv_falling_pillar_loop ::
 _bhv_falling_pillar_init :: _bhv_manta_ray_loop :: _bhv_manta_ray_init ::
 _bhv_orange_number_loop :: _bhv_orange_number_init ::
 _bhv_arrow_lift_loop :: _bhv_floating_platform_loop ::
 _bhv_snow_mound_spawn_loop :: _bhv_sliding_snow_mound_loop ::
 _bhv_breakable_box_small_loop :: _bhv_breakable_box_small_init ::
 _bhv_controllable_platform_sub_loop :: _bhv_controllable_platform_loop ::
 _bhv_controllable_platform_init :: _bhv_1up_hidden_in_pole_spawner_loop ::
 _bhv_1up_hidden_in_pole_trigger_loop :: _bhv_1up_hidden_in_pole_loop ::
 _bhv_1up_hidden_trigger_loop :: _bhv_1up_hidden_loop ::
 _bhv_1up_jump_on_approach_loop :: _bhv_1up_loop :: _bhv_1up_init ::
 _bhv_1up_sliding_loop :: _bhv_1up_running_away_loop ::
 _bhv_1up_walking_loop :: _bhv_1up_common_init ::
 _bhv_lll_rolling_log_init :: _bhv_rolling_log_loop ::
 _bhv_ttm_rolling_log_init :: _bhv_hidden_star_trigger_loop ::
 _bhv_hidden_star_loop :: _bhv_hidden_star_init ::
 _bhv_bowser_course_red_coin_star_loop :: _bhv_red_coin_loop ::
 _bhv_red_coin_init :: _bhv_hidden_red_coin_star_loop ::
 _bhv_hidden_red_coin_star_init :: _bhv_star_spawn_loop ::
 _bhv_star_spawn_init :: _bhv_collect_star_loop :: _bhv_collect_star_init ::
 _bhv_vanish_cap_init :: _bhv_normal_cap_loop :: _bhv_normal_cap_init ::
 _bhv_metal_cap_loop :: _bhv_metal_cap_init :: _bhv_wing_vanish_cap_loop ::
 _bhv_wing_cap_init :: _bhv_big_boulder_generator_loop ::
 _bhv_big_boulder_loop :: _bhv_big_boulder_init ::
 _bhv_snowmans_body_checkpoint_loop :: _bhv_snowmans_head_loop ::
 _bhv_snowmans_head_init :: _bhv_snowmans_bottom_loop ::
 _bhv_snowmans_bottom_init :: _bhv_castle_cannon_grate_init ::
 _bhv_sand_sound_loop :: _bhv_ambient_sounds_init :: _bhv_birds_sound_loop ::
 _bhv_castle_flag_init :: _bhv_volcano_sound_loop ::
 _bhv_waterfall_sound_loop :: _bhv_pyramid_pillar_touch_detector_loop ::
 _bhv_pyramid_top_fragment_loop :: _bhv_pyramid_top_fragment_init ::
 _bhv_pyramid_top_loop :: _bhv_pyramid_top_init ::
 _bhv_pyramid_elevator_trajectory_marker_ball_loop ::
 _bhv_pyramid_elevator_loop :: _bhv_pyramid_elevator_init ::
 _bhv_ssl_moving_pyramid_wall_loop :: _bhv_ssl_moving_pyramid_wall_init ::
 _bhv_spindel_loop :: _bhv_spindel_init :: _bhv_rr_cruiser_wing_loop ::
 _bhv_rr_cruiser_wing_init :: _bhv_thi_bowling_ball_spawner_loop ::
 _bhv_generic_bowling_ball_spawner_loop ::
 _bhv_generic_bowling_ball_spawner_init :: _bhv_bowling_ball_loop ::
 _bhv_bowling_ball_init :: _bhv_free_bowling_ball_loop ::
 _bhv_free_bowling_ball_init :: _bhv_bob_pit_bowling_ball_loop ::
 _bhv_bob_pit_bowling_ball_init :: _bhv_moneybag_hidden_loop ::
 _bhv_moneybag_loop :: _bhv_moneybag_init :: _bhv_wf_sliding_platform_loop ::
 _bhv_wf_sliding_platform_init :: _bhv_large_bomp_loop ::
 _bhv_large_bomp_init :: _bhv_small_bomp_loop :: _bhv_small_bomp_init ::
 _bhv_lll_drawbridge_loop :: _bhv_lll_drawbridge_spawner_loop ::
 _bhv_star_key_collection_puff_spawner_loop ::
 _bhv_celebration_star_sparkle_loop :: _bhv_celebration_star_loop ::
 _bhv_celebration_star_init :: _bhv_bowser_bomb_smoke_loop ::
 _bhv_bowser_bomb_explosion_loop :: _bhv_bowser_bomb_loop ::
 _bhv_manta_ray_water_ring_loop :: _bhv_manta_ray_water_ring_init ::
 _bhv_jet_stream_water_ring_loop :: _bhv_jet_stream_water_ring_init ::
 _bhv_jet_stream_ring_spawner_loop :: _bhv_big_bully_with_minions_loop ::
 _bhv_big_bully_with_minions_init :: _bhv_big_bully_init ::
 _bhv_bully_loop :: _bhv_small_bully_init :: _bhv_respawner_loop ::
 _bhv_bobomb_explosion_bubble_loop :: _bhv_bobomb_explosion_bubble_init ::
 _bhv_bobomb_bully_death_smoke_init :: _bhv_explosion_loop ::
 _bhv_explosion_init :: _bhv_object_water_wave_loop ::
 _bhv_object_water_wave_init :: _bhv_object_bubble_loop ::
 _bhv_object_bubble_init :: _bhv_beta_holdable_object_loop ::
 _bhv_beta_holdable_object_init :: _bhv_hoot_loop :: _bhv_hoot_init ::
 _bhv_butterfly_loop :: _bhv_butterfly_init :: _bhv_circling_amp_loop ::
 _bhv_circling_amp_init :: _bhv_homing_amp_loop :: _bhv_homing_amp_init ::
 _bhv_jet_stream_loop :: _bhv_whirlpool_loop :: _bhv_whirlpool_init ::
 _bhv_cannon_closed_loop :: _bhv_cannon_closed_init ::
 _bhv_bobomb_buddy_loop :: _bhv_bobomb_buddy_init ::
 _bhv_bobomb_fuse_smoke_init :: _bhv_bobomb_loop :: _bhv_bobomb_init ::
 _bhv_seaweed_bundle_init :: _bhv_seaweed_init ::
 _bhv_blue_coin_jumping_loop :: _bhv_blue_coin_sliding_loop ::
 _bhv_blue_coin_sliding_jumping_init :: _bhv_moving_blue_coin_loop ::
 _bhv_moving_blue_coin_init :: _bhv_moving_yellow_coin_loop ::
 _bhv_moving_yellow_coin_init :: _bhv_act_selector_loop ::
 _bhv_act_selector_init :: _bhv_act_selector_star_type_loop ::
 _bhv_sl_walking_penguin_loop :: _bhv_sl_snowman_wind_loop ::
 _bhv_strong_wind_particle_loop :: _bhv_wave_trail_shrink ::
 _bhv_shallow_water_splash_init :: _bhv_idle_water_wave_loop ::
 _bhv_bubble_splash_init :: _bhv_water_droplet_splash_init ::
 _bhv_water_droplet_loop :: _bhv_water_splash_spawn_droplets ::
 _bhv_whomp_loop :: _bhv_scuttlebug_spawn_loop :: _bhv_scuttlebug_loop ::
 _bhv_sparkle_spawn_loop :: _bhv_floor_trap_in_castle_loop ::
 _bhv_castle_floor_trap_loop :: _bhv_castle_floor_trap_init ::
 _bhv_static_checkered_platform_loop :: _bhv_beta_bowser_anchor_loop ::
 _bhv_play_music_track_when_touched_loop :: _bhv_merry_go_round_loop ::
 _bhv_haunted_bookshelf_loop :: _bhv_bbh_tilting_trap_platform_loop ::
 _bhv_boo_staircase :: _bhv_boo_loop :: _bhv_courtyard_boo_triplet_init ::
 _bhv_big_boo_loop :: _bhv_boo_init :: _bhv_boo_with_cage_loop ::
 _bhv_boo_with_cage_init :: _bhv_boo_in_castle_loop ::
 _bhv_animated_texture_loop :: _bhv_merry_go_round_boo_manager_loop ::
 _bhv_tweester_loop :: _bhv_tweester_sand_particle_loop ::
 _bhv_init_changing_water_level_loop :: _bhv_water_level_diamond_loop ::
 _bhv_openable_grill_loop :: _bhv_openable_cage_door_loop ::
 _bhv_hidden_blue_coin_loop :: _bhv_blue_coin_switch_loop ::
 _bhv_white_puff_2_loop :: _bhv_white_puff_1_loop ::
 _bhv_sunken_ship_part_loop :: _bhv_ship_part_3_loop ::
 _bhv_jrb_sliding_box_loop :: _bhv_sushi_shark_collision_loop ::
 _bhv_sushi_shark_loop :: _bhv_bowsers_sub_loop :: _bhv_sound_spawner_init ::
 _bhv_rotating_exclamation_box_loop :: _bhv_exclamation_box_loop ::
 _bhv_bub_loop :: _bhv_bub_spawner_loop :: _bhv_wdw_express_elevator_loop ::
 _bhv_fish_loop :: _bhv_fish_spawner_loop :: _bhv_small_penguin_loop ::
 _bhv_tuxies_mother_loop :: _bhv_lll_bowser_puzzle_loop ::
 _bhv_lll_bowser_puzzle_piece_loop :: _bhv_piranha_plant_loop ::
 _bhv_tox_box_loop :: _bhv_koopa_shell_flame_loop :: _bhv_koopa_shell_loop ::
 _bhv_lll_sinking_square_platforms_loop ::
 _bhv_lll_sinking_rectangular_platform_loop ::
 _bhv_lll_rotating_hexagonal_ring_loop :: _bhv_volcano_flames_loop ::
 _bhv_lll_floating_wood_bridge_loop :: _bhv_lll_wood_piece_loop ::
 _bhv_lll_rotating_hex_flame_loop ::
 _bhv_lll_rotating_block_fire_bars_loop ::
 _bhv_lll_moving_octagonal_mesh_platform_loop ::
 _bhv_lll_sinking_rock_block_loop :: _bhv_ukiki_loop :: _bhv_ukiki_init ::
 _bhv_rotating_clock_arm_loop :: _bhv_moat_grills_loop ::
 _bhv_ddd_warp_loop :: _bhv_water_level_pillar_loop ::
 _bhv_water_level_pillar_init :: _bhv_invisible_objects_under_bridge_init ::
 _bhv_bowser_key_course_exit_loop :: _bhv_bowser_key_unlock_door_loop ::
 _bhv_checkerboard_platform_loop :: _bhv_checkerboard_platform_init ::
 _bhv_checkerboard_elevator_group_init :: _bhv_tank_fish_group_loop ::
 _bhv_blue_fish_movement_loop :: _bhv_flame_large_burning_out_init ::
 _bhv_flame_bowser_loop :: _bhv_flame_bowser_init ::
 _bhv_flame_moving_forward_growing_loop ::
 _bhv_flame_moving_forward_growing_init :: _bhv_flame_bouncing_loop ::
 _bhv_flame_bouncing_init :: _bhv_blue_flames_group_loop ::
 _bhv_flame_floating_landing_loop :: _bhv_flame_floating_landing_init ::
 _bhv_blue_bowser_flame_loop :: _bhv_blue_bowser_flame_init ::
 _bhv_falling_bowser_platform_loop :: _bhv_bowser_flame_spawn_loop ::
 _bhv_bowser_body_anchor_loop :: _bhv_bowser_loop :: _bhv_bowser_init ::
 _bhv_bowser_tail_anchor_loop :: _bhv_white_puff_smoke_init ::
 _bhv_bullet_bill_loop :: _bhv_bullet_bill_init :: _bhv_alpha_boo_key_loop ::
 _bhv_beta_boo_key_loop :: _bhv_grand_star_loop :: _bhv_bowser_key_loop ::
 _bhv_boo_cage_loop :: _bhv_jumping_box_loop ::
 _bhv_beta_trampoline_spring_loop :: _bhv_beta_trampoline_top_loop ::
 _bhv_unused_poundable_platform :: _bhv_ccm_touched_star_spawn_loop ::
 _bhv_heave_ho_throw_mario_loop :: _bhv_heave_ho_loop ::
 _bhv_squarish_path_moving_loop :: _bhv_yellow_coin_loop ::
 _bhv_yellow_coin_init :: _bhv_small_water_wave_loop :: _bhv_init_room ::
 _bhv_pushable_loop :: _bhv_breakable_box_loop :: _bhv_hidden_object_loop ::
 _bhv_purple_switch_loop :: _bhv_piranha_plant_waking_bubbles_loop ::
 _bhv_piranha_plant_bubble_loop :: _bhv_tree_snow_or_leaf_loop ::
 _bhv_snow_leaf_particle_spawn_init :: _bhv_wf_solid_tower_platform_loop ::
 _bhv_wf_elevator_tower_platform_loop ::
 _bhv_wf_sliding_tower_platform_loop :: _bhv_tower_platform_group_loop ::
 _bhv_spindrift_loop :: _bhv_beta_fish_splash_spawner_loop ::
 _bhv_black_smoke_upward_loop :: _bhv_black_smoke_bowser_loop ::
 _bhv_black_smoke_mario_loop :: _bhv_flame_mario_loop ::
 _bhv_bowser_shock_wave_loop :: _bhv_bouncing_fireball_flame_loop ::
 _bhv_bouncing_fireball_loop :: _bhv_flamethrower_flame_loop ::
 _bhv_flamethrower_loop :: _bhv_rr_rotating_bridge_platform_loop ::
 _bhv_beta_moving_flames_loop :: _bhv_beta_moving_flames_spawn_loop ::
 _bhv_squishable_platform_loop :: _bhv_tilting_inverted_pyramid_loop ::
 _bhv_platform_normals_init :: _bhv_ddd_moving_pole_loop ::
 _bhv_bitfs_sinking_cage_platform_loop :: _bhv_bitfs_sinking_platform_loop ::
 _bhv_ukiki_cage_loop :: _bhv_ukiki_cage_star_loop ::
 _bhv_unused_particle_spawn_loop :: _bhv_wind_loop ::
 _bhv_ground_snow_init :: _bhv_ground_sand_init ::
 _bhv_pound_white_puffs_init :: _bhv_water_mist_2_loop ::
 _bhv_water_mist_spawn_loop :: _bhv_water_mist_loop :: _bhv_elevator_loop ::
 _bhv_elevator_init :: _bhv_tumbling_bridge_loop ::
 _bhv_tumbling_bridge_platform_loop :: _bhv_punch_tiny_triangle_init ::
 _bhv_punch_tiny_triangle_loop :: _bhv_pound_tiny_star_particle_init ::
 _bhv_pound_tiny_star_particle_loop :: _bhv_wall_tiny_star_particle_loop ::
 _bhv_golden_coin_sparkles_loop :: _bhv_coin_sparkles_loop ::
 _bhv_temp_coin_loop :: _bhv_coin_formation_loop ::
 _bhv_coin_formation_spawn_loop :: _bhv_coin_formation_init ::
 _bhv_coin_inside_boo_loop :: _bhv_spawned_coin_loop ::
 _bhv_spawned_coin_init :: _bhv_spawned_star_loop ::
 _bhv_spawned_star_init :: _bhv_white_puff_exploding_loop ::
 _bhv_warp_loop :: _bhv_fading_warp_loop ::
 _bhv_koopa_shell_underwater_loop :: _bhv_wf_rotating_wooden_platform_loop ::
 _bhv_tower_door_loop :: _bhv_kickable_board_loop ::
 _bhv_wf_breakable_wall_loop :: _bhv_rotating_platform_loop ::
 _bhv_chuckya_anchor_mario_loop :: _bhv_chuckya_loop ::
 _bhv_cannon_base_unused_loop :: _bhv_cannon_barrel_loop ::
 _bhv_cannon_base_loop :: _bhv_fish_group_loop :: _bhv_small_bubbles_loop ::
 _bhv_water_waves_init :: _bhv_particle_loop :: _bhv_particle_init ::
 _bhv_water_air_bubble_loop :: _bhv_water_air_bubble_init ::
 _bhv_bubble_maybe_loop :: _bhv_bubble_wave_init ::
 _bhv_beta_chest_lid_loop :: _bhv_beta_chest_bottom_loop ::
 _bhv_beta_chest_bottom_init :: _bhv_bobomb_anchor_mario_loop ::
 _bhv_king_bobomb_loop :: _bhv_thi_tiny_island_top_loop ::
 _bhv_thi_huge_island_top_loop :: _bhv_pole_base_loop :: _bhv_pole_init ::
 _bhv_giant_pole_loop :: _bhv_piranha_particle_loop ::
 _bhv_mr_i_particle_loop :: _bhv_mr_i_body_loop :: _bhv_mr_i_loop ::
 _bhv_star_door_loop :: _bhv_door_loop :: _bhv_door_init ::
 _bhv_grindel_thwomp_loop :: _bhv_tiny_star_particles_init ::
 _bhv_cap_switch_loop :: _bhv_star_door_loop_2 :: _bhv_mario_update ::
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


