(* ====================================================================== *)
(* THE FLOORS-FAMILY LEAF SURFACE (SPINE: floors_callees_pres DELETES the *)
(* capstone's Hpres_floors_callees residual).                             *)
(*                                                                        *)
(* Scope (probe-mapped, 2026-06-06): the special-floors census            *)
(* floors_int_ids has 4 leaves, all interaction.prog, all walked here:    *)
(*   check_death_barrier   (no stores; calls level_trigger_warp -- the    *)
(*                          capstone's SHARED warp body -- + play_sound)  *)
(*   pss_begin_slide       (one stored_globals store; calls               *)
(*                          level_control_timer)                          *)
(*   pss_end_slide         (chase store through m->marioObj + a           *)
(*                          stored_globals store; calls lct +             *)
(*                          spawn_default_star)                           *)
(*   check_lava_boost      (hurtCounter window store; calls               *)
(*                          update_mario_sound_and_camera +               *)
(*                          drop_and_set_mario_action -- the act-writer   *)
(*                          keystone tree)                                *)
(* plus their two internal helper bodies, walked here too:                *)
(*   update_mario_sound_and_camera   (mario.prog; one stored_globals      *)
(*                                    store; 2 external callees)          *)
(*   level_control_timer   (level_update.prog; NO Mario param at all --   *)
(*                          the marg-free mctw class; stores =            *)
(*                          sTimerRunning + the gHudDisplay fields, all   *)
(*                          stored_globals-class via the Efield-of-       *)
(*                          global walker arm)                            *)
(*                                                                        *)
(* Named residual hypotheses (per-symbol, satisfiable, dischargeable):    *)
(*   Hcpx_rbn / Hcpx_sds : call_pres_ext rows for the TWO floors-only     *)
(*       external leaves (raise_background_noise / spawn_default_star)    *)
(*       -- the floors_ext_ids capstone surface (warp_ext model class).   *)
(*   Hcpx_psound / Hcpx_scm / Hcpx_s2v / Hcpx_ssm / Hcpx_oshs : ext rows  *)
(*       ALREADY on the capstone (obj_ext_ids) -- shared, not new.        *)
(*   Hpres_warp : the level_trigger_warp body -- the capstone's EXISTING  *)
(*       warp_pres application (SHARED, not a new residual).              *)
(* ====================================================================== *)

From Coq Require Import ZArith Lia List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario mario_step interaction level_update
  mario_actions_airborne.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit FloorsSurface.
From SM64.Proofs Require Import ActWriterSurface ObjectLeafSurface.

Import ListNotations.

(* ====================================================================== *)
(* Censuses (probe-derived).                                              *)
(* ====================================================================== *)

Definition cdb_ids : list ident := level_update._level_trigger_warp :: nil.
Definition cdb_xids : list ident := mario._play_sound :: nil.

(* pbs/pes call the level timer; pes also spawns the slide star *)
Definition lct_xids : list ident := level_update._level_control_timer :: nil.
Definition pes_cact : list ident := interaction._t'3 :: nil.
Definition pes_xids : list ident :=
  level_update._level_control_timer
    :: interaction._spawn_default_star :: nil.

Definition clb_ids : list ident :=
  mario._update_mario_sound_and_camera :: nil.
(* the shared act-writer census: same pair as ObjectLeafSurface *)
Definition floors_leaf_sids : list ident :=
  mario._drop_and_set_mario_action :: mario._set_mario_action :: nil.

Definition umsc_xids : list ident :=
  mario._raise_background_noise :: mario._set_camera_mode :: nil.

(* the floors family's NEW external rows (capstone surface): only the two
   ids not already in obj_ext_ids *)
Definition floors_ext_ids : list ident :=
  mario._raise_background_noise
    :: interaction._spawn_default_star :: nil.

(* ====================================================================== *)
(* Pins (vm_compute over the generated TUs).                              *)
(* ====================================================================== *)

Example cdb_pin :
  (prog_defmap interaction.prog) ! interaction._check_death_barrier
  = Some (Gfun (Internal interaction.f_check_death_barrier)).
Proof. vm_compute. reflexivity. Qed.
Example pbs_pin :
  (prog_defmap interaction.prog) ! interaction._pss_begin_slide
  = Some (Gfun (Internal interaction.f_pss_begin_slide)).
Proof. vm_compute. reflexivity. Qed.
Example pes_pin :
  (prog_defmap interaction.prog) ! interaction._pss_end_slide
  = Some (Gfun (Internal interaction.f_pss_end_slide)).
Proof. vm_compute. reflexivity. Qed.
Example clb_pin :
  (prog_defmap interaction.prog) ! interaction._check_lava_boost
  = Some (Gfun (Internal interaction.f_check_lava_boost)).
Proof. vm_compute. reflexivity. Qed.
Example umsc_pin :
  (prog_defmap mario.prog) ! mario._update_mario_sound_and_camera
  = Some (Gfun (Internal mario.f_update_mario_sound_and_camera)).
Proof. vm_compute. reflexivity. Qed.
Example lct_pin :
  (prog_defmap level_update.prog) ! level_update._level_control_timer
  = Some (Gfun (Internal level_update.f_level_control_timer)).
Proof. vm_compute. reflexivity. Qed.
(* the BONUS leaf: the capstone's shared sta/mov quicksand body, whose
   census is exactly clb's machinery (umsc + the act-writer pair) *)
Example qsand_pin :
  (prog_defmap mario_step.prog) ! mario_step._mario_update_quicksand
  = Some (Gfun (Internal mario_step.f_mario_update_quicksand)).
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* Shapes: fn_vars = nil + the Mario-head parameter pin per body.         *)
(* ====================================================================== *)

Example cdb_vars : fn_vars interaction.f_check_death_barrier = nil.
Proof. reflexivity. Qed.
Example pbs_vars : fn_vars interaction.f_pss_begin_slide = nil.
Proof. reflexivity. Qed.
Example pes_vars : fn_vars interaction.f_pss_end_slide = nil.
Proof. reflexivity. Qed.
Example clb_vars : fn_vars interaction.f_check_lava_boost = nil.
Proof. reflexivity. Qed.
Example umsc_vars : fn_vars mario.f_update_mario_sound_and_camera = nil.
Proof. reflexivity. Qed.
Example qsand_vars : fn_vars mario_step.f_mario_update_quicksand = nil.
Proof. reflexivity. Qed.

Example cdb_params_ok :
  match fn_params interaction.f_check_death_barrier with
  | (i, ty) :: ps =>
      (Pos.eqb i mario_actions_airborne._m
       && proj_sumbool (type_eq ty tyMSp)
       && negb (mem_id mario_actions_airborne._m (map fst ps)))%bool
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example pbs_params_ok :
  match fn_params interaction.f_pss_begin_slide with
  | (i, ty) :: ps =>
      (Pos.eqb i mario_actions_airborne._m
       && proj_sumbool (type_eq ty tyMSp)
       && negb (mem_id mario_actions_airborne._m (map fst ps)))%bool
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example pes_params_ok :
  match fn_params interaction.f_pss_end_slide with
  | (i, ty) :: ps =>
      (Pos.eqb i mario_actions_airborne._m
       && proj_sumbool (type_eq ty tyMSp)
       && negb (mem_id mario_actions_airborne._m (map fst ps)))%bool
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example clb_params_ok :
  match fn_params interaction.f_check_lava_boost with
  | (i, ty) :: ps =>
      (Pos.eqb i mario_actions_airborne._m
       && proj_sumbool (type_eq ty tyMSp)
       && negb (mem_id mario_actions_airborne._m (map fst ps)))%bool
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example umsc_params_ok :
  match fn_params mario.f_update_mario_sound_and_camera with
  | (i, ty) :: ps =>
      (Pos.eqb i mario_actions_airborne._m
       && proj_sumbool (type_eq ty tyMSp)
       && negb (mem_id mario_actions_airborne._m (map fst ps)))%bool
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example qsand_params_ok :
  match fn_params mario_step.f_mario_update_quicksand with
  | (i, ty) :: ps =>
      (Pos.eqb i mario_actions_airborne._m
       && proj_sumbool (type_eq ty tyMSp)
       && negb (mem_id mario_actions_airborne._m (map fst ps)))%bool
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.

(* the pes chase temp is a non-param (undef at entry) *)
Example pes_nonparam :
  forallb (fun t' => negb (mem_id t'
       (map fst (fn_params interaction.f_pss_end_slide)))) pes_cact
  = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* The walks (vm_compute over the generated bodies).                      *)
(* ====================================================================== *)

Example cdb_walk :
  wwalk_chk false nil cdb_ids nil nil cdb_xids nil nil
    (fn_body interaction.f_check_death_barrier) = true.
Proof. vm_compute. reflexivity. Qed.
Example pbs_walk :
  wwalk_chk false nil nil nil nil lct_xids nil nil
    (fn_body interaction.f_pss_begin_slide) = true.
Proof. vm_compute. reflexivity. Qed.
Example pes_walk :
  wwalk_chk false nil nil nil pes_cact pes_xids nil nil
    (fn_body interaction.f_pss_end_slide) = true.
Proof. vm_compute. reflexivity. Qed.
Example clb_walk :
  wwalk_chk false nil clb_ids nil nil nil floors_leaf_sids nil
    (fn_body interaction.f_check_lava_boost) = true.
Proof. vm_compute. reflexivity. Qed.
Example umsc_walk :
  wwalk_chk false nil nil nil nil umsc_xids nil nil
    (fn_body mario.f_update_mario_sound_and_camera) = true.
Proof. vm_compute. reflexivity. Qed.
(* lct has NO Mario pointer anywhere: the plain (marg-free) walker, with
   an EMPTY callee census -- its stores are all stored_globals-class *)
Example lct_walk :
  walk_chk nil nil (fn_body level_update.f_level_control_timer) = true.
Proof. vm_compute. reflexivity. Qed.
(* quicksand: umsc (ids) + the act-writer pair (sids) + m-> field stores *)
Example qsand_walk :
  wwalk_chk false nil clb_ids nil nil nil floors_leaf_sids nil
    (fn_body mario_step.f_mario_update_quicksand) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* The rows.                                                              *)
(* ====================================================================== *)

Section FloorsLeafRows.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_mario_step : linkorder mario_step.prog lp.
  Hypothesis LO_int : linkorder interaction.prog lp.
  Hypothesis LO_lvl : linkorder level_update.prog lp.

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

  (* ---- the NAMED per-symbol residuals this surface rests on ---- *)

  (* already on the capstone (obj_ext_ids rows): SHARED *)
  Hypothesis Hcpx_psound :
    call_pres_ext lp bm NoA MWF mario._play_sound.
  Hypothesis Hcpx_scm :
    call_pres_ext lp bm NoA MWF mario._set_camera_mode.
  Hypothesis Hcpx_s2v :
    call_pres_ext lp bm NoA MWF interaction._segmented_to_virtual.
  Hypothesis Hcpx_ssm :
    call_pres_ext lp bm NoA MWF interaction._stop_shell_music.
  Hypothesis Hcpx_oshs :
    call_pres_ext lp bm NoA MWF interaction._obj_set_held_state.
  (* NEW: the floors_ext_ids capstone surface *)
  Hypothesis Hcpx_rbn :
    call_pres_ext lp bm NoA MWF mario._raise_background_noise.
  Hypothesis Hcpx_sds :
    call_pres_ext lp bm NoA MWF interaction._spawn_default_star.
  (* the warp-trigger body: the capstone's SHARED warp_pres application *)
  Hypothesis Hpres_warp : body_pres lp NoA MWF bm
      level_update.f_level_trigger_warp.

  (* the empty-census rows *)
  Lemma fl_no_int_calls :
    forall fid, mem_id fid (@nil ident) = true ->
      call_pres lp bm NoA MWF fid.
  Proof. intros fid H. cbn in H. discriminate H. Qed.
  Lemma fl_no_ext_calls :
    forall fid, mem_id fid (@nil ident) = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof. intros fid H. cbn in H. discriminate H. Qed.

  (* ---- the sids rows: the act-writer keystone pair (SHARED with the
     object family; both rows are already PROVED constants) ---- *)
  Let Hsmact : call_pres_act lp bm NoA MWF mario._set_mario_action :=
    smact_pres lp LO_mario LO_mario_step bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe.
  Let Hdasma :
    call_pres_act lp bm NoA MWF mario._drop_and_set_mario_action :=
    dasma_row lp LO_mario LO_mario_step LO_int bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
      Hcpx_s2v Hcpx_ssm Hcpx_oshs.

  Lemma floors_leaf_sids_rows :
    forall fid, mem_id fid floors_leaf_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold floors_leaf_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hdasma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.

  (* ================================================================== *)
  (* level_control_timer, WALKED: the marg-free (no Mario param) class. *)
  (* Same proof shape as WarpSurface.mctw_call_pres_ext.                *)
  (* ================================================================== *)
  Lemma lct_ext :
    call_pres_ext lp bm NoA MWF level_update._level_control_timer.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres HN HM HV HS.
    pose proof (resolve_pin_fd lp _ _ _ _ LO_lvl lct_pin Hres) as ->.
    inv Hevf.
    match goal with
    | He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry
    end.
    match goal with
    | Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody
    end.
    match goal with
    | Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree
    end.
    inv Hentry.
    match goal with
    | Ha : alloc_variables _ _ _ _ _ _ |- _ =>
        change (fn_vars level_update.f_level_control_timer)
          with (@nil (ident * type)) in Ha;
        inv Ha
    end.
    match goal with
    | Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind
    end.
    change (fn_params level_update.f_level_control_timer)
      with ((level_update._timerOp, tint) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs0 as [| v0 vrest]; [ discriminate Hbind | ].
    destruct vrest; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    (* the body has NO _m temp: the provenance fact holds vacuously *)
    assert (Htat0 : forall b o,
               (PTree.set level_update._timerOp v0
                  (create_undef_temps
                     (fn_temps level_update.f_level_control_timer)))
                 ! mario_actions_airborne._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg.
      rewrite PTree.gso in Hg
        by (intro EE; vm_compute in EE; discriminate EE).
      vm_compute in Hg. discriminate Hg. }
    destruct (walk_pres lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob nil nil fl_no_int_calls fl_no_ext_calls
                _ _ _ _ _ _ _ _ Hbody eq_refl lct_walk
                Htat0 HN HM HV HS)
      as (HV' & HS' & HM' & HN' & _).
    exact (conj HV' (conj HS' (conj HM' HN'))).
  Qed.

  (* ================================================================== *)
  (* update_mario_sound_and_camera, WALKED (mario.prog).                *)
  (* ================================================================== *)
  Lemma umsc_pres :
    body_pres lp NoA MWF bm mario.f_update_mario_sound_and_camera.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.f_update_mario_sound_and_camera
             nil nil umsc_xids nil nil
             umsc_vars umsc_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold umsc_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_rbn | ].
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_scm | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact umsc_walk.
  Qed.

  (* the two internal Mario-arg callee rows *)
  Let Humsc :
    call_pres lp bm NoA MWF mario._update_mario_sound_and_camera :=
    call_pres_of_body lp bm NoA MWF HNoA_of_MWF mario.prog
      mario._update_mario_sound_and_camera
      mario.f_update_mario_sound_and_camera LO_mario umsc_pin umsc_pres.
  Let Hltw :
    call_pres lp bm NoA MWF level_update._level_trigger_warp :=
    call_pres_of_body lp bm NoA MWF HNoA_of_MWF level_update.prog
      level_update._level_trigger_warp
      level_update.f_level_trigger_warp LO_lvl floors_warp_internal
      Hpres_warp.

  (* ================================================================== *)
  (* The four floors leaves.                                            *)
  (* ================================================================== *)
  Lemma cdb_pres :
    body_pres lp NoA MWF bm interaction.f_check_death_barrier.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             interaction.f_check_death_barrier
             cdb_ids nil cdb_xids nil nil
             cdb_vars cdb_params_ok).
    - intros fid' H. unfold cdb_ids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hltw | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold cdb_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_psound | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact cdb_walk.
  Qed.

  Lemma pbs_pres :
    body_pres lp NoA MWF bm interaction.f_pss_begin_slide.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             interaction.f_pss_begin_slide
             nil nil lct_xids nil nil
             pbs_vars pbs_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold lct_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact lct_ext | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact pbs_walk.
  Qed.

  Lemma pes_pres :
    body_pres lp NoA MWF bm interaction.f_pss_end_slide.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             interaction.f_pss_end_slide
             nil nil pes_cact pes_xids nil nil
             pes_vars pes_params_ok pes_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold pes_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact lct_ext | ].
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_sds | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact pes_walk.
  Qed.

  Lemma clb_pres :
    body_pres lp NoA MWF bm interaction.f_check_lava_boost.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             interaction.f_check_lava_boost
             clb_ids nil nil floors_leaf_sids nil
             clb_vars clb_params_ok).
    - intros fid' H. unfold clb_ids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Humsc | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact floors_leaf_sids_rows.
    - intros fid' H. discriminate H.
    - exact clb_walk.
  Qed.

  (* ================================================================== *)
  (* BONUS LEAF: mario_update_quicksand (mario_step.prog) -- the        *)
  (* capstone's Hpres_qsand body, SHARED by the stationary and moving   *)
  (* dispatchers.  Census = exactly check_lava_boost's machinery        *)
  (* (umsc + the act-writer pair); stores are m-> field stores.         *)
  (* ================================================================== *)
  Lemma qsand_pres :
    body_pres lp NoA MWF bm mario_step.f_mario_update_quicksand.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_step.f_mario_update_quicksand
             clb_ids nil nil floors_leaf_sids nil
             qsand_vars qsand_params_ok).
    - intros fid' H. unfold clb_ids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Humsc | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact floors_leaf_sids_rows.
    - intros fid' H. discriminate H.
    - exact qsand_walk.
  Qed.

  (* ================================================================== *)
  (* THE PAYOFF: the capstone's Hpres_floors_callees, PROVED.           *)
  (* ================================================================== *)
  Lemma floors_callees_pres :
    forall fid f,
      mem_id fid floors_int_ids = true ->
      (prog_defmap interaction.prog) ! fid = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f.
  Proof.
    intros fid f H Hdm.
    unfold floors_int_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite cdb_pin in Hdm. injection Hdm as <-. exact cdb_pres. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite pbs_pin in Hdm. injection Hdm as <-. exact pbs_pres. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite pes_pin in Hdm. injection Hdm as <-. exact pes_pres. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite clb_pin in Hdm. injection Hdm as <-. exact clb_pres. }
    discriminate H.
  Qed.

End FloorsLeafRows.
