(* ====================================================================== *)
(* CameraBodies.v -- the camera.c entries of the any-argument external     *)
(* lists, proved from their REAL bodies (SPINE: GOAL 1 premise sweep,      *)
(* 2026-10-22).                                                            *)
(*                                                                        *)
(* camera.c is the 35th TU.  Three entries of GOAL 1's any-argument lists *)
(* name functions it defines, so since the link those rows were claims    *)
(* about real code.  Each is now a lemma, walked over the generated body  *)
(* with SpawnBodies.sw_walk (switch- and loop-tolerant) and                *)
(* ObjExtBodies' store class ast_ok (a by-value store into a global that  *)
(* MWF does not read, with a value that cannot be a pointer):             *)
(*  - camera_approach_f32_symmetric: pure float arithmetic, no store;     *)
(*  - trigger_cutscene_dialog -> start_object_cutscene_without_focus:     *)
(*    two byte stores, sObjectCutscene / sCutsceneDialogResponse;         *)
(*  - set_camera_shake_from_hit -> set_camera_pitch/yaw/roll_shake,       *)
(*    set_fov_shake: s16 / f32 stores into gLakituState and sFOVState.    *)
(*    Its SHAKE_SHOCK arm calls random_float (engine/behavior_script.c,   *)
(*    NOT linked), so the row is proved FROM random_float's any-argument  *)
(*    row, which replaces it in the open list (a strictly narrower claim: *)
(*    a void-argument RNG instead of the whole shake dispatcher).         *)
(* The sqrtf entry is proved from the FPU floor sqrtf_spec (TRUST 3.5),   *)
(* already a premise of the capstone: the call leaves memory unchanged.   *)
(* FINDING: no row was false -- every store lands in a global no MWF row  *)
(* reads, with a non-pointer value, whatever the arguments.               *)
(* ====================================================================== *)

From Coq Require Import ZArith List String.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario camera interaction mario_actions_cutscene.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked AGates CensusV2 RestSurface MWFReal SpawnInit MathBodies
  FloorsSurface LinkedTwelve FpuFloor.
From SM64.Proofs Require MtxfBody SpawnBodies ObjExtBodies.

Import ListNotations.

(* ---------------------------------------------------------------------- *)
(* 1. The generated-AST pins and the recognizer runs.                       *)
(* ---------------------------------------------------------------------- *)

Local Notation cam_dm id f :=
  ((prog_defmap camera.prog) ! id = Some (Gfun (Internal f))).

Lemma dm_cafs :
  cam_dm camera._camera_approach_f32_symmetric camera.f_camera_approach_f32_symmetric.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_tcd : cam_dm camera._trigger_cutscene_dialog camera.f_trigger_cutscene_dialog.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_socwf :
  cam_dm camera._start_object_cutscene_without_focus
    camera.f_start_object_cutscene_without_focus.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_csh : cam_dm camera._set_camera_shake_from_hit camera.f_set_camera_shake_from_hit.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_cps : cam_dm camera._set_camera_pitch_shake camera.f_set_camera_pitch_shake.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_cys : cam_dm camera._set_camera_yaw_shake camera.f_set_camera_yaw_shake.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_crs : cam_dm camera._set_camera_roll_shake camera.f_set_camera_roll_shake.
Proof. vm_compute. reflexivity. Qed.
Lemma dm_fov : cam_dm camera._set_fov_shake camera.f_set_fov_shake.
Proof. vm_compute. reflexivity. Qed.

(* the camera walk: every Sset / return is free, every store is ast_ok, and
   every call names one of ids *)
Definition cam_chk (ids : list ident) (f : Clight.function) : bool :=
  SpawnBodies.sw_chk (fun _ _ => true) ObjExtBodies.ast_ok (ObjExtBodies.a_call_ok ids)
    (fun _ => true) (fn_body f).

Definition ids_tcd : list ident := [camera._start_object_cutscene_without_focus].
Definition ids_csh : list ident :=
  [camera._set_camera_pitch_shake; camera._set_camera_yaw_shake;
   camera._set_camera_roll_shake; camera._set_fov_shake; camera._random_float].

(* NON-VACUITY: the recognizer accepts each REAL body *)
Lemma chk_cafs : cam_chk nil camera.f_camera_approach_f32_symmetric = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_socwf : cam_chk nil camera.f_start_object_cutscene_without_focus = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_tcd : cam_chk ids_tcd camera.f_trigger_cutscene_dialog = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_cps : cam_chk nil camera.f_set_camera_pitch_shake = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_cys : cam_chk nil camera.f_set_camera_yaw_shake = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_crs : cam_chk nil camera.f_set_camera_roll_shake = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_fov : cam_chk nil camera.f_set_fov_shake = true.
Proof. vm_compute. reflexivity. Qed.
Lemma chk_csh : cam_chk ids_csh camera.f_set_camera_shake_from_hit = true.
Proof. vm_compute. reflexivity. Qed.
(* and the callee list is not decorative: without random_float the shake
   dispatcher is rejected (its SHAKE_SHOCK arm) *)
Example chk_csh_needs_rf :
  cam_chk (removelast ids_csh) camera.f_set_camera_shake_from_hit = false.
Proof. vm_compute. reflexivity. Qed.

(* (rf_no_internal is gone: since 2026-10-23 engine/behavior_script.c is
   the 43rd TU, so random_float has its real body, MenuBodies.Hpx_rf) *)

(* ---------------------------------------------------------------------- *)
(* 2. The rows, at the concrete MWF_real.                                   *)
(* ---------------------------------------------------------------------- *)

Section CameraRows.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.

  Let MWF := MWF_real lp bm bc oc0 SafeB.
  Let NoA := fun m => ctl_a_clear m bm.
  Let sym_pres := ObjExtBodies.sym_pres lp bm bc oc0 SafeB.

  Lemma cam_store : forall lv rhs le m0 t0 le' m0' out,
      ObjExtBodies.ast_ok lv rhs = true ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m0 (Sassign lv rhs) t0 le' m0' out ->
      ow_facts bm MWF m0 -> ow_facts bm MWF m0'.
  Proof. intros. eapply ObjExtBodies.ast_store_pres; eassumption. Qed.

  Lemma cam_call : forall ids,
      (forall g, mem_id g ids = true -> sym_pres g) ->
      forall optid a al le m0 t0 le' m0' out,
        ObjExtBodies.a_call_ok ids optid a al = true ->
        exec_stmt function_entry2 (lp_ge lp) empty_env le m0 (Scall optid a al) t0 le' m0' out ->
        ow_facts bm MWF m0 -> ow_facts bm MWF m0'.
  Proof. intros. eapply ObjExtBodies.gcall_pres; eassumption. Qed.

  (* a no-locals body that passes cam_chk keeps the carried facts *)
  Lemma cam_body_pres : forall ids f,
      fn_vars f = nil -> cam_chk ids f = true ->
      (forall g, mem_id g ids = true -> sym_pres g) ->
      forall m vargs t m' vres,
        eval_funcall function_entry2 (lp_ge lp) m (Internal f) vargs t m' vres ->
        ow_facts bm MWF m -> ow_facts bm MWF m'.
  Proof.
    intros ids f Hvars Hchk Hids m vargs t m' vres Hevf Hf0.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hfl : Mem.free_list _ _ = Some _ |- _ => rename Hfl into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rewrite Hvars in Ha; inv Ha end.
    destruct (SpawnBodies.sw_walk (lp_ge lp) empty_env (ow_facts bm MWF)
                (fun _ => True) (fun _ => True)
                (fun _ _ => true) ObjExtBodies.ast_ok (ObjExtBodies.a_call_ok ids)
                (fun _ => true)
                (fun _ _ _ _ _ _ _ _ _ => I)
                (fun lv rhs le m0 t0 le' m0' out Hok _ Hx Hf =>
                   cam_store lv rhs le m0 t0 le' m0' out Hok Hx Hf)
                (fun optid a al le m0 t0 le' m0' out Hok _ Hx Hf =>
                   conj (cam_call ids Hids optid a al le m0 t0 le' m0' out Hok Hx Hf) I)
                (fun _ _ _ _ _ _ _ _ => I)
                _ _ _ _ _ _ _ _ Hbody eq_refl Hchk I Hf0) as (Hf1 & _).
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    exact Hf1.
  Qed.

  Ltac cam_sym dm chk ids :=
    eapply (ObjExtBodies.sym_pres_of_body); [ exact (linked12_LO_camera lp H12) | exact dm | ];
    apply (cam_body_pres ids); [ reflexivity | exact chk | ].

  Lemma sp_cafs : sym_pres camera._camera_approach_f32_symmetric.
  Proof. cam_sym dm_cafs chk_cafs (@nil ident). intros g Hg. discriminate Hg. Qed.
  Lemma sp_socwf : sym_pres camera._start_object_cutscene_without_focus.
  Proof. cam_sym dm_socwf chk_socwf (@nil ident). intros g Hg. discriminate Hg. Qed.
  Lemma sp_tcd : sym_pres camera._trigger_cutscene_dialog.
  Proof.
    cam_sym dm_tcd chk_tcd ids_tcd.
    intros g Hg. cbn [mem_id existsb ids_tcd] in Hg.
    apply orb_true_iff in Hg as [Hg | Hg]; [ | discriminate Hg ].
    apply Pos.eqb_eq in Hg. subst g. exact sp_socwf.
  Qed.
  Lemma sp_cps : sym_pres camera._set_camera_pitch_shake.
  Proof. cam_sym dm_cps chk_cps (@nil ident). intros g Hg. discriminate Hg. Qed.
  Lemma sp_cys : sym_pres camera._set_camera_yaw_shake.
  Proof. cam_sym dm_cys chk_cys (@nil ident). intros g Hg. discriminate Hg. Qed.
  Lemma sp_crs : sym_pres camera._set_camera_roll_shake.
  Proof. cam_sym dm_crs chk_crs (@nil ident). intros g Hg. discriminate Hg. Qed.
  Lemma sp_fov : sym_pres camera._set_fov_shake.
  Proof. cam_sym dm_fov chk_fov (@nil ident). intros g Hg. discriminate Hg. Qed.

  (* an any-argument row gives the symbol fact *)
  Lemma sym_of_row : forall fid,
      call_pres_ext lp bm NoA MWF fid -> sym_pres fid.
  Proof.
    intros fid Hrow b fd Hs Hfp m vargs t m' vres Hevf (Hv & Hsat & HM).
    assert (Hres : EngineV2Consumer.resolves_lp lp fid fd).
    { exists b. split; [ exact Hs | ].
      rewrite Genv.find_funct_find_funct_ptr. exact Hfp. }
    destruct (Hrow fd m vargs t m' vres Hevf Hres (mwf_real_ctl lp bm bc oc0 SafeB _ HM)
                HM Hv Hsat) as (Hv' & Hs' & HM' & _).
    exact (conj Hv' (conj Hs' HM')).
  Qed.

  (* random_float (engine/behavior_script.c, not linked): its any-argument
     row, which the capstone now carries in place of the shake dispatcher's *)
  Hypothesis Hrf : call_pres_ext lp bm NoA MWF camera._random_float.

  Lemma sp_csh : sym_pres camera._set_camera_shake_from_hit.
  Proof.
    cam_sym dm_csh chk_csh ids_csh.
    intros g Hg. cbn [mem_id existsb ids_csh] in Hg.
    repeat (apply orb_true_iff in Hg as [Hg | Hg];
            [ apply Pos.eqb_eq in Hg; subst g | ]);
      [ exact sp_cps | exact sp_cys | exact sp_crs | exact sp_fov
      | exact (sym_of_row _ Hrf) | discriminate Hg ].
  Qed.

  (* ---- THE ROWS ---- *)
  Lemma Hpx_cafs :
    call_pres_ext lp bm NoA MWF mario_actions_cutscene._camera_approach_f32_symmetric.
  Proof. eapply ObjExtBodies.row_of_sym; exact sp_cafs. Qed.
  Lemma Hpx_tcd :
    call_pres_ext lp bm NoA MWF mario_actions_cutscene._trigger_cutscene_dialog.
  Proof. eapply ObjExtBodies.row_of_sym; exact sp_tcd. Qed.
  Lemma Hpx_csh :
    call_pres_ext lp bm NoA MWF interaction._set_camera_shake_from_hit.
  Proof. eapply ObjExtBodies.row_of_sym; exact sp_csh. Qed.

  (* sqrtf: the FPU floor (TRUST 3.5) says the call leaves memory as it was *)
  Hypothesis Hsq : sqrtf_spec.
  Lemma Hpx_sqrtf : call_pres_ext lp bm NoA MWF mario._sqrtf.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf (b & Hs & Hff) Hno HM Hv Hsat.
    pose proof (MtxfBody.sqrtf_memid lp H12 Hsq b fd m0 vargs0 t0 m1 vres0 Hs Hff Hevf)
      as ->.
    exact (conj Hv (conj Hsat (conj HM Hno))).
  Qed.
End CameraRows.

(* the FPU external, recognized by name (for the engine rows' sqrtf split) *)
Definition is_sqrtf_ef (ef : external_function) : Prop :=
  exists sg, ef = EF_external "sqrtf" sg.

Lemma ef_sqrtf_dec : forall ef, is_sqrtf_ef ef \/ ~ is_sqrtf_ef ef.
Proof.
  intros ef.
  destruct (string_dec (match ef with EF_external n _ => n | _ => EmptyString end) "sqrtf")
    as [ E | Hn ].
  - destruct ef; try discriminate E. left. exists sg. rewrite E. reflexivity.
  - right. intros (sg' & E). subst ef. exact (Hn eq_refl).
Qed.
