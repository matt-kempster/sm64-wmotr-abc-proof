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
  mario_actions_airborne mario_actions_submerged.
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

(* set_mario_action(const) is the only action-writer in slice 1. *)
Definition sub_sids : list ident := mario._set_mario_action :: nil.

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

(* the WALKED leaves. *)
Definition sub_walked_ids : list ident :=
  mario_actions_submerged._act_metal_water_standing
    :: mario_actions_submerged._act_metal_water_jump_land
    :: mario_actions_submerged._act_metal_water_fall_land
    :: mario_actions_submerged._act_metal_water_jump :: nil.
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

  Lemma sub_sids_rows : forall fid, mem_id fid sub_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sub_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
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
    (* REST: fid is in the census and not a walked id, so it is in the
       filter that defines sub_rest_ids. *)
    apply (Hrest fid f); [ | exact Hdm ].
    unfold sub_rest_ids.
    apply mem_id_filter_true; [ exact H | ].
    unfold sub_walked_ids. cbn [mem_id existsb].
    rewrite Ew1, Ew2, Ew3, Ew4. reflexivity.
  Qed.

End SubmergedLeafRows.
