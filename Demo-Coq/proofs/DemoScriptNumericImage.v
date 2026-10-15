From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Ctypes Globalenvs Integers Values.
From Demo.Generated Require Import us_level_scripts jp_level_scripts.
From Demo.Proofs Require Import DemoScriptDispatchFacts.
Import ListNotations.
Open Scope Z_scope.
Module SU := us_level_scripts.
Module SJ := jp_level_scripts.

(** Authenticated finite numeric word transcriptions. Authentication and ELF
    placement are checked outside Coq; the kernel checks each complete selected
    initializer against this explicit relocation-word representation. No new
    Clight dereference, call, or pointer/integer cast rule is introduced. *)
Fixpoint demo_numeric_relocation id (placements : list (ident * int)) : option int :=
  match placements with
  | [] => None
  | (name, address) :: rest =>
      if Pos.eqb id name then Some address else demo_numeric_relocation id rest
  end.

Definition demo_numeric_initializer_word placements datum : option int :=
  match datum with
  | Init_int32 word => Some word
  | Init_addrof id offset =>
      match demo_numeric_relocation id placements with
      | Some address => Some (Int.add address (Int.repr (Ptrofs.unsigned offset)))
      | None => None
      end
  | _ => None
  end.

Definition demo_initializer_word_representation placements datum word : Prop :=
  demo_numeric_initializer_word placements datum = Some word.

Definition demo_initializer_image_representation placements data words : Prop :=
  Forall2 (demo_initializer_word_representation placements) data words.

Fixpoint demo_initializer_image_matches placements data words : bool :=
  match data, words with
  | [], [] => true
  | datum :: rest, word :: remaining =>
      match demo_numeric_initializer_word placements datum with
      | Some expected => Int.eq expected word &&
          demo_initializer_image_matches placements rest remaining
      | None => false
      end
  | _, _ => false
  end.

Lemma demo_initializer_image_matches_sound : forall placements data words,
  demo_initializer_image_matches placements data words = true ->
  demo_initializer_image_representation placements data words.
Proof.
  intros placements data. induction data as [|datum rest IH];
    intros words Hcheck; destruct words as [|word remaining];
    cbn [demo_initializer_image_matches] in Hcheck; try discriminate.
  - constructor.
  - destruct (demo_numeric_initializer_word placements datum) as [expected|]
      eqn:Hvalue; [| discriminate].
    apply Bool.andb_true_iff in Hcheck as [Hhead Htail].
    pose proof (Int.eq_spec expected word) as Hequal.
    rewrite Hhead in Hequal. subst word.
    constructor; [exact Hvalue | apply IH; exact Htail].
Qed.

Inductive demo_symbol_address_representation (ge : Clight.genv) placements : val -> val -> Prop :=
| demo_symbol_address_represents : forall id block offset address,
    Genv.find_symbol ge id = Some block ->
    demo_numeric_relocation id placements = Some address ->
    demo_symbol_address_representation ge placements
      (Vptr block offset) (Vint (Int.add address (Int.repr (Ptrofs.unsigned offset)))).

Lemma demo_symbolic_pointer_is_not_integer_injection :
  forall injection block offset address,
    ~ Val.inject injection (Vptr block offset) (Vint address).
Proof. intros injection block offset address H; inversion H. Qed.

Fixpoint decode_demo_numeric_equality_arms fuel words : option (list (int * int)) :=
  match fuel with
  | O => None
  | S remaining =>
      match words with
      | [exit] => if Int.eq exit (Int.repr 33816576) then Some [] else None
      | jump :: argument :: target :: rest =>
          if Int.eq jump (Int.repr 202113536)
          then match decode_demo_numeric_equality_arms remaining rest with
               | Some arms => Some ((argument, target) :: arms)
               | None => None
               end
          else None
      | _ => None
      end
  end.

Fixpoint lookup_demo_numeric_arm header arms : option int :=
  match arms with
  | [] => None
  | (argument, target) :: rest =>
      if Int.eq header argument then Some target
      else lookup_demo_numeric_arm header rest
  end.

Definition checked_demo_numeric_dispatch_target header words : option int :=
  match words with
  | read :: rest =>
      if Int.eq read (Int.repr 1006895363)
      then match decode_demo_numeric_equality_arms (length words) rest with
           | Some arms => lookup_demo_numeric_arm (Int.repr header) arms
           | None => None
           end
      else None
  | _ => None
  end.

Definition demo_expected_numeric_route placements (route : option (ident * ident)) : option int :=
  match route with
  | Some (script, entry) => demo_numeric_relocation script placements
  | None => None
  end.

Definition demo_us_script_numeric_relocations : list (ident * int) :=
  [(SU.__bbhSegmentRomEnd, Int.repr 3684688);
   (SU.__bbhSegmentRomStart, Int.repr 3680448);
   (SU.__behaviorSegmentRomEnd, Int.repr 2225344);
   (SU.__behaviorSegmentRomStart, Int.repr 2203136);
   (SU.__bitdwSegmentRomEnd, Int.repr 4572672);
   (SU.__bitdwSegmentRomStart, Int.repr 4570976);
   (SU.__bitfsSegmentRomEnd, Int.repr 4632720);
   (SU.__bitfsSegmentRomStart, Int.repr 4630592);
   (SU.__bitsSegmentRomEnd, Int.repr 4687008);
   (SU.__bitsSegmentRomStart, Int.repr 4685056);
   (SU.__bobSegmentRomEnd, Int.repr 4218800);
   (SU.__bobSegmentRomStart, Int.repr 4217440);
   (SU.__bowser_1SegmentRomEnd, Int.repr 4997920);
   (SU.__bowser_1SegmentRomStart, Int.repr 4997568);
   (SU.__bowser_2SegmentRomEnd, Int.repr 5041152);
   (SU.__bowser_2SegmentRomStart, Int.repr 5040624);
   (SU.__bowser_3SegmentRomEnd, Int.repr 5052688);
   (SU.__bowser_3SegmentRomStart, Int.repr 5051632);
   (SU.__castle_courtyardSegmentRomEnd, Int.repr 4913456);
   (SU.__castle_courtyardSegmentRomStart, Int.repr 4912752);
   (SU.__castle_groundsSegmentRomEnd, Int.repr 4541952);
   (SU.__castle_groundsSegmentRomStart, Int.repr 4539872);
   (SU.__castle_insideSegmentRomEnd, Int.repr 4001216);
   (SU.__castle_insideSegmentRomStart, Int.repr 3993808);
   (SU.__ccmSegmentRomEnd, Int.repr 3760960);
   (SU.__ccmSegmentRomStart, Int.repr 3759248);
   (SU.__common1_geoSegmentRomEnd, Int.repr 2203136);
   (SU.__common1_geoSegmentRomStart, Int.repr 2198944);
   (SU.__common1_mio0SegmentRomEnd, Int.repr 2198944);
   (SU.__common1_mio0SegmentRomStart, Int.repr 2102288);
   (SU.__cotmcSegmentRomEnd, Int.repr 4975664);
   (SU.__cotmcSegmentRomStart, Int.repr 4975072);
   (SU.__dddSegmentRomEnd, Int.repr 4808848);
   (SU.__dddSegmentRomStart, Int.repr 4807264);
   (SU.__endingSegmentRomEnd, Int.repr 4900208);
   (SU.__endingSegmentRomStart, Int.repr 4900016);
   (SU.__group0_geoSegmentRomEnd, Int.repr 1222624);
   (SU.__group0_geoSegmentRomStart, Int.repr 1210800);
   (SU.__group0_mio0SegmentRomEnd, Int.repr 1210800);
   (SU.__group0_mio0SegmentRomStart, Int.repr 1132368);
   (SU.__hmcSegmentRomEnd, Int.repr 4093616);
   (SU.__hmcSegmentRomStart, Int.repr 4090368);
   (SU.__introSegmentRomEnd, Int.repr 2532256);
   (SU.__introSegmentRomStart, Int.repr 2530976);
   (SU.__jrbSegmentRomEnd, Int.repr 4343504);
   (SU.__jrbSegmentRomStart, Int.repr 4340512);
   (SU.__lllSegmentRomEnd, Int.repr 4774192);
   (SU.__lllSegmentRomStart, Int.repr 4770224);
   (SU.__menuSegmentRomEnd, Int.repr 2778544);
   (SU.__menuSegmentRomStart, Int.repr 2777376);
   (SU.__pssSegmentRomEnd, Int.repr 4948176);
   (SU.__pssSegmentRomStart, Int.repr 4947728);
   (SU.__rrSegmentRomEnd, Int.repr 4500416);
   (SU.__rrSegmentRomStart, Int.repr 4497728);
   (SU.__saSegmentRomEnd, Int.repr 4637600);
   (SU.__saSegmentRomStart, Int.repr 4637088);
   (SU.__slSegmentRomEnd, Int.repr 4255088);
   (SU.__slSegmentRomStart, Int.repr 4253760);
   (SU.__sslSegmentRomEnd, Int.repr 4178608);
   (SU.__sslSegmentRomStart, Int.repr 4176272);
   (SU.__thiSegmentRomEnd, Int.repr 4378400);
   (SU.__thiSegmentRomStart, Int.repr 4376288);
   (SU.__totwcSegmentRomEnd, Int.repr 4991264);
   (SU.__totwcSegmentRomStart, Int.repr 4990720);
   (SU.__ttcSegmentRomEnd, Int.repr 4421744);
   (SU.__ttcSegmentRomStart, Int.repr 4420608);
   (SU.__ttmSegmentRomEnd, Int.repr 5160960);
   (SU.__ttmSegmentRomStart, Int.repr 5157360);
   (SU.__vcutmSegmentRomEnd, Int.repr 4592848);
   (SU.__vcutmSegmentRomStart, Int.repr 4592160);
   (SU.__wdwSegmentRomEnd, Int.repr 4302688);
   (SU.__wdwSegmentRomStart, Int.repr 4300688);
   (SU.__wfSegmentRomEnd, Int.repr 4843280);
   (SU.__wfSegmentRomStart, Int.repr 4840016);
   (SU.__wmotrSegmentRomEnd, Int.repr 5037008);
   (SU.__wmotrSegmentRomStart, Int.repr 5036336);
   (SU._birds_geo, Int.repr 201326592);
   (SU._black_bobomb_geo, Int.repr 251660216);
   (SU._blargg_geo, Int.repr 201327168);
   (SU._blue_coin_geo, Int.repr 369099264);
   (SU._blue_coin_no_shadow_geo, Int.repr 369099364);
   (SU._blue_coin_switch_geo, Int.repr 251658240);
   (SU._blue_flame_geo, Int.repr 369101708);
   (SU._bobomb_buddy_geo, Int.repr 251660532);
   (SU._boo_castle_geo, Int.repr 218105264);
   (SU._boo_geo, Int.repr 201327140);
   (SU._bookend_geo, Int.repr 201326784);
   (SU._bookend_part_geo, Int.repr 201326592);
   (SU._bowling_ball_geo, Int.repr 251659840);
   (SU._bowling_ball_track_geo, Int.repr 251659884);
   (SU._bowser_bomb_geo, Int.repr 218106812);
   (SU._bowser_flames_geo, Int.repr 218103808);
   (SU._bowser_geo, Int.repr 218106564);
   (SU._bowser_geo_no_shadow, Int.repr 218106688);
   (SU._bowser_impact_smoke_geo, Int.repr 218106876);
   (SU._bowser_key_cutscene_geo, Int.repr 369101488);
   (SU._bowser_key_geo, Int.repr 369101444);
   (SU._breakable_box_geo, Int.repr 251659728);
   (SU._breakable_box_small_geo, Int.repr 251659792);
   (SU._bub_geo, Int.repr 218104716);
   (SU._bubba_geo, Int.repr 201326592);
   (SU._bubble_geo, Int.repr 385875968);
   (SU._bullet_bill_geo, Int.repr 201327204);
   (SU._bully_boss_geo, Int.repr 201326880);
   (SU._bully_geo, Int.repr 201326592);
   (SU._burn_smoke_geo, Int.repr 385876100);
   (SU._butterfly_geo, Int.repr 369098920);
   (SU._cannon_barrel_geo, Int.repr 251658688);
   (SU._cannon_base_geo, Int.repr 251658664);
   (SU._cannon_lid_seg8_dl_080048E0, Int.repr 134236384);
   (SU._cap_switch_base_seg5_dl_05003120, Int.repr 83898656);
   (SU._cap_switch_exclamation_seg5_dl_05002E00, Int.repr 83897856);
   (SU._cap_switch_geo, Int.repr 201326664);
   (SU._cartoon_star_geo, Int.repr 369102628);
   (SU._chain_chomp_geo, Int.repr 218105324);
   (SU._checkerboard_platform_geo, Int.repr 251659492);
   (SU._chilly_chief_big_geo, Int.repr 100677748);
   (SU._chilly_chief_geo, Int.repr 100677460);
   (SU._chuckya_geo, Int.repr 251658712);
   (SU._clam_shell_geo, Int.repr 201326592);
   (SU._cyan_fish_geo, Int.repr 218104612);
   (SU._dAmpGeo, Int.repr 251658280);
   (SU._dirt_animation_geo, Int.repr 369102548);
   (SU._dorrie_geo, Int.repr 218104368);
   (SU._enemy_lakitu_geo, Int.repr 201327036);
   (SU._exclamation_box_geo, Int.repr 251659924);
   (SU._exclamation_box_outline_geo, Int.repr 251660888);
   (SU._exclamation_box_outline_seg8_dl_08025F08, Int.repr 134373128);
   (SU._explosion_geo, Int.repr 369098816);
   (SU._eyerok_left_hand_geo, Int.repr 201328040);
   (SU._eyerok_right_hand_geo, Int.repr 201328100);
   (SU._fish_geo, Int.repr 369101892);
   (SU._fish_shadow_geo, Int.repr 369101804);
   (SU._flyguy_geo, Int.repr 251659544);
   (SU._fwoosh_geo, Int.repr 201327468);
   (SU._goomba_geo, Int.repr 251660004);
   (SU._goto_mario_head_dizzy, Int.repr 352322136);
   (SU._goto_mario_head_regular, Int.repr 352322120);
   (SU._haunted_cage_geo, Int.repr 201327220);
   (SU._haunted_chair_geo, Int.repr 201326808);
   (SU._heart_geo, Int.repr 251659516);
   (SU._heave_ho_geo, Int.repr 201327244);
   (SU._hoot_geo, Int.repr 201326616);
   (SU._idle_water_wave_geo, Int.repr 385876260);
   (SU._invisible_bowser_accessory_geo, Int.repr 218103952);
   (SU._king_bobomb_geo, Int.repr 201326592);
   (SU._klepto_geo, Int.repr 201326592);
   (SU._koopa_flag_geo, Int.repr 218103808);
   (SU._koopa_shell_geo, Int.repr 251660976);
   (SU._koopa_with_shell_geo, Int.repr 218104340);
   (SU._koopa_without_shell_geo, Int.repr 218104016);
   (SU._lakitu_geo, Int.repr 218103808);
   (SU._leaves_geo, Int.repr 369101964);
   (SU._level_bbh_entry, Int.repr 234882072);
   (SU._level_bitdw_entry, Int.repr 234881396);
   (SU._level_bitfs_entry, Int.repr 234881588);
   (SU._level_bits_entry, Int.repr 234881512);
   (SU._level_bob_entry, Int.repr 234881636);
   (SU._level_bowser_1_entry, Int.repr 234881024);
   (SU._level_bowser_2_entry, Int.repr 234881148);
   (SU._level_bowser_3_entry, Int.repr 234881388);
   (SU._level_castle_courtyard_entry, Int.repr 234881176);
   (SU._level_castle_grounds_entry, Int.repr 234882312);
   (SU._level_castle_inside_entry, Int.repr 234883832);
   (SU._level_ccm_entry, Int.repr 234881400);
   (SU._level_cotmc_entry, Int.repr 234881128);
   (SU._level_ddd_entry, Int.repr 234881644);
   (SU._level_ending_entry, Int.repr 234881024);
   (SU._level_hmc_entry, Int.repr 234881928);
   (SU._level_intro_entry_4, Int.repr 335544720);
   (SU._level_intro_mario_head_dizzy, Int.repr 335544580);
   (SU._level_intro_mario_head_regular, Int.repr 335544440);
   (SU._level_intro_splash_screen, Int.repr 335544320);
   (SU._level_jrb_entry, Int.repr 234882796);
   (SU._level_lll_entry, Int.repr 234882684);
   (SU._level_main_menu_entry_2, Int.repr 335544600);
   (SU._level_pss_entry, Int.repr 234881024);
   (SU._level_rr_entry, Int.repr 234882020);
   (SU._level_sa_entry, Int.repr 234881104);
   (SU._level_sl_entry, Int.repr 234881280);
   (SU._level_ssl_entry, Int.repr 234881720);
   (SU._level_thi_entry, Int.repr 234881680);
   (SU._level_totwc_entry, Int.repr 234881080);
   (SU._level_ttc_entry, Int.repr 234881224);
   (SU._level_ttm_entry, Int.repr 234881940);
   (SU._level_vcutm_entry, Int.repr 234881228);
   (SU._level_wdw_entry, Int.repr 234881904);
   (SU._level_wf_entry, Int.repr 234882408);
   (SU._level_wmotr_entry, Int.repr 234881200);
   (SU._lvl_init_from_save_file, Int.repr 2149891420);
   (SU._mad_piano_geo, Int.repr 201327028);
   (SU._manta_seg5_geo_05008D14, Int.repr 83922196);
   (SU._mario_geo, Int.repr 385887700);
   (SU._marios_cap_geo, Int.repr 369101988);
   (SU._marios_metal_cap_geo, Int.repr 369102064);
   (SU._marios_wing_cap_geo, Int.repr 369102140);
   (SU._marios_winged_metal_cap_geo, Int.repr 369102248);
   (SU._metal_box_dl, Int.repr 134368184);
   (SU._metal_box_geo, Int.repr 251660848);
   (SU._metallic_ball_geo, Int.repr 218105296);
   (SU._mips_geo, Int.repr 218104904);
   (SU._mist_geo, Int.repr 369098752);
   (SU._moneybag_geo, Int.repr 218104048);
   (SU._monty_mole_geo, Int.repr 201326592);
   (SU._monty_mole_hole_seg5_dl_05000840, Int.repr 83888192);
   (SU._mr_blizzard_geo, Int.repr 201327432);
   (SU._mr_blizzard_hidden_geo, Int.repr 201327132);
   (SU._mr_i_geo, Int.repr 218103808);
   (SU._mr_i_iris_geo, Int.repr 218103836);
   (SU._mushroom_1up_geo, Int.repr 369102468);
   (SU._number_geo, Int.repr 369102356);
   (SU._peach_geo, Int.repr 201327632);
   (SU._pebble_seg3_dl_0301CB00, Int.repr 50449152);
   (SU._penguin_geo, Int.repr 201326852);
   (SU._piranha_plant_geo, Int.repr 218104664);
   (SU._pokey_body_part_geo, Int.repr 201328196);
   (SU._pokey_head_geo, Int.repr 201328144);
   (SU._purple_marble_geo, Int.repr 385875996);
   (SU._purple_switch_geo, Int.repr 251659468);
   (SU._red_coin_geo, Int.repr 369099460);
   (SU._red_coin_no_shadow_geo, Int.repr 369099560);
   (SU._red_flame_geo, Int.repr 369101612);
   (SU._red_flame_shadow_geo, Int.repr 369101584);
   (SU._sand_seg3_dl_0302BCD0, Int.repr 50511056);
   (SU._script_L1, Int.repr 352322088);
   (SU._script_L2, Int.repr 352322104);
   (SU._script_L5, Int.repr 352322152);
   (SU._script_exec_bbh, Int.repr 352322548);
   (SU._script_exec_bitdw, Int.repr 352322808);
   (SU._script_exec_bitfs, Int.repr 352322848);
   (SU._script_exec_bits, Int.repr 352322888);
   (SU._script_exec_bob, Int.repr 352322648);
   (SU._script_exec_bowser_1, Int.repr 352323068);
   (SU._script_exec_bowser_2, Int.repr 352323108);
   (SU._script_exec_bowser_3, Int.repr 352323128);
   (SU._script_exec_castle_courtyard, Int.repr 352322988);
   (SU._script_exec_castle_grounds, Int.repr 352322788);
   (SU._script_exec_castle_inside, Int.repr 352322588);
   (SU._script_exec_ccm, Int.repr 352322568);
   (SU._script_exec_cotmc, Int.repr 352323028);
   (SU._script_exec_ddd, Int.repr 352322928);
   (SU._script_exec_ending, Int.repr 352322968);
   (SU._script_exec_hmc, Int.repr 352322608);
   (SU._script_exec_jrb, Int.repr 352322708);
   (SU._script_exec_level_table, Int.repr 352322168);
   (SU._script_exec_lll, Int.repr 352322908);
   (SU._script_exec_pss, Int.repr 352323008);
   (SU._script_exec_rr, Int.repr 352322768);
   (SU._script_exec_sa, Int.repr 352322868);
   (SU._script_exec_sl, Int.repr 352322668);
   (SU._script_exec_ssl, Int.repr 352322628);
   (SU._script_exec_thi, Int.repr 352322728);
   (SU._script_exec_totwc, Int.repr 352323048);
   (SU._script_exec_ttc, Int.repr 352322748);
   (SU._script_exec_ttm, Int.repr 352323148);
   (SU._script_exec_vcutm, Int.repr 352322828);
   (SU._script_exec_wdw, Int.repr 352322688);
   (SU._script_exec_wf, Int.repr 352322948);
   (SU._script_exec_wmotr, Int.repr 352323088);
   (SU._scuttlebug_geo, Int.repr 218104724);
   (SU._seaweed_geo, Int.repr 218104452);
   (SU._skeeter_geo, Int.repr 218103808);
   (SU._small_key_geo, Int.repr 201326984);
   (SU._small_water_splash_geo, Int.repr 385876124);
   (SU._smoke_geo, Int.repr 385876024);
   (SU._snufit_geo, Int.repr 218104224);
   (SU._sparkles_animation_geo, Int.repr 385876612);
   (SU._sparkles_geo, Int.repr 385876412);
   (SU._spindrift_geo, Int.repr 201326592);
   (SU._spiny_ball_geo, Int.repr 201327248);
   (SU._spiny_geo, Int.repr 201327400);
   (SU._star_geo, Int.repr 369102496);
   (SU._sushi_geo, Int.repr 201326696);
   (SU._swoop_geo, Int.repr 218104028);
   (SU._thwomp_geo, Int.repr 201327176);
   (SU._toad_geo, Int.repr 218104804);
   (SU._transparent_star_geo, Int.repr 369102700);
   (SU._treasure_chest_base_geo, Int.repr 218104912);
   (SU._treasure_chest_lid_geo, Int.repr 218104936);
   (SU._tweester_geo, Int.repr 83969584);
   (SU._ukiki_geo, Int.repr 201326864);
   (SU._unagi_geo, Int.repr 201326860);
   (SU._water_bomb_geo, Int.repr 201327368);
   (SU._water_bomb_shadow_geo, Int.repr 201327400);
   (SU._water_mine_geo, Int.repr 218104564);
   (SU._water_ring_geo, Int.repr 218104852);
   (SU._water_splash_geo, Int.repr 385876528);
   (SU._wave_trail_geo, Int.repr 385876328);
   (SU._whirlpool_seg5_dl_05013CB8, Int.repr 83967160);
   (SU._white_particle_dl, Int.repr 50514080);
   (SU._white_particle_geo, Int.repr 369102744);
   (SU._white_particle_small_dl, Int.repr 67316248);
   (SU._white_puff_geo, Int.repr 369098784);
   (SU._whomp_geo, Int.repr 218104960);
   (SU._wiggler_body_geo, Int.repr 83937144);
   (SU._wiggler_head_geo, Int.repr 201326640);
   (SU._wooden_post_geo, Int.repr 218103992);
   (SU._wooden_signpost_geo, Int.repr 369102772);
   (SU._yellow_coin_geo, Int.repr 369099068);
   (SU._yellow_coin_no_shadow_geo, Int.repr 369099168);
   (SU._yellow_sphere_geo, Int.repr 201326592);
   (SU._yoshi_egg_geo, Int.repr 201327076);
   (SU._yoshi_geo, Int.repr 201327720)].

Definition demo_us_numeric_level_main_scripts_entry : list int :=
  map Int.repr
  [403439620; 1132368; 1210800; 403439619; 2102288; 2198944; 386662423; 1210800;
   1222624; 386662422; 2198944; 2203136; 386662419; 2203136; 2225344; 486801408;
   570949633; 385887700; 570949782; 385876024; 570949781; 385876412; 570949800; 385875968;
   570949797; 385876124; 570949798; 385876260; 570949799; 385876528; 570949795; 385876328;
   570949748; 369099068; 570949754; 369102496; 570949753; 369102700; 570949756; 369102772;
   554188964; 67316248; 570949776; 369101612; 570949777; 369101708; 570949780; 385876100;
   570949794; 369101964; 570949802; 385875996; 570949817; 369101892; 570949818; 369101804;
   570949775; 385876612; 554188959; 50511056; 570949819; 369098920; 570949788; 385876100;
   554188961; 50449152; 570949774; 369098752; 570949856; 369098784; 554188958; 50514080;
   570949792; 369102744; 570949749; 369099168; 570949750; 369099264; 570949751; 369099364;
   570949765; 369102248; 570949766; 369102064; 570949767; 369102140; 570949768; 369101988;
   570949768; 369101988; 570949832; 369101488; 570949836; 369101444; 570949835; 369101584;
   570949844; 369102468; 570949847; 369099460; 570949848; 369099560; 570949851; 369102356;
   570949837; 369098816; 570949770; 369102548; 570949771; 369102628; 503578624; 285736960;
   2149891420; 168034304; 1048596; 2777376; 2778544; 335544600; 101187584; 352322168;
   50593793; 185074688; 0; 202113536; 4294967295; 352322104; 202113536; 4294967294;
   352322120; 202113536; 4294967293; 352322136; 202113536; 4294967288; 352322088; 202113536;
   4294967287; 352322152].

Definition demo_us_numeric_script_exec_level_table : list int :=
  map Int.repr
  [1006895363; 202113536; 4; 352322548; 202113536; 5; 352322568; 202113536;
   6; 352322588; 202113536; 7; 352322608; 202113536; 8; 352322628;
   202113536; 9; 352322648; 202113536; 10; 352322668; 202113536; 11;
   352322688; 202113536; 12; 352322708; 202113536; 13; 352322728; 202113536;
   14; 352322748; 202113536; 15; 352322768; 202113536; 16; 352322788;
   202113536; 17; 352322808; 202113536; 18; 352322828; 202113536; 19;
   352322848; 202113536; 20; 352322868; 202113536; 21; 352322888; 202113536;
   22; 352322908; 202113536; 23; 352322928; 202113536; 24; 352322948;
   202113536; 25; 352322968; 202113536; 26; 352322988; 202113536; 27;
   352323008; 202113536; 28; 352323028; 202113536; 29; 352323048; 202113536;
   30; 352323068; 202113536; 31; 352323088; 202113536; 33; 352323108;
   202113536; 34; 352323128; 202113536; 36; 352323148; 33816576].

Definition demo_us_numeric_script_exec_bbh : list int :=
  map Int.repr
  [1048590; 3680448; 3684688; 234882072; 117702656].

Definition demo_us_numeric_script_exec_ccm : list int :=
  map Int.repr
  [1048590; 3759248; 3760960; 234881400; 117702656].

Definition demo_us_numeric_script_exec_hmc : list int :=
  map Int.repr
  [1048590; 4090368; 4093616; 234881928; 117702656].

Definition demo_us_numeric_script_exec_jrb : list int :=
  map Int.repr
  [1048590; 4340512; 4343504; 234882796; 117702656].

Definition demo_us_numeric_script_exec_wf : list int :=
  map Int.repr
  [1048590; 4840016; 4843280; 234882408; 117702656].

Definition demo_us_numeric_script_exec_pss : list int :=
  map Int.repr
  [1048590; 4947728; 4948176; 234881024; 117702656].

Definition demo_us_numeric_script_exec_bowser_1 : list int :=
  map Int.repr
  [1048590; 4997568; 4997920; 234881024; 117702656].

Definition demo_us_numeric_script_exec_bitdw : list int :=
  map Int.repr
  [1048590; 4570976; 4572672; 234881396; 117702656].

Definition demo_jp_script_numeric_relocations : list (ident * int) :=
  [(SJ.__bbhSegmentRomEnd, Int.repr 3677936);
   (SJ.__bbhSegmentRomStart, Int.repr 3673696);
   (SJ.__behaviorSegmentRomEnd, Int.repr 2217936);
   (SJ.__behaviorSegmentRomStart, Int.repr 2195760);
   (SJ.__bitdwSegmentRomEnd, Int.repr 4564288);
   (SJ.__bitdwSegmentRomStart, Int.repr 4562592);
   (SJ.__bitfsSegmentRomEnd, Int.repr 4624336);
   (SJ.__bitfsSegmentRomStart, Int.repr 4622208);
   (SJ.__bitsSegmentRomEnd, Int.repr 4678592);
   (SJ.__bitsSegmentRomStart, Int.repr 4676640);
   (SJ.__bobSegmentRomEnd, Int.repr 4210704);
   (SJ.__bobSegmentRomStart, Int.repr 4209344);
   (SJ.__bowser_1SegmentRomEnd, Int.repr 4989632);
   (SJ.__bowser_1SegmentRomStart, Int.repr 4989280);
   (SJ.__bowser_2SegmentRomEnd, Int.repr 5032864);
   (SJ.__bowser_2SegmentRomStart, Int.repr 5032336);
   (SJ.__bowser_3SegmentRomEnd, Int.repr 5044400);
   (SJ.__bowser_3SegmentRomStart, Int.repr 5043344);
   (SJ.__castle_courtyardSegmentRomEnd, Int.repr 4905168);
   (SJ.__castle_courtyardSegmentRomStart, Int.repr 4904464);
   (SJ.__castle_groundsSegmentRomEnd, Int.repr 4533568);
   (SJ.__castle_groundsSegmentRomStart, Int.repr 4531488);
   (SJ.__castle_insideSegmentRomEnd, Int.repr 3993136);
   (SJ.__castle_insideSegmentRomStart, Int.repr 3985728);
   (SJ.__ccmSegmentRomEnd, Int.repr 3754192);
   (SJ.__ccmSegmentRomStart, Int.repr 3752496);
   (SJ.__common1_geoSegmentRomEnd, Int.repr 2195760);
   (SJ.__common1_geoSegmentRomStart, Int.repr 2191568);
   (SJ.__common1_mio0SegmentRomEnd, Int.repr 2191568);
   (SJ.__common1_mio0SegmentRomStart, Int.repr 2094912);
   (SJ.__cotmcSegmentRomEnd, Int.repr 4967376);
   (SJ.__cotmcSegmentRomStart, Int.repr 4966784);
   (SJ.__dddSegmentRomEnd, Int.repr 4800560);
   (SJ.__dddSegmentRomStart, Int.repr 4798976);
   (SJ.__endingSegmentRomEnd, Int.repr 4891920);
   (SJ.__endingSegmentRomStart, Int.repr 4891728);
   (SJ.__group0_geoSegmentRomEnd, Int.repr 1215456);
   (SJ.__group0_geoSegmentRomStart, Int.repr 1203632);
   (SJ.__group0_mio0SegmentRomEnd, Int.repr 1203632);
   (SJ.__group0_mio0SegmentRomStart, Int.repr 1125200);
   (SJ.__hmcSegmentRomEnd, Int.repr 4085520);
   (SJ.__hmcSegmentRomStart, Int.repr 4082272);
   (SJ.__introSegmentRomEnd, Int.repr 2524448);
   (SJ.__introSegmentRomStart, Int.repr 2523168);
   (SJ.__jrbSegmentRomEnd, Int.repr 4335408);
   (SJ.__jrbSegmentRomStart, Int.repr 4332416);
   (SJ.__lllSegmentRomEnd, Int.repr 4765904);
   (SJ.__lllSegmentRomStart, Int.repr 4761936);
   (SJ.__menuSegmentRomEnd, Int.repr 2770736);
   (SJ.__menuSegmentRomStart, Int.repr 2769568);
   (SJ.__pssSegmentRomEnd, Int.repr 4939888);
   (SJ.__pssSegmentRomStart, Int.repr 4939440);
   (SJ.__rrSegmentRomEnd, Int.repr 4492416);
   (SJ.__rrSegmentRomStart, Int.repr 4489728);
   (SJ.__saSegmentRomEnd, Int.repr 4629216);
   (SJ.__saSegmentRomStart, Int.repr 4628704);
   (SJ.__slSegmentRomEnd, Int.repr 4246992);
   (SJ.__slSegmentRomStart, Int.repr 4245664);
   (SJ.__sslSegmentRomEnd, Int.repr 4170512);
   (SJ.__sslSegmentRomStart, Int.repr 4168176);
   (SJ.__thiSegmentRomEnd, Int.repr 4370304);
   (SJ.__thiSegmentRomStart, Int.repr 4368192);
   (SJ.__totwcSegmentRomEnd, Int.repr 4982976);
   (SJ.__totwcSegmentRomStart, Int.repr 4982432);
   (SJ.__ttcSegmentRomEnd, Int.repr 4413648);
   (SJ.__ttcSegmentRomStart, Int.repr 4412512);
   (SJ.__ttmSegmentRomEnd, Int.repr 5152672);
   (SJ.__ttmSegmentRomStart, Int.repr 5149072);
   (SJ.__vcutmSegmentRomEnd, Int.repr 4584464);
   (SJ.__vcutmSegmentRomStart, Int.repr 4583776);
   (SJ.__wdwSegmentRomEnd, Int.repr 4294592);
   (SJ.__wdwSegmentRomStart, Int.repr 4292592);
   (SJ.__wfSegmentRomEnd, Int.repr 4834992);
   (SJ.__wfSegmentRomStart, Int.repr 4831728);
   (SJ.__wmotrSegmentRomEnd, Int.repr 5028720);
   (SJ.__wmotrSegmentRomStart, Int.repr 5028048);
   (SJ._birds_geo, Int.repr 201326592);
   (SJ._black_bobomb_geo, Int.repr 251660216);
   (SJ._blargg_geo, Int.repr 201327168);
   (SJ._blue_coin_geo, Int.repr 369099264);
   (SJ._blue_coin_no_shadow_geo, Int.repr 369099364);
   (SJ._blue_coin_switch_geo, Int.repr 251658240);
   (SJ._blue_flame_geo, Int.repr 369101708);
   (SJ._bobomb_buddy_geo, Int.repr 251660532);
   (SJ._boo_castle_geo, Int.repr 218105264);
   (SJ._boo_geo, Int.repr 201327140);
   (SJ._bookend_geo, Int.repr 201326784);
   (SJ._bookend_part_geo, Int.repr 201326592);
   (SJ._bowling_ball_geo, Int.repr 251659840);
   (SJ._bowling_ball_track_geo, Int.repr 251659884);
   (SJ._bowser_bomb_geo, Int.repr 218106744);
   (SJ._bowser_flames_geo, Int.repr 218103808);
   (SJ._bowser_geo, Int.repr 218106552);
   (SJ._bowser_geo_no_shadow, Int.repr 218106648);
   (SJ._bowser_impact_smoke_geo, Int.repr 218106808);
   (SJ._bowser_key_cutscene_geo, Int.repr 369101488);
   (SJ._bowser_key_geo, Int.repr 369101444);
   (SJ._breakable_box_geo, Int.repr 251659728);
   (SJ._breakable_box_small_geo, Int.repr 251659792);
   (SJ._bub_geo, Int.repr 218104716);
   (SJ._bubba_geo, Int.repr 201326592);
   (SJ._bubble_geo, Int.repr 385875968);
   (SJ._bullet_bill_geo, Int.repr 201327204);
   (SJ._bully_boss_geo, Int.repr 201326880);
   (SJ._bully_geo, Int.repr 201326592);
   (SJ._burn_smoke_geo, Int.repr 385876100);
   (SJ._butterfly_geo, Int.repr 369098920);
   (SJ._cannon_barrel_geo, Int.repr 251658688);
   (SJ._cannon_base_geo, Int.repr 251658664);
   (SJ._cannon_lid_seg8_dl_080048E0, Int.repr 134236384);
   (SJ._cap_switch_base_seg5_dl_05003120, Int.repr 83898656);
   (SJ._cap_switch_exclamation_seg5_dl_05002E00, Int.repr 83897856);
   (SJ._cap_switch_geo, Int.repr 201326664);
   (SJ._cartoon_star_geo, Int.repr 369102628);
   (SJ._chain_chomp_geo, Int.repr 218105324);
   (SJ._checkerboard_platform_geo, Int.repr 251659492);
   (SJ._chilly_chief_big_geo, Int.repr 100677748);
   (SJ._chilly_chief_geo, Int.repr 100677460);
   (SJ._chuckya_geo, Int.repr 251658712);
   (SJ._clam_shell_geo, Int.repr 201326592);
   (SJ._cyan_fish_geo, Int.repr 218104612);
   (SJ._dAmpGeo, Int.repr 251658280);
   (SJ._dirt_animation_geo, Int.repr 369102548);
   (SJ._dorrie_geo, Int.repr 218104368);
   (SJ._enemy_lakitu_geo, Int.repr 201327036);
   (SJ._exclamation_box_geo, Int.repr 251659924);
   (SJ._exclamation_box_outline_geo, Int.repr 251660888);
   (SJ._exclamation_box_outline_seg8_dl_08025F08, Int.repr 134373128);
   (SJ._explosion_geo, Int.repr 369098816);
   (SJ._eyerok_left_hand_geo, Int.repr 201328040);
   (SJ._eyerok_right_hand_geo, Int.repr 201328100);
   (SJ._fish_geo, Int.repr 369101892);
   (SJ._fish_shadow_geo, Int.repr 369101804);
   (SJ._flyguy_geo, Int.repr 251659544);
   (SJ._fwoosh_geo, Int.repr 201327468);
   (SJ._goomba_geo, Int.repr 251660004);
   (SJ._goto_mario_head_dizzy, Int.repr 352322136);
   (SJ._goto_mario_head_regular, Int.repr 352322120);
   (SJ._haunted_cage_geo, Int.repr 201327220);
   (SJ._haunted_chair_geo, Int.repr 201326808);
   (SJ._heart_geo, Int.repr 251659516);
   (SJ._heave_ho_geo, Int.repr 201327244);
   (SJ._hoot_geo, Int.repr 201326616);
   (SJ._idle_water_wave_geo, Int.repr 385876260);
   (SJ._invisible_bowser_accessory_geo, Int.repr 218103952);
   (SJ._king_bobomb_geo, Int.repr 201326592);
   (SJ._klepto_geo, Int.repr 201326592);
   (SJ._koopa_flag_geo, Int.repr 218103808);
   (SJ._koopa_shell_geo, Int.repr 251660976);
   (SJ._koopa_with_shell_geo, Int.repr 218104340);
   (SJ._koopa_without_shell_geo, Int.repr 218104016);
   (SJ._lakitu_geo, Int.repr 218103808);
   (SJ._leaves_geo, Int.repr 369101964);
   (SJ._level_bbh_entry, Int.repr 234882072);
   (SJ._level_bitdw_entry, Int.repr 234881396);
   (SJ._level_bitfs_entry, Int.repr 234881588);
   (SJ._level_bits_entry, Int.repr 234881512);
   (SJ._level_bob_entry, Int.repr 234881636);
   (SJ._level_bowser_1_entry, Int.repr 234881024);
   (SJ._level_bowser_2_entry, Int.repr 234881148);
   (SJ._level_bowser_3_entry, Int.repr 234881388);
   (SJ._level_castle_courtyard_entry, Int.repr 234881176);
   (SJ._level_castle_grounds_entry, Int.repr 234882312);
   (SJ._level_castle_inside_entry, Int.repr 234883832);
   (SJ._level_ccm_entry, Int.repr 234881376);
   (SJ._level_cotmc_entry, Int.repr 234881128);
   (SJ._level_ddd_entry, Int.repr 234881644);
   (SJ._level_ending_entry, Int.repr 234881024);
   (SJ._level_hmc_entry, Int.repr 234881928);
   (SJ._level_intro_entry_4, Int.repr 335544720);
   (SJ._level_intro_mario_head_dizzy, Int.repr 335544580);
   (SJ._level_intro_mario_head_regular, Int.repr 335544440);
   (SJ._level_intro_splash_screen, Int.repr 335544320);
   (SJ._level_jrb_entry, Int.repr 234882796);
   (SJ._level_lll_entry, Int.repr 234882684);
   (SJ._level_main_menu_entry_2, Int.repr 335544600);
   (SJ._level_pss_entry, Int.repr 234881024);
   (SJ._level_rr_entry, Int.repr 234882020);
   (SJ._level_sa_entry, Int.repr 234881104);
   (SJ._level_sl_entry, Int.repr 234881280);
   (SJ._level_ssl_entry, Int.repr 234881720);
   (SJ._level_thi_entry, Int.repr 234881680);
   (SJ._level_totwc_entry, Int.repr 234881080);
   (SJ._level_ttc_entry, Int.repr 234881224);
   (SJ._level_ttm_entry, Int.repr 234881940);
   (SJ._level_vcutm_entry, Int.repr 234881228);
   (SJ._level_wdw_entry, Int.repr 234881904);
   (SJ._level_wf_entry, Int.repr 234882408);
   (SJ._level_wmotr_entry, Int.repr 234881200);
   (SJ._lvl_init_from_save_file, Int.repr 2149891004);
   (SJ._mad_piano_geo, Int.repr 201327028);
   (SJ._manta_seg5_geo_05008D14, Int.repr 83922196);
   (SJ._mario_geo, Int.repr 385887700);
   (SJ._marios_cap_geo, Int.repr 369101988);
   (SJ._marios_metal_cap_geo, Int.repr 369102064);
   (SJ._marios_wing_cap_geo, Int.repr 369102140);
   (SJ._marios_winged_metal_cap_geo, Int.repr 369102248);
   (SJ._metal_box_dl, Int.repr 134368184);
   (SJ._metal_box_geo, Int.repr 251660848);
   (SJ._metallic_ball_geo, Int.repr 218105296);
   (SJ._mips_geo, Int.repr 218104904);
   (SJ._mist_geo, Int.repr 369098752);
   (SJ._moneybag_geo, Int.repr 218104048);
   (SJ._monty_mole_geo, Int.repr 201326592);
   (SJ._monty_mole_hole_seg5_dl_05000840, Int.repr 83888192);
   (SJ._mr_blizzard_geo, Int.repr 201327432);
   (SJ._mr_blizzard_hidden_geo, Int.repr 201327132);
   (SJ._mr_i_geo, Int.repr 218103808);
   (SJ._mr_i_iris_geo, Int.repr 218103836);
   (SJ._mushroom_1up_geo, Int.repr 369102468);
   (SJ._number_geo, Int.repr 369102356);
   (SJ._peach_geo, Int.repr 201327632);
   (SJ._pebble_seg3_dl_0301CB00, Int.repr 50449152);
   (SJ._penguin_geo, Int.repr 201326852);
   (SJ._piranha_plant_geo, Int.repr 218104664);
   (SJ._pokey_body_part_geo, Int.repr 201328196);
   (SJ._pokey_head_geo, Int.repr 201328144);
   (SJ._purple_marble_geo, Int.repr 385875996);
   (SJ._purple_switch_geo, Int.repr 251659468);
   (SJ._red_coin_geo, Int.repr 369099460);
   (SJ._red_coin_no_shadow_geo, Int.repr 369099560);
   (SJ._red_flame_geo, Int.repr 369101612);
   (SJ._red_flame_shadow_geo, Int.repr 369101584);
   (SJ._sand_seg3_dl_0302BCD0, Int.repr 50511056);
   (SJ._script_L1, Int.repr 352322088);
   (SJ._script_L2, Int.repr 352322104);
   (SJ._script_L5, Int.repr 352322152);
   (SJ._script_exec_bbh, Int.repr 352322548);
   (SJ._script_exec_bitdw, Int.repr 352322808);
   (SJ._script_exec_bitfs, Int.repr 352322848);
   (SJ._script_exec_bits, Int.repr 352322888);
   (SJ._script_exec_bob, Int.repr 352322648);
   (SJ._script_exec_bowser_1, Int.repr 352323068);
   (SJ._script_exec_bowser_2, Int.repr 352323108);
   (SJ._script_exec_bowser_3, Int.repr 352323128);
   (SJ._script_exec_castle_courtyard, Int.repr 352322988);
   (SJ._script_exec_castle_grounds, Int.repr 352322788);
   (SJ._script_exec_castle_inside, Int.repr 352322588);
   (SJ._script_exec_ccm, Int.repr 352322568);
   (SJ._script_exec_cotmc, Int.repr 352323028);
   (SJ._script_exec_ddd, Int.repr 352322928);
   (SJ._script_exec_ending, Int.repr 352322968);
   (SJ._script_exec_hmc, Int.repr 352322608);
   (SJ._script_exec_jrb, Int.repr 352322708);
   (SJ._script_exec_level_table, Int.repr 352322168);
   (SJ._script_exec_lll, Int.repr 352322908);
   (SJ._script_exec_pss, Int.repr 352323008);
   (SJ._script_exec_rr, Int.repr 352322768);
   (SJ._script_exec_sa, Int.repr 352322868);
   (SJ._script_exec_sl, Int.repr 352322668);
   (SJ._script_exec_ssl, Int.repr 352322628);
   (SJ._script_exec_thi, Int.repr 352322728);
   (SJ._script_exec_totwc, Int.repr 352323048);
   (SJ._script_exec_ttc, Int.repr 352322748);
   (SJ._script_exec_ttm, Int.repr 352323148);
   (SJ._script_exec_vcutm, Int.repr 352322828);
   (SJ._script_exec_wdw, Int.repr 352322688);
   (SJ._script_exec_wf, Int.repr 352322948);
   (SJ._script_exec_wmotr, Int.repr 352323088);
   (SJ._scuttlebug_geo, Int.repr 218104724);
   (SJ._seaweed_geo, Int.repr 218104452);
   (SJ._skeeter_geo, Int.repr 218103808);
   (SJ._small_key_geo, Int.repr 201326984);
   (SJ._small_water_splash_geo, Int.repr 385876124);
   (SJ._smoke_geo, Int.repr 385876024);
   (SJ._snufit_geo, Int.repr 218104224);
   (SJ._sparkles_animation_geo, Int.repr 385876612);
   (SJ._sparkles_geo, Int.repr 385876412);
   (SJ._spindrift_geo, Int.repr 201326592);
   (SJ._spiny_ball_geo, Int.repr 201327248);
   (SJ._spiny_geo, Int.repr 201327400);
   (SJ._star_geo, Int.repr 369102496);
   (SJ._sushi_geo, Int.repr 201326696);
   (SJ._swoop_geo, Int.repr 218104028);
   (SJ._thwomp_geo, Int.repr 201327176);
   (SJ._toad_geo, Int.repr 218104804);
   (SJ._transparent_star_geo, Int.repr 369102700);
   (SJ._treasure_chest_base_geo, Int.repr 218104912);
   (SJ._treasure_chest_lid_geo, Int.repr 218104936);
   (SJ._tweester_geo, Int.repr 83969584);
   (SJ._ukiki_geo, Int.repr 201326864);
   (SJ._unagi_geo, Int.repr 201326860);
   (SJ._water_bomb_geo, Int.repr 201327368);
   (SJ._water_bomb_shadow_geo, Int.repr 201327400);
   (SJ._water_mine_geo, Int.repr 218104564);
   (SJ._water_ring_geo, Int.repr 218104852);
   (SJ._water_splash_geo, Int.repr 385876528);
   (SJ._wave_trail_geo, Int.repr 385876328);
   (SJ._whirlpool_seg5_dl_05013CB8, Int.repr 83967160);
   (SJ._white_particle_dl, Int.repr 50514080);
   (SJ._white_particle_geo, Int.repr 369102744);
   (SJ._white_particle_small_dl, Int.repr 67316248);
   (SJ._white_puff_geo, Int.repr 369098784);
   (SJ._whomp_geo, Int.repr 218104960);
   (SJ._wiggler_body_geo, Int.repr 83937144);
   (SJ._wiggler_head_geo, Int.repr 201326640);
   (SJ._wooden_post_geo, Int.repr 218103992);
   (SJ._wooden_signpost_geo, Int.repr 369102772);
   (SJ._yellow_coin_geo, Int.repr 369099068);
   (SJ._yellow_coin_no_shadow_geo, Int.repr 369099168);
   (SJ._yellow_sphere_geo, Int.repr 201326592);
   (SJ._yoshi_egg_geo, Int.repr 201327076);
   (SJ._yoshi_geo, Int.repr 201327720)].

Definition demo_jp_numeric_level_main_scripts_entry : list int :=
  map Int.repr
  [403439620; 1125200; 1203632; 403439619; 2094912; 2191568; 386662423; 1203632;
   1215456; 386662422; 2191568; 2195760; 386662419; 2195760; 2217936; 486801408;
   570949633; 385887700; 570949782; 385876024; 570949781; 385876412; 570949800; 385875968;
   570949797; 385876124; 570949798; 385876260; 570949799; 385876528; 570949795; 385876328;
   570949748; 369099068; 570949754; 369102496; 570949753; 369102700; 570949756; 369102772;
   554188964; 67316248; 570949776; 369101612; 570949777; 369101708; 570949780; 385876100;
   570949794; 369101964; 570949802; 385875996; 570949817; 369101892; 570949818; 369101804;
   570949775; 385876612; 554188959; 50511056; 570949819; 369098920; 570949788; 385876100;
   554188961; 50449152; 570949774; 369098752; 570949856; 369098784; 554188958; 50514080;
   570949792; 369102744; 570949749; 369099168; 570949750; 369099264; 570949751; 369099364;
   570949765; 369102248; 570949766; 369102064; 570949767; 369102140; 570949768; 369101988;
   570949768; 369101988; 570949832; 369101488; 570949836; 369101444; 570949835; 369101584;
   570949844; 369102468; 570949847; 369099460; 570949848; 369099560; 570949851; 369102356;
   570949837; 369098816; 570949770; 369102548; 570949771; 369102628; 503578624; 285736960;
   2149891004; 168034304; 1048596; 2769568; 2770736; 335544600; 101187584; 352322168;
   50593793; 185074688; 0; 202113536; 4294967295; 352322104; 202113536; 4294967294;
   352322120; 202113536; 4294967293; 352322136; 202113536; 4294967288; 352322088; 202113536;
   4294967287; 352322152].

Definition demo_jp_numeric_script_exec_level_table : list int :=
  map Int.repr
  [1006895363; 202113536; 4; 352322548; 202113536; 5; 352322568; 202113536;
   6; 352322588; 202113536; 7; 352322608; 202113536; 8; 352322628;
   202113536; 9; 352322648; 202113536; 10; 352322668; 202113536; 11;
   352322688; 202113536; 12; 352322708; 202113536; 13; 352322728; 202113536;
   14; 352322748; 202113536; 15; 352322768; 202113536; 16; 352322788;
   202113536; 17; 352322808; 202113536; 18; 352322828; 202113536; 19;
   352322848; 202113536; 20; 352322868; 202113536; 21; 352322888; 202113536;
   22; 352322908; 202113536; 23; 352322928; 202113536; 24; 352322948;
   202113536; 25; 352322968; 202113536; 26; 352322988; 202113536; 27;
   352323008; 202113536; 28; 352323028; 202113536; 29; 352323048; 202113536;
   30; 352323068; 202113536; 31; 352323088; 202113536; 33; 352323108;
   202113536; 34; 352323128; 202113536; 36; 352323148; 33816576].

Definition demo_jp_numeric_script_exec_bbh : list int :=
  map Int.repr
  [1048590; 3673696; 3677936; 234882072; 117702656].

Definition demo_jp_numeric_script_exec_ccm : list int :=
  map Int.repr
  [1048590; 3752496; 3754192; 234881376; 117702656].

Definition demo_jp_numeric_script_exec_hmc : list int :=
  map Int.repr
  [1048590; 4082272; 4085520; 234881928; 117702656].

Definition demo_jp_numeric_script_exec_jrb : list int :=
  map Int.repr
  [1048590; 4332416; 4335408; 234882796; 117702656].

Definition demo_jp_numeric_script_exec_wf : list int :=
  map Int.repr
  [1048590; 4831728; 4834992; 234882408; 117702656].

Definition demo_jp_numeric_script_exec_pss : list int :=
  map Int.repr
  [1048590; 4939440; 4939888; 234881024; 117702656].

Definition demo_jp_numeric_script_exec_bowser_1 : list int :=
  map Int.repr
  [1048590; 4989280; 4989632; 234881024; 117702656].

Definition demo_jp_numeric_script_exec_bitdw : list int :=
  map Int.repr
  [1048590; 4562592; 4564288; 234881396; 117702656].

Definition demo_script_numeric_image_claim_us_jp : Prop :=
  demo_initializer_image_representation demo_us_script_numeric_relocations
    (gvar_init SU.v_level_main_scripts_entry) demo_us_numeric_level_main_scripts_entry /\
  demo_initializer_image_representation demo_us_script_numeric_relocations
    (gvar_init SU.v_script_exec_level_table) demo_us_numeric_script_exec_level_table /\
  demo_initializer_image_representation demo_us_script_numeric_relocations
    (gvar_init SU.v_script_exec_bbh) demo_us_numeric_script_exec_bbh /\
  demo_initializer_image_representation demo_us_script_numeric_relocations
    (gvar_init SU.v_script_exec_ccm) demo_us_numeric_script_exec_ccm /\
  demo_initializer_image_representation demo_us_script_numeric_relocations
    (gvar_init SU.v_script_exec_hmc) demo_us_numeric_script_exec_hmc /\
  demo_initializer_image_representation demo_us_script_numeric_relocations
    (gvar_init SU.v_script_exec_jrb) demo_us_numeric_script_exec_jrb /\
  demo_initializer_image_representation demo_us_script_numeric_relocations
    (gvar_init SU.v_script_exec_wf) demo_us_numeric_script_exec_wf /\
  demo_initializer_image_representation demo_us_script_numeric_relocations
    (gvar_init SU.v_script_exec_pss) demo_us_numeric_script_exec_pss /\
  demo_initializer_image_representation demo_us_script_numeric_relocations
    (gvar_init SU.v_script_exec_bowser_1) demo_us_numeric_script_exec_bowser_1 /\
  demo_initializer_image_representation demo_us_script_numeric_relocations
    (gvar_init SU.v_script_exec_bitdw) demo_us_numeric_script_exec_bitdw /\
  demo_initializer_image_representation demo_jp_script_numeric_relocations
    (gvar_init SJ.v_level_main_scripts_entry) demo_jp_numeric_level_main_scripts_entry /\
  demo_initializer_image_representation demo_jp_script_numeric_relocations
    (gvar_init SJ.v_script_exec_level_table) demo_jp_numeric_script_exec_level_table /\
  demo_initializer_image_representation demo_jp_script_numeric_relocations
    (gvar_init SJ.v_script_exec_bbh) demo_jp_numeric_script_exec_bbh /\
  demo_initializer_image_representation demo_jp_script_numeric_relocations
    (gvar_init SJ.v_script_exec_ccm) demo_jp_numeric_script_exec_ccm /\
  demo_initializer_image_representation demo_jp_script_numeric_relocations
    (gvar_init SJ.v_script_exec_hmc) demo_jp_numeric_script_exec_hmc /\
  demo_initializer_image_representation demo_jp_script_numeric_relocations
    (gvar_init SJ.v_script_exec_jrb) demo_jp_numeric_script_exec_jrb /\
  demo_initializer_image_representation demo_jp_script_numeric_relocations
    (gvar_init SJ.v_script_exec_wf) demo_jp_numeric_script_exec_wf /\
  demo_initializer_image_representation demo_jp_script_numeric_relocations
    (gvar_init SJ.v_script_exec_pss) demo_jp_numeric_script_exec_pss /\
  demo_initializer_image_representation demo_jp_script_numeric_relocations
    (gvar_init SJ.v_script_exec_bowser_1) demo_jp_numeric_script_exec_bowser_1 /\
  demo_initializer_image_representation demo_jp_script_numeric_relocations
    (gvar_init SJ.v_script_exec_bitdw) demo_jp_numeric_script_exec_bitdw.

Theorem generated_demo_script_numeric_images_us_jp :
  demo_script_numeric_image_claim_us_jp.
Proof.
  unfold demo_script_numeric_image_claim_us_jp.
  repeat match goal with |- _ /\ _ => split end;
    apply demo_initializer_image_matches_sound; vm_compute; reflexivity.
Qed.

Definition demo_script_numeric_dispatch_claim_us_jp : Prop :=
  map (fun header => checked_demo_numeric_dispatch_target header
         demo_us_numeric_script_exec_level_table) demo_dispatch_headers =
    map (demo_expected_numeric_route demo_us_script_numeric_relocations)
      expected_demo_dispatch_routes /\
  map (fun header => checked_demo_numeric_dispatch_target header
         demo_jp_numeric_script_exec_level_table) demo_dispatch_headers =
    map (demo_expected_numeric_route demo_jp_script_numeric_relocations)
      expected_demo_dispatch_routes.

Theorem generated_demo_script_numeric_dispatch_us_jp :
  demo_script_numeric_dispatch_claim_us_jp.
Proof. vm_compute. split; reflexivity. Qed.

Definition demo_script_numeric_image_boundary_claim_us_jp : Prop :=
  demo_script_numeric_image_claim_us_jp /\
  demo_script_numeric_dispatch_claim_us_jp /\
  (forall injection block offset address,
    ~ Val.inject injection (Vptr block offset) (Vint address)).

Theorem generated_demo_script_numeric_image_boundary_us_jp :
  demo_script_numeric_image_boundary_claim_us_jp.
Proof.
  exact (conj generated_demo_script_numeric_images_us_jp
    (conj generated_demo_script_numeric_dispatch_us_jp
      demo_symbolic_pointer_is_not_integer_injection)).
Qed.
