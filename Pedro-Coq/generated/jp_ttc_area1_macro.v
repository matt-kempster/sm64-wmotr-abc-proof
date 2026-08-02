(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_JP
   Source:          levels/ttc/areas/1/macro.inc.c (project wrapper)
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_JP=1 -DF3D_OLD=1
   Link hygiene:    private __stringlit_N atoms prefixed with jp_ttc_area1_macro
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
  Definition source_file := "./inputs/ttc_area1_macro.c".
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
Definition _main : ident := $"main".
Definition _ttc_seg7_macro_objs : ident := $"ttc_seg7_macro_objs".

Definition v_ttc_seg7_macro_objs := {|
  gvar_info := (tarray tshort 551);
  gvar_init := (Init_int16 (Int.repr 8536) ::
                Init_int16 (Int.repr (-1032)) ::
                Init_int16 (Int.repr (-3291)) ::
                Init_int16 (Int.repr 1070) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 16728) ::
                Init_int16 (Int.repr (-1881)) ::
                Init_int16 (Int.repr 1767) :: Init_int16 (Int.repr (-446)) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 16728) ::
                Init_int16 (Int.repr (-1870)) ::
                Init_int16 (Int.repr 2068) :: Init_int16 (Int.repr 362) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr (-24232)) ::
                Init_int16 (Int.repr (-770)) ::
                Init_int16 (Int.repr (-4361)) ::
                Init_int16 (Int.repr (-423)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 24920) ::
                Init_int16 (Int.repr (-1314)) ::
                Init_int16 (Int.repr (-3691)) :: Init_int16 (Int.repr 788) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 24920) ::
                Init_int16 (Int.repr (-1314)) ::
                Init_int16 (Int.repr (-2892)) ::
                Init_int16 (Int.repr 1353) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr (-7847)) :: Init_int16 (Int.repr 780) ::
                Init_int16 (Int.repr 5767) ::
                Init_int16 (Int.repr (-1027)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr (-7847)) ::
                Init_int16 (Int.repr 1063) :: Init_int16 (Int.repr 5562) ::
                Init_int16 (Int.repr (-744)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 8538) ::
                Init_int16 (Int.repr (-1350)) :: Init_int16 (Int.repr 748) ::
                Init_int16 (Int.repr (-1208)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 8538) :: Init_int16 (Int.repr (-690)) ::
                Init_int16 (Int.repr 901) :: Init_int16 (Int.repr (-910)) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 8538) ::
                Init_int16 (Int.repr (-1389)) ::
                Init_int16 (Int.repr (-3030)) ::
                Init_int16 (Int.repr (-1028)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 8538) :: Init_int16 (Int.repr 937) ::
                Init_int16 (Int.repr (-3867)) ::
                Init_int16 (Int.repr (-1041)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 24923) ::
                Init_int16 (Int.repr (-139)) ::
                Init_int16 (Int.repr (-4408)) ::
                Init_int16 (Int.repr (-1056)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 16732) :: Init_int16 (Int.repr 618) ::
                Init_int16 (Int.repr 3656) :: Init_int16 (Int.repr 148) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr (-16036)) ::
                Init_int16 (Int.repr 963) :: Init_int16 (Int.repr 3297) ::
                Init_int16 (Int.repr 608) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 16732) :: Init_int16 (Int.repr 1306) ::
                Init_int16 (Int.repr 2939) :: Init_int16 (Int.repr 1069) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr (-7844)) ::
                Init_int16 (Int.repr (-1179)) ::
                Init_int16 (Int.repr (-1453)) ::
                Init_int16 (Int.repr (-792)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr (-32419)) ::
                Init_int16 (Int.repr 174) :: Init_int16 (Int.repr 1248) ::
                Init_int16 (Int.repr 2040) :: Init_int16 (Int.repr 2) ::
                Init_int16 (Int.repr 8541) ::
                Init_int16 (Int.repr (-1321)) ::
                Init_int16 (Int.repr 1490) ::
                Init_int16 (Int.repr (-1563)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 8541) ::
                Init_int16 (Int.repr (-1076)) ::
                Init_int16 (Int.repr 1730) ::
                Init_int16 (Int.repr (-1808)) :: Init_int16 (Int.repr 5) ::
                Init_int16 (Int.repr 8541) ::
                Init_int16 (Int.repr (-1319)) ::
                Init_int16 (Int.repr 1970) ::
                Init_int16 (Int.repr (-1564)) :: Init_int16 (Int.repr 10) ::
                Init_int16 (Int.repr (-32419)) ::
                Init_int16 (Int.repr (-517)) :: Init_int16 (Int.repr 3175) ::
                Init_int16 (Int.repr 2040) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr (-32419)) ::
                Init_int16 (Int.repr (-170)) :: Init_int16 (Int.repr 1248) ::
                Init_int16 (Int.repr 2040) :: Init_int16 (Int.repr 1) ::
                Init_int16 (Int.repr (-32419)) ::
                Init_int16 (Int.repr (-515)) :: Init_int16 (Int.repr 1248) ::
                Init_int16 (Int.repr 2040) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 349) :: Init_int16 (Int.repr (-175)) ::
                Init_int16 (Int.repr (-1351)) ::
                Init_int16 (Int.repr (-2039)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr (-32419)) ::
                Init_int16 (Int.repr (-515)) ::
                Init_int16 (Int.repr (-2590)) ::
                Init_int16 (Int.repr 2040) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr (-32419)) ::
                Init_int16 (Int.repr 518) :: Init_int16 (Int.repr 3175) ::
                Init_int16 (Int.repr 2040) :: Init_int16 (Int.repr 3) ::
                Init_int16 (Int.repr (-32419)) ::
                Init_int16 (Int.repr (-171)) :: Init_int16 (Int.repr 3175) ::
                Init_int16 (Int.repr 2040) :: Init_int16 (Int.repr 1) ::
                Init_int16 (Int.repr (-32419)) ::
                Init_int16 (Int.repr 174) :: Init_int16 (Int.repr 3175) ::
                Init_int16 (Int.repr 2040) :: Init_int16 (Int.repr 2) ::
                Init_int16 (Int.repr 350) :: Init_int16 (Int.repr 1490) ::
                Init_int16 (Int.repr (-2088)) ::
                Init_int16 (Int.repr (-873)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 350) :: Init_int16 (Int.repr (-708)) ::
                Init_int16 (Int.repr (-1606)) ::
                Init_int16 (Int.repr (-1589)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 350) :: Init_int16 (Int.repr 954) ::
                Init_int16 (Int.repr (-1627)) ::
                Init_int16 (Int.repr (-1448)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 350) :: Init_int16 (Int.repr 1215) ::
                Init_int16 (Int.repr (-1781)) ::
                Init_int16 (Int.repr (-1215)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 350) :: Init_int16 (Int.repr 1052) ::
                Init_int16 (Int.repr (-1934)) ::
                Init_int16 (Int.repr (-769)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr (-24225)) ::
                Init_int16 (Int.repr (-620)) :: Init_int16 (Int.repr 1229) ::
                Init_int16 (Int.repr 1233) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr (-7841)) ::
                Init_int16 (Int.repr 1050) :: Init_int16 (Int.repr (-19)) ::
                Init_int16 (Int.repr (-1037)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr (-7840)) ::
                Init_int16 (Int.repr (-1100)) ::
                Init_int16 (Int.repr (-71)) ::
                Init_int16 (Int.repr (-1030)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr (-24221)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 6011) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 8547) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr (-2487)) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 24932) :: Init_int16 (Int.repr 1102) ::
                Init_int16 (Int.repr (-3619)) ::
                Init_int16 (Int.repr 1682) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 16740) :: Init_int16 (Int.repr 424) ::
                Init_int16 (Int.repr (-3312)) ::
                Init_int16 (Int.repr 1959) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 24932) :: Init_int16 (Int.repr 1102) ::
                Init_int16 (Int.repr (-3004)) ::
                Init_int16 (Int.repr 1682) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 24932) :: Init_int16 (Int.repr 1584) ::
                Init_int16 (Int.repr (-2697)) ::
                Init_int16 (Int.repr 1200) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 24932) :: Init_int16 (Int.repr 1582) ::
                Init_int16 (Int.repr (-3619)) ::
                Init_int16 (Int.repr 1203) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 24932) ::
                Init_int16 (Int.repr (-762)) :: Init_int16 (Int.repr 4347) ::
                Init_int16 (Int.repr 1047) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 16740) :: Init_int16 (Int.repr 424) ::
                Init_int16 (Int.repr (-3926)) ::
                Init_int16 (Int.repr 1959) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 24932) :: Init_int16 (Int.repr 1102) ::
                Init_int16 (Int.repr (-4233)) ::
                Init_int16 (Int.repr 1682) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 24932) :: Init_int16 (Int.repr 1102) ::
                Init_int16 (Int.repr (-4848)) ::
                Init_int16 (Int.repr 1682) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 16740) :: Init_int16 (Int.repr 424) ::
                Init_int16 (Int.repr (-4540)) ::
                Init_int16 (Int.repr 1959) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr (-7836)) ::
                Init_int16 (Int.repr (-1037)) ::
                Init_int16 (Int.repr 4244) :: Init_int16 (Int.repr 772) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 356) ::
                Init_int16 (Int.repr 1828) :: Init_int16 (Int.repr 3835) ::
                Init_int16 (Int.repr (-50)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 356) :: Init_int16 (Int.repr 1459) ::
                Init_int16 (Int.repr 3835) :: Init_int16 (Int.repr (-357)) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 356) ::
                Init_int16 (Int.repr 1091) :: Init_int16 (Int.repr 3835) ::
                Init_int16 (Int.repr (-665)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 357) :: Init_int16 (Int.repr 1580) ::
                Init_int16 (Int.repr (-4854)) ::
                Init_int16 (Int.repr (-825)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 357) :: Init_int16 (Int.repr (-1692)) ::
                Init_int16 (Int.repr 1022) ::
                Init_int16 (Int.repr (-1157)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 357) :: Init_int16 (Int.repr 2098) ::
                Init_int16 (Int.repr 7007) :: Init_int16 (Int.repr 2243) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 358) ::
                Init_int16 (Int.repr 1801) ::
                Init_int16 (Int.repr (-4843)) ::
                Init_int16 (Int.repr (-731)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 358) :: Init_int16 (Int.repr (-1477)) ::
                Init_int16 (Int.repr 1044) ::
                Init_int16 (Int.repr (-1088)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 358) :: Init_int16 (Int.repr 2268) ::
                Init_int16 (Int.repr 7030) :: Init_int16 (Int.repr 2227) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 35) ::
                Init_int16 (Int.repr 800) :: Init_int16 (Int.repr (-4400)) ::
                Init_int16 (Int.repr 1900) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 35) :: Init_int16 (Int.repr 800) ::
                Init_int16 (Int.repr (-3700)) ::
                Init_int16 (Int.repr 1900) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 35) :: Init_int16 (Int.repr 800) ::
                Init_int16 (Int.repr (-3000)) ::
                Init_int16 (Int.repr 1900) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 35) :: Init_int16 (Int.repr 1780) ::
                Init_int16 (Int.repr (-3300)) ::
                Init_int16 (Int.repr 1000) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 35) :: Init_int16 (Int.repr 1388) ::
                Init_int16 (Int.repr (-3300)) ::
                Init_int16 (Int.repr 1428) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 35) :: Init_int16 (Int.repr 200) ::
                Init_int16 (Int.repr (-3000)) ::
                Init_int16 (Int.repr 2000) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 35) :: Init_int16 (Int.repr 200) ::
                Init_int16 (Int.repr (-3700)) ::
                Init_int16 (Int.repr 2000) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 35) :: Init_int16 (Int.repr 200) ::
                Init_int16 (Int.repr (-4400)) ::
                Init_int16 (Int.repr 2000) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 60) :: Init_int16 (Int.repr (-1080)) ::
                Init_int16 (Int.repr 90) :: Init_int16 (Int.repr 1575) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 8546) ::
                Init_int16 (Int.repr (-1179)) :: Init_int16 (Int.repr 445) ::
                Init_int16 (Int.repr 1413) :: Init_int16 (Int.repr 6) ::
                Init_int16 (Int.repr (-7838)) ::
                Init_int16 (Int.repr (-1524)) ::
                Init_int16 (Int.repr (-1454)) ::
                Init_int16 (Int.repr 1129) :: Init_int16 (Int.repr 2) ::
                Init_int16 (Int.repr 70) :: Init_int16 (Int.repr (-980)) ::
                Init_int16 (Int.repr (-700)) :: Init_int16 (Int.repr 1450) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 8276) ::
                Init_int16 (Int.repr (-1203)) ::
                Init_int16 (Int.repr (-19)) ::
                Init_int16 (Int.repr (-170)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 85) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 20) :: Init_int16 (Int.repr (-1400)) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 85) ::
                Init_int16 (Int.repr (-250)) :: Init_int16 (Int.repr 20) ::
                Init_int16 (Int.repr (-1700)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 85) :: Init_int16 (Int.repr 250) ::
                Init_int16 (Int.repr 20) :: Init_int16 (Int.repr (-1700)) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 85) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 20) ::
                Init_int16 (Int.repr (-2000)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 85) :: Init_int16 (Int.repr 500) ::
                Init_int16 (Int.repr 20) :: Init_int16 (Int.repr (-2000)) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 85) ::
                Init_int16 (Int.repr (-500)) :: Init_int16 (Int.repr 20) ::
                Init_int16 (Int.repr (-2000)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 113) :: Init_int16 (Int.repr 880) ::
                Init_int16 (Int.repr (-19)) :: Init_int16 (Int.repr 1160) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 116) ::
                Init_int16 (Int.repr 800) :: Init_int16 (Int.repr (-2460)) ::
                Init_int16 (Int.repr 160) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 8229) ::
                Init_int16 (Int.repr (-1120)) ::
                Init_int16 (Int.repr (-820)) :: Init_int16 (Int.repr 1320) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 116) ::
                Init_int16 (Int.repr (-571)) :: Init_int16 (Int.repr 6020) ::
                Init_int16 (Int.repr (-1414)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 75) :: Init_int16 (Int.repr 620) ::
                Init_int16 (Int.repr (-5150)) ::
                Init_int16 (Int.repr 1540) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 80) :: Init_int16 (Int.repr (-520)) ::
                Init_int16 (Int.repr 1351) :: Init_int16 (Int.repr 1919) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 80) ::
                Init_int16 (Int.repr (-165)) :: Init_int16 (Int.repr 1351) ::
                Init_int16 (Int.repr 1919) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 80) :: Init_int16 (Int.repr 182) ::
                Init_int16 (Int.repr 1351) :: Init_int16 (Int.repr 1919) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 79) ::
                Init_int16 (Int.repr 657) :: Init_int16 (Int.repr 1368) ::
                Init_int16 (Int.repr 1879) :: Init_int16 (Int.repr 3) ::
                Init_int16 (Int.repr 70) :: Init_int16 (Int.repr (-700)) ::
                Init_int16 (Int.repr (-2350)) ::
                Init_int16 (Int.repr (-700)) :: Init_int16 (Int.repr 1) ::
                Init_int16 (Int.repr 98) :: Init_int16 (Int.repr 1883) ::
                Init_int16 (Int.repr 4150) :: Init_int16 (Int.repr 550) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 75) ::
                Init_int16 (Int.repr (-1333)) :: Init_int16 (Int.repr 350) ::
                Init_int16 (Int.repr 1116) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 8290) ::
                Init_int16 (Int.repr (-1101)) ::
                Init_int16 (Int.repr 6316) :: Init_int16 (Int.repr (-685)) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 142) ::
                Init_int16 (Int.repr 1077) ::
                Init_int16 (Int.repr (-4822)) :: Init_int16 (Int.repr 638) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 142) ::
                Init_int16 (Int.repr 1683) ::
                Init_int16 (Int.repr (-4822)) :: Init_int16 (Int.repr 189) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 85) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 20) ::
                Init_int16 (Int.repr (-1700)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 350) :: Init_int16 (Int.repr (-1020)) ::
                Init_int16 (Int.repr 1229) :: Init_int16 (Int.repr 537) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 8289) ::
                Init_int16 (Int.repr 2350) :: Init_int16 (Int.repr 5600) ::
                Init_int16 (Int.repr 2350) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 97) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 4783) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 8288) ::
                Init_int16 (Int.repr (-1140)) ::
                Init_int16 (Int.repr (-3720)) ::
                Init_int16 (Int.repr (-1620)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 8288) :: Init_int16 (Int.repr 840) ::
                Init_int16 (Int.repr (-2200)) :: Init_int16 (Int.repr 860) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 31) ::
                Init_int16 (Int.repr (-770)) ::
                Init_int16 (Int.repr (-3800)) ::
                Init_int16 (Int.repr (-440)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 31) :: Init_int16 (Int.repr (-770)) ::
                Init_int16 (Int.repr (-3700)) ::
                Init_int16 (Int.repr (-440)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 97) :: Init_int16 (Int.repr 280) ::
                Init_int16 (Int.repr (-4920)) ::
                Init_int16 (Int.repr 1660) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 8288) :: Init_int16 (Int.repr 1240) ::
                Init_int16 (Int.repr 300) :: Init_int16 (Int.repr 840) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 8288) ::
                Init_int16 (Int.repr 520) :: Init_int16 (Int.repr 300) ::
                Init_int16 (Int.repr 1500) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 97) :: Init_int16 (Int.repr (-400)) ::
                Init_int16 (Int.repr 3600) :: Init_int16 (Int.repr 1880) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 96) ::
                Init_int16 (Int.repr (-40)) :: Init_int16 (Int.repr 4160) ::
                Init_int16 (Int.repr (-1280)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 8288) ::
                Init_int16 (Int.repr (-1160)) ::
                Init_int16 (Int.repr 2920) :: Init_int16 (Int.repr (-840)) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 8289) ::
                Init_int16 (Int.repr (-780)) :: Init_int16 (Int.repr 6316) ::
                Init_int16 (Int.repr (-1020)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 8551) :: Init_int16 (Int.repr 1313) ::
                Init_int16 (Int.repr 6190) :: Init_int16 (Int.repr 1313) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 360) ::
                Init_int16 (Int.repr 1851) ::
                Init_int16 (Int.repr (-2488)) ::
                Init_int16 (Int.repr (-98)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 30) :: nil);
  gvar_readonly := true;
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
 (_ttc_seg7_macro_objs, Gvar v_ttc_seg7_macro_objs) :: nil).

Definition public_idents : list ident :=
(_ttc_seg7_macro_objs :: ___builtin_debug :: ___builtin_sync_fetch_and_add ::
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
