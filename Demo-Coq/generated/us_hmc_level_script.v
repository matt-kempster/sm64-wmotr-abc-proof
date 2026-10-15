(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_US
   Source:          levels/hmc/script.c
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1
   Link hygiene:    private __stringlit_N atoms prefixed with us_hmc_level_script
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
  Definition source_file := "build/pinned-sm64/levels/hmc/script.c".
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
Definition __cave_mio0SegmentRomEnd : ident := $"_cave_mio0SegmentRomEnd".
Definition __cave_mio0SegmentRomStart : ident := $"_cave_mio0SegmentRomStart".
Definition __common0_geoSegmentRomEnd : ident := $"_common0_geoSegmentRomEnd".
Definition __common0_geoSegmentRomStart : ident := $"_common0_geoSegmentRomStart".
Definition __common0_mio0SegmentRomEnd : ident := $"_common0_mio0SegmentRomEnd".
Definition __common0_mio0SegmentRomStart : ident := $"_common0_mio0SegmentRomStart".
Definition __group17_geoSegmentRomEnd : ident := $"_group17_geoSegmentRomEnd".
Definition __group17_geoSegmentRomStart : ident := $"_group17_geoSegmentRomStart".
Definition __group17_mio0SegmentRomEnd : ident := $"_group17_mio0SegmentRomEnd".
Definition __group17_mio0SegmentRomStart : ident := $"_group17_mio0SegmentRomStart".
Definition __group6_geoSegmentRomEnd : ident := $"_group6_geoSegmentRomEnd".
Definition __group6_geoSegmentRomStart : ident := $"_group6_geoSegmentRomStart".
Definition __group6_mio0SegmentRomEnd : ident := $"_group6_mio0SegmentRomEnd".
Definition __group6_mio0SegmentRomStart : ident := $"_group6_mio0SegmentRomStart".
Definition __hmc_segment_7SegmentRomEnd : ident := $"_hmc_segment_7SegmentRomEnd".
Definition __hmc_segment_7SegmentRomStart : ident := $"_hmc_segment_7SegmentRomStart".
Definition _bhvBigBoulderGenerator : ident := $"bhvBigBoulderGenerator".
Definition _bhvControllablePlatform : ident := $"bhvControllablePlatform".
Definition _bhvDorrie : ident := $"bhvDorrie".
Definition _bhvFlame : ident := $"bhvFlame".
Definition _bhvFlamethrower : ident := $"bhvFlamethrower".
Definition _bhvFloorSwitchGrills : ident := $"bhvFloorSwitchGrills".
Definition _bhvHMCElevatorPlatform : ident := $"bhvHMCElevatorPlatform".
Definition _bhvHiddenRedCoinStar : ident := $"bhvHiddenRedCoinStar".
Definition _bhvMario : ident := $"bhvMario".
Definition _bhvOpenableGrill : ident := $"bhvOpenableGrill".
Definition _bhvPlatformOnTrack : ident := $"bhvPlatformOnTrack".
Definition _bhvPoleGrabbing : ident := $"bhvPoleGrabbing".
Definition _bhvSpinAirborneWarp : ident := $"bhvSpinAirborneWarp".
Definition _bhvStar : ident := $"bhvStar".
Definition _bhvWarp : ident := $"bhvWarp".
Definition _hazy_maze_door_geo : ident := $"hazy_maze_door_geo".
Definition _hmc_geo_000530 : ident := $"hmc_geo_000530".
Definition _hmc_geo_000548 : ident := $"hmc_geo_000548".
Definition _hmc_geo_000570 : ident := $"hmc_geo_000570".
Definition _hmc_geo_000588 : ident := $"hmc_geo_000588".
Definition _hmc_geo_0005A0 : ident := $"hmc_geo_0005A0".
Definition _hmc_geo_0005B8 : ident := $"hmc_geo_0005B8".
Definition _hmc_geo_0005D0 : ident := $"hmc_geo_0005D0".
Definition _hmc_geo_000B90 : ident := $"hmc_geo_000B90".
Definition _hmc_seg7_collision_level : ident := $"hmc_seg7_collision_level".
Definition _hmc_seg7_macro_objs : ident := $"hmc_seg7_macro_objs".
Definition _hmc_seg7_rooms : ident := $"hmc_seg7_rooms".
Definition _level_hmc_entry : ident := $"level_hmc_entry".
Definition _lvl_init_or_update : ident := $"lvl_init_or_update".
Definition _main : ident := $"main".
Definition _metal_door_geo : ident := $"metal_door_geo".
Definition _script_func_global_1 : ident := $"script_func_global_1".
Definition _script_func_global_18 : ident := $"script_func_global_18".
Definition _script_func_global_7 : ident := $"script_func_global_7".
Definition _script_func_local_1 : ident := $"script_func_local_1".
Definition _script_func_local_2 : ident := $"script_func_local_2".
Definition _script_func_local_3 : ident := $"script_func_local_3".
Definition _script_func_local_4 : ident := $"script_func_local_4".
Definition _wooden_door_geo : ident := $"wooden_door_geo".

Definition v_bhvPoleGrabbing := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvFlame := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvHMCElevatorPlatform := {|
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

Definition v_bhvFloorSwitchGrills := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvOpenableGrill := {|
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

Definition v_bhvBigBoulderGenerator := {|
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

Definition v_bhvControllablePlatform := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvPlatformOnTrack := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvDorrie := {|
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

Definition v__group6_mio0SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group6_mio0SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group6_geoSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group6_geoSegmentRomEnd := {|
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

Definition v__hmc_segment_7SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__hmc_segment_7SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__cave_mio0SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__cave_mio0SegmentRomEnd := {|
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

Definition v_script_func_global_7 := {|
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

Definition v_wooden_door_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_metal_door_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_hazy_maze_door_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_hmc_geo_000530 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_hmc_geo_000548 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_hmc_geo_000570 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_hmc_geo_000588 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_hmc_geo_0005A0 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_hmc_geo_0005B8 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_hmc_geo_0005D0 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_hmc_geo_000B90 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_hmc_seg7_collision_level := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_hmc_seg7_macro_objs := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_hmc_seg7_rooms := {|
  gvar_info := (tarray tschar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_local_1 := {|
  gvar_info := (tarray tuint 115);
  gvar_init := (Init_int32 (Int.repr 605560720) ::
                Init_int32 (Int.repr 323550875) ::
                Init_int32 (Int.repr (-271712256)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFlame (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560720) ::
                Init_int32 (Int.repr 328924724) ::
                Init_int32 (Int.repr (-364314624)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFlame (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560720) ::
                Init_int32 (Int.repr 130876058) ::
                Init_int32 (Int.repr (-15400960)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFlame (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560720) ::
                Init_int32 (Int.repr 115539508) ::
                Init_int32 (Int.repr (-171048960)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFlame (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560720) ::
                Init_int32 (Int.repr 273874689) ::
                Init_int32 (Int.repr (-244908032)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFlame (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560720) ::
                Init_int32 (Int.repr 146406964) ::
                Init_int32 (Int.repr 16777216) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFlame (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560720) ::
                Init_int32 (Int.repr 361168641) ::
                Init_int32 (Int.repr (-224722944)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFlame (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560720) ::
                Init_int32 (Int.repr 307429019) ::
                Init_int32 (Int.repr (-50266112)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFlame (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560720) ::
                Init_int32 (Int.repr 226950913) ::
                Init_int32 (Int.repr (-73728000)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFlame (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560720) ::
                Init_int32 (Int.repr 115475098) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFlame (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560720) ::
                Init_int32 (Int.repr 115539508) ::
                Init_int32 (Int.repr 16777216) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFlame (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560720) ::
                Init_int32 (Int.repr 424804813) ::
                Init_int32 (Int.repr 211419136) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFlame (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560720) ::
                Init_int32 (Int.repr 70451661) ::
                Init_int32 (Int.repr 428802048) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFlame (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560720) ::
                Init_int32 (Int.repr 452985293) ::
                Init_int32 (Int.repr 428802048) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFlame (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560720) ::
                Init_int32 (Int.repr 452985293) ::
                Init_int32 (Int.repr 242286592) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFlame (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560720) ::
                Init_int32 (Int.repr 424804813) ::
                Init_int32 (Int.repr 459669504) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFlame (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560720) ::
                Init_int32 (Int.repr 250151629) ::
                Init_int32 (Int.repr 67764224) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFlame (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 52364288) ::
                Init_int32 (Int.repr 290586624) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 12058624) ::
                Init_addrof _bhvPoleGrabbing (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 58262528) ::
                Init_int32 (Int.repr 214761472) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 12058624) ::
                Init_addrof _bhvPoleGrabbing (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_local_2 := {|
  gvar_info := (tarray tuint 49);
  gvar_init := (Init_int32 (Int.repr 605560630) ::
                Init_int32 (Int.repr 72090550) ::
                Init_int32 (Int.repr 416153600) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvControllablePlatform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560632) ::
                Init_int32 (Int.repr (-212531814)) ::
                Init_int32 (Int.repr 91226112) ::
                Init_int32 (Int.repr 1769472) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvHMCElevatorPlatform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560632) ::
                Init_int32 (Int.repr (-184547123)) ::
                Init_int32 (Int.repr (-164429824)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 65536) ::
                Init_addrof _bhvHMCElevatorPlatform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560632) ::
                Init_int32 (Int.repr (-63764787)) ::
                Init_int32 (Int.repr (-481492992)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 131072) ::
                Init_addrof _bhvHMCElevatorPlatform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560632) ::
                Init_int32 (Int.repr (-231536947)) ::
                Init_int32 (Int.repr (-461373440)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 196608) ::
                Init_addrof _bhvHMCElevatorPlatform (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 40299950) ::
                Init_int32 (Int.repr 152698880) ::
                Init_int32 (Int.repr 17694720) ::
                Init_int32 (Int.repr 65536) ::
                Init_addrof _bhvOpenableGrill (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560783) ::
                Init_int32 (Int.repr (-20059013)) ::
                Init_int32 (Int.repr 162725888) ::
                Init_int32 (Int.repr 17694720) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvFloorSwitchGrills (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560778) ::
                Init_int32 (Int.repr 83232720) ::
                Init_int32 (Int.repr 262144000) ::
                Init_int32 (Int.repr 17694720) ::
                Init_int32 (Int.repr 161742848) ::
                Init_addrof _bhvPlatformOnTrack (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_local_3 := {|
  gvar_info := (tarray tuint 25);
  gvar_init := (Init_int32 (Int.repr 605560680) ::
                Init_int32 (Int.repr (-231478121)) ::
                Init_int32 (Int.repr 233177088) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvDorrie (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr (-399307773)) ::
                Init_int32 (Int.repr (-511639552)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvBigBoulderGenerator (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr (-32766400)) ::
                Init_int32 (Int.repr 229376000) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 262144) ::
                Init_addrof _bhvFlamethrower (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr (-32766400)) ::
                Init_int32 (Int.repr 249036800) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 262144) ::
                Init_addrof _bhvFlamethrower (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_local_4 := {|
  gvar_info := (tarray tuint 37);
  gvar_init := (Init_int32 (Int.repr 605568890) ::
                Init_int32 (Int.repr (-235868064)) ::
                Init_int32 (Int.repr 235929600) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvStar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568768) ::
                Init_int32 (Int.repr 262144300) ::
                Init_int32 (Int.repr 327680000) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 16777216) ::
                Init_addrof _bhvHiddenRedCoinStar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568890) ::
                Init_int32 (Int.repr 406384336) ::
                Init_int32 (Int.repr 150732800) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 33554432) ::
                Init_addrof _bhvStar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568890) ::
                Init_int32 (Int.repr (-137623500)) ::
                Init_int32 (Int.repr (-494796800)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 50331648) ::
                Init_addrof _bhvStar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568890) ::
                Init_int32 (Int.repr (-425981300)) ::
                Init_int32 (Int.repr (-104857600)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 67108864) ::
                Init_addrof _bhvStar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568890) ::
                Init_int32 (Int.repr (-327676950)) ::
                Init_int32 (Int.repr (-439091200)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 83886080) ::
                Init_addrof _bhvStar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_hmc_entry := {|
  gvar_info := (tarray tuint 106);
  gvar_init := (Init_int32 (Int.repr 453246976) ::
                Init_int32 (Int.repr 403439623) ::
                Init_addrof __hmc_segment_7SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __hmc_segment_7SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 436994057) ::
                Init_addrof __cave_mio0SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __cave_mio0SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 403439621) ::
                Init_addrof __group6_mio0SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __group6_mio0SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 386662412) ::
                Init_addrof __group6_geoSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __group6_geoSegmentRomEnd (Ptrofs.repr 0) ::
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
                Init_addrof _script_func_global_1 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_global_7 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_global_18 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949661) ::
                Init_addrof _wooden_door_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949663) ::
                Init_addrof _metal_door_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949664) ::
                Init_addrof _hazy_maze_door_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949686) ::
                Init_addrof _hmc_geo_0005A0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949687) ::
                Init_addrof _hmc_geo_0005B8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949688) ::
                Init_addrof _hmc_geo_0005D0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949689) ::
                Init_addrof _hmc_geo_000548 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949690) ::
                Init_addrof _hmc_geo_000570 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949691) ::
                Init_addrof _hmc_geo_000588 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949692) ::
                Init_addrof _hmc_geo_000530 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 520618240) ::
                Init_addrof _hmc_geo_000B90 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr (-468710311)) ::
                Init_int32 (Int.repr 470614016) ::
                Init_int32 (Int.repr 8847360) ::
                Init_int32 (Int.repr 655360) ::
                Init_addrof _bhvSpinAirborneWarp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 219671982) ::
                Init_int32 (Int.repr 312803328) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 873136128) ::
                Init_addrof _bhvWarp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 638061063) ::
                Init_int32 (Int.repr 17432576) ::
                Init_int32 (Int.repr 638061340) ::
                Init_int32 (Int.repr 17432576) ::
                Init_int32 (Int.repr 638119942) ::
                Init_int32 (Int.repr 53739520) ::
                Init_int32 (Int.repr 638120198) ::
                Init_int32 (Int.repr 57016320) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_local_1 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_local_2 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_local_3 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_local_4 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 772276224) ::
                Init_addrof _hmc_seg7_collision_level (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 956825600) ::
                Init_addrof _hmc_seg7_macro_objs (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 789053440) ::
                Init_addrof _hmc_seg7_rooms (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 906493956) ::
                Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 822345729) ::
                Init_int32 (Int.repr 537133056) ::
                Init_int32 (Int.repr 503578624) ::
                Init_int32 (Int.repr 722206976) ::
                Init_int32 (Int.repr 8905744) ::
                Init_int32 (Int.repr 141630477) ::
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
 (_bhvPoleGrabbing, Gvar v_bhvPoleGrabbing) :: (_bhvWarp, Gvar v_bhvWarp) ::
 (_bhvFlame, Gvar v_bhvFlame) ::
 (_bhvHMCElevatorPlatform, Gvar v_bhvHMCElevatorPlatform) ::
 (_bhvFlamethrower, Gvar v_bhvFlamethrower) ::
 (_bhvFloorSwitchGrills, Gvar v_bhvFloorSwitchGrills) ::
 (_bhvOpenableGrill, Gvar v_bhvOpenableGrill) ::
 (_bhvMario, Gvar v_bhvMario) ::
 (_bhvSpinAirborneWarp, Gvar v_bhvSpinAirborneWarp) ::
 (_bhvBigBoulderGenerator, Gvar v_bhvBigBoulderGenerator) ::
 (_bhvStar, Gvar v_bhvStar) ::
 (_bhvHiddenRedCoinStar, Gvar v_bhvHiddenRedCoinStar) ::
 (_bhvControllablePlatform, Gvar v_bhvControllablePlatform) ::
 (_bhvPlatformOnTrack, Gvar v_bhvPlatformOnTrack) ::
 (_bhvDorrie, Gvar v_bhvDorrie) ::
 (__common0_mio0SegmentRomStart, Gvar v__common0_mio0SegmentRomStart) ::
 (__common0_mio0SegmentRomEnd, Gvar v__common0_mio0SegmentRomEnd) ::
 (__common0_geoSegmentRomStart, Gvar v__common0_geoSegmentRomStart) ::
 (__common0_geoSegmentRomEnd, Gvar v__common0_geoSegmentRomEnd) ::
 (__group6_mio0SegmentRomStart, Gvar v__group6_mio0SegmentRomStart) ::
 (__group6_mio0SegmentRomEnd, Gvar v__group6_mio0SegmentRomEnd) ::
 (__group6_geoSegmentRomStart, Gvar v__group6_geoSegmentRomStart) ::
 (__group6_geoSegmentRomEnd, Gvar v__group6_geoSegmentRomEnd) ::
 (__group17_mio0SegmentRomStart, Gvar v__group17_mio0SegmentRomStart) ::
 (__group17_mio0SegmentRomEnd, Gvar v__group17_mio0SegmentRomEnd) ::
 (__group17_geoSegmentRomStart, Gvar v__group17_geoSegmentRomStart) ::
 (__group17_geoSegmentRomEnd, Gvar v__group17_geoSegmentRomEnd) ::
 (__hmc_segment_7SegmentRomStart, Gvar v__hmc_segment_7SegmentRomStart) ::
 (__hmc_segment_7SegmentRomEnd, Gvar v__hmc_segment_7SegmentRomEnd) ::
 (__cave_mio0SegmentRomStart, Gvar v__cave_mio0SegmentRomStart) ::
 (__cave_mio0SegmentRomEnd, Gvar v__cave_mio0SegmentRomEnd) ::
 (_lvl_init_or_update,
   Gfun(External (EF_external "lvl_init_or_update"
                   (mksignature (AST.Xint16signed :: AST.Xint :: nil)
                     AST.Xint cc_default)) (tshort :: tint :: nil) tint
     cc_default)) :: (_script_func_global_1, Gvar v_script_func_global_1) ::
 (_script_func_global_7, Gvar v_script_func_global_7) ::
 (_script_func_global_18, Gvar v_script_func_global_18) ::
 (_wooden_door_geo, Gvar v_wooden_door_geo) ::
 (_metal_door_geo, Gvar v_metal_door_geo) ::
 (_hazy_maze_door_geo, Gvar v_hazy_maze_door_geo) ::
 (_hmc_geo_000530, Gvar v_hmc_geo_000530) ::
 (_hmc_geo_000548, Gvar v_hmc_geo_000548) ::
 (_hmc_geo_000570, Gvar v_hmc_geo_000570) ::
 (_hmc_geo_000588, Gvar v_hmc_geo_000588) ::
 (_hmc_geo_0005A0, Gvar v_hmc_geo_0005A0) ::
 (_hmc_geo_0005B8, Gvar v_hmc_geo_0005B8) ::
 (_hmc_geo_0005D0, Gvar v_hmc_geo_0005D0) ::
 (_hmc_geo_000B90, Gvar v_hmc_geo_000B90) ::
 (_hmc_seg7_collision_level, Gvar v_hmc_seg7_collision_level) ::
 (_hmc_seg7_macro_objs, Gvar v_hmc_seg7_macro_objs) ::
 (_hmc_seg7_rooms, Gvar v_hmc_seg7_rooms) ::
 (_script_func_local_1, Gvar v_script_func_local_1) ::
 (_script_func_local_2, Gvar v_script_func_local_2) ::
 (_script_func_local_3, Gvar v_script_func_local_3) ::
 (_script_func_local_4, Gvar v_script_func_local_4) ::
 (_level_hmc_entry, Gvar v_level_hmc_entry) :: nil).

Definition public_idents : list ident :=
(_level_hmc_entry :: _hmc_seg7_rooms :: _hmc_seg7_macro_objs ::
 _hmc_seg7_collision_level :: _hmc_geo_000B90 :: _hmc_geo_0005D0 ::
 _hmc_geo_0005B8 :: _hmc_geo_0005A0 :: _hmc_geo_000588 :: _hmc_geo_000570 ::
 _hmc_geo_000548 :: _hmc_geo_000530 :: _hazy_maze_door_geo ::
 _metal_door_geo :: _wooden_door_geo :: _script_func_global_18 ::
 _script_func_global_7 :: _script_func_global_1 :: _lvl_init_or_update ::
 __cave_mio0SegmentRomEnd :: __cave_mio0SegmentRomStart ::
 __hmc_segment_7SegmentRomEnd :: __hmc_segment_7SegmentRomStart ::
 __group17_geoSegmentRomEnd :: __group17_geoSegmentRomStart ::
 __group17_mio0SegmentRomEnd :: __group17_mio0SegmentRomStart ::
 __group6_geoSegmentRomEnd :: __group6_geoSegmentRomStart ::
 __group6_mio0SegmentRomEnd :: __group6_mio0SegmentRomStart ::
 __common0_geoSegmentRomEnd :: __common0_geoSegmentRomStart ::
 __common0_mio0SegmentRomEnd :: __common0_mio0SegmentRomStart ::
 _bhvDorrie :: _bhvPlatformOnTrack :: _bhvControllablePlatform ::
 _bhvHiddenRedCoinStar :: _bhvStar :: _bhvBigBoulderGenerator ::
 _bhvSpinAirborneWarp :: _bhvMario :: _bhvOpenableGrill ::
 _bhvFloorSwitchGrills :: _bhvFlamethrower :: _bhvHMCElevatorPlatform ::
 _bhvFlame :: _bhvWarp :: _bhvPoleGrabbing :: ___builtin_debug ::
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
