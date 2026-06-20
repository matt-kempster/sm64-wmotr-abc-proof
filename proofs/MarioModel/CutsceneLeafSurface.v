(* ====================================================================== *)
(* THE CUTSCENE-FAMILY LEAF SURFACE                                        *)
(* (SPINE: cutscene_leaf_callees_pres shrinks the capstone's               *)
(*  Hpres_cut_callees down to a per-leaf census rest-split).               *)
(*                                                                         *)
(* CutsceneSurface.cutscene_pres walks the 50-arm dispatcher and reduces   *)
(* it to ONE residual: body_pres for every leaf callee in                  *)
(* cutscene_callee_ids (51 ids -- the prologue helper + 50 act handlers).  *)
(* Here we begin discharging those leaves cluster by cluster, mirroring    *)
(* SubmergedLeafSurface.v / AirborneLeafSurface.v.                         *)
(*                                                                         *)
(* SLICE 1 (this file's first cut): the DEATH cluster prologue helper      *)
(* common_death_handler (set_mario_animation + level_trigger_warp + the    *)
(* m->marioBodyState->eyeState chase store + stop_and_set_height_to_floor) *)
(* and the two cleanest death leaves act_electrocution / act_suffocation   *)
(* (play_sound_if_no_flag + common_death_handler + return 0).  The other   *)
(* 49 leaves stay under the rest premise cut_rest_ids.                     *)
(* ====================================================================== *)

From Coq Require Import ZArith Lia List.
From compcert Require Import Coqlib Maps AST Integers Floats Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario mario_step mario_actions_airborne
  mario_actions_cutscene level_update.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  DispatchKit FloorsSurface ActWriterSurface CutsceneSurface.
(* Require (not Import): reuse the proved psinf_row / sma_row / sub_sashf_row
   rows, referenced qualified -- avoids name shadowing. *)
From SM64.Proofs Require ObjectLeafSurface SubmergedLeafSurface.

Import ListNotations.

Module C := mario_actions_cutscene.
Local Notation Am := mario_actions_airborne._m.
Local Notation tyMSp := (tptr (Tstruct mario_actions_airborne._MarioState noattr)).

(* ====================================================================== *)
(* Censuses.                                                              *)
(* ====================================================================== *)

(* common_death_handler's callees (a plain call_pres helper). *)
Definition cdh_ids : list ident :=
  mario._set_mario_animation :: level_update._level_trigger_warp
    :: mario_step._stop_and_set_height_to_floor :: nil.
(* the m->marioBodyState chase temp it stores eyeState through. *)
Definition cdh_cact : list ident := C._t'2 :: nil.

(* the two cleanest death leaves: play_sound_if_no_flag + common_death_handler. *)
Definition death_ids : list ident :=
  mario._play_sound_if_no_flag :: C._common_death_handler :: nil.

(* play_mario_heavy_landing_sound's sole callee (a plain call_pres helper). *)
Definition pmhls_ids : list ident :=
  mario._play_sound_and_spawn_particles :: nil.

(* the two heavier death leaves (SLICE 2): psinf + common_death_handler +
   (animFrame==K -> play_mario_heavy_landing_sound) + return 0. *)
Definition death_ids3 : list ident :=
  mario._play_sound_if_no_flag :: C._common_death_handler
    :: mario._play_mario_heavy_landing_sound :: nil.

(* SLICE 3: the two "warp helper only" leaves (act_disappeared /
   act_teleport_fade_out) -- both call ONLY rows already proved here:
   play_sound_if_no_flag, set_mario_animation, level_trigger_warp,
   stop_and_set_height_to_floor.  (disappeared omits psinf; the superset
   census still accepts it.) *)
Definition slice3_ids : list ident :=
  mario._play_sound_if_no_flag :: mario._set_mario_animation
    :: level_update._level_trigger_warp
    :: mario_step._stop_and_set_height_to_floor :: nil.
(* the marioObj chase temps act_disappeared stores the graphnode flags through. *)
Definition disap_cact : list ident := C._t'5 :: C._t'6 :: nil.

(* the WALKED leaves (SLICE 1 + SLICE 2 + SLICE 3). *)
Definition cut_walked_ids : list ident :=
  C._act_electrocution :: C._act_suffocation
    :: C._act_death_on_back :: C._act_death_on_stomach
    :: C._act_disappeared :: C._act_teleport_fade_out :: nil.
Definition cut_rest_ids : list ident :=
  filter (fun id => negb (mem_id id cut_walked_ids)) cutscene_callee_ids.

(* ---- the AST shape pins (vm_compute reflexivity). ---- *)
Example cdh_pin :
  (prog_defmap C.prog) ! C._common_death_handler
  = Some (Gfun (Internal C.f_common_death_handler)).
Proof. vm_compute. reflexivity. Qed.
Example cdh_vars : fn_vars C.f_common_death_handler = nil.
Proof. vm_compute. reflexivity. Qed.
Example cdh_pok :
  match fn_params C.f_common_death_handler with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example cdh_nonparam :
  forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_common_death_handler))))
    cdh_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example cdh_walk :
  wwalk_chk false nil cdh_ids nil cdh_cact nil nil nil
    (fn_body C.f_common_death_handler) = true.
Proof. vm_compute. reflexivity. Qed.

Example elec_pin :
  (prog_defmap C.prog) ! C._act_electrocution
  = Some (Gfun (Internal C.f_act_electrocution)).
Proof. vm_compute. reflexivity. Qed.
Example elec_vars : fn_vars C.f_act_electrocution = nil.
Proof. vm_compute. reflexivity. Qed.
Example elec_pok :
  match fn_params C.f_act_electrocution with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example elec_walk :
  wwalk_chk false nil death_ids nil nil nil nil nil
    (fn_body C.f_act_electrocution) = true.
Proof. vm_compute. reflexivity. Qed.

Example suff_pin :
  (prog_defmap C.prog) ! C._act_suffocation
  = Some (Gfun (Internal C.f_act_suffocation)).
Proof. vm_compute. reflexivity. Qed.
Example suff_vars : fn_vars C.f_act_suffocation = nil.
Proof. vm_compute. reflexivity. Qed.
Example suff_pok :
  match fn_params C.f_act_suffocation with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example suff_walk :
  wwalk_chk false nil death_ids nil nil nil nil nil
    (fn_body C.f_act_suffocation) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE 2: play_mario_heavy_landing_sound + the two heavy death leaves. ---- *)
Example pmhls_pin :
  (prog_defmap mario.prog) ! mario._play_mario_heavy_landing_sound
  = Some (Gfun (Internal mario.f_play_mario_heavy_landing_sound)).
Proof. vm_compute. reflexivity. Qed.
Example pmhls_vars : fn_vars mario.f_play_mario_heavy_landing_sound = nil.
Proof. vm_compute. reflexivity. Qed.
Example pmhls_pok :
  match fn_params mario.f_play_mario_heavy_landing_sound with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example pmhls_walk :
  wwalk_chk false nil pmhls_ids nil nil nil nil nil
    (fn_body mario.f_play_mario_heavy_landing_sound) = true.
Proof. vm_compute. reflexivity. Qed.

Example dob_pin :
  (prog_defmap C.prog) ! C._act_death_on_back
  = Some (Gfun (Internal C.f_act_death_on_back)).
Proof. vm_compute. reflexivity. Qed.
Example dob_vars : fn_vars C.f_act_death_on_back = nil.
Proof. vm_compute. reflexivity. Qed.
Example dob_pok :
  match fn_params C.f_act_death_on_back with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example dob_walk :
  wwalk_chk false nil death_ids3 nil nil nil nil nil
    (fn_body C.f_act_death_on_back) = true.
Proof. vm_compute. reflexivity. Qed.

Example dos_pin :
  (prog_defmap C.prog) ! C._act_death_on_stomach
  = Some (Gfun (Internal C.f_act_death_on_stomach)).
Proof. vm_compute. reflexivity. Qed.
Example dos_vars : fn_vars C.f_act_death_on_stomach = nil.
Proof. vm_compute. reflexivity. Qed.
Example dos_pok :
  match fn_params C.f_act_death_on_stomach with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example dos_walk :
  wwalk_chk false nil death_ids3 nil nil nil nil nil
    (fn_body C.f_act_death_on_stomach) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE 3: act_disappeared + act_teleport_fade_out. ---- *)
Example disap_pin :
  (prog_defmap C.prog) ! C._act_disappeared
  = Some (Gfun (Internal C.f_act_disappeared)).
Proof. vm_compute. reflexivity. Qed.
Example disap_vars : fn_vars C.f_act_disappeared = nil.
Proof. vm_compute. reflexivity. Qed.
Example disap_pok :
  match fn_params C.f_act_disappeared with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example disap_nonparam :
  forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_disappeared))))
    disap_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example disap_walk :
  wwalk_chk false nil slice3_ids nil disap_cact nil nil nil
    (fn_body C.f_act_disappeared) = true.
Proof. vm_compute. reflexivity. Qed.

Example tfo_pin :
  (prog_defmap C.prog) ! C._act_teleport_fade_out
  = Some (Gfun (Internal C.f_act_teleport_fade_out)).
Proof. vm_compute. reflexivity. Qed.
Example tfo_vars : fn_vars C.f_act_teleport_fade_out = nil.
Proof. vm_compute. reflexivity. Qed.
Example tfo_pok :
  match fn_params C.f_act_teleport_fade_out with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example tfo_walk :
  wwalk_chk false nil slice3_ids nil nil nil nil nil
    (fn_body C.f_act_teleport_fade_out) = true.
Proof. vm_compute. reflexivity. Qed.

(* membership of the un-walked rest. *)
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
      destruct (P a); [ cbn [existsb]; rewrite Ea; cbn [orb]; exact IH | exact IH ].
Qed.

(* ====================================================================== *)
Section CutsceneLeafRows.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_stp : linkorder mario_step.prog lp.
  Hypothesis LO_int : linkorder interaction.prog lp.
  Hypothesis LO_lvl : linkorder level_update.prog lp.
  Hypothesis LO_cut : linkorder mario_actions_cutscene.prog lp.

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

  (* the death-cluster helper rows.  Three are PROVED ELSEWHERE and reused
     here (apply + assumption threads the standard MWF block); they bottom out
     in terminal externals carried as section hyps (discharged at the capstone
     via the obj_ext boundary -- NO new trust):
       - play_sound_if_no_flag        (ObjectLeafSurface.psinf_row;  play_sound)
       - set_mario_animation          (ObjectLeafSurface.sma_row;     load_patchable_table)
       - stop_and_set_height_to_floor (SubmergedLeafSurface.sub_sashf_row;
                                       vec3f_copy / vec3s_set)
     level_trigger_warp is the SHARED warp-trigger body (the capstone supplies
     the floors/warp call_pres_of_body term). *)
  Hypothesis Hcpx_psound : call_pres_ext lp bm NoA MWF mario._play_sound.
  Hypothesis Hcpx_lpt : call_pres_ext lp bm NoA MWF mario._load_patchable_table.
  Hypothesis Hcpx_v3fc : call_pres_ext lp bm NoA MWF mario._vec3f_copy.
  Hypothesis Hcpx_v3ss : call_pres_ext lp bm NoA MWF mario._vec3s_set.
  Hypothesis Hcp_ltw :
    call_pres lp bm NoA MWF level_update._level_trigger_warp.

  Lemma Hcp_psinf : call_pres lp bm NoA MWF mario._play_sound_if_no_flag.
  Proof. eapply ObjectLeafSurface.psinf_row; eassumption. Qed.
  Lemma Hcp_sma : call_pres lp bm NoA MWF mario._set_mario_animation.
  Proof. eapply ObjectLeafSurface.sma_row; eassumption. Qed.
  Lemma Hcp_sashf :
    call_pres lp bm NoA MWF mario_step._stop_and_set_height_to_floor.
  Proof. eapply SubmergedLeafSurface.sub_sashf_row; eassumption. Qed.

  (* common_death_handler: set_mario_animation + (animFrame==warpFrame ->
     level_trigger_warp) + m->marioBodyState->eyeState = 8 (chase store) +
     stop_and_set_height_to_floor.  NEVER the action cell -> genuine call_pres. *)
  Lemma cdh_ids_rows : forall fid, mem_id fid cdh_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold cdh_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_ltw | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sashf | ].
    discriminate H.
  Qed.

  Lemma cdh_row :
    call_pres lp bm NoA MWF C._common_death_handler.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_cutscene.prog C._common_death_handler
             C.f_common_death_handler
             cdh_ids nil cdh_cact nil nil
             LO_cut cdh_pin cdh_vars cdh_pok cdh_nonparam).
    - exact cdh_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact cdh_walk.
  Qed.

  (* the two death leaves. *)
  Lemma death_ids_rows : forall fid, mem_id fid death_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold death_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_psinf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cdh_row | ].
    discriminate H.
  Qed.

  Lemma elec_pres : body_pres lp NoA MWF bm C.f_act_electrocution.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_electrocution death_ids nil nil nil nil
             elec_vars elec_pok).
    - exact death_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact elec_walk.
  Qed.

  Lemma suff_pres : body_pres lp NoA MWF bm C.f_act_suffocation.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_suffocation death_ids nil nil nil nil
             suff_vars suff_pok).
    - exact death_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact suff_walk.
  Qed.

  (* ---- SLICE 2: play_mario_heavy_landing_sound + death_on_back/stomach. ---- *)
  (* play_sound_and_spawn_particles is the sole callee of pmhls; its row is
     PROVED in ObjectLeafSurface and reused here (window stores to
     m->particleFlags + the play_sound external).  NO new trust. *)
  Lemma Hcp_psasp :
    call_pres lp bm NoA MWF mario._play_sound_and_spawn_particles.
  Proof. eapply ObjectLeafSurface.psasp_row; eassumption. Qed.

  Lemma pmhls_ids_rows : forall fid, mem_id fid pmhls_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold pmhls_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_psasp | ].
    discriminate H.
  Qed.

  Lemma pmhls_row :
    call_pres lp bm NoA MWF mario._play_mario_heavy_landing_sound.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._play_mario_heavy_landing_sound
             mario.f_play_mario_heavy_landing_sound
             pmhls_ids nil nil nil
             LO_mario pmhls_pin pmhls_vars pmhls_pok).
    - exact pmhls_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact pmhls_walk.
  Qed.

  (* the two heavy death leaves: psinf + common_death_handler + pmhls. *)
  Lemma death_ids3_rows : forall fid, mem_id fid death_ids3 = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold death_ids3 in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_psinf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cdh_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact pmhls_row | ].
    discriminate H.
  Qed.

  Lemma dob_pres : body_pres lp NoA MWF bm C.f_act_death_on_back.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_death_on_back death_ids3 nil nil nil nil
             dob_vars dob_pok).
    - exact death_ids3_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact dob_walk.
  Qed.

  Lemma dos_pres : body_pres lp NoA MWF bm C.f_act_death_on_stomach.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_death_on_stomach death_ids3 nil nil nil nil
             dos_vars dos_pok).
    - exact death_ids3_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact dos_walk.
  Qed.

  (* ---- SLICE 3: act_disappeared + act_teleport_fade_out. ---- *)
  (* both call only the four already-proved helper rows; disappeared also
     stores the marioObj graphnode flags through its chase temps (disap_cact). *)
  Lemma slice3_ids_rows : forall fid, mem_id fid slice3_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold slice3_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_psinf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_ltw | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sashf | ].
    discriminate H.
  Qed.

  Lemma disap_pres : body_pres lp NoA MWF bm C.f_act_disappeared.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_disappeared slice3_ids nil disap_cact nil nil nil
             disap_vars disap_pok disap_nonparam).
    - exact slice3_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact disap_walk.
  Qed.

  Lemma tfo_pres : body_pres lp NoA MWF bm C.f_act_teleport_fade_out.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_teleport_fade_out slice3_ids nil nil nil nil
             tfo_vars tfo_pok).
    - exact slice3_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact tfo_walk.
  Qed.

  (* ==================================================================== *)
  (* The family rest-split: discharge the SLICE-1/2/3 leaves, leaving     *)
  (* the other 45 under cut_rest_ids.                                     *)
  (* ==================================================================== *)
  Lemma cutscene_leaf_callees_pres :
    (forall fid f, mem_id fid cut_rest_ids = true ->
       (prog_defmap mario_actions_cutscene.prog) ! fid
         = Some (Gfun (Internal f)) ->
       body_pres lp NoA MWF bm f) ->
    forall fid f, mem_id fid cutscene_callee_ids = true ->
      (prog_defmap mario_actions_cutscene.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f.
  Proof.
    intros Hrest fid f H Hdm.
    destruct (Pos.eqb fid C._act_electrocution) eqn:E1.
    { apply Pos.eqb_eq in E1; subst fid.
      rewrite elec_pin in Hdm. injection Hdm as <-. exact elec_pres. }
    destruct (Pos.eqb fid C._act_suffocation) eqn:E2.
    { apply Pos.eqb_eq in E2; subst fid.
      rewrite suff_pin in Hdm. injection Hdm as <-. exact suff_pres. }
    destruct (Pos.eqb fid C._act_death_on_back) eqn:E3.
    { apply Pos.eqb_eq in E3; subst fid.
      rewrite dob_pin in Hdm. injection Hdm as <-. exact dob_pres. }
    destruct (Pos.eqb fid C._act_death_on_stomach) eqn:E4.
    { apply Pos.eqb_eq in E4; subst fid.
      rewrite dos_pin in Hdm. injection Hdm as <-. exact dos_pres. }
    destruct (Pos.eqb fid C._act_disappeared) eqn:E5.
    { apply Pos.eqb_eq in E5; subst fid.
      rewrite disap_pin in Hdm. injection Hdm as <-. exact disap_pres. }
    destruct (Pos.eqb fid C._act_teleport_fade_out) eqn:E6.
    { apply Pos.eqb_eq in E6; subst fid.
      rewrite tfo_pin in Hdm. injection Hdm as <-. exact tfo_pres. }
    (* REST: fid is in the census and not a walked id. *)
    apply (Hrest fid f); [ | exact Hdm ].
    unfold cut_rest_ids.
    apply mem_id_filter_true; [ exact H | ].
    unfold cut_walked_ids. cbn [mem_id existsb].
    rewrite E1, E2, E3, E4, E5, E6. reflexivity.
  Qed.

End CutsceneLeafRows.
