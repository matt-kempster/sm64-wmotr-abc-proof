(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_US
   Source:          levels/ttc/geo.c
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1
   Link hygiene:    private __stringlit_N atoms prefixed with us_ttc_geo
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
  Definition source_file := "build/pinned-sm64/levels/ttc/geo.c".
  Definition normalized := true.
End Info.

Definition _GraphNode : ident := $"GraphNode".
Definition __469 : ident := $"_469".
Definition __510 : ident := $"_510".
Definition __512 : ident := $"_512".
Definition __514 : ident := $"_514".
Definition __516 : ident := $"_516".
Definition __518 : ident := $"_518".
Definition __520 : ident := $"_520".
Definition __522 : ident := $"_522".
Definition __524 : ident := $"_524".
Definition __526 : ident := $"_526".
Definition __528 : ident := $"_528".
Definition __530 : ident := $"_530".
Definition __532 : ident := $"_532".
Definition __534 : ident := $"_534".
Definition __536 : ident := $"_536".
Definition __538 : ident := $"_538".
Definition __547 : ident := $"_547".
Definition __549 : ident := $"_549".
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
Definition _addr : ident := $"addr".
Definition _base : ident := $"base".
Definition _children : ident := $"children".
Definition _cmd : ident := $"cmd".
Definition _color : ident := $"color".
Definition _cs : ident := $"cs".
Definition _ct : ident := $"ct".
Definition _data : ident := $"data".
Definition _dma : ident := $"dma".
Definition _dram : ident := $"dram".
Definition _fillrect : ident := $"fillrect".
Definition _flag : ident := $"flag".
Definition _flags : ident := $"flags".
Definition _fmt : ident := $"fmt".
Definition _force_structure_alignment : ident := $"force_structure_alignment".
Definition _geo_camera_fov : ident := $"geo_camera_fov".
Definition _geo_camera_main : ident := $"geo_camera_main".
Definition _geo_envfx_main : ident := $"geo_envfx_main".
Definition _geo_movtex_draw_colored_no_update : ident := $"geo_movtex_draw_colored_no_update".
Definition _geo_movtex_pause_control : ident := $"geo_movtex_pause_control".
Definition _geo_movtex_update_horizontal : ident := $"geo_movtex_update_horizontal".
Definition _len : ident := $"len".
Definition _line : ident := $"line".
Definition _loadtile : ident := $"loadtile".
Definition _loadtlut : ident := $"loadtlut".
Definition _lodscale : ident := $"lodscale".
Definition _main : ident := $"main".
Definition _masks : ident := $"masks".
Definition _maskt : ident := $"maskt".
Definition _ms : ident := $"ms".
Definition _mt : ident := $"mt".
Definition _muxs0 : ident := $"muxs0".
Definition _muxs1 : ident := $"muxs1".
Definition _mw_index : ident := $"mw_index".
Definition _next : ident := $"next".
Definition _number : ident := $"number".
Definition _on : ident := $"on".
Definition _pad : ident := $"pad".
Definition _pad0 : ident := $"pad0".
Definition _pad1 : ident := $"pad1".
Definition _pad2 : ident := $"pad2".
Definition _palette : ident := $"palette".
Definition _par : ident := $"par".
Definition _param : ident := $"param".
Definition _parent : ident := $"parent".
Definition _perspnorm : ident := $"perspnorm".
Definition _popmtx : ident := $"popmtx".
Definition _prev : ident := $"prev".
Definition _prim_level : ident := $"prim_level".
Definition _prim_min_level : ident := $"prim_min_level".
Definition _s : ident := $"s".
Definition _scale : ident := $"scale".
Definition _segment : ident := $"segment".
Definition _setcolor : ident := $"setcolor".
Definition _setcombine : ident := $"setcombine".
Definition _setimg : ident := $"setimg".
Definition _setothermodeH : ident := $"setothermodeH".
Definition _setothermodeL : ident := $"setothermodeL".
Definition _settile : ident := $"settile".
Definition _settilesize : ident := $"settilesize".
Definition _sft : ident := $"sft".
Definition _sh : ident := $"sh".
Definition _shifts : ident := $"shifts".
Definition _shiftt : ident := $"shiftt".
Definition _siz : ident := $"siz".
Definition _sl : ident := $"sl".
Definition _t : ident := $"t".
Definition _texture : ident := $"texture".
Definition _th : ident := $"th".
Definition _tile : ident := $"tile".
Definition _tl : ident := $"tl".
Definition _tmem : ident := $"tmem".
Definition _tri : ident := $"tri".
Definition _ttc_geo_000240 : ident := $"ttc_geo_000240".
Definition _ttc_geo_000258 : ident := $"ttc_geo_000258".
Definition _ttc_geo_000270 : ident := $"ttc_geo_000270".
Definition _ttc_geo_000288 : ident := $"ttc_geo_000288".
Definition _ttc_geo_0002A8 : ident := $"ttc_geo_0002A8".
Definition _ttc_geo_0002C8 : ident := $"ttc_geo_0002C8".
Definition _ttc_geo_0002E0 : ident := $"ttc_geo_0002E0".
Definition _ttc_geo_0002F8 : ident := $"ttc_geo_0002F8".
Definition _ttc_geo_000310 : ident := $"ttc_geo_000310".
Definition _ttc_geo_000328 : ident := $"ttc_geo_000328".
Definition _ttc_geo_000340 : ident := $"ttc_geo_000340".
Definition _ttc_geo_000358 : ident := $"ttc_geo_000358".
Definition _ttc_geo_000370 : ident := $"ttc_geo_000370".
Definition _ttc_geo_000388 : ident := $"ttc_geo_000388".
Definition _ttc_geo_0003A0 : ident := $"ttc_geo_0003A0".
Definition _ttc_geo_0003B8 : ident := $"ttc_geo_0003B8".
Definition _ttc_seg7_dl_0700AD38 : ident := $"ttc_seg7_dl_0700AD38".
Definition _ttc_seg7_dl_0700B1D8 : ident := $"ttc_seg7_dl_0700B1D8".
Definition _ttc_seg7_dl_0700E878 : ident := $"ttc_seg7_dl_0700E878".
Definition _ttc_seg7_dl_0700ECB8 : ident := $"ttc_seg7_dl_0700ECB8".
Definition _ttc_seg7_dl_0700EFE0 : ident := $"ttc_seg7_dl_0700EFE0".
Definition _ttc_seg7_dl_0700F760 : ident := $"ttc_seg7_dl_0700F760".
Definition _ttc_seg7_dl_0700FBB8 : ident := $"ttc_seg7_dl_0700FBB8".
Definition _ttc_seg7_dl_0700FFE8 : ident := $"ttc_seg7_dl_0700FFE8".
Definition _ttc_seg7_dl_070102B8 : ident := $"ttc_seg7_dl_070102B8".
Definition _ttc_seg7_dl_07010868 : ident := $"ttc_seg7_dl_07010868".
Definition _ttc_seg7_dl_07010D38 : ident := $"ttc_seg7_dl_07010D38".
Definition _ttc_seg7_dl_07011040 : ident := $"ttc_seg7_dl_07011040".
Definition _ttc_seg7_dl_07011360 : ident := $"ttc_seg7_dl_07011360".
Definition _ttc_seg7_dl_070116A8 : ident := $"ttc_seg7_dl_070116A8".
Definition _ttc_seg7_dl_07011B38 : ident := $"ttc_seg7_dl_07011B38".
Definition _ttc_seg7_dl_07012028 : ident := $"ttc_seg7_dl_07012028".
Definition _ttc_seg7_dl_07012148 : ident := $"ttc_seg7_dl_07012148".
Definition _ttc_seg7_dl_07012278 : ident := $"ttc_seg7_dl_07012278".
Definition _type : ident := $"type".
Definition _v : ident := $"v".
Definition _w0 : ident := $"w0".
Definition _w1 : ident := $"w1".
Definition _wd : ident := $"wd".
Definition _words : ident := $"words".
Definition _x0 : ident := $"x0".
Definition _x0frac : ident := $"x0frac".
Definition _x1 : ident := $"x1".
Definition _x1frac : ident := $"x1frac".
Definition _y0 : ident := $"y0".
Definition _y0frac : ident := $"y0frac".
Definition _y1 : ident := $"y1".
Definition _y1frac : ident := $"y1frac".

Definition v_ttc_seg7_dl_0700AD38 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_seg7_dl_0700B1D8 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_seg7_dl_0700E878 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_seg7_dl_0700ECB8 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_seg7_dl_0700EFE0 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_seg7_dl_0700F760 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_seg7_dl_0700FBB8 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_seg7_dl_0700FFE8 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_seg7_dl_070102B8 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_seg7_dl_07010868 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_seg7_dl_07010D38 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_seg7_dl_07011040 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_seg7_dl_07011360 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_seg7_dl_070116A8 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_seg7_dl_07011B38 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_seg7_dl_07012028 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_seg7_dl_07012148 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_seg7_dl_07012278 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_geo_000240 := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 536871322) ::
                Init_int32 (Int.repr 67108864) ::
                Init_int32 (Int.repr 352387072) ::
                Init_addrof _ttc_seg7_dl_0700ECB8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 83886080) ::
                Init_int32 (Int.repr 16777216) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_geo_000258 := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 536871322) ::
                Init_int32 (Int.repr 67108864) ::
                Init_int32 (Int.repr 352387072) ::
                Init_addrof _ttc_seg7_dl_0700EFE0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 83886080) ::
                Init_int32 (Int.repr 16777216) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_geo_000270 := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 536872012) ::
                Init_int32 (Int.repr 67108864) ::
                Init_int32 (Int.repr 352387072) ::
                Init_addrof _ttc_seg7_dl_0700F760 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 83886080) ::
                Init_int32 (Int.repr 16777216) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_geo_000288 := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 536871632) ::
                Init_int32 (Int.repr 67108864) ::
                Init_int32 (Int.repr 352387072) ::
                Init_addrof _ttc_seg7_dl_0700FBB8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 402658304) ::
                Init_addrof _geo_movtex_draw_colored_no_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 83886080) ::
                Init_int32 (Int.repr 16777216) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_geo_0002A8 := {|
  gvar_info := (tarray tuint 8);
  gvar_init := (Init_int32 (Int.repr 536871432) ::
                Init_int32 (Int.repr 67108864) ::
                Init_int32 (Int.repr 352387072) ::
                Init_addrof _ttc_seg7_dl_0700FFE8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 402658305) ::
                Init_addrof _geo_movtex_draw_colored_no_update (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 83886080) ::
                Init_int32 (Int.repr 16777216) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_geo_0002C8 := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 536871412) ::
                Init_int32 (Int.repr 67108864) ::
                Init_int32 (Int.repr 352387072) ::
                Init_addrof _ttc_seg7_dl_070102B8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 83886080) ::
                Init_int32 (Int.repr 16777216) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_geo_0002E0 := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 536871312) ::
                Init_int32 (Int.repr 67108864) ::
                Init_int32 (Int.repr 352387072) ::
                Init_addrof _ttc_seg7_dl_07010868 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 83886080) ::
                Init_int32 (Int.repr 16777216) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_geo_0002F8 := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 536871432) ::
                Init_int32 (Int.repr 67108864) ::
                Init_int32 (Int.repr 352387072) ::
                Init_addrof _ttc_seg7_dl_07010D38 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 83886080) ::
                Init_int32 (Int.repr 16777216) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_geo_000310 := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 536871162) ::
                Init_int32 (Int.repr 67108864) ::
                Init_int32 (Int.repr 352387072) ::
                Init_addrof _ttc_seg7_dl_07011040 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 83886080) ::
                Init_int32 (Int.repr 16777216) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_geo_000328 := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 536871162) ::
                Init_int32 (Int.repr 67108864) ::
                Init_int32 (Int.repr 352387072) ::
                Init_addrof _ttc_seg7_dl_07011360 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 83886080) ::
                Init_int32 (Int.repr 16777216) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_geo_000340 := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 536871292) ::
                Init_int32 (Int.repr 67108864) ::
                Init_int32 (Int.repr 352387072) ::
                Init_addrof _ttc_seg7_dl_070116A8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 83886080) ::
                Init_int32 (Int.repr 16777216) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_geo_000358 := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 536872612) ::
                Init_int32 (Int.repr 67108864) ::
                Init_int32 (Int.repr 352387072) ::
                Init_addrof _ttc_seg7_dl_07011B38 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 83886080) ::
                Init_int32 (Int.repr 16777216) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_geo_000370 := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 536871412) ::
                Init_int32 (Int.repr 67108864) ::
                Init_int32 (Int.repr 352387072) ::
                Init_addrof _ttc_seg7_dl_07012028 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 83886080) ::
                Init_int32 (Int.repr 16777216) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_geo_000388 := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 536871112) ::
                Init_int32 (Int.repr 67108864) ::
                Init_int32 (Int.repr 352583680) ::
                Init_addrof _ttc_seg7_dl_07012148 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 83886080) ::
                Init_int32 (Int.repr 16777216) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_geo_0003A0 := {|
  gvar_info := (tarray tuint 6);
  gvar_init := (Init_int32 (Int.repr 536871212) ::
                Init_int32 (Int.repr 67108864) ::
                Init_int32 (Int.repr 352583680) ::
                Init_addrof _ttc_seg7_dl_07012278 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 83886080) ::
                Init_int32 (Int.repr 16777216) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ttc_geo_0003B8 := {|
  gvar_info := (tarray tuint 44);
  gvar_init := (Init_int32 (Int.repr 134217738) ::
                Init_int32 (Int.repr 10485880) ::
                Init_int32 (Int.repr 10485880) ::
                Init_int32 (Int.repr 67108864) ::
                Init_int32 (Int.repr 201326592) ::
                Init_int32 (Int.repr 67108864) ::
                Init_int32 (Int.repr 150995044) ::
                Init_int32 (Int.repr 67108864) ::
                Init_int32 (Int.repr 419481599) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 83886080) ::
                Init_int32 (Int.repr 83886080) ::
                Init_int32 (Int.repr 201392128) ::
                Init_int32 (Int.repr 67108864) ::
                Init_int32 (Int.repr 167837741) ::
                Init_int32 (Int.repr 6566400) ::
                Init_addrof _geo_camera_fov (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 67108864) ::
                Init_int32 (Int.repr 251658242) ::
                Init_int32 (Int.repr 2000) ::
                Init_int32 (Int.repr 393216000) :: Init_int32 (Int.repr 0) ::
                Init_addrof _geo_camera_main (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 67108864) ::
                Init_int32 (Int.repr 402653184) ::
                Init_addrof _geo_movtex_pause_control (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 402658304) ::
                Init_addrof _geo_movtex_update_horizontal (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 402658305) ::
                Init_addrof _geo_movtex_update_horizontal (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 352387072) ::
                Init_addrof _ttc_seg7_dl_0700AD38 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 352649216) ::
                Init_addrof _ttc_seg7_dl_0700B1D8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 352583680) ::
                Init_addrof _ttc_seg7_dl_0700E878 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 385875968) ::
                Init_int32 (Int.repr 402653184) ::
                Init_addrof _geo_envfx_main (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 83886080) ::
                Init_int32 (Int.repr 83886080) ::
                Init_int32 (Int.repr 83886080) ::
                Init_int32 (Int.repr 83886080) ::
                Init_int32 (Int.repr 16777216) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition composites : list composite_definition :=
(Composite __469 Struct
   (Member_plain _flag tuchar :: Member_plain _v (tarray tuchar 3) :: nil)
   noattr ::
 Composite __510 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _par I32 Unsigned noattr 8 false ::
    Member_bitfield _len I32 Unsigned noattr 16 false ::
    Member_plain _addr tuint :: nil)
   noattr ::
 Composite __512 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad I32 Signed noattr 24 false ::
    Member_plain _tri (Tstruct __469 noattr) :: nil)
   noattr ::
 Composite __514 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad1 I32 Signed noattr 24 false ::
    Member_bitfield _pad2 I32 Signed noattr 24 false ::
    Member_bitfield _param I8 Unsigned noattr 8 false :: nil)
   noattr ::
 Composite __516 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad0 I32 Signed noattr 8 false ::
    Member_bitfield _mw_index I32 Signed noattr 8 false ::
    Member_bitfield _number I32 Signed noattr 8 false ::
    Member_bitfield _pad1 I32 Signed noattr 8 false ::
    Member_bitfield _base I32 Signed noattr 24 false :: nil)
   noattr ::
 Composite __518 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad0 I32 Signed noattr 8 false ::
    Member_bitfield _sft I32 Signed noattr 8 false ::
    Member_bitfield _len I32 Signed noattr 8 false ::
    Member_bitfield _data I32 Unsigned noattr 32 false :: nil)
   noattr ::
 Composite __520 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad0 I32 Signed noattr 8 false ::
    Member_bitfield _sft I32 Signed noattr 8 false ::
    Member_bitfield _len I32 Signed noattr 8 false ::
    Member_bitfield _data I32 Unsigned noattr 32 false :: nil)
   noattr ::
 Composite __522 Struct
   (Member_plain _cmd tuchar :: Member_plain _lodscale tuchar ::
    Member_plain _tile tuchar :: Member_plain _on tuchar ::
    Member_plain _s tushort :: Member_plain _t tushort :: nil)
   noattr ::
 Composite __524 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad I32 Signed noattr 24 false ::
    Member_plain _line (Tstruct __469 noattr) :: nil)
   noattr ::
 Composite __526 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad1 I32 Signed noattr 24 false ::
    Member_plain _pad2 tshort :: Member_plain _scale tshort :: nil)
   noattr ::
 Composite __528 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _fmt I32 Unsigned noattr 3 false ::
    Member_bitfield _siz I32 Unsigned noattr 2 false ::
    Member_bitfield _pad I32 Unsigned noattr 7 false ::
    Member_bitfield _wd I32 Unsigned noattr 12 false ::
    Member_plain _dram tuint :: nil)
   noattr ::
 Composite __530 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _muxs0 I32 Unsigned noattr 24 false ::
    Member_bitfield _muxs1 I32 Unsigned noattr 32 false :: nil)
   noattr ::
 Composite __532 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_plain _pad tuchar :: Member_plain _prim_min_level tuchar ::
    Member_plain _prim_level tuchar :: Member_plain _color tuint :: nil)
   noattr ::
 Composite __534 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _x0 I32 Signed noattr 10 false ::
    Member_bitfield _x0frac I32 Signed noattr 2 false ::
    Member_bitfield _y0 I32 Signed noattr 10 false ::
    Member_bitfield _y0frac I32 Signed noattr 2 false ::
    Member_bitfield _pad I32 Unsigned noattr 8 false ::
    Member_bitfield _x1 I32 Signed noattr 10 false ::
    Member_bitfield _x1frac I32 Signed noattr 2 false ::
    Member_bitfield _y1 I32 Signed noattr 10 false ::
    Member_bitfield _y1frac I32 Signed noattr 2 false :: nil)
   noattr ::
 Composite __536 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _fmt I32 Unsigned noattr 3 false ::
    Member_bitfield _siz I32 Unsigned noattr 2 false ::
    Member_bitfield _pad0 I32 Unsigned noattr 1 false ::
    Member_bitfield _line I32 Unsigned noattr 9 false ::
    Member_bitfield _tmem I32 Unsigned noattr 9 false ::
    Member_bitfield _pad1 I32 Unsigned noattr 5 false ::
    Member_bitfield _tile I32 Unsigned noattr 3 false ::
    Member_bitfield _palette I32 Unsigned noattr 4 false ::
    Member_bitfield _ct I32 Unsigned noattr 1 false ::
    Member_bitfield _mt I32 Unsigned noattr 1 false ::
    Member_bitfield _maskt I32 Unsigned noattr 4 false ::
    Member_bitfield _shiftt I32 Unsigned noattr 4 false ::
    Member_bitfield _cs I32 Unsigned noattr 1 false ::
    Member_bitfield _ms I32 Unsigned noattr 1 false ::
    Member_bitfield _masks I32 Unsigned noattr 4 false ::
    Member_bitfield _shifts I32 Unsigned noattr 4 false :: nil)
   noattr ::
 Composite __538 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _sl I32 Unsigned noattr 12 false ::
    Member_bitfield _tl I32 Unsigned noattr 12 false ::
    Member_bitfield _pad I32 Signed noattr 5 false ::
    Member_bitfield _tile I32 Unsigned noattr 3 false ::
    Member_bitfield _sh I32 Unsigned noattr 12 false ::
    Member_bitfield _th I32 Unsigned noattr 12 false :: nil)
   noattr ::
 Composite __547 Struct
   (Member_plain _w0 tuint :: Member_plain _w1 tuint :: nil)
   noattr ::
 Composite __549 Union
   (Member_plain _words (Tstruct __547 noattr) ::
    Member_plain _dma (Tstruct __510 noattr) ::
    Member_plain _tri (Tstruct __512 noattr) ::
    Member_plain _line (Tstruct __524 noattr) ::
    Member_plain _popmtx (Tstruct __514 noattr) ::
    Member_plain _segment (Tstruct __516 noattr) ::
    Member_plain _setothermodeH (Tstruct __520 noattr) ::
    Member_plain _setothermodeL (Tstruct __518 noattr) ::
    Member_plain _texture (Tstruct __522 noattr) ::
    Member_plain _perspnorm (Tstruct __526 noattr) ::
    Member_plain _setimg (Tstruct __528 noattr) ::
    Member_plain _setcombine (Tstruct __530 noattr) ::
    Member_plain _setcolor (Tstruct __532 noattr) ::
    Member_plain _fillrect (Tstruct __534 noattr) ::
    Member_plain _settile (Tstruct __536 noattr) ::
    Member_plain _loadtile (Tstruct __538 noattr) ::
    Member_plain _settilesize (Tstruct __538 noattr) ::
    Member_plain _loadtlut (Tstruct __538 noattr) ::
    Member_plain _force_structure_alignment tlong :: nil)
   noattr ::
 Composite _GraphNode Struct
   (Member_plain _type tshort :: Member_plain _flags tshort ::
    Member_plain _prev (tptr (Tstruct _GraphNode noattr)) ::
    Member_plain _next (tptr (Tstruct _GraphNode noattr)) ::
    Member_plain _parent (tptr (Tstruct _GraphNode noattr)) ::
    Member_plain _children (tptr (Tstruct _GraphNode noattr)) :: nil)
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
 (_geo_envfx_main,
   Gfun(External (EF_external "geo_envfx_main"
                   (mksignature (AST.Xint :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xptr cc_default))
     (tint :: (tptr (Tstruct _GraphNode noattr)) ::
      (tptr (tarray tfloat 4)) :: nil) (tptr (Tunion __549 noattr))
     cc_default)) ::
 (_geo_camera_main,
   Gfun(External (EF_external "geo_camera_main"
                   (mksignature (AST.Xint :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xptr cc_default))
     (tint :: (tptr (Tstruct _GraphNode noattr)) :: (tptr tvoid) :: nil)
     (tptr (Tunion __549 noattr)) cc_default)) ::
 (_geo_camera_fov,
   Gfun(External (EF_external "geo_camera_fov"
                   (mksignature (AST.Xint :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xptr cc_default))
     (tint :: (tptr (Tstruct _GraphNode noattr)) :: (tptr tvoid) :: nil)
     (tptr (Tunion __549 noattr)) cc_default)) ::
 (_geo_movtex_pause_control,
   Gfun(External (EF_external "geo_movtex_pause_control"
                   (mksignature (AST.Xint :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xptr cc_default))
     (tint :: (tptr (Tstruct _GraphNode noattr)) ::
      (tptr (tarray tfloat 4)) :: nil) (tptr (Tunion __549 noattr))
     cc_default)) ::
 (_geo_movtex_update_horizontal,
   Gfun(External (EF_external "geo_movtex_update_horizontal"
                   (mksignature (AST.Xint :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xptr cc_default))
     (tint :: (tptr (Tstruct _GraphNode noattr)) ::
      (tptr (tarray tfloat 4)) :: nil) (tptr (Tunion __549 noattr))
     cc_default)) ::
 (_geo_movtex_draw_colored_no_update,
   Gfun(External (EF_external "geo_movtex_draw_colored_no_update"
                   (mksignature (AST.Xint :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xptr cc_default))
     (tint :: (tptr (Tstruct _GraphNode noattr)) ::
      (tptr (tarray tfloat 4)) :: nil) (tptr (Tunion __549 noattr))
     cc_default)) :: (_ttc_seg7_dl_0700AD38, Gvar v_ttc_seg7_dl_0700AD38) ::
 (_ttc_seg7_dl_0700B1D8, Gvar v_ttc_seg7_dl_0700B1D8) ::
 (_ttc_seg7_dl_0700E878, Gvar v_ttc_seg7_dl_0700E878) ::
 (_ttc_seg7_dl_0700ECB8, Gvar v_ttc_seg7_dl_0700ECB8) ::
 (_ttc_seg7_dl_0700EFE0, Gvar v_ttc_seg7_dl_0700EFE0) ::
 (_ttc_seg7_dl_0700F760, Gvar v_ttc_seg7_dl_0700F760) ::
 (_ttc_seg7_dl_0700FBB8, Gvar v_ttc_seg7_dl_0700FBB8) ::
 (_ttc_seg7_dl_0700FFE8, Gvar v_ttc_seg7_dl_0700FFE8) ::
 (_ttc_seg7_dl_070102B8, Gvar v_ttc_seg7_dl_070102B8) ::
 (_ttc_seg7_dl_07010868, Gvar v_ttc_seg7_dl_07010868) ::
 (_ttc_seg7_dl_07010D38, Gvar v_ttc_seg7_dl_07010D38) ::
 (_ttc_seg7_dl_07011040, Gvar v_ttc_seg7_dl_07011040) ::
 (_ttc_seg7_dl_07011360, Gvar v_ttc_seg7_dl_07011360) ::
 (_ttc_seg7_dl_070116A8, Gvar v_ttc_seg7_dl_070116A8) ::
 (_ttc_seg7_dl_07011B38, Gvar v_ttc_seg7_dl_07011B38) ::
 (_ttc_seg7_dl_07012028, Gvar v_ttc_seg7_dl_07012028) ::
 (_ttc_seg7_dl_07012148, Gvar v_ttc_seg7_dl_07012148) ::
 (_ttc_seg7_dl_07012278, Gvar v_ttc_seg7_dl_07012278) ::
 (_ttc_geo_000240, Gvar v_ttc_geo_000240) ::
 (_ttc_geo_000258, Gvar v_ttc_geo_000258) ::
 (_ttc_geo_000270, Gvar v_ttc_geo_000270) ::
 (_ttc_geo_000288, Gvar v_ttc_geo_000288) ::
 (_ttc_geo_0002A8, Gvar v_ttc_geo_0002A8) ::
 (_ttc_geo_0002C8, Gvar v_ttc_geo_0002C8) ::
 (_ttc_geo_0002E0, Gvar v_ttc_geo_0002E0) ::
 (_ttc_geo_0002F8, Gvar v_ttc_geo_0002F8) ::
 (_ttc_geo_000310, Gvar v_ttc_geo_000310) ::
 (_ttc_geo_000328, Gvar v_ttc_geo_000328) ::
 (_ttc_geo_000340, Gvar v_ttc_geo_000340) ::
 (_ttc_geo_000358, Gvar v_ttc_geo_000358) ::
 (_ttc_geo_000370, Gvar v_ttc_geo_000370) ::
 (_ttc_geo_000388, Gvar v_ttc_geo_000388) ::
 (_ttc_geo_0003A0, Gvar v_ttc_geo_0003A0) ::
 (_ttc_geo_0003B8, Gvar v_ttc_geo_0003B8) :: nil).

Definition public_idents : list ident :=
(_ttc_geo_0003B8 :: _ttc_geo_0003A0 :: _ttc_geo_000388 :: _ttc_geo_000370 ::
 _ttc_geo_000358 :: _ttc_geo_000340 :: _ttc_geo_000328 :: _ttc_geo_000310 ::
 _ttc_geo_0002F8 :: _ttc_geo_0002E0 :: _ttc_geo_0002C8 :: _ttc_geo_0002A8 ::
 _ttc_geo_000288 :: _ttc_geo_000270 :: _ttc_geo_000258 :: _ttc_geo_000240 ::
 _ttc_seg7_dl_07012278 :: _ttc_seg7_dl_07012148 :: _ttc_seg7_dl_07012028 ::
 _ttc_seg7_dl_07011B38 :: _ttc_seg7_dl_070116A8 :: _ttc_seg7_dl_07011360 ::
 _ttc_seg7_dl_07011040 :: _ttc_seg7_dl_07010D38 :: _ttc_seg7_dl_07010868 ::
 _ttc_seg7_dl_070102B8 :: _ttc_seg7_dl_0700FFE8 :: _ttc_seg7_dl_0700FBB8 ::
 _ttc_seg7_dl_0700F760 :: _ttc_seg7_dl_0700EFE0 :: _ttc_seg7_dl_0700ECB8 ::
 _ttc_seg7_dl_0700E878 :: _ttc_seg7_dl_0700B1D8 :: _ttc_seg7_dl_0700AD38 ::
 _geo_movtex_draw_colored_no_update :: _geo_movtex_update_horizontal ::
 _geo_movtex_pause_control :: _geo_camera_fov :: _geo_camera_main ::
 _geo_envfx_main :: ___builtin_debug :: ___builtin_sync_fetch_and_add ::
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
