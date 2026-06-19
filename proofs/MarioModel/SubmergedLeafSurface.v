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
From SM64.Generated Require mario mario_step mario_actions_object
  mario_actions_airborne mario_actions_submerged level_update interaction.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit FloorsSurface.
From SM64.Proofs Require Import ActWriterSurface SubmergedSurface MarioStepSurface.
(* Require (not Import) ObjectLeafSurface / MovingLeafSurface: we only reuse
   their proved mtho_row / mov_smawa_row, referenced qualified -- avoids name
   shadowing. *)
From SM64.Proofs Require ObjectLeafSurface MovingLeafSurface.

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
(* set_mario_anim_with_accel moved OUT of ids into the np3 channel: it is the
   np3 body (its 3rd arg `accel` must be non-pointer to safely store), so it is
   discharged as call_pres_np3 (sub_smawa_row, reusing MovingLeafSurface.
   mov_smawa_row).  The metal_water_walking leaves pass val04 (a float-derived
   s32, nids-tracked via [_val04; _t'5]) as that 3rd arg. *)
Definition sub_walk_ids : list ident :=
  mario_actions_submerged._play_metal_water_walking_sound
    :: mario_actions_submerged._update_metal_water_walking_speed
    :: mario_step._perform_ground_step :: nil.
Definition sub_walk_np3 : list ident :=
  mario._set_mario_anim_with_accel :: nil.
Definition sub_walk_nids : list ident :=
  mario_actions_submerged._val04 :: mario_actions_submerged._t'5 :: nil.

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

(* the submerged cancel gate (check_common_submerged_cancels): window stores
   (pos[1], heldObj:=NULL), a chase store through m->heldObj (the held-shell
   oInteractStatus:=INT_STATUS_STOP_RIDING=1<<22, a non-ptr Oshl const into a
   chase-root block; heldObj in chase_root_fields), a set_mario_action(const
   ACT_DROWNING) (sids), the nullary stop_shell_music() (xids = the audio
   model-boundary, reuses Hpres_obj_ext -- NO new trust), and the tail call
   transition_submerged_to_walking(m) (ids = ONE honest INTERNAL residual,
   it's f_transition_submerged_to_walking in mario.prog, dischargeable). *)
Definition sub_ccsc_cact : list ident :=
  mario_actions_submerged._t'12 :: mario_actions_submerged._t'10 :: nil.
Definition sub_ccsc_ids : list ident :=
  mario_actions_submerged._transition_submerged_to_walking :: nil.
Definition sub_ccsc_xids : list ident :=
  interaction._stop_shell_music :: nil.

(* the throw/punch pair (act_water_throw / act_water_punch): both swim via the
   shared helpers (update_swimming_{yaw,pitch,speed}, update_water_pitch,
   perform_water_step), set_mario_animation, play_sound_if_no_flag, the
   approach_s32-into-headAngle[0] chase store (tshort field => any value OK),
   is_anim_at_end, and set_mario_action(const).  CACT IS PER-LEAF: throw chases
   m->marioBodyState into _t'5/_t'4, but in PUNCH those SAME temps hold a
   segmented_to_virtual result (void ptr) and an is_anim_at_end result (tint)
   -- so a shared cact would mis-gate punch's Scall(Some _t'5).  ids/xids ARE
   shared (supersets are harmless: extra ids/xids members never fire).  throw
   adds mario_throw_held_object; punch adds check_water_grab; xids =
   {approach_s32, segmented_to_virtual, play_shell_music} all obj_ext (NO new
   trust).  Honest new internal residuals: the 4 swim helpers + mtho + cwg. *)
Definition sub_wt_cact : list ident :=
  mario_actions_submerged._t'5 :: mario_actions_submerged._t'4 :: nil.
Definition sub_wp_cact : list ident :=
  mario_actions_submerged._t'11 :: mario_actions_submerged._t'10 :: nil.
Definition sub_tp_ids : list ident :=
  mario_actions_submerged._update_swimming_yaw
    :: mario_actions_submerged._update_swimming_pitch
    :: mario_actions_submerged._update_swimming_speed
    :: mario_actions_submerged._perform_water_step
    :: mario_actions_submerged._update_water_pitch
    :: mario_actions_submerged._set_mario_animation
    :: mario_actions_submerged._play_sound_if_no_flag
    :: mario_actions_submerged._is_anim_at_end
    :: mario_actions_submerged._mario_throw_held_object
    :: mario_actions_submerged._check_water_grab :: nil.
Definition sub_tp_xids : list ident :=
  mario_actions_object._approach_s32
    :: interaction._segmented_to_virtual
    :: interaction._play_shell_music :: nil.

(* SLICE 14 (the swimming cluster -- the 7 free/hold breaststroke/swimming_end/
   flutter_kick leaves + water_shell_swimming).  Each is the m-only swim action
   body: it stores sSwimStrength (the free trio; a stored_globals data symbol,
   Hglob_blk-disjoint), set_mario_action/drop_and_set_mario_action(const) the
   action cancels (sub_sids -- the untainted swim/water-action consts), and
   calls the shared swim helpers.  cact IS PER-LEAF (the marioObj/heldObj chase
   temps each body loads -- marioObj for the play_sound cameraToObject arg and
   the rawData.asS32[43] held-flag load; heldObj for water_shell_swimming's
   oInteractStatus chase store + its own heldObj:=NULL chase-root clear).  ids =
   the swim helpers, all genuine call_pres (none touches the action cell); xids
   = play_sound/stop_shell_music (obj_ext audio boundary, NO new trust) +
   approach_f32 (the pure-math float external -- the ONE new honest boundary). *)
Definition swim_ids : list ident :=
  mario_actions_submerged._check_water_jump
    :: mario_actions_submerged._set_anim_to_frame
    :: mario_actions_submerged._set_mario_animation
    :: mario_actions_submerged._reset_bob_variables
    :: mario_actions_submerged._common_swimming_step
    :: mario_actions_submerged._play_swimming_noise :: nil.
Definition swim_xids : list ident :=
  mario_actions_submerged._play_sound
    :: mario_actions_submerged._approach_f32
    :: mario_actions_submerged._stop_shell_music :: nil.
(* per-leaf cact: the marioObj/heldObj chase temps. *)
Definition swim_bs_cact : list ident := mario_actions_submerged._t'11 :: nil.
Definition swim_hbs_cact : list ident :=
  mario_actions_submerged._t'22 :: mario_actions_submerged._t'10 :: nil.
Definition swim_hse_cact : list ident := mario_actions_submerged._t'14 :: nil.
Definition swim_hfk_cact : list ident := mario_actions_submerged._t'10 :: nil.
Definition swim_wss_cact : list ident :=
  mario_actions_submerged._t'8 :: mario_actions_submerged._t'6 :: nil.

(* SLICE 15 (the LAST two submerged leaves -- act_water_plunge +
   act_caught_in_whirlpool).  Both are straight-line switch bodies (NOT loops).
   water_plunge stores sBobIncrement=0 (stored_globals), set_mario_action(const)
   the 6-case resolve (sub_sids), play_sound (obj_ext) via marioObj cact temps +
   a heldObj!=NULL read temp, and calls swimming_near_surface / stationary_slow_
   down / perform_water_step / set_mario_animation.  whirlpool chases m->marioObj
   (oMarioWhirlpoolPosY float chase store) + m->usedObj (whirlpool oPos reads),
   sets pos/vel/faceAngle window, calls level_trigger_warp (the SHARED warp) +
   set_mario_animation, and the obj_ext math/copy externals sqrtf / atan2s /
   vec3f_copy / vec3s_set.  ONE new honest residual: swimming_near_surface. *)
Definition wp_ids : list ident :=
  mario_actions_submerged._swimming_near_surface
    :: mario_actions_submerged._stationary_slow_down
    :: mario_actions_submerged._perform_water_step
    :: mario_actions_submerged._set_mario_animation :: nil.
Definition wp_xids : list ident := mario_actions_submerged._play_sound :: nil.
Definition wp_cact : list ident :=
  mario_actions_submerged._t'19
    :: mario_actions_submerged._t'14
    :: mario_actions_submerged._t'13 :: nil.
Definition whirl_ids : list ident :=
  mario_actions_submerged._level_trigger_warp
    :: mario_actions_submerged._set_mario_animation :: nil.
Definition whirl_xids : list ident :=
  mario_actions_submerged._sqrtf
    :: mario_actions_submerged._atan2s
    :: mario_actions_submerged._vec3f_copy
    :: mario_actions_submerged._vec3s_set :: nil.
Definition whirl_cact : list ident :=
  mario_actions_submerged._marioObj :: mario_actions_submerged._whirlpool :: nil.

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
    :: mario_actions_submerged._act_forward_water_kb
    :: mario_actions_submerged._check_common_submerged_cancels
    :: mario_actions_submerged._act_water_throw
    :: mario_actions_submerged._act_water_punch
    :: mario_actions_submerged._act_breaststroke
    :: mario_actions_submerged._act_swimming_end
    :: mario_actions_submerged._act_flutter_kick
    :: mario_actions_submerged._act_hold_breaststroke
    :: mario_actions_submerged._act_hold_swimming_end
    :: mario_actions_submerged._act_hold_flutter_kick
    :: mario_actions_submerged._act_water_shell_swimming
    :: mario_actions_submerged._act_water_plunge
    :: mario_actions_submerged._act_caught_in_whirlpool :: nil.
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

(* ---- mario_set_forward_vel (PURE window stores + gSineTable loads; the same
   already-PROVED helper as ActWriterSurface.msfv_row / AutomaticLeafSurface.
   Hmsfv -- all-nil censuses, its only non-window store is the vel[0] indexed
   write the engine's window recognizer already handles) ---- *)
Example sub_msfv_pin :
  (prog_defmap mario.prog) ! mario._mario_set_forward_vel
  = Some (Gfun (Internal mario.f_mario_set_forward_vel)).
Proof. vm_compute. reflexivity. Qed.
Example sub_msfv_vars : fn_vars mario.f_mario_set_forward_vel = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_msfv_pok :
  match fn_params mario.f_mario_set_forward_vel with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_msfv_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario.f_mario_set_forward_vel) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- stop_and_set_height_to_floor (mario_step.prog): the SAME walk already
   PROVED as AutomaticLeafSurface.Hsasthf -- ids=[mario_set_forward_vel],
   xids=[vec3f_copy; vec3s_set] (both write through marioObj->header.gfx.*
   chase dsts -- a NON-bm SafeB object-pool block, action cell @12 untouched;
   discharged via the EXISTING obj_ext boundary Hcpx_v3fc/Hcpx_v3ss the
   whirlpool slice already assumes -- NO new trust) ---- *)
Definition sub_sashf_ids : list ident := mario._mario_set_forward_vel :: nil.
Definition sub_sashf_xids : list ident :=
  mario_step._vec3f_copy :: mario._vec3s_set :: nil.
Example sub_sashf_pin :
  (prog_defmap mario_step.prog) ! mario_step._stop_and_set_height_to_floor
  = Some (Gfun (Internal mario_step.f_stop_and_set_height_to_floor)).
Proof. vm_compute. reflexivity. Qed.
Example sub_sashf_vars :
  fn_vars mario_step.f_stop_and_set_height_to_floor = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_sashf_pok :
  match fn_params mario_step.f_stop_and_set_height_to_floor with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_sashf_walk :
  wwalk_chk false nil sub_sashf_ids nil nil sub_sashf_xids nil nil
    (fn_body mario_step.f_stop_and_set_height_to_floor) = true.
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

(* ---- update_swimming_pitch (pure window stores m->faceAngle[0]; reads
   m->controller->stickY as a chase load into a temp; ZERO calls) ---- *)
Example sub_usp_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._update_swimming_pitch
  = Some (Gfun (Internal mario_actions_submerged.f_update_swimming_pitch)).
Proof. vm_compute. reflexivity. Qed.
Example sub_usp_vars :
  fn_vars mario_actions_submerged.f_update_swimming_pitch = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_usp_pok :
  match fn_params mario_actions_submerged.f_update_swimming_pitch with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_usp_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario_actions_submerged.f_update_swimming_pitch) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- update_swimming_yaw (window stores m->angleVel/faceAngle; ONE
   approach_s32 external -> xids, reuses the obj_ext boundary) ---- *)
Definition sub_usy_xids : list ident := mario_actions_object._approach_s32 :: nil.
Example sub_usy_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._update_swimming_yaw
  = Some (Gfun (Internal mario_actions_submerged.f_update_swimming_yaw)).
Proof. vm_compute. reflexivity. Qed.
Example sub_usy_vars :
  fn_vars mario_actions_submerged.f_update_swimming_yaw = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_usy_pok :
  match fn_params mario_actions_submerged.f_update_swimming_yaw with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_usy_walk :
  wwalk_chk false nil nil nil nil sub_usy_xids nil nil
    (fn_body mario_actions_submerged.f_update_swimming_yaw) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- update_water_pitch (chase stores through m->marioObj: gfx.pos[1] float
   += and gfx.angle[0] s16 = scaled; sins -> gSineTable load, NO external) ---- *)
Definition sub_uwp_cact : list ident := mario_actions_submerged._marioObj :: nil.
Example sub_uwp_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._update_water_pitch
  = Some (Gfun (Internal mario_actions_submerged.f_update_water_pitch)).
Proof. vm_compute. reflexivity. Qed.
Example sub_uwp_vars :
  fn_vars mario_actions_submerged.f_update_water_pitch = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_uwp_pok :
  match fn_params mario_actions_submerged.f_update_water_pitch with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_uwp_nonparam :
  forallb (fun t' => negb (mem_id t'
             (map fst (fn_params mario_actions_submerged.f_update_water_pitch))))
          sub_uwp_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_uwp_walk :
  wwalk_chk false nil nil nil sub_uwp_cact nil nil nil
    (fn_body mario_actions_submerged.f_update_water_pitch) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- get_buoyancy (NO stores; sole call is swimming_near_surface, already
   discharged as sns_cp; reads m->flags/action) -> ids=[swimming_near_surface] *)
Definition sub_gb_ids : list ident :=
  mario_actions_submerged._swimming_near_surface :: nil.
Example sub_gb_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._get_buoyancy
  = Some (Gfun (Internal mario_actions_submerged.f_get_buoyancy)).
Proof. vm_compute. reflexivity. Qed.
Example sub_gb_vars : fn_vars mario_actions_submerged.f_get_buoyancy = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_gb_pok :
  match fn_params mario_actions_submerged.f_get_buoyancy with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_gb_walk :
  wwalk_chk false nil sub_gb_ids nil nil nil nil nil
    (fn_body mario_actions_submerged.f_get_buoyancy) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- update_swimming_speed (window stores forwardVel/vel[0..2]; sole call is
   get_buoyancy; coss/sins = gSineTable loads) -> ids=[get_buoyancy] *)
Definition sub_uss_ids : list ident :=
  mario_actions_submerged._get_buoyancy :: nil.
Example sub_uss_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._update_swimming_speed
  = Some (Gfun (Internal mario_actions_submerged.f_update_swimming_speed)).
Proof. vm_compute. reflexivity. Qed.
Example sub_uss_vars :
  fn_vars mario_actions_submerged.f_update_swimming_speed = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_uss_pok :
  match fn_params mario_actions_submerged.f_update_swimming_speed with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_uss_walk :
  wwalk_chk false nil sub_uss_ids nil nil nil nil nil
    (fn_body mario_actions_submerged.f_update_swimming_speed) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- stationary_slow_down (window stores angleVel/forwardVel/vel/faceAngle;
   sole internal call get_buoyancy -> ids; approach_f32/approach_s32 externals
   -> xids, both obj_ext; coss/sins = gSineTable loads) *)
Definition sub_ssd_ids : list ident :=
  mario_actions_submerged._get_buoyancy :: nil.
Definition sub_ssd_xids : list ident :=
  mario_actions_submerged._approach_f32 :: mario_actions_object._approach_s32 :: nil.
Example sub_ssd_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._stationary_slow_down
  = Some (Gfun (Internal mario_actions_submerged.f_stationary_slow_down)).
Proof. vm_compute. reflexivity. Qed.
Example sub_ssd_vars :
  fn_vars mario_actions_submerged.f_stationary_slow_down = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_ssd_pok :
  match fn_params mario_actions_submerged.f_stationary_slow_down with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_ssd_walk :
  wwalk_chk false nil sub_ssd_ids nil nil sub_ssd_xids nil nil
    (fn_body mario_actions_submerged.f_stationary_slow_down) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- play_swimming_noise (chase reads marioObj->animFrame/cameraToObject;
   ONE conditional play_sound (obj_ext); NO stores) -> xids=[play_sound] *)
Definition sub_psn_xids : list ident := mario._play_sound :: nil.
Example sub_psn_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._play_swimming_noise
  = Some (Gfun (Internal mario_actions_submerged.f_play_swimming_noise)).
Proof. vm_compute. reflexivity. Qed.
Example sub_psn_vars :
  fn_vars mario_actions_submerged.f_play_swimming_noise = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_psn_pok :
  match fn_params mario_actions_submerged.f_play_swimming_noise with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_psn_walk :
  wwalk_chk false nil nil nil nil sub_psn_xids nil nil
    (fn_body mario_actions_submerged.f_play_swimming_noise) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- play_sound_if_no_flag (mario.prog): window read of m->flags; conditional
   play_sound (obj_ext) + window store m->flags |= flags -> xids=[play_sound].
   Reuses sub_psn_xids (= [play_sound]). *)
Example sub_psinf_pin :
  (prog_defmap mario.prog) ! mario._play_sound_if_no_flag
  = Some (Gfun (Internal mario.f_play_sound_if_no_flag)).
Proof. vm_compute. reflexivity. Qed.
Example sub_psinf_vars : fn_vars mario.f_play_sound_if_no_flag = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_psinf_pok :
  match fn_params mario.f_play_sound_if_no_flag with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_psinf_walk :
  wwalk_chk false nil nil nil nil sub_psn_xids nil nil
    (fn_body mario.f_play_sound_if_no_flag) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- is_anim_past_frame (mario.prog): chase reads of marioObj animInfo,
   returns bool; NO stores, NO calls -> all censuses nil (twin of is_anim_at_end) *)
Example sub_iapf_pin :
  (prog_defmap mario.prog) ! mario._is_anim_past_frame
  = Some (Gfun (Internal mario.f_is_anim_past_frame)).
Proof. vm_compute. reflexivity. Qed.
Example sub_iapf_vars : fn_vars mario.f_is_anim_past_frame = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_iapf_pok :
  match fn_params mario.f_is_anim_past_frame with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_iapf_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario.f_is_anim_past_frame) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- play_metal_water_jumping_sound: window store particleFlags; sole call is
   play_sound_if_no_flag (sub_psinf_row) -> ids=[play_sound_if_no_flag] *)
Definition sub_pmwjs_ids : list ident :=
  mario_actions_submerged._play_sound_if_no_flag :: nil.
Example sub_pmwjs_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._play_metal_water_jumping_sound
  = Some (Gfun (Internal mario_actions_submerged.f_play_metal_water_jumping_sound)).
Proof. vm_compute. reflexivity. Qed.
Example sub_pmwjs_vars :
  fn_vars mario_actions_submerged.f_play_metal_water_jumping_sound = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_pmwjs_pok :
  match fn_params mario_actions_submerged.f_play_metal_water_jumping_sound with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_pmwjs_walk :
  wwalk_chk false nil sub_pmwjs_ids nil nil nil nil nil
    (fn_body mario_actions_submerged.f_play_metal_water_jumping_sound) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- play_metal_water_walking_sound: window store particleFlags;
   ids=[is_anim_past_frame], xids=[play_sound] (sub_psn_xids); chase reads *)
Definition sub_pmwws_ids : list ident :=
  mario_actions_submerged._is_anim_past_frame :: nil.
Example sub_pmwws_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._play_metal_water_walking_sound
  = Some (Gfun (Internal mario_actions_submerged.f_play_metal_water_walking_sound)).
Proof. vm_compute. reflexivity. Qed.
Example sub_pmwws_vars :
  fn_vars mario_actions_submerged.f_play_metal_water_walking_sound = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_pmwws_pok :
  match fn_params mario_actions_submerged.f_play_metal_water_walking_sound with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_pmwws_walk :
  wwalk_chk false nil sub_pmwws_ids nil nil sub_psn_xids nil nil
    (fn_body mario_actions_submerged.f_play_metal_water_walking_sound) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- update_metal_water_walking_speed: window stores; xids=[approach_s32]
   (Hcpx_approach); m->floor chase read; sins/coss = gSineTable loads *)
Definition sub_umwws_xids : list ident :=
  mario_actions_object._approach_s32 :: nil.
Example sub_umwws_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._update_metal_water_walking_speed
  = Some (Gfun (Internal mario_actions_submerged.f_update_metal_water_walking_speed)).
Proof. vm_compute. reflexivity. Qed.
Example sub_umwws_vars :
  fn_vars mario_actions_submerged.f_update_metal_water_walking_speed = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_umwws_pok :
  match fn_params mario_actions_submerged.f_update_metal_water_walking_speed with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_umwws_walk :
  wwalk_chk false nil nil nil nil sub_umwws_xids nil nil
    (fn_body mario_actions_submerged.f_update_metal_water_walking_speed) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- update_metal_water_jump_speed: window stores; xids=[approach_f32]
   (Hcpx_af32); sins/coss = gSineTable loads *)
Definition sub_umwjs_xids : list ident :=
  mario_actions_submerged._approach_f32 :: nil.
Example sub_umwjs_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._update_metal_water_jump_speed
  = Some (Gfun (Internal mario_actions_submerged.f_update_metal_water_jump_speed)).
Proof. vm_compute. reflexivity. Qed.
Example sub_umwjs_vars :
  fn_vars mario_actions_submerged.f_update_metal_water_jump_speed = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_umwjs_pok :
  match fn_params mario_actions_submerged.f_update_metal_water_jump_speed with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_umwjs_walk :
  wwalk_chk false nil nil nil nil sub_umwjs_xids nil nil
    (fn_body mario_actions_submerged.f_update_metal_water_jump_speed) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- reset_bob_variables (three DIRECT static-global stores: sBobTimer = 0,
   sBobIncrement = 0x800, sBobHeight = m->faceAngle[0]/256 + 20; all three idents
   now in CensusV2.stored_globals, so glob_store_chk accepts each Sassign).  No
   callees, no externals -- every census is nil. ---- *)
Example sub_rbv_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._reset_bob_variables
  = Some (Gfun (Internal mario_actions_submerged.f_reset_bob_variables)).
Proof. vm_compute. reflexivity. Qed.
Example sub_rbv_vars :
  fn_vars mario_actions_submerged.f_reset_bob_variables = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_rbv_pok :
  match fn_params mario_actions_submerged.f_reset_bob_variables with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_rbv_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario_actions_submerged.f_reset_bob_variables) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- common_water_knockback_step (the call_pres_act3 kb helper): writes
   m->action via set_mario_action(m, health>=0x100 ? endAction : ACT_WATER_DEATH,
   0).  The ternary lowers to `_t'1 = (uint)endAction` / `_t'1 = (uint)ACT_*`,
   both an I32 cast into the action temp -- accepted by wsrc_chk's act-temp /
   const cast arms.  endAction is the THIRD param (the act3 gate's untainted
   aval), arg3 the value-irrelevant 4th -> call_pres_act3_of_wwalk_p4.
   ids = stationary_slow_down (sub_ssd_row) + perform_water_step (Hcp_pws) +
   set_mario_animation (sub_sma_row) + is_anim_at_end (sub_iae_row);
   cact = [_t'4] (m->marioBodyState->headAngle[0] chase store);
   sids = set_mario_action (Hsmact). ---- *)
Definition sub_cwks_wact : list ident :=
  mario_actions_submerged._endAction :: mario_actions_submerged._t'1 :: nil.
Definition sub_cwks_ids : list ident :=
  mario_actions_submerged._stationary_slow_down
  :: mario_actions_submerged._perform_water_step
  :: mario._set_mario_animation :: mario._is_anim_at_end :: nil.
Definition sub_cwks_cact : list ident :=
  mario_actions_submerged._t'4 :: nil.
Definition sub_cwks_sids : list ident :=
  mario._set_mario_action :: nil.
Example sub_cwks_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._common_water_knockback_step
  = Some (Gfun (Internal mario_actions_submerged.f_common_water_knockback_step)).
Proof. vm_compute. reflexivity. Qed.
Example sub_cwks_vars :
  fn_vars mario_actions_submerged.f_common_water_knockback_step = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_cwks_params :
  fn_params mario_actions_submerged.f_common_water_knockback_step
  = (mario_actions_airborne._m, tyMSp)
      :: (mario_actions_submerged._animation, tint)
      :: (mario_actions_submerged._endAction, tuint)
      :: (mario_actions_submerged._arg3, tint) :: nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_cwks_aid_m :
  mario_actions_submerged._animation <> mario_actions_airborne._m.
Proof. vm_compute. discriminate. Qed.
Example sub_cwks_eid_m :
  mario_actions_submerged._endAction <> mario_actions_airborne._m.
Proof. vm_compute. discriminate. Qed.
Example sub_cwks_harg_m :
  mario_actions_submerged._arg3 <> mario_actions_airborne._m.
Proof. vm_compute. discriminate. Qed.
Example sub_cwks_wa :
  mem_id mario_actions_submerged._endAction sub_cwks_wact = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_cwks_wm :
  mem_id mario_actions_airborne._m sub_cwks_wact = false.
Proof. vm_compute. reflexivity. Qed.
Example sub_cwks_wanim :
  mem_id mario_actions_submerged._animation sub_cwks_wact = false.
Proof. vm_compute. reflexivity. Qed.
Example sub_cwks_wharg :
  mem_id mario_actions_submerged._arg3 sub_cwks_wact = false.
Proof. vm_compute. reflexivity. Qed.
Example sub_cwks_cm :
  mem_id mario_actions_airborne._m sub_cwks_cact = false.
Proof. vm_compute. reflexivity. Qed.
Example sub_cwks_canim :
  mem_id mario_actions_submerged._animation sub_cwks_cact = false.
Proof. vm_compute. reflexivity. Qed.
Example sub_cwks_cend :
  mem_id mario_actions_submerged._endAction sub_cwks_cact = false.
Proof. vm_compute. reflexivity. Qed.
Example sub_cwks_charg :
  mem_id mario_actions_submerged._arg3 sub_cwks_cact = false.
Proof. vm_compute. reflexivity. Qed.
Example sub_cwks_walk :
  wwalk_chk false sub_cwks_wact sub_cwks_ids nil sub_cwks_cact nil sub_cwks_sids nil
    (fn_body mario_actions_submerged.f_common_water_knockback_step) = true.
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
  wwalk_chk' nil nil nil nil sub_walk_nids sub_walk_np3 false
    nil sub_walk_ids nil nil nil sub_sids nil
    (fn_body mario_actions_submerged.f_act_metal_water_walking) = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_mww_nonparam_n :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_submerged.f_act_metal_water_walking))))
    sub_walk_nids = true.
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
  wwalk_chk' nil nil nil nil sub_walk_nids sub_walk_np3 false
    nil sub_walk_ids nil nil nil sub_sids nil
    (fn_body mario_actions_submerged.f_act_hold_metal_water_walking) = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_hmww_nonparam_n :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_submerged.f_act_hold_metal_water_walking))))
    sub_walk_nids = true.
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
   nil, the only row is sub_kb_tids_rows (call_pres_act3 cwks = sub_cwks_row). ---- *)
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

(* ---- the cancel gate: body_pres_of_wwalk_cact (cact = the two heldObj
   chase temps); ids = transition_submerged_to_walking; xids = stop_shell_
   music; sids = set_mario_action. ---- *)
Example sub_ccsc_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._check_common_submerged_cancels
  = Some (Gfun (Internal mario_actions_submerged.f_check_common_submerged_cancels)).
Proof. vm_compute. reflexivity. Qed.
Example sub_ccsc_vars :
  fn_vars mario_actions_submerged.f_check_common_submerged_cancels = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_ccsc_pok :
  sub_hold_pok mario_actions_submerged.f_check_common_submerged_cancels = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_ccsc_nonparam :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_submerged.f_check_common_submerged_cancels))))
    sub_ccsc_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_ccsc_walk :
  wwalk_chk false nil sub_ccsc_ids nil sub_ccsc_cact sub_ccsc_xids sub_sids nil
    (fn_body mario_actions_submerged.f_check_common_submerged_cancels) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- throw: body_pres_of_wwalk_cact, cact = sub_wt_cact (the two
   marioBodyState chase temps for the headAngle approach_s32 store). ---- *)
Example sub_wt_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_water_throw
  = Some (Gfun (Internal mario_actions_submerged.f_act_water_throw)).
Proof. vm_compute. reflexivity. Qed.
Example sub_wt_vars :
  fn_vars mario_actions_submerged.f_act_water_throw = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_wt_pok :
  sub_hold_pok mario_actions_submerged.f_act_water_throw = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_wt_nonparam :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_submerged.f_act_water_throw))))
    sub_wt_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_wt_walk :
  wwalk_chk false nil sub_tp_ids nil sub_wt_cact sub_tp_xids sub_sids nil
    (fn_body mario_actions_submerged.f_act_water_throw) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- punch: same shared ids/xids, cact = sub_wp_cact (PER-LEAF; _t'5/_t'4
   here hold non-chase results, hence distinct temps from throw). ---- *)
Example sub_wp_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_water_punch
  = Some (Gfun (Internal mario_actions_submerged.f_act_water_punch)).
Proof. vm_compute. reflexivity. Qed.
Example sub_wp_vars :
  fn_vars mario_actions_submerged.f_act_water_punch = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_wp_pok :
  sub_hold_pok mario_actions_submerged.f_act_water_punch = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_wp_nonparam :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_submerged.f_act_water_punch))))
    sub_wp_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_wp_walk :
  wwalk_chk false nil sub_tp_ids nil sub_wp_cact sub_tp_xids sub_sids nil
    (fn_body mario_actions_submerged.f_act_water_punch) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE 14: the swimming cluster pins. ---- *)
(* breaststroke (cact = [_t'11], the marioObj for play_sound). *)
Example sub_bs_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_breaststroke
  = Some (Gfun (Internal mario_actions_submerged.f_act_breaststroke)).
Proof. vm_compute. reflexivity. Qed.
Example sub_bs_vars : fn_vars mario_actions_submerged.f_act_breaststroke = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_bs_pok : sub_hold_pok mario_actions_submerged.f_act_breaststroke = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_bs_nonparam :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_submerged.f_act_breaststroke))))
    swim_bs_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_bs_walk :
  wwalk_chk false nil swim_ids nil swim_bs_cact swim_xids sub_sids nil
    (fn_body mario_actions_submerged.f_act_breaststroke) = true.
Proof. vm_compute. reflexivity. Qed.

(* swimming_end (no cact). *)
Example sub_se_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_swimming_end
  = Some (Gfun (Internal mario_actions_submerged.f_act_swimming_end)).
Proof. vm_compute. reflexivity. Qed.
Example sub_se_vars : fn_vars mario_actions_submerged.f_act_swimming_end = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_se_pok : sub_hold_pok mario_actions_submerged.f_act_swimming_end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_se_walk :
  wwalk_chk false nil swim_ids nil nil swim_xids sub_sids nil
    (fn_body mario_actions_submerged.f_act_swimming_end) = true.
Proof. vm_compute. reflexivity. Qed.

(* flutter_kick (no cact; approach_f32 external). *)
Example sub_fk_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_flutter_kick
  = Some (Gfun (Internal mario_actions_submerged.f_act_flutter_kick)).
Proof. vm_compute. reflexivity. Qed.
Example sub_fk_vars : fn_vars mario_actions_submerged.f_act_flutter_kick = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_fk_pok : sub_hold_pok mario_actions_submerged.f_act_flutter_kick = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_fk_walk :
  wwalk_chk false nil swim_ids nil nil swim_xids sub_sids nil
    (fn_body mario_actions_submerged.f_act_flutter_kick) = true.
Proof. vm_compute. reflexivity. Qed.

(* hold_breaststroke (cact = [_t'22; _t'10]: rawData-flag load + play_sound). *)
Example sub_hbs_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_hold_breaststroke
  = Some (Gfun (Internal mario_actions_submerged.f_act_hold_breaststroke)).
Proof. vm_compute. reflexivity. Qed.
Example sub_hbs_vars : fn_vars mario_actions_submerged.f_act_hold_breaststroke = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_hbs_pok :
  sub_hold_pok mario_actions_submerged.f_act_hold_breaststroke = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_hbs_nonparam :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_submerged.f_act_hold_breaststroke))))
    swim_hbs_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_hbs_walk :
  wwalk_chk false nil swim_ids nil swim_hbs_cact swim_xids sub_sids nil
    (fn_body mario_actions_submerged.f_act_hold_breaststroke) = true.
Proof. vm_compute. reflexivity. Qed.

(* hold_swimming_end (cact = [_t'14]: rawData-flag load). *)
Example sub_hse_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_hold_swimming_end
  = Some (Gfun (Internal mario_actions_submerged.f_act_hold_swimming_end)).
Proof. vm_compute. reflexivity. Qed.
Example sub_hse_vars : fn_vars mario_actions_submerged.f_act_hold_swimming_end = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_hse_pok :
  sub_hold_pok mario_actions_submerged.f_act_hold_swimming_end = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_hse_nonparam :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_submerged.f_act_hold_swimming_end))))
    swim_hse_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_hse_walk :
  wwalk_chk false nil swim_ids nil swim_hse_cact swim_xids sub_sids nil
    (fn_body mario_actions_submerged.f_act_hold_swimming_end) = true.
Proof. vm_compute. reflexivity. Qed.

(* hold_flutter_kick (cact = [_t'10]: rawData-flag load; approach_f32). *)
Example sub_hfk_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_hold_flutter_kick
  = Some (Gfun (Internal mario_actions_submerged.f_act_hold_flutter_kick)).
Proof. vm_compute. reflexivity. Qed.
Example sub_hfk_vars : fn_vars mario_actions_submerged.f_act_hold_flutter_kick = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_hfk_pok :
  sub_hold_pok mario_actions_submerged.f_act_hold_flutter_kick = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_hfk_nonparam :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_submerged.f_act_hold_flutter_kick))))
    swim_hfk_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_hfk_walk :
  wwalk_chk false nil swim_ids nil swim_hfk_cact swim_xids sub_sids nil
    (fn_body mario_actions_submerged.f_act_hold_flutter_kick) = true.
Proof. vm_compute. reflexivity. Qed.

(* water_shell_swimming (cact = [_t'8; _t'6]: marioObj rawData-flag load +
   heldObj for the oInteractStatus chase store; also clears heldObj:=NULL). *)
Example sub_wss_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_water_shell_swimming
  = Some (Gfun (Internal mario_actions_submerged.f_act_water_shell_swimming)).
Proof. vm_compute. reflexivity. Qed.
Example sub_wss_vars :
  fn_vars mario_actions_submerged.f_act_water_shell_swimming = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_wss_pok :
  sub_hold_pok mario_actions_submerged.f_act_water_shell_swimming = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_wss_nonparam :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_submerged.f_act_water_shell_swimming))))
    swim_wss_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_wss_walk :
  wwalk_chk false nil swim_ids nil swim_wss_cact swim_xids sub_sids nil
    (fn_body mario_actions_submerged.f_act_water_shell_swimming) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE 15: the last two submerged leaves. ---- *)
(* water_plunge (cact = [_t'19 heldObj read; _t'14/_t'13 marioObj play_sound]). *)
Example sub_wpl_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_water_plunge
  = Some (Gfun (Internal mario_actions_submerged.f_act_water_plunge)).
Proof. vm_compute. reflexivity. Qed.
Example sub_wpl_vars : fn_vars mario_actions_submerged.f_act_water_plunge = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_wpl_pok : sub_hold_pok mario_actions_submerged.f_act_water_plunge = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_wpl_nonparam :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_submerged.f_act_water_plunge))))
    wp_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_wpl_walk :
  wwalk_chk false nil wp_ids nil wp_cact wp_xids sub_sids nil
    (fn_body mario_actions_submerged.f_act_water_plunge) = true.
Proof. vm_compute. reflexivity. Qed.

(* whirlpool (cact = [_marioObj; _whirlpool]). *)
Example sub_whp_pin :
  (prog_defmap mario_actions_submerged.prog)
    ! mario_actions_submerged._act_caught_in_whirlpool
  = Some (Gfun (Internal mario_actions_submerged.f_act_caught_in_whirlpool)).
Proof. vm_compute. reflexivity. Qed.
Example sub_whp_vars :
  fn_vars mario_actions_submerged.f_act_caught_in_whirlpool = nil.
Proof. vm_compute. reflexivity. Qed.
Example sub_whp_pok :
  sub_hold_pok mario_actions_submerged.f_act_caught_in_whirlpool = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_whp_nonparam :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_submerged.f_act_caught_in_whirlpool))))
    whirl_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example sub_whp_walk :
  wwalk_chk false nil whirl_ids nil whirl_cact whirl_xids nil nil
    (fn_body mario_actions_submerged.f_act_caught_in_whirlpool) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* Generic exec-derivation strippers (no section vars): peel a leading     *)
(* Sset off a sequence.  set_anim_to_frame is a CALL-FREE body whose only   *)
(* memory writes are scalar stores through an interior animInfo pointer     *)
(* aliasing the marioObj SafeB block -- a fixed-shape walk, so direct       *)
(* inversion is cleaner than the generic engine (whose chase tracking has   *)
(* no arm for the `animInfo = &marioObj->..->animInfo` Eaddrof set).        *)
(* ====================================================================== *)

Lemma exec_seq_sset : forall ge e le m i a s tr le' m' out,
  exec_stmt function_entry2 ge e le m (Ssequence (Sset i a) s) tr le' m' out ->
  exists v t2, eval_expr ge e le m a v /\
               exec_stmt function_entry2 ge e (PTree.set i v le) m s t2 le' m' out.
Proof.
  intros ge e le m i a s tr le' m' out H. inv H.
  - match goal with Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs end.
    eauto.
  - match goal with Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ ?o |- _ => inv Hs end.
    match goal with Hne : Out_normal <> Out_normal |- _ => exfalso; exact (Hne eq_refl) end.
Qed.

Lemma exec_seq_two_sset : forall ge e le m i1 a1 i2 a2 s tr le' m' out,
  exec_stmt function_entry2 ge e le m
    (Ssequence (Ssequence (Sset i1 a1) (Sset i2 a2)) s) tr le' m' out ->
  exists v1 v2 t2, eval_expr ge e le m a1 v1 /\
                   eval_expr ge e (PTree.set i1 v1 le) m a2 v2 /\
                   exec_stmt function_entry2 ge e
                     (PTree.set i2 v2 (PTree.set i1 v1 le)) m s t2 le' m' out.
Proof.
  intros ge e le m i1 a1 i2 a2 s tr le' m' out H. inv H.
  - match goal with
    | HA : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Sset _ _)) _ _ _ _ |- _ =>
        apply exec_seq_sset in HA; destruct HA as (v1 & ? & Hev1 & HA);
        inv HA
    end.
    eauto 8.
  - match goal with
    | HA : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Sset _ _)) _ _ _ ?o |- _ =>
        apply exec_seq_sset in HA; destruct HA as (? & ? & ? & HA);
        inv HA
    end.
    match goal with Hne : Out_normal <> Out_normal |- _ => exfalso; exact (Hne eq_refl) end.
Qed.

(* An Eaddrof evaluates to a pointer at the lvalue's location, WITHOUT
   substituting the result variable away (unlike a bare [inv]). *)
Lemma eval_Eaddrof_inv : forall ge e le m a ty v,
  eval_expr ge e le m (Eaddrof a ty) v ->
  exists loc ofs, eval_lvalue ge e le m a loc ofs Full /\ v = Vptr loc ofs.
Proof.
  intros ge e le m a ty v H. inv H.
  - eauto.
  - match goal with Hlv : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hlv end.
Qed.

(* ====================================================================== *)
(* The section: the leaf-callee discharge, keyed by the census.           *)
(* ====================================================================== *)

Section SubmergedLeafRows.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_mario_step : linkorder mario_step.prog lp.
  Hypothesis LO_sub : linkorder mario_actions_submerged.prog lp.
  (* interaction.prog linkorder -- needed to REUSE ObjectLeafSurface.mtho_row
     (mario_throw_held_object is Internal in interaction.prog).  Discharged at
     the capstone by the EXISTING interaction linkorder (the same LO_int the
     dasma_row arg already threads) -- a proved linkorder, NOT a residual. *)
  Hypothesis LO_int : linkorder interaction.prog lp.

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

  (* stop_and_set_height_to_floor needs NO hypothesis -- DISCHARGED in-surface
     (sub_sashf_row, the SAME walk as AutomaticLeafSurface.Hsasthf): it writes
     m->pos[1]/m->vel[1]/forwardVel (window) and copies into marioObj's gfx
     pos/angle through the chased marioObj pointer (a NON-bm SafeB pool block,
     action cell untouched).  ids=[mario_set_forward_vel] (sub_msfv_row);
     xids=[vec3f_copy; vec3s_set] ride the EXISTING obj_ext boundary
     (Hcpx_v3fc/Hcpx_v3ss the whirlpool slice already assumes) -- NO new trust. *)

  (* play_metal_water_jumping_sound is DISCHARGED below (sub_pmwjs_row): window
     store + sole call play_sound_if_no_flag (sub_psinf_row) -- NO hyp needed. *)

  (* perform_air_step: the air step (writes pos/vel, returns the step result;
     the CALLER dispatches the result to set the action), so a genuine
     call_pres.  ALREADY PROVED (PerformAirStepSurface.pas_cp) -- the capstone
     feeds its existing Hcp_pas Lemma, NO new trust. *)
  Hypothesis Hcp_pas :
    call_pres lp bm NoA MWF mario_step._perform_air_step.
  (* update_metal_water_jump_speed is DISCHARGED below (sub_umwjs_row): window
     stores + xids=[approach_f32] (Hcpx_af32, obj_ext) -- NO hyp needed. *)

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
     anim id / accel scalar args; NEVER the action cell.  DISCHARGED below as
     call_pres_np3 (sub_smawa_row, reusing MovingLeafSurface.mov_smawa_row) and
     threaded through the smawa-calling leaves via the np3 channel -- NO hyp. *)

  (* play_metal_water_walking_sound is DISCHARGED below (sub_pmwws_row): window
     store + ids=[is_anim_past_frame] (sub_iapf_row) + xids=[play_sound]
     (obj_ext) -- NO hyp needed. *)

  (* update_metal_water_walking_speed is DISCHARGED below (sub_umwws_row): window
     stores + xids=[approach_s32] (Hcpx_approach, obj_ext) + m->floor chase read
     -- NO hyp needed. *)

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

  (* stationary_slow_down: the water decel helper (window stores from
     approach_f32/approach_s32 + get_buoyancy + coss/sins).  DISCHARGED below
     (sub_ssd_row): ids=[get_buoyancy] (sub_gb_row), xids=[approach_f32,
     approach_s32] (obj_ext) -- NO hypothesis needed. *)

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

  (* play_sound_if_no_flag (the flag-gated sound helper, mario.prog) is
     DISCHARGED below (sub_psinf_row): window store m->flags + lone call
     play_sound (obj_ext) -- NO hypothesis needed. *)

  (* act_water_shocked's two terminal externals -- both obj_ext_ids members,
     the same audio/camera-shake model-boundary class as play_sound's row
     (discharged at the capstone via Hpres_obj_ext, NO new trust). *)
  Hypothesis Hcpx_psound : call_pres_ext lp bm NoA MWF mario._play_sound.
  Hypothesis Hcpx_scshf :
    call_pres_ext lp bm NoA MWF interaction._set_camera_shake_from_hit.

  (* the knockback step helper: action-preserving WHEN its endAction (param
     index 2 = the THIRD vargs element) is untainted.  Exactly call_pres_act3.
     DISCHARGED below (sub_cwks_row): walk its body via call_pres_act3_of_wwalk_p4
     threading the untainted endAction param into the action store
     (set_mario_action(m, health>=0x100 ? endAction : ACT_WATER_DEATH, 0));
     the only callees are the already-discharged ssd/sma/iae rows + the
     perform_water_step residual (Hcp_pws) + set_mario_action (Hsmact).  NO hyp. *)

  (* SLICE 12 (cancel gate): transition_submerged_to_walking is an honest
     INTERNAL residual (f_transition_submerged_to_walking in mario.prog;
     it transitions Mario to a walking action -- dischargeable by walking
     its body later).  stop_shell_music is the nullary AUDIO external
     (reuses the obj_ext boundary at the capstone -- NO new trust). *)
  (* transition_submerged_to_walking is DISCHARGED below (sub_tstw_row via the
     ws hybrid walker): set_camera_mode (xids/obj_ext), vec3s_set(m->angleVel)
     (the ws/w1 window site), set_mario_action (keystone).  NO hyp. *)
  Hypothesis Hcpx_ssm :
    call_pres_ext lp bm NoA MWF interaction._stop_shell_music.

  (* SLICE 13 (throw/punch pair): the four swimming helpers + the throw/grab
     helpers are honest INTERNAL residuals (all internal in mario_actions_
     submerged.prog / interaction.prog, dischargeable by walking their bodies
     later).  None writes the action cell directly (they update swimming yaw/
     pitch/speed/face physics + grab/throw the held object). *)
  (* update_swimming_yaw + update_swimming_pitch are DISCHARGED outright below
     (sub_usy_row / sub_usp_row via call_pres_of_wwalk): pure window stores into
     Mario's own faceAngle/angleVel, the only call (approach_s32, yaw only) rides
     the obj_ext boundary -- NO hypothesis needed. *)
  (* update_swimming_speed is DISCHARGED below (sub_uss_row): window stores +
     get_buoyancy (sub_gb_row, whose sole call swimming_near_surface is sns_cp)
     -- NO hypothesis needed. *)
  (* update_water_pitch is DISCHARGED below (sub_uwp_row): chase stores through
     m->marioObj, no calls -- NO hypothesis needed. *)
  (* mario_throw_held_object needs NO hypothesis -- DISCHARGED in-surface
     (sub_mtho_row) by REUSING ObjectLeafSurface.mtho_row (it is the SAME
     interaction.prog body the object/stationary/airborne families already
     walk).  Its 3 terminal externals (segmented_to_virtual / stop_shell_music
     / obj_set_held_state) ride the obj_ext boundary -- NO new trust. *)
  Hypothesis Hcp_cwg :
    call_pres lp bm NoA MWF mario_actions_submerged._check_water_grab.
  (* the throw/punch terminal externals -- all obj_ext_ids members (the
     pure-math approach_s32, the behaviour-segment reader segmented_to_virtual,
     the audio play_shell_music) -> discharged at the capstone via Hpres_obj_ext,
     NO new trust. *)
  Hypothesis Hcpx_approach :
    call_pres_ext lp bm NoA MWF mario_actions_object._approach_s32.
  Hypothesis Hcpx_s2v :
    call_pres_ext lp bm NoA MWF interaction._segmented_to_virtual.
  Hypothesis Hcpx_psm :
    call_pres_ext lp bm NoA MWF interaction._play_shell_music.
  (* obj_set_held_state: the 3rd terminal external of mario_throw_held_object
     (obj_ext_ids member -> capstone discharges via Hpres_obj_ext, the SAME
     term the dasma_row arg already passes) -- NO new trust. *)
  Hypothesis Hcpx_oshs :
    call_pres_ext lp bm NoA MWF interaction._obj_set_held_state.

  (* SLICE 14 (the swimming cluster): the swim helpers are honest INTERNAL
     residuals (check_water_jump / play_swimming_noise / reset_bob_variables /
     common_swimming_step are internal in mario_actions_submerged.prog,
     set_anim_to_frame is internal in mario.prog) -- dischargeable by walking
     their bodies later.  NONE writes the action cell (the leaves dispatch
     set_mario_action / drop_and_set_mario_action themselves via sub_sids; the
     helpers update swim physics / bob variables / animation frames).
     approach_f32 is the ONE new terminal external -- the pure-math float
     approach builtin (EF_external in every TU, the honest model boundary). *)
  (* check_water_jump is DISCHARGED below (sub_cwj_row via the ws hybrid
     walker): vec3s_set(m->angleVel) (the ws/w1 window site), m->vel[1]=62
     (window store), set_mario_action (keystone).  The A-gated inner block
     (input & INPUT_A_PRESSED) is walked too -- it never escapes the action
     cell.  NO hyp. *)
  (* set_anim_to_frame is DISCHARGED below (sub_satf_row): bespoke walk of its
     body (fn_vars=nil, no calls).  It chases m->marioObj to a SafeB block,
     forms &animInfo (same block), and the 4 scalar stores all go THROUGH that
     chased animInfo pointer -- never the action cell.  NO hypothesis needed. *)
  (* play_swimming_noise is DISCHARGED below (sub_psn_row): no stores, lone call
     play_sound (obj_ext) -- NO hypothesis needed. *)
  (* reset_bob_variables is DISCHARGED below (sub_rbv_row): three direct
     static-global stores (sBobTimer/sBobIncrement/sBobHeight, all in
     stored_globals) -- NO hypothesis needed. *)
  Hypothesis Hcp_css :
    call_pres lp bm NoA MWF mario_actions_submerged._common_swimming_step.
  Hypothesis Hcpx_af32 :
    call_pres_ext lp bm NoA MWF mario_actions_submerged._approach_f32.

  (* SLICE 15 (the last two leaves): swimming_near_surface is the ONE honest
     INTERNAL residual (internal in mario_actions_submerged.prog, a pure read of
     m->pos[1]/waterLevel returning a flag -- dischargeable by walking it later).
     The four whirlpool externals (sqrtf / atan2s / vec3f_copy / vec3s_set) are
     obj_ext_ids members, discharged zero-trust via Hpres_obj_ext at the
     capstone.  level_trigger_warp reuses the SHARED Hcp_ltw; set_mario_action /
     play_sound / set_mario_animation reuse the keystone / obj_ext / sub_sma_row. *)
  (* swimming_near_surface is a PURE read-only body: it loads m->flags,
     m->waterLevel, m->pos[1] and returns a bool -- no stores, no calls.
     So we DISCHARGE its call_pres outright via the pure_walk tool (no
     hypothesis needed): the whole funcall returns the same memory, so every
     carried run fact is its own proof. *)
  Lemma sns_pin :
    (prog_defmap mario_actions_submerged.prog)
      ! mario_actions_submerged._swimming_near_surface
    = Some (Gfun (Internal mario_actions_submerged.f_swimming_near_surface)).
  Proof. vm_compute. reflexivity. Qed.

  Lemma sns_chk_body :
    pure_chk (fn_body mario_actions_submerged.f_swimming_near_surface) = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma sns_body_pres :
    body_pres lp NoA MWF bm mario_actions_submerged.f_swimming_near_surface.
  Proof.
    intros m0 vargs0 t0 mF vres0 Hgate Hevf HN HM HV HS.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rename Ha into Halloc end.
    unfold mario_actions_submerged.f_swimming_near_surface in Halloc.
    cbn [fn_vars] in Halloc.
    inv Halloc.
    pose proof (pure_walk _ _ _ _ _ _ _ _ _ Hbody sns_chk_body) as Em.
    subst m1.
    assert (Hben : blocks_of_env (lp_ge lp) empty_env = nil) by reflexivity.
    rewrite Hben in Hfree. cbn [Mem.free_list] in Hfree.
    injection Hfree as <-.
    exact (conj HV (conj HS HM)).
  Qed.

  Lemma sns_cp :
    call_pres lp bm NoA MWF mario_actions_submerged._swimming_near_surface.
  Proof.
    exact (call_pres_of_body lp bm NoA MWF HNoA_of_MWF mario_actions_submerged.prog
             mario_actions_submerged._swimming_near_surface
             mario_actions_submerged.f_swimming_near_surface
             LO_sub sns_pin sns_body_pres).
  Qed.

  Hypothesis Hcpx_sqrtf :
    call_pres_ext lp bm NoA MWF mario_actions_submerged._sqrtf.
  Hypothesis Hcpx_atan2s :
    call_pres_ext lp bm NoA MWF mario_actions_submerged._atan2s.
  Hypothesis Hcpx_v3fc :
    call_pres_ext lp bm NoA MWF mario_actions_submerged._vec3f_copy.
  Hypothesis Hcpx_v3ss :
    call_pres_ext lp bm NoA MWF mario_actions_submerged._vec3s_set.

  (* the keystone, instantiated once: set_mario_action is call_pres_act. *)
  Let Hsmact : call_pres_act lp bm NoA MWF mario._set_mario_action :=
    smact_pres lp LO_mario LO_mario_step bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe.

  (* ==================================================================== *)
  (* THE angleVel-WINDOW (ws) ARC.  vec3s_set(m->angleVel, 0,0,0) writes   *)
  (* three shorts (6 bytes) at offset 50 of bm; the action cell @12 is     *)
  (* clear -- store_window_ok 50 12 = true (the 6-byte write sits strictly  *)
  (* INSIDE a 12-byte-safe window, so the EXISTING w1 dst-window external   *)
  (* residual / brick apply verbatim, exactly as for vec3f_set(m->vel)).    *)
  (* Two submerged helpers call it (transition_submerged_to_walking,        *)
  (* check_water_jump); the rest of each body the wwalk engine handles      *)
  (* (set_camera_mode = xids/obj_ext, set_mario_action = sids keystone,     *)
  (* m->vel[1]=62 = window store, field reads, branches).  A HYBRID walker  *)
  (* (engine generic arm || the vec3s_set special site), mirror of the      *)
  (* riding_hoot rh walker.                                                 *)
  (* ==================================================================== *)

  (* the NEW model-boundary residual + the consumed obj_ext external *)
  Hypothesis Hcpx_scm :
    call_pres_ext lp bm NoA MWF mario._set_camera_mode.
  Hypothesis Hw1cp_v3sset :
    OutParamSurface.call_pres_ext_w1 lp bm NoA MWF mario._vec3s_set.

  (* ---- recognizers ---- *)
  Definition ws_dst (a : expr) : bool :=
    match a with
    | Efield (Ederef (Etempvar p pty) sty) fld faty =>
        Pos.eqb p mario._m
        && proj_sumbool (type_eq pty (tptr (Tstruct mario._MarioState noattr)))
        && proj_sumbool (type_eq sty (Tstruct mario._MarioState noattr))
        && Pos.eqb fld mario._angleVel
        && proj_sumbool (type_eq faty (tarray tshort 3))
    | _ => false
    end.
  Definition ws_site_chk (s : statement) : bool :=
    match s with
    | Scall None (Evar fid fty) al =>
        Pos.eqb fid mario._vec3s_set
        && proj_sumbool
             (type_eq fty
                (Tfunction (tptr tshort :: tshort :: tshort :: tshort :: nil)
                   (tptr tvoid) cc_default))
        && match al with
           | a0 :: _ :: _ :: _ :: nil => ws_dst a0
           | _ => false
           end
    | _ => false
    end.

  Definition swk_xids : list ident := mario._set_camera_mode :: nil.
  Definition swk_sids : list ident := mario._set_mario_action :: nil.

  Definition swk_gen (s : statement) : bool :=
    wwalk_chk' nil nil nil nil nil nil false nil nil nil nil
      swk_xids swk_sids nil s.

  Fixpoint swk_chk (s : statement) : bool :=
    swk_gen s
    || match s with
       | Ssequence s1 s2 => swk_chk s1 && swk_chk s2
       | Sifthenelse _ s1 s2 => swk_chk s1 && swk_chk s2
       | Sswitch _ ls => swk_chk_ls ls
       | _ => ws_site_chk s
       end
  with swk_chk_ls (ls : labeled_statements) : bool :=
    match ls with
    | LSnil => true
    | LScons _ s rest => swk_chk s && swk_chk_ls rest
    end.

  (* ---- switch-selection transfer ---- *)
  Lemma swk_chk_ls_seq : forall sl,
      swk_chk_ls sl = true ->
      swk_chk (seq_of_labeled_statement sl) = true.
  Proof.
    induction sl as [| o s sl0 IH]; intros H.
    - reflexivity.
    - cbn in H. apply andb_prop in H as [H1 H2].
      cbn [seq_of_labeled_statement swk_chk].
      apply orb_true_iff. right.
      rewrite H1, (IH H2). reflexivity.
  Qed.
  Lemma swk_chk_ls_case : forall n sl sl',
      swk_chk_ls sl = true ->
      select_switch_case n sl = Some sl' ->
      swk_chk_ls sl' = true.
  Proof.
    intros n sl; induction sl as [| o s sl0 IH]; intros sl' H Hsel.
    - discriminate Hsel.
    - cbn in H. apply andb_prop in H as [H1 H2].
      destruct o as [c|]; cbn in Hsel.
      + destruct (zeq c n).
        * injection Hsel as <-. cbn. rewrite H1, H2. reflexivity.
        * exact (IH sl' H2 Hsel).
      + exact (IH sl' H2 Hsel).
  Qed.
  Lemma swk_chk_ls_default : forall sl,
      swk_chk_ls sl = true ->
      swk_chk_ls (select_switch_default sl) = true.
  Proof.
    induction sl as [| o s sl0 IH]; intros H.
    - exact H.
    - cbn in H. apply andb_prop in H as [H1 H2].
      destruct o as [c|]; cbn.
      + exact (IH H2).
      + rewrite H1, H2. reflexivity.
  Qed.
  Lemma swk_chk_select : forall n sl,
      swk_chk_ls sl = true ->
      swk_chk (seq_of_labeled_statement (select_switch n sl)) = true.
  Proof.
    intros n sl H. apply swk_chk_ls_seq.
    unfold select_switch.
    destruct (select_switch_case n sl) eqn:E.
    - exact (swk_chk_ls_case _ _ _ H E).
    - exact (swk_chk_ls_default _ H).
  Qed.

  (* ---- the vec3s_set site decode ---- *)
  Lemma ws_site_shape :
    forall optid a al,
      ws_site_chk (Scall optid a al) = true ->
      optid = None /\
      a = Evar mario._vec3s_set
            (Tfunction (tptr tshort :: tshort :: tshort :: tshort :: nil)
               (tptr tvoid) cc_default) /\
      exists a1 a2 a3,
        al = Efield (Ederef (Etempvar mario._m
                               (tptr (Tstruct mario._MarioState noattr)))
                       (Tstruct mario._MarioState noattr))
               mario._angleVel (tarray tshort 3)
             :: a1 :: a2 :: a3 :: nil.
  Proof.
    intros optid a al H.
    destruct optid as [t'|]; [ discriminate H | ].
    split; [ reflexivity | ].
    destruct a as [ | | | | cid ftyv | | | | | | | | | ]; try discriminate H.
    unfold ws_site_chk in H.
    apply andb_prop in H as [H Hal].
    apply andb_prop in H as [Hfid Hfty].
    apply Pos.eqb_eq in Hfid. subst cid.
    destruct (type_eq ftyv (Tfunction (tptr tshort :: tshort :: tshort
                                       :: tshort :: nil) (tptr tvoid)
                              cc_default));
      [ subst ftyv | discriminate Hfty ].
    split; [ reflexivity | ].
    destruct al as [|a0 [|a1 [|a2 [|a3 [|a4 al']]]]]; try discriminate Hal.
    unfold ws_dst in Hal.
    destruct a0 as [ | | | | | | | | | | | e0 fld faty | | ];
      try discriminate Hal.
    destruct e0 as [ | | | | | | e1 sty | | | | | | | ];
      try discriminate Hal.
    destruct e1 as [ | | | | | p pty | | | | | | | | ];
      try discriminate Hal.
    apply andb_prop in Hal as [Hal Hfaty].
    apply andb_prop in Hal as [Hal Hfld].
    apply andb_prop in Hal as [Hal Hsty].
    apply andb_prop in Hal as [Hp Hpty].
    apply Pos.eqb_eq in Hp. subst p.
    apply Pos.eqb_eq in Hfld. subst fld.
    destruct (type_eq pty (tptr (Tstruct mario._MarioState noattr)));
      [ subst pty | discriminate Hpty ].
    destruct (type_eq sty (Tstruct mario._MarioState noattr));
      [ subst sty | discriminate Hsty ].
    destruct (type_eq faty (tarray tshort 3));
      [ subst faty | discriminate Hfaty ].
    exists a1, a2, a3. reflexivity.
  Qed.

  (* ---- angleVel window-value helper (mirror of rh_vel_window_val) ---- *)
  Lemma ws_angleVel_window_val :
    forall e le m v,
      (forall b o, le ! mario._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      eval_expr (lp_ge lp) e le m
        (Efield
           (Ederef (Etempvar mario._m (tptr (Tstruct mario._MarioState noattr)))
              (Tstruct mario._MarioState noattr))
           mario._angleVel (tarray tshort 3)) v ->
      exists o, v = Vptr bm o /\ store_window_ok (Ptrofs.unsigned o) 12 = true.
  Proof.
    intros e le m v Htat Hev.
    assert (Hfo : field_offset (prog_comp_env mario.prog)
                    mario._angleVel mario_state_members = OK (50, Full))
      by (vm_compute; reflexivity).
    assert (Hwin : store_window_ok 50 12 = true) by (vm_compute; reflexivity).
    inv Hev.
    match goal with
    | Hd : deref_loc (typeof _) _ _ _ _ _ |- _ => cbn [typeof] in Hd
    end.
    match goal with
    | Hd : deref_loc (tarray tshort 3) _ _ _ _ _ |- _ =>
        inv Hd;
        try (match goal with Hacc : access_mode (tarray tshort 3) = _ |- _ =>
               cbn in Hacc; discriminate Hacc end);
        try (match goal with Hlb : load_bitfield (tarray tshort 3) _ _ _ _ _ _ _ |- _ =>
               inv Hlb end)
    end.
    match goal with
    | Hflv : eval_lvalue _ _ _ _ (Efield _ _ _) ?lf ?of ?bff |- _ =>
        pose proof Hflv as Hpin;
        apply RealFrameValue.eval_lvalue_Efield_base in Hpin;
        destruct Hpin as (oo0 & Hbase);
        apply RealFrameValue.eval_expr_Ederef_load in Hbase;
        destruct Hbase as (lb & ob & bfb & Hlvb & _);
        apply RealFrameValue.eval_lvalue_Ederef_base in Hlvb;
        apply RealFrameValue.eval_expr_Etempvar_val in Hlvb;
        destruct (Htat _ _ Hlvb) as [E1 E2]; subst lb ob;
        destruct (mfield_lvalue_geom_lp lp LO_mario _ _ _ _ _ _
                    lf of bff _ _ _ Hlvb Hfo Hflv) as (E3 & E4 & _);
        subst lf of
    end.
    eexists. split; [ reflexivity | ].
    rewrite Ptrofs.add_zero_l.
    rewrite Ptrofs.unsigned_repr by (vm_compute; split; discriminate).
    exact Hwin.
  Qed.

  (* ---- census rows ---- *)
  Lemma swk_xids_rows :
    forall fid, mem_id fid swk_xids = true -> call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold swk_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_scm | ].
    discriminate H.
  Qed.
  Lemma swk_sids_rows :
    forall fid, mem_id fid swk_sids = true -> call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold swk_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.

  (* ---- the generic-subtree discharger: ONE wwalk_pres call ---- *)
  Lemma swk_generic :
    forall s e le m0 tr le' m' out,
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g swk_xids = true -> e ! g = None) ->
      (forall g, mem_id g swk_sids = true -> e ! g = None) ->
      e ! interaction._gGlobalTimer = None ->
      swk_gen s = true ->
      (forall b o, le ! mario._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      act_inv nil le ->
      chase_inv SafeB nil le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      NoA m' /\
      (forall b o, le' ! mario._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) /\
      act_inv nil le' /\ chase_inv SafeB nil le'.
  Proof.
    intros s e le m0 tr le' m' out Hub_g Hub_x Hub_s Hubgt
           Hchk Htat Hact Hch HN HM HV HS Hexec.
    unfold swk_gen in Hchk.
    destruct (wwalk_pres lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false nil nil nil nil swk_xids swk_sids nil
                nil nil nil nil nil nil
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                swk_xids_rows
                swk_sids_rows
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                _ _ _ _ _ _ _ _
                (fun Hne => match Hne eq_refl with end)
                (fun lid HH => match Bool.diff_false_true HH with end)
                Hexec
                Hub_g
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                Hub_x
                Hub_s
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                Hubgt
                Hchk Htat Hact Hch
                (fun t HH => match Bool.diff_false_true HH with end)
                HN HM HV HS)
      as (HV' & HS' & HM' & HN' & Htat' & Hact' & Hch' & _ & _).
    exact (conj HV' (conj HS' (conj HM' (conj HN'
             (conj Htat' (conj Hact' Hch')))))).
  Qed.

  (* ---- the hybrid walk prover ---- *)
  Lemma swk_pres :
    forall s e le m0 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g swk_xids = true -> e ! g = None) ->
      (forall g, mem_id g swk_sids = true -> e ! g = None) ->
      e ! mario._vec3s_set = None ->
      e ! interaction._gGlobalTimer = None ->
      swk_chk s = true ->
      (forall b o, le ! mario._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      act_inv nil le ->
      chase_inv SafeB nil le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      NoA m' /\
      (forall b o, le' ! mario._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) /\
      act_inv nil le' /\ chase_inv SafeB nil le'.
  Proof.
    intros s e le m0 tr le' m' out Hexec.
    induction Hexec;
      intros Hub_g Hub_x Hub_s Hv3ss Hubgt
             Hchk Htat Hact Hch HN HM HV HS.
    - (* Sskip *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sassign: generic only *)
      cbn [swk_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [ws_site_chk] in Hsp; discriminate Hsp ].
      eapply (swk_generic _ _ _ _ _ _ _ _ Hub_g Hub_x Hub_s Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sassign; eauto.
    - (* Sset: generic only *)
      cbn [swk_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [ws_site_chk] in Hsp; discriminate Hsp ].
      eapply (swk_generic _ _ _ _ _ _ _ _ Hub_g Hub_x Hub_s Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sset; eauto.
    - (* Scall: generic censured arm, or the vec3s_set ws site *)
      cbn [swk_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (swk_generic _ _ _ _ _ _ _ _ Hub_g Hub_x Hub_s Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Scall; eauto. }
      destruct (ws_site_shape _ _ _ Hsp)
        as [-> [-> (a1 & a2 & a3 & ->)]].
      cbn [set_opttemp].
      assert (Hc0 : LocalVarsSurface.carried bm NoA MWF m)
        by (split; [ exact HV | split; [ exact HS
                   | split; [ exact HM | exact HN ] ] ]).
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Scall None
                         (Evar mario._vec3s_set
                            (Tfunction (tptr tshort :: tshort :: tshort
                                        :: tshort :: nil) (tptr tvoid)
                               cc_default))
                         (Efield (Ederef (Etempvar mario._m
                                            (tptr (Tstruct mario._MarioState
                                                     noattr)))
                                    (Tstruct mario._MarioState noattr))
                            mario._angleVel (tarray tshort 3)
                          :: a1 :: a2 :: a3 :: nil))
                      t (set_opttemp None vres le) m' Out_normal)
        by (eapply exec_Scall; eauto).
      assert (Hgate : forall vargs1,
          eval_exprlist (lp_ge lp) e le m
            (Efield (Ederef (Etempvar mario._m
                               (tptr (Tstruct mario._MarioState noattr)))
                       (Tstruct mario._MarioState noattr))
               mario._angleVel (tarray tshort 3)
             :: a1 :: a2 :: a3 :: nil)
            (tptr tshort :: tshort :: tshort :: tshort :: nil) vargs1 ->
          OutParamSurface.arg0_window bm vargs1).
      { intros vargs1 Hvl.
        inversion Hvl as [ | x1 bl1 ty1 tyl1 v1a v2a vl1 Hev_a Hsc_a Htl1 ];
          subst; clear Hvl.
        destruct (ws_angleVel_window_val _ _ _ _ Htat Hev_a) as (o0 & Ev0 & Hwin0).
        subst v1a. cbn in Hsc_a. injection Hsc_a as <-.
        red. exists o0, vl1. split; [ reflexivity | exact Hwin0 ]. }
      destruct (OutParamSurface.w1_scall_pres lp bm NoA MWF None
                  mario._vec3s_set
                  (tptr tshort :: tshort :: tshort :: tshort :: nil)
                  (tptr tvoid) cc_default
                  (Efield (Ederef (Etempvar mario._m
                                     (tptr (Tstruct mario._MarioState noattr)))
                             (Tstruct mario._MarioState noattr))
                     mario._angleVel (tarray tshort 3)
                   :: a1 :: a2 :: a3 :: nil)
                  e le m _ _ m' _
                  Hv3ss Hw1cp_v3sset Hgate Hex Hc0) as (Hc' & _).
      destruct Hc' as (HV' & HS' & HM' & HN').
      exact (conj HV' (conj HS' (conj HM' (conj HN'
               (conj Htat (conj Hact Hch)))))).
    - (* Sbuiltin: rejected by BOTH arms *)
      cbn [swk_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ unfold swk_gen in Hg; cbn [wwalk_chk'] in Hg; discriminate Hg
        | cbn [ws_site_chk] in Hsp; discriminate Hsp ].
    - (* Sseq_1 *)
      cbn [swk_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hand].
      { eapply (swk_generic _ _ _ _ _ _ _ _ Hub_g Hub_x Hub_s Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sseq_1; eauto. }
      apply andb_prop in Hand as [H1 H2].
      destruct (IHHexec1 Hub_g Hub_x Hub_s Hv3ss Hubgt H1
                  Htat Hact Hch HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & Hch1).
      exact (IHHexec2 Hub_g Hub_x Hub_s Hv3ss Hubgt H2
               Htat1 Hact1 Hch1 HN1 HM1 HV1 HS1).
    - (* Sseq_2 *)
      cbn [swk_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hand].
      { eapply (swk_generic _ _ _ _ _ _ _ _ Hub_g Hub_x Hub_s Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sseq_2; eauto. }
      apply andb_prop in Hand as [H1 _].
      exact (IHHexec Hub_g Hub_x Hub_s Hv3ss Hubgt H1
               Htat Hact Hch HN HM HV HS).
    - (* Sifthenelse *)
      cbn [swk_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (swk_generic _ _ _ _ _ _ _ _ Hub_g Hub_x Hub_s Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sifthenelse; eauto. }
      apply andb_prop in Hsp as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sreturn (Some a) *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sbreak *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Scontinue *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sloop stop1: generic only *)
      cbn [swk_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [ws_site_chk] in Hsp; discriminate Hsp ].
      eapply (swk_generic _ _ _ _ _ _ _ _ Hub_g Hub_x Hub_s Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_stop1; eauto.
    - (* Sloop stop2: generic only *)
      cbn [swk_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [ws_site_chk] in Hsp; discriminate Hsp ].
      eapply (swk_generic _ _ _ _ _ _ _ _ Hub_g Hub_x Hub_s Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_stop2; eauto.
    - (* Sloop loop: generic only *)
      cbn [swk_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [ws_site_chk] in Hsp; discriminate Hsp ].
      eapply (swk_generic _ _ _ _ _ _ _ _ Hub_g Hub_x Hub_s Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_loop; eauto.
    - (* Sswitch *)
      cbn [swk_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hls].
      { eapply (swk_generic _ _ _ _ _ _ _ _ Hub_g Hub_x Hub_s Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sswitch; eauto. }
      exact (IHHexec Hub_g Hub_x Hub_s Hv3ss Hubgt
               (swk_chk_select _ _ Hls) Htat Hact Hch HN HM HV HS).
  Qed.

  (* ---- the two helper rows ---- *)
  Lemma tstw_pin :
    (prog_defmap mario.prog) ! mario._transition_submerged_to_walking
    = Some (Gfun (Internal mario.f_transition_submerged_to_walking)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma cwj_pin :
    (prog_defmap mario_actions_submerged.prog)
      ! mario_actions_submerged._check_water_jump
    = Some (Gfun (Internal mario_actions_submerged.f_check_water_jump)).
  Proof. vm_compute. reflexivity. Qed.

  Lemma swk_walk_tstw :
    swk_chk (fn_body mario.f_transition_submerged_to_walking) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma swk_walk_cwj :
    swk_chk (fn_body mario_actions_submerged.f_check_water_jump) = true.
  Proof. vm_compute. reflexivity. Qed.

  (* the fn_vars=nil, single-(_m)-param entry wrapper, over any such f. *)
  Lemma swk_body_of :
    forall (f : Clight.function),
      fn_vars f = nil ->
      fn_params f =
        (mario._m, tptr (Tstruct mario._MarioState noattr)) :: nil ->
      swk_chk (fn_body f) = true ->
      body_pres lp NoA MWF bm f.
  Proof.
    intros f Hvars Hpar Hwalk m0 vargs0 t0 mF vres0 Hmargf Hevf HN HM HV HS.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rename Ha into Halloc end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    rewrite Hvars in Halloc. inv Halloc.
    rewrite Hpar in Hbind.
    assert (Hmarg : marg_ok bm vargs0)
      by (apply Hmargf; unfold marg_exempt; rewrite Hpar; reflexivity).
    destruct vargs0 as [| v0 [| v1 vr']];
      cbn [bind_parameter_temps] in Hbind;
      [ discriminate Hbind | | discriminate Hbind ].
    injection Hbind as Heqle.
    match type of Heqle with _ = ?L => subst L end.
    assert (Htat0 : forall b o,
               (PTree.set mario._m v0 (create_undef_temps (fn_temps f))) ! mario._m
                 = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg.
      injection Hg as ->. cbn in Hmarg; exact Hmarg. }
    assert (Hact0 : act_inv nil
               (PTree.set mario._m v0 (create_undef_temps (fn_temps f))))
      by (intros t' Hmem' x Hg'; discriminate Hmem').
    assert (Hch0 : chase_inv SafeB nil
               (PTree.set mario._m v0 (create_undef_temps (fn_temps f))))
      by (intros t' Hmem' b o Hg'; discriminate Hmem').
    destruct (swk_pres _ _ _ _ _ _ _ _ Hbody
                (fun g _ => PTree.gempty _ g)
                (fun g _ => PTree.gempty _ g)
                (fun g _ => PTree.gempty _ g)
                (PTree.gempty _ _) (PTree.gempty _ _)
                Hwalk Htat0 Hact0 Hch0 HN HM HV HS)
      as (HVb & HSb & HMb & HNb & _ & _ & _).
    assert (Hben : blocks_of_env (lp_ge lp) empty_env = nil) by reflexivity.
    rewrite Hben in Hfree. cbn [Mem.free_list] in Hfree.
    injection Hfree as <-.
    exact (conj HVb (conj HSb HMb)).
  Qed.

  Lemma sub_tstw_row :
    call_pres lp bm NoA MWF mario._transition_submerged_to_walking.
  Proof.
    exact (call_pres_of_body lp bm NoA MWF HNoA_of_MWF mario.prog
             mario._transition_submerged_to_walking
             mario.f_transition_submerged_to_walking
             LO_mario tstw_pin
             (swk_body_of mario.f_transition_submerged_to_walking
                eq_refl eq_refl swk_walk_tstw)).
  Qed.
  Lemma sub_cwj_row :
    call_pres lp bm NoA MWF mario_actions_submerged._check_water_jump.
  Proof.
    exact (call_pres_of_body lp bm NoA MWF HNoA_of_MWF
             mario_actions_submerged.prog
             mario_actions_submerged._check_water_jump
             mario_actions_submerged.f_check_water_jump
             LO_sub cwj_pin
             (swk_body_of mario_actions_submerged.f_check_water_jump
                eq_refl eq_refl swk_walk_cwj)).
  Qed.



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

  (* mario_set_forward_vel: pure window stores, all-nil censuses (twin of
     ActWriterSurface.msfv_row). *)
  Lemma sub_msfv_row : call_pres lp bm NoA MWF mario._mario_set_forward_vel.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._mario_set_forward_vel mario.f_mario_set_forward_vel
             nil nil nil nil LO_mario sub_msfv_pin sub_msfv_vars sub_msfv_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_msfv_walk.
  Qed.

  (* stop_and_set_height_to_floor (mario_step.prog): ids=[mario_set_forward_vel]
     (=sub_msfv_row), xids=[vec3f_copy; vec3s_set] through marioObj->header.gfx.*
     chase dsts -- a NON-bm SafeB block, so the EXISTING obj_ext boundary
     (Hcpx_v3fc/Hcpx_v3ss, already assumed by the whirlpool slice) discharges
     them, NO new trust.  The SAME walk as AutomaticLeafSurface.Hsasthf. *)
  Lemma sub_sashf_xids_rows :
    forall fid, mem_id fid sub_sashf_xids = true -> call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_sashf_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3fc | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3ss | ].
    discriminate H.
  Qed.
  Lemma sub_sashf_ids_rows :
    forall fid, mem_id fid sub_sashf_ids = true -> call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_sashf_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_msfv_row | ].
    discriminate H.
  Qed.
  Lemma sub_sashf_row :
    call_pres lp bm NoA MWF mario_step._stop_and_set_height_to_floor.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_step.prog mario_step._stop_and_set_height_to_floor
             mario_step.f_stop_and_set_height_to_floor
             sub_sashf_ids nil sub_sashf_xids nil
             LO_mario_step sub_sashf_pin sub_sashf_vars sub_sashf_pok).
    - exact sub_sashf_ids_rows.
    - intros fid' H. discriminate H.
    - exact sub_sashf_xids_rows.
    - intros fid' H. discriminate H.
    - exact sub_sashf_walk.
  Qed.

  (* mario_throw_held_object: REUSE the already-proved ObjectLeafSurface.mtho_row
     (interaction.prog body; the object/stationary/airborne families instantiate
     the identical term).  Its 3 obj_ext externals ride Hcpx_s2v/Hcpx_ssm/
     Hcpx_oshs -- all obj_ext at the capstone, NO new trust. *)
  Lemma sub_mtho_row :
    call_pres lp bm NoA MWF mario_actions_submerged._mario_throw_held_object.
  Proof.
    exact (ObjectLeafSurface.mtho_row lp LO_mario LO_int bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
             HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             Hcpx_s2v Hcpx_ssm Hcpx_oshs).
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

  (* update_swimming_pitch: pure window stores, ZERO calls -> all censuses nil. *)
  Lemma sub_usp_row :
    call_pres lp bm NoA MWF mario_actions_submerged._update_swimming_pitch.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.prog
             mario_actions_submerged._update_swimming_pitch
             mario_actions_submerged.f_update_swimming_pitch
             nil nil nil nil LO_sub sub_usp_pin sub_usp_vars sub_usp_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_usp_walk.
  Qed.

  (* update_swimming_yaw: window stores + ONE approach_s32 external (xids), which
     reuses the SHARED obj_ext boundary (Hcpx_approach) -- NO new trust. *)
  Lemma sub_usy_xids_rows : forall fid, mem_id fid sub_usy_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_usy_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_approach | ].
    discriminate H.
  Qed.

  Lemma sub_usy_row :
    call_pres lp bm NoA MWF mario_actions_submerged._update_swimming_yaw.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.prog
             mario_actions_submerged._update_swimming_yaw
             mario_actions_submerged.f_update_swimming_yaw
             nil nil sub_usy_xids nil LO_sub sub_usy_pin sub_usy_vars sub_usy_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_usy_xids_rows.
    - intros fid' H. discriminate H.
    - exact sub_usy_walk.
  Qed.

  (* update_water_pitch: chase stores through m->marioObj (chase root) -> cact;
     no calls (sins = gSineTable load).  No new trust. *)
  Lemma sub_uwp_row :
    call_pres lp bm NoA MWF mario_actions_submerged._update_water_pitch.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.prog
             mario_actions_submerged._update_water_pitch
             mario_actions_submerged.f_update_water_pitch
             nil nil sub_uwp_cact nil nil
             LO_sub sub_uwp_pin sub_uwp_vars sub_uwp_pok sub_uwp_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_uwp_walk.
  Qed.

  (* get_buoyancy: NO stores; sole call is swimming_near_surface (sns_cp, already
     discharged this surface) -> ids=[swimming_near_surface].  No new trust. *)
  Lemma sub_gb_ids_rows : forall fid, mem_id fid sub_gb_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_gb_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sns_cp | ].
    discriminate H.
  Qed.

  Lemma sub_gb_row :
    call_pres lp bm NoA MWF mario_actions_submerged._get_buoyancy.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.prog
             mario_actions_submerged._get_buoyancy
             mario_actions_submerged.f_get_buoyancy
             sub_gb_ids nil nil nil LO_sub sub_gb_pin sub_gb_vars sub_gb_pok).
    - exact sub_gb_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_gb_walk.
  Qed.

  (* update_swimming_speed: window stores (forwardVel/vel); sole call is
     get_buoyancy (sub_gb_row); coss/sins = gSineTable loads.  No new trust. *)
  Lemma sub_uss_ids_rows : forall fid, mem_id fid sub_uss_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_uss_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_gb_row | ].
    discriminate H.
  Qed.

  Lemma sub_uss_row :
    call_pres lp bm NoA MWF mario_actions_submerged._update_swimming_speed.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.prog
             mario_actions_submerged._update_swimming_speed
             mario_actions_submerged.f_update_swimming_speed
             sub_uss_ids nil nil nil LO_sub sub_uss_pin sub_uss_vars sub_uss_pok).
    - exact sub_uss_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_uss_walk.
  Qed.

  (* stationary_slow_down: window stores; ids=[get_buoyancy] (sub_gb_row);
     xids=[approach_f32, approach_s32] (Hcpx_af32 / Hcpx_approach, both obj_ext)
     -- NO new trust. *)
  Lemma sub_ssd_ids_rows : forall fid, mem_id fid sub_ssd_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_ssd_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_gb_row | ].
    discriminate H.
  Qed.

  Lemma sub_ssd_xids_rows : forall fid, mem_id fid sub_ssd_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_ssd_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_af32 | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_approach | ].
    discriminate H.
  Qed.

  Lemma sub_ssd_row :
    call_pres lp bm NoA MWF mario_actions_submerged._stationary_slow_down.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.prog
             mario_actions_submerged._stationary_slow_down
             mario_actions_submerged.f_stationary_slow_down
             sub_ssd_ids nil sub_ssd_xids nil LO_sub
             sub_ssd_pin sub_ssd_vars sub_ssd_pok).
    - exact sub_ssd_ids_rows.
    - intros fid' H. discriminate H.
    - exact sub_ssd_xids_rows.
    - intros fid' H. discriminate H.
    - exact sub_ssd_walk.
  Qed.

  (* play_swimming_noise: NO stores; lone call play_sound (Hcpx_psound, obj_ext)
     -> xids=[play_sound].  No new trust. *)
  Lemma sub_psn_xids_rows : forall fid, mem_id fid sub_psn_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_psn_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.

  Lemma sub_psn_row :
    call_pres lp bm NoA MWF mario_actions_submerged._play_swimming_noise.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.prog
             mario_actions_submerged._play_swimming_noise
             mario_actions_submerged.f_play_swimming_noise
             nil nil sub_psn_xids nil LO_sub
             sub_psn_pin sub_psn_vars sub_psn_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_psn_xids_rows.
    - intros fid' H. discriminate H.
    - exact sub_psn_walk.
  Qed.

  (* play_sound_if_no_flag (mario.prog): window store m->flags; lone call
     play_sound (sub_psn_xids_rows -> Hcpx_psound, obj_ext).  No new trust. *)
  Lemma sub_psinf_row :
    call_pres lp bm NoA MWF mario_actions_submerged._play_sound_if_no_flag.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._play_sound_if_no_flag mario.f_play_sound_if_no_flag
             nil nil sub_psn_xids nil LO_mario
             sub_psinf_pin sub_psinf_vars sub_psinf_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_psn_xids_rows.
    - intros fid' H. discriminate H.
    - exact sub_psinf_walk.
  Qed.

  (* reset_bob_variables (mario_actions_submerged.prog): three DIRECT static-
     global stores (sBobTimer/sBobIncrement/sBobHeight, all in stored_globals);
     the sBobHeight RHS reads m->faceAngle[0] (a window load, transparent).  No
     callees, no externals -- every census is nil.  Each Sassign is accepted by
     glob_store_chk and preserved via HMWF_glob (Hglob_blk's distinctness for the
     three static blocks). *)
  Lemma sub_rbv_row :
    call_pres lp bm NoA MWF mario_actions_submerged._reset_bob_variables.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.prog
             mario_actions_submerged._reset_bob_variables
             mario_actions_submerged.f_reset_bob_variables
             nil nil nil nil LO_sub sub_rbv_pin sub_rbv_vars sub_rbv_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_rbv_walk.
  Qed.

  (* common_water_knockback_step: the call_pres_act3 kb helper.  ids dispatch to
     the discharged ssd/sma/iae rows + the perform_water_step residual (Hcp_pws);
     sids dispatch to set_mario_action (Hsmact). *)
  Lemma sub_cwks_ids_rows : forall fid, mem_id fid sub_cwks_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_cwks_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_ssd_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pws | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_iae_row | ].
    discriminate H.
  Qed.

  Lemma sub_cwks_sids_rows : forall fid, mem_id fid sub_cwks_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_cwks_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.

  Lemma sub_cwks_row :
    call_pres_act3 lp bm NoA MWF
      mario_actions_submerged._common_water_knockback_step.
  Proof.
    apply (call_pres_act3_of_wwalk_p4 lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.prog
             mario_actions_submerged._common_water_knockback_step
             mario_actions_submerged.f_common_water_knockback_step
             sub_cwks_wact sub_cwks_ids nil sub_cwks_cact nil sub_cwks_sids
             mario_actions_submerged._animation mario_actions_submerged._endAction
             mario_actions_submerged._arg3 tint tint
             LO_sub sub_cwks_pin sub_cwks_vars sub_cwks_params
             sub_cwks_aid_m sub_cwks_eid_m sub_cwks_harg_m
             sub_cwks_wa sub_cwks_wm sub_cwks_wanim sub_cwks_wharg
             sub_cwks_cm sub_cwks_canim sub_cwks_cend sub_cwks_charg).
    - exact sub_cwks_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_cwks_sids_rows.
    - exact sub_cwks_walk.
  Qed.

  (* is_anim_past_frame (mario.prog): NO stores, NO calls -- twin of is_anim_at_end. *)
  Lemma sub_iapf_row : call_pres lp bm NoA MWF mario._is_anim_past_frame.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._is_anim_past_frame mario.f_is_anim_past_frame
             nil nil nil nil LO_mario sub_iapf_pin sub_iapf_vars sub_iapf_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_iapf_walk.
  Qed.

  (* play_metal_water_jumping_sound: window store; sole call play_sound_if_no_flag
     (sub_psinf_row) -> ids.  No new trust. *)
  Lemma sub_pmwjs_ids_rows : forall fid, mem_id fid sub_pmwjs_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_pmwjs_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_psinf_row | ].
    discriminate H.
  Qed.

  Lemma sub_pmwjs_row :
    call_pres lp bm NoA MWF mario_actions_submerged._play_metal_water_jumping_sound.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.prog
             mario_actions_submerged._play_metal_water_jumping_sound
             mario_actions_submerged.f_play_metal_water_jumping_sound
             sub_pmwjs_ids nil nil nil LO_sub
             sub_pmwjs_pin sub_pmwjs_vars sub_pmwjs_pok).
    - exact sub_pmwjs_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_pmwjs_walk.
  Qed.

  (* play_metal_water_walking_sound: window store; ids=[is_anim_past_frame]
     (sub_iapf_row), xids=[play_sound] (sub_psn_xids_rows).  No new trust. *)
  Lemma sub_pmwws_ids_rows : forall fid, mem_id fid sub_pmwws_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_pmwws_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_iapf_row | ].
    discriminate H.
  Qed.

  Lemma sub_pmwws_row :
    call_pres lp bm NoA MWF mario_actions_submerged._play_metal_water_walking_sound.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.prog
             mario_actions_submerged._play_metal_water_walking_sound
             mario_actions_submerged.f_play_metal_water_walking_sound
             sub_pmwws_ids nil sub_psn_xids nil LO_sub
             sub_pmwws_pin sub_pmwws_vars sub_pmwws_pok).
    - exact sub_pmwws_ids_rows.
    - intros fid' H. discriminate H.
    - exact sub_psn_xids_rows.
    - intros fid' H. discriminate H.
    - exact sub_pmwws_walk.
  Qed.

  (* update_metal_water_walking_speed: window stores; xids=[approach_s32]
     (Hcpx_approach).  No new trust. *)
  Lemma sub_umwws_xids_rows : forall fid, mem_id fid sub_umwws_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_umwws_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_approach | ].
    discriminate H.
  Qed.

  Lemma sub_umwws_row :
    call_pres lp bm NoA MWF mario_actions_submerged._update_metal_water_walking_speed.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.prog
             mario_actions_submerged._update_metal_water_walking_speed
             mario_actions_submerged.f_update_metal_water_walking_speed
             nil nil sub_umwws_xids nil LO_sub
             sub_umwws_pin sub_umwws_vars sub_umwws_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_umwws_xids_rows.
    - intros fid' H. discriminate H.
    - exact sub_umwws_walk.
  Qed.

  (* update_metal_water_jump_speed: window stores; xids=[approach_f32]
     (Hcpx_af32).  No new trust. *)
  Lemma sub_umwjs_xids_rows : forall fid, mem_id fid sub_umwjs_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_umwjs_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_af32 | ].
    discriminate H.
  Qed.

  Lemma sub_umwjs_row :
    call_pres lp bm NoA MWF mario_actions_submerged._update_metal_water_jump_speed.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.prog
             mario_actions_submerged._update_metal_water_jump_speed
             mario_actions_submerged.f_update_metal_water_jump_speed
             nil nil sub_umwjs_xids nil LO_sub
             sub_umwjs_pin sub_umwjs_vars sub_umwjs_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_umwjs_xids_rows.
    - intros fid' H. discriminate H.
    - exact sub_umwjs_walk.
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
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_sashf_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_pmwjs_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pas | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_umwjs_row | ].
    discriminate H.
  Qed.

  (* set_mario_anim_with_accel via the np3 channel: REUSE the already-proved
     MovingLeafSurface.mov_smawa_row (call_pres_np3; same mario.prog body the
     moving family walks).  Needs only LO_mario + wwalk vars + Hcpx_lpt. *)
  Lemma sub_smawa_row :
    call_pres_np3 lp bm NoA MWF mario._set_mario_anim_with_accel.
  Proof.
    exact (MovingLeafSurface.mov_smawa_row lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
             HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe Hcpx_lpt).
  Qed.
  Lemma sub_walk_np3_rows : forall fid, mem_id fid sub_walk_np3 = true ->
      call_pres_np3 lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_walk_np3 in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_smawa_row | ].
    discriminate H.
  Qed.

  Lemma sub_walk_ids_rows : forall fid, mem_id fid sub_walk_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_walk_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_pmwws_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_umwws_row | ].
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
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_ssd_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pws | ].
    discriminate H.
  Qed.

  Lemma sub_death_ids_rows : forall fid, mem_id fid sub_death_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_death_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_ssd_row | ].
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
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_psinf_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_ssd_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pws | ].
    discriminate H.
  Qed.

  Lemma sub_shock_ids_rows : forall fid, mem_id fid sub_shock_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_shock_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_ssd_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pws | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_psinf_row | ].
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
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_cwks_row | ].
    discriminate H.
  Qed.

  Lemma sub_ccsc_ids_rows : forall fid, mem_id fid sub_ccsc_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_ccsc_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_tstw_row | ].
    discriminate H.
  Qed.

  Lemma sub_ccsc_xids_rows : forall fid, mem_id fid sub_ccsc_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_ccsc_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_ssm | ].
    discriminate H.
  Qed.

  Lemma sub_tp_ids_rows : forall fid, mem_id fid sub_tp_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_tp_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_usy_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_usp_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_uss_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pws | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_uwp_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_psinf_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_iae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_mtho_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_cwg | ].
    discriminate H.
  Qed.

  Lemma sub_tp_xids_rows : forall fid, mem_id fid sub_tp_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_tp_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_approach | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_s2v | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psm | ].
    discriminate H.
  Qed.

  (* ================================================================== *)
  (* set_anim_to_frame (SLICE 14, mario.prog): a CALL-FREE body whose    *)
  (* only writes are scalar stores `animInfo->animFrame[AccelAssist] = c` *)
  (* through an INTERIOR pointer animInfo = &m->marioObj->..->animInfo    *)
  (* aliasing the marioObj SafeB block.  The generic chase engine has no  *)
  (* arm for the Eaddrof interior-pointer Sset, so we walk the fixed body *)
  (* directly: chase_root_set_sound pins marioObj SafeB, chain_root_l_    *)
  (* block carries that block onto animInfo, chase_assign_pres absorbs    *)
  (* each store (SafeB block, non-Vptr scalar value).  DISCHARGES the     *)
  (* former Hcp_satf residual -- NO new trust.                            *)
  (* ================================================================== *)

  Lemma sat_act_inv_nil : forall le0, act_inv nil le0.
  Proof. intros le0 tt Htt. cbn [mem_id existsb] in Htt. discriminate Htt. Qed.

  Lemma sat_ci_set : forall id v le,
    Pos.eqb id mario._animInfo = false ->
    chase_inv SafeB [mario._animInfo] le ->
    chase_inv SafeB [mario._animInfo] (PTree.set id v le).
  Proof.
    intros id v le Hne Hci tt Htt b o Hb.
    cbn [mem_id existsb] in Htt. rewrite orb_false_r in Htt.
    apply Pos.eqb_eq in Htt. subst tt.
    rewrite PTree.gso in Hb by (apply Pos.eqb_neq in Hne; congruence).
    refine (Hci mario._animInfo _ b o Hb).
    cbn [mem_id existsb]. rewrite orb_false_r. apply Pos.eqb_refl.
  Qed.

  Lemma sat_store : forall a1 a2 le mm tr le' mm' out,
    exec_stmt function_entry2 (lp_ge lp) empty_env le mm
      (Sassign a1 a2) tr le' mm' out ->
    chase_store_chk nil [mario._animInfo] a1 a2 = true ->
    chase_inv SafeB [mario._animInfo] le ->
    MWF mm -> Mem.valid_block mm bm -> action_sat not_tainted mm bm ->
    Mem.valid_block mm' bm /\ action_sat not_tainted mm' bm /\ MWF mm'.
  Proof.
    intros a1 a2 le mm tr le' mm' out Hexec Hck Hci HM HV HS.
    destruct (chase_assign_pres lp bm MWF SafeB HSafeNotBm HMWF_chase
                nil [mario._animInfo] a1 a2 empty_env le mm tr le' mm' out
                Hck (sat_act_inv_nil le) Hci Hexec HM HV HS)
      as (HV' & HS' & HM' & _ & _).
    exact (conj HV' (conj HS' HM')).
  Qed.

  Lemma sub_satf_pin :
    (prog_defmap mario.prog) ! mario._set_anim_to_frame
    = Some (Gfun (Internal mario.f_set_anim_to_frame)).
  Proof. vm_compute. reflexivity. Qed.

  Lemma sub_satf_body :
    body_pres lp NoA MWF bm mario.f_set_anim_to_frame.
  Proof.
    intros m0 vargs0 t0 mF vres0 Hgate Hevf HN HM HV HS.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rename Ha into Halloc end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    (* alloc nil -> empty_env, body memory unchanged *)
    change (fn_vars mario.f_set_anim_to_frame) with (@nil (ident * type)) in Halloc.
    inv Halloc.
    (* the [inv]s above auto-named the bound temp env and body memory; pin
       them to the names the walk below uses (avoid the Peano.le collision) *)
    match goal with
    | Hbd : exec_stmt _ _ _ ?LE ?MM _ _ _ _ _ |- _ =>
        rename LE into le; rename MM into m0
    end.
    (* the free_list of the empty env is the identity: mF is the body memory *)
    assert (Hben : blocks_of_env (lp_ge lp) empty_env = nil) by reflexivity.
    rewrite Hben in Hfree. cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    (* bind the two params *)
    change (fn_params mario.f_set_anim_to_frame)
      with ((mario._m, tptr (Tstruct mario._MarioState noattr))
            :: (mario._animFrame, tshort) :: nil) in Hbind.
    destruct vargs0 as [|vm0 [|vaf0 [|vextra vrest]]];
      cbn [bind_parameter_temps] in Hbind; try discriminate Hbind.
    injection Hbind as Hbind.
    (* the marg fact for _m *)
    specialize (Hgate eq_refl).
    assert (Hlm : le ! mario._m = Some vm0).
    { rewrite <- Hbind. rewrite PTree.gso by discriminate. apply PTree.gss. }
    assert (Htat : forall b o,
      le ! mario._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hb. rewrite Hlm in Hb. injection Hb as Hb. subst vm0.
      cbn in Hgate. exact Hgate. }
    (* expose the body *)
    unfold mario.f_set_anim_to_frame in Hbody. cbn [fn_body] in Hbody.
    (* strip the first two Ssets: t'6 = m->marioObj; animInfo = &(..animInfo) *)
    apply exec_seq_two_sset in Hbody.
    destruct Hbody as (v6 & vai & ? & Hev6 & Hevai & Hbody).
    (* marioObj is a chase root: v6 is SafeB-if-a-pointer *)
    pose proof (chase_root_set_sound lp LO_mario bm MWF HMWF_window HMWF_glob
                  HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_root
                  (Efield (Ederef (Etempvar mario._m
                       (tptr (Tstruct mario._MarioState noattr)))
                       (Tstruct mario._MarioState noattr)) mario._marioObj
                       (tptr (Tstruct mario._Object noattr)))
                  empty_env le m0 v6
                  ltac:(vm_compute; reflexivity) Htat HM Hev6) as Hsafe6.
    (* animInfo = &(v6 .. animInfo): same block as v6, hence SafeB.
       Use eval_Eaddrof_inv (not [inv]) so [vai] stays a name. *)
    destruct (eval_Eaddrof_inv _ _ _ _ _ _ _ Hevai) as (loc & ofs & Hlv & Hvai_eq).
    destruct (chain_root_l_block (lp_ge lp) empty_env
                (PTree.set mario._t'6 v6 le) m0
                (Efield (Efield (Efield
                   (Ederef (Etempvar mario._t'6
                      (tptr (Tstruct mario._Object noattr)))
                      (Tstruct mario._Object noattr)) mario._header
                      (Tstruct mario._ObjectNode noattr)) mario._gfx
                      (Tstruct mario._GraphNodeObject noattr)) mario._animInfo
                   (Tstruct mario._AnimInfo noattr))
                mario._t'6 loc ofs Full
                ltac:(vm_compute; reflexivity) Hlv) as (o0 & Ht6).
    rewrite PTree.gss in Ht6. injection Ht6 as Ht6.
    pose proof (Hsafe6 _ _ Ht6) as Hsafe_loc.
    (* the chase invariant for [animInfo] at le2 *)
    assert (Hci : chase_inv SafeB [mario._animInfo]
                    (PTree.set mario._animInfo vai
                       (PTree.set mario._t'6 v6 le))).
    { intros tt Htt b o Hb. cbn [mem_id existsb] in Htt.
      rewrite orb_false_r in Htt. apply Pos.eqb_eq in Htt. subst tt.
      rewrite PTree.gss in Hb. injection Hb as Hb. rewrite Hvai_eq in Hb.
      injection Hb as Hbloc Hbofs. subst. exact Hsafe_loc. }
    (* strip curAnim, t'1 (loads -- memory unchanged), refresh Hci *)
    apply exec_seq_sset in Hbody. destruct Hbody as (vca & ? & _ & Hbody).
    apply (sat_ci_set mario._curAnim vca _ ltac:(vm_compute; reflexivity)) in Hci.
    apply exec_seq_sset in Hbody. destruct Hbody as (v1 & ? & _ & Hbody).
    apply (sat_ci_set mario._t'1 v1 _ ltac:(vm_compute; reflexivity)) in Hci.
    (* outer if (animAccel != 0) *)
    inv Hbody.
    match goal with Hb1 : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ =>
      destruct b end.
    - (* THEN: t'3 = curAnim->flags; if (flags & BACKWARD) *)
      match goal with Hb : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
        apply exec_seq_sset in Hb; destruct Hb as (v3 & ? & _ & Hbody) end.
      apply (sat_ci_set mario._t'3 v3 _ ltac:(vm_compute; reflexivity)) in Hci.
      inv Hbody.
      match goal with Hb2 : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ =>
        destruct b end.
      + (* t'5 = animInfo->animAccel; STORE animFrameAccelAssist *)
        match goal with Hb : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
          apply exec_seq_sset in Hb; destruct Hb as (v5 & ? & _ & Hstore) end.
        apply (sat_ci_set mario._t'5 v5 _ ltac:(vm_compute; reflexivity)) in Hci.
        eapply sat_store;
          [ exact Hstore | vm_compute; reflexivity | exact Hci
          | exact HM | exact HV | exact HS ].
      + (* t'4 = animInfo->animAccel; STORE animFrameAccelAssist *)
        match goal with Hb : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
          apply exec_seq_sset in Hb; destruct Hb as (v4 & ? & _ & Hstore) end.
        apply (sat_ci_set mario._t'4 v4 _ ltac:(vm_compute; reflexivity)) in Hci.
        eapply sat_store;
          [ exact Hstore | vm_compute; reflexivity | exact Hci
          | exact HM | exact HV | exact HS ].
    - (* ELSE: t'2 = curAnim->flags; if (flags & BACKWARD) *)
      match goal with Hb : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
        apply exec_seq_sset in Hb; destruct Hb as (v2 & ? & _ & Hbody) end.
      apply (sat_ci_set mario._t'2 v2 _ ltac:(vm_compute; reflexivity)) in Hci.
      inv Hbody.
      match goal with Hb3 : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ =>
        destruct b end.
      + (* STORE animFrame = animFrame + 1 *)
        match goal with Hstore : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ =>
          eapply sat_store;
            [ exact Hstore | vm_compute; reflexivity | exact Hci
            | exact HM | exact HV | exact HS ] end.
      + (* STORE animFrame = animFrame - 1 *)
        match goal with Hstore : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ =>
          eapply sat_store;
            [ exact Hstore | vm_compute; reflexivity | exact Hci
            | exact HM | exact HV | exact HS ] end.
  Qed.

  Lemma sub_satf_row :
    call_pres lp bm NoA MWF mario_actions_submerged._set_anim_to_frame.
  Proof.
    exact (call_pres_of_body lp bm NoA MWF HNoA_of_MWF mario.prog
             mario._set_anim_to_frame mario.f_set_anim_to_frame
             LO_mario sub_satf_pin sub_satf_body).
  Qed.

  (* ---- SLICE 14: the swimming-cluster rows ---- *)
  Lemma swim_ids_rows : forall fid, mem_id fid swim_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold swim_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_cwj_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_satf_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_rbv_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_css | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_psn_row | ].
    discriminate H.
  Qed.

  Lemma swim_xids_rows : forall fid, mem_id fid swim_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold swim_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_af32 | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_ssm | ].
    discriminate H.
  Qed.

  (* ---- SLICE 15: the last-two-leaves rows ---- *)
  Lemma wp_ids_rows : forall fid, mem_id fid wp_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold wp_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sns_cp | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_ssd_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pws | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_sma_row | ].
    discriminate H.
  Qed.

  Lemma wp_xids_rows : forall fid, mem_id fid wp_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold wp_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.

  Lemma whirl_ids_rows : forall fid, mem_id fid whirl_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold whirl_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_ltw | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sub_sma_row | ].
    discriminate H.
  Qed.

  Lemma whirl_xids_rows : forall fid, mem_id fid whirl_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold whirl_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_sqrtf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_atan2s | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3fc | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3ss | ].
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
    apply (body_pres_of_wwalk_nids lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_metal_water_walking
             sub_walk_ids nil nil nil sub_sids nil sub_walk_nids sub_walk_np3
             sub_mww_vars sub_mww_pok eq_refl sub_mww_nonparam_n).
    - exact sub_walk_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_walk_np3_rows.
    - exact sub_mww_walk.
  Qed.

  Lemma act_hold_metal_water_walking_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_hold_metal_water_walking.
  Proof.
    apply (body_pres_of_wwalk_nids lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_hold_metal_water_walking
             sub_walk_ids nil nil nil sub_sids nil sub_walk_nids sub_walk_np3
             sub_hmww_vars sub_hmww_pok eq_refl sub_hmww_nonparam_n).
    - exact sub_walk_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_walk_np3_rows.
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

  Lemma act_check_common_submerged_cancels_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_check_common_submerged_cancels.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_check_common_submerged_cancels
             sub_ccsc_ids nil sub_ccsc_cact sub_ccsc_xids sub_sids nil
             sub_ccsc_vars sub_ccsc_pok sub_ccsc_nonparam).
    - exact sub_ccsc_ids_rows.
    - intros fid' H. discriminate H.
    - exact sub_ccsc_xids_rows.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_ccsc_walk.
  Qed.

  Lemma act_water_throw_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_water_throw.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_water_throw
             sub_tp_ids nil sub_wt_cact sub_tp_xids sub_sids nil
             sub_wt_vars sub_wt_pok sub_wt_nonparam).
    - exact sub_tp_ids_rows.
    - intros fid' H. discriminate H.
    - exact sub_tp_xids_rows.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_wt_walk.
  Qed.

  Lemma act_water_punch_pres :
    body_pres lp NoA MWF bm
      mario_actions_submerged.f_act_water_punch.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_water_punch
             sub_tp_ids nil sub_wp_cact sub_tp_xids sub_sids nil
             sub_wp_vars sub_wp_pok sub_wp_nonparam).
    - exact sub_tp_ids_rows.
    - intros fid' H. discriminate H.
    - exact sub_tp_xids_rows.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_wp_walk.
  Qed.

  (* ---- SLICE 14: the swimming-cluster leaves ---- *)
  Lemma act_breaststroke_pres :
    body_pres lp NoA MWF bm mario_actions_submerged.f_act_breaststroke.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_breaststroke
             swim_ids nil swim_bs_cact swim_xids sub_sids nil
             sub_bs_vars sub_bs_pok sub_bs_nonparam).
    - exact swim_ids_rows.
    - intros fid' H. discriminate H.
    - exact swim_xids_rows.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_bs_walk.
  Qed.

  Lemma act_swimming_end_pres :
    body_pres lp NoA MWF bm mario_actions_submerged.f_act_swimming_end.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_swimming_end
             swim_ids nil swim_xids sub_sids nil
             sub_se_vars sub_se_pok).
    - exact swim_ids_rows.
    - intros fid' H. discriminate H.
    - exact swim_xids_rows.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_se_walk.
  Qed.

  Lemma act_flutter_kick_pres :
    body_pres lp NoA MWF bm mario_actions_submerged.f_act_flutter_kick.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_flutter_kick
             swim_ids nil swim_xids sub_sids nil
             sub_fk_vars sub_fk_pok).
    - exact swim_ids_rows.
    - intros fid' H. discriminate H.
    - exact swim_xids_rows.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_fk_walk.
  Qed.

  Lemma act_hold_breaststroke_pres :
    body_pres lp NoA MWF bm mario_actions_submerged.f_act_hold_breaststroke.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_hold_breaststroke
             swim_ids nil swim_hbs_cact swim_xids sub_sids nil
             sub_hbs_vars sub_hbs_pok sub_hbs_nonparam).
    - exact swim_ids_rows.
    - intros fid' H. discriminate H.
    - exact swim_xids_rows.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_hbs_walk.
  Qed.

  Lemma act_hold_swimming_end_pres :
    body_pres lp NoA MWF bm mario_actions_submerged.f_act_hold_swimming_end.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_hold_swimming_end
             swim_ids nil swim_hse_cact swim_xids sub_sids nil
             sub_hse_vars sub_hse_pok sub_hse_nonparam).
    - exact swim_ids_rows.
    - intros fid' H. discriminate H.
    - exact swim_xids_rows.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_hse_walk.
  Qed.

  Lemma act_hold_flutter_kick_pres :
    body_pres lp NoA MWF bm mario_actions_submerged.f_act_hold_flutter_kick.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_hold_flutter_kick
             swim_ids nil swim_hfk_cact swim_xids sub_sids nil
             sub_hfk_vars sub_hfk_pok sub_hfk_nonparam).
    - exact swim_ids_rows.
    - intros fid' H. discriminate H.
    - exact swim_xids_rows.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_hfk_walk.
  Qed.

  Lemma act_water_shell_swimming_pres :
    body_pres lp NoA MWF bm mario_actions_submerged.f_act_water_shell_swimming.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_water_shell_swimming
             swim_ids nil swim_wss_cact swim_xids sub_sids nil
             sub_wss_vars sub_wss_pok sub_wss_nonparam).
    - exact swim_ids_rows.
    - intros fid' H. discriminate H.
    - exact swim_xids_rows.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_wss_walk.
  Qed.

  (* ---- SLICE 15: the last two submerged leaves ---- *)
  Lemma act_water_plunge_pres :
    body_pres lp NoA MWF bm mario_actions_submerged.f_act_water_plunge.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_water_plunge
             wp_ids nil wp_cact wp_xids sub_sids nil
             sub_wpl_vars sub_wpl_pok sub_wpl_nonparam).
    - exact wp_ids_rows.
    - intros fid' H. discriminate H.
    - exact wp_xids_rows.
    - exact sub_sids_rows.
    - intros fid' H. discriminate H.
    - exact sub_wpl_walk.
  Qed.

  Lemma act_caught_in_whirlpool_pres :
    body_pres lp NoA MWF bm mario_actions_submerged.f_act_caught_in_whirlpool.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_submerged.f_act_caught_in_whirlpool
             whirl_ids nil whirl_cact whirl_xids nil nil
             sub_whp_vars sub_whp_pok sub_whp_nonparam).
    - exact whirl_ids_rows.
    - intros fid' H. discriminate H.
    - exact whirl_xids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sub_whp_walk.
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
    destruct (Pos.eqb fid mario_actions_submerged._check_common_submerged_cancels)
      eqn:Ew22.
    { apply Pos.eqb_eq in Ew22; subst fid.
      rewrite sub_ccsc_pin in Hdm. injection Hdm as <-.
      exact act_check_common_submerged_cancels_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_water_throw)
      eqn:Ew23.
    { apply Pos.eqb_eq in Ew23; subst fid.
      rewrite sub_wt_pin in Hdm. injection Hdm as <-.
      exact act_water_throw_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_water_punch)
      eqn:Ew24.
    { apply Pos.eqb_eq in Ew24; subst fid.
      rewrite sub_wp_pin in Hdm. injection Hdm as <-.
      exact act_water_punch_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_breaststroke)
      eqn:Ew25.
    { apply Pos.eqb_eq in Ew25; subst fid.
      rewrite sub_bs_pin in Hdm. injection Hdm as <-.
      exact act_breaststroke_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_swimming_end)
      eqn:Ew26.
    { apply Pos.eqb_eq in Ew26; subst fid.
      rewrite sub_se_pin in Hdm. injection Hdm as <-.
      exact act_swimming_end_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_flutter_kick)
      eqn:Ew27.
    { apply Pos.eqb_eq in Ew27; subst fid.
      rewrite sub_fk_pin in Hdm. injection Hdm as <-.
      exact act_flutter_kick_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_hold_breaststroke)
      eqn:Ew28.
    { apply Pos.eqb_eq in Ew28; subst fid.
      rewrite sub_hbs_pin in Hdm. injection Hdm as <-.
      exact act_hold_breaststroke_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_hold_swimming_end)
      eqn:Ew29.
    { apply Pos.eqb_eq in Ew29; subst fid.
      rewrite sub_hse_pin in Hdm. injection Hdm as <-.
      exact act_hold_swimming_end_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_hold_flutter_kick)
      eqn:Ew30.
    { apply Pos.eqb_eq in Ew30; subst fid.
      rewrite sub_hfk_pin in Hdm. injection Hdm as <-.
      exact act_hold_flutter_kick_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_water_shell_swimming)
      eqn:Ew31.
    { apply Pos.eqb_eq in Ew31; subst fid.
      rewrite sub_wss_pin in Hdm. injection Hdm as <-.
      exact act_water_shell_swimming_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_water_plunge)
      eqn:Ew32.
    { apply Pos.eqb_eq in Ew32; subst fid.
      rewrite sub_wpl_pin in Hdm. injection Hdm as <-.
      exact act_water_plunge_pres. }
    destruct (Pos.eqb fid mario_actions_submerged._act_caught_in_whirlpool)
      eqn:Ew33.
    { apply Pos.eqb_eq in Ew33; subst fid.
      rewrite sub_whp_pin in Hdm. injection Hdm as <-.
      exact act_caught_in_whirlpool_pres. }
    (* REST: fid is in the census and not a walked id, so it is in the
       filter that defines sub_rest_ids. *)
    apply (Hrest fid f); [ | exact Hdm ].
    unfold sub_rest_ids.
    apply mem_id_filter_true; [ exact H | ].
    unfold sub_walked_ids. cbn [mem_id existsb].
    rewrite Ew1, Ew2, Ew3, Ew4, Ew5, Ew6, Ew7, Ew8, Ew9, Ew10,
      Ew11, Ew12, Ew13, Ew14, Ew15, Ew16, Ew17, Ew18, Ew19,
      Ew20, Ew21, Ew22, Ew23, Ew24, Ew25, Ew26, Ew27, Ew28, Ew29,
      Ew30, Ew31, Ew32, Ew33. reflexivity.
  Qed.

  (* SLICE 15 CLOSES THE SUBMERGED LEAF FAMILY: all 33 census ids are now
     WALKED (sub_rest_ids computes to []), so the rest premise is VACUOUS.
     This full version discharges it inline -- the WHOLE submerged leaf census
     is positively walked, with NO catch-all "rest" hypothesis surviving at the
     capstone (Hpres_sub_rest is eliminated). *)
  Lemma submerged_leaf_callees_pres_full :
    forall fid f, mem_id fid submerged_callee_ids = true ->
      (prog_defmap mario_actions_submerged.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f.
  Proof.
    apply submerged_leaf_callees_pres.
    intros fid f H _. vm_compute in H. discriminate H.
  Qed.

End SubmergedLeafRows.
