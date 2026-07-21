(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Produced by: pipeline/clightgen.sh
   From source: ../../../reference-sm64-decomp/levels/ssl/script.c
   clightgen:   The CompCert CompCert AST generator, version 3.15
   Flags:       -normalize -nostdinc -fstruct-passing -I../../../reference-sm64-decomp/include -I../../../reference-sm64-decomp/build/us -I../../../reference-sm64-decomp/build/us/include -I../../../reference-sm64-decomp/src -I../../../reference-sm64-decomp/src/game -I../../../reference-sm64-decomp -I../../../reference-sm64-decomp/include/libc -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1 -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1
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
  Definition source_file := "../../../reference-sm64-decomp/levels/ssl/script.c".
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
Definition __common0_geoSegmentRomEnd : ident := $"_common0_geoSegmentRomEnd".
Definition __common0_geoSegmentRomStart : ident := $"_common0_geoSegmentRomStart".
Definition __common0_mio0SegmentRomEnd : ident := $"_common0_mio0SegmentRomEnd".
Definition __common0_mio0SegmentRomStart : ident := $"_common0_mio0SegmentRomStart".
Definition __generic_mio0SegmentRomEnd : ident := $"_generic_mio0SegmentRomEnd".
Definition __generic_mio0SegmentRomStart : ident := $"_generic_mio0SegmentRomStart".
Definition __group5_geoSegmentRomEnd : ident := $"_group5_geoSegmentRomEnd".
Definition __group5_geoSegmentRomStart : ident := $"_group5_geoSegmentRomStart".
Definition __group5_mio0SegmentRomEnd : ident := $"_group5_mio0SegmentRomEnd".
Definition __group5_mio0SegmentRomStart : ident := $"_group5_mio0SegmentRomStart".
Definition __ssl_segment_7SegmentRomEnd : ident := $"_ssl_segment_7SegmentRomEnd".
Definition __ssl_segment_7SegmentRomStart : ident := $"_ssl_segment_7SegmentRomStart".
Definition __ssl_skybox_mio0SegmentRomEnd : ident := $"_ssl_skybox_mio0SegmentRomEnd".
Definition __ssl_skybox_mio0SegmentRomStart : ident := $"_ssl_skybox_mio0SegmentRomStart".
Definition _bhvAirborneWarp : ident := $"bhvAirborneWarp".
Definition _bhvEyerokBoss : ident := $"bhvEyerokBoss".
Definition _bhvFadingWarp : ident := $"bhvFadingWarp".
Definition _bhvGrindel : ident := $"bhvGrindel".
Definition _bhvHiddenRedCoinStar : ident := $"bhvHiddenRedCoinStar".
Definition _bhvHiddenStar : ident := $"bhvHiddenStar".
Definition _bhvHorizontalGrindel : ident := $"bhvHorizontalGrindel".
Definition _bhvKlepto : ident := $"bhvKlepto".
Definition _bhvMario : ident := $"bhvMario".
Definition _bhvPoleGrabbing : ident := $"bhvPoleGrabbing".
Definition _bhvPyramidElevator : ident := $"bhvPyramidElevator".
Definition _bhvPyramidTop : ident := $"bhvPyramidTop".
Definition _bhvSSLMovingPyramidWall : ident := $"bhvSSLMovingPyramidWall".
Definition _bhvSandSoundLoop : ident := $"bhvSandSoundLoop".
Definition _bhvSpinAirborneWarp : ident := $"bhvSpinAirborneWarp".
Definition _bhvSpindel : ident := $"bhvSpindel".
Definition _bhvStar : ident := $"bhvStar".
Definition _bhvToxBox : ident := $"bhvToxBox".
Definition _bhvTweester : ident := $"bhvTweester".
Definition _bhvWarp : ident := $"bhvWarp".
Definition _level_ssl_entry : ident := $"level_ssl_entry".
Definition _lvl_init_or_update : ident := $"lvl_init_or_update".
Definition _main : ident := $"main".
Definition _palm_tree_geo : ident := $"palm_tree_geo".
Definition _script_func_global_1 : ident := $"script_func_global_1".
Definition _script_func_global_6 : ident := $"script_func_global_6".
Definition _script_func_local_1 : ident := $"script_func_local_1".
Definition _script_func_local_2 : ident := $"script_func_local_2".
Definition _script_func_local_3 : ident := $"script_func_local_3".
Definition _script_func_local_4 : ident := $"script_func_local_4".
Definition _script_func_local_5 : ident := $"script_func_local_5".
Definition _script_func_local_6 : ident := $"script_func_local_6".
Definition _ssl_geo_0005C0 : ident := $"ssl_geo_0005C0".
Definition _ssl_geo_0005D8 : ident := $"ssl_geo_0005D8".
Definition _ssl_geo_000618 : ident := $"ssl_geo_000618".
Definition _ssl_geo_000630 : ident := $"ssl_geo_000630".
Definition _ssl_geo_000648 : ident := $"ssl_geo_000648".
Definition _ssl_geo_000734 : ident := $"ssl_geo_000734".
Definition _ssl_geo_000764 : ident := $"ssl_geo_000764".
Definition _ssl_geo_000794 : ident := $"ssl_geo_000794".
Definition _ssl_geo_0007AC : ident := $"ssl_geo_0007AC".
Definition _ssl_geo_0007CC : ident := $"ssl_geo_0007CC".
Definition _ssl_geo_00088C : ident := $"ssl_geo_00088C".
Definition _ssl_seg7_area_1_collision : ident := $"ssl_seg7_area_1_collision".
Definition _ssl_seg7_area_1_macro_objs : ident := $"ssl_seg7_area_1_macro_objs".
Definition _ssl_seg7_area_2_collision : ident := $"ssl_seg7_area_2_collision".
Definition _ssl_seg7_area_2_macro_objs : ident := $"ssl_seg7_area_2_macro_objs".
Definition _ssl_seg7_area_3_collision : ident := $"ssl_seg7_area_3_collision".
Definition _ssl_seg7_area_3_macro_objs : ident := $"ssl_seg7_area_3_macro_objs".

Definition v_bhvPoleGrabbing := {|
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

Definition v_bhvWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvGrindel := {|
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

Definition v_bhvTweester := {|
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

Definition v_bhvSpinAirborneWarp := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSpindel := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSSLMovingPyramidWall := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvPyramidElevator := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvPyramidTop := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSandSoundLoop := {|
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

Definition v_bhvHiddenStar := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvHorizontalGrindel := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvEyerokBoss := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvKlepto := {|
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

Definition v__group5_mio0SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group5_mio0SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group5_geoSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group5_geoSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__ssl_segment_7SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__ssl_segment_7SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__ssl_skybox_mio0SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__ssl_skybox_mio0SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__generic_mio0SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__generic_mio0SegmentRomEnd := {|
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

Definition v_script_func_global_6 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_palm_tree_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_ssl_geo_0005C0 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ssl_geo_0005D8 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ssl_geo_000618 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ssl_geo_000630 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ssl_geo_000648 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ssl_geo_000734 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ssl_geo_000764 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ssl_geo_000794 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ssl_geo_0007AC := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ssl_geo_0007CC := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ssl_geo_00088C := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ssl_seg7_area_1_collision := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ssl_seg7_area_1_macro_objs := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ssl_seg7_area_2_collision := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ssl_seg7_area_3_collision := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ssl_seg7_area_2_macro_objs := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ssl_seg7_area_3_macro_objs := {|
  gvar_info := (tarray tshort 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_local_1 := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 605560634) ::
                Init_int32 (Int.repr (-134150656)) ::
                Init_int32 (Int.repr (-67043328)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvPyramidTop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_local_2 := {|
  gvar_info := (tarray tuint 49);
  gvar_init := (Init_int32 (Int.repr 605560775) ::
                Init_int32 (Int.repr (-84148224)) ::
                Init_int32 (Int.repr (-386334720)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvToxBox (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560775) ::
                Init_int32 (Int.repr 84082688) ::
                Init_int32 (Int.repr (-318832640)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 65536) ::
                Init_addrof _bhvToxBox (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560775) ::
                Init_int32 (Int.repr 319356928) ::
                Init_int32 (Int.repr (-218562560)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 131072) ::
                Init_addrof _bhvToxBox (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560662) ::
                Init_int32 (Int.repr (-235864264)) ::
                Init_int32 (Int.repr 192675840) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 1179648) ::
                Init_addrof _bhvTweester (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605567062) ::
                Init_int32 (Int.repr 66715448) ::
                Init_int32 (Int.repr 251133952) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 1638400) ::
                Init_addrof _bhvTweester (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605567062) ::
                Init_int32 (Int.repr 200998712) ::
                Init_int32 (Int.repr 26214400) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 1638400) ::
                Init_addrof _bhvTweester (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605552983) ::
                Init_int32 (Int.repr 144180374) ::
                Init_int32 (Int.repr (-184811520)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 65536) ::
                Init_addrof _bhvKlepto (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568599) ::
                Init_int32 (Int.repr (-390790595)) ::
                Init_int32 (Int.repr (-313524224)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvKlepto (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_local_3 := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 605568890) ::
                Init_int32 (Int.repr (-134347600)) ::
                Init_int32 (Int.repr (-38010880)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 16777216) ::
                Init_addrof _bhvStar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568768) ::
                Init_int32 (Int.repr 393216800) ::
                Init_int32 (Int.repr 229376000) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 67108864) ::
                Init_addrof _bhvHiddenRedCoinStar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_local_4 := {|
  gvar_info := (tarray tuint 85);
  gvar_init := (Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 187892352) ::
                Init_int32 (Int.repr 187891712) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 5046272) ::
                Init_addrof _bhvPoleGrabbing (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 3200) ::
                Init_int32 (Int.repr 87228416) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 6029312) ::
                Init_addrof _bhvPoleGrabbing (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560630) ::
                Init_int32 (Int.repr 216072192) ::
                Init_int32 (Int.repr 6225920) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 1835008) ::
                Init_addrof _bhvGrindel (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560630) ::
                Init_int32 (Int.repr (-57012480)) ::
                Init_int32 (Int.repr 6881280) ::
                Init_int32 (Int.repr 11796480) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvHorizontalGrindel (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560630) ::
                Init_int32 (Int.repr (-220332032)) ::
                Init_int32 (Int.repr (-90767360)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvHorizontalGrindel (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560631) ::
                Init_int32 (Int.repr (-161085379)) ::
                Init_int32 (Int.repr (-93716480)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvSpindel (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560632) ::
                Init_int32 (Int.repr 56231815) ::
                Init_int32 (Int.repr (-151191552)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvSSLMovingPyramidWall (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560632) ::
                Init_int32 (Int.repr 47843207) ::
                Init_int32 (Int.repr (-151191552)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 65536) ::
                Init_addrof _bhvSSLMovingPyramidWall (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560632) ::
                Init_int32 (Int.repr 96537095) ::
                Init_int32 (Int.repr (-151191552)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 65536) ::
                Init_addrof _bhvSSLMovingPyramidWall (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560632) ::
                Init_int32 (Int.repr 88148487) ::
                Init_int32 (Int.repr (-151191552)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 131072) ::
                Init_addrof _bhvSSLMovingPyramidWall (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560633) ::
                Init_int32 (Int.repr 4966) ::
                Init_int32 (Int.repr 16777216) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvPyramidElevator (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 78577531) ::
                Init_int32 (Int.repr 157024256) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) ::
                Init_addrof _bhvSandSoundLoop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 459981) ::
                Init_int32 (Int.repr (-46399488)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvSandSoundLoop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 463069) ::
                Init_int32 (Int.repr (-46399488)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_addrof _bhvSandSoundLoop (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_local_5 := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 605568890) ::
                Init_int32 (Int.repr 32773050) ::
                Init_int32 (Int.repr (-32768000)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 33554432) ::
                Init_addrof _bhvStar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605568768) ::
                Init_int32 (Int.repr 58983800) ::
                Init_int32 (Int.repr 154009600) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 84148224) ::
                Init_addrof _bhvHiddenStar (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_local_6 := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 64002) ::
                Init_int32 (Int.repr (-242024448)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 50331648) ::
                Init_addrof _bhvEyerokBoss (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_ssl_entry := {|
  gvar_info := (tarray tuint 191);
  gvar_init := (Init_int32 (Int.repr 453246976) ::
                Init_int32 (Int.repr 403439623) ::
                Init_addrof __ssl_segment_7SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __ssl_segment_7SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 403439626) ::
                Init_addrof __ssl_skybox_mio0SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __ssl_skybox_mio0SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 436994057) ::
                Init_addrof __generic_mio0SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __generic_mio0SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 403439621) ::
                Init_addrof __group5_mio0SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __group5_mio0SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 386662412) ::
                Init_addrof __group5_geoSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __group5_geoSegmentRomEnd (Ptrofs.repr 0) ::
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
                Init_addrof _script_func_global_6 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949659) ::
                Init_addrof _palm_tree_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949635) ::
                Init_addrof _ssl_geo_0005C0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949636) ::
                Init_addrof _ssl_geo_0005D8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949690) ::
                Init_addrof _ssl_geo_000618 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949686) ::
                Init_addrof _ssl_geo_000734 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949687) ::
                Init_addrof _ssl_geo_000764 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949688) ::
                Init_addrof _ssl_geo_000794 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949689) ::
                Init_addrof _ssl_geo_0007AC (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949831) ::
                Init_addrof _ssl_geo_000630 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 520618240) ::
                Init_addrof _ssl_geo_000648 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 42796046) ::
                Init_int32 (Int.repr 430309376) ::
                Init_int32 (Int.repr 5898240) ::
                Init_int32 (Int.repr 655360) ::
                Init_addrof _bhvSpinAirborneWarp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr (-134217728)) ::
                Init_int32 (Int.repr 3670016) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 1310720) ::
                Init_addrof _bhvWarp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr (-134216960)) ::
                Init_int32 (Int.repr (-67108864)) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 253624320) ::
                Init_addrof _bhvWarp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 454164480) ::
                Init_int32 (Int.repr (-319225856)) ::
                Init_int32 (Int.repr 10420224) ::
                Init_int32 (Int.repr 2031616) ::
                Init_addrof _bhvFadingWarp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr (-389480448)) ::
                Init_int32 (Int.repr (-321323008)) ::
                Init_int32 (Int.repr 3211264) ::
                Init_int32 (Int.repr 2097152) ::
                Init_addrof _bhvFadingWarp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 638061064) ::
                Init_int32 (Int.repr 17432576) ::
                Init_int32 (Int.repr 638063624) ::
                Init_int32 (Int.repr 34242560) ::
                Init_int32 (Int.repr 638066184) ::
                Init_int32 (Int.repr 34897920) ::
                Init_int32 (Int.repr 638066440) ::
                Init_int32 (Int.repr 18874368) ::
                Init_int32 (Int.repr 638066696) ::
                Init_int32 (Int.repr 18808832) ::
                Init_int32 (Int.repr 638119942) ::
                Init_int32 (Int.repr 53673984) ::
                Init_int32 (Int.repr 638120198) ::
                Init_int32 (Int.repr 56950784) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_local_1 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_local_2 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_local_3 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 772276224) ::
                Init_addrof _ssl_seg7_area_1_collision (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 956825600) ::
                Init_addrof _ssl_seg7_area_1_macro_objs (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 906493952) ::
                Init_int32 (Int.repr 393216) ::
                Init_int32 (Int.repr 822345731) ::
                Init_int32 (Int.repr 537133056) ::
                Init_int32 (Int.repr 520618496) ::
                Init_addrof _ssl_geo_0007CC (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 300) ::
                Init_int32 (Int.repr 422772736) ::
                Init_int32 (Int.repr 11796480) ::
                Init_int32 (Int.repr 655360) ::
                Init_addrof _bhvAirborneWarp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 5500) ::
                Init_int32 (Int.repr 16777216) ::
                Init_int32 (Int.repr 11796480) ::
                Init_int32 (Int.repr 1310720) ::
                Init_addrof _bhvAirborneWarp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 201196800) ::
                Init_int32 (Int.repr 190054400) ::
                Init_int32 (Int.repr 11796480) ::
                Init_int32 (Int.repr 1376256) ::
                Init_addrof _bhvFadingWarp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 605560576) ::
                Init_int32 (Int.repr 166855806) ::
                Init_int32 (Int.repr (-173473792)) ::
                Init_int32 (Int.repr 5111808) ::
                Init_int32 (Int.repr 1441792) ::
                Init_addrof _bhvFadingWarp (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 638061064) ::
                Init_int32 (Int.repr 34209792) ::
                Init_int32 (Int.repr 638063624) ::
                Init_int32 (Int.repr 34865152) ::
                Init_int32 (Int.repr 638063880) ::
                Init_int32 (Int.repr 34996224) ::
                Init_int32 (Int.repr 638064136) ::
                Init_int32 (Int.repr 34930688) ::
                Init_int32 (Int.repr 638119942) ::
                Init_int32 (Int.repr 53673984) ::
                Init_int32 (Int.repr 638120198) ::
                Init_int32 (Int.repr 56950784) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_local_4 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_local_5 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671875843) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 772276224) ::
                Init_addrof _ssl_seg7_area_2_collision (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 956825600) ::
                Init_addrof _ssl_seg7_area_2_macro_objs (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 906493956) ::
                Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 822345729) ::
                Init_int32 (Int.repr 537133056) ::
                Init_int32 (Int.repr 520618752) ::
                Init_addrof _ssl_geo_00088C (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 638119942) ::
                Init_int32 (Int.repr 53673984) ::
                Init_int32 (Int.repr 638120198) ::
                Init_int32 (Int.repr 56950784) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_func_local_6 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 772276224) ::
                Init_addrof _ssl_seg7_area_3_collision (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 956825600) ::
                Init_addrof _ssl_seg7_area_3_macro_objs (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 671875586) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 906493956) ::
                Init_int32 (Int.repr 786432) ::
                Init_int32 (Int.repr 822345729) ::
                Init_int32 (Int.repr 537133056) ::
                Init_int32 (Int.repr 503578624) ::
                Init_int32 (Int.repr 722206976) ::
                Init_int32 (Int.repr 5767821) ::
                Init_int32 (Int.repr 2496934) ::
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
 (_bhvFadingWarp, Gvar v_bhvFadingWarp) :: (_bhvWarp, Gvar v_bhvWarp) ::
 (_bhvGrindel, Gvar v_bhvGrindel) :: (_bhvToxBox, Gvar v_bhvToxBox) ::
 (_bhvTweester, Gvar v_bhvTweester) :: (_bhvMario, Gvar v_bhvMario) ::
 (_bhvAirborneWarp, Gvar v_bhvAirborneWarp) ::
 (_bhvSpinAirborneWarp, Gvar v_bhvSpinAirborneWarp) ::
 (_bhvSpindel, Gvar v_bhvSpindel) ::
 (_bhvSSLMovingPyramidWall, Gvar v_bhvSSLMovingPyramidWall) ::
 (_bhvPyramidElevator, Gvar v_bhvPyramidElevator) ::
 (_bhvPyramidTop, Gvar v_bhvPyramidTop) ::
 (_bhvSandSoundLoop, Gvar v_bhvSandSoundLoop) ::
 (_bhvStar, Gvar v_bhvStar) ::
 (_bhvHiddenRedCoinStar, Gvar v_bhvHiddenRedCoinStar) ::
 (_bhvHiddenStar, Gvar v_bhvHiddenStar) ::
 (_bhvHorizontalGrindel, Gvar v_bhvHorizontalGrindel) ::
 (_bhvEyerokBoss, Gvar v_bhvEyerokBoss) :: (_bhvKlepto, Gvar v_bhvKlepto) ::
 (__common0_mio0SegmentRomStart, Gvar v__common0_mio0SegmentRomStart) ::
 (__common0_mio0SegmentRomEnd, Gvar v__common0_mio0SegmentRomEnd) ::
 (__common0_geoSegmentRomStart, Gvar v__common0_geoSegmentRomStart) ::
 (__common0_geoSegmentRomEnd, Gvar v__common0_geoSegmentRomEnd) ::
 (__group5_mio0SegmentRomStart, Gvar v__group5_mio0SegmentRomStart) ::
 (__group5_mio0SegmentRomEnd, Gvar v__group5_mio0SegmentRomEnd) ::
 (__group5_geoSegmentRomStart, Gvar v__group5_geoSegmentRomStart) ::
 (__group5_geoSegmentRomEnd, Gvar v__group5_geoSegmentRomEnd) ::
 (__ssl_segment_7SegmentRomStart, Gvar v__ssl_segment_7SegmentRomStart) ::
 (__ssl_segment_7SegmentRomEnd, Gvar v__ssl_segment_7SegmentRomEnd) ::
 (__ssl_skybox_mio0SegmentRomStart, Gvar v__ssl_skybox_mio0SegmentRomStart) ::
 (__ssl_skybox_mio0SegmentRomEnd, Gvar v__ssl_skybox_mio0SegmentRomEnd) ::
 (__generic_mio0SegmentRomStart, Gvar v__generic_mio0SegmentRomStart) ::
 (__generic_mio0SegmentRomEnd, Gvar v__generic_mio0SegmentRomEnd) ::
 (_lvl_init_or_update,
   Gfun(External (EF_external "lvl_init_or_update"
                   (mksignature (AST.Xint16signed :: AST.Xint :: nil)
                     AST.Xint cc_default)) (tshort :: tint :: nil) tint
     cc_default)) :: (_script_func_global_1, Gvar v_script_func_global_1) ::
 (_script_func_global_6, Gvar v_script_func_global_6) ::
 (_palm_tree_geo, Gvar v_palm_tree_geo) ::
 (_ssl_geo_0005C0, Gvar v_ssl_geo_0005C0) ::
 (_ssl_geo_0005D8, Gvar v_ssl_geo_0005D8) ::
 (_ssl_geo_000618, Gvar v_ssl_geo_000618) ::
 (_ssl_geo_000630, Gvar v_ssl_geo_000630) ::
 (_ssl_geo_000648, Gvar v_ssl_geo_000648) ::
 (_ssl_geo_000734, Gvar v_ssl_geo_000734) ::
 (_ssl_geo_000764, Gvar v_ssl_geo_000764) ::
 (_ssl_geo_000794, Gvar v_ssl_geo_000794) ::
 (_ssl_geo_0007AC, Gvar v_ssl_geo_0007AC) ::
 (_ssl_geo_0007CC, Gvar v_ssl_geo_0007CC) ::
 (_ssl_geo_00088C, Gvar v_ssl_geo_00088C) ::
 (_ssl_seg7_area_1_collision, Gvar v_ssl_seg7_area_1_collision) ::
 (_ssl_seg7_area_1_macro_objs, Gvar v_ssl_seg7_area_1_macro_objs) ::
 (_ssl_seg7_area_2_collision, Gvar v_ssl_seg7_area_2_collision) ::
 (_ssl_seg7_area_3_collision, Gvar v_ssl_seg7_area_3_collision) ::
 (_ssl_seg7_area_2_macro_objs, Gvar v_ssl_seg7_area_2_macro_objs) ::
 (_ssl_seg7_area_3_macro_objs, Gvar v_ssl_seg7_area_3_macro_objs) ::
 (_script_func_local_1, Gvar v_script_func_local_1) ::
 (_script_func_local_2, Gvar v_script_func_local_2) ::
 (_script_func_local_3, Gvar v_script_func_local_3) ::
 (_script_func_local_4, Gvar v_script_func_local_4) ::
 (_script_func_local_5, Gvar v_script_func_local_5) ::
 (_script_func_local_6, Gvar v_script_func_local_6) ::
 (_level_ssl_entry, Gvar v_level_ssl_entry) :: nil).

Definition public_idents : list ident :=
(_level_ssl_entry :: _ssl_seg7_area_3_macro_objs ::
 _ssl_seg7_area_2_macro_objs :: _ssl_seg7_area_3_collision ::
 _ssl_seg7_area_2_collision :: _ssl_seg7_area_1_macro_objs ::
 _ssl_seg7_area_1_collision :: _ssl_geo_00088C :: _ssl_geo_0007CC ::
 _ssl_geo_0007AC :: _ssl_geo_000794 :: _ssl_geo_000764 :: _ssl_geo_000734 ::
 _ssl_geo_000648 :: _ssl_geo_000630 :: _ssl_geo_000618 :: _ssl_geo_0005D8 ::
 _ssl_geo_0005C0 :: _palm_tree_geo :: _script_func_global_6 ::
 _script_func_global_1 :: _lvl_init_or_update ::
 __generic_mio0SegmentRomEnd :: __generic_mio0SegmentRomStart ::
 __ssl_skybox_mio0SegmentRomEnd :: __ssl_skybox_mio0SegmentRomStart ::
 __ssl_segment_7SegmentRomEnd :: __ssl_segment_7SegmentRomStart ::
 __group5_geoSegmentRomEnd :: __group5_geoSegmentRomStart ::
 __group5_mio0SegmentRomEnd :: __group5_mio0SegmentRomStart ::
 __common0_geoSegmentRomEnd :: __common0_geoSegmentRomStart ::
 __common0_mio0SegmentRomEnd :: __common0_mio0SegmentRomStart ::
 _bhvKlepto :: _bhvEyerokBoss :: _bhvHorizontalGrindel :: _bhvHiddenStar ::
 _bhvHiddenRedCoinStar :: _bhvStar :: _bhvSandSoundLoop :: _bhvPyramidTop ::
 _bhvPyramidElevator :: _bhvSSLMovingPyramidWall :: _bhvSpindel ::
 _bhvSpinAirborneWarp :: _bhvAirborneWarp :: _bhvMario :: _bhvTweester ::
 _bhvToxBox :: _bhvGrindel :: _bhvWarp :: _bhvFadingWarp ::
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
