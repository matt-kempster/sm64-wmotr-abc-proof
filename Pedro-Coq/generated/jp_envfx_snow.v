(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_JP
   Source:          src/game/envfx_snow.c
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_JP=1 -DF3D_OLD=1
   Link hygiene:    private __stringlit_N atoms prefixed with jp_envfx_snow
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
  Definition source_file := "build/pinned-sm64/src/game/envfx_snow.c".
  Definition normalized := true.
End Info.

Definition _D_80330644 : ident := $"D_80330644".
Definition _EnvFxParticle : ident := $"EnvFxParticle".
Definition _MemoryPool : ident := $"MemoryPool".
Definition _SnowFlakeVertex : ident := $"SnowFlakeVertex".
Definition __459 : ident := $"_459".
Definition __461 : ident := $"_461".
Definition __463 : ident := $"_463".
Definition __510 : ident := $"_510".
Definition __512 : ident := $"_512".
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
Definition __g__4 : ident := $"_g__4".
Definition __g__5 : ident := $"_g__5".
Definition __g__6 : ident := $"_g__6".
Definition __g__7 : ident := $"_g__7".
Definition __g__8 : ident := $"_g__8".
Definition _a : ident := $"a".
Definition _alloc_display_list : ident := $"alloc_display_list".
Definition _angleAndDist : ident := $"angleAndDist".
Definition _animFrame : ident := $"animFrame".
Definition _append_snowflake_vertex_buffer : ident := $"append_snowflake_vertex_buffer".
Definition _atan2s : ident := $"atan2s".
Definition _bubbleY : ident := $"bubbleY".
Definition _bzero : ident := $"bzero".
Definition _camFrom : ident := $"camFrom".
Definition _camTo : ident := $"camTo".
Definition _cn : ident := $"cn".
Definition _cosMYaw : ident := $"cosMYaw".
Definition _cosPitch : ident := $"cosPitch".
Definition _deltaX : ident := $"deltaX".
Definition _deltaY : ident := $"deltaY".
Definition _deltaZ : ident := $"deltaZ".
Definition _dx : ident := $"dx".
Definition _dy : ident := $"dy".
Definition _dz : ident := $"dz".
Definition _envfx_cleanup_snow : ident := $"envfx_cleanup_snow".
Definition _envfx_init_snow : ident := $"envfx_init_snow".
Definition _envfx_is_snowflake_alive : ident := $"envfx_is_snowflake_alive".
Definition _envfx_update_bubbles : ident := $"envfx_update_bubbles".
Definition _envfx_update_particles : ident := $"envfx_update_particles".
Definition _envfx_update_snow : ident := $"envfx_update_snow".
Definition _envfx_update_snow_blizzard : ident := $"envfx_update_snow_blizzard".
Definition _envfx_update_snow_normal : ident := $"envfx_update_snow_normal".
Definition _envfx_update_snow_water : ident := $"envfx_update_snow_water".
Definition _envfx_update_snowflake_count : ident := $"envfx_update_snowflake_count".
Definition _filler : ident := $"filler".
Definition _find_water_level : ident := $"find_water_level".
Definition _flag : ident := $"flag".
Definition _force_structure_alignment : ident := $"force_structure_alignment".
Definition _from : ident := $"from".
Definition _gEffectsMemoryPool : ident := $"gEffectsMemoryPool".
Definition _gEnvFxBuffer : ident := $"gEnvFxBuffer".
Definition _gEnvFxMode : ident := $"gEnvFxMode".
Definition _gGlobalTimer : ident := $"gGlobalTimer".
Definition _gSineTable : ident := $"gSineTable".
Definition _gSnowCylinderLastPos : ident := $"gSnowCylinderLastPos".
Definition _gSnowFlakeVertex1 : ident := $"gSnowFlakeVertex1".
Definition _gSnowFlakeVertex2 : ident := $"gSnowFlakeVertex2".
Definition _gSnowFlakeVertex3 : ident := $"gSnowFlakeVertex3".
Definition _gSnowParticleCount : ident := $"gSnowParticleCount".
Definition _gSnowParticleMaxCount : ident := $"gSnowParticleMaxCount".
Definition _gSnowTempVtx : ident := $"gSnowTempVtx".
Definition _get_dialog_id : ident := $"get_dialog_id".
Definition _gfx : ident := $"gfx".
Definition _gfxStart : ident := $"gfxStart".
Definition _globalTimer : ident := $"globalTimer".
Definition _i : ident := $"i".
Definition _index : ident := $"index".
Definition _isAlive : ident := $"isAlive".
Definition _main : ident := $"main".
Definition _marioPos : ident := $"marioPos".
Definition _mem_pool_alloc : ident := $"mem_pool_alloc".
Definition _mem_pool_free : ident := $"mem_pool_free".
Definition _mode : ident := $"mode".
Definition _n : ident := $"n".
Definition _ob : ident := $"ob".
Definition _orbit_from_positions : ident := $"orbit_from_positions".
Definition _origin : ident := $"origin".
Definition _pitch : ident := $"pitch".
Definition _pos_from_orbit : ident := $"pos_from_orbit".
Definition _radius : ident := $"radius".
Definition _random_float : ident := $"random_float".
Definition _result : ident := $"result".
Definition _rotate_triangle_vertices : ident := $"rotate_triangle_vertices".
Definition _sinMYaw : ident := $"sinMYaw".
Definition _sinPitch : ident := $"sinPitch".
Definition _snowCylinderPos : ident := $"snowCylinderPos".
Definition _snowCylinderX : ident := $"snowCylinderX".
Definition _snowCylinderY : ident := $"snowCylinderY".
Definition _snowCylinderZ : ident := $"snowCylinderZ".
Definition _snowMode : ident := $"snowMode".
Definition _snowParticleArray : ident := $"snowParticleArray".
Definition _sqrtf : ident := $"sqrtf".
Definition _tc : ident := $"tc".
Definition _tiny_bubble_dl_0B006A50 : ident := $"tiny_bubble_dl_0B006A50".
Definition _tiny_bubble_dl_0B006AB0 : ident := $"tiny_bubble_dl_0B006AB0".
Definition _tiny_bubble_dl_0B006CD8 : ident := $"tiny_bubble_dl_0B006CD8".
Definition _to : ident := $"to".
Definition _unusedBubbleVar : ident := $"unusedBubbleVar".
Definition _v : ident := $"v".
Definition _v1 : ident := $"v1".
Definition _v2 : ident := $"v2".
Definition _v3 : ident := $"v3".
Definition _vertBuf : ident := $"vertBuf".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _w0 : ident := $"w0".
Definition _w1 : ident := $"w1".
Definition _waterLevel : ident := $"waterLevel".
Definition _words : ident := $"words".
Definition _x : ident := $"x".
Definition _xPos : ident := $"xPos".
Definition _y : ident := $"y".
Definition _yPos : ident := $"yPos".
Definition _yaw : ident := $"yaw".
Definition _z : ident := $"z".
Definition _zPos : ident := $"zPos".
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
Definition _t'38 : ident := 165%positive.
Definition _t'39 : ident := 166%positive.
Definition _t'4 : ident := 131%positive.
Definition _t'40 : ident := 167%positive.
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

Definition v_gGlobalTimer := {|
  gvar_info := tuint;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSineTable := {|
  gvar_info := (tarray tfloat 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gEnvFxBuffer := {|
  gvar_info := (tptr (Tstruct _EnvFxParticle noattr));
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSnowCylinderLastPos := {|
  gvar_info := (tarray tint 3);
  gvar_init := (Init_space 12 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSnowParticleCount := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSnowParticleMaxCount := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gEnvFxMode := {|
  gvar_info := tschar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_80330644 := {|
  gvar_info := tint;
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSnowTempVtx := {|
  gvar_info := (tarray (Tunion __463 noattr) 3);
  gvar_init := (Init_int16 (Int.repr (-5)) :: Init_int16 (Int.repr 5) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int8 (Int.repr 127) :: Init_int8 (Int.repr 127) ::
                Init_int8 (Int.repr 127) :: Init_int8 (Int.repr 255) ::
                Init_int16 (Int.repr (-5)) :: Init_int16 (Int.repr (-5)) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 960) ::
                Init_int8 (Int.repr 127) :: Init_int8 (Int.repr 127) ::
                Init_int8 (Int.repr 127) :: Init_int8 (Int.repr 255) ::
                Init_int16 (Int.repr 5) :: Init_int16 (Int.repr 5) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 960) :: Init_int16 (Int.repr 0) ::
                Init_int8 (Int.repr 127) :: Init_int8 (Int.repr 127) ::
                Init_int8 (Int.repr 127) :: Init_int8 (Int.repr 255) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSnowFlakeVertex1 := {|
  gvar_info := (Tstruct _SnowFlakeVertex noattr);
  gvar_init := (Init_int16 (Int.repr (-5)) :: Init_int16 (Int.repr 5) ::
                Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSnowFlakeVertex2 := {|
  gvar_info := (Tstruct _SnowFlakeVertex noattr);
  gvar_init := (Init_int16 (Int.repr (-5)) :: Init_int16 (Int.repr (-5)) ::
                Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSnowFlakeVertex3 := {|
  gvar_info := (Tstruct _SnowFlakeVertex noattr);
  gvar_init := (Init_int16 (Int.repr 5) :: Init_int16 (Int.repr 5) ::
                Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_tiny_bubble_dl_0B006AB0 := {|
  gvar_info := (tptr tvoid);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_tiny_bubble_dl_0B006A50 := {|
  gvar_info := (tptr tvoid);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_tiny_bubble_dl_0B006CD8 := {|
  gvar_info := (tptr tvoid);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_envfx_init_snow := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_mode, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: (_t'6, tshort) ::
               (_t'5, (tptr (Tstruct _MemoryPool noattr))) ::
               (_t'4, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'3, tshort) ::
               (_t'2, (tptr (Tstruct _EnvFxParticle noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sswitch (Etempvar _mode tint)
    (LScons (Some 0)
      (Sreturn (Some (Econst_int (Int.repr 0) tint)))
      (LScons (Some 1)
        (Ssequence
          (Sassign (Evar _gSnowParticleMaxCount tshort)
            (Econst_int (Int.repr 140) tint))
          (Ssequence
            (Sassign (Evar _gSnowParticleCount tshort)
              (Econst_int (Int.repr 5) tint))
            Sbreak))
        (LScons (Some 2)
          (Ssequence
            (Sassign (Evar _gSnowParticleMaxCount tshort)
              (Econst_int (Int.repr 30) tint))
            (Ssequence
              (Sassign (Evar _gSnowParticleCount tshort)
                (Econst_int (Int.repr 30) tint))
              Sbreak))
          (LScons (Some 3)
            (Ssequence
              (Sassign (Evar _gSnowParticleMaxCount tshort)
                (Econst_int (Int.repr 140) tint))
              (Ssequence
                (Sassign (Evar _gSnowParticleCount tshort)
                  (Econst_int (Int.repr 140) tint))
                Sbreak))
            LSnil)))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'5
          (Evar _gEffectsMemoryPool (tptr (Tstruct _MemoryPool noattr))))
        (Ssequence
          (Sset _t'6 (Evar _gSnowParticleMaxCount tshort))
          (Scall (Some _t'1)
            (Evar _mem_pool_alloc (Tfunction
                                    ((tptr (Tstruct _MemoryPool noattr)) ::
                                     tuint :: nil) (tptr tvoid) cc_default))
            ((Etempvar _t'5 (tptr (Tstruct _MemoryPool noattr))) ::
             (Ebinop Omul (Etempvar _t'6 tshort)
               (Esizeof (Tstruct _EnvFxParticle noattr) tuint) tuint) :: nil))))
      (Sassign (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr)))
        (Etempvar _t'1 (tptr tvoid))))
    (Ssequence
      (Ssequence
        (Sset _t'4
          (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
        (Sifthenelse (Ebinop Oeq
                       (Etempvar _t'4 (tptr (Tstruct _EnvFxParticle noattr)))
                       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                       tint)
          (Sreturn (Some (Econst_int (Int.repr 0) tint)))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'2
            (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
          (Ssequence
            (Sset _t'3 (Evar _gSnowParticleMaxCount tshort))
            (Scall None
              (Evar _bzero (Tfunction ((tptr tvoid) :: tuint :: nil) tvoid
                             cc_default))
              ((Etempvar _t'2 (tptr (Tstruct _EnvFxParticle noattr))) ::
               (Ebinop Omul (Etempvar _t'3 tshort)
                 (Esizeof (Tstruct _EnvFxParticle noattr) tuint) tuint) ::
               nil))))
        (Ssequence
          (Sassign (Evar _gEnvFxMode tschar) (Etempvar _mode tint))
          (Sreturn (Some (Econst_int (Int.repr 1) tint))))))))
|}.

Definition f_envfx_update_snowflake_count := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_mode, tint) :: (_marioPos, (tptr tshort)) :: nil);
  fn_vars := nil;
  fn_temps := ((_globalTimer, tint) :: (_waterLevel, tfloat) ::
               (_t'1, tfloat) :: (_t'11, tshort) :: (_t'10, tshort) ::
               (_t'9, tshort) :: (_t'8, tshort) :: (_t'7, tshort) ::
               (_t'6, tshort) :: (_t'5, tshort) :: (_t'4, tshort) ::
               (_t'3, tshort) :: (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _globalTimer (Evar _gGlobalTimer tuint))
  (Sswitch (Etempvar _mode tint)
    (LScons (Some 1)
      (Ssequence
        (Ssequence
          (Sset _t'9 (Evar _gSnowParticleMaxCount tshort))
          (Ssequence
            (Sset _t'10 (Evar _gSnowParticleCount tshort))
            (Sifthenelse (Ebinop Ogt (Etempvar _t'9 tshort)
                           (Etempvar _t'10 tshort) tint)
              (Sifthenelse (Eunop Onotbool
                             (Ebinop Oand (Etempvar _globalTimer tint)
                               (Econst_int (Int.repr 63) tint) tint) tint)
                (Ssequence
                  (Sset _t'11 (Evar _gSnowParticleCount tshort))
                  (Sassign (Evar _gSnowParticleCount tshort)
                    (Ebinop Oadd (Etempvar _t'11 tshort)
                      (Econst_int (Int.repr 5) tint) tint)))
                Sskip)
              Sskip)))
        Sbreak)
      (LScons (Some 2)
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'7
                (Ederef
                  (Ebinop Oadd (Etempvar _marioPos (tptr tshort))
                    (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
              (Ssequence
                (Sset _t'8
                  (Ederef
                    (Ebinop Oadd (Etempvar _marioPos (tptr tshort))
                      (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort))
                (Scall (Some _t'1)
                  (Evar _find_water_level (Tfunction
                                            (tfloat :: tfloat :: nil) tfloat
                                            cc_default))
                  ((Etempvar _t'7 tshort) :: (Etempvar _t'8 tshort) :: nil))))
            (Sset _waterLevel (Etempvar _t'1 tfloat)))
          (Ssequence
            (Ssequence
              (Sset _t'6
                (Ederef
                  (Ebinop Oadd (Etempvar _marioPos (tptr tshort))
                    (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
              (Sassign (Evar _gSnowParticleCount tshort)
                (Ebinop Omul
                  (Ebinop Oshr
                    (Ebinop Oshl
                      (Ecast
                        (Ebinop Omul
                          (Ebinop Osub
                            (Ebinop Osub (Etempvar _waterLevel tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1137180672)) tfloat)
                              tfloat) (Ecast (Etempvar _t'6 tshort) tfloat)
                            tfloat)
                          (Econst_float (Float.of_bits (Int64.repr 4562254508917369340)) tdouble)
                          tdouble) tint) (Econst_int (Int.repr 16) tint)
                      tint) (Econst_int (Int.repr 16) tint) tint)
                  (Econst_int (Int.repr 5) tint) tint)))
            (Ssequence
              (Ssequence
                (Sset _t'5 (Evar _gSnowParticleCount tshort))
                (Sifthenelse (Ebinop Olt (Etempvar _t'5 tshort)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Sassign (Evar _gSnowParticleCount tshort)
                    (Econst_int (Int.repr 0) tint))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _t'2 (Evar _gSnowParticleCount tshort))
                  (Ssequence
                    (Sset _t'3 (Evar _gSnowParticleMaxCount tshort))
                    (Sifthenelse (Ebinop Ogt (Etempvar _t'2 tshort)
                                   (Etempvar _t'3 tshort) tint)
                      (Ssequence
                        (Sset _t'4 (Evar _gSnowParticleMaxCount tshort))
                        (Sassign (Evar _gSnowParticleCount tshort)
                          (Etempvar _t'4 tshort)))
                      Sskip)))
                Sbreak))))
        (LScons (Some 3) Sbreak LSnil)))))
|}.

Definition f_envfx_cleanup_snow := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_snowParticleArray, (tptr tvoid)) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, (tptr (Tstruct _MemoryPool noattr))) ::
               (_t'1, tschar) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _gEnvFxMode tschar))
  (Sifthenelse (Ebinop One (Etempvar _t'1 tschar)
                 (Econst_int (Int.repr 0) tint) tint)
    (Ssequence
      (Sifthenelse (Etempvar _snowParticleArray (tptr tvoid))
        (Ssequence
          (Sset _t'2
            (Evar _gEffectsMemoryPool (tptr (Tstruct _MemoryPool noattr))))
          (Scall None
            (Evar _mem_pool_free (Tfunction
                                   ((tptr (Tstruct _MemoryPool noattr)) ::
                                    (tptr tvoid) :: nil) tvoid cc_default))
            ((Etempvar _t'2 (tptr (Tstruct _MemoryPool noattr))) ::
             (Etempvar _snowParticleArray (tptr tvoid)) :: nil)))
        Sskip)
      (Sassign (Evar _gEnvFxMode tschar) (Econst_int (Int.repr 0) tint)))
    Sskip))
|}.

Definition f_orbit_from_positions := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_from, (tptr tshort)) :: (_to, (tptr tshort)) ::
                (_radius, (tptr tshort)) :: (_pitch, (tptr tshort)) ::
                (_yaw, (tptr tshort)) :: nil);
  fn_vars := nil;
  fn_temps := ((_dx, tfloat) :: (_dy, tfloat) :: (_dz, tfloat) ::
               (_t'4, tshort) :: (_t'3, tshort) :: (_t'2, tfloat) ::
               (_t'1, tfloat) :: (_t'10, tshort) :: (_t'9, tshort) ::
               (_t'8, tshort) :: (_t'7, tshort) :: (_t'6, tshort) ::
               (_t'5, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9
      (Ederef
        (Ebinop Oadd (Etempvar _to (tptr tshort))
          (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
    (Ssequence
      (Sset _t'10
        (Ederef
          (Ebinop Oadd (Etempvar _from (tptr tshort))
            (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
      (Sset _dx
        (Ecast
          (Ebinop Osub (Etempvar _t'9 tshort) (Etempvar _t'10 tshort) tint)
          tfloat))))
  (Ssequence
    (Ssequence
      (Sset _t'7
        (Ederef
          (Ebinop Oadd (Etempvar _to (tptr tshort))
            (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
      (Ssequence
        (Sset _t'8
          (Ederef
            (Ebinop Oadd (Etempvar _from (tptr tshort))
              (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
        (Sset _dy
          (Ecast
            (Ebinop Osub (Etempvar _t'7 tshort) (Etempvar _t'8 tshort) tint)
            tfloat))))
    (Ssequence
      (Ssequence
        (Sset _t'5
          (Ederef
            (Ebinop Oadd (Etempvar _to (tptr tshort))
              (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort))
        (Ssequence
          (Sset _t'6
            (Ederef
              (Ebinop Oadd (Etempvar _from (tptr tshort))
                (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort))
          (Sset _dz
            (Ecast
              (Ebinop Osub (Etempvar _t'5 tshort) (Etempvar _t'6 tshort)
                tint) tfloat))))
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _sqrtf (Tfunction (tfloat :: nil) tfloat cc_default))
            ((Ebinop Oadd
               (Ebinop Oadd
                 (Ebinop Omul (Etempvar _dx tfloat) (Etempvar _dx tfloat)
                   tfloat)
                 (Ebinop Omul (Etempvar _dy tfloat) (Etempvar _dy tfloat)
                   tfloat) tfloat)
               (Ebinop Omul (Etempvar _dz tfloat) (Etempvar _dz tfloat)
                 tfloat) tfloat) :: nil))
          (Sassign (Ederef (Etempvar _radius (tptr tshort)) tshort)
            (Ecast (Etempvar _t'1 tfloat) tshort)))
        (Ssequence
          (Ssequence
            (Ssequence
              (Scall (Some _t'2)
                (Evar _sqrtf (Tfunction (tfloat :: nil) tfloat cc_default))
                ((Ebinop Oadd
                   (Ebinop Omul (Etempvar _dx tfloat) (Etempvar _dx tfloat)
                     tfloat)
                   (Ebinop Omul (Etempvar _dz tfloat) (Etempvar _dz tfloat)
                     tfloat) tfloat) :: nil))
              (Scall (Some _t'3)
                (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil) tshort
                                cc_default))
                ((Etempvar _t'2 tfloat) :: (Etempvar _dy tfloat) :: nil)))
            (Sassign (Ederef (Etempvar _pitch (tptr tshort)) tshort)
              (Etempvar _t'3 tshort)))
          (Ssequence
            (Scall (Some _t'4)
              (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil) tshort
                              cc_default))
              ((Etempvar _dz tfloat) :: (Etempvar _dx tfloat) :: nil))
            (Sassign (Ederef (Etempvar _yaw (tptr tshort)) tshort)
              (Etempvar _t'4 tshort))))))))
|}.

Definition f_pos_from_orbit := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_origin, (tptr tshort)) :: (_result, (tptr tshort)) ::
                (_radius, tshort) :: (_pitch, tshort) :: (_yaw, tshort) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_t'8, tfloat) :: (_t'7, tfloat) :: (_t'6, tshort) ::
               (_t'5, tfloat) :: (_t'4, tshort) :: (_t'3, tfloat) ::
               (_t'2, tfloat) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6
      (Ederef
        (Ebinop Oadd (Etempvar _origin (tptr tshort))
          (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
    (Ssequence
      (Sset _t'7
        (Ederef
          (Ebinop Oadd
            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
              (Econst_int (Int.repr 1024) tint) (tptr tfloat))
            (Ebinop Oshr (Ecast (Etempvar _pitch tshort) tushort)
              (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
      (Ssequence
        (Sset _t'8
          (Ederef
            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
              (Ebinop Oshr (Ecast (Etempvar _yaw tshort) tushort)
                (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
        (Sassign
          (Ederef
            (Ebinop Oadd (Etempvar _result (tptr tshort))
              (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort)
          (Ebinop Oadd (Etempvar _t'6 tshort)
            (Ebinop Omul
              (Ebinop Omul (Etempvar _radius tshort) (Etempvar _t'7 tfloat)
                tfloat) (Etempvar _t'8 tfloat) tfloat) tfloat)))))
  (Ssequence
    (Ssequence
      (Sset _t'4
        (Ederef
          (Ebinop Oadd (Etempvar _origin (tptr tshort))
            (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
      (Ssequence
        (Sset _t'5
          (Ederef
            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
              (Ebinop Oshr (Ecast (Etempvar _pitch tshort) tushort)
                (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
        (Sassign
          (Ederef
            (Ebinop Oadd (Etempvar _result (tptr tshort))
              (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort)
          (Ebinop Oadd (Etempvar _t'4 tshort)
            (Ebinop Omul (Etempvar _radius tshort) (Etempvar _t'5 tfloat)
              tfloat) tfloat))))
    (Ssequence
      (Sset _t'1
        (Ederef
          (Ebinop Oadd (Etempvar _origin (tptr tshort))
            (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort))
      (Ssequence
        (Sset _t'2
          (Ederef
            (Ebinop Oadd
              (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                (Econst_int (Int.repr 1024) tint) (tptr tfloat))
              (Ebinop Oshr (Ecast (Etempvar _pitch tshort) tushort)
                (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
        (Ssequence
          (Sset _t'3
            (Ederef
              (Ebinop Oadd
                (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                  (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                (Ebinop Oshr (Ecast (Etempvar _yaw tshort) tushort)
                  (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
          (Sassign
            (Ederef
              (Ebinop Oadd (Etempvar _result (tptr tshort))
                (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort)
            (Ebinop Oadd (Etempvar _t'1 tshort)
              (Ebinop Omul
                (Ebinop Omul (Etempvar _radius tshort) (Etempvar _t'2 tfloat)
                  tfloat) (Etempvar _t'3 tfloat) tfloat) tfloat)))))))
|}.

Definition f_envfx_is_snowflake_alive := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_index, tint) :: (_snowCylinderX, tint) ::
                (_snowCylinderY, tint) :: (_snowCylinderZ, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_x, tint) :: (_y, tint) :: (_z, tint) :: (_t'1, tint) ::
               (_t'4, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'3, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'2, (tptr (Tstruct _EnvFxParticle noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
    (Sset _x
      (Efield
        (Ederef
          (Ebinop Oadd (Etempvar _t'4 (tptr (Tstruct _EnvFxParticle noattr)))
            (Etempvar _index tint) (tptr (Tstruct _EnvFxParticle noattr)))
          (Tstruct _EnvFxParticle noattr)) _xPos tint)))
  (Ssequence
    (Ssequence
      (Sset _t'3 (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
      (Sset _y
        (Efield
          (Ederef
            (Ebinop Oadd
              (Etempvar _t'3 (tptr (Tstruct _EnvFxParticle noattr)))
              (Etempvar _index tint) (tptr (Tstruct _EnvFxParticle noattr)))
            (Tstruct _EnvFxParticle noattr)) _yPos tint)))
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
        (Sset _z
          (Efield
            (Ederef
              (Ebinop Oadd
                (Etempvar _t'2 (tptr (Tstruct _EnvFxParticle noattr)))
                (Etempvar _index tint)
                (tptr (Tstruct _EnvFxParticle noattr)))
              (Tstruct _EnvFxParticle noattr)) _zPos tint)))
      (Ssequence
        (Sifthenelse (Ebinop Ogt
                       (Ebinop Oadd
                         (Ebinop Omul
                           (Ebinop Osub (Etempvar _x tint)
                             (Etempvar _snowCylinderX tint) tint)
                           (Ebinop Osub (Etempvar _x tint)
                             (Etempvar _snowCylinderX tint) tint) tint)
                         (Ebinop Omul
                           (Ebinop Osub (Etempvar _z tint)
                             (Etempvar _snowCylinderZ tint) tint)
                           (Ebinop Osub (Etempvar _z tint)
                             (Etempvar _snowCylinderZ tint) tint) tint) tint)
                       (Ebinop Omul (Econst_int (Int.repr 300) tint)
                         (Econst_int (Int.repr 300) tint) tint) tint)
          (Sreturn (Some (Econst_int (Int.repr 0) tint)))
          Sskip)
        (Ssequence
          (Ssequence
            (Sifthenelse (Ebinop Olt (Etempvar _y tint)
                           (Ebinop Osub (Etempvar _snowCylinderY tint)
                             (Econst_int (Int.repr 201) tint) tint) tint)
              (Sset _t'1 (Econst_int (Int.repr 1) tint))
              (Sset _t'1
                (Ecast
                  (Ebinop Olt
                    (Ebinop Oadd (Etempvar _snowCylinderY tint)
                      (Econst_int (Int.repr 201) tint) tint)
                    (Etempvar _y tint) tint) tbool)))
            (Sifthenelse (Etempvar _t'1 tint)
              (Sreturn (Some (Econst_int (Int.repr 0) tint)))
              Sskip))
          (Sreturn (Some (Econst_int (Int.repr 1) tint))))))))
|}.

Definition f_envfx_update_snow_normal := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_snowCylinderX, tint) :: (_snowCylinderY, tint) ::
                (_snowCylinderZ, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_deltaX, tint) :: (_deltaY, tint) ::
               (_deltaZ, tint) :: (_t'6, tfloat) :: (_t'5, tfloat) ::
               (_t'4, tfloat) :: (_t'3, tfloat) :: (_t'2, tfloat) ::
               (_t'1, tint) :: (_t'26, tint) :: (_t'25, tint) ::
               (_t'24, tint) :: (_t'23, tshort) ::
               (_t'22, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'21, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'20, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'19, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'18, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'17, tint) ::
               (_t'16, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'15, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'14, tint) ::
               (_t'13, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'12, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'11, tint) ::
               (_t'10, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'9, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'8, tschar) ::
               (_t'7, (tptr (Tstruct _EnvFxParticle noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'26
      (Ederef
        (Ebinop Oadd (Evar _gSnowCylinderLastPos (tarray tint 3))
          (Econst_int (Int.repr 0) tint) (tptr tint)) tint))
    (Sset _deltaX
      (Ebinop Osub (Etempvar _snowCylinderX tint) (Etempvar _t'26 tint) tint)))
  (Ssequence
    (Ssequence
      (Sset _t'25
        (Ederef
          (Ebinop Oadd (Evar _gSnowCylinderLastPos (tarray tint 3))
            (Econst_int (Int.repr 1) tint) (tptr tint)) tint))
      (Sset _deltaY
        (Ebinop Osub (Etempvar _snowCylinderY tint) (Etempvar _t'25 tint)
          tint)))
    (Ssequence
      (Ssequence
        (Sset _t'24
          (Ederef
            (Ebinop Oadd (Evar _gSnowCylinderLastPos (tarray tint 3))
              (Econst_int (Int.repr 2) tint) (tptr tint)) tint))
        (Sset _deltaZ
          (Ebinop Osub (Etempvar _snowCylinderZ tint) (Etempvar _t'24 tint)
            tint)))
      (Ssequence
        (Ssequence
          (Sset _i (Econst_int (Int.repr 0) tint))
          (Sloop
            (Ssequence
              (Ssequence
                (Sset _t'23 (Evar _gSnowParticleCount tshort))
                (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                               (Etempvar _t'23 tshort) tint)
                  Sskip
                  Sbreak))
              (Ssequence
                (Ssequence
                  (Scall (Some _t'1)
                    (Evar _envfx_is_snowflake_alive (Tfunction
                                                      (tint :: tint ::
                                                       tint :: tint :: nil)
                                                      tint cc_default))
                    ((Etempvar _i tint) :: (Etempvar _snowCylinderX tint) ::
                     (Etempvar _snowCylinderY tint) ::
                     (Etempvar _snowCylinderZ tint) :: nil))
                  (Ssequence
                    (Sset _t'22
                      (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                    (Sassign
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Etempvar _t'22 (tptr (Tstruct _EnvFxParticle noattr)))
                            (Etempvar _i tint)
                            (tptr (Tstruct _EnvFxParticle noattr)))
                          (Tstruct _EnvFxParticle noattr)) _isAlive tschar)
                      (Etempvar _t'1 tint))))
                (Ssequence
                  (Sset _t'7
                    (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                  (Ssequence
                    (Sset _t'8
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Etempvar _t'7 (tptr (Tstruct _EnvFxParticle noattr)))
                            (Etempvar _i tint)
                            (tptr (Tstruct _EnvFxParticle noattr)))
                          (Tstruct _EnvFxParticle noattr)) _isAlive tschar))
                    (Sifthenelse (Eunop Onotbool (Etempvar _t'8 tschar) tint)
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'2)
                            (Evar _random_float (Tfunction nil tfloat
                                                  cc_default)) nil)
                          (Ssequence
                            (Sset _t'21
                              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Ebinop Oadd
                                    (Etempvar _t'21 (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Etempvar _i tint)
                                    (tptr (Tstruct _EnvFxParticle noattr)))
                                  (Tstruct _EnvFxParticle noattr)) _xPos
                                tint)
                              (Ebinop Oadd
                                (Ebinop Oadd
                                  (Ebinop Osub
                                    (Ebinop Omul
                                      (Econst_single (Float32.of_bits (Int.repr 1137180672)) tfloat)
                                      (Etempvar _t'2 tfloat) tfloat)
                                    (Econst_single (Float32.of_bits (Int.repr 1128792064)) tfloat)
                                    tfloat) (Etempvar _snowCylinderX tint)
                                  tfloat)
                                (Ecast
                                  (Ebinop Omul (Etempvar _deltaX tint)
                                    (Econst_int (Int.repr 2) tint) tint)
                                  tshort) tfloat))))
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'3)
                              (Evar _random_float (Tfunction nil tfloat
                                                    cc_default)) nil)
                            (Ssequence
                              (Sset _t'20
                                (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'20 (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Etempvar _i tint)
                                      (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Tstruct _EnvFxParticle noattr)) _zPos
                                  tint)
                                (Ebinop Oadd
                                  (Ebinop Oadd
                                    (Ebinop Osub
                                      (Ebinop Omul
                                        (Econst_single (Float32.of_bits (Int.repr 1137180672)) tfloat)
                                        (Etempvar _t'3 tfloat) tfloat)
                                      (Econst_single (Float32.of_bits (Int.repr 1128792064)) tfloat)
                                      tfloat) (Etempvar _snowCylinderZ tint)
                                    tfloat)
                                  (Ecast
                                    (Ebinop Omul (Etempvar _deltaZ tint)
                                      (Econst_int (Int.repr 2) tint) tint)
                                    tshort) tfloat))))
                          (Ssequence
                            (Ssequence
                              (Scall (Some _t'4)
                                (Evar _random_float (Tfunction nil tfloat
                                                      cc_default)) nil)
                              (Ssequence
                                (Sset _t'19
                                  (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'19 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr)) _yPos
                                    tint)
                                  (Ebinop Oadd
                                    (Ebinop Omul
                                      (Econst_single (Float32.of_bits (Int.repr 1128792064)) tfloat)
                                      (Etempvar _t'4 tfloat) tfloat)
                                    (Etempvar _snowCylinderY tint) tfloat))))
                            (Ssequence
                              (Sset _t'18
                                (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'18 (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Etempvar _i tint)
                                      (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Tstruct _EnvFxParticle noattr)) _isAlive
                                  tschar) (Econst_int (Int.repr 1) tint))))))
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'5)
                            (Evar _random_float (Tfunction nil tfloat
                                                  cc_default)) nil)
                          (Ssequence
                            (Sset _t'15
                              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                            (Ssequence
                              (Sset _t'16
                                (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                              (Ssequence
                                (Sset _t'17
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'16 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr)) _xPos
                                    tint))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'15 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr)) _xPos
                                    tint)
                                  (Ebinop Oadd (Etempvar _t'17 tint)
                                    (Ebinop Oadd
                                      (Ebinop Osub
                                        (Ebinop Omul (Etempvar _t'5 tfloat)
                                          (Econst_int (Int.repr 2) tint)
                                          tfloat)
                                        (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                                        tfloat)
                                      (Ecast
                                        (Ebinop Odiv (Etempvar _deltaX tint)
                                          (Econst_float (Float.of_bits (Int64.repr 4608083138725491507)) tdouble)
                                          tdouble) tshort) tfloat) tfloat))))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'12
                              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                            (Ssequence
                              (Sset _t'13
                                (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                              (Ssequence
                                (Sset _t'14
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'13 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr)) _yPos
                                    tint))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'12 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr)) _yPos
                                    tint)
                                  (Ebinop Osub (Etempvar _t'14 tint)
                                    (Ebinop Osub
                                      (Econst_int (Int.repr 2) tint)
                                      (Ecast
                                        (Ebinop Omul (Etempvar _deltaY tint)
                                          (Econst_float (Float.of_bits (Int64.repr 4605380978949069210)) tdouble)
                                          tdouble) tshort) tint) tint)))))
                          (Ssequence
                            (Scall (Some _t'6)
                              (Evar _random_float (Tfunction nil tfloat
                                                    cc_default)) nil)
                            (Ssequence
                              (Sset _t'9
                                (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                              (Ssequence
                                (Sset _t'10
                                  (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                (Ssequence
                                  (Sset _t'11
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Etempvar _t'10 (tptr (Tstruct _EnvFxParticle noattr)))
                                          (Etempvar _i tint)
                                          (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Tstruct _EnvFxParticle noattr))
                                      _zPos tint))
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Etempvar _t'9 (tptr (Tstruct _EnvFxParticle noattr)))
                                          (Etempvar _i tint)
                                          (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Tstruct _EnvFxParticle noattr))
                                      _zPos tint)
                                    (Ebinop Oadd (Etempvar _t'11 tint)
                                      (Ebinop Oadd
                                        (Ebinop Osub
                                          (Ebinop Omul (Etempvar _t'6 tfloat)
                                            (Econst_int (Int.repr 2) tint)
                                            tfloat)
                                          (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                                          tfloat)
                                        (Ecast
                                          (Ebinop Odiv
                                            (Etempvar _deltaZ tint)
                                            (Econst_float (Float.of_bits (Int64.repr 4608083138725491507)) tdouble)
                                            tdouble) tshort) tfloat) tfloat)))))))))))))
            (Sset _i
              (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint)
                tint))))
        (Ssequence
          (Sassign
            (Ederef
              (Ebinop Oadd (Evar _gSnowCylinderLastPos (tarray tint 3))
                (Econst_int (Int.repr 0) tint) (tptr tint)) tint)
            (Etempvar _snowCylinderX tint))
          (Ssequence
            (Sassign
              (Ederef
                (Ebinop Oadd (Evar _gSnowCylinderLastPos (tarray tint 3))
                  (Econst_int (Int.repr 1) tint) (tptr tint)) tint)
              (Etempvar _snowCylinderY tint))
            (Sassign
              (Ederef
                (Ebinop Oadd (Evar _gSnowCylinderLastPos (tarray tint 3))
                  (Econst_int (Int.repr 2) tint) (tptr tint)) tint)
              (Etempvar _snowCylinderZ tint))))))))
|}.

Definition f_envfx_update_snow_blizzard := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_snowCylinderX, tint) :: (_snowCylinderY, tint) ::
                (_snowCylinderZ, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_deltaX, tint) :: (_deltaY, tint) ::
               (_deltaZ, tint) :: (_t'6, tfloat) :: (_t'5, tfloat) ::
               (_t'4, tfloat) :: (_t'3, tfloat) :: (_t'2, tfloat) ::
               (_t'1, tint) :: (_t'26, tint) :: (_t'25, tint) ::
               (_t'24, tint) :: (_t'23, tshort) ::
               (_t'22, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'21, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'20, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'19, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'18, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'17, tint) ::
               (_t'16, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'15, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'14, tint) ::
               (_t'13, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'12, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'11, tint) ::
               (_t'10, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'9, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'8, tschar) ::
               (_t'7, (tptr (Tstruct _EnvFxParticle noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'26
      (Ederef
        (Ebinop Oadd (Evar _gSnowCylinderLastPos (tarray tint 3))
          (Econst_int (Int.repr 0) tint) (tptr tint)) tint))
    (Sset _deltaX
      (Ebinop Osub (Etempvar _snowCylinderX tint) (Etempvar _t'26 tint) tint)))
  (Ssequence
    (Ssequence
      (Sset _t'25
        (Ederef
          (Ebinop Oadd (Evar _gSnowCylinderLastPos (tarray tint 3))
            (Econst_int (Int.repr 1) tint) (tptr tint)) tint))
      (Sset _deltaY
        (Ebinop Osub (Etempvar _snowCylinderY tint) (Etempvar _t'25 tint)
          tint)))
    (Ssequence
      (Ssequence
        (Sset _t'24
          (Ederef
            (Ebinop Oadd (Evar _gSnowCylinderLastPos (tarray tint 3))
              (Econst_int (Int.repr 2) tint) (tptr tint)) tint))
        (Sset _deltaZ
          (Ebinop Osub (Etempvar _snowCylinderZ tint) (Etempvar _t'24 tint)
            tint)))
      (Ssequence
        (Ssequence
          (Sset _i (Econst_int (Int.repr 0) tint))
          (Sloop
            (Ssequence
              (Ssequence
                (Sset _t'23 (Evar _gSnowParticleCount tshort))
                (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                               (Etempvar _t'23 tshort) tint)
                  Sskip
                  Sbreak))
              (Ssequence
                (Ssequence
                  (Scall (Some _t'1)
                    (Evar _envfx_is_snowflake_alive (Tfunction
                                                      (tint :: tint ::
                                                       tint :: tint :: nil)
                                                      tint cc_default))
                    ((Etempvar _i tint) :: (Etempvar _snowCylinderX tint) ::
                     (Etempvar _snowCylinderY tint) ::
                     (Etempvar _snowCylinderZ tint) :: nil))
                  (Ssequence
                    (Sset _t'22
                      (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                    (Sassign
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Etempvar _t'22 (tptr (Tstruct _EnvFxParticle noattr)))
                            (Etempvar _i tint)
                            (tptr (Tstruct _EnvFxParticle noattr)))
                          (Tstruct _EnvFxParticle noattr)) _isAlive tschar)
                      (Etempvar _t'1 tint))))
                (Ssequence
                  (Sset _t'7
                    (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                  (Ssequence
                    (Sset _t'8
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Etempvar _t'7 (tptr (Tstruct _EnvFxParticle noattr)))
                            (Etempvar _i tint)
                            (tptr (Tstruct _EnvFxParticle noattr)))
                          (Tstruct _EnvFxParticle noattr)) _isAlive tschar))
                    (Sifthenelse (Eunop Onotbool (Etempvar _t'8 tschar) tint)
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'2)
                            (Evar _random_float (Tfunction nil tfloat
                                                  cc_default)) nil)
                          (Ssequence
                            (Sset _t'21
                              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Ebinop Oadd
                                    (Etempvar _t'21 (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Etempvar _i tint)
                                    (tptr (Tstruct _EnvFxParticle noattr)))
                                  (Tstruct _EnvFxParticle noattr)) _xPos
                                tint)
                              (Ebinop Oadd
                                (Ebinop Oadd
                                  (Ebinop Osub
                                    (Ebinop Omul
                                      (Econst_single (Float32.of_bits (Int.repr 1137180672)) tfloat)
                                      (Etempvar _t'2 tfloat) tfloat)
                                    (Econst_single (Float32.of_bits (Int.repr 1128792064)) tfloat)
                                    tfloat) (Etempvar _snowCylinderX tint)
                                  tfloat)
                                (Ecast
                                  (Ebinop Omul (Etempvar _deltaX tint)
                                    (Econst_int (Int.repr 2) tint) tint)
                                  tshort) tfloat))))
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'3)
                              (Evar _random_float (Tfunction nil tfloat
                                                    cc_default)) nil)
                            (Ssequence
                              (Sset _t'20
                                (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'20 (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Etempvar _i tint)
                                      (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Tstruct _EnvFxParticle noattr)) _zPos
                                  tint)
                                (Ebinop Oadd
                                  (Ebinop Oadd
                                    (Ebinop Osub
                                      (Ebinop Omul
                                        (Econst_single (Float32.of_bits (Int.repr 1137180672)) tfloat)
                                        (Etempvar _t'3 tfloat) tfloat)
                                      (Econst_single (Float32.of_bits (Int.repr 1128792064)) tfloat)
                                      tfloat) (Etempvar _snowCylinderZ tint)
                                    tfloat)
                                  (Ecast
                                    (Ebinop Omul (Etempvar _deltaZ tint)
                                      (Econst_int (Int.repr 2) tint) tint)
                                    tshort) tfloat))))
                          (Ssequence
                            (Ssequence
                              (Scall (Some _t'4)
                                (Evar _random_float (Tfunction nil tfloat
                                                      cc_default)) nil)
                              (Ssequence
                                (Sset _t'19
                                  (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'19 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr)) _yPos
                                    tint)
                                  (Ebinop Oadd
                                    (Ebinop Osub
                                      (Ebinop Omul
                                        (Econst_single (Float32.of_bits (Int.repr 1137180672)) tfloat)
                                        (Etempvar _t'4 tfloat) tfloat)
                                      (Econst_single (Float32.of_bits (Int.repr 1128792064)) tfloat)
                                      tfloat) (Etempvar _snowCylinderY tint)
                                    tfloat))))
                            (Ssequence
                              (Sset _t'18
                                (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'18 (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Etempvar _i tint)
                                      (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Tstruct _EnvFxParticle noattr)) _isAlive
                                  tschar) (Econst_int (Int.repr 1) tint))))))
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'5)
                            (Evar _random_float (Tfunction nil tfloat
                                                  cc_default)) nil)
                          (Ssequence
                            (Sset _t'15
                              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                            (Ssequence
                              (Sset _t'16
                                (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                              (Ssequence
                                (Sset _t'17
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'16 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr)) _xPos
                                    tint))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'15 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr)) _xPos
                                    tint)
                                  (Ebinop Oadd (Etempvar _t'17 tint)
                                    (Ebinop Oadd
                                      (Ebinop Oadd
                                        (Ebinop Osub
                                          (Ebinop Omul (Etempvar _t'5 tfloat)
                                            (Econst_int (Int.repr 2) tint)
                                            tfloat)
                                          (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                                          tfloat)
                                        (Ecast
                                          (Ebinop Odiv
                                            (Etempvar _deltaX tint)
                                            (Econst_float (Float.of_bits (Int64.repr 4608083138725491507)) tdouble)
                                            tdouble) tshort) tfloat)
                                      (Econst_single (Float32.of_bits (Int.repr 1101004800)) tfloat)
                                      tfloat) tfloat))))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'12
                              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                            (Ssequence
                              (Sset _t'13
                                (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                              (Ssequence
                                (Sset _t'14
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'13 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr)) _yPos
                                    tint))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'12 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr)) _yPos
                                    tint)
                                  (Ebinop Osub (Etempvar _t'14 tint)
                                    (Ebinop Osub
                                      (Econst_int (Int.repr 5) tint)
                                      (Ecast
                                        (Ebinop Omul (Etempvar _deltaY tint)
                                          (Econst_float (Float.of_bits (Int64.repr 4605380978949069210)) tdouble)
                                          tdouble) tshort) tint) tint)))))
                          (Ssequence
                            (Scall (Some _t'6)
                              (Evar _random_float (Tfunction nil tfloat
                                                    cc_default)) nil)
                            (Ssequence
                              (Sset _t'9
                                (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                              (Ssequence
                                (Sset _t'10
                                  (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                (Ssequence
                                  (Sset _t'11
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Etempvar _t'10 (tptr (Tstruct _EnvFxParticle noattr)))
                                          (Etempvar _i tint)
                                          (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Tstruct _EnvFxParticle noattr))
                                      _zPos tint))
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Etempvar _t'9 (tptr (Tstruct _EnvFxParticle noattr)))
                                          (Etempvar _i tint)
                                          (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Tstruct _EnvFxParticle noattr))
                                      _zPos tint)
                                    (Ebinop Oadd (Etempvar _t'11 tint)
                                      (Ebinop Oadd
                                        (Ebinop Osub
                                          (Ebinop Omul (Etempvar _t'6 tfloat)
                                            (Econst_int (Int.repr 2) tint)
                                            tfloat)
                                          (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                                          tfloat)
                                        (Ecast
                                          (Ebinop Odiv
                                            (Etempvar _deltaZ tint)
                                            (Econst_float (Float.of_bits (Int64.repr 4608083138725491507)) tdouble)
                                            tdouble) tshort) tfloat) tfloat)))))))))))))
            (Sset _i
              (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint)
                tint))))
        (Ssequence
          (Sassign
            (Ederef
              (Ebinop Oadd (Evar _gSnowCylinderLastPos (tarray tint 3))
                (Econst_int (Int.repr 0) tint) (tptr tint)) tint)
            (Etempvar _snowCylinderX tint))
          (Ssequence
            (Sassign
              (Ederef
                (Ebinop Oadd (Evar _gSnowCylinderLastPos (tarray tint 3))
                  (Econst_int (Int.repr 1) tint) (tptr tint)) tint)
              (Etempvar _snowCylinderY tint))
            (Sassign
              (Ederef
                (Ebinop Oadd (Evar _gSnowCylinderLastPos (tarray tint 3))
                  (Econst_int (Int.repr 2) tint) (tptr tint)) tint)
              (Etempvar _snowCylinderZ tint))))))))
|}.

Definition f_envfx_update_snow_water := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_snowCylinderX, tint) :: (_snowCylinderY, tint) ::
                (_snowCylinderZ, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_t'4, tfloat) :: (_t'3, tfloat) ::
               (_t'2, tfloat) :: (_t'1, tint) :: (_t'12, tshort) ::
               (_t'11, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'10, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'9, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'8, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'7, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'6, tschar) ::
               (_t'5, (tptr (Tstruct _EnvFxParticle noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _i (Econst_int (Int.repr 0) tint))
  (Sloop
    (Ssequence
      (Ssequence
        (Sset _t'12 (Evar _gSnowParticleCount tshort))
        (Sifthenelse (Ebinop Olt (Etempvar _i tint) (Etempvar _t'12 tshort)
                       tint)
          Sskip
          Sbreak))
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _envfx_is_snowflake_alive (Tfunction
                                              (tint :: tint :: tint ::
                                               tint :: nil) tint cc_default))
            ((Etempvar _i tint) :: (Etempvar _snowCylinderX tint) ::
             (Etempvar _snowCylinderY tint) ::
             (Etempvar _snowCylinderZ tint) :: nil))
          (Ssequence
            (Sset _t'11
              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
            (Sassign
              (Efield
                (Ederef
                  (Ebinop Oadd
                    (Etempvar _t'11 (tptr (Tstruct _EnvFxParticle noattr)))
                    (Etempvar _i tint)
                    (tptr (Tstruct _EnvFxParticle noattr)))
                  (Tstruct _EnvFxParticle noattr)) _isAlive tschar)
              (Etempvar _t'1 tint))))
        (Ssequence
          (Sset _t'5
            (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
          (Ssequence
            (Sset _t'6
              (Efield
                (Ederef
                  (Ebinop Oadd
                    (Etempvar _t'5 (tptr (Tstruct _EnvFxParticle noattr)))
                    (Etempvar _i tint)
                    (tptr (Tstruct _EnvFxParticle noattr)))
                  (Tstruct _EnvFxParticle noattr)) _isAlive tschar))
            (Sifthenelse (Eunop Onotbool (Etempvar _t'6 tschar) tint)
              (Ssequence
                (Ssequence
                  (Scall (Some _t'2)
                    (Evar _random_float (Tfunction nil tfloat cc_default))
                    nil)
                  (Ssequence
                    (Sset _t'10
                      (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                    (Sassign
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Etempvar _t'10 (tptr (Tstruct _EnvFxParticle noattr)))
                            (Etempvar _i tint)
                            (tptr (Tstruct _EnvFxParticle noattr)))
                          (Tstruct _EnvFxParticle noattr)) _xPos tint)
                      (Ebinop Oadd
                        (Ebinop Osub
                          (Ebinop Omul
                            (Econst_single (Float32.of_bits (Int.repr 1137180672)) tfloat)
                            (Etempvar _t'2 tfloat) tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1128792064)) tfloat)
                          tfloat) (Etempvar _snowCylinderX tint) tfloat))))
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'3)
                      (Evar _random_float (Tfunction nil tfloat cc_default))
                      nil)
                    (Ssequence
                      (Sset _t'9
                        (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                      (Sassign
                        (Efield
                          (Ederef
                            (Ebinop Oadd
                              (Etempvar _t'9 (tptr (Tstruct _EnvFxParticle noattr)))
                              (Etempvar _i tint)
                              (tptr (Tstruct _EnvFxParticle noattr)))
                            (Tstruct _EnvFxParticle noattr)) _zPos tint)
                        (Ebinop Oadd
                          (Ebinop Osub
                            (Ebinop Omul
                              (Econst_single (Float32.of_bits (Int.repr 1137180672)) tfloat)
                              (Etempvar _t'3 tfloat) tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1128792064)) tfloat)
                            tfloat) (Etempvar _snowCylinderZ tint) tfloat))))
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'4)
                        (Evar _random_float (Tfunction nil tfloat cc_default))
                        nil)
                      (Ssequence
                        (Sset _t'8
                          (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                        (Sassign
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Etempvar _t'8 (tptr (Tstruct _EnvFxParticle noattr)))
                                (Etempvar _i tint)
                                (tptr (Tstruct _EnvFxParticle noattr)))
                              (Tstruct _EnvFxParticle noattr)) _yPos tint)
                          (Ebinop Oadd
                            (Ebinop Osub
                              (Ebinop Omul
                                (Econst_single (Float32.of_bits (Int.repr 1137180672)) tfloat)
                                (Etempvar _t'4 tfloat) tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1128792064)) tfloat)
                              tfloat) (Etempvar _snowCylinderY tint) tfloat))))
                    (Ssequence
                      (Sset _t'7
                        (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                      (Sassign
                        (Efield
                          (Ederef
                            (Ebinop Oadd
                              (Etempvar _t'7 (tptr (Tstruct _EnvFxParticle noattr)))
                              (Etempvar _i tint)
                              (tptr (Tstruct _EnvFxParticle noattr)))
                            (Tstruct _EnvFxParticle noattr)) _isAlive tschar)
                        (Econst_int (Int.repr 1) tint))))))
              Sskip)))))
    (Sset _i
      (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint) tint))))
|}.

Definition f_rotate_triangle_vertices := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_vertex1, (tptr tshort)) :: (_vertex2, (tptr tshort)) ::
                (_vertex3, (tptr tshort)) :: (_pitch, tshort) ::
                (_yaw, tshort) :: nil);
  fn_vars := ((_v1, (tarray tfloat 3)) :: (_v2, (tarray tfloat 3)) ::
              (_v3, (tarray tfloat 3)) :: nil);
  fn_temps := ((_cosPitch, tfloat) :: (_sinPitch, tfloat) ::
               (_cosMYaw, tfloat) :: (_sinMYaw, tfloat) :: (_t'33, tshort) ::
               (_t'32, tshort) :: (_t'31, tshort) :: (_t'30, tshort) ::
               (_t'29, tshort) :: (_t'28, tshort) :: (_t'27, tshort) ::
               (_t'26, tshort) :: (_t'25, tshort) :: (_t'24, tfloat) ::
               (_t'23, tfloat) :: (_t'22, tfloat) :: (_t'21, tfloat) ::
               (_t'20, tfloat) :: (_t'19, tfloat) :: (_t'18, tfloat) ::
               (_t'17, tfloat) :: (_t'16, tfloat) :: (_t'15, tfloat) ::
               (_t'14, tfloat) :: (_t'13, tfloat) :: (_t'12, tfloat) ::
               (_t'11, tfloat) :: (_t'10, tfloat) :: (_t'9, tfloat) ::
               (_t'8, tfloat) :: (_t'7, tfloat) :: (_t'6, tfloat) ::
               (_t'5, tfloat) :: (_t'4, tfloat) :: (_t'3, tfloat) ::
               (_t'2, tfloat) :: (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _cosPitch
    (Ederef
      (Ebinop Oadd
        (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
          (Econst_int (Int.repr 1024) tint) (tptr tfloat))
        (Ebinop Oshr (Ecast (Etempvar _pitch tshort) tushort)
          (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
  (Ssequence
    (Sset _sinPitch
      (Ederef
        (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
          (Ebinop Oshr (Ecast (Etempvar _pitch tshort) tushort)
            (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
    (Ssequence
      (Sset _cosMYaw
        (Ederef
          (Ebinop Oadd
            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
              (Econst_int (Int.repr 1024) tint) (tptr tfloat))
            (Ebinop Oshr
              (Ecast (Eunop Oneg (Etempvar _yaw tshort) tint) tushort)
              (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
      (Ssequence
        (Sset _sinMYaw
          (Ederef
            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
              (Ebinop Oshr
                (Ecast (Eunop Oneg (Etempvar _yaw tshort) tint) tushort)
                (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
        (Ssequence
          (Ssequence
            (Sset _t'33
              (Ederef
                (Ebinop Oadd (Etempvar _vertex1 (tptr tshort))
                  (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
            (Sassign
              (Ederef
                (Ebinop Oadd (Evar _v1 (tarray tfloat 3))
                  (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
              (Etempvar _t'33 tshort)))
          (Ssequence
            (Ssequence
              (Sset _t'32
                (Ederef
                  (Ebinop Oadd (Etempvar _vertex1 (tptr tshort))
                    (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
              (Sassign
                (Ederef
                  (Ebinop Oadd (Evar _v1 (tarray tfloat 3))
                    (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
                (Etempvar _t'32 tshort)))
            (Ssequence
              (Ssequence
                (Sset _t'31
                  (Ederef
                    (Ebinop Oadd (Etempvar _vertex1 (tptr tshort))
                      (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort))
                (Sassign
                  (Ederef
                    (Ebinop Oadd (Evar _v1 (tarray tfloat 3))
                      (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat)
                  (Etempvar _t'31 tshort)))
              (Ssequence
                (Ssequence
                  (Sset _t'30
                    (Ederef
                      (Ebinop Oadd (Etempvar _vertex2 (tptr tshort))
                        (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd (Evar _v2 (tarray tfloat 3))
                        (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
                    (Etempvar _t'30 tshort)))
                (Ssequence
                  (Ssequence
                    (Sset _t'29
                      (Ederef
                        (Ebinop Oadd (Etempvar _vertex2 (tptr tshort))
                          (Econst_int (Int.repr 1) tint) (tptr tshort))
                        tshort))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd (Evar _v2 (tarray tfloat 3))
                          (Econst_int (Int.repr 1) tint) (tptr tfloat))
                        tfloat) (Etempvar _t'29 tshort)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'28
                        (Ederef
                          (Ebinop Oadd (Etempvar _vertex2 (tptr tshort))
                            (Econst_int (Int.repr 2) tint) (tptr tshort))
                          tshort))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd (Evar _v2 (tarray tfloat 3))
                            (Econst_int (Int.repr 2) tint) (tptr tfloat))
                          tfloat) (Etempvar _t'28 tshort)))
                    (Ssequence
                      (Ssequence
                        (Sset _t'27
                          (Ederef
                            (Ebinop Oadd (Etempvar _vertex3 (tptr tshort))
                              (Econst_int (Int.repr 0) tint) (tptr tshort))
                            tshort))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd (Evar _v3 (tarray tfloat 3))
                              (Econst_int (Int.repr 0) tint) (tptr tfloat))
                            tfloat) (Etempvar _t'27 tshort)))
                      (Ssequence
                        (Ssequence
                          (Sset _t'26
                            (Ederef
                              (Ebinop Oadd (Etempvar _vertex3 (tptr tshort))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))
                              tshort))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd (Evar _v3 (tarray tfloat 3))
                                (Econst_int (Int.repr 1) tint) (tptr tfloat))
                              tfloat) (Etempvar _t'26 tshort)))
                        (Ssequence
                          (Ssequence
                            (Sset _t'25
                              (Ederef
                                (Ebinop Oadd
                                  (Etempvar _vertex3 (tptr tshort))
                                  (Econst_int (Int.repr 2) tint)
                                  (tptr tshort)) tshort))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd (Evar _v3 (tarray tfloat 3))
                                  (Econst_int (Int.repr 2) tint)
                                  (tptr tfloat)) tfloat)
                              (Etempvar _t'25 tshort)))
                          (Ssequence
                            (Ssequence
                              (Sset _t'22
                                (Ederef
                                  (Ebinop Oadd (Evar _v1 (tarray tfloat 3))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr tfloat)) tfloat))
                              (Ssequence
                                (Sset _t'23
                                  (Ederef
                                    (Ebinop Oadd (Evar _v1 (tarray tfloat 3))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr tfloat)) tfloat))
                                (Ssequence
                                  (Sset _t'24
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _v1 (tarray tfloat 3))
                                        (Econst_int (Int.repr 2) tint)
                                        (tptr tfloat)) tfloat))
                                  (Sassign
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _vertex1 (tptr tshort))
                                        (Econst_int (Int.repr 0) tint)
                                        (tptr tshort)) tshort)
                                    (Ebinop Oadd
                                      (Ebinop Oadd
                                        (Ebinop Omul (Etempvar _t'22 tfloat)
                                          (Etempvar _cosMYaw tfloat) tfloat)
                                        (Ebinop Omul (Etempvar _t'23 tfloat)
                                          (Ebinop Omul
                                            (Etempvar _sinPitch tfloat)
                                            (Etempvar _sinMYaw tfloat)
                                            tfloat) tfloat) tfloat)
                                      (Ebinop Omul (Etempvar _t'24 tfloat)
                                        (Ebinop Omul
                                          (Eunop Oneg
                                            (Etempvar _sinMYaw tfloat)
                                            tfloat)
                                          (Etempvar _cosPitch tfloat) tfloat)
                                        tfloat) tfloat)))))
                            (Ssequence
                              (Ssequence
                                (Sset _t'20
                                  (Ederef
                                    (Ebinop Oadd (Evar _v1 (tarray tfloat 3))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr tfloat)) tfloat))
                                (Ssequence
                                  (Sset _t'21
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _v1 (tarray tfloat 3))
                                        (Econst_int (Int.repr 2) tint)
                                        (tptr tfloat)) tfloat))
                                  (Sassign
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _vertex1 (tptr tshort))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr tshort)) tshort)
                                    (Ebinop Oadd
                                      (Ebinop Omul (Etempvar _t'20 tfloat)
                                        (Etempvar _cosPitch tfloat) tfloat)
                                      (Ebinop Omul (Etempvar _t'21 tfloat)
                                        (Etempvar _sinPitch tfloat) tfloat)
                                      tfloat))))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'17
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _v1 (tarray tfloat 3))
                                        (Econst_int (Int.repr 0) tint)
                                        (tptr tfloat)) tfloat))
                                  (Ssequence
                                    (Sset _t'18
                                      (Ederef
                                        (Ebinop Oadd
                                          (Evar _v1 (tarray tfloat 3))
                                          (Econst_int (Int.repr 1) tint)
                                          (tptr tfloat)) tfloat))
                                    (Ssequence
                                      (Sset _t'19
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _v1 (tarray tfloat 3))
                                            (Econst_int (Int.repr 2) tint)
                                            (tptr tfloat)) tfloat))
                                      (Sassign
                                        (Ederef
                                          (Ebinop Oadd
                                            (Etempvar _vertex1 (tptr tshort))
                                            (Econst_int (Int.repr 2) tint)
                                            (tptr tshort)) tshort)
                                        (Ebinop Oadd
                                          (Ebinop Oadd
                                            (Ebinop Omul
                                              (Etempvar _t'17 tfloat)
                                              (Etempvar _sinMYaw tfloat)
                                              tfloat)
                                            (Ebinop Omul
                                              (Etempvar _t'18 tfloat)
                                              (Ebinop Omul
                                                (Eunop Oneg
                                                  (Etempvar _sinPitch tfloat)
                                                  tfloat)
                                                (Etempvar _cosMYaw tfloat)
                                                tfloat) tfloat) tfloat)
                                          (Ebinop Omul
                                            (Etempvar _t'19 tfloat)
                                            (Ebinop Omul
                                              (Etempvar _cosPitch tfloat)
                                              (Etempvar _cosMYaw tfloat)
                                              tfloat) tfloat) tfloat)))))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'14
                                      (Ederef
                                        (Ebinop Oadd
                                          (Evar _v2 (tarray tfloat 3))
                                          (Econst_int (Int.repr 0) tint)
                                          (tptr tfloat)) tfloat))
                                    (Ssequence
                                      (Sset _t'15
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _v2 (tarray tfloat 3))
                                            (Econst_int (Int.repr 1) tint)
                                            (tptr tfloat)) tfloat))
                                      (Ssequence
                                        (Sset _t'16
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _v2 (tarray tfloat 3))
                                              (Econst_int (Int.repr 2) tint)
                                              (tptr tfloat)) tfloat))
                                        (Sassign
                                          (Ederef
                                            (Ebinop Oadd
                                              (Etempvar _vertex2 (tptr tshort))
                                              (Econst_int (Int.repr 0) tint)
                                              (tptr tshort)) tshort)
                                          (Ebinop Oadd
                                            (Ebinop Oadd
                                              (Ebinop Omul
                                                (Etempvar _t'14 tfloat)
                                                (Etempvar _cosMYaw tfloat)
                                                tfloat)
                                              (Ebinop Omul
                                                (Etempvar _t'15 tfloat)
                                                (Ebinop Omul
                                                  (Etempvar _sinPitch tfloat)
                                                  (Etempvar _sinMYaw tfloat)
                                                  tfloat) tfloat) tfloat)
                                            (Ebinop Omul
                                              (Etempvar _t'16 tfloat)
                                              (Ebinop Omul
                                                (Eunop Oneg
                                                  (Etempvar _sinMYaw tfloat)
                                                  tfloat)
                                                (Etempvar _cosPitch tfloat)
                                                tfloat) tfloat) tfloat)))))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'12
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _v2 (tarray tfloat 3))
                                            (Econst_int (Int.repr 1) tint)
                                            (tptr tfloat)) tfloat))
                                      (Ssequence
                                        (Sset _t'13
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _v2 (tarray tfloat 3))
                                              (Econst_int (Int.repr 2) tint)
                                              (tptr tfloat)) tfloat))
                                        (Sassign
                                          (Ederef
                                            (Ebinop Oadd
                                              (Etempvar _vertex2 (tptr tshort))
                                              (Econst_int (Int.repr 1) tint)
                                              (tptr tshort)) tshort)
                                          (Ebinop Oadd
                                            (Ebinop Omul
                                              (Etempvar _t'12 tfloat)
                                              (Etempvar _cosPitch tfloat)
                                              tfloat)
                                            (Ebinop Omul
                                              (Etempvar _t'13 tfloat)
                                              (Etempvar _sinPitch tfloat)
                                              tfloat) tfloat))))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'9
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _v2 (tarray tfloat 3))
                                              (Econst_int (Int.repr 0) tint)
                                              (tptr tfloat)) tfloat))
                                        (Ssequence
                                          (Sset _t'10
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _v2 (tarray tfloat 3))
                                                (Econst_int (Int.repr 1) tint)
                                                (tptr tfloat)) tfloat))
                                          (Ssequence
                                            (Sset _t'11
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _v2 (tarray tfloat 3))
                                                  (Econst_int (Int.repr 2) tint)
                                                  (tptr tfloat)) tfloat))
                                            (Sassign
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Etempvar _vertex2 (tptr tshort))
                                                  (Econst_int (Int.repr 2) tint)
                                                  (tptr tshort)) tshort)
                                              (Ebinop Oadd
                                                (Ebinop Oadd
                                                  (Ebinop Omul
                                                    (Etempvar _t'9 tfloat)
                                                    (Etempvar _sinMYaw tfloat)
                                                    tfloat)
                                                  (Ebinop Omul
                                                    (Etempvar _t'10 tfloat)
                                                    (Ebinop Omul
                                                      (Eunop Oneg
                                                        (Etempvar _sinPitch tfloat)
                                                        tfloat)
                                                      (Etempvar _cosMYaw tfloat)
                                                      tfloat) tfloat) tfloat)
                                                (Ebinop Omul
                                                  (Etempvar _t'11 tfloat)
                                                  (Ebinop Omul
                                                    (Etempvar _cosPitch tfloat)
                                                    (Etempvar _cosMYaw tfloat)
                                                    tfloat) tfloat) tfloat)))))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'6
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _v3 (tarray tfloat 3))
                                                (Econst_int (Int.repr 0) tint)
                                                (tptr tfloat)) tfloat))
                                          (Ssequence
                                            (Sset _t'7
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _v3 (tarray tfloat 3))
                                                  (Econst_int (Int.repr 1) tint)
                                                  (tptr tfloat)) tfloat))
                                            (Ssequence
                                              (Sset _t'8
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Evar _v3 (tarray tfloat 3))
                                                    (Econst_int (Int.repr 2) tint)
                                                    (tptr tfloat)) tfloat))
                                              (Sassign
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Etempvar _vertex3 (tptr tshort))
                                                    (Econst_int (Int.repr 0) tint)
                                                    (tptr tshort)) tshort)
                                                (Ebinop Oadd
                                                  (Ebinop Oadd
                                                    (Ebinop Omul
                                                      (Etempvar _t'6 tfloat)
                                                      (Etempvar _cosMYaw tfloat)
                                                      tfloat)
                                                    (Ebinop Omul
                                                      (Etempvar _t'7 tfloat)
                                                      (Ebinop Omul
                                                        (Etempvar _sinPitch tfloat)
                                                        (Etempvar _sinMYaw tfloat)
                                                        tfloat) tfloat)
                                                    tfloat)
                                                  (Ebinop Omul
                                                    (Etempvar _t'8 tfloat)
                                                    (Ebinop Omul
                                                      (Eunop Oneg
                                                        (Etempvar _sinMYaw tfloat)
                                                        tfloat)
                                                      (Etempvar _cosPitch tfloat)
                                                      tfloat) tfloat) tfloat)))))
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'4
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _v3 (tarray tfloat 3))
                                                  (Econst_int (Int.repr 1) tint)
                                                  (tptr tfloat)) tfloat))
                                            (Ssequence
                                              (Sset _t'5
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Evar _v3 (tarray tfloat 3))
                                                    (Econst_int (Int.repr 2) tint)
                                                    (tptr tfloat)) tfloat))
                                              (Sassign
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Etempvar _vertex3 (tptr tshort))
                                                    (Econst_int (Int.repr 1) tint)
                                                    (tptr tshort)) tshort)
                                                (Ebinop Oadd
                                                  (Ebinop Omul
                                                    (Etempvar _t'4 tfloat)
                                                    (Etempvar _cosPitch tfloat)
                                                    tfloat)
                                                  (Ebinop Omul
                                                    (Etempvar _t'5 tfloat)
                                                    (Etempvar _sinPitch tfloat)
                                                    tfloat) tfloat))))
                                          (Ssequence
                                            (Sset _t'1
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _v3 (tarray tfloat 3))
                                                  (Econst_int (Int.repr 0) tint)
                                                  (tptr tfloat)) tfloat))
                                            (Ssequence
                                              (Sset _t'2
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Evar _v3 (tarray tfloat 3))
                                                    (Econst_int (Int.repr 1) tint)
                                                    (tptr tfloat)) tfloat))
                                              (Ssequence
                                                (Sset _t'3
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Evar _v3 (tarray tfloat 3))
                                                      (Econst_int (Int.repr 2) tint)
                                                      (tptr tfloat)) tfloat))
                                                (Sassign
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Etempvar _vertex3 (tptr tshort))
                                                      (Econst_int (Int.repr 2) tint)
                                                      (tptr tshort)) tshort)
                                                  (Ebinop Oadd
                                                    (Ebinop Oadd
                                                      (Ebinop Omul
                                                        (Etempvar _t'1 tfloat)
                                                        (Etempvar _sinMYaw tfloat)
                                                        tfloat)
                                                      (Ebinop Omul
                                                        (Etempvar _t'2 tfloat)
                                                        (Ebinop Omul
                                                          (Eunop Oneg
                                                            (Etempvar _sinPitch tfloat)
                                                            tfloat)
                                                          (Etempvar _cosMYaw tfloat)
                                                          tfloat) tfloat)
                                                      tfloat)
                                                    (Ebinop Omul
                                                      (Etempvar _t'3 tfloat)
                                                      (Ebinop Omul
                                                        (Etempvar _cosPitch tfloat)
                                                        (Etempvar _cosMYaw tfloat)
                                                        tfloat) tfloat)
                                                    tfloat))))))))))))))))))))))))))
|}.

Definition f_append_snowflake_vertex_buffer := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_gfx, (tptr (Tunion __512 noattr))) :: (_index, tint) ::
                (_vertex1, (tptr tshort)) :: (_vertex2, (tptr tshort)) ::
                (_vertex3, (tptr tshort)) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_vertBuf, (tptr (Tunion __463 noattr))) ::
               (__g, (tptr (Tunion __512 noattr))) :: (_t'1, (tptr tvoid)) ::
               (_t'28, tshort) :: (_t'27, tint) ::
               (_t'26, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'25, tshort) :: (_t'24, tint) ::
               (_t'23, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'22, tshort) :: (_t'21, tint) ::
               (_t'20, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'19, tshort) :: (_t'18, tint) ::
               (_t'17, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'16, tshort) :: (_t'15, tint) ::
               (_t'14, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'13, tshort) :: (_t'12, tint) ::
               (_t'11, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'10, tshort) :: (_t'9, tint) ::
               (_t'8, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'7, tshort) :: (_t'6, tint) ::
               (_t'5, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'4, tshort) :: (_t'3, tint) ::
               (_t'2, (tptr (Tstruct _EnvFxParticle noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _i (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                    cc_default))
        ((Ebinop Omul (Econst_int (Int.repr 15) tint)
           (Esizeof (Tunion __463 noattr) tuint) tuint) :: nil))
      (Sset _vertBuf
        (Ecast (Etempvar _t'1 (tptr tvoid)) (tptr (Tunion __463 noattr)))))
    (Ssequence
      (Sifthenelse (Ebinop Oeq
                     (Etempvar _vertBuf (tptr (Tunion __463 noattr)))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Sreturn None)
        Sskip)
      (Ssequence
        (Ssequence
          (Sset _i (Econst_int (Int.repr 0) tint))
          (Sloop
            (Ssequence
              (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                             (Econst_int (Int.repr 15) tint) tint)
                Sskip
                Sbreak)
              (Ssequence
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Etempvar _vertBuf (tptr (Tunion __463 noattr)))
                      (Etempvar _i tint) (tptr (Tunion __463 noattr)))
                    (Tunion __463 noattr))
                  (Ederef
                    (Ebinop Oadd
                      (Evar _gSnowTempVtx (tarray (Tunion __463 noattr) 3))
                      (Econst_int (Int.repr 0) tint)
                      (tptr (Tunion __463 noattr))) (Tunion __463 noattr)))
                (Ssequence
                  (Ssequence
                    (Sset _t'26
                      (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                    (Ssequence
                      (Sset _t'27
                        (Efield
                          (Ederef
                            (Ebinop Oadd
                              (Etempvar _t'26 (tptr (Tstruct _EnvFxParticle noattr)))
                              (Ebinop Oadd (Etempvar _index tint)
                                (Ebinop Odiv (Etempvar _i tint)
                                  (Econst_int (Int.repr 3) tint) tint) tint)
                              (tptr (Tstruct _EnvFxParticle noattr)))
                            (Tstruct _EnvFxParticle noattr)) _xPos tint))
                      (Ssequence
                        (Sset _t'28
                          (Ederef
                            (Ebinop Oadd (Etempvar _vertex1 (tptr tshort))
                              (Econst_int (Int.repr 0) tint) (tptr tshort))
                            tshort))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _vertBuf (tptr (Tunion __463 noattr)))
                                      (Etempvar _i tint)
                                      (tptr (Tunion __463 noattr)))
                                    (Tunion __463 noattr)) _v
                                  (Tstruct __459 noattr)) _ob
                                (tarray tshort 3))
                              (Econst_int (Int.repr 0) tint) (tptr tshort))
                            tshort)
                          (Ebinop Oadd (Etempvar _t'27 tint)
                            (Etempvar _t'28 tshort) tint)))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'23
                        (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                      (Ssequence
                        (Sset _t'24
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Etempvar _t'23 (tptr (Tstruct _EnvFxParticle noattr)))
                                (Ebinop Oadd (Etempvar _index tint)
                                  (Ebinop Odiv (Etempvar _i tint)
                                    (Econst_int (Int.repr 3) tint) tint)
                                  tint)
                                (tptr (Tstruct _EnvFxParticle noattr)))
                              (Tstruct _EnvFxParticle noattr)) _yPos tint))
                        (Ssequence
                          (Sset _t'25
                            (Ederef
                              (Ebinop Oadd (Etempvar _vertex1 (tptr tshort))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))
                              tshort))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _vertBuf (tptr (Tunion __463 noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tunion __463 noattr)))
                                      (Tunion __463 noattr)) _v
                                    (Tstruct __459 noattr)) _ob
                                  (tarray tshort 3))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))
                              tshort)
                            (Ebinop Oadd (Etempvar _t'24 tint)
                              (Etempvar _t'25 tshort) tint)))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'20
                          (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                        (Ssequence
                          (Sset _t'21
                            (Efield
                              (Ederef
                                (Ebinop Oadd
                                  (Etempvar _t'20 (tptr (Tstruct _EnvFxParticle noattr)))
                                  (Ebinop Oadd (Etempvar _index tint)
                                    (Ebinop Odiv (Etempvar _i tint)
                                      (Econst_int (Int.repr 3) tint) tint)
                                    tint)
                                  (tptr (Tstruct _EnvFxParticle noattr)))
                                (Tstruct _EnvFxParticle noattr)) _zPos tint))
                          (Ssequence
                            (Sset _t'22
                              (Ederef
                                (Ebinop Oadd
                                  (Etempvar _vertex1 (tptr tshort))
                                  (Econst_int (Int.repr 2) tint)
                                  (tptr tshort)) tshort))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Etempvar _vertBuf (tptr (Tunion __463 noattr)))
                                          (Etempvar _i tint)
                                          (tptr (Tunion __463 noattr)))
                                        (Tunion __463 noattr)) _v
                                      (Tstruct __459 noattr)) _ob
                                    (tarray tshort 3))
                                  (Econst_int (Int.repr 2) tint)
                                  (tptr tshort)) tshort)
                              (Ebinop Oadd (Etempvar _t'21 tint)
                                (Etempvar _t'22 tshort) tint)))))
                      (Ssequence
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Etempvar _vertBuf (tptr (Tunion __463 noattr)))
                              (Ebinop Oadd (Etempvar _i tint)
                                (Econst_int (Int.repr 1) tint) tint)
                              (tptr (Tunion __463 noattr)))
                            (Tunion __463 noattr))
                          (Ederef
                            (Ebinop Oadd
                              (Evar _gSnowTempVtx (tarray (Tunion __463 noattr) 3))
                              (Econst_int (Int.repr 1) tint)
                              (tptr (Tunion __463 noattr)))
                            (Tunion __463 noattr)))
                        (Ssequence
                          (Ssequence
                            (Sset _t'17
                              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                            (Ssequence
                              (Sset _t'18
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'17 (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Ebinop Oadd (Etempvar _index tint)
                                        (Ebinop Odiv (Etempvar _i tint)
                                          (Econst_int (Int.repr 3) tint)
                                          tint) tint)
                                      (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Tstruct _EnvFxParticle noattr)) _xPos
                                  tint))
                              (Ssequence
                                (Sset _t'19
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _vertex2 (tptr tshort))
                                      (Econst_int (Int.repr 0) tint)
                                      (tptr tshort)) tshort))
                                (Sassign
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Ebinop Oadd
                                              (Ebinop Oadd
                                                (Etempvar _vertBuf (tptr (Tunion __463 noattr)))
                                                (Etempvar _i tint)
                                                (tptr (Tunion __463 noattr)))
                                              (Econst_int (Int.repr 1) tint)
                                              (tptr (Tunion __463 noattr)))
                                            (Tunion __463 noattr)) _v
                                          (Tstruct __459 noattr)) _ob
                                        (tarray tshort 3))
                                      (Econst_int (Int.repr 0) tint)
                                      (tptr tshort)) tshort)
                                  (Ebinop Oadd (Etempvar _t'18 tint)
                                    (Etempvar _t'19 tshort) tint)))))
                          (Ssequence
                            (Ssequence
                              (Sset _t'14
                                (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                              (Ssequence
                                (Sset _t'15
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'14 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Ebinop Oadd (Etempvar _index tint)
                                          (Ebinop Odiv (Etempvar _i tint)
                                            (Econst_int (Int.repr 3) tint)
                                            tint) tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr)) _yPos
                                    tint))
                                (Ssequence
                                  (Sset _t'16
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _vertex2 (tptr tshort))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr tshort)) tshort))
                                  (Sassign
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Ebinop Oadd
                                                (Ebinop Oadd
                                                  (Etempvar _vertBuf (tptr (Tunion __463 noattr)))
                                                  (Etempvar _i tint)
                                                  (tptr (Tunion __463 noattr)))
                                                (Econst_int (Int.repr 1) tint)
                                                (tptr (Tunion __463 noattr)))
                                              (Tunion __463 noattr)) _v
                                            (Tstruct __459 noattr)) _ob
                                          (tarray tshort 3))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr tshort)) tshort)
                                    (Ebinop Oadd (Etempvar _t'15 tint)
                                      (Etempvar _t'16 tshort) tint)))))
                            (Ssequence
                              (Ssequence
                                (Sset _t'11
                                  (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                (Ssequence
                                  (Sset _t'12
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Etempvar _t'11 (tptr (Tstruct _EnvFxParticle noattr)))
                                          (Ebinop Oadd (Etempvar _index tint)
                                            (Ebinop Odiv (Etempvar _i tint)
                                              (Econst_int (Int.repr 3) tint)
                                              tint) tint)
                                          (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Tstruct _EnvFxParticle noattr))
                                      _zPos tint))
                                  (Ssequence
                                    (Sset _t'13
                                      (Ederef
                                        (Ebinop Oadd
                                          (Etempvar _vertex2 (tptr tshort))
                                          (Econst_int (Int.repr 2) tint)
                                          (tptr tshort)) tshort))
                                    (Sassign
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Ebinop Oadd
                                                    (Etempvar _vertBuf (tptr (Tunion __463 noattr)))
                                                    (Etempvar _i tint)
                                                    (tptr (Tunion __463 noattr)))
                                                  (Econst_int (Int.repr 1) tint)
                                                  (tptr (Tunion __463 noattr)))
                                                (Tunion __463 noattr)) _v
                                              (Tstruct __459 noattr)) _ob
                                            (tarray tshort 3))
                                          (Econst_int (Int.repr 2) tint)
                                          (tptr tshort)) tshort)
                                      (Ebinop Oadd (Etempvar _t'12 tint)
                                        (Etempvar _t'13 tshort) tint)))))
                              (Ssequence
                                (Sassign
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _vertBuf (tptr (Tunion __463 noattr)))
                                      (Ebinop Oadd (Etempvar _i tint)
                                        (Econst_int (Int.repr 2) tint) tint)
                                      (tptr (Tunion __463 noattr)))
                                    (Tunion __463 noattr))
                                  (Ederef
                                    (Ebinop Oadd
                                      (Evar _gSnowTempVtx (tarray (Tunion __463 noattr) 3))
                                      (Econst_int (Int.repr 2) tint)
                                      (tptr (Tunion __463 noattr)))
                                    (Tunion __463 noattr)))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'8
                                      (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                    (Ssequence
                                      (Sset _t'9
                                        (Efield
                                          (Ederef
                                            (Ebinop Oadd
                                              (Etempvar _t'8 (tptr (Tstruct _EnvFxParticle noattr)))
                                              (Ebinop Oadd
                                                (Etempvar _index tint)
                                                (Ebinop Odiv
                                                  (Etempvar _i tint)
                                                  (Econst_int (Int.repr 3) tint)
                                                  tint) tint)
                                              (tptr (Tstruct _EnvFxParticle noattr)))
                                            (Tstruct _EnvFxParticle noattr))
                                          _xPos tint))
                                      (Ssequence
                                        (Sset _t'10
                                          (Ederef
                                            (Ebinop Oadd
                                              (Etempvar _vertex3 (tptr tshort))
                                              (Econst_int (Int.repr 0) tint)
                                              (tptr tshort)) tshort))
                                        (Sassign
                                          (Ederef
                                            (Ebinop Oadd
                                              (Efield
                                                (Efield
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Ebinop Oadd
                                                        (Etempvar _vertBuf (tptr (Tunion __463 noattr)))
                                                        (Etempvar _i tint)
                                                        (tptr (Tunion __463 noattr)))
                                                      (Econst_int (Int.repr 2) tint)
                                                      (tptr (Tunion __463 noattr)))
                                                    (Tunion __463 noattr)) _v
                                                  (Tstruct __459 noattr)) _ob
                                                (tarray tshort 3))
                                              (Econst_int (Int.repr 0) tint)
                                              (tptr tshort)) tshort)
                                          (Ebinop Oadd (Etempvar _t'9 tint)
                                            (Etempvar _t'10 tshort) tint)))))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'5
                                        (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                      (Ssequence
                                        (Sset _t'6
                                          (Efield
                                            (Ederef
                                              (Ebinop Oadd
                                                (Etempvar _t'5 (tptr (Tstruct _EnvFxParticle noattr)))
                                                (Ebinop Oadd
                                                  (Etempvar _index tint)
                                                  (Ebinop Odiv
                                                    (Etempvar _i tint)
                                                    (Econst_int (Int.repr 3) tint)
                                                    tint) tint)
                                                (tptr (Tstruct _EnvFxParticle noattr)))
                                              (Tstruct _EnvFxParticle noattr))
                                            _yPos tint))
                                        (Ssequence
                                          (Sset _t'7
                                            (Ederef
                                              (Ebinop Oadd
                                                (Etempvar _vertex3 (tptr tshort))
                                                (Econst_int (Int.repr 1) tint)
                                                (tptr tshort)) tshort))
                                          (Sassign
                                            (Ederef
                                              (Ebinop Oadd
                                                (Efield
                                                  (Efield
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Ebinop Oadd
                                                          (Etempvar _vertBuf (tptr (Tunion __463 noattr)))
                                                          (Etempvar _i tint)
                                                          (tptr (Tunion __463 noattr)))
                                                        (Econst_int (Int.repr 2) tint)
                                                        (tptr (Tunion __463 noattr)))
                                                      (Tunion __463 noattr))
                                                    _v
                                                    (Tstruct __459 noattr))
                                                  _ob (tarray tshort 3))
                                                (Econst_int (Int.repr 1) tint)
                                                (tptr tshort)) tshort)
                                            (Ebinop Oadd (Etempvar _t'6 tint)
                                              (Etempvar _t'7 tshort) tint)))))
                                    (Ssequence
                                      (Sset _t'2
                                        (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                      (Ssequence
                                        (Sset _t'3
                                          (Efield
                                            (Ederef
                                              (Ebinop Oadd
                                                (Etempvar _t'2 (tptr (Tstruct _EnvFxParticle noattr)))
                                                (Ebinop Oadd
                                                  (Etempvar _index tint)
                                                  (Ebinop Odiv
                                                    (Etempvar _i tint)
                                                    (Econst_int (Int.repr 3) tint)
                                                    tint) tint)
                                                (tptr (Tstruct _EnvFxParticle noattr)))
                                              (Tstruct _EnvFxParticle noattr))
                                            _zPos tint))
                                        (Ssequence
                                          (Sset _t'4
                                            (Ederef
                                              (Ebinop Oadd
                                                (Etempvar _vertex3 (tptr tshort))
                                                (Econst_int (Int.repr 2) tint)
                                                (tptr tshort)) tshort))
                                          (Sassign
                                            (Ederef
                                              (Ebinop Oadd
                                                (Efield
                                                  (Efield
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Ebinop Oadd
                                                          (Etempvar _vertBuf (tptr (Tunion __463 noattr)))
                                                          (Etempvar _i tint)
                                                          (tptr (Tunion __463 noattr)))
                                                        (Econst_int (Int.repr 2) tint)
                                                        (tptr (Tunion __463 noattr)))
                                                      (Tunion __463 noattr))
                                                    _v
                                                    (Tstruct __459 noattr))
                                                  _ob (tarray tshort 3))
                                                (Econst_int (Int.repr 2) tint)
                                                (tptr tshort)) tshort)
                                            (Ebinop Oadd (Etempvar _t'3 tint)
                                              (Etempvar _t'4 tshort) tint)))))))))))))))))
            (Sset _i
              (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 3) tint)
                tint))))
        (Ssequence
          (Sset __g
            (Ecast (Etempvar _gfx (tptr (Tunion __512 noattr)))
              (tptr (Tunion __512 noattr))))
          (Ssequence
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g (tptr (Tunion __512 noattr)))
                    (Tunion __512 noattr)) _words (Tstruct __510 noattr)) _w0
                tuint)
              (Ebinop Oor
                (Ebinop Oor
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 4) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 8) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 24) tint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast
                          (Ebinop Oor
                            (Ebinop Oshl
                              (Ebinop Osub (Econst_int (Int.repr 15) tint)
                                (Econst_int (Int.repr 1) tint) tint)
                              (Econst_int (Int.repr 4) tint) tint)
                            (Econst_int (Int.repr 0) tint) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 8) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 16) tint) tuint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast
                        (Ebinop Omul (Esizeof (Tunion __463 noattr) tuint)
                          (Econst_int (Int.repr 15) tint) tuint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 16) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g (tptr (Tunion __512 noattr)))
                    (Tunion __512 noattr)) _words (Tstruct __510 noattr)) _w1
                tuint)
              (Ecast
                (Ebinop Oand
                  (Ecast (Etempvar _vertBuf (tptr (Tunion __463 noattr)))
                    tuint) (Econst_int (Int.repr 536870911) tint) tuint)
                tuint))))))))
|}.

Definition f_envfx_update_snow := {|
  fn_return := (tptr (Tunion __512 noattr));
  fn_callconv := cc_default;
  fn_params := ((_snowMode, tint) :: (_marioPos, (tptr tshort)) ::
                (_camFrom, (tptr tshort)) :: (_camTo, (tptr tshort)) :: nil);
  fn_vars := ((_radius, tshort) :: (_pitch, tshort) :: (_yaw, tshort) ::
              (_snowCylinderPos, (tarray tshort 3)) ::
              (_vertex1, (Tstruct _SnowFlakeVertex noattr)) ::
              (_vertex2, (Tstruct _SnowFlakeVertex noattr)) ::
              (_vertex3, (Tstruct _SnowFlakeVertex noattr)) :: nil);
  fn_temps := ((_i, tint) :: (_gfxStart, (tptr (Tunion __512 noattr))) ::
               (_gfx, (tptr (Tunion __512 noattr))) ::
               (__g, (tptr (Tunion __512 noattr))) ::
               (__g__1, (tptr (Tunion __512 noattr))) ::
               (__g__2, (tptr (Tunion __512 noattr))) ::
               (__g__3, (tptr (Tunion __512 noattr))) ::
               (__g__4, (tptr (Tunion __512 noattr))) ::
               (__g__5, (tptr (Tunion __512 noattr))) ::
               (__g__6, (tptr (Tunion __512 noattr))) ::
               (__g__7, (tptr (Tunion __512 noattr))) ::
               (__g__8, (tptr (Tunion __512 noattr))) ::
               (_t'12, (tptr (Tunion __512 noattr))) ::
               (_t'11, (tptr (Tunion __512 noattr))) ::
               (_t'10, (tptr (Tunion __512 noattr))) ::
               (_t'9, (tptr (Tunion __512 noattr))) ::
               (_t'8, (tptr (Tunion __512 noattr))) ::
               (_t'7, (tptr (Tunion __512 noattr))) ::
               (_t'6, (tptr (Tunion __512 noattr))) ::
               (_t'5, (tptr (Tunion __512 noattr))) :: (_t'4, tint) ::
               (_t'3, (tptr (Tunion __512 noattr))) ::
               (_t'2, (tptr (Tunion __512 noattr))) ::
               (_t'1, (tptr tvoid)) :: (_t'40, tshort) :: (_t'39, tshort) ::
               (_t'38, tshort) :: (_t'37, tshort) :: (_t'36, tshort) ::
               (_t'35, tshort) :: (_t'34, tshort) :: (_t'33, tshort) ::
               (_t'32, tshort) :: (_t'31, tshort) :: (_t'30, tshort) ::
               (_t'29, tshort) :: (_t'28, tshort) :: (_t'27, tshort) ::
               (_t'26, tshort) :: (_t'25, tshort) :: (_t'24, tshort) ::
               (_t'23, tshort) :: (_t'22, tshort) :: (_t'21, tshort) ::
               (_t'20, tshort) :: (_t'19, tshort) :: (_t'18, tshort) ::
               (_t'17, tshort) :: (_t'16, tshort) :: (_t'15, tshort) ::
               (_t'14, tshort) :: (_t'13, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _vertex1 (Tstruct _SnowFlakeVertex noattr))
    (Evar _gSnowFlakeVertex1 (Tstruct _SnowFlakeVertex noattr)))
  (Ssequence
    (Sassign (Evar _vertex2 (Tstruct _SnowFlakeVertex noattr))
      (Evar _gSnowFlakeVertex2 (Tstruct _SnowFlakeVertex noattr)))
    (Ssequence
      (Sassign (Evar _vertex3 (Tstruct _SnowFlakeVertex noattr))
        (Evar _gSnowFlakeVertex3 (Tstruct _SnowFlakeVertex noattr)))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'40 (Evar _gSnowParticleCount tshort))
            (Scall (Some _t'1)
              (Evar _alloc_display_list (Tfunction (tuint :: nil)
                                          (tptr tvoid) cc_default))
              ((Ebinop Omul
                 (Ebinop Oadd
                   (Ebinop Omul (Etempvar _t'40 tshort)
                     (Econst_int (Int.repr 6) tint) tint)
                   (Econst_int (Int.repr 3) tint) tint)
                 (Esizeof (Tunion __512 noattr) tuint) tuint) :: nil)))
          (Sset _gfxStart
            (Ecast (Etempvar _t'1 (tptr tvoid)) (tptr (Tunion __512 noattr)))))
        (Ssequence
          (Sset _gfx (Etempvar _gfxStart (tptr (Tunion __512 noattr))))
          (Ssequence
            (Sifthenelse (Ebinop Oeq
                           (Etempvar _gfxStart (tptr (Tunion __512 noattr)))
                           (Ecast (Econst_int (Int.repr 0) tint)
                             (tptr tvoid)) tint)
              (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint)
                               (tptr tvoid))))
              Sskip)
            (Ssequence
              (Scall None
                (Evar _envfx_update_snowflake_count (Tfunction
                                                      (tint ::
                                                       (tptr tshort) :: nil)
                                                      tvoid cc_default))
                ((Etempvar _snowMode tint) ::
                 (Etempvar _marioPos (tptr tshort)) :: nil))
              (Ssequence
                (Scall None
                  (Evar _orbit_from_positions (Tfunction
                                                ((tptr tshort) ::
                                                 (tptr tshort) ::
                                                 (tptr tshort) ::
                                                 (tptr tshort) ::
                                                 (tptr tshort) :: nil) tvoid
                                                cc_default))
                  ((Etempvar _camTo (tptr tshort)) ::
                   (Etempvar _camFrom (tptr tshort)) ::
                   (Eaddrof (Evar _radius tshort) (tptr tshort)) ::
                   (Eaddrof (Evar _pitch tshort) (tptr tshort)) ::
                   (Eaddrof (Evar _yaw tshort) (tptr tshort)) :: nil))
                (Ssequence
                  (Sswitch (Etempvar _snowMode tint)
                    (LScons (Some 1)
                      (Ssequence
                        (Ssequence
                          (Sset _t'38 (Evar _radius tshort))
                          (Sifthenelse (Ebinop Ogt (Etempvar _t'38 tshort)
                                         (Econst_int (Int.repr 250) tint)
                                         tint)
                            (Ssequence
                              (Sset _t'39 (Evar _radius tshort))
                              (Sassign (Evar _radius tshort)
                                (Ebinop Osub (Etempvar _t'39 tshort)
                                  (Econst_int (Int.repr 250) tint) tint)))
                            (Sassign (Evar _radius tshort)
                              (Econst_int (Int.repr 1) tint))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'35 (Evar _radius tshort))
                            (Ssequence
                              (Sset _t'36 (Evar _pitch tshort))
                              (Ssequence
                                (Sset _t'37 (Evar _yaw tshort))
                                (Scall None
                                  (Evar _pos_from_orbit (Tfunction
                                                          ((tptr tshort) ::
                                                           (tptr tshort) ::
                                                           tshort ::
                                                           tshort ::
                                                           tshort :: nil)
                                                          tvoid cc_default))
                                  ((Etempvar _camTo (tptr tshort)) ::
                                   (Evar _snowCylinderPos (tarray tshort 3)) ::
                                   (Etempvar _t'35 tshort) ::
                                   (Etempvar _t'36 tshort) ::
                                   (Etempvar _t'37 tshort) :: nil)))))
                          (Ssequence
                            (Ssequence
                              (Sset _t'32
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _snowCylinderPos (tarray tshort 3))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr tshort)) tshort))
                              (Ssequence
                                (Sset _t'33
                                  (Ederef
                                    (Ebinop Oadd
                                      (Evar _snowCylinderPos (tarray tshort 3))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr tshort)) tshort))
                                (Ssequence
                                  (Sset _t'34
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _snowCylinderPos (tarray tshort 3))
                                        (Econst_int (Int.repr 2) tint)
                                        (tptr tshort)) tshort))
                                  (Scall None
                                    (Evar _envfx_update_snow_normal (Tfunction
                                                                    (tint ::
                                                                    tint ::
                                                                    tint ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                    ((Etempvar _t'32 tshort) ::
                                     (Etempvar _t'33 tshort) ::
                                     (Etempvar _t'34 tshort) :: nil)))))
                            Sbreak)))
                      (LScons (Some 2)
                        (Ssequence
                          (Ssequence
                            (Sset _t'30 (Evar _radius tshort))
                            (Sifthenelse (Ebinop Ogt (Etempvar _t'30 tshort)
                                           (Econst_int (Int.repr 500) tint)
                                           tint)
                              (Ssequence
                                (Sset _t'31 (Evar _radius tshort))
                                (Sassign (Evar _radius tshort)
                                  (Ebinop Osub (Etempvar _t'31 tshort)
                                    (Econst_int (Int.repr 500) tint) tint)))
                              (Sassign (Evar _radius tshort)
                                (Econst_int (Int.repr 1) tint))))
                          (Ssequence
                            (Ssequence
                              (Sset _t'27 (Evar _radius tshort))
                              (Ssequence
                                (Sset _t'28 (Evar _pitch tshort))
                                (Ssequence
                                  (Sset _t'29 (Evar _yaw tshort))
                                  (Scall None
                                    (Evar _pos_from_orbit (Tfunction
                                                            ((tptr tshort) ::
                                                             (tptr tshort) ::
                                                             tshort ::
                                                             tshort ::
                                                             tshort :: nil)
                                                            tvoid cc_default))
                                    ((Etempvar _camTo (tptr tshort)) ::
                                     (Evar _snowCylinderPos (tarray tshort 3)) ::
                                     (Etempvar _t'27 tshort) ::
                                     (Etempvar _t'28 tshort) ::
                                     (Etempvar _t'29 tshort) :: nil)))))
                            (Ssequence
                              (Ssequence
                                (Sset _t'24
                                  (Ederef
                                    (Ebinop Oadd
                                      (Evar _snowCylinderPos (tarray tshort 3))
                                      (Econst_int (Int.repr 0) tint)
                                      (tptr tshort)) tshort))
                                (Ssequence
                                  (Sset _t'25
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _snowCylinderPos (tarray tshort 3))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr tshort)) tshort))
                                  (Ssequence
                                    (Sset _t'26
                                      (Ederef
                                        (Ebinop Oadd
                                          (Evar _snowCylinderPos (tarray tshort 3))
                                          (Econst_int (Int.repr 2) tint)
                                          (tptr tshort)) tshort))
                                    (Scall None
                                      (Evar _envfx_update_snow_water
                                      (Tfunction
                                        (tint :: tint :: tint :: nil) tvoid
                                        cc_default))
                                      ((Etempvar _t'24 tshort) ::
                                       (Etempvar _t'25 tshort) ::
                                       (Etempvar _t'26 tshort) :: nil)))))
                              Sbreak)))
                        (LScons (Some 3)
                          (Ssequence
                            (Ssequence
                              (Sset _t'22 (Evar _radius tshort))
                              (Sifthenelse (Ebinop Ogt
                                             (Etempvar _t'22 tshort)
                                             (Econst_int (Int.repr 250) tint)
                                             tint)
                                (Ssequence
                                  (Sset _t'23 (Evar _radius tshort))
                                  (Sassign (Evar _radius tshort)
                                    (Ebinop Osub (Etempvar _t'23 tshort)
                                      (Econst_int (Int.repr 250) tint) tint)))
                                (Sassign (Evar _radius tshort)
                                  (Econst_int (Int.repr 1) tint))))
                            (Ssequence
                              (Ssequence
                                (Sset _t'19 (Evar _radius tshort))
                                (Ssequence
                                  (Sset _t'20 (Evar _pitch tshort))
                                  (Ssequence
                                    (Sset _t'21 (Evar _yaw tshort))
                                    (Scall None
                                      (Evar _pos_from_orbit (Tfunction
                                                              ((tptr tshort) ::
                                                               (tptr tshort) ::
                                                               tshort ::
                                                               tshort ::
                                                               tshort :: nil)
                                                              tvoid
                                                              cc_default))
                                      ((Etempvar _camTo (tptr tshort)) ::
                                       (Evar _snowCylinderPos (tarray tshort 3)) ::
                                       (Etempvar _t'19 tshort) ::
                                       (Etempvar _t'20 tshort) ::
                                       (Etempvar _t'21 tshort) :: nil)))))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'16
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _snowCylinderPos (tarray tshort 3))
                                        (Econst_int (Int.repr 0) tint)
                                        (tptr tshort)) tshort))
                                  (Ssequence
                                    (Sset _t'17
                                      (Ederef
                                        (Ebinop Oadd
                                          (Evar _snowCylinderPos (tarray tshort 3))
                                          (Econst_int (Int.repr 1) tint)
                                          (tptr tshort)) tshort))
                                    (Ssequence
                                      (Sset _t'18
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _snowCylinderPos (tarray tshort 3))
                                            (Econst_int (Int.repr 2) tint)
                                            (tptr tshort)) tshort))
                                      (Scall None
                                        (Evar _envfx_update_snow_blizzard
                                        (Tfunction
                                          (tint :: tint :: tint :: nil) tvoid
                                          cc_default))
                                        ((Etempvar _t'16 tshort) ::
                                         (Etempvar _t'17 tshort) ::
                                         (Etempvar _t'18 tshort) :: nil)))))
                                Sbreak)))
                          LSnil))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'14 (Evar _pitch tshort))
                      (Ssequence
                        (Sset _t'15 (Evar _yaw tshort))
                        (Scall None
                          (Evar _rotate_triangle_vertices (Tfunction
                                                            ((tptr tshort) ::
                                                             (tptr tshort) ::
                                                             (tptr tshort) ::
                                                             tshort ::
                                                             tshort :: nil)
                                                            tvoid cc_default))
                          ((Ecast
                             (Eaddrof
                               (Evar _vertex1 (Tstruct _SnowFlakeVertex noattr))
                               (tptr (Tstruct _SnowFlakeVertex noattr)))
                             (tptr tshort)) ::
                           (Ecast
                             (Eaddrof
                               (Evar _vertex2 (Tstruct _SnowFlakeVertex noattr))
                               (tptr (Tstruct _SnowFlakeVertex noattr)))
                             (tptr tshort)) ::
                           (Ecast
                             (Eaddrof
                               (Evar _vertex3 (Tstruct _SnowFlakeVertex noattr))
                               (tptr (Tstruct _SnowFlakeVertex noattr)))
                             (tptr tshort)) :: (Etempvar _t'14 tshort) ::
                           (Etempvar _t'15 tshort) :: nil))))
                    (Ssequence
                      (Ssequence
                        (Sifthenelse (Ebinop Oeq (Etempvar _snowMode tint)
                                       (Econst_int (Int.repr 1) tint) tint)
                          (Sset _t'4 (Econst_int (Int.repr 1) tint))
                          (Sset _t'4
                            (Ecast
                              (Ebinop Oeq (Etempvar _snowMode tint)
                                (Econst_int (Int.repr 3) tint) tint) tbool)))
                        (Sifthenelse (Etempvar _t'4 tint)
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Sset _t'2
                                  (Etempvar _gfx (tptr (Tunion __512 noattr))))
                                (Sset _gfx
                                  (Ebinop Oadd
                                    (Etempvar _t'2 (tptr (Tunion __512 noattr)))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr (Tunion __512 noattr)))))
                              (Sset __g
                                (Ecast
                                  (Etempvar _t'2 (tptr (Tunion __512 noattr)))
                                  (tptr (Tunion __512 noattr)))))
                            (Ssequence
                              (Sassign
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar __g (tptr (Tunion __512 noattr)))
                                      (Tunion __512 noattr)) _words
                                    (Tstruct __510 noattr)) _w0 tuint)
                                (Ebinop Oor
                                  (Ebinop Oor
                                    (Ecast
                                      (Ebinop Oshl
                                        (Ebinop Oand
                                          (Ecast
                                            (Econst_int (Int.repr 6) tint)
                                            tuint)
                                          (Ebinop Osub
                                            (Ebinop Oshl
                                              (Econst_int (Int.repr 1) tint)
                                              (Econst_int (Int.repr 8) tint)
                                              tint)
                                            (Econst_int (Int.repr 1) tint)
                                            tint) tuint)
                                        (Econst_int (Int.repr 24) tint)
                                        tuint) tuint)
                                    (Ecast
                                      (Ebinop Oshl
                                        (Ebinop Oand
                                          (Ecast
                                            (Econst_int (Int.repr 0) tint)
                                            tuint)
                                          (Ebinop Osub
                                            (Ebinop Oshl
                                              (Econst_int (Int.repr 1) tint)
                                              (Econst_int (Int.repr 8) tint)
                                              tint)
                                            (Econst_int (Int.repr 1) tint)
                                            tint) tuint)
                                        (Econst_int (Int.repr 16) tint)
                                        tuint) tuint) tuint)
                                  (Ecast
                                    (Ebinop Oshl
                                      (Ebinop Oand
                                        (Ecast (Econst_int (Int.repr 0) tint)
                                          tuint)
                                        (Ebinop Osub
                                          (Ebinop Oshl
                                            (Econst_int (Int.repr 1) tint)
                                            (Econst_int (Int.repr 16) tint)
                                            tint)
                                          (Econst_int (Int.repr 1) tint)
                                          tint) tuint)
                                      (Econst_int (Int.repr 0) tint) tuint)
                                    tuint) tuint))
                              (Sassign
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar __g (tptr (Tunion __512 noattr)))
                                      (Tunion __512 noattr)) _words
                                    (Tstruct __510 noattr)) _w1 tuint)
                                (Ecast
                                  (Eaddrof
                                    (Evar _tiny_bubble_dl_0B006A50 (tptr tvoid))
                                    (tptr (tptr tvoid))) tuint))))
                          (Sifthenelse (Ebinop Oeq (Etempvar _snowMode tint)
                                         (Econst_int (Int.repr 2) tint) tint)
                            (Ssequence
                              (Ssequence
                                (Ssequence
                                  (Sset _t'3
                                    (Etempvar _gfx (tptr (Tunion __512 noattr))))
                                  (Sset _gfx
                                    (Ebinop Oadd
                                      (Etempvar _t'3 (tptr (Tunion __512 noattr)))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr (Tunion __512 noattr)))))
                                (Sset __g__1
                                  (Ecast
                                    (Etempvar _t'3 (tptr (Tunion __512 noattr)))
                                    (tptr (Tunion __512 noattr)))))
                              (Ssequence
                                (Sassign
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar __g__1 (tptr (Tunion __512 noattr)))
                                        (Tunion __512 noattr)) _words
                                      (Tstruct __510 noattr)) _w0 tuint)
                                  (Ebinop Oor
                                    (Ebinop Oor
                                      (Ecast
                                        (Ebinop Oshl
                                          (Ebinop Oand
                                            (Ecast
                                              (Econst_int (Int.repr 6) tint)
                                              tuint)
                                            (Ebinop Osub
                                              (Ebinop Oshl
                                                (Econst_int (Int.repr 1) tint)
                                                (Econst_int (Int.repr 8) tint)
                                                tint)
                                              (Econst_int (Int.repr 1) tint)
                                              tint) tuint)
                                          (Econst_int (Int.repr 24) tint)
                                          tuint) tuint)
                                      (Ecast
                                        (Ebinop Oshl
                                          (Ebinop Oand
                                            (Ecast
                                              (Econst_int (Int.repr 0) tint)
                                              tuint)
                                            (Ebinop Osub
                                              (Ebinop Oshl
                                                (Econst_int (Int.repr 1) tint)
                                                (Econst_int (Int.repr 8) tint)
                                                tint)
                                              (Econst_int (Int.repr 1) tint)
                                              tint) tuint)
                                          (Econst_int (Int.repr 16) tint)
                                          tuint) tuint) tuint)
                                    (Ecast
                                      (Ebinop Oshl
                                        (Ebinop Oand
                                          (Ecast
                                            (Econst_int (Int.repr 0) tint)
                                            tuint)
                                          (Ebinop Osub
                                            (Ebinop Oshl
                                              (Econst_int (Int.repr 1) tint)
                                              (Econst_int (Int.repr 16) tint)
                                              tint)
                                            (Econst_int (Int.repr 1) tint)
                                            tint) tuint)
                                        (Econst_int (Int.repr 0) tint) tuint)
                                      tuint) tuint))
                                (Sassign
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar __g__1 (tptr (Tunion __512 noattr)))
                                        (Tunion __512 noattr)) _words
                                      (Tstruct __510 noattr)) _w1 tuint)
                                  (Ecast
                                    (Eaddrof
                                      (Evar _tiny_bubble_dl_0B006CD8 (tptr tvoid))
                                      (tptr (tptr tvoid))) tuint))))
                            Sskip)))
                      (Ssequence
                        (Ssequence
                          (Sset _i (Econst_int (Int.repr 0) tint))
                          (Sloop
                            (Ssequence
                              (Ssequence
                                (Sset _t'13
                                  (Evar _gSnowParticleCount tshort))
                                (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                                               (Etempvar _t'13 tshort) tint)
                                  Sskip
                                  Sbreak))
                              (Ssequence
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'5
                                      (Etempvar _gfx (tptr (Tunion __512 noattr))))
                                    (Sset _gfx
                                      (Ebinop Oadd
                                        (Etempvar _t'5 (tptr (Tunion __512 noattr)))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr (Tunion __512 noattr)))))
                                  (Scall None
                                    (Evar _append_snowflake_vertex_buffer
                                    (Tfunction
                                      ((tptr (Tunion __512 noattr)) ::
                                       tint :: (tptr tshort) ::
                                       (tptr tshort) :: (tptr tshort) :: nil)
                                      tvoid cc_default))
                                    ((Etempvar _t'5 (tptr (Tunion __512 noattr))) ::
                                     (Etempvar _i tint) ::
                                     (Ecast
                                       (Eaddrof
                                         (Evar _vertex1 (Tstruct _SnowFlakeVertex noattr))
                                         (tptr (Tstruct _SnowFlakeVertex noattr)))
                                       (tptr tshort)) ::
                                     (Ecast
                                       (Eaddrof
                                         (Evar _vertex2 (Tstruct _SnowFlakeVertex noattr))
                                         (tptr (Tstruct _SnowFlakeVertex noattr)))
                                       (tptr tshort)) ::
                                     (Ecast
                                       (Eaddrof
                                         (Evar _vertex3 (Tstruct _SnowFlakeVertex noattr))
                                         (tptr (Tstruct _SnowFlakeVertex noattr)))
                                       (tptr tshort)) :: nil)))
                                (Ssequence
                                  (Ssequence
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'6
                                          (Etempvar _gfx (tptr (Tunion __512 noattr))))
                                        (Sset _gfx
                                          (Ebinop Oadd
                                            (Etempvar _t'6 (tptr (Tunion __512 noattr)))
                                            (Econst_int (Int.repr 1) tint)
                                            (tptr (Tunion __512 noattr)))))
                                      (Sset __g__2
                                        (Ecast
                                          (Etempvar _t'6 (tptr (Tunion __512 noattr)))
                                          (tptr (Tunion __512 noattr)))))
                                    (Ssequence
                                      (Sassign
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar __g__2 (tptr (Tunion __512 noattr)))
                                              (Tunion __512 noattr)) _words
                                            (Tstruct __510 noattr)) _w0
                                          tuint)
                                        (Ecast
                                          (Ebinop Oshl
                                            (Ebinop Oand
                                              (Ecast
                                                (Ebinop Osub
                                                  (Eunop Oneg
                                                    (Econst_int (Int.repr 65) tint)
                                                    tint)
                                                  (Econst_int (Int.repr 0) tint)
                                                  tint) tuint)
                                              (Ebinop Osub
                                                (Ebinop Oshl
                                                  (Econst_int (Int.repr 1) tint)
                                                  (Econst_int (Int.repr 8) tint)
                                                  tint)
                                                (Econst_int (Int.repr 1) tint)
                                                tint) tuint)
                                            (Econst_int (Int.repr 24) tint)
                                            tuint) tuint))
                                      (Sassign
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar __g__2 (tptr (Tunion __512 noattr)))
                                              (Tunion __512 noattr)) _words
                                            (Tstruct __510 noattr)) _w1
                                          tuint)
                                        (Ebinop Oor
                                          (Ebinop Oor
                                            (Ebinop Oor
                                              (Ecast
                                                (Ebinop Oshl
                                                  (Ebinop Oand
                                                    (Ecast
                                                      (Econst_int (Int.repr 0) tint)
                                                      tuint)
                                                    (Ebinop Osub
                                                      (Ebinop Oshl
                                                        (Econst_int (Int.repr 1) tint)
                                                        (Econst_int (Int.repr 8) tint)
                                                        tint)
                                                      (Econst_int (Int.repr 1) tint)
                                                      tint) tuint)
                                                  (Econst_int (Int.repr 24) tint)
                                                  tuint) tuint)
                                              (Ecast
                                                (Ebinop Oshl
                                                  (Ebinop Oand
                                                    (Ecast
                                                      (Ebinop Omul
                                                        (Econst_int (Int.repr 0) tint)
                                                        (Econst_int (Int.repr 10) tint)
                                                        tint) tuint)
                                                    (Ebinop Osub
                                                      (Ebinop Oshl
                                                        (Econst_int (Int.repr 1) tint)
                                                        (Econst_int (Int.repr 8) tint)
                                                        tint)
                                                      (Econst_int (Int.repr 1) tint)
                                                      tint) tuint)
                                                  (Econst_int (Int.repr 16) tint)
                                                  tuint) tuint) tuint)
                                            (Ecast
                                              (Ebinop Oshl
                                                (Ebinop Oand
                                                  (Ecast
                                                    (Ebinop Omul
                                                      (Econst_int (Int.repr 1) tint)
                                                      (Econst_int (Int.repr 10) tint)
                                                      tint) tuint)
                                                  (Ebinop Osub
                                                    (Ebinop Oshl
                                                      (Econst_int (Int.repr 1) tint)
                                                      (Econst_int (Int.repr 8) tint)
                                                      tint)
                                                    (Econst_int (Int.repr 1) tint)
                                                    tint) tuint)
                                                (Econst_int (Int.repr 8) tint)
                                                tuint) tuint) tuint)
                                          (Ecast
                                            (Ebinop Oshl
                                              (Ebinop Oand
                                                (Ecast
                                                  (Ebinop Omul
                                                    (Econst_int (Int.repr 2) tint)
                                                    (Econst_int (Int.repr 10) tint)
                                                    tint) tuint)
                                                (Ebinop Osub
                                                  (Ebinop Oshl
                                                    (Econst_int (Int.repr 1) tint)
                                                    (Econst_int (Int.repr 8) tint)
                                                    tint)
                                                  (Econst_int (Int.repr 1) tint)
                                                  tint) tuint)
                                              (Econst_int (Int.repr 0) tint)
                                              tuint) tuint) tuint))))
                                  (Ssequence
                                    (Ssequence
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'7
                                            (Etempvar _gfx (tptr (Tunion __512 noattr))))
                                          (Sset _gfx
                                            (Ebinop Oadd
                                              (Etempvar _t'7 (tptr (Tunion __512 noattr)))
                                              (Econst_int (Int.repr 1) tint)
                                              (tptr (Tunion __512 noattr)))))
                                        (Sset __g__3
                                          (Ecast
                                            (Etempvar _t'7 (tptr (Tunion __512 noattr)))
                                            (tptr (Tunion __512 noattr)))))
                                      (Ssequence
                                        (Sassign
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar __g__3 (tptr (Tunion __512 noattr)))
                                                (Tunion __512 noattr)) _words
                                              (Tstruct __510 noattr)) _w0
                                            tuint)
                                          (Ecast
                                            (Ebinop Oshl
                                              (Ebinop Oand
                                                (Ecast
                                                  (Ebinop Osub
                                                    (Eunop Oneg
                                                      (Econst_int (Int.repr 65) tint)
                                                      tint)
                                                    (Econst_int (Int.repr 0) tint)
                                                    tint) tuint)
                                                (Ebinop Osub
                                                  (Ebinop Oshl
                                                    (Econst_int (Int.repr 1) tint)
                                                    (Econst_int (Int.repr 8) tint)
                                                    tint)
                                                  (Econst_int (Int.repr 1) tint)
                                                  tint) tuint)
                                              (Econst_int (Int.repr 24) tint)
                                              tuint) tuint))
                                        (Sassign
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar __g__3 (tptr (Tunion __512 noattr)))
                                                (Tunion __512 noattr)) _words
                                              (Tstruct __510 noattr)) _w1
                                            tuint)
                                          (Ebinop Oor
                                            (Ebinop Oor
                                              (Ebinop Oor
                                                (Ecast
                                                  (Ebinop Oshl
                                                    (Ebinop Oand
                                                      (Ecast
                                                        (Econst_int (Int.repr 0) tint)
                                                        tuint)
                                                      (Ebinop Osub
                                                        (Ebinop Oshl
                                                          (Econst_int (Int.repr 1) tint)
                                                          (Econst_int (Int.repr 8) tint)
                                                          tint)
                                                        (Econst_int (Int.repr 1) tint)
                                                        tint) tuint)
                                                    (Econst_int (Int.repr 24) tint)
                                                    tuint) tuint)
                                                (Ecast
                                                  (Ebinop Oshl
                                                    (Ebinop Oand
                                                      (Ecast
                                                        (Ebinop Omul
                                                          (Econst_int (Int.repr 3) tint)
                                                          (Econst_int (Int.repr 10) tint)
                                                          tint) tuint)
                                                      (Ebinop Osub
                                                        (Ebinop Oshl
                                                          (Econst_int (Int.repr 1) tint)
                                                          (Econst_int (Int.repr 8) tint)
                                                          tint)
                                                        (Econst_int (Int.repr 1) tint)
                                                        tint) tuint)
                                                    (Econst_int (Int.repr 16) tint)
                                                    tuint) tuint) tuint)
                                              (Ecast
                                                (Ebinop Oshl
                                                  (Ebinop Oand
                                                    (Ecast
                                                      (Ebinop Omul
                                                        (Econst_int (Int.repr 4) tint)
                                                        (Econst_int (Int.repr 10) tint)
                                                        tint) tuint)
                                                    (Ebinop Osub
                                                      (Ebinop Oshl
                                                        (Econst_int (Int.repr 1) tint)
                                                        (Econst_int (Int.repr 8) tint)
                                                        tint)
                                                      (Econst_int (Int.repr 1) tint)
                                                      tint) tuint)
                                                  (Econst_int (Int.repr 8) tint)
                                                  tuint) tuint) tuint)
                                            (Ecast
                                              (Ebinop Oshl
                                                (Ebinop Oand
                                                  (Ecast
                                                    (Ebinop Omul
                                                      (Econst_int (Int.repr 5) tint)
                                                      (Econst_int (Int.repr 10) tint)
                                                      tint) tuint)
                                                  (Ebinop Osub
                                                    (Ebinop Oshl
                                                      (Econst_int (Int.repr 1) tint)
                                                      (Econst_int (Int.repr 8) tint)
                                                      tint)
                                                    (Econst_int (Int.repr 1) tint)
                                                    tint) tuint)
                                                (Econst_int (Int.repr 0) tint)
                                                tuint) tuint) tuint))))
                                    (Ssequence
                                      (Ssequence
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'8
                                              (Etempvar _gfx (tptr (Tunion __512 noattr))))
                                            (Sset _gfx
                                              (Ebinop Oadd
                                                (Etempvar _t'8 (tptr (Tunion __512 noattr)))
                                                (Econst_int (Int.repr 1) tint)
                                                (tptr (Tunion __512 noattr)))))
                                          (Sset __g__4
                                            (Ecast
                                              (Etempvar _t'8 (tptr (Tunion __512 noattr)))
                                              (tptr (Tunion __512 noattr)))))
                                        (Ssequence
                                          (Sassign
                                            (Efield
                                              (Efield
                                                (Ederef
                                                  (Etempvar __g__4 (tptr (Tunion __512 noattr)))
                                                  (Tunion __512 noattr))
                                                _words
                                                (Tstruct __510 noattr)) _w0
                                              tuint)
                                            (Ecast
                                              (Ebinop Oshl
                                                (Ebinop Oand
                                                  (Ecast
                                                    (Ebinop Osub
                                                      (Eunop Oneg
                                                        (Econst_int (Int.repr 65) tint)
                                                        tint)
                                                      (Econst_int (Int.repr 0) tint)
                                                      tint) tuint)
                                                  (Ebinop Osub
                                                    (Ebinop Oshl
                                                      (Econst_int (Int.repr 1) tint)
                                                      (Econst_int (Int.repr 8) tint)
                                                      tint)
                                                    (Econst_int (Int.repr 1) tint)
                                                    tint) tuint)
                                                (Econst_int (Int.repr 24) tint)
                                                tuint) tuint))
                                          (Sassign
                                            (Efield
                                              (Efield
                                                (Ederef
                                                  (Etempvar __g__4 (tptr (Tunion __512 noattr)))
                                                  (Tunion __512 noattr))
                                                _words
                                                (Tstruct __510 noattr)) _w1
                                              tuint)
                                            (Ebinop Oor
                                              (Ebinop Oor
                                                (Ebinop Oor
                                                  (Ecast
                                                    (Ebinop Oshl
                                                      (Ebinop Oand
                                                        (Ecast
                                                          (Econst_int (Int.repr 0) tint)
                                                          tuint)
                                                        (Ebinop Osub
                                                          (Ebinop Oshl
                                                            (Econst_int (Int.repr 1) tint)
                                                            (Econst_int (Int.repr 8) tint)
                                                            tint)
                                                          (Econst_int (Int.repr 1) tint)
                                                          tint) tuint)
                                                      (Econst_int (Int.repr 24) tint)
                                                      tuint) tuint)
                                                  (Ecast
                                                    (Ebinop Oshl
                                                      (Ebinop Oand
                                                        (Ecast
                                                          (Ebinop Omul
                                                            (Econst_int (Int.repr 6) tint)
                                                            (Econst_int (Int.repr 10) tint)
                                                            tint) tuint)
                                                        (Ebinop Osub
                                                          (Ebinop Oshl
                                                            (Econst_int (Int.repr 1) tint)
                                                            (Econst_int (Int.repr 8) tint)
                                                            tint)
                                                          (Econst_int (Int.repr 1) tint)
                                                          tint) tuint)
                                                      (Econst_int (Int.repr 16) tint)
                                                      tuint) tuint) tuint)
                                                (Ecast
                                                  (Ebinop Oshl
                                                    (Ebinop Oand
                                                      (Ecast
                                                        (Ebinop Omul
                                                          (Econst_int (Int.repr 7) tint)
                                                          (Econst_int (Int.repr 10) tint)
                                                          tint) tuint)
                                                      (Ebinop Osub
                                                        (Ebinop Oshl
                                                          (Econst_int (Int.repr 1) tint)
                                                          (Econst_int (Int.repr 8) tint)
                                                          tint)
                                                        (Econst_int (Int.repr 1) tint)
                                                        tint) tuint)
                                                    (Econst_int (Int.repr 8) tint)
                                                    tuint) tuint) tuint)
                                              (Ecast
                                                (Ebinop Oshl
                                                  (Ebinop Oand
                                                    (Ecast
                                                      (Ebinop Omul
                                                        (Econst_int (Int.repr 8) tint)
                                                        (Econst_int (Int.repr 10) tint)
                                                        tint) tuint)
                                                    (Ebinop Osub
                                                      (Ebinop Oshl
                                                        (Econst_int (Int.repr 1) tint)
                                                        (Econst_int (Int.repr 8) tint)
                                                        tint)
                                                      (Econst_int (Int.repr 1) tint)
                                                      tint) tuint)
                                                  (Econst_int (Int.repr 0) tint)
                                                  tuint) tuint) tuint))))
                                      (Ssequence
                                        (Ssequence
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'9
                                                (Etempvar _gfx (tptr (Tunion __512 noattr))))
                                              (Sset _gfx
                                                (Ebinop Oadd
                                                  (Etempvar _t'9 (tptr (Tunion __512 noattr)))
                                                  (Econst_int (Int.repr 1) tint)
                                                  (tptr (Tunion __512 noattr)))))
                                            (Sset __g__5
                                              (Ecast
                                                (Etempvar _t'9 (tptr (Tunion __512 noattr)))
                                                (tptr (Tunion __512 noattr)))))
                                          (Ssequence
                                            (Sassign
                                              (Efield
                                                (Efield
                                                  (Ederef
                                                    (Etempvar __g__5 (tptr (Tunion __512 noattr)))
                                                    (Tunion __512 noattr))
                                                  _words
                                                  (Tstruct __510 noattr)) _w0
                                                tuint)
                                              (Ecast
                                                (Ebinop Oshl
                                                  (Ebinop Oand
                                                    (Ecast
                                                      (Ebinop Osub
                                                        (Eunop Oneg
                                                          (Econst_int (Int.repr 65) tint)
                                                          tint)
                                                        (Econst_int (Int.repr 0) tint)
                                                        tint) tuint)
                                                    (Ebinop Osub
                                                      (Ebinop Oshl
                                                        (Econst_int (Int.repr 1) tint)
                                                        (Econst_int (Int.repr 8) tint)
                                                        tint)
                                                      (Econst_int (Int.repr 1) tint)
                                                      tint) tuint)
                                                  (Econst_int (Int.repr 24) tint)
                                                  tuint) tuint))
                                            (Sassign
                                              (Efield
                                                (Efield
                                                  (Ederef
                                                    (Etempvar __g__5 (tptr (Tunion __512 noattr)))
                                                    (Tunion __512 noattr))
                                                  _words
                                                  (Tstruct __510 noattr)) _w1
                                                tuint)
                                              (Ebinop Oor
                                                (Ebinop Oor
                                                  (Ebinop Oor
                                                    (Ecast
                                                      (Ebinop Oshl
                                                        (Ebinop Oand
                                                          (Ecast
                                                            (Econst_int (Int.repr 0) tint)
                                                            tuint)
                                                          (Ebinop Osub
                                                            (Ebinop Oshl
                                                              (Econst_int (Int.repr 1) tint)
                                                              (Econst_int (Int.repr 8) tint)
                                                              tint)
                                                            (Econst_int (Int.repr 1) tint)
                                                            tint) tuint)
                                                        (Econst_int (Int.repr 24) tint)
                                                        tuint) tuint)
                                                    (Ecast
                                                      (Ebinop Oshl
                                                        (Ebinop Oand
                                                          (Ecast
                                                            (Ebinop Omul
                                                              (Econst_int (Int.repr 9) tint)
                                                              (Econst_int (Int.repr 10) tint)
                                                              tint) tuint)
                                                          (Ebinop Osub
                                                            (Ebinop Oshl
                                                              (Econst_int (Int.repr 1) tint)
                                                              (Econst_int (Int.repr 8) tint)
                                                              tint)
                                                            (Econst_int (Int.repr 1) tint)
                                                            tint) tuint)
                                                        (Econst_int (Int.repr 16) tint)
                                                        tuint) tuint) tuint)
                                                  (Ecast
                                                    (Ebinop Oshl
                                                      (Ebinop Oand
                                                        (Ecast
                                                          (Ebinop Omul
                                                            (Econst_int (Int.repr 10) tint)
                                                            (Econst_int (Int.repr 10) tint)
                                                            tint) tuint)
                                                        (Ebinop Osub
                                                          (Ebinop Oshl
                                                            (Econst_int (Int.repr 1) tint)
                                                            (Econst_int (Int.repr 8) tint)
                                                            tint)
                                                          (Econst_int (Int.repr 1) tint)
                                                          tint) tuint)
                                                      (Econst_int (Int.repr 8) tint)
                                                      tuint) tuint) tuint)
                                                (Ecast
                                                  (Ebinop Oshl
                                                    (Ebinop Oand
                                                      (Ecast
                                                        (Ebinop Omul
                                                          (Econst_int (Int.repr 11) tint)
                                                          (Econst_int (Int.repr 10) tint)
                                                          tint) tuint)
                                                      (Ebinop Osub
                                                        (Ebinop Oshl
                                                          (Econst_int (Int.repr 1) tint)
                                                          (Econst_int (Int.repr 8) tint)
                                                          tint)
                                                        (Econst_int (Int.repr 1) tint)
                                                        tint) tuint)
                                                    (Econst_int (Int.repr 0) tint)
                                                    tuint) tuint) tuint))))
                                        (Ssequence
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'10
                                                (Etempvar _gfx (tptr (Tunion __512 noattr))))
                                              (Sset _gfx
                                                (Ebinop Oadd
                                                  (Etempvar _t'10 (tptr (Tunion __512 noattr)))
                                                  (Econst_int (Int.repr 1) tint)
                                                  (tptr (Tunion __512 noattr)))))
                                            (Sset __g__6
                                              (Ecast
                                                (Etempvar _t'10 (tptr (Tunion __512 noattr)))
                                                (tptr (Tunion __512 noattr)))))
                                          (Ssequence
                                            (Sassign
                                              (Efield
                                                (Efield
                                                  (Ederef
                                                    (Etempvar __g__6 (tptr (Tunion __512 noattr)))
                                                    (Tunion __512 noattr))
                                                  _words
                                                  (Tstruct __510 noattr)) _w0
                                                tuint)
                                              (Ecast
                                                (Ebinop Oshl
                                                  (Ebinop Oand
                                                    (Ecast
                                                      (Ebinop Osub
                                                        (Eunop Oneg
                                                          (Econst_int (Int.repr 65) tint)
                                                          tint)
                                                        (Econst_int (Int.repr 0) tint)
                                                        tint) tuint)
                                                    (Ebinop Osub
                                                      (Ebinop Oshl
                                                        (Econst_int (Int.repr 1) tint)
                                                        (Econst_int (Int.repr 8) tint)
                                                        tint)
                                                      (Econst_int (Int.repr 1) tint)
                                                      tint) tuint)
                                                  (Econst_int (Int.repr 24) tint)
                                                  tuint) tuint))
                                            (Sassign
                                              (Efield
                                                (Efield
                                                  (Ederef
                                                    (Etempvar __g__6 (tptr (Tunion __512 noattr)))
                                                    (Tunion __512 noattr))
                                                  _words
                                                  (Tstruct __510 noattr)) _w1
                                                tuint)
                                              (Ebinop Oor
                                                (Ebinop Oor
                                                  (Ebinop Oor
                                                    (Ecast
                                                      (Ebinop Oshl
                                                        (Ebinop Oand
                                                          (Ecast
                                                            (Econst_int (Int.repr 0) tint)
                                                            tuint)
                                                          (Ebinop Osub
                                                            (Ebinop Oshl
                                                              (Econst_int (Int.repr 1) tint)
                                                              (Econst_int (Int.repr 8) tint)
                                                              tint)
                                                            (Econst_int (Int.repr 1) tint)
                                                            tint) tuint)
                                                        (Econst_int (Int.repr 24) tint)
                                                        tuint) tuint)
                                                    (Ecast
                                                      (Ebinop Oshl
                                                        (Ebinop Oand
                                                          (Ecast
                                                            (Ebinop Omul
                                                              (Econst_int (Int.repr 12) tint)
                                                              (Econst_int (Int.repr 10) tint)
                                                              tint) tuint)
                                                          (Ebinop Osub
                                                            (Ebinop Oshl
                                                              (Econst_int (Int.repr 1) tint)
                                                              (Econst_int (Int.repr 8) tint)
                                                              tint)
                                                            (Econst_int (Int.repr 1) tint)
                                                            tint) tuint)
                                                        (Econst_int (Int.repr 16) tint)
                                                        tuint) tuint) tuint)
                                                  (Ecast
                                                    (Ebinop Oshl
                                                      (Ebinop Oand
                                                        (Ecast
                                                          (Ebinop Omul
                                                            (Econst_int (Int.repr 13) tint)
                                                            (Econst_int (Int.repr 10) tint)
                                                            tint) tuint)
                                                        (Ebinop Osub
                                                          (Ebinop Oshl
                                                            (Econst_int (Int.repr 1) tint)
                                                            (Econst_int (Int.repr 8) tint)
                                                            tint)
                                                          (Econst_int (Int.repr 1) tint)
                                                          tint) tuint)
                                                      (Econst_int (Int.repr 8) tint)
                                                      tuint) tuint) tuint)
                                                (Ecast
                                                  (Ebinop Oshl
                                                    (Ebinop Oand
                                                      (Ecast
                                                        (Ebinop Omul
                                                          (Econst_int (Int.repr 14) tint)
                                                          (Econst_int (Int.repr 10) tint)
                                                          tint) tuint)
                                                      (Ebinop Osub
                                                        (Ebinop Oshl
                                                          (Econst_int (Int.repr 1) tint)
                                                          (Econst_int (Int.repr 8) tint)
                                                          tint)
                                                        (Econst_int (Int.repr 1) tint)
                                                        tint) tuint)
                                                    (Econst_int (Int.repr 0) tint)
                                                    tuint) tuint) tuint))))))))))
                            (Sset _i
                              (Ebinop Oadd (Etempvar _i tint)
                                (Econst_int (Int.repr 5) tint) tint))))
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Sset _t'11
                                  (Etempvar _gfx (tptr (Tunion __512 noattr))))
                                (Sset _gfx
                                  (Ebinop Oadd
                                    (Etempvar _t'11 (tptr (Tunion __512 noattr)))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr (Tunion __512 noattr)))))
                              (Sset __g__7
                                (Ecast
                                  (Etempvar _t'11 (tptr (Tunion __512 noattr)))
                                  (tptr (Tunion __512 noattr)))))
                            (Ssequence
                              (Sassign
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar __g__7 (tptr (Tunion __512 noattr)))
                                      (Tunion __512 noattr)) _words
                                    (Tstruct __510 noattr)) _w0 tuint)
                                (Ebinop Oor
                                  (Ebinop Oor
                                    (Ecast
                                      (Ebinop Oshl
                                        (Ebinop Oand
                                          (Ecast
                                            (Econst_int (Int.repr 6) tint)
                                            tuint)
                                          (Ebinop Osub
                                            (Ebinop Oshl
                                              (Econst_int (Int.repr 1) tint)
                                              (Econst_int (Int.repr 8) tint)
                                              tint)
                                            (Econst_int (Int.repr 1) tint)
                                            tint) tuint)
                                        (Econst_int (Int.repr 24) tint)
                                        tuint) tuint)
                                    (Ecast
                                      (Ebinop Oshl
                                        (Ebinop Oand
                                          (Ecast
                                            (Econst_int (Int.repr 0) tint)
                                            tuint)
                                          (Ebinop Osub
                                            (Ebinop Oshl
                                              (Econst_int (Int.repr 1) tint)
                                              (Econst_int (Int.repr 8) tint)
                                              tint)
                                            (Econst_int (Int.repr 1) tint)
                                            tint) tuint)
                                        (Econst_int (Int.repr 16) tint)
                                        tuint) tuint) tuint)
                                  (Ecast
                                    (Ebinop Oshl
                                      (Ebinop Oand
                                        (Ecast (Econst_int (Int.repr 0) tint)
                                          tuint)
                                        (Ebinop Osub
                                          (Ebinop Oshl
                                            (Econst_int (Int.repr 1) tint)
                                            (Econst_int (Int.repr 16) tint)
                                            tint)
                                          (Econst_int (Int.repr 1) tint)
                                          tint) tuint)
                                      (Econst_int (Int.repr 0) tint) tuint)
                                    tuint) tuint))
                              (Sassign
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar __g__7 (tptr (Tunion __512 noattr)))
                                      (Tunion __512 noattr)) _words
                                    (Tstruct __510 noattr)) _w1 tuint)
                                (Ecast
                                  (Eaddrof
                                    (Evar _tiny_bubble_dl_0B006AB0 (tptr tvoid))
                                    (tptr (tptr tvoid))) tuint))))
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Ssequence
                                  (Sset _t'12
                                    (Etempvar _gfx (tptr (Tunion __512 noattr))))
                                  (Sset _gfx
                                    (Ebinop Oadd
                                      (Etempvar _t'12 (tptr (Tunion __512 noattr)))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr (Tunion __512 noattr)))))
                                (Sset __g__8
                                  (Ecast
                                    (Etempvar _t'12 (tptr (Tunion __512 noattr)))
                                    (tptr (Tunion __512 noattr)))))
                              (Ssequence
                                (Sassign
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar __g__8 (tptr (Tunion __512 noattr)))
                                        (Tunion __512 noattr)) _words
                                      (Tstruct __510 noattr)) _w0 tuint)
                                  (Ecast
                                    (Ebinop Oshl
                                      (Ebinop Oand
                                        (Ecast
                                          (Ebinop Osub
                                            (Eunop Oneg
                                              (Econst_int (Int.repr 65) tint)
                                              tint)
                                            (Econst_int (Int.repr 7) tint)
                                            tint) tuint)
                                        (Ebinop Osub
                                          (Ebinop Oshl
                                            (Econst_int (Int.repr 1) tint)
                                            (Econst_int (Int.repr 8) tint)
                                            tint)
                                          (Econst_int (Int.repr 1) tint)
                                          tint) tuint)
                                      (Econst_int (Int.repr 24) tint) tuint)
                                    tuint))
                                (Sassign
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar __g__8 (tptr (Tunion __512 noattr)))
                                        (Tunion __512 noattr)) _words
                                      (Tstruct __510 noattr)) _w1 tuint)
                                  (Econst_int (Int.repr 0) tint))))
                            (Sreturn (Some (Etempvar _gfxStart (tptr (Tunion __512 noattr)))))))))))))))))))
|}.

Definition f_envfx_update_particles := {|
  fn_return := (tptr (Tunion __512 noattr));
  fn_callconv := cc_default;
  fn_params := ((_mode, tint) :: (_marioPos, (tptr tshort)) ::
                (_camTo, (tptr tshort)) :: (_camFrom, (tptr tshort)) :: nil);
  fn_vars := nil;
  fn_temps := ((_gfx, (tptr (Tunion __512 noattr))) ::
               (_t'8, (tptr (Tunion __512 noattr))) ::
               (_t'7, (tptr (Tunion __512 noattr))) ::
               (_t'6, (tptr (Tunion __512 noattr))) :: (_t'5, tint) ::
               (_t'4, tint) :: (_t'3, (tptr (Tunion __512 noattr))) ::
               (_t'2, tint) :: (_t'1, tshort) :: (_t'12, tschar) ::
               (_t'11, tschar) :: (_t'10, tschar) ::
               (_t'9, (tptr (Tstruct _EnvFxParticle noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _get_dialog_id (Tfunction nil tshort cc_default)) nil)
    (Sifthenelse (Ebinop One (Etempvar _t'1 tshort)
                   (Econst_int (Int.repr (-1)) tint) tint)
      (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
      Sskip))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'11 (Evar _gEnvFxMode tschar))
        (Sifthenelse (Ebinop One (Etempvar _t'11 tschar)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Sset _t'12 (Evar _gEnvFxMode tschar))
            (Sset _t'2
              (Ecast
                (Ebinop One (Etempvar _t'12 tschar) (Etempvar _mode tint)
                  tint) tbool)))
          (Sset _t'2 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'2 tint)
        (Sset _mode (Econst_int (Int.repr 0) tint))
        Sskip))
    (Ssequence
      (Sifthenelse (Ebinop Oge (Etempvar _mode tint)
                     (Econst_int (Int.repr 10) tint) tint)
        (Ssequence
          (Ssequence
            (Scall (Some _t'3)
              (Evar _envfx_update_bubbles (Tfunction
                                            (tint :: (tptr tshort) ::
                                             (tptr tshort) ::
                                             (tptr tshort) :: nil)
                                            (tptr (Tunion __512 noattr))
                                            cc_default))
              ((Etempvar _mode tint) :: (Etempvar _marioPos (tptr tshort)) ::
               (Etempvar _camTo (tptr tshort)) ::
               (Etempvar _camFrom (tptr tshort)) :: nil))
            (Sset _gfx (Etempvar _t'3 (tptr (Tunion __512 noattr)))))
          (Sreturn (Some (Etempvar _gfx (tptr (Tunion __512 noattr))))))
        Sskip)
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'10 (Evar _gEnvFxMode tschar))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'10 tschar)
                           (Econst_int (Int.repr 0) tint) tint)
              (Ssequence
                (Scall (Some _t'5)
                  (Evar _envfx_init_snow (Tfunction (tint :: nil) tint
                                           cc_default))
                  ((Etempvar _mode tint) :: nil))
                (Sset _t'4
                  (Ecast (Eunop Onotbool (Etempvar _t'5 tint) tint) tbool)))
              (Sset _t'4 (Econst_int (Int.repr 0) tint))))
          (Sifthenelse (Etempvar _t'4 tint)
            (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint)
                             (tptr tvoid))))
            Sskip))
        (Ssequence
          (Sswitch (Etempvar _mode tint)
            (LScons (Some 0)
              (Ssequence
                (Ssequence
                  (Sset _t'9
                    (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                  (Scall None
                    (Evar _envfx_cleanup_snow (Tfunction
                                                ((tptr tvoid) :: nil) tvoid
                                                cc_default))
                    ((Etempvar _t'9 (tptr (Tstruct _EnvFxParticle noattr))) ::
                     nil)))
                (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint)
                                 (tptr tvoid)))))
              (LScons (Some 1)
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'6)
                      (Evar _envfx_update_snow (Tfunction
                                                 (tint :: (tptr tshort) ::
                                                  (tptr tshort) ::
                                                  (tptr tshort) :: nil)
                                                 (tptr (Tunion __512 noattr))
                                                 cc_default))
                      ((Econst_int (Int.repr 1) tint) ::
                       (Etempvar _marioPos (tptr tshort)) ::
                       (Etempvar _camFrom (tptr tshort)) ::
                       (Etempvar _camTo (tptr tshort)) :: nil))
                    (Sset _gfx (Etempvar _t'6 (tptr (Tunion __512 noattr)))))
                  Sbreak)
                (LScons (Some 2)
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'7)
                        (Evar _envfx_update_snow (Tfunction
                                                   (tint :: (tptr tshort) ::
                                                    (tptr tshort) ::
                                                    (tptr tshort) :: nil)
                                                   (tptr (Tunion __512 noattr))
                                                   cc_default))
                        ((Econst_int (Int.repr 2) tint) ::
                         (Etempvar _marioPos (tptr tshort)) ::
                         (Etempvar _camFrom (tptr tshort)) ::
                         (Etempvar _camTo (tptr tshort)) :: nil))
                      (Sset _gfx
                        (Etempvar _t'7 (tptr (Tunion __512 noattr)))))
                    Sbreak)
                  (LScons (Some 3)
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'8)
                          (Evar _envfx_update_snow (Tfunction
                                                     (tint ::
                                                      (tptr tshort) ::
                                                      (tptr tshort) ::
                                                      (tptr tshort) :: nil)
                                                     (tptr (Tunion __512 noattr))
                                                     cc_default))
                          ((Econst_int (Int.repr 3) tint) ::
                           (Etempvar _marioPos (tptr tshort)) ::
                           (Etempvar _camFrom (tptr tshort)) ::
                           (Etempvar _camTo (tptr tshort)) :: nil))
                        (Sset _gfx
                          (Etempvar _t'8 (tptr (Tunion __512 noattr)))))
                      Sbreak)
                    (LScons None
                      (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint)
                                       (tptr tvoid))))
                      LSnil))))))
          (Sreturn (Some (Etempvar _gfx (tptr (Tunion __512 noattr))))))))))
|}.

Definition composites : list composite_definition :=
(Composite __459 Struct
   (Member_plain _ob (tarray tshort 3) :: Member_plain _flag tushort ::
    Member_plain _tc (tarray tshort 2) ::
    Member_plain _cn (tarray tuchar 4) :: nil)
   noattr ::
 Composite __461 Struct
   (Member_plain _ob (tarray tshort 3) :: Member_plain _flag tushort ::
    Member_plain _tc (tarray tshort 2) ::
    Member_plain _n (tarray tschar 3) :: Member_plain _a tuchar :: nil)
   noattr ::
 Composite __463 Union
   (Member_plain _v (Tstruct __459 noattr) ::
    Member_plain _n (Tstruct __461 noattr) ::
    Member_plain _force_structure_alignment tlong :: nil)
   noattr ::
 Composite __510 Struct
   (Member_plain _w0 tuint :: Member_plain _w1 tuint :: nil)
   noattr ::
 Composite __512 Union
   (Member_plain _words (Tstruct __510 noattr) ::
    Member_plain _force_structure_alignment tlong :: nil)
   noattr ::
 Composite _EnvFxParticle Struct
   (Member_plain _isAlive tschar :: Member_plain _animFrame tshort ::
    Member_plain _xPos tint :: Member_plain _yPos tint ::
    Member_plain _zPos tint :: Member_plain _angleAndDist (tarray tint 2) ::
    Member_plain _unusedBubbleVar tint :: Member_plain _bubbleY tint ::
    Member_plain _filler (tarray tuchar 24) :: nil)
   noattr ::
 Composite _SnowFlakeVertex Struct
   (Member_plain _x tshort :: Member_plain _y tshort ::
    Member_plain _z tshort :: nil)
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
 (_sqrtf,
   Gfun(External (EF_external "sqrtf"
                   (mksignature (AST.Xsingle :: nil) AST.Xsingle cc_default))
     (tfloat :: nil) tfloat cc_default)) ::
 (_bzero,
   Gfun(External (EF_external "bzero"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default)) ((tptr tvoid) :: tuint :: nil) tvoid
     cc_default)) :: (_gEffectsMemoryPool, Gvar v_gEffectsMemoryPool) ::
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
 (_gGlobalTimer, Gvar v_gGlobalTimer) ::
 (_get_dialog_id,
   Gfun(External (EF_external "get_dialog_id"
                   (mksignature nil AST.Xint16signed cc_default)) nil tshort
     cc_default)) ::
 (_envfx_update_bubbles,
   Gfun(External (EF_external "envfx_update_bubbles"
                   (mksignature
                     (AST.Xint :: AST.Xptr :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xptr cc_default))
     (tint :: (tptr tshort) :: (tptr tshort) :: (tptr tshort) :: nil)
     (tptr (Tunion __512 noattr)) cc_default)) ::
 (_find_water_level,
   Gfun(External (EF_external "find_water_level"
                   (mksignature (AST.Xsingle :: AST.Xsingle :: nil)
                     AST.Xsingle cc_default)) (tfloat :: tfloat :: nil)
     tfloat cc_default)) :: (_gSineTable, Gvar v_gSineTable) ::
 (_atan2s,
   Gfun(External (EF_external "atan2s"
                   (mksignature (AST.Xsingle :: AST.Xsingle :: nil)
                     AST.Xint16signed cc_default)) (tfloat :: tfloat :: nil)
     tshort cc_default)) ::
 (_random_float,
   Gfun(External (EF_external "random_float"
                   (mksignature nil AST.Xsingle cc_default)) nil tfloat
     cc_default)) :: (_gEnvFxBuffer, Gvar v_gEnvFxBuffer) ::
 (_gSnowCylinderLastPos, Gvar v_gSnowCylinderLastPos) ::
 (_gSnowParticleCount, Gvar v_gSnowParticleCount) ::
 (_gSnowParticleMaxCount, Gvar v_gSnowParticleMaxCount) ::
 (_gEnvFxMode, Gvar v_gEnvFxMode) :: (_D_80330644, Gvar v_D_80330644) ::
 (_gSnowTempVtx, Gvar v_gSnowTempVtx) ::
 (_gSnowFlakeVertex1, Gvar v_gSnowFlakeVertex1) ::
 (_gSnowFlakeVertex2, Gvar v_gSnowFlakeVertex2) ::
 (_gSnowFlakeVertex3, Gvar v_gSnowFlakeVertex3) ::
 (_tiny_bubble_dl_0B006AB0, Gvar v_tiny_bubble_dl_0B006AB0) ::
 (_tiny_bubble_dl_0B006A50, Gvar v_tiny_bubble_dl_0B006A50) ::
 (_tiny_bubble_dl_0B006CD8, Gvar v_tiny_bubble_dl_0B006CD8) ::
 (_envfx_init_snow, Gfun(Internal f_envfx_init_snow)) ::
 (_envfx_update_snowflake_count, Gfun(Internal f_envfx_update_snowflake_count)) ::
 (_envfx_cleanup_snow, Gfun(Internal f_envfx_cleanup_snow)) ::
 (_orbit_from_positions, Gfun(Internal f_orbit_from_positions)) ::
 (_pos_from_orbit, Gfun(Internal f_pos_from_orbit)) ::
 (_envfx_is_snowflake_alive, Gfun(Internal f_envfx_is_snowflake_alive)) ::
 (_envfx_update_snow_normal, Gfun(Internal f_envfx_update_snow_normal)) ::
 (_envfx_update_snow_blizzard, Gfun(Internal f_envfx_update_snow_blizzard)) ::
 (_envfx_update_snow_water, Gfun(Internal f_envfx_update_snow_water)) ::
 (_rotate_triangle_vertices, Gfun(Internal f_rotate_triangle_vertices)) ::
 (_append_snowflake_vertex_buffer, Gfun(Internal f_append_snowflake_vertex_buffer)) ::
 (_envfx_update_snow, Gfun(Internal f_envfx_update_snow)) ::
 (_envfx_update_particles, Gfun(Internal f_envfx_update_particles)) :: nil).

Definition public_idents : list ident :=
(_envfx_update_particles :: _envfx_update_snow ::
 _append_snowflake_vertex_buffer :: _rotate_triangle_vertices ::
 _envfx_update_snow_water :: _envfx_update_snow_blizzard ::
 _envfx_update_snow_normal :: _envfx_is_snowflake_alive :: _pos_from_orbit ::
 _orbit_from_positions :: _envfx_cleanup_snow ::
 _envfx_update_snowflake_count :: _envfx_init_snow ::
 _tiny_bubble_dl_0B006CD8 :: _tiny_bubble_dl_0B006A50 ::
 _tiny_bubble_dl_0B006AB0 :: _gSnowFlakeVertex3 :: _gSnowFlakeVertex2 ::
 _gSnowFlakeVertex1 :: _gSnowTempVtx :: _D_80330644 :: _gEnvFxMode ::
 _gSnowParticleMaxCount :: _gSnowParticleCount :: _gSnowCylinderLastPos ::
 _gEnvFxBuffer :: _random_float :: _atan2s :: _gSineTable ::
 _find_water_level :: _envfx_update_bubbles :: _get_dialog_id ::
 _gGlobalTimer :: _alloc_display_list :: _mem_pool_free :: _mem_pool_alloc ::
 _gEffectsMemoryPool :: _bzero :: _sqrtf :: ___builtin_debug ::
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
