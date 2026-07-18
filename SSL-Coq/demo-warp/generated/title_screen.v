(* GENERATED FILE -- DO NOT EDIT.
   Source: ../../../reference-sm64-decomp/src/menu/title_screen.c
   clightgen: The CompCert CompCert AST generator, version 3.15
   Flags: -normalize -nostdinc -fstruct-passing -I../../../reference-sm64-decomp/include -I../../../reference-sm64-decomp/build/us -I../../../reference-sm64-decomp/build/us/include -I../../../reference-sm64-decomp/src -I../../../reference-sm64-decomp/src/game -I../../../reference-sm64-decomp -I../../../reference-sm64-decomp/include/libc -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1 -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 *)
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
  Definition source_file := "../../../reference-sm64-decomp/src/menu/title_screen.c".
  Definition normalized := true.
End Info.

Definition _Controller : ident := $"Controller".
Definition _DemoInput : ident := $"DemoInput".
Definition _DmaHandlerList : ident := $"DmaHandlerList".
Definition _DmaTable : ident := $"DmaTable".
Definition _OffsetSizePair : ident := $"OffsetSizePair".
Definition __317 : ident := $"_317".
Definition __319 : ident := $"_319".
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
Definition ___stringlit_1 : ident := $"__stringlit_1".
Definition ___stringlit_2 : ident := $"__stringlit_2".
Definition ___stringlit_3 : ident := $"__stringlit_3".
Definition _anim : ident := $"anim".
Definition _arg : ident := $"arg".
Definition _bufTarget : ident := $"bufTarget".
Definition _button : ident := $"button".
Definition _buttonDown : ident := $"buttonDown".
Definition _buttonMask : ident := $"buttonMask".
Definition _buttonPressed : ident := $"buttonPressed".
Definition _controllerData : ident := $"controllerData".
Definition _count : ident := $"count".
Definition _currentAddr : ident := $"currentAddr".
Definition _dmaTable : ident := $"dmaTable".
Definition _errnum : ident := $"errnum".
Definition _gCurrActNum : ident := $"gCurrActNum".
Definition _gCurrDemoInput : ident := $"gCurrDemoInput".
Definition _gCurrLevelNum : ident := $"gCurrLevelNum".
Definition _gCurrSaveFileNum : ident := $"gCurrSaveFileNum".
Definition _gDebugLevelSelect : ident := $"gDebugLevelSelect".
Definition _gDemoInputListID : ident := $"gDemoInputListID".
Definition _gDemoInputsBuf : ident := $"gDemoInputsBuf".
Definition _gGlobalSoundSource : ident := $"gGlobalSoundSource".
Definition _gGlobalTimer : ident := $"gGlobalTimer".
Definition _gPlayer1Controller : ident := $"gPlayer1Controller".
Definition _intro_game_over : ident := $"intro_game_over".
Definition _intro_level_select : ident := $"intro_level_select".
Definition _intro_play_its_a_me_mario : ident := $"intro_play_its_a_me_mario".
Definition _intro_regular : ident := $"intro_regular".
Definition _level : ident := $"level".
Definition _load_patchable_table : ident := $"load_patchable_table".
Definition _lvl_intro_update : ident := $"lvl_intro_update".
Definition _main : ident := $"main".
Definition _offset : ident := $"offset".
Definition _play_sound : ident := $"play_sound".
Definition _print_intro_text : ident := $"print_intro_text".
Definition _print_text : ident := $"print_text".
Definition _print_text_centered : ident := $"print_text_centered".
Definition _print_text_fmt_int : ident := $"print_text_fmt_int".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _retVar : ident := $"retVar".
Definition _run_level_id_or_demo : ident := $"run_level_id_or_demo".
Definition _sDemoCountdown : ident := $"sDemoCountdown".
Definition _sLevelSelectStageNames : ident := $"sLevelSelectStageNames".
Definition _sPlayMarioGameOver : ident := $"sPlayMarioGameOver".
Definition _sPlayMarioGreeting : ident := $"sPlayMarioGreeting".
Definition _set_background_music : ident := $"set_background_music".
Definition _size : ident := $"size".
Definition _srcAddr : ident := $"srcAddr".
Definition _stageChanged : ident := $"stageChanged".
Definition _status : ident := $"status".
Definition _statusData : ident := $"statusData".
Definition _stickMag : ident := $"stickMag".
Definition _stickX : ident := $"stickX".
Definition _stickY : ident := $"stickY".
Definition _stick_x : ident := $"stick_x".
Definition _stick_y : ident := $"stick_y".
Definition _timer : ident := $"timer".
Definition _type : ident := $"type".
Definition _unusedArg : ident := $"unusedArg".
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
Definition _t'3 : ident := 130%positive.
Definition _t'4 : ident := 131%positive.
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v___stringlit_1 := {|
  gvar_info := (tarray tuchar 13);
  gvar_init := (Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 76) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 67) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 71) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_3 := {|
  gvar_info := (tarray tuchar 4);
  gvar_init := (Init_int8 (Int.repr 37) :: Init_int8 (Int.repr 50) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_2 := {|
  gvar_info := (tarray tuchar 19);
  gvar_init := (Init_int8 (Int.repr 80) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 66) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_gGlobalSoundSource := {|
  gvar_info := (tarray tfloat 3);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrActNum := {|
  gvar_info := tshort;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrSaveFileNum := {|
  gvar_info := tshort;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrLevelNum := {|
  gvar_info := tshort;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gPlayer1Controller := {|
  gvar_info := (tptr (Tstruct _Controller noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrDemoInput := {|
  gvar_info := (tptr (Tstruct _DemoInput noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDemoInputListID := {|
  gvar_info := tushort;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDemoInputsBuf := {|
  gvar_info := (Tstruct _DmaHandlerList noattr);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGlobalTimer := {|
  gvar_info := tuint;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDebugLevelSelect := {|
  gvar_info := tschar;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sLevelSelectStageNames := {|
  gvar_info := (tarray (tarray tuchar 16) 64);
  gvar_init := (Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 66) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 89) :: Init_int8 (Int.repr 89) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 77) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 49) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 89) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 76) ::
                Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 49) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 76) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 67) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 72) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 68) ::
                Init_int8 (Int.repr 85) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 71) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 66) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 80) ::
                Init_int8 (Int.repr 89) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 68) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 66) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 76) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 70) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 76) :: Init_int8 (Int.repr 68) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 89) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 89) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 50) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 80) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 76) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 75) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 87) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 71) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 66) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 66) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 71) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 87) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 76) ::
                Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 67) :: Init_int8 (Int.repr 76) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 67) ::
                Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 87) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 66) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 87) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 67) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 85) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 77) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 80) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 88) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 49) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 89) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 75) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 67) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 76) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 88) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 55) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 72) ::
                Init_int8 (Int.repr 79) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 88) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 50) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 75) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 76) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 86) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 88) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 57) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 85) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 85) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 88) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 51) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 72) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 86) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 70) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 66) :: Init_int8 (Int.repr 49) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 86) ::
                Init_int8 (Int.repr 76) :: Init_int8 (Int.repr 67) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 87) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 82) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 76) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 68) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 85) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 71) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 85) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 87) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 88) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 52) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 77) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 76) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 68) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 72) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 70) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 76) ::
                Init_int8 (Int.repr 76) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 88) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 54) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 77) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 82) ::
                Init_int8 (Int.repr 73) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 70) ::
                Init_int8 (Int.repr 76) :: Init_int8 (Int.repr 89) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 80) :: Init_int8 (Int.repr 80) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 49) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 88) ::
                Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 56) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 66) ::
                Init_int8 (Int.repr 76) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 75) ::
                Init_int8 (Int.repr 89) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 80) :: Init_int8 (Int.repr 80) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 50) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 80) :: Init_int8 (Int.repr 80) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 51) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 79) ::
                Init_int8 (Int.repr 78) :: Init_int8 (Int.repr 75) ::
                Init_int8 (Int.repr 69) :: Init_int8 (Int.repr 89) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 37) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 83) ::
                Init_int8 (Int.repr 76) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 50) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_space 416 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDemoCountdown := {|
  gvar_info := tushort;
  gvar_init := (Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sPlayMarioGreeting := {|
  gvar_info := tshort;
  gvar_init := (Init_int16 (Int.repr 1) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sPlayMarioGameOver := {|
  gvar_info := tshort;
  gvar_init := (Init_int16 (Int.repr 1) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_run_level_id_or_demo := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_level, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tushort) :: (_t'1, tushort) ::
               (_t'15, tfloat) ::
               (_t'14, (tptr (Tstruct _Controller noattr))) ::
               (_t'13, tushort) ::
               (_t'12, (tptr (Tstruct _Controller noattr))) ::
               (_t'11, tushort) :: (_t'10, tushort) :: (_t'9, tushort) ::
               (_t'8, tuint) :: (_t'7, (tptr (Tstruct _DmaTable noattr))) ::
               (_t'6, (tptr tvoid)) :: (_t'5, tuchar) ::
               (_t'4, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr)))
    (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Sifthenelse (Ebinop Oeq (Etempvar _level tint)
                   (Econst_int (Int.repr 0) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'12
            (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
          (Ssequence
            (Sset _t'13
              (Efield
                (Ederef (Etempvar _t'12 (tptr (Tstruct _Controller noattr)))
                  (Tstruct _Controller noattr)) _buttonDown tushort))
            (Sifthenelse (Eunop Onotbool (Etempvar _t'13 tushort) tint)
              (Ssequence
                (Sset _t'14
                  (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
                (Ssequence
                  (Sset _t'15
                    (Efield
                      (Ederef
                        (Etempvar _t'14 (tptr (Tstruct _Controller noattr)))
                        (Tstruct _Controller noattr)) _stickMag tfloat))
                  (Sset _t'3
                    (Ecast (Eunop Onotbool (Etempvar _t'15 tfloat) tint)
                      tbool))))
              (Sset _t'3 (Econst_int (Int.repr 0) tint)))))
        (Sifthenelse (Etempvar _t'3 tint)
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'11 (Evar _sDemoCountdown tushort))
                (Sset _t'2
                  (Ecast
                    (Ebinop Oadd (Etempvar _t'11 tushort)
                      (Econst_int (Int.repr 1) tint) tint) tushort)))
              (Sassign (Evar _sDemoCountdown tushort)
                (Etempvar _t'2 tushort)))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tushort)
                           (Econst_int (Int.repr 800) tint) tint)
              (Ssequence
                (Ssequence
                  (Sset _t'10 (Evar _gDemoInputListID tushort))
                  (Scall None
                    (Evar _load_patchable_table (Tfunction
                                                  ((tptr (Tstruct _DmaHandlerList noattr)) ::
                                                   tint :: nil) tint
                                                  cc_default))
                    ((Eaddrof
                       (Evar _gDemoInputsBuf (Tstruct _DmaHandlerList noattr))
                       (tptr (Tstruct _DmaHandlerList noattr))) ::
                     (Etempvar _t'10 tushort) :: nil)))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'9 (Evar _gDemoInputListID tushort))
                        (Sset _t'1
                          (Ecast
                            (Ebinop Oadd (Etempvar _t'9 tushort)
                              (Econst_int (Int.repr 1) tint) tint) tushort)))
                      (Sassign (Evar _gDemoInputListID tushort)
                        (Etempvar _t'1 tushort)))
                    (Ssequence
                      (Sset _t'7
                        (Efield
                          (Evar _gDemoInputsBuf (Tstruct _DmaHandlerList noattr))
                          _dmaTable (tptr (Tstruct _DmaTable noattr))))
                      (Ssequence
                        (Sset _t'8
                          (Efield
                            (Ederef
                              (Etempvar _t'7 (tptr (Tstruct _DmaTable noattr)))
                              (Tstruct _DmaTable noattr)) _count tuint))
                        (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tushort)
                                       (Etempvar _t'8 tuint) tint)
                          (Sassign (Evar _gDemoInputListID tushort)
                            (Econst_int (Int.repr 0) tint))
                          Sskip))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'6
                        (Efield
                          (Evar _gDemoInputsBuf (Tstruct _DmaHandlerList noattr))
                          _bufTarget (tptr tvoid)))
                      (Sassign
                        (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr)))
                        (Ebinop Oadd
                          (Ecast (Etempvar _t'6 (tptr tvoid))
                            (tptr (Tstruct _DemoInput noattr)))
                          (Econst_int (Int.repr 1) tint)
                          (tptr (Tstruct _DemoInput noattr)))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'4
                          (Efield
                            (Evar _gDemoInputsBuf (Tstruct _DmaHandlerList noattr))
                            _bufTarget (tptr tvoid)))
                        (Ssequence
                          (Sset _t'5
                            (Efield
                              (Ederef
                                (Ecast (Etempvar _t'4 (tptr tvoid))
                                  (tptr (Tstruct _DemoInput noattr)))
                                (Tstruct _DemoInput noattr)) _timer tuchar))
                          (Sset _level (Ecast (Etempvar _t'5 tuchar) tschar))))
                      (Ssequence
                        (Sassign (Evar _gCurrSaveFileNum tshort)
                          (Econst_int (Int.repr 1) tint))
                        (Sassign (Evar _gCurrActNum tshort)
                          (Econst_int (Int.repr 1) tint)))))))
              Sskip))
          (Sassign (Evar _sDemoCountdown tushort)
            (Econst_int (Int.repr 0) tint))))
      Sskip)
    (Sreturn (Some (Etempvar _level tint)))))
|}.

Definition f_intro_level_select := {|
  fn_return := tshort;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_stageChanged, tint) :: (_t'27, tshort) ::
               (_t'26, tushort) ::
               (_t'25, (tptr (Tstruct _Controller noattr))) ::
               (_t'24, tshort) :: (_t'23, tushort) ::
               (_t'22, (tptr (Tstruct _Controller noattr))) ::
               (_t'21, tshort) :: (_t'20, tushort) ::
               (_t'19, (tptr (Tstruct _Controller noattr))) ::
               (_t'18, tshort) :: (_t'17, tushort) ::
               (_t'16, (tptr (Tstruct _Controller noattr))) ::
               (_t'15, tshort) :: (_t'14, tushort) ::
               (_t'13, (tptr (Tstruct _Controller noattr))) ::
               (_t'12, tshort) :: (_t'11, tushort) ::
               (_t'10, (tptr (Tstruct _Controller noattr))) ::
               (_t'9, tshort) :: (_t'8, tshort) :: (_t'7, tshort) ::
               (_t'6, tshort) :: (_t'5, tushort) ::
               (_t'4, (tptr (Tstruct _Controller noattr))) ::
               (_t'3, tshort) :: (_t'2, tushort) ::
               (_t'1, (tptr (Tstruct _Controller noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _stageChanged (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Sset _t'25
        (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
      (Ssequence
        (Sset _t'26
          (Efield
            (Ederef (Etempvar _t'25 (tptr (Tstruct _Controller noattr)))
              (Tstruct _Controller noattr)) _buttonPressed tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'26 tushort)
                       (Econst_int (Int.repr 32768) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'27 (Evar _gCurrLevelNum tshort))
              (Sassign (Evar _gCurrLevelNum tshort)
                (Ebinop Oadd (Etempvar _t'27 tshort)
                  (Econst_int (Int.repr 1) tint) tint)))
            (Sset _stageChanged (Econst_int (Int.repr 1) tint)))
          Sskip)))
    (Ssequence
      (Ssequence
        (Sset _t'22
          (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
        (Ssequence
          (Sset _t'23
            (Efield
              (Ederef (Etempvar _t'22 (tptr (Tstruct _Controller noattr)))
                (Tstruct _Controller noattr)) _buttonPressed tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'23 tushort)
                         (Econst_int (Int.repr 16384) tint) tint)
            (Ssequence
              (Ssequence
                (Sset _t'24 (Evar _gCurrLevelNum tshort))
                (Sassign (Evar _gCurrLevelNum tshort)
                  (Ebinop Osub (Etempvar _t'24 tshort)
                    (Econst_int (Int.repr 1) tint) tint)))
              (Sset _stageChanged (Econst_int (Int.repr 1) tint)))
            Sskip)))
      (Ssequence
        (Ssequence
          (Sset _t'19
            (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
          (Ssequence
            (Sset _t'20
              (Efield
                (Ederef (Etempvar _t'19 (tptr (Tstruct _Controller noattr)))
                  (Tstruct _Controller noattr)) _buttonPressed tushort))
            (Sifthenelse (Ebinop Oand (Etempvar _t'20 tushort)
                           (Econst_int (Int.repr 2048) tint) tint)
              (Ssequence
                (Ssequence
                  (Sset _t'21 (Evar _gCurrLevelNum tshort))
                  (Sassign (Evar _gCurrLevelNum tshort)
                    (Ebinop Osub (Etempvar _t'21 tshort)
                      (Econst_int (Int.repr 1) tint) tint)))
                (Sset _stageChanged (Econst_int (Int.repr 1) tint)))
              Sskip)))
        (Ssequence
          (Ssequence
            (Sset _t'16
              (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
            (Ssequence
              (Sset _t'17
                (Efield
                  (Ederef
                    (Etempvar _t'16 (tptr (Tstruct _Controller noattr)))
                    (Tstruct _Controller noattr)) _buttonPressed tushort))
              (Sifthenelse (Ebinop Oand (Etempvar _t'17 tushort)
                             (Econst_int (Int.repr 1024) tint) tint)
                (Ssequence
                  (Ssequence
                    (Sset _t'18 (Evar _gCurrLevelNum tshort))
                    (Sassign (Evar _gCurrLevelNum tshort)
                      (Ebinop Oadd (Etempvar _t'18 tshort)
                        (Econst_int (Int.repr 1) tint) tint)))
                  (Sset _stageChanged (Econst_int (Int.repr 1) tint)))
                Sskip)))
          (Ssequence
            (Ssequence
              (Sset _t'13
                (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
              (Ssequence
                (Sset _t'14
                  (Efield
                    (Ederef
                      (Etempvar _t'13 (tptr (Tstruct _Controller noattr)))
                      (Tstruct _Controller noattr)) _buttonPressed tushort))
                (Sifthenelse (Ebinop Oand (Etempvar _t'14 tushort)
                               (Econst_int (Int.repr 512) tint) tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'15 (Evar _gCurrLevelNum tshort))
                      (Sassign (Evar _gCurrLevelNum tshort)
                        (Ebinop Osub (Etempvar _t'15 tshort)
                          (Econst_int (Int.repr 10) tint) tint)))
                    (Sset _stageChanged (Econst_int (Int.repr 1) tint)))
                  Sskip)))
            (Ssequence
              (Ssequence
                (Sset _t'10
                  (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
                (Ssequence
                  (Sset _t'11
                    (Efield
                      (Ederef
                        (Etempvar _t'10 (tptr (Tstruct _Controller noattr)))
                        (Tstruct _Controller noattr)) _buttonPressed tushort))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'11 tushort)
                                 (Econst_int (Int.repr 256) tint) tint)
                    (Ssequence
                      (Ssequence
                        (Sset _t'12 (Evar _gCurrLevelNum tshort))
                        (Sassign (Evar _gCurrLevelNum tshort)
                          (Ebinop Oadd (Etempvar _t'12 tshort)
                            (Econst_int (Int.repr 10) tint) tint)))
                      (Sset _stageChanged (Econst_int (Int.repr 1) tint)))
                    Sskip)))
              (Ssequence
                (Sifthenelse (Etempvar _stageChanged tint)
                  (Scall None
                    (Evar _play_sound (Tfunction
                                        (tint :: (tptr tfloat) :: nil) tvoid
                                        cc_default))
                    ((Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 3) tint) tuint)
                               (Econst_int (Int.repr 28) tint) tuint)
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 43) tint) tuint)
                               (Econst_int (Int.repr 16) tint) tuint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 0) tint) tuint)
                             (Econst_int (Int.repr 8) tint) tuint) tuint)
                         (Econst_int (Int.repr 128) tint) tuint)
                       (Econst_int (Int.repr 1) tint) tuint) ::
                     (Evar _gGlobalSoundSource (tarray tfloat 3)) :: nil))
                  Sskip)
                (Ssequence
                  (Ssequence
                    (Sset _t'9 (Evar _gCurrLevelNum tshort))
                    (Sifthenelse (Ebinop Ogt (Etempvar _t'9 tshort)
                                   (Econst_int (Int.repr 38) tint) tint)
                      (Sassign (Evar _gCurrLevelNum tshort)
                        (Econst_int (Int.repr 1) tint))
                      Sskip))
                  (Ssequence
                    (Ssequence
                      (Sset _t'8 (Evar _gCurrLevelNum tshort))
                      (Sifthenelse (Ebinop Olt (Etempvar _t'8 tshort)
                                     (Econst_int (Int.repr 1) tint) tint)
                        (Sassign (Evar _gCurrLevelNum tshort)
                          (Econst_int (Int.repr 38) tint))
                        Sskip))
                    (Ssequence
                      (Sassign (Evar _gCurrSaveFileNum tshort)
                        (Econst_int (Int.repr 4) tint))
                      (Ssequence
                        (Sassign (Evar _gCurrActNum tshort)
                          (Econst_int (Int.repr 6) tint))
                        (Ssequence
                          (Scall None
                            (Evar _print_text_centered (Tfunction
                                                         (tint :: tint ::
                                                          (tptr tuchar) ::
                                                          nil) tvoid
                                                         cc_default))
                            ((Econst_int (Int.repr 160) tint) ::
                             (Econst_int (Int.repr 80) tint) ::
                             (Evar ___stringlit_1 (tarray tuchar 13)) :: nil))
                          (Ssequence
                            (Scall None
                              (Evar _print_text_centered (Tfunction
                                                           (tint :: tint ::
                                                            (tptr tuchar) ::
                                                            nil) tvoid
                                                           cc_default))
                              ((Econst_int (Int.repr 160) tint) ::
                               (Econst_int (Int.repr 30) tint) ::
                               (Evar ___stringlit_2 (tarray tuchar 19)) ::
                               nil))
                            (Ssequence
                              (Ssequence
                                (Sset _t'7 (Evar _gCurrLevelNum tshort))
                                (Scall None
                                  (Evar _print_text_fmt_int (Tfunction
                                                              (tint ::
                                                               tint ::
                                                               (tptr tuchar) ::
                                                               tint :: nil)
                                                              tvoid
                                                              cc_default))
                                  ((Econst_int (Int.repr 40) tint) ::
                                   (Econst_int (Int.repr 60) tint) ::
                                   (Evar ___stringlit_3 (tarray tuchar 4)) ::
                                   (Etempvar _t'7 tshort) :: nil)))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'6 (Evar _gCurrLevelNum tshort))
                                  (Scall None
                                    (Evar _print_text (Tfunction
                                                        (tint :: tint ::
                                                         (tptr tuchar) ::
                                                         nil) tvoid
                                                        cc_default))
                                    ((Econst_int (Int.repr 80) tint) ::
                                     (Econst_int (Int.repr 60) tint) ::
                                     (Ederef
                                       (Ebinop Oadd
                                         (Evar _sLevelSelectStageNames (tarray (tarray tuchar 16) 64))
                                         (Ebinop Osub (Etempvar _t'6 tshort)
                                           (Econst_int (Int.repr 1) tint)
                                           tint) (tptr (tarray tuchar 16)))
                                       (tarray tuchar 16)) :: nil)))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'1
                                      (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
                                    (Ssequence
                                      (Sset _t'2
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'1 (tptr (Tstruct _Controller noattr)))
                                            (Tstruct _Controller noattr))
                                          _buttonPressed tushort))
                                      (Sifthenelse (Ebinop Oand
                                                     (Etempvar _t'2 tushort)
                                                     (Econst_int (Int.repr 4096) tint)
                                                     tint)
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'4
                                              (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
                                            (Ssequence
                                              (Sset _t'5
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _t'4 (tptr (Tstruct _Controller noattr)))
                                                    (Tstruct _Controller noattr))
                                                  _buttonDown tushort))
                                              (Sifthenelse (Ebinop Oeq
                                                             (Etempvar _t'5 tushort)
                                                             (Ebinop Oor
                                                               (Ebinop Oor
                                                                 (Ebinop Oor
                                                                   (Econst_int (Int.repr 8192) tint)
                                                                   (Econst_int (Int.repr 4096) tint)
                                                                   tint)
                                                                 (Econst_int (Int.repr 2) tint)
                                                                 tint)
                                                               (Econst_int (Int.repr 1) tint)
                                                               tint) tint)
                                                (Ssequence
                                                  (Sassign
                                                    (Evar _gDebugLevelSelect tschar)
                                                    (Econst_int (Int.repr 0) tint))
                                                  (Sreturn (Some (Eunop Oneg
                                                                   (Econst_int (Int.repr 1) tint)
                                                                   tint))))
                                                Sskip)))
                                          (Ssequence
                                            (Scall None
                                              (Evar _play_sound (Tfunction
                                                                  (tint ::
                                                                   (tptr tfloat) ::
                                                                   nil) tvoid
                                                                  cc_default))
                                              ((Ebinop Oor
                                                 (Ebinop Oor
                                                   (Ebinop Oor
                                                     (Ebinop Oor
                                                       (Ebinop Oshl
                                                         (Ecast
                                                           (Econst_int (Int.repr 7) tint)
                                                           tuint)
                                                         (Econst_int (Int.repr 28) tint)
                                                         tuint)
                                                       (Ebinop Oshl
                                                         (Ecast
                                                           (Econst_int (Int.repr 30) tint)
                                                           tuint)
                                                         (Econst_int (Int.repr 16) tint)
                                                         tuint) tuint)
                                                     (Ebinop Oshl
                                                       (Ecast
                                                         (Econst_int (Int.repr 255) tint)
                                                         tuint)
                                                       (Econst_int (Int.repr 8) tint)
                                                       tuint) tuint)
                                                   (Econst_int (Int.repr 128) tint)
                                                   tuint)
                                                 (Econst_int (Int.repr 1) tint)
                                                 tuint) ::
                                               (Evar _gGlobalSoundSource (tarray tfloat 3)) ::
                                               nil))
                                            (Ssequence
                                              (Sset _t'3
                                                (Evar _gCurrLevelNum tshort))
                                              (Sreturn (Some (Etempvar _t'3 tshort))))))
                                        Sskip)))
                                  (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))))))))))
|}.

Definition f_intro_regular := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_level, tint) :: (_t'1, tint) :: (_t'6, tuint) ::
               (_t'5, tshort) :: (_t'4, tschar) :: (_t'3, tushort) ::
               (_t'2, (tptr (Tstruct _Controller noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _level (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Sset _t'5 (Evar _sPlayMarioGreeting tshort))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tshort)
                     (Econst_int (Int.repr 1) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'6 (Evar _gGlobalTimer tuint))
            (Sifthenelse (Ebinop Olt (Etempvar _t'6 tuint)
                           (Econst_int (Int.repr 129) tint) tint)
              (Scall None
                (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil)
                                    tvoid cc_default))
                ((Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 2) tint) tuint)
                           (Econst_int (Int.repr 28) tint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 50) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 255) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                       (Econst_int (Int.repr 128) tint) tint) tuint)
                   (Econst_int (Int.repr 1) tint) tuint) ::
                 (Evar _gGlobalSoundSource (tarray tfloat 3)) :: nil))
              (Scall None
                (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil)
                                    tvoid cc_default))
                ((Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 2) tint) tuint)
                           (Econst_int (Int.repr 28) tint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 51) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 255) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Ebinop Oor
                       (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                         (Econst_int (Int.repr 32) tint) tint)
                       (Econst_int (Int.repr 128) tint) tint) tuint)
                   (Econst_int (Int.repr 1) tint) tuint) ::
                 (Evar _gGlobalSoundSource (tarray tfloat 3)) :: nil))))
          (Sassign (Evar _sPlayMarioGreeting tshort)
            (Econst_int (Int.repr 0) tint)))
        Sskip))
    (Ssequence
      (Scall None (Evar _print_intro_text (Tfunction nil tvoid cc_default))
        nil)
      (Ssequence
        (Ssequence
          (Sset _t'2
            (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
          (Ssequence
            (Sset _t'3
              (Efield
                (Ederef (Etempvar _t'2 (tptr (Tstruct _Controller noattr)))
                  (Tstruct _Controller noattr)) _buttonPressed tushort))
            (Sifthenelse (Ebinop Oand (Etempvar _t'3 tushort)
                           (Econst_int (Int.repr 4096) tint) tint)
              (Ssequence
                (Scall None
                  (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil)
                                      tvoid cc_default))
                  ((Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 7) tint) tuint)
                             (Econst_int (Int.repr 28) tint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 30) tint) tuint)
                             (Econst_int (Int.repr 16) tint) tuint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 255) tint) tuint)
                           (Econst_int (Int.repr 8) tint) tuint) tuint)
                       (Econst_int (Int.repr 128) tint) tuint)
                     (Econst_int (Int.repr 1) tint) tuint) ::
                   (Evar _gGlobalSoundSource (tarray tfloat 3)) :: nil))
                (Ssequence
                  (Ssequence
                    (Sset _t'4 (Evar _gDebugLevelSelect tschar))
                    (Sset _level
                      (Ebinop Oadd (Econst_int (Int.repr 100) tint)
                        (Etempvar _t'4 tschar) tint)))
                  (Sassign (Evar _sPlayMarioGreeting tshort)
                    (Econst_int (Int.repr 1) tint))))
              Sskip)))
        (Ssequence
          (Scall (Some _t'1)
            (Evar _run_level_id_or_demo (Tfunction (tint :: nil) tint
                                          cc_default))
            ((Etempvar _level tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tint))))))))
|}.

Definition f_intro_game_over := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_level, tint) :: (_t'1, tint) :: (_t'5, tshort) ::
               (_t'4, tschar) :: (_t'3, tushort) ::
               (_t'2, (tptr (Tstruct _Controller noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _level (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Sset _t'5 (Evar _sPlayMarioGameOver tshort))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tshort)
                     (Econst_int (Int.repr 1) tint) tint)
        (Ssequence
          (Scall None
            (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                                cc_default))
            ((Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 2) tint) tuint)
                       (Econst_int (Int.repr 28) tint) tuint)
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 49) tint) tuint)
                       (Econst_int (Int.repr 16) tint) tuint) tuint)
                   (Ebinop Oshl
                     (Ecast (Econst_int (Int.repr 255) tint) tuint)
                     (Econst_int (Int.repr 8) tint) tuint) tuint)
                 (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                   (Econst_int (Int.repr 128) tint) tint) tuint)
               (Econst_int (Int.repr 1) tint) tuint) ::
             (Evar _gGlobalSoundSource (tarray tfloat 3)) :: nil))
          (Sassign (Evar _sPlayMarioGameOver tshort)
            (Econst_int (Int.repr 0) tint)))
        Sskip))
    (Ssequence
      (Scall None (Evar _print_intro_text (Tfunction nil tvoid cc_default))
        nil)
      (Ssequence
        (Ssequence
          (Sset _t'2
            (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
          (Ssequence
            (Sset _t'3
              (Efield
                (Ederef (Etempvar _t'2 (tptr (Tstruct _Controller noattr)))
                  (Tstruct _Controller noattr)) _buttonPressed tushort))
            (Sifthenelse (Ebinop Oand (Etempvar _t'3 tushort)
                           (Econst_int (Int.repr 4096) tint) tint)
              (Ssequence
                (Scall None
                  (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil)
                                      tvoid cc_default))
                  ((Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 7) tint) tuint)
                             (Econst_int (Int.repr 28) tint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 30) tint) tuint)
                             (Econst_int (Int.repr 16) tint) tuint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 255) tint) tuint)
                           (Econst_int (Int.repr 8) tint) tuint) tuint)
                       (Econst_int (Int.repr 128) tint) tuint)
                     (Econst_int (Int.repr 1) tint) tuint) ::
                   (Evar _gGlobalSoundSource (tarray tfloat 3)) :: nil))
                (Ssequence
                  (Ssequence
                    (Sset _t'4 (Evar _gDebugLevelSelect tschar))
                    (Sset _level
                      (Ebinop Oadd (Econst_int (Int.repr 100) tint)
                        (Etempvar _t'4 tschar) tint)))
                  (Sassign (Evar _sPlayMarioGameOver tshort)
                    (Econst_int (Int.repr 1) tint))))
              Sskip)))
        (Ssequence
          (Scall (Some _t'1)
            (Evar _run_level_id_or_demo (Tfunction (tint :: nil) tint
                                          cc_default))
            ((Etempvar _level tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tint))))))))
|}.

Definition f_intro_play_its_a_me_mario := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _set_background_music (Tfunction
                                  (tushort :: tushort :: tshort :: nil) tvoid
                                  cc_default))
    ((Econst_int (Int.repr 0) tint) :: (Econst_int (Int.repr 0) tint) ::
     (Econst_int (Int.repr 0) tint) :: nil))
  (Ssequence
    (Scall None
      (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                          cc_default))
      ((Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 7) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 20) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Econst_int (Int.repr 128) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) ::
       (Evar _gGlobalSoundSource (tarray tfloat 3)) :: nil))
    (Sreturn (Some (Econst_int (Int.repr 1) tint)))))
|}.

Definition f_lvl_intro_update := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_arg, tshort) :: (_unusedArg, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_retVar, tint) :: (_t'4, tshort) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Sswitch (Etempvar _arg tshort)
    (LScons (Some 0)
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _intro_play_its_a_me_mario (Tfunction nil tint cc_default))
            nil)
          (Sset _retVar (Etempvar _t'1 tint)))
        Sbreak)
      (LScons (Some 1)
        (Ssequence
          (Ssequence
            (Scall (Some _t'2)
              (Evar _intro_regular (Tfunction nil tint cc_default)) nil)
            (Sset _retVar (Etempvar _t'2 tint)))
          Sbreak)
        (LScons (Some 2)
          (Ssequence
            (Ssequence
              (Scall (Some _t'3)
                (Evar _intro_game_over (Tfunction nil tint cc_default)) nil)
              (Sset _retVar (Etempvar _t'3 tint)))
            Sbreak)
          (LScons (Some 3)
            (Ssequence
              (Ssequence
                (Scall (Some _t'4)
                  (Evar _intro_level_select (Tfunction nil tshort cc_default))
                  nil)
                (Sset _retVar (Etempvar _t'4 tshort)))
              Sbreak)
            LSnil)))))
  (Sreturn (Some (Etempvar _retVar tint))))
|}.

Definition composites : list composite_definition :=
(Composite __317 Struct
   (Member_plain _type tushort :: Member_plain _status tuchar ::
    Member_plain _errnum tuchar :: nil)
   noattr ::
 Composite __319 Struct
   (Member_plain _button tushort :: Member_plain _stick_x tschar ::
    Member_plain _stick_y tschar :: Member_plain _errnum tuchar :: nil)
   noattr ::
 Composite _Controller Struct
   (Member_plain _rawStickX tshort :: Member_plain _rawStickY tshort ::
    Member_plain _stickX tfloat :: Member_plain _stickY tfloat ::
    Member_plain _stickMag tfloat :: Member_plain _buttonDown tushort ::
    Member_plain _buttonPressed tushort ::
    Member_plain _statusData (tptr (Tstruct __317 noattr)) ::
    Member_plain _controllerData (tptr (Tstruct __319 noattr)) :: nil)
   noattr ::
 Composite _OffsetSizePair Struct
   (Member_plain _offset tuint :: Member_plain _size tuint :: nil)
   noattr ::
 Composite _DmaTable Struct
   (Member_plain _count tuint :: Member_plain _srcAddr (tptr tuchar) ::
    Member_plain _anim (tarray (Tstruct _OffsetSizePair noattr) 1) :: nil)
   noattr ::
 Composite _DmaHandlerList Struct
   (Member_plain _dmaTable (tptr (Tstruct _DmaTable noattr)) ::
    Member_plain _currentAddr (tptr tvoid) ::
    Member_plain _bufTarget (tptr tvoid) :: nil)
   noattr ::
 Composite _DemoInput Struct
   (Member_plain _timer tuchar :: Member_plain _rawStickX tschar ::
    Member_plain _rawStickY tschar :: Member_plain _buttonMask tuchar :: nil)
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
     cc_default)) :: (___stringlit_1, Gvar v___stringlit_1) ::
 (___stringlit_3, Gvar v___stringlit_3) ::
 (___stringlit_2, Gvar v___stringlit_2) ::
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
 (_gGlobalSoundSource, Gvar v_gGlobalSoundSource) ::
 (_play_sound,
   Gfun(External (EF_external "play_sound"
                   (mksignature (AST.Xint :: AST.Xptr :: nil) AST.Xvoid
                     cc_default)) (tint :: (tptr tfloat) :: nil) tvoid
     cc_default)) ::
 (_load_patchable_table,
   Gfun(External (EF_external "load_patchable_table"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xint
                     cc_default))
     ((tptr (Tstruct _DmaHandlerList noattr)) :: tint :: nil) tint
     cc_default)) :: (_gCurrActNum, Gvar v_gCurrActNum) ::
 (_gCurrSaveFileNum, Gvar v_gCurrSaveFileNum) ::
 (_gCurrLevelNum, Gvar v_gCurrLevelNum) ::
 (_print_intro_text,
   Gfun(External (EF_external "print_intro_text"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) :: (_gPlayer1Controller, Gvar v_gPlayer1Controller) ::
 (_gCurrDemoInput, Gvar v_gCurrDemoInput) ::
 (_gDemoInputListID, Gvar v_gDemoInputListID) ::
 (_gDemoInputsBuf, Gvar v_gDemoInputsBuf) ::
 (_gGlobalTimer, Gvar v_gGlobalTimer) ::
 (_gDebugLevelSelect, Gvar v_gDebugLevelSelect) ::
 (_print_text_fmt_int,
   Gfun(External (EF_external "print_text_fmt_int"
                   (mksignature
                     (AST.Xint :: AST.Xint :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     (tint :: tint :: (tptr tuchar) :: tint :: nil) tvoid cc_default)) ::
 (_print_text,
   Gfun(External (EF_external "print_text"
                   (mksignature (AST.Xint :: AST.Xint :: AST.Xptr :: nil)
                     AST.Xvoid cc_default))
     (tint :: tint :: (tptr tuchar) :: nil) tvoid cc_default)) ::
 (_print_text_centered,
   Gfun(External (EF_external "print_text_centered"
                   (mksignature (AST.Xint :: AST.Xint :: AST.Xptr :: nil)
                     AST.Xvoid cc_default))
     (tint :: tint :: (tptr tuchar) :: nil) tvoid cc_default)) ::
 (_set_background_music,
   Gfun(External (EF_external "set_background_music"
                   (mksignature
                     (AST.Xint16unsigned :: AST.Xint16unsigned ::
                      AST.Xint16signed :: nil) AST.Xvoid cc_default))
     (tushort :: tushort :: tshort :: nil) tvoid cc_default)) ::
 (_sLevelSelectStageNames, Gvar v_sLevelSelectStageNames) ::
 (_sDemoCountdown, Gvar v_sDemoCountdown) ::
 (_sPlayMarioGreeting, Gvar v_sPlayMarioGreeting) ::
 (_sPlayMarioGameOver, Gvar v_sPlayMarioGameOver) ::
 (_run_level_id_or_demo, Gfun(Internal f_run_level_id_or_demo)) ::
 (_intro_level_select, Gfun(Internal f_intro_level_select)) ::
 (_intro_regular, Gfun(Internal f_intro_regular)) ::
 (_intro_game_over, Gfun(Internal f_intro_game_over)) ::
 (_intro_play_its_a_me_mario, Gfun(Internal f_intro_play_its_a_me_mario)) ::
 (_lvl_intro_update, Gfun(Internal f_lvl_intro_update)) :: nil).

Definition public_idents : list ident :=
(_lvl_intro_update :: _intro_play_its_a_me_mario :: _intro_game_over ::
 _intro_regular :: _intro_level_select :: _run_level_id_or_demo ::
 _set_background_music :: _print_text_centered :: _print_text ::
 _print_text_fmt_int :: _gDebugLevelSelect :: _gGlobalTimer ::
 _gDemoInputsBuf :: _gDemoInputListID :: _gCurrDemoInput ::
 _gPlayer1Controller :: _print_intro_text :: _gCurrLevelNum ::
 _gCurrSaveFileNum :: _gCurrActNum :: _load_patchable_table :: _play_sound ::
 _gGlobalSoundSource :: ___builtin_debug :: ___builtin_sync_fetch_and_add ::
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


