(* ====================================================================== *)
(* THE OBJECT-FAMILY LEAF SURFACE (SPINE: object_callees_pres shrinks the *)
(* capstone's object census): helper rows + the first discharged leaf.    *)
(*                                                                        *)
(* Scope (probe-mapped, 2026-06-05): the 11 leaves call 17 helpers.       *)
(* This file proves the rows that need NO census/walker changes:          *)
(*   play_sound_if_no_flag, is_anim_at_end, set_water_plunge_action,      *)
(*   check_common_action_exits          (mario.prog, Mario-head leaves)   *)
(*   mario_update_moving_sand, mario_update_windy_ground                  *)
(*                                      (mario_step.prog, walk EMPTY)     *)
(*   drop_and_set_mario_action          (the SECOND act writer: same      *)
(*                                       writer_params shape as           *)
(*                                       set_mario_action, consumes the   *)
(*                                       smact_pres keystone)             *)
(*   stationary_ground_step             (mario_step.prog; its only        *)
(*                                       deferred callee is               *)
(*                                       perform_ground_step)             *)
(*                                                                        *)
(* PLUS (2026-06-05, the B2b slice): the FIVE interaction-TU object       *)
(* helpers behind mario_stop_riding_and_holding, walked via the root-     *)
(* store / fused-pair / Oshl walker arms:                                 *)
(*   mario_stop_riding_and_holding, mario_stop_riding_object,             *)
(*   mario_drop_held_object, mario_throw_held_object,                     *)
(*   mario_grab_used_object                                               *)
(* -- this DELETES the Hcp_msrah residual.                                *)
(*                                                                        *)
(* Named residual hypotheses (per-symbol, satisfiable, dischargeable):    *)
(*   Hcpx_* : call_pres_ext rows for the EXTERNAL callees (play_sound,    *)
(*            vec3s_set, vec3f_copy, set_camera_mode, + the interaction   *)
(*            trio segmented_to_virtual / stop_shell_music /              *)
(*            obj_set_held_state) -- same model class as the capstone's   *)
(*            warp_ext ids.                                               *)
(*   Hcp_pgs : perform_ground_step (mario_step.prog; fn_vars <> nil --    *)
(*            local vec3f array -- + the quarter-step surface regime).    *)
(* ====================================================================== *)

From Coq Require Import ZArith Lia List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario mario_step interaction
  mario_actions_airborne mario_actions_object mario_actions_cutscene.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit FloorsSurface ObjectSurface.
From SM64.Proofs Require Import ActWriterSurface.

Import ListNotations.

(* ====================================================================== *)
(* Censuses (probe-derived).                                              *)
(* ====================================================================== *)

(* the shared smact-const census: every leaf/helper that calls
   set_mario_action with a vm-checkably untainted constant *)
Definition obj_sids : list ident := mario._set_mario_action :: nil.

Definition psinf_xids : list ident := mario._play_sound :: nil.

(* play_mario_jump_sound: structurally identical to play_sound_if_no_flag --
   one external (mario._play_sound), one flags window store; no chase stores. *)
Definition pmjs_xids : list ident := mario._play_sound :: nil.

(* swpa: vec3s_set(m->angleVel,0,0,0) + set_camera_mode(m->area->camera..) *)
Definition swpa_xids : list ident :=
  mario._vec3s_set :: mario._set_camera_mode :: nil.

(* dasma: _t'1 := set_mario_action(m, _action, _actionArg); return _t'1 *)
Definition dasma_wact : list ident := mario._action :: mario._t'1 :: nil.
Definition dasma_ids : list ident :=
  interaction._mario_stop_riding_and_holding :: nil.
Definition dasma_wids : list ident := mario._set_mario_action :: nil.

(* the FIVE interaction-TU object helpers (probe-derived censuses):
   chase temps loaded from the heldObj/usedObj/riddenObj root cells,
   external callees segmented_to_virtual / obj_set_held_state /
   stop_shell_music *)
Definition msrah_ids : list ident :=
  interaction._mario_drop_held_object
    :: interaction._mario_stop_riding_object :: nil.
Definition msrah_cact : list ident :=
  interaction._t'4 :: interaction._t'2 :: nil.
Definition msro_cact : list ident := interaction._t'2 :: nil.
Definition msro_xids : list ident := interaction._stop_shell_music :: nil.
Definition mdho_cact : list ident :=
  interaction._t'10 :: interaction._t'8 :: interaction._t'5
    :: interaction._t'3 :: nil.
Definition mdho_xids : list ident :=
  interaction._segmented_to_virtual :: interaction._obj_set_held_state
    :: interaction._stop_shell_music :: nil.
Definition mtho_cact : list ident :=
  interaction._t'13 :: interaction._t'10 :: interaction._t'5
    :: interaction._t'3 :: nil.
Definition mguo_cact : list ident := interaction._t'3 :: nil.
Definition mguo_xids : list ident :=
  interaction._obj_set_held_state :: nil.

(* sgs: msfv + the two sand/wind updaters + perform_ground_step, plus the
   two math-util externals copying gfx pos/angle through chase pointers *)
Definition sgs_ids : list ident :=
  mario._mario_set_forward_vel
    :: mario_step._mario_update_moving_sand
    :: mario_step._mario_update_windy_ground
    :: mario_step._perform_ground_step :: nil.
Definition sgs_xids : list ident :=
  mario_step._vec3f_copy :: mario._vec3s_set :: nil.

(* ccoc (the FIRST leaf): set_water_plunge_action(m) plain, plus two
   drop_and_set_mario_action(m, ACT_CONST, CONST) writer calls *)
Definition ccoc_ids : list ident := mario._set_water_plunge_action :: nil.
Definition ccoc_sids : list ident :=
  mario._drop_and_set_mario_action :: nil.

(* the object family's EXTERNAL leaf rows (the warp_ext_ids model class);
   grows as further leaves discharge *)
Definition obj_ext_ids : list ident :=
  mario._vec3s_set
    (* cutscene bbh/squished cluster: vec3f_set writes a caller-provided
       float window (3 scalar components into &Object->gfx.pos-style
       arrays), no Mario pointer -- the SAME pure-vector-helper model
       class as vec3s_set / vec3f_copy above (EF_external in every
       generated TU, writes no Mario cell). *)
    :: mario._vec3f_set
    :: mario._set_camera_mode
    :: interaction._segmented_to_virtual
    :: interaction._stop_shell_music
    :: interaction._obj_set_held_state
    :: mario._load_patchable_table
    :: mario._play_sound :: mario_step._vec3f_copy
    :: mario_actions_object._approach_s32
    :: interaction._atan2s
    :: interaction._virtual_to_segmented
    (* B10 pole cluster: set_sound_moving_speed is a pure AUDIO external
       (sets the moving-sound speed register), writes no Mario state --
       same model class as play_sound. *)
    :: mario._set_sound_moving_speed
    (* io arc (push_mario_out_of_object): sqrtf is the pure-math distance
       external -- the SAME model class as atan2s above (EF_external in
       every generated TU, writes nothing). *)
    :: mario._sqrtf
    (* slice 3 (tdfio): set_camera_shake_from_hit is the pure-camera
       shake external (tshort arg, no pointers, writes no Mario state) --
       the same model class as set_camera_mode above. *)
    :: interaction._set_camera_shake_from_hit
    (* slice 5 (coin): bhv_spawn_star_no_level_exit spawns the 100-coin
       star INTO THE OBJECT POOL (a const u32 star index arg, no Mario
       pointer) -- the same model class as spawn_object's row (the pool
       is SafeB-disjoint from Mario's state; it writes no Mario cell). *)
    :: interaction._bhv_spawn_star_no_level_exit
    (* slice 5 (warp_door): save_file_get_flags is a pure READER of the
       save buffer (no args, returns the flag word, no Mario pointer) --
       the same model class as the other no-pointer externals here. *)
    :: interaction._save_file_get_flags
    (* slice 5 ob arc (cap / koopa_shell): the two music-sequencer
       externals (scalar args, no Mario pointer) -- the same model
       class as play_sound above. *)
    :: interaction._play_cap_music
    :: interaction._play_shell_music
    (* slice 5 (door): save_file_get_total_star_count is a pure READER
       of the save buffer (two scalar course-range args, no Mario
       pointer) -- the same model class as save_file_get_flags above. *)
    :: interaction._save_file_get_total_star_count
    (* slice 5 (star_or_key): the save-buffer star WRITER (two scalar
       args: coin score + star index -- writes ONLY the save buffer,
       no Mario pointer) and the two music-sequencer externals (scalar
       args / no args) -- the same model classes as the save readers
       and play_sound above. *)
    :: interaction._save_file_collect_star_or_key
    (* cutscene door (act_unlocking_star_door): save_file_set_flags is a save-
       buffer WRITER (one scalar flag-word arg, no Mario pointer) -- EF_external
       in every generated TU, the SAME honest model class as save_file_collect_
       star_or_key above.  Rides Hpres_obj_ext, NO new capstone hypothesis. *)
    :: interaction._save_file_set_flags
    (* cutscene door (act_unlocking_key_door): save_file_clear_flags is the
       twin save-buffer WRITER (one scalar flag-word arg, no Mario pointer)
       -- EF_external in every generated TU, the SAME honest model class as
       save_file_set_flags above.  Rides Hpres_obj_ext, NO new capstone
       hypothesis. *)
    :: interaction._save_file_clear_flags
    :: interaction._drop_queued_background_music
    :: interaction._fadeout_level_music
    (* cutscene credits (act_credits_cutscene): vec3s_copy is the s16-vector
       copier (writes a caller-provided short window, e.g. marioObj->gfx.angle
       <- m->faceAngle; no Mario pointer first) -- the SAME pure-vector-helper
       model class as vec3f_copy above.  override_viewport_and_clip and
       reset_cutscene_msg_fade are pure viewport / message-fade writers (they
       touch only the sEndCutsceneVp viewport union and the msg-fade statics,
       no Mario pointer) -- EF_external in every generated TU, the same honest
       boundary class as set_camera_mode.  All ride Hpres_obj_ext, NO new
       capstone hypothesis. *)
    :: mario._vec3s_copy
    :: mario_actions_cutscene._override_viewport_and_clip
    :: mario_actions_cutscene._reset_cutscene_msg_fade :: nil.
(* NOTE: find_floor was REMOVED from obj_ext_ids.  It is an out-param
   WRITER, so the phantom-false `call_pres_ext find_floor` (which would
   allow &(action cell) as the out-param) is no longer a capstone
   residual; its only consumer (the ledge cluster lgl/ffhrp in
   AutomaticLeafSurface) now uses the faithful gated `call_pres_ext_oc`
   via the out-param arc (call_pres_of_lwalk2). *)

(* ====================================================================== *)
(* Pins (vm_compute over the generated TUs).                              *)
(* ====================================================================== *)

Example psinf_pin :
  (prog_defmap mario.prog) ! mario._play_sound_if_no_flag
  = Some (Gfun (Internal mario.f_play_sound_if_no_flag)).
Proof. vm_compute. reflexivity. Qed.
Example psinf_vars : fn_vars mario.f_play_sound_if_no_flag = nil.
Proof. vm_compute. reflexivity. Qed.
Example psinf_params_ok :
  match fn_params mario.f_play_sound_if_no_flag with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example psinf_walk :
  wwalk_chk false nil nil nil nil psinf_xids nil nil
    (fn_body mario.f_play_sound_if_no_flag) = true.
Proof. vm_compute. reflexivity. Qed.

Example pmjs_pin :
  (prog_defmap mario.prog) ! mario._play_mario_jump_sound
  = Some (Gfun (Internal mario.f_play_mario_jump_sound)).
Proof. vm_compute. reflexivity. Qed.
Example pmjs_vars : fn_vars mario.f_play_mario_jump_sound = nil.
Proof. vm_compute. reflexivity. Qed.
Example pmjs_params_ok :
  match fn_params mario.f_play_mario_jump_sound with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example pmjs_walk :
  wwalk_chk false nil nil nil nil pmjs_xids nil nil
    (fn_body mario.f_play_mario_jump_sound) = true.
Proof. vm_compute. reflexivity. Qed.

Example iaae_pin :
  (prog_defmap mario.prog) ! mario._is_anim_at_end
  = Some (Gfun (Internal mario.f_is_anim_at_end)).
Proof. vm_compute. reflexivity. Qed.
Example iaae_vars : fn_vars mario.f_is_anim_at_end = nil.
Proof. vm_compute. reflexivity. Qed.
Example iaae_params_ok :
  match fn_params mario.f_is_anim_at_end with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example iaae_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario.f_is_anim_at_end) = true.
Proof. vm_compute. reflexivity. Qed.

Example ccae_pin :
  (prog_defmap mario.prog) ! mario._check_common_action_exits
  = Some (Gfun (Internal mario.f_check_common_action_exits)).
Proof. vm_compute. reflexivity. Qed.
Example ccae_vars : fn_vars mario.f_check_common_action_exits = nil.
Proof. vm_compute. reflexivity. Qed.
Example ccae_params_ok :
  match fn_params mario.f_check_common_action_exits with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example ccae_walk :
  wwalk_chk false nil nil nil nil nil obj_sids nil
    (fn_body mario.f_check_common_action_exits) = true.
Proof. vm_compute. reflexivity. Qed.

Example swpa_pin :
  (prog_defmap mario.prog) ! mario._set_water_plunge_action
  = Some (Gfun (Internal mario.f_set_water_plunge_action)).
Proof. vm_compute. reflexivity. Qed.
Example swpa_vars : fn_vars mario.f_set_water_plunge_action = nil.
Proof. vm_compute. reflexivity. Qed.
Example swpa_params_ok :
  match fn_params mario.f_set_water_plunge_action with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example swpa_walk :
  wwalk_chk false nil nil nil nil swpa_xids obj_sids nil
    (fn_body mario.f_set_water_plunge_action) = true.
Proof. vm_compute. reflexivity. Qed.

Example mums_pin :
  (prog_defmap mario_step.prog) ! mario_step._mario_update_moving_sand
  = Some (Gfun (Internal mario_step.f_mario_update_moving_sand)).
Proof. vm_compute. reflexivity. Qed.
Example mums_vars : fn_vars mario_step.f_mario_update_moving_sand = nil.
Proof. vm_compute. reflexivity. Qed.
Example mums_params_ok :
  match fn_params mario_step.f_mario_update_moving_sand with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example mums_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario_step.f_mario_update_moving_sand) = true.
Proof. vm_compute. reflexivity. Qed.

Example muwg_pin :
  (prog_defmap mario_step.prog) ! mario_step._mario_update_windy_ground
  = Some (Gfun (Internal mario_step.f_mario_update_windy_ground)).
Proof. vm_compute. reflexivity. Qed.
Example muwg_vars : fn_vars mario_step.f_mario_update_windy_ground = nil.
Proof. vm_compute. reflexivity. Qed.
Example muwg_params_ok :
  match fn_params mario_step.f_mario_update_windy_ground with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example muwg_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario_step.f_mario_update_windy_ground) = true.
Proof. vm_compute. reflexivity. Qed.

Example dasma_pin :
  (prog_defmap mario.prog) ! mario._drop_and_set_mario_action
  = Some (Gfun (Internal mario.f_drop_and_set_mario_action)).
Proof. vm_compute. reflexivity. Qed.
Example dasma_vars : fn_vars mario.f_drop_and_set_mario_action = nil.
Proof. vm_compute. reflexivity. Qed.
Example dasma_params :
  fn_params mario.f_drop_and_set_mario_action = writer_params.
Proof. vm_compute. reflexivity. Qed.
Example dasma_ret :
  i32_ty (fn_return mario.f_drop_and_set_mario_action) = true.
Proof. vm_compute. reflexivity. Qed.
Example dasma_walk :
  wwalk_chk true dasma_wact dasma_ids dasma_wids nil nil nil nil
    (fn_body mario.f_drop_and_set_mario_action) = true.
Proof. vm_compute. reflexivity. Qed.

Example sgs_pin :
  (prog_defmap mario_step.prog) ! mario_step._stationary_ground_step
  = Some (Gfun (Internal mario_step.f_stationary_ground_step)).
Proof. vm_compute. reflexivity. Qed.
Example sgs_vars : fn_vars mario_step.f_stationary_ground_step = nil.
Proof. vm_compute. reflexivity. Qed.
Example sgs_params_ok :
  match fn_params mario_step.f_stationary_ground_step with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sgs_walk :
  wwalk_chk false nil sgs_ids nil nil sgs_xids nil nil
    (fn_body mario_step.f_stationary_ground_step) = true.
Proof. vm_compute. reflexivity. Qed.

Example ccoc_pin :
  (prog_defmap mario_actions_object.prog)
    ! mario_actions_object._check_common_object_cancels
  = Some (Gfun
      (Internal mario_actions_object.f_check_common_object_cancels)).
Proof. vm_compute. reflexivity. Qed.
Example ccoc_vars :
  fn_vars mario_actions_object.f_check_common_object_cancels = nil.
Proof. vm_compute. reflexivity. Qed.
Example ccoc_params_ok :
  match fn_params mario_actions_object.f_check_common_object_cancels with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example ccoc_walk :
  wwalk_chk false nil ccoc_ids nil nil nil ccoc_sids nil
    (fn_body mario_actions_object.f_check_common_object_cancels) = true.
Proof. vm_compute. reflexivity. Qed.

(* POSITIVE CONTROL: the leaf census bites -- empty sids fails *)
Example ccoc_walk_not_vacuous :
  wwalk_chk false nil ccoc_ids nil nil nil nil nil
    (fn_body mario_actions_object.f_check_common_object_cancels) = false.
Proof. vm_compute. reflexivity. Qed.

(* ---- the five interaction-TU object helpers ---- *)

Example msrah_pin :
  (prog_defmap interaction.prog)
    ! interaction._mario_stop_riding_and_holding
  = Some (Gfun (Internal interaction.f_mario_stop_riding_and_holding)).
Proof. vm_compute. reflexivity. Qed.
Example msrah_vars :
  fn_vars interaction.f_mario_stop_riding_and_holding = nil.
Proof. vm_compute. reflexivity. Qed.
Example msrah_params_ok :
  match fn_params interaction.f_mario_stop_riding_and_holding with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example msrah_nonparam :
  forallb (fun t' => negb (mem_id t'
      (map fst (fn_params interaction.f_mario_stop_riding_and_holding))))
    msrah_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example msrah_walk :
  wwalk_chk false nil msrah_ids nil msrah_cact nil nil nil
    (fn_body interaction.f_mario_stop_riding_and_holding) = true.
Proof. vm_compute. reflexivity. Qed.

Example msro_pin :
  (prog_defmap interaction.prog) ! interaction._mario_stop_riding_object
  = Some (Gfun (Internal interaction.f_mario_stop_riding_object)).
Proof. vm_compute. reflexivity. Qed.
Example msro_vars :
  fn_vars interaction.f_mario_stop_riding_object = nil.
Proof. vm_compute. reflexivity. Qed.
Example msro_params_ok :
  match fn_params interaction.f_mario_stop_riding_object with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example msro_nonparam :
  forallb (fun t' => negb (mem_id t'
      (map fst (fn_params interaction.f_mario_stop_riding_object))))
    msro_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example msro_walk :
  wwalk_chk false nil nil nil msro_cact msro_xids nil nil
    (fn_body interaction.f_mario_stop_riding_object) = true.
Proof. vm_compute. reflexivity. Qed.

Example mdho_pin :
  (prog_defmap interaction.prog) ! interaction._mario_drop_held_object
  = Some (Gfun (Internal interaction.f_mario_drop_held_object)).
Proof. vm_compute. reflexivity. Qed.
Example mdho_vars :
  fn_vars interaction.f_mario_drop_held_object = nil.
Proof. vm_compute. reflexivity. Qed.
Example mdho_params_ok :
  match fn_params interaction.f_mario_drop_held_object with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example mdho_nonparam :
  forallb (fun t' => negb (mem_id t'
      (map fst (fn_params interaction.f_mario_drop_held_object))))
    mdho_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example mdho_walk :
  wwalk_chk false nil nil nil mdho_cact mdho_xids nil nil
    (fn_body interaction.f_mario_drop_held_object) = true.
Proof. vm_compute. reflexivity. Qed.

Example mtho_pin :
  (prog_defmap interaction.prog) ! interaction._mario_throw_held_object
  = Some (Gfun (Internal interaction.f_mario_throw_held_object)).
Proof. vm_compute. reflexivity. Qed.
Example mtho_vars :
  fn_vars interaction.f_mario_throw_held_object = nil.
Proof. vm_compute. reflexivity. Qed.
Example mtho_params_ok :
  match fn_params interaction.f_mario_throw_held_object with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example mtho_nonparam :
  forallb (fun t' => negb (mem_id t'
      (map fst (fn_params interaction.f_mario_throw_held_object))))
    mtho_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example mtho_walk :
  wwalk_chk false nil nil nil mtho_cact mdho_xids nil nil
    (fn_body interaction.f_mario_throw_held_object) = true.
Proof. vm_compute. reflexivity. Qed.

Example mguo_pin :
  (prog_defmap interaction.prog) ! interaction._mario_grab_used_object
  = Some (Gfun (Internal interaction.f_mario_grab_used_object)).
Proof. vm_compute. reflexivity. Qed.
Example mguo_vars :
  fn_vars interaction.f_mario_grab_used_object = nil.
Proof. vm_compute. reflexivity. Qed.
Example mguo_params_ok :
  match fn_params interaction.f_mario_grab_used_object with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example mguo_nonparam :
  forallb (fun t' => negb (mem_id t'
      (map fst (fn_params interaction.f_mario_grab_used_object))))
    mguo_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example mguo_walk :
  wwalk_chk false nil nil nil mguo_cact mguo_xids nil nil
    (fn_body interaction.f_mario_grab_used_object) = true.
Proof. vm_compute. reflexivity. Qed.

(* POSITIVE CONTROL: the chase census bites -- empty cact fails *)
Example msrah_walk_not_vacuous :
  wwalk_chk false nil msrah_ids nil nil nil nil nil
    (fn_body interaction.f_mario_stop_riding_and_holding) = false.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* The rows.                                                              *)
(* ====================================================================== *)

(* ---- set_mario_animation (B4): FOUR chase temps (the marioObj root
   _o, the animList roots _t'13/_t'12, and the chase-STEP temp
   _targetAnim = t'13->bufTarget), plus the EXTERNAL
   load_patchable_table callee.  Its two `(anim + off) & 0x1FFFFFFF`
   segmented-pointer mask stores are DEAD CODE in CompCert's semantics
   (the dead-mask walker arm discharges them by contradiction). ---- *)
Definition sma_cact : list ident :=
  mario._o :: mario._t'13 :: mario._t'12 :: mario._targetAnim :: nil.
Definition sma_xids : list ident :=
  mario._load_patchable_table :: nil.

Example sma_pin :
  (prog_defmap mario.prog) ! mario._set_mario_animation
  = Some (Gfun (Internal mario.f_set_mario_animation)).
Proof. vm_compute. reflexivity. Qed.

Example sma_vars : fn_vars mario.f_set_mario_animation = nil.
Proof. vm_compute. reflexivity. Qed.

Example sma_params_ok :
  match fn_params mario.f_set_mario_animation with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.

Example sma_nonparam :
  forallb (fun t' => negb (mem_id t'
             (map fst (fn_params mario.f_set_mario_animation))))
    sma_cact = true.
Proof. vm_compute. reflexivity. Qed.

Example sma_walk :
  wwalk_chk false nil nil nil sma_cact sma_xids nil nil
    (fn_body mario.f_set_mario_animation) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* B3: asgs (the act3-class helper) + the SIX object leaves it unlocks.   *)
(* ====================================================================== *)

(* asgs: sgs(m); sma(m, animation); t'1 := iaae(m);
   if (t'1) smact(m, endAction, 0).  The action is PARAM 3 (act3). *)
Definition asgs_wact : list ident := mario_actions_object._endAction :: nil.
Definition asgs_ids : list ident :=
  mario_step._stationary_ground_step :: mario._set_mario_animation
    :: mario._is_anim_at_end :: nil.

Example asgs_pin :
  (prog_defmap mario_actions_object.prog)
    ! mario_actions_object._animated_stationary_ground_step
  = Some (Gfun (Internal
           mario_actions_object.f_animated_stationary_ground_step)).
Proof. vm_compute. reflexivity. Qed.
Example asgs_vars :
  fn_vars mario_actions_object.f_animated_stationary_ground_step = nil.
Proof. vm_compute. reflexivity. Qed.
Example asgs_params :
  fn_params mario_actions_object.f_animated_stationary_ground_step
  = act3_params.
Proof. vm_compute. reflexivity. Qed.
Example asgs_walk :
  wwalk_chk false asgs_wact asgs_ids nil nil nil obj_sids nil
    (fn_body mario_actions_object.f_animated_stationary_ground_step) = true.
Proof. vm_compute. reflexivity. Qed.

(* the six leaves share ONE census (the walker only needs supersets):
   held-object helpers + play_sound_if_no_flag plain, dasma/smact
   writer-consts, and the asgs act3 call *)
Definition obj_leaf_ids : list ident :=
  interaction._mario_drop_held_object
    :: interaction._mario_throw_held_object
    :: mario._play_sound_if_no_flag :: nil.
Definition obj_leaf_sids : list ident :=
  mario._drop_and_set_mario_action :: mario._set_mario_action :: nil.
Definition obj_leaf_tids : list ident :=
  mario_actions_object._animated_stationary_ground_step :: nil.

Example adpu_pin :
  (prog_defmap mario_actions_object.prog)
    ! mario_actions_object._act_dive_picking_up
  = Some (Gfun (Internal mario_actions_object.f_act_dive_picking_up)).
Proof. vm_compute. reflexivity. Qed.
Example adpu_vars : fn_vars mario_actions_object.f_act_dive_picking_up = nil.
Proof. vm_compute. reflexivity. Qed.
Example adpu_params_ok :
  match fn_params mario_actions_object.f_act_dive_picking_up with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example adpu_walk :
  wwalk_chk false nil obj_leaf_ids nil nil nil obj_leaf_sids obj_leaf_tids
    (fn_body mario_actions_object.f_act_dive_picking_up) = true.
Proof. vm_compute. reflexivity. Qed.

Example asss_pin :
  (prog_defmap mario_actions_object.prog)
    ! mario_actions_object._act_stomach_slide_stop
  = Some (Gfun (Internal mario_actions_object.f_act_stomach_slide_stop)).
Proof. vm_compute. reflexivity. Qed.
Example asss_vars :
  fn_vars mario_actions_object.f_act_stomach_slide_stop = nil.
Proof. vm_compute. reflexivity. Qed.
Example asss_params_ok :
  match fn_params mario_actions_object.f_act_stomach_slide_stop with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example asss_walk :
  wwalk_chk false nil obj_leaf_ids nil nil nil obj_leaf_sids obj_leaf_tids
    (fn_body mario_actions_object.f_act_stomach_slide_stop) = true.
Proof. vm_compute. reflexivity. Qed.

Example apd_pin :
  (prog_defmap mario_actions_object.prog)
    ! mario_actions_object._act_placing_down
  = Some (Gfun (Internal mario_actions_object.f_act_placing_down)).
Proof. vm_compute. reflexivity. Qed.
Example apd_vars : fn_vars mario_actions_object.f_act_placing_down = nil.
Proof. vm_compute. reflexivity. Qed.
Example apd_params_ok :
  match fn_params mario_actions_object.f_act_placing_down with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example apd_walk :
  wwalk_chk false nil obj_leaf_ids nil nil nil obj_leaf_sids obj_leaf_tids
    (fn_body mario_actions_object.f_act_placing_down) = true.
Proof. vm_compute. reflexivity. Qed.

Example ath_pin :
  (prog_defmap mario_actions_object.prog)
    ! mario_actions_object._act_throwing
  = Some (Gfun (Internal mario_actions_object.f_act_throwing)).
Proof. vm_compute. reflexivity. Qed.
Example ath_vars : fn_vars mario_actions_object.f_act_throwing = nil.
Proof. vm_compute. reflexivity. Qed.
Example ath_params_ok :
  match fn_params mario_actions_object.f_act_throwing with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example ath_walk :
  wwalk_chk false nil obj_leaf_ids nil nil nil obj_leaf_sids obj_leaf_tids
    (fn_body mario_actions_object.f_act_throwing) = true.
Proof. vm_compute. reflexivity. Qed.

Example aht_pin :
  (prog_defmap mario_actions_object.prog)
    ! mario_actions_object._act_heavy_throw
  = Some (Gfun (Internal mario_actions_object.f_act_heavy_throw)).
Proof. vm_compute. reflexivity. Qed.
Example aht_vars : fn_vars mario_actions_object.f_act_heavy_throw = nil.
Proof. vm_compute. reflexivity. Qed.
Example aht_params_ok :
  match fn_params mario_actions_object.f_act_heavy_throw with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example aht_walk :
  wwalk_chk false nil obj_leaf_ids nil nil nil obj_leaf_sids obj_leaf_tids
    (fn_body mario_actions_object.f_act_heavy_throw) = true.
Proof. vm_compute. reflexivity. Qed.

Example arb_pin :
  (prog_defmap mario_actions_object.prog)
    ! mario_actions_object._act_releasing_bowser
  = Some (Gfun (Internal mario_actions_object.f_act_releasing_bowser)).
Proof. vm_compute. reflexivity. Qed.
Example arb_vars : fn_vars mario_actions_object.f_act_releasing_bowser = nil.
Proof. vm_compute. reflexivity. Qed.
Example arb_params_ok :
  match fn_params mario_actions_object.f_act_releasing_bowser with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example arb_walk :
  wwalk_chk false nil obj_leaf_ids nil nil nil obj_leaf_sids obj_leaf_tids
    (fn_body mario_actions_object.f_act_releasing_bowser) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* B5: the three grab-family leaves (chase censuses through the          *)
(* marioObj / marioBodyState roots; approach_s32 is EXTERNAL in lp).     *)
(* ====================================================================== *)

Definition apub_ids : list ident :=
  interaction._mario_grab_used_object
    :: mario_step._stationary_ground_step
    :: mario._set_mario_animation :: mario._is_anim_at_end :: nil.
Definition apub_xids : list ident := mario._play_sound :: nil.
Definition apub_cact : list ident :=
  mario_actions_object._t'4 :: mario_actions_object._t'3 :: nil.

Example apub_pin :
  (prog_defmap mario_actions_object.prog)
    ! mario_actions_object._act_picking_up_bowser
  = Some (Gfun (Internal mario_actions_object.f_act_picking_up_bowser)).
Proof. vm_compute. reflexivity. Qed.
Example apub_vars :
  fn_vars mario_actions_object.f_act_picking_up_bowser = nil.
Proof. vm_compute. reflexivity. Qed.
Example apub_params_ok :
  match fn_params mario_actions_object.f_act_picking_up_bowser with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example apub_nonparam :
  forallb (fun t' => negb (mem_id t'
             (map fst (fn_params
                mario_actions_object.f_act_picking_up_bowser))))
    apub_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example apub_walk :
  wwalk_chk false nil apub_ids nil apub_cact apub_xids obj_leaf_sids nil
    (fn_body mario_actions_object.f_act_picking_up_bowser) = true.
Proof. vm_compute. reflexivity. Qed.

Definition ahb_ids : list ident :=
  mario._set_mario_animation :: mario_step._stationary_ground_step :: nil.
Definition ahb_xids : list ident :=
  mario._play_sound :: mario_actions_object._approach_s32 :: nil.
Definition ahb_cact : list ident :=
  mario_actions_object._t'35 :: mario_actions_object._t'34
    :: mario_actions_object._t'16 :: mario_actions_object._t'13
    :: mario_actions_object._t'11 :: mario_actions_object._t'9 :: nil.

Example ahb_pin :
  (prog_defmap mario_actions_object.prog)
    ! mario_actions_object._act_holding_bowser
  = Some (Gfun (Internal mario_actions_object.f_act_holding_bowser)).
Proof. vm_compute. reflexivity. Qed.
Example ahb_vars :
  fn_vars mario_actions_object.f_act_holding_bowser = nil.
Proof. vm_compute. reflexivity. Qed.
Example ahb_params_ok :
  match fn_params mario_actions_object.f_act_holding_bowser with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example ahb_nonparam :
  forallb (fun t' => negb (mem_id t'
             (map fst (fn_params
                mario_actions_object.f_act_holding_bowser))))
    ahb_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example ahb_walk :
  wwalk_chk false nil ahb_ids nil ahb_cact ahb_xids obj_leaf_sids nil
    (fn_body mario_actions_object.f_act_holding_bowser) = true.
Proof. vm_compute. reflexivity. Qed.

Definition apu_ids : list ident :=
  mario._is_anim_at_end :: interaction._mario_grab_used_object
    :: mario._play_sound_if_no_flag :: mario._set_mario_animation
    :: mario_step._stationary_ground_step :: nil.
Definition apu_cact : list ident :=
  mario_actions_object._t'11 :: mario_actions_object._t'10 :: nil.

Example apu_pin :
  (prog_defmap mario_actions_object.prog)
    ! mario_actions_object._act_picking_up
  = Some (Gfun (Internal mario_actions_object.f_act_picking_up)).
Proof. vm_compute. reflexivity. Qed.
Example apu_vars :
  fn_vars mario_actions_object.f_act_picking_up = nil.
Proof. vm_compute. reflexivity. Qed.
Example apu_params_ok :
  match fn_params mario_actions_object.f_act_picking_up with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example apu_nonparam :
  forallb (fun t' => negb (mem_id t'
             (map fst (fn_params mario_actions_object.f_act_picking_up))))
    apu_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example apu_walk :
  wwalk_chk false nil apu_ids nil apu_cact nil obj_leaf_sids nil
    (fn_body mario_actions_object.f_act_picking_up) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* B6: the punching subtree -- the LAST object leaf.  mcog's fused pair  *)
(* (m->usedObj = m->interactObj) consumes the interactObj census row;    *)
(* mcog/mups carry LOCAL untainted action consts through wact temps      *)
(* (the wact entry).                                                     *)
(* ====================================================================== *)

(* is_anim_past_end: pure reader *)
Example ipae_pin :
  (prog_defmap mario.prog) ! mario._is_anim_past_end
  = Some (Gfun (Internal mario.f_is_anim_past_end)).
Proof. vm_compute. reflexivity. Qed.
Example ipae_vars : fn_vars mario.f_is_anim_past_end = nil.
Proof. vm_compute. reflexivity. Qed.
Example ipae_params_ok :
  match fn_params mario.f_is_anim_past_end with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example ipae_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario.f_is_anim_past_end) = true.
Proof. vm_compute. reflexivity. Qed.

(* mario_obj_angle_to_object: reader + atan2s (external) *)
Definition moato_xids : list ident := interaction._atan2s :: nil.
Example moato_pin :
  (prog_defmap interaction.prog) ! interaction._mario_obj_angle_to_object
  = Some (Gfun (Internal interaction.f_mario_obj_angle_to_object)).
Proof. vm_compute. reflexivity. Qed.
Example moato_vars :
  fn_vars interaction.f_mario_obj_angle_to_object = nil.
Proof. vm_compute. reflexivity. Qed.
Example moato_params_ok :
  match fn_params interaction.f_mario_obj_angle_to_object with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example moato_walk :
  wwalk_chk false nil nil nil nil moato_xids nil nil
    (fn_body interaction.f_mario_obj_angle_to_object) = true.
Proof. vm_compute. reflexivity. Qed.

(* play_sound_and_spawn_particles: m->particleFlags |= ... only *)
Definition psasp_xids : list ident := mario._play_sound :: nil.
Example psasp_pin :
  (prog_defmap mario.prog) ! mario._play_sound_and_spawn_particles
  = Some (Gfun (Internal mario.f_play_sound_and_spawn_particles)).
Proof. vm_compute. reflexivity. Qed.
Example psasp_vars :
  fn_vars mario.f_play_sound_and_spawn_particles = nil.
Proof. vm_compute. reflexivity. Qed.
Example psasp_params_ok :
  match fn_params mario.f_play_sound_and_spawn_particles with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example psasp_walk :
  wwalk_chk false nil nil nil nil psasp_xids nil nil
    (fn_body mario.f_play_sound_and_spawn_particles) = true.
Proof. vm_compute. reflexivity. Qed.

(* play_mario_action_sound: one flags |= store + the psasp call *)
Definition pmas_ids : list ident :=
  mario._play_sound_and_spawn_particles :: nil.
Example pmas_pin :
  (prog_defmap mario.prog) ! mario._play_mario_action_sound
  = Some (Gfun (Internal mario.f_play_mario_action_sound)).
Proof. vm_compute. reflexivity. Qed.
Example pmas_vars : fn_vars mario.f_play_mario_action_sound = nil.
Proof. vm_compute. reflexivity. Qed.
Example pmas_params_ok :
  match fn_params mario.f_play_mario_action_sound with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example pmas_walk :
  wwalk_chk false nil pmas_ids nil nil nil nil nil
    (fn_body mario.f_play_mario_action_sound) = true.
Proof. vm_compute. reflexivity. Qed.

(* mario_check_object_grab: the fused pair (usedObj <- interactObj),
   the faceAngle[1] idx16 store, and a TEMP-carried untainted action *)
Definition mcog_ids : list ident :=
  interaction._mario_obj_angle_to_object :: nil.
Definition mcog_cact : list ident :=
  interaction._t'13 :: interaction._t'10 :: nil.
Definition mcog_wact : list ident := interaction._t'5 :: nil.
Definition mcog_xids : list ident :=
  interaction._virtual_to_segmented :: nil.
Example mcog_pin :
  (prog_defmap interaction.prog) ! interaction._mario_check_object_grab
  = Some (Gfun (Internal interaction.f_mario_check_object_grab)).
Proof. vm_compute. reflexivity. Qed.
Example mcog_vars : fn_vars interaction.f_mario_check_object_grab = nil.
Proof. vm_compute. reflexivity. Qed.
Example mcog_params_ok :
  match fn_params interaction.f_mario_check_object_grab with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example mcog_nonparam :
  forallb (fun t' => negb (mem_id t'
             (map fst (fn_params interaction.f_mario_check_object_grab))))
    mcog_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example mcog_nonparamw :
  forallb (fun t' => negb (mem_id t'
             (map fst (fn_params interaction.f_mario_check_object_grab))))
    mcog_wact = true.
Proof. vm_compute. reflexivity. Qed.
Example mcog_walk :
  wwalk_chk false mcog_wact mcog_ids nil mcog_cact mcog_xids
    obj_leaf_sids nil
    (fn_body interaction.f_mario_check_object_grab) = true.
Proof. vm_compute. reflexivity. Qed.

(* mario_update_punch_sequence: the big sequencer; endAction /
   crouchEndAction carry untainted consts into the smact calls *)
Definition mups_ids : list ident :=
  mario._is_anim_at_end :: mario._is_anim_past_end
    :: interaction._mario_check_object_grab
    :: mario._play_mario_action_sound
    :: mario._set_mario_animation :: nil.
Definition mups_cact : list ident :=
  mario_actions_object._t'31 :: mario_actions_object._t'21
    :: mario_actions_object._t'15 :: nil.
Definition mups_wact : list ident :=
  mario_actions_object._endAction
    :: mario_actions_object._crouchEndAction :: nil.
Definition mups_xids : list ident := mario._play_sound :: nil.
Example mups_pin :
  (prog_defmap mario_actions_object.prog)
    ! mario_actions_object._mario_update_punch_sequence
  = Some (Gfun (Internal
            mario_actions_object.f_mario_update_punch_sequence)).
Proof. vm_compute. reflexivity. Qed.
Example mups_vars :
  fn_vars mario_actions_object.f_mario_update_punch_sequence = nil.
Proof. vm_compute. reflexivity. Qed.
Example mups_params_ok :
  match fn_params mario_actions_object.f_mario_update_punch_sequence with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example mups_nonparam :
  forallb (fun t' => negb (mem_id t'
             (map fst (fn_params
                mario_actions_object.f_mario_update_punch_sequence))))
    mups_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example mups_nonparamw :
  forallb (fun t' => negb (mem_id t'
             (map fst (fn_params
                mario_actions_object.f_mario_update_punch_sequence))))
    mups_wact = true.
Proof. vm_compute. reflexivity. Qed.
Example mups_walk :
  wwalk_chk false mups_wact mups_ids nil mups_cact mups_xids
    obj_leaf_sids nil
    (fn_body mario_actions_object.f_mario_update_punch_sequence) = true.
Proof. vm_compute. reflexivity. Qed.

(* act_punching itself *)
Definition apun_ids : list ident :=
  mario._check_common_action_exits :: mario._mario_set_forward_vel
    :: mario_actions_object._mario_update_punch_sequence
    :: mario_step._perform_ground_step :: nil.
Example apun_pin :
  (prog_defmap mario_actions_object.prog)
    ! mario_actions_object._act_punching
  = Some (Gfun (Internal mario_actions_object.f_act_punching)).
Proof. vm_compute. reflexivity. Qed.
Example apun_vars : fn_vars mario_actions_object.f_act_punching = nil.
Proof. vm_compute. reflexivity. Qed.
Example apun_params_ok :
  match fn_params mario_actions_object.f_act_punching with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example apun_walk :
  wwalk_chk false nil apun_ids nil nil nil obj_leaf_sids nil
    (fn_body mario_actions_object.f_act_punching) = true.
Proof. vm_compute. reflexivity. Qed.

Section ObjectLeafRows.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_mario_step : linkorder mario_step.prog lp.
  Hypothesis LO_int : linkorder interaction.prog lp.
  Hypothesis LO_obj : linkorder mario_actions_object.prog lp.

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
  (* SafeB is load-closed (MWF R7): instantiated by mwf_real_chase_step *)
  Hypothesis HchaseStep : forall m b ofs b' o',
      MWF m -> SafeB b ->
      Mem.loadv Mptr m (Vptr b ofs) = Some (Vptr b' o') ->
      SafeB b'.
  (* a SafeB-IF-POINTER store into a SafeB block: mwf_real_chase_ptr *)
  Hypothesis HMWF_chase_safe : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv = Vptr bb oo -> SafeB bb) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.

  (* ---- the NAMED per-symbol residuals this surface still rests on ---- *)

  (* external (in lp) callees: the same model class as warp_ext_ids *)
  Hypothesis Hcpx_psound :
    call_pres_ext lp bm NoA MWF mario._play_sound.
  Hypothesis Hcpx_v3s :
    call_pres_ext lp bm NoA MWF mario._vec3s_set.
  Hypothesis Hcpx_v3f :
    call_pres_ext lp bm NoA MWF mario_step._vec3f_copy.
  Hypothesis Hcpx_scm :
    call_pres_ext lp bm NoA MWF mario._set_camera_mode.
  Hypothesis Hcpx_s2v :
    call_pres_ext lp bm NoA MWF interaction._segmented_to_virtual.
  Hypothesis Hcpx_ssm :
    call_pres_ext lp bm NoA MWF interaction._stop_shell_music.
  Hypothesis Hcpx_oshs :
    call_pres_ext lp bm NoA MWF interaction._obj_set_held_state.
  Hypothesis Hcpx_lpt :
    call_pres_ext lp bm NoA MWF mario._load_patchable_table.
  Hypothesis Hcpx_as32 :
    call_pres_ext lp bm NoA MWF mario_actions_object._approach_s32.
  Hypothesis Hcpx_atan2s :
    call_pres_ext lp bm NoA MWF interaction._atan2s.
  Hypothesis Hcpx_v2seg :
    call_pres_ext lp bm NoA MWF interaction._virtual_to_segmented.

  (* internal, deferred to later slices (named blockers in the header) *)
  Hypothesis Hcp_pgs :
    call_pres lp bm NoA MWF mario_step._perform_ground_step.

  (* the keystone, instantiated once *)
  Let Hsmact : call_pres_act lp bm NoA MWF mario._set_mario_action :=
    smact_pres lp LO_mario LO_mario_step bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe.

  Lemma obj_sids_rows : forall fid, mem_id fid obj_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold obj_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.

  (* ---- play_sound_if_no_flag ---- *)
  Lemma psinf_row : call_pres lp bm NoA MWF mario._play_sound_if_no_flag.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe mario.prog mario._play_sound_if_no_flag
             mario.f_play_sound_if_no_flag nil nil psinf_xids nil
             LO_mario psinf_pin psinf_vars psinf_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold psinf_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_psound | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - exact psinf_walk.
  Qed.

  (* ---- play_mario_jump_sound (flags window store + play_sound external) ---- *)
  Lemma pmjs_row : call_pres lp bm NoA MWF mario._play_mario_jump_sound.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe mario.prog mario._play_mario_jump_sound
             mario.f_play_mario_jump_sound nil nil pmjs_xids nil
             LO_mario pmjs_pin pmjs_vars pmjs_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold pmjs_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_psound | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - exact pmjs_walk.
  Qed.

  (* ---- is_anim_at_end (loads only; chase DEPTH is free on loads) ---- *)
  Lemma iaae_row : call_pres lp bm NoA MWF mario._is_anim_at_end.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe mario.prog mario._is_anim_at_end
             mario.f_is_anim_at_end nil nil nil nil
             LO_mario iaae_pin iaae_vars iaae_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact iaae_walk.
  Qed.

  (* ---- check_common_action_exits (four smact-const exits) ---- *)
  Lemma ccae_row :
    call_pres lp bm NoA MWF mario._check_common_action_exits.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe mario.prog mario._check_common_action_exits
             mario.f_check_common_action_exits nil nil nil obj_sids
             LO_mario ccae_pin ccae_vars ccae_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact obj_sids_rows.
    - exact ccae_walk.
  Qed.

  (* ---- set_water_plunge_action ---- *)
  Lemma swpa_row :
    call_pres lp bm NoA MWF mario._set_water_plunge_action.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe mario.prog mario._set_water_plunge_action
             mario.f_set_water_plunge_action nil nil swpa_xids obj_sids
             LO_mario swpa_pin swpa_vars swpa_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold swpa_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_v3s | ].
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_scm | ].
      discriminate H.
    - exact obj_sids_rows.
    - exact swpa_walk.
  Qed.

  (* ---- the two mario_step updaters (walk EMPTY: no calls, all
     window/idx stores) ---- *)
  Lemma mums_row :
    call_pres lp bm NoA MWF mario_step._mario_update_moving_sand.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe mario_step.prog
             mario_step._mario_update_moving_sand
             mario_step.f_mario_update_moving_sand nil nil nil nil
             LO_mario_step mums_pin mums_vars mums_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mums_walk.
  Qed.

  Lemma muwg_row :
    call_pres lp bm NoA MWF mario_step._mario_update_windy_ground.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe mario_step.prog
             mario_step._mario_update_windy_ground
             mario_step.f_mario_update_windy_ground nil nil nil nil
             LO_mario_step muwg_pin muwg_vars muwg_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact muwg_walk.
  Qed.

  (* ==================================================================
     The FIVE interaction-TU object helpers (the B2b slice): chase
     stores through heldObj/usedObj/riddenObj (the cact censuses), root
     stores BACK into those cells (the HMWF_root row), the fused
     gGlobalTimer / sub-word pairs, and the Oshl rhs class.  Together
     they DELETE the Hcp_msrah residual.
     ================================================================== *)

  Lemma mdho_row :
    call_pres lp bm NoA MWF interaction._mario_drop_held_object.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe interaction.prog
             interaction._mario_drop_held_object
             interaction.f_mario_drop_held_object
             nil nil mdho_cact mdho_xids nil
             LO_int mdho_pin mdho_vars mdho_params_ok mdho_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold mdho_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_s2v | ].
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_oshs | ].
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_ssm | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - exact mdho_walk.
  Qed.

  Lemma mtho_row :
    call_pres lp bm NoA MWF interaction._mario_throw_held_object.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe interaction.prog
             interaction._mario_throw_held_object
             interaction.f_mario_throw_held_object
             nil nil mtho_cact mdho_xids nil
             LO_int mtho_pin mtho_vars mtho_params_ok mtho_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold mdho_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_s2v | ].
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_oshs | ].
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_ssm | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - exact mtho_walk.
  Qed.

  Lemma msro_row :
    call_pres lp bm NoA MWF interaction._mario_stop_riding_object.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe interaction.prog
             interaction._mario_stop_riding_object
             interaction.f_mario_stop_riding_object
             nil nil msro_cact msro_xids nil
             LO_int msro_pin msro_vars msro_params_ok msro_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold msro_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_ssm | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - exact msro_walk.
  Qed.

  Lemma mguo_row :
    call_pres lp bm NoA MWF interaction._mario_grab_used_object.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe interaction.prog
             interaction._mario_grab_used_object
             interaction.f_mario_grab_used_object
             nil nil mguo_cact mguo_xids nil
             LO_int mguo_pin mguo_vars mguo_params_ok mguo_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold mguo_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_oshs | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - exact mguo_walk.
  Qed.

  Lemma msrah_ids_rows : forall fid, mem_id fid msrah_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold msrah_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mdho_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact msro_row | ].
    discriminate H.
  Qed.

  (* the former Hcp_msrah residual, now a PROVED row *)
  Lemma msrah_row :
    call_pres lp bm NoA MWF interaction._mario_stop_riding_and_holding.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe interaction.prog
             interaction._mario_stop_riding_and_holding
             interaction.f_mario_stop_riding_and_holding
             msrah_ids nil msrah_cact nil nil
             LO_int msrah_pin msrah_vars msrah_params_ok msrah_nonparam).
    - exact msrah_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact msrah_walk.
  Qed.

  (* ---- drop_and_set_mario_action: the SECOND act writer.  Same
     writer_params shape; body = mario_stop_riding_and_holding(m) then
     a tail call into set_mario_action with its own (censused) action
     temp -- the wids arm consumes the keystone. ---- *)
  Lemma dasma_ids_rows : forall fid, mem_id fid dasma_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold dasma_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact msrah_row | ].
    discriminate H.
  Qed.

  Lemma dasma_wids_rows : forall fid, mem_id fid dasma_wids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold dasma_wids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.

  Lemma dasma_row :
    call_pres_act lp bm NoA MWF mario._drop_and_set_mario_action.
  Proof.
    apply (call_pres_act_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe mario.prog _ mario.f_drop_and_set_mario_action
             dasma_wact dasma_ids dasma_wids nil nil nil
             LO_mario dasma_pin dasma_vars dasma_params dasma_ret
             eq_refl eq_refl eq_refl eq_refl eq_refl eq_refl).
    - exact dasma_ids_rows.
    - exact dasma_wids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact dasma_walk.
  Qed.

  (* ---- set_mario_animation (B4): the chase-step Sset arm, the
     curAnim pointer-chase store, and the two dead mask stores; the
     one callee is the EXTERNAL load_patchable_table. ---- *)
  Lemma sma_xids_rows : forall fid, mem_id fid sma_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sma_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_lpt | ].
    discriminate H.
  Qed.

  Lemma sma_row :
    call_pres lp bm NoA MWF mario._set_mario_animation.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._set_mario_animation
             mario.f_set_mario_animation
             nil nil sma_cact sma_xids nil
             LO_mario sma_pin sma_vars sma_params_ok sma_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sma_xids_rows.
    - intros fid' H. discriminate H.
    - exact sma_walk.
  Qed.

  (* ---- stationary_ground_step (the only deferred callee is
     perform_ground_step) ---- *)
  Lemma sgs_ids_rows : forall fid, mem_id fid sgs_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sgs_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (msfv_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                 HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
                 HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe) | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mums_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact muwg_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | ].
    discriminate H.
  Qed.

  Lemma sgs_xids_rows : forall fid, mem_id fid sgs_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sgs_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3f | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3s | ].
    discriminate H.
  Qed.

  Lemma sgs_row :
    call_pres lp bm NoA MWF mario_step._stationary_ground_step.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe mario_step.prog
             mario_step._stationary_ground_step
             mario_step.f_stationary_ground_step sgs_ids nil sgs_xids nil
             LO_mario_step sgs_pin sgs_vars sgs_params_ok).
    - exact sgs_ids_rows.
    - intros fid' H. discriminate H.
    - exact sgs_xids_rows.
    - intros fid' H. discriminate H.
    - exact sgs_walk.
  Qed.

  (* ==================================================================
     THE FIRST LEAF: check_common_object_cancels.  Its whole helper
     tree is proved above (swpa + dasma + the smact keystone), so its
     body_pres row -- the exact shape the capstone's object hypothesis
     quantifies over -- closes with no per-leaf residual.
     ================================================================== *)

  Lemma ccoc_ids_rows : forall fid, mem_id fid ccoc_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold ccoc_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact swpa_row | ].
    discriminate H.
  Qed.

  Lemma ccoc_sids_rows : forall fid, mem_id fid ccoc_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold ccoc_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact dasma_row | ].
    discriminate H.
  Qed.

  Lemma ccoc_pres :
    body_pres lp NoA MWF bm
      mario_actions_object.f_check_common_object_cancels.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_object.f_check_common_object_cancels
             ccoc_ids nil nil ccoc_sids nil ccoc_vars ccoc_params_ok).
    - exact ccoc_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact ccoc_sids_rows.
    - intros fid' H. discriminate H.
    - exact ccoc_walk.
  Qed.

  (* ==================================================================
     B3: the asgs act3 row, then the six leaves that consume it.
     ================================================================== *)
  Lemma asgs_ids_rows : forall fid, mem_id fid asgs_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold asgs_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sgs_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact iaae_row | ].
    discriminate H.
  Qed.

  Lemma asgs_row :
    call_pres_act3 lp bm NoA MWF
      mario_actions_object._animated_stationary_ground_step.
  Proof.
    apply (call_pres_act3_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_object.prog _
             mario_actions_object.f_animated_stationary_ground_step
             asgs_wact asgs_ids nil nil nil obj_sids
             LO_obj asgs_pin asgs_vars asgs_params
             eq_refl eq_refl eq_refl eq_refl eq_refl eq_refl).
    - exact asgs_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact obj_sids_rows.
    - exact asgs_walk.
  Qed.

  (* the shared six-leaf row bundles *)
  Lemma obj_leaf_ids_rows : forall fid, mem_id fid obj_leaf_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold obj_leaf_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mdho_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mtho_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact psinf_row | ].
    discriminate H.
  Qed.

  Lemma obj_leaf_sids_rows : forall fid, mem_id fid obj_leaf_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold obj_leaf_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact dasma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.

  Lemma obj_leaf_tids_rows : forall fid, mem_id fid obj_leaf_tids = true ->
      call_pres_act3 lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold obj_leaf_tids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact asgs_row | ].
    discriminate H.
  Qed.

  Lemma adpu_pres :
    body_pres lp NoA MWF bm mario_actions_object.f_act_dive_picking_up.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_object.f_act_dive_picking_up
             obj_leaf_ids nil nil obj_leaf_sids obj_leaf_tids
             adpu_vars adpu_params_ok).
    - exact obj_leaf_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact obj_leaf_sids_rows.
    - exact obj_leaf_tids_rows.
    - exact adpu_walk.
  Qed.

  Lemma asss_pres :
    body_pres lp NoA MWF bm mario_actions_object.f_act_stomach_slide_stop.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_object.f_act_stomach_slide_stop
             obj_leaf_ids nil nil obj_leaf_sids obj_leaf_tids
             asss_vars asss_params_ok).
    - exact obj_leaf_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact obj_leaf_sids_rows.
    - exact obj_leaf_tids_rows.
    - exact asss_walk.
  Qed.

  Lemma apd_pres :
    body_pres lp NoA MWF bm mario_actions_object.f_act_placing_down.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_object.f_act_placing_down
             obj_leaf_ids nil nil obj_leaf_sids obj_leaf_tids
             apd_vars apd_params_ok).
    - exact obj_leaf_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact obj_leaf_sids_rows.
    - exact obj_leaf_tids_rows.
    - exact apd_walk.
  Qed.

  Lemma ath_pres :
    body_pres lp NoA MWF bm mario_actions_object.f_act_throwing.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_object.f_act_throwing
             obj_leaf_ids nil nil obj_leaf_sids obj_leaf_tids
             ath_vars ath_params_ok).
    - exact obj_leaf_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact obj_leaf_sids_rows.
    - exact obj_leaf_tids_rows.
    - exact ath_walk.
  Qed.

  Lemma aht_pres :
    body_pres lp NoA MWF bm mario_actions_object.f_act_heavy_throw.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_object.f_act_heavy_throw
             obj_leaf_ids nil nil obj_leaf_sids obj_leaf_tids
             aht_vars aht_params_ok).
    - exact obj_leaf_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact obj_leaf_sids_rows.
    - exact obj_leaf_tids_rows.
    - exact aht_walk.
  Qed.

  Lemma arb_pres :
    body_pres lp NoA MWF bm mario_actions_object.f_act_releasing_bowser.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_object.f_act_releasing_bowser
             obj_leaf_ids nil nil obj_leaf_sids obj_leaf_tids
             arb_vars arb_params_ok).
    - exact obj_leaf_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact obj_leaf_sids_rows.
    - exact obj_leaf_tids_rows.
    - exact arb_walk.
  Qed.

  (* ==================================================================
     B5: the three grab-family leaves.  All fn_vars = nil, all chase
     roots tabled, approach_s32 EXTERNAL in lp -- the existing cact
     walker closes them with no new machinery.
     ================================================================== *)
  Lemma apub_ids_rows : forall fid, mem_id fid apub_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold apub_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mguo_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sgs_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact iaae_row | ].
    discriminate H.
  Qed.

  Lemma apub_pres :
    body_pres lp NoA MWF bm mario_actions_object.f_act_picking_up_bowser.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_object.f_act_picking_up_bowser
             apub_ids nil apub_cact apub_xids obj_leaf_sids nil
             apub_vars apub_params_ok apub_nonparam).
    - exact apub_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold apub_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_psound | ].
      discriminate H.
    - exact obj_leaf_sids_rows.
    - intros fid' H. discriminate H.
    - exact apub_walk.
  Qed.

  Lemma ahb_ids_rows : forall fid, mem_id fid ahb_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold ahb_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sgs_row | ].
    discriminate H.
  Qed.

  Lemma ahb_pres :
    body_pres lp NoA MWF bm mario_actions_object.f_act_holding_bowser.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_object.f_act_holding_bowser
             ahb_ids nil ahb_cact ahb_xids obj_leaf_sids nil
             ahb_vars ahb_params_ok ahb_nonparam).
    - exact ahb_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold ahb_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_psound | ].
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_as32 | ].
      discriminate H.
    - exact obj_leaf_sids_rows.
    - intros fid' H. discriminate H.
    - exact ahb_walk.
  Qed.

  Lemma apu_ids_rows : forall fid, mem_id fid apu_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold apu_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact iaae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mguo_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact psinf_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sgs_row | ].
    discriminate H.
  Qed.

  Lemma apu_pres :
    body_pres lp NoA MWF bm mario_actions_object.f_act_picking_up.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_object.f_act_picking_up
             apu_ids nil apu_cact nil obj_leaf_sids nil
             apu_vars apu_params_ok apu_nonparam).
    - exact apu_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact obj_leaf_sids_rows.
    - intros fid' H. discriminate H.
    - exact apu_walk.
  Qed.

  (* ==================================================================
     B6: the punching subtree -- the LAST leaf.  ipae/moato/psasp/pmas
     walk plainly; mcog and mups carry local untainted action consts
     through wact temps (the wact entry); apun consumes the whole tree
     plus the ccae row and Hcp_pgs.
     ================================================================== *)
  Lemma ipae_row : call_pres lp bm NoA MWF mario._is_anim_past_end.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._is_anim_past_end
             mario.f_is_anim_past_end nil nil nil nil
             LO_mario ipae_pin ipae_vars ipae_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact ipae_walk.
  Qed.

  Lemma moato_row :
    call_pres lp bm NoA MWF interaction._mario_obj_angle_to_object.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             interaction.prog interaction._mario_obj_angle_to_object
             interaction.f_mario_obj_angle_to_object
             nil nil moato_xids nil
             LO_int moato_pin moato_vars moato_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold moato_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_atan2s | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - exact moato_walk.
  Qed.

  Lemma psasp_row :
    call_pres lp bm NoA MWF mario._play_sound_and_spawn_particles.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._play_sound_and_spawn_particles
             mario.f_play_sound_and_spawn_particles
             nil nil psasp_xids nil
             LO_mario psasp_pin psasp_vars psasp_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold psasp_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_psound | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - exact psasp_walk.
  Qed.

  Lemma pmas_row :
    call_pres lp bm NoA MWF mario._play_mario_action_sound.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._play_mario_action_sound
             mario.f_play_mario_action_sound
             pmas_ids nil nil nil
             LO_mario pmas_pin pmas_vars pmas_params_ok).
    - intros fid' H. unfold pmas_ids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact psasp_row | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact pmas_walk.
  Qed.

  Lemma mcog_row :
    call_pres lp bm NoA MWF interaction._mario_check_object_grab.
  Proof.
    apply (call_pres_of_wwalk_wact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             interaction.prog interaction._mario_check_object_grab
             interaction.f_mario_check_object_grab
             mcog_wact mcog_ids nil mcog_cact mcog_xids obj_leaf_sids
             LO_int mcog_pin mcog_vars mcog_params_ok mcog_nonparam
             mcog_nonparamw).
    - intros fid' H. unfold mcog_ids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact moato_row | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold mcog_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_v2seg | ].
      discriminate H.
    - exact obj_leaf_sids_rows.
    - exact mcog_walk.
  Qed.

  Lemma mups_ids_rows : forall fid, mem_id fid mups_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mups_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact iaae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact ipae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mcog_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact pmas_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sma_row | ].
    discriminate H.
  Qed.

  Lemma mups_row :
    call_pres lp bm NoA MWF
      mario_actions_object._mario_update_punch_sequence.
  Proof.
    apply (call_pres_of_wwalk_wact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_object.prog
             mario_actions_object._mario_update_punch_sequence
             mario_actions_object.f_mario_update_punch_sequence
             mups_wact mups_ids nil mups_cact mups_xids obj_leaf_sids
             LO_obj mups_pin mups_vars mups_params_ok mups_nonparam
             mups_nonparamw).
    - exact mups_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold mups_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_psound | ].
      discriminate H.
    - exact obj_leaf_sids_rows.
    - exact mups_walk.
  Qed.

  Lemma apun_ids_rows : forall fid, mem_id fid apun_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold apun_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact ccae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (msfv_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                 HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
                 HMWF_chase HMWF_root HMWF_sglob HchaseStep
                 HMWF_chase_safe) | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mups_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | ].
    discriminate H.
  Qed.

  Lemma apun_pres :
    body_pres lp NoA MWF bm mario_actions_object.f_act_punching.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_object.f_act_punching
             apun_ids nil nil obj_leaf_sids nil
             apun_vars apun_params_ok).
    - exact apun_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact obj_leaf_sids_rows.
    - intros fid' H. discriminate H.
    - exact apun_walk.
  Qed.

  (* ==================================================================
     THE CAPSTONE REDUCTION: the 11-id object census is FULLY DISCHARGED
     (ccoc + the six B3 leaves + the three B5 grab leaves + the B6
     punching subtree).  No residual census remains: this is what
     NoAImpliesNoFlyLinked consumes in place of the old 11-id hypothesis.
     ================================================================== *)
  Lemma object_callees_pres :
    forall fid f,
      mem_id fid object_callee_ids = true ->
      (prog_defmap mario_actions_object.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f.
  Proof.
    intros fid f H Hdm.
    unfold object_callee_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite ccoc_pin in Hdm. injection Hdm as <-. exact ccoc_pres. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite apun_pin in Hdm. injection Hdm as <-. exact apun_pres. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite apu_pin in Hdm. injection Hdm as <-. exact apu_pres. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite adpu_pin in Hdm. injection Hdm as <-. exact adpu_pres. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite asss_pin in Hdm. injection Hdm as <-. exact asss_pres. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite apd_pin in Hdm. injection Hdm as <-. exact apd_pres. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite ath_pin in Hdm. injection Hdm as <-. exact ath_pres. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite aht_pin in Hdm. injection Hdm as <-. exact aht_pres. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite apub_pin in Hdm. injection Hdm as <-. exact apub_pres. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite ahb_pin in Hdm. injection Hdm as <-. exact ahb_pres. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite arb_pin in Hdm. injection Hdm as <-. exact arb_pres. }
    discriminate H.
  Qed.

End ObjectLeafRows.
