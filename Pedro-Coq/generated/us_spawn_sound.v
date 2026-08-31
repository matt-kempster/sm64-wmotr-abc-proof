(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_US
   Source:          src/game/spawn_sound.c
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1
   Link hygiene:    private __stringlit_N atoms prefixed with us_spawn_sound
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
  Definition source_file := "build/pinned-sm64/src/game/spawn_sound.c".
  Definition normalized := true.
End Info.

Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _GraphNode : ident := $"GraphNode".
Definition _GraphNodeObject : ident := $"GraphNodeObject".
Definition _Object : ident := $"Object".
Definition _ObjectNode : ident := $"ObjectNode".
Definition _SoundState : ident := $"SoundState".
Definition _SpawnInfo : ident := $"SpawnInfo".
Definition _Surface : ident := $"Surface".
Definition _Waypoint : ident := $"Waypoint".
Definition __764 : ident := $"_764".
Definition __769 : ident := $"_769".
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
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _angle : ident := $"angle".
Definition _animAccel : ident := $"animAccel".
Definition _animFrame : ident := $"animFrame".
Definition _animFrame1 : ident := $"animFrame1".
Definition _animFrame2 : ident := $"animFrame2".
Definition _animFrameAccelAssist : ident := $"animFrameAccelAssist".
Definition _animID : ident := $"animID".
Definition _animInfo : ident := $"animInfo".
Definition _animTimer : ident := $"animTimer".
Definition _animYTrans : ident := $"animYTrans".
Definition _animYTransDivisor : ident := $"animYTransDivisor".
Definition _areaIndex : ident := $"areaIndex".
Definition _asAnims : ident := $"asAnims".
Definition _asChainSegment : ident := $"asChainSegment".
Definition _asConstVoidPtr : ident := $"asConstVoidPtr".
Definition _asF32 : ident := $"asF32".
Definition _asObject : ident := $"asObject".
Definition _asS16 : ident := $"asS16".
Definition _asS16P : ident := $"asS16P".
Definition _asS32 : ident := $"asS32".
Definition _asS32P : ident := $"asS32P".
Definition _asSurface : ident := $"asSurface".
Definition _asU32 : ident := $"asU32".
Definition _asVoidPtr : ident := $"asVoidPtr".
Definition _asWaypoint : ident := $"asWaypoint".
Definition _behavior : ident := $"behavior".
Definition _behaviorArg : ident := $"behaviorArg".
Definition _behaviorScript : ident := $"behaviorScript".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvSoundSpawner : ident := $"bhvSoundSpawner".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _calc_dist_to_volume_range_1 : ident := $"calc_dist_to_volume_range_1".
Definition _calc_dist_to_volume_range_2 : ident := $"calc_dist_to_volume_range_2".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _children : ident := $"children".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _create_sound_spawner : ident := $"create_sound_spawner".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _cur_obj_check_anim_frame : ident := $"cur_obj_check_anim_frame".
Definition _cur_obj_play_sound_1 : ident := $"cur_obj_play_sound_1".
Definition _cur_obj_play_sound_2 : ident := $"cur_obj_play_sound_2".
Definition _distance : ident := $"distance".
Definition _exec_anim_sound_state : ident := $"exec_anim_sound_state".
Definition _flags : ident := $"flags".
Definition _force : ident := $"force".
Definition _gCurrentObject : ident := $"gCurrentObject".
Definition _gfx : ident := $"gfx".
Definition _header : ident := $"header".
Definition _hitboxDownOffset : ident := $"hitboxDownOffset".
Definition _hitboxHeight : ident := $"hitboxHeight".
Definition _hitboxRadius : ident := $"hitboxRadius".
Definition _hurtboxHeight : ident := $"hurtboxHeight".
Definition _hurtboxRadius : ident := $"hurtboxRadius".
Definition _index : ident := $"index".
Definition _length : ident := $"length".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _main : ident := $"main".
Definition _model : ident := $"model".
Definition _next : ident := $"next".
Definition _node : ident := $"node".
Definition _normal : ident := $"normal".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _obj : ident := $"obj".
Definition _object : ident := $"object".
Definition _originOffset : ident := $"originOffset".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _pitch : ident := $"pitch".
Definition _platform : ident := $"platform".
Definition _playSound : ident := $"playSound".
Definition _play_sound : ident := $"play_sound".
Definition _pos : ident := $"pos".
Definition _posX : ident := $"posX".
Definition _posY : ident := $"posY".
Definition _posZ : ident := $"posZ".
Definition _prev : ident := $"prev".
Definition _prevObj : ident := $"prevObj".
Definition _rawData : ident := $"rawData".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _roll : ident := $"roll".
Definition _room : ident := $"room".
Definition _scale : ident := $"scale".
Definition _sharedChild : ident := $"sharedChild".
Definition _soundMagic : ident := $"soundMagic".
Definition _soundStates : ident := $"soundStates".
Definition _spawn_object : ident := $"spawn_object".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
Definition _stateIdx : ident := $"stateIdx".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _transform : ident := $"transform".
Definition _type : ident := $"type".
Definition _unk4C : ident := $"unk4C".
Definition _unused1 : ident := $"unused1".
Definition _unused2 : ident := $"unused2".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _upperY : ident := $"upperY".
Definition _values : ident := $"values".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _volume : ident := $"volume".
Definition _x : ident := $"x".
Definition _y : ident := $"y".
Definition _yaw : ident := $"yaw".
Definition _z : ident := $"z".
Definition _t'1 : ident := 128%positive.
Definition _t'10 : ident := 137%positive.
Definition _t'2 : ident := 129%positive.
Definition _t'3 : ident := 130%positive.
Definition _t'4 : ident := 131%positive.
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v_bhvSoundSpawner := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_gCurrentObject := {|
  gvar_info := (tptr (Tstruct _Object noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_exec_anim_sound_state := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_soundStates, (tptr (Tstruct _SoundState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_stateIdx, tint) :: (_animFrame, tint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tschar) ::
               (_t'8, tint) :: (_t'7, tschar) :: (_t'6, tint) ::
               (_t'5, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'10 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
    (Sset _stateIdx
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Ederef (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
            _asS32 (tarray tint 80)) (Econst_int (Int.repr 60) tint)
          (tptr tint)) tint)))
  (Ssequence
    (Sset _t'5
      (Efield
        (Ederef
          (Ebinop Oadd
            (Etempvar _soundStates (tptr (Tstruct _SoundState noattr)))
            (Etempvar _stateIdx tint) (tptr (Tstruct _SoundState noattr)))
          (Tstruct _SoundState noattr)) _playSound tshort))
    (Sswitch (Etempvar _t'5 tshort)
      (LScons (Some 0)
        Sbreak
        (LScons (Some 1)
          (Ssequence
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'9
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Etempvar _soundStates (tptr (Tstruct _SoundState noattr)))
                          (Etempvar _stateIdx tint)
                          (tptr (Tstruct _SoundState noattr)))
                        (Tstruct _SoundState noattr)) _animFrame1 tschar))
                  (Sset _t'2 (Ecast (Etempvar _t'9 tschar) tint)))
                (Sset _animFrame (Etempvar _t'2 tint)))
              (Sifthenelse (Ebinop Oge (Etempvar _t'2 tint)
                             (Econst_int (Int.repr 0) tint) tint)
                (Ssequence
                  (Scall (Some _t'1)
                    (Evar _cur_obj_check_anim_frame (Tfunction (tint :: nil)
                                                      tint cc_default))
                    ((Etempvar _animFrame tint) :: nil))
                  (Sifthenelse (Etempvar _t'1 tint)
                    (Ssequence
                      (Sset _t'8
                        (Efield
                          (Ederef
                            (Ebinop Oadd
                              (Etempvar _soundStates (tptr (Tstruct _SoundState noattr)))
                              (Etempvar _stateIdx tint)
                              (tptr (Tstruct _SoundState noattr)))
                            (Tstruct _SoundState noattr)) _soundMagic tint))
                      (Scall None
                        (Evar _cur_obj_play_sound_2 (Tfunction (tint :: nil)
                                                      tvoid cc_default))
                        ((Etempvar _t'8 tint) :: nil)))
                    Sskip))
                Sskip))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'7
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Etempvar _soundStates (tptr (Tstruct _SoundState noattr)))
                            (Etempvar _stateIdx tint)
                            (tptr (Tstruct _SoundState noattr)))
                          (Tstruct _SoundState noattr)) _animFrame2 tschar))
                    (Sset _t'4 (Ecast (Etempvar _t'7 tschar) tint)))
                  (Sset _animFrame (Etempvar _t'4 tint)))
                (Sifthenelse (Ebinop Oge (Etempvar _t'4 tint)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Ssequence
                    (Scall (Some _t'3)
                      (Evar _cur_obj_check_anim_frame (Tfunction
                                                        (tint :: nil) tint
                                                        cc_default))
                      ((Etempvar _animFrame tint) :: nil))
                    (Sifthenelse (Etempvar _t'3 tint)
                      (Ssequence
                        (Sset _t'6
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Etempvar _soundStates (tptr (Tstruct _SoundState noattr)))
                                (Etempvar _stateIdx tint)
                                (tptr (Tstruct _SoundState noattr)))
                              (Tstruct _SoundState noattr)) _soundMagic tint))
                        (Scall None
                          (Evar _cur_obj_play_sound_2 (Tfunction
                                                        (tint :: nil) tvoid
                                                        cc_default))
                          ((Etempvar _t'6 tint) :: nil)))
                      Sskip))
                  Sskip))
              Sbreak))
          LSnil)))))
|}.

Definition f_create_sound_spawner := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_soundMagic, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_obj, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Scall (Some _t'1)
        (Evar _spawn_object (Tfunction
                              ((tptr (Tstruct _Object noattr)) :: tint ::
                               (tptr tuint) :: nil)
                              (tptr (Tstruct _Object noattr)) cc_default))
        ((Etempvar _t'2 (tptr (Tstruct _Object noattr))) ::
         (Econst_int (Int.repr 0) tint) ::
         (Evar _bhvSoundSpawner (tarray tuint 0)) :: nil)))
    (Sset _obj (Etempvar _t'1 (tptr (Tstruct _Object noattr)))))
  (Sassign
    (Ederef
      (Ebinop Oadd
        (Efield
          (Efield
            (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
              (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
          _asS32 (tarray tint 80)) (Econst_int (Int.repr 27) tint)
        (tptr tint)) tint) (Etempvar _soundMagic tint)))
|}.

Definition f_cur_obj_play_sound_1 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_soundMagic, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, (tptr (Tstruct _Object noattr))) :: (_t'2, tshort) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Sset _t'2
      (Efield
        (Efield
          (Efield
            (Efield
              (Ederef (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _header
              (Tstruct _ObjectNode noattr)) _gfx
            (Tstruct _GraphNodeObject noattr)) _node
          (Tstruct _GraphNode noattr)) _flags tshort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'2 tshort)
                   (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                     (Econst_int (Int.repr 0) tint) tint) tint)
      (Ssequence
        (Sset _t'3 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Scall None
          (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                              cc_default))
          ((Etempvar _soundMagic tint) ::
           (Efield
             (Efield
               (Efield
                 (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                   (Tstruct _Object noattr)) _header
                 (Tstruct _ObjectNode noattr)) _gfx
               (Tstruct _GraphNodeObject noattr)) _cameraToObject
             (tarray tfloat 3)) :: nil)))
      Sskip)))
|}.

Definition f_cur_obj_play_sound_2 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_soundMagic, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, (tptr (Tstruct _Object noattr))) :: (_t'2, tshort) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Sset _t'2
      (Efield
        (Efield
          (Efield
            (Efield
              (Ederef (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _header
              (Tstruct _ObjectNode noattr)) _gfx
            (Tstruct _GraphNodeObject noattr)) _node
          (Tstruct _GraphNode noattr)) _flags tshort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'2 tshort)
                   (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                     (Econst_int (Int.repr 0) tint) tint) tint)
      (Ssequence
        (Sset _t'3 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Scall None
          (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                              cc_default))
          ((Etempvar _soundMagic tint) ::
           (Efield
             (Efield
               (Efield
                 (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                   (Tstruct _Object noattr)) _header
                 (Tstruct _ObjectNode noattr)) _gfx
               (Tstruct _GraphNodeObject noattr)) _cameraToObject
             (tarray tfloat 3)) :: nil)))
      Sskip)))
|}.

Definition f_calc_dist_to_volume_range_1 := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_distance, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_volume, tint) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Olt (Etempvar _distance tfloat)
                 (Econst_single (Float32.of_bits (Int.repr 1140457472)) tfloat)
                 tint)
    (Sset _volume (Econst_int (Int.repr 127) tint))
    (Sifthenelse (Ebinop Olt
                   (Econst_single (Float32.of_bits (Int.repr 1153138688)) tfloat)
                   (Etempvar _distance tfloat) tint)
      (Sset _volume (Econst_int (Int.repr 0) tint))
      (Sset _volume
        (Ecast
          (Ebinop Oadd
            (Ebinop Omul
              (Ebinop Odiv
                (Ebinop Osub (Etempvar _distance tfloat)
                  (Econst_single (Float32.of_bits (Int.repr 1140457472)) tfloat)
                  tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1148846080)) tfloat)
                tfloat)
              (Econst_single (Float32.of_bits (Int.repr 1115684864)) tfloat)
              tfloat)
            (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat)
            tfloat) tint))))
  (Sreturn (Some (Etempvar _volume tint))))
|}.

Definition f_calc_dist_to_volume_range_2 := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_distance, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_volume, tint) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Olt (Etempvar _distance tfloat)
                 (Econst_single (Float32.of_bits (Int.repr 1151500288)) tfloat)
                 tint)
    (Sset _volume (Econst_int (Int.repr 127) tint))
    (Sifthenelse (Ebinop Olt
                   (Econst_single (Float32.of_bits (Int.repr 1158660096)) tfloat)
                   (Etempvar _distance tfloat) tint)
      (Sset _volume (Econst_int (Int.repr 0) tint))
      (Sset _volume
        (Ecast
          (Ebinop Oadd
            (Ebinop Omul
              (Ebinop Odiv
                (Ebinop Osub (Etempvar _distance tfloat)
                  (Econst_single (Float32.of_bits (Int.repr 1148846080)) tfloat)
                  tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1148846080)) tfloat)
                tfloat)
              (Econst_single (Float32.of_bits (Int.repr 1115684864)) tfloat)
              tfloat)
            (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat)
            tfloat) tint))))
  (Sreturn (Some (Etempvar _volume tint))))
|}.

Definition composites : list composite_definition :=
(Composite _Animation Struct
   (Member_plain _flags tshort :: Member_plain _animYTransDivisor tshort ::
    Member_plain _startFrame tshort :: Member_plain _loopStart tshort ::
    Member_plain _loopEnd tshort :: Member_plain _unusedBoneCount tshort ::
    Member_plain _values (tptr tshort) ::
    Member_plain _index (tptr tushort) :: Member_plain _length tuint :: nil)
   noattr ::
 Composite _GraphNode Struct
   (Member_plain _type tshort :: Member_plain _flags tshort ::
    Member_plain _prev (tptr (Tstruct _GraphNode noattr)) ::
    Member_plain _next (tptr (Tstruct _GraphNode noattr)) ::
    Member_plain _parent (tptr (Tstruct _GraphNode noattr)) ::
    Member_plain _children (tptr (Tstruct _GraphNode noattr)) :: nil)
   noattr ::
 Composite _AnimInfo Struct
   (Member_plain _animID tshort :: Member_plain _animYTrans tshort ::
    Member_plain _curAnim (tptr (Tstruct _Animation noattr)) ::
    Member_plain _animFrame tshort :: Member_plain _animTimer tushort ::
    Member_plain _animFrameAccelAssist tint ::
    Member_plain _animAccel tint :: nil)
   noattr ::
 Composite _GraphNodeObject Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _sharedChild (tptr (Tstruct _GraphNode noattr)) ::
    Member_plain _areaIndex tschar :: Member_plain _activeAreaIndex tschar ::
    Member_plain _angle (tarray tshort 3) ::
    Member_plain _pos (tarray tfloat 3) ::
    Member_plain _scale (tarray tfloat 3) ::
    Member_plain _animInfo (Tstruct _AnimInfo noattr) ::
    Member_plain _unk4C (tptr (Tstruct _SpawnInfo noattr)) ::
    Member_plain _throwMatrix (tptr (tarray (tarray tfloat 4) 4)) ::
    Member_plain _cameraToObject (tarray tfloat 3) :: nil)
   noattr ::
 Composite _ObjectNode Struct
   (Member_plain _gfx (Tstruct _GraphNodeObject noattr) ::
    Member_plain _next (tptr (Tstruct _ObjectNode noattr)) ::
    Member_plain _prev (tptr (Tstruct _ObjectNode noattr)) :: nil)
   noattr ::
 Composite __764 Union
   (Member_plain _asU32 (tarray tuint 80) ::
    Member_plain _asS32 (tarray tint 80) ::
    Member_plain _asS16 (tarray (tarray tshort 2) 80) ::
    Member_plain _asF32 (tarray tfloat 80) ::
    Member_plain _asS16P (tarray (tptr tshort) 80) ::
    Member_plain _asS32P (tarray (tptr tint) 80) ::
    Member_plain _asAnims
      (tarray (tptr (tptr (Tstruct _Animation noattr))) 80) ::
    Member_plain _asWaypoint (tarray (tptr (Tstruct _Waypoint noattr)) 80) ::
    Member_plain _asChainSegment
      (tarray (tptr (Tstruct _ChainSegment noattr)) 80) ::
    Member_plain _asObject (tarray (tptr (Tstruct _Object noattr)) 80) ::
    Member_plain _asSurface (tarray (tptr (Tstruct _Surface noattr)) 80) ::
    Member_plain _asVoidPtr (tarray (tptr tvoid) 80) ::
    Member_plain _asConstVoidPtr (tarray (tptr tvoid) 80) :: nil)
   noattr ::
 Composite _Object Struct
   (Member_plain _header (Tstruct _ObjectNode noattr) ::
    Member_plain _parentObj (tptr (Tstruct _Object noattr)) ::
    Member_plain _prevObj (tptr (Tstruct _Object noattr)) ::
    Member_plain _collidedObjInteractTypes tuint ::
    Member_plain _activeFlags tshort ::
    Member_plain _numCollidedObjs tshort ::
    Member_plain _collidedObjs (tarray (tptr (Tstruct _Object noattr)) 4) ::
    Member_plain _rawData (Tunion __764 noattr) ::
    Member_plain _unused1 tuint ::
    Member_plain _curBhvCommand (tptr tuint) ::
    Member_plain _bhvStackIndex tuint ::
    Member_plain _bhvStack (tarray tuint 8) ::
    Member_plain _bhvDelayTimer tshort ::
    Member_plain _respawnInfoType tshort ::
    Member_plain _hitboxRadius tfloat :: Member_plain _hitboxHeight tfloat ::
    Member_plain _hurtboxRadius tfloat ::
    Member_plain _hurtboxHeight tfloat ::
    Member_plain _hitboxDownOffset tfloat ::
    Member_plain _behavior (tptr tuint) :: Member_plain _unused2 tuint ::
    Member_plain _platform (tptr (Tstruct _Object noattr)) ::
    Member_plain _collisionData (tptr tvoid) ::
    Member_plain _transform (tarray (tarray tfloat 4) 4) ::
    Member_plain _respawnInfo (tptr tvoid) :: nil)
   noattr ::
 Composite _Waypoint Struct
   (Member_plain _flags tshort :: Member_plain _pos (tarray tshort 3) :: nil)
   noattr ::
 Composite __769 Struct
   (Member_plain _x tfloat :: Member_plain _y tfloat ::
    Member_plain _z tfloat :: nil)
   noattr ::
 Composite _Surface Struct
   (Member_plain _type tshort :: Member_plain _force tshort ::
    Member_plain _flags tschar :: Member_plain _room tschar ::
    Member_plain _lowerY tshort :: Member_plain _upperY tshort ::
    Member_plain _vertex1 (tarray tshort 3) ::
    Member_plain _vertex2 (tarray tshort 3) ::
    Member_plain _vertex3 (tarray tshort 3) ::
    Member_plain _normal (Tstruct __769 noattr) ::
    Member_plain _originOffset tfloat ::
    Member_plain _object (tptr (Tstruct _Object noattr)) :: nil)
   noattr ::
 Composite _ChainSegment Struct
   (Member_plain _posX tfloat :: Member_plain _posY tfloat ::
    Member_plain _posZ tfloat :: Member_plain _pitch tshort ::
    Member_plain _yaw tshort :: Member_plain _roll tshort :: nil)
   noattr ::
 Composite _SpawnInfo Struct
   (Member_plain _startPos (tarray tshort 3) ::
    Member_plain _startAngle (tarray tshort 3) ::
    Member_plain _areaIndex tschar :: Member_plain _activeAreaIndex tschar ::
    Member_plain _behaviorArg tuint ::
    Member_plain _behaviorScript (tptr tvoid) ::
    Member_plain _model (tptr (Tstruct _GraphNode noattr)) ::
    Member_plain _next (tptr (Tstruct _SpawnInfo noattr)) :: nil)
   noattr ::
 Composite _SoundState Struct
   (Member_plain _playSound tshort :: Member_plain _animFrame1 tschar ::
    Member_plain _animFrame2 tschar :: Member_plain _soundMagic tint :: nil)
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
 (_play_sound,
   Gfun(External (EF_external "play_sound"
                   (mksignature (AST.Xint :: AST.Xptr :: nil) AST.Xvoid
                     cc_default)) (tint :: (tptr tfloat) :: nil) tvoid
     cc_default)) :: (_bhvSoundSpawner, Gvar v_bhvSoundSpawner) ::
 (_spawn_object,
   Gfun(External (EF_external "spawn_object"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xptr :: nil)
                     AST.Xptr cc_default))
     ((tptr (Tstruct _Object noattr)) :: tint :: (tptr tuint) :: nil)
     (tptr (Tstruct _Object noattr)) cc_default)) ::
 (_cur_obj_check_anim_frame,
   Gfun(External (EF_external "cur_obj_check_anim_frame"
                   (mksignature (AST.Xint :: nil) AST.Xint cc_default))
     (tint :: nil) tint cc_default)) ::
 (_gCurrentObject, Gvar v_gCurrentObject) ::
 (_exec_anim_sound_state, Gfun(Internal f_exec_anim_sound_state)) ::
 (_create_sound_spawner, Gfun(Internal f_create_sound_spawner)) ::
 (_cur_obj_play_sound_1, Gfun(Internal f_cur_obj_play_sound_1)) ::
 (_cur_obj_play_sound_2, Gfun(Internal f_cur_obj_play_sound_2)) ::
 (_calc_dist_to_volume_range_1, Gfun(Internal f_calc_dist_to_volume_range_1)) ::
 (_calc_dist_to_volume_range_2, Gfun(Internal f_calc_dist_to_volume_range_2)) ::
 nil).

Definition public_idents : list ident :=
(_calc_dist_to_volume_range_2 :: _calc_dist_to_volume_range_1 ::
 _cur_obj_play_sound_2 :: _cur_obj_play_sound_1 :: _create_sound_spawner ::
 _exec_anim_sound_state :: _gCurrentObject :: _cur_obj_check_anim_frame ::
 _spawn_object :: _bhvSoundSpawner :: _play_sound :: ___builtin_debug ::
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
