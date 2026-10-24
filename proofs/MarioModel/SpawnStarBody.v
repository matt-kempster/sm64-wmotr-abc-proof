(* ====================================================================== *)
(* SpawnStarBody.v -- spawn_default_star, the last floors-external row,    *)
(* proved from its REAL body (SPINE: GOAL 1 premise sweep, 2026-10-23).    *)
(*                                                                        *)
(* game/obj_behaviors.c is linked (the 44th TU): interaction.c's           *)
(* pss_end_slide (the PSS slide timer, a special-floor case of             *)
(* mario_handle_special_floors) calls spawn_default_star(x, y, z), whose   *)
(* real body (behaviors/spawn_star.inc.c, #included by obj_behaviors.c) is *)
(*   star = spawn_star(star, x, y, z); star->oBhvParams2ndByte = 0;        *)
(* and spawn_star is                                                       *)
(*   star = spawn_object_abs_with_rot(o, 0, MODEL_STAR,                    *)
(*            bhvStarSpawnCoordinates, o->oPosX, o->oPosY, o->oPosZ, 0,0,0);*)
(*   star->oBhvParams = o->oBhvParams; star->oHome{X,Y,Z} = x, y, z;       *)
(*   star->oFaceAnglePitch = star->oFaceAngleRoll = 0; return star;        *)
(* with o = gCurrentObject.  spawn_star is walked with SpawnBodies'         *)
(* SafeB-world recognizer (every temp SafeB-if-pointer; spawn_object_abs_  *)
(* with_rot is the proved sres row): every store goes through the SafeB    *)
(* object spawn returns, and every stored value is a float argument, a     *)
(* constant, or a load from gCurrentObject's (SafeB) object.               *)
(* spawn_default_star is walked with the pointer-temps class of            *)
(* ObjExtBodies (only star / t'1 carry pointers; its three f32 arguments    *)
(* reach spawn_star through a cast to float, which never yields a          *)
(* pointer), so its row holds for ANY arguments, as the capstone states.  *)
(* FOUND (the SUSPECT, confirmed): spawn_object_abs_with_rot stores its    *)
(* behavior argument bhvStarSpawnCoordinates into the new pool object      *)
(* (curBhvCommand / behavior).  That script was not a SafeB symbol, so the *)
(* any-argument row rested on nothing (a SafeB pool object pointing        *)
(* outside SafeB breaks MWF's load closure R7).  REPAIRED:                 *)
(* bhvStarSpawnCoordinates joins CensusV2.spawn_bhv_syms (so safe_ptr_syms, *)
(* the same class as the other spawned scripts: SafeB_syms_ok (c)).        *)
(* ====================================================================== *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario object_helpers interaction obj_behaviors.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame Taint
  RealFrameLinked AGates CensusV2 RestSurface MWFReal SpawnInit
  FloorsSurface MathBodies LinkedTwelve MathGeomGated MathGeomBodies.
From SM64.Proofs Require SpawnBodies ObjExtBodies ObjHelpersBodies MtxfBody.

Import ListNotations.

(* ---------------------------------------------------------------------- *)
(* 1. The generated-AST pins and the recognizer runs.                       *)
(* ---------------------------------------------------------------------- *)

Lemma dm_star :
  (prog_defmap obj_behaviors.prog) ! obj_behaviors._spawn_star
    = Some (Gfun (Internal obj_behaviors.f_spawn_star)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_sds :
  (prog_defmap obj_behaviors.prog) ! obj_behaviors._spawn_default_star
    = Some (Gfun (Internal obj_behaviors.f_spawn_default_star)).
Proof. vm_compute. reflexivity. Qed.

Definition vt_star : list ident := [object_helpers._spawn_object_abs_with_rot].

(* NON-VACUITY: SpawnBodies' recognizer accepts the REAL spawn_star *)
Lemma chk_star : SpawnBodies.sb_chk SpawnBodies.sb_gs vt_star obj_behaviors.f_spawn_star = true.
Proof. vm_compute. reflexivity. Qed.
(* and the gs list is not decorative: without bhvStarSpawnCoordinates the
   spawn call (its behavior argument) is rejected -- the finding above *)
Example chk_star_needs_bhv :
  SpawnBodies.sb_chk (filter (fun x => negb (Pos.eqb x obj_behaviors._bhvStarSpawnCoordinates))
                        SpawnBodies.sb_gs)
    vt_star obj_behaviors.f_spawn_star = false.
Proof. vm_compute. reflexivity. Qed.

(* spawn_default_star: only star / t'1 carry pointers *)
Definition sds_sp : list ident := [obj_behaviors._star; obj_behaviors._t'1].

(* an argument is fine if it is a pointer temp's value, or is cast to a
   type whose values are never pointers *)
Fixpoint star_args_ok (ps : list type) (al : list expr) : bool :=
  match ps, al with
  | p :: ps', a :: al' =>
      (nonptr_scalar p || ObjExtBodies.val_ok sds_sp a) && star_args_ok ps' al'
  | nil, nil => true
  | _, _ => false
  end.

Definition sds_call_ok (optid : option ident) (a : expr) (al : list expr) : bool :=
  match a with
  | Evar f (Tfunction ps _ _) => Pos.eqb f obj_behaviors._spawn_star && star_args_ok ps al
  | _ => false
  end.

Lemma chk_sds :
  ObjHelpersBodies.tw_chk (ObjExtBodies.ox_set_ok sds_sp) (ObjExtBodies.ox_store_ok sds_sp)
    sds_call_ok (fn_body obj_behaviors.f_spawn_default_star) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 2. The row, at the concrete MWF_real.                                    *)
(* ---------------------------------------------------------------------- *)

Section SpawnStarRow.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables bm bc : block.
  Variable oc0 : ptrofs.
  Variable SafeB : block -> Prop.
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.

  Let MWF := MWF_real lp bm bc oc0 SafeB.
  Let NoA := fun m => ctl_a_clear m bm.
  Let sp_P := ObjExtBodies.sp_P SafeB.

  (* spawn_star is in the SafeB world (SpawnBodies.sres) *)
  Lemma sr_star : SpawnBodies.sres lp bm bc oc0 SafeB obj_behaviors._spawn_star.
  Proof.
    eapply SpawnBodies.sres_of; [ exact (linked12_LO_obj_behaviors lp H12) | exact dm_star | ].
    eapply SpawnBodies.body_sfun; [ exact H12 | exact HSafeB_syms | exact Hspawn | exact chk_star | ].
    intros fid Hf. cbn [mem_id existsb vt_star] in Hf.
    apply orb_true_iff in Hf as [Hf | Hf]; [ | discriminate Hf ].
    apply Pos.eqb_eq in Hf. subst fid.
    exact (SpawnBodies.sr_soawr lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn).
  Qed.

  Lemma val_safe : forall le m a v,
      ObjExtBodies.val_ok sds_sp a = true -> sp_P sds_sp le -> MWF m ->
      eval_expr (lp_ge lp) empty_env le m a v ->
      forall b o, v = Vptr b o -> SafeB b.
  Proof. intros. eapply ObjExtBodies.val_ok_safe; eassumption. Qed.

  (* the call's argument values are SafeB-if-pointer *)
  Lemma star_args_safe : forall le m al tyl vl,
      eval_exprlist (lp_ge lp) empty_env le m al tyl vl ->
      star_args_ok tyl al = true -> sp_P sds_sp le -> MWF m ->
      Forall (SpawnBodies.safev SafeB) vl.
  Proof.
    intros le m al tyl vl Hel. induction Hel; intros Hok HP HM; [ constructor | ].
    cbn [star_args_ok] in Hok. apply andb_prop in Hok as [H1 H2].
    constructor; [ | exact (IHHel H2 HP HM) ].
    intros b o ->.
    apply orb_true_iff in H1 as [Hnp | Hv].
    - exfalso.
      match goal with Hc : sem_cast _ _ _ _ = Some (Vptr b o) |- _ =>
        exact (sem_cast_to_nonptr_scalar _ _ _ _ _ Hnp Hc b o eq_refl) end.
    - match goal with Hc : sem_cast ?v1 _ _ _ = Some (Vptr b o),
                      He : eval_expr _ _ _ _ ?a ?v1 |- _ =>
        pose proof (ActWriterSurface.sem_cast_vptr_inv _ _ _ _ _ _ Hc) as Ev; subst v1;
        exact (val_safe le m a _ Hv HP HM He b o eq_refl) end.
  Qed.

  Lemma sds_call : forall optid a al le m t le' m' out,
      sds_call_ok optid a al = true -> sp_P sds_sp le ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m (Scall optid a al) t le' m' out ->
      ow_facts bm MWF m -> ow_facts bm MWF m' /\ sp_P sds_sp le'.
  Proof.
    intros optid a al le m t le' m' out Hok HP Hx Hf.
    destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hok.
    destruct fty as [ | | | | | | targs tres tcc | | ]; try discriminate Hok.
    cbn [sds_call_ok] in Hok. apply andb_prop in Hok as [Hid Hal].
    apply Pos.eqb_eq in Hid. subst fid.
    inv Hx.
    match goal with Hee : eval_expr _ _ _ _ (Evar _ _) ?vf |- _ =>
      destruct (evar_fun_val _ _ _ _ _ _ _ _ _ Hee (PTree.gempty _ _)) as (lf & Hsy & ->) end.
    match goal with Hcf : classify_fun _ = fun_case_f _ _ _ |- _ =>
      cbn in Hcf; injection Hcf as E1 E2 E3; subst end.
    match goal with Hel : eval_exprlist _ _ _ _ _ _ _ |- _ =>
      pose proof (star_args_safe _ _ _ _ _ Hel Hal HP (proj2 (proj2 Hf))) as Hva end.
    match goal with Hff : Genv.find_funct _ _ = Some ?fd,
                    Hfc : eval_funcall _ _ _ ?fd _ _ _ ?vr |- _ =>
      destruct (sr_star lf fd Hsy Hff _ _ _ _ _ Hfc Hva Hf) as (Hf' & Hr)
    end.
    split; [ exact Hf' | ].
    intros t0 b o Ht0 Hle.
    destruct optid as [ti|]; cbn [set_opttemp] in Hle; [ | exact (HP _ _ _ Ht0 Hle) ].
    destruct (peq t0 ti) as [-> | Hne].
    + rewrite PTree.gss in Hle. injection Hle as Ev. exact (Hr b o Ev).
    + rewrite PTree.gso in Hle by exact Hne. exact (HP _ _ _ Ht0 Hle).
  Qed.

  Lemma sp_sds : ObjExtBodies.sym_pres lp bm bc oc0 SafeB obj_behaviors._spawn_default_star.
  Proof.
    eapply ObjExtBodies.sym_pres_of_body;
      [ exact (linked12_LO_obj_behaviors lp H12) | exact dm_sds | ].
    intros m vargs t m' vres Hevf Hf.
    refine (ObjHelpersBodies.tw_body_frame (lp_ge lp) MWF bm obj_behaviors.f_spawn_default_star
              (sp_P sds_sp) (ObjExtBodies.ox_set_ok sds_sp) (ObjExtBodies.ox_store_ok sds_sp)
              sds_call_ok eq_refl chk_sds _ _ sds_call _ _ _ _ _ Hevf _ Hf).
    - intros. eapply ObjExtBodies.ox_set; eassumption.
    - intros. eapply ObjExtBodies.ox_store; eassumption.
    - (* entry: star / t'1 are temps, not parameters: they start undefined *)
      intros le1 Hb t0 b o Ht0 Hle.
      rewrite (bind_parameter_temps_gso _ _ _ _ t0 Hb) in Hle.
      + apply MtxfBody.create_undef_temps_get in Hle. discriminate Hle.
      + cbn [var_names map fst fn_params obj_behaviors.f_spawn_default_star].
        intros [E | [E | [E | []]]]; subst t0; vm_compute in Ht0; discriminate Ht0.
  Qed.

  (* ---- THE ROW ---- *)
  Lemma Hpx_sds : call_pres_ext lp bm NoA MWF interaction._spawn_default_star.
  Proof. eapply ObjExtBodies.row_of_sym; exact sp_sds. Qed.
End SpawnStarRow.
