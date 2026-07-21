(* GENERATED FILE -- DO NOT EDIT.
   Source: ../../../reference-sm64-decomp/src/game/rumble_init.c
   clightgen: The CompCert CompCert AST generator, version 3.15
   Flags: -normalize -nostdinc -fstruct-passing -I../../../reference-sm64-decomp/include -I../../../reference-sm64-decomp/build/us -I../../../reference-sm64-decomp/build/us/include -I../../../reference-sm64-decomp/src -I../../../reference-sm64-decomp/src/game -I../../../reference-sm64-decomp/lib/src -I../../../reference-sm64-decomp -I../../../reference-sm64-decomp/include/libc -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1 -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_SH=1 *)
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
  Definition source_file := "../../../reference-sm64-decomp/src/game/rumble_init.c".
  Definition normalized := true.
End Info.

Definition _Controller : ident := $"Controller".
Definition _DemoInput : ident := $"DemoInput".
Definition _OSMesgQueue_s : ident := $"OSMesgQueue_s".
Definition _OSThread_s : ident := $"OSThread_s".
Definition _RumbleData : ident := $"RumbleData".
Definition _StructSH8031D9B0 : ident := $"StructSH8031D9B0".
Definition __248 : ident := $"_248".
Definition __249 : ident := $"_249".
Definition __251 : ident := $"_251".
Definition __253 : ident := $"_253".
Definition __313 : ident := $"_313".
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
Definition _a0 : ident := $"a0".
Definition _a1 : ident := $"a1".
Definition _a2 : ident := $"a2".
Definition _a3 : ident := $"a3".
Definition _activebank : ident := $"activebank".
Definition _at : ident := $"at".
Definition _badvaddr : ident := $"badvaddr".
Definition _banks : ident := $"banks".
Definition _block_until_rumble_pak_free : ident := $"block_until_rumble_pak_free".
Definition _button : ident := $"button".
Definition _buttonDown : ident := $"buttonDown".
Definition _buttonMask : ident := $"buttonMask".
Definition _buttonPressed : ident := $"buttonPressed".
Definition _cancel_rumble : ident := $"cancel_rumble".
Definition _cause : ident := $"cause".
Definition _channel : ident := $"channel".
Definition _context : ident := $"context".
Definition _controllerData : ident := $"controllerData".
Definition _count : ident := $"count".
Definition _create_thread_6 : ident := $"create_thread_6".
Definition _dir_size : ident := $"dir_size".
Definition _dir_table : ident := $"dir_table".
Definition _errnum : ident := $"errnum".
Definition _f : ident := $"f".
Definition _f_even : ident := $"f_even".
Definition _f_odd : ident := $"f_odd".
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
Definition _func_sh_8024C89C : ident := $"func_sh_8024C89C".
Definition _func_sh_8024CA04 : ident := $"func_sh_8024CA04".
Definition _gCurrDemoInput : ident := $"gCurrDemoInput".
Definition _gCurrRumbleSettings : ident := $"gCurrRumbleSettings".
Definition _gNumVblanks : ident := $"gNumVblanks".
Definition _gPlayer1Controller : ident := $"gPlayer1Controller".
Definition _gResetTimer : ident := $"gResetTimer".
Definition _gRumbleDataQueue : ident := $"gRumbleDataQueue".
Definition _gRumblePakPfs : ident := $"gRumblePakPfs".
Definition _gRumblePakSchedulerMesgBuf : ident := $"gRumblePakSchedulerMesgBuf".
Definition _gRumblePakSchedulerMesgQueue : ident := $"gRumblePakSchedulerMesgQueue".
Definition _gRumblePakThread : ident := $"gRumblePakThread".
Definition _gRumblePakTimer : ident := $"gRumblePakTimer".
Definition _gRumbleThreadVIMesgBuf : ident := $"gRumbleThreadVIMesgBuf".
Definition _gRumbleThreadVIMesgQueue : ident := $"gRumbleThreadVIMesgQueue".
Definition _gSIEventMesgQueue : ident := $"gSIEventMesgQueue".
Definition _gThread6Stack : ident := $"gThread6Stack".
Definition _gp : ident := $"gp".
Definition _hi : ident := $"hi".
Definition _id : ident := $"id".
Definition _init_rumble_pak_scheduler_queue : ident := $"init_rumble_pak_scheduler_queue".
Definition _inode_start_page : ident := $"inode_start_page".
Definition _inode_table : ident := $"inode_table".
Definition _is_rumble_finished_and_queue_empty : ident := $"is_rumble_finished_and_queue_empty".
Definition _label : ident := $"label".
Definition _lo : ident := $"lo".
Definition _main : ident := $"main".
Definition _minode_table : ident := $"minode_table".
Definition _msg : ident := $"msg".
Definition _msgCount : ident := $"msgCount".
Definition _mtqueue : ident := $"mtqueue".
Definition _next : ident := $"next".
Definition _osCreateMesgQueue : ident := $"osCreateMesgQueue".
Definition _osCreateThread : ident := $"osCreateThread".
Definition _osMotorInit : ident := $"osMotorInit".
Definition _osMotorStart : ident := $"osMotorStart".
Definition _osMotorStop : ident := $"osMotorStop".
Definition _osRecvMesg : ident := $"osRecvMesg".
Definition _osSendMesg : ident := $"osSendMesg".
Definition _osStartThread : ident := $"osStartThread".
Definition _pc : ident := $"pc".
Definition _port : ident := $"port".
Definition _priority : ident := $"priority".
Definition _queue : ident := $"queue".
Definition _queue_rumble_data : ident := $"queue_rumble_data".
Definition _ra : ident := $"ra".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _rcp : ident := $"rcp".
Definition _release_rumble_pak_control : ident := $"release_rumble_pak_control".
Definition _reset_rumble_timers : ident := $"reset_rumble_timers".
Definition _reset_rumble_timers_2 : ident := $"reset_rumble_timers_2".
Definition _rumble_thread_update_vi : ident := $"rumble_thread_update_vi".
Definition _s0 : ident := $"s0".
Definition _s1 : ident := $"s1".
Definition _s2 : ident := $"s2".
Definition _s3 : ident := $"s3".
Definition _s4 : ident := $"s4".
Definition _s5 : ident := $"s5".
Definition _s6 : ident := $"s6".
Definition _s7 : ident := $"s7".
Definition _s8 : ident := $"s8".
Definition _sRumblePakActive : ident := $"sRumblePakActive".
Definition _sRumblePakErrorCount : ident := $"sRumblePakErrorCount".
Definition _sRumblePakThreadActive : ident := $"sRumblePakThreadActive".
Definition _sp : ident := $"sp".
Definition _sr : ident := $"sr".
Definition _start_rumble : ident := $"start_rumble".
Definition _state : ident := $"state".
Definition _status : ident := $"status".
Definition _statusData : ident := $"statusData".
Definition _stickMag : ident := $"stickMag".
Definition _stickX : ident := $"stickX".
Definition _stickY : ident := $"stickY".
Definition _stick_x : ident := $"stick_x".
Definition _stick_y : ident := $"stick_y".
Definition _stop_rumble : ident := $"stop_rumble".
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
Definition _thread6_rumble_loop : ident := $"thread6_rumble_loop".
Definition _time : ident := $"time".
Definition _timer : ident := $"timer".
Definition _tlnext : ident := $"tlnext".
Definition _type : ident := $"type".
Definition _unk00 : ident := $"unk00".
Definition _unk01 : ident := $"unk01".
Definition _unk02 : ident := $"unk02".
Definition _unk04 : ident := $"unk04".
Definition _unk06 : ident := $"unk06".
Definition _unk08 : ident := $"unk08".
Definition _unk0A : ident := $"unk0A".
Definition _unk0C : ident := $"unk0C".
Definition _unk0E : ident := $"unk0E".
Definition _update_rumble_data_queue : ident := $"update_rumble_data_queue".
Definition _update_rumble_pak : ident := $"update_rumble_pak".
Definition _v0 : ident := $"v0".
Definition _v1 : ident := $"v1".
Definition _validCount : ident := $"validCount".
Definition _version : ident := $"version".
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
Definition _t'3 : ident := 130%positive.
Definition _t'4 : ident := 131%positive.
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

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

Definition v_gThread6Stack := {|
  gvar_info := (tarray tuchar 0);
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

Definition v_gNumVblanks := {|
  gvar_info := tuint;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gResetTimer := {|
  gvar_info := tschar;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gRumblePakThread := {|
  gvar_info := (Tstruct _OSThread_s noattr);
  gvar_init := (Init_space 432 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gRumblePakPfs := {|
  gvar_info := (Tstruct __313 noattr);
  gvar_init := (Init_space 104 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gRumblePakSchedulerMesgBuf := {|
  gvar_info := (tptr tvoid);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gRumblePakSchedulerMesgQueue := {|
  gvar_info := (Tstruct _OSMesgQueue_s noattr);
  gvar_init := (Init_space 24 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gRumbleThreadVIMesgBuf := {|
  gvar_info := (tptr tvoid);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gRumbleThreadVIMesgQueue := {|
  gvar_info := (Tstruct _OSMesgQueue_s noattr);
  gvar_init := (Init_space 24 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gRumbleDataQueue := {|
  gvar_info := (tarray (Tstruct _RumbleData noattr) 3);
  gvar_init := (Init_space 18 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrRumbleSettings := {|
  gvar_info := (Tstruct _StructSH8031D9B0 noattr);
  gvar_init := (Init_space 16 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sRumblePakThreadActive := {|
  gvar_info := tint;
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sRumblePakActive := {|
  gvar_info := tint;
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sRumblePakErrorCount := {|
  gvar_info := tint;
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gRumblePakTimer := {|
  gvar_info := tint;
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_init_rumble_pak_scheduler_queue := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _osCreateMesgQueue (Tfunction
                               ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                (tptr (tptr tvoid)) :: tint :: nil) tvoid
                               cc_default))
    ((Eaddrof
       (Evar _gRumblePakSchedulerMesgQueue (Tstruct _OSMesgQueue_s noattr))
       (tptr (Tstruct _OSMesgQueue_s noattr))) ::
     (Eaddrof (Evar _gRumblePakSchedulerMesgBuf (tptr tvoid))
       (tptr (tptr tvoid))) :: (Econst_int (Int.repr 1) tint) :: nil))
  (Scall None
    (Evar _osSendMesg (Tfunction
                        ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                         (tptr tvoid) :: tint :: nil) tint cc_default))
    ((Eaddrof
       (Evar _gRumblePakSchedulerMesgQueue (Tstruct _OSMesgQueue_s noattr))
       (tptr (Tstruct _OSMesgQueue_s noattr))) ::
     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
     (Econst_int (Int.repr 0) tint) :: nil)))
|}.

Definition f_block_until_rumble_pak_free := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_msg, (tptr tvoid)) :: nil);
  fn_temps := nil;
  fn_body :=
(Scall None
  (Evar _osRecvMesg (Tfunction
                      ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                       (tptr (tptr tvoid)) :: tint :: nil) tint cc_default))
  ((Eaddrof
     (Evar _gRumblePakSchedulerMesgQueue (Tstruct _OSMesgQueue_s noattr))
     (tptr (Tstruct _OSMesgQueue_s noattr))) ::
   (Eaddrof (Evar _msg (tptr tvoid)) (tptr (tptr tvoid))) ::
   (Econst_int (Int.repr 1) tint) :: nil))
|}.

Definition f_release_rumble_pak_control := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Scall None
  (Evar _osSendMesg (Tfunction
                      ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                       (tptr tvoid) :: tint :: nil) tint cc_default))
  ((Eaddrof
     (Evar _gRumblePakSchedulerMesgQueue (Tstruct _OSMesgQueue_s noattr))
     (tptr (Tstruct _OSMesgQueue_s noattr))) ::
   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
   (Econst_int (Int.repr 0) tint) :: nil))
|}.

Definition f_start_rumble := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'3, tint) :: (_t'2, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3 (Evar _sRumblePakActive tint))
    (Sifthenelse (Eunop Onotbool (Etempvar _t'3 tint) tint)
      (Sreturn None)
      Sskip))
  (Ssequence
    (Scall None
      (Evar _block_until_rumble_pak_free (Tfunction nil tvoid cc_default))
      nil)
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _osMotorStart (Tfunction
                                ((tptr (Tstruct __313 noattr)) :: nil) tint
                                cc_default))
          ((Eaddrof (Evar _gRumblePakPfs (Tstruct __313 noattr))
             (tptr (Tstruct __313 noattr))) :: nil))
        (Sifthenelse (Eunop Onotbool (Etempvar _t'1 tint) tint)
          (Sassign (Evar _sRumblePakErrorCount tint)
            (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Sset _t'2 (Evar _sRumblePakErrorCount tint))
            (Sassign (Evar _sRumblePakErrorCount tint)
              (Ebinop Oadd (Etempvar _t'2 tint)
                (Econst_int (Int.repr 1) tint) tint)))))
      (Scall None
        (Evar _release_rumble_pak_control (Tfunction nil tvoid cc_default))
        nil))))
|}.

Definition f_stop_rumble := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'3, tint) :: (_t'2, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3 (Evar _sRumblePakActive tint))
    (Sifthenelse (Eunop Onotbool (Etempvar _t'3 tint) tint)
      (Sreturn None)
      Sskip))
  (Ssequence
    (Scall None
      (Evar _block_until_rumble_pak_free (Tfunction nil tvoid cc_default))
      nil)
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _osMotorStop (Tfunction
                               ((tptr (Tstruct __313 noattr)) :: nil) tint
                               cc_default))
          ((Eaddrof (Evar _gRumblePakPfs (Tstruct __313 noattr))
             (tptr (Tstruct __313 noattr))) :: nil))
        (Sifthenelse (Eunop Onotbool (Etempvar _t'1 tint) tint)
          (Sassign (Evar _sRumblePakErrorCount tint)
            (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Sset _t'2 (Evar _sRumblePakErrorCount tint))
            (Sassign (Evar _sRumblePakErrorCount tint)
              (Ebinop Oadd (Etempvar _t'2 tint)
                (Econst_int (Int.repr 1) tint) tint)))))
      (Scall None
        (Evar _release_rumble_pak_control (Tfunction nil tvoid cc_default))
        nil))))
|}.

Definition f_update_rumble_pak := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'22, tschar) :: (_t'21, tshort) ::
               (_t'20, tshort) :: (_t'19, tshort) :: (_t'18, tshort) ::
               (_t'17, tshort) :: (_t'16, tshort) :: (_t'15, tshort) ::
               (_t'14, tshort) :: (_t'13, tshort) :: (_t'12, tshort) ::
               (_t'11, tshort) :: (_t'10, tshort) :: (_t'9, tshort) ::
               (_t'8, tuint) :: (_t'7, tshort) :: (_t'6, tshort) ::
               (_t'5, tshort) :: (_t'4, tshort) :: (_t'3, tshort) ::
               (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'22 (Evar _gResetTimer tschar))
    (Sifthenelse (Ebinop Ogt (Etempvar _t'22 tschar)
                   (Econst_int (Int.repr 0) tint) tint)
      (Ssequence
        (Scall None (Evar _stop_rumble (Tfunction nil tvoid cc_default)) nil)
        (Sreturn None))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'4
        (Efield
          (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
          _unk08 tshort))
      (Sifthenelse (Ebinop Ogt (Etempvar _t'4 tshort)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'21
              (Efield
                (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                _unk08 tshort))
            (Sassign
              (Efield
                (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                _unk08 tshort)
              (Ebinop Osub (Etempvar _t'21 tshort)
                (Econst_int (Int.repr 1) tint) tint)))
          (Scall None (Evar _start_rumble (Tfunction nil tvoid cc_default))
            nil))
        (Ssequence
          (Sset _t'5
            (Efield
              (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
              _unk04 tshort))
          (Sifthenelse (Ebinop Ogt (Etempvar _t'5 tshort)
                         (Econst_int (Int.repr 0) tint) tint)
            (Ssequence
              (Ssequence
                (Sset _t'20
                  (Efield
                    (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                    _unk04 tshort))
                (Sassign
                  (Efield
                    (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                    _unk04 tshort)
                  (Ebinop Osub (Etempvar _t'20 tshort)
                    (Econst_int (Int.repr 1) tint) tint)))
              (Ssequence
                (Ssequence
                  (Sset _t'18
                    (Efield
                      (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                      _unk02 tshort))
                  (Ssequence
                    (Sset _t'19
                      (Efield
                        (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                        _unk0E tshort))
                    (Sassign
                      (Efield
                        (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                        _unk02 tshort)
                      (Ebinop Osub (Etempvar _t'18 tshort)
                        (Etempvar _t'19 tshort) tint))))
                (Ssequence
                  (Ssequence
                    (Sset _t'17
                      (Efield
                        (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                        _unk02 tshort))
                    (Sifthenelse (Ebinop Olt (Etempvar _t'17 tshort)
                                   (Econst_int (Int.repr 0) tint) tint)
                      (Sassign
                        (Efield
                          (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                          _unk02 tshort) (Econst_int (Int.repr 0) tint))
                      Sskip))
                  (Ssequence
                    (Sset _t'10
                      (Efield
                        (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                        _unk00 tshort))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'10 tshort)
                                   (Econst_int (Int.repr 1) tint) tint)
                      (Scall None
                        (Evar _start_rumble (Tfunction nil tvoid cc_default))
                        nil)
                      (Ssequence
                        (Sset _t'11
                          (Efield
                            (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                            _unk06 tshort))
                        (Sifthenelse (Ebinop Oge (Etempvar _t'11 tshort)
                                       (Econst_int (Int.repr 256) tint) tint)
                          (Ssequence
                            (Ssequence
                              (Sset _t'16
                                (Efield
                                  (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                                  _unk06 tshort))
                              (Sassign
                                (Efield
                                  (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                                  _unk06 tshort)
                                (Ebinop Osub (Etempvar _t'16 tshort)
                                  (Econst_int (Int.repr 256) tint) tint)))
                            (Scall None
                              (Evar _start_rumble (Tfunction nil tvoid
                                                    cc_default)) nil))
                          (Ssequence
                            (Ssequence
                              (Sset _t'12
                                (Efield
                                  (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                                  _unk06 tshort))
                              (Ssequence
                                (Sset _t'13
                                  (Efield
                                    (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                                    _unk02 tshort))
                                (Ssequence
                                  (Sset _t'14
                                    (Efield
                                      (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                                      _unk02 tshort))
                                  (Ssequence
                                    (Sset _t'15
                                      (Efield
                                        (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                                        _unk02 tshort))
                                    (Sassign
                                      (Efield
                                        (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                                        _unk06 tshort)
                                      (Ebinop Oadd (Etempvar _t'12 tshort)
                                        (Ebinop Oadd
                                          (Ebinop Odiv
                                            (Ebinop Omul
                                              (Ebinop Omul
                                                (Etempvar _t'13 tshort)
                                                (Etempvar _t'14 tshort) tint)
                                              (Etempvar _t'15 tshort) tint)
                                            (Ebinop Oshl
                                              (Econst_int (Int.repr 1) tint)
                                              (Econst_int (Int.repr 9) tint)
                                              tint) tint)
                                          (Econst_int (Int.repr 4) tint)
                                          tint) tint))))))
                            (Scall None
                              (Evar _stop_rumble (Tfunction nil tvoid
                                                   cc_default)) nil)))))))))
            (Ssequence
              (Sassign
                (Efield
                  (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                  _unk04 tshort) (Econst_int (Int.repr 0) tint))
              (Ssequence
                (Sset _t'6
                  (Efield
                    (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                    _unk0A tshort))
                (Sifthenelse (Ebinop Oge (Etempvar _t'6 tshort)
                               (Econst_int (Int.repr 5) tint) tint)
                  (Scall None
                    (Evar _start_rumble (Tfunction nil tvoid cc_default))
                    nil)
                  (Ssequence
                    (Ssequence
                      (Sset _t'7
                        (Efield
                          (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                          _unk0A tshort))
                      (Sifthenelse (Ebinop Oge (Etempvar _t'7 tshort)
                                     (Econst_int (Int.repr 2) tint) tint)
                        (Ssequence
                          (Sset _t'8 (Evar _gNumVblanks tuint))
                          (Ssequence
                            (Sset _t'9
                              (Efield
                                (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                                _unk0C tshort))
                            (Sset _t'1
                              (Ecast
                                (Ebinop Oeq
                                  (Ebinop Omod (Etempvar _t'8 tuint)
                                    (Etempvar _t'9 tshort) tuint)
                                  (Econst_int (Int.repr 0) tint) tint) tbool))))
                        (Sset _t'1 (Econst_int (Int.repr 0) tint))))
                    (Sifthenelse (Etempvar _t'1 tint)
                      (Scall None
                        (Evar _start_rumble (Tfunction nil tvoid cc_default))
                        nil)
                      (Scall None
                        (Evar _stop_rumble (Tfunction nil tvoid cc_default))
                        nil))))))))))
    (Ssequence
      (Sset _t'2
        (Efield
          (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
          _unk0A tshort))
      (Sifthenelse (Ebinop Ogt (Etempvar _t'2 tshort)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Sset _t'3
            (Efield
              (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
              _unk0A tshort))
          (Sassign
            (Efield
              (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
              _unk0A tshort)
            (Ebinop Osub (Etempvar _t'3 tshort)
              (Econst_int (Int.repr 1) tint) tint)))
        Sskip))))
|}.

Definition f_update_rumble_data_queue := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'5, tuchar) :: (_t'4, tshort) :: (_t'3, tuchar) ::
               (_t'2, tshort) :: (_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1
      (Efield
        (Ederef
          (Ebinop Oadd
            (Evar _gRumbleDataQueue (tarray (Tstruct _RumbleData noattr) 3))
            (Econst_int (Int.repr 0) tint)
            (tptr (Tstruct _RumbleData noattr)))
          (Tstruct _RumbleData noattr)) _unk00 tuchar))
    (Sifthenelse (Etempvar _t'1 tuchar)
      (Ssequence
        (Sassign
          (Efield
            (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
            _unk06 tshort) (Econst_int (Int.repr 0) tint))
        (Ssequence
          (Sassign
            (Efield
              (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
              _unk08 tshort) (Econst_int (Int.repr 4) tint))
          (Ssequence
            (Ssequence
              (Sset _t'5
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Evar _gRumbleDataQueue (tarray (Tstruct _RumbleData noattr) 3))
                      (Econst_int (Int.repr 0) tint)
                      (tptr (Tstruct _RumbleData noattr)))
                    (Tstruct _RumbleData noattr)) _unk00 tuchar))
              (Sassign
                (Efield
                  (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                  _unk00 tshort) (Etempvar _t'5 tuchar)))
            (Ssequence
              (Ssequence
                (Sset _t'4
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Evar _gRumbleDataQueue (tarray (Tstruct _RumbleData noattr) 3))
                        (Econst_int (Int.repr 0) tint)
                        (tptr (Tstruct _RumbleData noattr)))
                      (Tstruct _RumbleData noattr)) _unk02 tshort))
                (Sassign
                  (Efield
                    (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                    _unk04 tshort) (Etempvar _t'4 tshort)))
              (Ssequence
                (Ssequence
                  (Sset _t'3
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Evar _gRumbleDataQueue (tarray (Tstruct _RumbleData noattr) 3))
                          (Econst_int (Int.repr 0) tint)
                          (tptr (Tstruct _RumbleData noattr)))
                        (Tstruct _RumbleData noattr)) _unk01 tuchar))
                  (Sassign
                    (Efield
                      (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                      _unk02 tshort) (Etempvar _t'3 tuchar)))
                (Ssequence
                  (Sset _t'2
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Evar _gRumbleDataQueue (tarray (Tstruct _RumbleData noattr) 3))
                          (Econst_int (Int.repr 0) tint)
                          (tptr (Tstruct _RumbleData noattr)))
                        (Tstruct _RumbleData noattr)) _unk04 tshort))
                  (Sassign
                    (Efield
                      (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                      _unk0E tshort) (Etempvar _t'2 tshort))))))))
      Sskip))
  (Ssequence
    (Sassign
      (Ederef
        (Ebinop Oadd
          (Evar _gRumbleDataQueue (tarray (Tstruct _RumbleData noattr) 3))
          (Econst_int (Int.repr 0) tint) (tptr (Tstruct _RumbleData noattr)))
        (Tstruct _RumbleData noattr))
      (Ederef
        (Ebinop Oadd
          (Evar _gRumbleDataQueue (tarray (Tstruct _RumbleData noattr) 3))
          (Econst_int (Int.repr 1) tint) (tptr (Tstruct _RumbleData noattr)))
        (Tstruct _RumbleData noattr)))
    (Ssequence
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Evar _gRumbleDataQueue (tarray (Tstruct _RumbleData noattr) 3))
            (Econst_int (Int.repr 1) tint)
            (tptr (Tstruct _RumbleData noattr)))
          (Tstruct _RumbleData noattr))
        (Ederef
          (Ebinop Oadd
            (Evar _gRumbleDataQueue (tarray (Tstruct _RumbleData noattr) 3))
            (Econst_int (Int.repr 2) tint)
            (tptr (Tstruct _RumbleData noattr)))
          (Tstruct _RumbleData noattr)))
      (Sassign
        (Efield
          (Ederef
            (Ebinop Oadd
              (Evar _gRumbleDataQueue (tarray (Tstruct _RumbleData noattr) 3))
              (Econst_int (Int.repr 2) tint)
              (tptr (Tstruct _RumbleData noattr)))
            (Tstruct _RumbleData noattr)) _unk00 tuchar)
        (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_queue_rumble_data := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_a0, tshort) :: (_a1, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr (Tstruct _DemoInput noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1 (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr))))
    (Sifthenelse (Ebinop One
                   (Etempvar _t'1 (tptr (Tstruct _DemoInput noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Sreturn None)
      Sskip))
  (Ssequence
    (Sifthenelse (Ebinop Ogt (Etempvar _a1 tshort)
                   (Econst_int (Int.repr 70) tint) tint)
      (Sassign
        (Efield
          (Ederef
            (Ebinop Oadd
              (Evar _gRumbleDataQueue (tarray (Tstruct _RumbleData noattr) 3))
              (Econst_int (Int.repr 2) tint)
              (tptr (Tstruct _RumbleData noattr)))
            (Tstruct _RumbleData noattr)) _unk00 tuchar)
        (Econst_int (Int.repr 1) tint))
      (Sassign
        (Efield
          (Ederef
            (Ebinop Oadd
              (Evar _gRumbleDataQueue (tarray (Tstruct _RumbleData noattr) 3))
              (Econst_int (Int.repr 2) tint)
              (tptr (Tstruct _RumbleData noattr)))
            (Tstruct _RumbleData noattr)) _unk00 tuchar)
        (Econst_int (Int.repr 2) tint)))
    (Ssequence
      (Sassign
        (Efield
          (Ederef
            (Ebinop Oadd
              (Evar _gRumbleDataQueue (tarray (Tstruct _RumbleData noattr) 3))
              (Econst_int (Int.repr 2) tint)
              (tptr (Tstruct _RumbleData noattr)))
            (Tstruct _RumbleData noattr)) _unk01 tuchar)
        (Etempvar _a1 tshort))
      (Ssequence
        (Sassign
          (Efield
            (Ederef
              (Ebinop Oadd
                (Evar _gRumbleDataQueue (tarray (Tstruct _RumbleData noattr) 3))
                (Econst_int (Int.repr 2) tint)
                (tptr (Tstruct _RumbleData noattr)))
              (Tstruct _RumbleData noattr)) _unk02 tshort)
          (Etempvar _a0 tshort))
        (Sassign
          (Efield
            (Ederef
              (Ebinop Oadd
                (Evar _gRumbleDataQueue (tarray (Tstruct _RumbleData noattr) 3))
                (Econst_int (Int.repr 2) tint)
                (tptr (Tstruct _RumbleData noattr)))
              (Tstruct _RumbleData noattr)) _unk04 tshort)
          (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_func_sh_8024C89C := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_a0, tshort) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Sassign
  (Efield
    (Ederef
      (Ebinop Oadd
        (Evar _gRumbleDataQueue (tarray (Tstruct _RumbleData noattr) 3))
        (Econst_int (Int.repr 2) tint) (tptr (Tstruct _RumbleData noattr)))
      (Tstruct _RumbleData noattr)) _unk04 tshort) (Etempvar _a0 tshort))
|}.

Definition f_is_rumble_finished_and_queue_empty := {|
  fn_return := tuchar;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'5, tshort) :: (_t'4, tshort) :: (_t'3, tuchar) ::
               (_t'2, tuchar) :: (_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4
      (Efield (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
        _unk08 tshort))
    (Ssequence
      (Sset _t'5
        (Efield
          (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
          _unk04 tshort))
      (Sifthenelse (Ebinop Oge
                     (Ebinop Oadd (Etempvar _t'4 tshort)
                       (Etempvar _t'5 tshort) tint)
                     (Econst_int (Int.repr 4) tint) tint)
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))
        Sskip)))
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef
            (Ebinop Oadd
              (Evar _gRumbleDataQueue (tarray (Tstruct _RumbleData noattr) 3))
              (Econst_int (Int.repr 0) tint)
              (tptr (Tstruct _RumbleData noattr)))
            (Tstruct _RumbleData noattr)) _unk00 tuchar))
      (Sifthenelse (Ebinop One (Etempvar _t'3 tuchar)
                     (Econst_int (Int.repr 0) tint) tint)
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef
              (Ebinop Oadd
                (Evar _gRumbleDataQueue (tarray (Tstruct _RumbleData noattr) 3))
                (Econst_int (Int.repr 1) tint)
                (tptr (Tstruct _RumbleData noattr)))
              (Tstruct _RumbleData noattr)) _unk00 tuchar))
        (Sifthenelse (Ebinop One (Etempvar _t'2 tuchar)
                       (Econst_int (Int.repr 0) tint) tint)
          (Sreturn (Some (Econst_int (Int.repr 0) tint)))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'1
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Evar _gRumbleDataQueue (tarray (Tstruct _RumbleData noattr) 3))
                  (Econst_int (Int.repr 2) tint)
                  (tptr (Tstruct _RumbleData noattr)))
                (Tstruct _RumbleData noattr)) _unk00 tuchar))
          (Sifthenelse (Ebinop One (Etempvar _t'1 tuchar)
                         (Econst_int (Int.repr 0) tint) tint)
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))
            Sskip))
        (Sreturn (Some (Econst_int (Int.repr 1) tint)))))))
|}.

Definition f_reset_rumble_timers := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'3, (tptr (Tstruct _DemoInput noattr))) ::
               (_t'2, tshort) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3 (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr))))
    (Sifthenelse (Ebinop One
                   (Etempvar _t'3 (tptr (Tstruct _DemoInput noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Sreturn None)
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Efield
          (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
          _unk0A tshort))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tshort)
                     (Econst_int (Int.repr 0) tint) tint)
        (Sassign
          (Efield
            (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
            _unk0A tshort) (Econst_int (Int.repr 7) tint))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'1
          (Efield
            (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
            _unk0A tshort))
        (Sifthenelse (Ebinop Olt (Etempvar _t'1 tshort)
                       (Econst_int (Int.repr 4) tint) tint)
          (Sassign
            (Efield
              (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
              _unk0A tshort) (Econst_int (Int.repr 4) tint))
          Sskip))
      (Sassign
        (Efield
          (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
          _unk0C tshort) (Econst_int (Int.repr 7) tint)))))
|}.

Definition f_reset_rumble_timers_2 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_a0, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, (tptr (Tstruct _DemoInput noattr))) ::
               (_t'2, tshort) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3 (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr))))
    (Sifthenelse (Ebinop One
                   (Etempvar _t'3 (tptr (Tstruct _DemoInput noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Sreturn None)
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Efield
          (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
          _unk0A tshort))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tshort)
                     (Econst_int (Int.repr 0) tint) tint)
        (Sassign
          (Efield
            (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
            _unk0A tshort) (Econst_int (Int.repr 7) tint))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'1
          (Efield
            (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
            _unk0A tshort))
        (Sifthenelse (Ebinop Olt (Etempvar _t'1 tshort)
                       (Econst_int (Int.repr 4) tint) tint)
          (Sassign
            (Efield
              (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
              _unk0A tshort) (Econst_int (Int.repr 4) tint))
          Sskip))
      (Ssequence
        (Sifthenelse (Ebinop Oeq (Etempvar _a0 tint)
                       (Econst_int (Int.repr 4) tint) tint)
          (Sassign
            (Efield
              (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
              _unk0C tshort) (Econst_int (Int.repr 1) tint))
          Sskip)
        (Ssequence
          (Sifthenelse (Ebinop Oeq (Etempvar _a0 tint)
                         (Econst_int (Int.repr 3) tint) tint)
            (Sassign
              (Efield
                (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                _unk0C tshort) (Econst_int (Int.repr 2) tint))
            Sskip)
          (Ssequence
            (Sifthenelse (Ebinop Oeq (Etempvar _a0 tint)
                           (Econst_int (Int.repr 2) tint) tint)
              (Sassign
                (Efield
                  (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                  _unk0C tshort) (Econst_int (Int.repr 3) tint))
              Sskip)
            (Ssequence
              (Sifthenelse (Ebinop Oeq (Etempvar _a0 tint)
                             (Econst_int (Int.repr 1) tint) tint)
                (Sassign
                  (Efield
                    (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                    _unk0C tshort) (Econst_int (Int.repr 4) tint))
                Sskip)
              (Sifthenelse (Ebinop Oeq (Etempvar _a0 tint)
                             (Econst_int (Int.repr 0) tint) tint)
                (Sassign
                  (Efield
                    (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                    _unk0C tshort) (Econst_int (Int.repr 5) tint))
                Sskip))))))))
|}.

Definition f_func_sh_8024CA04 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr (Tstruct _DemoInput noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1 (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr))))
    (Sifthenelse (Ebinop One
                   (Etempvar _t'1 (tptr (Tstruct _DemoInput noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Sreturn None)
      Sskip))
  (Ssequence
    (Sassign
      (Efield (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
        _unk0A tshort) (Econst_int (Int.repr 4) tint))
    (Sassign
      (Efield (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
        _unk0C tshort) (Econst_int (Int.repr 4) tint))))
|}.

Definition f_thread6_rumble_loop := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_a0, (tptr tvoid)) :: nil);
  fn_vars := ((_msg, (tptr tvoid)) :: nil);
  fn_temps := ((_t'1, tint) :: (_t'8, tint) :: (_t'7, tint) ::
               (_t'6, (tptr (Tstruct _Controller noattr))) ::
               (_t'5, tuint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tint) :: nil);
  fn_body :=
(Ssequence
  (Scall None (Evar _cancel_rumble (Tfunction nil tvoid cc_default)) nil)
  (Ssequence
    (Sassign (Evar _sRumblePakThreadActive tint)
      (Econst_int (Int.repr 1) tint))
    (Sloop
      (Ssequence
        Sskip
        (Ssequence
          (Scall None
            (Evar _osRecvMesg (Tfunction
                                ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                 (tptr (tptr tvoid)) :: tint :: nil) tint
                                cc_default))
            ((Eaddrof
               (Evar _gRumbleThreadVIMesgQueue (Tstruct _OSMesgQueue_s noattr))
               (tptr (Tstruct _OSMesgQueue_s noattr))) ::
             (Eaddrof (Evar _msg (tptr tvoid)) (tptr (tptr tvoid))) ::
             (Econst_int (Int.repr 1) tint) :: nil))
          (Ssequence
            (Scall None
              (Evar _update_rumble_data_queue (Tfunction nil tvoid
                                                cc_default)) nil)
            (Ssequence
              (Scall None
                (Evar _update_rumble_pak (Tfunction nil tvoid cc_default))
                nil)
              (Ssequence
                (Ssequence
                  (Sset _t'4 (Evar _sRumblePakActive tint))
                  (Sifthenelse (Etempvar _t'4 tint)
                    (Ssequence
                      (Sset _t'8 (Evar _sRumblePakErrorCount tint))
                      (Sifthenelse (Ebinop Oge (Etempvar _t'8 tint)
                                     (Econst_int (Int.repr 30) tint) tint)
                        (Sassign (Evar _sRumblePakActive tint)
                          (Econst_int (Int.repr 0) tint))
                        Sskip))
                    (Ssequence
                      (Sset _t'5 (Evar _gNumVblanks tuint))
                      (Sifthenelse (Ebinop Oeq
                                     (Ebinop Omod (Etempvar _t'5 tuint)
                                       (Econst_int (Int.repr 60) tint) tuint)
                                     (Econst_int (Int.repr 0) tint) tint)
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Sset _t'6
                                (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
                              (Ssequence
                                (Sset _t'7
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'6 (tptr (Tstruct _Controller noattr)))
                                      (Tstruct _Controller noattr)) _port
                                    tint))
                                (Scall (Some _t'1)
                                  (Evar _osMotorInit (Tfunction
                                                       ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                                        (tptr (Tstruct __313 noattr)) ::
                                                        tint :: nil) tint
                                                       cc_default))
                                  ((Eaddrof
                                     (Evar _gSIEventMesgQueue (Tstruct _OSMesgQueue_s noattr))
                                     (tptr (Tstruct _OSMesgQueue_s noattr))) ::
                                   (Eaddrof
                                     (Evar _gRumblePakPfs (Tstruct __313 noattr))
                                     (tptr (Tstruct __313 noattr))) ::
                                   (Etempvar _t'7 tint) :: nil))))
                            (Sassign (Evar _sRumblePakActive tint)
                              (Ebinop Oeq (Etempvar _t'1 tint)
                                (Econst_int (Int.repr 0) tint) tint)))
                          (Sassign (Evar _sRumblePakErrorCount tint)
                            (Econst_int (Int.repr 0) tint)))
                        Sskip))))
                (Ssequence
                  (Sset _t'2 (Evar _gRumblePakTimer tint))
                  (Sifthenelse (Ebinop Ogt (Etempvar _t'2 tint)
                                 (Econst_int (Int.repr 0) tint) tint)
                    (Ssequence
                      (Sset _t'3 (Evar _gRumblePakTimer tint))
                      (Sassign (Evar _gRumblePakTimer tint)
                        (Ebinop Osub (Etempvar _t'3 tint)
                          (Econst_int (Int.repr 1) tint) tint)))
                    Sskip)))))))
      Sskip)))
|}.

Definition f_cancel_rumble := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'4, tint) ::
               (_t'3, (tptr (Tstruct _Controller noattr))) :: (_t'2, tint) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef (Etempvar _t'3 (tptr (Tstruct _Controller noattr)))
              (Tstruct _Controller noattr)) _port tint))
        (Scall (Some _t'1)
          (Evar _osMotorInit (Tfunction
                               ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                (tptr (Tstruct __313 noattr)) :: tint :: nil)
                               tint cc_default))
          ((Eaddrof (Evar _gSIEventMesgQueue (Tstruct _OSMesgQueue_s noattr))
             (tptr (Tstruct _OSMesgQueue_s noattr))) ::
           (Eaddrof (Evar _gRumblePakPfs (Tstruct __313 noattr))
             (tptr (Tstruct __313 noattr))) :: (Etempvar _t'4 tint) :: nil))))
    (Sassign (Evar _sRumblePakActive tint)
      (Ebinop Oeq (Etempvar _t'1 tint) (Econst_int (Int.repr 0) tint) tint)))
  (Ssequence
    (Ssequence
      (Sset _t'2 (Evar _sRumblePakActive tint))
      (Sifthenelse (Etempvar _t'2 tint)
        (Scall None
          (Evar _osMotorStop (Tfunction
                               ((tptr (Tstruct __313 noattr)) :: nil) tint
                               cc_default))
          ((Eaddrof (Evar _gRumblePakPfs (Tstruct __313 noattr))
             (tptr (Tstruct __313 noattr))) :: nil))
        Sskip))
    (Ssequence
      (Sassign
        (Efield
          (Ederef
            (Ebinop Oadd
              (Evar _gRumbleDataQueue (tarray (Tstruct _RumbleData noattr) 3))
              (Econst_int (Int.repr 0) tint)
              (tptr (Tstruct _RumbleData noattr)))
            (Tstruct _RumbleData noattr)) _unk00 tuchar)
        (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Sassign
          (Efield
            (Ederef
              (Ebinop Oadd
                (Evar _gRumbleDataQueue (tarray (Tstruct _RumbleData noattr) 3))
                (Econst_int (Int.repr 1) tint)
                (tptr (Tstruct _RumbleData noattr)))
              (Tstruct _RumbleData noattr)) _unk00 tuchar)
          (Econst_int (Int.repr 0) tint))
        (Ssequence
          (Sassign
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Evar _gRumbleDataQueue (tarray (Tstruct _RumbleData noattr) 3))
                  (Econst_int (Int.repr 2) tint)
                  (tptr (Tstruct _RumbleData noattr)))
                (Tstruct _RumbleData noattr)) _unk00 tuchar)
            (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Sassign
              (Efield
                (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                _unk04 tshort) (Econst_int (Int.repr 0) tint))
            (Ssequence
              (Sassign
                (Efield
                  (Evar _gCurrRumbleSettings (Tstruct _StructSH8031D9B0 noattr))
                  _unk0A tshort) (Econst_int (Int.repr 0) tint))
              (Sassign (Evar _gRumblePakTimer tint)
                (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_create_thread_6 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _osCreateMesgQueue (Tfunction
                               ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                (tptr (tptr tvoid)) :: tint :: nil) tvoid
                               cc_default))
    ((Eaddrof
       (Evar _gRumbleThreadVIMesgQueue (Tstruct _OSMesgQueue_s noattr))
       (tptr (Tstruct _OSMesgQueue_s noattr))) ::
     (Eaddrof (Evar _gRumbleThreadVIMesgBuf (tptr tvoid))
       (tptr (tptr tvoid))) :: (Econst_int (Int.repr 1) tint) :: nil))
  (Ssequence
    (Scall None
      (Evar _osCreateThread (Tfunction
                              ((tptr (Tstruct _OSThread_s noattr)) :: tint ::
                               (tptr (Tfunction ((tptr tvoid) :: nil) tvoid
                                       cc_default)) :: (tptr tvoid) ::
                               (tptr tvoid) :: tint :: nil) tvoid cc_default))
      ((Eaddrof (Evar _gRumblePakThread (Tstruct _OSThread_s noattr))
         (tptr (Tstruct _OSThread_s noattr))) ::
       (Econst_int (Int.repr 6) tint) ::
       (Evar _thread6_rumble_loop (Tfunction ((tptr tvoid) :: nil) tvoid
                                    cc_default)) ::
       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
       (Ebinop Oadd (Evar _gThread6Stack (tarray tuchar 0))
         (Econst_int (Int.repr 8192) tint) (tptr tuchar)) ::
       (Econst_int (Int.repr 30) tint) :: nil))
    (Scall None
      (Evar _osStartThread (Tfunction
                             ((tptr (Tstruct _OSThread_s noattr)) :: nil)
                             tvoid cc_default))
      ((Eaddrof (Evar _gRumblePakThread (Tstruct _OSThread_s noattr))
         (tptr (Tstruct _OSThread_s noattr))) :: nil))))
|}.

Definition f_rumble_thread_update_vi := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1 (Evar _sRumblePakThreadActive tint))
    (Sifthenelse (Eunop Onotbool (Etempvar _t'1 tint) tint)
      (Sreturn None)
      Sskip))
  (Scall None
    (Evar _osSendMesg (Tfunction
                        ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                         (tptr tvoid) :: tint :: nil) tint cc_default))
    ((Eaddrof
       (Evar _gRumbleThreadVIMesgQueue (Tstruct _OSMesgQueue_s noattr))
       (tptr (Tstruct _OSMesgQueue_s noattr))) ::
     (Ecast (Econst_int (Int.repr 1448236099) tint) (tptr tvoid)) ::
     (Econst_int (Int.repr 0) tint) :: nil)))
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
 Composite __313 Struct
   (Member_plain _status tint ::
    Member_plain _queue (tptr (Tstruct _OSMesgQueue_s noattr)) ::
    Member_plain _channel tint :: Member_plain _id (tarray tuchar 32) ::
    Member_plain _label (tarray tuchar 32) :: Member_plain _version tint ::
    Member_plain _dir_size tint :: Member_plain _inode_table tint ::
    Member_plain _minode_table tint :: Member_plain _dir_table tint ::
    Member_plain _inode_start_page tint :: Member_plain _banks tuchar ::
    Member_plain _activebank tuchar :: nil)
   noattr ::
 Composite __317 Struct
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
    Member_plain _controllerData (tptr (Tstruct __319 noattr)) ::
    Member_plain _port tint :: nil)
   noattr ::
 Composite _DemoInput Struct
   (Member_plain _timer tuchar :: Member_plain _rawStickX tschar ::
    Member_plain _rawStickY tschar :: Member_plain _buttonMask tuchar :: nil)
   noattr ::
 Composite _RumbleData Struct
   (Member_plain _unk00 tuchar :: Member_plain _unk01 tuchar ::
    Member_plain _unk02 tshort :: Member_plain _unk04 tshort :: nil)
   noattr ::
 Composite _StructSH8031D9B0 Struct
   (Member_plain _unk00 tshort :: Member_plain _unk02 tshort ::
    Member_plain _unk04 tshort :: Member_plain _unk06 tshort ::
    Member_plain _unk08 tshort :: Member_plain _unk0A tshort ::
    Member_plain _unk0C tshort :: Member_plain _unk0E tshort :: nil)
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
 (_osCreateThread,
   Gfun(External (EF_external "osCreateThread"
                   (mksignature
                     (AST.Xptr :: AST.Xint :: AST.Xptr :: AST.Xptr ::
                      AST.Xptr :: AST.Xint :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _OSThread_s noattr)) :: tint ::
      (tptr (Tfunction ((tptr tvoid) :: nil) tvoid cc_default)) ::
      (tptr tvoid) :: (tptr tvoid) :: tint :: nil) tvoid cc_default)) ::
 (_osStartThread,
   Gfun(External (EF_external "osStartThread"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _OSThread_s noattr)) :: nil) tvoid cc_default)) ::
 (_osCreateMesgQueue,
   Gfun(External (EF_external "osCreateMesgQueue"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     ((tptr (Tstruct _OSMesgQueue_s noattr)) :: (tptr (tptr tvoid)) ::
      tint :: nil) tvoid cc_default)) ::
 (_osSendMesg,
   Gfun(External (EF_external "osSendMesg"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xint cc_default))
     ((tptr (Tstruct _OSMesgQueue_s noattr)) :: (tptr tvoid) :: tint :: nil)
     tint cc_default)) ::
 (_osRecvMesg,
   Gfun(External (EF_external "osRecvMesg"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xint cc_default))
     ((tptr (Tstruct _OSMesgQueue_s noattr)) :: (tptr (tptr tvoid)) ::
      tint :: nil) tint cc_default)) ::
 (_osMotorInit,
   Gfun(External (EF_external "osMotorInit"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xint cc_default))
     ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
      (tptr (Tstruct __313 noattr)) :: tint :: nil) tint cc_default)) ::
 (_osMotorStop,
   Gfun(External (EF_external "osMotorStop"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct __313 noattr)) :: nil) tint cc_default)) ::
 (_osMotorStart,
   Gfun(External (EF_external "osMotorStart"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct __313 noattr)) :: nil) tint cc_default)) ::
 (_gPlayer1Controller, Gvar v_gPlayer1Controller) ::
 (_gCurrDemoInput, Gvar v_gCurrDemoInput) ::
 (_gThread6Stack, Gvar v_gThread6Stack) ::
 (_gSIEventMesgQueue, Gvar v_gSIEventMesgQueue) ::
 (_gNumVblanks, Gvar v_gNumVblanks) :: (_gResetTimer, Gvar v_gResetTimer) ::
 (_gRumblePakThread, Gvar v_gRumblePakThread) ::
 (_gRumblePakPfs, Gvar v_gRumblePakPfs) ::
 (_gRumblePakSchedulerMesgBuf, Gvar v_gRumblePakSchedulerMesgBuf) ::
 (_gRumblePakSchedulerMesgQueue, Gvar v_gRumblePakSchedulerMesgQueue) ::
 (_gRumbleThreadVIMesgBuf, Gvar v_gRumbleThreadVIMesgBuf) ::
 (_gRumbleThreadVIMesgQueue, Gvar v_gRumbleThreadVIMesgQueue) ::
 (_gRumbleDataQueue, Gvar v_gRumbleDataQueue) ::
 (_gCurrRumbleSettings, Gvar v_gCurrRumbleSettings) ::
 (_sRumblePakThreadActive, Gvar v_sRumblePakThreadActive) ::
 (_sRumblePakActive, Gvar v_sRumblePakActive) ::
 (_sRumblePakErrorCount, Gvar v_sRumblePakErrorCount) ::
 (_gRumblePakTimer, Gvar v_gRumblePakTimer) ::
 (_init_rumble_pak_scheduler_queue, Gfun(Internal f_init_rumble_pak_scheduler_queue)) ::
 (_block_until_rumble_pak_free, Gfun(Internal f_block_until_rumble_pak_free)) ::
 (_release_rumble_pak_control, Gfun(Internal f_release_rumble_pak_control)) ::
 (_start_rumble, Gfun(Internal f_start_rumble)) ::
 (_stop_rumble, Gfun(Internal f_stop_rumble)) ::
 (_update_rumble_pak, Gfun(Internal f_update_rumble_pak)) ::
 (_update_rumble_data_queue, Gfun(Internal f_update_rumble_data_queue)) ::
 (_queue_rumble_data, Gfun(Internal f_queue_rumble_data)) ::
 (_func_sh_8024C89C, Gfun(Internal f_func_sh_8024C89C)) ::
 (_is_rumble_finished_and_queue_empty, Gfun(Internal f_is_rumble_finished_and_queue_empty)) ::
 (_reset_rumble_timers, Gfun(Internal f_reset_rumble_timers)) ::
 (_reset_rumble_timers_2, Gfun(Internal f_reset_rumble_timers_2)) ::
 (_func_sh_8024CA04, Gfun(Internal f_func_sh_8024CA04)) ::
 (_thread6_rumble_loop, Gfun(Internal f_thread6_rumble_loop)) ::
 (_cancel_rumble, Gfun(Internal f_cancel_rumble)) ::
 (_create_thread_6, Gfun(Internal f_create_thread_6)) ::
 (_rumble_thread_update_vi, Gfun(Internal f_rumble_thread_update_vi)) :: nil).

Definition public_idents : list ident :=
(_rumble_thread_update_vi :: _create_thread_6 :: _cancel_rumble ::
 _func_sh_8024CA04 :: _reset_rumble_timers_2 :: _reset_rumble_timers ::
 _is_rumble_finished_and_queue_empty :: _func_sh_8024C89C ::
 _queue_rumble_data :: _release_rumble_pak_control ::
 _block_until_rumble_pak_free :: _init_rumble_pak_scheduler_queue ::
 _gRumblePakTimer :: _sRumblePakErrorCount :: _sRumblePakActive ::
 _sRumblePakThreadActive :: _gCurrRumbleSettings :: _gRumbleDataQueue ::
 _gRumbleThreadVIMesgQueue :: _gRumbleThreadVIMesgBuf ::
 _gRumblePakSchedulerMesgQueue :: _gRumblePakSchedulerMesgBuf ::
 _gRumblePakPfs :: _gRumblePakThread :: _gResetTimer :: _gNumVblanks ::
 _gSIEventMesgQueue :: _gThread6Stack :: _gCurrDemoInput ::
 _gPlayer1Controller :: _osMotorStart :: _osMotorStop :: _osMotorInit ::
 _osRecvMesg :: _osSendMesg :: _osCreateMesgQueue :: _osStartThread ::
 _osCreateThread :: ___builtin_debug :: ___builtin_sync_fetch_and_add ::
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


