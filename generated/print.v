(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Produced by: pipeline/clightgen.sh
   From source: vendor/sm64/src/game/print.c
   clightgen:   The CompCert CompCert AST generator, version 3.15
   Flags:       -normalize -nostdinc -fstruct-passing -Ivendor/sm64/include -Ivendor/sm64/build/us -Ivendor/sm64/build/us/include -Ivendor/sm64/src -Ivendor/sm64 -Ivendor/sm64/include/libc -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1 -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -include pipeline/proof_n64.h (+ __stringlit_ -> __stringlit_print_)
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
  Definition source_file := "vendor/sm64/src/game/print.c".
  Definition normalized := true.
End Info.

Definition _MemoryPool : ident := $"MemoryPool".
Definition _TextLabel : ident := $"TextLabel".
Definition __225 : ident := $"_anon_492449ad5917".
Definition __228 : ident := $"_anon_6379328cdf8f".
Definition __266 : ident := $"_anon_b68c7cd607b8".
Definition __268 : ident := $"_anon_cc23475d879a".
Definition __270 : ident := $"_anon_582ea1ea7a16".
Definition __272 : ident := $"_anon_1f056269c846".
Definition __274 : ident := $"_anon_e728cafb3139_0".
Definition __276 : ident := $"_anon_e728cafb3139_1".
Definition __278 : ident := $"_anon_082533b0d3da".
Definition __280 : ident := $"_anon_326d1d817e71".
Definition __282 : ident := $"_anon_93f6c6d42751".
Definition __284 : ident := $"_anon_7fe8a69a4b23".
Definition __286 : ident := $"_anon_4f0efebcc12b".
Definition __288 : ident := $"_anon_aa3f148f9bf1".
Definition __290 : ident := $"_anon_336f2d3e0b53".
Definition __292 : ident := $"_anon_5b5ce0cbc558".
Definition __294 : ident := $"_anon_f17a035c1639".
Definition __303 : ident := $"_anon_50f496f0a47e".
Definition __305 : ident := $"_anon_56e646c222b2".
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
Definition __g : ident := $"_g".
Definition __g__1 : ident := $"_g__1".
Definition __g__2 : ident := $"_g__2".
Definition __g__3 : ident := $"_g__3".
Definition _add_glyph_texture : ident := $"add_glyph_texture".
Definition _addr : ident := $"addr".
Definition _alloc_display_list : ident := $"alloc_display_list".
Definition _base : ident := $"base".
Definition _buffer : ident := $"buffer".
Definition _c : ident := $"c".
Definition _char_to_glyph_index : ident := $"char_to_glyph_index".
Definition _clip_to_bounds : ident := $"clip_to_bounds".
Definition _cmd : ident := $"cmd".
Definition _color : ident := $"color".
Definition _cs : ident := $"cs".
Definition _ct : ident := $"ct".
Definition _data : ident := $"data".
Definition _dest : ident := $"dest".
Definition _digit : ident := $"digit".
Definition _digits : ident := $"digits".
Definition _digitsLen : ident := $"digitsLen".
Definition _dl_hud_img_begin : ident := $"dl_hud_img_begin".
Definition _dl_hud_img_end : ident := $"dl_hud_img_end".
Definition _dl_hud_img_load_tex_block : ident := $"dl_hud_img_load_tex_block".
Definition _dma : ident := $"dma".
Definition _dram : ident := $"dram".
Definition _exponent : ident := $"exponent".
Definition _fillrect : ident := $"fillrect".
Definition _flag : ident := $"flag".
Definition _fmt : ident := $"fmt".
Definition _force_structure_alignment : ident := $"force_structure_alignment".
Definition _format_integer : ident := $"format_integer".
Definition _gDisplayListHead : ident := $"gDisplayListHead".
Definition _gEffectsMemoryPool : ident := $"gEffectsMemoryPool".
Definition _glyphIndex : ident := $"glyphIndex".
Definition _glyphs : ident := $"glyphs".
Definition _guOrtho : ident := $"guOrtho".
Definition _i : ident := $"i".
Definition _int_pow : ident := $"int_pow".
Definition _j : ident := $"j".
Definition _len : ident := $"len".
Definition _length : ident := $"length".
Definition _line : ident := $"line".
Definition _loadtile : ident := $"loadtile".
Definition _loadtlut : ident := $"loadtlut".
Definition _lodscale : ident := $"lodscale".
Definition _m : ident := $"m".
Definition _main : ident := $"main".
Definition _main_hud_lut : ident := $"main_hud_lut".
Definition _masks : ident := $"masks".
Definition _maskt : ident := $"maskt".
Definition _mem_pool_alloc : ident := $"mem_pool_alloc".
Definition _mem_pool_free : ident := $"mem_pool_free".
Definition _ms : ident := $"ms".
Definition _mt : ident := $"mt".
Definition _mtx : ident := $"mtx".
Definition _muxs0 : ident := $"muxs0".
Definition _muxs1 : ident := $"muxs1".
Definition _mw_index : ident := $"mw_index".
Definition _n : ident := $"n".
Definition _negative : ident := $"negative".
Definition _numDigits : ident := $"numDigits".
Definition _number : ident := $"number".
Definition _on : ident := $"on".
Definition _pad : ident := $"pad".
Definition _pad0 : ident := $"pad0".
Definition _pad1 : ident := $"pad1".
Definition _pad2 : ident := $"pad2".
Definition _palette : ident := $"palette".
Definition _par : ident := $"par".
Definition _param : ident := $"param".
Definition _parse_width_field : ident := $"parse_width_field".
Definition _perspnorm : ident := $"perspnorm".
Definition _popmtx : ident := $"popmtx".
Definition _pos : ident := $"pos".
Definition _powBase : ident := $"powBase".
Definition _prim_level : ident := $"prim_level".
Definition _prim_min_level : ident := $"prim_min_level".
Definition _print_text : ident := $"print_text".
Definition _print_text_centered : ident := $"print_text_centered".
Definition _print_text_fmt_int : ident := $"print_text_fmt_int".
Definition _rectBaseX : ident := $"rectBaseX".
Definition _rectBaseY : ident := $"rectBaseY".
Definition _rectX : ident := $"rectX".
Definition _rectY : ident := $"rectY".
Definition _render_text_labels : ident := $"render_text_labels".
Definition _render_textrect : ident := $"render_textrect".
Definition _result : ident := $"result".
Definition _s : ident := $"s".
Definition _sTextLabels : ident := $"sTextLabels".
Definition _sTextLabelsCount : ident := $"sTextLabelsCount".
Definition _scale : ident := $"scale".
Definition _segment : ident := $"segment".
Definition _segmented_to_virtual : ident := $"segmented_to_virtual".
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
Definition _srcIndex : ident := $"srcIndex".
Definition _str : ident := $"str".
Definition _t : ident := $"t".
Definition _texture : ident := $"texture".
Definition _th : ident := $"th".
Definition _tile : ident := $"tile".
Definition _tl : ident := $"tl".
Definition _tmem : ident := $"tmem".
Definition _totalLength : ident := $"totalLength".
Definition _tri : ident := $"tri".
Definition _unused1 : ident := $"unused1".
Definition _unused2 : ident := $"unused2".
Definition _v : ident := $"v".
Definition _w0 : ident := $"w0".
Definition _w1 : ident := $"w1".
Definition _wd : ident := $"wd".
Definition _width : ident := $"width".
Definition _words : ident := $"words".
Definition _x : ident := $"x".
Definition _x0 : ident := $"x0".
Definition _x0frac : ident := $"x0frac".
Definition _x1 : ident := $"x1".
Definition _x1frac : ident := $"x1frac".
Definition _y : ident := $"y".
Definition _y0 : ident := $"y0".
Definition _y0frac : ident := $"y0frac".
Definition _y1 : ident := $"y1".
Definition _y1frac : ident := $"y1frac".
Definition _zeroPad : ident := $"zeroPad".
Definition _t'1 : ident := 128%positive.
Definition _t'10 : ident := 137%positive.
Definition _t'11 : ident := 138%positive.
Definition _t'12 : ident := 139%positive.
Definition _t'13 : ident := 140%positive.
Definition _t'14 : ident := 141%positive.
Definition _t'15 : ident := 142%positive.
Definition _t'16 : ident := 143%positive.
Definition _t'17 : ident := 144%positive.
Definition _t'18 : ident := 145%positive.
Definition _t'19 : ident := 146%positive.
Definition _t'2 : ident := 129%positive.
Definition _t'20 : ident := 147%positive.
Definition _t'21 : ident := 148%positive.
Definition _t'22 : ident := 149%positive.
Definition _t'23 : ident := 150%positive.
Definition _t'24 : ident := 151%positive.
Definition _t'25 : ident := 152%positive.
Definition _t'26 : ident := 153%positive.
Definition _t'27 : ident := 154%positive.
Definition _t'28 : ident := 155%positive.
Definition _t'29 : ident := 156%positive.
Definition _t'3 : ident := 130%positive.
Definition _t'30 : ident := 157%positive.
Definition _t'31 : ident := 158%positive.
Definition _t'32 : ident := 159%positive.
Definition _t'33 : ident := 160%positive.
Definition _t'34 : ident := 161%positive.
Definition _t'35 : ident := 162%positive.
Definition _t'36 : ident := 163%positive.
Definition _t'37 : ident := 164%positive.
Definition _t'4 : ident := 131%positive.
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v_gEffectsMemoryPool := {|
  gvar_info := (tptr (Tstruct _MemoryPool noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDisplayListHead := {|
  gvar_info := (tptr (Tunion __305 noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_main_hud_lut := {|
  gvar_info := (tarray (tptr tuchar) 58);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_dl_hud_img_load_tex_block := {|
  gvar_info := (tarray (Tunion __305 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_dl_hud_img_begin := {|
  gvar_info := (tarray (Tunion __305 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_dl_hud_img_end := {|
  gvar_info := (tarray (Tunion __305 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sTextLabels := {|
  gvar_info := (tarray (tptr (Tstruct _TextLabel noattr)) 52);
  gvar_init := (Init_space 208 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sTextLabelsCount := {|
  gvar_info := tshort;
  gvar_init := (Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_int_pow := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_n, tint) :: (_exponent, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_result, tint) :: (_i, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _result (Econst_int (Int.repr 1) tint))
  (Ssequence
    (Ssequence
      (Sset _i (Econst_int (Int.repr 0) tint))
      (Sloop
        (Ssequence
          (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                         (Etempvar _exponent tint) tint)
            Sskip
            Sbreak)
          (Sset _result
            (Ebinop Omul (Etempvar _n tint) (Etempvar _result tint) tint)))
        (Sset _i
          (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint)
            tint))))
    (Sreturn (Some (Etempvar _result tint)))))
|}.

Definition f_format_integer := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_n, tint) :: (_base, tint) :: (_dest, (tptr tuchar)) ::
                (_totalLength, (tptr tint)) :: (_width, tuchar) ::
                (_zeroPad, tschar) :: nil);
  fn_vars := nil;
  fn_temps := ((_powBase, tuint) :: (_numDigits, tint) :: (_i, tint) ::
               (_len, tint) :: (_digit, tschar) :: (_negative, tschar) ::
               (_pad, tuchar) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'3, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _numDigits (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sset _len (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Sset _negative (Ecast (Econst_int (Int.repr 0) tint) tschar))
      (Ssequence
        (Sifthenelse (Ebinop Oeq (Etempvar _zeroPad tschar)
                       (Econst_int (Int.repr 1) tint) tint)
          (Sset _pad (Ecast (Econst_int (Int.repr 48) tint) tuchar))
          (Sset _pad
            (Ecast (Eunop Oneg (Econst_int (Int.repr 1) tint) tint) tuchar)))
        (Ssequence
          (Sifthenelse (Ebinop One (Etempvar _n tint)
                         (Econst_int (Int.repr 0) tint) tint)
            (Ssequence
              (Sifthenelse (Ebinop Olt (Etempvar _n tint)
                             (Econst_int (Int.repr 0) tint) tint)
                (Ssequence
                  (Sset _n (Eunop Oneg (Etempvar _n tint) tint))
                  (Sset _negative
                    (Ecast (Econst_int (Int.repr 1) tint) tschar)))
                Sskip)
              (Ssequence
                (Sloop
                  (Ssequence
                    Sskip
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'1)
                          (Evar _int_pow (Tfunction (tint :: tint :: nil)
                                           tint cc_default))
                          ((Etempvar _base tint) ::
                           (Etempvar _numDigits tint) :: nil))
                        (Sset _powBase (Etempvar _t'1 tint)))
                      (Ssequence
                        (Sifthenelse (Ebinop Ogt (Etempvar _powBase tuint)
                                       (Ecast (Etempvar _n tint) tuint) tint)
                          Sbreak
                          Sskip)
                        (Sset _numDigits
                          (Ebinop Oadd (Etempvar _numDigits tint)
                            (Econst_int (Int.repr 1) tint) tint)))))
                  Sskip)
                (Ssequence
                  (Sifthenelse (Ebinop Ogt (Etempvar _width tuchar)
                                 (Etempvar _numDigits tint) tint)
                    (Ssequence
                      (Ssequence
                        (Sset _len (Econst_int (Int.repr 0) tint))
                        (Sloop
                          (Ssequence
                            (Sifthenelse (Ebinop Olt (Etempvar _len tint)
                                           (Ebinop Osub
                                             (Etempvar _width tuchar)
                                             (Etempvar _numDigits tint) tint)
                                           tint)
                              Sskip
                              Sbreak)
                            (Sassign
                              (Ederef
                                (Ebinop Oadd (Etempvar _dest (tptr tuchar))
                                  (Etempvar _len tint) (tptr tuchar)) tuchar)
                              (Etempvar _pad tuchar)))
                          (Sset _len
                            (Ebinop Oadd (Etempvar _len tint)
                              (Econst_int (Int.repr 1) tint) tint))))
                      (Sifthenelse (Ebinop Oeq (Etempvar _negative tschar)
                                     (Econst_int (Int.repr 1) tint) tint)
                        (Sset _len
                          (Ebinop Osub (Etempvar _len tint)
                            (Econst_int (Int.repr 1) tint) tint))
                        Sskip))
                    Sskip)
                  (Ssequence
                    (Sifthenelse (Ebinop Oeq (Etempvar _negative tschar)
                                   (Econst_int (Int.repr 1) tint) tint)
                      (Ssequence
                        (Sassign
                          (Ederef
                            (Ebinop Oadd (Etempvar _dest (tptr tuchar))
                              (Etempvar _len tint) (tptr tuchar)) tuchar)
                          (Econst_int (Int.repr 77) tint))
                        (Sset _len
                          (Ebinop Oadd (Etempvar _len tint)
                            (Econst_int (Int.repr 1) tint) tint)))
                      Sskip)
                    (Ssequence
                      (Sset _i
                        (Ebinop Osub (Etempvar _numDigits tint)
                          (Econst_int (Int.repr 1) tint) tint))
                      (Sloop
                        (Ssequence
                          (Sifthenelse (Ebinop Oge (Etempvar _i tint)
                                         (Econst_int (Int.repr 0) tint) tint)
                            Sskip
                            Sbreak)
                          (Ssequence
                            (Ssequence
                              (Scall (Some _t'2)
                                (Evar _int_pow (Tfunction
                                                 (tint :: tint :: nil) tint
                                                 cc_default))
                                ((Etempvar _base tint) ::
                                 (Etempvar _i tint) :: nil))
                              (Sset _powBase (Etempvar _t'2 tint)))
                            (Ssequence
                              (Sset _digit
                                (Ecast
                                  (Ebinop Odiv (Etempvar _n tint)
                                    (Etempvar _powBase tuint) tuint) tschar))
                              (Ssequence
                                (Sifthenelse (Ebinop Olt
                                               (Etempvar _digit tschar)
                                               (Econst_int (Int.repr 10) tint)
                                               tint)
                                  (Sassign
                                    (Ederef
                                      (Ebinop Osub
                                        (Ebinop Oadd
                                          (Ebinop Oadd
                                            (Etempvar _dest (tptr tuchar))
                                            (Etempvar _len tint)
                                            (tptr tuchar))
                                          (Ebinop Osub
                                            (Etempvar _numDigits tint)
                                            (Econst_int (Int.repr 1) tint)
                                            tint) (tptr tuchar))
                                        (Etempvar _i tint) (tptr tuchar))
                                      tuchar)
                                    (Ebinop Oadd (Etempvar _digit tschar)
                                      (Econst_int (Int.repr 48) tint) tint))
                                  (Sassign
                                    (Ederef
                                      (Ebinop Osub
                                        (Ebinop Oadd
                                          (Ebinop Oadd
                                            (Etempvar _dest (tptr tuchar))
                                            (Etempvar _len tint)
                                            (tptr tuchar))
                                          (Ebinop Osub
                                            (Etempvar _numDigits tint)
                                            (Econst_int (Int.repr 1) tint)
                                            tint) (tptr tuchar))
                                        (Etempvar _i tint) (tptr tuchar))
                                      tuchar)
                                    (Ebinop Oadd (Etempvar _digit tschar)
                                      (Econst_int (Int.repr 55) tint) tint)))
                                (Sset _n
                                  (Ebinop Osub (Etempvar _n tint)
                                    (Ebinop Omul (Etempvar _digit tschar)
                                      (Etempvar _powBase tuint) tuint) tuint))))))
                        (Sset _i
                          (Ebinop Osub (Etempvar _i tint)
                            (Econst_int (Int.repr 1) tint) tint))))))))
            (Ssequence
              (Sset _numDigits (Econst_int (Int.repr 1) tint))
              (Ssequence
                (Sifthenelse (Ebinop Ogt (Etempvar _width tuchar)
                               (Etempvar _numDigits tint) tint)
                  (Ssequence
                    (Sset _len (Econst_int (Int.repr 0) tint))
                    (Sloop
                      (Ssequence
                        (Sifthenelse (Ebinop Olt (Etempvar _len tint)
                                       (Ebinop Osub (Etempvar _width tuchar)
                                         (Etempvar _numDigits tint) tint)
                                       tint)
                          Sskip
                          Sbreak)
                        (Sassign
                          (Ederef
                            (Ebinop Oadd (Etempvar _dest (tptr tuchar))
                              (Etempvar _len tint) (tptr tuchar)) tuchar)
                          (Etempvar _pad tuchar)))
                      (Sset _len
                        (Ebinop Oadd (Etempvar _len tint)
                          (Econst_int (Int.repr 1) tint) tint))))
                  Sskip)
                (Sassign
                  (Ederef
                    (Ebinop Oadd (Etempvar _dest (tptr tuchar))
                      (Etempvar _len tint) (tptr tuchar)) tuchar)
                  (Econst_int (Int.repr 48) tint)))))
          (Ssequence
            (Sset _t'3 (Ederef (Etempvar _totalLength (tptr tint)) tint))
            (Sassign (Ederef (Etempvar _totalLength (tptr tint)) tint)
              (Ebinop Oadd (Etempvar _t'3 tint)
                (Ebinop Oadd (Etempvar _numDigits tint) (Etempvar _len tint)
                  tint) tint))))))))
|}.

Definition f_parse_width_field := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_str, (tptr tuchar)) :: (_srcIndex, (tptr tint)) ::
                (_width, (tptr tuchar)) :: (_zeroPad, (tptr tschar)) :: nil);
  fn_vars := ((_digits, (tarray tschar 12)) :: nil);
  fn_temps := ((_digitsLen, tschar) :: (_i, tshort) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'17, tuchar) :: (_t'16, tint) ::
               (_t'15, tuchar) :: (_t'14, tint) :: (_t'13, tuchar) ::
               (_t'12, tint) :: (_t'11, tuchar) :: (_t'10, tint) ::
               (_t'9, tschar) :: (_t'8, tschar) :: (_t'7, tint) ::
               (_t'6, tschar) :: (_t'5, tuchar) :: (_t'4, tschar) ::
               (_t'3, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _digitsLen (Ecast (Econst_int (Int.repr 0) tint) tschar))
  (Ssequence
    (Ssequence
      (Sset _t'16 (Ederef (Etempvar _srcIndex (tptr tint)) tint))
      (Ssequence
        (Sset _t'17
          (Ederef
            (Ebinop Oadd (Etempvar _str (tptr tuchar)) (Etempvar _t'16 tint)
              (tptr tuchar)) tuchar))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'17 tuchar)
                       (Econst_int (Int.repr 48) tint) tint)
          (Sassign (Ederef (Etempvar _zeroPad (tptr tschar)) tschar)
            (Econst_int (Int.repr 1) tint))
          Sskip)))
    (Ssequence
      (Sloop
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'12 (Ederef (Etempvar _srcIndex (tptr tint)) tint))
              (Ssequence
                (Sset _t'13
                  (Ederef
                    (Ebinop Oadd (Etempvar _str (tptr tuchar))
                      (Etempvar _t'12 tint) (tptr tuchar)) tuchar))
                (Sifthenelse (Ebinop One (Etempvar _t'13 tuchar)
                               (Econst_int (Int.repr 100) tint) tint)
                  (Ssequence
                    (Sset _t'14
                      (Ederef (Etempvar _srcIndex (tptr tint)) tint))
                    (Ssequence
                      (Sset _t'15
                        (Ederef
                          (Ebinop Oadd (Etempvar _str (tptr tuchar))
                            (Etempvar _t'14 tint) (tptr tuchar)) tuchar))
                      (Sset _t'1
                        (Ecast
                          (Ebinop One (Etempvar _t'15 tuchar)
                            (Econst_int (Int.repr 120) tint) tint) tbool))))
                  (Sset _t'1 (Econst_int (Int.repr 0) tint)))))
            (Sifthenelse (Etempvar _t'1 tint) Sskip Sbreak))
          (Ssequence
            (Ssequence
              (Sset _t'10 (Ederef (Etempvar _srcIndex (tptr tint)) tint))
              (Ssequence
                (Sset _t'11
                  (Ederef
                    (Ebinop Oadd (Etempvar _str (tptr tuchar))
                      (Etempvar _t'10 tint) (tptr tuchar)) tuchar))
                (Sassign
                  (Ederef
                    (Ebinop Oadd (Evar _digits (tarray tschar 12))
                      (Etempvar _digitsLen tschar) (tptr tschar)) tschar)
                  (Ebinop Osub (Etempvar _t'11 tuchar)
                    (Econst_int (Int.repr 48) tint) tint))))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'8
                    (Ederef
                      (Ebinop Oadd (Evar _digits (tarray tschar 12))
                        (Etempvar _digitsLen tschar) (tptr tschar)) tschar))
                  (Sifthenelse (Ebinop Olt (Etempvar _t'8 tschar)
                                 (Econst_int (Int.repr 0) tint) tint)
                    (Sset _t'2 (Econst_int (Int.repr 1) tint))
                    (Ssequence
                      (Sset _t'9
                        (Ederef
                          (Ebinop Oadd (Evar _digits (tarray tschar 12))
                            (Etempvar _digitsLen tschar) (tptr tschar))
                          tschar))
                      (Sset _t'2
                        (Ecast
                          (Ebinop Oge (Etempvar _t'9 tschar)
                            (Econst_int (Int.repr 10) tint) tint) tbool)))))
                (Sifthenelse (Etempvar _t'2 tint)
                  (Ssequence
                    (Sassign (Ederef (Etempvar _width (tptr tuchar)) tuchar)
                      (Econst_int (Int.repr 0) tint))
                    (Sreturn None))
                  Sskip))
              (Ssequence
                (Sset _digitsLen
                  (Ecast
                    (Ebinop Oadd (Etempvar _digitsLen tschar)
                      (Econst_int (Int.repr 1) tint) tint) tschar))
                (Ssequence
                  (Sset _t'7 (Ederef (Etempvar _srcIndex (tptr tint)) tint))
                  (Sassign (Ederef (Etempvar _srcIndex (tptr tint)) tint)
                    (Ebinop Oadd (Etempvar _t'7 tint)
                      (Econst_int (Int.repr 1) tint) tint)))))))
        Sskip)
      (Ssequence
        (Sifthenelse (Ebinop Oeq (Etempvar _digitsLen tschar)
                       (Econst_int (Int.repr 0) tint) tint)
          (Sreturn None)
          Sskip)
        (Ssequence
          (Ssequence
            (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tshort))
            (Sloop
              (Ssequence
                (Sifthenelse (Ebinop Olt (Etempvar _i tshort)
                               (Ebinop Osub (Etempvar _digitsLen tschar)
                                 (Econst_int (Int.repr 1) tint) tint) tint)
                  Sskip
                  Sbreak)
                (Ssequence
                  (Sset _t'5 (Ederef (Etempvar _width (tptr tuchar)) tuchar))
                  (Ssequence
                    (Sset _t'6
                      (Ederef
                        (Ebinop Oadd (Evar _digits (tarray tschar 12))
                          (Etempvar _i tshort) (tptr tschar)) tschar))
                    (Sassign (Ederef (Etempvar _width (tptr tuchar)) tuchar)
                      (Ebinop Oadd (Etempvar _t'5 tuchar)
                        (Ebinop Omul
                          (Ebinop Omul
                            (Ebinop Osub
                              (Ebinop Osub (Etempvar _digitsLen tschar)
                                (Etempvar _i tshort) tint)
                              (Econst_int (Int.repr 1) tint) tint)
                            (Econst_int (Int.repr 10) tint) tint)
                          (Etempvar _t'6 tschar) tint) tint)))))
              (Sset _i
                (Ecast
                  (Ebinop Oadd (Etempvar _i tshort)
                    (Econst_int (Int.repr 1) tint) tint) tshort))))
          (Ssequence
            (Sset _t'3 (Ederef (Etempvar _width (tptr tuchar)) tuchar))
            (Ssequence
              (Sset _t'4
                (Ederef
                  (Ebinop Oadd (Evar _digits (tarray tschar 12))
                    (Ebinop Osub (Etempvar _digitsLen tschar)
                      (Econst_int (Int.repr 1) tint) tint) (tptr tschar))
                  tschar))
              (Sassign (Ederef (Etempvar _width (tptr tuchar)) tuchar)
                (Ebinop Oadd (Etempvar _t'3 tuchar) (Etempvar _t'4 tschar)
                  tint)))))))))
|}.

Definition f_print_text_fmt_int := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_x, tint) :: (_y, tint) :: (_str, (tptr tuchar)) ::
                (_n, tint) :: nil);
  fn_vars := ((_zeroPad, tschar) :: (_width, tuchar) :: (_len, tint) ::
              (_srcIndex, tint) :: nil);
  fn_temps := ((_c, tuchar) :: (_base, tint) :: (_t'3, tint) ::
               (_t'2, (tptr (Tstruct _TextLabel noattr))) ::
               (_t'1, (tptr tvoid)) ::
               (_t'37, (tptr (Tstruct _MemoryPool noattr))) ::
               (_t'36, tshort) ::
               (_t'35, (tptr (Tstruct _TextLabel noattr))) ::
               (_t'34, tshort) ::
               (_t'33, (tptr (Tstruct _TextLabel noattr))) ::
               (_t'32, tshort) :: (_t'31, tuchar) :: (_t'30, tint) ::
               (_t'29, tint) :: (_t'28, tuchar) :: (_t'27, tint) ::
               (_t'26, tuchar) :: (_t'25, tint) :: (_t'24, tuchar) ::
               (_t'23, tint) :: (_t'22, tuchar) :: (_t'21, tint) ::
               (_t'20, tint) :: (_t'19, tschar) :: (_t'18, tuchar) ::
               (_t'17, tint) ::
               (_t'16, (tptr (Tstruct _TextLabel noattr))) ::
               (_t'15, tshort) :: (_t'14, tint) ::
               (_t'13, (tptr (Tstruct _TextLabel noattr))) ::
               (_t'12, tshort) :: (_t'11, tint) :: (_t'10, tint) ::
               (_t'9, tuchar) :: (_t'8, tint) :: (_t'7, tint) ::
               (_t'6, (tptr (Tstruct _TextLabel noattr))) ::
               (_t'5, tshort) :: (_t'4, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _c (Ecast (Econst_int (Int.repr 0) tint) tuchar))
  (Ssequence
    (Sassign (Evar _zeroPad tschar) (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Sassign (Evar _width tuchar) (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Sset _base (Econst_int (Int.repr 0) tint))
        (Ssequence
          (Sassign (Evar _len tint) (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Sassign (Evar _srcIndex tint) (Econst_int (Int.repr 0) tint))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'37
                        (Evar _gEffectsMemoryPool (tptr (Tstruct _MemoryPool noattr))))
                      (Scall (Some _t'1)
                        (Evar _mem_pool_alloc (Tfunction
                                                ((tptr (Tstruct _MemoryPool noattr)) ::
                                                 tuint :: nil) (tptr tvoid)
                                                cc_default))
                        ((Etempvar _t'37 (tptr (Tstruct _MemoryPool noattr))) ::
                         (Esizeof (Tstruct _TextLabel noattr) tuint) :: nil)))
                    (Sset _t'2
                      (Ecast (Etempvar _t'1 (tptr tvoid))
                        (tptr (Tstruct _TextLabel noattr)))))
                  (Ssequence
                    (Sset _t'36 (Evar _sTextLabelsCount tshort))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Evar _sTextLabels (tarray (tptr (Tstruct _TextLabel noattr)) 52))
                          (Etempvar _t'36 tshort)
                          (tptr (tptr (Tstruct _TextLabel noattr))))
                        (tptr (Tstruct _TextLabel noattr)))
                      (Etempvar _t'2 (tptr (Tstruct _TextLabel noattr))))))
                (Sifthenelse (Ebinop Oeq
                               (Etempvar _t'2 (tptr (Tstruct _TextLabel noattr)))
                               (Ecast (Econst_int (Int.repr 0) tint)
                                 (tptr tvoid)) tint)
                  (Sreturn None)
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _t'34 (Evar _sTextLabelsCount tshort))
                  (Ssequence
                    (Sset _t'35
                      (Ederef
                        (Ebinop Oadd
                          (Evar _sTextLabels (tarray (tptr (Tstruct _TextLabel noattr)) 52))
                          (Etempvar _t'34 tshort)
                          (tptr (tptr (Tstruct _TextLabel noattr))))
                        (tptr (Tstruct _TextLabel noattr))))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _t'35 (tptr (Tstruct _TextLabel noattr)))
                          (Tstruct _TextLabel noattr)) _x tuint)
                      (Etempvar _x tint))))
                (Ssequence
                  (Ssequence
                    (Sset _t'32 (Evar _sTextLabelsCount tshort))
                    (Ssequence
                      (Sset _t'33
                        (Ederef
                          (Ebinop Oadd
                            (Evar _sTextLabels (tarray (tptr (Tstruct _TextLabel noattr)) 52))
                            (Etempvar _t'32 tshort)
                            (tptr (tptr (Tstruct _TextLabel noattr))))
                          (tptr (Tstruct _TextLabel noattr))))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _t'33 (tptr (Tstruct _TextLabel noattr)))
                            (Tstruct _TextLabel noattr)) _y tuint)
                        (Etempvar _y tint))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'30 (Evar _srcIndex tint))
                      (Ssequence
                        (Sset _t'31
                          (Ederef
                            (Ebinop Oadd (Etempvar _str (tptr tuchar))
                              (Etempvar _t'30 tint) (tptr tuchar)) tuchar))
                        (Sset _c (Ecast (Etempvar _t'31 tuchar) tuchar))))
                    (Ssequence
                      (Swhile
                        (Ebinop One (Etempvar _c tuchar)
                          (Econst_int (Int.repr 0) tint) tint)
                        (Ssequence
                          (Sifthenelse (Ebinop Oeq (Etempvar _c tuchar)
                                         (Econst_int (Int.repr 37) tint)
                                         tint)
                            (Ssequence
                              (Ssequence
                                (Sset _t'29 (Evar _srcIndex tint))
                                (Sassign (Evar _srcIndex tint)
                                  (Ebinop Oadd (Etempvar _t'29 tint)
                                    (Econst_int (Int.repr 1) tint) tint)))
                              (Ssequence
                                (Scall None
                                  (Evar _parse_width_field (Tfunction
                                                             ((tptr tuchar) ::
                                                              (tptr tint) ::
                                                              (tptr tuchar) ::
                                                              (tptr tschar) ::
                                                              nil) tvoid
                                                             cc_default))
                                  ((Etempvar _str (tptr tuchar)) ::
                                   (Eaddrof (Evar _srcIndex tint)
                                     (tptr tint)) ::
                                   (Eaddrof (Evar _width tuchar)
                                     (tptr tuchar)) ::
                                   (Eaddrof (Evar _zeroPad tschar)
                                     (tptr tschar)) :: nil))
                                (Ssequence
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'25 (Evar _srcIndex tint))
                                      (Ssequence
                                        (Sset _t'26
                                          (Ederef
                                            (Ebinop Oadd
                                              (Etempvar _str (tptr tuchar))
                                              (Etempvar _t'25 tint)
                                              (tptr tuchar)) tuchar))
                                        (Sifthenelse (Ebinop One
                                                       (Etempvar _t'26 tuchar)
                                                       (Econst_int (Int.repr 100) tint)
                                                       tint)
                                          (Ssequence
                                            (Sset _t'27
                                              (Evar _srcIndex tint))
                                            (Ssequence
                                              (Sset _t'28
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Etempvar _str (tptr tuchar))
                                                    (Etempvar _t'27 tint)
                                                    (tptr tuchar)) tuchar))
                                              (Sset _t'3
                                                (Ecast
                                                  (Ebinop One
                                                    (Etempvar _t'28 tuchar)
                                                    (Econst_int (Int.repr 120) tint)
                                                    tint) tbool))))
                                          (Sset _t'3
                                            (Econst_int (Int.repr 0) tint)))))
                                    (Sifthenelse (Etempvar _t'3 tint)
                                      Sbreak
                                      Sskip))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'23 (Evar _srcIndex tint))
                                      (Ssequence
                                        (Sset _t'24
                                          (Ederef
                                            (Ebinop Oadd
                                              (Etempvar _str (tptr tuchar))
                                              (Etempvar _t'23 tint)
                                              (tptr tuchar)) tuchar))
                                        (Sifthenelse (Ebinop Oeq
                                                       (Etempvar _t'24 tuchar)
                                                       (Econst_int (Int.repr 100) tint)
                                                       tint)
                                          (Sset _base
                                            (Econst_int (Int.repr 10) tint))
                                          Sskip)))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'21 (Evar _srcIndex tint))
                                        (Ssequence
                                          (Sset _t'22
                                            (Ederef
                                              (Ebinop Oadd
                                                (Etempvar _str (tptr tuchar))
                                                (Etempvar _t'21 tint)
                                                (tptr tuchar)) tuchar))
                                          (Sifthenelse (Ebinop Oeq
                                                         (Etempvar _t'22 tuchar)
                                                         (Econst_int (Int.repr 120) tint)
                                                         tint)
                                            (Sset _base
                                              (Econst_int (Int.repr 16) tint))
                                            Sskip)))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'20 (Evar _srcIndex tint))
                                          (Sassign (Evar _srcIndex tint)
                                            (Ebinop Oadd
                                              (Etempvar _t'20 tint)
                                              (Econst_int (Int.repr 1) tint)
                                              tint)))
                                        (Ssequence
                                          (Sset _t'15
                                            (Evar _sTextLabelsCount tshort))
                                          (Ssequence
                                            (Sset _t'16
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _sTextLabels (tarray (tptr (Tstruct _TextLabel noattr)) 52))
                                                  (Etempvar _t'15 tshort)
                                                  (tptr (tptr (Tstruct _TextLabel noattr))))
                                                (tptr (Tstruct _TextLabel noattr))))
                                            (Ssequence
                                              (Sset _t'17 (Evar _len tint))
                                              (Ssequence
                                                (Sset _t'18
                                                  (Evar _width tuchar))
                                                (Ssequence
                                                  (Sset _t'19
                                                    (Evar _zeroPad tschar))
                                                  (Scall None
                                                    (Evar _format_integer 
                                                    (Tfunction
                                                      (tint :: tint ::
                                                       (tptr tuchar) ::
                                                       (tptr tint) ::
                                                       tuchar :: tschar ::
                                                       nil) tvoid cc_default))
                                                    ((Etempvar _n tint) ::
                                                     (Etempvar _base tint) ::
                                                     (Ebinop Oadd
                                                       (Efield
                                                         (Ederef
                                                           (Etempvar _t'16 (tptr (Tstruct _TextLabel noattr)))
                                                           (Tstruct _TextLabel noattr))
                                                         _buffer
                                                         (tarray tuchar 50))
                                                       (Etempvar _t'17 tint)
                                                       (tptr tuchar)) ::
                                                     (Eaddrof
                                                       (Evar _len tint)
                                                       (tptr tint)) ::
                                                     (Etempvar _t'18 tuchar) ::
                                                     (Etempvar _t'19 tschar) ::
                                                     nil)))))))))))))
                            (Ssequence
                              (Ssequence
                                (Sset _t'12 (Evar _sTextLabelsCount tshort))
                                (Ssequence
                                  (Sset _t'13
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _sTextLabels (tarray (tptr (Tstruct _TextLabel noattr)) 52))
                                        (Etempvar _t'12 tshort)
                                        (tptr (tptr (Tstruct _TextLabel noattr))))
                                      (tptr (Tstruct _TextLabel noattr))))
                                  (Ssequence
                                    (Sset _t'14 (Evar _len tint))
                                    (Sassign
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'13 (tptr (Tstruct _TextLabel noattr)))
                                              (Tstruct _TextLabel noattr))
                                            _buffer (tarray tuchar 50))
                                          (Etempvar _t'14 tint)
                                          (tptr tuchar)) tuchar)
                                      (Etempvar _c tuchar)))))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'11 (Evar _len tint))
                                  (Sassign (Evar _len tint)
                                    (Ebinop Oadd (Etempvar _t'11 tint)
                                      (Econst_int (Int.repr 1) tint) tint)))
                                (Ssequence
                                  (Sset _t'10 (Evar _srcIndex tint))
                                  (Sassign (Evar _srcIndex tint)
                                    (Ebinop Oadd (Etempvar _t'10 tint)
                                      (Econst_int (Int.repr 1) tint) tint))))))
                          (Ssequence
                            (Sset _t'8 (Evar _srcIndex tint))
                            (Ssequence
                              (Sset _t'9
                                (Ederef
                                  (Ebinop Oadd (Etempvar _str (tptr tuchar))
                                    (Etempvar _t'8 tint) (tptr tuchar))
                                  tuchar))
                              (Sset _c (Ecast (Etempvar _t'9 tuchar) tuchar))))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'5 (Evar _sTextLabelsCount tshort))
                          (Ssequence
                            (Sset _t'6
                              (Ederef
                                (Ebinop Oadd
                                  (Evar _sTextLabels (tarray (tptr (Tstruct _TextLabel noattr)) 52))
                                  (Etempvar _t'5 tshort)
                                  (tptr (tptr (Tstruct _TextLabel noattr))))
                                (tptr (Tstruct _TextLabel noattr))))
                            (Ssequence
                              (Sset _t'7 (Evar _len tint))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _t'6 (tptr (Tstruct _TextLabel noattr)))
                                    (Tstruct _TextLabel noattr)) _length
                                  tshort) (Etempvar _t'7 tint)))))
                        (Ssequence
                          (Sset _t'4 (Evar _sTextLabelsCount tshort))
                          (Sassign (Evar _sTextLabelsCount tshort)
                            (Ebinop Oadd (Etempvar _t'4 tshort)
                              (Econst_int (Int.repr 1) tint) tint)))))))))))))))
|}.

Definition f_print_text := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_x, tint) :: (_y, tint) :: (_str, (tptr tuchar)) :: nil);
  fn_vars := nil;
  fn_temps := ((_c, tuchar) :: (_length, tint) :: (_srcIndex, tint) ::
               (_t'2, (tptr (Tstruct _TextLabel noattr))) ::
               (_t'1, (tptr tvoid)) ::
               (_t'15, (tptr (Tstruct _MemoryPool noattr))) ::
               (_t'14, tshort) ::
               (_t'13, (tptr (Tstruct _TextLabel noattr))) ::
               (_t'12, tshort) ::
               (_t'11, (tptr (Tstruct _TextLabel noattr))) ::
               (_t'10, tshort) :: (_t'9, tuchar) ::
               (_t'8, (tptr (Tstruct _TextLabel noattr))) ::
               (_t'7, tshort) :: (_t'6, tuchar) ::
               (_t'5, (tptr (Tstruct _TextLabel noattr))) ::
               (_t'4, tshort) :: (_t'3, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _c (Ecast (Econst_int (Int.repr 0) tint) tuchar))
  (Ssequence
    (Sset _length (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Sset _srcIndex (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Ssequence
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'15
                  (Evar _gEffectsMemoryPool (tptr (Tstruct _MemoryPool noattr))))
                (Scall (Some _t'1)
                  (Evar _mem_pool_alloc (Tfunction
                                          ((tptr (Tstruct _MemoryPool noattr)) ::
                                           tuint :: nil) (tptr tvoid)
                                          cc_default))
                  ((Etempvar _t'15 (tptr (Tstruct _MemoryPool noattr))) ::
                   (Esizeof (Tstruct _TextLabel noattr) tuint) :: nil)))
              (Sset _t'2
                (Ecast (Etempvar _t'1 (tptr tvoid))
                  (tptr (Tstruct _TextLabel noattr)))))
            (Ssequence
              (Sset _t'14 (Evar _sTextLabelsCount tshort))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Evar _sTextLabels (tarray (tptr (Tstruct _TextLabel noattr)) 52))
                    (Etempvar _t'14 tshort)
                    (tptr (tptr (Tstruct _TextLabel noattr))))
                  (tptr (Tstruct _TextLabel noattr)))
                (Etempvar _t'2 (tptr (Tstruct _TextLabel noattr))))))
          (Sifthenelse (Ebinop Oeq
                         (Etempvar _t'2 (tptr (Tstruct _TextLabel noattr)))
                         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                         tint)
            (Sreturn None)
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'12 (Evar _sTextLabelsCount tshort))
            (Ssequence
              (Sset _t'13
                (Ederef
                  (Ebinop Oadd
                    (Evar _sTextLabels (tarray (tptr (Tstruct _TextLabel noattr)) 52))
                    (Etempvar _t'12 tshort)
                    (tptr (tptr (Tstruct _TextLabel noattr))))
                  (tptr (Tstruct _TextLabel noattr))))
              (Sassign
                (Efield
                  (Ederef (Etempvar _t'13 (tptr (Tstruct _TextLabel noattr)))
                    (Tstruct _TextLabel noattr)) _x tuint)
                (Etempvar _x tint))))
          (Ssequence
            (Ssequence
              (Sset _t'10 (Evar _sTextLabelsCount tshort))
              (Ssequence
                (Sset _t'11
                  (Ederef
                    (Ebinop Oadd
                      (Evar _sTextLabels (tarray (tptr (Tstruct _TextLabel noattr)) 52))
                      (Etempvar _t'10 tshort)
                      (tptr (tptr (Tstruct _TextLabel noattr))))
                    (tptr (Tstruct _TextLabel noattr))))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _t'11 (tptr (Tstruct _TextLabel noattr)))
                      (Tstruct _TextLabel noattr)) _y tuint)
                  (Etempvar _y tint))))
            (Ssequence
              (Ssequence
                (Sset _t'9
                  (Ederef
                    (Ebinop Oadd (Etempvar _str (tptr tuchar))
                      (Etempvar _srcIndex tint) (tptr tuchar)) tuchar))
                (Sset _c (Ecast (Etempvar _t'9 tuchar) tuchar)))
              (Ssequence
                (Swhile
                  (Ebinop One (Etempvar _c tuchar)
                    (Econst_int (Int.repr 0) tint) tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'7 (Evar _sTextLabelsCount tshort))
                      (Ssequence
                        (Sset _t'8
                          (Ederef
                            (Ebinop Oadd
                              (Evar _sTextLabels (tarray (tptr (Tstruct _TextLabel noattr)) 52))
                              (Etempvar _t'7 tshort)
                              (tptr (tptr (Tstruct _TextLabel noattr))))
                            (tptr (Tstruct _TextLabel noattr))))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _t'8 (tptr (Tstruct _TextLabel noattr)))
                                  (Tstruct _TextLabel noattr)) _buffer
                                (tarray tuchar 50)) (Etempvar _length tint)
                              (tptr tuchar)) tuchar) (Etempvar _c tuchar))))
                    (Ssequence
                      (Sset _length
                        (Ebinop Oadd (Etempvar _length tint)
                          (Econst_int (Int.repr 1) tint) tint))
                      (Ssequence
                        (Sset _srcIndex
                          (Ebinop Oadd (Etempvar _srcIndex tint)
                            (Econst_int (Int.repr 1) tint) tint))
                        (Ssequence
                          (Sset _t'6
                            (Ederef
                              (Ebinop Oadd (Etempvar _str (tptr tuchar))
                                (Etempvar _srcIndex tint) (tptr tuchar))
                              tuchar))
                          (Sset _c (Ecast (Etempvar _t'6 tuchar) tuchar)))))))
                (Ssequence
                  (Ssequence
                    (Sset _t'4 (Evar _sTextLabelsCount tshort))
                    (Ssequence
                      (Sset _t'5
                        (Ederef
                          (Ebinop Oadd
                            (Evar _sTextLabels (tarray (tptr (Tstruct _TextLabel noattr)) 52))
                            (Etempvar _t'4 tshort)
                            (tptr (tptr (Tstruct _TextLabel noattr))))
                          (tptr (Tstruct _TextLabel noattr))))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _t'5 (tptr (Tstruct _TextLabel noattr)))
                            (Tstruct _TextLabel noattr)) _length tshort)
                        (Etempvar _length tint))))
                  (Ssequence
                    (Sset _t'3 (Evar _sTextLabelsCount tshort))
                    (Sassign (Evar _sTextLabelsCount tshort)
                      (Ebinop Oadd (Etempvar _t'3 tshort)
                        (Econst_int (Int.repr 1) tint) tint))))))))))))
|}.

Definition f_print_text_centered := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_x, tint) :: (_y, tint) :: (_str, (tptr tuchar)) :: nil);
  fn_vars := nil;
  fn_temps := ((_c, tuchar) :: (_unused1, tschar) :: (_unused2, tint) ::
               (_length, tint) :: (_srcIndex, tint) ::
               (_t'2, (tptr (Tstruct _TextLabel noattr))) ::
               (_t'1, (tptr tvoid)) ::
               (_t'15, (tptr (Tstruct _MemoryPool noattr))) ::
               (_t'14, tshort) :: (_t'13, tuchar) ::
               (_t'12, (tptr (Tstruct _TextLabel noattr))) ::
               (_t'11, tshort) :: (_t'10, tuchar) ::
               (_t'9, (tptr (Tstruct _TextLabel noattr))) ::
               (_t'8, tshort) ::
               (_t'7, (tptr (Tstruct _TextLabel noattr))) ::
               (_t'6, tshort) ::
               (_t'5, (tptr (Tstruct _TextLabel noattr))) ::
               (_t'4, tshort) :: (_t'3, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _c (Ecast (Econst_int (Int.repr 0) tint) tuchar))
  (Ssequence
    (Sset _unused1 (Ecast (Econst_int (Int.repr 0) tint) tschar))
    (Ssequence
      (Sset _unused2 (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Sset _length (Econst_int (Int.repr 0) tint))
        (Ssequence
          (Sset _srcIndex (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Ssequence
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'15
                      (Evar _gEffectsMemoryPool (tptr (Tstruct _MemoryPool noattr))))
                    (Scall (Some _t'1)
                      (Evar _mem_pool_alloc (Tfunction
                                              ((tptr (Tstruct _MemoryPool noattr)) ::
                                               tuint :: nil) (tptr tvoid)
                                              cc_default))
                      ((Etempvar _t'15 (tptr (Tstruct _MemoryPool noattr))) ::
                       (Esizeof (Tstruct _TextLabel noattr) tuint) :: nil)))
                  (Sset _t'2
                    (Ecast (Etempvar _t'1 (tptr tvoid))
                      (tptr (Tstruct _TextLabel noattr)))))
                (Ssequence
                  (Sset _t'14 (Evar _sTextLabelsCount tshort))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Evar _sTextLabels (tarray (tptr (Tstruct _TextLabel noattr)) 52))
                        (Etempvar _t'14 tshort)
                        (tptr (tptr (Tstruct _TextLabel noattr))))
                      (tptr (Tstruct _TextLabel noattr)))
                    (Etempvar _t'2 (tptr (Tstruct _TextLabel noattr))))))
              (Sifthenelse (Ebinop Oeq
                             (Etempvar _t'2 (tptr (Tstruct _TextLabel noattr)))
                             (Ecast (Econst_int (Int.repr 0) tint)
                               (tptr tvoid)) tint)
                (Sreturn None)
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'13
                  (Ederef
                    (Ebinop Oadd (Etempvar _str (tptr tuchar))
                      (Etempvar _srcIndex tint) (tptr tuchar)) tuchar))
                (Sset _c (Ecast (Etempvar _t'13 tuchar) tuchar)))
              (Ssequence
                (Swhile
                  (Ebinop One (Etempvar _c tuchar)
                    (Econst_int (Int.repr 0) tint) tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'11 (Evar _sTextLabelsCount tshort))
                      (Ssequence
                        (Sset _t'12
                          (Ederef
                            (Ebinop Oadd
                              (Evar _sTextLabels (tarray (tptr (Tstruct _TextLabel noattr)) 52))
                              (Etempvar _t'11 tshort)
                              (tptr (tptr (Tstruct _TextLabel noattr))))
                            (tptr (Tstruct _TextLabel noattr))))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _t'12 (tptr (Tstruct _TextLabel noattr)))
                                  (Tstruct _TextLabel noattr)) _buffer
                                (tarray tuchar 50)) (Etempvar _length tint)
                              (tptr tuchar)) tuchar) (Etempvar _c tuchar))))
                    (Ssequence
                      (Sset _length
                        (Ebinop Oadd (Etempvar _length tint)
                          (Econst_int (Int.repr 1) tint) tint))
                      (Ssequence
                        (Sset _srcIndex
                          (Ebinop Oadd (Etempvar _srcIndex tint)
                            (Econst_int (Int.repr 1) tint) tint))
                        (Ssequence
                          (Sset _t'10
                            (Ederef
                              (Ebinop Oadd (Etempvar _str (tptr tuchar))
                                (Etempvar _srcIndex tint) (tptr tuchar))
                              tuchar))
                          (Sset _c (Ecast (Etempvar _t'10 tuchar) tuchar)))))))
                (Ssequence
                  (Ssequence
                    (Sset _t'8 (Evar _sTextLabelsCount tshort))
                    (Ssequence
                      (Sset _t'9
                        (Ederef
                          (Ebinop Oadd
                            (Evar _sTextLabels (tarray (tptr (Tstruct _TextLabel noattr)) 52))
                            (Etempvar _t'8 tshort)
                            (tptr (tptr (Tstruct _TextLabel noattr))))
                          (tptr (Tstruct _TextLabel noattr))))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _t'9 (tptr (Tstruct _TextLabel noattr)))
                            (Tstruct _TextLabel noattr)) _length tshort)
                        (Etempvar _length tint))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'6 (Evar _sTextLabelsCount tshort))
                      (Ssequence
                        (Sset _t'7
                          (Ederef
                            (Ebinop Oadd
                              (Evar _sTextLabels (tarray (tptr (Tstruct _TextLabel noattr)) 52))
                              (Etempvar _t'6 tshort)
                              (tptr (tptr (Tstruct _TextLabel noattr))))
                            (tptr (Tstruct _TextLabel noattr))))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _t'7 (tptr (Tstruct _TextLabel noattr)))
                              (Tstruct _TextLabel noattr)) _x tuint)
                          (Ebinop Osub (Etempvar _x tint)
                            (Ebinop Odiv
                              (Ebinop Omul (Econst_int (Int.repr 12) tint)
                                (Etempvar _length tint) tint)
                              (Econst_int (Int.repr 2) tint) tint) tint))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'4 (Evar _sTextLabelsCount tshort))
                        (Ssequence
                          (Sset _t'5
                            (Ederef
                              (Ebinop Oadd
                                (Evar _sTextLabels (tarray (tptr (Tstruct _TextLabel noattr)) 52))
                                (Etempvar _t'4 tshort)
                                (tptr (tptr (Tstruct _TextLabel noattr))))
                              (tptr (Tstruct _TextLabel noattr))))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _t'5 (tptr (Tstruct _TextLabel noattr)))
                                (Tstruct _TextLabel noattr)) _y tuint)
                            (Etempvar _y tint))))
                      (Ssequence
                        (Sset _t'3 (Evar _sTextLabelsCount tshort))
                        (Sassign (Evar _sTextLabelsCount tshort)
                          (Ebinop Oadd (Etempvar _t'3 tshort)
                            (Econst_int (Int.repr 1) tint) tint))))))))))))))
|}.

Definition f_char_to_glyph_index := {|
  fn_return := tschar;
  fn_callconv := cc_default;
  fn_params := ((_c, tuchar) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sifthenelse (Ebinop Oge (Etempvar _c tuchar)
                   (Econst_int (Int.repr 65) tint) tint)
      (Sset _t'1
        (Ecast
          (Ebinop Ole (Etempvar _c tuchar) (Econst_int (Int.repr 90) tint)
            tint) tbool))
      (Sset _t'1 (Econst_int (Int.repr 0) tint)))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Ebinop Osub (Etempvar _c tuchar)
                       (Econst_int (Int.repr 55) tint) tint)))
      Sskip))
  (Ssequence
    (Ssequence
      (Sifthenelse (Ebinop Oge (Etempvar _c tuchar)
                     (Econst_int (Int.repr 97) tint) tint)
        (Sset _t'2
          (Ecast
            (Ebinop Ole (Etempvar _c tuchar) (Econst_int (Int.repr 122) tint)
              tint) tbool))
        (Sset _t'2 (Econst_int (Int.repr 0) tint)))
      (Sifthenelse (Etempvar _t'2 tint)
        (Sreturn (Some (Ebinop Osub (Etempvar _c tuchar)
                         (Econst_int (Int.repr 87) tint) tint)))
        Sskip))
    (Ssequence
      (Ssequence
        (Sifthenelse (Ebinop Oge (Etempvar _c tuchar)
                       (Econst_int (Int.repr 48) tint) tint)
          (Sset _t'3
            (Ecast
              (Ebinop Ole (Etempvar _c tuchar)
                (Econst_int (Int.repr 57) tint) tint) tbool))
          (Sset _t'3 (Econst_int (Int.repr 0) tint)))
        (Sifthenelse (Etempvar _t'3 tint)
          (Sreturn (Some (Ebinop Osub (Etempvar _c tuchar)
                           (Econst_int (Int.repr 48) tint) tint)))
          Sskip))
      (Ssequence
        (Sifthenelse (Ebinop Oeq (Etempvar _c tuchar)
                       (Econst_int (Int.repr 32) tint) tint)
          (Sreturn (Some (Eunop Oneg (Econst_int (Int.repr 1) tint) tint)))
          Sskip)
        (Ssequence
          (Sifthenelse (Ebinop Oeq (Etempvar _c tuchar)
                         (Econst_int (Int.repr 33) tint) tint)
            (Sreturn (Some (Econst_int (Int.repr 36) tint)))
            Sskip)
          (Ssequence
            (Sifthenelse (Ebinop Oeq (Etempvar _c tuchar)
                           (Econst_int (Int.repr 35) tint) tint)
              (Sreturn (Some (Econst_int (Int.repr 37) tint)))
              Sskip)
            (Ssequence
              (Sifthenelse (Ebinop Oeq (Etempvar _c tuchar)
                             (Econst_int (Int.repr 63) tint) tint)
                (Sreturn (Some (Econst_int (Int.repr 38) tint)))
                Sskip)
              (Ssequence
                (Sifthenelse (Ebinop Oeq (Etempvar _c tuchar)
                               (Econst_int (Int.repr 38) tint) tint)
                  (Sreturn (Some (Econst_int (Int.repr 39) tint)))
                  Sskip)
                (Ssequence
                  (Sifthenelse (Ebinop Oeq (Etempvar _c tuchar)
                                 (Econst_int (Int.repr 37) tint) tint)
                    (Sreturn (Some (Econst_int (Int.repr 40) tint)))
                    Sskip)
                  (Ssequence
                    (Sifthenelse (Ebinop Oeq (Etempvar _c tuchar)
                                   (Econst_int (Int.repr 42) tint) tint)
                      (Sreturn (Some (Econst_int (Int.repr 50) tint)))
                      Sskip)
                    (Ssequence
                      (Sifthenelse (Ebinop Oeq (Etempvar _c tuchar)
                                     (Econst_int (Int.repr 43) tint) tint)
                        (Sreturn (Some (Econst_int (Int.repr 51) tint)))
                        Sskip)
                      (Ssequence
                        (Sifthenelse (Ebinop Oeq (Etempvar _c tuchar)
                                       (Econst_int (Int.repr 44) tint) tint)
                          (Sreturn (Some (Econst_int (Int.repr 52) tint)))
                          Sskip)
                        (Ssequence
                          (Sifthenelse (Ebinop Oeq (Etempvar _c tuchar)
                                         (Econst_int (Int.repr 45) tint)
                                         tint)
                            (Sreturn (Some (Econst_int (Int.repr 53) tint)))
                            Sskip)
                          (Ssequence
                            (Sifthenelse (Ebinop Oeq (Etempvar _c tuchar)
                                           (Econst_int (Int.repr 46) tint)
                                           tint)
                              (Sreturn (Some (Econst_int (Int.repr 54) tint)))
                              Sskip)
                            (Ssequence
                              (Sifthenelse (Ebinop Oeq (Etempvar _c tuchar)
                                             (Econst_int (Int.repr 47) tint)
                                             tint)
                                (Sreturn (Some (Econst_int (Int.repr 55) tint)))
                                Sskip)
                              (Sreturn (Some (Eunop Oneg
                                               (Econst_int (Int.repr 1) tint)
                                               tint))))))))))))))))))
|}.

Definition f_add_glyph_texture := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_glyphIndex, tschar) :: nil);
  fn_vars := nil;
  fn_temps := ((_glyphs, (tptr (tptr tuchar))) ::
               (__g, (tptr (Tunion __305 noattr))) ::
               (__g__1, (tptr (Tunion __305 noattr))) ::
               (__g__2, (tptr (Tunion __305 noattr))) ::
               (_t'4, (tptr (Tunion __305 noattr))) ::
               (_t'3, (tptr (Tunion __305 noattr))) ::
               (_t'2, (tptr (Tunion __305 noattr))) ::
               (_t'1, (tptr tvoid)) :: (_t'5, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                    (tptr tvoid) cc_default))
      ((Evar _main_hud_lut (tarray (tptr tuchar) 58)) :: nil))
    (Sset _glyphs (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _gDisplayListHead (tptr (Tunion __305 noattr))))
          (Sassign (Evar _gDisplayListHead (tptr (Tunion __305 noattr)))
            (Ebinop Oadd (Etempvar _t'2 (tptr (Tunion __305 noattr)))
              (Econst_int (Int.repr 1) tint) (tptr (Tunion __305 noattr)))))
        (Sset __g
          (Ecast (Etempvar _t'2 (tptr (Tunion __305 noattr)))
            (tptr (Tunion __305 noattr)))))
      (Ssequence
        (Sassign
          (Efield
            (Efield
              (Ederef (Etempvar __g (tptr (Tunion __305 noattr)))
                (Tunion __305 noattr)) _words (Tstruct __303 noattr)) _w0
            tuint)
          (Ecast
            (Ebinop Oshl
              (Ebinop Oand (Ecast (Econst_int (Int.repr 231) tint) tuint)
                (Ebinop Osub
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 8) tint) tint)
                  (Econst_int (Int.repr 1) tint) tint) tuint)
              (Econst_int (Int.repr 24) tint) tuint) tuint))
        (Sassign
          (Efield
            (Efield
              (Ederef (Etempvar __g (tptr (Tunion __305 noattr)))
                (Tunion __305 noattr)) _words (Tstruct __303 noattr)) _w1
            tuint) (Econst_int (Int.repr 0) tint))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'3 (Evar _gDisplayListHead (tptr (Tunion __305 noattr))))
            (Sassign (Evar _gDisplayListHead (tptr (Tunion __305 noattr)))
              (Ebinop Oadd (Etempvar _t'3 (tptr (Tunion __305 noattr)))
                (Econst_int (Int.repr 1) tint) (tptr (Tunion __305 noattr)))))
          (Sset __g__1
            (Ecast (Etempvar _t'3 (tptr (Tunion __305 noattr)))
              (tptr (Tunion __305 noattr)))))
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__1 (tptr (Tunion __305 noattr)))
                  (Tunion __305 noattr)) _words (Tstruct __303 noattr)) _w0
              tuint)
            (Ebinop Oor
              (Ebinop Oor
                (Ebinop Oor
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 253) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 8) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 24) tint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 0) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 3) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 21) tint) tuint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand (Ecast (Econst_int (Int.repr 2) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 2) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 19) tint) tuint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand
                    (Ecast
                      (Ebinop Osub (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 12) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
          (Ssequence
            (Sset _t'5
              (Ederef
                (Ebinop Oadd (Etempvar _glyphs (tptr (tptr tuchar)))
                  (Etempvar _glyphIndex tschar) (tptr (tptr tuchar)))
                (tptr tuchar)))
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__1 (tptr (Tunion __305 noattr)))
                    (Tunion __305 noattr)) _words (Tstruct __303 noattr)) _w1
                tuint) (Ecast (Etempvar _t'5 (tptr tuchar)) tuint)))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'4 (Evar _gDisplayListHead (tptr (Tunion __305 noattr))))
            (Sassign (Evar _gDisplayListHead (tptr (Tunion __305 noattr)))
              (Ebinop Oadd (Etempvar _t'4 (tptr (Tunion __305 noattr)))
                (Econst_int (Int.repr 1) tint) (tptr (Tunion __305 noattr)))))
          (Sset __g__2
            (Ecast (Etempvar _t'4 (tptr (Tunion __305 noattr)))
              (tptr (Tunion __305 noattr)))))
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__2 (tptr (Tunion __305 noattr)))
                  (Tunion __305 noattr)) _words (Tstruct __303 noattr)) _w0
              tuint)
            (Ebinop Oor
              (Ebinop Oor
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast (Econst_int (Int.repr 222) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 24) tint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 16) tint) tuint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 16) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__2 (tptr (Tunion __305 noattr)))
                  (Tunion __305 noattr)) _words (Tstruct __303 noattr)) _w1
              tuint)
            (Ecast
              (Evar _dl_hud_img_load_tex_block (tarray (Tunion __305 noattr) 0))
              tuint)))))))
|}.

Definition f_clip_to_bounds := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_x, (tptr tint)) :: (_y, (tptr tint)) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Ederef (Etempvar _x (tptr tint)) tint))
    (Sifthenelse (Ebinop Olt (Etempvar _t'4 tint)
                   (Econst_int (Int.repr 10) tint) tint)
      (Sassign (Ederef (Etempvar _x (tptr tint)) tint)
        (Econst_int (Int.repr 10) tint))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'3 (Ederef (Etempvar _x (tptr tint)) tint))
      (Sifthenelse (Ebinop Ogt (Etempvar _t'3 tint)
                     (Econst_int (Int.repr 300) tint) tint)
        (Sassign (Ederef (Etempvar _x (tptr tint)) tint)
          (Econst_int (Int.repr 300) tint))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'2 (Ederef (Etempvar _y (tptr tint)) tint))
        (Sifthenelse (Ebinop Olt (Etempvar _t'2 tint)
                       (Econst_int (Int.repr 5) tint) tint)
          (Sassign (Ederef (Etempvar _y (tptr tint)) tint)
            (Econst_int (Int.repr 5) tint))
          Sskip))
      (Ssequence
        (Sset _t'1 (Ederef (Etempvar _y (tptr tint)) tint))
        (Sifthenelse (Ebinop Ogt (Etempvar _t'1 tint)
                       (Econst_int (Int.repr 220) tint) tint)
          (Sassign (Ederef (Etempvar _y (tptr tint)) tint)
            (Econst_int (Int.repr 220) tint))
          Sskip)))))
|}.

Definition f_render_textrect := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_x, tint) :: (_y, tint) :: (_pos, tint) :: nil);
  fn_vars := ((_rectBaseX, tint) :: (_rectBaseY, tint) :: nil);
  fn_temps := ((_rectX, tint) :: (_rectY, tint) ::
               (__g, (tptr (Tunion __305 noattr))) ::
               (__g__1, (tptr (Tunion __305 noattr))) ::
               (__g__2, (tptr (Tunion __305 noattr))) ::
               (_t'3, (tptr (Tunion __305 noattr))) ::
               (_t'2, (tptr (Tunion __305 noattr))) ::
               (_t'1, (tptr (Tunion __305 noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _rectBaseX tint)
    (Ebinop Oadd (Etempvar _x tint)
      (Ebinop Omul (Etempvar _pos tint) (Econst_int (Int.repr 12) tint) tint)
      tint))
  (Ssequence
    (Sassign (Evar _rectBaseY tint)
      (Ebinop Osub (Econst_int (Int.repr 224) tint) (Etempvar _y tint) tint))
    (Ssequence
      (Scall None
        (Evar _clip_to_bounds (Tfunction ((tptr tint) :: (tptr tint) :: nil)
                                tvoid cc_default))
        ((Eaddrof (Evar _rectBaseX tint) (tptr tint)) ::
         (Eaddrof (Evar _rectBaseY tint) (tptr tint)) :: nil))
      (Ssequence
        (Sset _rectX (Evar _rectBaseX tint))
        (Ssequence
          (Sset _rectY (Evar _rectBaseY tint))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'1
                  (Evar _gDisplayListHead (tptr (Tunion __305 noattr))))
                (Sassign
                  (Evar _gDisplayListHead (tptr (Tunion __305 noattr)))
                  (Ebinop Oadd (Etempvar _t'1 (tptr (Tunion __305 noattr)))
                    (Econst_int (Int.repr 1) tint)
                    (tptr (Tunion __305 noattr)))))
              (Sset __g
                (Ecast (Etempvar _t'1 (tptr (Tunion __305 noattr)))
                  (tptr (Tunion __305 noattr)))))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g (tptr (Tunion __305 noattr)))
                      (Tunion __305 noattr)) _words (Tstruct __303 noattr))
                  _w0 tuint)
                (Ebinop Oor
                  (Ebinop Oor
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 228) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 24) tint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oadd (Etempvar _rectX tint)
                                (Econst_int (Int.repr 15) tint) tint)
                              (Econst_int (Int.repr 2) tint) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 12) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 12) tint) tuint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oadd (Etempvar _rectY tint)
                              (Econst_int (Int.repr 15) tint) tint)
                            (Econst_int (Int.repr 2) tint) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 12) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
              (Ssequence
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g (tptr (Tunion __305 noattr)))
                        (Tunion __305 noattr)) _words (Tstruct __303 noattr))
                    _w1 tuint)
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 0) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 3) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 24) tint) tuint) tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast
                              (Ebinop Oshl (Etempvar _rectX tint)
                                (Econst_int (Int.repr 2) tint) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 12) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 12) tint) tuint) tuint)
                      tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast
                            (Ebinop Oshl (Etempvar _rectY tint)
                              (Econst_int (Int.repr 2) tint) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 12) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'2
                          (Evar _gDisplayListHead (tptr (Tunion __305 noattr))))
                        (Sassign
                          (Evar _gDisplayListHead (tptr (Tunion __305 noattr)))
                          (Ebinop Oadd
                            (Etempvar _t'2 (tptr (Tunion __305 noattr)))
                            (Econst_int (Int.repr 1) tint)
                            (tptr (Tunion __305 noattr)))))
                      (Sset __g__1
                        (Ecast (Etempvar _t'2 (tptr (Tunion __305 noattr)))
                          (tptr (Tunion __305 noattr)))))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar __g__1 (tptr (Tunion __305 noattr)))
                              (Tunion __305 noattr)) _words
                            (Tstruct __303 noattr)) _w0 tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 225) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 8) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 24) tint) tuint) tuint))
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar __g__1 (tptr (Tunion __305 noattr)))
                              (Tunion __305 noattr)) _words
                            (Tstruct __303 noattr)) _w1 tuint)
                        (Ecast
                          (Ebinop Oor
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Econst_int (Int.repr 0) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 16) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 16) tint)
                                tuint) tuint)
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Econst_int (Int.repr 0) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 16) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 0) tint)
                                tuint) tuint) tuint) tuint))))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'3
                          (Evar _gDisplayListHead (tptr (Tunion __305 noattr))))
                        (Sassign
                          (Evar _gDisplayListHead (tptr (Tunion __305 noattr)))
                          (Ebinop Oadd
                            (Etempvar _t'3 (tptr (Tunion __305 noattr)))
                            (Econst_int (Int.repr 1) tint)
                            (tptr (Tunion __305 noattr)))))
                      (Sset __g__2
                        (Ecast (Etempvar _t'3 (tptr (Tunion __305 noattr)))
                          (tptr (Tunion __305 noattr)))))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar __g__2 (tptr (Tunion __305 noattr)))
                              (Tunion __305 noattr)) _words
                            (Tstruct __303 noattr)) _w0 tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 241) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 8) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 24) tint) tuint) tuint))
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar __g__2 (tptr (Tunion __305 noattr)))
                              (Tunion __305 noattr)) _words
                            (Tstruct __303 noattr)) _w1 tuint)
                        (Ecast
                          (Ebinop Oor
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 4) tint)
                                      (Econst_int (Int.repr 10) tint) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 16) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 16) tint)
                                tuint) tuint)
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 10) tint) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 16) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 0) tint)
                                tuint) tuint) tuint) tuint)))))))))))))
|}.

Definition f_render_text_labels := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_j, tint) :: (_glyphIndex, tschar) ::
               (_mtx, (tptr (Tunion __228 noattr))) ::
               (__g, (tptr (Tunion __305 noattr))) ::
               (__g__1, (tptr (Tunion __305 noattr))) ::
               (__g__2, (tptr (Tunion __305 noattr))) ::
               (__g__3, (tptr (Tunion __305 noattr))) ::
               (_t'6, (tptr (Tunion __305 noattr))) :: (_t'5, tschar) ::
               (_t'4, (tptr (Tunion __305 noattr))) ::
               (_t'3, (tptr (Tunion __305 noattr))) ::
               (_t'2, (tptr (Tunion __305 noattr))) ::
               (_t'1, (tptr tvoid)) :: (_t'18, tshort) :: (_t'17, tshort) ::
               (_t'16, tshort) ::
               (_t'15, (tptr (Tstruct _TextLabel noattr))) ::
               (_t'14, tuchar) ::
               (_t'13, (tptr (Tstruct _TextLabel noattr))) ::
               (_t'12, tuint) ::
               (_t'11, (tptr (Tstruct _TextLabel noattr))) ::
               (_t'10, tuint) ::
               (_t'9, (tptr (Tstruct _TextLabel noattr))) ::
               (_t'8, (tptr (Tstruct _TextLabel noattr))) ::
               (_t'7, (tptr (Tstruct _MemoryPool noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'18 (Evar _sTextLabelsCount tshort))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'18 tshort)
                   (Econst_int (Int.repr 0) tint) tint)
      (Sreturn None)
      Sskip))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                    cc_default))
        ((Esizeof (Tunion __228 noattr) tuint) :: nil))
      (Sset _mtx (Etempvar _t'1 (tptr tvoid))))
    (Ssequence
      (Sifthenelse (Ebinop Oeq (Etempvar _mtx (tptr (Tunion __228 noattr)))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Ssequence
          (Sassign (Evar _sTextLabelsCount tshort)
            (Econst_int (Int.repr 0) tint))
          (Sreturn None))
        Sskip)
      (Ssequence
        (Scall None
          (Evar _guOrtho (Tfunction
                           ((tptr (Tunion __228 noattr)) :: tfloat ::
                            tfloat :: tfloat :: tfloat :: tfloat :: tfloat ::
                            tfloat :: nil) tvoid cc_default))
          ((Etempvar _mtx (tptr (Tunion __228 noattr))) ::
           (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
           (Econst_int (Int.repr 320) tint) ::
           (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
           (Econst_int (Int.repr 240) tint) ::
           (Eunop Oneg
             (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
             tfloat) ::
           (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat) ::
           (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat) ::
           nil))
        (Ssequence
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'2
                  (Evar _gDisplayListHead (tptr (Tunion __305 noattr))))
                (Sassign
                  (Evar _gDisplayListHead (tptr (Tunion __305 noattr)))
                  (Ebinop Oadd (Etempvar _t'2 (tptr (Tunion __305 noattr)))
                    (Econst_int (Int.repr 1) tint)
                    (tptr (Tunion __305 noattr)))))
              (Sset __g
                (Ecast
                  (Ecast (Etempvar _t'2 (tptr (Tunion __305 noattr)))
                    (tptr (Tunion __305 noattr)))
                  (tptr (Tunion __305 noattr)))))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g (tptr (Tunion __305 noattr)))
                      (Tunion __305 noattr)) _words (Tstruct __303 noattr))
                  _w0 tuint)
                (Ebinop Oor
                  (Ebinop Oor
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 219) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 24) tint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 14) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 16) tint) tuint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 0) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 16) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g (tptr (Tunion __305 noattr)))
                      (Tunion __305 noattr)) _words (Tstruct __303 noattr))
                  _w1 tuint)
                (Ecast (Econst_int (Int.repr 65535) tint) tuint))))
          (Ssequence
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'3
                    (Evar _gDisplayListHead (tptr (Tunion __305 noattr))))
                  (Sassign
                    (Evar _gDisplayListHead (tptr (Tunion __305 noattr)))
                    (Ebinop Oadd (Etempvar _t'3 (tptr (Tunion __305 noattr)))
                      (Econst_int (Int.repr 1) tint)
                      (tptr (Tunion __305 noattr)))))
                (Sset __g__1
                  (Ecast (Etempvar _t'3 (tptr (Tunion __305 noattr)))
                    (tptr (Tunion __305 noattr)))))
              (Ssequence
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__1 (tptr (Tunion __305 noattr)))
                        (Tunion __305 noattr)) _words (Tstruct __303 noattr))
                    _w0 tuint)
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 218) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 8) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 24) tint) tuint) tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast
                                (Ebinop Odiv
                                  (Ebinop Osub
                                    (Esizeof (Tunion __228 noattr) tuint)
                                    (Econst_int (Int.repr 1) tint) tuint)
                                  (Econst_int (Int.repr 8) tint) tuint)
                                tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 5) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 19) tint) tuint) tuint)
                        tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast
                              (Ebinop Odiv (Econst_int (Int.repr 0) tint)
                                (Econst_int (Int.repr 8) tint) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 8) tint) tuint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast
                            (Ebinop Oxor
                              (Ebinop Oor
                                (Ebinop Oor (Econst_int (Int.repr 4) tint)
                                  (Econst_int (Int.repr 2) tint) tint)
                                (Econst_int (Int.repr 0) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__1 (tptr (Tunion __305 noattr)))
                        (Tunion __305 noattr)) _words (Tstruct __303 noattr))
                    _w1 tuint)
                  (Ecast
                    (Ecast (Etempvar _mtx (tptr (Tunion __228 noattr)))
                      tuint) tuint))))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'4
                      (Evar _gDisplayListHead (tptr (Tunion __305 noattr))))
                    (Sassign
                      (Evar _gDisplayListHead (tptr (Tunion __305 noattr)))
                      (Ebinop Oadd
                        (Etempvar _t'4 (tptr (Tunion __305 noattr)))
                        (Econst_int (Int.repr 1) tint)
                        (tptr (Tunion __305 noattr)))))
                  (Sset __g__2
                    (Ecast (Etempvar _t'4 (tptr (Tunion __305 noattr)))
                      (tptr (Tunion __305 noattr)))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__2 (tptr (Tunion __305 noattr)))
                          (Tunion __305 noattr)) _words
                        (Tstruct __303 noattr)) _w0 tuint)
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 222) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 8) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 24) tint) tuint) tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 0) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 8) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 16) tint) tuint) tuint)
                        tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 0) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 16) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__2 (tptr (Tunion __305 noattr)))
                          (Tunion __305 noattr)) _words
                        (Tstruct __303 noattr)) _w1 tuint)
                    (Ecast
                      (Evar _dl_hud_img_begin (tarray (Tunion __305 noattr) 0))
                      tuint))))
              (Ssequence
                (Ssequence
                  (Sset _i (Econst_int (Int.repr 0) tint))
                  (Sloop
                    (Ssequence
                      (Ssequence
                        (Sset _t'17 (Evar _sTextLabelsCount tshort))
                        (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                                       (Etempvar _t'17 tshort) tint)
                          Sskip
                          Sbreak))
                      (Ssequence
                        (Ssequence
                          (Sset _j (Econst_int (Int.repr 0) tint))
                          (Sloop
                            (Ssequence
                              (Ssequence
                                (Sset _t'15
                                  (Ederef
                                    (Ebinop Oadd
                                      (Evar _sTextLabels (tarray (tptr (Tstruct _TextLabel noattr)) 52))
                                      (Etempvar _i tint)
                                      (tptr (tptr (Tstruct _TextLabel noattr))))
                                    (tptr (Tstruct _TextLabel noattr))))
                                (Ssequence
                                  (Sset _t'16
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'15 (tptr (Tstruct _TextLabel noattr)))
                                        (Tstruct _TextLabel noattr)) _length
                                      tshort))
                                  (Sifthenelse (Ebinop Olt (Etempvar _j tint)
                                                 (Etempvar _t'16 tshort)
                                                 tint)
                                    Sskip
                                    Sbreak)))
                              (Ssequence
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'13
                                      (Ederef
                                        (Ebinop Oadd
                                          (Evar _sTextLabels (tarray (tptr (Tstruct _TextLabel noattr)) 52))
                                          (Etempvar _i tint)
                                          (tptr (tptr (Tstruct _TextLabel noattr))))
                                        (tptr (Tstruct _TextLabel noattr))))
                                    (Ssequence
                                      (Sset _t'14
                                        (Ederef
                                          (Ebinop Oadd
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'13 (tptr (Tstruct _TextLabel noattr)))
                                                (Tstruct _TextLabel noattr))
                                              _buffer (tarray tuchar 50))
                                            (Etempvar _j tint) (tptr tuchar))
                                          tuchar))
                                      (Scall (Some _t'5)
                                        (Evar _char_to_glyph_index (Tfunction
                                                                    (tuchar ::
                                                                    nil)
                                                                    tschar
                                                                    cc_default))
                                        ((Etempvar _t'14 tuchar) :: nil))))
                                  (Sset _glyphIndex
                                    (Ecast (Etempvar _t'5 tschar) tschar)))
                                (Sifthenelse (Ebinop One
                                               (Etempvar _glyphIndex tschar)
                                               (Eunop Oneg
                                                 (Econst_int (Int.repr 1) tint)
                                                 tint) tint)
                                  (Ssequence
                                    (Scall None
                                      (Evar _add_glyph_texture (Tfunction
                                                                 (tschar ::
                                                                  nil) tvoid
                                                                 cc_default))
                                      ((Etempvar _glyphIndex tschar) :: nil))
                                    (Ssequence
                                      (Sset _t'9
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _sTextLabels (tarray (tptr (Tstruct _TextLabel noattr)) 52))
                                            (Etempvar _i tint)
                                            (tptr (tptr (Tstruct _TextLabel noattr))))
                                          (tptr (Tstruct _TextLabel noattr))))
                                      (Ssequence
                                        (Sset _t'10
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'9 (tptr (Tstruct _TextLabel noattr)))
                                              (Tstruct _TextLabel noattr)) _x
                                            tuint))
                                        (Ssequence
                                          (Sset _t'11
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _sTextLabels (tarray (tptr (Tstruct _TextLabel noattr)) 52))
                                                (Etempvar _i tint)
                                                (tptr (tptr (Tstruct _TextLabel noattr))))
                                              (tptr (Tstruct _TextLabel noattr))))
                                          (Ssequence
                                            (Sset _t'12
                                              (Efield
                                                (Ederef
                                                  (Etempvar _t'11 (tptr (Tstruct _TextLabel noattr)))
                                                  (Tstruct _TextLabel noattr))
                                                _y tuint))
                                            (Scall None
                                              (Evar _render_textrect 
                                              (Tfunction
                                                (tint :: tint :: tint :: nil)
                                                tvoid cc_default))
                                              ((Etempvar _t'10 tuint) ::
                                               (Etempvar _t'12 tuint) ::
                                               (Etempvar _j tint) :: nil)))))))
                                  Sskip)))
                            (Sset _j
                              (Ebinop Oadd (Etempvar _j tint)
                                (Econst_int (Int.repr 1) tint) tint))))
                        (Ssequence
                          (Sset _t'7
                            (Evar _gEffectsMemoryPool (tptr (Tstruct _MemoryPool noattr))))
                          (Ssequence
                            (Sset _t'8
                              (Ederef
                                (Ebinop Oadd
                                  (Evar _sTextLabels (tarray (tptr (Tstruct _TextLabel noattr)) 52))
                                  (Etempvar _i tint)
                                  (tptr (tptr (Tstruct _TextLabel noattr))))
                                (tptr (Tstruct _TextLabel noattr))))
                            (Scall None
                              (Evar _mem_pool_free (Tfunction
                                                     ((tptr (Tstruct _MemoryPool noattr)) ::
                                                      (tptr tvoid) :: nil)
                                                     tvoid cc_default))
                              ((Etempvar _t'7 (tptr (Tstruct _MemoryPool noattr))) ::
                               (Etempvar _t'8 (tptr (Tstruct _TextLabel noattr))) ::
                               nil))))))
                    (Sset _i
                      (Ebinop Oadd (Etempvar _i tint)
                        (Econst_int (Int.repr 1) tint) tint))))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'6
                          (Evar _gDisplayListHead (tptr (Tunion __305 noattr))))
                        (Sassign
                          (Evar _gDisplayListHead (tptr (Tunion __305 noattr)))
                          (Ebinop Oadd
                            (Etempvar _t'6 (tptr (Tunion __305 noattr)))
                            (Econst_int (Int.repr 1) tint)
                            (tptr (Tunion __305 noattr)))))
                      (Sset __g__3
                        (Ecast (Etempvar _t'6 (tptr (Tunion __305 noattr)))
                          (tptr (Tunion __305 noattr)))))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar __g__3 (tptr (Tunion __305 noattr)))
                              (Tunion __305 noattr)) _words
                            (Tstruct __303 noattr)) _w0 tuint)
                        (Ebinop Oor
                          (Ebinop Oor
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Econst_int (Int.repr 222) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 8) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 24) tint)
                                tuint) tuint)
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Econst_int (Int.repr 0) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 8) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 16) tint)
                                tuint) tuint) tuint)
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast (Econst_int (Int.repr 0) tint) tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 16) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 0) tint) tuint) tuint)
                          tuint))
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar __g__3 (tptr (Tunion __305 noattr)))
                              (Tunion __305 noattr)) _words
                            (Tstruct __303 noattr)) _w1 tuint)
                        (Ecast
                          (Evar _dl_hud_img_end (tarray (Tunion __305 noattr) 0))
                          tuint))))
                  (Sassign (Evar _sTextLabelsCount tshort)
                    (Econst_int (Int.repr 0) tint)))))))))))
|}.

Definition composites : list composite_definition :=
(Composite __225 Struct
   (Member_plain _flag tuchar :: Member_plain _v (tarray tuchar 3) :: nil)
   noattr ::
 Composite __228 Union
   (Member_plain _m (tarray (tarray tint 4) 4) ::
    Member_plain _force_structure_alignment tlong :: nil)
   noattr ::
 Composite __266 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _par I32 Unsigned noattr 8 false ::
    Member_bitfield _len I32 Unsigned noattr 16 false ::
    Member_plain _addr tuint :: nil)
   noattr ::
 Composite __268 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad I32 Signed noattr 24 false ::
    Member_plain _tri (Tstruct __225 noattr) :: nil)
   noattr ::
 Composite __270 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad1 I32 Signed noattr 24 false ::
    Member_bitfield _pad2 I32 Signed noattr 24 false ::
    Member_bitfield _param I8 Unsigned noattr 8 false :: nil)
   noattr ::
 Composite __272 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad0 I32 Signed noattr 8 false ::
    Member_bitfield _mw_index I32 Signed noattr 8 false ::
    Member_bitfield _number I32 Signed noattr 8 false ::
    Member_bitfield _pad1 I32 Signed noattr 8 false ::
    Member_bitfield _base I32 Signed noattr 24 false :: nil)
   noattr ::
 Composite __274 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad0 I32 Signed noattr 8 false ::
    Member_bitfield _sft I32 Signed noattr 8 false ::
    Member_bitfield _len I32 Signed noattr 8 false ::
    Member_bitfield _data I32 Unsigned noattr 32 false :: nil)
   noattr ::
 Composite __276 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad0 I32 Signed noattr 8 false ::
    Member_bitfield _sft I32 Signed noattr 8 false ::
    Member_bitfield _len I32 Signed noattr 8 false ::
    Member_bitfield _data I32 Unsigned noattr 32 false :: nil)
   noattr ::
 Composite __278 Struct
   (Member_plain _cmd tuchar :: Member_plain _lodscale tuchar ::
    Member_plain _tile tuchar :: Member_plain _on tuchar ::
    Member_plain _s tushort :: Member_plain _t tushort :: nil)
   noattr ::
 Composite __280 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad I32 Signed noattr 24 false ::
    Member_plain _line (Tstruct __225 noattr) :: nil)
   noattr ::
 Composite __282 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad1 I32 Signed noattr 24 false ::
    Member_plain _pad2 tshort :: Member_plain _scale tshort :: nil)
   noattr ::
 Composite __284 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _fmt I32 Unsigned noattr 3 false ::
    Member_bitfield _siz I32 Unsigned noattr 2 false ::
    Member_bitfield _pad I32 Unsigned noattr 7 false ::
    Member_bitfield _wd I32 Unsigned noattr 12 false ::
    Member_plain _dram tuint :: nil)
   noattr ::
 Composite __286 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _muxs0 I32 Unsigned noattr 24 false ::
    Member_bitfield _muxs1 I32 Unsigned noattr 32 false :: nil)
   noattr ::
 Composite __288 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_plain _pad tuchar :: Member_plain _prim_min_level tuchar ::
    Member_plain _prim_level tuchar :: Member_plain _color tuint :: nil)
   noattr ::
 Composite __290 Struct
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
 Composite __292 Struct
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
 Composite __294 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _sl I32 Unsigned noattr 12 false ::
    Member_bitfield _tl I32 Unsigned noattr 12 false ::
    Member_bitfield _pad I32 Signed noattr 5 false ::
    Member_bitfield _tile I32 Unsigned noattr 3 false ::
    Member_bitfield _sh I32 Unsigned noattr 12 false ::
    Member_bitfield _th I32 Unsigned noattr 12 false :: nil)
   noattr ::
 Composite __303 Struct
   (Member_plain _w0 tuint :: Member_plain _w1 tuint :: nil)
   noattr ::
 Composite __305 Union
   (Member_plain _words (Tstruct __303 noattr) ::
    Member_plain _dma (Tstruct __266 noattr) ::
    Member_plain _tri (Tstruct __268 noattr) ::
    Member_plain _line (Tstruct __280 noattr) ::
    Member_plain _popmtx (Tstruct __270 noattr) ::
    Member_plain _segment (Tstruct __272 noattr) ::
    Member_plain _setothermodeH (Tstruct __276 noattr) ::
    Member_plain _setothermodeL (Tstruct __274 noattr) ::
    Member_plain _texture (Tstruct __278 noattr) ::
    Member_plain _perspnorm (Tstruct __282 noattr) ::
    Member_plain _setimg (Tstruct __284 noattr) ::
    Member_plain _setcombine (Tstruct __286 noattr) ::
    Member_plain _setcolor (Tstruct __288 noattr) ::
    Member_plain _fillrect (Tstruct __290 noattr) ::
    Member_plain _settile (Tstruct __292 noattr) ::
    Member_plain _loadtile (Tstruct __294 noattr) ::
    Member_plain _settilesize (Tstruct __294 noattr) ::
    Member_plain _loadtlut (Tstruct __294 noattr) ::
    Member_plain _force_structure_alignment tlong :: nil)
   noattr ::
 Composite _TextLabel Struct
   (Member_plain _x tuint :: Member_plain _y tuint ::
    Member_plain _length tshort :: Member_plain _buffer (tarray tuchar 50) ::
    nil)
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
 (_guOrtho,
   Gfun(External (EF_external "guOrtho"
                   (mksignature
                     (AST.Xptr :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xsingle :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xsingle :: AST.Xsingle :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tunion __228 noattr)) :: tfloat :: tfloat :: tfloat :: tfloat ::
      tfloat :: tfloat :: tfloat :: nil) tvoid cc_default)) ::
 (_gEffectsMemoryPool, Gvar v_gEffectsMemoryPool) ::
 (_segmented_to_virtual,
   Gfun(External (EF_external "segmented_to_virtual"
                   (mksignature (AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr tvoid) :: nil) (tptr tvoid) cc_default)) ::
 (_mem_pool_alloc,
   Gfun(External (EF_external "mem_pool_alloc"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xptr
                     cc_default))
     ((tptr (Tstruct _MemoryPool noattr)) :: tuint :: nil) (tptr tvoid)
     cc_default)) ::
 (_mem_pool_free,
   Gfun(External (EF_external "mem_pool_free"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _MemoryPool noattr)) :: (tptr tvoid) :: nil) tvoid
     cc_default)) ::
 (_alloc_display_list,
   Gfun(External (EF_external "alloc_display_list"
                   (mksignature (AST.Xint :: nil) AST.Xptr cc_default))
     (tuint :: nil) (tptr tvoid) cc_default)) ::
 (_gDisplayListHead, Gvar v_gDisplayListHead) ::
 (_main_hud_lut, Gvar v_main_hud_lut) ::
 (_dl_hud_img_load_tex_block, Gvar v_dl_hud_img_load_tex_block) ::
 (_dl_hud_img_begin, Gvar v_dl_hud_img_begin) ::
 (_dl_hud_img_end, Gvar v_dl_hud_img_end) ::
 (_sTextLabels, Gvar v_sTextLabels) ::
 (_sTextLabelsCount, Gvar v_sTextLabelsCount) ::
 (_int_pow, Gfun(Internal f_int_pow)) ::
 (_format_integer, Gfun(Internal f_format_integer)) ::
 (_parse_width_field, Gfun(Internal f_parse_width_field)) ::
 (_print_text_fmt_int, Gfun(Internal f_print_text_fmt_int)) ::
 (_print_text, Gfun(Internal f_print_text)) ::
 (_print_text_centered, Gfun(Internal f_print_text_centered)) ::
 (_char_to_glyph_index, Gfun(Internal f_char_to_glyph_index)) ::
 (_add_glyph_texture, Gfun(Internal f_add_glyph_texture)) ::
 (_clip_to_bounds, Gfun(Internal f_clip_to_bounds)) ::
 (_render_textrect, Gfun(Internal f_render_textrect)) ::
 (_render_text_labels, Gfun(Internal f_render_text_labels)) :: nil).

Definition public_idents : list ident :=
(_render_text_labels :: _render_textrect :: _clip_to_bounds ::
 _add_glyph_texture :: _char_to_glyph_index :: _print_text_centered ::
 _print_text :: _print_text_fmt_int :: _parse_width_field ::
 _format_integer :: _int_pow :: _sTextLabelsCount :: _sTextLabels ::
 _dl_hud_img_end :: _dl_hud_img_begin :: _dl_hud_img_load_tex_block ::
 _main_hud_lut :: _gDisplayListHead :: _alloc_display_list ::
 _mem_pool_free :: _mem_pool_alloc :: _segmented_to_virtual ::
 _gEffectsMemoryPool :: _guOrtho :: ___builtin_debug ::
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


