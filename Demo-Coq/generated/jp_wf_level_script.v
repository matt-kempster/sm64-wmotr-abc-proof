(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_JP
   Source:          levels/wf/script.c
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_JP=1 -DF3D_OLD=1
   Link hygiene:    private __stringlit_N atoms prefixed with jp_wf_level_script
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
  Definition source_file := "build/pinned-sm64/levels/wf/script.c".
  Definition normalized := true.
End Info.

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
Definition __cloud_floor_skybox_mio0SegmentRomEnd : ident := $"_cloud_floor_skybox_mio0SegmentRomEnd".
Definition __cloud_floor_skybox_mio0SegmentRomStart : ident := $"_cloud_floor_skybox_mio0SegmentRomStart".
Definition __common0_geoSegmentRomEnd : ident := $"_common0_geoSegmentRomEnd".
Definition __common0_geoSegmentRomStart : ident := $"_common0_geoSegmentRomStart".
Definition __common0_mio0SegmentRomEnd : ident := $"_common0_mio0SegmentRomEnd".
Definition __common0_mio0SegmentRomStart : ident := $"_common0_mio0SegmentRomStart".
Definition __grass_mio0SegmentRomEnd : ident := $"_grass_mio0SegmentRomEnd".
Definition __grass_mio0SegmentRomStart : ident := $"_grass_mio0SegmentRomStart".
Definition __group14_geoSegmentRomEnd : ident := $"_group14_geoSegmentRomEnd".
Definition __group14_geoSegmentRomStart : ident := $"_group14_geoSegmentRomStart".
Definition __group14_mio0SegmentRomEnd : ident := $"_group14_mio0SegmentRomEnd".
Definition __group14_mio0SegmentRomStart : ident := $"_group14_mio0SegmentRomStart".
Definition __group1_geoSegmentRomEnd : ident := $"_group1_geoSegmentRomEnd".
Definition __group1_geoSegmentRomStart : ident := $"_group1_geoSegmentRomStart".
Definition __group1_mio0SegmentRomEnd : ident := $"_group1_mio0SegmentRomEnd".
Definition __group1_mio0SegmentRomStart : ident := $"_group1_mio0SegmentRomStart".
Definition __wf_segment_7SegmentRomEnd : ident := $"_wf_segment_7SegmentRomEnd".
Definition __wf_segment_7SegmentRomStart : ident := $"_wf_segment_7SegmentRomStart".
Definition _bhv1Up : ident := $"bhv1Up".
Definition _bhvBetaFishSplashSpawner : ident := $"bhvBetaFishSplashSpawner".
Definition _bhvBobombBuddyOpensCannon : ident := $"bhvBobombBuddyOpensCannon".
Definition _bhvBulletBill : ident := $"bhvBulletBill".
Definition _bhvBulletBillCannon : ident := $"bhvBulletBillCannon".
Definition _bhvButterfly : ident := $"bhvButterfly".
Definition _bhvCheckerboardElevatorGroup : ident := $"bhvCheckerboardElevatorGroup".
Definition _bhvFadingWarp : ident := $"bhvFadingWarp".
Definition _bhvGiantPole : ident := $"bhvGiantPole".
Definition _bhvHiddenRedCoinStar : ident := $"bhvHiddenRedCoinStar".
Definition _bhvHoot : ident := $"bhvHoot".
Definition _bhvKickableBoard : ident := $"bhvKickableBoard".
Definition _bhvLargeBomp : ident := $"bhvLargeBomp".
Definition _bhvMario : ident := $"bhvMario".
Definition _bhvPiranhaPlant : ident := $"bhvPiranhaPlant".
Definition _bhvPoleGrabbing : ident := $"bhvPoleGrabbing".
Definition _bhvRotatingPlatform : ident := $"bhvRotatingPlatform".
Definition _bhvSmallBomp : ident := $"bhvSmallBomp".
Definition _bhvSmallWhomp : ident := $"bhvSmallWhomp".
Definition _bhvSpinAirborneWarp : ident := $"bhvSpinAirborneWarp".
Definition _bhvStar : ident := $"bhvStar".
Definition _bhvStaticObject : ident := $"bhvStaticObject".
Definition _bhvThwomp : ident := $"bhvThwomp".
Definition _bhvThwomp2 : ident := $"bhvThwomp2".
Definition _bhvTower : ident := $"bhvTower".
Definition _bhvTowerDoor : ident := $"bhvTowerDoor".
Definition _bhvTowerPlatformGroup : ident := $"bhvTowerPlatformGroup".
Definition _bhvTumblingBridge : ident := $"bhvTumblingBridge".
Definition _bhvWFBreakableWallLeft : ident := $"bhvWFBreakableWallLeft".
Definition _bhvWFBreakableWallRight : ident := $"bhvWFBreakableWallRight".
Definition _bhvWFRotatingWoodenPlatform : ident := $"bhvWFRotatingWoodenPlatform".
Definition _bhvWFSlidingPlatform : ident := $"bhvWFSlidingPlatform".
Definition _bhvWhompKingBoss : ident := $"bhvWhompKingBoss".
Definition _bubbly_tree_geo : ident := $"bubbly_tree_geo".
Definition _level_wf_entry : ident := $"level_wf_entry".
Definition _lvl_init_or_update : ident := $"lvl_init_or_update".
Definition _main : ident := $"main".
Definition _script_func_global_1 : ident := $"script_func_global_1".
Definition _script_func_global_15 : ident := $"script_func_global_15".
Definition _script_func_global_2 : ident := $"script_func_global_2".
Definition _script_func_local_1 : ident := $"script_func_local_1".
Definition _script_func_local_2 : ident := $"script_func_local_2".
Definition _script_func_local_3 : ident := $"script_func_local_3".
Definition _script_func_local_4 : ident := $"script_func_local_4".
Definition _wf_geo_0007E0 : ident := $"wf_geo_0007E0".
Definition _wf_geo_000820 : ident := $"wf_geo_000820".
Definition _wf_geo_000860 : ident := $"wf_geo_000860".
Definition _wf_geo_000878 : ident := $"wf_geo_000878".
Definition _wf_geo_000890 : ident := $"wf_geo_000890".
Definition _wf_geo_0008A8 : ident := $"wf_geo_0008A8".
Definition _wf_geo_0008E8 : ident := $"wf_geo_0008E8".
Definition _wf_geo_000900 : ident := $"wf_geo_000900".
Definition _wf_geo_000940 : ident := $"wf_geo_000940".
Definition _wf_geo_000958 : ident := $"wf_geo_000958".
Definition _wf_geo_0009A0 : ident := $"wf_geo_0009A0".
Definition _wf_geo_0009B8 : ident := $"wf_geo_0009B8".
Definition _wf_geo_0009D0 : ident := $"wf_geo_0009D0".
Definition _wf_geo_0009E8 : ident := $"wf_geo_0009E8".
Definition _wf_geo_000A00 : ident := $"wf_geo_000A00".
Definition _wf_geo_000A40 : ident := $"wf_geo_000A40".
Definition _wf_geo_000A58 : ident := $"wf_geo_000A58".
Definition _wf_geo_000A98 : ident := $"wf_geo_000A98".
Definition _wf_geo_000AB0 : ident := $"wf_geo_000AB0".
Definition _wf_geo_000AC8 : ident := $"wf_geo_000AC8".
Definition _wf_geo_000AE0 : ident := $"wf_geo_000AE0".
Definition _wf_geo_000AF8 : ident := $"wf_geo_000AF8".
Definition _wf_geo_000B10 : ident := $"wf_geo_000B10".
Definition _wf_geo_000B38 : ident := $"wf_geo_000B38".
Definition _wf_geo_000B60 : ident := $"wf_geo_000B60".
Definition _wf_geo_000B78 : ident := $"wf_geo_000B78".
Definition _wf_geo_000B90 : ident := $"wf_geo_000B90".
Definition _wf_geo_000BA8 : ident := $"wf_geo_000BA8".
Definition _wf_geo_000BC8 : ident := $"wf_geo_000BC8".
Definition _wf_geo_000BE0 : ident := $"wf_geo_000BE0".
Definition _wf_geo_000BF8 : ident := $"wf_geo_000BF8".
Definition _wf_seg7_collision_070102D8 : ident := $"wf_seg7_collision_070102D8".
Definition _wf_seg7_macro_objs : ident := $"wf_seg7_macro_objs".

Definition v_bhvGiantPole := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvPoleGrabbing := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvRotatingPlatform := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvTower := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBulletBillCannon := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvWFBreakableWallRight := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvWFBreakableWallLeft := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvKickableBoard := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvTowerDoor := {|
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

Definition v_bhvFadingWarp := {|
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

Definition v_bhvThwomp2 := {|
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

Definition v_bhvBetaFishSplashSpawner := {|
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

Definition v_bhvBulletBill := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvCheckerboardElevatorGroup := {|
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

Definition v_bhvStaticObject := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvWhompKingBoss := {|
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

Definition v_bhvMario := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSpinAirborneWarp := {|
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

Definition v_bhvButterfly := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvHoot := {|
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

Definition v_bhvStar := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvHiddenRedCoinStar := {|
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

Definition v__common0_mio0SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__common0_mio0SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__common0_geoSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__common0_geoSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group1_mio0SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group1_mio0SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group1_geoSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group1_geoSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group14_mio0SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group14_mio0SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group14_geoSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group14_geoSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__wf_segment_7SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__wf_segment_7SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__cloud_floor_skybox_mio0SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__cloud_floor_skybox_mio0SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__grass_mio0SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__grass_mio0SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_global_1 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_script_func_global_2 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_script_func_global_15 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bubbly_tree_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_wf_geo_0007E0 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000820 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000860 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000878 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000890 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_0008A8 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_0008E8 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000900 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000940 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000958 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_0009A0 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_0009B8 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_0009D0 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_0009E8 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000A00 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000A40 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000A58 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000A98 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000AB0 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000AC8 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000AE0 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000AF8 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000B10 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000B38 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000B60 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000B78 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000B90 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000BA8 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000BC8 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000BE0 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_geo_000BF8 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_seg7_collision_070102D8 := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wf_seg7_macro_objs := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_local_1 := {|
  gvar_info := (tarray tuint 55);
  gvar_init := (Init_int32 (Int.repr 605560579) ::
                Init_int32 (Int.repr 151062912) ::
                Init_int32 (Int.repr (-16711680)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560580) ::
                Init_int32 (Int.repr 223151744) ::
                Init_int32 (Int.repr (-117374976)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560581) ::
                Init_int32 (Int.repr 251658240) ::
                Init_int32 (Int.repr (-150929408)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560581) ::
                Init_int32 (Int.repr 251658240) ::
                Init_int32 (Int.repr (-83820544)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560582) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560583) ::
                Init_int32 (Int.repr 115150271) ::
                Init_int32 (Int.repr (-206503936)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560586) ::
                Init_int32 (Int.repr 251659034) ::
                Init_int32 (Int.repr 176160768) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560588) ::
                Init_int32 (Int.repr 92277210) ::
                Init_int32 (Int.repr 159318016) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvStaticObject (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560589) ::
                Init_int32 (Int.repr (-167769600)) ::
                Init_int32 (Int.repr (-16777216)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvGiantPole (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_local_2 := {|
  gvar_info := (tarray tuint 97);
  gvar_init := (Init_int32 (Int.repr 605560750) ::
                Init_int32 (Int.repr 216269870) ::
                Init_int32 (Int.repr 65536) ::
                Init_int32 (Int.repr 5898240) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvSmallBomp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560750) ::
                Init_int32 (Int.repr 216269870) ::
                Init_int32 (Int.repr 83951616) ::
                Init_int32 (Int.repr 5898240) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvSmallBomp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560753) ::
                Init_int32 (Int.repr 216269870) ::
                Init_int32 (Int.repr 42008576) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvLargeBomp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560751) ::
                Init_int32 (Int.repr (-16709120)) ::
                Init_int32 (Int.repr 150994944) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvWFRotatingWoodenPlatform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560749) ::
                Init_int32 (Int.repr 218104883) ::
                Init_int32 (Int.repr (-117374976)) ::
                Init_int32 (Int.repr 5898240) ::
                Init_int32 (Int.repr 131072) ::
                Init_addrof _bhvWFSlidingPlatform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560749) ::
                Init_int32 (Int.repr 218104883) ::
                Init_int32 (Int.repr (-50266112)) ::
                Init_int32 (Int.repr 5898240) ::
                Init_int32 (Int.repr 65536) ::
                Init_addrof _bhvWFSlidingPlatform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560749) ::
                Init_int32 (Int.repr 218104883) ::
                Init_int32 (Int.repr (-184483840)) ::
                Init_int32 (Int.repr 5898240) ::
                Init_int32 (Int.repr 196608) ::
                Init_addrof _bhvWFSlidingPlatform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560754) ::
                Init_int32 (Int.repr 117443008) ::
                Init_int32 (Int.repr 104857600) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvTumblingBridge (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560630) ::
                Init_int32 (Int.repr 33556608) ::
                Init_int32 (Int.repr 192937984) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvWFBreakableWallRight (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560631) ::
                Init_int32 (Int.repr (-67041152)) ::
                Init_int32 (Int.repr 192937984) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvWFBreakableWallLeft (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568568) ::
                Init_int32 (Int.repr 855552) ::
                Init_int32 (Int.repr (-92209152)) ::
                Init_int32 (Int.repr 20643840) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvKickableBoard (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568724) ::
                Init_int32 (Int.repr (-25162240)) ::
                Init_int32 (Int.repr 393216) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhv1Up (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560592) ::
                Init_int32 (Int.repr 150998528) ::
                Init_int32 (Int.repr (-150929408)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 134217728) ::
                Init_addrof _bhvRotatingPlatform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560592) ::
                Init_int32 (Int.repr 209718528) ::
                Init_int32 (Int.repr (-117374976)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 134217728) ::
                Init_addrof _bhvRotatingPlatform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560592) ::
                Init_int32 (Int.repr 176164352) ::
                Init_int32 (Int.repr (-58654720)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 134217728) ::
                Init_addrof _bhvRotatingPlatform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr (-163510989)) ::
                Init_int32 (Int.repr (-16777216)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 3997696) ::
                Init_addrof _bhvPoleGrabbing (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_local_3 := {|
  gvar_info := (tarray tuint 157);
  gvar_init := (Init_int32 (Int.repr 605560664) ::
                Init_int32 (Int.repr 226887571) ::
                Init_int32 (Int.repr (-101253120)) ::
                Init_int32 (Int.repr 11796480) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvThwomp2 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560664) ::
                Init_int32 (Int.repr 226886707) ::
                Init_int32 (Int.repr (-217186304)) ::
                Init_int32 (Int.repr 5898240) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvThwomp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr (-56097894)) ::
                Init_int32 (Int.repr 250281984) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvBetaFishSplashSpawner (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560676) ::
                Init_int32 (Int.repr 119409152) ::
                Init_int32 (Int.repr (-6619136)) ::
                Init_int32 (Int.repr 5898240) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvPiranhaPlant (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560676) ::
                Init_int32 (Int.repr 303104256) ::
                Init_int32 (Int.repr 328794112) ::
                Init_int32 (Int.repr (-5898240)) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvPiranhaPlant (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560676) ::
                Init_int32 (Int.repr 45156864) ::
                Init_int32 (Int.repr 120913920) ::
                Init_int32 (Int.repr 5898240) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvPiranhaPlant (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560679) ::
                Init_int32 (Int.repr (-101250560)) ::
                Init_int32 (Int.repr (-18743296)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvSmallWhomp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560679) ::
                Init_int32 (Int.repr 12388864) ::
                Init_int32 (Int.repr (-121700352)) ::
                Init_int32 (Int.repr (-8847360)) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvSmallWhomp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560763) ::
                Init_int32 (Int.repr 310378752) ::
                Init_int32 (Int.repr 327155712) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvButterfly (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560763) ::
                Init_int32 (Int.repr 301990144) ::
                Init_int32 (Int.repr 335544320) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvButterfly (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560763) ::
                Init_int32 (Int.repr 301990144) ::
                Init_int32 (Int.repr 327155712) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvButterfly (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560763) ::
                Init_int32 (Int.repr 301990144) ::
                Init_int32 (Int.repr 318767104) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvButterfly (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560763) ::
                Init_int32 (Int.repr 293601536) ::
                Init_int32 (Int.repr 327155712) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvButterfly (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560763) ::
                Init_int32 (Int.repr 301990144) ::
                Init_int32 (Int.repr 16777216) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvButterfly (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560763) ::
                Init_int32 (Int.repr 310378752) ::
                Init_int32 (Int.repr 8388608) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvButterfly (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560763) ::
                Init_int32 (Int.repr 293601536) ::
                Init_int32 (Int.repr 8388608) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvButterfly (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560763) ::
                Init_int32 (Int.repr 301990144) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvButterfly (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560763) ::
                Init_int32 (Int.repr 301990144) ::
                Init_int32 (Int.repr 8388608) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvButterfly (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 67832640) ::
                Init_int32 (Int.repr (-58982400)) ::
                Init_int32 (Int.repr 2949120) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvCheckerboardElevatorGroup (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568596) ::
                Init_int32 (Int.repr 83889792) ::
                Init_int32 (Int.repr 63438848) ::
                Init_int32 (Int.repr 11796480) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvBulletBill (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568520) ::
                Init_int32 (Int.repr 3584) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvTower (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568521) ::
                Init_int32 (Int.repr 83889664) ::
                Init_int32 (Int.repr 58720256) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvBulletBillCannon (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568512) ::
                Init_int32 (Int.repr 3483) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvTowerPlatformGroup (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568569) ::
                Init_int32 (Int.repr (-33485312)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvTowerDoor (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568195) ::
                Init_int32 (Int.repr (-111410060)) ::
                Init_int32 (Int.repr 229376000) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvBobombBuddyOpensCannon (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568086) ::
                Init_int32 (Int.repr 167772860) ::
                Init_int32 (Int.repr 301989888) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvHoot (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_local_4 := {|
  gvar_info := (tarray tuint 37);
  gvar_init := (Init_int32 (Int.repr 605552999) ::
                Init_int32 (Int.repr 3584) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvWhompKingBoss (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568634) ::
                Init_int32 (Int.repr 19666350) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 16777216) ::
                Init_addrof _bhvStar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568890) ::
                Init_int32 (Int.repr (-163838500)) ::
                Init_int32 (Int.repr (-49152000)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 33554432) ::
                Init_addrof _bhvStar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568768) ::
                Init_int32 (Int.repr 301466150) ::
                Init_int32 (Int.repr 163840000) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 50331648) ::
                Init_addrof _bhvHiddenRedCoinStar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568890) ::
                Init_int32 (Int.repr 188747980) ::
                Init_int32 (Int.repr 12451840) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 67108864) ::
                Init_addrof _bhvStar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568890) ::
                Init_int32 (Int.repr 38668690) ::
                Init_int32 (Int.repr 173670400) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 83886080) ::
                Init_addrof _bhvStar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_wf_entry := {|
  gvar_info := (tarray tuint 158);
  gvar_init := (Init_int32 (Int.repr 453246976) ::
                Init_int32 (Int.repr 403439623) ::
                Init_addrof __wf_segment_7SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __wf_segment_7SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 403439626) ::
                Init_addrof __cloud_floor_skybox_mio0SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __cloud_floor_skybox_mio0SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 436994057) ::
                Init_addrof __grass_mio0SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __grass_mio0SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 403439621) ::
                Init_addrof __group1_mio0SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __group1_mio0SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 386662412) ::
                Init_addrof __group1_geoSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __group1_geoSegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 403439622) ::
                Init_addrof __group14_mio0SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __group14_mio0SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 386662413) ::
                Init_addrof __group14_geoSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __group14_geoSegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 403439624) ::
                Init_addrof __common0_mio0SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __common0_mio0SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 386662415) ::
                Init_addrof __common0_geoSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __common0_geoSegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 486801408) ::
                Init_int32 (Int.repr 621543425) :: Init_int32 (Int.repr 1) ::
                Init_addrof _bhvMario (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_global_1 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_global_2 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_global_15 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949655) ::
                Init_addrof _bubbly_tree_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949635) ::
                Init_addrof _wf_geo_0007E0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949636) ::
                Init_addrof _wf_geo_000820 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949637) ::
                Init_addrof _wf_geo_000860 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949638) ::
                Init_addrof _wf_geo_000878 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949639) ::
                Init_addrof _wf_geo_000890 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949640) ::
                Init_addrof _wf_geo_0008A8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949641) ::
                Init_addrof _wf_geo_0008E8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949642) ::
                Init_addrof _wf_geo_000900 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949644) ::
                Init_addrof _wf_geo_000940 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949645) ::
                Init_addrof _wf_geo_000AE0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949646) ::
                Init_addrof _wf_geo_000958 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949647) ::
                Init_addrof _wf_geo_0009A0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949648) ::
                Init_addrof _wf_geo_0009B8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949649) ::
                Init_addrof _wf_geo_0009D0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949650) ::
                Init_addrof _wf_geo_0009E8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949806) ::
                Init_addrof _wf_geo_000A00 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949809) ::
                Init_addrof _wf_geo_000A40 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949807) ::
                Init_addrof _wf_geo_000A58 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949805) ::
                Init_addrof _wf_geo_000A98 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949808) ::
                Init_addrof _wf_geo_000AB0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949810) ::
                Init_addrof _wf_geo_000AC8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949676) ::
                Init_addrof _wf_geo_000AF8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949677) ::
                Init_addrof _wf_geo_000B10 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949678) ::
                Init_addrof _wf_geo_000B38 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949679) ::
                Init_addrof _wf_geo_000B60 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949686) ::
                Init_addrof _wf_geo_000B78 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949687) ::
                Init_addrof _wf_geo_000B90 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949688) ::
                Init_addrof _wf_geo_000BA8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949689) ::
                Init_addrof _wf_geo_000BE0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949690) ::
                Init_addrof _wf_geo_000BC8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 520618240) ::
                Init_addrof _wf_geo_000BF8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 170394856) ::
                Init_int32 (Int.repr 335544320) ::
                Init_int32 (Int.repr 5898240) ::
                Init_int32 (Int.repr 655360) ::
                Init_addrof _bhvSpinAirborneWarp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr (-191690240)) ::
                Init_int32 (Int.repr (-62062592)) ::
                Init_int32 (Int.repr 1245184) ::
                Init_int32 (Int.repr 720896) ::
                Init_addrof _bhvFadingWarp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 166986803) ::
                Init_int32 (Int.repr (-259653632)) ::
                Init_int32 (Int.repr 3342336) ::
                Init_int32 (Int.repr 786432) ::
                Init_addrof _bhvFadingWarp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 638061080) ::
                Init_int32 (Int.repr 17432576) ::
                Init_int32 (Int.repr 638061336) ::
                Init_int32 (Int.repr 17563648) ::
                Init_int32 (Int.repr 638061592) ::
                Init_int32 (Int.repr 17498112) ::
                Init_int32 (Int.repr 638119942) ::
                Init_int32 (Int.repr 20185088) ::
                Init_int32 (Int.repr 638120198) ::
                Init_int32 (Int.repr 23461888) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_local_1 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_local_2 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_local_3 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_local_4 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 772276224) ::
                Init_addrof _wf_seg7_collision_070102D8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 956825600) ::
                Init_addrof _wf_seg7_macro_objs (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 805568542) ::
                Init_int32 (Int.repr 906493957) ::
                Init_int32 (Int.repr 196608) ::
                Init_int32 (Int.repr 822345729) ::
                Init_int32 (Int.repr 537133056) ::
                Init_int32 (Int.repr 503578624) ::
                Init_int32 (Int.repr 722206976) ::
                Init_int32 (Int.repr 5900840) ::
                Init_int32 (Int.repr 16782336) ::
                Init_int32 (Int.repr 285736960) ::
                Init_addrof _lvl_init_or_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 302514177) ::
                Init_addrof _lvl_init_or_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 470024192) ::
                Init_int32 (Int.repr 67371009) ::
                Init_int32 (Int.repr 33816576) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition composites : list composite_definition :=
nil.

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
 (_bhvGiantPole, Gvar v_bhvGiantPole) ::
 (_bhvPoleGrabbing, Gvar v_bhvPoleGrabbing) ::
 (_bhvRotatingPlatform, Gvar v_bhvRotatingPlatform) ::
 (_bhvTower, Gvar v_bhvTower) ::
 (_bhvBulletBillCannon, Gvar v_bhvBulletBillCannon) ::
 (_bhvWFBreakableWallRight, Gvar v_bhvWFBreakableWallRight) ::
 (_bhvWFBreakableWallLeft, Gvar v_bhvWFBreakableWallLeft) ::
 (_bhvKickableBoard, Gvar v_bhvKickableBoard) ::
 (_bhvTowerDoor, Gvar v_bhvTowerDoor) ::
 (_bhvWFRotatingWoodenPlatform, Gvar v_bhvWFRotatingWoodenPlatform) ::
 (_bhvFadingWarp, Gvar v_bhvFadingWarp) :: (_bhvThwomp, Gvar v_bhvThwomp) ::
 (_bhvThwomp2, Gvar v_bhvThwomp2) ::
 (_bhvTumblingBridge, Gvar v_bhvTumblingBridge) ::
 (_bhvBetaFishSplashSpawner, Gvar v_bhvBetaFishSplashSpawner) ::
 (_bhvTowerPlatformGroup, Gvar v_bhvTowerPlatformGroup) ::
 (_bhvBulletBill, Gvar v_bhvBulletBill) ::
 (_bhvCheckerboardElevatorGroup, Gvar v_bhvCheckerboardElevatorGroup) ::
 (_bhvPiranhaPlant, Gvar v_bhvPiranhaPlant) ::
 (_bhvStaticObject, Gvar v_bhvStaticObject) ::
 (_bhvWhompKingBoss, Gvar v_bhvWhompKingBoss) ::
 (_bhvSmallWhomp, Gvar v_bhvSmallWhomp) :: (_bhvMario, Gvar v_bhvMario) ::
 (_bhvSpinAirborneWarp, Gvar v_bhvSpinAirborneWarp) ::
 (_bhvBobombBuddyOpensCannon, Gvar v_bhvBobombBuddyOpensCannon) ::
 (_bhvButterfly, Gvar v_bhvButterfly) :: (_bhvHoot, Gvar v_bhvHoot) ::
 (_bhvSmallBomp, Gvar v_bhvSmallBomp) ::
 (_bhvLargeBomp, Gvar v_bhvLargeBomp) ::
 (_bhvWFSlidingPlatform, Gvar v_bhvWFSlidingPlatform) ::
 (_bhvStar, Gvar v_bhvStar) ::
 (_bhvHiddenRedCoinStar, Gvar v_bhvHiddenRedCoinStar) ::
 (_bhv1Up, Gvar v_bhv1Up) ::
 (__common0_mio0SegmentRomStart, Gvar v__common0_mio0SegmentRomStart) ::
 (__common0_mio0SegmentRomEnd, Gvar v__common0_mio0SegmentRomEnd) ::
 (__common0_geoSegmentRomStart, Gvar v__common0_geoSegmentRomStart) ::
 (__common0_geoSegmentRomEnd, Gvar v__common0_geoSegmentRomEnd) ::
 (__group1_mio0SegmentRomStart, Gvar v__group1_mio0SegmentRomStart) ::
 (__group1_mio0SegmentRomEnd, Gvar v__group1_mio0SegmentRomEnd) ::
 (__group1_geoSegmentRomStart, Gvar v__group1_geoSegmentRomStart) ::
 (__group1_geoSegmentRomEnd, Gvar v__group1_geoSegmentRomEnd) ::
 (__group14_mio0SegmentRomStart, Gvar v__group14_mio0SegmentRomStart) ::
 (__group14_mio0SegmentRomEnd, Gvar v__group14_mio0SegmentRomEnd) ::
 (__group14_geoSegmentRomStart, Gvar v__group14_geoSegmentRomStart) ::
 (__group14_geoSegmentRomEnd, Gvar v__group14_geoSegmentRomEnd) ::
 (__wf_segment_7SegmentRomStart, Gvar v__wf_segment_7SegmentRomStart) ::
 (__wf_segment_7SegmentRomEnd, Gvar v__wf_segment_7SegmentRomEnd) ::
 (__cloud_floor_skybox_mio0SegmentRomStart, Gvar v__cloud_floor_skybox_mio0SegmentRomStart) ::
 (__cloud_floor_skybox_mio0SegmentRomEnd, Gvar v__cloud_floor_skybox_mio0SegmentRomEnd) ::
 (__grass_mio0SegmentRomStart, Gvar v__grass_mio0SegmentRomStart) ::
 (__grass_mio0SegmentRomEnd, Gvar v__grass_mio0SegmentRomEnd) ::
 (_lvl_init_or_update,
   Gfun(External (EF_external "lvl_init_or_update"
                   (mksignature (AST.Xint16signed :: AST.Xint :: nil)
                     AST.Xint cc_default)) (tshort :: tint :: nil) tint
     cc_default)) :: (_script_func_global_1, Gvar v_script_func_global_1) ::
 (_script_func_global_2, Gvar v_script_func_global_2) ::
 (_script_func_global_15, Gvar v_script_func_global_15) ::
 (_bubbly_tree_geo, Gvar v_bubbly_tree_geo) ::
 (_wf_geo_0007E0, Gvar v_wf_geo_0007E0) ::
 (_wf_geo_000820, Gvar v_wf_geo_000820) ::
 (_wf_geo_000860, Gvar v_wf_geo_000860) ::
 (_wf_geo_000878, Gvar v_wf_geo_000878) ::
 (_wf_geo_000890, Gvar v_wf_geo_000890) ::
 (_wf_geo_0008A8, Gvar v_wf_geo_0008A8) ::
 (_wf_geo_0008E8, Gvar v_wf_geo_0008E8) ::
 (_wf_geo_000900, Gvar v_wf_geo_000900) ::
 (_wf_geo_000940, Gvar v_wf_geo_000940) ::
 (_wf_geo_000958, Gvar v_wf_geo_000958) ::
 (_wf_geo_0009A0, Gvar v_wf_geo_0009A0) ::
 (_wf_geo_0009B8, Gvar v_wf_geo_0009B8) ::
 (_wf_geo_0009D0, Gvar v_wf_geo_0009D0) ::
 (_wf_geo_0009E8, Gvar v_wf_geo_0009E8) ::
 (_wf_geo_000A00, Gvar v_wf_geo_000A00) ::
 (_wf_geo_000A40, Gvar v_wf_geo_000A40) ::
 (_wf_geo_000A58, Gvar v_wf_geo_000A58) ::
 (_wf_geo_000A98, Gvar v_wf_geo_000A98) ::
 (_wf_geo_000AB0, Gvar v_wf_geo_000AB0) ::
 (_wf_geo_000AC8, Gvar v_wf_geo_000AC8) ::
 (_wf_geo_000AE0, Gvar v_wf_geo_000AE0) ::
 (_wf_geo_000AF8, Gvar v_wf_geo_000AF8) ::
 (_wf_geo_000B10, Gvar v_wf_geo_000B10) ::
 (_wf_geo_000B38, Gvar v_wf_geo_000B38) ::
 (_wf_geo_000B60, Gvar v_wf_geo_000B60) ::
 (_wf_geo_000B78, Gvar v_wf_geo_000B78) ::
 (_wf_geo_000B90, Gvar v_wf_geo_000B90) ::
 (_wf_geo_000BA8, Gvar v_wf_geo_000BA8) ::
 (_wf_geo_000BC8, Gvar v_wf_geo_000BC8) ::
 (_wf_geo_000BE0, Gvar v_wf_geo_000BE0) ::
 (_wf_geo_000BF8, Gvar v_wf_geo_000BF8) ::
 (_wf_seg7_collision_070102D8, Gvar v_wf_seg7_collision_070102D8) ::
 (_wf_seg7_macro_objs, Gvar v_wf_seg7_macro_objs) ::
 (_script_func_local_1, Gvar v_script_func_local_1) ::
 (_script_func_local_2, Gvar v_script_func_local_2) ::
 (_script_func_local_3, Gvar v_script_func_local_3) ::
 (_script_func_local_4, Gvar v_script_func_local_4) ::
 (_level_wf_entry, Gvar v_level_wf_entry) :: nil).

Definition public_idents : list ident :=
(_level_wf_entry :: _wf_seg7_macro_objs :: _wf_seg7_collision_070102D8 ::
 _wf_geo_000BF8 :: _wf_geo_000BE0 :: _wf_geo_000BC8 :: _wf_geo_000BA8 ::
 _wf_geo_000B90 :: _wf_geo_000B78 :: _wf_geo_000B60 :: _wf_geo_000B38 ::
 _wf_geo_000B10 :: _wf_geo_000AF8 :: _wf_geo_000AE0 :: _wf_geo_000AC8 ::
 _wf_geo_000AB0 :: _wf_geo_000A98 :: _wf_geo_000A58 :: _wf_geo_000A40 ::
 _wf_geo_000A00 :: _wf_geo_0009E8 :: _wf_geo_0009D0 :: _wf_geo_0009B8 ::
 _wf_geo_0009A0 :: _wf_geo_000958 :: _wf_geo_000940 :: _wf_geo_000900 ::
 _wf_geo_0008E8 :: _wf_geo_0008A8 :: _wf_geo_000890 :: _wf_geo_000878 ::
 _wf_geo_000860 :: _wf_geo_000820 :: _wf_geo_0007E0 :: _bubbly_tree_geo ::
 _script_func_global_15 :: _script_func_global_2 :: _script_func_global_1 ::
 _lvl_init_or_update :: __grass_mio0SegmentRomEnd ::
 __grass_mio0SegmentRomStart :: __cloud_floor_skybox_mio0SegmentRomEnd ::
 __cloud_floor_skybox_mio0SegmentRomStart :: __wf_segment_7SegmentRomEnd ::
 __wf_segment_7SegmentRomStart :: __group14_geoSegmentRomEnd ::
 __group14_geoSegmentRomStart :: __group14_mio0SegmentRomEnd ::
 __group14_mio0SegmentRomStart :: __group1_geoSegmentRomEnd ::
 __group1_geoSegmentRomStart :: __group1_mio0SegmentRomEnd ::
 __group1_mio0SegmentRomStart :: __common0_geoSegmentRomEnd ::
 __common0_geoSegmentRomStart :: __common0_mio0SegmentRomEnd ::
 __common0_mio0SegmentRomStart :: _bhv1Up :: _bhvHiddenRedCoinStar ::
 _bhvStar :: _bhvWFSlidingPlatform :: _bhvLargeBomp :: _bhvSmallBomp ::
 _bhvHoot :: _bhvButterfly :: _bhvBobombBuddyOpensCannon ::
 _bhvSpinAirborneWarp :: _bhvMario :: _bhvSmallWhomp :: _bhvWhompKingBoss ::
 _bhvStaticObject :: _bhvPiranhaPlant :: _bhvCheckerboardElevatorGroup ::
 _bhvBulletBill :: _bhvTowerPlatformGroup :: _bhvBetaFishSplashSpawner ::
 _bhvTumblingBridge :: _bhvThwomp2 :: _bhvThwomp :: _bhvFadingWarp ::
 _bhvWFRotatingWoodenPlatform :: _bhvTowerDoor :: _bhvKickableBoard ::
 _bhvWFBreakableWallLeft :: _bhvWFBreakableWallRight ::
 _bhvBulletBillCannon :: _bhvTower :: _bhvRotatingPlatform ::
 _bhvPoleGrabbing :: _bhvGiantPole :: ___builtin_debug ::
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
