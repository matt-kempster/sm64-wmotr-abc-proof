(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Produced by: pipeline/clightgen.sh
   From source: vendor/sm64/src/game/mario_actions_cutscene.c
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
  Definition source_file := "vendor/sm64/src/game/mario_actions_cutscene.c".
  Definition normalized := true.
End Info.

Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _Area : ident := $"Area".
Definition _Camera : ident := $"Camera".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _Controller : ident := $"Controller".
Definition _CreditsEntry : ident := $"CreditsEntry".
Definition _D_8032CBE4 : ident := $"D_8032CBE4".
Definition _D_8032CBE8 : ident := $"D_8032CBE8".
Definition _D_8032CBEC : ident := $"D_8032CBEC".
Definition _DmaHandlerList : ident := $"DmaHandlerList".
Definition _DmaTable : ident := $"DmaTable".
Definition _FnGraphNode : ident := $"FnGraphNode".
Definition _GraphNode : ident := $"GraphNode".
Definition _GraphNodeObject : ident := $"GraphNodeObject".
Definition _GraphNodeRoot : ident := $"GraphNodeRoot".
Definition _GraphNodeSwitchCase : ident := $"GraphNodeSwitchCase".
Definition _HudDisplay : ident := $"HudDisplay".
Definition _InstantWarp : ident := $"InstantWarp".
Definition _MarioBodyState : ident := $"MarioBodyState".
Definition _MarioState : ident := $"MarioState".
Definition _Object : ident := $"Object".
Definition _ObjectNode : ident := $"ObjectNode".
Definition _ObjectWarpNode : ident := $"ObjectWarpNode".
Definition _OffsetSizePair : ident := $"OffsetSizePair".
Definition _PlayerCameraState : ident := $"PlayerCameraState".
Definition _SpawnInfo : ident := $"SpawnInfo".
Definition _Surface : ident := $"Surface".
Definition _UnusedArea28 : ident := $"UnusedArea28".
Definition _WarpNode : ident := $"WarpNode".
Definition _Waypoint : ident := $"Waypoint".
Definition _Whirlpool : ident := $"Whirlpool".
Definition __282 : ident := $"_282".
Definition __284 : ident := $"_284".
Definition __434 : ident := $"_434".
Definition __439 : ident := $"_439".
Definition __441 : ident := $"_441".
Definition __475 : ident := $"_475".
Definition __477 : ident := $"_477".
Definition __479 : ident := $"_479".
Definition __481 : ident := $"_481".
Definition __483 : ident := $"_483".
Definition __485 : ident := $"_485".
Definition __487 : ident := $"_487".
Definition __489 : ident := $"_489".
Definition __491 : ident := $"_491".
Definition __493 : ident := $"_493".
Definition __495 : ident := $"_495".
Definition __497 : ident := $"_497".
Definition __499 : ident := $"_499".
Definition __501 : ident := $"_501".
Definition __503 : ident := $"_503".
Definition __512 : ident := $"_512".
Definition __514 : ident := $"_514".
Definition __729 : ident := $"_729".
Definition __734 : ident := $"_734".
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
Definition _a2 : ident := $"a2".
Definition _act_bbh_enter_jump : ident := $"act_bbh_enter_jump".
Definition _act_bbh_enter_spin : ident := $"act_bbh_enter_spin".
Definition _act_butt_stuck_in_ground : ident := $"act_butt_stuck_in_ground".
Definition _act_credits_cutscene : ident := $"act_credits_cutscene".
Definition _act_death_exit : ident := $"act_death_exit".
Definition _act_death_on_back : ident := $"act_death_on_back".
Definition _act_death_on_stomach : ident := $"act_death_on_stomach".
Definition _act_debug_free_move : ident := $"act_debug_free_move".
Definition _act_disappeared : ident := $"act_disappeared".
Definition _act_eaten_by_bubba : ident := $"act_eaten_by_bubba".
Definition _act_electrocution : ident := $"act_electrocution".
Definition _act_emerge_from_pipe : ident := $"act_emerge_from_pipe".
Definition _act_end_peach_cutscene : ident := $"act_end_peach_cutscene".
Definition _act_end_waving_cutscene : ident := $"act_end_waving_cutscene".
Definition _act_entering_star_door : ident := $"act_entering_star_door".
Definition _act_exit_airborne : ident := $"act_exit_airborne".
Definition _act_exit_land_save_dialog : ident := $"act_exit_land_save_dialog".
Definition _act_fall_after_star_grab : ident := $"act_fall_after_star_grab".
Definition _act_falling_death_exit : ident := $"act_falling_death_exit".
Definition _act_falling_exit_airborne : ident := $"act_falling_exit_airborne".
Definition _act_feet_stuck_in_ground : ident := $"act_feet_stuck_in_ground".
Definition _act_going_through_door : ident := $"act_going_through_door".
Definition _act_head_stuck_in_ground : ident := $"act_head_stuck_in_ground".
Definition _act_intro_cutscene : ident := $"act_intro_cutscene".
Definition _act_jumbo_star_cutscene : ident := $"act_jumbo_star_cutscene".
Definition _act_putting_on_cap : ident := $"act_putting_on_cap".
Definition _act_quicksand_death : ident := $"act_quicksand_death".
Definition _act_reading_automatic_dialog : ident := $"act_reading_automatic_dialog".
Definition _act_reading_npc_dialog : ident := $"act_reading_npc_dialog".
Definition _act_reading_sign : ident := $"act_reading_sign".
Definition _act_shocked : ident := $"act_shocked".
Definition _act_spawn_no_spin_airborne : ident := $"act_spawn_no_spin_airborne".
Definition _act_spawn_no_spin_landing : ident := $"act_spawn_no_spin_landing".
Definition _act_spawn_spin_airborne : ident := $"act_spawn_spin_airborne".
Definition _act_spawn_spin_landing : ident := $"act_spawn_spin_landing".
Definition _act_special_death_exit : ident := $"act_special_death_exit".
Definition _act_special_exit_airborne : ident := $"act_special_exit_airborne".
Definition _act_squished : ident := $"act_squished".
Definition _act_standing_death : ident := $"act_standing_death".
Definition _act_star_dance : ident := $"act_star_dance".
Definition _act_star_dance_water : ident := $"act_star_dance_water".
Definition _act_suffocation : ident := $"act_suffocation".
Definition _act_teleport_fade_in : ident := $"act_teleport_fade_in".
Definition _act_teleport_fade_out : ident := $"act_teleport_fade_out".
Definition _act_unlocking_key_door : ident := $"act_unlocking_key_door".
Definition _act_unlocking_star_door : ident := $"act_unlocking_star_door".
Definition _act_unused_death_exit : ident := $"act_unused_death_exit".
Definition _act_waiting_for_dialog : ident := $"act_waiting_for_dialog".
Definition _act_warp_door_spawn : ident := $"act_warp_door_spawn".
Definition _action : ident := $"action".
Definition _actionArg : ident := $"actionArg".
Definition _actionGroup : ident := $"actionGroup".
Definition _actionState : ident := $"actionState".
Definition _actionTimer : ident := $"actionTimer".
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _addr : ident := $"addr".
Definition _advance_cutscene_step : ident := $"advance_cutscene_step".
Definition _airStepLanded : ident := $"airStepLanded".
Definition _angle : ident := $"angle".
Definition _angleToNPC : ident := $"angleToNPC".
Definition _angleVel : ident := $"angleVel".
Definition _anim : ident := $"anim".
Definition _animAccel : ident := $"animAccel".
Definition _animFrame : ident := $"animFrame".
Definition _animFrameAccelAssist : ident := $"animFrameAccelAssist".
Definition _animID : ident := $"animID".
Definition _animInfo : ident := $"animInfo".
Definition _animList : ident := $"animList".
Definition _animTimer : ident := $"animTimer".
Definition _animYTrans : ident := $"animYTrans".
Definition _animYTransDivisor : ident := $"animYTransDivisor".
Definition _anim_spline_init : ident := $"anim_spline_init".
Definition _anim_spline_poll : ident := $"anim_spline_poll".
Definition _animation : ident := $"animation".
Definition _approach_s32 : ident := $"approach_s32".
Definition _area : ident := $"area".
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
Definition _atan2s : ident := $"atan2s".
Definition _base : ident := $"base".
Definition _behavior : ident := $"behavior".
Definition _behaviorArg : ident := $"behaviorArg".
Definition _behaviorScript : ident := $"behaviorScript".
Definition _bhvBowserKeyCourseExit : ident := $"bhvBowserKeyCourseExit".
Definition _bhvBowserKeyUnlockDoor : ident := $"bhvBowserKeyUnlockDoor".
Definition _bhvCelebrationStar : ident := $"bhvCelebrationStar".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvEndPeach : ident := $"bhvEndPeach".
Definition _bhvEndToad : ident := $"bhvEndToad".
Definition _bhvSparkleSpawn : ident := $"bhvSparkleSpawn".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _bhvStaticObject : ident := $"bhvStaticObject".
Definition _bhvUnlockDoorStar : ident := $"bhvUnlockDoorStar".
Definition _bhv_end_peach_loop : ident := $"bhv_end_peach_loop".
Definition _bhv_end_toad_loop : ident := $"bhv_end_toad_loop".
Definition _bufTarget : ident := $"bufTarget".
Definition _button : ident := $"button".
Definition _buttonDown : ident := $"buttonDown".
Definition _buttonPressed : ident := $"buttonPressed".
Definition _c : ident := $"c".
Definition _cageDX : ident := $"cageDX".
Definition _cageDZ : ident := $"cageDZ".
Definition _cageDist : ident := $"cageDist".
Definition _camera : ident := $"camera".
Definition _cameraEvent : ident := $"cameraEvent".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _camera_approach_f32_symmetric : ident := $"camera_approach_f32_symmetric".
Definition _cancel : ident := $"cancel".
Definition _capState : ident := $"capState".
Definition _capTimer : ident := $"capTimer".
Definition _ceil : ident := $"ceil".
Definition _ceilHeight : ident := $"ceilHeight".
Definition _check_for_instant_quicksand : ident := $"check_for_instant_quicksand".
Definition _children : ident := $"children".
Definition _cmd : ident := $"cmd".
Definition _coins : ident := $"coins".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _color : ident := $"color".
Definition _common_death_handler : ident := $"common_death_handler".
Definition _controller : ident := $"controller".
Definition _controllerData : ident := $"controllerData".
Definition _count : ident := $"count".
Definition _create_dialog_box : ident := $"create_dialog_box".
Definition _create_dialog_box_with_response : ident := $"create_dialog_box_with_response".
Definition _create_dialog_box_with_var : ident := $"create_dialog_box_with_var".
Definition _create_dialog_inverted_box : ident := $"create_dialog_inverted_box".
Definition _cs : ident := $"cs".
Definition _ct : ident := $"ct".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _cur_obj_check_if_near_animation_end : ident := $"cur_obj_check_if_near_animation_end".
Definition _cur_obj_init_animation_with_sound : ident := $"cur_obj_init_animation_with_sound".
Definition _currStrPtr : ident := $"currStrPtr".
Definition _currentAddr : ident := $"currentAddr".
Definition _cutscene : ident := $"cutscene".
Definition _cutscene_put_cap_on : ident := $"cutscene_put_cap_on".
Definition _cutscene_take_cap_off : ident := $"cutscene_take_cap_off".
Definition _data : ident := $"data".
Definition _defMode : ident := $"defMode".
Definition _destArea : ident := $"destArea".
Definition _destLevel : ident := $"destLevel".
Definition _destNode : ident := $"destNode".
Definition _dialog : ident := $"dialog".
Definition _dialogID : ident := $"dialogID".
Definition _dialogState : ident := $"dialogState".
Definition _disable_background_sound : ident := $"disable_background_sound".
Definition _disable_time_stop : ident := $"disable_time_stop".
Definition _displacement : ident := $"displacement".
Definition _dl_rgba16_begin_cutscene_msg_fade : ident := $"dl_rgba16_begin_cutscene_msg_fade".
Definition _dl_rgba16_stop_cutscene_msg_fade : ident := $"dl_rgba16_stop_cutscene_msg_fade".
Definition _dma : ident := $"dma".
Definition _dmaTable : ident := $"dmaTable".
Definition _doorStatus : ident := $"doorStatus".
Definition _doubleJumpTimer : ident := $"doubleJumpTimer".
Definition _dram : ident := $"dram".
Definition _drop_and_set_mario_action : ident := $"drop_and_set_mario_action".
Definition _enable_background_sound : ident := $"enable_background_sound".
Definition _enable_time_stop : ident := $"enable_time_stop".
Definition _endAction : ident := $"endAction".
Definition _end_obj_set_visual_pos : ident := $"end_obj_set_visual_pos".
Definition _end_peach_cutscene_descend_peach : ident := $"end_peach_cutscene_descend_peach".
Definition _end_peach_cutscene_dialog_1 : ident := $"end_peach_cutscene_dialog_1".
Definition _end_peach_cutscene_dialog_2 : ident := $"end_peach_cutscene_dialog_2".
Definition _end_peach_cutscene_dialog_3 : ident := $"end_peach_cutscene_dialog_3".
Definition _end_peach_cutscene_fade_out : ident := $"end_peach_cutscene_fade_out".
Definition _end_peach_cutscene_kiss_from_peach : ident := $"end_peach_cutscene_kiss_from_peach".
Definition _end_peach_cutscene_mario_falling : ident := $"end_peach_cutscene_mario_falling".
Definition _end_peach_cutscene_mario_landing : ident := $"end_peach_cutscene_mario_landing".
Definition _end_peach_cutscene_run_to_castle : ident := $"end_peach_cutscene_run_to_castle".
Definition _end_peach_cutscene_run_to_peach : ident := $"end_peach_cutscene_run_to_peach".
Definition _end_peach_cutscene_spawn_peach : ident := $"end_peach_cutscene_spawn_peach".
Definition _end_peach_cutscene_star_dance : ident := $"end_peach_cutscene_star_dance".
Definition _end_peach_cutscene_summon_jumbo_star : ident := $"end_peach_cutscene_summon_jumbo_star".
Definition _errnum : ident := $"errnum".
Definition _eyeState : ident := $"eyeState".
Definition _faceAngle : ident := $"faceAngle".
Definition _fadeWarpOpacity : ident := $"fadeWarpOpacity".
Definition _fade_into_special_warp : ident := $"fade_into_special_warp".
Definition _filler : ident := $"filler".
Definition _filler1 : ident := $"filler1".
Definition _filler2 : ident := $"filler2".
Definition _fillrect : ident := $"fillrect".
Definition _find_floor : ident := $"find_floor".
Definition _find_mario_anim_flags_and_translation : ident := $"find_mario_anim_flags_and_translation".
Definition _flag : ident := $"flag".
Definition _flags : ident := $"flags".
Definition _floor : ident := $"floor".
Definition _floorAngle : ident := $"floorAngle".
Definition _floorDist : ident := $"floorDist".
Definition _floorHeight : ident := $"floorHeight".
Definition _fmt : ident := $"fmt".
Definition _fnNode : ident := $"fnNode".
Definition _focus : ident := $"focus".
Definition _force : ident := $"force".
Definition _force_structure_alignment : ident := $"force_structure_alignment".
Definition _forwardVel : ident := $"forwardVel".
Definition _frameToDeathWarp : ident := $"frameToDeathWarp".
Definition _framesSinceA : ident := $"framesSinceA".
Definition _framesSinceB : ident := $"framesSinceB".
Definition _func : ident := $"func".
Definition _gAreaUpdateCounter : ident := $"gAreaUpdateCounter".
Definition _gAudioRandom : ident := $"gAudioRandom".
Definition _gCamera : ident := $"gCamera".
Definition _gCameraMovementFlags : ident := $"gCameraMovementFlags".
Definition _gCurrAreaIndex : ident := $"gCurrAreaIndex".
Definition _gCurrCreditsEntry : ident := $"gCurrCreditsEntry".
Definition _gCurrLevelNum : ident := $"gCurrLevelNum".
Definition _gCurrSaveFileNum : ident := $"gCurrSaveFileNum".
Definition _gCurrentObject : ident := $"gCurrentObject".
Definition _gCutsceneFocus : ident := $"gCutsceneFocus".
Definition _gDialogResponse : ident := $"gDialogResponse".
Definition _gGlobalSoundSource : ident := $"gGlobalSoundSource".
Definition _gHudDisplay : ident := $"gHudDisplay".
Definition _gLastCompletedCourseNum : ident := $"gLastCompletedCourseNum".
Definition _gLastCompletedStarNum : ident := $"gLastCompletedStarNum".
Definition _gMarioState : ident := $"gMarioState".
Definition _gNeverEnteredCastle : ident := $"gNeverEnteredCastle".
Definition _gPaintingMarioYEntry : ident := $"gPaintingMarioYEntry".
Definition _gPlayer1Controller : ident := $"gPlayer1Controller".
Definition _gSaveOptSelectIndex : ident := $"gSaveOptSelectIndex".
Definition _gSineTable : ident := $"gSineTable".
Definition _general_star_dance_handler : ident := $"general_star_dance_handler".
Definition _generate_yellow_sparkles : ident := $"generate_yellow_sparkles".
Definition _geo_switch_peach_eyes : ident := $"geo_switch_peach_eyes".
Definition _get_credits_str_width : ident := $"get_credits_str_width".
Definition _get_dialog_id : ident := $"get_dialog_id".
Definition _get_door_save_file_flag : ident := $"get_door_save_file_flag".
Definition _get_star_collection_dialog : ident := $"get_star_collection_dialog".
Definition _gettingBlownGravity : ident := $"gettingBlownGravity".
Definition _gfx : ident := $"gfx".
Definition _grabPos : ident := $"grabPos".
Definition _handState : ident := $"handState".
Definition _handle_save_menu : ident := $"handle_save_menu".
Definition _headAngle : ident := $"headAngle".
Definition _headRotation : ident := $"headRotation".
Definition _headTurnAmount : ident := $"headTurnAmount".
Definition _header : ident := $"header".
Definition _healCounter : ident := $"healCounter".
Definition _health : ident := $"health".
Definition _height : ident := $"height".
Definition _heldObj : ident := $"heldObj".
Definition _heldObjLastPosition : ident := $"heldObjLastPosition".
Definition _hitboxDownOffset : ident := $"hitboxDownOffset".
Definition _hitboxHeight : ident := $"hitboxHeight".
Definition _hitboxRadius : ident := $"hitboxRadius".
Definition _hurtCounter : ident := $"hurtCounter".
Definition _hurtboxHeight : ident := $"hurtboxHeight".
Definition _hurtboxRadius : ident := $"hurtboxRadius".
Definition _i : ident := $"i".
Definition _id : ident := $"id".
Definition _index : ident := $"index".
Definition _input : ident := $"input".
Definition _instantWarps : ident := $"instantWarps".
Definition _intendedMag : ident := $"intendedMag".
Definition _intendedYaw : ident := $"intendedYaw".
Definition _interactObj : ident := $"interactObj".
Definition _intro_cutscene_hide_hud_and_mario : ident := $"intro_cutscene_hide_hud_and_mario".
Definition _intro_cutscene_jump_out_of_pipe : ident := $"intro_cutscene_jump_out_of_pipe".
Definition _intro_cutscene_land_outside_pipe : ident := $"intro_cutscene_land_outside_pipe".
Definition _intro_cutscene_lower_pipe : ident := $"intro_cutscene_lower_pipe".
Definition _intro_cutscene_peach_lakitu_scene : ident := $"intro_cutscene_peach_lakitu_scene".
Definition _intro_cutscene_raise_pipe : ident := $"intro_cutscene_raise_pipe".
Definition _intro_cutscene_set_mario_to_idle : ident := $"intro_cutscene_set_mario_to_idle".
Definition _invincTimer : ident := $"invincTimer".
Definition _isInWater : ident := $"isInWater".
Definition _isReadyToSpeak : ident := $"isReadyToSpeak".
Definition _is_anim_at_end : ident := $"is_anim_at_end".
Definition _is_anim_past_end : ident := $"is_anim_past_end".
Definition _jumbo_star_cutscene_falling : ident := $"jumbo_star_cutscene_falling".
Definition _jumbo_star_cutscene_flying : ident := $"jumbo_star_cutscene_flying".
Definition _jumbo_star_cutscene_taking_off : ident := $"jumbo_star_cutscene_taking_off".
Definition _keys : ident := $"keys".
Definition _launch_mario_until_land : ident := $"launch_mario_until_land".
Definition _len : ident := $"len".
Definition _length : ident := $"length".
Definition _levelNum : ident := $"levelNum".
Definition _level_trigger_warp : ident := $"level_trigger_warp".
Definition _line : ident := $"line".
Definition _lineHeight : ident := $"lineHeight".
Definition _lives : ident := $"lives".
Definition _load_level_init_text : ident := $"load_level_init_text".
Definition _loadtile : ident := $"loadtile".
Definition _loadtlut : ident := $"loadtlut".
Definition _lodscale : ident := $"lodscale".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _m : ident := $"m".
Definition _macroObjects : ident := $"macroObjects".
Definition _main : ident := $"main".
Definition _marioAngle : ident := $"marioAngle".
Definition _marioBodyState : ident := $"marioBodyState".
Definition _marioObj : ident := $"marioObj".
Definition _marioPos : ident := $"marioPos".
Definition _mario_execute_cutscene_action : ident := $"mario_execute_cutscene_action".
Definition _mario_obj_angle_to_object : ident := $"mario_obj_angle_to_object".
Definition _mario_ready_to_speak : ident := $"mario_ready_to_speak".
Definition _mario_set_forward_vel : ident := $"mario_set_forward_vel".
Definition _masks : ident := $"masks".
Definition _maskt : ident := $"maskt".
Definition _mode : ident := $"mode".
Definition _model : ident := $"model".
Definition _modelState : ident := $"modelState".
Definition _ms : ident := $"ms".
Definition _mt : ident := $"mt".
Definition _musicParam : ident := $"musicParam".
Definition _musicParam2 : ident := $"musicParam2".
Definition _muxs0 : ident := $"muxs0".
Definition _muxs1 : ident := $"muxs1".
Definition _mw_index : ident := $"mw_index".
Definition _next : ident := $"next".
Definition _nextYaw : ident := $"nextYaw".
Definition _node : ident := $"node".
Definition _normal : ident := $"normal".
Definition _numCases : ident := $"numCases".
Definition _numCoins : ident := $"numCoins".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _numKeys : ident := $"numKeys".
Definition _numLines : ident := $"numLines".
Definition _numLives : ident := $"numLives".
Definition _numStars : ident := $"numStars".
Definition _numStarsRequired : ident := $"numStarsRequired".
Definition _numViews : ident := $"numViews".
Definition _number : ident := $"number".
Definition _o : ident := $"o".
Definition _obj_mark_for_deletion : ident := $"obj_mark_for_deletion".
Definition _obj_scale : ident := $"obj_scale".
Definition _object : ident := $"object".
Definition _objectSpawnInfos : ident := $"objectSpawnInfos".
Definition _offset : ident := $"offset".
Definition _offsetX : ident := $"offsetX".
Definition _offsetY : ident := $"offsetY".
Definition _offsetZ : ident := $"offsetZ".
Definition _on : ident := $"on".
Definition _originOffset : ident := $"originOffset".
Definition _override_viewport_and_clip : ident := $"override_viewport_and_clip".
Definition _pad : ident := $"pad".
Definition _pad0 : ident := $"pad0".
Definition _pad1 : ident := $"pad1".
Definition _pad2 : ident := $"pad2".
Definition _paintingWarpNodes : ident := $"paintingWarpNodes".
Definition _palette : ident := $"palette".
Definition _par : ident := $"par".
Definition _param : ident := $"param".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _particleFlags : ident := $"particleFlags".
Definition _peakHeight : ident := $"peakHeight".
Definition _perform_air_step : ident := $"perform_air_step".
Definition _perform_ground_step : ident := $"perform_ground_step".
Definition _perspnorm : ident := $"perspnorm".
Definition _pitch : ident := $"pitch".
Definition _platform : ident := $"platform".
Definition _play_course_clear : ident := $"play_course_clear".
Definition _play_cutscene_music : ident := $"play_cutscene_music".
Definition _play_mario_action_sound : ident := $"play_mario_action_sound".
Definition _play_mario_heavy_landing_sound : ident := $"play_mario_heavy_landing_sound".
Definition _play_mario_jump_sound : ident := $"play_mario_jump_sound".
Definition _play_mario_landing_sound : ident := $"play_mario_landing_sound".
Definition _play_mario_landing_sound_once : ident := $"play_mario_landing_sound_once".
Definition _play_music : ident := $"play_music".
Definition _play_peachs_jingle : ident := $"play_peachs_jingle".
Definition _play_sound : ident := $"play_sound".
Definition _play_sound_and_spawn_particles : ident := $"play_sound_and_spawn_particles".
Definition _play_sound_if_no_flag : ident := $"play_sound_if_no_flag".
Definition _play_step_sound : ident := $"play_step_sound".
Definition _play_transition : ident := $"play_transition".
Definition _popmtx : ident := $"popmtx".
Definition _pos : ident := $"pos".
Definition _posX : ident := $"posX".
Definition _posY : ident := $"posY".
Definition _posZ : ident := $"posZ".
Definition _prev : ident := $"prev".
Definition _prevAction : ident := $"prevAction".
Definition _prevNumStarsForDialog : ident := $"prevNumStarsForDialog".
Definition _prevObj : ident := $"prevObj".
Definition _prim_level : ident := $"prim_level".
Definition _prim_min_level : ident := $"prim_min_level".
Definition _print_credits_str_ascii : ident := $"print_credits_str_ascii".
Definition _print_displaying_credits_entry : ident := $"print_displaying_credits_entry".
Definition _punchState : ident := $"punchState".
Definition _quicksandDepth : ident := $"quicksandDepth".
Definition _radius : ident := $"radius".
Definition _rawData : ident := $"rawData".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _relYaw : ident := $"relYaw".
Definition _reset_cutscene_msg_fade : ident := $"reset_cutscene_msg_fade".
Definition _resolve_and_return_wall_collisions : ident := $"resolve_and_return_wall_collisions".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _riddenObj : ident := $"riddenObj".
Definition _roll : ident := $"roll".
Definition _room : ident := $"room".
Definition _run : ident := $"run".
Definition _s : ident := $"s".
Definition _sDispCreditsEntry : ident := $"sDispCreditsEntry".
Definition _sEndCutsceneVp : ident := $"sEndCutsceneVp".
Definition _sEndJumboStarObj : ident := $"sEndJumboStarObj".
Definition _sEndLeftToadObj : ident := $"sEndLeftToadObj".
Definition _sEndPeachAnimation : ident := $"sEndPeachAnimation".
Definition _sEndPeachObj : ident := $"sEndPeachObj".
Definition _sEndRightToadObj : ident := $"sEndRightToadObj".
Definition _sEndToadAnims : ident := $"sEndToadAnims".
Definition _sIntroWarpPipeObj : ident := $"sIntroWarpPipeObj".
Definition _sJumboStarKeyframes : ident := $"sJumboStarKeyframes".
Definition _sMarioBlinkOverride : ident := $"sMarioBlinkOverride".
Definition _sSparkleGenPhi : ident := $"sSparkleGenPhi".
Definition _sSparkleGenTheta : ident := $"sSparkleGenTheta".
Definition _sStarsNeededForDialog : ident := $"sStarsNeededForDialog".
Definition _save_file_clear_flags : ident := $"save_file_clear_flags".
Definition _save_file_do_save : ident := $"save_file_do_save".
Definition _save_file_set_flags : ident := $"save_file_set_flags".
Definition _scale : ident := $"scale".
Definition _segment : ident := $"segment".
Definition _selectedCase : ident := $"selectedCase".
Definition _seq_player_lower_volume : ident := $"seq_player_lower_volume".
Definition _seq_player_unlower_volume : ident := $"seq_player_unlower_volume".
Definition _set_anim_to_frame : ident := $"set_anim_to_frame".
Definition _set_camera_mode : ident := $"set_camera_mode".
Definition _set_camera_shake_from_hit : ident := $"set_camera_shake_from_hit".
Definition _set_cutscene_message : ident := $"set_cutscene_message".
Definition _set_mario_action : ident := $"set_mario_action".
Definition _set_mario_anim_with_accel : ident := $"set_mario_anim_with_accel".
Definition _set_mario_animation : ident := $"set_mario_animation".
Definition _set_mario_npc_dialog : ident := $"set_mario_npc_dialog".
Definition _set_menu_mode : ident := $"set_menu_mode".
Definition _set_water_plunge_action : ident := $"set_water_plunge_action".
Definition _setcolor : ident := $"setcolor".
Definition _setcombine : ident := $"setcombine".
Definition _setimg : ident := $"setimg".
Definition _setothermodeH : ident := $"setothermodeH".
Definition _setothermodeL : ident := $"setothermodeL".
Definition _settile : ident := $"settile".
Definition _settilesize : ident := $"settilesize".
Definition _sft : ident := $"sft".
Definition _sh : ident := $"sh".
Definition _sharedChild : ident := $"sharedChild".
Definition _shifts : ident := $"shifts".
Definition _shiftt : ident := $"shiftt".
Definition _siz : ident := $"siz".
Definition _size : ident := $"size".
Definition _sl : ident := $"sl".
Definition _slideVelX : ident := $"slideVelX".
Definition _slideVelZ : ident := $"slideVelZ".
Definition _slideYaw : ident := $"slideYaw".
Definition _sound_banks_enable : ident := $"sound_banks_enable".
Definition _sp18 : ident := $"sp18".
Definition _sp1C : ident := $"sp1C".
Definition _sp20 : ident := $"sp20".
Definition _sp24 : ident := $"sp24".
Definition _spaceUnderCeil : ident := $"spaceUnderCeil".
Definition _spawnInfo : ident := $"spawnInfo".
Definition _spawn_obj_at_mario_rel_yaw : ident := $"spawn_obj_at_mario_rel_yaw".
Definition _spawn_object : ident := $"spawn_object".
Definition _spawn_object_abs_with_rot : ident := $"spawn_object_abs_with_rot".
Definition _speed : ident := $"speed".
Definition _sqrtf : ident := $"sqrtf".
Definition _squishAmount : ident := $"squishAmount".
Definition _squishTimer : ident := $"squishTimer".
Definition _srcAddr : ident := $"srcAddr".
Definition _stars : ident := $"stars".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
Definition _stationary_ground_step : ident := $"stationary_ground_step".
Definition _status : ident := $"status".
Definition _statusData : ident := $"statusData".
Definition _statusForCamera : ident := $"statusForCamera".
Definition _stickMag : ident := $"stickMag".
Definition _stickX : ident := $"stickX".
Definition _stickY : ident := $"stickY".
Definition _stick_x : ident := $"stick_x".
Definition _stick_y : ident := $"stick_y".
Definition _stop_and_set_height_to_floor : ident := $"stop_and_set_height_to_floor".
Definition _str : ident := $"str".
Definition _strY : ident := $"strY".
Definition _strength : ident := $"strength".
Definition _stuck_in_ground_handler : ident := $"stuck_in_ground_handler".
Definition _surf : ident := $"surf".
Definition _surfAngle : ident := $"surfAngle".
Definition _surfaceRooms : ident := $"surfaceRooms".
Definition _switchCase : ident := $"switchCase".
Definition _t : ident := $"t".
Definition _target2 : ident := $"target2".
Definition _target3 : ident := $"target3".
Definition _targetAngle : ident := $"targetAngle".
Definition _targetDX : ident := $"targetDX".
Definition _targetDY : ident := $"targetDY".
Definition _targetDZ : ident := $"targetDZ".
Definition _targetHyp : ident := $"targetHyp".
Definition _targetPos : ident := $"targetPos".
Definition _terrainData : ident := $"terrainData".
Definition _terrainSoundAddend : ident := $"terrainSoundAddend".
Definition _terrainType : ident := $"terrainType".
Definition _texture : ident := $"texture".
Definition _th : ident := $"th".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _tile : ident := $"tile".
Definition _timer : ident := $"timer".
Definition _titleStr : ident := $"titleStr".
Definition _tl : ident := $"tl".
Definition _tmem : ident := $"tmem".
Definition _toadAnimIndex : ident := $"toadAnimIndex".
Definition _torsoAngle : ident := $"torsoAngle".
Definition _transform : ident := $"transform".
Definition _tri : ident := $"tri".
Definition _trigger_cutscene_dialog : ident := $"trigger_cutscene_dialog".
Definition _twirlYaw : ident := $"twirlYaw".
Definition _type : ident := $"type".
Definition _underSteepSurf : ident := $"underSteepSurf".
Definition _unk00 : ident := $"unk00".
Definition _unk02 : ident := $"unk02".
Definition _unk04 : ident := $"unk04".
Definition _unk06 : ident := $"unk06".
Definition _unk08 : ident := $"unk08".
Definition _unk0C : ident := $"unk0C".
Definition _unk15 : ident := $"unk15".
Definition _unk4C : ident := $"unk4C".
Definition _unkB0 : ident := $"unkB0".
Definition _unstuckFrame : ident := $"unstuckFrame".
Definition _unused : ident := $"unused".
Definition _unused1 : ident := $"unused1".
Definition _unused2 : ident := $"unused2".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _unusedVec1 : ident := $"unusedVec1".
Definition _update_mario_pos_for_anim : ident := $"update_mario_pos_for_anim".
Definition _update_mario_sound_and_camera : ident := $"update_mario_sound_and_camera".
Definition _upperY : ident := $"upperY".
Definition _usedObj : ident := $"usedObj".
Definition _v : ident := $"v".
Definition _values : ident := $"values".
Definition _vec3f_copy : ident := $"vec3f_copy".
Definition _vec3f_set : ident := $"vec3f_set".
Definition _vec3s_copy : ident := $"vec3s_copy".
Definition _vec3s_set : ident := $"vec3s_set".
Definition _vel : ident := $"vel".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _views : ident := $"views".
Definition _vp : ident := $"vp".
Definition _vscale : ident := $"vscale".
Definition _vtrans : ident := $"vtrans".
Definition _w0 : ident := $"w0".
Definition _w1 : ident := $"w1".
Definition _wall : ident := $"wall".
Definition _wallKickTimer : ident := $"wallKickTimer".
Definition _warpNodes : ident := $"warpNodes".
Definition _waterLevel : ident := $"waterLevel".
Definition _wd : ident := $"wd".
Definition _wedges : ident := $"wedges".
Definition _whirlpools : ident := $"whirlpools".
Definition _width : ident := $"width".
Definition _wingFlutter : ident := $"wingFlutter".
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
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v_gAreaUpdateCounter := {|
  gvar_info := tushort;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCameraMovementFlags := {|
  gvar_info := tshort;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCamera := {|
  gvar_info := (tptr (Tstruct _Camera noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCutsceneFocus := {|
  gvar_info := (tptr (Tstruct _Object noattr));
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

Definition v_gSaveOptSelectIndex := {|
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

Definition v_gGlobalSoundSource := {|
  gvar_info := (tarray tfloat 3);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAudioRandom := {|
  gvar_info := tuint;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bhvEndToad := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvEndPeach := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBowserKeyUnlockDoor := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvBowserKeyCourseExit := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvStaticObject := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvSparkleSpawn := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvUnlockDoorStar := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvCelebrationStar := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_gSineTable := {|
  gvar_info := (tarray tfloat 0);
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

Definition v_gDialogResponse := {|
  gvar_info := tint;
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

Definition v_gMarioState := {|
  gvar_info := (tptr (Tstruct _MarioState noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gHudDisplay := {|
  gvar_info := (Tstruct _HudDisplay noattr);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gNeverEnteredCastle := {|
  gvar_info := tschar;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gPaintingMarioYEntry := {|
  gvar_info := tfloat;
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

Definition v_gLastCompletedCourseNum := {|
  gvar_info := tuchar;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gLastCompletedStarNum := {|
  gvar_info := tuchar;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sIntroWarpPipeObj := {|
  gvar_info := (tptr (Tstruct _Object noattr));
  gvar_init := (Init_space 8 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sEndPeachObj := {|
  gvar_info := (tptr (Tstruct _Object noattr));
  gvar_init := (Init_space 8 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sEndRightToadObj := {|
  gvar_info := (tptr (Tstruct _Object noattr));
  gvar_init := (Init_space 8 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sEndLeftToadObj := {|
  gvar_info := (tptr (Tstruct _Object noattr));
  gvar_init := (Init_space 8 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sEndJumboStarObj := {|
  gvar_info := (tptr (Tstruct _Object noattr));
  gvar_init := (Init_space 8 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sEndPeachAnimation := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sEndToadAnims := {|
  gvar_info := (tarray tshort 2);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sEndCutsceneVp := {|
  gvar_info := (Tunion __441 noattr);
  gvar_init := (Init_int16 (Int.repr 640) :: Init_int16 (Int.repr 480) ::
                Init_int16 (Int.repr 511) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 640) :: Init_int16 (Int.repr 480) ::
                Init_int16 (Int.repr 511) :: Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDispCreditsEntry := {|
  gvar_info := (tptr (Tstruct _CreditsEntry noattr));
  gvar_init := (Init_int64 (Int64.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_8032CBE4 := {|
  gvar_info := tschar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_8032CBE8 := {|
  gvar_info := tschar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_8032CBEC := {|
  gvar_info := (tarray tschar 7);
  gvar_init := (Init_int8 (Int.repr 2) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 2) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 2) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 2) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sStarsNeededForDialog := {|
  gvar_info := (tarray tuchar 6);
  gvar_init := (Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 8) :: Init_int8 (Int.repr 30) ::
                Init_int8 (Int.repr 50) :: Init_int8 (Int.repr 70) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sJumboStarKeyframes := {|
  gvar_info := (tarray (tarray tshort 4) 27);
  gvar_init := (Init_int16 (Int.repr 20) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 678) :: Init_int16 (Int.repr (-2916)) ::
                Init_int16 (Int.repr 30) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 680) :: Init_int16 (Int.repr (-3500)) ::
                Init_int16 (Int.repr 40) :: Init_int16 (Int.repr 1000) ::
                Init_int16 (Int.repr 700) :: Init_int16 (Int.repr (-4000)) ::
                Init_int16 (Int.repr 50) :: Init_int16 (Int.repr 2500) ::
                Init_int16 (Int.repr 750) :: Init_int16 (Int.repr (-3500)) ::
                Init_int16 (Int.repr 50) :: Init_int16 (Int.repr 3500) ::
                Init_int16 (Int.repr 800) :: Init_int16 (Int.repr (-2000)) ::
                Init_int16 (Int.repr 50) :: Init_int16 (Int.repr 4000) ::
                Init_int16 (Int.repr 850) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 50) :: Init_int16 (Int.repr 3500) ::
                Init_int16 (Int.repr 900) :: Init_int16 (Int.repr 2000) ::
                Init_int16 (Int.repr 50) :: Init_int16 (Int.repr 2000) ::
                Init_int16 (Int.repr 950) :: Init_int16 (Int.repr 3500) ::
                Init_int16 (Int.repr 50) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1000) :: Init_int16 (Int.repr 4000) ::
                Init_int16 (Int.repr 50) :: Init_int16 (Int.repr (-2000)) ::
                Init_int16 (Int.repr 1050) :: Init_int16 (Int.repr 3500) ::
                Init_int16 (Int.repr 50) :: Init_int16 (Int.repr (-3500)) ::
                Init_int16 (Int.repr 1100) :: Init_int16 (Int.repr 2000) ::
                Init_int16 (Int.repr 50) :: Init_int16 (Int.repr (-4000)) ::
                Init_int16 (Int.repr 1150) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 50) :: Init_int16 (Int.repr (-3500)) ::
                Init_int16 (Int.repr 1200) ::
                Init_int16 (Int.repr (-2000)) :: Init_int16 (Int.repr 50) ::
                Init_int16 (Int.repr (-2000)) ::
                Init_int16 (Int.repr 1250) ::
                Init_int16 (Int.repr (-3500)) :: Init_int16 (Int.repr 50) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 1300) ::
                Init_int16 (Int.repr (-4000)) :: Init_int16 (Int.repr 50) ::
                Init_int16 (Int.repr 2000) :: Init_int16 (Int.repr 1350) ::
                Init_int16 (Int.repr (-3500)) :: Init_int16 (Int.repr 50) ::
                Init_int16 (Int.repr 3500) :: Init_int16 (Int.repr 1400) ::
                Init_int16 (Int.repr (-2000)) :: Init_int16 (Int.repr 50) ::
                Init_int16 (Int.repr 4000) :: Init_int16 (Int.repr 1450) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 50) ::
                Init_int16 (Int.repr 3500) :: Init_int16 (Int.repr 1500) ::
                Init_int16 (Int.repr 2000) :: Init_int16 (Int.repr 50) ::
                Init_int16 (Int.repr 2000) :: Init_int16 (Int.repr 1600) ::
                Init_int16 (Int.repr 3500) :: Init_int16 (Int.repr 50) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 1700) ::
                Init_int16 (Int.repr 4000) :: Init_int16 (Int.repr 50) ::
                Init_int16 (Int.repr (-2000)) ::
                Init_int16 (Int.repr 1800) :: Init_int16 (Int.repr 3500) ::
                Init_int16 (Int.repr 50) :: Init_int16 (Int.repr (-3500)) ::
                Init_int16 (Int.repr 1900) :: Init_int16 (Int.repr 2000) ::
                Init_int16 (Int.repr 30) :: Init_int16 (Int.repr (-4000)) ::
                Init_int16 (Int.repr 2000) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr (-3500)) ::
                Init_int16 (Int.repr 2100) ::
                Init_int16 (Int.repr (-2000)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr (-2000)) ::
                Init_int16 (Int.repr 2200) ::
                Init_int16 (Int.repr (-3500)) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 2300) ::
                Init_int16 (Int.repr (-4000)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_get_credits_str_width := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_str, (tptr tschar)) :: nil);
  fn_vars := nil;
  fn_temps := ((_c, tuint) :: (_length, tint) :: (_t'3, tint) ::
               (_t'2, tuint) :: (_t'1, (tptr tschar)) :: (_t'4, tschar) ::
               nil);
  fn_body :=
(Ssequence
  (Sset _length (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sloop
      (Ssequence
        (Ssequence
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'1 (Etempvar _str (tptr tschar)))
                (Sset _str
                  (Ebinop Oadd (Etempvar _t'1 (tptr tschar))
                    (Econst_int (Int.repr 1) tint) (tptr tschar))))
              (Ssequence
                (Sset _t'4 (Ederef (Etempvar _t'1 (tptr tschar)) tschar))
                (Sset _t'2 (Ecast (Etempvar _t'4 tschar) tuint))))
            (Sset _c (Etempvar _t'2 tuint)))
          (Sifthenelse (Ebinop One (Etempvar _t'2 tuint)
                         (Econst_int (Int.repr 0) tint) tint)
            Sskip
            Sbreak))
        (Ssequence
          (Sifthenelse (Ebinop Oeq (Etempvar _c tuint)
                         (Econst_int (Int.repr 32) tint) tint)
            (Sset _t'3 (Ecast (Econst_int (Int.repr 4) tint) tint))
            (Sset _t'3 (Ecast (Econst_int (Int.repr 7) tint) tint)))
          (Sset _length
            (Ebinop Oadd (Etempvar _length tint) (Etempvar _t'3 tint) tint))))
      Sskip)
    (Sreturn (Some (Etempvar _length tint)))))
|}.

Definition f_print_displaying_credits_entry := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_currStrPtr, (tptr (tptr tschar))) ::
               (_titleStr, (tptr tschar)) :: (_numLines, tshort) ::
               (_strY, tshort) :: (_lineHeight, tshort) :: (_t'7, tint) ::
               (_t'6, tshort) :: (_t'5, (tptr (tptr tschar))) ::
               (_t'4, (tptr (tptr tschar))) :: (_t'3, tint) ::
               (_t'2, (tptr tschar)) :: (_t'1, (tptr (tptr tschar))) ::
               (_t'17, (tptr (tptr tschar))) ::
               (_t'16, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'15, tschar) :: (_t'14, tuchar) ::
               (_t'13, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'12, (tptr tschar)) :: (_t'11, (tptr tschar)) ::
               (_t'10, (tptr tschar)) :: (_t'9, (tptr tschar)) ::
               (_t'8, (tptr (Tstruct _CreditsEntry noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'8 (Evar _sDispCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
  (Sifthenelse (Ebinop One
                 (Etempvar _t'8 (tptr (Tstruct _CreditsEntry noattr)))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Ssequence
        (Sset _t'16
          (Evar _sDispCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
        (Ssequence
          (Sset _t'17
            (Efield
              (Ederef (Etempvar _t'16 (tptr (Tstruct _CreditsEntry noattr)))
                (Tstruct _CreditsEntry noattr)) _unk0C (tptr (tptr tschar))))
          (Sset _currStrPtr
            (Ecast (Etempvar _t'17 (tptr (tptr tschar)))
              (tptr (tptr tschar))))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'1 (Etempvar _currStrPtr (tptr (tptr tschar))))
            (Sset _currStrPtr
              (Ebinop Oadd (Etempvar _t'1 (tptr (tptr tschar)))
                (Econst_int (Int.repr 1) tint) (tptr (tptr tschar)))))
          (Sset _titleStr
            (Ederef (Etempvar _t'1 (tptr (tptr tschar))) (tptr tschar))))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'2 (Etempvar _titleStr (tptr tschar)))
              (Sset _titleStr
                (Ebinop Oadd (Etempvar _t'2 (tptr tschar))
                  (Econst_int (Int.repr 1) tint) (tptr tschar))))
            (Ssequence
              (Sset _t'15 (Ederef (Etempvar _t'2 (tptr tschar)) tschar))
              (Sset _numLines
                (Ecast
                  (Ebinop Osub (Etempvar _t'15 tschar)
                    (Econst_int (Int.repr 48) tint) tint) tshort))))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'13
                  (Evar _sDispCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
                (Ssequence
                  (Sset _t'14
                    (Efield
                      (Ederef
                        (Etempvar _t'13 (tptr (Tstruct _CreditsEntry noattr)))
                        (Tstruct _CreditsEntry noattr)) _unk02 tuchar))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'14 tuchar)
                                 (Econst_int (Int.repr 32) tint) tint)
                    (Sset _t'3 (Ecast (Econst_int (Int.repr 28) tint) tint))
                    (Sset _t'3 (Ecast (Econst_int (Int.repr 172) tint) tint)))))
              (Sset _strY
                (Ecast
                  (Ebinop Oadd (Etempvar _t'3 tint)
                    (Ebinop Omul
                      (Ebinop Oeq (Etempvar _numLines tshort)
                        (Econst_int (Int.repr 1) tint) tint)
                      (Econst_int (Int.repr 16) tint) tint) tint) tshort)))
            (Ssequence
              (Sset _lineHeight
                (Ecast (Econst_int (Int.repr 16) tint) tshort))
              (Ssequence
                (Scall None
                  (Evar _dl_rgba16_begin_cutscene_msg_fade (Tfunction nil
                                                             tvoid
                                                             cc_default))
                  nil)
                (Ssequence
                  (Scall None
                    (Evar _print_credits_str_ascii (Tfunction
                                                     (tshort :: tshort ::
                                                      (tptr tschar) :: nil)
                                                     tvoid cc_default))
                    ((Ecast
                       (Ebinop Omul
                         (Ebinop Odiv
                           (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 1077936128)) tfloat)
                           tfloat) (Econst_int (Int.repr 21) tint) tfloat)
                       tint) :: (Etempvar _strY tshort) ::
                     (Etempvar _titleStr (tptr tschar)) :: nil))
                  (Ssequence
                    (Sswitch (Etempvar _numLines tshort)
                      (LScons (Some 4)
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Sset _t'4
                                (Etempvar _currStrPtr (tptr (tptr tschar))))
                              (Sset _currStrPtr
                                (Ebinop Oadd
                                  (Etempvar _t'4 (tptr (tptr tschar)))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr (tptr tschar)))))
                            (Ssequence
                              (Sset _t'12
                                (Ederef (Etempvar _t'4 (tptr (tptr tschar)))
                                  (tptr tschar)))
                              (Scall None
                                (Evar _print_credits_str_ascii (Tfunction
                                                                 (tshort ::
                                                                  tshort ::
                                                                  (tptr tschar) ::
                                                                  nil) tvoid
                                                                 cc_default))
                                ((Ecast
                                   (Ebinop Omul
                                     (Ebinop Odiv
                                       (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                       (Econst_single (Float32.of_bits (Int.repr 1077936128)) tfloat)
                                       tfloat)
                                     (Econst_int (Int.repr 21) tint) tfloat)
                                   tint) ::
                                 (Ebinop Oadd (Etempvar _strY tshort)
                                   (Econst_int (Int.repr 24) tint) tint) ::
                                 (Etempvar _t'12 (tptr tschar)) :: nil))))
                          (Ssequence
                            (Sset _numLines
                              (Ecast (Econst_int (Int.repr 2) tint) tshort))
                            (Ssequence
                              (Sset _lineHeight
                                (Ecast (Econst_int (Int.repr 24) tint)
                                  tshort))
                              Sbreak)))
                        (LScons (Some 5)
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Sset _t'5
                                  (Etempvar _currStrPtr (tptr (tptr tschar))))
                                (Sset _currStrPtr
                                  (Ebinop Oadd
                                    (Etempvar _t'5 (tptr (tptr tschar)))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr (tptr tschar)))))
                              (Ssequence
                                (Sset _t'11
                                  (Ederef
                                    (Etempvar _t'5 (tptr (tptr tschar)))
                                    (tptr tschar)))
                                (Scall None
                                  (Evar _print_credits_str_ascii (Tfunction
                                                                   (tshort ::
                                                                    tshort ::
                                                                    (tptr tschar) ::
                                                                    nil)
                                                                   tvoid
                                                                   cc_default))
                                  ((Ecast
                                     (Ebinop Omul
                                       (Ebinop Odiv
                                         (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                         (Econst_single (Float32.of_bits (Int.repr 1077936128)) tfloat)
                                         tfloat)
                                       (Econst_int (Int.repr 21) tint)
                                       tfloat) tint) ::
                                   (Ebinop Oadd (Etempvar _strY tshort)
                                     (Econst_int (Int.repr 16) tint) tint) ::
                                   (Etempvar _t'11 (tptr tschar)) :: nil))))
                            (Ssequence
                              (Sset _numLines
                                (Ecast (Econst_int (Int.repr 3) tint) tshort))
                              Sbreak))
                          LSnil)))
                    (Ssequence
                      (Sloop
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Sset _t'6 (Etempvar _numLines tshort))
                              (Sset _numLines
                                (Ecast
                                  (Ebinop Osub (Etempvar _t'6 tshort)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tshort)))
                            (Sifthenelse (Ebinop Ogt (Etempvar _t'6 tshort)
                                           (Econst_int (Int.repr 0) tint)
                                           tint)
                              Sskip
                              Sbreak))
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Sset _t'10
                                  (Ederef
                                    (Etempvar _currStrPtr (tptr (tptr tschar)))
                                    (tptr tschar)))
                                (Scall (Some _t'7)
                                  (Evar _get_credits_str_width (Tfunction
                                                                 ((tptr tschar) ::
                                                                  nil) tint
                                                                 cc_default))
                                  ((Etempvar _t'10 (tptr tschar)) :: nil)))
                              (Ssequence
                                (Sset _t'9
                                  (Ederef
                                    (Etempvar _currStrPtr (tptr (tptr tschar)))
                                    (tptr tschar)))
                                (Scall None
                                  (Evar _print_credits_str_ascii (Tfunction
                                                                   (tshort ::
                                                                    tshort ::
                                                                    (tptr tschar) ::
                                                                    nil)
                                                                   tvoid
                                                                   cc_default))
                                  ((Ebinop Osub
                                     (Ebinop Osub
                                       (Econst_int (Int.repr 320) tint)
                                       (Ecast
                                         (Ebinop Omul
                                           (Ebinop Odiv
                                             (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                             (Econst_single (Float32.of_bits (Int.repr 1077936128)) tfloat)
                                             tfloat)
                                           (Econst_int (Int.repr 21) tint)
                                           tfloat) tint) tint)
                                     (Etempvar _t'7 tint) tint) ::
                                   (Etempvar _strY tshort) ::
                                   (Etempvar _t'9 (tptr tschar)) :: nil))))
                            (Ssequence
                              (Sset _strY
                                (Ecast
                                  (Ebinop Oadd (Etempvar _strY tshort)
                                    (Etempvar _lineHeight tshort) tint)
                                  tshort))
                              (Sset _currStrPtr
                                (Ebinop Oadd
                                  (Etempvar _currStrPtr (tptr (tptr tschar)))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr (tptr tschar)))))))
                        Sskip)
                      (Ssequence
                        (Scall None
                          (Evar _dl_rgba16_stop_cutscene_msg_fade (Tfunction
                                                                    nil tvoid
                                                                    cc_default))
                          nil)
                        (Sassign
                          (Evar _sDispCreditsEntry (tptr (Tstruct _CreditsEntry noattr)))
                          (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))))))))))))
    Sskip))
|}.

Definition f_bhv_end_peach_loop := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'8, tshort) :: (_t'7, tshort) :: (_t'6, tshort) ::
               (_t'5, tshort) :: (_t'4, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8 (Evar _sEndPeachAnimation tshort))
    (Scall None
      (Evar _cur_obj_init_animation_with_sound (Tfunction (tint :: nil) tvoid
                                                 cc_default))
      ((Etempvar _t'8 tshort) :: nil)))
  (Ssequence
    (Scall (Some _t'3)
      (Evar _cur_obj_check_if_near_animation_end (Tfunction nil tint
                                                   cc_default)) nil)
    (Sifthenelse (Etempvar _t'3 tint)
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'6 (Evar _sEndPeachAnimation tshort))
            (Sifthenelse (Ebinop Olt (Etempvar _t'6 tshort)
                           (Econst_int (Int.repr 3) tint) tint)
              (Sset _t'1 (Econst_int (Int.repr 1) tint))
              (Ssequence
                (Sset _t'7 (Evar _sEndPeachAnimation tshort))
                (Sset _t'1
                  (Ecast
                    (Ebinop Oeq (Etempvar _t'7 tshort)
                      (Econst_int (Int.repr 6) tint) tint) tbool)))))
          (Sifthenelse (Etempvar _t'1 tint)
            (Sset _t'2 (Econst_int (Int.repr 1) tint))
            (Ssequence
              (Sset _t'5 (Evar _sEndPeachAnimation tshort))
              (Sset _t'2
                (Ecast
                  (Ebinop Oeq (Etempvar _t'5 tshort)
                    (Econst_int (Int.repr 7) tint) tint) tbool)))))
        (Sifthenelse (Etempvar _t'2 tint)
          (Ssequence
            (Sset _t'4 (Evar _sEndPeachAnimation tshort))
            (Sassign (Evar _sEndPeachAnimation tshort)
              (Ebinop Oadd (Etempvar _t'4 tshort)
                (Econst_int (Int.repr 1) tint) tint)))
          Sskip))
      Sskip)))
|}.

Definition f_bhv_end_toad_loop := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_toadAnimIndex, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'8, tfloat) :: (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, tshort) :: (_t'5, tshort) :: (_t'4, tshort) ::
               (_t'3, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'8
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __729 noattr))
              _asF32 (tarray tfloat 80))
            (Ebinop Oadd (Econst_int (Int.repr 6) tint)
              (Econst_int (Int.repr 0) tint) tint) (tptr tfloat)) tfloat))
      (Sset _toadAnimIndex
        (Ebinop Oge (Etempvar _t'8 tfloat)
          (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) tint))))
  (Ssequence
    (Ssequence
      (Sset _t'6
        (Ederef
          (Ebinop Oadd (Evar _sEndToadAnims (tarray tshort 2))
            (Etempvar _toadAnimIndex tint) (tptr tshort)) tshort))
      (Scall None
        (Evar _cur_obj_init_animation_with_sound (Tfunction (tint :: nil)
                                                   tvoid cc_default))
        ((Etempvar _t'6 tshort) :: nil)))
    (Ssequence
      (Scall (Some _t'2)
        (Evar _cur_obj_check_if_near_animation_end (Tfunction nil tint
                                                     cc_default)) nil)
      (Sifthenelse (Etempvar _t'2 tint)
        (Ssequence
          (Ssequence
            (Sset _t'4
              (Ederef
                (Ebinop Oadd (Evar _sEndToadAnims (tarray tshort 2))
                  (Etempvar _toadAnimIndex tint) (tptr tshort)) tshort))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tshort)
                           (Econst_int (Int.repr 0) tint) tint)
              (Sset _t'1 (Econst_int (Int.repr 1) tint))
              (Ssequence
                (Sset _t'5
                  (Ederef
                    (Ebinop Oadd (Evar _sEndToadAnims (tarray tshort 2))
                      (Etempvar _toadAnimIndex tint) (tptr tshort)) tshort))
                (Sset _t'1
                  (Ecast
                    (Ebinop Oeq (Etempvar _t'5 tshort)
                      (Econst_int (Int.repr 2) tint) tint) tbool)))))
          (Sifthenelse (Etempvar _t'1 tint)
            (Ssequence
              (Sset _t'3
                (Ederef
                  (Ebinop Oadd (Evar _sEndToadAnims (tarray tshort 2))
                    (Etempvar _toadAnimIndex tint) (tptr tshort)) tshort))
              (Sassign
                (Ederef
                  (Ebinop Oadd (Evar _sEndToadAnims (tarray tshort 2))
                    (Etempvar _toadAnimIndex tint) (tptr tshort)) tshort)
                (Ebinop Oadd (Etempvar _t'3 tshort)
                  (Econst_int (Int.repr 1) tint) tint)))
            Sskip))
        Sskip))))
|}.

Definition f_geo_switch_peach_eyes := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_run, tint) ::
                (_node, (tptr (Tstruct _GraphNode noattr))) :: (_a2, tint) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_switchCase, (tptr (Tstruct _GraphNodeSwitchCase noattr))) ::
               (_timer, tshort) :: (_t'7, tushort) :: (_t'6, tschar) ::
               (_t'5, tschar) :: (_t'4, tschar) :: (_t'3, tschar) ::
               (_t'2, tschar) :: (_t'1, tschar) :: nil);
  fn_body :=
(Ssequence
  (Sset _switchCase
    (Ecast (Etempvar _node (tptr (Tstruct _GraphNode noattr)))
      (tptr (Tstruct _GraphNodeSwitchCase noattr))))
  (Ssequence
    (Sifthenelse (Ebinop Oeq (Etempvar _run tint)
                   (Econst_int (Int.repr 1) tint) tint)
      (Ssequence
        (Sset _t'1 (Evar _D_8032CBE4 tschar))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tschar)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'7 (Evar _gAreaUpdateCounter tushort))
              (Sset _timer
                (Ecast
                  (Ebinop Oand
                    (Ebinop Oshr
                      (Ebinop Oadd (Etempvar _t'7 tushort)
                        (Econst_int (Int.repr 32) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint)
                    (Econst_int (Int.repr 31) tint) tint) tshort)))
            (Sifthenelse (Ebinop Olt (Etempvar _timer tshort)
                           (Econst_int (Int.repr 7) tint) tint)
              (Ssequence
                (Sset _t'5 (Evar _D_8032CBE8 tschar))
                (Ssequence
                  (Sset _t'6
                    (Ederef
                      (Ebinop Oadd (Evar _D_8032CBEC (tarray tschar 7))
                        (Etempvar _timer tshort) (tptr tschar)) tschar))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _switchCase (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                        (Tstruct _GraphNodeSwitchCase noattr)) _selectedCase
                      tshort)
                    (Ebinop Oadd
                      (Ebinop Omul (Etempvar _t'5 tschar)
                        (Econst_int (Int.repr 4) tint) tint)
                      (Etempvar _t'6 tschar) tint))))
              (Ssequence
                (Sset _t'4 (Evar _D_8032CBE8 tschar))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _switchCase (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                      (Tstruct _GraphNodeSwitchCase noattr)) _selectedCase
                    tshort)
                  (Ebinop Oadd
                    (Ebinop Omul (Etempvar _t'4 tschar)
                      (Econst_int (Int.repr 4) tint) tint)
                    (Econst_int (Int.repr 1) tint) tint)))))
          (Ssequence
            (Sset _t'2 (Evar _D_8032CBE8 tschar))
            (Ssequence
              (Sset _t'3 (Evar _D_8032CBE4 tschar))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _switchCase (tptr (Tstruct _GraphNodeSwitchCase noattr)))
                    (Tstruct _GraphNodeSwitchCase noattr)) _selectedCase
                  tshort)
                (Ebinop Osub
                  (Ebinop Oadd
                    (Ebinop Omul (Etempvar _t'2 tschar)
                      (Econst_int (Int.repr 4) tint) tint)
                    (Etempvar _t'3 tschar) tint)
                  (Econst_int (Int.repr 1) tint) tint))))))
      Sskip)
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_get_star_collection_dialog := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_dialogID, tint) ::
               (_numStarsRequired, tint) :: (_t'1, tint) :: (_t'4, tshort) ::
               (_t'3, tshort) :: (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _dialogID (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Sset _i (Econst_int (Int.repr 0) tint))
      (Sloop
        (Ssequence
          (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                         (Ecast
                           (Ebinop Odiv (Esizeof (tarray tuchar 6) tulong)
                             (Esizeof tuchar tulong) tulong) tint) tint)
            Sskip
            Sbreak)
          (Ssequence
            (Sset _numStarsRequired
              (Ederef
                (Ebinop Oadd (Evar _sStarsNeededForDialog (tarray tuchar 6))
                  (Etempvar _i tint) (tptr tuchar)) tuchar))
            (Ssequence
              (Ssequence
                (Sset _t'3
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _prevNumStarsForDialog
                    tshort))
                (Sifthenelse (Ebinop Olt (Etempvar _t'3 tshort)
                               (Etempvar _numStarsRequired tint) tint)
                  (Ssequence
                    (Sset _t'4
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _numStars tshort))
                    (Sset _t'1
                      (Ecast
                        (Ebinop Oge (Etempvar _t'4 tshort)
                          (Etempvar _numStarsRequired tint) tint) tbool)))
                  (Sset _t'1 (Econst_int (Int.repr 0) tint))))
              (Sifthenelse (Etempvar _t'1 tint)
                (Ssequence
                  (Sset _dialogID
                    (Ebinop Oadd (Etempvar _i tint)
                      (Econst_int (Int.repr 141) tint) tint))
                  Sbreak)
                Sskip))))
        (Sset _i
          (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint)
            tint))))
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _numStars tshort))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _prevNumStarsForDialog tshort)
          (Etempvar _t'2 tshort)))
      (Sreturn (Some (Etempvar _dialogID tint))))))
|}.

Definition f_handle_save_menu := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_dialogID, tint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'11, tshort) ::
               (_t'10, tshort) :: (_t'9, tshort) :: (_t'8, tshort) ::
               (_t'7, tshort) :: (_t'6, tshort) :: (_t'5, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'3)
      (Evar _is_anim_past_end (Tfunction
                                ((tptr (Tstruct _MarioState noattr)) :: nil)
                                tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Sifthenelse (Etempvar _t'3 tint)
      (Ssequence
        (Sset _t'11 (Evar _gSaveOptSelectIndex tshort))
        (Sset _t'4
          (Ecast
            (Ebinop One (Etempvar _t'11 tshort)
              (Econst_int (Int.repr 0) tint) tint) tbool)))
      (Sset _t'4 (Econst_int (Int.repr 0) tint))))
  (Sifthenelse (Etempvar _t'4 tint)
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'9 (Evar _gSaveOptSelectIndex tshort))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tshort)
                         (Econst_int (Int.repr 1) tint) tint)
            (Sset _t'1 (Econst_int (Int.repr 1) tint))
            (Ssequence
              (Sset _t'10 (Evar _gSaveOptSelectIndex tshort))
              (Sset _t'1
                (Ecast
                  (Ebinop Oeq (Etempvar _t'10 tshort)
                    (Econst_int (Int.repr 2) tint) tint) tbool)))))
        (Sifthenelse (Etempvar _t'1 tint)
          (Ssequence
            (Ssequence
              (Sset _t'8 (Evar _gCurrSaveFileNum tshort))
              (Scall None
                (Evar _save_file_do_save (Tfunction (tint :: nil) tvoid
                                           cc_default))
                ((Ebinop Osub (Etempvar _t'8 tshort)
                   (Econst_int (Int.repr 1) tint) tint) :: nil)))
            (Ssequence
              (Sset _t'7 (Evar _gSaveOptSelectIndex tshort))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'7 tshort)
                             (Econst_int (Int.repr 2) tint) tint)
                (Scall None
                  (Evar _fade_into_special_warp (Tfunction
                                                  (tuint :: tuint :: nil)
                                                  tvoid cc_default))
                  ((Eunop Oneg (Econst_int (Int.repr 2) tint) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                Sskip)))
          Sskip))
      (Ssequence
        (Sset _t'5 (Evar _gSaveOptSelectIndex tshort))
        (Sifthenelse (Ebinop One (Etempvar _t'5 tshort)
                       (Econst_int (Int.repr 2) tint) tint)
          (Ssequence
            (Scall None
              (Evar _disable_time_stop (Tfunction nil tvoid cc_default)) nil)
            (Ssequence
              (Ssequence
                (Sset _t'6
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _faceAngle
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
                  (Ebinop Oadd (Etempvar _t'6 tshort)
                    (Econst_int (Int.repr 32768) tint) tint)))
              (Ssequence
                (Ssequence
                  (Scall (Some _t'2)
                    (Evar _get_star_collection_dialog (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tint
                                                        cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Sset _dialogID (Etempvar _t'2 tint)))
                (Sifthenelse (Etempvar _dialogID tint)
                  (Ssequence
                    (Scall None
                      (Evar _play_peachs_jingle (Tfunction nil tvoid
                                                  cc_default)) nil)
                    (Scall None
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 536875781) tint) ::
                       (Etempvar _dialogID tint) :: nil)))
                  (Scall None
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 205521409) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))))))
          Sskip)))
    Sskip))
|}.

Definition f_spawn_obj_at_mario_rel_yaw := {|
  fn_return := (tptr (Tstruct _Object noattr));
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_model, tint) :: (_behavior, (tptr tuint)) ::
                (_relYaw, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_o, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr (Tstruct _Object noattr))) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tshort) ::
               (_t'4, tfloat) :: (_t'3, tfloat) :: (_t'2, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'6
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioObj
          (tptr (Tstruct _Object noattr))))
      (Scall (Some _t'1)
        (Evar _spawn_object (Tfunction
                              ((tptr (Tstruct _Object noattr)) :: tint ::
                               (tptr tuint) :: nil)
                              (tptr (Tstruct _Object noattr)) cc_default))
        ((Etempvar _t'6 (tptr (Tstruct _Object noattr))) ::
         (Etempvar _model tint) :: (Etempvar _behavior (tptr tuint)) :: nil)))
    (Sset _o (Etempvar _t'1 (tptr (Tstruct _Object noattr)))))
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
            (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __729 noattr))
              _asS32 (tarray tint 80))
            (Ebinop Oadd (Econst_int (Int.repr 18) tint)
              (Econst_int (Int.repr 1) tint) tint) (tptr tint)) tint)
        (Ebinop Oadd (Etempvar _t'5 tshort) (Etempvar _relYaw tshort) tint)))
    (Ssequence
      (Ssequence
        (Sset _t'4
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __729 noattr))
                _asF32 (tarray tfloat 80))
              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                (Econst_int (Int.repr 0) tint) tint) (tptr tfloat)) tfloat)
          (Etempvar _t'4 tfloat)))
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __729 noattr)) _asF32 (tarray tfloat 80))
                (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                  (Econst_int (Int.repr 1) tint) tint) (tptr tfloat)) tfloat)
            (Etempvar _t'3 tfloat)))
        (Ssequence
          (Ssequence
            (Sset _t'2
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __729 noattr)) _asF32 (tarray tfloat 80))
                  (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                    (Econst_int (Int.repr 2) tint) tint) (tptr tfloat))
                tfloat) (Etempvar _t'2 tfloat)))
          (Sreturn (Some (Etempvar _o (tptr (Tstruct _Object noattr))))))))))
|}.

Definition f_cutscene_take_cap_off := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tuint) :: (_t'2, tuint) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sassign
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint)
      (Ebinop Oand (Etempvar _t'3 tuint)
        (Eunop Onotint (Econst_int (Int.repr 16) tint) tint) tuint)))
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _flags tuint))
      (Sassign
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _flags tuint)
        (Ebinop Oor (Etempvar _t'2 tuint) (Econst_int (Int.repr 32) tint)
          tuint)))
    (Ssequence
      (Sset _t'1
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioObj
          (tptr (Tstruct _Object noattr))))
      (Scall None
        (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                            cc_default))
        ((Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                   (Econst_int (Int.repr 28) tint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 61) tint) tuint)
                   (Econst_int (Int.repr 16) tint) tuint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                 (Econst_int (Int.repr 8) tint) tuint) tuint)
             (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
               (Econst_int (Int.repr 128) tint) tint) tuint)
           (Econst_int (Int.repr 1) tint) tuint) ::
         (Efield
           (Efield
             (Efield
               (Ederef (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
                 (Tstruct _Object noattr)) _header
               (Tstruct _ObjectNode noattr)) _gfx
             (Tstruct _GraphNodeObject noattr)) _cameraToObject
           (tarray tfloat 3)) :: nil)))))
|}.

Definition f_cutscene_put_cap_on := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tuint) :: (_t'2, tuint) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sassign
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint)
      (Ebinop Oand (Etempvar _t'3 tuint)
        (Eunop Onotint (Econst_int (Int.repr 32) tint) tint) tuint)))
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _flags tuint))
      (Sassign
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _flags tuint)
        (Ebinop Oor (Etempvar _t'2 tuint) (Econst_int (Int.repr 16) tint)
          tuint)))
    (Ssequence
      (Sset _t'1
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioObj
          (tptr (Tstruct _Object noattr))))
      (Scall None
        (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                            cc_default))
        ((Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                   (Econst_int (Int.repr 28) tint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 62) tint) tuint)
                   (Econst_int (Int.repr 16) tint) tuint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                 (Econst_int (Int.repr 8) tint) tuint) tuint)
             (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
               (Econst_int (Int.repr 128) tint) tint) tuint)
           (Econst_int (Int.repr 1) tint) tuint) ::
         (Efield
           (Efield
             (Efield
               (Ederef (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
                 (Tstruct _Object noattr)) _header
               (Tstruct _ObjectNode noattr)) _gfx
             (Tstruct _GraphNodeObject noattr)) _cameraToObject
           (tarray tfloat 3)) :: nil)))))
|}.

Definition f_mario_ready_to_speak := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_actionGroup, tuint) :: (_isReadyToSpeak, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'11, tuint) ::
               (_t'10, (tptr (Tstruct _MarioState noattr))) ::
               (_t'9, tuint) ::
               (_t'8, (tptr (Tstruct _MarioState noattr))) ::
               (_t'7, tuint) ::
               (_t'6, (tptr (Tstruct _MarioState noattr))) ::
               (_t'5, tuint) ::
               (_t'4, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'10 (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
    (Ssequence
      (Sset _t'11
        (Efield
          (Ederef (Etempvar _t'10 (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _action tuint))
      (Sset _actionGroup
        (Ebinop Oand (Etempvar _t'11 tuint) (Econst_int (Int.repr 448) tint)
          tuint))))
  (Ssequence
    (Sset _isReadyToSpeak (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'8
                (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
              (Ssequence
                (Sset _t'9
                  (Efield
                    (Ederef
                      (Etempvar _t'8 (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _action tuint))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tuint)
                               (Econst_int (Int.repr 4874) tint) tint)
                  (Sset _t'1 (Econst_int (Int.repr 1) tint))
                  (Sset _t'1
                    (Ecast
                      (Ebinop Oeq (Etempvar _actionGroup tuint)
                        (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                          (Econst_int (Int.repr 6) tint) tint) tint) tbool)))))
            (Sifthenelse (Etempvar _t'1 tint)
              (Sset _t'2 (Econst_int (Int.repr 1) tint))
              (Sset _t'2
                (Ecast
                  (Ebinop Oeq (Etempvar _actionGroup tuint)
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 6) tint) tint) tint) tbool))))
          (Sifthenelse (Etempvar _t'2 tint)
            (Ssequence
              (Sset _t'4
                (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef
                      (Etempvar _t'4 (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _action tuint))
                (Sifthenelse (Eunop Onotbool
                               (Ebinop Oand (Etempvar _t'5 tuint)
                                 (Ebinop Oor
                                   (Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 16) tint) tint)
                                   (Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 17) tint) tint)
                                   tint) tuint) tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'6
                        (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                      (Ssequence
                        (Sset _t'7
                          (Efield
                            (Ederef
                              (Etempvar _t'6 (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _action tuint))
                        (Sset _t'3
                          (Ecast
                            (Ebinop One (Etempvar _t'7 tuint)
                              (Econst_int (Int.repr 201327143) tint) tint)
                            tbool))))
                    (Sset _t'3 (Ecast (Etempvar _t'3 tint) tbool)))
                  (Sset _t'3 (Ecast (Econst_int (Int.repr 0) tint) tbool)))))
            (Sset _t'3 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'3 tint)
          (Sset _isReadyToSpeak (Econst_int (Int.repr 1) tint))
          Sskip))
      (Sreturn (Some (Etempvar _isReadyToSpeak tint))))))
|}.

Definition f_set_mario_npc_dialog := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_actionArg, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_dialogState, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'14, tushort) ::
               (_t'13, (tptr (Tstruct _MarioState noattr))) ::
               (_t'12, tushort) ::
               (_t'11, (tptr (Tstruct _MarioState noattr))) ::
               (_t'10, (tptr (Tstruct _MarioState noattr))) ::
               (_t'9, tushort) ::
               (_t'8, (tptr (Tstruct _MarioState noattr))) ::
               (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, (tptr (Tstruct _MarioState noattr))) ::
               (_t'5, (tptr (Tstruct _MarioState noattr))) ::
               (_t'4, tuint) ::
               (_t'3, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _dialogState (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Sset _t'3 (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef (Etempvar _t'3 (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _action tuint))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tuint)
                       (Econst_int (Int.repr 536875782) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'13
                (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
              (Ssequence
                (Sset _t'14
                  (Efield
                    (Ederef
                      (Etempvar _t'13 (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionState tushort))
                (Sifthenelse (Ebinop Olt (Etempvar _t'14 tushort)
                               (Econst_int (Int.repr 8) tint) tint)
                  (Sset _dialogState (Econst_int (Int.repr 1) tint))
                  Sskip)))
            (Ssequence
              (Sset _t'8
                (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
              (Ssequence
                (Sset _t'9
                  (Efield
                    (Ederef
                      (Etempvar _t'8 (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionState tushort))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tushort)
                               (Econst_int (Int.repr 8) tint) tint)
                  (Sifthenelse (Ebinop Oeq (Etempvar _actionArg tint)
                                 (Econst_int (Int.repr 0) tint) tint)
                    (Ssequence
                      (Sset _t'10
                        (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                      (Ssequence
                        (Sset _t'11
                          (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                        (Ssequence
                          (Sset _t'12
                            (Efield
                              (Ederef
                                (Etempvar _t'11 (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _actionState
                              tushort))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _t'10 (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _actionState
                              tushort)
                            (Ebinop Oadd (Etempvar _t'12 tushort)
                              (Econst_int (Int.repr 1) tint) tint)))))
                    (Sset _dialogState (Econst_int (Int.repr 2) tint)))
                  Sskip))))
          (Ssequence
            (Sifthenelse (Ebinop One (Etempvar _actionArg tint)
                           (Econst_int (Int.repr 0) tint) tint)
              (Ssequence
                (Scall (Some _t'2)
                  (Evar _mario_ready_to_speak (Tfunction nil tint cc_default))
                  nil)
                (Sset _t'1 (Ecast (Etempvar _t'2 tint) tbool)))
              (Sset _t'1 (Econst_int (Int.repr 0) tint)))
            (Sifthenelse (Etempvar _t'1 tint)
              (Ssequence
                (Ssequence
                  (Sset _t'6
                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                  (Ssequence
                    (Sset _t'7
                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _t'6 (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _usedObj
                        (tptr (Tstruct _Object noattr)))
                      (Etempvar _t'7 (tptr (Tstruct _Object noattr))))))
                (Ssequence
                  (Ssequence
                    (Sset _t'5
                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                    (Scall None
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _t'5 (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 536875782) tint) ::
                       (Etempvar _actionArg tint) :: nil)))
                  (Sset _dialogState (Econst_int (Int.repr 1) tint))))
              Sskip)))))
    (Sreturn (Some (Etempvar _dialogState tint)))))
|}.

Definition f_act_reading_npc_dialog := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_headTurnAmount, tint) :: (_angleToNPC, tshort) ::
               (_t'5, tint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tshort) :: (_t'25, tuint) ::
               (_t'24, tuint) :: (_t'23, (tptr (Tstruct _Object noattr))) ::
               (_t'22, tshort) :: (_t'21, tushort) ::
               (_t'20, (tptr (Tstruct _Object noattr))) ::
               (_t'19, tushort) :: (_t'18, tushort) :: (_t'17, tushort) ::
               (_t'16, (tptr (Tstruct _Object noattr))) :: (_t'15, tuint) ::
               (_t'14, tushort) :: (_t'13, tushort) ::
               (_t'12, (tptr (Tstruct _Object noattr))) :: (_t'11, tshort) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tushort) ::
               (_t'8, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'7, tushort) :: (_t'6, tushort) :: nil);
  fn_body :=
(Ssequence
  (Sset _headTurnAmount (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Sset _t'25
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionArg tuint))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'25 tuint)
                     (Econst_int (Int.repr 2) tint) tint)
        (Sset _headTurnAmount
          (Eunop Oneg (Econst_int (Int.repr 1024) tint) tint))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'24
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionArg tuint))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'24 tuint)
                       (Econst_int (Int.repr 3) tint) tint)
          (Sset _headTurnAmount (Econst_int (Int.repr 384) tint))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'13
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionState tushort))
          (Sifthenelse (Ebinop Olt (Etempvar _t'13 tushort)
                         (Econst_int (Int.repr 8) tint) tint)
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'23
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _usedObj
                      (tptr (Tstruct _Object noattr))))
                  (Scall (Some _t'1)
                    (Evar _mario_obj_angle_to_object (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        (tptr (Tstruct _Object noattr)) ::
                                                        nil) tshort
                                                       cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Etempvar _t'23 (tptr (Tstruct _Object noattr))) :: nil)))
                (Sset _angleToNPC (Ecast (Etempvar _t'1 tshort) tshort)))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'22
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _faceAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tshort)) tshort))
                    (Scall (Some _t'2)
                      (Evar _approach_s32 (Tfunction
                                            (tint :: tint :: tint :: tint ::
                                             nil) tint cc_default))
                      ((Ebinop Oshr
                         (Ebinop Oshl
                           (Ebinop Osub (Etempvar _angleToNPC tshort)
                             (Etempvar _t'22 tshort) tint)
                           (Econst_int (Int.repr 16) tint) tint)
                         (Econst_int (Int.repr 16) tint) tint) ::
                       (Econst_int (Int.repr 0) tint) ::
                       (Econst_int (Int.repr 2048) tint) ::
                       (Econst_int (Int.repr 2048) tint) :: nil)))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _faceAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tshort)) tshort)
                    (Ebinop Osub (Etempvar _angleToNPC tshort)
                      (Etempvar _t'2 tint) tint)))
                (Ssequence
                  (Ssequence
                    (Sset _t'21
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionTimer tushort))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionTimer tushort)
                      (Ebinop Oadd (Etempvar _t'21 tushort)
                        (Etempvar _headTurnAmount tint) tint)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'20
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _heldObj
                          (tptr (Tstruct _Object noattr))))
                      (Sifthenelse (Ebinop Oeq
                                     (Etempvar _t'20 (tptr (Tstruct _Object noattr)))
                                     (Ecast (Econst_int (Int.repr 0) tint)
                                       (tptr tvoid)) tint)
                        (Sset _t'3
                          (Ecast (Econst_int (Int.repr 194) tint) tint))
                        (Sset _t'3
                          (Ecast (Econst_int (Int.repr 63) tint) tint))))
                    (Scall None
                      (Evar _set_mario_animation (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: nil) tshort
                                                   cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Etempvar _t'3 tint) :: nil))))))
            (Ssequence
              (Ssequence
                (Sset _t'18
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionState tushort))
                (Sifthenelse (Ebinop Oge (Etempvar _t'18 tushort)
                               (Econst_int (Int.repr 9) tint) tint)
                  (Ssequence
                    (Sset _t'19
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionState tushort))
                    (Sset _t'5
                      (Ecast
                        (Ebinop Olt (Etempvar _t'19 tushort)
                          (Econst_int (Int.repr 17) tint) tint) tbool)))
                  (Sset _t'5 (Econst_int (Int.repr 0) tint))))
              (Sifthenelse (Etempvar _t'5 tint)
                (Ssequence
                  (Sset _t'17
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionTimer tushort))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionTimer tushort)
                    (Ebinop Osub (Etempvar _t'17 tushort)
                      (Etempvar _headTurnAmount tint) tint)))
                (Ssequence
                  (Sset _t'14
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionState tushort))
                  (Sifthenelse (Ebinop Oeq (Etempvar _t'14 tushort)
                                 (Econst_int (Int.repr 23) tint) tint)
                    (Ssequence
                      (Sset _t'15
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _flags tuint))
                      (Sifthenelse (Ebinop Oand (Etempvar _t'15 tuint)
                                     (Econst_int (Int.repr 32) tint) tuint)
                        (Scall None
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 4925) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))
                        (Ssequence
                          (Ssequence
                            (Sset _t'16
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _heldObj
                                (tptr (Tstruct _Object noattr))))
                            (Sifthenelse (Ebinop Oeq
                                           (Etempvar _t'16 (tptr (Tstruct _Object noattr)))
                                           (Ecast
                                             (Econst_int (Int.repr 0) tint)
                                             (tptr tvoid)) tint)
                              (Sset _t'4
                                (Ecast (Econst_int (Int.repr 205521409) tint)
                                  tint))
                              (Sset _t'4
                                (Ecast (Econst_int (Int.repr 134218247) tint)
                                  tint))))
                          (Scall None
                            (Evar _set_mario_action (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: tuint :: nil)
                                                      tuint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Etempvar _t'4 tint) ::
                             (Econst_int (Int.repr 0) tint) :: nil)))))
                    Sskip))))))
        (Ssequence
          (Ssequence
            (Sset _t'12
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _marioObj
                (tptr (Tstruct _Object noattr))))
            (Scall None
              (Evar _vec3f_copy (Tfunction
                                  ((tptr tfloat) :: (tptr tfloat) :: nil)
                                  (tptr tvoid) cc_default))
              ((Efield
                 (Efield
                   (Efield
                     (Ederef (Etempvar _t'12 (tptr (Tstruct _Object noattr)))
                       (Tstruct _Object noattr)) _header
                     (Tstruct _ObjectNode noattr)) _gfx
                   (Tstruct _GraphNodeObject noattr)) _pos (tarray tfloat 3)) ::
               (Efield
                 (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                   (Tstruct _MarioState noattr)) _pos (tarray tfloat 3)) ::
               nil)))
          (Ssequence
            (Ssequence
              (Sset _t'10
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioObj
                  (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'11
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _faceAngle
                        (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tshort)) tshort))
                (Scall None
                  (Evar _vec3s_set (Tfunction
                                     ((tptr tshort) :: tshort :: tshort ::
                                      tshort :: nil) (tptr tvoid) cc_default))
                  ((Efield
                     (Efield
                       (Efield
                         (Ederef
                           (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                           (Tstruct _Object noattr)) _header
                         (Tstruct _ObjectNode noattr)) _gfx
                       (Tstruct _GraphNodeObject noattr)) _angle
                     (tarray tshort 3)) :: (Econst_int (Int.repr 0) tint) ::
                   (Etempvar _t'11 tshort) ::
                   (Econst_int (Int.repr 0) tint) :: nil))))
            (Ssequence
              (Ssequence
                (Sset _t'8
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _marioBodyState
                    (tptr (Tstruct _MarioBodyState noattr))))
                (Ssequence
                  (Sset _t'9
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionTimer tushort))
                  (Scall None
                    (Evar _vec3s_set (Tfunction
                                       ((tptr tshort) :: tshort :: tshort ::
                                        tshort :: nil) (tptr tvoid)
                                       cc_default))
                    ((Efield
                       (Ederef
                         (Etempvar _t'8 (tptr (Tstruct _MarioBodyState noattr)))
                         (Tstruct _MarioBodyState noattr)) _headAngle
                       (tarray tshort 3)) :: (Etempvar _t'9 tushort) ::
                     (Econst_int (Int.repr 0) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))))
              (Ssequence
                (Ssequence
                  (Sset _t'6
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionState tushort))
                  (Sifthenelse (Ebinop One (Etempvar _t'6 tushort)
                                 (Econst_int (Int.repr 8) tint) tint)
                    (Ssequence
                      (Sset _t'7
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionState
                          tushort))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionState
                          tushort)
                        (Ebinop Oadd (Etempvar _t'7 tushort)
                          (Econst_int (Int.repr 1) tint) tint)))
                    Sskip))
                (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))
|}.

Definition f_act_waiting_for_dialog := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: (_t'3, tshort) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _heldObj
          (tptr (Tstruct _Object noattr))))
      (Sifthenelse (Ebinop Oeq
                     (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Sset _t'1 (Ecast (Econst_int (Int.repr 194) tint) tint))
        (Sset _t'1 (Ecast (Econst_int (Int.repr 63) tint) tint))))
    (Scall None
      (Evar _set_mario_animation (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _t'1 tint) :: nil)))
  (Ssequence
    (Ssequence
      (Sset _t'4
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioObj
          (tptr (Tstruct _Object noattr))))
      (Scall None
        (Evar _vec3f_copy (Tfunction ((tptr tfloat) :: (tptr tfloat) :: nil)
                            (tptr tvoid) cc_default))
        ((Efield
           (Efield
             (Efield
               (Ederef (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                 (Tstruct _Object noattr)) _header
               (Tstruct _ObjectNode noattr)) _gfx
             (Tstruct _GraphNodeObject noattr)) _pos (tarray tfloat 3)) ::
         (Efield
           (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
             (Tstruct _MarioState noattr)) _pos (tarray tfloat 3)) :: nil)))
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _marioObj
            (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'3
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _faceAngle
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort))
          (Scall None
            (Evar _vec3s_set (Tfunction
                               ((tptr tshort) :: tshort :: tshort ::
                                tshort :: nil) (tptr tvoid) cc_default))
            ((Efield
               (Efield
                 (Efield
                   (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                     (Tstruct _Object noattr)) _header
                   (Tstruct _ObjectNode noattr)) _gfx
                 (Tstruct _GraphNodeObject noattr)) _angle (tarray tshort 3)) ::
             (Econst_int (Int.repr 0) tint) :: (Etempvar _t'3 tshort) ::
             (Econst_int (Int.repr 0) tint) :: nil))))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_act_disappeared := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'7, tshort) :: (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: (_t'4, tuint) ::
               (_t'3, tuint) :: (_t'2, tuint) :: (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _set_mario_animation (Tfunction
                                 ((tptr (Tstruct _MarioState noattr)) ::
                                  tint :: nil) tshort cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Econst_int (Int.repr 14) tint) :: nil))
  (Ssequence
    (Scall None
      (Evar _stop_and_set_height_to_floor (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Ssequence
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _marioObj
            (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioObj
              (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'7
              (Efield
                (Efield
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _header
                      (Tstruct _ObjectNode noattr)) _gfx
                    (Tstruct _GraphNodeObject noattr)) _node
                  (Tstruct _GraphNode noattr)) _flags tshort))
            (Sassign
              (Efield
                (Efield
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _header
                      (Tstruct _ObjectNode noattr)) _gfx
                    (Tstruct _GraphNodeObject noattr)) _node
                  (Tstruct _GraphNode noattr)) _flags tshort)
              (Ebinop Oand (Etempvar _t'7 tshort)
                (Eunop Onotint
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 0) tint) tint) tint) tint)))))
      (Ssequence
        (Ssequence
          (Sset _t'1
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionArg tuint))
          (Sifthenelse (Etempvar _t'1 tuint)
            (Ssequence
              (Ssequence
                (Sset _t'4
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionArg tuint))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionArg tuint)
                  (Ebinop Osub (Etempvar _t'4 tuint)
                    (Econst_int (Int.repr 1) tint) tuint)))
              (Ssequence
                (Sset _t'2
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionArg tuint))
                (Sifthenelse (Ebinop Oeq
                               (Ebinop Oand (Etempvar _t'2 tuint)
                                 (Econst_int (Int.repr 65535) tint) tuint)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Ssequence
                    (Sset _t'3
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionArg tuint))
                    (Scall None
                      (Evar _level_trigger_warp (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tint :: nil) tshort
                                                  cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Ebinop Oshr (Etempvar _t'3 tuint)
                         (Econst_int (Int.repr 16) tint) tuint) :: nil)))
                  Sskip)))
            Sskip))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_reading_automatic_dialog := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_actionArg, tuint) :: (_t'3, tint) :: (_t'2, tshort) ::
               (_t'1, tint) :: (_t'19, tushort) :: (_t'18, tushort) ::
               (_t'17, tuint) :: (_t'16, tushort) :: (_t'15, tushort) ::
               (_t'14, tushort) :: (_t'13, tschar) :: (_t'12, tuint) ::
               (_t'11, tuint) :: (_t'10, tushort) :: (_t'9, tushort) ::
               (_t'8, tushort) :: (_t'7, tushort) :: (_t'6, tushort) ::
               (_t'5, tushort) ::
               (_t'4, (tptr (Tstruct _MarioBodyState noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'19
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionState tushort))
    (Sassign
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionState tushort)
      (Ebinop Oadd (Etempvar _t'19 tushort) (Econst_int (Int.repr 1) tint)
        tint)))
  (Ssequence
    (Ssequence
      (Sset _t'18
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionState tushort))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'18 tushort)
                     (Econst_int (Int.repr 2) tint) tint)
        (Scall None (Evar _enable_time_stop (Tfunction nil tvoid cc_default))
          nil)
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionState tushort))
        (Sifthenelse (Ebinop Olt (Etempvar _t'6 tushort)
                       (Econst_int (Int.repr 9) tint) tint)
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'17
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _prevAction tuint))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'17 tuint)
                               (Econst_int (Int.repr 4867) tint) tint)
                  (Sset _t'1 (Ecast (Econst_int (Int.repr 178) tint) tint))
                  (Sset _t'1 (Ecast (Econst_int (Int.repr 194) tint) tint))))
              (Scall None
                (Evar _set_mario_animation (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tint :: nil) tshort cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Etempvar _t'1 tint) :: nil)))
            (Ssequence
              (Sset _t'16
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionTimer tushort))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionTimer tushort)
                (Ebinop Osub (Etempvar _t'16 tushort)
                  (Econst_int (Int.repr 1024) tint) tint))))
          (Ssequence
            (Sset _t'7
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionState tushort))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'7 tushort)
                           (Econst_int (Int.repr 9) tint) tint)
              (Ssequence
                (Sset _actionArg
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionArg tuint))
                (Sifthenelse (Ebinop Oeq
                               (Ecast
                                 (Ebinop Oshr (Etempvar _actionArg tuint)
                                   (Econst_int (Int.repr 16) tint) tuint)
                                 tushort) (Econst_int (Int.repr 0) tint)
                               tint)
                  (Scall None
                    (Evar _create_dialog_box (Tfunction (tshort :: nil) tvoid
                                               cc_default))
                    ((Ecast
                       (Ebinop Oand (Etempvar _actionArg tuint)
                         (Econst_int (Int.repr 65535) tint) tuint) tushort) ::
                     nil))
                  (Scall None
                    (Evar _create_dialog_box_with_var (Tfunction
                                                        (tshort :: tint ::
                                                         nil) tvoid
                                                        cc_default))
                    ((Ecast
                       (Ebinop Oshr (Etempvar _actionArg tuint)
                         (Econst_int (Int.repr 16) tint) tuint) tushort) ::
                     (Ecast
                       (Ebinop Oand (Etempvar _actionArg tuint)
                         (Econst_int (Int.repr 65535) tint) tuint) tushort) ::
                     nil))))
              (Ssequence
                (Sset _t'8
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionState tushort))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'8 tushort)
                               (Econst_int (Int.repr 10) tint) tint)
                  (Ssequence
                    (Scall (Some _t'2)
                      (Evar _get_dialog_id (Tfunction nil tshort cc_default))
                      nil)
                    (Sifthenelse (Ebinop Oge (Etempvar _t'2 tshort)
                                   (Econst_int (Int.repr 0) tint) tint)
                      (Ssequence
                        (Sset _t'15
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _actionState
                            tushort))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _actionState
                            tushort)
                          (Ebinop Osub (Etempvar _t'15 tushort)
                            (Econst_int (Int.repr 1) tint) tint)))
                      Sskip))
                  (Ssequence
                    (Sset _t'9
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionState tushort))
                    (Sifthenelse (Ebinop Olt (Etempvar _t'9 tushort)
                                   (Econst_int (Int.repr 19) tint) tint)
                      (Ssequence
                        (Sset _t'14
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _actionTimer
                            tushort))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _actionTimer
                            tushort)
                          (Ebinop Oadd (Etempvar _t'14 tushort)
                            (Econst_int (Int.repr 1024) tint) tint)))
                      (Ssequence
                        (Sset _t'10
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _actionState
                            tushort))
                        (Sifthenelse (Ebinop Oeq (Etempvar _t'10 tushort)
                                       (Econst_int (Int.repr 25) tint) tint)
                          (Ssequence
                            (Scall None
                              (Evar _disable_time_stop (Tfunction nil tvoid
                                                         cc_default)) nil)
                            (Ssequence
                              (Ssequence
                                (Sset _t'13
                                  (Evar _gNeverEnteredCastle tschar))
                                (Sifthenelse (Etempvar _t'13 tschar)
                                  (Ssequence
                                    (Sassign
                                      (Evar _gNeverEnteredCastle tschar)
                                      (Econst_int (Int.repr 0) tint))
                                    (Scall None
                                      (Evar _play_cutscene_music (Tfunction
                                                                   (tushort ::
                                                                    nil)
                                                                   tvoid
                                                                   cc_default))
                                      ((Ebinop Oor
                                         (Ebinop Oshl
                                           (Econst_int (Int.repr 0) tint)
                                           (Econst_int (Int.repr 8) tint)
                                           tint)
                                         (Econst_int (Int.repr 4) tint) tint) ::
                                       nil)))
                                  Sskip))
                              (Ssequence
                                (Sset _t'11
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _prevAction tuint))
                                (Sifthenelse (Ebinop Oeq
                                               (Etempvar _t'11 tuint)
                                               (Econst_int (Int.repr 4867) tint)
                                               tint)
                                  (Scall None
                                    (Evar _set_mario_action (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               tuint ::
                                                               tuint :: nil)
                                                              tuint
                                                              cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     (Econst_int (Int.repr 939532992) tint) ::
                                     (Econst_int (Int.repr 0) tint) :: nil))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'12
                                        (Efield
                                          (Ederef
                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _prevAction tuint))
                                      (Sifthenelse (Ebinop Oeq
                                                     (Etempvar _t'12 tuint)
                                                     (Econst_int (Int.repr 4911) tint)
                                                     tint)
                                        (Sset _t'3
                                          (Ecast
                                            (Econst_int (Int.repr 67109952) tint)
                                            tint))
                                        (Sset _t'3
                                          (Ecast
                                            (Econst_int (Int.repr 205521409) tint)
                                            tint))))
                                    (Scall None
                                      (Evar _set_mario_action (Tfunction
                                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                                 tuint ::
                                                                 tuint ::
                                                                 nil) tuint
                                                                cc_default))
                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                       (Etempvar _t'3 tint) ::
                                       (Econst_int (Int.repr 0) tint) :: nil)))))))
                          Sskip))))))))))
      (Ssequence
        (Ssequence
          (Sset _t'4
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioBodyState
              (tptr (Tstruct _MarioBodyState noattr))))
          (Ssequence
            (Sset _t'5
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Scall None
              (Evar _vec3s_set (Tfunction
                                 ((tptr tshort) :: tshort :: tshort ::
                                  tshort :: nil) (tptr tvoid) cc_default))
              ((Efield
                 (Ederef
                   (Etempvar _t'4 (tptr (Tstruct _MarioBodyState noattr)))
                   (Tstruct _MarioBodyState noattr)) _headAngle
                 (tarray tshort 3)) :: (Etempvar _t'5 tushort) ::
               (Econst_int (Int.repr 0) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_reading_sign := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_t'1, tushort) :: (_t'13, tint) :: (_t'12, tshort) ::
               (_t'11, tfloat) :: (_t'10, tfloat) :: (_t'9, tfloat) ::
               (_t'8, tfloat) :: (_t'7, tint) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tuchar) ::
               (_t'4, (tptr (Tstruct _Camera noattr))) :: (_t'3, tushort) ::
               (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _marioObj
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
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
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 91) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 255) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) ::
       (Econst_int (Int.repr 65536) tint) :: nil))
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionState tushort))
        (Sswitch (Etempvar _t'3 tushort)
          (LScons (Some 0)
            (Ssequence
              (Scall None
                (Evar _trigger_cutscene_dialog (Tfunction (tint :: nil) tint
                                                 cc_default))
                ((Econst_int (Int.repr 1) tint) :: nil))
              (Ssequence
                (Scall None
                  (Evar _enable_time_stop (Tfunction nil tvoid cc_default))
                  nil)
                (Ssequence
                  (Scall None
                    (Evar _set_mario_animation (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tint :: nil) tshort
                                                 cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 194) tint) :: nil))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionState tushort)
                    (Econst_int (Int.repr 1) tint)))))
            (LScons (Some 1)
              (Ssequence
                (Ssequence
                  (Sset _t'12
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _faceAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tshort)) tshort))
                  (Ssequence
                    (Sset _t'13
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __729 noattr)) _asS32 (tarray tint 80))
                          (Econst_int (Int.repr 32) tint) (tptr tint)) tint))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _faceAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tshort)) tshort)
                      (Ebinop Oadd (Etempvar _t'12 tshort)
                        (Ebinop Odiv (Etempvar _t'13 tint)
                          (Econst_int (Int.repr 11) tint) tint) tint))))
                (Ssequence
                  (Ssequence
                    (Sset _t'10
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _pos
                            (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                          (tptr tfloat)) tfloat))
                    (Ssequence
                      (Sset _t'11
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _rawData
                                (Tunion __729 noattr)) _asF32
                              (tarray tfloat 80))
                            (Econst_int (Int.repr 33) tint) (tptr tfloat))
                          tfloat))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _pos
                              (tarray tfloat 3))
                            (Econst_int (Int.repr 0) tint) (tptr tfloat))
                          tfloat)
                        (Ebinop Oadd (Etempvar _t'10 tfloat)
                          (Ebinop Odiv (Etempvar _t'11 tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1093664768)) tfloat)
                            tfloat) tfloat))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'8
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _pos
                              (tarray tfloat 3))
                            (Econst_int (Int.repr 2) tint) (tptr tfloat))
                          tfloat))
                      (Ssequence
                        (Sset _t'9
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __729 noattr)) _asF32
                                (tarray tfloat 80))
                              (Econst_int (Int.repr 34) tint) (tptr tfloat))
                            tfloat))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _pos
                                (tarray tfloat 3))
                              (Econst_int (Int.repr 2) tint) (tptr tfloat))
                            tfloat)
                          (Ebinop Oadd (Etempvar _t'8 tfloat)
                            (Ebinop Odiv (Etempvar _t'9 tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1093664768)) tfloat)
                              tfloat) tfloat))))
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'1
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _actionTimer
                              tushort))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _actionTimer
                              tushort)
                            (Ebinop Oadd (Etempvar _t'1 tushort)
                              (Econst_int (Int.repr 1) tint) tint)))
                        (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tushort)
                                       (Econst_int (Int.repr 10) tint) tint)
                          (Ssequence
                            (Ssequence
                              (Sset _t'6
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _usedObj
                                  (tptr (Tstruct _Object noattr))))
                              (Ssequence
                                (Sset _t'7
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                                            (Tstruct _Object noattr))
                                          _rawData (Tunion __729 noattr))
                                        _asS32 (tarray tint 80))
                                      (Econst_int (Int.repr 47) tint)
                                      (tptr tint)) tint))
                                (Scall None
                                  (Evar _create_dialog_inverted_box (Tfunction
                                                                    (tshort ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                  ((Etempvar _t'7 tint) :: nil))))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _actionState
                                tushort) (Econst_int (Int.repr 2) tint)))
                          Sskip))
                      Sbreak))))
              (LScons (Some 2)
                (Ssequence
                  (Ssequence
                    (Sset _t'4
                      (Evar _gCamera (tptr (Tstruct _Camera noattr))))
                    (Ssequence
                      (Sset _t'5
                        (Efield
                          (Ederef
                            (Etempvar _t'4 (tptr (Tstruct _Camera noattr)))
                            (Tstruct _Camera noattr)) _cutscene tuchar))
                      (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tuchar)
                                     (Econst_int (Int.repr 0) tint) tint)
                        (Ssequence
                          (Scall None
                            (Evar _disable_time_stop (Tfunction nil tvoid
                                                       cc_default)) nil)
                          (Scall None
                            (Evar _set_mario_action (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: tuint :: nil)
                                                      tuint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 205521409) tint) ::
                             (Econst_int (Int.repr 0) tint) :: nil)))
                        Sskip)))
                  Sbreak)
                LSnil)))))
      (Ssequence
        (Scall None
          (Evar _vec3f_copy (Tfunction
                              ((tptr tfloat) :: (tptr tfloat) :: nil)
                              (tptr tvoid) cc_default))
          ((Efield
             (Efield
               (Efield
                 (Ederef (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                   (Tstruct _Object noattr)) _header
                 (Tstruct _ObjectNode noattr)) _gfx
               (Tstruct _GraphNodeObject noattr)) _pos (tarray tfloat 3)) ::
           (Efield
             (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
               (Tstruct _MarioState noattr)) _pos (tarray tfloat 3)) :: nil))
        (Ssequence
          (Ssequence
            (Sset _t'2
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _faceAngle
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort))
            (Scall None
              (Evar _vec3s_set (Tfunction
                                 ((tptr tshort) :: tshort :: tshort ::
                                  tshort :: nil) (tptr tvoid) cc_default))
              ((Efield
                 (Efield
                   (Efield
                     (Ederef
                       (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                       (Tstruct _Object noattr)) _header
                     (Tstruct _ObjectNode noattr)) _gfx
                   (Tstruct _GraphNodeObject noattr)) _angle
                 (tarray tshort 3)) :: (Econst_int (Int.repr 0) tint) ::
               (Etempvar _t'2 tshort) :: (Econst_int (Int.repr 0) tint) ::
               nil)))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_debug_free_move := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := ((_surf, (tptr (Tstruct _Surface noattr))) ::
              (_pos, (tarray tfloat 3)) :: nil);
  fn_temps := ((_floorHeight, tfloat) :: (_speed, tfloat) ::
               (_action, tuint) :: (_t'2, tfloat) :: (_t'1, tint) ::
               (_t'32, tushort) ::
               (_t'31, (tptr (Tstruct _Controller noattr))) ::
               (_t'30, tushort) ::
               (_t'29, (tptr (Tstruct _Controller noattr))) ::
               (_t'28, tfloat) :: (_t'27, tushort) ::
               (_t'26, (tptr (Tstruct _Controller noattr))) ::
               (_t'25, tfloat) :: (_t'24, tushort) ::
               (_t'23, (tptr (Tstruct _Controller noattr))) ::
               (_t'22, tfloat) :: (_t'21, tshort) :: (_t'20, tfloat) ::
               (_t'19, tfloat) :: (_t'18, tshort) :: (_t'17, tfloat) ::
               (_t'16, tfloat) :: (_t'15, tfloat) :: (_t'14, tfloat) ::
               (_t'13, tfloat) :: (_t'12, tfloat) ::
               (_t'11, (tptr (Tstruct _Surface noattr))) ::
               (_t'10, tshort) :: (_t'9, (tptr (Tstruct _Object noattr))) ::
               (_t'8, tshort) :: (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, tshort) :: (_t'5, tfloat) :: (_t'4, tushort) ::
               (_t'3, (tptr (Tstruct _Controller noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'31
        (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
      (Ssequence
        (Sset _t'32
          (Efield
            (Ederef (Etempvar _t'31 (tptr (Tstruct _Controller noattr)))
              (Tstruct _Controller noattr)) _buttonDown tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'32 tushort)
                       (Econst_int (Int.repr 16384) tint) tint)
          (Sset _t'1 (Ecast (Econst_int (Int.repr 4) tint) tint))
          (Sset _t'1 (Ecast (Econst_int (Int.repr 1) tint) tint)))))
    (Sset _speed (Ecast (Etempvar _t'1 tint) tfloat)))
  (Ssequence
    (Ssequence
      (Sset _t'29
        (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
      (Ssequence
        (Sset _t'30
          (Efield
            (Ederef (Etempvar _t'29 (tptr (Tstruct _Controller noattr)))
              (Tstruct _Controller noattr)) _buttonDown tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'30 tushort)
                       (Econst_int (Int.repr 32) tint) tint)
          (Sset _speed
            (Econst_single (Float32.of_bits (Int.repr 1008981770)) tfloat))
          Sskip)))
    (Ssequence
      (Scall None
        (Evar _set_mario_animation (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tint :: nil) tshort cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 14) tint) :: nil))
      (Ssequence
        (Scall None
          (Evar _vec3f_copy (Tfunction
                              ((tptr tfloat) :: (tptr tfloat) :: nil)
                              (tptr tvoid) cc_default))
          ((Evar _pos (tarray tfloat 3)) ::
           (Efield
             (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
               (Tstruct _MarioState noattr)) _pos (tarray tfloat 3)) :: nil))
        (Ssequence
          (Ssequence
            (Sset _t'26
              (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
            (Ssequence
              (Sset _t'27
                (Efield
                  (Ederef
                    (Etempvar _t'26 (tptr (Tstruct _Controller noattr)))
                    (Tstruct _Controller noattr)) _buttonDown tushort))
              (Sifthenelse (Ebinop Oand (Etempvar _t'27 tushort)
                             (Econst_int (Int.repr 2048) tint) tint)
                (Ssequence
                  (Sset _t'28
                    (Ederef
                      (Ebinop Oadd (Evar _pos (tarray tfloat 3))
                        (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd (Evar _pos (tarray tfloat 3))
                        (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
                    (Ebinop Oadd (Etempvar _t'28 tfloat)
                      (Ebinop Omul
                        (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                        (Etempvar _speed tfloat) tfloat) tfloat)))
                Sskip)))
          (Ssequence
            (Ssequence
              (Sset _t'23
                (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
              (Ssequence
                (Sset _t'24
                  (Efield
                    (Ederef
                      (Etempvar _t'23 (tptr (Tstruct _Controller noattr)))
                      (Tstruct _Controller noattr)) _buttonDown tushort))
                (Sifthenelse (Ebinop Oand (Etempvar _t'24 tushort)
                               (Econst_int (Int.repr 1024) tint) tint)
                  (Ssequence
                    (Sset _t'25
                      (Ederef
                        (Ebinop Oadd (Evar _pos (tarray tfloat 3))
                          (Econst_int (Int.repr 1) tint) (tptr tfloat))
                        tfloat))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd (Evar _pos (tarray tfloat 3))
                          (Econst_int (Int.repr 1) tint) (tptr tfloat))
                        tfloat)
                      (Ebinop Osub (Etempvar _t'25 tfloat)
                        (Ebinop Omul
                          (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                          (Etempvar _speed tfloat) tfloat) tfloat)))
                  Sskip)))
            (Ssequence
              (Ssequence
                (Sset _t'16
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _intendedMag tfloat))
                (Sifthenelse (Ebinop Ogt (Etempvar _t'16 tfloat)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'20
                        (Ederef
                          (Ebinop Oadd (Evar _pos (tarray tfloat 3))
                            (Econst_int (Int.repr 0) tint) (tptr tfloat))
                          tfloat))
                      (Ssequence
                        (Sset _t'21
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _intendedYaw
                            tshort))
                        (Ssequence
                          (Sset _t'22
                            (Ederef
                              (Ebinop Oadd
                                (Evar _gSineTable (tarray tfloat 0))
                                (Ebinop Oshr
                                  (Ecast (Etempvar _t'21 tshort) tushort)
                                  (Econst_int (Int.repr 4) tint) tint)
                                (tptr tfloat)) tfloat))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd (Evar _pos (tarray tfloat 3))
                                (Econst_int (Int.repr 0) tint) (tptr tfloat))
                              tfloat)
                            (Ebinop Oadd (Etempvar _t'20 tfloat)
                              (Ebinop Omul
                                (Ebinop Omul
                                  (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                                  (Etempvar _speed tfloat) tfloat)
                                (Etempvar _t'22 tfloat) tfloat) tfloat)))))
                    (Ssequence
                      (Sset _t'17
                        (Ederef
                          (Ebinop Oadd (Evar _pos (tarray tfloat 3))
                            (Econst_int (Int.repr 2) tint) (tptr tfloat))
                          tfloat))
                      (Ssequence
                        (Sset _t'18
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _intendedYaw
                            tshort))
                        (Ssequence
                          (Sset _t'19
                            (Ederef
                              (Ebinop Oadd
                                (Ebinop Oadd
                                  (Evar _gSineTable (tarray tfloat 0))
                                  (Econst_int (Int.repr 1024) tint)
                                  (tptr tfloat))
                                (Ebinop Oshr
                                  (Ecast (Etempvar _t'18 tshort) tushort)
                                  (Econst_int (Int.repr 4) tint) tint)
                                (tptr tfloat)) tfloat))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd (Evar _pos (tarray tfloat 3))
                                (Econst_int (Int.repr 2) tint) (tptr tfloat))
                              tfloat)
                            (Ebinop Oadd (Etempvar _t'17 tfloat)
                              (Ebinop Omul
                                (Ebinop Omul
                                  (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                                  (Etempvar _speed tfloat) tfloat)
                                (Etempvar _t'19 tfloat) tfloat) tfloat))))))
                  Sskip))
              (Ssequence
                (Scall None
                  (Evar _resolve_and_return_wall_collisions (Tfunction
                                                              ((tptr tfloat) ::
                                                               tfloat ::
                                                               tfloat :: nil)
                                                              (tptr (Tstruct _Surface noattr))
                                                              cc_default))
                  ((Evar _pos (tarray tfloat 3)) ::
                   (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat) ::
                   (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat) ::
                   nil))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'13
                        (Ederef
                          (Ebinop Oadd (Evar _pos (tarray tfloat 3))
                            (Econst_int (Int.repr 0) tint) (tptr tfloat))
                          tfloat))
                      (Ssequence
                        (Sset _t'14
                          (Ederef
                            (Ebinop Oadd (Evar _pos (tarray tfloat 3))
                              (Econst_int (Int.repr 1) tint) (tptr tfloat))
                            tfloat))
                        (Ssequence
                          (Sset _t'15
                            (Ederef
                              (Ebinop Oadd (Evar _pos (tarray tfloat 3))
                                (Econst_int (Int.repr 2) tint) (tptr tfloat))
                              tfloat))
                          (Scall (Some _t'2)
                            (Evar _find_floor (Tfunction
                                                (tfloat :: tfloat ::
                                                 tfloat ::
                                                 (tptr (tptr (Tstruct _Surface noattr))) ::
                                                 nil) tfloat cc_default))
                            ((Etempvar _t'13 tfloat) ::
                             (Etempvar _t'14 tfloat) ::
                             (Etempvar _t'15 tfloat) ::
                             (Eaddrof
                               (Evar _surf (tptr (Tstruct _Surface noattr)))
                               (tptr (tptr (Tstruct _Surface noattr)))) ::
                             nil)))))
                    (Sset _floorHeight (Etempvar _t'2 tfloat)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'11
                        (Evar _surf (tptr (Tstruct _Surface noattr))))
                      (Sifthenelse (Ebinop One
                                     (Etempvar _t'11 (tptr (Tstruct _Surface noattr)))
                                     (Ecast (Econst_int (Int.repr 0) tint)
                                       (tptr tvoid)) tint)
                        (Ssequence
                          (Ssequence
                            (Sset _t'12
                              (Ederef
                                (Ebinop Oadd (Evar _pos (tarray tfloat 3))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tfloat)) tfloat))
                            (Sifthenelse (Ebinop Olt (Etempvar _t'12 tfloat)
                                           (Etempvar _floorHeight tfloat)
                                           tint)
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd (Evar _pos (tarray tfloat 3))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr tfloat)) tfloat)
                                (Etempvar _floorHeight tfloat))
                              Sskip))
                          (Scall None
                            (Evar _vec3f_copy (Tfunction
                                                ((tptr tfloat) ::
                                                 (tptr tfloat) :: nil)
                                                (tptr tvoid) cc_default))
                            ((Efield
                               (Ederef
                                 (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                 (Tstruct _MarioState noattr)) _pos
                               (tarray tfloat 3)) ::
                             (Evar _pos (tarray tfloat 3)) :: nil)))
                        Sskip))
                    (Ssequence
                      (Ssequence
                        (Sset _t'10
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _intendedYaw
                            tshort))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _faceAngle
                                (tarray tshort 3))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))
                            tshort) (Etempvar _t'10 tshort)))
                      (Ssequence
                        (Ssequence
                          (Sset _t'9
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _marioObj
                              (tptr (Tstruct _Object noattr))))
                          (Scall None
                            (Evar _vec3f_copy (Tfunction
                                                ((tptr tfloat) ::
                                                 (tptr tfloat) :: nil)
                                                (tptr tvoid) cc_default))
                            ((Efield
                               (Efield
                                 (Efield
                                   (Ederef
                                     (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                                     (Tstruct _Object noattr)) _header
                                   (Tstruct _ObjectNode noattr)) _gfx
                                 (Tstruct _GraphNodeObject noattr)) _pos
                               (tarray tfloat 3)) ::
                             (Efield
                               (Ederef
                                 (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                 (Tstruct _MarioState noattr)) _pos
                               (tarray tfloat 3)) :: nil)))
                        (Ssequence
                          (Ssequence
                            (Sset _t'7
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _marioObj
                                (tptr (Tstruct _Object noattr))))
                            (Ssequence
                              (Sset _t'8
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _faceAngle (tarray tshort 3))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr tshort)) tshort))
                              (Scall None
                                (Evar _vec3s_set (Tfunction
                                                   ((tptr tshort) ::
                                                    tshort :: tshort ::
                                                    tshort :: nil)
                                                   (tptr tvoid) cc_default))
                                ((Efield
                                   (Efield
                                     (Efield
                                       (Ederef
                                         (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                                         (Tstruct _Object noattr)) _header
                                       (Tstruct _ObjectNode noattr)) _gfx
                                     (Tstruct _GraphNodeObject noattr))
                                   _angle (tarray tshort 3)) ::
                                 (Econst_int (Int.repr 0) tint) ::
                                 (Etempvar _t'8 tshort) ::
                                 (Econst_int (Int.repr 0) tint) :: nil))))
                          (Ssequence
                            (Ssequence
                              (Sset _t'3
                                (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
                              (Ssequence
                                (Sset _t'4
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'3 (tptr (Tstruct _Controller noattr)))
                                      (Tstruct _Controller noattr))
                                    _buttonPressed tushort))
                                (Sifthenelse (Ebinop Oeq
                                               (Etempvar _t'4 tushort)
                                               (Econst_int (Int.repr 32768) tint)
                                               tint)
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'5
                                        (Ederef
                                          (Ebinop Oadd
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _pos (tarray tfloat 3))
                                            (Econst_int (Int.repr 1) tint)
                                            (tptr tfloat)) tfloat))
                                      (Ssequence
                                        (Sset _t'6
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _waterLevel tshort))
                                        (Sifthenelse (Ebinop Ole
                                                       (Etempvar _t'5 tfloat)
                                                       (Ebinop Osub
                                                         (Etempvar _t'6 tshort)
                                                         (Econst_int (Int.repr 100) tint)
                                                         tint) tint)
                                          (Sset _action
                                            (Econst_int (Int.repr 939532992) tint))
                                          (Sset _action
                                            (Econst_int (Int.repr 205521409) tint)))))
                                    (Scall None
                                      (Evar _set_mario_action (Tfunction
                                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                                 tuint ::
                                                                 tuint ::
                                                                 nil) tuint
                                                                cc_default))
                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                       (Etempvar _action tuint) ::
                                       (Econst_int (Int.repr 0) tint) :: nil)))
                                  Sskip)))
                            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))))))))
|}.

Definition f_general_star_dance_handler := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_isInWater, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_dialogID, tint) :: (_t'8, tint) :: (_t'7, tint) ::
               (_t'6, tint) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tushort) ::
               (_t'22, tushort) ::
               (_t'21, (tptr (Tstruct _Object noattr))) :: (_t'20, tshort) ::
               (_t'19, tshort) :: (_t'18, tuint) ::
               (_t'17, (tptr (Tstruct _Object noattr))) :: (_t'16, tuchar) ::
               (_t'15, tuint) :: (_t'14, tint) :: (_t'13, tushort) ::
               (_t'12, tshort) :: (_t'11, tint) :: (_t'10, tushort) ::
               (_t'9, tushort) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'9
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _actionState tushort))
  (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tushort)
                 (Econst_int (Int.repr 0) tint) tint)
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'22
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort))
          (Sset _t'1
            (Ecast
              (Ebinop Oadd (Etempvar _t'22 tushort)
                (Econst_int (Int.repr 1) tint) tint) tushort)))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort)
          (Etempvar _t'1 tushort)))
      (Sswitch (Etempvar _t'1 tushort)
        (LScons (Some 1)
          (Ssequence
            (Ssequence
              (Sset _t'21
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioObj
                  (tptr (Tstruct _Object noattr))))
              (Scall None
                (Evar _spawn_object (Tfunction
                                      ((tptr (Tstruct _Object noattr)) ::
                                       tint :: (tptr tuint) :: nil)
                                      (tptr (Tstruct _Object noattr))
                                      cc_default))
                ((Etempvar _t'21 (tptr (Tstruct _Object noattr))) ::
                 (Econst_int (Int.repr 122) tint) ::
                 (Evar _bhvCelebrationStar (tarray tuint 0)) :: nil)))
            (Ssequence
              (Scall None
                (Evar _disable_background_sound (Tfunction nil tvoid
                                                  cc_default)) nil)
              (Ssequence
                (Ssequence
                  (Sset _t'18
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionArg tuint))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'18 tuint)
                                 (Econst_int (Int.repr 1) tint) tuint)
                    (Scall None
                      (Evar _play_course_clear (Tfunction nil tvoid
                                                 cc_default)) nil)
                    (Ssequence
                      (Ssequence
                        (Sset _t'19 (Evar _gCurrLevelNum tshort))
                        (Sifthenelse (Ebinop Oeq (Etempvar _t'19 tshort)
                                       (Econst_int (Int.repr 30) tint) tint)
                          (Sset _t'2 (Econst_int (Int.repr 1) tint))
                          (Ssequence
                            (Sset _t'20 (Evar _gCurrLevelNum tshort))
                            (Sset _t'2
                              (Ecast
                                (Ebinop Oeq (Etempvar _t'20 tshort)
                                  (Econst_int (Int.repr 33) tint) tint)
                                tbool)))))
                      (Sifthenelse (Etempvar _t'2 tint)
                        (Scall None
                          (Evar _play_music (Tfunction
                                              (tuchar :: tushort ::
                                               tushort :: nil) tvoid
                                              cc_default))
                          ((Econst_int (Int.repr 1) tint) ::
                           (Ebinop Oor
                             (Ebinop Oshl (Econst_int (Int.repr 15) tint)
                               (Econst_int (Int.repr 8) tint) tint)
                             (Econst_int (Int.repr 23) tint) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))
                        (Scall None
                          (Evar _play_music (Tfunction
                                              (tuchar :: tushort ::
                                               tushort :: nil) tvoid
                                              cc_default))
                          ((Econst_int (Int.repr 1) tint) ::
                           (Ebinop Oor
                             (Ebinop Oshl (Econst_int (Int.repr 15) tint)
                               (Econst_int (Int.repr 8) tint) tint)
                             (Econst_int (Int.repr 1) tint) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))))))
                Sbreak)))
          (LScons (Some 42)
            (Ssequence
              (Ssequence
                (Sset _t'17
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
                           (Etempvar _t'17 (tptr (Tstruct _Object noattr)))
                           (Tstruct _Object noattr)) _header
                         (Tstruct _ObjectNode noattr)) _gfx
                       (Tstruct _GraphNodeObject noattr)) _cameraToObject
                     (tarray tfloat 3)) :: nil)))
              Sbreak)
            (LScons (Some 80)
              (Ssequence
                (Ssequence
                  (Sset _t'15
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionArg tuint))
                  (Sifthenelse (Eunop Onotbool
                                 (Ebinop Oand (Etempvar _t'15 tuint)
                                   (Econst_int (Int.repr 1) tint) tuint)
                                 tint)
                    (Scall None
                      (Evar _level_trigger_warp (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tint :: nil) tshort
                                                  cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 17) tint) :: nil))
                    (Ssequence
                      (Scall None
                        (Evar _enable_time_stop (Tfunction nil tvoid
                                                  cc_default)) nil)
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'16 (Evar _gLastCompletedStarNum tuchar))
                            (Sifthenelse (Ebinop Oeq (Etempvar _t'16 tuchar)
                                           (Econst_int (Int.repr 7) tint)
                                           tint)
                              (Sset _t'3
                                (Ecast (Econst_int (Int.repr 13) tint) tint))
                              (Sset _t'3
                                (Ecast (Econst_int (Int.repr 14) tint) tint))))
                          (Scall None
                            (Evar _create_dialog_box_with_response (Tfunction
                                                                    (tshort ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                            ((Etempvar _t'3 tint) :: nil)))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _actionState
                            tushort) (Econst_int (Int.repr 1) tint))))))
                Sbreak)
              LSnil)))))
    (Ssequence
      (Ssequence
        (Sset _t'13
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionState tushort))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'13 tushort)
                       (Econst_int (Int.repr 1) tint) tint)
          (Ssequence
            (Sset _t'14 (Evar _gDialogResponse tint))
            (Sset _t'8
              (Ecast
                (Ebinop One (Etempvar _t'14 tint)
                  (Econst_int (Int.repr 0) tint) tint) tbool)))
          (Sset _t'8 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'8 tint)
        (Ssequence
          (Ssequence
            (Sset _t'11 (Evar _gDialogResponse tint))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'11 tint)
                           (Econst_int (Int.repr 1) tint) tint)
              (Ssequence
                (Sset _t'12 (Evar _gCurrSaveFileNum tshort))
                (Scall None
                  (Evar _save_file_do_save (Tfunction (tint :: nil) tvoid
                                             cc_default))
                  ((Ebinop Osub (Etempvar _t'12 tshort)
                     (Econst_int (Int.repr 1) tint) tint) :: nil)))
              Sskip))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionState tushort)
            (Econst_int (Int.repr 2) tint)))
        (Ssequence
          (Ssequence
            (Sset _t'10
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionState tushort))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'10 tushort)
                           (Econst_int (Int.repr 2) tint) tint)
              (Ssequence
                (Scall (Some _t'7)
                  (Evar _is_anim_at_end (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Sset _t'6 (Ecast (Etempvar _t'7 tint) tbool)))
              (Sset _t'6 (Econst_int (Int.repr 0) tint))))
          (Sifthenelse (Etempvar _t'6 tint)
            (Ssequence
              (Scall None
                (Evar _disable_time_stop (Tfunction nil tvoid cc_default))
                nil)
              (Ssequence
                (Scall None
                  (Evar _enable_background_sound (Tfunction nil tvoid
                                                   cc_default)) nil)
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'4)
                      (Evar _get_star_collection_dialog (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           nil) tint
                                                          cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Sset _dialogID (Etempvar _t'4 tint)))
                  (Sifthenelse (Etempvar _dialogID tint)
                    (Scall None
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 536875781) tint) ::
                       (Etempvar _dialogID tint) :: nil))
                    (Ssequence
                      (Sifthenelse (Etempvar _isInWater tint)
                        (Sset _t'5
                          (Ecast (Econst_int (Int.repr 939532992) tint) tint))
                        (Sset _t'5
                          (Ecast (Econst_int (Int.repr 205521409) tint) tint)))
                      (Scall None
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Etempvar _t'5 tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil)))))))
            Sskip))))))
|}.

Definition f_act_star_dance := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) :: (_t'9, tshort) ::
               (_t'8, (tptr (Tstruct _Camera noattr))) ::
               (_t'7, (tptr (Tstruct _Area noattr))) :: (_t'6, tushort) ::
               (_t'5, tushort) :: (_t'4, tushort) ::
               (_t'3, (tptr (Tstruct _MarioBodyState noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _area (tptr (Tstruct _Area noattr))))
    (Ssequence
      (Sset _t'8
        (Efield
          (Ederef (Etempvar _t'7 (tptr (Tstruct _Area noattr)))
            (Tstruct _Area noattr)) _camera (tptr (Tstruct _Camera noattr))))
      (Ssequence
        (Sset _t'9
          (Efield
            (Ederef (Etempvar _t'8 (tptr (Tstruct _Camera noattr)))
              (Tstruct _Camera noattr)) _yaw tshort))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
              (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort)
          (Etempvar _t'9 tshort)))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionState tushort))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'6 tushort)
                       (Econst_int (Int.repr 2) tint) tint)
          (Sset _t'1 (Ecast (Econst_int (Int.repr 206) tint) tint))
          (Sset _t'1 (Ecast (Econst_int (Int.repr 205) tint) tint))))
      (Scall None
        (Evar _set_mario_animation (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tint :: nil) tshort cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Etempvar _t'1 tint) :: nil)))
    (Ssequence
      (Scall None
        (Evar _general_star_dance_handler (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tint :: nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 0) tint) :: nil))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionState tushort))
            (Sifthenelse (Ebinop One (Etempvar _t'4 tushort)
                           (Econst_int (Int.repr 2) tint) tint)
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionTimer tushort))
                (Sset _t'2
                  (Ecast
                    (Ebinop Oge (Etempvar _t'5 tushort)
                      (Econst_int (Int.repr 40) tint) tint) tbool)))
              (Sset _t'2 (Econst_int (Int.repr 0) tint))))
          (Sifthenelse (Etempvar _t'2 tint)
            (Ssequence
              (Sset _t'3
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioBodyState
                  (tptr (Tstruct _MarioBodyState noattr))))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _t'3 (tptr (Tstruct _MarioBodyState noattr)))
                    (Tstruct _MarioBodyState noattr)) _handState tschar)
                (Econst_int (Int.repr 2) tint)))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _stop_and_set_height_to_floor (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_star_dance_water := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) :: (_t'12, tshort) ::
               (_t'11, (tptr (Tstruct _Camera noattr))) ::
               (_t'10, (tptr (Tstruct _Area noattr))) :: (_t'9, tushort) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tshort) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tushort) ::
               (_t'4, tushort) ::
               (_t'3, (tptr (Tstruct _MarioBodyState noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'10
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _area (tptr (Tstruct _Area noattr))))
    (Ssequence
      (Sset _t'11
        (Efield
          (Ederef (Etempvar _t'10 (tptr (Tstruct _Area noattr)))
            (Tstruct _Area noattr)) _camera (tptr (Tstruct _Camera noattr))))
      (Ssequence
        (Sset _t'12
          (Efield
            (Ederef (Etempvar _t'11 (tptr (Tstruct _Camera noattr)))
              (Tstruct _Camera noattr)) _yaw tshort))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
              (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort)
          (Etempvar _t'12 tshort)))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'9
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionState tushort))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tushort)
                       (Econst_int (Int.repr 2) tint) tint)
          (Sset _t'1 (Ecast (Econst_int (Int.repr 180) tint) tint))
          (Sset _t'1 (Ecast (Econst_int (Int.repr 179) tint) tint))))
      (Scall None
        (Evar _set_mario_animation (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tint :: nil) tshort cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Etempvar _t'1 tint) :: nil)))
    (Ssequence
      (Ssequence
        (Sset _t'8
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _marioObj
            (tptr (Tstruct _Object noattr))))
        (Scall None
          (Evar _vec3f_copy (Tfunction
                              ((tptr tfloat) :: (tptr tfloat) :: nil)
                              (tptr tvoid) cc_default))
          ((Efield
             (Efield
               (Efield
                 (Ederef (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                   (Tstruct _Object noattr)) _header
                 (Tstruct _ObjectNode noattr)) _gfx
               (Tstruct _GraphNodeObject noattr)) _pos (tarray tfloat 3)) ::
           (Efield
             (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
               (Tstruct _MarioState noattr)) _pos (tarray tfloat 3)) :: nil)))
      (Ssequence
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioObj
              (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'7
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _faceAngle
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort))
            (Scall None
              (Evar _vec3s_set (Tfunction
                                 ((tptr tshort) :: tshort :: tshort ::
                                  tshort :: nil) (tptr tvoid) cc_default))
              ((Efield
                 (Efield
                   (Efield
                     (Ederef (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                       (Tstruct _Object noattr)) _header
                     (Tstruct _ObjectNode noattr)) _gfx
                   (Tstruct _GraphNodeObject noattr)) _angle
                 (tarray tshort 3)) :: (Econst_int (Int.repr 0) tint) ::
               (Etempvar _t'7 tshort) :: (Econst_int (Int.repr 0) tint) ::
               nil))))
        (Ssequence
          (Scall None
            (Evar _general_star_dance_handler (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tint :: nil) tvoid
                                                cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 1) tint) :: nil))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'4
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionState tushort))
                (Sifthenelse (Ebinop One (Etempvar _t'4 tushort)
                               (Econst_int (Int.repr 2) tint) tint)
                  (Ssequence
                    (Sset _t'5
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionTimer tushort))
                    (Sset _t'2
                      (Ecast
                        (Ebinop Oge (Etempvar _t'5 tushort)
                          (Econst_int (Int.repr 62) tint) tint) tbool)))
                  (Sset _t'2 (Econst_int (Int.repr 0) tint))))
              (Sifthenelse (Etempvar _t'2 tint)
                (Ssequence
                  (Sset _t'3
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _marioBodyState
                      (tptr (Tstruct _MarioBodyState noattr))))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _t'3 (tptr (Tstruct _MarioBodyState noattr)))
                        (Tstruct _MarioBodyState noattr)) _handState tschar)
                    (Econst_int (Int.repr 2) tint)))
                Sskip))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_fall_after_star_grab := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tuint) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tuint) ::
               (_t'8, tuint) :: (_t'7, tshort) :: (_t'6, tfloat) ::
               (_t'5, tuint) :: (_t'4, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
          (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
    (Ssequence
      (Sset _t'7
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _waterLevel tshort))
      (Sifthenelse (Ebinop Olt (Etempvar _t'6 tfloat)
                     (Ebinop Osub (Etempvar _t'7 tshort)
                       (Econst_int (Int.repr 130) tint) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'10
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
                         (Ecast (Econst_int (Int.repr 0) tint) tuint)
                         (Econst_int (Int.repr 28) tint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 48) tint) tuint)
                         (Econst_int (Int.repr 16) tint) tuint) tuint)
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 192) tint) tuint)
                       (Econst_int (Int.repr 8) tint) tuint) tuint)
                   (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                     (Econst_int (Int.repr 128) tint) tint) tuint)
                 (Econst_int (Int.repr 1) tint) tuint) ::
               (Efield
                 (Efield
                   (Efield
                     (Ederef (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                       (Tstruct _Object noattr)) _header
                     (Tstruct _ObjectNode noattr)) _gfx
                   (Tstruct _GraphNodeObject noattr)) _cameraToObject
                 (tarray tfloat 3)) :: nil)))
          (Ssequence
            (Ssequence
              (Sset _t'9
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _particleFlags tuint))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _particleFlags tuint)
                (Ebinop Oor (Etempvar _t'9 tuint)
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 6) tint) tint) tuint)))
            (Ssequence
              (Ssequence
                (Sset _t'8
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionArg tuint))
                (Scall (Some _t'1)
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 4867) tint) ::
                   (Etempvar _t'8 tuint) :: nil)))
              (Sreturn (Some (Etempvar _t'1 tuint))))))
        Sskip)))
  (Ssequence
    (Ssequence
      (Scall (Some _t'3)
        (Evar _perform_air_step (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   tuint :: nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 1) tint) :: nil))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tint)
                     (Econst_int (Int.repr 1) tint) tint)
        (Ssequence
          (Scall None
            (Evar _play_mario_landing_sound (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: nil) tvoid
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
                       (Ecast (Econst_int (Int.repr 8) tint) tuint)
                       (Econst_int (Int.repr 16) tint) tuint) tuint)
                   (Ebinop Oshl
                     (Ecast (Econst_int (Int.repr 128) tint) tuint)
                     (Econst_int (Int.repr 8) tint) tuint) tuint)
                 (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                   (Econst_int (Int.repr 128) tint) tint) tuint)
               (Econst_int (Int.repr 1) tint) tuint) :: nil))
          (Ssequence
            (Ssequence
              (Sset _t'5
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionArg tuint))
              (Sifthenelse (Ebinop Oand (Etempvar _t'5 tuint)
                             (Econst_int (Int.repr 1) tint) tuint)
                (Sset _t'2 (Ecast (Econst_int (Int.repr 4871) tint) tint))
                (Sset _t'2 (Ecast (Econst_int (Int.repr 4866) tint) tint))))
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionArg tuint))
              (Scall None
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Etempvar _t'2 tint) :: (Etempvar _t'4 tuint) :: nil)))))
        Sskip))
    (Ssequence
      (Scall None
        (Evar _set_mario_animation (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tint :: nil) tshort cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 86) tint) :: nil))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_common_death_handler := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_animation, tint) :: (_frameToDeathWarp, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_animFrame, tint) :: (_t'1, tshort) ::
               (_t'2, (tptr (Tstruct _MarioBodyState noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _set_mario_animation (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _animation tint) :: nil))
    (Sset _animFrame (Etempvar _t'1 tshort)))
  (Ssequence
    (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                   (Etempvar _frameToDeathWarp tint) tint)
      (Scall None
        (Evar _level_trigger_warp (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tint :: nil) tshort cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 18) tint) :: nil))
      Sskip)
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _marioBodyState
            (tptr (Tstruct _MarioBodyState noattr))))
        (Sassign
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _MarioBodyState noattr)))
              (Tstruct _MarioBodyState noattr)) _eyeState tschar)
          (Econst_int (Int.repr 8) tint)))
      (Ssequence
        (Scall None
          (Evar _stop_and_set_height_to_floor (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Sreturn (Some (Etempvar _animFrame tint)))))))
|}.

Definition f_act_standing_death := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: (_t'4, tushort) :: (_t'3, tshort) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'4 tushort)
                   (Econst_int (Int.repr 256) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 135956) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
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
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 2) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 21) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 255) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) ::
       (Econst_int (Int.repr 65536) tint) :: nil))
    (Ssequence
      (Scall None
        (Evar _common_death_handler (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tint :: tint :: nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 50) tint) ::
         (Econst_int (Int.repr 80) tint) :: nil))
      (Ssequence
        (Ssequence
          (Sset _t'2
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioObj
              (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'3
              (Efield
                (Efield
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _header
                      (Tstruct _ObjectNode noattr)) _gfx
                    (Tstruct _GraphNodeObject noattr)) _animInfo
                  (Tstruct _AnimInfo noattr)) _animFrame tshort))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tshort)
                           (Econst_int (Int.repr 77) tint) tint)
              (Scall None
                (Evar _play_mario_landing_sound (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: nil) tvoid
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
                           (Ecast (Econst_int (Int.repr 24) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 128) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                       (Econst_int (Int.repr 128) tint) tint) tuint)
                   (Econst_int (Int.repr 1) tint) tuint) :: nil))
              Sskip)))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_electrocution := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _play_sound_if_no_flag (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tuint :: tuint :: nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Ebinop Oor
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 2) tint) tuint)
               (Econst_int (Int.repr 28) tint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 21) tint) tuint)
               (Econst_int (Int.repr 16) tint) tuint) tuint)
           (Ebinop Oshl (Ecast (Econst_int (Int.repr 255) tint) tuint)
             (Econst_int (Int.repr 8) tint) tuint) tuint)
         (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
           (Econst_int (Int.repr 128) tint) tint) tuint)
       (Econst_int (Int.repr 1) tint) tuint) ::
     (Econst_int (Int.repr 65536) tint) :: nil))
  (Ssequence
    (Scall None
      (Evar _common_death_handler (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tint :: tint :: nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 121) tint) :: (Econst_int (Int.repr 43) tint) ::
       nil))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_suffocation := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _play_sound_if_no_flag (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tuint :: tuint :: nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Ebinop Oor
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 2) tint) tuint)
               (Econst_int (Int.repr 28) tint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 21) tint) tuint)
               (Econst_int (Int.repr 16) tint) tuint) tuint)
           (Ebinop Oshl (Ecast (Econst_int (Int.repr 255) tint) tuint)
             (Econst_int (Int.repr 8) tint) tuint) tuint)
         (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
           (Econst_int (Int.repr 128) tint) tint) tuint)
       (Econst_int (Int.repr 1) tint) tuint) ::
     (Econst_int (Int.repr 65536) tint) :: nil))
  (Ssequence
    (Scall None
      (Evar _common_death_handler (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tint :: tint :: nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 47) tint) :: (Econst_int (Int.repr 86) tint) ::
       nil))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_death_on_back := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _play_sound_if_no_flag (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tuint :: tuint :: nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Ebinop Oor
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 2) tint) tuint)
               (Econst_int (Int.repr 28) tint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 21) tint) tuint)
               (Econst_int (Int.repr 16) tint) tuint) tuint)
           (Ebinop Oshl (Ecast (Econst_int (Int.repr 255) tint) tuint)
             (Econst_int (Int.repr 8) tint) tuint) tuint)
         (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
           (Econst_int (Int.repr 128) tint) tint) tuint)
       (Econst_int (Int.repr 1) tint) tuint) ::
     (Econst_int (Int.repr 65536) tint) :: nil))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _common_death_handler (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tint :: tint :: nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 3) tint) :: (Econst_int (Int.repr 54) tint) ::
         nil))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tint)
                     (Econst_int (Int.repr 40) tint) tint)
        (Scall None
          (Evar _play_mario_heavy_landing_sound (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: nil) tvoid
                                                  cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                     (Econst_int (Int.repr 28) tint) tuint)
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 24) tint) tuint)
                     (Econst_int (Int.repr 16) tint) tuint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                   (Econst_int (Int.repr 8) tint) tuint) tuint)
               (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                 (Econst_int (Int.repr 128) tint) tint) tuint)
             (Econst_int (Int.repr 1) tint) tuint) :: nil))
        Sskip))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_death_on_stomach := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _play_sound_if_no_flag (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tuint :: tuint :: nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Ebinop Oor
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 2) tint) tuint)
               (Econst_int (Int.repr 28) tint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 21) tint) tuint)
               (Econst_int (Int.repr 16) tint) tuint) tuint)
           (Ebinop Oshl (Ecast (Econst_int (Int.repr 255) tint) tuint)
             (Econst_int (Int.repr 8) tint) tuint) tuint)
         (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
           (Econst_int (Int.repr 128) tint) tint) tuint)
       (Econst_int (Int.repr 1) tint) tuint) ::
     (Econst_int (Int.repr 65536) tint) :: nil))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _common_death_handler (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tint :: tint :: nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 46) tint) ::
         (Econst_int (Int.repr 37) tint) :: nil))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tint)
                     (Econst_int (Int.repr 37) tint) tint)
        (Scall None
          (Evar _play_mario_heavy_landing_sound (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: nil) tvoid
                                                  cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                     (Econst_int (Int.repr 28) tint) tuint)
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 24) tint) tuint)
                     (Econst_int (Int.repr 16) tint) tuint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                   (Econst_int (Int.repr 8) tint) tuint) tuint)
               (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                 (Econst_int (Int.repr 128) tint) tint) tuint)
             (Econst_int (Int.repr 1) tint) tuint) :: nil))
        Sskip))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_quicksand_death := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tfloat) :: (_t'6, tushort) :: (_t'5, tfloat) ::
               (_t'4, tfloat) :: (_t'3, tushort) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionState tushort))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'6 tushort)
                   (Econst_int (Int.repr 0) tint) tint)
      (Ssequence
        (Scall None
          (Evar _set_mario_animation (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tint :: nil) tshort cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 118) tint) :: nil))
        (Ssequence
          (Scall None
            (Evar _set_anim_to_frame (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tshort :: nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 60) tint) :: nil))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionState tushort)
            (Econst_int (Int.repr 1) tint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionState tushort))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tushort)
                     (Econst_int (Int.repr 1) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'5
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _quicksandDepth tfloat))
            (Sifthenelse (Ebinop Oge (Etempvar _t'5 tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                           tint)
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
                           (Ecast (Econst_int (Int.repr 16) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 192) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                       (Econst_int (Int.repr 128) tint) tint) tuint)
                   (Econst_int (Int.repr 1) tint) tuint) ::
                 (Econst_int (Int.repr 65536) tint) :: nil))
              Sskip))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'4
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _quicksandDepth tfloat))
                (Sset _t'1
                  (Ecast
                    (Ebinop Oadd (Etempvar _t'4 tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1084227584)) tfloat)
                      tfloat) tfloat)))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _quicksandDepth tfloat)
                (Etempvar _t'1 tfloat)))
            (Sifthenelse (Ebinop Oge (Etempvar _t'1 tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 1127481344)) tfloat)
                           tint)
              (Ssequence
                (Scall None
                  (Evar _level_trigger_warp (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tint :: nil) tshort
                                              cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 18) tint) :: nil))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionState tushort)
                  (Econst_int (Int.repr 2) tint)))
              Sskip)))
        Sskip))
    (Ssequence
      (Scall None
        (Evar _stationary_ground_step (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Ssequence
        (Ssequence
          (Sset _t'2
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioObj
              (tptr (Tstruct _Object noattr))))
          (Scall None
            (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                                cc_default))
            ((Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 1) tint) tuint)
                       (Econst_int (Int.repr 28) tint) tuint)
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 20) tint) tuint)
                       (Econst_int (Int.repr 16) tint) tuint) tuint)
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                     (Econst_int (Int.repr 8) tint) tuint) tuint)
                 (Econst_int (Int.repr 67108864) tint) tuint)
               (Econst_int (Int.repr 1) tint) tuint) ::
             (Efield
               (Efield
                 (Efield
                   (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                     (Tstruct _Object noattr)) _header
                   (Tstruct _ObjectNode noattr)) _gfx
                 (Tstruct _GraphNodeObject noattr)) _cameraToObject
               (tarray tfloat 3)) :: nil)))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_eaten_by_bubba := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tushort) :: (_t'4, tshort) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _play_sound_if_no_flag (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tuint :: tuint :: nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Ebinop Oor
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 2) tint) tuint)
               (Econst_int (Int.repr 28) tint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 21) tint) tuint)
               (Econst_int (Int.repr 16) tint) tuint) tuint)
           (Ebinop Oshl (Ecast (Econst_int (Int.repr 255) tint) tuint)
             (Econst_int (Int.repr 8) tint) tuint) tuint)
         (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
           (Econst_int (Int.repr 128) tint) tint) tuint)
       (Econst_int (Int.repr 1) tint) tuint) ::
     (Econst_int (Int.repr 65536) tint) :: nil))
  (Ssequence
    (Scall None
      (Evar _set_mario_animation (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 14) tint) :: nil))
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _marioObj
            (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioObj
              (tptr (Tstruct _Object noattr))))
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
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _health tshort)
          (Econst_int (Int.repr 255) tint))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'1
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionTimer tushort))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionTimer tushort)
                (Ebinop Oadd (Etempvar _t'1 tushort)
                  (Econst_int (Int.repr 1) tint) tint)))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tushort)
                           (Econst_int (Int.repr 60) tint) tint)
              (Scall None
                (Evar _level_trigger_warp (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tint :: nil) tshort cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 18) tint) :: nil))
              Sskip))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_launch_mario_until_land := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_endAction, tint) :: (_animation, tint) ::
                (_forwardVel, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_airStepLanded, tint) :: (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _mario_set_forward_vel (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tfloat :: nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Etempvar _forwardVel tfloat) :: nil))
  (Ssequence
    (Scall None
      (Evar _set_mario_animation (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _animation tint) :: nil))
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _perform_air_step (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sset _airStepLanded
          (Ebinop Oeq (Etempvar _t'1 tint) (Econst_int (Int.repr 1) tint)
            tint)))
      (Ssequence
        (Sifthenelse (Etempvar _airStepLanded tint)
          (Scall None
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _endAction tint) :: (Econst_int (Int.repr 0) tint) ::
             nil))
          Sskip)
        (Sreturn (Some (Etempvar _airStepLanded tint)))))))
|}.

Definition f_act_unlocking_key_door := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'21, tint) ::
               (_t'20, (tptr (Tstruct _Object noattr))) :: (_t'19, tfloat) ::
               (_t'18, tshort) :: (_t'17, tfloat) ::
               (_t'16, (tptr (Tstruct _Object noattr))) :: (_t'15, tfloat) ::
               (_t'14, tshort) :: (_t'13, tfloat) ::
               (_t'12, (tptr (Tstruct _Object noattr))) :: (_t'11, tshort) ::
               (_t'10, tuint) :: (_t'9, tushort) ::
               (_t'8, (tptr (Tstruct _Object noattr))) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tshort) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: (_t'4, tint) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: (_t'2, tushort) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'20
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _usedObj
        (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'21
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'20 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __729 noattr))
              _asS32 (tarray tint 80))
            (Ebinop Oadd (Econst_int (Int.repr 15) tint)
              (Econst_int (Int.repr 1) tint) tint) (tptr tint)) tint))
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
            (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort)
        (Etempvar _t'21 tint))))
  (Ssequence
    (Ssequence
      (Sset _t'16
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _usedObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'17
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'16 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __729 noattr))
                _asF32 (tarray tfloat 80))
              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                (Econst_int (Int.repr 0) tint) tint) (tptr tfloat)) tfloat))
        (Ssequence
          (Sset _t'18
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _faceAngle
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort))
          (Ssequence
            (Sset _t'19
              (Ederef
                (Ebinop Oadd
                  (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                    (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                  (Ebinop Oshr (Ecast (Etempvar _t'18 tshort) tushort)
                    (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                tfloat))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
              (Ebinop Oadd (Etempvar _t'17 tfloat)
                (Ebinop Omul (Etempvar _t'19 tfloat)
                  (Econst_single (Float32.of_bits (Int.repr 1117126656)) tfloat)
                  tfloat) tfloat))))))
    (Ssequence
      (Ssequence
        (Sset _t'12
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _usedObj
            (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'13
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'12 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __729 noattr)) _asF32 (tarray tfloat 80))
                (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                  (Econst_int (Int.repr 2) tint) tint) (tptr tfloat)) tfloat))
          (Ssequence
            (Sset _t'14
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _faceAngle
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort))
            (Ssequence
              (Sset _t'15
                (Ederef
                  (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                    (Ebinop Oshr (Ecast (Etempvar _t'14 tshort) tushort)
                      (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                  tfloat))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                    (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat)
                (Ebinop Oadd (Etempvar _t'13 tfloat)
                  (Ebinop Omul (Etempvar _t'15 tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1117126656)) tfloat)
                    tfloat) tfloat))))))
      (Ssequence
        (Ssequence
          (Sset _t'10
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionArg tuint))
          (Sifthenelse (Ebinop Oand (Etempvar _t'10 tuint)
                         (Econst_int (Int.repr 2) tint) tuint)
            (Ssequence
              (Sset _t'11
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _faceAngle
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
                (Ebinop Oadd (Etempvar _t'11 tshort)
                  (Econst_int (Int.repr 32768) tint) tint)))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'9
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tushort)
                           (Econst_int (Int.repr 0) tint) tint)
              (Ssequence
                (Scall None
                  (Evar _spawn_obj_at_mario_rel_yaw (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tint ::
                                                       (tptr tuint) ::
                                                       tshort :: nil)
                                                      (tptr (Tstruct _Object noattr))
                                                      cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 200) tint) ::
                   (Evar _bhvBowserKeyUnlockDoor (tarray tuint 0)) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                (Scall None
                  (Evar _set_mario_animation (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tint :: nil) tshort
                                               cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 97) tint) :: nil)))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'5
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioObj
                  (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'6
                  (Efield
                    (Efield
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _header
                          (Tstruct _ObjectNode noattr)) _gfx
                        (Tstruct _GraphNodeObject noattr)) _animInfo
                      (Tstruct _AnimInfo noattr)) _animFrame tshort))
                (Sswitch (Etempvar _t'6 tshort)
                  (LScons (Some 79)
                    (Ssequence
                      (Ssequence
                        (Sset _t'8
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
                                     (Ecast (Econst_int (Int.repr 3) tint)
                                       tuint) (Econst_int (Int.repr 28) tint)
                                     tuint)
                                   (Ebinop Oshl
                                     (Ecast (Econst_int (Int.repr 66) tint)
                                       tuint) (Econst_int (Int.repr 16) tint)
                                     tuint) tuint)
                                 (Ebinop Oshl
                                   (Ecast (Econst_int (Int.repr 0) tint)
                                     tuint) (Econst_int (Int.repr 8) tint)
                                   tuint) tuint)
                               (Econst_int (Int.repr 128) tint) tuint)
                             (Econst_int (Int.repr 1) tint) tuint) ::
                           (Efield
                             (Efield
                               (Efield
                                 (Ederef
                                   (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                                   (Tstruct _Object noattr)) _header
                                 (Tstruct _ObjectNode noattr)) _gfx
                               (Tstruct _GraphNodeObject noattr))
                             _cameraToObject (tarray tfloat 3)) :: nil)))
                      Sbreak)
                    (LScons (Some 111)
                      (Ssequence
                        (Ssequence
                          (Sset _t'7
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _marioObj
                              (tptr (Tstruct _Object noattr))))
                          (Scall None
                            (Evar _play_sound (Tfunction
                                                (tint :: (tptr tfloat) ::
                                                 nil) tvoid cc_default))
                            ((Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oor
                                   (Ebinop Oor
                                     (Ebinop Oshl
                                       (Ecast (Econst_int (Int.repr 3) tint)
                                         tuint)
                                       (Econst_int (Int.repr 28) tint) tuint)
                                     (Ebinop Oshl
                                       (Ecast (Econst_int (Int.repr 59) tint)
                                         tuint)
                                       (Econst_int (Int.repr 16) tint) tuint)
                                     tuint)
                                   (Ebinop Oshl
                                     (Ecast (Econst_int (Int.repr 0) tint)
                                       tuint) (Econst_int (Int.repr 8) tint)
                                     tuint) tuint)
                                 (Econst_int (Int.repr 128) tint) tuint)
                               (Econst_int (Int.repr 1) tint) tuint) ::
                             (Efield
                               (Efield
                                 (Efield
                                   (Ederef
                                     (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                                     (Tstruct _Object noattr)) _header
                                   (Tstruct _ObjectNode noattr)) _gfx
                                 (Tstruct _GraphNodeObject noattr))
                               _cameraToObject (tarray tfloat 3)) :: nil)))
                        Sbreak)
                      LSnil)))))
            (Ssequence
              (Scall None
                (Evar _update_mario_pos_for_anim (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    nil) tvoid cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Ssequence
                (Scall None
                  (Evar _stop_and_set_height_to_floor (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tvoid
                                                        cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'1)
                      (Evar _is_anim_at_end (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Sifthenelse (Etempvar _t'1 tint)
                      (Ssequence
                        (Ssequence
                          (Sset _t'3
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _usedObj
                              (tptr (Tstruct _Object noattr))))
                          (Ssequence
                            (Sset _t'4
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _rawData
                                      (Tunion __729 noattr)) _asS32
                                    (tarray tint 80))
                                  (Econst_int (Int.repr 64) tint)
                                  (tptr tint)) tint))
                            (Sifthenelse (Ebinop Oeq
                                           (Ebinop Oshr (Etempvar _t'4 tint)
                                             (Econst_int (Int.repr 24) tint)
                                             tint)
                                           (Econst_int (Int.repr 1) tint)
                                           tint)
                              (Ssequence
                                (Scall None
                                  (Evar _save_file_set_flags (Tfunction
                                                               (tuint :: nil)
                                                               tvoid
                                                               cc_default))
                                  ((Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 7) tint) tint) ::
                                   nil))
                                (Scall None
                                  (Evar _save_file_clear_flags (Tfunction
                                                                 (tuint ::
                                                                  nil) tvoid
                                                                 cc_default))
                                  ((Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 5) tint) tint) ::
                                   nil)))
                              (Ssequence
                                (Scall None
                                  (Evar _save_file_set_flags (Tfunction
                                                               (tuint :: nil)
                                                               tvoid
                                                               cc_default))
                                  ((Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 6) tint) tint) ::
                                   nil))
                                (Scall None
                                  (Evar _save_file_clear_flags (Tfunction
                                                                 (tuint ::
                                                                  nil) tvoid
                                                                 cc_default))
                                  ((Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 4) tint) tint) ::
                                   nil))))))
                        (Scall None
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 67109952) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil)))
                      Sskip))
                  (Ssequence
                    (Ssequence
                      (Sset _t'2
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionTimer
                          tushort))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionTimer
                          tushort)
                        (Ebinop Oadd (Etempvar _t'2 tushort)
                          (Econst_int (Int.repr 1) tint) tint)))
                    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))))
|}.

Definition f_act_unlocking_star_door := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tint) :: (_t'3, tuint) :: (_t'2, tushort) ::
               (_t'1, tint) :: (_t'22, tint) ::
               (_t'21, (tptr (Tstruct _Object noattr))) :: (_t'20, tshort) ::
               (_t'19, tuint) :: (_t'18, tfloat) ::
               (_t'17, (tptr (Tstruct _Object noattr))) :: (_t'16, tfloat) ::
               (_t'15, (tptr (Tstruct _Object noattr))) ::
               (_t'14, tushort) ::
               (_t'13, (tptr (Tstruct _Object noattr))) ::
               (_t'12, tushort) :: (_t'11, tushort) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tushort) ::
               (_t'8, tfloat) :: (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, tfloat) :: (_t'5, (tptr (Tstruct _Object noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionState tushort))
    (Sswitch (Etempvar _t'9 tushort)
      (LScons (Some 0)
        (Ssequence
          (Ssequence
            (Sset _t'21
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _usedObj
                (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'22
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'21 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __729 noattr)) _asS32 (tarray tint 80))
                    (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                      (Econst_int (Int.repr 1) tint) tint) (tptr tint)) tint))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _faceAngle
                      (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                    (tptr tshort)) tshort) (Etempvar _t'22 tint))))
          (Ssequence
            (Ssequence
              (Sset _t'19
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionArg tuint))
              (Sifthenelse (Ebinop Oand (Etempvar _t'19 tuint)
                             (Econst_int (Int.repr 2) tint) tuint)
                (Ssequence
                  (Sset _t'20
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _faceAngle
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
                    (Ebinop Oadd (Etempvar _t'20 tshort)
                      (Econst_int (Int.repr 32768) tint) tint)))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'17
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _marioObj
                    (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'18
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _pos
                          (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tfloat)) tfloat))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'17 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __729 noattr)) _asF32 (tarray tfloat 80))
                        (Econst_int (Int.repr 33) tint) (tptr tfloat))
                      tfloat) (Etempvar _t'18 tfloat))))
              (Ssequence
                (Ssequence
                  (Sset _t'15
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _marioObj
                      (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sset _t'16
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _pos
                            (tarray tfloat 3)) (Econst_int (Int.repr 2) tint)
                          (tptr tfloat)) tfloat))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'15 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __729 noattr)) _asF32
                            (tarray tfloat 80))
                          (Econst_int (Int.repr 34) tint) (tptr tfloat))
                        tfloat) (Etempvar _t'16 tfloat))))
                (Ssequence
                  (Scall None
                    (Evar _set_mario_animation (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tint :: nil) tshort
                                                 cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 156) tint) :: nil))
                  (Ssequence
                    (Ssequence
                      (Sset _t'14
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionState
                          tushort))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionState
                          tushort)
                        (Ebinop Oadd (Etempvar _t'14 tushort)
                          (Econst_int (Int.repr 1) tint) tint)))
                    Sbreak))))))
        (LScons (Some 1)
          (Ssequence
            (Ssequence
              (Scall (Some _t'1)
                (Evar _is_anim_at_end (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sifthenelse (Etempvar _t'1 tint)
                (Ssequence
                  (Ssequence
                    (Sset _t'13
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _marioObj
                        (tptr (Tstruct _Object noattr))))
                    (Scall None
                      (Evar _spawn_object (Tfunction
                                            ((tptr (Tstruct _Object noattr)) ::
                                             tint :: (tptr tuint) :: nil)
                                            (tptr (Tstruct _Object noattr))
                                            cc_default))
                      ((Etempvar _t'13 (tptr (Tstruct _Object noattr))) ::
                       (Econst_int (Int.repr 122) tint) ::
                       (Evar _bhvUnlockDoorStar (tarray tuint 0)) :: nil)))
                  (Ssequence
                    (Sset _t'12
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionState tushort))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionState tushort)
                      (Ebinop Oadd (Etempvar _t'12 tushort)
                        (Econst_int (Int.repr 1) tint) tint))))
                Sskip))
            Sbreak)
          (LScons (Some 2)
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'2
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionTimer tushort))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionTimer tushort)
                    (Ebinop Oadd (Etempvar _t'2 tushort)
                      (Econst_int (Int.repr 1) tint) tint)))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tushort)
                               (Econst_int (Int.repr 70) tint) tint)
                  (Ssequence
                    (Scall None
                      (Evar _set_mario_animation (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: nil) tshort
                                                   cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 157) tint) :: nil))
                    (Ssequence
                      (Sset _t'11
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionState
                          tushort))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionState
                          tushort)
                        (Ebinop Oadd (Etempvar _t'11 tushort)
                          (Econst_int (Int.repr 1) tint) tint))))
                  Sskip))
              Sbreak)
            (LScons (Some 3)
              (Ssequence
                (Ssequence
                  (Scall (Some _t'4)
                    (Evar _is_anim_at_end (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Sifthenelse (Etempvar _t'4 tint)
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'10
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _usedObj
                              (tptr (Tstruct _Object noattr))))
                          (Scall (Some _t'3)
                            (Evar _get_door_save_file_flag (Tfunction
                                                             ((tptr (Tstruct _Object noattr)) ::
                                                              nil) tuint
                                                             cc_default))
                            ((Etempvar _t'10 (tptr (Tstruct _Object noattr))) ::
                             nil)))
                        (Scall None
                          (Evar _save_file_set_flags (Tfunction
                                                       (tuint :: nil) tvoid
                                                       cc_default))
                          ((Etempvar _t'3 tuint) :: nil)))
                      (Scall None
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 536875781) tint) ::
                         (Econst_int (Int.repr 38) tint) :: nil)))
                    Sskip))
                Sbreak)
              LSnil))))))
  (Ssequence
    (Ssequence
      (Sset _t'7
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'8
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __729 noattr))
                _asF32 (tarray tfloat 80)) (Econst_int (Int.repr 33) tint)
              (tptr tfloat)) tfloat))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
          (Etempvar _t'8 tfloat))))
    (Ssequence
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _marioObj
            (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'6
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __729 noattr)) _asF32 (tarray tfloat 80))
                (Econst_int (Int.repr 34) tint) (tptr tfloat)) tfloat))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat)
            (Etempvar _t'6 tfloat))))
      (Ssequence
        (Scall None
          (Evar _update_mario_pos_for_anim (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Ssequence
          (Scall None
            (Evar _stop_and_set_height_to_floor (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_entering_star_door := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_targetDX, tfloat) :: (_targetDZ, tfloat) ::
               (_targetAngle, tshort) :: (_t'2, tushort) :: (_t'1, tshort) ::
               (_t'35, (tptr (Tstruct _Object noattr))) :: (_t'34, tint) ::
               (_t'33, (tptr (Tstruct _Object noattr))) :: (_t'32, tuint) ::
               (_t'31, tfloat) :: (_t'30, tfloat) :: (_t'29, tfloat) ::
               (_t'28, (tptr (Tstruct _Object noattr))) :: (_t'27, tfloat) ::
               (_t'26, tfloat) :: (_t'25, tfloat) ::
               (_t'24, (tptr (Tstruct _Object noattr))) ::
               (_t'23, (tptr (Tstruct _Object noattr))) ::
               (_t'22, (tptr (Tstruct _Object noattr))) :: (_t'21, tfloat) ::
               (_t'20, (tptr (Tstruct _Object noattr))) :: (_t'19, tfloat) ::
               (_t'18, tfloat) :: (_t'17, (tptr (Tstruct _Object noattr))) ::
               (_t'16, tfloat) :: (_t'15, tint) ::
               (_t'14, (tptr (Tstruct _Object noattr))) :: (_t'13, tshort) ::
               (_t'12, tuint) :: (_t'11, tfloat) :: (_t'10, tshort) ::
               (_t'9, tfloat) :: (_t'8, tfloat) :: (_t'7, tshort) ::
               (_t'6, tfloat) :: (_t'5, tushort) :: (_t'4, tushort) ::
               (_t'3, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionTimer tushort))
      (Sassign
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionTimer tushort)
        (Ebinop Oadd (Etempvar _t'2 tushort) (Econst_int (Int.repr 1) tint)
          tint)))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tushort)
                   (Econst_int (Int.repr 0) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'35
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _interactObj
              (tptr (Tstruct _Object noattr))))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'35 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __729 noattr)) _asS32 (tarray tint 80))
                (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
              (Econst_int (Int.repr 16) tint) tint)))
        (Ssequence
          (Ssequence
            (Sset _t'33
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _usedObj
                (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'34
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'33 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __729 noattr)) _asS32 (tarray tint 80))
                    (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                      (Econst_int (Int.repr 1) tint) tint) (tptr tint)) tint))
              (Sset _targetAngle
                (Ecast
                  (Ebinop Oadd (Etempvar _t'34 tint)
                    (Econst_int (Int.repr 5461) tint) tint) tshort))))
          (Ssequence
            (Ssequence
              (Sset _t'32
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionArg tuint))
              (Sifthenelse (Ebinop Oand (Etempvar _t'32 tuint)
                             (Econst_int (Int.repr 2) tint) tuint)
                (Sset _targetAngle
                  (Ecast
                    (Ebinop Oadd (Etempvar _targetAngle tshort)
                      (Econst_int (Int.repr 21846) tint) tint) tshort))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'28
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _usedObj
                    (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'29
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'28 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __729 noattr)) _asF32 (tarray tfloat 80))
                        (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                          (Econst_int (Int.repr 0) tint) tint) (tptr tfloat))
                      tfloat))
                  (Ssequence
                    (Sset _t'30
                      (Ederef
                        (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                          (Ebinop Oshr
                            (Ecast (Etempvar _targetAngle tshort) tushort)
                            (Econst_int (Int.repr 4) tint) tint)
                          (tptr tfloat)) tfloat))
                    (Ssequence
                      (Sset _t'31
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _pos
                              (tarray tfloat 3))
                            (Econst_int (Int.repr 0) tint) (tptr tfloat))
                          tfloat))
                      (Sset _targetDX
                        (Ebinop Osub
                          (Ebinop Oadd (Etempvar _t'29 tfloat)
                            (Ebinop Omul
                              (Econst_single (Float32.of_bits (Int.repr 1125515264)) tfloat)
                              (Etempvar _t'30 tfloat) tfloat) tfloat)
                          (Etempvar _t'31 tfloat) tfloat))))))
              (Ssequence
                (Ssequence
                  (Sset _t'24
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _usedObj
                      (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sset _t'25
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'24 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __729 noattr)) _asF32
                            (tarray tfloat 80))
                          (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                            (Econst_int (Int.repr 2) tint) tint)
                          (tptr tfloat)) tfloat))
                    (Ssequence
                      (Sset _t'26
                        (Ederef
                          (Ebinop Oadd
                            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                              (Econst_int (Int.repr 1024) tint)
                              (tptr tfloat))
                            (Ebinop Oshr
                              (Ecast (Etempvar _targetAngle tshort) tushort)
                              (Econst_int (Int.repr 4) tint) tint)
                            (tptr tfloat)) tfloat))
                      (Ssequence
                        (Sset _t'27
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _pos
                                (tarray tfloat 3))
                              (Econst_int (Int.repr 2) tint) (tptr tfloat))
                            tfloat))
                        (Sset _targetDZ
                          (Ebinop Osub
                            (Ebinop Oadd (Etempvar _t'25 tfloat)
                              (Ebinop Omul
                                (Econst_single (Float32.of_bits (Int.repr 1125515264)) tfloat)
                                (Etempvar _t'26 tfloat) tfloat) tfloat)
                            (Etempvar _t'27 tfloat) tfloat))))))
                (Ssequence
                  (Ssequence
                    (Sset _t'23
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _marioObj
                        (tptr (Tstruct _Object noattr))))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'23 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __729 noattr)) _asF32
                            (tarray tfloat 80))
                          (Econst_int (Int.repr 33) tint) (tptr tfloat))
                        tfloat)
                      (Ebinop Odiv (Etempvar _targetDX tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1101004800)) tfloat)
                        tfloat)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'22
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _marioObj
                          (tptr (Tstruct _Object noattr))))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'22 (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _rawData
                                (Tunion __729 noattr)) _asF32
                              (tarray tfloat 80))
                            (Econst_int (Int.repr 34) tint) (tptr tfloat))
                          tfloat)
                        (Ebinop Odiv (Etempvar _targetDZ tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1101004800)) tfloat)
                          tfloat)))
                    (Ssequence
                      (Scall (Some _t'1)
                        (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil)
                                        tshort cc_default))
                        ((Etempvar _targetDZ tfloat) ::
                         (Etempvar _targetDX tfloat) :: nil))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _faceAngle
                              (tarray tshort 3))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))
                          tshort) (Etempvar _t'1 tshort))))))))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'4
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionTimer tushort))
      (Sifthenelse (Ebinop Olt (Etempvar _t'4 tushort)
                     (Econst_int (Int.repr 15) tint) tint)
        (Scall None
          (Evar _set_mario_animation (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tint :: nil) tshort cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 194) tint) :: nil))
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort))
          (Sifthenelse (Ebinop Olt (Etempvar _t'5 tushort)
                         (Econst_int (Int.repr 35) tint) tint)
            (Ssequence
              (Ssequence
                (Sset _t'19
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _pos
                        (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tfloat)) tfloat))
                (Ssequence
                  (Sset _t'20
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _marioObj
                      (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sset _t'21
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'20 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __729 noattr)) _asF32
                            (tarray tfloat 80))
                          (Econst_int (Int.repr 33) tint) (tptr tfloat))
                        tfloat))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _pos
                            (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                          (tptr tfloat)) tfloat)
                      (Ebinop Oadd (Etempvar _t'19 tfloat)
                        (Etempvar _t'21 tfloat) tfloat)))))
              (Ssequence
                (Ssequence
                  (Sset _t'16
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _pos
                          (tarray tfloat 3)) (Econst_int (Int.repr 2) tint)
                        (tptr tfloat)) tfloat))
                  (Ssequence
                    (Sset _t'17
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _marioObj
                        (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sset _t'18
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'17 (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _rawData
                                (Tunion __729 noattr)) _asF32
                              (tarray tfloat 80))
                            (Econst_int (Int.repr 34) tint) (tptr tfloat))
                          tfloat))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _pos
                              (tarray tfloat 3))
                            (Econst_int (Int.repr 2) tint) (tptr tfloat))
                          tfloat)
                        (Ebinop Oadd (Etempvar _t'16 tfloat)
                          (Etempvar _t'18 tfloat) tfloat)))))
                (Scall None
                  (Evar _set_mario_anim_with_accel (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tint :: tint :: nil)
                                                     tshort cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 72) tint) ::
                   (Econst_int (Int.repr 163840) tint) :: nil))))
            (Ssequence
              (Ssequence
                (Sset _t'14
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _usedObj
                    (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'15
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'14 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __729 noattr)) _asS32 (tarray tint 80))
                        (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                          (Econst_int (Int.repr 1) tint) tint) (tptr tint))
                      tint))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _faceAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tshort)) tshort) (Etempvar _t'15 tint))))
              (Ssequence
                (Ssequence
                  (Sset _t'12
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionArg tuint))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'12 tuint)
                                 (Econst_int (Int.repr 2) tint) tuint)
                    (Ssequence
                      (Sset _t'13
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _faceAngle
                              (tarray tshort 3))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))
                          tshort))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _faceAngle
                              (tarray tshort 3))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))
                          tshort)
                        (Ebinop Oadd (Etempvar _t'13 tshort)
                          (Econst_int (Int.repr 32768) tint) tint)))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sset _t'9
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _pos
                            (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                          (tptr tfloat)) tfloat))
                    (Ssequence
                      (Sset _t'10
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _faceAngle
                              (tarray tshort 3))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))
                          tshort))
                      (Ssequence
                        (Sset _t'11
                          (Ederef
                            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                              (Ebinop Oshr
                                (Ecast (Etempvar _t'10 tshort) tushort)
                                (Econst_int (Int.repr 4) tint) tint)
                              (tptr tfloat)) tfloat))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _pos
                                (tarray tfloat 3))
                              (Econst_int (Int.repr 0) tint) (tptr tfloat))
                            tfloat)
                          (Ebinop Oadd (Etempvar _t'9 tfloat)
                            (Ebinop Omul
                              (Econst_single (Float32.of_bits (Int.repr 1094713344)) tfloat)
                              (Etempvar _t'11 tfloat) tfloat) tfloat)))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'6
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _pos
                              (tarray tfloat 3))
                            (Econst_int (Int.repr 2) tint) (tptr tfloat))
                          tfloat))
                      (Ssequence
                        (Sset _t'7
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _faceAngle
                                (tarray tshort 3))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))
                            tshort))
                        (Ssequence
                          (Sset _t'8
                            (Ederef
                              (Ebinop Oadd
                                (Ebinop Oadd
                                  (Evar _gSineTable (tarray tfloat 0))
                                  (Econst_int (Int.repr 1024) tint)
                                  (tptr tfloat))
                                (Ebinop Oshr
                                  (Ecast (Etempvar _t'7 tshort) tushort)
                                  (Econst_int (Int.repr 4) tint) tint)
                                (tptr tfloat)) tfloat))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _pos
                                  (tarray tfloat 3))
                                (Econst_int (Int.repr 2) tint) (tptr tfloat))
                              tfloat)
                            (Ebinop Oadd (Etempvar _t'6 tfloat)
                              (Ebinop Omul
                                (Econst_single (Float32.of_bits (Int.repr 1094713344)) tfloat)
                                (Etempvar _t'8 tfloat) tfloat) tfloat)))))
                    (Scall None
                      (Evar _set_mario_anim_with_accel (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          tint :: tint ::
                                                          nil) tshort
                                                         cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 72) tint) ::
                       (Econst_int (Int.repr 163840) tint) :: nil))))))))))
    (Ssequence
      (Scall None
        (Evar _stop_and_set_height_to_floor (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tushort)
                         (Econst_int (Int.repr 48) tint) tint)
            (Scall None
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 205521409) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            Sskip))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_going_through_door := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'16, (tptr (Tstruct _Object noattr))) ::
               (_t'15, (tptr (Tstruct _Object noattr))) :: (_t'14, tuint) ::
               (_t'13, tushort) :: (_t'12, tint) ::
               (_t'11, (tptr (Tstruct _Object noattr))) :: (_t'10, tfloat) ::
               (_t'9, (tptr (Tstruct _Object noattr))) :: (_t'8, tfloat) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tushort) ::
               (_t'5, tshort) :: (_t'4, tuint) :: (_t'3, tuint) ::
               (_t'2, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'13
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionTimer tushort))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'13 tushort)
                   (Econst_int (Int.repr 0) tint) tint)
      (Ssequence
        (Sset _t'14
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionArg tuint))
        (Sifthenelse (Ebinop Oand (Etempvar _t'14 tuint)
                       (Econst_int (Int.repr 1) tint) tuint)
          (Ssequence
            (Ssequence
              (Sset _t'16
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _interactObj
                  (tptr (Tstruct _Object noattr))))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'16 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __729 noattr)) _asS32 (tarray tint 80))
                    (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 16) tint) tint)))
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 95) tint) :: nil)))
          (Ssequence
            (Ssequence
              (Sset _t'15
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _interactObj
                  (tptr (Tstruct _Object noattr))))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'15 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __729 noattr)) _asS32 (tarray tint 80))
                    (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 17) tint) tint)))
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 96) tint) :: nil)))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'11
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _usedObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'12
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'11 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __729 noattr))
                _asS32 (tarray tint 80))
              (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                (Econst_int (Int.repr 1) tint) tint) (tptr tint)) tint))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
              (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort)
          (Etempvar _t'12 tint))))
    (Ssequence
      (Ssequence
        (Sset _t'9
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _usedObj
            (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'10
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __729 noattr)) _asF32 (tarray tfloat 80))
                (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                  (Econst_int (Int.repr 0) tint) tint) (tptr tfloat)) tfloat))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
            (Etempvar _t'10 tfloat))))
      (Ssequence
        (Ssequence
          (Sset _t'7
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _usedObj
              (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'8
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __729 noattr)) _asF32 (tarray tfloat 80))
                  (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                    (Econst_int (Int.repr 2) tint) tint) (tptr tfloat))
                tfloat))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat)
              (Etempvar _t'8 tfloat))))
        (Ssequence
          (Scall None
            (Evar _update_mario_pos_for_anim (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Scall None
              (Evar _stop_and_set_height_to_floor (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Ssequence
              (Ssequence
                (Sset _t'3
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionArg tuint))
                (Sifthenelse (Ebinop Oand (Etempvar _t'3 tuint)
                               (Econst_int (Int.repr 4) tint) tuint)
                  (Ssequence
                    (Sset _t'6
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionTimer tushort))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'6 tushort)
                                   (Econst_int (Int.repr 16) tint) tint)
                      (Scall None
                        (Evar _level_trigger_warp (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tint :: nil) tshort
                                                    cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 3) tint) :: nil))
                      Sskip))
                  (Ssequence
                    (Scall (Some _t'1)
                      (Evar _is_anim_at_end (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Sifthenelse (Etempvar _t'1 tint)
                      (Ssequence
                        (Ssequence
                          (Sset _t'4
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _actionArg
                              tuint))
                          (Sifthenelse (Ebinop Oand (Etempvar _t'4 tuint)
                                         (Econst_int (Int.repr 2) tint)
                                         tuint)
                            (Ssequence
                              (Sset _t'5
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _faceAngle (tarray tshort 3))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr tshort)) tshort))
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _faceAngle (tarray tshort 3))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr tshort)) tshort)
                                (Ebinop Oadd (Etempvar _t'5 tshort)
                                  (Econst_int (Int.repr 32768) tint) tint)))
                            Sskip))
                        (Scall None
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 205521409) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil)))
                      Sskip))))
              (Ssequence
                (Ssequence
                  (Sset _t'2
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionTimer tushort))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionTimer tushort)
                    (Ebinop Oadd (Etempvar _t'2 tushort)
                      (Econst_int (Int.repr 1) tint) tint)))
                (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))
|}.

Definition f_act_warp_door_spawn := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'9, (tptr (Tstruct _Object noattr))) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tuint) ::
               (_t'6, tshort) :: (_t'5, tschar) :: (_t'4, tint) ::
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
          (Sset _t'7
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionArg tuint))
          (Sifthenelse (Ebinop Oand (Etempvar _t'7 tuint)
                         (Econst_int (Int.repr 1) tint) tuint)
            (Ssequence
              (Sset _t'9
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _usedObj
                  (tptr (Tstruct _Object noattr))))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __729 noattr)) _asS32 (tarray tint 80))
                    (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 18) tint) tint)))
            (Ssequence
              (Sset _t'8
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _usedObj
                  (tptr (Tstruct _Object noattr))))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __729 noattr)) _asS32 (tarray tint 80))
                    (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 19) tint) tint))))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _usedObj
            (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'4
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __729 noattr)) _asS32 (tarray tint 80))
                (Econst_int (Int.repr 49) tint) (tptr tint)) tint))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tint)
                         (Econst_int (Int.repr 0) tint) tint)
            (Ssequence
              (Ssequence
                (Sset _t'5 (Evar _gNeverEnteredCastle tschar))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tschar)
                               (Econst_int (Int.repr 1) tint) tint)
                  (Ssequence
                    (Sset _t'6 (Evar _gCurrLevelNum tshort))
                    (Sset _t'1
                      (Ecast
                        (Ebinop Oeq (Etempvar _t'6 tshort)
                          (Econst_int (Int.repr 6) tint) tint) tbool)))
                  (Sset _t'1 (Econst_int (Int.repr 0) tint))))
              (Sifthenelse (Etempvar _t'1 tint)
                (Scall None
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 536875781) tint) ::
                   (Econst_int (Int.repr 21) tint) :: nil))
                (Scall None
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 205521409) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))))
            Sskip)))))
  (Ssequence
    (Scall None
      (Evar _set_mario_animation (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 194) tint) :: nil))
    (Ssequence
      (Scall None
        (Evar _stop_and_set_height_to_floor (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_act_emerge_from_pipe := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_t'2, tint) :: (_t'1, tushort) :: (_t'6, tshort) ::
               (_t'5, tshort) :: (_t'4, tshort) :: (_t'3, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _marioObj
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'1
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort)
          (Ebinop Oadd (Etempvar _t'1 tushort) (Econst_int (Int.repr 1) tint)
            tint)))
      (Sifthenelse (Ebinop Olt (Etempvar _t'1 tushort)
                     (Econst_int (Int.repr 11) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'6
              (Efield
                (Efield
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _header
                      (Tstruct _ObjectNode noattr)) _gfx
                    (Tstruct _GraphNodeObject noattr)) _node
                  (Tstruct _GraphNode noattr)) _flags tshort))
            (Sassign
              (Efield
                (Efield
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _header
                      (Tstruct _ObjectNode noattr)) _gfx
                    (Tstruct _GraphNodeObject noattr)) _node
                  (Tstruct _GraphNode noattr)) _flags tshort)
              (Ebinop Oand (Etempvar _t'6 tshort)
                (Eunop Onotint
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 0) tint) tint) tint) tint)))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'5
          (Efield
            (Efield
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _header
                  (Tstruct _ObjectNode noattr)) _gfx
                (Tstruct _GraphNodeObject noattr)) _node
              (Tstruct _GraphNode noattr)) _flags tshort))
        (Sassign
          (Efield
            (Efield
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _header
                  (Tstruct _ObjectNode noattr)) _gfx
                (Tstruct _GraphNodeObject noattr)) _node
              (Tstruct _GraphNode noattr)) _flags tshort)
          (Ebinop Oor (Etempvar _t'5 tshort)
            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
              (Econst_int (Int.repr 0) tint) tint) tint)))
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
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 2) tint) tuint)
                     (Econst_int (Int.repr 28) tint) tuint)
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 4) tint) tuint)
                     (Econst_int (Int.repr 16) tint) tuint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                   (Econst_int (Int.repr 8) tint) tuint) tuint)
               (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                 (Econst_int (Int.repr 128) tint) tint) tuint)
             (Econst_int (Int.repr 1) tint) tuint) ::
           (Econst_int (Int.repr 131072) tint) :: nil))
        (Ssequence
          (Ssequence
            (Sset _t'3 (Evar _gCurrLevelNum tshort))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tshort)
                           (Econst_int (Int.repr 13) tint) tint)
              (Ssequence
                (Sset _t'4 (Evar _gCurrAreaIndex tshort))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tshort)
                               (Econst_int (Int.repr 2) tint) tint)
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
                               (Ecast (Econst_int (Int.repr 7) tint) tuint)
                               (Econst_int (Int.repr 28) tint) tuint)
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 23) tint) tuint)
                               (Econst_int (Int.repr 16) tint) tuint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 160) tint) tuint)
                             (Econst_int (Int.repr 8) tint) tuint) tuint)
                         (Econst_int (Int.repr 128) tint) tuint)
                       (Econst_int (Int.repr 1) tint) tuint) ::
                     (Econst_int (Int.repr 65536) tint) :: nil))
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
                               (Ecast (Econst_int (Int.repr 7) tint) tuint)
                               (Econst_int (Int.repr 28) tint) tuint)
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 22) tint) tuint)
                               (Econst_int (Int.repr 16) tint) tuint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 160) tint) tuint)
                             (Econst_int (Int.repr 8) tint) tuint) tuint)
                         (Econst_int (Int.repr 128) tint) tuint)
                       (Econst_int (Int.repr 1) tint) tuint) ::
                     (Econst_int (Int.repr 65536) tint) :: nil))))
              Sskip))
          (Ssequence
            (Ssequence
              (Scall (Some _t'2)
                (Evar _launch_mario_until_land (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tint :: tint :: tfloat ::
                                                  nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 201327152) tint) ::
                 (Econst_int (Int.repr 77) tint) ::
                 (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat) ::
                 nil))
              (Sifthenelse (Etempvar _t'2 tint)
                (Ssequence
                  (Scall None
                    (Evar _mario_set_forward_vel (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tfloat :: nil) tvoid
                                                   cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                     nil))
                  (Scall None
                    (Evar _play_mario_landing_sound (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: nil) tvoid
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
                               (Ecast (Econst_int (Int.repr 8) tint) tuint)
                               (Econst_int (Int.repr 16) tint) tuint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 128) tint) tuint)
                             (Econst_int (Int.repr 8) tint) tuint) tuint)
                         (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                           (Econst_int (Int.repr 128) tint) tint) tuint)
                       (Econst_int (Int.repr 1) tint) tuint) :: nil)))
                Sskip))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_spawn_spin_airborne := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tint) :: (_t'3, tshort) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'11, tshort) :: (_t'10, tfloat) ::
               (_t'9, tfloat) :: (_t'8, tfloat) :: (_t'7, tfloat) ::
               (_t'6, tushort) :: (_t'5, (tptr (Tstruct _Object noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'10
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
          (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
    (Ssequence
      (Sset _t'11
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _waterLevel tshort))
      (Sifthenelse (Ebinop Olt (Etempvar _t'10 tfloat)
                     (Ebinop Osub (Etempvar _t'11 tshort)
                       (Econst_int (Int.repr 100) tint) tint) tint)
        (Ssequence
          (Scall None
            (Evar _load_level_init_text (Tfunction (tuint :: nil) tvoid
                                          cc_default))
            ((Econst_int (Int.repr 0) tint) :: nil))
          (Ssequence
            (Scall (Some _t'1)
              (Evar _set_water_plunge_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Sreturn (Some (Etempvar _t'1 tint)))))
        Sskip)))
  (Ssequence
    (Ssequence
      (Sset _t'9
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _forwardVel tfloat))
      (Scall None
        (Evar _mario_set_forward_vel (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tfloat :: nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Etempvar _t'9 tfloat) :: nil)))
    (Ssequence
      (Ssequence
        (Scall (Some _t'2)
          (Evar _perform_air_step (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_float (Float.of_bits (Int64.repr 0)) tdouble) :: nil))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tint)
                       (Econst_int (Int.repr 1) tint) tint)
          (Ssequence
            (Scall None
              (Evar _play_mario_landing_sound (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: nil) tvoid
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
                         (Ecast (Econst_int (Int.repr 8) tint) tuint)
                         (Econst_int (Int.repr 16) tint) tuint) tuint)
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 128) tint) tuint)
                       (Econst_int (Int.repr 8) tint) tuint) tuint)
                   (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                     (Econst_int (Int.repr 128) tint) tint) tuint)
                 (Econst_int (Int.repr 1) tint) tuint) :: nil))
            (Scall None
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 4901) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil)))
          Sskip))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'6
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionState tushort))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'6 tushort)
                           (Econst_int (Int.repr 0) tint) tint)
              (Ssequence
                (Sset _t'7
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _pos
                        (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tfloat)) tfloat))
                (Ssequence
                  (Sset _t'8
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _floorHeight tfloat))
                  (Sset _t'4
                    (Ecast
                      (Ebinop Ogt
                        (Ebinop Osub (Etempvar _t'7 tfloat)
                          (Etempvar _t'8 tfloat) tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1133903872)) tfloat)
                        tint) tbool))))
              (Sset _t'4 (Econst_int (Int.repr 0) tint))))
          (Sifthenelse (Etempvar _t'4 tint)
            (Ssequence
              (Scall (Some _t'3)
                (Evar _set_mario_animation (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tint :: nil) tshort cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 111) tint) :: nil))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tshort)
                             (Econst_int (Int.repr 0) tint) tint)
                (Ssequence
                  (Sset _t'5
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
                               (Ecast (Econst_int (Int.repr 0) tint) tuint)
                               (Econst_int (Int.repr 28) tint) tuint)
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 55) tint) tuint)
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
                             (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                             (Tstruct _Object noattr)) _header
                           (Tstruct _ObjectNode noattr)) _gfx
                         (Tstruct _GraphNodeObject noattr)) _cameraToObject
                       (tarray tfloat 3)) :: nil)))
                Sskip))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionState tushort)
                (Econst_int (Int.repr 1) tint))
              (Scall None
                (Evar _set_mario_animation (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tint :: nil) tshort cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 86) tint) :: nil)))))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_spawn_spin_landing := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _stop_and_set_height_to_floor (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
  (Ssequence
    (Scall None
      (Evar _set_mario_animation (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 87) tint) :: nil))
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _is_anim_at_end (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Sifthenelse (Etempvar _t'1 tint)
          (Ssequence
            (Scall None
              (Evar _load_level_init_text (Tfunction (tuint :: nil) tvoid
                                            cc_default))
              ((Econst_int (Int.repr 0) tint) :: nil))
            (Scall None
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 205521409) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil)))
          Sskip))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_act_exit_airborne := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tushort) ::
               (_t'7, tshort) :: (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: (_t'4, tuint) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'1
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort)
          (Ebinop Oadd (Etempvar _t'1 tushort) (Econst_int (Int.repr 1) tint)
            tint)))
      (Sifthenelse (Ebinop Olt (Econst_int (Int.repr 15) tint)
                     (Etempvar _t'1 tushort) tint)
        (Ssequence
          (Scall (Some _t'3)
            (Evar _launch_mario_until_land (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tint :: tint :: tfloat :: nil)
                                             tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 4903) tint) ::
             (Econst_int (Int.repr 86) tint) ::
             (Eunop Oneg
               (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
               tfloat) :: nil))
          (Sset _t'2 (Ecast (Etempvar _t'3 tint) tbool)))
        (Sset _t'2 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'2 tint)
      (Sassign
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _healCounter tuchar)
        (Econst_int (Int.repr 31) tint))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _marioObj
            (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'7
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _header
                      (Tstruct _ObjectNode noattr)) _gfx
                    (Tstruct _GraphNodeObject noattr)) _angle
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _header
                      (Tstruct _ObjectNode noattr)) _gfx
                    (Tstruct _GraphNodeObject noattr)) _angle
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort)
            (Ebinop Oadd (Etempvar _t'7 tshort)
              (Econst_int (Int.repr 32768) tint) tint)))))
    (Ssequence
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _particleFlags tuint))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _particleFlags tuint)
          (Ebinop Oor (Etempvar _t'4 tuint)
            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
              (Econst_int (Int.repr 3) tint) tint) tuint)))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_act_falling_exit_airborne := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'5, tshort) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: (_t'2, tuint) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _launch_mario_until_land (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tint :: tint :: tfloat :: nil) tint
                                       cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 4903) tint) ::
       (Econst_int (Int.repr 86) tint) ::
       (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sassign
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _healCounter tuchar)
        (Econst_int (Int.repr 31) tint))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _marioObj
            (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'5
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _header
                      (Tstruct _ObjectNode noattr)) _gfx
                    (Tstruct _GraphNodeObject noattr)) _angle
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _header
                      (Tstruct _ObjectNode noattr)) _gfx
                    (Tstruct _GraphNodeObject noattr)) _angle
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort)
            (Ebinop Oadd (Etempvar _t'5 tshort)
              (Econst_int (Int.repr 32768) tint) tint)))))
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _particleFlags tuint))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _particleFlags tuint)
          (Ebinop Oor (Etempvar _t'2 tuint)
            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
              (Econst_int (Int.repr 3) tint) tint) tuint)))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_act_exit_land_save_dialog := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_animFrame, tint) :: (_t'10, tshort) :: (_t'9, tint) ::
               (_t'8, tint) :: (_t'7, tint) :: (_t'6, tshort) ::
               (_t'5, tshort) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'26, tuint) ::
               (_t'25, tuchar) :: (_t'24, tuchar) :: (_t'23, tuint) ::
               (_t'22, tuchar) :: (_t'21, tuchar) ::
               (_t'20, (tptr (Tstruct _Object noattr))) ::
               (_t'19, (tptr (Tstruct _Object noattr))) ::
               (_t'18, (tptr (Tstruct _Object noattr))) ::
               (_t'17, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'16, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'15, (tptr (Tstruct _Object noattr))) ::
               (_t'14, tushort) :: (_t'13, tshort) ::
               (_t'12, (tptr (Tstruct _Object noattr))) ::
               (_t'11, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _stationary_ground_step (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tint cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
  (Ssequence
    (Scall None
      (Evar _play_mario_landing_sound_once (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tuint :: nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 8) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) :: nil))
    (Ssequence
      (Ssequence
        (Sset _t'14
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionState tushort))
        (Sswitch (Etempvar _t'14 tushort)
          (LScons (Some 0)
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'26
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionArg tuint))
                  (Sifthenelse (Ebinop Oeq (Etempvar _t'26 tuint)
                                 (Econst_int (Int.repr 0) tint) tint)
                    (Sset _t'1 (Ecast (Econst_int (Int.repr 87) tint) tint))
                    (Sset _t'1 (Ecast (Econst_int (Int.repr 78) tint) tint))))
                (Scall None
                  (Evar _set_mario_animation (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tint :: nil) tshort
                                               cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Etempvar _t'1 tint) :: nil)))
              (Ssequence
                (Ssequence
                  (Scall (Some _t'4)
                    (Evar _is_anim_past_end (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Sifthenelse (Etempvar _t'4 tint)
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'24 (Evar _gLastCompletedCourseNum tuchar))
                          (Sifthenelse (Ebinop One (Etempvar _t'24 tuchar)
                                         (Econst_int (Int.repr 16) tint)
                                         tint)
                            (Ssequence
                              (Sset _t'25
                                (Evar _gLastCompletedCourseNum tuchar))
                              (Sset _t'2
                                (Ecast
                                  (Ebinop One (Etempvar _t'25 tuchar)
                                    (Econst_int (Int.repr 17) tint) tint)
                                  tbool)))
                            (Sset _t'2 (Econst_int (Int.repr 0) tint))))
                        (Sifthenelse (Etempvar _t'2 tint)
                          (Scall None
                            (Evar _enable_time_stop (Tfunction nil tvoid
                                                      cc_default)) nil)
                          Sskip))
                      (Ssequence
                        (Scall None
                          (Evar _set_menu_mode (Tfunction (tshort :: nil)
                                                 tvoid cc_default))
                          ((Econst_int (Int.repr 2) tint) :: nil))
                        (Ssequence
                          (Sassign (Evar _gSaveOptSelectIndex tshort)
                            (Econst_int (Int.repr 0) tint))
                          (Ssequence
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _actionState
                                tushort) (Econst_int (Int.repr 3) tint))
                            (Ssequence
                              (Ssequence
                                (Sset _t'23
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _flags
                                    tuint))
                                (Sifthenelse (Eunop Onotbool
                                               (Ebinop Oand
                                                 (Etempvar _t'23 tuint)
                                                 (Econst_int (Int.repr 16) tint)
                                                 tuint) tint)
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _actionState tushort)
                                    (Econst_int (Int.repr 2) tint))
                                  Sskip))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'21
                                    (Evar _gLastCompletedCourseNum tuchar))
                                  (Sifthenelse (Ebinop Oeq
                                                 (Etempvar _t'21 tuchar)
                                                 (Econst_int (Int.repr 16) tint)
                                                 tint)
                                    (Sset _t'3
                                      (Econst_int (Int.repr 1) tint))
                                    (Ssequence
                                      (Sset _t'22
                                        (Evar _gLastCompletedCourseNum tuchar))
                                      (Sset _t'3
                                        (Ecast
                                          (Ebinop Oeq (Etempvar _t'22 tuchar)
                                            (Econst_int (Int.repr 17) tint)
                                            tint) tbool)))))
                                (Sifthenelse (Etempvar _t'3 tint)
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _actionState tushort)
                                    (Econst_int (Int.repr 1) tint))
                                  Sskip)))))))
                    Sskip))
                Sbreak))
            (LScons (Some 1)
              (Ssequence
                (Ssequence
                  (Scall (Some _t'5)
                    (Evar _set_mario_animation (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tint :: nil) tshort
                                                 cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 49) tint) :: nil))
                  (Sset _animFrame (Etempvar _t'5 tshort)))
                (Ssequence
                  (Sswitch (Etempvar _animFrame tint)
                    (LScons (Some 4294967295)
                      (Scall None
                        (Evar _spawn_obj_at_mario_rel_yaw (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             tint ::
                                                             (tptr tuint) ::
                                                             tshort :: nil)
                                                            (tptr (Tstruct _Object noattr))
                                                            cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 200) tint) ::
                         (Evar _bhvBowserKeyCourseExit (tarray tuint 0)) ::
                         (Eunop Oneg (Econst_int (Int.repr 32768) tint) tint) ::
                         nil))
                      (LScons (Some 67)
                        (Ssequence
                          (Sset _t'20
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _marioObj
                              (tptr (Tstruct _Object noattr))))
                          (Scall None
                            (Evar _play_sound (Tfunction
                                                (tint :: (tptr tfloat) ::
                                                 nil) tvoid cc_default))
                            ((Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oor
                                   (Ebinop Oor
                                     (Ebinop Oshl
                                       (Ecast (Econst_int (Int.repr 0) tint)
                                         tuint)
                                       (Econst_int (Int.repr 28) tint) tuint)
                                     (Ebinop Oshl
                                       (Ecast (Econst_int (Int.repr 54) tint)
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
                             (Efield
                               (Efield
                                 (Efield
                                   (Ederef
                                     (Etempvar _t'20 (tptr (Tstruct _Object noattr)))
                                     (Tstruct _Object noattr)) _header
                                   (Tstruct _ObjectNode noattr)) _gfx
                                 (Tstruct _GraphNodeObject noattr))
                               _cameraToObject (tarray tfloat 3)) :: nil)))
                        (LScons (Some 83)
                          (Ssequence
                            (Sset _t'19
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _marioObj
                                (tptr (Tstruct _Object noattr))))
                            (Scall None
                              (Evar _play_sound (Tfunction
                                                  (tint :: (tptr tfloat) ::
                                                   nil) tvoid cc_default))
                              ((Ebinop Oor
                                 (Ebinop Oor
                                   (Ebinop Oor
                                     (Ebinop Oor
                                       (Ebinop Oshl
                                         (Ecast
                                           (Econst_int (Int.repr 0) tint)
                                           tuint)
                                         (Econst_int (Int.repr 28) tint)
                                         tuint)
                                       (Ebinop Oshl
                                         (Ecast
                                           (Econst_int (Int.repr 63) tint)
                                           tuint)
                                         (Econst_int (Int.repr 16) tint)
                                         tuint) tuint)
                                     (Ebinop Oshl
                                       (Ecast
                                         (Econst_int (Int.repr 128) tint)
                                         tuint)
                                       (Econst_int (Int.repr 8) tint) tuint)
                                     tuint)
                                   (Ebinop Oor
                                     (Econst_int (Int.repr 67108864) tint)
                                     (Econst_int (Int.repr 128) tint) tint)
                                   tuint) (Econst_int (Int.repr 1) tint)
                                 tuint) ::
                               (Efield
                                 (Efield
                                   (Efield
                                     (Ederef
                                       (Etempvar _t'19 (tptr (Tstruct _Object noattr)))
                                       (Tstruct _Object noattr)) _header
                                     (Tstruct _ObjectNode noattr)) _gfx
                                   (Tstruct _GraphNodeObject noattr))
                                 _cameraToObject (tarray tfloat 3)) :: nil)))
                          (LScons (Some 111)
                            (Ssequence
                              (Sset _t'18
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _marioObj
                                  (tptr (Tstruct _Object noattr))))
                              (Scall None
                                (Evar _play_sound (Tfunction
                                                    (tint :: (tptr tfloat) ::
                                                     nil) tvoid cc_default))
                                ((Ebinop Oor
                                   (Ebinop Oor
                                     (Ebinop Oor
                                       (Ebinop Oor
                                         (Ebinop Oshl
                                           (Ecast
                                             (Econst_int (Int.repr 0) tint)
                                             tuint)
                                           (Econst_int (Int.repr 28) tint)
                                           tuint)
                                         (Ebinop Oshl
                                           (Ecast
                                             (Econst_int (Int.repr 92) tint)
                                             tuint)
                                           (Econst_int (Int.repr 16) tint)
                                           tuint) tuint)
                                       (Ebinop Oshl
                                         (Ecast
                                           (Econst_int (Int.repr 128) tint)
                                           tuint)
                                         (Econst_int (Int.repr 8) tint)
                                         tuint) tuint)
                                     (Ebinop Oor
                                       (Econst_int (Int.repr 67108864) tint)
                                       (Econst_int (Int.repr 128) tint) tint)
                                     tuint) (Econst_int (Int.repr 1) tint)
                                   tuint) ::
                                 (Efield
                                   (Efield
                                     (Efield
                                       (Ederef
                                         (Etempvar _t'18 (tptr (Tstruct _Object noattr)))
                                         (Tstruct _Object noattr)) _header
                                       (Tstruct _ObjectNode noattr)) _gfx
                                     (Tstruct _GraphNodeObject noattr))
                                   _cameraToObject (tarray tfloat 3)) :: nil)))
                            LSnil)))))
                  (Ssequence
                    (Scall None
                      (Evar _handle_save_menu (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tvoid cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    Sbreak)))
              (LScons (Some 2)
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'6)
                      (Evar _set_mario_animation (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: nil) tshort
                                                   cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 94) tint) :: nil))
                    (Sset _animFrame (Etempvar _t'6 tshort)))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sifthenelse (Ebinop Oge (Etempvar _animFrame tint)
                                       (Econst_int (Int.repr 18) tint) tint)
                          (Sset _t'7
                            (Ecast
                              (Ebinop Olt (Etempvar _animFrame tint)
                                (Econst_int (Int.repr 55) tint) tint) tbool))
                          (Sset _t'7 (Econst_int (Int.repr 0) tint)))
                        (Sifthenelse (Etempvar _t'7 tint)
                          (Sset _t'8 (Econst_int (Int.repr 1) tint))
                          (Sifthenelse (Ebinop Oge (Etempvar _animFrame tint)
                                         (Econst_int (Int.repr 112) tint)
                                         tint)
                            (Ssequence
                              (Sset _t'8
                                (Ecast
                                  (Ebinop Olt (Etempvar _animFrame tint)
                                    (Econst_int (Int.repr 134) tint) tint)
                                  tbool))
                              (Sset _t'8 (Ecast (Etempvar _t'8 tint) tbool)))
                            (Sset _t'8
                              (Ecast (Econst_int (Int.repr 0) tint) tbool)))))
                      (Sifthenelse (Etempvar _t'8 tint)
                        (Ssequence
                          (Sset _t'17
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _marioBodyState
                              (tptr (Tstruct _MarioBodyState noattr))))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _t'17 (tptr (Tstruct _MarioBodyState noattr)))
                                (Tstruct _MarioBodyState noattr)) _handState
                              tschar) (Econst_int (Int.repr 1) tint)))
                        Sskip))
                    (Ssequence
                      (Ssequence
                        (Sifthenelse (Eunop Onotbool
                                       (Ebinop Olt (Etempvar _animFrame tint)
                                         (Econst_int (Int.repr 109) tint)
                                         tint) tint)
                          (Sset _t'9
                            (Ecast
                              (Ebinop Olt (Etempvar _animFrame tint)
                                (Econst_int (Int.repr 154) tint) tint) tbool))
                          (Sset _t'9 (Econst_int (Int.repr 0) tint)))
                        (Sifthenelse (Etempvar _t'9 tint)
                          (Ssequence
                            (Sset _t'16
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr))
                                _marioBodyState
                                (tptr (Tstruct _MarioBodyState noattr))))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _t'16 (tptr (Tstruct _MarioBodyState noattr)))
                                  (Tstruct _MarioBodyState noattr)) _eyeState
                                tschar) (Econst_int (Int.repr 2) tint)))
                          Sskip))
                      (Ssequence
                        (Scall None
                          (Evar _handle_save_menu (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tvoid cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        Sbreak))))
                (LScons (Some 3)
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'10)
                        (Evar _set_mario_animation (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tint :: nil) tshort
                                                     cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 55) tint) :: nil))
                      (Sset _animFrame (Etempvar _t'10 tshort)))
                    (Ssequence
                      (Sswitch (Etempvar _animFrame tint)
                        (LScons (Some 12)
                          (Ssequence
                            (Scall None
                              (Evar _cutscene_take_cap_off (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              nil) tvoid
                                                             cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               nil))
                            Sbreak)
                          (LScons (Some 37)
                            Sskip
                            (LScons (Some 53)
                              (Ssequence
                                (Ssequence
                                  (Sset _t'15
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _marioObj
                                      (tptr (Tstruct _Object noattr))))
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
                                                 (Econst_int (Int.repr 0) tint)
                                                 tuint)
                                               (Econst_int (Int.repr 28) tint)
                                               tuint)
                                             (Ebinop Oshl
                                               (Ecast
                                                 (Econst_int (Int.repr 64) tint)
                                                 tuint)
                                               (Econst_int (Int.repr 16) tint)
                                               tuint) tuint)
                                           (Ebinop Oshl
                                             (Ecast
                                               (Econst_int (Int.repr 128) tint)
                                               tuint)
                                             (Econst_int (Int.repr 8) tint)
                                             tuint) tuint)
                                         (Ebinop Oor
                                           (Econst_int (Int.repr 67108864) tint)
                                           (Econst_int (Int.repr 128) tint)
                                           tint) tuint)
                                       (Econst_int (Int.repr 1) tint) tuint) ::
                                     (Efield
                                       (Efield
                                         (Efield
                                           (Ederef
                                             (Etempvar _t'15 (tptr (Tstruct _Object noattr)))
                                             (Tstruct _Object noattr))
                                           _header
                                           (Tstruct _ObjectNode noattr)) _gfx
                                         (Tstruct _GraphNodeObject noattr))
                                       _cameraToObject (tarray tfloat 3)) ::
                                     nil)))
                                Sbreak)
                              (LScons (Some 82)
                                (Ssequence
                                  (Scall None
                                    (Evar _cutscene_put_cap_on (Tfunction
                                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                                  nil) tvoid
                                                                 cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     nil))
                                  Sbreak)
                                LSnil)))))
                      (Ssequence
                        (Scall None
                          (Evar _handle_save_menu (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tvoid cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        Sbreak)))
                  LSnil))))))
      (Ssequence
        (Ssequence
          (Sset _t'11
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioObj
              (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'12
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _marioObj
                (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'13
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'12 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _header
                          (Tstruct _ObjectNode noattr)) _gfx
                        (Tstruct _GraphNodeObject noattr)) _angle
                      (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                    (tptr tshort)) tshort))
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
                      (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                    (tptr tshort)) tshort)
                (Ebinop Oadd (Etempvar _t'13 tshort)
                  (Econst_int (Int.repr 32768) tint) tint)))))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_death_exit := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tushort) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: (_t'4, tschar) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'1
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort)
          (Ebinop Oadd (Etempvar _t'1 tushort) (Econst_int (Int.repr 1) tint)
            tint)))
      (Sifthenelse (Ebinop Olt (Econst_int (Int.repr 15) tint)
                     (Etempvar _t'1 tushort) tint)
        (Ssequence
          (Scall (Some _t'3)
            (Evar _launch_mario_until_land (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tint :: tint :: tfloat :: nil)
                                             tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 132199) tint) ::
             (Econst_int (Int.repr 86) tint) ::
             (Eunop Oneg
               (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
               tfloat) :: nil))
          (Sset _t'2 (Ecast (Etempvar _t'3 tint) tbool)))
        (Sset _t'2 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'2 tint)
      (Ssequence
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioObj
              (tptr (Tstruct _Object noattr))))
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
                       (Ecast (Econst_int (Int.repr 11) tint) tuint)
                       (Econst_int (Int.repr 16) tint) tuint) tuint)
                   (Ebinop Oshl
                     (Ecast (Econst_int (Int.repr 208) tint) tuint)
                     (Econst_int (Int.repr 8) tint) tuint) tuint)
                 (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                   (Econst_int (Int.repr 128) tint) tint) tuint)
               (Econst_int (Int.repr 1) tint) tuint) ::
             (Efield
               (Efield
                 (Efield
                   (Ederef (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                     (Tstruct _Object noattr)) _header
                   (Tstruct _ObjectNode noattr)) _gfx
                 (Tstruct _GraphNodeObject noattr)) _cameraToObject
               (tarray tfloat 3)) :: nil)))
        (Ssequence
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _numLives tschar))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _numLives tschar)
              (Ebinop Osub (Etempvar _t'4 tschar)
                (Econst_int (Int.repr 1) tint) tint)))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _healCounter tuchar)
            (Econst_int (Int.repr 31) tint))))
      Sskip))
  (Ssequence
    (Sassign
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _health tshort)
      (Econst_int (Int.repr 256) tint))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_unused_death_exit := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, tschar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _launch_mario_until_land (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tint :: tint :: tfloat :: nil) tint
                                       cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 201327154) tint) ::
       (Econst_int (Int.repr 86) tint) ::
       (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioObj
              (tptr (Tstruct _Object noattr))))
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
                       (Ecast (Econst_int (Int.repr 11) tint) tuint)
                       (Econst_int (Int.repr 16) tint) tuint) tuint)
                   (Ebinop Oshl
                     (Ecast (Econst_int (Int.repr 208) tint) tuint)
                     (Econst_int (Int.repr 8) tint) tuint) tuint)
                 (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                   (Econst_int (Int.repr 128) tint) tint) tuint)
               (Econst_int (Int.repr 1) tint) tuint) ::
             (Efield
               (Efield
                 (Efield
                   (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                     (Tstruct _Object noattr)) _header
                   (Tstruct _ObjectNode noattr)) _gfx
                 (Tstruct _GraphNodeObject noattr)) _cameraToObject
               (tarray tfloat 3)) :: nil)))
        (Ssequence
          (Ssequence
            (Sset _t'2
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _numLives tschar))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _numLives tschar)
              (Ebinop Osub (Etempvar _t'2 tschar)
                (Econst_int (Int.repr 1) tint) tint)))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _healCounter tuchar)
            (Econst_int (Int.repr 31) tint))))
      Sskip))
  (Ssequence
    (Sassign
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _health tshort)
      (Econst_int (Int.repr 256) tint))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_falling_death_exit := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, tschar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _launch_mario_until_land (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tint :: tint :: tfloat :: nil) tint
                                       cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 132199) tint) ::
       (Econst_int (Int.repr 86) tint) ::
       (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioObj
              (tptr (Tstruct _Object noattr))))
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
                       (Ecast (Econst_int (Int.repr 11) tint) tuint)
                       (Econst_int (Int.repr 16) tint) tuint) tuint)
                   (Ebinop Oshl
                     (Ecast (Econst_int (Int.repr 208) tint) tuint)
                     (Econst_int (Int.repr 8) tint) tuint) tuint)
                 (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                   (Econst_int (Int.repr 128) tint) tint) tuint)
               (Econst_int (Int.repr 1) tint) tuint) ::
             (Efield
               (Efield
                 (Efield
                   (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                     (Tstruct _Object noattr)) _header
                   (Tstruct _ObjectNode noattr)) _gfx
                 (Tstruct _GraphNodeObject noattr)) _cameraToObject
               (tarray tfloat 3)) :: nil)))
        (Ssequence
          (Ssequence
            (Sset _t'2
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _numLives tschar))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _numLives tschar)
              (Ebinop Osub (Etempvar _t'2 tschar)
                (Econst_int (Int.repr 1) tint) tint)))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _healCounter tuchar)
            (Econst_int (Int.repr 31) tint))))
      Sskip))
  (Ssequence
    (Sassign
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _health tshort)
      (Econst_int (Int.repr 256) tint))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_special_exit_airborne := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_t'2, tint) :: (_t'1, tushort) :: (_t'6, tshort) ::
               (_t'5, tuint) :: (_t'4, tshort) :: (_t'3, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _marioObj
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
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
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 2) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 4) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) ::
       (Econst_int (Int.repr 131072) tint) :: nil))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'1
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort)
            (Ebinop Oadd (Etempvar _t'1 tushort)
              (Econst_int (Int.repr 1) tint) tint)))
        (Sifthenelse (Ebinop Olt (Etempvar _t'1 tushort)
                       (Econst_int (Int.repr 11) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'6
                (Efield
                  (Efield
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _header
                        (Tstruct _ObjectNode noattr)) _gfx
                      (Tstruct _GraphNodeObject noattr)) _node
                    (Tstruct _GraphNode noattr)) _flags tshort))
              (Sassign
                (Efield
                  (Efield
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _header
                        (Tstruct _ObjectNode noattr)) _gfx
                      (Tstruct _GraphNodeObject noattr)) _node
                    (Tstruct _GraphNode noattr)) _flags tshort)
                (Ebinop Oand (Etempvar _t'6 tshort)
                  (Eunop Onotint
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 0) tint) tint) tint) tint)))
            (Sreturn (Some (Econst_int (Int.repr 0) tint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Scall (Some _t'2)
            (Evar _launch_mario_until_land (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tint :: tint :: tfloat :: nil)
                                             tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 4903) tint) ::
             (Econst_int (Int.repr 77) tint) ::
             (Eunop Oneg
               (Econst_single (Float32.of_bits (Int.repr 1103101952)) tfloat)
               tfloat) :: nil))
          (Sifthenelse (Etempvar _t'2 tint)
            (Ssequence
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _healCounter tuchar)
                (Econst_int (Int.repr 31) tint))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionArg tuint)
                (Econst_int (Int.repr 1) tint)))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'5
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _particleFlags tuint))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _particleFlags tuint)
              (Ebinop Oor (Etempvar _t'5 tuint)
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 3) tint) tint) tuint)))
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _header
                          (Tstruct _ObjectNode noattr)) _gfx
                        (Tstruct _GraphNodeObject noattr)) _angle
                      (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                    (tptr tshort)) tshort))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _header
                          (Tstruct _ObjectNode noattr)) _gfx
                        (Tstruct _GraphNodeObject noattr)) _angle
                      (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                    (tptr tshort)) tshort)
                (Ebinop Oadd (Etempvar _t'4 tshort)
                  (Econst_int (Int.repr 32768) tint) tint)))
            (Ssequence
              (Ssequence
                (Sset _t'3
                  (Efield
                    (Efield
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _header
                          (Tstruct _ObjectNode noattr)) _gfx
                        (Tstruct _GraphNodeObject noattr)) _node
                      (Tstruct _GraphNode noattr)) _flags tshort))
                (Sassign
                  (Efield
                    (Efield
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _header
                          (Tstruct _ObjectNode noattr)) _gfx
                        (Tstruct _GraphNodeObject noattr)) _node
                      (Tstruct _GraphNode noattr)) _flags tshort)
                  (Ebinop Oor (Etempvar _t'3 tshort)
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 0) tint) tint) tint)))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_act_special_death_exit := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_t'2, tint) :: (_t'1, tushort) :: (_t'5, tshort) ::
               (_t'4, tschar) :: (_t'3, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _marioObj
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'1
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort)
          (Ebinop Oadd (Etempvar _t'1 tushort) (Econst_int (Int.repr 1) tint)
            tint)))
      (Sifthenelse (Ebinop Olt (Etempvar _t'1 tushort)
                     (Econst_int (Int.repr 11) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'5
              (Efield
                (Efield
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _header
                      (Tstruct _ObjectNode noattr)) _gfx
                    (Tstruct _GraphNodeObject noattr)) _node
                  (Tstruct _GraphNode noattr)) _flags tshort))
            (Sassign
              (Efield
                (Efield
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _header
                      (Tstruct _ObjectNode noattr)) _gfx
                    (Tstruct _GraphNodeObject noattr)) _node
                  (Tstruct _GraphNode noattr)) _flags tshort)
              (Ebinop Oand (Etempvar _t'5 tshort)
                (Eunop Onotint
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 0) tint) tint) tint) tint)))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Scall (Some _t'2)
          (Evar _launch_mario_until_land (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: tint :: tfloat :: nil)
                                           tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 132192) tint) ::
           (Econst_int (Int.repr 2) tint) ::
           (Eunop Oneg
             (Econst_single (Float32.of_bits (Int.repr 1103101952)) tfloat)
             tfloat) :: nil))
        (Sifthenelse (Etempvar _t'2 tint)
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _numLives tschar))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _numLives tschar)
                (Ebinop Osub (Etempvar _t'4 tschar)
                  (Econst_int (Int.repr 1) tint) tint)))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _healCounter tuchar)
              (Econst_int (Int.repr 31) tint)))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield
              (Efield
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _header
                    (Tstruct _ObjectNode noattr)) _gfx
                  (Tstruct _GraphNodeObject noattr)) _node
                (Tstruct _GraphNode noattr)) _flags tshort))
          (Sassign
            (Efield
              (Efield
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _header
                    (Tstruct _ObjectNode noattr)) _gfx
                  (Tstruct _GraphNodeObject noattr)) _node
                (Tstruct _GraphNode noattr)) _flags tshort)
            (Ebinop Oor (Etempvar _t'3 tshort)
              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 0) tint) tint) tint)))
        (Ssequence
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _health tshort)
            (Econst_int (Int.repr 256) tint))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_spawn_no_spin_airborne := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tshort) :: (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _launch_mario_until_land (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tint :: tint :: tfloat :: nil) tint
                                     cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Econst_int (Int.repr 4915) tint) :: (Econst_int (Int.repr 86) tint) ::
     (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) :: nil))
  (Ssequence
    (Ssequence
      (Sset _t'1
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
            (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _waterLevel tshort))
        (Sifthenelse (Ebinop Olt (Etempvar _t'1 tfloat)
                       (Ebinop Osub (Etempvar _t'2 tshort)
                         (Econst_int (Int.repr 100) tint) tint) tint)
          (Scall None
            (Evar _set_water_plunge_action (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          Sskip)))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_spawn_no_spin_landing := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _play_mario_landing_sound_once (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tuint :: nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Ebinop Oor
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
               (Econst_int (Int.repr 28) tint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 8) tint) tuint)
               (Econst_int (Int.repr 16) tint) tuint) tuint)
           (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
             (Econst_int (Int.repr 8) tint) tuint) tuint)
         (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
           (Econst_int (Int.repr 128) tint) tint) tuint)
       (Econst_int (Int.repr 1) tint) tuint) :: nil))
  (Ssequence
    (Scall None
      (Evar _set_mario_animation (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 87) tint) :: nil))
    (Ssequence
      (Scall None
        (Evar _stop_and_set_height_to_floor (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _is_anim_at_end (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sifthenelse (Etempvar _t'1 tint)
            (Ssequence
              (Scall None
                (Evar _load_level_init_text (Tfunction (tuint :: nil) tvoid
                                              cc_default))
                ((Econst_int (Int.repr 0) tint) :: nil))
              (Scall None
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 205521409) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil)))
            Sskip))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_bbh_enter_spin := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_floorDist, tfloat) :: (_scale, tfloat) ::
               (_cageDX, tfloat) :: (_cageDZ, tfloat) ::
               (_cageDist, tfloat) :: (_forwardVel, tfloat) ::
               (_t'8, tshort) :: (_t'7, tint) :: (_t'6, tshort) ::
               (_t'5, tshort) :: (_t'4, tshort) :: (_t'3, tfloat) ::
               (_t'2, tfloat) :: (_t'1, tfloat) :: (_t'34, tfloat) ::
               (_t'33, tfloat) :: (_t'32, (tptr (Tstruct _Object noattr))) ::
               (_t'31, tfloat) :: (_t'30, tfloat) ::
               (_t'29, (tptr (Tstruct _Object noattr))) :: (_t'28, tfloat) ::
               (_t'27, tfloat) :: (_t'26, (tptr (Tstruct _Object noattr))) ::
               (_t'25, tuint) :: (_t'24, tfloat) :: (_t'23, tuint) ::
               (_t'22, tshort) :: (_t'21, (tptr (Tstruct _Object noattr))) ::
               (_t'20, tfloat) :: (_t'19, tfloat) ::
               (_t'18, (tptr (Tstruct _Object noattr))) ::
               (_t'17, tushort) :: (_t'16, tushort) :: (_t'15, tushort) ::
               (_t'14, (tptr (Tstruct _Object noattr))) ::
               (_t'13, tushort) :: (_t'12, tshort) ::
               (_t'11, (tptr (Tstruct _Object noattr))) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tushort) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'32
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _usedObj
        (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'33
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'32 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __729 noattr))
              _asF32 (tarray tfloat 80))
            (Ebinop Oadd (Econst_int (Int.repr 6) tint)
              (Econst_int (Int.repr 0) tint) tint) (tptr tfloat)) tfloat))
      (Ssequence
        (Sset _t'34
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
        (Sset _cageDX
          (Ebinop Osub (Etempvar _t'33 tfloat) (Etempvar _t'34 tfloat)
            tfloat)))))
  (Ssequence
    (Ssequence
      (Sset _t'29
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _usedObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'30
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'29 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __729 noattr))
                _asF32 (tarray tfloat 80))
              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                (Econst_int (Int.repr 2) tint) tint) (tptr tfloat)) tfloat))
        (Ssequence
          (Sset _t'31
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
          (Sset _cageDZ
            (Ebinop Osub (Etempvar _t'30 tfloat) (Etempvar _t'31 tfloat)
              tfloat)))))
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _sqrtf (Tfunction (tfloat :: nil) tfloat cc_default))
          ((Ebinop Oadd
             (Ebinop Omul (Etempvar _cageDX tfloat) (Etempvar _cageDX tfloat)
               tfloat)
             (Ebinop Omul (Etempvar _cageDZ tfloat) (Etempvar _cageDZ tfloat)
               tfloat) tfloat) :: nil))
        (Sset _cageDist (Etempvar _t'1 tfloat)))
      (Ssequence
        (Sifthenelse (Ebinop Ogt (Etempvar _cageDist tfloat)
                       (Econst_single (Float32.of_bits (Int.repr 1101004800)) tfloat)
                       tint)
          (Sset _forwardVel
            (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat))
          (Sset _forwardVel
            (Ebinop Odiv (Etempvar _cageDist tfloat)
              (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
              tfloat)))
        (Ssequence
          (Sifthenelse (Ebinop Olt (Etempvar _forwardVel tfloat)
                         (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat)
                         tint)
            (Sset _forwardVel
              (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
            Sskip)
          (Ssequence
            (Ssequence
              (Sset _t'9
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionState tushort))
              (Sswitch (Etempvar _t'9 tushort)
                (LScons (Some 0)
                  (Ssequence
                    (Ssequence
                      (Sset _t'27
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _pos
                              (tarray tfloat 3))
                            (Econst_int (Int.repr 1) tint) (tptr tfloat))
                          tfloat))
                      (Ssequence
                        (Sset _t'28
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _floorHeight
                            tfloat))
                        (Sset _floorDist
                          (Ebinop Osub
                            (Econst_single (Float32.of_bits (Int.repr 1140850688)) tfloat)
                            (Ebinop Osub (Etempvar _t'27 tfloat)
                              (Etempvar _t'28 tfloat) tfloat) tfloat))))
                    (Ssequence
                      (Ssequence
                        (Sifthenelse (Ebinop Ogt (Etempvar _floorDist tfloat)
                                       (Econst_int (Int.repr 0) tint) tint)
                          (Ssequence
                            (Scall (Some _t'3)
                              (Evar _sqrtf (Tfunction (tfloat :: nil) tfloat
                                             cc_default))
                              ((Ebinop Oadd
                                 (Ebinop Omul
                                   (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                   (Etempvar _floorDist tfloat) tfloat)
                                 (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                                 tfloat) :: nil))
                            (Sset _t'2
                              (Ecast
                                (Ebinop Osub (Etempvar _t'3 tfloat)
                                  (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                                  tfloat) tfloat)))
                          (Sset _t'2
                            (Ecast
                              (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                              tfloat)))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _vel
                                (tarray tfloat 3))
                              (Econst_int (Int.repr 1) tint) (tptr tfloat))
                            tfloat) (Etempvar _t'2 tfloat)))
                      (Ssequence
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _actionState
                            tushort) (Econst_int (Int.repr 1) tint))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _actionTimer
                            tushort) (Econst_int (Int.repr 100) tint)))))
                  (LScons (Some 1)
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'4)
                          (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil)
                                          tshort cc_default))
                          ((Etempvar _cageDZ tfloat) ::
                           (Etempvar _cageDX tfloat) :: nil))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _faceAngle
                                (tarray tshort 3))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))
                            tshort) (Etempvar _t'4 tshort)))
                      (Ssequence
                        (Scall None
                          (Evar _mario_set_forward_vel (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          tfloat :: nil)
                                                         tvoid cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Etempvar _forwardVel tfloat) :: nil))
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'5)
                              (Evar _set_mario_animation (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            tint :: nil)
                                                           tshort cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 111) tint) :: nil))
                            (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tshort)
                                           (Econst_int (Int.repr 0) tint)
                                           tint)
                              (Ssequence
                                (Sset _t'26
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _marioObj
                                    (tptr (Tstruct _Object noattr))))
                                (Scall None
                                  (Evar _play_sound (Tfunction
                                                      (tint ::
                                                       (tptr tfloat) :: nil)
                                                      tvoid cc_default))
                                  ((Ebinop Oor
                                     (Ebinop Oor
                                       (Ebinop Oor
                                         (Ebinop Oor
                                           (Ebinop Oshl
                                             (Ecast
                                               (Econst_int (Int.repr 0) tint)
                                               tuint)
                                             (Econst_int (Int.repr 28) tint)
                                             tuint)
                                           (Ebinop Oshl
                                             (Ecast
                                               (Econst_int (Int.repr 55) tint)
                                               tuint)
                                             (Econst_int (Int.repr 16) tint)
                                             tuint) tuint)
                                         (Ebinop Oshl
                                           (Ecast
                                             (Econst_int (Int.repr 128) tint)
                                             tuint)
                                           (Econst_int (Int.repr 8) tint)
                                           tuint) tuint)
                                       (Ebinop Oor
                                         (Econst_int (Int.repr 67108864) tint)
                                         (Econst_int (Int.repr 128) tint)
                                         tint) tuint)
                                     (Econst_int (Int.repr 1) tint) tuint) ::
                                   (Efield
                                     (Efield
                                       (Efield
                                         (Ederef
                                           (Etempvar _t'26 (tptr (Tstruct _Object noattr)))
                                           (Tstruct _Object noattr)) _header
                                         (Tstruct _ObjectNode noattr)) _gfx
                                       (Tstruct _GraphNodeObject noattr))
                                     _cameraToObject (tarray tfloat 3)) ::
                                   nil)))
                              Sskip))
                          (Ssequence
                            (Ssequence
                              (Sset _t'25
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
                                (Ebinop Oand (Etempvar _t'25 tuint)
                                  (Eunop Onotint
                                    (Econst_int (Int.repr 256) tint) tint)
                                  tuint)))
                            (Ssequence
                              (Scall None
                                (Evar _perform_air_step (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           tuint :: nil) tint
                                                          cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 (Econst_int (Int.repr 0) tint) :: nil))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'24
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Ederef
                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _vel (tarray tfloat 3))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr tfloat)) tfloat))
                                  (Sifthenelse (Ebinop Ole
                                                 (Etempvar _t'24 tfloat)
                                                 (Econst_int (Int.repr 0) tint)
                                                 tint)
                                    (Sassign
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _actionState tushort)
                                      (Econst_int (Int.repr 2) tint))
                                    Sskip))
                                Sbreak))))))
                    (LScons (Some 2)
                      Sskip
                      (LScons (Some 3)
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'6)
                              (Evar _atan2s (Tfunction
                                              (tfloat :: tfloat :: nil)
                                              tshort cc_default))
                              ((Etempvar _cageDZ tfloat) ::
                               (Etempvar _cageDX tfloat) :: nil))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _faceAngle (tarray tshort 3))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tshort)) tshort)
                              (Etempvar _t'6 tshort)))
                          (Ssequence
                            (Scall None
                              (Evar _mario_set_forward_vel (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              tfloat :: nil)
                                                             tvoid
                                                             cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Etempvar _forwardVel tfloat) :: nil))
                            (Ssequence
                              (Ssequence
                                (Sset _t'23
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
                                  (Ebinop Oand (Etempvar _t'23 tuint)
                                    (Eunop Onotint
                                      (Econst_int (Int.repr 256) tint) tint)
                                    tuint)))
                              (Ssequence
                                (Ssequence
                                  (Scall (Some _t'7)
                                    (Evar _perform_air_step (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               tuint :: nil)
                                                              tint
                                                              cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     (Econst_int (Int.repr 0) tint) :: nil))
                                  (Sifthenelse (Ebinop Oeq
                                                 (Etempvar _t'7 tint)
                                                 (Econst_int (Int.repr 1) tint)
                                                 tint)
                                    (Ssequence
                                      (Scall None
                                        (Evar _level_trigger_warp (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    tint ::
                                                                    nil)
                                                                    tshort
                                                                    cc_default))
                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                         (Econst_int (Int.repr 2) tint) ::
                                         nil))
                                      (Sassign
                                        (Efield
                                          (Ederef
                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _actionState tushort)
                                        (Econst_int (Int.repr 4) tint)))
                                    Sskip))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'17
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _actionState tushort))
                                    (Sifthenelse (Ebinop Oeq
                                                   (Etempvar _t'17 tushort)
                                                   (Econst_int (Int.repr 2) tint)
                                                   tint)
                                      (Ssequence
                                        (Sset _t'21
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _marioObj
                                            (tptr (Tstruct _Object noattr))))
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
                                                _animInfo
                                                (Tstruct _AnimInfo noattr))
                                              _animFrame tshort))
                                          (Sifthenelse (Ebinop Oeq
                                                         (Etempvar _t'22 tshort)
                                                         (Econst_int (Int.repr 0) tint)
                                                         tint)
                                            (Sassign
                                              (Efield
                                                (Ederef
                                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                  (Tstruct _MarioState noattr))
                                                _actionState tushort)
                                              (Econst_int (Int.repr 3) tint))
                                            Sskip)))
                                      (Ssequence
                                        (Scall None
                                          (Evar _play_sound_if_no_flag 
                                          (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tvoid
                                            cc_default))
                                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                           (Ebinop Oor
                                             (Ebinop Oor
                                               (Ebinop Oor
                                                 (Ebinop Oor
                                                   (Ebinop Oshl
                                                     (Ecast
                                                       (Econst_int (Int.repr 0) tint)
                                                       tuint)
                                                     (Econst_int (Int.repr 28) tint)
                                                     tuint)
                                                   (Ebinop Oshl
                                                     (Ecast
                                                       (Econst_int (Int.repr 70) tint)
                                                       tuint)
                                                     (Econst_int (Int.repr 16) tint)
                                                     tuint) tuint)
                                                 (Ebinop Oshl
                                                   (Ecast
                                                     (Econst_int (Int.repr 160) tint)
                                                     tuint)
                                                   (Econst_int (Int.repr 8) tint)
                                                   tuint) tuint)
                                               (Ebinop Oor
                                                 (Econst_int (Int.repr 67108864) tint)
                                                 (Econst_int (Int.repr 128) tint)
                                                 tint) tuint)
                                             (Econst_int (Int.repr 1) tint)
                                             tuint) ::
                                           (Econst_int (Int.repr 65536) tint) ::
                                           nil))
                                        (Ssequence
                                          (Scall None
                                            (Evar _set_mario_animation 
                                            (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tint :: nil) tshort
                                              cc_default))
                                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                             (Econst_int (Int.repr 136) tint) ::
                                             nil))
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'19
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                    (Tstruct _MarioState noattr))
                                                  _forwardVel tfloat))
                                              (Ssequence
                                                (Sset _t'20
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                          (Tstruct _MarioState noattr))
                                                        _vel
                                                        (tarray tfloat 3))
                                                      (Econst_int (Int.repr 1) tint)
                                                      (tptr tfloat)) tfloat))
                                                (Scall (Some _t'8)
                                                  (Evar _atan2s (Tfunction
                                                                  (tfloat ::
                                                                   tfloat ::
                                                                   nil)
                                                                  tshort
                                                                  cc_default))
                                                  ((Etempvar _t'19 tfloat) ::
                                                   (Eunop Oneg
                                                     (Etempvar _t'20 tfloat)
                                                     tfloat) :: nil))))
                                            (Ssequence
                                              (Sset _t'18
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                    (Tstruct _MarioState noattr))
                                                  _marioObj
                                                  (tptr (Tstruct _Object noattr))))
                                              (Sassign
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Efield
                                                      (Efield
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar _t'18 (tptr (Tstruct _Object noattr)))
                                                            (Tstruct _Object noattr))
                                                          _header
                                                          (Tstruct _ObjectNode noattr))
                                                        _gfx
                                                        (Tstruct _GraphNodeObject noattr))
                                                      _angle
                                                      (tarray tshort 3))
                                                    (Econst_int (Int.repr 0) tint)
                                                    (tptr tshort)) tshort)
                                                (Etempvar _t'8 tshort))))))))
                                  (Ssequence
                                    (Sassign
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _squishTimer tuchar)
                                      (Econst_int (Int.repr 255) tint))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'13
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _actionTimer tushort))
                                        (Sifthenelse (Ebinop Oge
                                                       (Etempvar _t'13 tushort)
                                                       (Econst_int (Int.repr 11) tint)
                                                       tint)
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'16
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                    (Tstruct _MarioState noattr))
                                                  _actionTimer tushort))
                                              (Sassign
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                    (Tstruct _MarioState noattr))
                                                  _actionTimer tushort)
                                                (Ebinop Osub
                                                  (Etempvar _t'16 tushort)
                                                  (Econst_int (Int.repr 6) tint)
                                                  tint)))
                                            (Ssequence
                                              (Ssequence
                                                (Sset _t'15
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                      (Tstruct _MarioState noattr))
                                                    _actionTimer tushort))
                                                (Sset _scale
                                                  (Ebinop Odiv
                                                    (Etempvar _t'15 tushort)
                                                    (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                                                    tfloat)))
                                              (Ssequence
                                                (Sset _t'14
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                      (Tstruct _MarioState noattr))
                                                    _marioObj
                                                    (tptr (Tstruct _Object noattr))))
                                                (Scall None
                                                  (Evar _vec3f_set (Tfunction
                                                                    ((tptr tfloat) ::
                                                                    tfloat ::
                                                                    tfloat ::
                                                                    tfloat ::
                                                                    nil)
                                                                    (tptr tvoid)
                                                                    cc_default))
                                                  ((Efield
                                                     (Efield
                                                       (Efield
                                                         (Ederef
                                                           (Etempvar _t'14 (tptr (Tstruct _Object noattr)))
                                                           (Tstruct _Object noattr))
                                                         _header
                                                         (Tstruct _ObjectNode noattr))
                                                       _gfx
                                                       (Tstruct _GraphNodeObject noattr))
                                                     _scale
                                                     (tarray tfloat 3)) ::
                                                   (Etempvar _scale tfloat) ::
                                                   (Etempvar _scale tfloat) ::
                                                   (Etempvar _scale tfloat) ::
                                                   nil)))))
                                          Sskip))
                                      Sbreak)))))))
                        (LScons (Some 4)
                          (Ssequence
                            (Scall None
                              (Evar _stop_and_set_height_to_floor (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               nil))
                            (Ssequence
                              (Ssequence
                                (Sset _t'10
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _marioObj
                                    (tptr (Tstruct _Object noattr))))
                                (Ssequence
                                  (Sset _t'11
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _marioObj
                                      (tptr (Tstruct _Object noattr))))
                                  (Ssequence
                                    (Sset _t'12
                                      (Efield
                                        (Efield
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'11 (tptr (Tstruct _Object noattr)))
                                                (Tstruct _Object noattr))
                                              _header
                                              (Tstruct _ObjectNode noattr))
                                            _gfx
                                            (Tstruct _GraphNodeObject noattr))
                                          _node (Tstruct _GraphNode noattr))
                                        _flags tshort))
                                    (Sassign
                                      (Efield
                                        (Efield
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                                                (Tstruct _Object noattr))
                                              _header
                                              (Tstruct _ObjectNode noattr))
                                            _gfx
                                            (Tstruct _GraphNodeObject noattr))
                                          _node (Tstruct _GraphNode noattr))
                                        _flags tshort)
                                      (Ebinop Oor (Etempvar _t'12 tshort)
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 4) tint)
                                          tint) tint)))))
                              Sbreak))
                          LSnil)))))))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_bbh_enter_jump := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_cageDX, tfloat) :: (_cageDZ, tfloat) ::
               (_cageDist, tfloat) :: (_t'3, tshort) :: (_t'2, tfloat) ::
               (_t'1, tuint) :: (_t'13, tuint) :: (_t'12, tfloat) ::
               (_t'11, tfloat) :: (_t'10, (tptr (Tstruct _Object noattr))) ::
               (_t'9, tfloat) :: (_t'8, tfloat) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tuint) ::
               (_t'5, tushort) :: (_t'4, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'13
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _flags tuint))
      (Sifthenelse (Ebinop Oand (Etempvar _t'13 tuint)
                     (Econst_int (Int.repr 4) tint) tuint)
        (Sset _t'1
          (Ecast
            (Ebinop Oor
              (Ebinop Oor
                (Ebinop Oor
                  (Ebinop Oor
                    (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                      (Econst_int (Int.repr 28) tint) tuint)
                    (Ebinop Oshl
                      (Ecast (Econst_int (Int.repr 40) tint) tuint)
                      (Econst_int (Int.repr 16) tint) tuint) tuint)
                  (Ebinop Oshl (Ecast (Econst_int (Int.repr 144) tint) tuint)
                    (Econst_int (Int.repr 8) tint) tuint) tuint)
                (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                  (Econst_int (Int.repr 128) tint) tint) tuint)
              (Econst_int (Int.repr 1) tint) tuint) tuint))
        (Sset _t'1
          (Ecast
            (Ebinop Oor
              (Ebinop Oor
                (Ebinop Oor
                  (Ebinop Oor
                    (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                      (Econst_int (Int.repr 28) tint) tuint)
                    (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                      (Econst_int (Int.repr 16) tint) tuint) tuint)
                  (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                    (Econst_int (Int.repr 8) tint) tuint) tuint)
                (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                  (Econst_int (Int.repr 128) tint) tint) tuint)
              (Econst_int (Int.repr 1) tint) tuint) tuint))))
    (Scall None
      (Evar _play_mario_action_sound (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tuint :: tuint :: nil) tvoid
                                       cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _t'1 tuint) :: (Econst_int (Int.repr 1) tint) :: nil)))
  (Ssequence
    (Scall None
      (Evar _play_mario_jump_sound (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Ssequence
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionState tushort))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tushort)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'10
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _usedObj
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
                          (Tunion __729 noattr)) _asF32 (tarray tfloat 80))
                      (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                        (Econst_int (Int.repr 0) tint) tint) (tptr tfloat))
                    tfloat))
                (Ssequence
                  (Sset _t'12
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _pos
                          (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tfloat)) tfloat))
                  (Sset _cageDX
                    (Ebinop Osub (Etempvar _t'11 tfloat)
                      (Etempvar _t'12 tfloat) tfloat)))))
            (Ssequence
              (Ssequence
                (Sset _t'7
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _usedObj
                    (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'8
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __729 noattr)) _asF32 (tarray tfloat 80))
                        (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                          (Econst_int (Int.repr 2) tint) tint) (tptr tfloat))
                      tfloat))
                  (Ssequence
                    (Sset _t'9
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _pos
                            (tarray tfloat 3)) (Econst_int (Int.repr 2) tint)
                          (tptr tfloat)) tfloat))
                    (Sset _cageDZ
                      (Ebinop Osub (Etempvar _t'8 tfloat)
                        (Etempvar _t'9 tfloat) tfloat)))))
              (Ssequence
                (Ssequence
                  (Scall (Some _t'2)
                    (Evar _sqrtf (Tfunction (tfloat :: nil) tfloat
                                   cc_default))
                    ((Ebinop Oadd
                       (Ebinop Omul (Etempvar _cageDX tfloat)
                         (Etempvar _cageDX tfloat) tfloat)
                       (Ebinop Omul (Etempvar _cageDZ tfloat)
                         (Etempvar _cageDZ tfloat) tfloat) tfloat) :: nil))
                  (Sset _cageDist (Etempvar _t'2 tfloat)))
                (Ssequence
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _vel
                          (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tfloat)) tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat))
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'3)
                        (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil)
                                        tshort cc_default))
                        ((Etempvar _cageDZ tfloat) ::
                         (Etempvar _cageDX tfloat) :: nil))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _faceAngle
                              (tarray tshort 3))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))
                          tshort) (Etempvar _t'3 tshort)))
                    (Ssequence
                      (Scall None
                        (Evar _mario_set_forward_vel (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tfloat :: nil) tvoid
                                                       cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Ebinop Odiv (Etempvar _cageDist tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 1101004800)) tfloat)
                           tfloat) :: nil))
                      (Ssequence
                        (Ssequence
                          (Sset _t'6
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _flags tuint))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _flags tuint)
                            (Ebinop Oand (Etempvar _t'6 tuint)
                              (Eunop Onotint (Econst_int (Int.repr 256) tint)
                                tint) tuint)))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _actionState
                            tushort) (Econst_int (Int.repr 1) tint)))))))))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _set_mario_animation (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tint :: nil) tshort cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 80) tint) :: nil))
        (Ssequence
          (Scall None
            (Evar _perform_air_step (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                    (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
              (Sifthenelse (Ebinop Ole (Etempvar _t'4 tfloat)
                             (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                             tint)
                (Scall None
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 5429) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                Sskip))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_teleport_fade_out := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tushort) :: (_t'1, tint) :: (_t'6, tuint) ::
               (_t'5, tuint) :: (_t'4, tushort) :: (_t'3, tushort) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _play_sound_if_no_flag (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tuint :: tuint :: nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Ebinop Oor
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
               (Econst_int (Int.repr 28) tint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 87) tint) tuint)
               (Econst_int (Int.repr 16) tint) tuint) tuint)
           (Ebinop Oshl (Ecast (Econst_int (Int.repr 192) tint) tuint)
             (Econst_int (Int.repr 8) tint) tuint) tuint)
         (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
           (Econst_int (Int.repr 128) tint) tint) tuint)
       (Econst_int (Int.repr 1) tint) tuint) ::
     (Econst_int (Int.repr 65536) tint) :: nil))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _prevAction tuint))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'6 tuint)
                       (Econst_int (Int.repr 201359904) tint) tint)
          (Sset _t'1 (Ecast (Econst_int (Int.repr 152) tint) tint))
          (Sset _t'1 (Ecast (Econst_int (Int.repr 194) tint) tint))))
      (Scall None
        (Evar _set_mario_animation (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tint :: nil) tshort cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Etempvar _t'1 tint) :: nil)))
    (Ssequence
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _flags tuint))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _flags tuint)
          (Ebinop Oor (Etempvar _t'5 tuint) (Econst_int (Int.repr 128) tint)
            tuint)))
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort))
          (Sifthenelse (Ebinop Olt (Etempvar _t'3 tushort)
                         (Econst_int (Int.repr 32) tint) tint)
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionTimer tushort))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _fadeWarpOpacity tuchar)
                (Ebinop Oadd
                  (Ebinop Oshl (Eunop Oneg (Etempvar _t'4 tushort) tint)
                    (Econst_int (Int.repr 3) tint) tint)
                  (Econst_int (Int.repr 248) tint) tint)))
            Sskip))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'2
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionTimer tushort))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionTimer tushort)
                (Ebinop Oadd (Etempvar _t'2 tushort)
                  (Econst_int (Int.repr 1) tint) tint)))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tushort)
                           (Econst_int (Int.repr 20) tint) tint)
              (Scall None
                (Evar _level_trigger_warp (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tint :: nil) tshort cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 5) tint) :: nil))
              Sskip))
          (Ssequence
            (Scall None
              (Evar _stop_and_set_height_to_floor (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_teleport_fade_in := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tushort) :: (_t'12, tuint) :: (_t'11, tushort) ::
               (_t'10, tuint) :: (_t'9, tushort) ::
               (_t'8, (tptr (Tstruct _Camera noattr))) ::
               (_t'7, (tptr (Tstruct _Area noattr))) :: (_t'6, tuchar) ::
               (_t'5, (tptr (Tstruct _Camera noattr))) ::
               (_t'4, (tptr (Tstruct _Area noattr))) :: (_t'3, tshort) ::
               (_t'2, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _play_sound_if_no_flag (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tuint :: tuint :: nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Ebinop Oor
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
               (Econst_int (Int.repr 28) tint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 87) tint) tuint)
               (Econst_int (Int.repr 16) tint) tuint) tuint)
           (Ebinop Oshl (Ecast (Econst_int (Int.repr 192) tint) tuint)
             (Econst_int (Int.repr 8) tint) tuint) tuint)
         (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
           (Econst_int (Int.repr 128) tint) tint) tuint)
       (Econst_int (Int.repr 1) tint) tuint) ::
     (Econst_int (Int.repr 65536) tint) :: nil))
  (Ssequence
    (Scall None
      (Evar _set_mario_animation (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 194) tint) :: nil))
    (Ssequence
      (Ssequence
        (Sset _t'9
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort))
        (Sifthenelse (Ebinop Olt (Etempvar _t'9 tushort)
                       (Econst_int (Int.repr 32) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'12
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _flags tuint))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _flags tuint)
                (Ebinop Oor (Etempvar _t'12 tuint)
                  (Econst_int (Int.repr 128) tint) tuint)))
            (Ssequence
              (Sset _t'11
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionTimer tushort))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _fadeWarpOpacity tuchar)
                (Ebinop Oshl (Etempvar _t'11 tushort)
                  (Econst_int (Int.repr 3) tint) tint))))
          (Ssequence
            (Sset _t'10
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _flags tuint))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _flags tuint)
              (Ebinop Oand (Etempvar _t'10 tuint)
                (Eunop Onotint (Econst_int (Int.repr 128) tint) tint) tuint)))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'1
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort)
              (Ebinop Oadd (Etempvar _t'1 tushort)
                (Econst_int (Int.repr 1) tint) tint)))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tushort)
                         (Econst_int (Int.repr 32) tint) tint)
            (Ssequence
              (Sset _t'2
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                    (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
              (Ssequence
                (Sset _t'3
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _waterLevel tshort))
                (Sifthenelse (Ebinop Olt (Etempvar _t'2 tfloat)
                               (Ebinop Osub (Etempvar _t'3 tshort)
                                 (Econst_int (Int.repr 100) tint) tint) tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'4
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _area
                          (tptr (Tstruct _Area noattr))))
                      (Ssequence
                        (Sset _t'5
                          (Efield
                            (Ederef
                              (Etempvar _t'4 (tptr (Tstruct _Area noattr)))
                              (Tstruct _Area noattr)) _camera
                            (tptr (Tstruct _Camera noattr))))
                        (Ssequence
                          (Sset _t'6
                            (Efield
                              (Ederef
                                (Etempvar _t'5 (tptr (Tstruct _Camera noattr)))
                                (Tstruct _Camera noattr)) _mode tuchar))
                          (Sifthenelse (Ebinop One (Etempvar _t'6 tuchar)
                                         (Econst_int (Int.repr 8) tint) tint)
                            (Ssequence
                              (Sset _t'7
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _area
                                  (tptr (Tstruct _Area noattr))))
                              (Ssequence
                                (Sset _t'8
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'7 (tptr (Tstruct _Area noattr)))
                                      (Tstruct _Area noattr)) _camera
                                    (tptr (Tstruct _Camera noattr))))
                                (Scall None
                                  (Evar _set_camera_mode (Tfunction
                                                           ((tptr (Tstruct _Camera noattr)) ::
                                                            tshort ::
                                                            tshort :: nil)
                                                           tvoid cc_default))
                                  ((Etempvar _t'8 (tptr (Tstruct _Camera noattr))) ::
                                   (Econst_int (Int.repr 8) tint) ::
                                   (Econst_int (Int.repr 1) tint) :: nil))))
                            Sskip))))
                    (Scall None
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 939532992) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil)))
                  (Scall None
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 205521409) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil)))))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _stop_and_set_height_to_floor (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_shocked := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tshort) ::
               (_t'9, (tptr (Tstruct _Object noattr))) :: (_t'8, tushort) ::
               (_t'7, tuint) :: (_t'6, tshort) :: (_t'5, tushort) ::
               (_t'4, tuint) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _play_sound_if_no_flag (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tuint :: tuint :: nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Ebinop Oor
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 2) tint) tuint)
               (Econst_int (Int.repr 28) tint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 16) tint) tuint)
               (Econst_int (Int.repr 16) tint) tuint) tuint)
           (Ebinop Oshl (Ecast (Econst_int (Int.repr 192) tint) tuint)
             (Econst_int (Int.repr 8) tint) tuint) tuint)
         (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
           (Econst_int (Int.repr 128) tint) tint) tuint)
       (Econst_int (Int.repr 1) tint) tuint) ::
     (Econst_int (Int.repr 65536) tint) :: nil))
  (Ssequence
    (Ssequence
      (Sset _t'9
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioObj
          (tptr (Tstruct _Object noattr))))
      (Scall None
        (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                            cc_default))
        ((Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 1) tint) tuint)
                   (Econst_int (Int.repr 28) tint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 22) tint) tuint)
                   (Econst_int (Int.repr 16) tint) tuint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 8) tint) tuint) tuint)
             (Econst_int (Int.repr 67108864) tint) tuint)
           (Econst_int (Int.repr 1) tint) tuint) ::
         (Efield
           (Efield
             (Efield
               (Ederef (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                 (Tstruct _Object noattr)) _header
               (Tstruct _ObjectNode noattr)) _gfx
             (Tstruct _GraphNodeObject noattr)) _cameraToObject
           (tarray tfloat 3)) :: nil)))
    (Ssequence
      (Scall None
        (Evar _set_camera_shake_from_hit (Tfunction (tshort :: nil) tvoid
                                           cc_default))
        ((Econst_int (Int.repr 10) tint) :: nil))
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _set_mario_animation (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 122) tint) :: nil))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tshort)
                         (Econst_int (Int.repr 0) tint) tint)
            (Ssequence
              (Ssequence
                (Sset _t'8
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionTimer tushort))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionTimer tushort)
                  (Ebinop Oadd (Etempvar _t'8 tushort)
                    (Econst_int (Int.repr 1) tint) tint)))
              (Ssequence
                (Sset _t'7
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _flags tuint))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _flags tuint)
                  (Ebinop Oor (Etempvar _t'7 tuint)
                    (Econst_int (Int.repr 64) tint) tuint))))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionArg tuint))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tuint)
                           (Econst_int (Int.repr 0) tint) tint)
              (Ssequence
                (Scall None
                  (Evar _mario_set_forward_vel (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tfloat :: nil) tvoid
                                                 cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                   nil))
                (Ssequence
                  (Scall (Some _t'2)
                    (Evar _perform_air_step (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 1) tint) :: nil))
                  (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tint)
                                 (Econst_int (Int.repr 1) tint) tint)
                    (Ssequence
                      (Scall None
                        (Evar _play_mario_landing_sound (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           tuint :: nil)
                                                          tvoid cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oshl
                                   (Ecast (Econst_int (Int.repr 0) tint)
                                     tuint) (Econst_int (Int.repr 28) tint)
                                   tuint)
                                 (Ebinop Oshl
                                   (Ecast (Econst_int (Int.repr 8) tint)
                                     tuint) (Econst_int (Int.repr 16) tint)
                                   tuint) tuint)
                               (Ebinop Oshl
                                 (Ecast (Econst_int (Int.repr 128) tint)
                                   tuint) (Econst_int (Int.repr 8) tint)
                                 tuint) tuint)
                             (Ebinop Oor
                               (Econst_int (Int.repr 67108864) tint)
                               (Econst_int (Int.repr 128) tint) tint) tuint)
                           (Econst_int (Int.repr 1) tint) tuint) :: nil))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionArg tuint)
                        (Econst_int (Int.repr 1) tint)))
                    Sskip)))
              (Ssequence
                (Ssequence
                  (Sset _t'5
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionTimer tushort))
                  (Sifthenelse (Ebinop Oge (Etempvar _t'5 tushort)
                                 (Econst_int (Int.repr 6) tint) tint)
                    (Ssequence
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _invincTimer
                          tshort) (Econst_int (Int.repr 30) tint))
                      (Ssequence
                        (Ssequence
                          (Sset _t'6
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _health tshort))
                          (Sifthenelse (Ebinop Olt (Etempvar _t'6 tshort)
                                         (Econst_int (Int.repr 256) tint)
                                         tint)
                            (Sset _t'3
                              (Ecast (Econst_int (Int.repr 135955) tint)
                                tint))
                            (Sset _t'3
                              (Ecast (Econst_int (Int.repr 205521409) tint)
                                tint))))
                        (Scall None
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Etempvar _t'3 tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))))
                    Sskip))
                (Scall None
                  (Evar _stop_and_set_height_to_floor (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tvoid
                                                        cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil)))))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_squished := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := ((_filler, (tarray tuchar 4)) :: nil);
  fn_temps := ((_squishAmount, tfloat) :: (_spaceUnderCeil, tfloat) ::
               (_surfAngle, tshort) :: (_underSteepSurf, tint) ::
               (_t'10, tuint) :: (_t'9, tint) :: (_t'8, tint) ::
               (_t'7, tshort) :: (_t'6, tint) :: (_t'5, tshort) ::
               (_t'4, tint) :: (_t'3, tint) :: (_t'2, tuint) ::
               (_t'1, tfloat) :: (_t'39, tfloat) :: (_t'38, tfloat) ::
               (_t'37, (tptr (Tstruct _Object noattr))) :: (_t'36, tshort) ::
               (_t'35, tuint) :: (_t'34, tuint) :: (_t'33, tuchar) ::
               (_t'32, (tptr (Tstruct _Object noattr))) ::
               (_t'31, tushort) :: (_t'30, tuchar) :: (_t'29, tshort) ::
               (_t'28, tushort) :: (_t'27, tushort) :: (_t'26, tfloat) ::
               (_t'25, (tptr (Tstruct _Surface noattr))) ::
               (_t'24, (tptr (Tstruct _Surface noattr))) ::
               (_t'23, tfloat) ::
               (_t'22, (tptr (Tstruct _Surface noattr))) ::
               (_t'21, tfloat) ::
               (_t'20, (tptr (Tstruct _Surface noattr))) ::
               (_t'19, tfloat) ::
               (_t'18, (tptr (Tstruct _Surface noattr))) ::
               (_t'17, (tptr (Tstruct _Surface noattr))) ::
               (_t'16, tfloat) ::
               (_t'15, (tptr (Tstruct _Surface noattr))) ::
               (_t'14, tfloat) ::
               (_t'13, (tptr (Tstruct _Surface noattr))) ::
               (_t'12, tfloat) :: (_t'11, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _underSteepSurf (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'38
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _ceilHeight tfloat))
          (Ssequence
            (Sset _t'39
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _floorHeight tfloat))
            (Sset _t'1
              (Ecast
                (Ebinop Osub (Etempvar _t'38 tfloat) (Etempvar _t'39 tfloat)
                  tfloat) tfloat))))
        (Sset _spaceUnderCeil (Etempvar _t'1 tfloat)))
      (Sifthenelse (Ebinop Olt (Etempvar _t'1 tfloat)
                     (Econst_int (Int.repr 0) tint) tint)
        (Sset _spaceUnderCeil (Ecast (Econst_int (Int.repr 0) tint) tfloat))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'27
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionState tushort))
        (Sswitch (Etempvar _t'27 tushort)
          (LScons (Some 0)
            (Ssequence
              (Sifthenelse (Ebinop Ogt (Etempvar _spaceUnderCeil tfloat)
                             (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat)
                             tint)
                (Ssequence
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _squishTimer tuchar)
                    (Econst_int (Int.repr 0) tint))
                  (Ssequence
                    (Scall (Some _t'2)
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 205521409) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    (Sreturn (Some (Etempvar _t'2 tuint)))))
                Sskip)
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _squishTimer tuchar)
                  (Econst_int (Int.repr 255) tint))
                (Ssequence
                  (Sifthenelse (Ebinop Oge (Etempvar _spaceUnderCeil tfloat)
                                 (Econst_single (Float32.of_bits (Int.repr 1092721050)) tfloat)
                                 tint)
                    (Ssequence
                      (Sset _squishAmount
                        (Ebinop Odiv (Etempvar _spaceUnderCeil tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat)
                          tfloat))
                      (Ssequence
                        (Sset _t'37
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _marioObj
                            (tptr (Tstruct _Object noattr))))
                        (Scall None
                          (Evar _vec3f_set (Tfunction
                                             ((tptr tfloat) :: tfloat ::
                                              tfloat :: tfloat :: nil)
                                             (tptr tvoid) cc_default))
                          ((Efield
                             (Efield
                               (Efield
                                 (Ederef
                                   (Etempvar _t'37 (tptr (Tstruct _Object noattr)))
                                   (Tstruct _Object noattr)) _header
                                 (Tstruct _ObjectNode noattr)) _gfx
                               (Tstruct _GraphNodeObject noattr)) _scale
                             (tarray tfloat 3)) ::
                           (Ebinop Osub
                             (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                             (Etempvar _squishAmount tfloat) tfloat) ::
                           (Etempvar _squishAmount tfloat) ::
                           (Ebinop Osub
                             (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                             (Etempvar _squishAmount tfloat) tfloat) :: nil))))
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'35
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _flags tuint))
                          (Sifthenelse (Eunop Onotbool
                                         (Ebinop Oand (Etempvar _t'35 tuint)
                                           (Econst_int (Int.repr 4) tint)
                                           tuint) tint)
                            (Ssequence
                              (Sset _t'36
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr))
                                  _invincTimer tshort))
                              (Sset _t'4
                                (Ecast
                                  (Ebinop Oeq (Etempvar _t'36 tshort)
                                    (Econst_int (Int.repr 0) tint) tint)
                                  tbool)))
                            (Sset _t'4 (Econst_int (Int.repr 0) tint))))
                        (Sifthenelse (Etempvar _t'4 tint)
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Sset _t'34
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _flags
                                    tuint))
                                (Sifthenelse (Ebinop Oand
                                               (Etempvar _t'34 tuint)
                                               (Econst_int (Int.repr 16) tint)
                                               tuint)
                                  (Sset _t'3
                                    (Ecast (Econst_int (Int.repr 12) tint)
                                      tint))
                                  (Sset _t'3
                                    (Ecast (Econst_int (Int.repr 18) tint)
                                      tint))))
                              (Ssequence
                                (Sset _t'33
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _hurtCounter tuchar))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _hurtCounter tuchar)
                                  (Ebinop Oadd (Etempvar _t'33 tuchar)
                                    (Etempvar _t'3 tint) tint))))
                            (Scall None
                              (Evar _play_sound_if_no_flag (Tfunction
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
                                         (Ecast
                                           (Econst_int (Int.repr 2) tint)
                                           tuint)
                                         (Econst_int (Int.repr 28) tint)
                                         tuint)
                                       (Ebinop Oshl
                                         (Ecast
                                           (Econst_int (Int.repr 10) tint)
                                           tuint)
                                         (Econst_int (Int.repr 16) tint)
                                         tuint) tuint)
                                     (Ebinop Oshl
                                       (Ecast
                                         (Econst_int (Int.repr 255) tint)
                                         tuint)
                                       (Econst_int (Int.repr 8) tint) tuint)
                                     tuint)
                                   (Ebinop Oor
                                     (Econst_int (Int.repr 67108864) tint)
                                     (Econst_int (Int.repr 128) tint) tint)
                                   tuint) (Econst_int (Int.repr 1) tint)
                                 tuint) ::
                               (Econst_int (Int.repr 131072) tint) :: nil)))
                          Sskip))
                      (Ssequence
                        (Ssequence
                          (Sset _t'32
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _marioObj
                              (tptr (Tstruct _Object noattr))))
                          (Scall None
                            (Evar _vec3f_set (Tfunction
                                               ((tptr tfloat) :: tfloat ::
                                                tfloat :: tfloat :: nil)
                                               (tptr tvoid) cc_default))
                            ((Efield
                               (Efield
                                 (Efield
                                   (Ederef
                                     (Etempvar _t'32 (tptr (Tstruct _Object noattr)))
                                     (Tstruct _Object noattr)) _header
                                   (Tstruct _ObjectNode noattr)) _gfx
                                 (Tstruct _GraphNodeObject noattr)) _scale
                               (tarray tfloat 3)) ::
                             (Econst_float (Float.of_bits (Int64.repr 4610785298501913805)) tdouble) ::
                             (Econst_single (Float32.of_bits (Int.repr 1028443341)) tfloat) ::
                             (Econst_single (Float32.of_bits (Int.repr 1072064102)) tfloat) ::
                             nil)))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _actionState
                            tushort) (Econst_int (Int.repr 1) tint)))))
                  Sbreak)))
            (LScons (Some 1)
              (Ssequence
                (Sifthenelse (Ebinop Oge (Etempvar _spaceUnderCeil tfloat)
                               (Econst_single (Float32.of_bits (Int.repr 1106247680)) tfloat)
                               tint)
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionState tushort)
                    (Econst_int (Int.repr 2) tint))
                  Sskip)
                Sbreak)
              (LScons (Some 2)
                (Ssequence
                  (Ssequence
                    (Sset _t'31
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionTimer tushort))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionTimer tushort)
                      (Ebinop Oadd (Etempvar _t'31 tushort)
                        (Econst_int (Int.repr 1) tint) tint)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'28
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionTimer
                          tushort))
                      (Sifthenelse (Ebinop Oge (Etempvar _t'28 tushort)
                                     (Econst_int (Int.repr 15) tint) tint)
                        (Ssequence
                          (Sset _t'29
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _health tshort))
                          (Sifthenelse (Ebinop Olt (Etempvar _t'29 tshort)
                                         (Econst_int (Int.repr 256) tint)
                                         tint)
                            (Ssequence
                              (Scall None
                                (Evar _level_trigger_warp (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             tint :: nil)
                                                            tshort
                                                            cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 (Econst_int (Int.repr 18) tint) :: nil))
                              (Scall None
                                (Evar _set_mario_action (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           tuint :: tuint ::
                                                           nil) tuint
                                                          cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 (Econst_int (Int.repr 4864) tint) ::
                                 (Econst_int (Int.repr 0) tint) :: nil)))
                            (Ssequence
                              (Sset _t'30
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr))
                                  _hurtCounter tuchar))
                              (Sifthenelse (Ebinop Oeq
                                             (Etempvar _t'30 tuchar)
                                             (Econst_int (Int.repr 0) tint)
                                             tint)
                                (Ssequence
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _squishTimer tuchar)
                                    (Econst_int (Int.repr 30) tint))
                                  (Scall None
                                    (Evar _set_mario_action (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               tuint ::
                                                               tuint :: nil)
                                                              tuint
                                                              cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     (Econst_int (Int.repr 205521409) tint) ::
                                     (Econst_int (Int.repr 0) tint) :: nil)))
                                Sskip))))
                        Sskip))
                    Sbreak))
                LSnil)))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'24
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _floor
                (tptr (Tstruct _Surface noattr))))
            (Sifthenelse (Ebinop One
                           (Etempvar _t'24 (tptr (Tstruct _Surface noattr)))
                           (Ecast (Econst_int (Int.repr 0) tint)
                             (tptr tvoid)) tint)
              (Ssequence
                (Sset _t'25
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _floor
                    (tptr (Tstruct _Surface noattr))))
                (Ssequence
                  (Sset _t'26
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'25 (tptr (Tstruct _Surface noattr)))
                          (Tstruct _Surface noattr)) _normal
                        (Tstruct __734 noattr)) _y tfloat))
                  (Sset _t'6
                    (Ecast
                      (Ebinop Olt (Etempvar _t'26 tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat)
                        tint) tbool))))
              (Sset _t'6 (Econst_int (Int.repr 0) tint))))
          (Sifthenelse (Etempvar _t'6 tint)
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'20
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _floor
                      (tptr (Tstruct _Surface noattr))))
                  (Ssequence
                    (Sset _t'21
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'20 (tptr (Tstruct _Surface noattr)))
                            (Tstruct _Surface noattr)) _normal
                          (Tstruct __734 noattr)) _z tfloat))
                    (Ssequence
                      (Sset _t'22
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _floor
                          (tptr (Tstruct _Surface noattr))))
                      (Ssequence
                        (Sset _t'23
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'22 (tptr (Tstruct _Surface noattr)))
                                (Tstruct _Surface noattr)) _normal
                              (Tstruct __734 noattr)) _x tfloat))
                        (Scall (Some _t'5)
                          (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil)
                                          tshort cc_default))
                          ((Etempvar _t'21 tfloat) ::
                           (Etempvar _t'23 tfloat) :: nil))))))
                (Sset _surfAngle (Ecast (Etempvar _t'5 tshort) tshort)))
              (Sset _underSteepSurf (Econst_int (Int.repr 1) tint)))
            Sskip))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'17
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _ceil
                  (tptr (Tstruct _Surface noattr))))
              (Sifthenelse (Ebinop One
                             (Etempvar _t'17 (tptr (Tstruct _Surface noattr)))
                             (Ecast (Econst_int (Int.repr 0) tint)
                               (tptr tvoid)) tint)
                (Ssequence
                  (Sset _t'18
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _ceil
                      (tptr (Tstruct _Surface noattr))))
                  (Ssequence
                    (Sset _t'19
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'18 (tptr (Tstruct _Surface noattr)))
                            (Tstruct _Surface noattr)) _normal
                          (Tstruct __734 noattr)) _y tfloat))
                    (Sset _t'8
                      (Ecast
                        (Ebinop Olt
                          (Eunop Oneg
                            (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat)
                            tfloat) (Etempvar _t'19 tfloat) tint) tbool))))
                (Sset _t'8 (Econst_int (Int.repr 0) tint))))
            (Sifthenelse (Etempvar _t'8 tint)
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'13
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _ceil
                        (tptr (Tstruct _Surface noattr))))
                    (Ssequence
                      (Sset _t'14
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'13 (tptr (Tstruct _Surface noattr)))
                              (Tstruct _Surface noattr)) _normal
                            (Tstruct __734 noattr)) _z tfloat))
                      (Ssequence
                        (Sset _t'15
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _ceil
                            (tptr (Tstruct _Surface noattr))))
                        (Ssequence
                          (Sset _t'16
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'15 (tptr (Tstruct _Surface noattr)))
                                  (Tstruct _Surface noattr)) _normal
                                (Tstruct __734 noattr)) _x tfloat))
                          (Scall (Some _t'7)
                            (Evar _atan2s (Tfunction
                                            (tfloat :: tfloat :: nil) tshort
                                            cc_default))
                            ((Etempvar _t'14 tfloat) ::
                             (Etempvar _t'16 tfloat) :: nil))))))
                  (Sset _surfAngle (Ecast (Etempvar _t'7 tshort) tshort)))
                (Sset _underSteepSurf (Econst_int (Int.repr 1) tint)))
              Sskip))
          (Ssequence
            (Sifthenelse (Etempvar _underSteepSurf tint)
              (Ssequence
                (Ssequence
                  (Sset _t'12
                    (Ederef
                      (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                        (Ebinop Oshr
                          (Ecast (Etempvar _surfAngle tshort) tushort)
                          (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                      tfloat))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _vel
                          (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tfloat)) tfloat)
                    (Ebinop Omul (Etempvar _t'12 tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                      tfloat)))
                (Ssequence
                  (Ssequence
                    (Sset _t'11
                      (Ederef
                        (Ebinop Oadd
                          (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                            (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                          (Ebinop Oshr
                            (Ecast (Etempvar _surfAngle tshort) tushort)
                            (Econst_int (Int.repr 4) tint) tint)
                          (tptr tfloat)) tfloat))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _vel
                            (tarray tfloat 3)) (Econst_int (Int.repr 2) tint)
                          (tptr tfloat)) tfloat)
                      (Ebinop Omul (Etempvar _t'11 tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                        tfloat)))
                  (Ssequence
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _vel
                            (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tfloat)) tfloat)
                      (Econst_int (Int.repr 0) tint))
                    (Ssequence
                      (Scall (Some _t'9)
                        (Evar _perform_ground_step (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      nil) tint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tint)
                                     (Econst_int (Int.repr 0) tint) tint)
                        (Ssequence
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _squishTimer
                              tuchar) (Econst_int (Int.repr 0) tint))
                          (Ssequence
                            (Scall None
                              (Evar _set_mario_action (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         tuint :: tuint ::
                                                         nil) tuint
                                                        cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 205521409) tint) ::
                               (Econst_int (Int.repr 0) tint) :: nil))
                            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
                        Sskip)))))
              Sskip)
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'10
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionArg tuint))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionArg tuint)
                    (Ebinop Oadd (Etempvar _t'10 tuint)
                      (Econst_int (Int.repr 1) tint) tuint)))
                (Sifthenelse (Ebinop Ogt (Etempvar _t'10 tuint)
                               (Econst_int (Int.repr 300) tint) tint)
                  (Ssequence
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _health tshort)
                      (Econst_int (Int.repr 255) tint))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _hurtCounter
                          tuchar) (Econst_int (Int.repr 0) tint))
                      (Ssequence
                        (Scall None
                          (Evar _level_trigger_warp (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tint :: nil) tshort
                                                      cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 18) tint) :: nil))
                        (Scall None
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 4864) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil)))))
                  Sskip))
              (Ssequence
                (Scall None
                  (Evar _stop_and_set_height_to_floor (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tvoid
                                                        cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Ssequence
                  (Scall None
                    (Evar _set_mario_animation (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tint :: nil) tshort
                                                 cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 14) tint) :: nil))
                  (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))
|}.

Definition f_act_putting_on_cap := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_animFrame, tint) :: (_t'2, tint) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _set_mario_animation (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 54) tint) :: nil))
    (Sset _animFrame (Etempvar _t'1 tshort)))
  (Ssequence
    (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                   (Econst_int (Int.repr 0) tint) tint)
      (Scall None (Evar _enable_time_stop (Tfunction nil tvoid cc_default))
        nil)
      Sskip)
    (Ssequence
      (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                     (Econst_int (Int.repr 28) tint) tint)
        (Scall None
          (Evar _cutscene_put_cap_on (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        Sskip)
      (Ssequence
        (Ssequence
          (Scall (Some _t'2)
            (Evar _is_anim_at_end (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sifthenelse (Etempvar _t'2 tint)
            (Ssequence
              (Scall None
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 205521409) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Scall None
                (Evar _disable_time_stop (Tfunction nil tvoid cc_default))
                nil))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _stationary_ground_step (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_stuck_in_ground_handler := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_animation, tint) :: (_unstuckFrame, tint) ::
                (_target2, tint) :: (_target3, tint) :: (_endAction, tint) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_animFrame, tint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tshort) :: (_t'7, tushort) ::
               (_t'6, tushort) :: (_t'5, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _set_mario_animation (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _animation tint) :: nil))
    (Sset _animFrame (Etempvar _t'1 tshort)))
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'5 tushort)
                     (Econst_int (Int.repr 2) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'7
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort)
              (Ebinop Oadd (Etempvar _t'7 tushort)
                (Econst_int (Int.repr 1) tint) tint)))
          (Ssequence
            (Ssequence
              (Sset _t'6
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionTimer tushort))
              (Sifthenelse (Ebinop Oge (Etempvar _t'6 tushort)
                             (Econst_int (Int.repr 5) tint) tint)
                (Sset _t'2
                  (Ecast
                    (Ebinop Olt (Etempvar _animFrame tint)
                      (Ebinop Osub (Etempvar _unstuckFrame tint)
                        (Econst_int (Int.repr 1) tint) tint) tint) tbool))
                (Sset _t'2 (Econst_int (Int.repr 0) tint))))
            (Sifthenelse (Etempvar _t'2 tint)
              (Ssequence
                (Sset _animFrame
                  (Ebinop Osub (Etempvar _unstuckFrame tint)
                    (Econst_int (Int.repr 1) tint) tint))
                (Scall None
                  (Evar _set_anim_to_frame (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tshort :: nil) tvoid
                                             cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Etempvar _animFrame tint) :: nil)))
              Sskip)))
        Sskip))
    (Ssequence
      (Scall None
        (Evar _stop_and_set_height_to_floor (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Ssequence
        (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                       (Eunop Oneg (Econst_int (Int.repr 1) tint) tint) tint)
          (Scall None
            (Evar _play_sound_and_spawn_particles (Tfunction
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
                       (Ecast (Econst_int (Int.repr 72) tint) tuint)
                       (Econst_int (Int.repr 16) tint) tuint) tuint)
                   (Ebinop Oshl
                     (Ecast (Econst_int (Int.repr 128) tint) tuint)
                     (Econst_int (Int.repr 8) tint) tuint) tuint)
                 (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                   (Econst_int (Int.repr 128) tint) tint) tuint)
               (Econst_int (Int.repr 1) tint) tuint) ::
             (Econst_int (Int.repr 1) tint) :: nil))
          (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                         (Etempvar _unstuckFrame tint) tint)
            (Scall None
              (Evar _play_sound_and_spawn_particles (Tfunction
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
                         (Ecast (Econst_int (Int.repr 67) tint) tuint)
                         (Econst_int (Int.repr 16) tint) tuint) tuint)
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 128) tint) tuint)
                       (Econst_int (Int.repr 8) tint) tuint) tuint)
                   (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                     (Econst_int (Int.repr 128) tint) tint) tuint)
                 (Econst_int (Int.repr 1) tint) tuint) ::
               (Econst_int (Int.repr 1) tint) :: nil))
            (Ssequence
              (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                             (Etempvar _target2 tint) tint)
                (Sset _t'3 (Econst_int (Int.repr 1) tint))
                (Sset _t'3
                  (Ecast
                    (Ebinop Oeq (Etempvar _animFrame tint)
                      (Etempvar _target3 tint) tint) tbool)))
              (Sifthenelse (Etempvar _t'3 tint)
                (Scall None
                  (Evar _play_mario_landing_sound (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: nil) tvoid
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
                             (Ecast (Econst_int (Int.repr 8) tint) tuint)
                             (Econst_int (Int.repr 16) tint) tuint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 128) tint) tuint)
                           (Econst_int (Int.repr 8) tint) tuint) tuint)
                       (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                         (Econst_int (Int.repr 128) tint) tint) tuint)
                     (Econst_int (Int.repr 1) tint) tuint) :: nil))
                Sskip))))
        (Ssequence
          (Scall (Some _t'4)
            (Evar _is_anim_at_end (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sifthenelse (Etempvar _t'4 tint)
            (Scall None
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Etempvar _endAction tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            Sskip))))))
|}.

Definition f_act_head_stuck_in_ground := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _stuck_in_ground_handler (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tint :: tint :: tint :: tint :: tint ::
                                      nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Econst_int (Int.repr 57) tint) :: (Econst_int (Int.repr 96) tint) ::
     (Econst_int (Int.repr 105) tint) :: (Econst_int (Int.repr 135) tint) ::
     (Econst_int (Int.repr 205521409) tint) :: nil))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_act_butt_stuck_in_ground := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _stuck_in_ground_handler (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tint :: tint :: tint :: tint :: tint ::
                                      nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Econst_int (Int.repr 62) tint) :: (Econst_int (Int.repr 127) tint) ::
     (Econst_int (Int.repr 136) tint) ::
     (Eunop Oneg (Econst_int (Int.repr 2) tint) tint) ::
     (Econst_int (Int.repr 8389180) tint) :: nil))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_act_feet_stuck_in_ground := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _stuck_in_ground_handler (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tint :: tint :: tint :: tint :: tint ::
                                      nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Econst_int (Int.repr 85) tint) :: (Econst_int (Int.repr 116) tint) ::
     (Econst_int (Int.repr 129) tint) ::
     (Eunop Oneg (Econst_int (Int.repr 2) tint) tint) ::
     (Econst_int (Int.repr 205521409) tint) :: nil))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_advance_cutscene_step := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sassign
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _actionState tushort)
    (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sassign
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionTimer tushort)
      (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Sset _t'1
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionArg tuint))
      (Sassign
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionArg tuint)
        (Ebinop Oadd (Etempvar _t'1 tuint) (Econst_int (Int.repr 1) tint)
          tuint)))))
|}.

Definition f_intro_cutscene_hide_hud_and_mario := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, (tptr (Tstruct _PlayerCameraState noattr))) ::
               (_t'3, tshort) :: (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sassign
    (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr)) _flags tshort)
    (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Sset _t'4
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _statusForCamera
          (tptr (Tstruct _PlayerCameraState noattr))))
      (Sassign
        (Efield
          (Ederef (Etempvar _t'4 (tptr (Tstruct _PlayerCameraState noattr)))
            (Tstruct _PlayerCameraState noattr)) _cameraEvent tshort)
        (Econst_int (Int.repr 9) tint)))
    (Ssequence
      (Ssequence
        (Sset _t'1
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _marioObj
            (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'2
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioObj
              (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'3
              (Efield
                (Efield
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _header
                      (Tstruct _ObjectNode noattr)) _gfx
                    (Tstruct _GraphNodeObject noattr)) _node
                  (Tstruct _GraphNode noattr)) _flags tshort))
            (Sassign
              (Efield
                (Efield
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _header
                      (Tstruct _ObjectNode noattr)) _gfx
                    (Tstruct _GraphNodeObject noattr)) _node
                  (Tstruct _GraphNode noattr)) _flags tshort)
              (Ebinop Oand (Etempvar _t'3 tshort)
                (Eunop Onotint
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 0) tint) tint) tint) tint)))))
      (Scall None
        (Evar _advance_cutscene_step (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil)))))
|}.

Definition f_intro_cutscene_peach_lakitu_scene := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tushort) :: (_t'1, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: (_t'4, tshort) ::
               (_t'3, (tptr (Tstruct _PlayerCameraState noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'3
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _statusForCamera
      (tptr (Tstruct _PlayerCameraState noattr))))
  (Ssequence
    (Sset _t'4
      (Efield
        (Ederef (Etempvar _t'3 (tptr (Tstruct _PlayerCameraState noattr)))
          (Tstruct _PlayerCameraState noattr)) _cameraEvent tshort))
    (Sifthenelse (Ebinop One (Ecast (Etempvar _t'4 tshort) tshort)
                   (Econst_int (Int.repr 9) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'2
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort)
            (Ebinop Oadd (Etempvar _t'2 tushort)
              (Econst_int (Int.repr 1) tint) tint)))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tushort)
                       (Econst_int (Int.repr 37) tint) tint)
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                (Scall (Some _t'1)
                  (Evar _spawn_object_abs_with_rot (Tfunction
                                                     ((tptr (Tstruct _Object noattr)) ::
                                                      tshort :: tuint ::
                                                      (tptr tuint) ::
                                                      tshort :: tshort ::
                                                      tshort :: tshort ::
                                                      tshort :: tshort ::
                                                      nil)
                                                     (tptr (Tstruct _Object noattr))
                                                     cc_default))
                  ((Etempvar _t'5 (tptr (Tstruct _Object noattr))) ::
                   (Econst_int (Int.repr 0) tint) ::
                   (Econst_int (Int.repr 22) tint) ::
                   (Evar _bhvStaticObject (tarray tuint 0)) ::
                   (Eunop Oneg (Econst_int (Int.repr 1328) tint) tint) ::
                   (Econst_int (Int.repr 60) tint) ::
                   (Econst_int (Int.repr 4664) tint) ::
                   (Econst_int (Int.repr 0) tint) ::
                   (Econst_int (Int.repr 180) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil)))
              (Sassign
                (Evar _sIntroWarpPipeObj (tptr (Tstruct _Object noattr)))
                (Etempvar _t'1 (tptr (Tstruct _Object noattr)))))
            (Scall None
              (Evar _advance_cutscene_step (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil)))
          Sskip))
      Sskip)))
|}.

Definition f_intro_cutscene_raise_pipe := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tushort) :: (_t'1, tfloat) :: (_t'7, tfloat) ::
               (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: (_t'3, tushort) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'6 (Evar _sIntroWarpPipeObj (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'7
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __729 noattr))
                _asF32 (tarray tfloat 80))
              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                (Econst_int (Int.repr 1) tint) tint) (tptr tfloat)) tfloat))
        (Scall (Some _t'1)
          (Evar _camera_approach_f32_symmetric (Tfunction
                                                 (tfloat :: tfloat ::
                                                  tfloat :: nil) tfloat
                                                 cc_default))
          ((Etempvar _t'7 tfloat) ::
           (Econst_single (Float32.of_bits (Int.repr 1132593152)) tfloat) ::
           (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat) ::
           nil))))
    (Ssequence
      (Sset _t'5 (Evar _sIntroWarpPipeObj (tptr (Tstruct _Object noattr))))
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __729 noattr))
              _asF32 (tarray tfloat 80))
            (Ebinop Oadd (Econst_int (Int.repr 6) tint)
              (Econst_int (Int.repr 1) tint) tint) (tptr tfloat)) tfloat)
        (Etempvar _t'1 tfloat))))
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionTimer tushort))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tushort)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Sset _t'4
            (Evar _sIntroWarpPipeObj (tptr (Tstruct _Object noattr))))
          (Scall None
            (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                                cc_default))
            ((Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 7) tint) tuint)
                       (Econst_int (Int.repr 28) tint) tuint)
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 23) tint) tuint)
                       (Econst_int (Int.repr 16) tint) tuint) tuint)
                   (Ebinop Oshl
                     (Ecast (Econst_int (Int.repr 160) tint) tuint)
                     (Econst_int (Int.repr 8) tint) tuint) tuint)
                 (Econst_int (Int.repr 128) tint) tuint)
               (Econst_int (Int.repr 1) tint) tuint) ::
             (Efield
               (Efield
                 (Efield
                   (Ederef (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                     (Tstruct _Object noattr)) _header
                   (Tstruct _ObjectNode noattr)) _gfx
                 (Tstruct _GraphNodeObject noattr)) _cameraToObject
               (tarray tfloat 3)) :: nil)))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort)
          (Ebinop Oadd (Etempvar _t'2 tushort) (Econst_int (Int.repr 1) tint)
            tint)))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tushort)
                     (Econst_int (Int.repr 38) tint) tint)
        (Ssequence
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
            (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat))
          (Scall None
            (Evar _advance_cutscene_step (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil)))
        Sskip))))
|}.

Definition f_intro_cutscene_jump_out_of_pipe := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tushort) :: (_t'1, tint) :: (_t'7, tushort) ::
               (_t'6, tshort) :: (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionTimer tushort))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'7 tushort)
                   (Econst_int (Int.repr 25) tint) tint)
      (Sassign
        (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr)) _flags
          tshort) (Econst_int (Int.repr 63) tint))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionTimer tushort))
      (Sassign
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionTimer tushort)
        (Ebinop Oadd (Etempvar _t'2 tushort) (Econst_int (Int.repr 1) tint)
          tint)))
    (Sifthenelse (Ebinop Oge (Etempvar _t'2 tushort)
                   (Econst_int (Int.repr 118) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'4
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioObj
              (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'5
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _marioObj
                (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'6
                (Efield
                  (Efield
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _header
                        (Tstruct _ObjectNode noattr)) _gfx
                      (Tstruct _GraphNodeObject noattr)) _node
                    (Tstruct _GraphNode noattr)) _flags tshort))
              (Sassign
                (Efield
                  (Efield
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _header
                        (Tstruct _ObjectNode noattr)) _gfx
                      (Tstruct _GraphNodeObject noattr)) _node
                    (Tstruct _GraphNode noattr)) _flags tshort)
                (Ebinop Oor (Etempvar _t'6 tshort)
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 0) tint) tint) tint)))))
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
                       (Ecast (Econst_int (Int.repr 4) tint) tuint)
                       (Econst_int (Int.repr 16) tint) tuint) tuint)
                   (Ebinop Oshl
                     (Ecast (Econst_int (Int.repr 128) tint) tuint)
                     (Econst_int (Int.repr 8) tint) tuint) tuint)
                 (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                   (Econst_int (Int.repr 128) tint) tint) tuint)
               (Econst_int (Int.repr 1) tint) tuint) ::
             (Econst_int (Int.repr 131072) tint) :: nil))
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
                         (Ecast (Econst_int (Int.repr 0) tint) tuint)
                         (Econst_int (Int.repr 28) tint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 68) tint) tuint)
                         (Econst_int (Int.repr 16) tint) tuint) tuint)
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 160) tint) tuint)
                       (Econst_int (Int.repr 8) tint) tuint) tuint)
                   (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                     (Econst_int (Int.repr 128) tint) tint) tuint)
                 (Econst_int (Int.repr 1) tint) tuint) ::
               (Econst_int (Int.repr 65536) tint) :: nil))
            (Ssequence
              (Scall None
                (Evar _set_mario_animation (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tint :: nil) tshort cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 77) tint) :: nil))
              (Ssequence
                (Scall None
                  (Evar _mario_set_forward_vel (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tfloat :: nil) tvoid
                                                 cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat) ::
                   nil))
                (Ssequence
                  (Scall (Some _t'1)
                    (Evar _perform_air_step (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tint)
                                 (Econst_int (Int.repr 1) tint) tint)
                    (Ssequence
                      (Scall None
                        (Evar _sound_banks_enable (Tfunction
                                                    (tuchar :: tushort ::
                                                     nil) tvoid cc_default))
                        ((Econst_int (Int.repr 2) tint) ::
                         (Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oor
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 4) tint) tint)
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 5) tint) tint) tint)
                             (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                               (Econst_int (Int.repr 8) tint) tint) tint)
                           (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                             (Econst_int (Int.repr 9) tint) tint) tint) ::
                         nil))
                      (Ssequence
                        (Scall None
                          (Evar _play_mario_landing_sound (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             tuint :: nil)
                                                            tvoid cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Ebinop Oor
                             (Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oor
                                   (Ebinop Oshl
                                     (Ecast (Econst_int (Int.repr 0) tint)
                                       tuint) (Econst_int (Int.repr 28) tint)
                                     tuint)
                                   (Ebinop Oshl
                                     (Ecast (Econst_int (Int.repr 8) tint)
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
                           nil))
                        (Ssequence
                          (Ssequence
                            (Sset _t'3
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _marioObj
                                (tptr (Tstruct _Object noattr))))
                            (Scall None
                              (Evar _play_sound (Tfunction
                                                  (tint :: (tptr tfloat) ::
                                                   nil) tvoid cc_default))
                              ((Ebinop Oor
                                 (Ebinop Oor
                                   (Ebinop Oor
                                     (Ebinop Oor
                                       (Ebinop Oshl
                                         (Ecast
                                           (Econst_int (Int.repr 2) tint)
                                           tuint)
                                         (Econst_int (Int.repr 28) tint)
                                         tuint)
                                       (Ebinop Oshl
                                         (Ecast
                                           (Econst_int (Int.repr 17) tint)
                                           tuint)
                                         (Econst_int (Int.repr 16) tint)
                                         tuint) tuint)
                                     (Ebinop Oshl
                                       (Ecast
                                         (Econst_int (Int.repr 128) tint)
                                         tuint)
                                       (Econst_int (Int.repr 8) tint) tuint)
                                     tuint)
                                   (Ebinop Oor
                                     (Econst_int (Int.repr 67108864) tint)
                                     (Econst_int (Int.repr 128) tint) tint)
                                   tuint) (Econst_int (Int.repr 1) tint)
                                 tuint) ::
                               (Efield
                                 (Efield
                                   (Efield
                                     (Ederef
                                       (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                                       (Tstruct _Object noattr)) _header
                                     (Tstruct _ObjectNode noattr)) _gfx
                                   (Tstruct _GraphNodeObject noattr))
                                 _cameraToObject (tarray tfloat 3)) :: nil)))
                          (Scall None
                            (Evar _advance_cutscene_step (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            nil) tvoid
                                                           cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             nil)))))
                    Sskip)))))))
      Sskip)))
|}.

Definition f_intro_cutscene_land_outside_pipe := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _set_mario_animation (Tfunction
                                 ((tptr (Tstruct _MarioState noattr)) ::
                                  tint :: nil) tshort cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Econst_int (Int.repr 78) tint) :: nil))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _is_anim_at_end (Tfunction
                                ((tptr (Tstruct _MarioState noattr)) :: nil)
                                tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Sifthenelse (Etempvar _t'1 tint)
        (Scall None
          (Evar _advance_cutscene_step (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        Sskip))
    (Scall None
      (Evar _stop_and_set_height_to_floor (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))))
|}.

Definition f_intro_cutscene_lower_pipe := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tushort) :: (_t'8, (tptr (Tstruct _Object noattr))) ::
               (_t'7, tfloat) :: (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: (_t'3, tfloat) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'1
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionTimer tushort))
      (Sassign
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionTimer tushort)
        (Ebinop Oadd (Etempvar _t'1 tushort) (Econst_int (Int.repr 1) tint)
          tint)))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tushort)
                   (Econst_int (Int.repr 0) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'8
            (Evar _sIntroWarpPipeObj (tptr (Tstruct _Object noattr))))
          (Scall None
            (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                                cc_default))
            ((Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 7) tint) tuint)
                       (Econst_int (Int.repr 28) tint) tuint)
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 22) tint) tuint)
                       (Econst_int (Int.repr 16) tint) tuint) tuint)
                   (Ebinop Oshl
                     (Ecast (Econst_int (Int.repr 160) tint) tuint)
                     (Econst_int (Int.repr 8) tint) tuint) tuint)
                 (Econst_int (Int.repr 128) tint) tuint)
               (Econst_int (Int.repr 1) tint) tuint) ::
             (Efield
               (Efield
                 (Efield
                   (Ederef (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                     (Tstruct _Object noattr)) _header
                   (Tstruct _ObjectNode noattr)) _gfx
                 (Tstruct _GraphNodeObject noattr)) _cameraToObject
               (tarray tfloat 3)) :: nil)))
        (Scall None
          (Evar _set_mario_animation (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tint :: nil) tshort cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 194) tint) :: nil)))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'5 (Evar _sIntroWarpPipeObj (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'6 (Evar _sIntroWarpPipeObj (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'7
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __729 noattr)) _asF32 (tarray tfloat 80))
                (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                  (Econst_int (Int.repr 1) tint) tint) (tptr tfloat)) tfloat))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __729 noattr)) _asF32 (tarray tfloat 80))
                (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                  (Econst_int (Int.repr 1) tint) tint) (tptr tfloat)) tfloat)
            (Ebinop Osub (Etempvar _t'7 tfloat)
              (Econst_single (Float32.of_bits (Int.repr 1084227584)) tfloat)
              tfloat)))))
    (Ssequence
      (Ssequence
        (Sset _t'2 (Evar _sIntroWarpPipeObj (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'3
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __729 noattr)) _asF32 (tarray tfloat 80))
                (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                  (Econst_int (Int.repr 1) tint) tint) (tptr tfloat)) tfloat))
          (Sifthenelse (Ebinop Ole (Etempvar _t'3 tfloat)
                         (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat)
                         tint)
            (Ssequence
              (Ssequence
                (Sset _t'4
                  (Evar _sIntroWarpPipeObj (tptr (Tstruct _Object noattr))))
                (Scall None
                  (Evar _obj_mark_for_deletion (Tfunction
                                                 ((tptr (Tstruct _Object noattr)) ::
                                                  nil) tvoid cc_default))
                  ((Etempvar _t'4 (tptr (Tstruct _Object noattr))) :: nil)))
              (Scall None
                (Evar _advance_cutscene_step (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tvoid cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil)))
            Sskip)))
      (Scall None
        (Evar _stop_and_set_height_to_floor (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil)))))
|}.

Definition f_intro_cutscene_set_mario_to_idle := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tshort) :: (_t'2, tuchar) ::
               (_t'1, (tptr (Tstruct _Camera noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1 (Evar _gCamera (tptr (Tstruct _Camera noattr))))
    (Ssequence
      (Sset _t'2
        (Efield
          (Ederef (Etempvar _t'1 (tptr (Tstruct _Camera noattr)))
            (Tstruct _Camera noattr)) _cutscene tuchar))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tuchar)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'3 (Evar _gCameraMovementFlags tshort))
            (Sassign (Evar _gCameraMovementFlags tshort)
              (Ebinop Oand (Etempvar _t'3 tshort)
                (Eunop Onotint (Econst_int (Int.repr 8192) tint) tint) tint)))
          (Scall None
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 205521409) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil)))
        Sskip)))
  (Scall None
    (Evar _stop_and_set_height_to_floor (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil)))
|}.

Definition f_act_intro_cutscene := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionArg tuint))
    (Sswitch (Etempvar _t'1 tuint)
      (LScons (Some 0)
        (Ssequence
          (Scall None
            (Evar _intro_cutscene_hide_hud_and_mario (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        nil) tvoid
                                                       cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          Sbreak)
        (LScons (Some 1)
          (Ssequence
            (Scall None
              (Evar _intro_cutscene_peach_lakitu_scene (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          nil) tvoid
                                                         cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            Sbreak)
          (LScons (Some 2)
            (Ssequence
              (Scall None
                (Evar _intro_cutscene_raise_pipe (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    nil) tvoid cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              Sbreak)
            (LScons (Some 3)
              (Ssequence
                (Scall None
                  (Evar _intro_cutscene_jump_out_of_pipe (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            nil) tvoid
                                                           cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                Sbreak)
              (LScons (Some 4)
                (Ssequence
                  (Scall None
                    (Evar _intro_cutscene_land_outside_pipe (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               nil) tvoid
                                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  Sbreak)
                (LScons (Some 5)
                  (Ssequence
                    (Scall None
                      (Evar _intro_cutscene_lower_pipe (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          nil) tvoid
                                                         cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    Sbreak)
                  (LScons (Some 6)
                    (Ssequence
                      (Scall None
                        (Evar _intro_cutscene_set_mario_to_idle (Tfunction
                                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                                   nil) tvoid
                                                                  cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      Sbreak)
                    LSnil)))))))))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_jumbo_star_cutscene_falling := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) :: (_t'7, tushort) ::
               (_t'6, tuint) :: (_t'5, tushort) ::
               (_t'4, (tptr (Tstruct _PlayerCameraState noattr))) ::
               (_t'3, tushort) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'3
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _actionState tushort))
  (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tushort)
                 (Econst_int (Int.repr 0) tint) tint)
    (Ssequence
      (Ssequence
        (Sset _t'7
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort)
          (Ebinop Oor (Etempvar _t'7 tushort)
            (Econst_int (Int.repr 128) tint) tint)))
      (Ssequence
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _flags tuint))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _flags tuint)
            (Ebinop Oor (Etempvar _t'6 tuint)
              (Ebinop Oor (Econst_int (Int.repr 8) tint)
                (Econst_int (Int.repr 16) tint) tint) tuint)))
        (Ssequence
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _faceAngle
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort)
            (Eunop Oneg (Econst_int (Int.repr 32768) tint) tint))
          (Ssequence
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
              (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
            (Ssequence
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                    (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat)
                (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
              (Ssequence
                (Scall None
                  (Evar _mario_set_forward_vel (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tfloat :: nil) tvoid
                                                 cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                   nil))
                (Ssequence
                  (Scall None
                    (Evar _set_mario_animation (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tint :: nil) tshort
                                                 cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 86) tint) :: nil))
                  (Ssequence
                    (Scall (Some _t'1)
                      (Evar _perform_air_step (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: nil) tint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 1) tint) :: nil))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tint)
                                   (Econst_int (Int.repr 1) tint) tint)
                      (Ssequence
                        (Scall None
                          (Evar _play_cutscene_music (Tfunction
                                                       (tushort :: nil) tvoid
                                                       cc_default))
                          ((Ebinop Oor
                             (Ebinop Oshl (Econst_int (Int.repr 15) tint)
                               (Econst_int (Int.repr 8) tint) tint)
                             (Econst_int (Int.repr 31) tint) tint) :: nil))
                        (Ssequence
                          (Scall None
                            (Evar _play_mario_landing_sound (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               tuint :: nil)
                                                              tvoid
                                                              cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oor
                                   (Ebinop Oor
                                     (Ebinop Oshl
                                       (Ecast (Econst_int (Int.repr 0) tint)
                                         tuint)
                                       (Econst_int (Int.repr 28) tint) tuint)
                                     (Ebinop Oshl
                                       (Ecast (Econst_int (Int.repr 8) tint)
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
                             nil))
                          (Ssequence
                            (Sset _t'5
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _actionState
                                tushort))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _actionState
                                tushort)
                              (Ebinop Oadd (Etempvar _t'5 tushort)
                                (Econst_int (Int.repr 1) tint) tint)))))
                      Sskip)))))))))
    (Ssequence
      (Scall None
        (Evar _set_mario_animation (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tint :: nil) tshort cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 87) tint) :: nil))
      (Ssequence
        (Scall (Some _t'2)
          (Evar _is_anim_at_end (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Sifthenelse (Etempvar _t'2 tint)
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _statusForCamera
                  (tptr (Tstruct _PlayerCameraState noattr))))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _t'4 (tptr (Tstruct _PlayerCameraState noattr)))
                    (Tstruct _PlayerCameraState noattr)) _cameraEvent tshort)
                (Econst_int (Int.repr 10) tint)))
            (Scall None
              (Evar _advance_cutscene_step (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil)))
          Sskip)))))
|}.

Definition f_jumbo_star_cutscene_taking_off := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_animFrame, tint) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tshort) :: (_t'1, tint) ::
               (_t'15, tushort) :: (_t'14, tfloat) ::
               (_t'13, (tptr (Tstruct _Object noattr))) :: (_t'12, tuint) ::
               (_t'11, (tptr (Tstruct _Object noattr))) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tuint) ::
               (_t'8, tushort) :: (_t'7, tfloat) :: (_t'6, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _marioObj
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'8
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionState tushort))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'8 tushort)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Scall None
            (Evar _set_mario_animation (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 37) tint) :: nil))
          (Ssequence
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __729 noattr)) _asF32 (tarray tfloat 80))
                  (Econst_int (Int.repr 34) tint) (tptr tfloat)) tfloat)
              (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
            (Ssequence
              (Scall (Some _t'1)
                (Evar _is_anim_past_end (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sifthenelse (Etempvar _t'1 tint)
                (Ssequence
                  (Scall None
                    (Evar _play_mario_landing_sound (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: nil) tvoid
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
                               (Ecast (Econst_int (Int.repr 8) tint) tuint)
                               (Econst_int (Int.repr 16) tint) tuint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 128) tint) tuint)
                             (Econst_int (Int.repr 8) tint) tuint) tuint)
                         (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                           (Econst_int (Int.repr 128) tint) tint) tuint)
                       (Econst_int (Int.repr 1) tint) tuint) :: nil))
                  (Ssequence
                    (Sset _t'15
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionState tushort))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionState tushort)
                      (Ebinop Oadd (Etempvar _t'15 tushort)
                        (Econst_int (Int.repr 1) tint) tint))))
                Sskip))))
        (Ssequence
          (Ssequence
            (Scall (Some _t'2)
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 38) tint) :: nil))
            (Sset _animFrame (Etempvar _t'2 tshort)))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                               (Econst_int (Int.repr 3) tint) tint)
                  (Sset _t'3 (Econst_int (Int.repr 1) tint))
                  (Sset _t'3
                    (Ecast
                      (Ebinop Oeq (Etempvar _animFrame tint)
                        (Econst_int (Int.repr 28) tint) tint) tbool)))
                (Sifthenelse (Etempvar _t'3 tint)
                  (Sset _t'4 (Econst_int (Int.repr 1) tint))
                  (Sset _t'4
                    (Ecast
                      (Ebinop Oeq (Etempvar _animFrame tint)
                        (Econst_int (Int.repr 60) tint) tint) tbool))))
              (Sifthenelse (Etempvar _t'4 tint)
                (Scall None
                  (Evar _play_sound_and_spawn_particles (Tfunction
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
                             (Ecast (Econst_int (Int.repr 0) tint) tuint)
                             (Econst_int (Int.repr 28) tint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 0) tint) tuint)
                             (Econst_int (Int.repr 16) tint) tuint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 128) tint) tuint)
                           (Econst_int (Int.repr 8) tint) tuint) tuint)
                       (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                         (Econst_int (Int.repr 128) tint) tint) tuint)
                     (Econst_int (Int.repr 1) tint) tuint) ::
                   (Econst_int (Int.repr 1) tint) :: nil))
                Sskip))
            (Ssequence
              (Sifthenelse (Ebinop Oge (Etempvar _animFrame tint)
                             (Econst_int (Int.repr 3) tint) tint)
                (Ssequence
                  (Sset _t'14
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __729 noattr)) _asF32 (tarray tfloat 80))
                        (Econst_int (Int.repr 34) tint) (tptr tfloat))
                      tfloat))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __729 noattr)) _asF32 (tarray tfloat 80))
                        (Econst_int (Int.repr 34) tint) (tptr tfloat))
                      tfloat)
                    (Ebinop Osub (Etempvar _t'14 tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                      tfloat)))
                Sskip)
              (Ssequence
                (Sswitch (Etempvar _animFrame tint)
                  (LScons (Some 3)
                    (Ssequence
                      (Ssequence
                        (Sset _t'12 (Evar _gAudioRandom tuint))
                        (Ssequence
                          (Sset _t'13
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _marioObj
                              (tptr (Tstruct _Object noattr))))
                          (Scall None
                            (Evar _play_sound (Tfunction
                                                (tint :: (tptr tfloat) ::
                                                 nil) tvoid cc_default))
                            ((Ebinop Oadd
                               (Ebinop Oor
                                 (Ebinop Oor
                                   (Ebinop Oor
                                     (Ebinop Oor
                                       (Ebinop Oshl
                                         (Ecast
                                           (Econst_int (Int.repr 2) tint)
                                           tuint)
                                         (Econst_int (Int.repr 28) tint)
                                         tuint)
                                       (Ebinop Oshl
                                         (Ecast
                                           (Econst_int (Int.repr 0) tint)
                                           tuint)
                                         (Econst_int (Int.repr 16) tint)
                                         tuint) tuint)
                                     (Ebinop Oshl
                                       (Ecast
                                         (Econst_int (Int.repr 128) tint)
                                         tuint)
                                       (Econst_int (Int.repr 8) tint) tuint)
                                     tuint)
                                   (Ebinop Oor
                                     (Econst_int (Int.repr 67108864) tint)
                                     (Econst_int (Int.repr 128) tint) tint)
                                   tuint) (Econst_int (Int.repr 1) tint)
                                 tuint)
                               (Ebinop Oshl
                                 (Ebinop Omod (Etempvar _t'12 tuint)
                                   (Econst_int (Int.repr 3) tint) tuint)
                                 (Econst_int (Int.repr 16) tint) tuint)
                               tuint) ::
                             (Efield
                               (Efield
                                 (Efield
                                   (Ederef
                                     (Etempvar _t'13 (tptr (Tstruct _Object noattr)))
                                     (Tstruct _Object noattr)) _header
                                   (Tstruct _ObjectNode noattr)) _gfx
                                 (Tstruct _GraphNodeObject noattr))
                               _cameraToObject (tarray tfloat 3)) :: nil))))
                      Sbreak)
                    (LScons (Some 28)
                      (Ssequence
                        (Ssequence
                          (Sset _t'11
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _marioObj
                              (tptr (Tstruct _Object noattr))))
                          (Scall None
                            (Evar _play_sound (Tfunction
                                                (tint :: (tptr tfloat) ::
                                                 nil) tvoid cc_default))
                            ((Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oor
                                   (Ebinop Oor
                                     (Ebinop Oshl
                                       (Ecast (Econst_int (Int.repr 2) tint)
                                         tuint)
                                       (Econst_int (Int.repr 28) tint) tuint)
                                     (Ebinop Oshl
                                       (Ecast (Econst_int (Int.repr 3) tint)
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
                             (Efield
                               (Efield
                                 (Efield
                                   (Ederef
                                     (Etempvar _t'11 (tptr (Tstruct _Object noattr)))
                                     (Tstruct _Object noattr)) _header
                                   (Tstruct _ObjectNode noattr)) _gfx
                                 (Tstruct _GraphNodeObject noattr))
                               _cameraToObject (tarray tfloat 3)) :: nil)))
                        Sbreak)
                      (LScons (Some 60)
                        (Ssequence
                          (Ssequence
                            (Sset _t'10
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _marioObj
                                (tptr (Tstruct _Object noattr))))
                            (Scall None
                              (Evar _play_sound (Tfunction
                                                  (tint :: (tptr tfloat) ::
                                                   nil) tvoid cc_default))
                              ((Ebinop Oor
                                 (Ebinop Oor
                                   (Ebinop Oor
                                     (Ebinop Oor
                                       (Ebinop Oshl
                                         (Ecast
                                           (Econst_int (Int.repr 2) tint)
                                           tuint)
                                         (Econst_int (Int.repr 28) tint)
                                         tuint)
                                       (Ebinop Oshl
                                         (Ecast
                                           (Econst_int (Int.repr 4) tint)
                                           tuint)
                                         (Econst_int (Int.repr 16) tint)
                                         tuint) tuint)
                                     (Ebinop Oshl
                                       (Ecast
                                         (Econst_int (Int.repr 128) tint)
                                         tuint)
                                       (Econst_int (Int.repr 8) tint) tuint)
                                     tuint)
                                   (Ebinop Oor
                                     (Econst_int (Int.repr 67108864) tint)
                                     (Econst_int (Int.repr 128) tint) tint)
                                   tuint) (Econst_int (Int.repr 1) tint)
                                 tuint) ::
                               (Efield
                                 (Efield
                                   (Efield
                                     (Ederef
                                       (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                                       (Tstruct _Object noattr)) _header
                                     (Tstruct _ObjectNode noattr)) _gfx
                                   (Tstruct _GraphNodeObject noattr))
                                 _cameraToObject (tarray tfloat 3)) :: nil)))
                          Sbreak)
                        LSnil))))
                (Ssequence
                  (Ssequence
                    (Sset _t'9
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _particleFlags tuint))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _particleFlags tuint)
                      (Ebinop Oor (Etempvar _t'9 tuint)
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 3) tint) tint) tuint)))
                  (Ssequence
                    (Scall (Some _t'5)
                      (Evar _is_anim_past_end (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Sifthenelse (Etempvar _t'5 tint)
                      (Scall None
                        (Evar _advance_cutscene_step (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        nil) tvoid
                                                       cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      Sskip)))))))))
    (Ssequence
      (Ssequence
        (Sset _t'7
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __729 noattr))
                _asF32 (tarray tfloat 80)) (Econst_int (Int.repr 34) tint)
              (tptr tfloat)) tfloat))
        (Scall None
          (Evar _vec3f_set (Tfunction
                             ((tptr tfloat) :: tfloat :: tfloat :: tfloat ::
                              nil) (tptr tvoid) cc_default))
          ((Efield
             (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
               (Tstruct _MarioState noattr)) _pos (tarray tfloat 3)) ::
           (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
           (Econst_float (Float.of_bits (Int64.repr 4644108417307246592)) tdouble) ::
           (Etempvar _t'7 tfloat) :: nil)))
      (Ssequence
        (Scall None
          (Evar _update_mario_pos_for_anim (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Ssequence
          (Scall None
            (Evar _vec3f_copy (Tfunction
                                ((tptr tfloat) :: (tptr tfloat) :: nil)
                                (tptr tvoid) cc_default))
            ((Efield
               (Efield
                 (Efield
                   (Ederef
                     (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                     (Tstruct _Object noattr)) _header
                   (Tstruct _ObjectNode noattr)) _gfx
                 (Tstruct _GraphNodeObject noattr)) _pos (tarray tfloat 3)) ::
             (Efield
               (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                 (Tstruct _MarioState noattr)) _pos (tarray tfloat 3)) ::
             nil))
          (Ssequence
            (Ssequence
              (Sset _t'6
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _faceAngle
                      (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                    (tptr tshort)) tshort))
              (Scall None
                (Evar _vec3s_set (Tfunction
                                   ((tptr tshort) :: tshort :: tshort ::
                                    tshort :: nil) (tptr tvoid) cc_default))
                ((Efield
                   (Efield
                     (Efield
                       (Ederef
                         (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                         (Tstruct _Object noattr)) _header
                       (Tstruct _ObjectNode noattr)) _gfx
                     (Tstruct _GraphNodeObject noattr)) _angle
                   (tarray tshort 3)) :: (Econst_int (Int.repr 0) tint) ::
                 (Etempvar _t'6 tshort) :: (Econst_int (Int.repr 0) tint) ::
                 nil)))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_jumbo_star_cutscene_flying := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := ((_targetPos, (tarray tfloat 3)) :: nil);
  fn_temps := ((_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_targetDX, tfloat) :: (_targetDY, tfloat) ::
               (_targetDZ, tfloat) :: (_targetHyp, tfloat) ::
               (_targetAngle, tshort) :: (_t'5, tushort) :: (_t'4, tint) ::
               (_t'3, tshort) :: (_t'2, tshort) :: (_t'1, tfloat) ::
               (_t'21, tushort) :: (_t'20, tushort) :: (_t'19, tfloat) ::
               (_t'18, tfloat) :: (_t'17, tfloat) :: (_t'16, tfloat) ::
               (_t'15, tfloat) :: (_t'14, tfloat) ::
               (_t'13, (tptr (Tstruct _Object noattr))) ::
               (_t'12, (tptr (Tstruct _Object noattr))) :: (_t'11, tshort) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tushort) ::
               (_t'8, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tuint) ::
               nil);
  fn_body :=
(Ssequence
  (Sset _marioObj
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'9
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionState tushort))
      (Sswitch (Etempvar _t'9 tushort)
        (LScons (Some 0)
          (Ssequence
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 42) tint) :: nil))
            (Ssequence
              (Scall None
                (Evar _anim_spline_init (Tfunction
                                          ((tptr (tarray tshort 4)) :: nil)
                                          tvoid cc_default))
                ((Evar _sJumboStarKeyframes (tarray (tarray tshort 4) 27)) ::
                 nil))
              (Ssequence
                (Sset _t'21
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionState tushort))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionState tushort)
                  (Ebinop Oadd (Etempvar _t'21 tushort)
                    (Econst_int (Int.repr 1) tint) tint)))))
          (LScons (Some 1)
            (Ssequence
              (Ssequence
                (Scall (Some _t'4)
                  (Evar _anim_spline_poll (Tfunction ((tptr tfloat) :: nil)
                                            tint cc_default))
                  ((Evar _targetPos (tarray tfloat 3)) :: nil))
                (Sifthenelse (Etempvar _t'4 tint)
                  (Ssequence
                    (Scall None
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 16779404) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    (Ssequence
                      (Sset _t'20
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionState
                          tushort))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionState
                          tushort)
                        (Ebinop Oadd (Etempvar _t'20 tushort)
                          (Econst_int (Int.repr 1) tint) tint))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'18
                        (Ederef
                          (Ebinop Oadd (Evar _targetPos (tarray tfloat 3))
                            (Econst_int (Int.repr 0) tint) (tptr tfloat))
                          tfloat))
                      (Ssequence
                        (Sset _t'19
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _pos
                                (tarray tfloat 3))
                              (Econst_int (Int.repr 0) tint) (tptr tfloat))
                            tfloat))
                        (Sset _targetDX
                          (Ebinop Osub (Etempvar _t'18 tfloat)
                            (Etempvar _t'19 tfloat) tfloat))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'16
                          (Ederef
                            (Ebinop Oadd (Evar _targetPos (tarray tfloat 3))
                              (Econst_int (Int.repr 1) tint) (tptr tfloat))
                            tfloat))
                        (Ssequence
                          (Sset _t'17
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _pos
                                  (tarray tfloat 3))
                                (Econst_int (Int.repr 1) tint) (tptr tfloat))
                              tfloat))
                          (Sset _targetDY
                            (Ebinop Osub (Etempvar _t'16 tfloat)
                              (Etempvar _t'17 tfloat) tfloat))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'14
                            (Ederef
                              (Ebinop Oadd
                                (Evar _targetPos (tarray tfloat 3))
                                (Econst_int (Int.repr 2) tint) (tptr tfloat))
                              tfloat))
                          (Ssequence
                            (Sset _t'15
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _pos
                                    (tarray tfloat 3))
                                  (Econst_int (Int.repr 2) tint)
                                  (tptr tfloat)) tfloat))
                            (Sset _targetDZ
                              (Ebinop Osub (Etempvar _t'14 tfloat)
                                (Etempvar _t'15 tfloat) tfloat))))
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'1)
                              (Evar _sqrtf (Tfunction (tfloat :: nil) tfloat
                                             cc_default))
                              ((Ebinop Oadd
                                 (Ebinop Omul (Etempvar _targetDX tfloat)
                                   (Etempvar _targetDX tfloat) tfloat)
                                 (Ebinop Omul (Etempvar _targetDZ tfloat)
                                   (Etempvar _targetDZ tfloat) tfloat)
                                 tfloat) :: nil))
                            (Sset _targetHyp (Etempvar _t'1 tfloat)))
                          (Ssequence
                            (Ssequence
                              (Scall (Some _t'2)
                                (Evar _atan2s (Tfunction
                                                (tfloat :: tfloat :: nil)
                                                tshort cc_default))
                                ((Etempvar _targetDZ tfloat) ::
                                 (Etempvar _targetDX tfloat) :: nil))
                              (Sset _targetAngle
                                (Ecast (Etempvar _t'2 tshort) tshort)))
                            (Ssequence
                              (Scall None
                                (Evar _vec3f_copy (Tfunction
                                                    ((tptr tfloat) ::
                                                     (tptr tfloat) :: nil)
                                                    (tptr tvoid) cc_default))
                                ((Efield
                                   (Ederef
                                     (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                     (Tstruct _MarioState noattr)) _pos
                                   (tarray tfloat 3)) ::
                                 (Evar _targetPos (tarray tfloat 3)) :: nil))
                              (Ssequence
                                (Ssequence
                                  (Scall (Some _t'3)
                                    (Evar _atan2s (Tfunction
                                                    (tfloat :: tfloat :: nil)
                                                    tshort cc_default))
                                    ((Etempvar _targetHyp tfloat) ::
                                     (Etempvar _targetDY tfloat) :: nil))
                                  (Ssequence
                                    (Sset _t'13
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _marioObj
                                        (tptr (Tstruct _Object noattr))))
                                    (Sassign
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Efield
                                              (Efield
                                                (Ederef
                                                  (Etempvar _t'13 (tptr (Tstruct _Object noattr)))
                                                  (Tstruct _Object noattr))
                                                _header
                                                (Tstruct _ObjectNode noattr))
                                              _gfx
                                              (Tstruct _GraphNodeObject noattr))
                                            _angle (tarray tshort 3))
                                          (Econst_int (Int.repr 0) tint)
                                          (tptr tshort)) tshort)
                                      (Eunop Oneg (Etempvar _t'3 tshort)
                                        tint))))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'12
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _marioObj
                                        (tptr (Tstruct _Object noattr))))
                                    (Sassign
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Efield
                                              (Efield
                                                (Ederef
                                                  (Etempvar _t'12 (tptr (Tstruct _Object noattr)))
                                                  (Tstruct _Object noattr))
                                                _header
                                                (Tstruct _ObjectNode noattr))
                                              _gfx
                                              (Tstruct _GraphNodeObject noattr))
                                            _angle (tarray tshort 3))
                                          (Econst_int (Int.repr 1) tint)
                                          (tptr tshort)) tshort)
                                      (Etempvar _targetAngle tshort)))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'10
                                        (Efield
                                          (Ederef
                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _marioObj
                                          (tptr (Tstruct _Object noattr))))
                                      (Ssequence
                                        (Sset _t'11
                                          (Ederef
                                            (Ebinop Oadd
                                              (Efield
                                                (Ederef
                                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                  (Tstruct _MarioState noattr))
                                                _faceAngle (tarray tshort 3))
                                              (Econst_int (Int.repr 1) tint)
                                              (tptr tshort)) tshort))
                                        (Sassign
                                          (Ederef
                                            (Ebinop Oadd
                                              (Efield
                                                (Efield
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                                                      (Tstruct _Object noattr))
                                                    _header
                                                    (Tstruct _ObjectNode noattr))
                                                  _gfx
                                                  (Tstruct _GraphNodeObject noattr))
                                                _angle (tarray tshort 3))
                                              (Econst_int (Int.repr 2) tint)
                                              (tptr tshort)) tshort)
                                          (Ebinop Omul
                                            (Ebinop Oshr
                                              (Ebinop Oshl
                                                (Ebinop Osub
                                                  (Etempvar _t'11 tshort)
                                                  (Etempvar _targetAngle tshort)
                                                  tint)
                                                (Econst_int (Int.repr 16) tint)
                                                tint)
                                              (Econst_int (Int.repr 16) tint)
                                              tint)
                                            (Econst_int (Int.repr 20) tint)
                                            tint))))
                                    (Sassign
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _faceAngle (tarray tshort 3))
                                          (Econst_int (Int.repr 1) tint)
                                          (tptr tshort)) tshort)
                                      (Etempvar _targetAngle tshort)))))))))))))
              Sbreak)
            (LScons (Some 2)
              (Ssequence
                (Scall None
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 16779404) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                Sbreak)
              LSnil)))))
    (Ssequence
      (Ssequence
        (Sset _t'8
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _marioBodyState
            (tptr (Tstruct _MarioBodyState noattr))))
        (Sassign
          (Efield
            (Ederef (Etempvar _t'8 (tptr (Tstruct _MarioBodyState noattr)))
              (Tstruct _MarioBodyState noattr)) _handState tschar)
          (Econst_int (Int.repr 5) tint)))
      (Ssequence
        (Ssequence
          (Sset _t'7
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioObj
              (tptr (Tstruct _Object noattr))))
          (Scall None
            (Evar _vec3f_copy (Tfunction
                                ((tptr tfloat) :: (tptr tfloat) :: nil)
                                (tptr tvoid) cc_default))
            ((Efield
               (Efield
                 (Efield
                   (Ederef (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                     (Tstruct _Object noattr)) _header
                   (Tstruct _ObjectNode noattr)) _gfx
                 (Tstruct _GraphNodeObject noattr)) _pos (tarray tfloat 3)) ::
             (Efield
               (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                 (Tstruct _MarioState noattr)) _pos (tarray tfloat 3)) ::
             nil)))
        (Ssequence
          (Ssequence
            (Sset _t'6
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _particleFlags tuint))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _particleFlags tuint)
              (Ebinop Oor (Etempvar _t'6 tuint)
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 3) tint) tint) tuint)))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionTimer tushort))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionTimer tushort)
                  (Ebinop Oadd (Etempvar _t'5 tushort)
                    (Econst_int (Int.repr 1) tint) tint)))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tushort)
                             (Econst_int (Int.repr 500) tint) tint)
                (Scall None
                  (Evar _level_trigger_warp (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tint :: nil) tshort
                                              cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 23) tint) :: nil))
                Sskip))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_jumbo_star_cutscene := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionArg tuint))
    (Sswitch (Etempvar _t'1 tuint)
      (LScons (Some 0)
        (Ssequence
          (Scall None
            (Evar _jumbo_star_cutscene_falling (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          Sbreak)
        (LScons (Some 1)
          (Ssequence
            (Scall None
              (Evar _jumbo_star_cutscene_taking_off (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            Sbreak)
          (LScons (Some 2)
            (Ssequence
              (Scall None
                (Evar _jumbo_star_cutscene_flying (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              Sbreak)
            LSnil)))))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition v_sSparkleGenTheta := {|
  gvar_info := tint;
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSparkleGenPhi := {|
  gvar_info := tint;
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_generate_yellow_sparkles := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_x, tshort) :: (_y, tshort) :: (_z, tshort) ::
                (_radius, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_offsetX, tshort) :: (_offsetY, tshort) ::
               (_offsetZ, tshort) :: (_t'14, tfloat) :: (_t'13, tint) ::
               (_t'12, tfloat) :: (_t'11, tint) :: (_t'10, tfloat) ::
               (_t'9, tint) :: (_t'8, tfloat) :: (_t'7, tint) ::
               (_t'6, tfloat) :: (_t'5, tint) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: (_t'2, tint) ::
               (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'11 (Evar _sSparkleGenTheta tint))
    (Ssequence
      (Sset _t'12
        (Ederef
          (Ebinop Oadd
            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
              (Econst_int (Int.repr 1024) tint) (tptr tfloat))
            (Ebinop Oshr (Ecast (Etempvar _t'11 tint) tushort)
              (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
      (Ssequence
        (Sset _t'13 (Evar _sSparkleGenPhi tint))
        (Ssequence
          (Sset _t'14
            (Ederef
              (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                (Ebinop Oshr (Ecast (Etempvar _t'13 tint) tushort)
                  (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
          (Sset _offsetX
            (Ecast
              (Ebinop Omul
                (Ebinop Omul (Etempvar _radius tfloat)
                  (Etempvar _t'12 tfloat) tfloat) (Etempvar _t'14 tfloat)
                tfloat) tshort))))))
  (Ssequence
    (Ssequence
      (Sset _t'9 (Evar _sSparkleGenTheta tint))
      (Ssequence
        (Sset _t'10
          (Ederef
            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
              (Ebinop Oshr (Ecast (Etempvar _t'9 tint) tushort)
                (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
        (Sset _offsetY
          (Ecast
            (Ebinop Omul (Etempvar _radius tfloat) (Etempvar _t'10 tfloat)
              tfloat) tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'5 (Evar _sSparkleGenTheta tint))
        (Ssequence
          (Sset _t'6
            (Ederef
              (Ebinop Oadd
                (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                  (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                (Ebinop Oshr (Ecast (Etempvar _t'5 tint) tushort)
                  (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
          (Ssequence
            (Sset _t'7 (Evar _sSparkleGenPhi tint))
            (Ssequence
              (Sset _t'8
                (Ederef
                  (Ebinop Oadd
                    (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                      (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                    (Ebinop Oshr (Ecast (Etempvar _t'7 tint) tushort)
                      (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                  tfloat))
              (Sset _offsetZ
                (Ecast
                  (Ebinop Omul
                    (Ebinop Omul (Etempvar _radius tfloat)
                      (Etempvar _t'6 tfloat) tfloat) (Etempvar _t'8 tfloat)
                    tfloat) tshort))))))
      (Ssequence
        (Ssequence
          (Sset _t'4 (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
          (Scall None
            (Evar _spawn_object_abs_with_rot (Tfunction
                                               ((tptr (Tstruct _Object noattr)) ::
                                                tshort :: tuint ::
                                                (tptr tuint) :: tshort ::
                                                tshort :: tshort :: tshort ::
                                                tshort :: tshort :: nil)
                                               (tptr (Tstruct _Object noattr))
                                               cc_default))
            ((Etempvar _t'4 (tptr (Tstruct _Object noattr))) ::
             (Econst_int (Int.repr 0) tint) ::
             (Econst_int (Int.repr 0) tint) ::
             (Evar _bhvSparkleSpawn (tarray tuint 0)) ::
             (Ebinop Oadd (Etempvar _x tshort) (Etempvar _offsetX tshort)
               tint) ::
             (Ebinop Oadd (Etempvar _y tshort) (Etempvar _offsetY tshort)
               tint) ::
             (Ebinop Oadd (Etempvar _z tshort) (Etempvar _offsetZ tshort)
               tint) :: (Econst_int (Int.repr 0) tint) ::
             (Econst_int (Int.repr 0) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil)))
        (Ssequence
          (Sset _offsetX
            (Ecast
              (Ebinop Odiv
                (Ebinop Omul (Etempvar _offsetX tshort)
                  (Econst_int (Int.repr 4) tint) tint)
                (Econst_int (Int.repr 3) tint) tint) tshort))
          (Ssequence
            (Sset _offsetX
              (Ecast
                (Ebinop Odiv
                  (Ebinop Omul (Etempvar _offsetY tshort)
                    (Econst_int (Int.repr 4) tint) tint)
                  (Econst_int (Int.repr 3) tint) tint) tshort))
            (Ssequence
              (Sset _offsetX
                (Ecast
                  (Ebinop Odiv
                    (Ebinop Omul (Etempvar _offsetZ tshort)
                      (Econst_int (Int.repr 4) tint) tint)
                    (Econst_int (Int.repr 3) tint) tint) tshort))
              (Ssequence
                (Ssequence
                  (Sset _t'3
                    (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                  (Scall None
                    (Evar _spawn_object_abs_with_rot (Tfunction
                                                       ((tptr (Tstruct _Object noattr)) ::
                                                        tshort :: tuint ::
                                                        (tptr tuint) ::
                                                        tshort :: tshort ::
                                                        tshort :: tshort ::
                                                        tshort :: tshort ::
                                                        nil)
                                                       (tptr (Tstruct _Object noattr))
                                                       cc_default))
                    ((Etempvar _t'3 (tptr (Tstruct _Object noattr))) ::
                     (Econst_int (Int.repr 0) tint) ::
                     (Econst_int (Int.repr 0) tint) ::
                     (Evar _bhvSparkleSpawn (tarray tuint 0)) ::
                     (Ebinop Osub (Etempvar _x tshort)
                       (Etempvar _offsetX tshort) tint) ::
                     (Ebinop Osub (Etempvar _y tshort)
                       (Etempvar _offsetY tshort) tint) ::
                     (Ebinop Osub (Etempvar _z tshort)
                       (Etempvar _offsetZ tshort) tint) ::
                     (Econst_int (Int.repr 0) tint) ::
                     (Econst_int (Int.repr 0) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil)))
                (Ssequence
                  (Ssequence
                    (Sset _t'2 (Evar _sSparkleGenTheta tint))
                    (Sassign (Evar _sSparkleGenTheta tint)
                      (Ebinop Oadd (Etempvar _t'2 tint)
                        (Econst_int (Int.repr 14336) tint) tint)))
                  (Ssequence
                    (Sset _t'1 (Evar _sSparkleGenPhi tint))
                    (Sassign (Evar _sSparkleGenPhi tint)
                      (Ebinop Oadd (Etempvar _t'1 tint)
                        (Econst_int (Int.repr 24576) tint) tint))))))))))))
|}.

Definition f_end_obj_set_visual_pos := {|
  fn_return := tfloat;
  fn_callconv := cc_default;
  fn_params := ((_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := ((_surf, (tptr (Tstruct _Surface noattr))) ::
              (_sp24, (tarray tshort 3)) :: nil);
  fn_temps := ((_sp20, tfloat) :: (_sp1C, tfloat) :: (_sp18, tfloat) ::
               (_t'1, tfloat) :: (_t'7, tshort) :: (_t'6, tshort) ::
               (_t'5, tfloat) :: (_t'4, tfloat) :: (_t'3, tshort) ::
               (_t'2, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Efield
                (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _header
                (Tstruct _ObjectNode noattr)) _gfx
              (Tstruct _GraphNodeObject noattr)) _angle (tarray tshort 3))
          (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
    (Scall None
      (Evar _find_mario_anim_flags_and_translation (Tfunction
                                                     ((tptr (Tstruct _Object noattr)) ::
                                                      tint ::
                                                      (tptr tshort) :: nil)
                                                     tshort cc_default))
      ((Etempvar _o (tptr (Tstruct _Object noattr))) ::
       (Etempvar _t'7 tshort) :: (Evar _sp24 (tarray tshort 3)) :: nil)))
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Efield
                  (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _header
                  (Tstruct _ObjectNode noattr)) _gfx
                (Tstruct _GraphNodeObject noattr)) _pos (tarray tfloat 3))
            (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
      (Ssequence
        (Sset _t'6
          (Ederef
            (Ebinop Oadd (Evar _sp24 (tarray tshort 3))
              (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
        (Sset _sp20
          (Ebinop Oadd (Etempvar _t'5 tfloat) (Etempvar _t'6 tshort) tfloat))))
    (Ssequence
      (Ssequence
        (Sset _t'4
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Efield
                    (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _header
                    (Tstruct _ObjectNode noattr)) _gfx
                  (Tstruct _GraphNodeObject noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
        (Sset _sp1C
          (Ebinop Oadd (Etempvar _t'4 tfloat)
            (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
            tfloat)))
      (Ssequence
        (Ssequence
          (Sset _t'2
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Efield
                      (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _header
                      (Tstruct _ObjectNode noattr)) _gfx
                    (Tstruct _GraphNodeObject noattr)) _pos
                  (tarray tfloat 3)) (Econst_int (Int.repr 2) tint)
                (tptr tfloat)) tfloat))
          (Ssequence
            (Sset _t'3
              (Ederef
                (Ebinop Oadd (Evar _sp24 (tarray tshort 3))
                  (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort))
            (Sset _sp18
              (Ebinop Oadd (Etempvar _t'2 tfloat) (Etempvar _t'3 tshort)
                tfloat))))
        (Ssequence
          (Scall (Some _t'1)
            (Evar _find_floor (Tfunction
                                (tfloat :: tfloat :: tfloat ::
                                 (tptr (tptr (Tstruct _Surface noattr))) ::
                                 nil) tfloat cc_default))
            ((Etempvar _sp20 tfloat) :: (Etempvar _sp1C tfloat) ::
             (Etempvar _sp18 tfloat) ::
             (Eaddrof (Evar _surf (tptr (Tstruct _Surface noattr)))
               (tptr (tptr (Tstruct _Surface noattr)))) :: nil))
          (Sreturn (Some (Etempvar _t'1 tfloat))))))))
|}.

Definition f_end_peach_cutscene_mario_falling := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) ::
               (_t'5, (tptr (Tstruct _PlayerCameraState noattr))) ::
               (_t'4, tushort) :: (_t'3, tushort) :: (_t'2, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionTimer tushort))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tushort)
                   (Econst_int (Int.repr 1) tint) tint)
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _statusForCamera
            (tptr (Tstruct _PlayerCameraState noattr))))
        (Sassign
          (Efield
            (Ederef
              (Etempvar _t'5 (tptr (Tstruct _PlayerCameraState noattr)))
              (Tstruct _PlayerCameraState noattr)) _cameraEvent tshort)
          (Econst_int (Int.repr 11) tint)))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sassign
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort)
        (Ebinop Oor (Etempvar _t'3 tushort) (Econst_int (Int.repr 128) tint)
          tint)))
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _flags tuint))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _flags tuint)
          (Ebinop Oor (Etempvar _t'2 tuint)
            (Ebinop Oor (Econst_int (Int.repr 8) tint)
              (Econst_int (Int.repr 16) tint) tint) tuint)))
      (Ssequence
        (Scall None
          (Evar _set_mario_animation (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tint :: nil) tshort cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 86) tint) :: nil))
        (Ssequence
          (Scall None
            (Evar _mario_set_forward_vel (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tfloat :: nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) :: nil))
          (Ssequence
            (Scall (Some _t'1)
              (Evar _perform_air_step (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tint)
                           (Econst_int (Int.repr 1) tint) tint)
              (Ssequence
                (Scall None
                  (Evar _play_mario_landing_sound (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: nil) tvoid
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
                             (Ecast (Econst_int (Int.repr 8) tint) tuint)
                             (Econst_int (Int.repr 16) tint) tuint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 128) tint) tuint)
                           (Econst_int (Int.repr 8) tint) tuint) tuint)
                       (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                         (Econst_int (Int.repr 128) tint) tint) tuint)
                     (Econst_int (Int.repr 1) tint) tuint) :: nil))
                (Scall None
                  (Evar _advance_cutscene_step (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tvoid cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil)))
              Sskip)))))))
|}.

Definition f_end_peach_cutscene_mario_landing := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _set_mario_animation (Tfunction
                                 ((tptr (Tstruct _MarioState noattr)) ::
                                  tint :: nil) tshort cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Econst_int (Int.repr 87) tint) :: nil))
  (Ssequence
    (Scall None
      (Evar _stop_and_set_height_to_floor (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Ssequence
      (Scall (Some _t'2)
        (Evar _is_anim_at_end (Tfunction
                                ((tptr (Tstruct _MarioState noattr)) :: nil)
                                tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Sifthenelse (Etempvar _t'2 tint)
        (Ssequence
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _capTimer tushort)
            (Econst_int (Int.repr 60) tint))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'4
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                (Scall (Some _t'1)
                  (Evar _spawn_object_abs_with_rot (Tfunction
                                                     ((tptr (Tstruct _Object noattr)) ::
                                                      tshort :: tuint ::
                                                      (tptr tuint) ::
                                                      tshort :: tshort ::
                                                      tshort :: tshort ::
                                                      tshort :: tshort ::
                                                      nil)
                                                     (tptr (Tstruct _Object noattr))
                                                     cc_default))
                  ((Etempvar _t'4 (tptr (Tstruct _Object noattr))) ::
                   (Econst_int (Int.repr 0) tint) ::
                   (Econst_int (Int.repr 122) tint) ::
                   (Evar _bhvStaticObject (tarray tuint 0)) ::
                   (Econst_int (Int.repr 0) tint) ::
                   (Econst_int (Int.repr 2528) tint) ::
                   (Eunop Oneg (Econst_int (Int.repr 1800) tint) tint) ::
                   (Econst_int (Int.repr 0) tint) ::
                   (Econst_int (Int.repr 0) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil)))
              (Sassign
                (Evar _sEndJumboStarObj (tptr (Tstruct _Object noattr)))
                (Etempvar _t'1 (tptr (Tstruct _Object noattr)))))
            (Ssequence
              (Ssequence
                (Sset _t'3
                  (Evar _sEndJumboStarObj (tptr (Tstruct _Object noattr))))
                (Scall None
                  (Evar _obj_scale (Tfunction
                                     ((tptr (Tstruct _Object noattr)) ::
                                      tfloat :: nil) tvoid cc_default))
                  ((Etempvar _t'3 (tptr (Tstruct _Object noattr))) ::
                   (Econst_float (Float.of_bits (Int64.repr 4613937818241073152)) tdouble) ::
                   nil)))
              (Scall None
                (Evar _advance_cutscene_step (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tvoid cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil)))))
        Sskip))))
|}.

Definition f_end_peach_cutscene_summon_jumbo_star := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'12, tushort) :: (_t'11, tushort) :: (_t'10, tushort) ::
               (_t'9, tushort) :: (_t'8, tushort) :: (_t'7, tint) ::
               (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'12
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionState tushort))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'12 tushort)
                     (Econst_int (Int.repr 0) tint) tint)
        (Sset _t'1 (Ecast (Econst_int (Int.repr 32) tint) tint))
        (Sset _t'1 (Ecast (Econst_int (Int.repr 33) tint) tint))))
    (Scall None
      (Evar _set_mario_animation (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _t'1 tint) :: nil)))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'11
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionState tushort))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'11 tushort)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _is_anim_past_end (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Sset _t'2 (Ecast (Etempvar _t'3 tint) tbool)))
          (Sset _t'2 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'2 tint)
        (Ssequence
          (Sset _t'10
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionState tushort))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionState tushort)
            (Ebinop Oadd (Etempvar _t'10 tushort)
              (Econst_int (Int.repr 1) tint) tint)))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'9
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tushort)
                       (Econst_int (Int.repr 90) tint) tint)
          (Scall None
            (Evar _play_cutscene_music (Tfunction (tushort :: nil) tvoid
                                         cc_default))
            ((Ebinop Oor
               (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                 (Econst_int (Int.repr 8) tint) tint)
               (Econst_int (Int.repr 32) tint) tint) :: nil))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'8
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'8 tushort)
                         (Econst_int (Int.repr 255) tint) tint)
            (Scall None
              (Evar _advance_cutscene_step (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'5
              (Evar _sEndJumboStarObj (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'6
                (Evar _sEndJumboStarObj (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'7
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __729 noattr)) _asS32 (tarray tint 80))
                      (Ebinop Oadd (Econst_int (Int.repr 18) tint)
                        (Econst_int (Int.repr 1) tint) tint) (tptr tint))
                    tint))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __729 noattr)) _asS32 (tarray tint 80))
                      (Ebinop Oadd (Econst_int (Int.repr 18) tint)
                        (Econst_int (Int.repr 1) tint) tint) (tptr tint))
                    tint)
                  (Ebinop Oadd (Etempvar _t'7 tint)
                    (Econst_int (Int.repr 1024) tint) tint)))))
          (Ssequence
            (Scall None
              (Evar _generate_yellow_sparkles (Tfunction
                                                (tshort :: tshort ::
                                                 tshort :: tfloat :: nil)
                                                tvoid cc_default))
              ((Econst_int (Int.repr 0) tint) ::
               (Econst_int (Int.repr 2528) tint) ::
               (Eunop Oneg (Econst_int (Int.repr 1800) tint) tint) ::
               (Econst_single (Float32.of_bits (Int.repr 1132068864)) tfloat) ::
               nil))
            (Ssequence
              (Sset _t'4
                (Evar _sEndJumboStarObj (tptr (Tstruct _Object noattr))))
              (Scall None
                (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil)
                                    tvoid cc_default))
                ((Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 6) tint) tuint)
                           (Econst_int (Int.repr 28) tint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 11) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 64) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Econst_int (Int.repr 0) tint) tuint)
                   (Econst_int (Int.repr 1) tint) tuint) ::
                 (Efield
                   (Efield
                     (Efield
                       (Ederef
                         (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                         (Tstruct _Object noattr)) _header
                       (Tstruct _ObjectNode noattr)) _gfx
                     (Tstruct _GraphNodeObject noattr)) _cameraToObject
                   (tarray tfloat 3)) :: nil)))))))))
|}.

Definition f_end_peach_cutscene_spawn_peach := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tfloat) :: (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: (_t'24, tushort) ::
               (_t'23, tushort) :: (_t'22, tushort) ::
               (_t'21, (tptr (Tstruct _Object noattr))) ::
               (_t'20, (tptr (Tstruct _Object noattr))) ::
               (_t'19, (tptr (Tstruct _Object noattr))) ::
               (_t'18, (tptr (Tstruct _Object noattr))) ::
               (_t'17, (tptr (Tstruct _Object noattr))) ::
               (_t'16, (tptr (Tstruct _Object noattr))) ::
               (_t'15, (tptr (Tstruct _Object noattr))) ::
               (_t'14, (tptr (Tstruct _Object noattr))) ::
               (_t'13, tushort) :: (_t'12, tint) ::
               (_t'11, (tptr (Tstruct _Object noattr))) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tushort) ::
               (_t'8, tushort) :: (_t'7, tushort) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tushort) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'24
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionTimer tushort))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'24 tushort)
                   (Econst_int (Int.repr 1) tint) tint)
      (Scall None
        (Evar _play_transition (Tfunction
                                 (tshort :: tshort :: tuchar :: tuchar ::
                                  tuchar :: nil) tvoid cc_default))
        ((Econst_int (Int.repr 1) tint) :: (Econst_int (Int.repr 14) tint) ::
         (Econst_int (Int.repr 255) tint) ::
         (Econst_int (Int.repr 255) tint) ::
         (Econst_int (Int.repr 255) tint) :: nil))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'23
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionTimer tushort))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'23 tushort)
                     (Econst_int (Int.repr 2) tint) tint)
        (Scall None
          (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                              cc_default))
          ((Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 7) tint) tuint)
                     (Econst_int (Int.repr 28) tint) tuint)
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 30) tint) tuint)
                     (Econst_int (Int.repr 16) tint) tuint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 255) tint) tuint)
                   (Econst_int (Int.repr 8) tint) tuint) tuint)
               (Econst_int (Int.repr 128) tint) tuint)
             (Econst_int (Int.repr 1) tint) tuint) ::
           (Evar _gGlobalSoundSource (tarray tfloat 3)) :: nil))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'22
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'22 tushort)
                       (Econst_int (Int.repr 44) tint) tint)
          (Scall None
            (Evar _play_transition (Tfunction
                                     (tshort :: tshort :: tuchar :: tuchar ::
                                      tuchar :: nil) tvoid cc_default))
            ((Econst_int (Int.repr 0) tint) ::
             (Econst_int (Int.repr 192) tint) ::
             (Econst_int (Int.repr 255) tint) ::
             (Econst_int (Int.repr 255) tint) ::
             (Econst_int (Int.repr 255) tint) :: nil))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'13
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'13 tushort)
                         (Econst_int (Int.repr 40) tint) tint)
            (Ssequence
              (Ssequence
                (Sset _t'21
                  (Evar _sEndJumboStarObj (tptr (Tstruct _Object noattr))))
                (Scall None
                  (Evar _obj_mark_for_deletion (Tfunction
                                                 ((tptr (Tstruct _Object noattr)) ::
                                                  nil) tvoid cc_default))
                  ((Etempvar _t'21 (tptr (Tstruct _Object noattr))) :: nil)))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'20
                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                    (Scall (Some _t'1)
                      (Evar _spawn_object_abs_with_rot (Tfunction
                                                         ((tptr (Tstruct _Object noattr)) ::
                                                          tshort :: tuint ::
                                                          (tptr tuint) ::
                                                          tshort :: tshort ::
                                                          tshort :: tshort ::
                                                          tshort :: tshort ::
                                                          nil)
                                                         (tptr (Tstruct _Object noattr))
                                                         cc_default))
                      ((Etempvar _t'20 (tptr (Tstruct _Object noattr))) ::
                       (Econst_int (Int.repr 0) tint) ::
                       (Econst_int (Int.repr 222) tint) ::
                       (Evar _bhvEndPeach (tarray tuint 0)) ::
                       (Econst_int (Int.repr 0) tint) ::
                       (Econst_int (Int.repr 2428) tint) ::
                       (Eunop Oneg (Econst_int (Int.repr 1300) tint) tint) ::
                       (Econst_int (Int.repr 0) tint) ::
                       (Econst_int (Int.repr 0) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil)))
                  (Sassign
                    (Evar _sEndPeachObj (tptr (Tstruct _Object noattr)))
                    (Etempvar _t'1 (tptr (Tstruct _Object noattr)))))
                (Ssequence
                  (Ssequence
                    (Sset _t'19
                      (Evar _sEndPeachObj (tptr (Tstruct _Object noattr))))
                    (Sassign
                      (Evar _gCutsceneFocus (tptr (Tstruct _Object noattr)))
                      (Etempvar _t'19 (tptr (Tstruct _Object noattr)))))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'18
                          (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                        (Scall (Some _t'2)
                          (Evar _spawn_object_abs_with_rot (Tfunction
                                                             ((tptr (Tstruct _Object noattr)) ::
                                                              tshort ::
                                                              tuint ::
                                                              (tptr tuint) ::
                                                              tshort ::
                                                              tshort ::
                                                              tshort ::
                                                              tshort ::
                                                              tshort ::
                                                              tshort :: nil)
                                                             (tptr (Tstruct _Object noattr))
                                                             cc_default))
                          ((Etempvar _t'18 (tptr (Tstruct _Object noattr))) ::
                           (Econst_int (Int.repr 0) tint) ::
                           (Econst_int (Int.repr 221) tint) ::
                           (Evar _bhvEndToad (tarray tuint 0)) ::
                           (Econst_int (Int.repr 200) tint) ::
                           (Econst_int (Int.repr 906) tint) ::
                           (Eunop Oneg (Econst_int (Int.repr 1290) tint)
                             tint) :: (Econst_int (Int.repr 0) tint) ::
                           (Econst_int (Int.repr 0) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil)))
                      (Sassign
                        (Evar _sEndRightToadObj (tptr (Tstruct _Object noattr)))
                        (Etempvar _t'2 (tptr (Tstruct _Object noattr)))))
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'17
                            (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                          (Scall (Some _t'3)
                            (Evar _spawn_object_abs_with_rot (Tfunction
                                                               ((tptr (Tstruct _Object noattr)) ::
                                                                tshort ::
                                                                tuint ::
                                                                (tptr tuint) ::
                                                                tshort ::
                                                                tshort ::
                                                                tshort ::
                                                                tshort ::
                                                                tshort ::
                                                                tshort ::
                                                                nil)
                                                               (tptr (Tstruct _Object noattr))
                                                               cc_default))
                            ((Etempvar _t'17 (tptr (Tstruct _Object noattr))) ::
                             (Econst_int (Int.repr 0) tint) ::
                             (Econst_int (Int.repr 221) tint) ::
                             (Evar _bhvEndToad (tarray tuint 0)) ::
                             (Eunop Oneg (Econst_int (Int.repr 200) tint)
                               tint) :: (Econst_int (Int.repr 906) tint) ::
                             (Eunop Oneg (Econst_int (Int.repr 1290) tint)
                               tint) :: (Econst_int (Int.repr 0) tint) ::
                             (Econst_int (Int.repr 0) tint) ::
                             (Econst_int (Int.repr 0) tint) :: nil)))
                        (Sassign
                          (Evar _sEndLeftToadObj (tptr (Tstruct _Object noattr)))
                          (Etempvar _t'3 (tptr (Tstruct _Object noattr)))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'16
                            (Evar _sEndPeachObj (tptr (Tstruct _Object noattr))))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'16 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __729 noattr)) _asS32
                                  (tarray tint 80))
                                (Econst_int (Int.repr 61) tint) (tptr tint))
                              tint) (Econst_int (Int.repr 127) tint)))
                        (Ssequence
                          (Ssequence
                            (Sset _t'15
                              (Evar _sEndRightToadObj (tptr (Tstruct _Object noattr))))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'15 (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _rawData
                                      (Tunion __729 noattr)) _asS32
                                    (tarray tint 80))
                                  (Econst_int (Int.repr 61) tint)
                                  (tptr tint)) tint)
                              (Econst_int (Int.repr 255) tint)))
                          (Ssequence
                            (Ssequence
                              (Sset _t'14
                                (Evar _sEndLeftToadObj (tptr (Tstruct _Object noattr))))
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'14 (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _rawData
                                        (Tunion __729 noattr)) _asS32
                                      (tarray tint 80))
                                    (Econst_int (Int.repr 61) tint)
                                    (tptr tint)) tint)
                                (Econst_int (Int.repr 255) tint)))
                            (Ssequence
                              (Sassign (Evar _D_8032CBE4 tschar)
                                (Econst_int (Int.repr 4) tint))
                              (Ssequence
                                (Sassign (Evar _sEndPeachAnimation tshort)
                                  (Econst_int (Int.repr 4) tint))
                                (Ssequence
                                  (Sassign
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _sEndToadAnims (tarray tshort 2))
                                        (Econst_int (Int.repr 0) tint)
                                        (tptr tshort)) tshort)
                                    (Econst_int (Int.repr 4) tint))
                                  (Sassign
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _sEndToadAnims (tarray tshort 2))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr tshort)) tshort)
                                    (Econst_int (Int.repr 5) tint)))))))))))))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'9
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sifthenelse (Ebinop Oge (Etempvar _t'9 tushort)
                           (Econst_int (Int.repr 276) tint) tint)
              (Ssequence
                (Ssequence
                  (Sset _t'11
                    (Evar _sEndPeachObj (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sset _t'12
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'11 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __729 noattr)) _asS32 (tarray tint 80))
                          (Econst_int (Int.repr 61) tint) (tptr tint)) tint))
                    (Scall (Some _t'4)
                      (Evar _camera_approach_f32_symmetric (Tfunction
                                                             (tfloat ::
                                                              tfloat ::
                                                              tfloat :: nil)
                                                             tfloat
                                                             cc_default))
                      ((Etempvar _t'12 tint) ::
                       (Econst_single (Float32.of_bits (Int.repr 1132396544)) tfloat) ::
                       (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat) ::
                       nil))))
                (Ssequence
                  (Sset _t'10
                    (Evar _sEndPeachObj (tptr (Tstruct _Object noattr))))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __729 noattr)) _asS32 (tarray tint 80))
                        (Econst_int (Int.repr 61) tint) (tptr tint)) tint)
                    (Etempvar _t'4 tfloat))))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'8
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionTimer tushort))
              (Sifthenelse (Ebinop Oge (Etempvar _t'8 tushort)
                             (Econst_int (Int.repr 40) tint) tint)
                (Scall None
                  (Evar _generate_yellow_sparkles (Tfunction
                                                    (tshort :: tshort ::
                                                     tshort :: tfloat :: nil)
                                                    tvoid cc_default))
                  ((Econst_int (Int.repr 0) tint) ::
                   (Econst_int (Int.repr 2628) tint) ::
                   (Eunop Oneg (Econst_int (Int.repr 1300) tint) tint) ::
                   (Econst_single (Float32.of_bits (Int.repr 1125515264)) tfloat) ::
                   nil))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'7
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionTimer tushort))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'7 tushort)
                               (Econst_int (Int.repr 355) tint) tint)
                  (Scall None
                    (Evar _advance_cutscene_step (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    nil) tvoid cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  Sskip))
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionTimer tushort))
                (Sifthenelse (Ebinop Oge (Etempvar _t'5 tushort)
                               (Econst_int (Int.repr 40) tint) tint)
                  (Ssequence
                    (Sset _t'6
                      (Evar _sEndPeachObj (tptr (Tstruct _Object noattr))))
                    (Scall None
                      (Evar _play_sound (Tfunction
                                          (tint :: (tptr tfloat) :: nil)
                                          tvoid cc_default))
                      ((Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oor
                               (Ebinop Oshl
                                 (Ecast (Econst_int (Int.repr 6) tint) tuint)
                                 (Econst_int (Int.repr 28) tint) tuint)
                               (Ebinop Oshl
                                 (Ecast (Econst_int (Int.repr 11) tint)
                                   tuint) (Econst_int (Int.repr 16) tint)
                                 tuint) tuint)
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 64) tint) tuint)
                               (Econst_int (Int.repr 8) tint) tuint) tuint)
                           (Econst_int (Int.repr 0) tint) tuint)
                         (Econst_int (Int.repr 1) tint) tuint) ::
                       (Efield
                         (Efield
                           (Efield
                             (Ederef
                               (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                               (Tstruct _Object noattr)) _header
                             (Tstruct _ObjectNode noattr)) _gfx
                           (Tstruct _GraphNodeObject noattr)) _cameraToObject
                         (tarray tfloat 3)) :: nil)))
                  Sskip)))))))))
|}.

Definition f_end_peach_cutscene_descend_peach := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tfloat) :: (_t'16, tfloat) ::
               (_t'15, (tptr (Tstruct _Object noattr))) ::
               (_t'14, tushort) :: (_t'13, tushort) :: (_t'12, tushort) ::
               (_t'11, tushort) :: (_t'10, tfloat) ::
               (_t'9, (tptr (Tstruct _Object noattr))) :: (_t'8, tushort) ::
               (_t'7, tfloat) :: (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: (_t'2, tushort) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'15 (Evar _sEndPeachObj (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'16
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'15 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __729 noattr))
              _asF32 (tarray tfloat 80))
            (Ebinop Oadd (Econst_int (Int.repr 6) tint)
              (Econst_int (Int.repr 1) tint) tint) (tptr tfloat)) tfloat))
      (Scall None
        (Evar _generate_yellow_sparkles (Tfunction
                                          (tshort :: tshort :: tshort ::
                                           tfloat :: nil) tvoid cc_default))
        ((Econst_int (Int.repr 0) tint) :: (Etempvar _t'16 tfloat) ::
         (Eunop Oneg (Econst_int (Int.repr 1300) tint) tint) ::
         (Econst_single (Float32.of_bits (Int.repr 1125515264)) tfloat) ::
         nil))))
  (Ssequence
    (Ssequence
      (Sset _t'9 (Evar _sEndPeachObj (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'10
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __729 noattr))
                _asF32 (tarray tfloat 80))
              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                (Econst_int (Int.repr 1) tint) tint) (tptr tfloat)) tfloat))
        (Sifthenelse (Ebinop Oge (Etempvar _t'10 tfloat)
                       (Econst_single (Float32.of_bits (Int.repr 1151500288)) tfloat)
                       tint)
          (Ssequence
            (Sset _t'13
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionState tushort))
            (Sifthenelse (Ebinop Olt (Etempvar _t'13 tushort)
                           (Econst_int (Int.repr 60) tint) tint)
              (Ssequence
                (Sset _t'14
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionState tushort))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionState tushort)
                  (Ebinop Oadd (Etempvar _t'14 tushort)
                    (Econst_int (Int.repr 5) tint) tint)))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'11
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionState tushort))
              (Sifthenelse (Ebinop Oge (Etempvar _t'11 tushort)
                             (Econst_int (Int.repr 27) tint) tint)
                (Ssequence
                  (Sset _t'12
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionState tushort))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionState tushort)
                    (Ebinop Osub (Etempvar _t'12 tushort)
                      (Econst_int (Int.repr 2) tint) tint)))
                Sskip))
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 31) tint) :: nil))))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'6 (Evar _sEndPeachObj (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'7
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __729 noattr)) _asF32 (tarray tfloat 80))
                    (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                      (Econst_int (Int.repr 1) tint) tint) (tptr tfloat))
                  tfloat))
              (Ssequence
                (Sset _t'8
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionState tushort))
                (Sset _t'1
                  (Ecast
                    (Ebinop Osub (Etempvar _t'7 tfloat)
                      (Ebinop Odiv (Etempvar _t'8 tushort)
                        (Econst_int (Int.repr 10) tint) tint) tfloat) tfloat)))))
          (Ssequence
            (Sset _t'5 (Evar _sEndPeachObj (tptr (Tstruct _Object noattr))))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __729 noattr)) _asF32 (tarray tfloat 80))
                  (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                    (Econst_int (Int.repr 1) tint) tint) (tptr tfloat))
                tfloat) (Etempvar _t'1 tfloat))))
        (Sifthenelse (Ebinop Ole (Etempvar _t'1 tfloat)
                       (Econst_single (Float32.of_bits (Int.repr 1147322368)) tfloat)
                       tint)
          (Ssequence
            (Sset _t'4 (Evar _sEndPeachObj (tptr (Tstruct _Object noattr))))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __729 noattr)) _asF32 (tarray tfloat 80))
                  (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                    (Econst_int (Int.repr 1) tint) tint) (tptr tfloat))
                tfloat)
              (Econst_single (Float32.of_bits (Int.repr 1147305984)) tfloat)))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'3 (Evar _sEndPeachObj (tptr (Tstruct _Object noattr))))
          (Scall None
            (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                                cc_default))
            ((Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 6) tint) tuint)
                       (Econst_int (Int.repr 28) tint) tuint)
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 11) tint) tuint)
                       (Econst_int (Int.repr 16) tint) tuint) tuint)
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 64) tint) tuint)
                     (Econst_int (Int.repr 8) tint) tuint) tuint)
                 (Econst_int (Int.repr 0) tint) tuint)
               (Econst_int (Int.repr 1) tint) tuint) ::
             (Efield
               (Efield
                 (Efield
                   (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                     (Tstruct _Object noattr)) _header
                   (Tstruct _ObjectNode noattr)) _gfx
                 (Tstruct _GraphNodeObject noattr)) _cameraToObject
               (tarray tfloat 3)) :: nil)))
        (Ssequence
          (Sset _t'2
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort))
          (Sifthenelse (Ebinop Oge (Etempvar _t'2 tushort)
                         (Econst_int (Int.repr 584) tint) tint)
            (Scall None
              (Evar _advance_cutscene_step (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            Sskip))))))
|}.

Definition f_end_peach_cutscene_run_to_peach := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := ((_surf, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_temps := ((_t'2, tfloat) :: (_t'1, tfloat) :: (_t'9, tushort) ::
               (_t'8, tfloat) :: (_t'7, tfloat) :: (_t'6, tfloat) ::
               (_t'5, tfloat) :: (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionTimer tushort))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tushort)
                   (Econst_int (Int.repr 22) tint) tint)
      (Sassign (Evar _sEndPeachAnimation tshort)
        (Econst_int (Int.repr 5) tint))
      Sskip))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'8
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
          (Sset _t'1
            (Ecast
              (Ebinop Osub (Etempvar _t'8 tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1101004800)) tfloat)
                tfloat) tfloat)))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat)
          (Etempvar _t'1 tfloat)))
      (Sifthenelse (Ebinop Ole (Etempvar _t'1 tfloat)
                     (Eunop Oneg
                       (Econst_single (Float32.of_bits (Int.repr 1150525440)) tfloat)
                       tfloat) tint)
        (Ssequence
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat)
            (Eunop Oneg
              (Econst_single (Float32.of_bits (Int.repr 1150517248)) tfloat)
              tfloat))
          (Scall None
            (Evar _advance_cutscene_step (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil)))
        Sskip))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'5
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
          (Ssequence
            (Sset _t'6
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
            (Ssequence
              (Sset _t'7
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                    (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
              (Scall (Some _t'2)
                (Evar _find_floor (Tfunction
                                    (tfloat :: tfloat :: tfloat ::
                                     (tptr (tptr (Tstruct _Surface noattr))) ::
                                     nil) tfloat cc_default))
                ((Etempvar _t'5 tfloat) :: (Etempvar _t'6 tfloat) ::
                 (Etempvar _t'7 tfloat) ::
                 (Eaddrof (Evar _surf (tptr (Tstruct _Surface noattr)))
                   (tptr (tptr (Tstruct _Surface noattr)))) :: nil)))))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
          (Etempvar _t'2 tfloat)))
      (Ssequence
        (Scall None
          (Evar _set_mario_anim_with_accel (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tint :: tint :: nil) tshort
                                             cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 114) tint) ::
           (Econst_int (Int.repr 524288) tint) :: nil))
        (Ssequence
          (Scall None
            (Evar _play_step_sound (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tshort :: tshort :: nil) tvoid
                                     cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 9) tint) ::
             (Econst_int (Int.repr 45) tint) :: nil))
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioObj
                  (tptr (Tstruct _Object noattr))))
              (Scall None
                (Evar _vec3f_copy (Tfunction
                                    ((tptr tfloat) :: (tptr tfloat) :: nil)
                                    (tptr tvoid) cc_default))
                ((Efield
                   (Efield
                     (Efield
                       (Ederef
                         (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                         (Tstruct _Object noattr)) _header
                       (Tstruct _ObjectNode noattr)) _gfx
                     (Tstruct _GraphNodeObject noattr)) _pos
                   (tarray tfloat 3)) ::
                 (Efield
                   (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                     (Tstruct _MarioState noattr)) _pos (tarray tfloat 3)) ::
                 nil)))
            (Ssequence
              (Sset _t'3
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _particleFlags tuint))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _particleFlags tuint)
                (Ebinop Oor (Etempvar _t'3 tuint)
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 0) tint) tint) tuint)))))))))
|}.

Definition f_end_peach_cutscene_dialog_1 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_animFrame, tint) :: (_t'3, tint) :: (_t'2, tshort) ::
               (_t'1, tint) :: (_t'9, tushort) :: (_t'8, tushort) ::
               (_t'7, tushort) :: (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: (_t'4, tushort) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'9
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionState tushort))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tushort)
                       (Econst_int (Int.repr 0) tint) tint)
          (Sset _t'1 (Ecast (Econst_int (Int.repr 34) tint) tint))
          (Sset _t'1 (Ecast (Econst_int (Int.repr 30) tint) tint))))
      (Scall (Some _t'2)
        (Evar _set_mario_animation (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tint :: nil) tshort cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Etempvar _t'1 tint) :: nil)))
    (Sset _animFrame (Etempvar _t'2 tshort)))
  (Ssequence
    (Ssequence
      (Sset _t'7
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionState tushort))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'7 tushort)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                         (Econst_int (Int.repr 8) tint) tint)
            (Scall None
              (Evar _cutscene_take_cap_off (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            Sskip)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _is_anim_at_end (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Sifthenelse (Etempvar _t'3 tint)
              (Ssequence
                (Sset _t'8
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionState tushort))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionState tushort)
                  (Ebinop Oadd (Etempvar _t'8 tushort)
                    (Econst_int (Int.repr 1) tint) tint)))
              Sskip)))
        Sskip))
    (Ssequence
      (Sset _t'4
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionTimer tushort))
      (Sswitch (Etempvar _t'4 tushort)
        (LScons (Some 80)
          (Ssequence
            (Sassign (Evar _sEndPeachAnimation tshort)
              (Econst_int (Int.repr 6) tint))
            Sbreak)
          (LScons (Some 81)
            (Ssequence
              (Sassign (Evar _D_8032CBE4 tschar)
                (Econst_int (Int.repr 3) tint))
              Sbreak)
            (LScons (Some 145)
              (Ssequence
                (Sassign (Evar _D_8032CBE4 tschar)
                  (Econst_int (Int.repr 2) tint))
                Sbreak)
              (LScons (Some 228)
                (Ssequence
                  (Sassign (Evar _D_8032CBE4 tschar)
                    (Econst_int (Int.repr 1) tint))
                  (Ssequence
                    (Sassign (Evar _D_8032CBE8 tschar)
                      (Econst_int (Int.repr 1) tint))
                    Sbreak))
                (LScons (Some 230)
                  (Ssequence
                    (Scall None
                      (Evar _set_cutscene_message (Tfunction
                                                    (tshort :: tshort ::
                                                     tshort :: tshort :: nil)
                                                    tvoid cc_default))
                      ((Econst_int (Int.repr 160) tint) ::
                       (Econst_int (Int.repr 227) tint) ::
                       (Econst_int (Int.repr 0) tint) ::
                       (Econst_int (Int.repr 30) tint) :: nil))
                    (Ssequence
                      (Scall None
                        (Evar _seq_player_lower_volume (Tfunction
                                                         (tuchar ::
                                                          tushort ::
                                                          tuchar :: nil)
                                                         tvoid cc_default))
                        ((Econst_int (Int.repr 0) tint) ::
                         (Econst_int (Int.repr 60) tint) ::
                         (Econst_int (Int.repr 40) tint) :: nil))
                      (Ssequence
                        (Ssequence
                          (Sset _t'6
                            (Evar _sEndPeachObj (tptr (Tstruct _Object noattr))))
                          (Scall None
                            (Evar _play_sound (Tfunction
                                                (tint :: (tptr tfloat) ::
                                                 nil) tvoid cc_default))
                            ((Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oor
                                   (Ebinop Oor
                                     (Ebinop Oshl
                                       (Ecast (Econst_int (Int.repr 2) tint)
                                         tuint)
                                       (Econst_int (Int.repr 28) tint) tuint)
                                     (Ebinop Oshl
                                       (Ecast (Econst_int (Int.repr 56) tint)
                                         tuint)
                                       (Econst_int (Int.repr 16) tint) tuint)
                                     tuint)
                                   (Ebinop Oshl
                                     (Ecast (Econst_int (Int.repr 255) tint)
                                       tuint) (Econst_int (Int.repr 8) tint)
                                     tuint) tuint)
                                 (Ebinop Oor
                                   (Econst_int (Int.repr 67108864) tint)
                                   (Econst_int (Int.repr 128) tint) tint)
                                 tuint) (Econst_int (Int.repr 1) tint) tuint) ::
                             (Efield
                               (Efield
                                 (Efield
                                   (Ederef
                                     (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                                     (Tstruct _Object noattr)) _header
                                   (Tstruct _ObjectNode noattr)) _gfx
                                 (Tstruct _GraphNodeObject noattr))
                               _cameraToObject (tarray tfloat 3)) :: nil)))
                        Sbreak)))
                  (LScons (Some 275)
                    (Ssequence
                      (Sassign (Evar _D_8032CBE4 tschar)
                        (Econst_int (Int.repr 0) tint))
                      (Ssequence
                        (Sassign (Evar _D_8032CBE8 tschar)
                          (Econst_int (Int.repr 0) tint))
                        Sbreak))
                    (LScons (Some 290)
                      (Ssequence
                        (Scall None
                          (Evar _set_cutscene_message (Tfunction
                                                        (tshort :: tshort ::
                                                         tshort :: tshort ::
                                                         nil) tvoid
                                                        cc_default))
                          ((Econst_int (Int.repr 160) tint) ::
                           (Econst_int (Int.repr 227) tint) ::
                           (Econst_int (Int.repr 1) tint) ::
                           (Econst_int (Int.repr 60) tint) :: nil))
                        (Ssequence
                          (Ssequence
                            (Sset _t'5
                              (Evar _sEndPeachObj (tptr (Tstruct _Object noattr))))
                            (Scall None
                              (Evar _play_sound (Tfunction
                                                  (tint :: (tptr tfloat) ::
                                                   nil) tvoid cc_default))
                              ((Ebinop Oor
                                 (Ebinop Oor
                                   (Ebinop Oor
                                     (Ebinop Oor
                                       (Ebinop Oshl
                                         (Ecast
                                           (Econst_int (Int.repr 2) tint)
                                           tuint)
                                         (Econst_int (Int.repr 28) tint)
                                         tuint)
                                       (Ebinop Oshl
                                         (Ecast
                                           (Econst_int (Int.repr 57) tint)
                                           tuint)
                                         (Econst_int (Int.repr 16) tint)
                                         tuint) tuint)
                                     (Ebinop Oshl
                                       (Ecast
                                         (Econst_int (Int.repr 255) tint)
                                         tuint)
                                       (Econst_int (Int.repr 8) tint) tuint)
                                     tuint)
                                   (Ebinop Oor
                                     (Econst_int (Int.repr 67108864) tint)
                                     (Econst_int (Int.repr 128) tint) tint)
                                   tuint) (Econst_int (Int.repr 1) tint)
                                 tuint) ::
                               (Efield
                                 (Efield
                                   (Efield
                                     (Ederef
                                       (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                                       (Tstruct _Object noattr)) _header
                                     (Tstruct _ObjectNode noattr)) _gfx
                                   (Tstruct _GraphNodeObject noattr))
                                 _cameraToObject (tarray tfloat 3)) :: nil)))
                          Sbreak))
                      (LScons (Some 480)
                        (Ssequence
                          (Scall None
                            (Evar _advance_cutscene_step (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            nil) tvoid
                                                           cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             nil))
                          Sbreak)
                        LSnil))))))))))))
|}.

Definition f_end_peach_cutscene_dialog_2 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: (_t'1, tushort) ::
               nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _sEndPeachAnimation tshort) (Econst_int (Int.repr 9) tint))
  (Ssequence
    (Sset _t'1
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionTimer tushort))
    (Sswitch (Etempvar _t'1 tushort)
      (LScons (Some 29)
        (Ssequence
          (Scall None
            (Evar _set_cutscene_message (Tfunction
                                          (tshort :: tshort :: tshort ::
                                           tshort :: nil) tvoid cc_default))
            ((Econst_int (Int.repr 160) tint) ::
             (Econst_int (Int.repr 227) tint) ::
             (Econst_int (Int.repr 2) tint) ::
             (Econst_int (Int.repr 30) tint) :: nil))
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Evar _sEndPeachObj (tptr (Tstruct _Object noattr))))
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
                           (Ecast (Econst_int (Int.repr 58) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 255) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                       (Econst_int (Int.repr 128) tint) tint) tuint)
                   (Econst_int (Int.repr 1) tint) tuint) ::
                 (Efield
                   (Efield
                     (Efield
                       (Ederef
                         (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                         (Tstruct _Object noattr)) _header
                       (Tstruct _ObjectNode noattr)) _gfx
                     (Tstruct _GraphNodeObject noattr)) _cameraToObject
                   (tarray tfloat 3)) :: nil)))
            Sbreak))
        (LScons (Some 45)
          (Ssequence
            (Sassign (Evar _D_8032CBE8 tschar)
              (Econst_int (Int.repr 1) tint))
            Sbreak)
          (LScons (Some 75)
            (Ssequence
              (Scall None
                (Evar _set_cutscene_message (Tfunction
                                              (tshort :: tshort :: tshort ::
                                               tshort :: nil) tvoid
                                              cc_default))
                ((Econst_int (Int.repr 160) tint) ::
                 (Econst_int (Int.repr 227) tint) ::
                 (Econst_int (Int.repr 3) tint) ::
                 (Econst_int (Int.repr 30) tint) :: nil))
              (Ssequence
                (Ssequence
                  (Sset _t'3
                    (Evar _sEndPeachObj (tptr (Tstruct _Object noattr))))
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
                               (Ecast (Econst_int (Int.repr 59) tint) tuint)
                               (Econst_int (Int.repr 16) tint) tuint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 255) tint) tuint)
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
                       (tarray tfloat 3)) :: nil)))
                Sbreak))
            (LScons (Some 130)
              (Ssequence
                (Scall None
                  (Evar _set_cutscene_message (Tfunction
                                                (tshort :: tshort ::
                                                 tshort :: tshort :: nil)
                                                tvoid cc_default))
                  ((Econst_int (Int.repr 160) tint) ::
                   (Econst_int (Int.repr 227) tint) ::
                   (Econst_int (Int.repr 4) tint) ::
                   (Econst_int (Int.repr 40) tint) :: nil))
                (Ssequence
                  (Ssequence
                    (Sset _t'2
                      (Evar _sEndPeachObj (tptr (Tstruct _Object noattr))))
                    (Scall None
                      (Evar _play_sound (Tfunction
                                          (tint :: (tptr tfloat) :: nil)
                                          tvoid cc_default))
                      ((Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oor
                               (Ebinop Oshl
                                 (Ecast (Econst_int (Int.repr 2) tint) tuint)
                                 (Econst_int (Int.repr 28) tint) tuint)
                               (Ebinop Oshl
                                 (Ecast (Econst_int (Int.repr 60) tint)
                                   tuint) (Econst_int (Int.repr 16) tint)
                                 tuint) tuint)
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 255) tint) tuint)
                               (Econst_int (Int.repr 8) tint) tuint) tuint)
                           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                             (Econst_int (Int.repr 128) tint) tint) tuint)
                         (Econst_int (Int.repr 1) tint) tuint) ::
                       (Efield
                         (Efield
                           (Efield
                             (Ederef
                               (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                               (Tstruct _Object noattr)) _header
                             (Tstruct _ObjectNode noattr)) _gfx
                           (Tstruct _GraphNodeObject noattr)) _cameraToObject
                         (tarray tfloat 3)) :: nil)))
                  Sbreak))
              (LScons (Some 200)
                (Ssequence
                  (Scall None
                    (Evar _advance_cutscene_step (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    nil) tvoid cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  Sbreak)
                LSnil))))))))
|}.

Definition v_sMarioBlinkOverride := {|
  gvar_info := (tarray tuchar 20);
  gvar_init := (Init_int8 (Int.repr 2) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 3) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 2) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 2) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 3) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 2) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 2) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 3) :: Init_int8 (Int.repr 3) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_end_peach_cutscene_kiss_from_peach := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'9, tuchar) :: (_t'8, tushort) ::
               (_t'7, tushort) ::
               (_t'6, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'5, tushort) ::
               (_t'4, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'3, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'2, tushort) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _sEndPeachAnimation tshort) (Econst_int (Int.repr 10) tint))
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionTimer tushort))
      (Sifthenelse (Ebinop Oge (Etempvar _t'5 tushort)
                     (Econst_int (Int.repr 90) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'7
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sifthenelse (Ebinop Olt (Etempvar _t'7 tushort)
                           (Econst_int (Int.repr 110) tint) tint)
              (Ssequence
                (Sset _t'8
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionTimer tushort))
                (Ssequence
                  (Sset _t'9
                    (Ederef
                      (Ebinop Oadd
                        (Evar _sMarioBlinkOverride (tarray tuchar 20))
                        (Ebinop Osub (Etempvar _t'8 tushort)
                          (Econst_int (Int.repr 90) tint) tint)
                        (tptr tuchar)) tuchar))
                  (Sset _t'1 (Ecast (Etempvar _t'9 tuchar) tint))))
              (Sset _t'1 (Ecast (Econst_int (Int.repr 2) tint) tint))))
          (Ssequence
            (Sset _t'6
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _marioBodyState
                (tptr (Tstruct _MarioBodyState noattr))))
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _t'6 (tptr (Tstruct _MarioBodyState noattr)))
                  (Tstruct _MarioBodyState noattr)) _eyeState tschar)
              (Etempvar _t'1 tint))))
        Sskip))
    (Ssequence
      (Sset _t'2
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionTimer tushort))
      (Sswitch (Etempvar _t'2 tushort)
        (LScons (Some 8)
          (Ssequence
            (Sassign (Evar _D_8032CBE8 tschar)
              (Econst_int (Int.repr 0) tint))
            Sbreak)
          (LScons (Some 10)
            (Ssequence
              (Sassign (Evar _D_8032CBE4 tschar)
                (Econst_int (Int.repr 3) tint))
              Sbreak)
            (LScons (Some 50)
              (Ssequence
                (Sassign (Evar _D_8032CBE4 tschar)
                  (Econst_int (Int.repr 4) tint))
                Sbreak)
              (LScons (Some 75)
                (Ssequence
                  (Ssequence
                    (Sset _t'4
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _marioBodyState
                        (tptr (Tstruct _MarioBodyState noattr))))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _t'4 (tptr (Tstruct _MarioBodyState noattr)))
                          (Tstruct _MarioBodyState noattr)) _eyeState tschar)
                      (Econst_int (Int.repr 2) tint)))
                  Sbreak)
                (LScons (Some 76)
                  (Ssequence
                    (Ssequence
                      (Sset _t'3
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _marioBodyState
                          (tptr (Tstruct _MarioBodyState noattr))))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _t'3 (tptr (Tstruct _MarioBodyState noattr)))
                            (Tstruct _MarioBodyState noattr)) _eyeState
                          tschar) (Econst_int (Int.repr 3) tint)))
                    Sbreak)
                  (LScons (Some 100)
                    (Ssequence
                      (Sassign (Evar _D_8032CBE4 tschar)
                        (Econst_int (Int.repr 3) tint))
                      Sbreak)
                    (LScons (Some 136)
                      (Ssequence
                        (Sassign (Evar _D_8032CBE4 tschar)
                          (Econst_int (Int.repr 0) tint))
                        Sbreak)
                      (LScons (Some 140)
                        (Ssequence
                          (Scall None
                            (Evar _advance_cutscene_step (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            nil) tvoid
                                                           cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             nil))
                          Sbreak)
                        LSnil))))))))))))
|}.

Definition f_end_peach_cutscene_star_dance := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_animFrame, tint) :: (_t'1, tshort) ::
               (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'4, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'3, tushort) :: (_t'2, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _set_mario_animation (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 39) tint) :: nil))
    (Sset _animFrame (Etempvar _t'1 tshort)))
  (Ssequence
    (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                   (Econst_int (Int.repr 77) tint) tint)
      (Scall None
        (Evar _cutscene_put_cap_on (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      Sskip)
    (Ssequence
      (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                     (Econst_int (Int.repr 88) tint) tint)
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioObj
              (tptr (Tstruct _Object noattr))))
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
                   (Ederef (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                     (Tstruct _Object noattr)) _header
                   (Tstruct _ObjectNode noattr)) _gfx
                 (Tstruct _GraphNodeObject noattr)) _cameraToObject
               (tarray tfloat 3)) :: nil)))
        Sskip)
      (Ssequence
        (Sifthenelse (Ebinop Oge (Etempvar _animFrame tint)
                       (Econst_int (Int.repr 98) tint) tint)
          (Ssequence
            (Sset _t'5
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _marioBodyState
                (tptr (Tstruct _MarioBodyState noattr))))
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _t'5 (tptr (Tstruct _MarioBodyState noattr)))
                  (Tstruct _MarioBodyState noattr)) _handState tschar)
              (Econst_int (Int.repr 2) tint)))
          Sskip)
        (Ssequence
          (Ssequence
            (Sset _t'3
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sifthenelse (Ebinop Olt (Etempvar _t'3 tushort)
                           (Econst_int (Int.repr 52) tint) tint)
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
                      (Tstruct _MarioBodyState noattr)) _eyeState tschar)
                  (Econst_int (Int.repr 2) tint)))
              Sskip))
          (Ssequence
            (Sset _t'2
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sswitch (Etempvar _t'2 tushort)
              (LScons (Some 70)
                (Ssequence
                  (Sassign (Evar _D_8032CBE4 tschar)
                    (Econst_int (Int.repr 1) tint))
                  Sbreak)
                (LScons (Some 86)
                  (Ssequence
                    (Sassign (Evar _D_8032CBE4 tschar)
                      (Econst_int (Int.repr 2) tint))
                    Sbreak)
                  (LScons (Some 90)
                    (Ssequence
                      (Sassign (Evar _D_8032CBE4 tschar)
                        (Econst_int (Int.repr 3) tint))
                      Sbreak)
                    (LScons (Some 120)
                      (Ssequence
                        (Sassign (Evar _D_8032CBE4 tschar)
                          (Econst_int (Int.repr 0) tint))
                        Sbreak)
                      (LScons (Some 140)
                        (Ssequence
                          (Scall None
                            (Evar _seq_player_unlower_volume (Tfunction
                                                               (tuchar ::
                                                                tushort ::
                                                                nil) tvoid
                                                               cc_default))
                            ((Econst_int (Int.repr 0) tint) ::
                             (Econst_int (Int.repr 60) tint) :: nil))
                          (Ssequence
                            (Scall None
                              (Evar _play_cutscene_music (Tfunction
                                                           (tushort :: nil)
                                                           tvoid cc_default))
                              ((Ebinop Oor
                                 (Ebinop Oshl (Econst_int (Int.repr 15) tint)
                                   (Econst_int (Int.repr 8) tint) tint)
                                 (Econst_int (Int.repr 26) tint) tint) ::
                               nil))
                            Sbreak))
                        (LScons (Some 142)
                          (Ssequence
                            (Scall None
                              (Evar _advance_cutscene_step (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              nil) tvoid
                                                             cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               nil))
                            Sbreak)
                          LSnil)))))))))))))
|}.

Definition f_end_peach_cutscene_dialog_3 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tfloat) :: (_t'2, tfloat) :: (_t'1, tfloat) ::
               (_t'13, (tptr (Tstruct _Object noattr))) ::
               (_t'12, (tptr (Tstruct _Object noattr))) ::
               (_t'11, (tptr (Tstruct _Object noattr))) ::
               (_t'10, (tptr (Tstruct _Object noattr))) ::
               (_t'9, (tptr (Tstruct _Object noattr))) ::
               (_t'8, (tptr (Tstruct _Object noattr))) ::
               (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tushort) ::
               (_t'4, tushort) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _set_mario_animation (Tfunction
                                 ((tptr (Tstruct _MarioState noattr)) ::
                                  tint :: nil) tshort cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Econst_int (Int.repr 194) tint) :: nil))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'13 (Evar _sEndPeachObj (tptr (Tstruct _Object noattr))))
        (Scall (Some _t'1)
          (Evar _end_obj_set_visual_pos (Tfunction
                                          ((tptr (Tstruct _Object noattr)) ::
                                           nil) tfloat cc_default))
          ((Etempvar _t'13 (tptr (Tstruct _Object noattr))) :: nil)))
      (Ssequence
        (Sset _t'12 (Evar _sEndPeachObj (tptr (Tstruct _Object noattr))))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'12 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __729 noattr))
                _asF32 (tarray tfloat 80))
              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                (Econst_int (Int.repr 1) tint) tint) (tptr tfloat)) tfloat)
          (Etempvar _t'1 tfloat))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'11
            (Evar _sEndRightToadObj (tptr (Tstruct _Object noattr))))
          (Scall (Some _t'2)
            (Evar _end_obj_set_visual_pos (Tfunction
                                            ((tptr (Tstruct _Object noattr)) ::
                                             nil) tfloat cc_default))
            ((Etempvar _t'11 (tptr (Tstruct _Object noattr))) :: nil)))
        (Ssequence
          (Sset _t'10
            (Evar _sEndRightToadObj (tptr (Tstruct _Object noattr))))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __729 noattr)) _asF32 (tarray tfloat 80))
                (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                  (Econst_int (Int.repr 1) tint) tint) (tptr tfloat)) tfloat)
            (Etempvar _t'2 tfloat))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'9
              (Evar _sEndLeftToadObj (tptr (Tstruct _Object noattr))))
            (Scall (Some _t'3)
              (Evar _end_obj_set_visual_pos (Tfunction
                                              ((tptr (Tstruct _Object noattr)) ::
                                               nil) tfloat cc_default))
              ((Etempvar _t'9 (tptr (Tstruct _Object noattr))) :: nil)))
          (Ssequence
            (Sset _t'8
              (Evar _sEndLeftToadObj (tptr (Tstruct _Object noattr))))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __729 noattr)) _asF32 (tarray tfloat 80))
                  (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                    (Econst_int (Int.repr 1) tint) tint) (tptr tfloat))
                tfloat) (Etempvar _t'3 tfloat))))
        (Ssequence
          (Ssequence
            (Sset _t'5
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sswitch (Etempvar _t'5 tushort)
              (LScons (Some 1)
                (Ssequence
                  (Sassign (Evar _sEndPeachAnimation tshort)
                    (Econst_int (Int.repr 0) tint))
                  (Ssequence
                    (Sassign
                      (Ederef
                        (Ebinop Oadd (Evar _sEndToadAnims (tarray tshort 2))
                          (Econst_int (Int.repr 0) tint) (tptr tshort))
                        tshort) (Econst_int (Int.repr 0) tint))
                    (Ssequence
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Evar _sEndToadAnims (tarray tshort 2))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))
                          tshort) (Econst_int (Int.repr 2) tint))
                      (Ssequence
                        (Sassign (Evar _D_8032CBE8 tschar)
                          (Econst_int (Int.repr 1) tint))
                        (Ssequence
                          (Scall None
                            (Evar _set_cutscene_message (Tfunction
                                                          (tshort ::
                                                           tshort ::
                                                           tshort ::
                                                           tshort :: nil)
                                                          tvoid cc_default))
                            ((Econst_int (Int.repr 160) tint) ::
                             (Econst_int (Int.repr 227) tint) ::
                             (Econst_int (Int.repr 5) tint) ::
                             (Econst_int (Int.repr 30) tint) :: nil))
                          (Ssequence
                            (Ssequence
                              (Sset _t'7
                                (Evar _sEndPeachObj (tptr (Tstruct _Object noattr))))
                              (Scall None
                                (Evar _play_sound (Tfunction
                                                    (tint :: (tptr tfloat) ::
                                                     nil) tvoid cc_default))
                                ((Ebinop Oor
                                   (Ebinop Oor
                                     (Ebinop Oor
                                       (Ebinop Oor
                                         (Ebinop Oshl
                                           (Ecast
                                             (Econst_int (Int.repr 2) tint)
                                             tuint)
                                           (Econst_int (Int.repr 28) tint)
                                           tuint)
                                         (Ebinop Oshl
                                           (Ecast
                                             (Econst_int (Int.repr 61) tint)
                                             tuint)
                                           (Econst_int (Int.repr 16) tint)
                                           tuint) tuint)
                                       (Ebinop Oshl
                                         (Ecast
                                           (Econst_int (Int.repr 255) tint)
                                           tuint)
                                         (Econst_int (Int.repr 8) tint)
                                         tuint) tuint)
                                     (Ebinop Oor
                                       (Econst_int (Int.repr 67108864) tint)
                                       (Econst_int (Int.repr 128) tint) tint)
                                     tuint) (Econst_int (Int.repr 1) tint)
                                   tuint) ::
                                 (Efield
                                   (Efield
                                     (Efield
                                       (Ederef
                                         (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                                         (Tstruct _Object noattr)) _header
                                       (Tstruct _ObjectNode noattr)) _gfx
                                     (Tstruct _GraphNodeObject noattr))
                                   _cameraToObject (tarray tfloat 3)) :: nil)))
                            Sbreak))))))
                (LScons (Some 55)
                  (Ssequence
                    (Scall None
                      (Evar _set_cutscene_message (Tfunction
                                                    (tshort :: tshort ::
                                                     tshort :: tshort :: nil)
                                                    tvoid cc_default))
                      ((Econst_int (Int.repr 160) tint) ::
                       (Econst_int (Int.repr 227) tint) ::
                       (Econst_int (Int.repr 6) tint) ::
                       (Econst_int (Int.repr 40) tint) :: nil))
                    Sbreak)
                  (LScons (Some 130)
                    (Ssequence
                      (Scall None
                        (Evar _set_cutscene_message (Tfunction
                                                      (tshort :: tshort ::
                                                       tshort :: tshort ::
                                                       nil) tvoid cc_default))
                        ((Econst_int (Int.repr 160) tint) ::
                         (Econst_int (Int.repr 227) tint) ::
                         (Econst_int (Int.repr 7) tint) ::
                         (Econst_int (Int.repr 50) tint) :: nil))
                      (Ssequence
                        (Ssequence
                          (Sset _t'6
                            (Evar _sEndPeachObj (tptr (Tstruct _Object noattr))))
                          (Scall None
                            (Evar _play_sound (Tfunction
                                                (tint :: (tptr tfloat) ::
                                                 nil) tvoid cc_default))
                            ((Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oor
                                   (Ebinop Oor
                                     (Ebinop Oshl
                                       (Ecast (Econst_int (Int.repr 2) tint)
                                         tuint)
                                       (Econst_int (Int.repr 28) tint) tuint)
                                     (Ebinop Oshl
                                       (Ecast (Econst_int (Int.repr 62) tint)
                                         tuint)
                                       (Econst_int (Int.repr 16) tint) tuint)
                                     tuint)
                                   (Ebinop Oshl
                                     (Ecast (Econst_int (Int.repr 255) tint)
                                       tuint) (Econst_int (Int.repr 8) tint)
                                     tuint) tuint)
                                 (Ebinop Oor
                                   (Econst_int (Int.repr 67108864) tint)
                                   (Econst_int (Int.repr 128) tint) tint)
                                 tuint) (Econst_int (Int.repr 1) tint) tuint) ::
                             (Efield
                               (Efield
                                 (Efield
                                   (Ederef
                                     (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                                     (Tstruct _Object noattr)) _header
                                   (Tstruct _ObjectNode noattr)) _gfx
                                 (Tstruct _GraphNodeObject noattr))
                               _cameraToObject (tarray tfloat 3)) :: nil)))
                        Sbreak))
                    LSnil)))))
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tushort)
                           (Econst_int (Int.repr 350) tint) tint)
              (Scall None
                (Evar _advance_cutscene_step (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tvoid cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              Sskip)))))))
|}.

Definition f_end_peach_cutscene_run_to_castle := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tint) :: (_t'3, tint) :: (_t'2, tfloat) ::
               (_t'1, tint) :: (_t'11, tushort) ::
               (_t'10, (tptr (Tstruct _Object noattr))) ::
               (_t'9, (tptr (Tstruct _Object noattr))) :: (_t'8, tushort) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tushort) ::
               (_t'5, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'11
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionState tushort))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'11 tushort)
                     (Econst_int (Int.repr 0) tint) tint)
        (Sset _t'1 (Ecast (Econst_int (Int.repr 35) tint) tint))
        (Sset _t'1 (Ecast (Econst_int (Int.repr 36) tint) tint))))
    (Scall None
      (Evar _set_mario_animation (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _t'1 tint) :: nil)))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'10
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _marioObj
            (tptr (Tstruct _Object noattr))))
        (Scall (Some _t'2)
          (Evar _end_obj_set_visual_pos (Tfunction
                                          ((tptr (Tstruct _Object noattr)) ::
                                           nil) tfloat cc_default))
          ((Etempvar _t'10 (tptr (Tstruct _Object noattr))) :: nil)))
      (Ssequence
        (Sset _t'9
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _marioObj
            (tptr (Tstruct _Object noattr))))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _header
                    (Tstruct _ObjectNode noattr)) _gfx
                  (Tstruct _GraphNodeObject noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
          (Etempvar _t'2 tfloat))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'8
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionState tushort))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'8 tushort)
                         (Econst_int (Int.repr 0) tint) tint)
            (Ssequence
              (Scall (Some _t'4)
                (Evar _is_anim_past_end (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sset _t'3 (Ecast (Etempvar _t'4 tint) tbool)))
            (Sset _t'3 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'3 tint)
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionState tushort)
            (Econst_int (Int.repr 1) tint))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'6 tushort)
                         (Econst_int (Int.repr 95) tint) tint)
            (Ssequence
              (Scall None
                (Evar _set_cutscene_message (Tfunction
                                              (tshort :: tshort :: tshort ::
                                               tshort :: nil) tvoid
                                              cc_default))
                ((Econst_int (Int.repr 160) tint) ::
                 (Econst_int (Int.repr 227) tint) ::
                 (Econst_int (Int.repr 0) tint) ::
                 (Econst_int (Int.repr 40) tint) :: nil))
              (Ssequence
                (Sset _t'7
                  (Evar _sEndPeachObj (tptr (Tstruct _Object noattr))))
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
                             (Ecast (Econst_int (Int.repr 63) tint) tuint)
                             (Econst_int (Int.repr 16) tint) tuint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 255) tint) tuint)
                           (Econst_int (Int.repr 8) tint) tuint) tuint)
                       (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                         (Econst_int (Int.repr 128) tint) tint) tuint)
                     (Econst_int (Int.repr 1) tint) tuint) ::
                   (Efield
                     (Efield
                       (Efield
                         (Ederef
                           (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                           (Tstruct _Object noattr)) _header
                         (Tstruct _ObjectNode noattr)) _gfx
                       (Tstruct _GraphNodeObject noattr)) _cameraToObject
                     (tarray tfloat 3)) :: nil))))
            Sskip))
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tushort)
                         (Econst_int (Int.repr 389) tint) tint)
            (Scall None
              (Evar _advance_cutscene_step (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            Sskip))))))
|}.

Definition f_end_peach_cutscene_fade_out := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tushort) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _actionState tushort))
  (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tushort)
                 (Econst_int (Int.repr 0) tint) tint)
    (Ssequence
      (Scall None
        (Evar _level_trigger_warp (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tint :: nil) tshort cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 24) tint) :: nil))
      (Ssequence
        (Sassign (Evar _gPaintingMarioYEntry tfloat)
          (Econst_single (Float32.of_bits (Int.repr 1153138688)) tfloat))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionState tushort)
          (Econst_int (Int.repr 1) tint))))
    Sskip))
|}.

Definition f_act_end_peach_cutscene := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tuint) :: (_t'1, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionArg tuint))
    (Sswitch (Etempvar _t'2 tuint)
      (LScons (Some 0)
        (Ssequence
          (Scall None
            (Evar _end_peach_cutscene_mario_falling (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          Sbreak)
        (LScons (Some 1)
          (Ssequence
            (Scall None
              (Evar _end_peach_cutscene_mario_landing (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tvoid
                                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            Sbreak)
          (LScons (Some 2)
            (Ssequence
              (Scall None
                (Evar _end_peach_cutscene_summon_jumbo_star (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               nil) tvoid
                                                              cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              Sbreak)
            (LScons (Some 3)
              (Ssequence
                (Scall None
                  (Evar _end_peach_cutscene_spawn_peach (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           nil) tvoid
                                                          cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                Sbreak)
              (LScons (Some 4)
                (Ssequence
                  (Scall None
                    (Evar _end_peach_cutscene_descend_peach (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               nil) tvoid
                                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  Sbreak)
                (LScons (Some 5)
                  (Ssequence
                    (Scall None
                      (Evar _end_peach_cutscene_run_to_peach (Tfunction
                                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                                nil) tvoid
                                                               cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    Sbreak)
                  (LScons (Some 6)
                    (Ssequence
                      (Scall None
                        (Evar _end_peach_cutscene_dialog_1 (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              nil) tvoid
                                                             cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      Sbreak)
                    (LScons (Some 7)
                      (Ssequence
                        (Scall None
                          (Evar _end_peach_cutscene_dialog_2 (Tfunction
                                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                                nil) tvoid
                                                               cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        Sbreak)
                      (LScons (Some 8)
                        (Ssequence
                          (Scall None
                            (Evar _end_peach_cutscene_kiss_from_peach 
                            (Tfunction
                              ((tptr (Tstruct _MarioState noattr)) :: nil)
                              tvoid cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             nil))
                          Sbreak)
                        (LScons (Some 9)
                          (Ssequence
                            (Scall None
                              (Evar _end_peach_cutscene_star_dance (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               nil))
                            Sbreak)
                          (LScons (Some 10)
                            (Ssequence
                              (Scall None
                                (Evar _end_peach_cutscene_dialog_3 (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 nil))
                              Sbreak)
                            (LScons (Some 11)
                              (Ssequence
                                (Scall None
                                  (Evar _end_peach_cutscene_run_to_castle 
                                  (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tvoid cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   nil))
                                Sbreak)
                              (LScons (Some 12)
                                (Ssequence
                                  (Scall None
                                    (Evar _end_peach_cutscene_fade_out 
                                    (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       nil) tvoid cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     nil))
                                  Sbreak)
                                LSnil)))))))))))))))
  (Ssequence
    (Ssequence
      (Sset _t'1
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionTimer tushort))
      (Sassign
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionTimer tushort)
        (Ebinop Oadd (Etempvar _t'1 tushort) (Econst_int (Int.repr 1) tint)
          tint)))
    (Ssequence
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield (Evar _sEndCutsceneVp (Tunion __441 noattr)) _vp
                (Tstruct __439 noattr)) _vscale (tarray tshort 4))
            (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort)
        (Econst_int (Int.repr 640) tint))
      (Ssequence
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield (Evar _sEndCutsceneVp (Tunion __441 noattr)) _vp
                  (Tstruct __439 noattr)) _vscale (tarray tshort 4))
              (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort)
          (Econst_int (Int.repr 360) tint))
        (Ssequence
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield (Evar _sEndCutsceneVp (Tunion __441 noattr)) _vp
                    (Tstruct __439 noattr)) _vtrans (tarray tshort 4))
                (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort)
            (Econst_int (Int.repr 640) tint))
          (Ssequence
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield (Evar _sEndCutsceneVp (Tunion __441 noattr)) _vp
                      (Tstruct __439 noattr)) _vtrans (tarray tshort 4))
                  (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort)
              (Econst_int (Int.repr 480) tint))
            (Ssequence
              (Scall None
                (Evar _override_viewport_and_clip (Tfunction
                                                    ((tptr (Tunion __441 noattr)) ::
                                                     (tptr (Tunion __441 noattr)) ::
                                                     tuchar :: tuchar ::
                                                     tuchar :: nil) tvoid
                                                    cc_default))
                ((Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
                 (Eaddrof (Evar _sEndCutsceneVp (Tunion __441 noattr))
                   (tptr (Tunion __441 noattr))) ::
                 (Econst_int (Int.repr 0) tint) ::
                 (Econst_int (Int.repr 0) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_act_credits_cutscene := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_width, tint) :: (_height, tint) :: (_t'3, tushort) ::
               (_t'2, tint) :: (_t'1, tint) ::
               (_t'32, (tptr (Tstruct _PlayerCameraState noattr))) ::
               (_t'31, (tptr (Tstruct _Camera noattr))) ::
               (_t'30, (tptr (Tstruct _Area noattr))) :: (_t'29, tuchar) ::
               (_t'28, (tptr (Tstruct _Camera noattr))) ::
               (_t'27, (tptr (Tstruct _Area noattr))) ::
               (_t'26, (tptr (Tstruct _Object noattr))) ::
               (_t'25, (tptr (Tstruct _Object noattr))) :: (_t'24, tuint) ::
               (_t'23, tushort) :: (_t'22, tshort) :: (_t'21, tfloat) ::
               (_t'20, tushort) :: (_t'19, tushort) :: (_t'18, tushort) ::
               (_t'17, tushort) :: (_t'16, tuchar) ::
               (_t'15, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'14, tuchar) ::
               (_t'13, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'12, tushort) :: (_t'11, tushort) ::
               (_t'10, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'9, tushort) :: (_t'8, tuchar) ::
               (_t'7, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'6, tshort) :: (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'32
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _statusForCamera
        (tptr (Tstruct _PlayerCameraState noattr))))
    (Sassign
      (Efield
        (Ederef (Etempvar _t'32 (tptr (Tstruct _PlayerCameraState noattr)))
          (Tstruct _PlayerCameraState noattr)) _cameraEvent tshort)
      (Econst_int (Int.repr 13) tint)))
  (Ssequence
    (Ssequence
      (Sset _t'21
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
            (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
      (Ssequence
        (Sset _t'22
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _waterLevel tshort))
        (Sifthenelse (Ebinop Olt (Etempvar _t'21 tfloat)
                       (Ebinop Osub (Etempvar _t'22 tshort)
                         (Econst_int (Int.repr 100) tint) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'27
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _area
                  (tptr (Tstruct _Area noattr))))
              (Ssequence
                (Sset _t'28
                  (Efield
                    (Ederef (Etempvar _t'27 (tptr (Tstruct _Area noattr)))
                      (Tstruct _Area noattr)) _camera
                    (tptr (Tstruct _Camera noattr))))
                (Ssequence
                  (Sset _t'29
                    (Efield
                      (Ederef
                        (Etempvar _t'28 (tptr (Tstruct _Camera noattr)))
                        (Tstruct _Camera noattr)) _mode tuchar))
                  (Sifthenelse (Ebinop One (Etempvar _t'29 tuchar)
                                 (Econst_int (Int.repr 3) tint) tint)
                    (Ssequence
                      (Sset _t'30
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _area
                          (tptr (Tstruct _Area noattr))))
                      (Ssequence
                        (Sset _t'31
                          (Efield
                            (Ederef
                              (Etempvar _t'30 (tptr (Tstruct _Area noattr)))
                              (Tstruct _Area noattr)) _camera
                            (tptr (Tstruct _Camera noattr))))
                        (Scall None
                          (Evar _set_camera_mode (Tfunction
                                                   ((tptr (Tstruct _Camera noattr)) ::
                                                    tshort :: tshort :: nil)
                                                   tvoid cc_default))
                          ((Etempvar _t'31 (tptr (Tstruct _Camera noattr))) ::
                           (Econst_int (Int.repr 3) tint) ::
                           (Econst_int (Int.repr 1) tint) :: nil))))
                    Sskip))))
            (Ssequence
              (Scall None
                (Evar _set_mario_animation (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tint :: nil) tshort cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 178) tint) :: nil))
              (Ssequence
                (Ssequence
                  (Sset _t'26
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _marioObj
                      (tptr (Tstruct _Object noattr))))
                  (Scall None
                    (Evar _vec3f_copy (Tfunction
                                        ((tptr tfloat) :: (tptr tfloat) ::
                                         nil) (tptr tvoid) cc_default))
                    ((Efield
                       (Efield
                         (Efield
                           (Ederef
                             (Etempvar _t'26 (tptr (Tstruct _Object noattr)))
                             (Tstruct _Object noattr)) _header
                           (Tstruct _ObjectNode noattr)) _gfx
                         (Tstruct _GraphNodeObject noattr)) _pos
                       (tarray tfloat 3)) ::
                     (Efield
                       (Ederef
                         (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                         (Tstruct _MarioState noattr)) _pos
                       (tarray tfloat 3)) :: nil)))
                (Ssequence
                  (Ssequence
                    (Sset _t'25
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _marioObj
                        (tptr (Tstruct _Object noattr))))
                    (Scall None
                      (Evar _vec3s_copy (Tfunction
                                          ((tptr tshort) :: (tptr tshort) ::
                                           nil) (tptr tvoid) cc_default))
                      ((Efield
                         (Efield
                           (Efield
                             (Ederef
                               (Etempvar _t'25 (tptr (Tstruct _Object noattr)))
                               (Tstruct _Object noattr)) _header
                             (Tstruct _ObjectNode noattr)) _gfx
                           (Tstruct _GraphNodeObject noattr)) _angle
                         (tarray tshort 3)) ::
                       (Efield
                         (Ederef
                           (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                           (Tstruct _MarioState noattr)) _faceAngle
                         (tarray tshort 3)) :: nil)))
                  (Ssequence
                    (Sset _t'24
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _particleFlags tuint))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _particleFlags tuint)
                      (Ebinop Oor (Etempvar _t'24 tuint)
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 5) tint) tint) tuint)))))))
          (Ssequence
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 194) tint) :: nil))
            (Ssequence
              (Sset _t'23
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionTimer tushort))
              (Sifthenelse (Ebinop Ogt (Etempvar _t'23 tushort)
                             (Econst_int (Int.repr 0) tint) tint)
                (Scall None
                  (Evar _stop_and_set_height_to_floor (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tvoid
                                                        cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                Sskip))))))
    (Ssequence
      (Ssequence
        (Sset _t'12
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort))
        (Sifthenelse (Ebinop Oge (Etempvar _t'12 tushort)
                       (Econst_int (Int.repr 61) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'19
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionState tushort))
              (Sifthenelse (Ebinop Olt (Etempvar _t'19 tushort)
                             (Econst_int (Int.repr 40) tint) tint)
                (Ssequence
                  (Sset _t'20
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionState tushort))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionState tushort)
                    (Ebinop Oadd (Etempvar _t'20 tushort)
                      (Econst_int (Int.repr 2) tint) tint)))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'18
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionState tushort))
                (Sset _width
                  (Ebinop Odiv
                    (Ebinop Omul (Etempvar _t'18 tushort)
                      (Econst_int (Int.repr 640) tint) tint)
                    (Econst_int (Int.repr 100) tint) tint)))
              (Ssequence
                (Ssequence
                  (Sset _t'17
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionState tushort))
                  (Sset _height
                    (Ebinop Odiv
                      (Ebinop Omul (Etempvar _t'17 tushort)
                        (Econst_int (Int.repr 480) tint) tint)
                      (Econst_int (Int.repr 100) tint) tint)))
                (Ssequence
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Evar _sEndCutsceneVp (Tunion __441 noattr)) _vp
                            (Tstruct __439 noattr)) _vscale
                          (tarray tshort 4)) (Econst_int (Int.repr 0) tint)
                        (tptr tshort)) tshort)
                    (Ebinop Osub (Econst_int (Int.repr 640) tint)
                      (Etempvar _width tint) tint))
                  (Ssequence
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Evar _sEndCutsceneVp (Tunion __441 noattr))
                              _vp (Tstruct __439 noattr)) _vscale
                            (tarray tshort 4)) (Econst_int (Int.repr 1) tint)
                          (tptr tshort)) tshort)
                      (Ebinop Osub (Econst_int (Int.repr 480) tint)
                        (Etempvar _height tint) tint))
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'15
                            (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
                          (Ssequence
                            (Sset _t'16
                              (Efield
                                (Ederef
                                  (Etempvar _t'15 (tptr (Tstruct _CreditsEntry noattr)))
                                  (Tstruct _CreditsEntry noattr)) _unk02
                                tuchar))
                            (Sifthenelse (Ebinop Oand (Etempvar _t'16 tuchar)
                                           (Econst_int (Int.repr 16) tint)
                                           tint)
                              (Sset _t'1 (Ecast (Etempvar _width tint) tint))
                              (Sset _t'1
                                (Ecast
                                  (Eunop Oneg (Etempvar _width tint) tint)
                                  tint)))))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Evar _sEndCutsceneVp (Tunion __441 noattr))
                                  _vp (Tstruct __439 noattr)) _vtrans
                                (tarray tshort 4))
                              (Econst_int (Int.repr 0) tint) (tptr tshort))
                            tshort)
                          (Ebinop Oadd
                            (Ebinop Odiv
                              (Ebinop Omul (Etempvar _t'1 tint)
                                (Econst_int (Int.repr 56) tint) tint)
                              (Econst_int (Int.repr 100) tint) tint)
                            (Econst_int (Int.repr 640) tint) tint)))
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'13
                              (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
                            (Ssequence
                              (Sset _t'14
                                (Efield
                                  (Ederef
                                    (Etempvar _t'13 (tptr (Tstruct _CreditsEntry noattr)))
                                    (Tstruct _CreditsEntry noattr)) _unk02
                                  tuchar))
                              (Sifthenelse (Ebinop Oand
                                             (Etempvar _t'14 tuchar)
                                             (Econst_int (Int.repr 32) tint)
                                             tint)
                                (Sset _t'2
                                  (Ecast (Etempvar _height tint) tint))
                                (Sset _t'2
                                  (Ecast
                                    (Eunop Oneg (Etempvar _height tint) tint)
                                    tint)))))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Evar _sEndCutsceneVp (Tunion __441 noattr))
                                    _vp (Tstruct __439 noattr)) _vtrans
                                  (tarray tshort 4))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))
                              tshort)
                            (Ebinop Oadd
                              (Ebinop Odiv
                                (Ebinop Omul (Etempvar _t'2 tint)
                                  (Econst_int (Int.repr 66) tint) tint)
                                (Econst_int (Int.repr 100) tint) tint)
                              (Econst_int (Int.repr 480) tint) tint)))
                        (Scall None
                          (Evar _override_viewport_and_clip (Tfunction
                                                              ((tptr (Tunion __441 noattr)) ::
                                                               (tptr (Tunion __441 noattr)) ::
                                                               tuchar ::
                                                               tuchar ::
                                                               tuchar :: nil)
                                                              tvoid
                                                              cc_default))
                          ((Eaddrof
                             (Evar _sEndCutsceneVp (Tunion __441 noattr))
                             (tptr (Tunion __441 noattr))) ::
                           (Econst_int (Int.repr 0) tint) ::
                           (Econst_int (Int.repr 0) tint) ::
                           (Econst_int (Int.repr 0) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil)))))))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'11
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'11 tushort)
                         (Econst_int (Int.repr 90) tint) tint)
            (Scall None
              (Evar _reset_cutscene_msg_fade (Tfunction nil tvoid cc_default))
              nil)
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'9
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sifthenelse (Ebinop Oge (Etempvar _t'9 tushort)
                           (Econst_int (Int.repr 90) tint) tint)
              (Ssequence
                (Sset _t'10
                  (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
                (Sassign
                  (Evar _sDispCreditsEntry (tptr (Tstruct _CreditsEntry noattr)))
                  (Etempvar _t'10 (tptr (Tstruct _CreditsEntry noattr)))))
              Sskip))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'3
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionTimer tushort))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionTimer tushort)
                  (Ebinop Oadd (Etempvar _t'3 tushort)
                    (Econst_int (Int.repr 1) tint) tint)))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tushort)
                             (Econst_int (Int.repr 200) tint) tint)
                (Scall None
                  (Evar _level_trigger_warp (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tint :: nil) tshort
                                              cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 24) tint) :: nil))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'4
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _marioObj
                    (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'5
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _marioObj
                      (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sset _t'6
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _header
                                (Tstruct _ObjectNode noattr)) _gfx
                              (Tstruct _GraphNodeObject noattr)) _angle
                            (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tshort)) tshort))
                    (Ssequence
                      (Sset _t'7
                        (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
                      (Ssequence
                        (Sset _t'8
                          (Efield
                            (Ederef
                              (Etempvar _t'7 (tptr (Tstruct _CreditsEntry noattr)))
                              (Tstruct _CreditsEntry noattr)) _unk02 tuchar))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _header
                                    (Tstruct _ObjectNode noattr)) _gfx
                                  (Tstruct _GraphNodeObject noattr)) _angle
                                (tarray tshort 3))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))
                            tshort)
                          (Ebinop Oadd (Etempvar _t'6 tshort)
                            (Ebinop Oshl
                              (Ebinop Oand (Etempvar _t'8 tuchar)
                                (Econst_int (Int.repr 192) tint) tint)
                              (Econst_int (Int.repr 8) tint) tint) tint)))))))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_act_end_waving_cutscene := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tushort) :: (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, (tptr (Tstruct _Object noattr))) ::
               (_t'19, (tptr (Tstruct _PlayerCameraState noattr))) ::
               (_t'18, (tptr (Tstruct _Object noattr))) ::
               (_t'17, (tptr (Tstruct _Object noattr))) ::
               (_t'16, (tptr (Tstruct _Object noattr))) ::
               (_t'15, (tptr (Tstruct _Object noattr))) ::
               (_t'14, (tptr (Tstruct _Object noattr))) ::
               (_t'13, (tptr (Tstruct _Object noattr))) ::
               (_t'12, tushort) :: (_t'11, tshort) ::
               (_t'10, (tptr (Tstruct _Object noattr))) ::
               (_t'9, (tptr (Tstruct _Object noattr))) :: (_t'8, tfloat) ::
               (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _MarioBodyState noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'12
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionState tushort))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'12 tushort)
                   (Econst_int (Int.repr 0) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'19
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _statusForCamera
              (tptr (Tstruct _PlayerCameraState noattr))))
          (Sassign
            (Efield
              (Ederef
                (Etempvar _t'19 (tptr (Tstruct _PlayerCameraState noattr)))
                (Tstruct _PlayerCameraState noattr)) _cameraEvent tshort)
            (Econst_int (Int.repr 12) tint)))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'18
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Scall (Some _t'1)
                (Evar _spawn_object_abs_with_rot (Tfunction
                                                   ((tptr (Tstruct _Object noattr)) ::
                                                    tshort :: tuint ::
                                                    (tptr tuint) :: tshort ::
                                                    tshort :: tshort ::
                                                    tshort :: tshort ::
                                                    tshort :: nil)
                                                   (tptr (Tstruct _Object noattr))
                                                   cc_default))
                ((Etempvar _t'18 (tptr (Tstruct _Object noattr))) ::
                 (Econst_int (Int.repr 0) tint) ::
                 (Econst_int (Int.repr 222) tint) ::
                 (Evar _bhvEndPeach (tarray tuint 0)) ::
                 (Econst_int (Int.repr 60) tint) ::
                 (Econst_int (Int.repr 906) tint) ::
                 (Eunop Oneg (Econst_int (Int.repr 1180) tint) tint) ::
                 (Econst_int (Int.repr 0) tint) ::
                 (Econst_int (Int.repr 0) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil)))
            (Sassign (Evar _sEndPeachObj (tptr (Tstruct _Object noattr)))
              (Etempvar _t'1 (tptr (Tstruct _Object noattr)))))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'17
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                (Scall (Some _t'2)
                  (Evar _spawn_object_abs_with_rot (Tfunction
                                                     ((tptr (Tstruct _Object noattr)) ::
                                                      tshort :: tuint ::
                                                      (tptr tuint) ::
                                                      tshort :: tshort ::
                                                      tshort :: tshort ::
                                                      tshort :: tshort ::
                                                      nil)
                                                     (tptr (Tstruct _Object noattr))
                                                     cc_default))
                  ((Etempvar _t'17 (tptr (Tstruct _Object noattr))) ::
                   (Econst_int (Int.repr 0) tint) ::
                   (Econst_int (Int.repr 221) tint) ::
                   (Evar _bhvEndToad (tarray tuint 0)) ::
                   (Econst_int (Int.repr 180) tint) ::
                   (Econst_int (Int.repr 906) tint) ::
                   (Eunop Oneg (Econst_int (Int.repr 1170) tint) tint) ::
                   (Econst_int (Int.repr 0) tint) ::
                   (Econst_int (Int.repr 0) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil)))
              (Sassign
                (Evar _sEndRightToadObj (tptr (Tstruct _Object noattr)))
                (Etempvar _t'2 (tptr (Tstruct _Object noattr)))))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'16
                    (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                  (Scall (Some _t'3)
                    (Evar _spawn_object_abs_with_rot (Tfunction
                                                       ((tptr (Tstruct _Object noattr)) ::
                                                        tshort :: tuint ::
                                                        (tptr tuint) ::
                                                        tshort :: tshort ::
                                                        tshort :: tshort ::
                                                        tshort :: tshort ::
                                                        nil)
                                                       (tptr (Tstruct _Object noattr))
                                                       cc_default))
                    ((Etempvar _t'16 (tptr (Tstruct _Object noattr))) ::
                     (Econst_int (Int.repr 0) tint) ::
                     (Econst_int (Int.repr 221) tint) ::
                     (Evar _bhvEndToad (tarray tuint 0)) ::
                     (Eunop Oneg (Econst_int (Int.repr 180) tint) tint) ::
                     (Econst_int (Int.repr 906) tint) ::
                     (Eunop Oneg (Econst_int (Int.repr 1170) tint) tint) ::
                     (Econst_int (Int.repr 0) tint) ::
                     (Econst_int (Int.repr 0) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil)))
                (Sassign
                  (Evar _sEndLeftToadObj (tptr (Tstruct _Object noattr)))
                  (Etempvar _t'3 (tptr (Tstruct _Object noattr)))))
              (Ssequence
                (Ssequence
                  (Sset _t'15
                    (Evar _sEndPeachObj (tptr (Tstruct _Object noattr))))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'15 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __729 noattr)) _asS32 (tarray tint 80))
                        (Econst_int (Int.repr 61) tint) (tptr tint)) tint)
                    (Econst_int (Int.repr 255) tint)))
                (Ssequence
                  (Ssequence
                    (Sset _t'14
                      (Evar _sEndRightToadObj (tptr (Tstruct _Object noattr))))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'14 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __729 noattr)) _asS32 (tarray tint 80))
                          (Econst_int (Int.repr 61) tint) (tptr tint)) tint)
                      (Econst_int (Int.repr 255) tint)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'13
                        (Evar _sEndLeftToadObj (tptr (Tstruct _Object noattr))))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'13 (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _rawData
                                (Tunion __729 noattr)) _asS32
                              (tarray tint 80))
                            (Econst_int (Int.repr 61) tint) (tptr tint))
                          tint) (Econst_int (Int.repr 255) tint)))
                    (Ssequence
                      (Sassign (Evar _sEndPeachAnimation tshort)
                        (Econst_int (Int.repr 11) tint))
                      (Ssequence
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Evar _sEndToadAnims (tarray tshort 2))
                              (Econst_int (Int.repr 0) tint) (tptr tshort))
                            tshort) (Econst_int (Int.repr 6) tint))
                        (Ssequence
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Evar _sEndToadAnims (tarray tshort 2))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))
                              tshort) (Econst_int (Int.repr 7) tint))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _actionState
                              tushort) (Econst_int (Int.repr 1) tint))))))))))))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _set_mario_animation (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 29) tint) :: nil))
    (Ssequence
      (Scall None
        (Evar _stop_and_set_height_to_floor (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Ssequence
        (Ssequence
          (Sset _t'9
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioObj
              (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'10
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _marioObj
                (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'11
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _header
                          (Tstruct _ObjectNode noattr)) _gfx
                        (Tstruct _GraphNodeObject noattr)) _angle
                      (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                    (tptr tshort)) tshort))
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
                      (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                    (tptr tshort)) tshort)
                (Ebinop Oadd (Etempvar _t'11 tshort)
                  (Econst_int (Int.repr 32768) tint) tint)))))
        (Ssequence
          (Ssequence
            (Sset _t'6
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _marioObj
                (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'7
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioObj
                  (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'8
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _header
                            (Tstruct _ObjectNode noattr)) _gfx
                          (Tstruct _GraphNodeObject noattr)) _pos
                        (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tfloat)) tfloat))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _header
                            (Tstruct _ObjectNode noattr)) _gfx
                          (Tstruct _GraphNodeObject noattr)) _pos
                        (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tfloat)) tfloat)
                  (Ebinop Osub (Etempvar _t'8 tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat)
                    tfloat)))))
          (Ssequence
            (Ssequence
              (Sset _t'5
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioBodyState
                  (tptr (Tstruct _MarioBodyState noattr))))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _t'5 (tptr (Tstruct _MarioBodyState noattr)))
                    (Tstruct _MarioBodyState noattr)) _handState tschar)
                (Econst_int (Int.repr 5) tint)))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'4
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionTimer tushort))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionTimer tushort)
                    (Ebinop Oadd (Etempvar _t'4 tushort)
                      (Econst_int (Int.repr 1) tint) tint)))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tushort)
                               (Econst_int (Int.repr 300) tint) tint)
                  (Scall None
                    (Evar _level_trigger_warp (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tint :: nil) tshort
                                                cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 21) tint) :: nil))
                  Sskip))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_check_for_instant_quicksand := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'7, tuint) :: (_t'6, tshort) ::
               (_t'5, (tptr (Tstruct _Surface noattr))) :: (_t'4, tuint) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _floor
            (tptr (Tstruct _Surface noattr))))
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _t'5 (tptr (Tstruct _Surface noattr)))
                (Tstruct _Surface noattr)) _type tshort))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'6 tshort)
                         (Econst_int (Int.repr 35) tint) tint)
            (Ssequence
              (Sset _t'7
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _action tuint))
              (Sset _t'2
                (Ecast
                  (Ebinop Oand (Etempvar _t'7 tuint)
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 17) tint) tint) tuint) tbool)))
            (Sset _t'2 (Econst_int (Int.repr 0) tint)))))
      (Sifthenelse (Etempvar _t'2 tint)
        (Ssequence
          (Sset _t'4
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _action tuint))
          (Sset _t'3
            (Ecast
              (Ebinop One (Etempvar _t'4 tuint)
                (Econst_int (Int.repr 135954) tint) tint) tbool)))
        (Sset _t'3 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'3 tint)
      (Ssequence
        (Scall None
          (Evar _update_mario_sound_and_camera (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Ssequence
          (Scall (Some _t'1)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 135954) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tint)))))
      Sskip))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_mario_execute_cutscene_action := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_cancel, tint) :: (_t'52, tint) :: (_t'51, tint) ::
               (_t'50, tint) :: (_t'49, tint) :: (_t'48, tint) ::
               (_t'47, tint) :: (_t'46, tint) :: (_t'45, tint) ::
               (_t'44, tint) :: (_t'43, tint) :: (_t'42, tint) ::
               (_t'41, tint) :: (_t'40, tint) :: (_t'39, tint) ::
               (_t'38, tint) :: (_t'37, tint) :: (_t'36, tint) ::
               (_t'35, tint) :: (_t'34, tint) :: (_t'33, tint) ::
               (_t'32, tint) :: (_t'31, tint) :: (_t'30, tint) ::
               (_t'29, tint) :: (_t'28, tint) :: (_t'27, tint) ::
               (_t'26, tint) :: (_t'25, tint) :: (_t'24, tint) ::
               (_t'23, tint) :: (_t'22, tint) :: (_t'21, tint) ::
               (_t'20, tint) :: (_t'19, tint) :: (_t'18, tint) ::
               (_t'17, tint) :: (_t'16, tint) :: (_t'15, tint) ::
               (_t'14, tint) :: (_t'13, tint) :: (_t'12, tint) ::
               (_t'11, tint) :: (_t'10, tint) :: (_t'9, tint) ::
               (_t'8, tint) :: (_t'7, tint) :: (_t'6, tint) ::
               (_t'5, tint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'55, tuint) ::
               (_t'54, tushort) :: (_t'53, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _check_for_instant_quicksand (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'55
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _action tuint))
      (Sswitch (Etempvar _t'55 tuint)
        (LScons (Some 4864)
          (Ssequence
            (Ssequence
              (Scall (Some _t'2)
                (Evar _act_disappeared (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sset _cancel (Etempvar _t'2 tint)))
            Sbreak)
          (LScons (Some 67113729)
            (Ssequence
              (Ssequence
                (Scall (Some _t'3)
                  (Evar _act_intro_cutscene (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Sset _cancel (Etempvar _t'3 tint)))
              Sbreak)
            (LScons (Some 4866)
              (Ssequence
                (Ssequence
                  (Scall (Some _t'4)
                    (Evar _act_star_dance (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Sset _cancel (Etempvar _t'4 tint)))
                Sbreak)
              (LScons (Some 4871)
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'5)
                      (Evar _act_star_dance (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Sset _cancel (Etempvar _t'5 tint)))
                  Sbreak)
                (LScons (Some 4867)
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'6)
                        (Evar _act_star_dance_water (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       nil) tint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      (Sset _cancel (Etempvar _t'6 tint)))
                    Sbreak)
                  (LScons (Some 6404)
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'7)
                          (Evar _act_fall_after_star_grab (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             nil) tint
                                                            cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        (Sset _cancel (Etempvar _t'7 tint)))
                      Sbreak)
                    (LScons (Some 536875781)
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'8)
                            (Evar _act_reading_automatic_dialog (Tfunction
                                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                                   nil) tint
                                                                  cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             nil))
                          (Sset _cancel (Etempvar _t'8 tint)))
                        Sbreak)
                      (LScons (Some 536875782)
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'9)
                              (Evar _act_reading_npc_dialog (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               nil) tint
                                                              cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               nil))
                            (Sset _cancel (Etempvar _t'9 tint)))
                          Sbreak)
                        (LScons (Some 4879)
                          (Ssequence
                            (Ssequence
                              (Scall (Some _t'10)
                                (Evar _act_debug_free_move (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              nil) tint
                                                             cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 nil))
                              (Sset _cancel (Etempvar _t'10 tint)))
                            Sbreak)
                          (LScons (Some 4872)
                            (Ssequence
                              (Ssequence
                                (Scall (Some _t'11)
                                  (Evar _act_reading_sign (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             nil) tint
                                                            cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   nil))
                                (Sset _cancel (Etempvar _t'11 tint)))
                              Sbreak)
                            (LScons (Some 6409)
                              (Ssequence
                                (Ssequence
                                  (Scall (Some _t'12)
                                    (Evar _act_jumbo_star_cutscene (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     nil))
                                  (Sset _cancel (Etempvar _t'12 tint)))
                                Sbreak)
                              (LScons (Some 4874)
                                (Ssequence
                                  (Ssequence
                                    (Scall (Some _t'13)
                                      (Evar _act_waiting_for_dialog (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                       nil))
                                    (Sset _cancel (Etempvar _t'13 tint)))
                                  Sbreak)
                                (LScons (Some 135953)
                                  (Ssequence
                                    (Ssequence
                                      (Scall (Some _t'14)
                                        (Evar _act_standing_death (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                         nil))
                                      (Sset _cancel (Etempvar _t'14 tint)))
                                    Sbreak)
                                  (LScons (Some 135954)
                                    (Ssequence
                                      (Ssequence
                                        (Scall (Some _t'15)
                                          (Evar _act_quicksand_death 
                                          (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
                                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                           nil))
                                        (Sset _cancel (Etempvar _t'15 tint)))
                                      Sbreak)
                                    (LScons (Some 135955)
                                      (Ssequence
                                        (Ssequence
                                          (Scall (Some _t'16)
                                            (Evar _act_electrocution 
                                            (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
                                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                             nil))
                                          (Sset _cancel
                                            (Etempvar _t'16 tint)))
                                        Sbreak)
                                      (LScons (Some 135956)
                                        (Ssequence
                                          (Ssequence
                                            (Scall (Some _t'17)
                                              (Evar _act_suffocation 
                                              (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tint cc_default))
                                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                               nil))
                                            (Sset _cancel
                                              (Etempvar _t'17 tint)))
                                          Sbreak)
                                        (LScons (Some 135957)
                                          (Ssequence
                                            (Ssequence
                                              (Scall (Some _t'18)
                                                (Evar _act_death_on_stomach 
                                                (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tint cc_default))
                                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                 nil))
                                              (Sset _cancel
                                                (Etempvar _t'18 tint)))
                                            Sbreak)
                                          (LScons (Some 135958)
                                            (Ssequence
                                              (Ssequence
                                                (Scall (Some _t'19)
                                                  (Evar _act_death_on_back 
                                                  (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                   nil))
                                                (Sset _cancel
                                                  (Etempvar _t'19 tint)))
                                              Sbreak)
                                            (LScons (Some 135959)
                                              (Ssequence
                                                (Ssequence
                                                  (Scall (Some _t'20)
                                                    (Evar _act_eaten_by_bubba 
                                                    (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       nil) tint cc_default))
                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                     nil))
                                                  (Sset _cancel
                                                    (Etempvar _t'20 tint)))
                                                Sbreak)
                                              (LScons (Some 6424)
                                                (Ssequence
                                                  (Ssequence
                                                    (Scall (Some _t'21)
                                                      (Evar _act_end_peach_cutscene 
                                                      (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tint
                                                        cc_default))
                                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                       nil))
                                                    (Sset _cancel
                                                      (Etempvar _t'21 tint)))
                                                  Sbreak)
                                                (LScons (Some 4889)
                                                  (Ssequence
                                                    (Ssequence
                                                      (Scall (Some _t'22)
                                                        (Evar _act_credits_cutscene 
                                                        (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           nil) tint
                                                          cc_default))
                                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                         nil))
                                                      (Sset _cancel
                                                        (Etempvar _t'22 tint)))
                                                    Sbreak)
                                                  (LScons (Some 4890)
                                                    (Ssequence
                                                      (Ssequence
                                                        (Scall (Some _t'23)
                                                          (Evar _act_end_waving_cutscene 
                                                          (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             nil) tint
                                                            cc_default))
                                                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                           nil))
                                                        (Sset _cancel
                                                          (Etempvar _t'23 tint)))
                                                      Sbreak)
                                                    (LScons (Some 4896)
                                                      Sskip
                                                      (LScons (Some 4897)
                                                        (Ssequence
                                                          (Ssequence
                                                            (Scall (Some _t'24)
                                                              (Evar _act_going_through_door 
                                                              (Tfunction
                                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                                 nil) tint
                                                                cc_default))
                                                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                               nil))
                                                            (Sset _cancel
                                                              (Etempvar _t'24 tint)))
                                                          Sbreak)
                                                        (LScons (Some 4898)
                                                          (Ssequence
                                                            (Ssequence
                                                              (Scall (Some _t'25)
                                                                (Evar _act_warp_door_spawn 
                                                                (Tfunction
                                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                                   nil) tint
                                                                  cc_default))
                                                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                 nil))
                                                              (Sset _cancel
                                                                (Etempvar _t'25 tint)))
                                                            Sbreak)
                                                          (LScons (Some 6435)
                                                            (Ssequence
                                                              (Ssequence
                                                                (Scall (Some _t'26)
                                                                  (Evar _act_emerge_from_pipe 
                                                                  (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                   nil))
                                                                (Sset _cancel
                                                                  (Etempvar _t'26 tint)))
                                                              Sbreak)
                                                            (LScons (Some 6436)
                                                              (Ssequence
                                                                (Ssequence
                                                                  (Scall (Some _t'27)
                                                                    (Evar _act_spawn_spin_airborne 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                  (Sset _cancel
                                                                    (Etempvar _t'27 tint)))
                                                                Sbreak)
                                                              (LScons (Some 4901)
                                                                (Ssequence
                                                                  (Ssequence
                                                                    (Scall (Some _t'28)
                                                                    (Evar _act_spawn_spin_landing 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'28 tint)))
                                                                  Sbreak)
                                                                (LScons (Some 6438)
                                                                  (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'29)
                                                                    (Evar _act_exit_airborne 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'29 tint)))
                                                                    Sbreak)
                                                                  (LScons (Some 4903)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'30)
                                                                    (Evar _act_exit_land_save_dialog 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'30 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 6440)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'31)
                                                                    (Evar _act_death_exit 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'31 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 6441)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'32)
                                                                    (Evar _act_unused_death_exit 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'32 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 6442)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'33)
                                                                    (Evar _act_falling_death_exit 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'33 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 6443)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'34)
                                                                    (Evar _act_special_exit_airborne 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'34 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 6444)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'35)
                                                                    (Evar _act_special_death_exit 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'35 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 6445)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'36)
                                                                    (Evar _act_falling_exit_airborne 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'36 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 4910)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'37)
                                                                    (Evar _act_unlocking_key_door 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'37 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 4911)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'38)
                                                                    (Evar _act_unlocking_star_door 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'38 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 4913)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'39)
                                                                    (Evar _act_entering_star_door 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'39 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 6450)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'40)
                                                                    (Evar _act_spawn_no_spin_airborne 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'40 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 4915)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'41)
                                                                    (Evar _act_spawn_no_spin_landing 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'41 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 6452)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'42)
                                                                    (Evar _act_bbh_enter_jump 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'42 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 5429)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'43)
                                                                    (Evar _act_bbh_enter_spin 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'43 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 4918)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'44)
                                                                    (Evar _act_teleport_fade_out 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'44 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 4919)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'45)
                                                                    (Evar _act_teleport_fade_in 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'45 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 131896)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'46)
                                                                    (Evar _act_shocked 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'46 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 131897)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'47)
                                                                    (Evar _act_squished 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'47 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 131898)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'48)
                                                                    (Evar _act_head_stuck_in_ground 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'48 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 131899)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'49)
                                                                    (Evar _act_butt_stuck_in_ground 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'49 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 131900)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'50)
                                                                    (Evar _act_feet_stuck_in_ground 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'50 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 4925)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'51)
                                                                    (Evar _act_putting_on_cap 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'51 tint)))
                                                                    Sbreak)
                                                                    LSnil)))))))))))))))))))))))))))))))))))))))))))))))))))))
    (Ssequence
      (Ssequence
        (Sifthenelse (Eunop Onotbool (Etempvar _cancel tint) tint)
          (Ssequence
            (Sset _t'54
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _input tushort))
            (Sset _t'52
              (Ecast
                (Ebinop Oand (Etempvar _t'54 tushort)
                  (Econst_int (Int.repr 512) tint) tint) tbool)))
          (Sset _t'52 (Econst_int (Int.repr 0) tint)))
        (Sifthenelse (Etempvar _t'52 tint)
          (Ssequence
            (Sset _t'53
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _particleFlags tuint))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _particleFlags tuint)
              (Ebinop Oor (Etempvar _t'53 tuint)
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 7) tint) tint) tuint)))
          Sskip))
      (Sreturn (Some (Etempvar _cancel tint))))))
|}.

Definition composites : list composite_definition :=
(Composite __282 Struct
   (Member_plain _type tushort :: Member_plain _status tuchar ::
    Member_plain _errnum tuchar :: nil)
   noattr ::
 Composite __284 Struct
   (Member_plain _button tushort :: Member_plain _stick_x tschar ::
    Member_plain _stick_y tschar :: Member_plain _errnum tuchar :: nil)
   noattr ::
 Composite __434 Struct
   (Member_plain _flag tuchar :: Member_plain _v (tarray tuchar 3) :: nil)
   noattr ::
 Composite __439 Struct
   (Member_plain _vscale (tarray tshort 4) ::
    Member_plain _vtrans (tarray tshort 4) :: nil)
   noattr ::
 Composite __441 Union
   (Member_plain _vp (Tstruct __439 noattr) ::
    Member_plain _force_structure_alignment tlong :: nil)
   noattr ::
 Composite __475 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _par I32 Unsigned noattr 8 false ::
    Member_bitfield _len I32 Unsigned noattr 16 false ::
    Member_plain _addr tuint :: nil)
   noattr ::
 Composite __477 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad I32 Signed noattr 24 false ::
    Member_plain _tri (Tstruct __434 noattr) :: nil)
   noattr ::
 Composite __479 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad1 I32 Signed noattr 24 false ::
    Member_bitfield _pad2 I32 Signed noattr 24 false ::
    Member_bitfield _param I8 Unsigned noattr 8 false :: nil)
   noattr ::
 Composite __481 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad0 I32 Signed noattr 8 false ::
    Member_bitfield _mw_index I32 Signed noattr 8 false ::
    Member_bitfield _number I32 Signed noattr 8 false ::
    Member_bitfield _pad1 I32 Signed noattr 8 false ::
    Member_bitfield _base I32 Signed noattr 24 false :: nil)
   noattr ::
 Composite __483 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad0 I32 Signed noattr 8 false ::
    Member_bitfield _sft I32 Signed noattr 8 false ::
    Member_bitfield _len I32 Signed noattr 8 false ::
    Member_bitfield _data I32 Unsigned noattr 32 false :: nil)
   noattr ::
 Composite __485 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad0 I32 Signed noattr 8 false ::
    Member_bitfield _sft I32 Signed noattr 8 false ::
    Member_bitfield _len I32 Signed noattr 8 false ::
    Member_bitfield _data I32 Unsigned noattr 32 false :: nil)
   noattr ::
 Composite __487 Struct
   (Member_plain _cmd tuchar :: Member_plain _lodscale tuchar ::
    Member_plain _tile tuchar :: Member_plain _on tuchar ::
    Member_plain _s tushort :: Member_plain _t tushort :: nil)
   noattr ::
 Composite __489 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad I32 Signed noattr 24 false ::
    Member_plain _line (Tstruct __434 noattr) :: nil)
   noattr ::
 Composite __491 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad1 I32 Signed noattr 24 false ::
    Member_plain _pad2 tshort :: Member_plain _scale tshort :: nil)
   noattr ::
 Composite __493 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _fmt I32 Unsigned noattr 3 false ::
    Member_bitfield _siz I32 Unsigned noattr 2 false ::
    Member_bitfield _pad I32 Unsigned noattr 7 false ::
    Member_bitfield _wd I32 Unsigned noattr 12 false ::
    Member_plain _dram tuint :: nil)
   noattr ::
 Composite __495 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _muxs0 I32 Unsigned noattr 24 false ::
    Member_bitfield _muxs1 I32 Unsigned noattr 32 false :: nil)
   noattr ::
 Composite __497 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_plain _pad tuchar :: Member_plain _prim_min_level tuchar ::
    Member_plain _prim_level tuchar :: Member_plain _color tulong :: nil)
   noattr ::
 Composite __499 Struct
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
 Composite __501 Struct
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
 Composite __503 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _sl I32 Unsigned noattr 12 false ::
    Member_bitfield _tl I32 Unsigned noattr 12 false ::
    Member_bitfield _pad I32 Signed noattr 5 false ::
    Member_bitfield _tile I32 Unsigned noattr 3 false ::
    Member_bitfield _sh I32 Unsigned noattr 12 false ::
    Member_bitfield _th I32 Unsigned noattr 12 false :: nil)
   noattr ::
 Composite __512 Struct
   (Member_plain _w0 tuint :: Member_plain _w1 tuint :: nil)
   noattr ::
 Composite __514 Union
   (Member_plain _words (Tstruct __512 noattr) ::
    Member_plain _dma (Tstruct __475 noattr) ::
    Member_plain _tri (Tstruct __477 noattr) ::
    Member_plain _line (Tstruct __489 noattr) ::
    Member_plain _popmtx (Tstruct __479 noattr) ::
    Member_plain _segment (Tstruct __481 noattr) ::
    Member_plain _setothermodeH (Tstruct __485 noattr) ::
    Member_plain _setothermodeL (Tstruct __483 noattr) ::
    Member_plain _texture (Tstruct __487 noattr) ::
    Member_plain _perspnorm (Tstruct __491 noattr) ::
    Member_plain _setimg (Tstruct __493 noattr) ::
    Member_plain _setcombine (Tstruct __495 noattr) ::
    Member_plain _setcolor (Tstruct __497 noattr) ::
    Member_plain _fillrect (Tstruct __499 noattr) ::
    Member_plain _settile (Tstruct __501 noattr) ::
    Member_plain _loadtile (Tstruct __503 noattr) ::
    Member_plain _settilesize (Tstruct __503 noattr) ::
    Member_plain _loadtlut (Tstruct __503 noattr) ::
    Member_plain _force_structure_alignment tlong :: nil)
   noattr ::
 Composite _Controller Struct
   (Member_plain _rawStickX tshort :: Member_plain _rawStickY tshort ::
    Member_plain _stickX tfloat :: Member_plain _stickY tfloat ::
    Member_plain _stickMag tfloat :: Member_plain _buttonDown tushort ::
    Member_plain _buttonPressed tushort ::
    Member_plain _statusData (tptr (Tstruct __282 noattr)) ::
    Member_plain _controllerData (tptr (Tstruct __284 noattr)) :: nil)
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
 Composite __729 Union
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
    Member_plain _rawData (Tunion __729 noattr) ::
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
 Composite __734 Struct
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
    Member_plain _normal (Tstruct __734 noattr) ::
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
 Composite _FnGraphNode Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _func
      (tptr (Tfunction
              (tint :: (tptr (Tstruct _GraphNode noattr)) :: (tptr tvoid) ::
               nil) (tptr (Tunion __514 noattr)) cc_default)) :: nil)
   noattr ::
 Composite _GraphNodeRoot Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _areaIndex tuchar :: Member_plain _unk15 tschar ::
    Member_plain _x tshort :: Member_plain _y tshort ::
    Member_plain _width tshort :: Member_plain _height tshort ::
    Member_plain _numViews tshort ::
    Member_plain _views (tptr (tptr (Tstruct _GraphNode noattr))) :: nil)
   noattr ::
 Composite _GraphNodeSwitchCase Struct
   (Member_plain _fnNode (Tstruct _FnGraphNode noattr) ::
    Member_plain _unused tint :: Member_plain _numCases tshort ::
    Member_plain _selectedCase tshort :: nil)
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
 Composite _WarpNode Struct
   (Member_plain _id tuchar :: Member_plain _destLevel tuchar ::
    Member_plain _destArea tuchar :: Member_plain _destNode tuchar :: nil)
   noattr ::
 Composite _ObjectWarpNode Struct
   (Member_plain _node (Tstruct _WarpNode noattr) ::
    Member_plain _object (tptr (Tstruct _Object noattr)) ::
    Member_plain _next (tptr (Tstruct _ObjectWarpNode noattr)) :: nil)
   noattr ::
 Composite _InstantWarp Struct
   (Member_plain _id tuchar :: Member_plain _area tuchar ::
    Member_plain _displacement (tarray tshort 3) :: nil)
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
 Composite _UnusedArea28 Struct
   (Member_plain _unk00 tshort :: Member_plain _unk02 tshort ::
    Member_plain _unk04 tshort :: Member_plain _unk06 tshort ::
    Member_plain _unk08 tshort :: nil)
   noattr ::
 Composite _Whirlpool Struct
   (Member_plain _pos (tarray tshort 3) :: Member_plain _strength tshort ::
    nil)
   noattr ::
 Composite _Area Struct
   (Member_plain _index tschar :: Member_plain _flags tschar ::
    Member_plain _terrainType tushort ::
    Member_plain _unk04 (tptr (Tstruct _GraphNodeRoot noattr)) ::
    Member_plain _terrainData (tptr tshort) ::
    Member_plain _surfaceRooms (tptr tschar) ::
    Member_plain _macroObjects (tptr tshort) ::
    Member_plain _warpNodes (tptr (Tstruct _ObjectWarpNode noattr)) ::
    Member_plain _paintingWarpNodes (tptr (Tstruct _WarpNode noattr)) ::
    Member_plain _instantWarps (tptr (Tstruct _InstantWarp noattr)) ::
    Member_plain _objectSpawnInfos (tptr (Tstruct _SpawnInfo noattr)) ::
    Member_plain _camera (tptr (Tstruct _Camera noattr)) ::
    Member_plain _unused (tptr (Tstruct _UnusedArea28 noattr)) ::
    Member_plain _whirlpools (tarray (tptr (Tstruct _Whirlpool noattr)) 2) ::
    Member_plain _dialog (tarray tuchar 2) ::
    Member_plain _musicParam tushort :: Member_plain _musicParam2 tushort ::
    nil)
   noattr ::
 Composite _CreditsEntry Struct
   (Member_plain _levelNum tuchar :: Member_plain _areaIndex tuchar ::
    Member_plain _unk02 tuchar :: Member_plain _marioAngle tschar ::
    Member_plain _marioPos (tarray tshort 3) ::
    Member_plain _unk0C (tptr (tptr tschar)) :: nil)
   noattr ::
 Composite _HudDisplay Struct
   (Member_plain _lives tshort :: Member_plain _coins tshort ::
    Member_plain _stars tshort :: Member_plain _wedges tshort ::
    Member_plain _keys tshort :: Member_plain _flags tshort ::
    Member_plain _timer tushort :: nil)
   noattr ::
 Composite _ChainSegment Struct
   (Member_plain _posX tfloat :: Member_plain _posY tfloat ::
    Member_plain _posZ tfloat :: Member_plain _pitch tshort ::
    Member_plain _yaw tshort :: Member_plain _roll tshort :: nil)
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
 (_sqrtf,
   Gfun(External (EF_external "sqrtf"
                   (mksignature (AST.Xsingle :: nil) AST.Xsingle cc_default))
     (tfloat :: nil) tfloat cc_default)) ::
 (_gAreaUpdateCounter, Gvar v_gAreaUpdateCounter) ::
 (_gCameraMovementFlags, Gvar v_gCameraMovementFlags) ::
 (_gCamera, Gvar v_gCamera) :: (_gCutsceneFocus, Gvar v_gCutsceneFocus) ::
 (_set_camera_shake_from_hit,
   Gfun(External (EF_external "set_camera_shake_from_hit"
                   (mksignature (AST.Xint16signed :: nil) AST.Xvoid
                     cc_default)) (tshort :: nil) tvoid cc_default)) ::
 (_set_camera_mode,
   Gfun(External (EF_external "set_camera_mode"
                   (mksignature
                     (AST.Xptr :: AST.Xint16signed :: AST.Xint16signed ::
                      nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _Camera noattr)) :: tshort :: tshort :: nil) tvoid
     cc_default)) ::
 (_camera_approach_f32_symmetric,
   Gfun(External (EF_external "camera_approach_f32_symmetric"
                   (mksignature
                     (AST.Xsingle :: AST.Xsingle :: AST.Xsingle :: nil)
                     AST.Xsingle cc_default))
     (tfloat :: tfloat :: tfloat :: nil) tfloat cc_default)) ::
 (_trigger_cutscene_dialog,
   Gfun(External (EF_external "trigger_cutscene_dialog"
                   (mksignature (AST.Xint :: nil) AST.Xint cc_default))
     (tint :: nil) tint cc_default)) ::
 (_gCurrAreaIndex, Gvar v_gCurrAreaIndex) ::
 (_gSaveOptSelectIndex, Gvar v_gSaveOptSelectIndex) ::
 (_gCurrSaveFileNum, Gvar v_gCurrSaveFileNum) ::
 (_gCurrLevelNum, Gvar v_gCurrLevelNum) ::
 (_override_viewport_and_clip,
   Gfun(External (EF_external "override_viewport_and_clip"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xint8unsigned ::
                      AST.Xint8unsigned :: AST.Xint8unsigned :: nil)
                     AST.Xvoid cc_default))
     ((tptr (Tunion __441 noattr)) :: (tptr (Tunion __441 noattr)) ::
      tuchar :: tuchar :: tuchar :: nil) tvoid cc_default)) ::
 (_play_transition,
   Gfun(External (EF_external "play_transition"
                   (mksignature
                     (AST.Xint16signed :: AST.Xint16signed ::
                      AST.Xint8unsigned :: AST.Xint8unsigned ::
                      AST.Xint8unsigned :: nil) AST.Xvoid cc_default))
     (tshort :: tshort :: tuchar :: tuchar :: tuchar :: nil) tvoid
     cc_default)) :: (_gGlobalSoundSource, Gvar v_gGlobalSoundSource) ::
 (_gAudioRandom, Gvar v_gAudioRandom) ::
 (_play_sound,
   Gfun(External (EF_external "play_sound"
                   (mksignature (AST.Xint :: AST.Xptr :: nil) AST.Xvoid
                     cc_default)) (tint :: (tptr tfloat) :: nil) tvoid
     cc_default)) ::
 (_seq_player_lower_volume,
   Gfun(External (EF_external "seq_player_lower_volume"
                   (mksignature
                     (AST.Xint8unsigned :: AST.Xint16unsigned ::
                      AST.Xint8unsigned :: nil) AST.Xvoid cc_default))
     (tuchar :: tushort :: tuchar :: nil) tvoid cc_default)) ::
 (_seq_player_unlower_volume,
   Gfun(External (EF_external "seq_player_unlower_volume"
                   (mksignature
                     (AST.Xint8unsigned :: AST.Xint16unsigned :: nil)
                     AST.Xvoid cc_default)) (tuchar :: tushort :: nil) tvoid
     cc_default)) ::
 (_sound_banks_enable,
   Gfun(External (EF_external "sound_banks_enable"
                   (mksignature
                     (AST.Xint8unsigned :: AST.Xint16unsigned :: nil)
                     AST.Xvoid cc_default)) (tuchar :: tushort :: nil) tvoid
     cc_default)) ::
 (_play_music,
   Gfun(External (EF_external "play_music"
                   (mksignature
                     (AST.Xint8unsigned :: AST.Xint16unsigned ::
                      AST.Xint16unsigned :: nil) AST.Xvoid cc_default))
     (tuchar :: tushort :: tushort :: nil) tvoid cc_default)) ::
 (_play_course_clear,
   Gfun(External (EF_external "play_course_clear"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_play_peachs_jingle,
   Gfun(External (EF_external "play_peachs_jingle"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) :: (_bhvEndToad, Gvar v_bhvEndToad) ::
 (_bhvEndPeach, Gvar v_bhvEndPeach) ::
 (_bhvBowserKeyUnlockDoor, Gvar v_bhvBowserKeyUnlockDoor) ::
 (_bhvBowserKeyCourseExit, Gvar v_bhvBowserKeyCourseExit) ::
 (_bhvStaticObject, Gvar v_bhvStaticObject) ::
 (_bhvSparkleSpawn, Gvar v_bhvSparkleSpawn) ::
 (_bhvUnlockDoorStar, Gvar v_bhvUnlockDoorStar) ::
 (_bhvCelebrationStar, Gvar v_bhvCelebrationStar) ::
 (_gSineTable, Gvar v_gSineTable) ::
 (_vec3f_copy,
   Gfun(External (EF_external "vec3f_copy"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xptr
                     cc_default)) ((tptr tfloat) :: (tptr tfloat) :: nil)
     (tptr tvoid) cc_default)) ::
 (_vec3f_set,
   Gfun(External (EF_external "vec3f_set"
                   (mksignature
                     (AST.Xptr :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xsingle :: nil) AST.Xptr cc_default))
     ((tptr tfloat) :: tfloat :: tfloat :: tfloat :: nil) (tptr tvoid)
     cc_default)) ::
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
     cc_default)) ::
 (_approach_s32,
   Gfun(External (EF_external "approach_s32"
                   (mksignature
                     (AST.Xint :: AST.Xint :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint cc_default))
     (tint :: tint :: tint :: tint :: nil) tint cc_default)) ::
 (_atan2s,
   Gfun(External (EF_external "atan2s"
                   (mksignature (AST.Xsingle :: AST.Xsingle :: nil)
                     AST.Xint16signed cc_default)) (tfloat :: tfloat :: nil)
     tshort cc_default)) ::
 (_anim_spline_init,
   Gfun(External (EF_external "anim_spline_init"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (tarray tshort 4)) :: nil) tvoid cc_default)) ::
 (_anim_spline_poll,
   Gfun(External (EF_external "anim_spline_poll"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr tfloat) :: nil) tint cc_default)) ::
 (_find_floor,
   Gfun(External (EF_external "find_floor"
                   (mksignature
                     (AST.Xsingle :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xptr :: nil) AST.Xsingle cc_default))
     (tfloat :: tfloat :: tfloat ::
      (tptr (tptr (Tstruct _Surface noattr))) :: nil) tfloat cc_default)) ::
 (_gPlayer1Controller, Gvar v_gPlayer1Controller) ::
 (_gDialogResponse, Gvar v_gDialogResponse) ::
 (_get_dialog_id,
   Gfun(External (EF_external "get_dialog_id"
                   (mksignature nil AST.Xint16signed cc_default)) nil tshort
     cc_default)) ::
 (_create_dialog_box,
   Gfun(External (EF_external "create_dialog_box"
                   (mksignature (AST.Xint16signed :: nil) AST.Xvoid
                     cc_default)) (tshort :: nil) tvoid cc_default)) ::
 (_create_dialog_box_with_var,
   Gfun(External (EF_external "create_dialog_box_with_var"
                   (mksignature (AST.Xint16signed :: AST.Xint :: nil)
                     AST.Xvoid cc_default)) (tshort :: tint :: nil) tvoid
     cc_default)) ::
 (_create_dialog_inverted_box,
   Gfun(External (EF_external "create_dialog_inverted_box"
                   (mksignature (AST.Xint16signed :: nil) AST.Xvoid
                     cc_default)) (tshort :: nil) tvoid cc_default)) ::
 (_create_dialog_box_with_response,
   Gfun(External (EF_external "create_dialog_box_with_response"
                   (mksignature (AST.Xint16signed :: nil) AST.Xvoid
                     cc_default)) (tshort :: nil) tvoid cc_default)) ::
 (_set_menu_mode,
   Gfun(External (EF_external "set_menu_mode"
                   (mksignature (AST.Xint16signed :: nil) AST.Xvoid
                     cc_default)) (tshort :: nil) tvoid cc_default)) ::
 (_reset_cutscene_msg_fade,
   Gfun(External (EF_external "reset_cutscene_msg_fade"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_dl_rgba16_begin_cutscene_msg_fade,
   Gfun(External (EF_external "dl_rgba16_begin_cutscene_msg_fade"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_dl_rgba16_stop_cutscene_msg_fade,
   Gfun(External (EF_external "dl_rgba16_stop_cutscene_msg_fade"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_print_credits_str_ascii,
   Gfun(External (EF_external "print_credits_str_ascii"
                   (mksignature
                     (AST.Xint16signed :: AST.Xint16signed :: AST.Xptr ::
                      nil) AST.Xvoid cc_default))
     (tshort :: tshort :: (tptr tschar) :: nil) tvoid cc_default)) ::
 (_set_cutscene_message,
   Gfun(External (EF_external "set_cutscene_message"
                   (mksignature
                     (AST.Xint16signed :: AST.Xint16signed ::
                      AST.Xint16signed :: AST.Xint16signed :: nil) AST.Xvoid
                     cc_default))
     (tshort :: tshort :: tshort :: tshort :: nil) tvoid cc_default)) ::
 (_mario_obj_angle_to_object,
   Gfun(External (EF_external "mario_obj_angle_to_object"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil)
                     AST.Xint16signed cc_default))
     ((tptr (Tstruct _MarioState noattr)) ::
      (tptr (Tstruct _Object noattr)) :: nil) tshort cc_default)) ::
 (_get_door_save_file_flag,
   Gfun(External (EF_external "get_door_save_file_flag"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _Object noattr)) :: nil) tuint cc_default)) ::
 (_gCurrCreditsEntry, Gvar v_gCurrCreditsEntry) ::
 (_gMarioState, Gvar v_gMarioState) :: (_gHudDisplay, Gvar v_gHudDisplay) ::
 (_gNeverEnteredCastle, Gvar v_gNeverEnteredCastle) ::
 (_fade_into_special_warp,
   Gfun(External (EF_external "fade_into_special_warp"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xvoid
                     cc_default)) (tuint :: tuint :: nil) tvoid cc_default)) ::
 (_load_level_init_text,
   Gfun(External (EF_external "load_level_init_text"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tuint :: nil) tvoid cc_default)) ::
 (_level_trigger_warp,
   Gfun(External (EF_external "level_trigger_warp"
                   (mksignature (AST.Xptr :: AST.Xint :: nil)
                     AST.Xint16signed cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tint :: nil) tshort cc_default)) ::
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
 (_set_mario_anim_with_accel,
   Gfun(External (EF_external "set_mario_anim_with_accel"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint16signed cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tint :: tint :: nil) tshort
     cc_default)) ::
 (_set_anim_to_frame,
   Gfun(External (EF_external "set_anim_to_frame"
                   (mksignature (AST.Xptr :: AST.Xint16signed :: nil)
                     AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tshort :: nil) tvoid
     cc_default)) ::
 (_find_mario_anim_flags_and_translation,
   Gfun(External (EF_external "find_mario_anim_flags_and_translation"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xptr :: nil)
                     AST.Xint16signed cc_default))
     ((tptr (Tstruct _Object noattr)) :: tint :: (tptr tshort) :: nil) tshort
     cc_default)) ::
 (_update_mario_pos_for_anim,
   Gfun(External (EF_external "update_mario_pos_for_anim"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_play_sound_if_no_flag,
   Gfun(External (EF_external "play_sound_if_no_flag"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: tuint :: nil) tvoid
     cc_default)) ::
 (_play_mario_jump_sound,
   Gfun(External (EF_external "play_mario_jump_sound"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_play_sound_and_spawn_particles,
   Gfun(External (EF_external "play_sound_and_spawn_particles"
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
 (_play_mario_landing_sound,
   Gfun(External (EF_external "play_mario_landing_sound"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: nil) tvoid cc_default)) ::
 (_play_mario_landing_sound_once,
   Gfun(External (EF_external "play_mario_landing_sound_once"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: nil) tvoid cc_default)) ::
 (_play_mario_heavy_landing_sound,
   Gfun(External (EF_external "play_mario_heavy_landing_sound"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: nil) tvoid cc_default)) ::
 (_mario_set_forward_vel,
   Gfun(External (EF_external "mario_set_forward_vel"
                   (mksignature (AST.Xptr :: AST.Xsingle :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tfloat :: nil) tvoid
     cc_default)) ::
 (_resolve_and_return_wall_collisions,
   Gfun(External (EF_external "resolve_and_return_wall_collisions"
                   (mksignature
                     (AST.Xptr :: AST.Xsingle :: AST.Xsingle :: nil) AST.Xptr
                     cc_default)) ((tptr tfloat) :: tfloat :: tfloat :: nil)
     (tptr (Tstruct _Surface noattr)) cc_default)) ::
 (_update_mario_sound_and_camera,
   Gfun(External (EF_external "update_mario_sound_and_camera"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
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
 (_set_water_plunge_action,
   Gfun(External (EF_external "set_water_plunge_action"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_play_step_sound,
   Gfun(External (EF_external "play_step_sound"
                   (mksignature
                     (AST.Xptr :: AST.Xint16signed :: AST.Xint16signed ::
                      nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tshort :: tshort :: nil) tvoid
     cc_default)) ::
 (_stop_and_set_height_to_floor,
   Gfun(External (EF_external "stop_and_set_height_to_floor"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_stationary_ground_step,
   Gfun(External (EF_external "stationary_ground_step"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_perform_ground_step,
   Gfun(External (EF_external "perform_ground_step"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_perform_air_step,
   Gfun(External (EF_external "perform_air_step"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xint
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: nil) tint cc_default)) ::
 (_gPaintingMarioYEntry, Gvar v_gPaintingMarioYEntry) ::
 (_spawn_object_abs_with_rot,
   Gfun(External (EF_external "spawn_object_abs_with_rot"
                   (mksignature
                     (AST.Xptr :: AST.Xint16signed :: AST.Xint :: AST.Xptr ::
                      AST.Xint16signed :: AST.Xint16signed ::
                      AST.Xint16signed :: AST.Xint16signed ::
                      AST.Xint16signed :: AST.Xint16signed :: nil) AST.Xptr
                     cc_default))
     ((tptr (Tstruct _Object noattr)) :: tshort :: tuint :: (tptr tuint) ::
      tshort :: tshort :: tshort :: tshort :: tshort :: tshort :: nil)
     (tptr (Tstruct _Object noattr)) cc_default)) ::
 (_spawn_object,
   Gfun(External (EF_external "spawn_object"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xptr :: nil)
                     AST.Xptr cc_default))
     ((tptr (Tstruct _Object noattr)) :: tint :: (tptr tuint) :: nil)
     (tptr (Tstruct _Object noattr)) cc_default)) ::
 (_obj_scale,
   Gfun(External (EF_external "obj_scale"
                   (mksignature (AST.Xptr :: AST.Xsingle :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _Object noattr)) :: tfloat :: nil) tvoid cc_default)) ::
 (_cur_obj_init_animation_with_sound,
   Gfun(External (EF_external "cur_obj_init_animation_with_sound"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tint :: nil) tvoid cc_default)) ::
 (_cur_obj_check_if_near_animation_end,
   Gfun(External (EF_external "cur_obj_check_if_near_animation_end"
                   (mksignature nil AST.Xint cc_default)) nil tint
     cc_default)) ::
 (_obj_mark_for_deletion,
   Gfun(External (EF_external "obj_mark_for_deletion"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _Object noattr)) :: nil) tvoid cc_default)) ::
 (_enable_time_stop,
   Gfun(External (EF_external "enable_time_stop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_disable_time_stop,
   Gfun(External (EF_external "disable_time_stop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) :: (_gCurrentObject, Gvar v_gCurrentObject) ::
 (_gLastCompletedCourseNum, Gvar v_gLastCompletedCourseNum) ::
 (_gLastCompletedStarNum, Gvar v_gLastCompletedStarNum) ::
 (_save_file_do_save,
   Gfun(External (EF_external "save_file_do_save"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tint :: nil) tvoid cc_default)) ::
 (_save_file_set_flags,
   Gfun(External (EF_external "save_file_set_flags"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tuint :: nil) tvoid cc_default)) ::
 (_save_file_clear_flags,
   Gfun(External (EF_external "save_file_clear_flags"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tuint :: nil) tvoid cc_default)) ::
 (_disable_background_sound,
   Gfun(External (EF_external "disable_background_sound"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_enable_background_sound,
   Gfun(External (EF_external "enable_background_sound"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_play_cutscene_music,
   Gfun(External (EF_external "play_cutscene_music"
                   (mksignature (AST.Xint16unsigned :: nil) AST.Xvoid
                     cc_default)) (tushort :: nil) tvoid cc_default)) ::
 (_sIntroWarpPipeObj, Gvar v_sIntroWarpPipeObj) ::
 (_sEndPeachObj, Gvar v_sEndPeachObj) ::
 (_sEndRightToadObj, Gvar v_sEndRightToadObj) ::
 (_sEndLeftToadObj, Gvar v_sEndLeftToadObj) ::
 (_sEndJumboStarObj, Gvar v_sEndJumboStarObj) ::
 (_sEndPeachAnimation, Gvar v_sEndPeachAnimation) ::
 (_sEndToadAnims, Gvar v_sEndToadAnims) ::
 (_sEndCutsceneVp, Gvar v_sEndCutsceneVp) ::
 (_sDispCreditsEntry, Gvar v_sDispCreditsEntry) ::
 (_D_8032CBE4, Gvar v_D_8032CBE4) :: (_D_8032CBE8, Gvar v_D_8032CBE8) ::
 (_D_8032CBEC, Gvar v_D_8032CBEC) ::
 (_sStarsNeededForDialog, Gvar v_sStarsNeededForDialog) ::
 (_sJumboStarKeyframes, Gvar v_sJumboStarKeyframes) ::
 (_get_credits_str_width, Gfun(Internal f_get_credits_str_width)) ::
 (_print_displaying_credits_entry, Gfun(Internal f_print_displaying_credits_entry)) ::
 (_bhv_end_peach_loop, Gfun(Internal f_bhv_end_peach_loop)) ::
 (_bhv_end_toad_loop, Gfun(Internal f_bhv_end_toad_loop)) ::
 (_geo_switch_peach_eyes, Gfun(Internal f_geo_switch_peach_eyes)) ::
 (_get_star_collection_dialog, Gfun(Internal f_get_star_collection_dialog)) ::
 (_handle_save_menu, Gfun(Internal f_handle_save_menu)) ::
 (_spawn_obj_at_mario_rel_yaw, Gfun(Internal f_spawn_obj_at_mario_rel_yaw)) ::
 (_cutscene_take_cap_off, Gfun(Internal f_cutscene_take_cap_off)) ::
 (_cutscene_put_cap_on, Gfun(Internal f_cutscene_put_cap_on)) ::
 (_mario_ready_to_speak, Gfun(Internal f_mario_ready_to_speak)) ::
 (_set_mario_npc_dialog, Gfun(Internal f_set_mario_npc_dialog)) ::
 (_act_reading_npc_dialog, Gfun(Internal f_act_reading_npc_dialog)) ::
 (_act_waiting_for_dialog, Gfun(Internal f_act_waiting_for_dialog)) ::
 (_act_disappeared, Gfun(Internal f_act_disappeared)) ::
 (_act_reading_automatic_dialog, Gfun(Internal f_act_reading_automatic_dialog)) ::
 (_act_reading_sign, Gfun(Internal f_act_reading_sign)) ::
 (_act_debug_free_move, Gfun(Internal f_act_debug_free_move)) ::
 (_general_star_dance_handler, Gfun(Internal f_general_star_dance_handler)) ::
 (_act_star_dance, Gfun(Internal f_act_star_dance)) ::
 (_act_star_dance_water, Gfun(Internal f_act_star_dance_water)) ::
 (_act_fall_after_star_grab, Gfun(Internal f_act_fall_after_star_grab)) ::
 (_common_death_handler, Gfun(Internal f_common_death_handler)) ::
 (_act_standing_death, Gfun(Internal f_act_standing_death)) ::
 (_act_electrocution, Gfun(Internal f_act_electrocution)) ::
 (_act_suffocation, Gfun(Internal f_act_suffocation)) ::
 (_act_death_on_back, Gfun(Internal f_act_death_on_back)) ::
 (_act_death_on_stomach, Gfun(Internal f_act_death_on_stomach)) ::
 (_act_quicksand_death, Gfun(Internal f_act_quicksand_death)) ::
 (_act_eaten_by_bubba, Gfun(Internal f_act_eaten_by_bubba)) ::
 (_launch_mario_until_land, Gfun(Internal f_launch_mario_until_land)) ::
 (_act_unlocking_key_door, Gfun(Internal f_act_unlocking_key_door)) ::
 (_act_unlocking_star_door, Gfun(Internal f_act_unlocking_star_door)) ::
 (_act_entering_star_door, Gfun(Internal f_act_entering_star_door)) ::
 (_act_going_through_door, Gfun(Internal f_act_going_through_door)) ::
 (_act_warp_door_spawn, Gfun(Internal f_act_warp_door_spawn)) ::
 (_act_emerge_from_pipe, Gfun(Internal f_act_emerge_from_pipe)) ::
 (_act_spawn_spin_airborne, Gfun(Internal f_act_spawn_spin_airborne)) ::
 (_act_spawn_spin_landing, Gfun(Internal f_act_spawn_spin_landing)) ::
 (_act_exit_airborne, Gfun(Internal f_act_exit_airborne)) ::
 (_act_falling_exit_airborne, Gfun(Internal f_act_falling_exit_airborne)) ::
 (_act_exit_land_save_dialog, Gfun(Internal f_act_exit_land_save_dialog)) ::
 (_act_death_exit, Gfun(Internal f_act_death_exit)) ::
 (_act_unused_death_exit, Gfun(Internal f_act_unused_death_exit)) ::
 (_act_falling_death_exit, Gfun(Internal f_act_falling_death_exit)) ::
 (_act_special_exit_airborne, Gfun(Internal f_act_special_exit_airborne)) ::
 (_act_special_death_exit, Gfun(Internal f_act_special_death_exit)) ::
 (_act_spawn_no_spin_airborne, Gfun(Internal f_act_spawn_no_spin_airborne)) ::
 (_act_spawn_no_spin_landing, Gfun(Internal f_act_spawn_no_spin_landing)) ::
 (_act_bbh_enter_spin, Gfun(Internal f_act_bbh_enter_spin)) ::
 (_act_bbh_enter_jump, Gfun(Internal f_act_bbh_enter_jump)) ::
 (_act_teleport_fade_out, Gfun(Internal f_act_teleport_fade_out)) ::
 (_act_teleport_fade_in, Gfun(Internal f_act_teleport_fade_in)) ::
 (_act_shocked, Gfun(Internal f_act_shocked)) ::
 (_act_squished, Gfun(Internal f_act_squished)) ::
 (_act_putting_on_cap, Gfun(Internal f_act_putting_on_cap)) ::
 (_stuck_in_ground_handler, Gfun(Internal f_stuck_in_ground_handler)) ::
 (_act_head_stuck_in_ground, Gfun(Internal f_act_head_stuck_in_ground)) ::
 (_act_butt_stuck_in_ground, Gfun(Internal f_act_butt_stuck_in_ground)) ::
 (_act_feet_stuck_in_ground, Gfun(Internal f_act_feet_stuck_in_ground)) ::
 (_advance_cutscene_step, Gfun(Internal f_advance_cutscene_step)) ::
 (_intro_cutscene_hide_hud_and_mario, Gfun(Internal f_intro_cutscene_hide_hud_and_mario)) ::
 (_intro_cutscene_peach_lakitu_scene, Gfun(Internal f_intro_cutscene_peach_lakitu_scene)) ::
 (_intro_cutscene_raise_pipe, Gfun(Internal f_intro_cutscene_raise_pipe)) ::
 (_intro_cutscene_jump_out_of_pipe, Gfun(Internal f_intro_cutscene_jump_out_of_pipe)) ::
 (_intro_cutscene_land_outside_pipe, Gfun(Internal f_intro_cutscene_land_outside_pipe)) ::
 (_intro_cutscene_lower_pipe, Gfun(Internal f_intro_cutscene_lower_pipe)) ::
 (_intro_cutscene_set_mario_to_idle, Gfun(Internal f_intro_cutscene_set_mario_to_idle)) ::
 (_act_intro_cutscene, Gfun(Internal f_act_intro_cutscene)) ::
 (_jumbo_star_cutscene_falling, Gfun(Internal f_jumbo_star_cutscene_falling)) ::
 (_jumbo_star_cutscene_taking_off, Gfun(Internal f_jumbo_star_cutscene_taking_off)) ::
 (_jumbo_star_cutscene_flying, Gfun(Internal f_jumbo_star_cutscene_flying)) ::
 (_act_jumbo_star_cutscene, Gfun(Internal f_act_jumbo_star_cutscene)) ::
 (_sSparkleGenTheta, Gvar v_sSparkleGenTheta) ::
 (_sSparkleGenPhi, Gvar v_sSparkleGenPhi) ::
 (_generate_yellow_sparkles, Gfun(Internal f_generate_yellow_sparkles)) ::
 (_end_obj_set_visual_pos, Gfun(Internal f_end_obj_set_visual_pos)) ::
 (_end_peach_cutscene_mario_falling, Gfun(Internal f_end_peach_cutscene_mario_falling)) ::
 (_end_peach_cutscene_mario_landing, Gfun(Internal f_end_peach_cutscene_mario_landing)) ::
 (_end_peach_cutscene_summon_jumbo_star, Gfun(Internal f_end_peach_cutscene_summon_jumbo_star)) ::
 (_end_peach_cutscene_spawn_peach, Gfun(Internal f_end_peach_cutscene_spawn_peach)) ::
 (_end_peach_cutscene_descend_peach, Gfun(Internal f_end_peach_cutscene_descend_peach)) ::
 (_end_peach_cutscene_run_to_peach, Gfun(Internal f_end_peach_cutscene_run_to_peach)) ::
 (_end_peach_cutscene_dialog_1, Gfun(Internal f_end_peach_cutscene_dialog_1)) ::
 (_end_peach_cutscene_dialog_2, Gfun(Internal f_end_peach_cutscene_dialog_2)) ::
 (_sMarioBlinkOverride, Gvar v_sMarioBlinkOverride) ::
 (_end_peach_cutscene_kiss_from_peach, Gfun(Internal f_end_peach_cutscene_kiss_from_peach)) ::
 (_end_peach_cutscene_star_dance, Gfun(Internal f_end_peach_cutscene_star_dance)) ::
 (_end_peach_cutscene_dialog_3, Gfun(Internal f_end_peach_cutscene_dialog_3)) ::
 (_end_peach_cutscene_run_to_castle, Gfun(Internal f_end_peach_cutscene_run_to_castle)) ::
 (_end_peach_cutscene_fade_out, Gfun(Internal f_end_peach_cutscene_fade_out)) ::
 (_act_end_peach_cutscene, Gfun(Internal f_act_end_peach_cutscene)) ::
 (_act_credits_cutscene, Gfun(Internal f_act_credits_cutscene)) ::
 (_act_end_waving_cutscene, Gfun(Internal f_act_end_waving_cutscene)) ::
 (_check_for_instant_quicksand, Gfun(Internal f_check_for_instant_quicksand)) ::
 (_mario_execute_cutscene_action, Gfun(Internal f_mario_execute_cutscene_action)) ::
 nil).

Definition public_idents : list ident :=
(_mario_execute_cutscene_action :: _generate_yellow_sparkles ::
 _act_feet_stuck_in_ground :: _act_butt_stuck_in_ground ::
 _act_head_stuck_in_ground :: _stuck_in_ground_handler ::
 _act_putting_on_cap :: _act_squished :: _act_shocked ::
 _act_teleport_fade_in :: _act_teleport_fade_out :: _act_bbh_enter_jump ::
 _act_bbh_enter_spin :: _act_spawn_no_spin_landing ::
 _act_spawn_no_spin_airborne :: _act_special_death_exit ::
 _act_special_exit_airborne :: _act_falling_death_exit ::
 _act_unused_death_exit :: _act_death_exit :: _act_exit_land_save_dialog ::
 _act_falling_exit_airborne :: _act_exit_airborne ::
 _act_spawn_spin_landing :: _act_spawn_spin_airborne ::
 _act_emerge_from_pipe :: _act_warp_door_spawn :: _act_going_through_door ::
 _act_entering_star_door :: _act_unlocking_star_door ::
 _act_unlocking_key_door :: _launch_mario_until_land ::
 _act_eaten_by_bubba :: _act_quicksand_death :: _act_death_on_stomach ::
 _act_death_on_back :: _act_suffocation :: _act_electrocution ::
 _act_standing_death :: _common_death_handler :: _act_fall_after_star_grab ::
 _act_star_dance_water :: _act_star_dance :: _general_star_dance_handler ::
 _act_debug_free_move :: _act_reading_sign ::
 _act_reading_automatic_dialog :: _act_disappeared ::
 _act_waiting_for_dialog :: _act_reading_npc_dialog ::
 _set_mario_npc_dialog :: _mario_ready_to_speak :: _cutscene_put_cap_on ::
 _cutscene_take_cap_off :: _spawn_obj_at_mario_rel_yaw ::
 _handle_save_menu :: _get_star_collection_dialog ::
 _geo_switch_peach_eyes :: _bhv_end_toad_loop :: _bhv_end_peach_loop ::
 _print_displaying_credits_entry :: _get_credits_str_width ::
 _play_cutscene_music :: _enable_background_sound ::
 _disable_background_sound :: _save_file_clear_flags ::
 _save_file_set_flags :: _save_file_do_save :: _gLastCompletedStarNum ::
 _gLastCompletedCourseNum :: _gCurrentObject :: _disable_time_stop ::
 _enable_time_stop :: _obj_mark_for_deletion ::
 _cur_obj_check_if_near_animation_end ::
 _cur_obj_init_animation_with_sound :: _obj_scale :: _spawn_object ::
 _spawn_object_abs_with_rot :: _gPaintingMarioYEntry :: _perform_air_step ::
 _perform_ground_step :: _stationary_ground_step ::
 _stop_and_set_height_to_floor :: _play_step_sound ::
 _set_water_plunge_action :: _drop_and_set_mario_action ::
 _set_mario_action :: _update_mario_sound_and_camera ::
 _resolve_and_return_wall_collisions :: _mario_set_forward_vel ::
 _play_mario_heavy_landing_sound :: _play_mario_landing_sound_once ::
 _play_mario_landing_sound :: _play_mario_action_sound ::
 _play_sound_and_spawn_particles :: _play_mario_jump_sound ::
 _play_sound_if_no_flag :: _update_mario_pos_for_anim ::
 _find_mario_anim_flags_and_translation :: _set_anim_to_frame ::
 _set_mario_anim_with_accel :: _set_mario_animation :: _is_anim_past_end ::
 _is_anim_at_end :: _level_trigger_warp :: _load_level_init_text ::
 _fade_into_special_warp :: _gNeverEnteredCastle :: _gHudDisplay ::
 _gMarioState :: _gCurrCreditsEntry :: _get_door_save_file_flag ::
 _mario_obj_angle_to_object :: _set_cutscene_message ::
 _print_credits_str_ascii :: _dl_rgba16_stop_cutscene_msg_fade ::
 _dl_rgba16_begin_cutscene_msg_fade :: _reset_cutscene_msg_fade ::
 _set_menu_mode :: _create_dialog_box_with_response ::
 _create_dialog_inverted_box :: _create_dialog_box_with_var ::
 _create_dialog_box :: _get_dialog_id :: _gDialogResponse ::
 _gPlayer1Controller :: _find_floor :: _anim_spline_poll ::
 _anim_spline_init :: _atan2s :: _approach_s32 :: _vec3s_set ::
 _vec3s_copy :: _vec3f_set :: _vec3f_copy :: _gSineTable ::
 _bhvCelebrationStar :: _bhvUnlockDoorStar :: _bhvSparkleSpawn ::
 _bhvStaticObject :: _bhvBowserKeyCourseExit :: _bhvBowserKeyUnlockDoor ::
 _bhvEndPeach :: _bhvEndToad :: _play_peachs_jingle :: _play_course_clear ::
 _play_music :: _sound_banks_enable :: _seq_player_unlower_volume ::
 _seq_player_lower_volume :: _play_sound :: _gAudioRandom ::
 _gGlobalSoundSource :: _play_transition :: _override_viewport_and_clip ::
 _gCurrLevelNum :: _gCurrSaveFileNum :: _gSaveOptSelectIndex ::
 _gCurrAreaIndex :: _trigger_cutscene_dialog ::
 _camera_approach_f32_symmetric :: _set_camera_mode ::
 _set_camera_shake_from_hit :: _gCutsceneFocus :: _gCamera ::
 _gCameraMovementFlags :: _gAreaUpdateCounter :: _sqrtf ::
 ___builtin_debug :: ___builtin_write32_reversed ::
 ___builtin_write16_reversed :: ___builtin_read32_reversed ::
 ___builtin_read16_reversed :: ___builtin_fnmsub :: ___builtin_fnmadd ::
 ___builtin_fmsub :: ___builtin_fmadd :: ___builtin_fmin ::
 ___builtin_fmax :: ___builtin_expect :: ___builtin_unreachable ::
 ___builtin_va_end :: ___builtin_va_copy :: ___builtin_va_arg ::
 ___builtin_va_start :: ___builtin_membar :: ___builtin_annot_intval ::
 ___builtin_annot :: ___builtin_sel :: ___builtin_memcpy_aligned ::
 ___builtin_sqrt :: ___builtin_fsqrt :: ___builtin_fabsf ::
 ___builtin_fabs :: ___builtin_ctzll :: ___builtin_ctzl :: ___builtin_ctz ::
 ___builtin_clzll :: ___builtin_clzl :: ___builtin_clz ::
 ___builtin_bswap16 :: ___builtin_bswap32 :: ___builtin_bswap ::
 ___builtin_bswap64 :: ___builtin_ais_annot :: ___compcert_i64_umulh ::
 ___compcert_i64_smulh :: ___compcert_i64_sar :: ___compcert_i64_shr ::
 ___compcert_i64_shl :: ___compcert_i64_umod :: ___compcert_i64_smod ::
 ___compcert_i64_udiv :: ___compcert_i64_sdiv :: ___compcert_i64_utof ::
 ___compcert_i64_stof :: ___compcert_i64_utod :: ___compcert_i64_stod ::
 ___compcert_i64_dtou :: ___compcert_i64_dtos :: ___compcert_va_composite ::
 ___compcert_va_float64 :: ___compcert_va_int64 :: ___compcert_va_int32 ::
 nil).

Definition prog : Clight.program := 
  mkprogram composites global_definitions public_idents _main Logic.I.


