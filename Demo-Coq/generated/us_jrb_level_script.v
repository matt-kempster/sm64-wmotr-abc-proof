(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_US
   Source:          levels/jrb/script.c
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1
   Link hygiene:    private globals scoped by translation unit jrb_level_script
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
  Definition source_file := "build/pinned-sm64/levels/jrb/script.c".
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
Definition __clouds_skybox_mio0SegmentRomEnd : ident := $"_clouds_skybox_mio0SegmentRomEnd".
Definition __clouds_skybox_mio0SegmentRomStart : ident := $"_clouds_skybox_mio0SegmentRomStart".
Definition __common0_geoSegmentRomEnd : ident := $"_common0_geoSegmentRomEnd".
Definition __common0_geoSegmentRomStart : ident := $"_common0_geoSegmentRomStart".
Definition __common0_mio0SegmentRomEnd : ident := $"_common0_mio0SegmentRomEnd".
Definition __common0_mio0SegmentRomStart : ident := $"_common0_mio0SegmentRomStart".
Definition __effect_mio0SegmentRomEnd : ident := $"_effect_mio0SegmentRomEnd".
Definition __effect_mio0SegmentRomStart : ident := $"_effect_mio0SegmentRomStart".
Definition __group13_geoSegmentRomEnd : ident := $"_group13_geoSegmentRomEnd".
Definition __group13_geoSegmentRomStart : ident := $"_group13_geoSegmentRomStart".
Definition __group13_mio0SegmentRomEnd : ident := $"_group13_mio0SegmentRomEnd".
Definition __group13_mio0SegmentRomStart : ident := $"_group13_mio0SegmentRomStart".
Definition __group4_geoSegmentRomEnd : ident := $"_group4_geoSegmentRomEnd".
Definition __group4_geoSegmentRomStart : ident := $"_group4_geoSegmentRomStart".
Definition __group4_mio0SegmentRomEnd : ident := $"_group4_mio0SegmentRomEnd".
Definition __group4_mio0SegmentRomStart : ident := $"_group4_mio0SegmentRomStart".
Definition __jrb_segment_7SegmentRomEnd : ident := $"_jrb_segment_7SegmentRomEnd".
Definition __jrb_segment_7SegmentRomStart : ident := $"_jrb_segment_7SegmentRomStart".
Definition __water_mio0SegmentRomEnd : ident := $"_water_mio0SegmentRomEnd".
Definition __water_mio0SegmentRomStart : ident := $"_water_mio0SegmentRomStart".
Definition _bhvBobombBuddyOpensCannon : ident := $"bhvBobombBuddyOpensCannon".
Definition _bhvExclamationBox : ident := $"bhvExclamationBox".
Definition _bhvFallingPillar : ident := $"bhvFallingPillar".
Definition _bhvHiddenRedCoinStar : ident := $"bhvHiddenRedCoinStar".
Definition _bhvInSunkenShip : ident := $"bhvInSunkenShip".
Definition _bhvInSunkenShip2 : ident := $"bhvInSunkenShip2".
Definition _bhvInSunkenShip3 : ident := $"bhvInSunkenShip3".
Definition _bhvInsideCannon : ident := $"bhvInsideCannon".
Definition _bhvJRBFloatingPlatform : ident := $"bhvJRBFloatingPlatform".
Definition _bhvJRBSlidingBox : ident := $"bhvJRBSlidingBox".
Definition _bhvJetStream : ident := $"bhvJetStream".
Definition _bhvMario : ident := $"bhvMario".
Definition _bhvPillarBase : ident := $"bhvPillarBase".
Definition _bhvPoleGrabbing : ident := $"bhvPoleGrabbing".
Definition _bhvRockSolid : ident := $"bhvRockSolid".
Definition _bhvShipPart3 : ident := $"bhvShipPart3".
Definition _bhvSpinAirborneWarp : ident := $"bhvSpinAirborneWarp".
Definition _bhvStar : ident := $"bhvStar".
Definition _bhvSunkenShipPart : ident := $"bhvSunkenShipPart".
Definition _bhvSunkenShipPart2 : ident := $"bhvSunkenShipPart2".
Definition _bhvSwimmingWarp : ident := $"bhvSwimmingWarp".
Definition _bhvTreasureChestsJRB : ident := $"bhvTreasureChestsJRB".
Definition _bhvTreasureChestsShip : ident := $"bhvTreasureChestsShip".
Definition _bhvUnagi : ident := $"bhvUnagi".
Definition _jrb_geo_000900 : ident := $"jrb_geo_000900".
Definition _jrb_geo_000918 : ident := $"jrb_geo_000918".
Definition _jrb_geo_000930 : ident := $"jrb_geo_000930".
Definition _jrb_geo_000948 : ident := $"jrb_geo_000948".
Definition _jrb_geo_000960 : ident := $"jrb_geo_000960".
Definition _jrb_geo_000978 : ident := $"jrb_geo_000978".
Definition _jrb_geo_000990 : ident := $"jrb_geo_000990".
Definition _jrb_geo_0009B0 : ident := $"jrb_geo_0009B0".
Definition _jrb_geo_0009C8 : ident := $"jrb_geo_0009C8".
Definition _jrb_geo_0009E8 : ident := $"jrb_geo_0009E8".
Definition _jrb_geo_000A00 : ident := $"jrb_geo_000A00".
Definition _jrb_geo_000A18 : ident := $"jrb_geo_000A18".
Definition _jrb_geo_000AFC : ident := $"jrb_geo_000AFC".
Definition _jrb_seg7_area_1_collision : ident := $"jrb_seg7_area_1_collision".
Definition _jrb_seg7_area_1_macro_objs : ident := $"jrb_seg7_area_1_macro_objs".
Definition _jrb_seg7_area_2_collision : ident := $"jrb_seg7_area_2_collision".
Definition _jrb_seg7_area_2_macro_objs : ident := $"jrb_seg7_area_2_macro_objs".
Definition _level_jrb_entry : ident := $"level_jrb_entry".
Definition _lvl_init_or_update : ident := $"lvl_init_or_update".
Definition _main : ident := $"main".
Definition _script_func_global_1 : ident := $"script_func_global_1".
Definition _script_func_global_14 : ident := $"script_func_global_14".
Definition _script_func_global_5 : ident := $"script_func_global_5".
Definition _script_func_local_1 : ident := $"__demo_jrb_level_script_script_func_local_1".
Definition _script_func_local_2 : ident := $"__demo_jrb_level_script_script_func_local_2".
Definition _script_func_local_3 : ident := $"__demo_jrb_level_script_script_func_local_3".
Definition _script_func_local_4 : ident := $"__demo_jrb_level_script_script_func_local_4".
Definition _script_func_local_5 : ident := $"__demo_jrb_level_script_script_func_local_5".

Definition v_bhvPoleGrabbing := {|
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

Definition v_bhvRockSolid := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvJRBSlidingBox := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvShipPart3 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvInSunkenShip3 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSunkenShipPart := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSunkenShipPart2 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvInSunkenShip := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvInSunkenShip2 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvInsideCannon := {|
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

Definition v_bhvSwimmingWarp := {|
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

Definition v_bhvJetStream := {|
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

Definition v_bhvJRBFloatingPlatform := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvFallingPillar := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvPillarBase := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvTreasureChestsShip := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvTreasureChestsJRB := {|
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

Definition v__group4_mio0SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group4_mio0SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group4_geoSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group4_geoSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group13_mio0SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group13_mio0SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group13_geoSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group13_geoSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__jrb_segment_7SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__jrb_segment_7SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__clouds_skybox_mio0SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__clouds_skybox_mio0SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__water_mio0SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__water_mio0SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__effect_mio0SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__effect_mio0SegmentRomEnd := {|
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

Definition v_script_func_global_5 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_script_func_global_14 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_jrb_geo_000900 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_jrb_geo_000918 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_jrb_geo_000930 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_jrb_geo_000948 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_jrb_geo_000960 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_jrb_geo_000978 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_jrb_geo_000990 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_jrb_geo_0009B0 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_jrb_geo_0009C8 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_jrb_geo_0009E8 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_jrb_geo_000A00 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_jrb_geo_000A18 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_jrb_geo_000AFC := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_jrb_seg7_area_1_collision := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_jrb_seg7_area_1_macro_objs := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_jrb_seg7_area_2_collision := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_jrb_seg7_area_2_macro_objs := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_local_1 := {|
  gvar_info := (tarray tuint 109);
  gvar_init := (Init_int32 (Int.repr 605552953) ::
                Init_int32 (Int.repr 156306949) ::
                Init_int32 (Int.repr 244252672) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvSunkenShipPart (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605552954) ::
                Init_int32 (Int.repr 156306949) ::
                Init_int32 (Int.repr 244252672) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvSunkenShipPart (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605552949) ::
                Init_int32 (Int.repr 352971376) ::
                Init_int32 (Int.repr 159121408) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvSunkenShipPart2 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605552951) ::
                Init_int32 (Int.repr 352971376) ::
                Init_int32 (Int.repr 159121408) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvSunkenShipPart2 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605552896) ::
                Init_int32 (Int.repr 352971376) ::
                Init_int32 (Int.repr 159121408) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvInSunkenShip (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605552896) ::
                Init_int32 (Int.repr 352971376) ::
                Init_int32 (Int.repr 159121408) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvInSunkenShip2 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568565) ::
                Init_int32 (Int.repr 319816500) ::
                Init_int32 (Int.repr 155648000) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvShipPart3 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568566) ::
                Init_int32 (Int.repr 319816500) ::
                Init_int32 (Int.repr 155648000) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvShipPart3 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568567) ::
                Init_int32 (Int.repr 319816500) ::
                Init_int32 (Int.repr 155648000) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvShipPart3 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568568) ::
                Init_int32 (Int.repr 319816500) ::
                Init_int32 (Int.repr 155648000) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvShipPart3 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568512) ::
                Init_int32 (Int.repr 319816500) ::
                Init_int32 (Int.repr 155648000) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvInSunkenShip3 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568572) ::
                Init_int32 (Int.repr 305923482) ::
                Init_int32 (Int.repr 191102976) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvJRBSlidingBox (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605552981) ::
                Init_int32 (Int.repr 396421883) ::
                Init_int32 (Int.repr 75628544) ::
                Init_int32 (Int.repr 22282240) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvUnagi (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605553237) ::
                Init_int32 (Int.repr 542045126) ::
                Init_int32 (Int.repr 120979456) ::
                Init_int32 (Int.repr 18677760) ::
                Init_int32 (Int.repr 16842752) ::
                Init_addrof _bhvUnagi (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568085) ::
                Init_int32 (Int.repr 396421883) ::
                Init_int32 (Int.repr 75628544) ::
                Init_int32 (Int.repr 22282240) ::
                Init_int32 (Int.repr 33685504) ::
                Init_addrof _bhvUnagi (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568512) ::
                Init_int32 (Int.repr 326953883) ::
                Init_int32 (Int.repr 162070528) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvJetStream (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr (-117902076)) ::
                Init_int32 (Int.repr (-137625600)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 33554432) ::
                Init_addrof _bhvTreasureChestsJRB (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568707) ::
                Init_int32 (Int.repr (-128187085)) ::
                Init_int32 (Int.repr 425984000) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvBobombBuddyOpensCannon (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_local_2 := {|
  gvar_info := (tarray tuint 307);
  gvar_init := (Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr 120256004) ::
                Init_int32 (Int.repr (-464650240)) ::
                Init_int32 (Int.repr 12713984) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr (-131336700)) ::
                Init_int32 (Int.repr (-229769216)) ::
                Init_int32 (Int.repr 8847360) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr 103478788) ::
                Init_int32 (Int.repr (-363986944)) ::
                Init_int32 (Int.repr 5898240) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr 2815492) ::
                Init_int32 (Int.repr (-431095808)) ::
                Init_int32 (Int.repr 8847360) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr (-64227836)) ::
                Init_int32 (Int.repr (-347209728)) ::
                Init_int32 (Int.repr 16711680) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr (-429193728)) ::
                Init_int32 (Int.repr 284622848) ::
                Init_int32 (Int.repr 5898240) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr 86701572) ::
                Init_int32 (Int.repr (-229769216)) ::
                Init_int32 (Int.repr 10813440) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr 422245892) ::
                Init_int32 (Int.repr (-414318592)) ::
                Init_int32 (Int.repr 8847360) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr 254473732) ::
                Init_int32 (Int.repr (-330432512)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr 98109133) ::
                Init_int32 (Int.repr 511836160) ::
                Init_int32 (Int.repr 917504) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr (-260700672)) ::
                Init_int32 (Int.repr (-5570560)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr (-342620978)) ::
                Init_int32 (Int.repr 138018816) ::
                Init_int32 (Int.repr 21168128) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr (-490273280)) ::
                Init_int32 (Int.repr 12124160) ::
                Init_int32 (Int.repr 9764864) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr (-376764928)) ::
                Init_int32 (Int.repr (-72941568)) ::
                Init_int32 (Int.repr 16711680) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr (-349436518)) ::
                Init_int32 (Int.repr 67043328) ::
                Init_int32 (Int.repr 20643840) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr (-53346917)) ::
                Init_int32 (Int.repr 233046016) ::
                Init_int32 (Int.repr 20643840) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr (-224722125)) ::
                Init_int32 (Int.repr 324272128) ::
                Init_int32 (Int.repr 18612224) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr (-127139430)) ::
                Init_int32 (Int.repr 155779072) ::
                Init_int32 (Int.repr 12713984) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr (-117768908)) ::
                Init_int32 (Int.repr 283770880) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr (-55376998)) ::
                Init_int32 (Int.repr 502530048) ::
                Init_int32 (Int.repr 20643840) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr 441840826) ::
                Init_int32 (Int.repr 233046016) ::
                Init_int32 (Int.repr 8847360) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr 16777115) ::
                Init_int32 (Int.repr 309264384) ::
                Init_int32 (Int.repr 2949120) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr 117178062) ::
                Init_int32 (Int.repr 336396288) ::
                Init_int32 (Int.repr 20643840) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr 70778267) ::
                Init_int32 (Int.repr 150667264) ::
                Init_int32 (Int.repr 4915200) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr 192149855) ::
                Init_int32 (Int.repr 64225280) ::
                Init_int32 (Int.repr 20643840) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr 199028123) ::
                Init_int32 (Int.repr 263913472) ::
                Init_int32 (Int.repr 20643840) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr 276757403) ::
                Init_int32 (Int.repr 464191488) ::
                Init_int32 (Int.repr 6815744) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr 435879323) ::
                Init_int32 (Int.repr 323813376) ::
                Init_int32 (Int.repr 20643840) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr 377810331) ::
                Init_int32 (Int.repr 290127872) ::
                Init_int32 (Int.repr 20643840) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr 242085275) ::
                Init_int32 (Int.repr 56098816) ::
                Init_int32 (Int.repr 8847360) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr 523043226) ::
                Init_int32 (Int.repr 177209344) ::
                Init_int32 (Int.repr 10813440) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr 191231002) ::
                Init_int32 (Int.repr 315752448) ::
                Init_int32 (Int.repr 15794176) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560635) ::
                Init_int32 (Int.repr 386465399) ::
                Init_int32 (Int.repr (-8060928)) ::
                Init_int32 (Int.repr 20643840) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvRockSolid (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 3475763) ::
                Init_int32 (Int.repr 178520064) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 2686976) ::
                Init_addrof _bhvPoleGrabbing (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 43190784) ::
                Init_int32 (Int.repr 217186304) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 2686976) ::
                Init_addrof _bhvPoleGrabbing (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 71239782) ::
                Init_int32 (Int.repr 248905728) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 2686976) ::
                Init_addrof _bhvPoleGrabbing (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr (-166132685)) ::
                Init_int32 (Int.repr 400621568) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 6356992) ::
                Init_addrof _bhvPoleGrabbing (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560637) ::
                Init_int32 (Int.repr 136246481) ::
                Init_int32 (Int.repr (-307757056)) ::
                Init_int32 (Int.repr 5898240) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFallingPillar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560637) ::
                Init_int32 (Int.repr (-91884335)) ::
                Init_int32 (Int.repr (-307757056)) ::
                Init_int32 (Int.repr 5898240) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFallingPillar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560637) ::
                Init_int32 (Int.repr (-71764783)) ::
                Init_int32 (Int.repr (-213778432)) ::
                Init_int32 (Int.repr 5898240) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFallingPillar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560637) ::
                Init_int32 (Int.repr 22148305) ::
                Init_int32 (Int.repr (-334626816)) ::
                Init_int32 (Int.repr 5898240) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFallingPillar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560637) ::
                Init_int32 (Int.repr 136246481) ::
                Init_int32 (Int.repr (-408420352)) ::
                Init_int32 (Int.repr 5898240) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFallingPillar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560637) ::
                Init_int32 (Int.repr 283833553) ::
                Init_int32 (Int.repr (-368181248)) ::
                Init_int32 (Int.repr 5898240) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFallingPillar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560638) ::
                Init_int32 (Int.repr 136246378) ::
                Init_int32 (Int.repr (-307757056)) ::
                Init_int32 (Int.repr 5898240) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvPillarBase (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560638) ::
                Init_int32 (Int.repr (-91884438)) ::
                Init_int32 (Int.repr (-307757056)) ::
                Init_int32 (Int.repr 5898240) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvPillarBase (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560638) ::
                Init_int32 (Int.repr (-71764886)) ::
                Init_int32 (Int.repr (-213778432)) ::
                Init_int32 (Int.repr 5898240) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvPillarBase (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560638) ::
                Init_int32 (Int.repr 22148202) ::
                Init_int32 (Int.repr (-334626816)) ::
                Init_int32 (Int.repr 5898240) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvPillarBase (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560638) ::
                Init_int32 (Int.repr 136246378) ::
                Init_int32 (Int.repr (-408420352)) ::
                Init_int32 (Int.repr 5898240) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvPillarBase (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560638) ::
                Init_int32 (Int.repr 283833450) ::
                Init_int32 (Int.repr (-368181248)) ::
                Init_int32 (Int.repr 5898240) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvPillarBase (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560639) ::
                Init_int32 (Int.repr (-69401599)) ::
                Init_int32 (Int.repr 463470592) ::
                Init_int32 (Int.repr 16187392) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvJRBFloatingPlatform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr (-277609452)) ::
                Init_int32 (Int.repr 139984896) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvInsideCannon (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_local_3 := {|
  gvar_info := (tarray tuint 19);
  gvar_init := (Init_int32 (Int.repr 605568768) ::
                Init_int32 (Int.repr 321128800) ::
                Init_int32 (Int.repr 52428800) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 50331648) ::
                Init_addrof _bhvHiddenRedCoinStar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568905) ::
                Init_int32 (Int.repr 100927600) ::
                Init_int32 (Int.repr 139591680) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 67633152) ::
                Init_addrof _bhvExclamationBox (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568634) ::
                Init_int32 (Int.repr 327740736) ::
                Init_int32 (Int.repr 163840000) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 83886080) ::
                Init_addrof _bhvStar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_local_4 := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 26279586) ::
                Init_int32 (Int.repr (-176947200)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvTreasureChestsShip (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_local_5 := {|
  gvar_info := (tarray tuint 1);
  gvar_init := (Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_jrb_entry := {|
  gvar_info := (tarray tuint 133);
  gvar_init := (Init_int32 (Int.repr 453246976) ::
                Init_int32 (Int.repr 403439623) ::
                Init_addrof __jrb_segment_7SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __jrb_segment_7SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 403439627) ::
                Init_addrof __effect_mio0SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __effect_mio0SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 436994057) ::
                Init_addrof __water_mio0SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __water_mio0SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 403439626) ::
                Init_addrof __clouds_skybox_mio0SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __clouds_skybox_mio0SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 403439621) ::
                Init_addrof __group4_mio0SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __group4_mio0SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 386662412) ::
                Init_addrof __group4_geoSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __group4_geoSegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 403439622) ::
                Init_addrof __group13_mio0SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __group13_mio0SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 386662413) ::
                Init_addrof __group13_geoSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __group13_geoSegmentRomEnd (Ptrofs.repr 0) ::
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
                Init_addrof _script_func_global_5 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_global_14 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949685) ::
                Init_addrof _jrb_geo_000978 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949686) ::
                Init_addrof _jrb_geo_0009B0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949687) ::
                Init_addrof _jrb_geo_0009E8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949688) ::
                Init_addrof _jrb_geo_000A00 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949689) ::
                Init_addrof _jrb_geo_000990 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949690) ::
                Init_addrof _jrb_geo_0009C8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949691) ::
                Init_addrof _jrb_geo_000930 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949692) ::
                Init_addrof _jrb_geo_000960 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949693) ::
                Init_addrof _jrb_geo_000900 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949694) ::
                Init_addrof _jrb_geo_000918 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949695) ::
                Init_addrof _jrb_geo_000948 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 520618240) ::
                Init_addrof _jrb_geo_000A18 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr (-442365874)) ::
                Init_int32 (Int.repr 97124352) ::
                Init_int32 (Int.repr 5898240) ::
                Init_int32 (Int.repr 655360) ::
                Init_addrof _bhvSpinAirborneWarp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 638061068) ::
                Init_int32 (Int.repr 17432576) ::
                Init_int32 (Int.repr 638120716) ::
                Init_int32 (Int.repr 34209792) ::
                Init_int32 (Int.repr 638119942) ::
                Init_int32 (Int.repr 20250624) ::
                Init_int32 (Int.repr 638120198) ::
                Init_int32 (Int.repr 23527424) ::
                Init_int32 (Int.repr 990642179) ::
                Init_int32 (Int.repr 326364058) ::
                Init_int32 (Int.repr 162725858) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_local_1 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_local_2 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_local_3 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 772276224) ::
                Init_addrof _jrb_seg7_area_1_collision (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 956825600) ::
                Init_addrof _jrb_seg7_area_1_macro_objs (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 906493955) ::
                Init_int32 (Int.repr 327680) ::
                Init_int32 (Int.repr 822345733) ::
                Init_int32 (Int.repr 537133056) ::
                Init_int32 (Int.repr 520618496) ::
                Init_addrof _jrb_geo_000AFC (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 60818458) ::
                Init_int32 (Int.repr (-81788928)) ::
                Init_int32 (Int.repr 11796480) ::
                Init_int32 (Int.repr 655360) ::
                Init_addrof _bhvSwimmingWarp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 638061068) ::
                Init_int32 (Int.repr 34209792) ::
                Init_int32 (Int.repr 638119942) ::
                Init_int32 (Int.repr 20250624) ::
                Init_int32 (Int.repr 638120198) ::
                Init_int32 (Int.repr 23527424) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_local_4 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_local_5 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 772276224) ::
                Init_addrof _jrb_seg7_area_2_collision (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 956825600) ::
                Init_addrof _jrb_seg7_area_2_macro_objs (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 906493955) ::
                Init_int32 (Int.repr 327680) ::
                Init_int32 (Int.repr 822345733) ::
                Init_int32 (Int.repr 537133056) ::
                Init_int32 (Int.repr 503578624) ::
                Init_int32 (Int.repr 722206976) ::
                Init_int32 (Int.repr 5957026) ::
                Init_int32 (Int.repr 73795018) ::
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
 (_bhvPoleGrabbing, Gvar v_bhvPoleGrabbing) ::
 (_bhvExclamationBox, Gvar v_bhvExclamationBox) ::
 (_bhvRockSolid, Gvar v_bhvRockSolid) ::
 (_bhvJRBSlidingBox, Gvar v_bhvJRBSlidingBox) ::
 (_bhvShipPart3, Gvar v_bhvShipPart3) ::
 (_bhvInSunkenShip3, Gvar v_bhvInSunkenShip3) ::
 (_bhvSunkenShipPart, Gvar v_bhvSunkenShipPart) ::
 (_bhvSunkenShipPart2, Gvar v_bhvSunkenShipPart2) ::
 (_bhvInSunkenShip, Gvar v_bhvInSunkenShip) ::
 (_bhvInSunkenShip2, Gvar v_bhvInSunkenShip2) ::
 (_bhvInsideCannon, Gvar v_bhvInsideCannon) ::
 (_bhvMario, Gvar v_bhvMario) ::
 (_bhvSpinAirborneWarp, Gvar v_bhvSpinAirborneWarp) ::
 (_bhvSwimmingWarp, Gvar v_bhvSwimmingWarp) ::
 (_bhvBobombBuddyOpensCannon, Gvar v_bhvBobombBuddyOpensCannon) ::
 (_bhvJetStream, Gvar v_bhvJetStream) :: (_bhvStar, Gvar v_bhvStar) ::
 (_bhvHiddenRedCoinStar, Gvar v_bhvHiddenRedCoinStar) ::
 (_bhvJRBFloatingPlatform, Gvar v_bhvJRBFloatingPlatform) ::
 (_bhvFallingPillar, Gvar v_bhvFallingPillar) ::
 (_bhvPillarBase, Gvar v_bhvPillarBase) ::
 (_bhvTreasureChestsShip, Gvar v_bhvTreasureChestsShip) ::
 (_bhvTreasureChestsJRB, Gvar v_bhvTreasureChestsJRB) ::
 (_bhvUnagi, Gvar v_bhvUnagi) ::
 (__common0_mio0SegmentRomStart, Gvar v__common0_mio0SegmentRomStart) ::
 (__common0_mio0SegmentRomEnd, Gvar v__common0_mio0SegmentRomEnd) ::
 (__common0_geoSegmentRomStart, Gvar v__common0_geoSegmentRomStart) ::
 (__common0_geoSegmentRomEnd, Gvar v__common0_geoSegmentRomEnd) ::
 (__group4_mio0SegmentRomStart, Gvar v__group4_mio0SegmentRomStart) ::
 (__group4_mio0SegmentRomEnd, Gvar v__group4_mio0SegmentRomEnd) ::
 (__group4_geoSegmentRomStart, Gvar v__group4_geoSegmentRomStart) ::
 (__group4_geoSegmentRomEnd, Gvar v__group4_geoSegmentRomEnd) ::
 (__group13_mio0SegmentRomStart, Gvar v__group13_mio0SegmentRomStart) ::
 (__group13_mio0SegmentRomEnd, Gvar v__group13_mio0SegmentRomEnd) ::
 (__group13_geoSegmentRomStart, Gvar v__group13_geoSegmentRomStart) ::
 (__group13_geoSegmentRomEnd, Gvar v__group13_geoSegmentRomEnd) ::
 (__jrb_segment_7SegmentRomStart, Gvar v__jrb_segment_7SegmentRomStart) ::
 (__jrb_segment_7SegmentRomEnd, Gvar v__jrb_segment_7SegmentRomEnd) ::
 (__clouds_skybox_mio0SegmentRomStart, Gvar v__clouds_skybox_mio0SegmentRomStart) ::
 (__clouds_skybox_mio0SegmentRomEnd, Gvar v__clouds_skybox_mio0SegmentRomEnd) ::
 (__water_mio0SegmentRomStart, Gvar v__water_mio0SegmentRomStart) ::
 (__water_mio0SegmentRomEnd, Gvar v__water_mio0SegmentRomEnd) ::
 (__effect_mio0SegmentRomStart, Gvar v__effect_mio0SegmentRomStart) ::
 (__effect_mio0SegmentRomEnd, Gvar v__effect_mio0SegmentRomEnd) ::
 (_lvl_init_or_update,
   Gfun(External (EF_external "lvl_init_or_update"
                   (mksignature (AST.Xint16signed :: AST.Xint :: nil)
                     AST.Xint cc_default)) (tshort :: tint :: nil) tint
     cc_default)) :: (_script_func_global_1, Gvar v_script_func_global_1) ::
 (_script_func_global_5, Gvar v_script_func_global_5) ::
 (_script_func_global_14, Gvar v_script_func_global_14) ::
 (_jrb_geo_000900, Gvar v_jrb_geo_000900) ::
 (_jrb_geo_000918, Gvar v_jrb_geo_000918) ::
 (_jrb_geo_000930, Gvar v_jrb_geo_000930) ::
 (_jrb_geo_000948, Gvar v_jrb_geo_000948) ::
 (_jrb_geo_000960, Gvar v_jrb_geo_000960) ::
 (_jrb_geo_000978, Gvar v_jrb_geo_000978) ::
 (_jrb_geo_000990, Gvar v_jrb_geo_000990) ::
 (_jrb_geo_0009B0, Gvar v_jrb_geo_0009B0) ::
 (_jrb_geo_0009C8, Gvar v_jrb_geo_0009C8) ::
 (_jrb_geo_0009E8, Gvar v_jrb_geo_0009E8) ::
 (_jrb_geo_000A00, Gvar v_jrb_geo_000A00) ::
 (_jrb_geo_000A18, Gvar v_jrb_geo_000A18) ::
 (_jrb_geo_000AFC, Gvar v_jrb_geo_000AFC) ::
 (_jrb_seg7_area_1_collision, Gvar v_jrb_seg7_area_1_collision) ::
 (_jrb_seg7_area_1_macro_objs, Gvar v_jrb_seg7_area_1_macro_objs) ::
 (_jrb_seg7_area_2_collision, Gvar v_jrb_seg7_area_2_collision) ::
 (_jrb_seg7_area_2_macro_objs, Gvar v_jrb_seg7_area_2_macro_objs) ::
 (_script_func_local_1, Gvar v_script_func_local_1) ::
 (_script_func_local_2, Gvar v_script_func_local_2) ::
 (_script_func_local_3, Gvar v_script_func_local_3) ::
 (_script_func_local_4, Gvar v_script_func_local_4) ::
 (_script_func_local_5, Gvar v_script_func_local_5) ::
 (_level_jrb_entry, Gvar v_level_jrb_entry) :: nil).

Definition public_idents : list ident :=
(_level_jrb_entry :: _jrb_seg7_area_2_macro_objs ::
 _jrb_seg7_area_2_collision :: _jrb_seg7_area_1_macro_objs ::
 _jrb_seg7_area_1_collision :: _jrb_geo_000AFC :: _jrb_geo_000A18 ::
 _jrb_geo_000A00 :: _jrb_geo_0009E8 :: _jrb_geo_0009C8 :: _jrb_geo_0009B0 ::
 _jrb_geo_000990 :: _jrb_geo_000978 :: _jrb_geo_000960 :: _jrb_geo_000948 ::
 _jrb_geo_000930 :: _jrb_geo_000918 :: _jrb_geo_000900 ::
 _script_func_global_14 :: _script_func_global_5 :: _script_func_global_1 ::
 _lvl_init_or_update :: __effect_mio0SegmentRomEnd ::
 __effect_mio0SegmentRomStart :: __water_mio0SegmentRomEnd ::
 __water_mio0SegmentRomStart :: __clouds_skybox_mio0SegmentRomEnd ::
 __clouds_skybox_mio0SegmentRomStart :: __jrb_segment_7SegmentRomEnd ::
 __jrb_segment_7SegmentRomStart :: __group13_geoSegmentRomEnd ::
 __group13_geoSegmentRomStart :: __group13_mio0SegmentRomEnd ::
 __group13_mio0SegmentRomStart :: __group4_geoSegmentRomEnd ::
 __group4_geoSegmentRomStart :: __group4_mio0SegmentRomEnd ::
 __group4_mio0SegmentRomStart :: __common0_geoSegmentRomEnd ::
 __common0_geoSegmentRomStart :: __common0_mio0SegmentRomEnd ::
 __common0_mio0SegmentRomStart :: _bhvUnagi :: _bhvTreasureChestsJRB ::
 _bhvTreasureChestsShip :: _bhvPillarBase :: _bhvFallingPillar ::
 _bhvJRBFloatingPlatform :: _bhvHiddenRedCoinStar :: _bhvStar ::
 _bhvJetStream :: _bhvBobombBuddyOpensCannon :: _bhvSwimmingWarp ::
 _bhvSpinAirborneWarp :: _bhvMario :: _bhvInsideCannon ::
 _bhvInSunkenShip2 :: _bhvInSunkenShip :: _bhvSunkenShipPart2 ::
 _bhvSunkenShipPart :: _bhvInSunkenShip3 :: _bhvShipPart3 ::
 _bhvJRBSlidingBox :: _bhvRockSolid :: _bhvExclamationBox ::
 _bhvPoleGrabbing :: ___builtin_debug :: ___builtin_sync_fetch_and_add ::
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
