(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Produced by: pipeline/clightgen.sh
   From source: inputs/eyerok_model.c
   clightgen:   The CompCert CompCert AST generator, version 3.15
   Flags:       -normalize
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
  Definition source_file := "inputs/eyerok_model.c".
  Definition normalized := true.
End Info.

Definition _EyerokVerticalState : ident := $"EyerokVerticalState".
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
Definition _action : ident := $"action".
Definition _ascentBudget : ident := $"ascentBudget".
Definition _budget : ident := $"budget".
Definition _ceiling : ident := $"ceiling".
Definition _delta : ident := $"delta".
Definition _eyerok_action_ascent_budget : ident := $"eyerok_action_ascent_budget".
Definition _eyerok_clamp_height : ident := $"eyerok_clamp_height".
Definition _eyerok_controlled_position : ident := $"eyerok_controlled_position".
Definition _eyerok_delete : ident := $"eyerok_delete".
Definition _eyerok_height_ceiling : ident := $"eyerok_height_ceiling".
Definition _eyerok_land : ident := $"eyerok_land".
Definition _eyerok_nonrising_frame : ident := $"eyerok_nonrising_frame".
Definition _eyerok_partial_update : ident := $"eyerok_partial_update".
Definition _eyerok_runaway_frame : ident := $"eyerok_runaway_frame".
Definition _eyerok_safe_envelope : ident := $"eyerok_safe_envelope".
Definition _eyerok_safe_rise : ident := $"eyerok_safe_rise".
Definition _eyerok_start_authentic_impulse : ident := $"eyerok_start_authentic_impulse".
Definition _eyerok_support_ceiling : ident := $"eyerok_support_ceiling".
Definition _eyerok_vertical_init : ident := $"eyerok_vertical_init".
Definition _floorY : ident := $"floorY".
Definition _gravity : ident := $"gravity".
Definition _grounded : ident := $"grounded".
Definition _main : ident := $"main".
Definition _mode : ident := $"mode".
Definition _nextAction : ident := $"nextAction".
Definition _nextY : ident := $"nextY".
Definition _rank : ident := $"rank".
Definition _requestedY : ident := $"requestedY".
Definition _state : ident := $"state".
Definition _y : ident := $"y".
Definition _t'1 : ident := 128%positive.
Definition _t'10 : ident := 137%positive.
Definition _t'11 : ident := 138%positive.
Definition _t'12 : ident := 139%positive.
Definition _t'2 : ident := 129%positive.
Definition _t'3 : ident := 130%positive.
Definition _t'4 : ident := 131%positive.
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition f_eyerok_support_ceiling := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_rank, tint) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Oeq (Etempvar _rank tint)
                 (Econst_int (Int.repr 0) tint) tint)
    (Sreturn (Some (Econst_int (Int.repr 896) tint)))
    Sskip)
  (Sreturn (Some (Econst_int (Int.repr 1703) tint))))
|}.

Definition f_eyerok_height_ceiling := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_rank, tint) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Oeq (Etempvar _rank tint)
                 (Econst_int (Int.repr 0) tint) tint)
    (Sreturn (Some (Econst_int (Int.repr 1196) tint)))
    Sskip)
  (Sreturn (Some (Econst_int (Int.repr 2003) tint))))
|}.

Definition f_eyerok_clamp_height := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_y, tint) :: (_ceiling, tint) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Olt (Etempvar _y tint)
                 (Eunop Oneg (Econst_int (Int.repr 12000) tint) tint) tint)
    (Sreturn (Some (Eunop Oneg (Econst_int (Int.repr 12000) tint) tint)))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop Ogt (Etempvar _y tint) (Etempvar _ceiling tint)
                   tint)
      (Sreturn (Some (Etempvar _ceiling tint)))
      Sskip)
    (Sreturn (Some (Etempvar _y tint)))))
|}.

Definition f_eyerok_vertical_init := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_state, (tptr (Tstruct _EyerokVerticalState noattr))) ::
                (_rank, tint) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sassign
    (Efield
      (Ederef (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
        (Tstruct _EyerokVerticalState noattr)) _rank tint)
    (Etempvar _rank tint))
  (Ssequence
    (Sassign
      (Efield
        (Ederef
          (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
          (Tstruct _EyerokVerticalState noattr)) _action tint)
      (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Sassign
        (Efield
          (Ederef
            (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
            (Tstruct _EyerokVerticalState noattr)) _mode tint)
        (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Sassign
          (Efield
            (Ederef
              (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
              (Tstruct _EyerokVerticalState noattr)) _y tint)
          (Eunop Oneg (Econst_int (Int.repr 1534) tint) tint))
        (Ssequence
          (Sassign
            (Efield
              (Ederef
                (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
                (Tstruct _EyerokVerticalState noattr)) _ascentBudget tint)
            (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
                  (Tstruct _EyerokVerticalState noattr)) _gravity tint)
              (Econst_int (Int.repr 0) tint))
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
                  (Tstruct _EyerokVerticalState noattr)) _grounded tint)
              (Econst_int (Int.repr 1) tint))))))))
|}.

Definition f_eyerok_controlled_position := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_state, (tptr (Tstruct _EyerokVerticalState noattr))) ::
                (_action, tint) :: (_requestedY, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Sassign
    (Efield
      (Ederef (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
        (Tstruct _EyerokVerticalState noattr)) _action tint)
    (Etempvar _action tint))
  (Ssequence
    (Sassign
      (Efield
        (Ederef
          (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
          (Tstruct _EyerokVerticalState noattr)) _mode tint)
      (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _eyerok_clamp_height (Tfunction (tint :: tint :: nil) tint
                                       cc_default))
          ((Etempvar _requestedY tint) ::
           (Eunop Oneg (Econst_int (Int.repr 934) tint) tint) :: nil))
        (Sassign
          (Efield
            (Ederef
              (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
              (Tstruct _EyerokVerticalState noattr)) _y tint)
          (Etempvar _t'1 tint)))
      (Ssequence
        (Sassign
          (Efield
            (Ederef
              (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
              (Tstruct _EyerokVerticalState noattr)) _ascentBudget tint)
          (Econst_int (Int.repr 0) tint))
        (Sassign
          (Efield
            (Ederef
              (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
              (Tstruct _EyerokVerticalState noattr)) _grounded tint)
          (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_eyerok_land := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_state, (tptr (Tstruct _EyerokVerticalState noattr))) ::
                (_floorY, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) :: (_t'3, tint) :: nil);
  fn_body :=
(Ssequence
  (Sassign
    (Efield
      (Ederef (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
        (Tstruct _EyerokVerticalState noattr)) _mode tint)
    (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef
                (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
                (Tstruct _EyerokVerticalState noattr)) _rank tint))
          (Scall (Some _t'1)
            (Evar _eyerok_support_ceiling (Tfunction (tint :: nil) tint
                                            cc_default))
            ((Etempvar _t'3 tint) :: nil)))
        (Scall (Some _t'2)
          (Evar _eyerok_clamp_height (Tfunction (tint :: tint :: nil) tint
                                       cc_default))
          ((Etempvar _floorY tint) :: (Etempvar _t'1 tint) :: nil)))
      (Sassign
        (Efield
          (Ederef
            (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
            (Tstruct _EyerokVerticalState noattr)) _y tint)
        (Etempvar _t'2 tint)))
    (Ssequence
      (Sassign
        (Efield
          (Ederef
            (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
            (Tstruct _EyerokVerticalState noattr)) _ascentBudget tint)
        (Econst_int (Int.repr 0) tint))
      (Sassign
        (Efield
          (Ederef
            (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
            (Tstruct _EyerokVerticalState noattr)) _grounded tint)
        (Econst_int (Int.repr 1) tint)))))
|}.

Definition f_eyerok_action_ascent_budget := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_action, tint) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Oeq (Etempvar _action tint)
                 (Econst_int (Int.repr 12) tint) tint)
    (Sreturn (Some (Econst_int (Int.repr 98) tint)))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop Oeq (Etempvar _action tint)
                   (Econst_int (Int.repr 15) tint) tint)
      (Sreturn (Some (Econst_int (Int.repr 288) tint)))
      Sskip)
    (Ssequence
      (Sifthenelse (Ebinop Oeq (Etempvar _action tint)
                     (Econst_int (Int.repr 11) tint) tint)
        (Sreturn (Some (Econst_int (Int.repr 285) tint)))
        Sskip)
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_eyerok_start_authentic_impulse := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_state, (tptr (Tstruct _EyerokVerticalState noattr))) ::
                (_action, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_budget, tint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'7, tint) ::
               (_t'6, tint) :: (_t'5, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _eyerok_action_ascent_budget (Tfunction (tint :: nil) tint
                                           cc_default))
      ((Etempvar _action tint) :: nil))
    (Sset _budget (Etempvar _t'1 tint)))
  (Ssequence
    (Sassign
      (Efield
        (Ederef
          (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
          (Tstruct _EyerokVerticalState noattr)) _action tint)
      (Etempvar _action tint))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sifthenelse (Ebinop Oeq (Etempvar _action tint)
                         (Econst_int (Int.repr 11) tint) tint)
            (Ssequence
              (Sset _t'7
                (Efield
                  (Ederef
                    (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
                    (Tstruct _EyerokVerticalState noattr)) _grounded tint))
              (Sset _t'2 (Ecast (Etempvar _t'7 tint) tbool)))
            (Sset _t'2 (Econst_int (Int.repr 0) tint)))
          (Sifthenelse (Etempvar _t'2 tint)
            (Ssequence
              (Sset _t'6
                (Efield
                  (Ederef
                    (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
                    (Tstruct _EyerokVerticalState noattr)) _gravity tint))
              (Sset _t'3
                (Ecast
                  (Ebinop Oeq (Etempvar _t'6 tint)
                    (Econst_int (Int.repr 0) tint) tint) tbool)))
            (Sset _t'3 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'3 tint)
          (Ssequence
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
                  (Tstruct _EyerokVerticalState noattr)) _mode tint)
              (Econst_int (Int.repr 2) tint))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
                    (Tstruct _EyerokVerticalState noattr)) _ascentBudget
                  tint) (Econst_int (Int.repr 0) tint))
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
                      (Tstruct _EyerokVerticalState noattr)) _grounded tint)
                  (Econst_int (Int.repr 0) tint))
                (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
          Sskip))
      (Ssequence
        (Sifthenelse (Ebinop Oeq (Etempvar _budget tint)
                       (Econst_int (Int.repr 0) tint) tint)
          (Sreturn (Some (Econst_int (Int.repr 0) tint)))
          Sskip)
        (Ssequence
          (Ssequence
            (Sifthenelse (Ebinop Oeq (Etempvar _action tint)
                           (Econst_int (Int.repr 11) tint) tint)
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef
                      (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
                      (Tstruct _EyerokVerticalState noattr)) _gravity tint))
                (Sset _t'4
                  (Ecast
                    (Ebinop Ogt (Etempvar _t'5 tint)
                      (Eunop Oneg (Econst_int (Int.repr 15) tint) tint) tint)
                    tbool)))
              (Sset _t'4 (Econst_int (Int.repr 0) tint)))
            (Sifthenelse (Etempvar _t'4 tint)
              (Sreturn (Some (Econst_int (Int.repr 0) tint)))
              Sskip))
          (Ssequence
            (Sifthenelse (Ebinop Oeq (Etempvar _action tint)
                           (Econst_int (Int.repr 11) tint) tint)
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
                    (Tstruct _EyerokVerticalState noattr)) _gravity tint)
                (Eunop Oneg (Econst_int (Int.repr 15) tint) tint))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
                    (Tstruct _EyerokVerticalState noattr)) _gravity tint)
                (Eunop Oneg (Econst_int (Int.repr 4) tint) tint)))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
                    (Tstruct _EyerokVerticalState noattr)) _mode tint)
                (Econst_int (Int.repr 1) tint))
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
                      (Tstruct _EyerokVerticalState noattr)) _ascentBudget
                    tint) (Etempvar _budget tint))
                (Ssequence
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
                        (Tstruct _EyerokVerticalState noattr)) _grounded
                      tint) (Econst_int (Int.repr 0) tint))
                  (Sreturn (Some (Econst_int (Int.repr 1) tint))))))))))))
|}.

Definition f_eyerok_safe_rise := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_state, (tptr (Tstruct _EyerokVerticalState noattr))) ::
                (_delta, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) :: (_t'6, tint) ::
               (_t'5, tint) :: (_t'4, tint) :: (_t'3, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'6
        (Efield
          (Ederef
            (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
            (Tstruct _EyerokVerticalState noattr)) _mode tint))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'6 tint)
                     (Econst_int (Int.repr 1) tint) tint)
        (Sset _t'1
          (Ecast
            (Ebinop Oge (Etempvar _delta tint) (Econst_int (Int.repr 0) tint)
              tint) tbool))
        (Sset _t'1 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'1 tint)
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef
              (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
              (Tstruct _EyerokVerticalState noattr)) _ascentBudget tint))
        (Sset _t'2
          (Ecast
            (Ebinop Ole (Etempvar _delta tint) (Etempvar _t'5 tint) tint)
            tbool)))
      (Sset _t'2 (Econst_int (Int.repr 0) tint))))
  (Sifthenelse (Etempvar _t'2 tint)
    (Ssequence
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef
              (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
              (Tstruct _EyerokVerticalState noattr)) _y tint))
        (Sassign
          (Efield
            (Ederef
              (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
              (Tstruct _EyerokVerticalState noattr)) _y tint)
          (Ebinop Oadd (Etempvar _t'4 tint) (Etempvar _delta tint) tint)))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef
              (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
              (Tstruct _EyerokVerticalState noattr)) _ascentBudget tint))
        (Sassign
          (Efield
            (Ederef
              (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
              (Tstruct _EyerokVerticalState noattr)) _ascentBudget tint)
          (Ebinop Osub (Etempvar _t'3 tint) (Etempvar _delta tint) tint))))
    Sskip))
|}.

Definition f_eyerok_nonrising_frame := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_state, (tptr (Tstruct _EyerokVerticalState noattr))) ::
                (_nextY, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'2, tint) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Oge (Etempvar _nextY tint)
                 (Eunop Oneg (Econst_int (Int.repr 12000) tint) tint) tint)
    (Ssequence
      (Sset _t'2
        (Efield
          (Ederef
            (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
            (Tstruct _EyerokVerticalState noattr)) _y tint))
      (Sset _t'1
        (Ecast (Ebinop Ole (Etempvar _nextY tint) (Etempvar _t'2 tint) tint)
          tbool)))
    (Sset _t'1 (Econst_int (Int.repr 0) tint)))
  (Sifthenelse (Etempvar _t'1 tint)
    (Sassign
      (Efield
        (Ederef
          (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
          (Tstruct _EyerokVerticalState noattr)) _y tint)
      (Etempvar _nextY tint))
    Sskip))
|}.

Definition f_eyerok_partial_update := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_state, (tptr (Tstruct _EyerokVerticalState noattr))) ::
                (_nextAction, tint) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Sassign
  (Efield
    (Ederef (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
      (Tstruct _EyerokVerticalState noattr)) _action tint)
  (Etempvar _nextAction tint))
|}.

Definition f_eyerok_delete := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_state, (tptr (Tstruct _EyerokVerticalState noattr))) ::
                nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sassign
    (Efield
      (Ederef (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
        (Tstruct _EyerokVerticalState noattr)) _mode tint)
    (Econst_int (Int.repr 3) tint))
  (Ssequence
    (Sassign
      (Efield
        (Ederef
          (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
          (Tstruct _EyerokVerticalState noattr)) _ascentBudget tint)
      (Econst_int (Int.repr 0) tint))
    (Sassign
      (Efield
        (Ederef
          (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
          (Tstruct _EyerokVerticalState noattr)) _grounded tint)
      (Econst_int (Int.repr 0) tint))))
|}.

Definition f_eyerok_runaway_frame := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_state, (tptr (Tstruct _EyerokVerticalState noattr))) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Efield
      (Ederef (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
        (Tstruct _EyerokVerticalState noattr)) _mode tint))
  (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tint)
                 (Econst_int (Int.repr 2) tint) tint)
    (Ssequence
      (Sset _t'2
        (Efield
          (Ederef
            (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
            (Tstruct _EyerokVerticalState noattr)) _y tint))
      (Sassign
        (Efield
          (Ederef
            (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
            (Tstruct _EyerokVerticalState noattr)) _y tint)
        (Ebinop Oadd (Etempvar _t'2 tint) (Econst_int (Int.repr 100) tint)
          tint)))
    Sskip))
|}.

Definition f_eyerok_safe_envelope := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_state, (tptr (Tstruct _EyerokVerticalState noattr))) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_ceiling, tint) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'12, tint) :: (_t'11, tint) :: (_t'10, tint) ::
               (_t'9, tint) :: (_t'8, tint) :: (_t'7, tint) ::
               (_t'6, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'12
        (Efield
          (Ederef
            (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
            (Tstruct _EyerokVerticalState noattr)) _rank tint))
      (Scall (Some _t'1)
        (Evar _eyerok_height_ceiling (Tfunction (tint :: nil) tint
                                       cc_default))
        ((Etempvar _t'12 tint) :: nil)))
    (Sset _ceiling (Etempvar _t'1 tint)))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'10
              (Efield
                (Ederef
                  (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
                  (Tstruct _EyerokVerticalState noattr)) _mode tint))
            (Sifthenelse (Ebinop One (Etempvar _t'10 tint)
                           (Econst_int (Int.repr 2) tint) tint)
              (Ssequence
                (Sset _t'11
                  (Efield
                    (Ederef
                      (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
                      (Tstruct _EyerokVerticalState noattr)) _ascentBudget
                    tint))
                (Sset _t'2
                  (Ecast
                    (Ebinop Oge (Etempvar _t'11 tint)
                      (Econst_int (Int.repr 0) tint) tint) tbool)))
              (Sset _t'2 (Econst_int (Int.repr 0) tint))))
          (Sifthenelse (Etempvar _t'2 tint)
            (Ssequence
              (Sset _t'9
                (Efield
                  (Ederef
                    (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
                    (Tstruct _EyerokVerticalState noattr)) _ascentBudget
                  tint))
              (Sset _t'3
                (Ecast
                  (Ebinop Ole (Etempvar _t'9 tint)
                    (Econst_int (Int.repr 300) tint) tint) tbool)))
            (Sset _t'3 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'3 tint)
          (Ssequence
            (Sset _t'8
              (Efield
                (Ederef
                  (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
                  (Tstruct _EyerokVerticalState noattr)) _y tint))
            (Sset _t'4
              (Ecast
                (Ebinop Ole (Etempvar _t'8 tint) (Etempvar _ceiling tint)
                  tint) tbool)))
          (Sset _t'4 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'4 tint)
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef
                (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
                (Tstruct _EyerokVerticalState noattr)) _y tint))
          (Ssequence
            (Sset _t'7
              (Efield
                (Ederef
                  (Etempvar _state (tptr (Tstruct _EyerokVerticalState noattr)))
                  (Tstruct _EyerokVerticalState noattr)) _ascentBudget tint))
            (Sset _t'5
              (Ecast
                (Ebinop Ole
                  (Ebinop Oadd (Etempvar _t'6 tint) (Etempvar _t'7 tint)
                    tint) (Etempvar _ceiling tint) tint) tbool))))
        (Sset _t'5 (Econst_int (Int.repr 0) tint))))
    (Sreturn (Some (Etempvar _t'5 tint)))))
|}.

Definition composites : list composite_definition :=
(Composite _EyerokVerticalState Struct
   (Member_plain _rank tint :: Member_plain _action tint ::
    Member_plain _mode tint :: Member_plain _y tint ::
    Member_plain _ascentBudget tint :: Member_plain _gravity tint ::
    Member_plain _grounded tint :: nil)
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
 (_eyerok_support_ceiling, Gfun(Internal f_eyerok_support_ceiling)) ::
 (_eyerok_height_ceiling, Gfun(Internal f_eyerok_height_ceiling)) ::
 (_eyerok_clamp_height, Gfun(Internal f_eyerok_clamp_height)) ::
 (_eyerok_vertical_init, Gfun(Internal f_eyerok_vertical_init)) ::
 (_eyerok_controlled_position, Gfun(Internal f_eyerok_controlled_position)) ::
 (_eyerok_land, Gfun(Internal f_eyerok_land)) ::
 (_eyerok_action_ascent_budget, Gfun(Internal f_eyerok_action_ascent_budget)) ::
 (_eyerok_start_authentic_impulse, Gfun(Internal f_eyerok_start_authentic_impulse)) ::
 (_eyerok_safe_rise, Gfun(Internal f_eyerok_safe_rise)) ::
 (_eyerok_nonrising_frame, Gfun(Internal f_eyerok_nonrising_frame)) ::
 (_eyerok_partial_update, Gfun(Internal f_eyerok_partial_update)) ::
 (_eyerok_delete, Gfun(Internal f_eyerok_delete)) ::
 (_eyerok_runaway_frame, Gfun(Internal f_eyerok_runaway_frame)) ::
 (_eyerok_safe_envelope, Gfun(Internal f_eyerok_safe_envelope)) :: nil).

Definition public_idents : list ident :=
(_eyerok_safe_envelope :: _eyerok_runaway_frame :: _eyerok_delete ::
 _eyerok_partial_update :: _eyerok_nonrising_frame :: _eyerok_safe_rise ::
 _eyerok_start_authentic_impulse :: _eyerok_action_ascent_budget ::
 _eyerok_land :: _eyerok_controlled_position :: _eyerok_vertical_init ::
 _eyerok_clamp_height :: _eyerok_height_ceiling :: _eyerok_support_ceiling ::
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
