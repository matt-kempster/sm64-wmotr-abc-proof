(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_JP
   Source:          actors/bobomb/anims data and table (common0.c data-only wrapper)
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_JP=1 -DF3D_OLD=1
   Link hygiene:    private __stringlit_N atoms prefixed with jp_bobomb_animation_data
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
  Definition source_file := "./inputs/bobomb_animation_data.c".
  Definition normalized := true.
End Info.

Definition _Animation : ident := $"Animation".
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
Definition _bobomb_seg8_anim_080237FC : ident := $"bobomb_seg8_anim_080237FC".
Definition _bobomb_seg8_anim_08023954 : ident := $"bobomb_seg8_anim_08023954".
Definition _bobomb_seg8_animindex_08023754 : ident := $"bobomb_seg8_animindex_08023754".
Definition _bobomb_seg8_animindex_080238AC : ident := $"bobomb_seg8_animindex_080238AC".
Definition _bobomb_seg8_anims_0802396C : ident := $"bobomb_seg8_anims_0802396C".
Definition _bobomb_seg8_animvalue_08023528 : ident := $"bobomb_seg8_animvalue_08023528".
Definition _bobomb_seg8_animvalue_08023814 : ident := $"bobomb_seg8_animvalue_08023814".
Definition _flags : ident := $"flags".
Definition _index : ident := $"index".
Definition _length : ident := $"length".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _main : ident := $"main".
Definition _startFrame : ident := $"startFrame".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _values : ident := $"values".

Definition v_bobomb_seg8_animvalue_08023528 := {|
  gvar_info := (tarray tshort 278);
  gvar_init := (Init_int16 (Int.repr 0) :: Init_int16 (Int.repr (-8)) ::
                Init_int16 (Int.repr (-8)) :: Init_int16 (Int.repr (-6)) ::
                Init_int16 (Int.repr (-4)) :: Init_int16 (Int.repr (-1)) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 1) ::
                Init_int16 (Int.repr 3) :: Init_int16 (Int.repr 5) ::
                Init_int16 (Int.repr 6) :: Init_int16 (Int.repr 7) ::
                Init_int16 (Int.repr 8) :: Init_int16 (Int.repr 7) ::
                Init_int16 (Int.repr 6) :: Init_int16 (Int.repr 5) ::
                Init_int16 (Int.repr 3) :: Init_int16 (Int.repr 1) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr (-1)) ::
                Init_int16 (Int.repr (-3)) :: Init_int16 (Int.repr (-4)) ::
                Init_int16 (Int.repr (-6)) :: Init_int16 (Int.repr (-7)) ::
                Init_int16 (Int.repr (-8)) :: Init_int16 (Int.repr (-8)) ::
                Init_int16 (Int.repr 162) :: Init_int16 (Int.repr 163) ::
                Init_int16 (Int.repr 166) :: Init_int16 (Int.repr 170) ::
                Init_int16 (Int.repr 173) :: Init_int16 (Int.repr 174) ::
                Init_int16 (Int.repr 173) :: Init_int16 (Int.repr 171) ::
                Init_int16 (Int.repr 168) :: Init_int16 (Int.repr 165) ::
                Init_int16 (Int.repr 163) :: Init_int16 (Int.repr 162) ::
                Init_int16 (Int.repr 163) :: Init_int16 (Int.repr 165) ::
                Init_int16 (Int.repr 168) :: Init_int16 (Int.repr 171) ::
                Init_int16 (Int.repr 173) :: Init_int16 (Int.repr 174) ::
                Init_int16 (Int.repr 173) :: Init_int16 (Int.repr 171) ::
                Init_int16 (Int.repr 169) :: Init_int16 (Int.repr 167) ::
                Init_int16 (Int.repr 164) :: Init_int16 (Int.repr 163) ::
                Init_int16 (Int.repr 162) :: Init_int16 (Int.repr 16383) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr (-4)) ::
                Init_int16 (Int.repr (-14)) :: Init_int16 (Int.repr (-28)) ::
                Init_int16 (Int.repr (-45)) :: Init_int16 (Int.repr (-60)) ::
                Init_int16 (Int.repr (-72)) :: Init_int16 (Int.repr (-78)) ::
                Init_int16 (Int.repr (-77)) :: Init_int16 (Int.repr (-65)) ::
                Init_int16 (Int.repr (-40)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 131) :: Init_int16 (Int.repr 363) ::
                Init_int16 (Int.repr 596) :: Init_int16 (Int.repr 730) ::
                Init_int16 (Int.repr 724) :: Init_int16 (Int.repr 638) ::
                Init_int16 (Int.repr 518) :: Init_int16 (Int.repr 413) ::
                Init_int16 (Int.repr 318) :: Init_int16 (Int.repr 209) ::
                Init_int16 (Int.repr 106) :: Init_int16 (Int.repr 30) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr (-2)) ::
                Init_int16 (Int.repr (-6)) :: Init_int16 (Int.repr (-7)) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 22) ::
                Init_int16 (Int.repr 56) :: Init_int16 (Int.repr 87) ::
                Init_int16 (Int.repr 101) :: Init_int16 (Int.repr 90) ::
                Init_int16 (Int.repr 65) :: Init_int16 (Int.repr 35) ::
                Init_int16 (Int.repr 10) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr (-22954)) ::
                Init_int16 (Int.repr (-22814)) ::
                Init_int16 (Int.repr (-22423)) ::
                Init_int16 (Int.repr (-21823)) ::
                Init_int16 (Int.repr (-21057)) ::
                Init_int16 (Int.repr (-20168)) ::
                Init_int16 (Int.repr (-19197)) ::
                Init_int16 (Int.repr (-18187)) ::
                Init_int16 (Int.repr (-17181)) ::
                Init_int16 (Int.repr (-16221)) ::
                Init_int16 (Int.repr (-15350)) ::
                Init_int16 (Int.repr (-14610)) ::
                Init_int16 (Int.repr (-13858)) ::
                Init_int16 (Int.repr (-13134)) ::
                Init_int16 (Int.repr (-12759)) ::
                Init_int16 (Int.repr (-13052)) ::
                Init_int16 (Int.repr (-14418)) ::
                Init_int16 (Int.repr (-16580)) ::
                Init_int16 (Int.repr (-18833)) ::
                Init_int16 (Int.repr (-20475)) ::
                Init_int16 (Int.repr (-21437)) ::
                Init_int16 (Int.repr (-22140)) ::
                Init_int16 (Int.repr (-22609)) ::
                Init_int16 (Int.repr (-22872)) ::
                Init_int16 (Int.repr (-22954)) ::
                Init_int16 (Int.repr (-14401)) ::
                Init_int16 (Int.repr (-13741)) ::
                Init_int16 (Int.repr (-12568)) ::
                Init_int16 (Int.repr (-12090)) ::
                Init_int16 (Int.repr (-13555)) ::
                Init_int16 (Int.repr (-15771)) ::
                Init_int16 (Int.repr (-17653)) ::
                Init_int16 (Int.repr (-19507)) ::
                Init_int16 (Int.repr (-20969)) ::
                Init_int16 (Int.repr (-22003)) ::
                Init_int16 (Int.repr (-22644)) ::
                Init_int16 (Int.repr (-22641)) ::
                Init_int16 (Int.repr (-22153)) ::
                Init_int16 (Int.repr (-21528)) ::
                Init_int16 (Int.repr (-20798)) ::
                Init_int16 (Int.repr (-19994)) ::
                Init_int16 (Int.repr (-19145)) ::
                Init_int16 (Int.repr (-18282)) ::
                Init_int16 (Int.repr (-17435)) ::
                Init_int16 (Int.repr (-16635)) ::
                Init_int16 (Int.repr (-15912)) ::
                Init_int16 (Int.repr (-15297)) ::
                Init_int16 (Int.repr (-14819)) ::
                Init_int16 (Int.repr (-14511)) ::
                Init_int16 (Int.repr (-14401)) ::
                Init_int16 (Int.repr 26917) :: Init_int16 (Int.repr 26483) ::
                Init_int16 (Int.repr 25290) :: Init_int16 (Int.repr 23509) ::
                Init_int16 (Int.repr 21307) :: Init_int16 (Int.repr 18852) ::
                Init_int16 (Int.repr 16313) :: Init_int16 (Int.repr 13858) ::
                Init_int16 (Int.repr 11656) :: Init_int16 (Int.repr 9875) ::
                Init_int16 (Int.repr 8682) :: Init_int16 (Int.repr 8248) ::
                Init_int16 (Int.repr 8562) :: Init_int16 (Int.repr 9437) ::
                Init_int16 (Int.repr 10771) :: Init_int16 (Int.repr 12462) ::
                Init_int16 (Int.repr 14408) :: Init_int16 (Int.repr 16507) ::
                Init_int16 (Int.repr 18657) :: Init_int16 (Int.repr 20756) ::
                Init_int16 (Int.repr 22702) :: Init_int16 (Int.repr 24393) ::
                Init_int16 (Int.repr 25728) :: Init_int16 (Int.repr 26603) ::
                Init_int16 (Int.repr 26917) :: Init_int16 (Int.repr 8456) ::
                Init_int16 (Int.repr 8845) :: Init_int16 (Int.repr 9911) ::
                Init_int16 (Int.repr 11503) :: Init_int16 (Int.repr 13471) ::
                Init_int16 (Int.repr 15666) :: Init_int16 (Int.repr 17935) ::
                Init_int16 (Int.repr 20129) :: Init_int16 (Int.repr 22098) ::
                Init_int16 (Int.repr 23690) :: Init_int16 (Int.repr 24756) ::
                Init_int16 (Int.repr 25144) :: Init_int16 (Int.repr 24863) ::
                Init_int16 (Int.repr 24081) :: Init_int16 (Int.repr 22888) ::
                Init_int16 (Int.repr 21377) :: Init_int16 (Int.repr 19637) ::
                Init_int16 (Int.repr 17761) :: Init_int16 (Int.repr 15839) ::
                Init_int16 (Int.repr 13963) :: Init_int16 (Int.repr 12224) ::
                Init_int16 (Int.repr 10712) :: Init_int16 (Int.repr 9520) ::
                Init_int16 (Int.repr 8737) :: Init_int16 (Int.repr 8456) ::
                Init_int16 (Int.repr 518) :: Init_int16 (Int.repr 477) ::
                Init_int16 (Int.repr 370) :: Init_int16 (Int.repr 225) ::
                Init_int16 (Int.repr 68) :: Init_int16 (Int.repr (-72)) ::
                Init_int16 (Int.repr (-217)) ::
                Init_int16 (Int.repr (-385)) ::
                Init_int16 (Int.repr (-555)) ::
                Init_int16 (Int.repr (-705)) ::
                Init_int16 (Int.repr (-810)) ::
                Init_int16 (Int.repr (-848)) ::
                Init_int16 (Int.repr (-815)) ::
                Init_int16 (Int.repr (-729)) ::
                Init_int16 (Int.repr (-605)) ::
                Init_int16 (Int.repr (-459)) ::
                Init_int16 (Int.repr (-307)) ::
                Init_int16 (Int.repr (-162)) ::
                Init_int16 (Int.repr (-40)) :: Init_int16 (Int.repr 74) ::
                Init_int16 (Int.repr 198) :: Init_int16 (Int.repr 318) ::
                Init_int16 (Int.repr 420) :: Init_int16 (Int.repr 492) ::
                Init_int16 (Int.repr 518) :: Init_int16 (Int.repr 52) ::
                Init_int16 (Int.repr 48) :: Init_int16 (Int.repr 39) ::
                Init_int16 (Int.repr 26) :: Init_int16 (Int.repr 11) ::
                Init_int16 (Int.repr (-2)) :: Init_int16 (Int.repr (-18)) ::
                Init_int16 (Int.repr (-37)) :: Init_int16 (Int.repr (-57)) ::
                Init_int16 (Int.repr (-75)) :: Init_int16 (Int.repr (-88)) ::
                Init_int16 (Int.repr (-93)) :: Init_int16 (Int.repr (-90)) ::
                Init_int16 (Int.repr (-80)) :: Init_int16 (Int.repr (-66)) ::
                Init_int16 (Int.repr (-49)) :: Init_int16 (Int.repr (-32)) ::
                Init_int16 (Int.repr (-16)) :: Init_int16 (Int.repr (-2)) ::
                Init_int16 (Int.repr 8) :: Init_int16 (Int.repr 21) ::
                Init_int16 (Int.repr 32) :: Init_int16 (Int.repr 42) ::
                Init_int16 (Int.repr 49) :: Init_int16 (Int.repr 52) ::
                Init_int16 (Int.repr 31725) :: Init_int16 (Int.repr 31852) ::
                Init_int16 (Int.repr 32154) :: Init_int16 (Int.repr 32514) ::
                Init_int16 (Int.repr (-32720)) ::
                Init_int16 (Int.repr (-32601)) ::
                Init_int16 (Int.repr (-32704)) ::
                Init_int16 (Int.repr 32584) :: Init_int16 (Int.repr 32270) ::
                Init_int16 (Int.repr 31958) :: Init_int16 (Int.repr 31718) ::
                Init_int16 (Int.repr 31623) :: Init_int16 (Int.repr 31696) ::
                Init_int16 (Int.repr 31882) :: Init_int16 (Int.repr 32137) ::
                Init_int16 (Int.repr 32415) :: Init_int16 (Int.repr 32672) ::
                Init_int16 (Int.repr (-32671)) ::
                Init_int16 (Int.repr (-32592)) ::
                Init_int16 (Int.repr (-32677)) ::
                Init_int16 (Int.repr 32633) :: Init_int16 (Int.repr 32339) ::
                Init_int16 (Int.repr 32044) :: Init_int16 (Int.repr 31816) ::
                Init_int16 (Int.repr 31725) :: Init_int16 (Int.repr 0) ::
                nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bobomb_seg8_animindex_08023754 := {|
  gvar_info := (tarray tushort 84);
  gvar_init := (Init_int16 (Int.repr 25) :: Init_int16 (Int.repr 1) ::
                Init_int16 (Int.repr 25) :: Init_int16 (Int.repr 26) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 51) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 25) :: Init_int16 (Int.repr 202) ::
                Init_int16 (Int.repr 25) :: Init_int16 (Int.repr 227) ::
                Init_int16 (Int.repr 25) :: Init_int16 (Int.repr 252) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 25) :: Init_int16 (Int.repr 152) ::
                Init_int16 (Int.repr 25) :: Init_int16 (Int.repr 52) ::
                Init_int16 (Int.repr 25) :: Init_int16 (Int.repr 77) ::
                Init_int16 (Int.repr 25) :: Init_int16 (Int.repr 102) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 25) :: Init_int16 (Int.repr 177) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 25) :: Init_int16 (Int.repr 127) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bobomb_seg8_anim_080237FC := {|
  gvar_info := (Tstruct _Animation noattr);
  gvar_init := (Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 25) :: Init_int16 (Int.repr 13) ::
                Init_addrof _bobomb_seg8_animvalue_08023528 (Ptrofs.repr 0) ::
                Init_addrof _bobomb_seg8_animindex_08023754 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bobomb_seg8_animvalue_08023814 := {|
  gvar_info := (tarray tshort 76);
  gvar_init := (Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 177) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 2) ::
                Init_int16 (Int.repr 8) :: Init_int16 (Int.repr 14) ::
                Init_int16 (Int.repr 16) :: Init_int16 (Int.repr 14) ::
                Init_int16 (Int.repr 10) :: Init_int16 (Int.repr 5) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 16383) :: Init_int16 (Int.repr 4067) ::
                Init_int16 (Int.repr 4100) :: Init_int16 (Int.repr 4172) ::
                Init_int16 (Int.repr 4243) :: Init_int16 (Int.repr 4276) ::
                Init_int16 (Int.repr 4254) :: Init_int16 (Int.repr 4202) ::
                Init_int16 (Int.repr 4141) :: Init_int16 (Int.repr 4089) ::
                Init_int16 (Int.repr 4067) ::
                Init_int16 (Int.repr (-17426)) ::
                Init_int16 (Int.repr (-16643)) ::
                Init_int16 (Int.repr (-14923)) ::
                Init_int16 (Int.repr (-13202)) ::
                Init_int16 (Int.repr (-12419)) ::
                Init_int16 (Int.repr (-12940)) ::
                Init_int16 (Int.repr (-14182)) ::
                Init_int16 (Int.repr (-15664)) ::
                Init_int16 (Int.repr (-16905)) ::
                Init_int16 (Int.repr (-17426)) ::
                Init_int16 (Int.repr (-987)) ::
                Init_int16 (Int.repr (-662)) :: Init_int16 (Int.repr 50) ::
                Init_int16 (Int.repr 763) :: Init_int16 (Int.repr 1088) ::
                Init_int16 (Int.repr 872) :: Init_int16 (Int.repr 357) ::
                Init_int16 (Int.repr (-256)) ::
                Init_int16 (Int.repr (-771)) ::
                Init_int16 (Int.repr (-987)) ::
                Init_int16 (Int.repr (-3844)) ::
                Init_int16 (Int.repr (-4175)) ::
                Init_int16 (Int.repr (-4903)) ::
                Init_int16 (Int.repr (-5630)) ::
                Init_int16 (Int.repr (-5961)) ::
                Init_int16 (Int.repr (-5741)) ::
                Init_int16 (Int.repr (-5216)) ::
                Init_int16 (Int.repr (-4589)) ::
                Init_int16 (Int.repr (-4064)) ::
                Init_int16 (Int.repr (-3844)) ::
                Init_int16 (Int.repr (-10047)) ::
                Init_int16 (Int.repr (-11446)) ::
                Init_int16 (Int.repr (-14524)) ::
                Init_int16 (Int.repr (-17601)) ::
                Init_int16 (Int.repr (-19000)) ::
                Init_int16 (Int.repr (-18069)) ::
                Init_int16 (Int.repr (-15849)) ::
                Init_int16 (Int.repr (-13199)) ::
                Init_int16 (Int.repr (-10978)) ::
                Init_int16 (Int.repr (-10047)) ::
                Init_int16 (Int.repr 16383) :: Init_int16 (Int.repr 16383) ::
                Init_int16 (Int.repr 29950) :: Init_int16 (Int.repr 30293) ::
                Init_int16 (Int.repr 31046) :: Init_int16 (Int.repr 31798) ::
                Init_int16 (Int.repr 32141) :: Init_int16 (Int.repr 31913) ::
                Init_int16 (Int.repr 31370) :: Init_int16 (Int.repr 30721) ::
                Init_int16 (Int.repr 30178) :: Init_int16 (Int.repr 29950) ::
                Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bobomb_seg8_animindex_080238AC := {|
  gvar_info := (tarray tushort 84);
  gvar_init := (Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 1) ::
                Init_int16 (Int.repr 10) :: Init_int16 (Int.repr 2) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 12) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 10) :: Init_int16 (Int.repr 65) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 63) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 10) :: Init_int16 (Int.repr 13) ::
                Init_int16 (Int.repr 10) :: Init_int16 (Int.repr 23) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 64) ::
                Init_int16 (Int.repr 10) :: Init_int16 (Int.repr 33) ::
                Init_int16 (Int.repr 10) :: Init_int16 (Int.repr 43) ::
                Init_int16 (Int.repr 10) :: Init_int16 (Int.repr 53) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bobomb_seg8_anim_08023954 := {|
  gvar_info := (Tstruct _Animation noattr);
  gvar_init := (Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 10) :: Init_int16 (Int.repr 13) ::
                Init_addrof _bobomb_seg8_animvalue_08023814 (Ptrofs.repr 0) ::
                Init_addrof _bobomb_seg8_animindex_080238AC (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bobomb_seg8_anims_0802396C := {|
  gvar_info := (tarray (tptr (Tstruct _Animation noattr)) 3);
  gvar_init := (Init_addrof _bobomb_seg8_anim_080237FC (Ptrofs.repr 0) ::
                Init_addrof _bobomb_seg8_anim_08023954 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 0) :: nil);
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
 (_bobomb_seg8_animvalue_08023528, Gvar v_bobomb_seg8_animvalue_08023528) ::
 (_bobomb_seg8_animindex_08023754, Gvar v_bobomb_seg8_animindex_08023754) ::
 (_bobomb_seg8_anim_080237FC, Gvar v_bobomb_seg8_anim_080237FC) ::
 (_bobomb_seg8_animvalue_08023814, Gvar v_bobomb_seg8_animvalue_08023814) ::
 (_bobomb_seg8_animindex_080238AC, Gvar v_bobomb_seg8_animindex_080238AC) ::
 (_bobomb_seg8_anim_08023954, Gvar v_bobomb_seg8_anim_08023954) ::
 (_bobomb_seg8_anims_0802396C, Gvar v_bobomb_seg8_anims_0802396C) :: nil).

Definition public_idents : list ident :=
(_bobomb_seg8_anims_0802396C :: ___builtin_debug ::
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


