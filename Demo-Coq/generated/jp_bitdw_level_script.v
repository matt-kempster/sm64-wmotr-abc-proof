(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_JP
   Source:          levels/bitdw/script.c
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_JP=1 -DF3D_OLD=1
   Link hygiene:    private globals scoped by translation unit bitdw_level_script
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
  Definition source_file := "build/pinned-sm64/levels/bitdw/script.c".
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
Definition __bidw_skybox_mio0SegmentRomEnd : ident := $"_bidw_skybox_mio0SegmentRomEnd".
Definition __bidw_skybox_mio0SegmentRomStart : ident := $"_bidw_skybox_mio0SegmentRomStart".
Definition __bitdw_segment_7SegmentRomEnd : ident := $"_bitdw_segment_7SegmentRomEnd".
Definition __bitdw_segment_7SegmentRomStart : ident := $"_bitdw_segment_7SegmentRomStart".
Definition __common0_geoSegmentRomEnd : ident := $"_common0_geoSegmentRomEnd".
Definition __common0_geoSegmentRomStart : ident := $"_common0_geoSegmentRomStart".
Definition __common0_mio0SegmentRomEnd : ident := $"_common0_mio0SegmentRomEnd".
Definition __common0_mio0SegmentRomStart : ident := $"_common0_mio0SegmentRomStart".
Definition __group11_geoSegmentRomEnd : ident := $"_group11_geoSegmentRomEnd".
Definition __group11_geoSegmentRomStart : ident := $"_group11_geoSegmentRomStart".
Definition __group11_mio0SegmentRomEnd : ident := $"_group11_mio0SegmentRomEnd".
Definition __group11_mio0SegmentRomStart : ident := $"_group11_mio0SegmentRomStart".
Definition __group17_geoSegmentRomEnd : ident := $"_group17_geoSegmentRomEnd".
Definition __group17_geoSegmentRomStart : ident := $"_group17_geoSegmentRomStart".
Definition __group17_mio0SegmentRomEnd : ident := $"_group17_mio0SegmentRomEnd".
Definition __group17_mio0SegmentRomStart : ident := $"_group17_mio0SegmentRomStart".
Definition __sky_mio0SegmentRomEnd : ident := $"_sky_mio0SegmentRomEnd".
Definition __sky_mio0SegmentRomStart : ident := $"_sky_mio0SegmentRomStart".
Definition _bhvAirborneWarp : ident := $"bhvAirborneWarp".
Definition _bhvAnimatesOnFloorSwitchPress : ident := $"bhvAnimatesOnFloorSwitchPress".
Definition _bhvBowserCourseRedCoinStar : ident := $"bhvBowserCourseRedCoinStar".
Definition _bhvDeathWarp : ident := $"bhvDeathWarp".
Definition _bhvFerrisWheelAxle : ident := $"bhvFerrisWheelAxle".
Definition _bhvFlamethrower : ident := $"bhvFlamethrower".
Definition _bhvFloorSwitchAnimatesObject : ident := $"bhvFloorSwitchAnimatesObject".
Definition _bhvMario : ident := $"bhvMario".
Definition _bhvSeesawPlatform : ident := $"bhvSeesawPlatform".
Definition _bhvSlidingPlatform2 : ident := $"bhvSlidingPlatform2".
Definition _bhvSquarishPathMoving : ident := $"bhvSquarishPathMoving".
Definition _bhvWarpPipe : ident := $"bhvWarpPipe".
Definition _bitdw_seg7_collision_level : ident := $"bitdw_seg7_collision_level".
Definition _bitdw_seg7_macro_objs : ident := $"bitdw_seg7_macro_objs".
Definition _geo_bitdw_0003C0 : ident := $"geo_bitdw_0003C0".
Definition _geo_bitdw_0003D8 : ident := $"geo_bitdw_0003D8".
Definition _geo_bitdw_0003F0 : ident := $"geo_bitdw_0003F0".
Definition _geo_bitdw_000408 : ident := $"geo_bitdw_000408".
Definition _geo_bitdw_000420 : ident := $"geo_bitdw_000420".
Definition _geo_bitdw_000438 : ident := $"geo_bitdw_000438".
Definition _geo_bitdw_000450 : ident := $"geo_bitdw_000450".
Definition _geo_bitdw_000468 : ident := $"geo_bitdw_000468".
Definition _geo_bitdw_000480 : ident := $"geo_bitdw_000480".
Definition _geo_bitdw_000498 : ident := $"geo_bitdw_000498".
Definition _geo_bitdw_0004B0 : ident := $"geo_bitdw_0004B0".
Definition _geo_bitdw_0004C8 : ident := $"geo_bitdw_0004C8".
Definition _geo_bitdw_0004E0 : ident := $"geo_bitdw_0004E0".
Definition _geo_bitdw_0004F8 : ident := $"geo_bitdw_0004F8".
Definition _geo_bitdw_000510 : ident := $"geo_bitdw_000510".
Definition _geo_bitdw_000528 : ident := $"geo_bitdw_000528".
Definition _geo_bitdw_000540 : ident := $"geo_bitdw_000540".
Definition _geo_bitdw_000558 : ident := $"geo_bitdw_000558".
Definition _geo_bitdw_000570 : ident := $"geo_bitdw_000570".
Definition _geo_bitdw_000588 : ident := $"geo_bitdw_000588".
Definition _geo_bitdw_0005A0 : ident := $"geo_bitdw_0005A0".
Definition _geo_bitdw_0005B8 : ident := $"geo_bitdw_0005B8".
Definition _geo_bitdw_0005D0 : ident := $"geo_bitdw_0005D0".
Definition _geo_bitdw_0005E8 : ident := $"geo_bitdw_0005E8".
Definition _geo_bitdw_000600 : ident := $"geo_bitdw_000600".
Definition _geo_bitdw_000618 : ident := $"geo_bitdw_000618".
Definition _level_bitdw_entry : ident := $"level_bitdw_entry".
Definition _lvl_init_or_update : ident := $"lvl_init_or_update".
Definition _main : ident := $"main".
Definition _script_func_global_1 : ident := $"script_func_global_1".
Definition _script_func_global_12 : ident := $"script_func_global_12".
Definition _script_func_global_18 : ident := $"script_func_global_18".
Definition _script_func_local_1 : ident := $"__demo_bitdw_level_script_script_func_local_1".
Definition _script_func_local_2 : ident := $"__demo_bitdw_level_script_script_func_local_2".
Definition _script_func_local_3 : ident := $"__demo_bitdw_level_script_script_func_local_3".
Definition _warp_pipe_geo : ident := $"warp_pipe_geo".

Definition v_bhvWarpPipe := {|
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

Definition v_bhvSquarishPathMoving := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvFloorSwitchAnimatesObject := {|
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

Definition v_bhvAirborneWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvDeathWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBowserCourseRedCoinStar := {|
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

Definition v_bhvSlidingPlatform2 := {|
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

Definition v__group11_mio0SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group11_mio0SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group11_geoSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group11_geoSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group17_mio0SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group17_mio0SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group17_geoSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group17_geoSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__bitdw_segment_7SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__bitdw_segment_7SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__bidw_skybox_mio0SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__bidw_skybox_mio0SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__sky_mio0SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__sky_mio0SegmentRomEnd := {|
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

Definition v_script_func_global_12 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_script_func_global_18 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_warp_pipe_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_0003C0 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_0003D8 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_0003F0 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_000408 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_000420 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_000438 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_000450 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_000468 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_000480 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_000498 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_0004B0 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_0004C8 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_0004E0 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_0004F8 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_000510 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_000528 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_000540 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_000558 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_000570 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_000588 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_0005A0 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_0005B8 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_0005D0 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_0005E8 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_000600 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_geo_bitdw_000618 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bitdw_seg7_collision_level := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bitdw_seg7_macro_objs := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_local_1 := {|
  gvar_info := (tarray tuint 73);
  gvar_init := (Init_int32 (Int.repr 605560630) ::
                Init_int32 (Int.repr (-128781394)) ::
                Init_int32 (Int.repr 235012096) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvSquarishPathMoving (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560630) ::
                Init_int32 (Int.repr (-88542290)) ::
                Init_int32 (Int.repr 275251200) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 131072) ::
                Init_addrof _bhvSquarishPathMoving (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560630) ::
                Init_int32 (Int.repr (-194182151)) ::
                Init_int32 (Int.repr (-161480704)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvSquarishPathMoving (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560630) ::
                Init_int32 (Int.repr (-153943047)) ::
                Init_int32 (Int.repr (-121176064)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 131072) ::
                Init_addrof _bhvSquarishPathMoving (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560630) ::
                Init_int32 (Int.repr (-153943047)) ::
                Init_int32 (Int.repr (-80936960)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvSquarishPathMoving (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560630) ::
                Init_int32 (Int.repr (-113703943)) ::
                Init_int32 (Int.repr (-40697856)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 131072) ::
                Init_addrof _bhvSquarishPathMoving (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560631) ::
                Init_int32 (Int.repr 97715449) ::
                Init_int32 (Int.repr 33554432) ::
                Init_int32 (Int.repr 5898240) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvSeesawPlatform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560631) ::
                Init_int32 (Int.repr (-9632898)) ::
                Init_int32 (Int.repr 33554432) ::
                Init_int32 (Int.repr 5898240) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvSeesawPlatform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560632) ::
                Init_int32 (Int.repr (-375389389)) ::
                Init_int32 (Int.repr (-140967936)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 63832064) ::
                Init_addrof _bhvSlidingPlatform2 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560633) ::
                Init_int32 (Int.repr (-13305732)) ::
                Init_int32 (Int.repr 221577216) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 65536) ::
                Init_addrof _bhvFerrisWheelAxle (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560639) ::
                Init_int32 (Int.repr 345966284) ::
                Init_int32 (Int.repr (-393216)) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 65536) ::
                Init_addrof _bhvAnimatesOnFloorSwitchPress (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560783) ::
                Init_int32 (Int.repr 257033932) ::
                Init_int32 (Int.repr (-458752)) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFloorSwitchAnimatesObject (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_local_2 := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr (-202574571)) ::
                Init_int32 (Int.repr 186253312) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFlamethrower (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 161478318) ::
                Init_int32 (Int.repr 186384384) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFlamethrower (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_local_3 := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 470551480) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvBowserCourseRedCoinStar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_bitdw_entry := {|
  gvar_info := (tarray tuint 144);
  gvar_init := (Init_int32 (Int.repr 453246976) ::
                Init_int32 (Int.repr 403439623) ::
                Init_addrof __bitdw_segment_7SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __bitdw_segment_7SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 403439626) ::
                Init_addrof __bidw_skybox_mio0SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __bidw_skybox_mio0SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 436994057) ::
                Init_addrof __sky_mio0SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __sky_mio0SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 403439621) ::
                Init_addrof __group11_mio0SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __group11_mio0SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 386662412) ::
                Init_addrof __group11_geoSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __group11_geoSegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 403439622) ::
                Init_addrof __group17_mio0SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __group17_mio0SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 386662413) ::
                Init_addrof __group17_geoSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __group17_geoSegmentRomEnd (Ptrofs.repr 0) ::
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
                Init_addrof _script_func_global_12 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_global_18 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_global_1 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949635) ::
                Init_addrof _geo_bitdw_0003C0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949636) ::
                Init_addrof _geo_bitdw_0003D8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949637) ::
                Init_addrof _geo_bitdw_0003F0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949638) ::
                Init_addrof _geo_bitdw_000408 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949639) ::
                Init_addrof _geo_bitdw_000420 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949640) ::
                Init_addrof _geo_bitdw_000438 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949641) ::
                Init_addrof _geo_bitdw_000450 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949642) ::
                Init_addrof _geo_bitdw_000468 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949643) ::
                Init_addrof _geo_bitdw_000480 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949644) ::
                Init_addrof _geo_bitdw_000498 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949645) ::
                Init_addrof _geo_bitdw_0004B0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949646) ::
                Init_addrof _geo_bitdw_0004C8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949647) ::
                Init_addrof _geo_bitdw_0004E0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949648) ::
                Init_addrof _geo_bitdw_0004F8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949649) ::
                Init_addrof _geo_bitdw_000510 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949650) ::
                Init_addrof _warp_pipe_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949686) ::
                Init_addrof _geo_bitdw_000558 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949687) ::
                Init_addrof _geo_bitdw_000540 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949688) ::
                Init_addrof _geo_bitdw_000528 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949689) ::
                Init_addrof _geo_bitdw_000570 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949690) ::
                Init_addrof _geo_bitdw_000588 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949691) ::
                Init_addrof _geo_bitdw_0005A0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949692) ::
                Init_addrof _geo_bitdw_0005B8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949693) ::
                Init_addrof _geo_bitdw_0005D0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949694) ::
                Init_addrof _geo_bitdw_0005E8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949695) ::
                Init_addrof _geo_bitdw_000600 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 520618240) ::
                Init_addrof _geo_bitdw_000618 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr (-487721065)) ::
                Init_int32 (Int.repr 254672896) ::
                Init_int32 (Int.repr 5898240) ::
                Init_int32 (Int.repr 655360) ::
                Init_addrof _bhvAirborneWarp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560594) ::
                Init_int32 (Int.repr 446696236) ::
                Init_int32 (Int.repr (-458752)) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 720896) ::
                Init_addrof _bhvWarpPipe (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 387321260) ::
                Init_int32 (Int.repr (-458752)) ::
                Init_int32 (Int.repr 5898240) ::
                Init_int32 (Int.repr 786432) ::
                Init_addrof _bhvDeathWarp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 638061073) ::
                Init_int32 (Int.repr 17432576) ::
                Init_int32 (Int.repr 638061342) ::
                Init_int32 (Int.repr 17432576) ::
                Init_int32 (Int.repr 638061585) ::
                Init_int32 (Int.repr 17563648) ::
                Init_int32 (Int.repr 638120198) ::
                Init_int32 (Int.repr 19202048) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_local_1 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_local_2 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_local_3 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 772276224) ::
                Init_addrof _bitdw_seg7_collision_level (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 956825600) ::
                Init_addrof _bitdw_seg7_macro_objs (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 805568602) ::
                Init_int32 (Int.repr 906493952) ::
                Init_int32 (Int.repr 1114112) ::
                Init_int32 (Int.repr 822345729) ::
                Init_int32 (Int.repr 537133056) ::
                Init_int32 (Int.repr 503578624) ::
                Init_int32 (Int.repr 722206976) ::
                Init_int32 (Int.repr 5956333) ::
                Init_int32 (Int.repr (-206631122)) ::
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
 (_bhvWarpPipe, Gvar v_bhvWarpPipe) ::
 (_bhvFlamethrower, Gvar v_bhvFlamethrower) ::
 (_bhvSquarishPathMoving, Gvar v_bhvSquarishPathMoving) ::
 (_bhvFloorSwitchAnimatesObject, Gvar v_bhvFloorSwitchAnimatesObject) ::
 (_bhvMario, Gvar v_bhvMario) ::
 (_bhvAirborneWarp, Gvar v_bhvAirborneWarp) ::
 (_bhvDeathWarp, Gvar v_bhvDeathWarp) ::
 (_bhvBowserCourseRedCoinStar, Gvar v_bhvBowserCourseRedCoinStar) ::
 (_bhvSeesawPlatform, Gvar v_bhvSeesawPlatform) ::
 (_bhvFerrisWheelAxle, Gvar v_bhvFerrisWheelAxle) ::
 (_bhvSlidingPlatform2, Gvar v_bhvSlidingPlatform2) ::
 (_bhvAnimatesOnFloorSwitchPress, Gvar v_bhvAnimatesOnFloorSwitchPress) ::
 (__common0_mio0SegmentRomStart, Gvar v__common0_mio0SegmentRomStart) ::
 (__common0_mio0SegmentRomEnd, Gvar v__common0_mio0SegmentRomEnd) ::
 (__common0_geoSegmentRomStart, Gvar v__common0_geoSegmentRomStart) ::
 (__common0_geoSegmentRomEnd, Gvar v__common0_geoSegmentRomEnd) ::
 (__group11_mio0SegmentRomStart, Gvar v__group11_mio0SegmentRomStart) ::
 (__group11_mio0SegmentRomEnd, Gvar v__group11_mio0SegmentRomEnd) ::
 (__group11_geoSegmentRomStart, Gvar v__group11_geoSegmentRomStart) ::
 (__group11_geoSegmentRomEnd, Gvar v__group11_geoSegmentRomEnd) ::
 (__group17_mio0SegmentRomStart, Gvar v__group17_mio0SegmentRomStart) ::
 (__group17_mio0SegmentRomEnd, Gvar v__group17_mio0SegmentRomEnd) ::
 (__group17_geoSegmentRomStart, Gvar v__group17_geoSegmentRomStart) ::
 (__group17_geoSegmentRomEnd, Gvar v__group17_geoSegmentRomEnd) ::
 (__bitdw_segment_7SegmentRomStart, Gvar v__bitdw_segment_7SegmentRomStart) ::
 (__bitdw_segment_7SegmentRomEnd, Gvar v__bitdw_segment_7SegmentRomEnd) ::
 (__bidw_skybox_mio0SegmentRomStart, Gvar v__bidw_skybox_mio0SegmentRomStart) ::
 (__bidw_skybox_mio0SegmentRomEnd, Gvar v__bidw_skybox_mio0SegmentRomEnd) ::
 (__sky_mio0SegmentRomStart, Gvar v__sky_mio0SegmentRomStart) ::
 (__sky_mio0SegmentRomEnd, Gvar v__sky_mio0SegmentRomEnd) ::
 (_lvl_init_or_update,
   Gfun(External (EF_external "lvl_init_or_update"
                   (mksignature (AST.Xint16signed :: AST.Xint :: nil)
                     AST.Xint cc_default)) (tshort :: tint :: nil) tint
     cc_default)) :: (_script_func_global_1, Gvar v_script_func_global_1) ::
 (_script_func_global_12, Gvar v_script_func_global_12) ::
 (_script_func_global_18, Gvar v_script_func_global_18) ::
 (_warp_pipe_geo, Gvar v_warp_pipe_geo) ::
 (_geo_bitdw_0003C0, Gvar v_geo_bitdw_0003C0) ::
 (_geo_bitdw_0003D8, Gvar v_geo_bitdw_0003D8) ::
 (_geo_bitdw_0003F0, Gvar v_geo_bitdw_0003F0) ::
 (_geo_bitdw_000408, Gvar v_geo_bitdw_000408) ::
 (_geo_bitdw_000420, Gvar v_geo_bitdw_000420) ::
 (_geo_bitdw_000438, Gvar v_geo_bitdw_000438) ::
 (_geo_bitdw_000450, Gvar v_geo_bitdw_000450) ::
 (_geo_bitdw_000468, Gvar v_geo_bitdw_000468) ::
 (_geo_bitdw_000480, Gvar v_geo_bitdw_000480) ::
 (_geo_bitdw_000498, Gvar v_geo_bitdw_000498) ::
 (_geo_bitdw_0004B0, Gvar v_geo_bitdw_0004B0) ::
 (_geo_bitdw_0004C8, Gvar v_geo_bitdw_0004C8) ::
 (_geo_bitdw_0004E0, Gvar v_geo_bitdw_0004E0) ::
 (_geo_bitdw_0004F8, Gvar v_geo_bitdw_0004F8) ::
 (_geo_bitdw_000510, Gvar v_geo_bitdw_000510) ::
 (_geo_bitdw_000528, Gvar v_geo_bitdw_000528) ::
 (_geo_bitdw_000540, Gvar v_geo_bitdw_000540) ::
 (_geo_bitdw_000558, Gvar v_geo_bitdw_000558) ::
 (_geo_bitdw_000570, Gvar v_geo_bitdw_000570) ::
 (_geo_bitdw_000588, Gvar v_geo_bitdw_000588) ::
 (_geo_bitdw_0005A0, Gvar v_geo_bitdw_0005A0) ::
 (_geo_bitdw_0005B8, Gvar v_geo_bitdw_0005B8) ::
 (_geo_bitdw_0005D0, Gvar v_geo_bitdw_0005D0) ::
 (_geo_bitdw_0005E8, Gvar v_geo_bitdw_0005E8) ::
 (_geo_bitdw_000600, Gvar v_geo_bitdw_000600) ::
 (_geo_bitdw_000618, Gvar v_geo_bitdw_000618) ::
 (_bitdw_seg7_collision_level, Gvar v_bitdw_seg7_collision_level) ::
 (_bitdw_seg7_macro_objs, Gvar v_bitdw_seg7_macro_objs) ::
 (_script_func_local_1, Gvar v_script_func_local_1) ::
 (_script_func_local_2, Gvar v_script_func_local_2) ::
 (_script_func_local_3, Gvar v_script_func_local_3) ::
 (_level_bitdw_entry, Gvar v_level_bitdw_entry) :: nil).

Definition public_idents : list ident :=
(_level_bitdw_entry :: _bitdw_seg7_macro_objs ::
 _bitdw_seg7_collision_level :: _geo_bitdw_000618 :: _geo_bitdw_000600 ::
 _geo_bitdw_0005E8 :: _geo_bitdw_0005D0 :: _geo_bitdw_0005B8 ::
 _geo_bitdw_0005A0 :: _geo_bitdw_000588 :: _geo_bitdw_000570 ::
 _geo_bitdw_000558 :: _geo_bitdw_000540 :: _geo_bitdw_000528 ::
 _geo_bitdw_000510 :: _geo_bitdw_0004F8 :: _geo_bitdw_0004E0 ::
 _geo_bitdw_0004C8 :: _geo_bitdw_0004B0 :: _geo_bitdw_000498 ::
 _geo_bitdw_000480 :: _geo_bitdw_000468 :: _geo_bitdw_000450 ::
 _geo_bitdw_000438 :: _geo_bitdw_000420 :: _geo_bitdw_000408 ::
 _geo_bitdw_0003F0 :: _geo_bitdw_0003D8 :: _geo_bitdw_0003C0 ::
 _warp_pipe_geo :: _script_func_global_18 :: _script_func_global_12 ::
 _script_func_global_1 :: _lvl_init_or_update :: __sky_mio0SegmentRomEnd ::
 __sky_mio0SegmentRomStart :: __bidw_skybox_mio0SegmentRomEnd ::
 __bidw_skybox_mio0SegmentRomStart :: __bitdw_segment_7SegmentRomEnd ::
 __bitdw_segment_7SegmentRomStart :: __group17_geoSegmentRomEnd ::
 __group17_geoSegmentRomStart :: __group17_mio0SegmentRomEnd ::
 __group17_mio0SegmentRomStart :: __group11_geoSegmentRomEnd ::
 __group11_geoSegmentRomStart :: __group11_mio0SegmentRomEnd ::
 __group11_mio0SegmentRomStart :: __common0_geoSegmentRomEnd ::
 __common0_geoSegmentRomStart :: __common0_mio0SegmentRomEnd ::
 __common0_mio0SegmentRomStart :: _bhvAnimatesOnFloorSwitchPress ::
 _bhvSlidingPlatform2 :: _bhvFerrisWheelAxle :: _bhvSeesawPlatform ::
 _bhvBowserCourseRedCoinStar :: _bhvDeathWarp :: _bhvAirborneWarp ::
 _bhvMario :: _bhvFloorSwitchAnimatesObject :: _bhvSquarishPathMoving ::
 _bhvFlamethrower :: _bhvWarpPipe :: ___builtin_debug ::
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
