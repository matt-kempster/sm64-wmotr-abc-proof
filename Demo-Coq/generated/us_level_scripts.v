(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_US
   Source:          levels/scripts.c
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -Ibuild/pinned-sm64/levels -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1
   Link hygiene:    private __stringlit_N atoms prefixed with us_level_scripts
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
  Definition source_file := "build/pinned-sm64/levels/scripts.c".
  Definition normalized := true.
End Info.

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
Definition __bbhSegmentRomEnd : ident := $"_bbhSegmentRomEnd".
Definition __bbhSegmentRomStart : ident := $"_bbhSegmentRomStart".
Definition __behaviorSegmentRomEnd : ident := $"_behaviorSegmentRomEnd".
Definition __behaviorSegmentRomStart : ident := $"_behaviorSegmentRomStart".
Definition __bitdwSegmentRomEnd : ident := $"_bitdwSegmentRomEnd".
Definition __bitdwSegmentRomStart : ident := $"_bitdwSegmentRomStart".
Definition __bitfsSegmentRomEnd : ident := $"_bitfsSegmentRomEnd".
Definition __bitfsSegmentRomStart : ident := $"_bitfsSegmentRomStart".
Definition __bitsSegmentRomEnd : ident := $"_bitsSegmentRomEnd".
Definition __bitsSegmentRomStart : ident := $"_bitsSegmentRomStart".
Definition __bobSegmentRomEnd : ident := $"_bobSegmentRomEnd".
Definition __bobSegmentRomStart : ident := $"_bobSegmentRomStart".
Definition __bowser_1SegmentRomEnd : ident := $"_bowser_1SegmentRomEnd".
Definition __bowser_1SegmentRomStart : ident := $"_bowser_1SegmentRomStart".
Definition __bowser_2SegmentRomEnd : ident := $"_bowser_2SegmentRomEnd".
Definition __bowser_2SegmentRomStart : ident := $"_bowser_2SegmentRomStart".
Definition __bowser_3SegmentRomEnd : ident := $"_bowser_3SegmentRomEnd".
Definition __bowser_3SegmentRomStart : ident := $"_bowser_3SegmentRomStart".
Definition __castle_courtyardSegmentRomEnd : ident := $"_castle_courtyardSegmentRomEnd".
Definition __castle_courtyardSegmentRomStart : ident := $"_castle_courtyardSegmentRomStart".
Definition __castle_groundsSegmentRomEnd : ident := $"_castle_groundsSegmentRomEnd".
Definition __castle_groundsSegmentRomStart : ident := $"_castle_groundsSegmentRomStart".
Definition __castle_insideSegmentRomEnd : ident := $"_castle_insideSegmentRomEnd".
Definition __castle_insideSegmentRomStart : ident := $"_castle_insideSegmentRomStart".
Definition __ccmSegmentRomEnd : ident := $"_ccmSegmentRomEnd".
Definition __ccmSegmentRomStart : ident := $"_ccmSegmentRomStart".
Definition __common1_geoSegmentRomEnd : ident := $"_common1_geoSegmentRomEnd".
Definition __common1_geoSegmentRomStart : ident := $"_common1_geoSegmentRomStart".
Definition __common1_mio0SegmentRomEnd : ident := $"_common1_mio0SegmentRomEnd".
Definition __common1_mio0SegmentRomStart : ident := $"_common1_mio0SegmentRomStart".
Definition __cotmcSegmentRomEnd : ident := $"_cotmcSegmentRomEnd".
Definition __cotmcSegmentRomStart : ident := $"_cotmcSegmentRomStart".
Definition __dddSegmentRomEnd : ident := $"_dddSegmentRomEnd".
Definition __dddSegmentRomStart : ident := $"_dddSegmentRomStart".
Definition __endingSegmentRomEnd : ident := $"_endingSegmentRomEnd".
Definition __endingSegmentRomStart : ident := $"_endingSegmentRomStart".
Definition __group0_geoSegmentRomEnd : ident := $"_group0_geoSegmentRomEnd".
Definition __group0_geoSegmentRomStart : ident := $"_group0_geoSegmentRomStart".
Definition __group0_mio0SegmentRomEnd : ident := $"_group0_mio0SegmentRomEnd".
Definition __group0_mio0SegmentRomStart : ident := $"_group0_mio0SegmentRomStart".
Definition __hmcSegmentRomEnd : ident := $"_hmcSegmentRomEnd".
Definition __hmcSegmentRomStart : ident := $"_hmcSegmentRomStart".
Definition __introSegmentRomEnd : ident := $"_introSegmentRomEnd".
Definition __introSegmentRomStart : ident := $"_introSegmentRomStart".
Definition __jrbSegmentRomEnd : ident := $"_jrbSegmentRomEnd".
Definition __jrbSegmentRomStart : ident := $"_jrbSegmentRomStart".
Definition __lllSegmentRomEnd : ident := $"_lllSegmentRomEnd".
Definition __lllSegmentRomStart : ident := $"_lllSegmentRomStart".
Definition __menuSegmentRomEnd : ident := $"_menuSegmentRomEnd".
Definition __menuSegmentRomStart : ident := $"_menuSegmentRomStart".
Definition __pssSegmentRomEnd : ident := $"_pssSegmentRomEnd".
Definition __pssSegmentRomStart : ident := $"_pssSegmentRomStart".
Definition __rrSegmentRomEnd : ident := $"_rrSegmentRomEnd".
Definition __rrSegmentRomStart : ident := $"_rrSegmentRomStart".
Definition __saSegmentRomEnd : ident := $"_saSegmentRomEnd".
Definition __saSegmentRomStart : ident := $"_saSegmentRomStart".
Definition __slSegmentRomEnd : ident := $"_slSegmentRomEnd".
Definition __slSegmentRomStart : ident := $"_slSegmentRomStart".
Definition __sslSegmentRomEnd : ident := $"_sslSegmentRomEnd".
Definition __sslSegmentRomStart : ident := $"_sslSegmentRomStart".
Definition __thiSegmentRomEnd : ident := $"_thiSegmentRomEnd".
Definition __thiSegmentRomStart : ident := $"_thiSegmentRomStart".
Definition __totwcSegmentRomEnd : ident := $"_totwcSegmentRomEnd".
Definition __totwcSegmentRomStart : ident := $"_totwcSegmentRomStart".
Definition __ttcSegmentRomEnd : ident := $"_ttcSegmentRomEnd".
Definition __ttcSegmentRomStart : ident := $"_ttcSegmentRomStart".
Definition __ttmSegmentRomEnd : ident := $"_ttmSegmentRomEnd".
Definition __ttmSegmentRomStart : ident := $"_ttmSegmentRomStart".
Definition __vcutmSegmentRomEnd : ident := $"_vcutmSegmentRomEnd".
Definition __vcutmSegmentRomStart : ident := $"_vcutmSegmentRomStart".
Definition __wdwSegmentRomEnd : ident := $"_wdwSegmentRomEnd".
Definition __wdwSegmentRomStart : ident := $"_wdwSegmentRomStart".
Definition __wfSegmentRomEnd : ident := $"_wfSegmentRomEnd".
Definition __wfSegmentRomStart : ident := $"_wfSegmentRomStart".
Definition __wmotrSegmentRomEnd : ident := $"_wmotrSegmentRomEnd".
Definition __wmotrSegmentRomStart : ident := $"_wmotrSegmentRomStart".
Definition _addr : ident := $"addr".
Definition _base : ident := $"base".
Definition _birds_geo : ident := $"birds_geo".
Definition _black_bobomb_geo : ident := $"black_bobomb_geo".
Definition _blargg_geo : ident := $"blargg_geo".
Definition _blue_coin_geo : ident := $"blue_coin_geo".
Definition _blue_coin_no_shadow_geo : ident := $"blue_coin_no_shadow_geo".
Definition _blue_coin_switch_geo : ident := $"blue_coin_switch_geo".
Definition _blue_flame_geo : ident := $"blue_flame_geo".
Definition _bobomb_buddy_geo : ident := $"bobomb_buddy_geo".
Definition _boo_castle_geo : ident := $"boo_castle_geo".
Definition _boo_geo : ident := $"boo_geo".
Definition _bookend_geo : ident := $"bookend_geo".
Definition _bookend_part_geo : ident := $"bookend_part_geo".
Definition _bowling_ball_geo : ident := $"bowling_ball_geo".
Definition _bowling_ball_track_geo : ident := $"bowling_ball_track_geo".
Definition _bowser_bomb_geo : ident := $"bowser_bomb_geo".
Definition _bowser_flames_geo : ident := $"bowser_flames_geo".
Definition _bowser_geo : ident := $"bowser_geo".
Definition _bowser_geo_no_shadow : ident := $"bowser_geo_no_shadow".
Definition _bowser_impact_smoke_geo : ident := $"bowser_impact_smoke_geo".
Definition _bowser_key_cutscene_geo : ident := $"bowser_key_cutscene_geo".
Definition _bowser_key_geo : ident := $"bowser_key_geo".
Definition _breakable_box_geo : ident := $"breakable_box_geo".
Definition _breakable_box_small_geo : ident := $"breakable_box_small_geo".
Definition _bub_geo : ident := $"bub_geo".
Definition _bubba_geo : ident := $"bubba_geo".
Definition _bubble_geo : ident := $"bubble_geo".
Definition _bullet_bill_geo : ident := $"bullet_bill_geo".
Definition _bully_boss_geo : ident := $"bully_boss_geo".
Definition _bully_geo : ident := $"bully_geo".
Definition _burn_smoke_geo : ident := $"burn_smoke_geo".
Definition _butterfly_geo : ident := $"butterfly_geo".
Definition _cannon_barrel_geo : ident := $"cannon_barrel_geo".
Definition _cannon_base_geo : ident := $"cannon_base_geo".
Definition _cannon_lid_seg8_dl_080048E0 : ident := $"cannon_lid_seg8_dl_080048E0".
Definition _cap_switch_base_seg5_dl_05003120 : ident := $"cap_switch_base_seg5_dl_05003120".
Definition _cap_switch_exclamation_seg5_dl_05002E00 : ident := $"cap_switch_exclamation_seg5_dl_05002E00".
Definition _cap_switch_geo : ident := $"cap_switch_geo".
Definition _cartoon_star_geo : ident := $"cartoon_star_geo".
Definition _chain_chomp_geo : ident := $"chain_chomp_geo".
Definition _checkerboard_platform_geo : ident := $"checkerboard_platform_geo".
Definition _chilly_chief_big_geo : ident := $"chilly_chief_big_geo".
Definition _chilly_chief_geo : ident := $"chilly_chief_geo".
Definition _chuckya_geo : ident := $"chuckya_geo".
Definition _clam_shell_geo : ident := $"clam_shell_geo".
Definition _cmd : ident := $"cmd".
Definition _color : ident := $"color".
Definition _cs : ident := $"cs".
Definition _ct : ident := $"ct".
Definition _cyan_fish_geo : ident := $"cyan_fish_geo".
Definition _dAmpGeo : ident := $"dAmpGeo".
Definition _data : ident := $"data".
Definition _dirt_animation_geo : ident := $"dirt_animation_geo".
Definition _dma : ident := $"dma".
Definition _dorrie_geo : ident := $"dorrie_geo".
Definition _dram : ident := $"dram".
Definition _enemy_lakitu_geo : ident := $"enemy_lakitu_geo".
Definition _exclamation_box_geo : ident := $"exclamation_box_geo".
Definition _exclamation_box_outline_geo : ident := $"exclamation_box_outline_geo".
Definition _exclamation_box_outline_seg8_dl_08025F08 : ident := $"exclamation_box_outline_seg8_dl_08025F08".
Definition _explosion_geo : ident := $"explosion_geo".
Definition _eyerok_left_hand_geo : ident := $"eyerok_left_hand_geo".
Definition _eyerok_right_hand_geo : ident := $"eyerok_right_hand_geo".
Definition _fillrect : ident := $"fillrect".
Definition _fish_geo : ident := $"fish_geo".
Definition _fish_shadow_geo : ident := $"fish_shadow_geo".
Definition _flag : ident := $"flag".
Definition _flyguy_geo : ident := $"flyguy_geo".
Definition _fmt : ident := $"fmt".
Definition _force_structure_alignment : ident := $"force_structure_alignment".
Definition _fwoosh_geo : ident := $"fwoosh_geo".
Definition _goomba_geo : ident := $"goomba_geo".
Definition _goto_mario_head_dizzy : ident := $"goto_mario_head_dizzy".
Definition _goto_mario_head_regular : ident := $"goto_mario_head_regular".
Definition _haunted_cage_geo : ident := $"haunted_cage_geo".
Definition _haunted_chair_geo : ident := $"haunted_chair_geo".
Definition _heart_geo : ident := $"heart_geo".
Definition _heave_ho_geo : ident := $"heave_ho_geo".
Definition _hoot_geo : ident := $"hoot_geo".
Definition _idle_water_wave_geo : ident := $"idle_water_wave_geo".
Definition _invisible_bowser_accessory_geo : ident := $"invisible_bowser_accessory_geo".
Definition _king_bobomb_geo : ident := $"king_bobomb_geo".
Definition _klepto_geo : ident := $"klepto_geo".
Definition _koopa_flag_geo : ident := $"koopa_flag_geo".
Definition _koopa_shell_geo : ident := $"koopa_shell_geo".
Definition _koopa_with_shell_geo : ident := $"koopa_with_shell_geo".
Definition _koopa_without_shell_geo : ident := $"koopa_without_shell_geo".
Definition _lakitu_geo : ident := $"lakitu_geo".
Definition _leaves_geo : ident := $"leaves_geo".
Definition _len : ident := $"len".
Definition _level_bbh_entry : ident := $"level_bbh_entry".
Definition _level_bitdw_entry : ident := $"level_bitdw_entry".
Definition _level_bitfs_entry : ident := $"level_bitfs_entry".
Definition _level_bits_entry : ident := $"level_bits_entry".
Definition _level_bob_entry : ident := $"level_bob_entry".
Definition _level_bowser_1_entry : ident := $"level_bowser_1_entry".
Definition _level_bowser_2_entry : ident := $"level_bowser_2_entry".
Definition _level_bowser_3_entry : ident := $"level_bowser_3_entry".
Definition _level_castle_courtyard_entry : ident := $"level_castle_courtyard_entry".
Definition _level_castle_grounds_entry : ident := $"level_castle_grounds_entry".
Definition _level_castle_inside_entry : ident := $"level_castle_inside_entry".
Definition _level_ccm_entry : ident := $"level_ccm_entry".
Definition _level_cotmc_entry : ident := $"level_cotmc_entry".
Definition _level_ddd_entry : ident := $"level_ddd_entry".
Definition _level_ending_entry : ident := $"level_ending_entry".
Definition _level_hmc_entry : ident := $"level_hmc_entry".
Definition _level_intro_entry_4 : ident := $"level_intro_entry_4".
Definition _level_intro_mario_head_dizzy : ident := $"level_intro_mario_head_dizzy".
Definition _level_intro_mario_head_regular : ident := $"level_intro_mario_head_regular".
Definition _level_intro_splash_screen : ident := $"level_intro_splash_screen".
Definition _level_jrb_entry : ident := $"level_jrb_entry".
Definition _level_lll_entry : ident := $"level_lll_entry".
Definition _level_main_menu_entry_2 : ident := $"level_main_menu_entry_2".
Definition _level_main_scripts_entry : ident := $"level_main_scripts_entry".
Definition _level_pss_entry : ident := $"level_pss_entry".
Definition _level_rr_entry : ident := $"level_rr_entry".
Definition _level_sa_entry : ident := $"level_sa_entry".
Definition _level_sl_entry : ident := $"level_sl_entry".
Definition _level_ssl_entry : ident := $"level_ssl_entry".
Definition _level_thi_entry : ident := $"level_thi_entry".
Definition _level_totwc_entry : ident := $"level_totwc_entry".
Definition _level_ttc_entry : ident := $"level_ttc_entry".
Definition _level_ttm_entry : ident := $"level_ttm_entry".
Definition _level_vcutm_entry : ident := $"level_vcutm_entry".
Definition _level_wdw_entry : ident := $"level_wdw_entry".
Definition _level_wf_entry : ident := $"level_wf_entry".
Definition _level_wmotr_entry : ident := $"level_wmotr_entry".
Definition _line : ident := $"line".
Definition _loadtile : ident := $"loadtile".
Definition _loadtlut : ident := $"loadtlut".
Definition _lodscale : ident := $"lodscale".
Definition _lvl_init_from_save_file : ident := $"lvl_init_from_save_file".
Definition _mad_piano_geo : ident := $"mad_piano_geo".
Definition _main : ident := $"main".
Definition _manta_seg5_geo_05008D14 : ident := $"manta_seg5_geo_05008D14".
Definition _mario_geo : ident := $"mario_geo".
Definition _marios_cap_geo : ident := $"marios_cap_geo".
Definition _marios_metal_cap_geo : ident := $"marios_metal_cap_geo".
Definition _marios_wing_cap_geo : ident := $"marios_wing_cap_geo".
Definition _marios_winged_metal_cap_geo : ident := $"marios_winged_metal_cap_geo".
Definition _masks : ident := $"masks".
Definition _maskt : ident := $"maskt".
Definition _metal_box_dl : ident := $"metal_box_dl".
Definition _metal_box_geo : ident := $"metal_box_geo".
Definition _metallic_ball_geo : ident := $"metallic_ball_geo".
Definition _mips_geo : ident := $"mips_geo".
Definition _mist_geo : ident := $"mist_geo".
Definition _moneybag_geo : ident := $"moneybag_geo".
Definition _monty_mole_geo : ident := $"monty_mole_geo".
Definition _monty_mole_hole_seg5_dl_05000840 : ident := $"monty_mole_hole_seg5_dl_05000840".
Definition _mr_blizzard_geo : ident := $"mr_blizzard_geo".
Definition _mr_blizzard_hidden_geo : ident := $"mr_blizzard_hidden_geo".
Definition _mr_i_geo : ident := $"mr_i_geo".
Definition _mr_i_iris_geo : ident := $"mr_i_iris_geo".
Definition _ms : ident := $"ms".
Definition _mt : ident := $"mt".
Definition _mushroom_1up_geo : ident := $"mushroom_1up_geo".
Definition _muxs0 : ident := $"muxs0".
Definition _muxs1 : ident := $"muxs1".
Definition _mw_index : ident := $"mw_index".
Definition _number : ident := $"number".
Definition _number_geo : ident := $"number_geo".
Definition _on : ident := $"on".
Definition _pad : ident := $"pad".
Definition _pad0 : ident := $"pad0".
Definition _pad1 : ident := $"pad1".
Definition _pad2 : ident := $"pad2".
Definition _palette : ident := $"palette".
Definition _par : ident := $"par".
Definition _param : ident := $"param".
Definition _peach_geo : ident := $"peach_geo".
Definition _pebble_seg3_dl_0301CB00 : ident := $"pebble_seg3_dl_0301CB00".
Definition _penguin_geo : ident := $"penguin_geo".
Definition _perspnorm : ident := $"perspnorm".
Definition _piranha_plant_geo : ident := $"piranha_plant_geo".
Definition _pokey_body_part_geo : ident := $"pokey_body_part_geo".
Definition _pokey_head_geo : ident := $"pokey_head_geo".
Definition _popmtx : ident := $"popmtx".
Definition _prim_level : ident := $"prim_level".
Definition _prim_min_level : ident := $"prim_min_level".
Definition _purple_marble_geo : ident := $"purple_marble_geo".
Definition _purple_switch_geo : ident := $"purple_switch_geo".
Definition _red_coin_geo : ident := $"red_coin_geo".
Definition _red_coin_no_shadow_geo : ident := $"red_coin_no_shadow_geo".
Definition _red_flame_geo : ident := $"red_flame_geo".
Definition _red_flame_shadow_geo : ident := $"red_flame_shadow_geo".
Definition _s : ident := $"s".
Definition _sand_seg3_dl_0302BCD0 : ident := $"sand_seg3_dl_0302BCD0".
Definition _scale : ident := $"scale".
Definition _script_L1 : ident := $"script_L1".
Definition _script_L2 : ident := $"script_L2".
Definition _script_L5 : ident := $"script_L5".
Definition _script_exec_bbh : ident := $"script_exec_bbh".
Definition _script_exec_bitdw : ident := $"script_exec_bitdw".
Definition _script_exec_bitfs : ident := $"script_exec_bitfs".
Definition _script_exec_bits : ident := $"script_exec_bits".
Definition _script_exec_bob : ident := $"script_exec_bob".
Definition _script_exec_bowser_1 : ident := $"script_exec_bowser_1".
Definition _script_exec_bowser_2 : ident := $"script_exec_bowser_2".
Definition _script_exec_bowser_3 : ident := $"script_exec_bowser_3".
Definition _script_exec_castle_courtyard : ident := $"script_exec_castle_courtyard".
Definition _script_exec_castle_grounds : ident := $"script_exec_castle_grounds".
Definition _script_exec_castle_inside : ident := $"script_exec_castle_inside".
Definition _script_exec_ccm : ident := $"script_exec_ccm".
Definition _script_exec_cotmc : ident := $"script_exec_cotmc".
Definition _script_exec_ddd : ident := $"script_exec_ddd".
Definition _script_exec_ending : ident := $"script_exec_ending".
Definition _script_exec_hmc : ident := $"script_exec_hmc".
Definition _script_exec_jrb : ident := $"script_exec_jrb".
Definition _script_exec_level_table : ident := $"script_exec_level_table".
Definition _script_exec_lll : ident := $"script_exec_lll".
Definition _script_exec_pss : ident := $"script_exec_pss".
Definition _script_exec_rr : ident := $"script_exec_rr".
Definition _script_exec_sa : ident := $"script_exec_sa".
Definition _script_exec_sl : ident := $"script_exec_sl".
Definition _script_exec_ssl : ident := $"script_exec_ssl".
Definition _script_exec_thi : ident := $"script_exec_thi".
Definition _script_exec_totwc : ident := $"script_exec_totwc".
Definition _script_exec_ttc : ident := $"script_exec_ttc".
Definition _script_exec_ttm : ident := $"script_exec_ttm".
Definition _script_exec_vcutm : ident := $"script_exec_vcutm".
Definition _script_exec_wdw : ident := $"script_exec_wdw".
Definition _script_exec_wf : ident := $"script_exec_wf".
Definition _script_exec_wmotr : ident := $"script_exec_wmotr".
Definition _script_func_global_1 : ident := $"script_func_global_1".
Definition _script_func_global_10 : ident := $"script_func_global_10".
Definition _script_func_global_11 : ident := $"script_func_global_11".
Definition _script_func_global_12 : ident := $"script_func_global_12".
Definition _script_func_global_13 : ident := $"script_func_global_13".
Definition _script_func_global_14 : ident := $"script_func_global_14".
Definition _script_func_global_15 : ident := $"script_func_global_15".
Definition _script_func_global_16 : ident := $"script_func_global_16".
Definition _script_func_global_17 : ident := $"script_func_global_17".
Definition _script_func_global_18 : ident := $"script_func_global_18".
Definition _script_func_global_2 : ident := $"script_func_global_2".
Definition _script_func_global_3 : ident := $"script_func_global_3".
Definition _script_func_global_4 : ident := $"script_func_global_4".
Definition _script_func_global_5 : ident := $"script_func_global_5".
Definition _script_func_global_6 : ident := $"script_func_global_6".
Definition _script_func_global_7 : ident := $"script_func_global_7".
Definition _script_func_global_8 : ident := $"script_func_global_8".
Definition _script_func_global_9 : ident := $"script_func_global_9".
Definition _scuttlebug_geo : ident := $"scuttlebug_geo".
Definition _seaweed_geo : ident := $"seaweed_geo".
Definition _segment : ident := $"segment".
Definition _setcolor : ident := $"setcolor".
Definition _setcombine : ident := $"setcombine".
Definition _setimg : ident := $"setimg".
Definition _setothermodeH : ident := $"setothermodeH".
Definition _setothermodeL : ident := $"setothermodeL".
Definition _settile : ident := $"settile".
Definition _settilesize : ident := $"settilesize".
Definition _sft : ident := $"sft".
Definition _sh : ident := $"sh".
Definition _shifts : ident := $"shifts".
Definition _shiftt : ident := $"shiftt".
Definition _siz : ident := $"siz".
Definition _skeeter_geo : ident := $"skeeter_geo".
Definition _sl : ident := $"sl".
Definition _small_key_geo : ident := $"small_key_geo".
Definition _small_water_splash_geo : ident := $"small_water_splash_geo".
Definition _smoke_geo : ident := $"smoke_geo".
Definition _snufit_geo : ident := $"snufit_geo".
Definition _sparkles_animation_geo : ident := $"sparkles_animation_geo".
Definition _sparkles_geo : ident := $"sparkles_geo".
Definition _spindrift_geo : ident := $"spindrift_geo".
Definition _spiny_ball_geo : ident := $"spiny_ball_geo".
Definition _spiny_geo : ident := $"spiny_geo".
Definition _star_geo : ident := $"star_geo".
Definition _sushi_geo : ident := $"sushi_geo".
Definition _swoop_geo : ident := $"swoop_geo".
Definition _t : ident := $"t".
Definition _texture : ident := $"texture".
Definition _th : ident := $"th".
Definition _thwomp_geo : ident := $"thwomp_geo".
Definition _tile : ident := $"tile".
Definition _tl : ident := $"tl".
Definition _tmem : ident := $"tmem".
Definition _toad_geo : ident := $"toad_geo".
Definition _transparent_star_geo : ident := $"transparent_star_geo".
Definition _treasure_chest_base_geo : ident := $"treasure_chest_base_geo".
Definition _treasure_chest_lid_geo : ident := $"treasure_chest_lid_geo".
Definition _tri : ident := $"tri".
Definition _tweester_geo : ident := $"tweester_geo".
Definition _ukiki_geo : ident := $"ukiki_geo".
Definition _unagi_geo : ident := $"unagi_geo".
Definition _v : ident := $"v".
Definition _w0 : ident := $"w0".
Definition _w1 : ident := $"w1".
Definition _water_bomb_geo : ident := $"water_bomb_geo".
Definition _water_bomb_shadow_geo : ident := $"water_bomb_shadow_geo".
Definition _water_mine_geo : ident := $"water_mine_geo".
Definition _water_ring_geo : ident := $"water_ring_geo".
Definition _water_splash_geo : ident := $"water_splash_geo".
Definition _wave_trail_geo : ident := $"wave_trail_geo".
Definition _wd : ident := $"wd".
Definition _whirlpool_seg5_dl_05013CB8 : ident := $"whirlpool_seg5_dl_05013CB8".
Definition _white_particle_dl : ident := $"white_particle_dl".
Definition _white_particle_geo : ident := $"white_particle_geo".
Definition _white_particle_small_dl : ident := $"white_particle_small_dl".
Definition _white_puff_geo : ident := $"white_puff_geo".
Definition _whomp_geo : ident := $"whomp_geo".
Definition _wiggler_body_geo : ident := $"wiggler_body_geo".
Definition _wiggler_head_geo : ident := $"wiggler_head_geo".
Definition _wooden_post_geo : ident := $"wooden_post_geo".
Definition _wooden_signpost_geo : ident := $"wooden_signpost_geo".
Definition _words : ident := $"words".
Definition _x0 : ident := $"x0".
Definition _x0frac : ident := $"x0frac".
Definition _x1 : ident := $"x1".
Definition _x1frac : ident := $"x1frac".
Definition _y0 : ident := $"y0".
Definition _y0frac : ident := $"y0frac".
Definition _y1 : ident := $"y1".
Definition _y1frac : ident := $"y1frac".
Definition _yellow_coin_geo : ident := $"yellow_coin_geo".
Definition _yellow_coin_no_shadow_geo : ident := $"yellow_coin_no_shadow_geo".
Definition _yellow_sphere_geo : ident := $"yellow_sphere_geo".
Definition _yoshi_egg_geo : ident := $"yoshi_egg_geo".
Definition _yoshi_geo : ident := $"yoshi_geo".

Definition v__common1_mio0SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__common1_mio0SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__common1_geoSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__common1_geoSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group0_mio0SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group0_mio0SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group0_geoSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__group0_geoSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__behaviorSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__behaviorSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__menuSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__menuSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__introSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__introSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__bbhSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__bbhSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__ccmSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__ccmSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__castle_insideSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__castle_insideSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__hmcSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__hmcSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__sslSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__sslSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__bobSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__bobSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__slSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__slSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__wdwSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__wdwSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__jrbSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__jrbSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__thiSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__thiSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__ttcSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__ttcSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__rrSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__rrSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__castle_groundsSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__castle_groundsSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__bitdwSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__bitdwSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__vcutmSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__vcutmSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__bitfsSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__bitfsSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__saSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__saSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__bitsSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__bitsSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__lllSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__lllSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__dddSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__dddSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__wfSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__wfSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__endingSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__endingSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__castle_courtyardSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__castle_courtyardSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__pssSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__pssSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__cotmcSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__cotmcSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__totwcSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__totwcSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__bowser_1SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__bowser_1SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__wmotrSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__wmotrSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__bowser_2SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__bowser_2SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__bowser_3SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__bowser_3SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__ttmSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__ttmSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_dAmpGeo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_blue_coin_switch_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_black_bobomb_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bobomb_buddy_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bowling_ball_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bowling_ball_track_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_breakable_box_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_breakable_box_small_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_cannon_barrel_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_cannon_base_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_cannon_lid_seg8_dl_080048E0 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_checkerboard_platform_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_chuckya_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_exclamation_box_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_exclamation_box_outline_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_exclamation_box_outline_seg8_dl_08025F08 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_flyguy_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_goomba_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_heart_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_koopa_shell_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_metal_box_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_metal_box_dl := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_purple_switch_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_fish_shadow_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_fish_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bowser_key_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bowser_key_cutscene_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_butterfly_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_yellow_coin_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_yellow_coin_no_shadow_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_blue_coin_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_blue_coin_no_shadow_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_red_coin_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_red_coin_no_shadow_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_dirt_animation_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_cartoon_star_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_explosion_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_red_flame_shadow_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_red_flame_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_blue_flame_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_leaves_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_marios_cap_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_marios_metal_cap_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_marios_wing_cap_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_marios_winged_metal_cap_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_mist_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_white_puff_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_mushroom_1up_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_number_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_pebble_seg3_dl_0301CB00 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sand_seg3_dl_0302BCD0 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_star_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_transparent_star_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_white_particle_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_white_particle_dl := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wooden_signpost_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bubble_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_purple_marble_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_burn_smoke_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_mario_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sparkles_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sparkles_animation_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_small_water_splash_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_smoke_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_water_splash_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_idle_water_wave_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wave_trail_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_white_particle_small_dl := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bullet_bill_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_heave_ho_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_hoot_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_thwomp_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_yellow_sphere_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_yoshi_egg_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_blargg_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bully_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bully_boss_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_king_bobomb_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_water_bomb_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_water_bomb_shadow_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_clam_shell_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_manta_seg5_geo_05008D14 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sushi_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_unagi_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_whirlpool_seg5_dl_05013CB8 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_eyerok_left_hand_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_eyerok_right_hand_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_klepto_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_pokey_head_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_pokey_body_part_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_tweester_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_fwoosh_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_monty_mole_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_monty_mole_hole_seg5_dl_05000840 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_ukiki_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_penguin_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_mr_blizzard_hidden_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_mr_blizzard_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_spindrift_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_cap_switch_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_cap_switch_exclamation_seg5_dl_05002E00 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_cap_switch_base_seg5_dl_05003120 := {|
  gvar_info := (tarray (Tunion __549 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_boo_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bookend_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bookend_part_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_haunted_chair_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_haunted_cage_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_mad_piano_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_small_key_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_birds_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_peach_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_yoshi_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bubba_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_enemy_lakitu_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_spiny_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_spiny_ball_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wiggler_body_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wiggler_head_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bowser_bomb_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bowser_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bowser_geo_no_shadow := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bowser_flames_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_invisible_bowser_accessory_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bowser_impact_smoke_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_bub_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_cyan_fish_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_seaweed_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_skeeter_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_treasure_chest_base_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_treasure_chest_lid_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_water_mine_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_water_ring_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_metallic_ball_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_chain_chomp_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_koopa_without_shell_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_koopa_with_shell_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_koopa_flag_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_piranha_plant_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_wooden_post_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_whomp_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_boo_castle_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_lakitu_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_mips_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_toad_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_chilly_chief_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_chilly_chief_big_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_moneybag_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_dorrie_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_mr_i_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_mr_i_iris_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_scuttlebug_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_snufit_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_swoop_geo := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_main_menu_entry_2 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_intro_splash_screen := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_intro_mario_head_regular := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_intro_mario_head_dizzy := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_intro_entry_4 := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_bbh_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_ccm_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_castle_inside_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_hmc_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_ssl_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_bob_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_sl_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_wdw_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_jrb_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_thi_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_ttc_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_rr_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_castle_grounds_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_bitdw_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_vcutm_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_bitfs_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_sa_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_bits_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_lll_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_ddd_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_wf_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_ending_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_castle_courtyard_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_pss_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_cotmc_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_totwc_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_bowser_1_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_wmotr_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_bowser_2_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_bowser_3_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_ttm_entry := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_main_scripts_entry := {|
  gvar_info := (tarray tuint 138);
  gvar_init := (Init_int32 (Int.repr 403439620) ::
                Init_addrof __group0_mio0SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __group0_mio0SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 403439619) ::
                Init_addrof __common1_mio0SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __common1_mio0SegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 386662423) ::
                Init_addrof __group0_geoSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __group0_geoSegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 386662422) ::
                Init_addrof __common1_geoSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __common1_geoSegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 386662419) ::
                Init_addrof __behaviorSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __behaviorSegmentRomEnd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 486801408) ::
                Init_int32 (Int.repr 570949633) ::
                Init_addrof _mario_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949782) ::
                Init_addrof _smoke_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949781) ::
                Init_addrof _sparkles_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949800) ::
                Init_addrof _bubble_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949797) ::
                Init_addrof _small_water_splash_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949798) ::
                Init_addrof _idle_water_wave_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949799) ::
                Init_addrof _water_splash_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949795) ::
                Init_addrof _wave_trail_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949748) ::
                Init_addrof _yellow_coin_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949754) ::
                Init_addrof _star_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949753) ::
                Init_addrof _transparent_star_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949756) ::
                Init_addrof _wooden_signpost_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 554188964) ::
                Init_addrof _white_particle_small_dl (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949776) ::
                Init_addrof _red_flame_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949777) ::
                Init_addrof _blue_flame_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949780) ::
                Init_addrof _burn_smoke_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949794) ::
                Init_addrof _leaves_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949802) ::
                Init_addrof _purple_marble_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949817) ::
                Init_addrof _fish_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949818) ::
                Init_addrof _fish_shadow_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949775) ::
                Init_addrof _sparkles_animation_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 554188959) ::
                Init_addrof _sand_seg3_dl_0302BCD0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949819) ::
                Init_addrof _butterfly_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949788) ::
                Init_addrof _burn_smoke_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 554188961) ::
                Init_addrof _pebble_seg3_dl_0301CB00 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949774) ::
                Init_addrof _mist_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949856) ::
                Init_addrof _white_puff_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 554188958) ::
                Init_addrof _white_particle_dl (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949792) ::
                Init_addrof _white_particle_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949749) ::
                Init_addrof _yellow_coin_no_shadow_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949750) ::
                Init_addrof _blue_coin_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949751) ::
                Init_addrof _blue_coin_no_shadow_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949765) ::
                Init_addrof _marios_winged_metal_cap_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949766) ::
                Init_addrof _marios_metal_cap_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949767) ::
                Init_addrof _marios_wing_cap_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949768) ::
                Init_addrof _marios_cap_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949768) ::
                Init_addrof _marios_cap_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949832) ::
                Init_addrof _bowser_key_cutscene_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949836) ::
                Init_addrof _bowser_key_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949835) ::
                Init_addrof _red_flame_shadow_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949844) ::
                Init_addrof _mushroom_1up_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949847) ::
                Init_addrof _red_coin_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949848) ::
                Init_addrof _red_coin_no_shadow_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949851) ::
                Init_addrof _number_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949837) ::
                Init_addrof _explosion_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949770) ::
                Init_addrof _dirt_animation_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949771) ::
                Init_addrof _cartoon_star_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 503578624) ::
                Init_int32 (Int.repr 285736960) ::
                Init_addrof _lvl_init_from_save_file (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 168034304) ::
                Init_int32 (Int.repr 1048596) ::
                Init_addrof __menuSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __menuSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_main_menu_entry_2 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 101187584) ::
                Init_addrof _script_exec_level_table (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 50593793) ::
                Init_int32 (Int.repr 185074688) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr (-1)) ::
                Init_addrof _script_L2 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr (-2)) ::
                Init_addrof _goto_mario_head_regular (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr (-3)) ::
                Init_addrof _goto_mario_head_dizzy (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr (-8)) ::
                Init_addrof _script_L1 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr (-9)) ::
                Init_addrof _script_L5 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_L1 := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 17825812) ::
                Init_addrof __introSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __introSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_intro_splash_screen (Ptrofs.repr 0) ::
                nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_L2 := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 17825806) ::
                Init_addrof __endingSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __endingSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_ending_entry (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_goto_mario_head_regular := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 17825812) ::
                Init_addrof __introSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __introSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_intro_mario_head_regular (Ptrofs.repr 0) ::
                nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_goto_mario_head_dizzy := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 17825812) ::
                Init_addrof __introSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __introSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_intro_mario_head_dizzy (Ptrofs.repr 0) ::
                nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_L5 := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 17825812) ::
                Init_addrof __introSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __introSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_intro_entry_4 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_level_table := {|
  gvar_info := (tarray tuint 95);
  gvar_init := (Init_int32 (Int.repr 1006895363) ::
                Init_int32 (Int.repr 202113536) :: Init_int32 (Int.repr 4) ::
                Init_addrof _script_exec_bbh (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) :: Init_int32 (Int.repr 5) ::
                Init_addrof _script_exec_ccm (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) :: Init_int32 (Int.repr 6) ::
                Init_addrof _script_exec_castle_inside (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) :: Init_int32 (Int.repr 7) ::
                Init_addrof _script_exec_hmc (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) :: Init_int32 (Int.repr 8) ::
                Init_addrof _script_exec_ssl (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) :: Init_int32 (Int.repr 9) ::
                Init_addrof _script_exec_bob (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 10) ::
                Init_addrof _script_exec_sl (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 11) ::
                Init_addrof _script_exec_wdw (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 12) ::
                Init_addrof _script_exec_jrb (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 13) ::
                Init_addrof _script_exec_thi (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 14) ::
                Init_addrof _script_exec_ttc (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 15) ::
                Init_addrof _script_exec_rr (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 16) ::
                Init_addrof _script_exec_castle_grounds (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 17) ::
                Init_addrof _script_exec_bitdw (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 18) ::
                Init_addrof _script_exec_vcutm (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 19) ::
                Init_addrof _script_exec_bitfs (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 20) ::
                Init_addrof _script_exec_sa (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 21) ::
                Init_addrof _script_exec_bits (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 22) ::
                Init_addrof _script_exec_lll (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 23) ::
                Init_addrof _script_exec_ddd (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 24) ::
                Init_addrof _script_exec_wf (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 25) ::
                Init_addrof _script_exec_ending (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 26) ::
                Init_addrof _script_exec_castle_courtyard (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 27) ::
                Init_addrof _script_exec_pss (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 28) ::
                Init_addrof _script_exec_cotmc (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 29) ::
                Init_addrof _script_exec_totwc (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 30) ::
                Init_addrof _script_exec_bowser_1 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 31) ::
                Init_addrof _script_exec_wmotr (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 33) ::
                Init_addrof _script_exec_bowser_2 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 34) ::
                Init_addrof _script_exec_bowser_3 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 202113536) ::
                Init_int32 (Int.repr 36) ::
                Init_addrof _script_exec_ttm (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 33816576) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_bbh := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __bbhSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __bbhSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_bbh_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_ccm := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __ccmSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __ccmSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_ccm_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_castle_inside := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __castle_insideSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __castle_insideSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_castle_inside_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_hmc := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __hmcSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __hmcSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_hmc_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_ssl := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __sslSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __sslSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_ssl_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_bob := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __bobSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __bobSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_bob_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_sl := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __slSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __slSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_sl_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_wdw := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __wdwSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __wdwSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_wdw_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_jrb := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __jrbSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __jrbSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_jrb_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_thi := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __thiSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __thiSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_thi_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_ttc := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __ttcSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __ttcSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_ttc_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_rr := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __rrSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __rrSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_rr_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_castle_grounds := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __castle_groundsSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __castle_groundsSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_castle_grounds_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_bitdw := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __bitdwSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __bitdwSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_bitdw_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_vcutm := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __vcutmSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __vcutmSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_vcutm_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_bitfs := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __bitfsSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __bitfsSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_bitfs_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_sa := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __saSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __saSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_sa_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_bits := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __bitsSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __bitsSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_bits_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_lll := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __lllSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __lllSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_lll_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_ddd := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __dddSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __dddSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_ddd_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_wf := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __wfSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __wfSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_wf_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_ending := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __endingSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __endingSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_ending_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_castle_courtyard := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __castle_courtyardSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __castle_courtyardSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_castle_courtyard_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_pss := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __pssSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __pssSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_pss_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_cotmc := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __cotmcSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __cotmcSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_cotmc_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_totwc := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __totwcSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __totwcSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_totwc_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_bowser_1 := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __bowser_1SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __bowser_1SegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_bowser_1_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_wmotr := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __wmotrSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __wmotrSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_wmotr_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_bowser_2 := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __bowser_2SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __bowser_2SegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_bowser_2_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_bowser_3 := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __bowser_3SegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __bowser_3SegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_bowser_3_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_exec_ttm := {|
  gvar_info := (tarray tuint 5);
  gvar_init := (Init_int32 (Int.repr 1048590) ::
                Init_addrof __ttmSegmentRomStart (Ptrofs.repr 0) ::
                Init_addrof __ttmSegmentRomEnd (Ptrofs.repr 0) ::
                Init_addrof _level_ttm_entry (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_global_1 := {|
  gvar_info := (tarray tuint 47);
  gvar_init := (Init_int32 (Int.repr 570949772) ::
                Init_addrof _blue_coin_switch_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949826) ::
                Init_addrof _dAmpGeo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949839) ::
                Init_addrof _purple_switch_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949834) ::
                Init_addrof _checkerboard_platform_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949761) ::
                Init_addrof _breakable_box_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949762) ::
                Init_addrof _breakable_box_small_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949763) ::
                Init_addrof _exclamation_box_outline_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949769) ::
                Init_addrof _exclamation_box_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949824) ::
                Init_addrof _goomba_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 554188932) ::
                Init_addrof _exclamation_box_outline_seg8_dl_08025F08 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949822) ::
                Init_addrof _koopa_shell_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949849) ::
                Init_addrof _metal_box_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 554176730) ::
                Init_addrof _metal_box_dl (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949820) ::
                Init_addrof _black_bobomb_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949827) ::
                Init_addrof _bobomb_buddy_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 554176713) ::
                Init_addrof _cannon_lid_seg8_dl_080048E0 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949812) ::
                Init_addrof _bowling_ball_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949759) ::
                Init_addrof _cannon_barrel_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949760) ::
                Init_addrof _cannon_base_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949752) ::
                Init_addrof _heart_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949852) ::
                Init_addrof _flyguy_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949855) ::
                Init_addrof _chuckya_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949857) ::
                Init_addrof _bowling_ball_track_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_global_2 := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 570949716) ::
                Init_addrof _bullet_bill_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949717) ::
                Init_addrof _yellow_sphere_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949718) ::
                Init_addrof _hoot_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949719) ::
                Init_addrof _yoshi_egg_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949720) ::
                Init_addrof _thwomp_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949721) ::
                Init_addrof _heave_ho_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_global_3 := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 570949716) ::
                Init_addrof _blargg_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949718) ::
                Init_addrof _bully_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949719) ::
                Init_addrof _bully_boss_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_global_4 := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 570949716) ::
                Init_addrof _water_bomb_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949717) ::
                Init_addrof _water_bomb_shadow_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949718) ::
                Init_addrof _king_bobomb_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_global_5 := {|
  gvar_info := (tarray tuint 11);
  gvar_init := (Init_int32 (Int.repr 570949716) ::
                Init_addrof _manta_seg5_geo_05008D14 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949717) ::
                Init_addrof _unagi_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949718) ::
                Init_addrof _sushi_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 554192983) ::
                Init_addrof _whirlpool_seg5_dl_05013CB8 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949720) ::
                Init_addrof _clam_shell_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_global_6 := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 570949716) ::
                Init_addrof _pokey_head_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949717) ::
                Init_addrof _pokey_body_part_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949718) ::
                Init_addrof _tweester_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949719) ::
                Init_addrof _klepto_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949720) ::
                Init_addrof _eyerok_left_hand_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949721) ::
                Init_addrof _eyerok_right_hand_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_global_7 := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 554197076) ::
                Init_addrof _monty_mole_hole_seg5_dl_05000840 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949717) ::
                Init_addrof _monty_mole_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949718) ::
                Init_addrof _ukiki_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949719) ::
                Init_addrof _fwoosh_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_global_8 := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 570949716) ::
                Init_addrof _spindrift_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949717) ::
                Init_addrof _mr_blizzard_hidden_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949718) ::
                Init_addrof _mr_blizzard_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949719) ::
                Init_addrof _penguin_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_global_9 := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 554188884) ::
                Init_addrof _cap_switch_exclamation_seg5_dl_05002E00 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949717) ::
                Init_addrof _cap_switch_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 554176598) ::
                Init_addrof _cap_switch_base_seg5_dl_05003120 (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_global_10 := {|
  gvar_info := (tarray tuint 15);
  gvar_init := (Init_int32 (Int.repr 570949716) ::
                Init_addrof _boo_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949717) ::
                Init_addrof _small_key_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949718) ::
                Init_addrof _haunted_chair_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949719) ::
                Init_addrof _mad_piano_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949720) ::
                Init_addrof _bookend_part_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949721) ::
                Init_addrof _bookend_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949722) ::
                Init_addrof _haunted_cage_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_global_11 := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 570949716) ::
                Init_addrof _birds_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949854) ::
                Init_addrof _peach_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949717) ::
                Init_addrof _yoshi_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_global_12 := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 570949716) ::
                Init_addrof _enemy_lakitu_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949717) ::
                Init_addrof _spiny_ball_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949718) ::
                Init_addrof _spiny_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949719) ::
                Init_addrof _wiggler_head_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949720) ::
                Init_addrof _wiggler_body_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949721) ::
                Init_addrof _bubba_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_global_13 := {|
  gvar_info := (tarray tuint 15);
  gvar_init := (Init_int32 (Int.repr 570949732) ::
                Init_addrof _bowser_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949733) ::
                Init_addrof _bowser_bomb_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949811) ::
                Init_addrof _bowser_bomb_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949734) ::
                Init_addrof _bowser_impact_smoke_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949735) ::
                Init_addrof _bowser_flames_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949736) ::
                Init_addrof _invisible_bowser_accessory_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949737) ::
                Init_addrof _bowser_geo_no_shadow (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_global_14 := {|
  gvar_info := (tarray tuint 17);
  gvar_init := (Init_int32 (Int.repr 570949732) ::
                Init_addrof _bub_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949733) ::
                Init_addrof _treasure_chest_base_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949734) ::
                Init_addrof _treasure_chest_lid_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949735) ::
                Init_addrof _cyan_fish_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949736) ::
                Init_addrof _water_ring_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949811) ::
                Init_addrof _water_mine_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949825) ::
                Init_addrof _seaweed_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949737) ::
                Init_addrof _skeeter_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_global_15 := {|
  gvar_info := (tarray tuint 17);
  gvar_init := (Init_int32 (Int.repr 570949732) ::
                Init_addrof _piranha_plant_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949735) ::
                Init_addrof _whomp_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949736) ::
                Init_addrof _koopa_with_shell_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949823) ::
                Init_addrof _koopa_without_shell_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949733) ::
                Init_addrof _metallic_ball_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949734) ::
                Init_addrof _chain_chomp_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949738) ::
                Init_addrof _koopa_flag_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949739) ::
                Init_addrof _wooden_post_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_global_16 := {|
  gvar_info := (tarray tuint 9);
  gvar_init := (Init_int32 (Int.repr 570949732) ::
                Init_addrof _mips_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949733) ::
                Init_addrof _boo_castle_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949734) ::
                Init_addrof _lakitu_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949853) ::
                Init_addrof _toad_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_global_17 := {|
  gvar_info := (tarray tuint 7);
  gvar_init := (Init_int32 (Int.repr 570949732) ::
                Init_addrof _chilly_chief_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949733) ::
                Init_addrof _chilly_chief_big_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949734) ::
                Init_addrof _moneybag_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_script_func_global_18 := {|
  gvar_info := (tarray tuint 13);
  gvar_init := (Init_int32 (Int.repr 570949732) ::
                Init_addrof _swoop_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949733) ::
                Init_addrof _scuttlebug_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949734) ::
                Init_addrof _mr_i_iris_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949735) ::
                Init_addrof _mr_i_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949736) ::
                Init_addrof _dorrie_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 570949838) ::
                Init_addrof _snufit_geo (Ptrofs.repr 0) ::
                Init_int32 (Int.repr 117702656) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition composites : list composite_definition :=
(Composite __469 Struct
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
 (_lvl_init_from_save_file,
   Gfun(External (EF_external "lvl_init_from_save_file"
                   (mksignature (AST.Xint16signed :: AST.Xint :: nil)
                     AST.Xint cc_default)) (tshort :: tint :: nil) tint
     cc_default)) ::
 (__common1_mio0SegmentRomStart, Gvar v__common1_mio0SegmentRomStart) ::
 (__common1_mio0SegmentRomEnd, Gvar v__common1_mio0SegmentRomEnd) ::
 (__common1_geoSegmentRomStart, Gvar v__common1_geoSegmentRomStart) ::
 (__common1_geoSegmentRomEnd, Gvar v__common1_geoSegmentRomEnd) ::
 (__group0_mio0SegmentRomStart, Gvar v__group0_mio0SegmentRomStart) ::
 (__group0_mio0SegmentRomEnd, Gvar v__group0_mio0SegmentRomEnd) ::
 (__group0_geoSegmentRomStart, Gvar v__group0_geoSegmentRomStart) ::
 (__group0_geoSegmentRomEnd, Gvar v__group0_geoSegmentRomEnd) ::
 (__behaviorSegmentRomStart, Gvar v__behaviorSegmentRomStart) ::
 (__behaviorSegmentRomEnd, Gvar v__behaviorSegmentRomEnd) ::
 (__menuSegmentRomStart, Gvar v__menuSegmentRomStart) ::
 (__menuSegmentRomEnd, Gvar v__menuSegmentRomEnd) ::
 (__introSegmentRomStart, Gvar v__introSegmentRomStart) ::
 (__introSegmentRomEnd, Gvar v__introSegmentRomEnd) ::
 (__bbhSegmentRomStart, Gvar v__bbhSegmentRomStart) ::
 (__bbhSegmentRomEnd, Gvar v__bbhSegmentRomEnd) ::
 (__ccmSegmentRomStart, Gvar v__ccmSegmentRomStart) ::
 (__ccmSegmentRomEnd, Gvar v__ccmSegmentRomEnd) ::
 (__castle_insideSegmentRomStart, Gvar v__castle_insideSegmentRomStart) ::
 (__castle_insideSegmentRomEnd, Gvar v__castle_insideSegmentRomEnd) ::
 (__hmcSegmentRomStart, Gvar v__hmcSegmentRomStart) ::
 (__hmcSegmentRomEnd, Gvar v__hmcSegmentRomEnd) ::
 (__sslSegmentRomStart, Gvar v__sslSegmentRomStart) ::
 (__sslSegmentRomEnd, Gvar v__sslSegmentRomEnd) ::
 (__bobSegmentRomStart, Gvar v__bobSegmentRomStart) ::
 (__bobSegmentRomEnd, Gvar v__bobSegmentRomEnd) ::
 (__slSegmentRomStart, Gvar v__slSegmentRomStart) ::
 (__slSegmentRomEnd, Gvar v__slSegmentRomEnd) ::
 (__wdwSegmentRomStart, Gvar v__wdwSegmentRomStart) ::
 (__wdwSegmentRomEnd, Gvar v__wdwSegmentRomEnd) ::
 (__jrbSegmentRomStart, Gvar v__jrbSegmentRomStart) ::
 (__jrbSegmentRomEnd, Gvar v__jrbSegmentRomEnd) ::
 (__thiSegmentRomStart, Gvar v__thiSegmentRomStart) ::
 (__thiSegmentRomEnd, Gvar v__thiSegmentRomEnd) ::
 (__ttcSegmentRomStart, Gvar v__ttcSegmentRomStart) ::
 (__ttcSegmentRomEnd, Gvar v__ttcSegmentRomEnd) ::
 (__rrSegmentRomStart, Gvar v__rrSegmentRomStart) ::
 (__rrSegmentRomEnd, Gvar v__rrSegmentRomEnd) ::
 (__castle_groundsSegmentRomStart, Gvar v__castle_groundsSegmentRomStart) ::
 (__castle_groundsSegmentRomEnd, Gvar v__castle_groundsSegmentRomEnd) ::
 (__bitdwSegmentRomStart, Gvar v__bitdwSegmentRomStart) ::
 (__bitdwSegmentRomEnd, Gvar v__bitdwSegmentRomEnd) ::
 (__vcutmSegmentRomStart, Gvar v__vcutmSegmentRomStart) ::
 (__vcutmSegmentRomEnd, Gvar v__vcutmSegmentRomEnd) ::
 (__bitfsSegmentRomStart, Gvar v__bitfsSegmentRomStart) ::
 (__bitfsSegmentRomEnd, Gvar v__bitfsSegmentRomEnd) ::
 (__saSegmentRomStart, Gvar v__saSegmentRomStart) ::
 (__saSegmentRomEnd, Gvar v__saSegmentRomEnd) ::
 (__bitsSegmentRomStart, Gvar v__bitsSegmentRomStart) ::
 (__bitsSegmentRomEnd, Gvar v__bitsSegmentRomEnd) ::
 (__lllSegmentRomStart, Gvar v__lllSegmentRomStart) ::
 (__lllSegmentRomEnd, Gvar v__lllSegmentRomEnd) ::
 (__dddSegmentRomStart, Gvar v__dddSegmentRomStart) ::
 (__dddSegmentRomEnd, Gvar v__dddSegmentRomEnd) ::
 (__wfSegmentRomStart, Gvar v__wfSegmentRomStart) ::
 (__wfSegmentRomEnd, Gvar v__wfSegmentRomEnd) ::
 (__endingSegmentRomStart, Gvar v__endingSegmentRomStart) ::
 (__endingSegmentRomEnd, Gvar v__endingSegmentRomEnd) ::
 (__castle_courtyardSegmentRomStart, Gvar v__castle_courtyardSegmentRomStart) ::
 (__castle_courtyardSegmentRomEnd, Gvar v__castle_courtyardSegmentRomEnd) ::
 (__pssSegmentRomStart, Gvar v__pssSegmentRomStart) ::
 (__pssSegmentRomEnd, Gvar v__pssSegmentRomEnd) ::
 (__cotmcSegmentRomStart, Gvar v__cotmcSegmentRomStart) ::
 (__cotmcSegmentRomEnd, Gvar v__cotmcSegmentRomEnd) ::
 (__totwcSegmentRomStart, Gvar v__totwcSegmentRomStart) ::
 (__totwcSegmentRomEnd, Gvar v__totwcSegmentRomEnd) ::
 (__bowser_1SegmentRomStart, Gvar v__bowser_1SegmentRomStart) ::
 (__bowser_1SegmentRomEnd, Gvar v__bowser_1SegmentRomEnd) ::
 (__wmotrSegmentRomStart, Gvar v__wmotrSegmentRomStart) ::
 (__wmotrSegmentRomEnd, Gvar v__wmotrSegmentRomEnd) ::
 (__bowser_2SegmentRomStart, Gvar v__bowser_2SegmentRomStart) ::
 (__bowser_2SegmentRomEnd, Gvar v__bowser_2SegmentRomEnd) ::
 (__bowser_3SegmentRomStart, Gvar v__bowser_3SegmentRomStart) ::
 (__bowser_3SegmentRomEnd, Gvar v__bowser_3SegmentRomEnd) ::
 (__ttmSegmentRomStart, Gvar v__ttmSegmentRomStart) ::
 (__ttmSegmentRomEnd, Gvar v__ttmSegmentRomEnd) ::
 (_dAmpGeo, Gvar v_dAmpGeo) ::
 (_blue_coin_switch_geo, Gvar v_blue_coin_switch_geo) ::
 (_black_bobomb_geo, Gvar v_black_bobomb_geo) ::
 (_bobomb_buddy_geo, Gvar v_bobomb_buddy_geo) ::
 (_bowling_ball_geo, Gvar v_bowling_ball_geo) ::
 (_bowling_ball_track_geo, Gvar v_bowling_ball_track_geo) ::
 (_breakable_box_geo, Gvar v_breakable_box_geo) ::
 (_breakable_box_small_geo, Gvar v_breakable_box_small_geo) ::
 (_cannon_barrel_geo, Gvar v_cannon_barrel_geo) ::
 (_cannon_base_geo, Gvar v_cannon_base_geo) ::
 (_cannon_lid_seg8_dl_080048E0, Gvar v_cannon_lid_seg8_dl_080048E0) ::
 (_checkerboard_platform_geo, Gvar v_checkerboard_platform_geo) ::
 (_chuckya_geo, Gvar v_chuckya_geo) ::
 (_exclamation_box_geo, Gvar v_exclamation_box_geo) ::
 (_exclamation_box_outline_geo, Gvar v_exclamation_box_outline_geo) ::
 (_exclamation_box_outline_seg8_dl_08025F08, Gvar v_exclamation_box_outline_seg8_dl_08025F08) ::
 (_flyguy_geo, Gvar v_flyguy_geo) :: (_goomba_geo, Gvar v_goomba_geo) ::
 (_heart_geo, Gvar v_heart_geo) ::
 (_koopa_shell_geo, Gvar v_koopa_shell_geo) ::
 (_metal_box_geo, Gvar v_metal_box_geo) ::
 (_metal_box_dl, Gvar v_metal_box_dl) ::
 (_purple_switch_geo, Gvar v_purple_switch_geo) ::
 (_fish_shadow_geo, Gvar v_fish_shadow_geo) ::
 (_fish_geo, Gvar v_fish_geo) :: (_bowser_key_geo, Gvar v_bowser_key_geo) ::
 (_bowser_key_cutscene_geo, Gvar v_bowser_key_cutscene_geo) ::
 (_butterfly_geo, Gvar v_butterfly_geo) ::
 (_yellow_coin_geo, Gvar v_yellow_coin_geo) ::
 (_yellow_coin_no_shadow_geo, Gvar v_yellow_coin_no_shadow_geo) ::
 (_blue_coin_geo, Gvar v_blue_coin_geo) ::
 (_blue_coin_no_shadow_geo, Gvar v_blue_coin_no_shadow_geo) ::
 (_red_coin_geo, Gvar v_red_coin_geo) ::
 (_red_coin_no_shadow_geo, Gvar v_red_coin_no_shadow_geo) ::
 (_dirt_animation_geo, Gvar v_dirt_animation_geo) ::
 (_cartoon_star_geo, Gvar v_cartoon_star_geo) ::
 (_explosion_geo, Gvar v_explosion_geo) ::
 (_red_flame_shadow_geo, Gvar v_red_flame_shadow_geo) ::
 (_red_flame_geo, Gvar v_red_flame_geo) ::
 (_blue_flame_geo, Gvar v_blue_flame_geo) ::
 (_leaves_geo, Gvar v_leaves_geo) ::
 (_marios_cap_geo, Gvar v_marios_cap_geo) ::
 (_marios_metal_cap_geo, Gvar v_marios_metal_cap_geo) ::
 (_marios_wing_cap_geo, Gvar v_marios_wing_cap_geo) ::
 (_marios_winged_metal_cap_geo, Gvar v_marios_winged_metal_cap_geo) ::
 (_mist_geo, Gvar v_mist_geo) :: (_white_puff_geo, Gvar v_white_puff_geo) ::
 (_mushroom_1up_geo, Gvar v_mushroom_1up_geo) ::
 (_number_geo, Gvar v_number_geo) ::
 (_pebble_seg3_dl_0301CB00, Gvar v_pebble_seg3_dl_0301CB00) ::
 (_sand_seg3_dl_0302BCD0, Gvar v_sand_seg3_dl_0302BCD0) ::
 (_star_geo, Gvar v_star_geo) ::
 (_transparent_star_geo, Gvar v_transparent_star_geo) ::
 (_white_particle_geo, Gvar v_white_particle_geo) ::
 (_white_particle_dl, Gvar v_white_particle_dl) ::
 (_wooden_signpost_geo, Gvar v_wooden_signpost_geo) ::
 (_bubble_geo, Gvar v_bubble_geo) ::
 (_purple_marble_geo, Gvar v_purple_marble_geo) ::
 (_burn_smoke_geo, Gvar v_burn_smoke_geo) ::
 (_mario_geo, Gvar v_mario_geo) :: (_sparkles_geo, Gvar v_sparkles_geo) ::
 (_sparkles_animation_geo, Gvar v_sparkles_animation_geo) ::
 (_small_water_splash_geo, Gvar v_small_water_splash_geo) ::
 (_smoke_geo, Gvar v_smoke_geo) ::
 (_water_splash_geo, Gvar v_water_splash_geo) ::
 (_idle_water_wave_geo, Gvar v_idle_water_wave_geo) ::
 (_wave_trail_geo, Gvar v_wave_trail_geo) ::
 (_white_particle_small_dl, Gvar v_white_particle_small_dl) ::
 (_bullet_bill_geo, Gvar v_bullet_bill_geo) ::
 (_heave_ho_geo, Gvar v_heave_ho_geo) :: (_hoot_geo, Gvar v_hoot_geo) ::
 (_thwomp_geo, Gvar v_thwomp_geo) ::
 (_yellow_sphere_geo, Gvar v_yellow_sphere_geo) ::
 (_yoshi_egg_geo, Gvar v_yoshi_egg_geo) ::
 (_blargg_geo, Gvar v_blargg_geo) :: (_bully_geo, Gvar v_bully_geo) ::
 (_bully_boss_geo, Gvar v_bully_boss_geo) ::
 (_king_bobomb_geo, Gvar v_king_bobomb_geo) ::
 (_water_bomb_geo, Gvar v_water_bomb_geo) ::
 (_water_bomb_shadow_geo, Gvar v_water_bomb_shadow_geo) ::
 (_clam_shell_geo, Gvar v_clam_shell_geo) ::
 (_manta_seg5_geo_05008D14, Gvar v_manta_seg5_geo_05008D14) ::
 (_sushi_geo, Gvar v_sushi_geo) :: (_unagi_geo, Gvar v_unagi_geo) ::
 (_whirlpool_seg5_dl_05013CB8, Gvar v_whirlpool_seg5_dl_05013CB8) ::
 (_eyerok_left_hand_geo, Gvar v_eyerok_left_hand_geo) ::
 (_eyerok_right_hand_geo, Gvar v_eyerok_right_hand_geo) ::
 (_klepto_geo, Gvar v_klepto_geo) ::
 (_pokey_head_geo, Gvar v_pokey_head_geo) ::
 (_pokey_body_part_geo, Gvar v_pokey_body_part_geo) ::
 (_tweester_geo, Gvar v_tweester_geo) :: (_fwoosh_geo, Gvar v_fwoosh_geo) ::
 (_monty_mole_geo, Gvar v_monty_mole_geo) ::
 (_monty_mole_hole_seg5_dl_05000840, Gvar v_monty_mole_hole_seg5_dl_05000840) ::
 (_ukiki_geo, Gvar v_ukiki_geo) :: (_penguin_geo, Gvar v_penguin_geo) ::
 (_mr_blizzard_hidden_geo, Gvar v_mr_blizzard_hidden_geo) ::
 (_mr_blizzard_geo, Gvar v_mr_blizzard_geo) ::
 (_spindrift_geo, Gvar v_spindrift_geo) ::
 (_cap_switch_geo, Gvar v_cap_switch_geo) ::
 (_cap_switch_exclamation_seg5_dl_05002E00, Gvar v_cap_switch_exclamation_seg5_dl_05002E00) ::
 (_cap_switch_base_seg5_dl_05003120, Gvar v_cap_switch_base_seg5_dl_05003120) ::
 (_boo_geo, Gvar v_boo_geo) :: (_bookend_geo, Gvar v_bookend_geo) ::
 (_bookend_part_geo, Gvar v_bookend_part_geo) ::
 (_haunted_chair_geo, Gvar v_haunted_chair_geo) ::
 (_haunted_cage_geo, Gvar v_haunted_cage_geo) ::
 (_mad_piano_geo, Gvar v_mad_piano_geo) ::
 (_small_key_geo, Gvar v_small_key_geo) :: (_birds_geo, Gvar v_birds_geo) ::
 (_peach_geo, Gvar v_peach_geo) :: (_yoshi_geo, Gvar v_yoshi_geo) ::
 (_bubba_geo, Gvar v_bubba_geo) ::
 (_enemy_lakitu_geo, Gvar v_enemy_lakitu_geo) ::
 (_spiny_geo, Gvar v_spiny_geo) ::
 (_spiny_ball_geo, Gvar v_spiny_ball_geo) ::
 (_wiggler_body_geo, Gvar v_wiggler_body_geo) ::
 (_wiggler_head_geo, Gvar v_wiggler_head_geo) ::
 (_bowser_bomb_geo, Gvar v_bowser_bomb_geo) ::
 (_bowser_geo, Gvar v_bowser_geo) ::
 (_bowser_geo_no_shadow, Gvar v_bowser_geo_no_shadow) ::
 (_bowser_flames_geo, Gvar v_bowser_flames_geo) ::
 (_invisible_bowser_accessory_geo, Gvar v_invisible_bowser_accessory_geo) ::
 (_bowser_impact_smoke_geo, Gvar v_bowser_impact_smoke_geo) ::
 (_bub_geo, Gvar v_bub_geo) :: (_cyan_fish_geo, Gvar v_cyan_fish_geo) ::
 (_seaweed_geo, Gvar v_seaweed_geo) :: (_skeeter_geo, Gvar v_skeeter_geo) ::
 (_treasure_chest_base_geo, Gvar v_treasure_chest_base_geo) ::
 (_treasure_chest_lid_geo, Gvar v_treasure_chest_lid_geo) ::
 (_water_mine_geo, Gvar v_water_mine_geo) ::
 (_water_ring_geo, Gvar v_water_ring_geo) ::
 (_metallic_ball_geo, Gvar v_metallic_ball_geo) ::
 (_chain_chomp_geo, Gvar v_chain_chomp_geo) ::
 (_koopa_without_shell_geo, Gvar v_koopa_without_shell_geo) ::
 (_koopa_with_shell_geo, Gvar v_koopa_with_shell_geo) ::
 (_koopa_flag_geo, Gvar v_koopa_flag_geo) ::
 (_piranha_plant_geo, Gvar v_piranha_plant_geo) ::
 (_wooden_post_geo, Gvar v_wooden_post_geo) ::
 (_whomp_geo, Gvar v_whomp_geo) ::
 (_boo_castle_geo, Gvar v_boo_castle_geo) ::
 (_lakitu_geo, Gvar v_lakitu_geo) :: (_mips_geo, Gvar v_mips_geo) ::
 (_toad_geo, Gvar v_toad_geo) ::
 (_chilly_chief_geo, Gvar v_chilly_chief_geo) ::
 (_chilly_chief_big_geo, Gvar v_chilly_chief_big_geo) ::
 (_moneybag_geo, Gvar v_moneybag_geo) :: (_dorrie_geo, Gvar v_dorrie_geo) ::
 (_mr_i_geo, Gvar v_mr_i_geo) :: (_mr_i_iris_geo, Gvar v_mr_i_iris_geo) ::
 (_scuttlebug_geo, Gvar v_scuttlebug_geo) ::
 (_snufit_geo, Gvar v_snufit_geo) :: (_swoop_geo, Gvar v_swoop_geo) ::
 (_level_main_menu_entry_2, Gvar v_level_main_menu_entry_2) ::
 (_level_intro_splash_screen, Gvar v_level_intro_splash_screen) ::
 (_level_intro_mario_head_regular, Gvar v_level_intro_mario_head_regular) ::
 (_level_intro_mario_head_dizzy, Gvar v_level_intro_mario_head_dizzy) ::
 (_level_intro_entry_4, Gvar v_level_intro_entry_4) ::
 (_level_bbh_entry, Gvar v_level_bbh_entry) ::
 (_level_ccm_entry, Gvar v_level_ccm_entry) ::
 (_level_castle_inside_entry, Gvar v_level_castle_inside_entry) ::
 (_level_hmc_entry, Gvar v_level_hmc_entry) ::
 (_level_ssl_entry, Gvar v_level_ssl_entry) ::
 (_level_bob_entry, Gvar v_level_bob_entry) ::
 (_level_sl_entry, Gvar v_level_sl_entry) ::
 (_level_wdw_entry, Gvar v_level_wdw_entry) ::
 (_level_jrb_entry, Gvar v_level_jrb_entry) ::
 (_level_thi_entry, Gvar v_level_thi_entry) ::
 (_level_ttc_entry, Gvar v_level_ttc_entry) ::
 (_level_rr_entry, Gvar v_level_rr_entry) ::
 (_level_castle_grounds_entry, Gvar v_level_castle_grounds_entry) ::
 (_level_bitdw_entry, Gvar v_level_bitdw_entry) ::
 (_level_vcutm_entry, Gvar v_level_vcutm_entry) ::
 (_level_bitfs_entry, Gvar v_level_bitfs_entry) ::
 (_level_sa_entry, Gvar v_level_sa_entry) ::
 (_level_bits_entry, Gvar v_level_bits_entry) ::
 (_level_lll_entry, Gvar v_level_lll_entry) ::
 (_level_ddd_entry, Gvar v_level_ddd_entry) ::
 (_level_wf_entry, Gvar v_level_wf_entry) ::
 (_level_ending_entry, Gvar v_level_ending_entry) ::
 (_level_castle_courtyard_entry, Gvar v_level_castle_courtyard_entry) ::
 (_level_pss_entry, Gvar v_level_pss_entry) ::
 (_level_cotmc_entry, Gvar v_level_cotmc_entry) ::
 (_level_totwc_entry, Gvar v_level_totwc_entry) ::
 (_level_bowser_1_entry, Gvar v_level_bowser_1_entry) ::
 (_level_wmotr_entry, Gvar v_level_wmotr_entry) ::
 (_level_bowser_2_entry, Gvar v_level_bowser_2_entry) ::
 (_level_bowser_3_entry, Gvar v_level_bowser_3_entry) ::
 (_level_ttm_entry, Gvar v_level_ttm_entry) ::
 (_level_main_scripts_entry, Gvar v_level_main_scripts_entry) ::
 (_script_L1, Gvar v_script_L1) :: (_script_L2, Gvar v_script_L2) ::
 (_goto_mario_head_regular, Gvar v_goto_mario_head_regular) ::
 (_goto_mario_head_dizzy, Gvar v_goto_mario_head_dizzy) ::
 (_script_L5, Gvar v_script_L5) ::
 (_script_exec_level_table, Gvar v_script_exec_level_table) ::
 (_script_exec_bbh, Gvar v_script_exec_bbh) ::
 (_script_exec_ccm, Gvar v_script_exec_ccm) ::
 (_script_exec_castle_inside, Gvar v_script_exec_castle_inside) ::
 (_script_exec_hmc, Gvar v_script_exec_hmc) ::
 (_script_exec_ssl, Gvar v_script_exec_ssl) ::
 (_script_exec_bob, Gvar v_script_exec_bob) ::
 (_script_exec_sl, Gvar v_script_exec_sl) ::
 (_script_exec_wdw, Gvar v_script_exec_wdw) ::
 (_script_exec_jrb, Gvar v_script_exec_jrb) ::
 (_script_exec_thi, Gvar v_script_exec_thi) ::
 (_script_exec_ttc, Gvar v_script_exec_ttc) ::
 (_script_exec_rr, Gvar v_script_exec_rr) ::
 (_script_exec_castle_grounds, Gvar v_script_exec_castle_grounds) ::
 (_script_exec_bitdw, Gvar v_script_exec_bitdw) ::
 (_script_exec_vcutm, Gvar v_script_exec_vcutm) ::
 (_script_exec_bitfs, Gvar v_script_exec_bitfs) ::
 (_script_exec_sa, Gvar v_script_exec_sa) ::
 (_script_exec_bits, Gvar v_script_exec_bits) ::
 (_script_exec_lll, Gvar v_script_exec_lll) ::
 (_script_exec_ddd, Gvar v_script_exec_ddd) ::
 (_script_exec_wf, Gvar v_script_exec_wf) ::
 (_script_exec_ending, Gvar v_script_exec_ending) ::
 (_script_exec_castle_courtyard, Gvar v_script_exec_castle_courtyard) ::
 (_script_exec_pss, Gvar v_script_exec_pss) ::
 (_script_exec_cotmc, Gvar v_script_exec_cotmc) ::
 (_script_exec_totwc, Gvar v_script_exec_totwc) ::
 (_script_exec_bowser_1, Gvar v_script_exec_bowser_1) ::
 (_script_exec_wmotr, Gvar v_script_exec_wmotr) ::
 (_script_exec_bowser_2, Gvar v_script_exec_bowser_2) ::
 (_script_exec_bowser_3, Gvar v_script_exec_bowser_3) ::
 (_script_exec_ttm, Gvar v_script_exec_ttm) ::
 (_script_func_global_1, Gvar v_script_func_global_1) ::
 (_script_func_global_2, Gvar v_script_func_global_2) ::
 (_script_func_global_3, Gvar v_script_func_global_3) ::
 (_script_func_global_4, Gvar v_script_func_global_4) ::
 (_script_func_global_5, Gvar v_script_func_global_5) ::
 (_script_func_global_6, Gvar v_script_func_global_6) ::
 (_script_func_global_7, Gvar v_script_func_global_7) ::
 (_script_func_global_8, Gvar v_script_func_global_8) ::
 (_script_func_global_9, Gvar v_script_func_global_9) ::
 (_script_func_global_10, Gvar v_script_func_global_10) ::
 (_script_func_global_11, Gvar v_script_func_global_11) ::
 (_script_func_global_12, Gvar v_script_func_global_12) ::
 (_script_func_global_13, Gvar v_script_func_global_13) ::
 (_script_func_global_14, Gvar v_script_func_global_14) ::
 (_script_func_global_15, Gvar v_script_func_global_15) ::
 (_script_func_global_16, Gvar v_script_func_global_16) ::
 (_script_func_global_17, Gvar v_script_func_global_17) ::
 (_script_func_global_18, Gvar v_script_func_global_18) :: nil).

Definition public_idents : list ident :=
(_script_func_global_18 :: _script_func_global_17 ::
 _script_func_global_16 :: _script_func_global_15 ::
 _script_func_global_14 :: _script_func_global_13 ::
 _script_func_global_12 :: _script_func_global_11 ::
 _script_func_global_10 :: _script_func_global_9 :: _script_func_global_8 ::
 _script_func_global_7 :: _script_func_global_6 :: _script_func_global_5 ::
 _script_func_global_4 :: _script_func_global_3 :: _script_func_global_2 ::
 _script_func_global_1 :: _level_main_scripts_entry :: _level_ttm_entry ::
 _level_bowser_3_entry :: _level_bowser_2_entry :: _level_wmotr_entry ::
 _level_bowser_1_entry :: _level_totwc_entry :: _level_cotmc_entry ::
 _level_pss_entry :: _level_castle_courtyard_entry :: _level_ending_entry ::
 _level_wf_entry :: _level_ddd_entry :: _level_lll_entry ::
 _level_bits_entry :: _level_sa_entry :: _level_bitfs_entry ::
 _level_vcutm_entry :: _level_bitdw_entry :: _level_castle_grounds_entry ::
 _level_rr_entry :: _level_ttc_entry :: _level_thi_entry ::
 _level_jrb_entry :: _level_wdw_entry :: _level_sl_entry ::
 _level_bob_entry :: _level_ssl_entry :: _level_hmc_entry ::
 _level_castle_inside_entry :: _level_ccm_entry :: _level_bbh_entry ::
 _level_intro_entry_4 :: _level_intro_mario_head_dizzy ::
 _level_intro_mario_head_regular :: _level_intro_splash_screen ::
 _level_main_menu_entry_2 :: _swoop_geo :: _snufit_geo :: _scuttlebug_geo ::
 _mr_i_iris_geo :: _mr_i_geo :: _dorrie_geo :: _moneybag_geo ::
 _chilly_chief_big_geo :: _chilly_chief_geo :: _toad_geo :: _mips_geo ::
 _lakitu_geo :: _boo_castle_geo :: _whomp_geo :: _wooden_post_geo ::
 _piranha_plant_geo :: _koopa_flag_geo :: _koopa_with_shell_geo ::
 _koopa_without_shell_geo :: _chain_chomp_geo :: _metallic_ball_geo ::
 _water_ring_geo :: _water_mine_geo :: _treasure_chest_lid_geo ::
 _treasure_chest_base_geo :: _skeeter_geo :: _seaweed_geo ::
 _cyan_fish_geo :: _bub_geo :: _bowser_impact_smoke_geo ::
 _invisible_bowser_accessory_geo :: _bowser_flames_geo ::
 _bowser_geo_no_shadow :: _bowser_geo :: _bowser_bomb_geo ::
 _wiggler_head_geo :: _wiggler_body_geo :: _spiny_ball_geo :: _spiny_geo ::
 _enemy_lakitu_geo :: _bubba_geo :: _yoshi_geo :: _peach_geo :: _birds_geo ::
 _small_key_geo :: _mad_piano_geo :: _haunted_cage_geo ::
 _haunted_chair_geo :: _bookend_part_geo :: _bookend_geo :: _boo_geo ::
 _cap_switch_base_seg5_dl_05003120 ::
 _cap_switch_exclamation_seg5_dl_05002E00 :: _cap_switch_geo ::
 _spindrift_geo :: _mr_blizzard_geo :: _mr_blizzard_hidden_geo ::
 _penguin_geo :: _ukiki_geo :: _monty_mole_hole_seg5_dl_05000840 ::
 _monty_mole_geo :: _fwoosh_geo :: _tweester_geo :: _pokey_body_part_geo ::
 _pokey_head_geo :: _klepto_geo :: _eyerok_right_hand_geo ::
 _eyerok_left_hand_geo :: _whirlpool_seg5_dl_05013CB8 :: _unagi_geo ::
 _sushi_geo :: _manta_seg5_geo_05008D14 :: _clam_shell_geo ::
 _water_bomb_shadow_geo :: _water_bomb_geo :: _king_bobomb_geo ::
 _bully_boss_geo :: _bully_geo :: _blargg_geo :: _yoshi_egg_geo ::
 _yellow_sphere_geo :: _thwomp_geo :: _hoot_geo :: _heave_ho_geo ::
 _bullet_bill_geo :: _white_particle_small_dl :: _wave_trail_geo ::
 _idle_water_wave_geo :: _water_splash_geo :: _smoke_geo ::
 _small_water_splash_geo :: _sparkles_animation_geo :: _sparkles_geo ::
 _mario_geo :: _burn_smoke_geo :: _purple_marble_geo :: _bubble_geo ::
 _wooden_signpost_geo :: _white_particle_dl :: _white_particle_geo ::
 _transparent_star_geo :: _star_geo :: _sand_seg3_dl_0302BCD0 ::
 _pebble_seg3_dl_0301CB00 :: _number_geo :: _mushroom_1up_geo ::
 _white_puff_geo :: _mist_geo :: _marios_winged_metal_cap_geo ::
 _marios_wing_cap_geo :: _marios_metal_cap_geo :: _marios_cap_geo ::
 _leaves_geo :: _blue_flame_geo :: _red_flame_geo :: _red_flame_shadow_geo ::
 _explosion_geo :: _cartoon_star_geo :: _dirt_animation_geo ::
 _red_coin_no_shadow_geo :: _red_coin_geo :: _blue_coin_no_shadow_geo ::
 _blue_coin_geo :: _yellow_coin_no_shadow_geo :: _yellow_coin_geo ::
 _butterfly_geo :: _bowser_key_cutscene_geo :: _bowser_key_geo ::
 _fish_geo :: _fish_shadow_geo :: _purple_switch_geo :: _metal_box_dl ::
 _metal_box_geo :: _koopa_shell_geo :: _heart_geo :: _goomba_geo ::
 _flyguy_geo :: _exclamation_box_outline_seg8_dl_08025F08 ::
 _exclamation_box_outline_geo :: _exclamation_box_geo :: _chuckya_geo ::
 _checkerboard_platform_geo :: _cannon_lid_seg8_dl_080048E0 ::
 _cannon_base_geo :: _cannon_barrel_geo :: _breakable_box_small_geo ::
 _breakable_box_geo :: _bowling_ball_track_geo :: _bowling_ball_geo ::
 _bobomb_buddy_geo :: _black_bobomb_geo :: _blue_coin_switch_geo ::
 _dAmpGeo :: __ttmSegmentRomEnd :: __ttmSegmentRomStart ::
 __bowser_3SegmentRomEnd :: __bowser_3SegmentRomStart ::
 __bowser_2SegmentRomEnd :: __bowser_2SegmentRomStart ::
 __wmotrSegmentRomEnd :: __wmotrSegmentRomStart :: __bowser_1SegmentRomEnd ::
 __bowser_1SegmentRomStart :: __totwcSegmentRomEnd ::
 __totwcSegmentRomStart :: __cotmcSegmentRomEnd :: __cotmcSegmentRomStart ::
 __pssSegmentRomEnd :: __pssSegmentRomStart ::
 __castle_courtyardSegmentRomEnd :: __castle_courtyardSegmentRomStart ::
 __endingSegmentRomEnd :: __endingSegmentRomStart :: __wfSegmentRomEnd ::
 __wfSegmentRomStart :: __dddSegmentRomEnd :: __dddSegmentRomStart ::
 __lllSegmentRomEnd :: __lllSegmentRomStart :: __bitsSegmentRomEnd ::
 __bitsSegmentRomStart :: __saSegmentRomEnd :: __saSegmentRomStart ::
 __bitfsSegmentRomEnd :: __bitfsSegmentRomStart :: __vcutmSegmentRomEnd ::
 __vcutmSegmentRomStart :: __bitdwSegmentRomEnd :: __bitdwSegmentRomStart ::
 __castle_groundsSegmentRomEnd :: __castle_groundsSegmentRomStart ::
 __rrSegmentRomEnd :: __rrSegmentRomStart :: __ttcSegmentRomEnd ::
 __ttcSegmentRomStart :: __thiSegmentRomEnd :: __thiSegmentRomStart ::
 __jrbSegmentRomEnd :: __jrbSegmentRomStart :: __wdwSegmentRomEnd ::
 __wdwSegmentRomStart :: __slSegmentRomEnd :: __slSegmentRomStart ::
 __bobSegmentRomEnd :: __bobSegmentRomStart :: __sslSegmentRomEnd ::
 __sslSegmentRomStart :: __hmcSegmentRomEnd :: __hmcSegmentRomStart ::
 __castle_insideSegmentRomEnd :: __castle_insideSegmentRomStart ::
 __ccmSegmentRomEnd :: __ccmSegmentRomStart :: __bbhSegmentRomEnd ::
 __bbhSegmentRomStart :: __introSegmentRomEnd :: __introSegmentRomStart ::
 __menuSegmentRomEnd :: __menuSegmentRomStart :: __behaviorSegmentRomEnd ::
 __behaviorSegmentRomStart :: __group0_geoSegmentRomEnd ::
 __group0_geoSegmentRomStart :: __group0_mio0SegmentRomEnd ::
 __group0_mio0SegmentRomStart :: __common1_geoSegmentRomEnd ::
 __common1_geoSegmentRomStart :: __common1_mio0SegmentRomEnd ::
 __common1_mio0SegmentRomStart :: _lvl_init_from_save_file ::
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
