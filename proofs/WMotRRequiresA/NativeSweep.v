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
(*   For the other 60 natives no spawn can leave live_bhvs.                *)
(* 3 red_ok's "no slot is a bhvStarSpawnCoordinates": only two live        *)
(*   residual natives reach that behavior (star_reach_value):              *)
(*   bhv_hidden_red_coin_star_loop and bhv_mario_update.                   *)
(*                                                                         *)
(* A census, not a proof of native_res: the row stays inside rest_keeps.   *)
(* The per-case verdicts read off it are in the proof-discipline skill's   *)
(* open surface and docs/TRUST.md row 0.7.                                 *)
(* ======================================================================= *)
From Coq Require Import ZArith List Bool String.
From compcert Require Import Integers AST Ctypesdefs.
From SM64.Proofs.WMotRRequiresA Require Import BhvVM BehaviorScripts.
From SM64.Proofs.WMotRRequiresA Require ObjWorld BhvStep ObjFamily ObjFrame.
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
