(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Produced by: pipeline/clightgen.sh
   From source: vendor/sm64/src/game/mario_actions_object.c
   clightgen:   The CompCert CompCert AST generator, version 3.15
   Flags:       -normalize -nostdinc -fstruct-passing -Ivendor/sm64/include -Ivendor/sm64/build/us -Ivendor/sm64/build/us/include -Ivendor/sm64/src -Ivendor/sm64 -Ivendor/sm64/include/libc -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1 -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1
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
  Definition arch := "x86".
  Definition model := "64".
  Definition abi := "standard".
  Definition bitsize := 64.
  Definition big_endian := false.
  Definition source_file := "vendor/sm64/src/game/mario_actions_object.c".
  Definition normalized := true.
End Info.

Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _Area : ident := $"Area".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _Controller : ident := $"Controller".
Definition _DmaHandlerList : ident := $"DmaHandlerList".
Definition _GraphNode : ident := $"GraphNode".
Definition _GraphNodeObject : ident := $"GraphNodeObject".
Definition _MarioBodyState : ident := $"MarioBodyState".
Definition _MarioState : ident := $"MarioState".
Definition _Object : ident := $"Object".
Definition _ObjectNode : ident := $"ObjectNode".
Definition _PlayerCameraState : ident := $"PlayerCameraState".
Definition _SpawnInfo : ident := $"SpawnInfo".
Definition _Surface : ident := $"Surface".
Definition _Waypoint : ident := $"Waypoint".
Definition __218 : ident := $"_218".
Definition __220 : ident := $"_220".
Definition __665 : ident := $"_665".
Definition __670 : ident := $"_670".
Definition ___builtin_ais_annot : ident := $"__builtin_ais_annot".
Definition ___builtin_annot : ident := $"__builtin_annot".
Definition ___builtin_annot_intval : ident := $"__builtin_annot_intval".
Definition ___builtin_bswap : ident := $"__builtin_bswap".
Definition ___builtin_bswap16 : ident := $"__builtin_bswap16".
Definition ___builtin_bswap32 : ident := $"__builtin_bswap32".
Definition ___builtin_bswap64 : ident := $"__builtin_bswap64".
Definition ___builtin_clz : ident := $"__builtin_clz".
Definition ___builtin_clzl : ident := $"__builtin_clzl".
Definition ___builtin_clzll : ident := $"__builtin_clzll".
Definition ___builtin_ctz : ident := $"__builtin_ctz".
Definition ___builtin_ctzl : ident := $"__builtin_ctzl".
Definition ___builtin_ctzll : ident := $"__builtin_ctzll".
Definition ___builtin_debug : ident := $"__builtin_debug".
Definition ___builtin_expect : ident := $"__builtin_expect".
Definition ___builtin_fabs : ident := $"__builtin_fabs".
Definition ___builtin_fabsf : ident := $"__builtin_fabsf".
Definition ___builtin_fmadd : ident := $"__builtin_fmadd".
Definition ___builtin_fmax : ident := $"__builtin_fmax".
Definition ___builtin_fmin : ident := $"__builtin_fmin".
Definition ___builtin_fmsub : ident := $"__builtin_fmsub".
Definition ___builtin_fnmadd : ident := $"__builtin_fnmadd".
Definition ___builtin_fnmsub : ident := $"__builtin_fnmsub".
Definition ___builtin_fsqrt : ident := $"__builtin_fsqrt".
Definition ___builtin_membar : ident := $"__builtin_membar".
Definition ___builtin_memcpy_aligned : ident := $"__builtin_memcpy_aligned".
Definition ___builtin_read16_reversed : ident := $"__builtin_read16_reversed".
Definition ___builtin_read32_reversed : ident := $"__builtin_read32_reversed".
Definition ___builtin_sel : ident := $"__builtin_sel".
Definition ___builtin_sqrt : ident := $"__builtin_sqrt".
Definition ___builtin_unreachable : ident := $"__builtin_unreachable".
Definition ___builtin_va_arg : ident := $"__builtin_va_arg".
Definition ___builtin_va_copy : ident := $"__builtin_va_copy".
Definition ___builtin_va_end : ident := $"__builtin_va_end".
Definition ___builtin_va_start : ident := $"__builtin_va_start".
Definition ___builtin_write16_reversed : ident := $"__builtin_write16_reversed".
Definition ___builtin_write32_reversed : ident := $"__builtin_write32_reversed".
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
Definition _act_dive_picking_up : ident := $"act_dive_picking_up".
Definition _act_heavy_throw : ident := $"act_heavy_throw".
Definition _act_holding_bowser : ident := $"act_holding_bowser".
Definition _act_picking_up : ident := $"act_picking_up".
Definition _act_picking_up_bowser : ident := $"act_picking_up_bowser".
Definition _act_placing_down : ident := $"act_placing_down".
Definition _act_punching : ident := $"act_punching".
Definition _act_releasing_bowser : ident := $"act_releasing_bowser".
Definition _act_stomach_slide_stop : ident := $"act_stomach_slide_stop".
Definition _act_throwing : ident := $"act_throwing".
Definition _action : ident := $"action".
Definition _actionArg : ident := $"actionArg".
Definition _actionState : ident := $"actionState".
Definition _actionTimer : ident := $"actionTimer".
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _angle : ident := $"angle".
Definition _angleVel : ident := $"angleVel".
Definition _animAccel : ident := $"animAccel".
Definition _animFrame : ident := $"animFrame".
Definition _animFrameAccelAssist : ident := $"animFrameAccelAssist".
Definition _animID : ident := $"animID".
Definition _animInfo : ident := $"animInfo".
Definition _animList : ident := $"animList".
Definition _animTimer : ident := $"animTimer".
Definition _animYTrans : ident := $"animYTrans".
Definition _animYTransDivisor : ident := $"animYTransDivisor".
Definition _animated_stationary_ground_step : ident := $"animated_stationary_ground_step".
Definition _animation : ident := $"animation".
Definition _approach_s32 : ident := $"approach_s32".
Definition _area : ident := $"area".
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
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _button : ident := $"button".
Definition _buttonDown : ident := $"buttonDown".
Definition _buttonPressed : ident := $"buttonPressed".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _cancel : ident := $"cancel".
Definition _capState : ident := $"capState".
Definition _capTimer : ident := $"capTimer".
Definition _ceil : ident := $"ceil".
Definition _ceilHeight : ident := $"ceilHeight".
Definition _check_common_action_exits : ident := $"check_common_action_exits".
Definition _check_common_object_cancels : ident := $"check_common_object_cancels".
Definition _children : ident := $"children".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _controller : ident := $"controller".
Definition _controllerData : ident := $"controllerData".
Definition _crouchEndAction : ident := $"crouchEndAction".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _doubleJumpTimer : ident := $"doubleJumpTimer".
Definition _drop_and_set_mario_action : ident := $"drop_and_set_mario_action".
Definition _endAction : ident := $"endAction".
Definition _errnum : ident := $"errnum".
Definition _eyeState : ident := $"eyeState".
Definition _faceAngle : ident := $"faceAngle".
Definition _fadeWarpOpacity : ident := $"fadeWarpOpacity".
Definition _filler : ident := $"filler".
Definition _flags : ident := $"flags".
Definition _floor : ident := $"floor".
Definition _floorAngle : ident := $"floorAngle".
Definition _floorHeight : ident := $"floorHeight".
Definition _force : ident := $"force".
Definition _forwardVel : ident := $"forwardVel".
Definition _framesSinceA : ident := $"framesSinceA".
Definition _framesSinceB : ident := $"framesSinceB".
Definition _gettingBlownGravity : ident := $"gettingBlownGravity".
Definition _gfx : ident := $"gfx".
Definition _grabPos : ident := $"grabPos".
Definition _handState : ident := $"handState".
Definition _headAngle : ident := $"headAngle".
Definition _header : ident := $"header".
Definition _healCounter : ident := $"healCounter".
Definition _health : ident := $"health".
Definition _heldObj : ident := $"heldObj".
Definition _heldObjLastPosition : ident := $"heldObjLastPosition".
Definition _hitboxDownOffset : ident := $"hitboxDownOffset".
Definition _hitboxHeight : ident := $"hitboxHeight".
Definition _hitboxRadius : ident := $"hitboxRadius".
Definition _hurtCounter : ident := $"hurtCounter".
Definition _hurtboxHeight : ident := $"hurtboxHeight".
Definition _hurtboxRadius : ident := $"hurtboxRadius".
Definition _index : ident := $"index".
Definition _input : ident := $"input".
Definition _intendedMag : ident := $"intendedMag".
Definition _intendedYaw : ident := $"intendedYaw".
Definition _interactObj : ident := $"interactObj".
Definition _invincTimer : ident := $"invincTimer".
Definition _is_anim_at_end : ident := $"is_anim_at_end".
Definition _is_anim_past_end : ident := $"is_anim_past_end".
Definition _length : ident := $"length".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _m : ident := $"m".
Definition _main : ident := $"main".
Definition _marioBodyState : ident := $"marioBodyState".
Definition _marioObj : ident := $"marioObj".
Definition _mario_check_object_grab : ident := $"mario_check_object_grab".
Definition _mario_drop_held_object : ident := $"mario_drop_held_object".
Definition _mario_execute_object_action : ident := $"mario_execute_object_action".
Definition _mario_grab_used_object : ident := $"mario_grab_used_object".
Definition _mario_set_forward_vel : ident := $"mario_set_forward_vel".
Definition _mario_throw_held_object : ident := $"mario_throw_held_object".
Definition _mario_update_punch_sequence : ident := $"mario_update_punch_sequence".
Definition _mario_update_quicksand : ident := $"mario_update_quicksand".
Definition _modelState : ident := $"modelState".
Definition _next : ident := $"next".
Definition _node : ident := $"node".
Definition _normal : ident := $"normal".
Definition _numCoins : ident := $"numCoins".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _numKeys : ident := $"numKeys".
Definition _numLives : ident := $"numLives".
Definition _numStars : ident := $"numStars".
Definition _object : ident := $"object".
Definition _originOffset : ident := $"originOffset".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _particleFlags : ident := $"particleFlags".
Definition _peakHeight : ident := $"peakHeight".
Definition _perform_ground_step : ident := $"perform_ground_step".
Definition _platform : ident := $"platform".
Definition _play_mario_action_sound : ident := $"play_mario_action_sound".
Definition _play_sound : ident := $"play_sound".
Definition _play_sound_if_no_flag : ident := $"play_sound_if_no_flag".
Definition _pos : ident := $"pos".
Definition _prev : ident := $"prev".
Definition _prevAction : ident := $"prevAction".
Definition _prevNumStarsForDialog : ident := $"prevNumStarsForDialog".
Definition _prevObj : ident := $"prevObj".
Definition _punchState : ident := $"punchState".
Definition _quicksandDepth : ident := $"quicksandDepth".
Definition _rawData : ident := $"rawData".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _riddenObj : ident := $"riddenObj".
Definition _room : ident := $"room".
Definition _sPunchingForwardVelocities : ident := $"sPunchingForwardVelocities".
Definition _scale : ident := $"scale".
Definition _set_mario_action : ident := $"set_mario_action".
Definition _set_mario_animation : ident := $"set_mario_animation".
Definition _set_water_plunge_action : ident := $"set_water_plunge_action".
Definition _sharedChild : ident := $"sharedChild".
Definition _slideVelX : ident := $"slideVelX".
Definition _slideVelZ : ident := $"slideVelZ".
Definition _slideYaw : ident := $"slideYaw".
Definition _spawnInfo : ident := $"spawnInfo".
Definition _spin : ident := $"spin".
Definition _squishTimer : ident := $"squishTimer".
Definition _startFrame : ident := $"startFrame".
Definition _stationary_ground_step : ident := $"stationary_ground_step".
Definition _status : ident := $"status".
Definition _statusData : ident := $"statusData".
Definition _statusForCamera : ident := $"statusForCamera".
Definition _stickMag : ident := $"stickMag".
Definition _stickX : ident := $"stickX".
Definition _stickY : ident := $"stickY".
Definition _stick_x : ident := $"stick_x".
Definition _stick_y : ident := $"stick_y".
Definition _terrainSoundAddend : ident := $"terrainSoundAddend".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _torsoAngle : ident := $"torsoAngle".
Definition _transform : ident := $"transform".
Definition _twirlYaw : ident := $"twirlYaw".
Definition _type : ident := $"type".
Definition _unk00 : ident := $"unk00".
Definition _unk4C : ident := $"unk4C".
Definition _unkB0 : ident := $"unkB0".
Definition _unused1 : ident := $"unused1".
Definition _unused2 : ident := $"unused2".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _upperY : ident := $"upperY".
Definition _usedObj : ident := $"usedObj".
Definition _values : ident := $"values".
Definition _vel : ident := $"vel".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _wall : ident := $"wall".
Definition _wallKickTimer : ident := $"wallKickTimer".
Definition _waterLevel : ident := $"waterLevel".
Definition _waterSurface : ident := $"waterSurface".
Definition _wingFlutter : ident := $"wingFlutter".
Definition _x : ident := $"x".
Definition _y : ident := $"y".
Definition _z : ident := $"z".
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

Definition v_sPunchingForwardVelocities := {|
  gvar_info := (tarray tschar 8);
  gvar_init := (Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 3) :: Init_int8 (Int.repr 5) ::
                Init_int8 (Int.repr 7) :: Init_int8 (Int.repr 10) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_animated_stationary_ground_step := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_animation, tint) :: (_endAction, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _stationary_ground_step (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tint cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
  (Ssequence
    (Scall None
      (Evar _set_mario_animation (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _animation tint) :: nil))
    (Ssequence
      (Scall (Some _t'1)
        (Evar _is_anim_at_end (Tfunction
                                ((tptr (Tstruct _MarioState noattr)) :: nil)
                                tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Sifthenelse (Etempvar _t'1 tint)
        (Scall None
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Etempvar _endAction tuint) :: (Econst_int (Int.repr 0) tint) ::
           nil))
        Sskip))))
|}.

Definition f_mario_update_punch_sequence := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_endAction, tuint) :: (_crouchEndAction, tuint) ::
               (_animFrame, tint) :: (_t'10, tint) :: (_t'9, tint) ::
               (_t'8, tint) :: (_t'7, tint) :: (_t'6, tshort) ::
               (_t'5, tint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tuint) :: (_t'1, tint) :: (_t'36, tuint) ::
               (_t'35, (tptr (Tstruct _Object noattr))) :: (_t'34, tuint) ::
               (_t'33, tshort) :: (_t'32, (tptr (Tstruct _Object noattr))) ::
               (_t'31, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'30, tuint) :: (_t'29, tuint) :: (_t'28, tshort) ::
               (_t'27, (tptr (Tstruct _Object noattr))) ::
               (_t'26, tushort) ::
               (_t'25, (tptr (Tstruct _Object noattr))) :: (_t'24, tuint) ::
               (_t'23, tshort) :: (_t'22, (tptr (Tstruct _Object noattr))) ::
               (_t'21, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'20, tuint) :: (_t'19, tuint) :: (_t'18, tshort) ::
               (_t'17, (tptr (Tstruct _Object noattr))) ::
               (_t'16, tushort) ::
               (_t'15, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'14, tuint) :: (_t'13, (tptr (Tstruct _Object noattr))) ::
               (_t'12, tuint) :: (_t'11, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'36
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _action tuint))
    (Sifthenelse (Ebinop Oand (Etempvar _t'36 tuint)
                   (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                     (Econst_int (Int.repr 10) tint) tint) tuint)
      (Ssequence
        (Sset _endAction (Econst_int (Int.repr 67109952) tint))
        (Sset _crouchEndAction (Econst_int (Int.repr 75531353) tint)))
      (Ssequence
        (Sset _endAction (Econst_int (Int.repr 205521409) tint))
        (Sset _crouchEndAction (Econst_int (Int.repr 201359904) tint)))))
  (Ssequence
    (Ssequence
      (Sset _t'11
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionArg tuint))
      (Sswitch (Etempvar _t'11 tuint)
        (LScons (Some 0)
          (Ssequence
            (Sset _t'35
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _marioObj
                (tptr (Tstruct _Object noattr))))
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
                         (Ecast (Econst_int (Int.repr 30) tint) tuint)
                         (Econst_int (Int.repr 16) tint) tuint) tuint)
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 128) tint) tuint)
                       (Econst_int (Int.repr 8) tint) tuint) tuint)
                   (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                     (Econst_int (Int.repr 128) tint) tint) tuint)
                 (Econst_int (Int.repr 1) tint) tuint) ::
               (Efield
                 (Efield
                   (Efield
                     (Ederef (Etempvar _t'35 (tptr (Tstruct _Object noattr)))
                       (Tstruct _Object noattr)) _header
                     (Tstruct _ObjectNode noattr)) _gfx
                   (Tstruct _GraphNodeObject noattr)) _cameraToObject
                 (tarray tfloat 3)) :: nil)))
          (LScons (Some 1)
            (Ssequence
              (Scall None
                (Evar _set_mario_animation (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tint :: nil) tshort cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 103) tint) :: nil))
              (Ssequence
                (Ssequence
                  (Scall (Some _t'1)
                    (Evar _is_anim_past_end (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Sifthenelse (Etempvar _t'1 tint)
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionArg tuint)
                      (Econst_int (Int.repr 2) tint))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionArg tuint)
                      (Econst_int (Int.repr 1) tint))))
                (Ssequence
                  (Ssequence
                    (Sset _t'32
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _marioObj
                        (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sset _t'33
                        (Efield
                          (Efield
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'32 (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _header
                                (Tstruct _ObjectNode noattr)) _gfx
                              (Tstruct _GraphNodeObject noattr)) _animInfo
                            (Tstruct _AnimInfo noattr)) _animFrame tshort))
                      (Sifthenelse (Ebinop Oge (Etempvar _t'33 tshort)
                                     (Econst_int (Int.repr 2) tint) tint)
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'2)
                              (Evar _mario_check_object_grab (Tfunction
                                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                                nil) tuint
                                                               cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               nil))
                            (Sifthenelse (Etempvar _t'2 tuint)
                              (Sreturn (Some (Econst_int (Int.repr 1) tint)))
                              Sskip))
                          (Ssequence
                            (Sset _t'34
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _flags tuint))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _flags tuint)
                              (Ebinop Oor (Etempvar _t'34 tuint)
                                (Econst_int (Int.repr 1048576) tint) tuint))))
                        Sskip)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'30
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionArg tuint))
                      (Sifthenelse (Ebinop Oeq (Etempvar _t'30 tuint)
                                     (Econst_int (Int.repr 2) tint) tint)
                        (Ssequence
                          (Sset _t'31
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _marioBodyState
                              (tptr (Tstruct _MarioBodyState noattr))))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _t'31 (tptr (Tstruct _MarioBodyState noattr)))
                                (Tstruct _MarioBodyState noattr)) _punchState
                              tuchar)
                            (Ebinop Oor
                              (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                                (Econst_int (Int.repr 6) tint) tint)
                              (Econst_int (Int.repr 4) tint) tint)))
                        Sskip))
                    Sbreak))))
            (LScons (Some 2)
              (Ssequence
                (Scall None
                  (Evar _set_mario_animation (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tint :: nil) tshort
                                               cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 105) tint) :: nil))
                (Ssequence
                  (Ssequence
                    (Sset _t'27
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _marioObj
                        (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sset _t'28
                        (Efield
                          (Efield
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'27 (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _header
                                (Tstruct _ObjectNode noattr)) _gfx
                              (Tstruct _GraphNodeObject noattr)) _animInfo
                            (Tstruct _AnimInfo noattr)) _animFrame tshort))
                      (Sifthenelse (Ebinop Ole (Etempvar _t'28 tshort)
                                     (Econst_int (Int.repr 0) tint) tint)
                        (Ssequence
                          (Sset _t'29
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _flags tuint))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _flags tuint)
                            (Ebinop Oor (Etempvar _t'29 tuint)
                              (Econst_int (Int.repr 1048576) tint) tuint)))
                        Sskip)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'26
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _input tushort))
                      (Sifthenelse (Ebinop Oand (Etempvar _t'26 tushort)
                                     (Econst_int (Int.repr 8192) tint) tint)
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _actionArg tuint)
                          (Econst_int (Int.repr 3) tint))
                        Sskip))
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'3)
                          (Evar _is_anim_at_end (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        (Sifthenelse (Etempvar _t'3 tint)
                          (Scall None
                            (Evar _set_mario_action (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: tuint :: nil)
                                                      tuint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Etempvar _endAction tuint) ::
                             (Econst_int (Int.repr 0) tint) :: nil))
                          Sskip))
                      Sbreak))))
              (LScons (Some 3)
                (Ssequence
                  (Sset _t'25
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _marioObj
                      (tptr (Tstruct _Object noattr))))
                  (Scall None
                    (Evar _play_sound (Tfunction
                                        (tint :: (tptr tfloat) :: nil) tvoid
                                        cc_default))
                    ((Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 2) tint) tuint)
                               (Econst_int (Int.repr 28) tint) tuint)
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 36) tint) tuint)
                               (Econst_int (Int.repr 16) tint) tuint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 128) tint) tuint)
                             (Econst_int (Int.repr 8) tint) tuint) tuint)
                         (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                           (Econst_int (Int.repr 128) tint) tint) tuint)
                       (Econst_int (Int.repr 1) tint) tuint) ::
                     (Efield
                       (Efield
                         (Efield
                           (Ederef
                             (Etempvar _t'25 (tptr (Tstruct _Object noattr)))
                             (Tstruct _Object noattr)) _header
                           (Tstruct _ObjectNode noattr)) _gfx
                         (Tstruct _GraphNodeObject noattr)) _cameraToObject
                       (tarray tfloat 3)) :: nil)))
                (LScons (Some 4)
                  (Ssequence
                    (Scall None
                      (Evar _set_mario_animation (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: nil) tshort
                                                   cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 104) tint) :: nil))
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'4)
                          (Evar _is_anim_past_end (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        (Sifthenelse (Etempvar _t'4 tint)
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _actionArg
                              tuint) (Econst_int (Int.repr 5) tint))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _actionArg
                              tuint) (Econst_int (Int.repr 4) tint))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'22
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _marioObj
                              (tptr (Tstruct _Object noattr))))
                          (Ssequence
                            (Sset _t'23
                              (Efield
                                (Efield
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'22 (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _header
                                      (Tstruct _ObjectNode noattr)) _gfx
                                    (Tstruct _GraphNodeObject noattr))
                                  _animInfo (Tstruct _AnimInfo noattr))
                                _animFrame tshort))
                            (Sifthenelse (Ebinop Ogt (Etempvar _t'23 tshort)
                                           (Econst_int (Int.repr 0) tint)
                                           tint)
                              (Ssequence
                                (Sset _t'24
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _flags
                                    tuint))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _flags
                                    tuint)
                                  (Ebinop Oor (Etempvar _t'24 tuint)
                                    (Econst_int (Int.repr 1048576) tint)
                                    tuint)))
                              Sskip)))
                        (Ssequence
                          (Ssequence
                            (Sset _t'20
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _actionArg
                                tuint))
                            (Sifthenelse (Ebinop Oeq (Etempvar _t'20 tuint)
                                           (Econst_int (Int.repr 5) tint)
                                           tint)
                              (Ssequence
                                (Sset _t'21
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _marioBodyState
                                    (tptr (Tstruct _MarioBodyState noattr))))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'21 (tptr (Tstruct _MarioBodyState noattr)))
                                      (Tstruct _MarioBodyState noattr))
                                    _punchState tuchar)
                                  (Ebinop Oor
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 6) tint) tint)
                                    (Econst_int (Int.repr 4) tint) tint)))
                              Sskip))
                          Sbreak))))
                  (LScons (Some 5)
                    (Ssequence
                      (Scall None
                        (Evar _set_mario_animation (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tint :: nil) tshort
                                                     cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 106) tint) :: nil))
                      (Ssequence
                        (Ssequence
                          (Sset _t'17
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _marioObj
                              (tptr (Tstruct _Object noattr))))
                          (Ssequence
                            (Sset _t'18
                              (Efield
                                (Efield
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'17 (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _header
                                      (Tstruct _ObjectNode noattr)) _gfx
                                    (Tstruct _GraphNodeObject noattr))
                                  _animInfo (Tstruct _AnimInfo noattr))
                                _animFrame tshort))
                            (Sifthenelse (Ebinop Ole (Etempvar _t'18 tshort)
                                           (Econst_int (Int.repr 0) tint)
                                           tint)
                              (Ssequence
                                (Sset _t'19
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _flags
                                    tuint))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _flags
                                    tuint)
                                  (Ebinop Oor (Etempvar _t'19 tuint)
                                    (Econst_int (Int.repr 1048576) tint)
                                    tuint)))
                              Sskip)))
                        (Ssequence
                          (Ssequence
                            (Sset _t'16
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _input
                                tushort))
                            (Sifthenelse (Ebinop Oand
                                           (Etempvar _t'16 tushort)
                                           (Econst_int (Int.repr 8192) tint)
                                           tint)
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _actionArg
                                  tuint) (Econst_int (Int.repr 6) tint))
                              Sskip))
                          (Ssequence
                            (Ssequence
                              (Scall (Some _t'5)
                                (Evar _is_anim_at_end (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tint
                                                        cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 nil))
                              (Sifthenelse (Etempvar _t'5 tint)
                                (Scall None
                                  (Evar _set_mario_action (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             tuint ::
                                                             tuint :: nil)
                                                            tuint cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   (Etempvar _endAction tuint) ::
                                   (Econst_int (Int.repr 0) tint) :: nil))
                                Sskip))
                            Sbreak))))
                    (LScons (Some 6)
                      (Ssequence
                        (Scall None
                          (Evar _play_mario_action_sound (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            tuint :: tuint ::
                                                            nil) tvoid
                                                           cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Ebinop Oor
                             (Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oor
                                   (Ebinop Oshl
                                     (Ecast (Econst_int (Int.repr 2) tint)
                                       tuint) (Econst_int (Int.repr 28) tint)
                                     tuint)
                                   (Ebinop Oshl
                                     (Ecast (Econst_int (Int.repr 31) tint)
                                       tuint) (Econst_int (Int.repr 16) tint)
                                     tuint) tuint)
                                 (Ebinop Oshl
                                   (Ecast (Econst_int (Int.repr 128) tint)
                                     tuint) (Econst_int (Int.repr 8) tint)
                                   tuint) tuint)
                               (Ebinop Oor
                                 (Econst_int (Int.repr 67108864) tint)
                                 (Econst_int (Int.repr 128) tint) tint)
                               tuint) (Econst_int (Int.repr 1) tint) tuint) ::
                           (Econst_int (Int.repr 1) tint) :: nil))
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'6)
                              (Evar _set_mario_animation (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            tint :: nil)
                                                           tshort cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 102) tint) :: nil))
                            (Sset _animFrame (Etempvar _t'6 tshort)))
                          (Ssequence
                            (Sifthenelse (Ebinop Oeq
                                           (Etempvar _animFrame tint)
                                           (Econst_int (Int.repr 0) tint)
                                           tint)
                              (Ssequence
                                (Sset _t'15
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _marioBodyState
                                    (tptr (Tstruct _MarioBodyState noattr))))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'15 (tptr (Tstruct _MarioBodyState noattr)))
                                      (Tstruct _MarioBodyState noattr))
                                    _punchState tuchar)
                                  (Ebinop Oor
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 2) tint)
                                      (Econst_int (Int.repr 6) tint) tint)
                                    (Econst_int (Int.repr 6) tint) tint)))
                              Sskip)
                            (Ssequence
                              (Ssequence
                                (Sifthenelse (Ebinop Oge
                                               (Etempvar _animFrame tint)
                                               (Econst_int (Int.repr 0) tint)
                                               tint)
                                  (Sset _t'7
                                    (Ecast
                                      (Ebinop Olt (Etempvar _animFrame tint)
                                        (Econst_int (Int.repr 8) tint) tint)
                                      tbool))
                                  (Sset _t'7 (Econst_int (Int.repr 0) tint)))
                                (Sifthenelse (Etempvar _t'7 tint)
                                  (Ssequence
                                    (Sset _t'14
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _flags tuint))
                                    (Sassign
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _flags tuint)
                                      (Ebinop Oor (Etempvar _t'14 tuint)
                                        (Econst_int (Int.repr 2097152) tint)
                                        tuint)))
                                  Sskip))
                              (Ssequence
                                (Ssequence
                                  (Scall (Some _t'8)
                                    (Evar _is_anim_at_end (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             nil) tint
                                                            cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     nil))
                                  (Sifthenelse (Etempvar _t'8 tint)
                                    (Scall None
                                      (Evar _set_mario_action (Tfunction
                                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                                 tuint ::
                                                                 tuint ::
                                                                 nil) tuint
                                                                cc_default))
                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                       (Etempvar _endAction tuint) ::
                                       (Econst_int (Int.repr 0) tint) :: nil))
                                    Sskip))
                                Sbreak)))))
                      (LScons (Some 9)
                        (Ssequence
                          (Scall None
                            (Evar _play_mario_action_sound (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              tuint ::
                                                              tuint :: nil)
                                                             tvoid
                                                             cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oor
                                   (Ebinop Oor
                                     (Ebinop Oshl
                                       (Ecast (Econst_int (Int.repr 2) tint)
                                         tuint)
                                       (Econst_int (Int.repr 28) tint) tuint)
                                     (Ebinop Oshl
                                       (Ecast (Econst_int (Int.repr 31) tint)
                                         tuint)
                                       (Econst_int (Int.repr 16) tint) tuint)
                                     tuint)
                                   (Ebinop Oshl
                                     (Ecast (Econst_int (Int.repr 128) tint)
                                       tuint) (Econst_int (Int.repr 8) tint)
                                     tuint) tuint)
                                 (Ebinop Oor
                                   (Econst_int (Int.repr 67108864) tint)
                                   (Econst_int (Int.repr 128) tint) tint)
                                 tuint) (Econst_int (Int.repr 1) tint) tuint) ::
                             (Econst_int (Int.repr 1) tint) :: nil))
                          (Ssequence
                            (Scall None
                              (Evar _set_mario_animation (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            tint :: nil)
                                                           tshort cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 113) tint) :: nil))
                            (Ssequence
                              (Ssequence
                                (Sset _t'13
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _marioObj
                                    (tptr (Tstruct _Object noattr))))
                                (Sset _animFrame
                                  (Efield
                                    (Efield
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'13 (tptr (Tstruct _Object noattr)))
                                            (Tstruct _Object noattr)) _header
                                          (Tstruct _ObjectNode noattr)) _gfx
                                        (Tstruct _GraphNodeObject noattr))
                                      _animInfo (Tstruct _AnimInfo noattr))
                                    _animFrame tshort)))
                              (Ssequence
                                (Ssequence
                                  (Sifthenelse (Ebinop Oge
                                                 (Etempvar _animFrame tint)
                                                 (Econst_int (Int.repr 2) tint)
                                                 tint)
                                    (Sset _t'9
                                      (Ecast
                                        (Ebinop Olt
                                          (Etempvar _animFrame tint)
                                          (Econst_int (Int.repr 8) tint)
                                          tint) tbool))
                                    (Sset _t'9
                                      (Econst_int (Int.repr 0) tint)))
                                  (Sifthenelse (Etempvar _t'9 tint)
                                    (Ssequence
                                      (Sset _t'12
                                        (Efield
                                          (Ederef
                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _flags tuint))
                                      (Sassign
                                        (Efield
                                          (Ederef
                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _flags tuint)
                                        (Ebinop Oor (Etempvar _t'12 tuint)
                                          (Econst_int (Int.repr 4194304) tint)
                                          tuint)))
                                    Sskip))
                                (Ssequence
                                  (Ssequence
                                    (Scall (Some _t'10)
                                      (Evar _is_anim_at_end (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               nil) tint
                                                              cc_default))
                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                       nil))
                                    (Sifthenelse (Etempvar _t'10 tint)
                                      (Scall None
                                        (Evar _set_mario_action (Tfunction
                                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                                   tuint ::
                                                                   tuint ::
                                                                   nil) tuint
                                                                  cc_default))
                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                         (Etempvar _crouchEndAction tuint) ::
                                         (Econst_int (Int.repr 0) tint) ::
                                         nil))
                                      Sskip))
                                  Sbreak)))))
                        LSnil))))))))))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_punching := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tint) :: (_t'3, tuint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'13, tushort) :: (_t'12, tushort) ::
               (_t'11, tushort) :: (_t'10, tushort) :: (_t'9, tuint) ::
               (_t'8, tschar) :: (_t'7, tushort) :: (_t'6, tushort) ::
               (_t'5, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'13
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'13 tushort)
                   (Econst_int (Int.repr 1024) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _drop_and_set_mario_action (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tuint :: tuint :: nil) tint
                                             cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 131622) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'12
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'12 tushort)
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oor (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 2) tint) tint)
                         (Econst_int (Int.repr 4) tint) tint)
                       (Econst_int (Int.repr 8) tint) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _check_common_action_exits (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sreturn (Some (Etempvar _t'2 tint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'10
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionState tushort))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'10 tushort)
                         (Econst_int (Int.repr 0) tint) tint)
            (Ssequence
              (Sset _t'11
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _input tushort))
              (Sset _t'4
                (Ecast
                  (Ebinop Oand (Etempvar _t'11 tushort)
                    (Econst_int (Int.repr 128) tint) tint) tbool)))
            (Sset _t'4 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'4 tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 25168044) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionState tushort)
          (Econst_int (Int.repr 1) tint))
        (Ssequence
          (Ssequence
            (Sset _t'9
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionArg tuint))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tuint)
                           (Econst_int (Int.repr 0) tint) tint)
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionTimer tushort)
                (Econst_int (Int.repr 7) tint))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'7
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionTimer tushort))
              (Ssequence
                (Sset _t'8
                  (Ederef
                    (Ebinop Oadd
                      (Evar _sPunchingForwardVelocities (tarray tschar 8))
                      (Etempvar _t'7 tushort) (tptr tschar)) tschar))
                (Scall None
                  (Evar _mario_set_forward_vel (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tfloat :: nil) tvoid
                                                 cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Etempvar _t'8 tschar) :: nil))))
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionTimer tushort))
                (Sifthenelse (Ebinop Ogt (Etempvar _t'5 tushort)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Ssequence
                    (Sset _t'6
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionTimer tushort))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionTimer tushort)
                      (Ebinop Osub (Etempvar _t'6 tushort)
                        (Econst_int (Int.repr 1) tint) tint)))
                  Sskip))
              (Ssequence
                (Scall None
                  (Evar _mario_update_punch_sequence (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Ssequence
                  (Scall None
                    (Evar _perform_ground_step (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))
|}.

Definition f_act_picking_up := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'6, tint) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'14, tushort) :: (_t'13, tushort) :: (_t'12, tushort) ::
               (_t'11, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'10, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'9, tuint) :: (_t'8, (tptr (Tstruct _Object noattr))) ::
               (_t'7, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'14
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'14 tushort)
                   (Econst_int (Int.repr 1024) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _drop_and_set_mario_action (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tuint :: tuint :: nil) tint
                                             cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 131622) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'13
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'13 tushort)
                     (Econst_int (Int.repr 4) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 16779404) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'12
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionState tushort))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'12 tushort)
                         (Econst_int (Int.repr 0) tint) tint)
            (Ssequence
              (Scall (Some _t'4)
                (Evar _is_anim_at_end (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sset _t'3 (Ecast (Etempvar _t'4 tint) tbool)))
            (Sset _t'3 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'3 tint)
          (Ssequence
            (Scall None
              (Evar _mario_grab_used_object (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Ssequence
              (Scall None
                (Evar _play_sound_if_no_flag (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tvoid
                                               cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 2) tint) tuint)
                           (Econst_int (Int.repr 28) tint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 6) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 128) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                       (Econst_int (Int.repr 128) tint) tint) tuint)
                   (Econst_int (Int.repr 1) tint) tuint) ::
                 (Econst_int (Int.repr 131072) tint) :: nil))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionState tushort)
                (Econst_int (Int.repr 1) tint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'7
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionState tushort))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'7 tushort)
                         (Econst_int (Int.repr 1) tint) tint)
            (Ssequence
              (Sset _t'8
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _heldObj
                  (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'9
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asU32 (tarray tuint 80))
                      (Econst_int (Int.repr 66) tint) (tptr tuint)) tuint))
                (Sifthenelse (Ebinop Oand (Etempvar _t'9 tuint)
                               (Econst_int (Int.repr 4) tint) tuint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'11
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _marioBodyState
                          (tptr (Tstruct _MarioBodyState noattr))))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _t'11 (tptr (Tstruct _MarioBodyState noattr)))
                            (Tstruct _MarioBodyState noattr)) _grabPos
                          tschar) (Econst_int (Int.repr 2) tint)))
                    (Ssequence
                      (Scall None
                        (Evar _set_mario_animation (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tint :: nil) tshort
                                                     cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 89) tint) :: nil))
                      (Ssequence
                        (Scall (Some _t'5)
                          (Evar _is_anim_at_end (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        (Sifthenelse (Etempvar _t'5 tint)
                          (Scall None
                            (Evar _set_mario_action (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: tuint :: nil)
                                                      tuint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 134218248) tint) ::
                             (Econst_int (Int.repr 0) tint) :: nil))
                          Sskip))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'10
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _marioBodyState
                          (tptr (Tstruct _MarioBodyState noattr))))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _t'10 (tptr (Tstruct _MarioBodyState noattr)))
                            (Tstruct _MarioBodyState noattr)) _grabPos
                          tschar) (Econst_int (Int.repr 1) tint)))
                    (Ssequence
                      (Scall None
                        (Evar _set_mario_animation (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tint :: nil) tshort
                                                     cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 107) tint) :: nil))
                      (Ssequence
                        (Scall (Some _t'6)
                          (Evar _is_anim_at_end (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        (Sifthenelse (Etempvar _t'6 tint)
                          (Scall None
                            (Evar _set_mario_action (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: tuint :: nil)
                                                      tuint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 134218247) tint) ::
                             (Econst_int (Int.repr 0) tint) :: nil))
                          Sskip)))))))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _stationary_ground_step (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_dive_picking_up := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tuint) :: (_t'2, tuint) :: (_t'1, tint) ::
               (_t'6, tushort) :: (_t'5, tushort) :: (_t'4, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                   (Econst_int (Int.repr 1024) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _drop_and_set_mario_action (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tuint :: tuint :: nil) tint
                                             cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 131622) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'5 tushort)
                     (Econst_int (Int.repr 4) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 16779404) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'4 tushort)
                       (Econst_int (Int.repr 8) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 80) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _animated_stationary_ground_step (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: tuint :: nil)
                                                   tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 139) tint) ::
           (Econst_int (Int.repr 134218247) tint) :: nil))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_placing_down := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tushort) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'6, tushort) :: (_t'5, tushort) :: (_t'4, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                   (Econst_int (Int.repr 1024) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _drop_and_set_mario_action (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tuint :: tuint :: nil) tint
                                             cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 131622) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'5 tushort)
                     (Econst_int (Int.repr 4) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 16779404) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sset _t'3
              (Ecast
                (Ebinop Oadd (Etempvar _t'4 tushort)
                  (Econst_int (Int.repr 1) tint) tint) tushort)))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort)
            (Etempvar _t'3 tushort)))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tushort)
                       (Econst_int (Int.repr 8) tint) tint)
          (Scall None
            (Evar _mario_drop_held_object (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _animated_stationary_ground_step (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: tuint :: nil)
                                                   tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 110) tint) ::
           (Econst_int (Int.repr 205521409) tint) :: nil))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_throwing := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'5, tushort) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tuint) :: (_t'11, tuint) ::
               (_t'10, (tptr (Tstruct _Object noattr))) ::
               (_t'9, (tptr (Tstruct _Object noattr))) :: (_t'8, tushort) ::
               (_t'7, tushort) :: (_t'6, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'9
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _heldObj
          (tptr (Tstruct _Object noattr))))
      (Sifthenelse (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
        (Ssequence
          (Sset _t'10
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _heldObj
              (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'11
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __665 noattr)) _asU32 (tarray tuint 80))
                  (Econst_int (Int.repr 66) tint) (tptr tuint)) tuint))
            (Sset _t'2
              (Ecast
                (Ebinop Oand (Etempvar _t'11 tuint)
                  (Econst_int (Int.repr 16) tint) tuint) tbool))))
        (Sset _t'2 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'2 tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 903) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'8
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'8 tushort)
                     (Econst_int (Int.repr 1024) tint) tint)
        (Ssequence
          (Scall (Some _t'3)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 131622) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'3 tint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'7
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'7 tushort)
                       (Econst_int (Int.repr 4) tint) tint)
          (Ssequence
            (Scall (Some _t'4)
              (Evar _drop_and_set_mario_action (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 16779404) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'4 tint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'6
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionTimer tushort))
              (Sset _t'5
                (Ecast
                  (Ebinop Oadd (Etempvar _t'6 tushort)
                    (Econst_int (Int.repr 1) tint) tint) tushort)))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort)
              (Etempvar _t'5 tushort)))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tushort)
                         (Econst_int (Int.repr 7) tint) tint)
            (Ssequence
              (Scall None
                (Evar _mario_throw_held_object (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tvoid cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Ssequence
                (Scall None
                  (Evar _play_sound_if_no_flag (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil)
                                                 tvoid cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 2) tint) tuint)
                             (Econst_int (Int.repr 28) tint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 7) tint) tuint)
                             (Econst_int (Int.repr 16) tint) tuint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 128) tint) tuint)
                           (Econst_int (Int.repr 8) tint) tuint) tuint)
                       (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                         (Econst_int (Int.repr 128) tint) tint) tuint)
                     (Econst_int (Int.repr 1) tint) tuint) ::
                   (Econst_int (Int.repr 131072) tint) :: nil))
                (Scall None
                  (Evar _play_sound_if_no_flag (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil)
                                                 tvoid cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 0) tint) tuint)
                             (Econst_int (Int.repr 28) tint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 53) tint) tuint)
                             (Econst_int (Int.repr 16) tint) tuint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 128) tint) tuint)
                           (Econst_int (Int.repr 8) tint) tuint) tuint)
                       (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                         (Econst_int (Int.repr 128) tint) tint) tuint)
                     (Econst_int (Int.repr 1) tint) tuint) ::
                   (Econst_int (Int.repr 65536) tint) :: nil))))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _animated_stationary_ground_step (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tint :: tuint :: nil)
                                                     tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 101) tint) ::
             (Econst_int (Int.repr 205521409) tint) :: nil))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_heavy_throw := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tushort) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'6, tushort) :: (_t'5, tushort) :: (_t'4, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                   (Econst_int (Int.repr 1024) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _drop_and_set_mario_action (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tuint :: tuint :: nil) tint
                                             cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 131622) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'5 tushort)
                     (Econst_int (Int.repr 4) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 16779404) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sset _t'3
              (Ecast
                (Ebinop Oadd (Etempvar _t'4 tushort)
                  (Econst_int (Int.repr 1) tint) tint) tushort)))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort)
            (Etempvar _t'3 tushort)))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tushort)
                       (Econst_int (Int.repr 13) tint) tint)
          (Ssequence
            (Scall None
              (Evar _mario_drop_held_object (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Ssequence
              (Scall None
                (Evar _play_sound_if_no_flag (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tvoid
                                               cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 2) tint) tuint)
                           (Econst_int (Int.repr 28) tint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 7) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 128) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                       (Econst_int (Int.repr 128) tint) tint) tuint)
                   (Econst_int (Int.repr 1) tint) tuint) ::
                 (Econst_int (Int.repr 131072) tint) :: nil))
              (Scall None
                (Evar _play_sound_if_no_flag (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tvoid
                                               cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 0) tint) tuint)
                           (Econst_int (Int.repr 28) tint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 53) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 128) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                       (Econst_int (Int.repr 128) tint) tint) tuint)
                   (Econst_int (Int.repr 1) tint) tuint) ::
                 (Econst_int (Int.repr 65536) tint) :: nil))))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _animated_stationary_ground_step (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: tuint :: nil)
                                                   tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 185) tint) ::
           (Econst_int (Int.repr 205521409) tint) :: nil))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_stomach_slide_stop := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tuint) :: (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'6, tushort) :: (_t'5, tushort) :: (_t'4, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                   (Econst_int (Int.repr 1024) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 131622) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'5 tushort)
                     (Econst_int (Int.repr 4) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 16779404) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'4 tushort)
                       (Econst_int (Int.repr 8) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 80) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _animated_stationary_ground_step (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: tuint :: nil)
                                                   tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 90) tint) ::
           (Econst_int (Int.repr 205521409) tint) :: nil))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_picking_up_bowser := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) ::
               (_t'4, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: (_t'2, tushort) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionState tushort))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tushort)
                   (Econst_int (Int.repr 0) tint) tint)
      (Ssequence
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionState tushort)
          (Econst_int (Int.repr 1) tint))
        (Ssequence
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _angleVel
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort) (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioBodyState
                  (tptr (Tstruct _MarioBodyState noattr))))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _t'4 (tptr (Tstruct _MarioBodyState noattr)))
                    (Tstruct _MarioBodyState noattr)) _grabPos tschar)
                (Econst_int (Int.repr 3) tint)))
            (Ssequence
              (Scall None
                (Evar _mario_grab_used_object (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tvoid cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Ssequence
                (Sset _t'3
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _marioObj
                    (tptr (Tstruct _Object noattr))))
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
                             (Ecast (Econst_int (Int.repr 6) tint) tuint)
                             (Econst_int (Int.repr 16) tint) tuint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 128) tint) tuint)
                           (Econst_int (Int.repr 8) tint) tuint) tuint)
                       (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                         (Econst_int (Int.repr 128) tint) tint) tuint)
                     (Econst_int (Int.repr 1) tint) tuint) ::
                   (Efield
                     (Efield
                       (Efield
                         (Ederef
                           (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                           (Tstruct _Object noattr)) _header
                         (Tstruct _ObjectNode noattr)) _gfx
                       (Tstruct _GraphNodeObject noattr)) _cameraToObject
                     (tarray tfloat 3)) :: nil)))))))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _set_mario_animation (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 181) tint) :: nil))
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _is_anim_at_end (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Sifthenelse (Etempvar _t'1 tint)
          (Scall None
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 913) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _stationary_ground_step (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_holding_bowser := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_spin, tshort) :: (_t'7, tint) :: (_t'6, tint) ::
               (_t'5, tint) :: (_t'4, tushort) :: (_t'3, tuint) ::
               (_t'2, tuint) :: (_t'1, tint) :: (_t'37, tshort) ::
               (_t'36, tshort) :: (_t'35, (tptr (Tstruct _Object noattr))) ::
               (_t'34, (tptr (Tstruct _Object noattr))) ::
               (_t'33, tushort) :: (_t'32, tshort) :: (_t'31, tshort) ::
               (_t'30, tshort) :: (_t'29, tshort) :: (_t'28, tshort) ::
               (_t'27, tshort) :: (_t'26, tshort) :: (_t'25, tshort) ::
               (_t'24, tuint) :: (_t'23, tshort) :: (_t'22, tfloat) ::
               (_t'21, tshort) :: (_t'20, tshort) :: (_t'19, tshort) ::
               (_t'18, tshort) :: (_t'17, tshort) ::
               (_t'16, (tptr (Tstruct _Object noattr))) :: (_t'15, tshort) ::
               (_t'14, tshort) :: (_t'13, (tptr (Tstruct _Object noattr))) ::
               (_t'12, tshort) :: (_t'11, (tptr (Tstruct _Object noattr))) ::
               (_t'10, tshort) :: (_t'9, (tptr (Tstruct _Object noattr))) ::
               (_t'8, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'33
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'33 tushort)
                   (Econst_int (Int.repr 8192) tint) tint)
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'36
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _angleVel
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort))
            (Sifthenelse (Ebinop Ole (Etempvar _t'36 tshort)
                           (Eunop Oneg (Econst_int (Int.repr 3584) tint)
                             tint) tint)
              (Sset _t'1 (Econst_int (Int.repr 1) tint))
              (Ssequence
                (Sset _t'37
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _angleVel
                        (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tshort)) tshort))
                (Sset _t'1
                  (Ecast
                    (Ebinop Oge (Etempvar _t'37 tshort)
                      (Econst_int (Int.repr 3584) tint) tint) tbool)))))
          (Sifthenelse (Etempvar _t'1 tint)
            (Ssequence
              (Sset _t'35
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioObj
                  (tptr (Tstruct _Object noattr))))
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
                           (Ecast (Econst_int (Int.repr 54) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 128) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                       (Econst_int (Int.repr 128) tint) tint) tuint)
                   (Econst_int (Int.repr 1) tint) tuint) ::
                 (Efield
                   (Efield
                     (Efield
                       (Ederef
                         (Etempvar _t'35 (tptr (Tstruct _Object noattr)))
                         (Tstruct _Object noattr)) _header
                       (Tstruct _ObjectNode noattr)) _gfx
                     (Tstruct _GraphNodeObject noattr)) _cameraToObject
                   (tarray tfloat 3)) :: nil)))
            (Ssequence
              (Sset _t'34
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioObj
                  (tptr (Tstruct _Object noattr))))
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
                           (Ecast (Econst_int (Int.repr 12) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 128) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                       (Econst_int (Int.repr 128) tint) tint) tuint)
                   (Econst_int (Int.repr 1) tint) tuint) ::
                 (Efield
                   (Efield
                     (Efield
                       (Ederef
                         (Etempvar _t'34 (tptr (Tstruct _Object noattr)))
                         (Tstruct _Object noattr)) _header
                       (Tstruct _ObjectNode noattr)) _gfx
                     (Tstruct _GraphNodeObject noattr)) _cameraToObject
                   (tarray tfloat 3)) :: nil)))))
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 914) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tuint)))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'32
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _angleVel (tarray tshort 3))
            (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'32 tshort)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionTimer tushort))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionTimer tushort)
                (Ebinop Oadd (Etempvar _t'4 tushort)
                  (Econst_int (Int.repr 1) tint) tint)))
            (Sifthenelse (Ebinop Ogt (Etempvar _t'4 tushort)
                           (Econst_int (Int.repr 120) tint) tint)
              (Ssequence
                (Scall (Some _t'3)
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 914) tint) ::
                   (Econst_int (Int.repr 1) tint) :: nil))
                (Sreturn (Some (Etempvar _t'3 tuint))))
              Sskip))
          (Scall None
            (Evar _set_mario_animation (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 184) tint) :: nil)))
        (Ssequence
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort)
            (Econst_int (Int.repr 0) tint))
          (Scall None
            (Evar _set_mario_animation (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 182) tint) :: nil)))))
    (Ssequence
      (Ssequence
        (Sset _t'22
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _intendedMag tfloat))
        (Sifthenelse (Ebinop Ogt (Etempvar _t'22 tfloat)
                       (Econst_single (Float32.of_bits (Int.repr 1101004800)) tfloat)
                       tint)
          (Ssequence
            (Sset _t'24
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionArg tuint))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'24 tuint)
                           (Econst_int (Int.repr 0) tint) tint)
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionArg tuint)
                  (Econst_int (Int.repr 1) tint))
                (Ssequence
                  (Sset _t'31
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _intendedYaw tshort))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _twirlYaw tshort)
                    (Etempvar _t'31 tshort))))
              (Ssequence
                (Ssequence
                  (Sset _t'29
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _intendedYaw tshort))
                  (Ssequence
                    (Sset _t'30
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _twirlYaw tshort))
                    (Sset _spin
                      (Ecast
                        (Ebinop Odiv
                          (Ecast
                            (Ebinop Osub (Etempvar _t'29 tshort)
                              (Etempvar _t'30 tshort) tint) tshort)
                          (Econst_int (Int.repr 128) tint) tint) tshort))))
                (Ssequence
                  (Sifthenelse (Ebinop Olt (Etempvar _spin tshort)
                                 (Eunop Oneg (Econst_int (Int.repr 128) tint)
                                   tint) tint)
                    (Sset _spin
                      (Ecast
                        (Eunop Oneg (Econst_int (Int.repr 128) tint) tint)
                        tshort))
                    Sskip)
                  (Ssequence
                    (Sifthenelse (Ebinop Ogt (Etempvar _spin tshort)
                                   (Econst_int (Int.repr 128) tint) tint)
                      (Sset _spin
                        (Ecast (Econst_int (Int.repr 128) tint) tshort))
                      Sskip)
                    (Ssequence
                      (Ssequence
                        (Sset _t'28
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _intendedYaw
                            tshort))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _twirlYaw tshort)
                          (Etempvar _t'28 tshort)))
                      (Ssequence
                        (Ssequence
                          (Sset _t'27
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _angleVel
                                  (tarray tshort 3))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))
                              tshort))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _angleVel
                                  (tarray tshort 3))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))
                              tshort)
                            (Ebinop Oadd (Etempvar _t'27 tshort)
                              (Etempvar _spin tshort) tint)))
                        (Ssequence
                          (Ssequence
                            (Sset _t'26
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _angleVel
                                    (tarray tshort 3))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tshort)) tshort))
                            (Sifthenelse (Ebinop Ogt (Etempvar _t'26 tshort)
                                           (Econst_int (Int.repr 4096) tint)
                                           tint)
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _angleVel (tarray tshort 3))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr tshort)) tshort)
                                (Econst_int (Int.repr 4096) tint))
                              Sskip))
                          (Ssequence
                            (Sset _t'25
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _angleVel
                                    (tarray tshort 3))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tshort)) tshort))
                            (Sifthenelse (Ebinop Olt (Etempvar _t'25 tshort)
                                           (Eunop Oneg
                                             (Econst_int (Int.repr 4096) tint)
                                             tint) tint)
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _angleVel (tarray tshort 3))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr tshort)) tshort)
                                (Eunop Oneg (Econst_int (Int.repr 4096) tint)
                                  tint))
                              Sskip))))))))))
          (Ssequence
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionArg tuint)
              (Econst_int (Int.repr 0) tint))
            (Ssequence
              (Ssequence
                (Sset _t'23
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _angleVel
                        (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tshort)) tshort))
                (Scall (Some _t'5)
                  (Evar _approach_s32 (Tfunction
                                        (tint :: tint :: tint :: tint :: nil)
                                        tint cc_default))
                  ((Etempvar _t'23 tshort) ::
                   (Econst_int (Int.repr 0) tint) ::
                   (Econst_int (Int.repr 64) tint) ::
                   (Econst_int (Int.repr 64) tint) :: nil)))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _angleVel
                      (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                    (tptr tshort)) tshort) (Etempvar _t'5 tint))))))
      (Ssequence
        (Ssequence
          (Sset _t'21
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _faceAngle
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort))
          (Sset _spin (Ecast (Etempvar _t'21 tshort) tshort)))
        (Ssequence
          (Ssequence
            (Sset _t'19
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _faceAngle
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort))
            (Ssequence
              (Sset _t'20
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _angleVel
                      (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                    (tptr tshort)) tshort))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _faceAngle
                      (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                    (tptr tshort)) tshort)
                (Ebinop Oadd (Etempvar _t'19 tshort) (Etempvar _t'20 tshort)
                  tint))))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'17
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _angleVel
                        (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tshort)) tshort))
                (Sifthenelse (Ebinop Ole (Etempvar _t'17 tshort)
                               (Eunop Oneg (Econst_int (Int.repr 256) tint)
                                 tint) tint)
                  (Ssequence
                    (Sset _t'18
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _faceAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tshort)) tshort))
                    (Sset _t'6
                      (Ecast
                        (Ebinop Olt (Etempvar _spin tshort)
                          (Etempvar _t'18 tshort) tint) tbool)))
                  (Sset _t'6 (Econst_int (Int.repr 0) tint))))
              (Sifthenelse (Etempvar _t'6 tint)
                (Ssequence
                  (Sset _t'16
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _marioObj
                      (tptr (Tstruct _Object noattr))))
                  (Scall None
                    (Evar _play_sound (Tfunction
                                        (tint :: (tptr tfloat) :: nil) tvoid
                                        cc_default))
                    ((Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 5) tint) tuint)
                               (Econst_int (Int.repr 28) tint) tuint)
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 7) tint) tuint)
                               (Econst_int (Int.repr 16) tint) tuint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 0) tint) tuint)
                             (Econst_int (Int.repr 8) tint) tuint) tuint)
                         (Econst_int (Int.repr 128) tint) tuint)
                       (Econst_int (Int.repr 1) tint) tuint) ::
                     (Efield
                       (Efield
                         (Efield
                           (Ederef
                             (Etempvar _t'16 (tptr (Tstruct _Object noattr)))
                             (Tstruct _Object noattr)) _header
                           (Tstruct _ObjectNode noattr)) _gfx
                         (Tstruct _GraphNodeObject noattr)) _cameraToObject
                       (tarray tfloat 3)) :: nil)))
                Sskip))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'14
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _angleVel
                          (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tshort)) tshort))
                  (Sifthenelse (Ebinop Oge (Etempvar _t'14 tshort)
                                 (Econst_int (Int.repr 256) tint) tint)
                    (Ssequence
                      (Sset _t'15
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _faceAngle
                              (tarray tshort 3))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))
                          tshort))
                      (Sset _t'7
                        (Ecast
                          (Ebinop Ogt (Etempvar _spin tshort)
                            (Etempvar _t'15 tshort) tint) tbool)))
                    (Sset _t'7 (Econst_int (Int.repr 0) tint))))
                (Sifthenelse (Etempvar _t'7 tint)
                  (Ssequence
                    (Sset _t'13
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _marioObj
                        (tptr (Tstruct _Object noattr))))
                    (Scall None
                      (Evar _play_sound (Tfunction
                                          (tint :: (tptr tfloat) :: nil)
                                          tvoid cc_default))
                      ((Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oor
                               (Ebinop Oshl
                                 (Ecast (Econst_int (Int.repr 5) tint) tuint)
                                 (Econst_int (Int.repr 28) tint) tuint)
                               (Ebinop Oshl
                                 (Ecast (Econst_int (Int.repr 7) tint) tuint)
                                 (Econst_int (Int.repr 16) tint) tuint)
                               tuint)
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 0) tint) tuint)
                               (Econst_int (Int.repr 8) tint) tuint) tuint)
                           (Econst_int (Int.repr 128) tint) tuint)
                         (Econst_int (Int.repr 1) tint) tuint) ::
                       (Efield
                         (Efield
                           (Efield
                             (Ederef
                               (Etempvar _t'13 (tptr (Tstruct _Object noattr)))
                               (Tstruct _Object noattr)) _header
                             (Tstruct _ObjectNode noattr)) _gfx
                           (Tstruct _GraphNodeObject noattr)) _cameraToObject
                         (tarray tfloat 3)) :: nil)))
                  Sskip))
              (Ssequence
                (Scall None
                  (Evar _stationary_ground_step (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Ssequence
                  (Ssequence
                    (Sset _t'8
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _angleVel
                            (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tshort)) tshort))
                    (Sifthenelse (Ebinop Oge (Etempvar _t'8 tshort)
                                   (Econst_int (Int.repr 0) tint) tint)
                      (Ssequence
                        (Sset _t'11
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _marioObj
                            (tptr (Tstruct _Object noattr))))
                        (Ssequence
                          (Sset _t'12
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _angleVel
                                  (tarray tshort 3))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))
                              tshort))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'11 (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _header
                                      (Tstruct _ObjectNode noattr)) _gfx
                                    (Tstruct _GraphNodeObject noattr)) _angle
                                  (tarray tshort 3))
                                (Econst_int (Int.repr 0) tint) (tptr tshort))
                              tshort)
                            (Eunop Oneg (Etempvar _t'12 tshort) tint))))
                      (Ssequence
                        (Sset _t'9
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _marioObj
                            (tptr (Tstruct _Object noattr))))
                        (Ssequence
                          (Sset _t'10
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _angleVel
                                  (tarray tshort 3))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))
                              tshort))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _header
                                      (Tstruct _ObjectNode noattr)) _gfx
                                    (Tstruct _GraphNodeObject noattr)) _angle
                                  (tarray tshort 3))
                                (Econst_int (Int.repr 0) tint) (tptr tshort))
                              tshort) (Etempvar _t'10 tshort))))))
                  (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))
|}.

Definition f_act_releasing_bowser := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tushort) :: (_t'3, tushort) :: (_t'2, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort))
        (Sset _t'1
          (Ecast
            (Ebinop Oadd (Etempvar _t'3 tushort)
              (Econst_int (Int.repr 1) tint) tint) tushort)))
      (Sassign
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionTimer tushort)
        (Etempvar _t'1 tushort)))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tushort)
                   (Econst_int (Int.repr 1) tint) tint)
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionArg tuint))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tuint)
                       (Econst_int (Int.repr 0) tint) tint)
          (Scall None
            (Evar _mario_throw_held_object (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Scall None
            (Evar _mario_drop_held_object (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))))
      Sskip))
  (Ssequence
    (Sassign
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _angleVel (tarray tshort 3))
          (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort)
      (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Scall None
        (Evar _animated_stationary_ground_step (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tint :: tuint :: nil) tvoid
                                                 cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 183) tint) ::
         (Econst_int (Int.repr 205521409) tint) :: nil))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_check_common_object_cancels := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_waterSurface, tfloat) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'7, tshort) :: (_t'6, tfloat) ::
               (_t'5, tushort) :: (_t'4, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _waterLevel tshort))
    (Sset _waterSurface
      (Ecast
        (Ebinop Osub (Etempvar _t'7 tshort) (Econst_int (Int.repr 100) tint)
          tint) tfloat)))
  (Ssequence
    (Ssequence
      (Sset _t'6
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
            (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
      (Sifthenelse (Ebinop Olt (Etempvar _t'6 tfloat)
                     (Etempvar _waterSurface tfloat) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _set_water_plunge_action (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sreturn (Some (Etempvar _t'1 tint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'5 tushort)
                       (Econst_int (Int.repr 64) tint) tint)
          (Ssequence
            (Scall (Some _t'2)
              (Evar _drop_and_set_mario_action (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 131897) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'2 tint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'4
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _health tshort))
          (Sifthenelse (Ebinop Olt (Etempvar _t'4 tshort)
                         (Econst_int (Int.repr 256) tint) tint)
            (Ssequence
              (Scall (Some _t'3)
                (Evar _drop_and_set_mario_action (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tuint :: tuint :: nil)
                                                   tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 135953) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'3 tint))))
            Sskip))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_mario_execute_object_action := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_cancel, tint) :: (_t'13, tint) :: (_t'12, tint) ::
               (_t'11, tint) :: (_t'10, tint) :: (_t'9, tint) ::
               (_t'8, tint) :: (_t'7, tint) :: (_t'6, tint) ::
               (_t'5, tint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tuint) :: (_t'1, tint) :: (_t'16, tuint) ::
               (_t'15, tushort) :: (_t'14, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _check_common_object_cancels (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Ssequence
      (Scall (Some _t'2)
        (Evar _mario_update_quicksand (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tfloat :: nil) tuint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat) ::
         nil))
      (Sifthenelse (Etempvar _t'2 tuint)
        (Sreturn (Some (Econst_int (Int.repr 1) tint)))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'16
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _action tuint))
        (Sswitch (Etempvar _t'16 tuint)
          (LScons (Some 8389504)
            (Ssequence
              (Ssequence
                (Scall (Some _t'3)
                  (Evar _act_punching (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Sset _cancel (Etempvar _t'3 tint)))
              Sbreak)
            (LScons (Some 899)
              (Ssequence
                (Ssequence
                  (Scall (Some _t'4)
                    (Evar _act_picking_up (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Sset _cancel (Etempvar _t'4 tint)))
                Sbreak)
              (LScons (Some 901)
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'5)
                      (Evar _act_dive_picking_up (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    nil) tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Sset _cancel (Etempvar _t'5 tint)))
                  Sbreak)
                (LScons (Some 902)
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'6)
                        (Evar _act_stomach_slide_stop (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tint
                                                        cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      (Sset _cancel (Etempvar _t'6 tint)))
                    Sbreak)
                  (LScons (Some 903)
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'7)
                          (Evar _act_placing_down (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        (Sset _cancel (Etempvar _t'7 tint)))
                      Sbreak)
                    (LScons (Some 2147485064)
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'8)
                            (Evar _act_throwing (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             nil))
                          (Sset _cancel (Etempvar _t'8 tint)))
                        Sbreak)
                      (LScons (Some 2147485065)
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'9)
                              (Evar _act_heavy_throw (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        nil) tint cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               nil))
                            (Sset _cancel (Etempvar _t'9 tint)))
                          Sbreak)
                        (LScons (Some 912)
                          (Ssequence
                            (Ssequence
                              (Scall (Some _t'10)
                                (Evar _act_picking_up_bowser (Tfunction
                                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                                nil) tint
                                                               cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 nil))
                              (Sset _cancel (Etempvar _t'10 tint)))
                            Sbreak)
                          (LScons (Some 913)
                            (Ssequence
                              (Ssequence
                                (Scall (Some _t'11)
                                  (Evar _act_holding_bowser (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               nil) tint
                                                              cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   nil))
                                (Sset _cancel (Etempvar _t'11 tint)))
                              Sbreak)
                            (LScons (Some 914)
                              (Ssequence
                                (Ssequence
                                  (Scall (Some _t'12)
                                    (Evar _act_releasing_bowser (Tfunction
                                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                                   nil) tint
                                                                  cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     nil))
                                  (Sset _cancel (Etempvar _t'12 tint)))
                                Sbreak)
                              LSnil))))))))))))
      (Ssequence
        (Ssequence
          (Sifthenelse (Eunop Onotbool (Etempvar _cancel tint) tint)
            (Ssequence
              (Sset _t'15
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _input tushort))
              (Sset _t'13
                (Ecast
                  (Ebinop Oand (Etempvar _t'15 tushort)
                    (Econst_int (Int.repr 512) tint) tint) tbool)))
            (Sset _t'13 (Econst_int (Int.repr 0) tint)))
          (Sifthenelse (Etempvar _t'13 tint)
            (Ssequence
              (Sset _t'14
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _particleFlags tuint))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _particleFlags tuint)
                (Ebinop Oor (Etempvar _t'14 tuint)
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 7) tint) tint) tuint)))
            Sskip))
        (Sreturn (Some (Etempvar _cancel tint)))))))
|}.

Definition composites : list composite_definition :=
(Composite __218 Struct
   (Member_plain _type tushort :: Member_plain _status tuchar ::
    Member_plain _errnum tuchar :: nil)
   noattr ::
 Composite __220 Struct
   (Member_plain _button tushort :: Member_plain _stick_x tschar ::
    Member_plain _stick_y tschar :: Member_plain _errnum tuchar :: nil)
   noattr ::
 Composite _Controller Struct
   (Member_plain _rawStickX tshort :: Member_plain _rawStickY tshort ::
    Member_plain _stickX tfloat :: Member_plain _stickY tfloat ::
    Member_plain _stickMag tfloat :: Member_plain _buttonDown tushort ::
    Member_plain _buttonPressed tushort ::
    Member_plain _statusData (tptr (Tstruct __218 noattr)) ::
    Member_plain _controllerData (tptr (Tstruct __220 noattr)) :: nil)
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
 Composite __665 Union
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
    Member_plain _rawData (Tunion __665 noattr) ::
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
 Composite __670 Struct
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
    Member_plain _normal (Tstruct __670 noattr) ::
    Member_plain _originOffset tfloat ::
    Member_plain _object (tptr (Tstruct _Object noattr)) :: nil)
   noattr ::
 Composite _MarioBodyState Struct
   (Member_plain _action tuint :: Member_plain _capState tschar ::
    Member_plain _eyeState tschar :: Member_plain _handState tschar ::
    Member_plain _wingFlutter tschar :: Member_plain _modelState tshort ::
    Member_plain _grabPos tschar :: Member_plain _punchState tuchar ::
    Member_plain _torsoAngle (tarray tshort 3) ::
    Member_plain _headAngle (tarray tshort 3) ::
    Member_plain _heldObjLastPosition (tarray tfloat 3) ::
    Member_plain _filler (tarray tuchar 4) :: nil)
   noattr ::
 Composite _MarioState Struct
   (Member_plain _unk00 tushort :: Member_plain _input tushort ::
    Member_plain _flags tuint :: Member_plain _particleFlags tuint ::
    Member_plain _action tuint :: Member_plain _prevAction tuint ::
    Member_plain _terrainSoundAddend tuint ::
    Member_plain _actionState tushort :: Member_plain _actionTimer tushort ::
    Member_plain _actionArg tuint :: Member_plain _intendedMag tfloat ::
    Member_plain _intendedYaw tshort :: Member_plain _invincTimer tshort ::
    Member_plain _framesSinceA tuchar :: Member_plain _framesSinceB tuchar ::
    Member_plain _wallKickTimer tuchar ::
    Member_plain _doubleJumpTimer tuchar ::
    Member_plain _faceAngle (tarray tshort 3) ::
    Member_plain _angleVel (tarray tshort 3) ::
    Member_plain _slideYaw tshort :: Member_plain _twirlYaw tshort ::
    Member_plain _pos (tarray tfloat 3) ::
    Member_plain _vel (tarray tfloat 3) :: Member_plain _forwardVel tfloat ::
    Member_plain _slideVelX tfloat :: Member_plain _slideVelZ tfloat ::
    Member_plain _wall (tptr (Tstruct _Surface noattr)) ::
    Member_plain _ceil (tptr (Tstruct _Surface noattr)) ::
    Member_plain _floor (tptr (Tstruct _Surface noattr)) ::
    Member_plain _ceilHeight tfloat :: Member_plain _floorHeight tfloat ::
    Member_plain _floorAngle tshort :: Member_plain _waterLevel tshort ::
    Member_plain _interactObj (tptr (Tstruct _Object noattr)) ::
    Member_plain _heldObj (tptr (Tstruct _Object noattr)) ::
    Member_plain _usedObj (tptr (Tstruct _Object noattr)) ::
    Member_plain _riddenObj (tptr (Tstruct _Object noattr)) ::
    Member_plain _marioObj (tptr (Tstruct _Object noattr)) ::
    Member_plain _spawnInfo (tptr (Tstruct _SpawnInfo noattr)) ::
    Member_plain _area (tptr (Tstruct _Area noattr)) ::
    Member_plain _statusForCamera (tptr (Tstruct _PlayerCameraState noattr)) ::
    Member_plain _marioBodyState (tptr (Tstruct _MarioBodyState noattr)) ::
    Member_plain _controller (tptr (Tstruct _Controller noattr)) ::
    Member_plain _animList (tptr (Tstruct _DmaHandlerList noattr)) ::
    Member_plain _collidedObjInteractTypes tuint ::
    Member_plain _numCoins tshort :: Member_plain _numStars tshort ::
    Member_plain _numKeys tschar :: Member_plain _numLives tschar ::
    Member_plain _health tshort :: Member_plain _unkB0 tshort ::
    Member_plain _hurtCounter tuchar :: Member_plain _healCounter tuchar ::
    Member_plain _squishTimer tuchar ::
    Member_plain _fadeWarpOpacity tuchar :: Member_plain _capTimer tushort ::
    Member_plain _prevNumStarsForDialog tshort ::
    Member_plain _peakHeight tfloat :: Member_plain _quicksandDepth tfloat ::
    Member_plain _gettingBlownGravity tfloat :: nil)
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
                   (mksignature (AST.Xptr :: AST.Xlong :: nil) AST.Xptr
                     cc_default)) ((tptr tvoid) :: tulong :: nil)
     (tptr tvoid) cc_default)) ::
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
     ((tptr tschar) :: nil) tvoid
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
                   (mksignature (AST.Xlong :: nil) AST.Xint cc_default))
     (tulong :: nil) tint cc_default)) ::
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
                   (mksignature (AST.Xlong :: nil) AST.Xint cc_default))
     (tulong :: nil) tint cc_default)) ::
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
                     (AST.Xptr :: AST.Xptr :: AST.Xlong :: AST.Xlong :: nil)
                     AST.Xvoid cc_default))
     ((tptr tvoid) :: (tptr tvoid) :: tulong :: tulong :: nil) tvoid
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
     ((tptr tschar) :: nil) tvoid
     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|})) ::
 (___builtin_annot_intval,
   Gfun(External (EF_builtin "__builtin_annot_intval"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xint
                     cc_default)) ((tptr tschar) :: tint :: nil) tint
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
                   (mksignature (AST.Xlong :: AST.Xlong :: nil) AST.Xlong
                     cc_default)) (tlong :: tlong :: nil) tlong cc_default)) ::
 (___builtin_fmax,
   Gfun(External (EF_builtin "__builtin_fmax"
                   (mksignature (AST.Xfloat :: AST.Xfloat :: nil) AST.Xfloat
                     cc_default)) (tdouble :: tdouble :: nil) tdouble
     cc_default)) ::
 (___builtin_fmin,
   Gfun(External (EF_builtin "__builtin_fmin"
                   (mksignature (AST.Xfloat :: AST.Xfloat :: nil) AST.Xfloat
                     cc_default)) (tdouble :: tdouble :: nil) tdouble
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
 (___builtin_debug,
   Gfun(External (EF_external "__builtin_debug"
                   (mksignature (AST.Xint :: nil) AST.Xvoid
                     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|}))
     (tint :: nil) tvoid
     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|})) ::
 (_mario_update_quicksand,
   Gfun(External (EF_external "mario_update_quicksand"
                   (mksignature (AST.Xptr :: AST.Xsingle :: nil) AST.Xint
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tfloat :: nil) tuint
     cc_default)) ::
 (_stationary_ground_step,
   Gfun(External (EF_external "stationary_ground_step"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_perform_ground_step,
   Gfun(External (EF_external "perform_ground_step"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_is_anim_at_end,
   Gfun(External (EF_external "is_anim_at_end"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_is_anim_past_end,
   Gfun(External (EF_external "is_anim_past_end"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_set_mario_animation,
   Gfun(External (EF_external "set_mario_animation"
                   (mksignature (AST.Xptr :: AST.Xint :: nil)
                     AST.Xint16signed cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tint :: nil) tshort cc_default)) ::
 (_play_sound_if_no_flag,
   Gfun(External (EF_external "play_sound_if_no_flag"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: tuint :: nil) tvoid
     cc_default)) ::
 (_play_mario_action_sound,
   Gfun(External (EF_external "play_mario_action_sound"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: tuint :: nil) tvoid
     cc_default)) ::
 (_mario_set_forward_vel,
   Gfun(External (EF_external "mario_set_forward_vel"
                   (mksignature (AST.Xptr :: AST.Xsingle :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tfloat :: nil) tvoid
     cc_default)) ::
 (_set_mario_action,
   Gfun(External (EF_external "set_mario_action"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: tuint :: nil) tuint
     cc_default)) ::
 (_drop_and_set_mario_action,
   Gfun(External (EF_external "drop_and_set_mario_action"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: tuint :: nil) tint
     cc_default)) ::
 (_check_common_action_exits,
   Gfun(External (EF_external "check_common_action_exits"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_set_water_plunge_action,
   Gfun(External (EF_external "set_water_plunge_action"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_play_sound,
   Gfun(External (EF_external "play_sound"
                   (mksignature (AST.Xint :: AST.Xptr :: nil) AST.Xvoid
                     cc_default)) (tint :: (tptr tfloat) :: nil) tvoid
     cc_default)) ::
 (_mario_grab_used_object,
   Gfun(External (EF_external "mario_grab_used_object"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_mario_drop_held_object,
   Gfun(External (EF_external "mario_drop_held_object"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_mario_throw_held_object,
   Gfun(External (EF_external "mario_throw_held_object"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_mario_check_object_grab,
   Gfun(External (EF_external "mario_check_object_grab"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tuint cc_default)) ::
 (_approach_s32,
   Gfun(External (EF_external "approach_s32"
                   (mksignature
                     (AST.Xint :: AST.Xint :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint cc_default))
     (tint :: tint :: tint :: tint :: nil) tint cc_default)) ::
 (_sPunchingForwardVelocities, Gvar v_sPunchingForwardVelocities) ::
 (_animated_stationary_ground_step, Gfun(Internal f_animated_stationary_ground_step)) ::
 (_mario_update_punch_sequence, Gfun(Internal f_mario_update_punch_sequence)) ::
 (_act_punching, Gfun(Internal f_act_punching)) ::
 (_act_picking_up, Gfun(Internal f_act_picking_up)) ::
 (_act_dive_picking_up, Gfun(Internal f_act_dive_picking_up)) ::
 (_act_placing_down, Gfun(Internal f_act_placing_down)) ::
 (_act_throwing, Gfun(Internal f_act_throwing)) ::
 (_act_heavy_throw, Gfun(Internal f_act_heavy_throw)) ::
 (_act_stomach_slide_stop, Gfun(Internal f_act_stomach_slide_stop)) ::
 (_act_picking_up_bowser, Gfun(Internal f_act_picking_up_bowser)) ::
 (_act_holding_bowser, Gfun(Internal f_act_holding_bowser)) ::
 (_act_releasing_bowser, Gfun(Internal f_act_releasing_bowser)) ::
 (_check_common_object_cancels, Gfun(Internal f_check_common_object_cancels)) ::
 (_mario_execute_object_action, Gfun(Internal f_mario_execute_object_action)) ::
 nil).

Definition public_idents : list ident :=
(_mario_execute_object_action :: _check_common_object_cancels ::
 _act_releasing_bowser :: _act_holding_bowser :: _act_picking_up_bowser ::
 _act_stomach_slide_stop :: _act_heavy_throw :: _act_throwing ::
 _act_placing_down :: _act_dive_picking_up :: _act_picking_up ::
 _act_punching :: _mario_update_punch_sequence ::
 _animated_stationary_ground_step :: _sPunchingForwardVelocities ::
 _approach_s32 :: _mario_check_object_grab :: _mario_throw_held_object ::
 _mario_drop_held_object :: _mario_grab_used_object :: _play_sound ::
 _set_water_plunge_action :: _check_common_action_exits ::
 _drop_and_set_mario_action :: _set_mario_action :: _mario_set_forward_vel ::
 _play_mario_action_sound :: _play_sound_if_no_flag ::
 _set_mario_animation :: _is_anim_past_end :: _is_anim_at_end ::
 _perform_ground_step :: _stationary_ground_step ::
 _mario_update_quicksand :: ___builtin_debug ::
 ___builtin_write32_reversed :: ___builtin_write16_reversed ::
 ___builtin_read32_reversed :: ___builtin_read16_reversed ::
 ___builtin_fnmsub :: ___builtin_fnmadd :: ___builtin_fmsub ::
 ___builtin_fmadd :: ___builtin_fmin :: ___builtin_fmax ::
 ___builtin_expect :: ___builtin_unreachable :: ___builtin_va_end ::
 ___builtin_va_copy :: ___builtin_va_arg :: ___builtin_va_start ::
 ___builtin_membar :: ___builtin_annot_intval :: ___builtin_annot ::
 ___builtin_sel :: ___builtin_memcpy_aligned :: ___builtin_sqrt ::
 ___builtin_fsqrt :: ___builtin_fabsf :: ___builtin_fabs ::
 ___builtin_ctzll :: ___builtin_ctzl :: ___builtin_ctz :: ___builtin_clzll ::
 ___builtin_clzl :: ___builtin_clz :: ___builtin_bswap16 ::
 ___builtin_bswap32 :: ___builtin_bswap :: ___builtin_bswap64 ::
 ___builtin_ais_annot :: ___compcert_i64_umulh :: ___compcert_i64_smulh ::
 ___compcert_i64_sar :: ___compcert_i64_shr :: ___compcert_i64_shl ::
 ___compcert_i64_umod :: ___compcert_i64_smod :: ___compcert_i64_udiv ::
 ___compcert_i64_sdiv :: ___compcert_i64_utof :: ___compcert_i64_stof ::
 ___compcert_i64_utod :: ___compcert_i64_stod :: ___compcert_i64_dtou ::
 ___compcert_i64_dtos :: ___compcert_va_composite ::
 ___compcert_va_float64 :: ___compcert_va_int64 :: ___compcert_va_int32 ::
 nil).

Definition prog : Clight.program := 
  mkprogram composites global_definitions public_idents _main Logic.I.


