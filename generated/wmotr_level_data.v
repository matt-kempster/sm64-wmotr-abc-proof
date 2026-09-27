(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Produced by: pipeline/clightgen.sh
   From source: pipeline/tu/wmotr_level_data.c
   clightgen:   The CompCert CompCert AST generator, version 3.15
   Flags:       -normalize -nostdinc -fstruct-passing -Ivendor/sm64/include -Ivendor/sm64/build/us -Ivendor/sm64/build/us/include -Ivendor/sm64/src -Ivendor/sm64 -Ivendor/sm64/include/libc -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1 -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 (+ __stringlit_ -> __stringlit_wmotr_level_data_)
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
  Definition arch := "powerpc".
  Definition model := "ppc32".
  Definition abi := "eabi".
  Definition bitsize := 32.
  Definition big_endian := true.
  Definition source_file := "pipeline/tu/wmotr_level_data.c".
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
Definition _cannon_lid_seg8_collision_08004950 : ident := $"cannon_lid_seg8_collision_08004950".
Definition _exclamation_box_outline_seg8_collision_08025F78 : ident := $"exclamation_box_outline_seg8_collision_08025F78".
Definition _main : ident := $"main".
Definition _wmotr_seg7_collision : ident := $"wmotr_seg7_collision".
Definition _wmotr_seg7_macro_objs : ident := $"wmotr_seg7_macro_objs".

Definition v_wmotr_seg7_collision := {|
  gvar_info := (tarray tshort 6159);
  gvar_init := (Init_int16 (Int.repr 64) :: Init_int16 (Int.repr 694) ::
                Init_int16 (Int.repr 8192) ::
                Init_int16 (Int.repr (-8191)) ::
                Init_int16 (Int.repr (-8191)) ::
                Init_int16 (Int.repr (-8191)) ::
                Init_int16 (Int.repr (-8191)) ::
                Init_int16 (Int.repr (-8191)) ::
                Init_int16 (Int.repr (-8191)) ::
                Init_int16 (Int.repr (-8191)) ::
                Init_int16 (Int.repr 8192) :: Init_int16 (Int.repr 8192) ::
                Init_int16 (Int.repr (-8191)) ::
                Init_int16 (Int.repr 8192) ::
                Init_int16 (Int.repr (-2851)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-4091)) ::
                Init_int16 (Int.repr (-3358)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-4101)) ::
                Init_int16 (Int.repr (-2691)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-4040)) ::
                Init_int16 (Int.repr (-3172)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-4261)) ::
                Init_int16 (Int.repr (-2955)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-4241)) ::
                Init_int16 (Int.repr (-3465)) ::
                Init_int16 (Int.repr 1968) ::
                Init_int16 (Int.repr (-4172)) ::
                Init_int16 (Int.repr (-3398)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-3950)) ::
                Init_int16 (Int.repr (-2763)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-3982)) ::
                Init_int16 (Int.repr (-2816)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-3921)) ::
                Init_int16 (Int.repr (-2915)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-3739)) ::
                Init_int16 (Int.repr (-3066)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-3665)) ::
                Init_int16 (Int.repr (-3255)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-3709)) ::
                Init_int16 (Int.repr (-3365)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-3821)) ::
                Init_int16 (Int.repr (-2690)) ::
                Init_int16 (Int.repr 1968) ::
                Init_int16 (Int.repr (-3915)) ::
                Init_int16 (Int.repr (-2477)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-4439)) ::
                Init_int16 (Int.repr (-2434)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-4266)) ::
                Init_int16 (Int.repr (-2536)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-4122)) ::
                Init_int16 (Int.repr (-2613)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-4548)) ::
                Init_int16 (Int.repr (-2872)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-4417)) ::
                Init_int16 (Int.repr (-2770)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-4532)) ::
                Init_int16 (Int.repr (-2456)) ::
                Init_int16 (Int.repr 1968) ::
                Init_int16 (Int.repr (-4039)) ::
                Init_int16 (Int.repr (-3357)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-4585)) ::
                Init_int16 (Int.repr (-2888)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-4606)) ::
                Init_int16 (Int.repr (-2832)) ::
                Init_int16 (Int.repr 1968) ::
                Init_int16 (Int.repr (-3655)) ::
                Init_int16 (Int.repr (-3048)) ::
                Init_int16 (Int.repr 1968) ::
                Init_int16 (Int.repr (-3549)) ::
                Init_int16 (Int.repr (-3319)) ::
                Init_int16 (Int.repr 1968) ::
                Init_int16 (Int.repr (-3612)) ::
                Init_int16 (Int.repr (-3476)) ::
                Init_int16 (Int.repr 1968) ::
                Init_int16 (Int.repr (-3771)) ::
                Init_int16 (Int.repr (-3522)) ::
                Init_int16 (Int.repr 1968) ::
                Init_int16 (Int.repr (-3956)) ::
                Init_int16 (Int.repr (-2986)) ::
                Init_int16 (Int.repr 1968) ::
                Init_int16 (Int.repr (-4801)) ::
                Init_int16 (Int.repr (-2811)) ::
                Init_int16 (Int.repr 1885) ::
                Init_int16 (Int.repr (-4660)) ::
                Init_int16 (Int.repr (-2986)) ::
                Init_int16 (Int.repr 1885) ::
                Init_int16 (Int.repr (-4801)) ::
                Init_int16 (Int.repr (-2573)) ::
                Init_int16 (Int.repr 1885) ::
                Init_int16 (Int.repr (-4686)) ::
                Init_int16 (Int.repr (-2366)) ::
                Init_int16 (Int.repr 1885) ::
                Init_int16 (Int.repr (-4520)) ::
                Init_int16 (Int.repr (-2301)) ::
                Init_int16 (Int.repr 1885) ::
                Init_int16 (Int.repr (-4258)) ::
                Init_int16 (Int.repr (-2456)) ::
                Init_int16 (Int.repr 1885) ::
                Init_int16 (Int.repr (-4039)) ::
                Init_int16 (Int.repr (-2690)) ::
                Init_int16 (Int.repr 1885) ::
                Init_int16 (Int.repr (-3915)) ::
                Init_int16 (Int.repr (-3430)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-4449)) ::
                Init_int16 (Int.repr (-3418)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-4322)) ::
                Init_int16 (Int.repr (-3522)) ::
                Init_int16 (Int.repr 1885) ::
                Init_int16 (Int.repr (-3956)) ::
                Init_int16 (Int.repr (-3465)) ::
                Init_int16 (Int.repr 1885) ::
                Init_int16 (Int.repr (-4172)) ::
                Init_int16 (Int.repr (-3534)) ::
                Init_int16 (Int.repr 1885) ::
                Init_int16 (Int.repr (-4279)) ::
                Init_int16 (Int.repr (-3447)) ::
                Init_int16 (Int.repr 1968) ::
                Init_int16 (Int.repr (-4653)) ::
                Init_int16 (Int.repr (-3552)) ::
                Init_int16 (Int.repr 1885) ::
                Init_int16 (Int.repr (-4460)) ::
                Init_int16 (Int.repr (-3216)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-4679)) ::
                Init_int16 (Int.repr (-3447)) ::
                Init_int16 (Int.repr 1885) ::
                Init_int16 (Int.repr (-4653)) ::
                Init_int16 (Int.repr (-3034)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-4688)) ::
                Init_int16 (Int.repr (-3246)) ::
                Init_int16 (Int.repr 1885) ::
                Init_int16 (Int.repr (-4788)) ::
                Init_int16 (Int.repr (-2832)) ::
                Init_int16 (Int.repr 1885) ::
                Init_int16 (Int.repr (-3655)) ::
                Init_int16 (Int.repr (-3048)) ::
                Init_int16 (Int.repr 1885) ::
                Init_int16 (Int.repr (-3549)) ::
                Init_int16 (Int.repr (-3319)) ::
                Init_int16 (Int.repr 1885) ::
                Init_int16 (Int.repr (-3612)) ::
                Init_int16 (Int.repr (-3476)) ::
                Init_int16 (Int.repr 1885) ::
                Init_int16 (Int.repr (-3771)) ::
                Init_int16 (Int.repr (-2842)) ::
                Init_int16 (Int.repr 1843) ::
                Init_int16 (Int.repr (-3693)) ::
                Init_int16 (Int.repr (-3044)) ::
                Init_int16 (Int.repr 1843) ::
                Init_int16 (Int.repr (-3594)) ::
                Init_int16 (Int.repr (-3447)) ::
                Init_int16 (Int.repr 1843) ::
                Init_int16 (Int.repr (-3803)) ::
                Init_int16 (Int.repr (-3436)) ::
                Init_int16 (Int.repr 1843) ::
                Init_int16 (Int.repr (-4179)) ::
                Init_int16 (Int.repr (-3501)) ::
                Init_int16 (Int.repr 1843) ::
                Init_int16 (Int.repr (-4280)) ::
                Init_int16 (Int.repr (-2708)) ::
                Init_int16 (Int.repr 1843) ::
                Init_int16 (Int.repr (-3938)) ::
                Init_int16 (Int.repr (-2488)) ::
                Init_int16 (Int.repr 1843) ::
                Init_int16 (Int.repr (-4054)) ::
                Init_int16 (Int.repr (-2342)) ::
                Init_int16 (Int.repr 1843) ::
                Init_int16 (Int.repr (-4260)) ::
                Init_int16 (Int.repr (-2403)) ::
                Init_int16 (Int.repr 1843) ::
                Init_int16 (Int.repr (-4507)) ::
                Init_int16 (Int.repr (-2598)) ::
                Init_int16 (Int.repr 1843) ::
                Init_int16 (Int.repr (-4663)) ::
                Init_int16 (Int.repr (-2821)) ::
                Init_int16 (Int.repr 1843) ::
                Init_int16 (Int.repr (-4639)) ::
                Init_int16 (Int.repr (-3230)) ::
                Init_int16 (Int.repr 1843) ::
                Init_int16 (Int.repr (-4759)) ::
                Init_int16 (Int.repr (-3419)) ::
                Init_int16 (Int.repr 1843) ::
                Init_int16 (Int.repr (-4632)) ::
                Init_int16 (Int.repr (-3518)) ::
                Init_int16 (Int.repr 1843) ::
                Init_int16 (Int.repr (-4450)) ::
                Init_int16 (Int.repr 4233) :: Init_int16 (Int.repr 174) ::
                Init_int16 (Int.repr 207) :: Init_int16 (Int.repr 4393) ::
                Init_int16 (Int.repr 174) :: Init_int16 (Int.repr 258) ::
                Init_int16 (Int.repr 3619) :: Init_int16 (Int.repr 124) ::
                Init_int16 (Int.repr 127) :: Init_int16 (Int.repr 3726) ::
                Init_int16 (Int.repr 174) :: Init_int16 (Int.repr 198) ::
                Init_int16 (Int.repr 4393) :: Init_int16 (Int.repr 124) ::
                Init_int16 (Int.repr 383) :: Init_int16 (Int.repr 3911) ::
                Init_int16 (Int.repr 174) :: Init_int16 (Int.repr 38) ::
                Init_int16 (Int.repr 4211) :: Init_int16 (Int.repr 174) ::
                Init_int16 (Int.repr (-118)) :: Init_int16 (Int.repr 4196) ::
                Init_int16 (Int.repr 174) :: Init_int16 (Int.repr (-306)) ::
                Init_int16 (Int.repr 3726) :: Init_int16 (Int.repr 174) ::
                Init_int16 (Int.repr (-285)) :: Init_int16 (Int.repr 4470) ::
                Init_int16 (Int.repr 174) :: Init_int16 (Int.repr (-249)) ::
                Init_int16 (Int.repr 4607) :: Init_int16 (Int.repr 174) ::
                Init_int16 (Int.repr (-140)) :: Init_int16 (Int.repr 4650) ::
                Init_int16 (Int.repr 174) :: Init_int16 (Int.repr 33) ::
                Init_int16 (Int.repr 4547) :: Init_int16 (Int.repr 174) ::
                Init_int16 (Int.repr 177) :: Init_int16 (Int.repr 4268) ::
                Init_int16 (Int.repr 174) :: Init_int16 (Int.repr 377) ::
                Init_int16 (Int.repr 4168) :: Init_int16 (Int.repr 174) ::
                Init_int16 (Int.repr 560) :: Init_int16 (Int.repr 4017) ::
                Init_int16 (Int.repr 174) :: Init_int16 (Int.repr 633) ::
                Init_int16 (Int.repr 3828) :: Init_int16 (Int.repr 174) ::
                Init_int16 (Int.repr 589) :: Init_int16 (Int.repr 3718) ::
                Init_int16 (Int.repr 174) :: Init_int16 (Int.repr 478) ::
                Init_int16 (Int.repr 3608) :: Init_int16 (Int.repr 124) ::
                Init_int16 (Int.repr 527) :: Init_int16 (Int.repr 3561) ::
                Init_int16 (Int.repr 124) :: Init_int16 (Int.repr 342) ::
                Init_int16 (Int.repr 4273) :: Init_int16 (Int.repr 41) ::
                Init_int16 (Int.repr (-360)) :: Init_int16 (Int.repr 4098) ::
                Init_int16 (Int.repr 41) :: Init_int16 (Int.repr (-502)) ::
                Init_int16 (Int.repr 4098) :: Init_int16 (Int.repr 124) ::
                Init_int16 (Int.repr (-502)) :: Init_int16 (Int.repr 4510) ::
                Init_int16 (Int.repr 41) :: Init_int16 (Int.repr (-386)) ::
                Init_int16 (Int.repr 4717) :: Init_int16 (Int.repr 41) ::
                Init_int16 (Int.repr (-221)) :: Init_int16 (Int.repr 4783) ::
                Init_int16 (Int.repr 41) :: Init_int16 (Int.repr 41) ::
                Init_int16 (Int.repr 4627) :: Init_int16 (Int.repr 41) ::
                Init_int16 (Int.repr 260) :: Init_int16 (Int.repr 4393) ::
                Init_int16 (Int.repr 41) :: Init_int16 (Int.repr 383) ::
                Init_int16 (Int.repr 3653) :: Init_int16 (Int.repr 174) ::
                Init_int16 (Int.repr (-150)) :: Init_int16 (Int.repr 3665) ::
                Init_int16 (Int.repr 174) :: Init_int16 (Int.repr (-23)) ::
                Init_int16 (Int.repr 3619) :: Init_int16 (Int.repr 41) ::
                Init_int16 (Int.repr 127) :: Init_int16 (Int.repr 3561) ::
                Init_int16 (Int.repr 41) :: Init_int16 (Int.repr 342) ::
                Init_int16 (Int.repr 3550) :: Init_int16 (Int.repr 41) ::
                Init_int16 (Int.repr 20) :: Init_int16 (Int.repr 3637) ::
                Init_int16 (Int.repr 124) :: Init_int16 (Int.repr (-354)) ::
                Init_int16 (Int.repr 3532) :: Init_int16 (Int.repr 41) ::
                Init_int16 (Int.repr (-161)) :: Init_int16 (Int.repr 3867) ::
                Init_int16 (Int.repr 174) :: Init_int16 (Int.repr (-379)) ::
                Init_int16 (Int.repr 3637) :: Init_int16 (Int.repr 41) ::
                Init_int16 (Int.repr (-354)) :: Init_int16 (Int.repr 4049) ::
                Init_int16 (Int.repr 174) :: Init_int16 (Int.repr (-388)) ::
                Init_int16 (Int.repr 3838) :: Init_int16 (Int.repr 41) ::
                Init_int16 (Int.repr (-488)) :: Init_int16 (Int.repr 4251) ::
                Init_int16 (Int.repr 41) :: Init_int16 (Int.repr 644) ::
                Init_int16 (Int.repr 4035) :: Init_int16 (Int.repr 41) ::
                Init_int16 (Int.repr 749) :: Init_int16 (Int.repr 3765) ::
                Init_int16 (Int.repr 41) :: Init_int16 (Int.repr 686) ::
                Init_int16 (Int.repr 3608) :: Init_int16 (Int.repr 41) ::
                Init_int16 (Int.repr 527) :: Init_int16 (Int.repr 4242) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 606) ::
                Init_int16 (Int.repr 4039) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 705) :: Init_int16 (Int.repr 3637) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 496) ::
                Init_int16 (Int.repr 3647) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 119) :: Init_int16 (Int.repr 4375) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 360) ::
                Init_int16 (Int.repr 3582) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 19) :: Init_int16 (Int.repr 4595) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 244) ::
                Init_int16 (Int.repr 4742) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 38) :: Init_int16 (Int.repr 4680) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr (-208)) ::
                Init_int16 (Int.repr 4486) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr (-363)) :: Init_int16 (Int.repr 4262) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr (-339)) ::
                Init_int16 (Int.repr 3853) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr (-459)) :: Init_int16 (Int.repr 3664) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr (-333)) ::
                Init_int16 (Int.repr 3565) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr (-151)) ::
                Init_int16 (Int.repr (-1099)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4467) :: Init_int16 (Int.repr (-495)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4608) :: Init_int16 (Int.repr (-968)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4380) :: Init_int16 (Int.repr (-333)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4944) :: Init_int16 (Int.repr (-978)) ::
                Init_int16 (Int.repr (-1443)) ::
                Init_int16 (Int.repr 4323) :: Init_int16 (Int.repr (-414)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4291) :: Init_int16 (Int.repr (-89)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4576) :: Init_int16 (Int.repr (-841)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4167) :: Init_int16 (Int.repr (-51)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4577) :: Init_int16 (Int.repr (-372)) ::
                Init_int16 (Int.repr (-1443)) ::
                Init_int16 (Int.repr 4066) :: Init_int16 (Int.repr (-72)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4818) :: Init_int16 (Int.repr 108) ::
                Init_int16 (Int.repr (-1443)) ::
                Init_int16 (Int.repr 4571) :: Init_int16 (Int.repr (-378)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4733) :: Init_int16 (Int.repr (-739)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4076) :: Init_int16 (Int.repr (-591)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4058) :: Init_int16 (Int.repr (-369)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4300) :: Init_int16 (Int.repr (-162)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4093) :: Init_int16 (Int.repr (-22)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4138) :: Init_int16 (Int.repr 15) ::
                Init_int16 (Int.repr (-1443)) ::
                Init_int16 (Int.repr 4058) :: Init_int16 (Int.repr 78) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4255) :: Init_int16 (Int.repr 100) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4389) :: Init_int16 (Int.repr 186) ::
                Init_int16 (Int.repr (-1443)) ::
                Init_int16 (Int.repr 4408) :: Init_int16 (Int.repr 140) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4739) :: Init_int16 (Int.repr 194) ::
                Init_int16 (Int.repr (-1443)) ::
                Init_int16 (Int.repr 4719) :: Init_int16 (Int.repr 97) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4956) :: Init_int16 (Int.repr (-57)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 5074) :: Init_int16 (Int.repr (-232)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 5068) :: Init_int16 (Int.repr (-271)) ::
                Init_int16 (Int.repr (-1443)) ::
                Init_int16 (Int.repr 5130) :: Init_int16 (Int.repr (-723)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4770) :: Init_int16 (Int.repr (-932)) ::
                Init_int16 (Int.repr (-1443)) ::
                Init_int16 (Int.repr 4913) :: Init_int16 (Int.repr (-863)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4932) :: Init_int16 (Int.repr (-767)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4775) ::
                Init_int16 (Int.repr (-1080)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4791) ::
                Init_int16 (Int.repr (-1118)) ::
                Init_int16 (Int.repr (-1443)) ::
                Init_int16 (Int.repr 4835) ::
                Init_int16 (Int.repr (-1204)) ::
                Init_int16 (Int.repr (-1443)) ::
                Init_int16 (Int.repr 4626) :: Init_int16 (Int.repr (-416)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 5243) :: Init_int16 (Int.repr (-593)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 5286) :: Init_int16 (Int.repr (-776)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 5205) :: Init_int16 (Int.repr (-857)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 5075) :: Init_int16 (Int.repr (-924)) ::
                Init_int16 (Int.repr (-1489)) ::
                Init_int16 (Int.repr 5092) :: Init_int16 (Int.repr (-932)) ::
                Init_int16 (Int.repr (-1489)) ::
                Init_int16 (Int.repr 4913) :: Init_int16 (Int.repr (-823)) ::
                Init_int16 (Int.repr (-1489)) ::
                Init_int16 (Int.repr 5255) :: Init_int16 (Int.repr (-594)) ::
                Init_int16 (Int.repr (-1489)) ::
                Init_int16 (Int.repr 5355) :: Init_int16 (Int.repr (-372)) ::
                Init_int16 (Int.repr (-1489)) ::
                Init_int16 (Int.repr 5301) :: Init_int16 (Int.repr (-271)) ::
                Init_int16 (Int.repr (-1489)) ::
                Init_int16 (Int.repr 5130) :: Init_int16 (Int.repr (-53)) ::
                Init_int16 (Int.repr (-1489)) ::
                Init_int16 (Int.repr 5138) ::
                Init_int16 (Int.repr (-1204)) ::
                Init_int16 (Int.repr (-1489)) ::
                Init_int16 (Int.repr 4626) ::
                Init_int16 (Int.repr (-1118)) ::
                Init_int16 (Int.repr (-1489)) ::
                Init_int16 (Int.repr 4835) ::
                Init_int16 (Int.repr (-1141)) ::
                Init_int16 (Int.repr (-1489)) ::
                Init_int16 (Int.repr 4431) :: Init_int16 (Int.repr (-978)) ::
                Init_int16 (Int.repr (-1489)) ::
                Init_int16 (Int.repr 4323) :: Init_int16 (Int.repr (-372)) ::
                Init_int16 (Int.repr (-1489)) ::
                Init_int16 (Int.repr 4066) :: Init_int16 (Int.repr (-574)) ::
                Init_int16 (Int.repr (-1489)) ::
                Init_int16 (Int.repr 3957) :: Init_int16 (Int.repr (-785)) ::
                Init_int16 (Int.repr (-1489)) ::
                Init_int16 (Int.repr 3983) :: Init_int16 (Int.repr (-932)) ::
                Init_int16 (Int.repr (-1489)) ::
                Init_int16 (Int.repr 4113) :: Init_int16 (Int.repr 108) ::
                Init_int16 (Int.repr (-1489)) ::
                Init_int16 (Int.repr 4571) :: Init_int16 (Int.repr 186) ::
                Init_int16 (Int.repr (-1489)) ::
                Init_int16 (Int.repr 4408) :: Init_int16 (Int.repr 155) ::
                Init_int16 (Int.repr (-1489)) ::
                Init_int16 (Int.repr 4222) :: Init_int16 (Int.repr 15) ::
                Init_int16 (Int.repr (-1489)) ::
                Init_int16 (Int.repr 4058) :: Init_int16 (Int.repr (-178)) ::
                Init_int16 (Int.repr (-1489)) ::
                Init_int16 (Int.repr 3996) :: Init_int16 (Int.repr 140) ::
                Init_int16 (Int.repr (-1489)) ::
                Init_int16 (Int.repr 4990) :: Init_int16 (Int.repr 194) ::
                Init_int16 (Int.repr (-1489)) ::
                Init_int16 (Int.repr 4719) :: Init_int16 (Int.repr (-902)) ::
                Init_int16 (Int.repr (-1535)) ::
                Init_int16 (Int.repr 5067) :: Init_int16 (Int.repr (-909)) ::
                Init_int16 (Int.repr (-1535)) ::
                Init_int16 (Int.repr 4898) :: Init_int16 (Int.repr (-806)) ::
                Init_int16 (Int.repr (-1535)) ::
                Init_int16 (Int.repr 5222) ::
                Init_int16 (Int.repr (-1108)) ::
                Init_int16 (Int.repr (-1535)) ::
                Init_int16 (Int.repr 4440) :: Init_int16 (Int.repr (-953)) ::
                Init_int16 (Int.repr (-1535)) ::
                Init_int16 (Int.repr 4337) ::
                Init_int16 (Int.repr (-1086)) ::
                Init_int16 (Int.repr (-1535)) ::
                Init_int16 (Int.repr 4824) :: Init_int16 (Int.repr (-588)) ::
                Init_int16 (Int.repr (-1535)) ::
                Init_int16 (Int.repr 5318) :: Init_int16 (Int.repr (-378)) ::
                Init_int16 (Int.repr (-1535)) ::
                Init_int16 (Int.repr 5267) :: Init_int16 (Int.repr (-282)) ::
                Init_int16 (Int.repr (-1535)) ::
                Init_int16 (Int.repr 5104) :: Init_int16 (Int.repr (-75)) ::
                Init_int16 (Int.repr (-1535)) ::
                Init_int16 (Int.repr 5111) :: Init_int16 (Int.repr 109) ::
                Init_int16 (Int.repr (-1535)) ::
                Init_int16 (Int.repr 4971) :: Init_int16 (Int.repr 160) ::
                Init_int16 (Int.repr (-1535)) ::
                Init_int16 (Int.repr 4713) :: Init_int16 (Int.repr 79) ::
                Init_int16 (Int.repr (-1535)) ::
                Init_int16 (Int.repr 4573) :: Init_int16 (Int.repr 152) ::
                Init_int16 (Int.repr (-1535)) ::
                Init_int16 (Int.repr 4418) :: Init_int16 (Int.repr 123) ::
                Init_int16 (Int.repr (-1535)) ::
                Init_int16 (Int.repr 4241) :: Init_int16 (Int.repr (-9)) ::
                Init_int16 (Int.repr (-1535)) ::
                Init_int16 (Int.repr 4086) :: Init_int16 (Int.repr (-193)) ::
                Init_int16 (Int.repr (-1535)) ::
                Init_int16 (Int.repr 4027) :: Init_int16 (Int.repr (-378)) ::
                Init_int16 (Int.repr (-1535)) ::
                Init_int16 (Int.repr 4093) :: Init_int16 (Int.repr (-570)) ::
                Init_int16 (Int.repr (-1535)) ::
                Init_int16 (Int.repr 3990) :: Init_int16 (Int.repr (-770)) ::
                Init_int16 (Int.repr (-1535)) ::
                Init_int16 (Int.repr 4014) :: Init_int16 (Int.repr (-909)) ::
                Init_int16 (Int.repr (-1535)) ::
                Init_int16 (Int.repr 4138) ::
                Init_int16 (Int.repr (-1167)) ::
                Init_int16 (Int.repr (-1535)) ::
                Init_int16 (Int.repr 4625) ::
                Init_int16 (Int.repr (-3008)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-4202)) ::
                Init_int16 (Int.repr (-2811)) ::
                Init_int16 (Int.repr 1968) ::
                Init_int16 (Int.repr (-4660)) ::
                Init_int16 (Int.repr (-2573)) ::
                Init_int16 (Int.repr 1968) ::
                Init_int16 (Int.repr (-4686)) ::
                Init_int16 (Int.repr (-2366)) ::
                Init_int16 (Int.repr 1968) ::
                Init_int16 (Int.repr (-4520)) ::
                Init_int16 (Int.repr (-2301)) ::
                Init_int16 (Int.repr 1968) ::
                Init_int16 (Int.repr (-4258)) ::
                Init_int16 (Int.repr (-3369)) ::
                Init_int16 (Int.repr 2017) ::
                Init_int16 (Int.repr (-4247)) ::
                Init_int16 (Int.repr (-3534)) ::
                Init_int16 (Int.repr 1968) ::
                Init_int16 (Int.repr (-4279)) ::
                Init_int16 (Int.repr (-3552)) ::
                Init_int16 (Int.repr 1968) ::
                Init_int16 (Int.repr (-4460)) ::
                Init_int16 (Int.repr (-3246)) ::
                Init_int16 (Int.repr 1968) ::
                Init_int16 (Int.repr (-4788)) ::
                Init_int16 (Int.repr (-3299)) ::
                Init_int16 (Int.repr 1843) ::
                Init_int16 (Int.repr (-3653)) ::
                Init_int16 (Int.repr (-3491)) ::
                Init_int16 (Int.repr 1843) ::
                Init_int16 (Int.repr (-3977)) ::
                Init_int16 (Int.repr (-2986)) ::
                Init_int16 (Int.repr 1843) ::
                Init_int16 (Int.repr (-4771)) ::
                Init_int16 (Int.repr 4129) :: Init_int16 (Int.repr 174) ::
                Init_int16 (Int.repr 58) :: Init_int16 (Int.repr 4320) ::
                Init_int16 (Int.repr 174) :: Init_int16 (Int.repr 316) ::
                Init_int16 (Int.repr 3685) :: Init_int16 (Int.repr 174) ::
                Init_int16 (Int.repr 348) :: Init_int16 (Int.repr 4627) ::
                Init_int16 (Int.repr 124) :: Init_int16 (Int.repr 260) ::
                Init_int16 (Int.repr 4313) :: Init_int16 (Int.repr 174) ::
                Init_int16 (Int.repr (-232)) :: Init_int16 (Int.repr 4273) ::
                Init_int16 (Int.repr 124) :: Init_int16 (Int.repr (-360)) ::
                Init_int16 (Int.repr 4510) :: Init_int16 (Int.repr 124) ::
                Init_int16 (Int.repr (-386)) :: Init_int16 (Int.repr 4783) ::
                Init_int16 (Int.repr 124) :: Init_int16 (Int.repr 41) ::
                Init_int16 (Int.repr 4251) :: Init_int16 (Int.repr 124) ::
                Init_int16 (Int.repr 644) :: Init_int16 (Int.repr 4035) ::
                Init_int16 (Int.repr 124) :: Init_int16 (Int.repr 749) ::
                Init_int16 (Int.repr 3765) :: Init_int16 (Int.repr 124) ::
                Init_int16 (Int.repr 686) :: Init_int16 (Int.repr 4076) ::
                Init_int16 (Int.repr 174) :: Init_int16 (Int.repr 96) ::
                Init_int16 (Int.repr 3714) :: Init_int16 (Int.repr 174) ::
                Init_int16 (Int.repr 51) :: Init_int16 (Int.repr 4717) ::
                Init_int16 (Int.repr 124) :: Init_int16 (Int.repr (-221)) ::
                Init_int16 (Int.repr 3550) :: Init_int16 (Int.repr 124) ::
                Init_int16 (Int.repr 20) :: Init_int16 (Int.repr 3532) ::
                Init_int16 (Int.repr 124) :: Init_int16 (Int.repr (-161)) ::
                Init_int16 (Int.repr 3838) :: Init_int16 (Int.repr 124) ::
                Init_int16 (Int.repr (-488)) :: Init_int16 (Int.repr 3785) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 646) ::
                Init_int16 (Int.repr 3593) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 322) :: Init_int16 (Int.repr 4098) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr (-472)) ::
                Init_int16 (Int.repr (-627)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4720) :: Init_int16 (Int.repr (-258)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4615) :: Init_int16 (Int.repr (-871)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4365) :: Init_int16 (Int.repr (-874)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4314) :: Init_int16 (Int.repr (-356)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4777) :: Init_int16 (Int.repr (-525)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4822) :: Init_int16 (Int.repr (-931)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4853) ::
                Init_int16 (Int.repr (-1141)) ::
                Init_int16 (Int.repr (-1443)) ::
                Init_int16 (Int.repr 4431) ::
                Init_int16 (Int.repr (-1148)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4623) :: Init_int16 (Int.repr (-450)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4135) :: Init_int16 (Int.repr 44) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4507) :: Init_int16 (Int.repr 72) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4621) :: Init_int16 (Int.repr (-302)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 4143) :: Init_int16 (Int.repr (-932)) ::
                Init_int16 (Int.repr (-1443)) ::
                Init_int16 (Int.repr 4113) :: Init_int16 (Int.repr (-785)) ::
                Init_int16 (Int.repr (-1443)) ::
                Init_int16 (Int.repr 3983) :: Init_int16 (Int.repr (-574)) ::
                Init_int16 (Int.repr (-1443)) ::
                Init_int16 (Int.repr 3957) :: Init_int16 (Int.repr (-178)) ::
                Init_int16 (Int.repr (-1443)) ::
                Init_int16 (Int.repr 3996) :: Init_int16 (Int.repr 155) ::
                Init_int16 (Int.repr (-1443)) ::
                Init_int16 (Int.repr 4222) :: Init_int16 (Int.repr 140) ::
                Init_int16 (Int.repr (-1443)) ::
                Init_int16 (Int.repr 4990) :: Init_int16 (Int.repr (-53)) ::
                Init_int16 (Int.repr (-1443)) ::
                Init_int16 (Int.repr 5138) :: Init_int16 (Int.repr (-335)) ::
                Init_int16 (Int.repr (-1415)) ::
                Init_int16 (Int.repr 5106) :: Init_int16 (Int.repr (-372)) ::
                Init_int16 (Int.repr (-1443)) ::
                Init_int16 (Int.repr 5301) :: Init_int16 (Int.repr (-594)) ::
                Init_int16 (Int.repr (-1443)) ::
                Init_int16 (Int.repr 5355) :: Init_int16 (Int.repr (-823)) ::
                Init_int16 (Int.repr (-1443)) ::
                Init_int16 (Int.repr 5255) :: Init_int16 (Int.repr (-924)) ::
                Init_int16 (Int.repr (-1443)) ::
                Init_int16 (Int.repr 5092) ::
                Init_int16 (Int.repr (-4350)) :: Init_int16 (Int.repr 824) ::
                Init_int16 (Int.repr 88) :: Init_int16 (Int.repr (-4197)) ::
                Init_int16 (Int.repr 824) :: Init_int16 (Int.repr (-321)) ::
                Init_int16 (Int.repr (-4709)) :: Init_int16 (Int.repr 824) ::
                Init_int16 (Int.repr (-321)) ::
                Init_int16 (Int.repr (-3941)) :: Init_int16 (Int.repr 824) ::
                Init_int16 (Int.repr (-65)) ::
                Init_int16 (Int.repr (-4350)) :: Init_int16 (Int.repr 824) ::
                Init_int16 (Int.repr 293) :: Init_int16 (Int.repr (-4555)) ::
                Init_int16 (Int.repr 824) :: Init_int16 (Int.repr 88) ::
                Init_int16 (Int.repr (-4965)) :: Init_int16 (Int.repr 824) ::
                Init_int16 (Int.repr (-65)) ::
                Init_int16 (Int.repr (-4555)) :: Init_int16 (Int.repr 824) ::
                Init_int16 (Int.repr 293) :: Init_int16 (Int.repr (-3941)) ::
                Init_int16 (Int.repr 824) :: Init_int16 (Int.repr 446) ::
                Init_int16 (Int.repr (-4709)) :: Init_int16 (Int.repr 824) ::
                Init_int16 (Int.repr 702) :: Init_int16 (Int.repr (-4197)) ::
                Init_int16 (Int.repr 824) :: Init_int16 (Int.repr 702) ::
                Init_int16 (Int.repr (-4965)) :: Init_int16 (Int.repr 824) ::
                Init_int16 (Int.repr 446) :: Init_int16 (Int.repr 3811) ::
                Init_int16 (Int.repr (-2738)) ::
                Init_int16 (Int.repr 5302) :: Init_int16 (Int.repr 4631) ::
                Init_int16 (Int.repr (-2738)) ::
                Init_int16 (Int.repr 4739) :: Init_int16 (Int.repr 3811) ::
                Init_int16 (Int.repr (-2738)) ::
                Init_int16 (Int.repr 5097) :: Init_int16 (Int.repr 4170) ::
                Init_int16 (Int.repr (-2738)) ::
                Init_int16 (Int.repr 4278) :: Init_int16 (Int.repr 3248) ::
                Init_int16 (Int.repr (-2738)) ::
                Init_int16 (Int.repr 4278) :: Init_int16 (Int.repr 3607) ::
                Init_int16 (Int.repr (-2738)) ::
                Init_int16 (Int.repr 5097) :: Init_int16 (Int.repr 2787) ::
                Init_int16 (Int.repr (-2738)) ::
                Init_int16 (Int.repr 4739) :: Init_int16 (Int.repr 4631) ::
                Init_int16 (Int.repr (-2738)) ::
                Init_int16 (Int.repr 5660) :: Init_int16 (Int.repr 3248) ::
                Init_int16 (Int.repr (-2738)) ::
                Init_int16 (Int.repr 6121) :: Init_int16 (Int.repr 4170) ::
                Init_int16 (Int.repr (-2738)) ::
                Init_int16 (Int.repr 6121) :: Init_int16 (Int.repr 2787) ::
                Init_int16 (Int.repr (-2738)) ::
                Init_int16 (Int.repr 5660) :: Init_int16 (Int.repr 3607) ::
                Init_int16 (Int.repr (-2738)) ::
                Init_int16 (Int.repr 5302) ::
                Init_int16 (Int.repr (-4965)) :: Init_int16 (Int.repr 671) ::
                Init_int16 (Int.repr 446) :: Init_int16 (Int.repr (-4965)) ::
                Init_int16 (Int.repr 671) :: Init_int16 (Int.repr (-65)) ::
                Init_int16 (Int.repr (-4453)) :: Init_int16 (Int.repr 5) ::
                Init_int16 (Int.repr 190) :: Init_int16 (Int.repr (-4709)) ::
                Init_int16 (Int.repr 671) :: Init_int16 (Int.repr (-321)) ::
                Init_int16 (Int.repr (-4197)) :: Init_int16 (Int.repr 671) ::
                Init_int16 (Int.repr (-321)) ::
                Init_int16 (Int.repr (-4709)) :: Init_int16 (Int.repr 671) ::
                Init_int16 (Int.repr 702) :: Init_int16 (Int.repr (-4197)) ::
                Init_int16 (Int.repr 671) :: Init_int16 (Int.repr 702) ::
                Init_int16 (Int.repr (-3941)) :: Init_int16 (Int.repr 671) ::
                Init_int16 (Int.repr (-65)) ::
                Init_int16 (Int.repr (-3941)) :: Init_int16 (Int.repr 671) ::
                Init_int16 (Int.repr 446) :: Init_int16 (Int.repr (-4350)) ::
                Init_int16 (Int.repr 312) :: Init_int16 (Int.repr 293) ::
                Init_int16 (Int.repr (-4555)) :: Init_int16 (Int.repr 312) ::
                Init_int16 (Int.repr 293) :: Init_int16 (Int.repr (-4555)) ::
                Init_int16 (Int.repr 312) :: Init_int16 (Int.repr 88) ::
                Init_int16 (Int.repr (-4350)) :: Init_int16 (Int.repr 312) ::
                Init_int16 (Int.repr 88) :: Init_int16 (Int.repr 3607) ::
                Init_int16 (Int.repr (-3250)) ::
                Init_int16 (Int.repr 5302) :: Init_int16 (Int.repr 4170) ::
                Init_int16 (Int.repr (-2891)) ::
                Init_int16 (Int.repr 4278) :: Init_int16 (Int.repr 3248) ::
                Init_int16 (Int.repr (-2891)) ::
                Init_int16 (Int.repr 4278) :: Init_int16 (Int.repr 4631) ::
                Init_int16 (Int.repr (-2891)) ::
                Init_int16 (Int.repr 4739) :: Init_int16 (Int.repr 3248) ::
                Init_int16 (Int.repr (-2891)) ::
                Init_int16 (Int.repr 6121) :: Init_int16 (Int.repr 4170) ::
                Init_int16 (Int.repr (-2891)) ::
                Init_int16 (Int.repr 6121) :: Init_int16 (Int.repr 4631) ::
                Init_int16 (Int.repr (-2891)) ::
                Init_int16 (Int.repr 5660) :: Init_int16 (Int.repr 3709) ::
                Init_int16 (Int.repr (-3557)) ::
                Init_int16 (Int.repr 5200) :: Init_int16 (Int.repr 2787) ::
                Init_int16 (Int.repr (-2891)) ::
                Init_int16 (Int.repr 4739) :: Init_int16 (Int.repr 2787) ::
                Init_int16 (Int.repr (-2891)) ::
                Init_int16 (Int.repr 5660) :: Init_int16 (Int.repr 3811) ::
                Init_int16 (Int.repr (-3250)) ::
                Init_int16 (Int.repr 5302) :: Init_int16 (Int.repr 3607) ::
                Init_int16 (Int.repr (-3250)) ::
                Init_int16 (Int.repr 5097) :: Init_int16 (Int.repr 3811) ::
                Init_int16 (Int.repr (-3250)) ::
                Init_int16 (Int.repr 5097) ::
                Init_int16 (Int.repr (-2318)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-3596)) ::
                Init_int16 (Int.repr (-2302)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-3584)) ::
                Init_int16 (Int.repr (-2468)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-3562)) ::
                Init_int16 (Int.repr (-2481)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-3574)) ::
                Init_int16 (Int.repr (-2130)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-3688)) ::
                Init_int16 (Int.repr (-2635)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-3618)) ::
                Init_int16 (Int.repr (-2645)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-3629)) ::
                Init_int16 (Int.repr (-2110)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-3678)) ::
                Init_int16 (Int.repr (-2579)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-3385)) ::
                Init_int16 (Int.repr (-2591)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-3401)) ::
                Init_int16 (Int.repr (-2658)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-3208)) ::
                Init_int16 (Int.repr (-2667)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-3227)) ::
                Init_int16 (Int.repr (-2825)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-3096)) ::
                Init_int16 (Int.repr (-2831)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-3118)) ::
                Init_int16 (Int.repr (-3069)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-3131)) ::
                Init_int16 (Int.repr (-3070)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-3152)) ::
                Init_int16 (Int.repr (-3214)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-3282)) ::
                Init_int16 (Int.repr (-3216)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-3264)) ::
                Init_int16 (Int.repr (-3296)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-3439)) ::
                Init_int16 (Int.repr (-3488)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-3316)) ::
                Init_int16 (Int.repr (-3693)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-3275)) ::
                Init_int16 (Int.repr (-3885)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-3368)) ::
                Init_int16 (Int.repr (-3870)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-3385)) ::
                Init_int16 (Int.repr (-3952)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-3576)) ::
                Init_int16 (Int.repr (-3940)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-3744)) ::
                Init_int16 (Int.repr (-3857)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-3863)) ::
                Init_int16 (Int.repr (-3760)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-3918)) ::
                Init_int16 (Int.repr (-3901)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-3904)) ::
                Init_int16 (Int.repr (-4096)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-3987)) ::
                Init_int16 (Int.repr (-4115)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-3983)) ::
                Init_int16 (Int.repr (-4198)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-4144)) ::
                Init_int16 (Int.repr (-4198)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-4322)) ::
                Init_int16 (Int.repr (-4123)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-4499)) ::
                Init_int16 (Int.repr (-3944)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-4601)) ::
                Init_int16 (Int.repr (-3751)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-4604)) ::
                Init_int16 (Int.repr (-3826)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-4739)) ::
                Init_int16 (Int.repr (-3804)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-4905)) ::
                Init_int16 (Int.repr (-3680)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-5119)) ::
                Init_int16 (Int.repr (-3463)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-5203)) ::
                Init_int16 (Int.repr (-3221)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-5196)) ::
                Init_int16 (Int.repr (-3016)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-5066)) ::
                Init_int16 (Int.repr (-2947)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-4930)) ::
                Init_int16 (Int.repr (-2944)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-4945)) ::
                Init_int16 (Int.repr (-2854)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-5108)) ::
                Init_int16 (Int.repr (-2622)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-5197)) ::
                Init_int16 (Int.repr (-2346)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-5087)) ::
                Init_int16 (Int.repr (-2195)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-4854)) ::
                Init_int16 (Int.repr (-2190)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-4624)) ::
                Init_int16 (Int.repr (-2209)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-4615)) ::
                Init_int16 (Int.repr (-2380)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-4465)) ::
                Init_int16 (Int.repr (-2365)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-4470)) ::
                Init_int16 (Int.repr (-2189)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-4410)) ::
                Init_int16 (Int.repr (-2169)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-4415)) ::
                Init_int16 (Int.repr (-2025)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-4198)) ::
                Init_int16 (Int.repr (-2004)) ::
                Init_int16 (Int.repr 4403) ::
                Init_int16 (Int.repr (-3890)) ::
                Init_int16 (Int.repr (-3759)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4518)) ::
                Init_int16 (Int.repr (-3907)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4533)) ::
                Init_int16 (Int.repr (-3961)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-4610)) ::
                Init_int16 (Int.repr (-4143)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-4505)) ::
                Init_int16 (Int.repr (-3763)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-4612)) ::
                Init_int16 (Int.repr (-2748)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4557)) ::
                Init_int16 (Int.repr (-2685)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4438)) ::
                Init_int16 (Int.repr (-2910)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4412)) ::
                Init_int16 (Int.repr (-2949)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4666)) ::
                Init_int16 (Int.repr (-3039)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4633)) ::
                Init_int16 (Int.repr (-3072)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4181)) ::
                Init_int16 (Int.repr (-3143)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4517)) ::
                Init_int16 (Int.repr (-2787)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4064)) ::
                Init_int16 (Int.repr (-2742)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4070)) ::
                Init_int16 (Int.repr (-2703)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4260)) ::
                Init_int16 (Int.repr (-2002)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-4198)) ::
                Init_int16 (Int.repr (-1981)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-3884)) ::
                Init_int16 (Int.repr (-2070)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3896)) ::
                Init_int16 (Int.repr (-2182)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3715)) ::
                Init_int16 (Int.repr (-2101)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4162)) ::
                Init_int16 (Int.repr (-2340)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3644)) ::
                Init_int16 (Int.repr (-3153)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4116)) ::
                Init_int16 (Int.repr (-3220)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4345)) ::
                Init_int16 (Int.repr (-3323)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4154)) ::
                Init_int16 (Int.repr (-3201)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3992)) ::
                Init_int16 (Int.repr (-3096)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4087)) ::
                Init_int16 (Int.repr (-3278)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3967)) ::
                Init_int16 (Int.repr (-3455)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4058)) ::
                Init_int16 (Int.repr (-3144)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3838)) ::
                Init_int16 (Int.repr (-3342)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3807)) ::
                Init_int16 (Int.repr (-3249)) ::
                Init_int16 (Int.repr 4509) ::
                Init_int16 (Int.repr (-3639)) ::
                Init_int16 (Int.repr (-3038)) ::
                Init_int16 (Int.repr 4538) ::
                Init_int16 (Int.repr (-3744)) ::
                Init_int16 (Int.repr (-3508)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3724)) ::
                Init_int16 (Int.repr (-3336)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3655)) ::
                Init_int16 (Int.repr (-3188)) ::
                Init_int16 (Int.repr 4542) ::
                Init_int16 (Int.repr (-3619)) ::
                Init_int16 (Int.repr (-2919)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3466)) ::
                Init_int16 (Int.repr (-2996)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3823)) ::
                Init_int16 (Int.repr (-2899)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3804)) ::
                Init_int16 (Int.repr (-3299)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-3424)) ::
                Init_int16 (Int.repr (-3218)) ::
                Init_int16 (Int.repr 4542) ::
                Init_int16 (Int.repr (-3452)) ::
                Init_int16 (Int.repr (-3331)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3491)) ::
                Init_int16 (Int.repr (-3706)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4131)) ::
                Init_int16 (Int.repr (-3757)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3975)) ::
                Init_int16 (Int.repr (-3643)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4214)) ::
                Init_int16 (Int.repr (-3710)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3882)) ::
                Init_int16 (Int.repr (-3773)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-3912)) ::
                Init_int16 (Int.repr (-3566)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3754)) ::
                Init_int16 (Int.repr (-3789)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3837)) ::
                Init_int16 (Int.repr (-3488)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3390)) ::
                Init_int16 (Int.repr (-3151)) ::
                Init_int16 (Int.repr 4542) ::
                Init_int16 (Int.repr (-3323)) ::
                Init_int16 (Int.repr (-3029)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4889)) ::
                Init_int16 (Int.repr (-2980)) ::
                Init_int16 (Int.repr 4496) ::
                Init_int16 (Int.repr (-4818)) ::
                Init_int16 (Int.repr (-2918)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4863)) ::
                Init_int16 (Int.repr (-2959)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4734)) ::
                Init_int16 (Int.repr (-3059)) ::
                Init_int16 (Int.repr 4534) ::
                Init_int16 (Int.repr (-4716)) ::
                Init_int16 (Int.repr (-3212)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4538)) ::
                Init_int16 (Int.repr (-3081)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-5002)) ::
                Init_int16 (Int.repr (-3013)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-5084)) ::
                Init_int16 (Int.repr (-2490)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3617)) ::
                Init_int16 (Int.repr (-2644)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3677)) ::
                Init_int16 (Int.repr (-2706)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3709)) ::
                Init_int16 (Int.repr (-2802)) ::
                Init_int16 (Int.repr 4542) ::
                Init_int16 (Int.repr (-3735)) ::
                Init_int16 (Int.repr (-2642)) ::
                Init_int16 (Int.repr 4542) ::
                Init_int16 (Int.repr (-3420)) ::
                Init_int16 (Int.repr (-2745)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3815)) ::
                Init_int16 (Int.repr (-2462)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4017)) ::
                Init_int16 (Int.repr (-2808)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3849)) ::
                Init_int16 (Int.repr (-2623)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4446)) ::
                Init_int16 (Int.repr (-2424)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4386)) ::
                Init_int16 (Int.repr (-2339)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4616)) ::
                Init_int16 (Int.repr (-2482)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4499)) ::
                Init_int16 (Int.repr (-3871)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-3857)) ::
                Init_int16 (Int.repr (-3886)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3986)) ::
                Init_int16 (Int.repr (-3594)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3625)) ::
                Init_int16 (Int.repr (-2930)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3979)) ::
                Init_int16 (Int.repr (-3144)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4003)) ::
                Init_int16 (Int.repr (-3094)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3877)) ::
                Init_int16 (Int.repr (-3434)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4395)) ::
                Init_int16 (Int.repr (-3686)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4628)) ::
                Init_int16 (Int.repr (-3622)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4579)) ::
                Init_int16 (Int.repr (-3689)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4484)) ::
                Init_int16 (Int.repr (-3742)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4734)) ::
                Init_int16 (Int.repr (-3679)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4329)) ::
                Init_int16 (Int.repr (-2641)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4746)) ::
                Init_int16 (Int.repr (-2848)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-5127)) ::
                Init_int16 (Int.repr (-2836)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-5007)) ::
                Init_int16 (Int.repr (-2612)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-5218)) ::
                Init_int16 (Int.repr (-2330)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-5105)) ::
                Init_int16 (Int.repr (-2176)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-4868)) ::
                Init_int16 (Int.repr (-2705)) ::
                Init_int16 (Int.repr 4542) ::
                Init_int16 (Int.repr (-3279)) ::
                Init_int16 (Int.repr (-2839)) ::
                Init_int16 (Int.repr 4542) ::
                Init_int16 (Int.repr (-3189)) ::
                Init_int16 (Int.repr (-3034)) ::
                Init_int16 (Int.repr 4542) ::
                Init_int16 (Int.repr (-3217)) ::
                Init_int16 (Int.repr (-3655)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3357)) ::
                Init_int16 (Int.repr (-3495)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-3298)) ::
                Init_int16 (Int.repr (-3800)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3446)) ::
                Init_int16 (Int.repr (-3704)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-3257)) ::
                Init_int16 (Int.repr (-3867)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3603)) ::
                Init_int16 (Int.repr (-3857)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3740)) ::
                Init_int16 (Int.repr (-3969)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-3564)) ::
                Init_int16 (Int.repr (-3957)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-3735)) ::
                Init_int16 (Int.repr (-4031)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4031)) ::
                Init_int16 (Int.repr (-3916)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-3899)) ::
                Init_int16 (Int.repr (-4115)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4160)) ::
                Init_int16 (Int.repr (-4115)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4305)) ::
                Init_int16 (Int.repr (-4220)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-4143)) ::
                Init_int16 (Int.repr (-4053)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4450)) ::
                Init_int16 (Int.repr (-4220)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-4324)) ::
                Init_int16 (Int.repr (-3724)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4870)) ::
                Init_int16 (Int.repr (-3840)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-4750)) ::
                Init_int16 (Int.repr (-3631)) ::
                Init_int16 (Int.repr 4535) ::
                Init_int16 (Int.repr (-5054)) ::
                Init_int16 (Int.repr (-3818)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-4919)) ::
                Init_int16 (Int.repr (-3446)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-5113)) ::
                Init_int16 (Int.repr (-3691)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-5138)) ::
                Init_int16 (Int.repr (-3248)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-5108)) ::
                Init_int16 (Int.repr (-3470)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-5223)) ::
                Init_int16 (Int.repr (-3223)) ::
                Init_int16 (Int.repr 4468) ::
                Init_int16 (Int.repr (-5217)) ::
                Init_int16 (Int.repr (-3820)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4249)) ::
                Init_int16 (Int.repr (-2700)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4600)) :: Init_int16 (Int.repr 941) ::
                Init_int16 (Int.repr 1536) :: Init_int16 (Int.repr 407) ::
                Init_int16 (Int.repr 753) :: Init_int16 (Int.repr 1536) ::
                Init_int16 (Int.repr 499) :: Init_int16 (Int.repr 590) ::
                Init_int16 (Int.repr 1536) :: Init_int16 (Int.repr 521) ::
                Init_int16 (Int.repr 426) :: Init_int16 (Int.repr 1536) ::
                Init_int16 (Int.repr 466) :: Init_int16 (Int.repr 480) ::
                Init_int16 (Int.repr 1536) :: Init_int16 (Int.repr 694) ::
                Init_int16 (Int.repr 404) :: Init_int16 (Int.repr 1536) ::
                Init_int16 (Int.repr 868) :: Init_int16 (Int.repr 246) ::
                Init_int16 (Int.repr 1601) :: Init_int16 (Int.repr 999) ::
                Init_int16 (Int.repr 240) :: Init_int16 (Int.repr 1536) ::
                Init_int16 (Int.repr 977) :: Init_int16 (Int.repr 1) ::
                Init_int16 (Int.repr 1536) :: Init_int16 (Int.repr 943) ::
                Init_int16 (Int.repr (-142)) :: Init_int16 (Int.repr 1536) ::
                Init_int16 (Int.repr 813) :: Init_int16 (Int.repr (-144)) ::
                Init_int16 (Int.repr 1601) :: Init_int16 (Int.repr 831) ::
                Init_int16 (Int.repr (-224)) :: Init_int16 (Int.repr 1536) ::
                Init_int16 (Int.repr 656) :: Init_int16 (Int.repr (-416)) ::
                Init_int16 (Int.repr 1536) :: Init_int16 (Int.repr 779) ::
                Init_int16 (Int.repr (-621)) :: Init_int16 (Int.repr 1536) ::
                Init_int16 (Int.repr 820) :: Init_int16 (Int.repr (-813)) ::
                Init_int16 (Int.repr 1601) :: Init_int16 (Int.repr 727) ::
                Init_int16 (Int.repr (-798)) :: Init_int16 (Int.repr 1536) ::
                Init_int16 (Int.repr 710) :: Init_int16 (Int.repr (-880)) ::
                Init_int16 (Int.repr 1536) :: Init_int16 (Int.repr 519) ::
                Init_int16 (Int.repr (-868)) :: Init_int16 (Int.repr 1536) ::
                Init_int16 (Int.repr 351) :: Init_int16 (Int.repr (-785)) ::
                Init_int16 (Int.repr 1536) :: Init_int16 (Int.repr 232) ::
                Init_int16 (Int.repr (-688)) :: Init_int16 (Int.repr 1536) ::
                Init_int16 (Int.repr 177) :: Init_int16 (Int.repr (-829)) ::
                Init_int16 (Int.repr 1536) :: Init_int16 (Int.repr 191) ::
                Init_int16 (Int.repr (-1024)) ::
                Init_int16 (Int.repr 1536) :: Init_int16 (Int.repr 108) ::
                Init_int16 (Int.repr (-1043)) ::
                Init_int16 (Int.repr 1601) :: Init_int16 (Int.repr 112) ::
                Init_int16 (Int.repr (-1126)) ::
                Init_int16 (Int.repr 1536) :: Init_int16 (Int.repr (-48)) ::
                Init_int16 (Int.repr (-1126)) ::
                Init_int16 (Int.repr 1536) :: Init_int16 (Int.repr (-226)) ::
                Init_int16 (Int.repr (-1051)) ::
                Init_int16 (Int.repr 1536) :: Init_int16 (Int.repr (-403)) ::
                Init_int16 (Int.repr (-872)) :: Init_int16 (Int.repr 1536) ::
                Init_int16 (Int.repr (-505)) ::
                Init_int16 (Int.repr (-679)) :: Init_int16 (Int.repr 1536) ::
                Init_int16 (Int.repr (-508)) ::
                Init_int16 (Int.repr (-754)) :: Init_int16 (Int.repr 1536) ::
                Init_int16 (Int.repr (-643)) ::
                Init_int16 (Int.repr (-732)) :: Init_int16 (Int.repr 1536) ::
                Init_int16 (Int.repr (-809)) ::
                Init_int16 (Int.repr (-608)) :: Init_int16 (Int.repr 1536) ::
                Init_int16 (Int.repr (-1023)) ::
                Init_int16 (Int.repr (-391)) :: Init_int16 (Int.repr 1536) ::
                Init_int16 (Int.repr (-1107)) ::
                Init_int16 (Int.repr (-149)) :: Init_int16 (Int.repr 1536) ::
                Init_int16 (Int.repr (-1100)) :: Init_int16 (Int.repr 55) ::
                Init_int16 (Int.repr 1536) :: Init_int16 (Int.repr (-970)) ::
                Init_int16 (Int.repr 124) :: Init_int16 (Int.repr 1536) ::
                Init_int16 (Int.repr (-834)) :: Init_int16 (Int.repr 127) ::
                Init_int16 (Int.repr 1601) :: Init_int16 (Int.repr (-849)) ::
                Init_int16 (Int.repr 217) :: Init_int16 (Int.repr 1536) ::
                Init_int16 (Int.repr (-1012)) :: Init_int16 (Int.repr 449) ::
                Init_int16 (Int.repr 1536) ::
                Init_int16 (Int.repr (-1101)) :: Init_int16 (Int.repr 725) ::
                Init_int16 (Int.repr 1536) :: Init_int16 (Int.repr (-991)) ::
                Init_int16 (Int.repr 876) :: Init_int16 (Int.repr 1536) ::
                Init_int16 (Int.repr (-758)) :: Init_int16 (Int.repr 862) ::
                Init_int16 (Int.repr 1536) :: Init_int16 (Int.repr (-519)) ::
                Init_int16 (Int.repr 881) :: Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr (-528)) :: Init_int16 (Int.repr 691) ::
                Init_int16 (Int.repr 1536) :: Init_int16 (Int.repr (-369)) ::
                Init_int16 (Int.repr 706) :: Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr (-374)) :: Init_int16 (Int.repr 882) ::
                Init_int16 (Int.repr 1536) :: Init_int16 (Int.repr (-314)) ::
                Init_int16 (Int.repr 902) :: Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr (-319)) :: Init_int16 (Int.repr 1046) ::
                Init_int16 (Int.repr 1536) :: Init_int16 (Int.repr (-102)) ::
                Init_int16 (Int.repr 1067) :: Init_int16 (Int.repr 1536) ::
                Init_int16 (Int.repr 205) :: Init_int16 (Int.repr (-835)) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr (-437)) ::
                Init_int16 (Int.repr (-889)) :: Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr (-514)) ::
                Init_int16 (Int.repr (-687)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-422)) ::
                Init_int16 (Int.repr (-1071)) ::
                Init_int16 (Int.repr 1601) :: Init_int16 (Int.repr (-409)) ::
                Init_int16 (Int.repr (-691)) :: Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr (-516)) :: Init_int16 (Int.repr 323) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr (-461)) ::
                Init_int16 (Int.repr 386) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-342)) :: Init_int16 (Int.repr 161) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr (-316)) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-85)) :: Init_int16 (Int.repr (-71)) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr (-421)) ::
                Init_int16 (Int.repr 122) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-570)) :: Init_int16 (Int.repr 32) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr (-537)) ::
                Init_int16 (Int.repr 329) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr 25) :: Init_int16 (Int.repr 284) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr 31) ::
                Init_int16 (Int.repr 368) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-164)) :: Init_int16 (Int.repr 1069) ::
                Init_int16 (Int.repr 1601) :: Init_int16 (Int.repr (-102)) ::
                Init_int16 (Int.repr 1090) :: Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr 211) :: Init_int16 (Int.repr 1001) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr 199) ::
                Init_int16 (Int.repr 889) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr 380) :: Init_int16 (Int.repr 961) ::
                Init_int16 (Int.repr 1601) :: Init_int16 (Int.repr 417) ::
                Init_int16 (Int.repr 970) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-66)) :: Init_int16 (Int.repr 731) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr 451) ::
                Init_int16 (Int.repr (-81)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-20)) ::
                Init_int16 (Int.repr (-148)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-249)) ::
                Init_int16 (Int.repr (-251)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-58)) ::
                Init_int16 (Int.repr (-129)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr 103) :: Init_int16 (Int.repr (-24)) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr 8) ::
                Init_int16 (Int.repr (-206)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr 128) :: Init_int16 (Int.repr (-383)) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr 37) ::
                Init_int16 (Int.repr (-72)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr 257) :: Init_int16 (Int.repr (-270)) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr 288) ::
                Init_int16 (Int.repr 33) :: Init_int16 (Int.repr 1671) ::
                Init_int16 (Int.repr 351) :: Init_int16 (Int.repr (-177)) ::
                Init_int16 (Int.repr 1641) :: Init_int16 (Int.repr 456) ::
                Init_int16 (Int.repr (-436)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr 371) :: Init_int16 (Int.repr (-264)) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr 440) ::
                Init_int16 (Int.repr (-116)) :: Init_int16 (Int.repr 1675) ::
                Init_int16 (Int.repr 476) :: Init_int16 (Int.repr 75) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr 272) ::
                Init_int16 (Int.repr 172) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr 291) :: Init_int16 (Int.repr 152) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr 629) ::
                Init_int16 (Int.repr (-227)) :: Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr 671) :: Init_int16 (Int.repr (-146)) ::
                Init_int16 (Int.repr 1675) :: Init_int16 (Int.repr 643) ::
                Init_int16 (Int.repr (-259)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr 604) :: Init_int16 (Int.repr (-634)) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr (-35)) ::
                Init_int16 (Int.repr (-571)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-118)) ::
                Init_int16 (Int.repr (-685)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr 120) :: Init_int16 (Int.repr (-638)) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr 213) ::
                Init_int16 (Int.repr (-701)) :: Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr 183) :: Init_int16 (Int.repr (-494)) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr 341) ::
                Init_int16 (Int.repr (-717)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr 258) :: Init_int16 (Int.repr (-416)) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr 705) ::
                Init_int16 (Int.repr (-79)) :: Init_int16 (Int.repr 1675) ::
                Init_int16 (Int.repr 772) :: Init_int16 (Int.repr 91) ::
                Init_int16 (Int.repr 1629) :: Init_int16 (Int.repr (-722)) ::
                Init_int16 (Int.repr 42) :: Init_int16 (Int.repr 1670) ::
                Init_int16 (Int.repr (-793)) :: Init_int16 (Int.repr 153) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr (-767)) ::
                Init_int16 (Int.repr 112) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-638)) :: Init_int16 (Int.repr 12) ::
                Init_int16 (Int.repr 1667) :: Init_int16 (Int.repr (-620)) ::
                Init_int16 (Int.repr (-140)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-442)) :: Init_int16 (Int.repr (-9)) ::
                Init_int16 (Int.repr 1670) :: Init_int16 (Int.repr (-906)) ::
                Init_int16 (Int.repr 58) :: Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr (-988)) :: Init_int16 (Int.repr 436) ::
                Init_int16 (Int.repr 1601) :: Init_int16 (Int.repr 477) ::
                Init_int16 (Int.repr 581) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr 478) :: Init_int16 (Int.repr 603) ::
                Init_int16 (Int.repr 1601) :: Init_int16 (Int.repr 533) ::
                Init_int16 (Int.repr 365) :: Init_int16 (Int.repr 1670) ::
                Init_int16 (Int.repr 386) :: Init_int16 (Int.repr 427) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr 418) ::
                Init_int16 (Int.repr 269) :: Init_int16 (Int.repr 1675) ::
                Init_int16 (Int.repr 360) :: Init_int16 (Int.repr 429) ::
                Init_int16 (Int.repr 1675) :: Init_int16 (Int.repr 675) ::
                Init_int16 (Int.repr 326) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr 280) :: Init_int16 (Int.repr 609) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr 78) ::
                Init_int16 (Int.repr 263) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr 246) :: Init_int16 (Int.repr 448) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr (-350)) ::
                Init_int16 (Int.repr 647) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-290)) :: Init_int16 (Int.repr 732) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr (-520)) ::
                Init_int16 (Int.repr 589) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-403)) ::
                Init_int16 (Int.repr (-799)) :: Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr 238) :: Init_int16 (Int.repr (-814)) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr 109) ::
                Init_int16 (Int.repr (-522)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr 470) :: Init_int16 (Int.repr 141) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr 116) ::
                Init_int16 (Int.repr (-72)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr 92) :: Init_int16 (Int.repr (-22)) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr 218) ::
                Init_int16 (Int.repr (-362)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-299)) ::
                Init_int16 (Int.repr (-550)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-483)) ::
                Init_int16 (Int.repr (-614)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-532)) ::
                Init_int16 (Int.repr (-617)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-388)) ::
                Init_int16 (Int.repr (-670)) :: Init_int16 (Int.repr 1670) ::
                Init_int16 (Int.repr (-638)) ::
                Init_int16 (Int.repr (-607)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-233)) :: Init_int16 (Int.repr 430) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr (-650)) ::
                Init_int16 (Int.repr 235) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-911)) :: Init_int16 (Int.repr 223) ::
                Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr (-1031)) :: Init_int16 (Int.repr 459) ::
                Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr (-1122)) :: Init_int16 (Int.repr 741) ::
                Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr (-1009)) :: Init_int16 (Int.repr 895) ::
                Init_int16 (Int.repr 1601) :: Init_int16 (Int.repr (-772)) ::
                Init_int16 (Int.repr 769) :: Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr 511) :: Init_int16 (Int.repr 366) ::
                Init_int16 (Int.repr 1675) :: Init_int16 (Int.repr 816) ::
                Init_int16 (Int.repr 492) :: Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr 710) :: Init_int16 (Int.repr 232) ::
                Init_int16 (Int.repr 1675) :: Init_int16 (Int.repr 906) ::
                Init_int16 (Int.repr 413) :: Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr 887) :: Init_int16 (Int.repr 37) ::
                Init_int16 (Int.repr 1675) :: Init_int16 (Int.repr 878) ::
                Init_int16 (Int.repr 2) :: Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr 964) :: Init_int16 (Int.repr (-583)) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr 738) ::
                Init_int16 (Int.repr (-423)) :: Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr 797) :: Init_int16 (Int.repr (-728)) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr 649) ::
                Init_int16 (Int.repr (-632)) :: Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr 838) :: Init_int16 (Int.repr (-795)) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr 492) ::
                Init_int16 (Int.repr (-785)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr 355) :: Init_int16 (Int.repr (-897)) ::
                Init_int16 (Int.repr 1601) :: Init_int16 (Int.repr 531) ::
                Init_int16 (Int.repr (-885)) :: Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr 360) :: Init_int16 (Int.repr (-959)) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr 64) ::
                Init_int16 (Int.repr (-844)) :: Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr 196) :: Init_int16 (Int.repr (-1043)) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr (-64)) ::
                Init_int16 (Int.repr (-1043)) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr (-209)) ::
                Init_int16 (Int.repr (-1148)) ::
                Init_int16 (Int.repr 1601) :: Init_int16 (Int.repr (-47)) ::
                Init_int16 (Int.repr (-981)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-354)) ::
                Init_int16 (Int.repr (-1148)) ::
                Init_int16 (Int.repr 1601) :: Init_int16 (Int.repr (-228)) ::
                Init_int16 (Int.repr (-652)) :: Init_int16 (Int.repr 1670) ::
                Init_int16 (Int.repr (-774)) ::
                Init_int16 (Int.repr (-768)) :: Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr (-654)) ::
                Init_int16 (Int.repr (-559)) :: Init_int16 (Int.repr 1668) ::
                Init_int16 (Int.repr (-958)) ::
                Init_int16 (Int.repr (-746)) :: Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr (-823)) ::
                Init_int16 (Int.repr (-374)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-1017)) ::
                Init_int16 (Int.repr (-619)) :: Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr (-1042)) ::
                Init_int16 (Int.repr (-176)) :: Init_int16 (Int.repr 1670) ::
                Init_int16 (Int.repr (-1012)) ::
                Init_int16 (Int.repr (-398)) :: Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr (-1127)) ::
                Init_int16 (Int.repr (-151)) :: Init_int16 (Int.repr 1601) ::
                Init_int16 (Int.repr (-1121)) ::
                Init_int16 (Int.repr (-748)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-153)) :: Init_int16 (Int.repr 371) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr (-504)) ::
                Init_int16 (Int.repr (-3705)) ::
                Init_int16 (Int.repr 4499) ::
                Init_int16 (Int.repr (-4572)) ::
                Init_int16 (Int.repr (-2859)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4652)) ::
                Init_int16 (Int.repr (-2880)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4165)) ::
                Init_int16 (Int.repr (-2847)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4704)) ::
                Init_int16 (Int.repr (-3142)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4365)) ::
                Init_int16 (Int.repr (-2895)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4124)) ::
                Init_int16 (Int.repr (-2579)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4322)) ::
                Init_int16 (Int.repr (-2252)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4320)) ::
                Init_int16 (Int.repr (-3491)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4263)) ::
                Init_int16 (Int.repr (-3392)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4631)) ::
                Init_int16 (Int.repr (-2687)) ::
                Init_int16 (Int.repr 4542) ::
                Init_int16 (Int.repr (-3607)) ::
                Init_int16 (Int.repr (-3735)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3958)) ::
                Init_int16 (Int.repr (-3690)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-3900)) ::
                Init_int16 (Int.repr (-3386)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4785)) ::
                Init_int16 (Int.repr (-2646)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-5080)) ::
                Init_int16 (Int.repr (-2438)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-5019)) ::
                Init_int16 (Int.repr (-2312)) ::
                Init_int16 (Int.repr 4537) ::
                Init_int16 (Int.repr (-4844)) ::
                Init_int16 (Int.repr (-633)) :: Init_int16 (Int.repr 1632) ::
                Init_int16 (Int.repr (-476)) :: Init_int16 (Int.repr 191) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr (-69)) ::
                Init_int16 (Int.repr 212) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-556)) ::
                Init_int16 (Int.repr (-70)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-269)) :: Init_int16 (Int.repr 176) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr (-28)) ::
                Init_int16 (Int.repr 224) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-608)) :: Init_int16 (Int.repr 492) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr (-226)) ::
                Init_int16 (Int.repr 819) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-224)) ::
                Init_int16 (Int.repr (-419)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-167)) :: Init_int16 (Int.repr 384) ::
                Init_int16 (Int.repr 1675) :: Init_int16 (Int.repr 488) ::
                Init_int16 (Int.repr (-663)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr 137) :: Init_int16 (Int.repr (-618)) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr 195) ::
                Init_int16 (Int.repr (-314)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-689)) ::
                Init_int16 (Int.repr (-320)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-535)) :: Init_int16 (Int.repr 425) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr (-984)) ::
                Init_int16 (Int.repr 633) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-923)) :: Init_int16 (Int.repr 759) ::
                Init_int16 (Int.repr 1669) :: Init_int16 (Int.repr (-748)) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 68) ::
                Init_int16 (Int.repr 290) :: Init_int16 (Int.repr 272) ::
                Init_int16 (Int.repr 291) :: Init_int16 (Int.repr 292) ::
                Init_int16 (Int.repr 290) :: Init_int16 (Int.repr 291) ::
                Init_int16 (Int.repr 268) :: Init_int16 (Int.repr 291) ::
                Init_int16 (Int.repr 272) :: Init_int16 (Int.repr 268) ::
                Init_int16 (Int.repr 293) :: Init_int16 (Int.repr 291) ::
                Init_int16 (Int.repr 291) :: Init_int16 (Int.repr 293) ::
                Init_int16 (Int.repr 292) :: Init_int16 (Int.repr 293) ::
                Init_int16 (Int.repr 294) :: Init_int16 (Int.repr 292) ::
                Init_int16 (Int.repr 268) :: Init_int16 (Int.repr 294) ::
                Init_int16 (Int.repr 293) :: Init_int16 (Int.repr 295) ::
                Init_int16 (Int.repr 290) :: Init_int16 (Int.repr 292) ::
                Init_int16 (Int.repr 296) :: Init_int16 (Int.repr 295) ::
                Init_int16 (Int.repr 292) :: Init_int16 (Int.repr 294) ::
                Init_int16 (Int.repr 297) :: Init_int16 (Int.repr 292) ::
                Init_int16 (Int.repr 297) :: Init_int16 (Int.repr 298) ::
                Init_int16 (Int.repr 292) :: Init_int16 (Int.repr 298) ::
                Init_int16 (Int.repr 296) :: Init_int16 (Int.repr 292) ::
                Init_int16 (Int.repr 273) :: Init_int16 (Int.repr 299) ::
                Init_int16 (Int.repr 300) :: Init_int16 (Int.repr 273) ::
                Init_int16 (Int.repr 300) :: Init_int16 (Int.repr 301) ::
                Init_int16 (Int.repr 269) :: Init_int16 (Int.repr 294) ::
                Init_int16 (Int.repr 267) :: Init_int16 (Int.repr 266) ::
                Init_int16 (Int.repr 302) :: Init_int16 (Int.repr 299) ::
                Init_int16 (Int.repr 266) :: Init_int16 (Int.repr 301) ::
                Init_int16 (Int.repr 302) :: Init_int16 (Int.repr 300) ::
                Init_int16 (Int.repr 302) :: Init_int16 (Int.repr 301) ::
                Init_int16 (Int.repr 300) :: Init_int16 (Int.repr 299) ::
                Init_int16 (Int.repr 302) :: Init_int16 (Int.repr 273) ::
                Init_int16 (Int.repr 301) :: Init_int16 (Int.repr 271) ::
                Init_int16 (Int.repr 266) :: Init_int16 (Int.repr 271) ::
                Init_int16 (Int.repr 301) :: Init_int16 (Int.repr 266) ::
                Init_int16 (Int.repr 299) :: Init_int16 (Int.repr 270) ::
                Init_int16 (Int.repr 273) :: Init_int16 (Int.repr 270) ::
                Init_int16 (Int.repr 299) :: Init_int16 (Int.repr 268) ::
                Init_int16 (Int.repr 267) :: Init_int16 (Int.repr 294) ::
                Init_int16 (Int.repr 269) :: Init_int16 (Int.repr 297) ::
                Init_int16 (Int.repr 294) :: Init_int16 (Int.repr 289) ::
                Init_int16 (Int.repr 303) :: Init_int16 (Int.repr 314) ::
                Init_int16 (Int.repr 274) :: Init_int16 (Int.repr 298) ::
                Init_int16 (Int.repr 297) :: Init_int16 (Int.repr 274) ::
                Init_int16 (Int.repr 297) :: Init_int16 (Int.repr 269) ::
                Init_int16 (Int.repr 276) :: Init_int16 (Int.repr 298) ::
                Init_int16 (Int.repr 274) :: Init_int16 (Int.repr 276) ::
                Init_int16 (Int.repr 296) :: Init_int16 (Int.repr 298) ::
                Init_int16 (Int.repr 276) :: Init_int16 (Int.repr 295) ::
                Init_int16 (Int.repr 296) :: Init_int16 (Int.repr 277) ::
                Init_int16 (Int.repr 295) :: Init_int16 (Int.repr 275) ::
                Init_int16 (Int.repr 277) :: Init_int16 (Int.repr 290) ::
                Init_int16 (Int.repr 295) :: Init_int16 (Int.repr 276) ::
                Init_int16 (Int.repr 275) :: Init_int16 (Int.repr 295) ::
                Init_int16 (Int.repr 290) :: Init_int16 (Int.repr 277) ::
                Init_int16 (Int.repr 272) :: Init_int16 (Int.repr 289) ::
                Init_int16 (Int.repr 313) :: Init_int16 (Int.repr 303) ::
                Init_int16 (Int.repr 280) :: Init_int16 (Int.repr 314) ::
                Init_int16 (Int.repr 315) :: Init_int16 (Int.repr 280) ::
                Init_int16 (Int.repr 315) :: Init_int16 (Int.repr 313) ::
                Init_int16 (Int.repr 303) :: Init_int16 (Int.repr 313) ::
                Init_int16 (Int.repr 315) :: Init_int16 (Int.repr 303) ::
                Init_int16 (Int.repr 315) :: Init_int16 (Int.repr 314) ::
                Init_int16 (Int.repr 280) :: Init_int16 (Int.repr 283) ::
                Init_int16 (Int.repr 314) :: Init_int16 (Int.repr 289) ::
                Init_int16 (Int.repr 314) :: Init_int16 (Int.repr 283) ::
                Init_int16 (Int.repr 289) :: Init_int16 (Int.repr 278) ::
                Init_int16 (Int.repr 313) :: Init_int16 (Int.repr 280) ::
                Init_int16 (Int.repr 313) :: Init_int16 (Int.repr 278) ::
                Init_int16 (Int.repr 282) :: Init_int16 (Int.repr 281) ::
                Init_int16 (Int.repr 304) :: Init_int16 (Int.repr 282) ::
                Init_int16 (Int.repr 304) :: Init_int16 (Int.repr 305) ::
                Init_int16 (Int.repr 279) :: Init_int16 (Int.repr 306) ::
                Init_int16 (Int.repr 304) :: Init_int16 (Int.repr 304) ::
                Init_int16 (Int.repr 306) :: Init_int16 (Int.repr 310) ::
                Init_int16 (Int.repr 279) :: Init_int16 (Int.repr 304) ::
                Init_int16 (Int.repr 281) :: Init_int16 (Int.repr 305) ::
                Init_int16 (Int.repr 304) :: Init_int16 (Int.repr 310) ::
                Init_int16 (Int.repr 285) :: Init_int16 (Int.repr 309) ::
                Init_int16 (Int.repr 306) :: Init_int16 (Int.repr 285) ::
                Init_int16 (Int.repr 306) :: Init_int16 (Int.repr 279) ::
                Init_int16 (Int.repr 306) :: Init_int16 (Int.repr 309) ::
                Init_int16 (Int.repr 310) :: Init_int16 (Int.repr 307) ::
                Init_int16 (Int.repr 312) :: Init_int16 (Int.repr 310) ::
                Init_int16 (Int.repr 308) :: Init_int16 (Int.repr 307) ::
                Init_int16 (Int.repr 310) :: Init_int16 (Int.repr 309) ::
                Init_int16 (Int.repr 308) :: Init_int16 (Int.repr 310) ::
                Init_int16 (Int.repr 310) :: Init_int16 (Int.repr 312) ::
                Init_int16 (Int.repr 311) :: Init_int16 (Int.repr 311) ::
                Init_int16 (Int.repr 305) :: Init_int16 (Int.repr 310) ::
                Init_int16 (Int.repr 287) :: Init_int16 (Int.repr 308) ::
                Init_int16 (Int.repr 309) :: Init_int16 (Int.repr 287) ::
                Init_int16 (Int.repr 309) :: Init_int16 (Int.repr 285) ::
                Init_int16 (Int.repr 287) :: Init_int16 (Int.repr 307) ::
                Init_int16 (Int.repr 308) :: Init_int16 (Int.repr 287) ::
                Init_int16 (Int.repr 286) :: Init_int16 (Int.repr 307) ::
                Init_int16 (Int.repr 288) :: Init_int16 (Int.repr 307) ::
                Init_int16 (Int.repr 286) :: Init_int16 (Int.repr 288) ::
                Init_int16 (Int.repr 312) :: Init_int16 (Int.repr 307) ::
                Init_int16 (Int.repr 312) :: Init_int16 (Int.repr 284) ::
                Init_int16 (Int.repr 311) :: Init_int16 (Int.repr 312) ::
                Init_int16 (Int.repr 288) :: Init_int16 (Int.repr 284) ::
                Init_int16 (Int.repr 282) :: Init_int16 (Int.repr 305) ::
                Init_int16 (Int.repr 311) :: Init_int16 (Int.repr 282) ::
                Init_int16 (Int.repr 311) :: Init_int16 (Int.repr 284) ::
                Init_int16 (Int.repr 5) :: Init_int16 (Int.repr 38) ::
                Init_int16 (Int.repr 507) :: Init_int16 (Int.repr 530) ::
                Init_int16 (Int.repr 491) :: Init_int16 (Int.repr 507) ::
                Init_int16 (Int.repr 522) :: Init_int16 (Int.repr 530) ::
                Init_int16 (Int.repr 507) :: Init_int16 (Int.repr 515) ::
                Init_int16 (Int.repr 522) :: Init_int16 (Int.repr 507) ::
                Init_int16 (Int.repr 491) :: Init_int16 (Int.repr 499) ::
                Init_int16 (Int.repr 507) :: Init_int16 (Int.repr 511) ::
                Init_int16 (Int.repr 515) :: Init_int16 (Int.repr 507) ::
                Init_int16 (Int.repr 509) :: Init_int16 (Int.repr 511) ::
                Init_int16 (Int.repr 499) :: Init_int16 (Int.repr 506) ::
                Init_int16 (Int.repr 507) :: Init_int16 (Int.repr 507) ::
                Init_int16 (Int.repr 508) :: Init_int16 (Int.repr 509) ::
                Init_int16 (Int.repr 491) :: Init_int16 (Int.repr 497) ::
                Init_int16 (Int.repr 499) :: Init_int16 (Int.repr 491) ::
                Init_int16 (Int.repr 496) :: Init_int16 (Int.repr 497) ::
                Init_int16 (Int.repr 530) :: Init_int16 (Int.repr 490) ::
                Init_int16 (Int.repr 491) :: Init_int16 (Int.repr 491) ::
                Init_int16 (Int.repr 492) :: Init_int16 (Int.repr 493) ::
                Init_int16 (Int.repr 499) :: Init_int16 (Int.repr 501) ::
                Init_int16 (Int.repr 503) :: Init_int16 (Int.repr 499) ::
                Init_int16 (Int.repr 500) :: Init_int16 (Int.repr 501) ::
                Init_int16 (Int.repr 499) :: Init_int16 (Int.repr 503) ::
                Init_int16 (Int.repr 504) :: Init_int16 (Int.repr 499) ::
                Init_int16 (Int.repr 504) :: Init_int16 (Int.repr 505) ::
                Init_int16 (Int.repr 499) :: Init_int16 (Int.repr 505) ::
                Init_int16 (Int.repr 506) :: Init_int16 (Int.repr 530) ::
                Init_int16 (Int.repr 489) :: Init_int16 (Int.repr 490) ::
                Init_int16 (Int.repr 530) :: Init_int16 (Int.repr 532) ::
                Init_int16 (Int.repr 534) :: Init_int16 (Int.repr 530) ::
                Init_int16 (Int.repr 534) :: Init_int16 (Int.repr 535) ::
                Init_int16 (Int.repr 530) :: Init_int16 (Int.repr 535) ::
                Init_int16 (Int.repr 488) :: Init_int16 (Int.repr 530) ::
                Init_int16 (Int.repr 488) :: Init_int16 (Int.repr 489) ::
                Init_int16 (Int.repr 511) :: Init_int16 (Int.repr 514) ::
                Init_int16 (Int.repr 515) :: Init_int16 (Int.repr 515) ::
                Init_int16 (Int.repr 521) :: Init_int16 (Int.repr 522) ::
                Init_int16 (Int.repr 522) :: Init_int16 (Int.repr 528) ::
                Init_int16 (Int.repr 530) :: Init_int16 (Int.repr 522) ::
                Init_int16 (Int.repr 524) :: Init_int16 (Int.repr 525) ::
                Init_int16 (Int.repr 522) :: Init_int16 (Int.repr 525) ::
                Init_int16 (Int.repr 526) :: Init_int16 (Int.repr 522) ::
                Init_int16 (Int.repr 526) :: Init_int16 (Int.repr 527) ::
                Init_int16 (Int.repr 522) :: Init_int16 (Int.repr 527) ::
                Init_int16 (Int.repr 528) :: Init_int16 (Int.repr 515) ::
                Init_int16 (Int.repr 520) :: Init_int16 (Int.repr 521) ::
                Init_int16 (Int.repr 515) :: Init_int16 (Int.repr 519) ::
                Init_int16 (Int.repr 520) :: Init_int16 (Int.repr 515) ::
                Init_int16 (Int.repr 518) :: Init_int16 (Int.repr 519) ::
                Init_int16 (Int.repr 515) :: Init_int16 (Int.repr 517) ::
                Init_int16 (Int.repr 518) :: Init_int16 (Int.repr 515) ::
                Init_int16 (Int.repr 516) :: Init_int16 (Int.repr 517) ::
                Init_int16 (Int.repr 511) :: Init_int16 (Int.repr 512) ::
                Init_int16 (Int.repr 513) :: Init_int16 (Int.repr 511) ::
                Init_int16 (Int.repr 513) :: Init_int16 (Int.repr 514) ::
                Init_int16 (Int.repr 491) :: Init_int16 (Int.repr 495) ::
                Init_int16 (Int.repr 496) :: Init_int16 (Int.repr 491) ::
                Init_int16 (Int.repr 493) :: Init_int16 (Int.repr 495) ::
                Init_int16 (Int.repr 10) :: Init_int16 (Int.repr 2) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 1) ::
                Init_int16 (Int.repr 2) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 2) :: Init_int16 (Int.repr 3) ::
                Init_int16 (Int.repr 21) :: Init_int16 (Int.repr 1220) ::
                Init_int16 (Int.repr 5) :: Init_int16 (Int.repr 10) ::
                Init_int16 (Int.repr 16) :: Init_int16 (Int.repr 4) ::
                Init_int16 (Int.repr 5) :: Init_int16 (Int.repr 6) ::
                Init_int16 (Int.repr 4) :: Init_int16 (Int.repr 7) ::
                Init_int16 (Int.repr 5) :: Init_int16 (Int.repr 4) ::
                Init_int16 (Int.repr 8) :: Init_int16 (Int.repr 7) ::
                Init_int16 (Int.repr 6) :: Init_int16 (Int.repr 8) ::
                Init_int16 (Int.repr 4) :: Init_int16 (Int.repr 5) ::
                Init_int16 (Int.repr 9) :: Init_int16 (Int.repr 10) ::
                Init_int16 (Int.repr 9) :: Init_int16 (Int.repr 5) ::
                Init_int16 (Int.repr 7) :: Init_int16 (Int.repr 5) ::
                Init_int16 (Int.repr 11) :: Init_int16 (Int.repr 6) ::
                Init_int16 (Int.repr 5) :: Init_int16 (Int.repr 12) ::
                Init_int16 (Int.repr 11) :: Init_int16 (Int.repr 5) ::
                Init_int16 (Int.repr 13) :: Init_int16 (Int.repr 12) ::
                Init_int16 (Int.repr 5) :: Init_int16 (Int.repr 14) ::
                Init_int16 (Int.repr 13) :: Init_int16 (Int.repr 5) ::
                Init_int16 (Int.repr 15) :: Init_int16 (Int.repr 14) ::
                Init_int16 (Int.repr 5) :: Init_int16 (Int.repr 16) ::
                Init_int16 (Int.repr 15) :: Init_int16 (Int.repr 17) ::
                Init_int16 (Int.repr 6) :: Init_int16 (Int.repr 11) ::
                Init_int16 (Int.repr 6) :: Init_int16 (Int.repr 18) ::
                Init_int16 (Int.repr 21) :: Init_int16 (Int.repr 6) ::
                Init_int16 (Int.repr 19) :: Init_int16 (Int.repr 18) ::
                Init_int16 (Int.repr 6) :: Init_int16 (Int.repr 20) ::
                Init_int16 (Int.repr 19) :: Init_int16 (Int.repr 6) ::
                Init_int16 (Int.repr 21) :: Init_int16 (Int.repr 23) ::
                Init_int16 (Int.repr 6) :: Init_int16 (Int.repr 22) ::
                Init_int16 (Int.repr 8) :: Init_int16 (Int.repr 6) ::
                Init_int16 (Int.repr 23) :: Init_int16 (Int.repr 22) ::
                Init_int16 (Int.repr 6) :: Init_int16 (Int.repr 17) ::
                Init_int16 (Int.repr 24) :: Init_int16 (Int.repr 6) ::
                Init_int16 (Int.repr 24) :: Init_int16 (Int.repr 20) ::
                Init_int16 (Int.repr 7) :: Init_int16 (Int.repr 209) ::
                Init_int16 (Int.repr 8) :: Init_int16 (Int.repr 20) ::
                Init_int16 (Int.repr 213) :: Init_int16 (Int.repr 19) ::
                Init_int16 (Int.repr 25) :: Init_int16 (Int.repr 22) ::
                Init_int16 (Int.repr 26) :: Init_int16 (Int.repr 25) ::
                Init_int16 (Int.repr 8) :: Init_int16 (Int.repr 22) ::
                Init_int16 (Int.repr 22) :: Init_int16 (Int.repr 23) ::
                Init_int16 (Int.repr 210) :: Init_int16 (Int.repr 26) ::
                Init_int16 (Int.repr 22) :: Init_int16 (Int.repr 210) ::
                Init_int16 (Int.repr 21) :: Init_int16 (Int.repr 210) ::
                Init_int16 (Int.repr 23) :: Init_int16 (Int.repr 18) ::
                Init_int16 (Int.repr 211) :: Init_int16 (Int.repr 21) ::
                Init_int16 (Int.repr 21) :: Init_int16 (Int.repr 211) ::
                Init_int16 (Int.repr 210) :: Init_int16 (Int.repr 18) ::
                Init_int16 (Int.repr 212) :: Init_int16 (Int.repr 211) ::
                Init_int16 (Int.repr 19) :: Init_int16 (Int.repr 212) ::
                Init_int16 (Int.repr 18) :: Init_int16 (Int.repr 19) ::
                Init_int16 (Int.repr 213) :: Init_int16 (Int.repr 212) ::
                Init_int16 (Int.repr 16) :: Init_int16 (Int.repr 29) ::
                Init_int16 (Int.repr 15) :: Init_int16 (Int.repr 20) ::
                Init_int16 (Int.repr 24) :: Init_int16 (Int.repr 213) ::
                Init_int16 (Int.repr 12) :: Init_int16 (Int.repr 17) ::
                Init_int16 (Int.repr 11) :: Init_int16 (Int.repr 13) ::
                Init_int16 (Int.repr 17) :: Init_int16 (Int.repr 12) ::
                Init_int16 (Int.repr 13) :: Init_int16 (Int.repr 27) ::
                Init_int16 (Int.repr 17) :: Init_int16 (Int.repr 14) ::
                Init_int16 (Int.repr 27) :: Init_int16 (Int.repr 13) ::
                Init_int16 (Int.repr 14) :: Init_int16 (Int.repr 28) ::
                Init_int16 (Int.repr 27) :: Init_int16 (Int.repr 15) ::
                Init_int16 (Int.repr 28) :: Init_int16 (Int.repr 14) ::
                Init_int16 (Int.repr 15) :: Init_int16 (Int.repr 29) ::
                Init_int16 (Int.repr 28) :: Init_int16 (Int.repr 30) ::
                Init_int16 (Int.repr 16) :: Init_int16 (Int.repr 10) ::
                Init_int16 (Int.repr 16) :: Init_int16 (Int.repr 30) ::
                Init_int16 (Int.repr 29) :: Init_int16 (Int.repr 31) ::
                Init_int16 (Int.repr 30) :: Init_int16 (Int.repr 10) ::
                Init_int16 (Int.repr 9) :: Init_int16 (Int.repr 31) ::
                Init_int16 (Int.repr 10) :: Init_int16 (Int.repr 32) ::
                Init_int16 (Int.repr 26) :: Init_int16 (Int.repr 210) ::
                Init_int16 (Int.repr 33) :: Init_int16 (Int.repr 210) ::
                Init_int16 (Int.repr 211) :: Init_int16 (Int.repr 34) ::
                Init_int16 (Int.repr 210) :: Init_int16 (Int.repr 33) ::
                Init_int16 (Int.repr 34) :: Init_int16 (Int.repr 32) ::
                Init_int16 (Int.repr 210) :: Init_int16 (Int.repr 35) ::
                Init_int16 (Int.repr 211) :: Init_int16 (Int.repr 212) ::
                Init_int16 (Int.repr 33) :: Init_int16 (Int.repr 211) ::
                Init_int16 (Int.repr 35) :: Init_int16 (Int.repr 40) ::
                Init_int16 (Int.repr 215) :: Init_int16 (Int.repr 41) ::
                Init_int16 (Int.repr 35) :: Init_int16 (Int.repr 212) ::
                Init_int16 (Int.repr 36) :: Init_int16 (Int.repr 36) ::
                Init_int16 (Int.repr 212) :: Init_int16 (Int.repr 213) ::
                Init_int16 (Int.repr 36) :: Init_int16 (Int.repr 213) ::
                Init_int16 (Int.repr 37) :: Init_int16 (Int.repr 37) ::
                Init_int16 (Int.repr 213) :: Init_int16 (Int.repr 24) ::
                Init_int16 (Int.repr 37) :: Init_int16 (Int.repr 24) ::
                Init_int16 (Int.repr 38) :: Init_int16 (Int.repr 38) ::
                Init_int16 (Int.repr 24) :: Init_int16 (Int.repr 17) ::
                Init_int16 (Int.repr 39) :: Init_int16 (Int.repr 17) ::
                Init_int16 (Int.repr 27) :: Init_int16 (Int.repr 38) ::
                Init_int16 (Int.repr 17) :: Init_int16 (Int.repr 39) ::
                Init_int16 (Int.repr 25) :: Init_int16 (Int.repr 41) ::
                Init_int16 (Int.repr 214) :: Init_int16 (Int.repr 25) ::
                Init_int16 (Int.repr 40) :: Init_int16 (Int.repr 41) ::
                Init_int16 (Int.repr 42) :: Init_int16 (Int.repr 31) ::
                Init_int16 (Int.repr 9) :: Init_int16 (Int.repr 43) ::
                Init_int16 (Int.repr 9) :: Init_int16 (Int.repr 215) ::
                Init_int16 (Int.repr 42) :: Init_int16 (Int.repr 9) ::
                Init_int16 (Int.repr 43) :: Init_int16 (Int.repr 7) ::
                Init_int16 (Int.repr 214) :: Init_int16 (Int.repr 9) ::
                Init_int16 (Int.repr 41) :: Init_int16 (Int.repr 9) ::
                Init_int16 (Int.repr 214) :: Init_int16 (Int.repr 41) ::
                Init_int16 (Int.repr 215) :: Init_int16 (Int.repr 9) ::
                Init_int16 (Int.repr 25) :: Init_int16 (Int.repr 214) ::
                Init_int16 (Int.repr 7) :: Init_int16 (Int.repr 43) ::
                Init_int16 (Int.repr 215) :: Init_int16 (Int.repr 44) ::
                Init_int16 (Int.repr 44) :: Init_int16 (Int.repr 215) ::
                Init_int16 (Int.repr 216) :: Init_int16 (Int.repr 40) ::
                Init_int16 (Int.repr 216) :: Init_int16 (Int.repr 215) ::
                Init_int16 (Int.repr 25) :: Init_int16 (Int.repr 45) ::
                Init_int16 (Int.repr 40) :: Init_int16 (Int.repr 45) ::
                Init_int16 (Int.repr 216) :: Init_int16 (Int.repr 40) ::
                Init_int16 (Int.repr 44) :: Init_int16 (Int.repr 216) ::
                Init_int16 (Int.repr 46) :: Init_int16 (Int.repr 46) ::
                Init_int16 (Int.repr 216) :: Init_int16 (Int.repr 45) ::
                Init_int16 (Int.repr 25) :: Init_int16 (Int.repr 26) ::
                Init_int16 (Int.repr 49) :: Init_int16 (Int.repr 25) ::
                Init_int16 (Int.repr 7) :: Init_int16 (Int.repr 8) ::
                Init_int16 (Int.repr 25) :: Init_int16 (Int.repr 49) ::
                Init_int16 (Int.repr 47) :: Init_int16 (Int.repr 47) ::
                Init_int16 (Int.repr 45) :: Init_int16 (Int.repr 25) ::
                Init_int16 (Int.repr 46) :: Init_int16 (Int.repr 45) ::
                Init_int16 (Int.repr 48) :: Init_int16 (Int.repr 47) ::
                Init_int16 (Int.repr 217) :: Init_int16 (Int.repr 45) ::
                Init_int16 (Int.repr 48) :: Init_int16 (Int.repr 45) ::
                Init_int16 (Int.repr 217) :: Init_int16 (Int.repr 49) ::
                Init_int16 (Int.repr 217) :: Init_int16 (Int.repr 47) ::
                Init_int16 (Int.repr 49) :: Init_int16 (Int.repr 32) ::
                Init_int16 (Int.repr 217) :: Init_int16 (Int.repr 48) ::
                Init_int16 (Int.repr 217) :: Init_int16 (Int.repr 50) ::
                Init_int16 (Int.repr 50) :: Init_int16 (Int.repr 217) ::
                Init_int16 (Int.repr 32) :: Init_int16 (Int.repr 32) ::
                Init_int16 (Int.repr 49) :: Init_int16 (Int.repr 26) ::
                Init_int16 (Int.repr 54) :: Init_int16 (Int.repr 30) ::
                Init_int16 (Int.repr 31) :: Init_int16 (Int.repr 50) ::
                Init_int16 (Int.repr 32) :: Init_int16 (Int.repr 34) ::
                Init_int16 (Int.repr 39) :: Init_int16 (Int.repr 27) ::
                Init_int16 (Int.repr 51) :: Init_int16 (Int.repr 51) ::
                Init_int16 (Int.repr 27) :: Init_int16 (Int.repr 28) ::
                Init_int16 (Int.repr 51) :: Init_int16 (Int.repr 28) ::
                Init_int16 (Int.repr 52) :: Init_int16 (Int.repr 52) ::
                Init_int16 (Int.repr 28) :: Init_int16 (Int.repr 29) ::
                Init_int16 (Int.repr 52) :: Init_int16 (Int.repr 29) ::
                Init_int16 (Int.repr 53) :: Init_int16 (Int.repr 53) ::
                Init_int16 (Int.repr 29) :: Init_int16 (Int.repr 30) ::
                Init_int16 (Int.repr 53) :: Init_int16 (Int.repr 30) ::
                Init_int16 (Int.repr 54) :: Init_int16 (Int.repr 59) ::
                Init_int16 (Int.repr 55) :: Init_int16 (Int.repr 58) ::
                Init_int16 (Int.repr 54) :: Init_int16 (Int.repr 31) ::
                Init_int16 (Int.repr 42) :: Init_int16 (Int.repr 55) ::
                Init_int16 (Int.repr 56) :: Init_int16 (Int.repr 58) ::
                Init_int16 (Int.repr 56) :: Init_int16 (Int.repr 218) ::
                Init_int16 (Int.repr 57) :: Init_int16 (Int.repr 56) ::
                Init_int16 (Int.repr 219) :: Init_int16 (Int.repr 58) ::
                Init_int16 (Int.repr 56) :: Init_int16 (Int.repr 57) ::
                Init_int16 (Int.repr 219) :: Init_int16 (Int.repr 55) ::
                Init_int16 (Int.repr 52) :: Init_int16 (Int.repr 56) ::
                Init_int16 (Int.repr 56) :: Init_int16 (Int.repr 53) ::
                Init_int16 (Int.repr 218) :: Init_int16 (Int.repr 56) ::
                Init_int16 (Int.repr 52) :: Init_int16 (Int.repr 53) ::
                Init_int16 (Int.repr 57) :: Init_int16 (Int.repr 42) ::
                Init_int16 (Int.repr 219) :: Init_int16 (Int.repr 42) ::
                Init_int16 (Int.repr 58) :: Init_int16 (Int.repr 219) ::
                Init_int16 (Int.repr 58) :: Init_int16 (Int.repr 43) ::
                Init_int16 (Int.repr 44) :: Init_int16 (Int.repr 42) ::
                Init_int16 (Int.repr 43) :: Init_int16 (Int.repr 58) ::
                Init_int16 (Int.repr 58) :: Init_int16 (Int.repr 44) ::
                Init_int16 (Int.repr 59) :: Init_int16 (Int.repr 53) ::
                Init_int16 (Int.repr 54) :: Init_int16 (Int.repr 57) ::
                Init_int16 (Int.repr 57) :: Init_int16 (Int.repr 54) ::
                Init_int16 (Int.repr 42) :: Init_int16 (Int.repr 53) ::
                Init_int16 (Int.repr 57) :: Init_int16 (Int.repr 218) ::
                Init_int16 (Int.repr 59) :: Init_int16 (Int.repr 44) ::
                Init_int16 (Int.repr 46) :: Init_int16 (Int.repr 59) ::
                Init_int16 (Int.repr 60) :: Init_int16 (Int.repr 55) ::
                Init_int16 (Int.repr 60) :: Init_int16 (Int.repr 51) ::
                Init_int16 (Int.repr 55) :: Init_int16 (Int.repr 59) ::
                Init_int16 (Int.repr 220) :: Init_int16 (Int.repr 65) ::
                Init_int16 (Int.repr 59) :: Init_int16 (Int.repr 66) ::
                Init_int16 (Int.repr 220) :: Init_int16 (Int.repr 59) ::
                Init_int16 (Int.repr 67) :: Init_int16 (Int.repr 66) ::
                Init_int16 (Int.repr 59) :: Init_int16 (Int.repr 68) ::
                Init_int16 (Int.repr 67) :: Init_int16 (Int.repr 59) ::
                Init_int16 (Int.repr 65) :: Init_int16 (Int.repr 64) ::
                Init_int16 (Int.repr 59) :: Init_int16 (Int.repr 61) ::
                Init_int16 (Int.repr 60) :: Init_int16 (Int.repr 59) ::
                Init_int16 (Int.repr 62) :: Init_int16 (Int.repr 61) ::
                Init_int16 (Int.repr 59) :: Init_int16 (Int.repr 63) ::
                Init_int16 (Int.repr 62) :: Init_int16 (Int.repr 59) ::
                Init_int16 (Int.repr 64) :: Init_int16 (Int.repr 63) ::
                Init_int16 (Int.repr 59) :: Init_int16 (Int.repr 46) ::
                Init_int16 (Int.repr 68) :: Init_int16 (Int.repr 65) ::
                Init_int16 (Int.repr 33) :: Init_int16 (Int.repr 35) ::
                Init_int16 (Int.repr 61) :: Init_int16 (Int.repr 39) ::
                Init_int16 (Int.repr 60) :: Init_int16 (Int.repr 60) ::
                Init_int16 (Int.repr 39) :: Init_int16 (Int.repr 51) ::
                Init_int16 (Int.repr 62) :: Init_int16 (Int.repr 38) ::
                Init_int16 (Int.repr 61) :: Init_int16 (Int.repr 61) ::
                Init_int16 (Int.repr 38) :: Init_int16 (Int.repr 39) ::
                Init_int16 (Int.repr 63) :: Init_int16 (Int.repr 37) ::
                Init_int16 (Int.repr 62) :: Init_int16 (Int.repr 62) ::
                Init_int16 (Int.repr 37) :: Init_int16 (Int.repr 38) ::
                Init_int16 (Int.repr 64) :: Init_int16 (Int.repr 36) ::
                Init_int16 (Int.repr 63) :: Init_int16 (Int.repr 63) ::
                Init_int16 (Int.repr 36) :: Init_int16 (Int.repr 37) ::
                Init_int16 (Int.repr 65) :: Init_int16 (Int.repr 35) ::
                Init_int16 (Int.repr 64) :: Init_int16 (Int.repr 64) ::
                Init_int16 (Int.repr 35) :: Init_int16 (Int.repr 36) ::
                Init_int16 (Int.repr 34) :: Init_int16 (Int.repr 65) ::
                Init_int16 (Int.repr 220) :: Init_int16 (Int.repr 34) ::
                Init_int16 (Int.repr 33) :: Init_int16 (Int.repr 65) ::
                Init_int16 (Int.repr 69) :: Init_int16 (Int.repr 74) ::
                Init_int16 (Int.repr 72) :: Init_int16 (Int.repr 66) ::
                Init_int16 (Int.repr 34) :: Init_int16 (Int.repr 220) ::
                Init_int16 (Int.repr 66) :: Init_int16 (Int.repr 50) ::
                Init_int16 (Int.repr 34) :: Init_int16 (Int.repr 67) ::
                Init_int16 (Int.repr 50) :: Init_int16 (Int.repr 66) ::
                Init_int16 (Int.repr 68) :: Init_int16 (Int.repr 48) ::
                Init_int16 (Int.repr 67) :: Init_int16 (Int.repr 67) ::
                Init_int16 (Int.repr 48) :: Init_int16 (Int.repr 50) ::
                Init_int16 (Int.repr 68) :: Init_int16 (Int.repr 46) ::
                Init_int16 (Int.repr 48) :: Init_int16 (Int.repr 55) ::
                Init_int16 (Int.repr 51) :: Init_int16 (Int.repr 52) ::
                Init_int16 (Int.repr 69) :: Init_int16 (Int.repr 72) ::
                Init_int16 (Int.repr 70) :: Init_int16 (Int.repr 71) ::
                Init_int16 (Int.repr 72) :: Init_int16 (Int.repr 74) ::
                Init_int16 (Int.repr 72) :: Init_int16 (Int.repr 222) ::
                Init_int16 (Int.repr 70) :: Init_int16 (Int.repr 72) ::
                Init_int16 (Int.repr 223) :: Init_int16 (Int.repr 86) ::
                Init_int16 (Int.repr 72) :: Init_int16 (Int.repr 82) ::
                Init_int16 (Int.repr 222) :: Init_int16 (Int.repr 72) ::
                Init_int16 (Int.repr 83) :: Init_int16 (Int.repr 82) ::
                Init_int16 (Int.repr 72) :: Init_int16 (Int.repr 84) ::
                Init_int16 (Int.repr 83) :: Init_int16 (Int.repr 72) ::
                Init_int16 (Int.repr 85) :: Init_int16 (Int.repr 84) ::
                Init_int16 (Int.repr 72) :: Init_int16 (Int.repr 86) ::
                Init_int16 (Int.repr 85) :: Init_int16 (Int.repr 72) ::
                Init_int16 (Int.repr 71) :: Init_int16 (Int.repr 223) ::
                Init_int16 (Int.repr 73) :: Init_int16 (Int.repr 70) ::
                Init_int16 (Int.repr 222) :: Init_int16 (Int.repr 70) ::
                Init_int16 (Int.repr 224) :: Init_int16 (Int.repr 81) ::
                Init_int16 (Int.repr 70) :: Init_int16 (Int.repr 73) ::
                Init_int16 (Int.repr 224) :: Init_int16 (Int.repr 82) ::
                Init_int16 (Int.repr 73) :: Init_int16 (Int.repr 222) ::
                Init_int16 (Int.repr 83) :: Init_int16 (Int.repr 73) ::
                Init_int16 (Int.repr 82) :: Init_int16 (Int.repr 70) ::
                Init_int16 (Int.repr 225) :: Init_int16 (Int.repr 75) ::
                Init_int16 (Int.repr 69) :: Init_int16 (Int.repr 221) ::
                Init_int16 (Int.repr 74) :: Init_int16 (Int.repr 74) ::
                Init_int16 (Int.repr 232) :: Init_int16 (Int.repr 221) ::
                Init_int16 (Int.repr 70) :: Init_int16 (Int.repr 221) ::
                Init_int16 (Int.repr 69) :: Init_int16 (Int.repr 70) ::
                Init_int16 (Int.repr 75) :: Init_int16 (Int.repr 221) ::
                Init_int16 (Int.repr 75) :: Init_int16 (Int.repr 225) ::
                Init_int16 (Int.repr 226) :: Init_int16 (Int.repr 76) ::
                Init_int16 (Int.repr 75) :: Init_int16 (Int.repr 226) ::
                Init_int16 (Int.repr 77) :: Init_int16 (Int.repr 221) ::
                Init_int16 (Int.repr 75) :: Init_int16 (Int.repr 77) ::
                Init_int16 (Int.repr 75) :: Init_int16 (Int.repr 76) ::
                Init_int16 (Int.repr 77) :: Init_int16 (Int.repr 74) ::
                Init_int16 (Int.repr 221) :: Init_int16 (Int.repr 70) ::
                Init_int16 (Int.repr 78) :: Init_int16 (Int.repr 225) ::
                Init_int16 (Int.repr 70) :: Init_int16 (Int.repr 79) ::
                Init_int16 (Int.repr 78) :: Init_int16 (Int.repr 70) ::
                Init_int16 (Int.repr 80) :: Init_int16 (Int.repr 79) ::
                Init_int16 (Int.repr 70) :: Init_int16 (Int.repr 81) ::
                Init_int16 (Int.repr 80) :: Init_int16 (Int.repr 78) ::
                Init_int16 (Int.repr 226) :: Init_int16 (Int.repr 225) ::
                Init_int16 (Int.repr 78) :: Init_int16 (Int.repr 227) ::
                Init_int16 (Int.repr 226) :: Init_int16 (Int.repr 79) ::
                Init_int16 (Int.repr 227) :: Init_int16 (Int.repr 78) ::
                Init_int16 (Int.repr 79) :: Init_int16 (Int.repr 234) ::
                Init_int16 (Int.repr 227) :: Init_int16 (Int.repr 80) ::
                Init_int16 (Int.repr 234) :: Init_int16 (Int.repr 79) ::
                Init_int16 (Int.repr 81) :: Init_int16 (Int.repr 228) ::
                Init_int16 (Int.repr 80) :: Init_int16 (Int.repr 80) ::
                Init_int16 (Int.repr 228) :: Init_int16 (Int.repr 234) ::
                Init_int16 (Int.repr 81) :: Init_int16 (Int.repr 224) ::
                Init_int16 (Int.repr 228) :: Init_int16 (Int.repr 83) ::
                Init_int16 (Int.repr 229) :: Init_int16 (Int.repr 73) ::
                Init_int16 (Int.repr 84) :: Init_int16 (Int.repr 229) ::
                Init_int16 (Int.repr 83) :: Init_int16 (Int.repr 90) ::
                Init_int16 (Int.repr 91) :: Init_int16 (Int.repr 226) ::
                Init_int16 (Int.repr 84) :: Init_int16 (Int.repr 230) ::
                Init_int16 (Int.repr 229) :: Init_int16 (Int.repr 85) ::
                Init_int16 (Int.repr 230) :: Init_int16 (Int.repr 84) ::
                Init_int16 (Int.repr 86) :: Init_int16 (Int.repr 231) ::
                Init_int16 (Int.repr 85) :: Init_int16 (Int.repr 85) ::
                Init_int16 (Int.repr 231) :: Init_int16 (Int.repr 230) ::
                Init_int16 (Int.repr 86) :: Init_int16 (Int.repr 87) ::
                Init_int16 (Int.repr 231) :: Init_int16 (Int.repr 87) ::
                Init_int16 (Int.repr 86) :: Init_int16 (Int.repr 223) ::
                Init_int16 (Int.repr 88) :: Init_int16 (Int.repr 87) ::
                Init_int16 (Int.repr 223) :: Init_int16 (Int.repr 71) ::
                Init_int16 (Int.repr 88) :: Init_int16 (Int.repr 223) ::
                Init_int16 (Int.repr 89) :: Init_int16 (Int.repr 226) ::
                Init_int16 (Int.repr 227) :: Init_int16 (Int.repr 90) ::
                Init_int16 (Int.repr 226) :: Init_int16 (Int.repr 89) ::
                Init_int16 (Int.repr 97) :: Init_int16 (Int.repr 235) ::
                Init_int16 (Int.repr 98) :: Init_int16 (Int.repr 92) ::
                Init_int16 (Int.repr 227) :: Init_int16 (Int.repr 234) ::
                Init_int16 (Int.repr 89) :: Init_int16 (Int.repr 227) ::
                Init_int16 (Int.repr 92) :: Init_int16 (Int.repr 92) ::
                Init_int16 (Int.repr 234) :: Init_int16 (Int.repr 93) ::
                Init_int16 (Int.repr 93) :: Init_int16 (Int.repr 234) ::
                Init_int16 (Int.repr 228) :: Init_int16 (Int.repr 93) ::
                Init_int16 (Int.repr 228) :: Init_int16 (Int.repr 94) ::
                Init_int16 (Int.repr 94) :: Init_int16 (Int.repr 228) ::
                Init_int16 (Int.repr 224) :: Init_int16 (Int.repr 94) ::
                Init_int16 (Int.repr 224) :: Init_int16 (Int.repr 95) ::
                Init_int16 (Int.repr 95) :: Init_int16 (Int.repr 224) ::
                Init_int16 (Int.repr 73) :: Init_int16 (Int.repr 95) ::
                Init_int16 (Int.repr 73) :: Init_int16 (Int.repr 96) ::
                Init_int16 (Int.repr 96) :: Init_int16 (Int.repr 73) ::
                Init_int16 (Int.repr 229) :: Init_int16 (Int.repr 98) ::
                Init_int16 (Int.repr 235) :: Init_int16 (Int.repr 71) ::
                Init_int16 (Int.repr 98) :: Init_int16 (Int.repr 71) ::
                Init_int16 (Int.repr 233) :: Init_int16 (Int.repr 77) ::
                Init_int16 (Int.repr 98) :: Init_int16 (Int.repr 233) ::
                Init_int16 (Int.repr 74) :: Init_int16 (Int.repr 233) ::
                Init_int16 (Int.repr 71) :: Init_int16 (Int.repr 99) ::
                Init_int16 (Int.repr 71) :: Init_int16 (Int.repr 235) ::
                Init_int16 (Int.repr 100) :: Init_int16 (Int.repr 71) ::
                Init_int16 (Int.repr 99) :: Init_int16 (Int.repr 100) ::
                Init_int16 (Int.repr 88) :: Init_int16 (Int.repr 71) ::
                Init_int16 (Int.repr 77) :: Init_int16 (Int.repr 233) ::
                Init_int16 (Int.repr 74) :: Init_int16 (Int.repr 97) ::
                Init_int16 (Int.repr 236) :: Init_int16 (Int.repr 235) ::
                Init_int16 (Int.repr 101) :: Init_int16 (Int.repr 235) ::
                Init_int16 (Int.repr 236) :: Init_int16 (Int.repr 99) ::
                Init_int16 (Int.repr 235) :: Init_int16 (Int.repr 101) ::
                Init_int16 (Int.repr 77) :: Init_int16 (Int.repr 102) ::
                Init_int16 (Int.repr 97) :: Init_int16 (Int.repr 102) ::
                Init_int16 (Int.repr 236) :: Init_int16 (Int.repr 97) ::
                Init_int16 (Int.repr 77) :: Init_int16 (Int.repr 97) ::
                Init_int16 (Int.repr 98) :: Init_int16 (Int.repr 107) ::
                Init_int16 (Int.repr 91) :: Init_int16 (Int.repr 90) ::
                Init_int16 (Int.repr 91) :: Init_int16 (Int.repr 76) ::
                Init_int16 (Int.repr 226) :: Init_int16 (Int.repr 101) ::
                Init_int16 (Int.repr 236) :: Init_int16 (Int.repr 103) ::
                Init_int16 (Int.repr 103) :: Init_int16 (Int.repr 236) ::
                Init_int16 (Int.repr 102) :: Init_int16 (Int.repr 104) ::
                Init_int16 (Int.repr 102) :: Init_int16 (Int.repr 77) ::
                Init_int16 (Int.repr 77) :: Init_int16 (Int.repr 106) ::
                Init_int16 (Int.repr 104) :: Init_int16 (Int.repr 77) ::
                Init_int16 (Int.repr 76) :: Init_int16 (Int.repr 106) ::
                Init_int16 (Int.repr 105) :: Init_int16 (Int.repr 102) ::
                Init_int16 (Int.repr 237) :: Init_int16 (Int.repr 104) ::
                Init_int16 (Int.repr 237) :: Init_int16 (Int.repr 102) ::
                Init_int16 (Int.repr 103) :: Init_int16 (Int.repr 102) ::
                Init_int16 (Int.repr 105) :: Init_int16 (Int.repr 106) ::
                Init_int16 (Int.repr 237) :: Init_int16 (Int.repr 104) ::
                Init_int16 (Int.repr 107) :: Init_int16 (Int.repr 237) ::
                Init_int16 (Int.repr 91) :: Init_int16 (Int.repr 105) ::
                Init_int16 (Int.repr 237) :: Init_int16 (Int.repr 107) ::
                Init_int16 (Int.repr 106) :: Init_int16 (Int.repr 91) ::
                Init_int16 (Int.repr 237) :: Init_int16 (Int.repr 91) ::
                Init_int16 (Int.repr 106) :: Init_int16 (Int.repr 76) ::
                Init_int16 (Int.repr 112) :: Init_int16 (Int.repr 108) ::
                Init_int16 (Int.repr 109) :: Init_int16 (Int.repr 108) ::
                Init_int16 (Int.repr 229) :: Init_int16 (Int.repr 230) ::
                Init_int16 (Int.repr 96) :: Init_int16 (Int.repr 229) ::
                Init_int16 (Int.repr 108) :: Init_int16 (Int.repr 109) ::
                Init_int16 (Int.repr 230) :: Init_int16 (Int.repr 231) ::
                Init_int16 (Int.repr 108) :: Init_int16 (Int.repr 230) ::
                Init_int16 (Int.repr 109) :: Init_int16 (Int.repr 109) ::
                Init_int16 (Int.repr 231) :: Init_int16 (Int.repr 110) ::
                Init_int16 (Int.repr 110) :: Init_int16 (Int.repr 231) ::
                Init_int16 (Int.repr 87) :: Init_int16 (Int.repr 110) ::
                Init_int16 (Int.repr 87) :: Init_int16 (Int.repr 111) ::
                Init_int16 (Int.repr 111) :: Init_int16 (Int.repr 87) ::
                Init_int16 (Int.repr 88) :: Init_int16 (Int.repr 111) ::
                Init_int16 (Int.repr 88) :: Init_int16 (Int.repr 100) ::
                Init_int16 (Int.repr 112) :: Init_int16 (Int.repr 109) ::
                Init_int16 (Int.repr 113) :: Init_int16 (Int.repr 113) ::
                Init_int16 (Int.repr 110) :: Init_int16 (Int.repr 238) ::
                Init_int16 (Int.repr 113) :: Init_int16 (Int.repr 109) ::
                Init_int16 (Int.repr 110) :: Init_int16 (Int.repr 117) ::
                Init_int16 (Int.repr 112) :: Init_int16 (Int.repr 115) ::
                Init_int16 (Int.repr 113) :: Init_int16 (Int.repr 239) ::
                Init_int16 (Int.repr 115) :: Init_int16 (Int.repr 114) ::
                Init_int16 (Int.repr 100) :: Init_int16 (Int.repr 239) ::
                Init_int16 (Int.repr 100) :: Init_int16 (Int.repr 115) ::
                Init_int16 (Int.repr 239) :: Init_int16 (Int.repr 113) ::
                Init_int16 (Int.repr 114) :: Init_int16 (Int.repr 239) ::
                Init_int16 (Int.repr 115) :: Init_int16 (Int.repr 101) ::
                Init_int16 (Int.repr 117) :: Init_int16 (Int.repr 100) ::
                Init_int16 (Int.repr 99) :: Init_int16 (Int.repr 115) ::
                Init_int16 (Int.repr 115) :: Init_int16 (Int.repr 99) ::
                Init_int16 (Int.repr 101) :: Init_int16 (Int.repr 114) ::
                Init_int16 (Int.repr 111) :: Init_int16 (Int.repr 100) ::
                Init_int16 (Int.repr 110) :: Init_int16 (Int.repr 114) ::
                Init_int16 (Int.repr 238) :: Init_int16 (Int.repr 110) ::
                Init_int16 (Int.repr 111) :: Init_int16 (Int.repr 114) ::
                Init_int16 (Int.repr 113) :: Init_int16 (Int.repr 238) ::
                Init_int16 (Int.repr 114) :: Init_int16 (Int.repr 116) ::
                Init_int16 (Int.repr 108) :: Init_int16 (Int.repr 112) ::
                Init_int16 (Int.repr 117) :: Init_int16 (Int.repr 116) ::
                Init_int16 (Int.repr 112) :: Init_int16 (Int.repr 112) ::
                Init_int16 (Int.repr 113) :: Init_int16 (Int.repr 115) ::
                Init_int16 (Int.repr 117) :: Init_int16 (Int.repr 122) ::
                Init_int16 (Int.repr 121) :: Init_int16 (Int.repr 117) ::
                Init_int16 (Int.repr 101) :: Init_int16 (Int.repr 103) ::
                Init_int16 (Int.repr 117) :: Init_int16 (Int.repr 103) ::
                Init_int16 (Int.repr 125) :: Init_int16 (Int.repr 117) ::
                Init_int16 (Int.repr 123) :: Init_int16 (Int.repr 240) ::
                Init_int16 (Int.repr 117) :: Init_int16 (Int.repr 124) ::
                Init_int16 (Int.repr 123) :: Init_int16 (Int.repr 117) ::
                Init_int16 (Int.repr 125) :: Init_int16 (Int.repr 124) ::
                Init_int16 (Int.repr 117) :: Init_int16 (Int.repr 240) ::
                Init_int16 (Int.repr 122) :: Init_int16 (Int.repr 117) ::
                Init_int16 (Int.repr 118) :: Init_int16 (Int.repr 116) ::
                Init_int16 (Int.repr 117) :: Init_int16 (Int.repr 119) ::
                Init_int16 (Int.repr 118) :: Init_int16 (Int.repr 117) ::
                Init_int16 (Int.repr 120) :: Init_int16 (Int.repr 119) ::
                Init_int16 (Int.repr 117) :: Init_int16 (Int.repr 121) ::
                Init_int16 (Int.repr 120) :: Init_int16 (Int.repr 90) ::
                Init_int16 (Int.repr 89) :: Init_int16 (Int.repr 122) ::
                Init_int16 (Int.repr 116) :: Init_int16 (Int.repr 96) ::
                Init_int16 (Int.repr 108) :: Init_int16 (Int.repr 118) ::
                Init_int16 (Int.repr 96) :: Init_int16 (Int.repr 116) ::
                Init_int16 (Int.repr 119) :: Init_int16 (Int.repr 95) ::
                Init_int16 (Int.repr 118) :: Init_int16 (Int.repr 118) ::
                Init_int16 (Int.repr 95) :: Init_int16 (Int.repr 96) ::
                Init_int16 (Int.repr 120) :: Init_int16 (Int.repr 94) ::
                Init_int16 (Int.repr 119) :: Init_int16 (Int.repr 119) ::
                Init_int16 (Int.repr 94) :: Init_int16 (Int.repr 95) ::
                Init_int16 (Int.repr 121) :: Init_int16 (Int.repr 93) ::
                Init_int16 (Int.repr 120) :: Init_int16 (Int.repr 120) ::
                Init_int16 (Int.repr 93) :: Init_int16 (Int.repr 94) ::
                Init_int16 (Int.repr 121) :: Init_int16 (Int.repr 92) ::
                Init_int16 (Int.repr 93) :: Init_int16 (Int.repr 122) ::
                Init_int16 (Int.repr 92) :: Init_int16 (Int.repr 121) ::
                Init_int16 (Int.repr 122) :: Init_int16 (Int.repr 89) ::
                Init_int16 (Int.repr 92) :: Init_int16 (Int.repr 90) ::
                Init_int16 (Int.repr 122) :: Init_int16 (Int.repr 240) ::
                Init_int16 (Int.repr 123) :: Init_int16 (Int.repr 90) ::
                Init_int16 (Int.repr 240) :: Init_int16 (Int.repr 124) ::
                Init_int16 (Int.repr 107) :: Init_int16 (Int.repr 123) ::
                Init_int16 (Int.repr 123) :: Init_int16 (Int.repr 107) ::
                Init_int16 (Int.repr 90) :: Init_int16 (Int.repr 125) ::
                Init_int16 (Int.repr 105) :: Init_int16 (Int.repr 124) ::
                Init_int16 (Int.repr 124) :: Init_int16 (Int.repr 105) ::
                Init_int16 (Int.repr 107) :: Init_int16 (Int.repr 125) ::
                Init_int16 (Int.repr 103) :: Init_int16 (Int.repr 105) ::
                Init_int16 (Int.repr 126) :: Init_int16 (Int.repr 241) ::
                Init_int16 (Int.repr 127) :: Init_int16 (Int.repr 127) ::
                Init_int16 (Int.repr 242) :: Init_int16 (Int.repr 132) ::
                Init_int16 (Int.repr 127) :: Init_int16 (Int.repr 138) ::
                Init_int16 (Int.repr 242) :: Init_int16 (Int.repr 128) ::
                Init_int16 (Int.repr 126) :: Init_int16 (Int.repr 127) ::
                Init_int16 (Int.repr 127) :: Init_int16 (Int.repr 243) ::
                Init_int16 (Int.repr 128) :: Init_int16 (Int.repr 127) ::
                Init_int16 (Int.repr 244) :: Init_int16 (Int.repr 243) ::
                Init_int16 (Int.repr 130) :: Init_int16 (Int.repr 243) ::
                Init_int16 (Int.repr 244) :: Init_int16 (Int.repr 128) ::
                Init_int16 (Int.repr 243) :: Init_int16 (Int.repr 130) ::
                Init_int16 (Int.repr 128) :: Init_int16 (Int.repr 130) ::
                Init_int16 (Int.repr 126) :: Init_int16 (Int.repr 131) ::
                Init_int16 (Int.repr 133) :: Init_int16 (Int.repr 244) ::
                Init_int16 (Int.repr 127) :: Init_int16 (Int.repr 132) ::
                Init_int16 (Int.repr 244) :: Init_int16 (Int.repr 132) ::
                Init_int16 (Int.repr 131) :: Init_int16 (Int.repr 244) ::
                Init_int16 (Int.repr 133) :: Init_int16 (Int.repr 130) ::
                Init_int16 (Int.repr 244) :: Init_int16 (Int.repr 132) ::
                Init_int16 (Int.repr 136) :: Init_int16 (Int.repr 134) ::
                Init_int16 (Int.repr 132) :: Init_int16 (Int.repr 134) ::
                Init_int16 (Int.repr 131) :: Init_int16 (Int.repr 131) ::
                Init_int16 (Int.repr 140) :: Init_int16 (Int.repr 139) ::
                Init_int16 (Int.repr 131) :: Init_int16 (Int.repr 250) ::
                Init_int16 (Int.repr 140) :: Init_int16 (Int.repr 131) ::
                Init_int16 (Int.repr 139) :: Init_int16 (Int.repr 133) ::
                Init_int16 (Int.repr 134) :: Init_int16 (Int.repr 141) ::
                Init_int16 (Int.repr 131) :: Init_int16 (Int.repr 134) ::
                Init_int16 (Int.repr 145) :: Init_int16 (Int.repr 143) ::
                Init_int16 (Int.repr 134) :: Init_int16 (Int.repr 146) ::
                Init_int16 (Int.repr 145) :: Init_int16 (Int.repr 134) ::
                Init_int16 (Int.repr 251) :: Init_int16 (Int.repr 146) ::
                Init_int16 (Int.repr 136) :: Init_int16 (Int.repr 252) ::
                Init_int16 (Int.repr 134) :: Init_int16 (Int.repr 134) ::
                Init_int16 (Int.repr 143) :: Init_int16 (Int.repr 142) ::
                Init_int16 (Int.repr 134) :: Init_int16 (Int.repr 253) ::
                Init_int16 (Int.repr 141) :: Init_int16 (Int.repr 134) ::
                Init_int16 (Int.repr 142) :: Init_int16 (Int.repr 253) ::
                Init_int16 (Int.repr 137) :: Init_int16 (Int.repr 251) ::
                Init_int16 (Int.repr 134) :: Init_int16 (Int.repr 134) ::
                Init_int16 (Int.repr 252) :: Init_int16 (Int.repr 137) ::
                Init_int16 (Int.repr 136) :: Init_int16 (Int.repr 148) ::
                Init_int16 (Int.repr 252) :: Init_int16 (Int.repr 136) ::
                Init_int16 (Int.repr 150) :: Init_int16 (Int.repr 148) ::
                Init_int16 (Int.repr 136) :: Init_int16 (Int.repr 151) ::
                Init_int16 (Int.repr 150) :: Init_int16 (Int.repr 137) ::
                Init_int16 (Int.repr 146) :: Init_int16 (Int.repr 251) ::
                Init_int16 (Int.repr 138) :: Init_int16 (Int.repr 245) ::
                Init_int16 (Int.repr 242) :: Init_int16 (Int.repr 129) ::
                Init_int16 (Int.repr 242) :: Init_int16 (Int.repr 245) ::
                Init_int16 (Int.repr 129) :: Init_int16 (Int.repr 132) ::
                Init_int16 (Int.repr 242) :: Init_int16 (Int.repr 126) ::
                Init_int16 (Int.repr 246) :: Init_int16 (Int.repr 241) ::
                Init_int16 (Int.repr 126) :: Init_int16 (Int.repr 154) ::
                Init_int16 (Int.repr 246) :: Init_int16 (Int.repr 126) ::
                Init_int16 (Int.repr 157) :: Init_int16 (Int.repr 154) ::
                Init_int16 (Int.repr 126) :: Init_int16 (Int.repr 247) ::
                Init_int16 (Int.repr 157) :: Init_int16 (Int.repr 126) ::
                Init_int16 (Int.repr 158) :: Init_int16 (Int.repr 247) ::
                Init_int16 (Int.repr 130) :: Init_int16 (Int.repr 248) ::
                Init_int16 (Int.repr 126) :: Init_int16 (Int.repr 126) ::
                Init_int16 (Int.repr 248) :: Init_int16 (Int.repr 160) ::
                Init_int16 (Int.repr 129) :: Init_int16 (Int.repr 246) ::
                Init_int16 (Int.repr 154) :: Init_int16 (Int.repr 129) ::
                Init_int16 (Int.repr 241) :: Init_int16 (Int.repr 246) ::
                Init_int16 (Int.repr 142) :: Init_int16 (Int.repr 135) ::
                Init_int16 (Int.repr 253) :: Init_int16 (Int.repr 133) ::
                Init_int16 (Int.repr 254) :: Init_int16 (Int.repr 130) ::
                Init_int16 (Int.repr 139) :: Init_int16 (Int.repr 254) ::
                Init_int16 (Int.repr 133) :: Init_int16 (Int.repr 140) ::
                Init_int16 (Int.repr 255) :: Init_int16 (Int.repr 139) ::
                Init_int16 (Int.repr 139) :: Init_int16 (Int.repr 255) ::
                Init_int16 (Int.repr 254) :: Init_int16 (Int.repr 135) ::
                Init_int16 (Int.repr 140) :: Init_int16 (Int.repr 250) ::
                Init_int16 (Int.repr 135) :: Init_int16 (Int.repr 256) ::
                Init_int16 (Int.repr 140) :: Init_int16 (Int.repr 140) ::
                Init_int16 (Int.repr 256) :: Init_int16 (Int.repr 255) ::
                Init_int16 (Int.repr 135) :: Init_int16 (Int.repr 250) ::
                Init_int16 (Int.repr 131) :: Init_int16 (Int.repr 131) ::
                Init_int16 (Int.repr 141) :: Init_int16 (Int.repr 135) ::
                Init_int16 (Int.repr 141) :: Init_int16 (Int.repr 253) ::
                Init_int16 (Int.repr 135) :: Init_int16 (Int.repr 142) ::
                Init_int16 (Int.repr 257) :: Init_int16 (Int.repr 135) ::
                Init_int16 (Int.repr 143) :: Init_int16 (Int.repr 144) ::
                Init_int16 (Int.repr 142) :: Init_int16 (Int.repr 144) ::
                Init_int16 (Int.repr 257) :: Init_int16 (Int.repr 142) ::
                Init_int16 (Int.repr 145) :: Init_int16 (Int.repr 144) ::
                Init_int16 (Int.repr 143) :: Init_int16 (Int.repr 146) ::
                Init_int16 (Int.repr 147) :: Init_int16 (Int.repr 145) ::
                Init_int16 (Int.repr 147) :: Init_int16 (Int.repr 258) ::
                Init_int16 (Int.repr 145) :: Init_int16 (Int.repr 145) ::
                Init_int16 (Int.repr 258) :: Init_int16 (Int.repr 144) ::
                Init_int16 (Int.repr 137) :: Init_int16 (Int.repr 147) ::
                Init_int16 (Int.repr 146) :: Init_int16 (Int.repr 148) ::
                Init_int16 (Int.repr 149) :: Init_int16 (Int.repr 252) ::
                Init_int16 (Int.repr 149) :: Init_int16 (Int.repr 137) ::
                Init_int16 (Int.repr 252) :: Init_int16 (Int.repr 129) ::
                Init_int16 (Int.repr 245) :: Init_int16 (Int.repr 138) ::
                Init_int16 (Int.repr 136) :: Init_int16 (Int.repr 152) ::
                Init_int16 (Int.repr 151) :: Init_int16 (Int.repr 150) ::
                Init_int16 (Int.repr 149) :: Init_int16 (Int.repr 148) ::
                Init_int16 (Int.repr 151) :: Init_int16 (Int.repr 259) ::
                Init_int16 (Int.repr 150) :: Init_int16 (Int.repr 150) ::
                Init_int16 (Int.repr 259) :: Init_int16 (Int.repr 149) ::
                Init_int16 (Int.repr 152) :: Init_int16 (Int.repr 260) ::
                Init_int16 (Int.repr 151) :: Init_int16 (Int.repr 151) ::
                Init_int16 (Int.repr 260) :: Init_int16 (Int.repr 259) ::
                Init_int16 (Int.repr 136) :: Init_int16 (Int.repr 129) ::
                Init_int16 (Int.repr 152) :: Init_int16 (Int.repr 153) ::
                Init_int16 (Int.repr 152) :: Init_int16 (Int.repr 129) ::
                Init_int16 (Int.repr 152) :: Init_int16 (Int.repr 153) ::
                Init_int16 (Int.repr 260) :: Init_int16 (Int.repr 153) ::
                Init_int16 (Int.repr 129) :: Init_int16 (Int.repr 261) ::
                Init_int16 (Int.repr 129) :: Init_int16 (Int.repr 136) ::
                Init_int16 (Int.repr 132) :: Init_int16 (Int.repr 154) ::
                Init_int16 (Int.repr 261) :: Init_int16 (Int.repr 129) ::
                Init_int16 (Int.repr 129) :: Init_int16 (Int.repr 127) ::
                Init_int16 (Int.repr 241) :: Init_int16 (Int.repr 155) ::
                Init_int16 (Int.repr 154) :: Init_int16 (Int.repr 157) ::
                Init_int16 (Int.repr 156) :: Init_int16 (Int.repr 154) ::
                Init_int16 (Int.repr 155) :: Init_int16 (Int.repr 154) ::
                Init_int16 (Int.repr 161) :: Init_int16 (Int.repr 261) ::
                Init_int16 (Int.repr 154) :: Init_int16 (Int.repr 162) ::
                Init_int16 (Int.repr 161) :: Init_int16 (Int.repr 154) ::
                Init_int16 (Int.repr 163) :: Init_int16 (Int.repr 162) ::
                Init_int16 (Int.repr 154) :: Init_int16 (Int.repr 164) ::
                Init_int16 (Int.repr 163) :: Init_int16 (Int.repr 154) ::
                Init_int16 (Int.repr 156) :: Init_int16 (Int.repr 164) ::
                Init_int16 (Int.repr 157) :: Init_int16 (Int.repr 247) ::
                Init_int16 (Int.repr 155) :: Init_int16 (Int.repr 155) ::
                Init_int16 (Int.repr 164) :: Init_int16 (Int.repr 156) ::
                Init_int16 (Int.repr 158) :: Init_int16 (Int.repr 159) ::
                Init_int16 (Int.repr 247) :: Init_int16 (Int.repr 159) ::
                Init_int16 (Int.repr 155) :: Init_int16 (Int.repr 247) ::
                Init_int16 (Int.repr 160) :: Init_int16 (Int.repr 159) ::
                Init_int16 (Int.repr 158) :: Init_int16 (Int.repr 160) ::
                Init_int16 (Int.repr 158) :: Init_int16 (Int.repr 249) ::
                Init_int16 (Int.repr 126) :: Init_int16 (Int.repr 249) ::
                Init_int16 (Int.repr 158) :: Init_int16 (Int.repr 126) ::
                Init_int16 (Int.repr 160) :: Init_int16 (Int.repr 249) ::
                Init_int16 (Int.repr 129) :: Init_int16 (Int.repr 138) ::
                Init_int16 (Int.repr 127) :: Init_int16 (Int.repr 161) ::
                Init_int16 (Int.repr 153) :: Init_int16 (Int.repr 261) ::
                Init_int16 (Int.repr 166) :: Init_int16 (Int.repr 155) ::
                Init_int16 (Int.repr 159) :: Init_int16 (Int.repr 161) ::
                Init_int16 (Int.repr 262) :: Init_int16 (Int.repr 153) ::
                Init_int16 (Int.repr 162) :: Init_int16 (Int.repr 262) ::
                Init_int16 (Int.repr 161) :: Init_int16 (Int.repr 162) ::
                Init_int16 (Int.repr 263) :: Init_int16 (Int.repr 262) ::
                Init_int16 (Int.repr 163) :: Init_int16 (Int.repr 263) ::
                Init_int16 (Int.repr 162) :: Init_int16 (Int.repr 164) ::
                Init_int16 (Int.repr 264) :: Init_int16 (Int.repr 163) ::
                Init_int16 (Int.repr 163) :: Init_int16 (Int.repr 264) ::
                Init_int16 (Int.repr 263) :: Init_int16 (Int.repr 164) ::
                Init_int16 (Int.repr 265) :: Init_int16 (Int.repr 264) ::
                Init_int16 (Int.repr 155) :: Init_int16 (Int.repr 265) ::
                Init_int16 (Int.repr 164) :: Init_int16 (Int.repr 165) ::
                Init_int16 (Int.repr 155) :: Init_int16 (Int.repr 166) ::
                Init_int16 (Int.repr 165) :: Init_int16 (Int.repr 265) ::
                Init_int16 (Int.repr 155) :: Init_int16 (Int.repr 172) ::
                Init_int16 (Int.repr 160) :: Init_int16 (Int.repr 248) ::
                Init_int16 (Int.repr 167) :: Init_int16 (Int.repr 265) ::
                Init_int16 (Int.repr 165) :: Init_int16 (Int.repr 167) ::
                Init_int16 (Int.repr 264) :: Init_int16 (Int.repr 265) ::
                Init_int16 (Int.repr 168) :: Init_int16 (Int.repr 264) ::
                Init_int16 (Int.repr 167) :: Init_int16 (Int.repr 168) ::
                Init_int16 (Int.repr 263) :: Init_int16 (Int.repr 264) ::
                Init_int16 (Int.repr 169) :: Init_int16 (Int.repr 262) ::
                Init_int16 (Int.repr 263) :: Init_int16 (Int.repr 169) ::
                Init_int16 (Int.repr 263) :: Init_int16 (Int.repr 168) ::
                Init_int16 (Int.repr 170) :: Init_int16 (Int.repr 262) ::
                Init_int16 (Int.repr 169) :: Init_int16 (Int.repr 170) ::
                Init_int16 (Int.repr 153) :: Init_int16 (Int.repr 262) ::
                Init_int16 (Int.repr 171) :: Init_int16 (Int.repr 153) ::
                Init_int16 (Int.repr 170) :: Init_int16 (Int.repr 171) ::
                Init_int16 (Int.repr 260) :: Init_int16 (Int.repr 153) ::
                Init_int16 (Int.repr 173) :: Init_int16 (Int.repr 159) ::
                Init_int16 (Int.repr 160) :: Init_int16 (Int.repr 173) ::
                Init_int16 (Int.repr 160) :: Init_int16 (Int.repr 172) ::
                Init_int16 (Int.repr 172) :: Init_int16 (Int.repr 248) ::
                Init_int16 (Int.repr 174) :: Init_int16 (Int.repr 174) ::
                Init_int16 (Int.repr 248) :: Init_int16 (Int.repr 130) ::
                Init_int16 (Int.repr 166) :: Init_int16 (Int.repr 159) ::
                Init_int16 (Int.repr 173) :: Init_int16 (Int.repr 175) ::
                Init_int16 (Int.repr 130) :: Init_int16 (Int.repr 254) ::
                Init_int16 (Int.repr 174) :: Init_int16 (Int.repr 130) ::
                Init_int16 (Int.repr 175) :: Init_int16 (Int.repr 176) ::
                Init_int16 (Int.repr 135) :: Init_int16 (Int.repr 257) ::
                Init_int16 (Int.repr 177) :: Init_int16 (Int.repr 256) ::
                Init_int16 (Int.repr 135) :: Init_int16 (Int.repr 177) ::
                Init_int16 (Int.repr 135) :: Init_int16 (Int.repr 176) ::
                Init_int16 (Int.repr 178) :: Init_int16 (Int.repr 256) ::
                Init_int16 (Int.repr 177) :: Init_int16 (Int.repr 178) ::
                Init_int16 (Int.repr 255) :: Init_int16 (Int.repr 256) ::
                Init_int16 (Int.repr 179) :: Init_int16 (Int.repr 255) ::
                Init_int16 (Int.repr 178) :: Init_int16 (Int.repr 179) ::
                Init_int16 (Int.repr 254) :: Init_int16 (Int.repr 255) ::
                Init_int16 (Int.repr 175) :: Init_int16 (Int.repr 254) ::
                Init_int16 (Int.repr 179) :: Init_int16 (Int.repr 180) ::
                Init_int16 (Int.repr 137) :: Init_int16 (Int.repr 149) ::
                Init_int16 (Int.repr 181) :: Init_int16 (Int.repr 147) ::
                Init_int16 (Int.repr 137) :: Init_int16 (Int.repr 181) ::
                Init_int16 (Int.repr 137) :: Init_int16 (Int.repr 180) ::
                Init_int16 (Int.repr 182) :: Init_int16 (Int.repr 147) ::
                Init_int16 (Int.repr 181) :: Init_int16 (Int.repr 182) ::
                Init_int16 (Int.repr 258) :: Init_int16 (Int.repr 147) ::
                Init_int16 (Int.repr 186) :: Init_int16 (Int.repr 149) ::
                Init_int16 (Int.repr 259) :: Init_int16 (Int.repr 183) ::
                Init_int16 (Int.repr 258) :: Init_int16 (Int.repr 182) ::
                Init_int16 (Int.repr 183) :: Init_int16 (Int.repr 144) ::
                Init_int16 (Int.repr 258) :: Init_int16 (Int.repr 184) ::
                Init_int16 (Int.repr 144) :: Init_int16 (Int.repr 183) ::
                Init_int16 (Int.repr 184) :: Init_int16 (Int.repr 257) ::
                Init_int16 (Int.repr 144) :: Init_int16 (Int.repr 176) ::
                Init_int16 (Int.repr 257) :: Init_int16 (Int.repr 184) ::
                Init_int16 (Int.repr 185) :: Init_int16 (Int.repr 259) ::
                Init_int16 (Int.repr 260) :: Init_int16 (Int.repr 185) ::
                Init_int16 (Int.repr 260) :: Init_int16 (Int.repr 171) ::
                Init_int16 (Int.repr 186) :: Init_int16 (Int.repr 259) ::
                Init_int16 (Int.repr 185) :: Init_int16 (Int.repr 192) ::
                Init_int16 (Int.repr 190) :: Init_int16 (Int.repr 191) ::
                Init_int16 (Int.repr 180) :: Init_int16 (Int.repr 149) ::
                Init_int16 (Int.repr 186) :: Init_int16 (Int.repr 187) ::
                Init_int16 (Int.repr 166) :: Init_int16 (Int.repr 188) ::
                Init_int16 (Int.repr 188) :: Init_int16 (Int.repr 173) ::
                Init_int16 (Int.repr 192) :: Init_int16 (Int.repr 188) ::
                Init_int16 (Int.repr 166) :: Init_int16 (Int.repr 173) ::
                Init_int16 (Int.repr 189) :: Init_int16 (Int.repr 187) ::
                Init_int16 (Int.repr 188) :: Init_int16 (Int.repr 188) ::
                Init_int16 (Int.repr 191) :: Init_int16 (Int.repr 189) ::
                Init_int16 (Int.repr 188) :: Init_int16 (Int.repr 192) ::
                Init_int16 (Int.repr 191) :: Init_int16 (Int.repr 190) ::
                Init_int16 (Int.repr 175) :: Init_int16 (Int.repr 191) ::
                Init_int16 (Int.repr 191) :: Init_int16 (Int.repr 179) ::
                Init_int16 (Int.repr 207) :: Init_int16 (Int.repr 191) ::
                Init_int16 (Int.repr 175) :: Init_int16 (Int.repr 179) ::
                Init_int16 (Int.repr 194) :: Init_int16 (Int.repr 168) ::
                Init_int16 (Int.repr 193) :: Init_int16 (Int.repr 191) ::
                Init_int16 (Int.repr 193) :: Init_int16 (Int.repr 189) ::
                Init_int16 (Int.repr 191) :: Init_int16 (Int.repr 194) ::
                Init_int16 (Int.repr 193) :: Init_int16 (Int.repr 193) ::
                Init_int16 (Int.repr 167) :: Init_int16 (Int.repr 189) ::
                Init_int16 (Int.repr 189) :: Init_int16 (Int.repr 165) ::
                Init_int16 (Int.repr 187) :: Init_int16 (Int.repr 189) ::
                Init_int16 (Int.repr 167) :: Init_int16 (Int.repr 165) ::
                Init_int16 (Int.repr 192) :: Init_int16 (Int.repr 172) ::
                Init_int16 (Int.repr 208) :: Init_int16 (Int.repr 192) ::
                Init_int16 (Int.repr 173) :: Init_int16 (Int.repr 172) ::
                Init_int16 (Int.repr 192) :: Init_int16 (Int.repr 208) ::
                Init_int16 (Int.repr 190) :: Init_int16 (Int.repr 187) ::
                Init_int16 (Int.repr 165) :: Init_int16 (Int.repr 166) ::
                Init_int16 (Int.repr 193) :: Init_int16 (Int.repr 168) ::
                Init_int16 (Int.repr 167) :: Init_int16 (Int.repr 199) ::
                Init_int16 (Int.repr 186) :: Init_int16 (Int.repr 198) ::
                Init_int16 (Int.repr 191) :: Init_int16 (Int.repr 199) ::
                Init_int16 (Int.repr 198) :: Init_int16 (Int.repr 191) ::
                Init_int16 (Int.repr 198) :: Init_int16 (Int.repr 197) ::
                Init_int16 (Int.repr 194) :: Init_int16 (Int.repr 169) ::
                Init_int16 (Int.repr 168) :: Init_int16 (Int.repr 195) ::
                Init_int16 (Int.repr 169) :: Init_int16 (Int.repr 194) ::
                Init_int16 (Int.repr 191) :: Init_int16 (Int.repr 195) ::
                Init_int16 (Int.repr 194) :: Init_int16 (Int.repr 196) ::
                Init_int16 (Int.repr 170) :: Init_int16 (Int.repr 195) ::
                Init_int16 (Int.repr 195) :: Init_int16 (Int.repr 170) ::
                Init_int16 (Int.repr 169) :: Init_int16 (Int.repr 191) ::
                Init_int16 (Int.repr 196) :: Init_int16 (Int.repr 195) ::
                Init_int16 (Int.repr 197) :: Init_int16 (Int.repr 171) ::
                Init_int16 (Int.repr 196) :: Init_int16 (Int.repr 196) ::
                Init_int16 (Int.repr 171) :: Init_int16 (Int.repr 170) ::
                Init_int16 (Int.repr 191) :: Init_int16 (Int.repr 197) ::
                Init_int16 (Int.repr 196) :: Init_int16 (Int.repr 198) ::
                Init_int16 (Int.repr 185) :: Init_int16 (Int.repr 197) ::
                Init_int16 (Int.repr 197) :: Init_int16 (Int.repr 185) ::
                Init_int16 (Int.repr 171) :: Init_int16 (Int.repr 198) ::
                Init_int16 (Int.repr 186) :: Init_int16 (Int.repr 185) ::
                Init_int16 (Int.repr 204) :: Init_int16 (Int.repr 184) ::
                Init_int16 (Int.repr 203) :: Init_int16 (Int.repr 191) ::
                Init_int16 (Int.repr 204) :: Init_int16 (Int.repr 203) ::
                Init_int16 (Int.repr 191) :: Init_int16 (Int.repr 200) ::
                Init_int16 (Int.repr 199) :: Init_int16 (Int.repr 191) ::
                Init_int16 (Int.repr 201) :: Init_int16 (Int.repr 200) ::
                Init_int16 (Int.repr 191) :: Init_int16 (Int.repr 202) ::
                Init_int16 (Int.repr 201) :: Init_int16 (Int.repr 191) ::
                Init_int16 (Int.repr 203) :: Init_int16 (Int.repr 202) ::
                Init_int16 (Int.repr 199) :: Init_int16 (Int.repr 180) ::
                Init_int16 (Int.repr 186) :: Init_int16 (Int.repr 200) ::
                Init_int16 (Int.repr 180) :: Init_int16 (Int.repr 199) ::
                Init_int16 (Int.repr 201) :: Init_int16 (Int.repr 181) ::
                Init_int16 (Int.repr 200) :: Init_int16 (Int.repr 200) ::
                Init_int16 (Int.repr 181) :: Init_int16 (Int.repr 180) ::
                Init_int16 (Int.repr 202) :: Init_int16 (Int.repr 182) ::
                Init_int16 (Int.repr 201) :: Init_int16 (Int.repr 201) ::
                Init_int16 (Int.repr 182) :: Init_int16 (Int.repr 181) ::
                Init_int16 (Int.repr 202) :: Init_int16 (Int.repr 183) ::
                Init_int16 (Int.repr 182) :: Init_int16 (Int.repr 203) ::
                Init_int16 (Int.repr 183) :: Init_int16 (Int.repr 202) ::
                Init_int16 (Int.repr 203) :: Init_int16 (Int.repr 184) ::
                Init_int16 (Int.repr 183) :: Init_int16 (Int.repr 191) ::
                Init_int16 (Int.repr 205) :: Init_int16 (Int.repr 204) ::
                Init_int16 (Int.repr 191) :: Init_int16 (Int.repr 206) ::
                Init_int16 (Int.repr 205) :: Init_int16 (Int.repr 191) ::
                Init_int16 (Int.repr 207) :: Init_int16 (Int.repr 206) ::
                Init_int16 (Int.repr 204) :: Init_int16 (Int.repr 176) ::
                Init_int16 (Int.repr 184) :: Init_int16 (Int.repr 205) ::
                Init_int16 (Int.repr 176) :: Init_int16 (Int.repr 204) ::
                Init_int16 (Int.repr 206) :: Init_int16 (Int.repr 177) ::
                Init_int16 (Int.repr 205) :: Init_int16 (Int.repr 205) ::
                Init_int16 (Int.repr 177) :: Init_int16 (Int.repr 176) ::
                Init_int16 (Int.repr 206) :: Init_int16 (Int.repr 178) ::
                Init_int16 (Int.repr 177) :: Init_int16 (Int.repr 207) ::
                Init_int16 (Int.repr 178) :: Init_int16 (Int.repr 206) ::
                Init_int16 (Int.repr 207) :: Init_int16 (Int.repr 179) ::
                Init_int16 (Int.repr 178) :: Init_int16 (Int.repr 190) ::
                Init_int16 (Int.repr 174) :: Init_int16 (Int.repr 175) ::
                Init_int16 (Int.repr 208) :: Init_int16 (Int.repr 174) ::
                Init_int16 (Int.repr 190) :: Init_int16 (Int.repr 208) ::
                Init_int16 (Int.repr 172) :: Init_int16 (Int.repr 174) ::
                Init_int16 (Int.repr 327) :: Init_int16 (Int.repr 326) ::
                Init_int16 (Int.repr 328) :: Init_int16 (Int.repr 316) ::
                Init_int16 (Int.repr 317) :: Init_int16 (Int.repr 318) ::
                Init_int16 (Int.repr 316) :: Init_int16 (Int.repr 318) ::
                Init_int16 (Int.repr 319) :: Init_int16 (Int.repr 320) ::
                Init_int16 (Int.repr 317) :: Init_int16 (Int.repr 316) ::
                Init_int16 (Int.repr 319) :: Init_int16 (Int.repr 318) ::
                Init_int16 (Int.repr 321) :: Init_int16 (Int.repr 319) ::
                Init_int16 (Int.repr 321) :: Init_int16 (Int.repr 322) ::
                Init_int16 (Int.repr 320) :: Init_int16 (Int.repr 323) ::
                Init_int16 (Int.repr 317) :: Init_int16 (Int.repr 322) ::
                Init_int16 (Int.repr 321) :: Init_int16 (Int.repr 324) ::
                Init_int16 (Int.repr 322) :: Init_int16 (Int.repr 324) ::
                Init_int16 (Int.repr 325) :: Init_int16 (Int.repr 325) ::
                Init_int16 (Int.repr 324) :: Init_int16 (Int.repr 326) ::
                Init_int16 (Int.repr 325) :: Init_int16 (Int.repr 326) ::
                Init_int16 (Int.repr 327) :: Init_int16 (Int.repr 335) ::
                Init_int16 (Int.repr 465) :: Init_int16 (Int.repr 336) ::
                Init_int16 (Int.repr 327) :: Init_int16 (Int.repr 328) ::
                Init_int16 (Int.repr 329) :: Init_int16 (Int.repr 328) ::
                Init_int16 (Int.repr 330) :: Init_int16 (Int.repr 331) ::
                Init_int16 (Int.repr 329) :: Init_int16 (Int.repr 328) ::
                Init_int16 (Int.repr 331) :: Init_int16 (Int.repr 331) ::
                Init_int16 (Int.repr 330) :: Init_int16 (Int.repr 333) ::
                Init_int16 (Int.repr 331) :: Init_int16 (Int.repr 333) ::
                Init_int16 (Int.repr 332) :: Init_int16 (Int.repr 332) ::
                Init_int16 (Int.repr 333) :: Init_int16 (Int.repr 334) ::
                Init_int16 (Int.repr 333) :: Init_int16 (Int.repr 409) ::
                Init_int16 (Int.repr 334) :: Init_int16 (Int.repr 334) ::
                Init_int16 (Int.repr 409) :: Init_int16 (Int.repr 463) ::
                Init_int16 (Int.repr 334) :: Init_int16 (Int.repr 463) ::
                Init_int16 (Int.repr 335) :: Init_int16 (Int.repr 335) ::
                Init_int16 (Int.repr 463) :: Init_int16 (Int.repr 465) ::
                Init_int16 (Int.repr 342) :: Init_int16 (Int.repr 416) ::
                Init_int16 (Int.repr 471) :: Init_int16 (Int.repr 336) ::
                Init_int16 (Int.repr 465) :: Init_int16 (Int.repr 337) ::
                Init_int16 (Int.repr 336) :: Init_int16 (Int.repr 337) ::
                Init_int16 (Int.repr 338) :: Init_int16 (Int.repr 337) ::
                Init_int16 (Int.repr 468) :: Init_int16 (Int.repr 339) ::
                Init_int16 (Int.repr 338) :: Init_int16 (Int.repr 337) ::
                Init_int16 (Int.repr 339) :: Init_int16 (Int.repr 339) ::
                Init_int16 (Int.repr 468) :: Init_int16 (Int.repr 469) ::
                Init_int16 (Int.repr 339) :: Init_int16 (Int.repr 469) ::
                Init_int16 (Int.repr 340) :: Init_int16 (Int.repr 340) ::
                Init_int16 (Int.repr 469) :: Init_int16 (Int.repr 441) ::
                Init_int16 (Int.repr 340) :: Init_int16 (Int.repr 441) ::
                Init_int16 (Int.repr 341) :: Init_int16 (Int.repr 341) ::
                Init_int16 (Int.repr 441) :: Init_int16 (Int.repr 416) ::
                Init_int16 (Int.repr 341) :: Init_int16 (Int.repr 416) ::
                Init_int16 (Int.repr 342) :: Init_int16 (Int.repr 348) ::
                Init_int16 (Int.repr 373) :: Init_int16 (Int.repr 349) ::
                Init_int16 (Int.repr 342) :: Init_int16 (Int.repr 471) ::
                Init_int16 (Int.repr 343) :: Init_int16 (Int.repr 343) ::
                Init_int16 (Int.repr 471) :: Init_int16 (Int.repr 345) ::
                Init_int16 (Int.repr 343) :: Init_int16 (Int.repr 345) ::
                Init_int16 (Int.repr 344) :: Init_int16 (Int.repr 344) ::
                Init_int16 (Int.repr 345) :: Init_int16 (Int.repr 346) ::
                Init_int16 (Int.repr 345) :: Init_int16 (Int.repr 474) ::
                Init_int16 (Int.repr 346) :: Init_int16 (Int.repr 346) ::
                Init_int16 (Int.repr 474) :: Init_int16 (Int.repr 476) ::
                Init_int16 (Int.repr 346) :: Init_int16 (Int.repr 476) ::
                Init_int16 (Int.repr 347) :: Init_int16 (Int.repr 347) ::
                Init_int16 (Int.repr 476) :: Init_int16 (Int.repr 374) ::
                Init_int16 (Int.repr 347) :: Init_int16 (Int.repr 374) ::
                Init_int16 (Int.repr 348) :: Init_int16 (Int.repr 348) ::
                Init_int16 (Int.repr 374) :: Init_int16 (Int.repr 373) ::
                Init_int16 (Int.repr 354) :: Init_int16 (Int.repr 484) ::
                Init_int16 (Int.repr 485) :: Init_int16 (Int.repr 349) ::
                Init_int16 (Int.repr 373) :: Init_int16 (Int.repr 375) ::
                Init_int16 (Int.repr 349) :: Init_int16 (Int.repr 375) ::
                Init_int16 (Int.repr 350) :: Init_int16 (Int.repr 350) ::
                Init_int16 (Int.repr 375) :: Init_int16 (Int.repr 478) ::
                Init_int16 (Int.repr 350) :: Init_int16 (Int.repr 478) ::
                Init_int16 (Int.repr 351) :: Init_int16 (Int.repr 351) ::
                Init_int16 (Int.repr 478) :: Init_int16 (Int.repr 480) ::
                Init_int16 (Int.repr 351) :: Init_int16 (Int.repr 480) ::
                Init_int16 (Int.repr 352) :: Init_int16 (Int.repr 352) ::
                Init_int16 (Int.repr 480) :: Init_int16 (Int.repr 482) ::
                Init_int16 (Int.repr 352) :: Init_int16 (Int.repr 482) ::
                Init_int16 (Int.repr 353) :: Init_int16 (Int.repr 353) ::
                Init_int16 (Int.repr 482) :: Init_int16 (Int.repr 484) ::
                Init_int16 (Int.repr 353) :: Init_int16 (Int.repr 484) ::
                Init_int16 (Int.repr 354) :: Init_int16 (Int.repr 360) ::
                Init_int16 (Int.repr 457) :: Init_int16 (Int.repr 361) ::
                Init_int16 (Int.repr 354) :: Init_int16 (Int.repr 485) ::
                Init_int16 (Int.repr 355) :: Init_int16 (Int.repr 355) ::
                Init_int16 (Int.repr 485) :: Init_int16 (Int.repr 428) ::
                Init_int16 (Int.repr 355) :: Init_int16 (Int.repr 428) ::
                Init_int16 (Int.repr 356) :: Init_int16 (Int.repr 356) ::
                Init_int16 (Int.repr 428) :: Init_int16 (Int.repr 358) ::
                Init_int16 (Int.repr 356) :: Init_int16 (Int.repr 358) ::
                Init_int16 (Int.repr 357) :: Init_int16 (Int.repr 357) ::
                Init_int16 (Int.repr 358) :: Init_int16 (Int.repr 359) ::
                Init_int16 (Int.repr 358) :: Init_int16 (Int.repr 454) ::
                Init_int16 (Int.repr 359) :: Init_int16 (Int.repr 359) ::
                Init_int16 (Int.repr 454) :: Init_int16 (Int.repr 456) ::
                Init_int16 (Int.repr 359) :: Init_int16 (Int.repr 456) ::
                Init_int16 (Int.repr 360) :: Init_int16 (Int.repr 360) ::
                Init_int16 (Int.repr 456) :: Init_int16 (Int.repr 457) ::
                Init_int16 (Int.repr 361) :: Init_int16 (Int.repr 457) ::
                Init_int16 (Int.repr 458) :: Init_int16 (Int.repr 361) ::
                Init_int16 (Int.repr 458) :: Init_int16 (Int.repr 362) ::
                Init_int16 (Int.repr 362) :: Init_int16 (Int.repr 458) ::
                Init_int16 (Int.repr 363) :: Init_int16 (Int.repr 362) ::
                Init_int16 (Int.repr 363) :: Init_int16 (Int.repr 364) ::
                Init_int16 (Int.repr 363) :: Init_int16 (Int.repr 366) ::
                Init_int16 (Int.repr 365) :: Init_int16 (Int.repr 364) ::
                Init_int16 (Int.repr 363) :: Init_int16 (Int.repr 365) ::
                Init_int16 (Int.repr 365) :: Init_int16 (Int.repr 366) ::
                Init_int16 (Int.repr 367) :: Init_int16 (Int.repr 366) ::
                Init_int16 (Int.repr 368) :: Init_int16 (Int.repr 367) ::
                Init_int16 (Int.repr 367) :: Init_int16 (Int.repr 368) ::
                Init_int16 (Int.repr 369) :: Init_int16 (Int.repr 368) ::
                Init_int16 (Int.repr 386) :: Init_int16 (Int.repr 369) ::
                Init_int16 (Int.repr 369) :: Init_int16 (Int.repr 386) ::
                Init_int16 (Int.repr 387) :: Init_int16 (Int.repr 369) ::
                Init_int16 (Int.repr 387) :: Init_int16 (Int.repr 370) ::
                Init_int16 (Int.repr 370) :: Init_int16 (Int.repr 387) ::
                Init_int16 (Int.repr 323) :: Init_int16 (Int.repr 370) ::
                Init_int16 (Int.repr 323) :: Init_int16 (Int.repr 320) ::
                Init_int16 (Int.repr 334) :: Init_int16 (Int.repr 341) ::
                Init_int16 (Int.repr 342) :: Init_int16 (Int.repr 342) ::
                Init_int16 (Int.repr 343) :: Init_int16 (Int.repr 344) ::
                Init_int16 (Int.repr 342) :: Init_int16 (Int.repr 344) ::
                Init_int16 (Int.repr 346) :: Init_int16 (Int.repr 342) ::
                Init_int16 (Int.repr 346) :: Init_int16 (Int.repr 350) ::
                Init_int16 (Int.repr 342) :: Init_int16 (Int.repr 350) ::
                Init_int16 (Int.repr 357) :: Init_int16 (Int.repr 342) ::
                Init_int16 (Int.repr 357) :: Init_int16 (Int.repr 365) ::
                Init_int16 (Int.repr 342) :: Init_int16 (Int.repr 365) ::
                Init_int16 (Int.repr 322) :: Init_int16 (Int.repr 342) ::
                Init_int16 (Int.repr 322) :: Init_int16 (Int.repr 334) ::
                Init_int16 (Int.repr 334) :: Init_int16 (Int.repr 336) ::
                Init_int16 (Int.repr 338) :: Init_int16 (Int.repr 365) ::
                Init_int16 (Int.repr 319) :: Init_int16 (Int.repr 322) ::
                Init_int16 (Int.repr 322) :: Init_int16 (Int.repr 325) ::
                Init_int16 (Int.repr 327) :: Init_int16 (Int.repr 322) ::
                Init_int16 (Int.repr 327) :: Init_int16 (Int.repr 329) ::
                Init_int16 (Int.repr 322) :: Init_int16 (Int.repr 329) ::
                Init_int16 (Int.repr 331) :: Init_int16 (Int.repr 322) ::
                Init_int16 (Int.repr 331) :: Init_int16 (Int.repr 332) ::
                Init_int16 (Int.repr 322) :: Init_int16 (Int.repr 332) ::
                Init_int16 (Int.repr 334) :: Init_int16 (Int.repr 334) ::
                Init_int16 (Int.repr 339) :: Init_int16 (Int.repr 340) ::
                Init_int16 (Int.repr 334) :: Init_int16 (Int.repr 340) ::
                Init_int16 (Int.repr 341) :: Init_int16 (Int.repr 334) ::
                Init_int16 (Int.repr 338) :: Init_int16 (Int.repr 339) ::
                Init_int16 (Int.repr 334) :: Init_int16 (Int.repr 335) ::
                Init_int16 (Int.repr 336) :: Init_int16 (Int.repr 350) ::
                Init_int16 (Int.repr 356) :: Init_int16 (Int.repr 357) ::
                Init_int16 (Int.repr 365) :: Init_int16 (Int.repr 370) ::
                Init_int16 (Int.repr 320) :: Init_int16 (Int.repr 365) ::
                Init_int16 (Int.repr 320) :: Init_int16 (Int.repr 316) ::
                Init_int16 (Int.repr 365) :: Init_int16 (Int.repr 316) ::
                Init_int16 (Int.repr 319) :: Init_int16 (Int.repr 365) ::
                Init_int16 (Int.repr 369) :: Init_int16 (Int.repr 370) ::
                Init_int16 (Int.repr 357) :: Init_int16 (Int.repr 364) ::
                Init_int16 (Int.repr 365) :: Init_int16 (Int.repr 365) ::
                Init_int16 (Int.repr 367) :: Init_int16 (Int.repr 369) ::
                Init_int16 (Int.repr 357) :: Init_int16 (Int.repr 360) ::
                Init_int16 (Int.repr 361) :: Init_int16 (Int.repr 357) ::
                Init_int16 (Int.repr 361) :: Init_int16 (Int.repr 362) ::
                Init_int16 (Int.repr 357) :: Init_int16 (Int.repr 362) ::
                Init_int16 (Int.repr 364) :: Init_int16 (Int.repr 357) ::
                Init_int16 (Int.repr 359) :: Init_int16 (Int.repr 360) ::
                Init_int16 (Int.repr 350) :: Init_int16 (Int.repr 352) ::
                Init_int16 (Int.repr 353) :: Init_int16 (Int.repr 350) ::
                Init_int16 (Int.repr 353) :: Init_int16 (Int.repr 354) ::
                Init_int16 (Int.repr 350) :: Init_int16 (Int.repr 354) ::
                Init_int16 (Int.repr 355) :: Init_int16 (Int.repr 350) ::
                Init_int16 (Int.repr 355) :: Init_int16 (Int.repr 356) ::
                Init_int16 (Int.repr 350) :: Init_int16 (Int.repr 351) ::
                Init_int16 (Int.repr 352) :: Init_int16 (Int.repr 346) ::
                Init_int16 (Int.repr 349) :: Init_int16 (Int.repr 350) ::
                Init_int16 (Int.repr 346) :: Init_int16 (Int.repr 347) ::
                Init_int16 (Int.repr 348) :: Init_int16 (Int.repr 346) ::
                Init_int16 (Int.repr 348) :: Init_int16 (Int.repr 349) ::
                Init_int16 (Int.repr 371) :: Init_int16 (Int.repr 372) ::
                Init_int16 (Int.repr 486) :: Init_int16 (Int.repr 372) ::
                Init_int16 (Int.repr 475) :: Init_int16 (Int.repr 486) ::
                Init_int16 (Int.repr 377) :: Init_int16 (Int.repr 487) ::
                Init_int16 (Int.repr 376) :: Init_int16 (Int.repr 373) ::
                Init_int16 (Int.repr 372) :: Init_int16 (Int.repr 375) ::
                Init_int16 (Int.repr 372) :: Init_int16 (Int.repr 371) ::
                Init_int16 (Int.repr 375) :: Init_int16 (Int.repr 371) ::
                Init_int16 (Int.repr 486) :: Init_int16 (Int.repr 452) ::
                Init_int16 (Int.repr 371) :: Init_int16 (Int.repr 452) ::
                Init_int16 (Int.repr 450) :: Init_int16 (Int.repr 371) ::
                Init_int16 (Int.repr 450) :: Init_int16 (Int.repr 660) ::
                Init_int16 (Int.repr 375) :: Init_int16 (Int.repr 371) ::
                Init_int16 (Int.repr 660) :: Init_int16 (Int.repr 375) ::
                Init_int16 (Int.repr 660) :: Init_int16 (Int.repr 448) ::
                Init_int16 (Int.repr 375) :: Init_int16 (Int.repr 448) ::
                Init_int16 (Int.repr 478) :: Init_int16 (Int.repr 374) ::
                Init_int16 (Int.repr 372) :: Init_int16 (Int.repr 373) ::
                Init_int16 (Int.repr 376) :: Init_int16 (Int.repr 487) ::
                Init_int16 (Int.repr 661) :: Init_int16 (Int.repr 378) ::
                Init_int16 (Int.repr 376) :: Init_int16 (Int.repr 661) ::
                Init_int16 (Int.repr 379) :: Init_int16 (Int.repr 378) ::
                Init_int16 (Int.repr 661) :: Init_int16 (Int.repr 376) ::
                Init_int16 (Int.repr 378) :: Init_int16 (Int.repr 662) ::
                Init_int16 (Int.repr 380) :: Init_int16 (Int.repr 378) ::
                Init_int16 (Int.repr 379) :: Init_int16 (Int.repr 381) ::
                Init_int16 (Int.repr 378) :: Init_int16 (Int.repr 664) ::
                Init_int16 (Int.repr 381) :: Init_int16 (Int.repr 662) ::
                Init_int16 (Int.repr 378) :: Init_int16 (Int.repr 382) ::
                Init_int16 (Int.repr 378) :: Init_int16 (Int.repr 380) ::
                Init_int16 (Int.repr 378) :: Init_int16 (Int.repr 382) ::
                Init_int16 (Int.repr 664) :: Init_int16 (Int.repr 377) ::
                Init_int16 (Int.repr 662) :: Init_int16 (Int.repr 385) ::
                Init_int16 (Int.repr 377) :: Init_int16 (Int.repr 376) ::
                Init_int16 (Int.repr 662) :: Init_int16 (Int.repr 383) ::
                Init_int16 (Int.repr 662) :: Init_int16 (Int.repr 665) ::
                Init_int16 (Int.repr 383) :: Init_int16 (Int.repr 384) ::
                Init_int16 (Int.repr 662) :: Init_int16 (Int.repr 384) ::
                Init_int16 (Int.repr 385) :: Init_int16 (Int.repr 662) ::
                Init_int16 (Int.repr 381) :: Init_int16 (Int.repr 665) ::
                Init_int16 (Int.repr 662) :: Init_int16 (Int.repr 435) ::
                Init_int16 (Int.repr 666) :: Init_int16 (Int.repr 384) ::
                Init_int16 (Int.repr 377) :: Init_int16 (Int.repr 437) ::
                Init_int16 (Int.repr 487) :: Init_int16 (Int.repr 385) ::
                Init_int16 (Int.repr 437) :: Init_int16 (Int.repr 377) ::
                Init_int16 (Int.repr 385) :: Init_int16 (Int.repr 666) ::
                Init_int16 (Int.repr 437) :: Init_int16 (Int.repr 384) ::
                Init_int16 (Int.repr 666) :: Init_int16 (Int.repr 385) ::
                Init_int16 (Int.repr 386) :: Init_int16 (Int.repr 390) ::
                Init_int16 (Int.repr 388) :: Init_int16 (Int.repr 386) ::
                Init_int16 (Int.repr 388) :: Init_int16 (Int.repr 387) ::
                Init_int16 (Int.repr 368) :: Init_int16 (Int.repr 390) ::
                Init_int16 (Int.repr 386) :: Init_int16 (Int.repr 387) ::
                Init_int16 (Int.repr 388) :: Init_int16 (Int.repr 389) ::
                Init_int16 (Int.repr 388) :: Init_int16 (Int.repr 390) ::
                Init_int16 (Int.repr 435) :: Init_int16 (Int.repr 389) ::
                Init_int16 (Int.repr 388) :: Init_int16 (Int.repr 435) ::
                Init_int16 (Int.repr 323) :: Init_int16 (Int.repr 387) ::
                Init_int16 (Int.repr 389) :: Init_int16 (Int.repr 368) ::
                Init_int16 (Int.repr 667) :: Init_int16 (Int.repr 390) ::
                Init_int16 (Int.repr 390) :: Init_int16 (Int.repr 667) ::
                Init_int16 (Int.repr 435) :: Init_int16 (Int.repr 389) ::
                Init_int16 (Int.repr 391) :: Init_int16 (Int.repr 317) ::
                Init_int16 (Int.repr 323) :: Init_int16 (Int.repr 389) ::
                Init_int16 (Int.repr 317) :: Init_int16 (Int.repr 391) ::
                Init_int16 (Int.repr 389) :: Init_int16 (Int.repr 435) ::
                Init_int16 (Int.repr 392) :: Init_int16 (Int.repr 393) ::
                Init_int16 (Int.repr 394) :: Init_int16 (Int.repr 393) ::
                Init_int16 (Int.repr 392) :: Init_int16 (Int.repr 381) ::
                Init_int16 (Int.repr 394) :: Init_int16 (Int.repr 393) ::
                Init_int16 (Int.repr 447) :: Init_int16 (Int.repr 393) ::
                Init_int16 (Int.repr 426) :: Init_int16 (Int.repr 447) ::
                Init_int16 (Int.repr 395) :: Init_int16 (Int.repr 392) ::
                Init_int16 (Int.repr 394) :: Init_int16 (Int.repr 381) ::
                Init_int16 (Int.repr 392) :: Init_int16 (Int.repr 396) ::
                Init_int16 (Int.repr 392) :: Init_int16 (Int.repr 445) ::
                Init_int16 (Int.repr 396) :: Init_int16 (Int.repr 392) ::
                Init_int16 (Int.repr 395) :: Init_int16 (Int.repr 445) ::
                Init_int16 (Int.repr 393) :: Init_int16 (Int.repr 381) ::
                Init_int16 (Int.repr 664) :: Init_int16 (Int.repr 396) ::
                Init_int16 (Int.repr 665) :: Init_int16 (Int.repr 381) ::
                Init_int16 (Int.repr 397) :: Init_int16 (Int.repr 395) ::
                Init_int16 (Int.repr 394) :: Init_int16 (Int.repr 394) ::
                Init_int16 (Int.repr 447) :: Init_int16 (Int.repr 668) ::
                Init_int16 (Int.repr 398) :: Init_int16 (Int.repr 394) ::
                Init_int16 (Int.repr 668) :: Init_int16 (Int.repr 397) ::
                Init_int16 (Int.repr 394) :: Init_int16 (Int.repr 398) ::
                Init_int16 (Int.repr 406) :: Init_int16 (Int.repr 432) ::
                Init_int16 (Int.repr 402) :: Init_int16 (Int.repr 399) ::
                Init_int16 (Int.repr 395) :: Init_int16 (Int.repr 397) ::
                Init_int16 (Int.repr 395) :: Init_int16 (Int.repr 399) ::
                Init_int16 (Int.repr 446) :: Init_int16 (Int.repr 395) ::
                Init_int16 (Int.repr 446) :: Init_int16 (Int.repr 445) ::
                Init_int16 (Int.repr 399) :: Init_int16 (Int.repr 397) ::
                Init_int16 (Int.repr 400) :: Init_int16 (Int.repr 400) ::
                Init_int16 (Int.repr 397) :: Init_int16 (Int.repr 398) ::
                Init_int16 (Int.repr 401) :: Init_int16 (Int.repr 399) ::
                Init_int16 (Int.repr 400) :: Init_int16 (Int.repr 402) ::
                Init_int16 (Int.repr 399) :: Init_int16 (Int.repr 401) ::
                Init_int16 (Int.repr 399) :: Init_int16 (Int.repr 407) ::
                Init_int16 (Int.repr 446) :: Init_int16 (Int.repr 399) ::
                Init_int16 (Int.repr 402) :: Init_int16 (Int.repr 407) ::
                Init_int16 (Int.repr 400) :: Init_int16 (Int.repr 404) ::
                Init_int16 (Int.repr 401) :: Init_int16 (Int.repr 403) ::
                Init_int16 (Int.repr 400) :: Init_int16 (Int.repr 398) ::
                Init_int16 (Int.repr 404) :: Init_int16 (Int.repr 400) ::
                Init_int16 (Int.repr 403) :: Init_int16 (Int.repr 405) ::
                Init_int16 (Int.repr 402) :: Init_int16 (Int.repr 401) ::
                Init_int16 (Int.repr 406) :: Init_int16 (Int.repr 402) ::
                Init_int16 (Int.repr 405) :: Init_int16 (Int.repr 412) ::
                Init_int16 (Int.repr 413) :: Init_int16 (Int.repr 671) ::
                Init_int16 (Int.repr 409) :: Init_int16 (Int.repr 401) ::
                Init_int16 (Int.repr 411) :: Init_int16 (Int.repr 401) ::
                Init_int16 (Int.repr 404) :: Init_int16 (Int.repr 411) ::
                Init_int16 (Int.repr 409) :: Init_int16 (Int.repr 410) ::
                Init_int16 (Int.repr 401) :: Init_int16 (Int.repr 410) ::
                Init_int16 (Int.repr 405) :: Init_int16 (Int.repr 401) ::
                Init_int16 (Int.repr 411) :: Init_int16 (Int.repr 404) ::
                Init_int16 (Int.repr 443) :: Init_int16 (Int.repr 404) ::
                Init_int16 (Int.repr 403) :: Init_int16 (Int.repr 443) ::
                Init_int16 (Int.repr 410) :: Init_int16 (Int.repr 406) ::
                Init_int16 (Int.repr 405) :: Init_int16 (Int.repr 412) ::
                Init_int16 (Int.repr 671) :: Init_int16 (Int.repr 672) ::
                Init_int16 (Int.repr 413) :: Init_int16 (Int.repr 412) ::
                Init_int16 (Int.repr 486) :: Init_int16 (Int.repr 398) ::
                Init_int16 (Int.repr 412) :: Init_int16 (Int.repr 672) ::
                Init_int16 (Int.repr 411) :: Init_int16 (Int.repr 419) ::
                Init_int16 (Int.repr 463) :: Init_int16 (Int.repr 415) ::
                Init_int16 (Int.repr 672) :: Init_int16 (Int.repr 671) ::
                Init_int16 (Int.repr 416) :: Init_int16 (Int.repr 671) ::
                Init_int16 (Int.repr 413) :: Init_int16 (Int.repr 416) ::
                Init_int16 (Int.repr 415) :: Init_int16 (Int.repr 671) ::
                Init_int16 (Int.repr 415) :: Init_int16 (Int.repr 417) ::
                Init_int16 (Int.repr 672) :: Init_int16 (Int.repr 417) ::
                Init_int16 (Int.repr 398) :: Init_int16 (Int.repr 672) ::
                Init_int16 (Int.repr 415) :: Init_int16 (Int.repr 418) ::
                Init_int16 (Int.repr 443) :: Init_int16 (Int.repr 415) ::
                Init_int16 (Int.repr 443) :: Init_int16 (Int.repr 417) ::
                Init_int16 (Int.repr 418) :: Init_int16 (Int.repr 415) ::
                Init_int16 (Int.repr 416) :: Init_int16 (Int.repr 419) ::
                Init_int16 (Int.repr 411) :: Init_int16 (Int.repr 443) ::
                Init_int16 (Int.repr 409) :: Init_int16 (Int.repr 411) ::
                Init_int16 (Int.repr 463) :: Init_int16 (Int.repr 425) ::
                Init_int16 (Int.repr 426) :: Init_int16 (Int.repr 380) ::
                Init_int16 (Int.repr 420) :: Init_int16 (Int.repr 410) ::
                Init_int16 (Int.repr 409) :: Init_int16 (Int.repr 333) ::
                Init_int16 (Int.repr 420) :: Init_int16 (Int.repr 409) ::
                Init_int16 (Int.repr 410) :: Init_int16 (Int.repr 420) ::
                Init_int16 (Int.repr 406) :: Init_int16 (Int.repr 358) ::
                Init_int16 (Int.repr 421) :: Init_int16 (Int.repr 422) ::
                Init_int16 (Int.repr 421) :: Init_int16 (Int.repr 425) ::
                Init_int16 (Int.repr 422) :: Init_int16 (Int.repr 422) ::
                Init_int16 (Int.repr 425) :: Init_int16 (Int.repr 424) ::
                Init_int16 (Int.repr 423) :: Init_int16 (Int.repr 358) ::
                Init_int16 (Int.repr 422) :: Init_int16 (Int.repr 424) ::
                Init_int16 (Int.repr 423) :: Init_int16 (Int.repr 422) ::
                Init_int16 (Int.repr 421) :: Init_int16 (Int.repr 673) ::
                Init_int16 (Int.repr 425) :: Init_int16 (Int.repr 425) ::
                Init_int16 (Int.repr 673) :: Init_int16 (Int.repr 669) ::
                Init_int16 (Int.repr 426) :: Init_int16 (Int.repr 425) ::
                Init_int16 (Int.repr 669) :: Init_int16 (Int.repr 424) ::
                Init_int16 (Int.repr 425) :: Init_int16 (Int.repr 380) ::
                Init_int16 (Int.repr 423) :: Init_int16 (Int.repr 424) ::
                Init_int16 (Int.repr 453) :: Init_int16 (Int.repr 424) ::
                Init_int16 (Int.repr 379) :: Init_int16 (Int.repr 663) ::
                Init_int16 (Int.repr 424) :: Init_int16 (Int.repr 663) ::
                Init_int16 (Int.repr 453) :: Init_int16 (Int.repr 424) ::
                Init_int16 (Int.repr 380) :: Init_int16 (Int.repr 379) ::
                Init_int16 (Int.repr 421) :: Init_int16 (Int.repr 427) ::
                Init_int16 (Int.repr 673) :: Init_int16 (Int.repr 427) ::
                Init_int16 (Int.repr 421) :: Init_int16 (Int.repr 358) ::
                Init_int16 (Int.repr 358) :: Init_int16 (Int.repr 423) ::
                Init_int16 (Int.repr 454) :: Init_int16 (Int.repr 428) ::
                Init_int16 (Int.repr 427) :: Init_int16 (Int.repr 358) ::
                Init_int16 (Int.repr 423) :: Init_int16 (Int.repr 453) ::
                Init_int16 (Int.repr 455) :: Init_int16 (Int.repr 423) ::
                Init_int16 (Int.repr 455) :: Init_int16 (Int.repr 454) ::
                Init_int16 (Int.repr 435) :: Init_int16 (Int.repr 384) ::
                Init_int16 (Int.repr 434) :: Init_int16 (Int.repr 318) ::
                Init_int16 (Int.repr 429) :: Init_int16 (Int.repr 321) ::
                Init_int16 (Int.repr 429) :: Init_int16 (Int.repr 430) ::
                Init_int16 (Int.repr 321) :: Init_int16 (Int.repr 321) ::
                Init_int16 (Int.repr 431) :: Init_int16 (Int.repr 670) ::
                Init_int16 (Int.repr 321) :: Init_int16 (Int.repr 430) ::
                Init_int16 (Int.repr 431) :: Init_int16 (Int.repr 321) ::
                Init_int16 (Int.repr 670) :: Init_int16 (Int.repr 433) ::
                Init_int16 (Int.repr 321) :: Init_int16 (Int.repr 433) ::
                Init_int16 (Int.repr 324) :: Init_int16 (Int.repr 430) ::
                Init_int16 (Int.repr 435) :: Init_int16 (Int.repr 434) ::
                Init_int16 (Int.repr 431) :: Init_int16 (Int.repr 430) ::
                Init_int16 (Int.repr 434) :: Init_int16 (Int.repr 430) ::
                Init_int16 (Int.repr 429) :: Init_int16 (Int.repr 435) ::
                Init_int16 (Int.repr 432) :: Init_int16 (Int.repr 431) ::
                Init_int16 (Int.repr 434) :: Init_int16 (Int.repr 432) ::
                Init_int16 (Int.repr 670) :: Init_int16 (Int.repr 431) ::
                Init_int16 (Int.repr 433) :: Init_int16 (Int.repr 670) ::
                Init_int16 (Int.repr 406) :: Init_int16 (Int.repr 406) ::
                Init_int16 (Int.repr 670) :: Init_int16 (Int.repr 432) ::
                Init_int16 (Int.repr 434) :: Init_int16 (Int.repr 383) ::
                Init_int16 (Int.repr 436) :: Init_int16 (Int.repr 434) ::
                Init_int16 (Int.repr 384) :: Init_int16 (Int.repr 383) ::
                Init_int16 (Int.repr 434) :: Init_int16 (Int.repr 436) ::
                Init_int16 (Int.repr 432) :: Init_int16 (Int.repr 435) ::
                Init_int16 (Int.repr 667) :: Init_int16 (Int.repr 438) ::
                Init_int16 (Int.repr 436) :: Init_int16 (Int.repr 408) ::
                Init_int16 (Int.repr 432) :: Init_int16 (Int.repr 408) ::
                Init_int16 (Int.repr 402) :: Init_int16 (Int.repr 432) ::
                Init_int16 (Int.repr 437) :: Init_int16 (Int.repr 666) ::
                Init_int16 (Int.repr 438) :: Init_int16 (Int.repr 435) ::
                Init_int16 (Int.repr 438) :: Init_int16 (Int.repr 666) ::
                Init_int16 (Int.repr 437) :: Init_int16 (Int.repr 453) ::
                Init_int16 (Int.repr 487) :: Init_int16 (Int.repr 437) ::
                Init_int16 (Int.repr 440) :: Init_int16 (Int.repr 453) ::
                Init_int16 (Int.repr 438) :: Init_int16 (Int.repr 366) ::
                Init_int16 (Int.repr 437) :: Init_int16 (Int.repr 366) ::
                Init_int16 (Int.repr 440) :: Init_int16 (Int.repr 437) ::
                Init_int16 (Int.repr 366) :: Init_int16 (Int.repr 438) ::
                Init_int16 (Int.repr 368) :: Init_int16 (Int.repr 438) ::
                Init_int16 (Int.repr 667) :: Init_int16 (Int.repr 368) ::
                Init_int16 (Int.repr 363) :: Init_int16 (Int.repr 439) ::
                Init_int16 (Int.repr 366) :: Init_int16 (Int.repr 439) ::
                Init_int16 (Int.repr 440) :: Init_int16 (Int.repr 366) ::
                Init_int16 (Int.repr 440) :: Init_int16 (Int.repr 439) ::
                Init_int16 (Int.repr 453) :: Init_int16 (Int.repr 416) ::
                Init_int16 (Int.repr 413) :: Init_int16 (Int.repr 471) ::
                Init_int16 (Int.repr 441) :: Init_int16 (Int.repr 418) ::
                Init_int16 (Int.repr 416) :: Init_int16 (Int.repr 442) ::
                Init_int16 (Int.repr 413) :: Init_int16 (Int.repr 486) ::
                Init_int16 (Int.repr 413) :: Init_int16 (Int.repr 442) ::
                Init_int16 (Int.repr 471) :: Init_int16 (Int.repr 403) ::
                Init_int16 (Int.repr 398) :: Init_int16 (Int.repr 417) ::
                Init_int16 (Int.repr 443) :: Init_int16 (Int.repr 403) ::
                Init_int16 (Int.repr 417) :: Init_int16 (Int.repr 444) ::
                Init_int16 (Int.repr 383) :: Init_int16 (Int.repr 665) ::
                Init_int16 (Int.repr 444) :: Init_int16 (Int.repr 436) ::
                Init_int16 (Int.repr 383) :: Init_int16 (Int.repr 444) ::
                Init_int16 (Int.repr 408) :: Init_int16 (Int.repr 436) ::
                Init_int16 (Int.repr 445) :: Init_int16 (Int.repr 444) ::
                Init_int16 (Int.repr 396) :: Init_int16 (Int.repr 444) ::
                Init_int16 (Int.repr 665) :: Init_int16 (Int.repr 396) ::
                Init_int16 (Int.repr 446) :: Init_int16 (Int.repr 444) ::
                Init_int16 (Int.repr 445) :: Init_int16 (Int.repr 407) ::
                Init_int16 (Int.repr 444) :: Init_int16 (Int.repr 446) ::
                Init_int16 (Int.repr 444) :: Init_int16 (Int.repr 407) ::
                Init_int16 (Int.repr 408) :: Init_int16 (Int.repr 407) ::
                Init_int16 (Int.repr 402) :: Init_int16 (Int.repr 408) ::
                Init_int16 (Int.repr 449) :: Init_int16 (Int.repr 450) ::
                Init_int16 (Int.repr 447) :: Init_int16 (Int.repr 382) ::
                Init_int16 (Int.repr 393) :: Init_int16 (Int.repr 664) ::
                Init_int16 (Int.repr 426) :: Init_int16 (Int.repr 382) ::
                Init_int16 (Int.repr 380) :: Init_int16 (Int.repr 382) ::
                Init_int16 (Int.repr 426) :: Init_int16 (Int.repr 393) ::
                Init_int16 (Int.repr 447) :: Init_int16 (Int.repr 426) ::
                Init_int16 (Int.repr 669) :: Init_int16 (Int.repr 379) ::
                Init_int16 (Int.repr 661) :: Init_int16 (Int.repr 663) ::
                Init_int16 (Int.repr 448) :: Init_int16 (Int.repr 449) ::
                Init_int16 (Int.repr 673) :: Init_int16 (Int.repr 449) ::
                Init_int16 (Int.repr 669) :: Init_int16 (Int.repr 673) ::
                Init_int16 (Int.repr 449) :: Init_int16 (Int.repr 447) ::
                Init_int16 (Int.repr 669) :: Init_int16 (Int.repr 450) ::
                Init_int16 (Int.repr 449) :: Init_int16 (Int.repr 660) ::
                Init_int16 (Int.repr 449) :: Init_int16 (Int.repr 448) ::
                Init_int16 (Int.repr 660) :: Init_int16 (Int.repr 455) ::
                Init_int16 (Int.repr 674) :: Init_int16 (Int.repr 456) ::
                Init_int16 (Int.repr 414) :: Init_int16 (Int.repr 398) ::
                Init_int16 (Int.repr 668) :: Init_int16 (Int.repr 451) ::
                Init_int16 (Int.repr 448) :: Init_int16 (Int.repr 673) ::
                Init_int16 (Int.repr 448) :: Init_int16 (Int.repr 451) ::
                Init_int16 (Int.repr 478) :: Init_int16 (Int.repr 452) ::
                Init_int16 (Int.repr 447) :: Init_int16 (Int.repr 450) ::
                Init_int16 (Int.repr 414) :: Init_int16 (Int.repr 447) ::
                Init_int16 (Int.repr 452) :: Init_int16 (Int.repr 414) ::
                Init_int16 (Int.repr 668) :: Init_int16 (Int.repr 447) ::
                Init_int16 (Int.repr 453) :: Init_int16 (Int.repr 674) ::
                Init_int16 (Int.repr 455) :: Init_int16 (Int.repr 454) ::
                Init_int16 (Int.repr 455) :: Init_int16 (Int.repr 456) ::
                Init_int16 (Int.repr 453) :: Init_int16 (Int.repr 675) ::
                Init_int16 (Int.repr 674) :: Init_int16 (Int.repr 456) ::
                Init_int16 (Int.repr 674) :: Init_int16 (Int.repr 675) ::
                Init_int16 (Int.repr 456) :: Init_int16 (Int.repr 675) ::
                Init_int16 (Int.repr 457) :: Init_int16 (Int.repr 453) ::
                Init_int16 (Int.repr 676) :: Init_int16 (Int.repr 675) ::
                Init_int16 (Int.repr 457) :: Init_int16 (Int.repr 675) ::
                Init_int16 (Int.repr 676) :: Init_int16 (Int.repr 457) ::
                Init_int16 (Int.repr 676) :: Init_int16 (Int.repr 458) ::
                Init_int16 (Int.repr 453) :: Init_int16 (Int.repr 439) ::
                Init_int16 (Int.repr 676) :: Init_int16 (Int.repr 458) ::
                Init_int16 (Int.repr 676) :: Init_int16 (Int.repr 439) ::
                Init_int16 (Int.repr 458) :: Init_int16 (Int.repr 439) ::
                Init_int16 (Int.repr 363) :: Init_int16 (Int.repr 317) ::
                Init_int16 (Int.repr 391) :: Init_int16 (Int.repr 318) ::
                Init_int16 (Int.repr 391) :: Init_int16 (Int.repr 429) ::
                Init_int16 (Int.repr 318) :: Init_int16 (Int.repr 429) ::
                Init_int16 (Int.repr 391) :: Init_int16 (Int.repr 435) ::
                Init_int16 (Int.repr 459) :: Init_int16 (Int.repr 433) ::
                Init_int16 (Int.repr 406) :: Init_int16 (Int.repr 324) ::
                Init_int16 (Int.repr 433) :: Init_int16 (Int.repr 326) ::
                Init_int16 (Int.repr 433) :: Init_int16 (Int.repr 459) ::
                Init_int16 (Int.repr 326) :: Init_int16 (Int.repr 460) ::
                Init_int16 (Int.repr 459) :: Init_int16 (Int.repr 406) ::
                Init_int16 (Int.repr 326) :: Init_int16 (Int.repr 459) ::
                Init_int16 (Int.repr 460) :: Init_int16 (Int.repr 326) ::
                Init_int16 (Int.repr 460) :: Init_int16 (Int.repr 328) ::
                Init_int16 (Int.repr 461) :: Init_int16 (Int.repr 460) ::
                Init_int16 (Int.repr 406) :: Init_int16 (Int.repr 460) ::
                Init_int16 (Int.repr 461) :: Init_int16 (Int.repr 330) ::
                Init_int16 (Int.repr 328) :: Init_int16 (Int.repr 460) ::
                Init_int16 (Int.repr 330) :: Init_int16 (Int.repr 420) ::
                Init_int16 (Int.repr 461) :: Init_int16 (Int.repr 406) ::
                Init_int16 (Int.repr 330) :: Init_int16 (Int.repr 461) ::
                Init_int16 (Int.repr 420) :: Init_int16 (Int.repr 330) ::
                Init_int16 (Int.repr 420) :: Init_int16 (Int.repr 333) ::
                Init_int16 (Int.repr 462) :: Init_int16 (Int.repr 419) ::
                Init_int16 (Int.repr 443) :: Init_int16 (Int.repr 463) ::
                Init_int16 (Int.repr 419) :: Init_int16 (Int.repr 462) ::
                Init_int16 (Int.repr 463) :: Init_int16 (Int.repr 462) ::
                Init_int16 (Int.repr 465) :: Init_int16 (Int.repr 464) ::
                Init_int16 (Int.repr 462) :: Init_int16 (Int.repr 443) ::
                Init_int16 (Int.repr 465) :: Init_int16 (Int.repr 462) ::
                Init_int16 (Int.repr 337) :: Init_int16 (Int.repr 462) ::
                Init_int16 (Int.repr 464) :: Init_int16 (Int.repr 337) ::
                Init_int16 (Int.repr 466) :: Init_int16 (Int.repr 464) ::
                Init_int16 (Int.repr 443) :: Init_int16 (Int.repr 337) ::
                Init_int16 (Int.repr 464) :: Init_int16 (Int.repr 466) ::
                Init_int16 (Int.repr 337) :: Init_int16 (Int.repr 466) ::
                Init_int16 (Int.repr 468) :: Init_int16 (Int.repr 467) ::
                Init_int16 (Int.repr 466) :: Init_int16 (Int.repr 443) ::
                Init_int16 (Int.repr 466) :: Init_int16 (Int.repr 467) ::
                Init_int16 (Int.repr 469) :: Init_int16 (Int.repr 468) ::
                Init_int16 (Int.repr 466) :: Init_int16 (Int.repr 469) ::
                Init_int16 (Int.repr 418) :: Init_int16 (Int.repr 467) ::
                Init_int16 (Int.repr 443) :: Init_int16 (Int.repr 469) ::
                Init_int16 (Int.repr 467) :: Init_int16 (Int.repr 418) ::
                Init_int16 (Int.repr 469) :: Init_int16 (Int.repr 418) ::
                Init_int16 (Int.repr 441) :: Init_int16 (Int.repr 470) ::
                Init_int16 (Int.repr 442) :: Init_int16 (Int.repr 486) ::
                Init_int16 (Int.repr 477) :: Init_int16 (Int.repr 451) ::
                Init_int16 (Int.repr 673) :: Init_int16 (Int.repr 471) ::
                Init_int16 (Int.repr 442) :: Init_int16 (Int.repr 470) ::
                Init_int16 (Int.repr 471) :: Init_int16 (Int.repr 470) ::
                Init_int16 (Int.repr 345) :: Init_int16 (Int.repr 472) ::
                Init_int16 (Int.repr 470) :: Init_int16 (Int.repr 486) ::
                Init_int16 (Int.repr 470) :: Init_int16 (Int.repr 472) ::
                Init_int16 (Int.repr 474) :: Init_int16 (Int.repr 345) ::
                Init_int16 (Int.repr 470) :: Init_int16 (Int.repr 474) ::
                Init_int16 (Int.repr 473) :: Init_int16 (Int.repr 472) ::
                Init_int16 (Int.repr 486) :: Init_int16 (Int.repr 474) ::
                Init_int16 (Int.repr 472) :: Init_int16 (Int.repr 473) ::
                Init_int16 (Int.repr 474) :: Init_int16 (Int.repr 473) ::
                Init_int16 (Int.repr 476) :: Init_int16 (Int.repr 475) ::
                Init_int16 (Int.repr 473) :: Init_int16 (Int.repr 486) ::
                Init_int16 (Int.repr 476) :: Init_int16 (Int.repr 473) ::
                Init_int16 (Int.repr 374) :: Init_int16 (Int.repr 473) ::
                Init_int16 (Int.repr 475) :: Init_int16 (Int.repr 374) ::
                Init_int16 (Int.repr 374) :: Init_int16 (Int.repr 475) ::
                Init_int16 (Int.repr 372) :: Init_int16 (Int.repr 478) ::
                Init_int16 (Int.repr 477) :: Init_int16 (Int.repr 480) ::
                Init_int16 (Int.repr 478) :: Init_int16 (Int.repr 451) ::
                Init_int16 (Int.repr 477) :: Init_int16 (Int.repr 479) ::
                Init_int16 (Int.repr 477) :: Init_int16 (Int.repr 673) ::
                Init_int16 (Int.repr 480) :: Init_int16 (Int.repr 477) ::
                Init_int16 (Int.repr 479) :: Init_int16 (Int.repr 480) ::
                Init_int16 (Int.repr 479) :: Init_int16 (Int.repr 482) ::
                Init_int16 (Int.repr 481) :: Init_int16 (Int.repr 479) ::
                Init_int16 (Int.repr 673) :: Init_int16 (Int.repr 482) ::
                Init_int16 (Int.repr 479) :: Init_int16 (Int.repr 484) ::
                Init_int16 (Int.repr 479) :: Init_int16 (Int.repr 481) ::
                Init_int16 (Int.repr 484) :: Init_int16 (Int.repr 483) ::
                Init_int16 (Int.repr 481) :: Init_int16 (Int.repr 673) ::
                Init_int16 (Int.repr 484) :: Init_int16 (Int.repr 481) ::
                Init_int16 (Int.repr 485) :: Init_int16 (Int.repr 481) ::
                Init_int16 (Int.repr 483) :: Init_int16 (Int.repr 485) ::
                Init_int16 (Int.repr 427) :: Init_int16 (Int.repr 483) ::
                Init_int16 (Int.repr 673) :: Init_int16 (Int.repr 485) ::
                Init_int16 (Int.repr 483) :: Init_int16 (Int.repr 427) ::
                Init_int16 (Int.repr 485) :: Init_int16 (Int.repr 427) ::
                Init_int16 (Int.repr 428) :: Init_int16 (Int.repr 398) ::
                Init_int16 (Int.repr 414) :: Init_int16 (Int.repr 412) ::
                Init_int16 (Int.repr 414) :: Init_int16 (Int.repr 486) ::
                Init_int16 (Int.repr 412) :: Init_int16 (Int.repr 486) ::
                Init_int16 (Int.repr 414) :: Init_int16 (Int.repr 452) ::
                Init_int16 (Int.repr 487) :: Init_int16 (Int.repr 453) ::
                Init_int16 (Int.repr 663) :: Init_int16 (Int.repr 487) ::
                Init_int16 (Int.repr 663) :: Init_int16 (Int.repr 661) ::
                Init_int16 (Int.repr 488) :: Init_int16 (Int.repr 627) ::
                Init_int16 (Int.repr 489) :: Init_int16 (Int.repr 489) ::
                Init_int16 (Int.repr 597) :: Init_int16 (Int.repr 490) ::
                Init_int16 (Int.repr 489) :: Init_int16 (Int.repr 627) ::
                Init_int16 (Int.repr 597) :: Init_int16 (Int.repr 493) ::
                Init_int16 (Int.repr 494) :: Init_int16 (Int.repr 495) ::
                Init_int16 (Int.repr 490) :: Init_int16 (Int.repr 597) ::
                Init_int16 (Int.repr 595) :: Init_int16 (Int.repr 490) ::
                Init_int16 (Int.repr 595) :: Init_int16 (Int.repr 491) ::
                Init_int16 (Int.repr 488) :: Init_int16 (Int.repr 555) ::
                Init_int16 (Int.repr 627) :: Init_int16 (Int.repr 491) ::
                Init_int16 (Int.repr 595) :: Init_int16 (Int.repr 629) ::
                Init_int16 (Int.repr 491) :: Init_int16 (Int.repr 629) ::
                Init_int16 (Int.repr 492) :: Init_int16 (Int.repr 492) ::
                Init_int16 (Int.repr 629) :: Init_int16 (Int.repr 631) ::
                Init_int16 (Int.repr 492) :: Init_int16 (Int.repr 631) ::
                Init_int16 (Int.repr 493) :: Init_int16 (Int.repr 493) ::
                Init_int16 (Int.repr 631) :: Init_int16 (Int.repr 494) ::
                Init_int16 (Int.repr 501) :: Init_int16 (Int.repr 637) ::
                Init_int16 (Int.repr 502) :: Init_int16 (Int.repr 494) ::
                Init_int16 (Int.repr 633) :: Init_int16 (Int.repr 496) ::
                Init_int16 (Int.repr 495) :: Init_int16 (Int.repr 494) ::
                Init_int16 (Int.repr 496) :: Init_int16 (Int.repr 496) ::
                Init_int16 (Int.repr 498) :: Init_int16 (Int.repr 497) ::
                Init_int16 (Int.repr 496) :: Init_int16 (Int.repr 633) ::
                Init_int16 (Int.repr 498) :: Init_int16 (Int.repr 497) ::
                Init_int16 (Int.repr 498) :: Init_int16 (Int.repr 499) ::
                Init_int16 (Int.repr 498) :: Init_int16 (Int.repr 575) ::
                Init_int16 (Int.repr 499) :: Init_int16 (Int.repr 499) ::
                Init_int16 (Int.repr 635) :: Init_int16 (Int.repr 500) ::
                Init_int16 (Int.repr 499) :: Init_int16 (Int.repr 575) ::
                Init_int16 (Int.repr 635) :: Init_int16 (Int.repr 500) ::
                Init_int16 (Int.repr 635) :: Init_int16 (Int.repr 637) ::
                Init_int16 (Int.repr 500) :: Init_int16 (Int.repr 637) ::
                Init_int16 (Int.repr 501) :: Init_int16 (Int.repr 507) ::
                Init_int16 (Int.repr 643) :: Init_int16 (Int.repr 508) ::
                Init_int16 (Int.repr 501) :: Init_int16 (Int.repr 502) ::
                Init_int16 (Int.repr 503) :: Init_int16 (Int.repr 502) ::
                Init_int16 (Int.repr 640) :: Init_int16 (Int.repr 504) ::
                Init_int16 (Int.repr 503) :: Init_int16 (Int.repr 502) ::
                Init_int16 (Int.repr 504) :: Init_int16 (Int.repr 504) ::
                Init_int16 (Int.repr 641) :: Init_int16 (Int.repr 505) ::
                Init_int16 (Int.repr 504) :: Init_int16 (Int.repr 640) ::
                Init_int16 (Int.repr 641) :: Init_int16 (Int.repr 505) ::
                Init_int16 (Int.repr 641) :: Init_int16 (Int.repr 609) ::
                Init_int16 (Int.repr 505) :: Init_int16 (Int.repr 609) ::
                Init_int16 (Int.repr 506) :: Init_int16 (Int.repr 506) ::
                Init_int16 (Int.repr 609) :: Init_int16 (Int.repr 582) ::
                Init_int16 (Int.repr 506) :: Init_int16 (Int.repr 582) ::
                Init_int16 (Int.repr 507) :: Init_int16 (Int.repr 507) ::
                Init_int16 (Int.repr 582) :: Init_int16 (Int.repr 643) ::
                Init_int16 (Int.repr 514) :: Init_int16 (Int.repr 537) ::
                Init_int16 (Int.repr 540) :: Init_int16 (Int.repr 508) ::
                Init_int16 (Int.repr 643) :: Init_int16 (Int.repr 510) ::
                Init_int16 (Int.repr 508) :: Init_int16 (Int.repr 510) ::
                Init_int16 (Int.repr 509) :: Init_int16 (Int.repr 509) ::
                Init_int16 (Int.repr 510) :: Init_int16 (Int.repr 511) ::
                Init_int16 (Int.repr 510) :: Init_int16 (Int.repr 646) ::
                Init_int16 (Int.repr 511) :: Init_int16 (Int.repr 511) ::
                Init_int16 (Int.repr 648) :: Init_int16 (Int.repr 512) ::
                Init_int16 (Int.repr 511) :: Init_int16 (Int.repr 646) ::
                Init_int16 (Int.repr 648) :: Init_int16 (Int.repr 512) ::
                Init_int16 (Int.repr 648) :: Init_int16 (Int.repr 539) ::
                Init_int16 (Int.repr 512) :: Init_int16 (Int.repr 539) ::
                Init_int16 (Int.repr 513) :: Init_int16 (Int.repr 513) ::
                Init_int16 (Int.repr 539) :: Init_int16 (Int.repr 537) ::
                Init_int16 (Int.repr 513) :: Init_int16 (Int.repr 537) ::
                Init_int16 (Int.repr 514) :: Init_int16 (Int.repr 519) ::
                Init_int16 (Int.repr 657) :: Init_int16 (Int.repr 520) ::
                Init_int16 (Int.repr 514) :: Init_int16 (Int.repr 540) ::
                Init_int16 (Int.repr 515) :: Init_int16 (Int.repr 515) ::
                Init_int16 (Int.repr 540) :: Init_int16 (Int.repr 650) ::
                Init_int16 (Int.repr 515) :: Init_int16 (Int.repr 650) ::
                Init_int16 (Int.repr 516) :: Init_int16 (Int.repr 516) ::
                Init_int16 (Int.repr 650) :: Init_int16 (Int.repr 652) ::
                Init_int16 (Int.repr 516) :: Init_int16 (Int.repr 652) ::
                Init_int16 (Int.repr 517) :: Init_int16 (Int.repr 517) ::
                Init_int16 (Int.repr 652) :: Init_int16 (Int.repr 654) ::
                Init_int16 (Int.repr 517) :: Init_int16 (Int.repr 654) ::
                Init_int16 (Int.repr 518) :: Init_int16 (Int.repr 518) ::
                Init_int16 (Int.repr 654) :: Init_int16 (Int.repr 656) ::
                Init_int16 (Int.repr 518) :: Init_int16 (Int.repr 656) ::
                Init_int16 (Int.repr 519) :: Init_int16 (Int.repr 519) ::
                Init_int16 (Int.repr 656) :: Init_int16 (Int.repr 657) ::
                Init_int16 (Int.repr 526) :: Init_int16 (Int.repr 625) ::
                Init_int16 (Int.repr 626) :: Init_int16 (Int.repr 520) ::
                Init_int16 (Int.repr 657) :: Init_int16 (Int.repr 594) ::
                Init_int16 (Int.repr 520) :: Init_int16 (Int.repr 594) ::
                Init_int16 (Int.repr 521) :: Init_int16 (Int.repr 521) ::
                Init_int16 (Int.repr 594) :: Init_int16 (Int.repr 523) ::
                Init_int16 (Int.repr 521) :: Init_int16 (Int.repr 523) ::
                Init_int16 (Int.repr 522) :: Init_int16 (Int.repr 522) ::
                Init_int16 (Int.repr 523) :: Init_int16 (Int.repr 524) ::
                Init_int16 (Int.repr 523) :: Init_int16 (Int.repr 623) ::
                Init_int16 (Int.repr 524) :: Init_int16 (Int.repr 524) ::
                Init_int16 (Int.repr 624) :: Init_int16 (Int.repr 525) ::
                Init_int16 (Int.repr 524) :: Init_int16 (Int.repr 623) ::
                Init_int16 (Int.repr 624) :: Init_int16 (Int.repr 525) ::
                Init_int16 (Int.repr 624) :: Init_int16 (Int.repr 625) ::
                Init_int16 (Int.repr 525) :: Init_int16 (Int.repr 625) ::
                Init_int16 (Int.repr 526) :: Init_int16 (Int.repr 534) ::
                Init_int16 (Int.repr 551) :: Init_int16 (Int.repr 552) ::
                Init_int16 (Int.repr 526) :: Init_int16 (Int.repr 626) ::
                Init_int16 (Int.repr 527) :: Init_int16 (Int.repr 527) ::
                Init_int16 (Int.repr 626) :: Init_int16 (Int.repr 529) ::
                Init_int16 (Int.repr 527) :: Init_int16 (Int.repr 529) ::
                Init_int16 (Int.repr 528) :: Init_int16 (Int.repr 528) ::
                Init_int16 (Int.repr 529) :: Init_int16 (Int.repr 530) ::
                Init_int16 (Int.repr 529) :: Init_int16 (Int.repr 531) ::
                Init_int16 (Int.repr 530) :: Init_int16 (Int.repr 530) ::
                Init_int16 (Int.repr 531) :: Init_int16 (Int.repr 532) ::
                Init_int16 (Int.repr 531) :: Init_int16 (Int.repr 533) ::
                Init_int16 (Int.repr 532) :: Init_int16 (Int.repr 532) ::
                Init_int16 (Int.repr 533) :: Init_int16 (Int.repr 534) ::
                Init_int16 (Int.repr 533) :: Init_int16 (Int.repr 551) ::
                Init_int16 (Int.repr 534) :: Init_int16 (Int.repr 534) ::
                Init_int16 (Int.repr 552) :: Init_int16 (Int.repr 535) ::
                Init_int16 (Int.repr 535) :: Init_int16 (Int.repr 552) ::
                Init_int16 (Int.repr 555) :: Init_int16 (Int.repr 535) ::
                Init_int16 (Int.repr 555) :: Init_int16 (Int.repr 488) ::
                Init_int16 (Int.repr 536) :: Init_int16 (Int.repr 538) ::
                Init_int16 (Int.repr 540) :: Init_int16 (Int.repr 537) ::
                Init_int16 (Int.repr 536) :: Init_int16 (Int.repr 540) ::
                Init_int16 (Int.repr 536) :: Init_int16 (Int.repr 647) ::
                Init_int16 (Int.repr 658) :: Init_int16 (Int.repr 538) ::
                Init_int16 (Int.repr 536) :: Init_int16 (Int.repr 658) ::
                Init_int16 (Int.repr 539) :: Init_int16 (Int.repr 647) ::
                Init_int16 (Int.repr 536) :: Init_int16 (Int.repr 539) ::
                Init_int16 (Int.repr 536) :: Init_int16 (Int.repr 537) ::
                Init_int16 (Int.repr 538) :: Init_int16 (Int.repr 620) ::
                Init_int16 (Int.repr 618) :: Init_int16 (Int.repr 538) ::
                Init_int16 (Int.repr 658) :: Init_int16 (Int.repr 620) ::
                Init_int16 (Int.repr 538) :: Init_int16 (Int.repr 618) ::
                Init_int16 (Int.repr 677) :: Init_int16 (Int.repr 540) ::
                Init_int16 (Int.repr 538) :: Init_int16 (Int.repr 677) ::
                Init_int16 (Int.repr 547) :: Init_int16 (Int.repr 543) ::
                Init_int16 (Int.repr 546) :: Init_int16 (Int.repr 540) ::
                Init_int16 (Int.repr 677) :: Init_int16 (Int.repr 617) ::
                Init_int16 (Int.repr 540) :: Init_int16 (Int.repr 617) ::
                Init_int16 (Int.repr 650) :: Init_int16 (Int.repr 541) ::
                Init_int16 (Int.repr 543) :: Init_int16 (Int.repr 678) ::
                Init_int16 (Int.repr 542) :: Init_int16 (Int.repr 541) ::
                Init_int16 (Int.repr 678) :: Init_int16 (Int.repr 541) ::
                Init_int16 (Int.repr 659) :: Init_int16 (Int.repr 679) ::
                Init_int16 (Int.repr 543) :: Init_int16 (Int.repr 541) ::
                Init_int16 (Int.repr 679) :: Init_int16 (Int.repr 542) ::
                Init_int16 (Int.repr 659) :: Init_int16 (Int.repr 541) ::
                Init_int16 (Int.repr 543) :: Init_int16 (Int.repr 545) ::
                Init_int16 (Int.repr 680) :: Init_int16 (Int.repr 544) ::
                Init_int16 (Int.repr 678) :: Init_int16 (Int.repr 543) ::
                Init_int16 (Int.repr 544) :: Init_int16 (Int.repr 543) ::
                Init_int16 (Int.repr 680) :: Init_int16 (Int.repr 545) ::
                Init_int16 (Int.repr 543) :: Init_int16 (Int.repr 547) ::
                Init_int16 (Int.repr 546) :: Init_int16 (Int.repr 543) ::
                Init_int16 (Int.repr 679) :: Init_int16 (Int.repr 548) ::
                Init_int16 (Int.repr 550) :: Init_int16 (Int.repr 678) ::
                Init_int16 (Int.repr 542) :: Init_int16 (Int.repr 678) ::
                Init_int16 (Int.repr 550) :: Init_int16 (Int.repr 549) ::
                Init_int16 (Int.repr 548) :: Init_int16 (Int.repr 678) ::
                Init_int16 (Int.repr 549) :: Init_int16 (Int.repr 678) ::
                Init_int16 (Int.repr 681) :: Init_int16 (Int.repr 544) ::
                Init_int16 (Int.repr 681) :: Init_int16 (Int.repr 678) ::
                Init_int16 (Int.repr 550) :: Init_int16 (Int.repr 605) ::
                Init_int16 (Int.repr 542) :: Init_int16 (Int.repr 542) ::
                Init_int16 (Int.repr 605) :: Init_int16 (Int.repr 659) ::
                Init_int16 (Int.repr 548) :: Init_int16 (Int.repr 683) ::
                Init_int16 (Int.repr 550) :: Init_int16 (Int.repr 550) ::
                Init_int16 (Int.repr 683) :: Init_int16 (Int.repr 605) ::
                Init_int16 (Int.repr 551) :: Init_int16 (Int.repr 553) ::
                Init_int16 (Int.repr 552) :: Init_int16 (Int.repr 551) ::
                Init_int16 (Int.repr 556) :: Init_int16 (Int.repr 553) ::
                Init_int16 (Int.repr 533) :: Init_int16 (Int.repr 556) ::
                Init_int16 (Int.repr 551) :: Init_int16 (Int.repr 559) ::
                Init_int16 (Int.repr 558) :: Init_int16 (Int.repr 544) ::
                Init_int16 (Int.repr 552) :: Init_int16 (Int.repr 553) ::
                Init_int16 (Int.repr 554) :: Init_int16 (Int.repr 553) ::
                Init_int16 (Int.repr 556) :: Init_int16 (Int.repr 603) ::
                Init_int16 (Int.repr 554) :: Init_int16 (Int.repr 553) ::
                Init_int16 (Int.repr 603) :: Init_int16 (Int.repr 555) ::
                Init_int16 (Int.repr 552) :: Init_int16 (Int.repr 554) ::
                Init_int16 (Int.repr 556) :: Init_int16 (Int.repr 684) ::
                Init_int16 (Int.repr 603) :: Init_int16 (Int.repr 533) ::
                Init_int16 (Int.repr 684) :: Init_int16 (Int.repr 556) ::
                Init_int16 (Int.repr 557) :: Init_int16 (Int.repr 554) ::
                Init_int16 (Int.repr 603) :: Init_int16 (Int.repr 554) ::
                Init_int16 (Int.repr 557) :: Init_int16 (Int.repr 627) ::
                Init_int16 (Int.repr 555) :: Init_int16 (Int.repr 554) ::
                Init_int16 (Int.repr 627) :: Init_int16 (Int.repr 558) ::
                Init_int16 (Int.repr 559) :: Init_int16 (Int.repr 560) ::
                Init_int16 (Int.repr 564) :: Init_int16 (Int.repr 560) ::
                Init_int16 (Int.repr 685) :: Init_int16 (Int.repr 559) ::
                Init_int16 (Int.repr 544) :: Init_int16 (Int.repr 680) ::
                Init_int16 (Int.repr 561) :: Init_int16 (Int.repr 558) ::
                Init_int16 (Int.repr 560) :: Init_int16 (Int.repr 558) ::
                Init_int16 (Int.repr 561) :: Init_int16 (Int.repr 613) ::
                Init_int16 (Int.repr 558) :: Init_int16 (Int.repr 613) ::
                Init_int16 (Int.repr 562) :: Init_int16 (Int.repr 544) ::
                Init_int16 (Int.repr 558) :: Init_int16 (Int.repr 562) ::
                Init_int16 (Int.repr 562) :: Init_int16 (Int.repr 681) ::
                Init_int16 (Int.repr 544) :: Init_int16 (Int.repr 563) ::
                Init_int16 (Int.repr 561) :: Init_int16 (Int.repr 560) ::
                Init_int16 (Int.repr 563) :: Init_int16 (Int.repr 560) ::
                Init_int16 (Int.repr 564) :: Init_int16 (Int.repr 560) ::
                Init_int16 (Int.repr 559) :: Init_int16 (Int.repr 615) ::
                Init_int16 (Int.repr 560) :: Init_int16 (Int.repr 615) ::
                Init_int16 (Int.repr 685) :: Init_int16 (Int.repr 573) ::
                Init_int16 (Int.repr 567) :: Init_int16 (Int.repr 600) ::
                Init_int16 (Int.repr 565) :: Init_int16 (Int.repr 561) ::
                Init_int16 (Int.repr 563) :: Init_int16 (Int.repr 561) ::
                Init_int16 (Int.repr 614) :: Init_int16 (Int.repr 613) ::
                Init_int16 (Int.repr 561) :: Init_int16 (Int.repr 565) ::
                Init_int16 (Int.repr 614) :: Init_int16 (Int.repr 565) ::
                Init_int16 (Int.repr 563) :: Init_int16 (Int.repr 566) ::
                Init_int16 (Int.repr 566) :: Init_int16 (Int.repr 563) ::
                Init_int16 (Int.repr 564) :: Init_int16 (Int.repr 567) ::
                Init_int16 (Int.repr 565) :: Init_int16 (Int.repr 568) ::
                Init_int16 (Int.repr 568) :: Init_int16 (Int.repr 565) ::
                Init_int16 (Int.repr 566) :: Init_int16 (Int.repr 565) ::
                Init_int16 (Int.repr 567) :: Init_int16 (Int.repr 572) ::
                Init_int16 (Int.repr 565) :: Init_int16 (Int.repr 572) ::
                Init_int16 (Int.repr 614) :: Init_int16 (Int.repr 566) ::
                Init_int16 (Int.repr 570) :: Init_int16 (Int.repr 568) ::
                Init_int16 (Int.repr 569) :: Init_int16 (Int.repr 566) ::
                Init_int16 (Int.repr 564) :: Init_int16 (Int.repr 570) ::
                Init_int16 (Int.repr 566) :: Init_int16 (Int.repr 569) ::
                Init_int16 (Int.repr 571) :: Init_int16 (Int.repr 567) ::
                Init_int16 (Int.repr 568) :: Init_int16 (Int.repr 572) ::
                Init_int16 (Int.repr 567) :: Init_int16 (Int.repr 573) ::
                Init_int16 (Int.repr 564) :: Init_int16 (Int.repr 578) ::
                Init_int16 (Int.repr 688) :: Init_int16 (Int.repr 568) ::
                Init_int16 (Int.repr 570) :: Init_int16 (Int.repr 577) ::
                Init_int16 (Int.repr 575) :: Init_int16 (Int.repr 568) ::
                Init_int16 (Int.repr 577) :: Init_int16 (Int.repr 576) ::
                Init_int16 (Int.repr 571) :: Init_int16 (Int.repr 568) ::
                Init_int16 (Int.repr 575) :: Init_int16 (Int.repr 576) ::
                Init_int16 (Int.repr 568) :: Init_int16 (Int.repr 570) ::
                Init_int16 (Int.repr 569) :: Init_int16 (Int.repr 611) ::
                Init_int16 (Int.repr 577) :: Init_int16 (Int.repr 570) ::
                Init_int16 (Int.repr 611) :: Init_int16 (Int.repr 574) ::
                Init_int16 (Int.repr 567) :: Init_int16 (Int.repr 571) ::
                Init_int16 (Int.repr 576) :: Init_int16 (Int.repr 574) ::
                Init_int16 (Int.repr 571) :: Init_int16 (Int.repr 578) ::
                Init_int16 (Int.repr 687) :: Init_int16 (Int.repr 688) ::
                Init_int16 (Int.repr 578) :: Init_int16 (Int.repr 580) ::
                Init_int16 (Int.repr 687) :: Init_int16 (Int.repr 577) ::
                Init_int16 (Int.repr 585) :: Init_int16 (Int.repr 635) ::
                Init_int16 (Int.repr 581) :: Init_int16 (Int.repr 688) ::
                Init_int16 (Int.repr 687) :: Init_int16 (Int.repr 582) ::
                Init_int16 (Int.repr 581) :: Init_int16 (Int.repr 687) ::
                Init_int16 (Int.repr 582) :: Init_int16 (Int.repr 687) ::
                Init_int16 (Int.repr 580) :: Init_int16 (Int.repr 583) ::
                Init_int16 (Int.repr 564) :: Init_int16 (Int.repr 688) ::
                Init_int16 (Int.repr 581) :: Init_int16 (Int.repr 583) ::
                Init_int16 (Int.repr 688) :: Init_int16 (Int.repr 581) ::
                Init_int16 (Int.repr 584) :: Init_int16 (Int.repr 611) ::
                Init_int16 (Int.repr 581) :: Init_int16 (Int.repr 611) ::
                Init_int16 (Int.repr 583) :: Init_int16 (Int.repr 584) ::
                Init_int16 (Int.repr 581) :: Init_int16 (Int.repr 582) ::
                Init_int16 (Int.repr 585) :: Init_int16 (Int.repr 577) ::
                Init_int16 (Int.repr 611) :: Init_int16 (Int.repr 575) ::
                Init_int16 (Int.repr 577) :: Init_int16 (Int.repr 635) ::
                Init_int16 (Int.repr 590) :: Init_int16 (Int.repr 591) ::
                Init_int16 (Int.repr 547) :: Init_int16 (Int.repr 586) ::
                Init_int16 (Int.repr 576) :: Init_int16 (Int.repr 575) ::
                Init_int16 (Int.repr 498) :: Init_int16 (Int.repr 586) ::
                Init_int16 (Int.repr 575) :: Init_int16 (Int.repr 576) ::
                Init_int16 (Int.repr 586) :: Init_int16 (Int.repr 574) ::
                Init_int16 (Int.repr 587) :: Init_int16 (Int.repr 591) ::
                Init_int16 (Int.repr 590) :: Init_int16 (Int.repr 588) ::
                Init_int16 (Int.repr 591) :: Init_int16 (Int.repr 587) ::
                Init_int16 (Int.repr 523) :: Init_int16 (Int.repr 588) ::
                Init_int16 (Int.repr 587) :: Init_int16 (Int.repr 589) ::
                Init_int16 (Int.repr 523) :: Init_int16 (Int.repr 587) ::
                Init_int16 (Int.repr 590) :: Init_int16 (Int.repr 589) ::
                Init_int16 (Int.repr 587) :: Init_int16 (Int.repr 588) ::
                Init_int16 (Int.repr 689) :: Init_int16 (Int.repr 591) ::
                Init_int16 (Int.repr 591) :: Init_int16 (Int.repr 689) ::
                Init_int16 (Int.repr 690) :: Init_int16 (Int.repr 592) ::
                Init_int16 (Int.repr 591) :: Init_int16 (Int.repr 690) ::
                Init_int16 (Int.repr 591) :: Init_int16 (Int.repr 592) ::
                Init_int16 (Int.repr 547) :: Init_int16 (Int.repr 590) ::
                Init_int16 (Int.repr 546) :: Init_int16 (Int.repr 682) ::
                Init_int16 (Int.repr 590) :: Init_int16 (Int.repr 682) ::
                Init_int16 (Int.repr 621) :: Init_int16 (Int.repr 589) ::
                Init_int16 (Int.repr 590) :: Init_int16 (Int.repr 621) ::
                Init_int16 (Int.repr 590) :: Init_int16 (Int.repr 547) ::
                Init_int16 (Int.repr 546) :: Init_int16 (Int.repr 588) ::
                Init_int16 (Int.repr 593) :: Init_int16 (Int.repr 689) ::
                Init_int16 (Int.repr 593) :: Init_int16 (Int.repr 588) ::
                Init_int16 (Int.repr 523) :: Init_int16 (Int.repr 594) ::
                Init_int16 (Int.repr 593) :: Init_int16 (Int.repr 523) ::
                Init_int16 (Int.repr 523) :: Init_int16 (Int.repr 589) ::
                Init_int16 (Int.repr 623) :: Init_int16 (Int.repr 589) ::
                Init_int16 (Int.repr 621) :: Init_int16 (Int.repr 622) ::
                Init_int16 (Int.repr 589) :: Init_int16 (Int.repr 622) ::
                Init_int16 (Int.repr 623) :: Init_int16 (Int.repr 603) ::
                Init_int16 (Int.repr 548) :: Init_int16 (Int.repr 602) ::
                Init_int16 (Int.repr 595) :: Init_int16 (Int.repr 599) ::
                Init_int16 (Int.repr 598) :: Init_int16 (Int.repr 595) ::
                Init_int16 (Int.repr 598) :: Init_int16 (Int.repr 686) ::
                Init_int16 (Int.repr 595) :: Init_int16 (Int.repr 601) ::
                Init_int16 (Int.repr 629) :: Init_int16 (Int.repr 596) ::
                Init_int16 (Int.repr 599) :: Init_int16 (Int.repr 595) ::
                Init_int16 (Int.repr 597) :: Init_int16 (Int.repr 596) ::
                Init_int16 (Int.repr 595) :: Init_int16 (Int.repr 595) ::
                Init_int16 (Int.repr 686) :: Init_int16 (Int.repr 601) ::
                Init_int16 (Int.repr 598) :: Init_int16 (Int.repr 599) ::
                Init_int16 (Int.repr 602) :: Init_int16 (Int.repr 599) ::
                Init_int16 (Int.repr 596) :: Init_int16 (Int.repr 603) ::
                Init_int16 (Int.repr 599) :: Init_int16 (Int.repr 603) ::
                Init_int16 (Int.repr 602) :: Init_int16 (Int.repr 600) ::
                Init_int16 (Int.repr 686) :: Init_int16 (Int.repr 598) ::
                Init_int16 (Int.repr 600) :: Init_int16 (Int.repr 598) ::
                Init_int16 (Int.repr 602) :: Init_int16 (Int.repr 574) ::
                Init_int16 (Int.repr 686) :: Init_int16 (Int.repr 600) ::
                Init_int16 (Int.repr 601) :: Init_int16 (Int.repr 686) ::
                Init_int16 (Int.repr 574) :: Init_int16 (Int.repr 602) ::
                Init_int16 (Int.repr 604) :: Init_int16 (Int.repr 600) ::
                Init_int16 (Int.repr 602) :: Init_int16 (Int.repr 548) ::
                Init_int16 (Int.repr 549) :: Init_int16 (Int.repr 602) ::
                Init_int16 (Int.repr 549) :: Init_int16 (Int.repr 604) ::
                Init_int16 (Int.repr 605) :: Init_int16 (Int.repr 621) ::
                Init_int16 (Int.repr 659) :: Init_int16 (Int.repr 604) ::
                Init_int16 (Int.repr 573) :: Init_int16 (Int.repr 600) ::
                Init_int16 (Int.repr 574) :: Init_int16 (Int.repr 600) ::
                Init_int16 (Int.repr 567) :: Init_int16 (Int.repr 603) ::
                Init_int16 (Int.repr 683) :: Init_int16 (Int.repr 548) ::
                Init_int16 (Int.repr 605) :: Init_int16 (Int.repr 683) ::
                Init_int16 (Int.repr 606) :: Init_int16 (Int.repr 603) ::
                Init_int16 (Int.repr 606) :: Init_int16 (Int.repr 683) ::
                Init_int16 (Int.repr 606) :: Init_int16 (Int.repr 531) ::
                Init_int16 (Int.repr 605) :: Init_int16 (Int.repr 531) ::
                Init_int16 (Int.repr 608) :: Init_int16 (Int.repr 605) ::
                Init_int16 (Int.repr 605) :: Init_int16 (Int.repr 608) ::
                Init_int16 (Int.repr 621) :: Init_int16 (Int.repr 603) ::
                Init_int16 (Int.repr 684) :: Init_int16 (Int.repr 606) ::
                Init_int16 (Int.repr 531) :: Init_int16 (Int.repr 606) ::
                Init_int16 (Int.repr 533) :: Init_int16 (Int.repr 606) ::
                Init_int16 (Int.repr 684) :: Init_int16 (Int.repr 533) ::
                Init_int16 (Int.repr 607) :: Init_int16 (Int.repr 608) ::
                Init_int16 (Int.repr 531) :: Init_int16 (Int.repr 529) ::
                Init_int16 (Int.repr 607) :: Init_int16 (Int.repr 531) ::
                Init_int16 (Int.repr 608) :: Init_int16 (Int.repr 607) ::
                Init_int16 (Int.repr 621) :: Init_int16 (Int.repr 609) ::
                Init_int16 (Int.repr 584) :: Init_int16 (Int.repr 582) ::
                Init_int16 (Int.repr 582) :: Init_int16 (Int.repr 580) ::
                Init_int16 (Int.repr 643) :: Init_int16 (Int.repr 610) ::
                Init_int16 (Int.repr 580) :: Init_int16 (Int.repr 658) ::
                Init_int16 (Int.repr 580) :: Init_int16 (Int.repr 578) ::
                Init_int16 (Int.repr 658) :: Init_int16 (Int.repr 580) ::
                Init_int16 (Int.repr 610) :: Init_int16 (Int.repr 643) ::
                Init_int16 (Int.repr 569) :: Init_int16 (Int.repr 564) ::
                Init_int16 (Int.repr 583) :: Init_int16 (Int.repr 564) ::
                Init_int16 (Int.repr 579) :: Init_int16 (Int.repr 578) ::
                Init_int16 (Int.repr 579) :: Init_int16 (Int.repr 564) ::
                Init_int16 (Int.repr 685) :: Init_int16 (Int.repr 611) ::
                Init_int16 (Int.repr 569) :: Init_int16 (Int.repr 583) ::
                Init_int16 (Int.repr 612) :: Init_int16 (Int.repr 549) ::
                Init_int16 (Int.repr 681) :: Init_int16 (Int.repr 612) ::
                Init_int16 (Int.repr 604) :: Init_int16 (Int.repr 549) ::
                Init_int16 (Int.repr 579) :: Init_int16 (Int.repr 658) ::
                Init_int16 (Int.repr 578) :: Init_int16 (Int.repr 592) ::
                Init_int16 (Int.repr 545) :: Init_int16 (Int.repr 547) ::
                Init_int16 (Int.repr 545) :: Init_int16 (Int.repr 592) ::
                Init_int16 (Int.repr 559) :: Init_int16 (Int.repr 545) ::
                Init_int16 (Int.repr 559) :: Init_int16 (Int.repr 680) ::
                Init_int16 (Int.repr 612) :: Init_int16 (Int.repr 573) ::
                Init_int16 (Int.repr 604) :: Init_int16 (Int.repr 613) ::
                Init_int16 (Int.repr 612) :: Init_int16 (Int.repr 562) ::
                Init_int16 (Int.repr 612) :: Init_int16 (Int.repr 681) ::
                Init_int16 (Int.repr 562) :: Init_int16 (Int.repr 612) ::
                Init_int16 (Int.repr 572) :: Init_int16 (Int.repr 573) ::
                Init_int16 (Int.repr 572) :: Init_int16 (Int.repr 612) ::
                Init_int16 (Int.repr 614) :: Init_int16 (Int.repr 614) ::
                Init_int16 (Int.repr 612) :: Init_int16 (Int.repr 613) ::
                Init_int16 (Int.repr 617) :: Init_int16 (Int.repr 619) ::
                Init_int16 (Int.repr 650) :: Init_int16 (Int.repr 615) ::
                Init_int16 (Int.repr 592) :: Init_int16 (Int.repr 690) ::
                Init_int16 (Int.repr 559) :: Init_int16 (Int.repr 592) ::
                Init_int16 (Int.repr 615) :: Init_int16 (Int.repr 546) ::
                Init_int16 (Int.repr 679) :: Init_int16 (Int.repr 682) ::
                Init_int16 (Int.repr 616) :: Init_int16 (Int.repr 615) ::
                Init_int16 (Int.repr 690) :: Init_int16 (Int.repr 616) ::
                Init_int16 (Int.repr 690) :: Init_int16 (Int.repr 689) ::
                Init_int16 (Int.repr 617) :: Init_int16 (Int.repr 616) ::
                Init_int16 (Int.repr 689) :: Init_int16 (Int.repr 618) ::
                Init_int16 (Int.repr 616) :: Init_int16 (Int.repr 677) ::
                Init_int16 (Int.repr 616) :: Init_int16 (Int.repr 617) ::
                Init_int16 (Int.repr 677) :: Init_int16 (Int.repr 616) ::
                Init_int16 (Int.repr 618) :: Init_int16 (Int.repr 615) ::
                Init_int16 (Int.repr 619) :: Init_int16 (Int.repr 617) ::
                Init_int16 (Int.repr 689) :: Init_int16 (Int.repr 625) ::
                Init_int16 (Int.repr 692) :: Init_int16 (Int.repr 693) ::
                Init_int16 (Int.repr 620) :: Init_int16 (Int.repr 615) ::
                Init_int16 (Int.repr 618) :: Init_int16 (Int.repr 579) ::
                Init_int16 (Int.repr 685) :: Init_int16 (Int.repr 615) ::
                Init_int16 (Int.repr 579) :: Init_int16 (Int.repr 615) ::
                Init_int16 (Int.repr 620) :: Init_int16 (Int.repr 621) ::
                Init_int16 (Int.repr 691) :: Init_int16 (Int.repr 622) ::
                Init_int16 (Int.repr 622) :: Init_int16 (Int.repr 691) ::
                Init_int16 (Int.repr 624) :: Init_int16 (Int.repr 623) ::
                Init_int16 (Int.repr 622) :: Init_int16 (Int.repr 624) ::
                Init_int16 (Int.repr 621) :: Init_int16 (Int.repr 692) ::
                Init_int16 (Int.repr 691) :: Init_int16 (Int.repr 624) ::
                Init_int16 (Int.repr 691) :: Init_int16 (Int.repr 692) ::
                Init_int16 (Int.repr 624) :: Init_int16 (Int.repr 692) ::
                Init_int16 (Int.repr 625) :: Init_int16 (Int.repr 621) ::
                Init_int16 (Int.repr 693) :: Init_int16 (Int.repr 692) ::
                Init_int16 (Int.repr 601) :: Init_int16 (Int.repr 628) ::
                Init_int16 (Int.repr 631) :: Init_int16 (Int.repr 625) ::
                Init_int16 (Int.repr 693) :: Init_int16 (Int.repr 626) ::
                Init_int16 (Int.repr 621) :: Init_int16 (Int.repr 607) ::
                Init_int16 (Int.repr 693) :: Init_int16 (Int.repr 626) ::
                Init_int16 (Int.repr 693) :: Init_int16 (Int.repr 607) ::
                Init_int16 (Int.repr 626) :: Init_int16 (Int.repr 607) ::
                Init_int16 (Int.repr 529) :: Init_int16 (Int.repr 596) ::
                Init_int16 (Int.repr 557) :: Init_int16 (Int.repr 603) ::
                Init_int16 (Int.repr 557) :: Init_int16 (Int.repr 596) ::
                Init_int16 (Int.repr 597) :: Init_int16 (Int.repr 627) ::
                Init_int16 (Int.repr 557) :: Init_int16 (Int.repr 597) ::
                Init_int16 (Int.repr 628) :: Init_int16 (Int.repr 601) ::
                Init_int16 (Int.repr 574) :: Init_int16 (Int.repr 629) ::
                Init_int16 (Int.repr 601) :: Init_int16 (Int.repr 631) ::
                Init_int16 (Int.repr 630) :: Init_int16 (Int.repr 628) ::
                Init_int16 (Int.repr 574) :: Init_int16 (Int.repr 631) ::
                Init_int16 (Int.repr 628) :: Init_int16 (Int.repr 630) ::
                Init_int16 (Int.repr 631) :: Init_int16 (Int.repr 630) ::
                Init_int16 (Int.repr 494) :: Init_int16 (Int.repr 632) ::
                Init_int16 (Int.repr 630) :: Init_int16 (Int.repr 574) ::
                Init_int16 (Int.repr 630) :: Init_int16 (Int.repr 632) ::
                Init_int16 (Int.repr 633) :: Init_int16 (Int.repr 494) ::
                Init_int16 (Int.repr 630) :: Init_int16 (Int.repr 633) ::
                Init_int16 (Int.repr 586) :: Init_int16 (Int.repr 632) ::
                Init_int16 (Int.repr 574) :: Init_int16 (Int.repr 633) ::
                Init_int16 (Int.repr 632) :: Init_int16 (Int.repr 586) ::
                Init_int16 (Int.repr 633) :: Init_int16 (Int.repr 586) ::
                Init_int16 (Int.repr 498) :: Init_int16 (Int.repr 634) ::
                Init_int16 (Int.repr 585) :: Init_int16 (Int.repr 611) ::
                Init_int16 (Int.repr 635) :: Init_int16 (Int.repr 585) ::
                Init_int16 (Int.repr 634) :: Init_int16 (Int.repr 635) ::
                Init_int16 (Int.repr 634) :: Init_int16 (Int.repr 637) ::
                Init_int16 (Int.repr 636) :: Init_int16 (Int.repr 634) ::
                Init_int16 (Int.repr 611) :: Init_int16 (Int.repr 634) ::
                Init_int16 (Int.repr 636) :: Init_int16 (Int.repr 502) ::
                Init_int16 (Int.repr 637) :: Init_int16 (Int.repr 634) ::
                Init_int16 (Int.repr 502) :: Init_int16 (Int.repr 638) ::
                Init_int16 (Int.repr 636) :: Init_int16 (Int.repr 611) ::
                Init_int16 (Int.repr 502) :: Init_int16 (Int.repr 636) ::
                Init_int16 (Int.repr 638) :: Init_int16 (Int.repr 502) ::
                Init_int16 (Int.repr 638) :: Init_int16 (Int.repr 640) ::
                Init_int16 (Int.repr 639) :: Init_int16 (Int.repr 638) ::
                Init_int16 (Int.repr 611) :: Init_int16 (Int.repr 638) ::
                Init_int16 (Int.repr 639) :: Init_int16 (Int.repr 641) ::
                Init_int16 (Int.repr 640) :: Init_int16 (Int.repr 638) ::
                Init_int16 (Int.repr 641) :: Init_int16 (Int.repr 584) ::
                Init_int16 (Int.repr 639) :: Init_int16 (Int.repr 611) ::
                Init_int16 (Int.repr 641) :: Init_int16 (Int.repr 639) ::
                Init_int16 (Int.repr 584) :: Init_int16 (Int.repr 641) ::
                Init_int16 (Int.repr 584) :: Init_int16 (Int.repr 609) ::
                Init_int16 (Int.repr 642) :: Init_int16 (Int.repr 610) ::
                Init_int16 (Int.repr 658) :: Init_int16 (Int.repr 650) ::
                Init_int16 (Int.repr 619) :: Init_int16 (Int.repr 649) ::
                Init_int16 (Int.repr 643) :: Init_int16 (Int.repr 642) ::
                Init_int16 (Int.repr 510) :: Init_int16 (Int.repr 643) ::
                Init_int16 (Int.repr 610) :: Init_int16 (Int.repr 642) ::
                Init_int16 (Int.repr 644) :: Init_int16 (Int.repr 642) ::
                Init_int16 (Int.repr 658) :: Init_int16 (Int.repr 642) ::
                Init_int16 (Int.repr 644) :: Init_int16 (Int.repr 646) ::
                Init_int16 (Int.repr 510) :: Init_int16 (Int.repr 642) ::
                Init_int16 (Int.repr 646) :: Init_int16 (Int.repr 645) ::
                Init_int16 (Int.repr 644) :: Init_int16 (Int.repr 658) ::
                Init_int16 (Int.repr 646) :: Init_int16 (Int.repr 644) ::
                Init_int16 (Int.repr 645) :: Init_int16 (Int.repr 646) ::
                Init_int16 (Int.repr 645) :: Init_int16 (Int.repr 648) ::
                Init_int16 (Int.repr 647) :: Init_int16 (Int.repr 645) ::
                Init_int16 (Int.repr 658) :: Init_int16 (Int.repr 648) ::
                Init_int16 (Int.repr 645) :: Init_int16 (Int.repr 539) ::
                Init_int16 (Int.repr 645) :: Init_int16 (Int.repr 647) ::
                Init_int16 (Int.repr 539) :: Init_int16 (Int.repr 649) ::
                Init_int16 (Int.repr 619) :: Init_int16 (Int.repr 689) ::
                Init_int16 (Int.repr 650) :: Init_int16 (Int.repr 649) ::
                Init_int16 (Int.repr 652) :: Init_int16 (Int.repr 651) ::
                Init_int16 (Int.repr 649) :: Init_int16 (Int.repr 689) ::
                Init_int16 (Int.repr 652) :: Init_int16 (Int.repr 649) ::
                Init_int16 (Int.repr 651) :: Init_int16 (Int.repr 652) ::
                Init_int16 (Int.repr 651) :: Init_int16 (Int.repr 654) ::
                Init_int16 (Int.repr 653) :: Init_int16 (Int.repr 651) ::
                Init_int16 (Int.repr 689) :: Init_int16 (Int.repr 651) ::
                Init_int16 (Int.repr 653) :: Init_int16 (Int.repr 656) ::
                Init_int16 (Int.repr 654) :: Init_int16 (Int.repr 651) ::
                Init_int16 (Int.repr 656) :: Init_int16 (Int.repr 655) ::
                Init_int16 (Int.repr 653) :: Init_int16 (Int.repr 689) ::
                Init_int16 (Int.repr 656) :: Init_int16 (Int.repr 653) ::
                Init_int16 (Int.repr 657) :: Init_int16 (Int.repr 653) ::
                Init_int16 (Int.repr 655) :: Init_int16 (Int.repr 657) ::
                Init_int16 (Int.repr 593) :: Init_int16 (Int.repr 655) ::
                Init_int16 (Int.repr 689) :: Init_int16 (Int.repr 657) ::
                Init_int16 (Int.repr 655) :: Init_int16 (Int.repr 593) ::
                Init_int16 (Int.repr 657) :: Init_int16 (Int.repr 593) ::
                Init_int16 (Int.repr 594) :: Init_int16 (Int.repr 658) ::
                Init_int16 (Int.repr 579) :: Init_int16 (Int.repr 620) ::
                Init_int16 (Int.repr 659) :: Init_int16 (Int.repr 621) ::
                Init_int16 (Int.repr 682) :: Init_int16 (Int.repr 659) ::
                Init_int16 (Int.repr 682) :: Init_int16 (Int.repr 679) ::
                Init_int16 (Int.repr 55) :: Init_int16 (Int.repr 24) ::
                Init_int16 (Int.repr 278) :: Init_int16 (Int.repr 279) ::
                Init_int16 (Int.repr 280) :: Init_int16 (Int.repr 266) ::
                Init_int16 (Int.repr 267) :: Init_int16 (Int.repr 268) ::
                Init_int16 (Int.repr 266) :: Init_int16 (Int.repr 269) ::
                Init_int16 (Int.repr 267) :: Init_int16 (Int.repr 270) ::
                Init_int16 (Int.repr 269) :: Init_int16 (Int.repr 266) ::
                Init_int16 (Int.repr 266) :: Init_int16 (Int.repr 268) ::
                Init_int16 (Int.repr 271) :: Init_int16 (Int.repr 271) ::
                Init_int16 (Int.repr 268) :: Init_int16 (Int.repr 272) ::
                Init_int16 (Int.repr 272) :: Init_int16 (Int.repr 273) ::
                Init_int16 (Int.repr 271) :: Init_int16 (Int.repr 270) ::
                Init_int16 (Int.repr 274) :: Init_int16 (Int.repr 269) ::
                Init_int16 (Int.repr 275) :: Init_int16 (Int.repr 270) ::
                Init_int16 (Int.repr 273) :: Init_int16 (Int.repr 276) ::
                Init_int16 (Int.repr 274) :: Init_int16 (Int.repr 270) ::
                Init_int16 (Int.repr 275) :: Init_int16 (Int.repr 276) ::
                Init_int16 (Int.repr 270) :: Init_int16 (Int.repr 277) ::
                Init_int16 (Int.repr 275) :: Init_int16 (Int.repr 273) ::
                Init_int16 (Int.repr 272) :: Init_int16 (Int.repr 277) ::
                Init_int16 (Int.repr 273) :: Init_int16 (Int.repr 284) ::
                Init_int16 (Int.repr 288) :: Init_int16 (Int.repr 289) ::
                Init_int16 (Int.repr 280) :: Init_int16 (Int.repr 279) ::
                Init_int16 (Int.repr 281) :: Init_int16 (Int.repr 280) ::
                Init_int16 (Int.repr 282) :: Init_int16 (Int.repr 283) ::
                Init_int16 (Int.repr 280) :: Init_int16 (Int.repr 281) ::
                Init_int16 (Int.repr 282) :: Init_int16 (Int.repr 283) ::
                Init_int16 (Int.repr 282) :: Init_int16 (Int.repr 284) ::
                Init_int16 (Int.repr 284) :: Init_int16 (Int.repr 289) ::
                Init_int16 (Int.repr 283) :: Init_int16 (Int.repr 278) ::
                Init_int16 (Int.repr 285) :: Init_int16 (Int.repr 279) ::
                Init_int16 (Int.repr 286) :: Init_int16 (Int.repr 278) ::
                Init_int16 (Int.repr 289) :: Init_int16 (Int.repr 287) ::
                Init_int16 (Int.repr 285) :: Init_int16 (Int.repr 278) ::
                Init_int16 (Int.repr 286) :: Init_int16 (Int.repr 287) ::
                Init_int16 (Int.repr 278) :: Init_int16 (Int.repr 288) ::
                Init_int16 (Int.repr 286) :: Init_int16 (Int.repr 289) ::
                Init_int16 (Int.repr 65) :: Init_int16 (Int.repr 67) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr (-67)) :: Init_int16 (Int.repr 1669) ::
                Init_int16 (Int.repr (-16)) :: Init_int16 (Int.repr 192) ::
                Init_int16 (Int.repr 66) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wmotr_seg7_macro_objs := {|
  gvar_info := (tarray tshort 131);
  gvar_init := (Init_int16 (Int.repr 53) :: Init_int16 (Int.repr (-4456)) ::
                Init_int16 (Int.repr 827) :: Init_int16 (Int.repr 191) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 53) ::
                Init_int16 (Int.repr 3712) ::
                Init_int16 (Int.repr (-2740)) ::
                Init_int16 (Int.repr 5200) :: Init_int16 (Int.repr 128) ::
                Init_int16 (Int.repr 54) :: Init_int16 (Int.repr 3684) ::
                Init_int16 (Int.repr (-2712)) ::
                Init_int16 (Int.repr 4660) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 42) :: Init_int16 (Int.repr (-3050)) ::
                Init_int16 (Int.repr 2100) ::
                Init_int16 (Int.repr (-4200)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 98) :: Init_int16 (Int.repr (-2744)) ::
                Init_int16 (Int.repr 4899) ::
                Init_int16 (Int.repr (-4439)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 60) :: Init_int16 (Int.repr 3995) ::
                Init_int16 (Int.repr (-1850)) ::
                Init_int16 (Int.repr 5478) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 35) :: Init_int16 (Int.repr (-2980)) ::
                Init_int16 (Int.repr 3990) ::
                Init_int16 (Int.repr (-4248)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 35) :: Init_int16 (Int.repr 2735) ::
                Init_int16 (Int.repr 3140) ::
                Init_int16 (Int.repr (-3085)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 35) :: Init_int16 (Int.repr (-3640)) ::
                Init_int16 (Int.repr 4600) ::
                Init_int16 (Int.repr (-4200)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 35) :: Init_int16 (Int.repr 4400) ::
                Init_int16 (Int.repr 240) :: Init_int16 (Int.repr 80) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 35) ::
                Init_int16 (Int.repr 3440) ::
                Init_int16 (Int.repr (-2680)) ::
                Init_int16 (Int.repr 5240) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 35) :: Init_int16 (Int.repr (-600)) ::
                Init_int16 (Int.repr (-1360)) ::
                Init_int16 (Int.repr 5040) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 91) :: Init_int16 (Int.repr (-400)) ::
                Init_int16 (Int.repr 1960) :: Init_int16 (Int.repr (-120)) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 91) ::
                Init_int16 (Int.repr (-240)) ::
                Init_int16 (Int.repr (-1080)) ::
                Init_int16 (Int.repr 4520) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 91) :: Init_int16 (Int.repr 3600) ::
                Init_int16 (Int.repr (-2480)) ::
                Init_int16 (Int.repr 5440) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 91) :: Init_int16 (Int.repr 3960) ::
                Init_int16 (Int.repr 520) :: Init_int16 (Int.repr 440) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 91) ::
                Init_int16 (Int.repr (-3200)) ::
                Init_int16 (Int.repr 4880) ::
                Init_int16 (Int.repr (-4040)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 91) :: Init_int16 (Int.repr (-2760)) ::
                Init_int16 (Int.repr 2320) ::
                Init_int16 (Int.repr (-4080)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 77) :: Init_int16 (Int.repr (-3630)) ::
                Init_int16 (Int.repr (-430)) :: Init_int16 (Int.repr 3180) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 35) ::
                Init_int16 (Int.repr 320) :: Init_int16 (Int.repr 1725) ::
                Init_int16 (Int.repr 40) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 35) :: Init_int16 (Int.repr (-2560)) ::
                Init_int16 (Int.repr 4600) ::
                Init_int16 (Int.repr (-4800)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 43) :: Init_int16 (Int.repr (-50)) ::
                Init_int16 (Int.repr 2180) :: Init_int16 (Int.repr 1900) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 7211) ::
                Init_int16 (Int.repr (-2850)) ::
                Init_int16 (Int.repr 1550) :: Init_int16 (Int.repr 2280) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 15403) ::
                Init_int16 (Int.repr 1710) :: Init_int16 (Int.repr (-650)) ::
                Init_int16 (Int.repr 4850) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 43) :: Init_int16 (Int.repr 2350) ::
                Init_int16 (Int.repr 2300) :: Init_int16 (Int.repr 240) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 77) ::
                Init_int16 (Int.repr (-3260)) ::
                Init_int16 (Int.repr 3370) ::
                Init_int16 (Int.repr (-3945)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 30) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_exclamation_box_outline_seg8_collision_08025F78 := {|
  gvar_info := (tarray tshort 66);
  gvar_init := (Init_int16 (Int.repr 64) :: Init_int16 (Int.repr 8) ::
                Init_int16 (Int.repr (-26)) :: Init_int16 (Int.repr 30) ::
                Init_int16 (Int.repr (-26)) :: Init_int16 (Int.repr (-26)) ::
                Init_int16 (Int.repr 30) :: Init_int16 (Int.repr 26) ::
                Init_int16 (Int.repr (-26)) :: Init_int16 (Int.repr 52) ::
                Init_int16 (Int.repr 26) :: Init_int16 (Int.repr 26) ::
                Init_int16 (Int.repr 30) :: Init_int16 (Int.repr 26) ::
                Init_int16 (Int.repr 26) :: Init_int16 (Int.repr 52) ::
                Init_int16 (Int.repr 26) :: Init_int16 (Int.repr 26) ::
                Init_int16 (Int.repr 30) :: Init_int16 (Int.repr (-26)) ::
                Init_int16 (Int.repr 26) :: Init_int16 (Int.repr 52) ::
                Init_int16 (Int.repr (-26)) :: Init_int16 (Int.repr (-26)) ::
                Init_int16 (Int.repr 52) :: Init_int16 (Int.repr (-26)) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 12) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 1) ::
                Init_int16 (Int.repr 2) :: Init_int16 (Int.repr 1) ::
                Init_int16 (Int.repr 3) :: Init_int16 (Int.repr 4) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 4) ::
                Init_int16 (Int.repr 2) :: Init_int16 (Int.repr 5) ::
                Init_int16 (Int.repr 3) :: Init_int16 (Int.repr 1) ::
                Init_int16 (Int.repr 5) :: Init_int16 (Int.repr 1) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 6) ::
                Init_int16 (Int.repr 4) :: Init_int16 (Int.repr 3) ::
                Init_int16 (Int.repr 6) :: Init_int16 (Int.repr 3) ::
                Init_int16 (Int.repr 5) :: Init_int16 (Int.repr 7) ::
                Init_int16 (Int.repr 4) :: Init_int16 (Int.repr 6) ::
                Init_int16 (Int.repr 7) :: Init_int16 (Int.repr 2) ::
                Init_int16 (Int.repr 4) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 2) :: Init_int16 (Int.repr 7) ::
                Init_int16 (Int.repr 7) :: Init_int16 (Int.repr 6) ::
                Init_int16 (Int.repr 5) :: Init_int16 (Int.repr 7) ::
                Init_int16 (Int.repr 5) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 65) :: Init_int16 (Int.repr 66) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_cannon_lid_seg8_collision_08004950 := {|
  gvar_info := (tarray tshort 24);
  gvar_init := (Init_int16 (Int.repr 64) :: Init_int16 (Int.repr 4) ::
                Init_int16 (Int.repr 112) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr (-111)) ::
                Init_int16 (Int.repr (-111)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr (-111)) ::
                Init_int16 (Int.repr (-111)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 112) :: Init_int16 (Int.repr 112) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 112) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 2) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 1) ::
                Init_int16 (Int.repr 2) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 2) :: Init_int16 (Int.repr 3) ::
                Init_int16 (Int.repr 65) :: Init_int16 (Int.repr 66) :: nil);
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
 (_wmotr_seg7_collision, Gvar v_wmotr_seg7_collision) ::
 (_wmotr_seg7_macro_objs, Gvar v_wmotr_seg7_macro_objs) ::
 (_exclamation_box_outline_seg8_collision_08025F78, Gvar v_exclamation_box_outline_seg8_collision_08025F78) ::
 (_cannon_lid_seg8_collision_08004950, Gvar v_cannon_lid_seg8_collision_08004950) ::
 nil).

Definition public_idents : list ident :=
(_cannon_lid_seg8_collision_08004950 ::
 _exclamation_box_outline_seg8_collision_08025F78 ::
 _wmotr_seg7_macro_objs :: _wmotr_seg7_collision :: ___builtin_debug ::
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


