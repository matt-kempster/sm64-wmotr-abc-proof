(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_US
   Source:          src/game/envfx_bubbles.c
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1
   Link hygiene:    private __stringlit_N atoms prefixed with us_envfx_bubbles
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
  Definition source_file := "build/pinned-sm64/src/game/envfx_bubbles.c".
  Definition normalized := true.
End Info.

Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _D_80330690 : ident := $"D_80330690".
Definition _D_80330694 : ident := $"D_80330694".
Definition _EnvFxParticle : ident := $"EnvFxParticle".
Definition _FloorGeometry : ident := $"FloorGeometry".
Definition _GraphNode : ident := $"GraphNode".
Definition _GraphNodeObject : ident := $"GraphNodeObject".
Definition _MemoryPool : ident := $"MemoryPool".
Definition _Object : ident := $"Object".
Definition _ObjectNode : ident := $"ObjectNode".
Definition _SpawnInfo : ident := $"SpawnInfo".
Definition _Surface : ident := $"Surface".
Definition _Waypoint : ident := $"Waypoint".
Definition __459 : ident := $"_459".
Definition __461 : ident := $"_461".
Definition __463 : ident := $"_463".
Definition __469 : ident := $"_469".
Definition __510 : ident := $"_510".
Definition __512 : ident := $"_512".
Definition __514 : ident := $"_514".
Definition __516 : ident := $"_516".
Definition __518 : ident := $"_518".
Definition __520 : ident := $"_520".
Definition __522 : ident := $"_522".
Definition __524 : ident := $"_524".
Definition __526 : ident := $"_526".
Definition __528 : ident := $"_528".
Definition __530 : ident := $"_530".
Definition __532 : ident := $"_532".
Definition __534 : ident := $"_534".
Definition __536 : ident := $"_536".
Definition __538 : ident := $"_538".
Definition __547 : ident := $"_547".
Definition __549 : ident := $"_549".
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
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _addr : ident := $"addr".
Definition _alloc_display_list : ident := $"alloc_display_list".
Definition _angle : ident := $"angle".
Definition _angleAndDist : ident := $"angleAndDist".
Definition _animAccel : ident := $"animAccel".
Definition _animFrame : ident := $"animFrame".
Definition _animFrameAccelAssist : ident := $"animFrameAccelAssist".
Definition _animID : ident := $"animID".
Definition _animInfo : ident := $"animInfo".
Definition _animTimer : ident := $"animTimer".
Definition _animYTrans : ident := $"animYTrans".
Definition _animYTransDivisor : ident := $"animYTransDivisor".
Definition _append_bubble_vertex_buffer : ident := $"append_bubble_vertex_buffer".
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
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _bubbleY : ident := $"bubbleY".
Definition _bubble_ptr_0B006848 : ident := $"bubble_ptr_0B006848".
Definition _bzero : ident := $"bzero".
Definition _camFrom : ident := $"camFrom".
Definition _camTo : ident := $"camTo".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _centerPos : ident := $"centerPos".
Definition _centerX : ident := $"centerX".
Definition _centerY : ident := $"centerY".
Definition _centerZ : ident := $"centerZ".
Definition _chance : ident := $"chance".
Definition _children : ident := $"children".
Definition _cmd : ident := $"cmd".
Definition _cn : ident := $"cn".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _color : ident := $"color".
Definition _cosMYaw : ident := $"cosMYaw".
Definition _cosPitch : ident := $"cosPitch".
Definition _cs : ident := $"cs".
Definition _ct : ident := $"ct".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _data : ident := $"data".
Definition _distance : ident := $"distance".
Definition _dma : ident := $"dma".
Definition _dram : ident := $"dram".
Definition _envfx_bubbles_update_switch : ident := $"envfx_bubbles_update_switch".
Definition _envfx_init_bubble : ident := $"envfx_init_bubble".
Definition _envfx_is_jestream_bubble_alive : ident := $"envfx_is_jestream_bubble_alive".
Definition _envfx_is_whirlpool_bubble_alive : ident := $"envfx_is_whirlpool_bubble_alive".
Definition _envfx_rotate_around_whirlpool : ident := $"envfx_rotate_around_whirlpool".
Definition _envfx_set_bubble_texture : ident := $"envfx_set_bubble_texture".
Definition _envfx_set_lava_bubble_position : ident := $"envfx_set_lava_bubble_position".
Definition _envfx_set_max_bubble_particles : ident := $"envfx_set_max_bubble_particles".
Definition _envfx_update_bubble_particles : ident := $"envfx_update_bubble_particles".
Definition _envfx_update_bubbles : ident := $"envfx_update_bubbles".
Definition _envfx_update_flower : ident := $"envfx_update_flower".
Definition _envfx_update_jetstream : ident := $"envfx_update_jetstream".
Definition _envfx_update_lava : ident := $"envfx_update_lava".
Definition _envfx_update_whirlpool : ident := $"envfx_update_whirlpool".
Definition _filler : ident := $"filler".
Definition _fillrect : ident := $"fillrect".
Definition _find_floor : ident := $"find_floor".
Definition _find_floor_height_and_data : ident := $"find_floor_height_and_data".
Definition _flag : ident := $"flag".
Definition _flags : ident := $"flags".
Definition _floorGeo : ident := $"floorGeo".
Definition _floorY : ident := $"floorY".
Definition _flower_bubbles_textures_ptr_0B002008 : ident := $"flower_bubbles_textures_ptr_0B002008".
Definition _fmt : ident := $"fmt".
Definition _force : ident := $"force".
Definition _force_structure_alignment : ident := $"force_structure_alignment".
Definition _frame : ident := $"frame".
Definition _gBubbleTempVtx : ident := $"gBubbleTempVtx".
Definition _gEffectsMemoryPool : ident := $"gEffectsMemoryPool".
Definition _gEnvFxBubbleConfig : ident := $"gEnvFxBubbleConfig".
Definition _gEnvFxBuffer : ident := $"gEnvFxBuffer".
Definition _gEnvFxMode : ident := $"gEnvFxMode".
Definition _gGlobalSoundSource : ident := $"gGlobalSoundSource".
Definition _gGlobalTimer : ident := $"gGlobalTimer".
Definition _gSineTable : ident := $"gSineTable".
Definition _gfx : ident := $"gfx".
Definition _gfxStart : ident := $"gfxStart".
Definition _globalTimer : ident := $"globalTimer".
Definition _header : ident := $"header".
Definition _hitboxDownOffset : ident := $"hitboxDownOffset".
Definition _hitboxHeight : ident := $"hitboxHeight".
Definition _hitboxRadius : ident := $"hitboxRadius".
Definition _hurtboxHeight : ident := $"hurtboxHeight".
Definition _hurtboxRadius : ident := $"hurtboxRadius".
Definition _i : ident := $"i".
Definition _imageArr : ident := $"imageArr".
Definition _index : ident := $"index".
Definition _isAlive : ident := $"isAlive".
Definition _lava_bubble_ptr_0B006020 : ident := $"lava_bubble_ptr_0B006020".
Definition _len : ident := $"len".
Definition _length : ident := $"length".
Definition _line : ident := $"line".
Definition _loadtile : ident := $"loadtile".
Definition _loadtlut : ident := $"loadtlut".
Definition _lodscale : ident := $"lodscale".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _main : ident := $"main".
Definition _marioPos : ident := $"marioPos".
Definition _masks : ident := $"masks".
Definition _maskt : ident := $"maskt".
Definition _mem_pool_alloc : ident := $"mem_pool_alloc".
Definition _mode : ident := $"mode".
Definition _ms : ident := $"ms".
Definition _mt : ident := $"mt".
Definition _muxs0 : ident := $"muxs0".
Definition _muxs1 : ident := $"muxs1".
Definition _mw_index : ident := $"mw_index".
Definition _n : ident := $"n".
Definition _next : ident := $"next".
Definition _node : ident := $"node".
Definition _normal : ident := $"normal".
Definition _normalX : ident := $"normalX".
Definition _normalY : ident := $"normalY".
Definition _normalZ : ident := $"normalZ".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _number : ident := $"number".
Definition _ob : ident := $"ob".
Definition _object : ident := $"object".
Definition _on : ident := $"on".
Definition _orbit_from_positions : ident := $"orbit_from_positions".
Definition _originOffset : ident := $"originOffset".
Definition _pad : ident := $"pad".
Definition _pad0 : ident := $"pad0".
Definition _pad1 : ident := $"pad1".
Definition _pad2 : ident := $"pad2".
Definition _palette : ident := $"palette".
Definition _par : ident := $"par".
Definition _param : ident := $"param".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _particle_is_laterally_close : ident := $"particle_is_laterally_close".
Definition _perspnorm : ident := $"perspnorm".
Definition _pitch : ident := $"pitch".
Definition _platform : ident := $"platform".
Definition _play_sound : ident := $"play_sound".
Definition _popmtx : ident := $"popmtx".
Definition _pos : ident := $"pos".
Definition _prev : ident := $"prev".
Definition _prevObj : ident := $"prevObj".
Definition _prim_level : ident := $"prim_level".
Definition _prim_min_level : ident := $"prim_min_level".
Definition _radius : ident := $"radius".
Definition _random_float : ident := $"random_float".
Definition _random_flower_offset : ident := $"random_flower_offset".
Definition _random_u16 : ident := $"random_u16".
Definition _rawData : ident := $"rawData".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _result : ident := $"result".
Definition _room : ident := $"room".
Definition _rotate_triangle_vertices : ident := $"rotate_triangle_vertices".
Definition _rotatedX : ident := $"rotatedX".
Definition _rotatedY : ident := $"rotatedY".
Definition _rotatedZ : ident := $"rotatedZ".
Definition _s : ident := $"s".
Definition _sBubbleParticleCount : ident := $"sBubbleParticleCount".
Definition _sBubbleParticleMaxCount : ident := $"sBubbleParticleMaxCount".
Definition _sGfxCursor : ident := $"sGfxCursor".
Definition _scale : ident := $"scale".
Definition _segment : ident := $"segment".
Definition _segmented_to_virtual : ident := $"segmented_to_virtual".
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
Definition _sinMYaw : ident := $"sinMYaw".
Definition _sinPitch : ident := $"sinPitch".
Definition _siz : ident := $"siz".
Definition _sl : ident := $"sl".
Definition _startFrame : ident := $"startFrame".
Definition _surface : ident := $"surface".
Definition _t : ident := $"t".
Definition _tc : ident := $"tc".
Definition _template : ident := $"template".
Definition _texture : ident := $"texture".
Definition _th : ident := $"th".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _tile : ident := $"tile".
Definition _tiny_bubble_dl_0B006AB0 : ident := $"tiny_bubble_dl_0B006AB0".
Definition _tiny_bubble_dl_0B006D38 : ident := $"tiny_bubble_dl_0B006D38".
Definition _tiny_bubble_dl_0B006D68 : ident := $"tiny_bubble_dl_0B006D68".
Definition _tl : ident := $"tl".
Definition _tmem : ident := $"tmem".
Definition _transform : ident := $"transform".
Definition _tri : ident := $"tri".
Definition _type : ident := $"type".
Definition _unk4C : ident := $"unk4C".
Definition _unused1 : ident := $"unused1".
Definition _unused2 : ident := $"unused2".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _unusedBubbleVar : ident := $"unusedBubbleVar".
Definition _upperY : ident := $"upperY".
Definition _v : ident := $"v".
Definition _values : ident := $"values".
Definition _vecX : ident := $"vecX".
Definition _vecY : ident := $"vecY".
Definition _vecZ : ident := $"vecZ".
Definition _vertBuf : ident := $"vertBuf".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _w0 : ident := $"w0".
Definition _w1 : ident := $"w1".
Definition _wd : ident := $"wd".
Definition _words : ident := $"words".
Definition _x : ident := $"x".
Definition _x0 : ident := $"x0".
Definition _x0frac : ident := $"x0frac".
Definition _x1 : ident := $"x1".
Definition _x1frac : ident := $"x1frac".
Definition _xPos : ident := $"xPos".
Definition _y : ident := $"y".
Definition _y0 : ident := $"y0".
Definition _y0frac : ident := $"y0frac".
Definition _y1 : ident := $"y1".
Definition _y1frac : ident := $"y1frac".
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

Definition v_gEnvFxMode := {|
  gvar_info := tschar;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gEnvFxBuffer := {|
  gvar_info := (tptr (Tstruct _EnvFxParticle noattr));
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

Definition v_gGlobalSoundSource := {|
  gvar_info := (tarray tfloat 3);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_flower_bubbles_textures_ptr_0B002008 := {|
  gvar_info := (tarray (tptr tuchar) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_lava_bubble_ptr_0B006020 := {|
  gvar_info := (tarray (tptr tuchar) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bubble_ptr_0B006848 := {|
  gvar_info := (tarray (tptr tuchar) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_tiny_bubble_dl_0B006AB0 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_tiny_bubble_dl_0B006D38 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_tiny_bubble_dl_0B006D68 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_gEnvFxBubbleConfig := {|
  gvar_info := (tarray tshort 10);
  gvar_init := (Init_space 20 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sGfxCursor := {|
  gvar_info := (tptr (Tunion __549 noattr));
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sBubbleParticleCount := {|
  gvar_info := tint;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sBubbleParticleMaxCount := {|
  gvar_info := tint;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_80330690 := {|
  gvar_info := tint;
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_80330694 := {|
  gvar_info := tint;
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gBubbleTempVtx := {|
  gvar_info := (tarray (Tstruct __459 noattr) 3);
  gvar_init := (Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 1544) :: Init_int16 (Int.repr 964) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 522) :: Init_int16 (Int.repr (-568)) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr (-498)) :: Init_int16 (Int.repr 964) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_particle_is_laterally_close := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_index, tint) :: (_x, tint) :: (_z, tint) ::
                (_distance, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_xPos, tint) :: (_zPos, tint) ::
               (_t'2, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'1, (tptr (Tstruct _EnvFxParticle noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2 (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
    (Sset _xPos
      (Efield
        (Ederef
          (Ebinop Oadd (Etempvar _t'2 (tptr (Tstruct _EnvFxParticle noattr)))
            (Etempvar _index tint) (tptr (Tstruct _EnvFxParticle noattr)))
          (Tstruct _EnvFxParticle noattr)) _xPos tint)))
  (Ssequence
    (Ssequence
      (Sset _t'1 (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
      (Sset _zPos
        (Efield
          (Ederef
            (Ebinop Oadd
              (Etempvar _t'1 (tptr (Tstruct _EnvFxParticle noattr)))
              (Etempvar _index tint) (tptr (Tstruct _EnvFxParticle noattr)))
            (Tstruct _EnvFxParticle noattr)) _zPos tint)))
    (Ssequence
      (Sifthenelse (Ebinop Ogt
                     (Ebinop Oadd
                       (Ebinop Omul
                         (Ebinop Osub (Etempvar _xPos tint)
                           (Etempvar _x tint) tint)
                         (Ebinop Osub (Etempvar _xPos tint)
                           (Etempvar _x tint) tint) tint)
                       (Ebinop Omul
                         (Ebinop Osub (Etempvar _zPos tint)
                           (Etempvar _z tint) tint)
                         (Ebinop Osub (Etempvar _zPos tint)
                           (Etempvar _z tint) tint) tint) tint)
                     (Ebinop Omul (Etempvar _distance tint)
                       (Etempvar _distance tint) tint) tint)
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))
        Sskip)
      (Sreturn (Some (Econst_int (Int.repr 1) tint))))))
|}.

Definition f_random_flower_offset := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_result, tint) :: (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1) (Evar _random_float (Tfunction nil tfloat cc_default))
      nil)
    (Sset _result
      (Ecast
        (Ebinop Osub
          (Ebinop Omul (Etempvar _t'1 tfloat)
            (Econst_single (Float32.of_bits (Int.repr 1157234688)) tfloat)
            tfloat)
          (Econst_single (Float32.of_bits (Int.repr 1148846080)) tfloat)
          tfloat) tint)))
  (Ssequence
    (Sifthenelse (Ebinop Olt (Etempvar _result tint)
                   (Econst_int (Int.repr 0) tint) tint)
      (Sset _result
        (Ebinop Osub (Etempvar _result tint)
          (Econst_int (Int.repr 1000) tint) tint))
      (Sset _result
        (Ebinop Oadd (Etempvar _result tint)
          (Econst_int (Int.repr 1000) tint) tint)))
    (Sreturn (Some (Etempvar _result tint)))))
|}.

Definition f_envfx_update_flower := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_centerPos, (tptr tshort)) :: nil);
  fn_vars := ((_floorGeo, (tptr (Tstruct _FloorGeometry noattr))) :: nil);
  fn_temps := ((_i, tint) :: (_globalTimer, tint) :: (_centerX, tshort) ::
               (_centerY, tshort) :: (_centerZ, tshort) :: (_t'5, tfloat) ::
               (_t'4, tfloat) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'27, tshort) :: (_t'26, tshort) ::
               (_t'25, tshort) :: (_t'24, tint) ::
               (_t'23, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'22, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'21, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'20, tint) ::
               (_t'19, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'18, tint) ::
               (_t'17, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'16, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'15, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'14, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'13, tshort) ::
               (_t'12, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'11, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'10, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'9, tshort) ::
               (_t'8, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'7, tschar) ::
               (_t'6, (tptr (Tstruct _EnvFxParticle noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _globalTimer (Evar _gGlobalTimer tuint))
  (Ssequence
    (Ssequence
      (Sset _t'27
        (Ederef
          (Ebinop Oadd (Etempvar _centerPos (tptr tshort))
            (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
      (Sset _centerX (Ecast (Etempvar _t'27 tshort) tshort)))
    (Ssequence
      (Ssequence
        (Sset _t'26
          (Ederef
            (Ebinop Oadd (Etempvar _centerPos (tptr tshort))
              (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
        (Sset _centerY (Ecast (Etempvar _t'26 tshort) tshort)))
      (Ssequence
        (Ssequence
          (Sset _t'25
            (Ederef
              (Ebinop Oadd (Etempvar _centerPos (tptr tshort))
                (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort))
          (Sset _centerZ (Ecast (Etempvar _t'25 tshort) tshort)))
        (Ssequence
          (Sset _i (Econst_int (Int.repr 0) tint))
          (Sloop
            (Ssequence
              (Ssequence
                (Sset _t'24 (Evar _sBubbleParticleMaxCount tint))
                (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                               (Etempvar _t'24 tint) tint)
                  Sskip
                  Sbreak))
              (Ssequence
                (Ssequence
                  (Scall (Some _t'1)
                    (Evar _particle_is_laterally_close (Tfunction
                                                         (tint :: tint ::
                                                          tint :: tint ::
                                                          nil) tint
                                                         cc_default))
                    ((Etempvar _i tint) :: (Etempvar _centerX tshort) ::
                     (Etempvar _centerZ tshort) ::
                     (Econst_int (Int.repr 3000) tint) :: nil))
                  (Ssequence
                    (Sset _t'23
                      (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                    (Sassign
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Etempvar _t'23 (tptr (Tstruct _EnvFxParticle noattr)))
                            (Etempvar _i tint)
                            (tptr (Tstruct _EnvFxParticle noattr)))
                          (Tstruct _EnvFxParticle noattr)) _isAlive tschar)
                      (Etempvar _t'1 tint))))
                (Ssequence
                  (Sset _t'6
                    (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                  (Ssequence
                    (Sset _t'7
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Etempvar _t'6 (tptr (Tstruct _EnvFxParticle noattr)))
                            (Etempvar _i tint)
                            (tptr (Tstruct _EnvFxParticle noattr)))
                          (Tstruct _EnvFxParticle noattr)) _isAlive tschar))
                    (Sifthenelse (Eunop Onotbool (Etempvar _t'7 tschar) tint)
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'2)
                            (Evar _random_flower_offset (Tfunction nil tint
                                                          cc_default)) nil)
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
                                  (Tstruct _EnvFxParticle noattr)) _xPos
                                tint)
                              (Ebinop Oadd (Etempvar _t'2 tint)
                                (Etempvar _centerX tshort) tint))))
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'3)
                              (Evar _random_flower_offset (Tfunction nil tint
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
                                    (Tstruct _EnvFxParticle noattr)) _zPos
                                  tint)
                                (Ebinop Oadd (Etempvar _t'3 tint)
                                  (Etempvar _centerZ tshort) tint))))
                          (Ssequence
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
                                          (Etempvar _i tint)
                                          (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Tstruct _EnvFxParticle noattr))
                                      _xPos tint))
                                  (Ssequence
                                    (Sset _t'19
                                      (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                    (Ssequence
                                      (Sset _t'20
                                        (Efield
                                          (Ederef
                                            (Ebinop Oadd
                                              (Etempvar _t'19 (tptr (Tstruct _EnvFxParticle noattr)))
                                              (Etempvar _i tint)
                                              (tptr (Tstruct _EnvFxParticle noattr)))
                                            (Tstruct _EnvFxParticle noattr))
                                          _zPos tint))
                                      (Scall (Some _t'4)
                                        (Evar _find_floor_height_and_data
                                        (Tfunction
                                          (tfloat :: tfloat :: tfloat ::
                                           (tptr (tptr (Tstruct _FloorGeometry noattr))) ::
                                           nil) tfloat cc_default))
                                        ((Etempvar _t'18 tint) ::
                                         (Econst_single (Float32.of_bits (Int.repr 1176256512)) tfloat) ::
                                         (Etempvar _t'20 tint) ::
                                         (Eaddrof
                                           (Evar _floorGeo (tptr (Tstruct _FloorGeometry noattr)))
                                           (tptr (tptr (Tstruct _FloorGeometry noattr)))) ::
                                         nil))))))
                              (Ssequence
                                (Sset _t'16
                                  (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'16 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr)) _yPos
                                    tint) (Etempvar _t'4 tfloat))))
                            (Ssequence
                              (Ssequence
                                (Sset _t'15
                                  (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'15 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr))
                                    _isAlive tschar)
                                  (Econst_int (Int.repr 1) tint)))
                              (Ssequence
                                (Scall (Some _t'5)
                                  (Evar _random_float (Tfunction nil tfloat
                                                        cc_default)) nil)
                                (Ssequence
                                  (Sset _t'14
                                    (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Etempvar _t'14 (tptr (Tstruct _EnvFxParticle noattr)))
                                          (Etempvar _i tint)
                                          (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Tstruct _EnvFxParticle noattr))
                                      _animFrame tshort)
                                    (Ebinop Omul (Etempvar _t'5 tfloat)
                                      (Econst_single (Float32.of_bits (Int.repr 1084227584)) tfloat)
                                      tfloat))))))))
                      (Sifthenelse (Eunop Onotbool
                                     (Ebinop Oand
                                       (Etempvar _globalTimer tint)
                                       (Econst_int (Int.repr 3) tint) tint)
                                     tint)
                        (Ssequence
                          (Ssequence
                            (Sset _t'11
                              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                            (Ssequence
                              (Sset _t'12
                                (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                              (Ssequence
                                (Sset _t'13
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'12 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr))
                                    _animFrame tshort))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'11 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr))
                                    _animFrame tshort)
                                  (Ebinop Oadd (Etempvar _t'13 tshort)
                                    (Econst_int (Int.repr 1) tint) tint)))))
                          (Ssequence
                            (Sset _t'8
                              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                            (Ssequence
                              (Sset _t'9
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'8 (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Etempvar _i tint)
                                      (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Tstruct _EnvFxParticle noattr))
                                  _animFrame tshort))
                              (Sifthenelse (Ebinop Ogt (Etempvar _t'9 tshort)
                                             (Econst_int (Int.repr 5) tint)
                                             tint)
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
                                        (Tstruct _EnvFxParticle noattr))
                                      _animFrame tshort)
                                    (Econst_int (Int.repr 0) tint)))
                                Sskip))))
                        Sskip))))))
            (Sset _i
              (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint)
                tint))))))))
|}.

Definition f_envfx_set_lava_bubble_position := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_index, tint) :: (_centerPos, (tptr tshort)) :: nil);
  fn_vars := ((_surface, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_temps := ((_floorY, tshort) :: (_centerX, tshort) ::
               (_centerY, tshort) :: (_centerZ, tshort) :: (_t'3, tfloat) ::
               (_t'2, tfloat) :: (_t'1, tfloat) :: (_t'38, tshort) ::
               (_t'37, tshort) :: (_t'36, tshort) ::
               (_t'35, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'34, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'33, tint) ::
               (_t'32, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'31, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'30, tint) ::
               (_t'29, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'28, tint) ::
               (_t'27, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'26, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'25, tint) ::
               (_t'24, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'23, tint) ::
               (_t'22, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'21, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'20, tint) ::
               (_t'19, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'18, tint) ::
               (_t'17, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'16, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'15, tint) ::
               (_t'14, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'13, tint) ::
               (_t'12, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'11, tint) ::
               (_t'10, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'9, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'8, (tptr (Tstruct _Surface noattr))) ::
               (_t'7, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'6, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'5, tshort) :: (_t'4, (tptr (Tstruct _Surface noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'38
      (Ederef
        (Ebinop Oadd (Etempvar _centerPos (tptr tshort))
          (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
    (Sset _centerX (Ecast (Etempvar _t'38 tshort) tshort)))
  (Ssequence
    (Ssequence
      (Sset _t'37
        (Ederef
          (Ebinop Oadd (Etempvar _centerPos (tptr tshort))
            (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
      (Sset _centerY (Ecast (Etempvar _t'37 tshort) tshort)))
    (Ssequence
      (Ssequence
        (Sset _t'36
          (Ederef
            (Ebinop Oadd (Etempvar _centerPos (tptr tshort))
              (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort))
        (Sset _centerZ (Ecast (Etempvar _t'36 tshort) tshort)))
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _random_float (Tfunction nil tfloat cc_default)) nil)
          (Ssequence
            (Sset _t'35
              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
            (Sassign
              (Efield
                (Ederef
                  (Ebinop Oadd
                    (Etempvar _t'35 (tptr (Tstruct _EnvFxParticle noattr)))
                    (Etempvar _index tint)
                    (tptr (Tstruct _EnvFxParticle noattr)))
                  (Tstruct _EnvFxParticle noattr)) _xPos tint)
              (Ebinop Oadd
                (Ebinop Osub
                  (Ebinop Omul (Etempvar _t'1 tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1169915904)) tfloat)
                    tfloat)
                  (Econst_single (Float32.of_bits (Int.repr 1161527296)) tfloat)
                  tfloat) (Etempvar _centerX tshort) tfloat))))
        (Ssequence
          (Ssequence
            (Scall (Some _t'2)
              (Evar _random_float (Tfunction nil tfloat cc_default)) nil)
            (Ssequence
              (Sset _t'34
                (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
              (Sassign
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Etempvar _t'34 (tptr (Tstruct _EnvFxParticle noattr)))
                      (Etempvar _index tint)
                      (tptr (Tstruct _EnvFxParticle noattr)))
                    (Tstruct _EnvFxParticle noattr)) _zPos tint)
                (Ebinop Oadd
                  (Ebinop Osub
                    (Ebinop Omul (Etempvar _t'2 tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1169915904)) tfloat)
                      tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1161527296)) tfloat)
                    tfloat) (Etempvar _centerZ tshort) tfloat))))
          (Ssequence
            (Ssequence
              (Sset _t'29
                (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
              (Ssequence
                (Sset _t'30
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Etempvar _t'29 (tptr (Tstruct _EnvFxParticle noattr)))
                        (Etempvar _index tint)
                        (tptr (Tstruct _EnvFxParticle noattr)))
                      (Tstruct _EnvFxParticle noattr)) _xPos tint))
                (Sifthenelse (Ebinop Ogt (Etempvar _t'30 tint)
                               (Econst_int (Int.repr 8000) tint) tint)
                  (Ssequence
                    (Sset _t'31
                      (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                    (Ssequence
                      (Sset _t'32
                        (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                      (Ssequence
                        (Sset _t'33
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Etempvar _t'32 (tptr (Tstruct _EnvFxParticle noattr)))
                                (Etempvar _index tint)
                                (tptr (Tstruct _EnvFxParticle noattr)))
                              (Tstruct _EnvFxParticle noattr)) _xPos tint))
                        (Sassign
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Etempvar _t'31 (tptr (Tstruct _EnvFxParticle noattr)))
                                (Etempvar _index tint)
                                (tptr (Tstruct _EnvFxParticle noattr)))
                              (Tstruct _EnvFxParticle noattr)) _xPos tint)
                          (Ebinop Osub (Econst_int (Int.repr 16000) tint)
                            (Etempvar _t'33 tint) tint)))))
                  Sskip)))
            (Ssequence
              (Ssequence
                (Sset _t'24
                  (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                (Ssequence
                  (Sset _t'25
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Etempvar _t'24 (tptr (Tstruct _EnvFxParticle noattr)))
                          (Etempvar _index tint)
                          (tptr (Tstruct _EnvFxParticle noattr)))
                        (Tstruct _EnvFxParticle noattr)) _xPos tint))
                  (Sifthenelse (Ebinop Olt (Etempvar _t'25 tint)
                                 (Eunop Oneg
                                   (Econst_int (Int.repr 8000) tint) tint)
                                 tint)
                    (Ssequence
                      (Sset _t'26
                        (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                      (Ssequence
                        (Sset _t'27
                          (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                        (Ssequence
                          (Sset _t'28
                            (Efield
                              (Ederef
                                (Ebinop Oadd
                                  (Etempvar _t'27 (tptr (Tstruct _EnvFxParticle noattr)))
                                  (Etempvar _index tint)
                                  (tptr (Tstruct _EnvFxParticle noattr)))
                                (Tstruct _EnvFxParticle noattr)) _xPos tint))
                          (Sassign
                            (Efield
                              (Ederef
                                (Ebinop Oadd
                                  (Etempvar _t'26 (tptr (Tstruct _EnvFxParticle noattr)))
                                  (Etempvar _index tint)
                                  (tptr (Tstruct _EnvFxParticle noattr)))
                                (Tstruct _EnvFxParticle noattr)) _xPos tint)
                            (Ebinop Osub
                              (Eunop Oneg (Econst_int (Int.repr 16000) tint)
                                tint) (Etempvar _t'28 tint) tint)))))
                    Sskip)))
              (Ssequence
                (Ssequence
                  (Sset _t'19
                    (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                  (Ssequence
                    (Sset _t'20
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Etempvar _t'19 (tptr (Tstruct _EnvFxParticle noattr)))
                            (Etempvar _index tint)
                            (tptr (Tstruct _EnvFxParticle noattr)))
                          (Tstruct _EnvFxParticle noattr)) _zPos tint))
                    (Sifthenelse (Ebinop Ogt (Etempvar _t'20 tint)
                                   (Econst_int (Int.repr 8000) tint) tint)
                      (Ssequence
                        (Sset _t'21
                          (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                        (Ssequence
                          (Sset _t'22
                            (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                          (Ssequence
                            (Sset _t'23
                              (Efield
                                (Ederef
                                  (Ebinop Oadd
                                    (Etempvar _t'22 (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Etempvar _index tint)
                                    (tptr (Tstruct _EnvFxParticle noattr)))
                                  (Tstruct _EnvFxParticle noattr)) _zPos
                                tint))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Ebinop Oadd
                                    (Etempvar _t'21 (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Etempvar _index tint)
                                    (tptr (Tstruct _EnvFxParticle noattr)))
                                  (Tstruct _EnvFxParticle noattr)) _zPos
                                tint)
                              (Ebinop Osub (Econst_int (Int.repr 16000) tint)
                                (Etempvar _t'23 tint) tint)))))
                      Sskip)))
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
                              (Etempvar _index tint)
                              (tptr (Tstruct _EnvFxParticle noattr)))
                            (Tstruct _EnvFxParticle noattr)) _zPos tint))
                      (Sifthenelse (Ebinop Olt (Etempvar _t'15 tint)
                                     (Eunop Oneg
                                       (Econst_int (Int.repr 8000) tint)
                                       tint) tint)
                        (Ssequence
                          (Sset _t'16
                            (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                          (Ssequence
                            (Sset _t'17
                              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                            (Ssequence
                              (Sset _t'18
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'17 (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Etempvar _index tint)
                                      (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Tstruct _EnvFxParticle noattr)) _zPos
                                  tint))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'16 (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Etempvar _index tint)
                                      (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Tstruct _EnvFxParticle noattr)) _zPos
                                  tint)
                                (Ebinop Osub
                                  (Eunop Oneg
                                    (Econst_int (Int.repr 16000) tint) tint)
                                  (Etempvar _t'18 tint) tint)))))
                        Sskip)))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'10
                          (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                        (Ssequence
                          (Sset _t'11
                            (Efield
                              (Ederef
                                (Ebinop Oadd
                                  (Etempvar _t'10 (tptr (Tstruct _EnvFxParticle noattr)))
                                  (Etempvar _index tint)
                                  (tptr (Tstruct _EnvFxParticle noattr)))
                                (Tstruct _EnvFxParticle noattr)) _xPos tint))
                          (Ssequence
                            (Sset _t'12
                              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                            (Ssequence
                              (Sset _t'13
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'12 (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Etempvar _index tint)
                                      (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Tstruct _EnvFxParticle noattr)) _zPos
                                  tint))
                              (Scall (Some _t'3)
                                (Evar _find_floor (Tfunction
                                                    (tfloat :: tfloat ::
                                                     tfloat ::
                                                     (tptr (tptr (Tstruct _Surface noattr))) ::
                                                     nil) tfloat cc_default))
                                ((Etempvar _t'11 tint) ::
                                 (Ebinop Oadd (Etempvar _centerY tshort)
                                   (Econst_int (Int.repr 500) tint) tint) ::
                                 (Etempvar _t'13 tint) ::
                                 (Eaddrof
                                   (Evar _surface (tptr (Tstruct _Surface noattr)))
                                   (tptr (tptr (Tstruct _Surface noattr)))) ::
                                 nil))))))
                      (Sset _floorY (Ecast (Etempvar _t'3 tfloat) tshort)))
                    (Ssequence
                      (Ssequence
                        (Sset _t'8
                          (Evar _surface (tptr (Tstruct _Surface noattr))))
                        (Sifthenelse (Ebinop Oeq
                                       (Etempvar _t'8 (tptr (Tstruct _Surface noattr)))
                                       (Ecast (Econst_int (Int.repr 0) tint)
                                         (tptr tvoid)) tint)
                          (Ssequence
                            (Ssequence
                              (Sset _t'9
                                (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'9 (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Etempvar _index tint)
                                      (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Tstruct _EnvFxParticle noattr)) _yPos
                                  tint)
                                (Ebinop Oadd
                                  (Eunop Oneg
                                    (Econst_int (Int.repr 11000) tint) tint)
                                  (Econst_int (Int.repr 1000) tint) tint)))
                            (Sreturn None))
                          Sskip))
                      (Ssequence
                        (Sset _t'4
                          (Evar _surface (tptr (Tstruct _Surface noattr))))
                        (Ssequence
                          (Sset _t'5
                            (Efield
                              (Ederef
                                (Etempvar _t'4 (tptr (Tstruct _Surface noattr)))
                                (Tstruct _Surface noattr)) _type tshort))
                          (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tshort)
                                         (Econst_int (Int.repr 1) tint) tint)
                            (Ssequence
                              (Sset _t'7
                                (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'7 (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Etempvar _index tint)
                                      (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Tstruct _EnvFxParticle noattr)) _yPos
                                  tint) (Etempvar _floorY tshort)))
                            (Ssequence
                              (Sset _t'6
                                (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'6 (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Etempvar _index tint)
                                      (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Tstruct _EnvFxParticle noattr)) _yPos
                                  tint)
                                (Ebinop Oadd
                                  (Eunop Oneg
                                    (Econst_int (Int.repr 11000) tint) tint)
                                  (Econst_int (Int.repr 1000) tint) tint)))))))))))))))))
|}.

Definition f_envfx_update_lava := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_centerPos, (tptr tshort)) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_globalTimer, tint) :: (_chance, tschar) ::
               (_centerX, tshort) :: (_centerY, tshort) ::
               (_centerZ, tshort) :: (_t'2, tschar) :: (_t'1, tfloat) ::
               (_t'16, tshort) :: (_t'15, tshort) :: (_t'14, tshort) ::
               (_t'13, tint) ::
               (_t'12, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'11, tshort) ::
               (_t'10, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'9, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'8, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'7, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'6, tshort) ::
               (_t'5, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'4, tschar) ::
               (_t'3, (tptr (Tstruct _EnvFxParticle noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _globalTimer (Evar _gGlobalTimer tuint))
  (Ssequence
    (Ssequence
      (Sset _t'16
        (Ederef
          (Ebinop Oadd (Etempvar _centerPos (tptr tshort))
            (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
      (Sset _centerX (Ecast (Etempvar _t'16 tshort) tshort)))
    (Ssequence
      (Ssequence
        (Sset _t'15
          (Ederef
            (Ebinop Oadd (Etempvar _centerPos (tptr tshort))
              (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
        (Sset _centerY (Ecast (Etempvar _t'15 tshort) tshort)))
      (Ssequence
        (Ssequence
          (Sset _t'14
            (Ederef
              (Ebinop Oadd (Etempvar _centerPos (tptr tshort))
                (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort))
          (Sset _centerZ (Ecast (Etempvar _t'14 tshort) tshort)))
        (Ssequence
          (Ssequence
            (Sset _i (Econst_int (Int.repr 0) tint))
            (Sloop
              (Ssequence
                (Ssequence
                  (Sset _t'13 (Evar _sBubbleParticleMaxCount tint))
                  (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                                 (Etempvar _t'13 tint) tint)
                    Sskip
                    Sbreak))
                (Ssequence
                  (Sset _t'3
                    (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                  (Ssequence
                    (Sset _t'4
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Etempvar _t'3 (tptr (Tstruct _EnvFxParticle noattr)))
                            (Etempvar _i tint)
                            (tptr (Tstruct _EnvFxParticle noattr)))
                          (Tstruct _EnvFxParticle noattr)) _isAlive tschar))
                    (Sifthenelse (Eunop Onotbool (Etempvar _t'4 tschar) tint)
                      (Ssequence
                        (Scall None
                          (Evar _envfx_set_lava_bubble_position (Tfunction
                                                                  (tint ::
                                                                   (tptr tshort) ::
                                                                   nil) tvoid
                                                                  cc_default))
                          ((Etempvar _i tint) ::
                           (Etempvar _centerPos (tptr tshort)) :: nil))
                        (Ssequence
                          (Sset _t'12
                            (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                          (Sassign
                            (Efield
                              (Ederef
                                (Ebinop Oadd
                                  (Etempvar _t'12 (tptr (Tstruct _EnvFxParticle noattr)))
                                  (Etempvar _i tint)
                                  (tptr (Tstruct _EnvFxParticle noattr)))
                                (Tstruct _EnvFxParticle noattr)) _isAlive
                              tschar) (Econst_int (Int.repr 1) tint))))
                      (Sifthenelse (Eunop Onotbool
                                     (Ebinop Oand
                                       (Etempvar _globalTimer tint)
                                       (Econst_int (Int.repr 1) tint) tint)
                                     tint)
                        (Ssequence
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
                                    _animFrame tshort))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'9 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr))
                                    _animFrame tshort)
                                  (Ebinop Oadd (Etempvar _t'11 tshort)
                                    (Econst_int (Int.repr 1) tint) tint)))))
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
                                    (Tstruct _EnvFxParticle noattr))
                                  _animFrame tshort))
                              (Sifthenelse (Ebinop Ogt (Etempvar _t'6 tshort)
                                             (Econst_int (Int.repr 8) tint)
                                             tint)
                                (Ssequence
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
                                          (Tstruct _EnvFxParticle noattr))
                                        _isAlive tschar)
                                      (Econst_int (Int.repr 0) tint)))
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
                                          (Tstruct _EnvFxParticle noattr))
                                        _animFrame tshort)
                                      (Econst_int (Int.repr 0) tint))))
                                Sskip))))
                        Sskip)))))
              (Sset _i
                (Ebinop Oadd (Etempvar _i tint)
                  (Econst_int (Int.repr 1) tint) tint))))
          (Ssequence
            (Ssequence
              (Ssequence
                (Scall (Some _t'1)
                  (Evar _random_float (Tfunction nil tfloat cc_default)) nil)
                (Sset _t'2
                  (Ecast
                    (Ecast
                      (Ebinop Omul (Etempvar _t'1 tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                        tfloat) tint) tschar)))
              (Sset _chance (Ecast (Etempvar _t'2 tschar) tschar)))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tschar)
                           (Econst_int (Int.repr 8) tint) tint)
              (Scall None
                (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil)
                                    tvoid cc_default))
                ((Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 3) tint) tuint)
                           (Econst_int (Int.repr 28) tint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 13) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 0) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Econst_int (Int.repr 128) tint) tuint)
                   (Econst_int (Int.repr 1) tint) tuint) ::
                 (Evar _gGlobalSoundSource (tarray tfloat 3)) :: nil))
              Sskip)))))))
|}.

Definition f_envfx_rotate_around_whirlpool := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_x, (tptr tint)) :: (_y, (tptr tint)) ::
                (_z, (tptr tint)) :: nil);
  fn_vars := nil;
  fn_temps := ((_vecX, tint) :: (_vecY, tint) :: (_vecZ, tint) ::
               (_cosPitch, tfloat) :: (_sinPitch, tfloat) ::
               (_cosMYaw, tfloat) :: (_sinMYaw, tfloat) ::
               (_rotatedX, tfloat) :: (_rotatedY, tfloat) ::
               (_rotatedZ, tfloat) :: (_t'13, tshort) :: (_t'12, tint) ::
               (_t'11, tshort) :: (_t'10, tint) :: (_t'9, tshort) ::
               (_t'8, tint) :: (_t'7, tshort) :: (_t'6, tshort) ::
               (_t'5, tshort) :: (_t'4, tshort) :: (_t'3, tshort) ::
               (_t'2, tshort) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'12 (Ederef (Etempvar _x (tptr tint)) tint))
    (Ssequence
      (Sset _t'13
        (Ederef
          (Ebinop Oadd (Evar _gEnvFxBubbleConfig (tarray tshort 10))
            (Econst_int (Int.repr 4) tint) (tptr tshort)) tshort))
      (Sset _vecX
        (Ebinop Osub (Etempvar _t'12 tint) (Etempvar _t'13 tshort) tint))))
  (Ssequence
    (Ssequence
      (Sset _t'10 (Ederef (Etempvar _y (tptr tint)) tint))
      (Ssequence
        (Sset _t'11
          (Ederef
            (Ebinop Oadd (Evar _gEnvFxBubbleConfig (tarray tshort 10))
              (Econst_int (Int.repr 5) tint) (tptr tshort)) tshort))
        (Sset _vecY
          (Ebinop Osub (Etempvar _t'10 tint) (Etempvar _t'11 tshort) tint))))
    (Ssequence
      (Ssequence
        (Sset _t'8 (Ederef (Etempvar _z (tptr tint)) tint))
        (Ssequence
          (Sset _t'9
            (Ederef
              (Ebinop Oadd (Evar _gEnvFxBubbleConfig (tarray tshort 10))
                (Econst_int (Int.repr 6) tint) (tptr tshort)) tshort))
          (Sset _vecZ
            (Ebinop Osub (Etempvar _t'8 tint) (Etempvar _t'9 tshort) tint))))
      (Ssequence
        (Ssequence
          (Sset _t'7
            (Ederef
              (Ebinop Oadd (Evar _gEnvFxBubbleConfig (tarray tshort 10))
                (Econst_int (Int.repr 8) tint) (tptr tshort)) tshort))
          (Sset _cosPitch
            (Ederef
              (Ebinop Oadd
                (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                  (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                (Ebinop Oshr (Ecast (Etempvar _t'7 tshort) tushort)
                  (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat)))
        (Ssequence
          (Ssequence
            (Sset _t'6
              (Ederef
                (Ebinop Oadd (Evar _gEnvFxBubbleConfig (tarray tshort 10))
                  (Econst_int (Int.repr 8) tint) (tptr tshort)) tshort))
            (Sset _sinPitch
              (Ederef
                (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                  (Ebinop Oshr (Ecast (Etempvar _t'6 tshort) tushort)
                    (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                tfloat)))
          (Ssequence
            (Ssequence
              (Sset _t'5
                (Ederef
                  (Ebinop Oadd (Evar _gEnvFxBubbleConfig (tarray tshort 10))
                    (Econst_int (Int.repr 9) tint) (tptr tshort)) tshort))
              (Sset _cosMYaw
                (Ederef
                  (Ebinop Oadd
                    (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                      (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                    (Ebinop Oshr
                      (Ecast (Eunop Oneg (Etempvar _t'5 tshort) tint)
                        tushort) (Econst_int (Int.repr 4) tint) tint)
                    (tptr tfloat)) tfloat)))
            (Ssequence
              (Ssequence
                (Sset _t'4
                  (Ederef
                    (Ebinop Oadd
                      (Evar _gEnvFxBubbleConfig (tarray tshort 10))
                      (Econst_int (Int.repr 9) tint) (tptr tshort)) tshort))
                (Sset _sinMYaw
                  (Ederef
                    (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                      (Ebinop Oshr
                        (Ecast (Eunop Oneg (Etempvar _t'4 tshort) tint)
                          tushort) (Econst_int (Int.repr 4) tint) tint)
                      (tptr tfloat)) tfloat)))
              (Ssequence
                (Sset _rotatedX
                  (Ebinop Osub
                    (Ebinop Osub
                      (Ebinop Omul (Etempvar _vecX tint)
                        (Etempvar _cosMYaw tfloat) tfloat)
                      (Ebinop Omul
                        (Ebinop Omul (Etempvar _sinMYaw tfloat)
                          (Etempvar _cosPitch tfloat) tfloat)
                        (Etempvar _vecY tint) tfloat) tfloat)
                    (Ebinop Omul
                      (Ebinop Omul (Etempvar _sinPitch tfloat)
                        (Etempvar _sinMYaw tfloat) tfloat)
                      (Etempvar _vecZ tint) tfloat) tfloat))
                (Ssequence
                  (Sset _rotatedY
                    (Ebinop Osub
                      (Ebinop Oadd
                        (Ebinop Omul (Etempvar _vecX tint)
                          (Etempvar _sinMYaw tfloat) tfloat)
                        (Ebinop Omul
                          (Ebinop Omul (Etempvar _cosPitch tfloat)
                            (Etempvar _cosMYaw tfloat) tfloat)
                          (Etempvar _vecY tint) tfloat) tfloat)
                      (Ebinop Omul
                        (Ebinop Omul (Etempvar _sinPitch tfloat)
                          (Etempvar _cosMYaw tfloat) tfloat)
                        (Etempvar _vecZ tint) tfloat) tfloat))
                  (Ssequence
                    (Sset _rotatedZ
                      (Ebinop Oadd
                        (Ebinop Omul (Etempvar _vecY tint)
                          (Etempvar _sinPitch tfloat) tfloat)
                        (Ebinop Omul (Etempvar _cosPitch tfloat)
                          (Etempvar _vecZ tint) tfloat) tfloat))
                    (Ssequence
                      (Ssequence
                        (Sset _t'3
                          (Ederef
                            (Ebinop Oadd
                              (Evar _gEnvFxBubbleConfig (tarray tshort 10))
                              (Econst_int (Int.repr 4) tint) (tptr tshort))
                            tshort))
                        (Sassign (Ederef (Etempvar _x (tptr tint)) tint)
                          (Ebinop Oadd (Etempvar _t'3 tshort)
                            (Ecast (Etempvar _rotatedX tfloat) tint) tint)))
                      (Ssequence
                        (Ssequence
                          (Sset _t'2
                            (Ederef
                              (Ebinop Oadd
                                (Evar _gEnvFxBubbleConfig (tarray tshort 10))
                                (Econst_int (Int.repr 5) tint) (tptr tshort))
                              tshort))
                          (Sassign (Ederef (Etempvar _y (tptr tint)) tint)
                            (Ebinop Oadd (Etempvar _t'2 tshort)
                              (Ecast (Etempvar _rotatedY tfloat) tint) tint)))
                        (Ssequence
                          (Sset _t'1
                            (Ederef
                              (Ebinop Oadd
                                (Evar _gEnvFxBubbleConfig (tarray tshort 10))
                                (Econst_int (Int.repr 6) tint) (tptr tshort))
                              tshort))
                          (Sassign (Ederef (Etempvar _z (tptr tint)) tint)
                            (Ebinop Oadd (Etempvar _t'1 tshort)
                              (Ecast (Etempvar _rotatedZ tfloat) tint) tint)))))))))))))))
|}.

Definition f_envfx_is_whirlpool_bubble_alive := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_index, tint) :: nil);
  fn_vars := ((_filler, (tarray tuchar 4)) :: nil);
  fn_temps := ((_t'5, tshort) :: (_t'4, tint) ::
               (_t'3, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'2, tint) ::
               (_t'1, (tptr (Tstruct _EnvFxParticle noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3 (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
    (Ssequence
      (Sset _t'4
        (Efield
          (Ederef
            (Ebinop Oadd
              (Etempvar _t'3 (tptr (Tstruct _EnvFxParticle noattr)))
              (Etempvar _index tint) (tptr (Tstruct _EnvFxParticle noattr)))
            (Tstruct _EnvFxParticle noattr)) _bubbleY tint))
      (Ssequence
        (Sset _t'5
          (Ederef
            (Ebinop Oadd (Evar _gEnvFxBubbleConfig (tarray tshort 10))
              (Econst_int (Int.repr 5) tint) (tptr tshort)) tshort))
        (Sifthenelse (Ebinop Olt (Etempvar _t'4 tint)
                       (Ebinop Osub (Etempvar _t'5 tshort)
                         (Econst_int (Int.repr 100) tint) tint) tint)
          (Sreturn (Some (Econst_int (Int.repr 0) tint)))
          Sskip))))
  (Ssequence
    (Ssequence
      (Sset _t'1 (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
      (Ssequence
        (Sset _t'2
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef
                  (Ebinop Oadd
                    (Etempvar _t'1 (tptr (Tstruct _EnvFxParticle noattr)))
                    (Etempvar _index tint)
                    (tptr (Tstruct _EnvFxParticle noattr)))
                  (Tstruct _EnvFxParticle noattr)) _angleAndDist
                (tarray tint 2)) (Econst_int (Int.repr 1) tint) (tptr tint))
            tint))
        (Sifthenelse (Ebinop Olt (Etempvar _t'2 tint)
                       (Econst_int (Int.repr 10) tint) tint)
          (Sreturn (Some (Econst_int (Int.repr 0) tint)))
          Sskip)))
    (Sreturn (Some (Econst_int (Int.repr 1) tint)))))
|}.

Definition f_envfx_update_whirlpool := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_t'4, tfloat) :: (_t'3, tfloat) ::
               (_t'2, tfloat) :: (_t'1, tint) :: (_t'67, tint) ::
               (_t'66, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'65, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'64, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'63, tint) ::
               (_t'62, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'61, tfloat) :: (_t'60, tint) ::
               (_t'59, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'58, tshort) ::
               (_t'57, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'56, tint) ::
               (_t'55, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'54, tfloat) :: (_t'53, tint) ::
               (_t'52, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'51, tshort) ::
               (_t'50, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'49, tshort) ::
               (_t'48, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'47, tint) ::
               (_t'46, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'45, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'44, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'43, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'42, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'41, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'40, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'39, tint) ::
               (_t'38, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'37, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'36, tint) ::
               (_t'35, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'34, tint) ::
               (_t'33, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'32, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'31, tint) ::
               (_t'30, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'29, tfloat) :: (_t'28, tint) ::
               (_t'27, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'26, tshort) ::
               (_t'25, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'24, tint) ::
               (_t'23, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'22, tfloat) :: (_t'21, tint) ::
               (_t'20, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'19, tshort) ::
               (_t'18, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'17, tint) ::
               (_t'16, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'15, tint) ::
               (_t'14, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'13, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'12, tint) ::
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
        (Sset _t'67 (Evar _sBubbleParticleMaxCount tint))
        (Sifthenelse (Ebinop Olt (Etempvar _i tint) (Etempvar _t'67 tint)
                       tint)
          Sskip
          Sbreak))
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _envfx_is_whirlpool_bubble_alive (Tfunction (tint :: nil)
                                                     tint cc_default))
            ((Etempvar _i tint) :: nil))
          (Ssequence
            (Sset _t'66
              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
            (Sassign
              (Efield
                (Ederef
                  (Ebinop Oadd
                    (Etempvar _t'66 (tptr (Tstruct _EnvFxParticle noattr)))
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
                    (Sset _t'65
                      (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Etempvar _t'65 (tptr (Tstruct _EnvFxParticle noattr)))
                                (Etempvar _i tint)
                                (tptr (Tstruct _EnvFxParticle noattr)))
                              (Tstruct _EnvFxParticle noattr)) _angleAndDist
                            (tarray tint 2)) (Econst_int (Int.repr 1) tint)
                          (tptr tint)) tint)
                      (Ebinop Omul (Etempvar _t'2 tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1148846080)) tfloat)
                        tfloat))))
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'3)
                      (Evar _random_float (Tfunction nil tfloat cc_default))
                      nil)
                    (Ssequence
                      (Sset _t'64
                        (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Ebinop Oadd
                                  (Etempvar _t'64 (tptr (Tstruct _EnvFxParticle noattr)))
                                  (Etempvar _i tint)
                                  (tptr (Tstruct _EnvFxParticle noattr)))
                                (Tstruct _EnvFxParticle noattr))
                              _angleAndDist (tarray tint 2))
                            (Econst_int (Int.repr 0) tint) (tptr tint)) tint)
                        (Ebinop Omul (Etempvar _t'3 tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1199570944)) tfloat)
                          tfloat))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'57
                        (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                      (Ssequence
                        (Sset _t'58
                          (Ederef
                            (Ebinop Oadd
                              (Evar _gEnvFxBubbleConfig (tarray tshort 10))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))
                            tshort))
                        (Ssequence
                          (Sset _t'59
                            (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                          (Ssequence
                            (Sset _t'60
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'59 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr))
                                    _angleAndDist (tarray tint 2))
                                  (Econst_int (Int.repr 0) tint) (tptr tint))
                                tint))
                            (Ssequence
                              (Sset _t'61
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _gSineTable (tarray tfloat 0))
                                    (Ebinop Oshr
                                      (Ecast (Etempvar _t'60 tint) tushort)
                                      (Econst_int (Int.repr 4) tint) tint)
                                    (tptr tfloat)) tfloat))
                              (Ssequence
                                (Sset _t'62
                                  (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                (Ssequence
                                  (Sset _t'63
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Ederef
                                            (Ebinop Oadd
                                              (Etempvar _t'62 (tptr (Tstruct _EnvFxParticle noattr)))
                                              (Etempvar _i tint)
                                              (tptr (Tstruct _EnvFxParticle noattr)))
                                            (Tstruct _EnvFxParticle noattr))
                                          _angleAndDist (tarray tint 2))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr tint)) tint))
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Etempvar _t'57 (tptr (Tstruct _EnvFxParticle noattr)))
                                          (Etempvar _i tint)
                                          (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Tstruct _EnvFxParticle noattr))
                                      _xPos tint)
                                    (Ebinop Oadd (Etempvar _t'58 tshort)
                                      (Ebinop Omul (Etempvar _t'61 tfloat)
                                        (Etempvar _t'63 tint) tfloat) tfloat)))))))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'50
                          (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                        (Ssequence
                          (Sset _t'51
                            (Ederef
                              (Ebinop Oadd
                                (Evar _gEnvFxBubbleConfig (tarray tshort 10))
                                (Econst_int (Int.repr 3) tint) (tptr tshort))
                              tshort))
                          (Ssequence
                            (Sset _t'52
                              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                            (Ssequence
                              (Sset _t'53
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Etempvar _t'52 (tptr (Tstruct _EnvFxParticle noattr)))
                                          (Etempvar _i tint)
                                          (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Tstruct _EnvFxParticle noattr))
                                      _angleAndDist (tarray tint 2))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr tint)) tint))
                              (Ssequence
                                (Sset _t'54
                                  (Ederef
                                    (Ebinop Oadd
                                      (Ebinop Oadd
                                        (Evar _gSineTable (tarray tfloat 0))
                                        (Econst_int (Int.repr 1024) tint)
                                        (tptr tfloat))
                                      (Ebinop Oshr
                                        (Ecast (Etempvar _t'53 tint) tushort)
                                        (Econst_int (Int.repr 4) tint) tint)
                                      (tptr tfloat)) tfloat))
                                (Ssequence
                                  (Sset _t'55
                                    (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                  (Ssequence
                                    (Sset _t'56
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Ederef
                                              (Ebinop Oadd
                                                (Etempvar _t'55 (tptr (Tstruct _EnvFxParticle noattr)))
                                                (Etempvar _i tint)
                                                (tptr (Tstruct _EnvFxParticle noattr)))
                                              (Tstruct _EnvFxParticle noattr))
                                            _angleAndDist (tarray tint 2))
                                          (Econst_int (Int.repr 1) tint)
                                          (tptr tint)) tint))
                                    (Sassign
                                      (Efield
                                        (Ederef
                                          (Ebinop Oadd
                                            (Etempvar _t'50 (tptr (Tstruct _EnvFxParticle noattr)))
                                            (Etempvar _i tint)
                                            (tptr (Tstruct _EnvFxParticle noattr)))
                                          (Tstruct _EnvFxParticle noattr))
                                        _zPos tint)
                                      (Ebinop Oadd (Etempvar _t'51 tshort)
                                        (Ebinop Omul (Etempvar _t'54 tfloat)
                                          (Etempvar _t'56 tint) tfloat)
                                        tfloat)))))))))
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'4)
                            (Evar _random_float (Tfunction nil tfloat
                                                  cc_default)) nil)
                          (Ssequence
                            (Sset _t'48
                              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                            (Ssequence
                              (Sset _t'49
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _gEnvFxBubbleConfig (tarray tshort 10))
                                    (Econst_int (Int.repr 2) tint)
                                    (tptr tshort)) tshort))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'48 (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Etempvar _i tint)
                                      (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Tstruct _EnvFxParticle noattr)) _bubbleY
                                  tint)
                                (Ebinop Oadd (Etempvar _t'49 tshort)
                                  (Ebinop Osub
                                    (Ebinop Omul (Etempvar _t'4 tfloat)
                                      (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                                      tfloat)
                                    (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat)
                                    tfloat) tfloat)))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'45
                              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                            (Ssequence
                              (Sset _t'46
                                (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                              (Ssequence
                                (Sset _t'47
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd (Etempvar _i tint)
                                        (Etempvar _t'46 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr))
                                    _bubbleY tint))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'45 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr)) _yPos
                                    tint) (Etempvar _t'47 tint)))))
                          (Ssequence
                            (Ssequence
                              (Sset _t'44
                                (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'44 (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Etempvar _i tint)
                                      (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Tstruct _EnvFxParticle noattr))
                                  _unusedBubbleVar tint)
                                (Econst_int (Int.repr 0) tint)))
                            (Ssequence
                              (Ssequence
                                (Sset _t'43
                                  (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'43 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr))
                                    _isAlive tschar)
                                  (Econst_int (Int.repr 1) tint)))
                              (Ssequence
                                (Sset _t'40
                                  (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                (Ssequence
                                  (Sset _t'41
                                    (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                  (Ssequence
                                    (Sset _t'42
                                      (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                    (Scall None
                                      (Evar _envfx_rotate_around_whirlpool
                                      (Tfunction
                                        ((tptr tint) :: (tptr tint) ::
                                         (tptr tint) :: nil) tvoid
                                        cc_default))
                                      ((Eaddrof
                                         (Efield
                                           (Ederef
                                             (Ebinop Oadd
                                               (Etempvar _t'40 (tptr (Tstruct _EnvFxParticle noattr)))
                                               (Etempvar _i tint)
                                               (tptr (Tstruct _EnvFxParticle noattr)))
                                             (Tstruct _EnvFxParticle noattr))
                                           _xPos tint) (tptr tint)) ::
                                       (Eaddrof
                                         (Efield
                                           (Ederef
                                             (Ebinop Oadd
                                               (Etempvar _t'41 (tptr (Tstruct _EnvFxParticle noattr)))
                                               (Etempvar _i tint)
                                               (tptr (Tstruct _EnvFxParticle noattr)))
                                             (Tstruct _EnvFxParticle noattr))
                                           _yPos tint) (tptr tint)) ::
                                       (Eaddrof
                                         (Efield
                                           (Ederef
                                             (Ebinop Oadd
                                               (Etempvar _t'42 (tptr (Tstruct _EnvFxParticle noattr)))
                                               (Etempvar _i tint)
                                               (tptr (Tstruct _EnvFxParticle noattr)))
                                             (Tstruct _EnvFxParticle noattr))
                                           _zPos tint) (tptr tint)) :: nil)))))))))))))
              (Ssequence
                (Ssequence
                  (Sset _t'37
                    (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                  (Ssequence
                    (Sset _t'38
                      (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                    (Ssequence
                      (Sset _t'39
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Ebinop Oadd
                                  (Etempvar _t'38 (tptr (Tstruct _EnvFxParticle noattr)))
                                  (Etempvar _i tint)
                                  (tptr (Tstruct _EnvFxParticle noattr)))
                                (Tstruct _EnvFxParticle noattr))
                              _angleAndDist (tarray tint 2))
                            (Econst_int (Int.repr 1) tint) (tptr tint)) tint))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Ebinop Oadd
                                  (Etempvar _t'37 (tptr (Tstruct _EnvFxParticle noattr)))
                                  (Etempvar _i tint)
                                  (tptr (Tstruct _EnvFxParticle noattr)))
                                (Tstruct _EnvFxParticle noattr))
                              _angleAndDist (tarray tint 2))
                            (Econst_int (Int.repr 1) tint) (tptr tint)) tint)
                        (Ebinop Osub (Etempvar _t'39 tint)
                          (Econst_int (Int.repr 40) tint) tint)))))
                (Ssequence
                  (Ssequence
                    (Sset _t'32
                      (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                    (Ssequence
                      (Sset _t'33
                        (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                      (Ssequence
                        (Sset _t'34
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Ebinop Oadd
                                    (Etempvar _t'33 (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Etempvar _i tint)
                                    (tptr (Tstruct _EnvFxParticle noattr)))
                                  (Tstruct _EnvFxParticle noattr))
                                _angleAndDist (tarray tint 2))
                              (Econst_int (Int.repr 0) tint) (tptr tint))
                            tint))
                        (Ssequence
                          (Sset _t'35
                            (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                          (Ssequence
                            (Sset _t'36
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'35 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr))
                                    _angleAndDist (tarray tint 2))
                                  (Econst_int (Int.repr 1) tint) (tptr tint))
                                tint))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'32 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr))
                                    _angleAndDist (tarray tint 2))
                                  (Econst_int (Int.repr 0) tint) (tptr tint))
                                tint)
                              (Ebinop Oadd (Etempvar _t'34 tint)
                                (Ebinop Oadd
                                  (Ecast
                                    (Ebinop Osub
                                      (Econst_int (Int.repr 3000) tint)
                                      (Ebinop Omul (Etempvar _t'36 tint)
                                        (Econst_int (Int.repr 2) tint) tint)
                                      tint) tshort)
                                  (Econst_int (Int.repr 1024) tint) tint)
                                tint)))))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'25
                        (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                      (Ssequence
                        (Sset _t'26
                          (Ederef
                            (Ebinop Oadd
                              (Evar _gEnvFxBubbleConfig (tarray tshort 10))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))
                            tshort))
                        (Ssequence
                          (Sset _t'27
                            (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                          (Ssequence
                            (Sset _t'28
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'27 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr))
                                    _angleAndDist (tarray tint 2))
                                  (Econst_int (Int.repr 0) tint) (tptr tint))
                                tint))
                            (Ssequence
                              (Sset _t'29
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _gSineTable (tarray tfloat 0))
                                    (Ebinop Oshr
                                      (Ecast (Etempvar _t'28 tint) tushort)
                                      (Econst_int (Int.repr 4) tint) tint)
                                    (tptr tfloat)) tfloat))
                              (Ssequence
                                (Sset _t'30
                                  (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                (Ssequence
                                  (Sset _t'31
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Ederef
                                            (Ebinop Oadd
                                              (Etempvar _t'30 (tptr (Tstruct _EnvFxParticle noattr)))
                                              (Etempvar _i tint)
                                              (tptr (Tstruct _EnvFxParticle noattr)))
                                            (Tstruct _EnvFxParticle noattr))
                                          _angleAndDist (tarray tint 2))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr tint)) tint))
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Etempvar _t'25 (tptr (Tstruct _EnvFxParticle noattr)))
                                          (Etempvar _i tint)
                                          (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Tstruct _EnvFxParticle noattr))
                                      _xPos tint)
                                    (Ebinop Oadd (Etempvar _t'26 tshort)
                                      (Ebinop Omul (Etempvar _t'29 tfloat)
                                        (Etempvar _t'31 tint) tfloat) tfloat)))))))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'18
                          (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                        (Ssequence
                          (Sset _t'19
                            (Ederef
                              (Ebinop Oadd
                                (Evar _gEnvFxBubbleConfig (tarray tshort 10))
                                (Econst_int (Int.repr 3) tint) (tptr tshort))
                              tshort))
                          (Ssequence
                            (Sset _t'20
                              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                            (Ssequence
                              (Sset _t'21
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Etempvar _t'20 (tptr (Tstruct _EnvFxParticle noattr)))
                                          (Etempvar _i tint)
                                          (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Tstruct _EnvFxParticle noattr))
                                      _angleAndDist (tarray tint 2))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr tint)) tint))
                              (Ssequence
                                (Sset _t'22
                                  (Ederef
                                    (Ebinop Oadd
                                      (Ebinop Oadd
                                        (Evar _gSineTable (tarray tfloat 0))
                                        (Econst_int (Int.repr 1024) tint)
                                        (tptr tfloat))
                                      (Ebinop Oshr
                                        (Ecast (Etempvar _t'21 tint) tushort)
                                        (Econst_int (Int.repr 4) tint) tint)
                                      (tptr tfloat)) tfloat))
                                (Ssequence
                                  (Sset _t'23
                                    (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                  (Ssequence
                                    (Sset _t'24
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Ederef
                                              (Ebinop Oadd
                                                (Etempvar _t'23 (tptr (Tstruct _EnvFxParticle noattr)))
                                                (Etempvar _i tint)
                                                (tptr (Tstruct _EnvFxParticle noattr)))
                                              (Tstruct _EnvFxParticle noattr))
                                            _angleAndDist (tarray tint 2))
                                          (Econst_int (Int.repr 1) tint)
                                          (tptr tint)) tint))
                                    (Sassign
                                      (Efield
                                        (Ederef
                                          (Ebinop Oadd
                                            (Etempvar _t'18 (tptr (Tstruct _EnvFxParticle noattr)))
                                            (Etempvar _i tint)
                                            (tptr (Tstruct _EnvFxParticle noattr)))
                                          (Tstruct _EnvFxParticle noattr))
                                        _zPos tint)
                                      (Ebinop Oadd (Etempvar _t'19 tshort)
                                        (Ebinop Omul (Etempvar _t'22 tfloat)
                                          (Etempvar _t'24 tint) tfloat)
                                        tfloat)))))))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'13
                            (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                          (Ssequence
                            (Sset _t'14
                              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                            (Ssequence
                              (Sset _t'15
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'14 (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Etempvar _i tint)
                                      (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Tstruct _EnvFxParticle noattr)) _bubbleY
                                  tint))
                              (Ssequence
                                (Sset _t'16
                                  (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                (Ssequence
                                  (Sset _t'17
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Ederef
                                            (Ebinop Oadd
                                              (Etempvar _t'16 (tptr (Tstruct _EnvFxParticle noattr)))
                                              (Etempvar _i tint)
                                              (tptr (Tstruct _EnvFxParticle noattr)))
                                            (Tstruct _EnvFxParticle noattr))
                                          _angleAndDist (tarray tint 2))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr tint)) tint))
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Etempvar _t'13 (tptr (Tstruct _EnvFxParticle noattr)))
                                          (Etempvar _i tint)
                                          (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Tstruct _EnvFxParticle noattr))
                                      _bubbleY tint)
                                    (Ebinop Osub (Etempvar _t'15 tint)
                                      (Ebinop Osub
                                        (Econst_int (Int.repr 40) tint)
                                        (Ebinop Odiv
                                          (Ecast (Etempvar _t'17 tint)
                                            tshort)
                                          (Econst_int (Int.repr 100) tint)
                                          tint) tint) tint)))))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'10
                              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                            (Ssequence
                              (Sset _t'11
                                (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                              (Ssequence
                                (Sset _t'12
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd (Etempvar _i tint)
                                        (Etempvar _t'11 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr))
                                    _bubbleY tint))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'10 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr)) _yPos
                                    tint) (Etempvar _t'12 tint)))))
                          (Ssequence
                            (Sset _t'7
                              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                            (Ssequence
                              (Sset _t'8
                                (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                              (Ssequence
                                (Sset _t'9
                                  (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                (Scall None
                                  (Evar _envfx_rotate_around_whirlpool
                                  (Tfunction
                                    ((tptr tint) :: (tptr tint) ::
                                     (tptr tint) :: nil) tvoid cc_default))
                                  ((Eaddrof
                                     (Efield
                                       (Ederef
                                         (Ebinop Oadd
                                           (Etempvar _t'7 (tptr (Tstruct _EnvFxParticle noattr)))
                                           (Etempvar _i tint)
                                           (tptr (Tstruct _EnvFxParticle noattr)))
                                         (Tstruct _EnvFxParticle noattr))
                                       _xPos tint) (tptr tint)) ::
                                   (Eaddrof
                                     (Efield
                                       (Ederef
                                         (Ebinop Oadd
                                           (Etempvar _t'8 (tptr (Tstruct _EnvFxParticle noattr)))
                                           (Etempvar _i tint)
                                           (tptr (Tstruct _EnvFxParticle noattr)))
                                         (Tstruct _EnvFxParticle noattr))
                                       _yPos tint) (tptr tint)) ::
                                   (Eaddrof
                                     (Efield
                                       (Ederef
                                         (Ebinop Oadd
                                           (Etempvar _t'9 (tptr (Tstruct _EnvFxParticle noattr)))
                                           (Etempvar _i tint)
                                           (tptr (Tstruct _EnvFxParticle noattr)))
                                         (Tstruct _EnvFxParticle noattr))
                                       _zPos tint) (tptr tint)) :: nil))))))))))))))))
    (Sset _i
      (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint) tint))))
|}.

Definition f_envfx_is_jestream_bubble_alive := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_index, tint) :: nil);
  fn_vars := ((_filler, (tarray tuchar 4)) :: nil);
  fn_temps := ((_t'2, tint) :: (_t'1, tint) :: (_t'7, tshort) ::
               (_t'6, tshort) :: (_t'5, tint) ::
               (_t'4, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'3, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'6
          (Ederef
            (Ebinop Oadd (Evar _gEnvFxBubbleConfig (tarray tshort 10))
              (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
        (Ssequence
          (Sset _t'7
            (Ederef
              (Ebinop Oadd (Evar _gEnvFxBubbleConfig (tarray tshort 10))
                (Econst_int (Int.repr 3) tint) (tptr tshort)) tshort))
          (Scall (Some _t'1)
            (Evar _particle_is_laterally_close (Tfunction
                                                 (tint :: tint :: tint ::
                                                  tint :: nil) tint
                                                 cc_default))
            ((Etempvar _index tint) :: (Etempvar _t'6 tshort) ::
             (Etempvar _t'7 tshort) :: (Econst_int (Int.repr 1000) tint) ::
             nil))))
      (Sifthenelse (Eunop Onotbool (Etempvar _t'1 tint) tint)
        (Sset _t'2 (Econst_int (Int.repr 1) tint))
        (Ssequence
          (Sset _t'3
            (Ederef
              (Ebinop Oadd (Evar _gEnvFxBubbleConfig (tarray tshort 10))
                (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort))
          (Ssequence
            (Sset _t'4
              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
            (Ssequence
              (Sset _t'5
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Etempvar _t'4 (tptr (Tstruct _EnvFxParticle noattr)))
                      (Etempvar _index tint)
                      (tptr (Tstruct _EnvFxParticle noattr)))
                    (Tstruct _EnvFxParticle noattr)) _yPos tint))
              (Sset _t'2
                (Ecast
                  (Ebinop Olt
                    (Ebinop Oadd (Etempvar _t'3 tshort)
                      (Econst_int (Int.repr 1500) tint) tint)
                    (Etempvar _t'5 tint) tint) tbool)))))))
    (Sifthenelse (Etempvar _t'2 tint)
      (Sreturn (Some (Econst_int (Int.repr 0) tint)))
      Sskip))
  (Sreturn (Some (Econst_int (Int.repr 1) tint))))
|}.

Definition f_envfx_update_jetstream := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_t'4, tfloat) :: (_t'3, tushort) ::
               (_t'2, tfloat) :: (_t'1, tint) :: (_t'46, tint) ::
               (_t'45, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'44, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'43, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'42, tint) ::
               (_t'41, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'40, tfloat) :: (_t'39, tint) ::
               (_t'38, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'37, tshort) ::
               (_t'36, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'35, tint) ::
               (_t'34, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'33, tfloat) :: (_t'32, tint) ::
               (_t'31, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'30, tshort) ::
               (_t'29, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'28, tshort) ::
               (_t'27, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'26, tint) ::
               (_t'25, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'24, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'23, tfloat) :: (_t'22, tint) ::
               (_t'21, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'20, tint) ::
               (_t'19, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'18, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'17, tfloat) :: (_t'16, tint) ::
               (_t'15, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'14, tint) ::
               (_t'13, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'12, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'11, tint) ::
               (_t'10, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'9, tint) ::
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
        (Sset _t'46 (Evar _sBubbleParticleMaxCount tint))
        (Sifthenelse (Ebinop Olt (Etempvar _i tint) (Etempvar _t'46 tint)
                       tint)
          Sskip
          Sbreak))
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _envfx_is_jestream_bubble_alive (Tfunction (tint :: nil)
                                                    tint cc_default))
            ((Etempvar _i tint) :: nil))
          (Ssequence
            (Sset _t'45
              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
            (Sassign
              (Efield
                (Ederef
                  (Ebinop Oadd
                    (Etempvar _t'45 (tptr (Tstruct _EnvFxParticle noattr)))
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
                    (Sset _t'44
                      (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Etempvar _t'44 (tptr (Tstruct _EnvFxParticle noattr)))
                                (Etempvar _i tint)
                                (tptr (Tstruct _EnvFxParticle noattr)))
                              (Tstruct _EnvFxParticle noattr)) _angleAndDist
                            (tarray tint 2)) (Econst_int (Int.repr 1) tint)
                          (tptr tint)) tint)
                      (Ebinop Omul (Etempvar _t'2 tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1133903872)) tfloat)
                        tfloat))))
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'3)
                      (Evar _random_u16 (Tfunction nil tushort cc_default))
                      nil)
                    (Ssequence
                      (Sset _t'43
                        (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Ebinop Oadd
                                  (Etempvar _t'43 (tptr (Tstruct _EnvFxParticle noattr)))
                                  (Etempvar _i tint)
                                  (tptr (Tstruct _EnvFxParticle noattr)))
                                (Tstruct _EnvFxParticle noattr))
                              _angleAndDist (tarray tint 2))
                            (Econst_int (Int.repr 0) tint) (tptr tint)) tint)
                        (Etempvar _t'3 tushort))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'36
                        (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                      (Ssequence
                        (Sset _t'37
                          (Ederef
                            (Ebinop Oadd
                              (Evar _gEnvFxBubbleConfig (tarray tshort 10))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))
                            tshort))
                        (Ssequence
                          (Sset _t'38
                            (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                          (Ssequence
                            (Sset _t'39
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'38 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr))
                                    _angleAndDist (tarray tint 2))
                                  (Econst_int (Int.repr 0) tint) (tptr tint))
                                tint))
                            (Ssequence
                              (Sset _t'40
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _gSineTable (tarray tfloat 0))
                                    (Ebinop Oshr
                                      (Ecast (Etempvar _t'39 tint) tushort)
                                      (Econst_int (Int.repr 4) tint) tint)
                                    (tptr tfloat)) tfloat))
                              (Ssequence
                                (Sset _t'41
                                  (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                (Ssequence
                                  (Sset _t'42
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Ederef
                                            (Ebinop Oadd
                                              (Etempvar _t'41 (tptr (Tstruct _EnvFxParticle noattr)))
                                              (Etempvar _i tint)
                                              (tptr (Tstruct _EnvFxParticle noattr)))
                                            (Tstruct _EnvFxParticle noattr))
                                          _angleAndDist (tarray tint 2))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr tint)) tint))
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Etempvar _t'36 (tptr (Tstruct _EnvFxParticle noattr)))
                                          (Etempvar _i tint)
                                          (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Tstruct _EnvFxParticle noattr))
                                      _xPos tint)
                                    (Ebinop Oadd (Etempvar _t'37 tshort)
                                      (Ebinop Omul (Etempvar _t'40 tfloat)
                                        (Etempvar _t'42 tint) tfloat) tfloat)))))))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'29
                          (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                        (Ssequence
                          (Sset _t'30
                            (Ederef
                              (Ebinop Oadd
                                (Evar _gEnvFxBubbleConfig (tarray tshort 10))
                                (Econst_int (Int.repr 3) tint) (tptr tshort))
                              tshort))
                          (Ssequence
                            (Sset _t'31
                              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                            (Ssequence
                              (Sset _t'32
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Etempvar _t'31 (tptr (Tstruct _EnvFxParticle noattr)))
                                          (Etempvar _i tint)
                                          (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Tstruct _EnvFxParticle noattr))
                                      _angleAndDist (tarray tint 2))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr tint)) tint))
                              (Ssequence
                                (Sset _t'33
                                  (Ederef
                                    (Ebinop Oadd
                                      (Ebinop Oadd
                                        (Evar _gSineTable (tarray tfloat 0))
                                        (Econst_int (Int.repr 1024) tint)
                                        (tptr tfloat))
                                      (Ebinop Oshr
                                        (Ecast (Etempvar _t'32 tint) tushort)
                                        (Econst_int (Int.repr 4) tint) tint)
                                      (tptr tfloat)) tfloat))
                                (Ssequence
                                  (Sset _t'34
                                    (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                                  (Ssequence
                                    (Sset _t'35
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Ederef
                                              (Ebinop Oadd
                                                (Etempvar _t'34 (tptr (Tstruct _EnvFxParticle noattr)))
                                                (Etempvar _i tint)
                                                (tptr (Tstruct _EnvFxParticle noattr)))
                                              (Tstruct _EnvFxParticle noattr))
                                            _angleAndDist (tarray tint 2))
                                          (Econst_int (Int.repr 1) tint)
                                          (tptr tint)) tint))
                                    (Sassign
                                      (Efield
                                        (Ederef
                                          (Ebinop Oadd
                                            (Etempvar _t'29 (tptr (Tstruct _EnvFxParticle noattr)))
                                            (Etempvar _i tint)
                                            (tptr (Tstruct _EnvFxParticle noattr)))
                                          (Tstruct _EnvFxParticle noattr))
                                        _zPos tint)
                                      (Ebinop Oadd (Etempvar _t'30 tshort)
                                        (Ebinop Omul (Etempvar _t'33 tfloat)
                                          (Etempvar _t'35 tint) tfloat)
                                        tfloat)))))))))
                      (Ssequence
                        (Scall (Some _t'4)
                          (Evar _random_float (Tfunction nil tfloat
                                                cc_default)) nil)
                        (Ssequence
                          (Sset _t'27
                            (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                          (Ssequence
                            (Sset _t'28
                              (Ederef
                                (Ebinop Oadd
                                  (Evar _gEnvFxBubbleConfig (tarray tshort 10))
                                  (Econst_int (Int.repr 2) tint)
                                  (tptr tshort)) tshort))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Ebinop Oadd
                                    (Etempvar _t'27 (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Etempvar _i tint)
                                    (tptr (Tstruct _EnvFxParticle noattr)))
                                  (Tstruct _EnvFxParticle noattr)) _yPos
                                tint)
                              (Ebinop Oadd (Etempvar _t'28 tshort)
                                (Ebinop Osub
                                  (Ebinop Omul (Etempvar _t'4 tfloat)
                                    (Econst_single (Float32.of_bits (Int.repr 1137180672)) tfloat)
                                    tfloat)
                                  (Econst_single (Float32.of_bits (Int.repr 1128792064)) tfloat)
                                  tfloat) tfloat)))))))))
              (Ssequence
                (Ssequence
                  (Sset _t'24
                    (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                  (Ssequence
                    (Sset _t'25
                      (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                    (Ssequence
                      (Sset _t'26
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Ebinop Oadd
                                  (Etempvar _t'25 (tptr (Tstruct _EnvFxParticle noattr)))
                                  (Etempvar _i tint)
                                  (tptr (Tstruct _EnvFxParticle noattr)))
                                (Tstruct _EnvFxParticle noattr))
                              _angleAndDist (tarray tint 2))
                            (Econst_int (Int.repr 1) tint) (tptr tint)) tint))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Ebinop Oadd
                                  (Etempvar _t'24 (tptr (Tstruct _EnvFxParticle noattr)))
                                  (Etempvar _i tint)
                                  (tptr (Tstruct _EnvFxParticle noattr)))
                                (Tstruct _EnvFxParticle noattr))
                              _angleAndDist (tarray tint 2))
                            (Econst_int (Int.repr 1) tint) (tptr tint)) tint)
                        (Ebinop Oadd (Etempvar _t'26 tint)
                          (Econst_int (Int.repr 10) tint) tint)))))
                (Ssequence
                  (Ssequence
                    (Sset _t'18
                      (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                    (Ssequence
                      (Sset _t'19
                        (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                      (Ssequence
                        (Sset _t'20
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Etempvar _t'19 (tptr (Tstruct _EnvFxParticle noattr)))
                                (Etempvar _i tint)
                                (tptr (Tstruct _EnvFxParticle noattr)))
                              (Tstruct _EnvFxParticle noattr)) _xPos tint))
                        (Ssequence
                          (Sset _t'21
                            (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                          (Ssequence
                            (Sset _t'22
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'21 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr))
                                    _angleAndDist (tarray tint 2))
                                  (Econst_int (Int.repr 0) tint) (tptr tint))
                                tint))
                            (Ssequence
                              (Sset _t'23
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _gSineTable (tarray tfloat 0))
                                    (Ebinop Oshr
                                      (Ecast (Etempvar _t'22 tint) tushort)
                                      (Econst_int (Int.repr 4) tint) tint)
                                    (tptr tfloat)) tfloat))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'18 (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Etempvar _i tint)
                                      (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Tstruct _EnvFxParticle noattr)) _xPos
                                  tint)
                                (Ebinop Oadd (Etempvar _t'20 tint)
                                  (Ebinop Omul (Etempvar _t'23 tfloat)
                                    (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                                    tfloat) tfloat))))))))
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
                                (Tstruct _EnvFxParticle noattr)) _zPos tint))
                          (Ssequence
                            (Sset _t'15
                              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                            (Ssequence
                              (Sset _t'16
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Etempvar _t'15 (tptr (Tstruct _EnvFxParticle noattr)))
                                          (Etempvar _i tint)
                                          (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Tstruct _EnvFxParticle noattr))
                                      _angleAndDist (tarray tint 2))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr tint)) tint))
                              (Ssequence
                                (Sset _t'17
                                  (Ederef
                                    (Ebinop Oadd
                                      (Ebinop Oadd
                                        (Evar _gSineTable (tarray tfloat 0))
                                        (Econst_int (Int.repr 1024) tint)
                                        (tptr tfloat))
                                      (Ebinop Oshr
                                        (Ecast (Etempvar _t'16 tint) tushort)
                                        (Econst_int (Int.repr 4) tint) tint)
                                      (tptr tfloat)) tfloat))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _t'12 (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Etempvar _i tint)
                                        (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Tstruct _EnvFxParticle noattr)) _zPos
                                    tint)
                                  (Ebinop Oadd (Etempvar _t'14 tint)
                                    (Ebinop Omul (Etempvar _t'17 tfloat)
                                      (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                                      tfloat) tfloat))))))))
                    (Ssequence
                      (Sset _t'7
                        (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                      (Ssequence
                        (Sset _t'8
                          (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                        (Ssequence
                          (Sset _t'9
                            (Efield
                              (Ederef
                                (Ebinop Oadd
                                  (Etempvar _t'8 (tptr (Tstruct _EnvFxParticle noattr)))
                                  (Etempvar _i tint)
                                  (tptr (Tstruct _EnvFxParticle noattr)))
                                (Tstruct _EnvFxParticle noattr)) _yPos tint))
                          (Ssequence
                            (Sset _t'10
                              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                            (Ssequence
                              (Sset _t'11
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Etempvar _t'10 (tptr (Tstruct _EnvFxParticle noattr)))
                                          (Etempvar _i tint)
                                          (tptr (Tstruct _EnvFxParticle noattr)))
                                        (Tstruct _EnvFxParticle noattr))
                                      _angleAndDist (tarray tint 2))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr tint)) tint))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _t'7 (tptr (Tstruct _EnvFxParticle noattr)))
                                      (Etempvar _i tint)
                                      (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Tstruct _EnvFxParticle noattr)) _yPos
                                  tint)
                                (Ebinop Osub (Etempvar _t'9 tint)
                                  (Ebinop Osub
                                    (Ebinop Odiv (Etempvar _t'11 tint)
                                      (Econst_int (Int.repr 30) tint) tint)
                                    (Econst_int (Int.repr 50) tint) tint)
                                  tint)))))))))))))))
    (Sset _i
      (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint) tint))))
|}.

Definition f_envfx_init_bubble := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_mode, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_t'2, tfloat) :: (_t'1, (tptr tvoid)) ::
               (_t'9, tint) :: (_t'8, (tptr (Tstruct _MemoryPool noattr))) ::
               (_t'7, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'6, tint) ::
               (_t'5, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'4, tint) ::
               (_t'3, (tptr (Tstruct _EnvFxParticle noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sswitch (Etempvar _mode tint)
    (LScons (Some 0)
      (Sreturn (Some (Econst_int (Int.repr 0) tint)))
      (LScons (Some 11)
        (Ssequence
          (Sassign (Evar _sBubbleParticleCount tint)
            (Econst_int (Int.repr 30) tint))
          (Ssequence
            (Sassign (Evar _sBubbleParticleMaxCount tint)
              (Econst_int (Int.repr 30) tint))
            Sbreak))
        (LScons (Some 12)
          (Ssequence
            (Sassign (Evar _sBubbleParticleCount tint)
              (Econst_int (Int.repr 15) tint))
            (Ssequence
              (Sassign (Evar _sBubbleParticleMaxCount tint)
                (Econst_int (Int.repr 15) tint))
              Sbreak))
          (LScons (Some 13)
            (Ssequence
              (Sassign (Evar _sBubbleParticleCount tint)
                (Econst_int (Int.repr 60) tint))
              Sbreak)
            (LScons (Some 14)
              (Ssequence
                (Sassign (Evar _sBubbleParticleCount tint)
                  (Econst_int (Int.repr 60) tint))
                Sbreak)
              LSnil))))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'8
          (Evar _gEffectsMemoryPool (tptr (Tstruct _MemoryPool noattr))))
        (Ssequence
          (Sset _t'9 (Evar _sBubbleParticleCount tint))
          (Scall (Some _t'1)
            (Evar _mem_pool_alloc (Tfunction
                                    ((tptr (Tstruct _MemoryPool noattr)) ::
                                     tuint :: nil) (tptr tvoid) cc_default))
            ((Etempvar _t'8 (tptr (Tstruct _MemoryPool noattr))) ::
             (Ebinop Omul (Etempvar _t'9 tint)
               (Esizeof (Tstruct _EnvFxParticle noattr) tuint) tuint) :: nil))))
      (Sassign (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr)))
        (Etempvar _t'1 (tptr tvoid))))
    (Ssequence
      (Ssequence
        (Sset _t'7
          (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
        (Sifthenelse (Ebinop Oeq
                       (Etempvar _t'7 (tptr (Tstruct _EnvFxParticle noattr)))
                       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                       tint)
          (Sreturn (Some (Econst_int (Int.repr 0) tint)))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'5
            (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
          (Ssequence
            (Sset _t'6 (Evar _sBubbleParticleCount tint))
            (Scall None
              (Evar _bzero (Tfunction ((tptr tvoid) :: tuint :: nil) tvoid
                             cc_default))
              ((Etempvar _t'5 (tptr (Tstruct _EnvFxParticle noattr))) ::
               (Ebinop Omul (Etempvar _t'6 tint)
                 (Esizeof (Tstruct _EnvFxParticle noattr) tuint) tuint) ::
               nil))))
        (Ssequence
          (Scall None
            (Evar _bzero (Tfunction ((tptr tvoid) :: tuint :: nil) tvoid
                           cc_default))
            ((Evar _gEnvFxBubbleConfig (tarray tshort 10)) ::
             (Esizeof (tarray tshort 10) tuint) :: nil))
          (Ssequence
            (Sswitch (Etempvar _mode tint)
              (LScons (Some 12)
                (Ssequence
                  (Ssequence
                    (Sset _i (Econst_int (Int.repr 0) tint))
                    (Sloop
                      (Ssequence
                        (Ssequence
                          (Sset _t'4 (Evar _sBubbleParticleCount tint))
                          (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                                         (Etempvar _t'4 tint) tint)
                            Sskip
                            Sbreak))
                        (Ssequence
                          (Scall (Some _t'2)
                            (Evar _random_float (Tfunction nil tfloat
                                                  cc_default)) nil)
                          (Ssequence
                            (Sset _t'3
                              (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Ebinop Oadd
                                    (Etempvar _t'3 (tptr (Tstruct _EnvFxParticle noattr)))
                                    (Etempvar _i tint)
                                    (tptr (Tstruct _EnvFxParticle noattr)))
                                  (Tstruct _EnvFxParticle noattr)) _animFrame
                                tshort)
                              (Ebinop Omul (Etempvar _t'2 tfloat)
                                (Econst_single (Float32.of_bits (Int.repr 1088421888)) tfloat)
                                tfloat)))))
                      (Sset _i
                        (Ebinop Oadd (Etempvar _i tint)
                          (Econst_int (Int.repr 1) tint) tint))))
                  Sbreak)
                LSnil))
            (Ssequence
              (Sassign (Evar _gEnvFxMode tschar) (Etempvar _mode tint))
              (Sreturn (Some (Econst_int (Int.repr 1) tint))))))))))
|}.

Definition f_envfx_bubbles_update_switch := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_mode, tint) :: (_camTo, (tptr tshort)) ::
                (_vertex1, (tptr tshort)) :: (_vertex2, (tptr tshort)) ::
                (_vertex3, (tptr tshort)) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Sswitch (Etempvar _mode tint)
  (LScons (Some 11)
    (Ssequence
      (Scall None
        (Evar _envfx_update_flower (Tfunction ((tptr tshort) :: nil) tvoid
                                     cc_default))
        ((Etempvar _camTo (tptr tshort)) :: nil))
      (Ssequence
        (Sassign
          (Ederef
            (Ebinop Oadd (Etempvar _vertex1 (tptr tshort))
              (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort)
          (Econst_int (Int.repr 50) tint))
        (Ssequence
          (Sassign
            (Ederef
              (Ebinop Oadd (Etempvar _vertex1 (tptr tshort))
                (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort)
            (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Sassign
              (Ederef
                (Ebinop Oadd (Etempvar _vertex1 (tptr tshort))
                  (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort)
              (Econst_int (Int.repr 0) tint))
            (Ssequence
              (Sassign
                (Ederef
                  (Ebinop Oadd (Etempvar _vertex2 (tptr tshort))
                    (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort)
                (Econst_int (Int.repr 0) tint))
              (Ssequence
                (Sassign
                  (Ederef
                    (Ebinop Oadd (Etempvar _vertex2 (tptr tshort))
                      (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort)
                  (Econst_int (Int.repr 75) tint))
                (Ssequence
                  (Sassign
                    (Ederef
                      (Ebinop Oadd (Etempvar _vertex2 (tptr tshort))
                        (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort)
                    (Econst_int (Int.repr 0) tint))
                  (Ssequence
                    (Sassign
                      (Ederef
                        (Ebinop Oadd (Etempvar _vertex3 (tptr tshort))
                          (Econst_int (Int.repr 0) tint) (tptr tshort))
                        tshort)
                      (Eunop Oneg (Econst_int (Int.repr 50) tint) tint))
                    (Ssequence
                      (Sassign
                        (Ederef
                          (Ebinop Oadd (Etempvar _vertex3 (tptr tshort))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))
                          tshort) (Econst_int (Int.repr 0) tint))
                      (Ssequence
                        (Sassign
                          (Ederef
                            (Ebinop Oadd (Etempvar _vertex3 (tptr tshort))
                              (Econst_int (Int.repr 2) tint) (tptr tshort))
                            tshort) (Econst_int (Int.repr 0) tint))
                        Sbreak))))))))))
    (LScons (Some 12)
      (Ssequence
        (Scall None
          (Evar _envfx_update_lava (Tfunction ((tptr tshort) :: nil) tvoid
                                     cc_default))
          ((Etempvar _camTo (tptr tshort)) :: nil))
        (Ssequence
          (Sassign
            (Ederef
              (Ebinop Oadd (Etempvar _vertex1 (tptr tshort))
                (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort)
            (Econst_int (Int.repr 100) tint))
          (Ssequence
            (Sassign
              (Ederef
                (Ebinop Oadd (Etempvar _vertex1 (tptr tshort))
                  (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort)
              (Econst_int (Int.repr 0) tint))
            (Ssequence
              (Sassign
                (Ederef
                  (Ebinop Oadd (Etempvar _vertex1 (tptr tshort))
                    (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort)
                (Econst_int (Int.repr 0) tint))
              (Ssequence
                (Sassign
                  (Ederef
                    (Ebinop Oadd (Etempvar _vertex2 (tptr tshort))
                      (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort)
                  (Econst_int (Int.repr 0) tint))
                (Ssequence
                  (Sassign
                    (Ederef
                      (Ebinop Oadd (Etempvar _vertex2 (tptr tshort))
                        (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort)
                    (Econst_int (Int.repr 150) tint))
                  (Ssequence
                    (Sassign
                      (Ederef
                        (Ebinop Oadd (Etempvar _vertex2 (tptr tshort))
                          (Econst_int (Int.repr 2) tint) (tptr tshort))
                        tshort) (Econst_int (Int.repr 0) tint))
                    (Ssequence
                      (Sassign
                        (Ederef
                          (Ebinop Oadd (Etempvar _vertex3 (tptr tshort))
                            (Econst_int (Int.repr 0) tint) (tptr tshort))
                          tshort)
                        (Eunop Oneg (Econst_int (Int.repr 100) tint) tint))
                      (Ssequence
                        (Sassign
                          (Ederef
                            (Ebinop Oadd (Etempvar _vertex3 (tptr tshort))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))
                            tshort) (Econst_int (Int.repr 0) tint))
                        (Ssequence
                          (Sassign
                            (Ederef
                              (Ebinop Oadd (Etempvar _vertex3 (tptr tshort))
                                (Econst_int (Int.repr 2) tint) (tptr tshort))
                              tshort) (Econst_int (Int.repr 0) tint))
                          Sbreak))))))))))
      (LScons (Some 13)
        (Ssequence
          (Scall None
            (Evar _envfx_update_whirlpool (Tfunction nil tvoid cc_default))
            nil)
          (Ssequence
            (Sassign
              (Ederef
                (Ebinop Oadd (Etempvar _vertex1 (tptr tshort))
                  (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort)
              (Econst_int (Int.repr 40) tint))
            (Ssequence
              (Sassign
                (Ederef
                  (Ebinop Oadd (Etempvar _vertex1 (tptr tshort))
                    (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort)
                (Econst_int (Int.repr 0) tint))
              (Ssequence
                (Sassign
                  (Ederef
                    (Ebinop Oadd (Etempvar _vertex1 (tptr tshort))
                      (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort)
                  (Econst_int (Int.repr 0) tint))
                (Ssequence
                  (Sassign
                    (Ederef
                      (Ebinop Oadd (Etempvar _vertex2 (tptr tshort))
                        (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort)
                    (Econst_int (Int.repr 0) tint))
                  (Ssequence
                    (Sassign
                      (Ederef
                        (Ebinop Oadd (Etempvar _vertex2 (tptr tshort))
                          (Econst_int (Int.repr 1) tint) (tptr tshort))
                        tshort) (Econst_int (Int.repr 60) tint))
                    (Ssequence
                      (Sassign
                        (Ederef
                          (Ebinop Oadd (Etempvar _vertex2 (tptr tshort))
                            (Econst_int (Int.repr 2) tint) (tptr tshort))
                          tshort) (Econst_int (Int.repr 0) tint))
                      (Ssequence
                        (Sassign
                          (Ederef
                            (Ebinop Oadd (Etempvar _vertex3 (tptr tshort))
                              (Econst_int (Int.repr 0) tint) (tptr tshort))
                            tshort)
                          (Eunop Oneg (Econst_int (Int.repr 40) tint) tint))
                        (Ssequence
                          (Sassign
                            (Ederef
                              (Ebinop Oadd (Etempvar _vertex3 (tptr tshort))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))
                              tshort) (Econst_int (Int.repr 0) tint))
                          (Ssequence
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Etempvar _vertex3 (tptr tshort))
                                  (Econst_int (Int.repr 2) tint)
                                  (tptr tshort)) tshort)
                              (Econst_int (Int.repr 0) tint))
                            Sbreak))))))))))
        (LScons (Some 14)
          (Ssequence
            (Scall None
              (Evar _envfx_update_jetstream (Tfunction nil tvoid cc_default))
              nil)
            (Ssequence
              (Sassign
                (Ederef
                  (Ebinop Oadd (Etempvar _vertex1 (tptr tshort))
                    (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort)
                (Econst_int (Int.repr 40) tint))
              (Ssequence
                (Sassign
                  (Ederef
                    (Ebinop Oadd (Etempvar _vertex1 (tptr tshort))
                      (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort)
                  (Econst_int (Int.repr 0) tint))
                (Ssequence
                  (Sassign
                    (Ederef
                      (Ebinop Oadd (Etempvar _vertex1 (tptr tshort))
                        (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort)
                    (Econst_int (Int.repr 0) tint))
                  (Ssequence
                    (Sassign
                      (Ederef
                        (Ebinop Oadd (Etempvar _vertex2 (tptr tshort))
                          (Econst_int (Int.repr 0) tint) (tptr tshort))
                        tshort) (Econst_int (Int.repr 0) tint))
                    (Ssequence
                      (Sassign
                        (Ederef
                          (Ebinop Oadd (Etempvar _vertex2 (tptr tshort))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))
                          tshort) (Econst_int (Int.repr 60) tint))
                      (Ssequence
                        (Sassign
                          (Ederef
                            (Ebinop Oadd (Etempvar _vertex2 (tptr tshort))
                              (Econst_int (Int.repr 2) tint) (tptr tshort))
                            tshort) (Econst_int (Int.repr 0) tint))
                        (Ssequence
                          (Sassign
                            (Ederef
                              (Ebinop Oadd (Etempvar _vertex3 (tptr tshort))
                                (Econst_int (Int.repr 0) tint) (tptr tshort))
                              tshort)
                            (Eunop Oneg (Econst_int (Int.repr 40) tint) tint))
                          (Ssequence
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Etempvar _vertex3 (tptr tshort))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tshort)) tshort)
                              (Econst_int (Int.repr 0) tint))
                            (Ssequence
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd
                                    (Etempvar _vertex3 (tptr tshort))
                                    (Econst_int (Int.repr 2) tint)
                                    (tptr tshort)) tshort)
                                (Econst_int (Int.repr 0) tint))
                              Sbreak))))))))))
          LSnil)))))
|}.

Definition f_append_bubble_vertex_buffer := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_gfx, (tptr (Tunion __549 noattr))) :: (_index, tint) ::
                (_vertex1, (tptr tshort)) :: (_vertex2, (tptr tshort)) ::
                (_vertex3, (tptr tshort)) ::
                (_template, (tptr (Tunion __463 noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_vertBuf, (tptr (Tunion __463 noattr))) ::
               (__g, (tptr (Tunion __549 noattr))) :: (_t'1, (tptr tvoid)) ::
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
      (Sset _vertBuf (Etempvar _t'1 (tptr tvoid))))
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
                      (Etempvar _template (tptr (Tunion __463 noattr)))
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
                              (Etempvar _template (tptr (Tunion __463 noattr)))
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
                                      (Etempvar _template (tptr (Tunion __463 noattr)))
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
            (Ecast (Etempvar _gfx (tptr (Tunion __549 noattr)))
              (tptr (Tunion __549 noattr))))
          (Ssequence
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
                tuint)
              (Ebinop Oor
                (Ebinop Oor
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 1) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 8) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 24) tint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 15) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 8) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 12) tint) tuint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast
                        (Ebinop Oadd (Econst_int (Int.repr 0) tint)
                          (Econst_int (Int.repr 15) tint) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 7) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 1) tint) tuint) tuint) tuint))
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
                tuint)
              (Ecast
                (Ebinop Oand
                  (Ecast (Etempvar _vertBuf (tptr (Tunion __463 noattr)))
                    tuint) (Econst_int (Int.repr 536870911) tint) tuint)
                tuint))))))))
|}.

Definition f_envfx_set_bubble_texture := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_mode, tint) :: (_index, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_imageArr, (tptr (tptr tvoid))) :: (_frame, tshort) ::
               (__g, (tptr (Tunion __549 noattr))) ::
               (__g__1, (tptr (Tunion __549 noattr))) ::
               (_t'5, (tptr (Tunion __549 noattr))) ::
               (_t'4, (tptr (Tunion __549 noattr))) ::
               (_t'3, (tptr tvoid)) :: (_t'2, (tptr tvoid)) ::
               (_t'1, (tptr tvoid)) :: (_t'12, tshort) ::
               (_t'11, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'10, tshort) ::
               (_t'9, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'8, tshort) ::
               (_t'7, (tptr (Tstruct _EnvFxParticle noattr))) ::
               (_t'6, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'11 (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
    (Ssequence
      (Sset _t'12
        (Efield
          (Ederef
            (Ebinop Oadd
              (Etempvar _t'11 (tptr (Tstruct _EnvFxParticle noattr)))
              (Etempvar _index tshort)
              (tptr (Tstruct _EnvFxParticle noattr)))
            (Tstruct _EnvFxParticle noattr)) _animFrame tshort))
      (Sset _frame (Ecast (Etempvar _t'12 tshort) tshort))))
  (Ssequence
    (Sswitch (Etempvar _mode tint)
      (LScons (Some 11)
        (Ssequence
          (Ssequence
            (Scall (Some _t'1)
              (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                            (tptr tvoid) cc_default))
              ((Eaddrof
                 (Evar _flower_bubbles_textures_ptr_0B002008 (tarray (tptr tuchar) 0))
                 (tptr (tarray (tptr tuchar) 0))) :: nil))
            (Sset _imageArr (Etempvar _t'1 (tptr tvoid))))
          (Ssequence
            (Ssequence
              (Sset _t'9
                (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
              (Ssequence
                (Sset _t'10
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Etempvar _t'9 (tptr (Tstruct _EnvFxParticle noattr)))
                        (Etempvar _index tshort)
                        (tptr (Tstruct _EnvFxParticle noattr)))
                      (Tstruct _EnvFxParticle noattr)) _animFrame tshort))
                (Sset _frame (Ecast (Etempvar _t'10 tshort) tshort))))
            Sbreak))
        (LScons (Some 12)
          (Ssequence
            (Ssequence
              (Scall (Some _t'2)
                (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                              (tptr tvoid) cc_default))
                ((Eaddrof
                   (Evar _lava_bubble_ptr_0B006020 (tarray (tptr tuchar) 0))
                   (tptr (tarray (tptr tuchar) 0))) :: nil))
              (Sset _imageArr (Etempvar _t'2 (tptr tvoid))))
            (Ssequence
              (Ssequence
                (Sset _t'7
                  (Evar _gEnvFxBuffer (tptr (Tstruct _EnvFxParticle noattr))))
                (Ssequence
                  (Sset _t'8
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Etempvar _t'7 (tptr (Tstruct _EnvFxParticle noattr)))
                          (Etempvar _index tshort)
                          (tptr (Tstruct _EnvFxParticle noattr)))
                        (Tstruct _EnvFxParticle noattr)) _animFrame tshort))
                  (Sset _frame (Ecast (Etempvar _t'8 tshort) tshort))))
              Sbreak))
          (LScons (Some 13)
            Sskip
            (LScons (Some 14)
              (Ssequence
                (Ssequence
                  (Scall (Some _t'3)
                    (Evar _segmented_to_virtual (Tfunction
                                                  ((tptr tvoid) :: nil)
                                                  (tptr tvoid) cc_default))
                    ((Eaddrof
                       (Evar _bubble_ptr_0B006848 (tarray (tptr tuchar) 0))
                       (tptr (tarray (tptr tuchar) 0))) :: nil))
                  (Sset _imageArr (Etempvar _t'3 (tptr tvoid))))
                (Ssequence
                  (Sset _frame (Ecast (Econst_int (Int.repr 0) tint) tshort))
                  Sbreak))
              LSnil)))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'4 (Evar _sGfxCursor (tptr (Tunion __549 noattr))))
            (Sassign (Evar _sGfxCursor (tptr (Tunion __549 noattr)))
              (Ebinop Oadd (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
          (Sset __g
            (Ecast (Etempvar _t'4 (tptr (Tunion __549 noattr)))
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
            (Sset _t'6
              (Ederef
                (Ebinop Oadd (Etempvar _imageArr (tptr (tptr tvoid)))
                  (Etempvar _frame tshort) (tptr (tptr tvoid))) (tptr tvoid)))
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
                tuint) (Ecast (Etempvar _t'6 (tptr tvoid)) tuint)))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'5 (Evar _sGfxCursor (tptr (Tunion __549 noattr))))
            (Sassign (Evar _sGfxCursor (tptr (Tunion __549 noattr)))
              (Ebinop Oadd (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
          (Sset __g__1
            (Ecast (Etempvar _t'5 (tptr (Tunion __549 noattr)))
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
                (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                  (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
              tuint)
            (Ecast
              (Eaddrof
                (Evar _tiny_bubble_dl_0B006D68 (tarray (Tunion __549 noattr) 0))
                (tptr (tarray (Tunion __549 noattr) 0))) tuint)))))))
|}.

Definition f_envfx_update_bubble_particles := {|
  fn_return := (tptr (Tunion __549 noattr));
  fn_callconv := cc_default;
  fn_params := ((_mode, tint) :: (_marioPos, (tptr tshort)) ::
                (_camFrom, (tptr tshort)) :: (_camTo, (tptr tshort)) :: nil);
  fn_vars := ((_radius, tshort) :: (_pitch, tshort) :: (_yaw, tshort) ::
              (_vertex1, (tarray tshort 3)) ::
              (_vertex2, (tarray tshort 3)) ::
              (_vertex3, (tarray tshort 3)) :: nil);
  fn_temps := ((_i, tint) :: (_gfxStart, (tptr (Tunion __549 noattr))) ::
               (__g, (tptr (Tunion __549 noattr))) ::
               (__g__1, (tptr (Tunion __549 noattr))) ::
               (__g__2, (tptr (Tunion __549 noattr))) ::
               (__g__3, (tptr (Tunion __549 noattr))) ::
               (__g__4, (tptr (Tunion __549 noattr))) ::
               (__g__5, (tptr (Tunion __549 noattr))) ::
               (__g__6, (tptr (Tunion __549 noattr))) ::
               (__g__7, (tptr (Tunion __549 noattr))) ::
               (__g__8, (tptr (Tunion __549 noattr))) ::
               (_t'16, (tptr (Tunion __549 noattr))) ::
               (_t'15, (tptr (Tunion __549 noattr))) :: (_t'14, tuint) ::
               (_t'13, (tptr (Tunion __549 noattr))) :: (_t'12, tuint) ::
               (_t'11, (tptr (Tunion __549 noattr))) :: (_t'10, tuint) ::
               (_t'9, (tptr (Tunion __549 noattr))) :: (_t'8, tuint) ::
               (_t'7, (tptr (Tunion __549 noattr))) :: (_t'6, tuint) ::
               (_t'5, (tptr (Tunion __549 noattr))) ::
               (_t'4, (tptr (Tunion __549 noattr))) ::
               (_t'3, (tptr (Tunion __549 noattr))) ::
               (_t'2, (tptr (Tunion __549 noattr))) ::
               (_t'1, (tptr tvoid)) :: (_t'21, tint) :: (_t'20, tint) ::
               (_t'19, tshort) :: (_t'18, tshort) :: (_t'17, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'20 (Evar _sBubbleParticleMaxCount tint))
      (Ssequence
        (Sset _t'21 (Evar _sBubbleParticleMaxCount tint))
        (Scall (Some _t'1)
          (Evar _alloc_display_list (Tfunction (tuint :: nil) (tptr tvoid)
                                      cc_default))
          ((Ebinop Omul
             (Ebinop Oadd
               (Ebinop Oadd
                 (Ebinop Omul
                   (Ebinop Odiv (Etempvar _t'20 tint)
                     (Econst_int (Int.repr 5) tint) tint)
                   (Econst_int (Int.repr 10) tint) tint)
                 (Etempvar _t'21 tint) tint) (Econst_int (Int.repr 3) tint)
               tint) (Esizeof (Tunion __549 noattr) tuint) tuint) :: nil))))
    (Sset _gfxStart (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Sifthenelse (Ebinop Oeq
                   (Etempvar _gfxStart (tptr (Tunion __549 noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
      Sskip)
    (Ssequence
      (Sassign (Evar _sGfxCursor (tptr (Tunion __549 noattr)))
        (Etempvar _gfxStart (tptr (Tunion __549 noattr))))
      (Ssequence
        (Scall None
          (Evar _orbit_from_positions (Tfunction
                                        ((tptr tshort) :: (tptr tshort) ::
                                         (tptr tshort) :: (tptr tshort) ::
                                         (tptr tshort) :: nil) tvoid
                                        cc_default))
          ((Etempvar _camTo (tptr tshort)) ::
           (Etempvar _camFrom (tptr tshort)) ::
           (Eaddrof (Evar _radius tshort) (tptr tshort)) ::
           (Eaddrof (Evar _pitch tshort) (tptr tshort)) ::
           (Eaddrof (Evar _yaw tshort) (tptr tshort)) :: nil))
        (Ssequence
          (Scall None
            (Evar _envfx_bubbles_update_switch (Tfunction
                                                 (tint :: (tptr tshort) ::
                                                  (tptr tshort) ::
                                                  (tptr tshort) ::
                                                  (tptr tshort) :: nil) tvoid
                                                 cc_default))
            ((Etempvar _mode tint) :: (Etempvar _camTo (tptr tshort)) ::
             (Evar _vertex1 (tarray tshort 3)) ::
             (Evar _vertex2 (tarray tshort 3)) ::
             (Evar _vertex3 (tarray tshort 3)) :: nil))
          (Ssequence
            (Ssequence
              (Sset _t'18 (Evar _pitch tshort))
              (Ssequence
                (Sset _t'19 (Evar _yaw tshort))
                (Scall None
                  (Evar _rotate_triangle_vertices (Tfunction
                                                    ((tptr tshort) ::
                                                     (tptr tshort) ::
                                                     (tptr tshort) ::
                                                     tshort :: tshort :: nil)
                                                    tvoid cc_default))
                  ((Evar _vertex1 (tarray tshort 3)) ::
                   (Evar _vertex2 (tarray tshort 3)) ::
                   (Evar _vertex3 (tarray tshort 3)) ::
                   (Etempvar _t'18 tshort) :: (Etempvar _t'19 tshort) :: nil))))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'2
                      (Evar _sGfxCursor (tptr (Tunion __549 noattr))))
                    (Sassign (Evar _sGfxCursor (tptr (Tunion __549 noattr)))
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
                        (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
                          (Tunion __549 noattr)) _words
                        (Tstruct __547 noattr)) _w0 tuint)
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
                          (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
                          (Tunion __549 noattr)) _words
                        (Tstruct __547 noattr)) _w1 tuint)
                    (Ecast
                      (Eaddrof
                        (Evar _tiny_bubble_dl_0B006D38 (tarray (Tunion __549 noattr) 0))
                        (tptr (tarray (Tunion __549 noattr) 0))) tuint))))
              (Ssequence
                (Ssequence
                  (Sset _i (Econst_int (Int.repr 0) tint))
                  (Sloop
                    (Ssequence
                      (Ssequence
                        (Sset _t'17 (Evar _sBubbleParticleMaxCount tint))
                        (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                                       (Etempvar _t'17 tint) tint)
                          Sskip
                          Sbreak))
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Sset _t'3
                                (Evar _sGfxCursor (tptr (Tunion __549 noattr))))
                              (Sassign
                                (Evar _sGfxCursor (tptr (Tunion __549 noattr)))
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
                              (Ecast
                                (Ebinop Oshl
                                  (Ebinop Oand
                                    (Ecast (Econst_int (Int.repr 231) tint)
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
                                    (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                                    (Tunion __549 noattr)) _words
                                  (Tstruct __547 noattr)) _w1 tuint)
                              (Econst_int (Int.repr 0) tint))))
                        (Ssequence
                          (Scall None
                            (Evar _envfx_set_bubble_texture (Tfunction
                                                              (tint ::
                                                               tshort :: nil)
                                                              tvoid
                                                              cc_default))
                            ((Etempvar _mode tint) :: (Etempvar _i tint) ::
                             nil))
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Sset _t'4
                                  (Evar _sGfxCursor (tptr (Tunion __549 noattr))))
                                (Sassign
                                  (Evar _sGfxCursor (tptr (Tunion __549 noattr)))
                                  (Ebinop Oadd
                                    (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr (Tunion __549 noattr)))))
                              (Scall None
                                (Evar _append_bubble_vertex_buffer (Tfunction
                                                                    ((tptr (Tunion __549 noattr)) ::
                                                                    tint ::
                                                                    (tptr tshort) ::
                                                                    (tptr tshort) ::
                                                                    (tptr tshort) ::
                                                                    (tptr (Tunion __463 noattr)) ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                ((Etempvar _t'4 (tptr (Tunion __549 noattr))) ::
                                 (Etempvar _i tint) ::
                                 (Evar _vertex1 (tarray tshort 3)) ::
                                 (Evar _vertex2 (tarray tshort 3)) ::
                                 (Evar _vertex3 (tarray tshort 3)) ::
                                 (Ecast
                                   (Evar _gBubbleTempVtx (tarray (Tstruct __459 noattr) 3))
                                   (tptr (Tunion __463 noattr))) :: nil)))
                            (Ssequence
                              (Ssequence
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'5
                                      (Evar _sGfxCursor (tptr (Tunion __549 noattr))))
                                    (Sassign
                                      (Evar _sGfxCursor (tptr (Tunion __549 noattr)))
                                      (Ebinop Oadd
                                        (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr (Tunion __549 noattr)))))
                                  (Sset __g__2
                                    (Ecast
                                      (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                                      (tptr (Tunion __549 noattr)))))
                                (Ssequence
                                  (Ssequence
                                    (Sifthenelse (Ebinop Oeq
                                                   (Econst_int (Int.repr 0) tint)
                                                   (Econst_int (Int.repr 0) tint)
                                                   tint)
                                      (Sset _t'6
                                        (Ecast
                                          (Ebinop Oor
                                            (Ebinop Oor
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
                                                      (Econst_int (Int.repr 1) tint)
                                                      tint) tuint)
                                                  (Econst_int (Int.repr 16) tint)
                                                  tuint) tuint)
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
                                                      (Econst_int (Int.repr 2) tint)
                                                      tint) tuint)
                                                  (Ebinop Osub
                                                    (Ebinop Oshl
                                                      (Econst_int (Int.repr 1) tint)
                                                      (Econst_int (Int.repr 8) tint)
                                                      tint)
                                                    (Econst_int (Int.repr 1) tint)
                                                    tint) tuint)
                                                (Econst_int (Int.repr 0) tint)
                                                tuint) tuint) tuint) tuint))
                                      (Sifthenelse (Ebinop Oeq
                                                     (Econst_int (Int.repr 0) tint)
                                                     (Econst_int (Int.repr 1) tint)
                                                     tint)
                                        (Ssequence
                                          (Sset _t'6
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
                                                          (Econst_int (Int.repr 1) tint)
                                                          tint) tuint)
                                                      (Econst_int (Int.repr 16) tint)
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
                                                          (Econst_int (Int.repr 1) tint)
                                                          tint) tuint)
                                                      (Econst_int (Int.repr 8) tint)
                                                      tuint) tuint) tuint)
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
                                                        (Econst_int (Int.repr 1) tint)
                                                        tint) tuint)
                                                    (Econst_int (Int.repr 0) tint)
                                                    tuint) tuint) tuint)
                                              tuint))
                                          (Sset _t'6
                                            (Ecast (Etempvar _t'6 tuint)
                                              tuint)))
                                        (Ssequence
                                          (Sset _t'6
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
                                                          (Econst_int (Int.repr 1) tint)
                                                          tint) tuint)
                                                      (Econst_int (Int.repr 16) tint)
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
                                                          (Econst_int (Int.repr 1) tint)
                                                          tint) tuint)
                                                      (Econst_int (Int.repr 8) tint)
                                                      tuint) tuint) tuint)
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
                                                        (Econst_int (Int.repr 1) tint)
                                                        tint) tuint)
                                                    (Econst_int (Int.repr 0) tint)
                                                    tuint) tuint) tuint)
                                              tuint))
                                          (Sset _t'6
                                            (Ecast (Etempvar _t'6 tuint)
                                              tuint)))))
                                    (Sassign
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                                            (Tunion __549 noattr)) _words
                                          (Tstruct __547 noattr)) _w0 tuint)
                                      (Ebinop Oor
                                        (Ecast
                                          (Ebinop Oshl
                                            (Ebinop Oand
                                              (Ecast
                                                (Econst_int (Int.repr 5) tint)
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
                                        (Etempvar _t'6 tuint) tuint)))
                                  (Sassign
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                                          (Tunion __549 noattr)) _words
                                        (Tstruct __547 noattr)) _w1 tuint)
                                    (Econst_int (Int.repr 0) tint))))
                              (Ssequence
                                (Ssequence
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'7
                                        (Evar _sGfxCursor (tptr (Tunion __549 noattr))))
                                      (Sassign
                                        (Evar _sGfxCursor (tptr (Tunion __549 noattr)))
                                        (Ebinop Oadd
                                          (Etempvar _t'7 (tptr (Tunion __549 noattr)))
                                          (Econst_int (Int.repr 1) tint)
                                          (tptr (Tunion __549 noattr)))))
                                    (Sset __g__3
                                      (Ecast
                                        (Etempvar _t'7 (tptr (Tunion __549 noattr)))
                                        (tptr (Tunion __549 noattr)))))
                                  (Ssequence
                                    (Ssequence
                                      (Sifthenelse (Ebinop Oeq
                                                     (Econst_int (Int.repr 0) tint)
                                                     (Econst_int (Int.repr 0) tint)
                                                     tint)
                                        (Sset _t'8
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
                                                        (Econst_int (Int.repr 1) tint)
                                                        tint) tuint)
                                                    (Econst_int (Int.repr 16) tint)
                                                    tuint) tuint)
                                                (Ecast
                                                  (Ebinop Oshl
                                                    (Ebinop Oand
                                                      (Ecast
                                                        (Ebinop Omul
                                                          (Econst_int (Int.repr 4) tint)
                                                          (Econst_int (Int.repr 2) tint)
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
                                                        (Econst_int (Int.repr 2) tint)
                                                        tint) tuint)
                                                    (Ebinop Osub
                                                      (Ebinop Oshl
                                                        (Econst_int (Int.repr 1) tint)
                                                        (Econst_int (Int.repr 8) tint)
                                                        tint)
                                                      (Econst_int (Int.repr 1) tint)
                                                      tint) tuint)
                                                  (Econst_int (Int.repr 0) tint)
                                                  tuint) tuint) tuint) tuint))
                                        (Sifthenelse (Ebinop Oeq
                                                       (Econst_int (Int.repr 0) tint)
                                                       (Econst_int (Int.repr 1) tint)
                                                       tint)
                                          (Ssequence
                                            (Sset _t'8
                                              (Ecast
                                                (Ebinop Oor
                                                  (Ebinop Oor
                                                    (Ecast
                                                      (Ebinop Oshl
                                                        (Ebinop Oand
                                                          (Ecast
                                                            (Ebinop Omul
                                                              (Econst_int (Int.repr 4) tint)
                                                              (Econst_int (Int.repr 2) tint)
                                                              tint) tuint)
                                                          (Ebinop Osub
                                                            (Ebinop Oshl
                                                              (Econst_int (Int.repr 1) tint)
                                                              (Econst_int (Int.repr 8) tint)
                                                              tint)
                                                            (Econst_int (Int.repr 1) tint)
                                                            tint) tuint)
                                                        (Econst_int (Int.repr 16) tint)
                                                        tuint) tuint)
                                                    (Ecast
                                                      (Ebinop Oshl
                                                        (Ebinop Oand
                                                          (Ecast
                                                            (Ebinop Omul
                                                              (Econst_int (Int.repr 5) tint)
                                                              (Econst_int (Int.repr 2) tint)
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
                                                            (Econst_int (Int.repr 3) tint)
                                                            (Econst_int (Int.repr 2) tint)
                                                            tint) tuint)
                                                        (Ebinop Osub
                                                          (Ebinop Oshl
                                                            (Econst_int (Int.repr 1) tint)
                                                            (Econst_int (Int.repr 8) tint)
                                                            tint)
                                                          (Econst_int (Int.repr 1) tint)
                                                          tint) tuint)
                                                      (Econst_int (Int.repr 0) tint)
                                                      tuint) tuint) tuint)
                                                tuint))
                                            (Sset _t'8
                                              (Ecast (Etempvar _t'8 tuint)
                                                tuint)))
                                          (Ssequence
                                            (Sset _t'8
                                              (Ecast
                                                (Ebinop Oor
                                                  (Ebinop Oor
                                                    (Ecast
                                                      (Ebinop Oshl
                                                        (Ebinop Oand
                                                          (Ecast
                                                            (Ebinop Omul
                                                              (Econst_int (Int.repr 5) tint)
                                                              (Econst_int (Int.repr 2) tint)
                                                              tint) tuint)
                                                          (Ebinop Osub
                                                            (Ebinop Oshl
                                                              (Econst_int (Int.repr 1) tint)
                                                              (Econst_int (Int.repr 8) tint)
                                                              tint)
                                                            (Econst_int (Int.repr 1) tint)
                                                            tint) tuint)
                                                        (Econst_int (Int.repr 16) tint)
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
                                                            (Econst_int (Int.repr 1) tint)
                                                            tint) tuint)
                                                        (Econst_int (Int.repr 8) tint)
                                                        tuint) tuint) tuint)
                                                  (Ecast
                                                    (Ebinop Oshl
                                                      (Ebinop Oand
                                                        (Ecast
                                                          (Ebinop Omul
                                                            (Econst_int (Int.repr 4) tint)
                                                            (Econst_int (Int.repr 2) tint)
                                                            tint) tuint)
                                                        (Ebinop Osub
                                                          (Ebinop Oshl
                                                            (Econst_int (Int.repr 1) tint)
                                                            (Econst_int (Int.repr 8) tint)
                                                            tint)
                                                          (Econst_int (Int.repr 1) tint)
                                                          tint) tuint)
                                                      (Econst_int (Int.repr 0) tint)
                                                      tuint) tuint) tuint)
                                                tuint))
                                            (Sset _t'8
                                              (Ecast (Etempvar _t'8 tuint)
                                                tuint)))))
                                      (Sassign
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                                              (Tunion __549 noattr)) _words
                                            (Tstruct __547 noattr)) _w0
                                          tuint)
                                        (Ebinop Oor
                                          (Ecast
                                            (Ebinop Oshl
                                              (Ebinop Oand
                                                (Ecast
                                                  (Econst_int (Int.repr 5) tint)
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
                                          (Etempvar _t'8 tuint) tuint)))
                                    (Sassign
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                                            (Tunion __549 noattr)) _words
                                          (Tstruct __547 noattr)) _w1 tuint)
                                      (Econst_int (Int.repr 0) tint))))
                                (Ssequence
                                  (Ssequence
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'9
                                          (Evar _sGfxCursor (tptr (Tunion __549 noattr))))
                                        (Sassign
                                          (Evar _sGfxCursor (tptr (Tunion __549 noattr)))
                                          (Ebinop Oadd
                                            (Etempvar _t'9 (tptr (Tunion __549 noattr)))
                                            (Econst_int (Int.repr 1) tint)
                                            (tptr (Tunion __549 noattr)))))
                                      (Sset __g__4
                                        (Ecast
                                          (Etempvar _t'9 (tptr (Tunion __549 noattr)))
                                          (tptr (Tunion __549 noattr)))))
                                    (Ssequence
                                      (Ssequence
                                        (Sifthenelse (Ebinop Oeq
                                                       (Econst_int (Int.repr 0) tint)
                                                       (Econst_int (Int.repr 0) tint)
                                                       tint)
                                          (Sset _t'10
                                            (Ecast
                                              (Ebinop Oor
                                                (Ebinop Oor
                                                  (Ecast
                                                    (Ebinop Oshl
                                                      (Ebinop Oand
                                                        (Ecast
                                                          (Ebinop Omul
                                                            (Econst_int (Int.repr 6) tint)
                                                            (Econst_int (Int.repr 2) tint)
                                                            tint) tuint)
                                                        (Ebinop Osub
                                                          (Ebinop Oshl
                                                            (Econst_int (Int.repr 1) tint)
                                                            (Econst_int (Int.repr 8) tint)
                                                            tint)
                                                          (Econst_int (Int.repr 1) tint)
                                                          tint) tuint)
                                                      (Econst_int (Int.repr 16) tint)
                                                      tuint) tuint)
                                                  (Ecast
                                                    (Ebinop Oshl
                                                      (Ebinop Oand
                                                        (Ecast
                                                          (Ebinop Omul
                                                            (Econst_int (Int.repr 7) tint)
                                                            (Econst_int (Int.repr 2) tint)
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
                                                          (Econst_int (Int.repr 2) tint)
                                                          tint) tuint)
                                                      (Ebinop Osub
                                                        (Ebinop Oshl
                                                          (Econst_int (Int.repr 1) tint)
                                                          (Econst_int (Int.repr 8) tint)
                                                          tint)
                                                        (Econst_int (Int.repr 1) tint)
                                                        tint) tuint)
                                                    (Econst_int (Int.repr 0) tint)
                                                    tuint) tuint) tuint)
                                              tuint))
                                          (Sifthenelse (Ebinop Oeq
                                                         (Econst_int (Int.repr 0) tint)
                                                         (Econst_int (Int.repr 1) tint)
                                                         tint)
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
                                                                (Econst_int (Int.repr 7) tint)
                                                                (Econst_int (Int.repr 2) tint)
                                                                tint) tuint)
                                                            (Ebinop Osub
                                                              (Ebinop Oshl
                                                                (Econst_int (Int.repr 1) tint)
                                                                (Econst_int (Int.repr 8) tint)
                                                                tint)
                                                              (Econst_int (Int.repr 1) tint)
                                                              tint) tuint)
                                                          (Econst_int (Int.repr 16) tint)
                                                          tuint) tuint)
                                                      (Ecast
                                                        (Ebinop Oshl
                                                          (Ebinop Oand
                                                            (Ecast
                                                              (Ebinop Omul
                                                                (Econst_int (Int.repr 8) tint)
                                                                (Econst_int (Int.repr 2) tint)
                                                                tint) tuint)
                                                            (Ebinop Osub
                                                              (Ebinop Oshl
                                                                (Econst_int (Int.repr 1) tint)
                                                                (Econst_int (Int.repr 8) tint)
                                                                tint)
                                                              (Econst_int (Int.repr 1) tint)
                                                              tint) tuint)
                                                          (Econst_int (Int.repr 8) tint)
                                                          tuint) tuint)
                                                      tuint)
                                                    (Ecast
                                                      (Ebinop Oshl
                                                        (Ebinop Oand
                                                          (Ecast
                                                            (Ebinop Omul
                                                              (Econst_int (Int.repr 6) tint)
                                                              (Econst_int (Int.repr 2) tint)
                                                              tint) tuint)
                                                          (Ebinop Osub
                                                            (Ebinop Oshl
                                                              (Econst_int (Int.repr 1) tint)
                                                              (Econst_int (Int.repr 8) tint)
                                                              tint)
                                                            (Econst_int (Int.repr 1) tint)
                                                            tint) tuint)
                                                        (Econst_int (Int.repr 0) tint)
                                                        tuint) tuint) tuint)
                                                  tuint))
                                              (Sset _t'10
                                                (Ecast (Etempvar _t'10 tuint)
                                                  tuint)))
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
                                                                (Econst_int (Int.repr 8) tint)
                                                                (Econst_int (Int.repr 2) tint)
                                                                tint) tuint)
                                                            (Ebinop Osub
                                                              (Ebinop Oshl
                                                                (Econst_int (Int.repr 1) tint)
                                                                (Econst_int (Int.repr 8) tint)
                                                                tint)
                                                              (Econst_int (Int.repr 1) tint)
                                                              tint) tuint)
                                                          (Econst_int (Int.repr 16) tint)
                                                          tuint) tuint)
                                                      (Ecast
                                                        (Ebinop Oshl
                                                          (Ebinop Oand
                                                            (Ecast
                                                              (Ebinop Omul
                                                                (Econst_int (Int.repr 6) tint)
                                                                (Econst_int (Int.repr 2) tint)
                                                                tint) tuint)
                                                            (Ebinop Osub
                                                              (Ebinop Oshl
                                                                (Econst_int (Int.repr 1) tint)
                                                                (Econst_int (Int.repr 8) tint)
                                                                tint)
                                                              (Econst_int (Int.repr 1) tint)
                                                              tint) tuint)
                                                          (Econst_int (Int.repr 8) tint)
                                                          tuint) tuint)
                                                      tuint)
                                                    (Ecast
                                                      (Ebinop Oshl
                                                        (Ebinop Oand
                                                          (Ecast
                                                            (Ebinop Omul
                                                              (Econst_int (Int.repr 7) tint)
                                                              (Econst_int (Int.repr 2) tint)
                                                              tint) tuint)
                                                          (Ebinop Osub
                                                            (Ebinop Oshl
                                                              (Econst_int (Int.repr 1) tint)
                                                              (Econst_int (Int.repr 8) tint)
                                                              tint)
                                                            (Econst_int (Int.repr 1) tint)
                                                            tint) tuint)
                                                        (Econst_int (Int.repr 0) tint)
                                                        tuint) tuint) tuint)
                                                  tuint))
                                              (Sset _t'10
                                                (Ecast (Etempvar _t'10 tuint)
                                                  tuint)))))
                                        (Sassign
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                                                (Tunion __549 noattr)) _words
                                              (Tstruct __547 noattr)) _w0
                                            tuint)
                                          (Ebinop Oor
                                            (Ecast
                                              (Ebinop Oshl
                                                (Ebinop Oand
                                                  (Ecast
                                                    (Econst_int (Int.repr 5) tint)
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
                                            (Etempvar _t'10 tuint) tuint)))
                                      (Sassign
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                                              (Tunion __549 noattr)) _words
                                            (Tstruct __547 noattr)) _w1
                                          tuint)
                                        (Econst_int (Int.repr 0) tint))))
                                  (Ssequence
                                    (Ssequence
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'11
                                            (Evar _sGfxCursor (tptr (Tunion __549 noattr))))
                                          (Sassign
                                            (Evar _sGfxCursor (tptr (Tunion __549 noattr)))
                                            (Ebinop Oadd
                                              (Etempvar _t'11 (tptr (Tunion __549 noattr)))
                                              (Econst_int (Int.repr 1) tint)
                                              (tptr (Tunion __549 noattr)))))
                                        (Sset __g__5
                                          (Ecast
                                            (Etempvar _t'11 (tptr (Tunion __549 noattr)))
                                            (tptr (Tunion __549 noattr)))))
                                      (Ssequence
                                        (Ssequence
                                          (Sifthenelse (Ebinop Oeq
                                                         (Econst_int (Int.repr 0) tint)
                                                         (Econst_int (Int.repr 0) tint)
                                                         tint)
                                            (Sset _t'12
                                              (Ecast
                                                (Ebinop Oor
                                                  (Ebinop Oor
                                                    (Ecast
                                                      (Ebinop Oshl
                                                        (Ebinop Oand
                                                          (Ecast
                                                            (Ebinop Omul
                                                              (Econst_int (Int.repr 9) tint)
                                                              (Econst_int (Int.repr 2) tint)
                                                              tint) tuint)
                                                          (Ebinop Osub
                                                            (Ebinop Oshl
                                                              (Econst_int (Int.repr 1) tint)
                                                              (Econst_int (Int.repr 8) tint)
                                                              tint)
                                                            (Econst_int (Int.repr 1) tint)
                                                            tint) tuint)
                                                        (Econst_int (Int.repr 16) tint)
                                                        tuint) tuint)
                                                    (Ecast
                                                      (Ebinop Oshl
                                                        (Ebinop Oand
                                                          (Ecast
                                                            (Ebinop Omul
                                                              (Econst_int (Int.repr 10) tint)
                                                              (Econst_int (Int.repr 2) tint)
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
                                                            (Econst_int (Int.repr 2) tint)
                                                            tint) tuint)
                                                        (Ebinop Osub
                                                          (Ebinop Oshl
                                                            (Econst_int (Int.repr 1) tint)
                                                            (Econst_int (Int.repr 8) tint)
                                                            tint)
                                                          (Econst_int (Int.repr 1) tint)
                                                          tint) tuint)
                                                      (Econst_int (Int.repr 0) tint)
                                                      tuint) tuint) tuint)
                                                tuint))
                                            (Sifthenelse (Ebinop Oeq
                                                           (Econst_int (Int.repr 0) tint)
                                                           (Econst_int (Int.repr 1) tint)
                                                           tint)
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
                                                                  (Econst_int (Int.repr 10) tint)
                                                                  (Econst_int (Int.repr 2) tint)
                                                                  tint)
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
                                                        (Ecast
                                                          (Ebinop Oshl
                                                            (Ebinop Oand
                                                              (Ecast
                                                                (Ebinop Omul
                                                                  (Econst_int (Int.repr 11) tint)
                                                                  (Econst_int (Int.repr 2) tint)
                                                                  tint)
                                                                tuint)
                                                              (Ebinop Osub
                                                                (Ebinop Oshl
                                                                  (Econst_int (Int.repr 1) tint)
                                                                  (Econst_int (Int.repr 8) tint)
                                                                  tint)
                                                                (Econst_int (Int.repr 1) tint)
                                                                tint) tuint)
                                                            (Econst_int (Int.repr 8) tint)
                                                            tuint) tuint)
                                                        tuint)
                                                      (Ecast
                                                        (Ebinop Oshl
                                                          (Ebinop Oand
                                                            (Ecast
                                                              (Ebinop Omul
                                                                (Econst_int (Int.repr 9) tint)
                                                                (Econst_int (Int.repr 2) tint)
                                                                tint) tuint)
                                                            (Ebinop Osub
                                                              (Ebinop Oshl
                                                                (Econst_int (Int.repr 1) tint)
                                                                (Econst_int (Int.repr 8) tint)
                                                                tint)
                                                              (Econst_int (Int.repr 1) tint)
                                                              tint) tuint)
                                                          (Econst_int (Int.repr 0) tint)
                                                          tuint) tuint)
                                                      tuint) tuint))
                                                (Sset _t'12
                                                  (Ecast
                                                    (Etempvar _t'12 tuint)
                                                    tuint)))
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
                                                                  (Econst_int (Int.repr 11) tint)
                                                                  (Econst_int (Int.repr 2) tint)
                                                                  tint)
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
                                                        (Ecast
                                                          (Ebinop Oshl
                                                            (Ebinop Oand
                                                              (Ecast
                                                                (Ebinop Omul
                                                                  (Econst_int (Int.repr 9) tint)
                                                                  (Econst_int (Int.repr 2) tint)
                                                                  tint)
                                                                tuint)
                                                              (Ebinop Osub
                                                                (Ebinop Oshl
                                                                  (Econst_int (Int.repr 1) tint)
                                                                  (Econst_int (Int.repr 8) tint)
                                                                  tint)
                                                                (Econst_int (Int.repr 1) tint)
                                                                tint) tuint)
                                                            (Econst_int (Int.repr 8) tint)
                                                            tuint) tuint)
                                                        tuint)
                                                      (Ecast
                                                        (Ebinop Oshl
                                                          (Ebinop Oand
                                                            (Ecast
                                                              (Ebinop Omul
                                                                (Econst_int (Int.repr 10) tint)
                                                                (Econst_int (Int.repr 2) tint)
                                                                tint) tuint)
                                                            (Ebinop Osub
                                                              (Ebinop Oshl
                                                                (Econst_int (Int.repr 1) tint)
                                                                (Econst_int (Int.repr 8) tint)
                                                                tint)
                                                              (Econst_int (Int.repr 1) tint)
                                                              tint) tuint)
                                                          (Econst_int (Int.repr 0) tint)
                                                          tuint) tuint)
                                                      tuint) tuint))
                                                (Sset _t'12
                                                  (Ecast
                                                    (Etempvar _t'12 tuint)
                                                    tuint)))))
                                          (Sassign
                                            (Efield
                                              (Efield
                                                (Ederef
                                                  (Etempvar __g__5 (tptr (Tunion __549 noattr)))
                                                  (Tunion __549 noattr))
                                                _words
                                                (Tstruct __547 noattr)) _w0
                                              tuint)
                                            (Ebinop Oor
                                              (Ecast
                                                (Ebinop Oshl
                                                  (Ebinop Oand
                                                    (Ecast
                                                      (Econst_int (Int.repr 5) tint)
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
                                              (Etempvar _t'12 tuint) tuint)))
                                        (Sassign
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar __g__5 (tptr (Tunion __549 noattr)))
                                                (Tunion __549 noattr)) _words
                                              (Tstruct __547 noattr)) _w1
                                            tuint)
                                          (Econst_int (Int.repr 0) tint))))
                                    (Ssequence
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'13
                                            (Evar _sGfxCursor (tptr (Tunion __549 noattr))))
                                          (Sassign
                                            (Evar _sGfxCursor (tptr (Tunion __549 noattr)))
                                            (Ebinop Oadd
                                              (Etempvar _t'13 (tptr (Tunion __549 noattr)))
                                              (Econst_int (Int.repr 1) tint)
                                              (tptr (Tunion __549 noattr)))))
                                        (Sset __g__6
                                          (Ecast
                                            (Etempvar _t'13 (tptr (Tunion __549 noattr)))
                                            (tptr (Tunion __549 noattr)))))
                                      (Ssequence
                                        (Ssequence
                                          (Sifthenelse (Ebinop Oeq
                                                         (Econst_int (Int.repr 0) tint)
                                                         (Econst_int (Int.repr 0) tint)
                                                         tint)
                                            (Sset _t'14
                                              (Ecast
                                                (Ebinop Oor
                                                  (Ebinop Oor
                                                    (Ecast
                                                      (Ebinop Oshl
                                                        (Ebinop Oand
                                                          (Ecast
                                                            (Ebinop Omul
                                                              (Econst_int (Int.repr 12) tint)
                                                              (Econst_int (Int.repr 2) tint)
                                                              tint) tuint)
                                                          (Ebinop Osub
                                                            (Ebinop Oshl
                                                              (Econst_int (Int.repr 1) tint)
                                                              (Econst_int (Int.repr 8) tint)
                                                              tint)
                                                            (Econst_int (Int.repr 1) tint)
                                                            tint) tuint)
                                                        (Econst_int (Int.repr 16) tint)
                                                        tuint) tuint)
                                                    (Ecast
                                                      (Ebinop Oshl
                                                        (Ebinop Oand
                                                          (Ecast
                                                            (Ebinop Omul
                                                              (Econst_int (Int.repr 13) tint)
                                                              (Econst_int (Int.repr 2) tint)
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
                                                            (Econst_int (Int.repr 2) tint)
                                                            tint) tuint)
                                                        (Ebinop Osub
                                                          (Ebinop Oshl
                                                            (Econst_int (Int.repr 1) tint)
                                                            (Econst_int (Int.repr 8) tint)
                                                            tint)
                                                          (Econst_int (Int.repr 1) tint)
                                                          tint) tuint)
                                                      (Econst_int (Int.repr 0) tint)
                                                      tuint) tuint) tuint)
                                                tuint))
                                            (Sifthenelse (Ebinop Oeq
                                                           (Econst_int (Int.repr 0) tint)
                                                           (Econst_int (Int.repr 1) tint)
                                                           tint)
                                              (Ssequence
                                                (Sset _t'14
                                                  (Ecast
                                                    (Ebinop Oor
                                                      (Ebinop Oor
                                                        (Ecast
                                                          (Ebinop Oshl
                                                            (Ebinop Oand
                                                              (Ecast
                                                                (Ebinop Omul
                                                                  (Econst_int (Int.repr 13) tint)
                                                                  (Econst_int (Int.repr 2) tint)
                                                                  tint)
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
                                                        (Ecast
                                                          (Ebinop Oshl
                                                            (Ebinop Oand
                                                              (Ecast
                                                                (Ebinop Omul
                                                                  (Econst_int (Int.repr 14) tint)
                                                                  (Econst_int (Int.repr 2) tint)
                                                                  tint)
                                                                tuint)
                                                              (Ebinop Osub
                                                                (Ebinop Oshl
                                                                  (Econst_int (Int.repr 1) tint)
                                                                  (Econst_int (Int.repr 8) tint)
                                                                  tint)
                                                                (Econst_int (Int.repr 1) tint)
                                                                tint) tuint)
                                                            (Econst_int (Int.repr 8) tint)
                                                            tuint) tuint)
                                                        tuint)
                                                      (Ecast
                                                        (Ebinop Oshl
                                                          (Ebinop Oand
                                                            (Ecast
                                                              (Ebinop Omul
                                                                (Econst_int (Int.repr 12) tint)
                                                                (Econst_int (Int.repr 2) tint)
                                                                tint) tuint)
                                                            (Ebinop Osub
                                                              (Ebinop Oshl
                                                                (Econst_int (Int.repr 1) tint)
                                                                (Econst_int (Int.repr 8) tint)
                                                                tint)
                                                              (Econst_int (Int.repr 1) tint)
                                                              tint) tuint)
                                                          (Econst_int (Int.repr 0) tint)
                                                          tuint) tuint)
                                                      tuint) tuint))
                                                (Sset _t'14
                                                  (Ecast
                                                    (Etempvar _t'14 tuint)
                                                    tuint)))
                                              (Ssequence
                                                (Sset _t'14
                                                  (Ecast
                                                    (Ebinop Oor
                                                      (Ebinop Oor
                                                        (Ecast
                                                          (Ebinop Oshl
                                                            (Ebinop Oand
                                                              (Ecast
                                                                (Ebinop Omul
                                                                  (Econst_int (Int.repr 14) tint)
                                                                  (Econst_int (Int.repr 2) tint)
                                                                  tint)
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
                                                        (Ecast
                                                          (Ebinop Oshl
                                                            (Ebinop Oand
                                                              (Ecast
                                                                (Ebinop Omul
                                                                  (Econst_int (Int.repr 12) tint)
                                                                  (Econst_int (Int.repr 2) tint)
                                                                  tint)
                                                                tuint)
                                                              (Ebinop Osub
                                                                (Ebinop Oshl
                                                                  (Econst_int (Int.repr 1) tint)
                                                                  (Econst_int (Int.repr 8) tint)
                                                                  tint)
                                                                (Econst_int (Int.repr 1) tint)
                                                                tint) tuint)
                                                            (Econst_int (Int.repr 8) tint)
                                                            tuint) tuint)
                                                        tuint)
                                                      (Ecast
                                                        (Ebinop Oshl
                                                          (Ebinop Oand
                                                            (Ecast
                                                              (Ebinop Omul
                                                                (Econst_int (Int.repr 13) tint)
                                                                (Econst_int (Int.repr 2) tint)
                                                                tint) tuint)
                                                            (Ebinop Osub
                                                              (Ebinop Oshl
                                                                (Econst_int (Int.repr 1) tint)
                                                                (Econst_int (Int.repr 8) tint)
                                                                tint)
                                                              (Econst_int (Int.repr 1) tint)
                                                              tint) tuint)
                                                          (Econst_int (Int.repr 0) tint)
                                                          tuint) tuint)
                                                      tuint) tuint))
                                                (Sset _t'14
                                                  (Ecast
                                                    (Etempvar _t'14 tuint)
                                                    tuint)))))
                                          (Sassign
                                            (Efield
                                              (Efield
                                                (Ederef
                                                  (Etempvar __g__6 (tptr (Tunion __549 noattr)))
                                                  (Tunion __549 noattr))
                                                _words
                                                (Tstruct __547 noattr)) _w0
                                              tuint)
                                            (Ebinop Oor
                                              (Ecast
                                                (Ebinop Oshl
                                                  (Ebinop Oand
                                                    (Ecast
                                                      (Econst_int (Int.repr 5) tint)
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
                                              (Etempvar _t'14 tuint) tuint)))
                                        (Sassign
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar __g__6 (tptr (Tunion __549 noattr)))
                                                (Tunion __549 noattr)) _words
                                              (Tstruct __547 noattr)) _w1
                                            tuint)
                                          (Econst_int (Int.repr 0) tint))))))))))))
                    (Sset _i
                      (Ebinop Oadd (Etempvar _i tint)
                        (Econst_int (Int.repr 5) tint) tint))))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'15
                          (Evar _sGfxCursor (tptr (Tunion __549 noattr))))
                        (Sassign
                          (Evar _sGfxCursor (tptr (Tunion __549 noattr)))
                          (Ebinop Oadd
                            (Etempvar _t'15 (tptr (Tunion __549 noattr)))
                            (Econst_int (Int.repr 1) tint)
                            (tptr (Tunion __549 noattr)))))
                      (Sset __g__7
                        (Ecast (Etempvar _t'15 (tptr (Tunion __549 noattr)))
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
                              (Etempvar __g__7 (tptr (Tunion __549 noattr)))
                              (Tunion __549 noattr)) _words
                            (Tstruct __547 noattr)) _w1 tuint)
                        (Ecast
                          (Eaddrof
                            (Evar _tiny_bubble_dl_0B006AB0 (tarray (Tunion __549 noattr) 0))
                            (tptr (tarray (Tunion __549 noattr) 0))) tuint))))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'16
                            (Evar _sGfxCursor (tptr (Tunion __549 noattr))))
                          (Sassign
                            (Evar _sGfxCursor (tptr (Tunion __549 noattr)))
                            (Ebinop Oadd
                              (Etempvar _t'16 (tptr (Tunion __549 noattr)))
                              (Econst_int (Int.repr 1) tint)
                              (tptr (Tunion __549 noattr)))))
                        (Sset __g__8
                          (Ecast
                            (Etempvar _t'16 (tptr (Tunion __549 noattr)))
                            (tptr (Tunion __549 noattr)))))
                      (Ssequence
                        (Sassign
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar __g__8 (tptr (Tunion __549 noattr)))
                                (Tunion __549 noattr)) _words
                              (Tstruct __547 noattr)) _w0 tuint)
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast (Econst_int (Int.repr 223) tint)
                                  tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 8) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 24) tint) tuint) tuint))
                        (Sassign
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar __g__8 (tptr (Tunion __549 noattr)))
                                (Tunion __549 noattr)) _words
                              (Tstruct __547 noattr)) _w1 tuint)
                          (Econst_int (Int.repr 0) tint))))
                    (Sreturn (Some (Etempvar _gfxStart (tptr (Tunion __549 noattr)))))))))))))))
|}.

Definition f_envfx_set_max_bubble_particles := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_mode, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tshort) :: (_t'1, tshort) :: nil);
  fn_body :=
(Sswitch (Etempvar _mode tint)
  (LScons (Some 13)
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Ederef
            (Ebinop Oadd (Evar _gEnvFxBubbleConfig (tarray tshort 10))
              (Econst_int (Int.repr 7) tint) (tptr tshort)) tshort))
        (Sassign (Evar _sBubbleParticleMaxCount tint) (Etempvar _t'2 tshort)))
      Sbreak)
    (LScons (Some 14)
      (Ssequence
        (Ssequence
          (Sset _t'1
            (Ederef
              (Ebinop Oadd (Evar _gEnvFxBubbleConfig (tarray tshort 10))
                (Econst_int (Int.repr 7) tint) (tptr tshort)) tshort))
          (Sassign (Evar _sBubbleParticleMaxCount tint)
            (Etempvar _t'1 tshort)))
        Sbreak)
      LSnil)))
|}.

Definition f_envfx_update_bubbles := {|
  fn_return := (tptr (Tunion __549 noattr));
  fn_callconv := cc_default;
  fn_params := ((_mode, tint) :: (_marioPos, (tptr tshort)) ::
                (_camTo, (tptr tshort)) :: (_camFrom, (tptr tshort)) :: nil);
  fn_vars := nil;
  fn_temps := ((_gfx, (tptr (Tunion __549 noattr))) ::
               (_t'6, (tptr (Tunion __549 noattr))) ::
               (_t'5, (tptr (Tunion __549 noattr))) ::
               (_t'4, (tptr (Tunion __549 noattr))) ::
               (_t'3, (tptr (Tunion __549 noattr))) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'8, tschar) :: (_t'7, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'8 (Evar _gEnvFxMode tschar))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'8 tschar)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _envfx_init_bubble (Tfunction (tint :: nil) tint
                                       cc_default))
            ((Etempvar _mode tint) :: nil))
          (Sset _t'1
            (Ecast (Eunop Onotbool (Etempvar _t'2 tint) tint) tbool)))
        (Sset _t'1 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _envfx_set_max_bubble_particles (Tfunction (tint :: nil) tvoid
                                              cc_default))
      ((Etempvar _mode tint) :: nil))
    (Ssequence
      (Ssequence
        (Sset _t'7 (Evar _sBubbleParticleMaxCount tint))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'7 tint)
                       (Econst_int (Int.repr 0) tint) tint)
          (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
          Sskip))
      (Ssequence
        (Sswitch (Etempvar _mode tint)
          (LScons (Some 11)
            (Ssequence
              (Ssequence
                (Scall (Some _t'3)
                  (Evar _envfx_update_bubble_particles (Tfunction
                                                         (tint ::
                                                          (tptr tshort) ::
                                                          (tptr tshort) ::
                                                          (tptr tshort) ::
                                                          nil)
                                                         (tptr (Tunion __549 noattr))
                                                         cc_default))
                  ((Econst_int (Int.repr 11) tint) ::
                   (Etempvar _marioPos (tptr tshort)) ::
                   (Etempvar _camFrom (tptr tshort)) ::
                   (Etempvar _camTo (tptr tshort)) :: nil))
                (Sset _gfx (Etempvar _t'3 (tptr (Tunion __549 noattr)))))
              Sbreak)
            (LScons (Some 12)
              (Ssequence
                (Ssequence
                  (Scall (Some _t'4)
                    (Evar _envfx_update_bubble_particles (Tfunction
                                                           (tint ::
                                                            (tptr tshort) ::
                                                            (tptr tshort) ::
                                                            (tptr tshort) ::
                                                            nil)
                                                           (tptr (Tunion __549 noattr))
                                                           cc_default))
                    ((Econst_int (Int.repr 12) tint) ::
                     (Etempvar _marioPos (tptr tshort)) ::
                     (Etempvar _camFrom (tptr tshort)) ::
                     (Etempvar _camTo (tptr tshort)) :: nil))
                  (Sset _gfx (Etempvar _t'4 (tptr (Tunion __549 noattr)))))
                Sbreak)
              (LScons (Some 13)
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'5)
                      (Evar _envfx_update_bubble_particles (Tfunction
                                                             (tint ::
                                                              (tptr tshort) ::
                                                              (tptr tshort) ::
                                                              (tptr tshort) ::
                                                              nil)
                                                             (tptr (Tunion __549 noattr))
                                                             cc_default))
                      ((Econst_int (Int.repr 13) tint) ::
                       (Etempvar _marioPos (tptr tshort)) ::
                       (Etempvar _camFrom (tptr tshort)) ::
                       (Etempvar _camTo (tptr tshort)) :: nil))
                    (Sset _gfx (Etempvar _t'5 (tptr (Tunion __549 noattr)))))
                  Sbreak)
                (LScons (Some 14)
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'6)
                        (Evar _envfx_update_bubble_particles (Tfunction
                                                               (tint ::
                                                                (tptr tshort) ::
                                                                (tptr tshort) ::
                                                                (tptr tshort) ::
                                                                nil)
                                                               (tptr (Tunion __549 noattr))
                                                               cc_default))
                        ((Econst_int (Int.repr 14) tint) ::
                         (Etempvar _marioPos (tptr tshort)) ::
                         (Etempvar _camFrom (tptr tshort)) ::
                         (Etempvar _camTo (tptr tshort)) :: nil))
                      (Sset _gfx
                        (Etempvar _t'6 (tptr (Tunion __549 noattr)))))
                    Sbreak)
                  (LScons None
                    (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint)
                                     (tptr tvoid))))
                    LSnil))))))
        (Sreturn (Some (Etempvar _gfx (tptr (Tunion __549 noattr)))))))))
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
 Composite __469 Struct
   (Member_plain _flag tuchar :: Member_plain _v (tarray tuchar 3) :: nil)
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
 Composite _EnvFxParticle Struct
   (Member_plain _isAlive tschar :: Member_plain _animFrame tshort ::
    Member_plain _xPos tint :: Member_plain _yPos tint ::
    Member_plain _zPos tint :: Member_plain _angleAndDist (tarray tint 2) ::
    Member_plain _unusedBubbleVar tint :: Member_plain _bubbleY tint ::
    Member_plain _filler (tarray tuchar 24) :: nil)
   noattr ::
 Composite _FloorGeometry Struct
   (Member_plain _filler (tarray tuchar 16) ::
    Member_plain _normalX tfloat :: Member_plain _normalY tfloat ::
    Member_plain _normalZ tfloat :: Member_plain _originOffset tfloat :: nil)
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
 (_bzero,
   Gfun(External (EF_external "bzero"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default)) ((tptr tvoid) :: tuint :: nil) tvoid
     cc_default)) :: (_gEffectsMemoryPool, Gvar v_gEffectsMemoryPool) ::
 (_segmented_to_virtual,
   Gfun(External (EF_external "segmented_to_virtual"
                   (mksignature (AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr tvoid) :: nil) (tptr tvoid) cc_default)) ::
 (_mem_pool_alloc,
   Gfun(External (EF_external "mem_pool_alloc"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xptr
                     cc_default))
     ((tptr (Tstruct _MemoryPool noattr)) :: tuint :: nil) (tptr tvoid)
     cc_default)) ::
 (_alloc_display_list,
   Gfun(External (EF_external "alloc_display_list"
                   (mksignature (AST.Xint :: nil) AST.Xptr cc_default))
     (tuint :: nil) (tptr tvoid) cc_default)) ::
 (_gGlobalTimer, Gvar v_gGlobalTimer) :: (_gEnvFxMode, Gvar v_gEnvFxMode) ::
 (_gEnvFxBuffer, Gvar v_gEnvFxBuffer) ::
 (_orbit_from_positions,
   Gfun(External (EF_external "orbit_from_positions"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xptr :: AST.Xptr ::
                      AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr tshort) :: (tptr tshort) :: (tptr tshort) :: (tptr tshort) ::
      (tptr tshort) :: nil) tvoid cc_default)) ::
 (_rotate_triangle_vertices,
   Gfun(External (EF_external "rotate_triangle_vertices"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xptr :: AST.Xint16signed ::
                      AST.Xint16signed :: nil) AST.Xvoid cc_default))
     ((tptr tshort) :: (tptr tshort) :: (tptr tshort) :: tshort :: tshort ::
      nil) tvoid cc_default)) ::
 (_find_floor_height_and_data,
   Gfun(External (EF_external "find_floor_height_and_data"
                   (mksignature
                     (AST.Xsingle :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xptr :: nil) AST.Xsingle cc_default))
     (tfloat :: tfloat :: tfloat ::
      (tptr (tptr (Tstruct _FloorGeometry noattr))) :: nil) tfloat
     cc_default)) ::
 (_find_floor,
   Gfun(External (EF_external "find_floor"
                   (mksignature
                     (AST.Xsingle :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xptr :: nil) AST.Xsingle cc_default))
     (tfloat :: tfloat :: tfloat ::
      (tptr (tptr (Tstruct _Surface noattr))) :: nil) tfloat cc_default)) ::
 (_gSineTable, Gvar v_gSineTable) ::
 (_random_u16,
   Gfun(External (EF_external "random_u16"
                   (mksignature nil AST.Xint16unsigned cc_default)) nil
     tushort cc_default)) ::
 (_random_float,
   Gfun(External (EF_external "random_float"
                   (mksignature nil AST.Xsingle cc_default)) nil tfloat
     cc_default)) :: (_gGlobalSoundSource, Gvar v_gGlobalSoundSource) ::
 (_play_sound,
   Gfun(External (EF_external "play_sound"
                   (mksignature (AST.Xint :: AST.Xptr :: nil) AST.Xvoid
                     cc_default)) (tint :: (tptr tfloat) :: nil) tvoid
     cc_default)) ::
 (_flower_bubbles_textures_ptr_0B002008, Gvar v_flower_bubbles_textures_ptr_0B002008) ::
 (_lava_bubble_ptr_0B006020, Gvar v_lava_bubble_ptr_0B006020) ::
 (_bubble_ptr_0B006848, Gvar v_bubble_ptr_0B006848) ::
 (_tiny_bubble_dl_0B006AB0, Gvar v_tiny_bubble_dl_0B006AB0) ::
 (_tiny_bubble_dl_0B006D38, Gvar v_tiny_bubble_dl_0B006D38) ::
 (_tiny_bubble_dl_0B006D68, Gvar v_tiny_bubble_dl_0B006D68) ::
 (_gEnvFxBubbleConfig, Gvar v_gEnvFxBubbleConfig) ::
 (_sGfxCursor, Gvar v_sGfxCursor) ::
 (_sBubbleParticleCount, Gvar v_sBubbleParticleCount) ::
 (_sBubbleParticleMaxCount, Gvar v_sBubbleParticleMaxCount) ::
 (_D_80330690, Gvar v_D_80330690) :: (_D_80330694, Gvar v_D_80330694) ::
 (_gBubbleTempVtx, Gvar v_gBubbleTempVtx) ::
 (_particle_is_laterally_close, Gfun(Internal f_particle_is_laterally_close)) ::
 (_random_flower_offset, Gfun(Internal f_random_flower_offset)) ::
 (_envfx_update_flower, Gfun(Internal f_envfx_update_flower)) ::
 (_envfx_set_lava_bubble_position, Gfun(Internal f_envfx_set_lava_bubble_position)) ::
 (_envfx_update_lava, Gfun(Internal f_envfx_update_lava)) ::
 (_envfx_rotate_around_whirlpool, Gfun(Internal f_envfx_rotate_around_whirlpool)) ::
 (_envfx_is_whirlpool_bubble_alive, Gfun(Internal f_envfx_is_whirlpool_bubble_alive)) ::
 (_envfx_update_whirlpool, Gfun(Internal f_envfx_update_whirlpool)) ::
 (_envfx_is_jestream_bubble_alive, Gfun(Internal f_envfx_is_jestream_bubble_alive)) ::
 (_envfx_update_jetstream, Gfun(Internal f_envfx_update_jetstream)) ::
 (_envfx_init_bubble, Gfun(Internal f_envfx_init_bubble)) ::
 (_envfx_bubbles_update_switch, Gfun(Internal f_envfx_bubbles_update_switch)) ::
 (_append_bubble_vertex_buffer, Gfun(Internal f_append_bubble_vertex_buffer)) ::
 (_envfx_set_bubble_texture, Gfun(Internal f_envfx_set_bubble_texture)) ::
 (_envfx_update_bubble_particles, Gfun(Internal f_envfx_update_bubble_particles)) ::
 (_envfx_set_max_bubble_particles, Gfun(Internal f_envfx_set_max_bubble_particles)) ::
 (_envfx_update_bubbles, Gfun(Internal f_envfx_update_bubbles)) :: nil).

Definition public_idents : list ident :=
(_envfx_update_bubbles :: _envfx_set_max_bubble_particles ::
 _envfx_update_bubble_particles :: _envfx_set_bubble_texture ::
 _append_bubble_vertex_buffer :: _envfx_bubbles_update_switch ::
 _envfx_init_bubble :: _envfx_update_jetstream ::
 _envfx_is_jestream_bubble_alive :: _envfx_update_whirlpool ::
 _envfx_is_whirlpool_bubble_alive :: _envfx_rotate_around_whirlpool ::
 _envfx_update_lava :: _envfx_set_lava_bubble_position ::
 _envfx_update_flower :: _random_flower_offset ::
 _particle_is_laterally_close :: _gBubbleTempVtx :: _D_80330694 ::
 _D_80330690 :: _gEnvFxBubbleConfig :: _tiny_bubble_dl_0B006D68 ::
 _tiny_bubble_dl_0B006D38 :: _tiny_bubble_dl_0B006AB0 ::
 _bubble_ptr_0B006848 :: _lava_bubble_ptr_0B006020 ::
 _flower_bubbles_textures_ptr_0B002008 :: _play_sound ::
 _gGlobalSoundSource :: _random_float :: _random_u16 :: _gSineTable ::
 _find_floor :: _find_floor_height_and_data :: _rotate_triangle_vertices ::
 _orbit_from_positions :: _gEnvFxBuffer :: _gEnvFxMode :: _gGlobalTimer ::
 _alloc_display_list :: _mem_pool_alloc :: _segmented_to_virtual ::
 _gEffectsMemoryPool :: _bzero :: ___builtin_debug ::
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
