(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_JP
   Source:          src/game/level_geo.c
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_JP=1 -DF3D_OLD=1
   Link hygiene:    private __stringlit_N atoms prefixed with jp_level_geo
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
  Definition source_file := "build/pinned-sm64/src/game/level_geo.c".
  Definition normalized := true.
End Info.

Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _Camera : ident := $"Camera".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _FnGraphNode : ident := $"FnGraphNode".
Definition _GraphNode : ident := $"GraphNode".
Definition _GraphNodeBackground : ident := $"GraphNodeBackground".
Definition _GraphNodeCamera : ident := $"GraphNodeCamera".
Definition _GraphNodeGenerated : ident := $"GraphNodeGenerated".
Definition _GraphNodeObject : ident := $"GraphNodeObject".
Definition _GraphNodePerspective : ident := $"GraphNodePerspective".
Definition _GraphNodeRoot : ident := $"GraphNodeRoot".
Definition _LakituState : ident := $"LakituState".
Definition _Object : ident := $"Object".
Definition _ObjectNode : ident := $"ObjectNode".
Definition _PlayerCameraState : ident := $"PlayerCameraState".
Definition _SpawnInfo : ident := $"SpawnInfo".
Definition _Surface : ident := $"Surface".
Definition _Waypoint : ident := $"Waypoint".
Definition __1069 : ident := $"_1069".
Definition __472 : ident := $"_472".
Definition __510 : ident := $"_510".
Definition __512 : ident := $"_512".
Definition __727 : ident := $"_727".
Definition __732 : ident := $"_732".
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
Definition _action : ident := $"action".
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _alloc_display_list : ident := $"alloc_display_list".
Definition _angle : ident := $"angle".
Definition _animAccel : ident := $"animAccel".
Definition _animFrame : ident := $"animFrame".
Definition _animFrameAccelAssist : ident := $"animFrameAccelAssist".
Definition _animID : ident := $"animID".
Definition _animInfo : ident := $"animInfo".
Definition _animTimer : ident := $"animTimer".
Definition _animYTrans : ident := $"animYTrans".
Definition _animYTransDivisor : ident := $"animYTransDivisor".
Definition _areaCenX : ident := $"areaCenX".
Definition _areaCenY : ident := $"areaCenY".
Definition _areaCenZ : ident := $"areaCenZ".
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
Definition _background : ident := $"background".
Definition _backgroundNode : ident := $"backgroundNode".
Definition _behavior : ident := $"behavior".
Definition _behaviorArg : ident := $"behaviorArg".
Definition _behaviorScript : ident := $"behaviorScript".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _callContext : ident := $"callContext".
Definition _camFrom : ident := $"camFrom".
Definition _camFrustum : ident := $"camFrustum".
Definition _camNode : ident := $"camNode".
Definition _camTo : ident := $"camTo".
Definition _camera : ident := $"camera".
Definition _cameraEvent : ident := $"cameraEvent".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _children : ident := $"children".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _config : ident := $"config".
Definition _create_skybox_facing_camera : ident := $"create_skybox_facing_camera".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _curFocus : ident := $"curFocus".
Definition _curPos : ident := $"curPos".
Definition _cutscene : ident := $"cutscene".
Definition _defMode : ident := $"defMode".
Definition _doorStatus : ident := $"doorStatus".
Definition _envfx_update_particles : ident := $"envfx_update_particles".
Definition _execNode : ident := $"execNode".
Definition _faceAngle : ident := $"faceAngle".
Definition _far : ident := $"far".
Definition _filler1 : ident := $"filler1".
Definition _filler2 : ident := $"filler2".
Definition _filler3 : ident := $"filler3".
Definition _flags : ident := $"flags".
Definition _fnNode : ident := $"fnNode".
Definition _focHSpeed : ident := $"focHSpeed".
Definition _focVSpeed : ident := $"focVSpeed".
Definition _focus : ident := $"focus".
Definition _focusDistance : ident := $"focusDistance".
Definition _force : ident := $"force".
Definition _force_structure_alignment : ident := $"force_structure_alignment".
Definition _fov : ident := $"fov".
Definition _func : ident := $"func".
Definition _gAreaUpdateCounter : ident := $"gAreaUpdateCounter".
Definition _gCurGraphNodeCamera : ident := $"gCurGraphNodeCamera".
Definition _gCurGraphNodeRoot : ident := $"gCurGraphNodeRoot".
Definition _gLakituState : ident := $"gLakituState".
Definition _gPlayerCameraState : ident := $"gPlayerCameraState".
Definition _gVec3sZero : ident := $"gVec3sZero".
Definition _geo_envfx_main : ident := $"geo_envfx_main".
Definition _geo_skybox_main : ident := $"geo_skybox_main".
Definition _gfx : ident := $"gfx".
Definition _goalFocus : ident := $"goalFocus".
Definition _goalPos : ident := $"goalPos".
Definition _headRotation : ident := $"headRotation".
Definition _header : ident := $"header".
Definition _height : ident := $"height".
Definition _hitboxDownOffset : ident := $"hitboxDownOffset".
Definition _hitboxHeight : ident := $"hitboxHeight".
Definition _hitboxRadius : ident := $"hitboxRadius".
Definition _hurtboxHeight : ident := $"hurtboxHeight".
Definition _hurtboxRadius : ident := $"hurtboxRadius".
Definition _index : ident := $"index".
Definition _keyDanceRoll : ident := $"keyDanceRoll".
Definition _lastFrameAction : ident := $"lastFrameAction".
Definition _length : ident := $"length".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _m : ident := $"m".
Definition _main : ident := $"main".
Definition _marioPos : ident := $"marioPos".
Definition _matrixPtr : ident := $"matrixPtr".
Definition _mode : ident := $"mode".
Definition _model : ident := $"model".
Definition _mtx : ident := $"mtx".
Definition _mtxf : ident := $"mtxf".
Definition _mtxf_to_mtx : ident := $"mtxf_to_mtx".
Definition _near : ident := $"near".
Definition _next : ident := $"next".
Definition _nextYaw : ident := $"nextYaw".
Definition _node : ident := $"node".
Definition _normal : ident := $"normal".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _numViews : ident := $"numViews".
Definition _object : ident := $"object".
Definition _oldPitch : ident := $"oldPitch".
Definition _oldRoll : ident := $"oldRoll".
Definition _oldYaw : ident := $"oldYaw".
Definition _originOffset : ident := $"originOffset".
Definition _parameter : ident := $"parameter".
Definition _params : ident := $"params".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _particleList : ident := $"particleList".
Definition _platform : ident := $"platform".
Definition _pos : ident := $"pos".
Definition _posHSpeed : ident := $"posHSpeed".
Definition _posVSpeed : ident := $"posVSpeed".
Definition _prev : ident := $"prev".
Definition _prevObj : ident := $"prevObj".
Definition _rawData : ident := $"rawData".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _roll : ident := $"roll".
Definition _rollScreen : ident := $"rollScreen".
Definition _room : ident := $"room".
Definition _scale : ident := $"scale".
Definition _shakeMagnitude : ident := $"shakeMagnitude".
Definition _shakePitchDecay : ident := $"shakePitchDecay".
Definition _shakePitchPhase : ident := $"shakePitchPhase".
Definition _shakePitchVel : ident := $"shakePitchVel".
Definition _shakeRollDecay : ident := $"shakeRollDecay".
Definition _shakeRollPhase : ident := $"shakeRollPhase".
Definition _shakeRollVel : ident := $"shakeRollVel".
Definition _shakeYawDecay : ident := $"shakeYawDecay".
Definition _shakeYawPhase : ident := $"shakeYawPhase".
Definition _shakeYawVel : ident := $"shakeYawVel".
Definition _sharedChild : ident := $"sharedChild".
Definition _snowMode : ident := $"snowMode".
Definition _sp2C : ident := $"sp2C".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _transform : ident := $"transform".
Definition _type : ident := $"type".
Definition _unk15 : ident := $"unk15".
Definition _unk4C : ident := $"unk4C".
Definition _unused : ident := $"unused".
Definition _unused1 : ident := $"unused1".
Definition _unused2 : ident := $"unused2".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _unusedVec1 : ident := $"unusedVec1".
Definition _unusedVec2 : ident := $"unusedVec2".
Definition _upperY : ident := $"upperY".
Definition _usedObj : ident := $"usedObj".
Definition _values : ident := $"values".
Definition _vec3f_to_vec3s : ident := $"vec3f_to_vec3s".
Definition _vec3s_copy : ident := $"vec3s_copy".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _views : ident := $"views".
Definition _w0 : ident := $"w0".
Definition _w1 : ident := $"w1".
Definition _width : ident := $"width".
Definition _words : ident := $"words".
Definition _x : ident := $"x".
Definition _y : ident := $"y".
Definition _yaw : ident := $"yaw".
Definition _z : ident := $"z".
Definition _t'1 : ident := 128%positive.
Definition _t'10 : ident := 137%positive.
Definition _t'11 : ident := 138%positive.
Definition _t'12 : ident := 139%positive.
Definition _t'13 : ident := 140%positive.
Definition _t'14 : ident := 141%positive.
Definition _t'2 : ident := 129%positive.
Definition _t'3 : ident := 130%positive.
Definition _t'4 : ident := 131%positive.
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v_gVec3sZero := {|
  gvar_info := (tarray tshort 3);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurGraphNodeRoot := {|
  gvar_info := (tptr (Tstruct _GraphNodeRoot noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurGraphNodeCamera := {|
  gvar_info := (tptr (Tstruct _GraphNodeCamera noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAreaUpdateCounter := {|
  gvar_info := tushort;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gPlayerCameraState := {|
  gvar_info := (tarray (Tstruct _PlayerCameraState noattr) 2);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gLakituState := {|
  gvar_info := (Tstruct _LakituState noattr);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_geo_envfx_main := {|
  fn_return := (tptr (Tunion __512 noattr));
  fn_callconv := cc_default;
  fn_params := ((_callContext, tint) ::
                (_node, (tptr (Tstruct _GraphNode noattr))) ::
                (_mtxf, (tptr (tarray tfloat 4))) :: nil);
  fn_vars := ((_marioPos, (tarray tshort 3)) ::
              (_camFrom, (tarray tshort 3)) :: (_camTo, (tarray tshort 3)) ::
              nil);
  fn_temps := ((_particleList, (tptr tvoid)) ::
               (_gfx, (tptr (Tunion __512 noattr))) ::
               (_execNode, (tptr (Tstruct _GraphNodeGenerated noattr))) ::
               (_params, (tptr tuint)) ::
               (_sp2C, (tptr (Tstruct _Camera noattr))) ::
               (_snowMode, tint) :: (_mtx, (tptr (Tunion __472 noattr))) ::
               (__g, (tptr (Tunion __512 noattr))) ::
               (__g__1, (tptr (Tunion __512 noattr))) :: (_t'4, tint) ::
               (_t'3, (tptr tvoid)) :: (_t'2, (tptr tvoid)) ::
               (_t'1, (tptr (Tunion __512 noattr))) ::
               (_t'14, (tptr (Tstruct _GraphNodeCamera noattr))) ::
               (_t'13, (tptr (Tstruct _GraphNodeCamera noattr))) ::
               (_t'12, tuint) ::
               (_t'11, (tptr (Tstruct _GraphNodeCamera noattr))) ::
               (_t'10, (tptr (Tstruct _GraphNodeCamera noattr))) ::
               (_t'9, tshort) :: (_t'8, tushort) :: (_t'7, tuint) ::
               (_t'6, tushort) :: (_t'5, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _gfx (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Ssequence
      (Sifthenelse (Ebinop Oeq (Etempvar _callContext tint)
                     (Econst_int (Int.repr 1) tint) tint)
        (Ssequence
          (Sset _t'14
            (Evar _gCurGraphNodeCamera (tptr (Tstruct _GraphNodeCamera noattr))))
          (Sset _t'4
            (Ecast
              (Ebinop One
                (Etempvar _t'14 (tptr (Tstruct _GraphNodeCamera noattr)))
                (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
              tbool)))
        (Sset _t'4 (Econst_int (Int.repr 0) tint)))
      (Sifthenelse (Etempvar _t'4 tint)
        (Ssequence
          (Sset _execNode
            (Ecast (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
              (tptr (Tstruct _GraphNodeGenerated noattr))))
          (Ssequence
            (Sset _params
              (Eaddrof
                (Efield
                  (Ederef
                    (Etempvar _execNode (tptr (Tstruct _GraphNodeGenerated noattr)))
                    (Tstruct _GraphNodeGenerated noattr)) _parameter tuint)
                (tptr tuint)))
            (Ssequence
              (Sset _t'5 (Ederef (Etempvar _params (tptr tuint)) tuint))
              (Ssequence
                (Sset _t'6 (Evar _gAreaUpdateCounter tushort))
                (Sifthenelse (Ebinop One
                               (Ecast
                                 (Ebinop Oshr (Etempvar _t'5 tuint)
                                   (Econst_int (Int.repr 16) tint) tuint)
                                 tushort) (Etempvar _t'6 tushort) tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'13
                        (Evar _gCurGraphNodeCamera (tptr (Tstruct _GraphNodeCamera noattr))))
                      (Sset _sp2C
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'13 (tptr (Tstruct _GraphNodeCamera noattr)))
                              (Tstruct _GraphNodeCamera noattr)) _config
                            (Tunion __1069 noattr)) _camera
                          (tptr (Tstruct _Camera noattr)))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'12
                          (Ederef (Etempvar _params (tptr tuint)) tuint))
                        (Sset _snowMode
                          (Ecast
                            (Ebinop Oand (Etempvar _t'12 tuint)
                              (Econst_int (Int.repr 65535) tint) tuint)
                            tushort)))
                      (Ssequence
                        (Ssequence
                          (Sset _t'11
                            (Evar _gCurGraphNodeCamera (tptr (Tstruct _GraphNodeCamera noattr))))
                          (Scall None
                            (Evar _vec3f_to_vec3s (Tfunction
                                                    ((tptr tshort) ::
                                                     (tptr tfloat) :: nil)
                                                    (tptr tvoid) cc_default))
                            ((Evar _camTo (tarray tshort 3)) ::
                             (Efield
                               (Ederef
                                 (Etempvar _t'11 (tptr (Tstruct _GraphNodeCamera noattr)))
                                 (Tstruct _GraphNodeCamera noattr)) _focus
                               (tarray tfloat 3)) :: nil)))
                        (Ssequence
                          (Ssequence
                            (Sset _t'10
                              (Evar _gCurGraphNodeCamera (tptr (Tstruct _GraphNodeCamera noattr))))
                            (Scall None
                              (Evar _vec3f_to_vec3s (Tfunction
                                                      ((tptr tshort) ::
                                                       (tptr tfloat) :: nil)
                                                      (tptr tvoid)
                                                      cc_default))
                              ((Evar _camFrom (tarray tshort 3)) ::
                               (Efield
                                 (Ederef
                                   (Etempvar _t'10 (tptr (Tstruct _GraphNodeCamera noattr)))
                                   (Tstruct _GraphNodeCamera noattr)) _pos
                                 (tarray tfloat 3)) :: nil)))
                          (Ssequence
                            (Scall None
                              (Evar _vec3f_to_vec3s (Tfunction
                                                      ((tptr tshort) ::
                                                       (tptr tfloat) :: nil)
                                                      (tptr tvoid)
                                                      cc_default))
                              ((Evar _marioPos (tarray tshort 3)) ::
                               (Efield
                                 (Ederef
                                   (Evar _gPlayerCameraState (tarray (Tstruct _PlayerCameraState noattr) 2))
                                   (Tstruct _PlayerCameraState noattr)) _pos
                                 (tarray tfloat 3)) :: nil))
                            (Ssequence
                              (Ssequence
                                (Scall (Some _t'1)
                                  (Evar _envfx_update_particles (Tfunction
                                                                  (tint ::
                                                                   (tptr tshort) ::
                                                                   (tptr tshort) ::
                                                                   (tptr tshort) ::
                                                                   nil)
                                                                  (tptr (Tunion __512 noattr))
                                                                  cc_default))
                                  ((Etempvar _snowMode tint) ::
                                   (Evar _marioPos (tarray tshort 3)) ::
                                   (Evar _camTo (tarray tshort 3)) ::
                                   (Evar _camFrom (tarray tshort 3)) :: nil))
                                (Sset _particleList
                                  (Etempvar _t'1 (tptr (Tunion __512 noattr)))))
                              (Ssequence
                                (Sifthenelse (Ebinop One
                                               (Etempvar _particleList (tptr tvoid))
                                               (Ecast
                                                 (Econst_int (Int.repr 0) tint)
                                                 (tptr tvoid)) tint)
                                  (Ssequence
                                    (Ssequence
                                      (Scall (Some _t'2)
                                        (Evar _alloc_display_list (Tfunction
                                                                    (tuint ::
                                                                    nil)
                                                                    (tptr tvoid)
                                                                    cc_default))
                                        ((Esizeof (Tunion __472 noattr) tuint) ::
                                         nil))
                                      (Sset _mtx
                                        (Etempvar _t'2 (tptr tvoid))))
                                    (Ssequence
                                      (Ssequence
                                        (Scall (Some _t'3)
                                          (Evar _alloc_display_list (Tfunction
                                                                    (tuint ::
                                                                    nil)
                                                                    (tptr tvoid)
                                                                    cc_default))
                                          ((Ebinop Omul
                                             (Econst_int (Int.repr 2) tint)
                                             (Esizeof (Tunion __512 noattr) tuint)
                                             tuint) :: nil))
                                        (Sset _gfx
                                          (Etempvar _t'3 (tptr tvoid))))
                                      (Ssequence
                                        (Scall None
                                          (Evar _mtxf_to_mtx (Tfunction
                                                               ((tptr (Tunion __472 noattr)) ::
                                                                (tptr (tarray tfloat 4)) ::
                                                                nil) tvoid
                                                               cc_default))
                                          ((Etempvar _mtx (tptr (Tunion __472 noattr))) ::
                                           (Etempvar _mtxf (tptr (tarray tfloat 4))) ::
                                           nil))
                                        (Ssequence
                                          (Ssequence
                                            (Sset __g
                                              (Ecast
                                                (Ebinop Oadd
                                                  (Etempvar _gfx (tptr (Tunion __512 noattr)))
                                                  (Econst_int (Int.repr 0) tint)
                                                  (tptr (Tunion __512 noattr)))
                                                (tptr (Tunion __512 noattr))))
                                            (Ssequence
                                              (Sassign
                                                (Efield
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar __g (tptr (Tunion __512 noattr)))
                                                      (Tunion __512 noattr))
                                                    _words
                                                    (Tstruct __510 noattr))
                                                  _w0 tuint)
                                                (Ebinop Oor
                                                  (Ebinop Oor
                                                    (Ecast
                                                      (Ebinop Oshl
                                                        (Ebinop Oand
                                                          (Ecast
                                                            (Econst_int (Int.repr 1) tint)
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
                                                            (Ebinop Oor
                                                              (Ebinop Oor
                                                                (Econst_int (Int.repr 0) tint)
                                                                (Econst_int (Int.repr 2) tint)
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
                                                        (Econst_int (Int.repr 16) tint)
                                                        tuint) tuint) tuint)
                                                  (Ecast
                                                    (Ebinop Oshl
                                                      (Ebinop Oand
                                                        (Ecast
                                                          (Esizeof (Tunion __472 noattr) tuint)
                                                          tuint)
                                                        (Ebinop Osub
                                                          (Ebinop Oshl
                                                            (Econst_int (Int.repr 1) tint)
                                                            (Econst_int (Int.repr 16) tint)
                                                            tint)
                                                          (Econst_int (Int.repr 1) tint)
                                                          tint) tuint)
                                                      (Econst_int (Int.repr 0) tint)
                                                      tuint) tuint) tuint))
                                              (Sassign
                                                (Efield
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar __g (tptr (Tunion __512 noattr)))
                                                      (Tunion __512 noattr))
                                                    _words
                                                    (Tstruct __510 noattr))
                                                  _w1 tuint)
                                                (Ecast
                                                  (Ebinop Oand
                                                    (Ecast
                                                      (Etempvar _mtx (tptr (Tunion __472 noattr)))
                                                      tuint)
                                                    (Econst_int (Int.repr 536870911) tint)
                                                    tuint) tuint))))
                                          (Ssequence
                                            (Ssequence
                                              (Sset __g__1
                                                (Ecast
                                                  (Ebinop Oadd
                                                    (Etempvar _gfx (tptr (Tunion __512 noattr)))
                                                    (Econst_int (Int.repr 1) tint)
                                                    (tptr (Tunion __512 noattr)))
                                                  (tptr (Tunion __512 noattr))))
                                              (Ssequence
                                                (Sassign
                                                  (Efield
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar __g__1 (tptr (Tunion __512 noattr)))
                                                        (Tunion __512 noattr))
                                                      _words
                                                      (Tstruct __510 noattr))
                                                    _w0 tuint)
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
                                                              (Econst_int (Int.repr 1) tint)
                                                              tuint)
                                                            (Ebinop Osub
                                                              (Ebinop Oshl
                                                                (Econst_int (Int.repr 1) tint)
                                                                (Econst_int (Int.repr 8) tint)
                                                                tint)
                                                              (Econst_int (Int.repr 1) tint)
                                                              tint) tuint)
                                                          (Econst_int (Int.repr 16) tint)
                                                          tuint) tuint)
                                                      tuint)
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
                                                        (Econst_int (Int.repr 0) tint)
                                                        tuint) tuint) tuint))
                                                (Sassign
                                                  (Efield
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar __g__1 (tptr (Tunion __512 noattr)))
                                                        (Tunion __512 noattr))
                                                      _words
                                                      (Tstruct __510 noattr))
                                                    _w1 tuint)
                                                  (Ecast
                                                    (Ebinop Oand
                                                      (Ecast
                                                        (Etempvar _particleList (tptr tvoid))
                                                        tuint)
                                                      (Econst_int (Int.repr 536870911) tint)
                                                      tuint) tuint))))
                                            (Ssequence
                                              (Sset _t'9
                                                (Efield
                                                  (Efield
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _execNode (tptr (Tstruct _GraphNodeGenerated noattr)))
                                                        (Tstruct _GraphNodeGenerated noattr))
                                                      _fnNode
                                                      (Tstruct _FnGraphNode noattr))
                                                    _node
                                                    (Tstruct _GraphNode noattr))
                                                  _flags tshort))
                                              (Sassign
                                                (Efield
                                                  (Efield
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _execNode (tptr (Tstruct _GraphNodeGenerated noattr)))
                                                        (Tstruct _GraphNodeGenerated noattr))
                                                      _fnNode
                                                      (Tstruct _FnGraphNode noattr))
                                                    _node
                                                    (Tstruct _GraphNode noattr))
                                                  _flags tshort)
                                                (Ebinop Oor
                                                  (Ebinop Oand
                                                    (Etempvar _t'9 tshort)
                                                    (Econst_int (Int.repr 255) tint)
                                                    tint)
                                                  (Econst_int (Int.repr 1024) tint)
                                                  tint))))))))
                                  Sskip)
                                (Ssequence
                                  (Sset _t'7
                                    (Ederef (Etempvar _params (tptr tuint))
                                      tuint))
                                  (Ssequence
                                    (Sset _t'8
                                      (Evar _gAreaUpdateCounter tushort))
                                    (Sassign
                                      (Ederef (Etempvar _params (tptr tuint))
                                        tuint)
                                      (Ebinop Oor
                                        (Ebinop Oand (Etempvar _t'7 tuint)
                                          (Econst_int (Int.repr 65535) tint)
                                          tuint)
                                        (Ebinop Oshl (Etempvar _t'8 tushort)
                                          (Econst_int (Int.repr 16) tint)
                                          tint) tuint)))))))))))
                  Sskip)))))
        (Sifthenelse (Ebinop Oeq (Etempvar _callContext tint)
                       (Econst_int (Int.repr 4) tint) tint)
          (Ssequence
            (Scall None
              (Evar _vec3s_copy (Tfunction
                                  ((tptr tshort) :: (tptr tshort) :: nil)
                                  (tptr tvoid) cc_default))
              ((Evar _camTo (tarray tshort 3)) ::
               (Evar _gVec3sZero (tarray tshort 3)) :: nil))
            (Ssequence
              (Scall None
                (Evar _vec3s_copy (Tfunction
                                    ((tptr tshort) :: (tptr tshort) :: nil)
                                    (tptr tvoid) cc_default))
                ((Evar _camFrom (tarray tshort 3)) ::
                 (Evar _gVec3sZero (tarray tshort 3)) :: nil))
              (Ssequence
                (Scall None
                  (Evar _vec3s_copy (Tfunction
                                      ((tptr tshort) :: (tptr tshort) :: nil)
                                      (tptr tvoid) cc_default))
                  ((Evar _marioPos (tarray tshort 3)) ::
                   (Evar _gVec3sZero (tarray tshort 3)) :: nil))
                (Scall None
                  (Evar _envfx_update_particles (Tfunction
                                                  (tint :: (tptr tshort) ::
                                                   (tptr tshort) ::
                                                   (tptr tshort) :: nil)
                                                  (tptr (Tunion __512 noattr))
                                                  cc_default))
                  ((Econst_int (Int.repr 0) tint) ::
                   (Evar _marioPos (tarray tshort 3)) ::
                   (Evar _camTo (tarray tshort 3)) ::
                   (Evar _camFrom (tarray tshort 3)) :: nil)))))
          Sskip)))
    (Sreturn (Some (Etempvar _gfx (tptr (Tunion __512 noattr)))))))
|}.

Definition f_geo_skybox_main := {|
  fn_return := (tptr (Tunion __512 noattr));
  fn_callconv := cc_default;
  fn_params := ((_callContext, tint) ::
                (_node, (tptr (Tstruct _GraphNode noattr))) ::
                (_mtx, (tptr (tarray (tarray tfloat 4) 4))) :: nil);
  fn_vars := nil;
  fn_temps := ((_gfx, (tptr (Tunion __512 noattr))) ::
               (_backgroundNode,
                (tptr (Tstruct _GraphNodeBackground noattr))) ::
               (_camNode, (tptr (Tstruct _GraphNodeCamera noattr))) ::
               (_camFrustum, (tptr (Tstruct _GraphNodePerspective noattr))) ::
               (_t'1, (tptr (Tunion __512 noattr))) ::
               (_t'13, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'12, (tptr (tptr (Tstruct _GraphNode noattr)))) ::
               (_t'11, (tptr (Tstruct _GraphNodeRoot noattr))) ::
               (_t'10, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'9, tfloat) :: (_t'8, tfloat) :: (_t'7, tfloat) ::
               (_t'6, tfloat) :: (_t'5, tfloat) :: (_t'4, tfloat) ::
               (_t'3, tfloat) :: (_t'2, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _gfx (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Sset _backgroundNode
      (Ecast (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
        (tptr (Tstruct _GraphNodeBackground noattr))))
    (Ssequence
      (Sifthenelse (Ebinop Oeq (Etempvar _callContext tint)
                     (Econst_int (Int.repr 3) tint) tint)
        (Sassign
          (Efield
            (Ederef
              (Etempvar _backgroundNode (tptr (Tstruct _GraphNodeBackground noattr)))
              (Tstruct _GraphNodeBackground noattr)) _unused tint)
          (Econst_int (Int.repr 0) tint))
        (Sifthenelse (Ebinop Oeq (Etempvar _callContext tint)
                       (Econst_int (Int.repr 1) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'11
                (Evar _gCurGraphNodeRoot (tptr (Tstruct _GraphNodeRoot noattr))))
              (Ssequence
                (Sset _t'12
                  (Efield
                    (Ederef
                      (Etempvar _t'11 (tptr (Tstruct _GraphNodeRoot noattr)))
                      (Tstruct _GraphNodeRoot noattr)) _views
                    (tptr (tptr (Tstruct _GraphNode noattr)))))
                (Ssequence
                  (Sset _t'13
                    (Ederef
                      (Ebinop Oadd
                        (Etempvar _t'12 (tptr (tptr (Tstruct _GraphNode noattr))))
                        (Econst_int (Int.repr 0) tint)
                        (tptr (tptr (Tstruct _GraphNode noattr))))
                      (tptr (Tstruct _GraphNode noattr))))
                  (Sset _camNode
                    (Ecast
                      (Etempvar _t'13 (tptr (Tstruct _GraphNode noattr)))
                      (tptr (Tstruct _GraphNodeCamera noattr)))))))
            (Ssequence
              (Ssequence
                (Sset _t'10
                  (Efield
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _camNode (tptr (Tstruct _GraphNodeCamera noattr)))
                          (Tstruct _GraphNodeCamera noattr)) _fnNode
                        (Tstruct _FnGraphNode noattr)) _node
                      (Tstruct _GraphNode noattr)) _parent
                    (tptr (Tstruct _GraphNode noattr))))
                (Sset _camFrustum
                  (Ecast (Etempvar _t'10 (tptr (Tstruct _GraphNode noattr)))
                    (tptr (Tstruct _GraphNodePerspective noattr)))))
              (Ssequence
                (Ssequence
                  (Sset _t'2
                    (Efield
                      (Ederef
                        (Etempvar _backgroundNode (tptr (Tstruct _GraphNodeBackground noattr)))
                        (Tstruct _GraphNodeBackground noattr)) _background
                      tint))
                  (Ssequence
                    (Sset _t'3
                      (Efield
                        (Ederef
                          (Etempvar _camFrustum (tptr (Tstruct _GraphNodePerspective noattr)))
                          (Tstruct _GraphNodePerspective noattr)) _fov
                        tfloat))
                    (Ssequence
                      (Sset _t'4
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Evar _gLakituState (Tstruct _LakituState noattr))
                              _pos (tarray tfloat 3))
                            (Econst_int (Int.repr 0) tint) (tptr tfloat))
                          tfloat))
                      (Ssequence
                        (Sset _t'5
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Evar _gLakituState (Tstruct _LakituState noattr))
                                _pos (tarray tfloat 3))
                              (Econst_int (Int.repr 1) tint) (tptr tfloat))
                            tfloat))
                        (Ssequence
                          (Sset _t'6
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Evar _gLakituState (Tstruct _LakituState noattr))
                                  _pos (tarray tfloat 3))
                                (Econst_int (Int.repr 2) tint) (tptr tfloat))
                              tfloat))
                          (Ssequence
                            (Sset _t'7
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Evar _gLakituState (Tstruct _LakituState noattr))
                                    _focus (tarray tfloat 3))
                                  (Econst_int (Int.repr 0) tint)
                                  (tptr tfloat)) tfloat))
                            (Ssequence
                              (Sset _t'8
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Evar _gLakituState (Tstruct _LakituState noattr))
                                      _focus (tarray tfloat 3))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr tfloat)) tfloat))
                              (Ssequence
                                (Sset _t'9
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Evar _gLakituState (Tstruct _LakituState noattr))
                                        _focus (tarray tfloat 3))
                                      (Econst_int (Int.repr 2) tint)
                                      (tptr tfloat)) tfloat))
                                (Scall (Some _t'1)
                                  (Evar _create_skybox_facing_camera
                                  (Tfunction
                                    (tschar :: tschar :: tfloat :: tfloat ::
                                     tfloat :: tfloat :: tfloat :: tfloat ::
                                     tfloat :: nil)
                                    (tptr (Tunion __512 noattr)) cc_default))
                                  ((Econst_int (Int.repr 0) tint) ::
                                   (Etempvar _t'2 tint) ::
                                   (Etempvar _t'3 tfloat) ::
                                   (Etempvar _t'4 tfloat) ::
                                   (Etempvar _t'5 tfloat) ::
                                   (Etempvar _t'6 tfloat) ::
                                   (Etempvar _t'7 tfloat) ::
                                   (Etempvar _t'8 tfloat) ::
                                   (Etempvar _t'9 tfloat) :: nil))))))))))
                (Sset _gfx (Etempvar _t'1 (tptr (Tunion __512 noattr)))))))
          Sskip))
      (Sreturn (Some (Etempvar _gfx (tptr (Tunion __512 noattr))))))))
|}.

Definition composites : list composite_definition :=
(Composite __472 Union
   (Member_plain _m (tarray (tarray tint 4) 4) ::
    Member_plain _force_structure_alignment tlong :: nil)
   noattr ::
 Composite __510 Struct
   (Member_plain _w0 tuint :: Member_plain _w1 tuint :: nil)
   noattr ::
 Composite __512 Union
   (Member_plain _words (Tstruct __510 noattr) ::
    Member_plain _force_structure_alignment tlong :: nil)
   noattr ::
 Composite _Animation Struct
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
 Composite __727 Union
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
    Member_plain _rawData (Tunion __727 noattr) ::
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
 Composite __732 Struct
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
    Member_plain _normal (Tstruct __732 noattr) ::
    Member_plain _originOffset tfloat ::
    Member_plain _object (tptr (Tstruct _Object noattr)) :: nil)
   noattr ::
 Composite _FnGraphNode Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _func
      (tptr (Tfunction
              (tint :: (tptr (Tstruct _GraphNode noattr)) :: (tptr tvoid) ::
               nil) (tptr (Tunion __512 noattr)) cc_default)) :: nil)
   noattr ::
 Composite _GraphNodeRoot Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _areaIndex tuchar :: Member_plain _unk15 tschar ::
    Member_plain _x tshort :: Member_plain _y tshort ::
    Member_plain _width tshort :: Member_plain _height tshort ::
    Member_plain _numViews tshort ::
    Member_plain _views (tptr (tptr (Tstruct _GraphNode noattr))) :: nil)
   noattr ::
 Composite _GraphNodePerspective Struct
   (Member_plain _fnNode (Tstruct _FnGraphNode noattr) ::
    Member_plain _unused tint :: Member_plain _fov tfloat ::
    Member_plain _near tshort :: Member_plain _far tshort :: nil)
   noattr ::
 Composite __1069 Union
   (Member_plain _mode tint ::
    Member_plain _camera (tptr (Tstruct _Camera noattr)) :: nil)
   noattr ::
 Composite _GraphNodeCamera Struct
   (Member_plain _fnNode (Tstruct _FnGraphNode noattr) ::
    Member_plain _config (Tunion __1069 noattr) ::
    Member_plain _pos (tarray tfloat 3) ::
    Member_plain _focus (tarray tfloat 3) ::
    Member_plain _matrixPtr (tptr (tarray (tarray tfloat 4) 4)) ::
    Member_plain _roll tshort :: Member_plain _rollScreen tshort :: nil)
   noattr ::
 Composite _GraphNodeGenerated Struct
   (Member_plain _fnNode (Tstruct _FnGraphNode noattr) ::
    Member_plain _parameter tuint :: nil)
   noattr ::
 Composite _GraphNodeBackground Struct
   (Member_plain _fnNode (Tstruct _FnGraphNode noattr) ::
    Member_plain _unused tint :: Member_plain _background tint :: nil)
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
 Composite _PlayerCameraState Struct
   (Member_plain _action tuint :: Member_plain _pos (tarray tfloat 3) ::
    Member_plain _faceAngle (tarray tshort 3) ::
    Member_plain _headRotation (tarray tshort 3) ::
    Member_plain _unused tshort :: Member_plain _cameraEvent tshort ::
    Member_plain _usedObj (tptr (Tstruct _Object noattr)) :: nil)
   noattr ::
 Composite _Camera Struct
   (Member_plain _mode tuchar :: Member_plain _defMode tuchar ::
    Member_plain _yaw tshort :: Member_plain _focus (tarray tfloat 3) ::
    Member_plain _pos (tarray tfloat 3) ::
    Member_plain _unusedVec1 (tarray tfloat 3) ::
    Member_plain _areaCenX tfloat :: Member_plain _areaCenZ tfloat ::
    Member_plain _cutscene tuchar ::
    Member_plain _filler1 (tarray tuchar 8) ::
    Member_plain _nextYaw tshort ::
    Member_plain _filler2 (tarray tuchar 40) ::
    Member_plain _doorStatus tuchar :: Member_plain _areaCenY tfloat :: nil)
   noattr ::
 Composite _LakituState Struct
   (Member_plain _curFocus (tarray tfloat 3) ::
    Member_plain _curPos (tarray tfloat 3) ::
    Member_plain _goalFocus (tarray tfloat 3) ::
    Member_plain _goalPos (tarray tfloat 3) ::
    Member_plain _filler1 (tarray tuchar 12) :: Member_plain _mode tuchar ::
    Member_plain _defMode tuchar ::
    Member_plain _filler2 (tarray tuchar 10) ::
    Member_plain _focusDistance tfloat :: Member_plain _oldPitch tshort ::
    Member_plain _oldYaw tshort :: Member_plain _oldRoll tshort ::
    Member_plain _shakeMagnitude (tarray tshort 3) ::
    Member_plain _shakePitchPhase tshort ::
    Member_plain _shakePitchVel tshort ::
    Member_plain _shakePitchDecay tshort ::
    Member_plain _unusedVec1 (tarray tfloat 3) ::
    Member_plain _unusedVec2 (tarray tshort 3) ::
    Member_plain _filler3 (tarray tuchar 8) :: Member_plain _roll tshort ::
    Member_plain _yaw tshort :: Member_plain _nextYaw tshort ::
    Member_plain _focus (tarray tfloat 3) ::
    Member_plain _pos (tarray tfloat 3) ::
    Member_plain _shakeRollPhase tshort ::
    Member_plain _shakeRollVel tshort ::
    Member_plain _shakeRollDecay tshort ::
    Member_plain _shakeYawPhase tshort :: Member_plain _shakeYawVel tshort ::
    Member_plain _shakeYawDecay tshort :: Member_plain _focHSpeed tfloat ::
    Member_plain _focVSpeed tfloat :: Member_plain _posHSpeed tfloat ::
    Member_plain _posVSpeed tfloat :: Member_plain _keyDanceRoll tshort ::
    Member_plain _lastFrameAction tuint :: Member_plain _unused tshort ::
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
 (_alloc_display_list,
   Gfun(External (EF_external "alloc_display_list"
                   (mksignature (AST.Xint :: nil) AST.Xptr cc_default))
     (tuint :: nil) (tptr tvoid) cc_default)) ::
 (_gVec3sZero, Gvar v_gVec3sZero) ::
 (_gCurGraphNodeRoot, Gvar v_gCurGraphNodeRoot) ::
 (_gCurGraphNodeCamera, Gvar v_gCurGraphNodeCamera) ::
 (_gAreaUpdateCounter, Gvar v_gAreaUpdateCounter) ::
 (_create_skybox_facing_camera,
   Gfun(External (EF_external "create_skybox_facing_camera"
                   (mksignature
                     (AST.Xint8signed :: AST.Xint8signed :: AST.Xsingle ::
                      AST.Xsingle :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xsingle :: AST.Xsingle :: AST.Xsingle :: nil)
                     AST.Xptr cc_default))
     (tschar :: tschar :: tfloat :: tfloat :: tfloat :: tfloat :: tfloat ::
      tfloat :: tfloat :: nil) (tptr (Tunion __512 noattr)) cc_default)) ::
 (_vec3s_copy,
   Gfun(External (EF_external "vec3s_copy"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xptr
                     cc_default)) ((tptr tshort) :: (tptr tshort) :: nil)
     (tptr tvoid) cc_default)) ::
 (_vec3f_to_vec3s,
   Gfun(External (EF_external "vec3f_to_vec3s"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xptr
                     cc_default)) ((tptr tshort) :: (tptr tfloat) :: nil)
     (tptr tvoid) cc_default)) ::
 (_mtxf_to_mtx,
   Gfun(External (EF_external "mtxf_to_mtx"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tunion __472 noattr)) :: (tptr (tarray tfloat 4)) :: nil) tvoid
     cc_default)) :: (_gPlayerCameraState, Gvar v_gPlayerCameraState) ::
 (_gLakituState, Gvar v_gLakituState) ::
 (_envfx_update_particles,
   Gfun(External (EF_external "envfx_update_particles"
                   (mksignature
                     (AST.Xint :: AST.Xptr :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xptr cc_default))
     (tint :: (tptr tshort) :: (tptr tshort) :: (tptr tshort) :: nil)
     (tptr (Tunion __512 noattr)) cc_default)) ::
 (_geo_envfx_main, Gfun(Internal f_geo_envfx_main)) ::
 (_geo_skybox_main, Gfun(Internal f_geo_skybox_main)) :: nil).

Definition public_idents : list ident :=
(_geo_skybox_main :: _geo_envfx_main :: _envfx_update_particles ::
 _gLakituState :: _gPlayerCameraState :: _mtxf_to_mtx :: _vec3f_to_vec3s ::
 _vec3s_copy :: _create_skybox_facing_camera :: _gAreaUpdateCounter ::
 _gCurGraphNodeCamera :: _gCurGraphNodeRoot :: _gVec3sZero ::
 _alloc_display_list :: ___builtin_debug :: ___builtin_sync_fetch_and_add ::
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
