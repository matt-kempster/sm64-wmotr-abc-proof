(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_US
   Source:          src/engine/behavior_script.c
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1
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
  Definition source_file := "build/pinned-sm64/src/engine/behavior_script.c".
  Definition normalized := true.
End Info.

Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _BehaviorCmdTable : ident := $"BehaviorCmdTable".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _GraphNode : ident := $"GraphNode".
Definition _GraphNodeObject : ident := $"GraphNodeObject".
Definition _Object : ident := $"Object".
Definition _ObjectNode : ident := $"ObjectNode".
Definition _SpawnInfo : ident := $"SpawnInfo".
Definition _Surface : ident := $"Surface".
Definition _WaterDropletParams : ident := $"WaterDropletParams".
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
Definition _animFrameAccelAssist : ident := $"animFrameAccelAssist".
Definition _animID : ident := $"animID".
Definition _animIndex : ident := $"animIndex".
Definition _animInfo : ident := $"animInfo".
Definition _animTimer : ident := $"animTimer".
Definition _animYTrans : ident := $"animYTrans".
Definition _animYTransDivisor : ident := $"animYTransDivisor".
Definition _animations : ident := $"animations".
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
Definition _behaviorFunc : ident := $"behaviorFunc".
Definition _behaviorScript : ident := $"behaviorScript".
Definition _bhvAddr : ident := $"bhvAddr".
Definition _bhvCmdProc : ident := $"bhvCmdProc".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvHauntedChair : ident := $"bhvHauntedChair".
Definition _bhvMadPiano : ident := $"bhvMadPiano".
Definition _bhvMessagePanel : ident := $"bhvMessagePanel".
Definition _bhvParam : ident := $"bhvParam".
Definition _bhvProcResult : ident := $"bhvProcResult".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _bhv_cmd_add_float : ident := $"bhv_cmd_add_float".
Definition _bhv_cmd_add_int : ident := $"bhv_cmd_add_int".
Definition _bhv_cmd_add_int_rand_rshift : ident := $"bhv_cmd_add_int_rand_rshift".
Definition _bhv_cmd_add_random_float : ident := $"bhv_cmd_add_random_float".
Definition _bhv_cmd_animate : ident := $"bhv_cmd_animate".
Definition _bhv_cmd_animate_texture : ident := $"bhv_cmd_animate_texture".
Definition _bhv_cmd_begin : ident := $"bhv_cmd_begin".
Definition _bhv_cmd_begin_loop : ident := $"bhv_cmd_begin_loop".
Definition _bhv_cmd_begin_repeat : ident := $"bhv_cmd_begin_repeat".
Definition _bhv_cmd_begin_repeat_unused : ident := $"bhv_cmd_begin_repeat_unused".
Definition _bhv_cmd_billboard : ident := $"bhv_cmd_billboard".
Definition _bhv_cmd_bit_clear : ident := $"bhv_cmd_bit_clear".
Definition _bhv_cmd_break : ident := $"bhv_cmd_break".
Definition _bhv_cmd_break_unused : ident := $"bhv_cmd_break_unused".
Definition _bhv_cmd_call : ident := $"bhv_cmd_call".
Definition _bhv_cmd_call_native : ident := $"bhv_cmd_call_native".
Definition _bhv_cmd_deactivate : ident := $"bhv_cmd_deactivate".
Definition _bhv_cmd_delay : ident := $"bhv_cmd_delay".
Definition _bhv_cmd_delay_var : ident := $"bhv_cmd_delay_var".
Definition _bhv_cmd_disable_rendering : ident := $"bhv_cmd_disable_rendering".
Definition _bhv_cmd_drop_to_floor : ident := $"bhv_cmd_drop_to_floor".
Definition _bhv_cmd_end_loop : ident := $"bhv_cmd_end_loop".
Definition _bhv_cmd_end_repeat : ident := $"bhv_cmd_end_repeat".
Definition _bhv_cmd_end_repeat_continue : ident := $"bhv_cmd_end_repeat_continue".
Definition _bhv_cmd_goto : ident := $"bhv_cmd_goto".
Definition _bhv_cmd_hide : ident := $"bhv_cmd_hide".
Definition _bhv_cmd_load_animations : ident := $"bhv_cmd_load_animations".
Definition _bhv_cmd_load_collision_data : ident := $"bhv_cmd_load_collision_data".
Definition _bhv_cmd_nop_1 : ident := $"bhv_cmd_nop_1".
Definition _bhv_cmd_nop_2 : ident := $"bhv_cmd_nop_2".
Definition _bhv_cmd_nop_3 : ident := $"bhv_cmd_nop_3".
Definition _bhv_cmd_nop_4 : ident := $"bhv_cmd_nop_4".
Definition _bhv_cmd_or_int : ident := $"bhv_cmd_or_int".
Definition _bhv_cmd_parent_bit_clear : ident := $"bhv_cmd_parent_bit_clear".
Definition _bhv_cmd_return : ident := $"bhv_cmd_return".
Definition _bhv_cmd_scale : ident := $"bhv_cmd_scale".
Definition _bhv_cmd_set_float : ident := $"bhv_cmd_set_float".
Definition _bhv_cmd_set_hitbox : ident := $"bhv_cmd_set_hitbox".
Definition _bhv_cmd_set_hitbox_with_offset : ident := $"bhv_cmd_set_hitbox_with_offset".
Definition _bhv_cmd_set_home : ident := $"bhv_cmd_set_home".
Definition _bhv_cmd_set_hurtbox : ident := $"bhv_cmd_set_hurtbox".
Definition _bhv_cmd_set_int : ident := $"bhv_cmd_set_int".
Definition _bhv_cmd_set_int_rand_rshift : ident := $"bhv_cmd_set_int_rand_rshift".
Definition _bhv_cmd_set_int_unused : ident := $"bhv_cmd_set_int_unused".
Definition _bhv_cmd_set_interact_subtype : ident := $"bhv_cmd_set_interact_subtype".
Definition _bhv_cmd_set_interact_type : ident := $"bhv_cmd_set_interact_type".
Definition _bhv_cmd_set_model : ident := $"bhv_cmd_set_model".
Definition _bhv_cmd_set_obj_physics : ident := $"bhv_cmd_set_obj_physics".
Definition _bhv_cmd_set_random_float : ident := $"bhv_cmd_set_random_float".
Definition _bhv_cmd_set_random_int : ident := $"bhv_cmd_set_random_int".
Definition _bhv_cmd_spawn_child : ident := $"bhv_cmd_spawn_child".
Definition _bhv_cmd_spawn_child_with_param : ident := $"bhv_cmd_spawn_child_with_param".
Definition _bhv_cmd_spawn_obj : ident := $"bhv_cmd_spawn_obj".
Definition _bhv_cmd_spawn_water_droplet : ident := $"bhv_cmd_spawn_water_droplet".
Definition _bhv_cmd_sum_float : ident := $"bhv_cmd_sum_float".
Definition _bhv_cmd_sum_int : ident := $"bhv_cmd_sum_int".
Definition _bhv_init_room : ident := $"bhv_init_room".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _child : ident := $"child".
Definition _children : ident := $"children".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _count : ident := $"count".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _cur_obj_bhv_stack_pop : ident := $"cur_obj_bhv_stack_pop".
Definition _cur_obj_bhv_stack_push : ident := $"cur_obj_bhv_stack_push".
Definition _cur_obj_enable_rendering_if_mario_in_room : ident := $"cur_obj_enable_rendering_if_mario_in_room".
Definition _cur_obj_has_behavior : ident := $"cur_obj_has_behavior".
Definition _cur_obj_hide : ident := $"cur_obj_hide".
Definition _cur_obj_move_xz_using_fvel_and_yaw : ident := $"cur_obj_move_xz_using_fvel_and_yaw".
Definition _cur_obj_move_y_with_terminal_vel : ident := $"cur_obj_move_y_with_terminal_vel".
Definition _cur_obj_scale : ident := $"cur_obj_scale".
Definition _cur_obj_update : ident := $"cur_obj_update".
Definition _dist_between_objects : ident := $"dist_between_objects".
Definition _distanceFromMario : ident := $"distanceFromMario".
Definition _downOffset : ident := $"downOffset".
Definition _dropletParams : ident := $"dropletParams".
Definition _field : ident := $"field".
Definition _fieldDst : ident := $"fieldDst".
Definition _fieldSrc1 : ident := $"fieldSrc1".
Definition _fieldSrc2 : ident := $"fieldSrc2".
Definition _filler : ident := $"filler".
Definition _find_floor_height : ident := $"find_floor_height".
Definition _flags : ident := $"flags".
Definition _floor : ident := $"floor".
Definition _force : ident := $"force".
Definition _gCurBhvCommand : ident := $"gCurBhvCommand".
Definition _gCurrentObject : ident := $"gCurrentObject".
Definition _gGlobalTimer : ident := $"gGlobalTimer".
Definition _gLoadedGraphNodes : ident := $"gLoadedGraphNodes".
Definition _gMarioObject : ident := $"gMarioObject".
Definition _gRandomSeed16 : ident := $"gRandomSeed16".
Definition _geo_obj_init_animation : ident := $"geo_obj_init_animation".
Definition _gfx : ident := $"gfx".
Definition _header : ident := $"header".
Definition _height : ident := $"height".
Definition _hitboxDownOffset : ident := $"hitboxDownOffset".
Definition _hitboxHeight : ident := $"hitboxHeight".
Definition _hitboxRadius : ident := $"hitboxRadius".
Definition _hurtboxHeight : ident := $"hurtboxHeight".
Definition _hurtboxRadius : ident := $"hurtboxRadius".
Definition _index : ident := $"index".
Definition _jumpAddress : ident := $"jumpAddress".
Definition _length : ident := $"length".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _main : ident := $"main".
Definition _min : ident := $"min".
Definition _model : ident := $"model".
Definition _modelID : ident := $"modelID".
Definition _moveAngleRange : ident := $"moveAngleRange".
Definition _moveRange : ident := $"moveRange".
Definition _next : ident := $"next".
Definition _node : ident := $"node".
Definition _normal : ident := $"normal".
Definition _num : ident := $"num".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _obj : ident := $"obj".
Definition _objFlags : ident := $"objFlags".
Definition _obj_angle_to_object : ident := $"obj_angle_to_object".
Definition _obj_build_transform_relative_to_parent : ident := $"obj_build_transform_relative_to_parent".
Definition _obj_copy_pos_and_angle : ident := $"obj_copy_pos_and_angle".
Definition _obj_set_face_angle_to_move_angle : ident := $"obj_set_face_angle_to_move_angle".
Definition _obj_set_throw_matrix_from_transform : ident := $"obj_set_throw_matrix_from_transform".
Definition _obj_update_gfx_pos_and_angle : ident := $"obj_update_gfx_pos_and_angle".
Definition _object : ident := $"object".
Definition _objectOffset : ident := $"objectOffset".
Definition _originOffset : ident := $"originOffset".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _percent : ident := $"percent".
Definition _pitch : ident := $"pitch".
Definition _platform : ident := $"platform".
Definition _pos : ident := $"pos".
Definition _posX : ident := $"posX".
Definition _posY : ident := $"posY".
Definition _posZ : ident := $"posZ".
Definition _prev : ident := $"prev".
Definition _prevObj : ident := $"prevObj".
Definition _radius : ident := $"radius".
Definition _randForwardVelOffset : ident := $"randForwardVelOffset".
Definition _randForwardVelScale : ident := $"randForwardVelScale".
Definition _randSizeOffset : ident := $"randSizeOffset".
Definition _randSizeScale : ident := $"randSizeScale".
Definition _randYVelOffset : ident := $"randYVelOffset".
Definition _randYVelScale : ident := $"randYVelScale".
Definition _random_float : ident := $"random_float".
Definition _random_sign : ident := $"random_sign".
Definition _random_u16 : ident := $"random_u16".
Definition _range : ident := $"range".
Definition _rate : ident := $"rate".
Definition _rawData : ident := $"rawData".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _rnd : ident := $"rnd".
Definition _roll : ident := $"roll".
Definition _room : ident := $"room".
Definition _rshift : ident := $"rshift".
Definition _scale : ident := $"scale".
Definition _segmented_to_virtual : ident := $"segmented_to_virtual".
Definition _sharedChild : ident := $"sharedChild".
Definition _spawn_object_at_origin : ident := $"spawn_object_at_origin".
Definition _spawn_water_droplet : ident := $"spawn_water_droplet".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
Definition _stub_behavior_script_2 : ident := $"stub_behavior_script_2".
Definition _temp1 : ident := $"temp1".
Definition _temp2 : ident := $"temp2".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _transform : ident := $"transform".
Definition _type : ident := $"type".
Definition _unk4C : ident := $"unk4C".
Definition _unused1 : ident := $"unused1".
Definition _unused2 : ident := $"unused2".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _unusedField : ident := $"unusedField".
Definition _upperY : ident := $"upperY".
Definition _value : ident := $"value".
Definition _values : ident := $"values".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
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
Definition _t'41 : ident := 168%positive.
Definition _t'42 : ident := 169%positive.
Definition _t'43 : ident := 170%positive.
Definition _t'44 : ident := 171%positive.
Definition _t'45 : ident := 172%positive.
Definition _t'46 : ident := 173%positive.
Definition _t'47 : ident := 174%positive.
Definition _t'48 : ident := 175%positive.
Definition _t'49 : ident := 176%positive.
Definition _t'5 : ident := 132%positive.
Definition _t'50 : ident := 177%positive.
Definition _t'51 : ident := 178%positive.
Definition _t'52 : ident := 179%positive.
Definition _t'53 : ident := 180%positive.
Definition _t'54 : ident := 181%positive.
Definition _t'55 : ident := 182%positive.
Definition _t'56 : ident := 183%positive.
Definition _t'57 : ident := 184%positive.
Definition _t'58 : ident := 185%positive.
Definition _t'59 : ident := 186%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'60 : ident := 187%positive.
Definition _t'61 : ident := 188%positive.
Definition _t'62 : ident := 189%positive.
Definition _t'63 : ident := 190%positive.
Definition _t'64 : ident := 191%positive.
Definition _t'65 : ident := 192%positive.
Definition _t'66 : ident := 193%positive.
Definition _t'67 : ident := 194%positive.
Definition _t'68 : ident := 195%positive.
Definition _t'69 : ident := 196%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'70 : ident := 197%positive.
Definition _t'71 : ident := 198%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v_bhvMessagePanel := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvHauntedChair := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvMadPiano := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_gLoadedGraphNodes := {|
  gvar_info := (tptr (tptr (Tstruct _GraphNode noattr)));
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

Definition v_gMarioObject := {|
  gvar_info := (tptr (Tstruct _Object noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrentObject := {|
  gvar_info := (tptr (Tstruct _Object noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurBhvCommand := {|
  gvar_info := (tptr tuint);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gRandomSeed16 := {|
  gvar_info := tushort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_random_u16 := {|
  fn_return := tushort;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_temp1, tushort) :: (_temp2, tushort) :: (_t'5, tushort) ::
               (_t'4, tushort) :: (_t'3, tushort) :: (_t'2, tushort) ::
               (_t'1, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5 (Evar _gRandomSeed16 tushort))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tushort)
                   (Econst_int (Int.repr 22026) tint) tint)
      (Sassign (Evar _gRandomSeed16 tushort) (Econst_int (Int.repr 0) tint))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'4 (Evar _gRandomSeed16 tushort))
      (Sset _temp1
        (Ecast
          (Ebinop Oshl
            (Ebinop Oand (Etempvar _t'4 tushort)
              (Econst_int (Int.repr 255) tint) tint)
            (Econst_int (Int.repr 8) tint) tint) tushort)))
    (Ssequence
      (Ssequence
        (Sset _t'3 (Evar _gRandomSeed16 tushort))
        (Sset _temp1
          (Ecast
            (Ebinop Oxor (Etempvar _temp1 tushort) (Etempvar _t'3 tushort)
              tint) tushort)))
      (Ssequence
        (Sassign (Evar _gRandomSeed16 tushort)
          (Ebinop Oadd
            (Ebinop Oshl
              (Ebinop Oand (Etempvar _temp1 tushort)
                (Econst_int (Int.repr 255) tint) tint)
              (Econst_int (Int.repr 8) tint) tint)
            (Ebinop Oshr
              (Ebinop Oand (Etempvar _temp1 tushort)
                (Econst_int (Int.repr 65280) tint) tint)
              (Econst_int (Int.repr 8) tint) tint) tint))
        (Ssequence
          (Ssequence
            (Sset _t'2 (Evar _gRandomSeed16 tushort))
            (Sset _temp1
              (Ecast
                (Ebinop Oxor
                  (Ebinop Oshl
                    (Ebinop Oand (Etempvar _temp1 tushort)
                      (Econst_int (Int.repr 255) tint) tint)
                    (Econst_int (Int.repr 1) tint) tint)
                  (Etempvar _t'2 tushort) tint) tushort)))
          (Ssequence
            (Sset _temp2
              (Ecast
                (Ebinop Oxor
                  (Ebinop Oshr (Etempvar _temp1 tushort)
                    (Econst_int (Int.repr 1) tint) tint)
                  (Econst_int (Int.repr 65408) tint) tint) tushort))
            (Ssequence
              (Sifthenelse (Ebinop Oeq
                             (Ebinop Oand (Etempvar _temp1 tushort)
                               (Econst_int (Int.repr 1) tint) tint)
                             (Econst_int (Int.repr 0) tint) tint)
                (Sifthenelse (Ebinop Oeq (Etempvar _temp2 tushort)
                               (Econst_int (Int.repr 43605) tint) tint)
                  (Sassign (Evar _gRandomSeed16 tushort)
                    (Econst_int (Int.repr 0) tint))
                  (Sassign (Evar _gRandomSeed16 tushort)
                    (Ebinop Oxor (Etempvar _temp2 tushort)
                      (Econst_int (Int.repr 8180) tint) tint)))
                (Sassign (Evar _gRandomSeed16 tushort)
                  (Ebinop Oxor (Etempvar _temp2 tushort)
                    (Econst_int (Int.repr 33152) tint) tint)))
              (Ssequence
                (Sset _t'1 (Evar _gRandomSeed16 tushort))
                (Sreturn (Some (Etempvar _t'1 tushort)))))))))))
|}.

Definition f_random_float := {|
  fn_return := tfloat;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_rnd, tfloat) :: (_t'1, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1) (Evar _random_u16 (Tfunction nil tushort cc_default))
      nil)
    (Sset _rnd (Ecast (Etempvar _t'1 tushort) tfloat)))
  (Sreturn (Some (Ebinop Odiv (Etempvar _rnd tfloat)
                   (Ecast (Econst_int (Int.repr 65536) tint) tdouble)
                   tdouble))))
|}.

Definition f_random_sign := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tushort) :: nil);
  fn_body :=
(Ssequence
  (Scall (Some _t'1) (Evar _random_u16 (Tfunction nil tushort cc_default))
    nil)
  (Sifthenelse (Ebinop Oge (Etempvar _t'1 tushort)
                 (Econst_int (Int.repr 32767) tint) tint)
    (Sreturn (Some (Econst_int (Int.repr 1) tint)))
    (Sreturn (Some (Eunop Oneg (Econst_int (Int.repr 1) tint) tint)))))
|}.

Definition f_obj_update_gfx_pos_and_angle := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_obj, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'7, tfloat) :: (_t'6, tfloat) :: (_t'5, tfloat) ::
               (_t'4, tfloat) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
            _asF32 (tarray tfloat 80))
          (Ebinop Oadd (Econst_int (Int.repr 6) tint)
            (Econst_int (Int.repr 0) tint) tint) (tptr tfloat)) tfloat))
    (Sassign
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Efield
                (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _header
                (Tstruct _ObjectNode noattr)) _gfx
              (Tstruct _GraphNodeObject noattr)) _pos (tarray tfloat 3))
          (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
      (Etempvar _t'7 tfloat)))
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
              _asF32 (tarray tfloat 80))
            (Ebinop Oadd (Econst_int (Int.repr 6) tint)
              (Econst_int (Int.repr 1) tint) tint) (tptr tfloat)) tfloat))
      (Ssequence
        (Sset _t'6
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
                _asF32 (tarray tfloat 80)) (Econst_int (Int.repr 21) tint)
              (tptr tfloat)) tfloat))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Efield
                    (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _header
                    (Tstruct _ObjectNode noattr)) _gfx
                  (Tstruct _GraphNodeObject noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
          (Ebinop Oadd (Etempvar _t'5 tfloat) (Etempvar _t'6 tfloat) tfloat))))
    (Ssequence
      (Ssequence
        (Sset _t'4
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
                _asF32 (tarray tfloat 80))
              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                (Econst_int (Int.repr 2) tint) tint) (tptr tfloat)) tfloat))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Efield
                    (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _header
                    (Tstruct _ObjectNode noattr)) _gfx
                  (Tstruct _GraphNodeObject noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat)
          (Etempvar _t'4 tfloat)))
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __764 noattr)) _asS32 (tarray tint 80))
                (Ebinop Oadd (Econst_int (Int.repr 18) tint)
                  (Econst_int (Int.repr 0) tint) tint) (tptr tint)) tint))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Efield
                      (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _header
                      (Tstruct _ObjectNode noattr)) _gfx
                    (Tstruct _GraphNodeObject noattr)) _angle
                  (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                (tptr tshort)) tshort)
            (Ebinop Oand (Etempvar _t'3 tint)
              (Econst_int (Int.repr 65535) tint) tint)))
        (Ssequence
          (Ssequence
            (Sset _t'2
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __764 noattr)) _asS32 (tarray tint 80))
                  (Ebinop Oadd (Econst_int (Int.repr 18) tint)
                    (Econst_int (Int.repr 1) tint) tint) (tptr tint)) tint))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _obj (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _header
                        (Tstruct _ObjectNode noattr)) _gfx
                      (Tstruct _GraphNodeObject noattr)) _angle
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort)
              (Ebinop Oand (Etempvar _t'2 tint)
                (Econst_int (Int.repr 65535) tint) tint)))
          (Ssequence
            (Sset _t'1
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __764 noattr)) _asS32 (tarray tint 80))
                  (Ebinop Oadd (Econst_int (Int.repr 18) tint)
                    (Econst_int (Int.repr 2) tint) tint) (tptr tint)) tint))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _obj (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _header
                        (Tstruct _ObjectNode noattr)) _gfx
                      (Tstruct _GraphNodeObject noattr)) _angle
                    (tarray tshort 3)) (Econst_int (Int.repr 2) tint)
                  (tptr tshort)) tshort)
              (Ebinop Oand (Etempvar _t'1 tint)
                (Econst_int (Int.repr 65535) tint) tint))))))))
|}.

Definition f_cur_obj_bhv_stack_push := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_bhvAddr, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'6, tuint) :: (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: (_t'3, tuint) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'5 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
              (Tstruct _Object noattr)) _bhvStackIndex tuint))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _bhvStack (tarray tuint 8))
              (Etempvar _t'6 tuint) (tptr tuint)) tuint)
          (Etempvar _bhvAddr tuint)))))
  (Ssequence
    (Sset _t'1 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
              (Tstruct _Object noattr)) _bhvStackIndex tuint))
        (Sassign
          (Efield
            (Ederef (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
              (Tstruct _Object noattr)) _bhvStackIndex tuint)
          (Ebinop Oadd (Etempvar _t'3 tuint) (Econst_int (Int.repr 1) tint)
            tuint))))))
|}.

Definition f_cur_obj_bhv_stack_pop := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_bhvAddr, tuint) :: (_t'6, tuint) ::
               (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: (_t'3, tuint) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'5 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
              (Tstruct _Object noattr)) _bhvStackIndex tuint))
        (Sassign
          (Efield
            (Ederef (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
              (Tstruct _Object noattr)) _bhvStackIndex tuint)
          (Ebinop Osub (Etempvar _t'6 tuint) (Econst_int (Int.repr 1) tint)
            tuint)))))
  (Ssequence
    (Ssequence
      (Sset _t'1 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _bhvStackIndex tuint))
          (Sset _bhvAddr
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _bhvStack (tarray tuint 8))
                (Etempvar _t'3 tuint) (tptr tuint)) tuint)))))
    (Sreturn (Some (Etempvar _bhvAddr tuint)))))
|}.

Definition f_bhv_cmd_hide := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Scall None (Evar _cur_obj_hide (Tfunction nil tvoid cc_default)) nil)
  (Ssequence
    (Ssequence
      (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
      (Sassign (Evar _gCurBhvCommand (tptr tuint))
        (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
          (Econst_int (Int.repr 1) tint) (tptr tuint))))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_bhv_cmd_disable_rendering := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'4, tshort) :: (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'3 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'4
          (Efield
            (Efield
              (Efield
                (Efield
                  (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _header
                  (Tstruct _ObjectNode noattr)) _gfx
                (Tstruct _GraphNodeObject noattr)) _node
              (Tstruct _GraphNode noattr)) _flags tshort))
        (Sassign
          (Efield
            (Efield
              (Efield
                (Efield
                  (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _header
                  (Tstruct _ObjectNode noattr)) _gfx
                (Tstruct _GraphNodeObject noattr)) _node
              (Tstruct _GraphNode noattr)) _flags tshort)
          (Ebinop Oand (Etempvar _t'4 tshort)
            (Eunop Onotint
              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 0) tint) tint) tint) tint)))))
  (Ssequence
    (Ssequence
      (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
      (Sassign (Evar _gCurBhvCommand (tptr tuint))
        (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
          (Econst_int (Int.repr 1) tint) (tptr tuint))))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_bhv_cmd_billboard := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'4, tshort) :: (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'3 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'4
          (Efield
            (Efield
              (Efield
                (Efield
                  (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _header
                  (Tstruct _ObjectNode noattr)) _gfx
                (Tstruct _GraphNodeObject noattr)) _node
              (Tstruct _GraphNode noattr)) _flags tshort))
        (Sassign
          (Efield
            (Efield
              (Efield
                (Efield
                  (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _header
                  (Tstruct _ObjectNode noattr)) _gfx
                (Tstruct _GraphNodeObject noattr)) _node
              (Tstruct _GraphNode noattr)) _flags tshort)
          (Ebinop Oor (Etempvar _t'4 tshort)
            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
              (Econst_int (Int.repr 2) tint) tint) tint)))))
  (Ssequence
    (Ssequence
      (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
      (Sassign (Evar _gCurBhvCommand (tptr tuint))
        (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
          (Econst_int (Int.repr 1) tint) (tptr tuint))))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_bhv_cmd_set_model := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_modelID, tint) :: (_t'6, tuint) :: (_t'5, (tptr tuint)) ::
               (_t'4, (tptr (Tstruct _GraphNode noattr))) ::
               (_t'3, (tptr (tptr (Tstruct _GraphNode noattr)))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'6
        (Ederef
          (Ebinop Oadd (Etempvar _t'5 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _modelID
        (Ecast
          (Ebinop Oand (Etempvar _t'6 tuint)
            (Econst_int (Int.repr 65535) tint) tuint) tshort))))
  (Ssequence
    (Ssequence
      (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'3
          (Evar _gLoadedGraphNodes (tptr (tptr (Tstruct _GraphNode noattr)))))
        (Ssequence
          (Sset _t'4
            (Ederef
              (Ebinop Oadd
                (Etempvar _t'3 (tptr (tptr (Tstruct _GraphNode noattr))))
                (Etempvar _modelID tint)
                (tptr (tptr (Tstruct _GraphNode noattr))))
              (tptr (Tstruct _GraphNode noattr))))
          (Sassign
            (Efield
              (Efield
                (Efield
                  (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _header
                  (Tstruct _ObjectNode noattr)) _gfx
                (Tstruct _GraphNodeObject noattr)) _sharedChild
              (tptr (Tstruct _GraphNode noattr)))
            (Etempvar _t'4 (tptr (Tstruct _GraphNode noattr)))))))
    (Ssequence
      (Ssequence
        (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
        (Sassign (Evar _gCurBhvCommand (tptr tuint))
          (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
            (Econst_int (Int.repr 1) tint) (tptr tuint))))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_bhv_cmd_spawn_child := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_model, tuint) :: (_behavior, (tptr tuint)) ::
               (_child, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: (_t'8, tuint) ::
               (_t'7, (tptr tuint)) :: (_t'6, tuint) ::
               (_t'5, (tptr tuint)) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'8
        (Ederef
          (Ebinop Oadd (Etempvar _t'7 (tptr tuint))
            (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
      (Sset _model (Ecast (Etempvar _t'8 tuint) tuint))))
  (Ssequence
    (Ssequence
      (Sset _t'5 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'6
          (Ederef
            (Ebinop Oadd (Etempvar _t'5 (tptr tuint))
              (Econst_int (Int.repr 2) tint) (tptr tuint)) tuint))
        (Sset _behavior (Ecast (Etempvar _t'6 tuint) (tptr tvoid)))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'4 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Scall (Some _t'1)
            (Evar _spawn_object_at_origin (Tfunction
                                            ((tptr (Tstruct _Object noattr)) ::
                                             tint :: tuint :: (tptr tuint) ::
                                             nil)
                                            (tptr (Tstruct _Object noattr))
                                            cc_default))
            ((Etempvar _t'4 (tptr (Tstruct _Object noattr))) ::
             (Econst_int (Int.repr 0) tint) :: (Etempvar _model tuint) ::
             (Etempvar _behavior (tptr tuint)) :: nil)))
        (Sset _child (Etempvar _t'1 (tptr (Tstruct _Object noattr)))))
      (Ssequence
        (Ssequence
          (Sset _t'3 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Scall None
            (Evar _obj_copy_pos_and_angle (Tfunction
                                            ((tptr (Tstruct _Object noattr)) ::
                                             (tptr (Tstruct _Object noattr)) ::
                                             nil) tvoid cc_default))
            ((Etempvar _child (tptr (Tstruct _Object noattr))) ::
             (Etempvar _t'3 (tptr (Tstruct _Object noattr))) :: nil)))
        (Ssequence
          (Ssequence
            (Sset _t'2 (Evar _gCurBhvCommand (tptr tuint)))
            (Sassign (Evar _gCurBhvCommand (tptr tuint))
              (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
                (Econst_int (Int.repr 3) tint) (tptr tuint))))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_bhv_cmd_spawn_obj := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_model, tuint) :: (_behavior, (tptr tuint)) ::
               (_object, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: (_t'9, tuint) ::
               (_t'8, (tptr tuint)) :: (_t'7, tuint) ::
               (_t'6, (tptr tuint)) ::
               (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'9
        (Ederef
          (Ebinop Oadd (Etempvar _t'8 (tptr tuint))
            (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
      (Sset _model (Ecast (Etempvar _t'9 tuint) tuint))))
  (Ssequence
    (Ssequence
      (Sset _t'6 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'7
          (Ederef
            (Ebinop Oadd (Etempvar _t'6 (tptr tuint))
              (Econst_int (Int.repr 2) tint) (tptr tuint)) tuint))
        (Sset _behavior (Ecast (Etempvar _t'7 tuint) (tptr tvoid)))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'5 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Scall (Some _t'1)
            (Evar _spawn_object_at_origin (Tfunction
                                            ((tptr (Tstruct _Object noattr)) ::
                                             tint :: tuint :: (tptr tuint) ::
                                             nil)
                                            (tptr (Tstruct _Object noattr))
                                            cc_default))
            ((Etempvar _t'5 (tptr (Tstruct _Object noattr))) ::
             (Econst_int (Int.repr 0) tint) :: (Etempvar _model tuint) ::
             (Etempvar _behavior (tptr tuint)) :: nil)))
        (Sset _object (Etempvar _t'1 (tptr (Tstruct _Object noattr)))))
      (Ssequence
        (Ssequence
          (Sset _t'4 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Scall None
            (Evar _obj_copy_pos_and_angle (Tfunction
                                            ((tptr (Tstruct _Object noattr)) ::
                                             (tptr (Tstruct _Object noattr)) ::
                                             nil) tvoid cc_default))
            ((Etempvar _object (tptr (Tstruct _Object noattr))) ::
             (Etempvar _t'4 (tptr (Tstruct _Object noattr))) :: nil)))
        (Ssequence
          (Ssequence
            (Sset _t'3
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Sassign
              (Efield
                (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _prevObj
                (tptr (Tstruct _Object noattr)))
              (Etempvar _object (tptr (Tstruct _Object noattr)))))
          (Ssequence
            (Ssequence
              (Sset _t'2 (Evar _gCurBhvCommand (tptr tuint)))
              (Sassign (Evar _gCurBhvCommand (tptr tuint))
                (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
                  (Econst_int (Int.repr 3) tint) (tptr tuint))))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_bhv_cmd_spawn_child_with_param := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_bhvParam, tuint) :: (_modelID, tuint) ::
               (_behavior, (tptr tuint)) ::
               (_child, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: (_t'10, tuint) ::
               (_t'9, (tptr tuint)) :: (_t'8, tuint) ::
               (_t'7, (tptr tuint)) :: (_t'6, tuint) ::
               (_t'5, (tptr tuint)) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'10
        (Ederef
          (Ebinop Oadd (Etempvar _t'9 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _bhvParam
        (Ecast
          (Ebinop Oand (Etempvar _t'10 tuint)
            (Econst_int (Int.repr 65535) tint) tuint) tshort))))
  (Ssequence
    (Ssequence
      (Sset _t'7 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'8
          (Ederef
            (Ebinop Oadd (Etempvar _t'7 (tptr tuint))
              (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
        (Sset _modelID (Ecast (Etempvar _t'8 tuint) tuint))))
    (Ssequence
      (Ssequence
        (Sset _t'5 (Evar _gCurBhvCommand (tptr tuint)))
        (Ssequence
          (Sset _t'6
            (Ederef
              (Ebinop Oadd (Etempvar _t'5 (tptr tuint))
                (Econst_int (Int.repr 2) tint) (tptr tuint)) tuint))
          (Sset _behavior (Ecast (Etempvar _t'6 tuint) (tptr tvoid)))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'4
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Scall (Some _t'1)
              (Evar _spawn_object_at_origin (Tfunction
                                              ((tptr (Tstruct _Object noattr)) ::
                                               tint :: tuint ::
                                               (tptr tuint) :: nil)
                                              (tptr (Tstruct _Object noattr))
                                              cc_default))
              ((Etempvar _t'4 (tptr (Tstruct _Object noattr))) ::
               (Econst_int (Int.repr 0) tint) :: (Etempvar _modelID tuint) ::
               (Etempvar _behavior (tptr tuint)) :: nil)))
          (Sset _child (Etempvar _t'1 (tptr (Tstruct _Object noattr)))))
        (Ssequence
          (Ssequence
            (Sset _t'3
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Scall None
              (Evar _obj_copy_pos_and_angle (Tfunction
                                              ((tptr (Tstruct _Object noattr)) ::
                                               (tptr (Tstruct _Object noattr)) ::
                                               nil) tvoid cc_default))
              ((Etempvar _child (tptr (Tstruct _Object noattr))) ::
               (Etempvar _t'3 (tptr (Tstruct _Object noattr))) :: nil)))
          (Ssequence
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _child (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __764 noattr)) _asS32 (tarray tint 80))
                  (Econst_int (Int.repr 47) tint) (tptr tint)) tint)
              (Etempvar _bhvParam tuint))
            (Ssequence
              (Ssequence
                (Sset _t'2 (Evar _gCurBhvCommand (tptr tuint)))
                (Sassign (Evar _gCurBhvCommand (tptr tuint))
                  (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
                    (Econst_int (Int.repr 3) tint) (tptr tuint))))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_bhv_cmd_deactivate := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
    (Sassign
      (Efield
        (Ederef (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
          (Tstruct _Object noattr)) _activeFlags tshort)
      (Econst_int (Int.repr 0) tint)))
  (Sreturn (Some (Econst_int (Int.repr 1) tint))))
|}.

Definition f_bhv_cmd_break := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Sreturn (Some (Econst_int (Int.repr 1) tint)))
|}.

Definition f_bhv_cmd_break_unused := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Sreturn (Some (Econst_int (Int.repr 1) tint)))
|}.

Definition f_bhv_cmd_call := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_jumpAddress, (tptr tuint)) :: (_t'1, (tptr tvoid)) ::
               (_t'5, (tptr tuint)) :: (_t'4, (tptr tuint)) ::
               (_t'3, tuint) :: (_t'2, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5 (Evar _gCurBhvCommand (tptr tuint)))
    (Sassign (Evar _gCurBhvCommand (tptr tuint))
      (Ebinop Oadd (Etempvar _t'5 (tptr tuint))
        (Econst_int (Int.repr 1) tint) (tptr tuint))))
  (Ssequence
    (Ssequence
      (Sset _t'4 (Evar _gCurBhvCommand (tptr tuint)))
      (Scall None
        (Evar _cur_obj_bhv_stack_push (Tfunction (tuint :: nil) tvoid
                                        cc_default))
        ((Ecast
           (Ebinop Oadd (Etempvar _t'4 (tptr tuint))
             (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint) :: nil)))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _gCurBhvCommand (tptr tuint)))
          (Ssequence
            (Sset _t'3
              (Ederef
                (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
                  (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
            (Scall (Some _t'1)
              (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                            (tptr tvoid) cc_default))
              ((Ecast (Etempvar _t'3 tuint) (tptr tvoid)) :: nil))))
        (Sset _jumpAddress (Etempvar _t'1 (tptr tvoid))))
      (Ssequence
        (Sassign (Evar _gCurBhvCommand (tptr tuint))
          (Etempvar _jumpAddress (tptr tuint)))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_bhv_cmd_return := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _cur_obj_bhv_stack_pop (Tfunction nil tuint cc_default)) nil)
    (Sassign (Evar _gCurBhvCommand (tptr tuint))
      (Ecast (Etempvar _t'1 tuint) (tptr tuint))))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_bhv_cmd_delay := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_num, tshort) :: (_t'9, tuint) :: (_t'8, (tptr tuint)) ::
               (_t'7, tshort) :: (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr tuint)) :: (_t'2, tshort) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'9
        (Ederef
          (Ebinop Oadd (Etempvar _t'8 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _num
        (Ecast
          (Ecast
            (Ebinop Oand (Etempvar _t'9 tuint)
              (Econst_int (Int.repr 65535) tint) tuint) tshort) tshort))))
  (Ssequence
    (Ssequence
      (Sset _t'1 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
              (Tstruct _Object noattr)) _bhvDelayTimer tshort))
        (Sifthenelse (Ebinop Olt (Etempvar _t'2 tshort)
                       (Ebinop Osub (Etempvar _num tshort)
                         (Econst_int (Int.repr 1) tint) tint) tint)
          (Ssequence
            (Sset _t'5
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'6
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'7
                  (Efield
                    (Ederef (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _bhvDelayTimer tshort))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _bhvDelayTimer tshort)
                  (Ebinop Oadd (Etempvar _t'7 tshort)
                    (Econst_int (Int.repr 1) tint) tint)))))
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Sassign
                (Efield
                  (Ederef (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _bhvDelayTimer tshort)
                (Econst_int (Int.repr 0) tint)))
            (Ssequence
              (Sset _t'3 (Evar _gCurBhvCommand (tptr tuint)))
              (Sassign (Evar _gCurBhvCommand (tptr tuint))
                (Ebinop Oadd (Etempvar _t'3 (tptr tuint))
                  (Econst_int (Int.repr 1) tint) (tptr tuint))))))))
    (Sreturn (Some (Econst_int (Int.repr 1) tint)))))
|}.

Definition f_bhv_cmd_delay_var := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_field, tuchar) :: (_num, tint) :: (_t'10, tuint) ::
               (_t'9, (tptr tuint)) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tshort) ::
               (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr tuint)) :: (_t'2, tshort) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'10
        (Ederef
          (Ebinop Oadd (Etempvar _t'9 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _field
        (Ecast
          (Ecast
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'10 tuint)
                (Econst_int (Int.repr 16) tint) tuint)
              (Econst_int (Int.repr 255) tint) tuint) tuchar) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'8 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Sset _num
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
              _asS32 (tarray tint 80)) (Etempvar _field tuchar) (tptr tint))
          tint)))
    (Ssequence
      (Ssequence
        (Sset _t'1 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'2
            (Efield
              (Ederef (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _bhvDelayTimer tshort))
          (Sifthenelse (Ebinop Olt (Etempvar _t'2 tshort)
                         (Ebinop Osub (Etempvar _num tint)
                           (Econst_int (Int.repr 1) tint) tint) tint)
            (Ssequence
              (Sset _t'5
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'6
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'7
                    (Efield
                      (Ederef (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _bhvDelayTimer tshort))
                  (Sassign
                    (Efield
                      (Ederef (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _bhvDelayTimer tshort)
                    (Ebinop Oadd (Etempvar _t'7 tshort)
                      (Econst_int (Int.repr 1) tint) tint)))))
            (Ssequence
              (Ssequence
                (Sset _t'4
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _bhvDelayTimer tshort)
                  (Econst_int (Int.repr 0) tint)))
              (Ssequence
                (Sset _t'3 (Evar _gCurBhvCommand (tptr tuint)))
                (Sassign (Evar _gCurBhvCommand (tptr tuint))
                  (Ebinop Oadd (Etempvar _t'3 (tptr tuint))
                    (Econst_int (Int.repr 1) tint) (tptr tuint))))))))
      (Sreturn (Some (Econst_int (Int.repr 1) tint))))))
|}.

Definition f_bhv_cmd_goto := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr tvoid)) :: (_t'4, (tptr tuint)) ::
               (_t'3, tuint) :: (_t'2, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _gCurBhvCommand (tptr tuint)))
    (Sassign (Evar _gCurBhvCommand (tptr tuint))
      (Ebinop Oadd (Etempvar _t'4 (tptr tuint))
        (Econst_int (Int.repr 1) tint) (tptr tuint))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'2 (Evar _gCurBhvCommand (tptr tuint)))
        (Ssequence
          (Sset _t'3
            (Ederef
              (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
                (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
          (Scall (Some _t'1)
            (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                          (tptr tvoid) cc_default))
            ((Ecast (Etempvar _t'3 tuint) (tptr tvoid)) :: nil))))
      (Sassign (Evar _gCurBhvCommand (tptr tuint))
        (Etempvar _t'1 (tptr tvoid))))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_bhv_cmd_begin_repeat_unused := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_count, tint) :: (_t'4, tuint) :: (_t'3, (tptr tuint)) ::
               (_t'2, (tptr tuint)) :: (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'4
        (Ederef
          (Ebinop Oadd (Etempvar _t'3 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _count
        (Ecast
          (Ebinop Oand
            (Ebinop Oshr (Etempvar _t'4 tuint)
              (Econst_int (Int.repr 16) tint) tuint)
            (Econst_int (Int.repr 255) tint) tuint) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'2 (Evar _gCurBhvCommand (tptr tuint)))
      (Scall None
        (Evar _cur_obj_bhv_stack_push (Tfunction (tuint :: nil) tvoid
                                        cc_default))
        ((Ecast
           (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
             (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint) :: nil)))
    (Ssequence
      (Scall None
        (Evar _cur_obj_bhv_stack_push (Tfunction (tuint :: nil) tvoid
                                        cc_default))
        ((Etempvar _count tint) :: nil))
      (Ssequence
        (Ssequence
          (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
          (Sassign (Evar _gCurBhvCommand (tptr tuint))
            (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
              (Econst_int (Int.repr 1) tint) (tptr tuint))))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_bhv_cmd_begin_repeat := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_count, tint) :: (_t'4, tuint) :: (_t'3, (tptr tuint)) ::
               (_t'2, (tptr tuint)) :: (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'4
        (Ederef
          (Ebinop Oadd (Etempvar _t'3 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _count
        (Ecast
          (Ebinop Oand (Etempvar _t'4 tuint)
            (Econst_int (Int.repr 65535) tint) tuint) tshort))))
  (Ssequence
    (Ssequence
      (Sset _t'2 (Evar _gCurBhvCommand (tptr tuint)))
      (Scall None
        (Evar _cur_obj_bhv_stack_push (Tfunction (tuint :: nil) tvoid
                                        cc_default))
        ((Ecast
           (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
             (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint) :: nil)))
    (Ssequence
      (Scall None
        (Evar _cur_obj_bhv_stack_push (Tfunction (tuint :: nil) tvoid
                                        cc_default))
        ((Etempvar _count tint) :: nil))
      (Ssequence
        (Ssequence
          (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
          (Sassign (Evar _gCurBhvCommand (tptr tuint))
            (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
              (Econst_int (Int.repr 1) tint) (tptr tuint))))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_bhv_cmd_end_repeat := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_count, tuint) :: (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'4, (tptr tuint)) :: (_t'3, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _cur_obj_bhv_stack_pop (Tfunction nil tuint cc_default)) nil)
    (Sset _count (Etempvar _t'1 tuint)))
  (Ssequence
    (Sset _count
      (Ebinop Osub (Etempvar _count tuint) (Econst_int (Int.repr 1) tint)
        tuint))
    (Ssequence
      (Sifthenelse (Ebinop One (Etempvar _count tuint)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Ssequence
            (Scall (Some _t'2)
              (Evar _cur_obj_bhv_stack_pop (Tfunction nil tuint cc_default))
              nil)
            (Sassign (Evar _gCurBhvCommand (tptr tuint))
              (Ecast (Etempvar _t'2 tuint) (tptr tuint))))
          (Ssequence
            (Ssequence
              (Sset _t'4 (Evar _gCurBhvCommand (tptr tuint)))
              (Scall None
                (Evar _cur_obj_bhv_stack_push (Tfunction (tuint :: nil) tvoid
                                                cc_default))
                ((Ecast
                   (Ebinop Oadd (Etempvar _t'4 (tptr tuint))
                     (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint) ::
                 nil)))
            (Scall None
              (Evar _cur_obj_bhv_stack_push (Tfunction (tuint :: nil) tvoid
                                              cc_default))
              ((Etempvar _count tuint) :: nil))))
        (Ssequence
          (Scall None
            (Evar _cur_obj_bhv_stack_pop (Tfunction nil tuint cc_default))
            nil)
          (Ssequence
            (Sset _t'3 (Evar _gCurBhvCommand (tptr tuint)))
            (Sassign (Evar _gCurBhvCommand (tptr tuint))
              (Ebinop Oadd (Etempvar _t'3 (tptr tuint))
                (Econst_int (Int.repr 1) tint) (tptr tuint))))))
      (Sreturn (Some (Econst_int (Int.repr 1) tint))))))
|}.

Definition f_bhv_cmd_end_repeat_continue := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_count, tuint) :: (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'4, (tptr tuint)) :: (_t'3, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _cur_obj_bhv_stack_pop (Tfunction nil tuint cc_default)) nil)
    (Sset _count (Etempvar _t'1 tuint)))
  (Ssequence
    (Sset _count
      (Ebinop Osub (Etempvar _count tuint) (Econst_int (Int.repr 1) tint)
        tuint))
    (Ssequence
      (Sifthenelse (Ebinop One (Etempvar _count tuint)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Ssequence
            (Scall (Some _t'2)
              (Evar _cur_obj_bhv_stack_pop (Tfunction nil tuint cc_default))
              nil)
            (Sassign (Evar _gCurBhvCommand (tptr tuint))
              (Ecast (Etempvar _t'2 tuint) (tptr tuint))))
          (Ssequence
            (Ssequence
              (Sset _t'4 (Evar _gCurBhvCommand (tptr tuint)))
              (Scall None
                (Evar _cur_obj_bhv_stack_push (Tfunction (tuint :: nil) tvoid
                                                cc_default))
                ((Ecast
                   (Ebinop Oadd (Etempvar _t'4 (tptr tuint))
                     (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint) ::
                 nil)))
            (Scall None
              (Evar _cur_obj_bhv_stack_push (Tfunction (tuint :: nil) tvoid
                                              cc_default))
              ((Etempvar _count tuint) :: nil))))
        (Ssequence
          (Scall None
            (Evar _cur_obj_bhv_stack_pop (Tfunction nil tuint cc_default))
            nil)
          (Ssequence
            (Sset _t'3 (Evar _gCurBhvCommand (tptr tuint)))
            (Sassign (Evar _gCurBhvCommand (tptr tuint))
              (Ebinop Oadd (Etempvar _t'3 (tptr tuint))
                (Econst_int (Int.repr 1) tint) (tptr tuint))))))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_bhv_cmd_begin_loop := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, (tptr tuint)) :: (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2 (Evar _gCurBhvCommand (tptr tuint)))
    (Scall None
      (Evar _cur_obj_bhv_stack_push (Tfunction (tuint :: nil) tvoid
                                      cc_default))
      ((Ecast
         (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
           (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint) :: nil)))
  (Ssequence
    (Ssequence
      (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
      (Sassign (Evar _gCurBhvCommand (tptr tuint))
        (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
          (Econst_int (Int.repr 1) tint) (tptr tuint))))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_bhv_cmd_end_loop := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: (_t'2, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _cur_obj_bhv_stack_pop (Tfunction nil tuint cc_default)) nil)
    (Sassign (Evar _gCurBhvCommand (tptr tuint))
      (Ecast (Etempvar _t'1 tuint) (tptr tuint))))
  (Ssequence
    (Ssequence
      (Sset _t'2 (Evar _gCurBhvCommand (tptr tuint)))
      (Scall None
        (Evar _cur_obj_bhv_stack_push (Tfunction (tuint :: nil) tvoid
                                        cc_default))
        ((Ecast
           (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
             (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint) :: nil)))
    (Sreturn (Some (Econst_int (Int.repr 1) tint)))))
|}.

Definition f_bhv_cmd_call_native := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_behaviorFunc, (tptr (Tfunction nil tvoid cc_default))) ::
               (_t'3, tuint) :: (_t'2, (tptr tuint)) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'3
        (Ederef
          (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
            (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
      (Sset _behaviorFunc (Ecast (Etempvar _t'3 tuint) (tptr tvoid)))))
  (Ssequence
    (Scall None
      (Etempvar _behaviorFunc (tptr (Tfunction nil tvoid cc_default))) nil)
    (Ssequence
      (Ssequence
        (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
        (Sassign (Evar _gCurBhvCommand (tptr tuint))
          (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
            (Econst_int (Int.repr 2) tint) (tptr tuint))))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_bhv_cmd_set_float := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_field, tuchar) :: (_value, tfloat) :: (_t'6, tuint) ::
               (_t'5, (tptr tuint)) :: (_t'4, tuint) ::
               (_t'3, (tptr tuint)) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'6
        (Ederef
          (Ebinop Oadd (Etempvar _t'5 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _field
        (Ecast
          (Ecast
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'6 tuint)
                (Econst_int (Int.repr 16) tint) tuint)
              (Econst_int (Int.repr 255) tint) tuint) tuchar) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'3 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'4
          (Ederef
            (Ebinop Oadd (Etempvar _t'3 (tptr tuint))
              (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
        (Sset _value
          (Ecast
            (Ecast
              (Ebinop Oand (Etempvar _t'4 tuint)
                (Econst_int (Int.repr 65535) tint) tuint) tshort) tfloat))))
    (Ssequence
      (Ssequence
        (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
                _asF32 (tarray tfloat 80)) (Etempvar _field tuchar)
              (tptr tfloat)) tfloat) (Ecast (Etempvar _value tfloat) tfloat)))
      (Ssequence
        (Ssequence
          (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
          (Sassign (Evar _gCurBhvCommand (tptr tuint))
            (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
              (Econst_int (Int.repr 1) tint) (tptr tuint))))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_bhv_cmd_set_int := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_field, tuchar) :: (_value, tshort) :: (_t'6, tuint) ::
               (_t'5, (tptr tuint)) :: (_t'4, tuint) ::
               (_t'3, (tptr tuint)) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'6
        (Ederef
          (Ebinop Oadd (Etempvar _t'5 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _field
        (Ecast
          (Ecast
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'6 tuint)
                (Econst_int (Int.repr 16) tint) tuint)
              (Econst_int (Int.repr 255) tint) tuint) tuchar) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'3 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'4
          (Ederef
            (Ebinop Oadd (Etempvar _t'3 (tptr tuint))
              (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
        (Sset _value
          (Ecast
            (Ecast
              (Ebinop Oand (Etempvar _t'4 tuint)
                (Econst_int (Int.repr 65535) tint) tuint) tshort) tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
                _asS32 (tarray tint 80)) (Etempvar _field tuchar)
              (tptr tint)) tint) (Ecast (Etempvar _value tshort) tint)))
      (Ssequence
        (Ssequence
          (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
          (Sassign (Evar _gCurBhvCommand (tptr tuint))
            (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
              (Econst_int (Int.repr 1) tint) (tptr tuint))))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_bhv_cmd_set_int_unused := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_field, tuchar) :: (_value, tint) :: (_t'6, tuint) ::
               (_t'5, (tptr tuint)) :: (_t'4, tuint) ::
               (_t'3, (tptr tuint)) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'6
        (Ederef
          (Ebinop Oadd (Etempvar _t'5 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _field
        (Ecast
          (Ecast
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'6 tuint)
                (Econst_int (Int.repr 16) tint) tuint)
              (Econst_int (Int.repr 255) tint) tuint) tuchar) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'3 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'4
          (Ederef
            (Ebinop Oadd (Etempvar _t'3 (tptr tuint))
              (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
        (Sset _value
          (Ecast
            (Ebinop Oand (Etempvar _t'4 tuint)
              (Econst_int (Int.repr 65535) tint) tuint) tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
                _asS32 (tarray tint 80)) (Etempvar _field tuchar)
              (tptr tint)) tint) (Ecast (Etempvar _value tint) tint)))
      (Ssequence
        (Ssequence
          (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
          (Sassign (Evar _gCurBhvCommand (tptr tuint))
            (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
              (Econst_int (Int.repr 2) tint) (tptr tuint))))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_bhv_cmd_set_random_float := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_field, tuchar) :: (_min, tfloat) :: (_range, tfloat) ::
               (_t'1, tfloat) :: (_t'9, tuint) :: (_t'8, (tptr tuint)) ::
               (_t'7, tuint) :: (_t'6, (tptr tuint)) :: (_t'5, tuint) ::
               (_t'4, (tptr tuint)) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'9
        (Ederef
          (Ebinop Oadd (Etempvar _t'8 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _field
        (Ecast
          (Ecast
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'9 tuint)
                (Econst_int (Int.repr 16) tint) tuint)
              (Econst_int (Int.repr 255) tint) tuint) tuchar) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'6 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'7
          (Ederef
            (Ebinop Oadd (Etempvar _t'6 (tptr tuint))
              (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
        (Sset _min
          (Ecast
            (Ecast
              (Ebinop Oand (Etempvar _t'7 tuint)
                (Econst_int (Int.repr 65535) tint) tuint) tshort) tfloat))))
    (Ssequence
      (Ssequence
        (Sset _t'4 (Evar _gCurBhvCommand (tptr tuint)))
        (Ssequence
          (Sset _t'5
            (Ederef
              (Ebinop Oadd (Etempvar _t'4 (tptr tuint))
                (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
          (Sset _range
            (Ecast
              (Ecast
                (Ebinop Oshr (Etempvar _t'5 tuint)
                  (Econst_int (Int.repr 16) tint) tuint) tshort) tfloat))))
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _random_float (Tfunction nil tfloat cc_default)) nil)
          (Ssequence
            (Sset _t'3
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                  (Etempvar _field tuchar) (tptr tfloat)) tfloat)
              (Ecast
                (Ebinop Oadd
                  (Ebinop Omul (Etempvar _range tfloat)
                    (Etempvar _t'1 tfloat) tfloat) (Etempvar _min tfloat)
                  tfloat) tfloat))))
        (Ssequence
          (Ssequence
            (Sset _t'2 (Evar _gCurBhvCommand (tptr tuint)))
            (Sassign (Evar _gCurBhvCommand (tptr tuint))
              (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
                (Econst_int (Int.repr 2) tint) (tptr tuint))))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_bhv_cmd_set_random_int := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_field, tuchar) :: (_min, tint) :: (_range, tint) ::
               (_t'1, tfloat) :: (_t'9, tuint) :: (_t'8, (tptr tuint)) ::
               (_t'7, tuint) :: (_t'6, (tptr tuint)) :: (_t'5, tuint) ::
               (_t'4, (tptr tuint)) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'9
        (Ederef
          (Ebinop Oadd (Etempvar _t'8 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _field
        (Ecast
          (Ecast
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'9 tuint)
                (Econst_int (Int.repr 16) tint) tuint)
              (Econst_int (Int.repr 255) tint) tuint) tuchar) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'6 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'7
          (Ederef
            (Ebinop Oadd (Etempvar _t'6 (tptr tuint))
              (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
        (Sset _min
          (Ecast
            (Ebinop Oand (Etempvar _t'7 tuint)
              (Econst_int (Int.repr 65535) tint) tuint) tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'4 (Evar _gCurBhvCommand (tptr tuint)))
        (Ssequence
          (Sset _t'5
            (Ederef
              (Ebinop Oadd (Etempvar _t'4 (tptr tuint))
                (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
          (Sset _range
            (Ecast
              (Ebinop Oshr (Etempvar _t'5 tuint)
                (Econst_int (Int.repr 16) tint) tuint) tshort))))
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _random_float (Tfunction nil tfloat cc_default)) nil)
          (Ssequence
            (Sset _t'3
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __764 noattr)) _asS32 (tarray tint 80))
                  (Etempvar _field tuchar) (tptr tint)) tint)
              (Ecast
                (Ebinop Oadd
                  (Ecast
                    (Ebinop Omul (Etempvar _range tint)
                      (Etempvar _t'1 tfloat) tfloat) tint)
                  (Etempvar _min tint) tint) tint))))
        (Ssequence
          (Ssequence
            (Sset _t'2 (Evar _gCurBhvCommand (tptr tuint)))
            (Sassign (Evar _gCurBhvCommand (tptr tuint))
              (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
                (Econst_int (Int.repr 2) tint) (tptr tuint))))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_bhv_cmd_set_int_rand_rshift := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_field, tuchar) :: (_min, tint) :: (_rshift, tint) ::
               (_t'1, tushort) :: (_t'9, tuint) :: (_t'8, (tptr tuint)) ::
               (_t'7, tuint) :: (_t'6, (tptr tuint)) :: (_t'5, tuint) ::
               (_t'4, (tptr tuint)) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'9
        (Ederef
          (Ebinop Oadd (Etempvar _t'8 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _field
        (Ecast
          (Ecast
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'9 tuint)
                (Econst_int (Int.repr 16) tint) tuint)
              (Econst_int (Int.repr 255) tint) tuint) tuchar) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'6 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'7
          (Ederef
            (Ebinop Oadd (Etempvar _t'6 (tptr tuint))
              (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
        (Sset _min
          (Ecast
            (Ebinop Oand (Etempvar _t'7 tuint)
              (Econst_int (Int.repr 65535) tint) tuint) tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'4 (Evar _gCurBhvCommand (tptr tuint)))
        (Ssequence
          (Sset _t'5
            (Ederef
              (Ebinop Oadd (Etempvar _t'4 (tptr tuint))
                (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
          (Sset _rshift
            (Ecast
              (Ebinop Oshr (Etempvar _t'5 tuint)
                (Econst_int (Int.repr 16) tint) tuint) tshort))))
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _random_u16 (Tfunction nil tushort cc_default)) nil)
          (Ssequence
            (Sset _t'3
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __764 noattr)) _asS32 (tarray tint 80))
                  (Etempvar _field tuchar) (tptr tint)) tint)
              (Ecast
                (Ebinop Oadd
                  (Ebinop Oshr (Etempvar _t'1 tushort)
                    (Etempvar _rshift tint) tint) (Etempvar _min tint) tint)
                tint))))
        (Ssequence
          (Ssequence
            (Sset _t'2 (Evar _gCurBhvCommand (tptr tuint)))
            (Sassign (Evar _gCurBhvCommand (tptr tuint))
              (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
                (Econst_int (Int.repr 2) tint) (tptr tuint))))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_bhv_cmd_add_random_float := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_field, tuchar) :: (_min, tfloat) :: (_range, tfloat) ::
               (_t'1, tfloat) :: (_t'11, tuint) :: (_t'10, (tptr tuint)) ::
               (_t'9, tuint) :: (_t'8, (tptr tuint)) :: (_t'7, tuint) ::
               (_t'6, (tptr tuint)) :: (_t'5, tfloat) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'10 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'11
        (Ederef
          (Ebinop Oadd (Etempvar _t'10 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _field
        (Ecast
          (Ecast
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'11 tuint)
                (Econst_int (Int.repr 16) tint) tuint)
              (Econst_int (Int.repr 255) tint) tuint) tuchar) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'8 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'9
          (Ederef
            (Ebinop Oadd (Etempvar _t'8 (tptr tuint))
              (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
        (Sset _min
          (Ecast
            (Ecast
              (Ebinop Oand (Etempvar _t'9 tuint)
                (Econst_int (Int.repr 65535) tint) tuint) tshort) tfloat))))
    (Ssequence
      (Ssequence
        (Sset _t'6 (Evar _gCurBhvCommand (tptr tuint)))
        (Ssequence
          (Sset _t'7
            (Ederef
              (Ebinop Oadd (Etempvar _t'6 (tptr tuint))
                (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
          (Sset _range
            (Ecast
              (Ecast
                (Ebinop Oshr (Etempvar _t'7 tuint)
                  (Econst_int (Int.repr 16) tint) tuint) tshort) tfloat))))
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _random_float (Tfunction nil tfloat cc_default)) nil)
          (Ssequence
            (Sset _t'3
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'4
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'5
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                      (Etempvar _field tuchar) (tptr tfloat)) tfloat))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                      (Etempvar _field tuchar) (tptr tfloat)) tfloat)
                  (Ecast
                    (Ebinop Oadd
                      (Ebinop Oadd (Etempvar _t'5 tfloat)
                        (Etempvar _min tfloat) tfloat)
                      (Ebinop Omul (Etempvar _range tfloat)
                        (Etempvar _t'1 tfloat) tfloat) tfloat) tfloat))))))
        (Ssequence
          (Ssequence
            (Sset _t'2 (Evar _gCurBhvCommand (tptr tuint)))
            (Sassign (Evar _gCurBhvCommand (tptr tuint))
              (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
                (Econst_int (Int.repr 2) tint) (tptr tuint))))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_bhv_cmd_add_int_rand_rshift := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_field, tuchar) :: (_min, tint) :: (_rshift, tint) ::
               (_rnd, tint) :: (_t'1, tushort) :: (_t'11, tuint) ::
               (_t'10, (tptr tuint)) :: (_t'9, tuint) ::
               (_t'8, (tptr tuint)) :: (_t'7, tuint) ::
               (_t'6, (tptr tuint)) :: (_t'5, tint) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'10 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'11
        (Ederef
          (Ebinop Oadd (Etempvar _t'10 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _field
        (Ecast
          (Ecast
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'11 tuint)
                (Econst_int (Int.repr 16) tint) tuint)
              (Econst_int (Int.repr 255) tint) tuint) tuchar) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'8 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'9
          (Ederef
            (Ebinop Oadd (Etempvar _t'8 (tptr tuint))
              (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
        (Sset _min
          (Ecast
            (Ebinop Oand (Etempvar _t'9 tuint)
              (Econst_int (Int.repr 65535) tint) tuint) tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'6 (Evar _gCurBhvCommand (tptr tuint)))
        (Ssequence
          (Sset _t'7
            (Ederef
              (Ebinop Oadd (Etempvar _t'6 (tptr tuint))
                (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
          (Sset _rshift
            (Ecast
              (Ebinop Oshr (Etempvar _t'7 tuint)
                (Econst_int (Int.repr 16) tint) tuint) tshort))))
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _random_u16 (Tfunction nil tushort cc_default)) nil)
          (Sset _rnd (Etempvar _t'1 tushort)))
        (Ssequence
          (Ssequence
            (Sset _t'3
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'4
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'5
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __764 noattr)) _asS32 (tarray tint 80))
                      (Etempvar _field tuchar) (tptr tint)) tint))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __764 noattr)) _asS32 (tarray tint 80))
                      (Etempvar _field tuchar) (tptr tint)) tint)
                  (Ecast
                    (Ebinop Oadd
                      (Ebinop Oadd (Etempvar _t'5 tint) (Etempvar _min tint)
                        tint)
                      (Ebinop Oshr (Etempvar _rnd tint)
                        (Etempvar _rshift tint) tint) tint) tint)))))
          (Ssequence
            (Ssequence
              (Sset _t'2 (Evar _gCurBhvCommand (tptr tuint)))
              (Sassign (Evar _gCurBhvCommand (tptr tuint))
                (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
                  (Econst_int (Int.repr 2) tint) (tptr tuint))))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_bhv_cmd_add_float := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_field, tuchar) :: (_value, tfloat) :: (_t'8, tuint) ::
               (_t'7, (tptr tuint)) :: (_t'6, tuint) ::
               (_t'5, (tptr tuint)) :: (_t'4, tfloat) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'8
        (Ederef
          (Ebinop Oadd (Etempvar _t'7 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _field
        (Ecast
          (Ecast
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'8 tuint)
                (Econst_int (Int.repr 16) tint) tuint)
              (Econst_int (Int.repr 255) tint) tuint) tuchar) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'5 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'6
          (Ederef
            (Ebinop Oadd (Etempvar _t'5 (tptr tuint))
              (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
        (Sset _value
          (Ecast
            (Ecast
              (Ebinop Oand (Etempvar _t'6 tuint)
                (Econst_int (Int.repr 65535) tint) tuint) tshort) tfloat))))
    (Ssequence
      (Ssequence
        (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'3 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'4
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                  (Etempvar _field tuchar) (tptr tfloat)) tfloat))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                  (Etempvar _field tuchar) (tptr tfloat)) tfloat)
              (Ebinop Oadd (Etempvar _t'4 tfloat)
                (Ecast (Etempvar _value tfloat) tfloat) tfloat)))))
      (Ssequence
        (Ssequence
          (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
          (Sassign (Evar _gCurBhvCommand (tptr tuint))
            (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
              (Econst_int (Int.repr 1) tint) (tptr tuint))))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_bhv_cmd_add_int := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_field, tuchar) :: (_value, tshort) :: (_t'8, tuint) ::
               (_t'7, (tptr tuint)) :: (_t'6, tuint) ::
               (_t'5, (tptr tuint)) :: (_t'4, tint) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'8
        (Ederef
          (Ebinop Oadd (Etempvar _t'7 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _field
        (Ecast
          (Ecast
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'8 tuint)
                (Econst_int (Int.repr 16) tint) tuint)
              (Econst_int (Int.repr 255) tint) tuint) tuchar) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'5 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'6
          (Ederef
            (Ebinop Oadd (Etempvar _t'5 (tptr tuint))
              (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
        (Sset _value
          (Ecast
            (Ecast
              (Ebinop Oand (Etempvar _t'6 tuint)
                (Econst_int (Int.repr 65535) tint) tuint) tshort) tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'3 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'4
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __764 noattr)) _asS32 (tarray tint 80))
                  (Etempvar _field tuchar) (tptr tint)) tint))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __764 noattr)) _asS32 (tarray tint 80))
                  (Etempvar _field tuchar) (tptr tint)) tint)
              (Ebinop Oadd (Etempvar _t'4 tint)
                (Ecast (Etempvar _value tshort) tint) tint)))))
      (Ssequence
        (Ssequence
          (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
          (Sassign (Evar _gCurBhvCommand (tptr tuint))
            (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
              (Econst_int (Int.repr 1) tint) (tptr tuint))))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_bhv_cmd_or_int := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_objectOffset, tuchar) :: (_value, tint) :: (_t'8, tuint) ::
               (_t'7, (tptr tuint)) :: (_t'6, tuint) ::
               (_t'5, (tptr tuint)) :: (_t'4, tint) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'8
        (Ederef
          (Ebinop Oadd (Etempvar _t'7 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _objectOffset
        (Ecast
          (Ecast
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'8 tuint)
                (Econst_int (Int.repr 16) tint) tuint)
              (Econst_int (Int.repr 255) tint) tuint) tuchar) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'5 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'6
          (Ederef
            (Ebinop Oadd (Etempvar _t'5 (tptr tuint))
              (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
        (Sset _value
          (Ecast
            (Ebinop Oand (Etempvar _t'6 tuint)
              (Econst_int (Int.repr 65535) tint) tuint) tshort))))
    (Ssequence
      (Sset _value
        (Ebinop Oand (Etempvar _value tint)
          (Econst_int (Int.repr 65535) tint) tint))
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'3
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'4
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __764 noattr)) _asS32 (tarray tint 80))
                    (Etempvar _objectOffset tuchar) (tptr tint)) tint))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __764 noattr)) _asS32 (tarray tint 80))
                    (Etempvar _objectOffset tuchar) (tptr tint)) tint)
                (Ebinop Oor (Etempvar _t'4 tint)
                  (Ecast (Etempvar _value tint) tint) tint)))))
        (Ssequence
          (Ssequence
            (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
            (Sassign (Evar _gCurBhvCommand (tptr tuint))
              (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
                (Econst_int (Int.repr 1) tint) (tptr tuint))))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_bhv_cmd_bit_clear := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_field, tuchar) :: (_value, tint) :: (_t'8, tuint) ::
               (_t'7, (tptr tuint)) :: (_t'6, tuint) ::
               (_t'5, (tptr tuint)) :: (_t'4, tint) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'8
        (Ederef
          (Ebinop Oadd (Etempvar _t'7 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _field
        (Ecast
          (Ecast
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'8 tuint)
                (Econst_int (Int.repr 16) tint) tuint)
              (Econst_int (Int.repr 255) tint) tuint) tuchar) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'5 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'6
          (Ederef
            (Ebinop Oadd (Etempvar _t'5 (tptr tuint))
              (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
        (Sset _value
          (Ecast
            (Ebinop Oand (Etempvar _t'6 tuint)
              (Econst_int (Int.repr 65535) tint) tuint) tshort))))
    (Ssequence
      (Sset _value
        (Ebinop Oxor
          (Ebinop Oand (Etempvar _value tint)
            (Econst_int (Int.repr 65535) tint) tint)
          (Econst_int (Int.repr 65535) tint) tint))
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'3
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'4
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __764 noattr)) _asS32 (tarray tint 80))
                    (Etempvar _field tuchar) (tptr tint)) tint))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __764 noattr)) _asS32 (tarray tint 80))
                    (Etempvar _field tuchar) (tptr tint)) tint)
                (Ebinop Oand (Etempvar _t'4 tint)
                  (Ecast (Etempvar _value tint) tint) tint)))))
        (Ssequence
          (Ssequence
            (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
            (Sassign (Evar _gCurBhvCommand (tptr tuint))
              (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
                (Econst_int (Int.repr 1) tint) (tptr tuint))))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_bhv_cmd_load_animations := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_field, tuchar) :: (_t'6, tuint) :: (_t'5, (tptr tuint)) ::
               (_t'4, tuint) :: (_t'3, (tptr tuint)) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'6
        (Ederef
          (Ebinop Oadd (Etempvar _t'5 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _field
        (Ecast
          (Ecast
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'6 tuint)
                (Econst_int (Int.repr 16) tint) tuint)
              (Econst_int (Int.repr 255) tint) tuint) tuchar) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'3 (Evar _gCurBhvCommand (tptr tuint)))
        (Ssequence
          (Sset _t'4
            (Ederef
              (Ebinop Oadd (Etempvar _t'3 (tptr tuint))
                (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __764 noattr)) _asVoidPtr
                  (tarray (tptr tvoid) 80)) (Etempvar _field tuchar)
                (tptr (tptr tvoid))) (tptr tvoid))
            (Ecast (Ecast (Etempvar _t'4 tuint) (tptr tvoid)) (tptr tvoid))))))
    (Ssequence
      (Ssequence
        (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
        (Sassign (Evar _gCurBhvCommand (tptr tuint))
          (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
            (Econst_int (Int.repr 2) tint) (tptr tuint))))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_bhv_cmd_animate := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_animIndex, tint) ::
               (_animations, (tptr (tptr (Tstruct _Animation noattr)))) ::
               (_t'5, tuint) :: (_t'4, (tptr tuint)) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'5
        (Ederef
          (Ebinop Oadd (Etempvar _t'4 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _animIndex
        (Ecast
          (Ebinop Oand
            (Ebinop Oshr (Etempvar _t'5 tuint)
              (Econst_int (Int.repr 16) tint) tuint)
            (Econst_int (Int.repr 255) tint) tuint) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'3 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Sset _animations
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
              _asAnims (tarray (tptr (tptr (Tstruct _Animation noattr))) 80))
            (Econst_int (Int.repr 38) tint)
            (tptr (tptr (tptr (Tstruct _Animation noattr)))))
          (tptr (tptr (Tstruct _Animation noattr))))))
    (Ssequence
      (Ssequence
        (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Scall None
          (Evar _geo_obj_init_animation (Tfunction
                                          ((tptr (Tstruct _GraphNodeObject noattr)) ::
                                           (tptr (tptr (Tstruct _Animation noattr))) ::
                                           nil) tvoid cc_default))
          ((Eaddrof
             (Efield
               (Efield
                 (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                   (Tstruct _Object noattr)) _header
                 (Tstruct _ObjectNode noattr)) _gfx
               (Tstruct _GraphNodeObject noattr))
             (tptr (Tstruct _GraphNodeObject noattr))) ::
           (Ebinop Oadd
             (Etempvar _animations (tptr (tptr (Tstruct _Animation noattr))))
             (Etempvar _animIndex tint)
             (tptr (tptr (Tstruct _Animation noattr)))) :: nil)))
      (Ssequence
        (Ssequence
          (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
          (Sassign (Evar _gCurBhvCommand (tptr tuint))
            (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
              (Econst_int (Int.repr 1) tint) (tptr tuint))))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_bhv_cmd_drop_to_floor := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_x, tfloat) :: (_y, tfloat) :: (_z, tfloat) ::
               (_floor, tfloat) :: (_t'1, tfloat) ::
               (_t'9, (tptr (Tstruct _Object noattr))) ::
               (_t'8, (tptr (Tstruct _Object noattr))) ::
               (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tuint) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
    (Sset _x
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Ederef (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
            _asF32 (tarray tfloat 80))
          (Ebinop Oadd (Econst_int (Int.repr 6) tint)
            (Econst_int (Int.repr 0) tint) tint) (tptr tfloat)) tfloat)))
  (Ssequence
    (Ssequence
      (Sset _t'8 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Sset _y
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
              _asF32 (tarray tfloat 80))
            (Ebinop Oadd (Econst_int (Int.repr 6) tint)
              (Econst_int (Int.repr 1) tint) tint) (tptr tfloat)) tfloat)))
    (Ssequence
      (Ssequence
        (Sset _t'7 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Sset _z
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
                _asF32 (tarray tfloat 80))
              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                (Econst_int (Int.repr 2) tint) tint) (tptr tfloat)) tfloat)))
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _find_floor_height (Tfunction
                                       (tfloat :: tfloat :: tfloat :: nil)
                                       tfloat cc_default))
            ((Etempvar _x tfloat) ::
             (Ebinop Oadd (Etempvar _y tfloat)
               (Econst_single (Float32.of_bits (Int.repr 1128792064)) tfloat)
               tfloat) :: (Etempvar _z tfloat) :: nil))
          (Sset _floor (Etempvar _t'1 tfloat)))
        (Ssequence
          (Ssequence
            (Sset _t'6
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                  (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                    (Econst_int (Int.repr 1) tint) tint) (tptr tfloat))
                tfloat) (Etempvar _floor tfloat)))
          (Ssequence
            (Ssequence
              (Sset _t'3
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'4
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'5
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __764 noattr)) _asU32 (tarray tuint 80))
                        (Econst_int (Int.repr 25) tint) (tptr tuint)) tuint))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __764 noattr)) _asU32 (tarray tuint 80))
                        (Econst_int (Int.repr 25) tint) (tptr tuint)) tuint)
                    (Ebinop Oor (Etempvar _t'5 tuint)
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)))))
            (Ssequence
              (Ssequence
                (Sset _t'2 (Evar _gCurBhvCommand (tptr tuint)))
                (Sassign (Evar _gCurBhvCommand (tptr tuint))
                  (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
                    (Econst_int (Int.repr 1) tint) (tptr tuint))))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_bhv_cmd_nop_1 := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_field, tuchar) :: (_t'3, tuint) :: (_t'2, (tptr tuint)) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'3
        (Ederef
          (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _field
        (Ecast
          (Ecast
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'3 tuint)
                (Econst_int (Int.repr 16) tint) tuint)
              (Econst_int (Int.repr 255) tint) tuint) tuchar) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
      (Sassign (Evar _gCurBhvCommand (tptr tuint))
        (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
          (Econst_int (Int.repr 1) tint) (tptr tuint))))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_bhv_cmd_nop_3 := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_field, tuchar) :: (_t'3, tuint) :: (_t'2, (tptr tuint)) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'3
        (Ederef
          (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _field
        (Ecast
          (Ecast
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'3 tuint)
                (Econst_int (Int.repr 16) tint) tuint)
              (Econst_int (Int.repr 255) tint) tuint) tuchar) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
      (Sassign (Evar _gCurBhvCommand (tptr tuint))
        (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
          (Econst_int (Int.repr 1) tint) (tptr tuint))))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_bhv_cmd_nop_2 := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_field, tuchar) :: (_t'3, tuint) :: (_t'2, (tptr tuint)) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'3
        (Ederef
          (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _field
        (Ecast
          (Ecast
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'3 tuint)
                (Econst_int (Int.repr 16) tint) tuint)
              (Econst_int (Int.repr 255) tint) tuint) tuchar) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
      (Sassign (Evar _gCurBhvCommand (tptr tuint))
        (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
          (Econst_int (Int.repr 1) tint) (tptr tuint))))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_bhv_cmd_sum_float := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_fieldDst, tuint) :: (_fieldSrc1, tuint) ::
               (_fieldSrc2, tuint) :: (_t'12, tuint) ::
               (_t'11, (tptr tuint)) :: (_t'10, tuint) ::
               (_t'9, (tptr tuint)) :: (_t'8, tuint) ::
               (_t'7, (tptr tuint)) :: (_t'6, tfloat) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: (_t'4, tfloat) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'11 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'12
        (Ederef
          (Ebinop Oadd (Etempvar _t'11 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _fieldDst
        (Ecast
          (Ebinop Oand
            (Ebinop Oshr (Etempvar _t'12 tuint)
              (Econst_int (Int.repr 16) tint) tuint)
            (Econst_int (Int.repr 255) tint) tuint) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'9 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'10
          (Ederef
            (Ebinop Oadd (Etempvar _t'9 (tptr tuint))
              (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
        (Sset _fieldSrc1
          (Ecast
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'10 tuint)
                (Econst_int (Int.repr 8) tint) tuint)
              (Econst_int (Int.repr 255) tint) tuint) tuchar))))
    (Ssequence
      (Ssequence
        (Sset _t'7 (Evar _gCurBhvCommand (tptr tuint)))
        (Ssequence
          (Sset _t'8
            (Ederef
              (Ebinop Oadd (Etempvar _t'7 (tptr tuint))
                (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
          (Sset _fieldSrc2
            (Ecast
              (Ebinop Oand (Etempvar _t'8 tuint)
                (Econst_int (Int.repr 255) tint) tuint) tuchar))))
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'3
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'4
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                    (Etempvar _fieldSrc1 tuint) (tptr tfloat)) tfloat))
              (Ssequence
                (Sset _t'5
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'6
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                        (Etempvar _fieldSrc2 tuint) (tptr tfloat)) tfloat))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                        (Etempvar _fieldDst tuint) (tptr tfloat)) tfloat)
                    (Ecast
                      (Ebinop Oadd (Etempvar _t'4 tfloat)
                        (Etempvar _t'6 tfloat) tfloat) tfloat)))))))
        (Ssequence
          (Ssequence
            (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
            (Sassign (Evar _gCurBhvCommand (tptr tuint))
              (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
                (Econst_int (Int.repr 1) tint) (tptr tuint))))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_bhv_cmd_sum_int := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_fieldDst, tuint) :: (_fieldSrc1, tuint) ::
               (_fieldSrc2, tuint) :: (_t'12, tuint) ::
               (_t'11, (tptr tuint)) :: (_t'10, tuint) ::
               (_t'9, (tptr tuint)) :: (_t'8, tuint) ::
               (_t'7, (tptr tuint)) :: (_t'6, tint) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: (_t'4, tint) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'11 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'12
        (Ederef
          (Ebinop Oadd (Etempvar _t'11 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _fieldDst
        (Ecast
          (Ebinop Oand
            (Ebinop Oshr (Etempvar _t'12 tuint)
              (Econst_int (Int.repr 16) tint) tuint)
            (Econst_int (Int.repr 255) tint) tuint) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'9 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'10
          (Ederef
            (Ebinop Oadd (Etempvar _t'9 (tptr tuint))
              (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
        (Sset _fieldSrc1
          (Ecast
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'10 tuint)
                (Econst_int (Int.repr 8) tint) tuint)
              (Econst_int (Int.repr 255) tint) tuint) tuchar))))
    (Ssequence
      (Ssequence
        (Sset _t'7 (Evar _gCurBhvCommand (tptr tuint)))
        (Ssequence
          (Sset _t'8
            (Ederef
              (Ebinop Oadd (Etempvar _t'7 (tptr tuint))
                (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
          (Sset _fieldSrc2
            (Ecast
              (Ebinop Oand (Etempvar _t'8 tuint)
                (Econst_int (Int.repr 255) tint) tuint) tuchar))))
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'3
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'4
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __764 noattr)) _asS32 (tarray tint 80))
                    (Etempvar _fieldSrc1 tuint) (tptr tint)) tint))
              (Ssequence
                (Sset _t'5
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'6
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __764 noattr)) _asS32 (tarray tint 80))
                        (Etempvar _fieldSrc2 tuint) (tptr tint)) tint))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __764 noattr)) _asS32 (tarray tint 80))
                        (Etempvar _fieldDst tuint) (tptr tint)) tint)
                    (Ecast
                      (Ebinop Oadd (Etempvar _t'4 tint) (Etempvar _t'6 tint)
                        tint) tint)))))))
        (Ssequence
          (Ssequence
            (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
            (Sassign (Evar _gCurBhvCommand (tptr tuint))
              (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
                (Econst_int (Int.repr 1) tint) (tptr tuint))))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_bhv_cmd_set_hitbox := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_radius, tshort) :: (_height, tshort) :: (_t'7, tuint) ::
               (_t'6, (tptr tuint)) :: (_t'5, tuint) ::
               (_t'4, (tptr tuint)) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'7
        (Ederef
          (Ebinop Oadd (Etempvar _t'6 (tptr tuint))
            (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
      (Sset _radius
        (Ecast
          (Ecast
            (Ebinop Oshr (Etempvar _t'7 tuint)
              (Econst_int (Int.repr 16) tint) tuint) tshort) tshort))))
  (Ssequence
    (Ssequence
      (Sset _t'4 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'5
          (Ederef
            (Ebinop Oadd (Etempvar _t'4 (tptr tuint))
              (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
        (Sset _height
          (Ecast
            (Ecast
              (Ebinop Oand (Etempvar _t'5 tuint)
                (Econst_int (Int.repr 65535) tint) tuint) tshort) tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'3 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Sassign
          (Efield
            (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
              (Tstruct _Object noattr)) _hitboxRadius tfloat)
          (Etempvar _radius tshort)))
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Sassign
            (Efield
              (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _hitboxHeight tfloat)
            (Etempvar _height tshort)))
        (Ssequence
          (Ssequence
            (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
            (Sassign (Evar _gCurBhvCommand (tptr tuint))
              (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
                (Econst_int (Int.repr 2) tint) (tptr tuint))))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_bhv_cmd_set_hurtbox := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_radius, tshort) :: (_height, tshort) :: (_t'7, tuint) ::
               (_t'6, (tptr tuint)) :: (_t'5, tuint) ::
               (_t'4, (tptr tuint)) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'7
        (Ederef
          (Ebinop Oadd (Etempvar _t'6 (tptr tuint))
            (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
      (Sset _radius
        (Ecast
          (Ecast
            (Ebinop Oshr (Etempvar _t'7 tuint)
              (Econst_int (Int.repr 16) tint) tuint) tshort) tshort))))
  (Ssequence
    (Ssequence
      (Sset _t'4 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'5
          (Ederef
            (Ebinop Oadd (Etempvar _t'4 (tptr tuint))
              (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
        (Sset _height
          (Ecast
            (Ecast
              (Ebinop Oand (Etempvar _t'5 tuint)
                (Econst_int (Int.repr 65535) tint) tuint) tshort) tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'3 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Sassign
          (Efield
            (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
              (Tstruct _Object noattr)) _hurtboxRadius tfloat)
          (Etempvar _radius tshort)))
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Sassign
            (Efield
              (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _hurtboxHeight tfloat)
            (Etempvar _height tshort)))
        (Ssequence
          (Ssequence
            (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
            (Sassign (Evar _gCurBhvCommand (tptr tuint))
              (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
                (Econst_int (Int.repr 2) tint) (tptr tuint))))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_bhv_cmd_set_hitbox_with_offset := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_radius, tshort) :: (_height, tshort) ::
               (_downOffset, tshort) :: (_t'10, tuint) ::
               (_t'9, (tptr tuint)) :: (_t'8, tuint) ::
               (_t'7, (tptr tuint)) :: (_t'6, tuint) ::
               (_t'5, (tptr tuint)) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'10
        (Ederef
          (Ebinop Oadd (Etempvar _t'9 (tptr tuint))
            (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
      (Sset _radius
        (Ecast
          (Ecast
            (Ebinop Oshr (Etempvar _t'10 tuint)
              (Econst_int (Int.repr 16) tint) tuint) tshort) tshort))))
  (Ssequence
    (Ssequence
      (Sset _t'7 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'8
          (Ederef
            (Ebinop Oadd (Etempvar _t'7 (tptr tuint))
              (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
        (Sset _height
          (Ecast
            (Ecast
              (Ebinop Oand (Etempvar _t'8 tuint)
                (Econst_int (Int.repr 65535) tint) tuint) tshort) tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'5 (Evar _gCurBhvCommand (tptr tuint)))
        (Ssequence
          (Sset _t'6
            (Ederef
              (Ebinop Oadd (Etempvar _t'5 (tptr tuint))
                (Econst_int (Int.repr 2) tint) (tptr tuint)) tuint))
          (Sset _downOffset
            (Ecast
              (Ecast
                (Ebinop Oshr (Etempvar _t'6 tuint)
                  (Econst_int (Int.repr 16) tint) tuint) tshort) tshort))))
      (Ssequence
        (Ssequence
          (Sset _t'4 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Sassign
            (Efield
              (Ederef (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _hitboxRadius tfloat)
            (Etempvar _radius tshort)))
        (Ssequence
          (Ssequence
            (Sset _t'3
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Sassign
              (Efield
                (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _hitboxHeight tfloat)
              (Etempvar _height tshort)))
          (Ssequence
            (Ssequence
              (Sset _t'2
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Sassign
                (Efield
                  (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _hitboxDownOffset tfloat)
                (Etempvar _downOffset tshort)))
            (Ssequence
              (Ssequence
                (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
                (Sassign (Evar _gCurBhvCommand (tptr tuint))
                  (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
                    (Econst_int (Int.repr 3) tint) (tptr tuint))))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_bhv_cmd_nop_4 := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_field, tshort) :: (_value, tshort) :: (_t'5, tuint) ::
               (_t'4, (tptr tuint)) :: (_t'3, tuint) ::
               (_t'2, (tptr tuint)) :: (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'5
        (Ederef
          (Ebinop Oadd (Etempvar _t'4 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _field
        (Ecast
          (Ecast
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'5 tuint)
                (Econst_int (Int.repr 16) tint) tuint)
              (Econst_int (Int.repr 255) tint) tuint) tuchar) tshort))))
  (Ssequence
    (Ssequence
      (Sset _t'2 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'3
          (Ederef
            (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
              (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
        (Sset _value
          (Ecast
            (Ecast
              (Ebinop Oand (Etempvar _t'3 tuint)
                (Econst_int (Int.repr 65535) tint) tuint) tshort) tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
        (Sassign (Evar _gCurBhvCommand (tptr tuint))
          (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
            (Econst_int (Int.repr 1) tint) (tptr tuint))))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_bhv_cmd_begin := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _cur_obj_has_behavior (Tfunction ((tptr tuint) :: nil) tint
                                    cc_default))
      ((Evar _bhvHauntedChair (tarray tuint 0)) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Scall None (Evar _bhv_init_room (Tfunction nil tvoid cc_default)) nil)
      Sskip))
  (Ssequence
    (Ssequence
      (Scall (Some _t'2)
        (Evar _cur_obj_has_behavior (Tfunction ((tptr tuint) :: nil) tint
                                      cc_default))
        ((Evar _bhvMadPiano (tarray tuint 0)) :: nil))
      (Sifthenelse (Etempvar _t'2 tint)
        (Scall None (Evar _bhv_init_room (Tfunction nil tvoid cc_default))
          nil)
        Sskip))
    (Ssequence
      (Ssequence
        (Scall (Some _t'3)
          (Evar _cur_obj_has_behavior (Tfunction ((tptr tuint) :: nil) tint
                                        cc_default))
          ((Evar _bhvMessagePanel (tarray tuint 0)) :: nil))
        (Sifthenelse (Etempvar _t'3 tint)
          (Ssequence
            (Sset _t'5
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                  (Econst_int (Int.repr 67) tint) (tptr tfloat)) tfloat)
              (Econst_single (Float32.of_bits (Int.repr 1125515264)) tfloat)))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'4 (Evar _gCurBhvCommand (tptr tuint)))
          (Sassign (Evar _gCurBhvCommand (tptr tuint))
            (Ebinop Oadd (Etempvar _t'4 (tptr tuint))
              (Econst_int (Int.repr 1) tint) (tptr tuint))))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_bhv_cmd_load_collision_data := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_collisionData, (tptr tuint)) :: (_t'1, (tptr tvoid)) ::
               (_t'5, tuint) :: (_t'4, (tptr tuint)) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'4 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'5
          (Ederef
            (Ebinop Oadd (Etempvar _t'4 (tptr tuint))
              (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
        (Scall (Some _t'1)
          (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                        (tptr tvoid) cc_default))
          ((Ecast (Etempvar _t'5 tuint) (tptr tvoid)) :: nil))))
    (Sset _collisionData (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Ssequence
      (Sset _t'3 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Sassign
        (Efield
          (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
            (Tstruct _Object noattr)) _collisionData (tptr tvoid))
        (Etempvar _collisionData (tptr tuint))))
    (Ssequence
      (Ssequence
        (Sset _t'2 (Evar _gCurBhvCommand (tptr tuint)))
        (Sassign (Evar _gCurBhvCommand (tptr tuint))
          (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
            (Econst_int (Int.repr 2) tint) (tptr tuint))))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_bhv_cmd_set_home := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'10, tfloat) :: (_t'9, (tptr (Tstruct _Object noattr))) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tfloat) ::
               (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: (_t'4, tfloat) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'9 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'10
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
                _asF32 (tarray tfloat 80))
              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                (Econst_int (Int.repr 0) tint) tint) (tptr tfloat)) tfloat))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
                _asF32 (tarray tfloat 80)) (Econst_int (Int.repr 55) tint)
              (tptr tfloat)) tfloat) (Etempvar _t'10 tfloat)))))
  (Ssequence
    (Ssequence
      (Sset _t'5 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'6 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'7
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                  (Econst_int (Int.repr 1) tint) tint) (tptr tfloat)) tfloat))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                (Econst_int (Int.repr 56) tint) (tptr tfloat)) tfloat)
            (Etempvar _t'7 tfloat)))))
    (Ssequence
      (Ssequence
        (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'3 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'4
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                  (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                    (Econst_int (Int.repr 2) tint) tint) (tptr tfloat))
                tfloat))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                  (Econst_int (Int.repr 57) tint) (tptr tfloat)) tfloat)
              (Etempvar _t'4 tfloat)))))
      (Ssequence
        (Ssequence
          (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
          (Sassign (Evar _gCurBhvCommand (tptr tuint))
            (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
              (Econst_int (Int.repr 1) tint) (tptr tuint))))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_bhv_cmd_set_interact_type := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'4, tuint) :: (_t'3, (tptr tuint)) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'3 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'4
          (Ederef
            (Ebinop Oadd (Etempvar _t'3 (tptr tuint))
              (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
                _asU32 (tarray tuint 80)) (Econst_int (Int.repr 42) tint)
              (tptr tuint)) tuint) (Ecast (Etempvar _t'4 tuint) tuint)))))
  (Ssequence
    (Ssequence
      (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
      (Sassign (Evar _gCurBhvCommand (tptr tuint))
        (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
          (Econst_int (Int.repr 2) tint) (tptr tuint))))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_bhv_cmd_set_interact_subtype := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'4, tuint) :: (_t'3, (tptr tuint)) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'3 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'4
          (Ederef
            (Ebinop Oadd (Etempvar _t'3 (tptr tuint))
              (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
                _asU32 (tarray tuint 80)) (Econst_int (Int.repr 66) tint)
              (tptr tuint)) tuint) (Ecast (Etempvar _t'4 tuint) tuint)))))
  (Ssequence
    (Ssequence
      (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
      (Sassign (Evar _gCurBhvCommand (tptr tuint))
        (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
          (Econst_int (Int.repr 2) tint) (tptr tuint))))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_bhv_cmd_scale := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_unusedField, tuchar) :: (_percent, tshort) ::
               (_t'5, tuint) :: (_t'4, (tptr tuint)) :: (_t'3, tuint) ::
               (_t'2, (tptr tuint)) :: (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'5
        (Ederef
          (Ebinop Oadd (Etempvar _t'4 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _unusedField
        (Ecast
          (Ecast
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'5 tuint)
                (Econst_int (Int.repr 16) tint) tuint)
              (Econst_int (Int.repr 255) tint) tuint) tuchar) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'2 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'3
          (Ederef
            (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
              (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
        (Sset _percent
          (Ecast
            (Ecast
              (Ebinop Oand (Etempvar _t'3 tuint)
                (Econst_int (Int.repr 65535) tint) tuint) tshort) tshort))))
    (Ssequence
      (Scall None
        (Evar _cur_obj_scale (Tfunction (tfloat :: nil) tvoid cc_default))
        ((Ebinop Odiv (Etempvar _percent tshort)
           (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
           tfloat) :: nil))
      (Ssequence
        (Ssequence
          (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
          (Sassign (Evar _gCurBhvCommand (tptr tuint))
            (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
              (Econst_int (Int.repr 1) tint) (tptr tuint))))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_bhv_cmd_set_obj_physics := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_unused1, tfloat) :: (_unused2, tfloat) :: (_t'23, tuint) ::
               (_t'22, (tptr tuint)) ::
               (_t'21, (tptr (Tstruct _Object noattr))) :: (_t'20, tuint) ::
               (_t'19, (tptr tuint)) ::
               (_t'18, (tptr (Tstruct _Object noattr))) :: (_t'17, tuint) ::
               (_t'16, (tptr tuint)) ::
               (_t'15, (tptr (Tstruct _Object noattr))) :: (_t'14, tuint) ::
               (_t'13, (tptr tuint)) ::
               (_t'12, (tptr (Tstruct _Object noattr))) :: (_t'11, tuint) ::
               (_t'10, (tptr tuint)) ::
               (_t'9, (tptr (Tstruct _Object noattr))) :: (_t'8, tuint) ::
               (_t'7, (tptr tuint)) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tuint) ::
               (_t'4, (tptr tuint)) :: (_t'3, tuint) ::
               (_t'2, (tptr tuint)) :: (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'21 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'22 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'23
          (Ederef
            (Ebinop Oadd (Etempvar _t'22 (tptr tuint))
              (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'21 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
                _asF32 (tarray tfloat 80)) (Econst_int (Int.repr 40) tint)
              (tptr tfloat)) tfloat)
          (Ecast
            (Ebinop Oshr (Etempvar _t'23 tuint)
              (Econst_int (Int.repr 16) tint) tuint) tshort)))))
  (Ssequence
    (Ssequence
      (Sset _t'18 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'19 (Evar _gCurBhvCommand (tptr tuint)))
        (Ssequence
          (Sset _t'20
            (Ederef
              (Ebinop Oadd (Etempvar _t'19 (tptr tuint))
                (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'18 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                (Econst_int (Int.repr 23) tint) (tptr tfloat)) tfloat)
            (Ebinop Odiv
              (Ecast
                (Ebinop Oand (Etempvar _t'20 tuint)
                  (Econst_int (Int.repr 65535) tint) tuint) tshort)
              (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
              tfloat)))))
    (Ssequence
      (Ssequence
        (Sset _t'15 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'16 (Evar _gCurBhvCommand (tptr tuint)))
          (Ssequence
            (Sset _t'17
              (Ederef
                (Ebinop Oadd (Etempvar _t'16 (tptr tuint))
                  (Econst_int (Int.repr 2) tint) (tptr tuint)) tuint))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _t'15 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                  (Econst_int (Int.repr 52) tint) (tptr tfloat)) tfloat)
              (Ebinop Odiv
                (Ecast
                  (Ebinop Oshr (Etempvar _t'17 tuint)
                    (Econst_int (Int.repr 16) tint) tuint) tshort)
                (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                tfloat)))))
      (Ssequence
        (Ssequence
          (Sset _t'12 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'13 (Evar _gCurBhvCommand (tptr tuint)))
            (Ssequence
              (Sset _t'14
                (Ederef
                  (Ebinop Oadd (Etempvar _t'13 (tptr tuint))
                    (Econst_int (Int.repr 2) tint) (tptr tuint)) tuint))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'12 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                    (Econst_int (Int.repr 41) tint) (tptr tfloat)) tfloat)
                (Ebinop Odiv
                  (Ecast
                    (Ebinop Oand (Etempvar _t'14 tuint)
                      (Econst_int (Int.repr 65535) tint) tuint) tshort)
                  (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                  tfloat)))))
        (Ssequence
          (Ssequence
            (Sset _t'9
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'10 (Evar _gCurBhvCommand (tptr tuint)))
              (Ssequence
                (Sset _t'11
                  (Ederef
                    (Ebinop Oadd (Etempvar _t'10 (tptr tuint))
                      (Econst_int (Int.repr 3) tint) (tptr tuint)) tuint))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                      (Econst_int (Int.repr 58) tint) (tptr tfloat)) tfloat)
                  (Ebinop Odiv
                    (Ecast
                      (Ebinop Oshr (Etempvar _t'11 tuint)
                        (Econst_int (Int.repr 16) tint) tuint) tshort)
                    (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                    tfloat)))))
          (Ssequence
            (Ssequence
              (Sset _t'6
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'7 (Evar _gCurBhvCommand (tptr tuint)))
                (Ssequence
                  (Sset _t'8
                    (Ederef
                      (Ebinop Oadd (Etempvar _t'7 (tptr tuint))
                        (Econst_int (Int.repr 3) tint) (tptr tuint)) tuint))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                        (Econst_int (Int.repr 59) tint) (tptr tfloat))
                      tfloat)
                    (Ebinop Odiv
                      (Ecast
                        (Ebinop Oand (Etempvar _t'8 tuint)
                          (Econst_int (Int.repr 65535) tint) tuint) tshort)
                      (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                      tfloat)))))
            (Ssequence
              (Ssequence
                (Sset _t'4 (Evar _gCurBhvCommand (tptr tuint)))
                (Ssequence
                  (Sset _t'5
                    (Ederef
                      (Ebinop Oadd (Etempvar _t'4 (tptr tuint))
                        (Econst_int (Int.repr 4) tint) (tptr tuint)) tuint))
                  (Sset _unused1
                    (Ebinop Odiv
                      (Ecast
                        (Ebinop Oshr (Etempvar _t'5 tuint)
                          (Econst_int (Int.repr 16) tint) tuint) tshort)
                      (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                      tfloat))))
              (Ssequence
                (Ssequence
                  (Sset _t'2 (Evar _gCurBhvCommand (tptr tuint)))
                  (Ssequence
                    (Sset _t'3
                      (Ederef
                        (Ebinop Oadd (Etempvar _t'2 (tptr tuint))
                          (Econst_int (Int.repr 4) tint) (tptr tuint)) tuint))
                    (Sset _unused2
                      (Ebinop Odiv
                        (Ecast
                          (Ebinop Oand (Etempvar _t'3 tuint)
                            (Econst_int (Int.repr 65535) tint) tuint) tshort)
                        (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                        tfloat))))
                (Ssequence
                  (Ssequence
                    (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
                    (Sassign (Evar _gCurBhvCommand (tptr tuint))
                      (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
                        (Econst_int (Int.repr 5) tint) (tptr tuint))))
                  (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))
|}.

Definition f_bhv_cmd_parent_bit_clear := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_field, tuchar) :: (_value, tint) :: (_t'10, tuint) ::
               (_t'9, (tptr tuint)) :: (_t'8, tuint) ::
               (_t'7, (tptr tuint)) :: (_t'6, tint) ::
               (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'10
        (Ederef
          (Ebinop Oadd (Etempvar _t'9 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _field
        (Ecast
          (Ecast
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'10 tuint)
                (Econst_int (Int.repr 16) tint) tuint)
              (Econst_int (Int.repr 255) tint) tuint) tuchar) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'7 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'8
          (Ederef
            (Ebinop Oadd (Etempvar _t'7 (tptr tuint))
              (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
        (Sset _value (Ecast (Etempvar _t'8 tuint) tuint))))
    (Ssequence
      (Sset _value
        (Ebinop Oxor (Etempvar _value tint)
          (Econst_int (Int.repr (-1)) tuint) tuint))
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'3
              (Efield
                (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _parentObj
                (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'4
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _parentObj
                    (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'6
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __764 noattr)) _asS32 (tarray tint 80))
                        (Etempvar _field tuchar) (tptr tint)) tint))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __764 noattr)) _asS32 (tarray tint 80))
                        (Etempvar _field tuchar) (tptr tint)) tint)
                    (Ebinop Oand (Etempvar _t'6 tint)
                      (Ecast (Etempvar _value tint) tint) tint)))))))
        (Ssequence
          (Ssequence
            (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
            (Sassign (Evar _gCurBhvCommand (tptr tuint))
              (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
                (Econst_int (Int.repr 2) tint) (tptr tuint))))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_bhv_cmd_spawn_water_droplet := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_dropletParams, (tptr (Tstruct _WaterDropletParams noattr))) ::
               (_t'4, tuint) :: (_t'3, (tptr tuint)) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'4
        (Ederef
          (Ebinop Oadd (Etempvar _t'3 (tptr tuint))
            (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint))
      (Sset _dropletParams (Ecast (Etempvar _t'4 tuint) (tptr tvoid)))))
  (Ssequence
    (Ssequence
      (Sset _t'2 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
      (Scall None
        (Evar _spawn_water_droplet (Tfunction
                                     ((tptr (Tstruct _Object noattr)) ::
                                      (tptr (Tstruct _WaterDropletParams noattr)) ::
                                      nil) (tptr (Tstruct _Object noattr))
                                     cc_default))
        ((Etempvar _t'2 (tptr (Tstruct _Object noattr))) ::
         (Etempvar _dropletParams (tptr (Tstruct _WaterDropletParams noattr))) ::
         nil)))
    (Ssequence
      (Ssequence
        (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
        (Sassign (Evar _gCurBhvCommand (tptr tuint))
          (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
            (Econst_int (Int.repr 2) tint) (tptr tuint))))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_bhv_cmd_animate_texture := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_field, tuchar) :: (_rate, tshort) :: (_t'9, tuint) ::
               (_t'8, (tptr tuint)) :: (_t'7, tuint) ::
               (_t'6, (tptr tuint)) :: (_t'5, tint) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: (_t'2, tuint) ::
               (_t'1, (tptr tuint)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8 (Evar _gCurBhvCommand (tptr tuint)))
    (Ssequence
      (Sset _t'9
        (Ederef
          (Ebinop Oadd (Etempvar _t'8 (tptr tuint))
            (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
      (Sset _field
        (Ecast
          (Ecast
            (Ebinop Oand
              (Ebinop Oshr (Etempvar _t'9 tuint)
                (Econst_int (Int.repr 16) tint) tuint)
              (Econst_int (Int.repr 255) tint) tuint) tuchar) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _t'6 (Evar _gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset _t'7
          (Ederef
            (Ebinop Oadd (Etempvar _t'6 (tptr tuint))
              (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint))
        (Sset _rate
          (Ecast
            (Ecast
              (Ebinop Oand (Etempvar _t'7 tuint)
                (Econst_int (Int.repr 65535) tint) tuint) tshort) tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'2 (Evar _gGlobalTimer tuint))
        (Sifthenelse (Ebinop Oeq
                       (Ebinop Omod (Etempvar _t'2 tuint)
                         (Etempvar _rate tshort) tuint)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Sset _t'3
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'4
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'5
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __764 noattr)) _asS32 (tarray tint 80))
                      (Etempvar _field tuchar) (tptr tint)) tint))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __764 noattr)) _asS32 (tarray tint 80))
                      (Etempvar _field tuchar) (tptr tint)) tint)
                  (Ebinop Oadd (Etempvar _t'5 tint)
                    (Ecast (Econst_int (Int.repr 1) tint) tint) tint)))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'1 (Evar _gCurBhvCommand (tptr tuint)))
          (Sassign (Evar _gCurBhvCommand (tptr tuint))
            (Ebinop Oadd (Etempvar _t'1 (tptr tuint))
              (Econst_int (Int.repr 1) tint) (tptr tuint))))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_stub_behavior_script_2 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
Sskip
|}.

Definition v_BehaviorCmdTable := {|
  gvar_info := (tarray (tptr (Tfunction nil tint cc_default)) 56);
  gvar_init := (Init_addrof _bhv_cmd_begin (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_delay (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_call (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_return (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_goto (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_begin_repeat (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_end_repeat (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_end_repeat_continue (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_begin_loop (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_end_loop (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_break (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_break_unused (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_call_native (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_add_float (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_set_float (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_add_int (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_set_int (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_or_int (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_bit_clear (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_set_int_rand_rshift (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_set_random_float (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_set_random_int (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_add_random_float (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_add_int_rand_rshift (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_nop_1 (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_nop_2 (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_nop_3 (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_set_model (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_spawn_child (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_deactivate (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_drop_to_floor (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_sum_float (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_sum_int (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_billboard (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_hide (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_set_hitbox (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_nop_4 (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_delay_var (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_begin_repeat_unused (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_load_animations (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_animate (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_spawn_child_with_param (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_load_collision_data (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_set_hitbox_with_offset (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_spawn_obj (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_set_home (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_set_hurtbox (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_set_interact_type (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_set_obj_physics (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_set_interact_subtype (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_scale (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_parent_bit_clear (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_animate_texture (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_disable_rendering (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_set_int_unused (Ptrofs.repr 0) ::
                Init_addrof _bhv_cmd_spawn_water_droplet (Ptrofs.repr 0) ::
                nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_cur_obj_update := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_filler, (tarray tuchar 4)) :: nil);
  fn_temps := ((_objFlags, tshort) :: (_distanceFromMario, tfloat) ::
               (_bhvCmdProc, (tptr (Tfunction nil tint cc_default))) ::
               (_bhvProcResult, tint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tshort) :: (_t'1, tfloat) :: (_t'71, tuint) ::
               (_t'70, (tptr (Tstruct _Object noattr))) ::
               (_t'69, (tptr (Tstruct _Object noattr))) ::
               (_t'68, (tptr (Tstruct _Object noattr))) ::
               (_t'67, (tptr (Tstruct _Object noattr))) ::
               (_t'66, (tptr (Tstruct _Object noattr))) ::
               (_t'65, (tptr (Tstruct _Object noattr))) ::
               (_t'64, (tptr (Tstruct _Object noattr))) ::
               (_t'63, (tptr (Tstruct _Object noattr))) ::
               (_t'62, (tptr (Tstruct _Object noattr))) ::
               (_t'61, (tptr (Tstruct _Object noattr))) :: (_t'60, tint) ::
               (_t'59, (tptr (Tstruct _Object noattr))) ::
               (_t'58, (tptr (Tstruct _Object noattr))) :: (_t'57, tint) ::
               (_t'56, (tptr (Tstruct _Object noattr))) :: (_t'55, tint) ::
               (_t'54, (tptr (Tstruct _Object noattr))) ::
               (_t'53, (tptr tuint)) ::
               (_t'52, (tptr (Tstruct _Object noattr))) :: (_t'51, tuint) ::
               (_t'50, (tptr tuint)) :: (_t'49, (tptr tuint)) ::
               (_t'48, (tptr (Tstruct _Object noattr))) :: (_t'47, tint) ::
               (_t'46, (tptr (Tstruct _Object noattr))) ::
               (_t'45, (tptr (Tstruct _Object noattr))) :: (_t'44, tint) ::
               (_t'43, (tptr (Tstruct _Object noattr))) ::
               (_t'42, (tptr (Tstruct _Object noattr))) ::
               (_t'41, (tptr (Tstruct _Object noattr))) :: (_t'40, tint) ::
               (_t'39, (tptr (Tstruct _Object noattr))) ::
               (_t'38, (tptr (Tstruct _Object noattr))) :: (_t'37, tint) ::
               (_t'36, (tptr (Tstruct _Object noattr))) :: (_t'35, tint) ::
               (_t'34, (tptr (Tstruct _Object noattr))) :: (_t'33, tuint) ::
               (_t'32, (tptr (Tstruct _Object noattr))) ::
               (_t'31, (tptr (Tstruct _Object noattr))) :: (_t'30, tint) ::
               (_t'29, (tptr (Tstruct _Object noattr))) ::
               (_t'28, (tptr (Tstruct _Object noattr))) ::
               (_t'27, (tptr (Tstruct _Object noattr))) ::
               (_t'26, (tptr (Tstruct _Object noattr))) ::
               (_t'25, (tptr (Tstruct _Object noattr))) ::
               (_t'24, (tptr tvoid)) ::
               (_t'23, (tptr (Tstruct _Object noattr))) :: (_t'22, tshort) ::
               (_t'21, (tptr (Tstruct _Object noattr))) ::
               (_t'20, (tptr (Tstruct _Object noattr))) :: (_t'19, tshort) ::
               (_t'18, (tptr (Tstruct _Object noattr))) ::
               (_t'17, (tptr (Tstruct _Object noattr))) :: (_t'16, tshort) ::
               (_t'15, (tptr (Tstruct _Object noattr))) ::
               (_t'14, (tptr (Tstruct _Object noattr))) :: (_t'13, tshort) ::
               (_t'12, (tptr (Tstruct _Object noattr))) ::
               (_t'11, (tptr (Tstruct _Object noattr))) :: (_t'10, tuint) ::
               (_t'9, (tptr (Tstruct _Object noattr))) :: (_t'8, tfloat) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tint) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'70 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'71
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'70 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
              _asU32 (tarray tuint 80)) (Econst_int (Int.repr 1) tint)
            (tptr tuint)) tuint))
      (Sset _objFlags (Ecast (Etempvar _t'71 tuint) tshort))))
  (Ssequence
    (Sifthenelse (Ebinop Oand (Etempvar _objFlags tshort)
                   (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                     (Econst_int (Int.repr 6) tint) tint) tint)
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'68
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'69
                (Evar _gMarioObject (tptr (Tstruct _Object noattr))))
              (Scall (Some _t'1)
                (Evar _dist_between_objects (Tfunction
                                              ((tptr (Tstruct _Object noattr)) ::
                                               (tptr (Tstruct _Object noattr)) ::
                                               nil) tfloat cc_default))
                ((Etempvar _t'68 (tptr (Tstruct _Object noattr))) ::
                 (Etempvar _t'69 (tptr (Tstruct _Object noattr))) :: nil))))
          (Ssequence
            (Sset _t'67
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _t'67 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                  (Econst_int (Int.repr 53) tint) (tptr tfloat)) tfloat)
              (Etempvar _t'1 tfloat))))
        (Ssequence
          (Sset _t'66 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Sset _distanceFromMario
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'66 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                (Econst_int (Int.repr 53) tint) (tptr tfloat)) tfloat))))
      (Sset _distanceFromMario
        (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)))
    (Ssequence
      (Sifthenelse (Ebinop Oand (Etempvar _objFlags tshort)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 13) tint) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'64
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'65
                (Evar _gMarioObject (tptr (Tstruct _Object noattr))))
              (Scall (Some _t'2)
                (Evar _obj_angle_to_object (Tfunction
                                             ((tptr (Tstruct _Object noattr)) ::
                                              (tptr (Tstruct _Object noattr)) ::
                                              nil) tshort cc_default))
                ((Etempvar _t'64 (tptr (Tstruct _Object noattr))) ::
                 (Etempvar _t'65 (tptr (Tstruct _Object noattr))) :: nil))))
          (Ssequence
            (Sset _t'63
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _t'63 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __764 noattr)) _asS32 (tarray tint 80))
                  (Econst_int (Int.repr 54) tint) (tptr tint)) tint)
              (Etempvar _t'2 tshort))))
        Sskip)
      (Ssequence
        (Ssequence
          (Sset _t'54 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'55
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _t'54 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __764 noattr)) _asS32 (tarray tint 80))
                  (Econst_int (Int.repr 49) tint) (tptr tint)) tint))
            (Ssequence
              (Sset _t'56
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'57
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'56 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __764 noattr)) _asS32 (tarray tint 80))
                      (Econst_int (Int.repr 65) tint) (tptr tint)) tint))
                (Sifthenelse (Ebinop One (Etempvar _t'55 tint)
                               (Etempvar _t'57 tint) tint)
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'62
                          (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'62 (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __764 noattr)) _asS32
                                (tarray tint 80))
                              (Econst_int (Int.repr 51) tint) (tptr tint))
                            tint) (Econst_int (Int.repr 0) tint)))
                      (Ssequence
                        (Sset _t'61
                          (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'61 (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __764 noattr)) _asS32
                                (tarray tint 80))
                              (Econst_int (Int.repr 50) tint) (tptr tint))
                            tint) (Econst_int (Int.repr 0) tint))))
                    (Ssequence
                      (Sset _t'58
                        (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                      (Ssequence
                        (Sset _t'59
                          (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                        (Ssequence
                          (Sset _t'60
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'59 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __764 noattr)) _asS32
                                  (tarray tint 80))
                                (Econst_int (Int.repr 49) tint) (tptr tint))
                              tint))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'58 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __764 noattr)) _asS32
                                  (tarray tint 80))
                                (Econst_int (Int.repr 65) tint) (tptr tint))
                              tint) (Etempvar _t'60 tint))))))
                  Sskip)))))
        (Ssequence
          (Ssequence
            (Sset _t'52
              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'53
                (Efield
                  (Ederef (Etempvar _t'52 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _curBhvCommand (tptr tuint)))
              (Sassign (Evar _gCurBhvCommand (tptr tuint))
                (Etempvar _t'53 (tptr tuint)))))
          (Ssequence
            (Sloop
              (Ssequence
                (Ssequence
                  (Sset _t'50 (Evar _gCurBhvCommand (tptr tuint)))
                  (Ssequence
                    (Sset _t'51 (Ederef (Etempvar _t'50 (tptr tuint)) tuint))
                    (Sset _bhvCmdProc
                      (Ederef
                        (Ebinop Oadd
                          (Evar _BehaviorCmdTable (tarray (tptr (Tfunction
                                                                  nil tint
                                                                  cc_default)) 56))
                          (Ebinop Oshr (Etempvar _t'51 tuint)
                            (Econst_int (Int.repr 24) tint) tuint)
                          (tptr (tptr (Tfunction nil tint cc_default))))
                        (tptr (Tfunction nil tint cc_default))))))
                (Ssequence
                  (Scall (Some _t'3)
                    (Etempvar _bhvCmdProc (tptr (Tfunction nil tint
                                                  cc_default))) nil)
                  (Sset _bhvProcResult (Etempvar _t'3 tint))))
              (Sifthenelse (Ebinop Oeq (Etempvar _bhvProcResult tint)
                             (Econst_int (Int.repr 0) tint) tint)
                Sskip
                Sbreak))
            (Ssequence
              (Ssequence
                (Sset _t'48
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'49 (Evar _gCurBhvCommand (tptr tuint)))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _t'48 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _curBhvCommand
                      (tptr tuint)) (Etempvar _t'49 (tptr tuint)))))
              (Ssequence
                (Ssequence
                  (Sset _t'43
                    (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sset _t'44
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'43 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __764 noattr)) _asS32 (tarray tint 80))
                          (Econst_int (Int.repr 51) tint) (tptr tint)) tint))
                    (Sifthenelse (Ebinop Olt (Etempvar _t'44 tint)
                                   (Econst_int (Int.repr 1073741823) tint)
                                   tint)
                      (Ssequence
                        (Sset _t'45
                          (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                        (Ssequence
                          (Sset _t'46
                            (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                          (Ssequence
                            (Sset _t'47
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'46 (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _rawData
                                      (Tunion __764 noattr)) _asS32
                                    (tarray tint 80))
                                  (Econst_int (Int.repr 51) tint)
                                  (tptr tint)) tint))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'45 (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _rawData
                                      (Tunion __764 noattr)) _asS32
                                    (tarray tint 80))
                                  (Econst_int (Int.repr 51) tint)
                                  (tptr tint)) tint)
                              (Ebinop Oadd (Etempvar _t'47 tint)
                                (Econst_int (Int.repr 1) tint) tint)))))
                      Sskip)))
                (Ssequence
                  (Ssequence
                    (Sset _t'34
                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sset _t'35
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'34 (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _rawData
                                (Tunion __764 noattr)) _asS32
                              (tarray tint 80))
                            (Econst_int (Int.repr 49) tint) (tptr tint))
                          tint))
                      (Ssequence
                        (Sset _t'36
                          (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                        (Ssequence
                          (Sset _t'37
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'36 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __764 noattr)) _asS32
                                  (tarray tint 80))
                                (Econst_int (Int.repr 65) tint) (tptr tint))
                              tint))
                          (Sifthenelse (Ebinop One (Etempvar _t'35 tint)
                                         (Etempvar _t'37 tint) tint)
                            (Ssequence
                              (Ssequence
                                (Ssequence
                                  (Sset _t'42
                                    (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                  (Sassign
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'42 (tptr (Tstruct _Object noattr)))
                                              (Tstruct _Object noattr))
                                            _rawData (Tunion __764 noattr))
                                          _asS32 (tarray tint 80))
                                        (Econst_int (Int.repr 51) tint)
                                        (tptr tint)) tint)
                                    (Econst_int (Int.repr 0) tint)))
                                (Ssequence
                                  (Sset _t'41
                                    (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                  (Sassign
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'41 (tptr (Tstruct _Object noattr)))
                                              (Tstruct _Object noattr))
                                            _rawData (Tunion __764 noattr))
                                          _asS32 (tarray tint 80))
                                        (Econst_int (Int.repr 50) tint)
                                        (tptr tint)) tint)
                                    (Econst_int (Int.repr 0) tint))))
                              (Ssequence
                                (Sset _t'38
                                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                (Ssequence
                                  (Sset _t'39
                                    (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                  (Ssequence
                                    (Sset _t'40
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'39 (tptr (Tstruct _Object noattr)))
                                                (Tstruct _Object noattr))
                                              _rawData (Tunion __764 noattr))
                                            _asS32 (tarray tint 80))
                                          (Econst_int (Int.repr 49) tint)
                                          (tptr tint)) tint))
                                    (Sassign
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'38 (tptr (Tstruct _Object noattr)))
                                                (Tstruct _Object noattr))
                                              _rawData (Tunion __764 noattr))
                                            _asS32 (tarray tint 80))
                                          (Econst_int (Int.repr 65) tint)
                                          (tptr tint)) tint)
                                      (Etempvar _t'40 tint))))))
                            Sskip)))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'32
                        (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                      (Ssequence
                        (Sset _t'33
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'32 (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __764 noattr)) _asU32
                                (tarray tuint 80))
                              (Econst_int (Int.repr 1) tint) (tptr tuint))
                            tuint))
                        (Sset _objFlags
                          (Ecast (Ecast (Etempvar _t'33 tuint) tshort)
                            tshort))))
                    (Ssequence
                      (Sifthenelse (Ebinop Oand (Etempvar _objFlags tshort)
                                     (Ebinop Oshl
                                       (Econst_int (Int.repr 1) tint)
                                       (Econst_int (Int.repr 4) tint) tint)
                                     tint)
                        (Ssequence
                          (Sset _t'31
                            (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                          (Scall None
                            (Evar _obj_set_face_angle_to_move_angle (Tfunction
                                                                    ((tptr (Tstruct _Object noattr)) ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                            ((Etempvar _t'31 (tptr (Tstruct _Object noattr))) ::
                             nil)))
                        Sskip)
                      (Ssequence
                        (Sifthenelse (Ebinop Oand (Etempvar _objFlags tshort)
                                       (Ebinop Oshl
                                         (Econst_int (Int.repr 1) tint)
                                         (Econst_int (Int.repr 3) tint) tint)
                                       tint)
                          (Ssequence
                            (Sset _t'28
                              (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                            (Ssequence
                              (Sset _t'29
                                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                              (Ssequence
                                (Sset _t'30
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'29 (tptr (Tstruct _Object noattr)))
                                            (Tstruct _Object noattr))
                                          _rawData (Tunion __764 noattr))
                                        _asS32 (tarray tint 80))
                                      (Ebinop Oadd
                                        (Econst_int (Int.repr 15) tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      (tptr tint)) tint))
                                (Sassign
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'28 (tptr (Tstruct _Object noattr)))
                                            (Tstruct _Object noattr))
                                          _rawData (Tunion __764 noattr))
                                        _asS32 (tarray tint 80))
                                      (Ebinop Oadd
                                        (Econst_int (Int.repr 18) tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      (tptr tint)) tint)
                                  (Etempvar _t'30 tint)))))
                          Sskip)
                        (Ssequence
                          (Sifthenelse (Ebinop Oand
                                         (Etempvar _objFlags tshort)
                                         (Ebinop Oshl
                                           (Econst_int (Int.repr 1) tint)
                                           (Econst_int (Int.repr 1) tint)
                                           tint) tint)
                            (Scall None
                              (Evar _cur_obj_move_xz_using_fvel_and_yaw 
                              (Tfunction nil tvoid cc_default)) nil)
                            Sskip)
                          (Ssequence
                            (Sifthenelse (Ebinop Oand
                                           (Etempvar _objFlags tshort)
                                           (Ebinop Oshl
                                             (Econst_int (Int.repr 1) tint)
                                             (Econst_int (Int.repr 2) tint)
                                             tint) tint)
                              (Scall None
                                (Evar _cur_obj_move_y_with_terminal_vel 
                                (Tfunction nil tvoid cc_default)) nil)
                              Sskip)
                            (Ssequence
                              (Sifthenelse (Ebinop Oand
                                             (Etempvar _objFlags tshort)
                                             (Ebinop Oshl
                                               (Econst_int (Int.repr 1) tint)
                                               (Econst_int (Int.repr 9) tint)
                                               tint) tint)
                                (Ssequence
                                  (Sset _t'27
                                    (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                  (Scall None
                                    (Evar _obj_build_transform_relative_to_parent 
                                    (Tfunction
                                      ((tptr (Tstruct _Object noattr)) ::
                                       nil) tvoid cc_default))
                                    ((Etempvar _t'27 (tptr (Tstruct _Object noattr))) ::
                                     nil)))
                                Sskip)
                              (Ssequence
                                (Sifthenelse (Ebinop Oand
                                               (Etempvar _objFlags tshort)
                                               (Ebinop Oshl
                                                 (Econst_int (Int.repr 1) tint)
                                                 (Econst_int (Int.repr 11) tint)
                                                 tint) tint)
                                  (Ssequence
                                    (Sset _t'26
                                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                    (Scall None
                                      (Evar _obj_set_throw_matrix_from_transform 
                                      (Tfunction
                                        ((tptr (Tstruct _Object noattr)) ::
                                         nil) tvoid cc_default))
                                      ((Etempvar _t'26 (tptr (Tstruct _Object noattr))) ::
                                       nil)))
                                  Sskip)
                                (Ssequence
                                  (Sifthenelse (Ebinop Oand
                                                 (Etempvar _objFlags tshort)
                                                 (Ebinop Oshl
                                                   (Econst_int (Int.repr 1) tint)
                                                   (Econst_int (Int.repr 0) tint)
                                                   tint) tint)
                                    (Ssequence
                                      (Sset _t'25
                                        (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                      (Scall None
                                        (Evar _obj_update_gfx_pos_and_angle 
                                        (Tfunction
                                          ((tptr (Tstruct _Object noattr)) ::
                                           nil) tvoid cc_default))
                                        ((Etempvar _t'25 (tptr (Tstruct _Object noattr))) ::
                                         nil)))
                                    Sskip)
                                  (Ssequence
                                    (Sset _t'5
                                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                    (Ssequence
                                      (Sset _t'6
                                        (Ederef
                                          (Ebinop Oadd
                                            (Efield
                                              (Efield
                                                (Ederef
                                                  (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                                                  (Tstruct _Object noattr))
                                                _rawData
                                                (Tunion __764 noattr)) _asS32
                                              (tarray tint 80))
                                            (Econst_int (Int.repr 70) tint)
                                            (tptr tint)) tint))
                                      (Sifthenelse (Ebinop One
                                                     (Etempvar _t'6 tint)
                                                     (Eunop Oneg
                                                       (Econst_int (Int.repr 1) tint)
                                                       tint) tint)
                                        (Scall None
                                          (Evar _cur_obj_enable_rendering_if_mario_in_room 
                                          (Tfunction nil tvoid cc_default))
                                          nil)
                                        (Ssequence
                                          (Sifthenelse (Ebinop Oand
                                                         (Etempvar _objFlags tshort)
                                                         (Ebinop Oshl
                                                           (Econst_int (Int.repr 1) tint)
                                                           (Econst_int (Int.repr 6) tint)
                                                           tint) tint)
                                            (Ssequence
                                              (Sset _t'23
                                                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                              (Ssequence
                                                (Sset _t'24
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _t'23 (tptr (Tstruct _Object noattr)))
                                                      (Tstruct _Object noattr))
                                                    _collisionData
                                                    (tptr tvoid)))
                                                (Sset _t'4
                                                  (Ecast
                                                    (Ebinop Oeq
                                                      (Etempvar _t'24 (tptr tvoid))
                                                      (Ecast
                                                        (Econst_int (Int.repr 0) tint)
                                                        (tptr tvoid)) tint)
                                                    tbool))))
                                            (Sset _t'4
                                              (Econst_int (Int.repr 0) tint)))
                                          (Sifthenelse (Etempvar _t'4 tint)
                                            (Sifthenelse (Eunop Onotbool
                                                           (Ebinop Oand
                                                             (Etempvar _objFlags tshort)
                                                             (Ebinop Oshl
                                                               (Econst_int (Int.repr 1) tint)
                                                               (Econst_int (Int.repr 7) tint)
                                                               tint) tint)
                                                           tint)
                                              (Ssequence
                                                (Sset _t'7
                                                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                                (Ssequence
                                                  (Sset _t'8
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Efield
                                                          (Efield
                                                            (Ederef
                                                              (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                                                              (Tstruct _Object noattr))
                                                            _rawData
                                                            (Tunion __764 noattr))
                                                          _asF32
                                                          (tarray tfloat 80))
                                                        (Econst_int (Int.repr 69) tint)
                                                        (tptr tfloat))
                                                      tfloat))
                                                  (Sifthenelse (Ebinop Ogt
                                                                 (Etempvar _distanceFromMario tfloat)
                                                                 (Etempvar _t'8 tfloat)
                                                                 tint)
                                                    (Ssequence
                                                      (Ssequence
                                                        (Sset _t'20
                                                          (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                                        (Ssequence
                                                          (Sset _t'21
                                                            (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                                          (Ssequence
                                                            (Sset _t'22
                                                              (Efield
                                                                (Efield
                                                                  (Efield
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'21 (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _header
                                                                    (Tstruct _ObjectNode noattr))
                                                                    _gfx
                                                                    (Tstruct _GraphNodeObject noattr))
                                                                  _node
                                                                  (Tstruct _GraphNode noattr))
                                                                _flags
                                                                tshort))
                                                            (Sassign
                                                              (Efield
                                                                (Efield
                                                                  (Efield
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'20 (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _header
                                                                    (Tstruct _ObjectNode noattr))
                                                                    _gfx
                                                                    (Tstruct _GraphNodeObject noattr))
                                                                  _node
                                                                  (Tstruct _GraphNode noattr))
                                                                _flags
                                                                tshort)
                                                              (Ebinop Oand
                                                                (Etempvar _t'22 tshort)
                                                                (Eunop Onotint
                                                                  (Ebinop Oshl
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tint)
                                                                  tint) tint)))))
                                                      (Ssequence
                                                        (Sset _t'17
                                                          (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                                        (Ssequence
                                                          (Sset _t'18
                                                            (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                                          (Ssequence
                                                            (Sset _t'19
                                                              (Efield
                                                                (Ederef
                                                                  (Etempvar _t'18 (tptr (Tstruct _Object noattr)))
                                                                  (Tstruct _Object noattr))
                                                                _activeFlags
                                                                tshort))
                                                            (Sassign
                                                              (Efield
                                                                (Ederef
                                                                  (Etempvar _t'17 (tptr (Tstruct _Object noattr)))
                                                                  (Tstruct _Object noattr))
                                                                _activeFlags
                                                                tshort)
                                                              (Ebinop Oor
                                                                (Etempvar _t'19 tshort)
                                                                (Ebinop Oshl
                                                                  (Econst_int (Int.repr 1) tint)
                                                                  (Econst_int (Int.repr 1) tint)
                                                                  tint) tint))))))
                                                    (Ssequence
                                                      (Sset _t'9
                                                        (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                                      (Ssequence
                                                        (Sset _t'10
                                                          (Ederef
                                                            (Ebinop Oadd
                                                              (Efield
                                                                (Efield
                                                                  (Ederef
                                                                    (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                  _rawData
                                                                  (Tunion __764 noattr))
                                                                _asU32
                                                                (tarray tuint 80))
                                                              (Econst_int (Int.repr 39) tint)
                                                              (tptr tuint))
                                                            tuint))
                                                        (Sifthenelse 
                                                          (Ebinop Oeq
                                                            (Etempvar _t'10 tuint)
                                                            (Econst_int (Int.repr 0) tint)
                                                            tint)
                                                          (Ssequence
                                                            (Ssequence
                                                              (Sset _t'14
                                                                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                                              (Ssequence
                                                                (Sset _t'15
                                                                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                                                (Ssequence
                                                                  (Sset _t'16
                                                                    (Efield
                                                                    (Efield
                                                                    (Efield
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'15 (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _header
                                                                    (Tstruct _ObjectNode noattr))
                                                                    _gfx
                                                                    (Tstruct _GraphNodeObject noattr))
                                                                    _node
                                                                    (Tstruct _GraphNode noattr))
                                                                    _flags
                                                                    tshort))
                                                                  (Sassign
                                                                    (Efield
                                                                    (Efield
                                                                    (Efield
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'14 (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _header
                                                                    (Tstruct _ObjectNode noattr))
                                                                    _gfx
                                                                    (Tstruct _GraphNodeObject noattr))
                                                                    _node
                                                                    (Tstruct _GraphNode noattr))
                                                                    _flags
                                                                    tshort)
                                                                    (Ebinop Oor
                                                                    (Etempvar _t'16 tshort)
                                                                    (Ebinop Oshl
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tint)
                                                                    tint)))))
                                                            (Ssequence
                                                              (Sset _t'11
                                                                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                                              (Ssequence
                                                                (Sset _t'12
                                                                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                                                                (Ssequence
                                                                  (Sset _t'13
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'12 (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _activeFlags
                                                                    tshort))
                                                                  (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'11 (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _activeFlags
                                                                    tshort)
                                                                    (Ebinop Oand
                                                                    (Etempvar _t'13 tshort)
                                                                    (Eunop Onotint
                                                                    (Ebinop Oshl
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    tint)
                                                                    tint))))))
                                                          Sskip))))))
                                              Sskip)
                                            Sskip))))))))))))))))))))))
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
 Composite _SpawnInfo Struct
   (Member_plain _startPos (tarray tshort 3) ::
    Member_plain _startAngle (tarray tshort 3) ::
    Member_plain _areaIndex tschar :: Member_plain _activeAreaIndex tschar ::
    Member_plain _behaviorArg tuint ::
    Member_plain _behaviorScript (tptr tvoid) ::
    Member_plain _model (tptr (Tstruct _GraphNode noattr)) ::
    Member_plain _next (tptr (Tstruct _SpawnInfo noattr)) :: nil)
   noattr ::
 Composite _ChainSegment Struct
   (Member_plain _posX tfloat :: Member_plain _posY tfloat ::
    Member_plain _posZ tfloat :: Member_plain _pitch tshort ::
    Member_plain _yaw tshort :: Member_plain _roll tshort :: nil)
   noattr ::
 Composite _WaterDropletParams Struct
   (Member_plain _flags tshort :: Member_plain _model tshort ::
    Member_plain _behavior (tptr tuint) ::
    Member_plain _moveAngleRange tshort :: Member_plain _moveRange tshort ::
    Member_plain _randForwardVelOffset tfloat ::
    Member_plain _randForwardVelScale tfloat ::
    Member_plain _randYVelOffset tfloat ::
    Member_plain _randYVelScale tfloat ::
    Member_plain _randSizeOffset tfloat ::
    Member_plain _randSizeScale tfloat :: nil)
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
 (_bhvMessagePanel, Gvar v_bhvMessagePanel) ::
 (_bhvHauntedChair, Gvar v_bhvHauntedChair) ::
 (_bhvMadPiano, Gvar v_bhvMadPiano) ::
 (_segmented_to_virtual,
   Gfun(External (EF_external "segmented_to_virtual"
                   (mksignature (AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr tvoid) :: nil) (tptr tvoid) cc_default)) ::
 (_geo_obj_init_animation,
   Gfun(External (EF_external "geo_obj_init_animation"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _GraphNodeObject noattr)) ::
      (tptr (tptr (Tstruct _Animation noattr))) :: nil) tvoid cc_default)) ::
 (_gLoadedGraphNodes, Gvar v_gLoadedGraphNodes) ::
 (_bhv_init_room,
   Gfun(External (EF_external "bhv_init_room"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) :: (_gGlobalTimer, Gvar v_gGlobalTimer) ::
 (_dist_between_objects,
   Gfun(External (EF_external "dist_between_objects"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xsingle
                     cc_default))
     ((tptr (Tstruct _Object noattr)) :: (tptr (Tstruct _Object noattr)) ::
      nil) tfloat cc_default)) ::
 (_obj_angle_to_object,
   Gfun(External (EF_external "obj_angle_to_object"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil)
                     AST.Xint16signed cc_default))
     ((tptr (Tstruct _Object noattr)) :: (tptr (Tstruct _Object noattr)) ::
      nil) tshort cc_default)) ::
 (_spawn_water_droplet,
   Gfun(External (EF_external "spawn_water_droplet"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xptr
                     cc_default))
     ((tptr (Tstruct _Object noattr)) ::
      (tptr (Tstruct _WaterDropletParams noattr)) :: nil)
     (tptr (Tstruct _Object noattr)) cc_default)) ::
 (_spawn_object_at_origin,
   Gfun(External (EF_external "spawn_object_at_origin"
                   (mksignature
                     (AST.Xptr :: AST.Xint :: AST.Xint :: AST.Xptr :: nil)
                     AST.Xptr cc_default))
     ((tptr (Tstruct _Object noattr)) :: tint :: tuint :: (tptr tuint) ::
      nil) (tptr (Tstruct _Object noattr)) cc_default)) ::
 (_obj_copy_pos_and_angle,
   Gfun(External (EF_external "obj_copy_pos_and_angle"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _Object noattr)) :: (tptr (Tstruct _Object noattr)) ::
      nil) tvoid cc_default)) ::
 (_cur_obj_scale,
   Gfun(External (EF_external "cur_obj_scale"
                   (mksignature (AST.Xsingle :: nil) AST.Xvoid cc_default))
     (tfloat :: nil) tvoid cc_default)) ::
 (_cur_obj_hide,
   Gfun(External (EF_external "cur_obj_hide"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_obj_set_face_angle_to_move_angle,
   Gfun(External (EF_external "obj_set_face_angle_to_move_angle"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _Object noattr)) :: nil) tvoid cc_default)) ::
 (_cur_obj_move_xz_using_fvel_and_yaw,
   Gfun(External (EF_external "cur_obj_move_xz_using_fvel_and_yaw"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_cur_obj_move_y_with_terminal_vel,
   Gfun(External (EF_external "cur_obj_move_y_with_terminal_vel"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_cur_obj_has_behavior,
   Gfun(External (EF_external "cur_obj_has_behavior"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr tuint) :: nil) tint cc_default)) ::
 (_obj_set_throw_matrix_from_transform,
   Gfun(External (EF_external "obj_set_throw_matrix_from_transform"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _Object noattr)) :: nil) tvoid cc_default)) ::
 (_obj_build_transform_relative_to_parent,
   Gfun(External (EF_external "obj_build_transform_relative_to_parent"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _Object noattr)) :: nil) tvoid cc_default)) ::
 (_cur_obj_enable_rendering_if_mario_in_room,
   Gfun(External (EF_external "cur_obj_enable_rendering_if_mario_in_room"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) :: (_gMarioObject, Gvar v_gMarioObject) ::
 (_gCurrentObject, Gvar v_gCurrentObject) ::
 (_gCurBhvCommand, Gvar v_gCurBhvCommand) ::
 (_find_floor_height,
   Gfun(External (EF_external "find_floor_height"
                   (mksignature
                     (AST.Xsingle :: AST.Xsingle :: AST.Xsingle :: nil)
                     AST.Xsingle cc_default))
     (tfloat :: tfloat :: tfloat :: nil) tfloat cc_default)) ::
 (_gRandomSeed16, Gvar v_gRandomSeed16) ::
 (_random_u16, Gfun(Internal f_random_u16)) ::
 (_random_float, Gfun(Internal f_random_float)) ::
 (_random_sign, Gfun(Internal f_random_sign)) ::
 (_obj_update_gfx_pos_and_angle, Gfun(Internal f_obj_update_gfx_pos_and_angle)) ::
 (_cur_obj_bhv_stack_push, Gfun(Internal f_cur_obj_bhv_stack_push)) ::
 (_cur_obj_bhv_stack_pop, Gfun(Internal f_cur_obj_bhv_stack_pop)) ::
 (_bhv_cmd_hide, Gfun(Internal f_bhv_cmd_hide)) ::
 (_bhv_cmd_disable_rendering, Gfun(Internal f_bhv_cmd_disable_rendering)) ::
 (_bhv_cmd_billboard, Gfun(Internal f_bhv_cmd_billboard)) ::
 (_bhv_cmd_set_model, Gfun(Internal f_bhv_cmd_set_model)) ::
 (_bhv_cmd_spawn_child, Gfun(Internal f_bhv_cmd_spawn_child)) ::
 (_bhv_cmd_spawn_obj, Gfun(Internal f_bhv_cmd_spawn_obj)) ::
 (_bhv_cmd_spawn_child_with_param, Gfun(Internal f_bhv_cmd_spawn_child_with_param)) ::
 (_bhv_cmd_deactivate, Gfun(Internal f_bhv_cmd_deactivate)) ::
 (_bhv_cmd_break, Gfun(Internal f_bhv_cmd_break)) ::
 (_bhv_cmd_break_unused, Gfun(Internal f_bhv_cmd_break_unused)) ::
 (_bhv_cmd_call, Gfun(Internal f_bhv_cmd_call)) ::
 (_bhv_cmd_return, Gfun(Internal f_bhv_cmd_return)) ::
 (_bhv_cmd_delay, Gfun(Internal f_bhv_cmd_delay)) ::
 (_bhv_cmd_delay_var, Gfun(Internal f_bhv_cmd_delay_var)) ::
 (_bhv_cmd_goto, Gfun(Internal f_bhv_cmd_goto)) ::
 (_bhv_cmd_begin_repeat_unused, Gfun(Internal f_bhv_cmd_begin_repeat_unused)) ::
 (_bhv_cmd_begin_repeat, Gfun(Internal f_bhv_cmd_begin_repeat)) ::
 (_bhv_cmd_end_repeat, Gfun(Internal f_bhv_cmd_end_repeat)) ::
 (_bhv_cmd_end_repeat_continue, Gfun(Internal f_bhv_cmd_end_repeat_continue)) ::
 (_bhv_cmd_begin_loop, Gfun(Internal f_bhv_cmd_begin_loop)) ::
 (_bhv_cmd_end_loop, Gfun(Internal f_bhv_cmd_end_loop)) ::
 (_bhv_cmd_call_native, Gfun(Internal f_bhv_cmd_call_native)) ::
 (_bhv_cmd_set_float, Gfun(Internal f_bhv_cmd_set_float)) ::
 (_bhv_cmd_set_int, Gfun(Internal f_bhv_cmd_set_int)) ::
 (_bhv_cmd_set_int_unused, Gfun(Internal f_bhv_cmd_set_int_unused)) ::
 (_bhv_cmd_set_random_float, Gfun(Internal f_bhv_cmd_set_random_float)) ::
 (_bhv_cmd_set_random_int, Gfun(Internal f_bhv_cmd_set_random_int)) ::
 (_bhv_cmd_set_int_rand_rshift, Gfun(Internal f_bhv_cmd_set_int_rand_rshift)) ::
 (_bhv_cmd_add_random_float, Gfun(Internal f_bhv_cmd_add_random_float)) ::
 (_bhv_cmd_add_int_rand_rshift, Gfun(Internal f_bhv_cmd_add_int_rand_rshift)) ::
 (_bhv_cmd_add_float, Gfun(Internal f_bhv_cmd_add_float)) ::
 (_bhv_cmd_add_int, Gfun(Internal f_bhv_cmd_add_int)) ::
 (_bhv_cmd_or_int, Gfun(Internal f_bhv_cmd_or_int)) ::
 (_bhv_cmd_bit_clear, Gfun(Internal f_bhv_cmd_bit_clear)) ::
 (_bhv_cmd_load_animations, Gfun(Internal f_bhv_cmd_load_animations)) ::
 (_bhv_cmd_animate, Gfun(Internal f_bhv_cmd_animate)) ::
 (_bhv_cmd_drop_to_floor, Gfun(Internal f_bhv_cmd_drop_to_floor)) ::
 (_bhv_cmd_nop_1, Gfun(Internal f_bhv_cmd_nop_1)) ::
 (_bhv_cmd_nop_3, Gfun(Internal f_bhv_cmd_nop_3)) ::
 (_bhv_cmd_nop_2, Gfun(Internal f_bhv_cmd_nop_2)) ::
 (_bhv_cmd_sum_float, Gfun(Internal f_bhv_cmd_sum_float)) ::
 (_bhv_cmd_sum_int, Gfun(Internal f_bhv_cmd_sum_int)) ::
 (_bhv_cmd_set_hitbox, Gfun(Internal f_bhv_cmd_set_hitbox)) ::
 (_bhv_cmd_set_hurtbox, Gfun(Internal f_bhv_cmd_set_hurtbox)) ::
 (_bhv_cmd_set_hitbox_with_offset, Gfun(Internal f_bhv_cmd_set_hitbox_with_offset)) ::
 (_bhv_cmd_nop_4, Gfun(Internal f_bhv_cmd_nop_4)) ::
 (_bhv_cmd_begin, Gfun(Internal f_bhv_cmd_begin)) ::
 (_bhv_cmd_load_collision_data, Gfun(Internal f_bhv_cmd_load_collision_data)) ::
 (_bhv_cmd_set_home, Gfun(Internal f_bhv_cmd_set_home)) ::
 (_bhv_cmd_set_interact_type, Gfun(Internal f_bhv_cmd_set_interact_type)) ::
 (_bhv_cmd_set_interact_subtype, Gfun(Internal f_bhv_cmd_set_interact_subtype)) ::
 (_bhv_cmd_scale, Gfun(Internal f_bhv_cmd_scale)) ::
 (_bhv_cmd_set_obj_physics, Gfun(Internal f_bhv_cmd_set_obj_physics)) ::
 (_bhv_cmd_parent_bit_clear, Gfun(Internal f_bhv_cmd_parent_bit_clear)) ::
 (_bhv_cmd_spawn_water_droplet, Gfun(Internal f_bhv_cmd_spawn_water_droplet)) ::
 (_bhv_cmd_animate_texture, Gfun(Internal f_bhv_cmd_animate_texture)) ::
 (_stub_behavior_script_2, Gfun(Internal f_stub_behavior_script_2)) ::
 (_BehaviorCmdTable, Gvar v_BehaviorCmdTable) ::
 (_cur_obj_update, Gfun(Internal f_cur_obj_update)) :: nil).

Definition public_idents : list ident :=
(_cur_obj_update :: _stub_behavior_script_2 ::
 _obj_update_gfx_pos_and_angle :: _random_sign :: _random_float ::
 _random_u16 :: _find_floor_height :: _gCurBhvCommand :: _gCurrentObject ::
 _gMarioObject :: _cur_obj_enable_rendering_if_mario_in_room ::
 _obj_build_transform_relative_to_parent ::
 _obj_set_throw_matrix_from_transform :: _cur_obj_has_behavior ::
 _cur_obj_move_y_with_terminal_vel :: _cur_obj_move_xz_using_fvel_and_yaw ::
 _obj_set_face_angle_to_move_angle :: _cur_obj_hide :: _cur_obj_scale ::
 _obj_copy_pos_and_angle :: _spawn_object_at_origin ::
 _spawn_water_droplet :: _obj_angle_to_object :: _dist_between_objects ::
 _gGlobalTimer :: _bhv_init_room :: _gLoadedGraphNodes ::
 _geo_obj_init_animation :: _segmented_to_virtual :: _bhvMadPiano ::
 _bhvHauntedChair :: _bhvMessagePanel :: ___builtin_debug ::
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


