(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_US
   Source:          src/game/save_file.c
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1
   Link hygiene:    private __stringlit_N atoms prefixed with us_save_file
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
  Definition source_file := "build/pinned-sm64/src/game/save_file.c".
  Definition normalized := true.
End Info.

Definition _CreditsEntry : ident := $"CreditsEntry".
Definition _DemoInput : ident := $"DemoInput".
Definition _MainMenuSaveData : ident := $"MainMenuSaveData".
Definition _OSMesgQueue_s : ident := $"OSMesgQueue_s".
Definition _OSThread_s : ident := $"OSThread_s".
Definition _SaveBlockSignature : ident := $"SaveBlockSignature".
Definition _SaveBuffer : ident := $"SaveBuffer".
Definition _SaveFile : ident := $"SaveFile".
Definition _WarpCheckpoint : ident := $"WarpCheckpoint".
Definition _WarpNode : ident := $"WarpNode".
Definition __248 : ident := $"_248".
Definition __249 : ident := $"_249".
Definition __251 : ident := $"_251".
Definition __253 : ident := $"_253".
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
Definition _a0 : ident := $"a0".
Definition _a1 : ident := $"a1".
Definition _a2 : ident := $"a2".
Definition _a3 : ident := $"a3".
Definition _actNum : ident := $"actNum".
Definition _add_save_block_signature : ident := $"add_save_block_signature".
Definition _age : ident := $"age".
Definition _areaIndex : ident := $"areaIndex".
Definition _areaNum : ident := $"areaNum".
Definition _at : ident := $"at".
Definition _badvaddr : ident := $"badvaddr".
Definition _bcopy : ident := $"bcopy".
Definition _buffer : ident := $"buffer".
Definition _buttonMask : ident := $"buttonMask".
Definition _bzero : ident := $"bzero".
Definition _calc_checksum : ident := $"calc_checksum".
Definition _capArea : ident := $"capArea".
Definition _capLevel : ident := $"capLevel".
Definition _capPos : ident := $"capPos".
Definition _cause : ident := $"cause".
Definition _check_if_should_set_warp_checkpoint : ident := $"check_if_should_set_warp_checkpoint".
Definition _check_warp_checkpoint : ident := $"check_warp_checkpoint".
Definition _chksum : ident := $"chksum".
Definition _coinScore : ident := $"coinScore".
Definition _coinScoreAges : ident := $"coinScoreAges".
Definition _context : ident := $"context".
Definition _count : ident := $"count".
Definition _courseCoinScores : ident := $"courseCoinScores".
Definition _courseIndex : ident := $"courseIndex".
Definition _courseNum : ident := $"courseNum".
Definition _courseStars : ident := $"courseStars".
Definition _currCourseNum : ident := $"currCourseNum".
Definition _currentAge : ident := $"currentAge".
Definition _data : ident := $"data".
Definition _destArea : ident := $"destArea".
Definition _destFileIndex : ident := $"destFileIndex".
Definition _destLevel : ident := $"destLevel".
Definition _destNode : ident := $"destNode".
Definition _destSlot : ident := $"destSlot".
Definition _disable_warp_checkpoint : ident := $"disable_warp_checkpoint".
Definition _f : ident := $"f".
Definition _f_even : ident := $"f_even".
Definition _f_odd : ident := $"f_odd".
Definition _file : ident := $"file".
Definition _fileIndex : ident := $"fileIndex".
Definition _files : ident := $"files".
Definition _filler : ident := $"filler".
Definition _first : ident := $"first".
Definition _flag : ident := $"flag".
Definition _flags : ident := $"flags".
Definition _fp : ident := $"fp".
Definition _fp0 : ident := $"fp0".
Definition _fp10 : ident := $"fp10".
Definition _fp12 : ident := $"fp12".
Definition _fp14 : ident := $"fp14".
Definition _fp16 : ident := $"fp16".
Definition _fp18 : ident := $"fp18".
Definition _fp2 : ident := $"fp2".
Definition _fp20 : ident := $"fp20".
Definition _fp22 : ident := $"fp22".
Definition _fp24 : ident := $"fp24".
Definition _fp26 : ident := $"fp26".
Definition _fp28 : ident := $"fp28".
Definition _fp30 : ident := $"fp30".
Definition _fp4 : ident := $"fp4".
Definition _fp6 : ident := $"fp6".
Definition _fp8 : ident := $"fp8".
Definition _fpcsr : ident := $"fpcsr".
Definition _fullqueue : ident := $"fullqueue".
Definition _gCurrActNum : ident := $"gCurrActNum".
Definition _gCurrAreaIndex : ident := $"gCurrAreaIndex".
Definition _gCurrCourseNum : ident := $"gCurrCourseNum".
Definition _gCurrCourseStarFlags : ident := $"gCurrCourseStarFlags".
Definition _gCurrCreditsEntry : ident := $"gCurrCreditsEntry".
Definition _gCurrDemoInput : ident := $"gCurrDemoInput".
Definition _gCurrLevelNum : ident := $"gCurrLevelNum".
Definition _gCurrSaveFileNum : ident := $"gCurrSaveFileNum".
Definition _gEepromProbe : ident := $"gEepromProbe".
Definition _gGotFileCoinHiScore : ident := $"gGotFileCoinHiScore".
Definition _gLastCompletedCourseNum : ident := $"gLastCompletedCourseNum".
Definition _gLastCompletedStarNum : ident := $"gLastCompletedStarNum".
Definition _gLevelToCourseNumTable : ident := $"gLevelToCourseNumTable".
Definition _gMainMenuDataModified : ident := $"gMainMenuDataModified".
Definition _gSIEventMesgQueue : ident := $"gSIEventMesgQueue".
Definition _gSaveBuffer : ident := $"gSaveBuffer".
Definition _gSaveFileModified : ident := $"gSaveFileModified".
Definition _gSavedCourseNum : ident := $"gSavedCourseNum".
Definition _gSpecialTripleJump : ident := $"gSpecialTripleJump".
Definition _gWarpCheckpoint : ident := $"gWarpCheckpoint".
Definition _get_coin_score_age : ident := $"get_coin_score_age".
Definition _gp : ident := $"gp".
Definition _hi : ident := $"hi".
Definition _i : ident := $"i".
Definition _id : ident := $"id".
Definition _levelID : ident := $"levelID".
Definition _levelNum : ident := $"levelNum".
Definition _lo : ident := $"lo".
Definition _magic : ident := $"magic".
Definition _main : ident := $"main".
Definition _marioAngle : ident := $"marioAngle".
Definition _marioPos : ident := $"marioPos".
Definition _mask : ident := $"mask".
Definition _maxCoinScore : ident := $"maxCoinScore".
Definition _maxCourse : ident := $"maxCourse".
Definition _maxScoreAge : ident := $"maxScoreAge".
Definition _maxScoreFileNum : ident := $"maxScoreFileNum".
Definition _menuData : ident := $"menuData".
Definition _minCourse : ident := $"minCourse".
Definition _mode : ident := $"mode".
Definition _msg : ident := $"msg".
Definition _msgCount : ident := $"msgCount".
Definition _mtqueue : ident := $"mtqueue".
Definition _next : ident := $"next".
Definition _offset : ident := $"offset".
Definition _osEepromLongRead : ident := $"osEepromLongRead".
Definition _osEepromLongWrite : ident := $"osEepromLongWrite".
Definition _pc : ident := $"pc".
Definition _priority : ident := $"priority".
Definition _queue : ident := $"queue".
Definition _ra : ident := $"ra".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _rcp : ident := $"rcp".
Definition _read_eeprom_data : ident := $"read_eeprom_data".
Definition _restore_main_menu_data : ident := $"restore_main_menu_data".
Definition _restore_save_file_data : ident := $"restore_save_file_data".
Definition _s0 : ident := $"s0".
Definition _s1 : ident := $"s1".
Definition _s2 : ident := $"s2".
Definition _s3 : ident := $"s3".
Definition _s4 : ident := $"s4".
Definition _s5 : ident := $"s5".
Definition _s6 : ident := $"s6".
Definition _s7 : ident := $"s7".
Definition _s8 : ident := $"s8".
Definition _sUnusedGotGlobalCoinHiScore : ident := $"sUnusedGotGlobalCoinHiScore".
Definition _saveFile : ident := $"saveFile".
Definition _save_file_clear_flags : ident := $"save_file_clear_flags".
Definition _save_file_collect_star_or_key : ident := $"save_file_collect_star_or_key".
Definition _save_file_copy : ident := $"save_file_copy".
Definition _save_file_do_save : ident := $"save_file_do_save".
Definition _save_file_erase : ident := $"save_file_erase".
Definition _save_file_exists : ident := $"save_file_exists".
Definition _save_file_get_cap_pos : ident := $"save_file_get_cap_pos".
Definition _save_file_get_course_coin_score : ident := $"save_file_get_course_coin_score".
Definition _save_file_get_course_star_count : ident := $"save_file_get_course_star_count".
Definition _save_file_get_flags : ident := $"save_file_get_flags".
Definition _save_file_get_max_coin_score : ident := $"save_file_get_max_coin_score".
Definition _save_file_get_sound_mode : ident := $"save_file_get_sound_mode".
Definition _save_file_get_star_flags : ident := $"save_file_get_star_flags".
Definition _save_file_get_total_star_count : ident := $"save_file_get_total_star_count".
Definition _save_file_is_cannon_unlocked : ident := $"save_file_is_cannon_unlocked".
Definition _save_file_load_all : ident := $"save_file_load_all".
Definition _save_file_move_cap_to_default_location : ident := $"save_file_move_cap_to_default_location".
Definition _save_file_reload : ident := $"save_file_reload".
Definition _save_file_set_cannon_unlocked : ident := $"save_file_set_cannon_unlocked".
Definition _save_file_set_cap_pos : ident := $"save_file_set_cap_pos".
Definition _save_file_set_flags : ident := $"save_file_set_flags".
Definition _save_file_set_sound_mode : ident := $"save_file_set_sound_mode".
Definition _save_file_set_star_flags : ident := $"save_file_set_star_flags".
Definition _save_main_menu_data : ident := $"save_main_menu_data".
Definition _scoreAge : ident := $"scoreAge".
Definition _set_coin_score_age : ident := $"set_coin_score_age".
Definition _set_sound_mode : ident := $"set_sound_mode".
Definition _sig : ident := $"sig".
Definition _signature : ident := $"signature".
Definition _size : ident := $"size".
Definition _soundMode : ident := $"soundMode".
Definition _sp : ident := $"sp".
Definition _sr : ident := $"sr".
Definition _srcFileIndex : ident := $"srcFileIndex".
Definition _srcSlot : ident := $"srcSlot".
Definition _starFlag : ident := $"starFlag".
Definition _starFlags : ident := $"starFlags".
Definition _starIndex : ident := $"starIndex".
Definition _state : ident := $"state".
Definition _status : ident := $"status".
Definition _stub_save_file_1 : ident := $"stub_save_file_1".
Definition _t0 : ident := $"t0".
Definition _t1 : ident := $"t1".
Definition _t2 : ident := $"t2".
Definition _t3 : ident := $"t3".
Definition _t4 : ident := $"t4".
Definition _t5 : ident := $"t5".
Definition _t6 : ident := $"t6".
Definition _t7 : ident := $"t7".
Definition _t8 : ident := $"t8".
Definition _t9 : ident := $"t9".
Definition _thprof : ident := $"thprof".
Definition _time : ident := $"time".
Definition _timer : ident := $"timer".
Definition _tlnext : ident := $"tlnext".
Definition _touch_coin_score_age : ident := $"touch_coin_score_age".
Definition _touch_high_score_ages : ident := $"touch_high_score_ages".
Definition _triesLeft : ident := $"triesLeft".
Definition _unk02 : ident := $"unk02".
Definition _unk0C : ident := $"unk0C".
Definition _v0 : ident := $"v0".
Definition _v1 : ident := $"v1".
Definition _validCount : ident := $"validCount".
Definition _validSlots : ident := $"validSlots".
Definition _vec3s_copy : ident := $"vec3s_copy".
Definition _vec3s_set : ident := $"vec3s_set".
Definition _verify_save_block_signature : ident := $"verify_save_block_signature".
Definition _warpCheckpointActive : ident := $"warpCheckpointActive".
Definition _warpNode : ident := $"warpNode".
Definition _wipe_main_menu_data : ident := $"wipe_main_menu_data".
Definition _write_eeprom_data : ident := $"write_eeprom_data".
Definition _x : ident := $"x".
Definition _y : ident := $"y".
Definition _z : ident := $"z".
Definition _t'1 : ident := 128%positive.
Definition _t'10 : ident := 137%positive.
Definition _t'11 : ident := 138%positive.
Definition _t'2 : ident := 129%positive.
Definition _t'3 : ident := 130%positive.
Definition _t'4 : ident := 131%positive.
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v_gEepromProbe := {|
  gvar_info := tschar;
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

Definition v_gSIEventMesgQueue := {|
  gvar_info := (Tstruct _OSMesgQueue_s noattr);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrCourseNum := {|
  gvar_info := tshort;
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

Definition v_gCurrAreaIndex := {|
  gvar_info := tshort;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSavedCourseNum := {|
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

Definition v_gCurrCreditsEntry := {|
  gvar_info := (tptr (Tstruct _CreditsEntry noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSaveBuffer := {|
  gvar_info := (Tstruct _SaveBuffer noattr);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gWarpCheckpoint := {|
  gvar_info := (Tstruct _WarpCheckpoint noattr);
  gvar_init := (Init_space 5 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMainMenuDataModified := {|
  gvar_info := tschar;
  gvar_init := (Init_space 1 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSaveFileModified := {|
  gvar_info := tschar;
  gvar_init := (Init_space 1 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gLastCompletedCourseNum := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gLastCompletedStarNum := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sUnusedGotGlobalCoinHiScore := {|
  gvar_info := tschar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGotFileCoinHiScore := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrCourseStarFlags := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSpecialTripleJump := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gLevelToCourseNumTable := {|
  gvar_info := (tarray tschar 38);
  gvar_init := (Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 5) ::
                Init_int8 (Int.repr 4) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 6) :: Init_int8 (Int.repr 8) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 10) ::
                Init_int8 (Int.repr 11) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 13) :: Init_int8 (Int.repr 14) ::
                Init_int8 (Int.repr 15) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 16) :: Init_int8 (Int.repr 22) ::
                Init_int8 (Int.repr 17) :: Init_int8 (Int.repr 24) ::
                Init_int8 (Int.repr 18) :: Init_int8 (Int.repr 7) ::
                Init_int8 (Int.repr 9) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 25) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 19) :: Init_int8 (Int.repr 20) ::
                Init_int8 (Int.repr 21) :: Init_int8 (Int.repr 16) ::
                Init_int8 (Int.repr 23) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 17) :: Init_int8 (Int.repr 18) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 12) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_stub_save_file_1 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_filler, (tarray tuchar 4)) :: nil);
  fn_temps := nil;
  fn_body :=
Sskip
|}.

Definition f_read_eeprom_data := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_buffer, (tptr tvoid)) :: (_size, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_status, tint) :: (_triesLeft, tint) :: (_offset, tuint) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'3, tschar) :: nil);
  fn_body :=
(Ssequence
  (Sset _status (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Sset _t'3 (Evar _gEepromProbe tschar))
      (Sifthenelse (Ebinop One (Etempvar _t'3 tschar)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Sset _triesLeft (Econst_int (Int.repr 4) tint))
          (Ssequence
            (Sset _offset
              (Ebinop Odiv
                (Ecast
                  (Ebinop Osub
                    (Ecast (Etempvar _buffer (tptr tvoid)) (tptr tuchar))
                    (Ecast
                      (Eaddrof
                        (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                        (tptr (Tstruct _SaveBuffer noattr))) (tptr tuchar))
                    tint) tuint) (Econst_int (Int.repr 8) tint) tuint))
            (Sloop
              (Ssequence
                (Sset _triesLeft
                  (Ebinop Osub (Etempvar _triesLeft tint)
                    (Econst_int (Int.repr 1) tint) tint))
                (Ssequence
                  (Scall (Some _t'2)
                    (Evar _osEepromLongRead (Tfunction
                                              ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                               tuchar :: (tptr tuchar) ::
                                               tint :: nil) tint cc_default))
                    ((Eaddrof
                       (Evar _gSIEventMesgQueue (Tstruct _OSMesgQueue_s noattr))
                       (tptr (Tstruct _OSMesgQueue_s noattr))) ::
                     (Etempvar _offset tuint) ::
                     (Etempvar _buffer (tptr tvoid)) ::
                     (Etempvar _size tint) :: nil))
                  (Sset _status (Etempvar _t'2 tint))))
              (Ssequence
                (Sifthenelse (Ebinop Ogt (Etempvar _triesLeft tint)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Sset _t'1
                    (Ecast
                      (Ebinop One (Etempvar _status tint)
                        (Econst_int (Int.repr 0) tint) tint) tbool))
                  (Sset _t'1 (Econst_int (Int.repr 0) tint)))
                (Sifthenelse (Etempvar _t'1 tint) Sskip Sbreak)))))
        Sskip))
    (Sreturn (Some (Etempvar _status tint)))))
|}.

Definition f_write_eeprom_data := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_buffer, (tptr tvoid)) :: (_size, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_status, tint) :: (_triesLeft, tint) :: (_offset, tuint) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'3, tschar) :: nil);
  fn_body :=
(Ssequence
  (Sset _status (Econst_int (Int.repr 1) tint))
  (Ssequence
    (Ssequence
      (Sset _t'3 (Evar _gEepromProbe tschar))
      (Sifthenelse (Ebinop One (Etempvar _t'3 tschar)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Sset _triesLeft (Econst_int (Int.repr 4) tint))
          (Ssequence
            (Sset _offset
              (Ebinop Oshr
                (Ecast
                  (Ebinop Osub
                    (Ecast (Etempvar _buffer (tptr tvoid)) (tptr tuchar))
                    (Ecast
                      (Eaddrof
                        (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                        (tptr (Tstruct _SaveBuffer noattr))) (tptr tuchar))
                    tint) tuint) (Econst_int (Int.repr 3) tint) tuint))
            (Sloop
              (Ssequence
                (Sset _triesLeft
                  (Ebinop Osub (Etempvar _triesLeft tint)
                    (Econst_int (Int.repr 1) tint) tint))
                (Ssequence
                  (Scall (Some _t'2)
                    (Evar _osEepromLongWrite (Tfunction
                                               ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                                tuchar :: (tptr tuchar) ::
                                                tint :: nil) tint cc_default))
                    ((Eaddrof
                       (Evar _gSIEventMesgQueue (Tstruct _OSMesgQueue_s noattr))
                       (tptr (Tstruct _OSMesgQueue_s noattr))) ::
                     (Etempvar _offset tuint) ::
                     (Etempvar _buffer (tptr tvoid)) ::
                     (Etempvar _size tint) :: nil))
                  (Sset _status (Etempvar _t'2 tint))))
              (Ssequence
                (Sifthenelse (Ebinop Ogt (Etempvar _triesLeft tint)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Sset _t'1
                    (Ecast
                      (Ebinop One (Etempvar _status tint)
                        (Econst_int (Int.repr 0) tint) tint) tbool))
                  (Sset _t'1 (Econst_int (Int.repr 0) tint)))
                (Sifthenelse (Etempvar _t'1 tint) Sskip Sbreak)))))
        Sskip))
    (Sreturn (Some (Etempvar _status tint)))))
|}.

Definition f_calc_checksum := {|
  fn_return := tushort;
  fn_callconv := cc_default;
  fn_params := ((_data, (tptr tuchar)) :: (_size, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_chksum, tushort) :: (_t'2, (tptr tuchar)) :: (_t'1, tint) ::
               (_t'3, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _chksum (Ecast (Econst_int (Int.repr 0) tint) tushort))
  (Ssequence
    (Sloop
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'1 (Etempvar _size tint))
            (Sset _size
              (Ebinop Osub (Etempvar _t'1 tint)
                (Econst_int (Int.repr 1) tint) tint)))
          (Sifthenelse (Ebinop Ogt (Etempvar _t'1 tint)
                         (Econst_int (Int.repr 2) tint) tint)
            Sskip
            Sbreak))
        (Ssequence
          (Ssequence
            (Sset _t'2 (Etempvar _data (tptr tuchar)))
            (Sset _data
              (Ebinop Oadd (Etempvar _t'2 (tptr tuchar))
                (Econst_int (Int.repr 1) tint) (tptr tuchar))))
          (Ssequence
            (Sset _t'3 (Ederef (Etempvar _t'2 (tptr tuchar)) tuchar))
            (Sset _chksum
              (Ecast
                (Ebinop Oadd (Etempvar _chksum tushort)
                  (Etempvar _t'3 tuchar) tint) tushort)))))
      Sskip)
    (Sreturn (Some (Etempvar _chksum tushort)))))
|}.

Definition f_verify_save_block_signature := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_buffer, (tptr tvoid)) :: (_size, tint) ::
                (_magic, tushort) :: nil);
  fn_vars := nil;
  fn_temps := ((_sig, (tptr (Tstruct _SaveBlockSignature noattr))) ::
               (_t'1, tushort) :: (_t'3, tushort) :: (_t'2, tushort) :: nil);
  fn_body :=
(Ssequence
  (Sset _sig
    (Ecast
      (Ebinop Oadd
        (Ebinop Osub (Etempvar _size tint) (Econst_int (Int.repr 4) tint)
          tint) (Ecast (Etempvar _buffer (tptr tvoid)) (tptr tuchar))
        (tptr tuchar)) (tptr (Tstruct _SaveBlockSignature noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef (Etempvar _sig (tptr (Tstruct _SaveBlockSignature noattr)))
            (Tstruct _SaveBlockSignature noattr)) _magic tushort))
      (Sifthenelse (Ebinop One (Etempvar _t'3 tushort)
                     (Etempvar _magic tushort) tint)
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))
        Sskip))
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _calc_checksum (Tfunction ((tptr tuchar) :: tint :: nil)
                                 tushort cc_default))
          ((Etempvar _buffer (tptr tvoid)) :: (Etempvar _size tint) :: nil))
        (Ssequence
          (Sset _t'2
            (Efield
              (Ederef
                (Etempvar _sig (tptr (Tstruct _SaveBlockSignature noattr)))
                (Tstruct _SaveBlockSignature noattr)) _chksum tushort))
          (Sifthenelse (Ebinop One (Etempvar _t'2 tushort)
                         (Etempvar _t'1 tushort) tint)
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))
            Sskip)))
      (Sreturn (Some (Econst_int (Int.repr 1) tint))))))
|}.

Definition f_add_save_block_signature := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_buffer, (tptr tvoid)) :: (_size, tint) ::
                (_magic, tushort) :: nil);
  fn_vars := nil;
  fn_temps := ((_sig, (tptr (Tstruct _SaveBlockSignature noattr))) ::
               (_t'1, tushort) :: nil);
  fn_body :=
(Ssequence
  (Sset _sig
    (Ecast
      (Ebinop Oadd
        (Ebinop Osub (Etempvar _size tint) (Econst_int (Int.repr 4) tint)
          tint) (Ecast (Etempvar _buffer (tptr tvoid)) (tptr tuchar))
        (tptr tuchar)) (tptr (Tstruct _SaveBlockSignature noattr))))
  (Ssequence
    (Sassign
      (Efield
        (Ederef (Etempvar _sig (tptr (Tstruct _SaveBlockSignature noattr)))
          (Tstruct _SaveBlockSignature noattr)) _magic tushort)
      (Etempvar _magic tushort))
    (Ssequence
      (Scall (Some _t'1)
        (Evar _calc_checksum (Tfunction ((tptr tuchar) :: tint :: nil)
                               tushort cc_default))
        ((Etempvar _buffer (tptr tvoid)) :: (Etempvar _size tint) :: nil))
      (Sassign
        (Efield
          (Ederef (Etempvar _sig (tptr (Tstruct _SaveBlockSignature noattr)))
            (Tstruct _SaveBlockSignature noattr)) _chksum tushort)
        (Etempvar _t'1 tushort)))))
|}.

Definition f_restore_main_menu_data := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_srcSlot, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_destSlot, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _destSlot
    (Ebinop Oxor (Etempvar _srcSlot tint) (Econst_int (Int.repr 1) tint)
      tint))
  (Ssequence
    (Scall None
      (Evar _add_save_block_signature (Tfunction
                                        ((tptr tvoid) :: tint :: tushort ::
                                         nil) tvoid cc_default))
      ((Ebinop Oadd
         (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr)) _menuData
           (tarray (Tstruct _MainMenuSaveData noattr) 2))
         (Etempvar _srcSlot tint) (tptr (Tstruct _MainMenuSaveData noattr))) ::
       (Esizeof (Tstruct _MainMenuSaveData noattr) tuint) ::
       (Econst_int (Int.repr 18505) tint) :: nil))
    (Ssequence
      (Scall None
        (Evar _bcopy (Tfunction
                       ((tptr tvoid) :: (tptr tvoid) :: tuint :: nil) tvoid
                       cc_default))
        ((Ebinop Oadd
           (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr)) _menuData
             (tarray (Tstruct _MainMenuSaveData noattr) 2))
           (Etempvar _srcSlot tint)
           (tptr (Tstruct _MainMenuSaveData noattr))) ::
         (Ebinop Oadd
           (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr)) _menuData
             (tarray (Tstruct _MainMenuSaveData noattr) 2))
           (Etempvar _destSlot tint)
           (tptr (Tstruct _MainMenuSaveData noattr))) ::
         (Esizeof (Tstruct _MainMenuSaveData noattr) tuint) :: nil))
      (Scall None
        (Evar _write_eeprom_data (Tfunction ((tptr tvoid) :: tint :: nil)
                                   tint cc_default))
        ((Ebinop Oadd
           (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr)) _menuData
             (tarray (Tstruct _MainMenuSaveData noattr) 2))
           (Etempvar _destSlot tint)
           (tptr (Tstruct _MainMenuSaveData noattr))) ::
         (Esizeof (Tstruct _MainMenuSaveData noattr) tuint) :: nil)))))
|}.

Definition f_save_main_menu_data := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tschar) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _gMainMenuDataModified tschar))
  (Sifthenelse (Etempvar _t'1 tschar)
    (Ssequence
      (Scall None
        (Evar _add_save_block_signature (Tfunction
                                          ((tptr tvoid) :: tint :: tushort ::
                                           nil) tvoid cc_default))
        ((Ebinop Oadd
           (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr)) _menuData
             (tarray (Tstruct _MainMenuSaveData noattr) 2))
           (Econst_int (Int.repr 0) tint)
           (tptr (Tstruct _MainMenuSaveData noattr))) ::
         (Esizeof (Tstruct _MainMenuSaveData noattr) tuint) ::
         (Econst_int (Int.repr 18505) tint) :: nil))
      (Ssequence
        (Scall None
          (Evar _bcopy (Tfunction
                         ((tptr tvoid) :: (tptr tvoid) :: tuint :: nil) tvoid
                         cc_default))
          ((Ebinop Oadd
             (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
               _menuData (tarray (Tstruct _MainMenuSaveData noattr) 2))
             (Econst_int (Int.repr 0) tint)
             (tptr (Tstruct _MainMenuSaveData noattr))) ::
           (Ebinop Oadd
             (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
               _menuData (tarray (Tstruct _MainMenuSaveData noattr) 2))
             (Econst_int (Int.repr 1) tint)
             (tptr (Tstruct _MainMenuSaveData noattr))) ::
           (Esizeof (Tstruct _MainMenuSaveData noattr) tuint) :: nil))
        (Ssequence
          (Scall None
            (Evar _write_eeprom_data (Tfunction ((tptr tvoid) :: tint :: nil)
                                       tint cc_default))
            ((Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
               _menuData (tarray (Tstruct _MainMenuSaveData noattr) 2)) ::
             (Esizeof (tarray (Tstruct _MainMenuSaveData noattr) 2) tuint) ::
             nil))
          (Sassign (Evar _gMainMenuDataModified tschar)
            (Econst_int (Int.repr 0) tint)))))
    Sskip))
|}.

Definition f_wipe_main_menu_data := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _bzero (Tfunction ((tptr tvoid) :: tuint :: nil) tvoid cc_default))
    ((Ebinop Oadd
       (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr)) _menuData
         (tarray (Tstruct _MainMenuSaveData noattr) 2))
       (Econst_int (Int.repr 0) tint)
       (tptr (Tstruct _MainMenuSaveData noattr))) ::
     (Esizeof (Tstruct _MainMenuSaveData noattr) tuint) :: nil))
  (Ssequence
    (Sassign
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef
              (Ebinop Oadd
                (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                  _menuData (tarray (Tstruct _MainMenuSaveData noattr) 2))
                (Econst_int (Int.repr 0) tint)
                (tptr (Tstruct _MainMenuSaveData noattr)))
              (Tstruct _MainMenuSaveData noattr)) _coinScoreAges
            (tarray tuint 4)) (Econst_int (Int.repr 0) tint) (tptr tuint))
        tuint) (Econst_int (Int.repr 1073741823) tint))
    (Ssequence
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                    _menuData (tarray (Tstruct _MainMenuSaveData noattr) 2))
                  (Econst_int (Int.repr 0) tint)
                  (tptr (Tstruct _MainMenuSaveData noattr)))
                (Tstruct _MainMenuSaveData noattr)) _coinScoreAges
              (tarray tuint 4)) (Econst_int (Int.repr 1) tint) (tptr tuint))
          tuint) (Econst_int (Int.repr 715827882) tint))
      (Ssequence
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef
                  (Ebinop Oadd
                    (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                      _menuData
                      (tarray (Tstruct _MainMenuSaveData noattr) 2))
                    (Econst_int (Int.repr 0) tint)
                    (tptr (Tstruct _MainMenuSaveData noattr)))
                  (Tstruct _MainMenuSaveData noattr)) _coinScoreAges
                (tarray tuint 4)) (Econst_int (Int.repr 2) tint)
              (tptr tuint)) tuint) (Econst_int (Int.repr 357913941) tint))
        (Ssequence
          (Sassign (Evar _gMainMenuDataModified tschar)
            (Econst_int (Int.repr 1) tint))
          (Scall None
            (Evar _save_main_menu_data (Tfunction nil tvoid cc_default)) nil))))))
|}.

Definition f_get_coin_score_age := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_fileIndex, tint) :: (_courseIndex, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Ederef
      (Ebinop Oadd
        (Efield
          (Ederef
            (Ebinop Oadd
              (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                _menuData (tarray (Tstruct _MainMenuSaveData noattr) 2))
              (Econst_int (Int.repr 0) tint)
              (tptr (Tstruct _MainMenuSaveData noattr)))
            (Tstruct _MainMenuSaveData noattr)) _coinScoreAges
          (tarray tuint 4)) (Etempvar _fileIndex tint) (tptr tuint)) tuint))
  (Sreturn (Some (Ebinop Oand
                   (Ebinop Oshr (Etempvar _t'1 tuint)
                     (Ebinop Omul (Econst_int (Int.repr 2) tint)
                       (Etempvar _courseIndex tint) tint) tuint)
                   (Econst_int (Int.repr 3) tint) tuint))))
|}.

Definition f_set_coin_score_age := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_fileIndex, tint) :: (_courseIndex, tint) :: (_age, tint) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_mask, tint) :: (_t'2, tuint) :: (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _mask
    (Ebinop Oshl (Econst_int (Int.repr 3) tint)
      (Ebinop Omul (Econst_int (Int.repr 2) tint)
        (Etempvar _courseIndex tint) tint) tint))
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                    _menuData (tarray (Tstruct _MainMenuSaveData noattr) 2))
                  (Econst_int (Int.repr 0) tint)
                  (tptr (Tstruct _MainMenuSaveData noattr)))
                (Tstruct _MainMenuSaveData noattr)) _coinScoreAges
              (tarray tuint 4)) (Etempvar _fileIndex tint) (tptr tuint))
          tuint))
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                    _menuData (tarray (Tstruct _MainMenuSaveData noattr) 2))
                  (Econst_int (Int.repr 0) tint)
                  (tptr (Tstruct _MainMenuSaveData noattr)))
                (Tstruct _MainMenuSaveData noattr)) _coinScoreAges
              (tarray tuint 4)) (Etempvar _fileIndex tint) (tptr tuint))
          tuint)
        (Ebinop Oand (Etempvar _t'2 tuint)
          (Eunop Onotint (Etempvar _mask tint) tint) tuint)))
    (Ssequence
      (Sset _t'1
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                    _menuData (tarray (Tstruct _MainMenuSaveData noattr) 2))
                  (Econst_int (Int.repr 0) tint)
                  (tptr (Tstruct _MainMenuSaveData noattr)))
                (Tstruct _MainMenuSaveData noattr)) _coinScoreAges
              (tarray tuint 4)) (Etempvar _fileIndex tint) (tptr tuint))
          tuint))
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                    _menuData (tarray (Tstruct _MainMenuSaveData noattr) 2))
                  (Econst_int (Int.repr 0) tint)
                  (tptr (Tstruct _MainMenuSaveData noattr)))
                (Tstruct _MainMenuSaveData noattr)) _coinScoreAges
              (tarray tuint 4)) (Etempvar _fileIndex tint) (tptr tuint))
          tuint)
        (Ebinop Oor (Etempvar _t'1 tuint)
          (Ebinop Oshl (Etempvar _age tint)
            (Ebinop Omul (Econst_int (Int.repr 2) tint)
              (Etempvar _courseIndex tint) tint) tint) tuint)))))
|}.

Definition f_touch_coin_score_age := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_fileIndex, tint) :: (_courseIndex, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_age, tuint) :: (_currentAge, tuint) ::
               (_t'2, tint) :: (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _get_coin_score_age (Tfunction (tint :: tint :: nil) tint
                                  cc_default))
      ((Etempvar _fileIndex tint) :: (Etempvar _courseIndex tint) :: nil))
    (Sset _currentAge (Etempvar _t'1 tint)))
  (Sifthenelse (Ebinop One (Etempvar _currentAge tuint)
                 (Econst_int (Int.repr 0) tint) tint)
    (Ssequence
      (Ssequence
        (Sset _i (Econst_int (Int.repr 0) tint))
        (Sloop
          (Ssequence
            (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                           (Econst_int (Int.repr 4) tint) tint)
              Sskip
              Sbreak)
            (Ssequence
              (Ssequence
                (Scall (Some _t'2)
                  (Evar _get_coin_score_age (Tfunction (tint :: tint :: nil)
                                              tint cc_default))
                  ((Etempvar _i tint) :: (Etempvar _courseIndex tint) :: nil))
                (Sset _age (Etempvar _t'2 tint)))
              (Sifthenelse (Ebinop Olt (Etempvar _age tuint)
                             (Etempvar _currentAge tuint) tint)
                (Scall None
                  (Evar _set_coin_score_age (Tfunction
                                              (tint :: tint :: tint :: nil)
                                              tvoid cc_default))
                  ((Etempvar _i tint) :: (Etempvar _courseIndex tint) ::
                   (Ebinop Oadd (Etempvar _age tuint)
                     (Econst_int (Int.repr 1) tint) tuint) :: nil))
                Sskip)))
          (Sset _i
            (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint)
              tint))))
      (Ssequence
        (Scall None
          (Evar _set_coin_score_age (Tfunction (tint :: tint :: tint :: nil)
                                      tvoid cc_default))
          ((Etempvar _fileIndex tint) :: (Etempvar _courseIndex tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sassign (Evar _gMainMenuDataModified tschar)
          (Econst_int (Int.repr 1) tint))))
    Sskip))
|}.

Definition f_touch_high_score_ages := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_fileIndex, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _i
    (Ebinop Osub (Econst_int (Int.repr 1) tint)
      (Econst_int (Int.repr 1) tint) tint))
  (Sloop
    (Ssequence
      (Sifthenelse (Ebinop Ole (Etempvar _i tint)
                     (Ebinop Osub (Econst_int (Int.repr 15) tint)
                       (Econst_int (Int.repr 1) tint) tint) tint)
        Sskip
        Sbreak)
      (Scall None
        (Evar _touch_coin_score_age (Tfunction (tint :: tint :: nil) tvoid
                                      cc_default))
        ((Etempvar _fileIndex tint) :: (Etempvar _i tint) :: nil)))
    (Sset _i
      (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint) tint))))
|}.

Definition f_restore_save_file_data := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_fileIndex, tint) :: (_srcSlot, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_destSlot, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _destSlot
    (Ebinop Oxor (Etempvar _srcSlot tint) (Econst_int (Int.repr 1) tint)
      tint))
  (Ssequence
    (Scall None
      (Evar _add_save_block_signature (Tfunction
                                        ((tptr tvoid) :: tint :: tushort ::
                                         nil) tvoid cc_default))
      ((Ebinop Oadd
         (Ederef
           (Ebinop Oadd
             (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr)) _files
               (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
             (Etempvar _fileIndex tint)
             (tptr (tarray (Tstruct _SaveFile noattr) 2)))
           (tarray (Tstruct _SaveFile noattr) 2)) (Etempvar _srcSlot tint)
         (tptr (Tstruct _SaveFile noattr))) ::
       (Esizeof (Tstruct _SaveFile noattr) tuint) ::
       (Econst_int (Int.repr 17473) tint) :: nil))
    (Ssequence
      (Scall None
        (Evar _bcopy (Tfunction
                       ((tptr tvoid) :: (tptr tvoid) :: tuint :: nil) tvoid
                       cc_default))
        ((Ebinop Oadd
           (Ederef
             (Ebinop Oadd
               (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                 _files (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
               (Etempvar _fileIndex tint)
               (tptr (tarray (Tstruct _SaveFile noattr) 2)))
             (tarray (Tstruct _SaveFile noattr) 2)) (Etempvar _srcSlot tint)
           (tptr (Tstruct _SaveFile noattr))) ::
         (Ebinop Oadd
           (Ederef
             (Ebinop Oadd
               (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                 _files (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
               (Etempvar _fileIndex tint)
               (tptr (tarray (Tstruct _SaveFile noattr) 2)))
             (tarray (Tstruct _SaveFile noattr) 2)) (Etempvar _destSlot tint)
           (tptr (Tstruct _SaveFile noattr))) ::
         (Esizeof (Tstruct _SaveFile noattr) tuint) :: nil))
      (Scall None
        (Evar _write_eeprom_data (Tfunction ((tptr tvoid) :: tint :: nil)
                                   tint cc_default))
        ((Ebinop Oadd
           (Ederef
             (Ebinop Oadd
               (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                 _files (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
               (Etempvar _fileIndex tint)
               (tptr (tarray (Tstruct _SaveFile noattr) 2)))
             (tarray (Tstruct _SaveFile noattr) 2)) (Etempvar _destSlot tint)
           (tptr (Tstruct _SaveFile noattr))) ::
         (Esizeof (Tstruct _SaveFile noattr) tuint) :: nil)))))
|}.

Definition f_save_file_do_save := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_fileIndex, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tschar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1 (Evar _gSaveFileModified tschar))
    (Sifthenelse (Etempvar _t'1 tschar)
      (Ssequence
        (Scall None
          (Evar _add_save_block_signature (Tfunction
                                            ((tptr tvoid) :: tint ::
                                             tushort :: nil) tvoid
                                            cc_default))
          ((Ebinop Oadd
             (Ederef
               (Ebinop Oadd
                 (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                   _files (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                 (Etempvar _fileIndex tint)
                 (tptr (tarray (Tstruct _SaveFile noattr) 2)))
               (tarray (Tstruct _SaveFile noattr) 2))
             (Econst_int (Int.repr 0) tint)
             (tptr (Tstruct _SaveFile noattr))) ::
           (Esizeof (Tstruct _SaveFile noattr) tuint) ::
           (Econst_int (Int.repr 17473) tint) :: nil))
        (Ssequence
          (Scall None
            (Evar _bcopy (Tfunction
                           ((tptr tvoid) :: (tptr tvoid) :: tuint :: nil)
                           tvoid cc_default))
            ((Ebinop Oadd
               (Ederef
                 (Ebinop Oadd
                   (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                     _files (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                   (Etempvar _fileIndex tint)
                   (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                 (tarray (Tstruct _SaveFile noattr) 2))
               (Econst_int (Int.repr 0) tint)
               (tptr (Tstruct _SaveFile noattr))) ::
             (Ebinop Oadd
               (Ederef
                 (Ebinop Oadd
                   (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                     _files (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                   (Etempvar _fileIndex tint)
                   (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                 (tarray (Tstruct _SaveFile noattr) 2))
               (Econst_int (Int.repr 1) tint)
               (tptr (Tstruct _SaveFile noattr))) ::
             (Esizeof (Tstruct _SaveFile noattr) tuint) :: nil))
          (Ssequence
            (Scall None
              (Evar _write_eeprom_data (Tfunction
                                         ((tptr tvoid) :: tint :: nil) tint
                                         cc_default))
              ((Ederef
                 (Ebinop Oadd
                   (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                     _files (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                   (Etempvar _fileIndex tint)
                   (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                 (tarray (Tstruct _SaveFile noattr) 2)) ::
               (Esizeof (tarray (Tstruct _SaveFile noattr) 2) tuint) :: nil))
            (Sassign (Evar _gSaveFileModified tschar)
              (Econst_int (Int.repr 0) tint)))))
      Sskip))
  (Scall None (Evar _save_main_menu_data (Tfunction nil tvoid cc_default))
    nil))
|}.

Definition f_save_file_erase := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_fileIndex, tint) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _touch_high_score_ages (Tfunction (tint :: nil) tvoid cc_default))
    ((Etempvar _fileIndex tint) :: nil))
  (Ssequence
    (Scall None
      (Evar _bzero (Tfunction ((tptr tvoid) :: tuint :: nil) tvoid
                     cc_default))
      ((Ebinop Oadd
         (Ederef
           (Ebinop Oadd
             (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr)) _files
               (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
             (Etempvar _fileIndex tint)
             (tptr (tarray (Tstruct _SaveFile noattr) 2)))
           (tarray (Tstruct _SaveFile noattr) 2))
         (Econst_int (Int.repr 0) tint) (tptr (Tstruct _SaveFile noattr))) ::
       (Esizeof (Tstruct _SaveFile noattr) tuint) :: nil))
    (Ssequence
      (Sassign (Evar _gSaveFileModified tschar)
        (Econst_int (Int.repr 1) tint))
      (Scall None
        (Evar _save_file_do_save (Tfunction (tint :: nil) tvoid cc_default))
        ((Etempvar _fileIndex tint) :: nil)))))
|}.

Definition f_save_file_copy := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_srcFileIndex, tint) :: (_destFileIndex, tint) :: nil);
  fn_vars := ((_filler, (tarray tuchar 4)) :: nil);
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _touch_high_score_ages (Tfunction (tint :: nil) tvoid cc_default))
    ((Etempvar _destFileIndex tint) :: nil))
  (Ssequence
    (Scall None
      (Evar _bcopy (Tfunction ((tptr tvoid) :: (tptr tvoid) :: tuint :: nil)
                     tvoid cc_default))
      ((Ebinop Oadd
         (Ederef
           (Ebinop Oadd
             (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr)) _files
               (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
             (Etempvar _srcFileIndex tint)
             (tptr (tarray (Tstruct _SaveFile noattr) 2)))
           (tarray (Tstruct _SaveFile noattr) 2))
         (Econst_int (Int.repr 0) tint) (tptr (Tstruct _SaveFile noattr))) ::
       (Ebinop Oadd
         (Ederef
           (Ebinop Oadd
             (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr)) _files
               (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
             (Etempvar _destFileIndex tint)
             (tptr (tarray (Tstruct _SaveFile noattr) 2)))
           (tarray (Tstruct _SaveFile noattr) 2))
         (Econst_int (Int.repr 0) tint) (tptr (Tstruct _SaveFile noattr))) ::
       (Esizeof (Tstruct _SaveFile noattr) tuint) :: nil))
    (Ssequence
      (Sassign (Evar _gSaveFileModified tschar)
        (Econst_int (Int.repr 1) tint))
      (Scall None
        (Evar _save_file_do_save (Tfunction (tint :: nil) tvoid cc_default))
        ((Etempvar _destFileIndex tint) :: nil)))))
|}.

Definition f_save_file_load_all := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_file, tint) :: (_validSlots, tint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _gMainMenuDataModified tschar)
    (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sassign (Evar _gSaveFileModified tschar) (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Scall None
        (Evar _bzero (Tfunction ((tptr tvoid) :: tuint :: nil) tvoid
                       cc_default))
        ((Eaddrof (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
           (tptr (Tstruct _SaveBuffer noattr))) ::
         (Esizeof (Tstruct _SaveBuffer noattr) tuint) :: nil))
      (Ssequence
        (Scall None
          (Evar _read_eeprom_data (Tfunction ((tptr tvoid) :: tint :: nil)
                                    tint cc_default))
          ((Eaddrof (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
             (tptr (Tstruct _SaveBuffer noattr))) ::
           (Esizeof (Tstruct _SaveBuffer noattr) tuint) :: nil))
        (Ssequence
          (Ssequence
            (Scall (Some _t'1)
              (Evar _verify_save_block_signature (Tfunction
                                                   ((tptr tvoid) :: tint ::
                                                    tushort :: nil) tint
                                                   cc_default))
              ((Ebinop Oadd
                 (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                   _menuData (tarray (Tstruct _MainMenuSaveData noattr) 2))
                 (Econst_int (Int.repr 0) tint)
                 (tptr (Tstruct _MainMenuSaveData noattr))) ::
               (Esizeof (Tstruct _MainMenuSaveData noattr) tuint) ::
               (Econst_int (Int.repr 18505) tint) :: nil))
            (Sset _validSlots (Etempvar _t'1 tint)))
          (Ssequence
            (Ssequence
              (Scall (Some _t'2)
                (Evar _verify_save_block_signature (Tfunction
                                                     ((tptr tvoid) :: tint ::
                                                      tushort :: nil) tint
                                                     cc_default))
                ((Ebinop Oadd
                   (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                     _menuData (tarray (Tstruct _MainMenuSaveData noattr) 2))
                   (Econst_int (Int.repr 1) tint)
                   (tptr (Tstruct _MainMenuSaveData noattr))) ::
                 (Esizeof (Tstruct _MainMenuSaveData noattr) tuint) ::
                 (Econst_int (Int.repr 18505) tint) :: nil))
              (Sset _validSlots
                (Ebinop Oor (Etempvar _validSlots tint)
                  (Ebinop Oshl (Etempvar _t'2 tint)
                    (Econst_int (Int.repr 1) tint) tint) tint)))
            (Ssequence
              (Sswitch (Etempvar _validSlots tint)
                (LScons (Some 0)
                  (Ssequence
                    (Scall None
                      (Evar _wipe_main_menu_data (Tfunction nil tvoid
                                                   cc_default)) nil)
                    Sbreak)
                  (LScons (Some 1)
                    (Ssequence
                      (Scall None
                        (Evar _restore_main_menu_data (Tfunction
                                                        (tint :: nil) tvoid
                                                        cc_default))
                        ((Econst_int (Int.repr 0) tint) :: nil))
                      Sbreak)
                    (LScons (Some 2)
                      (Ssequence
                        (Scall None
                          (Evar _restore_main_menu_data (Tfunction
                                                          (tint :: nil) tvoid
                                                          cc_default))
                          ((Econst_int (Int.repr 1) tint) :: nil))
                        Sbreak)
                      LSnil))))
              (Ssequence
                (Ssequence
                  (Sset _file (Econst_int (Int.repr 0) tint))
                  (Sloop
                    (Ssequence
                      (Sifthenelse (Ebinop Olt (Etempvar _file tint)
                                     (Econst_int (Int.repr 4) tint) tint)
                        Sskip
                        Sbreak)
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'3)
                            (Evar _verify_save_block_signature (Tfunction
                                                                 ((tptr tvoid) ::
                                                                  tint ::
                                                                  tushort ::
                                                                  nil) tint
                                                                 cc_default))
                            ((Ebinop Oadd
                               (Ederef
                                 (Ebinop Oadd
                                   (Efield
                                     (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                                     _files
                                     (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                                   (Etempvar _file tint)
                                   (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                                 (tarray (Tstruct _SaveFile noattr) 2))
                               (Econst_int (Int.repr 0) tint)
                               (tptr (Tstruct _SaveFile noattr))) ::
                             (Esizeof (Tstruct _SaveFile noattr) tuint) ::
                             (Econst_int (Int.repr 17473) tint) :: nil))
                          (Sset _validSlots (Etempvar _t'3 tint)))
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'4)
                              (Evar _verify_save_block_signature (Tfunction
                                                                   ((tptr tvoid) ::
                                                                    tint ::
                                                                    tushort ::
                                                                    nil) tint
                                                                   cc_default))
                              ((Ebinop Oadd
                                 (Ederef
                                   (Ebinop Oadd
                                     (Efield
                                       (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                                       _files
                                       (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                                     (Etempvar _file tint)
                                     (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                                   (tarray (Tstruct _SaveFile noattr) 2))
                                 (Econst_int (Int.repr 1) tint)
                                 (tptr (Tstruct _SaveFile noattr))) ::
                               (Esizeof (Tstruct _SaveFile noattr) tuint) ::
                               (Econst_int (Int.repr 17473) tint) :: nil))
                            (Sset _validSlots
                              (Ebinop Oor (Etempvar _validSlots tint)
                                (Ebinop Oshl (Etempvar _t'4 tint)
                                  (Econst_int (Int.repr 1) tint) tint) tint)))
                          (Sswitch (Etempvar _validSlots tint)
                            (LScons (Some 0)
                              (Ssequence
                                (Scall None
                                  (Evar _save_file_erase (Tfunction
                                                           (tint :: nil)
                                                           tvoid cc_default))
                                  ((Etempvar _file tint) :: nil))
                                Sbreak)
                              (LScons (Some 1)
                                (Ssequence
                                  (Scall None
                                    (Evar _restore_save_file_data (Tfunction
                                                                    (tint ::
                                                                    tint ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                    ((Etempvar _file tint) ::
                                     (Econst_int (Int.repr 0) tint) :: nil))
                                  Sbreak)
                                (LScons (Some 2)
                                  (Ssequence
                                    (Scall None
                                      (Evar _restore_save_file_data (Tfunction
                                                                    (tint ::
                                                                    tint ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                      ((Etempvar _file tint) ::
                                       (Econst_int (Int.repr 1) tint) :: nil))
                                    Sbreak)
                                  LSnil)))))))
                    (Sset _file
                      (Ebinop Oadd (Etempvar _file tint)
                        (Econst_int (Int.repr 1) tint) tint))))
                (Scall None
                  (Evar _stub_save_file_1 (Tfunction nil tvoid cc_default))
                  nil)))))))))
|}.

Definition f_save_file_reload := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, tshort) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1 (Evar _gCurrSaveFileNum tshort))
    (Ssequence
      (Sset _t'2 (Evar _gCurrSaveFileNum tshort))
      (Scall None
        (Evar _bcopy (Tfunction
                       ((tptr tvoid) :: (tptr tvoid) :: tuint :: nil) tvoid
                       cc_default))
        ((Ebinop Oadd
           (Ederef
             (Ebinop Oadd
               (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                 _files (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
               (Ebinop Osub (Etempvar _t'1 tshort)
                 (Econst_int (Int.repr 1) tint) tint)
               (tptr (tarray (Tstruct _SaveFile noattr) 2)))
             (tarray (Tstruct _SaveFile noattr) 2))
           (Econst_int (Int.repr 1) tint) (tptr (Tstruct _SaveFile noattr))) ::
         (Ebinop Oadd
           (Ederef
             (Ebinop Oadd
               (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                 _files (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
               (Ebinop Osub (Etempvar _t'2 tshort)
                 (Econst_int (Int.repr 1) tint) tint)
               (tptr (tarray (Tstruct _SaveFile noattr) 2)))
             (tarray (Tstruct _SaveFile noattr) 2))
           (Econst_int (Int.repr 0) tint) (tptr (Tstruct _SaveFile noattr))) ::
         (Esizeof (Tstruct _SaveFile noattr) tuint) :: nil))))
  (Ssequence
    (Scall None
      (Evar _bcopy (Tfunction ((tptr tvoid) :: (tptr tvoid) :: tuint :: nil)
                     tvoid cc_default))
      ((Ebinop Oadd
         (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr)) _menuData
           (tarray (Tstruct _MainMenuSaveData noattr) 2))
         (Econst_int (Int.repr 1) tint)
         (tptr (Tstruct _MainMenuSaveData noattr))) ::
       (Ebinop Oadd
         (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr)) _menuData
           (tarray (Tstruct _MainMenuSaveData noattr) 2))
         (Econst_int (Int.repr 0) tint)
         (tptr (Tstruct _MainMenuSaveData noattr))) ::
       (Esizeof (Tstruct _MainMenuSaveData noattr) tuint) :: nil))
    (Ssequence
      (Sassign (Evar _gMainMenuDataModified tschar)
        (Econst_int (Int.repr 0) tint))
      (Sassign (Evar _gSaveFileModified tschar)
        (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_save_file_collect_star_or_key := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_coinScore, tshort) :: (_starIndex, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_fileIndex, tint) :: (_courseIndex, tint) ::
               (_starFlag, tint) :: (_flags, tint) :: (_t'7, tuint) ::
               (_t'6, tuint) :: (_t'5, tuint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'10, tshort) :: (_t'9, tshort) :: (_t'8, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'10 (Evar _gCurrSaveFileNum tshort))
    (Sset _fileIndex
      (Ebinop Osub (Etempvar _t'10 tshort) (Econst_int (Int.repr 1) tint)
        tint)))
  (Ssequence
    (Ssequence
      (Sset _t'9 (Evar _gCurrCourseNum tshort))
      (Sset _courseIndex
        (Ebinop Osub (Etempvar _t'9 tshort) (Econst_int (Int.repr 1) tint)
          tint)))
    (Ssequence
      (Sset _starFlag
        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
          (Etempvar _starIndex tshort) tint))
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _save_file_get_flags (Tfunction nil tuint cc_default)) nil)
          (Sset _flags (Etempvar _t'1 tuint)))
        (Ssequence
          (Sassign (Evar _gLastCompletedCourseNum tuchar)
            (Ebinop Oadd (Etempvar _courseIndex tint)
              (Econst_int (Int.repr 1) tint) tint))
          (Ssequence
            (Sassign (Evar _gLastCompletedStarNum tuchar)
              (Ebinop Oadd (Etempvar _starIndex tshort)
                (Econst_int (Int.repr 1) tint) tint))
            (Ssequence
              (Sassign (Evar _sUnusedGotGlobalCoinHiScore tschar)
                (Econst_int (Int.repr 0) tint))
              (Ssequence
                (Sassign (Evar _gGotFileCoinHiScore tuchar)
                  (Econst_int (Int.repr 0) tint))
                (Ssequence
                  (Ssequence
                    (Sifthenelse (Ebinop Oge (Etempvar _courseIndex tint)
                                   (Ebinop Osub
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 1) tint) tint)
                                   tint)
                      (Sset _t'4
                        (Ecast
                          (Ebinop Ole (Etempvar _courseIndex tint)
                            (Ebinop Osub (Econst_int (Int.repr 15) tint)
                              (Econst_int (Int.repr 1) tint) tint) tint)
                          tbool))
                      (Sset _t'4 (Econst_int (Int.repr 0) tint)))
                    (Sifthenelse (Etempvar _t'4 tint)
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'2)
                            (Evar _save_file_get_max_coin_score (Tfunction
                                                                  (tint ::
                                                                   nil) tuint
                                                                  cc_default))
                            ((Etempvar _courseIndex tint) :: nil))
                          (Sifthenelse (Ebinop Ogt
                                         (Etempvar _coinScore tshort)
                                         (Ebinop Oand
                                           (Ecast (Etempvar _t'2 tuint)
                                             tushort)
                                           (Econst_int (Int.repr 65535) tint)
                                           tint) tint)
                            (Sassign
                              (Evar _sUnusedGotGlobalCoinHiScore tschar)
                              (Econst_int (Int.repr 1) tint))
                            Sskip))
                        (Ssequence
                          (Scall (Some _t'3)
                            (Evar _save_file_get_course_coin_score (Tfunction
                                                                    (tint ::
                                                                    tint ::
                                                                    nil) tint
                                                                    cc_default))
                            ((Etempvar _fileIndex tint) ::
                             (Etempvar _courseIndex tint) :: nil))
                          (Sifthenelse (Ebinop Ogt
                                         (Etempvar _coinScore tshort)
                                         (Etempvar _t'3 tint) tint)
                            (Ssequence
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Ederef
                                            (Ebinop Oadd
                                              (Efield
                                                (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                                                _files
                                                (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                                              (Etempvar _fileIndex tint)
                                              (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                                            (tarray (Tstruct _SaveFile noattr) 2))
                                          (Econst_int (Int.repr 0) tint)
                                          (tptr (Tstruct _SaveFile noattr)))
                                        (Tstruct _SaveFile noattr))
                                      _courseCoinScores (tarray tuchar 15))
                                    (Etempvar _courseIndex tint)
                                    (tptr tuchar)) tuchar)
                                (Etempvar _coinScore tshort))
                              (Ssequence
                                (Scall None
                                  (Evar _touch_coin_score_age (Tfunction
                                                                (tint ::
                                                                 tint :: nil)
                                                                tvoid
                                                                cc_default))
                                  ((Etempvar _fileIndex tint) ::
                                   (Etempvar _courseIndex tint) :: nil))
                                (Ssequence
                                  (Sassign (Evar _gGotFileCoinHiScore tuchar)
                                    (Econst_int (Int.repr 1) tint))
                                  (Sassign (Evar _gSaveFileModified tschar)
                                    (Econst_int (Int.repr 1) tint)))))
                            Sskip)))
                      Sskip))
                  (Ssequence
                    (Sset _t'8 (Evar _gCurrLevelNum tshort))
                    (Sswitch (Etempvar _t'8 tshort)
                      (LScons (Some 30)
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'5)
                              (Evar _save_file_get_flags (Tfunction nil tuint
                                                           cc_default)) nil)
                            (Sifthenelse (Eunop Onotbool
                                           (Ebinop Oand (Etempvar _t'5 tuint)
                                             (Ebinop Oor
                                               (Ebinop Oshl
                                                 (Econst_int (Int.repr 1) tint)
                                                 (Econst_int (Int.repr 4) tint)
                                                 tint)
                                               (Ebinop Oshl
                                                 (Econst_int (Int.repr 1) tint)
                                                 (Econst_int (Int.repr 6) tint)
                                                 tint) tint) tuint) tint)
                              (Scall None
                                (Evar _save_file_set_flags (Tfunction
                                                             (tuint :: nil)
                                                             tvoid
                                                             cc_default))
                                ((Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                   (Econst_int (Int.repr 4) tint) tint) ::
                                 nil))
                              Sskip))
                          Sbreak)
                        (LScons (Some 33)
                          (Ssequence
                            (Ssequence
                              (Scall (Some _t'6)
                                (Evar _save_file_get_flags (Tfunction nil
                                                             tuint
                                                             cc_default))
                                nil)
                              (Sifthenelse (Eunop Onotbool
                                             (Ebinop Oand
                                               (Etempvar _t'6 tuint)
                                               (Ebinop Oor
                                                 (Ebinop Oshl
                                                   (Econst_int (Int.repr 1) tint)
                                                   (Econst_int (Int.repr 5) tint)
                                                   tint)
                                                 (Ebinop Oshl
                                                   (Econst_int (Int.repr 1) tint)
                                                   (Econst_int (Int.repr 7) tint)
                                                   tint) tint) tuint) tint)
                                (Scall None
                                  (Evar _save_file_set_flags (Tfunction
                                                               (tuint :: nil)
                                                               tvoid
                                                               cc_default))
                                  ((Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 5) tint) tint) ::
                                   nil))
                                Sskip))
                            Sbreak)
                          (LScons (Some 34)
                            Sbreak
                            (LScons None
                              (Ssequence
                                (Ssequence
                                  (Scall (Some _t'7)
                                    (Evar _save_file_get_star_flags (Tfunction
                                                                    (tint ::
                                                                    tint ::
                                                                    nil)
                                                                    tuint
                                                                    cc_default))
                                    ((Etempvar _fileIndex tint) ::
                                     (Etempvar _courseIndex tint) :: nil))
                                  (Sifthenelse (Eunop Onotbool
                                                 (Ebinop Oand
                                                   (Etempvar _t'7 tuint)
                                                   (Etempvar _starFlag tint)
                                                   tuint) tint)
                                    (Scall None
                                      (Evar _save_file_set_star_flags 
                                      (Tfunction
                                        (tint :: tint :: tuint :: nil) tvoid
                                        cc_default))
                                      ((Etempvar _fileIndex tint) ::
                                       (Etempvar _courseIndex tint) ::
                                       (Etempvar _starFlag tint) :: nil))
                                    Sskip))
                                Sbreak)
                              LSnil)))))))))))))))
|}.

Definition f_save_file_exists := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_fileIndex, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Efield
      (Ederef
        (Ebinop Oadd
          (Ederef
            (Ebinop Oadd
              (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr)) _files
                (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
              (Etempvar _fileIndex tint)
              (tptr (tarray (Tstruct _SaveFile noattr) 2)))
            (tarray (Tstruct _SaveFile noattr) 2))
          (Econst_int (Int.repr 0) tint) (tptr (Tstruct _SaveFile noattr)))
        (Tstruct _SaveFile noattr)) _flags tuint))
  (Sreturn (Some (Ebinop One
                   (Ebinop Oand (Etempvar _t'1 tuint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 0) tint) tint) tuint)
                   (Econst_int (Int.repr 0) tint) tint))))
|}.

Definition f_save_file_get_max_coin_score := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_courseIndex, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_fileIndex, tint) :: (_maxCoinScore, tint) ::
               (_maxScoreAge, tint) :: (_maxScoreFileNum, tint) ::
               (_coinScore, tint) :: (_scoreAge, tint) :: (_t'5, tint) ::
               (_t'4, tuint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _maxCoinScore (Eunop Oneg (Econst_int (Int.repr 1) tint) tint))
  (Ssequence
    (Sset _maxScoreAge (Eunop Oneg (Econst_int (Int.repr 1) tint) tint))
    (Ssequence
      (Sset _maxScoreFileNum (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Ssequence
          (Sset _fileIndex (Econst_int (Int.repr 0) tint))
          (Sloop
            (Ssequence
              (Sifthenelse (Ebinop Olt (Etempvar _fileIndex tint)
                             (Econst_int (Int.repr 4) tint) tint)
                Sskip
                Sbreak)
              (Ssequence
                (Scall (Some _t'4)
                  (Evar _save_file_get_star_flags (Tfunction
                                                    (tint :: tint :: nil)
                                                    tuint cc_default))
                  ((Etempvar _fileIndex tint) ::
                   (Etempvar _courseIndex tint) :: nil))
                (Sifthenelse (Ebinop One (Etempvar _t'4 tuint)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'1)
                        (Evar _save_file_get_course_coin_score (Tfunction
                                                                 (tint ::
                                                                  tint ::
                                                                  nil) tint
                                                                 cc_default))
                        ((Etempvar _fileIndex tint) ::
                         (Etempvar _courseIndex tint) :: nil))
                      (Sset _coinScore (Etempvar _t'1 tint)))
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'2)
                          (Evar _get_coin_score_age (Tfunction
                                                      (tint :: tint :: nil)
                                                      tint cc_default))
                          ((Etempvar _fileIndex tint) ::
                           (Etempvar _courseIndex tint) :: nil))
                        (Sset _scoreAge (Etempvar _t'2 tint)))
                      (Ssequence
                        (Sifthenelse (Ebinop Ogt (Etempvar _coinScore tint)
                                       (Etempvar _maxCoinScore tint) tint)
                          (Sset _t'3 (Econst_int (Int.repr 1) tint))
                          (Sifthenelse (Ebinop Oeq (Etempvar _coinScore tint)
                                         (Etempvar _maxCoinScore tint) tint)
                            (Ssequence
                              (Sset _t'3
                                (Ecast
                                  (Ebinop Ogt (Etempvar _scoreAge tint)
                                    (Etempvar _maxScoreAge tint) tint) tbool))
                              (Sset _t'3 (Ecast (Etempvar _t'3 tint) tbool)))
                            (Sset _t'3
                              (Ecast (Econst_int (Int.repr 0) tint) tbool))))
                        (Sifthenelse (Etempvar _t'3 tint)
                          (Ssequence
                            (Sset _maxCoinScore (Etempvar _coinScore tint))
                            (Ssequence
                              (Sset _maxScoreAge (Etempvar _scoreAge tint))
                              (Sset _maxScoreFileNum
                                (Ebinop Oadd (Etempvar _fileIndex tint)
                                  (Econst_int (Int.repr 1) tint) tint))))
                          Sskip))))
                  Sskip)))
            (Sset _fileIndex
              (Ebinop Oadd (Etempvar _fileIndex tint)
                (Econst_int (Int.repr 1) tint) tint))))
        (Ssequence
          (Sifthenelse (Ebinop Ogt (Etempvar _maxCoinScore tint)
                         (Econst_int (Int.repr 0) tint) tint)
            (Sset _t'5 (Ecast (Etempvar _maxCoinScore tint) tint))
            (Sset _t'5 (Ecast (Econst_int (Int.repr 0) tint) tint)))
          (Sreturn (Some (Ebinop Oadd
                           (Ebinop Oshl (Etempvar _maxScoreFileNum tint)
                             (Econst_int (Int.repr 16) tint) tint)
                           (Etempvar _t'5 tint) tint))))))))
|}.

Definition f_save_file_get_course_star_count := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_fileIndex, tint) :: (_courseIndex, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_count, tint) :: (_flag, tuchar) ::
               (_starFlags, tuchar) :: (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _count (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sset _flag (Ecast (Econst_int (Int.repr 1) tint) tuchar))
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _save_file_get_star_flags (Tfunction (tint :: tint :: nil)
                                            tuint cc_default))
          ((Etempvar _fileIndex tint) :: (Etempvar _courseIndex tint) :: nil))
        (Sset _starFlags (Ecast (Etempvar _t'1 tuint) tuchar)))
      (Ssequence
        (Ssequence
          (Sset _i (Econst_int (Int.repr 0) tint))
          (Sloop
            (Ssequence
              (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                             (Econst_int (Int.repr 7) tint) tint)
                Sskip
                Sbreak)
              (Sifthenelse (Ebinop Oand (Etempvar _starFlags tuchar)
                             (Etempvar _flag tuchar) tint)
                (Sset _count
                  (Ebinop Oadd (Etempvar _count tint)
                    (Econst_int (Int.repr 1) tint) tint))
                Sskip))
            (Ssequence
              (Sset _i
                (Ebinop Oadd (Etempvar _i tint)
                  (Econst_int (Int.repr 1) tint) tint))
              (Sset _flag
                (Ecast
                  (Ebinop Oshl (Etempvar _flag tuchar)
                    (Econst_int (Int.repr 1) tint) tint) tuchar)))))
        (Sreturn (Some (Etempvar _count tint)))))))
|}.

Definition f_save_file_get_total_star_count := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_fileIndex, tint) :: (_minCourse, tint) ::
                (_maxCourse, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_count, tint) :: (_t'2, tint) :: (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _count (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sloop
      (Ssequence
        (Sifthenelse (Ebinop Ole (Etempvar _minCourse tint)
                       (Etempvar _maxCourse tint) tint)
          Sskip
          Sbreak)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _save_file_get_course_star_count (Tfunction
                                                     (tint :: tint :: nil)
                                                     tint cc_default))
            ((Etempvar _fileIndex tint) :: (Etempvar _minCourse tint) :: nil))
          (Sset _count
            (Ebinop Oadd (Etempvar _count tint) (Etempvar _t'1 tint) tint))))
      (Sset _minCourse
        (Ebinop Oadd (Etempvar _minCourse tint)
          (Econst_int (Int.repr 1) tint) tint)))
    (Ssequence
      (Scall (Some _t'2)
        (Evar _save_file_get_course_star_count (Tfunction
                                                 (tint :: tint :: nil) tint
                                                 cc_default))
        ((Etempvar _fileIndex tint) ::
         (Ebinop Osub (Econst_int (Int.repr 0) tint)
           (Econst_int (Int.repr 1) tint) tint) :: nil))
      (Sreturn (Some (Ebinop Oadd (Etempvar _t'2 tint) (Etempvar _count tint)
                       tint))))))
|}.

Definition f_save_file_set_flags := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_flags, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tuint) :: (_t'2, tshort) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1 (Evar _gCurrSaveFileNum tshort))
    (Ssequence
      (Sset _t'2 (Evar _gCurrSaveFileNum tshort))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef
              (Ebinop Oadd
                (Ederef
                  (Ebinop Oadd
                    (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                      _files
                      (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                    (Ebinop Osub (Etempvar _t'2 tshort)
                      (Econst_int (Int.repr 1) tint) tint)
                    (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                  (tarray (Tstruct _SaveFile noattr) 2))
                (Econst_int (Int.repr 0) tint)
                (tptr (Tstruct _SaveFile noattr)))
              (Tstruct _SaveFile noattr)) _flags tuint))
        (Sassign
          (Efield
            (Ederef
              (Ebinop Oadd
                (Ederef
                  (Ebinop Oadd
                    (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                      _files
                      (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                    (Ebinop Osub (Etempvar _t'1 tshort)
                      (Econst_int (Int.repr 1) tint) tint)
                    (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                  (tarray (Tstruct _SaveFile noattr) 2))
                (Econst_int (Int.repr 0) tint)
                (tptr (Tstruct _SaveFile noattr)))
              (Tstruct _SaveFile noattr)) _flags tuint)
          (Ebinop Oor (Etempvar _t'3 tuint)
            (Ebinop Oor (Etempvar _flags tuint)
              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 0) tint) tint) tuint) tuint)))))
  (Sassign (Evar _gSaveFileModified tschar) (Econst_int (Int.repr 1) tint)))
|}.

Definition f_save_file_clear_flags := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_flags, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'6, tuint) :: (_t'5, tshort) :: (_t'4, tshort) ::
               (_t'3, tuint) :: (_t'2, tshort) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _gCurrSaveFileNum tshort))
    (Ssequence
      (Sset _t'5 (Evar _gCurrSaveFileNum tshort))
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef
              (Ebinop Oadd
                (Ederef
                  (Ebinop Oadd
                    (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                      _files
                      (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                    (Ebinop Osub (Etempvar _t'5 tshort)
                      (Econst_int (Int.repr 1) tint) tint)
                    (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                  (tarray (Tstruct _SaveFile noattr) 2))
                (Econst_int (Int.repr 0) tint)
                (tptr (Tstruct _SaveFile noattr)))
              (Tstruct _SaveFile noattr)) _flags tuint))
        (Sassign
          (Efield
            (Ederef
              (Ebinop Oadd
                (Ederef
                  (Ebinop Oadd
                    (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                      _files
                      (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                    (Ebinop Osub (Etempvar _t'4 tshort)
                      (Econst_int (Int.repr 1) tint) tint)
                    (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                  (tarray (Tstruct _SaveFile noattr) 2))
                (Econst_int (Int.repr 0) tint)
                (tptr (Tstruct _SaveFile noattr)))
              (Tstruct _SaveFile noattr)) _flags tuint)
          (Ebinop Oand (Etempvar _t'6 tuint)
            (Eunop Onotint (Etempvar _flags tuint) tuint) tuint)))))
  (Ssequence
    (Ssequence
      (Sset _t'1 (Evar _gCurrSaveFileNum tshort))
      (Ssequence
        (Sset _t'2 (Evar _gCurrSaveFileNum tshort))
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                        _files
                        (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                      (Ebinop Osub (Etempvar _t'2 tshort)
                        (Econst_int (Int.repr 1) tint) tint)
                      (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                    (tarray (Tstruct _SaveFile noattr) 2))
                  (Econst_int (Int.repr 0) tint)
                  (tptr (Tstruct _SaveFile noattr)))
                (Tstruct _SaveFile noattr)) _flags tuint))
          (Sassign
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                        _files
                        (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                      (Ebinop Osub (Etempvar _t'1 tshort)
                        (Econst_int (Int.repr 1) tint) tint)
                      (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                    (tarray (Tstruct _SaveFile noattr) 2))
                  (Econst_int (Int.repr 0) tint)
                  (tptr (Tstruct _SaveFile noattr)))
                (Tstruct _SaveFile noattr)) _flags tuint)
            (Ebinop Oor (Etempvar _t'3 tuint)
              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 0) tint) tint) tuint)))))
    (Sassign (Evar _gSaveFileModified tschar) (Econst_int (Int.repr 1) tint))))
|}.

Definition f_save_file_get_flags := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'5, (tptr (Tstruct _DemoInput noattr))) ::
               (_t'4, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'3, tuint) :: (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'4
        (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
      (Sifthenelse (Ebinop One
                     (Etempvar _t'4 (tptr (Tstruct _CreditsEntry noattr)))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Sset _t'1 (Econst_int (Int.repr 1) tint))
        (Ssequence
          (Sset _t'5
            (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr))))
          (Sset _t'1
            (Ecast
              (Ebinop One (Etempvar _t'5 (tptr (Tstruct _DemoInput noattr)))
                (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
              tbool)))))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Econst_int (Int.repr 0) tint)))
      Sskip))
  (Ssequence
    (Sset _t'2 (Evar _gCurrSaveFileNum tshort))
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef
            (Ebinop Oadd
              (Ederef
                (Ebinop Oadd
                  (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                    _files (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                  (Ebinop Osub (Etempvar _t'2 tshort)
                    (Econst_int (Int.repr 1) tint) tint)
                  (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                (tarray (Tstruct _SaveFile noattr) 2))
              (Econst_int (Int.repr 0) tint)
              (tptr (Tstruct _SaveFile noattr))) (Tstruct _SaveFile noattr))
          _flags tuint))
      (Sreturn (Some (Etempvar _t'3 tuint))))))
|}.

Definition f_save_file_get_star_flags := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_fileIndex, tint) :: (_courseIndex, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_starFlags, tuint) :: (_t'2, tuint) :: (_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Oeq (Etempvar _courseIndex tint)
                 (Ebinop Osub (Econst_int (Int.repr 0) tint)
                   (Econst_int (Int.repr 1) tint) tint) tint)
    (Ssequence
      (Sset _t'2
        (Efield
          (Ederef
            (Ebinop Oadd
              (Ederef
                (Ebinop Oadd
                  (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                    _files (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                  (Etempvar _fileIndex tint)
                  (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                (tarray (Tstruct _SaveFile noattr) 2))
              (Econst_int (Int.repr 0) tint)
              (tptr (Tstruct _SaveFile noattr))) (Tstruct _SaveFile noattr))
          _flags tuint))
      (Sset _starFlags
        (Ebinop Oand
          (Ebinop Oshr (Etempvar _t'2 tuint) (Econst_int (Int.repr 24) tint)
            tuint) (Econst_int (Int.repr 127) tint) tuint)))
    (Ssequence
      (Sset _t'1
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                        _files
                        (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                      (Etempvar _fileIndex tint)
                      (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                    (tarray (Tstruct _SaveFile noattr) 2))
                  (Econst_int (Int.repr 0) tint)
                  (tptr (Tstruct _SaveFile noattr)))
                (Tstruct _SaveFile noattr)) _courseStars (tarray tuchar 25))
            (Etempvar _courseIndex tint) (tptr tuchar)) tuchar))
      (Sset _starFlags
        (Ebinop Oand (Etempvar _t'1 tuchar) (Econst_int (Int.repr 127) tint)
          tint))))
  (Sreturn (Some (Etempvar _starFlags tuint))))
|}.

Definition f_save_file_set_star_flags := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_fileIndex, tint) :: (_courseIndex, tint) ::
                (_starFlags, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tuint) :: (_t'2, tuchar) :: (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Oeq (Etempvar _courseIndex tint)
                 (Ebinop Osub (Econst_int (Int.repr 0) tint)
                   (Econst_int (Int.repr 1) tint) tint) tint)
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef
            (Ebinop Oadd
              (Ederef
                (Ebinop Oadd
                  (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                    _files (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                  (Etempvar _fileIndex tint)
                  (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                (tarray (Tstruct _SaveFile noattr) 2))
              (Econst_int (Int.repr 0) tint)
              (tptr (Tstruct _SaveFile noattr))) (Tstruct _SaveFile noattr))
          _flags tuint))
      (Sassign
        (Efield
          (Ederef
            (Ebinop Oadd
              (Ederef
                (Ebinop Oadd
                  (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                    _files (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                  (Etempvar _fileIndex tint)
                  (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                (tarray (Tstruct _SaveFile noattr) 2))
              (Econst_int (Int.repr 0) tint)
              (tptr (Tstruct _SaveFile noattr))) (Tstruct _SaveFile noattr))
          _flags tuint)
        (Ebinop Oor (Etempvar _t'3 tuint)
          (Ebinop Oshl (Etempvar _starFlags tuint)
            (Econst_int (Int.repr 24) tint) tuint) tuint)))
    (Ssequence
      (Sset _t'2
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                        _files
                        (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                      (Etempvar _fileIndex tint)
                      (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                    (tarray (Tstruct _SaveFile noattr) 2))
                  (Econst_int (Int.repr 0) tint)
                  (tptr (Tstruct _SaveFile noattr)))
                (Tstruct _SaveFile noattr)) _courseStars (tarray tuchar 25))
            (Etempvar _courseIndex tint) (tptr tuchar)) tuchar))
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                        _files
                        (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                      (Etempvar _fileIndex tint)
                      (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                    (tarray (Tstruct _SaveFile noattr) 2))
                  (Econst_int (Int.repr 0) tint)
                  (tptr (Tstruct _SaveFile noattr)))
                (Tstruct _SaveFile noattr)) _courseStars (tarray tuchar 25))
            (Etempvar _courseIndex tint) (tptr tuchar)) tuchar)
        (Ebinop Oor (Etempvar _t'2 tuchar) (Etempvar _starFlags tuint) tuint))))
  (Ssequence
    (Ssequence
      (Sset _t'1
        (Efield
          (Ederef
            (Ebinop Oadd
              (Ederef
                (Ebinop Oadd
                  (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                    _files (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                  (Etempvar _fileIndex tint)
                  (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                (tarray (Tstruct _SaveFile noattr) 2))
              (Econst_int (Int.repr 0) tint)
              (tptr (Tstruct _SaveFile noattr))) (Tstruct _SaveFile noattr))
          _flags tuint))
      (Sassign
        (Efield
          (Ederef
            (Ebinop Oadd
              (Ederef
                (Ebinop Oadd
                  (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                    _files (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                  (Etempvar _fileIndex tint)
                  (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                (tarray (Tstruct _SaveFile noattr) 2))
              (Econst_int (Int.repr 0) tint)
              (tptr (Tstruct _SaveFile noattr))) (Tstruct _SaveFile noattr))
          _flags tuint)
        (Ebinop Oor (Etempvar _t'1 tuint)
          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
            (Econst_int (Int.repr 0) tint) tint) tuint)))
    (Sassign (Evar _gSaveFileModified tschar) (Econst_int (Int.repr 1) tint))))
|}.

Definition f_save_file_get_course_coin_score := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_fileIndex, tint) :: (_courseIndex, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Ederef
      (Ebinop Oadd
        (Efield
          (Ederef
            (Ebinop Oadd
              (Ederef
                (Ebinop Oadd
                  (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                    _files (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                  (Etempvar _fileIndex tint)
                  (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                (tarray (Tstruct _SaveFile noattr) 2))
              (Econst_int (Int.repr 0) tint)
              (tptr (Tstruct _SaveFile noattr))) (Tstruct _SaveFile noattr))
          _courseCoinScores (tarray tuchar 15)) (Etempvar _courseIndex tint)
        (tptr tuchar)) tuchar))
  (Sreturn (Some (Etempvar _t'1 tuchar))))
|}.

Definition f_save_file_is_cannon_unlocked := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'3, tuchar) :: (_t'2, tshort) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _gCurrSaveFileNum tshort))
  (Ssequence
    (Sset _t'2 (Evar _gCurrCourseNum tshort))
    (Ssequence
      (Sset _t'3
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                        _files
                        (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                      (Ebinop Osub (Etempvar _t'1 tshort)
                        (Econst_int (Int.repr 1) tint) tint)
                      (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                    (tarray (Tstruct _SaveFile noattr) 2))
                  (Econst_int (Int.repr 0) tint)
                  (tptr (Tstruct _SaveFile noattr)))
                (Tstruct _SaveFile noattr)) _courseStars (tarray tuchar 25))
            (Etempvar _t'2 tshort) (tptr tuchar)) tuchar))
      (Sreturn (Some (Ebinop One
                       (Ebinop Oand (Etempvar _t'3 tuchar)
                         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 7) tint) tint) tint)
                       (Econst_int (Int.repr 0) tint) tint))))))
|}.

Definition f_save_file_set_cannon_unlocked := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'8, tuchar) :: (_t'7, tshort) :: (_t'6, tshort) ::
               (_t'5, tshort) :: (_t'4, tshort) :: (_t'3, tuint) ::
               (_t'2, tshort) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _gCurrSaveFileNum tshort))
    (Ssequence
      (Sset _t'5 (Evar _gCurrCourseNum tshort))
      (Ssequence
        (Sset _t'6 (Evar _gCurrSaveFileNum tshort))
        (Ssequence
          (Sset _t'7 (Evar _gCurrCourseNum tshort))
          (Ssequence
            (Sset _t'8
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                              _files
                              (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                            (Ebinop Osub (Etempvar _t'6 tshort)
                              (Econst_int (Int.repr 1) tint) tint)
                            (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                          (tarray (Tstruct _SaveFile noattr) 2))
                        (Econst_int (Int.repr 0) tint)
                        (tptr (Tstruct _SaveFile noattr)))
                      (Tstruct _SaveFile noattr)) _courseStars
                    (tarray tuchar 25)) (Etempvar _t'7 tshort) (tptr tuchar))
                tuchar))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                              _files
                              (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                            (Ebinop Osub (Etempvar _t'4 tshort)
                              (Econst_int (Int.repr 1) tint) tint)
                            (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                          (tarray (Tstruct _SaveFile noattr) 2))
                        (Econst_int (Int.repr 0) tint)
                        (tptr (Tstruct _SaveFile noattr)))
                      (Tstruct _SaveFile noattr)) _courseStars
                    (tarray tuchar 25)) (Etempvar _t'5 tshort) (tptr tuchar))
                tuchar)
              (Ebinop Oor (Etempvar _t'8 tuchar)
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 7) tint) tint) tint)))))))
  (Ssequence
    (Ssequence
      (Sset _t'1 (Evar _gCurrSaveFileNum tshort))
      (Ssequence
        (Sset _t'2 (Evar _gCurrSaveFileNum tshort))
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                        _files
                        (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                      (Ebinop Osub (Etempvar _t'2 tshort)
                        (Econst_int (Int.repr 1) tint) tint)
                      (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                    (tarray (Tstruct _SaveFile noattr) 2))
                  (Econst_int (Int.repr 0) tint)
                  (tptr (Tstruct _SaveFile noattr)))
                (Tstruct _SaveFile noattr)) _flags tuint))
          (Sassign
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                        _files
                        (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                      (Ebinop Osub (Etempvar _t'1 tshort)
                        (Econst_int (Int.repr 1) tint) tint)
                      (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                    (tarray (Tstruct _SaveFile noattr) 2))
                  (Econst_int (Int.repr 0) tint)
                  (tptr (Tstruct _SaveFile noattr)))
                (Tstruct _SaveFile noattr)) _flags tuint)
            (Ebinop Oor (Etempvar _t'3 tuint)
              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 0) tint) tint) tuint)))))
    (Sassign (Evar _gSaveFileModified tschar) (Econst_int (Int.repr 1) tint))))
|}.

Definition f_save_file_set_cap_pos := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_x, tshort) :: (_y, tshort) :: (_z, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_saveFile, (tptr (Tstruct _SaveFile noattr))) ::
               (_t'3, tshort) :: (_t'2, tshort) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3 (Evar _gCurrSaveFileNum tshort))
    (Sset _saveFile
      (Ebinop Oadd
        (Ederef
          (Ebinop Oadd
            (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr)) _files
              (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
            (Ebinop Osub (Etempvar _t'3 tshort)
              (Econst_int (Int.repr 1) tint) tint)
            (tptr (tarray (Tstruct _SaveFile noattr) 2)))
          (tarray (Tstruct _SaveFile noattr) 2))
        (Econst_int (Int.repr 0) tint) (tptr (Tstruct _SaveFile noattr)))))
  (Ssequence
    (Ssequence
      (Sset _t'2 (Evar _gCurrLevelNum tshort))
      (Sassign
        (Efield
          (Ederef (Etempvar _saveFile (tptr (Tstruct _SaveFile noattr)))
            (Tstruct _SaveFile noattr)) _capLevel tuchar)
        (Etempvar _t'2 tshort)))
    (Ssequence
      (Ssequence
        (Sset _t'1 (Evar _gCurrAreaIndex tshort))
        (Sassign
          (Efield
            (Ederef (Etempvar _saveFile (tptr (Tstruct _SaveFile noattr)))
              (Tstruct _SaveFile noattr)) _capArea tuchar)
          (Etempvar _t'1 tshort)))
      (Ssequence
        (Scall None
          (Evar _vec3s_set (Tfunction
                             ((tptr tshort) :: tshort :: tshort :: tshort ::
                              nil) (tptr tvoid) cc_default))
          ((Efield
             (Ederef (Etempvar _saveFile (tptr (Tstruct _SaveFile noattr)))
               (Tstruct _SaveFile noattr)) _capPos (tarray tshort 3)) ::
           (Etempvar _x tshort) :: (Etempvar _y tshort) ::
           (Etempvar _z tshort) :: nil))
        (Scall None
          (Evar _save_file_set_flags (Tfunction (tuint :: nil) tvoid
                                       cc_default))
          ((Ebinop Oshl (Econst_int (Int.repr 1) tint)
             (Econst_int (Int.repr 16) tint) tint) :: nil))))))
|}.

Definition f_save_file_get_cap_pos := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_capPos, (tptr tshort)) :: nil);
  fn_vars := nil;
  fn_temps := ((_saveFile, (tptr (Tstruct _SaveFile noattr))) ::
               (_flags, tint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tuint) :: (_t'8, tshort) :: (_t'7, tshort) ::
               (_t'6, tuchar) :: (_t'5, tshort) :: (_t'4, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8 (Evar _gCurrSaveFileNum tshort))
    (Sset _saveFile
      (Ebinop Oadd
        (Ederef
          (Ebinop Oadd
            (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr)) _files
              (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
            (Ebinop Osub (Etempvar _t'8 tshort)
              (Econst_int (Int.repr 1) tint) tint)
            (tptr (tarray (Tstruct _SaveFile noattr) 2)))
          (tarray (Tstruct _SaveFile noattr) 2))
        (Econst_int (Int.repr 0) tint) (tptr (Tstruct _SaveFile noattr)))))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _save_file_get_flags (Tfunction nil tuint cc_default)) nil)
      (Sset _flags (Etempvar _t'1 tuint)))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef
                  (Etempvar _saveFile (tptr (Tstruct _SaveFile noattr)))
                  (Tstruct _SaveFile noattr)) _capLevel tuchar))
            (Ssequence
              (Sset _t'5 (Evar _gCurrLevelNum tshort))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tuchar)
                             (Etempvar _t'5 tshort) tint)
                (Ssequence
                  (Sset _t'6
                    (Efield
                      (Ederef
                        (Etempvar _saveFile (tptr (Tstruct _SaveFile noattr)))
                        (Tstruct _SaveFile noattr)) _capArea tuchar))
                  (Ssequence
                    (Sset _t'7 (Evar _gCurrAreaIndex tshort))
                    (Sset _t'2
                      (Ecast
                        (Ebinop Oeq (Etempvar _t'6 tuchar)
                          (Etempvar _t'7 tshort) tint) tbool))))
                (Sset _t'2 (Econst_int (Int.repr 0) tint)))))
          (Sifthenelse (Etempvar _t'2 tint)
            (Sset _t'3
              (Ecast
                (Ebinop Oand (Etempvar _flags tint)
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 16) tint) tint) tint) tbool))
            (Sset _t'3 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'3 tint)
          (Ssequence
            (Scall None
              (Evar _vec3s_copy (Tfunction
                                  ((tptr tshort) :: (tptr tshort) :: nil)
                                  (tptr tvoid) cc_default))
              ((Etempvar _capPos (tptr tshort)) ::
               (Efield
                 (Ederef
                   (Etempvar _saveFile (tptr (Tstruct _SaveFile noattr)))
                   (Tstruct _SaveFile noattr)) _capPos (tarray tshort 3)) ::
               nil))
            (Sreturn (Some (Econst_int (Int.repr 1) tint))))
          Sskip))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_save_file_set_sound_mode := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_mode, tushort) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _set_sound_mode (Tfunction (tushort :: nil) tvoid cc_default))
    ((Etempvar _mode tushort) :: nil))
  (Ssequence
    (Sassign
      (Efield
        (Ederef
          (Ebinop Oadd
            (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
              _menuData (tarray (Tstruct _MainMenuSaveData noattr) 2))
            (Econst_int (Int.repr 0) tint)
            (tptr (Tstruct _MainMenuSaveData noattr)))
          (Tstruct _MainMenuSaveData noattr)) _soundMode tushort)
      (Etempvar _mode tushort))
    (Ssequence
      (Sassign (Evar _gMainMenuDataModified tschar)
        (Econst_int (Int.repr 1) tint))
      (Scall None
        (Evar _save_main_menu_data (Tfunction nil tvoid cc_default)) nil))))
|}.

Definition f_save_file_get_sound_mode := {|
  fn_return := tushort;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tushort) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Efield
      (Ederef
        (Ebinop Oadd
          (Efield (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr)) _menuData
            (tarray (Tstruct _MainMenuSaveData noattr) 2))
          (Econst_int (Int.repr 0) tint)
          (tptr (Tstruct _MainMenuSaveData noattr)))
        (Tstruct _MainMenuSaveData noattr)) _soundMode tushort))
  (Sreturn (Some (Etempvar _t'1 tushort))))
|}.

Definition f_save_file_move_cap_to_default_location := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: (_t'3, tuchar) :: (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Scall (Some _t'1)
    (Evar _save_file_get_flags (Tfunction nil tuint cc_default)) nil)
  (Sifthenelse (Ebinop Oand (Etempvar _t'1 tuint)
                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                   (Econst_int (Int.repr 16) tint) tint) tuint)
    (Ssequence
      (Ssequence
        (Sset _t'2 (Evar _gCurrSaveFileNum tshort))
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Evar _gSaveBuffer (Tstruct _SaveBuffer noattr))
                        _files
                        (tarray (tarray (Tstruct _SaveFile noattr) 2) 4))
                      (Ebinop Osub (Etempvar _t'2 tshort)
                        (Econst_int (Int.repr 1) tint) tint)
                      (tptr (tarray (Tstruct _SaveFile noattr) 2)))
                    (tarray (Tstruct _SaveFile noattr) 2))
                  (Econst_int (Int.repr 0) tint)
                  (tptr (Tstruct _SaveFile noattr)))
                (Tstruct _SaveFile noattr)) _capLevel tuchar))
          (Sswitch (Etempvar _t'3 tuchar)
            (LScons (Some 8)
              (Ssequence
                (Scall None
                  (Evar _save_file_set_flags (Tfunction (tuint :: nil) tvoid
                                               cc_default))
                  ((Ebinop Oshl (Econst_int (Int.repr 1) tint)
                     (Econst_int (Int.repr 17) tint) tint) :: nil))
                Sbreak)
              (LScons (Some 10)
                (Ssequence
                  (Scall None
                    (Evar _save_file_set_flags (Tfunction (tuint :: nil)
                                                 tvoid cc_default))
                    ((Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 19) tint) tint) :: nil))
                  Sbreak)
                (LScons (Some 36)
                  (Ssequence
                    (Scall None
                      (Evar _save_file_set_flags (Tfunction (tuint :: nil)
                                                   tvoid cc_default))
                      ((Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 18) tint) tint) :: nil))
                    Sbreak)
                  LSnil))))))
      (Scall None
        (Evar _save_file_clear_flags (Tfunction (tuint :: nil) tvoid
                                       cc_default))
        ((Ebinop Oshl (Econst_int (Int.repr 1) tint)
           (Econst_int (Int.repr 16) tint) tint) :: nil)))
    Sskip))
|}.

Definition f_disable_warp_checkpoint := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Sassign
  (Efield (Evar _gWarpCheckpoint (Tstruct _WarpCheckpoint noattr)) _courseNum
    tuchar) (Econst_int (Int.repr 0) tint))
|}.

Definition f_check_if_should_set_warp_checkpoint := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_warpNode, (tptr (Tstruct _WarpNode noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'6, tshort) :: (_t'5, tshort) :: (_t'4, tuchar) ::
               (_t'3, tuchar) :: (_t'2, tuchar) :: (_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Efield
      (Ederef (Etempvar _warpNode (tptr (Tstruct _WarpNode noattr)))
        (Tstruct _WarpNode noattr)) _destLevel tuchar))
  (Sifthenelse (Ebinop Oand (Etempvar _t'1 tuchar)
                 (Econst_int (Int.repr 128) tint) tint)
    (Ssequence
      (Ssequence
        (Sset _t'6 (Evar _gCurrActNum tshort))
        (Sassign
          (Efield (Evar _gWarpCheckpoint (Tstruct _WarpCheckpoint noattr))
            _actNum tuchar) (Etempvar _t'6 tshort)))
      (Ssequence
        (Ssequence
          (Sset _t'5 (Evar _gCurrCourseNum tshort))
          (Sassign
            (Efield (Evar _gWarpCheckpoint (Tstruct _WarpCheckpoint noattr))
              _courseNum tuchar) (Etempvar _t'5 tshort)))
        (Ssequence
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef
                  (Etempvar _warpNode (tptr (Tstruct _WarpNode noattr)))
                  (Tstruct _WarpNode noattr)) _destLevel tuchar))
            (Sassign
              (Efield
                (Evar _gWarpCheckpoint (Tstruct _WarpCheckpoint noattr))
                _levelID tuchar)
              (Ebinop Oand (Etempvar _t'4 tuchar)
                (Econst_int (Int.repr 127) tint) tint)))
          (Ssequence
            (Ssequence
              (Sset _t'3
                (Efield
                  (Ederef
                    (Etempvar _warpNode (tptr (Tstruct _WarpNode noattr)))
                    (Tstruct _WarpNode noattr)) _destArea tuchar))
              (Sassign
                (Efield
                  (Evar _gWarpCheckpoint (Tstruct _WarpCheckpoint noattr))
                  _areaNum tuchar) (Etempvar _t'3 tuchar)))
            (Ssequence
              (Sset _t'2
                (Efield
                  (Ederef
                    (Etempvar _warpNode (tptr (Tstruct _WarpNode noattr)))
                    (Tstruct _WarpNode noattr)) _destNode tuchar))
              (Sassign
                (Efield
                  (Evar _gWarpCheckpoint (Tstruct _WarpCheckpoint noattr))
                  _warpNode tuchar) (Etempvar _t'2 tuchar)))))))
    Sskip))
|}.

Definition f_check_warp_checkpoint := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_warpNode, (tptr (Tstruct _WarpNode noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_warpCheckpointActive, tshort) :: (_currCourseNum, tshort) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'11, tschar) ::
               (_t'10, tuchar) :: (_t'9, tshort) :: (_t'8, tuchar) ::
               (_t'7, tshort) :: (_t'6, tuchar) :: (_t'5, tuchar) ::
               (_t'4, tuchar) :: (_t'3, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _warpCheckpointActive (Ecast (Econst_int (Int.repr 0) tint) tshort))
  (Ssequence
    (Ssequence
      (Sset _t'10
        (Efield
          (Ederef (Etempvar _warpNode (tptr (Tstruct _WarpNode noattr)))
            (Tstruct _WarpNode noattr)) _destLevel tuchar))
      (Ssequence
        (Sset _t'11
          (Ederef
            (Ebinop Oadd (Evar _gLevelToCourseNumTable (tarray tschar 38))
              (Ebinop Osub
                (Ebinop Oand (Etempvar _t'10 tuchar)
                  (Econst_int (Int.repr 127) tint) tint)
                (Econst_int (Int.repr 1) tint) tint) (tptr tschar)) tschar))
        (Sset _currCourseNum (Ecast (Etempvar _t'11 tschar) tshort))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'8
              (Efield
                (Evar _gWarpCheckpoint (Tstruct _WarpCheckpoint noattr))
                _courseNum tuchar))
            (Sifthenelse (Ebinop One (Etempvar _t'8 tuchar)
                           (Econst_int (Int.repr 0) tint) tint)
              (Ssequence
                (Sset _t'9 (Evar _gSavedCourseNum tshort))
                (Sset _t'1
                  (Ecast
                    (Ebinop Oeq (Etempvar _t'9 tshort)
                      (Etempvar _currCourseNum tshort) tint) tbool)))
              (Sset _t'1 (Econst_int (Int.repr 0) tint))))
          (Sifthenelse (Etempvar _t'1 tint)
            (Ssequence
              (Sset _t'6
                (Efield
                  (Evar _gWarpCheckpoint (Tstruct _WarpCheckpoint noattr))
                  _actNum tuchar))
              (Ssequence
                (Sset _t'7 (Evar _gCurrActNum tshort))
                (Sset _t'2
                  (Ecast
                    (Ebinop Oeq (Etempvar _t'6 tuchar) (Etempvar _t'7 tshort)
                      tint) tbool))))
            (Sset _t'2 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'2 tint)
          (Ssequence
            (Ssequence
              (Sset _t'5
                (Efield
                  (Evar _gWarpCheckpoint (Tstruct _WarpCheckpoint noattr))
                  _levelID tuchar))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _warpNode (tptr (Tstruct _WarpNode noattr)))
                    (Tstruct _WarpNode noattr)) _destLevel tuchar)
                (Etempvar _t'5 tuchar)))
            (Ssequence
              (Ssequence
                (Sset _t'4
                  (Efield
                    (Evar _gWarpCheckpoint (Tstruct _WarpCheckpoint noattr))
                    _areaNum tuchar))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _warpNode (tptr (Tstruct _WarpNode noattr)))
                      (Tstruct _WarpNode noattr)) _destArea tuchar)
                  (Etempvar _t'4 tuchar)))
              (Ssequence
                (Ssequence
                  (Sset _t'3
                    (Efield
                      (Evar _gWarpCheckpoint (Tstruct _WarpCheckpoint noattr))
                      _warpNode tuchar))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _warpNode (tptr (Tstruct _WarpNode noattr)))
                        (Tstruct _WarpNode noattr)) _destNode tuchar)
                    (Etempvar _t'3 tuchar)))
                (Sset _warpCheckpointActive
                  (Ecast (Econst_int (Int.repr 1) tint) tshort)))))
          (Sassign
            (Efield (Evar _gWarpCheckpoint (Tstruct _WarpCheckpoint noattr))
              _courseNum tuchar) (Econst_int (Int.repr 0) tint))))
      (Sreturn (Some (Etempvar _warpCheckpointActive tshort))))))
|}.

Definition composites : list composite_definition :=
(Composite __249 Struct
   (Member_plain _f_odd tfloat :: Member_plain _f_even tfloat :: nil)
   noattr ::
 Composite __248 Union (Member_plain _f (Tstruct __249 noattr) :: nil) noattr ::
 Composite __251 Struct
   (Member_plain _at tulong :: Member_plain _v0 tulong ::
    Member_plain _v1 tulong :: Member_plain _a0 tulong ::
    Member_plain _a1 tulong :: Member_plain _a2 tulong ::
    Member_plain _a3 tulong :: Member_plain _t0 tulong ::
    Member_plain _t1 tulong :: Member_plain _t2 tulong ::
    Member_plain _t3 tulong :: Member_plain _t4 tulong ::
    Member_plain _t5 tulong :: Member_plain _t6 tulong ::
    Member_plain _t7 tulong :: Member_plain _s0 tulong ::
    Member_plain _s1 tulong :: Member_plain _s2 tulong ::
    Member_plain _s3 tulong :: Member_plain _s4 tulong ::
    Member_plain _s5 tulong :: Member_plain _s6 tulong ::
    Member_plain _s7 tulong :: Member_plain _t8 tulong ::
    Member_plain _t9 tulong :: Member_plain _gp tulong ::
    Member_plain _sp tulong :: Member_plain _s8 tulong ::
    Member_plain _ra tulong :: Member_plain _lo tulong ::
    Member_plain _hi tulong :: Member_plain _sr tuint ::
    Member_plain _pc tuint :: Member_plain _cause tuint ::
    Member_plain _badvaddr tuint :: Member_plain _rcp tuint ::
    Member_plain _fpcsr tuint :: Member_plain _fp0 (Tunion __248 noattr) ::
    Member_plain _fp2 (Tunion __248 noattr) ::
    Member_plain _fp4 (Tunion __248 noattr) ::
    Member_plain _fp6 (Tunion __248 noattr) ::
    Member_plain _fp8 (Tunion __248 noattr) ::
    Member_plain _fp10 (Tunion __248 noattr) ::
    Member_plain _fp12 (Tunion __248 noattr) ::
    Member_plain _fp14 (Tunion __248 noattr) ::
    Member_plain _fp16 (Tunion __248 noattr) ::
    Member_plain _fp18 (Tunion __248 noattr) ::
    Member_plain _fp20 (Tunion __248 noattr) ::
    Member_plain _fp22 (Tunion __248 noattr) ::
    Member_plain _fp24 (Tunion __248 noattr) ::
    Member_plain _fp26 (Tunion __248 noattr) ::
    Member_plain _fp28 (Tunion __248 noattr) ::
    Member_plain _fp30 (Tunion __248 noattr) :: nil)
   noattr ::
 Composite __253 Struct
   (Member_plain _flag tuint :: Member_plain _count tuint ::
    Member_plain _time tulong :: nil)
   noattr ::
 Composite _OSThread_s Struct
   (Member_plain _next (tptr (Tstruct _OSThread_s noattr)) ::
    Member_plain _priority tint ::
    Member_plain _queue (tptr (tptr (Tstruct _OSThread_s noattr))) ::
    Member_plain _tlnext (tptr (Tstruct _OSThread_s noattr)) ::
    Member_plain _state tushort :: Member_plain _flags tushort ::
    Member_plain _id tint :: Member_plain _fp tint ::
    Member_plain _thprof (tptr (Tstruct __253 noattr)) ::
    Member_plain _context (Tstruct __251 noattr) :: nil)
   noattr ::
 Composite _OSMesgQueue_s Struct
   (Member_plain _mtqueue (tptr (Tstruct _OSThread_s noattr)) ::
    Member_plain _fullqueue (tptr (Tstruct _OSThread_s noattr)) ::
    Member_plain _validCount tint :: Member_plain _first tint ::
    Member_plain _msgCount tint :: Member_plain _msg (tptr (tptr tvoid)) ::
    nil)
   noattr ::
 Composite _DemoInput Struct
   (Member_plain _timer tuchar :: Member_plain _rawStickX tschar ::
    Member_plain _rawStickY tschar :: Member_plain _buttonMask tuchar :: nil)
   noattr ::
 Composite _WarpNode Struct
   (Member_plain _id tuchar :: Member_plain _destLevel tuchar ::
    Member_plain _destArea tuchar :: Member_plain _destNode tuchar :: nil)
   noattr ::
 Composite _CreditsEntry Struct
   (Member_plain _levelNum tuchar :: Member_plain _areaIndex tuchar ::
    Member_plain _unk02 tuchar :: Member_plain _marioAngle tschar ::
    Member_plain _marioPos (tarray tshort 3) ::
    Member_plain _unk0C (tptr (tptr tuchar)) :: nil)
   noattr ::
 Composite _SaveBlockSignature Struct
   (Member_plain _magic tushort :: Member_plain _chksum tushort :: nil)
   noattr ::
 Composite _SaveFile Struct
   (Member_plain _capLevel tuchar :: Member_plain _capArea tuchar ::
    Member_plain _capPos (tarray tshort 3) :: Member_plain _flags tuint ::
    Member_plain _courseStars (tarray tuchar 25) ::
    Member_plain _courseCoinScores (tarray tuchar 15) ::
    Member_plain _signature (Tstruct _SaveBlockSignature noattr) :: nil)
   noattr ::
 Composite _MainMenuSaveData Struct
   (Member_plain _coinScoreAges (tarray tuint 4) ::
    Member_plain _soundMode tushort ::
    Member_plain _filler (tarray tuchar 10) ::
    Member_plain _signature (Tstruct _SaveBlockSignature noattr) :: nil)
   noattr ::
 Composite _SaveBuffer Struct
   (Member_plain _files (tarray (tarray (Tstruct _SaveFile noattr) 2) 4) ::
    Member_plain _menuData (tarray (Tstruct _MainMenuSaveData noattr) 2) ::
    nil)
   noattr ::
 Composite _WarpCheckpoint Struct
   (Member_plain _actNum tuchar :: Member_plain _courseNum tuchar ::
    Member_plain _levelID tuchar :: Member_plain _areaNum tuchar ::
    Member_plain _warpNode tuchar :: nil)
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
 (_osEepromLongRead,
   Gfun(External (EF_external "osEepromLongRead"
                   (mksignature
                     (AST.Xptr :: AST.Xint8unsigned :: AST.Xptr ::
                      AST.Xint :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _OSMesgQueue_s noattr)) :: tuchar :: (tptr tuchar) ::
      tint :: nil) tint cc_default)) ::
 (_osEepromLongWrite,
   Gfun(External (EF_external "osEepromLongWrite"
                   (mksignature
                     (AST.Xptr :: AST.Xint8unsigned :: AST.Xptr ::
                      AST.Xint :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _OSMesgQueue_s noattr)) :: tuchar :: (tptr tuchar) ::
      tint :: nil) tint cc_default)) ::
 (_bcopy,
   Gfun(External (EF_external "bcopy"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     ((tptr tvoid) :: (tptr tvoid) :: tuint :: nil) tvoid cc_default)) ::
 (_bzero,
   Gfun(External (EF_external "bzero"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default)) ((tptr tvoid) :: tuint :: nil) tvoid
     cc_default)) :: (_gEepromProbe, Gvar v_gEepromProbe) ::
 (_gCurrDemoInput, Gvar v_gCurrDemoInput) ::
 (_gSIEventMesgQueue, Gvar v_gSIEventMesgQueue) ::
 (_vec3s_copy,
   Gfun(External (EF_external "vec3s_copy"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xptr
                     cc_default)) ((tptr tshort) :: (tptr tshort) :: nil)
     (tptr tvoid) cc_default)) ::
 (_vec3s_set,
   Gfun(External (EF_external "vec3s_set"
                   (mksignature
                     (AST.Xptr :: AST.Xint16signed :: AST.Xint16signed ::
                      AST.Xint16signed :: nil) AST.Xptr cc_default))
     ((tptr tshort) :: tshort :: tshort :: tshort :: nil) (tptr tvoid)
     cc_default)) :: (_gCurrCourseNum, Gvar v_gCurrCourseNum) ::
 (_gCurrActNum, Gvar v_gCurrActNum) ::
 (_gCurrAreaIndex, Gvar v_gCurrAreaIndex) ::
 (_gSavedCourseNum, Gvar v_gSavedCourseNum) ::
 (_gCurrSaveFileNum, Gvar v_gCurrSaveFileNum) ::
 (_gCurrLevelNum, Gvar v_gCurrLevelNum) ::
 (_gCurrCreditsEntry, Gvar v_gCurrCreditsEntry) ::
 (_set_sound_mode,
   Gfun(External (EF_external "set_sound_mode"
                   (mksignature (AST.Xint16unsigned :: nil) AST.Xvoid
                     cc_default)) (tushort :: nil) tvoid cc_default)) ::
 (_gSaveBuffer, Gvar v_gSaveBuffer) ::
 (_gWarpCheckpoint, Gvar v_gWarpCheckpoint) ::
 (_gMainMenuDataModified, Gvar v_gMainMenuDataModified) ::
 (_gSaveFileModified, Gvar v_gSaveFileModified) ::
 (_gLastCompletedCourseNum, Gvar v_gLastCompletedCourseNum) ::
 (_gLastCompletedStarNum, Gvar v_gLastCompletedStarNum) ::
 (_sUnusedGotGlobalCoinHiScore, Gvar v_sUnusedGotGlobalCoinHiScore) ::
 (_gGotFileCoinHiScore, Gvar v_gGotFileCoinHiScore) ::
 (_gCurrCourseStarFlags, Gvar v_gCurrCourseStarFlags) ::
 (_gSpecialTripleJump, Gvar v_gSpecialTripleJump) ::
 (_gLevelToCourseNumTable, Gvar v_gLevelToCourseNumTable) ::
 (_stub_save_file_1, Gfun(Internal f_stub_save_file_1)) ::
 (_read_eeprom_data, Gfun(Internal f_read_eeprom_data)) ::
 (_write_eeprom_data, Gfun(Internal f_write_eeprom_data)) ::
 (_calc_checksum, Gfun(Internal f_calc_checksum)) ::
 (_verify_save_block_signature, Gfun(Internal f_verify_save_block_signature)) ::
 (_add_save_block_signature, Gfun(Internal f_add_save_block_signature)) ::
 (_restore_main_menu_data, Gfun(Internal f_restore_main_menu_data)) ::
 (_save_main_menu_data, Gfun(Internal f_save_main_menu_data)) ::
 (_wipe_main_menu_data, Gfun(Internal f_wipe_main_menu_data)) ::
 (_get_coin_score_age, Gfun(Internal f_get_coin_score_age)) ::
 (_set_coin_score_age, Gfun(Internal f_set_coin_score_age)) ::
 (_touch_coin_score_age, Gfun(Internal f_touch_coin_score_age)) ::
 (_touch_high_score_ages, Gfun(Internal f_touch_high_score_ages)) ::
 (_restore_save_file_data, Gfun(Internal f_restore_save_file_data)) ::
 (_save_file_do_save, Gfun(Internal f_save_file_do_save)) ::
 (_save_file_erase, Gfun(Internal f_save_file_erase)) ::
 (_save_file_copy, Gfun(Internal f_save_file_copy)) ::
 (_save_file_load_all, Gfun(Internal f_save_file_load_all)) ::
 (_save_file_reload, Gfun(Internal f_save_file_reload)) ::
 (_save_file_collect_star_or_key, Gfun(Internal f_save_file_collect_star_or_key)) ::
 (_save_file_exists, Gfun(Internal f_save_file_exists)) ::
 (_save_file_get_max_coin_score, Gfun(Internal f_save_file_get_max_coin_score)) ::
 (_save_file_get_course_star_count, Gfun(Internal f_save_file_get_course_star_count)) ::
 (_save_file_get_total_star_count, Gfun(Internal f_save_file_get_total_star_count)) ::
 (_save_file_set_flags, Gfun(Internal f_save_file_set_flags)) ::
 (_save_file_clear_flags, Gfun(Internal f_save_file_clear_flags)) ::
 (_save_file_get_flags, Gfun(Internal f_save_file_get_flags)) ::
 (_save_file_get_star_flags, Gfun(Internal f_save_file_get_star_flags)) ::
 (_save_file_set_star_flags, Gfun(Internal f_save_file_set_star_flags)) ::
 (_save_file_get_course_coin_score, Gfun(Internal f_save_file_get_course_coin_score)) ::
 (_save_file_is_cannon_unlocked, Gfun(Internal f_save_file_is_cannon_unlocked)) ::
 (_save_file_set_cannon_unlocked, Gfun(Internal f_save_file_set_cannon_unlocked)) ::
 (_save_file_set_cap_pos, Gfun(Internal f_save_file_set_cap_pos)) ::
 (_save_file_get_cap_pos, Gfun(Internal f_save_file_get_cap_pos)) ::
 (_save_file_set_sound_mode, Gfun(Internal f_save_file_set_sound_mode)) ::
 (_save_file_get_sound_mode, Gfun(Internal f_save_file_get_sound_mode)) ::
 (_save_file_move_cap_to_default_location, Gfun(Internal f_save_file_move_cap_to_default_location)) ::
 (_disable_warp_checkpoint, Gfun(Internal f_disable_warp_checkpoint)) ::
 (_check_if_should_set_warp_checkpoint, Gfun(Internal f_check_if_should_set_warp_checkpoint)) ::
 (_check_warp_checkpoint, Gfun(Internal f_check_warp_checkpoint)) :: nil).

Definition public_idents : list ident :=
(_check_warp_checkpoint :: _check_if_should_set_warp_checkpoint ::
 _disable_warp_checkpoint :: _save_file_move_cap_to_default_location ::
 _save_file_get_sound_mode :: _save_file_set_sound_mode ::
 _save_file_get_cap_pos :: _save_file_set_cap_pos ::
 _save_file_set_cannon_unlocked :: _save_file_is_cannon_unlocked ::
 _save_file_get_course_coin_score :: _save_file_set_star_flags ::
 _save_file_get_star_flags :: _save_file_get_flags ::
 _save_file_clear_flags :: _save_file_set_flags ::
 _save_file_get_total_star_count :: _save_file_get_course_star_count ::
 _save_file_get_max_coin_score :: _save_file_exists ::
 _save_file_collect_star_or_key :: _save_file_reload ::
 _save_file_load_all :: _save_file_copy :: _save_file_erase ::
 _save_file_do_save :: _gLevelToCourseNumTable :: _gSpecialTripleJump ::
 _gCurrCourseStarFlags :: _gGotFileCoinHiScore ::
 _sUnusedGotGlobalCoinHiScore :: _gLastCompletedStarNum ::
 _gLastCompletedCourseNum :: _gSaveFileModified :: _gMainMenuDataModified ::
 _gWarpCheckpoint :: _gSaveBuffer :: _set_sound_mode :: _gCurrCreditsEntry ::
 _gCurrLevelNum :: _gCurrSaveFileNum :: _gSavedCourseNum ::
 _gCurrAreaIndex :: _gCurrActNum :: _gCurrCourseNum :: _vec3s_set ::
 _vec3s_copy :: _gSIEventMesgQueue :: _gCurrDemoInput :: _gEepromProbe ::
 _bzero :: _bcopy :: _osEepromLongWrite :: _osEepromLongRead ::
 ___builtin_debug :: ___builtin_sync_fetch_and_add ::
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


