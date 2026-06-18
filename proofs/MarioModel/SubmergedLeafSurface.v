(* ====================================================================== *)
(* THE SUBMERGED LEAF SURFACE: shrink Hpres_sub_callees leaf by leaf.      *)
(* (SPINE: submerged_leaf_callees_pres feeds SubmergedSurface.submerged_   *)
(*  pres, discharging the 33-id census down to the un-walked rest.)        *)
(*                                                                         *)
(* SLICE 1 (foundation): act_metal_water_standing WALKED.  Its body is a   *)
(* pure body_pres_of_wwalk walk -- three set_mario_action(const) cancels,  *)
(* a head-anim switch (set_mario_animation), an is_anim_at_end gate, the   *)
(* stop_and_set_height_to_floor step, and window stores to actionState/    *)
(* particleFlags.  NO chase stores in this leaf.                           *)
(*                                                                         *)
(* The shared helper rows is_anim_at_end / set_mario_animation are WALKED  *)
(* inline (the same plain-engine + cact walks the moving/stationary leaf   *)
(* surfaces use); set_mario_action is the reusable smact_pres keystone;    *)
(* stop_and_set_height_to_floor (a genuine action-preserving step helper   *)
(* that writes pos/vel and chases marioObj into the SafeB gfx pool) is the *)
(* ONE honest call_pres residual this slice introduces -- a real, named,   *)
(* dischargeable function, NOT a restatement of the goal.                  *)
(* ====================================================================== *)

From Coq Require Import ZArith Lia List.
From compcert Require Import Coqlib Maps AST Integers Floats Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario mario_step
  mario_actions_airborne mario_actions_submerged level_update interaction.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit FloorsSurface.
From SM64.Proofs Require Import ActWriterSurface SubmergedSurface.

Import ListNotations.

(* ====================================================================== *)
(* Censuses (probe-derived).                                              *)
(* ====================================================================== *)

(* set_mario_animation's chase temps + its load_patchable_table external. *)
Definition sub_sma_cact : list ident :=
  mario._o :: mario._t'13 :: mario._t'12 :: mario._targetAnim :: nil.
Definition sub_sma_xids : list ident := mario._load_patchable_table :: nil.

(* the action-writers the metal-water cluster calls with untainted const
   action args: set_mario_action + drop_and_set_mario_action (the hold
   variants' held-object drop). *)
Definition sub_sids : list ident :=
  mario._set_mario_action :: mario._drop_and_set_mario_action :: nil.

(* the ids helpers the metal-water cluster calls (each passes m, marg):
   set_mario_animation + is_anim_at_end (walked here) + stop_and_set_height_
   to_floor + play_metal_water_jumping_sound (the assumed honest step/sound
   residuals).  A single superset list serves all three metal-water leaves --
   act_metal_water_standing does not call play_metal_water_jumping_sound, but
   an unused ids entry is harmless to the walk. *)
Definition sub_metal_ids : list ident :=
  mario._set_mario_animation
    :: mario._is_anim_at_end
    :: mario_step._stop_and_set_height_to_floor
    :: mario_actions_submerged._play_metal_water_jumping_sound
    :: mario_step._perform_air_step
    :: mario_actions_submerged._update_metal_water_jump_speed :: nil.

(* the ids helpers the metal-water WALKING pair calls (each passes m + non-
   pointer scalar extras): set_mario_anim_with_accel (anim id + accel), the
   walking sound + speed updaters, and perform_ground_step.  ALL write only the
   anim/particle/forwardVel/vel/slideVel window (or chase marioObj's SafeB gfx
   pool); NONE touches the action cell, so each is a genuine call_pres for any
   caller.  perform_ground_step is ALREADY PROVED (capstone Hcp_pgs, the
   MarioStepSurface walk) -- fed through, NO new trust. *)
Definition sub_walk_ids : list ident :=
  mario._set_mario_anim_with_accel
    :: mario_actions_submerged._play_metal_water_walking_sound
    :: mario_actions_submerged._update_metal_water_walking_speed
    :: mario_step._perform_ground_step :: nil.

(* the ids helpers the water-IDLE cluster (water_idle/hold + water_action_end/
   hold) calls: common_idle_step (the shared swim-idle step -- writes window +
   chases marioBodyState->headAngle, NEVER the action cell, a genuine call_pres
   residual) and is_anim_at_end (already WALKED here, sub_iae_row).  The action
   selection is set_mario_action / drop_and_set_mario_action via sub_sids. *)
Definition sub_idle_ids : list ident :=
  mario_actions_submerged._common_idle_step
    :: mario._is_anim_at_end :: nil.

(* the ids helpers the metal-water FALLING pair calls: set_mario_animation
   (already WALKED, sub_sma_row), stationary_slow_down (the water decel helper
   -- writes angleVel/forwardVel/vel/faceAngle window, never the action cell),
   and perform_water_step (the Tier-2 water step -- writes pos/vel window +
   chases marioObj's SafeB gfx pool, never the action cell).  The faceAngle
   nudge reads gSineTable (a global LOAD, no store), so NO external/global
   row.  set_mario_action / drop_and_set_mario_action via sub_sids. *)
Definition sub_fall_ids : list ident :=
  mario._set_mario_animation
    :: mario_actions_submerged._stationary_slow_down
    :: mario_actions_submerged._perform_water_step :: nil.

(* the ids helpers act_water_death calls: stationary_slow_down +
   perform_water_step (the slice-7 step residuals, REUSED), set_mario_animation
   (sub_sma_row), and level_trigger_warp (the SHARED warp-trigger, already
   discharged at the capstone -- NO new trust).  The body also chases
   m->marioBodyState into a temp and writes its eyeState (a non-pointer const
   into a SafeB chase-root block), so cact = [_t'2].  No set_mario_action. *)
Definition sub_death_ids : list ident :=
  mario_actions_submerged._stationary_slow_down
    :: mario_actions_submerged._perform_water_step
    :: mario._set_mario_animation
    :: level_update._level_trigger_warp :: nil.
Definition sub_death_cact : list ident :=
  mario_actions_submerged._t'2 :: nil.

(* act_drowning: the death-sibling.  Same step helpers (stationary_slow_down +
   perform_water_step REUSED) + set_mario_animation + is_anim_at_end (both
   already WALKED) + level_trigger_warp (SHARED) + play_sound_if_no_flag (the
   ONE new honest residual -- flags window + a sound, never the action cell).
   Chases m->marioBodyState (eyeState writes, _t'5/_t'6) and m->marioObj
   (animFrame read, _t'3) => cact = [_t'3; _t'5; _t'6].  No set_mario_action. *)
Definition sub_drown_ids : list ident :=
  mario._set_mario_animation
    :: mario._is_anim_at_end
    :: level_update._level_trigger_warp
    :: mario_actions_submerged._play_sound_if_no_flag
    :: mario_actions_submerged._stationary_slow_down
    :: mario_actions_submerged._perform_water_step :: nil.
Definition sub_drown_cact : list ident :=
  mario_actions_submerged._t'3
    :: mario_actions_submerged._t'5
    :: mario_actions_submerged._t'6 :: nil.

(* act_water_shocked: the INLINE knockback (does NOT call common_water_knockback_
   step).  set_mario_action's action arg is the ternary health<0x100 ? DEATH :
   IDLE -- two untainted consts written into _t'2 => wact=[_t'2] (the seeded
   untainted-action temp).  Chases m->marioBodyState (headAngle write, _t'3) and
   m->marioObj (gfx read for play_sound, _t'8) => cact=[_t'3; _t'8].  ids reused
   (ssd/pws/sma/psinf); externals play_sound + set_camera_shake_from_hit are
   obj_ext_ids members (Hpres_obj_ext, NO new trust); set_mario_action via
   sub_sids (Hsmact).  ZERO new capstone trust. *)
Definition sub_shock_wact : list ident :=
  mario_actions_submerged._t'2 :: nil.
Definition sub_shock_ids : list ident :=
  mario_actions_submerged._stationary_slow_down
    :: mario_actions_submerged._perform_water_step
    :: mario._set_mario_animation
    :: mario_actions_submerged._play_sound_if_no_flag :: nil.
Definition sub_shock_cact : list ident :=
  mario_actions_submerged._t'3 :: mario_actions_submerged._t'8 :: nil.
Definition sub_shock_xids : list ident :=
  mario._play_sound :: interaction._set_camera_shake_from_hit :: nil.

(* the knockback pair (act_backward_water_kb / act_forward_water_kb): each
   body is one `common_water_knockback_step(m, <anim>, ACT_WATER_IDLE, m->
   actionArg)` call (+ return 0).  cwks writes m->action via set_mario_action
   with `m->health >= 0x100 ? endAction : ACT_WATER_DEATH` -- so it preserves
   the action cell ONLY when its endAction (param index 2) is untainted.  That
   is exactly call_pres_act3's gate (`aval` = the THIRD vargs element); the leaf
   passes ACT_WATER_IDLE (a const, vm-checked untainted) there, recognised by
   the engine's act3_call_chk (Mario-stripped index 1 = full index 2).  So cwks
   rides tids as ONE honest residual Hcp_cwks (`call_pres_act3 cwks`,
   dischargeable later via the param-action arc once endAction is threaded). *)
Definition sub_kb_tids : list ident :=
  mario_actions_submerged._common_water_knockback_step :: nil.

(* the WALKED leaves. *)
Definition sub_walked_ids : list ident :=
  mario_actions_submerged._act_metal_water_standing
    :: mario_actions_submerged._act_metal_water_jump_land
    :: mario_actions_submerged._act_metal_water_fall_land
    :: mario_actions_submerged._act_metal_water_jump
    :: mario_actions_submerged._act_hold_metal_water_standing
    :: mario_actions_submerged._act_hold_metal_water_jump_land
    :: mario_actions_submerged._act_hold_metal_water_fall_land
    :: mario_actions_submerged._act_hold_metal_water_jump
    :: mario_actions_submerged._act_metal_water_walking
    :: mario_actions_submerged._act_hold_metal_water_walking
    :: mario_actions_submerged._act_water_idle
    :: mario_actions_submerged._act_hold_water_idle
    :: mario_actions_submerged._act_water_action_end
    :: mario_actions_submerged._act_hold_water_action_end
    :: mario_actions_submerged._act_metal_water_falling
    :: mario_actions_submerged._act_hold_metal_water_falling
    :: mario_actions_submerged._act_water_death
    :: mario_actions_submerged._act_drowning
    :: mario_actions_submerged._act_water_shocked
    :: mario_actions_submerged._act_backward_water_kb
    :: mario_actions_submerged._act_forward_water_kb :: nil.
Definition sub_rest_ids : list ident :=
  filter (fun id => negb (mem_id id sub_walked_ids)) submerged_callee_ids.

(* membership of the un-walked rest: a census id that is not walked lands
   in the filter that defines the rest. *)
Lemma mem_id_filter_true :
  forall (P : ident -> bool) (l : list ident) (fid : ident),
    mem_id fid l = true -> P fid = true ->
    mem_id fid (filter P l) = true.
Proof.
  intros P l fid. unfold mem_id. induction l as [| a l IH]; intros Hin HP.
  - discriminate Hin.
  - cbn [existsb] in Hin. cbn [filter].
    destruct (Pos.eqb fid a) eqn:Ea.
    + apply Pos.eqb_eq in Ea; subst a. rewrite HP. cbn [existsb].
      rewrite Pos.eqb_refl. reflexivity.
    + cbn [orb] in Hin. specialize (IH Hin HP).
      destruct (P a); [ cbn [existsb]; rewrite Ea, IH; reflexivity | exact IH ].
Qed.

(* ====================================================================== *)
(* The probe pins (vm_compute facts about the generated AST).             *)
(* ====================================================================== *)

(* ---- is_anim_at_end (loads only) ---- *)
Example sub_iae_pin :
  (prog_defmap mario.prog) ! mario._is_anim_at_end
  = Some (Gfun (Internal mario.f_is_anim_at_end)).
Proof. vm_compute. reflexivity. Qed.
Example sub_iae_vars : fn_vars mario.f_is_anim_at_end = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_iae_pok :
  match fn_params mario.f_is_anim_at_end with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_iae_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario.f_is_anim_at_end) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- set_mario_animation (cact chase temps + load_patchable_table) ---- *)
Example sub_sma_pin :
  (prog_defmap mario.prog) ! mario._set_mario_animation
  = Some (Gfun (Internal mario.f_set_mario_animation)).
Proof. vm_compute. reflexivity. Qed.
Example sub_sma_vars : fn_vars mario.f_set_mario_animation = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_sma_pok :
  match fn_params mario.f_set_mario_animation with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_sma_nonparam :
  forallb (fun t' => negb (mem_id t'
             (map fst (fn_params mario.f_set_mario_animation)))) sub_sma_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_sma_walk :
  wwalk_chk false nil nil nil sub_sma_cact sub_sma_xids nil nil
    (fn_body mario.f_set_mario_animation) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- act_metal_water_standing ---- *)
Example sub_mws_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_metal_water_standing
  = Some (Gfun (Internal mario_actions_submerged.f_act_metal_water_standing)).
Proof. vm_compute. reflexivity. Qed.
Example sub_mws_vars :
  fn_vars mario_actions_submerged.f_act_metal_water_standing = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_mws_pok :
  match fn_params mario_actions_submerged.f_act_metal_water_standing with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_mws_walk :
  wwalk_chk false nil sub_metal_ids nil nil nil sub_sids nil
    (fn_body mario_actions_submerged.f_act_metal_water_standing) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- act_metal_water_jump_land ---- *)
Example sub_mwjl_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_metal_water_jump_land
  = Some (Gfun (Internal mario_actions_submerged.f_act_metal_water_jump_land)).
Proof. vm_compute. reflexivity. Qed.
Example sub_mwjl_vars :
  fn_vars mario_actions_submerged.f_act_metal_water_jump_land = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_mwjl_pok :
  match fn_params mario_actions_submerged.f_act_metal_water_jump_land with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_mwjl_walk :
  wwalk_chk false nil sub_metal_ids nil nil nil sub_sids nil
    (fn_body mario_actions_submerged.f_act_metal_water_jump_land) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- act_metal_water_fall_land ---- *)
Example sub_mwfl_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_metal_water_fall_land
  = Some (Gfun (Internal mario_actions_submerged.f_act_metal_water_fall_land)).
Proof. vm_compute. reflexivity. Qed.
Example sub_mwfl_vars :
  fn_vars mario_actions_submerged.f_act_metal_water_fall_land = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_mwfl_pok :
  match fn_params mario_actions_submerged.f_act_metal_water_fall_land with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_mwfl_walk :
  wwalk_chk false nil sub_metal_ids nil nil nil sub_sids nil
    (fn_body mario_actions_submerged.f_act_metal_water_fall_land) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- act_metal_water_jump ---- *)
Example sub_mwj_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_metal_water_jump
  = Some (Gfun (Internal mario_actions_submerged.f_act_metal_water_jump)).
Proof. vm_compute. reflexivity. Qed.
Example sub_mwj_vars :
  fn_vars mario_actions_submerged.f_act_metal_water_jump = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_mwj_pok :
  match fn_params mario_actions_submerged.f_act_metal_water_jump with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_mwj_walk :
  wwalk_chk false nil sub_metal_ids nil nil nil sub_sids nil
    (fn_body mario_actions_submerged.f_act_metal_water_jump) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- the hold-metal cluster (chase READS of marioObj->oInteractStatus
   into untracked scalar temps -- NO chase stores, so cact=nil; the held-
   object drop goes through drop_and_set_mario_action (sids)) ---- *)
Definition sub_hold_pok (f : Clight.function) : bool :=
  match fn_params f with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end.

Example sub_hmws_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_hold_metal_water_standing
  = Some (Gfun (Internal mario_actions_submerged.f_act_hold_metal_water_standing)).
Proof. vm_compute. reflexivity. Qed.
Example sub_hmws_vars :
  fn_vars mario_actions_submerged.f_act_hold_metal_water_standing = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_hmws_pok :
  sub_hold_pok mario_actions_submerged.f_act_hold_metal_water_standing = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_hmws_walk :
  wwalk_chk false nil sub_metal_ids nil nil nil sub_sids nil
    (fn_body mario_actions_submerged.f_act_hold_metal_water_standing) = true.
Proof. vm_compute. reflexivity. Qed.

Example sub_hmwjl_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_hold_metal_water_jump_land
  = Some (Gfun (Internal mario_actions_submerged.f_act_hold_metal_water_jump_land)).
Proof. vm_compute. reflexivity. Qed.
Example sub_hmwjl_vars :
  fn_vars mario_actions_submerged.f_act_hold_metal_water_jump_land = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_hmwjl_pok :
  sub_hold_pok mario_actions_submerged.f_act_hold_metal_water_jump_land = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_hmwjl_walk :
  wwalk_chk false nil sub_metal_ids nil nil nil sub_sids nil
    (fn_body mario_actions_submerged.f_act_hold_metal_water_jump_land) = true.
Proof. vm_compute. reflexivity. Qed.

Example sub_hmwfl_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_hold_metal_water_fall_land
  = Some (Gfun (Internal mario_actions_submerged.f_act_hold_metal_water_fall_land)).
Proof. vm_compute. reflexivity. Qed.
Example sub_hmwfl_vars :
  fn_vars mario_actions_submerged.f_act_hold_metal_water_fall_land = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_hmwfl_pok :
  sub_hold_pok mario_actions_submerged.f_act_hold_metal_water_fall_land = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_hmwfl_walk :
  wwalk_chk false nil sub_metal_ids nil nil nil sub_sids nil
    (fn_body mario_actions_submerged.f_act_hold_metal_water_fall_land) = true.
Proof. vm_compute. reflexivity. Qed.

Example sub_hmwj_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_hold_metal_water_jump
  = Some (Gfun (Internal mario_actions_submerged.f_act_hold_metal_water_jump)).
Proof. vm_compute. reflexivity. Qed.
Example sub_hmwj_vars :
  fn_vars mario_actions_submerged.f_act_hold_metal_water_jump = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_hmwj_pok :
  sub_hold_pok mario_actions_submerged.f_act_hold_metal_water_jump = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_hmwj_walk :
  wwalk_chk false nil sub_metal_ids nil nil nil sub_sids nil
    (fn_body mario_actions_submerged.f_act_hold_metal_water_jump) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- the metal-water WALKING pair (set_mario_anim_with_accel + walking
   sound/speed + perform_ground_step; forwardVel/intendedMag window stores;
   val04 reads into untracked temps -- NO chase stores, cact=nil) ---- *)
Example sub_mww_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_metal_water_walking
  = Some (Gfun (Internal mario_actions_submerged.f_act_metal_water_walking)).
Proof. vm_compute. reflexivity. Qed.
Example sub_mww_vars :
  fn_vars mario_actions_submerged.f_act_metal_water_walking = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_mww_pok :
  sub_hold_pok mario_actions_submerged.f_act_metal_water_walking = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_mww_walk :
  wwalk_chk false nil sub_walk_ids nil nil nil sub_sids nil
    (fn_body mario_actions_submerged.f_act_metal_water_walking) = true.
Proof. vm_compute. reflexivity. Qed.

Example sub_hmww_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_hold_metal_water_walking
  = Some (Gfun (Internal mario_actions_submerged.f_act_hold_metal_water_walking)).
Proof. vm_compute. reflexivity. Qed.
Example sub_hmww_vars :
  fn_vars mario_actions_submerged.f_act_hold_metal_water_walking = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_hmww_pok :
  sub_hold_pok mario_actions_submerged.f_act_hold_metal_water_walking = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_hmww_walk :
  wwalk_chk false nil sub_walk_ids nil nil nil sub_sids nil
    (fn_body mario_actions_submerged.f_act_hold_metal_water_walking) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- the water-IDLE cluster (common_idle_step + is_anim_at_end ids; the
   action-end pair also is_anim_at_end-gates a set_mario_action; chase READS
   of marioObj->oInteractStatus into untracked temps -- NO chase stores) ---- *)
Example sub_wid_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_water_idle
  = Some (Gfun (Internal mario_actions_submerged.f_act_water_idle)).
Proof. vm_compute. reflexivity. Qed.
Example sub_wid_vars :
  fn_vars mario_actions_submerged.f_act_water_idle = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_wid_pok :
  sub_hold_pok mario_actions_submerged.f_act_water_idle = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_wid_walk :
  wwalk_chk false nil sub_idle_ids nil nil nil sub_sids nil
    (fn_body mario_actions_submerged.f_act_water_idle) = true.
Proof. vm_compute. reflexivity. Qed.

Example sub_hwid_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_hold_water_idle
  = Some (Gfun (Internal mario_actions_submerged.f_act_hold_water_idle)).
Proof. vm_compute. reflexivity. Qed.
Example sub_hwid_vars :
  fn_vars mario_actions_submerged.f_act_hold_water_idle = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_hwid_pok :
  sub_hold_pok mario_actions_submerged.f_act_hold_water_idle = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_hwid_walk :
  wwalk_chk false nil sub_idle_ids nil nil nil sub_sids nil
    (fn_body mario_actions_submerged.f_act_hold_water_idle) = true.
Proof. vm_compute. reflexivity. Qed.

Example sub_wae_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_water_action_end
  = Some (Gfun (Internal mario_actions_submerged.f_act_water_action_end)).
Proof. vm_compute. reflexivity. Qed.
Example sub_wae_vars :
  fn_vars mario_actions_submerged.f_act_water_action_end = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_wae_pok :
  sub_hold_pok mario_actions_submerged.f_act_water_action_end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_wae_walk :
  wwalk_chk false nil sub_idle_ids nil nil nil sub_sids nil
    (fn_body mario_actions_submerged.f_act_water_action_end) = true.
Proof. vm_compute. reflexivity. Qed.

Example sub_hwae_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_hold_water_action_end
  = Some (Gfun (Internal mario_actions_submerged.f_act_hold_water_action_end)).
Proof. vm_compute. reflexivity. Qed.
Example sub_hwae_vars :
  fn_vars mario_actions_submerged.f_act_hold_water_action_end = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_hwae_pok :
  sub_hold_pok mario_actions_submerged.f_act_hold_water_action_end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_hwae_walk :
  wwalk_chk false nil sub_idle_ids nil nil nil sub_sids nil
    (fn_body mario_actions_submerged.f_act_hold_water_action_end) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- the metal-water FALLING pair (set_mario_animation + stationary_slow_
   down + perform_water_step; faceAngle window store with a gSineTable load
   RHS; NO chase stores, cact=nil) ---- *)
Example sub_mwf2_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_metal_water_falling
  = Some (Gfun (Internal mario_actions_submerged.f_act_metal_water_falling)).
Proof. vm_compute. reflexivity. Qed.
Example sub_mwf2_vars :
  fn_vars mario_actions_submerged.f_act_metal_water_falling = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_mwf2_pok :
  sub_hold_pok mario_actions_submerged.f_act_metal_water_falling = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_mwf2_walk :
  wwalk_chk false nil sub_fall_ids nil nil nil sub_sids nil
    (fn_body mario_actions_submerged.f_act_metal_water_falling) = true.
Proof. vm_compute. reflexivity. Qed.

Example sub_hmwf2_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_hold_metal_water_falling
  = Some (Gfun (Internal mario_actions_submerged.f_act_hold_metal_water_falling)).
Proof. vm_compute. reflexivity. Qed.
Example sub_hmwf2_vars :
  fn_vars mario_actions_submerged.f_act_hold_metal_water_falling = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_hmwf2_pok :
  sub_hold_pok mario_actions_submerged.f_act_hold_metal_water_falling = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_hmwf2_walk :
  wwalk_chk false nil sub_fall_ids nil nil nil sub_sids nil
    (fn_body mario_actions_submerged.f_act_hold_metal_water_falling) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- act_water_death: stationary_slow_down + perform_water_step + set_mario_
   animation + level_trigger_warp; chases m->marioBodyState into _t'2 and writes
   eyeState (a non-pointer const into a SafeB chase-root block) => cact=[_t'2].
   No set_mario_action.  REUSES the slice-7 step residuals + the SHARED warp
   trigger -- NO new capstone trust. ---- *)
Example sub_wd_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_water_death
  = Some (Gfun (Internal mario_actions_submerged.f_act_water_death)).
Proof. vm_compute. reflexivity. Qed.
Example sub_wd_vars :
  fn_vars mario_actions_submerged.f_act_water_death = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_wd_pok :
  sub_hold_pok mario_actions_submerged.f_act_water_death = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_wd_nonparam :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_submerged.f_act_water_death))))
    sub_death_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_wd_walk :
  wwalk_chk false nil sub_death_ids nil sub_death_cact nil nil nil
    (fn_body mario_actions_submerged.f_act_water_death) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- act_drowning: the death-sibling (cact = [_t'3; _t'5; _t'6] for the
   marioBodyState eyeState writes + marioObj animFrame read) ---- *)
Example sub_dr_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_drowning
  = Some (Gfun (Internal mario_actions_submerged.f_act_drowning)).
Proof. vm_compute. reflexivity. Qed.
Example sub_dr_vars :
  fn_vars mario_actions_submerged.f_act_drowning = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_dr_pok :
  sub_hold_pok mario_actions_submerged.f_act_drowning = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_dr_nonparam :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_submerged.f_act_drowning))))
    sub_drown_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_dr_walk :
  wwalk_chk false nil sub_drown_ids nil sub_drown_cact nil nil nil
    (fn_body mario_actions_submerged.f_act_drowning) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- act_water_shocked: wact=[_t'2] (ternary-const action), cact=[_t'3;_t'8]
   (marioBodyState headAngle write + marioObj gfx read), xids=[play_sound;
   set_camera_shake_from_hit] (obj_ext) ---- *)
Example sub_sh_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_water_shocked
  = Some (Gfun (Internal mario_actions_submerged.f_act_water_shocked)).
Proof. vm_compute. reflexivity. Qed.
Example sub_sh_vars :
  fn_vars mario_actions_submerged.f_act_water_shocked = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_sh_pok :
  sub_hold_pok mario_actions_submerged.f_act_water_shocked = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_sh_nonparam_c :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_submerged.f_act_water_shocked))))
    sub_shock_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_sh_nonparam_w :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_submerged.f_act_water_shocked))))
    sub_shock_wact = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_sh_walk :
  wwalk_chk false sub_shock_wact sub_shock_ids nil sub_shock_cact
    sub_shock_xids sub_sids nil
    (fn_body mario_actions_submerged.f_act_water_shocked) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- the knockback pair: ONE cwks call via tids (act3_call_chk gates the
   ACT_WATER_IDLE const at full-index 2 = endAction); ids/wids/xids/sids all
   nil, the only row is sub_kb_tids_rows (call_pres_act3 cwks = Hcp_cwks). ---- *)
Example sub_bwkb_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_backward_water_kb
  = Some (Gfun (Internal mario_actions_submerged.f_act_backward_water_kb)).
Proof. vm_compute. reflexivity. Qed.
Example sub_bwkb_vars :
  fn_vars mario_actions_submerged.f_act_backward_water_kb = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_bwkb_pok :
  sub_hold_pok mario_actions_submerged.f_act_backward_water_kb = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_bwkb_walk :
  wwalk_chk false nil nil nil nil nil nil sub_kb_tids
    (fn_body mario_actions_submerged.f_act_backward_water_kb) = true.
Proof. vm_compute. reflexivity. Qed.

Example sub_fwkb_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_forward_water_kb
  = Some (Gfun (Internal mario_actions_submerged.f_act_forward_water_kb)).
Proof. vm_compute. reflexivity. Qed.
Example sub_fwkb_vars :
  fn_vars mario_actions_submerged.f_act_forward_water_kb = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_fwkb_pok :
  sub_hold_pok mario_actions_submerged.f_act_forward_water_kb = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_fwkb_walk :
  wwalk_chk false nil nil nil nil nil nil sub_kb_tids
    (fn_body mario_actions_submerged.f_act_forward_water_kb) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* The section: the leaf-callee discharge, keyed by the census.           *)
(* ====================================================================== *)

Section SubmergedLeafRows.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_mario_step : linkorder mario_step.prog lp.
  Hypothesis LO_sub : linkorder mario_actions_submerged.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_glob : forall gid,
      mem_id gid stored_globals = true ->
      forall bg, Genv.find_symbol (lp_ge lp) gid = Some bg ->
      bg <> bm /\
      (forall mm mm' ch0 (d : Z) vv,
          MWF mm -> Mem.store ch0 mm bg d vv = Some mm' -> MWF mm').
  Hypothesis HMWF_act : forall mm mm' vv,
      MWF mm ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store Mint32 mm bm 12 vv = Some mm' -> MWF mm'.

  Variable SafeB : block -> Prop.
  Hypothesis HSafeNotBm : forall b, SafeB b -> b <> bm.
  Hypothesis HchaseRoot : forall fld delta m b' o',
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) ->
      MWF m ->
      Mem.loadv Mptr m
        (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta)))
        = Some (Vptr b' o') ->
      SafeB b'.
  Hypothesis HMWF_chase : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_root : forall mm mm' fld (delta : Z) vv,
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) ->
      (forall bb oo, vv = Vptr bb oo -> SafeB bb) ->
      MWF mm ->
      Mem.store Mptr mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_sglob : forall m gb v,
      MWF m ->
      Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some gb ->
      Mem.load Mint32 m gb 0 = Some v ->
      forall bb oo, v <> Vptr bb oo.
  Hypothesis HchaseStep : forall m b ofs b' o',
      MWF m -> SafeB b ->
      Mem.loadv Mptr m (Vptr b ofs) = Some (Vptr b' o') ->
      SafeB b'.
  Hypothesis HMWF_chase_safe : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv = Vptr bb oo -> SafeB bb) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.

  (* set_mario_animation's terminal external -- the load_patchable_table
     animation-table reader, the SAME honest model-boundary class as the
     obj_ext rows (discharged at the capstone via Hpres_obj_ext). *)
  Hypothesis Hcpx_lpt :
    call_pres_ext lp bm NoA MWF mario._load_patchable_table.

  (* THE ONE honest step residual of slice 1: stop_and_set_height_to_floor.
     It writes m->pos[1]/m->vel[1]/forwardVel (window) and copies into
     marioObj's gfx pos/angle through the chased marioObj pointer (SafeB
     pool); it NEVER touches the action cell, so it is a genuine call_pres
     for any caller.  Discharged later by walking its sc-arc body. *)
  Hypothesis Hcp_sashf :
    call_pres lp bm NoA MWF mario_step._stop_and_set_height_to_floor.

  (* play_metal_water_jumping_sound: writes particleFlags/flags (window) and
     plays a sound via play_sound_if_no_flag; it NEVER touches the action
     cell, so a genuine call_pres for any caller.  Honest residual (its body
     walk -- play_sound_if_no_flag + play_sound obj_ext -- is a later unit). *)
  Hypothesis Hcp_pmwjs :
    call_pres lp bm NoA MWF mario_actions_submerged._play_metal_water_jumping_sound.

  (* perform_air_step: the air step (writes pos/vel, returns the step result;
     the CALLER dispatches the result to set the action), so a genuine
     call_pres.  ALREADY PROVED (PerformAirStepSurface.pas_cp) -- the capstone
     feeds its existing Hcp_pas Lemma, NO new trust. *)
  Hypothesis Hcp_pas :
    call_pres lp bm NoA MWF mario_step._perform_air_step.
  (* update_metal_water_jump_speed: writes forwardVel/vel (window) and returns
     a hit-ceiling flag; never the action cell, so a genuine call_pres.  Honest
     residual (its body walk is a later unit). *)
  Hypothesis Hcp_umwjs :
    call_pres lp bm NoA MWF mario_actions_submerged._update_metal_water_jump_speed.

  (* drop_and_set_mario_action: the held-object drop + set_mario_action.  A
     call_pres_act (writes action only via set_mario_action with the untainted
     const arg the leaf passes).  ALREADY PROVED (ObjectLeafSurface.dasma_row);
     the capstone feeds that existing term, NO new trust. *)
  Hypothesis Hcpa_dasma :
    call_pres_act lp bm NoA MWF mario._drop_and_set_mario_action.

  (* perform_ground_step: the ground step (writes pos/vel, returns the step
     result; the CALLER dispatches it to set the action), a genuine call_pres.
     ALREADY PROVED (MarioStepSurface.pgs_cp) -- the capstone feeds its existing
     Hcp_pgs Lemma, NO new trust. *)
  Hypothesis Hcp_pgs :
    call_pres lp bm NoA MWF mario_step._perform_ground_step.

  (* set_mario_anim_with_accel: set_mario_animation's accel-scaled sibling.
     Writes the anim window + chases marioObj's SafeB gfx anim pool through the
     anim id / accel scalar args; NEVER the action cell, so a genuine call_pres
     for any caller.  Honest residual (its body is already walked in
     AutomaticLeafSurface via the np3 channel -- promotable to a standalone
     call_pres Lemma later). *)
  Hypothesis Hcp_smawa :
    call_pres lp bm NoA MWF mario._set_mario_anim_with_accel.

  (* play_metal_water_walking_sound: writes particleFlags (window) and plays a
     footstep sound at anim frames 10/49; chases marioObj's gfx cameraToObject
     (SafeB read).  NEVER the action cell, so a genuine call_pres.  Honest
     residual (its body walk -- is_anim_past_frame + play_sound obj_ext -- is a
     later unit). *)
  Hypothesis Hcp_pmwws :
    call_pres lp bm NoA MWF mario_actions_submerged._play_metal_water_walking_sound.

  (* update_metal_water_walking_speed: writes forwardVel/faceAngle/slideVel/vel
     (window) from m->intendedMag/intendedYaw and reads m->floor->normal.y;
     NEVER the action cell, so a genuine call_pres.  Honest residual (its body
     walk -- approach_s32 + sins/coss ext + the m->floor chase read -- is a
     later unit). *)
  Hypothesis Hcp_umwws :
    call_pres lp bm NoA MWF mario_actions_submerged._update_metal_water_walking_speed.

  (* common_idle_step: the shared swim-idle step.  Writes m->faceAngle (window)
     + chases m->marioBodyState->headAngle (a SafeB chase-root block) + calls
     update_swimming_yaw/pitch/speed, perform_water_step, update_water_pitch,
     set_mario_animation / set_mario_anim_with_accel, set_swimming_at_surface_
     particles.  It NEVER touches the action cell (the act handlers dispatch
     set_mario_action themselves), so a genuine call_pres for any caller.
     Honest residual (its body walk -- chase machinery + perform_water_step --
     is a later unit). *)
  Hypothesis Hcp_cis :
    call_pres lp bm NoA MWF mario_actions_submerged._common_idle_step.

  (* stationary_slow_down: the water decel helper.  Writes m->angleVel/
     forwardVel/vel/faceAngle (window) from approach_f32/approach_s32 +
     get_buoyancy + coss/sins(gSineTable); NEVER the action cell, a genuine
     call_pres for any caller.  Honest residual (body walk a later unit). *)
  Hypothesis Hcp_ssd :
    call_pres lp bm NoA MWF mario_actions_submerged._stationary_slow_down.

  (* perform_water_step: the Tier-2 water step.  Writes m->vel (window) +
     chases marioObj's SafeB gfx pos/angle pool through vec3f_copy/vec3s_set;
     NEVER the action cell, a genuine call_pres for any caller.  Honest
     residual (body walk -- apply_water_current/perform_water_full_step +
     the gfx chase -- is a later unit). *)
  Hypothesis Hcp_pws :
    call_pres lp bm NoA MWF mario_actions_submerged._perform_water_step.

  (* level_trigger_warp: the SHARED warp-trigger.  Writes the sDelayedWarp*
     statics (stored_globals, bm/SafeB-disjoint) + reads m; NEVER the action
     cell, a genuine call_pres for any caller.  ALREADY discharged at the
     capstone (the floors/warp surfaces walk its body, call_pres_of_body +
     warp_pres) -- the capstone feeds that existing term, NO new trust. *)
  Hypothesis Hcp_ltw :
    call_pres lp bm NoA MWF level_update._level_trigger_warp.

  (* play_sound_if_no_flag: the flag-gated sound helper.  Writes m->flags
     (window) + plays a sound; NEVER the action cell, a genuine call_pres for
     any caller (the SAME Hpsinf class the airborne/stationary surfaces use).
     Honest residual (body walk = play_sound obj_ext + the flag store). *)
  Hypothesis Hcp_psinf :
    call_pres lp bm NoA MWF mario_actions_submerged._play_sound_if_no_flag.

  (* act_water_shocked's two terminal externals -- both obj_ext_ids members,
     the same audio/camera-shake model-boundary class as play_sound's row
     (discharged at the capstone via Hpres_obj_ext, NO new trust). *)
  Hypothesis Hcpx_psound : call_pres_ext lp bm NoA MWF mario._play_sound.
  Hypothesis Hcpx_scshf :
    call_pres_ext lp bm NoA MWF interaction._set_camera_shake_from_hit.

  (* the knockback step helper: action-preserving WHEN its endAction (param
     index 2 = the THIRD vargs element) is untainted.  Exactly call_pres_act3.
     An honest INTERNAL residual (cwks is internal in mario_actions_submerged.
     prog) -- dischargeable later via the #66 param-action arc (walk its body
     threading the untainted endAction param into the action store). *)
  Hypothesis Hcp_cwks :
    call_pres_act3 lp bm NoA MWF
      mario_actions_submerged._common_water_knockback_step.

  (* the keystone, instantiated once: set_mario_action is call_pres_act. *)
  Let Hsmact : call_pres_act lp bm NoA MWF mario._set_mario_action :=
    smact_pres lp LO_mario LO_mario_step bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe.

  (* ---- the walked helper rows ---- *)
  Lemma sub_iae_row : call_pres lp bm NoA MWF mario._is_anim_at_end.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._is_anim_at_end mario.f_is_anim_at_end
             nil nil nil nil LO_mario sub_iae_pin sub_iae_vars sub_iae_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_iae_walk.
  Qed.

  Lemma sub_sma_xids_rows : forall fid, mem_id fid sub_sma_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_sma_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_lpt | ].
    discriminate H.
  Qed.

  Lemma sub_sma_row : call_pres lp bm NoA MWF mario._set_mario_animation.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._set_mario_animation mario.f_set_mario_animation
             nil nil sub_sma_cact sub_sma_xids nil
             LO_mario sub_sma_pin sub_sma_vars sub_sma_pok sub_sma_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_sma_xids_rows.
    - intros fid' H. discriminate H.
    - exact sub_sma_walk.
  Qed.

  (* ---- the ids/sids row dispatchers for the leaf walks ---- *)
  Lemma sub_metal_ids_rows : forall fid, mem_id fid sub_metal_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_metal_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_iae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sashf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pmwjs | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pas | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_umwjs | ].
    discriminate H.
  Qed.

  Lemma sub_walk_ids_rows : forall fid, mem_id fid sub_walk_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_walk_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_smawa | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pmwws | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_umwws | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | ].
    discriminate H.
  Qed.

  Lemma sub_idle_ids_rows : forall fid, mem_id fid sub_idle_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_idle_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_cis | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_iae_row | ].
    discriminate H.
  Qed.

  Lemma sub_fall_ids_rows : forall fid, mem_id fid sub_fall_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_fall_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_ssd | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pws | ].
    discriminate H.
  Qed.

  Lemma sub_death_ids_rows : forall fid, mem_id fid sub_death_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_death_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_ssd | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pws | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_ltw | ].
    discriminate H.
  Qed.

  Lemma sub_drown_ids_rows : forall fid, mem_id fid sub_drown_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_drown_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_iae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_ltw | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_psinf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_ssd | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pws | ].
    discriminate H.
  Qed.

  Lemma sub_shock_ids_rows : forall fid, mem_id fid sub_shock_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_shock_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_ssd | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pws | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_psinf | ].
    discriminate H.
  Qed.

  Lemma sub_shock_xids_rows : forall fid, mem_id fid sub_shock_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_shock_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_scshf | ].
    discriminate H.
  Qed.

  Lemma sub_sids_rows : forall fid, mem_id fid sub_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpa_dasma | ].
    discriminate H.
  Qed.

  Lemma sub_kb_tids_rows : forall fid, mem_id fid sub_kb_tids = true ->
      call_pres_act3 lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_kb_tids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_cwks | ].
    discriminate H.
  Qed.

  (* ---- the leaf walks ---- *)
  Lemma act_metal_water_standing_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_metal_water_standing.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_metal_water_standing
             sub_metal_ids nil nil sub_sids nil
             sub_mws_vars sub_mws_pok).
    - exact sub_metal_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_mws_walk.
  Qed.

  Lemma act_metal_water_jump_land_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_metal_water_jump_land.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_metal_water_jump_land
             sub_metal_ids nil nil sub_sids nil
             sub_mwjl_vars sub_mwjl_pok).
    - exact sub_metal_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_mwjl_walk.
  Qed.

  Lemma act_metal_water_fall_land_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_metal_water_fall_land.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_metal_water_fall_land
             sub_metal_ids nil nil sub_sids nil
             sub_mwfl_vars sub_mwfl_pok).
    - exact sub_metal_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_mwfl_walk.
  Qed.

  Lemma act_metal_water_jump_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_metal_water_jump.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_metal_water_jump
             sub_metal_ids nil nil sub_sids nil
             sub_mwj_vars sub_mwj_pok).
    - exact sub_metal_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_mwj_walk.
  Qed.

  Lemma act_hold_metal_water_standing_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_hold_metal_water_standing.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_hold_metal_water_standing
             sub_metal_ids nil nil sub_sids nil
             sub_hmws_vars sub_hmws_pok).
    - exact sub_metal_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_hmws_walk.
  Qed.

  Lemma act_hold_metal_water_jump_land_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_hold_metal_water_jump_land.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_hold_metal_water_jump_land
             sub_metal_ids nil nil sub_sids nil
             sub_hmwjl_vars sub_hmwjl_pok).
    - exact sub_metal_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_hmwjl_walk.
  Qed.

  Lemma act_hold_metal_water_fall_land_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_hold_metal_water_fall_land.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_hold_metal_water_fall_land
             sub_metal_ids nil nil sub_sids nil
             sub_hmwfl_vars sub_hmwfl_pok).
    - exact sub_metal_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_hmwfl_walk.
  Qed.

  Lemma act_hold_metal_water_jump_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_hold_metal_water_jump.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_hold_metal_water_jump
             sub_metal_ids nil nil sub_sids nil
             sub_hmwj_vars sub_hmwj_pok).
    - exact sub_metal_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_hmwj_walk.
  Qed.

  Lemma act_metal_water_walking_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_metal_water_walking.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_metal_water_walking
             sub_walk_ids nil nil sub_sids nil
             sub_mww_vars sub_mww_pok).
    - exact sub_walk_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_mww_walk.
  Qed.

  Lemma act_hold_metal_water_walking_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_hold_metal_water_walking.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_hold_metal_water_walking
             sub_walk_ids nil nil sub_sids nil
             sub_hmww_vars sub_hmww_pok).
    - exact sub_walk_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_hmww_walk.
  Qed.

  Lemma act_water_idle_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_water_idle.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_water_idle
             sub_idle_ids nil nil sub_sids nil
             sub_wid_vars sub_wid_pok).
    - exact sub_idle_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_wid_walk.
  Qed.

  Lemma act_hold_water_idle_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_hold_water_idle.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_hold_water_idle
             sub_idle_ids nil nil sub_sids nil
             sub_hwid_vars sub_hwid_pok).
    - exact sub_idle_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_hwid_walk.
  Qed.

  Lemma act_water_action_end_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_water_action_end.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_water_action_end
             sub_idle_ids nil nil sub_sids nil
             sub_wae_vars sub_wae_pok).
    - exact sub_idle_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_wae_walk.
  Qed.

  Lemma act_hold_water_action_end_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_hold_water_action_end.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_hold_water_action_end
             sub_idle_ids nil nil sub_sids nil
             sub_hwae_vars sub_hwae_pok).
    - exact sub_idle_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_hwae_walk.
  Qed.

  Lemma act_metal_water_falling_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_metal_water_falling.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_metal_water_falling
             sub_fall_ids nil nil sub_sids nil
             sub_mwf2_vars sub_mwf2_pok).
    - exact sub_fall_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_mwf2_walk.
  Qed.

  Lemma act_hold_metal_water_falling_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_hold_metal_water_falling.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_hold_metal_water_falling
             sub_fall_ids nil nil sub_sids nil
             sub_hmwf2_vars sub_hmwf2_pok).
    - exact sub_fall_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_hmwf2_walk.
  Qed.

  Lemma act_water_death_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_water_death.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_water_death
             sub_death_ids nil sub_death_cact nil nil nil
             sub_wd_vars sub_wd_pok sub_wd_nonparam).
    - exact sub_death_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_wd_walk.
  Qed.

  Lemma act_drowning_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_drowning.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_drowning
             sub_drown_ids nil sub_drown_cact nil nil nil
             sub_dr_vars sub_dr_pok sub_dr_nonparam).
    - exact sub_drown_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_dr_walk.
  Qed.

  Lemma act_water_shocked_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_water_shocked.
  Proof.
    apply (body_pres_of_wwalk_wact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_water_shocked
             sub_shock_wact sub_shock_ids nil sub_shock_cact
             sub_shock_xids sub_sids nil
             sub_sh_vars sub_sh_pok sub_sh_nonparam_c sub_sh_nonparam_w).
    - exact sub_shock_ids_rows.
    - intros fid' H. discriminate H.
    - exact sub_shock_xids_rows.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_sh_walk.
  Qed.

  Lemma act_backward_water_kb_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_backward_water_kb.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_backward_water_kb
             nil nil nil nil sub_kb_tids
             sub_bwkb_vars sub_bwkb_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_kb_tids_rows.
    - exact sub_bwkb_walk.
  Qed.

  Lemma act_forward_water_kb_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_forward_water_kb.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_forward_water_kb
             nil nil nil nil sub_kb_tids
             sub_fwkb_vars sub_fwkb_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_kb_tids_rows.
    - exact sub_fwkb_walk.
  Qed.

  (* ================================================================== *)
  (* THE PAYOFF: the census-keyed leaf discharge.  The walked leaf is   *)
  (* discharged here; everything else falls through to the rest premise *)
  (* over sub_rest_ids.                                                 *)
  (* ================================================================== *)
  Lemma submerged_leaf_callees_pres :
    (forall fid f, mem_id fid sub_rest_ids = true ->
       (prog_defmap mario_actions_submerged.prog) ! fid
         = Some (Gfun (Internal f)) ->
       body_pres lp NoA MWF bm f) ->
    forall fid f, mem_id fid submerged_callee_ids = true ->
      (prog_defmap mario_actions_submerged.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f.
  Proof.
    intros Hrest fid f H Hdm.
    destruct (Pos.eqb fid mario_actions_submerged._act_metal_water_standing)
      eqn:Ew1.
    { apply Pos.eqb_eq in Ew1; subst fid.
      rewrite sub_mws_pin in Hdm. injection Hdm as <-.
      exact act_metal_water_standing_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_metal_water_jump_land)
      eqn:Ew2.
    { apply Pos.eqb_eq in Ew2; subst fid.
      rewrite sub_mwjl_pin in Hdm. injection Hdm as <-.
      exact act_metal_water_jump_land_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_metal_water_fall_land)
      eqn:Ew3.
    { apply Pos.eqb_eq in Ew3; subst fid.
      rewrite sub_mwfl_pin in Hdm. injection Hdm as <-.
      exact act_metal_water_fall_land_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_metal_water_jump)
      eqn:Ew4.
    { apply Pos.eqb_eq in Ew4; subst fid.
      rewrite sub_mwj_pin in Hdm. injection Hdm as <-.
      exact act_metal_water_jump_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_hold_metal_water_standing)
      eqn:Ew5.
    { apply Pos.eqb_eq in Ew5; subst fid.
      rewrite sub_hmws_pin in Hdm. injection Hdm as <-.
      exact act_hold_metal_water_standing_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_hold_metal_water_jump_land)
      eqn:Ew6.
    { apply Pos.eqb_eq in Ew6; subst fid.
      rewrite sub_hmwjl_pin in Hdm. injection Hdm as <-.
      exact act_hold_metal_water_jump_land_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_hold_metal_water_fall_land)
      eqn:Ew7.
    { apply Pos.eqb_eq in Ew7; subst fid.
      rewrite sub_hmwfl_pin in Hdm. injection Hdm as <-.
      exact act_hold_metal_water_fall_land_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_hold_metal_water_jump)
      eqn:Ew8.
    { apply Pos.eqb_eq in Ew8; subst fid.
      rewrite sub_hmwj_pin in Hdm. injection Hdm as <-.
      exact act_hold_metal_water_jump_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_metal_water_walking)
      eqn:Ew9.
    { apply Pos.eqb_eq in Ew9; subst fid.
      rewrite sub_mww_pin in Hdm. injection Hdm as <-.
      exact act_metal_water_walking_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_hold_metal_water_walking)
      eqn:Ew10.
    { apply Pos.eqb_eq in Ew10; subst fid.
      rewrite sub_hmww_pin in Hdm. injection Hdm as <-.
      exact act_hold_metal_water_walking_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_water_idle)
      eqn:Ew11.
    { apply Pos.eqb_eq in Ew11; subst fid.
      rewrite sub_wid_pin in Hdm. injection Hdm as <-.
      exact act_water_idle_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_hold_water_idle)
      eqn:Ew12.
    { apply Pos.eqb_eq in Ew12; subst fid.
      rewrite sub_hwid_pin in Hdm. injection Hdm as <-.
      exact act_hold_water_idle_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_water_action_end)
      eqn:Ew13.
    { apply Pos.eqb_eq in Ew13; subst fid.
      rewrite sub_wae_pin in Hdm. injection Hdm as <-.
      exact act_water_action_end_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_hold_water_action_end)
      eqn:Ew14.
    { apply Pos.eqb_eq in Ew14; subst fid.
      rewrite sub_hwae_pin in Hdm. injection Hdm as <-.
      exact act_hold_water_action_end_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_metal_water_falling)
      eqn:Ew15.
    { apply Pos.eqb_eq in Ew15; subst fid.
      rewrite sub_mwf2_pin in Hdm. injection Hdm as <-.
      exact act_metal_water_falling_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_hold_metal_water_falling)
      eqn:Ew16.
    { apply Pos.eqb_eq in Ew16; subst fid.
      rewrite sub_hmwf2_pin in Hdm. injection Hdm as <-.
      exact act_hold_metal_water_falling_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_water_death)
      eqn:Ew17.
    { apply Pos.eqb_eq in Ew17; subst fid.
      rewrite sub_wd_pin in Hdm. injection Hdm as <-.
      exact act_water_death_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_drowning)
      eqn:Ew18.
    { apply Pos.eqb_eq in Ew18; subst fid.
      rewrite sub_dr_pin in Hdm. injection Hdm as <-.
      exact act_drowning_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_water_shocked)
      eqn:Ew19.
    { apply Pos.eqb_eq in Ew19; subst fid.
      rewrite sub_sh_pin in Hdm. injection Hdm as <-.
      exact act_water_shocked_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_backward_water_kb)
      eqn:Ew20.
    { apply Pos.eqb_eq in Ew20; subst fid.
      rewrite sub_bwkb_pin in Hdm. injection Hdm as <-.
      exact act_backward_water_kb_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_forward_water_kb)
      eqn:Ew21.
    { apply Pos.eqb_eq in Ew21; subst fid.
      rewrite sub_fwkb_pin in Hdm. injection Hdm as <-.
      exact act_forward_water_kb_pres. }
    (* REST: fid is in the census and not a walked id, so it is in the
       filter that defines sub_rest_ids. *)
    apply (Hrest fid f); [ | exact Hdm ].
    unfold sub_rest_ids.
    apply mem_id_filter_true; [ exact H | ].
    unfold sub_walked_ids. cbn [mem_id existsb].
    rewrite Ew1, Ew2, Ew3, Ew4, Ew5, Ew6, Ew7, Ew8, Ew9, Ew10,
      Ew11, Ew12, Ew13, Ew14, Ew15, Ew16, Ew17, Ew18, Ew19,
      Ew20, Ew21. reflexivity.
  Qed.

End SubmergedLeafRows.
