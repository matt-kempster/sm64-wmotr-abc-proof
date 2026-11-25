(* spine-root: the sweep census behind BhvStep.native_res (the residual
   CALL_NATIVE row the capstones' objects rows carry inside rest_keeps). *)
(* ======================================================================= *)
(* NativeSweep.v -- WHICH native_res CASES CAN AN INV-STATE REACH, AND     *)
(* WHICH CAN BREAK THE SCRIPT CLAUSE? (GOAL 2 objects, 2026-11-13)         *)
(*                                                                         *)
(* native_res is asked at Qs := ObjFamily.Qfam, per (script, word, native) *)
(* site: every CALL_NATIVE word of a special script, every native without  *)
(* a nullary SFR' entry at a generic script.  79 sites (res_sites).        *)
(*                                                                         *)
(* 1 DEAD sites (11, dead_sites_value): the script is not in               *)
(*   ObjWorld.live_bhvs (a cut exclamation-box content, or the jumping     *)
(*   box).  Qfam contains In (v_s st) live_bhvs, so the row's premise Qs   *)
(*   st is false there (dead_site_vacuous, proved): TRUE, nothing asked.   *)
(* 2 LIVE sites (68; 62 natives): the real surface.  For the SCRIPT clause *)
(*   (obj_w: every slot runs a live script) the detector unlive_reach      *)
(*   lists the non-live behaviors in a native's reference closure (over    *)
(*   the generated ASTs).  Only two natives reach one (unlive_reach_value):*)
(*   - try_do_mario_debug_object_spawn: gated by obj_w's DEBUG clause;     *)
(*   - bhv_exclamation_box_loop: through sExclamationBoxContents, indexed  *)
(*     by the box's oBehParams2ndByte, which obj_w does NOT pin (BoxCensus *)
(*     resolves the real boxes' ids, a census).  FOUND: an INV-state with  *)
(*     a box slot in act 4 whose byte is 3 spawns bhvKoopaShell.           *)
(*     REPAIRED 2026-11-14 (INV strengthened, no transfer proof): the slot *)
(*     table's row 2 (ObjWorld.box_at) pins the byte of a slot running the *)
(*     box script to BoxCensus.box_ids (box_row_census below).             *)
(*   For the other 60 natives no spawn can leave live_bhvs.                *)
(* 3 red_ok's "no slot is a bhvStarSpawnCoordinates": only two live        *)
(*   residual natives reach that behavior (star_reach_value):              *)
(*   bhv_hidden_red_coin_star_loop and bhv_mario_update.                   *)
(*                                                                         *)
(* A census, not a proof of native_res: the row stays inside rest_keeps.   *)
(* The per-case verdicts read off it are in the proof-discipline skill's   *)
(* open surface and docs/TRUST.md row 0.7.                                 *)
(* ======================================================================= *)
From Coq Require Import ZArith List Bool String Lia.
From compcert Require Import Integers AST Ctypesdefs.
From compcert Require Coqlib Values Memory Globalenvs Clight.
From SM64.Proofs.WMotRRequiresA Require Import BhvVM BehaviorScripts.
From SM64.Proofs.WMotRRequiresA Require ObjWorld BhvStep ObjFamily ObjFrame BoxCensus WMotRLevel WMotRWorld.
Import ListNotations.
Local Open Scope Z_scope.

Definition live (s : ident) : bool := existsb (Pos.eqb s) ObjWorld.live_bhvs.
Definition sp (s : ident) : bool := existsb (Pos.eqb s) BhvStep.sp_scripts.
Definition site : Type := (ident * nat * ident)%type.
Definition site_eqb (x y : site) : bool :=
  let '(s, i, f) := x in let '(s', i', f') := y in Pos.eqb s s' && Nat.eqb i i' && Pos.eqb f f'.
Fixpoint sdd (l : list site) : list site :=
  match l with [] => [] | x :: l' => if existsb (site_eqb x) l' then sdd l' else x :: sdd l' end.
Definition res_sites : list site :=
  sdd (flat_map (fun st =>
         map (fun f => (v_s st, v_i st, f))
             (filter (fun f => sp (v_s st) || negb (BhvStep.has_null f ObjFrame.self_tab_n)) (BhvStep.cn_st st)))
       vm_tab).
Definition dead_sites : list site := filter (fun x => negb (live (fst (fst x)))) res_sites.
Definition live_sites : list site := filter (fun x => live (fst (fst x))) res_sites.
Definition live_res_natives : list ident := BhvStep.idd (map snd live_sites).
Definition unlive_reach (f : ident) : list ident :=
  filter (fun x => is_bhv_sym x && negb (live x)) (closure_of [f]).
Definition sname (x : site) := (string_of_ident (fst (fst x)), snd (fst x), string_of_ident (snd x)).

Definition SSC : ident := ident_of_string "bhvStarSpawnCoordinates".

Lemma sweep_counts :
  (List.length res_sites, List.length dead_sites, List.length live_sites, List.length live_res_natives)
  = (79, 11, 68, 62)%nat.
Proof. vm_compute. reflexivity. Qed.

Lemma dead_sites_value : map sname dead_sites =
  [("bhvJumpingBox", 8%nat, "bhv_jumping_box_loop");
   ("bhvBlueCoinJumping", 8%nat, "bhv_blue_coin_jumping_loop");
   ("bhvBlueCoinJumping", 5%nat, "bhv_blue_coin_sliding_jumping_init");
   ("bhvVanishCap", 5%nat, "bhv_wing_vanish_cap_loop");
   ("bhv1UpRunningAway", 10%nat, "bhv_1up_running_away_loop");
   ("bhvKoopaShellFlame", 6%nat, "bhv_koopa_shell_flame_loop");
   ("bhvKoopaShell", 8%nat, "bhv_koopa_shell_loop");
   ("bhvKoopaShellUnderwater", 3%nat, "bhv_koopa_shell_underwater_loop");
   ("bhvSingleCoinGetsSpawned", 11%nat, "bhv_spawned_coin_loop");
   ("bhvSingleCoinGetsSpawned", 3%nat, "bhv_spawned_coin_init");
   ("bhvMetalCap", 5%nat, "bhv_metal_cap_loop")]%string.
Proof. vm_compute. reflexivity. Qed.

(* the special scripts' live sites: the 12 cases that need a transfer proof each *)
Lemma special_live_sites_value : map sname (filter (fun x => sp (fst (fst x))) live_sites) =
  [("bhvHiddenRedCoinStar", 5%nat, "bhv_hidden_red_coin_star_loop");
   ("bhvHiddenRedCoinStar", 2%nat, "bhv_hidden_red_coin_star_init");
   ("bhvPoleGrabbing", 9%nat, "bhv_pole_base_loop");
   ("bhvPoleGrabbing", 5%nat, "bhv_pole_init");
   ("bhvCannon", 12%nat, "bhv_cannon_base_loop");
   ("bhvCannonClosed", 10%nat, "load_object_collision_model");
   ("bhvCannonClosed", 8%nat, "bhv_cannon_closed_loop");
   ("bhvCannonClosed", 5%nat, "bhv_cannon_closed_init");
   ("bhvExclamationBox", 8%nat, "bhv_exclamation_box_loop");
   ("bhvMario", 11%nat, "try_do_mario_debug_object_spawn");
   ("bhvMario", 9%nat, "bhv_mario_update");
   ("bhvMario", 7%nat, "try_print_debug_mario_level_info")]%string.
Proof. vm_compute. reflexivity. Qed.

(* 1: the row asks nothing at a dead site *)
Lemma dead_site_vacuous : forall s0 st, ObjFamily.Qfam s0 st -> live (v_s st) = true.
Proof.
  intros s0 st H. unfold live. apply existsb_exists. exists (v_s st).
  split; [ exact (ObjFamily.Qfam_live s0 st H) | apply Pos.eqb_refl ].
Qed.

Lemma dead_site_no_Q : forall s0 st, live (v_s st) = false -> ~ ObjFamily.Qfam s0 st.
Proof. intros s0 st E Q. rewrite (dead_site_vacuous s0 st Q) in E. discriminate E. Qed.

Lemma dead_sites_dead : forallb (fun x => negb (live (fst (fst x)))) dead_sites = true.
Proof. vm_compute. reflexivity. Qed.

(* 2: the SCRIPT clause's candidates *)
Lemma unlive_reach_value :
  map string_of_ident (filter (fun f => match unlive_reach f with [] => false | _ => true end) live_res_natives)
  = ["bhv_exclamation_box_loop"; "try_do_mario_debug_object_spawn"]%string.
Proof. vm_compute. reflexivity. Qed.

(* 3: who can bring a bhvStarSpawnCoordinates into being *)
Lemma star_reach_value :
  map string_of_ident (filter (fun f => existsb (Pos.eqb SSC) (closure_of [f])) live_res_natives)
  = ["bhv_hidden_red_coin_star_loop"; "bhv_mario_update"]%string.
Proof. vm_compute. reflexivity. Qed.

(* 2, REPAIRED 2026-11-14: obj_w's slot table pins a box slot's contents
   byte (ObjWorld.box_at) to exactly the census's ids of WMotR's boxes *)
Lemma box_row_census : forall p, (p = Int.zero \/ p = Int.repr 7) <-> In (Int.signed p) BoxCensus.box_ids.
Proof.
  intros p. rewrite BoxCensus.box_ids_value. cbn [In]. split.
  - intros [-> | ->]; [ right; left | left ]; reflexivity.
  - intros [E | [E | []]]; [ right | left ]; rewrite <- (Int.repr_signed p), <- E; reflexivity.
Qed.

(* 4 (2026-11-24): the NOT DECIDED live natives, classed by what their
   reference closure (generated ASTs) reaches.  A census: it names which
   sites can create / free a slot or read Mario at all; it proves no site. *)
Definition reach (x : string) (f : ident) : bool :=
  existsb (Pos.eqb (ident_of_string x)) (closure_of [f]).
Definition spawns (f : ident) : bool := reach "allocate_object" f || reach "unload_object" f.
Definition sees_mario (f : ident) : bool := reach "gMarioStates" f || reach "gMarioObject" f.
Definition closed_native (f : ident) : bool :=
  negb (spawns f || sees_mario f || reach "load_object_collision_model" f || reach "gMarioPlatform" f
        || reach "cur_obj_nearest_object_with_behavior" f || reach "save_file_set_flags" f).

Lemma reach_counts :
  (List.length (filter closed_native live_res_natives),
   List.length (filter spawns live_res_natives),
   List.length (filter sees_mario live_res_natives)) = (12, 42, 22)%nat.
Proof. vm_compute. reflexivity. Qed.

(* the 12 live residual natives that reach none of those: no slot is
   created or freed, Mario is not read *)
Lemma closed_natives_value : map string_of_ident (filter closed_native live_res_natives) =
  ["bhv_tree_snow_or_leaf_loop"; "bhv_pole_init"; "bhv_bowser_key_course_exit_loop";
   "bhv_bowser_key_unlock_door_loop"; "bhv_init_room"; "bhv_star_spawn_init"; "bhv_collect_star_init";
   "bhv_cannon_base_loop"; "bhv_white_puff_exploding_loop"; "bhv_end_toad_loop"; "bhv_end_peach_loop";
   "try_print_debug_mario_level_info"]%string.
Proof. vm_compute. reflexivity. Qed.

(* 5 (2026-11-24) FOUND: live_bhvs still holds the star family.  script_ok
   admits a slot that runs bhvStar / bhvStarSpawnCoordinates, and at such a
   slot native_res asks bhv_collect_star_init, which stores INTERACT_STAR:
   KIND breaks.  The family's 13 live sites, and the only bodies / scripts
   of the closure that mention a member (so the only spawners). *)
Definition star_fam : list ident := map ident_of_string
  ["bhvStar"; "bhvStarSpawnCoordinates"; "bhvCelebrationStar"; "bhvSpawnedStarNoLevelExit";
   "bhvBowserKeyUnlockDoor"; "bhvBowserKeyCourseExit"; "bhvEndToad"; "bhvEndPeach"; "bhvUnlockDoorStar"]%string.
Definition in_fam (x : ident) : bool := existsb (Pos.eqb x) star_fam.

Lemma star_fam_live : forallb live star_fam = true.
Proof. vm_compute. reflexivity. Qed.

Lemma star_fam_sites_value : map sname (filter (fun x => in_fam (fst (fst x))) live_sites) =
  [("bhvBowserKeyCourseExit", 5%nat, "bhv_bowser_key_course_exit_loop");
   ("bhvBowserKeyUnlockDoor", 5%nat, "bhv_bowser_key_unlock_door_loop");
   ("bhvStar", 4%nat, "bhv_collect_star_init");
   ("bhvStar", 2%nat, "bhv_init_room");
   ("bhvStarSpawnCoordinates", 7%nat, "bhv_star_spawn_loop");
   ("bhvStarSpawnCoordinates", 4%nat, "bhv_star_spawn_init");
   ("bhvStarSpawnCoordinates", 2%nat, "bhv_collect_star_init");
   ("bhvSpawnedStarNoLevelExit", 6%nat, "bhv_spawned_star_loop");
   ("bhvCelebrationStar", 5%nat, "bhv_celebration_star_loop");
   ("bhvUnlockDoorStar", 5%nat, "bhv_unlock_door_star_loop");
   ("bhvUnlockDoorStar", 2%nat, "bhv_unlock_door_star_init");
   ("bhvEndToad", 6%nat, "bhv_end_toad_loop");
   ("bhvEndPeach", 6%nat, "bhv_end_peach_loop")]%string.
Proof. vm_compute. reflexivity. Qed.

Lemma star_fam_referrers :
  map string_of_ident (filter (fun x => existsb in_fam (refs_of x)) wmotr_closure) =
  ["general_star_dance_handler"; "spawn_star"; "act_exit_land_save_dialog"; "act_end_waving_cutscene";
   "act_unlocking_key_door"; "act_unlocking_star_door"; "end_peach_cutscene_spawn_peach"; "bhvSpawnedStar";
   "bhv_spawn_star_no_level_exit"; "bhv_hidden_red_coin_star_init"]%string.
Proof. vm_compute. reflexivity. Qed.

(* 6 (2026-11-25) THE CANNON-UNLOCKED BIT.  Not pinned, and not pinnable:
   the bit (save_file_is_cannon_unlocked: courseStars[course] & 0x80) is
   NOT constant 0 under no-A.  Read off the generated Clight:
   - interaction.check_npc_talk tests m->input & 0x2002 (INPUT_A_PRESSED |
     INPUT_B_PRESSED); mario.update_mario_button_inputs sets 0x2000 from
     B_BUTTON (0x4000) pressed.  So B starts a talk: oInteractStatus :=
     INTERACTED, ACT_WAITING_FOR_DIALOG (0x130A).
   - obj_behaviors.bobomb_buddy_act_idle moves to turn-to-talk on that
     status; bobomb_buddy_act_talk, role 1, calls bobomb_buddy_cannon_dialog,
     whose case 0 calls save_file_set_cannon_unlocked once
     cutscene_object_with_dialog returns non-zero (the dialog closed).
   - ingame_menu.render_dialog_entries advances / closes a dialog on
     gPlayer3Controller->buttonPressed & A_BUTTON (0x8000) OR B_BUTTON
     (0x4000).
   So with the bit set, bhv_cannon_closed_init (bhvCannonClosed word 5, and
   from the loop, word 8, at the opening action's timer 80) spawns a
   bhvCannon slot: create_object starts it at word 0, allocate_object zeroes
   rawData (oAction, oPrevAction, oTimer, oInteractType = 0), and the init
   stores the lid's oHome into its oPos.  The lid's home is a lid position
   (row 3 past word 4: ObjWorld.lid_at_off; inside an update ObjInv.HLk).
   PROVED here: that slot satisfies the cannon's EXISTING pins -- kind_ok,
   act_ok, pin_at (C through cannon_xz_ok at jitter 0, rise step 68:
   lid y = lid y - 340 + 5 * 68; can_pin and can_traj's can0 at word 0) --
   so the bit-set state is inside obj_w's per-slot pins and needs no new
   clause.  OPEN (narrowed, inside native_res): that the real runs of
   bhv_cannon_closed_init / bhv_cannon_closed_loop produce that slot and
   keep the rest of the invariant (the spawn's list / gfx / parent cells,
   HLk, the lid's deactivation). *)
Module LidSpawn.
Import Coqlib Values Memory Globalenvs Clight WMotRLevel WMotRWorld ObjWorld.

Lemma lid_xzy_b : forallb (fun t => match t with (x, y, z) =>
    existsb (fun u => match u with (x', z', s) => (x' =? x) && (z' =? z) && (s =? y + CANNON_SEAT) end)
      wmotr_cannon_xzy end) cannon_lid_xyz = true.
Proof. vm_compute. reflexivity. Qed.

(* a lid position's x / z and y + 350 is a cannon seat entry (rise step 68) *)
Lemma lid_xzy : forall x y z, In (x, y, z) cannon_lid_xyz -> In (x, z, y + CANNON_SEAT) wmotr_cannon_xzy.
Proof.
  intros x y z H. pose proof (proj1 (forallb_forall _ _) lid_xzy_b _ H) as E. cbv beta iota in E.
  apply existsb_exists in E as (((x' & z') & s) & Hin & E).
  apply andb_prop in E as [E E3]. apply andb_prop in E as [E1 E2].
  apply Z.eqb_eq in E1, E2, E3. subst x' z' s. exact Hin.
Qed.

Lemma lid_y_in : forall x y z, In (x, y, z) cannon_lid_xyz -> In y cannon_lids.
Proof.
  intros x y z H. unfold cannon_lid_xyz in H. unfold cannon_lids.
  apply in_map_iff in H as (o & E & Ho). injection E as _ <- _. exact (in_map m_y _ o Ho).
Qed.

(* a slot running script s runs no other script *)
Lemma runs_other : forall (ge : genv) pool m k s bs o id,
  Genv.find_symbol ge s = Some bs -> ld32 m pool (k * OSZ + O_CMD) = Some (Vptr bs o) -> id <> s ->
  runs ge pool m k id = false.
Proof.
  intros ge pool m k s bs o id Hs L N. unfold runs, sym_is. rewrite L.
  destruct (Genv.find_symbol ge id) as [b |] eqn:Hb; [ | reflexivity ].
  apply Pos.eqb_neq. intros <-. apply N. eapply Genv.genv_vars_inj; [ exact Hb | exact Hs ].
Qed.

(* a slot running none of the table's scripts passes the table *)
Lemma tab_at_nr : forall (ge : genv) pool m k,
  (forall r, In r slot_tab -> runs ge pool m k (tr_s r) = false) -> tab_at ge pool m k.
Proof.
  intros ge pool m k H. unfold tab_at. apply forallb_forall. intros r Hr.
  specialize (H r Hr). unfold row_b. unfold runs, sym_is in H.
  destruct (Genv.find_symbol ge (tr_s r)) as [b |]; [ | reflexivity ].
  destruct (ld32 m pool (k * OSZ + O_CMD)) as [[| | | | | b' o] |]; try reflexivity.
  rewrite H. reflexivity.
Qed.

Lemma tab_not_cans : forallb (fun r => negb (Pos.eqb (tr_s r) CANS)) slot_tab = true.
Proof. vm_compute. reflexivity. Qed.

Lemma poles_not_cans : POLES <> CANS.
Proof. vm_compute. discriminate. Qed.

(* the spawned base: word 0 of bhvCannon, zeroed rawData, at a lid position *)
Lemma lid_spawn_ok : forall (ge : genv) pool m j bc x y z,
  Genv.find_symbol ge CANS = Some bc ->
  ld32 m pool (j * OSZ + O_CMD) = Some (Vptr bc Ptrofs.zero) ->
  Mem.load Mint32 m pool (j * OSZ + O_INTERACT_TYPE) = Some (Vint Int.zero) ->
  can_apt m pool (j * OSZ) Int.zero Int.zero Int.zero ->
  In (x, y, z) cannon_lid_xyz -> can_pos m pool (j * OSZ) x y z ->
  kind_ok pool m j /\ act_ok ge pool m j /\ pin_at ge pool m j.
Proof.
  intros ge pool m j bc x y z Hc Lc Lt Ha Hin Hp.
  pose proof Ha as (La & _ & _). pose proof Hp as (Lx & Ly & Lz).
  split; [ | split ].
  - exists Int.zero. rewrite Int.unsigned_zero. split; [ exact Lt | split; [ unfold wmotr_interact_types; left; reflexivity | ] ].
    unfold INTERACT_POLE, INTERACT_CANNON_BASE. repeat split; intros E; discriminate E.
  - intros bh t Hbt _. exists Int.zero. split; [ exact La | ].
    apply (in_map (fun p => tlen (snd p))) in Hbt. rewrite act_tables_pinned in Hbt. cbn [snd] in Hbt.
    rewrite Int.signed_zero. cbn [In] in Hbt. lia.
  - split; [ | split; [ | split; [ | split ] ] ].
    + intros t Lt'. rewrite Lt in Lt'. injection Lt' as <-. rewrite Int.unsigned_zero.
      unfold INTERACT_POLE, INTERACT_CANNON_BASE. split; [ intros E; discriminate E | split; [ intros E; discriminate E | ] ].
      intros _ _. exists x, z, (y + CANNON_SEAT), 0. split; [ exact (lid_xzy x y z Hin) | split; [ left; reflexivity | ] ].
      rewrite Z.add_0_r, Z.add_0_r. replace (y + CANNON_SEAT - CANNON_SEAT) with y by lia.
      exact (conj Lx (conj Ly Lz)).
    + intros R. rewrite (runs_other ge pool m j CANS bc Ptrofs.zero POLES Hc Lc poles_not_cans) in R. discriminate R.
    + intros b o Hb L. rewrite Hc in Hb. injection Hb as <-. rewrite Lc in L. injection L as <-.
      left. rewrite Ptrofs.unsigned_zero. split; [ reflexivity | ]. exists y. exact (conj (lid_y_in x y z Hin) Ly).
    + intros b o Hb L. rewrite Hc in Hb. injection Hb as <-. rewrite Lc in L. injection L as <-.
      rewrite Ptrofs.unsigned_zero. exists x, y, z. exact (conj Hin (conj Hp Ha)).
    + apply tab_at_nr. intros r Hr. apply (runs_other ge pool m j CANS bc Ptrofs.zero _ Hc Lc).
      pose proof (proj1 (forallb_forall _ _) tab_not_cans r Hr) as E. cbv beta in E.
      intros Er. rewrite Er, Pos.eqb_refl in E. discriminate E.
Qed.

(* ... stated from the lid: the base's position cells hold a lid home *)
Lemma lid_cannon_ok : forall (ge : genv) pool m k j bc,
  lid_home m pool (k * OSZ) ->
  Mem.load Mfloat32 m pool (j * OSZ + O_POSX) = Mem.load Mfloat32 m pool (k * OSZ + O_HOMEX) ->
  Mem.load Mfloat32 m pool (j * OSZ + O_POSY) = Mem.load Mfloat32 m pool (k * OSZ + O_HOMEY) ->
  Mem.load Mfloat32 m pool (j * OSZ + O_POSZ) = Mem.load Mfloat32 m pool (k * OSZ + O_HOMEZ) ->
  Genv.find_symbol ge CANS = Some bc ->
  ld32 m pool (j * OSZ + O_CMD) = Some (Vptr bc Ptrofs.zero) ->
  Mem.load Mint32 m pool (j * OSZ + O_INTERACT_TYPE) = Some (Vint Int.zero) ->
  can_apt m pool (j * OSZ) Int.zero Int.zero Int.zero ->
  kind_ok pool m j /\ act_ok ge pool m j /\ pin_at ge pool m j.
Proof.
  intros ge pool m k j bc (x & y & z & Hin & Hx & Hy & Hz) Ex Ey Ez Hc Lc Lt Ha.
  apply (lid_spawn_ok ge pool m j bc x y z Hc Lc Lt Ha Hin).
  unfold can_pos. rewrite Ex, Ey, Ez. exact (conj Hx (conj Hy Hz)).
Qed.
End LidSpawn.
