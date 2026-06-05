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
  mario_actions_airborne mario_actions_object.
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

(* the capstone's object census MINUS the discharged leaf *)
Definition object_callee_ids_rest : list ident :=
  mario_actions_object._act_punching
    :: mario_actions_object._act_picking_up
    :: mario_actions_object._act_dive_picking_up
    :: mario_actions_object._act_stomach_slide_stop
    :: mario_actions_object._act_placing_down
    :: mario_actions_object._act_throwing
    :: mario_actions_object._act_heavy_throw
    :: mario_actions_object._act_picking_up_bowser
    :: mario_actions_object._act_holding_bowser
    :: mario_actions_object._act_releasing_bowser :: nil.

(* the object family's EXTERNAL leaf rows (the warp_ext_ids model class);
   grows as further leaves discharge *)
Definition obj_ext_ids : list ident :=
  mario._vec3s_set :: mario._set_camera_mode
    :: interaction._segmented_to_virtual
    :: interaction._stop_shell_music
    :: interaction._obj_set_held_state :: nil.

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
  wwalk_chk false nil nil nil nil psinf_xids nil
    (fn_body mario.f_play_sound_if_no_flag) = true.
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
  wwalk_chk false nil nil nil nil nil nil
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
  wwalk_chk false nil nil nil nil nil obj_sids
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
  wwalk_chk false nil nil nil nil swpa_xids obj_sids
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
  wwalk_chk false nil nil nil nil nil nil
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
  wwalk_chk false nil nil nil nil nil nil
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
  wwalk_chk true dasma_wact dasma_ids dasma_wids nil nil nil
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
  wwalk_chk false nil sgs_ids nil nil sgs_xids nil
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
  wwalk_chk false nil ccoc_ids nil nil nil ccoc_sids
    (fn_body mario_actions_object.f_check_common_object_cancels) = true.
Proof. vm_compute. reflexivity. Qed.

(* POSITIVE CONTROL: the leaf census bites -- empty sids fails *)
Example ccoc_walk_not_vacuous :
  wwalk_chk false nil ccoc_ids nil nil nil nil
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
  wwalk_chk false nil msrah_ids nil msrah_cact nil nil
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
  wwalk_chk false nil nil nil msro_cact msro_xids nil
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
  wwalk_chk false nil nil nil mdho_cact mdho_xids nil
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
  wwalk_chk false nil nil nil mtho_cact mdho_xids nil
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
  wwalk_chk false nil nil nil mguo_cact mguo_xids nil
    (fn_body interaction.f_mario_grab_used_object) = true.
Proof. vm_compute. reflexivity. Qed.

(* POSITIVE CONTROL: the chase census bites -- empty cact fails *)
Example msrah_walk_not_vacuous :
  wwalk_chk false nil msrah_ids nil nil nil nil
    (fn_body interaction.f_mario_stop_riding_and_holding) = false.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* The rows.                                                              *)
(* ====================================================================== *)

Section ObjectLeafRows.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_mario_step : linkorder mario_step.prog lp.
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

  (* internal, deferred to later slices (named blockers in the header) *)
  Hypothesis Hcp_pgs :
    call_pres lp bm NoA MWF mario_step._perform_ground_step.

  (* the keystone, instantiated once *)
  Let Hsmact : call_pres_act lp bm NoA MWF mario._set_mario_action :=
    smact_pres lp LO_mario LO_mario_step bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob.

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
             HMWF_chase HMWF_root HMWF_sglob mario.prog mario._play_sound_if_no_flag
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

  (* ---- is_anim_at_end (loads only; chase DEPTH is free on loads) ---- *)
  Lemma iaae_row : call_pres lp bm NoA MWF mario._is_anim_at_end.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob mario.prog mario._is_anim_at_end
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
             HMWF_chase HMWF_root HMWF_sglob mario.prog mario._check_common_action_exits
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
             HMWF_chase HMWF_root HMWF_sglob mario.prog mario._set_water_plunge_action
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
             HMWF_chase HMWF_root HMWF_sglob mario_step.prog
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
             HMWF_chase HMWF_root HMWF_sglob mario_step.prog
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
             HMWF_chase HMWF_root HMWF_sglob interaction.prog
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
             HMWF_chase HMWF_root HMWF_sglob interaction.prog
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
             HMWF_chase HMWF_root HMWF_sglob interaction.prog
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
             HMWF_chase HMWF_root HMWF_sglob interaction.prog
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
             HMWF_chase HMWF_root HMWF_sglob interaction.prog
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
             HMWF_chase HMWF_root HMWF_sglob mario.prog _ mario.f_drop_and_set_mario_action
             dasma_wact dasma_ids dasma_wids nil nil nil
             LO_mario dasma_pin dasma_vars dasma_params dasma_ret
             eq_refl eq_refl eq_refl eq_refl eq_refl eq_refl).
    - exact dasma_ids_rows.
    - exact dasma_wids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact dasma_walk.
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
                 HMWF_chase HMWF_root HMWF_sglob) | ].
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
             HMWF_chase HMWF_root HMWF_sglob mario_step.prog
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
             HMWF_chase HMWF_root HMWF_sglob
             mario_actions_object.f_check_common_object_cancels
             ccoc_ids nil nil ccoc_sids ccoc_vars ccoc_params_ok).
    - exact ccoc_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact ccoc_sids_rows.
    - exact ccoc_walk.
  Qed.

  (* ==================================================================
     THE CAPSTONE REDUCTION: the 11-id object census collapses to the
     10 undischarged leaves.  This is what NoAImpliesNoFlyLinked
     consumes in place of the old 11-id hypothesis.
     ================================================================== *)
  Lemma object_callees_pres :
    (forall fid f,
        mem_id fid object_callee_ids_rest = true ->
        (prog_defmap mario_actions_object.prog) ! fid
          = Some (Gfun (Internal f)) ->
        body_pres lp NoA MWF bm f) ->
    forall fid f,
      mem_id fid object_callee_ids = true ->
      (prog_defmap mario_actions_object.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f.
  Proof.
    intros Hrest fid f H Hdm.
    unfold object_callee_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H].
    - apply Pos.eqb_eq in Hm. subst fid.
      rewrite ccoc_pin in Hdm. injection Hdm as <-.
      exact ccoc_pres.
    - apply (Hrest fid f); [ | exact Hdm ].
      unfold object_callee_ids_rest. cbn [mem_id existsb]. exact H.
  Qed.

End ObjectLeafRows.
