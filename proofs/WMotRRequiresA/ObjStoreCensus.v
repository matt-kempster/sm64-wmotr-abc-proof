(* spine-root: OBJECTS phase S3 groundwork -- the store census of the code
   a non-Mario object slot runs in WMotR (the behavior-script VM and the
   live natives, BehaviorScripts.wmotr_live_natives), vm-pinned like
   UpdateCameraBody.uc_census.  It lists every store (and pointer handed
   to a callee) whose target is NOT the running object's own block, i.e.
   exactly where a "a slot writes only its own object" (kW) walker must
   charge an exception.  Consumed by the S3 class walker and the obj_w
   invariant (S2). *)
(* ======================================================================= *)
(* WHAT CAN A WMOTR OBJECT'S SCRIPT WRITE BESIDES ITSELF?                   *)
(*                                                                          *)
(* update_objects runs, for each active pool slot, cur_obj_update with     *)
(* gCurrentObject = that slot ("o" in the decomp is gCurrentObject).  The  *)
(* code it can run is the reference closure (AngleVelCensus.close2, over   *)
(* BehaviorScripts.all_tus; spawned behaviors' scripts are not followed,  *)
(* their code runs on the new object) of cur_obj_update -- the behavior    *)
(* command table and everything it calls -- and of the live natives,       *)
(* minus bhv_mario_update (the Mario slot runs execute_mario_action, the   *)
(* frame the capstones already walk).                                      *)
(*                                                                          *)
(* For every function in that closure with a body, the census resolves the *)
(* root block of each store target and each pointer-typed call argument    *)
(* through the body's own temp definitions:                                *)
(*   RLoc         a stack local;                                           *)
(*   RSelf        the running object (a pointer loaded from gCurrentObject) *)
(*   RGlob g      the global g itself (a field / cell of it, or &g);       *)
(*   RVia g       a block reached through the pointer held in global g;    *)
(*   RParam t     the block of parameter t (charged to the callers' args); *)
(*   RCall f      a block returned by the call to f (e.g. spawn_object);   *)
(*   RPtr         a pointer loaded from memory or otherwise unresolved.    *)
(* The own-object class is RLoc, RSelf and RParam (charged).  The census  *)
(* pins, per function, the roots outside it.  It is a census, not a proof: *)
(* each entry is a place where a kW walker needs a contract.               *)
(* ======================================================================= *)

From Coq Require Import ZArith List Bool String.
From compcert Require Import Coqlib Integers AST Ctypes Cop Clight Maps Ctypesdefs Clightdefs.
From SM64.Generated Require behavior_actions behavior_script behavior_data.
From SM64.Proofs.WMotRRequiresA Require Import BehaviorScripts AngleVelCensus.
Import ListNotations.

Local Open Scope Z_scope.

Definition mem_i (x : ident) (l : list ident) : bool := existsb (Pos.eqb x) l.

Inductive sroot : Type :=
  | RLoc | RSelf | RGlob (g : ident) | RVia (g : ident) | RParam (t : ident)
  | RCall (f : ident) | RPtr.

Definition sroot_beq (a b : sroot) : bool :=
  match a, b with
  | RLoc, RLoc | RSelf, RSelf | RPtr, RPtr => true
  | RGlob x, RGlob y | RVia x, RVia y | RParam x, RParam y | RCall x, RCall y => Pos.eqb x y
  | _, _ => false
  end.

Fixpoint snodup (l : list sroot) : list sroot :=
  match l with
  | nil => nil
  | r :: l' => let t := snodup l' in if existsb (sroot_beq r) t then t else r :: t
  end.

(* a temp's definition: an expression, or the result of a direct call *)
Inductive tdef := TExpr (a : expr) | TCall (f : ident).

Fixpoint c_defs (s : statement) : list (ident * tdef) :=
  match s with
  | Sset t a => [(t, TExpr a)]
  | Scall (Some t) (Evar f _) _ => [(t, TCall f)]
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 => c_defs s1 ++ c_defs s2
  | Slabel _ s1 => c_defs s1
  | Sswitch _ sl => c_defs_ls sl
  | _ => nil
  end
with c_defs_ls (sl : labeled_statements) : list (ident * tdef) :=
  match sl with LSnil => nil | LScons _ s sl' => c_defs s ++ c_defs_ls sl' end.

(* the targets: lvalues stored to (Sassign), and pointer-typed call /
   builtin arguments, marked false / true *)
Fixpoint c_targets (s : statement) : list (bool * expr) :=
  match s with
  | Sassign l _ => [(false, l)]
  | Scall _ _ al | Sbuiltin _ _ _ al =>
      map (fun a => (true, a))
        (filter (fun a => match typeof a with Tpointer _ _ | Tarray _ _ _ => true | _ => false end) al)
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 => c_targets s1 ++ c_targets s2
  | Slabel _ s1 => c_targets s1
  | Sswitch _ sl => c_targets_ls sl
  | _ => nil
  end
with c_targets_ls (sl : labeled_statements) : list (bool * expr) :=
  match sl with LSnil => nil | LScons _ s sl' => c_targets s ++ c_targets_ls sl' end.

Definition GCUR : ident := behavior_actions._gCurrentObject.

Definition decays (ty : type) : bool :=
  match ty with Tarray _ _ _ | Tfunction _ _ _ => true | _ => false end.

(* the values stored into each local variable (Sassign (Evar x) rhs) *)
Fixpoint c_lassigns (s : statement) : list (ident * expr) :=
  match s with
  | Sassign (Evar x _) r => [(x, r)]
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 => c_lassigns s1 ++ c_lassigns s2
  | Slabel _ s1 => c_lassigns s1
  | Sswitch _ sl => c_lassigns_ls sl
  | _ => nil
  end
with c_lassigns_ls (sl : labeled_statements) : list (ident * expr) :=
  match sl with LSnil => nil | LScons _ s sl' => c_lassigns s ++ c_lassigns_ls sl' end.

(* a local that only ever holds a parameter's value (an address-taken
   parameter spilled to the stack, e.g. math_util's vec3f_set) *)
Definition local_param (ps : list ident) (las : list (ident * expr)) (x : ident) : option ident :=
  match filter (fun p => Pos.eqb (fst p) x) las with
  | [(_, Etempvar p _)] => if mem_i p ps then Some p else None
  | _ => None
  end.

Section ROOT.
  Variable lv ps : list ident.
  Variable defs : list (ident * tdef).
  Variable las : list (ident * expr).
  (* the root blocks of a pointer VALUE, and of an lvalue, depth-bounded.
     A temp's roots are the union over ALL its definitions in the body (a
     temp may be set more than once); a parameter temp that is also
     re-set gets its parameter root and every definition's.  A temp already
     being resolved (vis, e.g. dest = dest + 1 in a loop) contributes
     nothing more: the roots are the least fixed point of the equations. *)
  Fixpoint pval (vis : list ident) (n : nat) (a : expr) : list sroot :=
    match n with O => [RPtr] | S n' =>
    match a with
    | Evar x ty =>
        if mem_i x lv then
          (if decays ty then [RLoc]
           else match local_param ps las x with Some p => [RParam p] | None => [RPtr] end)
        else if decays ty then [RGlob x]
        else if Pos.eqb x GCUR then [RSelf] else [RVia x]
    | Eaddrof l _ => lblk vis n' l
    | Ecast a1 _ => pval vis n' a1
    | Ebinop _ a1 _ _ => pval vis n' a1
    | Etempvar t _ =>
        if mem_i t vis then nil else
        (if mem_i t ps then [RParam t] else nil) ++
        match filter (fun p => Pos.eqb (fst p) t) defs with
        | nil => if mem_i t ps then nil else [RPtr]
        | ds => flat_map (fun p => match snd p with
                                   | TExpr d => pval (t :: vis) n' d
                                   | TCall f => [RCall f]
                                   end) ds
        end
    | Efield _ _ ty | Ederef _ ty =>
        (* an array member decays to its own address; otherwise a pointer
           loaded from memory *)
        if decays ty then lblk vis n' a else [RPtr]
    | _ => [RPtr]
    end end
  with lblk (vis : list ident) (n : nat) (l : expr) : list sroot :=
    match n with O => [RPtr] | S n' =>
    match l with
    | Evar x _ => if mem_i x lv then [RLoc] else [RGlob x]
    | Efield a1 _ _ => lblk vis n' a1
    | Ederef a1 _ => pval vis n' a1
    | _ => [RPtr]
    end end.
End ROOT.

Definition own (r : sroot) : bool :=
  match r with RLoc | RSelf | RParam _ => true | _ => false end.

Definition out_roots (want_arg : bool) (f : Clight.function) : list sroot :=
  let lv := map fst (fn_vars f) in
  let ps := map fst (fn_params f) in
  let ds := c_defs (fn_body f) in
  let las := c_lassigns (fn_body f) in
  snodup (filter (fun r => negb (own r))
            (flat_map (fun (p : bool * expr) => let '(isarg, a) := p in
                    if isarg then pval lv ps ds las nil 16 a else lblk lv ps ds las nil 16 a)
                 (filter (fun p => Bool.eqb (fst p) want_arg) (c_targets (fn_body f))))).

(* the function table: every internal definition of the census TUs *)
Definition ftab : PTree.t (list Clight.function) :=
  fold_left (fun t defs => fold_left (fun t '(id, g) =>
    match g with
    | Gfun (Internal f) => PTree.set id (f :: match PTree.get id t with Some o => o | None => nil end) t
    | _ => t
    end) defs t) all_tus (PTree.empty _).

(* the roots of the object closure: the VM and the live natives, Mario's
   update excluded *)
Definition obj_roots : list ident :=
  behavior_script._cur_obj_update
  :: filter (fun f => negb (Pos.eqb f behavior_data._bhv_mario_update)) wmotr_live_natives.

Definition obj_code : list ident :=
  map fst (PTree.elements (close2 1000000 obj_roots (PTree.empty _))).

Definition obj_fns : list ident :=
  filter (fun x => match PTree.get x ftab with Some _ => true | None => false end) obj_code.

Definition census_of (want_arg : bool) (x : ident) : list (ident * list sroot) :=
  match PTree.get x ftab with
  | Some fs => match snodup (flat_map (out_roots want_arg) fs) with nil => nil | l => [(x, l)] end
  | None => nil
  end.

(* the STORES outside the running object, and the pointer ARGUMENTS outside
   it (what a callee may store through, charged to this caller) *)
Definition obj_census : list (ident * list sroot) := flat_map (census_of false) obj_fns.
Definition obj_arg_census : list (ident * list sroot) := flat_map (census_of true) obj_fns.

(* readable form *)
Definition sroot_str (r : sroot) : string :=
  match r with
  | RLoc => "loc" | RSelf => "self" | RPtr => "ptr"
  | RGlob g => "glob " ++ string_of_ident g
  | RVia g => "via " ++ string_of_ident g
  | RParam t => "param " ++ string_of_ident t
  | RCall f => "call " ++ string_of_ident f
  end.
Definition cstr (c : list (ident * list sroot)) : list (string * list string) :=
  map (fun (p : ident * list sroot) => (string_of_ident (fst p), map sroot_str (snd p))) c.

(* the distinct store roots outside the running object, over the whole
   closure, and the functions that store through a pointer the census cannot
   resolve (loaded from memory): the places a kW walker needs a real
   points-to contract, not a frame row *)
Definition obj_store_roots : list sroot := snodup (flat_map snd obj_census).
Definition obj_ptr_store_fns : list ident :=
  map fst (filter (fun p => existsb (sroot_beq RPtr) (snd p)) obj_census).

(* ---- the pinned census (vm-checked against the generated Clight) ---- *)

Lemma obj_fns_count : List.length obj_fns = 432%nat.
Proof. vm_compute. reflexivity. Qed.

(* every store outside the running object, per function *)
Lemma obj_census_value : cstr obj_census =
       [("geo_add_child"%string, ["ptr"%string]);
        ("geo_remove_child"%string, ["ptr"%string]);
        ("opened_cannon_act_1"%string, ["glob gMarioShotFromCannon"%string]);
        ("obj_spawn_loot_coins"%string, ["call spawn_object"%string]);
        ("koopa_shell_spawn_water_drop"%string,
         ["call spawn_object_with_scale"%string]);
        ("koopa_shell_spawn_sparkles"%string, ["call spawn_object"%string]);
        ("cutscene_object_with_dialog"%string,
         ["glob sCutsceneDialogID"%string; "glob gRecentCutscene"%string]);
        ("cur_obj_spawn_particles"%string, ["call spawn_object"%string]);
        ("cur_obj_enable_rendering_if_mario_in_room"%string,
         ["glob gNumRoomedObjectsInMarioRoom"%string;
          "glob gNumRoomedObjectsNotInMarioRoom"%string]);
        ("cur_obj_update"%string, ["glob gCurBhvCommand"%string]);
        ("cur_obj_push_mario_away"%string, ["glob gMarioStates"%string]);
        ("clear_particle_flags"%string, ["ptr"%string]);
        ("clear_time_stop_flags"%string, ["glob gTimeStopState"%string]);
        ("create_object"%string, ["call allocate_object"%string]);
        ("create_sound_spawner"%string, ["call spawn_object"%string]);
        ("save_file_clear_flags"%string,
         ["glob gSaveBuffer"%string; "glob gSaveFileModified"%string]);
        ("save_file_set_cap_pos"%string, ["glob gSaveBuffer"%string]);
        ("save_file_set_cannon_unlocked"%string,
         ["glob gSaveBuffer"%string; "glob gSaveFileModified"%string]);
        ("save_file_set_flags"%string,
         ["glob gSaveBuffer"%string; "glob gSaveFileModified"%string]);
        ("seq_player_play_sequence"%string,
         ["glob sCurrentBackgroundMusicSeqId"%string;
          "glob sBackgroundMusicForDynamics"%string;
          "glob sCurrentMusicDynamic"%string;
          "glob sMusicDynamicDelay"%string; "glob D_80360928"%string;
          "glob gSequencePlayers"%string]);
        ("seq_player_fade_to_target_volume"%string,
         ["glob gSequencePlayers"%string]);
        ("seq_player_fade_to_normal_volume"%string,
         ["glob gSequencePlayers"%string]);
        ("set_object_respawn_info_bits"%string, ["ptr"%string]);
        ("set_mario_action_airborne"%string, ["ptr"%string]);
        ("set_mario_action_moving"%string, ["ptr"%string]);
        ("set_mario_npc_dialog"%string, ["via gMarioState"%string]);
        ("set_time_stop_flags"%string, ["glob gTimeStopState"%string]);
        ("spawn_water_droplet"%string, ["call spawn_object"%string]);
        ("spawn_object_at_origin"%string, ["call create_object"%string]);
        ("spawn_object_relative"%string,
         ["call spawn_object_at_origin"%string]);
        ("spawn_orange_number"%string, ["call spawn_object_relative"%string]);
        ("spawn_coin_in_formation"%string,
         ["call spawn_object_relative"%string]);
        ("spawn_star"%string, ["call spawn_object_abs_with_rot"%string]);
        ("spawn_mist_particles_variable"%string,
         ["glob sMistParticles"%string]);
        ("spawn_triangle_break_particles"%string,
         ["call spawn_object"%string]);
        ("spawn_red_coin_cutscene_star"%string, ["call spawn_star"%string]);
        ("stop_sounds_from_source"%string, ["glob sSoundBanks"%string]);
        ("star_door_unlock_spawn_particles"%string,
         ["call spawn_object"%string]);
        ("start_object_cutscene"%string,
         ["glob sObjectCutscene"%string; "glob gRecentCutscene"%string;
          "glob gCutsceneFocus"%string; "glob gObjCutsceneDone"%string]);
        ("allocate_object"%string, ["call try_allocate_object"%string]);
        ("alloc_surface_node"%string,
         ["glob gSurfaceNodesAllocated"%string; "via sSurfaceNodePool"%string]);
        ("alloc_surface"%string,
         ["glob gSurfacesAllocated"%string; "via sSurfacePool"%string]);
        ("add_surface_to_cell"%string,
         ["call alloc_surface_node"%string;
          "glob gDynamicSurfacePartition"%string;
          "glob gStaticSurfacePartition"%string; "ptr"%string]);
        ("exclamation_box_spawn_contents"%string,
         ["ptr"%string; "call spawn_object"%string]);
        ("update_background_music_after_sound"%string,
         ["glob sSoundBanksThatLowerBackgroundMusic"%string]);
        ("play_sound"%string,
         ["glob sSoundRequests"%string; "glob sSoundRequestCount"%string]);
        ("play_power_star_jingle"%string,
         ["glob sBackgroundMusicTargetVolume"%string;
          "glob sBackgroundMusicMaxTargetVolume"%string]);
        ("load_object_surfaces"%string, ["call read_surface_data"%string]);
        ("deallocate_object"%string, ["ptr"%string]);
        ("try_allocate_object"%string, ["ptr"%string]);
        ("try_to_spawn_object"%string, ["call spawn_object"%string]);
        ("begin_background_music_fade"%string,
         ["glob gSequencePlayers"%string]);
        ("bhv_golden_coin_sparkles_loop"%string, ["call spawn_object"%string]);
        ("bhv_object_bubble_loop"%string,
         ["call spawn_object_at_origin"%string]);
        ("bhv_orange_number_loop"%string, ["call spawn_object"%string]);
        ("bhv_coin_formation_spawn_loop"%string, ["ptr"%string]);
        ("bhv_cannon_closed_init"%string, ["call spawn_object"%string]);
        ("bhv_cmd_goto"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_or_int"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_call_native"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_call"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_scale"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_set_obj_physics"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_set_interact_subtype"%string,
         ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_set_interact_type"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_set_int_unused"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_set_int_rand_rshift"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_set_int"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_set_model"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_set_home"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_set_hitbox_with_offset"%string,
         ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_set_hitbox"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_set_hurtbox"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_set_random_int"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_set_random_float"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_set_float"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_sum_int"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_sum_float"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_spawn_water_droplet"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_spawn_obj"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_spawn_child_with_param"%string,
         ["call spawn_object_at_origin"%string; "glob gCurBhvCommand"%string]);
        ("bhv_cmd_spawn_child"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_add_int_rand_rshift"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_add_int"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_add_random_float"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_add_float"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_animate_texture"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_animate"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_end_loop"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_end_repeat_continue"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_end_repeat"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_hide"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_parent_bit_clear"%string,
         ["ptr"%string; "glob gCurBhvCommand"%string]);
        ("bhv_cmd_load_collision_data"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_load_animations"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_disable_rendering"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_delay_var"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_delay"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_drop_to_floor"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_billboard"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_bit_clear"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_begin_loop"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_begin_repeat_unused"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_begin_repeat"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_begin"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_return"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_nop_4"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_nop_2"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_nop_1"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_cmd_nop_3"%string, ["glob gCurBhvCommand"%string]);
        ("bhv_spawned_star_loop"%string, ["glob gObjCutsceneDone"%string]);
        ("bhv_star_spawn_loop"%string, ["glob gObjCutsceneDone"%string]);
        ("bhv_snow_leaf_particle_spawn_init"%string,
         ["via gMarioObject"%string; "call spawn_object"%string]);
        ("bhv_idle_water_wave_loop"%string, ["via gMarioObject"%string]);
        ("bhv_end_peach_loop"%string, ["glob sEndPeachAnimation"%string]);
        ("bhv_end_toad_loop"%string, ["glob sEndToadAnims"%string]);
        ("bhv_1up_interact"%string, ["via gMarioState"%string]);
        ("bhv_1up_hidden_in_pole_trigger_loop"%string,
         ["call cur_obj_nearest_object_with_behavior"%string]);
        ("bhv_hidden_red_coin_star_init"%string,
         ["call spawn_object_abs_with_rot"%string]);
        ("bhv_hidden_red_coin_star_loop"%string,
         ["glob gRedCoinsCollected"%string]);
        ("bhv_pound_tiny_star_particle_init"%string,
         ["call spawn_object"%string]);
        ("bhv_punch_tiny_triangle_init"%string, ["call spawn_object"%string]);
        ("bhv_tiny_star_particles_init"%string, ["call spawn_object"%string]);
        ("bhv_red_coin_loop"%string, ["ptr"%string]);
        ("bhv_flame_mario_loop"%string,
         ["ptr"%string; "via gMarioObject"%string]);
        ("random_u16"%string, ["glob gRandomSeed16"%string]);
        ("read_surface_data"%string, ["call alloc_surface"%string]);
        ("find_wall_collisions"%string, ["glob gNumCalls"%string]);
        ("find_floor"%string,
         ["glob gFindFloorIncludeSurfaceIntangible"%string;
          "glob gNumFindFloorMisses"%string; "glob gNumCalls"%string]);
        ("func_8031D690"%string, ["glob gSequencePlayers"%string])].
Proof. vm_compute. reflexivity. Qed.

(* every pointer argument outside the running object, per function (what a
   callee may store through; mostly behavior-script addresses handed to
   spawn_object, which a callee only reads) *)
Lemma obj_arg_census_value : cstr obj_arg_census =
       [("geo_obj_init_animation"%string, ["ptr"%string]);
        ("object_step"%string,
         ["glob sObjFloor"%string; "via sObjFloor"%string]);
        ("obj_orient_graph"%string, ["call alloc_display_list"%string]);
        ("obj_spawn_loot_coins"%string, ["call spawn_object"%string]);
        ("obj_spawn_loot_yellow_coins"%string,
         ["glob bhvSingleCoinGetsSpawned"%string]);
        ("obj_spawn_loot_blue_coins"%string,
         ["glob bhvBlueCoinJumping"%string]);
        ("obj_splash"%string,
         ["glob bhvObjectWaterWave"%string; "glob bhvObjectBubble"%string]);
        ("obj_build_transform_relative_to_parent"%string, ["ptr"%string]);
        ("koopa_shell_spawn_water_drop"%string,
         ["glob bhvObjectWaveTrail"%string; "glob bhvWaterDroplet"%string;
          "call spawn_object_with_scale"%string]);
        ("koopa_shell_spawn_sparkles"%string, ["glob bhvSparkleSpawn"%string]);
        ("coin_collected"%string, ["glob bhvGoldenCoinSparkles"%string]);
        ("coin_step"%string, ["via sObjFloor"%string]);
        ("count_objects_with_behavior"%string,
         ["call segmented_to_virtual"%string]);
        ("cap_set_hitbox"%string, ["glob sCapHitbox"%string]);
        ("celeb_star_act_spin_around_mario"%string,
         ["glob bhvCelebrationStarSparkle"%string]);
        ("cur_obj_get_thrown_or_placed"%string, ["glob bhvBowser"%string]);
        ("cur_obj_set_pos_relative_to_parent"%string, ["ptr"%string]);
        ("cur_obj_spawn_particles"%string,
         ["glob bhvWhitePuffExplosion"%string; "call spawn_object"%string]);
        ("cur_obj_init_animation_with_sound"%string, ["ptr"%string]);
        ("cur_obj_move_after_thrown_or_dropped"%string,
         ["via gMarioObject"%string]);
        ("cur_obj_update"%string, ["via gMarioObject"%string]);
        ("cur_obj_find_nearest_object_with_behavior"%string,
         ["call segmented_to_virtual"%string; "ptr"%string]);
        ("create_object"%string,
         ["via gObjectLists"%string; "call allocate_object"%string]);
        ("create_sound_spawner"%string, ["glob bhvSoundSpawner"%string]);
        ("save_file_set_cap_pos"%string, ["glob gSaveBuffer"%string]);
        ("set_koopa_shell_underwater_hitbox"%string,
         ["glob sKoopaShellUnderwaterHitbox"%string]);
        ("set_sparkle_spawn_star_hitbox"%string,
         ["glob sSparkleSpawnStarHitbox"%string]);
        ("set_mario_npc_dialog"%string, ["via gMarioState"%string]);
        ("spawn_water_droplet"%string,
         ["ptr"%string; "call spawn_object"%string]);
        ("spawn_object_with_scale"%string,
         ["call spawn_object_at_origin"%string]);
        ("spawn_object_at_origin"%string,
         ["call segmented_to_virtual"%string; "call create_object"%string;
          "ptr"%string; "glob gVec3fZero"%string; "glob gVec3sZero"%string]);
        ("spawn_object_abs_with_rot"%string,
         ["call spawn_object_at_origin"%string]);
        ("spawn_object_relative"%string,
         ["call spawn_object_at_origin"%string]);
        ("spawn_object"%string, ["call spawn_object_at_origin"%string]);
        ("spawn_orange_number"%string, ["glob bhvOrangeNumber"%string]);
        ("spawn_coin_in_formation"%string,
         ["glob bhvCoinFormationSpawn"%string]);
        ("spawn_star"%string, ["glob bhvStarSpawnCoordinates"%string]);
        ("spawn_mist_particles_variable"%string,
         ["glob sMistParticles"%string]);
        ("spawn_mist_from_global"%string,
         ["glob sGlobalMistParticles"%string]);
        ("spawn_triangle_break_particles"%string,
         ["glob bhvBreakBoxTriangle"%string; "call spawn_object"%string]);
        ("spawn_red_coin_cutscene_star"%string, ["call spawn_star"%string]);
        ("star_door_unlock_spawn_particles"%string,
         ["glob bhvSparkleSpawn"%string]);
        ("allocate_object"%string,
         ["call find_unimportant_object"%string;
          "glob gFreeObjectList"%string; "call try_allocate_object"%string]);
        ("exclamation_box_spawn_contents"%string, ["ptr"%string]);
        ("exclamation_box_act_4"%string,
         ["glob sExclamationBoxContents"%string]);
        ("exclamation_box_act_2"%string,
         ["glob sExclamationBoxHitbox"%string]);
        ("exclamation_box_act_1"%string,
         ["glob bhvRotatingExclamationMark"%string]);
        ("unload_object"%string,
         ["glob gObjParentGraphNode"%string; "glob gFreeObjectList"%string]);
        ("pole_1up_move_towards_mario"%string, ["via gMarioObject"%string]);
        ("print_checkinfo"%string, ["glob __stringlit_debug_31"%string]);
        ("print_stageinfo"%string,
         ["glob __stringlit_debug_32"%string;
          "glob __stringlit_debug_33"%string]);
        ("print_mapinfo"%string,
         ["glob __stringlit_debug_20"%string;
          "glob __stringlit_debug_21"%string;
          "glob __stringlit_debug_22"%string;
          "glob __stringlit_debug_23"%string;
          "glob __stringlit_debug_24"%string;
          "glob __stringlit_debug_25"%string;
          "glob __stringlit_debug_26"%string;
          "glob __stringlit_debug_27"%string;
          "glob __stringlit_debug_28"%string;
          "glob __stringlit_debug_29"%string;
          "glob __stringlit_debug_30"%string]);
        ("print_debug_top_down_mapinfo"%string,
         ["glob gDebugPrintState1"%string]);
        ("print_debug_top_down_normal"%string,
         ["glob gDebugPrintState1"%string]);
        ("print_text_array_info"%string, ["glob __stringlit_debug_19"%string]);
        ("load_object_collision_model"%string, ["via gMarioObject"%string]);
        ("load_object_surfaces"%string,
         ["glob bhvDDDWarp"%string; "call read_surface_data"%string]);
        ("try_allocate_object"%string,
         ["glob gObjParentGraphNode"%string; "ptr"%string]);
        ("try_do_mario_debug_object_spawn"%string,
         ["glob bhvKoopaShell"%string; "glob bhvJumpingBox"%string;
          "glob bhvKoopaShellUnderwater"%string]);
        ("try_to_spawn_object"%string, ["call spawn_object"%string]);
        ("jumping_box_free_update"%string,
         ["glob sJumpingBoxHitbox"%string; "glob sJumpingBoxActions"%string]);
        ("bobomb_buddy_cannon_dialog"%string,
         ["glob bhvCannonClosed"%string;
          "call cur_obj_nearest_object_with_behavior"%string]);
        ("bhv_wall_tiny_star_particle_loop"%string,
         ["via gMarioObject"%string]);
        ("bhv_water_waves_init"%string, ["glob bhvSmallParticle"%string]);
        ("bhv_water_splash_spawn_droplets"%string,
         ["glob sWaterSplashDropletParams"%string]);
        ("bhv_water_mist_spawn_loop"%string, ["glob bhvWaterMist"%string]);
        ("bhv_water_droplet_loop"%string,
         ["glob bhvWaterDropletSplash"%string]);
        ("bhv_golden_coin_sparkles_loop"%string,
         ["glob bhvCoinSparkles"%string]);
        ("bhv_ground_sand_init"%string, ["glob sSandParticles"%string]);
        ("bhv_ground_snow_init"%string, ["glob sSnowParticles"%string]);
        ("bhv_object_bubble_loop"%string, ["glob bhvBubbleSplash"%string]);
        ("bhv_orange_number_loop"%string,
         ["glob bhvGoldenCoinSparkles"%string]);
        ("bhv_koopa_shell_loop"%string,
         ["glob sKoopaShellHitbox"%string; "via gMarioObject"%string]);
        ("bhv_koopa_shell_flame_spawn"%string,
         ["glob bhvKoopaShellFlame"%string]);
        ("bhv_coin_sparkles_init"%string,
         ["glob bhvGoldenCoinSparkles"%string]);
        ("bhv_coin_formation_spawn_loop"%string,
         ["glob bhvYellowCoin"%string; "glob sYellowCoinHitbox"%string]);
        ("bhv_collect_star_init"%string, ["glob sCollectStarHitbox"%string]);
        ("bhv_cannon_closed_init"%string, ["glob bhvCannon"%string]);
        ("bhv_cannon_base_loop"%string, ["glob sOpenedCannonActions"%string]);
        ("bhv_cannon_barrel_loop"%string, ["ptr"%string]);
        ("bhv_cmd_goto"%string, ["ptr"%string]);
        ("bhv_cmd_call"%string, ["ptr"%string]);
        ("bhv_cmd_spawn_water_droplet"%string, ["ptr"%string]);
        ("bhv_cmd_spawn_obj"%string,
         ["ptr"%string; "call spawn_object_at_origin"%string]);
        ("bhv_cmd_spawn_child_with_param"%string,
         ["ptr"%string; "call spawn_object_at_origin"%string]);
        ("bhv_cmd_spawn_child"%string,
         ["ptr"%string; "call spawn_object_at_origin"%string]);
        ("bhv_cmd_animate"%string, ["ptr"%string]);
        ("bhv_cmd_load_collision_data"%string, ["ptr"%string]);
        ("bhv_cmd_begin"%string,
         ["glob bhvHauntedChair"%string; "glob bhvMadPiano"%string;
          "glob bhvMessagePanel"%string]);
        ("bhv_small_water_wave_loop"%string,
         ["glob bhvObjectWaterSplash"%string]);
        ("bhv_shallow_water_splash_init"%string,
         ["glob sWaterDropletFishParams"%string;
          "call spawn_water_droplet"%string;
          "glob blue_fish_seg3_anims_0301C2B0"%string]);
        ("bhv_spawned_coin_init"%string,
         ["glob bhvYellowCoin"%string; "glob sYellowCoinHitbox"%string]);
        ("bhv_spawned_star_loop"%string, ["glob bhvSparkleSpawn"%string]);
        ("bhv_sparkle_spawn_loop"%string,
         ["glob bhvSparkle"%string; "call try_to_spawn_object"%string]);
        ("bhv_star_spawn_loop"%string, ["glob bhvSparkleSpawn"%string]);
        ("bhv_snow_leaf_particle_spawn_init"%string,
         ["glob bhvTreeSnow"%string; "glob bhvTreeLeaf"%string;
          "call spawn_object"%string]);
        ("bhv_yellow_coin_init"%string,
         ["glob bhvYellowCoin"%string; "glob sYellowCoinHitbox"%string]);
        ("bhv_idle_water_wave_loop"%string, ["via gMarioObject"%string]);
        ("bhv_init_room"%string, ["glob sLevelsWithRooms"%string]);
        ("bhv_exclamation_box_loop"%string,
         ["glob sExclamationBoxActions"%string]);
        ("bhv_1up_walking_loop"%string,
         ["glob bhvSparkleSpawn"%string; "glob gGlobalSoundSource"%string]);
        ("bhv_1up_interact"%string,
         ["via gMarioObject"%string; "glob gGlobalSoundSource"%string]);
        ("bhv_1up_hidden_in_pole_spawner_loop"%string,
         ["glob bhvHidden1UpInPole"%string;
          "glob bhvHidden1UpInPoleTrigger"%string]);
        ("bhv_1up_hidden_in_pole_loop"%string,
         ["glob gGlobalSoundSource"%string; "glob bhvSparkleSpawn"%string]);
        ("bhv_1up_hidden_in_pole_trigger_loop"%string,
         ["via gMarioObject"%string; "glob bhvHidden1UpInPole"%string]);
        ("bhv_1up_running_away_loop"%string,
         ["glob gGlobalSoundSource"%string; "glob bhvSparkleSpawn"%string]);
        ("bhv_hidden_red_coin_star_init"%string,
         ["glob bhvRedCoinStarMarker"%string; "glob bhvRedCoin"%string;
          "glob bhvStar"%string]);
        ("bhv_pound_tiny_star_particle_init"%string,
         ["glob bhvPoundTinyStarParticle"%string]);
        ("bhv_particle_loop"%string, ["glob bhvObjectWaterSplash"%string]);
        ("bhv_punch_tiny_triangle_init"%string,
         ["glob bhvPunchTinyTriangle"%string]);
        ("bhv_punch_tiny_triangle_loop"%string, ["via gMarioObject"%string]);
        ("bhv_tiny_star_particles_init"%string,
         ["glob bhvWallTinyStarParticle"%string]);
        ("bhv_jumping_box_loop"%string, ["via gMarioObject"%string]);
        ("bhv_black_smoke_mario_loop"%string, ["via gMarioObject"%string]);
        ("bhv_blue_coin_sliding_jumping_init"%string,
         ["glob sMovingBlueCoinHitbox"%string]);
        ("bhv_red_coin_init"%string,
         ["glob bhvHiddenRedCoinStar"%string;
          "glob bhvBowserCourseRedCoinStar"%string;
          "glob sRedCoinHitbox"%string]);
        ("bhv_red_coin_loop"%string, ["glob gGlobalSoundSource"%string]);
        ("bhv_flame_mario_loop"%string, ["glob bhvBlackSmokeMario"%string]);
        ("find_wall_collisions"%string, ["ptr"%string]);
        ("find_floor"%string, ["ptr"%string])].
Proof. vm_compute. reflexivity. Qed.

Lemma obj_store_roots_value : map sroot_str obj_store_roots =
       ["glob gMarioShotFromCannon"%string;
        "call spawn_object_with_scale"%string;
        "glob sCutsceneDialogID"%string;
        "glob gNumRoomedObjectsInMarioRoom"%string;
        "glob gNumRoomedObjectsNotInMarioRoom"%string;
        "glob gMarioStates"%string; "call allocate_object"%string;
        "glob gSaveBuffer"%string; "glob gSaveFileModified"%string;
        "glob sCurrentBackgroundMusicSeqId"%string;
        "glob sBackgroundMusicForDynamics"%string;
        "glob sCurrentMusicDynamic"%string; "glob sMusicDynamicDelay"%string;
        "glob D_80360928"%string; "glob gTimeStopState"%string;
        "call create_object"%string; "call spawn_object_relative"%string;
        "glob sMistParticles"%string; "call spawn_star"%string;
        "glob sSoundBanks"%string; "glob sObjectCutscene"%string;
        "glob gRecentCutscene"%string; "glob gCutsceneFocus"%string;
        "call try_allocate_object"%string;
        "glob gSurfaceNodesAllocated"%string; "via sSurfaceNodePool"%string;
        "glob gSurfacesAllocated"%string; "via sSurfacePool"%string;
        "call alloc_surface_node"%string;
        "glob gDynamicSurfacePartition"%string;
        "glob gStaticSurfacePartition"%string;
        "glob sSoundBanksThatLowerBackgroundMusic"%string;
        "glob sSoundRequests"%string; "glob sSoundRequestCount"%string;
        "glob sBackgroundMusicTargetVolume"%string;
        "glob sBackgroundMusicMaxTargetVolume"%string;
        "call read_surface_data"%string;
        "call spawn_object_at_origin"%string; "glob gCurBhvCommand"%string;
        "glob gObjCutsceneDone"%string; "glob sEndPeachAnimation"%string;
        "glob sEndToadAnims"%string; "via gMarioState"%string;
        "call cur_obj_nearest_object_with_behavior"%string;
        "call spawn_object_abs_with_rot"%string;
        "glob gRedCoinsCollected"%string; "call spawn_object"%string;
        "ptr"%string; "via gMarioObject"%string; "glob gRandomSeed16"%string;
        "call alloc_surface"%string;
        "glob gFindFloorIncludeSurfaceIntangible"%string;
        "glob gNumFindFloorMisses"%string; "glob gNumCalls"%string;
        "glob gSequencePlayers"%string].
Proof. vm_compute. reflexivity. Qed.

Lemma obj_ptr_store_fns_value : map string_of_ident obj_ptr_store_fns =
       ["geo_add_child"%string; "geo_remove_child"%string;
        "clear_particle_flags"%string; "set_object_respawn_info_bits"%string;
        "set_mario_action_airborne"%string; "set_mario_action_moving"%string;
        "add_surface_to_cell"%string;
        "exclamation_box_spawn_contents"%string; "deallocate_object"%string;
        "try_allocate_object"%string; "bhv_coin_formation_spawn_loop"%string;
        "bhv_cmd_parent_bit_clear"%string; "bhv_red_coin_loop"%string;
        "bhv_flame_mario_loop"%string].
Proof. vm_compute. reflexivity. Qed.

(* the running object stays put: no function an object slot runs stores
   gCurrentObject, so the RSelf class ("o") is the slot's block for the
   whole cur_obj_update *)
Lemma gcur_not_stored : existsb (sroot_beq (RGlob GCUR)) obj_store_roots = false.
Proof. vm_compute. reflexivity. Qed.

