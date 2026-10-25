(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Produced by: pipeline/clightgen.sh
   From source: vendor/sm64/src/game/hud.c
   clightgen:   The CompCert CompCert AST generator, version 3.15
   Flags:       -normalize -nostdinc -fstruct-passing -Ivendor/sm64/include -Ivendor/sm64/build/us -Ivendor/sm64/build/us/include -Ivendor/sm64/src -Ivendor/sm64 -Ivendor/sm64/include/libc -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1 -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -include pipeline/proof_n64.h (+ __stringlit_ -> __stringlit_hud_)
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
  Definition arch := "powerpc".
  Definition model := "ppc32".
  Definition abi := "eabi".
  Definition bitsize := 32.
  Definition big_endian := true.
  Definition source_file := "vendor/sm64/src/game/hud.c".
  Definition normalized := true.
End Info.

Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _Area : ident := $"Area".
Definition _Camera : ident := $"Camera".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _GraphNode : ident := $"GraphNode".
Definition _GraphNodeObject : ident := $"GraphNodeObject".
Definition _GraphNodeRoot : ident := $"GraphNodeRoot".
Definition _HudDisplay : ident := $"HudDisplay".
Definition _InstantWarp : ident := $"InstantWarp".
Definition _Object : ident := $"Object".
Definition _ObjectNode : ident := $"ObjectNode".
Definition _ObjectWarpNode : ident := $"ObjectWarpNode".
Definition _PlayerCameraState : ident := $"PlayerCameraState".
Definition _PowerMeterHUD : ident := $"PowerMeterHUD".
Definition _SpawnInfo : ident := $"SpawnInfo".
Definition _Surface : ident := $"Surface".
Definition _UnusedArea28 : ident := $"UnusedArea28".
Definition _WarpNode : ident := $"WarpNode".
Definition _Waypoint : ident := $"Waypoint".
Definition _Whirlpool : ident := $"Whirlpool".
Definition __469 : ident := $"_anon_492449ad5917".
Definition __472 : ident := $"_anon_6379328cdf8f".
Definition __510 : ident := $"_anon_b68c7cd607b8".
Definition __512 : ident := $"_anon_cc23475d879a".
Definition __514 : ident := $"_anon_582ea1ea7a16".
Definition __516 : ident := $"_anon_1f056269c846".
Definition __518 : ident := $"_anon_e728cafb3139_0".
Definition __520 : ident := $"_anon_e728cafb3139_1".
Definition __522 : ident := $"_anon_082533b0d3da".
Definition __524 : ident := $"_anon_326d1d817e71".
Definition __526 : ident := $"_anon_93f6c6d42751".
Definition __528 : ident := $"_anon_7fe8a69a4b23".
Definition __530 : ident := $"_anon_4f0efebcc12b".
Definition __532 : ident := $"_anon_aa3f148f9bf1".
Definition __534 : ident := $"_anon_336f2d3e0b53".
Definition __536 : ident := $"_anon_5b5ce0cbc558".
Definition __538 : ident := $"_anon_f17a035c1639".
Definition __547 : ident := $"_anon_50f496f0a47e".
Definition __549 : ident := $"_anon_56e646c222b2".
Definition __764 : ident := $"_anon_2a845cdd6eb9".
Definition __769 : ident := $"_anon_7dce1c6c6ad3".
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
Definition ___stringlit_1 : ident := $"__stringlit_hud_1".
Definition ___stringlit_2 : ident := $"__stringlit_hud_2".
Definition ___stringlit_3 : ident := $"__stringlit_hud_3".
Definition ___stringlit_4 : ident := $"__stringlit_hud_4".
Definition ___stringlit_5 : ident := $"__stringlit_hud_5".
Definition ___stringlit_6 : ident := $"__stringlit_hud_6".
Definition ___stringlit_7 : ident := $"__stringlit_hud_7".
Definition ___stringlit_8 : ident := $"__stringlit_hud_8".
Definition ___stringlit_9 : ident := $"__stringlit_hud_9".
Definition __g : ident := $"_g".
Definition __g__1 : ident := $"_g__1".
Definition __g__10 : ident := $"_g__10".
Definition __g__2 : ident := $"_g__2".
Definition __g__3 : ident := $"_g__3".
Definition __g__4 : ident := $"_g__4".
Definition __g__5 : ident := $"_g__5".
Definition __g__6 : ident := $"_g__6".
Definition __g__7 : ident := $"_g__7".
Definition __g__8 : ident := $"_g__8".
Definition __g__9 : ident := $"_g__9".
Definition _action : ident := $"action".
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _addr : ident := $"addr".
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
Definition _animate_power_meter_deemphasizing : ident := $"animate_power_meter_deemphasizing".
Definition _animate_power_meter_emphasized : ident := $"animate_power_meter_emphasized".
Definition _animate_power_meter_hiding : ident := $"animate_power_meter_hiding".
Definition _animation : ident := $"animation".
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
Definition _base : ident := $"base".
Definition _behavior : ident := $"behavior".
Definition _behaviorArg : ident := $"behaviorArg".
Definition _behaviorScript : ident := $"behaviorScript".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _camera : ident := $"camera".
Definition _cameraEvent : ident := $"cameraEvent".
Definition _cameraLUT : ident := $"cameraLUT".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _children : ident := $"children".
Definition _cmd : ident := $"cmd".
Definition _coins : ident := $"coins".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _color : ident := $"color".
Definition _create_dl_ortho_matrix : ident := $"create_dl_ortho_matrix".
Definition _cs : ident := $"cs".
Definition _ct : ident := $"ct".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _cutscene : ident := $"cutscene".
Definition _data : ident := $"data".
Definition _defMode : ident := $"defMode".
Definition _destArea : ident := $"destArea".
Definition _destLevel : ident := $"destLevel".
Definition _destNode : ident := $"destNode".
Definition _dialog : ident := $"dialog".
Definition _displacement : ident := $"displacement".
Definition _dl_hud_img_begin : ident := $"dl_hud_img_begin".
Definition _dl_hud_img_end : ident := $"dl_hud_img_end".
Definition _dl_hud_img_load_tex_block : ident := $"dl_hud_img_load_tex_block".
Definition _dl_power_meter_base : ident := $"dl_power_meter_base".
Definition _dl_power_meter_health_segments_begin : ident := $"dl_power_meter_health_segments_begin".
Definition _dl_power_meter_health_segments_end : ident := $"dl_power_meter_health_segments_end".
Definition _dma : ident := $"dma".
Definition _doorStatus : ident := $"doorStatus".
Definition _dram : ident := $"dram".
Definition _faceAngle : ident := $"faceAngle".
Definition _filler1 : ident := $"filler1".
Definition _filler2 : ident := $"filler2".
Definition _fillrect : ident := $"fillrect".
Definition _flag : ident := $"flag".
Definition _flags : ident := $"flags".
Definition _fmt : ident := $"fmt".
Definition _focus : ident := $"focus".
Definition _force : ident := $"force".
Definition _force_structure_alignment : ident := $"force_structure_alignment".
Definition _gCurrentArea : ident := $"gCurrentArea".
Definition _gDisplayListHead : ident := $"gDisplayListHead".
Definition _gGlobalTimer : ident := $"gGlobalTimer".
Definition _gHudDisplay : ident := $"gHudDisplay".
Definition _gHudFlash : ident := $"gHudFlash".
Definition _gPlayerCameraState : ident := $"gPlayerCameraState".
Definition _gfx : ident := $"gfx".
Definition _guTranslate : ident := $"guTranslate".
Definition _handle_power_meter_actions : ident := $"handle_power_meter_actions".
Definition _headRotation : ident := $"headRotation".
Definition _header : ident := $"header".
Definition _healthLUT : ident := $"healthLUT".
Definition _height : ident := $"height".
Definition _hitboxDownOffset : ident := $"hitboxDownOffset".
Definition _hitboxHeight : ident := $"hitboxHeight".
Definition _hitboxRadius : ident := $"hitboxRadius".
Definition _hudDisplayFlags : ident := $"hudDisplayFlags".
Definition _hudLUT : ident := $"hudLUT".
Definition _hurtboxHeight : ident := $"hurtboxHeight".
Definition _hurtboxRadius : ident := $"hurtboxRadius".
Definition _i : ident := $"i".
Definition _id : ident := $"id".
Definition _index : ident := $"index".
Definition _instantWarps : ident := $"instantWarps".
Definition _keys : ident := $"keys".
Definition _len : ident := $"len".
Definition _length : ident := $"length".
Definition _line : ident := $"line".
Definition _lives : ident := $"lives".
Definition _loadtile : ident := $"loadtile".
Definition _loadtlut : ident := $"loadtlut".
Definition _lodscale : ident := $"lodscale".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _m : ident := $"m".
Definition _macroObjects : ident := $"macroObjects".
Definition _main : ident := $"main".
Definition _main_hud_camera_lut : ident := $"main_hud_camera_lut".
Definition _main_hud_lut : ident := $"main_hud_lut".
Definition _masks : ident := $"masks".
Definition _maskt : ident := $"maskt".
Definition _mode : ident := $"mode".
Definition _model : ident := $"model".
Definition _ms : ident := $"ms".
Definition _mt : ident := $"mt".
Definition _mtx : ident := $"mtx".
Definition _musicParam : ident := $"musicParam".
Definition _musicParam2 : ident := $"musicParam2".
Definition _muxs0 : ident := $"muxs0".
Definition _muxs1 : ident := $"muxs1".
Definition _mw_index : ident := $"mw_index".
Definition _next : ident := $"next".
Definition _nextYaw : ident := $"nextYaw".
Definition _node : ident := $"node".
Definition _normal : ident := $"normal".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _numHealthWedges : ident := $"numHealthWedges".
Definition _numViews : ident := $"numViews".
Definition _number : ident := $"number".
Definition _object : ident := $"object".
Definition _objectSpawnInfos : ident := $"objectSpawnInfos".
Definition _on : ident := $"on".
Definition _originOffset : ident := $"originOffset".
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
Definition _perspnorm : ident := $"perspnorm".
Definition _platform : ident := $"platform".
Definition _popmtx : ident := $"popmtx".
Definition _pos : ident := $"pos".
Definition _power_meter_health_segments_lut : ident := $"power_meter_health_segments_lut".
Definition _prev : ident := $"prev".
Definition _prevObj : ident := $"prevObj".
Definition _prim_level : ident := $"prim_level".
Definition _prim_min_level : ident := $"prim_min_level".
Definition _print_text : ident := $"print_text".
Definition _print_text_fmt_int : ident := $"print_text_fmt_int".
Definition _rawData : ident := $"rawData".
Definition _render_dl_power_meter : ident := $"render_dl_power_meter".
Definition _render_hud : ident := $"render_hud".
Definition _render_hud_camera_status : ident := $"render_hud_camera_status".
Definition _render_hud_cannon_reticle : ident := $"render_hud_cannon_reticle".
Definition _render_hud_coins : ident := $"render_hud_coins".
Definition _render_hud_keys : ident := $"render_hud_keys".
Definition _render_hud_mario_lives : ident := $"render_hud_mario_lives".
Definition _render_hud_power_meter : ident := $"render_hud_power_meter".
Definition _render_hud_small_tex_lut : ident := $"render_hud_small_tex_lut".
Definition _render_hud_stars : ident := $"render_hud_stars".
Definition _render_hud_tex_lut : ident := $"render_hud_tex_lut".
Definition _render_hud_timer : ident := $"render_hud_timer".
Definition _render_power_meter_health_segment : ident := $"render_power_meter_health_segment".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _room : ident := $"room".
Definition _s : ident := $"s".
Definition _sCameraHUDStatus : ident := $"sCameraHUDStatus".
Definition _sPowerMeterHUD : ident := $"sPowerMeterHUD".
Definition _sPowerMeterStoredHealth : ident := $"sPowerMeterStoredHealth".
Definition _sPowerMeterVisibleTimer : ident := $"sPowerMeterVisibleTimer".
Definition _scale : ident := $"scale".
Definition _segment : ident := $"segment".
Definition _segmented_to_virtual : ident := $"segmented_to_virtual".
Definition _set_hud_camera_status : ident := $"set_hud_camera_status".
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
Definition _showX : ident := $"showX".
Definition _shownHealthWedges : ident := $"shownHealthWedges".
Definition _siz : ident := $"siz".
Definition _sl : ident := $"sl".
Definition _speed : ident := $"speed".
Definition _stars : ident := $"stars".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
Definition _status : ident := $"status".
Definition _strength : ident := $"strength".
Definition _surfaceRooms : ident := $"surfaceRooms".
Definition _t : ident := $"t".
Definition _terrainData : ident := $"terrainData".
Definition _terrainType : ident := $"terrainType".
Definition _texture : ident := $"texture".
Definition _th : ident := $"th".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _tile : ident := $"tile".
Definition _timer : ident := $"timer".
Definition _timerFracSecs : ident := $"timerFracSecs".
Definition _timerMins : ident := $"timerMins".
Definition _timerSecs : ident := $"timerSecs".
Definition _timerValFrames : ident := $"timerValFrames".
Definition _tl : ident := $"tl".
Definition _tmem : ident := $"tmem".
Definition _transform : ident := $"transform".
Definition _tri : ident := $"tri".
Definition _type : ident := $"type".
Definition _unk00 : ident := $"unk00".
Definition _unk02 : ident := $"unk02".
Definition _unk04 : ident := $"unk04".
Definition _unk06 : ident := $"unk06".
Definition _unk08 : ident := $"unk08".
Definition _unk15 : ident := $"unk15".
Definition _unk4C : ident := $"unk4C".
Definition _unused : ident := $"unused".
Definition _unused1 : ident := $"unused1".
Definition _unused2 : ident := $"unused2".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _unusedVec1 : ident := $"unusedVec1".
Definition _upperY : ident := $"upperY".
Definition _usedObj : ident := $"usedObj".
Definition _v : ident := $"v".
Definition _values : ident := $"values".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _views : ident := $"views".
Definition _w0 : ident := $"w0".
Definition _w1 : ident := $"w1".
Definition _warpNodes : ident := $"warpNodes".
Definition _wd : ident := $"wd".
Definition _wedges : ident := $"wedges".
Definition _whirlpools : ident := $"whirlpools".
Definition _width : ident := $"width".
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
Definition _t'2 : ident := 129%positive.
Definition _t'3 : ident := 130%positive.
Definition _t'4 : ident := 131%positive.
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v___stringlit_2 := {|
  gvar_info := (tarray tuchar 2);
  gvar_init := (Init_int8 (Int.repr 42) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_8 := {|
  gvar_info := (tarray tuchar 4);
  gvar_init := (Init_int8 (Int.repr 37) :: Init_int8 (Int.repr 48) ::
                Init_int8 (Int.repr 100) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_3 := {|
  gvar_info := (tarray tuchar 3);
  gvar_init := (Init_int8 (Int.repr 37) :: Init_int8 (Int.repr 100) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_5 := {|
  gvar_info := (tarray tuchar 2);
  gvar_init := (Init_int8 (Int.repr 45) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_4 := {|
  gvar_info := (tarray tuchar 2);
  gvar_init := (Init_int8 (Int.repr 43) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_6 := {|
  gvar_info := (tarray tuchar 2);
  gvar_init := (Init_int8 (Int.repr 47) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_7 := {|
  gvar_info := (tarray tuchar 5);
  gvar_init := (Init_int8 (Int.repr 84) :: Init_int8 (Int.repr 73) ::
                Init_int8 (Int.repr 77) :: Init_int8 (Int.repr 69) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_9 := {|
  gvar_info := (tarray tuchar 5);
  gvar_init := (Init_int8 (Int.repr 37) :: Init_int8 (Int.repr 48) ::
                Init_int8 (Int.repr 50) :: Init_int8 (Int.repr 100) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_1 := {|
  gvar_info := (tarray tuchar 2);
  gvar_init := (Init_int8 (Int.repr 44) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_power_meter_health_segments_lut := {|
  gvar_info := (tarray (tptr tuchar) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_dl_power_meter_base := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_dl_power_meter_health_segments_begin := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_dl_power_meter_health_segments_end := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_gDisplayListHead := {|
  gvar_info := (tptr (Tunion __549 noattr));
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

Definition v_gHudDisplay := {|
  gvar_info := (Tstruct _HudDisplay noattr);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrentArea := {|
  gvar_info := (tptr (Tstruct _Area noattr));
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

Definition v_gHudFlash := {|
  gvar_info := tschar;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_main_hud_lut := {|
  gvar_info := (tarray (tptr tuchar) 58);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_dl_hud_img_load_tex_block := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_dl_hud_img_begin := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_dl_hud_img_end := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_main_hud_camera_lut := {|
  gvar_info := (tarray (tptr tuchar) 6);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sPowerMeterStoredHealth := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sPowerMeterHUD := {|
  gvar_info := (Tstruct _PowerMeterHUD noattr);
  gvar_init := (Init_int8 (Int.repr 0) :: Init_space 1 ::
                Init_int16 (Int.repr 140) :: Init_int16 (Int.repr 166) ::
                Init_space 2 ::
                Init_float32 (Float32.of_bits (Int.repr 1065353216)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sPowerMeterVisibleTimer := {|
  gvar_info := tint;
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sCameraHUDStatus := {|
  gvar_info := tshort;
  gvar_init := (Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_render_hud_tex_lut := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_x, tint) :: (_y, tint) :: (_texture, (tptr tuchar)) :: nil);
  fn_vars := nil;
  fn_temps := ((__g, (tptr (Tunion __549 noattr))) ::
               (__g__1, (tptr (Tunion __549 noattr))) ::
               (__g__2, (tptr (Tunion __549 noattr))) ::
               (__g__3, (tptr (Tunion __549 noattr))) ::
               (__g__4, (tptr (Tunion __549 noattr))) ::
               (__g__5, (tptr (Tunion __549 noattr))) ::
               (_t'6, (tptr (Tunion __549 noattr))) ::
               (_t'5, (tptr (Tunion __549 noattr))) ::
               (_t'4, (tptr (Tunion __549 noattr))) ::
               (_t'3, (tptr (Tunion __549 noattr))) ::
               (_t'2, (tptr (Tunion __549 noattr))) ::
               (_t'1, (tptr (Tunion __549 noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'1 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
        (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
          (Ebinop Oadd (Etempvar _t'1 (tptr (Tunion __549 noattr)))
            (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
      (Sset __g
        (Ecast (Etempvar _t'1 (tptr (Tunion __549 noattr)))
          (tptr (Tunion __549 noattr)))))
    (Ssequence
      (Sassign
        (Efield
          (Efield
            (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
              (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
          tuint)
        (Ecast
          (Ebinop Oshl
            (Ebinop Oand (Ecast (Econst_int (Int.repr 231) tint) tuint)
              (Ebinop Osub
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 8) tint) tint)
                (Econst_int (Int.repr 1) tint) tint) tuint)
            (Econst_int (Int.repr 24) tint) tuint) tuint))
      (Sassign
        (Efield
          (Efield
            (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
              (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
          tuint) (Econst_int (Int.repr 0) tint))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
          (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
            (Ebinop Oadd (Etempvar _t'2 (tptr (Tunion __549 noattr)))
              (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
        (Sset __g__1
          (Ecast (Etempvar _t'2 (tptr (Tunion __549 noattr)))
            (tptr (Tunion __549 noattr)))))
      (Ssequence
        (Sassign
          (Efield
            (Efield
              (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
            tuint)
          (Ebinop Oor
            (Ebinop Oor
              (Ebinop Oor
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast (Econst_int (Int.repr 253) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 24) tint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 3) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 21) tint) tuint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand (Ecast (Econst_int (Int.repr 2) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 2) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 19) tint) tuint) tuint) tuint)
            (Ecast
              (Ebinop Oshl
                (Ebinop Oand
                  (Ecast
                    (Ebinop Osub (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Ebinop Osub
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 12) tint) tint)
                    (Econst_int (Int.repr 1) tint) tint) tuint)
                (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
        (Sassign
          (Efield
            (Efield
              (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
            tuint) (Ecast (Etempvar _texture (tptr tuchar)) tuint))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'3 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
            (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
              (Ebinop Oadd (Etempvar _t'3 (tptr (Tunion __549 noattr)))
                (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
          (Sset __g__2
            (Ecast (Etempvar _t'3 (tptr (Tunion __549 noattr)))
              (tptr (Tunion __549 noattr)))))
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                  (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
              tuint)
            (Ebinop Oor
              (Ebinop Oor
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast (Econst_int (Int.repr 222) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 24) tint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 16) tint) tuint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 16) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                  (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
              tuint)
            (Ecast
              (Eaddrof
                (Evar _dl_hud_img_load_tex_block (tarray (Tunion __549 noattr) 0))
                (tptr (tarray (Tunion __549 noattr) 0))) tuint))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'4 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
            (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
              (Ebinop Oadd (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
          (Sset __g__3
            (Ecast (Etempvar _t'4 (tptr (Tunion __549 noattr)))
              (tptr (Tunion __549 noattr)))))
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                  (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
              tuint)
            (Ebinop Oor
              (Ebinop Oor
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast (Econst_int (Int.repr 228) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 24) tint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oadd (Etempvar _x tint)
                            (Econst_int (Int.repr 15) tint) tint)
                          (Econst_int (Int.repr 2) tint) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 12) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 12) tint) tuint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oadd (Etempvar _y tint)
                          (Econst_int (Int.repr 15) tint) tint)
                        (Econst_int (Int.repr 2) tint) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 12) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
          (Ssequence
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
                tuint)
              (Ebinop Oor
                (Ebinop Oor
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 0) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 3) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 24) tint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast
                          (Ebinop Oshl (Etempvar _x tint)
                            (Econst_int (Int.repr 2) tint) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 12) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 12) tint) tuint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast
                        (Ebinop Oshl (Etempvar _y tint)
                          (Econst_int (Int.repr 2) tint) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 12) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'5
                      (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                    (Sassign
                      (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                      (Ebinop Oadd
                        (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                        (Econst_int (Int.repr 1) tint)
                        (tptr (Tunion __549 noattr)))))
                  (Sset __g__4
                    (Ecast (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                      (tptr (Tunion __549 noattr)))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                          (Tunion __549 noattr)) _words
                        (Tstruct __547 noattr)) _w0 tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 225) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 24) tint) tuint) tuint))
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                          (Tunion __549 noattr)) _words
                        (Tstruct __547 noattr)) _w1 tuint)
                    (Ecast
                      (Ebinop Oor
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 0) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 16) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 16) tint) tuint) tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 0) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 16) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 0) tint) tuint) tuint)
                        tuint) tuint))))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'6
                      (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                    (Sassign
                      (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                      (Ebinop Oadd
                        (Etempvar _t'6 (tptr (Tunion __549 noattr)))
                        (Econst_int (Int.repr 1) tint)
                        (tptr (Tunion __549 noattr)))))
                  (Sset __g__5
                    (Ecast (Etempvar _t'6 (tptr (Tunion __549 noattr)))
                      (tptr (Tunion __549 noattr)))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__5 (tptr (Tunion __549 noattr)))
                          (Tunion __549 noattr)) _words
                        (Tstruct __547 noattr)) _w0 tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 241) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 24) tint) tuint) tuint))
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__5 (tptr (Tunion __549 noattr)))
                          (Tunion __549 noattr)) _words
                        (Tstruct __547 noattr)) _w1 tuint)
                    (Ecast
                      (Ebinop Oor
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast
                                (Ebinop Oshl (Econst_int (Int.repr 4) tint)
                                  (Econst_int (Int.repr 10) tint) tint)
                                tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 16) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 16) tint) tuint) tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 10) tint) tint)
                                tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 16) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 0) tint) tuint) tuint)
                        tuint) tuint)))))))))))
|}.

Definition f_render_hud_small_tex_lut := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_x, tint) :: (_y, tint) :: (_texture, (tptr tuchar)) :: nil);
  fn_vars := nil;
  fn_temps := ((__g, (tptr (Tunion __549 noattr))) ::
               (__g__1, (tptr (Tunion __549 noattr))) ::
               (__g__2, (tptr (Tunion __549 noattr))) ::
               (__g__3, (tptr (Tunion __549 noattr))) ::
               (__g__4, (tptr (Tunion __549 noattr))) ::
               (__g__5, (tptr (Tunion __549 noattr))) ::
               (__g__6, (tptr (Tunion __549 noattr))) ::
               (__g__7, (tptr (Tunion __549 noattr))) ::
               (__g__8, (tptr (Tunion __549 noattr))) ::
               (__g__9, (tptr (Tunion __549 noattr))) ::
               (__g__10, (tptr (Tunion __549 noattr))) ::
               (_t'14, (tptr (Tunion __549 noattr))) ::
               (_t'13, (tptr (Tunion __549 noattr))) ::
               (_t'12, (tptr (Tunion __549 noattr))) :: (_t'11, tint) ::
               (_t'10, tint) :: (_t'9, tint) ::
               (_t'8, (tptr (Tunion __549 noattr))) ::
               (_t'7, (tptr (Tunion __549 noattr))) ::
               (_t'6, (tptr (Tunion __549 noattr))) ::
               (_t'5, (tptr (Tunion __549 noattr))) ::
               (_t'4, (tptr (Tunion __549 noattr))) ::
               (_t'3, (tptr (Tunion __549 noattr))) ::
               (_t'2, (tptr (Tunion __549 noattr))) ::
               (_t'1, (tptr (Tunion __549 noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'1 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
        (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
          (Ebinop Oadd (Etempvar _t'1 (tptr (Tunion __549 noattr)))
            (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
      (Sset __g
        (Ecast (Etempvar _t'1 (tptr (Tunion __549 noattr)))
          (tptr (Tunion __549 noattr)))))
    (Ssequence
      (Sassign
        (Efield
          (Efield
            (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
              (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
          tuint)
        (Ebinop Oor
          (Ebinop Oor
            (Ebinop Oor
              (Ebinop Oor
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast (Econst_int (Int.repr 245) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 24) tint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 3) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 21) tint) tuint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand (Ecast (Econst_int (Int.repr 2) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 2) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 19) tint) tuint) tuint) tuint)
            (Ecast
              (Ebinop Oshl
                (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                  (Ebinop Osub
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 9) tint) tint)
                    (Econst_int (Int.repr 1) tint) tint) tuint)
                (Econst_int (Int.repr 9) tint) tuint) tuint) tuint)
          (Ecast
            (Ebinop Oshl
              (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                (Ebinop Osub
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 9) tint) tint)
                  (Econst_int (Int.repr 1) tint) tint) tuint)
              (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
      (Sassign
        (Efield
          (Efield
            (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
              (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
          tuint)
        (Ebinop Oor
          (Ebinop Oor
            (Ebinop Oor
              (Ebinop Oor
                (Ebinop Oor
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 7) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 3) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 24) tint) tuint) tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 0) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 4) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 20) tint) tuint) tuint)
                      tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast
                            (Ebinop Oor (Econst_int (Int.repr 0) tint)
                              (Econst_int (Int.repr 0) tint) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 2) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 18) tint) tuint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 0) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 4) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 14) tint) tuint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 4) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 10) tint) tuint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand
                    (Ecast
                      (Ebinop Oor (Econst_int (Int.repr 0) tint)
                        (Econst_int (Int.repr 0) tint) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 2) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 8) tint) tuint) tuint) tuint)
            (Ecast
              (Ebinop Oshl
                (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                  (Ebinop Osub
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 4) tint) tint)
                    (Econst_int (Int.repr 1) tint) tint) tuint)
                (Econst_int (Int.repr 4) tint) tuint) tuint) tuint)
          (Ecast
            (Ebinop Oshl
              (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                (Ebinop Osub
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 4) tint) tint)
                  (Econst_int (Int.repr 1) tint) tint) tuint)
              (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
          (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
            (Ebinop Oadd (Etempvar _t'2 (tptr (Tunion __549 noattr)))
              (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
        (Sset __g__1
          (Ecast (Etempvar _t'2 (tptr (Tunion __549 noattr)))
            (tptr (Tunion __549 noattr)))))
      (Ssequence
        (Sassign
          (Efield
            (Efield
              (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
            tuint)
          (Ecast
            (Ebinop Oshl
              (Ebinop Oand (Ecast (Econst_int (Int.repr 232) tint) tuint)
                (Ebinop Osub
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 8) tint) tint)
                  (Econst_int (Int.repr 1) tint) tint) tuint)
              (Econst_int (Int.repr 24) tint) tuint) tuint))
        (Sassign
          (Efield
            (Efield
              (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
            tuint) (Econst_int (Int.repr 0) tint))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'3 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
            (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
              (Ebinop Oadd (Etempvar _t'3 (tptr (Tunion __549 noattr)))
                (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
          (Sset __g__2
            (Ecast (Etempvar _t'3 (tptr (Tunion __549 noattr)))
              (tptr (Tunion __549 noattr)))))
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                  (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
              tuint)
            (Ebinop Oor
              (Ebinop Oor
                (Ebinop Oor
                  (Ebinop Oor
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 245) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 24) tint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 0) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 3) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 21) tint) tuint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 2) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 2) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 19) tint) tuint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand (Ecast (Econst_int (Int.repr 2) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 9) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 9) tint) tuint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 9) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                  (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
              tuint)
            (Ebinop Oor
              (Ebinop Oor
                (Ebinop Oor
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ebinop Oor
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast (Econst_int (Int.repr 0) tint) tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 3) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 24) tint) tuint) tuint)
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast (Econst_int (Int.repr 0) tint) tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 4) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 20) tint) tuint) tuint)
                          tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 2) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 2) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 18) tint) tuint) tuint)
                        tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 3) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 4) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 14) tint) tuint) tuint)
                      tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 0) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 4) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 10) tint) tuint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 2) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 2) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 8) tint) tuint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand (Ecast (Econst_int (Int.repr 3) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 4) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 4) tint) tuint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 4) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
              (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                (Ebinop Oadd (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                  (Econst_int (Int.repr 1) tint)
                  (tptr (Tunion __549 noattr)))))
            (Sset __g__3
              (Ecast (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                (tptr (Tunion __549 noattr)))))
          (Ssequence
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
                tuint)
              (Ebinop Oor
                (Ebinop Oor
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 242) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 8) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 24) tint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 0) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 12) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 12) tint) tuint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 12) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
                tuint)
              (Ebinop Oor
                (Ebinop Oor
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 0) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 3) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 24) tint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Osub (Econst_int (Int.repr 8) tint)
                              (Econst_int (Int.repr 1) tint) tint)
                            (Econst_int (Int.repr 2) tint) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 12) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 12) tint) tuint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Osub (Econst_int (Int.repr 8) tint)
                            (Econst_int (Int.repr 1) tint) tint)
                          (Econst_int (Int.repr 2) tint) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 12) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))))
        (Ssequence
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                (Sassign
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                  (Ebinop Oadd (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                    (Econst_int (Int.repr 1) tint)
                    (tptr (Tunion __549 noattr)))))
              (Sset __g__4
                (Ecast (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                  (tptr (Tunion __549 noattr)))))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w0 tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast (Econst_int (Int.repr 231) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 24) tint) tuint) tuint))
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w1 tuint) (Econst_int (Int.repr 0) tint))))
          (Ssequence
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'6
                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                  (Sassign
                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                    (Ebinop Oadd (Etempvar _t'6 (tptr (Tunion __549 noattr)))
                      (Econst_int (Int.repr 1) tint)
                      (tptr (Tunion __549 noattr)))))
                (Sset __g__5
                  (Ecast (Etempvar _t'6 (tptr (Tunion __549 noattr)))
                    (tptr (Tunion __549 noattr)))))
              (Ssequence
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__5 (tptr (Tunion __549 noattr)))
                        (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                    _w0 tuint)
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 253) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 8) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 24) tint) tuint) tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 0) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 3) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 21) tint) tuint) tuint)
                        tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 2) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 2) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 19) tint) tuint) tuint)
                      tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast
                            (Ebinop Osub (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 12) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__5 (tptr (Tunion __549 noattr)))
                        (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                    _w1 tuint)
                  (Ecast (Etempvar _texture (tptr tuchar)) tuint))))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'7
                      (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                    (Sassign
                      (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                      (Ebinop Oadd
                        (Etempvar _t'7 (tptr (Tunion __549 noattr)))
                        (Econst_int (Int.repr 1) tint)
                        (tptr (Tunion __549 noattr)))))
                  (Sset __g__6
                    (Ecast (Etempvar _t'7 (tptr (Tunion __549 noattr)))
                      (tptr (Tunion __549 noattr)))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__6 (tptr (Tunion __549 noattr)))
                          (Tunion __549 noattr)) _words
                        (Tstruct __547 noattr)) _w0 tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 230) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 24) tint) tuint) tuint))
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__6 (tptr (Tunion __549 noattr)))
                          (Tunion __549 noattr)) _words
                        (Tstruct __547 noattr)) _w1 tuint)
                    (Econst_int (Int.repr 0) tint))))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'8
                        (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                      (Sassign
                        (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                        (Ebinop Oadd
                          (Etempvar _t'8 (tptr (Tunion __549 noattr)))
                          (Econst_int (Int.repr 1) tint)
                          (tptr (Tunion __549 noattr)))))
                    (Sset __g__7
                      (Ecast (Etempvar _t'8 (tptr (Tunion __549 noattr)))
                        (tptr (Tunion __549 noattr)))))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar __g__7 (tptr (Tunion __549 noattr)))
                            (Tunion __549 noattr)) _words
                          (Tstruct __547 noattr)) _w0 tuint)
                      (Ebinop Oor
                        (Ebinop Oor
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast (Econst_int (Int.repr 243) tint)
                                  tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 8) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 24) tint) tuint) tuint)
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast (Econst_int (Int.repr 0) tint) tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 12) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 12) tint) tuint) tuint)
                          tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 0) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 12) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 0) tint) tuint) tuint)
                        tuint))
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sifthenelse (Ebinop Olt
                                         (Ebinop Osub
                                           (Ebinop Omul
                                             (Econst_int (Int.repr 8) tint)
                                             (Econst_int (Int.repr 8) tint)
                                             tint)
                                           (Econst_int (Int.repr 1) tint)
                                           tint)
                                         (Econst_int (Int.repr 2047) tint)
                                         tint)
                            (Sset _t'9
                              (Ecast
                                (Ebinop Osub
                                  (Ebinop Omul (Econst_int (Int.repr 8) tint)
                                    (Econst_int (Int.repr 8) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tint))
                            (Sset _t'9
                              (Ecast (Econst_int (Int.repr 2047) tint) tint)))
                          (Sifthenelse (Ebinop Ogt
                                         (Econst_int (Int.repr 1) tint)
                                         (Ebinop Odiv
                                           (Ebinop Omul
                                             (Econst_int (Int.repr 8) tint)
                                             (Econst_int (Int.repr 2) tint)
                                             tint)
                                           (Econst_int (Int.repr 8) tint)
                                           tint) tint)
                            (Sset _t'10
                              (Ecast (Econst_int (Int.repr 1) tint) tint))
                            (Sset _t'10
                              (Ecast
                                (Ebinop Odiv
                                  (Ebinop Omul (Econst_int (Int.repr 8) tint)
                                    (Econst_int (Int.repr 2) tint) tint)
                                  (Econst_int (Int.repr 8) tint) tint) tint))))
                        (Sifthenelse (Ebinop Ogt
                                       (Econst_int (Int.repr 1) tint)
                                       (Ebinop Odiv
                                         (Ebinop Omul
                                           (Econst_int (Int.repr 8) tint)
                                           (Econst_int (Int.repr 2) tint)
                                           tint)
                                         (Econst_int (Int.repr 8) tint) tint)
                                       tint)
                          (Sset _t'11
                            (Ecast (Econst_int (Int.repr 1) tint) tint))
                          (Sset _t'11
                            (Ecast
                              (Ebinop Odiv
                                (Ebinop Omul (Econst_int (Int.repr 8) tint)
                                  (Econst_int (Int.repr 2) tint) tint)
                                (Econst_int (Int.repr 8) tint) tint) tint))))
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar __g__7 (tptr (Tunion __549 noattr)))
                              (Tunion __549 noattr)) _words
                            (Tstruct __547 noattr)) _w1 tuint)
                        (Ebinop Oor
                          (Ebinop Oor
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Econst_int (Int.repr 7) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 3) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 24) tint)
                                tuint) tuint)
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Etempvar _t'9 tint) tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 12) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 12) tint)
                                tuint) tuint) tuint)
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast
                                  (Ebinop Odiv
                                    (Ebinop Osub
                                      (Ebinop Oadd
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 11) tint)
                                          tint) (Etempvar _t'10 tint) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    (Etempvar _t'11 tint) tint) tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 12) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 0) tint) tuint) tuint)
                          tuint)))))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'12
                        (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                      (Sassign
                        (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                        (Ebinop Oadd
                          (Etempvar _t'12 (tptr (Tunion __549 noattr)))
                          (Econst_int (Int.repr 1) tint)
                          (tptr (Tunion __549 noattr)))))
                    (Sset __g__8
                      (Ecast (Etempvar _t'12 (tptr (Tunion __549 noattr)))
                        (tptr (Tunion __549 noattr)))))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar __g__8 (tptr (Tunion __549 noattr)))
                            (Tunion __549 noattr)) _words
                          (Tstruct __547 noattr)) _w0 tuint)
                      (Ebinop Oor
                        (Ebinop Oor
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast (Econst_int (Int.repr 228) tint)
                                  tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 8) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 24) tint) tuint) tuint)
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast
                                  (Ebinop Oshl
                                    (Ebinop Oadd (Etempvar _x tint)
                                      (Econst_int (Int.repr 7) tint) tint)
                                    (Econst_int (Int.repr 2) tint) tint)
                                  tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 12) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 12) tint) tuint) tuint)
                          tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast
                                (Ebinop Oshl
                                  (Ebinop Oadd (Etempvar _y tint)
                                    (Econst_int (Int.repr 7) tint) tint)
                                  (Econst_int (Int.repr 2) tint) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 12) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 0) tint) tuint) tuint)
                        tuint))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar __g__8 (tptr (Tunion __549 noattr)))
                              (Tunion __549 noattr)) _words
                            (Tstruct __547 noattr)) _w1 tuint)
                        (Ebinop Oor
                          (Ebinop Oor
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Econst_int (Int.repr 0) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 3) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 24) tint)
                                tuint) tuint)
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast
                                    (Ebinop Oshl (Etempvar _x tint)
                                      (Econst_int (Int.repr 2) tint) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 12) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 12) tint)
                                tuint) tuint) tuint)
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast
                                  (Ebinop Oshl (Etempvar _y tint)
                                    (Econst_int (Int.repr 2) tint) tint)
                                  tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 12) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 0) tint) tuint) tuint)
                          tuint))
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Sset _t'13
                                (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                              (Sassign
                                (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                                (Ebinop Oadd
                                  (Etempvar _t'13 (tptr (Tunion __549 noattr)))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr (Tunion __549 noattr)))))
                            (Sset __g__9
                              (Ecast
                                (Etempvar _t'13 (tptr (Tunion __549 noattr)))
                                (tptr (Tunion __549 noattr)))))
                          (Ssequence
                            (Sassign
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar __g__9 (tptr (Tunion __549 noattr)))
                                    (Tunion __549 noattr)) _words
                                  (Tstruct __547 noattr)) _w0 tuint)
                              (Ecast
                                (Ebinop Oshl
                                  (Ebinop Oand
                                    (Ecast (Econst_int (Int.repr 225) tint)
                                      tuint)
                                    (Ebinop Osub
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 8) tint) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuint) (Econst_int (Int.repr 24) tint)
                                  tuint) tuint))
                            (Sassign
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar __g__9 (tptr (Tunion __549 noattr)))
                                    (Tunion __549 noattr)) _words
                                  (Tstruct __547 noattr)) _w1 tuint)
                              (Ecast
                                (Ebinop Oor
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
                                      (Econst_int (Int.repr 16) tint) tuint)
                                    tuint)
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
                                    tuint) tuint) tuint))))
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Sset _t'14
                                (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                              (Sassign
                                (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                                (Ebinop Oadd
                                  (Etempvar _t'14 (tptr (Tunion __549 noattr)))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr (Tunion __549 noattr)))))
                            (Sset __g__10
                              (Ecast
                                (Etempvar _t'14 (tptr (Tunion __549 noattr)))
                                (tptr (Tunion __549 noattr)))))
                          (Ssequence
                            (Sassign
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar __g__10 (tptr (Tunion __549 noattr)))
                                    (Tunion __549 noattr)) _words
                                  (Tstruct __547 noattr)) _w0 tuint)
                              (Ecast
                                (Ebinop Oshl
                                  (Ebinop Oand
                                    (Ecast (Econst_int (Int.repr 241) tint)
                                      tuint)
                                    (Ebinop Osub
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 8) tint) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuint) (Econst_int (Int.repr 24) tint)
                                  tuint) tuint))
                            (Sassign
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar __g__10 (tptr (Tunion __549 noattr)))
                                    (Tunion __549 noattr)) _words
                                  (Tstruct __547 noattr)) _w1 tuint)
                              (Ecast
                                (Ebinop Oor
                                  (Ecast
                                    (Ebinop Oshl
                                      (Ebinop Oand
                                        (Ecast
                                          (Ebinop Oshl
                                            (Econst_int (Int.repr 4) tint)
                                            (Econst_int (Int.repr 10) tint)
                                            tint) tuint)
                                        (Ebinop Osub
                                          (Ebinop Oshl
                                            (Econst_int (Int.repr 1) tint)
                                            (Econst_int (Int.repr 16) tint)
                                            tint)
                                          (Econst_int (Int.repr 1) tint)
                                          tint) tuint)
                                      (Econst_int (Int.repr 16) tint) tuint)
                                    tuint)
                                  (Ecast
                                    (Ebinop Oshl
                                      (Ebinop Oand
                                        (Ecast
                                          (Ebinop Oshl
                                            (Econst_int (Int.repr 1) tint)
                                            (Econst_int (Int.repr 10) tint)
                                            tint) tuint)
                                        (Ebinop Osub
                                          (Ebinop Oshl
                                            (Econst_int (Int.repr 1) tint)
                                            (Econst_int (Int.repr 16) tint)
                                            tint)
                                          (Econst_int (Int.repr 1) tint)
                                          tint) tuint)
                                      (Econst_int (Int.repr 0) tint) tuint)
                                    tuint) tuint) tuint))))))))))))))))
|}.

Definition f_render_power_meter_health_segment := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_numHealthWedges, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_healthLUT, (tptr (tarray (tptr tuchar) 0))) ::
               (__g, (tptr (Tunion __549 noattr))) ::
               (__g__1, (tptr (Tunion __549 noattr))) ::
               (__g__2, (tptr (Tunion __549 noattr))) ::
               (__g__3, (tptr (Tunion __549 noattr))) ::
               (__g__4, (tptr (Tunion __549 noattr))) ::
               (__g__5, (tptr (Tunion __549 noattr))) :: (_t'12, tuint) ::
               (_t'11, (tptr (Tunion __549 noattr))) :: (_t'10, tuint) ::
               (_t'9, (tptr (Tunion __549 noattr))) :: (_t'8, tint) ::
               (_t'7, tint) :: (_t'6, tint) ::
               (_t'5, (tptr (Tunion __549 noattr))) ::
               (_t'4, (tptr (Tunion __549 noattr))) ::
               (_t'3, (tptr (Tunion __549 noattr))) ::
               (_t'2, (tptr (Tunion __549 noattr))) ::
               (_t'1, (tptr tvoid)) :: (_t'13, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                    (tptr tvoid) cc_default))
      ((Eaddrof
         (Evar _power_meter_health_segments_lut (tarray (tptr tuchar) 0))
         (tptr (tarray (tptr tuchar) 0))) :: nil))
    (Sset _healthLUT (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
          (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
            (Ebinop Oadd (Etempvar _t'2 (tptr (Tunion __549 noattr)))
              (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
        (Sset __g
          (Ecast (Etempvar _t'2 (tptr (Tunion __549 noattr)))
            (tptr (Tunion __549 noattr)))))
      (Ssequence
        (Sassign
          (Efield
            (Efield
              (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
                (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
            tuint)
          (Ecast
            (Ebinop Oshl
              (Ebinop Oand (Ecast (Econst_int (Int.repr 231) tint) tuint)
                (Ebinop Osub
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 8) tint) tint)
                  (Econst_int (Int.repr 1) tint) tint) tuint)
              (Econst_int (Int.repr 24) tint) tuint) tuint))
        (Sassign
          (Efield
            (Efield
              (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
                (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
            tuint) (Econst_int (Int.repr 0) tint))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'3 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
            (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
              (Ebinop Oadd (Etempvar _t'3 (tptr (Tunion __549 noattr)))
                (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
          (Sset __g__1
            (Ecast (Etempvar _t'3 (tptr (Tunion __549 noattr)))
              (tptr (Tunion __549 noattr)))))
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                  (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
              tuint)
            (Ebinop Oor
              (Ebinop Oor
                (Ebinop Oor
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 253) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 8) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 24) tint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 0) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 3) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 21) tint) tuint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand (Ecast (Econst_int (Int.repr 2) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 2) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 19) tint) tuint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand
                    (Ecast
                      (Ebinop Osub (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 12) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
          (Ssequence
            (Sset _t'13
              (Ederef
                (Ebinop Oadd
                  (Ederef
                    (Etempvar _healthLUT (tptr (tarray (tptr tuchar) 0)))
                    (tarray (tptr tuchar) 0))
                  (Ebinop Osub (Etempvar _numHealthWedges tshort)
                    (Econst_int (Int.repr 1) tint) tint)
                  (tptr (tptr tuchar))) (tptr tuchar)))
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
                tuint) (Ecast (Etempvar _t'13 (tptr tuchar)) tuint)))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
              (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                (Ebinop Oadd (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                  (Econst_int (Int.repr 1) tint)
                  (tptr (Tunion __549 noattr)))))
            (Sset __g__2
              (Ecast (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                (tptr (Tunion __549 noattr)))))
          (Ssequence
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
                tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand (Ecast (Econst_int (Int.repr 230) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 8) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 24) tint) tuint) tuint))
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
                tuint) (Econst_int (Int.repr 0) tint))))
        (Ssequence
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                (Sassign
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                  (Ebinop Oadd (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                    (Econst_int (Int.repr 1) tint)
                    (tptr (Tunion __549 noattr)))))
              (Sset __g__3
                (Ecast (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                  (tptr (Tunion __549 noattr)))))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w0 tuint)
                (Ebinop Oor
                  (Ebinop Oor
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 243) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 24) tint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 0) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 12) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 12) tint) tuint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 0) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 12) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sifthenelse (Ebinop Olt
                                   (Ebinop Osub
                                     (Ebinop Omul
                                       (Econst_int (Int.repr 32) tint)
                                       (Econst_int (Int.repr 32) tint) tint)
                                     (Econst_int (Int.repr 1) tint) tint)
                                   (Econst_int (Int.repr 2047) tint) tint)
                      (Sset _t'6
                        (Ecast
                          (Ebinop Osub
                            (Ebinop Omul (Econst_int (Int.repr 32) tint)
                              (Econst_int (Int.repr 32) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tint))
                      (Sset _t'6
                        (Ecast (Econst_int (Int.repr 2047) tint) tint)))
                    (Sifthenelse (Ebinop Ogt (Econst_int (Int.repr 1) tint)
                                   (Ebinop Odiv
                                     (Ebinop Omul
                                       (Econst_int (Int.repr 32) tint)
                                       (Econst_int (Int.repr 2) tint) tint)
                                     (Econst_int (Int.repr 8) tint) tint)
                                   tint)
                      (Sset _t'7 (Ecast (Econst_int (Int.repr 1) tint) tint))
                      (Sset _t'7
                        (Ecast
                          (Ebinop Odiv
                            (Ebinop Omul (Econst_int (Int.repr 32) tint)
                              (Econst_int (Int.repr 2) tint) tint)
                            (Econst_int (Int.repr 8) tint) tint) tint))))
                  (Sifthenelse (Ebinop Ogt (Econst_int (Int.repr 1) tint)
                                 (Ebinop Odiv
                                   (Ebinop Omul
                                     (Econst_int (Int.repr 32) tint)
                                     (Econst_int (Int.repr 2) tint) tint)
                                   (Econst_int (Int.repr 8) tint) tint) tint)
                    (Sset _t'8 (Ecast (Econst_int (Int.repr 1) tint) tint))
                    (Sset _t'8
                      (Ecast
                        (Ebinop Odiv
                          (Ebinop Omul (Econst_int (Int.repr 32) tint)
                            (Econst_int (Int.repr 2) tint) tint)
                          (Econst_int (Int.repr 8) tint) tint) tint))))
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                        (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                    _w1 tuint)
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 7) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 3) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 24) tint) tuint) tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand (Ecast (Etempvar _t'6 tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 12) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 12) tint) tuint) tuint)
                      tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast
                            (Ebinop Odiv
                              (Ebinop Osub
                                (Ebinop Oadd
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 11) tint) tint)
                                  (Etempvar _t'7 tint) tint)
                                (Econst_int (Int.repr 1) tint) tint)
                              (Etempvar _t'8 tint) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 12) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 0) tint) tuint) tuint) tuint)))))
          (Ssequence
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'9
                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                  (Sassign
                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                    (Ebinop Oadd (Etempvar _t'9 (tptr (Tunion __549 noattr)))
                      (Econst_int (Int.repr 1) tint)
                      (tptr (Tunion __549 noattr)))))
                (Sset __g__4
                  (Ecast (Etempvar _t'9 (tptr (Tunion __549 noattr)))
                    (tptr (Tunion __549 noattr)))))
              (Ssequence
                (Ssequence
                  (Sifthenelse (Ebinop Oeq (Econst_int (Int.repr 0) tint)
                                 (Econst_int (Int.repr 0) tint) tint)
                    (Sset _t'10
                      (Ecast
                        (Ebinop Oor
                          (Ebinop Oor
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast
                                    (Ebinop Omul
                                      (Econst_int (Int.repr 0) tint)
                                      (Econst_int (Int.repr 2) tint) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 8) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 16) tint)
                                tuint) tuint)
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast
                                    (Ebinop Omul
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 2) tint) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 8) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 8) tint)
                                tuint) tuint) tuint)
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast
                                  (Ebinop Omul (Econst_int (Int.repr 2) tint)
                                    (Econst_int (Int.repr 2) tint) tint)
                                  tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 8) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 0) tint) tuint) tuint)
                          tuint) tuint))
                    (Sifthenelse (Ebinop Oeq (Econst_int (Int.repr 0) tint)
                                   (Econst_int (Int.repr 1) tint) tint)
                      (Ssequence
                        (Sset _t'10
                          (Ecast
                            (Ebinop Oor
                              (Ebinop Oor
                                (Ecast
                                  (Ebinop Oshl
                                    (Ebinop Oand
                                      (Ecast
                                        (Ebinop Omul
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 2) tint)
                                          tint) tuint)
                                      (Ebinop Osub
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 8) tint)
                                          tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuint) (Econst_int (Int.repr 16) tint)
                                    tuint) tuint)
                                (Ecast
                                  (Ebinop Oshl
                                    (Ebinop Oand
                                      (Ecast
                                        (Ebinop Omul
                                          (Econst_int (Int.repr 2) tint)
                                          (Econst_int (Int.repr 2) tint)
                                          tint) tuint)
                                      (Ebinop Osub
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 8) tint)
                                          tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuint) (Econst_int (Int.repr 8) tint)
                                    tuint) tuint) tuint)
                              (Ecast
                                (Ebinop Oshl
                                  (Ebinop Oand
                                    (Ecast
                                      (Ebinop Omul
                                        (Econst_int (Int.repr 0) tint)
                                        (Econst_int (Int.repr 2) tint) tint)
                                      tuint)
                                    (Ebinop Osub
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 8) tint) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuint) (Econst_int (Int.repr 0) tint)
                                  tuint) tuint) tuint) tuint))
                        (Sset _t'10 (Ecast (Etempvar _t'10 tuint) tuint)))
                      (Ssequence
                        (Sset _t'10
                          (Ecast
                            (Ebinop Oor
                              (Ebinop Oor
                                (Ecast
                                  (Ebinop Oshl
                                    (Ebinop Oand
                                      (Ecast
                                        (Ebinop Omul
                                          (Econst_int (Int.repr 2) tint)
                                          (Econst_int (Int.repr 2) tint)
                                          tint) tuint)
                                      (Ebinop Osub
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 8) tint)
                                          tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuint) (Econst_int (Int.repr 16) tint)
                                    tuint) tuint)
                                (Ecast
                                  (Ebinop Oshl
                                    (Ebinop Oand
                                      (Ecast
                                        (Ebinop Omul
                                          (Econst_int (Int.repr 0) tint)
                                          (Econst_int (Int.repr 2) tint)
                                          tint) tuint)
                                      (Ebinop Osub
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 8) tint)
                                          tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuint) (Econst_int (Int.repr 8) tint)
                                    tuint) tuint) tuint)
                              (Ecast
                                (Ebinop Oshl
                                  (Ebinop Oand
                                    (Ecast
                                      (Ebinop Omul
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 2) tint) tint)
                                      tuint)
                                    (Ebinop Osub
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 8) tint) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuint) (Econst_int (Int.repr 0) tint)
                                  tuint) tuint) tuint) tuint))
                        (Sset _t'10 (Ecast (Etempvar _t'10 tuint) tuint)))))
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                          (Tunion __549 noattr)) _words
                        (Tstruct __547 noattr)) _w0 tuint)
                    (Ebinop Oor
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 5) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 24) tint) tuint) tuint)
                      (Etempvar _t'10 tuint) tuint)))
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                        (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                    _w1 tuint) (Econst_int (Int.repr 0) tint))))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'11
                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                  (Sassign
                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                    (Ebinop Oadd
                      (Etempvar _t'11 (tptr (Tunion __549 noattr)))
                      (Econst_int (Int.repr 1) tint)
                      (tptr (Tunion __549 noattr)))))
                (Sset __g__5
                  (Ecast (Etempvar _t'11 (tptr (Tunion __549 noattr)))
                    (tptr (Tunion __549 noattr)))))
              (Ssequence
                (Ssequence
                  (Sifthenelse (Ebinop Oeq (Econst_int (Int.repr 0) tint)
                                 (Econst_int (Int.repr 0) tint) tint)
                    (Sset _t'12
                      (Ecast
                        (Ebinop Oor
                          (Ebinop Oor
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast
                                    (Ebinop Omul
                                      (Econst_int (Int.repr 0) tint)
                                      (Econst_int (Int.repr 2) tint) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 8) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 16) tint)
                                tuint) tuint)
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast
                                    (Ebinop Omul
                                      (Econst_int (Int.repr 2) tint)
                                      (Econst_int (Int.repr 2) tint) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 8) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 8) tint)
                                tuint) tuint) tuint)
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast
                                  (Ebinop Omul (Econst_int (Int.repr 3) tint)
                                    (Econst_int (Int.repr 2) tint) tint)
                                  tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 8) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 0) tint) tuint) tuint)
                          tuint) tuint))
                    (Sifthenelse (Ebinop Oeq (Econst_int (Int.repr 0) tint)
                                   (Econst_int (Int.repr 1) tint) tint)
                      (Ssequence
                        (Sset _t'12
                          (Ecast
                            (Ebinop Oor
                              (Ebinop Oor
                                (Ecast
                                  (Ebinop Oshl
                                    (Ebinop Oand
                                      (Ecast
                                        (Ebinop Omul
                                          (Econst_int (Int.repr 2) tint)
                                          (Econst_int (Int.repr 2) tint)
                                          tint) tuint)
                                      (Ebinop Osub
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 8) tint)
                                          tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuint) (Econst_int (Int.repr 16) tint)
                                    tuint) tuint)
                                (Ecast
                                  (Ebinop Oshl
                                    (Ebinop Oand
                                      (Ecast
                                        (Ebinop Omul
                                          (Econst_int (Int.repr 3) tint)
                                          (Econst_int (Int.repr 2) tint)
                                          tint) tuint)
                                      (Ebinop Osub
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 8) tint)
                                          tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuint) (Econst_int (Int.repr 8) tint)
                                    tuint) tuint) tuint)
                              (Ecast
                                (Ebinop Oshl
                                  (Ebinop Oand
                                    (Ecast
                                      (Ebinop Omul
                                        (Econst_int (Int.repr 0) tint)
                                        (Econst_int (Int.repr 2) tint) tint)
                                      tuint)
                                    (Ebinop Osub
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 8) tint) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuint) (Econst_int (Int.repr 0) tint)
                                  tuint) tuint) tuint) tuint))
                        (Sset _t'12 (Ecast (Etempvar _t'12 tuint) tuint)))
                      (Ssequence
                        (Sset _t'12
                          (Ecast
                            (Ebinop Oor
                              (Ebinop Oor
                                (Ecast
                                  (Ebinop Oshl
                                    (Ebinop Oand
                                      (Ecast
                                        (Ebinop Omul
                                          (Econst_int (Int.repr 3) tint)
                                          (Econst_int (Int.repr 2) tint)
                                          tint) tuint)
                                      (Ebinop Osub
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 8) tint)
                                          tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuint) (Econst_int (Int.repr 16) tint)
                                    tuint) tuint)
                                (Ecast
                                  (Ebinop Oshl
                                    (Ebinop Oand
                                      (Ecast
                                        (Ebinop Omul
                                          (Econst_int (Int.repr 0) tint)
                                          (Econst_int (Int.repr 2) tint)
                                          tint) tuint)
                                      (Ebinop Osub
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 8) tint)
                                          tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuint) (Econst_int (Int.repr 8) tint)
                                    tuint) tuint) tuint)
                              (Ecast
                                (Ebinop Oshl
                                  (Ebinop Oand
                                    (Ecast
                                      (Ebinop Omul
                                        (Econst_int (Int.repr 2) tint)
                                        (Econst_int (Int.repr 2) tint) tint)
                                      tuint)
                                    (Ebinop Osub
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 8) tint) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuint) (Econst_int (Int.repr 0) tint)
                                  tuint) tuint) tuint) tuint))
                        (Sset _t'12 (Ecast (Etempvar _t'12 tuint) tuint)))))
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__5 (tptr (Tunion __549 noattr)))
                          (Tunion __549 noattr)) _words
                        (Tstruct __547 noattr)) _w0 tuint)
                    (Ebinop Oor
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 5) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 24) tint) tuint) tuint)
                      (Etempvar _t'12 tuint) tuint)))
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__5 (tptr (Tunion __549 noattr)))
                        (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                    _w1 tuint) (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_render_dl_power_meter := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_numHealthWedges, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_mtx, (tptr (Tunion __472 noattr))) ::
               (__g, (tptr (Tunion __549 noattr))) ::
               (__g__1, (tptr (Tunion __549 noattr))) ::
               (__g__2, (tptr (Tunion __549 noattr))) ::
               (__g__3, (tptr (Tunion __549 noattr))) ::
               (__g__4, (tptr (Tunion __549 noattr))) ::
               (_t'7, (tptr (Tunion __549 noattr))) ::
               (_t'6, (tptr (Tunion __549 noattr))) ::
               (_t'5, (tptr (Tunion __549 noattr))) ::
               (_t'4, (tptr (Tunion __549 noattr))) ::
               (_t'3, (tptr (Tunion __472 noattr))) ::
               (_t'2, (tptr (Tunion __549 noattr))) ::
               (_t'1, (tptr tvoid)) :: (_t'9, tshort) :: (_t'8, tshort) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                  cc_default))
      ((Esizeof (Tunion __472 noattr) tuint) :: nil))
    (Sset _mtx (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Sifthenelse (Ebinop Oeq (Etempvar _mtx (tptr (Tunion __472 noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Sreturn None)
      Sskip)
    (Ssequence
      (Ssequence
        (Sset _t'8
          (Efield (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr)) _x
            tshort))
        (Ssequence
          (Sset _t'9
            (Efield (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr)) _y
              tshort))
          (Scall None
            (Evar _guTranslate (Tfunction
                                 ((tptr (Tunion __472 noattr)) :: tfloat ::
                                  tfloat :: tfloat :: nil) tvoid cc_default))
            ((Etempvar _mtx (tptr (Tunion __472 noattr))) ::
             (Ecast (Etempvar _t'8 tshort) tfloat) ::
             (Ecast (Etempvar _t'9 tshort) tfloat) ::
             (Econst_int (Int.repr 0) tint) :: nil))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'2
                (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
              (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                (Ebinop Oadd (Etempvar _t'2 (tptr (Tunion __549 noattr)))
                  (Econst_int (Int.repr 1) tint)
                  (tptr (Tunion __549 noattr)))))
            (Sset __g
              (Ecast (Etempvar _t'2 (tptr (Tunion __549 noattr)))
                (tptr (Tunion __549 noattr)))))
          (Ssequence
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
                tuint)
              (Ebinop Oor
                (Ebinop Oor
                  (Ebinop Oor
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 218) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 24) tint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast
                            (Ebinop Odiv
                              (Ebinop Osub
                                (Esizeof (Tunion __472 noattr) tuint)
                                (Econst_int (Int.repr 1) tint) tuint)
                              (Econst_int (Int.repr 8) tint) tuint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 5) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 19) tint) tuint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast
                          (Ebinop Odiv (Econst_int (Int.repr 0) tint)
                            (Econst_int (Int.repr 8) tint) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 8) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 8) tint) tuint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast
                        (Ebinop Oxor
                          (Ebinop Oor
                            (Ebinop Oor (Econst_int (Int.repr 0) tint)
                              (Econst_int (Int.repr 0) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
            (Ssequence
              (Ssequence
                (Sset _t'3 (Etempvar _mtx (tptr (Tunion __472 noattr))))
                (Sset _mtx
                  (Ebinop Oadd (Etempvar _t'3 (tptr (Tunion __472 noattr)))
                    (Econst_int (Int.repr 1) tint)
                    (tptr (Tunion __472 noattr)))))
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w1 tuint)
                (Ecast
                  (Ecast (Etempvar _t'3 (tptr (Tunion __472 noattr))) tuint)
                  tuint)))))
        (Ssequence
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'4
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                (Sassign
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                  (Ebinop Oadd (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                    (Econst_int (Int.repr 1) tint)
                    (tptr (Tunion __549 noattr)))))
              (Sset __g__1
                (Ecast (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                  (tptr (Tunion __549 noattr)))))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w0 tuint)
                (Ebinop Oor
                  (Ebinop Oor
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 222) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 24) tint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 0) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 16) tint) tuint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 0) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 16) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w1 tuint)
                (Ecast
                  (Eaddrof
                    (Evar _dl_power_meter_base (tarray (Tunion __549 noattr) 0))
                    (tptr (tarray (Tunion __549 noattr) 0))) tuint))))
          (Ssequence
            (Sifthenelse (Ebinop One (Etempvar _numHealthWedges tshort)
                           (Econst_int (Int.repr 0) tint) tint)
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'5
                        (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                      (Sassign
                        (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                        (Ebinop Oadd
                          (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                          (Econst_int (Int.repr 1) tint)
                          (tptr (Tunion __549 noattr)))))
                    (Sset __g__2
                      (Ecast (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                        (tptr (Tunion __549 noattr)))))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                            (Tunion __549 noattr)) _words
                          (Tstruct __547 noattr)) _w0 tuint)
                      (Ebinop Oor
                        (Ebinop Oor
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast (Econst_int (Int.repr 222) tint)
                                  tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 8) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 24) tint) tuint) tuint)
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast (Econst_int (Int.repr 0) tint) tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 8) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 16) tint) tuint) tuint)
                          tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 0) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 16) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 0) tint) tuint) tuint)
                        tuint))
                    (Sassign
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                            (Tunion __549 noattr)) _words
                          (Tstruct __547 noattr)) _w1 tuint)
                      (Ecast
                        (Eaddrof
                          (Evar _dl_power_meter_health_segments_begin (tarray (Tunion __549 noattr) 0))
                          (tptr (tarray (Tunion __549 noattr) 0))) tuint))))
                (Ssequence
                  (Scall None
                    (Evar _render_power_meter_health_segment (Tfunction
                                                               (tshort ::
                                                                nil) tvoid
                                                               cc_default))
                    ((Etempvar _numHealthWedges tshort) :: nil))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'6
                          (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                        (Sassign
                          (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                          (Ebinop Oadd
                            (Etempvar _t'6 (tptr (Tunion __549 noattr)))
                            (Econst_int (Int.repr 1) tint)
                            (tptr (Tunion __549 noattr)))))
                      (Sset __g__3
                        (Ecast (Etempvar _t'6 (tptr (Tunion __549 noattr)))
                          (tptr (Tunion __549 noattr)))))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                              (Tunion __549 noattr)) _words
                            (Tstruct __547 noattr)) _w0 tuint)
                        (Ebinop Oor
                          (Ebinop Oor
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Econst_int (Int.repr 222) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 8) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 24) tint)
                                tuint) tuint)
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Econst_int (Int.repr 0) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 8) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 16) tint)
                                tuint) tuint) tuint)
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast (Econst_int (Int.repr 0) tint) tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 16) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 0) tint) tuint) tuint)
                          tuint))
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                              (Tunion __549 noattr)) _words
                            (Tstruct __547 noattr)) _w1 tuint)
                        (Ecast
                          (Eaddrof
                            (Evar _dl_power_meter_health_segments_end (tarray (Tunion __549 noattr) 0))
                            (tptr (tarray (Tunion __549 noattr) 0))) tuint))))))
              Sskip)
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'7
                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                  (Sassign
                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                    (Ebinop Oadd (Etempvar _t'7 (tptr (Tunion __549 noattr)))
                      (Econst_int (Int.repr 1) tint)
                      (tptr (Tunion __549 noattr)))))
                (Sset __g__4
                  (Ecast (Etempvar _t'7 (tptr (Tunion __549 noattr)))
                    (tptr (Tunion __549 noattr)))))
              (Ssequence
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                        (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                    _w0 tuint)
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 216) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 8) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 24) tint) tuint) tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast
                                (Ebinop Odiv
                                  (Ebinop Osub
                                    (Econst_int (Int.repr 64) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  (Econst_int (Int.repr 8) tint) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 5) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 19) tint) tuint) tuint)
                        tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast
                              (Ebinop Odiv (Econst_int (Int.repr 0) tint)
                                (Econst_int (Int.repr 8) tint) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 8) tint) tuint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 2) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                        (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                    _w1 tuint)
                  (Ecast
                    (Ebinop Omul (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 64) tint) tint) tuint))))))))))
|}.

Definition f_animate_power_meter_emphasized := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_hudDisplayFlags, tshort) :: (_t'2, tshort) ::
               (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2
      (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr)) _flags tshort))
    (Sset _hudDisplayFlags (Ecast (Etempvar _t'2 tshort) tshort)))
  (Sifthenelse (Eunop Onotbool
                 (Ebinop Oand (Etempvar _hudDisplayFlags tshort)
                   (Econst_int (Int.repr 32768) tint) tint) tint)
    (Ssequence
      (Sset _t'1 (Evar _sPowerMeterVisibleTimer tint))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tint)
                     (Econst_float (Float.of_bits (Int64.repr 4631530004285489152)) tdouble)
                     tint)
        (Sassign
          (Efield (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr))
            _animation tschar) (Econst_int (Int.repr 2) tint))
        Sskip))
    (Sassign (Evar _sPowerMeterVisibleTimer tint)
      (Econst_int (Int.repr 0) tint))))
|}.

Definition f_animate_power_meter_deemphasizing := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_speed, tshort) :: (_t'5, tshort) :: (_t'4, tshort) ::
               (_t'3, tshort) :: (_t'2, tshort) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _speed (Ecast (Econst_int (Int.repr 5) tint) tshort))
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Efield (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr)) _y
          tshort))
      (Sifthenelse (Ebinop Ogt (Etempvar _t'5 tshort)
                     (Econst_int (Int.repr 180) tint) tint)
        (Sset _speed (Ecast (Econst_int (Int.repr 3) tint) tshort))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'4
          (Efield (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr)) _y
            tshort))
        (Sifthenelse (Ebinop Ogt (Etempvar _t'4 tshort)
                       (Econst_int (Int.repr 190) tint) tint)
          (Sset _speed (Ecast (Econst_int (Int.repr 2) tint) tshort))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr)) _y
              tshort))
          (Sifthenelse (Ebinop Ogt (Etempvar _t'3 tshort)
                         (Econst_int (Int.repr 195) tint) tint)
            (Sset _speed (Ecast (Econst_int (Int.repr 1) tint) tshort))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'2
              (Efield (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr))
                _y tshort))
            (Sassign
              (Efield (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr))
                _y tshort)
              (Ebinop Oadd (Etempvar _t'2 tshort) (Etempvar _speed tshort)
                tint)))
          (Ssequence
            (Sset _t'1
              (Efield (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr))
                _y tshort))
            (Sifthenelse (Ebinop Ogt (Etempvar _t'1 tshort)
                           (Econst_int (Int.repr 200) tint) tint)
              (Ssequence
                (Sassign
                  (Efield
                    (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr)) _y
                    tshort) (Econst_int (Int.repr 200) tint))
                (Sassign
                  (Efield
                    (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr))
                    _animation tschar) (Econst_int (Int.repr 4) tint)))
              Sskip)))))))
|}.

Definition f_animate_power_meter_hiding := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, tshort) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2
      (Efield (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr)) _y
        tshort))
    (Sassign
      (Efield (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr)) _y
        tshort)
      (Ebinop Oadd (Etempvar _t'2 tshort) (Econst_int (Int.repr 20) tint)
        tint)))
  (Ssequence
    (Sset _t'1
      (Efield (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr)) _y
        tshort))
    (Sifthenelse (Ebinop Ogt (Etempvar _t'1 tshort)
                   (Econst_int (Int.repr 300) tint) tint)
      (Ssequence
        (Sassign
          (Efield (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr))
            _animation tschar) (Econst_int (Int.repr 0) tint))
        (Sassign (Evar _sPowerMeterVisibleTimer tint)
          (Econst_int (Int.repr 0) tint)))
      Sskip)))
|}.

Definition f_handle_power_meter_actions := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_numHealthWedges, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'5, tint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'12, tshort) ::
               (_t'11, tschar) :: (_t'10, tshort) :: (_t'9, tint) ::
               (_t'8, tschar) :: (_t'7, tschar) :: (_t'6, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sifthenelse (Ebinop Olt (Etempvar _numHealthWedges tshort)
                     (Econst_int (Int.repr 8) tint) tint)
        (Ssequence
          (Sset _t'12 (Evar _sPowerMeterStoredHealth tshort))
          (Sset _t'1
            (Ecast
              (Ebinop Oeq (Etempvar _t'12 tshort)
                (Econst_int (Int.repr 8) tint) tint) tbool)))
        (Sset _t'1 (Econst_int (Int.repr 0) tint)))
      (Sifthenelse (Etempvar _t'1 tint)
        (Ssequence
          (Sset _t'11
            (Efield (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr))
              _animation tschar))
          (Sset _t'2
            (Ecast
              (Ebinop Oeq (Etempvar _t'11 tschar)
                (Econst_int (Int.repr 0) tint) tint) tbool)))
        (Sset _t'2 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'2 tint)
      (Ssequence
        (Sassign
          (Efield (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr))
            _animation tschar) (Econst_int (Int.repr 1) tint))
        (Sassign
          (Efield (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr)) _y
            tshort) (Econst_int (Int.repr 166) tint)))
      Sskip))
  (Ssequence
    (Ssequence
      (Sifthenelse (Ebinop Oeq (Etempvar _numHealthWedges tshort)
                     (Econst_int (Int.repr 8) tint) tint)
        (Ssequence
          (Sset _t'10 (Evar _sPowerMeterStoredHealth tshort))
          (Sset _t'3
            (Ecast
              (Ebinop Oeq (Etempvar _t'10 tshort)
                (Econst_int (Int.repr 7) tint) tint) tbool)))
        (Sset _t'3 (Econst_int (Int.repr 0) tint)))
      (Sifthenelse (Etempvar _t'3 tint)
        (Sassign (Evar _sPowerMeterVisibleTimer tint)
          (Econst_int (Int.repr 0) tint))
        Sskip))
    (Ssequence
      (Ssequence
        (Sifthenelse (Ebinop Oeq (Etempvar _numHealthWedges tshort)
                       (Econst_int (Int.repr 8) tint) tint)
          (Ssequence
            (Sset _t'9 (Evar _sPowerMeterVisibleTimer tint))
            (Sset _t'4
              (Ecast
                (Ebinop Ogt (Etempvar _t'9 tint)
                  (Econst_float (Float.of_bits (Int64.repr 4631530004285489152)) tdouble)
                  tint) tbool)))
          (Sset _t'4 (Econst_int (Int.repr 0) tint)))
        (Sifthenelse (Etempvar _t'4 tint)
          (Sassign
            (Efield (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr))
              _animation tschar) (Econst_int (Int.repr 3) tint))
          Sskip))
      (Ssequence
        (Sassign (Evar _sPowerMeterStoredHealth tshort)
          (Etempvar _numHealthWedges tshort))
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef
                (Evar _gPlayerCameraState (tarray (Tstruct _PlayerCameraState noattr) 2))
                (Tstruct _PlayerCameraState noattr)) _action tuint))
          (Sifthenelse (Ebinop Oand (Etempvar _t'6 tuint)
                         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 13) tint) tint) tuint)
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'7
                    (Efield
                      (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr))
                      _animation tschar))
                  (Sifthenelse (Ebinop Oeq (Etempvar _t'7 tschar)
                                 (Econst_int (Int.repr 0) tint) tint)
                    (Sset _t'5 (Econst_int (Int.repr 1) tint))
                    (Ssequence
                      (Sset _t'8
                        (Efield
                          (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr))
                          _animation tschar))
                      (Sset _t'5
                        (Ecast
                          (Ebinop Oeq (Etempvar _t'8 tschar)
                            (Econst_int (Int.repr 1) tint) tint) tbool)))))
                (Sifthenelse (Etempvar _t'5 tint)
                  (Ssequence
                    (Sassign
                      (Efield
                        (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr))
                        _animation tschar) (Econst_int (Int.repr 2) tint))
                    (Sassign
                      (Efield
                        (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr))
                        _y tshort) (Econst_int (Int.repr 166) tint)))
                  Sskip))
              (Sassign (Evar _sPowerMeterVisibleTimer tint)
                (Econst_int (Int.repr 0) tint)))
            Sskip))))))
|}.

Definition f_render_hud_power_meter := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_shownHealthWedges, tshort) :: (_t'5, tshort) ::
               (_t'4, tschar) :: (_t'3, tschar) :: (_t'2, tschar) ::
               (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5
      (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr)) _wedges
        tshort))
    (Sset _shownHealthWedges (Ecast (Etempvar _t'5 tshort) tshort)))
  (Ssequence
    (Ssequence
      (Sset _t'4
        (Efield (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr))
          _animation tschar))
      (Sifthenelse (Ebinop One (Etempvar _t'4 tschar)
                     (Econst_int (Int.repr 3) tint) tint)
        (Scall None
          (Evar _handle_power_meter_actions (Tfunction (tshort :: nil) tvoid
                                              cc_default))
          ((Etempvar _shownHealthWedges tshort) :: nil))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Efield (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr))
            _animation tschar))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tschar)
                       (Econst_int (Int.repr 0) tint) tint)
          (Sreturn None)
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'2
            (Efield (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr))
              _animation tschar))
          (Sswitch (Etempvar _t'2 tschar)
            (LScons (Some 1)
              (Ssequence
                (Scall None
                  (Evar _animate_power_meter_emphasized (Tfunction nil tvoid
                                                          cc_default)) nil)
                Sbreak)
              (LScons (Some 2)
                (Ssequence
                  (Scall None
                    (Evar _animate_power_meter_deemphasizing (Tfunction nil
                                                               tvoid
                                                               cc_default))
                    nil)
                  Sbreak)
                (LScons (Some 3)
                  (Ssequence
                    (Scall None
                      (Evar _animate_power_meter_hiding (Tfunction nil tvoid
                                                          cc_default)) nil)
                    Sbreak)
                  (LScons None Sbreak LSnil))))))
        (Ssequence
          (Scall None
            (Evar _render_dl_power_meter (Tfunction (tshort :: nil) tvoid
                                           cc_default))
            ((Etempvar _shownHealthWedges tshort) :: nil))
          (Ssequence
            (Sset _t'1 (Evar _sPowerMeterVisibleTimer tint))
            (Sassign (Evar _sPowerMeterVisibleTimer tint)
              (Ebinop Oadd (Etempvar _t'1 tint)
                (Econst_int (Int.repr 1) tint) tint))))))))
|}.

Definition f_render_hud_mario_lives := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _print_text (Tfunction (tint :: tint :: (tptr tuchar) :: nil) tvoid
                        cc_default))
    ((Econst_int (Int.repr 22) tint) :: (Econst_int (Int.repr 209) tint) ::
     (Evar ___stringlit_1 (tarray tuchar 2)) :: nil))
  (Ssequence
    (Scall None
      (Evar _print_text (Tfunction (tint :: tint :: (tptr tuchar) :: nil)
                          tvoid cc_default))
      ((Econst_int (Int.repr 38) tint) :: (Econst_int (Int.repr 209) tint) ::
       (Evar ___stringlit_2 (tarray tuchar 2)) :: nil))
    (Ssequence
      (Sset _t'1
        (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr)) _lives
          tshort))
      (Scall None
        (Evar _print_text_fmt_int (Tfunction
                                    (tint :: tint :: (tptr tuchar) :: tint ::
                                     nil) tvoid cc_default))
        ((Econst_int (Int.repr 54) tint) ::
         (Econst_int (Int.repr 209) tint) ::
         (Evar ___stringlit_3 (tarray tuchar 3)) :: (Etempvar _t'1 tshort) ::
         nil)))))
|}.

Definition f_render_hud_coins := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _print_text (Tfunction (tint :: tint :: (tptr tuchar) :: nil) tvoid
                        cc_default))
    ((Econst_int (Int.repr 168) tint) :: (Econst_int (Int.repr 209) tint) ::
     (Evar ___stringlit_4 (tarray tuchar 2)) :: nil))
  (Ssequence
    (Scall None
      (Evar _print_text (Tfunction (tint :: tint :: (tptr tuchar) :: nil)
                          tvoid cc_default))
      ((Econst_int (Int.repr 184) tint) ::
       (Econst_int (Int.repr 209) tint) ::
       (Evar ___stringlit_2 (tarray tuchar 2)) :: nil))
    (Ssequence
      (Sset _t'1
        (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr)) _coins
          tshort))
      (Scall None
        (Evar _print_text_fmt_int (Tfunction
                                    (tint :: tint :: (tptr tuchar) :: tint ::
                                     nil) tvoid cc_default))
        ((Econst_int (Int.repr 198) tint) ::
         (Econst_int (Int.repr 209) tint) ::
         (Evar ___stringlit_3 (tarray tuchar 3)) :: (Etempvar _t'1 tshort) ::
         nil)))))
|}.

Definition f_render_hud_stars := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_showX, tschar) :: (_t'1, tint) :: (_t'5, tuint) ::
               (_t'4, tschar) :: (_t'3, tshort) :: (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _showX (Ecast (Econst_int (Int.repr 0) tint) tschar))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'4 (Evar _gHudFlash tschar))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tschar)
                       (Econst_int (Int.repr 1) tint) tint)
          (Ssequence
            (Sset _t'5 (Evar _gGlobalTimer tuint))
            (Sset _t'1
              (Ecast
                (Ebinop Oand (Etempvar _t'5 tuint)
                  (Econst_int (Int.repr 8) tint) tuint) tbool)))
          (Sset _t'1 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'1 tint) (Sreturn None) Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr)) _stars
            tshort))
        (Sifthenelse (Ebinop Olt (Etempvar _t'3 tshort)
                       (Econst_int (Int.repr 100) tint) tint)
          (Sset _showX (Ecast (Econst_int (Int.repr 1) tint) tschar))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _print_text (Tfunction (tint :: tint :: (tptr tuchar) :: nil)
                              tvoid cc_default))
          ((Ebinop Osub (Econst_int (Int.repr 320) tint)
             (Econst_int (Int.repr 78) tint) tint) ::
           (Econst_int (Int.repr 209) tint) ::
           (Evar ___stringlit_5 (tarray tuchar 2)) :: nil))
        (Ssequence
          (Sifthenelse (Ebinop Oeq (Etempvar _showX tschar)
                         (Econst_int (Int.repr 1) tint) tint)
            (Scall None
              (Evar _print_text (Tfunction
                                  (tint :: tint :: (tptr tuchar) :: nil)
                                  tvoid cc_default))
              ((Ebinop Oadd
                 (Ebinop Osub (Econst_int (Int.repr 320) tint)
                   (Econst_int (Int.repr 78) tint) tint)
                 (Econst_int (Int.repr 16) tint) tint) ::
               (Econst_int (Int.repr 209) tint) ::
               (Evar ___stringlit_2 (tarray tuchar 2)) :: nil))
            Sskip)
          (Ssequence
            (Sset _t'2
              (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr)) _stars
                tshort))
            (Scall None
              (Evar _print_text_fmt_int (Tfunction
                                          (tint :: tint :: (tptr tuchar) ::
                                           tint :: nil) tvoid cc_default))
              ((Ebinop Oadd
                 (Ebinop Omul (Etempvar _showX tschar)
                   (Econst_int (Int.repr 14) tint) tint)
                 (Ebinop Osub (Econst_int (Int.repr 320) tint)
                   (Ebinop Osub (Econst_int (Int.repr 78) tint)
                     (Econst_int (Int.repr 16) tint) tint) tint) tint) ::
               (Econst_int (Int.repr 209) tint) ::
               (Evar ___stringlit_3 (tarray tuchar 3)) ::
               (Etempvar _t'2 tshort) :: nil))))))))
|}.

Definition f_render_hud_keys := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_i, tshort) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tshort))
  (Sloop
    (Ssequence
      (Ssequence
        (Sset _t'1
          (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr)) _keys
            tshort))
        (Sifthenelse (Ebinop Olt (Etempvar _i tshort) (Etempvar _t'1 tshort)
                       tint)
          Sskip
          Sbreak))
      (Scall None
        (Evar _print_text (Tfunction (tint :: tint :: (tptr tuchar) :: nil)
                            tvoid cc_default))
        ((Ebinop Oadd
           (Ebinop Omul (Etempvar _i tshort) (Econst_int (Int.repr 16) tint)
             tint) (Econst_int (Int.repr 220) tint) tint) ::
         (Econst_int (Int.repr 142) tint) ::
         (Evar ___stringlit_6 (tarray tuchar 2)) :: nil)))
    (Sset _i
      (Ecast
        (Ebinop Oadd (Etempvar _i tshort) (Econst_int (Int.repr 1) tint)
          tint) tshort))))
|}.

Definition f_render_hud_timer := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_hudLUT, (tptr (tarray (tptr tuchar) 58))) ::
               (_timerValFrames, tushort) :: (_timerMins, tushort) ::
               (_timerSecs, tushort) :: (_timerFracSecs, tushort) ::
               (__g, (tptr (Tunion __549 noattr))) ::
               (__g__1, (tptr (Tunion __549 noattr))) ::
               (_t'3, (tptr (Tunion __549 noattr))) ::
               (_t'2, (tptr (Tunion __549 noattr))) ::
               (_t'1, (tptr tvoid)) :: (_t'6, tushort) ::
               (_t'5, (tptr tuchar)) :: (_t'4, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                    (tptr tvoid) cc_default))
      ((Eaddrof (Evar _main_hud_lut (tarray (tptr tuchar) 58))
         (tptr (tarray (tptr tuchar) 58))) :: nil))
    (Sset _hudLUT (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Ssequence
      (Sset _t'6
        (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr)) _timer
          tushort))
      (Sset _timerValFrames (Ecast (Etempvar _t'6 tushort) tushort)))
    (Ssequence
      (Sset _timerMins
        (Ecast
          (Ebinop Odiv (Etempvar _timerValFrames tushort)
            (Ebinop Omul (Econst_int (Int.repr 30) tint)
              (Econst_int (Int.repr 60) tint) tint) tint) tushort))
      (Ssequence
        (Sset _timerSecs
          (Ecast
            (Ebinop Odiv
              (Ebinop Osub (Etempvar _timerValFrames tushort)
                (Ebinop Omul (Etempvar _timerMins tushort)
                  (Econst_int (Int.repr 1800) tint) tint) tint)
              (Econst_int (Int.repr 30) tint) tint) tushort))
        (Ssequence
          (Sset _timerFracSecs
            (Ecast
              (Ebinop Odiv
                (Ecast
                  (Ebinop Osub
                    (Ebinop Osub (Etempvar _timerValFrames tushort)
                      (Ebinop Omul (Etempvar _timerMins tushort)
                        (Econst_int (Int.repr 1800) tint) tint) tint)
                    (Ebinop Omul (Etempvar _timerSecs tushort)
                      (Econst_int (Int.repr 30) tint) tint) tint) tushort)
                (Econst_int (Int.repr 3) tint) tint) tushort))
          (Ssequence
            (Scall None
              (Evar _print_text (Tfunction
                                  (tint :: tint :: (tptr tuchar) :: nil)
                                  tvoid cc_default))
              ((Ebinop Osub (Econst_int (Int.repr 320) tint)
                 (Econst_int (Int.repr 150) tint) tint) ::
               (Econst_int (Int.repr 185) tint) ::
               (Evar ___stringlit_7 (tarray tuchar 5)) :: nil))
            (Ssequence
              (Scall None
                (Evar _print_text_fmt_int (Tfunction
                                            (tint :: tint :: (tptr tuchar) ::
                                             tint :: nil) tvoid cc_default))
                ((Ebinop Osub (Econst_int (Int.repr 320) tint)
                   (Econst_int (Int.repr 91) tint) tint) ::
                 (Econst_int (Int.repr 185) tint) ::
                 (Evar ___stringlit_8 (tarray tuchar 4)) ::
                 (Etempvar _timerMins tushort) :: nil))
              (Ssequence
                (Scall None
                  (Evar _print_text_fmt_int (Tfunction
                                              (tint :: tint ::
                                               (tptr tuchar) :: tint :: nil)
                                              tvoid cc_default))
                  ((Ebinop Osub (Econst_int (Int.repr 320) tint)
                     (Econst_int (Int.repr 71) tint) tint) ::
                   (Econst_int (Int.repr 185) tint) ::
                   (Evar ___stringlit_9 (tarray tuchar 5)) ::
                   (Etempvar _timerSecs tushort) :: nil))
                (Ssequence
                  (Scall None
                    (Evar _print_text_fmt_int (Tfunction
                                                (tint :: tint ::
                                                 (tptr tuchar) :: tint ::
                                                 nil) tvoid cc_default))
                    ((Ebinop Osub (Econst_int (Int.repr 320) tint)
                       (Econst_int (Int.repr 37) tint) tint) ::
                     (Econst_int (Int.repr 185) tint) ::
                     (Evar ___stringlit_3 (tarray tuchar 3)) ::
                     (Etempvar _timerFracSecs tushort) :: nil))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'2
                            (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                          (Sassign
                            (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                            (Ebinop Oadd
                              (Etempvar _t'2 (tptr (Tunion __549 noattr)))
                              (Econst_int (Int.repr 1) tint)
                              (tptr (Tunion __549 noattr)))))
                        (Sset __g
                          (Ecast (Etempvar _t'2 (tptr (Tunion __549 noattr)))
                            (tptr (Tunion __549 noattr)))))
                      (Ssequence
                        (Sassign
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar __g (tptr (Tunion __549 noattr)))
                                (Tunion __549 noattr)) _words
                              (Tstruct __547 noattr)) _w0 tuint)
                          (Ebinop Oor
                            (Ebinop Oor
                              (Ecast
                                (Ebinop Oshl
                                  (Ebinop Oand
                                    (Ecast (Econst_int (Int.repr 222) tint)
                                      tuint)
                                    (Ebinop Osub
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 8) tint) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuint) (Econst_int (Int.repr 24) tint)
                                  tuint) tuint)
                              (Ecast
                                (Ebinop Oshl
                                  (Ebinop Oand
                                    (Ecast (Econst_int (Int.repr 0) tint)
                                      tuint)
                                    (Ebinop Osub
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 8) tint) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuint) (Econst_int (Int.repr 16) tint)
                                  tuint) tuint) tuint)
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Econst_int (Int.repr 0) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 16) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 0) tint)
                                tuint) tuint) tuint))
                        (Sassign
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar __g (tptr (Tunion __549 noattr)))
                                (Tunion __549 noattr)) _words
                              (Tstruct __547 noattr)) _w1 tuint)
                          (Ecast
                            (Evar _dl_hud_img_begin (tarray (Tunion __549 noattr) 0))
                            tuint))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'5
                          (Ederef
                            (Ebinop Oadd
                              (Ederef
                                (Etempvar _hudLUT (tptr (tarray (tptr tuchar) 58)))
                                (tarray (tptr tuchar) 58))
                              (Econst_int (Int.repr 56) tint)
                              (tptr (tptr tuchar))) (tptr tuchar)))
                        (Scall None
                          (Evar _render_hud_tex_lut (Tfunction
                                                      (tint :: tint ::
                                                       (tptr tuchar) :: nil)
                                                      tvoid cc_default))
                          ((Ebinop Osub (Econst_int (Int.repr 320) tint)
                             (Econst_int (Int.repr 81) tint) tint) ::
                           (Econst_int (Int.repr 32) tint) ::
                           (Etempvar _t'5 (tptr tuchar)) :: nil)))
                      (Ssequence
                        (Ssequence
                          (Sset _t'4
                            (Ederef
                              (Ebinop Oadd
                                (Ederef
                                  (Etempvar _hudLUT (tptr (tarray (tptr tuchar) 58)))
                                  (tarray (tptr tuchar) 58))
                                (Econst_int (Int.repr 57) tint)
                                (tptr (tptr tuchar))) (tptr tuchar)))
                          (Scall None
                            (Evar _render_hud_tex_lut (Tfunction
                                                        (tint :: tint ::
                                                         (tptr tuchar) ::
                                                         nil) tvoid
                                                        cc_default))
                            ((Ebinop Osub (Econst_int (Int.repr 320) tint)
                               (Econst_int (Int.repr 46) tint) tint) ::
                             (Econst_int (Int.repr 32) tint) ::
                             (Etempvar _t'4 (tptr tuchar)) :: nil)))
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Sset _t'3
                                (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                              (Sassign
                                (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                                (Ebinop Oadd
                                  (Etempvar _t'3 (tptr (Tunion __549 noattr)))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr (Tunion __549 noattr)))))
                            (Sset __g__1
                              (Ecast
                                (Etempvar _t'3 (tptr (Tunion __549 noattr)))
                                (tptr (Tunion __549 noattr)))))
                          (Ssequence
                            (Sassign
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                                    (Tunion __549 noattr)) _words
                                  (Tstruct __547 noattr)) _w0 tuint)
                              (Ebinop Oor
                                (Ebinop Oor
                                  (Ecast
                                    (Ebinop Oshl
                                      (Ebinop Oand
                                        (Ecast
                                          (Econst_int (Int.repr 222) tint)
                                          tuint)
                                        (Ebinop Osub
                                          (Ebinop Oshl
                                            (Econst_int (Int.repr 1) tint)
                                            (Econst_int (Int.repr 8) tint)
                                            tint)
                                          (Econst_int (Int.repr 1) tint)
                                          tint) tuint)
                                      (Econst_int (Int.repr 24) tint) tuint)
                                    tuint)
                                  (Ecast
                                    (Ebinop Oshl
                                      (Ebinop Oand
                                        (Ecast (Econst_int (Int.repr 0) tint)
                                          tuint)
                                        (Ebinop Osub
                                          (Ebinop Oshl
                                            (Econst_int (Int.repr 1) tint)
                                            (Econst_int (Int.repr 8) tint)
                                            tint)
                                          (Econst_int (Int.repr 1) tint)
                                          tint) tuint)
                                      (Econst_int (Int.repr 16) tint) tuint)
                                    tuint) tuint)
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
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuint) (Econst_int (Int.repr 0) tint)
                                    tuint) tuint) tuint))
                            (Sassign
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                                    (Tunion __549 noattr)) _words
                                  (Tstruct __547 noattr)) _w1 tuint)
                              (Ecast
                                (Evar _dl_hud_img_end (tarray (Tunion __549 noattr) 0))
                                tuint))))))))))))))))
|}.

Definition f_set_hud_camera_status := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_status, tshort) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Sassign (Evar _sCameraHUDStatus tshort) (Etempvar _status tshort))
|}.

Definition f_render_hud_camera_status := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_cameraLUT, (tptr (tarray (tptr tuchar) 6))) :: (_x, tint) ::
               (_y, tint) :: (__g, (tptr (Tunion __549 noattr))) ::
               (__g__1, (tptr (Tunion __549 noattr))) ::
               (_t'3, (tptr (Tunion __549 noattr))) ::
               (_t'2, (tptr (Tunion __549 noattr))) ::
               (_t'1, (tptr tvoid)) :: (_t'12, tshort) ::
               (_t'11, (tptr tuchar)) :: (_t'10, (tptr tuchar)) ::
               (_t'9, (tptr tuchar)) :: (_t'8, (tptr tuchar)) ::
               (_t'7, tshort) :: (_t'6, (tptr tuchar)) ::
               (_t'5, (tptr tuchar)) :: (_t'4, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                    (tptr tvoid) cc_default))
      ((Eaddrof (Evar _main_hud_camera_lut (tarray (tptr tuchar) 6))
         (tptr (tarray (tptr tuchar) 6))) :: nil))
    (Sset _cameraLUT (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Sset _x
      (Ebinop Osub (Econst_int (Int.repr 320) tint)
        (Econst_int (Int.repr 54) tint) tint))
    (Ssequence
      (Sset _y (Econst_int (Int.repr 205) tint))
      (Ssequence
        (Ssequence
          (Sset _t'12 (Evar _sCameraHUDStatus tshort))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'12 tshort)
                         (Econst_int (Int.repr 0) tint) tint)
            (Sreturn None)
            Sskip))
        (Ssequence
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'2
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                (Sassign
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                  (Ebinop Oadd (Etempvar _t'2 (tptr (Tunion __549 noattr)))
                    (Econst_int (Int.repr 1) tint)
                    (tptr (Tunion __549 noattr)))))
              (Sset __g
                (Ecast (Etempvar _t'2 (tptr (Tunion __549 noattr)))
                  (tptr (Tunion __549 noattr)))))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w0 tuint)
                (Ebinop Oor
                  (Ebinop Oor
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 222) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 24) tint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 0) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 16) tint) tuint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 0) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 16) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w1 tuint)
                (Ecast
                  (Evar _dl_hud_img_begin (tarray (Tunion __549 noattr) 0))
                  tuint))))
          (Ssequence
            (Ssequence
              (Sset _t'11
                (Ederef
                  (Ebinop Oadd
                    (Ederef
                      (Etempvar _cameraLUT (tptr (tarray (tptr tuchar) 6)))
                      (tarray (tptr tuchar) 6))
                    (Econst_int (Int.repr 0) tint) (tptr (tptr tuchar)))
                  (tptr tuchar)))
              (Scall None
                (Evar _render_hud_tex_lut (Tfunction
                                            (tint :: tint :: (tptr tuchar) ::
                                             nil) tvoid cc_default))
                ((Etempvar _x tint) :: (Etempvar _y tint) ::
                 (Etempvar _t'11 (tptr tuchar)) :: nil)))
            (Ssequence
              (Ssequence
                (Sset _t'7 (Evar _sCameraHUDStatus tshort))
                (Sswitch (Ebinop Oand (Etempvar _t'7 tshort)
                           (Ebinop Oor
                             (Ebinop Oor
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 0) tint) tint)
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 1) tint) tint) tint)
                             (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                               (Econst_int (Int.repr 2) tint) tint) tint)
                           tint)
                  (LScons (Some 1)
                    (Ssequence
                      (Ssequence
                        (Sset _t'10
                          (Ederef
                            (Ebinop Oadd
                              (Ederef
                                (Etempvar _cameraLUT (tptr (tarray (tptr tuchar) 6)))
                                (tarray (tptr tuchar) 6))
                              (Econst_int (Int.repr 1) tint)
                              (tptr (tptr tuchar))) (tptr tuchar)))
                        (Scall None
                          (Evar _render_hud_tex_lut (Tfunction
                                                      (tint :: tint ::
                                                       (tptr tuchar) :: nil)
                                                      tvoid cc_default))
                          ((Ebinop Oadd (Etempvar _x tint)
                             (Econst_int (Int.repr 16) tint) tint) ::
                           (Etempvar _y tint) ::
                           (Etempvar _t'10 (tptr tuchar)) :: nil)))
                      Sbreak)
                    (LScons (Some 2)
                      (Ssequence
                        (Ssequence
                          (Sset _t'9
                            (Ederef
                              (Ebinop Oadd
                                (Ederef
                                  (Etempvar _cameraLUT (tptr (tarray (tptr tuchar) 6)))
                                  (tarray (tptr tuchar) 6))
                                (Econst_int (Int.repr 2) tint)
                                (tptr (tptr tuchar))) (tptr tuchar)))
                          (Scall None
                            (Evar _render_hud_tex_lut (Tfunction
                                                        (tint :: tint ::
                                                         (tptr tuchar) ::
                                                         nil) tvoid
                                                        cc_default))
                            ((Ebinop Oadd (Etempvar _x tint)
                               (Econst_int (Int.repr 16) tint) tint) ::
                             (Etempvar _y tint) ::
                             (Etempvar _t'9 (tptr tuchar)) :: nil)))
                        Sbreak)
                      (LScons (Some 4)
                        (Ssequence
                          (Ssequence
                            (Sset _t'8
                              (Ederef
                                (Ebinop Oadd
                                  (Ederef
                                    (Etempvar _cameraLUT (tptr (tarray (tptr tuchar) 6)))
                                    (tarray (tptr tuchar) 6))
                                  (Econst_int (Int.repr 3) tint)
                                  (tptr (tptr tuchar))) (tptr tuchar)))
                            (Scall None
                              (Evar _render_hud_tex_lut (Tfunction
                                                          (tint :: tint ::
                                                           (tptr tuchar) ::
                                                           nil) tvoid
                                                          cc_default))
                              ((Ebinop Oadd (Etempvar _x tint)
                                 (Econst_int (Int.repr 16) tint) tint) ::
                               (Etempvar _y tint) ::
                               (Etempvar _t'8 (tptr tuchar)) :: nil)))
                          Sbreak)
                        LSnil)))))
              (Ssequence
                (Ssequence
                  (Sset _t'4 (Evar _sCameraHUDStatus tshort))
                  (Sswitch (Ebinop Oand (Etempvar _t'4 tshort)
                             (Ebinop Oor
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 3) tint) tint)
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 4) tint) tint) tint)
                             tint)
                    (LScons (Some 8)
                      (Ssequence
                        (Ssequence
                          (Sset _t'6
                            (Ederef
                              (Ebinop Oadd
                                (Ederef
                                  (Etempvar _cameraLUT (tptr (tarray (tptr tuchar) 6)))
                                  (tarray (tptr tuchar) 6))
                                (Econst_int (Int.repr 5) tint)
                                (tptr (tptr tuchar))) (tptr tuchar)))
                          (Scall None
                            (Evar _render_hud_small_tex_lut (Tfunction
                                                              (tint ::
                                                               tint ::
                                                               (tptr tuchar) ::
                                                               nil) tvoid
                                                              cc_default))
                            ((Ebinop Oadd (Etempvar _x tint)
                               (Econst_int (Int.repr 4) tint) tint) ::
                             (Ebinop Oadd (Etempvar _y tint)
                               (Econst_int (Int.repr 16) tint) tint) ::
                             (Etempvar _t'6 (tptr tuchar)) :: nil)))
                        Sbreak)
                      (LScons (Some 16)
                        (Ssequence
                          (Ssequence
                            (Sset _t'5
                              (Ederef
                                (Ebinop Oadd
                                  (Ederef
                                    (Etempvar _cameraLUT (tptr (tarray (tptr tuchar) 6)))
                                    (tarray (tptr tuchar) 6))
                                  (Econst_int (Int.repr 4) tint)
                                  (tptr (tptr tuchar))) (tptr tuchar)))
                            (Scall None
                              (Evar _render_hud_small_tex_lut (Tfunction
                                                                (tint ::
                                                                 tint ::
                                                                 (tptr tuchar) ::
                                                                 nil) tvoid
                                                                cc_default))
                              ((Ebinop Oadd (Etempvar _x tint)
                                 (Econst_int (Int.repr 4) tint) tint) ::
                               (Ebinop Osub (Etempvar _y tint)
                                 (Econst_int (Int.repr 8) tint) tint) ::
                               (Etempvar _t'5 (tptr tuchar)) :: nil)))
                          Sbreak)
                        LSnil))))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'3
                        (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                      (Sassign
                        (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                        (Ebinop Oadd
                          (Etempvar _t'3 (tptr (Tunion __549 noattr)))
                          (Econst_int (Int.repr 1) tint)
                          (tptr (Tunion __549 noattr)))))
                    (Sset __g__1
                      (Ecast (Etempvar _t'3 (tptr (Tunion __549 noattr)))
                        (tptr (Tunion __549 noattr)))))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                            (Tunion __549 noattr)) _words
                          (Tstruct __547 noattr)) _w0 tuint)
                      (Ebinop Oor
                        (Ebinop Oor
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast (Econst_int (Int.repr 222) tint)
                                  tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 8) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 24) tint) tuint) tuint)
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast (Econst_int (Int.repr 0) tint) tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 8) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 16) tint) tuint) tuint)
                          tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 0) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 16) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 0) tint) tuint) tuint)
                        tuint))
                    (Sassign
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                            (Tunion __549 noattr)) _words
                          (Tstruct __547 noattr)) _w1 tuint)
                      (Ecast
                        (Evar _dl_hud_img_end (tarray (Tunion __549 noattr) 0))
                        tuint))))))))))))
|}.

Definition f_render_hud := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_hudDisplayFlags, tshort) :: (_t'1, tint) ::
               (_t'6, tshort) :: (_t'5, tuchar) ::
               (_t'4, (tptr (Tstruct _Camera noattr))) ::
               (_t'3, (tptr (Tstruct _Area noattr))) ::
               (_t'2, (tptr (Tstruct _Area noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6
      (Efield (Evar _gHudDisplay (Tstruct _HudDisplay noattr)) _flags tshort))
    (Sset _hudDisplayFlags (Ecast (Etempvar _t'6 tshort) tshort)))
  (Sifthenelse (Ebinop Oeq (Etempvar _hudDisplayFlags tshort)
                 (Econst_int (Int.repr 0) tint) tint)
    (Ssequence
      (Sassign
        (Efield (Evar _sPowerMeterHUD (Tstruct _PowerMeterHUD noattr))
          _animation tschar) (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Sassign (Evar _sPowerMeterStoredHealth tshort)
          (Econst_int (Int.repr 8) tint))
        (Sassign (Evar _sPowerMeterVisibleTimer tint)
          (Econst_int (Int.repr 0) tint))))
    (Ssequence
      (Scall None
        (Evar _create_dl_ortho_matrix (Tfunction nil tvoid cc_default)) nil)
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'2 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
            (Sifthenelse (Ebinop One
                           (Etempvar _t'2 (tptr (Tstruct _Area noattr)))
                           (Ecast (Econst_int (Int.repr 0) tint)
                             (tptr tvoid)) tint)
              (Ssequence
                (Sset _t'3
                  (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                (Ssequence
                  (Sset _t'4
                    (Efield
                      (Ederef (Etempvar _t'3 (tptr (Tstruct _Area noattr)))
                        (Tstruct _Area noattr)) _camera
                      (tptr (Tstruct _Camera noattr))))
                  (Ssequence
                    (Sset _t'5
                      (Efield
                        (Ederef
                          (Etempvar _t'4 (tptr (Tstruct _Camera noattr)))
                          (Tstruct _Camera noattr)) _mode tuchar))
                    (Sset _t'1
                      (Ecast
                        (Ebinop Oeq (Etempvar _t'5 tuchar)
                          (Econst_int (Int.repr 10) tint) tint) tbool)))))
              (Sset _t'1 (Econst_int (Int.repr 0) tint))))
          (Sifthenelse (Etempvar _t'1 tint)
            (Scall None
              (Evar _render_hud_cannon_reticle (Tfunction nil tvoid
                                                 cc_default)) nil)
            Sskip))
        (Ssequence
          (Sifthenelse (Ebinop Oand (Etempvar _hudDisplayFlags tshort)
                         (Econst_int (Int.repr 1) tint) tint)
            (Scall None
              (Evar _render_hud_mario_lives (Tfunction nil tvoid cc_default))
              nil)
            Sskip)
          (Ssequence
            (Sifthenelse (Ebinop Oand (Etempvar _hudDisplayFlags tshort)
                           (Econst_int (Int.repr 2) tint) tint)
              (Scall None
                (Evar _render_hud_coins (Tfunction nil tvoid cc_default))
                nil)
              Sskip)
            (Ssequence
              (Sifthenelse (Ebinop Oand (Etempvar _hudDisplayFlags tshort)
                             (Econst_int (Int.repr 4) tint) tint)
                (Scall None
                  (Evar _render_hud_stars (Tfunction nil tvoid cc_default))
                  nil)
                Sskip)
              (Ssequence
                (Sifthenelse (Ebinop Oand (Etempvar _hudDisplayFlags tshort)
                               (Econst_int (Int.repr 16) tint) tint)
                  (Scall None
                    (Evar _render_hud_keys (Tfunction nil tvoid cc_default))
                    nil)
                  Sskip)
                (Ssequence
                  (Sifthenelse (Ebinop Oand
                                 (Etempvar _hudDisplayFlags tshort)
                                 (Econst_int (Int.repr 8) tint) tint)
                    (Ssequence
                      (Scall None
                        (Evar _render_hud_power_meter (Tfunction nil tvoid
                                                        cc_default)) nil)
                      (Scall None
                        (Evar _render_hud_camera_status (Tfunction nil tvoid
                                                          cc_default)) nil))
                    Sskip)
                  (Sifthenelse (Ebinop Oand
                                 (Etempvar _hudDisplayFlags tshort)
                                 (Econst_int (Int.repr 64) tint) tint)
                    (Scall None
                      (Evar _render_hud_timer (Tfunction nil tvoid
                                                cc_default)) nil)
                    Sskip))))))))))
|}.

Definition composites : list composite_definition :=
(Composite __469 Struct
   (Member_plain _flag tuchar :: Member_plain _v (tarray tuchar 3) :: nil)
   noattr ::
 Composite __472 Union
   (Member_plain _m (tarray (tarray tint 4) 4) ::
    Member_plain _force_structure_alignment tlong :: nil)
   noattr ::
 Composite __510 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _par I32 Unsigned noattr 8 false ::
    Member_bitfield _len I32 Unsigned noattr 16 false ::
    Member_plain _addr tuint :: nil)
   noattr ::
 Composite __512 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad I32 Signed noattr 24 false ::
    Member_plain _tri (Tstruct __469 noattr) :: nil)
   noattr ::
 Composite __514 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad1 I32 Signed noattr 24 false ::
    Member_bitfield _pad2 I32 Signed noattr 24 false ::
    Member_bitfield _param I8 Unsigned noattr 8 false :: nil)
   noattr ::
 Composite __516 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad0 I32 Signed noattr 8 false ::
    Member_bitfield _mw_index I32 Signed noattr 8 false ::
    Member_bitfield _number I32 Signed noattr 8 false ::
    Member_bitfield _pad1 I32 Signed noattr 8 false ::
    Member_bitfield _base I32 Signed noattr 24 false :: nil)
   noattr ::
 Composite __518 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad0 I32 Signed noattr 8 false ::
    Member_bitfield _sft I32 Signed noattr 8 false ::
    Member_bitfield _len I32 Signed noattr 8 false ::
    Member_bitfield _data I32 Unsigned noattr 32 false :: nil)
   noattr ::
 Composite __520 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad0 I32 Signed noattr 8 false ::
    Member_bitfield _sft I32 Signed noattr 8 false ::
    Member_bitfield _len I32 Signed noattr 8 false ::
    Member_bitfield _data I32 Unsigned noattr 32 false :: nil)
   noattr ::
 Composite __522 Struct
   (Member_plain _cmd tuchar :: Member_plain _lodscale tuchar ::
    Member_plain _tile tuchar :: Member_plain _on tuchar ::
    Member_plain _s tushort :: Member_plain _t tushort :: nil)
   noattr ::
 Composite __524 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad I32 Signed noattr 24 false ::
    Member_plain _line (Tstruct __469 noattr) :: nil)
   noattr ::
 Composite __526 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad1 I32 Signed noattr 24 false ::
    Member_plain _pad2 tshort :: Member_plain _scale tshort :: nil)
   noattr ::
 Composite __528 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _fmt I32 Unsigned noattr 3 false ::
    Member_bitfield _siz I32 Unsigned noattr 2 false ::
    Member_bitfield _pad I32 Unsigned noattr 7 false ::
    Member_bitfield _wd I32 Unsigned noattr 12 false ::
    Member_plain _dram tuint :: nil)
   noattr ::
 Composite __530 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _muxs0 I32 Unsigned noattr 24 false ::
    Member_bitfield _muxs1 I32 Unsigned noattr 32 false :: nil)
   noattr ::
 Composite __532 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_plain _pad tuchar :: Member_plain _prim_min_level tuchar ::
    Member_plain _prim_level tuchar :: Member_plain _color tuint :: nil)
   noattr ::
 Composite __534 Struct
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
 Composite __536 Struct
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
 Composite __538 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _sl I32 Unsigned noattr 12 false ::
    Member_bitfield _tl I32 Unsigned noattr 12 false ::
    Member_bitfield _pad I32 Signed noattr 5 false ::
    Member_bitfield _tile I32 Unsigned noattr 3 false ::
    Member_bitfield _sh I32 Unsigned noattr 12 false ::
    Member_bitfield _th I32 Unsigned noattr 12 false :: nil)
   noattr ::
 Composite __547 Struct
   (Member_plain _w0 tuint :: Member_plain _w1 tuint :: nil)
   noattr ::
 Composite __549 Union
   (Member_plain _words (Tstruct __547 noattr) ::
    Member_plain _dma (Tstruct __510 noattr) ::
    Member_plain _tri (Tstruct __512 noattr) ::
    Member_plain _line (Tstruct __524 noattr) ::
    Member_plain _popmtx (Tstruct __514 noattr) ::
    Member_plain _segment (Tstruct __516 noattr) ::
    Member_plain _setothermodeH (Tstruct __520 noattr) ::
    Member_plain _setothermodeL (Tstruct __518 noattr) ::
    Member_plain _texture (Tstruct __522 noattr) ::
    Member_plain _perspnorm (Tstruct __526 noattr) ::
    Member_plain _setimg (Tstruct __528 noattr) ::
    Member_plain _setcombine (Tstruct __530 noattr) ::
    Member_plain _setcolor (Tstruct __532 noattr) ::
    Member_plain _fillrect (Tstruct __534 noattr) ::
    Member_plain _settile (Tstruct __536 noattr) ::
    Member_plain _loadtile (Tstruct __538 noattr) ::
    Member_plain _settilesize (Tstruct __538 noattr) ::
    Member_plain _loadtlut (Tstruct __538 noattr) ::
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
 Composite _HudDisplay Struct
   (Member_plain _lives tshort :: Member_plain _coins tshort ::
    Member_plain _stars tshort :: Member_plain _wedges tshort ::
    Member_plain _keys tshort :: Member_plain _flags tshort ::
    Member_plain _timer tushort :: nil)
   noattr ::
 Composite _GraphNodeRoot Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _areaIndex tuchar :: Member_plain _unk15 tschar ::
    Member_plain _x tshort :: Member_plain _y tshort ::
    Member_plain _width tshort :: Member_plain _height tshort ::
    Member_plain _numViews tshort ::
    Member_plain _views (tptr (tptr (Tstruct _GraphNode noattr))) :: nil)
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
 Composite _PowerMeterHUD Struct
   (Member_plain _animation tschar :: Member_plain _x tshort ::
    Member_plain _y tshort :: Member_plain _unused tfloat :: nil)
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
     cc_default)) :: (___stringlit_2, Gvar v___stringlit_2) ::
 (___stringlit_8, Gvar v___stringlit_8) ::
 (___stringlit_3, Gvar v___stringlit_3) ::
 (___stringlit_5, Gvar v___stringlit_5) ::
 (___stringlit_4, Gvar v___stringlit_4) ::
 (___stringlit_6, Gvar v___stringlit_6) ::
 (___stringlit_7, Gvar v___stringlit_7) ::
 (___stringlit_9, Gvar v___stringlit_9) ::
 (___stringlit_1, Gvar v___stringlit_1) ::
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
 (_guTranslate,
   Gfun(External (EF_external "guTranslate"
                   (mksignature
                     (AST.Xptr :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xsingle :: nil) AST.Xvoid cc_default))
     ((tptr (Tunion __472 noattr)) :: tfloat :: tfloat :: tfloat :: nil)
     tvoid cc_default)) ::
 (_power_meter_health_segments_lut, Gvar v_power_meter_health_segments_lut) ::
 (_dl_power_meter_base, Gvar v_dl_power_meter_base) ::
 (_dl_power_meter_health_segments_begin, Gvar v_dl_power_meter_health_segments_begin) ::
 (_dl_power_meter_health_segments_end, Gvar v_dl_power_meter_health_segments_end) ::
 (_segmented_to_virtual,
   Gfun(External (EF_external "segmented_to_virtual"
                   (mksignature (AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr tvoid) :: nil) (tptr tvoid) cc_default)) ::
 (_alloc_display_list,
   Gfun(External (EF_external "alloc_display_list"
                   (mksignature (AST.Xint :: nil) AST.Xptr cc_default))
     (tuint :: nil) (tptr tvoid) cc_default)) ::
 (_gDisplayListHead, Gvar v_gDisplayListHead) ::
 (_gGlobalTimer, Gvar v_gGlobalTimer) ::
 (_gHudDisplay, Gvar v_gHudDisplay) ::
 (_gCurrentArea, Gvar v_gCurrentArea) ::
 (_gPlayerCameraState, Gvar v_gPlayerCameraState) ::
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
 (_gHudFlash, Gvar v_gHudFlash) ::
 (_create_dl_ortho_matrix,
   Gfun(External (EF_external "create_dl_ortho_matrix"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_render_hud_cannon_reticle,
   Gfun(External (EF_external "render_hud_cannon_reticle"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) :: (_main_hud_lut, Gvar v_main_hud_lut) ::
 (_dl_hud_img_load_tex_block, Gvar v_dl_hud_img_load_tex_block) ::
 (_dl_hud_img_begin, Gvar v_dl_hud_img_begin) ::
 (_dl_hud_img_end, Gvar v_dl_hud_img_end) ::
 (_main_hud_camera_lut, Gvar v_main_hud_camera_lut) ::
 (_sPowerMeterStoredHealth, Gvar v_sPowerMeterStoredHealth) ::
 (_sPowerMeterHUD, Gvar v_sPowerMeterHUD) ::
 (_sPowerMeterVisibleTimer, Gvar v_sPowerMeterVisibleTimer) ::
 (_sCameraHUDStatus, Gvar v_sCameraHUDStatus) ::
 (_render_hud_tex_lut, Gfun(Internal f_render_hud_tex_lut)) ::
 (_render_hud_small_tex_lut, Gfun(Internal f_render_hud_small_tex_lut)) ::
 (_render_power_meter_health_segment, Gfun(Internal f_render_power_meter_health_segment)) ::
 (_render_dl_power_meter, Gfun(Internal f_render_dl_power_meter)) ::
 (_animate_power_meter_emphasized, Gfun(Internal f_animate_power_meter_emphasized)) ::
 (_animate_power_meter_deemphasizing, Gfun(Internal f_animate_power_meter_deemphasizing)) ::
 (_animate_power_meter_hiding, Gfun(Internal f_animate_power_meter_hiding)) ::
 (_handle_power_meter_actions, Gfun(Internal f_handle_power_meter_actions)) ::
 (_render_hud_power_meter, Gfun(Internal f_render_hud_power_meter)) ::
 (_render_hud_mario_lives, Gfun(Internal f_render_hud_mario_lives)) ::
 (_render_hud_coins, Gfun(Internal f_render_hud_coins)) ::
 (_render_hud_stars, Gfun(Internal f_render_hud_stars)) ::
 (_render_hud_keys, Gfun(Internal f_render_hud_keys)) ::
 (_render_hud_timer, Gfun(Internal f_render_hud_timer)) ::
 (_set_hud_camera_status, Gfun(Internal f_set_hud_camera_status)) ::
 (_render_hud_camera_status, Gfun(Internal f_render_hud_camera_status)) ::
 (_render_hud, Gfun(Internal f_render_hud)) :: nil).

Definition public_idents : list ident :=
(_render_hud :: _render_hud_camera_status :: _set_hud_camera_status ::
 _render_hud_timer :: _render_hud_keys :: _render_hud_stars ::
 _render_hud_coins :: _render_hud_mario_lives :: _render_hud_power_meter ::
 _handle_power_meter_actions :: _animate_power_meter_emphasized ::
 _render_dl_power_meter :: _render_power_meter_health_segment ::
 _render_hud_small_tex_lut :: _render_hud_tex_lut ::
 _sPowerMeterVisibleTimer :: _main_hud_camera_lut :: _dl_hud_img_end ::
 _dl_hud_img_begin :: _dl_hud_img_load_tex_block :: _main_hud_lut ::
 _render_hud_cannon_reticle :: _create_dl_ortho_matrix :: _gHudFlash ::
 _print_text :: _print_text_fmt_int :: _gPlayerCameraState ::
 _gCurrentArea :: _gHudDisplay :: _gGlobalTimer :: _gDisplayListHead ::
 _alloc_display_list :: _segmented_to_virtual ::
 _dl_power_meter_health_segments_end ::
 _dl_power_meter_health_segments_begin :: _dl_power_meter_base ::
 _power_meter_health_segments_lut :: _guTranslate :: ___builtin_debug ::
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


