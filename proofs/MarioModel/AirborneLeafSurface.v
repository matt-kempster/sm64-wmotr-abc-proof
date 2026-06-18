(* ====================================================================== *)
(* THE AIRBORNE-FAMILY LEAF SURFACE                                        *)
(* (SPINE: airborne_leaf_callees_pres shrinks the capstone's               *)
(*  Hpres_air_callees down to a per-leaf census rest-split).               *)
(*                                                                         *)
(* AirborneSurface.airborne_pres walks the 43-arm dispatcher and reduces   *)
(* it to ONE residual: body_pres for every leaf callee in                  *)
(* airborne_callee_ids (43 ids -- 41 act handlers + 2 prologue helpers).   *)
(* Here we discharge those leaves one cluster at a time, mirroring         *)
(* MovingLeafSurface.v / StationaryLeafSurface.v.                          *)
(*                                                                         *)
(* SLICE A1 (this file's first cut): the TWO PROLOGUE helpers --           *)
(* check_common_airborne_cancels (the common-cancel gate: set_water_       *)
(* plunge_action + drop_and_set_mario_action x2 + the m->quicksandDepth    *)
(* window store) and play_far_fall_sound (play_sound external + the        *)
(* m->flags window store).  Both are clean basic-engine walks.  The        *)
(* remaining 41 act handlers stay under the rest premise airborne_rest_ids.*)
(* ====================================================================== *)

From Coq Require Import ZArith Lia List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario mario_step
  mario_actions_airborne mario_actions_object interaction.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit FloorsSurface.
From SM64.Proofs Require Import ActWriterSurface ObjectLeafSurface.
From SM64.Proofs Require Import MWFReal LandingBricks StationaryLeafSurface.
From SM64.Proofs Require Import LocalVarsSurface OutParamSurface.

Import ListNotations.

(* alias + MarioState* notation *)
Module A := mario_actions_airborne.
Local Notation tyMSp := (tptr (Tstruct A._MarioState noattr)).

(* ====================================================================== *)
(* The per-function params-ok check (uniform Mario-arg leaf shape).        *)
(* ====================================================================== *)
Definition air_pok (f : function) : bool :=
  match fn_params f with
  | (i, ty) :: ps =>
      Pos.eqb i A._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id A._m (map fst ps))
  | nil => false
  end.

(* ====================================================================== *)
(* Censuses (probe-derived).                                              *)
(* ====================================================================== *)

(* set_water_plunge_action's externals (set_camera_mode + vec3s_set),
   routed through the capstone's obj_ext boundary -- verbatim the moving
   family's mov_swpa_xids. *)
Definition air_swpa_xids : list ident :=
  mario._set_camera_mode :: mario._vec3s_set :: nil.

(* check_common_airborne_cancels: set_water_plunge_action (call_pres) +
   drop_and_set_mario_action (call_pres_act). *)
Definition air_ccac_ids : list ident :=
  mario._set_water_plunge_action :: nil.
Definition air_ccac_sids : list ident :=
  mario._drop_and_set_mario_action :: nil.

(* play_far_fall_sound: play_sound (external) only. *)
Definition air_pffs_xids : list ident := mario._play_sound :: nil.

(* set_mario_action with a vm-checkably untainted constant 2nd arg *)
Definition air_sids : list ident := mario._set_mario_action :: nil.

(* ---- pin / vars / pok / walk Examples ---- *)

(* set_water_plunge_action (mario.prog) -- same body as the moving reuse *)
Example air_swpa_pin :
  (prog_defmap mario.prog) ! mario._set_water_plunge_action
  = Some (Gfun (Internal mario.f_set_water_plunge_action)).
Proof. vm_compute. reflexivity. Qed.
Example air_swpa_vars : fn_vars mario.f_set_water_plunge_action = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_swpa_pok : air_pok mario.f_set_water_plunge_action = true.
Proof. vm_compute. reflexivity. Qed.
Example air_swpa_walk :
  wwalk_chk false nil nil nil nil air_swpa_xids air_sids nil
    (fn_body mario.f_set_water_plunge_action) = true.
Proof. vm_compute. reflexivity. Qed.

(* check_common_airborne_cancels *)
Example air_ccac_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._check_common_airborne_cancels
  = Some (Gfun (Internal A.f_check_common_airborne_cancels)).
Proof. vm_compute. reflexivity. Qed.
Example air_ccac_vars : fn_vars A.f_check_common_airborne_cancels = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_ccac_pok : air_pok A.f_check_common_airborne_cancels = true.
Proof. vm_compute. reflexivity. Qed.
Example air_ccac_walk :
  wwalk_chk false nil air_ccac_ids nil nil nil air_ccac_sids nil
    (fn_body A.f_check_common_airborne_cancels) = true.
Proof. vm_compute. reflexivity. Qed.

(* play_far_fall_sound *)
Example air_pffs_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._play_far_fall_sound
  = Some (Gfun (Internal A.f_play_far_fall_sound)).
Proof. vm_compute. reflexivity. Qed.
Example air_pffs_vars : fn_vars A.f_play_far_fall_sound = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_pffs_pok : air_pok A.f_play_far_fall_sound = true.
Proof. vm_compute. reflexivity. Qed.
Example air_pffs_walk :
  wwalk_chk false nil nil nil nil air_pffs_xids nil nil
    (fn_body A.f_play_far_fall_sound) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* SLICE A2: the common_air_action_step jump-cluster.                      *)
(* ====================================================================== *)

(* common_air_action_step is the BIG shared air-physics helper (it walks
   update_air_without_turn / perform_air_step / set_mario_animation /
   check_fall_damage_or_get_stuck / set_mario_action / mario_bonk_reflection
   / mario_set_forward_vel / lava_boost_on_wall / drop_and_set_mario_action;
   all its stores are window/indexed-window + untainted-const actions).  We
   carry it as a residual (call_pres) -- an internal mario_actions_airborne
   .prog function, the air analogue of perform_ground_step's Hcp_pgs --
   discharged later by walking its body.  Its presence shrinks the 11
   common_air_action_step-dependent act handlers from whole-cloth leaves to
   thin wrappers. *)

(* the jump-cluster census: common_air_action_step (Hcp_caas) +
   play_mario_jump_sound (pmjs_row); set_mario_action + drop_and_set_mario_
   action (sids). *)
Definition air_ajc_ids : list ident :=
  A._common_air_action_step :: mario._play_mario_jump_sound :: nil.
Definition air_ajc_sids : list ident :=
  mario._set_mario_action :: mario._drop_and_set_mario_action :: nil.

(* act_freefall: B/Z input-gated set_mario_action + a Sswitch(actionArg)
   choosing the animation (no store) + caas. *)
Example air_ff_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_freefall
  = Some (Gfun (Internal A.f_act_freefall)).
Proof. vm_compute. reflexivity. Qed.
Example air_ff_vars : fn_vars A.f_act_freefall = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_ff_pok : air_pok A.f_act_freefall = true.
Proof. vm_compute. reflexivity. Qed.
Example air_ff_walk :
  wwalk_chk false nil air_ajc_ids nil nil nil air_ajc_sids nil
    (fn_body A.f_act_freefall) = true.
Proof. vm_compute. reflexivity. Qed.

(* act_hold_freefall: chase reads (m->marioObj / m->heldObj) + input-gated
   set_mario_action / drop_and_set_mario_action + caas. *)
Example air_hff_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_hold_freefall
  = Some (Gfun (Internal A.f_act_hold_freefall)).
Proof. vm_compute. reflexivity. Qed.
Example air_hff_vars : fn_vars A.f_act_hold_freefall = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_hff_pok : air_pok A.f_act_hold_freefall = true.
Proof. vm_compute. reflexivity. Qed.
Example air_hff_walk :
  wwalk_chk false nil air_ajc_ids nil nil nil air_ajc_sids nil
    (fn_body A.f_act_hold_freefall) = true.
Proof. vm_compute. reflexivity. Qed.

(* act_wall_kick_air: input-gated set_mario_action + play_mario_jump_sound
   + caas. *)
Example air_wka_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_wall_kick_air
  = Some (Gfun (Internal A.f_act_wall_kick_air)).
Proof. vm_compute. reflexivity. Qed.
Example air_wka_vars : fn_vars A.f_act_wall_kick_air = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_wka_pok : air_pok A.f_act_wall_kick_air = true.
Proof. vm_compute. reflexivity. Qed.
Example air_wka_walk :
  wwalk_chk false nil air_ajc_ids nil nil nil air_ajc_sids nil
    (fn_body A.f_act_wall_kick_air) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* The walked / rest split of airborne_callee_ids.                        *)
(* ====================================================================== *)
Definition airborne_walked_ids : list ident :=
  A._check_common_airborne_cancels ::
  A._play_far_fall_sound ::
  A._act_freefall ::
  A._act_hold_freefall ::
  A._act_wall_kick_air :: nil.

Definition airborne_rest_ids : list ident :=
  A._act_jump ::
  A._act_double_jump ::
  A._act_hold_jump ::
  A._act_side_flip ::
  A._act_twirling ::
  A._act_water_jump ::
  A._act_hold_water_jump ::
  A._act_steep_jump ::
  A._act_burning_jump ::
  A._act_burning_fall ::
  A._act_triple_jump ::
  A._act_backflip ::
  A._act_long_jump ::
  A._act_riding_shell_air ::
  A._act_dive ::
  A._act_air_throw ::
  A._act_backward_air_kb ::
  A._act_forward_air_kb ::
  A._act_hard_backward_air_kb ::
  A._act_hard_forward_air_kb ::
  A._act_butt_slide_air ::
  A._act_hold_butt_slide_air ::
  A._act_lava_boost ::
  A._act_getting_blown ::
  A._act_air_hit_wall ::
  A._act_forward_rollout ::
  A._act_backward_rollout ::
  A._act_crazy_box_bounce ::
  A._act_special_triple_jump ::
  A._act_ground_pound ::
  A._act_thrown_forward ::
  A._act_thrown_backward ::
  A._act_soft_bonk ::
  A._act_jump_kick ::
  A._act_riding_hoot ::
  A._act_top_of_pole_jump ::
  A._act_vertical_wind ::
  A._act_slide_kick :: nil.

(* the rest list is EXACTLY the non-walked complement of the census *)
Example air_rest_check :
  airborne_rest_ids
  = filter (fun id => negb (mem_id id airborne_walked_ids)) airborne_callee_ids.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
Section AirborneLeafRows.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_mario_step : linkorder mario_step.prog lp.
  Hypothesis LO_air : linkorder mario_actions_airborne.prog lp.
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
  Hypothesis HchaseStep : forall m b ofs b' o',
      MWF m -> SafeB b ->
      Mem.loadv Mptr m (Vptr b ofs) = Some (Vptr b' o') ->
      SafeB b'.
  Hypothesis HMWF_chase_safe : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv = Vptr bb oo -> SafeB bb) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.

  (* play_sound: pure audio external, the honest model boundary *)
  Hypothesis Hcpx_psound :
    call_pres_ext lp bm NoA MWF mario._play_sound.
  (* the obj_ext boundary (set_camera_mode/vec3s_set for swpa + the dasma
     trio segmented_to_virtual / stop_shell_music / obj_set_held_state).
     The capstone supplies its own Hpres_obj_ext verbatim. *)
  Hypothesis Hpres_obj_ext : forall fid,
      mem_id fid obj_ext_ids = true -> call_pres_ext lp bm NoA MWF fid.

  (* ==================================================================== *)
  (* Reused rows.                                                         *)
  (* ==================================================================== *)

  (* set_mario_action keystone *)
  Let Hsmact : call_pres_act lp bm NoA MWF mario._set_mario_action :=
    smact_pres lp LO_mario LO_mario_step bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe.

  (* drop_and_set_mario_action -- REUSED from ObjectLeafSurface.dasma_row *)
  Let Hdasma : call_pres_act lp bm NoA MWF mario._drop_and_set_mario_action :=
    dasma_row lp LO_mario LO_mario_step LO_int bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
      (Hpres_obj_ext interaction._segmented_to_virtual eq_refl)
      (Hpres_obj_ext interaction._stop_shell_music eq_refl)
      (Hpres_obj_ext interaction._obj_set_held_state eq_refl).

  (* the set_mario_action sids-rows arm *)
  Lemma air_sids_rows : forall fid, mem_id fid air_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.

  (* ==================================================================== *)
  (* set_water_plunge_action (call_pres) row.                             *)
  (* ==================================================================== *)
  Lemma air_swpa_xids_rows : forall fid, mem_id fid air_swpa_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_swpa_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (Hpres_obj_ext mario._set_camera_mode eq_refl) | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (Hpres_obj_ext mario._vec3s_set eq_refl) | ].
    discriminate H.
  Qed.

  Lemma air_swpa_row : call_pres lp bm NoA MWF mario._set_water_plunge_action.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._set_water_plunge_action
             mario.f_set_water_plunge_action
             nil nil air_swpa_xids air_sids
             LO_mario air_swpa_pin air_swpa_vars air_swpa_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_swpa_xids_rows.
    - exact air_sids_rows.
    - exact air_swpa_walk.
  Qed.

  (* ==================================================================== *)
  (* check_common_airborne_cancels (the common cancel gate).              *)
  (* ==================================================================== *)
  Lemma air_ccac_ids_rows : forall fid, mem_id fid air_ccac_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_ccac_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_swpa_row | ].
    discriminate H.
  Qed.

  Lemma air_ccac_sids_rows : forall fid, mem_id fid air_ccac_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_ccac_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hdasma | ].
    discriminate H.
  Qed.

  Lemma air_ccac_pres :
    body_pres lp NoA MWF bm A.f_check_common_airborne_cancels.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_check_common_airborne_cancels
             air_ccac_ids nil nil air_ccac_sids nil air_ccac_vars air_ccac_pok).
    - exact air_ccac_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_ccac_sids_rows.
    - intros fid' H. discriminate H.
    - exact air_ccac_walk.
  Qed.

  (* ==================================================================== *)
  (* play_far_fall_sound (the peak-fall audio cue).                       *)
  (* ==================================================================== *)
  Lemma air_pffs_xids_rows : forall fid, mem_id fid air_pffs_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_pffs_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.

  Lemma air_pffs_pres :
    body_pres lp NoA MWF bm A.f_play_far_fall_sound.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_play_far_fall_sound
             nil nil air_pffs_xids nil nil air_pffs_vars air_pffs_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_pffs_xids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_pffs_walk.
  Qed.

  (* ==================================================================== *)
  (* SLICE A2: the common_air_action_step jump-cluster.                   *)
  (* ==================================================================== *)

  (* common_air_action_step: the BIG shared air-physics helper, carried as
     a call_pres residual (internal mario_actions_airborne.prog, the air
     analogue of Hcp_pgs; discharged later by walking its body).  All its
     stores are window / indexed-window + untainted-const actions. *)
  Hypothesis Hcp_caas :
    call_pres lp bm NoA MWF mario_actions_airborne._common_air_action_step.

  (* play_mario_jump_sound -- REUSED from ObjectLeafSurface.pmjs_row *)
  Let Hpmjs : call_pres lp bm NoA MWF mario._play_mario_jump_sound :=
    ObjectLeafSurface.pmjs_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
      HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase HMWF_root
      HMWF_sglob HchaseStep HMWF_chase_safe Hcpx_psound.

  Lemma air_ajc_ids_rows : forall fid, mem_id fid air_ajc_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_ajc_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_caas | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hpmjs | ].
    discriminate H.
  Qed.

  Lemma air_ajc_sids_rows : forall fid, mem_id fid air_ajc_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_ajc_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hdasma | ].
    discriminate H.
  Qed.

  (* the three clean caas-dependent wrappers *)
  Lemma air_ff_pres : body_pres lp NoA MWF bm A.f_act_freefall.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_freefall
             air_ajc_ids nil nil air_ajc_sids nil air_ff_vars air_ff_pok).
    - exact air_ajc_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_ajc_sids_rows.
    - intros fid' H. discriminate H.
    - exact air_ff_walk.
  Qed.

  Lemma air_hff_pres : body_pres lp NoA MWF bm A.f_act_hold_freefall.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_hold_freefall
             air_ajc_ids nil nil air_ajc_sids nil air_hff_vars air_hff_pok).
    - exact air_ajc_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_ajc_sids_rows.
    - intros fid' H. discriminate H.
    - exact air_hff_walk.
  Qed.

  Lemma air_wka_pres : body_pres lp NoA MWF bm A.f_act_wall_kick_air.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_wall_kick_air
             air_ajc_ids nil nil air_ajc_sids nil air_wka_vars air_wka_pok).
    - exact air_ajc_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_ajc_sids_rows.
    - intros fid' H. discriminate H.
    - exact air_wka_walk.
  Qed.

  (* ==================================================================== *)
  (* THE REST-SPLIT: the capstone's Hpres_air_callees from the walked     *)
  (* leaves + the shrinking airborne_rest_ids residual.                   *)
  (* ==================================================================== *)
  Lemma airborne_leaf_callees_pres :
    (forall fid f, mem_id fid airborne_rest_ids = true ->
       (prog_defmap mario_actions_airborne.prog) ! fid
         = Some (Gfun (Internal f)) ->
       body_pres lp NoA MWF bm f) ->
    forall fid f, mem_id fid airborne_callee_ids = true ->
      (prog_defmap mario_actions_airborne.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f.
  Proof.
    intros Hrest fid f H Hdm.
    unfold airborne_callee_ids in H. cbn [mem_id existsb] in H.
    (* 1: check_common_airborne_cancels -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite air_ccac_pin in Hdm. injection Hdm as <-. exact air_ccac_pres. }
    (* 2: play_far_fall_sound -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite air_pffs_pin in Hdm. injection Hdm as <-. exact air_pffs_pres. }
    (* 3: act_jump -- REST *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm;
      exact (Hrest fid f ltac:(rewrite Hm; vm_compute; reflexivity) Hdm). }
    (* 4: act_double_jump -- REST *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm;
      exact (Hrest fid f ltac:(rewrite Hm; vm_compute; reflexivity) Hdm). }
    (* 5: act_freefall -- WALKED (caas wrapper) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite air_ff_pin in Hdm. injection Hdm as <-. exact air_ff_pres. }
    (* 6: act_hold_jump -- REST *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm;
      exact (Hrest fid f ltac:(rewrite Hm; vm_compute; reflexivity) Hdm). }
    (* 7: act_hold_freefall -- WALKED (caas wrapper) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite air_hff_pin in Hdm. injection Hdm as <-. exact air_hff_pres. }
    (* 8: act_side_flip -- REST *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm;
      exact (Hrest fid f ltac:(rewrite Hm; vm_compute; reflexivity) Hdm). }
    (* 9: act_wall_kick_air -- WALKED (caas wrapper) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite air_wka_pin in Hdm. injection Hdm as <-. exact air_wka_pres. }
    (* 10..43: the remaining act handlers -- all REST (uniform) *)
    repeat (apply orb_true_iff in H as [Hm | H];
            [ apply Pos.eqb_eq in Hm;
              exact (Hrest fid f ltac:(rewrite Hm; vm_compute; reflexivity) Hdm) | ]).
    discriminate H.
  Qed.

End AirborneLeafRows.
